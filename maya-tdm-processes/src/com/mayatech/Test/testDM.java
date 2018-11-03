package com.mayatech.Test;

import java.sql.Connection;
import java.util.ArrayList;

import com.mayatech.dm.ddmLib;
import com.mayatech.tdm.commonLib;

public class testDM {
	
	

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		commonLib clib=new commonLib();
		
		testDM dm=new testDM();



		/*
		String ConnStr="jdbc:oracle:thin:@localhost:1522:orcl12c";
		String Driver="oracle.jdbc.driver.OracleDriver";
		String User="system";
		String Pass="Han#1323";
		*/


		
		
		String ConnStr="jdbc:oracle:thin:@localhost:1522:orcl";
		String Driver="oracle.jdbc.driver.OracleDriver";
		String User="system";
		String Pass="Han#1323";
		
		
		/*
		String ConnStr="jdbc:jtds:sqlserver://localhost:2433;database=Northwind";
		String Driver="net.sourceforge.jtds.jdbc.Driver";
		String User="sa";
		String Pass="Han!1323";
		*/
		
		/*
		String ConnStr="jdbc:jtds:sybase://YELMACI-PC:54322";
		String Driver="net.sourceforge.jtds.jdbc.Driver";
		String User="sa";
		String Pass="Han!1323";
		*/
		
		/*
		String ConnStr="jdbc:postgresql://localhost:54321/dvdrentaldb";
		String Driver="org.postgresql.Driver";
		String User="postgres";
		String Pass="postgres";
		*/
		
		Connection connApp=clib.getDBConnection(ConnStr, Driver, User, Pass, 1);
		ArrayList<String[]> arr=null;
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String sql="";

		sql="select * from scott.emp where hiredate=?";
		bindlist.add(new String[]{"TIMESTAMP",""+System.currentTimeMillis()});
		
		ddmLib.getDbArray(connApp, sql, 1, bindlist, 0);

		try {connApp.close();} catch(Exception e) {};
		
		
		
		
	}

}
