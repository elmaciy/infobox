package com.mayatech.Test;

import java.util.ArrayList;

import com.mayatech.baseLibs.fileUtilities;
import com.mayatech.repoDrivers.SVNRepoExplorer;

public class testExportFromSVN {

	
	public static void main(String[] args) {
		SVNRepoExplorer re=new SVNRepoExplorer();
		
		StringBuilder retlogs=new StringBuilder();
		
		String url="https://10.115.224.76:443/svn/sep";
		String username="mdeployersvn";
		String password="md@p!oyer.99";
		String export_path="/tags/16.03.02-0928/osb/XDSL/RequestorABCS/SubscribeStbXDSLReqABCS";
		//String export_file="/SUB_bpm_ýnput.xsl";
		String export_file="";
		String export_version="76351";
		String local_path="/data/mad/temp";
		//String local_path="D:\\temp\\input";
		
		boolean is_ok=re.exportFolder(url, username, password, export_path, export_file, export_version, local_path, retlogs);
		
		
		System.out.println("is_ok="+is_ok);
		
		System.out.println(retlogs.toString());
		
		
		fileUtilities modifier=new fileUtilities();
		
		//String file_pattern="D:\\temp\\input\\Resources\\Transform\\*.xsl";
		String file_pattern="/data/mad/temp/Resources/Transform/*.xsl";
		
		boolean to_include_sub_folders=false;
		String new_file_path="";
		
		
		StringBuilder replacer_log=new StringBuilder();

		
		boolean is_mod_ok=
			modifier.checkAndModifyFile(
				file_pattern, 
				to_include_sub_folders, 
				new_file_path, 
				new ArrayList<String[]>(), 
				new ArrayList<String[]>(), 
				replacer_log);
		
		System.out.println("is_mod_ok="+is_mod_ok);
		
		System.out.println(replacer_log.toString());
		
	}
	
	
}
