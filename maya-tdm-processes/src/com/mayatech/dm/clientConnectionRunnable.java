package com.mayatech.dm;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Date;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import com.mayatech.baseLibs.genLib;

public class clientConnectionRunnable implements Runnable {

	ddmProxyServer dm=null;
	protected Socket clientSocket = null;
	int listener_port=0;
    String server_host="";
    int server_port=0;
    Socket ProxyserverSocket =null; 
    byte[] buf_from_client=null;
    byte[] buf_from_server=null;
    
  //  boolean client_cancelled=false;
    
    ddmClient packageObj=null;
    
    ArrayList<String> sqlStatements=new ArrayList<String>();
    
    int BUFFER_SIZE=4096*10;
    
    Cipher cipher_encoder =null;
	Cipher cipher_decoder =null;
   
    
    public clientConnectionRunnable(
    		ddmProxyServer dm,
    		Socket clientSocket, 
    		int listener_port,
    		String server_host,
    		int server_port,
    		int BUFFER_SIZE
    		) {
        this.dm=dm;
    	this.clientSocket = clientSocket;
    	this.listener_port=listener_port;
        this.server_host=server_host;
        this.server_port=server_port;
        this.BUFFER_SIZE=BUFFER_SIZE;
        
        buf_from_client=new byte[this.BUFFER_SIZE];
        buf_from_server=new byte[this.BUFFER_SIZE];
        
        
        
    }
    
    
    //----------------------------------------------------------------
    boolean initCiphers() {
    	if (!dm.is_secure_client) return true;
    	
    	try {
			dm.mylog("initializing encoder cipher... ");
			cipher_encoder = Cipher.getInstance(ddmLib.cipher_method);
			SecretKeySpec secretKey1 = new SecretKeySpec(dm.public_key_byte_arr, ddmLib.AES);
			cipher_encoder.init(Cipher.ENCRYPT_MODE, secretKey1, ddmLib.ivspec);
			
			dm.mylog("initializing decoder cipher... ");
			cipher_decoder = Cipher.getInstance(ddmLib.cipher_method);
			SecretKeySpec secretKey2 = new SecretKeySpec(dm.public_key_byte_arr, ddmLib.AES);
			cipher_decoder.init(Cipher.DECRYPT_MODE, secretKey2, ddmLib.ivspec);

			dm.mylog("ciphers initialized. ");
			
			return true;
			
		} catch(Exception e) {
			e.printStackTrace();
			dm.mylog("ciphers is NOT initialized... ");
			return false;
		}
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
			
    		packageObj=new ddmClient(dm);
    		
    		packageObj.client_iddle_timeout=dm.DYNAMIC_CLIENT_IDDLE_TIMEOUT;
    		packageObj.mydebug("client_iddle_timeout : "+packageObj.client_iddle_timeout);
    		
    		packageObj.client_log_statement=dm.DDM_LOG_STATEMENT;
    		packageObj.mydebug("client_log_statement : "+packageObj.client_iddle_timeout);
    		
    		packageObj.extra_args=dm.proxy_extra_args;
    		packageObj.mydebug("extra_args : "+packageObj.extra_args);
    		

    		packageObj.mylog("Connecting to "+server_host+":"+server_port+"...");
			
			
    		ProxyserverSocket = new Socket(server_host, server_port);
    		ProxyserverSocket.setKeepAlive(true);
    		ProxyserverSocket.setSendBufferSize(BUFFER_SIZE);
    		ProxyserverSocket.setReceiveBufferSize(BUFFER_SIZE);
    		

    		
    		packageObj.mylog("Connected to "+server_host+":"+server_port+"...");
    		
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
    	
        packageObj.CLIENT_PORT=listener_port;
    	
    	try {
    		packageObj.CLIENT_HOST_ADDRESS=ddmLib.nvl(clientSocket.getInetAddress().getHostName(),"");
    		
    		packageObj.CLIENT_PORT=listener_port;
    		
    		if (packageObj.CLIENT_HOST_ADDRESS.length()==0) throw new Exception();
    	} catch(Exception e) {
    		
    		try {
        		packageObj.CLIENT_HOST_ADDRESS=ddmLib.nvl(clientSocket.getInetAddress().getCanonicalHostName(),"");
        		if (packageObj.CLIENT_HOST_ADDRESS.length()==0) throw new Exception();
        	} catch(Exception ex) {
        		try {
            		packageObj.CLIENT_HOST_ADDRESS=ddmLib.nvl(clientSocket.getInetAddress().getHostAddress(),"");
            		if (packageObj.CLIENT_HOST_ADDRESS.length()==0) throw new Exception();
            	} catch(Exception ex2) {
            		packageObj.CLIENT_HOST_ADDRESS="unknown";
            	}
        	}
    		
    	}
    	
    	
    	
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
	            
	            int changed_read_size=0;
	            
	            int thread_sleep_duration=10;
	            	
	            while(!break_loop) {
	            	
	            	ddmLib.checkIdenticalValidatedSessionsAndTimeout(packageObj);
	            	
	            	ddmLib.checkSessionLimit(packageObj);
	            	
	            	ddmLib.checkBlacklist(packageObj);
	            	
	            	if (dm.is_proxy_cancelled ||  packageObj.client_cancelled || client_disconnect || server_disconnect ) 
	            		{
		            		packageObj.mylog("Client is cancelled.");
		            		break_loop=true;
		            		break;
	            		}
	            	
	            	if (packageObj.package_state==packageObj.STATE_STATEMENT_BUILDING &&  packageObj.last_statement_start_ts+packageObj.STATEMENT_BUILD_TIMEOUT<System.currentTimeMillis()) {
	            		packageObj.mydebug("Resending cached package(s) since it is stalled.");
	            		packageObj.sendSavedPackages(to_server);
	            		to_server.flush();

	            		packageObj.restartPackage();
	            		packageObj.clearPackage();
	            		packageObj.last_statement_start_ts=System.currentTimeMillis();
	            	}
	            	
	            	

	            	
	            
	            	
	            	//Check coming stream from client and 
	            	//if available, send it to server directly
	            	available_from_client_size=from_client.available();
	            	
	            	if (available_from_client_size>0) {
	            		block_size_for_client=available_from_client_size;
	            		if(available_from_client_size>BUFFER_SIZE) 
	            			block_size_for_client=BUFFER_SIZE;
	            		
	            		read_from_client_size=0;

	            		            		
	            		haeartbeatClient();
	            		
	            		while(true) {
	            			
	            			
	            			read_size=from_client.read(buf_from_client, 0, block_size_for_client);
	            			last_client_read_ts=System.currentTimeMillis();
	            			


	            			if (read_size==-1) {
	            				packageObj.mylog("Client read error...");
	            				client_disconnect=true;
	            				break;
	            			}

	            			if (dm.is_secure_client) {
	            				packageObj.mydebug("decoding bytes read from client...");
	            				
	            				packageObj.mydebug("Encoded Bytes : "+read_size);
	            				packageObj.printByteArray(buf_from_client, 0, read_size);
	            				
	            				buf_from_client=ddmLib.decryptByteArray(cipher_decoder, buf_from_client, read_size);
	            				read_size=buf_from_client.length;
	            				
	            				packageObj.mydebug("Decoded Bytes : "+read_size);
	            				packageObj.printByteArray(buf_from_client, 0, read_size);
	            			}
	            			
	            			
	            			changed_read_size=dm.checkPackage(packageObj, buf_from_client,read_size, dm.FROM_CLIENT, from_server, to_server, from_client, to_client); 
	            			
	            			if (packageObj.client_cancelled) {break_loop=true; break;}
	            			
	            			

	            			if (changed_read_size>0) {
	            				to_server.write(buf_from_client, 0, changed_read_size);
	            				to_server.flush();
	            			} 

	            			
	            			
	            			read_from_client_size+= Math.abs(read_size) ;
	            			if (read_from_client_size>=available_from_client_size) {
	            				to_server.flush();
	            				break;
	            			}
	            			
	            		}
	            		            			            		
	            		
	            	}
	            	//no data from client, test client connection
	            	else {
	            		
	            		if (System.currentTimeMillis()>last_client_read_ts+packageObj.client_iddle_timeout) {
	            			packageObj.mydebug("Stalled session ["+packageObj.proxy_session_id+"] found. Closing...");
	            			client_disconnect=true;
	            			break_loop=true;
	            			packageObj.client_cancelled=true;

	            			break;
	            			
	            		} 
	            		
	            		
	            		if (System.currentTimeMillis()>last_check_client_ts+dm.CHECK_CLIENT_CONFIGURATION) {
	            			last_check_client_ts=System.currentTimeMillis(); 
	            			packageObj.flushlogs(false);
	            			checkClientStatus();
	            			checkCalendarException();
	            				
	            		}
	            		
	            		
	            		
	            		if (!break_loop && System.currentTimeMillis()>last_client_read_ts+dm.TEST_PARALLEL_DB_CONNECTION_TIMEOUT) {
	            			
	            			boolean is_conn_ok= packageObj.testConnection();
	            			last_client_read_ts=System.currentTimeMillis();
	            			if (!is_conn_ok) {
	            				client_disconnect=true;
	            				break_loop=true;
	            				packageObj.mydebug("Parallel connection lost... Client will be disconnected.");
	            				
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
	            		
	            		haeartbeatClient();
	            		
	            		while(true) {
	            			
	            			read_size=from_server.read(buf_from_server, 0, block_size_for_server);
	            			
	            			            			
	            			if (read_size==-1) {
	            				packageObj.mylog("Server read error...");
	            				server_disconnect=true;
	            				break;
	            			} 
	            			
	            			
	            			
            				changed_read_size=dm.checkPackage(packageObj, buf_from_server,read_size, dm.FROM_SERVER, from_server, to_server, from_client, to_client);
	            			
            				
            				
            				if (changed_read_size>0) {
            					to_client.write(buf_from_server, 0, changed_read_size);
            					to_client.flush();
            					
            					
            				}
            					
            				
            				
	            			
            				if (packageObj.client_cancelled) { break_loop=true; break;}
            				
	            			
	            			read_from_server_size+=read_size;
	            			
	            			if (read_from_server_size>=available_from_server_size) {
	            				to_client.flush();
	            				break;
	            			}
	            			
	            		}
	            		
	            	} 
	            	
	            	
	            	
	            	
	            	
	            	if (available_from_client_size==0 && available_from_server_size==0)  {
	            		thread_sleep_duration+=1;
	            		if (thread_sleep_duration>=1000) thread_sleep_duration=1000;
	            		Thread.sleep(thread_sleep_duration);
	            	} else {
	            		ddmLib.checkReceivedBytes(packageObj);
	            		thread_sleep_duration=1;
	            	}
	            		
	            	
	            	//when configuration reloaded, refresh clients info, reset argument parameters
	            	if (packageObj.is_authorized &&  packageObj.client_last_configuration_ts<dm.last_configuration_load_time) 
	            		packageObj.setPolicyGroup();
	            		

	            } //while !break
	            
	
	            
	
	    	} catch(Exception e) {
	    		packageObj.mylog("Exception@clientConnectionRunnable : "+genLib.getStackTraceAsStringBuilder(e).toString());
	    	}
    	
    	packageObj.mylog("Closing client ... proxy session id : "+packageObj.proxy_session_id);
    	
    	
    	packageObj.flushlogs(true);
    	
    	try{to_client.close();} catch(Exception e) {}
    	try{from_client.close();} catch(Exception e) {}
    	try{from_server.close();} catch(Exception e) {}
    	try{to_server.close();} catch(Exception e) {}
    	
    	try{clientSocket.close();} catch(Exception e) {}
    	try{ProxyserverSocket.close();} catch(Exception e) {}
    	
    	
    	try{packageObj.connParallel.close();} catch(Exception e) {}
    	
    	if (client_disconnect)
    		dm.disconnectClient(packageObj.proxy_session_id);
    	else 
    		dm.closeClient(packageObj.proxy_session_id);
    	
    	//alinan bir validasyon varsa bu validasyonu cache den siler
    	ddmLib.resetSessionValidationCommonKey(packageObj);
    	
    	packageObj.mylog("Bye from client ..."+packageObj.proxy_session_id);
    	
    	
        
    }
    
    //*******************************************************************
    void checkCalendarException() {
    	
    	if (packageObj.calendarExceptionArr.size()==0) return;
    	Date now=new Date();

    	if (!packageObj.calendar_exception_flag)
	    	for (int i=0;i<packageObj.calendarExceptionArr.size();i++) {

	    		if (now.after(packageObj.calendarExceptionArr.get(i)[0]) && now.before(packageObj.calendarExceptionArr.get(i)[1]) ) {
	    			packageObj.calendar_exception_flag=true;

	    			return;
	    		}
	    	}
	    		
    	packageObj.calendar_exception_flag=false;
    	
    } 
    
    //*******************************************************************
    long last_check_client_status_ts=0;
    final int CLIENT_CHECK_TIMEOUT=1000;
    
    void checkClientStatus() {
    	
    	if (packageObj.client_cancelled) return;
    	if (dm.is_client_status_loading) return;
    	
    	if (System.currentTimeMillis()<last_check_client_status_ts+CLIENT_CHECK_TIMEOUT) return;
    	last_check_client_status_ts=System.currentTimeMillis();
    	
    	
    	
    	//System.out.println("Checking status...");
    	
    	String cancel_flag="NO";
    	String diff_as_minute="0";
    	String tracing_flag="NO";
    	
    	boolean is_found=false;
    	
    	for (int i=0;i<dm.clientStatusArray.size();i++) {
    		if (dm.clientStatusArray.get(i)[0].equals(packageObj.proxy_session_id)) {
    			cancel_flag=dm.clientStatusArray.get(i)[1];
    			diff_as_minute=dm.clientStatusArray.get(i)[2];
    			tracing_flag=dm.clientStatusArray.get(i)[3];
    			is_found=true;
    			break;
    		}
    	}
    	
    	if (!is_found) {
    		packageObj.temporary_exception_flag=false;
    		return;
    	}
    	
    	

    	if (!dm.is_debug && tracing_flag.equals("YES")) {
    		packageObj.is_tracing=true;
    		dm.mydebug("Going to tracing mode. Session ID : "+ packageObj.proxy_session_id);
    		
    	}
    	
    	if (cancel_flag.equals("YES")) {
    		packageObj.client_cancelled=true;
    		packageObj.temporary_exception_flag=false;
    		return;
    	}
    	
    	if (diff_as_minute.equals("0")) {
    		packageObj.temporary_exception_flag=false;
    		return;
    	}
    	
    	
    	
    	int diff_ass_minute_INT=0;
    	try {diff_ass_minute_INT=Integer.parseInt(diff_as_minute);} catch(Exception e) {};
    	
    	if (diff_ass_minute_INT<=0) {
    		packageObj.temporary_exception_flag=false;
    		return;
    	}
    	
    	dm.mydebug("Setting temporary exception flag");
    	
    	packageObj.temporary_exception_flag=true;
    	
    	
    	
    	
    	
    	
    }
    
    
    //******************************************************************
    long next_heartbeat_ts=0;
    static final int HEARTBEAT_INTERVAL=15000;
    
    void haeartbeatClient() {
    	
    	if (packageObj.client_cancelled) return;
    	
    	if (System.currentTimeMillis()<next_heartbeat_ts) return;
    	next_heartbeat_ts=System.currentTimeMillis()+HEARTBEAT_INTERVAL;


    	ddmLib.addProxyEvent(
    			dm,
    			dm.proxyEventArray, 
    			dm.HEARTBEAT,
				""+System.currentTimeMillis(),
				null,
				null,
				null,
				null,
				packageObj.proxy_session_id,
				null,
				null,
				null
				);
    }
    

    
    
    
    
}
