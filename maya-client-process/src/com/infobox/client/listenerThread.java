package com.infobox.client;

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;



class listenerThread implements Runnable  {
	clientProxyDriver cp=null;
	
	ServerSocket ProxyserverSocket = null;
	PrintWriter out = null;
	BufferedReader in = null;
	
	boolean is_socket_opened=true;
	
	int BUFFER_SIZE=1024*1024;
	
	
	listenerThread(clientProxyDriver cp) {
		this.cp=cp;		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		try {
			ProxyserverSocket = new ServerSocket(cp.listener_port);
			   
			cp.mylog("PROXY is ready, listening port : "+ cp.listener_port+ " ...");
			} catch (Exception e) {
				cp.mylog("Port ["+cp.listener_port+"] Error! Quiting...");
			
				e.printStackTrace();
				e.printStackTrace();
				is_socket_opened=false;
				System.exit(0);
			}
		
		cp.mylog("Listening port : "+cp.listener_port+"...");
		
		while(true) {
			try {
				if (ProxyserverSocket.isBound()) {
					
					Socket clientSocket = ProxyserverSocket.accept();
					clientSocket.setKeepAlive(true);
					clientSocket.setReceiveBufferSize(BUFFER_SIZE);
					clientSocket.setSendBufferSize(BUFFER_SIZE);
					cp.mylog("Client is connected to port ["+cp.listener_port+"]...");
					
					
					new Thread(
				            new clientConnectionRunnable(
				            		cp,
				            		clientSocket, 
				            		cp.server_proxy_host,
				            		cp.server_proxy_port,
				            		BUFFER_SIZE
				            		)
								).start();
					
				} //if (ProxyserverSocket.isBound())
				else {
					try {Thread.sleep(50);} catch (InterruptedException e) {e.printStackTrace();}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			
			try{Thread.sleep(100);} catch(Exception e) {}
			
		} // while 
		
		
		
		
	}
	
	
	
	

}
