package com.mayatech.maskdisc;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import com.mayatech.baseLibs.genLib;

public final  class mDiscLib {
	
	//---------------------------------------------------------------------------
	
	static void mylog(String logstr) {
		System.out.println(logstr);

	}
	
	static void mydebug(String logstr) {
		
		//System.out.println(logstr);
		
	}
	
	
	//****************************************************************************
	public static ArrayList<String[]> getDbArray(
			Connection conn, 
			String sql, 
			int limit,
			ArrayList<String[]> bindlist, 
			int timeout_insecond) {
		return getDbArray(conn, sql, limit, bindlist, timeout_insecond,null, null);
	}
	
	//****************************************************************************
	public static ArrayList<String[]> getDbArray(
			Connection conn, 
			String sql, 
			int limit,
			ArrayList<String[]> bindlist, 
			int timeout_insecond,
			ArrayList<String> colList,
			ArrayList<String> colTypeList
			) {
		
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
			
			try{pstmtConf.setFetchSize(1000);} catch(Exception e) {}
			
			if (rsetConf == null) 
				rsetConf = pstmtConf.executeQuery();
			
			if (rsmdConf == null) 
				rsmdConf = rsetConf.getMetaData();

			int colcount = rsmdConf.getColumnCount();
			
			if (colList!=null)
				for (int i=1;i<=colcount;i++) {
					String col_name=rsmdConf.getColumnLabel(i);
					colList.add(col_name);
				}	
			
			if (colTypeList!=null)
				for (int i=1;i<=colcount;i++) {
					String col_type=rsmdConf.getColumnTypeName(i)+"("+rsmdConf.getColumnDisplaySize(i)+")";
					colTypeList.add(col_type);
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
						if (a_field.length()>2000) a_field=a_field.substring(0,2000);
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
	//***********************************************************************************************************************
	static boolean isTableEmpty(maskDiscServer discServer, Connection conn, String owner, String table) {
		boolean ret1=true;
		
		String hkey=owner+"."+table;
		
		if (discServer.hmIsEmptyTable.containsKey(hkey)) ret1=(Boolean) discServer.hmIsEmptyTable.get(hkey);
		else {
			String sql="select 1 from \""+owner+"\".\""+table+"\"";
			
			if (discServer.isMssql()) sql="select top 1  1 from \""+owner+"\".\""+table+"\" with (NOLOCK)";
			if (discServer.isMysql()) sql="select 1 from "+owner+"."+table+" limit 0,1";
			
			System.out.println("isTableEmpty sql : " + sql);
			
			ArrayList<String[]> tmpArr=getDbArray(conn, sql, 1, null, 10);
			if (tmpArr.size()==1) ret1=false;
			
			discServer.hmIsEmptyTable.put(hkey,ret1);
		}
		
		return ret1;
	}
	//***********************************************************************************************************************
	static String getDataTypeName(Connection conn, String catalog, String owner, String table, String column) {
		String ret1="";
		
		DatabaseMetaData md =null;
		ResultSet rs = null;
		ArrayList<String[]> allColumns=new ArrayList<String[]>();
		
		try {
			md = conn.getMetaData();
			rs = md.getColumns(catalog, owner, table, column);
			while( rs.next( ) ) 
			{    
				  ret1 = rs.getString("TYPE_NAME");
				  break;
			}
			
			
			
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {rs.close();}catch(Exception e) {e.printStackTrace();}
		}
		
		return ret1;
	}
	
	//***********************************************************************************************************************
	static ArrayList<String[]> getPrimaryKeyFields(maskDiscServer discServer, Connection conn, String catalog, String owner, String table) {
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		String hkey=catalog+"."+owner+"."+table;
		
		if (discServer.pkList.containsKey(hkey)) ret1=(ArrayList<String[]>) discServer.pkList.get(hkey);
		else {
			DatabaseMetaData md =null;
			ResultSet rs = null;
			try {
				md = conn.getMetaData();
				rs = md.getPrimaryKeys( catalog , owner , table);
				while( rs.next( ) ) 
				{    
				  String pkey = rs.getString("COLUMN_NAME");
				  String pkey_type_name=getDataTypeName(conn,catalog,owner,table,pkey);
				  ret1.add(new String[]{pkey,pkey_type_name});
				}
				
				
				
			} catch(Exception e) {
				e.printStackTrace();
			} finally {
				try {rs.close();}catch(Exception e) {e.printStackTrace();}
			}
			
			discServer.pkList.put(hkey,ret1);
			
		}
		
		return ret1;
	}
	
	
	//***********************************************************************************************************************

	static ArrayList<String[]> buildCartesian(ArrayList<ArrayList<String>> list) {
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		
		int pk_count=list.size();
		int el_count=1;
		
		for (int i=0;i<pk_count;i++) 
			el_count=el_count*list.get(i).size();
		
		//System.out.println("array size ="+el_count);
		
		//allocate array
		for (int i=0;i<el_count;i++) {
			String[] tmpArr=new String[pk_count];
			ret1.add(tmpArr);
		}
		
		
		
		
		for (int pk=0;pk<pk_count;pk++) {
			
			ArrayList<String> tmpList=list.get(pk);
			int col_count=tmpList.size();
			
			int repeat=pk+1;
			
			int index=0;
			int col_no=0;
			
			while(index<el_count) {
				
				for (int r=0;r<repeat;r++) {
					if (index>=el_count) break;
					
					String[] element=ret1.get(index);
					element[pk]=tmpList.get(col_no);
					ret1.set(index, element);
					
					index++;
				}
				
				col_no++;
				if (col_no>=col_count) col_no=0;
				
			} //while(index<el_count)
			
		
			
		}
		
		//remove duplicates
		ArrayList<String> hashList=new ArrayList<String>();
		for (int i=0;i<el_count;i++) {
			long hash=0;
			for (int k=0;k<pk_count;k++) {
				hash+=ret1.get(i)[k].hashCode();
			}
			hashList.add(""+hash);
		}
		for (int i=el_count-1;i>=0;i--) 
			if (hashList.indexOf(hashList.get(i))<i) ret1.remove(i);
		
		
		
		el_count=ret1.size();
		
		//remove rows with duplicate cols
		for (int i=el_count-1;i>=0;i--) {
			String[] strArr=ret1.get(i);
			boolean has_dup_col=false;
			
			for (int x=0;x<strArr.length;x++) {
				for (int y=x+1;y<strArr.length;y++) {
					if (strArr[x].equals(strArr[y])) {
						has_dup_col=true;
						break;
					}
				}
				
				if (has_dup_col) break;
			}
			
			if (has_dup_col) ret1.remove(i);
		}
		return ret1;
	}
	
	//***********************************************************************************************************************
	static ArrayList<String[]> getColumnNamesCombination(maskDiscServer discServer, Connection conn, String catalog, String owner, String table, ArrayList<String[]> compPKFields) {
		ArrayList<String[]> ret1=new ArrayList<String[]>(); 
		
		DatabaseMetaData md =null;
		ResultSet rs = null;
		ArrayList<String[]> allColumns=new ArrayList<String[]>();
		
		ArrayList<String[]> pkColList=getPrimaryKeyFields(discServer, conn, catalog, owner, table);
		
		try {
			md = conn.getMetaData();
			rs = md.getColumns(catalog, owner, table, null);
			while( rs.next( ) ) 
			{    
				  String column_name = rs.getString("COLUMN_NAME");
				  String type_name = rs.getString("TYPE_NAME");
				  String is_nullable = rs.getString("IS_NULLABLE");
				 
				  boolean is_pk=false;
				  
				  for (int pk=0;pk<pkColList.size();pk++) {
					  String pk_col_name=pkColList.get(pk)[0];
					  if (pk_col_name.equals(column_name)) {
						  is_pk=true;
						  break;
					  }
				  }
				  
				  if (is_pk) continue;
				  
				  int data_type=rs.getInt("DATA_TYPE");
				  
				  if (
						  data_type!=java.sql.Types.BIGINT 
						  && data_type!=java.sql.Types.CHAR 
						  && data_type!=java.sql.Types.DECIMAL
						  && data_type!=java.sql.Types.INTEGER
						  && data_type!=java.sql.Types.NCHAR
						  && data_type!=java.sql.Types.NUMERIC
						  && data_type!=java.sql.Types.NVARCHAR
						  && data_type!=java.sql.Types.SMALLINT
						  && data_type!=java.sql.Types.VARCHAR
					 )
					  continue;
				  
				  allColumns.add(new String[]{column_name, type_name, is_nullable});
				  
				  String hkey_base=catalog+"."+owner+"."+table+"."+column_name;
				  
				  discServer.hm.put("DATA_TYPE_OF_"+hkey_base, ""+data_type);
				  discServer.hm.put("TYPE_NAME_OF_"+hkey_base, type_name);
				  discServer.hm.put("NULLABLE_OF_"+hkey_base, is_nullable);
			}
			
			
			
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {rs.close();}catch(Exception e) {e.printStackTrace();}
		}
		
		
		
		
		//PK tiplerinin disindakileri temizle
		for (int c=allColumns.size()-1;c>=0;c--) {
			String col_name=allColumns.get(c)[0];
			String col_type=allColumns.get(c)[1]; 
			
			boolean is_matched=false;
			
			for (int pk=0;pk<compPKFields.size();pk++) {
				  String pk_col_type=compPKFields.get(pk)[1];
				  discServer.mydebug(catalog+"."+owner+"."+table+"."+col_name+"  ["+col_type+"] is comparing to "+pk_col_type);
				  if (pk_col_type.equals(col_type)) {
					  is_matched=true;
					  break;
				  }
			  }
			
			if (!is_matched) {
				discServer.mydebug(catalog+"."+owner+"."+table+"."+col_name+"["+col_type+"] is removed since does not match any PK column type");
				allColumns.remove(c);
				continue;
			}
			
			if (discServer.skipFieldList.indexOf(col_name.toLowerCase())>-1) {
				discServer.mydebug(catalog+"."+owner+"."+table+"."+col_name+" is removed since column is in exception list");
				allColumns.remove(c);
				continue;
			}
		}
			
			
		//PK dan daha az sayida kolon kaldiysa 
		if (compPKFields.size()>allColumns.size()) {
			return ret1;
		}
		
		
		
		ArrayList<ArrayList<String>> tmpCombination=new ArrayList<ArrayList<String>>();
		
		for (int pk=0;pk<compPKFields.size();pk++) {
			  String pk_col_type=compPKFields.get(pk)[1];
			  
			  ArrayList<String> tmpList=new ArrayList<String>();
			  
			  for (int c=0;c<allColumns.size();c++) {
					String col_name=allColumns.get(c)[0];
					String col_type=allColumns.get(c)[1];
					
					if (col_type.equals(pk_col_type)) tmpList.add(col_name);
			  }
			  
			  if (tmpList.size()==0) {
				  discServer.mydebug(catalog+"."+owner+"."+table+" no columns found with PK type ["+pk_col_type+"]. Skiping...");
				  return ret1;
			  }
			  
			  tmpCombination.add(tmpList);

		  }
		
		
		ret1=buildCartesian(tmpCombination);

		
		return ret1;
	}
	
	
	
	//*************************************************************
	static public String getParamByName(Connection conn,String param_name) {
	//*************************************************************
	String ret1="";
	String sql="select param_value from tdm_parameters where param_name='"+param_name+"' limit 0,1";

	try {
		ret1=getDbArray(conn, sql, 1, null,0).get(0)[0];
	} catch(Exception e) {
		ret1="";
	}

	
	return ret1;
	
	}
	
}
