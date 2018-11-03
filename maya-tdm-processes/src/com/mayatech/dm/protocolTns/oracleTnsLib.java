package com.mayatech.dm.protocolTns;

import java.nio.ByteOrder;

import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmLib;

public final class oracleTnsLib {
	
	static final byte byte_single_254=(byte) 254;
	static final byte byte_single_255=(byte) 255;
	static final byte byte_single_64=(byte) 64;
	
	
	static final byte[] byte_final_3_94=ddmLib.string2ByteArr("[3][94]");
	static final byte[] byte_arr_13=ddmLib.string2ByteArr("[13]");
	
	public static final int LEN_TYPE_NONE=0;
	public static final int LEN_TYPE_BYTE_LENGTH=1; //[1][1][18]
	public static final int LEN_TYPE_BYTE_LENGTH_WITHOUT_1=2; //[1][18]
	public static final int LEN_TYPE_BYTE_ORDERED_4_BYTES=4; //[149][20][0][0]

	
	
	static final byte[] byte_part_before_statement_for_20120=ddmLib.string2ByteArr("[0][0][0][0][0][0][0][0][0][0][0][1]");
	static final byte[] byte_part_before_statement_for_20120_v2=ddmLib.string2ByteArr("[0][0][0][0][0][0][0][0][0][1]");

	static final byte[] byte_array_zero=ddmLib.string2ByteArr("[0]");
	static final byte[] byte_array_one=ddmLib.string2ByteArr("[1]");
	
	
	public static final int CHUNK_STYLE_NONE=0; //no chunk
	public static final int CHUNK_STYLE_CLASSIC=1; //[254]@select ...
	public static final int CHUNK_STYLE_4BYTES=2; //[254][149][20][0][0]select....
	public static final int CHUNK_STYLE_BYTELEN=3; //[254][2][3][31]select....
	
	//--------------------------------------------------------------------------------------------
	static final int goRightUntil(byte[] buf, int startIndex, int EndIndex, byte[] searchByteArr) {
		int cursor=startIndex;
		while(true) {
			int pos=ddmLib.IndexOfByteArray(buf, cursor, EndIndex, searchByteArr);
			if (pos==cursor) return cursor;
			cursor++;
			if (cursor>=EndIndex) break;
		}
		return -1;
	}
	//--------------------------------------------------------------------------------------------
	static final int goLeftUntil(byte[] buf, int startIndex, int EndIndex, byte[] searchByteArr) {
		int cursor=startIndex;
		int searchByteLen=searchByteArr.length;

		while(true) {

			int pos=ddmLib.IndexOfByteArray(buf, cursor, cursor+searchByteLen, searchByteArr);

			if (pos==cursor) return cursor;
			cursor--;
			if (cursor<=EndIndex) break;
		}

		return -1;
	}
	//--------------------------------------------------------------------------------------------
	static final int goRightWhile(byte[] buf, int startIndex, int EndIndex, byte[] searchByteArr) {
		int cursor=startIndex;
		
		while(true) {
			int pos=ddmLib.IndexOfByteArray(buf, cursor, EndIndex, searchByteArr);
			
			if (pos!=cursor) return cursor;
			cursor++;
			if (cursor>=EndIndex) break;
		}
		return -1;
	}
	
	//-------------------------------------------------------------------------------------------
	public static int getLengthValueByType(byte[] buf, int startIndex, int type) {
		switch(type) {
			case  LEN_TYPE_BYTE_LENGTH: return getLength_LEN_TYPE_BYTE_LENGTH(buf,startIndex); 
			case  LEN_TYPE_BYTE_LENGTH_WITHOUT_1: return getLength_LEN_TYPE_BYTE_LENGTH_WITHOUT_1(buf,startIndex); 
			case  LEN_TYPE_BYTE_ORDERED_4_BYTES: return getLength_LEN_TYPE_BYTE_ORDERED_4_BYTES(buf,startIndex); 


			default : return 0;
		}
	}
	
	//-------------------------------------------------------------------------------------------
	static int getLength_LEN_TYPE_BYTE_LENGTH(byte[] buf, int startIndex) {
		return ddmLib.getByteSizedLength(buf,startIndex);
	}
	
	//-------------------------------------------------------------------------------------------
	static int getLength_LEN_TYPE_BYTE_LENGTH_WITHOUT_1(byte[] buf, int startIndex) {
		return ddmLib.getByteSizedLengthV2(buf,startIndex);
	}
	//-------------------------------------------------------------------------------------------
	static int getLength_LEN_TYPE_BYTE_ORDERED_4_BYTES(byte[] buf, int startIndex) {

		return ddmLib.contertByteArray2Integer(buf,startIndex,4,ByteOrder.LITTLE_ENDIAN);
	}
	//-------------------------------------------------------------------------------------------
	static int getLength_LEN_TYPE_BYTE_ORDERED_8_BYTES(byte[] buf, int startIndex) {
		return ddmLib.contertByteArray2Integer(buf,startIndex,8,ByteOrder.LITTLE_ENDIAN);
	}
	
	
	
	//-------------------------------------------------------------------------------------------
	static byte[] getLengthBytesByType(int value, int type) {
		switch(type) {
			case  LEN_TYPE_BYTE_LENGTH: return getLengthBytes_LEN_TYPE_BYTE_LENGTH(value); 
			case  LEN_TYPE_BYTE_LENGTH_WITHOUT_1: return getLengthBytes_BYTE_LENGTH_WITHOUT_1(value); 
			case  LEN_TYPE_BYTE_ORDERED_4_BYTES: return getLengthBytes_LEN_TYPE_BYTE_ORDERED_4_BYTES(value); 


			default : return new byte[0];
		}
	}
	
	//--------------------------------------------------------------------------------------------
	static byte[] getLengthBytes_LEN_TYPE_BYTE_LENGTH(int value) {
		return ddmLib.convertInteger2ByteSizedBytes(value);
	}
	
	//--------------------------------------------------------------------------------------------
	static byte[] getLengthBytes_BYTE_LENGTH_WITHOUT_1(int value) {
		return ddmLib.convertInteger2ByteSizedBytesV2(value);
	}
	
	//--------------------------------------------------------------------------------------------
	static byte[] getLengthBytes_LEN_TYPE_BYTE_ORDERED_4_BYTES(int value) {
		return ddmLib.convertInteger2ByteArray4Bytes(value, ByteOrder.LITTLE_ENDIAN);
	}
	
	//--------------------------------------------------------------------------------------------
	static byte[] getLengthBytes_LEN_TYPE_BYTE_ORDERED_8_BYTES(int value) {
		return ddmLib.convertInteger2ByteArray8Bytes(value, ByteOrder.LITTLE_ENDIAN);
	}
	
	
	//*****************************************************************************************
	public static byte[] makeChunkedBytes(byte[] buf, int len, int chunk_size) {
		byte[] tmpArr=new byte[len*2];
		int cursor=0;
		int chunk_cursor=0;
		int remaining=len;
		byte[] bytesForChunk=new byte[1];
		byte[] bytesForZero=new byte[1];
		
		
		bytesForChunk[0]=(byte) 254;
		System.arraycopy(bytesForChunk, 0, tmpArr, cursor, 1);
		cursor+=1;
		
		while(true) {
			int part_len=chunk_size;
			if (part_len>remaining) part_len=remaining;
			
			bytesForChunk[0]=(byte) part_len;
			System.arraycopy(bytesForChunk, 0, tmpArr, cursor, 1);
			cursor+=1;
			
			System.arraycopy(buf, chunk_cursor, tmpArr, cursor, part_len);
			cursor+=part_len;
			chunk_cursor+=part_len;
			
			remaining-=part_len;
			if (remaining==0) break;
		}
		
		bytesForZero[0]=(byte) 0;
		System.arraycopy(bytesForZero, 0, tmpArr, cursor, 1);
		cursor+=1;
		
		byte[] retArr=new byte[cursor];
		System.arraycopy(tmpArr, 0, retArr, 0, cursor);
		return retArr;
	}
	
	//------------------------------------------------------------------------------------
	
	
	static final String[] chunkCheckParams=new String[]{"AUTH_ALTER_SESSION",""};
	public static void discoverChunkConfiguration(ddmClient ddmClient, byte[] buf, int len) {
		
		
		if (ddmClient.ORADISC_is_chunk_discovered) return;
		
		
		
		if (buf[10]!=(byte) 3 && buf[11]!=(byte) 's' && buf[11]!=(byte) 'v' ) {
			return;
		}
		
		ddmClient.mydebug("discoverChunkConfiguration");
		ddmClient.printByteArray(buf, len);
		
		//AUTH_ALTER_SESSION[232][1][0][0]		[254]@ALTER SESSION SET NLS_LANGUAGE= 'TURKISH' NLS_TERRITORY= 'TURKEY@' NLS_CURRENCY= 'TL' NLS_ISO_CURRENCY= 'TURKEY' NLS_NUMERIC_CHAR@ACTERS= ',.' NLS_CALENDAR= 'GREGORIAN' NLS_DATE_FORMAT= 'DD/MM/R@RRR' NLS_DATE_LANGUAGE= 'TURKISH' NLS_SORT= 'TURKISH' TIME_ZONE=@ '+03:00' NLS_COMP= 'BINARY' NLS_DUAL_CURRENCY= 'YTL' NLS_TIME_F@ORMAT= 'HH24:MI:SSXFF' NLS_TIMESTAMP_FORMAT= 'DD/MM/RRRR HH24:MI@:SSXFF' NLS_TIME_TZ_FORMAT= 'HH24:MI:SSXFF TZR' NLS_TIMESTAMP_TZ(_FORMAT= 'DD/MM/RRRR HH24:MI:SSXFF TZR'[0][0][0][0][0][0][23][0][0][0][23]AUTH_LOGICAL_SESSION_ID [0][0][0] 92935111803C482B99062D21E3E150F2[0][0][0][0][16][0][0][0][16]AUTH_FAILOVER_ID[0][0][0][0][0][0][0][0] 
		//AUTH_ALTER_SESSION[233][1][0][0]		[254][233][1][0][0]ALTER SESSION SET NLS_LANGUAGE= 'AMERICAN' NLS_TERRITORY= 'AMERICA' NLS_CURRENCY= '$' NLS_ISO_CURRENCY= 'AMERICA' NLS_NUMERIC_CHARACTERS= '.,' NLS_CALENDAR= 'GREGORIAN' NLS_DATE_FORMAT= 'DD-MON-RR' NLS_DATE_LANGUAGE= 'AMERICAN' NLS_SORT= 'BINARY' TIME_ZONE= '+03:00' NLS_COMP= 'BINARY' NLS_DUAL_CURRENCY= '$' NLS_TIME_FORMAT= 'HH.MI.SSXFF AM' NLS_TIMESTAMP_FORMAT= 'DD-MON-RR HH.MI.SSXFF AM' NLS_TIME_TZ_FORMAT= 'HH.MI.SSXFF AM TZR' NLS_TIMESTAMP_TZ_FORMAT= 'DD-MON-RR HH.MI.SSXFF AM TZR'[0][0][0][0][0][0][0][0][0][23][0][0][0][23]AUTH_LOGICAL_SESSION_ID [0][0][0] 75F0F3AB938F4228BEA93B7C38B48D2B[0][0][0][0][16][0][0][0][16]AUTH_FAILOVER_ID[0][0][0][0][0][0][0][0] 
		//AUTH_ALTER_SESSION[2][1][230]			[254][2][1][230]ALTER SESSION SET NLS_LANGUAGE= 'TURKISH' NLS_TERRITORY= 'TURKEY' NLS_CURRENCY= '?' NLS_ISO_CURRENCY= 'TURKEY' NLS_NUMERIC_CHARACTERS= ',.' NLS_CALENDAR= 'GREGORIAN' NLS_DATE_FORMAT= 'DD/MM/RRRR' NLS_DATE_LANGUAGE= 'TURKISH' NLS_SORT= 'TURKISH' TIME_ZONE= '+03:00' NLS_COMP= 'BINARY' NLS_DUAL_CURRENCY= 'TL' NLS_TIME_FORMAT= 'HH24:MI:SSXFF' NLS_TIMESTAMP_FORMAT= 'DD/MM/RRRR HH24:MI:SSXFF' NLS_TIME_TZ_FORMAT= 'HH24:MI:SSXFF TZR' NLS_TIMESTAMP_TZ_FORMAT= 'DD/MM/RRRR HH24:MI:SSXFF TZR'[0][0][0][1][23][23]AUTH_LOGICAL_SESSION_ID[1]  D1D450D7C4974E47AE6A7A7D78D6BFDB[0][1][16][16]AUTH_FAILOVER_ID[0][0]

		
		for (int p=0;p<chunkCheckParams.length;p++) {
			byte[] paramNameBytes=chunkCheckParams[p].getBytes();
			
			
			ddmClient.mydebug("checking : "+chunkCheckParams[p]);
			
			int posParamName=ddmLib.IndexOfByteArray(buf, 0, len, paramNameBytes);
			
			if (posParamName==-1) continue;
			
			posParamName+=paramNameBytes.length;
			
			int posFirst254=ddmLib.IndexOfByteArray(buf, posParamName, posParamName+10, new byte[]{byte_single_254});
			ddmClient.mydebug("posFirst254 : "+posFirst254);
			
			if (posFirst254==-1) continue;
			
			if (ddmLib.byte2UnsignedInt(buf[posFirst254+1])==255) {
				ddmClient.ORADISC_chunk_style=CHUNK_STYLE_CLASSIC;
				ddmClient.ORADISC_chunk_limit=255;
				ddmClient.ORADISC_is_chunk_discovered=true;
				break;
			}
			if (ddmLib.byte2UnsignedInt(buf[posFirst254+1])==64) {
				ddmClient.ORADISC_chunk_style=CHUNK_STYLE_CLASSIC;
				ddmClient.ORADISC_chunk_limit=64;
				ddmClient.ORADISC_is_chunk_discovered=true;
				break;
			}
			
			if (ddmLib.byte2UnsignedInt(buf[posFirst254+4])==0) {
				ddmClient.ORADISC_chunk_style=CHUNK_STYLE_4BYTES;
				ddmClient.ORADISC_chunk_limit=255;
				ddmClient.ORADISC_is_chunk_discovered=true;
				break;
			}
			
			ddmClient.ORADISC_chunk_style=CHUNK_STYLE_BYTELEN;
			ddmClient.ORADISC_chunk_limit=255;
			ddmClient.ORADISC_is_chunk_discovered=true;
			break;
			
		}
		
		if (!ddmClient.ORADISC_is_chunk_discovered) 	
			ddmClient.mydebug("Chunk configuration is not discovered.");
		
		
	}
	//------------------------------------------------------------------------------------
	public static final int ACT_SAVE=0;
	public static final int ACT_LOAD=1;
	
	static final String[] sess_keys=new String[]{"OSUSER","MACHINE","TERMINAL","PROGRAM","MODULE","CLIENT_VERSION","CLIENT_DRIVER","CLIENT_OCI_LIBRARY"};
	
	public static void loadSaveOracleTnsChunkConf(ddmClient ddmClient, int action) {
		String hm_base="";
		for (int s=0;s<sess_keys.length;s++) 
			hm_base=hm_base+sess_keys[s]+"="+ddmLib.getSessionKey(ddmClient,sess_keys[s])+",";
		
		
		ddmLib.printSessionInfo(ddmClient);
		
		
		if (action==ACT_LOAD)  {
			
			ddmClient.mydebug("loadSaveOracleTnsChunkConf:LOAD");
			ddmClient.mydebug("hm_key:"+hm_base);
			
			if (ddmClient.ORADISC_is_chunk_discovered) {
				ddmClient.mydebug("already discovered. Not loading from cache. Updating cache...");
				loadSaveOracleTnsChunkConf(ddmClient, ACT_SAVE);
				return; 
			}
			
			if (!ddmClient.dm.hmOracleChunkConfiguration.containsKey("ORADISC_chunk_style"+hm_base)) {
				ddmClient.mydebug("No chunk info found from cache...");
				return;
			}
			
			
			
			
			
			ddmClient.ORADISC_chunk_style=(int) ddmClient.dm.hmOracleChunkConfiguration.get("ORADISC_chunk_style"+hm_base);
			ddmClient.ORADISC_chunk_limit=(int) ddmClient.dm.hmOracleChunkConfiguration.get("ORADISC_chunk_limit"+hm_base);
			ddmClient.ORADISC_is_chunk_discovered=true;
			
			ddmClient.mydebug("loaded ORADISC_chunk_style:"+ddmClient.ORADISC_chunk_style);
			ddmClient.mydebug("loaded ORADISC_chunk_limit:"+ddmClient.ORADISC_chunk_limit);
		} 

		
		if (action==ACT_SAVE)  {
			ddmClient.mydebug("loadSaveOracleTnsChunkConf:SAVE");
			ddmClient.mydebug("hm_key:"+hm_base);
			ddmClient.mydebug("saving ORADISC_chunk_style:"+ddmClient.ORADISC_chunk_style);
			ddmClient.mydebug("saving ORADISC_chunk_limit:"+ddmClient.ORADISC_chunk_limit);

			ddmClient.dm.hmOracleChunkConfiguration.put("ORADISC_chunk_style"+hm_base,ddmClient.ORADISC_chunk_style);
			ddmClient.dm.hmOracleChunkConfiguration.put("ORADISC_chunk_limit"+hm_base,ddmClient.ORADISC_chunk_limit);
		}  
	}
}
