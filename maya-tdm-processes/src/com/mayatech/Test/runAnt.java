package com.mayatech.Test;

import java.util.ArrayList;

import com.mayatech.baseLibs.antRunner;




public class runAnt {

	
	public static void main(String[] args) {
		/*
		String build_file="D:\\selenium\\ants\\build.xml"; 
		String build_target="test";
		*/
		String build_file="D:\\temp\\mad\\build\\50\\platform_111\\app_102\\item_1343\\build.xml";
		String build_target="compileSingleProject";
		String working_dir="D:\\temp\\mad\\build\\50\\platform_111\\app_102\\item_1343";
		antRunner ant=new antRunner();
		
		ArrayList<String[]> params=new ArrayList<String[]>();
		params.add(new String[]{"ant.file",build_file});
		params.add(new String[]{"ant.core.lib",""});
		params.add(new String[]{"ant.target",build_target});
		
		params.add(new String[]{"ant.core.lib","D:\\deploy\\apache-ant-1.8.4\\lib"});
		params.add(new String[]{"ant.library.dir","D:\\deploy\\apache-ant-1.8.4\\lib"});
		params.add(new String[]{"ant.home","D:\\deploy\\apache-ant-1.8.4"});
		params.add(new String[]{"ant.basedir","D:\\deploy\\apache-ant-1.8.4"});
		
		StringBuilder sb=new StringBuilder();
		ant.runAnt(params,sb);
		

	}

}
