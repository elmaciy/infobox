package com.mayatech.tdm;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.mayatech.baseLibs.genLib;

public class metadataCopyLib {

	String jdbc_driver="";
	String jdbc_url="";
	String jdbc_username="";
	String jdbc_password="";
	
	
	String jdbc_target_driver="";
	String jdbc_target_url="";
	String jdbc_target_username="";
	String jdbc_target_password="";
	
	String source_schemas="";
	String target_schemas="";
	
	String object_type_filter="ALL";
	String object_name_filter="";
	
	ArrayList<String> sourceSchemas=new ArrayList<String>();
	ArrayList<String> targetSchemas=new ArrayList<String>();
	
	
	
	public static final int LOG_LEVEL_DEBUG=5;
	public static final int LOG_LEVEL_INFO=4;
	public static final int LOG_LEVEL_WARNING=3;
	public static final int LOG_LEVEL_ERROR=2;
	public static final int LOG_LEVEL_FATAL=1;
	
	static final int MAX_LOG_LENGTH=20*1024*1024;
	
	Logger logger=LogManager.getLogger(this.getClass());
	
	private StringBuilder log_info = new StringBuilder();
	private StringBuilder err_info = new StringBuilder();
	
	Connection connSource=null;
	Connection connTarget=null;
	
	
	
	static final int FIELD_SEQ_OWNER=0;
	static final int FIELD_SEQ_NAME=1;
	static final int FIELD_SEQ_LAST_NUMBER=2;
	static final int FIELD_SEQ_INCREMENT_BY=3;
	
	boolean skip_users=false;
	boolean skip_roles=false;
	
	String extract_path="d:\\temp\\extract";
	
	//----------------------------------------------------------------
	public metadataCopyLib(
			String jdbc_driver,
			String jdbc_url,
			String jdbc_username,
			String jdbc_password,
			String jdbc_target_driver,
			String jdbc_target_url,
			String jdbc_target_username,
			String jdbc_target_password
			) {
		
		this.jdbc_driver=jdbc_driver;
		this.jdbc_url=jdbc_url;
		this.jdbc_username=jdbc_username;
		this.jdbc_password=jdbc_password;
		
		this.jdbc_target_driver=jdbc_target_driver;
		this.jdbc_target_url=jdbc_target_url;
		this.jdbc_target_username=jdbc_target_username;
		this.jdbc_target_password=jdbc_target_password;
		
		
		connSource=getconn(jdbc_url, jdbc_driver, jdbc_username, jdbc_password);
		connTarget=getconn(jdbc_target_url, jdbc_target_driver, jdbc_target_username, jdbc_target_password);
		
		if (connSource==null) {
			mylog(LOG_LEVEL_FATAL, "Source connection is not established");
			return;
		}
		
		if (connTarget==null) {
			mylog(LOG_LEVEL_FATAL, "Target connection is not established");
			return;
		}
		
		
	}
	
	//----------------------------------------------------------------
	public void setSchemas(String source_schemas, String target_schemas) {
		this.source_schemas=source_schemas;
		this.target_schemas=target_schemas;
		
		
		if (source_schemas.length()==0) {
			mylog(LOG_LEVEL_WARNING,"Source and target schema list filling...");
			String sql="SELECT username FROM dba_users u WHERE EXISTS (SELECT 1 FROM dba_objects o WHERE o.owner = u.username) ";
			ArrayList<String[]> arr=getDbArray(connSource, sql, Integer.MAX_VALUE, null, 0);
			for (int i=0;i<arr.size();i++) {
				mylog(LOG_LEVEL_INFO,"\tAdding : "+arr.get(i)[0]);
				
				if (i>0) this.source_schemas=this.source_schemas+",";
				this.source_schemas=this.source_schemas+arr.get(i)[0];
				
				if (i>0) this.target_schemas=this.target_schemas+",";
				this.target_schemas=this.target_schemas+arr.get(i)[0];
			}
		}
		
		

		sourceSchemas.clear();
		targetSchemas.clear();
		
		String[] arrSrc=this.source_schemas.split(",");
		String[] arrTar=this.target_schemas.split(",");
		
		if (arrSrc.length!=arrTar.length) {
			mylog(LOG_LEVEL_FATAL, "Source and target schema count is not equal");
			return;
		}
		
		
		
		
		
		
		for (int i=0;i<arrSrc.length;i++) {
			String schema_src=arrSrc[i].trim();
			String schema_tar=arrTar[i].trim();
			
			if (schema_src.length()>0 && schema_tar.length()>0 ) {
				sourceSchemas.add(schema_src);
				targetSchemas.add(schema_tar);
			}
		}
		
		
		

	}
	//----------------------------------------------------------------
	public void setFilter(String object_type_filter, String object_name_filter) {
		this.object_type_filter=object_type_filter;
		
		
		this.object_name_filter=object_name_filter;

	}
	
	
	// ***************************************
	public void mylog(int level, String plog) {

		if (plog.indexOf("xception")>-1) {
			System.out.println(plog);
			myerr(plog);
		}

		System.out.println(plog);
		

		if (level!=LOG_LEVEL_DEBUG)
			log_info.append(" "+(new Date().toString()) +" "+plog + "\r");
		
		if (log_info.length()>MAX_LOG_LENGTH) log_info.delete(0, MAX_LOG_LENGTH/4);
		
		if (logger==null) {
			System.out.println(" "+plog);
			return;
		}
		
		
		
		switch(level) {
			case LOG_LEVEL_DEBUG : {logger.debug(" "+(new Date().toString()) +" "+ plog); break;}
			case LOG_LEVEL_INFO : {logger.info(" "+(new Date().toString()) +" "+ plog); break;}
			case LOG_LEVEL_WARNING : {logger.warn(" "+(new Date().toString()) +" "+ plog); break;}
			case LOG_LEVEL_ERROR : {logger.error(" "+(new Date().toString()) +" "+ plog); break;}
			case LOG_LEVEL_FATAL : {logger.fatal(" "+(new Date().toString()) +" "+ plog); break;}
			default : logger.debug(" "+(new Date().toString()) +" "+ plog);
		}
		
		//logger.error(java_pid+" "+plog);
		
	}
	// ***************************************
	public void sleep(long milis) {
		try {
			Thread.sleep(milis);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	// ***************************************
	public void myerr(String plog) {
		
		System.out.println("> "+plog);
		err_info.append(" "+plog + "\r");
		
		if (err_info.length()>MAX_LOG_LENGTH) err_info.delete(0, MAX_LOG_LENGTH/4);
		
		if (logger==null) {
			System.out.println(" "+plog);
			return;
		}
		
		logger.error(" "+plog);
	}
	
	//---------------------------------------------------------------------
	public Connection getconn(String ConnStr, String Driver, String User,
			String Pass) {
		return getconn(ConnStr, Driver, User, Pass, 3);
	}
	
	//---------------------------------------------------------------------
	public Connection getconn(String ConnStr, String Driver, String User,String Pass, int retry_count) {
		Connection ret1 = null;
		mylog(LOG_LEVEL_INFO, "Connecting to : ");
		mylog(LOG_LEVEL_INFO, "driver     :"+Driver);
		mylog(LOG_LEVEL_INFO, "connstr    :"+ConnStr);
		mylog(LOG_LEVEL_INFO, "user       :"+User);
		mylog(LOG_LEVEL_INFO, "pass       :"+"************");	
		


	

		int retry=0;
		while (true) {
			if (retry>retry_count) break;
			retry++;
			try {
				Class.forName(Driver.replace("*",""));
				Connection conn = DriverManager.getConnection(ConnStr, User, Pass);
				Statement stmt = conn.createStatement();
				
				
				
				
				
				
				ResultSet rset = stmt.executeQuery("select 1 from dual");
				while (rset.next()) {
					rset.getString(1);
					mylog(LOG_LEVEL_INFO, "Connected to DB : " + User + "@" + ConnStr);
					
					

				}
	
				ret1 = conn;
					
				break;
	
			} catch (Exception ignore) {
				myerr("Exception@getconn : " + ignore.getMessage());
				ignore.printStackTrace();
				ret1=null;
				mylog(LOG_LEVEL_INFO, "sleeping ...");
				sleep(5000);
			}
			
			mylog(LOG_LEVEL_ERROR, "Connection is failed to db : retry("+retry+") ");
			mylog(LOG_LEVEL_ERROR, "driver     :"+Driver);
			mylog(LOG_LEVEL_ERROR, "connstr    :"+ConnStr);
			mylog(LOG_LEVEL_ERROR, "user       :"+User);
			mylog(LOG_LEVEL_ERROR, "pass       :"+"************");
			mylog(LOG_LEVEL_ERROR, "Sleeping...");
			
			


			
			
		}
		
		return ret1;
	}
	
	//--------------------------------------------------------------------------------------
	ArrayList<String[]> getDbArray(
			Connection conn, 
			String sql, 
			int limit,
			ArrayList<String[]> bindlist, 
			int timeout_insecond) {
		
		//if (bindlist!=null && bindlist.size()==1)
		//	mylog("xxxxxxxxxxxxxxxxxxx "+sql  + " binding "+bindlist.get(0)[1]);
		ArrayList<String[]> ret1 = new ArrayList<String[]>();

		PreparedStatement pstmtConf = null;
		ResultSet rsetConf = null;
		ResultSetMetaData rsmdConf = null;

		
		int reccnt = 0;
		try {
			if (pstmtConf == null) 	pstmtConf = conn.prepareStatement(sql);
			
			//------------------------------ end binding

			if (bindlist!=null) {
				for (int i = 1; i <= bindlist.size(); i++) {
					String[] a_bind = bindlist.get(i - 1);
					String bind_type = a_bind[0];
					String bind_val = a_bind[1];
					
	
					if (bind_type.equals("INTEGER")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtConf.setInt(i, Integer.parseInt(bind_val));
					} else if (bind_type.equals("LONG")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtConf.setLong(i, Long.parseLong(bind_val));
					} else if (bind_type.equals("DOUBLE")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.DOUBLE);
						else
							pstmtConf.setDouble(i, Double.parseDouble(bind_val));
					} else if (bind_type.equals("FLOAT")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.FLOAT);
						else
							pstmtConf.setFloat(i, Float.parseFloat(bind_val));
					} 
					else {
						pstmtConf.setString(i, bind_val);
					}
				}
				//------------------------------ end binding
			}  // if bindlist 
			
			if (timeout_insecond>0)
				pstmtConf.setQueryTimeout(timeout_insecond);
			
			if (rsetConf == null) rsetConf = pstmtConf.executeQuery();
			if (rsmdConf == null) rsmdConf = rsetConf.getMetaData();

			int colcount = rsmdConf.getColumnCount();
			
			
			
			String a_field = "";
			while (rsetConf.next()) {
				reccnt++;
				if (reccnt > limit) break;
				String[] row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {
					try {
						a_field = rsetConf.getString(i);
						
						if (a_field.equals("null")) a_field=""; 
						if (a_field.length()>8000) a_field=a_field.substring(0,8000);
						} 
					catch (Exception enull) {a_field = "";}
					row[i - 1] = a_field;
				}
				ret1.add(row);
			}
		} catch(SQLException sqle) {
			sqle.printStackTrace();
			mylog(LOG_LEVEL_ERROR, "Exception@getDbArray : SQL       => " + sql);
			mylog(LOG_LEVEL_ERROR, "Exception@getDbArray : MSG       => " + sqle.getMessage());
			mylog(LOG_LEVEL_ERROR, "Exception@getDbArray : CODE      => " + sqle.getErrorCode());
			mylog(LOG_LEVEL_ERROR, "Exception@getDbArray : SQL STATE => " + sqle.getSQLState());
		}
		catch (Exception ignore) {
			ignore.printStackTrace();
			mylog(LOG_LEVEL_ERROR, "Exception@getDbArray : SQL => " + sql);
			mylog(LOG_LEVEL_ERROR, "Exception@getDbArray : MSG => " + ignore.getMessage());
		} finally {
			try {rsmdConf = null;} catch (Exception e) {}
			try {rsetConf.close();rsetConf = null;} catch (Exception e) {}
			try {pstmtConf.close();	pstmtConf = null;} catch (Exception e) {}
		}
		return ret1;
	}
	// ***************************************
	public boolean execDBCommand(Connection conn, String sql,ArrayList<String[]> bindlist) {

		boolean ret1 = true;
		
		PreparedStatement pstmt_execbind = null;

		StringBuilder using = new StringBuilder();
		try {
			pstmt_execbind = conn.prepareStatement(sql);

			if (bindlist!=null)
			for (int i = 1; i <= bindlist.size(); i++) {
				String[] a_bind = bindlist.get(i - 1);
				String bind_type = a_bind[0];
				String bind_val = a_bind[1];
				if (i > 1)
					using.append(", ");
				using.append("{" + bind_val + "}");

				if (bind_type.equals("INTEGER")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.INTEGER);
					else
						pstmt_execbind.setInt(i, Integer.parseInt(bind_val));
				} else if (bind_type.equals("LONG")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.INTEGER);
					else
						pstmt_execbind.setLong(i, Long.parseLong(bind_val));
				} else if (bind_type.equals("DATE")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.DATE);
					else {
						Date d = new SimpleDateFormat(genLib.DEFAULT_DATE_FORMAT)
								.parse(bind_val);
						java.sql.Date date = new java.sql.Date(d.getTime());
						pstmt_execbind.setDate(i, date);
					}
				} 
				else if (bind_type.equals("TIMESTAMP")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.TIMESTAMP);
					else {
						Timestamp ts=new Timestamp(System.currentTimeMillis());
						try {ts=new Timestamp(Long.parseLong(bind_val));} catch(Exception e) {e.printStackTrace();}
						pstmt_execbind.setTimestamp(i, ts);
					}
				}
				else {
					pstmt_execbind.setString(i, bind_val);
				}
			}

			mylog(LOG_LEVEL_DEBUG, "Executing SQL : " + sql + " using " + using.toString());

			pstmt_execbind.executeUpdate();

			mylog(LOG_LEVEL_DEBUG, "DONE : " + sql + " using " + using.toString());
			
			if (!conn.getAutoCommit()) 	conn.commit();


		} catch (Exception e) {
			mylog(LOG_LEVEL_ERROR,"Exception@execDBBindingConf : " + e.getMessage());
			myerr("while " + "Executing SQL : " + sql + " using " + using.toString());

			
				
			
			e.printStackTrace();
			ret1 = false;
		} finally {
			try {
				pstmt_execbind.close();
			} catch (Exception e) {
			}
		}

		return ret1;
	}
	
	//----------------------------------------------------------------
	
	
	
	
	void extractDDLFromDB() {
				//ROLES	Object
				//USERS	  Object
				//SYSTEM GRANTS	Property
				//TYPES	  Object
				//TYPE BODIES	  Object
				//TABLES	  Object
				//PARTITIONS
				//SEQUENCES	  Object
				//MAT VIEWS	  Object
				//VIEWS	  Object
				//PROCEDURES	  Object
				//FUNCTIONS	  Object
				//PACKAGES	  Object
				//PACKAGE BODIES	  Object
				//TRIGGERS	  Object
				//SYNONYMS
				//INDEXES
				//CONSTRAINTS PK
				//CONTSTRAINTS FK
				//CONSRAINTS CHECK
				//OBJECT GRANTS
		
		
		
		
		
		extractROLES();
		
		extractUSERS();
		
		extractOtherObjects();
		
		createDDLScripts();
		
		
	}
	
	//-------------------------------------------------------------------------------
	
	ArrayList<String[]> objArr=new  ArrayList<String[]>();
	
	ArrayList<String[]> rolesArr=new ArrayList<String[]>();
	ArrayList<String[]> usersArr=new ArrayList<String[]>();
	
	
	//-------------------------------------------------------------------------------
	void extractROLES() {
		
		if (skip_roles) {
			mylog(LOG_LEVEL_INFO,"skipping roles");
			return;
		}
		
		mylog(LOG_LEVEL_INFO,"Extracting roles");
		
		String sql="select 'ROLE' object_type,'SYS' schema_name, role from dba_roles where " +
				 " role not in ('SYS','DBA','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','DELETE_CATALOG_ROLE', "+
					"'EXP_FULL_DATABASE','IMP_FULL_DATABASE','LOGSTDBY_ADMINISTRATOR','DBFS_ROLE', "+
					"'CONNECT','RESOURCE','DBFS_ROLE','AQ_ADMINISTRATOR_ROLE',"+
					"'AQ_USER_ROLE','DATAPUMP_EXP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE','ADM_PARALLEL_EXECUTE_TASK',"+
					"'GATHER_SYSTEM_STATISTICS','JAVA_DEPLOY','RECOVERY_CATALOG_OWNER','SCHEDULER_ADMIN',"+
					"'HS_ADMIN_SELECT_ROLE','HS_ADMIN_EXECUTE_ROLE','HS_ADMIN_ROLE','GLOBAL_AQ_USER_ROLE',"+
					"'OEM_ADVISOR','OEM_MONITOR','WM_ADMIN_ROLE','JAVAUSERPRIV',"+
					"'JAVAIDPRIV','JAVASYSPRIV','JAVADEBUGPRIV','EJBCLIENT',"+
					"'JMXSERVER','JAVA_ADMIN','CTXAPP','XDBADMIN',"+
					"'XDB_SET_INVOKER','AUTHENTICATEDUSER','XDB_WEBSERVICES','XDB_WEBSERVICES_WITH_PUBLIC',"+
					"'XDB_WEBSERVICES_OVER_HTTP','ORDADMIN','OLAPI_TRACE_USER','OLAP_XS_ADMIN',"+
					"'OWB_USER','OLAP_DBA','CWM_USER','OLAP_USER',"+
					"'SPATIAL_WFS_ADMIN','WFS_USR_ROLE','SPATIAL_CSW_ADMIN','CSW_USR_ROLE',"+
					"'MGMT_USER','APEX_ADMINISTRATOR_ROLE','OWB$CLIENT','OWB_DESIGNCENTER_VIEW'"+
				")";
		rolesArr=getDbArray(connSource, sql, Integer.MAX_VALUE, null, 0);
		
		for (int i=0;i<rolesArr.size();i++) {
			String obj_type=rolesArr.get(i)[0];
			String obj_owner=rolesArr.get(i)[1];
			String obj_name=rolesArr.get(i)[2];
			
			mylog(LOG_LEVEL_INFO,"Adding "+obj_type+": "+obj_owner+"."+obj_name);
			
			objArr.add(new String[]{obj_type,	obj_owner,	obj_name});
		}
		
	}
	
	
	
	//-------------------------------------------------------------------------------
	void extractUSERS() {
		
		if (skip_users) {
			mylog(LOG_LEVEL_INFO,"skipping users");
			return;
		}
		
		mylog(LOG_LEVEL_INFO,"Extracting users");
		
		String sql="select 'USER' object_type,'SYS' schema_name, username from dba_users where " +
				 " default_tablespace not in ('SYSTEM','SYSAUX')  ";
		usersArr=getDbArray(connSource, sql, Integer.MAX_VALUE, null, 0);
		
		for (int i=0;i<usersArr.size();i++) {
			String obj_type=usersArr.get(i)[0];
			String obj_owner=usersArr.get(i)[1];
			String obj_name=usersArr.get(i)[2];
			
			mylog(LOG_LEVEL_INFO,"Adding "+obj_type+": "+obj_owner+"."+obj_name);
			
			objArr.add(new String[]{obj_type,	obj_owner,	obj_name});
		}
		
	}
	
	//-------------------------------------------------------------------------------
	void extractOtherObjects() {
		
		
		
		mylog(LOG_LEVEL_INFO,"Extracting objects");
		
		String sql="select object_type, owner, object_name from dba_objects "+
				" where "+
				" owner not in ('SYS','SYSTEM') "+
				//paket ve type body lerin source leri direk kendinden aliniyor
				" and object_type not in('TABLE PARTITION','LOB','LOB PARTITION','TYPE BODY','PACKAGE BODY') "+
				" and owner in('-'";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		for (int i=0;i<sourceSchemas.size();i++) {
			sql=sql+",?";
			bindlist.add(new String[]{"STRING",sourceSchemas.get(i)});
		}
		sql=sql+")";
		
		int last_id=objArr.size()-1;
		
		objArr.addAll(getDbArray(connSource, sql, Integer.MAX_VALUE, bindlist, 0));
		
		for (int i=last_id;i<objArr.size();i++) {
			String obj_type=objArr.get(i)[0];
			String obj_owner=objArr.get(i)[1];
			String obj_name=objArr.get(i)[2];
			
			mylog(LOG_LEVEL_INFO,"Adding "+obj_type+": "+obj_owner+"."+obj_name);
			
		}
		
	}
	
	//----------------------------------------------------------------
	void createDDLScripts() {
		mylog(LOG_LEVEL_INFO,"Creating DDL for");
		
		String sql="select dbms_metadata.get_ddl(?,?,?) from dual";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		StringBuilder sourceCode=new StringBuilder();
		
		
		
		for (int i=0;i<objArr.size();i++) {
			String obj_type=objArr.get(i)[0];
			String obj_owner=objArr.get(i)[1];
			String obj_name=objArr.get(i)[2];
			
			if (obj_type.equals("ROLE")) {
				continue;
			}
			else if (obj_type.equals("USER")) {
				continue;
			}
			
			
			
			mylog(LOG_LEVEL_INFO,"Creating script for  "+obj_type+": "+obj_owner+"."+obj_name);
			
			bindlist.clear();
			bindlist.add(new String[]{"STRING",obj_type});
			bindlist.add(new String[]{"STRING",obj_name});
			bindlist.add(new String[]{"STRING",obj_owner});
			
			sourceCode.setLength(0);
			
			try {
				sourceCode.append(getDbArray(connSource, sql, 1, bindlist, 0).get(0)[0]);
			} 
			catch(Exception e) {
				mylog(LOG_LEVEL_ERROR, "DDL is unsuccessfull. ");
				continue;
			}
			
			text2file(sourceCode.toString(), extract_path+"\\"+obj_type+"."+obj_owner+"."+obj_name+".sql");
			
			
		}
	}
	
	
	// *****************************************
	void text2file(String text, String filepath) {
			BufferedWriter out = null;
			
			File f=new File(filepath);
			if (f.exists()) f.delete();
		
		try {
			out=new BufferedWriter(new OutputStreamWriter(new FileOutputStream(filepath),"UTF-8"));
			out.append(text);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {out.close();} catch(Exception e) {}
		}
	}
	
	//----------------------------------------------------------------
	void checkAndCreateUsersOnTarget() {
		
	}
	
	//----------------------------------------------------------------
	void clearStorageInfo() {
		
	}
	
	//----------------------------------------------------------------
	void checkDependencies() {
		
	}
	
	
	
	//-----------------------------------------------------------------
	public void copyMetadata() {
		
		connSource=getconn(jdbc_url, jdbc_driver, jdbc_username, jdbc_password);
		connTarget=getconn(jdbc_target_url, jdbc_target_driver, jdbc_target_username, jdbc_target_password);
		
		if (connSource==null) {
			mylog(LOG_LEVEL_FATAL, "Source connection is not established");
			return;
		}
		
		if (connTarget==null) {
			mylog(LOG_LEVEL_FATAL, "Target connection is not established");
			return;
		}
		
		
		extractDDLFromDB();
		
		clearStorageInfo();
		
		checkDependencies();
		
		checkAndCreateUsersOnTarget();
		
		
		try{connSource.close();} catch(Exception e) {}
		try{connTarget.close();} catch(Exception e) {}
		
		mylog(LOG_LEVEL_FATAL, "Metadata copy terminated.");
		
	}
	
	
	
	
	
	
	
	
	//---------------------------------------------------------------------------
	
	
	
	
	ArrayList<String[]> getSequences(Connection conn, ArrayList<String> schemas) {
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		String sql="";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		
		
		
		if (schemas.size()==0) {
			sql="select sequence_owner,sequence_name,last_number, increment_by from dba_sequences";
			mylog(LOG_LEVEL_INFO, "\tGetting sequences for all schemas");
		} else {
			sql="select sequence_owner,sequence_name,last_number, increment_by from dba_sequences where sequence_owner in(''";
			for (int i=0;i<schemas.size();i++) {
				String owner=schemas.get(i);
				sql=sql+",?";
				bindlist.add(new String[]{"STRING",owner});
				
				mylog(LOG_LEVEL_INFO, "\tGetting sequences for "+owner);
			}
			sql=sql+")";
		}
		
		ret1=getDbArray(conn,sql,Integer.MAX_VALUE,bindlist,0);
		
		mylog(LOG_LEVEL_INFO, "Sequence count found : "+ret1.size());
		
		return ret1;
	}
	
	//-----------------------------------------------------------------
	public void synchSequences() {
		
		
		mylog(LOG_LEVEL_INFO, "Getting sequences for source DB");
		ArrayList<String[]> seqListSource=getSequences(connSource,sourceSchemas);
		
		mylog(LOG_LEVEL_INFO, "Getting sequences for source DB");
		ArrayList<String[]> seqListTarget=getSequences(connSource,targetSchemas);
		
		syncySequenceDo(seqListSource,seqListTarget);
		
		
		try{connSource.close();} catch(Exception e) {}
		try{connTarget.close();} catch(Exception e) {}
		
		mylog(LOG_LEVEL_FATAL, "Metadata copy terminated.");
		
	}
	
	//---------------------------------------------------------------------------------------------
	String getTargetOwner(String source_owner) {
		String ret1="";
		for (int i=0;i<sourceSchemas.size();i++) {
			//System.out.println("Checking... "+sourceSchemas.get(i).trim()+" to "+source_owner);
			if (sourceSchemas.get(i).trim().equals(source_owner)) {
				return targetSchemas.get(i).trim();
			}
		}
		return ret1;
	}
	//---------------------------------------------------------------------------------------------
	int getTargetSequenceId(String source_owner,String source_seq_name,ArrayList<String[]> seqListTarget) {
		int ret1=-1;
		
		String target_owner=getTargetOwner(source_owner);
		
		if (target_owner.length()==0) {
			return ret1;
		}
		
		for (int i=0;i<seqListTarget.size();i++) {
			//System.out.println("Checking... "+target_owner+"."+source_seq_name+" to "+seqListTarget.get(i)[FIELD_SEQ_OWNER]+"."+seqListTarget.get(i)[FIELD_SEQ_NAME]);
			if (target_owner.equals(seqListTarget.get(i)[FIELD_SEQ_OWNER]) && source_seq_name.equals(seqListTarget.get(i)[FIELD_SEQ_NAME])) {
				return i;
			}
		}
		
		return ret1;
	}
	//---------------------------------------------------------------------------------------------
	void syncySequenceDo(ArrayList<String[]> seqListSource,ArrayList<String[]> seqListTarget) {
		for (int i=0;i<seqListSource.size();i++) {
			String source_owner=seqListSource.get(i)[FIELD_SEQ_OWNER];
			String source_seq_name=seqListSource.get(i)[FIELD_SEQ_NAME];
			//String source_increment_by=seqListSource.get(i)[FIELD_SEQ_INCREMENT_BY];
			String source_last_number=seqListSource.get(i)[FIELD_SEQ_LAST_NUMBER];
			
			
			int target_seq_id=getTargetSequenceId(source_owner,source_seq_name,seqListTarget);
			
			if (target_seq_id==-1) {
				mylog(LOG_LEVEL_WARNING, source_owner+"."+source_seq_name+" is not found on target database. Skipping...");
				continue;
			}
			
			mylog(LOG_LEVEL_INFO, source_owner+"."+source_seq_name+" is found");
			
			String target_owner=seqListSource.get(target_seq_id)[FIELD_SEQ_OWNER];
			String target_seq_name=seqListSource.get(target_seq_id)[FIELD_SEQ_NAME];
			String target_increment_by=seqListSource.get(target_seq_id)[FIELD_SEQ_INCREMENT_BY];
			String target_last_number=seqListSource.get(target_seq_id)[FIELD_SEQ_LAST_NUMBER];
			
			long source_last_number_LONG=0;
			long target_last_number_LONG=0;
			
			try{source_last_number_LONG=Long.parseLong(source_last_number);} catch(Exception e) {continue;}
			try{target_last_number_LONG=Long.parseLong(target_last_number);} catch(Exception e) {continue;}
			
			source_last_number_LONG++;
			
			if (target_last_number_LONG>=source_last_number_LONG) {
				mylog(LOG_LEVEL_WARNING, source_owner+"."+source_seq_name+" is already synchronised . Skipping");
				continue;
			}
			
			long diff=source_last_number_LONG-target_last_number_LONG;
			
			//synchronising
			
			String sql="ALTER SEQUENCE \""+target_owner+"\".\""+target_seq_name+"\" INCREMENT BY "+diff;
			execDBCommand(connTarget, sql, null);
			
			sql="SELECT \""+target_owner+"\".\""+target_seq_name+"\".NEXTVAL FROM dual";
			getDbArray(connTarget, sql, 1, null, 0);
			
			sql="ALTER SEQUENCE \""+target_owner+"\".\""+target_seq_name+"\" INCREMENT BY "+target_increment_by;
			execDBCommand(connTarget, sql, null);
			
			
		}
	}
	
}
