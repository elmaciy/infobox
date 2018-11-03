package com.mayatech.tdm;

import java.util.ArrayList;

class checkCancelForCopyingThread implements Runnable  {
	
	ConfDBOper db=null;
	int work_package_id=0;
	copyLib cpLib=null;
	String p_id="";
	
	
	
	checkCancelForCopyingThread(
			ConfDBOper db,
			copyLib cpLib, 
			int work_package_id
			) {
		
		this.db=db;
		this.cpLib=cpLib;
		this.work_package_id=work_package_id;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
	 	
	 	boolean is_master_cancelled=isMasterCancelled();
	 	
	 	
	 	
	 	
	 	if(is_master_cancelled) {
	 		cpLib.mylog("Exception@ Master "+db.master_id + " is cancelled...");
	 	} 
	 	
 		boolean is_work_package_cancelled=isworkPlanCancelled();
 		if (is_work_package_cancelled) {
 			cpLib.mylog("Exception@Work Package "+work_package_id + " is cancelled...");
	 		
	 	}
	 	
	 	cpLib.error_flag=is_master_cancelled || is_work_package_cancelled;
	 	
	 	if (cpLib.error_flag) 
	 		cpLib.global_error_count++;
	 	
	 	
	 	
	}
	
	
	//-----------------------------------------------------------------------------
	boolean isMasterCancelled() {
		
		
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+db.master_id});
		String sql="select cancel_flag from tdm_master where id=?";
		ArrayList<String[]> arr=cpLib.cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		
		if (arr==null || arr.size()==0|| arr.get(0)[0].equals("YES")) return true;
		
		return false;
	}
	
	//-----------------------------------------------------------------------------
	boolean isworkPlanCancelled() {
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+this.work_package_id});
		
		String sql="select wpl.status from tdm_work_plan wpl, tdm_work_package wpc where wpc.work_plan_id=wpl.id and wpc.id=?";
		ArrayList<String[]> arr=cpLib.cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		if (arr!=null && arr.size()==1 && (arr.get(0)[0].equals("CANCELLED") || arr.get(0)[0].equals("PAUSED"))) return true;
		
		if (arr==null || arr.size()==0) return true;
		
		return false;
	}
	
	
}
