package com.mayatech.buildDrivers;

import java.util.ArrayList;

import com.mayatech.baseLibs.genLib;
import com.mayatech.baseLibs.shellLib;

public class ShellDriver {

	StringBuilder logs=new StringBuilder();
	
	void mylog(String log) {
		System.out.println(log);
		logs.append(log);
		logs.append("\n");
		
	}
	
	
	public ArrayList<String[]> commonMethod(ArrayList<String[]> parameters) {
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		mylog("****************************************************");
		mylog("***               SHELL STARTED                  ***");
		mylog("****************************************************");
		
		genLib.printParameters(parameters, logs);
		
		
		String start_path=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_DIRECTORY");
		String start_cmd=genLib.getParamByName(parameters, "MAD_SHELL_SHELL_START_CMD");
		String cmd_list=genLib.getParamByName(parameters, "MAD_SHELL_CMD_LIST");
		
		//replace all parameters
		cmd_list=genLib.replaceAllParams(cmd_list, parameters);
		
		StringBuilder wls_deploy_logs=new StringBuilder();
		boolean is_success=true;
		
		shellLib sh=new shellLib(start_cmd, start_path);
		
		
		
		is_success=sh.performDeployment(cmd_list, wls_deploy_logs);
		
		mylog(wls_deploy_logs.toString());
		
		if (!is_success) {
			mylog("Shell Driver : FAILED");
			ret1.add(new String[]{"false",logs.toString()});
			return ret1;
		}
			
		mylog("Shell Driver : SUCCESSFULL");
		ret1.add(new String[]{"true",logs.toString()});
		return ret1;
		
		
		
	}
	
	
	public ArrayList<String[]> build(ArrayList<String[]> parameters) {
		
		return commonMethod(parameters);
	}
	
	
	public ArrayList<String[]> deploy(ArrayList<String[]> parameters) {
		
		return commonMethod(parameters);
	}
	
	
	
	
}
