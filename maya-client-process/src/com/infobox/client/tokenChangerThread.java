package com.infobox.client;



class tokenChangerThread implements Runnable  {
	clientProxyDriver cp=null;
	
	static final int TOKEN_CHANGE_INTERVAL=60000;
	long last_token_change_ts=0;
	
	
	tokenChangerThread(clientProxyDriver cp) {
		this.cp=cp;		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		while(true) {
			if (System.currentTimeMillis()>(last_token_change_ts+TOKEN_CHANGE_INTERVAL)) {
				cp.setGetToken("SET",null);
				last_token_change_ts=System.currentTimeMillis();
			}
			try{Thread.sleep(1000);} catch(Exception e) {}
			
		}
	}
	

}
