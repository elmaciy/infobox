package com.mayatech.maskdisc;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

import com.mayatech.baseLibs.genLib;




class maskDiscoveryThread implements Runnable  {
	
	maskDiscServer  discoverer;
	int thread_id=0;
	
	ScriptEngineManager factory=null;
	ScriptEngine engine=null;
	
	
	private volatile boolean running = true;
	
	maskDiscoveryThread(
			maskDiscServer  discoverer,
			int thread_id
			
			) {
		
		this.discoverer=discoverer;
		this.thread_id=thread_id;
		
	}
	
	
	public void stopRunning()
	{
	    running = false;
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		Connection connApp=mDiscLib.getDBConnection(discoverer.app_db_connstr, discoverer.app_db_driver, discoverer.app_db_username, discoverer.app_db_password, 1);
		
		
		
		if (connApp==null) {
			discoverer.mylog("Connection is not established.");
			return;
		}
		
		if (discoverer.isSybase() || discoverer.isMssql()) {
			try {
				connApp.setTransactionIsolation(connApp.TRANSACTION_NONE);
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		
		try {
			factory = new ScriptEngineManager();
			engine = factory.getEngineByName("JavaScript");
		} catch(Exception e) {
			discoverer.mylog("JavaScript Engine is not initialised.");
			return;
		}
		
		
		while(running) {
			
			if (discoverer.is_server_cancelled) stopRunning();
			
			if (discoverer.is_discovery_finished) stopRunning();
			
			int tab_arr_id=discoverer.getNextTableId();
			
			if (tab_arr_id>-1) {
				validateConn(connApp);
				
				try {
					discoverer.performMaskDiscovery(connApp, thread_id,  tab_arr_id, factory, engine);
				}
				catch(Exception e) {
					discoverer.mylog("Exception @performMaskDiscovery : ");
					discoverer.mylog(genLib.getStackTraceAsStringBuilder(e).toString());
					discoverer.tableStatusArr.set(tab_arr_id, discoverer.STATE_DONE);
				}
				
				
				
			}
				
			else stopRunning();
				//try {Thread.sleep(1000); } catch(Exception e) {}
			
		}
		
		try {connApp.close();} catch(Exception e) {}
		
		
		
	 	
	}
	
	//-----------------------------------------------------------------
	static final String MSSQL_SYBASE_TEST_CONN_STMT="select 1";
	static final String DB2_TEST_CONN_STMT="select IBMREQD x from SYSIBM.SYSDUMMY1";
	
	void validateConn(Connection conn) {
		boolean is_valid=false;
		if (discoverer.isMssql() || discoverer.isSybase()) {
			try {
				ArrayList<String[]> testArr=mDiscLib.getDbArray(conn, MSSQL_SYBASE_TEST_CONN_STMT, 1, null, 5);
				if (testArr!=null && testArr.size()==1) is_valid=true;
			} catch(Exception e) {
				
			}
		} else if (discoverer.isDb2()) 
			try {
				ArrayList<String[]> testArr=mDiscLib.getDbArray(conn, DB2_TEST_CONN_STMT, 1, null, 5);
				if (testArr!=null && testArr.size()==1) is_valid=true;
			} catch(Exception e) {
				
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
