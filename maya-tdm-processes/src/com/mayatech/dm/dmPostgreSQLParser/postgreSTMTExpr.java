package com.mayatech.dm.dmPostgreSQLParser;

import java.util.ArrayList;

import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmChunk;

public class postgreSTMTExpr {
	
	
	postgreSTMTExpr parentExpr=null;
	
	String text=null;

	String function_name_part=null;
	String function_parameters_part=null;
	
	ddmChunk chunk=null;
	
	boolean isSubQuery=false;
	boolean isComment=false;
	boolean isOperator=false;
	boolean isLiteral=false;
	boolean isFunctionOrColumnName=false;
	boolean isFunctionParameter=false;
		
	ArrayList<postgreSTMTExpr> exprList=new ArrayList<postgreSTMTExpr>();
	
	
	ArrayList<postgreSTMTColumn> baseColumns=new ArrayList<postgreSTMTColumn>();
	
	String maskingFunction="NONE";


	
	
	void compile(ddmClient ddmClient) {
		
		
		
		if (postgreParser.matchesAny(text, 0, postgreParser.operators)>-1 || text.equals(",")) {
			isOperator=true;
			return;
		}
		
		if (chunk.isLineComment || chunk.isMultiLineComment) {
			isComment=true;
			return;
		}
		
		
		
		if (text.charAt(0)==postgreParser.char_single_quote && text.charAt(text.length()-1)==postgreParser.char_single_quote) {
			isLiteral=true;
			return;
		}
		
		
			
		StringBuilder cleared=new StringBuilder(text);
		postgreParser.clearUnnecesaryParantesis(cleared);
		
		StringBuilder statement_type=new StringBuilder();
		StringBuilder statement_related_object=new StringBuilder();
		
		postgreParser.determineStatementType(cleared.toString(), statement_type, statement_related_object);
		
		if (statement_type.toString().equals(postgreParser.POSTGRE_SELECT)) {
			text=cleared.toString();
			isSubQuery=true;
			return;
		}

		
		if (chunk.isBlock) {
			isFunctionParameter=true;
			function_parameters_part=cleared.toString();
			
			
			ArrayList<ddmChunk> chunksForParams=postgreParser.getChunksByComma(function_parameters_part);
			

			for (int c=0;c<chunksForParams.size();c++) {
				
				if (c>0) {
					postgreSTMTExpr exprComma=new postgreSTMTExpr();
					exprComma.text=",";
					exprComma.parentExpr=this;
					exprComma.compile(ddmClient);
					exprList.add(exprComma);
					
				}
				exprList.addAll(postgreParser.getExpressionList(chunksForParams.get(c).text, this, ddmClient));
			}
			
			return;
		}
		
		isFunctionOrColumnName=true;
		function_name_part=text;
		
	}
	
	
	
}
