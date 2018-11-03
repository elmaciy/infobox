package com.mayatech.dm;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.Date;

import com.mayatech.baseLibs.genLib;


class clientStatusCheckerWriterThread implements Runnable  {
	
	ddmProxyServer dm;
	int proxy_id;
	
	
	int SET_CLIENT_STATUS_INTERVAL=10000;
	int KILL_STALLED_SESSIONS_INTERVAL=10000;
	
	Connection connConfThread;
	
	clientStatusCheckerWriterThread(
			ddmProxyServer dm,
			int proxy_id
			) {
		
		this.dm=dm;
		this.proxy_id=proxy_id;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		//make initial loading
		dm.loadConfiguration();
		
		connConfThread=ddmLib.getTargetDbConnection(dm.conf_db_driver, dm.conf_db_url, dm.conf_db_username,dm.conf_db_password);
		
		long next_check_client_status_ts=System.currentTimeMillis();
		long next_kill_stalled_clients_ts=System.currentTimeMillis();

		
		while(true) {
			
			if (dm.is_proxy_cancelled) break;
			
			dm.flushLogs(false);
			
			if (!ddmLib.validateMySQLConnection(connConfThread)) {
				dm.mylog("Connection connConfThread is not valid. Trying to reestablish.");
				try {Thread.sleep(1000); } catch(Exception e) {}
				connConfThread=ddmLib.getTargetDbConnection(dm.conf_db_driver, dm.conf_db_url, dm.conf_db_username,dm.conf_db_password);
				continue;
			}
			
			if (System.currentTimeMillis()>next_check_client_status_ts) {
				refreshClientStatusArray();
				next_check_client_status_ts=System.currentTimeMillis()+SET_CLIENT_STATUS_INTERVAL;
			}
			
			
			if (System.currentTimeMillis()>next_kill_stalled_clients_ts) {
				killStalledClients();
				next_kill_stalled_clients_ts=System.currentTimeMillis()+KILL_STALLED_SESSIONS_INTERVAL;
				dm.mylog(""+(new Date())+"Heap Size : "+genLib.heapUsedRate()+" %" +", Active Clients :"+dm.clientThreadGroup.activeCount());
				
				//dm.clientThreadGroup.list();
			}
			
			
			try {Thread.sleep(1000); } catch(Exception e) {}
			
			
			
			
		}
		
		ddmLib.closeConn(connConfThread);
		
	 	
	}
	
	
	
	
	//-----------------------------------------------------------------------------
	void refreshClientStatusArray() {
		
		String sql="select id, cancel_flag,  IFNULL(TIMESTAMPDIFF(MINUTE, now(), exception_time_to),0) diff_as_sec, tracing_flag \n" + 
					"	from tdm_proxy_session \n" + 
					"	where proxy_id=? \n" + 
					"	and status='ACTIVE'";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		
		ArrayList<String[]> arr=ddmLib.getDbArray(connConfThread, sql, Integer.MAX_VALUE, bindlist, 0);
		
		if (arr==null || arr.size()==0) return;
		
		dm.is_client_status_loading=true;
		dm.clientStatusArray.clear();
		dm.clientStatusArray.addAll(arr);
		dm.is_client_status_loading=false;
	}
	
	
	//-----------------------------------------------------------------------------
	void killStalledClients() {
		
		int stalling_time=10*60;
		
		String sql="select id  \n" + 
					"	from tdm_proxy_session \n" + 
					"	where proxy_id=? \n" + 
					"	and status='ACTIVE' "+
					" and TIME_TO_SEC(TIMEDIFF(now(), last_activity_date))>?"
					;
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		bindlist.add(new String[]{"INTEGER",""+stalling_time});
		
		ArrayList<String[]> arr=ddmLib.getDbArray(connConfThread, sql, Integer.MAX_VALUE, bindlist, 0);
		
		if (arr==null || arr.size()==0) return;
		
		for (int i=0;i<arr.size();i++) {
			String session_id=arr.get(0)[0];
			dm.mydebug("Stalled session ["+session_id+"] detected. Aborting.");
			dm.disconnectClient(session_id);
		}
		


	}
	
	


	


	
	
	
	
}
