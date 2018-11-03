package com.mayatech.datapool;



class dataPoolCheckCancelThread implements Runnable  {
	
	dataPoolServer  dpool;
	int data_pool_instance_id;
	
	
	
	
	int SET_CHECK_CANCEL_INTERVAL=3000;
	
	
	
	
	
	dataPoolCheckCancelThread(
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
			
			
			if (System.currentTimeMillis()>next_check_cancel_ts) {
				dpool.checkCancel();
				next_check_cancel_ts=System.currentTimeMillis()+SET_CHECK_CANCEL_INTERVAL;
			}
				

			
			try {Thread.sleep(1000); } catch(Exception e) {}
			
			
		}
		
		
		
	 	
	}
	
	
	
}
