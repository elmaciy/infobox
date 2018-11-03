package com.mayatech.dm.protocolTds;

import java.nio.charset.Charset;
import java.util.ArrayList;

import com.mayatech.baseLibs.genLib;
import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmLib;

public class tdsMicrosoftSqlPackage {
	
	
	ddmClient ddmClient;
	
	boolean is_debug=false;
	String charset="UTF-16LE";
	int tdsVersion=8;
	
	byte[] originalBuf=null;
	public boolean isRewritablePackage=false;
	
	int package_type=0;
	int package_len=0;
	
	int sPProcShortcutId=0;
	String sPProcShortcutName=null;
	
	boolean hasSPProcShortcutId=false;
	boolean noMetaData=false;
	
	public String stmt=null;
	
	
	public ArrayList<tdsMicrosoftSqlRPCParam> rpcParameters=new ArrayList<tdsMicrosoftSqlRPCParam>();
	
	
	
	byte[] beforeStatementBytes=null;
	byte[] afterStatementBytes=null;
	
	//header ler atilip buraya parametre olarak gonderilmelidir. 
	
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
	//----------------------------------------------------------------------
	public void compile(
			ddmClient  ddmClient,
			byte[] buf, 
			int len, 
			int tdsVersion, 
			String charset) {
		
		this.ddmClient=ddmClient;
		
		
		
		if (ddmClient==null) 
			this.is_debug=true;
		else 
			this.is_debug=ddmClient.dm.is_debug || ddmClient.is_tracing;
		
		this.tdsVersion=tdsVersion;
		this.charset=charset;
		
		originalBuf=new byte[len];
		System.arraycopy(buf, 0, originalBuf, 0, len);
		
		if (len<10) return;
		
		
		try {
			package_type=(int) buf[0];
			
			if (package_type==tdsMicrosoftSqlLib.TDS_PACKAGE_TYPE_SQL_BATCH_REQUEST) 
				compileSqlBatch();
			else if (package_type==tdsMicrosoftSqlLib.TDS_PACKAGE_TYPE_RPC_REQUEST) 
				compileRPCRequest();
			else  
				mydebug("not a sql batch or rpc package");
		} catch(Exception e) {
			isRewritablePackage=false;
			e.printStackTrace();
			mylog("Exception@compileTdsPackage : ");
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
		}
		
		
		
		
		
	}
	
	//----------------------------------------------------------------------
	void compileSqlBatch() {
		if (is_debug) mydebug("compileSqlBatch");
		isRewritablePackage=true;
		
		int cursor=8;
		
		if (
				originalBuf[8]==(byte)  22 && 
				originalBuf[9]==(byte)  0  && 
				originalBuf[10]==(byte) 0 && 
				originalBuf[11]==(byte) 0 ) {
			
			beforeStatementBytes=new byte[22];
			
			System.arraycopy(originalBuf, 8, beforeStatementBytes, 0, 22);
			cursor+=22;
			
			if (is_debug) {
				mydebug("beforeStatementBytes :");
				printByteArray(beforeStatementBytes, beforeStatementBytes.length);
			}
		} 
		
		
		int len=originalBuf.length-cursor;
		
		
		
		stmt=new String(originalBuf,cursor,len,Charset.forName(charset));
		
		
		
		if (is_debug) 
			mydebug("stmt="+stmt);
		
		
	}
	//----------------------------------------------------------------------
	void compileRPCRequest() {
		if (is_debug)  mydebug("compileRPCRequest");
		
	
		//proc id verilecegi zaman 8 ve 9 nolu byte lar 255 ve 255 olur. yani short=-1
		//aksi takdirde burada kosturulacak procedure in adi ve oncesinde adinin uzunlugu yer alir

		int tmp=tdsMicrosoftSqlLib.readShort(this, originalBuf, 8);
		
		if (tmp==-1) {
			hasSPProcShortcutId=true;
			sPProcShortcutId=tdsMicrosoftSqlLib.readShort(this, originalBuf, 10);
			sPProcShortcutName=tdsMicrosoftSqlLib.getSpName(sPProcShortcutId);
			isRewritablePackage=tdsMicrosoftSqlLib.isRewritable(sPProcShortcutId);
			tmp=tdsMicrosoftSqlLib.readShort(this, originalBuf, 12);
			if (tdsMicrosoftSqlLib.readSwappedUnsignedShort(originalBuf,12)==1)  noMetaData=true;
				
			
			if (isRewritablePackage) compileRPCParameters();
		}
		
	}
	
	int readerCursor=0;
	
	//-----------------------------------------------------------------------
	void compileRPCParameters() {
		if (is_debug)  mydebug("compileRPCParameters");
		
		readerCursor=14;
		
		int original_buf_len=originalBuf.length;
		
		int param_bytes_start_pos=0;
		
		int param_no=0;

		
		while(true) {
			
			param_bytes_start_pos=readerCursor;
			
			param_no++;
			if (is_debug)  mydebug("reading param_no :"+param_no);
			
			int param_name_byte=tdsMicrosoftSqlLib.read(this, originalBuf, readerCursor);
			
			String parameter_name=null;
			String parametervalue_as_string=null;
			byte[] parametervalue_as_bytes=null;
			boolean isOutput=false;
			boolean isStatmentParameter=false;
			int tdsType=0;
			
			
			if (param_name_byte>0) {
				if (is_debug)  mydebug("param_name_byte :"+param_name_byte);
				int param_name_len=param_name_byte;
				parameter_name=tdsMicrosoftSqlLib.readString(this, originalBuf, readerCursor,param_name_len, charset);
			}
			
			int is_output_byte=tdsMicrosoftSqlLib.read(this, originalBuf, readerCursor);
			
			if (is_output_byte!=0) isOutput=true;
			
			tdsType=tdsMicrosoftSqlLib.read(this, originalBuf, readerCursor);
			param_bytes_start_pos=readerCursor;
			
			tdsMicrosoftSqlRPCParam newParam=new tdsMicrosoftSqlRPCParam();
			
			
			Object obj=readData(originalBuf, readerCursor, original_buf_len, tdsType, newParam.collationBytes);
			
			if (obj!=null) {
				
				if (obj instanceof String) {
					parametervalue_as_string=((String) obj).toString();
					
					//sp_prepare handle OUTPUT, params, stmt, options 
					if (sPProcShortcutId==tdsMicrosoftSqlLib.tds8SpNames_sp_prepare && param_no==3) isStatmentParameter=true;
					//sp_cursorprepare prepared_handle OUTPUT, params , stmt , options
					else if (sPProcShortcutId==tdsMicrosoftSqlLib.tds8SpNames_sp_cursorprepare && param_no==3) isStatmentParameter=true;
					//sp_executesql [ @stmt = ] statement 
					else if (sPProcShortcutId==tdsMicrosoftSqlLib.tds8SpNames_sp_executesql && param_no==1) isStatmentParameter=true;
					//sp_prepexecrpc handle OUTPUT, RPCCall 
					else if (sPProcShortcutId==tdsMicrosoftSqlLib.tds8SpNames_sp_prepexecrpc && param_no==2) isStatmentParameter=true;
					//sp_cursorprepexec prepared handle OUTPUT, cursor OUTPUT, params , statement , options
					else if (sPProcShortcutId==tdsMicrosoftSqlLib.tds8SpNames_sp_cursorprepexec && param_no==4) isStatmentParameter=true;
				}
						
						
				
			} 
			else {
				int param_as_bytes_len=readerCursor-param_bytes_start_pos;
				parametervalue_as_bytes=new byte[param_as_bytes_len];
				System.arraycopy(originalBuf, param_bytes_start_pos, parametervalue_as_bytes, 0, param_as_bytes_len);
				}
				
			
			
			
			
			newParam.TDSPackage=this;
			newParam.parameter_name=parameter_name;
			newParam.parametervalue_as_string=parametervalue_as_string;
			newParam.parametervalue_as_bytes=parametervalue_as_bytes;
			newParam.tdsType=tdsType;
			newParam.isOutput=isOutput;
			newParam.isStatmentParameter=isStatmentParameter;

			rpcParameters.add(newParam);
			
			
			if (isStatmentParameter) {
				
				int beforeLen=param_bytes_start_pos-1;
				int afterLen=original_buf_len-readerCursor;
				if (is_debug)  mydebug("isStatmentParameter found.");
				
				if (beforeLen>0) {
					beforeStatementBytes=new byte[beforeLen];
					System.arraycopy(originalBuf, 0, beforeStatementBytes, 0, beforeLen);
				}
				
				
				afterStatementBytes=new byte[afterLen];
				System.arraycopy(originalBuf, readerCursor, afterStatementBytes, 0, afterLen);
				
				if (is_debug)  {
					mydebug("beforeStatementBytes :");
					printByteArray(beforeStatementBytes, beforeStatementBytes.length);
				}
				
				
				if (is_debug)  {
					mydebug("afterStatementBytes :");
					printByteArray(afterStatementBytes, afterStatementBytes.length);
				}
				
				return;
			}
			
			if (readerCursor>=original_buf_len-1) return;
			 
			
			
		}
		
	}
	
	
	//-----------------------------------------------------------------------
	public void print() {
		
		if (!is_debug)  return;
		
		mydebug("originalBuf                 ....:");
		printByteArray(originalBuf, originalBuf.length);
		mydebug("package_type                ....:"+package_type);
		mydebug("package_len                 ....:"+package_len);
		mydebug("hasSPProcShortcutId         ....:"+hasSPProcShortcutId);
		mydebug("isRewritablePackage         ....:"+isRewritablePackage);
		mydebug("sPProcShortcut ID/Name      ....:"+sPProcShortcutId+"=>"+sPProcShortcutName);
		
		if (beforeStatementBytes!=null) {
			mydebug("beforeStatementBytes        ....:");
			printByteArray(beforeStatementBytes, beforeStatementBytes.length);
		}
		if (afterStatementBytes!=null) {
			mydebug("afterStatementBytes         ....:");
			printByteArray(afterStatementBytes, afterStatementBytes.length);
		}
		
		
		if (!isRewritablePackage) return;
		
		mydebug("noMetaData                  ....:"+noMetaData);
		
		if (package_type==tdsMicrosoftSqlLib.TDS_PACKAGE_TYPE_SQL_BATCH_REQUEST) {
			mydebug("stmt                        ....:"+stmt);			
		}
		else {
			mydebug("Parameter count             ....:"+rpcParameters.size());
			
			if (rpcParameters.size()>0) 
				for (int p=0;p<rpcParameters.size();p++) 
					rpcParameters.get(p).print(p+1);
			
			
			
		
		}
			
		
	}
	
	//---------------------------------------------------------
	int getTdsVersion() {
		return tdsVersion;
	}
	
	//---------------------------------------------------------
	void skipReader(int skip_count) {
		readerCursor+=skip_count;
	}
	 //--------------------------------------------------------
	 Object readData(byte[] buf, int offset, int buf_len, int  tdsType, byte[] collationBytes) {
		 
		 if (is_debug)  mydebug("readData from "+offset+"/"+buf_len+" for tdsType :"+tdsType);
		 
		 boolean isTds8 = getTdsVersion() >= 4;
		 
		 
		 
		 int len=0;
		 	
		 	
		    switch (tdsType)    {
		    //--------------------------------------------------------------------
		    case 38: //Integer or Long
		        tdsMicrosoftSqlLib.read(this, buf, readerCursor);
		        //means null
		        if (buf[readerCursor]==0) {
		        	//skip 0
		        	skipReader(1);
		        } else {
		        	int numberNextLen=tdsMicrosoftSqlLib.read(this, buf, readerCursor);
		        	skipReader(numberNextLen);
		        }
		        return null;
		    //--------------------------------------------------------------------
		    case 109: //Float or Double
		        tdsMicrosoftSqlLib.read(this, buf, readerCursor);
		        //means null
		        if (buf[readerCursor]==0) {
		        	//skip 0
		        	skipReader(1);
		        } else {
		        	int numberNextLen=tdsMicrosoftSqlLib.read(this, buf, readerCursor);
		        	skipReader(numberNextLen);
		        }
		      return null;
		    //--------------------------------------------------------------------
		    case 111:  //DateTime
		    	//skip len as 8
		    	skipReader(1);
		    	//skip 8 bytes for date time value
		    	skipReader(8);
		    	return null;
		    	//--------------------------------------------------------------------
		    case 50:  //Boolean
		    	//byte 0
		    	skipReader(1);
		    	return null;
			      //------------------------------------------------------------------------
		    case 104:  //Boolean
		    	//byte 1
		    	skipReader(1);
		    	if (buf[readerCursor]==0) 
		    		skipReader(1);
		    	else 
		    		skipReader(2);
		    	return null;
			      //------------------------------------------------------------------------
		    case 108:  //numeric
		    	//getMaxDecimalBytes
		    	skipReader(1);
		    	//prec
		    	skipReader(1);
		    	//scale
		    	skipReader(1);
		    	//scale
		    	skipReader(8);

		    	
		    	return null;
		      //------------------------------------------------------------------------
		    case 231: //BNVARCHAR

		    	//skip 8000
		    	skipReader(2);
		        if (isTds8) {
		        	System.arraycopy(buf, readerCursor, collationBytes, 0, 5);
		        	skipReader(5); //skip collation
		        }
		        
		        	
		    	len = tdsMicrosoftSqlLib.readShort(this, buf,readerCursor);
		    	mylog("String len : "+len);
		      if (len >-1) 
			        return tdsMicrosoftSqlLib.readNonUnicodeString(this, buf,readerCursor, len, charset);
		      else  
		    	  return null; 
		    //------------------------------------------------------------------------
		    case 241:  //xml
		    	//skip 0
		    	skipReader(1);
	        	if (
	        			buf[readerCursor+0]==(byte) 255 && 
	        			buf[readerCursor+1]==(byte) 255 && 
	        			buf[readerCursor+2]==(byte) 255 && 
	        			buf[readerCursor+3]==(byte) 255 &&
	        			buf[readerCursor+4]==(byte) 255 && 
	        			buf[readerCursor+5]==(byte) 255 && 
	        			buf[readerCursor+6]==(byte) 255 && 
	        			buf[readerCursor+7]==(byte) 255 
	        			) {
	        		//skipNull -1L
	        		skipReader(8);
		        	} 
	        	else {
		        		int xmlLen=tdsMicrosoftSqlLib.readInt(this, buf, readerCursor);
		        		//2 times read
		        		xmlLen=tdsMicrosoftSqlLib.readInt(this, buf, readerCursor);
		        		skipReader(xmlLen); 
		        		//skip last int as 0
		        		skipReader(4);
		        	}
		    	return null;
			      //---------------------------------------------------------------------
		    case 167 : //BVARCHAR
		    	byte byte_35=buf[readerCursor];
		    	
		    	if (byte_35==(byte) 35) {
		    		skipReader(1);
		    		tdsMicrosoftSqlLib.readInt(this, buf,readerCursor);
		    		
		    		if (isTds8) {
			        	System.arraycopy(buf, readerCursor, collationBytes, 0, 5);
			        	skipReader(5); //skip collation
			        }
		    		
		    		len=tdsMicrosoftSqlLib.readInt(this, buf,readerCursor);
		    		return tdsMicrosoftSqlLib.readNonUnicodeString(this, buf, readerCursor, len, charset);
		    		
		    	} else {
		    		//read 8000
		    		tdsMicrosoftSqlLib.readShort(this, buf,readerCursor);
		    		
		    		if (isTds8) {
			        	System.arraycopy(buf, readerCursor, collationBytes, 0, 5);
			        	skipReader(5); //skip collation
			        }
		    		
		    		len=tdsMicrosoftSqlLib.readShort(this, buf,readerCursor);
		    		if (len==-1) return null;
		    		
		    		return tdsMicrosoftSqlLib.readNonUnicodeString(this, buf,readerCursor, len, charset);
		    	}
			      //---------------------------------------------------------------------
		    case 99 : //ntext
		    	len=tdsMicrosoftSqlLib.readInt(this, buf,readerCursor);

		    	if (isTds8) {
		        	System.arraycopy(buf, readerCursor, collationBytes, 0, 5);
		        	skipReader(5); //skip collation
		        }
		    	len=tdsMicrosoftSqlLib.readInt(this, buf,readerCursor);

		    	return tdsMicrosoftSqlLib.readNonUnicodeString(this, buf,readerCursor, len, charset);
		    	
		      //---------------------------------------------------------------------
		    default: 
		      mylog("Unsupported TDS data type 0x" + Integer.toHexString(tdsType & 0xFF));
		      return null;
		    }


	  }
	
	 //-------------------------------------------------------------------------------------------------------------
	 public int getStatementParameterId() {
		 for (int i=0;i<rpcParameters.size();i++)
			 if (rpcParameters.get(i).isStatmentParameter) return i;
		 return -1;
	 }
	 //-------------------------------------------------------------------------------------------------------------
	 byte[] generateParameterBytes(tdsMicrosoftSqlRPCParam param) {
		 if (is_debug) mydebug("generateParameterBytes");
		 boolean isTds8 = getTdsVersion() >= 4;
		 
		 try {
			 boolean isNull=false;
			 if (param.parametervalue_as_string==null) {
				 param.tdsType=231;
				 isNull=true;
			 } else {
				 if (param.parametervalue_as_string.length()*2<=8000) 
					 param.tdsType=231;
				 else 
					if (param.tdsType==231) 
						param.tdsType=99;
			 }
				 
			int bufferLen=0;
			int cursor=0;
			
			byte buf[]=null;
			
			if (isNull) {
				bufferLen=100;
				buf=new byte[bufferLen];
				buf[0]=(byte) param.tdsType;
				cursor++;
				tdsMicrosoftSqlLib.writeSwappedShort(buf,cursor,(short) 8000);
				cursor+=2;
				if (isTds8) {
					System.arraycopy(param.collationBytes, 0, buf, cursor, param.collationBytes.length);
					cursor+=param.collationBytes.length;
				}
					
				tdsMicrosoftSqlLib.writeSwappedShort(buf,cursor,(short) -1);
				cursor+=2;
			}
			else {
				bufferLen=param.parametervalue_as_string.length()*2+100;
				buf=new byte[bufferLen];
				buf[0]=(byte) param.tdsType;
				cursor++;
				
				if (param.tdsType==231) {
					tdsMicrosoftSqlLib.writeSwappedShort(buf,cursor,(short) 8000);
					cursor+=2;
					if (isTds8) {
						System.arraycopy(param.collationBytes, 0, buf, cursor, param.collationBytes.length);
						cursor+=param.collationBytes.length;
					}
					
					byte[] strBuf=param.parametervalue_as_string.getBytes(charset);
					int strBufLen=strBuf.length;
					
					tdsMicrosoftSqlLib.writeSwappedShort(buf,cursor,(short) strBufLen);
					cursor+=2;
					
					System.arraycopy(strBuf, 0, buf, cursor, strBufLen);
					cursor+=strBufLen;
					
				} else if (param.tdsType==167) {
					buf[cursor]=(byte) 35;
					cursor++;
					
					byte[] strBuf=param.parametervalue_as_string.getBytes(charset);
					int strBufLen=strBuf.length;
					
					tdsMicrosoftSqlLib.writeSwappedInteger(buf,cursor,strBufLen);
					cursor+=4;
					
					if (isTds8) {
						System.arraycopy(param.collationBytes, 0, buf, cursor, param.collationBytes.length);
						cursor+=param.collationBytes.length;
					}
					
					tdsMicrosoftSqlLib.writeSwappedInteger(buf,cursor,strBufLen);
					cursor+=4;
					
					System.arraycopy(strBuf, 0, buf, cursor, strBufLen);
					cursor+=strBufLen;
					
				} else if (param.tdsType==99) {
					byte[] strBuf=param.parametervalue_as_string.getBytes(charset);
					int strBufLen=strBuf.length;
					
					tdsMicrosoftSqlLib.writeSwappedInteger(buf,cursor,strBufLen/2);
					cursor+=4;
					
					if (isTds8) {
						System.arraycopy(param.collationBytes, 0, buf, cursor, param.collationBytes.length);
						cursor+=param.collationBytes.length;
					}
					
					tdsMicrosoftSqlLib.writeSwappedInteger(buf,cursor,strBufLen);
					cursor+=4;
					
					System.arraycopy(strBuf, 0, buf, cursor, strBufLen);
					cursor+=strBufLen;
					
				} else {
					if (is_debug) mydebug("inappropriate tds type : "+param.tdsType);
					return null;
				}
				
			}
			
			
			byte[] ret1=new byte[cursor];
			System.arraycopy(buf, 0, ret1, 0, cursor);
			return ret1;
			 
		 } catch(Exception e) {
			mylog("Exception@generateParameterBytes :");
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			return null;
		 }
		 
		 
		 
	 }
	 //-------------------------------------------------------------------------------------------------------------
	 public void rePack(int maxPackageSize, ArrayList<byte[]> packArr, ArrayList<Integer> sizeArr) {
		 ArrayList<byte[]> byteChunks=new ArrayList<byte[]>();
		 
		 mydebug("///////////// rePack : "+package_type+" stmt :"+stmt);
		 
		 if (package_type==tdsMicrosoftSqlLib.TDS_PACKAGE_TYPE_SQL_BATCH_REQUEST) {
			 if (!isRewritablePackage) {
				 byteChunks.add(originalBuf);
			 } else {
				 byte[] headerBuf=new byte[8];
				 System.arraycopy(originalBuf, 0, headerBuf, 0, 8);
				 byteChunks.add(headerBuf);
				 if (beforeStatementBytes!=null) 
					 byteChunks.add(beforeStatementBytes);
				 
				try {
					if (is_debug) 
						mydebug("//////////////// stmt="+stmt);
					
					byte[] strBuf=stmt.getBytes(Charset.forName(charset));
					byteChunks.add(strBuf);
				} catch(Exception e) {
					mylog("Exception@rePack :");
					mylog(genLib.getStackTraceAsStringBuilder(e).toString());
					byteChunks.clear();
					byteChunks.add(originalBuf);
				}
			 }
		 }
		else if (package_type==tdsMicrosoftSqlLib.TDS_PACKAGE_TYPE_RPC_REQUEST)  {
			if (!isRewritablePackage || beforeStatementBytes==null || afterStatementBytes==null) {
				 byteChunks.add(originalBuf);
			 } else {
				 int stmtParameterIndex=getStatementParameterId();
				 
				 if (stmtParameterIndex==-1) 
					 byteChunks.add(originalBuf);
				 else {
					
					 tdsMicrosoftSqlRPCParam stmtParam=rpcParameters.get(stmtParameterIndex);
					 
					
					 
					 byte[] stmtParamBytes=generateParameterBytes(stmtParam);
					 if (stmtParamBytes==null) {
						 if (is_debug) mydebug("generateParameterBytes returns null");
						 byteChunks.add(originalBuf);
					 } else {
						 if (is_debug)  {
							 mydebug("generateParameterBytes :");
							 printByteArray(stmtParamBytes, stmtParamBytes.length);
						 }
						 
						 
						 byteChunks.add(beforeStatementBytes);
						 byteChunks.add(stmtParamBytes);
						 byteChunks.add(afterStatementBytes);
					 }
						
				 }
				 
				 
			 }
		} //if (package_type==tdsLib.TDS_PACKAGE_TYPE_RPC_REQUEST)
		else {
			byteChunks.add(originalBuf);
		}
		 
		 
		 //-----------------------------------------------------------

		 
		 int sum_len=0;
		 
		 for (int i=0;i<byteChunks.size();i++) {
			 if(is_debug) 
				 printByteArray(byteChunks.get(i), byteChunks.get(i).length);
			 sum_len+=byteChunks.get(i).length;
		 }
		 
		 byte[] buf=new byte[sum_len];
		 int cursor=0;
		 for (int i=0;i<byteChunks.size();i++) {
			 System.arraycopy(byteChunks.get(i), 0, buf, cursor, byteChunks.get(i).length);
			 cursor+=byteChunks.get(i).length;
		 }
		 
		 int buf_len=buf.length;
		 
		 if (is_debug) { 
			 mydebug("concatanated buffer :");
			printByteArray(buf,buf_len);
		 }
			 
		 byte[] header=new byte[8];
		 System.arraycopy(buf, 0, header, 0, 8);
		 header[1]=(byte) 0;
		 cursor=8;
		
		 
		 while(true) {
			 boolean last_pack=false;
			 int next_pos=cursor+maxPackageSize-8;
			 if (next_pos>=buf_len) {
				 next_pos=buf_len;
				 last_pack=true;
			 }
			 int packSize=next_pos-cursor+8;
			 byte[] aPack=new byte[packSize];
			 System.arraycopy(header, 0, aPack, 0, 8);
			 if (last_pack)  
				 aPack[1]=(byte) 1;
			 System.arraycopy(buf, cursor, aPack, 8, packSize-8);
			 
			 //tdsLib.writeSwappedShort(aPack,2,(short) packSize);
			 
			 byte[] packageLengthByteArr=ddmLib.makeLengthFor2Bytes(packSize);
			 System.arraycopy(packageLengthByteArr, 0, aPack, 2, 2);
			 
			 packArr.add(aPack);
			 sizeArr.add(packSize);
			 
			 cursor=next_pos;
			 
			 if (last_pack) break;
		 }


		 
	 }
	
}
