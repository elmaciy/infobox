package com.mayatech.baseLibs;

import java.io.File;
import java.io.PrintStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import org.apache.tools.ant.DefaultLogger;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;

public class antRunner {

	PrintStream oldSysOut = System.out;
	PrintStream oldSysErr = System.err;
	
	//---------------------------------------
	void mylog(String log) {
		System.out.println(log);
		//logs.append(log);
		//logs.append("\n");
	}
	
	
	
	
	
	public boolean runAnt(ArrayList<String[]> params, StringBuilder ant_logs) {
		
		WriterOutputStream wout=new WriterOutputStream();
		PrintStream outStr= new PrintStream(wout);
		System.setOut(outStr);
		System.setErr(outStr);
		
		genLib.printParameters(params);
		
		String ant_file=genLib.getParamByName(params, "ant.file");
		String ant_project=genLib.getParamByName(params, "ant.project");
		String ant_target=genLib.getParamByName(params, "ant.target");

		String ant_core_lib=genLib.getParamByName(params, "ant.core.lib");
		String ant_library_dir=genLib.getParamByName(params, "ant.library.dir");
		String ant_home=genLib.getParamByName(params, "ant.home");
		String ant_basedir=genLib.getParamByName(params, "ant.basedir");
		String ant_log_level=genLib.getParamByName(params, "ant.log.level");
		
		String java_classpath=genLib.getEnvValue("CLASSPATH");
		
		Project p = new Project();


		
		
		if (ant_file.trim().length()>0) p.setUserProperty("ant.file", ant_file);
		if (ant_project.trim().length()>0) p.setUserProperty("ant.project.name", ant_project);
		if (ant_target.trim().length()>0) p.setUserProperty("ant.target", ant_target);
		if (ant_core_lib.trim().length()>0)  p.setUserProperty("ant.core.lib", ant_core_lib);
		if (ant_library_dir.trim().length()>0) p.setUserProperty("ant.library.dir", ant_library_dir);
		if (ant_home.trim().length()>0) p.setUserProperty("ant.home", ant_home);
		if (ant_basedir.trim().length()>0) p.setUserProperty("basedir", ant_basedir);
		

		mylog("------------------------------------------------------------------");
		mylog("ANT PROPERTIES ");
		mylog("------------------------------------------------------------------");
		mylog("\t ant.file:"+ant_file);
		mylog("\t ant.project:"+p.getUserProperty("ant.project"));
		mylog("\t ant.target:"+ant_target);
		mylog("\t basedir:"+p.getUserProperty("basedir"));
		mylog("\t ant.log.level:"+ant_log_level);
		mylog("\t ant.core.lib:"+p.getUserProperty("ant.core.lib"));
		mylog("\t ant.home:"+p.getUserProperty("ant.home"));
		mylog("\t ant.library.dir:"+p.getUserProperty("ant.library.dir"));
		mylog("\t CLASSPATH:"+java_classpath);
		mylog("------------------------------------------------------------------");
		
		
		 DefaultLogger consoleLogger=new DefaultLogger(){
			 @Override 
			 protected void printMessage(    String message,    PrintStream stream,    int priority){
				 SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				 Date now = new Date();
			    String strDate = sdfDate.format(now);
				 message=" ANT@"+strDate+"> " + message;
			      //super.printMessage(message,stream,priority);
			      mylog(message);
			    }
		 };
		
		
		consoleLogger.setEmacsMode(true);


		/*
		consoleLogger.setErrorPrintStream(System.err);
		consoleLogger.setOutputPrintStream(System.out);
		*/
		
		consoleLogger.setErrorPrintStream(outStr);
		consoleLogger.setOutputPrintStream(outStr);

	
		int log_level_int=Project.MSG_VERBOSE;
		try {log_level_int=Integer.parseInt(ant_log_level);} catch(Exception e) {log_level_int=Project.MSG_VERBOSE;} 
		consoleLogger.setMessageOutputLevel(log_level_int);
		
		
		p.addBuildListener(consoleLogger);


		try {
			p.fireBuildStarted();
			p.init();
			ProjectHelper helper = ProjectHelper.getProjectHelper();
			p.addReference("ant.projectHelper", helper);
			
			File buildFile = null;
			try {
				buildFile=new File(ant_file); 
				} 
			catch(Exception e) {
				System.setOut(oldSysOut);
				System.setErr(oldSysErr);
				ant_logs.append(wout.getOutput().toString());
				return false;
				}
			
			try {helper.parse(p, buildFile);} catch(Exception e) {}
			
			String targetToExecute = (ant_target != null && ant_target.trim().length() > 0) ? ant_target.trim() : p.getDefaultTarget();
			p.executeTarget(targetToExecute);
			
			p.fireBuildFinished(null);

		}
		
		catch (Throwable buildException)
	    {
	     buildException.printStackTrace();
	     p.fireBuildFinished(buildException);
	     ant_logs.append(wout.getOutput().toString());
	     
			
	     try {
	    	 	
				outStr.close();
			} catch(Exception e) {
				
			}
	     
	      return false;
	    }  finally {
	    	
	    	 System.setOut(oldSysOut);
			 System.setErr(oldSysErr);
			 
			 try {
				outStr.close();
			} catch(Exception e) {
				
			}
	    }
		
		
		ant_logs.append(wout.getOutput().toString());
		return true;
	}
	
	
}
