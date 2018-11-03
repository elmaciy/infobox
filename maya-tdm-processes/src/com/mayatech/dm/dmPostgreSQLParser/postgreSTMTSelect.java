package com.mayatech.dm.dmPostgreSQLParser;

import java.util.ArrayList;

import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmChunk;

public class postgreSTMTSelect {
	
	
	String text=null;
	String selection=null;
	String alias="";
	String base_alias="";
	
	boolean isMasked=false;

	
	ArrayList<ddmChunk> commentChunkArr=new ArrayList<ddmChunk>();
	ArrayList<ddmChunk> selectClausesChunkArr=new ArrayList<ddmChunk>();
	
	ArrayList<postgreSTMTExpr> exprList=new ArrayList<postgreSTMTExpr>();
				
	//boolean isSubStatement=false;
	postgreSTMT stmt=null;


	
	
	//-------------------------------------------------------------------------
	void compile(ddmClient ddmClient) {
		
		text=postgreParser.clearComments(text,commentChunkArr);
		
		text=postgreParser.clearSelectClauses(text,selectClausesChunkArr);
		
		StringBuilder sbSelection=new StringBuilder();
		StringBuilder sbAlias=new StringBuilder();
		postgreParser.extractSelectionAndAlias(text,sbSelection,sbAlias, ddmClient); 
		
		postgreParser.clearUnnecesaryParantesis(sbAlias);
		
		alias=sbAlias.toString();
		selection=sbSelection.toString();
		
	}
	
	
}
