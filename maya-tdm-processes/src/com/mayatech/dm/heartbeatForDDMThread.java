package com.mayatech.dm;

import java.sql.Connection;
import java.util.ArrayList;


class heartbeatForDDMThread implements Runnable  {
	
	ddmProxyServer dm;
	int proxy_id;
	Connection connConfHeartBeat;
	
	int HEARTBEAT_INTERVAL=10000;
	
	
	
	heartbeatForDDMThread(
			ddmProxyServer dm,
			int proxy_id
			) {
		
		this.dm=dm;
		this.proxy_id=proxy_id;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		long ts=0;
		
		connConfHeartBeat=ddmLib.getTargetDbConnection(dm.conf_db_driver, dm.conf_db_url, dm.conf_db_username,dm.conf_db_password);
		
		while(true) {
			
			if (dm.is_proxy_cancelled) break;
			
			
			if (!ddmLib.validateMySQLConnection(connConfHeartBeat)) {
				dm.mylog("Connection connConfHeartBeat is not valid. Trying to reestablish.");
				try {Thread.sleep(1000); } catch(Exception e) {}
				connConfHeartBeat=ddmLib.getTargetDbConnection(dm.conf_db_driver, dm.conf_db_url, dm.conf_db_username,dm.conf_db_password);
				continue;
			}
			
			boolean to_reload=isReloadNeeded();
			if (to_reload) 
				dm.loadConfiguration();
			
			if (System.currentTimeMillis()-ts>=HEARTBEAT_INTERVAL) {
				ts=System.currentTimeMillis();
				setProxyHeartbeatTime();
				
				int heap_rate=dm.heapUsedRate();
				
				//dm.mylog("Heap Usage Rate : %"  + heap_rate);
				
				if (heap_rate>80) {
					dm.hmCache.clear();
				}
				
				if (heap_rate>95) {
					dm.mylog("Heap Rate is too high. Masking profile will be reloaded.");
					dm.loadConfiguration();
				}
				
				
				
				if (System.currentTimeMillis()>dm.next_proxy_event_write_ts) {
					
					ddmLib.addProxyEvent(
							dm,
							dm.proxyEventArray, 
							dm.DUMMY,
							"",
							"",
							"",
							"",
							"",
							"",
							"",
							"", // bind
							"0"  // +sampleData.size()
							);
				}
						

			}
			
			
			
			boolean to_cancel=isStoppedCancelled();
			
			if (to_cancel) {
				System.out.println("Proxy cancelled. ");
				setStatusInactive();
				dm.is_proxy_cancelled=true;
				//try {Thread.sleep(5000); } catch(Exception e) {}
				break;
				
			}
			
			


			
			try {Thread.sleep(1000); } catch(Exception e) {}
			
			
		}
		
		
		ddmLib.closeConn(connConfHeartBeat);
	 	
	}
	


	//-----------------------------------------------------------------------------
	boolean isReloadNeeded() {
		
		if (dm.DDM_CONFIGURATION_RELOAD_INTERVAL>0 && System.currentTimeMillis()>  dm.last_configuration_load_ts+dm.DDM_CONFIGURATION_RELOAD_INTERVAL) {
			dm.mylog("Reloading configuration.");
			return true;
		}
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		
		String sql="select reload_flag, is_debug from tdm_proxy where id=?";
		ArrayList<String[]> arr=ddmLib.getDbArray(connConfHeartBeat, sql, 1, bindlist, 0);
		
		
		String reload_flag="NO";
		String is_debug="NO";
		
		
		
		try {reload_flag=arr.get(0)[0];} catch(Exception e) { };
		try {is_debug=arr.get(0)[1];} catch(Exception e) { };
		
		boolean bool_is_debug=false;
		if (is_debug.equals("YES")) bool_is_debug=true;
		dm.is_debug=bool_is_debug;
		
		
		if (reload_flag.equals("YES")) {
			sql="update tdm_proxy set reload_flag=null where id=?";
			ddmLib.execSingleUpdateSQL(connConfHeartBeat, sql, bindlist);
			return true;
		}
		
		return false;
	}
	
	//-------------------------------------------------------------

	void setProxyHeartbeatTime() {
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String sql="update tdm_proxy set status='ACTIVE', last_heartbeat=now() where id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		
		ddmLib.execSingleUpdateSQL(connConfHeartBeat, sql, bindlist);
		
		
		
		//System.out.println(" heartbeat for proxy " + proxy_id);
		
	}
	


	//-----------------------------------------------------------------------------
	boolean isStoppedCancelled() {
		
		
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		String sql="select status from tdm_proxy where id=?";
		ArrayList<String[]> arr=ddmLib.getDbArray(connConfHeartBeat, sql, 1, bindlist, 0);
		
		
		if (arr==null || arr.size()==0|| arr.get(0)[0].equals("STOP")) return true;
		
		return false;
	}
	
	//*******************************************************************
	void setStatusInactive() {
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String sql="update tdm_proxy set status='INACTIVE' where id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		
		ddmLib.execSingleUpdateSQL(connConfHeartBeat, sql, bindlist);
		
		
	}
	
	
	
	
}
