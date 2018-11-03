package com.mayatech.dm.dmMsSqlParser;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;

import com.mayatech.baseLibs.genLib;
import com.mayatech.dm.ddmChunk;
import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmLib;

public final class msSqlParser {

	
	public static final short LEVEL_ROOT=0;
	
	public static final String KEYWORD_WITH="WITH";
	public static final String KEYWORD_SELECT="SELECT";
	public static final String KEYWORD_INTO="INTO";
	public static final String KEYWORD_FROM="FROM";
	public static final String KEYWORD_CONNECT="CONNECT";
	public static final String KEYWORD_WHERE="WHERE";
	public static final String KEYWORD_GROUP="GROUP";
	public static final String KEYWORD_BY="BY";
	public static final String KEYWORD_HAVING="HAVING";
	public static final String KEYWORD_ORDER="ORDER";
	public static final String KEYWORD_OPTION="OPTION";
	public static final String KEYWORD_ON="ON";
	public static final String KEYWORD_USING="USING";
	public static final String KEYWORD_JOIN="JOIN";
	public static final String KEYWORD_AS="AS";
	public static final String KEYWORD_FOR="FOR";
	public static final String KEYWORD_PIVOT="PIVOT";
	public static final String KEYWORD_UNPIVOT="UNPIVOT";
	
	public static final String KEYWORDS_AFTER_FROM=
			msSqlParser.KEYWORD_WHERE+"|"+
			msSqlParser.KEYWORD_ORDER+"|"+
			msSqlParser.KEYWORD_GROUP+"|"+
			msSqlParser.KEYWORD_HAVING+"|"+
			msSqlParser.KEYWORD_PIVOT+"|"+
			msSqlParser.KEYWORD_UNPIVOT+"|"+
			msSqlParser.KEYWORD_OPTION;
	
	
	public static final String KEYWORD_BEGIN="BEGIN";
	public static final String KEYWORD_END="END";
	public static final String KEYWORD_END_WITH_COMMA="END";
	
	public static final String UNION_WORDS="UNION|EXCEPT|INTERSECT";

	
	
	//-----------------------------------------------------
	public static final String invisibleChars=" \n\r\t";
	public static final String[] invisibleCharsArr=new String[]{" ","\n","\r","\t"};
	
	static final char[] multilineCommentStarter="/*".toCharArray();
	static final String multilineCommentFinisher="*/";
	
	static final char[] lineCommentStarter="--".toCharArray();
	static final char lineCommentFinisher1='\n';
	static final char lineCommentFinisher2='\r';
	
	static final char parantesisOpening='('; 
	static final char parantesisClosing=')'; 
	
	static final char bracketOpening='['; 
	static final char bracketClosing=']'; 
	
	static final char quoteChar='"'; 

	
	static final char comma_as_char=','; 
	static final String comma_as_str=","; 

	static final char qouteOpening='"'; 
	static final char qouteClosing='"'; 

	static final char singleQouteOpening='\''; 
	static final char singleQouteClosing='\''; 

	

	
	//-----------------------------------------------------
	static int getClosingParantesisPos(String query, int startIndex, int endIndex) {
		int opening_count=1;
		int closing_count=0;
		
		for (int i=startIndex;i<endIndex;i++) {
			if (query.charAt(i)==parantesisOpening) opening_count++;
			else if (query.charAt(i)==parantesisClosing) closing_count++;
			if (opening_count==closing_count) return i;
		}
		
		return -1;
	}
	
	//-----------------------------------------------------
	static int getClosingBracketPos(String query, int startIndex, int endIndex) {
		int opening_count=1;
		int closing_count=0;
		
		for (int i=startIndex;i<endIndex;i++) {
			if (query.charAt(i)==bracketOpening) opening_count++;
			else if (query.charAt(i)==bracketClosing) closing_count++;
			if (opening_count==closing_count) return i;
		}
		
		return -1;
	}
	
	//-----------------------------------------------------
	static int getClosingQuotePos(String query, int startIndex, int endIndex) {
		int quote_count=1;
		
		for (int i=startIndex;i<endIndex;i++) {
			if (query.charAt(i)==quoteChar) {
				quote_count++;
			}


			if (quote_count % 2==0) return i;
		}
		
		

		
		return -1;
	}

	
	//-----------------------------------------------------
	static int getClosingSingleQuotePos(String query, int startIndex, int endIndex) {
		int quote_count=1;
		
		for (int i=startIndex;i<endIndex;i++) {
			if (query.charAt(i)==singleQouteOpening) {
				quote_count++;
			}


			if (quote_count % 2==0) return i;
		}
		
		return -1;
	}	
	
	//-------------------------------------------------------------------------------------------
	public static ArrayList<ddmChunk> getChunks(
			String query, 
			String splitChars, 
			boolean skipComments) {
		return getChunks(query,splitChars,skipComments,true, true, true);
	}

	//-------------------------------------------------------------------------------------------
	public static ArrayList<ddmChunk> getChunks(
			String query, 
			String splitChars, 
			boolean skipComments,
			boolean checkBracket,
			boolean checkQuote,
			boolean checkSingleQuote
			) {
		
		
	
		ArrayList<ddmChunk> ret1=new ArrayList<ddmChunk>();
		
		if (query==null || query.length()==0) return ret1;
		
		int cursor=0;
		int start_pointer=0;
		int query_len=query.length();
		
		
		
		while(true) {
			
			
			if (cursor<query_len-1 && query.charAt(cursor)==multilineCommentStarter[0] && query.charAt(cursor+1)==multilineCommentStarter[1]) {
				
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}
					
				
				
				int pos_multiline_comment_finish=query.indexOf(multilineCommentFinisher,cursor+2);
				if (pos_multiline_comment_finish==-1) pos_multiline_comment_finish=query_len;
				
				if (!skipComments) {
					ddmChunk chunk=new ddmChunk(query.substring(cursor,pos_multiline_comment_finish+2));
					chunk.isMultiLineComment=true;
					chunk.startPosInText=cursor;
					ret1.add(chunk);
				}
				
				cursor=pos_multiline_comment_finish+2;
				start_pointer=cursor;		
			}
			else if (cursor<query_len-1 && query.charAt(cursor)==lineCommentStarter[0] && query.charAt(cursor+1)==lineCommentStarter[1]) {
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}
				
				int pos_line_comment_finish=query.indexOf(lineCommentFinisher1,cursor+2);
				if (pos_line_comment_finish==-1) pos_line_comment_finish=query.indexOf(lineCommentFinisher2,cursor+2);
				if (pos_line_comment_finish==-1) pos_line_comment_finish=query_len;
				
				if (!skipComments) {
					
					//ddmParserChunk chunk=new ddmParserChunk(query.substring(cursor,pos_line_comment_finish+1));
					ddmChunk chunk=new ddmChunk(query.substring(cursor,pos_line_comment_finish));
					chunk.isLineComment=true;
					chunk.startPosInText=cursor;
					ret1.add(chunk);
				}
				
				cursor=pos_line_comment_finish+1;
				start_pointer=cursor;
			}
			else if (query.charAt(cursor)==parantesisOpening) {
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}

				
				int pos_parantesis_closing=getClosingParantesisPos(query, cursor+1, query_len);
				
				if (pos_parantesis_closing==-1) {
					cursor++;
				}
				else {
					ddmChunk chunk=new ddmChunk(query.substring(cursor,pos_parantesis_closing+1));
					chunk.isBlock=true;
					chunk.startPosInText=cursor;
					ret1.add(chunk);
					cursor=pos_parantesis_closing+1;
					start_pointer=cursor;
				}
				
				
			}
			else if (query.charAt(cursor)==bracketOpening) {
				if (start_pointer<cursor) {
					if (checkBracket) {
						ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
						chunk.isSingleWord=true;
						chunk.startPosInText=start_pointer;
						ret1.add(chunk);
					}
				}

				
				int pos_bracket_closing=getClosingBracketPos(query, cursor+1, query_len);
				
				if (pos_bracket_closing==-1) {
					cursor++;
				}
				else {
					
					
					if (checkBracket) {
						ddmChunk chunk=new ddmChunk(query.substring(cursor,pos_bracket_closing+1));
						chunk.isSingleWord=true;
						chunk.startPosInText=cursor;
						ret1.add(chunk);
						cursor=pos_bracket_closing+1;
						start_pointer=cursor;
					}
					else 
						cursor=pos_bracket_closing+1;
					
				}
				
				
			}
			else if (query.charAt(cursor)==qouteOpening) {
				if (start_pointer<cursor) {
					if (checkQuote) {
						ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
						chunk.isSingleWord=true;
						chunk.startPosInText=start_pointer;
						ret1.add(chunk);
					}
				}
				
				int pos_quote_closing=getClosingQuotePos(query, cursor+1, query_len);
				
				if (pos_quote_closing==-1) {
					cursor++;
				} else {
					
					
					if (checkQuote) {
						ddmChunk chunk=new ddmChunk(query.substring(cursor,pos_quote_closing+1));
						chunk.isSingleWord=true;
						chunk.startPosInText=cursor;
						ret1.add(chunk);
						cursor=pos_quote_closing+1;
						start_pointer=cursor;
					}
					else 
						cursor=pos_quote_closing+1;
					
				}

				
			}
			else if (query.charAt(cursor)==singleQouteOpening) {
				if (start_pointer<cursor) {
					if (checkSingleQuote) {
						ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
						chunk.isSingleWord=true;
						chunk.startPosInText=start_pointer;
						ret1.add(chunk);
					}
					
				}
				
				int pos_quote_closing=getClosingSingleQuotePos(query, cursor+1, query_len);
				
				if (pos_quote_closing==-1) {
					cursor++;
				} else {
					
					
					if (checkSingleQuote) {
						ddmChunk chunk=new ddmChunk(query.substring(cursor,pos_quote_closing+1));
						chunk.isSingleWord=true;
						chunk.startPosInText=cursor;
						ret1.add(chunk);
						cursor=pos_quote_closing+1;
						start_pointer=cursor;
					} else 
						cursor=pos_quote_closing+1;
					
					
					
				}

				
			} 
			else if(query.charAt(cursor)==comma_as_char) {
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}
				
				if (query.charAt(cursor)==comma_as_char) {
					ddmChunk chunk=new ddmChunk(comma_as_str);
					chunk.isComma=true;
					chunk.startPosInText=cursor;
					ret1.add(chunk);
				}

				start_pointer=cursor+1;
				cursor++;
				
			}
			else if (splitChars.contains(query.substring(cursor, cursor+1))) {
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}
					
				start_pointer=cursor+1;
				cursor++;
			}
			else 
				cursor++;
				
			
			/*	
			System.out.println("cursor        ="+cursor);
			System.out.println("query_len     ="+query_len);
			System.out.println("start_pointer ="+start_pointer);
			*/


			if (cursor>=query_len) {
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}
				break;
			}
			
		}
		
		
		return ret1;
	}
	
	//--------------------------------------------------------------------------
	static ArrayList<ddmChunk> getChunksByComma(String query) {
		
		

		ArrayList<ddmChunk> ret1=new ArrayList<ddmChunk>();
		
		if (query==null) return ret1;
		
		int cursor=0;
		int start_pointer=0;
		int query_len=query.length();
		
		while(true) {
			
			if (cursor<query_len-1 && query.charAt(cursor)==multilineCommentStarter[0] && query.charAt(cursor+1)==multilineCommentStarter[1]) {
				
				int pos_multiline_comment_finish=query.indexOf(multilineCommentFinisher,cursor+2);
				if (pos_multiline_comment_finish==-1) pos_multiline_comment_finish=query_len;
				cursor=pos_multiline_comment_finish+2;
			}
			else if (cursor<query_len-1 && query.charAt(cursor)==lineCommentStarter[0] && query.charAt(cursor+1)==lineCommentStarter[1]) {
				
				int pos_line_comment_finish=query.indexOf(lineCommentFinisher1,cursor+2);
				if (pos_line_comment_finish==-1) pos_line_comment_finish=query.indexOf(lineCommentFinisher2,cursor+2);
				if (pos_line_comment_finish==-1) pos_line_comment_finish=query_len;
				
				cursor=pos_line_comment_finish+1;
			}
			else if (query.charAt(cursor)==parantesisOpening) {
				int pos_parantesis_closing=getClosingParantesisPos(query, cursor+1, query_len);
				if (pos_parantesis_closing==-1) 
					cursor++;
				else 
					cursor=pos_parantesis_closing+1;
			}
			else if(query.charAt(cursor)==comma_as_char) {
				
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}

				if (query.charAt(cursor)==comma_as_char) {
					ddmChunk chunk=new ddmChunk(comma_as_str);
					chunk.isComma=true;
					chunk.startPosInText=cursor;
					ret1.add(chunk);
				}
				
				start_pointer=cursor+1;
				cursor++;
				
			}
			else 
				cursor++;
				
			
						
			
			if (cursor>=query_len) {
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}
				break;
			}
			
		}
		
		
		clearEmptyAndCommaChunks(ret1);
		
		return ret1;
	}
	
	//-----------------------------------------------------
	static void clearEmptyAndCommaChunks(ArrayList<ddmChunk> chunkArr) {
		for (int i=chunkArr.size()-1;i>=0;i--) 
			if (chunkArr.get(i).isComma || chunkArr.get(i).text.replaceAll("\n\r\t ", "").length()==0) 
				chunkArr.remove(i);
	}

	//-----------------------------------------------------
	public static boolean equalsAny(String str, String cmpstr) {
		String[] matchArr=cmpstr.split("\\|");
		if(matchesAny(str, 0, matchArr)>-1) return true;
		return false;
	}
	//-----------------------------------------------------
	public static int getNextChunkId(
			ArrayList<ddmChunk> chunkArr, 
			int startIndex, 
			int EndIndex, 
			boolean isSigleWord, 
			boolean isComment, 
			boolean isBlock,
			boolean isOperator,
			String singleWordQuery) {
		
		
		if (startIndex<0 || startIndex>chunkArr.size()-1) return -1;
		if (EndIndex<1 || EndIndex>chunkArr.size()) return -1;
		
		for (int i=startIndex;i<EndIndex;i++) {
			
			
			ddmChunk chunk=chunkArr.get(i);
			
			
			if (chunk.isSingleWord==isSigleWord && (chunk.isLineComment|chunk.isMultiLineComment)==isComment && chunk.isBlock==isBlock && chunk.isOperator==isOperator) {
				if (singleWordQuery==null || equalsAny(chunk.text,singleWordQuery) ) return i;
			}
		}
		
		return -1;
	}
	
	
	//-----------------------------------------------------
	public static int getLastChunkId(
			ArrayList<ddmChunk> chunkArr, 
			int startIndex, 
			int EndIndex, 
			boolean isSigleWord, 
			boolean isComment, 
			boolean isBlock,
			String singleWordQuery) {
		
		int ret1=-1;
		
		
		for (int i=startIndex;i<EndIndex;i++) {
			ddmChunk chunk=chunkArr.get(i);
			if (chunk.isSingleWord==isSigleWord && (chunk.isLineComment|chunk.isMultiLineComment)==isComment && chunk.isBlock==isBlock ) {
				if (singleWordQuery==null || chunk.text.equalsIgnoreCase(singleWordQuery)) 
					ret1=i;
			}
		}
		
		return ret1;
	}
	
	
	
	//-----------------------------------------------------
	
	static final String SPLITTER_UNION="UNION";
	static final String SPLITTER_EXCEPT="EXCEPT";
	static final String SPLITTER_INTERSECT="INTERSECT";
	
	static void splitSelectQuery(String query, ArrayList<ddmChunk> chunks,   ArrayList<Integer> splitPositions, ddmClient ddmClient) {
		
		chunks.clear();
		ArrayList<ddmChunk> chunkArr=getChunks(query,invisibleChars,false);
		
		ddmClient.mydebug("splitSelectQuery : chunkArr.size() :"+chunkArr.size());
		
		
		chunks.addAll(chunkArr);
		
		
		for (int i=0;i<chunks.size()-2;i++) {
			if (i==0)  splitPositions.add(i);
			else if (chunks.get(i).isSingleWord && 
						(
							chunks.get(i).text.equalsIgnoreCase(SPLITTER_UNION) 
							|| chunks.get(i).text.equalsIgnoreCase(SPLITTER_EXCEPT) 
							|| chunks.get(i).text.equalsIgnoreCase(SPLITTER_INTERSECT)
						) 
					) 
				splitPositions.add(i);
			
		}
		
		
		


	}
	
	
	
	
	//-----------------------------------------------------

	public static msSqlSTMT parse(String query, msSqlSTMT parentSTMT, ddmClient ddmClient) {


		msSqlSTMT rootSTMT=new msSqlSTMT();
		rootSTMT.query=query;
		rootSTMT.isSubStatement=false;
		rootSTMT.parentStmt=parentSTMT;
		
		rootSTMT.parse(ddmClient);
		
		return rootSTMT;


	}
	
	
	//-----------------------------------------------------
	static void addUnitedStatements(
			ArrayList<ddmChunk> chunks, 
			ArrayList<Integer> splitPositions, 
			msSqlSTMT parentSTMT,
			ddmClient ddmClient
			) {
		
		
		ddmClient.mydebug("addUnitedStatements : splitPositions size : "+splitPositions.size());

		for (int s=0;s<splitPositions.size();s++) {
			
			int startIndex=splitPositions.get(s);
			int endIndex=chunks.size();
			if (s+1<splitPositions.size()) endIndex=splitPositions.get(s+1);
			
			int queryStartPos=chunks.get(startIndex).startPosInText;
			int queryEndPos=(chunks.get(endIndex-1).startPosInText+chunks.get(endIndex-1).text.length());
	
			msSqlSTMT stmt=new msSqlSTMT();
			
			stmt.parentStmt=parentSTMT;
			stmt.isSubStatement=true;
			stmt.query=parentSTMT.query.substring(queryStartPos,queryEndPos);
						
			stmt.parse(ddmClient);
			
			parentSTMT.subStatements.add(stmt);
			
		}
		
	}
	
	


	
	//----------------------------------------------------------
	static final String dot=".";
	
	static String mergeDotsBetweenNames(String text) {
		
		if (!text.contains(dot)) return text;
		
		
		StringBuilder sb=new StringBuilder(text);
		
		int pos_dot=0;
		while(true) {
			
			if (pos_dot>=sb.length()-1) break;
			pos_dot=sb.indexOf(dot,pos_dot);
			if (pos_dot==-1) break;
			try{
			while(true) 
				if (invisibleChars.contains(sb.substring(pos_dot+1, pos_dot+2))) 
					sb.delete(pos_dot+1,pos_dot+2);
				else 
					break;
			} catch(Exception e) {e.printStackTrace();}
			
			try{
				while(true) 
					if (invisibleChars.contains(sb.substring(pos_dot-1, pos_dot))) 
						{sb.delete(pos_dot-1,pos_dot); pos_dot--;}
					else 
						break;
			} catch(Exception e) {e.printStackTrace();}
			
			
			pos_dot++;
		}
		
		
		return sb.toString();
		
	}
	
	//-----------------------------------------------------------


	
	//static final String[] skipFromWords=new String[]{"with"	};
	static final String KEYWORD_FROM_OPTIONS="WITH|ON|TABLESAMPLE|PIVOT|UNPIVOT|FROM|BETWEEN|CONTAINED|ALL";
	
	public static int extractObjectNameAndAlias(
			String text, 
			StringBuilder sbText,
			StringBuilder from_joins,
			StringBuilder from_part, 
			StringBuilder from_option,
			StringBuilder alias
			) {
		
		ArrayList<ddmChunk> chunkArr=getChunks(text, invisibleChars,true);
		
		//for (int i=0;i<chunkArr.size();i++) System.out.println(chunkArr.get(i).text);
		
		mergeDottedChunks(chunkArr);
				
		sbText.append(chunkArrToText(chunkArr));
		
		chunkArr=getChunks(sbText.toString(), invisibleChars, true, false, false, true);
		
		//for (int i=0;i<chunkArr.size();i++) System.out.println(chunkArr.get(i).text);
				
		int pos_join=getNextChunkId(chunkArr, 0, chunkArr.size(), true, false, false, false, KEYWORD_JOIN);
		
		if (pos_join>-1) {
			int start_pos=0;
			int end_pos=chunkArr.get(pos_join).startPosInText+chunkArr.get(pos_join).text.length();
			from_joins.append(sbText.toString().substring(start_pos,end_pos));
		}
		
		int pos_source=-1;
		int pos_first_block=getNextChunkId(chunkArr, pos_join+1, chunkArr.size(), false, false, true, false, null);
		int pos_first_single=getNextChunkId(chunkArr, pos_join+1, chunkArr.size(), true, false, false, false, null);
		
		if (pos_first_block>-1) pos_source=pos_first_block;
		if (pos_source==-1 && pos_first_single>-1) pos_source=pos_first_single;
		if (pos_first_single>-1 && pos_first_single<pos_first_block)  pos_source=pos_first_single;
		
		
		if (pos_source==-1) {
			from_part.append(sbText.toString());
			return -1;
		}
		else {
			int start_pos=chunkArr.get(pos_source).startPosInText;
			int end_pos=start_pos+chunkArr.get(pos_source).text.length();
			from_part.append(sbText.toString().substring(start_pos,end_pos));
		}
		
			
		
		
		int  pos_options=getNextChunkId(chunkArr, pos_source+1, chunkArr.size(), true, false, false, false, KEYWORD_FROM_OPTIONS);
		
		
		if (pos_options>-1) {
			int start_pos=chunkArr.get(pos_options).startPosInText;
			int end_pos=sbText.toString().length();
			from_option.append(sbText.toString().substring(start_pos,end_pos));
		}
		
		int pos_as=getNextChunkId(chunkArr, pos_source, chunkArr.size(), true, false, false, false, KEYWORD_AS);
		
		int pos_alias=-1;
		
		if (pos_as>-1) 
			pos_alias=getNextChunkId(chunkArr, pos_as+1, chunkArr.size(), true, false, false, false, null);
		else {
			pos_alias=getNextChunkId(chunkArr, pos_source+1, chunkArr.size(), true, false, false, false, null);
			if (pos_alias==pos_options) pos_alias=-1;
		}
			
		if (pos_alias>-1) alias.append(chunkArr.get(pos_alias).text);
		
		return pos_join;
		
		
	}

	//---------------------------------------------------------------------------------------------
	static String chunkArrToText(ArrayList<ddmChunk> chunkArr) {
		StringBuilder sb=new StringBuilder();
		
		for (int i=0;i<chunkArr.size();i++) {
			ddmChunk chunk=chunkArr.get(i);
			ddmChunk prevChunk=null;
			if (i>0) prevChunk=chunkArr.get(i-1);

			if (sb.length()>0) {
				if (chunk.isMultiLineComment) sb.append("\n"); 
				else if (chunk.isLineComment)  sb.append(" "); 
				else if ((chunk.isBlock || chunk.isSingleWord) && prevChunk!=null && (prevChunk.isSingleWord || prevChunk.isBlock)) sb.append(" "); 
			}
			
			sb.append(chunk.text);
			
			if (chunk.isMultiLineComment) sb.append("\n");
			else if (chunk.isLineComment) sb.append("\n");
		}
		
		
		return sb.toString();
	}
	//---------------------------------------------------------------------------------------------
	public static void extractSelectionAndAlias(
			String text, 
			StringBuilder sbText,
			StringBuilder selection, 
			StringBuilder alias,
			ddmClient ddmClient
			) {

		
		selection.setLength(0);
		alias.setLength(0);
		
	
		ArrayList<ddmChunk> chunkArr=getChunks(text, invisibleChars, true);
		mergeDottedChunks(chunkArr);
		
		sbText.append(chunkArrToText(chunkArr));
		
		if (chunkArr.size()==1) {
			selection.append(sbText.toString().trim());
			return;
		}
		
		chunkArr=getChunks(sbText.toString(), invisibleChars, true, false, false, true);
		
		int pos_as=getNextChunkId(chunkArr, 0, chunkArr.size(), true, false, false, false, KEYWORD_AS);
		if (pos_as!=-1 && pos_as+1<chunkArr.size()) {
				ddmChunk chunk=chunkArr.get(pos_as);
				
			
				selection.append(sbText.toString().substring(0,chunk.startPosInText).trim());
		
				ddmChunk chunkAfterAs=chunkArr.get(pos_as+1);
		
				alias.append(chunkAfterAs.text.trim());
				
				return;
		}
		
		
		//en sondaki chunk case deki end ya da bir blok ise alias yoktur
		ddmChunk lastChunk=chunkArr.get(chunkArr.size()-1);
		if (lastChunk.text.equalsIgnoreCase("end") || lastChunk.isBlock) {
			selection.append(sbText.toString().trim());
			return;
		}
	
		int alias_chunk_id=getLastChunkId(chunkArr, 0, chunkArr.size(), true, false, false, null);
		
		
		if (alias_chunk_id>-1) {
			
			String alias_test_str=chunkArr.get(alias_chunk_id).text;
			int previous_chunk_id=-1;
			if (alias_chunk_id>0) 
				previous_chunk_id=getLastChunkId(chunkArr, 0,alias_chunk_id, true, false, false, null);
			
			
			if (previous_chunk_id>-1) 
					alias_test_str=chunkArr.get(previous_chunk_id).text.substring(chunkArr.get(previous_chunk_id).text.length()-1)+alias_test_str;
			
			
			
			ArrayList<msSqlSTMTExpr> exprList=getExpressionList(alias_test_str, null, ddmClient);
			
			for (int i=0;i<exprList.size();i++) {
				if (exprList.get(i).isOperator) {
					alias_chunk_id=-1;
					break;
				}
			}
			
			if (alias_chunk_id>-1) {
				for (int i=alias_chunk_id+1;i<chunkArr.size();i++) {
					if (chunkArr.get(i).isBlock || chunkArr.get(i).isOperator) {
						alias_chunk_id=-1;
						break;
					}
				}
			}
				
			
		}
		
		
		
		
		
		
		if (alias_chunk_id==-1) {
			selection.append(sbText.toString().trim());
			return;
		}
		
		
		ddmChunk chunkFoAlias=chunkArr.get(alias_chunk_id);
		
		selection.append(sbText.toString().substring(0,chunkFoAlias.startPosInText).trim());
		
		
		alias.append(chunkFoAlias.text.trim());


	}
	
	//-----------------------------------------------------------------------------------------------------
	static void extractWithAliasAndStatement(String text, StringBuilder statement, StringBuilder alias) {
		
		ArrayList<ddmChunk> chunkArr=getChunks(text, invisibleChars, true);
		if (chunkArr.size()<3) return;
		
		int pos_as=getNextChunkId(chunkArr, 0, chunkArr.size(), true, false, false, false, KEYWORD_AS);
		
		if (pos_as!=1) return;
		ddmChunk aliasChunk=chunkArr.get(pos_as-1);
		ddmChunk stmtChunk=chunkArr.get(pos_as+1);
		
		alias.setLength(0);
		alias.append(aliasChunk.text.trim());
		
		statement.setLength(0);
		statement.append(stmtChunk.text.trim());

		}


	//-----------------------------------------------------------
	static void clearUnnecesaryParantesis(StringBuilder text) {
	
		
		
		while(true) {
			ArrayList<ddmChunk> chunkArr=getChunks(text.toString(), invisibleChars, false);
			
			if (chunkArr.size()>1 || chunkArr.size()==0|| !chunkArr.get(0).isBlock) return;
			
			
			
			int pos_parantesis_open=text.toString().indexOf(msSqlParser.parantesisOpening);
			if (pos_parantesis_open==-1) break;
			
			int last_index_of_text=text.length();
			int pos_parantesis_close=getClosingParantesisPos(text.toString(), pos_parantesis_open+1, last_index_of_text);
			
			if (pos_parantesis_close==-1) break;
			
			//text.delete(pos_parantesis_close, last_index_of_text);
			//text.delete(pos_parantesis_open, pos_parantesis_open+1);
			

			
			text.setCharAt(pos_parantesis_open, ' ');
			text.setCharAt(pos_parantesis_close, ' ');
			
			
			
		}
		


		

	}
	
	//------------------------------------------------------------
	static final String object_finder_sql=""+
	"select table_name object_name, table_type object_type, table_catalog catalog, table_schema owner, table_name object_name "+
		" from INFORMATION_SCHEMA.TABLES "+
		" where upper(table_catalog)=upper(?) and upper(table_schema)=upper(?) and upper(table_name)=upper(?)";
	/*
			" select object_name, object_type, object_name, owner from dba_objects where upper(object_name)=upper(?) and owner=upper(?) and object_type in ('TABLE','VIEW','MATERIALIZED VIEW') \n"+
			" union all \n"+
			" select synonym_name, 'SYNONYM', table_name, table_owner from dba_synonyms where upper(synonym_name)=upper(?) and owner=upper(?) \n"+
			" union all \n"+
			" select synonym_name, 'SYNONYM', table_name, table_owner from dba_synonyms where upper(synonym_name)=upper(?) and owner='PUBLIC' ";
	*/
			
	static final String object_columns_sql="select column_name from INFORMATION_SCHEMA.columns where table_catalog=? and table_schema=? and table_name=? order by ordinal_position";
	
	
	static boolean  discoverObjectFromDb(
			String object_catalog,
			String object_schema, 
			String object_name, 
			ddmClient ddmClient, 
			StringBuilder extractedCatalog, 
			StringBuilder extractedSchema, 
			StringBuilder extractedObject,
			ArrayList<String[]> columns
			) {
		
		if (ddmClient.dm.is_debug || ddmClient.is_tracing) {
			ddmClient.mydebug("discoverObjectFromDb object_catalog   :"+object_catalog);
			ddmClient.mydebug("discoverObjectFromDb object_schema    :"+object_schema);
			ddmClient.mydebug("discoverObjectFromDb object_name      :"+object_name);
		}
		
		

		String hm_key_catalog="CATALOG_"+object_catalog.toUpperCase()+"."+object_schema.toUpperCase()+"."+object_name.toUpperCase()+"_FOR_"+ddmClient.CURRENT_CATALOG+"_"+ddmClient.CURRENT_SCHEMA;
		String hm_key_schema="SCHEMA_"+object_catalog.toUpperCase()+"."+object_schema.toUpperCase()+"."+object_name.toUpperCase()+"_FOR_"+ddmClient.CURRENT_CATALOG+"_"+ddmClient.CURRENT_SCHEMA;
		String hm_key_object="OBJECT_"+object_catalog.toUpperCase()+"."+object_schema.toUpperCase()+"."+object_name.toUpperCase()+"_FOR_"+ddmClient.CURRENT_CATALOG+"_"+ddmClient.CURRENT_SCHEMA;
		
		String hm_key_column="COLUMNS_"+object_catalog.toUpperCase()+"."+object_schema.toUpperCase()+"."+object_name.toUpperCase();

		if (ddmClient.dm.hmCache.containsKey(hm_key_catalog)) {
			
						
			extractedCatalog.setLength(0);
			extractedCatalog.append((String) ddmClient.dm.hmCache.get(hm_key_catalog));
			
			extractedSchema.setLength(0);
			extractedSchema.append((String) ddmClient.dm.hmCache.get(hm_key_schema));
			
			extractedObject.setLength(0);
			extractedObject.append((String) ddmClient.dm.hmCache.get(hm_key_object));
			
		
			columns.clear();
			columns.addAll((ArrayList<String[]>) ddmClient.dm.hmCache.get(hm_key_column));
			
			ddmClient.mydebug("discoverObjectFromDb : read from cache for "+hm_key_schema);
			
			return true;
		}
		
		
		if (ddmClient.connParallel==null) {
			ddmClient.mylog("Parallel connection is null!");
			return false;
		}
		
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		
		bindlist.add(new String[]{"STRING",object_catalog});
		bindlist.add(new String[]{"STRING",object_schema});
		bindlist.add(new String[]{"STRING",object_name});
		
		
		String saved_catalog=ddmClient.CURRENT_CATALOG;
		
		ddmLib.setCatalogForConnection(ddmClient.connParallel, extractedCatalog.toString());

		
		ArrayList<String[]> arr=ddmLib.getDbArray(ddmClient.connParallel, object_finder_sql, 1, bindlist, 0);
		
		
		if (arr==null || arr.size()==0) return false;
		
		extractedCatalog.setLength(0);
		extractedCatalog.append(arr.get(0)[2]);
		
		extractedSchema.setLength(0);
		extractedSchema.append(arr.get(0)[3]);
		
		extractedObject.setLength(0);
		extractedObject.append(arr.get(0)[4]);
		
		
		
		
		bindlist.clear();
		bindlist.add(new String[]{"STRING",extractedCatalog.toString()});
		bindlist.add(new String[]{"STRING",extractedSchema.toString()});
		bindlist.add(new String[]{"STRING",extractedObject.toString()});
		
		
		columns.clear();
		columns.addAll(ddmLib.getDbArray(ddmClient.connParallel, object_columns_sql, Integer.MAX_VALUE, bindlist, 0));
		
		ddmClient.dm.hmCache.put(hm_key_catalog,	extractedCatalog.toString());
		ddmClient.dm.hmCache.put(hm_key_schema, 	extractedSchema.toString());
		ddmClient.dm.hmCache.put(hm_key_object, 	extractedObject.toString());
		ddmClient.dm.hmCache.put(hm_key_column, 	columns);
		
		
		ddmLib.setCatalogForConnection(ddmClient.connParallel, saved_catalog);
		
		return true;
		
	}
	
	//------------------------------------------------------------------
	static final char char_quote='"';
	static final char char_single_quote='\'';
	
	static String clearQueote(String text) {
		
		if (text.length()==0) return text;
				
		StringBuilder sb=new StringBuilder(text);
				
		if (sb.charAt(0)==char_quote) sb.delete(0, 1);
		
		if (sb.charAt(sb.length()-1)==char_quote) sb.delete(sb.length()-1,sb.length());
		
		return sb.toString();
	}
	


	
	//-----------------------------------------------------------------------------
	static final String startend_ch="\"";
	static final String start_br="[";
	static final String end_br="]";

	
	static void prepareMatchListForFromPart(
			ArrayList<String> matchList, 
			String catalog,
			String schema, 
			String object_name_or_alias, 
			ddmClient ddmClient
			) {
		
		//adding alias direct
		if (catalog==null && schema==null) {
			matchList.add(object_name_or_alias);
			return;
		}
		
		String srv=ddmClient.CURRENT_SERVER;
		String cat=catalog;
		String sch=schema;
		String obj=object_name_or_alias;
		
		ArrayList<String> varSrv=new ArrayList<String>();
		ArrayList<String> varCat=new ArrayList<String>();
		ArrayList<String> varSch=new ArrayList<String>();
		ArrayList<String> varObj=new ArrayList<String>();
		
		varSrv.add(cat);
		varSrv.add(startend_ch+ srv+ startend_ch);
		varSrv.add(start_br+ srv+ end_br);
		
		varCat.add(cat);
		varCat.add(startend_ch+ cat+ startend_ch);
		varCat.add(start_br+ cat+ end_br);
		if (cat.equalsIgnoreCase(ddmClient.CURRENT_CATALOG))  varCat.add("");
		
		varSch.add(sch);
		varSch.add(startend_ch+ sch+ startend_ch);
		varSch.add(start_br+ sch+ end_br);
		if (sch.equalsIgnoreCase(ddmClient.CURRENT_SCHEMA))  varSch.add("");
		
		varObj.add(obj);
		varObj.add(startend_ch+ obj+ startend_ch);
		varObj.add(start_br+ obj+ end_br);
		
		
		if (srv.equals(ddmClient.CURRENT_SERVER) && cat.equals(ddmClient.CURRENT_CATALOG) && sch.equals(ddmClient.CURRENT_SCHEMA))
			for (int o=0;o<varObj.size();o++) 				
				matchList.add(varObj.get(o));
		
		if (srv.equals(ddmClient.CURRENT_SERVER) && cat.equals(ddmClient.CURRENT_CATALOG))
			for (int sc=0;sc<varSch.size();sc++)
				for (int o=0;o<varObj.size();o++) 				
					matchList.add(varSch.get(sc)+"."+varObj.get(o));
		
		if (srv.equals(ddmClient.CURRENT_SERVER))
			for (int c=0;c<varCat.size();c++)
				for (int sc=0;sc<varSch.size();sc++)
					for (int o=0;o<varObj.size();o++) 					
						matchList.add(varCat.get(c)+"."+varSch.get(sc)+"."+varObj.get(o));
		
		for (int s=0;s<varSrv.size();s++)
			for (int c=0;c<varCat.size();c++)
				for (int sc=0;sc<varSch.size();sc++)
					for (int o=0;o<varObj.size();o++) 				
						matchList.add(varSrv.get(s)+"."+varCat.get(c)+"."+varSch.get(sc)+"."+varObj.get(o));
		

		//for (int v=0;v<matchList.size();v++) System.out.println("["+v+"] \t:"+matchList.get(v));

	}
	

	


	
	
	//------------------------------------------------------------------------------------
	static void expandStatement(
			msSqlSTMT stmt,
			ddmClient ddmClient) {
				
		if (stmt.isExpanded) {
			ddmClient.mydebug("Already Expanded : "+stmt.query);
			return;
		}


		ddmClient.mydebug("expandStatement "+stmt.statement_id);
		
		
		if (stmt.isSubStatement) {
			
			for (int f=0;f<stmt.fromList.size();f++) {
				msSqlSTMTFrom from=stmt.fromList.get(f);
				if (from.isSubQuery) 
					msSqlParser.expandStatement(from.stmtForThisFrom, ddmClient);
			}
			
			expandSubStatement(stmt, ddmClient);
			extractSelectExpressions(stmt,ddmClient);
			
			
			
		} 
		else {
			
			for (int s=0;s<stmt.subStatements.size();s++) {
				msSqlSTMT subStmt=stmt.subStatements.get(s);
				
				
				
				for (int f=0;f<subStmt.fromList.size();f++) {
					msSqlSTMTFrom from=subStmt.fromList.get(f);
					if (from.isSubQuery) 
						msSqlParser.expandStatement(from.stmtForThisFrom, ddmClient);
				}
				
				expandSubStatement(subStmt, ddmClient);
				extractSelectExpressions(subStmt,ddmClient);
				
				
			}
		}
		
		
		stmt.isExpanded=true;
		
		

		
	}
		

	//------------------------------------------------------------------------------------
	static void expandSubStatement(
			msSqlSTMT stmt,
			ddmClient ddmClient) {
				
		if (stmt.isExpanded) {
			ddmClient.mydebug("Already Expanded : "+stmt.query);
			return;
		}

		ddmClient.mydebug("expandSUBBStatement "+stmt.statement_id);

		ArrayList<msSqlSTMTSelect> ret1=new ArrayList<msSqlSTMTSelect>();
		
	
			
		
		for (int s=0;s<stmt.selectList.size();s++) {

			msSqlSTMTSelect aSelect=stmt.selectList.get(s);
			
			ddmClient.mydebug("expandStatement for select : "+aSelect.text);
			
			ArrayList<ddmChunk> tmpcommentChunkArr=new ArrayList<ddmChunk>();  
			ArrayList<ddmChunk> tmpselectClausesChunkArr=new ArrayList<ddmChunk>();
			
			tmpcommentChunkArr.addAll(aSelect.commentChunkArr);
			tmpselectClausesChunkArr.addAll(aSelect.selectClausesChunkArr);
			
			ArrayList<msSqlSTMTSelect> expArr=expandSelect(stmt,aSelect,ddmClient);

			//commentleri ilk selecte set ediyoruz
			expArr.get(0).commentChunkArr.clear();
			expArr.get(0).commentChunkArr.addAll(tmpcommentChunkArr);
			
			//select clause leri ilk selecte set ediyoruz.
			expArr.get(0).selectClausesChunkArr.clear();
			expArr.get(0).selectClausesChunkArr.addAll(tmpselectClausesChunkArr);
			
			ret1.addAll(expArr);
		} 
		
		stmt.selectList.clear();
		stmt.selectList.addAll(ret1);
		
		stmt.isExpanded=true;
		
		

		
	}
	//------------------------------------------------------------------------------------
	static ArrayList<msSqlSTMTSelect> expandSelect(
			msSqlSTMT stmt, 
			msSqlSTMTSelect select,
			ddmClient ddmClient
			) {
		
		
		ArrayList<msSqlSTMTSelect> ret1=new ArrayList<msSqlSTMTSelect>();
		
		if (!select.text.contains("*")) {
			if (select.alias.length()==0) select.alias=generateAliasFromSelect(select, select.text, stmt);
			ret1.add(select);
			return ret1;
		}

		
		String merged=msSqlParser.mergeDotsBetweenNames(select.text);
		
		StringBuilder colSource=new StringBuilder();
		StringBuilder colName=new StringBuilder();
		
		msSqlParser.splitSourceAndColName(merged,colSource,colName);
		
		if (!colName.toString().equals("*")) {
			if (select.alias.length()==0) select.alias=generateAliasFromSelect(select, select.text, stmt);
			ret1.add(select);
			return ret1;
		}
				
		for (int f=0;f<stmt.fromList.size();f++) {
			
			msSqlSTMTFrom from=stmt.fromList.get(f);
			
			boolean is_related=msSqlParser.checkSelectFormRelation(select, from, ddmClient);
			
			if (!is_related) continue;
			
			if (from.isSubQuery) {
				
				String from_alias=from.alias;


				msSqlSTMT stmtSource=from.stmtForThisFrom.subStatements.get(0);
								
				for (int c=0;c<stmtSource.selectList.size();c++) { 
					msSqlSTMTSelect selectNew=new msSqlSTMTSelect();
					
					if (stmtSource.selectList.get(c).alias.length()>0) 
						selectNew.text=stmtSource.selectList.get(c).alias;
					else
						selectNew.text=stmtSource.selectList.get(c).selection;
					
					msSqlParser.splitSourceAndColName(selectNew.text,colSource,colName);
					
					selectNew.selection=colName.toString();
					selectNew.base_alias=from_alias;
					
					if (selectNew.base_alias.length()>0)  selectNew.selection=selectNew.base_alias+"."+selectNew.selection;
					
					selectNew.alias=msSqlParser.generateAliasFromSelect(selectNew, selectNew.selection, stmt);
					
					ddmClient.mydebug("\tAdding from subquery : "+selectNew.selection);
					ret1.add(selectNew);
				}
			
			} else {

				ddmClient.mydebug("extract from table/view. columns size : "+from.columns.size());
				
				for (int c=0;c<from.columns.size();c++) {
					String[] col=from.columns.get(c);
					
					msSqlSTMTSelect selectNew=new msSqlSTMTSelect();
					selectNew.text="\""+col[0]+"\"";
					
					selectNew.selection=selectNew.text;
					
					selectNew.alias=selectNew.selection;

					if (from.alias.length()>0) 
						selectNew.base_alias=from.alias;
					else 
						if (!from.isSubQuery) 
							selectNew.base_alias=from.from_part;
						
					if (selectNew.base_alias.length()>0)  
						selectNew.selection=selectNew.base_alias+"."+selectNew.selection;
					
					selectNew.alias=msSqlParser.generateAliasFromSelect(selectNew, selectNew.selection, stmt);
					
					ddmClient.mydebug("\tAdding from column : "+selectNew.selection);
					ret1.add(selectNew);
				}
				
				
				
			}
			
			

		}
		
		if (ret1.size()==0) ret1.add(select);

		return ret1;
		
		
		
	}
	//--------------------------------------------------------------------
	static void getSelectionListRecursively(
			msSqlSTMTSelect select,
			msSqlSTMTFrom from, 
			ArrayList<msSqlSTMTSelect> selections,
			ddmClient ddmClient
			) {
				
			if (from.isSubQuery) {
				
				
				msSqlSTMT subStmt=from.stmtForThisFrom.subStatements.get(0);
				
				ddmClient.mydebug("expandStatement for "+subStmt.query);
				
				expandStatement(subStmt, ddmClient);
				


				for (int n=0;n<subStmt.selectList.size();n++) {
					msSqlSTMTSelect aSel= subStmt.selectList.get(n);
									
					aSel.base_alias=from.alias;
				    subStmt.selectList.set(n, aSel);
				}
				
				if (subStmt.selectList.size()>0)
					selections.addAll(subStmt.selectList);
				
			} else {
			
				for (int c=0;c<from.columns.size();c++) {
					String[] col=from.columns.get(c);
					
					msSqlSTMTSelect selectNew=new msSqlSTMTSelect();
					selectNew.text=col[0];
					if (col[0].contains(" ")) selectNew.text="\""+col[0]+"\"";
					selectNew.selection=selectNew.text;
					selectNew.alias=selectNew.text;
					selectNew.base_alias=from.alias;
					selections.add(selectNew);
				}
			
		}

		
		
	}
		
	

	
	
	


	//----------------------------------------------------------------
	static ArrayList<ddmChunk>  extractCommentChunks(ArrayList<ddmChunk> chunkArr) {
		ArrayList<ddmChunk> ret1=new ArrayList<ddmChunk>();
		
		for (int c=0;c<chunkArr.size();c++) {
			ddmChunk chunk=chunkArr.get(c);
			if (chunk.isLineComment || chunk.isMultiLineComment) 
				ret1.add(chunk);
			
		}
		return ret1;
	}
	
	//----------------------------------------------------------------
	static String clearComments(String text, ArrayList<ddmChunk> commentArrReturn) {
		ArrayList<ddmChunk> tmpchunks=msSqlParser.getChunks(text, msSqlParser.invisibleChars, false);
		ArrayList<ddmChunk> commentArr=new ArrayList<ddmChunk>();
		
		
		commentArr.addAll(msSqlParser.extractCommentChunks(tmpchunks));
		
		if (commentArrReturn!=null) commentArrReturn.addAll(commentArr);
			
		if (commentArr.size()==0) return text;
		
		StringBuilder sb=new StringBuilder(text);
		
		for (int i=commentArr.size()-1;i>=0;i--) {
			int pos=commentArr.get(i).startPosInText;
			int len=commentArr.get(i).text.length();
			sb.delete(pos, pos+len);
		}
		
		return sb.toString();
		
	}
	
	
	
	//----------------------------------------------------------------
	static final String[] selectClauseList=new String[]{"distinct","all","top","percent","with","ties"};
	
	static ArrayList<ddmChunk>  extractSelectClauseChunks(ArrayList<ddmChunk> chunkArr) {
		ArrayList<ddmChunk> ret1=new ArrayList<ddmChunk>();
		
		for (int c=0;c<chunkArr.size();c++) {
			ddmChunk chunk=chunkArr.get(c);
			
			if (!chunk.isSingleWord)  
				continue;
			
			
			for (int i=0;i<selectClauseList.length;i++)
				if (selectClauseList[i].equalsIgnoreCase(chunk.text)) {
					ret1.add(chunk);
					//top dan sonraki ifade direk alinir.
					if (selectClauseList[i].equals("top"))
						for (int t=c+1;t<chunkArr.size();t++) {
							// ilk bulunan blok ya da single wordu ekle ve bitir.
							//top 11 ve top(11) seklinde iki sekilde de yazilabiliyor
							if (chunkArr.get(c).isBlock || chunkArr.get(c).isSingleWord) {
								ret1.add(chunkArr.get(t));
								c=t;
								break;
							} else 
								ret1.add(chunkArr.get(t));
						}
					
					break;
				}
			
		}
		return ret1;
	}
	//----------------------------------------------------------------
	static String clearSelectClauses(String text, ArrayList<ddmChunk> selectClauseArrReturn) {
		ArrayList<ddmChunk> tmpchunks=msSqlParser.getChunks(text, msSqlParser.invisibleChars, false);
		ArrayList<ddmChunk> selectClauseArr=new ArrayList<ddmChunk>();
		
		selectClauseArr.addAll(msSqlParser.extractSelectClauseChunks(tmpchunks));
		
		if (selectClauseArrReturn!=null) selectClauseArrReturn.addAll(selectClauseArr);
			
		if (selectClauseArr.size()==0) return text;
		
		StringBuilder sb=new StringBuilder(text);
		
		for (int i=selectClauseArr.size()-1;i>=0;i--) {
			int pos=selectClauseArr.get(i).startPosInText;
			int len=selectClauseArr.get(i).text.length();

			sb.delete(pos, pos+len);
		}
		
		return sb.toString();
		
	}
	
	
	
	//-------------------------------------------------------
	static void splitSourceAndColName(String text, StringBuilder colSourceAlias,StringBuilder colName ) {
		
		
		colSourceAlias.setLength(0);
		colName.setLength(0);
		
		String[] arr=text.trim().split("\\.");
		
		if (arr.length==1) {
			colName.append(arr[0]);
		} else if (arr.length==2) {
			colSourceAlias.append(arr[0]);
			colName.append(arr[1]);
		} else if (arr.length>=2) {
			colSourceAlias.append(arr[arr.length-3]+"."+arr[arr.length-2]);
			colName.append(arr[arr.length-1]);
		}
		
		if (colName.length()==0) colName.append("${!EMPTYCOLNAME}");
		
	}
	
	//---------------------------------------------------------------
	static String clearQueteFromSchemaObject(String text) {
		String[] arr=text.split("\\.");
		StringBuilder sb=new StringBuilder();
		for (int i=0;i<arr.length;i++) {
			if (sb.length()>0) sb.append(".");
			sb.append(clearQueote(arr[i]));
		}
		return sb.toString();
	}
	
	//---------------------------------------------------------------
	static boolean schemaObjectMatcher(String text1, String text2) {

		if (text1.indexOf(quoteChar)==-1 && text2.indexOf(quoteChar)==-1) return text1.equalsIgnoreCase(text2);
		
		String cleared_text1=clearQueteFromSchemaObject(text1);
		String cleared_text2=clearQueteFromSchemaObject(text2);
		
		return cleared_text1.equals(cleared_text2);
		
	}
	
	//-------------------------------------------------------
	static void mergeDottedChunks(ArrayList<ddmChunk> chunkArr) {
		ArrayList<Integer> mergeArr=new ArrayList<Integer>();
		
		boolean to_merge=false;
		
		for (int i=0;i<chunkArr.size()-1;i++) {
			String text=chunkArr.get(i).text;
			String next_text=chunkArr.get(i+1).text;
			
			if (text.length()==0 || next_text.length()==0) continue;
						
			if (	text.equals(".") 
					|| text.charAt(text.length()-1)=='.' 
					|| next_text.charAt(0)=='.'
					) to_merge=true;
			else to_merge=false;
			
			if (to_merge) mergeArr.add(i);
		}
				
		for (int i=mergeArr.size()-1;i>=0;i--) {
			int merge_id=mergeArr.get(i);
			chunkArr.get(merge_id).text=chunkArr.get(merge_id).text+chunkArr.get(merge_id+1).text;
			chunkArr.remove(merge_id+1);
		}
		
	}
	
	
	//------------------------------------------------------------------------------------
	static boolean checkSelectFormRelation(
			msSqlSTMTSelect select,
			msSqlSTMTFrom from,
			ddmClient ddmClient
			) {
		
		String merged=msSqlParser.mergeDotsBetweenNames(select.text);
		
		ArrayList<ddmChunk> chunkArr=msSqlParser.getChunks(merged, msSqlParser.invisibleChars, true);
		
		msSqlParser.mergeDottedChunks(chunkArr);
		
		StringBuilder colSource=new StringBuilder();
		StringBuilder colName=new StringBuilder();
		
		
		
		//boolean is_related=false;
		
		for (int i=0;i<chunkArr.size();i++) {
			ddmChunk chunk=chunkArr.get(i);
			if (!chunk.isSingleWord) continue;
			
			msSqlParser.splitSourceAndColName(chunk.text,colSource,colName);
			
			if (colName.toString().equals("*") && colSource.length()==0) {
				ddmClient.mydebug("checkRelation.MATCHED : select ALL (*)");
				return true;
			}
			else if (colSource.length()>0 ) {
					for (int m=0;m<from.matchList.size();m++) {
						ddmClient.mydebug("\t\t checkRelation.matching col source "+colSource.toString()+" to "+from.matchList.get(m));

						
						if (msSqlParser.schemaObjectMatcher(from.matchList.get(m),colSource.toString())) {
							ddmClient.mydebug("\t\t checkRelation.MATCHED=>>> "+colSource.toString()+" to "+from.matchList.get(m));
							return true;
						}
					}
					
					//match etmedi ama kaynak from un bir aliasi varsa match islemine devam edilmez
					if (from.alias.length()>0) {
						ddmClient.mydebug("\t\t checkRelation.base From has a specific alias ["+from.alias+"] but not matched to ["+colSource.toString()+"]");
						return false;
					}
				} 
			else {
				
				
				if (from.isSubQuery) {
					ArrayList<msSqlSTMTSelect> selList=new ArrayList<msSqlSTMTSelect>();
							
					msSqlParser.getSelectionListRecursively(select, from, selList, ddmClient);
					
					String col_name_to_check=colName.toString();
					
					for (int s=0;s<selList.size();s++) {
						msSqlSTMTSelect sel=selList.get(s);

						if (sel.alias.length()>0 && sel.alias.equalsIgnoreCase(col_name_to_check)) {
							ddmClient.mydebug("\t\t alias MATCHED=>>> "+sel.alias+" to "+col_name_to_check);
							return true;
						} 
						else if (sel.selection.equalsIgnoreCase(col_name_to_check) || sel.selection.equalsIgnoreCase(clearQueote(col_name_to_check)) ) {
							ddmClient.mydebug("\t\t colname MATCHED=>>> "+sel.selection+" to "+col_name_to_check);
							return true;
						} 
						
					} //for (int s=0;s<selList.size();s++)
				} 
				else {
					ArrayList<String[]> cols=from.columns;
					String col_name_to_check=colName.toString();
					
					for (int c=0;c<cols.size();c++) {

						if (cols.get(c)[1].length()>0 && cols.get(c)[1].equalsIgnoreCase(col_name_to_check)) {
							ddmClient.mydebug("\t\t alias MATCHED=>>> "+cols.get(c)[1]+" to "+col_name_to_check);
							return true;
						} else if (cols.get(c)[0].equalsIgnoreCase(col_name_to_check)  || cols.get(c)[0].equalsIgnoreCase(clearQueote(col_name_to_check))) {
							ddmClient.mydebug("\t\t colname MATCHED=>>> "+cols.get(c)[0]+" to "+col_name_to_check);
							return true;
						} 
					}
				}
				
			}
			
			
			
			
			
		} //for (int i=0;i<chunkArr.size();i++)
		
		return false;
		
	}
	//---------------------------------------------------------------------
	static ArrayList<String> getColNamesFromStatement(Connection conn, String query, StringBuilder err) {
		ArrayList<String> ret1=new ArrayList<String>();
		PreparedStatement preparedStatement =null;
		
		try {

			preparedStatement = conn.prepareStatement(query);
			ResultSetMetaData rsmd= preparedStatement.getMetaData();
			
			for (int r=0;r<rsmd.getColumnCount();r++) 
				ret1.add(rsmd.getColumnName(r+1));
			
			preparedStatement.close();

		} catch(Exception e) {
			if (err!=null) {
				err.append(genLib.getStackTraceAsStringBuilder(e).toString());
			}
			
			ret1.clear();
			
		} finally {
			try {preparedStatement.close();} catch(Exception e) {}
		}
		
		return ret1;
	}

//-----------------------------------------------------------------------------
	static final String[] joinKeywords=new String[]{"JOIN","INNER","OUTER","CROSS","NATURAL","FULL","LEFT","RIGHT"};
	
	static ArrayList<ddmChunk> getChunksForFromPart(String text) {
		
		ArrayList<ddmChunk> ret1=new ArrayList<ddmChunk>();
		ArrayList<ddmChunk> chunkArr=getChunks(text, invisibleChars, false);
		
		StringBuilder sb=new StringBuilder();

		for (int i=0;i<chunkArr.size();i++) {
			ddmChunk chunk=chunkArr.get(i);
			
			if (chunk.isComma || i==chunkArr.size()-1) {
				
				if (i==chunkArr.size()-1) {
					if (sb.length()>0) sb.append(" ");
					sb.append(chunk.text);
				}
				
				ddmChunk newChunk=new ddmChunk();
				newChunk.text=sb.toString();
				newChunk.isSingleWord=true;
				ret1.add(newChunk);
											
				sb.setLength(0);
				


			}
			
			boolean is_join_keyword=msSqlParser.matchesAny(chunk.text, 0, joinKeywords)>-1;
			
			if (is_join_keyword) {
				
				if (sb.length()>0) {
					ddmChunk newChunk=new ddmChunk();
					newChunk.text=sb.toString();
					newChunk.isSingleWord=true;
					ret1.add(newChunk);
												
					sb.setLength(0);
				}
				
				//skip all join keywords and comments
				while(true)	{
					if (i==chunkArr.size()) break;
					chunk=chunkArr.get(i);
					is_join_keyword=msSqlParser.matchesAny(chunk.text, 0, joinKeywords)>-1;
					if (is_join_keyword || chunk.isLineComment || chunk.isMultiLineComment) {
						if (sb.length()>0) sb.append(" ");
						sb.append(chunk.text);
					} else break;
					i++;
					
				}

			}
			
			
			
			if(!chunk.isComma) {
				if (sb.length()>0) sb.append(" ");
				sb.append(chunk.text);
			}
			
		}
		
		

		return ret1;
	}

	//------------------------------------------------------------------------------
	static String extractOnlySelectPart(String query) {
		StringBuilder ret1=new StringBuilder(query);
		
		
		
		clearUnnecesaryParantesis(ret1);
		
		ArrayList<ddmChunk> chunkArr=getChunks(ret1.toString(), invisibleChars, false);
		
		int pos_sel=getNextChunkId(chunkArr, 0, chunkArr.size(), true, false, false, false, KEYWORD_SELECT);
		
		if (pos_sel==-1) return query;
		
		int pos_with=getNextChunkId(chunkArr, 0, pos_sel, true, false, false, false ,KEYWORD_WITH);
		
		
		
		//create or replace view emp_check_opt as select * from hr.employees with check option
		int pos_end=getNextChunkId(chunkArr, pos_sel, chunkArr.size(), true, false, false, false, KEYWORD_WITH);
		if (pos_end==-1) pos_end=getNextChunkId(chunkArr, pos_sel, chunkArr.size(), true, false, false, false,  KEYWORD_FOR);
		
		int substr_end_i=ret1.length();
		if (pos_end!=-1) substr_end_i=chunkArr.get(pos_end).startPosInText;
		
		String select_statement=clearIntoClause(ret1.substring(chunkArr.get(pos_sel).startPosInText, substr_end_i));
		if (pos_with>-1) {
			select_statement=clearIntoClause(ret1.substring(chunkArr.get(pos_with).startPosInText, substr_end_i));
		}
		
		
		return select_statement;
	}
	
	//------------------------------------------------------------------------------------------------------
	static String clearIntoClause(String query) {
		StringBuilder sb=new StringBuilder(query);
		
		ArrayList<ddmChunk> chunkArr=getChunks(query, invisibleChars, false);
		
		int pos_into=getNextChunkId(chunkArr, 0, chunkArr.size(), true, false, false, false, KEYWORD_INTO);
		
		if (pos_into==-1) return query;
		
		int pos_from=getNextChunkId(chunkArr, pos_into, chunkArr.size(), true, false, false, false, KEYWORD_FROM);
		
		if (pos_from<pos_into) return query;
		
		int remove_from=chunkArr.get(pos_into).startPosInText;
		int remove_to=chunkArr.get(pos_from).startPosInText;
		
		sb.delete(remove_from, remove_to);
		
		return sb.toString();
	}
	
	//--------------------------------------------------------------------------
	
	static int matchesAny(String str, int startIndex, String[] matchArr) {
		
		for (int i=0;i<matchArr.length;i++) {
					
			try {
				if (str.substring(startIndex,str.length()).equalsIgnoreCase(matchArr[i])) return i;
				
				if ( str.substring(startIndex,startIndex+matchArr[i].length()).equalsIgnoreCase(matchArr[i])	) {
					//aranan tek karakter ise kontrole gerek yok
					if (matchArr[i].length()==1) return i;
					
					char nextChar=str.charAt(startIndex+matchArr[i].length());
					
					if (nextChar==' ' || nextChar=='\n'|| nextChar=='\r'|| nextChar=='\t') return i;
				}
			} catch(Exception e) {}
			
			try {if (matchArr[i].equals("^")) return i;	} catch(Exception e) {}
			
		}

		return -1;
	}
	//--------------------------------------------------------------------------
	static final String[] operators=new String[]{"+","-","*","/","|","="};
	
	static ArrayList<ddmChunk> getChunksByCharArr(String query, String[] chrArr) {
		
		ArrayList<ddmChunk> ret1=new ArrayList<ddmChunk>();
		
		if (query==null) return ret1;
		
		int cursor=0;
		int start_pointer=0;
		int query_len=query.length();
		
		int match_ind=-1;
		
		while(true) {
			
			if (cursor<query_len-1 && query.charAt(cursor)==multilineCommentStarter[0] && query.charAt(cursor+1)==multilineCommentStarter[1]) {
				
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}
					
				
				
				int pos_multiline_comment_finish=query.indexOf(multilineCommentFinisher,cursor+2);
				if (pos_multiline_comment_finish==-1) pos_multiline_comment_finish=query_len;
				
				
				ddmChunk chunk=new ddmChunk(query.substring(cursor,pos_multiline_comment_finish+2));
				chunk.isMultiLineComment=true;
				chunk.startPosInText=cursor;
				ret1.add(chunk);
				
				
				cursor=pos_multiline_comment_finish+2;
				start_pointer=cursor;	

			}
			else if (cursor<query_len-1 && query.charAt(cursor)==lineCommentStarter[0] && query.charAt(cursor+1)==lineCommentStarter[1]) {
				
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}
				
				int pos_line_comment_finish=query.indexOf(lineCommentFinisher1,cursor+2);
				if (pos_line_comment_finish==-1) pos_line_comment_finish=query.indexOf(lineCommentFinisher2,cursor+2);
				if (pos_line_comment_finish==-1) pos_line_comment_finish=query_len;

				
				ddmChunk chunk=new ddmChunk(query.substring(cursor,pos_line_comment_finish));
				chunk.isLineComment=true;
				chunk.startPosInText=cursor;
				ret1.add(chunk);
				
				
				cursor=pos_line_comment_finish+1;
				start_pointer=cursor;

			}
			else if (query.charAt(cursor)==parantesisOpening) {
				/*
				int pos_parantesis_closing=getClosingParantesisPos(query, cursor+1, query_len);
				if (pos_parantesis_closing==-1) 
					cursor++;
				else 
					cursor=pos_parantesis_closing+1;
				 */
				
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}
				
				int pos_parantesis_closing=getClosingParantesisPos(query, cursor+1, query_len);
				
				if (pos_parantesis_closing==-1) {
					cursor++;
				}
				else {
					ddmChunk chunk=new ddmChunk(query.substring(cursor,pos_parantesis_closing+1));
					chunk.isBlock=true;
					chunk.startPosInText=cursor;
					ret1.add(chunk);
					cursor=pos_parantesis_closing+1;
					start_pointer=cursor;
				}
			}
			else if (query.charAt(cursor)==bracketOpening || query.charAt(cursor)==quoteChar || query.charAt(cursor)==singleQouteClosing ) {
				int pos_escape_char_closing=-1;
				
				if (query.charAt(cursor)==bracketOpening)
					pos_escape_char_closing=getClosingBracketPos(query, cursor+1, query_len);
				else if (query.charAt(cursor)==quoteChar)
					pos_escape_char_closing=getClosingQuotePos(query, cursor+1, query_len);
				else if (query.charAt(cursor)==singleQouteClosing)
					pos_escape_char_closing=getClosingSingleQuotePos(query, cursor+1, query_len);
				
				if (pos_escape_char_closing==-1) {
					cursor++;
				}
				else {
					cursor=pos_escape_char_closing+1;
				}
			}
			else if ((match_ind=matchesAny(query,cursor,chrArr))>-1) {
				
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}

				
				ddmChunk chunk=new ddmChunk(chrArr[match_ind]);
				chunk.isOperator=true;
				chunk.startPosInText=cursor;
				ret1.add(chunk);
				
				
				start_pointer=cursor+chunk.text.length();
				cursor+=chunk.text.length();
				
			}
			else 
				cursor++;
				
			
						
			
			if (cursor>=query_len) {
				if (start_pointer<cursor) {
					ddmChunk chunk=new ddmChunk(query.substring(start_pointer,cursor).trim());
					chunk.isSingleWord=true;
					chunk.startPosInText=start_pointer;
					ret1.add(chunk);
				}
				break;
			}
			
		}
		
		
		clearEmptyAndCommaChunks(ret1);
		
		return ret1;
	}
	
	//-------------------------------------------------------------------------------------------
	static String getSelectionFromExpression(
			msSqlSTMTSelect select,
			ArrayList<msSqlSTMTExpr> exprList,
			ddmClient ddmClient,
			//boolean put_comma,
			msSqlSTMT outerSTMT
			) {
		StringBuilder sb=new StringBuilder();
		
		
		
		
		for (int i=0;i<exprList.size();i++) {
			
			if (i>0 && !exprList.get(i-1).isOperator) {
				sb.append(" ");
			}
			msSqlSTMTExpr expr=exprList.get(i);
						
								
			if (expr.isSubQuery) {
				sb.append(msSqlParser.parantesisOpening);
				sb.append(msSqlParser.parse(expr.text, null, ddmClient).rewriteSingleSQL(ddmClient, false, true, outerSTMT));
				sb.append(msSqlParser.parantesisClosing);
				continue;
			}
			
			if (expr.isComment) {
				sb.append(expr.text);
				continue;
			}
			
			if (expr.isLiteral) {
				sb.append(expr.text);
				continue;
			}
			
			
			if (expr.isFunctionParameter) {
				
				sb.append(msSqlParser.parantesisOpening);
				sb.append(getSelectionFromExpression(select, expr.exprList, ddmClient, outerSTMT));
				sb.append(msSqlParser.parantesisClosing);
				

				continue;
			}
			
			if (expr.exprList.size()>0) 
				sb.append(getSelectionFromExpression(select, expr.exprList, ddmClient, outerSTMT));
			else {
				
				if (expr.maskingFunction.equals("NONE")) {
					sb.append(expr.text);
				} else {
					
					if (expr.maskingFunction.equals("SETNULL")) {
						sb.append("null ");
					} else if (expr.maskingFunction.startsWith("FIXED")) {
						String[] maskArr=expr.maskingFunction.split(":");
						String fixed_val="null";
						try{fixed_val=maskArr[1];} catch(Exception e) {fixed_val="null";}
						sb.append(fixed_val);
					} else if (expr.maskingFunction.startsWith("HIDE")) {
						String[] maskArr=expr.maskingFunction.split(":");
						String hide_char="*";
						String hide_after="2";
						
						try{hide_char=maskArr[1];} catch(Exception e) {hide_char="*";}
						try{hide_after=maskArr[2];} catch(Exception e) {hide_after="2";} 
						
						String masking_str=" CASE "+
								" WHEN ISNULL("+expr.text+", '${null}')='${null}' 	THEN null "+
								" WHEN Len("+expr.text+")<="+hide_after+" THEN "+expr.text+" "+
								" ELSE CONCAT(SUBSTRING("+expr.text+",1,"+hide_after+"),replicate('"+hide_char+"',Len("+expr.text+")-"+hide_after+")) "+
								" END ";
						
						sb.append(masking_str);
					} else 
						sb.append("null ");
					
				}
								
				
			}
			
			
			
		}
		
		
	
		
		return sb.toString();
	}
	
	//------------------------------------------------------------------------------------------
	static ArrayList<msSqlSTMTExpr> getExpressionList(
			String str,
			msSqlSTMTExpr parentExpr,
			ddmClient ddmClient) {
		
		ArrayList<msSqlSTMTExpr> ret1=new ArrayList<msSqlSTMTExpr>();
	
				
		
		ArrayList<ddmChunk> chunksForSelection=msSqlParser.getChunksByCharArr(str, msSqlParser.invisibleCharsArr);
		
		
		for (int s=0;s<chunksForSelection.size();s++) {
			
						
			ArrayList<ddmChunk> chunksForExpression=msSqlParser.getChunksByCharArr(chunksForSelection.get(s).text, msSqlParser.operators);
						
			for (int c=0;c<chunksForExpression.size();c++) {
				
				ddmChunk chunk=chunksForExpression.get(c);
				
				msSqlSTMTExpr expr=new msSqlSTMTExpr();
				expr.text=chunk.text;
				expr.parentExpr=parentExpr;
				expr.chunk=chunk;
				expr.compile(ddmClient);
				
				ret1.add(expr);
				
			} //for (int c=0;c<chunksForExpression.size();c++)
		}
		
		
		
		
		
		return ret1;
		
	}
	//------------------------------------------------------------------------------------------
	static void extractSelectExpressions(
			msSqlSTMT stmt,
			ddmClient ddmClient
			) {
		
		if (stmt.isExpressionExtracted) return;
		
		for (int e=0;e<stmt.selectList.size();e++)  {
			msSqlSTMTSelect select=stmt.selectList.get(e);
			select.exprList.addAll(getExpressionList(stmt.selectList.get(e).selection, null, ddmClient));
			for (int i=0;i<select.exprList.size();i++)
				if (select.exprList.get(i).text.equals("=")) {
					select.isAssigned=true;
					break;
				}
		}
			
		
		stmt.isExpressionExtracted=true;
	}
	
	
	
	//------------------------------------------------------------------------------------------
	static void discoverSourceColumns(
			msSqlSTMT stmt,
			msSqlSTMT outerSTMT,
			ddmClient ddmClient
			) {
		
		
		if (stmt.isSubStatement) {
			
			ArrayList<msSqlSTMTFrom> fromArr=new ArrayList<msSqlSTMTFrom>();
			fromArr.addAll(stmt.fromList);
			if (outerSTMT!=null) 
				fromArr.addAll(outerSTMT.fromList);
			
			for (int f=0;f<fromArr.size();f++) {
				
				if (fromArr.get(f).isSubQuery) continue;
				
				seedMsSqlSTMTFrom(fromArr.get(f),stmt, ddmClient);
			}
			
			
		} else {
			for (int i=0;i<stmt.subStatements.size();i++) {
				msSqlSTMT subSTMT=stmt.subStatements.get(i);
				
				discoverSourceColumns(subSTMT,outerSTMT,ddmClient);
				
				for (int f=0;f<subSTMT.fromList.size();f++) {
					msSqlSTMTFrom from=subSTMT.fromList.get(f);
					if (from.isSubQuery) 
						discoverSourceColumns(from.stmtForThisFrom,null,ddmClient);
				}
				
				
			}
		}
		
		
	}
	
	
	//---------------------------------------------------------------
	static void seedMsSqlSTMTFrom(msSqlSTMTFrom from, msSqlSTMT stmtTarget, ddmClient ddmClient) {
		
		copyColumnSources(from, stmtTarget, ddmClient);
		
		seedMsSqlSTMT(stmtTarget,ddmClient);
	}

	//----------------------------------------------------------------
	static msSqlSTMT getParentStatement(msSqlSTMT stmt) {
		msSqlSTMT ret1=stmt.parentStmt;
		if (ret1==null) return ret1;
		if (!ret1.isSubStatement) return getParentStatement(ret1);
		return ret1;
	}
	//----------------------------------------------------------------
	static void seedMsSqlSTMT(msSqlSTMT stmt, ddmClient ddmClient) {
		
		msSqlSTMT parentSTMT=getParentStatement(stmt);
		
		
		if (parentSTMT==null) {
			ddmClient.mydebug("!!!!!! parentSTMT is null : "+stmt.statement_id);
			return;
		}
		
		
		ddmClient.mydebug("seedOracleSTMT  : "+stmt.statement_id+" => "+parentSTMT.statement_id);
		
		ArrayList<msSqlSTMTSelect> selectArr=stmt.selectList;
		ArrayList<msSqlSTMTSelect> parentSelectArr=parentSTMT.selectList;
		
		msSqlSTMTFrom from=stmt.parentStmt.fromBased;
		
		for (int s=0;s<selectArr.size();s++) {
			msSqlSTMTSelect select=selectArr.get(s);
			
			for (int p=0;p<parentSelectArr.size();p++) {
				msSqlSTMTSelect parentSelect=parentSelectArr.get(p);
				
				for (int e=0;e<parentSelect.exprList.size();e++) {
					msSqlSTMTExpr expr=parentSelect.exprList.get(e);
					
					if (expr.isFunctionParameter) {
						for (int px=0;px<expr.exprList.size();px++) {
							msSqlSTMTExpr exprParam=expr.exprList.get(px);
							
							if (!matchSelectExpression(select, exprParam, from, ddmClient)) continue;
							
							for (int m=0;m<select.exprList.size();m++) {
								exprParam.baseColumns.addAll(select.exprList.get(m).baseColumns);
								expr.baseColumns.addAll(select.exprList.get(m).baseColumns);
							}
						} //if (expr.isFunction)
					} else {
						

						
						if (!matchSelectExpression(select, expr, from, ddmClient)) continue;
						


						for (int m=0;m<select.exprList.size();m++) 							
							expr.baseColumns.addAll(select.exprList.get(m).baseColumns);
					}
					
				}
				
				
			}
			
			
			
		}
		
		
		seedMsSqlSTMT(parentSTMT,  ddmClient);
		
	}

	
	//-------------------------------------------------------------------------------------------
	static boolean matchSelectExpression(msSqlSTMTSelect select, msSqlSTMTExpr expr, msSqlSTMTFrom from, ddmClient ddmClient) {
		
		ArrayList<String> checkList=new ArrayList<String>();
				
		String expr_cleared=expr.text.replaceAll("\"", "").trim();
		String select_alias_cleared=select.alias.replaceAll("\"", "").trim();
		String select_selection_cleared=select.selection.replaceAll("\"", "").trim();


		
		String from_alias_cleared="";	
		if (from!=null)		
			from_alias_cleared=from.alias.replaceAll("\"", "").trim();
		
		if (select_alias_cleared.length()>0) {
			checkList.add(select_alias_cleared);
			if (from_alias_cleared.length()>0) checkList.add(from_alias_cleared+"."+select_alias_cleared);
		}
		else {
			checkList.add(select_selection_cleared);
			if (from_alias_cleared.length()>0)  checkList.add(from_alias_cleared+"."+select_selection_cleared);
		}
			

		for (int i=0;i<checkList.size();i++) {
			//System.out.println("\t\t Check "+checkList.get(i)+" with "+expr_cleared);
			if (expr_cleared.equalsIgnoreCase(checkList.get(i)))  {
				//System.out.println(":))))))))))))");
				return true;
			}
		}




		return false;
	}
	
	


	
	//-------------------------------------------------------------------------------------------
	static void copyColumnSources(
			msSqlSTMTFrom from,
			msSqlSTMT stmt,
			ddmClient ddmClient
			) {
		


		
		for (int s=0;s<stmt.selectList.size();s++) {
			
			msSqlSTMTSelect select=stmt.selectList.get(s);
			
			for (int e=0;e<select.exprList.size();e++) 
				copyColumnSourcesToExpressions(from, select.exprList.get(e), ddmClient);
		
				
			
			
		} //for (int s=0;s<stmt.selectList.size();s++)
		
		
	}
	//-------------------------------------------------------------------------------------------
	static void copyColumnSourcesToExpressions(
			msSqlSTMTFrom from,
			msSqlSTMTExpr expr,
			ddmClient ddmClient
			) {
			
		

		
		if (expr.isFunctionParameter) {
			for (int p=0;p<expr.exprList.size();p++) {
				msSqlSTMTExpr exprParam=expr.exprList.get(p);
				
				copyColumnSourcesToExpressions(from,exprParam,ddmClient);
				
			}
		}
		else {
			if (expr.exprList.size()>0) {
				for (int p=0;p<expr.exprList.size();p++) {
					msSqlSTMTExpr subExpr=expr.exprList.get(p);
					copyColumnSourcesToExpressions(from,subExpr,ddmClient);
				}
			}
			else {
				
				for (int c=0;c<from.columns.size();c++) {
					
					String matchText=from.columns.get(c)[0];
					
					
					
					if (!matchColExpr(matchText,expr.text, from)) continue;
					
					
					msSqlSTMTColumn column=new msSqlSTMTColumn();
					
					column.catalog_name=from.object_catalog;
					column.schema_name=from.object_owner;
					column.object_name=from.object_name;
					column.column_name=matchText;
					column.compile(ddmClient);
					
					expr.baseColumns.add(column);
					
					if (expr.parentExpr!=null && expr.parentExpr.isFunctionParameter) 
						expr.parentExpr.baseColumns.add(column);

											
				} //for (int c=0;c<from.columns.size();c++)
				
			}

			
		}

	}
	
	//-------------------------------------------------------------------------------------------
	static synchronized long generateStatementId() {
		try{Thread.sleep(1);} catch (Exception e) {}
		return System.currentTimeMillis();
	}
	



	//-------------------------------------------------------------------------------------------
	static boolean matchColExpr(String colname, String expr, msSqlSTMTFrom from) {
		
		String expr_cleared=expr.replaceAll("\"", "").trim();
		String alias_cleared=from.alias.replaceAll("\"", "").trim(); 
		String col_name_cleared=colname.replaceAll("\"", "").trim();
		String from_part=from.from_part.replaceAll("\"", "").trim();
		
		ArrayList<String> checkList=new ArrayList<String>();
		
		if (alias_cleared.length()==0 && !from.isSubQuery) {
			
			String from_catalog=clearQueote(from.object_catalog);
			String from_owner=clearQueote(from.object_owner);
			String from_object=clearQueote(from.object_name);
			
			checkList.add(from_object+"."+col_name_cleared);
			checkList.add(from_owner+"."+from_object+"."+col_name_cleared);
			checkList.add(from_catalog+"."+from_object+"."+col_name_cleared);
			checkList.add(from_catalog+".."+col_name_cleared);
			
			checkList.add(from_part+"."+col_name_cleared);

			
		} else {
			checkList.add(alias_cleared+"."+col_name_cleared);
		}
		
		checkList.add(col_name_cleared);
		
		
		/*
		if (expr_cleared.contains(".")) {
			checkList.add(from.object_name+"."+col_name_cleared);
			checkList.add(from.schema_name+"."+from.object_name+"."+col_name_cleared);
		}
		*/
		
		
		for (int i=0;i<checkList.size();i++) {
			
			if (expr_cleared.equalsIgnoreCase(checkList.get(i)))  {
				return true;
			}
		}
			
		


		return false;
	}
	
	//-------------------------------------------------------------------------------------------
	static void setMaskingConfigurationForSelect(
			msSqlSTMTSelect select,
			msSqlSTMT stmt,
			ddmClient ddmClient
			) {
		
		
		
		
		for (int e=0;e<select.exprList.size();e++) {
			msSqlSTMTExpr expr=select.exprList.get(e);
			
			if (expr.isFunctionParameter) {
				for (int p=0;p<expr.exprList.size();p++) 
					setMaskingConfigurationForExpression(select, expr.exprList.get(p), ddmClient);
				continue;
			}
			else if (expr.isSubQuery) {
				continue;
			}
			
			
			setMaskingConfigurationForExpression(select, expr, ddmClient);
			
		}


	}
	//-----------------------------------------------------------
	static boolean checkColumnException(msSqlSTMTColumn column, ddmClient ddmClient) {

		
		
		for (int p=0;p<ddmClient.policyGroups.size();p++) {
			int policy_group_id=ddmClient.policyGroups.get(p);
			
			
			if (ddmClient.dm.hmConfig.containsKey("TABLE_EXCEPTION_"+column.schema_name+"."+column.object_name+"_FOR_PLC_"+policy_group_id)) {
				return true;
			} 
			

			if (ddmClient.dm.hmConfig.containsKey("COLUMN_EXCEPTION_"+column.col_path+"_FOR_PLC_"+policy_group_id)) {
				return true;
			}
			
		}
		
		
		return false;
	}
	
	//-----------------------------------------------------------
	static void clearDuplicatedOrExceptionalBaseColumns(
			msSqlSTMTExpr expr,
			ddmClient ddmClient
			) {
		boolean is_duplicated=false;
		
		ArrayList<Integer> removeList=new ArrayList<Integer>();
		
		for (int i=0;i<expr.baseColumns.size();i++) 
			if (expr.baseColumns.get(i).is_exception) 
				removeList.add(i);
		
		
		for (int i=removeList.size()-1;i>=0;i--) expr.baseColumns.remove(i);
		
		removeList.clear();
		
		for (int i=0;i<expr.baseColumns.size()-1;i++) {
			
			for (int j=i+1;j<expr.baseColumns.size();j++) {
				if (expr.baseColumns.get(i).col_path.equals(expr.baseColumns.get(j).col_path)) {
					is_duplicated=true;
					break;
				}
			}
			
			if (is_duplicated) {
				removeList.add(i);
				is_duplicated=false;
			}
		}
		
		for (int i=removeList.size()-1;i>=0;i--) expr.baseColumns.remove(i);
		
	}
	//-------------------------------------------------------------------------------------------
	static void setMaskingConfigurationForExpression(
			msSqlSTMTSelect select,
			msSqlSTMTExpr expr,
			ddmClient ddmClient
			) {
		
		ddmClient.mydebug("setMaskingConfigurationForExpression "+expr.text);
		
		if (expr.exprList.size()>0) {
			for (int i=0;i<expr.exprList.size();i++) 
				setMaskingConfigurationForExpression(select, expr.exprList.get(i), ddmClient);
			return;
		}
		


		clearDuplicatedOrExceptionalBaseColumns(expr, ddmClient);
		
		if (expr.baseColumns.size()==0) return;
		
		
		for (int i=0;i<expr.baseColumns.size();i++) {
			if (!ddmClient.dm.hmConfig.containsKey("MASK_METHOD_FOR_COLUMN_"+expr.baseColumns.get(i).col_path)) continue;
			
			if (i>0 && !expr.maskingFunction.equals("NONE")) {
				expr.maskingFunction="SETNULL";
				return;
			}
			
			expr.maskingFunction=(String) ddmClient.dm.hmConfig.get("MASK_METHOD_FOR_COLUMN_"+expr.baseColumns.get(i).col_path);
			
		}
		
		
	}
	
	

	
	
	//--------------------------------------------------------
	static String generateAliasFromSelect(msSqlSTMTSelect select, String expression, msSqlSTMT stmt) {
		
		if (select.alias.length()>0) return select.alias;
		
		String[] arr=expression.split("\\.");
		
		StringBuilder sb=new StringBuilder();
		for (int i=0;i<arr.length;i++) {
			if (clearQueote(arr[i]).equalsIgnoreCase(clearQueote(select.base_alias))) continue;
			if (sb.length()>0) sb.append(".");
			sb.append(arr[i]);
		}
		
		if (sb.toString().trim().equals("*")) return "";
		
		if (sb.toString().trim().endsWith(".*")) return "";
		
		String text=sb.toString();
		
		if (text.trim().charAt(0)=='"' && text.trim().charAt(text.length()-1)=='"') return text;
		
		
		text=text.trim().replaceAll("\n|\t|\r|\"| ", "");
		
	
		if (select.selection.contains(".")) {
			
			StringBuilder colSource=new StringBuilder();
			StringBuilder colName=new StringBuilder();
			
			msSqlParser.splitSourceAndColName(select.selection,colSource,colName);

			boolean delete_base=false;
			
			for (int i=0;i<stmt.fromList.size();i++) {
				msSqlSTMTFrom from=stmt.fromList.get(i);
				if (from.alias.equalsIgnoreCase(colSource.toString().trim())) {
					delete_base=true;
					break;
				}
				
				if (from.object_name.equalsIgnoreCase(colSource.toString().replaceAll("\"", ""))) {
					delete_base=true;
					break;
				}
				 
				if ((from.object_catalog+"."+from.object_owner+"."+from.object_name).equalsIgnoreCase(colSource.toString().replaceAll("\"", ""))) {
					delete_base=true;
					break;
				}
				
			}
			
			if (delete_base) text=colName.toString();
			
		} 
		
		
		
		
		
		sb.setLength(0);
		sb.append(text.toUpperCase());
		if (sb.length()>30) sb.delete(30, sb.length());
		
		return "\""+sb.toString().toUpperCase()+"\"";
		
	}
	
	//-----------------------------------------------------------------------------
	public static String normalizeFromPart(String text) {
		
		ArrayList<ddmChunk> chunkArr=getChunks(text.toString(), invisibleChars, false);
		
		
		int block_ind=getNextChunkId(chunkArr, 0, chunkArr.size(), false, false, true, false, null);
		
	
		//nothing to normalize
		if (block_ind!=0) return text;
		
		//(select * from hr.employees) a
		//(select * from hr.employees)
		StringBuilder sbx=new StringBuilder(chunkArr.get(block_ind).text);

		if (chunkArr.size()<=2) {
			sbx.setLength(0);
			sbx.append(chunkArr.get(0).text);
			clearUnnecesaryParantesis(sbx);
			
			ArrayList<ddmChunk> tmpChunks=msSqlParser.getChunks(sbx.toString(), msSqlParser.invisibleChars, false);
			int pos_select=msSqlParser.getNextChunkId(tmpChunks, 0, tmpChunks.size(), true, false, false, false, msSqlParser.KEYWORD_SELECT);
			if (pos_select>-1) 	return text;
			
		}
		
		
			StringBuilder sb=new StringBuilder(chunkArr.get(block_ind).text);
			clearUnnecesaryParantesis(sb);
			chunkArr.get(block_ind).text=normalizeFromPart(sb.toString().trim());
			
			
			sb.setLength(0);

			for (int i=0;i<chunkArr.size();i++) {
				ddmChunk chunk=chunkArr.get(i);
				if (sb.length()>0) sb.append(" ");
				sb.append(chunk.text);
			}

			return sb.toString();
			
	}
	
	public static boolean checkKeywordArrays(String text, String[] keywordArr) {
		
		ArrayList<ddmChunk> chunkArr=getChunks(text, invisibleChars, true);
		int last_holder=0;
		int len=chunkArr.size();
		
		for (int i=0;i<keywordArr.length;i++) {
			String[] strSplited= keywordArr[i].split("\\|");
			
			int holder=0;
			
			for (int s=0;s<strSplited.length;s++) {
				holder=getNextChunkId(chunkArr, last_holder, len, true, false, false, false, strSplited[s]);
				if (holder!=-1) break;
			}
			
			if (holder==-1) return false;
			last_holder=holder;
			
		}
			
					
		
		
		return true;
	}
	
	
	
	//----------------------------------------------------------------
	
	public static final String MSSQL_PLSQL_BLOCK="MSSQL_PLSQL_BLOCK";
	public static final String MSSQL_INSERT_WITH_SELECT="MSSQL_INSERT_WITH_SELECT";
	public static final String MSSQL_INSERT="MSSQL_INSERT";
	public static final String MSSQL_UPDATE="MSSQL_UPDATE";
	public static final String MSSQL_DELETE="MSSQL_DELETE";
	public static final String MSSQL_CREATE_TABLE="MSSQL_CREATE_TABLE";
	public static final String MSSQL_CREATE_TABLE_AS="MSSQL_CREATE_TABLE_AS";
	public static final String MSSQL_ALTER_TABLE="MSSQL_ALTER_TABLE";
	public static final String MSSQL_DROP_TABLE="MSSQL_DROP_TABLE";
	public static final String MSSQL_CREATE_VIEW="MSSQL_CREATE_VIEW";
	public static final String MSSQL_ALTER_VIEW="MSSQL_ALTER_VIEW";
	public static final String MSSQL_DROP_VIEW="MSSQL_DROP_VIEW";
	public static final String MSSQL_CREATE_PROCEDURE="MSSQL_CREATE_PROCEDURE";
	public static final String MSSQL_ALTER_PROCEDURE="MSSQL_ALTER_PROCEDURE";
	public static final String MSSQL_DROP_PROCEDURE="MSSQL_DROP_PROCEDURE";
	public static final String MSSQL_CREATE_FUNCTION="MSSQL_CREATE_FUNCTION";
	public static final String MSSQL_ALTER_FUNCTION="MSSQL_ALTER_FUNCTION";
	public static final String MSSQL_DROP_FUNCTION="MSSQL_DROP_FUNCTION";
	public static final String MSSQL_CREATE_PACKAGE_BODY="MSSQL_CREATE_PACKAGE_BODY";
	public static final String MSSQL_CREATE_PACKAGE="MSSQL_CREATE_PACKAGE";
	public static final String MSSQL_ALTER_PACKAGE="MSSQL_ALTER_PACKAGE";
	public static final String MSSQL_DROP_PACKAGE="MSSQL_DROP_PACKAGE";
	public static final String MSSQL_DROP_PACKAGE_BODY="MSSQL_DROP_PACKAGE_BODY";
	public static final String MSSQL_CREATE_MATERIALIZED_VIEW="MSSQL_CREATE_MATERIALIZED_VIEW";
	public static final String MSSQL_ALTER_MATERIALIZED_VIEW="MSSQL_ALTER_MATERIALIZED_VIEW";
	public static final String MSSQL_DROP_MATERIALIZED_VIEW="MSSQL_DROP_MATERIALIZED_VIEW";
	public static final String MSSQL_SELECT="MSSQL_SELECT";
	public static final String MSSQL_CREATE_SEQUENCE="MSSQL_CREATE_SEQUENCE";
	public static final String MSSQL_ALTER_SEQUENCE="MSSQL_ALTER_SEQUENCE";
	public static final String MSSQL_DROP_SEQUENCE="MSSQL_DROP_SEQUENCE";
	public static final String MSSQL_CREATE_USER="MSSQL_CREATE_USER";
	public static final String MSSQL_ALTER_USER="MSSQL_ALTER_USER";
	public static final String MSSQL_DROP_USER="MSSQL_DROP_USER";
	public static final String MSSQL_CREATE_ROLE="MSSQL_CREATE_ROLE";
	public static final String MSSQL_ALTER_ROLE="MSSQL_ALTER_ROLE";
	public static final String MSSQL_DROP_ROLE="MSSQL_DROP_ROLE";
	public static final String MSSQL_SET_ROLE="MSSQL_SET_ROLE";
	public static final String MSSQL_CREATE_SYNONM="MSSQL_CREATE_SYNONM";
	public static final String MSSQL_ALTER_SYNONM="MSSQL_ALTER_SYNONM";
	public static final String MSSQL_DROP_SYNONM="MSSQL_DROP_SYNONM";
	public static final String MSSQL_CREATE_TABLESPACE="MSSQL_CREATE_TABLESPACE";
	public static final String MSSQL_CREATE_TEMPORARY_TABLESPACE="MSSQL_CREATE_TEMPORARY_TABLESPACE";
	public static final String MSSQL_ALTER_TABLESPACE="MSSQL_ALTER_TABLESPACE";
	public static final String MSSQL_DROP_TABLESPACE="MSSQL_DROP_TABLESPACE";
	public static final String MSSQL_CREATE_TRIGGER="MSSQL_CREATE_TRIGGER";
	public static final String MSSQL_ALTER_TRIGGER="MSSQL_ALTER_TRIGGER";
	public static final String MSSQL_DROP_TRIGGER="MSSQL_DROP_TRIGGER";
	public static final String MSSQL_ALTER_SESSION="MSSQL_ALTER_SESSION";
	public static final String MSSQL_ALTER_SESSION_SET_PARAMETER="MSSQL_ALTER_SESSION_SET_PARAMETER";
	public static final String MSSQL_CREATE_PROFILE="MSSQL_CREATE_PROFILE";
	public static final String MSSQL_ALTER_PROFILE="MSSQL_ALTER_PROFILE";
	public static final String MSSQL_DROP_PROFILE="MSSQL_DROP_PROFILE";
	public static final String MSSQL_CREATE_TYPE="MSSQL_CREATE_TYPE";
	public static final String MSSQL_CREATE_TYPE_BODY="MSSQL_CREATE_TYPE_BODY";
	public static final String MSSQL_ALTER_TYPE="MSSQL_ALTER_TYPE";
	public static final String MSSQL_DROP_TYPE="MSSQL_DROP_TYPE";
	public static final String MSSQL_COMMIT="MSSQL_COMMIT";
	public static final String MSSQL_ROLLBACK="MSSQL_ROLLBACK";
	public static final String MSSQL_SAVEPOINT="MSSQL_SAVEPOINT";
	public static final String MSSQL_COMMENT="MSSQL_COMMENT";
	public static final String MSSQL_LOCK_TABLE="MSSQL_LOCK_TABLE";
	public static final String MSSQL_CREATE_DIRECTORY="MSSQL_CREATE_DIRECTORY";
	public static final String MSSQL_DROP_DIRECTORY="MSSQL_DROP_DIRECTORY";
	public static final String MSSQL_EXECUTE_IMMEDIATE="MSSQL_EXECUTE_IMMEDIATE";
	public static final String MSSQL_EXPLAIN_PLAN="MSSQL_EXPLAIN_PLAN";
	public static final String MSSQL_GRANT="MSSQL_GRANT";
	public static final String MSSQL_REVOKE="MSSQL_REVOKE";
	public static final String MSSQL_CREATE_JAVA="MSSQL_CREATE_JAVA";
	public static final String MSSQL_ALTER_JAVA="MSSQL_ALTER_JAVA";
	public static final String MSSQL_DROP_JAVA="MSSQL_DROP_JAVA";
	public static final String MSSQL_CREATE_DATABASE_LINK="MSSQL_CREATE_DATABASE_LINK";
	public static final String MSSQL_DROP_DATABASE_LINK="MSSQL_DROP_DATABASE_LINK";

	
	static final String[] oracleStmtTypeConfigArr=new String[]{
		MSSQL_CREATE_PROCEDURE+"				=>	create procedure [?] as|is begin end|end; ",
		MSSQL_CREATE_FUNCTION+"					=>	create function [?] as|is begin end|end; ",
		MSSQL_CREATE_PACKAGE_BODY+"				=>	create package body [?] as|is begin end|end; ",
		MSSQL_CREATE_PACKAGE+"					=>	create package [?] as|is begin end|end; ",
		MSSQL_CREATE_TRIGGER+"					=>	create or|replace|^ trigger [?] before|after|instead ",
		MSSQL_CREATE_TYPE+"						=>	create type [?]  oid|as|is|under",
		MSSQL_CREATE_TYPE_BODY+"				=>	create type body [?]  oid|as|is|under",

		
		MSSQL_PLSQL_BLOCK+"						=>	declare|begin end|end;|;",			

		MSSQL_INSERT_WITH_SELECT+"				=>	insert into [?] select  from",			

		MSSQL_INSERT+"							=>	insert into [?] values {block}",			
		MSSQL_UPDATE+"							=>	update [?] set {1..} where|^",			
		MSSQL_DELETE+"							=>	delete from [?] set  where|^",			
		
		MSSQL_CREATE_TABLE+"					=>	create global|temporary|table [?] {block}",			
		MSSQL_CREATE_TABLE_AS+"					=>	create table [?] as select  from",
		MSSQL_ALTER_TABLE+"						=>	alter table [?] add|drop|attach|detach|enable|disable|modify",			
		MSSQL_DROP_TABLE+"						=>	drop table [?] cascade|restrict|^",		
		
		MSSQL_CREATE_VIEW+"						=>	create  view [?] as  select  from",
		MSSQL_ALTER_VIEW+"						=>	alter view [?] compile",
		MSSQL_DROP_VIEW+"						=>	drop view [?] cascade|restrict|^",
		
		MSSQL_ALTER_PROCEDURE+"					=>	alter procedure [?] compile ",
		MSSQL_DROP_PROCEDURE+"					=>	drop procedure [?]",

		MSSQL_ALTER_FUNCTION+"					=>	alter function [?] compile ",
		MSSQL_DROP_FUNCTION+"					=>	drop function [?]",
		
		MSSQL_ALTER_PACKAGE+"					=>	alter package [?] compile ",
		MSSQL_DROP_PACKAGE+"					=>	drop package [?]",
		MSSQL_DROP_PACKAGE_BODY+"				=>	drop package body [?]",
		
		MSSQL_CREATE_MATERIALIZED_VIEW+"		=>	create materialized view",
		MSSQL_ALTER_MATERIALIZED_VIEW+"			=>	alter materialized view",
		MSSQL_DROP_MATERIALIZED_VIEW+"			=>	drop materialized view",
		
		MSSQL_SELECT+"							=>	select from",

		MSSQL_CREATE_SEQUENCE+"					=>	create sequence [?] increment|start|maxvalue|nomaxvalue|minvalue|nominvalue|cycle|nocycle|cache|nocache|order|noorder",
		MSSQL_ALTER_SEQUENCE+"					=>	alter sequence [?] increment|start|maxvalue|nomaxvalue|minvalue|nominvalue|cycle|nocycle|cache|nocache|order|noorder",
		MSSQL_DROP_SEQUENCE+"					=>	drop sequence [?]",		
		
		MSSQL_CREATE_USER+"						=>	create user [?]",
		MSSQL_ALTER_USER+"						=>	alter user [?]",
		MSSQL_DROP_USER+"						=>	drop user [?]",

		MSSQL_CREATE_ROLE+"						=>	create role [?]",
		MSSQL_ALTER_ROLE+"						=>	alter role [?]",
		MSSQL_DROP_ROLE+"						=>	drop role [?]",
		MSSQL_SET_ROLE+"						=>	set role [?]",
		
		MSSQL_CREATE_SYNONM+"					=>	create synonym [?] for",
		MSSQL_ALTER_SYNONM+"					=>	alter synonym [?] compile|editionable|editionable|^",
		MSSQL_DROP_SYNONM+"						=>	drop synonym [?] force|^",

		MSSQL_CREATE_TABLESPACE+"				=>	create tablespace [?]",
		MSSQL_CREATE_TEMPORARY_TABLESPACE+"		=>	create temporary tablespace [?]",
		MSSQL_ALTER_TABLESPACE+"				=>	alter tablespace  [?]",
		MSSQL_DROP_TABLESPACE+"					=>	drop tablespace  [?]",
		
		MSSQL_ALTER_TRIGGER+"					=>	alter trigger [?] enable|disable|rename|compile ",
		MSSQL_DROP_TRIGGER+"					=>	drop trigger [?]",
		
		MSSQL_ALTER_SESSION+"					=>	alter session advise|close|enable|disable|force|",
		MSSQL_ALTER_SESSION_SET_PARAMETER+"		=>	alter session set [?]",
		
		MSSQL_CREATE_PROFILE+"					=>	create profile [?]",
		MSSQL_ALTER_PROFILE+"					=>	alter profile [?]",
		MSSQL_DROP_PROFILE+"					=>	drop profile [?]",
		
		MSSQL_ALTER_TYPE+"						=>	alter type [?] ",
		MSSQL_DROP_TYPE+"						=>	drop type [?] ",		

		MSSQL_COMMIT+"							=>	commit",		
		MSSQL_ROLLBACK+"						=>	rollback",
		MSSQL_SAVEPOINT+"						=>	savepoint",
		
		
		MSSQL_COMMENT+"							=>	comment on table|column [?] is",
		
		MSSQL_LOCK_TABLE+"						=>	lock table [?] in",
		
		MSSQL_CREATE_DIRECTORY+"				=>	create directory [?] as",
		MSSQL_DROP_DIRECTORY+"					=>	drop directory [?]",

		MSSQL_EXECUTE_IMMEDIATE+"				=>	execute immediate",		
		MSSQL_EXPLAIN_PLAN+"					=>	explain plan for",		
		
		MSSQL_GRANT+"							=>	grant ^ to",		
		MSSQL_REVOKE+"							=>	revoke ^ from",	
		
		MSSQL_CREATE_JAVA+"						=>	create java",
		MSSQL_ALTER_JAVA+"						=>	alter java",
		MSSQL_DROP_JAVA+"						=>	drop java",

		MSSQL_CREATE_DATABASE_LINK+"			=>	create database link [?]",
		MSSQL_DROP_DATABASE_LINK+"				=>	drop database link [?]",

	};
	


	static final String STMT_TYPE_UNDETECTED="UNDETECTED";
	
	//----------------------------------------------------------------
	public static void determineStatementType(String original_query, StringBuilder statement_type, StringBuilder  statement_related_object) {
		
		
		statement_type.setLength(0);
		statement_type.append(STMT_TYPE_UNDETECTED);
		
		statement_related_object.setLength(0);
		
		
		
		StringBuilder sbStmtConf=new StringBuilder();
		
		ArrayList<ddmChunk> chunkArr=msSqlParser.getChunks(original_query, msSqlParser.invisibleChars, true);
		
		mergeDottedChunks(chunkArr);
		
		for (int i=0;i<oracleStmtTypeConfigArr.length;i++) {
			sbStmtConf.setLength(0);
			sbStmtConf.append(oracleStmtTypeConfigArr[i]);
			int ind=sbStmtConf.indexOf("=>");
			String stmt_type_name=sbStmtConf.substring(0,ind).replaceAll("\t", "").trim();
			String stmt_type_config=sbStmtConf.substring(ind+2).replaceAll("\t", "").trim();
								
			boolean isMatched=checkStatementType(original_query, chunkArr, stmt_type_config, statement_related_object);
			
			if (!isMatched) statement_related_object.setLength(0);
			
			
			if (isMatched) {
				statement_type.setLength(0);
				statement_type.append(stmt_type_name);
				break;
			}
		}
		
		
	}
	
	
	//-------------------------------------------------------------------
	static boolean checkStatementType(String text, ArrayList<ddmChunk> chunkArr, String stmt_type_config, StringBuilder related_object) {
		
		
		
		related_object.setLength(0);
		
		String[] confArr=stmt_type_config.split(" ");
		int last_chunk_id=0;
		
		boolean isSigleWord=true;
		boolean isBlock=false;
		boolean isComment=false;
		boolean isOperator=false;
		
		
		int EndIndex=chunkArr.size();
		
		for (int i=0;i<confArr.length;i++) {
						
			if (confArr[i].length()==0) continue;
			
			if (confArr[i].equals("[?]")) {
				
				int next_keyword_id=getNextChunkId(chunkArr, last_chunk_id, EndIndex, true, false, false, false, null);
				if (next_keyword_id>-1) {
					related_object.append(chunkArr.get(next_keyword_id).text);
					last_chunk_id=next_keyword_id;
				}
				
				continue;
			} 
			
			if (confArr[i].equals("{block}")) {
				isBlock=true;
				isSigleWord=false;
				last_chunk_id=getNextChunkId(chunkArr, last_chunk_id, EndIndex, isSigleWord, isComment, isBlock, isOperator, null);
			} else {
				isBlock=false;
				isSigleWord=true;
				last_chunk_id=getNextChunkId(chunkArr, last_chunk_id, EndIndex, isSigleWord, isComment, isBlock, isOperator, confArr[i]);
			}
						
			if (last_chunk_id==-1) 
				return false;
			
			last_chunk_id++;	
		}
		
		
		return true;
	}

	
	//--------------------------------------------------------------------------------------------------
	static final String KEYWORDS_END_OF_SELECT="UNION|EXCEPT|INTERSECT";
	static final String KEYWORD_END_OF_COMMAND=";";
	
	static final String[] eofCommandArr=new String[]{" ","\t","\n","\r",";"};
	
	public static void locateSelectQueries(
			String query, 
			int offset, 
			ArrayList<Integer[]> locations, 
			ArrayList<String> selectQueries
			) {
		
		
		ArrayList<ddmChunk> chunkArr=getChunksByCharArr(query, eofCommandArr);
				
		int len=chunkArr.size();
		int length_of_query=query.length();
		int cursor=0;
		int pos_from=-1;
		int pos_with=-1;
		int pos_start_of_select=-1;
		int pos_end_of_select=-1;
		
		while(true) {
			pos_from=getNextChunkId(chunkArr, cursor, len, true, false, false, false, KEYWORD_FROM);
			if (pos_from==-1) break;
			
			pos_start_of_select=getNextChunkId(chunkArr, cursor, pos_from, true, false, false, false, KEYWORD_SELECT);
			
			if (pos_start_of_select==-1) break;
			
						
			cursor=pos_from+1;
						
			pos_end_of_select=getNextChunkId(chunkArr, cursor, len, false, false, false, true, KEYWORD_END_OF_COMMAND);
			if (pos_end_of_select==-1) pos_end_of_select=getNextChunkId(chunkArr, cursor, len, true, false, false, false, KEYWORDS_END_OF_SELECT);
			if (pos_end_of_select==-1) pos_end_of_select=len;
						
			if (pos_end_of_select==-1) break;
			
			int start_index=chunkArr.get(pos_start_of_select).startPosInText;
			int end_index=length_of_query;
			if (pos_end_of_select!=len) end_index=chunkArr.get(pos_end_of_select).startPosInText;
			
			Integer[] locArr=new Integer[]{start_index+offset, end_index+offset};
			
			locations.add(locArr);
						
			cursor=pos_end_of_select+1;
						
			selectQueries.add(query.substring(start_index,end_index));
			
		}
		
		
		StringBuilder sbBlockQuery=new StringBuilder();
		
		for (int i=0;i<chunkArr.size();i++) {
			ddmChunk chunk=chunkArr.get(i);

			if (!chunk.isBlock) continue;
			if (chunk.text.length()<2) continue;
			
			boolean is_in_select_ranges=false;
			for (int r=0;r<locations.size();r++) 
				if (chunk.startPosInText>= locations.get(r)[0] && chunk.startPosInText<= locations.get(r)[1]) {
					is_in_select_ranges=true;
					break;
				}
			
			if (is_in_select_ranges) continue;
			/*
			sbBlockQuery.setLength(0);
			sbBlockQuery.append(chunk.text);
			sbBlockQuery.setCharAt(0, ' ');
			sbBlockQuery.setCharAt(chunk.text.length()-1, ' ');
			*/
			//locateSelectQueries(sbBlockQuery.toString(), chunk.startPosInText+1, locations, selectQueries);
			sbBlockQuery.setLength(0);
			sbBlockQuery.append(chunk.text.substring(1, chunk.text.length()-1));
			locateSelectQueries(sbBlockQuery.toString() , chunk.startPosInText+1, locations, selectQueries);
			
		}
		
		if (offset==0) {
			//reorder positions
			
			for (int r=0;r<locations.size();r++) 
				for (int s=r+1;s<locations.size();s++) {
					if (locations.get(s)[0]<locations.get(r)[0]) {
						Integer[] tmpIntArr=locations.get(r);
						locations.set(r, locations.get(s));
						locations.set(s, tmpIntArr);
						
						String tmpStr=selectQueries.get(r);
						selectQueries.set(r, selectQueries.get(s));
						selectQueries.set(s, tmpStr);
					}
				}
		}
		
		
	}
	
	//************************************************************************************************
	public static void extractCatalogSchemaObject(
			StringBuilder sbFromPart,
			StringBuilder sbCatalog,
			StringBuilder sbSchema,
			StringBuilder sbObject,
			ddmClient ddmClient
			) {
		
		String[] arr=sbFromPart.toString().split("\\.");
		

		int counter=0;
		
		
		
		for (int i=arr.length-1;i>=0;i--) {
			arr[i]=arr[i].replaceAll("\"|\\[|\\]|\t|\n|\r", "");
			counter++;
			
			if (counter==1) sbObject.append(arr[i]);
			else if (counter==2) sbSchema.append(arr[i]);
			else if (counter==3) sbCatalog.append(arr[i]);
		}
		
		
		if (sbSchema.length()==0) sbSchema.append(ddmClient.CURRENT_SCHEMA);
		if (sbCatalog.length()==0) sbCatalog.append(ddmClient.CURRENT_CATALOG);	
	}	
	
}
