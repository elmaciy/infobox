package com.mayatech.tdm;


class heartbeatThread implements Runnable  {
	maskLib mLib=null;
	String heartbeat_key="";
	
	
	
	heartbeatThread(
			maskLib mLib, 
			String heartbeat_key
			) {
		
		this.mLib=mLib;
		this.heartbeat_key=heartbeat_key;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		long ts=System.currentTimeMillis();
		
		
		while(true) {
			mLib.cLib.heartbeat(mLib.confDB, mLib.cLib.TABLE_TDM_MASTER, 0, mLib.master_id);
			
			if (System.currentTimeMillis()-ts>=mLib.COUNTER_INTERVAL) {
				ts=System.currentTimeMillis();
				mLib.cLib.setWorkPackageStatus(mLib.confDB, mLib.work_plan_id, mLib.work_package_id, mLib.master_id, mLib.cLib.WORK_PACKAGE_STATUS_TOUCH);

			}
			
			
			boolean to_continue=mLib.hm.containsKey(heartbeat_key);
			
			if (!to_continue) break;
			
			try {Thread.sleep(1000); } catch(Exception e) {}
			
			
		}
		
		
		
	 	
		Thread.currentThread().interrupt();
		return;
	 	
	}
	
	private volatile boolean running = true;
	
	public void stopRunning()
	{
	    running = false;
	}
	
	
	
	
	
	
}
