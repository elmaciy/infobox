package com.mayatech.dm.dmPostgreSQLParser;

import java.util.ArrayList;

import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmChunk;

public class postgreSTMTFrom {
	
	
	String text=null;
	
	String object_owner=null;
	String object_name=null;
	
	String from_part="";
	String from_option="";
	String alias="";
	
	String table_filter="";
	
	ArrayList<String> matchList=new ArrayList<String>();
	
	boolean hasError=false;
	
	boolean isSubQuery=false;
	
	postgreSTMT stmtForOwner=null;
	postgreSTMT stmtForThisFrom=null;
	
	
	int start_of_source=0;
	int end_of_source=0;
	boolean isJoin=false; 
	
	
	ArrayList<String[]> columns=new ArrayList<String[]>();
	
	ArrayList<ddmChunk> commentChunkArr=new ArrayList<ddmChunk>();
	
	
	void compile(ddmClient ddmClient) {
				
		text=postgreParser.normalizeFromPart(postgreParser.clearComments(text,commentChunkArr));
		
		StringBuilder sbFromPart=new StringBuilder();
		StringBuilder sbFromOption=new StringBuilder();
		StringBuilder sbAlias=new StringBuilder();

		ArrayList<Integer> parseInfo=postgreParser.extractObjectNameAndAlias(text,sbFromPart,sbFromOption,sbAlias);
		
		int pos_join=0;
		
		try {pos_join=parseInfo.get(0);} catch (Exception e){e.printStackTrace();}
		try {start_of_source=parseInfo.get(1);} catch (Exception e){e.printStackTrace();}
		try {end_of_source=parseInfo.get(2);} catch (Exception e){e.printStackTrace();}
		
		if (pos_join>0) isJoin=true;
	
		postgreParser.clearUnnecesaryParantesis(sbFromPart);

		from_part=sbFromPart.toString();
		from_option=sbFromOption.toString();
		alias=sbAlias.toString();
		
		if (ddmClient.dm.is_debug || ddmClient.is_tracing) {
			ddmClient.mydebug("From.Compile from_part    :"+from_part);
			ddmClient.mydebug("From.Compile from_option  :"+from_option);
			ddmClient.mydebug("From.Compile alias        :"+alias);
		}
		
		ArrayList<ddmChunk> tmpChunks=postgreParser.getChunks(sbFromPart.toString(), postgreParser.invisibleChars, false);
		int pos_select=postgreParser.getNextChunkId(tmpChunks, 0, tmpChunks.size(), true, false, false, false, postgreParser.KEYWORD_SELECT);

		if (pos_select>-1) isSubQuery=true;


		
		if (isSubQuery && alias.length()==0) {
			alias="al$_"+System.currentTimeMillis();
		}
		
		if (alias.length()>0)	
			postgreParser.prepareMatchListForFromPart(matchList,null,alias,null);
		
		
		ddmClient.mydebug("compile.FROM "+text+" AS "+alias);
				
		if (!isSubQuery) {
			
			int pos_dot=sbFromPart.indexOf(".");
			
			if (pos_dot==-1) {
				object_owner=ddmClient.CURRENT_SCHEMA;
				object_name=postgreParser.clearQueote(sbFromPart.toString());	
			} 
			else {
				object_owner=postgreParser.clearQueote(sbFromPart.substring(0,pos_dot));
				object_name=postgreParser.clearQueote(sbFromPart.substring(pos_dot+1));
			}
			
			StringBuilder sbSchema=new StringBuilder();
			StringBuilder sbObject=new StringBuilder();
			
			sbSchema.append(object_owner);
			sbObject.append(object_name);
			
			//aliasli hali varsa atilir. 
			if (alias.length()==0) 
				postgreParser.prepareMatchListForFromPart(matchList,object_owner,object_name,ddmClient.CURRENT_SCHEMA);
			
			 
			long start_ts=System.currentTimeMillis();
			hasError=!postgreParser.discoverObjectFromDb(object_owner, object_name, ddmClient, sbSchema, sbObject, columns);
			ddmClient.mydebug("DB Discovery Duration ["+object_owner+"."+object_name+"]: "+(System.currentTimeMillis()-start_ts));
			
			object_owner=sbSchema.toString();
			object_name=sbObject.toString();
			
			if (ddmClient.dm.hmConfig.containsKey("TAB_FILTER_FOR_"+ object_owner+"."+object_name))
				table_filter=(String) ddmClient.dm.hmConfig.get("TAB_FILTER_FOR_"+ object_owner+"."+object_name);
			
			if (alias.length()==0) 
				postgreParser.prepareMatchListForFromPart(matchList,object_owner,object_name,ddmClient.CURRENT_SCHEMA);
			
			stmtForThisFrom=stmtForOwner;
		} 
		else {
			stmtForThisFrom=postgreParser.parse(sbFromPart.toString(), stmtForOwner, ddmClient);
			stmtForThisFrom.fromBased=this;

			stmtForThisFrom.parse(ddmClient);
			postgreParser.expandStatement(stmtForThisFrom, ddmClient);
		}
		
		
	}
	
	


	
	
}
