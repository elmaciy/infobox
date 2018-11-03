package com.mayatech.datamodel;

import java.sql.Connection;
import java.util.ArrayList;

import com.mayatech.dm.ddmLib;

public class test {

	public static void main(String[] args) {
		
		
		/*
		String ConnStr="jdbc:mysql://localhost/test?useUnicode=true&characterEncoding=utf8";
		String Driver="com.mysql.jdbc.Driver";
		String User="ssping";
		String Pass="123";
		*/
		
		String ConnStr="jdbc:mysql://localhost/test?useUnicode=true&characterEncoding=utf8";
		String Driver="com.mysql.jdbc.Driver";
		String User="ssping";
		String Pass="xxxx";
		
		Connection conn=ddmLib.getTargetDbConnection(Driver, ConnStr, User, Pass);
		
		
		dmModelForDM model=new dmModelForDM();
		model.syncDM(conn);
		try {conn.close();} catch(Exception e) {};
	}
}
