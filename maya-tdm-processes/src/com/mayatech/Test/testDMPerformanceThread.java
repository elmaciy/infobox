package com.mayatech.Test;

import java.sql.Connection;
import java.util.ArrayList;

import com.mayatech.dm.ddmLib;


class testDMPerformanceThread implements Runnable  {
	
	testDMPerformance dm;
	int thread_id;
	


	
	testDMPerformanceThread(
			testDMPerformance dm,
			int thread_id
			) {
		
		this.dm=dm;
		this.thread_id=thread_id;


	}

	//-------------------------------------------------------------------


	
	@Override
    public void run() {
		
		Connection conn=ddmLib.getTargetDbConnection(dm.driver, dm.url, dm.user, dm.pass);
		
		int i=0;
		
		while(true) {
			i++;
			if (i==dm.sqlSampleArr.size()) i=0;
			
			String sql=dm.sqlSampleArr.get(i)[0];
			if (sql.contains("?") || sql.contains(":")) continue;
			
			//System.out.println("Thread "+thread_id+ " : " + sql.replaceAll("\n|\r", " "));
			long start_ts=System.currentTimeMillis();
			ArrayList<String[]> arr=ddmLib.getDbArray(conn, sql, 100, null, 0);
			
			dm.duration+=(System.currentTimeMillis()-start_ts);
			dm.sql_count++;
			
			if (dm.stop_flag) break;


			try{Thread.sleep(100);} catch(Exception e) {}
			
			
		}
		
		try{conn.close();} catch(Exception e) {}
		
	}
	

}
