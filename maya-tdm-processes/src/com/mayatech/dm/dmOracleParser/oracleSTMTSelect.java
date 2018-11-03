package com.mayatech.dm.dmOracleParser;

import java.util.ArrayList;

import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmChunk;

public class oracleSTMTSelect {
	
	
	public String text=null;
	String selection=null;
	String alias="";
	String base_alias="";
	
	boolean isMasked=false;

	
	ArrayList<ddmChunk> commentChunkArr=new ArrayList<ddmChunk>();
	ArrayList<ddmChunk> selectClausesChunkArr=new ArrayList<ddmChunk>();
	
	public ArrayList<oracleSTMTExpr> exprList=new ArrayList<oracleSTMTExpr>();
				
	//boolean isSubStatement=false;
	oracleSTMT stmt=null;


	
	
	//-------------------------------------------------------------------------
	void compile(ddmClient ddmClient) {
		
		text=oracleParser.clearComments(text,commentChunkArr);
		
		text=oracleParser.clearSelectClauses(text,selectClausesChunkArr);
		
		StringBuilder sbSelection=new StringBuilder();
		StringBuilder sbAlias=new StringBuilder();
		oracleParser.extractSelectionAndAlias(text,sbSelection,sbAlias, ddmClient); 
		
		oracleParser.clearUnnecesaryParantesis(sbAlias);
		
		alias=sbAlias.toString();
		selection=sbSelection.toString();
		
	}
	
	
}
