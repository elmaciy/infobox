package com.mayatech.tdm;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.impl.client.DefaultHttpClient;


public class methodRunThread implements Runnable  {
	String url="";
	String params="";
	int timeout=Integer.MAX_VALUE;


	
	
	
	public methodRunThread(
			String url,
			String params,
			int timeout
			) {
		
		this.url=url;
		this.params=params;
		this.timeout=timeout;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
	 	
	 	
	 	System.out.println("Running method : " + params);
	 	
	 	long start_ts=System.currentTimeMillis();
	 	
	 	try {
	 		HttpClient client = new DefaultHttpClient();
		 	client.getParams().setIntParameter("http.connection.timeout", timeout);
		 	
		 	HttpUriRequest request = new HttpGet(url+"?"+params);
	 	    HttpResponse response = client.execute(request);
	 	    
	 	   System.out.println(url+"?"+params+ " Returns :[" + response.toString()+"]");
	 	    
	 	} catch(Exception e) {
	 		System.out.println("Exception@methodRunThread : "+e.getMessage());
	 		e.printStackTrace();
	 	}
	 	
	 	
	 	  
	 	long duration=System.currentTimeMillis()-start_ts;

	 	System.out.println("Done. Running method :  " + params  + " Duration : "+duration);
	 	
	 	
	 	
	}
	


	
	
	
}
