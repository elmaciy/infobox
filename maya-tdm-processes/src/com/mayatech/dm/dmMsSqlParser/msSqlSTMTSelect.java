package com.mayatech.dm.dmMsSqlParser;

import java.util.ArrayList;

import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmChunk;

public class msSqlSTMTSelect {
	
	
	String text=null;
	String selection=null;
	String alias="";
	String base_alias="";
	

	
	ArrayList<ddmChunk> commentChunkArr=new ArrayList<ddmChunk>();
	ArrayList<ddmChunk> selectClausesChunkArr=new ArrayList<ddmChunk>();
	
	ArrayList<msSqlSTMTExpr> exprList=new ArrayList<msSqlSTMTExpr>();
				
	//boolean isSubStatement=false;
	msSqlSTMT stmt=null;


	
	boolean isAssigned=false;
	
	//-------------------------------------------------------------------------
	void compile(ddmClient ddmClient) {
		
		if (ddmClient.dm.is_debug || ddmClient.is_tracing) 
			ddmClient.mydebug("SELECT.compile text : "+text);
		text=msSqlParser.clearComments(text,commentChunkArr);
		
		text=msSqlParser.clearSelectClauses(text,selectClausesChunkArr).trim();
		
		if (ddmClient.dm.is_debug || ddmClient.is_tracing) 
			ddmClient.mydebug("SELECT.compile text after clearSelectClauses : "+text);
		
		StringBuilder sbText=new StringBuilder();
		StringBuilder sbSelection=new StringBuilder();
		StringBuilder sbAlias=new StringBuilder();
		
		msSqlParser.extractSelectionAndAlias(text, sbText, sbSelection,sbAlias, ddmClient); 
		
		msSqlParser.clearUnnecesaryParantesis(sbAlias);
		
		text=sbText.toString();
		selection=sbSelection.toString();
		alias=sbAlias.toString();
		
		if (ddmClient.dm.is_debug || ddmClient.is_tracing) {
			ddmClient.mydebug("SELECT.compile selection :"+selection);
			ddmClient.mydebug("SELECT.compile alias :"+alias);
		}
		
	}
	
	
}
