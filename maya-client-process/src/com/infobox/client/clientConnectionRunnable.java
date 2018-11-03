package com.infobox.client;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.net.UnknownHostException;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class clientConnectionRunnable implements Runnable {

	clientProxyDriver cp=null;
	protected Socket clientSocket = null;
	
    String server_proxy_host="";
    int server_proxy_port=0;
    Socket ProxyserverSocket =null; 
    byte[] buf_from_client=null;
    byte[] buf_from_server=null;

    
    int BUFFER_SIZE=4096*10;
    
    Cipher cipher_encoder =null;
   	Cipher cipher_decoder =null;
   
    
    public clientConnectionRunnable(
    		clientProxyDriver cp,
    		Socket clientSocket, 
    		String server_proxy_host,
    		int server_proxy_port,
    		int BUFFER_SIZE
    		) {
        this.cp=cp;
    	this.clientSocket = clientSocket;
        this.server_proxy_host=server_proxy_host;
        this.server_proxy_port=server_proxy_port;
        this.BUFFER_SIZE=BUFFER_SIZE;
        
        buf_from_client=new byte[this.BUFFER_SIZE];
        buf_from_server=new byte[this.BUFFER_SIZE];
        
        
        
    }
    
    
    //----------------------------------------------------------------

    
    public void run() {

    	if (!initCiphers()) return;

    	DataInputStream from_client = null;
    	DataOutputStream to_client = null;
    	DataInputStream from_server = null;
    	DataOutputStream to_server = null;
    	
    	
    	//---------------------------------
    	
    	boolean socket_ok=false;
    	
    	try {
			System.out.println("Connecting to "+server_proxy_host+":"+server_proxy_port+"...");
			
			
    		ProxyserverSocket = new Socket(server_proxy_host, server_proxy_port);
    		ProxyserverSocket.setKeepAlive(true);
    		ProxyserverSocket.setSendBufferSize(BUFFER_SIZE);
    		ProxyserverSocket.setReceiveBufferSize(BUFFER_SIZE);
    		

    		
    		System.out.println("Connected to "+server_proxy_host+":"+server_proxy_port+"...");
    		
    		from_server=new DataInputStream(new BufferedInputStream(ProxyserverSocket.getInputStream()));
    		to_server=new DataOutputStream(new BufferedOutputStream(ProxyserverSocket.getOutputStream()));
    		
    		socket_ok=true;
    		
		} catch (UnknownHostException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
    	
    	//---------------------------------
    	
    	
    	
    	
    	
    	boolean client_disconnect=false;
        boolean server_disconnect=false;
    	
    	
    	
    	
    	if (socket_ok)    	
	    	try {
	
	    		from_client = new DataInputStream(new BufferedInputStream(clientSocket.getInputStream()));
	    		to_client = new DataOutputStream(new BufferedOutputStream(clientSocket.getOutputStream()));
	    		
	    		
	            
	            
	            int read_size=0;
	            
	            int available_from_client_size=0;
	            int read_from_client_size=0;
	            int block_size_for_client=0;
	            
	            int available_from_server_size=0;
	            int read_from_server_size=0;
	            int block_size_for_server=0;
	            
	            //long sleep_time=1;
	            
	            boolean break_loop=false;
	            
	            long last_client_read_ts=System.currentTimeMillis();
	            long last_check_client_ts=System.currentTimeMillis();
	            
	           
	           // int changed_read_size=0;
	            
	            		
	            while(!break_loop) {
	            	
	            	
	            	if (client_disconnect || server_disconnect) break;
	            	
	            	//Check coming stream from client and 
	            	//if available, send it to server directly
	            	available_from_client_size=from_client.available();
	            	
	            	
	            	if (available_from_client_size>0) {
	            		block_size_for_client=available_from_client_size;
	            		if(available_from_client_size>BUFFER_SIZE) 
	            			block_size_for_client=BUFFER_SIZE;
	            		
	            		read_from_client_size=0;

	            		            		
	            		
	            		while(true) {
	            			
	            			read_size=from_client.read(buf_from_client, 0, block_size_for_client);
	            			last_client_read_ts=System.currentTimeMillis();


	            			if (read_size==-1) {
	            				System.out.println("Client read error...");
	            				client_disconnect=true;
	            				break;
	            			}


	            			/*
	            			changed_read_size=cp.checkPackage(buf_from_client,read_size, cp.FROM_CLIENT, 
	            					from_server, to_server, 
	            					from_client, to_client, 
	            					null, null); 
							*/

	            			
            				cp.mydebug("Original bytes from client : "+read_size);
            				cp.printByteArray(buf_from_client, read_size);
            				
            				
            				byte[] encodedbuf=proxyLib.ecryptByteArray(cipher_encoder, buf_from_client, read_size);
            				int encoded_len=encodedbuf.length;
            				
            				cp.mydebug("Encoded bytes from client : "+encoded_len);
            				cp.printByteArray(encodedbuf, encoded_len);
            				//cp.printByteArray(encodedbuf);
            				
            				to_server.write(buf_from_client, 0, read_size);
            				//to_server.write(encodedbuf, 0, encoded_len);
                			to_server.flush();
	                			
	                			
                			cp.mydebug("written successfullly.");
	            			
	            			
	            			read_from_client_size+= Math.abs(read_size) ;
	            			if (read_from_client_size>=available_from_client_size) {
	            				to_server.flush();
	            				break;
	            			}
	            			
	            		}
	            		            			            		
	            		
	            	}
	           
	            	
	            	//Check coming stream from server 
	            	available_from_server_size=from_server.available();
	            	
	            	
	            	if (available_from_server_size>0) {
	            		block_size_for_server=available_from_server_size;
	            		if(available_from_server_size>BUFFER_SIZE) 
	            			block_size_for_server=BUFFER_SIZE;
	            		
	            		read_from_server_size=0;
	            		
	            		
	            		
	            		while(true) {
	            			
	            			read_size=from_server.read(buf_from_server, 0, block_size_for_server);
	            			
	            			            			
	            			if (read_size==-1) {
	            				cp.mylog("Server read error...");
	            				server_disconnect=true;
	            				break;
	            			} 
	            			
	            			
	            			/*
            				changed_read_size=cp.checkPackage(buf_from_server,read_size, cp.FROM_SERVER, 
            						from_server, to_server, 
            						from_client, to_client,
            						cipher_decoder, cp.public_key_byte_arr);
	            			*/
	            			
            				to_client.write(buf_from_server, 0, read_size);
	            			//to_client.flush();
	            			
	            			
	            			
	            			read_from_server_size+=read_size;
	            			
	            			if (read_from_server_size>=available_from_server_size) {
	            				to_client.flush();
	            				break;
	            			}
	            			
	            		}
	            		
	            	} 
	            	else Thread.sleep(1);
	            	


	            	
	            	
	            	

	            } //while !break
	            
	
	            
	
	    	} catch(Exception e) {
	    		e.printStackTrace();
	    	}
    	
    	System.out.println("Closing client ...");
    	
    	
    	
    	try{to_client.close();} catch(Exception e) {}
    	try{from_client.close();} catch(Exception e) {}
    	try{from_server.close();} catch(Exception e) {}
    	try{to_server.close();} catch(Exception e) {}
    	
    	try{clientSocket.close();} catch(Exception e) {}
    	try{ProxyserverSocket.close();} catch(Exception e) {}
    	
    	
    	


    	System.out.println("Bye...");
    	
    	
        
    }
    
    

  //----------------------------------------------------------------
    
   
	
    boolean initCiphers() {


    	
    	try {
    		cp.mylog("initializing encoder cipher... ");
			cipher_encoder = Cipher.getInstance(proxyLib.cipher_method);
			SecretKeySpec secretKey1 = new SecretKeySpec(cp.public_key_byte_arr, proxyLib.AES);
			cipher_encoder.init(Cipher.ENCRYPT_MODE, secretKey1, proxyLib.ivspec);
			
			cp.mylog("initializing decoder cipher... ");
			cipher_decoder = Cipher.getInstance(proxyLib.cipher_method);
			SecretKeySpec secretKey2 = new SecretKeySpec(cp.public_key_byte_arr, proxyLib.AES);
			cipher_decoder.init(Cipher.DECRYPT_MODE, secretKey2, proxyLib.ivspec);

			cp.mylog("ciphers initialized. ");
			
			return true;
			 
		} catch(Exception e) {
			e.printStackTrace();
			cp.mylog("ciphers is NOT initialized... ");
			return false;
		}
    }
    
    
}
