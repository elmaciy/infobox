package com.mayatech.tdm;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.lang.management.RuntimeMXBean;
import java.sql.BatchUpdateException;
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
import java.util.zip.Deflater;

import oracle.sql.ROWID;

import com.mayatech.baseLibs.genLib;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoDatabase;

public class commonLib {

	
	
	
	byte LOG_LEVEL_DANGER=0;
	byte LOG_LEVEL_WARNING=1;
	byte LOG_LEVEL_INFO=2;
	byte LOG_LEVEL_DEBUG=3;
	
	byte CURRENT_LOG_LEVEL=LOG_LEVEL_INFO;
	
	int batch_updated_column_count=0;
	
	
	final int TABLE_TDM_MANAGER=1;
	final int TABLE_TDM_MASTER=2;
	final int TABLE_TDM_WORKER=3;
	
	
	public static final long HEARTBEAT_INTERVAL = 10000;
	
	static final int MAX_RETRY_COUNT=5;
	
	long last_heartbeat = 0;
	
	
	static final int MAX_LONG_LENGTH=100000;
	//******************************************
	
	public StringBuilder logStr=new StringBuilder();
	public StringBuilder errStr=new StringBuilder();
	
	public void mylog(byte log_level, String logstr) {
		myloggerBase(logStr, errStr, log_level, logstr);



		
		
	}
		
	//******************************************
	String getPID() {
		RuntimeMXBean rmxb = ManagementFactory.getRuntimeMXBean();
		System.out.println("PID.................. : " + rmxb.getName());
		return  rmxb.getName();
	}
	
	
	//******************************************
	
	
	
	public synchronized Connection getApplicationDbConnectionByDBId(Connection confDbConn, int db_id) {
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		String sql="select db_driver, db_connstr, db_username, db_password, db_catalog from tdm_envs where id=?";
		bindlist.add(new String[]{"INTEGER",""+db_id});
		ArrayList<String[]> arr=getDbArray(confDbConn, sql, 1, bindlist);
		
		if (arr==null || arr.size()==0) return null;
		
		String app_db_driver=arr.get(0)[0];
		String app_db_connstr=arr.get(0)[1];
		String app_db_username=arr.get(0)[2];
		String app_db_password=genLib.passwordDecoder(arr.get(0)[3]) ;
		String app_db_catalog=arr.get(0)[4];
		
		
		
		Connection ret1=getDBConnection(app_db_connstr, app_db_driver, app_db_username, app_db_password, 1);
		
		setCatalogForConnection(ret1, app_db_catalog);
		
		
		
		return ret1;
	}
	
	public String last_connection_error="";
		
	// *****************************************
	public Connection getDBConnection(String ConnStr, String Driver, String User, String Pass, int retry_count) {
		
		Connection ret1 = null;
		
		last_connection_error="";
		
		mylog(LOG_LEVEL_WARNING, "Connecting to : ");
		mylog(LOG_LEVEL_WARNING, "driver     :["+Driver+"]");
		mylog(LOG_LEVEL_WARNING, "connstr    :["+ConnStr+"]");
		mylog(LOG_LEVEL_WARNING, "user       :["+User+"]");
		mylog(LOG_LEVEL_WARNING, "pass       :["+"************]");	
		
		System.out.println("Connecting to : ");
		System.out.println("driver     :["+Driver+"]");
		System.out.println("connstr    :["+ConnStr+"]");
		System.out.println("user       :["+User+"]");


		int retry=0;
		while (true) {
			if (retry>retry_count) break;
			retry++;
			try {
				Class.forName(Driver.replace("*",""));
				Connection conn = DriverManager.getConnection(ConnStr, User, Pass);
				
			
				boolean is_connection_valid=true;
				
				//try{ conn.isValid(60); } catch(Exception e) {is_connection_valid=true;}
				if (is_connection_valid) {
					ret1 = conn;
					break;
				}
					
				
	
			} catch (Exception ignore) {
				mylog(LOG_LEVEL_DANGER, "Exception@getconn : " + ignore.getMessage());
				ignore.printStackTrace();
				ret1=null;
				mylog(LOG_LEVEL_DANGER, "sleeping ...");
				
				last_connection_error=ignore.getMessage();
				
				sleep(5000);
			}
			
			mylog(LOG_LEVEL_DANGER, "Connection is failed to db : retry("+retry+") ");
			mylog(LOG_LEVEL_DANGER, "driver     :"+Driver);
			mylog(LOG_LEVEL_DANGER, "connstr    :"+ConnStr);
			mylog(LOG_LEVEL_DANGER, "user       :"+User);
			mylog(LOG_LEVEL_DANGER, "pass       :"+"************");
			mylog(LOG_LEVEL_DANGER, "Sleeping...");
			
			
			
		}
		
		return ret1;
	}
		
	//*******************************************************************************
	
	String last_db_type_type=null;
	
	
	String getDbType(Connection conn) {
		
		if (last_db_type_type!=null) return last_db_type_type;
		
		
		String DatabaseProductName="";
		
		if (conn==null) {
			last_db_type_type="UNKNOWN";
			return "UNKNOWN";
		}
		
		try {
			DatabaseProductName = conn.getMetaData().getDatabaseProductName().toUpperCase();
			
		} catch (SQLException e) {}
		
		
		String ret1="";
		
		if (DatabaseProductName.contains("ORACLE")) {
			
			ret1=genLib.DB_TYPE_ORACLE;
		}
		if (DatabaseProductName.contains("MSSQL") || DatabaseProductName.contains("MICROSOFT")) ret1=genLib.DB_TYPE_MSSQL;
		else if (DatabaseProductName.contains("MYSQL") || DatabaseProductName.contains("MY SQL")) ret1=genLib.DB_TYPE_MYSQL;
		else if (DatabaseProductName.contains("DB2")) ret1=genLib.DB_TYPE_DB2;
		else  if (DatabaseProductName.contains("JBASE")) ret1=genLib.DB_TYPE_JBASE;
		else if (DatabaseProductName.contains("SYBASE")) ret1=genLib.DB_TYPE_SYBASE;
		else if (DatabaseProductName.contains("POSTGRESQL")) ret1=genLib.DB_TYPE_POSTGRESQL;
		else  ret1=genLib.nvl(DatabaseProductName,"UNKNOWN_DB_TYPE");
		
		last_db_type_type=ret1;
		
		return ret1;
		
	}
	
	//-------------------------------------------------------------------------------
	String getDbType(Connection connfDB,String driver_name) {
		
		String ret1="";
		String sql="select flexval1 from  tdm_ref where ref_type='DB_TYPE' and ref_name=?";
		
	
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"STRING",driver_name});
		System.out.println("Driver Name : ["+driver_name+"]");
		
		try {ret1=getDbArray(connfDB, sql, 1, bindlist).get(0)[0];} catch(Exception e) {e.printStackTrace();}
		
		return ret1;
		
	}
		
		//*****************************************
		public ArrayList<String[]> getDbArray(Connection conn, String sql, int limit,ArrayList<String[]> bindlist) {
			return getDbArray(conn, sql, limit, bindlist, 999999);
		}
			
		//*****************************************
		public ArrayList<String[]> getDbArray(Connection conn, String sql, int limit,ArrayList<String[]> bindlist, int timeout_insecond) {
			
			ArrayList<String[]> ret1 = new ArrayList<String[]>();

			PreparedStatement pstmt = null;
			ResultSet rset = null;
			ResultSetMetaData rsmd = null;

			mylog(LOG_LEVEL_DEBUG, "getDbArrayConf sql : " + sql);
			
			int reccnt = 0;
			try {
				if (pstmt == null) {
					pstmt = conn.prepareStatement(sql);
					try{pstmt.setFetchSize(1000);} catch(Exception e) {}
				}
				
				//------------------------------ end binding

				if (bindlist!=null) {
					for (int i = 1; i <= bindlist.size(); i++) {
						String[] a_bind = bindlist.get(i - 1);
						String bind_type = a_bind[0];
						String bind_val = a_bind[1];
						
						mylog(LOG_LEVEL_DEBUG, "binding ["+bind_type+"] :\t " + bind_val);
		
						if (bind_type.equals("INTEGER")) {
							if (bind_val == null || bind_val.equals(""))
								pstmt.setNull(i, java.sql.Types.INTEGER);
							else
								pstmt.setInt(i, Integer.parseInt(bind_val));
						} else if (bind_type.equals("LONG")) {
							if (bind_val == null || bind_val.equals(""))
								pstmt.setNull(i, java.sql.Types.INTEGER);
							else
								pstmt.setLong(i, Long.parseLong(bind_val));
						} else if (bind_type.equals("DOUBLE")) {
							if (bind_val == null || bind_val.equals(""))
								pstmt.setNull(i, java.sql.Types.DOUBLE);
							else
								pstmt.setDouble(i, Double.parseDouble(bind_val));
						} else if (bind_type.equals("FLOAT")) {
							if (bind_val == null || bind_val.equals(""))
								pstmt.setNull(i, java.sql.Types.FLOAT);
							else
								pstmt.setFloat(i, Float.parseFloat(bind_val));
						} 
						else {
							pstmt.setString(i, bind_val);
						}
					}
					//------------------------------ end binding
				}  // if bindlist 
				
				pstmt.setQueryTimeout(timeout_insecond);
				
				if (rset == null) rset = pstmt.executeQuery();
				if (rsmd == null) rsmd = rset.getMetaData();

				int colcount = rsmd.getColumnCount();
				String a_field = "";
				while (rset.next()) {
					reccnt++;
					if (reccnt > limit) break;
					String[] row = new String[colcount];
					for (int i = 1; i <= colcount; i++) {
						try {
							a_field = rset.getString(i);
							if (a_field.equals("null")) a_field=""; 
							} 
						catch (Exception enull) {a_field = "";}
						row[i - 1] = a_field;
					}
					ret1.add(row);
				}
			} catch(SQLException sqle) {
				sqle.printStackTrace();
				mylog(LOG_LEVEL_DANGER, "Exception@getDbArray : SQL       => " + sql);
				mylog(LOG_LEVEL_DANGER, "Exception@getDbArray : MSG       => " + sqle.getMessage());
				mylog(LOG_LEVEL_DANGER, "Exception@getDbArray : CODE      => " + sqle.getErrorCode());
				mylog(LOG_LEVEL_DANGER, "Exception@getDbArray : SQL STATE => " + sqle.getSQLState());
			}
			catch (Exception ignore) {
				ignore.printStackTrace();
				mylog(LOG_LEVEL_DANGER, "Exception@getDbArray : SQL => " + sql);
				mylog(LOG_LEVEL_DANGER, "Exception@getDbArray : MSG => " + ignore.getMessage());
			} finally {
				try {rsmd = null;} catch (Exception e) {}
				try {rset.close();rset = null;} catch (Exception e) {}
				try {pstmt.close();	pstmt = null;} catch (Exception e) {}
			}
			return ret1;
		}
		
		//**********************************
		public byte[] getInfoBin(Connection conn, String table_name, long p_id,String field_name) {

			byte[] ret1=null;
			String sql="select "+field_name+" from "+ table_name + " where id=? limit 0,1";
			
			PreparedStatement pstmt = null;
			ResultSet rset = null;
			
			try {
				pstmt = conn.prepareStatement(sql);
				pstmt.setLong(1, p_id);
				
				rset = pstmt.executeQuery();
				
				while (rset.next()) {
					try {
					ret1=rset.getBytes(1); 
					} catch(Exception e) {ret1=null;}
					break;
				}
				
			} catch (Exception ignore) {
				String msg = ignore.getMessage();
				mylog(LOG_LEVEL_DANGER,"getDbArrayConf Exception : " + msg);
				ret1=null;
			} finally {
				try {
					rset.close();
					rset = null;
				} catch (Exception e) {
				}
				try {
					pstmt.close();
					pstmt = null;
				} catch (Exception e) {
				}

			}
			
			return ret1;
		}
		
		
		

		
		// ***************************************
		public int execBatchUpdateSql(
				Connection conn, 
				boolean isBatchUpdateSupported, 
				String sql, 
				ArrayList<String[]> bindlist, 
				int binding_size_per_record, 
				int timeout,
				maskLib mLib,
				StringBuilder sbLog,
				StringBuilder sbErr
				) {

			batch_updated_column_count+=bindlist.size();
			
			
			
			int ret1 = 0;
			ArrayList<String> usingArr=new ArrayList<String>();
			
			PreparedStatement pstmt=null;

			try {
				pstmt = conn.prepareStatement(sql);

				if (timeout>0 && timeout<Integer.MAX_VALUE) pstmt.setQueryTimeout(timeout);
				
				
				int field_no=0;
				StringBuilder using = new StringBuilder();
				

				//myloggerBase(sbLog, sbErr, LOG_LEVEL_DEBUG, "SQL : "+sql);
				

				for (int i = 1; i <= bindlist.size(); i++) {
					
					field_no++;
					String[] a_bind = bindlist.get(i - 1);
					String bind_type = a_bind[0];
					String bind_val  = a_bind[1];
					
					//myloggerBase(sbLog, sbErr, LOG_LEVEL_DEBUG, "\t bind("+i+") "+bind_type+ " => "+bind_val);
					
					if (field_no > 1) 	using.append(", ");
					using.append("{" + bind_val + "}");
					
					try {
						if (bind_type.equals("INTEGER")) {
							if (bind_val == null || bind_val.equals(""))
								pstmt.setNull(field_no, java.sql.Types.INTEGER);
							else{
								try {
									int int_val=Integer.parseInt(bind_val);
									pstmt.setInt(field_no, int_val);
								} catch(Exception e1) {
									try {
										float f_val=Float.parseFloat(bind_val.replace(',', '.'));
										pstmt.setFloat(field_no, f_val);
									} catch(Exception e2) {
										try {
											double d_val=Double.parseDouble(bind_val.replace(',', '.'));
											pstmt.setDouble(field_no, d_val);
										} catch(Exception e3) {
											e3.printStackTrace();
										}
									}
								}
								
								
								
							} //if (bind_val == null || bind_val.equals(""))
								
						} else if (bind_type.equals("LONG")) {
							if (bind_val == null || bind_val.equals(""))
								pstmt.setNull(field_no, java.sql.Types.INTEGER);
							else
								pstmt.setLong(field_no, Long.parseLong(bind_val));
						} else if (bind_type.equals("DATE")) {
							if (bind_val == null || bind_val.equals(""))
								pstmt.setNull(field_no, java.sql.Types.DATE);
							else {
								Date d = new SimpleDateFormat(genLib.DEFAULT_DATE_FORMAT)
										.parse(bind_val);
								java.sql.Date date = new java.sql.Date(d.getTime());
								pstmt.setDate(field_no, date);
							}
						} else if (bind_type.equals("BLOB")) {
							pstmt.setBytes(field_no, hexStringToByteArray(bind_val));
							
							
						} else if (bind_type.equals("ROWID")) {
							String db_type=getDbType(conn);
							if (db_type.equals(genLib.DB_TYPE_ORACLE)) {
								ROWID r = new ROWID();
								r.setBytes(bind_val.getBytes());
								pstmt.setRowId(field_no, r);
								r = null;
							}
							
							if (db_type.equals(genLib.DB_TYPE_DB2)) {
								byte[] byterowid=hexStringToByteArray(bind_val);
								pstmt.setBytes(field_no, byterowid);
							}
						} else 
							pstmt.setString(field_no, bind_val);
						
						
						
					} catch (Exception e) {
						
						myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execBatchUpdateSsql BINDING : MSG       => " + genLib.getStackTraceAsStringBuilder(e).toString());

					}

				
					if (field_no==binding_size_per_record) {
						field_no=0;
						usingArr.add(using.toString());
						if (using.length()>10000) 
							myloggerBase(sbLog, sbErr, LOG_LEVEL_DEBUG,"Using : "+using.toString().substring(1,10000)+"... and more...");
						else
							myloggerBase(sbLog, sbErr, LOG_LEVEL_DEBUG,"Using : "+using.toString());
						using = new StringBuilder();

						if (isBatchUpdateSupported) {
							pstmt.addBatch();
							}
						else {
							
							try {
								pstmt.executeUpdate();
								ret1++;
								
							} 
							catch(SQLException sqle) {
								
								
								myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execBatchSingleUpdateSsql : SQL       => " + sql);
								myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execBatchSingleUpdateSsql : MSG       => " + sqle.getMessage());
								myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execBatchSingleUpdateSsql : CODE      => " + sqle.getErrorCode());
								myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execBatchSingleUpdateSsql : SQL STATE => " + sqle.getSQLState());
								
								myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execDBBindingApp  BINDLIST (max 100) : ");
								
								int max_bindlist_size=bindlist.size();
								if (max_bindlist_size>100) max_bindlist_size=100;
								
								for (int b=0;b<max_bindlist_size;b++) 
									myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "\t"+b+"["+bindlist.get(b)[0]+"]> {"+ bindlist.get(b)[1]+"}");
								
								
								sqle.printStackTrace();
							}
							catch(Exception e) {
								
								myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execBatchSingleUpdateSsql     :     MSG=> " + e.getMessage());
								myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execBatchSingleUpdateSsql     :     SQL => "+sql);
								e.printStackTrace();
							}
							
							try{pstmt.close();} catch(Exception e) {}
							
							try{
								pstmt = conn.prepareStatement(sql);
								if (timeout>0 && timeout<Integer.MAX_VALUE) pstmt.setQueryTimeout(timeout);	
							}
							catch(Exception e) {
								
								myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execBatchSingleUpdateSsqlprepareStatement     :     MSG=> " + e.getMessage());
								myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execBatchSingleUpdateSsqlprepareStatement     :     SQL=> "+sql);
								e.printStackTrace();
							}
						}
						
					}
					
				} //for (int i = 1; i <= bindlist.size(); i++)


				
				if (isBatchUpdateSupported) {
					ret1=0;
					int[] updates=pstmt.executeBatch();
					for (int u=0;u<updates.length;u++) 
						if (updates[u]>=0) ret1++;
					
				}
				
			} 
			catch (BatchUpdateException buex) {


				int upd_count=0;
				
				int[] cnts=buex.getUpdateCounts();
				for (int a=0;a<cnts.length;a++) 
					if (cnts[a]>0) upd_count++;
				
				ret1=upd_count;

			    SQLException ex = buex.getNextException(); 
			    
			    int err_count_shown=0;
			    
			    while (ex != null) {                                      
			    	err_count_shown++;
			        
				    String using=null;
				    try {
				    	using=usingArr.get(upd_count);
				    } catch(Exception e) {
				    	using="Unknown";
				    }
				    
				    if (err_count_shown<=10) {
				    	myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "BatchUpdateException@SQL        : " + sql);
				    	myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "BatchUpdateException@Using      : " + using);     		    
				    	myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "BatchUpdateException@Message    : " + ex.getMessage());
				    	myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "BatchUpdateException@SQLSTATE   : " + ex.getSQLState());
				    	myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "BatchUpdateException@Errorcode  : " + ex.getErrorCode());
				    	
				    } else break;

					ex = buex.getNextException();
			     }

				
			} 
			catch (Exception e) {
				
				
				try {ret1=pstmt.getUpdateCount();} catch(Exception ex) {ret1=0;}
				
				if (ret1<0) ret1=0;

				myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execDBBindingApp  BINDLIST (max 100) : ");
				
				int max_bindlist_size=bindlist.size();
				if (max_bindlist_size>100) max_bindlist_size=100;
				
				for (int b=0;b<max_bindlist_size;b++) 
					
					myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "\t"+b+"["+bindlist.get(b)[0]+"]> {"+ bindlist.get(b)[1]+"}");
				
				myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execDBBindingApp : " + genLib.getStackTraceAsStringBuilder(e));
				myloggerBase(sbLog, sbErr, LOG_LEVEL_DANGER, "Exception@execDBBindingApp  STATEMENT : " + sql);
				

			} finally {
				try {
				
					if (isBatchUpdateSupported && ret1==0) 
						ret1=pstmt.getUpdateCount();
					if (ret1<0) ret1=0;
					
					if (batch_updated_column_count >= 100000) {
						
						if (!conn.getAutoCommit()) {
							batch_updated_column_count=0;
							conn.commit();
							myloggerBase(sbLog, sbErr, LOG_LEVEL_DEBUG, "Committed :)");
						}
					}
					
					
					
					
					try {
						pstmt.close();
						pstmt = null;
					} catch(Exception e) {}
					
					
				} catch (Exception e) {}
			}

			try {pstmt.close();} catch(Exception e) {}
			
			//System.out.println("=================="+ret1);
			
			return ret1;
		}
		
		//****************************************		
		public boolean execSingleUpdateSQL(Connection conn, String sql,ArrayList<String[]> bindlist) {
			
			return execSingleUpdateSQL(conn,sql,bindlist,true, 0);
			
		}

		//****************************************		
		public boolean execSingleUpdateSQL(Connection conn, String sql,ArrayList<String[]> bindlist, int timeout_as_sec) {
			
			return execSingleUpdateSQL(conn,sql,bindlist,true, timeout_as_sec);
			
		}
		
		
		//****************************************
		public boolean execSingleUpdateSQL(Connection conn, String sql,ArrayList<String[]> bindlist, boolean commit_after, int timeout_as_sec) {

			boolean ret1 = true;
			PreparedStatement pstmt_execbind = null;

			StringBuilder using = new StringBuilder();
			try {
				pstmt_execbind = conn.prepareStatement(sql);
				if (timeout_as_sec>0) 
					try { pstmt_execbind.setQueryTimeout(timeout_as_sec);  } catch(Exception e) {}
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

				mylog(LOG_LEVEL_DEBUG,"Executing SQL : " + sql + " using " + using.toString());

				pstmt_execbind.executeUpdate();

				
				if (!conn.getAutoCommit() && commit_after) 	{
					conn.commit();
				}


			} catch (Exception e) {
				mylog(LOG_LEVEL_DANGER, "Exception@execSingleUpdateSQL : " + e.getMessage());
				e.printStackTrace();
				ret1 = false;
			} finally {
				try {
					pstmt_execbind.close();
					pstmt_execbind = null;
				} catch (Exception e) {
				}
			}

			return ret1;
		}
		
		
		//***********************************************
		public boolean execAppScript(Connection conn, String sql) {
			boolean ret1=false;
			Statement stmt=null;
			//************************
			mylog(LOG_LEVEL_DEBUG, sql);
			if (conn!=null) {
				try {
					stmt=conn.createStatement();
					
					stmt.executeUpdate(sql);
					stmt.close();
					ret1=true;
				} catch(Exception e) {
					mylog(LOG_LEVEL_DANGER, "Exception@execAppScript : " + e.getMessage());
					e.printStackTrace();
				} finally {
					try{stmt.close();} catch(Exception e) {}
				}
			}
			
			return ret1;
		}
		
		
		
		//*************************************************************
		public String getParamByName(Connection conn, String param_name) {
		//*************************************************************
		String ret1="";
		String sql="select param_value from tdm_parameters where param_name=?  limit 0,1";

		try {
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			bindlist.add(new String[]{"STRING",param_name});
			ArrayList<String[]> arr=getDbArray(conn, sql, 1, bindlist);
			return arr.get(0)[0];
		} catch(Exception e) {
			ret1="";
		}

		
		return ret1;
		
		}
		
		//********************************
		String sql_FOR_setBinInfo_ById=null;
		
		void setBinInfo(Connection conn, String table_name, String id_field, long id, String field_name, byte[] sb_info) {
			
			if (sb_info==null || sb_info.length==0) return;
			
			if (sql_FOR_setBinInfo_ById==null)
				sql_FOR_setBinInfo_ById="update "+table_name+" set "+field_name+" =? where "+id_field+"=?";
			
			PreparedStatement stmt=null;
			try {
				stmt = conn.prepareStatement(sql_FOR_setBinInfo_ById);
				stmt.setBytes(1, sb_info);
				stmt.setLong(2, id);
				stmt.executeUpdate();
			}  catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {stmt.close();stmt = null;} catch (Exception e) {	}
			}
		}
		
		
		//*************************************************
		public static byte[] compress(byte[] input){
			
		    Deflater df = new Deflater();
		    df.setLevel(Deflater.BEST_COMPRESSION);
		    df.setInput(input);

		    ByteArrayOutputStream baos = new ByteArrayOutputStream(input.length);
		    df.finish();
		    byte[] buff = new byte[1024];
		    while (!df.finished()) {
		        int count = df.deflate(buff);
		        baos.write(buff, 0, count);
		    }
		    try {
				baos.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		    byte[] output = baos.toByteArray();

		    return output;
		}
		
		
		//*************************************************
		public static byte[] compress(String data){
			byte[] input;
			try {
				input = data.getBytes();
			} catch (Exception e) {
				e.printStackTrace();
				return null;
			}
		    return compress(input);
		}
		
		//********************************************
		String sql_FOR_setBinInfo=null;
		
		void setBinInfo(Connection conn, String table_name, long id, String field_name, StringBuilder sb_info) {
			
			
			
			if (sb_info.length()==0) return;
			
			byte[] compressed=compress(sb_info.toString());
			
			if (sql_FOR_setBinInfo==null)
				sql_FOR_setBinInfo="update "+table_name+" set "+field_name+" =? where id=?";
			
			
			PreparedStatement stmt=null;
			try {
				stmt = conn.prepareStatement(sql_FOR_setBinInfo);
				stmt.setBytes(1, compressed);
				stmt.setLong(2, id);
				stmt.executeUpdate();
			}  catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {stmt.close();stmt = null;} catch (Exception e) {	}
			}
		}
			
		
		//********************************************
		
		String sql_FOR_IncreaseRetryCount=null;
		
		void IncreaseRetryCount(Connection conn, String table_name, long id) {

			if (sql_FOR_IncreaseRetryCount==null)
				sql_FOR_IncreaseRetryCount="update "+table_name+" set retry_count=retry_count+1 where id=? ";
			
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			bindlist.add(new String[]{"LONG",""+id});
			execSingleUpdateSQL(conn, sql_FOR_IncreaseRetryCount, bindlist);
			
		}
		//*****************************
		public void sleep(long milis) {
			try {
				Thread.sleep(milis);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		
		//----------------------------------------------------------
		public String normalize(String val) {
			String normal_chars="ABCDEFGHIJKLMNOPQRSTUWXYZabcdefghijklmnopqrstuwxyz0123456789";
			String val1=val.toUpperCase();
			char[] arr=val1.toCharArray();
			for (int i=0;i<val1.length();i++) {
				String cin=val1.substring(i,i+1);
				if (normal_chars.indexOf(cin)==-1) {
					String cout=""+replaceChar(cin);
					if (cin.equals(cout)) cout=" ";
					arr[i]=cout.charAt(0);
				}
			}
			
			return new String(arr).replace(" ", "");
			
		}
		//----------------------------------------------------------

		public static byte[] hexStringToByteArray(String s) {
		    int len = s.length();
		    byte[] data = new byte[len / 2];
		    for (int i = 0; i < len; i += 2) {
		        data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
		                             + Character.digit(s.charAt(i+1), 16));
		    }
		    return data;
		}
		//----------------------------------------------------------

		private static final char replaceChar(String in) {
			
			String a="çÇðÐýÝöÖþÞüÜ";
			String b="CCGGIIOOSSUU";
			
			int pos=a.indexOf(in);
			
			if (pos==-1) return in.charAt(0);
			return b.charAt(pos);
		}
		//----------------------------------------------------------
		final String[]  table_list=new String[] {"tdm_manager","tdm_master","tdm_worker"};
		
		public void heartbeat(Connection conn, int table_id,long rec_cnt, int id) {
			
			boolean is_db_closed=false;
			try{is_db_closed=conn.isClosed();} catch(Exception e) {is_db_closed=true;}
			
			if (is_db_closed) return;
			
			if ((System.currentTimeMillis() - last_heartbeat) > HEARTBEAT_INTERVAL) {
				
				String sql = "";
				
				String table=table_list[table_id-1];
				
				ArrayList<String[]> bindlist = new ArrayList<String[]>();
				
				sql="update "+table+" set last_heartbeat=?  where id=?";
				if (table.equals("tdm_manager") ) {
					sql="update "+table+" set last_heartbeat=?";
					bindlist.add(new String[]{"TIMESTAMP",""+System.currentTimeMillis()});
				}
				else {
					bindlist.add(new String[]{"TIMESTAMP",""+System.currentTimeMillis()});
					bindlist.add(new String[] { "INTEGER", ""+id});
				}
				
				execSingleUpdateSQL(conn, sql, bindlist);
				
				mylog(LOG_LEVEL_INFO, table + "[j.pid="+id+"] heap:%"+heapUsedRate()+" heartbeat...@" + (new Date()));
				
				last_heartbeat = System.currentTimeMillis();
			}
		}
		
	//---------------------------------------
	public int heapUsedRate() {
		Runtime runtime = Runtime.getRuntime();
		int ret1=Math.round(100* (runtime.totalMemory()-runtime.freeMemory())  / runtime.maxMemory());
		runtime=null;
		return ret1;
	}
	
	final String TASK_STATUS_NEW="NEW";
	final String TASK_STATUS_RUNNING="RUNNING";
	final String TASK_STATUS_FINISHED="FINISHED";
	final String TASK_STATUS_FAILED="FAILED";
	final String TASK_STATUS_RETRY="RETRY";
	final String TASK_STATUS_TOUCH="TOUCH";


	//---------------------------------------
	public void setTaskStatus(Connection conn, int work_plan_id, int work_package_id, long task_id, String status, int worker_id) {
		setTaskStatus(conn, work_plan_id, work_package_id, task_id, worker_id, status, 0, 0, 0);
	}
	
	
	
	//----------------------------------------
	public void setTaskStatus(
			Connection conn, 
			int work_plan_id, 
			int work_package_id, 
			long task_id, 
			int worker_id, 
			String status, 
			int success_count, 
			int fail_count,	
			long duration
			) {
		StringBuilder sql=new StringBuilder();
		sql.append("update tdm_task_"+work_plan_id+"_"+work_package_id + " set status=? ");
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"STRING",status});
		
		//NEW  => RENEW
		if (status.equals(TASK_STATUS_NEW)) {
			sql.append(" ,worker_id=null, start_date=null, end_date=null, "+
					" last_activity_date=now(), duration=null, success_count=0, fail_count=0, done_count=0,"+
					" log_info_zipped=null, err_info_zipped=null "
					);

		}
		else  if (status.equals(TASK_STATUS_RETRY)) {
			sql.append(" ,worker_id=null, end_date=now(), last_activity_date=now(), duration=?, success_count=?, fail_count=?, done_count=? "
					);
		bindlist.add(new String[]{"INTEGER",""+duration});
		bindlist.add(new String[]{"INTEGER",""+success_count});
		bindlist.add(new String[]{"INTEGER",""+fail_count});
		bindlist.add(new String[]{"INTEGER",""+(success_count+fail_count)});
			
		}
		else  if (status.equals(TASK_STATUS_RUNNING)) {
			sql.append(" ,worker_id=?, assign_date=now(), start_date=now(), end_date=null, "+
						" last_activity_date=now(), duration=null "
						);
			bindlist.add(new String[]{"INTEGER",""+worker_id});
			
		}
		else  if (status.equals(TASK_STATUS_FINISHED)) {
			sql.append(" ,worker_id=null, end_date=now(), "+
						" last_activity_date=now(), duration=?, success_count=?, fail_count=?, done_count=? "
						);
			bindlist.add(new String[]{"INTEGER",""+duration});
			bindlist.add(new String[]{"INTEGER",""+success_count});
			bindlist.add(new String[]{"INTEGER",""+fail_count});
			bindlist.add(new String[]{"INTEGER",""+(success_count+fail_count)});
			
	
		}
		else  if (status.equals(TASK_STATUS_TOUCH)) {
			sql.append(" ,last_activity_date=now()" );
		
			
		}
		sql.append(" WHERE id=? ");
		bindlist.add(new String[]{"LONG",""+task_id});
		
		
		execSingleUpdateSQL(conn, sql.toString(), bindlist);
		
		
		
		
	}
	
	
	//--------------------------------------------------------------------------------------------
	
	final String WORK_PACKAGE_STATUS_NEW="NEW";
	final String WORK_PACKAGE_STATUS_EXPORTING="EXPORTING";
	final String WORK_PACKAGE_STATUS_MASKING="MASKING";
	final String WORK_PACKAGE_STATUS_FINISHED="FINISHED";
	final String WORK_PACKAGE_STATUS_FAILED="FAILED";
	final String WORK_PACKAGE_STATUS_TOUCH="TOUCH";

	//-----------------------------------------------------------------------------------------------
	String getWorkPackageStatus(Connection conn, int work_package_id) {
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		String sql="select status from tdm_work_package where id=?  limit 0,1";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+work_package_id});
		ArrayList<String[]> arr=getDbArray(conn, sql, 1, bindlist);
		if (arr!=null && arr.size()==1) return arr.get(0)[0];
		return "UNKNOWN";
	}
	//-----------------------------------------------------------------------------------------------
	void setWorkPackageStatus(Connection conn, int work_plan_id, int work_package_id, int master_id, String status) {
	
		StringBuilder sql=new StringBuilder();
		sql.append("update tdm_work_package set status=? ");
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"STRING",status});
	
		//renew 
		if (status.equals(WORK_PACKAGE_STATUS_NEW)) {
			sql.append(" ,master_id=null, assign_date=null, start_date=null, end_date=null, last_activity_date=null, duration=null, "
					+ " export_count=0, all_count=0, done_count=0, success_count=0, fail_count=0, err_info=null  ");
			
			mylog(LOG_LEVEL_WARNING, "Renewing work package "  + work_package_id + ". So truncating task table...");
			String trunc_sql="truncate table tdm_task_"+work_plan_id+"_"+work_package_id;
			execSingleUpdateSQL(conn, trunc_sql, null);
			
		}
		
		if (status.equals(WORK_PACKAGE_STATUS_EXPORTING)) {
			sql.append(" ,master_id=?, start_date=now(), last_activity_date=now() ");
			bindlist.add(new String[]{"INTEGER",""+master_id});
		}
		
		if (status.equals(WORK_PACKAGE_STATUS_MASKING)) {
			sql.append(" , last_activity_date=now() ");
		}
		
		if (status.equals(WORK_PACKAGE_STATUS_FINISHED)) {
			sql.append(" ,master_id=null, end_date=now(), last_activity_date=now(), duration=TIMESTAMPDIFF(SECOND, start_date, end_date)*1000 ");
		}
		
		if (status.equals(WORK_PACKAGE_STATUS_FAILED)) {
			sql.append(" ,master_id=null, end_date=now(), last_activity_date=now(), duration=TIMESTAMPDIFF(SECOND, start_date, end_date)*1000 ");
		}
		
		if (status.equals(WORK_PACKAGE_STATUS_TOUCH)) {
			sql.setLength(0);
			sql.append("update tdm_work_package set  last_activity_date=now() ");
			
			bindlist.clear();
		}
		
		sql.append(" WHERE id=?");
		bindlist.add(new String[]{"INTEGER",""+work_package_id});
		
		mylog(LOG_LEVEL_INFO,"Updating work package ["+work_package_id+"] status to " + status);
		execSingleUpdateSQL(conn, sql.toString(), bindlist);
		
	}
	
	//************************************
	void setworkPackageError(Connection conn, int err_work_plan_id, int err_work_package_id, String err) {
		String sql="update tdm_work_package set err_info=? where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"STRING",""+err});
		bindlist.add(new String[]{"INTEGER",""+err_work_package_id});
		
		execSingleUpdateSQL(conn, sql, bindlist);
	}
	
	//------------------------------------------------------------------------------
	MongoClient getMongoClient(Connection conn, int env_id) {
		String sql="select db_connstr from tdm_envs where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",""+env_id});
		ArrayList<String[]> arr=getDbArray(conn, sql, 1, bindlist);
		if (arr==null || arr.size()==0) return null;
		
		String url=arr.get(0)[0];
		try {
			MongoClientURI muri=new MongoClientURI(url);
			MongoClient mongoClient = new MongoClient(muri);
			mylog(LOG_LEVEL_WARNING, "Connected to Mongo.");
			return mongoClient;
		} catch(Exception e) {
			mylog(LOG_LEVEL_DANGER, "Exception@getMongoClient : "+e.getMessage());
			e.printStackTrace();
			return null;
		}
		
	}
	
	//-----------------------------------------------------------
	ArrayList<String> getDBList(MongoClient mongo) {
		ArrayList<String> ret1=new ArrayList<String>();
		try {
			
			for (String dbname : mongo.listDatabaseNames()) {
				ret1.add(dbname);
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		
		return ret1;
	}
	
	//-----------------------------------------------------------------------
	MongoDatabase getMongoDB(MongoClient mongo, String dbname) {
		
		ArrayList<String> dblist=getDBList(mongo);
		if (dblist.indexOf(dbname)==-1) {
			mylog(LOG_LEVEL_DANGER, "MONGO DB is not available to use: "+dbname);
			return null;
			}
		
		
		return mongo.getDatabase(dbname);
		
	}
	//--------------------------------------------------------------------------
	String getDbTypeByEnvId(Connection conn, int env_id) {
		
		String sql="select db_driver from tdm_envs where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",""+env_id});
		ArrayList<String[]> arr=getDbArray(conn, sql, 1, bindlist);
		if (arr==null || arr.size()==0) return "UNKNOWN";
		
		
		String db_driver=arr.get(0)[0];
		
		
		return getDbType(conn,db_driver);
	}
	
	
	//******************************************************
	String extractCopyTarget(String target_info, String full_table_name) {
		
		String catalog_name="";
		String schema_name="";
		String tab_name=full_table_name;
		
		if (full_table_name.contains(".")) {
			catalog_name=full_table_name.split("\\.")[0];
			schema_name=full_table_name.split("\\.")[1];
			tab_name=full_table_name.split("\\.")[2];
		}
		

		String[] targets=target_info.split("\n|\r");
		
		for (int t=0;t<targets.length;t++) {
			String a_target=targets[t];
			if (a_target.contains("*") && a_target.contains("[") && a_target.contains("]")) {
				String a_orig_part=a_target.split("\\[")[0].split("\\*")[1];
				if (a_orig_part.contains(".")) {
					String a_orig_catalog=a_orig_part.split("\\.")[0];
					String a_orig_schema=a_orig_part.split("\\.")[1];
					String a_orig_table=a_orig_part.split("\\.")[2];
					
					if (a_orig_catalog.toLowerCase().equals(catalog_name.toLowerCase()) &&  a_orig_schema.toLowerCase().equals(schema_name.toLowerCase()) && a_orig_table.toLowerCase().equals(tab_name.toLowerCase())) {
						String a_new_table=a_target.split("\\[")[1].split("\\]")[0].split(":")[1];
						if (a_new_table.contains(".")) {
							catalog_name=a_new_table.split("\\.")[0];
							schema_name=a_new_table.split("\\.")[1];
							tab_name=a_new_table.split("\\.")[2];
							break;
						}
						
					}
				}
				
			}
			
		} // for t
		
		return catalog_name+"."+schema_name+"."+tab_name;
	}
	
	
	
	//******************************************************
	String extractCopySource(String target_info, String full_table_name) {
		
		String catalog_name="";
		String schema_name="";
		String tab_name=full_table_name;
		
		if (full_table_name.contains(".")) {
			catalog_name=full_table_name.split("\\.")[0];
			schema_name=full_table_name.split("\\.")[1];
			tab_name=full_table_name.split("\\.")[2];
		}
		

		String[] targets=target_info.split("\n|\r");
		
		for (int t=0;t<targets.length;t++) {
			String a_target=targets[t];
			if (a_target.contains("*") && a_target.contains("[") && a_target.contains("]")) {
				String a_orig_part=a_target.split("\\[")[0].split("\\*")[1];
				if (a_orig_part.contains(".")) {
					String a_orig_catalog=a_orig_part.split("\\.")[0];
					String a_orig_schema=a_orig_part.split("\\.")[1];
					String a_orig_table=a_orig_part.split("\\.")[2];
					
					if (a_orig_catalog.equals(catalog_name) &&  a_orig_schema.equals(schema_name) && a_orig_table.toLowerCase().equals(tab_name.toLowerCase())) {
						String a_new_table=a_target.split("\\[")[1].split("\\]")[0].split(":")[0];
						if (a_new_table.contains(".")) {
							catalog_name=a_new_table.split("\\.")[0];
							schema_name=a_new_table.split("\\.")[1];
							tab_name=a_new_table.split("\\.")[2];
							break;
						}
						
					}
				}
				
			}
			
		} // for t
		
		return catalog_name+"."+schema_name+"."+tab_name;
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
	
	
	static final String SQL_FOR_FIELDS_ORACLE="select column_name, data_type, data_length from all_tab_columns where '${default}'=? and owner=? and table_name=? order by column_id";
	static final String SQL_FOR_FIELDS_MSSQL="select column_name,data_type,CHARACTER_MAXIMUM_LENGTH from INFORMATION_SCHEMA.columns where table_catalog=? and table_schema=? and table_name=? order by ordinal_position";
	static final String SQL_FOR_FIELDS_MYSQL="select column_name,data_type,CHARACTER_MAXIMUM_LENGTH from INFORMATION_SCHEMA.columns where table_schema=? and table_schema=? and table_name=? order by ordinal_position";
	
	
	static final String SQL_FOR_PK_FIELDS_ORACLE="SELECT cols.column_name "+
												"	FROM all_constraints cons, all_cons_columns cols "+
											    "	WHERE '${default}'=? and cols.owner=? and cols.table_name=? "+
												"	AND cons.constraint_type = 'P' "+
												"	AND cons.constraint_name = cols.constraint_name "+
												"	AND cons.owner = cols.owner";
	static final String SQL_FOR_PK_FIELDS_MSSQL="SELECT COLUMN_NAME "+
												"	FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE "+
												"	WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME), 'IsPrimaryKey') = 1 "+
												"	AND TABLE_CATALOG=? AND TABLE_SCHEMA  = ? and  TABLE_NAME =?";
	static final String SQL_FOR_PK_FIELDS_MYSQL=" SELECT column_name "+
												"	FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE "+
												"	where constraint_name='PRIMARY' and table_schema=? and table_schema=? and table_name=?";
	
	
	//*************************************************************
	public ArrayList<String[]> getFieldListFromDb(Connection conn, String catalog, String owner, String table, String db_type) {
	//*************************************************************
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		setCatalogForConnection(conn, catalog);
		
		String sql="";
		if (db_type.equals("ORACLE") ) sql=SQL_FOR_FIELDS_ORACLE;
		else if (db_type.equals("MSSQL") ) sql=SQL_FOR_FIELDS_MSSQL;
		else if (db_type.equals("MYSQL") ) sql=SQL_FOR_FIELDS_MYSQL;
		else return ret1;
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"STRING",catalog});
		bindlist.add(new String[]{"STRING",owner});
		bindlist.add(new String[]{"STRING",table});
		
		ArrayList<String[]> cols=getDbArray(conn, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<cols.size();i++) {
			String f_name=cols.get(i)[0];
			String f_type=cols.get(i)[1];
			String f_size=cols.get(i)[2];
			String f_is_pk="NO";
			
			
			
			ret1.add(new String[]{f_name, f_type, f_size, f_is_pk});
			
		}
		
		
		
		sql="";
		if (db_type.equals("ORACLE") ) sql=SQL_FOR_PK_FIELDS_ORACLE;
		else if (db_type.equals("MSSQL") ) sql=SQL_FOR_PK_FIELDS_MSSQL;
		else if (db_type.equals("MYSQL") ) sql=SQL_FOR_PK_FIELDS_MYSQL;
		else return ret1;
		
		bindlist.clear();
		bindlist.add(new String[]{"STRING",catalog});
		bindlist.add(new String[]{"STRING",owner});
		bindlist.add(new String[]{"STRING",table});
		
		ArrayList<String[]> pks=getDbArray(conn, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<ret1.size();i++) {
			String f_name=ret1.get(i)[0];
			String f_type=ret1.get(i)[1];
			String f_size=ret1.get(i)[2];
			String f_is_pk=ret1.get(i)[3];
			
			for (int p=0;p<pks.size();p++) {
				String pk_col_name=pks.get(p)[0];
				if (f_name.equals(pk_col_name)) {
					f_is_pk="YES";
					break;
				}
			}
			
			
			ret1.set(i, new String[]{f_name, f_type, f_size, f_is_pk});
			
		}
		
		
		return ret1;

	}
	
	
	
	/*
	//*************************************************************
	public ArrayList<String[]> getFieldListFromDb(Connection conn, String catalog, String owner, String table, String db_type) {
	//*************************************************************

		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		DatabaseMetaData md=null;
		
		String f_name="";
		String f_type="";
		String f_size="";
		String f_is_pk="";
		String f_catalog="";
		String f_schema="";
		String f_table="";
		
		
		ArrayList<String> pklist=new ArrayList<String>();

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
			
		 
		

		String[] type_filter=new String[] {"TABLE"};
		
		if (conn!=null) {
				ResultSet rs = null;

				try {

					md = conn.getMetaData();
					//JBASE 
					if (owner.length()>0 || owner.equals("null"))
						rs = md.getColumns(null, null, table, null);
					else 
						rs = md.getColumns(conn.getCatalog(), owner, table, null);
					
					int c=0;
					
					while (rs.next()) {
						boolean is_added=false;
						c++;
						f_name=rs.getString("COLUMN_NAME"); //4
						f_type=rs.getString("TYPE_NAME");
						f_size=rs.getString("COLUMN_SIZE");
						f_schema=opAutoLib.nvl(rs.getString("TABLE_SCHEM"),"");
						f_table=opAutoLib.nvl(rs.getString("TABLE_NAME"),"");
						
						f_is_pk="NO";
						
						if (!f_schema.equals(owner) || !f_table.equals(table)) {
							//System.out.println("Skip for different table column..."+f_schema+"."+f_table);
									
							continue;
						}
						

						
						for (int p=0;p<pklist.size();p++)
							if (f_name.equals(pklist.get(p))) 
								f_is_pk="YES";
						
						//for some tables (partitioned eg.) column names may be duplicated
						for (int f=0;f<ret1.size();f++)
							if (f_name.equals(ret1.get(f)[0])) is_added=true;
							
						String[] arr=new String[]{f_name, f_type, f_size, f_is_pk};
						if (!is_added) ret1.add(arr);
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
	*/
	
	//****************************************************************************
	void setTaskContentNull(Connection conn,String task_table, long task_id) {
		String sql="update  "+ task_table+  " set log_info_zipped=null where id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"LONG",""+task_id});
		
		execSingleUpdateSQL(conn, sql, bindlist);

		
	}
	
	//****************************************************************************
	int getExecutionOrderOfWpc(Connection conn, int id) {
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		String sql="select execution_order from tdm_work_package where id=? limit 0,1";
		bindlist.add(new String[]{"INTEGER",""+id});
		
		ArrayList<String[]> arr=getDbArray(conn, sql, 1, bindlist);
		
		if (arr==null || arr.size()==0) return -1;
		
		int ret1=-1;
		try {ret1=Integer.parseInt(arr.get(0)[0]);} catch(Exception e) {return ret1;}
		
		
		
		return ret1;
	}
	
	
	//****************************************************************************
	void setExecutionOrderOfWpc(Connection conn,int id, int execution_order) {
		String sql="update tdm_work_package set execution_order=?, end_date=null where id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",""+execution_order});
		bindlist.add(new String[]{"INTEGER",""+id});
		
		execSingleUpdateSQL(conn, sql, bindlist);

		
	}
	
	//*****************************************************************************
	void setCatalogForConnection(Connection conn, String cat) {
		if (cat.length()==0 || cat.equals("${default}")) return;
			
			String curr_cat="";
			try { curr_cat=genLib.nvl(conn.getCatalog(),"");} catch(Exception e) {e.printStackTrace();}
			
			if (!curr_cat.equals(cat)) {
				System.out.println("setting catalog to ="+cat);
				try { conn.setCatalog(cat);} catch(Exception e) {e.printStackTrace();}	
			}
				
		
	}
	
	
	//*****************************************************************************

	public void myloggerBase(StringBuilder sblog, StringBuilder sberr,  byte log_level, String logstr) {
		if (log_level<=CURRENT_LOG_LEVEL) 
			System.out.println(""+new Date()+" >" + logstr);
		
		
		try {
			if (sblog.length()>MAX_LONG_LENGTH) 
				sblog.setLength(0);

			sblog.append(""+new Date()+" >" + logstr);
			sblog.append("\r");

		if (logstr.contains("xception") || logstr.contains("error")) {
				
				if (sberr.length()>MAX_LONG_LENGTH)
					sberr.setLength(0);


				sberr.append(""+new Date()+" >" + logstr);
				sberr.append("\r");
			}
		}
		catch(Exception e) {
			
		}
		
		
		
	}
	
	
	
}
