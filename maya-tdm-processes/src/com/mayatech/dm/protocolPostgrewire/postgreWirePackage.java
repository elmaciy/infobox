package com.mayatech.dm.protocolPostgrewire;

import java.nio.ByteOrder;
import java.nio.charset.Charset;
import java.util.ArrayList;

import com.mayatech.baseLibs.genLib;
import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmLib;

public class postgreWirePackage {
	
	ddmClient ddmClient=null;
	public boolean is_debug=false;

	
	public boolean is_invalid=false;
	
	
	String charset="utf-8";


	
	public String sql_statement=null;
	
	
	byte[] byte_part_for_header=null;	
	byte[] byte_part_for_statement_string=null;	
	byte[] byte_part_after_statement_string=null;	
	
	
	int len_of_original_pack=0;
	int len_of_original_stmt=0;
	
	
	
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
		
		
	
	
	//--------------------------------------------------------
	
	static final byte[] ZER0_BYTE_ARR=new byte[]{(byte) 0};
	
	public void compile(
			ddmClient  ddmClient,
			byte[] buf, 
			int len, 
			String charset) {
		
		if (ddmClient!=null)
			this.is_debug=ddmClient.dm.is_debug ||  ddmClient.is_tracing;
		
		//this.is_debug=true;
		
		this.ddmClient=ddmClient;
		this.charset=charset;
		
		if (is_debug)  {
			mydebug("compile:");
			printByteArray(buf, len);
		}
		
		len_of_original_pack=ddmLib.contertByteArray2Integer(buf, 1, 4, ByteOrder.BIG_ENDIAN);
		if (is_debug) mydebug("len_of_original_pack:"+len_of_original_pack);
		
		if (len_of_original_pack<0) {
			mydebug("len_of_original_pack<0");
			is_invalid=true;
			return;
		}
		
		int end_of_header=5;
		while(true) {
			if (buf[end_of_header]==0) break;
			end_of_header++;
		}
		
		byte_part_for_header=new byte[end_of_header+1];
		System.arraycopy(buf, 0, byte_part_for_header, 0, end_of_header+1);
		
		if (is_debug)  {
			mydebug("byte_part_for_header:"+byte_part_for_header.length);
			printByteArray(byte_part_for_header, byte_part_for_header.length);
		}
		
		int start_of_statement=end_of_header+1;
		if (is_debug)  
			mydebug("start_of_statement:"+start_of_statement);
		
		
		int pos_end_of_statement=ddmLib.IndexOfByteArray(buf, start_of_statement, len, ZER0_BYTE_ARR);
		
		
		
		if (pos_end_of_statement==-1) {
			is_invalid=true;
			mydebug("pos_end_of_statement not found.");
			return;
		}
		

		len_of_original_stmt=pos_end_of_statement-start_of_statement;
		
		if (is_debug) mydebug("len_of_statement_bytes:"+len_of_original_stmt);
		try {
			byte_part_for_statement_string=new byte[len_of_original_stmt];
			System.arraycopy(buf, start_of_statement, byte_part_for_statement_string, 0, len_of_original_stmt);
			sql_statement=new String(byte_part_for_statement_string, 0, byte_part_for_statement_string.length, Charset.forName(charset));
			if (is_debug) 
				mydebug("SQL Statement extracted : "+sql_statement);
			
		} catch(Exception e) {
			is_invalid=true;
			mylog("Exception@compile:"+genLib.getStackTraceAsStringBuilder(e).toString());
			return;
		}
		
		
		int len_after_statement=len-pos_end_of_statement;
		
		byte_part_after_statement_string=new byte[len_after_statement];

		
		try {
			byte_part_after_statement_string=new byte[len_after_statement];
			System.arraycopy(buf, pos_end_of_statement, byte_part_after_statement_string, 0, len_after_statement);
			if (is_debug)  {
				mydebug("byte_part_after_statement_string :"+len_after_statement);
				printByteArray(byte_part_after_statement_string, len_after_statement);
			}
		} catch(Exception e) {
			is_invalid=true;
			mylog("Exception@compile:"+genLib.getStackTraceAsStringBuilder(e).toString());
			return;
		}
		
		
		
		
		
	}
	
	
	//---------------------------------------------------------------------------------------------
	public void setStatement(String new_statement) {
		sql_statement=new_statement;
	}
	
	//-------------------------------------------------------------------------------------------------------------
	public void rePack(int maxPackageSize, ArrayList<byte[]> packArr, ArrayList<Integer> sizeArr) {
		
		if (is_invalid) return;
		
		int len_of_bytes_for_statement=0;
		try {
			byte_part_for_statement_string=sql_statement.getBytes(Charset.forName(charset));
			len_of_bytes_for_statement=byte_part_for_statement_string.length;
			if (is_debug)  {
				mydebug("bytes_for_statement :"+len_of_bytes_for_statement);
				printByteArray(byte_part_for_statement_string, len_of_bytes_for_statement);
			}
		} catch(Exception e) {
			mylog("Exception@rePack:"+genLib.getStackTraceAsStringBuilder(e).toString());
			return;
		}
		

		int pack_len=len_of_original_pack+(len_of_bytes_for_statement-len_of_original_stmt);
		
		int buf_len=byte_part_for_header.length+len_of_bytes_for_statement+byte_part_after_statement_string.length;
		byte[] bytesForPackLen=ddmLib.convertInteger2ByteArray4Bytes(pack_len, ByteOrder.BIG_ENDIAN);
		
		byte[] buf=new byte[buf_len];
		
		//directly copy the original header first
		System.arraycopy(byte_part_for_header, 0, buf, 0, byte_part_for_header.length);
		//set the new pack length
		System.arraycopy(bytesForPackLen, 0, buf, 1, 4);
		
		int cursor=byte_part_for_header.length;

		
		
		try {
			System.arraycopy(byte_part_for_statement_string, 0, buf, cursor, len_of_bytes_for_statement);
			cursor+=len_of_bytes_for_statement;
			
			System.arraycopy(byte_part_after_statement_string, 0, buf, cursor, byte_part_after_statement_string.length);
			cursor+=byte_part_after_statement_string.length;
			
			packArr.add(buf);
			sizeArr.add(cursor);
		} catch(Exception e) {
			mylog("Exception@rePack:"+genLib.getStackTraceAsStringBuilder(e).toString());
			return;
		}
		
		
		
	}


	

}
