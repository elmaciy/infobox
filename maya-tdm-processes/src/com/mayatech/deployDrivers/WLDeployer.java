package com.mayatech.deployDrivers;

import java.io.File;
import java.util.ArrayList;

import com.mayatech.baseLibs.genLib;
import com.mayatech.baseLibs.wlsDeployLib;

public class WLDeployer {

	StringBuilder logs=new StringBuilder();
	
	void mylog(String log) {
		System.out.println(log);
		logs.append(log);
		logs.append("\n");
		
	}
	
	
	public ArrayList<String[]> deploy(ArrayList<String[]> parameters) {
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		mylog("****************************************************");
		mylog("***               WLS DEPLOY STARTED             ***");
		mylog("****************************************************");
		
		genLib.printParameters(parameters, logs);
		
		
		String build_path=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_DIRECTORY");
		
		String platform_id=genLib.getParamByName(parameters, "CURRENT_PLATFORM_ID");
		String platform_type_id=genLib.getParamByName(parameters, "CURRENT_PLATFORM_TYPE_ID");
		
		String member_path=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_PATH");
		String member_name=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_NAME");
		String member_version=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_VERSION");
		String build_tag_info=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_TAG_INFO");
		String soa_project_name=genLib.getParamByName(parameters, "MAD_REQUEST_PROJECT_NAME");
		
		
		String wls_protocol=genLib.nvl(genLib.getParamByName(parameters, "WL_ADMIN_SERVER_PROTOCOL"),"t3");
		String wls_host=genLib.getParamByName(parameters, "WL_ADMIN_SERVER_HOST");
		String wls_port=genLib.getParamByName(parameters, "WL_ADMIN_SERVER_PORT");
		
		String wls_username=genLib.getParamByName(parameters, "WL_ADMIN_SERVER_USERNAME");
		String wls_password=genLib.getParamByName(parameters, "WL_ADMIN_SERVER_PASSWORD");
		
		long deployment_timeout=0;
		try  {deployment_timeout=Long.parseLong(genLib.getParamByName(parameters, "WL_DEPLOYMENT_TIMEOUT")); } catch(Exception e) {deployment_timeout=240000;}
		
		String wls_package_name=genLib.getParamByName(parameters, "WL_PACKAGE_NAME");
		String wls_package_type=genLib.getParamByName(parameters, "WL_PACKAGE_TYPE");
		
		
		String wls_target_type=genLib.getParamByName(parameters, "WL_TARGET_TYPE");
		String wls_target_names=genLib.getParamByName(parameters, "WL_TARGET_NAMES");
		
		String wls_is_library=genLib.nvl(genLib.getParamByName(parameters, "WL_OPT_IS_LIBRARY"),"NO");
		
		//STAGE—Force copying of files to target servers.
		//NO_STAGE—Files are not copied to target servers.
		//EXTERNAL_STAGE—Files are staged manually.
		String wls_stage_mode=genLib.nvl(genLib.getParamByName(parameters, "WL_OPT_STAGE_MODE"),"nostage");
		
		//NO: (Default) Don't start automatically after install
		//YES_ADMIN : Start only for admin
		//YES_PUBLIC : Start for all
		String wls_start_after=genLib.nvl(genLib.getParamByName(parameters, "WL_OPT_START_AFTER"),"NO");
		
		
		//KEEP: (Default) Don't undeploy retired ones
		//UNDEPLOY : Undeploy 
		String wl_retired_option=genLib.nvl(genLib.getParamByName(parameters, "WL_OPT_RETIRED_ACTION"),"KEEP");
		
		
		String wls_package_version=genLib.nvl(genLib.getParamByName(parameters, "MAD_CALCULATED_APPLICATION_VERSION"),"");
		
		
		String deploy_package_path=build_path+File.separator+soa_project_name+File.separator+member_name;
		
		StringBuilder wls_deploy_logs=new StringBuilder();
		boolean is_success=true;
		
		
		
		
		wlsDeployLib d=new wlsDeployLib();
		d.setConnection(wls_protocol, wls_host, wls_port, wls_username, wls_password,wls_deploy_logs);
		
		d.DiscoverWLServer(wls_deploy_logs);
		
		d.addDeploymentTarget(wls_target_type, wls_target_names, logs);
		
		d.setStagingMode(wls_stage_mode, logs);
		
		d.setStartMode(wls_start_after, logs);
		
		d.setIsLibrary(wls_is_library, logs);
		
		is_success=d.performDeployment(deploy_package_path,wls_package_name,wls_package_version, wls_package_type, deployment_timeout, wl_retired_option, wls_deploy_logs);
		
		mylog(wls_deploy_logs.toString());
		
		if (!is_success) {
			mylog("WL Build : FAILED");
			ret1.add(new String[]{"false",logs.toString()});
			return ret1;
		}
			
		mylog("WL Build : SUCCESSFULL");
		ret1.add(new String[]{"true",logs.toString()});
		return ret1;
		
		
		
	}
	
	
	
	
}
