package com.mayatech.Test;

import java.sql.Connection;
import java.util.ArrayList;

import com.mayatech.dm.ddmLib;

public class testDMPerformance {
	
	
	boolean stop_flag=false;
	
	int sql_count=0;
	long duration=0;
	
	
	ArrayList<String[]> sqlSampleArr=null;

	String driver="oracle.jdbc.driver.OracleDriver";
	String url="jdbc:oracle:thin:@localhost:1522:orcl";
	//String url="jdbc:oracle:thin:@localhost:1521:orcl";
	String user="system";
	String pass="Han#1323";
	
	ThreadGroup testDMPerformanceThreadGroup = new ThreadGroup("CheckersubThreadGroup Thread Group");
	
	void startNewThread(testDMPerformance dm, int thread_id) {
		String thread_name="testDMPerformance_THRED_"+thread_id;
		try {
			Thread thread=new Thread(testDMPerformanceThreadGroup, 
					new testDMPerformanceThread(dm, thread_id),thread_name);
			thread.start();
		} catch(Exception e) {
			
			e.printStackTrace();
		}
	}
	
	
	void printStats() {

		System.out.println("----------------------------");
		System.out.println("SQL COUNT      : "+sql_count);
		System.out.println("SQL DURATION   : "+duration);
		if (sql_count>0) {
			float metric=(duration/sql_count);
			
			System.out.println("METRIC         : "+ metric );
		}
			
		System.out.println("----------------------------");
	
	}
	
	public static void main(String[] args) {

		testDMPerformance dm= new testDMPerformance();
		
		
		
		
		
		String sql="";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		sql="select sql_fulltext from v$sql where bind_data is null and parsing_schema_name='SYSTEM'";
		
		Connection conn=ddmLib.getTargetDbConnection(dm.driver, dm.url, dm.user, dm.pass);
		dm.sqlSampleArr=ddmLib.getDbArray(conn, sql, 100, bindlist, 0);
		
		try{conn.close();} catch(Exception e) {}
		
		long start_ts=System.currentTimeMillis();
		
		for (int i=0;i<10;i++) 
			dm.startNewThread(dm,i);
		
		int i=0;
		
		while(true) {
			if (System.currentTimeMillis()-start_ts>60000) break;
			try{Thread.sleep(1000);} catch(Exception e) {}
			i++;
			
			
			if (i%5==0) dm.printStats();
		}

		dm.stop_flag=true;
		
		while(true) {
			if (dm.testDMPerformanceThreadGroup.activeCount()==0) break;
			try{Thread.sleep(100);} catch(Exception e) {}
		}
		
		dm.printStats();
			
		

	}

}
