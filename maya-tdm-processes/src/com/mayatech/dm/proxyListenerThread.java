package com.mayatech.dm;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.sql.Connection;

import com.mayatech.baseLibs.genLib;


class proxyListenerThread implements Runnable  {
	
	ddmProxyServer dm;
	int listener_port=0;
	
	
	ServerSocket ProxyserverSocket = null;
	PrintWriter out = null;
	BufferedReader in = null;
	
	boolean is_socket_opened=true;
	
	
	Connection connListener;
	
	proxyListenerThread(
			ddmProxyServer dm,
			int listener_port
			) {
		
		this.dm=dm;
		this.listener_port=listener_port;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {


		connListener=ddmLib.getTargetDbConnection(dm.conf_db_driver, dm.conf_db_url, dm.conf_db_username,dm.conf_db_password);
				
		try {
			ProxyserverSocket = new ServerSocket(listener_port);
			   
			dm.mylog("PROXY is ready, listening port : "+ this.listener_port+ " ...");
			} catch (Exception e) {
				dm.mylog("Port ["+listener_port+"] Error!");
			
				e.printStackTrace();
				String error=genLib.getStackTraceAsStringBuilder(e).toString();
				is_socket_opened=false;
				
				ddmLib.setProxyError(connListener, dm.proxy_id,error); 
				
			
			}
		
		

		while(is_socket_opened) {
			
			if (dm.is_proxy_cancelled) break;
			
			if (!ddmLib.validateMySQLConnection(connListener)) {
				dm.mylog("Connection connListener for listener port ["+listener_port+"] is not valid. Trying to reestablish.");
				try {Thread.sleep(1000); } catch(Exception e) {}
				connListener=ddmLib.getTargetDbConnection(dm.conf_db_driver, dm.conf_db_url, dm.conf_db_username,dm.conf_db_password);
				continue;
			}

			try {
				if (ProxyserverSocket.isBound()) {
					startClientConnection();
					
				} else {
					try {Thread.sleep(10);} catch (InterruptedException e) {e.printStackTrace();}
					
				}
					
				
			} catch (Exception e) {
				e.printStackTrace();
			}
			
			try{Thread.sleep(100);} catch(Exception e) {}

			
		} //while
		
		
		dm.decreaseActiveListenerCount();
		
		closeListenerResources();
		
		
	 	
	} //run
	
	//----------------------------------------------------------------
	
	
	
	synchronized boolean startClientConnection() {
		
		int heaprate=dm.heapUsedRate();
		
		
		
		try {
			Socket clientSocket = ProxyserverSocket.accept();
			clientSocket.setKeepAlive(true);
			clientSocket.setReceiveBufferSize(dm.BUFFER_SIZE);
			clientSocket.setSendBufferSize(dm.BUFFER_SIZE);
			dm.mylog("Client is connecting to port ["+listener_port+"]...");
			
			if (heaprate>=80) {
				dm.mylog("Heap rate ("+heaprate+"%) is too high. Client connection declined.");
				try{clientSocket.close();} catch(Exception e) {}
				return false;
			}
			
			dm.mylog("Client is connected to port ["+listener_port+"]...");
			
			String thread_name="CLIENT_"+listener_port+"_"+System.currentTimeMillis();
			
					new Thread(	dm.clientThreadGroup, 
					            new clientConnectionRunnable(
					            		dm,
					            		clientSocket, 
					            		listener_port,
					            		dm.server_host,
					            		dm.server_port,
					            		dm.BUFFER_SIZE
					            		),
			            		thread_name	
						).start();
		} catch(Exception e) {
			
			dm.mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			return false;
		}
		
		return true;
		
	}
	//----------------------------------------------------------------
	void closeListenerResources() {
		
		//TODO : close all client connections
		
        try {ProxyserverSocket.close();} catch (IOException e) {}
        
        
        try {out.close();} catch (Exception e) { }
        try {in.close();} catch (Exception e) { }
        
        ddmLib.closeConn(connListener);
	}
	
	
}
