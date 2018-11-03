package com.mayatech.tdm;




public class masterDriver {

	
	public static void main(String[] args) {

		String mid=""+(System.currentTimeMillis()+Math.round(Math.random()*1000));
		ConfDBOper d=new ConfDBOper(false);
		
		
		d.master_id=d.startMaster(mid);
		d.sleep(100);
		
		//d.checkLicence();
		
		d.mylog(d.LOG_LEVEL_INFO, "MID="+mid);		
		d.mylog(d.LOG_LEVEL_INFO, "Master id : "+d.master_id);
		
		String master_stat="FREE";
		
		
		while(true) {

			try {Thread.sleep(1000);} catch (InterruptedException e) {}

			if (d.isMadInstalled()) 
				d.sendMadNotifications(false);
			
			if (d.isMadInstalled())
				d.deleteUnsavedMadRequestsAndTempFiles();
			
			master_stat=d.getMasterStatus();

			
			d.runScriptPREPPOST();


			if (master_stat.equals("ASSIGNED")) {

				d.setMasterStatus("BUSY");

				//if (master_stat.equals("ASSIGNED")) {
				d.startKeepAliveConfDB();
				d.runMaster();
				d.stopKeepAliveConfDB();
				//}
					


				System.gc();

				if (d.heapUsedRate()>80) {
					System.out.println("Heap usage is too much!... Restarting. ");
					break;
				}
				

				d.renewAllWorkPackagesByMasterId(d.master_id);

				d.setMasterStatus("FREE");

			} 
			
			
			d.heartbeat(ConfDBOper.TABLE_TDM_MASTER,d.master_done_count,d.master_id);

			
			if (d.getCancelFlag("tdm_master")) {
				System.out.println("Master is cancelled...");
				break;
			}

		} //while
	
		d.stopMaster();
		d.closeAll();
		d=null;
	}

}
