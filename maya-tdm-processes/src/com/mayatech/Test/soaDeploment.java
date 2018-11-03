package com.mayatech.Test;

import java.util.ArrayList;

import com.mayatech.tdm.ConfDBOper;



public class soaDeploment {
	
	
	String getInput() {
		try {
			return System.console().readLine();
		} catch(Exception e) {
			System.out.println("Exception@xxxx");
			e.printStackTrace();
		}
		
		return null;
	}
	
	public static void main(String[] args) {
		ConfDBOper t=new ConfDBOper(false);
		soaDeploment s=new soaDeploment();
		String sql="";
		
		String request_id="";
		
		try {
			request_id=args[0];
			int i=0;
			i=Integer.parseInt(request_id);
			
		} catch(Exception e) {
			
			System.out.println("Enter deployment request id : ");
			request_id=s.getInput();
			if (request_id==null) request_id="50";
			
		}
		
		
		
		System.out.println("Deploying Request No : " + request_id);
		
		sql="select application_id, environment_id from mad_request_app_env where request_id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",request_id});
		
		ArrayList<String[]> depList=t.getDbArrayConf(sql,Integer.MAX_VALUE,bindlist);
		
		for (int i=0;i<depList.size();i++) {
			String application_id=depList.get(i)[0];
			String environment_id=depList.get(i)[1];
			
			//t.MADdeployApplication(request_id, application_id, environment_id);
			
		}
		
	}
	
}
