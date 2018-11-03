package com.mayatech.dm.dmPostgreSQLParser;

import java.util.ArrayList;

import com.mayatech.dm.ddmClient;

public class postgreSTMTWith {
	
	
	String text=null;
	String charset="";
	
	String statement_part="";
	String alias="";
	
	
	boolean hasError=false;
	
	postgreSTMT stmt=null;
	
	ArrayList<String[]> columns=new ArrayList<String[]>();
	
	
	void compile(ddmClient ddmClient) {
				
		StringBuilder sbAlias=new StringBuilder();
		StringBuilder sbStatement=new StringBuilder();

		postgreParser.extractWithAliasAndStatement(text,sbStatement,sbAlias);
		
		postgreParser.clearUnnecesaryParantesis(sbStatement);
		
		statement_part=sbStatement.toString();
		alias=sbAlias.toString();

		stmt=postgreParser.parse(sbStatement.toString(), null, ddmClient);
		
		
		
	}
	
	
	
}
