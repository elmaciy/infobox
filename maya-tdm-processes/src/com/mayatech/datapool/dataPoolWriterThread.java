package com.mayatech.datapool;

import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import com.mayatech.baseLibs.genLib;


class dataPoolWriterThread implements Runnable  {
	
	dataPoolServer  dpool;
	int data_pool_instance_id;
	
	
	
	
	int SET_CHECK_CANCEL_INTERVAL=3000;
	
	
	
	
	
	dataPoolWriterThread(
			dataPoolServer dpool,
			int data_pool_instance_id
			) {
		
		this.dpool=dpool;
		this.data_pool_instance_id=data_pool_instance_id;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		dpool.written_count=0;
		
		setPoolSize();
		
		
		while(true) {
			
			if (dpool.is_server_cancelled) break;
						
			
			try {
				for (int i=0;i<dpool.recStatArr.size();i++) {
					if (dpool.recStatArr.get(i)!=dpool.REC_STAT_DONE) continue;
					
					if (dpool.is_server_cancelled) break;
					
					writeRecord(i);
					
					
				}
			} catch(Exception e) {
				e.printStackTrace();
			}
			
			commitAll();
			
			try {Thread.sleep(100); } catch(Exception e) {}
			
		}

	}
	
	
	//--------------------------------------------------
	
	ArrayList<Integer> writeArr=new ArrayList<Integer>();
	
	void writeRecord(int rec_no) {
		
		//dpool.mydebug("Writing rec : "+rec_no );
		writeArr.add(rec_no);
		
		
	}
	
	//--------------------------------------------------
	
	long last_commit_ts=System.currentTimeMillis();
	
	void commitAll() {
		
		if (writeArr.size()==0) {
			if ((System.currentTimeMillis()-last_commit_ts)>60000) 
				try {
					last_commit_ts=System.currentTimeMillis();
					dpool.mylog("testing connConfWriter connection ");
					dpool.connConfWriter.isValid(5);
				} catch(Exception e) {}
			return;
		}
		
		dpool.is_commiting=true;
		
		long start_ts=System.currentTimeMillis();
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		
		try {
			int added=0;
			for (int i=0;i<writeArr.size();i++) {
				int rec_no=writeArr.get(i);
				
				
				added++;
				
				if (added>dpool.paralellism_count*10) break;
				
				for (int c=0;c<dpool.ColumnBindTypes.size();c++) {
					String bind_type=dpool.ColumnBindTypes.get(c);
					
					if (bind_type.equals("MEMO")) bind_type="STRING";
					
					String bind_val=dpool.recArr.get(rec_no)[dpool.base_sql_colcount+c];
					if (bind_val!=null && bind_val.length()==0) bind_val=null;
					
					bindlist.add(new String[]{bind_type, bind_val});
				}
				
				dpool.recStatArr.set(rec_no, dpool.REC_STAT_EMPTY);
				
				
			}
			
			
			int inserted_rec=execBatchSqlBinding(
							dpool.connConfWriter, 
							dpool.pool_base_insert_sql, 
							bindlist, 
							dpool.ColumnBindTypes.size()
						);
			
			dpool.written_count+=inserted_rec;
			
			dpool.mylog("recs inserting : "  + added+", inserted : "+inserted_rec+", duration : "+(System.currentTimeMillis()-start_ts)+" msecs.");
			
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			setPoolSize();
						

			writeArr.clear();
			
			
			dpool.is_commiting=false;
			
		}
		
		
		
	}
	
	
	//--------------------------------------------------------------------------------------------------
	
	public int execBatchSqlBinding(Connection conn,String sql, ArrayList<String[]> bindlist,int binding_size) {

		//dpool.mylog(" /////////////  sql : " + sql);
		//dpool.mylog(" /////////////  bindlist.size : " + bindlist.size());
		//dpool.mylog(" /////////////  binding_size : " + binding_size);
		
		int ret1 = 0;
		ArrayList<String> usingArr=new ArrayList<String>();
		
		PreparedStatement pstmt_execbind=null;

		try {
			pstmt_execbind = conn.prepareStatement(sql);
			
			

			//pstmt_execbind.setQueryTimeout(120);
			
			int field_no=0;
			StringBuilder using = new StringBuilder();
			

			//dpool.mydebug("SQL : "+sql);
			

			for (int i = 1; i <= bindlist.size(); i++) {
				
				
				
				field_no++;
				String[] a_bind = bindlist.get(i - 1);
				String bind_type = a_bind[0];
				String bind_val  = a_bind[1];
				
				//dpool.mylog(" ////////////////////  bind("+i+") "+bind_type+ " => "+bind_val);
				
				if (field_no > 1) 	using.append(", ");
				using.append("{" + bind_val + "}");
				
				if (bind_type.equals("INTEGER")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(field_no, java.sql.Types.INTEGER);
					else{

						try {
							int int_val=Integer.parseInt(bind_val);
							pstmt_execbind.setInt(field_no, int_val);
						} catch(Exception e1) {
							try {
								float f_val=Float.parseFloat(bind_val.replace(',', '.'));
								pstmt_execbind.setFloat(field_no, f_val);
							} catch(Exception e2) {
								try {
									double d_val=Double.parseDouble(bind_val.replace(',', '.'));
									pstmt_execbind.setDouble(field_no, d_val);
								} catch(Exception e3) {
									e3.printStackTrace();
								}
							}
						}
						
						
						
					} //if (bind_val == null || bind_val.equals(""))
						
				} else if (bind_type.equals("LONG")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(field_no, java.sql.Types.INTEGER);
					else
						pstmt_execbind.setLong(field_no, Long.parseLong(bind_val));
				} else if (bind_type.equals("DATE")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(field_no, java.sql.Types.DATE);
					else {
						Date d = new SimpleDateFormat(genLib.DEFAULT_DATE_FORMAT)
								.parse(bind_val);
						java.sql.Date date = new java.sql.Date(d.getTime());
						pstmt_execbind.setDate(field_no, date);
					}
				} 
				else {
					if (bind_val == null)
						pstmt_execbind.setNull(field_no, java.sql.Types.VARCHAR);
					else 
						pstmt_execbind.setString(field_no, bind_val);
				}
				
				if (field_no==binding_size) {
					field_no=0;
					usingArr.add(using.toString());
					//dpool.mydebug("Using : "+using.toString());
					using = new StringBuilder();

					pstmt_execbind.addBatch();
				}
				
			} //for (int i = 1; i <= bindlist.size(); i++)

			ret1=0;
			int[] updates=pstmt_execbind.executeBatch();
			for (int u=0;u<updates.length;u++) 
				if (updates[u]>=0) ret1++;
				
		} 
		catch (BatchUpdateException buex) {
			dpool.mylog("Contents of BatchUpdateException:  ");

			buex.printStackTrace();
			
			int upd_count=0;
			
			int[] cnts=buex.getUpdateCounts();
			for (int a=0;a<cnts.length;a++) 
				if (cnts[a]>0) upd_count++;
			
			ret1=upd_count;

		    SQLException ex = buex.getNextException(); 
		    
		    while (ex != null) {                                      
		        
			    String using=null;
			    try {
			    	using=usingArr.get(upd_count);
			    } catch(Exception e) {
			    	using="Unknown";
			    }

			    dpool.mylog("BatchUpdateException@SQL        : " + sql);
			    dpool.mylog("BatchUpdateException@Using      : " + using);     		    
			    dpool.mylog("BatchUpdateException@Message    : " + ex.getMessage());
			    dpool.mylog("BatchUpdateException@SQLSTATE   : " + ex.getSQLState());
			    dpool.mylog("BatchUpdateException@Errorcode  : " + ex.getErrorCode());

				ex = ex.getNextException();
		     }

			
				
		    
		}
		catch (Exception e) {
			
			ret1=0;
			
			dpool.mylog("Exception@execDBBindingApp : " + e.getMessage());
			

			
			e.printStackTrace();
			
		} finally {
			try {
			
				if (ret1==0) 
					ret1=pstmt_execbind.getUpdateCount();
				if (ret1<0) ret1=0;
				
				try {
					pstmt_execbind.close();
				} catch(Exception e) {}
				
				
			} catch (Exception e) {}
		}

		
		return ret1;
	}
	//--------------------------------------------------------------------------------------------------
	void setPoolSize() {
		String sql="update tdm_pool_instance set pool_size=? where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",""+dpool.written_count});
		bindlist.add(new String[]{"INTEGER",""+dpool.data_pool_instance_id});
		
		poolLib.execSingleUpdateSQL(dpool.connConfWriter, sql, bindlist);
		
		
		
	}
	
}
