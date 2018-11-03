package com.mayatech.maskdisc;

import java.sql.Connection;
import java.util.ArrayList;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;




class copyDiscoveryThread implements Runnable  {
	
	maskDiscServer  discoverer;
	int thread_id=0;
	
	
	
	
	
	copyDiscoveryThread(
			maskDiscServer  discoverer,
			int thread_id
			
			) {
		
		this.discoverer=discoverer;
		this.thread_id=thread_id;
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		Connection connApp=mDiscLib.getDBConnection(discoverer.app_db_connstr, discoverer.app_db_driver, discoverer.app_db_username, discoverer.app_db_password, 1);
		
		if (connApp==null) {
			discoverer.mylog("Connection is not established.");
			return;
		}
		
		
		
		
		while(true) {
			
			if (discoverer.is_server_cancelled) break;
			
			if (discoverer.is_discovery_finished) break;
			
			int tab_arr_id=discoverer.getNextTableId();
			
			if (tab_arr_id>-1) {
				validateConn(connApp);
				discoverer.performCopyDiscovery(connApp, thread_id,  tab_arr_id);
			}
				
			else 
				try {Thread.sleep(1000); } catch(Exception e) {}
			
		}
		
		try {connApp.close();} catch(Exception e) {}
		
	 	
	}
	
	//-----------------------------------------------------------------
	static final String MSSQL_TEST_CONN_STMT="select 1";
	void validateConn(Connection conn) {
		boolean is_valid=false;
		if (discoverer.isMssql()) {
			try {
				ArrayList<String[]> testArr=mDiscLib.getDbArray(conn, MSSQL_TEST_CONN_STMT, 1, null, 5);
				if (testArr!=null && testArr.size()==1) is_valid=true;
			} catch(Exception e) {
				
			}
		}
		else {
			try {
				is_valid=conn.isValid(5);
				is_valid=true;
			} catch(Exception e) {
				
			}
		}
		
		
		if (!is_valid)
			conn=mDiscLib.getDBConnection(discoverer.app_db_connstr, discoverer.app_db_driver, discoverer.app_db_username, discoverer.app_db_password, 1);
		
		
	}
	
}
