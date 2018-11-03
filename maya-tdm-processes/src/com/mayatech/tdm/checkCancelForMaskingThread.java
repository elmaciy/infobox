package com.mayatech.tdm;

import java.util.ArrayList;

class checkCancelForMaskingThread implements Runnable  {
	int master_id=0;
	int work_package_id=0;
	maskLib mLib=null;
	String p_id="";
	
	
	
	checkCancelForMaskingThread(
			maskLib mLib, 
			int master_id,
			int work_package_id
			) {
		
		this.mLib=mLib;
		this.master_id=master_id;
		this.work_package_id=work_package_id;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
	 	
		mLib.last_check_cancel_ts=System.currentTimeMillis();
		
		mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_DEBUG, "**** check cancellation for work package "  + work_package_id + " ...");
	 	
	 	
	 	ConfDBOper dbCancel=new ConfDBOper(false);
	 	
	 	 
	 	
	 	while(true) {
	 		
	 		
	 		if (mLib.cancellation_flag) break;
	 		
	 		if (mLib.isMaskingFinished) break;
	 	 	
	 		if (System.currentTimeMillis()<mLib.next_check_cancel_ts+mLib.CHECK_CANCEL_INTERVAL) {
	 			try{Thread.sleep(1000);} catch(Exception e) {}
	 			continue;
	 		}
	 		
	 		mLib.next_check_cancel_ts=System.currentTimeMillis()+mLib.CHECK_CANCEL_INTERVAL;
	 		
	 		System.out.println(".... Check Cancel for "  + mLib.master_id+ " "+work_package_id);
	 		
	 		boolean is_master_cancelled=isMasterCancelled(dbCancel);
		 	boolean is_work_package_cancelled=false;
		 	
		 	if(is_master_cancelled) 
		 		mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_DANGER, "Master "+this.master_id + " is cancelled...");
		 	
		 	
		 	
		 	
	 		is_work_package_cancelled=isworkPlanCancelled(dbCancel);
	 		if (is_work_package_cancelled) 
	 			mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_DANGER, "Master "+this.master_id + " is cancelled...");
		 		
		 	
		 	mLib.cancellation_flag=is_master_cancelled || is_work_package_cancelled;
		 	
		 	mLib.is_master_cancelled=is_master_cancelled;
		 	mLib.is_work_package_cancelled=is_work_package_cancelled;
		 	
		 	
		 	
		 	mLib.isExportsOfOtherWorkPackagesFinished=isExportsOfOtherWorkPackagesFinished(dbCancel);
	 	}
	 	
	 	dbCancel.closeAll();
	}
	
	
	//-----------------------------------------------------------------------------
	boolean isMasterCancelled(ConfDBOper db) {
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+this.master_id});
		String sql="select cancel_flag from tdm_master where id=?";
		ArrayList<String[]> arr=mLib.cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		if (arr==null || arr.size()==0 || arr.get(0)[0].equals("YES")) return true;
		
		return false;
	}
	
	//-----------------------------------------------------------------------------
	boolean isworkPlanCancelled(ConfDBOper db) {
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+this.work_package_id});
		
		String sql="select wpl.status from tdm_work_plan wpl, tdm_work_package wpc where wpc.work_plan_id=wpl.id and wpc.id=?";
		ArrayList<String[]> arr=mLib.cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		if (arr!=null && arr.size()==1 && (arr.get(0)[0].equals("CANCELLED") || arr.get(0)[0].equals("PAUSED"))) return true;
		
		if (arr==null || arr.size()==0) return true;
		
		return false;
	}
	
	
	//------------------------------------------------------------------------------
	
	
	long max_other_export_finish_wait_ts=0;
	
	boolean isExportsOfOtherWorkPackagesFinished(ConfDBOper db) {
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		//diger exportlarin finish olmasi, bu export bittikten sonra
		//en fazla 5 dakika daha beklenmeli
		
		if (mLib.isExportImportSameTime) return true;
		
		if (mLib.isExportingFinished) {
			if (max_other_export_finish_wait_ts==0) 
				max_other_export_finish_wait_ts=System.currentTimeMillis()+5*60*1000;
			
			if (!mLib.is_paralleled_by_mod && !mLib.is_group_mixing ) return true;
			
			if (System.currentTimeMillis()>max_other_export_finish_wait_ts) return true;
			
		}
		
		String sql="select tab_id from tdm_work_package where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+this.work_package_id});
		
		ArrayList<String[]> arr=mLib.cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		if (arr==null || arr.size()==0) return true;
		
		String tab_id=arr.get(0)[0];
		
		sql="select 1 from tdm_work_package "+
				" where work_plan_id=? and tab_id=? and id!=? "+
				" and status in ('EXPORTING','NEW')  "+
				" and ( last_activity_date is null or last_activity_date>DATE_ADD(NOW(), INTERVAL -5 MINUTE) )";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+mLib.work_plan_id});
		bindlist.add(new String[]{"INTEGER",""+tab_id});
		bindlist.add(new String[]{"INTEGER",""+this.work_package_id});
		
		arr=mLib.cLib.getDbArray(db.connConf, sql, 1, bindlist);
		if (arr!=null && arr.size()==0) return true;

		
		return false;
	}
	
}
