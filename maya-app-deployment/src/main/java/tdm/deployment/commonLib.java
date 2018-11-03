package tdm.deployment;

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

import oracle.sql.ROWID;


public class commonLib {

	String start_char="\"";
	String end_char="\"";
	String middle_char=".";
	
	final String DEFAULT_DATE_FORMAT="dd/MM/yyyy HH:mm:ss";
	String mysql_format="%d.%m.%Y %H:%i:%s";
	
	// *******************************
		public String nvl(String in, String out) {
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
		
	//*************************************************************
	public ArrayList<String[]> getDbArrayConf(Connection connConf, String sql, int limit,ArrayList<String[]> bindlist) {
	//*************************************************************
		return  getDbArrayConf(connConf, sql, limit, bindlist,9999);
		}
	//*************************************************************

	public ArrayList<String[]> getDbArrayConf(Connection connConf, String sql, int limit,ArrayList<String[]> bindlist, int timeout_insecond) {
		return getDbArrayConf(connConf,sql,limit, bindlist,timeout_insecond,null);
	}

	public ArrayList<String[]> getDbArrayConf(Connection connConf, String sql, int limit,ArrayList<String[]> bindlist, int timeout_insecond, ArrayList<String> columnList) {
	//*************************************************************
			ArrayList<String[]> ret1 = new ArrayList<String[]>();

			PreparedStatement pstmtConf = null;
			ResultSet rsetConf = null;
			ResultSetMetaData rsmdConf = null;


			int reccnt = 0;
			try {
				if (pstmtConf == null) 	pstmtConf = connConf.prepareStatement(sql);
				
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
				
				pstmtConf.setQueryTimeout(timeout_insecond);
				
				if (rsetConf == null) rsetConf = pstmtConf.executeQuery();
				if (rsmdConf == null) rsmdConf = rsetConf.getMetaData();
				
				

				int colcount = rsmdConf.getColumnCount();
				
				if (columnList!=null) {
					columnList.clear();
					for (int i=1;i<=colcount;i++) {
						columnList.add(rsmdConf.getColumnName(i));
					}
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
							} 
						catch (Exception enull) {a_field = "";}
						row[i - 1] = a_field;
					}
					ret1.add(row);
				}
			} catch (Exception ignore) {
				ignore.printStackTrace();
				System.out.println("Exception@getDbArrayConf : " + sql);
			} finally {
				try {rsmdConf = null;} catch (Exception e) {}
				try {rsetConf.close();rsetConf = null;} catch (Exception e) {}
				try {pstmtConf.close();	pstmtConf = null;} catch (Exception e) {}
			}
			return ret1;
		}
	
	//*************************************************************
	public Connection getconn(Connection connconf, String env_id) {
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",env_id});
		
		String sql="select db_driver, db_connstr, db_username, db_password from tdm_envs where id=?";
		ArrayList<String[]> recs=getDbArrayConf(connconf, sql, 1, bindlist);
		
		if (recs.size()==0) {
			System.out.println("Exception@getconn : Environment parameters cannot be retrieved. Environment id : "+env_id);
			return null;
		}
		
		String db_driver="";
		String db_connstr="";
		String db_username="";
		String db_password="";
		
		try{
		db_driver=recs.get(0)[0];
		db_connstr=recs.get(0)[1];
		db_username=recs.get(0)[2];
		db_password=recs.get(0)[3]; 
		
		
		} catch(Exception e) {
			e.printStackTrace();
			return null;
		}
		
			Connection ret1 = null;
			String test_sql="";
			
			sql="select flexval1, flexval2 from  tdm_ref where ref_type='DB_TYPE' and ref_name='"+db_driver+"'";
			
			ArrayList<String[]> retdb=getDbArrayConf(connconf, sql, 1, new ArrayList<String[]>());
			
			if (retdb.size()==0) {
				System.out.println("Exception@getconn : Database type parameters cannot be retrieved. db driver : "+db_driver);
				return null;
			}
			
			String db_type=retdb.get(0)[0];
			String template=retdb.get(0)[1];
			

			
			if (template.contains("|")) 
				test_sql=template.split("\\|")[0];
			
			if (test_sql.length()==0) test_sql="select 1";
			
			ret1=getconn(db_driver, db_connstr, db_username, db_password, test_sql);
				

		return ret1;
		}

	//*************************************************************
	String last_connection_error="";
	
	public Connection getconn(String db_driver, String db_connstr, String db_username, String db_password, String test_sql) {
		Connection ret1=null;
		
		
		
		try {
			Class.forName(db_driver);
			Connection conn = DriverManager.getConnection(db_connstr, db_username, db_password);
			
			Statement stmt = conn.createStatement();
			ResultSet rset = stmt.executeQuery(test_sql);
			while (rset.next()) {rset.getString(1);	}

			ret1=conn; 
			
			if(conn!=null && conn.getMetaData().getIdentifierQuoteString().trim().length()>0) 
				try {
					start_char=conn.getMetaData().getIdentifierQuoteString();
					end_char=start_char;
					middle_char=nvl(conn.getMetaData().getCatalogSeparator(),".");
				} catch(Exception e) {
					e.printStackTrace();
				}
			
		} catch (Exception ignore) {
			last_connection_error=ignore.getMessage();
			ignore.printStackTrace();
			ret1=null;
		}
		
		return ret1;
	}
	//*************************************************************
	public void closeconn(Connection conn) {
			if (conn==null) return;
			try {
				conn.close();
				conn=null;
			} catch (SQLException e) {
				conn=null;
				System.out.print("closeconn@"+e.getMessage());
			}
			
	}
	
	//*************************************************************
		public ArrayList<String[]> getDbArrayApp(Connection connconf,String env_id, String sql, int limit,ArrayList<String[]> bindlist) {
			return getDbArrayApp(connconf,env_id,sql,limit, bindlist,null);
		}
		
		
		//*************************************************************
		public ArrayList<String[]> getDbArrayApp(
				String db_driver, 
				String db_connstr, 
				String db_username , 
				String db_password, 
				String test_sql,
				String sql, 
				int limit,
				ArrayList<String[]> bindlist
				) {
		//*************************************************************
			ArrayList<String[]> ret1 = new ArrayList<String[]>();

			
			Connection connApp=getconn(db_driver, db_connstr, db_username, db_password, test_sql);
			ret1=getDbArrayApp(connApp, sql, limit, bindlist, null);
			
			
			return ret1;
		}	
		
	//*************************************************************
	public ArrayList<String[]> getDbArrayApp(Connection connconf,String env_id, String sql, int limit,ArrayList<String[]> bindlist, ArrayList<String> colList) {
	//*************************************************************
		ArrayList<String[]> ret1 = new ArrayList<String[]>();

		
		Connection connApp=getconn(connconf, env_id);
		ret1=getDbArrayApp(connApp, sql, limit, bindlist, colList);
			
		
		return ret1;
	}
		
	//*********************************************************************************************	
	public ArrayList<String[]> getDbArrayApp(
			Connection connApp,
			String sql, 
			int limit,
			ArrayList<String[]> bindlist, 
			ArrayList<String> colList) {
		
		ArrayList<String[]> ret1 = new ArrayList<String[]>();
		
		int reccnt = 0;
		
		PreparedStatement pstmtApp = null;
		ResultSet rsetApp = null;
		ResultSetMetaData rsmdApp = null;
		
		try {
			
			pstmtApp = connApp.prepareStatement(sql);
			
			//------------------------------ end binding

			if (bindlist!=null) {
				for (int i = 1; i <= bindlist.size(); i++) {
					String[] a_bind = bindlist.get(i - 1);
					String bind_type = a_bind[0];
					String bind_val = a_bind[1];

					if (bind_type.equals("INTEGER")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtApp.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtApp.setInt(i, Integer.parseInt(bind_val));
					} else if (bind_type.equals("LONG")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtApp.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtApp.setLong(i, Long.parseLong(bind_val));
					} else if (bind_type.equals("ROWID")) {
							ROWID r = new ROWID();
							r.setBytes(bind_val.getBytes());
							pstmtApp.setRowId(i, r);
					} else if (bind_type.equals("DATE") || bind_type.equals("DATETIME") || bind_type.equals("TIMESTAMP")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtApp.setNull(i, java.sql.Types.DATE);
						else
						{
							Date b=new Date();
							try {
								SimpleDateFormat df=new SimpleDateFormat(DEFAULT_DATE_FORMAT);
								b=df.parse(bind_val);
							} catch(Exception e) {};
							java.sql.Date sqld=new java.sql.Date(b.getTime());
							//pstmtConf.setDate(i, sqld);
							Timestamp t=new Timestamp(b.getTime());
							pstmtApp.setTimestamp(i, t);
						}
							
					} else {
						pstmtApp.setString(i, bind_val);
					}
				}
				//------------------------------ end binding
			}  // if bindlist 
			
			if (rsetApp == null) rsetApp = pstmtApp.executeQuery();
			if (rsmdApp == null) rsmdApp = rsetApp.getMetaData();

			int colcount = rsmdApp.getColumnCount();
			
			if (colList!=null) {
				colList.clear();
				for (int i=1;i<=colcount;i++) 
					colList.add(rsmdApp.getColumnName(i));
				
				
			}
			
			
			String a_field = "";
			while (rsetApp.next()) {
				reccnt++;
				if (reccnt > limit) break;
				String[] row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {
					try {
						if ("DATE,TIMESTAMP,DATETIME".indexOf(rsmdApp.getColumnTypeName(i).toUpperCase()) > -1) {
							Date d = rsetApp.getDate(i);
							if (d == null)	a_field = "";
							else a_field = new SimpleDateFormat(DEFAULT_DATE_FORMAT).format(d);
						} else
							a_field = rsetApp.getString(i);
							if (a_field.equals("null")) {
								if (rsetApp.wasNull()) a_field="";
							}
						} 
					catch (Exception enull) {a_field = "";}
					row[i - 1] = a_field;
				}
				ret1.add(row);
			}
			
		} catch (Exception ignore) {
			
			ignore.printStackTrace();
			System.out.println("Exception@getDbArrayApp : " + sql);
		} finally {
			try {rsmdApp = null;} catch (Exception e) {}
			try {rsetApp.close();rsetApp = null;} catch (Exception e) {}
			try {pstmtApp.close();pstmtApp = null;} catch (Exception e) {}
		}
		return ret1;
	}
}
