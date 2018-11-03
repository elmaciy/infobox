package com.mayatech.maskdisc;




class maskDiscCheckCancelThread implements Runnable  {
	
	maskDiscServer  discoverer;
	int discovery_id;
	
	
	
	
	int SET_CHECK_CANCEL_INTERVAL=3000;
	
	
	
	
	
	maskDiscCheckCancelThread(
			maskDiscServer discoverer,
			int discovery_id
			) {
		
		this.discoverer=discoverer;
		this.discovery_id=discovery_id;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		
		long next_check_cancel_ts=System.currentTimeMillis();
		
		
		while(true) {
			
			if (discoverer.is_server_cancelled) break;
			if (discoverer.is_discovery_finished) break;
			
			
			if (System.currentTimeMillis()>next_check_cancel_ts) {
				discoverer.checkCancel();
				next_check_cancel_ts=System.currentTimeMillis()+SET_CHECK_CANCEL_INTERVAL;
			}
				

			
			try {Thread.sleep(1000); } catch(Exception e) {}
			
			
		}
		
		
		
	 	
	}
	
	
	
}
