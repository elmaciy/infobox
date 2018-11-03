package com.mayatech.datapool;

import java.sql.Connection;
import java.util.ArrayList;



class dataSubThread implements Runnable  {
	
	dataPoolServer  dpool;
	int sub_thread_id;
	
	
	
	
	
	
	
	
	
	dataSubThread(
			dataPoolServer dpool,
			int sub_thread_id
			) {
		
		this.dpool=dpool;
		this.sub_thread_id=sub_thread_id;
		
		dpool.mydebug("Starting subThread : "+sub_thread_id);
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		
		
		while(true) {
			
			
			
			if (dpool.is_server_cancelled) break;
			if (dpool.is_all_records_processed) break;
			
			int i=sub_thread_id;
			
			
			if (i<=(dpool.recArr.size()-1))
				while(true) {
					
					
					if (dpool.is_server_cancelled) break;
					
					if (dpool.is_all_records_processed) break;
					
					if (dpool.recStatArr.get(i)==dpool.REC_STAT_NEW) processRecord(i);
					
					i+=dpool.paralellism_count;
					if (i>(dpool.recArr.size()-1)) break;
					
					
				}
			
			try {Thread.sleep(1000); } catch(Exception e) {}
			
			
		}
		
		dpool.mylog("shutting down sub thread : " + sub_thread_id);
		
	 	
	}
	
	//-----------------------------------------------------------------
	void processRecord(int rec_no) {
		dpool.recStatArr.set(rec_no, dpool.REC_STAT_BUSY);
		
		dpool.mydebug("Processing rec : "+rec_no + " by sub thread " + sub_thread_id);
		
		long start_ts=System.currentTimeMillis();
		
		String[] rec=dpool.recArr.get(rec_no);
		/*
		dpool.mydebug("----------------\t"+rec_no+"\t---------------");
		for (int c=0;c<dpool.base_sql_colcount;c++) 
			dpool.mydebug("\t"+c +" \t: "+((String) dpool.hm.get("BASE_COL_"+c))+" " + rec[c]);
		dpool.mydebug("----------------------------------");
		*/
		
		for (int i=0;i<dpool.propertyArr.size();i++) {
			String get_method=dpool.propertyArr.get(i)[6];
			String get_val="";
			
			if (get_method.equals("DB")) {
				String sql_statement=dpool.propertyArr.get(i)[7];
				int db_family_id=0;
				try {db_family_id=Integer.parseInt(dpool.propertyArr.get(i)[8]); } catch(Exception e) {}
				get_val=calcDatabase(rec,i,db_family_id);
			} else if (get_method.equals("PATTERN")) {
				String pattern=dpool.propertyArr.get(i)[7];
				get_val=calcPattern(rec, pattern);
			} else if (get_method.equals("JS")) {
				get_val="JS";
			} else if (get_method.equals("HTTP")) {
				get_val="HTTP";
			} else {
				get_val="";
			}
			
			rec[dpool.base_sql_colcount+i]=get_val;
		}
		
		dpool.recArr.set(rec_no, rec);
		dpool.recStatArr.set(rec_no, dpool.REC_STAT_DONE);
		
		dpool.mydebug("Duration : "+(System.currentTimeMillis()-start_ts)+" msecs.");
	}

	//----------------------------------------------------------------------------------
	String calcDatabase(String[] rec,int property_id, int property_family_id) {
		StringBuilder sb=new StringBuilder();
		String val="";
		
		
		String sql=(String) dpool.hm.get("SQL_STATEMENT_OF_"+property_id);
		ArrayList<Integer> bindOrder=(ArrayList<Integer>) dpool.hm.get("BIND_ORDER_OF_"+property_id);
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		for (int i=0;i<bindOrder.size();i++) {
			int p_i=bindOrder.get(i);
			String bind_type=dpool.propertyArr.get(p_i)[2];
			if (bind_type.equals("MEMO")) bind_type="STRING";
			String bind_val=rec[dpool.base_sql_colcount+ p_i];
			
			bindlist.add(new String[]{bind_type, bind_val});
		}
		
		Connection conn=dpool.leaseConnection(property_family_id);
		
		try {
			ArrayList<String[]> arr=poolLib.getDbArray(conn, sql, 200, bindlist, 120);
			
			if (arr!=null && arr.size()>0) {
				val=arr.get(0)[0];
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		dpool.releaseConnection(conn);
		
		return val;
		
	}
	//----------------------------------------------------------------------------------
	
	String calcPattern(String[] rec, String pattern) {
		StringBuilder sb=new StringBuilder();
		sb.append(pattern);
		
		
		for (int c=0;c<dpool.base_sql_colcount;c++) {
			String col_name=(String) dpool.hm.get("BASE_COL_"+c);
			
			String search_str="${"+col_name.toUpperCase()+"}";
			String replace_val=rec[c];
			if (replace_val==null) replace_val="";
			
			dpool.mydebug("Searching for "+search_str+" in ("+pattern+"), to replace by '"+replace_val+"'");
			
			while(true) {
				int pos=sb.toString().toUpperCase().indexOf(search_str);
				if (pos==-1) break;
				
				sb.delete(pos, pos+search_str.length());
				sb.insert(pos, replace_val);
				
				dpool.mydebug("Found&replaced : "+sb.toString());
			}
			
		}
		
		
		
		for (int c=0;c<dpool.ColumnNames.size();c++) {
			String search_str="${"+dpool.ColumnNames.get(c).toUpperCase()+"}";
			String replace_val=rec[dpool.base_sql_colcount+c];
			if (replace_val==null) replace_val="";
			
			dpool.mydebug("Searching for "+search_str+" in ("+pattern+"), to replace by '"+replace_val+"'");
			
			
			while(true) {
				int pos=sb.toString().toUpperCase().indexOf(search_str);
				if (pos==-1) break;
				
				sb.delete(pos, pos+search_str.length());
				sb.insert(pos, replace_val);
				
				dpool.mydebug("Found&replaced : "+sb.toString());
			}
		}
		
		return sb.toString();
	}
	
	
	
}
