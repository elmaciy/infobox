package com.mayatech.Test;

import java.util.ArrayList;

import com.mayatech.tdm.ConfDBOper;
import com.mayatech.tdm.methodRunThread;


public class testRunMethod {
	

	
	public static void main(String[] args) {
			
		ConfDBOper d=new ConfDBOper(false);
		
		ThreadGroup methodRunThreadGroup = new ThreadGroup("Method Runner Thread Group");
		
		String url="http://localhost:9090/mayapp-deployment/runMethod.jsp";
		int max_rec=100;
		int timeout=60*1000;
		
		int MAX_THREAD=10;
		
		
		String sql="select cl.id, cl.token \n"+
					"	from mad_method_call_logs cl, mad_flow_state_action_methods am \n"+
					"	where cl.status not in ('FINISHED') \n"+
					"	and action_method_id=am.id \n"+
					"	and cl.attempt_no<am.retry_count+1 \n"+
					"	order by 1 desc";
		
		
		ArrayList<String[]> arr=d.getDbArrayConf(sql, max_rec);
		
		for (int i=0;i<arr.size();i++) {
			
			String id=arr.get(i)[0];
			String token=arr.get(i)[1];
			
			String params="id="+id+"&token="+token;
			
			d.mylog(d.LOG_LEVEL_INFO,  "Running ASYNCH method ("+params+")...");
			
			String thread_name="COUNTING_THREAD_"+System.currentTimeMillis();
			
			try {
				Thread thread=new Thread(methodRunThreadGroup, new methodRunThread(url, params, timeout) ,thread_name);
				thread.start();
				Thread.sleep(100);
			} catch(Exception e) {
				d.mylog(d.LOG_LEVEL_ERROR, "Exception@methodRunThread : "+ e.getMessage());
				e.printStackTrace();
			}
			
			int active_thread_count=methodRunThreadGroup.activeCount();
			
			if (active_thread_count>=MAX_THREAD) {
				int x=0;
				
				while(true) {
					
					d.mylog(d.LOG_LEVEL_ERROR, "Max Method Runner Thread ["+MAX_THREAD+"] reached. Waiting... ");
					try {Thread.sleep(1000);} catch(Exception e) {}
					x++;
					active_thread_count=methodRunThreadGroup.activeCount();
					if (active_thread_count<MAX_THREAD) break;
					if (x>120) break;
				}
				
				if (x>120) break;
			}
			
		}
		
		d.closeAll();
			

		
		}

		
		
	
}
