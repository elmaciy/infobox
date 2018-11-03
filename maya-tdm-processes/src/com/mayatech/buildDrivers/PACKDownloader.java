package com.mayatech.buildDrivers;
		
import java.io.File;
import java.util.ArrayList;

import org.apache.commons.io.FileUtils;

import com.mayatech.baseLibs.fileUtilities;
import com.mayatech.baseLibs.genLib;
import com.mayatech.repoDrivers.RepoExplorer;
import com.mayatech.tdm.ConfDBOper;

public class PACKDownloader {

	StringBuilder logs=new StringBuilder();
	
	void mylog(String log) {
		System.out.println(log);
		logs.append(log);
		logs.append("\n");
		
	}
	
	
	public ArrayList<String[]> build(ArrayList<String[]> parameters) {
		
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		mylog("****************************************************");
		mylog("***               DOWNLOADER STARTED             ***");
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
		
		
		
		String file_to_download=build_path+File.separator+project_name+File.separator+member_name;
		System.out.println("File to download : "+file_to_download);
		
		
		String[] copyfiles=new String[]{repo_par_hostname+member_path};
		
		for (int i=0;i<copyfiles.length;i++) {
			
			String file_to_copy=copyfiles[i];
			String file_to_copy_dir="";
			String file_to_copy_file="";
			
			try {
				
				mylog("Checking "+file_to_copy+" from filesystem ...");
				File source=new File(file_to_copy);
				if (source.exists()) {
					mylog("Copying from filesystem : " + file_to_copy + " => " + build_path);
					try {
						File target=new File(build_path);
						FileUtils.copyFileToDirectory(source, target);
					} catch(Exception e) {
						mylog("PACKAGE Download : FAILED");
						mylog("Exception@build (copy from local "+ file_to_copy +"): "+e.getMessage());
						mylog(genLib.getStackTraceAsStringBuilder(e).toString());
						
						e.printStackTrace();
						
						ret1.add(new String[]{"false",logs.toString()});
						return ret1;
					}
				} 
				else {
					
					mylog("Checking "+file_to_copy+" from repository ...");
					
					try{file_to_copy_dir=file_to_copy.substring(0,file_to_copy.lastIndexOf("/"));} catch(Exception e) {}
					try{file_to_copy_file=file_to_copy.substring(file_to_copy.lastIndexOf("/")+1);} catch(Exception e) {}
							
					
					mylog("Downloading file ....");
					mylog("\t repo_class_name \t: "  + repo_class_name);
					mylog("\t repo_par_hostname \t: "  + repo_par_hostname);
					mylog("\t repository dir \t: "  + file_to_copy_dir);
					mylog("\t repository file \t: "  + file_to_copy_file);
					mylog("\t member_version \t: "  + member_version);
					mylog("\t local_path \t: "  + build_path);

					
					
					boolean export_ok=re.exportFolder(
										repo_class_name, 
										repo_par_hostname, 
										repo_par_username, 
										repo_par_password, 
										file_to_copy_dir, 
										file_to_copy_file, 
										member_version, 
										build_path,
										logs
										);
					
					if (!export_ok) {
						mylog("PACKAGE Download : FAILED");
						ret1.add(new String[]{"false",logs.toString()});
						return ret1;
					}
					
					
				} //if (x.size()==0)
			} catch(Exception e) {
				mylog("PACKAGE Download : FAILED");
				mylog("Exception@build : "+e.getMessage());
				mylog(genLib.getStackTraceAsStringBuilder(e).toString());
				e.printStackTrace();
				
				ret1.add(new String[]{"false",logs.toString()});
				return ret1;
				 
			}
			
			
			
			
		} //for (int i=0;i<copyfiles.length;i++)
		
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
		
		
		StringBuilder db_logs=new StringBuilder();
		boolean is_success=true;
		
		if (logs.indexOf("Exception@")>-1)  is_success=false;
		
			
		mylog("PACKAGE Download Result : "+is_success);
		
		mylog(db_logs.toString());
		
		if (!is_success) {
			mylog("PACKAGE Download : FAILED");
			ret1.add(new String[]{"false",logs.toString()});
			return ret1;
		}
			
		mylog("PACKAGE Download : SUCCESSFULL");
		ret1.add(new String[]{"true",logs.toString()});
		return ret1;
	}
	
	//--------------------------------------------------
	
	
}
