package com.mayatech.dm;

import java.sql.Connection;
import java.util.ArrayList;


class proxyEventWriterThread implements Runnable  {
	
	ddmProxyServer dm;
	int proxy_id;
	ArrayList<String[]> proxyEventArray=null;
	
	
	Connection connLogWriter;
	
	
	
	proxyEventWriterThread(
			ddmProxyServer dm,
			int proxy_id,
			ArrayList<String[]> proxyEventArray
			) {
		
		this.dm=dm;
		this.proxy_id=proxy_id;
		this.proxyEventArray=proxyEventArray;
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		
		connLogWriter=ddmLib.getTargetDbConnection(dm.conf_db_driver, dm.conf_db_url, dm.conf_db_username,dm.conf_db_password);
		
		if (!ddmLib.validateMySQLConnection(connLogWriter)) {
			dm.mylog("Connection connLogWriter is not valid. Events will not be written...");
			return;
		}
		
		dm.persistProxyEvents(connLogWriter, proxyEventArray,  dm, proxy_id, true);

		ddmLib.closeConn(connLogWriter);
	
	}
	

	
	
	
	
}
