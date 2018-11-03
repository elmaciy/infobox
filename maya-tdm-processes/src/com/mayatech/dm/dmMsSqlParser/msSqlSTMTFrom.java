package com.mayatech.dm.dmMsSqlParser;

import java.util.ArrayList;

import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmChunk;

public class msSqlSTMTFrom {
	
	
	String text=null;
	
	String object_catalog=null;
	String object_owner=null;
	String object_name=null;
	
	String from_part="";
	String from_join="";
	String from_option="";
	String alias="";
	
	ArrayList<String> matchList=new ArrayList<String>();
	
	boolean hasError=false;
	
	boolean isSubQuery=false;
	
	msSqlSTMT stmtForOwner=null;
	msSqlSTMT stmtForThisFrom=null;
	
	
	int start_of_source=0;
	int end_of_source=0;
	boolean isJoin=false; 
	
	
	ArrayList<String[]> columns=new ArrayList<String[]>();
	
	ArrayList<ddmChunk> commentChunkArr=new ArrayList<ddmChunk>();
	
	
	void compile(ddmClient ddmClient) {
				
		ddmClient.mydebug("FROM.compile.text="+text);
		
		//text=msSqlParser.normalizeFromPart(msSqlParser.clearComments(text,commentChunkArr));
		//text=msSqlParser.normalizeFromPart(msSqlParser.clearComments(text,commentChunkArr));
		text=msSqlParser.clearComments(text,commentChunkArr);
		
		
		StringBuilder sbText=new StringBuilder();
		StringBuilder sbFromJoins=new StringBuilder();
		StringBuilder sbFromPart=new StringBuilder();
		StringBuilder sbFromOption=new StringBuilder();
		StringBuilder sbAlias=new StringBuilder();

		int pos_join=msSqlParser.extractObjectNameAndAlias(text,sbText,sbFromJoins, sbFromPart,sbFromOption,sbAlias);
		
		if (pos_join>-1) isJoin=true;
			
		msSqlParser.clearUnnecesaryParantesis(sbFromPart);

		text=sbFromPart.toString();
		from_join=sbFromJoins.toString();
		from_part=sbFromPart.toString();
		from_option=sbFromOption.toString();
		alias=sbAlias.toString();
		
		if (ddmClient.dm.is_debug || ddmClient.is_tracing) {
			ddmClient.mydebug("FROM.compile.from_join           ="+from_join);
			ddmClient.mydebug("FROM.compile.from_part           ="+from_part);
			ddmClient.mydebug("FROM.compile.from_option         ="+from_option);
			ddmClient.mydebug("FROM.compile.alias               ="+alias);
		}
		

		
		ArrayList<ddmChunk> tmpChunks=msSqlParser.getChunks(sbFromPart.toString(), msSqlParser.invisibleChars, false);
		int pos_select=msSqlParser.getNextChunkId(tmpChunks, 0, tmpChunks.size(), true, false, false, false, msSqlParser.KEYWORD_SELECT);

		if (pos_select>-1) isSubQuery=true;

		
		if (isSubQuery && alias.length()==0) {
			alias="al$_"+System.currentTimeMillis();
		}
		
		if (alias.length()>0)	
			msSqlParser.prepareMatchListForFromPart(matchList,null,null,alias,ddmClient);
		
		
		ddmClient.mydebug("compile.FROM "+text+" AS "+alias);
				
		if (!isSubQuery) {
			
			StringBuilder sbCatalog=new StringBuilder();
			StringBuilder sbSchema=new StringBuilder();
			StringBuilder sbObject=new StringBuilder();
			
			msSqlParser.extractCatalogSchemaObject(sbFromPart,sbCatalog,sbSchema,sbObject, ddmClient); 
			
			
			object_catalog=sbCatalog.toString();
			object_owner=sbSchema.toString();
			object_name=sbObject.toString();
			
			long start_ts=System.currentTimeMillis();
			hasError=!msSqlParser.discoverObjectFromDb(object_catalog, object_owner, object_name, ddmClient, sbCatalog, sbSchema, sbObject, columns);
			ddmClient.mydebug("DB Discovery Duration ["+object_catalog+"."+object_owner+"."+object_name+"]: "+(System.currentTimeMillis()-start_ts));
			
						
			object_catalog=sbCatalog.toString();
			object_owner=sbSchema.toString();
			object_name=sbObject.toString();
			
			if (alias.length()==0) 
				msSqlParser.prepareMatchListForFromPart(matchList,object_catalog, object_owner,object_name,ddmClient);
			
			stmtForThisFrom=stmtForOwner;
			
			
		} 
		else {
			stmtForThisFrom=msSqlParser.parse(sbFromPart.toString(), stmtForOwner, ddmClient);
			stmtForThisFrom.fromBased=this;

			stmtForThisFrom.parse(ddmClient);
			msSqlParser.expandStatement(stmtForThisFrom, ddmClient);
		}
		
		
	}
	
	


	
	
}
