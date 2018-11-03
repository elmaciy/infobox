package com.mayatech.datapool;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

import com.mayatech.baseLibs.genLib;

public final  class poolLib {
	
	//---------------------------------------------------------------------------
	
	static void mylog(String logstr) {
		System.out.println(logstr);

	}
	
	static void mydebug(String logstr) {
		
		//System.out.println(logstr);
		
	}
	
	
	
	//----------------------------------------------------------

	
	
	
	
	
	
	//---------------------------------------------------------------------------
	
		
	
	//---------------------------------------------------------------------------
	
	
	
	
	
	
	
	
	
	
	
	
		
	//*********************************************

	 //**************************************************
	static boolean testRegexMatch(String val_to_test, String regex_expr, String case_sensitivity) {
		
		Pattern pattern=null;
		Matcher matcher =null;
		
		try {
			if (case_sensitivity.equals("YES"))
				pattern=Pattern.compile(regex_expr);
			else 
				pattern=Pattern.compile(regex_expr,Pattern.CASE_INSENSITIVE);
			
			matcher = pattern.matcher(val_to_test);
			if (matcher.find()) return true;
		} catch(Exception e) {
			e.printStackTrace();
			return false;
		}
		
		return false;
		
	}
	
	
	
	
	
	
	
	
	
	
	
		
	
	
	
	
	//*************************************************************************
	static int getArrIndex(String[] arr, String el) {
		for (int i=0;i<arr.length;i++) {
			
			//mylog(" \t\t Testing "+arr[i]+ " and "  + el + " "  + arr[i].toUpperCase().indexOf(el.toUpperCase()));
			if (
					
						//tam esitlik aramasi
						arr[i].toUpperCase().equals(el.toUpperCase()) 
					|| 
						(
								//icinde nokta olmasi durumunda 
								arr[i].lastIndexOf(".")>-1
								&&
								arr[i].toUpperCase().indexOf(el.toUpperCase())-1==arr[i].lastIndexOf(".") 
						)
						
						//"fieldname alias" aramasi
					||  arr[i].replaceAll("\n|\r|\t", " ").toUpperCase().trim().endsWith(" "+el.toUpperCase().trim())
					) return i;
		}
			
		return -1;
	}
	
	
	
	
	
	
	
	
	
	
	
	


	
	
	//***************************************************************************
	
	//****************************************************************************
	public static ArrayList<String[]> getDbArray(
			Connection conn, 
			String sql, 
			int limit,
			ArrayList<String[]> bindlist, 
			int timeout_insecond) {
		return getDbArray(conn, sql, limit, bindlist, timeout_insecond,null);
	}
	
	//****************************************************************************
	public static ArrayList<String[]> getDbArray(
			Connection conn, 
			String sql, 
			int limit,
			ArrayList<String[]> bindlist, 
			int timeout_insecond,
			ArrayList<String> colList) {
		
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
			
			if (colList!=null)
				for (int i=1;i<=colcount;i++) {
					String col_name=rsmdConf.getColumnLabel(i);
					colList.add(col_name);
				}	
			
			String a_field = "";
			while (rsetConf.next()) {
				reccnt++;
				if (reccnt > limit) break;
				String[] row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {
					try {
						a_field = rsetConf.getString(i);
						
						if (a_field.equals("null")) a_field=""; 
						if (a_field.length()>100000) a_field=a_field.substring(0,100000);
						} 
					catch (Exception enull) {a_field = "";}
					row[i - 1] = a_field;
				}
				ret1.add(row);
			}
		} catch(SQLException sqle) {
			sqle.printStackTrace();
			mylog("Exception@getDbArray : SQL       => " + sql);
			mylog("Exception@getDbArray : MSG       => " + sqle.getMessage());
			mylog("Exception@getDbArray : CODE      => " + sqle.getErrorCode());
			mylog("Exception@getDbArray : SQL STATE => " + sqle.getSQLState());
		}
		catch (Exception ignore) {
			ignore.printStackTrace();
			mylog("Exception@getDbArray : SQL => " + sql);
			mylog("Exception@getDbArray : MSG => " + ignore.getMessage());
		} finally {
			try {rsmdConf = null;} catch (Exception e) {}
			try {rsetConf.close();rsetConf = null;} catch (Exception e) {}
			try {pstmtConf.close();	pstmtConf = null;} catch (Exception e) {}
		}
		return ret1;
	}
	
	
	//****************************************		
	static public boolean execSingleUpdateSQL(Connection conn, String sql,ArrayList<String[]> bindlist) {
		
		return execSingleUpdateSQL(conn,sql,bindlist,true, 0);
		
	}

	//****************************************		
	static public boolean execSingleUpdateSQL(Connection conn, String sql,ArrayList<String[]> bindlist, int timeout_as_sec) {
		
		return execSingleUpdateSQL(conn,sql,bindlist,true, timeout_as_sec);
		
	}
	
	//****************************************
	static public boolean execSingleUpdateSQL(
			Connection conn, 
			String sql,
			ArrayList<String[]> bindlist, 
			boolean commit_after, 
			int timeout_as_sec) {

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

			mydebug("Executing SQL : " + sql + " using " + using.toString());

			pstmt_execbind.executeUpdate();

			
			if (!conn.getAutoCommit() && commit_after) 	{
				conn.commit();
			}


		} catch (Exception e) {
			mylog("Exception@execSingleUpdateSQL : " + e.getMessage());
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
	
	//----------------------------------------------------------------------
	public static String nvl(String in, String out) {
		String r = "";
		try {
			r=in;
			if (r.equals("null")) r="";
		} catch (Exception e) {
			r = "";
		}

		if (r.length() == 0)
			r = out;

		return r;
	}
	
	
	
	
	//----------------------------------------------------------------------
	
	static ScriptEngineManager factory=null;
	static ScriptEngine engine=null;
	
	static boolean checkJSCode(String js_code, String param) {
		StringBuilder sb=new StringBuilder();
		sb.append(js_code);
		while(true) {
			int ind=-1;
			ind=sb.indexOf("${1}");
			if (ind==-1) break;
			sb.delete(ind, ind+4);
			sb.insert(ind, param);
		}
		
		try {
			if (factory==null) 	{
				factory = new ScriptEngineManager();
				engine = factory.getEngineByName("JavaScript");
				}
			
			try {
				String tmpval=""+engine.eval(sb.toString());
				boolean ret1=Boolean.parseBoolean(tmpval);
				return ret1;
			} catch (Exception e) {
				
			}
		} catch(Exception e) {
			return false;
		}
		
		return false;
		
	}
	
	
	// *****************************************
	static public Connection getDBConnection(String ConnStr, String Driver, String User, String Pass, int retry_count) {
		
		Connection ret1 = null;
		
		
		mylog("Connecting to : ");
		mylog("driver     :["+Driver+"]");
		mylog("connstr    :["+ConnStr+"]");
		mylog("user       :["+User+"]");
		mylog("pass       :["+"************]");	




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
				mylog("Exception@getconn : " + ignore.getMessage());
				ignore.printStackTrace();
				ret1=null;
				mylog("sleeping ...");
				
				try{Thread.sleep(5000);} catch(Exception e) {}
			}
			
			mylog("Connection is failed to db : retry("+retry+") ");
			mylog("driver     :"+Driver);
			mylog("connstr    :"+ConnStr);
			mylog("user       :"+User);
			mylog("pass       :"+"************");
			mylog("Sleeping...");
			
			
			
		}
		
		return ret1;
	}
	
	
}
