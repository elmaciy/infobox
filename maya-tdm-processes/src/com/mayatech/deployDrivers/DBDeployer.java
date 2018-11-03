package com.mayatech.deployDrivers;

import java.io.File;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;

import com.mayatech.baseLibs.fileUtilities;
import com.mayatech.baseLibs.genLib;
import com.mayatech.tdm.commonLib;

public class DBDeployer {

	StringBuilder logs=new StringBuilder();
	
	void mylog(String log) {
		System.out.println(log);
		logs.append(log);
		logs.append("\n");
		
	}
	
	
	public ArrayList<String[]> deploy(ArrayList<String[]> parameters) {
		
		
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		mylog("****************************************************");
		mylog("***        DATABASE DEPLOY STARTED              ***");
		mylog("****************************************************");
		
		genLib.printParameters(parameters, logs);
		
		
		
		
		String build_path=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_DIRECTORY");
		String project_name=genLib.getParamByName(parameters, "MAD_REQUEST_PROJECT_NAME");
		
		String platform_id=genLib.getParamByName(parameters, "CURRENT_PLATFORM_ID");
		String platform_type_id=genLib.getParamByName(parameters, "CURRENT_PLATFORM_TYPE_ID");
		
		String member_path=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_PATH");
		String member_name=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_NAME");
		String member_version=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_VERSION");
		String build_tag_info=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_TAG_INFO");
		
		
		
		String db_type=genLib.getParamByName(parameters, "DATABASE_TYPE");
		
		
		ArrayList<String[]> dbtypes=new ArrayList<String[]>();
		dbtypes.add(new String[]{"dbvoracle","dbvoracle"});
		dbtypes.add(new String[]{"oracle","dbvoracle"});
		dbtypes.add(new String[]{"dbvmysql","dbvmysql"});
		dbtypes.add(new String[]{"mysql","dbvmysql"});
		dbtypes.add(new String[]{"dbvsybase","dbvsybase"});
		dbtypes.add(new String[]{"sybase","dbvsybase"});
		
		for (int i=0;i<dbtypes.size();i++) {
			
			if (db_type.trim().toLowerCase().equals(dbtypes.get(i)[0].trim().toLowerCase())) {
				db_type=dbtypes.get(i)[1];
				break;
			}
		}
		
		
		String DATABASE_FILE_TYPE=genLib.getParamByName(parameters, "DATABASE_FILE_TYPE");
		
		

		
		String file_to_deploy=build_path+File.separator+project_name+File.separator+member_name;
		System.out.println("Db Deploy File : "+file_to_deploy);
		
		fileUtilities f=new fileUtilities();
		
		mylog("parseDatabaseFile started.");
		ArrayList<String[]> cmds=f.parseDatabaseFile(parameters, file_to_deploy, db_type, DATABASE_FILE_TYPE);
		
		mylog(f.logs.toString());
		
		mylog("parseDatabaseFile finished.");
		
		StringBuilder db_logs=new StringBuilder();
		
		boolean is_success=true;
		
		
		
		
		if (cmds==null) {
			mylog("Sql is not parsed successfully.");
			is_success=false;
		} 
		else {
			
			
			String JDBC_DRIVER=genLib.getParamByName(parameters, "JDBC_DRIVER");
			String JDBC_URL=genLib.getParamByName(parameters, "JDBC_URL");
			String DB_USERNAME=genLib.getParamByName(parameters, "DB_USERNAME");
			String DB_PASSWORD=genLib.getParamByName(parameters, "DB_PASSWORD");
			
			String DATABASE_PRE_COMMANDS=genLib.getParamByName(parameters, "DATABASE_PRE_COMMANDS");
			String DATABASE_POST_COMMANDS=genLib.getParamByName(parameters, "DATABASE_POST_COMMANDS");
			String DATABASE_ONFAIL_ACTION=genLib.getParamByName(parameters, "DATABASE_ONFAIL_ACTION");
			
			String DATABASE_SCHEMA_NAME=genLib.getParamByName(parameters, "DATABASE_SCHEMA_NAME");
			
			
			String DATABASE_SKIP_STATEMENT_TYPES=genLib.getParamByName(parameters, "DATABASE_SKIP_STATEMENT_TYPES");
			

			commonLib cLib=new commonLib();
			
			mylog("Connecting to "+JDBC_URL+" with "+DB_USERNAME+"...");
			Connection conn=cLib.getDBConnection(JDBC_URL, JDBC_DRIVER, DB_USERNAME, DB_PASSWORD, 1);
			
			
			if (conn==null) {
				mylog("Database Connection failed : "+cLib.last_connection_error);
				is_success=false;
			}
			else {
				mylog("Database Connection established"); 
				try {conn.setAutoCommit(false);} catch (SQLException e1) {e1.printStackTrace();}
				
				ArrayList<String[]> bindlist=new ArrayList<String[]>();
				
				
				
				DATABASE_PRE_COMMANDS=genLib.replaceAllParams(DATABASE_PRE_COMMANDS, parameters);
				DATABASE_POST_COMMANDS=genLib.replaceAllParams(DATABASE_POST_COMMANDS, parameters);
				
				mylog("***\t DATABASE_PRE_COMMANDS:"+DATABASE_PRE_COMMANDS);
				mylog("***\t DATABASE_POST_COMMANDS:"+DATABASE_POST_COMMANDS);
				mylog("***\t DATABASE_ONFAIL_ACTION:"+DATABASE_ONFAIL_ACTION);
				
				
				runCommandsLines(cLib,conn,DATABASE_PRE_COMMANDS);
				
				for (int i=0;i<cmds.size();i++) {
					String statement_to_run=cmds.get(i)[0];
					String statement_type=cmds.get(i)[1];
					
					statement_to_run=RefineStmt(statement_to_run, statement_type, DATABASE_FILE_TYPE, db_type);

					if (DATABASE_SKIP_STATEMENT_TYPES.toLowerCase().contains(statement_type.toLowerCase())) {
						mylog("!Statement type ["+statement_type+"] to be skipped :");
						mylog(statement_to_run);
						continue;
					}
					
					
					
					mylog("Statement to execute ["+statement_type+"] :");
					mylog(statement_to_run);
					
					//boolean command_result=cLib.execSingleUpdateSQL(conn, statement_to_run, bindlist, false);
					boolean command_result=cLib.execAppScript(conn, statement_to_run);
					
					
					if (!command_result) {
						if (DATABASE_ONFAIL_ACTION.equals("rollback")) {
							mylog("Deployment failed. Stopping... ");
							try {conn.rollback();} catch (SQLException e) {e.printStackTrace();}
							is_success=false;
							break;
						}
						else { //skip next
							mylog("Deployment failed. Skipping to next command. ");
							is_success=false;
						}
						
							
						
					}
					
				} //for (int i=0;i<cmds.size();i++)
				
				
				runCommandsLines(cLib,conn,DATABASE_POST_COMMANDS);
				try {conn.commit();} catch (SQLException e) {e.printStackTrace();}
				
					
				mylog(cLib.logStr.toString());
				
				if (!is_success) {
					mylog(cLib.errStr.toString());
				}
				
				try {conn.close();} catch(Exception e){}
			}
				
		} // else of if (cmds==null)
		
		
		
		
		mylog("Db Deployment Result : "+is_success);
		
		
		mylog(db_logs.toString());
		
		if (!is_success) {
			mylog("DB Build : FAILED");
			ret1.add(new String[]{"false",logs.toString()});
			return ret1;
		}
			
		mylog("DB Build : SUCCESSFULL");
		ret1.add(new String[]{"true",logs.toString()});
		return ret1;
		
		
		
	}
	
	//---------------------------------------------------------------------------
	public String RefineStmt(String in_stmt, String cmd_type, String file_type, String db_type) {
		

		
		
		try {
			
			if (db_type.toUpperCase().trim().equals("DBVORACLE"))  {
				
				//plsql ve procedure, trgger lerde sonundaki ; i kaldirma
				
				if (cmd_type.toLowerCase().startsWith("sstplsql_create") || cmd_type.toLowerCase().startsWith("sst_block")) {
					mylog("comma is not deleted since its type is "+cmd_type);
					return in_stmt;
				}
					
				
				
				//clear comma's at the end of DDL's
				if (file_type.toUpperCase().trim().equals("DDL")) {
					

					String tmp1=in_stmt.replace("\n|\r| ", "").trim();
					int last_comma_ind=tmp1.lastIndexOf(";");
					if (last_comma_ind==tmp1.length()-1) {
						last_comma_ind=in_stmt.lastIndexOf(";");
						return in_stmt.substring(0,last_comma_ind);
					}
					
				}
			} //if (db_type.toLowerCase().trim().equals("ORACLE"))
			
		} catch(Exception e) {
			mylog("Exception@RefineStmt ERR    : "+e.getMessage());
			mylog("Exception@RefineStmt INSTMT : "+in_stmt);
			mylog("Exception@RefineStmt CMDTYP : "+cmd_type);
			mylog("Exception@RefineStmt FLTYPE : "+file_type);
			mylog("Exception@RefineStmt DBTYPE : "+db_type);
			
			return in_stmt;
		}
		
		
		
		return in_stmt;
	}
	
	//---------------------------------------------------------------------------
	void runCommandsLines(commonLib c, Connection conn,String cmd) {
		String[] arr=cmd.split("\n|\r");
		for (int i=0;i<arr.length;i++) {
			if (arr[i].trim().length()==0) continue;
			c.execAppScript(conn, arr[i]);
			//c.execSingleUpdateSQL(conn, arr[i], new ArrayList<String[]>(), false);
		}
	}
	
	
	
	
}
