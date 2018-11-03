package com.mayatech.dm.dmOracleParser;

import java.util.ArrayList;

import com.mayatech.dm.ddmClient;

public class oracleSTMTWith {
	
	
	String text=null;
	String charset="";
	
	String statement_part="";
	String alias="";
	
	
	boolean hasError=false;
	
	oracleSTMT stmt=null;
	
	ArrayList<String[]> columns=new ArrayList<String[]>();
	
	
	void compile(ddmClient ddmClient) {
				
		StringBuilder sbAlias=new StringBuilder();
		StringBuilder sbStatement=new StringBuilder();

		oracleParser.extractWithAliasAndStatement(text,sbStatement,sbAlias);
		
		oracleParser.clearUnnecesaryParantesis(sbStatement);
		
		statement_part=sbStatement.toString();
		alias=sbAlias.toString();

		stmt=oracleParser.parse(sbStatement.toString(), null, ddmClient);
		
		
		
	}
	
	
	
}
