package com.mayatech.tdm;

import com.mayatech.baseLibs.genLib;


class testConnectionThread implements Runnable  {


	copyLib cpLib=null;
	
	
	
	testConnectionThread(
			copyLib cpLib
			) {
		
		this.cpLib=cpLib;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
	 	System.out.println("! testing connections  ...");

	 	String exception="";
	 	
	 	
	 	for (int i=0;i<cpLib.connArr.size();i++) {
	 		boolean conn_ok=false;
	 		
	 		
	 		String db_lease_status=cpLib.getDbInstanceStatus(i);
	 		
	 		//if it is not free, no need to test it.
	 		if (!db_lease_status.equals("FREE")) continue;
	 		
	 		try {
	 			System.out.println("*********************************************");
	 			System.out.println("TESTING CONNECTION ("+(i+1)+")...");
	 			//cpLib.connArr.get(i).isValid(5000);
	 			System.out.println("*********************************************");
	 			conn_ok=true;
	 		} catch(Exception e) {
	 			exception=genLib.getStackTraceAsStringBuilder(e).toString();
	 			conn_ok=false;
	 		}
	 		
	 		if (!conn_ok) {
	 			cpLib.mylog("Exception@ Connection is invalid TRC : "+exception);
	 			
	 			cpLib.error_flag=true;
	 			cpLib.global_error_count++;
	 			
	 			break;
	 		}
	 		
	 	}
	 	
	 	
	}


	
	
	
}
