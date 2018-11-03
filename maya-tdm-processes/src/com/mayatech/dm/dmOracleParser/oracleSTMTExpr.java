package com.mayatech.dm.dmOracleParser;

import java.util.ArrayList;

import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmChunk;

public class oracleSTMTExpr {
	
	
	oracleSTMTExpr parentExpr=null;
	
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
		
	public ArrayList<oracleSTMTExpr> exprList=new ArrayList<oracleSTMTExpr>();
	public ArrayList<oracleSTMTColumn> baseColumns=new ArrayList<oracleSTMTColumn>();
	
	String maskingFunction="NONE";


	
	
	void compile(ddmClient ddmClient) {
		
		
		
		if (oracleParser.matchesAny(text, 0, oracleParser.operators)>-1 || text.equals(",")) {
			isOperator=true;
			return;
		}
		
		if (chunk.isLineComment || chunk.isMultiLineComment) {
			isComment=true;
			return;
		}
		
		
		
		if (text.charAt(0)==oracleParser.char_single_quote && text.charAt(text.length()-1)==oracleParser.char_single_quote) {
			isLiteral=true;
			return;
		}
		
		
			
		StringBuilder cleared=new StringBuilder(text);
		oracleParser.clearUnnecesaryParantesis(cleared);
		
		StringBuilder statement_type=new StringBuilder();
		StringBuilder statement_related_object=new StringBuilder();
		
		oracleParser.determineStatementType(cleared.toString(), statement_type, statement_related_object);
		
		if (statement_type.toString().equals(oracleParser.ORACLE_SELECT)) {
			text=cleared.toString();
			isSubQuery=true;
			return;
		}

		
		if (chunk.isBlock) {
			isFunctionParameter=true;
			function_parameters_part=cleared.toString();
			
			
			ArrayList<ddmChunk> chunksForParams=oracleParser.getChunksByComma(function_parameters_part);
			

			for (int c=0;c<chunksForParams.size();c++) {
				
				if (c>0) {
					oracleSTMTExpr exprComma=new oracleSTMTExpr();
					exprComma.text=",";
					exprComma.parentExpr=this;
					exprComma.compile(ddmClient);
					exprList.add(exprComma);
					
				}
				exprList.addAll(oracleParser.getExpressionList(chunksForParams.get(c).text, this, ddmClient));
			}
			
			return;
		}
		
		isFunctionOrColumnName=true;
		function_name_part=text;
		
	}
	
	
	
}
