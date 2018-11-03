package com.mayatech.dm.protocolTns;

import java.nio.ByteOrder;
import java.nio.charset.Charset;
import java.util.ArrayList;

import com.mayatech.baseLibs.genLib;
import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmLib;

public class oracleTnsPackage {
	
	ddmClient ddmClient=null;
	public boolean is_debug=false;
	
	
	int package_version=0; //52 54 58 59
	int protocol_characteristic=0;	//-14834 20120
	
	public boolean is_invalid=false;
	
	
	String charset="utf-8";
	
	
	public String sql_statement=null;
	
	byte[] byte_part_header=null;	
	int skip_bytes_before_statement_len=0;
	byte[] byte_part_before_statement_len=null;	
	byte[] byte_part_before_statement_string=null;	
	byte[] byte_part_for_statement_string=null;	
	byte[] byte_part_after_statement_string=null;	
	
	int header_len_pos=0;
	
	

	
	
	int len_type=oracleTnsLib.LEN_TYPE_NONE;
	int len_type_before_statement=oracleTnsLib.LEN_TYPE_NONE;
	
	boolean is_long_statement=false;
	
	int chunk_style=oracleTnsLib.CHUNK_STYLE_NONE;
	int chunk_size=0;
	
	boolean is_triple=false;
	
	 	//-------------------------------------------------------------------------
		void mydebug(String logstr) {

			if (is_debug) mylog(logstr);
		}
		//-------------------------------------------------------------------------
		void mylog(String logstr) {
			if (ddmClient!=null)
				ddmClient.mylog(logstr);
			else 
				System.out.println(logstr);
		}
		//-----------------------------------------------------------------------
		void printByteArray(byte[] buf, int len) {
			if (is_debug)  
				if (ddmClient!=null)
					ddmClient.printByteArray(buf, len);
				else 
					ddmLib.printByteArray(buf, len);
		}
		
		
	


	
	//-----------------------------------------------------------------------------
	
	public void compile(
			ddmClient  ddmClient,
			byte[] buf, 
			int len, 
			int package_version,
			int protocol_characteristic,
			String charset) {
		
		if (ddmClient!=null && ddmClient.dm!=null)
			this.is_debug=ddmClient.dm.is_debug ||  ddmClient.is_tracing;
		
		//this.is_debug=true;
		
		this.ddmClient=ddmClient;
		this.package_version=package_version;
		this.protocol_characteristic=protocol_characteristic;
		this.charset=charset;
		
		int cursor=0;
		byte_part_header=new byte[10];
		System.arraycopy(buf, 0, byte_part_header, 0, 10);
		cursor+=10;
		
		if (is_debug)	 {
			mydebug("byte_part_header : ");
			printByteArray(byte_part_header,10);
		}

		
		if (buf[0]==0 && buf[1]==0) header_len_pos=2;
		if (is_debug)	mydebug("header_len_pos : "+header_len_pos);
		
		int pos_3_94=ddmLib.IndexOfByteArray(buf, cursor, cursor+50, oracleTnsLib.byte_final_3_94);
		
		
		if (pos_3_94==-1) {
			mydebug("pos_3_94 not found. Package invalid");
			is_invalid=true;
			return;
		}
		
		
		try {
			cursor=pos_3_94+7;

			
			while (true) {
				if (buf[cursor]==(byte) 0) {cursor++; continue;}
				if (buf[cursor]==oracleTnsLib.byte_single_254) {cursor+=8; break;}
				//if (buf[cursor]==(byte) 1) {cursor++; break;}
				if (buf[cursor]==(byte) 1) {break;}
				break;
			}
			
			
			int start_of_statement_len=cursor;
			if (is_debug)	mydebug("start_of_statement_len : "+start_of_statement_len);
			
			int len_of_part_before_statement_len=(start_of_statement_len-10);
			byte_part_before_statement_len=new byte[len_of_part_before_statement_len];
			System.arraycopy(buf, 10, byte_part_before_statement_len, 0, len_of_part_before_statement_len);
			
			if (is_debug)	{
				mydebug("byte_part_before_statement_len : "+len_of_part_before_statement_len);
				printByteArray(byte_part_before_statement_len, byte_part_before_statement_len.length);
			}

			compileForProtocolCharAll(buf, len, start_of_statement_len);
			
		} catch(Exception e) {
			is_invalid=true;
			sql_statement=null;
			mylog("Exception@ oracleTnsPackage.compile : ");
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
		}
		
		
	}
	
	//---------------------------------------------------------------------------------------------
	void compileForProtocolCharAll(
			byte[] buf, 
			int len,
			int startIndex) {
		//[0][0][1]2[6][0][0][0][0][0][17]i[7][254][255][255][255][255][255][255][255][1][1][1][1][3][94][8][2][128]a[0][254][255][255][255][255][255][255][255][1]h[254][255][255][255][255][255][255][255][1][13][254][255][255][255][255][255][255][255][254][255][255][255][255][255][255][255][0][2][1][245][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][254][255][255][255][255][255][255][255][0][0][0][0][0][0][0][0][254][255][255][255][255][255][255][255][254][255][255][255][255][255][255][255][254][255][255][255][255][255][255][255][0][0][254][255][255][255][255][255][255][255][254][255][255][255][255][255][255][255][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0]hSELECT version, product, sysdate FROM sys.PRODUCT_COMPONENT_VERSION WHERE UPPER(PRODUCT) LIKE '%ORACLE%'[1][1][0][0][0][0][0][0][1][1][0][2][128][0][0][0][0]
		
		
		
		len_type_before_statement=oracleTnsLib.LEN_TYPE_NONE;
		
		//visible 5 karakter buluncaya kadar devam
		int start_of_search=startIndex+20;
		int visible_char_count=0;
		boolean visible_part_found=false;
		int statement_part_start_pos=-1;
		int statement_part_end_pos=-1;
		int search_end=len-10;
		
		
		for (int i=start_of_search;i<search_end;i++) {
			if (ddmLib.visible_chars.indexOf(buf[i])>-1) 
				visible_char_count++;
			else 
				visible_char_count=0;
			if (visible_char_count>5) {
				visible_part_found=true;
				statement_part_start_pos=i;
				break;
			} 
		}
		
		
		if (!visible_part_found) {
			if (is_debug) mydebug("Visible part not found");
			is_invalid=true;
			return;
		}
		
		statement_part_start_pos=oracleTnsLib.goLeftUntil(buf, statement_part_start_pos, startIndex, oracleTnsLib.byte_array_zero);
		
		//5 karakter geriden basla ve 0 lar ve 1 ler bitinceye kadar devam et 		
		statement_part_start_pos-=5;
		while(true) {
			if (buf[statement_part_start_pos]!=(byte) 0 && buf[statement_part_start_pos]!=(byte) 1) break;
			statement_part_start_pos++;
		}
		
		
		//1 i buluncaya kadar devam et ve statement in sonunu bul
		statement_part_end_pos=statement_part_start_pos+6;
		statement_part_end_pos=oracleTnsLib.goRightUntil(buf, statement_part_end_pos, len, oracleTnsLib.byte_array_one);
		//bazen son chunk sadece 1 byte kaliyor. bu durumda 1 den sonrakini de almaliyiz.
		//[254]@Select created, last_ddl_time, object_id, status[10]from sys.DBA_OB@JECTS[10]where object_name = :nm[10]and owner = :o[10]and object_type = :[1]t[0][1][1][0][0][0]....
		if (buf[statement_part_end_pos+1]!=1 && buf[statement_part_end_pos+1]!=0) {
			statement_part_end_pos+=2;
			//sifirlara denk geldiyse bunlari da dahil et. ORNEK : 
			//[1][135][0][0][6][0][0][0][0][0][17]i[29][254][255][255][255][255][255][255][255][1][1][1][1][3][94][30][2][128]i[0][254][255][255][255][255][255][255][255][1][129][254][255][255][255][255][255][255][255][1][13][254][255][255][255][255][255][255][255][254][255][255][255][255][255][255][255][0][2][1][245][0][254][255][255][255][255][255][255][255][1][3][0][0][0][0][0][0][0][0][254][255][255][255][255][255][255][255][0][0][0][0][0][0][0][0][254][255][255][255][255][255][255][255][254][255][255][255][255][255][255][255][254][255][255][255][255][255][255][255][0][0][254][255][255][255][255][255][255][255][254][255][255][255][255][255][255][255][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0] 	[254]@Select created, last_ddl_time, object_id, status[10]from sys.DBA_OB@JECTS[10]where object_name = :nm[10]and owner = :o[10]and object_type = :[1]t[0][1][1][0][0][0][0][0][0][1][1][0][0][0][0][0][1][1][0][0][1][26][0][1][16][0][0][1]'[1][0][1][1][0][0][1][14][0][1][16][0][0][1]'[1][0][1][1][0][0][1][10][0][1][16][0][0][1]'[1][0][7][13]SMS_ISLEM_LOG[7]SMS_DBA[5]TABLE
			while(true) {
				if (buf[statement_part_end_pos]!=(byte) 0) break;
				statement_part_end_pos++;
			}
			
			
		}
		
		
		int statement_bytes_len=statement_part_end_pos-statement_part_start_pos;
		
		byte_part_for_statement_string=new byte[statement_bytes_len];
		System.arraycopy(buf, statement_part_start_pos, byte_part_for_statement_string, 0, statement_bytes_len);
		
		if (statement_bytes_len>270) is_long_statement=true;
		
		
		if (byte_part_for_statement_string[0]==oracleTnsLib.byte_single_254 ) {
			if (byte_part_for_statement_string[4]==0) {
				chunk_style=oracleTnsLib.CHUNK_STYLE_4BYTES;
				chunk_size=255;
			}
			else if (ddmLib.byte2UnsignedInt(byte_part_for_statement_string[1])==64) {
				chunk_style=oracleTnsLib.CHUNK_STYLE_CLASSIC;
				chunk_size=64;
				
			}
			else if (ddmLib.byte2UnsignedInt(byte_part_for_statement_string[1])==255) {
				chunk_style=oracleTnsLib.CHUNK_STYLE_CLASSIC;
				chunk_size=255;
			}
			else {
				chunk_style=oracleTnsLib.CHUNK_STYLE_BYTELEN;
				chunk_size=255;
				
			}

		} 
		
		
		if (!ddmClient.ORADISC_is_chunk_discovered && is_long_statement) {
			ddmClient.ORADISC_is_chunk_discovered=true;
			ddmClient.ORADISC_chunk_style=chunk_style;
			ddmClient.ORADISC_chunk_limit=chunk_size;
			
			oracleTnsLib.loadSaveOracleTnsChunkConf(ddmClient,oracleTnsLib.ACT_SAVE);
		}
		

		if (is_debug) {
			mydebug("statement_part_start_pos         : "+statement_part_start_pos);
			mydebug("statement_part_end_pos           : "+statement_part_end_pos);
			mydebug("statement_bytes_len              : "+statement_bytes_len);
			mydebug("byte_part_for_statement_string   :"+statement_bytes_len);
			printByteArray(byte_part_for_statement_string, byte_part_for_statement_string.length);
			
			mydebug("is_long_statement : "+is_long_statement);
			mydebug("chunk_style       : "+chunk_style);
			mydebug("chunk_size        : "+chunk_size);
		}
		
		
		if (chunk_style==oracleTnsLib.CHUNK_STYLE_NONE) {
		
			if (!ddmClient.ORADISC_first_byte_analyzed) {
				ddmClient.ORADISC_first_byte_analyzed=true;
				if (ddmLib.byte2UnsignedInt(byte_part_for_statement_string[0])==(byte_part_for_statement_string.length-1))
					ddmClient.ORADISC_first_byte_as_length=true;
			}
			
			if (!ddmClient.ORADISC_first_byte_analyzed) {
				is_invalid=true;
				mydebug("ORADISC_first_byte_analyzed=false;");
				return;
			}
			
			if (ddmClient.ORADISC_first_byte_as_length)
				sql_statement=new String(byte_part_for_statement_string, 1, byte_part_for_statement_string.length-1, Charset.forName(charset));
			else 
				sql_statement=new String(byte_part_for_statement_string, 0, byte_part_for_statement_string.length, Charset.forName(charset));
			
		} else if (chunk_style==oracleTnsLib.CHUNK_STYLE_CLASSIC) {
			byte[] cleared=ddmLib.clearChunkedBytes(byte_part_for_statement_string,0,byte_part_for_statement_string.length);
			sql_statement=new String(cleared, 0, cleared.length, Charset.forName(charset));
		}
		else if (chunk_style==oracleTnsLib.CHUNK_STYLE_4BYTES) {
			sql_statement=new String(byte_part_for_statement_string, 5, byte_part_for_statement_string.length-9, Charset.forName(charset));
		} 
		else if (chunk_style==oracleTnsLib.CHUNK_STYLE_BYTELEN) {
			int statement_len=oracleTnsLib.getLengthValueByType(byte_part_for_statement_string, 1, oracleTnsLib.LEN_TYPE_BYTE_LENGTH_WITHOUT_1);
			byte[] tmpStmtLen=oracleTnsLib.getLengthBytesByType(statement_len, oracleTnsLib.LEN_TYPE_BYTE_LENGTH_WITHOUT_1);
			
			if (is_debug) {
				mydebug("statement_len:"+statement_len);
				printByteArray(tmpStmtLen, tmpStmtLen.length);


				sql_statement=new String(byte_part_for_statement_string, 1+tmpStmtLen.length, statement_len, Charset.forName(charset));

			}
			
		}
		
		
		
	
		if (is_debug) {
			mydebug("Sql Statement              : "+sql_statement);
			mydebug("Sql Statement Length       : "+sql_statement.length());
		}
		

		
		
		int test_BYTE_LENGTH=0;					//[1][1][18]
		int test_BYTE_LENGTH_WITHOUT_1=0;		//[1][18]
		int test_BYTE_ORDERED_4_BYTES=0;		//[149][20][0][0] veya [149][20][0][0][0][0][0][0]
		

		
		try{test_BYTE_LENGTH=oracleTnsLib.getLengthValueByType(buf,startIndex,oracleTnsLib.LEN_TYPE_BYTE_LENGTH);} catch(Exception e){}
		try{test_BYTE_LENGTH_WITHOUT_1=oracleTnsLib.getLengthValueByType(buf,startIndex,oracleTnsLib.LEN_TYPE_BYTE_LENGTH_WITHOUT_1);} catch(Exception e){}
		try{test_BYTE_ORDERED_4_BYTES=oracleTnsLib.getLengthValueByType(buf,startIndex,oracleTnsLib.LEN_TYPE_BYTE_ORDERED_4_BYTES);} catch(Exception e){}

		
		if (is_debug) {
			mydebug("test_BYTE_LENGTH                  : "+test_BYTE_LENGTH);
			mydebug("test_BYTE_LENGTH_WITHOUT_1        : "+test_BYTE_LENGTH_WITHOUT_1);
			mydebug("test_BYTE_ORDERED_4_8_BYTES       : "+test_BYTE_ORDERED_4_BYTES);
		}
		
		int statement_byte_length=0;
		
		try{statement_byte_length=sql_statement.getBytes(Charset.forName(charset)).length;} catch(Exception e){}
		
		int statement_byte_length_triple=statement_byte_length*3;
		
		len_type=oracleTnsLib.LEN_TYPE_BYTE_ORDERED_4_BYTES;
		
		if (test_BYTE_LENGTH==statement_byte_length) {
			is_triple=false;
			len_type=oracleTnsLib.LEN_TYPE_BYTE_LENGTH;
			try{skip_bytes_before_statement_len=oracleTnsLib.getLengthBytesByType(test_BYTE_LENGTH, len_type).length;} catch(Exception e){};
		} else if (test_BYTE_LENGTH==statement_byte_length_triple) {
			is_triple=true;
			len_type=oracleTnsLib.LEN_TYPE_BYTE_LENGTH;
			try{skip_bytes_before_statement_len=oracleTnsLib.getLengthBytesByType(test_BYTE_LENGTH, len_type).length;} catch(Exception e){};
		} else if (test_BYTE_LENGTH_WITHOUT_1==statement_byte_length) {
			is_triple=false;
			len_type=oracleTnsLib.LEN_TYPE_BYTE_LENGTH_WITHOUT_1;
			try{skip_bytes_before_statement_len=oracleTnsLib.getLengthBytesByType(test_BYTE_LENGTH_WITHOUT_1, len_type).length;} catch(Exception e){};
		} else if (test_BYTE_LENGTH_WITHOUT_1==statement_byte_length_triple) {
			is_triple=true;
			len_type=oracleTnsLib.LEN_TYPE_BYTE_LENGTH_WITHOUT_1;
			try{skip_bytes_before_statement_len=oracleTnsLib.getLengthBytesByType(test_BYTE_LENGTH_WITHOUT_1, len_type).length;} catch(Exception e){};
		} else if (test_BYTE_ORDERED_4_BYTES==statement_byte_length) {
			is_triple=false;
			len_type=oracleTnsLib.LEN_TYPE_BYTE_ORDERED_4_BYTES;
			try{skip_bytes_before_statement_len=oracleTnsLib.getLengthBytesByType(test_BYTE_ORDERED_4_BYTES, len_type).length;} catch(Exception e){};
		} else if (test_BYTE_ORDERED_4_BYTES==statement_byte_length_triple) {
			is_triple=true;
			len_type=oracleTnsLib.LEN_TYPE_BYTE_ORDERED_4_BYTES;
			try{skip_bytes_before_statement_len=oracleTnsLib.getLengthBytesByType(test_BYTE_ORDERED_4_BYTES, len_type).length;} catch(Exception e){};
		}
		
		if (is_debug) {
			mydebug("skip_bytes_before_statement_len   : "+skip_bytes_before_statement_len);
			mydebug("statement_byte_length_triple      : "+statement_byte_length_triple);
			mydebug("len_type                          : "+len_type+" (0:NONE, 1:BYTE_LENGTH, 2:LENGTH_WITHOUT_1, 4:ORDERED_4_BYTES, 8: ORDERED_8_BYTES)");
			mydebug("is_triple                         : "+is_triple);
		}
		
		if (skip_bytes_before_statement_len==0) {
			is_invalid=true;
			mydebug("skip_bytes_before_statement_len =0");
			return;
		}

		int len_of_part_before_statement_text=(statement_part_start_pos-startIndex)-skip_bytes_before_statement_len;
		
		byte[] stmtLenHdrByteAr=new byte[skip_bytes_before_statement_len];
		System.arraycopy(buf, startIndex, stmtLenHdrByteAr, 0, skip_bytes_before_statement_len);
		
		byte_part_before_statement_string=new byte[len_of_part_before_statement_text];
		System.arraycopy(buf, startIndex+skip_bytes_before_statement_len , byte_part_before_statement_string, 0, len_of_part_before_statement_text);
		
		if (is_debug)	{
			mydebug("stmtLenHdrByteAr      : "+skip_bytes_before_statement_len);
			printByteArray(stmtLenHdrByteAr, stmtLenHdrByteAr.length);
			mydebug("byte_part_before_statement_string      : "+len_of_part_before_statement_text);
			printByteArray(byte_part_before_statement_string, byte_part_before_statement_string.length);
		}


		 
		
		
		int len_after_statement_bytes=len-statement_part_end_pos;
		byte_part_after_statement_string=new byte[len_after_statement_bytes];
		System.arraycopy(buf, statement_part_end_pos, byte_part_after_statement_string, 0, len_after_statement_bytes);
		if (is_debug)	{
			mydebug("byte_part_after_statement_string : "+len_after_statement_bytes);
			printByteArray(byte_part_after_statement_string, byte_part_after_statement_string.length);
		}
		
		
	}
	
	
	
	
	
	//---------------------------------------------------------------------------------------------
	public void setStatement(String new_statement) {
		sql_statement=new_statement;
		
		//hep chunked olsun diye, 260 dan kisa ise 260 a tamamliyoruz ve chunk a zorluyoruz. 
		if (new_statement.length()<260) {
			int dif=(260-new_statement.length())/18;

			for (int i=0;i<dif+1;i++) sql_statement=sql_statement+"\n/* infobox ddm */";
		}
		
	}
	
	//-------------------------------------------------------------------------------------------------------------
	public void rePack(int maxPackageSize, ArrayList<byte[]> packArr, ArrayList<Integer> sizeArr) {
		
		
		if (!ddmClient.ORADISC_is_chunk_discovered) {
			mydebug("ORADISC_is_chunk_discovered=false;");
			return;
		}
		try {


			repackForProtocolCharAll(maxPackageSize,packArr,sizeArr);
		} catch(Exception e) {
			mylog("Exception@rePack:"+e.getLocalizedMessage());
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
		}
		
		
	}
	//----------------------------------------------------------------------------------------------
	public void repackForProtocolCharAll(int maxPackageSize, ArrayList<byte[]> packArr, ArrayList<Integer> sizeArr) {
		
		if (is_debug) mydebug("repackForProtocolChar_14834 : "+sql_statement);
		
		byte_part_for_statement_string=sql_statement.getBytes(Charset.forName(charset));
		int statement_bytes_len=byte_part_for_statement_string.length;

		ArrayList<byte[]> byteArrays=new ArrayList<byte[]>();
		
		int stmt_len=statement_bytes_len;
		if (is_triple) stmt_len=stmt_len*3;
		
		byte[] lenBytes=oracleTnsLib.getLengthBytesByType(stmt_len,len_type);
		
		byte[] bytesForStatement=generateByteForStatement(byte_part_for_statement_string);
		
		if (bytesForStatement==null) {
			mydebug("repackForProtocolChar_14834:generateByteForStatement returns null;");
			return;
		}
		
		byteArrays.add(byte_part_before_statement_len);
		byteArrays.add(lenBytes);
		byteArrays.add(byte_part_before_statement_string);

		byteArrays.add(bytesForStatement);
		byteArrays.add(byte_part_after_statement_string);
		
		if (!is_invalid)
			concatanateByteArrays(maxPackageSize,packArr,sizeArr,byteArrays);
	}
	//-----------------------------------------------------------------------------------------------
	byte[] generateByteForStatement(byte[] stmtByteArr) {
		
		int chunk_limit=chunk_size;
		
		if (chunk_size==0) {
			chunk_limit=32;
			
			if (ddmClient.ORADISC_is_chunk_discovered) {
				chunk_limit=ddmClient.ORADISC_chunk_limit;
				chunk_size=chunk_limit;
				chunk_style=ddmClient.ORADISC_chunk_style;
			}
			else {
				if (package_version>=59) 
					chunk_limit=255;
				else 
					chunk_limit=64;
				
				if (package_version>=59) 
					chunk_style=oracleTnsLib.CHUNK_STYLE_4BYTES;
				else 
					chunk_style=oracleTnsLib.CHUNK_STYLE_CLASSIC;
			}
			
			
		}
		
		
		int stmtByteArrLen=stmtByteArr.length;
		boolean to_be_chunked=false;
		if (stmtByteArrLen>=chunk_limit) to_be_chunked=true;
		
		if (!to_be_chunked) {
			byte[] ret1=new byte[stmtByteArrLen+1];
			ret1[0]=(byte) stmtByteArr.length;
			System.arraycopy(stmtByteArr, 0, ret1, 1, stmtByteArrLen);
			if (is_debug) {
				mydebug("generatedBytesForStmt :");
				printByteArray(ret1, ret1.length);
			}
			return ret1;
		}
		
		
		
		if (chunk_style==oracleTnsLib.CHUNK_STYLE_CLASSIC) {
			if (is_debug) mydebug("chunk_style=CHUNK_STYLE_CLASSIC, chunk_size: "+chunk_limit);

			byte[] ret1= oracleTnsLib.makeChunkedBytes(stmtByteArr,stmtByteArrLen,chunk_limit);
			
			if (is_debug) {
				mydebug("generatedBytesForStmt :");
				printByteArray(ret1, ret1.length);
			}
			
			return ret1;
		} 
		else if (chunk_style==oracleTnsLib.CHUNK_STYLE_BYTELEN) {
			if (is_debug) mydebug("chunk_style=CHUNK_STYLE_BYTELEN");
			int cursor=0;
			
			byte[] ret1=new byte[stmtByteArrLen+10];
			ret1[0]=oracleTnsLib.byte_single_254;
			cursor++;
			
			byte[] lenBytes=oracleTnsLib.getLengthBytes_BYTE_LENGTH_WITHOUT_1(stmtByteArrLen);
			if (is_debug) {
				mydebug("lenBytes :");
				printByteArray(lenBytes, lenBytes.length);
			}
			System.arraycopy(lenBytes, 0, ret1, 1, lenBytes.length);
			cursor+=lenBytes.length;
			System.arraycopy(stmtByteArr, 0, ret1, cursor, stmtByteArrLen);
			cursor+=stmtByteArrLen;
			//keep last 1 zero as default+
			cursor+=1;
			
			byte[] finalBytes=new byte[cursor];
			System.arraycopy(ret1, 0, finalBytes, 0, cursor);
			
			if (is_debug) {
				mydebug("generatedBytesForStmt :");
				printByteArray(finalBytes, finalBytes.length);
			}
			
			return finalBytes;
			
			
		}
		else if ( chunk_style==oracleTnsLib.CHUNK_STYLE_4BYTES) {
			
			if (is_debug) mydebug("chunk_style=CHUNK_STYLE_4BYTES");
			int cursor=0;
			
			byte[] ret1=new byte[stmtByteArrLen+9];
			ret1[0]=oracleTnsLib.byte_single_254;
			cursor++;
			
			byte[] lenBytes=oracleTnsLib.getLengthBytes_LEN_TYPE_BYTE_ORDERED_4_BYTES(stmtByteArrLen);
			if (is_debug) {
				mydebug("lenBytes :");
				printByteArray(lenBytes, lenBytes.length);
			}
			System.arraycopy(lenBytes, 0, ret1, cursor, lenBytes.length);
			cursor+=lenBytes.length;
			
			System.arraycopy(stmtByteArr, 0, ret1, cursor, stmtByteArrLen);
			cursor+=stmtByteArrLen;
			
			
			//keep last 4 zero as default+
			cursor+=4;
			
			if (is_debug) {
				mydebug("generatedBytesForStmt :");
				printByteArray(ret1, ret1.length);
			}
			
			return ret1;
		}
		
		else return null;
	}
	//-----------------------------------------------------------------------------------------------
	void concatanateByteArrays(int maxPackageSize, ArrayList<byte[]> packArr, ArrayList<Integer> sizeArr,  ArrayList<byte[]> byteArrays) {
		
		int sum_len=0;
		 
		 for (int i=0;i<byteArrays.size();i++) {
			 if(is_debug) 
				 printByteArray(byteArrays.get(i), byteArrays.get(i).length);
			 sum_len+=byteArrays.get(i).length;
		 }
		 
		 byte[] buf=new byte[sum_len];
		 int cursor=0;
		 for (int i=0;i<byteArrays.size();i++) {
			 System.arraycopy(byteArrays.get(i), 0, buf, cursor, byteArrays.get(i).length);
			 cursor+=byteArrays.get(i).length;
		 }
		 
		 int buf_len=buf.length;
		 
		 
		 if (is_debug) { 
			mydebug("concatanated buffer :"+buf_len);
			printByteArray(buf,buf_len);
		 }
		 
		 int targetPackageSize=((maxPackageSize/4)*3);
		 cursor=0;
		 
		 while(true) {
			 boolean last_pack=false;
			 int next_pos=cursor+targetPackageSize-10;
			 
			 if (next_pos>=buf_len) {
				 next_pos=buf_len;
				 last_pack=true;
			 }
			 int packSize=next_pos-cursor;
			 
			 if (is_debug) mydebug("packSize:"+packSize);
			 
			 byte[] aPack=new byte[packSize+10];
			 
			 System.arraycopy(byte_part_header, 0, aPack, 0, 10);
			 byte[] packageLengthByteArr=ddmLib.convertInteger2ByteArray4Bytes(packSize+10, ByteOrder.BIG_ENDIAN);
			 
			 if (is_debug) {
				 mydebug("packageLengthByteArr :"+packageLengthByteArr.length);
				 printByteArray(packageLengthByteArr, 4);
			 }
			 
			 System.arraycopy(packageLengthByteArr, 2, aPack, header_len_pos, 2);
			 System.arraycopy(buf, cursor, aPack, 10, packSize);
			 
			 aPack[5]=byte_part_header[5];// may be 0 or 32
			 
			 
			 
			 if (last_pack)  
				 aPack[9]=(byte) 0;
			 else {
				 if (protocol_characteristic==20120) 
					 aPack[9]=byte_part_header[9];
				 else 
					 aPack[9]=(byte) 0;
			 }
				 
			 packArr.add(aPack);
			 sizeArr.add(packSize+10);
			 
			 cursor=next_pos;
			 
			 if (last_pack) break;
		 }
		 
	}
}
