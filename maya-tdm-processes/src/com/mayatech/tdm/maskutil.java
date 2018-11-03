package com.mayatech.tdm;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.util.ArrayList;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import com.mayatech.baseLibs.genLib;
import com.mayatech.datamodel.dmModelForDM;
import com.sun.mail.util.BASE64EncoderStream;

public class maskutil {
	
	boolean login_ok=false;
	
	
	//*************************************************************
		public String encrypt(String input) {
		//*************************************************************
		String ret1=input;
		Cipher ecipher;
	    SecretKey key;
		try {
			String theKey = "01234567";
	        key = KeyGenerator.getInstance("DES").generateKey();
	        key=new SecretKeySpec(theKey.getBytes("UTF-8"), "DES");
	        ecipher = Cipher.getInstance("DES");
	        ecipher.init(Cipher.ENCRYPT_MODE, key);
	        
	        byte[] utf8 = input.getBytes("UTF8");
	        byte[] enc = ecipher.doFinal(utf8);
	        enc = BASE64EncoderStream.encode(enc);

	        //convert to hex
	        StringBuilder sb = new StringBuilder();
	        for(int i=0; i< enc.length ;i++)
	            sb.append(Integer.toString((enc[i] & 0xff) + 0x100, 16).substring(1));

	        ret1 = sb.toString();
		} catch (Exception e) {
			e.printStackTrace();
		}

		return ret1;
		}
		
	String getInput() {
		try {
			return System.console().readLine();
		} catch(Exception e) {
			System.out.println("Exception@xxxx");
			e.printStackTrace();
		}
		
		return null;
	}
	
	
	//********************************************
	String getPassword() {
		try {
			return new String(System.console().readPassword() );
		} catch(Exception e) {
			System.out.println("Exception@xxxx");
			e.printStackTrace();
		}
		
		return null;
	}
	
	//****************************************

	String printMenu() {
		
		String cmd_option=getParamFromArgs("CMD");
		
		if (cmd_option.trim().length()>0) {
			int s=0;
			try {
				s=Integer.parseInt(cmd_option);
			} catch(Exception e) {}
			
			if (s>0) return cmd_option;
		}
		
		System.out.println("********************************************");
		System.out.println("--------------------------------------------");
		
		System.out.println(" 1) Drop Unused Task Tables                 ");
		System.out.println(" 2) Synchronize Database Structure          ");
		System.out.println(" 3) Import Big List File                    ");
		System.out.println(" 4) Create KeyVal List File                 ");
		System.out.println(" 5) Bulk Masking Table Configuration        ");
		System.out.println(" 7) Retry failed tasks                      ");
		System.out.println(" 8) Empty Finished Tasks                    ");
		System.out.println(" 9) [Q]uit                                  ");
		System.out.println("--------------------------------------------");
		System.out.println("********************************************");
		System.out.print("Your Choice : ");
		
		return getInput();
	}
	
	//****************************************
	String last_selection_name="";
	
	
	int getSelectionFromList(ConfDBOper d, String sql, String title) {
		
		String cmd_selection=getParamFromArgs("SELECTION");
		
		if (cmd_selection.trim().length()>0) {
			int s=0;
			try{
				s=Integer.parseInt(cmd_selection);
				return s;
			}  catch(Exception e) {}
		}
		
		ArrayList<String> selection=new ArrayList<String>();
		ArrayList<String[]> list=d.getDbArrayConf(sql, Integer.MAX_VALUE);
		
		while (true) {
			
			
			System.out.println("----------------------------------");
			System.out.println("  "+title+"                ");
			System.out.println("----------------------------------");
			
			selection.clear();
			for (int i=0;i<list.size();i++) {
				String id=list.get(i)[0];
				String name=list.get(i)[1];
				
				selection.add(id);
				
				System.out.println("\t["+id + "]\t" + name);
				
			}
			System.out.println("\n\t[m]\t Return to menu");
			System.out.println("----------------------------------");
			
			System.out.print(title);
			System.out.print("Your Choice : ");
			String input = getInput();
			
			if (input.toLowerCase().equals("m")) return -1;
			
			if (selection.contains(input)) {
				last_selection_name=list.get(selection.indexOf(input))[1];
				return Integer.parseInt(input);
			}
				
			
			System.out.println("\n\n!!!! Invalid Selection !!!! \n\n");
		}
	}
	
	//*****************************************************************

	void splitKeyValFile(String filepath, int split_count) {
		
		System.out.println("Splitting " + filepath + " "+ split_count + " part...");
		
		InputStream fis=null;
		BufferedReader br=null;
		StringBuilder sb=new StringBuilder();
		int i=0;
		final int MAX_BUFFER_LEN=10000;
		String[][] arr=new String[split_count][MAX_BUFFER_LEN];
		
		
		int[] len_i=new int[split_count];
		File[] files=new File[split_count];
		
		for (i=0;i<arr.length;i++) {
			len_i[i]=0;
			try {
				files[i]=new File(filepath+"_"+i);
				files[i].delete();
				files[i].createNewFile();
			} catch(Exception e) {
				
			}
			
			
			
		}
		
		
		int x=0;
		
		try {
			
			 fis=new FileInputStream(filepath);
			 br=new BufferedReader(new InputStreamReader(fis));
			 
			while (true) {
				try {
					sb.setLength(0);
					sb.append(br.readLine());
					if (sb.length()==0 || sb.toString().equals("null")) break;
				} catch(Exception e) {
					break;
				}
				
				
								
				i++;
				try {
					x=Math.abs(sb.toString().split(";")[0].hashCode() % split_count);
				} catch(Exception e) {
					x=0;
				}
				
				if (i%100000==0)  {
					System.out.println("Chunk ok for : " + i );
				}
				
				arr[x][len_i[x]]=sb.toString();
				len_i[x]++;
				if (len_i[x]>=MAX_BUFFER_LEN)
				{
					//System.out.println("appending to chunk " + x);
					
					
					FileWriter fileWritter = new FileWriter(filepath+"_"+x,true);
	    	        BufferedWriter bufferWritter = new BufferedWriter(fileWritter);
	    	        
	    	        for (int d=0;d<len_i[x];d++) {
	    	        	//System.out.println("data : " + arr[x][d]+" to "+ x);
	    	        	bufferWritter.write(arr[x][d]);
	    	        	bufferWritter.newLine();
	    	        }
	    	        bufferWritter.flush();
	    	        bufferWritter.close();
	    	        
					len_i[x]=0;
				}
				
				
			}
		} catch(Exception e) {
			e.printStackTrace();
			
			System.out.println("\n\n\n!!!! ************************************************************.." );
			System.out.println("!!!! Problem in splitKeyValFile list. " );
			System.out.println("!!!! ************************************************************..\n\n\n" );			
		} finally {
			try {
				 br.close();
			} catch (Exception e) {
				
			}
			
			for (x=0;x<split_count;x++)
			if (len_i[x]>=1) {
				try {
					FileWriter fileWritter = new FileWriter(filepath+"_"+x,true);
					 BufferedWriter bufferWritter = new BufferedWriter(fileWritter);
		    	        
		    	        for (int d=0;d<len_i[x];d++) {
		    	        	bufferWritter.write(arr[x][d]);
		    	        	bufferWritter.newLine();
		    	        }
		    	        bufferWritter.flush();
		    	        bufferWritter.close();
				} catch(Exception e) {
					e.printStackTrace();
				}
    	       
			}
			
			
		}
	}
	
	
	//*****************************************************************
	void createKeyMapList(ConfDBOper d) {
		System.out.println("***********************************************");
		System.out.println("****       CREATE KEYMAP LIST FILE         ****");
		System.out.println("***********************************************");
		
		String sql="select id, name from tdm_envs order by name";
		
		int env_id=getSelectionFromList(d,sql,"Select From Environment List");
		
		if (env_id>0) {
			System.out.println("Environment to use : " + env_id+"\t"+  last_selection_name);
			
			//app_connstr, app_driver, app_username, app_password
			sql="select db_driver, db_connstr, db_username, db_password from tdm_envs where id=?";
			ArrayList<String[]> aEnv=d.getDbArrayConfInt(sql,1,env_id);
			
			d.app_driver=aEnv.get(0)[0];
			d.app_connstr=aEnv.get(0)[1];
			d.app_username=aEnv.get(0)[2];
			d.app_password=genLib.passwordDecoder(aEnv.get(0)[3]) ;
			
			
			
			System.out.println("Enter a valid SQL statement which has at least 2 columns in result set. ");
			System.out.println("!! 1st columnt will be used as Key and 2nd will be a value to be mapped");
			System.out.print(" SQL : ");
			
			String keymapsql=getInput();
			
			
			
			System.out.println("----------------------------------------");
			System.out.println(keymapsql);
			System.out.println("----------------------------------------");
			
			System.out.print(" Enter File Name : ");
			
			String filename=getInput();
			
			FileWriter fileWritter=null;
			BufferedWriter bufferWritter = null;
			try {
				
				File directory = new File(d.getParamByName("TDM_PROCESS_HOME")+File.separator+"list");
				if (!directory.exists()) 
					directory.mkdirs();
				
				filename=filename=d.getParamByName("TDM_PROCESS_HOME")+File.separator+"list"+File.separator+filename;
				
				fileWritter = new FileWriter(filename);
				bufferWritter = new BufferedWriter(fileWritter);
			} catch (Exception e) {
				System.out.println("Exception : invalid file name "+ filename);
				return;
			}
			
			ArrayList<String[]> arr=new ArrayList<String[]>();
			int recsize=0;
			while(true) {
				arr=d.getDbArrayAppLoop(keymapsql, 10000);
				if (arr==null || arr.size()==0) break;
				if (arr.get(0).length<2) {
					System.out.println("No way. SQL does not result 2 columns. Fix it.");
					break;
				}
				
				recsize+=arr.size();
				
				for (int i=0;i<arr.size();i++) {
					if (arr.get(i)[0].length()>0 && arr.get(i)[1].length()>0)
						try {
							bufferWritter.write(arr.get(i)[0]+";"+arr.get(i)[1]);
		    	        	bufferWritter.newLine();
						} catch(Exception e) {
							System.out.println("Write Error ");
							e.printStackTrace();
							return;
						}
					
				}
				
				try {
					bufferWritter.flush();
				} catch (IOException e) {
					System.out.println("Write Error ");
					e.printStackTrace();
					return;
				}
				
				arr.clear();
				if (d.heapUsedRate()>60) System.gc();
				
				if (recsize % 100000==0) System.out.println(" HEAP : " + d.heapUsedRate()+ " %");
			}
			
			try {fileWritter.close();bufferWritter.close();} catch(Exception e) {}
			
			splitKeyValFile(filename, d.KEYVAL_FILE_CHUNK_SIZE);
			
			System.out.println("\n\n :) file is created and splitted at " + filename+"\n\n");
			
			
			
		}
		
	}
	
	
	//*********************************************************
	String extractValFromPair(String pair) {
		try {
			return pair.substring(pair.indexOf("=")+1);
		} catch(Exception e) {
			return null;
		}
	}
	
	int last_rec_count=0;
	String last_schema_name="";
	String last_tab_name="";
	
	//****************************************************************
	int createTabFromLine(ConfDBOper d, int app_id, String a_line) {
		int tab_id=0;
		
		last_rec_count=0;
		
		if (!a_line.contains("schema_name=") || !a_line.contains("tab_name=")) 
		{
			System.out.println("Cannot create table from line since there is no  schema_name specified\nLine : " + a_line);
			return 0;
		}
		
		String[] parts=a_line.split("\\|::\\|");
		String sql="";
		String flds_sql="app_id";
		String vals_sql="?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",""+app_id});
		
		for (int i=0;i<parts.length;i++) {
			String a_item=parts[i];
			if (a_item.contains("=")) {
				String key=a_item.split("=")[0];
				String val=extractValFromPair(a_item);
				if (val.equals("-")) val="";
				
				if (
						key.equals("schema_name") ||
						key.equals("tab_name") ||
						key.equals("rec_count") ||
						key.equals("mask_level") ||
						key.equals("tab_filter") ||
						key.equals("parallel_function") ||
						key.equals("parallel_field") ||
						key.equals("parallel_mod") ||
						key.equals("partition_flag") ||
						key.equals("partition_used") 
						) {
					
					
					
					
					
					
					if (key.equals("rec_count")) 
						try {last_rec_count+=Integer.parseInt(val);} catch(Exception e) {}
					else 
					{
						
						if (flds_sql.length()>0) flds_sql=flds_sql+",";
						flds_sql=flds_sql+key;
						
						if (vals_sql.length()>0) vals_sql=vals_sql+",";
						vals_sql=vals_sql+"?";
						
						if (key.equals("parallel_mod")) 
							bindlist.add(new String[]{"INTEGER",val});
						else 
							bindlist.add(new String[]{"STRING",val});
						
						if (key.equals("schema_name")) last_schema_name=val;
						if (key.equals("tab_name")) last_tab_name=val;
						
					}
					
				}
				
				
			} //if (a_item.contains("="))
			
		} //for
		
		sql="insert into tdm_tabs ("+flds_sql+") values ("+vals_sql+")";
		//System.out.println("SQL to exec : " + sql);
		boolean inserted=d.execDBBindingConf(sql, bindlist);
		
		if (inserted) {
			sql="select max(id) from tdm_tabs";
			try { tab_id=Integer.parseInt(d.getDbArrayConf(sql, 1).get(0)[0]);} catch(Exception e) {}
			
			//insert fields ...
			//d.testconn(d.connApp);
			
			if (!d.testconn(d.connApp)) 
				d.connApp=d.getconn(d.app_connstr, d.app_driver, d.app_username, d.app_password);
			
			
		
			ArrayList<String[]> fieldArr=new ArrayList<String[]>();
			
			
			fieldArr=getFieldListFromApp(d.connApp, "ROWID", last_schema_name, last_tab_name);
			
			for (int f=0;f<fieldArr.size();f++) {
				String column_name=fieldArr.get(f)[0];
				String column_type=fieldArr.get(f)[1];
				String column_size=fieldArr.get(f)[2];
				String is_pk=fieldArr.get(f)[3];
				
				
				
				sql="insert into tdm_fields (tab_id, field_name, field_type, field_size, is_pk, mask_prof_id) values (?,?,?,?,?,?)";
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+tab_id});
				bindlist.add(new String[]{"STRING",column_name});
				bindlist.add(new String[]{"STRING",column_type});
				bindlist.add(new String[]{"INTEGER",column_size});
				bindlist.add(new String[]{"STRING",is_pk});
				bindlist.add(new String[]{"INTEGER","0"});
				
				d.execDBBindingConf(sql, bindlist);
			}
				
		}
		return tab_id;
	}
	


	//*****************************************************************
	void importBulkConfig(ConfDBOper d) {
		System.out.println("***********************************************");
		System.out.println("****       BULK CONFIGURATION              ****");
		System.out.println("***********************************************");
		
		String sql="select id, name from tdm_envs order by name";
		
		int env_id=getSelectionFromList(d,sql,"Select From Environment List");
		
		if (env_id>0) {
			System.out.println("Environment to use : " + env_id+"\t"+  last_selection_name);
			
			//app_connstr, app_driver, app_username, app_password
			sql="select db_driver, db_connstr, db_username, db_password from tdm_envs where id=?";
			ArrayList<String[]> aEnv=d.getDbArrayConfInt(sql,1,env_id);
			
			d.app_driver=aEnv.get(0)[0];
			d.app_connstr=aEnv.get(0)[1];
			d.app_username=aEnv.get(0)[2];
			d.app_password=genLib.passwordDecoder(aEnv.get(0)[3]) ;
			
			
			System.out.print(" Enter Bulk Config File Name With Path : ");
			
			String filename=getInput();
			
			InputStream fis=null;
			BufferedReader br=null;
			StringBuilder sb=new StringBuilder();
			ArrayList<String> lines=new ArrayList<String>();
			
			//open file
			try {
				fis=new FileInputStream(filename);
				 br=new BufferedReader(new InputStreamReader(fis));
			} catch(Exception e) {
				e.printStackTrace();
				System.out.println("File " + filename + " cannot be opened. ");
				
				return;
			}
			
			//read file...
			try {
				
				while (true) {
					
						sb.setLength(0);
						sb.append(br.readLine());
						if (sb.length()==0 || sb.toString().equals("null")) break;
						if (sb.toString().trim().length()>0) 
							lines.add(sb.toString().trim());
						
						
				}
					
			} catch(Exception e) {
				e.printStackTrace();
				System.out.println("Exception in importing file "  + filename);
				
				return;
			}
			
			///close file....
			try {fis.close();br.close();} catch(Exception e) {}
			
			//*******************************************
			int tab_id=0;
			int table_count=0;
			int field_count=0;
			int app_id=-1;
			
			System.out.println("Importing files...");
			ArrayList<String[]> tabArr=new ArrayList<String[]>();
			
			for (int i=0;i<lines.size();i++) {
				
				
			}
			
			
			
		
			
			
			
		}
	}
	
	//******************************
	int createApp(ConfDBOper d,String app_name) {
		int ret1=0;
		
		String sql="insert into tdm_apps(name, app_type) values (?, 'MASK')";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.add(new String[]{"STRING",app_name});
		
		d.execDBBindingConf(sql, bindlist);
		
		sql="select max(id) from tdm_apps where name=?";
		
		ArrayList<String[]> res=d.getDbArrayConf(sql, 1, bindlist);
		
		if (res.size()==1) 
			ret1=Integer.parseInt(res.get(0)[0]);
		
		return ret1;
	}
	
	
	//*************************************************************
	String getDbName(Connection conn) {
	//*************************************************************
		String url="";

		try {url=conn.getMetaData().getURL();} catch(Exception e) {}
		
		String split_str="";
		if (url.indexOf("database=")>-1) split_str="database=";
		if (url.indexOf("databaseName=")>-1) split_str="databaseName=";
		if (url.indexOf("DatabaseName=")>-1) split_str="DatabaseName=";
		if (url.indexOf("db=")>-1) split_str="db=";
		if (url.indexOf("dbname=")>-1) split_str="dbname=";
		
		String db_name="";
		try{db_name=url.split(split_str)[1].split(";")[0];} catch(Exception e) {}
		
		return db_name;
	}
	
	
	//*************************************************************
	public String getSqlDataTypeName(String val) {
	//*************************************************************
	String ret1="NOT/FOUND";
	int i=0;
	try{
	i=Integer.parseInt(val);
	} catch(Exception e) {
		i=0;
		e.printStackTrace();
	}

	switch(i) {
		case -6 : ret1="TINYINT"; break;
		case 5 : ret1="SMALLINT"; break;
		case 4 : ret1="INTEGER"; break;
		case -5 : ret1="BIGINT"; break;
		case 6 : ret1="FLOAT"; break;
		case 7 : ret1="REAL"; break;
		case 8 : ret1="DOUBLE"; break;
		case 2 : ret1="NUMERIC"; break;
		case 3 : ret1="DECIMAL"; break;
		case 1 : ret1="CHAR"; break;
		case 12 : ret1="VARCHAR"; break;
		case -1 : ret1="LONGVARCHAR"; break;
		case 91 : ret1="DATE"; break;
		case 92 : ret1="TIME"; break;
		case 93 : ret1="TIMESTAMP"; break;
		case -2 : ret1="BINARY"; break;
		case -3 : ret1="VARBINARY"; break;
		case -4 : ret1="LONGVARBINARY"; break;
		case 0 : ret1="NULL"; break;
		case 1111 : ret1="OTHER"; break;
		case 2000 : ret1="JAVA_OBJECT"; break;
		case 2001 : ret1="DISTINCT"; break;
		case 2002 : ret1="STRUCT"; break;
		case 2003 : ret1="ARRAY"; break;
		case 2004 : ret1="BLOB"; break;
		case 2005 : ret1="CLOB"; break;
		case 2006 : ret1="REF"; break;
		case -8 : ret1="ROWID"; break;
		case -15 : ret1="NCHAR"; break;
		case -9 : ret1="NVARCHAR"; break;
		case -16 : ret1="LONGNVARCHAR"; break;
		case 2011 : ret1="NCLOB"; break;
		case 2009 : ret1="SQLXML"; break;
		default:ret1="NOT/FOUND"; break;

	}

	return ret1;

	}
	
	//*************************************************************
	public ArrayList<String[]> getFieldListFromApp(Connection conn, String env_db_rowid, String owner, String table) {
	//*************************************************************

		long s=System.currentTimeMillis();
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		
		DatabaseMetaData md=null;
		
		String f_name="";
		String f_type="";
		String f_size="";
		String f_is_pk="";
		
		
		ArrayList<String> pklist=new ArrayList<String>();

		//if db have row id add it as a first column
		if (env_db_rowid.trim().length()>0) {
			String[] arr=new String[]{env_db_rowid, env_db_rowid, "0","YES"};
			ret1.add(arr);
		} 
		else
		{
			try {
			DatabaseMetaData meta = conn.getMetaData();
			
			ResultSet rspk = null;
			
			try {
				rspk = meta.getPrimaryKeys(owner, null, table);
				
				while (rspk!=null && rspk.next()) {
				      String columnName = rspk.getString(4); //"COLUMN_NAME"
				      pklist.add(columnName);
				    }
			} catch(Exception e) {} finally {try{rspk.close();} catch(Exception e){}}
			
			
		
			if (pklist.size()==0) {
				try {
					rspk = meta.getPrimaryKeys(null, owner, table);
					while (rspk!=null && rspk.next()) {
					      String columnName = rspk.getString(4); //"COLUMN_NAME"
					      pklist.add(columnName);
					    }
				} catch(Exception e) {} finally {try{rspk.close();} catch(Exception e){}}
			}
			
			//DBs like SQL Server
			if (pklist.size()==0) {
				String db_name=getDbName(conn);
				System.out.println("db_name : "+db_name);
				
				if (db_name.length()>0) {
					rspk = meta.getPrimaryKeys(db_name, owner, table);
					while (rspk!=null && rspk.next()) {
					      String columnName = rspk.getString(4); //"COLUMN_NAME"
					      pklist.add(columnName);
					    }
					rspk.close();
				} //if (db_name.length()>0)
				
			}
			
			} catch(Exception e) {
				e.printStackTrace();
			}
			
		} //if (env_db_rowid.length()>0) 
		

		String[] type_filter=new String[] {"TABLE"};
		
		if (conn!=null) {

			ResultSet rs = null;

			try {

				md = conn.getMetaData();
				rs = md.getColumns(conn.getCatalog(), owner, table, null);
				
				while (rs.next()) {
					f_name=rs.getString("COLUMN_NAME"); //4
					f_type=getSqlDataTypeName(rs.getString("DATA_TYPE")); //+"."+rs.getString("TYPE_NAME");			
					f_size=rs.getString("COLUMN_SIZE");
					f_is_pk="NO";
					
					for (int p=0;p<pklist.size();p++)
						if (f_name.equals(pklist.get(p))) f_is_pk="YES";
					
					String[] arr=new String[]{f_name, f_type, f_size, f_is_pk};
					ret1.add(arr);
					}
			
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {md = null;} catch (Exception e) {}
				try {rs.close();rs = null;} catch (Exception e) {}
			}
		
		}
		
		
		return ret1;

	}
	
	String[] global_args=new String[]{""};
	//******************************
	String getParamFromArgs(String param_name) {
		for (int i=0;i<global_args.length;i++) {
			String par="";
			String val="";
			
			String arg=global_args[i];
			if (arg.length()>0 && arg.contains("=")) {
				par=arg.split("=")[0];
				val=arg.split("=")[1];
			}
			if (par.equals(param_name)) return val;
		}
		
		return "";
	}
	
	//******************************
	void login() {
		
		
		int retry_count=0;
		String password="";
		try {
			ConfDBOper d=new ConfDBOper(false);
			String sql="select password from tdm_user where username='admin'";
			password=d.getDbArrayConf(sql, 1).get(0)[0];
			d.closeAll();
		} catch(Exception e) {
			System.out.println("System is not ready. Could not login to database");
			return;
		}

		String cmd_password=getParamFromArgs("PASSWORD");
		
		if (cmd_password.trim().length()>0) {
			if (encrypt(cmd_password).equals(password)) {
				System.out.println("Login OK :)");
				login_ok=true;
				return;
			}
		}
		

		while(retry_count<3) {
			System.out.print("Enter TDM Admin Password ("+(retry_count+1)+"): " );
			String input=getPassword();
			if (encrypt(input).equals(password)) {
				System.out.println("Login OK :)");
				login_ok=true;
				break;
			}
			retry_count++;
		}
		
	}
	
	


	

	//*****************************************************************
	void retryFailedTaskByWorkPlan(ConfDBOper d) {
		System.out.println("***********************************************");
		System.out.println("****       RETRY FAILED TASKS              ****");
		System.out.println("***********************************************");
		
		
			String sql="select id, work_plan_name from tdm_work_plan where status in('RUNNING') order by 1";
			
			
			
			int work_plan_id=getSelectionFromList(d,sql,"Select From Running WorkPlans");
			
			System.out.print(" Enter WorkPlan Id : ");
			
			if (work_plan_id>0) {
				sql="select id from tdm_work_package where work_plan_id="+work_plan_id;
				
				ArrayList<String[]> wpcList=d.getDbArrayConf(sql, Integer.MAX_VALUE);
				int sum_task_retried=0;
				for (int i=0;i<wpcList.size();i++) {
					String work_pack_id=wpcList.get(i)[0];
					System.out.println("Checking task_table : tdm_task_"+work_plan_id+"_"+work_pack_id +  " ..." );
					sql="select count(*) from tdm_task_"+work_plan_id+"_"+work_pack_id  + " where fail_count>0";
					int failed_count=0;
					try {failed_count=Integer.parseInt(d.getDbArrayConf(sql, 1).get(0)[0]);} catch(Exception e) {failed_count=0;}
					
					if (failed_count>0) {
						System.out.println("\t"+failed_count +" failed task(s) found. updating ...");
						sql="update tdm_task_" + work_plan_id + "_" + work_pack_id + 
								" set status='NEW', start_date=null, end_date=null, " +
								" duration=null, success_count=0, fail_count=0, done_count=0," + 
								" log_info_zipped=null, err_info_zipped=null, retry_count=0" +
								" where  fail_count>0";
						d.execDBConf(sql);
						System.out.println("done..");
						
						sum_task_retried+=failed_count;
					} //if (failed_count>0)
					
				} // for 
				
				System.out.println("**************************************");
				System.out.println(" Done. COUNT OF TASK TO RETRY : " + sum_task_retried);
				System.out.println("**************************************");
			}
			
		
	}
	
	
	//*****************************************************************
	void setNullTaskByWorkPlan(ConfDBOper d) {
		System.out.println("***********************************************");
		System.out.println("****       SET FINISHED TASK NULL          ****");
		System.out.println("***********************************************");
		
		
			String sql="select id, work_plan_name from tdm_work_plan where status in('RUNNING') order by 1";
			
			
			
			int work_plan_id=getSelectionFromList(d,sql,"Select From Running WorkPlans");
			
			System.out.print(" Enter WorkPlan Id : ");
			
			if (work_plan_id>0) {
				sql="select id from tdm_work_package where work_plan_id="+work_plan_id+ " and status='FINISHED'";
				
				ArrayList<String[]> wpcList=d.getDbArrayConf(sql, Integer.MAX_VALUE);
				int sum_task_nulled=0;
				for (int i=0;i<wpcList.size();i++) {
					String work_pack_id=wpcList.get(i)[0];
					System.out.println("Checking task_table : tdm_task_"+work_plan_id+"_"+work_pack_id +  " ..." );
					sql="select count(*) from tdm_task_"+work_plan_id+"_"+work_pack_id  + " where status='FINISHED' and fail_count=0 and task_info_zipped is not null" ;
					//sql="select count(*) from tdm_task_"+work_plan_id+"_"+work_pack_id  + " where status='FINISHED' and fail_count=0" ;
					int nullable_count=0;
					try {nullable_count=Integer.parseInt(d.getDbArrayConf(sql, 1).get(0)[0]);} catch(Exception e) {nullable_count=0;}
					
					if (nullable_count>0) {
						System.out.println("\t"+nullable_count +" finished task(s) found. setting null ...");
						sql="update tdm_task_" + work_plan_id + "_" + work_pack_id + 
								" set " + 
								" task_info_zipped=null, log_info_zipped=null, err_info_zipped=null" +
								" where  status='FINISHED' and fail_count=0";
						d.execDBConf(sql);
						
						
						
						sql="optimize table  tdm_task_" + work_plan_id + "_" + work_pack_id;
						d.execDBConf(sql);
						
						System.out.println("done..");
						sum_task_nulled+=nullable_count;
					} //if (failed_count>0)
					
				} // for 
				
				System.out.println("**************************************");
				System.out.println(" Done. NULL TASK DONE : " + sum_task_nulled);
				System.out.println("**************************************");
			}
			
		
	}
	
	
	public static void main(String[] args) {
		
		ConfDBOper licencecheck=new ConfDBOper(false);
		licencecheck.checkLicence();
		
		
		
		
		maskutil m=new maskutil();
		
		m.global_args=args;
		
		if (!m.login_ok) {
			m.login();
		}
		
		if (!m.login_ok) {
			System.out.println("Invalid password entered 3 times.");
			System.exit(0);
		}
		
		int c=0;
		while(c!=9) {
			try {
				String input=m.printMenu();
				if (input.toLowerCase().equals("q")) c=9;
				else c=Integer.parseInt(input);
				}  catch(Exception e) {c=0;}
			if (c==0) {
				System.out.println("\n\n!!!! Invalid Selection !!!! \n\n");
			}
			
			if (c==1) {
				ConfDBOper d=new ConfDBOper(false);
				d.next_delete_unused_tables_ts=0;
				d.deleteUnusedTaskTables(true);
				d.closeAll();
			}
			
			if (c==2) {
				ConfDBOper d=new ConfDBOper(false);
				dmModelForDM model=new dmModelForDM();
				model.syncDM(d.connConf);
				d.closeAll();
			}
			
			if (c==3) {
				System.out.println("\n\nNot Implemented yet !!!\n\n");
			}
			
			
			if (c==4) {
				ConfDBOper d=new ConfDBOper(false);
				m.createKeyMapList(d);
				d.closeAll();
			}
			
			if (c==5) {
				ConfDBOper d=new ConfDBOper(false);
				m.importBulkConfig(d);
				d.closeAll();
			}
			
			
			
			if (c==7) {
				ConfDBOper d=new ConfDBOper(false);
				m.retryFailedTaskByWorkPlan(d);
				d.closeAll();
			}
			
			if (c==8) {
				ConfDBOper d=new ConfDBOper(false);
				m.setNullTaskByWorkPlan(d);
				d.closeAll();
			}
			
			if (m.global_args.length>0) {
				System.out.println("One time executed. Bye");
				break;
			}
			
		}

	}

}
