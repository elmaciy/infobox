package com.mayatech.Test;

import java.util.ArrayList;

import com.mayatech.repoDrivers.RepoExplorer;
import com.mayatech.tdm.ConfDBOper;



public class testexport {

	
	public static void main(String[] args) {
		
		ConfDBOper d=new ConfDBOper(false);
		int application_id=1;
		
		String sql=" select " +
				" class_name, par_hostname, par_username, "+
				" par_password, app_repo_root, app_repo_filter "+
				" from  mad_application a, mad_repository r "+
				" where a.repository_id=r.id "+
				" and a.id=?";		
		ArrayList<String[]> repoparams=d.getDbArrayConfInt(sql, 1, application_id);
		
		String className=repoparams.get(0)[0];
		String repo_url=repoparams.get(0)[1];
		String username=repoparams.get(0)[2];
		String password=repoparams.get(0)[3];
		String path=repoparams.get(0)[4];
		String filter=repoparams.get(0)[5];
		
		d.closeAll();
		
		
		ArrayList<String[]> arr=new ArrayList<String[]>();
		long start_ts=System.currentTimeMillis();
		RepoExplorer re=new RepoExplorer();
		
		
		StringBuilder retlogs=new StringBuilder();
		
		/*
		String export_path="d:\\githome\\def";
		String export_file="deneme.txt";
		String export_version="-1";
		String local_path="d:\\temp\\export";
		*/
		
		String export_path="d:\\githome";
		String export_file="";
		String export_version="-1";
		String local_path="d:\\temp\\export";
		
		re.exportFolder(
					className, 
					repo_url, 
					username, 
					password, 
					export_path, 
					export_file, 
					export_version, 
					local_path,
					retlogs);
		
		
		

	}

}
