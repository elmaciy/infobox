package com.infobox.client;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.nio.charset.Charset;

import javax.crypto.Cipher;


public class clientProxyDriver {
	
	
	boolean is_debug=true;
	int listener_port=2521;
	String server_proxy_host="localhost";
	int server_proxy_port=1522;
	String charset="utf-8";
	
	StringBuilder token=new StringBuilder();
	byte[] public_key_byte_arr="920A!Dsl091ad@kl".getBytes();
	
	
	int FROM_CLIENT=1;
	int FROM_SERVER=2;
	
	//**************************************************
	void mydebug(String logstr) {
		if (is_debug) mylog(logstr);
	}
	//**************************************************
	void mylog(String logstr) {
		System.out.println(logstr);
	}
	//**************************************************
	void loadConfiguration()  {
		mylog("Loading configuraiton...");
		
		
		mylog("listener_port................................:"+listener_port);
		mylog("server_proxy_host............................:"+server_proxy_host);
		mylog("server_proxy_port............................:"+server_proxy_port);
		mylog("charset......................................:"+charset);
		mylog("public_key_byte_arr..........................:"+new String(public_key_byte_arr,Charset.forName(charset)));
		
		
		boolean is_success=true;
		
		
		if (!is_success) {
			mylog("Loading configuration is failed. Closing...");
			System.exit(0);
		}
		mylog("Done.");
	}
	
	
	//**************************************************
	ThreadGroup tg = new ThreadGroup("Proxy Listener Thread Group");
	void startTokenChangerThread() {
		String thread_name="TOKEN_CHANGER"+System.currentTimeMillis();
		
		try {
			Thread thread=new Thread(tg, new tokenChangerThread(this),thread_name);
			thread.start();
		} catch(Exception e) {
			e.printStackTrace();
			System.exit(0);
		}
	}
	//**************************************************
	void startListenerThread() {
		String thread_name="LISTENER_"+System.currentTimeMillis();
		
		try {
			Thread thread=new Thread(tg, new listenerThread(this),thread_name);
			thread.start();
		} catch(Exception e) {
			e.printStackTrace();
			System.exit(0);
		}
	}
	
	

	
	//**************************************************
	synchronized void setGetToken(String action, StringBuilder token_to_set) {
		if (action.equals("SET")) {
			token.setLength(0);
			token.append(""+System.currentTimeMillis());
			mylog("New token set to : "+token.toString());
			return;
		}
		
		
		//GET 
		token_to_set.setLength(0);
		token_to_set.append(this.token.toString());
	}
	
	
	//*********************************************

	 public static int byte2UnsignedInt(byte b) {
		    return b & 0xFF;
		  }
	//-----------------------------------------------------------------------

	public  void printByteArray(byte[] buf, int len) {
		printByteArray(buf, 0, len);
	}
	
	
	//-----------------------------------------------------------------------
	static final String visible_chars=new String(" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456456789*()_.?;:<>=\"'\\/@$+-*,`");
	
	public  void printByteArray(byte[] buf, int start, int len) {
	
	if (!is_debug) return;
	
	try {
		StringBuilder sb=new StringBuilder();
		
		for (int i=start;i<start+len;i++) {
			if (visible_chars.indexOf(buf[i])>-1)
				//System.out.print(new String(buf,i,1));
				sb.append(new String(buf,i,1));
			else 
				//System.out.print("["+ ddmLib.byte2UnsignedInt(buf[i])   +"]");
				sb.append("["+ byte2UnsignedInt(buf[i])   +"]");
		}
		
		//System.out.println("");
		sb.append("\n");
		
		mydebug(sb.toString());
	} catch(Exception e) {
		e.printStackTrace();
	}
		
	
	
	}
	
	//------------------------------------------------------
	int checkPackage(
			byte[] buf, 
			int len, 
			int origin, 
			DataInputStream from_server_stream,
			DataOutputStream to_server_stream,
			DataInputStream from_client_stream,
			DataOutputStream to_client_stream,
			Cipher cipher_decoder,
			byte[] cipher_key
			) {
		int ret1=len;
		
		if (origin==FROM_CLIENT) {
			//mydebug("From Client Original : ");
			//printByteArray(buf, len);
		} else {
			//mydebug("From Server Encoded: ");
			//printByteArray(buf, len);
			
			/*
			mydebug("From Server Decoded: ");
			buf=proxyLib.decryptByteArray(cipher_decoder, buf, cipher_key);
			int buf_len=buf.length;
			
			printByteArray(buf, buf_len);
			return buf_len;
			*/
		}
		
		return ret1;
		
	}
	//**************************************************
	public static void main(String[] args) {

		clientProxyDriver client=new clientProxyDriver();
		

		client.loadConfiguration();
		
		client.startTokenChangerThread();
		
		client.startListenerThread();
		
		while(true) try{Thread.sleep(1000);} catch(Exception e) {}
		

	}

}
