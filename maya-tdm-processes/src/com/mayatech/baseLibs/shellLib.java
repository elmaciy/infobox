package com.mayatech.baseLibs;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class shellLib {

	String start_cmd="";
	String start_path="";
	
	
	Logger logger=LogManager.getLogger(this.getClass());
	
	
	//************************************************************************
	
	public shellLib(String start_cmd, String start_path) {
		this.start_cmd=start_cmd;
		this.start_path=start_path;
	}
	
	//************************************************************************
	void mylog(StringBuilder logsb, String log_str) {
		logsb.append(log_str+"\n");
		logger.info(log_str); ;
	}
	
	
	public boolean performDeployment(String cmd_list, StringBuilder logs) {
		
		
		ProcessBuilder pb =null;
				
		try {
			pb = new ProcessBuilder(start_cmd);
			if (start_path.trim().length()>0) {
				File f=new File(start_path);
				if (f.exists()) pb.directory(f);
				pb.redirectErrorStream(true);
			}
		} catch(Exception e) {
			pb =null;
			mylog(logs, genLib.getStackTraceAsStringBuilder(e).toString());
		}
		
		if (pb==null) {
			mylog(logs, "Process builder no initialized.");
			return false;
		}
 
		
		
		String[] cmds=cmd_list.split("\n|\r");
		
		String a_cmd_line="";
		
		
		InputStream input = null;
		OutputStream sendkeys =null;
		
		InputStreamConsumer stdout=null;
		
		Process p=null;
		
		
		StringBuilder cmd_output=new StringBuilder();
		
		if (p==null) {
			mylog(logs, "Starting command line ..");
			try{
				p=pb.start();
				mylog(logs, "command line is ready ..");
				} catch(Exception e) {p=null; mylog(logs,genLib.getStackTraceAsStringBuilder(e).toString());}
			
			
		}
		
		if (p==null) {
			mylog(logs, "command line not initiated ..");
			return false;
		}
		
		input=p.getInputStream();
		
		
		sendkeys = p.getOutputStream();
		
		stdout=new InputStreamConsumer(input, cmd_output, "");
		stdout.start();
		
		int cmd_id=-1;
		
		long wait_timeout=0;
		String wait_statement="";
		while (true) {
			
			try {
				
				cmd_id++;
				try {a_cmd_line=cmds[cmd_id].trim();} catch(Exception e) {break;}

				wait_statement="";
				wait_timeout=1000;
				
				String next_cmd="";
				try {next_cmd=cmds[cmd_id+1].trim();} catch(Exception e) {next_cmd="";}

				if (next_cmd.length()>0) {
					if (next_cmd.indexOf("@wait")==0) {
						cmd_id++;
						try {
							int first_id=next_cmd.indexOf("(");
							int last_id=next_cmd.lastIndexOf(")");

							if (first_id>-1 && last_id>-1 && last_id>first_id+1) {
								String next_cmd_par=next_cmd.substring(first_id+1, last_id);
								
								int comma_ind=next_cmd_par.indexOf(",");
								
								if (comma_ind==-1) {
									try {wait_timeout=Integer.parseInt(next_cmd_par);} catch(Exception e) {}
									wait_statement="";
								} //if (comma_ind==-1)
								else {
									String wait_timeout_part="";
									String wait_statement_part="";
									
									try {wait_timeout_part=next_cmd_par.substring(0,comma_ind).trim();} catch(Exception e) {}
									try {wait_statement_part=next_cmd_par.substring(comma_ind+1).trim();} catch(Exception e) {}
									
									try {wait_timeout=Integer.parseInt(wait_timeout_part);} catch(Exception e) {}
									wait_statement=wait_statement_part;
								} //if (comma_ind==-1)
								
								
							}
						} catch(Exception e) {
							e.printStackTrace();
						}
						
					}
				}
				
				if (a_cmd_line.length()==0 || a_cmd_line.indexOf("@wait")==0) continue;
				
				cmd_output.setLength(0);
				
				
				
				sendkeys.write(a_cmd_line.getBytes());
				sendkeys.write("\n".getBytes());
				sendkeys.flush();
				

				long start_ts=System.currentTimeMillis();
				
				while(true) {
					Thread.sleep(100);
					
					 if (checkStr(cmd_output.toString(),wait_statement)) break;
					 
					 if (System.currentTimeMillis()-start_ts>wait_timeout) {
						 if (wait_statement.trim().length()>0 && !checkStr(cmd_output.toString(),wait_statement)) {
							 logs.append(cmd_output.toString());
							 return false;
						 }
						 break;
						}
				}
				
				if (cmd_output!=null) logs.append(cmd_output.toString());

			} catch(Exception e) {
				mylog(logs, "Exception@Shell Cmd["+a_cmd_line+"] : "+genLib.getStackTraceAsStringBuilder(e).toString());
				return false;
			} 
			
		} // while 
		
		
		try{stdout.stopExecuting();stdout.stop();} catch(Exception e) {}
		try{stdout.stop();} catch(Exception e) {}
		try{stdout=null;} catch(Exception e) {}
		try{input.close();} catch(Exception e) {}
		try{sendkeys.close();} catch(Exception e) {}
		try {p.destroy(); }  catch(Exception e) {}
		

		
		return true;
	}
	
	
	//***************************************************************************
	boolean checkStr(String cmd_output, String wait_statement) {
		
		if (wait_statement.trim().length()==0) return false;
		
		if (cmd_output.indexOf(wait_statement)>-1) 	return true;
		
		
		try {
			Pattern pattern=Pattern.compile(wait_statement,Pattern.CASE_INSENSITIVE);
			Matcher matcher = pattern.matcher(cmd_output);
			if (matcher.find()) 
				return true;
		} catch(Exception e) {
			
		}
		
		
		
		return false;
	}
	
}
