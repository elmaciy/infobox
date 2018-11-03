package com.mayatech.tdm;

import java.util.ArrayList;

import com.mayatech.baseLibs.genLib;



class dispatcherThread implements Runnable  {
	maskLib mLib=null;
	String dispatcher_key="";
	
	
	
	dispatcherThread(
			maskLib mLib, 
			String dispatcher_key
			) {
		
		this.mLib=mLib;
		this.dispatcher_key=dispatcher_key;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		long ts=System.currentTimeMillis();
		
		
		int sleep_duration=100;
		int dispatched=0;
		
		
		ConfDBOper dbDispatcher=new ConfDBOper(false);
		

		String check_export_finished_sql="select 1 from tdm_work_package  where work_plan_id=? and id!=? and tab_id=(select tab_id from tdm_work_package where id=?) and status in ('NEW','EXPORTING','FAILED') limit 0,1";
		ArrayList<String[]> bindArrForCheckExportFinished=new ArrayList<String[]>();
		bindArrForCheckExportFinished.add(new String[]{"INTEGER",""+mLib.work_plan_id});
		bindArrForCheckExportFinished.add(new String[]{"INTEGER",""+mLib.work_package_id});
		bindArrForCheckExportFinished.add(new String[]{"INTEGER",""+mLib.work_package_id});
		
		
		boolean isAllExported=false;


		
		while(true) {
			
			mLib.cLib.heartbeat(dbDispatcher.connConf, mLib.cLib.TABLE_TDM_MASTER, 0, mLib.master_id);
			
			if (System.currentTimeMillis()-ts>=mLib.COUNTER_INTERVAL) {
				ts=System.currentTimeMillis();
				mLib.cLib.setWorkPackageStatus(dbDispatcher.connConf, mLib.work_plan_id, mLib.work_package_id, mLib.master_id, mLib.cLib.WORK_PACKAGE_STATUS_TOUCH);
				
				
				if (mLib.cLib.heapUsedRate()>90) {
					mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_INFO, "Garbage collection performing... ");
					System.gc();
				}
				
			}
			
			
			boolean to_continue=mLib.hm.containsKey(dispatcher_key);
			
			if (!to_continue) break;
			
			if (mLib.cancellation_flag) break;	
			
			
			if (mLib.isTemporaryTableCreating) {
				try {Thread.sleep(1000); } catch(Exception e) {}
				continue;
			}
			
			//EXPORT_FIRST durumunda, ayni tablodaki diger tum wpc lerin exportlarinin bitmesini bekle
			if (mLib.isExportFirst && !isAllExported) {
				ArrayList<String[]> notExportedArr=mLib.cLib.getDbArray(dbDispatcher.connConf, check_export_finished_sql, 1, bindArrForCheckExportFinished);
				if (notExportedArr.size()==1) {
					mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_INFO, "Dispatcher is waiting other workpackages of "+mLib.work_package_id+"to be exported... ");
					try{Thread.sleep(3000);} catch(Exception e) {}
					continue;
				}
				isAllExported=true;
			}


			try {
				mLib.resumeStalledTasks();
			} catch(Exception e) {
				mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_DANGER, "Exception@dispatcherThread@:resumeStalledTasks=> "+genLib.getStackTraceAsStringBuilder(e).toString());
				e.printStackTrace();
			}
			
			
			try {
				int loaded_persisted_task_count=mLib.loadPersistedTasks(dbDispatcher.connConf, false);
				if (loaded_persisted_task_count>0)
					mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_INFO, "loaded Persisted Task Count : "+loaded_persisted_task_count);
			} catch(Exception e) {
				mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_DANGER, "Exception@dispatcherThread@:loadPersistedTasks=>"+genLib.getStackTraceAsStringBuilder(e).toString());
				e.printStackTrace();
			}
			
			
			try {
				int loaded_failed_task_count=mLib.loadTasksToRetry(dbDispatcher.connConf);
				if (loaded_failed_task_count>0)
					mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_INFO, "loaded Failed Task Count : "+loaded_failed_task_count);
			} catch(Exception e) {
				mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_DANGER, "Exception@dispatcherThread@:loadFailedTasks=>"+genLib.getStackTraceAsStringBuilder(e).toString());
				e.printStackTrace();
			}
			
			
			try {
				dispatched=mLib.dispatchGlobalTaskArr(dbDispatcher.connConf);
				if (dispatched>0)
					mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_INFO, "Dispatched Task Count : "+dispatched + " [master : "+ mLib.master_id+", wpc : "+mLib.work_package_id+"] maskThread : ["+mLib.maskerThreadGroup.activeCount()+"]");
			} catch(Exception e) {
				mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_DANGER, "Exception@dispatcherThread@:dispatchGlobalTaskArr=>"+genLib.getStackTraceAsStringBuilder(e).toString());
				e.printStackTrace();
			}
			
			
			
			
			if (dispatched>0) 	 continue; //dispatch more
			
			
			

			
			if (dispatched==0) sleep_duration=sleep_duration+100;
			else sleep_duration=sleep_duration-100;
			
			if (sleep_duration<100) sleep_duration=100;
			if (sleep_duration>1000) sleep_duration=1000;
			
			try {Thread.sleep(sleep_duration); } catch(Exception e) {}
			
			
		}
		
		dbDispatcher.closeAll();
		
	 	
		Thread.currentThread().interrupt();
		return;
	 	
	}
	
	private volatile boolean running = true;
	
	public void stopRunning()
	{
	    running = false;
	}
	
	
	
	
	
	
}
