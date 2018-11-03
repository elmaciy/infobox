package com.mayatech.Test;

import java.util.ArrayList;

import com.mayatech.dm.ddmLib;





public class testGenerl {

	
	public static void main(String[] args) {
		
		String sql="select ${P1} as X, ${P_2} as XXXX from dual where 'SYSTEM'=${CURRENT_USER} and 'P1'=${P1}";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		ArrayList<String[]> params=new ArrayList<String[]>();
		
		params.add(new String[]{"P1","value of param 1"});
		params.add(new String[]{"P2","value of param 2"});
		params.add(new String[]{"P3","value of param 3"});
		params.add(new String[]{"P4","value of param 4"});
		params.add(new String[]{"P5","value of param 5"});
		params.add(new String[]{"P_2","value of param P_2"});
		params.add(new String[]{"CURRENT_USER","value of param CURRENT_USER"});
		params.add(new String[]{"xxx","value of param xxxx"});
		
		String new_sql=ddmLib.decodeControllStatementAndBindings(params,sql,bindlist);
		
		System.out.println("new_sql : "+new_sql);
		for (int b=0;b<bindlist.size();b++) 
			System.out.println(bindlist.get(b)[0]+"="+bindlist.get(b)[1]);

	}

	
	
		
		
	
}
