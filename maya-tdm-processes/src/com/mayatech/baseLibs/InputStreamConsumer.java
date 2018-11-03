package com.mayatech.baseLibs;

import java.io.InputStream;

public class InputStreamConsumer extends Thread {

	private InputStream is;
	StringBuilder sb=null;
	String command=null;

    public InputStreamConsumer(InputStream is, StringBuilder sb, String command) {
        this.is = is;
        this.sb=sb;
        this.command=command;
        
        
    }
    
    boolean stop=false;
    
    public void stopExecuting() {
        this.stop = true;
    }
    
    //---------------------------------
    @Override
    public void run() {
    	
    	try {
            int value = -1;
            while(true) {
            	if (stop) System.exit(0);
            	if (is.available()==0) continue;
            	value=is.read();
            	if (value==-1) continue;
                System.out.print((char) value);
                sb.append((char) value);
                
            }
        } catch (Exception exp) {
            exp.printStackTrace();
        }
    }
    
    
}
