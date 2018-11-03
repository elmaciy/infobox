package com.mayatech.tdm;

import com.mayatech.baseLibs.genLib;


class countingThread implements Runnable  {
	int work_plan_id=0;
	int work_package_id=0;
	maskLib mLib=null;
	String p_id="";
	
	
	
	countingThread(
			maskLib mLib, 
			int work_plan_id,
			int work_package_id
			) {
		
		this.mLib=mLib;
		this.work_plan_id=work_plan_id;
		this.work_package_id=work_package_id;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
	 	
	 	
	 	ConfDBOper dbCount=new ConfDBOper(false);
	 	
	 	
	 	while(true) {
	 		
	 		
	 		if (mLib.cancellation_flag) break;
	 		
	 		if (mLib.isMaskingFinished) {
	 			//mLib.loadWorkPlanParameters(dbCount);
	 			break;
	 		}
	 		
	 		if (System.currentTimeMillis()<mLib.next_counter_ts+mLib.COUNTER_INTERVAL) {
	 			try{Thread.sleep(1000);} catch(Exception e) {}
	 			continue;
	 		}
	 		
	 		mLib.next_counter_ts=System.currentTimeMillis()+mLib.COUNTER_INTERVAL;
	 		
	 		long start_ts=System.currentTimeMillis();
		 	
		 	
		 	mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_INFO, "Counting " + work_package_id + " ...");
		 	mLib.countWorkPackage(dbCount); 
		 	
		 	long countig_duration=System.currentTimeMillis()-start_ts;
		 	
		 	mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_INFO, "Counting " + work_package_id + " is finished. Duration " + countig_duration + " msecs.");
		 	
		 	mLib.loadWorkPlanParameters(dbCount);
		 	
		 	try {
				mLib.testTargetDbConnections();
			} catch(Exception e) {
				mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_DANGER, "Exception@countingThread@:testTargetDbConnections=>"+genLib.getStackTraceAsStringBuilder(e).toString());
				e.printStackTrace();
			}
	 	}
	 	
	 	
	 	dbCount.closeAll();
	 	 
	 	Thread.currentThread().interrupt();
		return;
	 	
	}
	
	private volatile boolean running = true;
	
	public void stopRunning()
	{
	    running = false;
	}


	
	
	
	
}
