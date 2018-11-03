package com.mayatech.deployDrivers;

import java.io.File;
import java.util.ArrayList;

import com.mayatech.baseLibs.antRunner;
import com.mayatech.baseLibs.genLib;

public class ANTDeployer {

	StringBuilder logs=new StringBuilder();
	
	void mylog(String log) {
		System.out.println(log);
		logs.append(log);
		logs.append("\n");
		
	}
	
	
	public ArrayList<String[]> deploy(ArrayList<String[]> parameters) {
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		mylog("****************************************************");
		mylog("***               ANT STARTED                    ***");
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
		
		
		antRunner ant=new antRunner();
		
		String build_file=build_path+File.separator+"build.xml";
		String build_target=genLib.getParamByName(parameters, "ant.deploy.target");
		
		
		parameters.add(new String[]{"ant.file",build_file});
		parameters.add(new String[]{"ant.project",genLib.getParamByName(parameters, "ant.project")});
		parameters.add(new String[]{"ant.target",build_target});
		
		
		parameters.add(new String[]{"ant.core.lib",genLib.getParamByName(parameters, "ant.core.lib")});
		parameters.add(new String[]{"ant.library.dir",genLib.getParamByName(parameters, "ant.library.dir")});
		parameters.add(new String[]{"ant.home",genLib.getParamByName(parameters, "ant.home")});
		parameters.add(new String[]{"ant.basedir",build_path});
		
		
		
		StringBuilder ant_logs=new StringBuilder();
		boolean is_success=ant.runAnt(parameters, ant_logs);
		mylog(ant_logs.toString());
		
		if (!is_success) {
			mylog("Start ANT Build : FAILED");
			ret1.add(new String[]{"false",logs.toString()});
			return ret1;
		}
			
		mylog("Start ANT Build : SUCCESSFULL");
		ret1.add(new String[]{"true",logs.toString()});
		return ret1;
		
		
		
	}
	
	
	
	
}
