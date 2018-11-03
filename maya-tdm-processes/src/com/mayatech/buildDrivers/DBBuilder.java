package com.mayatech.buildDrivers;

import java.io.File;
import java.util.ArrayList;

import com.mayatech.baseLibs.fileUtilities;
import com.mayatech.baseLibs.genLib;
import com.mayatech.repoDrivers.RepoExplorer;
import com.mayatech.tdm.ConfDBOper;

public class DBBuilder {

	StringBuilder logs=new StringBuilder();
	
	void mylog(String log) {
		System.out.println(log);
		logs.append(log);
		logs.append("\n");
		
	}
	
	
	public ArrayList<String[]> build(ArrayList<String[]> parameters) {
		
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		mylog("****************************************************");
		mylog("***               DATABASE BUILD STARTED         ***");
		mylog("****************************************************");
		
		genLib.printParameters(parameters, logs);
		
		
		String current_application_id=genLib.getParamByName(parameters, "CURRENT_APPLICATION_ID");
		
		
		
		String repo_class_name=genLib.getParamByName(parameters, "MAD_REPOSITORY_CLASS_NAME");
		String repo_par_hostname=genLib.getParamByName(parameters, "MAD_REPOSITORY_HOSTNAME");
		String repo_par_username=genLib.getParamByName(parameters, "MAD_REPOSITORY_USERNAME");
		String repo_par_password=genLib.getParamByName(parameters, "MAD_REPOSITORY_PASSWORD");

		
		
		RepoExplorer re=new RepoExplorer();
		
		
		String build_path=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_DIRECTORY");
		String project_name=genLib.getParamByName(parameters, "MAD_REQUEST_PROJECT_NAME");
		
		String platform_id=genLib.getParamByName(parameters, "CURRENT_PLATFORM_ID");
		String platform_type_id=genLib.getParamByName(parameters, "CURRENT_PLATFORM_TYPE_ID");
		
		String member_path=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_PATH");
		String member_name=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_NAME");
		String member_version=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_VERSION");
		String build_tag_info=genLib.getParamByName(parameters, "MAD_REQUEST_ITEM_TAG_INFO");
		
		String db_type=genLib.getParamByName(parameters, "DATABASE_TYPE");
		String DATABASE_FILE_TYPE=genLib.getParamByName(parameters, "DATABASE_FILE_TYPE");
		
		
		String file_to_deploy=build_path+File.separator+project_name+File.separator+member_name;
		System.out.println("Db Build File : "+file_to_deploy);
		mylog("Db Build File : "+file_to_deploy);
		
		//****************************************************
		//Replace Files
		//****************************************************
		ConfDBOper d=new ConfDBOper(false);
		fileUtilities rep=new fileUtilities();

		 
		 String sql="select file_name, modifier_group_id, include_sub_folders "+
				 	" from mad_platform_type_modifier_group "+
				 	" where platform_type_id=? and (application_id is null or application_id=?)";
		 
		 ArrayList<String[]> bindlist=new  ArrayList<String[]>();
		 bindlist.add(new String[]{"INTEGER",platform_type_id});
		 bindlist.add(new String[]{"INTEGER",current_application_id});

		 
		 ArrayList<String[]> arr=d.getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);
		 mylog("Replacer File Count : " + arr.size());
		 
		 for (int i=0;i<arr.size();i++) {
			 
			 String file_name=arr.get(i)[0];
			 if (file_name.contains("${"))
				 file_name=genLib.replaceAllParams(file_name, parameters);
			 
			 String modifier_group_id=arr.get(i)[1];
			 String file_path=build_path+File.separator+file_name;
			 
			 String include_sub_folders=arr.get(i)[2];
			 
			 boolean to_include_sub_folders=false;
			 if (include_sub_folders.equals("YES")) to_include_sub_folders=true;
			 
			 sql="select " +
					 " id, " + 
					 " rule_locator_type, " + 
					 " rule_locator_statement, " + 
					 " rule_locator_options, " + 
					 " rule_changer_action, " + 
					 " rule_changer_statement, " + 
					 " rule_changer_options, " + 
					 " when_value_to_check, " +
					 " when_operand, " +
					 " when_values " +
					 " from mad_modifier_rule  "+
					 " where " +
					 " modifier_group_id=? " + 
					 " and is_valid='YES' " + 
					 " order by modifier_order ";
			 
			 bindlist.clear();
			 bindlist.add(new String[]{"INTEGER",modifier_group_id});

			 
			 ArrayList<String[]> rules=d.getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);
			 mylog("Replacer Rule Count : " + rules.size());
			 
			 StringBuilder replacer_log=new StringBuilder();
			 
			 boolean is_success=rep.checkAndModifyFile(file_path, to_include_sub_folders, file_path, rules, parameters, replacer_log);
			 mylog(replacer_log.toString());

			 if (!is_success) {
				 d.closeAll();
				 mylog("Error on replaceFile.");
				 ret1.add(new String[]{"false",logs.toString()});
				 return ret1;
			 }
			 
		 }
		 
		d.closeAll();
		
		
		//-----------------------------------------------
		
		genLib.printParameters(parameters);
		//-----------------------------------------------
		
		
		StringBuilder db_logs=new StringBuilder();
		boolean is_success=true;
		mylog("Db Build Result : "+is_success);
		
		mylog(db_logs.toString());
		
		if (!is_success) {
			mylog("DB Build : FAILED");
			ret1.add(new String[]{"false",logs.toString()});
			return ret1;
		}
			
		mylog("DB Build : SUCCESSFULL");
		ret1.add(new String[]{"true",logs.toString()});
		return ret1;
	}
	
	//--------------------------------------------------
	
	
}
