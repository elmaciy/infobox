package com.mayatech.checkLibs;

import java.io.File;
import java.util.ArrayList;

import com.mayatech.baseLibs.fileUtilities;


public class customCheck {

	
	void mylog(StringBuilder sb, String logstr) {
		sb.append(logstr+"\n");
		System.out.println(logstr);
	}
	
	//**********************************************************
	public boolean checkFile(
			String file_path, 
			String class_params, 
			ArrayList<String[]> pars, 
			StringBuilder log ) {

		
		fileUtilities fu=new fileUtilities();
		
		
		mylog(log,"Checking file : "+file_path);
		
		try {new File(file_path);} 
		catch(Exception e) {
			mylog(log,"File not found : " + file_path);
			e.printStackTrace();
			
			return false;
		}
		
		File f=new File(file_path);
		if (!f.exists()) {
			mylog(log,"Error@checkFile");
			mylog(log,"!File Not Found : "+ file_path);
			return false;
		}
		
		String[] lines=fu.readFile(file_path).toString().split(fu.ls); 
		
		for (int i=0;i<lines.length;i++) {
			String a_line=lines[i];
			if (a_line.contains(class_params)) 
				return true;
		}
		

		return false;
		
	}
	
}
