package com.mayatech.deployDrivers;

import java.util.ArrayList;

public class DUMMYDeployer {

	StringBuilder logs=new StringBuilder();
	
	void mylog(String log) {
		System.out.println(log);
		logs.append(log);
		logs.append("\n");
		
	}
	
	
	public ArrayList<String[]> deploy(ArrayList<String[]> parameters) {
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		mylog("DUMMY Deploy : SUCCESSFULL");
		ret1.add(new String[]{"true",logs.toString()});
		return ret1;
		
		
		
	}
	
	
	
	
}
