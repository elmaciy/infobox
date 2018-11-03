package com.mayatech.dm.dmMsSqlParser;

import java.util.ArrayList;

import com.mayatech.baseLibs.genLib;
import com.mayatech.dm.ddmChunk;
import com.mayatech.dm.ddmClient;


public class msSqlSTMT {

	long statement_id=msSqlParser.generateStatementId();
	public String statement_type=msSqlParser.STMT_TYPE_UNDETECTED;
	public String statement_related_object=null;
	
	String original_query=null;
	String query=null;
	
	String query_template=null;
	msSqlSTMTFrom fromBased=null;
	

	msSqlSTMT parentStmt=null;
	
	boolean isParsed=false;
	boolean isExpanded=false;
	boolean isExpressionExtracted=false;
	
	boolean isSubStatement=true;
	
	boolean hasError=false;
	
	String union_part=null;
	String with_part=null;
	String select_part=null;
	String into_part=null;
	String from_part=null;
	String after_from_part=null;
	
	int with_part_start_pos_in_query=-1;
	int select_part_start_pos_in_query=-1;
	int from_part_start_pos_in_query=-1;
	int end_of_from_part_start_pos_in_query=-1;

	ArrayList<ddmChunk> withChunks=new ArrayList<ddmChunk>();
	ArrayList<ddmChunk> selectChunks=new ArrayList<ddmChunk>();
	ArrayList<ddmChunk> fromChunks=new ArrayList<ddmChunk>();

	
	ArrayList<ddmChunk> chunks=new ArrayList<ddmChunk>();
	
	ArrayList<msSqlSTMT> subStatements=new ArrayList<msSqlSTMT>();
	
	ArrayList<msSqlSTMTSelect> selectList=new ArrayList<msSqlSTMTSelect>();
	ArrayList<msSqlSTMTFrom> fromList=new ArrayList<msSqlSTMTFrom>();
	
	public boolean isRewritable=false;
	
	//-----------------------------------------------------------------
	void parse(ddmClient ddmClient) {
		
		if (isParsed) return;
		
		original_query=query;
		
		ddmClient.mydebug("parseSTMT : "+this.query+" "+this.statement_id);
		
		StringBuilder stmt_type=new StringBuilder();
		StringBuilder related_object=new StringBuilder();
		
		msSqlParser.determineStatementType(query, stmt_type, related_object);
		
		statement_type=stmt_type.toString();
		statement_related_object =related_object.toString();
		
		isRewritable=
				statement_type.equals(msSqlParser.MSSQL_SELECT) ||
				statement_type.equals(msSqlParser.MSSQL_PLSQL_BLOCK) ||
				statement_type.equals(msSqlParser.MSSQL_INSERT_WITH_SELECT) ||
				statement_type.equals(msSqlParser.MSSQL_UPDATE) ||
				statement_type.equals(msSqlParser.MSSQL_CREATE_VIEW) ||
				statement_type.equals(msSqlParser.MSSQL_CREATE_MATERIALIZED_VIEW) ||
				statement_type.equals(msSqlParser.MSSQL_CREATE_TABLE_AS);
		
		

		
		if (!isRewritable) return;
		
		parseSelectStmt(ddmClient);
		
		isParsed=true;
	
	}
	
	//----------------------------------------------------------------
	void parseSelectStmt(ddmClient ddmClient) {
		
		splitUnionPart();
		
		StringBuilder cleared=new StringBuilder(query);
		msSqlParser.clearUnnecesaryParantesis(cleared);
		query=cleared.toString();
		
		ArrayList<ddmChunk> chunkArr=msSqlParser.getChunks(this.query, msSqlParser.invisibleChars, false);
		

		this.chunks.clear();
		this.chunks.addAll(chunkArr);
		
		
		ddmClient.mydebug("parseSTMT : this.chunks.addAll done.");
				
		if (this.isSubStatement) {
			extractSelectFromChunks(ddmClient);		
			ddmClient.mydebug("parseSTMT : extractSelectFromChunks done.");
			
			
			makeTemplateQuery(ddmClient);
			ddmClient.mydebug("parseSTMT : makeTemplateQuery done.");
			
			
			
			
			compileSelectPart(ddmClient);
			ddmClient.mydebug("parseSTMT : compileSelectPart done.");
			
			
			compileFromPart(ddmClient);
			ddmClient.mydebug("parseSTMT : compileFromPart done.");
			
			msSqlParser.expandStatement(this, ddmClient);
			ddmClient.mydebug("parseSTMT : expandStatement done.");
			
			
		}
		else {
			ArrayList<Integer> splitPositions=new ArrayList<Integer>();
			
			msSqlParser.splitSelectQuery(query,chunks,splitPositions, ddmClient);
			ddmClient.mydebug("parseSTMT : splitSelectQuery done."+", splitited to : "+splitPositions+" parts.");
			
			msSqlParser.addUnitedStatements(chunks, splitPositions, this, ddmClient);
			ddmClient.mydebug("parseSTMT : addUnitedStatements done.");
		}
	}
	
	//----------------------------------------------------------------
	void splitUnionPart() {
		
		if (!isSubStatement) return;
		
		
		
		ArrayList<ddmChunk> chunkArr=msSqlParser.getChunks(query, msSqlParser.invisibleChars, false);
		int pos_union=msSqlParser.getNextChunkId(chunkArr, 0, chunkArr.size(), true, false, false, false, msSqlParser.UNION_WORDS);
		if (pos_union==-1) return;
		int pos_first_select=msSqlParser.getNextChunkId(chunkArr, 0, chunkArr.size(), true, false, false, false, msSqlParser.KEYWORD_SELECT);
		if (pos_first_select==-1) 
			pos_first_select=msSqlParser.getNextChunkId(chunkArr, 0, chunkArr.size(), false, false, true, false, null);
		if (pos_first_select==-1) return;
		
		if (pos_union>=pos_first_select) return;
		
		union_part=query.substring(0,chunkArr.get(pos_first_select).startPosInText);
		query=query.substring(chunkArr.get(pos_first_select).startPosInText);
		
		
	}
	
	
	
	
	
	//----------------------------------------------------------------
	void makeTemplateQuery(ddmClient ddmClient) {
		
		ddmClient.mydebug("makeTemplateQuery query="+query);
		
		StringBuilder sb=new StringBuilder(query);
		

		sb.delete(from_part_start_pos_in_query, end_of_from_part_start_pos_in_query);
		sb.insert(from_part_start_pos_in_query, " ${#FROM_PART#} ");
		
		sb.delete(select_part_start_pos_in_query, from_part_start_pos_in_query);
		sb.insert(select_part_start_pos_in_query, " ${#SELECT_PART#} ");
		
		if (with_part_start_pos_in_query>-1) {
			sb.delete(with_part_start_pos_in_query, select_part_start_pos_in_query);
			sb.insert(with_part_start_pos_in_query, " ${#WITH_PART#} ");
		}
		
		
		
		query_template=sb.toString();
		
	}
	
	
	
	//----------------------------------------------------------------
	void compileSelectPart(ddmClient ddmClient) {
		
		for (int i=0;i<selectChunks.size();i++) {
		
			ddmChunk chunk=selectChunks.get(i);
			
			
			msSqlSTMTSelect select=new msSqlSTMTSelect();
			select.text=chunk.text;
			select.compile(ddmClient);
			selectList.add(select);
		}
	}
	
	
	
	//----------------------------------------------------------------
	void extractSelectFromChunks(ddmClient ddmClient) {
		
				
		int pos_select=msSqlParser.getNextChunkId(chunks, 0, chunks.size(), true, false, false, false, msSqlParser.KEYWORD_SELECT);
		if (pos_select==-1) {
			hasError=true;
			ddmClient.mydebug(" extractWithSelectFromChunks : '"+msSqlParser.KEYWORD_SELECT+"' not found ");
			return;
		}
		
		int pos_from=msSqlParser.getNextChunkId(chunks, pos_select, chunks.size(), true, false, false, false, msSqlParser.KEYWORD_FROM);
		if (pos_from==-1 || pos_from<pos_select) {
			hasError=true;
			ddmClient.mydebug("compileSelect : 'FROM' not found or invalid");
			return;
		}
		
		/*
		int pos_end_of_from=msSqlParser.getNextChunkId(chunks, pos_from, chunks.size(), true, false, false, false, msSqlParser.KEYWORD_WHERE);  
		if (pos_end_of_from==-1) pos_end_of_from=msSqlParser.getNextChunkId(chunks, pos_from, chunks.size(), true, false, false, false, msSqlParser.KEYWORD_ORDER);
		if (pos_end_of_from==-1) pos_end_of_from=msSqlParser.getNextChunkId(chunks, pos_from, chunks.size(), true, false, false, false, msSqlParser.KEYWORD_GROUP);
		if (pos_end_of_from==-1) pos_end_of_from=msSqlParser.getNextChunkId(chunks, pos_from, chunks.size(), true, false, false, false, msSqlParser.KEYWORD_HAVING);
		if (pos_end_of_from==-1) pos_end_of_from=msSqlParser.getNextChunkId(chunks, pos_from, chunks.size(), true, false, false, false, msSqlParser.KEYWORD_OPTION);
		*/
		
		
		
		int pos_end_of_from=msSqlParser.getNextChunkId(chunks, pos_from, chunks.size(), true, false, false, false, msSqlParser.KEYWORDS_AFTER_FROM);
		
		if (pos_end_of_from==-1) pos_end_of_from=chunks.size();
		
		select_part_start_pos_in_query=chunks.get(pos_select).startPosInText;
		from_part_start_pos_in_query=chunks.get(pos_from).startPosInText;
		
		if (pos_end_of_from==chunks.size())
			end_of_from_part_start_pos_in_query=query.length();
		else 
			end_of_from_part_start_pos_in_query=chunks.get(pos_end_of_from).startPosInText;


		
		
		select_part=query.substring(select_part_start_pos_in_query+6,from_part_start_pos_in_query);
		
		ArrayList<ddmChunk> intoCheckArr=msSqlParser.getChunks(select_part, msSqlParser.invisibleChars, false);
		int pos_into=msSqlParser.getNextChunkId(intoCheckArr, 0, intoCheckArr.size(), true, false, false, false, msSqlParser.KEYWORD_INTO);
		

		if (pos_into>-1) {
			into_part=select_part.substring(intoCheckArr.get(pos_into).startPosInText+4);
			select_part=select_part.substring(0,intoCheckArr.get(pos_into).startPosInText);
		} 
		
		
		from_part=query.substring(from_part_start_pos_in_query+4,end_of_from_part_start_pos_in_query);
		
		
		
		selectChunks.addAll(msSqlParser.getChunksByComma(select_part));
		
		after_from_part=query.substring(end_of_from_part_start_pos_in_query);
		
		
		

	}
	
	




	
	
	
	//----------------------------------------------------------------
	void compileFromPart(ddmClient ddmClient) {
				
		

		fromChunks=msSqlParser.getChunksForFromPart(from_part);
		
		for (int i=0;i<fromChunks.size();i++) {
			ddmChunk chunk=fromChunks.get(i);
			
			msSqlSTMTFrom from=new msSqlSTMTFrom();
			
			
						
			from.stmtForOwner=this;
			from.text=chunk.text;
			from.compile(ddmClient);
			fromList.add(from);

		}
	}
	

	//------------------------------------------------------------------------------------
	void printFrom(ddmClient ddmClient, msSqlSTMTFrom from, String padding_str) {
		ddmClient.mydebug(padding_str+"\tFROM  Text                      :"+from.text+" as "+from.alias);
		ddmClient.mydebug(padding_str+"\tFROM  stmtForThisFrom           :"+"@"+from.stmtForThisFrom.statement_id+" "+from.stmtForThisFrom.query);
		ddmClient.mydebug(padding_str+"\tFROM  stmtForOwner              :"+"@"+from.stmtForOwner.statement_id+    " "+from.stmtForOwner.query);
		
		if (from.isSubQuery)
			printSTMT(from.stmtForThisFrom, ddmClient);
	}
	
	//------------------------------------------------------------------------------------
	String printExpression(ddmClient ddmClient, msSqlSTMTExpr expr) {
		
		StringBuilder sb=new StringBuilder();
		
		if (expr.isFunctionParameter) {
			sb.append(expr.function_name_part);
			sb.append("(");
		}
		if (expr.exprList.size()==0) {
			sb.append(expr.text);
			if (expr.baseColumns.size()>0) {
				sb.append("/*");
				for (int b=0;b<expr.baseColumns.size();b++) {
					if (b>0) sb.append("+");
					sb.append(expr.baseColumns.get(b).col_path);
				}
					
			  sb.append("*/");
			}
		}
		else 
			for (int e=0;e<expr.exprList.size();e++) {
				//if (expr.exprList.get(e)!=null && expr.exprList.get(e).parentExpr.isFunction && e>0) sb.append(",");
				sb.append(printExpression(ddmClient, expr.exprList.get(e)));
			}
		
		if (expr.isFunctionParameter) sb.append(")");
			
		
		
		
		return sb.toString();
		
	}
	//------------------------------------------------------------------------------------
	void printSelect(ddmClient ddmClient, msSqlSTMTSelect select, String padding_str) {
		
		StringBuilder sb=new StringBuilder();
		
		sb.append(padding_str+"\tSELECT  Text                      :"+select.text+"=> ");
		
		
		
		for (int e=0;e<select.exprList.size();e++) 
			sb.append(printExpression(ddmClient, select.exprList.get(e)));
				
		sb.append(" AS "+select.alias);
		
		ddmClient.mydebug(sb.toString());
		
	}
	//------------------------------------------------------------------------------------
	void printSTMT(msSqlSTMT stmt, ddmClient ddmClient) {
		
		if (!ddmClient.dm.is_debug && !ddmClient.is_tracing) return;
		
		
		String padding_str="";
		if (stmt.isSubStatement) padding_str="\t\t";

		
		ddmClient.mydebug(padding_str+"--------------------------------------------------------");
		ddmClient.mydebug(padding_str+"STMT ID                                     : "+stmt.statement_id);
		ddmClient.mydebug(padding_str+"STMT Type                                   : "+stmt.statement_type);
		ddmClient.mydebug(padding_str+"STMT Related Object                         : "+stmt.statement_related_object);
		ddmClient.mydebug(padding_str+"STMT isSubQuery                             : "+stmt.isSubStatement);
		ddmClient.mydebug(padding_str+"STMT Query                                  : "+stmt.query);
		ddmClient.mydebug(padding_str+"STMT Template Query                         : "+stmt.query_template);
		
		if (stmt.parentStmt!=null) {
			ddmClient.mydebug(padding_str+"STMT PARENT STMT ID                         : "+stmt.parentStmt.statement_id);

			ddmClient.mydebug(padding_str+"--------------------------------------------------------");
			for (int s=0;s<stmt.selectList.size();s++) 
				printSelect(ddmClient, stmt.selectList.get(s),padding_str);
			ddmClient.mydebug(padding_str+"--------------------------------------------------------");
			for (int f=0;f<stmt.fromList.size();f++) 
				printFrom(ddmClient, stmt.fromList.get(f),padding_str);
		}
		
		
		for (int s=0;s<stmt.subStatements.size();s++)
			printSTMT(stmt.subStatements.get(s), ddmClient);
		
		ddmClient.mydebug(padding_str+"--------------------------------------------------------");
	}
	
	//------------------------------------------------------------------------------------
	public String rewriteSingleSQL(
			ddmClient ddmClient,
			boolean validateQuery,
			boolean toMask,
			msSqlSTMT outerSTMT
			) {
		
		StringBuilder sbRet=new StringBuilder();
		
		if (this.subStatements.size()==0) {
			return null;
		}
		
		
		
		if (validateQuery) {
			StringBuilder err=new StringBuilder();
			String only_select_part=msSqlParser.extractOnlySelectPart(this.query);
			
			ArrayList<String> testCols=msSqlParser.getColNamesFromStatement(ddmClient.connParallel, only_select_part,err);
			
			if (testCols.size()==0) {
				ddmClient.mydebug("rewriteSQL           : Orjinal query is not valid. Returning the original.");
				ddmClient.mydebug("--------------------------------------------------------------------");
				ddmClient.mydebug("rewriteSQL. Exception : \n"+err.toString());
				ddmClient.mydebug("--------------------------------------------------------------------");
				ddmClient.mydebug("rewriteSQL. Original : \n"+only_select_part);
				ddmClient.mydebug("--------------------------------------------------------------------");
				
				return this.query;
			}
		} //if (validateQuery)
		
		
		
		StringBuilder sbSelect=new StringBuilder();
		StringBuilder sbFrom=new StringBuilder();
		//StringBuilder sbGroup=new StringBuilder();
		
		
		try {

			if (toMask) {
				
				msSqlParser.discoverSourceColumns(this, outerSTMT, ddmClient);
				this.printSTMT(this,ddmClient);
			}
			
			
			
			for (int i=0;i<this.subStatements.size();i++) {
				msSqlSTMT subStmt=this.subStatements.get(i);
				
				
				
				StringBuilder sb=new StringBuilder(subStmt.query_template);
								
				
				
				
				sbSelect.setLength(0);
				sbFrom.setLength(0);
				
				
				
				
				//------------------- SELECT

				for (int e=0;e<subStmt.selectList.size();e++) {
					
					msSqlSTMTSelect aSel=subStmt.selectList.get(e);					
					
					if (sbSelect.length()>0) sbSelect.append(",\n");
					sbSelect.append("\t\t");
					
					//add select  chunks like distinct, all, unique etc.
					for (int c=0;c<aSel.selectClausesChunkArr.size();c++) {
						sbSelect.append(" ");
						sbSelect.append(aSel.selectClausesChunkArr.get(c).text);
						sbSelect.append(" ");
					}
					

					if (toMask)
						msSqlParser.setMaskingConfigurationForSelect(aSel, subStmt, ddmClient);
					
					String selection_from_expr=msSqlParser.getSelectionFromExpression(aSel, aSel.exprList, ddmClient, subStmt);
										
					sbSelect.append(selection_from_expr);

				
					if (!aSel.isAssigned) {
						if (aSel.alias.length()==0) {
							String generated_alias=msSqlParser.generateAliasFromSelect(aSel, aSel.selection, subStmt);
							if (generated_alias.trim().length()>0) sbSelect.append(" as "+generated_alias);
						}
						else {
							String generated_alias=msSqlParser.generateAliasFromSelect(aSel, selection_from_expr, subStmt);
							if (generated_alias.trim().length()>0) sbSelect.append(" as "+generated_alias);
						}
					}
					
					
					//add comment chunks
					for (int c=0;c<aSel.commentChunkArr.size();c++) {
						sbSelect.append(" ");
						sbSelect.append(aSel.commentChunkArr.get(c).text);
						sbSelect.append(" ");
					}
				}
				
				
				if (subStmt.into_part!=null && subStmt.into_part.length()>0) {
					sbSelect.append("\n into \n");
					sbSelect.append(subStmt.into_part);
				}
				
				//------------------- FROM 
				
				for (int f=0;f<subStmt.fromList.size();f++) {
					msSqlSTMTFrom from=subStmt.fromList.get(f);
					
					if (f>0) 
						if (from.isJoin) sbFrom.append("\n"); else sbFrom.append(",\n");
					
					if (from.from_join.length()>0) {
						sbFrom.append(from.from_join);
						sbFrom.append(" ");
					}
						
					//try {sbFrom.append(from.text.substring(0, from.start_of_source));} catch(Exception e) {e.printStackTrace();}
					
					
					
					
					if (from.isSubQuery) {
						String innerSQL=from.stmtForThisFrom.rewriteSingleSQL(ddmClient, false, false, null);
						sbFrom.append("("+innerSQL+")");
						sbFrom.append("\n");
					} else 
					{
						sbFrom.append(from.from_part);
					}
					
					if (from.alias.length()>0) {
						sbFrom.append(" as ");
						sbFrom.append(from.alias);
					}

					if (from.from_option.length()>0) {
						sbFrom.append(" ");
						sbFrom.append(from.from_option);
					}

					/*
					if (from.isSubQuery) {
						sbFrom.append(" ");
						sbFrom.append(from.stmtForThisFrom.fromBased.alias);
						sbFrom.append(" ");
					} else {
						sbFrom.append(" ");
						sbFrom.append(from.alias);
						sbFrom.append(" ");
					}
					*/
					//if (from.from_option.length()>0) 
					//	sbFrom.append(from.text.substring(from.end_of_source+1));
					
					/*
					if (from.text.length()>=from.end_of_source+1)
					try {
						sbFrom.append(from.text.substring(from.end_of_source+1));
						} catch(Exception e) {e.printStackTrace();}

					System.out.println("*********** from.end_of_source : "+from.end_of_source);
					System.out.println("*********** from.text : "+from.text);
					System.out.println("*********** from Part 0005 : "+sbFrom.toString());
					*/
					
					for (int c=0;c<from.commentChunkArr.size();c++) {
						sbFrom.append(" ");
						sbFrom.append(from.commentChunkArr.get(c).text);
					}
					

				}
				
				
				
				
				//------------------------------------------------------------------
		
				
				
				if (sbSelect.length()>0) {
					String part_key="${#SELECT_PART#}";
					int ind=sb.indexOf(part_key);
					if (ind>-1) {
						sb.delete(ind, ind+part_key.length());
						sb.insert(ind, sbSelect.toString());
						sb.insert(ind, "\n");
						sb.insert(ind, msSqlParser.KEYWORD_SELECT);
					}
				}
				
				
				
				
				if (sbFrom.length()>0) {
					String part_key="${#FROM_PART#}";
					int ind=sb.indexOf(part_key);
					if (ind>-1) {
						sb.delete(ind, ind+part_key.length());
						sb.insert(ind, sbFrom.toString());
						sb.insert(ind, "\n");
						sb.insert(ind, msSqlParser.KEYWORD_FROM);
						sb.insert(ind, "\n ");
					}
				}


				if (sbRet.length()>0) sbRet.append("\n");
				
				if (subStmt.union_part!=null) sbRet.append(subStmt.union_part+"\n");
				
				sbRet.append(sb.toString());
				
				
			}
			
		} catch(Exception e) {
			ddmClient.mylog("rewriteSQL           : Exception.");
			ddmClient.mylog("Query                : "+this.query);
			ddmClient.mylog("--------------------------------------------------------------------");
			ddmClient.mylog("rewriteSQL. Exception : \n"+genLib.getStackTraceAsStringBuilder(e).toString());
			ddmClient.mylog("--------------------------------------------------------------------");
			
			return this.query;
		}
		
		
		
		
		if (validateQuery) {
			StringBuilder err=new StringBuilder();
			String only_select_part=msSqlParser.extractOnlySelectPart(this.query);
			
			ArrayList<String> testCols=msSqlParser.getColNamesFromStatement(ddmClient.connParallel, only_select_part,err);
			
			if (testCols.size()==0) {
				ddmClient.mylog("rewriteSQL           : Invalid query rewritten. Returning original.");
				ddmClient.mylog("--------------------------------------------------------------------");
				ddmClient.mylog("rewriteSQL. Exception : \n"+err.toString());
				ddmClient.mylog("--------------------------------------------------------------------");
				ddmClient.mylog("rewriteSQL. Original : \n"+query);
				ddmClient.mylog("--------------------------------------------------------------------");
				ddmClient.mylog("rewriteSQL. Query    : \n"+sbRet.toString());
				ddmClient.mylog("--------------------------------------------------------------------");
				
				return this.query;
			}
		}
		
		
		
		
		return sbRet.toString(); 
		
	}
	
	
	
}
