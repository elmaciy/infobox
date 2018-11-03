package com.mayatech.dm.dmMsSqlParser;

import com.mayatech.dm.ddmClient;

public class msSqlSTMTColumn {

	String col_path;
	
	String catalog_name;
	String schema_name;
	String object_name;
	String column_name;

	
	boolean is_exception=false;
	
	
	void compile(ddmClient ddmClient) {
		col_path=catalog_name+"."+schema_name+"."+object_name+"."+column_name;
		
		is_exception=msSqlParser.checkColumnException(this, ddmClient);
		
	}
	
}
