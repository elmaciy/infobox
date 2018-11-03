package com.mayatech.datamodel;

import com.mayatech.baseLibs.genLib;

public class dmColumn {
	String column_name;
	String column_type;
	int size;
	String default_value="NULL";
	boolean isPkey=false;
	boolean nullable=true;
	boolean auto_increment=false;
	
	public dmColumn(
			String column_name,
			String column_type,
			int size,
			String default_value,
			boolean isPkey,
			boolean nullable,
			boolean auto_increment
			) {
		
		this.column_name=column_name;
		this.column_type=column_type;
		this.size=size;
		this.default_value=genLib.nvl(default_value, "NULL");
		this.isPkey=isPkey;
		//this.nullable=nullable;
		this.nullable=true;
		this.auto_increment=auto_increment;
	}
	


}
