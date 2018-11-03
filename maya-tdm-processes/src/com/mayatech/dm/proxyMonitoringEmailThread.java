package com.mayatech.dm;

import java.util.ArrayList;



class proxyMonitoringEmailThread implements Runnable  {
	
	ddmProxyServer dm;
	int proxy_id;
	

	proxyMonitoringEmailThread(
			ddmProxyServer dm,
			int proxy_id
			) {
		
		this.dm=dm;
		this.proxy_id=proxy_id;
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		StringBuilder monitoring_id=new StringBuilder();
		StringBuilder emailbody=new StringBuilder();
		StringBuilder to_address=new StringBuilder();
		StringBuilder sbErr=new StringBuilder();
		
		String sql="insert into tdm_proxy_monitoring_email_log (proxy_id,monitoring_id,from_address,to_address,email_body,sent_date,is_success,sending_logs) "+
						" values (?,?,?,?,?,now(), ?,?)";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		
		while(true) {
			if (dm.is_proxy_cancelled) break;
			
			ddmLib.setGetViolationEmailList(dm, monitoring_id, emailbody, to_address, ddmLib.MONITORING_ACTION_GET); 
			
			if (emailbody.length()==0) {
				try{Thread.sleep(1000);} catch(Exception e) {}
				continue;
			}
			
			String from="info@infobox.com.tr";
			String subject="InfoboxTDM : Monitoring violation report";
			boolean is_ok=ddmLib.sendMail(dm, from, to_address.toString(), subject, emailbody, sbErr);
			
			String is_success="NO";
			if (is_ok) is_success="YES";
			
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+dm.proxy_id});
			bindlist.add(new String[]{"INTEGER",""+monitoring_id.toString()});
			bindlist.add(new String[]{"STRING",""+from.toString()});
			bindlist.add(new String[]{"STRING",""+to_address.toString()});
			bindlist.add(new String[]{"STRING",""+emailbody.toString()});
			bindlist.add(new String[]{"STRING",""+is_success});
			bindlist.add(new String[]{"STRING",""+sbErr.toString()});
			
			
			ddmLib.execSingleUpdateSQL(dm.connConf, sql, bindlist);
			
		}
	
	
	}
	

	
	
	
}
