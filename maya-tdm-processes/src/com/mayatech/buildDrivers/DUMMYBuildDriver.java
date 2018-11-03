package com.mayatech.buildDrivers;

import java.util.ArrayList;

public class DUMMYBuildDriver {

	StringBuilder logs=new StringBuilder();
	
	void mylog(String log) {
		System.out.println(log);
		logs.append(log);
		logs.append("\n");
		
	}
	
	
	public ArrayList<String[]> build(ArrayList<String[]> parameters) {
		
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		
			
		mylog("DUMMY Build : SUCCESSFULL");
		ret1.add(new String[]{"true",logs.toString()});
		return ret1;
	}
}
