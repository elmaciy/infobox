package com.mayatech.tdm;

import java.util.ArrayList;



class keepAliveConfDBThread implements Runnable  {
	ConfDBOper db=null;
	
	int KEEP_ALIVE_INTERVAL=30000;
	
	keepAliveConfDBThread(
			ConfDBOper db
			) {
		
		this.db=db;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		long ts=System.currentTimeMillis();
		
		
		
		while(true) {
			
			if (System.currentTimeMillis()-ts>KEEP_ALIVE_INTERVAL) {
				ts=System.currentTimeMillis();
				try {db.connConf.isValid(5);} catch(Exception e) {e.printStackTrace();}
				db.mylog(db.LOG_LEVEL_INFO, "keepAliveConfDBThread ...");
				
				setWorkPackageHeartbeat();
				
				db.heartbeat(db.TABLE_TDM_MASTER, 0, db.master_id);
			}
			
			
			
			
			
			
			if (!db.keepAliveConfDbFlag) {
				System.out.println("startKeepAliveConfDB exit");
				break;
			}
			
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
	
	
	void setWorkPackageHeartbeat() {
		String sql="update tdm_work_package set last_activity_date=now() where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.add(new String[]{"INTEGER",""+db.work_package_id});
		
		db.execDBBindingConf(sql, bindlist);
	}
	
	
	
}
