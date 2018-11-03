package com.mayatech.dm.protocolTds;

import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;

public final  class tdsMicrosoftSqlLib {

	static final int tds8SpNames_NONE=0; 

	static final int tds8SpNames_sp_cursor=1; 
	static final int tds8SpNames_sp_cursoropen=2; 
	static final int tds8SpNames_sp_cursorprepare=3; 
	static final int tds8SpNames_sp_cursorexecute=4; 
	static final int tds8SpNames_sp_cursorprepexec=5; 
	static final int tds8SpNames_sp_cursorunprepare=6; 
	static final int tds8SpNames_sp_cursorfetch=7; 
	static final int tds8SpNames_sp_cursoroption=8; 
	static final int tds8SpNames_sp_cursorclose=9; 
	static final int tds8SpNames_sp_executesql=10; 
	static final int tds8SpNames_sp_prepare=11; 
	static final int tds8SpNames_sp_execute=12; 
	static final int tds8SpNames_sp_prepexec=13; 
	static final int tds8SpNames_sp_prepexecrpc=14; 
	static final int tds8SpNames_sp_unprepare=15; 
	
	
	static final int TDS_PACKAGE_TYPE_SQL_BATCH_REQUEST=1;
	static final int TDS_PACKAGE_TYPE_RPC_REQUEST=3;
	
	static final String SP_NAME_NONE="NONE";
	
	static boolean isRewritable(int shortcutid) {
		if (shortcutid==tds8SpNames_sp_prepare) return true;
		if (shortcutid==tds8SpNames_sp_cursorprepare) return true;
		if (shortcutid==tds8SpNames_sp_executesql) return true;
		if (shortcutid==tds8SpNames_sp_prepexecrpc) return true;
		if (shortcutid==tds8SpNames_sp_cursorprepexec) return true;
		return false;
	}
	//---------------------------------------------------------------------
	static String getSpName(int spNameId) {
		switch (spNameId) {
			case tds8SpNames_sp_cursor : 			return "sp_cursor";
			case tds8SpNames_sp_cursoropen : 		return "sp_cursoropen";
			case tds8SpNames_sp_cursorprepare :		return "sp_cursorprepare";
			case tds8SpNames_sp_cursorexecute : 	return "sp_cursorexecute";
			case tds8SpNames_sp_cursorprepexec : 	return "sp_cursorprepexec";
			case tds8SpNames_sp_cursorunprepare : 	return "sp_cursorunprepare";
			case tds8SpNames_sp_cursorfetch : 		return "sp_cursorfetch";
			case tds8SpNames_sp_cursoroption : 		return "sp_cursoroption";
			case tds8SpNames_sp_cursorclose :		return "sp_cursorclose";
			case tds8SpNames_sp_executesql : 		return "sp_executesql";
			case tds8SpNames_sp_prepare : 			return "sp_prepare";
			case tds8SpNames_sp_execute : 			return "sp_execute";
			case tds8SpNames_sp_prepexec : 			return "sp_prepexec";
			case tds8SpNames_sp_prepexecrpc : 		return "sp_prepexecrpc";
			case tds8SpNames_sp_unprepare : 		return "sp_unprepare";
			
			default : return SP_NAME_NONE;
		}
	}
	
	
	
	//********************************************************
	public static int readSwappedUnsignedShort(final byte[] data, final int offset) {
		return ( ( ( data[ offset + 0 ] & 0xff ) << 0 ) +		 ( ( data[ offset + 1 ] & 0xff ) << 8 ) );
		}
	//---------------------------------------------------------------------------------------------
	public static void writeSwappedShort(final byte[] data, final int offset, final short value) {
		 data[ offset + 0 ] = (byte)( ( value >> 0 ) & 0xff );
		 data[ offset + 1 ] = (byte)( ( value >> 8 ) & 0xff );
	}
	//---------------------------------------------------------------------------------------------
	public static int readSwappedInteger(final byte[] data, final int offset) {
		 return ( ( ( data[ offset + 0 ] & 0xff ) << 0 ) +
				 ( ( data[ offset + 1 ] & 0xff ) << 8 ) +
				 ( ( data[ offset + 2 ] & 0xff ) << 16 ) +
				 ( ( data[ offset + 3 ] & 0xff ) << 24 ) );
	}
	//---------------------------------------------------------------------------------------------
	public  static void writeSwappedInteger(final byte[] data, final int offset, final int value) {
		 data[ offset + 0 ] = (byte)( ( value >> 0 ) & 0xff );
		 data[ offset + 1 ] = (byte)( ( value >> 8 ) & 0xff );
		 data[ offset + 2 ] = (byte)( ( value >> 16 ) & 0xff );
		 data[ offset + 3 ] = (byte)( ( value >> 24 ) & 0xff );
	 }
	
	 //----------------------------------------------------------
	 public static int read(tdsMicrosoftSqlPackage tdspack, byte[] buf, int offset){
	 			tdspack.readerCursor+=1;
			    return buf[offset] & 0xFF;
			  }
	 //--------------------------------------------------------
	 public static short readShort(tdsMicrosoftSqlPackage tdspack, byte[] buf, int offset)  {
			    int b1 = read(tdspack, buf, offset+0);
			    int b2 = read(tdspack, buf, offset+1);
			    
			    return (short)(b1 | b2 << 8);
			  }
	 //--------------------------------------------------------
	 public static int readInt(tdsMicrosoftSqlPackage tdspack, byte[] buf, int offset)			  {
			    int b1 = read(tdspack, buf, offset+0);
			    int b2 = read(tdspack, buf, offset+1) << 8;
			    int b3 = read(tdspack, buf, offset+2) << 16;
			    int b4 = read(tdspack, buf, offset+3) << 24;
			    
			    return b4 | b3 | b2 | b1;
			  }
	 //--------------------------------------------------------
	 public static long readLong(tdsMicrosoftSqlPackage tdspack, byte[] buf, int offset)	{
			    long b1 = read(tdspack, buf, offset+0);
			    long b2 = read(tdspack, buf, offset+1) << 8;
			    long b3 = read(tdspack, buf, offset+2) << 16;
			    long b4 = read(tdspack, buf, offset+3) << 24;
			    long b5 = read(tdspack, buf, offset+4) << 32;
			    long b6 = read(tdspack, buf, offset+5) << 40;
			    long b7 = read(tdspack, buf, offset+6) << 48;
			    long b8 = read(tdspack, buf, offset+7) << 56;
			    
			    
			    return b1 | b2 | b3 | b4 | b5 | b6 | b7 | b8;
			  }
	 //--------------------------------------------------------
	 static BigDecimal readUnsignedLong(tdsMicrosoftSqlPackage tdspack, byte[] buf, int offset)	  {
			   
		 		int b1 = read(tdspack, buf, offset+0) & 0xFF;
			    long b2 = read(tdspack, buf, offset+0);
			    long b3 = read(tdspack, buf, offset+0) << 8;
			    long b4 = read(tdspack, buf, offset+0) << 16;
			    long b5 = read(tdspack, buf, offset+0) << 24;
			    long b6 = read(tdspack, buf, offset+0) << 32;
			    long b7 = read(tdspack, buf, offset+0) << 40;
			    long b8 = read(tdspack, buf, offset+0) << 48;
			    
			    
			    return new BigDecimal(Long.toString(b2 | b3 | b4 | b5 | b6 | b7 | b8)).multiply(new BigDecimal(256)).add(new BigDecimal(b1));
			  }
	 //--------------------------------------------------------

	
	 
	 static String readString(tdsMicrosoftSqlPackage tdspack, byte[] buf, int offset, int len, String  charsetName)			  {

		 	String ret1=null;
		 
			    byte[] bytes = new byte[len];
			    
			    System.arraycopy(buf, offset, bytes, 0, len);
			    
			    try {ret1=new String(bytes, 0, len, charsetName);}
			    catch (UnsupportedEncodingException e) {}
			    
			    
			    tdspack.readerCursor+=len;
			    
			    return ret1;
			  }
	 //--------------------------------------------------------

	 static String readNonUnicodeString(tdsMicrosoftSqlPackage tdspack, byte[] buf, int offset, int len, String  charsetName)  {
			    return readString(tdspack, buf, offset, len, charsetName);
			  }
	
 

}
