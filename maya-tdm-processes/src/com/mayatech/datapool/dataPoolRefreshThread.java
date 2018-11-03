package com.mayatech.datapool;

import java.util.ArrayList;


class dataPoolRefreshThread implements Runnable  {
	
	dataPoolServer  dpool;
	int data_pool_instance_id;
	
	
	
	
	int SET_CHECK_CANCEL_INTERVAL=3000;
	
	
	
	
	
	dataPoolRefreshThread(
			dataPoolServer dpool,
			int data_pool_instance_id
			) {
		
		this.dpool=dpool;
		this.data_pool_instance_id=data_pool_instance_id;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		
		long next_check_cancel_ts=System.currentTimeMillis();
		
		
		while(true) {
			
			if (dpool.is_server_cancelled) break;
				

			boolean to_reload=isReloadNeeded();
			if (to_reload) 
				dpool.reloadDataPool();
			
			try {Thread.sleep(1000); } catch(Exception e) {}
			
			
		}
		
		
		
	 	
	}
	
	
	
	
	//-----------------------------------------------------------------------------
	boolean isReloadNeeded() {
		
		if (dpool.is_server_cancelled) return false;
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+data_pool_instance_id});
		
		String sql="select reload_flag from tdm_pool_instance where id=?";
		ArrayList<String[]> arr=poolLib.getDbArray(dpool.connConfListener, sql, 1, bindlist, 0);
		
		
		String reload_flag="NO";
		try {reload_flag=arr.get(0)[0];} catch(Exception e) { };
		
		if (reload_flag.equals("YES")) {
			sql="update tdm_pool_instance set reload_flag='NO' where id=?";
			poolLib.execSingleUpdateSQL(dpool.connConfListener, sql, bindlist);
			return true;
		}
		
		return false;
	}
	


	


	
	
	
	
}
