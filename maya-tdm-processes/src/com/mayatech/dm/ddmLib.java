package com.mayatech.dm;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.DataFormatException;
import java.util.zip.Deflater;
import java.util.zip.Inflater;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

import org.apache.commons.codec.binary.Base64;
import org.bson.BSONObject;

import com.mayatech.baseLibs.genLib;
import com.mayatech.dm.dmOracleParser.oracleParser;
import com.mayatech.dm.dmOracleParser.oracleSTMT;
import com.mayatech.dm.dmOracleParser.oracleSTMTColumn;
import com.mayatech.dm.dmOracleParser.oracleSTMTExpr;
import com.mayatech.dm.dmOracleParser.oracleSTMTSelect;
import com.mayatech.dm.dmPostgreSQLParser.postgreSTMTColumn;

public final  class ddmLib {
	


	
	//---------------------------------------------------------------------------
	
	static void mylog(String logstr) {
		System.out.println(logstr);

	}
	
	static void mydebug(String logstr) {
		
		//System.out.println(logstr);
		
	}
	
	//---------------------------------------------------------------------------
	public static void printSessionInfo(ddmClient packageObj) {
		if (packageObj.dm.is_debug || packageObj.is_tracing ) {
			for (int i=0;i< packageObj.sessionInfoForConnArr.size();i++) {
				packageObj.mydebug(packageObj.sessionInfoForConnArr.get(i)[0]+"={"+packageObj.sessionInfoForConnArr.get(i)[1]+"}");
			}
			packageObj.mydebug("\n");
		}
		
	}
	
	//--------------------------------------------------------------------
	static void saveChangedSessionVar(ddmClient ddmClient, String paaram_name, String current_param_value) {
		
		for (int i=0;i<ddmClient.sessionInfoForConnArrChanged.size();i++) {
			if (ddmClient.sessionInfoForConnArrChanged.get(i)[0].equals(paaram_name)) return;
		}
		
		ddmClient.sessionInfoForConnArrChanged.add(new String[]{paaram_name,current_param_value});
		
	}

	//*********************************************************************************
	static ArrayList<String[]> getSessionVariablesAsArrayList(String session_info) {
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		String[] lines=session_info.split("\n");
		
		
		for (int s=0;s<lines.length;s++) {
			try {
				String a_line=lines[s];
				if (a_line.trim().length()==0) continue;
				int ind=a_line.indexOf("=");
				if (ind==-1) continue;
				String key=a_line.substring(0,ind);
				String val=a_line.substring(ind+1);
				
				ret1.add(new String[]{key,val});

				
			} catch(Exception e) {
				e.printStackTrace();
			}
			
			
			
		}
		
		return ret1;
	}
	//---------------------------------------------------------------------
	public static byte[] convertInteger2ByteSizedBytes(int int_val)	 {
		byte[] tmp=null;
		
		int cursor=0;
		
		//length of length of length
		
		
		
		if (int_val<256) {
			tmp=new byte[3];
			System.arraycopy(ddmLib.ORCL_SQLpackageSingleByteSqlLength, 0, tmp, cursor, 1);
			cursor+=1;
			System.arraycopy(ddmLib.ORCL_SQLpackageSingleByteSqlLength, 0, tmp, cursor, 1);
			cursor+=1;
			byte[] sqlLenByte=new byte[]{ (byte) int_val };
			System.arraycopy(sqlLenByte, 0, tmp, cursor, 1);
			cursor+=1;
		}
		else if (int_val<256*256) {
			tmp=new byte[4];
			System.arraycopy(ddmLib.ORCL_SQLpackageSingleByteSqlLength, 0, tmp, cursor, 1);
			cursor+=1;
			System.arraycopy(ddmLib.ORCL_SQLpackageDoubleByteSqlLength, 0, tmp, cursor, 1);
			cursor+=1;
			byte[] sqlLenByte=ddmLib.makeLengthFor2Bytes(int_val);
			System.arraycopy(sqlLenByte, 0, tmp, cursor, 2);
			cursor+=2;
		}	
		else {



			tmp=new byte[5];
			System.arraycopy(ddmLib.ORCL_SQLpackageSingleByteSqlLength, 0, tmp, cursor, 1);
			cursor+=1;
			System.arraycopy(ddmLib.ORCL_SQLpackageTripleByteSqlLength, 0, tmp, cursor, 1);
			
			cursor+=1;
			byte[] sqlLenByte=ddmLib.makeLengthFor3Bytes(int_val);
			System.arraycopy(sqlLenByte, 0, tmp, cursor, 3);
			cursor+=3;
		}
		
		return tmp;
		
	}
	
	//----------------------------------------------------------

	
	public static byte[] convertInteger2ByteSizedBytesV3(int int_val)	 {
		byte[] tmp=null;
		
		int cursor=0;
		
		if (int_val<256) {
			//tmp=new byte[2];
			//System.arraycopy(ddmLib.ORCL_SQLpackageSingleByteSqlLength, 0, tmp, cursor, 1);
			//cursor+=1;
			tmp=new byte[1];
			byte[] sqlLenByte=new byte[]{ (byte) int_val };
			System.arraycopy(sqlLenByte, 0, tmp, cursor, 1);
			cursor+=1;
		}
		else if (int_val<256*256) {
			tmp=new byte[3];
			System.arraycopy(ddmLib.ORCL_SQLpackageDoubleByteSqlLength, 0, tmp, cursor, 1);
			cursor+=1;
			byte[] sqlLenByte=ddmLib.makeLengthFor2Bytes(int_val);
			System.arraycopy(sqlLenByte, 0, tmp, cursor, 2);
			cursor+=2;
		}	
		else {
			tmp=new byte[4];
			System.arraycopy(ddmLib.ORCL_SQLpackageTripleByteSqlLength, 0, tmp, cursor, 1);
			cursor+=1;
			byte[] sqlLenByte=ddmLib.makeLengthFor3Bytes(int_val);
			System.arraycopy(sqlLenByte, 0, tmp, cursor, 3);
			cursor+=3;
		}
		
		return tmp;
		
	}
	//----------------------------------------------------------
	public static byte[] convertInteger2ByteSizedBytesV2(int int_val)	 {
		byte[] tmp=null;
		
		int cursor=0;
		
		if (int_val<256) {
			tmp=new byte[2];
			System.arraycopy(ddmLib.ORCL_SQLpackageSingleByteSqlLength, 0, tmp, cursor, 1);
			cursor+=1;
			byte[] sqlLenByte=new byte[]{ (byte) int_val };
			System.arraycopy(sqlLenByte, 0, tmp, cursor, 1);
			cursor+=1;
		}
		else if (int_val<256*256) {
			tmp=new byte[3];
			System.arraycopy(ddmLib.ORCL_SQLpackageDoubleByteSqlLength, 0, tmp, cursor, 1);
			cursor+=1;
			byte[] sqlLenByte=ddmLib.makeLengthFor2Bytes(int_val);
			System.arraycopy(sqlLenByte, 0, tmp, cursor, 2);
			cursor+=2;
		}	
		else {
			tmp=new byte[4];
			System.arraycopy(ddmLib.ORCL_SQLpackageTripleByteSqlLength, 0, tmp, cursor, 1);
			cursor+=1;
			
		}
		
		return tmp;
		
	}
	
	//----------------------------------------------------------------------------------
	public static int contertByteArray2Integer(byte[] buf, int start, int len, ByteOrder byteorder) {
		
		byte[] intbuf=new byte[]{ (byte) 0x0, (byte)  0x0, (byte)  0x0, (byte)  0x0};
		
		//In big endian, you store the most significant byte in the smallest address. 
		//In little endian, you store the least significant byte in the smallest address.
		int cursor=0;
		if (byteorder==ByteOrder.BIG_ENDIAN)  cursor=(intbuf.length-len);
	
		for (int i=start;i<start+len;i++) {
			intbuf[cursor]=buf[i];
			cursor++;
		}
		
		int ret1=-1;
		
		try {
			ret1 = ByteBuffer.wrap(intbuf).order(byteorder).getInt();
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		
		
		
		return ret1;
	}
	
	
	
	//---------------------------------------------------------------------------
	
	public static byte[] convertInteger2ByteArray4Bytes(int numInt, ByteOrder byteorder) {
		
		
		byte[] ret1 =new byte[]{ (byte) 0x0, (byte)  0x0, (byte)  0x0,  (byte)  0x0};
		
		//In big endian, you store the most significant byte in the smallest address. 
		//In little endian, you store the least significant byte in the smallest address.
		
		try {
			ByteBuffer buffer = ByteBuffer.allocate(4);
			buffer.order(byteorder);
			 buffer.putInt(numInt);
			 //buffer.flip();
			 
			 return buffer.array();
		} catch(Exception e) {
			e.printStackTrace();
			return ret1;
		}
		
		
		
	}
	
	//---------------------------------------------------------------------------
	
	public static byte[] convertInteger2ByteArray8Bytes(int numInt, ByteOrder byteorder) {
		
		
		byte[] ret1 =new byte[]{ (byte) 0x0, (byte)  0x0, (byte)  0x0, (byte)  0x0, (byte) 0x0, (byte)  0x0, (byte)  0x0, (byte)  0x0};
		
		//In big endian, you store the most significant byte in the smallest address. 
		//In little endian, you store the least significant byte in the smallest address.
		
		try {
			ByteBuffer buffer = ByteBuffer.allocate(8);
			buffer.order(byteorder);
			 buffer.putInt(numInt);
			 //buffer.flip();
			 
			 return buffer.array();
		} catch(Exception e) {
			e.printStackTrace();
			return ret1;
		}
		
		
		
	}
	
	
	//---------------------------------------------------------------------------
	public static int getByteSizedLength(byte[] buf, int start) {
		// [1][2][17][11]  
		// 17*256 + 11 = 4363 byte dir. Uzunluk iki byte da gosterilmistir. 
		// 1: size i iceren byte lerin uzunlugunu gosteren kac byte oldugunu belirtir. Uzunluk byte inin uzunluk byte inin sayisi
		// 2: uzunluk belirten byte lerin sayisini belirtir
		// 17 , 11 : uzunluk belirten byte ler
		int cursor=start;
		int legth_of_length_of_len =	contertByteArray2Integer(buf, start , 1 , ByteOrder.BIG_ENDIAN);
		if (legth_of_length_of_len==0) legth_of_length_of_len=1;
		cursor+=1;
		int length_of_len=contertByteArray2Integer(buf, cursor , legth_of_length_of_len , ByteOrder.BIG_ENDIAN);
		cursor+=legth_of_length_of_len;
		int len=contertByteArray2Integer(buf, cursor , length_of_len , ByteOrder.BIG_ENDIAN);

		return len;
		
	}
	
	
	
	
	//---------------------------------------------------------------------------
	public static int getByteSizedLengthV2(byte[] buf, int start) {
		// [2][17][11]  
		// 17*256 + 11 = 4363 byte dir. Uzunluk iki byte da gosterilmistir. 
		// 2: uzunluk belirten byte lerin sayisini belirtir
		// 17 , 11 : uzunluk belirten byte ler
		int cursor=start;
		int legth_of_length_of_len =	1;
		int length_of_len=contertByteArray2Integer(buf, cursor , legth_of_length_of_len , ByteOrder.BIG_ENDIAN);
		cursor+=legth_of_length_of_len;
		int len=contertByteArray2Integer(buf, cursor , length_of_len , ByteOrder.BIG_ENDIAN);

		return len;
		
	}
	
	//---------------------------------------------------------------------------
	public static int IndexOfByteArray(byte[] mainByteArr, int from, int to, byte[] searchByteArr) {
		return IndexOfByteArray(mainByteArr, from, to, searchByteArr, true);
	
	}
	
	//---------------------------------------------------------------------------
	static int IndexOfByteArray(byte[] mainByteArr, int from, int to, byte[] searchByteArr, boolean case_sensitive) {
		boolean matched_all=true;
		
		try {
			for (int i=from;i<to-searchByteArr.length+1;i++) {
				 matched_all=true;
				 for (int j=0;j<searchByteArr.length;j++) {
					 if (mainByteArr[i+j]!=searchByteArr[j]) {
						 if (case_sensitive) {
							 matched_all=false;
							 break;
						 } else {
							 if (mainByteArr[i+j]!=searchByteArr[j]-32) {
								 matched_all=false;
								 break;
							 }
						 }
						
					 }
					 
				 }
				 
				 if (matched_all) return i;
			}
			
			return -1;
			
		} catch(Exception e) {
			return -1;
		}
		
	}
		
	//*********************************************

	 public static int byte2UnsignedInt(byte b) {
		    return b & 0xFF;
		  }
	 
	//*********************************************
	public static int getPackageLength(byte[] buf, int start) {
		
		if (buf[start+2]==(byte) 0x00 && buf[start+3]==(byte) 0x00) {
			try {
				int high=byte2UnsignedInt(buf[start+0]);
				int low=byte2UnsignedInt(buf[start+1]);
				return high*256+low;
			} catch(Exception e) {
				e.printStackTrace();
				return -1;
			}
		} else {
			try {
				int high=byte2UnsignedInt(buf[start+2]);
				int low=byte2UnsignedInt(buf[start+3]);
				return high*256+low;
			} catch(Exception e) {
				e.printStackTrace();
				return -1;
			}
		}
		
	}
	
	//**********************************************
	public static int decodeBigIndian(byte[] buf, int start, int len) {
			int ret1=0;
			
			try {
				for (int i=0;i<len;i++) 
					ret1= ret1+ byte2UnsignedInt(buf[start+i]) *  ( (int) Math.pow((double) 256, (double) (len-i-1) ));
			} catch(Exception e) {
				e.printStackTrace();
				return -1;
			}
			
			return ret1;
			
		}
	
	
	
	
	
	
	
	

	
	//*******************************************************
	public static Connection getTargetDbConnection(String driver, String url, String user, String pass) {
		Connection conn=null;
		
		
		
		mydebug("Connecting to : ");
		mydebug("driver     :["+driver+"]");
		mydebug("connstr    :["+url+"]");
		mydebug("user       :["+user+"]");
		mydebug("pass       :["+"************]");	
		
			try {
				Class.forName(driver.replace("*",""));
				conn = DriverManager.getConnection(url, user, pass);
				
			
				return conn;
					
	
			} catch (Exception e) {
				mylog("Exception@getconn : " + e.getMessage());
				e.printStackTrace();
				return null;
			}
			
	}
	
	
	//*************************************************************************************************
	public static boolean testRule(String data, String check_rule, String params, String case_sensitive) {
		
		String test_data=data;
		
		
		
		boolean is_matched=false;
		
		
		
		if (check_rule.equals("IS_EMPTY")) {
			if (test_data.trim().length()==0) is_matched=true;
		} 
		else if (check_rule.equals("IS_NOT_EMPTY")) {
			if (test_data.trim().length()>0) is_matched=true;
		} 
		else  {
			
			
			if (case_sensitive.equals("NO")) test_data=test_data.toLowerCase();
			
			String[] check_parameterArr=params.split("\n|\r");
			
			for (int k=0;k<check_parameterArr.length;k++) {
				String a_check_param=check_parameterArr[k];
				if (a_check_param.trim().length()==0) continue;
				
				if (case_sensitive.equals("NO")) a_check_param=a_check_param.toLowerCase();
				
				if (check_rule.equals("EQUALS")) {
					if (test_data.equals(a_check_param)) {
						is_matched=true;
						break;
					}
				}
				else if (check_rule.equals("NOT_EQUALS")) {
					if (!test_data.equals(a_check_param)) {
						is_matched=true;
						break;
					}
				}
				else if (check_rule.equals("CONTAINS")) {
					if (test_data.contains(a_check_param)) {
						is_matched=true;
						break;
					}
				}
				else if (check_rule.equals("NOT_CONTAINS")) {
					if (!test_data.contains(a_check_param)) {
						is_matched=true;
						break;
					}
				}
				else if (check_rule.equals("REGEX")) {
					if (testRegexMatch(test_data, a_check_param, case_sensitive)) {
						is_matched=true;
						break;
					}
				}
				else if (check_rule.equals("NOT_REGEX")) {
					if (!testRegexMatch(test_data, a_check_param, case_sensitive)) {
						is_matched=true;
						break;
					}
				}
				
			}
		} 
		
		return is_matched;
	}
	
	//**************************************************
	static boolean testRegexMatch(String val_to_test, String regex_expr, String case_sensitivity) {
		
		Pattern pattern=null;
		Matcher matcher =null;
		
		try {
			if (case_sensitivity.equals("YES"))
				pattern=Pattern.compile(regex_expr);
			else 
				pattern=Pattern.compile(regex_expr,Pattern.CASE_INSENSITIVE);
			
			matcher = pattern.matcher(val_to_test);
			if (matcher.find()) return true;
		} catch(Exception e) {
			e.printStackTrace();
			return false;
		}
		
		return false;
		
	}
	
	
	
	//******************************************
	static final char replaceChar(String in) {
		
		String a="çÇðÐýÝöÖþÞüÜ";
		String b="CCGGIIOOSSUU";
		
		int pos=a.indexOf(in);
		
		if (pos==-1) return in.charAt(0);
		return b.charAt(pos);
	}
	//******************************************
	static public String normalizeString(String val) {
		String normal_chars="ABCDEFGHIJKLMNOPQRSTUWXYZabcdefghijklmnopqrstuwxyz0123456789";
		String val1=val.toUpperCase();
		char[] arr=val1.toCharArray();
		for (int i=0;i<val1.length();i++) {
			String cin=val1.substring(i,i+1);
			if (normal_chars.indexOf(cin)==-1) {
				String cout=""+replaceChar(cin);
				if (cin.equals(cout)) cout=" ";
				arr[i]=cout.charAt(0);
			}
		}
		
		return new String(arr).replace(" ", "");
		
	}
	
	
	
	//***************************************************************************
	
	static final byte[] ORCL_SQLpackageSingleByteSqlLength=new byte[] { (byte) 0x01 };
	static final byte[] ORCL_SQLpackageDoubleByteSqlLength=new byte[] { (byte) 0x02 };
	static final byte[] ORCL_SQLpackageTripleByteSqlLength=new byte[] { (byte) 0x03 };
	
	static final int MAX_SQL_CHUNK_SIZE=8196;
	
	
	
	
	//****************************************************************************
	static byte[] getLengthBytesV2(int paramInt)
	  {
	    byte[] buffer=new byte[4];
	      buffer[0] = ((byte)(paramInt & 0xFF));
	      buffer[1] = ((byte)(paramInt >> 8 & 0xFF));
	      buffer[2] = ((byte)(paramInt >> 16 & 0xFF));
	      buffer[3] = ((byte)(paramInt >> 24 & 0xFF));
	    
	    return buffer;
	  }
	
	//****************************************************************************
	public static byte[] makeLengthFor2Bytes(int package_length) {
		 byte[] ret1=new byte[]{ (byte) 0x0, (byte) 0x0};
		 int low=package_length % 256;
		 int high=(int) package_length/256;
		 if (package_length<256) high=0;
		 
		 ret1[0]=(byte) high;
		 ret1[1]=(byte) low;
		 
		 return ret1;
	}
	
	//****************************************************************************
	static final  int X_256_256=256*256;
	
	static byte[] makeLengthFor3Bytes(int package_length) {
		 byte[] ret1=new byte[]{ (byte) 0x0, (byte) 0x0, (byte) 0x0};
		 int low=package_length % 256;
		 int medium=(int) package_length/256;
		 if (package_length<256) medium=0;
		 int high=(int) package_length/(X_256_256);
		 if (package_length<X_256_256) high=0;
		 
		 ret1[0]=(byte) high;
		 ret1[1]=(byte) medium;
		 ret1[2]=(byte) low;
		 
		 return ret1;
	}
	
	//****************************************************************************
	public static ArrayList<String[]> getDbArray(
			Connection conn, 
			String sql, 
			int limit,
			ArrayList<String[]> bindlist, 
			int timeout_insecond) {
		return getDbArray(conn, sql, limit, bindlist, timeout_insecond,null, null);
	}
	
	//****************************************************************************
	public static ArrayList<String[]> getDbArray(
			Connection conn, 
			String sql, 
			int limit,
			ArrayList<String[]> bindlist, 
			int timeout_insecond,
			ArrayList<String> colNameList) {
		return getDbArray(conn, sql, limit, bindlist, timeout_insecond,colNameList, null);
	}
	
	//****************************************************************************
	public static ArrayList<String[]> getDbArray(
			Connection conn, 
			String sql, 
			int limit,
			ArrayList<String[]> bindlist, 
			int timeout_insecond,
			ArrayList<String> colNameList,
			ArrayList<String> colTypeList) {
		
		ArrayList<String[]> ret1 = new ArrayList<String[]>();

		PreparedStatement pstmtConf = null;
		ResultSet rsetConf = null;
		ResultSetMetaData rsmdConf = null;

		
		int reccnt = 0;
		try {
			if (pstmtConf == null) 	{
				pstmtConf = conn.prepareStatement(sql, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);
				try {pstmtConf.setFetchSize(1000);} catch(Exception e) {}
			}
			
			
			//------------------------------ end binding

			if (bindlist!=null) {
				for (int i = 1; i <= bindlist.size(); i++) {
					String[] a_bind = bindlist.get(i - 1);
					String bind_type = a_bind[0];
					String bind_val = a_bind[1];
					
	
					if (bind_type.equals("INTEGER")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtConf.setInt(i, Integer.parseInt(bind_val));
					} else if (bind_type.equals("LONG")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtConf.setLong(i, Long.parseLong(bind_val));
					} else if (bind_type.equals("DOUBLE")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.DOUBLE);
						else
							pstmtConf.setDouble(i, Double.parseDouble(bind_val));
					} else if (bind_type.equals("FLOAT")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.FLOAT);
						else
							pstmtConf.setFloat(i, Float.parseFloat(bind_val));
					}  else if (bind_type.equals("DATE")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.DATE);
						else {
							Date d = new SimpleDateFormat(genLib.DEFAULT_DATE_FORMAT)
									.parse(bind_val);
							java.sql.Date date = new java.sql.Date(d.getTime());
							pstmtConf.setDate(i, date);
						}
					} 
					else if (bind_type.equals("TIMESTAMP")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.TIMESTAMP);
						else {
							Timestamp ts=new Timestamp(System.currentTimeMillis());
							try {ts=new Timestamp(Long.parseLong(bind_val));} catch(Exception e) {e.printStackTrace();}
							pstmtConf.setTimestamp(i, ts);
						}
					}
					else {
						pstmtConf.setString(i, bind_val);
					}
				}
				//------------------------------ end binding
			}  // if bindlist 
			
			if (timeout_insecond>0 )
				pstmtConf.setQueryTimeout(timeout_insecond);
			
			if (rsetConf == null) rsetConf = pstmtConf.executeQuery();
			
			rsetConf.setFetchDirection(ResultSet.FETCH_FORWARD);
			
			
			if (rsmdConf == null) rsmdConf = rsetConf.getMetaData();
			
			
			int colcount = rsmdConf.getColumnCount();
			
			if (colNameList!=null || colTypeList!=null) {
				if (colNameList!=null) colNameList.clear();
				if (colTypeList!=null) colTypeList.clear();
				
				for (int i=1;i<=colcount;i++) {
					String col_name=rsmdConf.getColumnLabel(i);
					String col_type=rsmdConf.getColumnTypeName(i);
					
					if (colNameList!=null)  colNameList.add(col_name);
					if (colTypeList!=null)  colTypeList.add(col_type);
				}
			}
			
			
			String a_field = "";
			
			
			
			while (rsetConf.next()) {
				reccnt++;
				if (reccnt > limit) break;
				String[] row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {
					try {
						a_field = rsetConf.getString(i);
						
						if (a_field.equals("null")) a_field=""; 
						if (a_field.length()>100000) a_field=a_field.substring(0,100000);
						} 
					catch (Exception enull) {a_field = "";}
					row[i - 1] = a_field;
				}
				ret1.add(row);
			}
			
			
		} catch(SQLException sqle) {
			sqle.printStackTrace();
			mylog("Exception@getDbArray : SQL       => " + sql);
			mylog("Exception@getDbArray : MSG       => " + sqle.getMessage());
			mylog("Exception@getDbArray : CODE      => " + sqle.getErrorCode());
			mylog("Exception@getDbArray : SQL STATE => " + sqle.getSQLState());
		}
		catch (Exception ignore) {
			ignore.printStackTrace();
			mylog("Exception@getDbArray : SQL => " + sql);
			mylog("Exception@getDbArray : MSG => " + ignore.getMessage());
		} finally {
			try {rsetConf.close();} catch(Exception e) { e.printStackTrace();}
			try {pstmtConf.close();} catch(Exception e) {e.printStackTrace();}
			
		}
		return ret1;
	}
	
	
	
	
	//****************************************************************************
	public static ArrayList<String[]> getDbArrayNoException(
			Connection conn, 
			String sql, 
			int limit,
			int timeout_insecond) {
		
		ArrayList<String[]> ret1 = new ArrayList<String[]>();

		PreparedStatement pstmtConf = null;
		ResultSet rsetConf = null;
		ResultSetMetaData rsmdConf = null;

		
		int reccnt = 0;
		try {
			if (pstmtConf == null) 	pstmtConf = conn.prepareStatement(sql);
			
			
			
			
			if (timeout_insecond>0)
				pstmtConf.setQueryTimeout(timeout_insecond);
			
			if (rsetConf == null) rsetConf = pstmtConf.executeQuery();
			if (rsmdConf == null) rsmdConf = rsetConf.getMetaData();

			int colcount = rsmdConf.getColumnCount();
			
			
			
			String a_field = "";
			while (rsetConf.next()) {
				reccnt++;
				if (reccnt > limit) break;
				String[] row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {
					try {
						a_field = rsetConf.getString(i);
						
						if (a_field.equals("null")) a_field=""; 
						if (a_field.length()>1000) a_field=a_field.substring(0,1000);
						} 
					catch (Exception enull) {a_field = "";}
					row[i - 1] = a_field;
				}
				ret1.add(row);
			}
		} catch(SQLException sqle) {
			
		}
		catch (Exception ignore) {
			
		} finally {
			try {rsmdConf = null;} catch (Exception e) {}
			try {rsetConf.close();rsetConf = null;} catch (Exception e) {}
			try {pstmtConf.close();	pstmtConf = null;} catch (Exception e) {}
		}
		return ret1;
	}
	
	
	//****************************************		
	static public boolean execSingleUpdateSQL(Connection conn, String sql,ArrayList<String[]> bindlist) {
		
		return execSingleUpdateSQL(conn,sql,bindlist,true, 0,null);
		
	}

	//****************************************		
	static public boolean execSingleUpdateSQL(Connection conn, String sql,ArrayList<String[]> bindlist, int timeout_as_sec) {
		
		return execSingleUpdateSQL(conn,sql,bindlist,true, timeout_as_sec, null);
		
	}
	
	//****************************************
	static public boolean execSingleUpdateSQL(
			Connection conn, 
			String sql,
			ArrayList<String[]> bindlist, 
			boolean commit_after, 
			int timeout_as_sec,
			StringBuilder sberr
			) {

		boolean ret1 = true;
		PreparedStatement pstmt_execbind = null;

		StringBuilder using = new StringBuilder();
		try {
			pstmt_execbind = conn.prepareStatement(sql);

			if (timeout_as_sec>0) 
				try { pstmt_execbind.setQueryTimeout(timeout_as_sec);  } catch(Exception e) {}
			if (bindlist!=null)
			for (int i = 1; i <= bindlist.size(); i++) {
				String[] a_bind = bindlist.get(i - 1);
				String bind_type = a_bind[0];
				String bind_val = a_bind[1];
				if (i > 1)
					using.append(", ");
				using.append("{" + bind_val + "}");

				if (bind_type.equals("INTEGER")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.INTEGER);
					else
						pstmt_execbind.setInt(i, Integer.parseInt(bind_val));
				} else if (bind_type.equals("LONG")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.INTEGER);
					else
						pstmt_execbind.setLong(i, Long.parseLong(bind_val));
				} else if (bind_type.equals("DATE")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.DATE);
					else {
						Date d = new SimpleDateFormat(genLib.DEFAULT_DATE_FORMAT)
								.parse(bind_val);
						java.sql.Date date = new java.sql.Date(d.getTime());
						pstmt_execbind.setDate(i, date);
					}
				} 
				else if (bind_type.equals("TIMESTAMP")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.TIMESTAMP);
					else {
						Timestamp ts=new Timestamp(System.currentTimeMillis());
						try {ts=new Timestamp(Long.parseLong(bind_val));} catch(Exception e) {e.printStackTrace();}
						pstmt_execbind.setTimestamp(i, ts);
					}
				}
				else {
					pstmt_execbind.setString(i, bind_val);
				}
			}

			mydebug("Executing SQL : " + sql + " using " + using.toString());
			if (sberr!=null) sberr.append("Executing SQL : " + sql + " using " + using.toString());

			pstmt_execbind.executeUpdate();
			//pstmt_execbind.execute();
			
			if (!conn.getAutoCommit() && commit_after) 	{
				conn.commit();
			}


		} catch (Exception e) {
			mylog("Exception@execSingleUpdateSQL : " + e.getMessage());
			if (sberr!=null) sberr.append("Exception@execSingleUpdateSQL : " + genLib.getStackTraceAsStringBuilder(e).toString());
			e.printStackTrace();
			ret1 = false;
		} finally {
			try {
				pstmt_execbind.close();
				pstmt_execbind = null;
			} catch (Exception e) {
			}
		}

		return ret1;
	}
	
	//----------------------------------------------------------------------
	public static String nvl(String in, String out) {
		String r = "";
		try {
			r=in;
			if (r.equals("null")) r="";
		} catch (Exception e) {
			r = "";
		}

		if (r.length() == 0)
			r = out;

		return r;
	}
	
	//----------------------------------------------------------------------
	static void setProxyActive(Connection conn, int proxy_id) {
		String sql="update tdm_proxy set status='ACTIVE', error_log=null where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		execSingleUpdateSQL(conn, sql, bindlist);
	}
	//----------------------------------------------------------------------
	static void setProxyLoading(Connection conn, int proxy_id) {
		String sql="update tdm_proxy set status='LOADING', error_log=null where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		execSingleUpdateSQL(conn, sql, bindlist);
	}
	//----------------------------------------------------------------------
	static void setProxyError(Connection conn, int proxy_id, String error) {
		String sql="update tdm_proxy set status='FAILED', error_log=? where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"STRING",error});
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		execSingleUpdateSQL(conn, sql, bindlist);
	}
	
	//----------------------------------------------------------------------
	
	static ScriptEngineManager factory=null;
	static ScriptEngine engine=null;
	
	static boolean checkJSCode(String js_code, String param) {
		StringBuilder sb=new StringBuilder();
		sb.append(js_code);
		while(true) {
			int ind=-1;
			ind=sb.indexOf("${1}");
			if (ind==-1) break;
			sb.delete(ind, ind+4);
			sb.insert(ind, param);
		}
		
		try {
			if (factory==null) 	{
				factory = new ScriptEngineManager();
				engine = factory.getEngineByName("JavaScript");
				}
			
			try {
				String tmpval=""+engine.eval(sb.toString());
				boolean ret1=Boolean.parseBoolean(tmpval);
				return ret1;
			} catch (Exception e) {
				
			}
		} catch(Exception e) {
			return false;
		}
		
		return false;
		
	}
	
	//*************************************************************************************************
	
	static final String DUMMY="DUMMY";
	
	static synchronized void addProxyEvent(
			ddmProxyServer dm,
			ArrayList<String[]> proxyEventArr,
			String log_type,
			String log_ts,
			String username,
			String original_sql,
			String sql_without_where_condition,
			String mask_sql,
			String  proxy_session_id,
			String  bindInfo,
			String sessionInfo,
			String sample_count
			) {
		
		
		if (!log_type.equals(DUMMY)) {
			String[] arr=new String[]{
					log_type,
					log_ts, 
					username,
					original_sql,
					sql_without_where_condition,
					mask_sql,
					proxy_session_id,
					bindInfo,
					sessionInfo,
					sample_count
					};
			
			proxyEventArr.add(arr);
		}
		
		
		boolean log_write=false;
		if (proxyEventArr.size()>=1000 || System.currentTimeMillis()>=dm.next_proxy_event_write_ts) log_write=true;
		
		if (log_write && proxyEventArr.size()>0) {
			ArrayList<String[]> tmpEventArr=new ArrayList<String[]>();
			tmpEventArr.addAll(proxyEventArr);
			proxyEventArr.clear();
			dm.startProxyEventWriterThread(tmpEventArr); 
			
			
			
		}
		
	}
	
	
	//*************************************************************************************************
	
	public static String getStatementType(ddmProxyServer dm, String statement) {
				
		StringBuilder stmt_type=new StringBuilder();
		StringBuilder statement_related_object=new StringBuilder();
		
		try {
			if (dm.proxy_type.equals(dm.PROXY_TYPE_ORACLE_T2)) {
				oracleParser.determineStatementType(statement, stmt_type, statement_related_object);
				return stmt_type.toString();
			} 
			
			
			oracleParser.determineStatementType(statement, stmt_type, statement_related_object);
			return stmt_type.toString();
		} catch(Exception e) {
			e.printStackTrace();
			return "error";
		}
		
		
		
	}
	


	//********************************************************************************************
	public static boolean evaluateDataArray(
			ddmClient ddmClient,
			ArrayList<String[]> sampleDataArr, 
			int col_no, 
			String profile_matching_rule_id,
			String profile_matching_method, 
			String profile_matching_statement,
			int targetRate) {

		
		int all_sample_count=sampleDataArr.size();
		if (all_sample_count==0) {
			ddmClient.mydebug("No sample to match!");
			return false;
		}
		
		int target_match_count=all_sample_count * targetRate / 100;
		if (target_match_count==0) target_match_count=1;
		
		StringBuilder sampleString=new StringBuilder();
		StringBuilder hashkey=new StringBuilder();
		
		int matched_count=0;
		
		Pattern pattern=null;
		Matcher matcher =null;
		
		//mylog("MATCH : " + profile_matching_method +"," +profile_matching_statement+", " + targetRate);
		
		
		for (int i=0;i<all_sample_count;i++) {
			sampleString.setLength(0); 
			sampleString.append(sampleDataArr.get(i)[col_no]);
			if (sampleString.length()==0) continue;
			
			if (profile_matching_method.equals("EQUALS")) {
				if (sampleString.toString().toUpperCase().equals(profile_matching_statement.toUpperCase())) matched_count++;
			} 
			else if (profile_matching_method.equals("CONTAINS")) {
				if (ddmLib.normalizeString(sampleString.toString().toUpperCase()).indexOf(ddmLib.normalizeString(profile_matching_statement.toUpperCase()))>-1) matched_count++;
			}
			else if (profile_matching_method.equals("IN")) {
				hashkey.setLength(0);
				hashkey.append("CHECKLIST_KEY_"+profile_matching_rule_id+"_"+ddmLib.normalizeString(sampleString.toString().toUpperCase()).hashCode());
				if (ddmClient.dm.hmConfig.containsKey(hashkey.toString())) matched_count++;
				
			}
			else if (profile_matching_method.equals("CONTAINS_ANY")) {
				
				ArrayList<String> containsAnyList=(ArrayList<String>) ddmClient.dm.hmConfig.get("CONTAIN_ANY_LIST_"+profile_matching_rule_id);
				
				if (containsAnyList!=null) {
					for (int k=0;k<containsAnyList.size();k++) {
						if (ddmLib.normalizeString(sampleString.toString().toUpperCase()).contains(containsAnyList.get(k))) {
							matched_count++;
							break;
						}
					}
				}
				
				
				
				
			}
			else if (profile_matching_method.equals("REGEX")) {
				try {
					pattern=Pattern.compile(profile_matching_statement,Pattern.CASE_INSENSITIVE);
					matcher = pattern.matcher(sampleString.toString());
					if (matcher.find()) matched_count++;
				} catch(Exception e) {
					e.printStackTrace();
				}
				
			}
			else if (profile_matching_method.equals("JAVASCRIPT")) {
				if (sampleString.toString().length()>0) {
					if (ddmLib.checkJSCode(profile_matching_statement, sampleString.toString())) matched_count++;;
				}
			}
			else if (profile_matching_method.equals("STARTS_WITH")) {
				if (sampleString.toString().toUpperCase().indexOf(profile_matching_statement.toUpperCase())==0) matched_count++;
			}
			else if (profile_matching_method.equals("ENDS_WITH")) {
				if (sampleString.toString().toUpperCase().indexOf(profile_matching_statement.toUpperCase())== sampleString.toString().length()-profile_matching_statement.length() ) matched_count++;
			}
			
			
			if (matched_count>=target_match_count) return true;
		}
		
		
		return false;
	}
	
	//********************************************************
	public static String getMaskingFunction(ConcurrentHashMap hm, String mask_prof_id) {
		
		
		String ret1="HIDE:*";
		
		String mask_rule_id=(String) hm.get("MASK_PROF_RULE_TYPE_"+mask_prof_id);
		
		if (mask_rule_id==null) return ret1;
		
		String par1=(String) hm.get("MASK_PROF_PAR_1_"+mask_prof_id);
		String par2=(String) hm.get("MASK_PROF_PAR_2_"+mask_prof_id);
		
		if (par1==null || par2==null) return ret1;
		
		
		if (mask_rule_id.equals("FIXED")) 
			ret1=par1;
		else if (mask_rule_id.equals("JAVASCRIPT")) 
			ret1=par1;
		else if (mask_rule_id.equals("HIDE")) 
			ret1=par1+":"+par2;
		else if (mask_rule_id.equals("RANDOM_NUMBER") || mask_rule_id.equals("RANDOM_STRING")) 
			ret1=par1+":"+par2;
		else if (mask_rule_id.equals("SETNULL")) 
			ret1="";
		else if (mask_rule_id.equals("ENCAPSULATE")) {
			ret1=par1;
		}
		
		if (ret1.length()>0)  ret1=":"+ret1;
		
		ret1=mask_rule_id+ret1;
		
		return ret1;
	}
	
	//-------------------------------------------------
	public static byte[] string2ByteArr(String input) {
		byte[] tmp=new byte[input.length()];
		StringBuilder sb=new StringBuilder(input);
		int length=input.length();

		byte open_p= (byte) 0x5b;
		
		int target_cursor=0;
		int cursor=0;
		
		while(true) {
			byte x=sb.toString().getBytes()[cursor];
			if (x==open_p) {
				cursor++;
				int pos_end=sb.indexOf("]",cursor);
				int number=Integer.parseInt(sb.substring(cursor, pos_end));
				byte b = (byte) number;
				tmp[target_cursor]=b;
				target_cursor++;
				cursor=pos_end+1;
			} else {
				tmp[target_cursor]=x;
				target_cursor++;
				cursor++;
			}
			if (cursor>=length) break;
		}
		
		byte[] ret=new byte[target_cursor];
		System.arraycopy(tmp, 0, ret, 0, target_cursor);
		return ret;
		
	}
	

	//*****************************************************************************************
	
	public static byte[] ORACLE_QUERY_BYTES=new byte[]{ (byte) 3 , (byte) 94};
	public static byte[] ORACLE_NULL_BYTE=new byte[]{ (byte) 0};
	
	public static String visible_chars=new String(" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456456789*()_.?;:<>=\"'\\/@$+-*,%!");
	
					
	
		
	//********************************************************
	public static byte[] clearChunkedBytes(byte[] buf, int start, int len) {
		byte[] tmpArr=new byte[len];
		int part_len=0;
		int target_cursor=0;
		
		
		int end_of_bytes=start+len;
		
		int cursor=start;
		if (buf[start]==(byte) 254) cursor++;
		
		while(true) {
			part_len=ddmLib.byte2UnsignedInt(buf[cursor]);
			cursor++;
			if (part_len==0) break;
			System.arraycopy(buf, cursor, tmpArr, target_cursor, part_len);
			cursor+=part_len;
			target_cursor+=part_len;
			if (cursor>=end_of_bytes) break;
		}
		
		byte[] retArr=new byte[target_cursor];
		System.arraycopy(tmpArr, 0, retArr, 0, target_cursor);
		return retArr;
	}
	
	
	//*****************************************************************************************
	public static byte[] makeChunkedBytes(byte[] buf, int len, int chunk_size) {
		byte[] tmpArr=new byte[len*2];
		int cursor=0;
		int chunk_cursor=0;
		int remaining=len;
		byte[] bytesForChunk=new byte[1];
		
		
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
		
		byte[] retArr=new byte[cursor];
		System.arraycopy(tmpArr, 0, retArr, 0, cursor);
		return retArr;
	}
	
	
	//----------------------------------------------------------------
	static final String MYSQL_TEST_CONNECTION_STRING="select 1 from dual";
	static boolean validateMySQLConnection(Connection conn) {
		ArrayList<String[]> testArr=getDbArrayNoException(conn, MYSQL_TEST_CONNECTION_STRING, 1, 0);
		if (testArr.size()==0) return false;
		return true;
	}
	
	
	//----------------------------------------------------------------
	public static void closeConn(Connection conn) {
		try {conn.close();} catch(Exception e) {}
	}
	
	
	//*************************************************************
	public static void setCatalogForConnection(Connection conn, String cat) {
		if (cat.length()>0 && !cat.equals("${default}")) {
			
			String curr_cat="";
			try { curr_cat=nvl(conn.getCatalog(),"");} catch(Exception e) {e.printStackTrace();}
			
			if (!curr_cat.equals(cat)) {
				//System.out.println("setting catalog to ="+cat);
				try { conn.setCatalog(cat);} catch(Exception e) {e.printStackTrace();}	
			}
				
		}
	}
	
	//*************************************************************
	static final char CHAR_0=(char) 0;
	static final char CHAR_1=(char) 1;
	
	
	static final String SPLIT_CHRS=" \n\r\t,)(;="+CHAR_0+CHAR_1;
	static final String SINGLE_STRINGS=",";
	static final String SINGLE_DOT_REGEX="\\.";
	
	public static int searchForStandaloneString(String str, String searchfor, int startIndex) {
		
		
		int pos=str.indexOf(searchfor,startIndex);
		if (pos==-1) return -1;
		
		if (pos>=0) {
			String start_ch=" ";
			String end_ch=" ";
			
			int pos_end=pos+searchfor.length();
			try{start_ch=str.substring(pos-1, pos);} catch(Exception e) {}
			try{end_ch=str.substring(pos_end, pos_end+1);} catch(Exception e) {}
			
			
			if (SPLIT_CHRS.contains(start_ch)	&& SPLIT_CHRS.contains(end_ch)) 
				return pos;
			else 
				return searchForStandaloneString(str,searchfor,pos_end+1);
			
		}
		
		return -1;
		}
	


	//*************************************************************************
	public static int searchForStandaloneStringArray(String str, String[] searchfor, int startIndex) {
		int prev_pos=0;
		int first_pos=-1;
		for (int i=0;i<searchfor.length;i++) {
			int pos=searchForStandaloneString(str,searchfor[i],prev_pos);
			if (pos==-1) return -1;
			prev_pos=pos;
			if (i==0) first_pos=prev_pos;
			
		}
		return first_pos;
	}
	
	
	//--------------------------------------------------------------------------
	
	
	static final String cipher_method="AES/CBC/PKCS5Padding";
	static final String AES="AES";
	static byte[] iv = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static final IvParameterSpec ivspec = new IvParameterSpec(iv);


	
	public static final byte[] ecryptByteArray(Cipher cipher, byte[] buf, int len) {
		try {
			byte[] tmp=new byte[len];
			System.arraycopy(buf, 0, tmp, 0, len);
			return cipher.doFinal(tmp);

		} catch(Exception e) {
			e.printStackTrace();
			return buf;
		}
		
	}


	
	//-----------------------------------------------------------------------
	public static final byte[] decryptByteArray(Cipher cipher,  byte[] buf, int len) {
		try {
			byte[] tmp=new byte[len];
			System.arraycopy(buf, 0, tmp, 0, len);
			return cipher.doFinal(tmp);
		} catch(Exception e) {
			e.printStackTrace();
			return buf;
		}
	}
	
	//-----------------------------------------------------------------------


	static public  void printByteArray(byte[] buf, int len) {
		printByteArray(buf, 0, len);
	}
	
	
	//-----------------------------------------------------------------------
	
	
	
	static public  void printByteArray(byte[] buf, int start, int len) {
		try {
			boolean truncated=false;
			int target=start+len;
			
			if (len>16348) {
				target=start+16348;
				truncated=true;
			}
			
			for (int i=start;i<target;i++) {
				if (visible_chars.indexOf(buf[i])>-1)
					System.out.print(new String(buf,i,1));
				else 
					System.out.print("["+byte2UnsignedInt(buf[i])   +"]");
			}
			
			if(truncated) System.out.print("...[?truncated?]");
			
			System.out.print("\n");
			
		} catch(Exception e) {
			e.printStackTrace();
		}
		
	}
	
	
	//***********************************************************
	public static ArrayList<byte[]> splitPackage(
			byte[] wholePack, 
			int full_package_size, 
			int max_package_size,
			int POS_BEFORE_STATEMENT) {

		int remaining=full_package_size;
		
		int package_no=0;
		
		ArrayList<byte[]> splitedBytesArrayList=new ArrayList<byte[]>();
		
		
		while(true) {
			
			if (package_no==0) {
				int start=0;
				int end=POS_BEFORE_STATEMENT;
				int len=end-start+1;
				if (len<max_package_size) {
					int diff=max_package_size-len;
					end+=diff;
				}
				len=end-start+1;
				remaining-=len;
				byte[] arrX=new byte[len];
				System.arraycopy(wholePack, 0, arrX, 0, len);
				//printByteArray(arrX, 0, len);
				splitedBytesArrayList.add(arrX);
				package_no++;
			} else {
				int start=full_package_size-remaining;
				int end=start+max_package_size;
				if (end>full_package_size-1) end=full_package_size-1;
				int len=end-start+1;
				remaining-=len;
				byte[] arrX=new byte[len+10];
				System.arraycopy(wholePack, 0, arrX, 0, 10);
				System.arraycopy(wholePack, start, arrX, 10, len);
				//printByteArray(arrX, 0, len);
				splitedBytesArrayList.add(arrX);
				package_no++;
			}
			if (remaining<=0) break;
		}
	
		return splitedBytesArrayList;
	}
	
	//--------------------------------------------
	static public byte[] decompress(byte[] input)  {
	    
		if (input==null) return null;
			
		Inflater ifl = new Inflater();
	    ifl.setInput(input);

	    ByteArrayOutputStream baos = new ByteArrayOutputStream(input.length);
	    byte[] buff = new byte[1024];
	    while (!ifl.finished()) {
	        int count;
			try {
				count = ifl.inflate(buff);
			} catch (DataFormatException e) {
				e.printStackTrace();
				return null;
			}
	        baos.write(buff, 0, count); 
	       
	    }
	   
	    byte[] output = baos.toByteArray();
	    try {baos.close();} catch (IOException e){e.printStackTrace(); }
	    
	    return output;
	    
	    
	}
		
		
		
	//--------------------------------------------
	static public byte[] compress(byte[] input){
		
	    Deflater df = new Deflater();
	    df.setLevel(Deflater.BEST_SPEED);
	    df.setInput(input);

	    ByteArrayOutputStream baos = new ByteArrayOutputStream(input.length);
	    df.finish();
	    byte[] buff = new byte[1024];
	    while (!df.finished()) {
	        int count = df.deflate(buff);
	        baos.write(buff, 0, count);
	    }
	    try {
			baos.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	    byte[] output = baos.toByteArray();

	    return output;
	}
		
	//--------------------------------------------
	static public byte[] hashMapToByteArr(ConcurrentHashMap in) {
		
		
		byte[] ret1=null;
		ObjectOutputStream out =null;
		try {
			ByteArrayOutputStream bos = new ByteArrayOutputStream() ;
			out =new ObjectOutputStream(bos) ;
			out.writeObject(in);
			out.close();
			ret1= bos.toByteArray();
		} catch(IOException e) {
			e.printStackTrace();
		} finally {
			try{out.close();} catch(Exception e) {}
		}
		
		return ret1;
	}
		
	//--------------------------------------------
	static public ConcurrentHashMap byteArrToHashMap(byte[] in) {
		ConcurrentHashMap ret1=null;
		ObjectInputStream ois =null;
		
		
		if (in==null) return null;
		try { 
			ByteArrayInputStream bis=new ByteArrayInputStream(in);
			ois = new ObjectInputStream(bis);
			
			
			ret1=(ConcurrentHashMap) ois.readObject();
			
			ois.close();
		} catch(Exception e) {
			e.printStackTrace();
			return null;
		} finally {
			try {ois.close();} catch (Exception e) {}
		}
		
		return ret1;
	}
	
	//********************************************

	
	static void setBinInfo(Connection conn, String table_name, int id, String field_name, byte[] buf) {
		
		String sql_FOR_setBinInfo="update "+table_name+" set "+field_name+" =? where id=?";
		
		if (buf==null || buf.length==0) return;
		
		
		
		PreparedStatement stmt=null;
		try {
			stmt = conn.prepareStatement(sql_FOR_setBinInfo);
			stmt.setBytes(1, buf);
			stmt.setInt(2, id);
			stmt.executeUpdate();
		}  catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {stmt.close();stmt = null;} catch (Exception e) {	}
		}
	}
	
	
	//***********************************************
	static public byte[] getInfoBin(Connection conn, String table_name, int p_id,String field_name) {

		byte[] ret1=null;
		String sql="select "+field_name+" from "+ table_name + " where id=? ";
		
		PreparedStatement pstmtConf = null;
		ResultSet rsetConf = null;
		
		try {
			
			
			pstmtConf = conn.prepareStatement(sql);
			pstmtConf.setInt(1, p_id);
			
			rsetConf = pstmtConf.executeQuery();
			
			while (rsetConf.next()) {
				try {
				ret1=rsetConf.getBytes(1); 
				} catch(Exception e) {ret1=null;}
				break;
			}
			
		} catch (Exception ignore) {
			ignore.printStackTrace();
			ret1=null;
		} finally {
			try {
				rsetConf.close();
				rsetConf = null;
			} catch (Exception e) {
			}
			try {
				pstmtConf.close();
				pstmtConf = null;
			} catch (Exception e) {
			}

		}
				
		return ret1;
	}
	
	//**********************************************************************
	static byte[] BYTE_MONGO_OP_QUERY=new byte[]{ (byte) (212), (byte) 7, (byte) 0, (byte) 0 };
	static byte[] BYTE_MONGO_OP_GET_MORE=new byte[]{ (byte) (213), (byte) 7, (byte) 0, (byte) 0 };
	
	static boolean isMongoQueryPack(byte[] buf, int len) {
		int pos=IndexOfByteArray(buf, 0, 20, BYTE_MONGO_OP_QUERY);
		
		if (pos==12) return true;
		
		pos=IndexOfByteArray(buf, 0, 20, BYTE_MONGO_OP_GET_MORE);
		
		if (pos==12) return true;
		
		return false;
		
		
	}
	
	//**********************************************************************
	static byte[] BYTE_MONGO_NULL=new byte[]{ (byte) 0 };
	static final int MONGO_COLL_START_POS=20;
	
	static String decodeMongoCollectionNameFromPack(byte[] buf, int len) {
		
		
		int pos_null=IndexOfByteArray(buf, MONGO_COLL_START_POS, len, BYTE_MONGO_NULL);
		if (pos_null==-1) return null;
		int str_len=pos_null-MONGO_COLL_START_POS;
		
		try {
			byte[] tmp=new byte[str_len];
			System.arraycopy(buf, MONGO_COLL_START_POS, tmp, 0, str_len);
			String tmpstr=new String(tmp);
			return tmpstr;
		} catch(Exception e) {
			e.printStackTrace();
			return null;
		}
		
	}
	
	
	
	//**********************************************************************

	static byte[] BYTE_MONGO_OP_REPLY=new byte[]{ (byte) (1), (byte) 0, (byte) 0, (byte) 0 };
	static int DOC_COUNT_POS=32;
	
	static byte[] maskMongoPackage(
			ddmClient packageObj,  
			byte[] buf, 
			int len
			) {
		int pos=IndexOfByteArray(buf, 0, 20, BYTE_MONGO_OP_REPLY);
		
		if (pos!=12) return buf;
		
		int doc_count=ddmLib.contertByteArray2Integer(buf, DOC_COUNT_POS, 4, ByteOrder.LITTLE_ENDIAN);
		packageObj.mydebug("doc_count="+doc_count);
		
		int cursor=DOC_COUNT_POS+4;
		int doc_len=0;
		int doc_counter=0;
		
		byte[] tmpBuf=new byte[len*2];
		System.arraycopy(buf, 0, tmpBuf, 0, cursor);
		
		int tmp_cursor=cursor;
		
 		
		while(true) {
			doc_len=ddmLib.contertByteArray2Integer(buf, cursor, 4, ByteOrder.LITTLE_ENDIAN);
			doc_counter++;
			
			byte[] docbuf=new byte[doc_len];
			System.arraycopy(buf, cursor, docbuf, 0, doc_len);
			
			//packageObj.mydebug("doc : "+doc_counter);
			//packageObj.printByteArray(docbuf, doc_len);
			
			//mask here
			//*************************
			//*************************
			docbuf=maskMongoDocument(packageObj,docbuf);
			int masked_doc_len=docbuf.length;
			
			packageObj.mydebug("final masked buf "+masked_doc_len);
			packageObj.printByteArray(docbuf, masked_doc_len);
			
			System.arraycopy(docbuf, 0, tmpBuf, tmp_cursor, masked_doc_len);
			
			cursor+=doc_len;
			tmp_cursor+=masked_doc_len;
			
			
			if (doc_counter==doc_count) break;
			if (cursor>=len) break;
			
		}
		
		byte[] packHeader=convertInteger2ByteArray4Bytes(tmp_cursor, ByteOrder.LITTLE_ENDIAN);
		System.arraycopy(packHeader, 0, tmpBuf, 0, 4);
		
		byte [] ret1=new byte[tmp_cursor];
		System.arraycopy(tmpBuf, 0, ret1, 0, tmp_cursor);
		
		packageObj.printByteArray(ret1, tmp_cursor);
		
		return ret1;

	}
	
	//***********************************************************************************
	static byte[] maskMongoDocument(
			ddmClient packageObj,  
			byte[] docbuf
			) {
		
		int original_len=docbuf.length;
		BSONObject  bsonobj = null;
		
		try {
			bsonobj=packageObj.BSONdecoder.readObject(docbuf);
			//packageObj.mydebug("Decoded BSON : "+bsonobj.toString());
			
			//StringBuilder sb=new StringBuilder(bsonobj.toString());

			maskBSONObject(packageObj, bsonobj,"");
			
			byte[] encoded=packageObj.BSONencoder.encode(bsonobj);
			
			
			if (encoded!=null) return encoded;
			else return docbuf;
			
		} catch(Exception e) {
			packageObj.mydebug("Exception@maskMongoDocument : "+genLib.getStackTraceAsStringBuilder(e).toString());
			return docbuf;
		}
		
		
		
	}
	
	//************************************************************************************

	static private String maskHide(String orig_value,int show_count, String mask_asterix_char,String hide_by_word) {
		if (orig_value.length()<= show_count)
			return orig_value; 
		
		char asterix='*';
		
		try {asterix=mask_asterix_char.toCharArray()[0];} catch(Exception e) {asterix='*';}
		
		char[] arr=orig_value.toCharArray();
		int start_indicator=0;
		char a_char='x';
		
		for (int i=0;i<arr.length;i++) {
			start_indicator++;
			if (start_indicator<=show_count) continue;
			if (arr[i]==' ') {if(hide_by_word.equals("YES")) start_indicator=0;continue;}
			arr[i]=asterix;
		}
		return (new String().valueOf(arr));
	}
	
	//************************************************************************************
	static final String NONE="NONE";
	static final String SETNULL="SETNULL";
	static final String HIDE="HIDE";
	static final String FIXED="FIXED";
	
	static String mask(String val, String mask_function) {
		String[] arr=mask_function.split(":");
		
		if (arr[0].equals(HIDE)) {
			String mask_asterix_char="*";
			try{mask_asterix_char=arr[1];} catch(Exception e) {}
			int show_count=2;
			try{show_count=Integer.parseInt(arr[2]);} catch(Exception e) {}
			
			return maskHide(val, show_count, mask_asterix_char, "YES");
		}
		if (arr[0].equals(FIXED)) {
			String fixed="*************";
			try{fixed=arr[1];} catch(Exception e) {}			
			return fixed;
		}
		else
			return val;
	}
	//************************************************************************************
	static void maskBSONObject(ddmClient packageObj, BSONObject bsonobj, String parent_key) {
		
		//packageObj.mydebug("masking : "+bsonobj.toString());
		
		try {
			Map map=bsonobj.toMap();
			//packageObj.mydebug("map found : "+map.size());
			for (Object obj:  map.keySet()) {
				String key=obj.toString();
				Object val_obj=map.get(key);
				
				if (parent_key.length()>0) key=parent_key+"."+key;
				
				
				//String val_type=val_obj.getClass().getName();
				String val_value=val_obj.toString();
				
				
				if (val_obj instanceof org.bson.BasicBSONObject) {
					//packageObj.mydebug("BasicBSONObject found at "+key +" : "+val_obj.toString());
					maskBSONObject(packageObj, (BSONObject) val_obj, key);
					//packageObj.mydebug("BasicBSONObject masked : "+val_obj.toString());
					bsonobj.put(key, val_obj);
					continue;
				}
				
				packageObj.mydebug("Testing "+packageObj.mongo_collection_name+"."+key);

				
				if (val_obj instanceof org.bson.BsonNull || val_value.length()==0) {
					//packageObj.mydebug("continue : null or empty");
					continue; 
				}
				
				if (!packageObj.dm.hmConfig.containsKey("MASK_METHOD_FOR_COLUMN_"+packageObj.mongo_collection_name+"."+key)) {
					packageObj.mydebug("continue : no masking method defined for :"+"MASK_METHOD_FOR_COLUMN_"+packageObj.mongo_collection_name+"."+key);
					continue;
				}
				
				String mask_function=(String) packageObj.dm.hmConfig.get("MASK_METHOD_FOR_COLUMN_"+packageObj.mongo_collection_name+"."+key);
				//packageObj.mydebug(key+"("+val_obj.getClass().getName()+")="+val_value+" masking with : "+mask_function);
				
				if (mask_function.equals(NONE)) {
					continue;
				}
				
				
				
				if (mask_function.equals(SETNULL)) {
					bsonobj.put(key, null);
					continue;
				}
				
				String masked_val=mask(val_value, mask_function);
				
				//if (val_obj.getClass())
				bsonobj.put(key, masked_val);
				
			}
		} catch(Exception e) {
			packageObj.mydebug("Exception@maskMongoDocument : "+genLib.getStackTraceAsStringBuilder(e).toString());
		}
		
	}
	
	
	//********************************************************
	static void abortOldSessions(ddmProxyServer dm) {
		dm.mylog("Aborting old sessions...");
		String sql="update tdm_proxy_session set status='ABORTED', exception_time_to=null where proxy_id=? and status in ('NEW','ACTIVE') ";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+dm.proxy_id});
		
		execSingleUpdateSQL(dm.connConf, sql, bindlist);
		dm.mylog("Done...");
	}
	
	//********************************************************
	static String getSessionInfoAsString(ArrayList<String[]> sessionInfoForConnArr) {
		StringBuilder session_info=new StringBuilder();
		
		for (int i=0;i<sessionInfoForConnArr.size();i++) {
			String session_key=sessionInfoForConnArr.get(i)[0];
			String session_val=sessionInfoForConnArr.get(i)[1];
			if (i>0)session_info.append("\n");
			session_info.append(session_key + "="+session_val);
		
		}
		
		return session_info.toString();
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
	 public static void writeSwappedInteger(final byte[] data, final int offset, final int value) {
		 data[ offset + 0 ] = (byte)( ( value >> 0 ) & 0xff );
		 data[ offset + 1 ] = (byte)( ( value >> 8 ) & 0xff );
		 data[ offset + 2 ] = (byte)( ( value >> 16 ) & 0xff );
		 data[ offset + 3 ] = (byte)( ( value >> 24 ) & 0xff );
	 }
	 
	//****************************************
	static String addStartEndForTable(ddmClient ddmClient, String tabin, String start_ch, String end_ch, String middle_ch) {
		if (tabin.contains(start_ch)) return tabin;
		String ret1=tabin;
		
		
		try {
			ret1=
					start_ch+tabin.split("\\.")[0]+end_ch+
					middle_ch+
					start_ch+tabin.split("\\.")[1]+end_ch;
		} catch(Exception e) {e.printStackTrace();}
		
		return ret1;
		
	}
		
	//****************************************
	static String addStartEndForColumn(ddmClient ddmClient, String colin, String start_ch, String end_ch) {
		if (colin.contains(start_ch)) return colin;
		String ret1=colin;
		
		
		try {
			ret1=start_ch+ret1+end_ch;
		} catch(Exception e) {e.printStackTrace();}
		
		return ret1;
		
	}
	 
	 //--------------------------------------------------------------------------------------------
	static final String ORACLE_start_ch="\"";
	static final String ORACLE_end_ch="\"";
	static final String ORACLE_middle_ch=".";
	
	 public static void getSampleDataOracle(oracleSTMTColumn col, ArrayList<String[]> sampleDataArr, int sampleSize, ddmClient ddmClient) {
		 sampleDataArr.clear();
		 
		 if (col.data_type.contains("BLOB") || col.data_type.contains("ROWID") || col.data_type.contains("BIN") || col.data_type.contains("RAW")) return;
		 
		 String sql="Select "+
					 addStartEndForColumn(ddmClient,col.column_name,ORACLE_start_ch,ORACLE_end_ch)+
					 " from "+addStartEndForTable(ddmClient,col.schema_name+"."+col.object_name,ORACLE_start_ch,ORACLE_end_ch,ORACLE_middle_ch)+
					 " where "+addStartEndForColumn(ddmClient,col.column_name,ORACLE_start_ch,ORACLE_end_ch)+" is not null "+
					 " and rownum<="+sampleSize;
		
		 if (ddmClient.dm.is_debug || ddmClient.is_tracing) ddmClient.mydebug("getSampleDataOracle SQL : "+sql);
		 
		 try {
			 //sampleDataArr=ddmLib.getDbArrayNoException(ddmClient.connParallel, sql, sampleSize, 2);
			 sampleDataArr.addAll(ddmLib.getDbArray(ddmClient.connParallel, sql, sampleSize, null, 2));
		 } catch(Exception e) {
			 ddmClient.mylog("Exception@getSampleData : "+genLib.getStackTraceAsStringBuilder(e).toString());
		 }
		 
	 }
	 
	//--------------------------------------------------------------------------------------------
	static final String POSTGRESQL_start_ch="\"";
	static final String POSTGRESQL_end_ch="\"";
	static final String POSTGRESQL_middle_ch=".";
	
	 public static void getSampleDataPostgreSQL(postgreSTMTColumn col, ArrayList<String[]> sampleDataArr, int sampleSize, ddmClient ddmClient) {
		 sampleDataArr.clear();
		 
		 if (col.data_type.contains("BLOB") || col.data_type.contains("ROWID") || col.data_type.contains("BIN") || col.data_type.contains("RAW")) return;
		 
		 String sql="Select "+
					 addStartEndForColumn(ddmClient,col.column_name,POSTGRESQL_start_ch,POSTGRESQL_end_ch)+
					 " from "+addStartEndForTable(ddmClient,col.schema_name+"."+col.object_name,POSTGRESQL_start_ch,POSTGRESQL_end_ch,POSTGRESQL_middle_ch)+
					 " where "+addStartEndForColumn(ddmClient,col.column_name,POSTGRESQL_start_ch,POSTGRESQL_end_ch)+" is not null "+
					 " and limit "+sampleSize;
		
		 if (ddmClient.dm.is_debug || ddmClient.is_tracing) ddmClient.mydebug("getSampleDataOracle SQL : "+sql);
		 
		 try {
			 //sampleDataArr=ddmLib.getDbArrayNoException(ddmClient.connParallel, sql, sampleSize, 2);
			 sampleDataArr.addAll(ddmLib.getDbArray(ddmClient.connParallel, sql, sampleSize, null, 2));
		 } catch(Exception e) {
			 ddmClient.mylog("Exception@getSampleData : "+genLib.getStackTraceAsStringBuilder(e).toString());
		 }
		 
	 }
	//************************************************************************************
	 static public String replaceTableFilter(String tab_filter, String alias) {
	 	StringBuilder sb=new StringBuilder(tab_filter);
	 	String findstr="${this}";
	 	while(true) {
	 		int pos=sb.toString().toLowerCase().indexOf(findstr);
	 		if (pos==-1) break;
	 		sb.delete(pos,pos+findstr.length());
	 		sb.insert(pos, alias);
	 	}
	 	
	 	return sb.toString();
	 }
	 //************************************************************************************
	 static String extractOracleProxyClientName(
			 	ddmClient packageObj,
				byte[] buf, 
				int len) {
		 byte[] AUTH_TERMINAL="AUTH_TERMINAL".getBytes();
		 int pos_AUTH_TERMINAL=IndexOfByteArray(buf, 0, 100, AUTH_TERMINAL);
		 if (pos_AUTH_TERMINAL==-1) return "";

		 
		 //iki turlu olabiliyor
		 //[0][237][0][0][6][0][0][0][0][0][3]v[2][254][255][255][255][255][255][255][255][5][0][0][0][1][0][0][0][254][255][255][255][255][255][255][255][5][0][0][0][0][0][0][0][254][255][255][255][255][255][255][255][254][255][255][255][255][255][255][255][5]PROXY[13][0][0][0][13]AUTH_TERMINAL[11][0][0][0][11]...
		 //[4][4][0][0][6][0][0][0][0][0][3]s[0][1][1][6][2][1][1][1][1][11][1][1][6]SYSTEM[1][13][13]AUTH_TERMINAL[2][1][0]...
		 
		 pos_AUTH_TERMINAL=pos_AUTH_TERMINAL-3;
		 //skip 13, 0
		 while(true) {
			 if (buf[pos_AUTH_TERMINAL-1]!=(byte) 13 && buf[pos_AUTH_TERMINAL-1]!= (byte) 0 && buf[pos_AUTH_TERMINAL-1]!= (byte) 1) break;
			 pos_AUTH_TERMINAL--;
		 }
		 
		 int pos_USERNAME=pos_AUTH_TERMINAL;
		 while(true) { 
			 pos_USERNAME--;
			 if (pos_USERNAME<=0 || buf[pos_USERNAME]==(byte) 1 || buf[pos_USERNAME]==(byte) 255) break;
		 }
		 
		 //skip 2 bytes;
		 pos_USERNAME+=2;
		 
		 
		 try {
			 int len_x=pos_AUTH_TERMINAL-pos_USERNAME;
			 byte[] tmp=new byte[len_x];
			 System.arraycopy(buf, pos_USERNAME, tmp, 0, len_x);
			 return new String(tmp);
		 } catch(Exception e) {
			 return "";
		 }
		 
		 
	 }
	 
	//**********************************************************************
	static public String getSessionKey(ArrayList<String[]> arr, String session_key) {
		String ret1="";
		
		for (int i=0;i<arr.size();i++) {
			String arr_session_key=arr.get(i)[0];
			String arr_session_val=arr.get(i)[1];
			if (session_key.equals(arr_session_key)) return arr_session_val;
		}
		
		return ret1;
		}
	 
	//**********************************************************************
	static public String getSessionKey(ddmClient ddmClient, String session_key) {
		
		return getSessionKey(ddmClient.sessionInfoForConnArr,session_key);

	}
	
	//**********************************************************************
	static void setSessionKey(ddmClient ddmClient, String session_key, String val) {
		int index=-1;
		
		for (int i=0;i<ddmClient.sessionInfoForConnArr.size();i++) {
			String arr_session_key=ddmClient.sessionInfoForConnArr.get(i)[0];

			if (session_key.equals(arr_session_key)) {
				index=i;
				break;
			}
		}
		
		if (index>-1) {
			String[] newArr=new String[]{session_key, val};
			ddmClient.sessionInfoForConnArr.set(index, newArr);
			
		} else {
			ddmClient.sessionInfoForConnArr.add(new String[]{session_key,val});
		}
		
		saveSessionVariables(ddmClient);
		
	}
	

	//*******************************************************************
	static void saveSessionVariables(ddmClient ddmClient) {
		///update changed session info
				ddmLib.addProxyEvent(
						ddmClient.dm,
						ddmClient.dm.proxyEventArray,  
						ddmClient.dm.UPDATE_SESSION_INFO,
						""+System.currentTimeMillis(),
						null, //username,
						null,
						null,
						null,
						ddmClient.proxy_session_id,
						null,
						ddmLib.getSessionInfoAsString(ddmClient.sessionInfoForConnArr),
						null
						);
	}
	 
	 
	//**********************************************************************
	static void setSessionValidationVariables(ddmClient ddmClient) {
		if (ddmClient.client_session_validation_id>0) {
			if (ddmClient.dm.hmConfig.containsKey("SESSION_VALIDATION_"+ddmClient.client_session_validation_id)) {
				String[] valArr= (String[]) ddmClient.dm.hmConfig.get("SESSION_VALIDATION_"+ddmClient.client_session_validation_id);
				
				try {
					ddmClient.session_validation_start_ts=System.currentTimeMillis()+ Long.parseLong(valArr[ddmClient.dm.FLD_SESSION_VALIDATION_check_start]);
				} catch(Exception e) {ddmClient.session_validation_start_ts=System.currentTimeMillis()+0;}
				
				try {
					ddmClient.session_validation_end_ts=ddmClient.session_validation_start_ts+ Long.parseLong(valArr[ddmClient.dm.FLD_SESSION_VALIDATION_check_duration]);
				} catch(Exception e) {ddmClient.session_validation_end_ts=ddmClient.session_validation_start_ts+120*60*60*1000;}
				
				try {
					int tmp_duration=Integer.parseInt(valArr[ddmClient.dm.FLD_SESSION_VALIDATION_limit_session_duration]);
					if (tmp_duration>0) 
						ddmClient.session_limit_ts=ddmClient.session_validation_start_ts+tmp_duration;
					else 
						ddmClient.session_limit_ts=ddmClient.session_validation_start_ts+120*60*60*1000;
				} catch(Exception e) {ddmClient.session_limit_ts=ddmClient.session_validation_start_ts+120*60*60*1000;}
				
				try {
					ddmClient.max_session_validation_attempt_count=Integer.parseInt(valArr[ddmClient.dm.FLD_SESSION_VALIDATION_max_attempt_count]);
				} catch(Exception e) {ddmClient.max_session_validation_attempt_count=3;}
			
			}
			else 
				ddmClient.client_session_validation_id=0;
		}
		
		ddmClient.mydebug("=============================================================");
		ddmClient.mydebug("======= client_session_validation_id     :"+ddmClient.client_session_validation_id);
		ddmClient.mydebug("======= session_validation_start_ts      :"+ddmClient.session_validation_start_ts);
		ddmClient.mydebug("======= session_validation_end_ts        :"+ddmClient.session_validation_end_ts);
		ddmClient.mydebug("======= max_session_validation_attempt   :"+ddmClient.max_session_validation_attempt_count);
		ddmClient.mydebug("======= session_limit_ts                 :"+ddmClient.session_limit_ts);
		ddmClient.mydebug("=============================================================");

		
	}
	 
	 //**********************************************************************
	 static void validateSession(ddmClient ddmClient) {
		 
		 if (ddmClient.session_validated ||  ddmClient.client_cancelled) return;
		 
		 if (ddmClient.client_session_validation_id<=0) {
			 ddmClient.session_validated=true;
			 return;
		 }
		 
		 if (System.currentTimeMillis()<ddmClient.session_validation_start_ts) return;
		 
		
		 
		 
		 String[] valArr= (String[]) ddmClient.dm.hmConfig.get("SESSION_VALIDATION_"+ddmClient.client_session_validation_id);
		 
		 String for_statement_check_regex=valArr[ddmProxyServer.FLD_SESSION_VALIDATION_for_statement_check_regex];
		 
		 String extraction_js_for_par1=valArr[ddmProxyServer.FLD_SESSION_VALIDATION_extraction_js_for_par1];
		 String extraction_js_for_par2=valArr[ddmProxyServer.FLD_SESSION_VALIDATION_extraction_js_for_par2];
		 String extraction_js_for_par3=valArr[ddmProxyServer.FLD_SESSION_VALIDATION_extraction_js_for_par3];
		 String extraction_js_for_par4=valArr[ddmProxyServer.FLD_SESSION_VALIDATION_extraction_js_for_par4];
		 String extraction_js_for_par5=valArr[ddmProxyServer.FLD_SESSION_VALIDATION_extraction_js_for_par5];
		 
		 String controll_method=valArr[ddmProxyServer.FLD_SESSION_VALIDATION_controll_method];
		 String controll_statement=valArr[ddmProxyServer.FLD_SESSION_VALIDATION_controll_statement];
		 String controll_db_id=valArr[ddmProxyServer.FLD_SESSION_VALIDATION_controll_db_id];
		 String expected_result=valArr[ddmProxyServer.FLD_SESSION_VALIDATION_expected_result];
		 String validate_identical_sessions=valArr[ddmProxyServer.FLD_SESSION_VALIDATION_validate_identical_sessions];
		 
		 String validation_key="NO";
		 
		 boolean sql_check_matched=genLib.testRegex(ddmClient.sql_statement.toString(), for_statement_check_regex);
		 
		 if (!sql_check_matched) {
			 ddmClient.mydebug("********** Clause not matched : "+ddmClient.sql_statement.toString());
				 setSessionKey(ddmClient, "SESSION_VALIDATED", validation_key);
			 
			 return;
		 }
		 
		
		 
			 
		 ddmClient.session_validation_attempt_count++;


		 String EXTRACTED_PAR1=extractSessionValidationParameter(ddmClient,extraction_js_for_par1, ddmClient.sql_statement.toString());
		 String EXTRACTED_PAR2=extractSessionValidationParameter(ddmClient,extraction_js_for_par2, ddmClient.sql_statement.toString());
		 String EXTRACTED_PAR3=extractSessionValidationParameter(ddmClient,extraction_js_for_par3, ddmClient.sql_statement.toString());
		 String EXTRACTED_PAR4=extractSessionValidationParameter(ddmClient,extraction_js_for_par4, ddmClient.sql_statement.toString());
		 String EXTRACTED_PAR5=extractSessionValidationParameter(ddmClient,extraction_js_for_par5, ddmClient.sql_statement.toString());
		 
		 ddmClient.mydebug("EXTRACTED_PAR1 :"+EXTRACTED_PAR1);
		 ddmClient.mydebug("EXTRACTED_PAR2 :"+EXTRACTED_PAR2);
		 ddmClient.mydebug("EXTRACTED_PAR3 :"+EXTRACTED_PAR3);
		 ddmClient.mydebug("EXTRACTED_PAR4 :"+EXTRACTED_PAR4);
		 ddmClient.mydebug("EXTRACTED_PAR5 :"+EXTRACTED_PAR5);
		 
		 
		 if (!ddmLib.getSessionKey(ddmClient, "EXTRACTED_PAR1").equals(EXTRACTED_PAR1) && EXTRACTED_PAR1.length()>0) ddmLib.setSessionKey(ddmClient, "EXTRACTED_PAR1", EXTRACTED_PAR1);
		 if (!ddmLib.getSessionKey(ddmClient, "EXTRACTED_PAR2").equals(EXTRACTED_PAR2) && EXTRACTED_PAR2.length()>0) ddmLib.setSessionKey(ddmClient, "EXTRACTED_PAR2", EXTRACTED_PAR2);
		 if (!ddmLib.getSessionKey(ddmClient, "EXTRACTED_PAR3").equals(EXTRACTED_PAR3) && EXTRACTED_PAR3.length()>0) ddmLib.setSessionKey(ddmClient, "EXTRACTED_PAR3", EXTRACTED_PAR3);
		 if (!ddmLib.getSessionKey(ddmClient, "EXTRACTED_PAR4").equals(EXTRACTED_PAR4) && EXTRACTED_PAR4.length()>0) ddmLib.setSessionKey(ddmClient, "EXTRACTED_PAR4", EXTRACTED_PAR4);
		 if (!ddmLib.getSessionKey(ddmClient, "EXTRACTED_PAR5").equals(EXTRACTED_PAR5) && EXTRACTED_PAR5.length()>0) ddmLib.setSessionKey(ddmClient, "EXTRACTED_PAR5", EXTRACTED_PAR5);
		 
		 ddmClient.session_validated=checkSessionValidation(ddmClient, controll_method, controll_statement, controll_db_id, expected_result);
		 if (ddmClient.session_validated)   
			 validation_key="YES";
		 
		 ddmLib.setSessionKey(ddmClient, "SESSION_VALIDATED", validation_key);
		
		 
		 
		 setSessionValidationMessage(ddmClient);
		 
		 if (ddmClient.session_validated && validate_identical_sessions.equals("YES")) 
			 setSessionValidationCommonKey(ddmClient);
		 
		 
		 if (ddmClient.session_validation_attempt_count>ddmClient.max_session_validation_attempt_count && !ddmClient.session_validated) {
			 ddmClient.mydebug("Maximum attempt count ["+ddmClient.max_session_validation_attempt_count+"] is exceeded for session : "+ddmClient.proxy_session_id);
			 ddmClient.client_cancelled=true;
		 }
		 
		 if (!ddmClient.session_validated && System.currentTimeMillis()>ddmClient.session_validation_end_ts) {
			 ddmClient.mydebug("Session validation time is up for session : "+ddmClient.proxy_session_id);
			 ddmClient.client_cancelled=true;
		 }
		 
		 
	 }
	 
	 //************************************************************************
	 static final String[] validation_common_keys=new String[]{"CLIENT_HOST_ADDRESS","MACHINE","TERMINAL","PROGRAM","MODULE","CURRENT_USER","OSUSER"};
	 
	 static String getValidationCommonKey(ddmClient ddmClient, String prefix) {		 
		 StringBuilder hmKey=new StringBuilder(prefix);
		 for (int i=0;i<validation_common_keys.length;i++)
			 hmKey.append("_"+getSessionKey(ddmClient, "CLIENT_HOST_ADDRESS"));
		 		 
		 return hmKey.toString();
	 }
	 //************************************************************************
	 static void setSessionValidationCommonKey(ddmClient ddmClient) {
		 //bu validasyon oncesi ve bu validasyonu alan session kapanana kadar olan surede
		 //ayni kaynaktan gelen baglantilara otomatikman validasyon verir
		 ddmClient.dm.hmCache.put(getValidationCommonKey(ddmClient,"IDENTICAL_SESSION_START_TS"), ddmClient.client_start_ts);
		 ddmClient.dm.hmCache.put(getValidationCommonKey(ddmClient,"IDENTICAL_SESSION_LIMIT_TS"), ddmClient.session_limit_ts);
		 
	 }
	 
	//************************************************************************
	 static void resetSessionValidationCommonKey(ddmClient ddmClient) {
		 ddmClient.dm.hmCache.remove(getValidationCommonKey(ddmClient,"IDENTICAL_SESSION_START_TS"));
		 ddmClient.dm.hmCache.remove(getValidationCommonKey(ddmClient,"IDENTICAL_SESSION_LIMIT_TS"));
	 }
	 //************************************************************************
	 static boolean isIdenticalSessionValidatedInParallel(ddmClient ddmClient) {
		 if (!ddmClient.dm.hmCache.containsKey(getValidationCommonKey(ddmClient,"IDENTICAL_SESSION_START_TS"))) return false;
		 long validated_session_stat_ts=(long) ddmClient.dm.hmCache.get(getValidationCommonKey(ddmClient,"IDENTICAL_SESSION_START_TS"))-5000;
		 if (ddmClient.client_start_ts>=validated_session_stat_ts) return true;
		 return false;
		 
	 }
	 //************************************************************************
	 static void setSessionValidationMessage(ddmClient ddmClient) {
		 ddmClient.sql_statement_masked.setLength(0);
		 
		 String msg="";
		 
		 
		 if (ddmClient.session_validated) 
			 msg="INFOBOX TDM ("+ddmClient.session_validated+"): Session validated. :) Good luck!";
		 else 
 			 msg="INFOBOX TDM ("+ddmClient.session_validated+"): Session NOT validated. Attempt : "+ddmClient.session_validation_attempt_count+"/"+ddmClient.max_session_validation_attempt_count;


		 if (ddmClient.dm.proxy_type.equals(ddmClient.dm.PROXY_TYPE_ORACLE_T2) || ddmClient.dm.proxy_type.equals(ddmClient.dm.PROXY_TYPE_MYSQL))
			 ddmClient.sql_statement_masked.append("select '"+msg+"' from dual                                                                                                                                                                                                                                                        ");
		 else 
			 ddmClient.sql_statement_masked.append("select '"+msg+"' ");

		
	 }
	 
	 //**********************************************************************
	 static void checkIdenticalValidatedSessionsAndTimeout(ddmClient ddmClient) {
		 
		 if (ddmClient.session_validated ||  ddmClient.client_cancelled) return;
		 if (ddmClient.client_session_validation_id<=0) return;
		 if (System.currentTimeMillis()<ddmClient.session_validation_start_ts) return;
		 
		//see if there is identical sessions validated
    	 if (isIdenticalSessionValidatedInParallel(ddmClient)) {
    		 ddmClient.mydebug("Identical validated session detected. So this session validated accordingly.");
    		 ddmClient.session_validated=true;
    		 setSessionKey(ddmClient, "EXTRACTED_PAR1", ""+ddmClient.dm.hmConfig.get(getValidationCommonKey(ddmClient,"EXTRACTED_PAR1")));
    		 setSessionKey(ddmClient, "EXTRACTED_PAR2", ""+ddmClient.dm.hmConfig.get(getValidationCommonKey(ddmClient,"EXTRACTED_PAR2")));
    		 setSessionKey(ddmClient, "EXTRACTED_PAR3", ""+ddmClient.dm.hmConfig.get(getValidationCommonKey(ddmClient,"EXTRACTED_PAR3")));
    		 setSessionKey(ddmClient, "EXTRACTED_PAR4", ""+ddmClient.dm.hmConfig.get(getValidationCommonKey(ddmClient,"EXTRACTED_PAR4")));
    		 setSessionKey(ddmClient, "EXTRACTED_PAR5", ""+ddmClient.dm.hmConfig.get(getValidationCommonKey(ddmClient,"EXTRACTED_PAR5")));
    		 setSessionKey(ddmClient, "VALIDATION_DATA", "Validated by identical session");
    		 setSessionKey(ddmClient, "SESSION_VALIDATED", "YES");
    		 
    		 ddmClient.session_limit_ts=(long) ddmClient.dm.hmCache.get(getValidationCommonKey(ddmClient,"IDENTICAL_SESSION_LIMIT_TS"));
    		 
			 return;
		 }
		 
		 if (!ddmClient.session_validated && System.currentTimeMillis()>ddmClient.session_validation_end_ts) {
			 ddmClient.mydebug("Session validation time is up for session : "+ddmClient.proxy_session_id);
			 ddmClient.client_cancelled=true;
		 }
		 
		 
	 }
	 //*********************************************************************
	 static String extractSessionValidationParameter(ddmClient ddmClient, String extraction_script, String source_clause) {
		 
		 String final_script="";
		 
		 ScriptEngineManager factory=null;
		 ScriptEngine engine=null; 
		 
		 try {
				
			 ArrayList<String[]> params=new ArrayList<String[]>();
			 params.addAll(ddmClient.sessionInfoForConnArr);
			 params.add(new String[]{"CLAUSE",source_clause.replaceAll("\n|\r"," ")});
			 
 			 final_script=genLib.replaceAllParams(extraction_script, params);
				factory = new ScriptEngineManager();
				engine = factory.getEngineByName("JavaScript");
				return ""+ engine.eval(final_script);
			} catch (Exception e) {
				ddmClient.mydebug("EXCEPTION AT SCRIP : ");
				ddmClient.mydebug("=====================================");
				ddmClient.mydebug(final_script);
				ddmClient.mydebug("=====================================");
				return "<EXCEPTION>"+e.getMessage();
			}
	 }
	 //*********************************************************************
	 static boolean checkSessionValidation(ddmClient ddmClient, String controll_method,String controll_statement,String controll_db_id,String expected_result) {
		 String validation_data="";
		 
		 ddmClient.mydebug("checkSessionValidation controll_method     : "+controll_method);
		 ddmClient.mydebug("checkSessionValidation controll_statement  : "+controll_statement);
		 ddmClient.mydebug("checkSessionValidation controll_db_id      : "+controll_db_id);
		 ddmClient.mydebug("checkSessionValidation expected_result     : "+expected_result);
		 
		 if (controll_method.equals("JAVASCRIPT")) 
			 validation_data=getResultWithJavaScript(ddmClient, controll_statement);
		 else 
			 validation_data=getSessionValidationResultWithDatabaseSQL(ddmClient, controll_statement, controll_db_id);
		 
		 ddmLib.setSessionKey(ddmClient, "VALIDATION_DATA", validation_data);
		 
		 ddmClient.mydebug("checkSessionValidation result  : "+validation_data);
		 
		 boolean ret1=genLib.testRegex(validation_data, expected_result);
		 
		 ddmClient.mydebug("checkSessionValidation returns  : "+ret1);
		
		 return ret1;
		 
	 }
	 //*********************************************************************
	 static String getResultWithJavaScript(ddmClient ddmClient, String controll_statement) {
		 
		 
		 String final_script="";
		 
		 ScriptEngineManager factory=null;
		 ScriptEngine engine=null; 
		 
		 try {
				final_script=genLib.replaceAllParams(controll_statement, ddmClient.sessionInfoForConnArr);
				factory = new ScriptEngineManager();
				engine = factory.getEngineByName("JavaScript");
				return ""+ engine.eval(final_script);
			} catch (Exception e) {
				ddmClient.mydebug("EXCEPTION AT SCRIP : ");
				ddmClient.mydebug("=====================================");
				ddmClient.mydebug(final_script);
				ddmClient.mydebug("=====================================");
				return "<EXCEPTION>"+e.getMessage();
			}
		 
	 }
	 
	 //*********************************************************************
	 static String getSessionValidationResultWithDatabaseSQL(ddmClient ddmClient, String controll_statement, String controll_db_id) {
		 
		 StringBuilder sbRet=new StringBuilder();
		 
		 Connection connConf=null;
		 Connection connApp=null;
		 
		
		 
		 try {
			 
			 ddmClient.mydebug("getSessionValidationResultWithDatabaseSQL conf_db_driver :"+ddmClient.dm.conf_db_driver);
			 ddmClient.mydebug("getSessionValidationResultWithDatabaseSQL conf_db_url :"+ddmClient.dm.conf_db_url);
			 ddmClient.mydebug("getSessionValidationResultWithDatabaseSQL conf_db_username :"+ddmClient.dm.conf_db_username);
			 ddmClient.mydebug("getSessionValidationResultWithDatabaseSQL conf_db_password :"+"*********");
			 
			 
			 connConf=ddmLib.getTargetDbConnection(ddmClient.dm.conf_db_driver, ddmClient.dm.conf_db_url, ddmClient.dm.conf_db_username,ddmClient.dm.conf_db_password);
			 
			 String sql="select db_driver, db_connstr, db_username, db_password from tdm_envs where id=?";
			 ArrayList<String[]> bindlist=new ArrayList<String[]>();
			 bindlist.add(new String[]{"INTEGER",controll_db_id});
			 
			 ArrayList<String[]> arr=getDbArray(connConf, sql, 1, bindlist, 0);
			 
			 String driver=arr.get(0)[0];
			 String connstr=arr.get(0)[1];
			 String user=arr.get(0)[2];
			 String pass=genLib.passwordDecoder(arr.get(0)[3]);
			 
			 ddmClient.mydebug("getSessionValidationResultWithDatabaseSQL driver  :"+driver);
			 ddmClient.mydebug("getSessionValidationResultWithDatabaseSQL connstr :"+connstr);
			 ddmClient.mydebug("getSessionValidationResultWithDatabaseSQL user    :"+user);
			 ddmClient.mydebug("getSessionValidationResultWithDatabaseSQL pass    :"+"*********");
			 
			 connApp=ddmLib.getTargetDbConnection(driver, connstr, user, pass);
			 
			 String final_script=decodeControllStatementAndBindings(ddmClient.sessionInfoForConnArr, controll_statement,bindlist);
			 
			 
			 ArrayList<String[]> arrRes=getDbArray(connApp, final_script, 100, bindlist, 10);
			 
			 for (int r=0;r<arrRes.size();r++) {
				 if (r>0) sbRet.append("\n");
				 String[] row=arrRes.get(r);
				 for (int c=0;c<row.length;c++) {
					 if (c>0) sbRet.append("\t");
					 sbRet.append(row[c]);
				 }
			 }
			 
			 
		 } catch(Exception e) {
			 ddmLib.mydebug("Exception@getSessionValidationResultWithDatabaseSQL : "+genLib.getStackTraceAsStringBuilder(e).toString());
		 } finally {
			 try {connConf.close();} catch(Exception e) {}
			 try {connApp.close();} catch(Exception e) {}
		 }
		 
		 return sbRet.toString();
	 }
	 
	 //*********************************************************************
	 public static String decodeControllStatementAndBindings(ArrayList<String[]> sourceParams, String controll_statement,ArrayList<String[]> bindlist) {
		
		 
		 ArrayList<String> pars=new ArrayList<String>();
		 ArrayList<Integer> positions=new ArrayList<Integer>();
		 ArrayList<Integer> parIndexes=new ArrayList<Integer>();
		 
		 for (int p=0;p<sourceParams.size();p++) {
			 String par_name="${"+sourceParams.get(p)[0]+"}";
			 int startIndex=0;
			 while(true) {
				 int pos=controll_statement.indexOf(par_name, startIndex);
				 if (pos==-1) break;
			 
				 pars.add(par_name);
				 positions.add(pos);
				 parIndexes.add(p);
				 
				 startIndex=pos+par_name.length();
				 
				 
			 }
			
		 }
		 
		 //order by position
		 for (int i=0;i<positions.size();i++) {
			 for (int j=i+1;j<positions.size();j++) {
				 if (positions.get(i)>positions.get(j)) {
					 int pos=positions.get(i);
					 positions.set(i, positions.get(j));
					 positions.set(j, pos);
					 
					 int index=parIndexes.get(i);
					 parIndexes.set(i, parIndexes.get(j));
					 parIndexes.set(j, index);
					 
					 String par_name=pars.get(i);
					 pars.set(i, pars.get(j));
					 pars.set(j, par_name);
				 }
			 }
		 }
		 
		 bindlist.clear();
		 StringBuilder sbRet=new StringBuilder(controll_statement);
		 
		 for (int p=pars.size()-1;p>=0;p--) {
			 String par_name=pars.get(p);
			 int pos=positions.get(p);
			 int index=parIndexes.get(p);
			 
			 sbRet.delete(pos, pos+par_name.length());
			 sbRet.insert(pos,"?");
			 bindlist.add(0,new String[]{"STRING",sourceParams.get(index)[1]});
			 
		 }
		 
		 
		 
		 return sbRet.toString();
	 }
	//**********************************************************************
	 static void checkSessionLimit(ddmClient ddmClient) {
		 
		 if (System.currentTimeMillis()<ddmClient.session_validation_start_ts) return;
		 
		 if (System.currentTimeMillis()>ddmClient.session_limit_ts) {
			 ddmClient.mydebug("Session duration limit reached: "+ddmClient.proxy_session_id);
			 ddmClient.client_cancelled=true;
		 }
		 
		 
	 }
	 
	 
	 //**********************************************************************
	 static void checkBlacklist(ddmClient ddmClient) {
		 
		 String machine=genLib.nvl(ddmClient.session_machine,ddmClient.session_terminal);
		 String osuser=ddmClient.session_osuser;
		 String dbuser=ddmClient.session_username;
		 
		 
		 if (ddmClient.dm.hmCache.containsKey("BLACKLISTED_SESSION_FOR_"+ddmClient.proxy_session_id)) {
			 
			 String to_blacklist=(String) ddmClient.dm.hmCache.get("BLACKLISTED_SESSION_FOR_"+ddmClient.proxy_session_id);
			 
			 ddmClient.dm.hmCache.remove("BLACKLISTED_SESSION_FOR_"+ddmClient.proxy_session_id);
			 ddmClient.dm.hmConfig.put("BLACKLIST_FOR_"+machine+"_"+osuser+"_"+dbuser, true);
			 
			 if (to_blacklist.equals("YES")) {
				 ddmLib.addProxyEvent(
			     			ddmClient.dm,
			     			ddmClient.dm.proxyEventArray, 
			     			ddmClient.dm.BLACKLIST,
			 				""+System.currentTimeMillis(),
			 				machine,
			 				osuser,
			 				dbuser,
			 				null,
			 				ddmClient.proxy_session_id,
			 				null,
			 				null,
			 				null
			 				);
			 
			 
			 
			 } 
			 else {
				 ddmClient.mydebug("Session ["+ddmClient.proxy_session_id+"] has violated a monitoring rule. Aborting.");
				 ddmClient.client_cancelled=true;
				 return;
			 }
    	}
	    	

			
	    	if (ddmClient.dm.hmConfig.containsKey("BLACKLIST_FOR_"+machine+"_"+osuser+"_"+dbuser)) {
	    		ddmClient.mydebug("Session is in blacklist. Aborting.");
	    		ddmClient.client_cancelled=true;
	    		return;
	    	}
	 }

	 //***********************************************************************
	 static void archiveMonitoringColumns(ddmProxyServer dm, Connection conn, int proxy_id) {
		 
		 if (System.currentTimeMillis()<dm.next_acrhive_monitoring_columns_ts) return;
		 
		 String sql_to_archive="insert into tdm_proxy_monitoring_columns_archive select * from tdm_proxy_monitoring_columns where proxy_id=? and monitoring_time<=?";
		 String sql_to_delete= "delete from tdm_proxy_monitoring_columns where proxy_id=?  and monitoring_time<=?";
		 
		 long archive_ts=System.currentTimeMillis()-(dm.ARCHIVE_MONITORING_COLUMNS_INTERVAL);
		 
		 ArrayList<String[]> bindlist=new ArrayList<String[]>();
		 bindlist.add(new String[]{"INTEGER",""+proxy_id});
		 bindlist.add(new String[]{"TIMESTAMP",""+archive_ts});
		 
		 boolean is_inserted=ddmLib.execSingleUpdateSQL(conn, sql_to_archive, bindlist);
		 
		 if (is_inserted) ddmLib.execSingleUpdateSQL(conn, sql_to_delete, bindlist);
		 
		 
		 dm.next_acrhive_monitoring_columns_ts=System.currentTimeMillis()+dm.ARCHIVE_MONITORING_COLUMNS_INTERVAL;
	 }
 
	 //***********************************************************************
	 static void checkMonitoring(ddmClient ddmClient, Object stmtobj, int statement_id) {
		
		 if (ddmClient.dm.monitoringPolicies.size()==0) return; 
		 
		 ArrayList<String[]> sourceTabList=new ArrayList<String[]>();
		 
		 try {
			 if (stmtobj instanceof oracleSTMT) {
				 oracleSTMT stmt=(oracleSTMT) stmtobj;	
				 
				 
				 if (stmt==null)  return;
				 
				 
			 	for (int s=0;s<stmt.subStatements.size();s++) {
			 		oracleSTMT subStmt=stmt.subStatements.get(s);
			 		
			 		for (int sel=0;sel<subStmt.selectList.size();sel++) {
			 			oracleSTMTSelect select=subStmt.selectList.get(sel);
			 					 			
			 			for (int x=0;x<select.exprList.size();x++) 
			 				getExpressionBaseTablesForOracle(ddmClient, subStmt, sourceTabList, select.exprList.get(x));
			 			
			 		}
			 	}
			 } 
		 } catch(Exception e) {
			 if (ddmClient.dm.is_debug || ddmClient.is_tracing) 
				 ddmClient.mylog("Exception@checkMonitoring:"+genLib.getStackTraceAsStringBuilder(e).toString());
		 }
		 
		 
		 getSetMonitoringColumnsList(ddmClient.dm, sourceTabList, MONITORING_ACTION_SET, 0);
		 
		 //en sonunda orjinal statement de kontrolden gecmesi icindir.
		 if (statement_id==0) checkMonitoringExpressionsForStatement(ddmClient);

	 }
	 //*****************************************************************
	 static void checkMonitoringExpressionsForStatement(ddmClient ddmClient) {
		 
		 
		 for (int p=0;p<ddmClient.dm.monitoringPolicies.size();p++) {
				String monitoring_id=ddmClient.dm.monitoringPolicies.get(p)[0];
				
				ArrayList<String[]> monitoringExpressionArr=(ArrayList<String[]>) ddmClient.dm.hmConfig.get("MONITORING_EXPRESSIONS_FOR_"+monitoring_id);
				
				if (monitoringExpressionArr==null || monitoringExpressionArr.size()==0) continue;
				
				for (int e=0;e<monitoringExpressionArr.size();e++) {
					String expression=monitoringExpressionArr.get(e)[1];
					
					for (int g=0;g<ddmClient.policyGroups.size();g++) {
						int policy_group_id=ddmClient.policyGroups.get(g);
						
						if (!ddmClient.dm.hmConfig.containsKey("IS_POLICY_GROUP_MONITORED_"+policy_group_id)) continue;
						
						if (genLib.testRegex(ddmClient.sql_statement.toString(), expression)) {
							getSetMonitoringExpressionList(ddmClient.dm, expression, ddmClient.proxy_session_id, policy_group_id,System.currentTimeMillis(), null, MONITORING_ACTION_SET, 0);
							return;
						}
						
					}
					
				}
		 }
	 }
	//******************************************************************
	static void getExpressionBaseTablesForOracle(ddmClient ddmClient,  oracleSTMT stmt, ArrayList<String[]> sourceTabList, oracleSTMTExpr expr) {
		
		for (int c=0;c<expr.baseColumns.size();c++) {
			oracleSTMTColumn column=expr.baseColumns.get(c);
			
			
			String catalog_name=column.catalog_name;
			String schema_name=column.schema_name;
			String object_name=column.object_name;
			String column_name=column.column_name;
			String proxy_session_id=ddmClient.proxy_session_id;
			String timestamp=""+System.currentTimeMillis();
			
			if (ddmClient.dm.is_debug || ddmClient.is_tracing)
				ddmClient.mydebug("Adding to monitoring list : "+catalog_name+schema_name+object_name+column_name);
			
			for (int p=0;p<ddmClient.policyGroups.size();p++) {
				int policy_group_id=ddmClient.policyGroups.get(p);
				if (!ddmClient.dm.hmConfig.containsKey("IS_POLICY_GROUP_MONITORED_"+policy_group_id)) 
					continue; 
				
				sourceTabList.add(new String[]{catalog_name,schema_name,object_name, column_name, proxy_session_id, timestamp,""+policy_group_id});
				//only one insert 
				break;
			}
			
			
		}
		
		for (int e=0;e<expr.exprList.size();e++) 
			getExpressionBaseTablesForOracle(ddmClient, stmt, sourceTabList,expr.exprList.get(e));
		
	}
	
	//********************************************************************
	public static final String MONITORING_ACTION_GET="GET";
	public static final String MONITORING_ACTION_SET="SET";
	
	static synchronized void getSetMonitoringReceivedBytesList(
			ddmProxyServer dm, 
			int received_bytes, 
			String proxy_session_id,
			int policy_group_id, 
			long ts, 
			ArrayList<String[]> receivedBytesList, 
			String action, 
			int limit
		) {
		if (action.equals(MONITORING_ACTION_GET)) {
			receivedBytesList.clear();
			int get_count=0;
			for (int i=0;i<dm.monitoringReceivedBytesArray.size();i++) {
				if (get_count>=limit) break;
				if (dm.monitoringReceivedBytesArray.get(i)==null) continue;
				get_count++;
				String[] arr=dm.monitoringReceivedBytesArray.get(i);
				receivedBytesList.add(arr);
				dm.monitoringReceivedBytesArray.set(i, null);
			}
		} else {
			for (int i=0;i<dm.monitoringReceivedBytesArray.size();i++) {
				if (dm.monitoringReceivedBytesArray.get(i)!=null) continue;
				dm.monitoringReceivedBytesArray.set(i, new String[]{""+received_bytes,proxy_session_id, ""+policy_group_id,""+ts});
				return;
			}
			dm.monitoringReceivedBytesArray.add(new String[]{""+received_bytes,proxy_session_id, ""+policy_group_id,""+ts});
			
		}
	}
	
	//*******************************************************************
	static synchronized void getSetMonitoringExpressionList(
				ddmProxyServer dm, 
				String expr, 
				String proxy_session_id,
				int policy_group_id, 
				long ts, 
				ArrayList<String[]> expressionList, 
				String action, 
				int limit
			) {
		if (action.equals(MONITORING_ACTION_GET)) {
			expressionList.clear();
			int get_count=0;
			for (int i=0;i<dm.monitoringExpressionsArray.size();i++) {
				if (get_count>=limit) break;
				if (dm.monitoringExpressionsArray.get(i)==null) continue;
				get_count++;
				String[] arr=dm.monitoringExpressionsArray.get(i);
				expressionList.add(arr);
				dm.monitoringExpressionsArray.set(i, null);
			}
		} else {
			for (int i=0;i<dm.monitoringExpressionsArray.size();i++) {
				if (dm.monitoringExpressionsArray.get(i)!=null) continue;
				dm.monitoringExpressionsArray.set(i, new String[]{expr,proxy_session_id, ""+policy_group_id,""+ts});
				return;
			}
			dm.monitoringExpressionsArray.add(new String[]{expr,proxy_session_id, ""+policy_group_id,""+ts});
			
		}
	}
	//********************************************************************
	static synchronized void getSetMonitoringColumnsList(ddmProxyServer dm, ArrayList<String[]> monitoringList, String action, int limit) {
		if (action.equals(MONITORING_ACTION_GET)) {
			monitoringList.clear();
			int get_count=0;
			for (int i=0;i<dm.monitoringColumnsArray.size();i++) {
				if (get_count>=limit) break;
				if (dm.monitoringColumnsArray.get(i)==null) continue;
				get_count++;
				String[] arr=dm.monitoringColumnsArray.get(i);
				monitoringList.add(arr);
				dm.monitoringColumnsArray.set(i, null);
			}
		} else {
			int set_count=0;
			
			for (int i=0;i<dm.monitoringColumnsArray.size();i++) {
				if (set_count>=limit) break;
				if (dm.monitoringColumnsArray.get(i)!=null) continue;
				String[] arr=dm.monitoringColumnsArray.get(set_count);
				dm.monitoringColumnsArray.set(i, arr);
				set_count++;
			}
			
			//append remaining ones
			for (int i=set_count;i<monitoringList.size();i++) {
				String[] arr=monitoringList.get(i);
				dm.monitoringColumnsArray.add(arr);
			}
		}
	}
	
	
	//*************************************************************************************************
	static synchronized void setGetViolationEmailList(ddmProxyServer dm, StringBuilder monitoring_id, StringBuilder emailbody, StringBuilder to_email, String monitoring_action) {
		if (monitoring_action.equals(MONITORING_ACTION_GET)) {
			
			emailbody.setLength(0);
			to_email.setLength(0);
			
			for (int i=0;i<dm.monitoringEmailArr.size();i++) {
				String[] arr=dm.monitoringEmailArr.get(i);
				if (arr==null) continue;
				String read_monitoring_id=arr[0];
				String read_body=arr[1];
				String read_to=arr[2];
				
				emailbody.append(read_body);
				to_email.append(read_to);
				monitoring_id.append(read_monitoring_id);
				
				dm.monitoringEmailArr.set(i, null);
				return;
			}
		} else {
			String[] arr=new String[]{monitoring_id.toString(), emailbody.toString(), to_email.toString()};
			for (int i=0;i<dm.monitoringEmailArr.size();i++) {
				if (dm.monitoringEmailArr.get(i)!=null) continue;
				dm.monitoringEmailArr.set(i, arr);
				return;
			}
			dm.monitoringEmailArr.add(arr);
		}
	}
	// *******************************************************
	static public String decode(String a) {
		byte[] valueDecoded = Base64.decodeBase64(a);
		return new String(valueDecoded);

	}
	
	// ***********************************************************
	static Session createEmailSession(ddmProxyServer dm, StringBuilder sbErr) {

		final String username =dm.JAVAX_EMAIL_USERNAME;  // getParamByName("JAVAX_EMAIL_USERNAME");
		final String password =decode(dm.JAVAX_EMAIL_PASSWORD);  //decode(getParamByName("JAVAX_EMAIL_PASSWORD"));
		Properties props = System.getProperties();
		String props_str =dm.JAVAX_EMAIL_PROPERTIES; //getParamByName("JAVAX_EMAIL_PROPERTIES");
		
		
		Session session = null;

		if (props_str.length() == 0) return null;

		String[] arr = props_str.split("\n");

		for (int i = 0; i < arr.length; i++) {
			String line = arr[i].trim();
			String par = "";
			String val = "";
			if (line.contains("=")) {
				par = line.split("=")[0];
				val = line.split("=")[1];
			}
			if (par.length() > 0) {
				dm.mydebug("Setting Javax Email Property : " + par+ "=" + val);
				sbErr.append("Setting Javax Email Property : " + par+ "=" + val);
				props.put(par, val);
			}

		}

		try {
			String auth_err_msg = "";
			if (username.length() == 0)
				session = Session.getInstance(props);
			else {
				try {
					session = Session.getInstance(props,
							new javax.mail.Authenticator() {
								@Override
								protected PasswordAuthentication getPasswordAuthentication() {
									return new PasswordAuthentication(username,
											password);
								}
							});
				} catch (Exception e) {
					auth_err_msg = e.getMessage();
					e.printStackTrace();
				}
			}

			if (session == null) {
				dm.mydebug("Not authenticated. : " + auth_err_msg);
				sbErr.append("Not authenticated. : " + auth_err_msg);
				return null;
			} else {
				dm.mydebug("authenticated... ");
				return session;
			}
				

		} catch (Exception e) {
			dm.mylog("Exception@createEmailSession : "+ genLib.getStackTraceAsStringBuilder(e).toString());
			sbErr.append("Exception@createEmailSession : "+ genLib.getStackTraceAsStringBuilder(e).toString());			
			return null;
		} 

		


	}
	// ************************************************************
	static boolean sendMail(ddmProxyServer dm, String from, String to, String subject, StringBuilder body, StringBuilder sbErr) {
		sbErr.setLength(0);

		Session session = createEmailSession(dm,sbErr);

		if (session == null) {
			dm.mydebug("Email session not successfull.");
			return false;
		}

		Message msg = new MimeMessage(session);

		try {

			msg.setContent(body.toString(), "text/html; charset=utf-8");
			msg.setFrom(new InternetAddress(from));

			String[] targetAddresses = to.split(";");
			for (int t = 0; t < targetAddresses.length; t++) {
				String atarget = targetAddresses[t].trim();
				if (atarget.length() > 0) {
					msg.addRecipients(Message.RecipientType.TO,
							InternetAddress.parse(atarget, false));
				}
			}

			msg.setSubject(subject);
			msg.setSentDate(new Date());

			Transport.send(msg);

		} catch (Exception e) {
			dm.mylog("Exception@sendmail : " + genLib.getStackTraceAsStringBuilder(e).toString());
			sbErr.append("Exception@sendmail : " + genLib.getStackTraceAsStringBuilder(e).toString());
			return false;
		} finally {
			msg = null;
		}

		return true;
	}
	
	//---------------------------------------------------------------------------------------------
	static void checkReceivedBytes(ddmClient ddmClient) {
		if (System.currentTimeMillis()>=ddmClient.next_save_received_bytes_ts && ddmClient.bytes_received_buffer>100) {
			ddmClient.next_save_received_bytes_ts=System.currentTimeMillis()+ddmClient.RECEIVE_BYTES_INTERVAL;
			for (int p=0;p<ddmClient.policyGroups.size();p++) {
				int policy_group_id=ddmClient.policyGroups.get(p);
				if (!ddmClient.dm.hmConfig.containsKey("IS_POLICY_GROUP_MONITORED_"+policy_group_id)) continue;
				getSetMonitoringReceivedBytesList(ddmClient.dm, ddmClient.bytes_received_buffer, ddmClient.proxy_session_id, policy_group_id, System.currentTimeMillis(), null, MONITORING_ACTION_SET, 0);
			}
		}
	}
}
