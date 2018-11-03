package com.mayatech.dm;


import java.io.DataOutputStream;
import java.io.IOException;
import java.nio.ByteOrder;
import java.nio.charset.Charset;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.Date;

import org.bson.BasicBSONDecoder;
import org.bson.BasicBSONEncoder;

import com.mayatech.baseLibs.genLib;
import com.mayatech.dm.dmMsSqlParser.msSqlParser;
import com.mayatech.dm.dmMsSqlParser.msSqlSTMT;
import com.mayatech.dm.dmOracleParser.oracleParser;
import com.mayatech.dm.dmOracleParser.oracleSTMT;
import com.mayatech.dm.dmPostgreSQLParser.postgreParser;
import com.mayatech.dm.dmPostgreSQLParser.postgreSTMT;
import com.mayatech.dm.protocolPostgrewire.postgreWirePackage;
import com.mayatech.dm.protocolTds.tdsMicrosoftSqlPackage;
import com.mayatech.dm.protocolTds.tdsMicrosoftSqlRPCParam;
import com.mayatech.dm.protocolTns.oracleTnsLib;
import com.mayatech.dm.protocolTns.oracleTnsPackage;



public class ddmClient {

	public Connection connParallel=null;
	
	public ddmProxyServer dm=null;
	
	boolean client_cancelled=false;
	int client_iddle_timeout=0;
	int client_calendar_id=0;
	
	int client_session_validation_id=0;
	long session_validation_start_ts=	System.currentTimeMillis()+0;
	long session_validation_end_ts=		System.currentTimeMillis()+30000;
	long session_limit_ts=		System.currentTimeMillis()+120*60*60*1000;
	int max_session_validation_attempt_count=1;
	int session_validation_attempt_count=0;
	boolean session_validated=false;
	
	
	boolean save_received_bytes=true;
	static int RECEIVE_BYTES_INTERVAL=5000;
	long next_save_received_bytes_ts=System.currentTimeMillis()+RECEIVE_BYTES_INTERVAL;
	int bytes_received_buffer=0;
	

	boolean client_log_statement=false;
	
	String DB_VERSION="";
	
	public String session_oracle_session_id="";
	public String session_sid="";
	public String session_serial_num="";
	public String session_username="";
	public String session_osuser="";
	public String session_machine="";
	public String session_terminal="";
	public String session_program="";
	public String session_module="";
	public String session_client_version="";
	public String session_client_driver="";
	public String session_client_oci_library="";
	public String session_granted_roles="";
	public String session_authentication_type="";
	public String session_proxy_client_name="";



	
	int statement_package_no=0;
	
	
	public String proxy_session_id="";
	
	int max_package_size=2048;
	int oracle_package_version_number=0;
	int oracle_protocol_characteristic=0;
	
	boolean temporary_exception_flag=false;
	boolean calendar_exception_flag=false;
	boolean user_exception_flag=false;
	
	
	
	ArrayList<String[]> sessionInfoForConnArrChanged=new ArrayList<String[]>();
	
	ArrayList<String[]> sessionInfoForConnArr=new ArrayList<String[]>();
	
	String CLIENT_HOST_ADDRESS="unknown";
	int CLIENT_PORT=0;
	
	boolean is_authorized=false;
	
	public boolean is_tracing=false;
	
	
	
	long client_start_ts=System.currentTimeMillis();
	long client_last_configuration_ts=System.currentTimeMillis();
	
	
	long last_statement_start_ts=0;
	
	static final int STATEMENT_BUILD_TIMEOUT=500;
	
	
	static short STATE_START=0;
	static short STATE_NO_DATA_PACKAGE=1;
	static short STATE_STATEMENT_BUILDING=10;
	static short STATE_STATEMENT_COMPLETED=20;
	static short STATE_FETCHING_MORE=100;
	
	

	short package_state=STATE_START;
	
	
	
	
	ArrayList<byte[]> bufferArr=new ArrayList<byte[]>();
	int buffer_len=0;
	
	
	
	ArrayList<byte[]> stmtByteBufferArr=new ArrayList<byte[]>();
	
	int stmtByteBufferArr_len=0;
	
	StringBuilder sql_statement=new StringBuilder();
	StringBuilder sql_statement_masked=new StringBuilder();

	
	StringBuilder sqlToExecuteInParallel=new StringBuilder();

	boolean is_rewritable_statement=false;
	
	long proxy_instance_start_ts=System.currentTimeMillis();
	
	
	static final int SQL_LOGGING_START_INTERVAL=5000;
	
	
	int record_limit=0;
	
	ArrayList<Date[]> calendarExceptionArr=new ArrayList<Date[]>();
	
	
	//------------------------------------------------------------------------------------------
	public ddmClient(ddmProxyServer dm) {
		this.dm=dm;
		
		max_package_size=dm.MAX_PACKAGE_SIZE;
				
		is_tracing=dm.is_debug;
	}
	
	
	//--------------------------------------------------------------------------------------------
	
	StringBuilder localLog=new StringBuilder();
	
	static final String lineBreak=System.getProperty("line.separator");
	static final String log_sep1="@";
	static final String log_sep2=": ";
	static final String log_tab="\t";

	static boolean log_immediate_write=false;
	
	//------------------------------------------------------------
	public void mydebug(String logstr) {
		//System.out.println(logstr);
		if (!dm.is_debug && !is_tracing) return;
		if (log_immediate_write) {
			System.out.println(logstr);
		} 
		else
			mylog(logstr);
	}
	
	//----------------------------------------------------------------
	void mylogNLF(String logstr) {
		//System.out.print(logstr);
		
		if (log_immediate_write) {
			System.out.print(logstr);
		}
		else {
			try {localLog.append(logstr);} catch(Exception e) {}
		}
		
	}
	
	//------------------------------------------------------------
	public void mylog(String logstr) {
		
		if (log_immediate_write) {
			System.out.print(logstr);
			return;
		}
		
		try {
			
			localLog.append(proxy_session_id);
			localLog.append(log_sep1);
			localLog.append(new Date().toString());
			localLog.append(log_sep2);
			localLog.append(logstr);
			localLog.append(lineBreak);
		} catch(Exception e) {
			
		}
		
		
		
		
		
		//System.out.println(logstr);
	}
	
	
	
	//-----------------------------------------------------------------------

	public  void printByteArray(byte[] buf, int len) {
		printByteArray(buf, 0, len);
	}
	
	
	//-----------------------------------------------------------------------
	static final String visible_chars=new String(" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456456789*()_.?;:<>=\"'\\/@$+-*,`");

	public  void printByteArray(byte[] buf, int start, int len) {
	
	if (!dm.is_debug && !is_tracing) return;
	
	try {
		StringBuilder sb=new StringBuilder();
		boolean truncated=false;
		int target=start+len;
		if (len>16348) {
			target=start+16348;
			truncated=true;
		}
		
		for (int i=start;i<target;i++) {
			if (ddmLib.visible_chars.indexOf(buf[i])>-1)
				//System.out.print(new String(buf,i,1));
				sb.append(new String(buf,i,1));
			else 
				//System.out.print("["+ ddmLib.byte2UnsignedInt(buf[i])   +"]");
				sb.append("["+ ddmLib.byte2UnsignedInt(buf[i])   +"]");
		}
		
		if(truncated) sb.append("...[?truncated?]");
		
		//System.out.println("");
		sb.append("\n");
		
		mydebug(sb.toString());
	} catch(Exception e) {
		e.printStackTrace();
	}
		
	
	
	}
	
	
	//------------------------------------------------------------
	long last_log_flush_ts=0;
	static final int LOG_FLUSH_INTERVAL=2000;
	
	void flushlogs(boolean force) {
		
		if (System.currentTimeMillis()<last_log_flush_ts+LOG_FLUSH_INTERVAL && !force) return;
		
		if (localLog.length()==0) return;
		
		
		dm.addNewLog(localLog);
		
		localLog.setLength(0);
		
		last_log_flush_ts=System.currentTimeMillis();
	}
	
	//------------------------------------------------------------
	
	
	
	
	public void feedOraclePack( 
			byte[] buf, 
			int len, 
			DataOutputStream to_server_stream
			) {
		

		int cursor=0;
		
		
		while(true) {
			
			int package_size=ddmLib.getPackageLength(buf, cursor);
			
			byte package_type=buf[cursor+4];
			
			//Connect
			if (!is_authorized && package_type== (byte) 0x1 &&  oracle_protocol_characteristic==0) {
				oracle_protocol_characteristic=buf[18]*256+buf[19];
				mydebug("Oracle Protocol Characteristics : " + oracle_protocol_characteristic);
			}
			
						
			if (package_type==(byte) 0x6 &&  package_size>20) {
		
				//[0][17][0][0] 	[6][0][0][0] 	[0][0]	[3][5]
				if (buf[cursor+10]==0x03 && buf[cursor+11]==0x05 ) {
					package_state=STATE_FETCHING_MORE;
				} 
				else {
					try {
						feedOracleSinglePack(buf, cursor, package_size, len);
					} catch(Exception e) {
						e.printStackTrace();
						clearPackage();
						package_state=STATE_START;
					}

				}
				
				
			} else 
				package_state=STATE_NO_DATA_PACKAGE;
			
			
			
			//-------------------------------------------------------------------------------------

			if (package_state==STATE_START) {
				if(dm.is_debug || is_tracing) mydebug("STATE_START");
				
				bufferArr.clear();
				buffer_len=0;
				last_statement_start_ts=System.currentTimeMillis();
				
				
				sendBuffer(to_server_stream, buf, cursor, package_size);
				restartPackage();
				
				
			}
			else if (package_state==STATE_STATEMENT_BUILDING) {
				
				last_statement_start_ts=System.currentTimeMillis();
				
				if(dm.is_debug || is_tracing) mydebug("STATE_STATEMENT_BUILDING : Waiting for more sql statement from client... ");
			}
			
			else if (package_state==STATE_STATEMENT_COMPLETED) {
				mydebug("STATE_STATEMENT_COMPLETED");
				

				resendOraclePackage(to_server_stream);

				
				if (sqlToExecuteInParallel.length()>0) {
					boolean is_ok=true;
					StringBuilder sberr=new StringBuilder();
					
					if (sqlToExecuteInParallel.toString().toUpperCase().contains("ALTER") && sqlToExecuteInParallel.toString().toUpperCase().contains("CURRENT_SCHEMA")) {
						mydebug("----------------------------------------------------");
						mydebug("--------    RUNNING PARALLEL STATEMENT       -------");
						mydebug("----------------------------------------------------");
						mydebug(sqlToExecuteInParallel.toString());

						is_ok=ddmLib.execSingleUpdateSQL(connParallel, sqlToExecuteInParallel.toString(), null, false, 0, sberr);
					}
					
					
					
					mydebug("Execution Returns : "+ is_ok); 
					if (!is_ok) mydebug("Execution err: "+sberr.toString());
					
					if (is_ok && sqlToExecuteInParallel.toString().toUpperCase().contains("CURRENT_SCHEMA") ) {
						setCurrentSchemaForOracle();
						ddmLib.setSessionKey(this,"CURRENT_SCHEMA",CURRENT_SCHEMA);
					}
					
					//ilk 1-2 saniye icinde calistirilan DBMS_APPLICATION_INFO komutlarindan sonra session verileri reload edilir. 
					
					if (sqlToExecuteInParallel.toString().toUpperCase().contains(DBMS_APPLICATION_INFO)) {
							if (System.currentTimeMillis()<(client_start_ts+2000))  {
								mydebug("DBMS_APPLICATION_INFO detected. Refreshing client session info");
								setVariablesFromORACLEDb();
								client_last_configuration_ts=dm.last_configuration_load_time-1000;
							}
								
					}
						

					sqlToExecuteInParallel.setLength(0);
					mydebug("----------------------------------------------------");
				} // if (sqlToExecuteInParallel.length()>0)
				
				
				restartPackage();
				
				bufferArr.clear();
				
			}
			else if (package_state==STATE_FETCHING_MORE) {
				if(dm.is_debug || is_tracing) mydebug("STATE_FETCHING_MORE: Client fetches more more data... ");
				
				
				sendBuffer(to_server_stream, buf, cursor, package_size);
				restartPackage();
			}
			else if (package_state==STATE_NO_DATA_PACKAGE) {
				if(dm.is_debug || is_tracing) mydebug("STATE_NO_DATA_PACKAGE : Not a DATA package... ");
				
				sendBuffer(to_server_stream, buf, cursor, package_size);
				restartPackage();
			}
			else {
				if(dm.is_debug || is_tracing) mydebug("!!! UNKNOWN_PACKAGE_STATE    : "  +package_state);
				
				sendBuffer(to_server_stream, buf, cursor, package_size);
				restartPackage();
			}
			
			
			
			
			//-------------------------------------------------------------------------------------
			
			
			
			cursor+=package_size;
			
			if (cursor>=len)  break;
			
			
			
			
		} //while 
		
		
		try {
			to_server_stream.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}

		
	}
	
	//------------------------------------------------------------
	void sendBuffer(DataOutputStream to_server_stream, byte[] buf, int start, int len) {
		
		if (dm.is_debug || is_tracing) {
			mydebug("sendBuffer (start="+start+", len="+len+") : ");
			printByteArray(buf, start, len);
		}
			
		
		try {
			to_server_stream.write(buf, start, len);
			to_server_stream.flush();
		} catch(Exception e) {
			e.printStackTrace();
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
		}
	}
	
	//------------------------------------------------------------
	void restartPackage() {
		mydebug("Restarting package");
		package_state=STATE_START;
	}
	//------------------------------------------------------------
	void clearPackage() {
		
		statement_package_no=0;
		
		bufferArr.clear();
		buffer_len=0;
		
		
		is_rewritable_statement=false;
		
		
		
		sql_statement.setLength(0);
		
		stmtByteBufferArr.clear();
		stmtByteBufferArr_len=0;
			
	}
	
	//------------------------------------------------------------
	
	
	
	
	byte[] BYTES_QUERY=				new byte[]{ (byte) 3,  (byte) 94 };
	
	
	//static final int QUERY_BYTES_LEN=7;
	//static final int QUERY_EXTENTION_BYTES_LEN=8;
	
	//--------------------------------------------------------------------------------------------------------
	void feedOracleSinglePack(byte[] buf, int cursor, int this_package_len, int full_package_len) {
		
		mydebug("feedOracleSinglePack : state :"+package_state);
		
		printByteArray(buf, cursor, this_package_len);
		
		
		int tmp_query_bytes_query_pos=ddmLib.IndexOfByteArray(buf,cursor,cursor+this_package_len,BYTES_QUERY);
		if (tmp_query_bytes_query_pos>-1 && tmp_query_bytes_query_pos<50 && package_state==STATE_STATEMENT_COMPLETED) {
			clearPackage();
			package_state=STATE_START;
		}
		
		
		if (package_state==STATE_STATEMENT_BUILDING) {
			
			byte[] packBuf=new byte[this_package_len];
			System.arraycopy(buf, cursor, packBuf, 0, this_package_len);
			bufferArr.add(packBuf);
			buffer_len+=packBuf.length;
			statement_package_no++;
			
			if (isLastOraclePackage(packBuf,  this_package_len)) 
				package_state=STATE_STATEMENT_COMPLETED;
			
		}
		
		if (package_state==STATE_START) {
			
			clearPackage();
			
			int query_bytes_pos=ddmLib.IndexOfByteArray(buf,cursor,cursor+this_package_len,BYTES_QUERY);
			
			if (query_bytes_pos==-1) {
				mydebug("!Not a command package.");
				package_state=STATE_START;
				return;
			}
			
			byte[] packBuf=new byte[this_package_len];
			System.arraycopy(buf, cursor, packBuf, 0, this_package_len);
			bufferArr.add(packBuf);
			buffer_len+=packBuf.length;
			
			statement_package_no++;
			
			package_state=STATE_STATEMENT_BUILDING;
			
			if (isLastOraclePackage(packBuf,  this_package_len)) 
				package_state=STATE_STATEMENT_COMPLETED;
			
		} // if package_stat=START
		
		mydebug("package_state       : "+package_state);
		
	}
	
	//****************************************************************
	boolean isLastOraclePackage(byte[] buf, int this_package_len) {
		
		int invisible_char_count=0;
		int check_limit=this_package_len-50;
		try {
			for (int i=this_package_len-1;i>=check_limit;i--) {
				if (buf[i]==(byte) 0x00 || buf[i]==(byte) 0x01) invisible_char_count++;
				if (invisible_char_count>3) {
					mydebug("Last Package : "+statement_package_no);
					return true;
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
			return true;
		}
		
		
		mydebug("Continuing Package : "+statement_package_no);
		return false;
	}
	//****************************************************************
	void appendStatementByteArray(byte[] buf) {
		
		stmtByteBufferArr.add(buf);
		stmtByteBufferArr_len+=buf.length;
		
	}
	
	
	//***************************************************************
	ArrayList<String[]> bindList=new ArrayList<String[]>();
	
	int ORADISC_discovered_package_count=0;
	
	//***************************************************************
	boolean checkSqlExceptionList(StringBuilder orig_sql, StringBuilder new_sql) {
		
		int hashcode=orig_sql.toString().hashCode();
		
		if (dm.hmConfig.contains("SQL_EXCEPTION_FOR_"+hashcode)) {
			return (boolean) dm.hmConfig.contains("SQL_EXCEPTION_FOR_"+hashcode);
		}
		
		boolean ret1=false;
		
		
		for (int i=0;i<dm.sqlStatementExceptionRules.size();i++) {
			String check_field=dm.sqlStatementExceptionRules.get(i)[0];
			String check_rule=dm.sqlStatementExceptionRules.get(i)[1];
			String check_parameter=dm.sqlStatementExceptionRules.get(i)[2];
			//String new_command=dm.sqlStatementExceptionRules.get(i)[3];
			String case_sensitive=dm.sqlStatementExceptionRules.get(i)[4];
			
			boolean is_matched=false;
			
			if (check_field.equals("SQL"))
				is_matched=ddmLib.testRule(orig_sql.toString(), check_rule, check_parameter, case_sensitive);
			else {
				
				String statement_type=ddmLib.getStatementType(dm, orig_sql.toString());
				is_matched=ddmLib.testRule(statement_type, check_rule, check_parameter, "NO");
			}
				
			
			if (is_matched) {
				new_sql.setLength(0);
				String new_command=dm.sqlStatementExceptionRules.get(i)[3];
				new_sql.append(new_command);
				ret1=true;
				break;
			}
		}
		
		dm.hmConfig.put("SQL_EXCEPTION_FOR_"+hashcode, ret1);
		
		return ret1;
		
		
	}
	
	
	
	byte[] collectedBytes=null;
	int collectedByteLen=0;
	
	boolean analyseOracleSqlPackage() {
		
		if (bufferArr.size()==0) 
			return false;
		
		collectedBytes=new byte[buffer_len];
		collectedByteLen=0;
		
		
		boolean to_debug=dm.is_debug || is_tracing;
		
		
		
		for (int i=0;i<bufferArr.size();i++) {
			byte[] buf=bufferArr.get(i);
			int buf_len=buf.length;
			if (to_debug) mydebug("PACK["+i+"] :");
			printByteArray(buf, buf_len);
			int start_from=0;
			if (i>0) start_from=10;
			System.arraycopy(buf, start_from, collectedBytes, collectedByteLen, buf_len-start_from);
			collectedByteLen+=buf_len-start_from;
		} // for 1
		
		if (to_debug)  {
			mydebug("*** collectedBytes : "+collectedByteLen);
			printByteArray(collectedBytes, collectedByteLen);
		}
		
		
		ORADISC_discovered_package_count++;


		if (oracle_protocol_characteristic==20120 || oracle_protocol_characteristic==-14834) {
			oracleTnsPackage=new oracleTnsPackage();
			oracleTnsPackage.compile(this, collectedBytes, collectedByteLen, oracle_package_version_number, oracle_protocol_characteristic, dm.proxy_encoding);
			
			if (oracleTnsPackage.is_invalid || oracleTnsPackage.sql_statement==null) return false;
			
			sql_statement.append(oracleTnsPackage.sql_statement);
			
			return true;
		}
		
		
		
		
		

		return false;
		
	}


	
	//**********************************************************************************************************************************
	
	public boolean ORADISC_first_byte_analyzed=false;
	public boolean ORADISC_first_byte_as_length=false;
	public boolean ORADISC_is_chunk_discovered=false;
	public int ORADISC_chunk_style=oracleTnsLib.CHUNK_STYLE_NONE;
	public int ORADISC_chunk_limit=0;
	
	void printProtocolParametersForOracle() {
		
		if(dm.is_debug || is_tracing) {
			
			mydebug("=============================================================================================== ");
			mydebug("oracle_package_version_number....................... : "+oracle_package_version_number);
			mydebug("oracle_protocol_characteristic...................... : "+oracle_protocol_characteristic);
			mydebug("ORADISC_discovered_package_count ................... : "+ORADISC_discovered_package_count);
			mydebug("ORADISC_first_byte_analyzed......................... : "+ORADISC_first_byte_analyzed);
			mydebug("ORADISC_first_byte_as_length........................ : "+ORADISC_first_byte_as_length);
			mydebug("ORADISC_is_chunk_discovered ........................ : "+ORADISC_is_chunk_discovered);
			mydebug("ORADISC_chunk_style................................. : "+ORADISC_chunk_style+" ( 1:[254]@s, 2:[254][149][20][0][0]s, 3:[254][2][3][31]s )");
			mydebug("ORADISC_chunk_limit................................. : "+ORADISC_chunk_limit);
			mydebug("=============================================================================================== ");
			
			
		}
			
		

	}
	
	//**********************************************************************************************************************************
	
	String extra_args="";
	
	
	
	
	int GEN_PAR_Masking_Skip_Time=0;
	
	
	
	
	//****************************************************************
	void sendSavedPackages(DataOutputStream to_server_stream) {
		
		
		for (int i=0;i<bufferArr.size();i++) {
			
			byte[] buf=bufferArr.get(i);
			int buf_len=buf.length;
			
			try {
				if (dm.is_debug || is_tracing) {
					mydebug("Sending original pack "  + (i+1)+" : Length : " + buf_len);
					printByteArray(buf,  buf_len);
				}
				
				to_server_stream.write(buf, 0, buf_len);
				to_server_stream.flush();
				
			} catch(Exception e) {
				e.printStackTrace();
			} 
			
		}
		
		//try {to_server_stream.flush();} catch(Exception e) {e.printStackTrace();} 
	
		clearPackage();
	}
	
	


	//****************************************************************
	
	void maskOracleSqlCommandWithParser() {
		
		if (dm.checkClearCacheNeededForOracle(sql_statement.toString())) {
			mylog("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			mylog("Cache is clearing since refreshing statement found :"+sql_statement.toString());
			mylog("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			dm.hmCache.clear();
		}
		
		
		
		try {
			sql_statement_masked.setLength(0);
			sql_statement_masked.append(sql_statement.toString());
			
			ArrayList<Integer[]> locations=new ArrayList<Integer[]>();
			ArrayList<String> selectQueries=new ArrayList<String>();
			
			oracleParser.locateSelectQueries(sql_statement.toString(), 0, locations, selectQueries);
			
			for (int i=selectQueries.size()-1;i>=0;i--) {
				Integer[] loc=locations.get(i);
				oracleSTMT stmt=oracleParser.parse(selectQueries.get(i) ,null, this);
				
				String rewritten_sql=stmt.rewriteSingleSQL(this, false, true, null);
				
				ddmLib.checkMonitoring(this, stmt,i);
				
				sql_statement_masked.delete(loc[0], loc[01]);
				sql_statement_masked.insert(loc[0], rewritten_sql+" ");
			}
			
			
			mydebug("??????????????????????????????????????????????????????????????????????????????");
			mydebug(this.sql_statement_masked.toString());
			mydebug("??????????????????????????????????????????????????????????????????????????????");
			
		} catch(Exception e) {
		
			sql_statement_masked.setLength(0);
			sql_statement_masked.append(sql_statement.toString());

			
			mylog("Exception@maskOracleSqlCommandWithParser MSG : "+e.getMessage());
			mylog("Exception@maskOracleSqlCommandWithParser SQL : "+sql_statement.toString());
			mylog("_________________________________________________________________________");
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			mylog("_________________________________________________________________________");
		}
		
		
		
		
	}



	//****************************************************************
	
	void maskPostgreSqlCommandWithParser() {
		
		if (dm.checkClearCacheNeededForPostgreSQL(sql_statement.toString())) {
			mylog("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			mylog("Cache is clearing since refreshing statement found :"+sql_statement.toString());
			mylog("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			dm.hmCache.clear();
		}
		
		
		
		try {
			sql_statement_masked.setLength(0);
			sql_statement_masked.append(sql_statement.toString());
			
			ArrayList<Integer[]> locations=new ArrayList<Integer[]>();
			ArrayList<String> selectQueries=new ArrayList<String>();
			
			postgreParser.locateSelectQueries(sql_statement.toString(), 0, locations, selectQueries);
			
			for (int i=selectQueries.size()-1;i>=0;i--) {
				Integer[] loc=locations.get(i);
				postgreSTMT stmt=postgreParser.parse(selectQueries.get(i) ,null, this);
				
				String rewritten_sql=stmt.rewriteSingleSQL(this, false, true, null);
				
				
				sql_statement_masked.delete(loc[0], loc[01]);
				sql_statement_masked.insert(loc[0], rewritten_sql+" ");
			}
			
			
			mydebug("??????????????????????????????????????????????????????????????????????????????");
			mydebug(this.sql_statement_masked.toString());
			mydebug("??????????????????????????????????????????????????????????????????????????????");
			
		} catch(Exception e) {
		
			sql_statement_masked.setLength(0);
			sql_statement_masked.append(sql_statement.toString());

			
			mylog("Exception@maskPostgreSqlCommandWithParser MSG : "+e.getMessage());
			mylog("Exception@maskPostgreSqlCommandWithParser SQL : "+sql_statement.toString());
			mylog("_________________________________________________________________________");
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			mylog("_________________________________________________________________________");
		}
		
		
		
		
	}
	//************************************************************************************************
	boolean checkStatementForOracleT2() {
		boolean to_be_masked=false;
		
		long start_ts=System.currentTimeMillis();
		
		
		
		sql_statement_masked.setLength(0);
		sql_statement_masked.append(sql_statement.toString());
		
		boolean is_sql_in_exception_list=checkSqlExceptionList(sql_statement, sql_statement_masked);
		
		if (is_sql_in_exception_list) {
			if(dm.is_debug || is_tracing)  mydebug("Sql is modified since it is in statement exception list : " + sql_statement_masked.toString());
			is_rewritable_statement=false;
			bindList.clear();
			to_be_masked=true;
		} //if (is_sql_in_exception_list)
		else {
			
			maskOracleSqlCommandWithParser();
			
			ddmLib.validateSession(this);
			
			to_be_masked=true;
			if (sql_statement.length()==sql_statement_masked.length()) to_be_masked=false;
			
			long log_ts=System.currentTimeMillis();
			
			if (client_log_statement && System.currentTimeMillis()>proxy_instance_start_ts+SQL_LOGGING_START_INTERVAL)
				ddmLib.addProxyEvent(
						dm,
						dm.proxyEventArray, 
						dm.SQL,
						""+log_ts,
						genLib.nvl(CURRENT_CATALOG, "${default}")+"."+CURRENT_SCHEMA,
						sql_statement.toString(),
						sql_statement.toString(),
						sql_statement_masked.toString(),
						this.proxy_session_id,
						"",
						null,
						"0" //sampleData.size()
						);
			
			
		}
		
		if(dm.is_debug || is_tracing)  mydebug("checkOracleStatement returns masked:  "+to_be_masked+" in "+(System.currentTimeMillis()-start_ts) +" msecs");
		
		return to_be_masked;
	}
	
	
	//*************************************************************************************************
	boolean checkStatementForPOSTGRESQL() {
		boolean to_be_masked=false;
		
		long start_ts=System.currentTimeMillis();
		
		
		
		sql_statement_masked.setLength(0);
		sql_statement_masked.append(sql_statement.toString());
		
		boolean is_sql_in_exception_list=checkSqlExceptionList(sql_statement, sql_statement_masked);
		
		if (is_sql_in_exception_list) {
			if(dm.is_debug || is_tracing)  mydebug("Sql is modified since it is in statement exception list : " + sql_statement_masked.toString());
			is_rewritable_statement=false;
			bindList.clear();
			to_be_masked=true;
		} //if (is_sql_in_exception_list)
		else {
			
			maskPostgreSqlCommandWithParser();

			ddmLib.validateSession(this);
			
			to_be_masked=true;
			if (sql_statement.length()==sql_statement_masked.length()) to_be_masked=false;
			
			long log_ts=System.currentTimeMillis();
			
			
			if (client_log_statement && System.currentTimeMillis()>proxy_instance_start_ts+SQL_LOGGING_START_INTERVAL)
				ddmLib.addProxyEvent(
						dm,
						dm.proxyEventArray, 
						dm.SQL,
						""+log_ts,
						genLib.nvl(CURRENT_CATALOG, "${default}")+"."+CURRENT_SCHEMA,
						sql_statement.toString(),
						sql_statement.toString(),
						sql_statement_masked.toString(),
						this.proxy_session_id,
						"",
						null,
						"0" //sampleData.size()
						);
			
			
		}
		
		if(dm.is_debug || is_tracing)  mydebug("checkStatementForPOSTGRESQL returns masked:  "+to_be_masked+" in "+(System.currentTimeMillis()-start_ts) +" msecs");
		
		return to_be_masked;
	}
	//****************************************************************
	
	void resendOraclePackage(
			DataOutputStream to_server_stream
			) {
		

		
		boolean is_analysed=analyseOracleSqlPackage();
		
		if (!is_analysed) {
			mydebug("Oracle package analysis error.");
			sendSavedPackages(to_server_stream);
			
			return;
		}
		
		

		if (isCommandToBeExecutedInParallelConnection()) {
			sqlToExecuteInParallel.setLength(0);
			sqlToExecuteInParallel.append(sql_statement.toString());
			
			mydebug("Parallel statement found : "+sqlToExecuteInParallel.toString());
		}
		
		boolean to_be_masked=checkStatementForOracleT2();
		
		
		
		printProtocolParametersForOracle();
		
		if (!to_be_masked) {
			if(dm.is_debug || is_tracing) mydebug("ORCL !!! No masking done. Sending original bytes !!!...");
			
			sendSavedPackages(to_server_stream);
			
			return;
		}
		
		
		if (dm.is_debug || this.is_tracing) mydebug("Masked statement : "+sql_statement_masked.toString());
		//Paketi gonder
		
		//ssping tns
		if (oracle_protocol_characteristic==20120 || oracle_protocol_characteristic==-14834) {
			ArrayList<byte[]> packArr=new ArrayList<byte[]>();
			ArrayList<Integer> sizeArr=new ArrayList<Integer>();
			
			oracleTnsPackage.setStatement(sql_statement_masked.toString());
			
			oracleTnsPackage.rePack(dm.MAX_PACKAGE_SIZE, packArr, sizeArr);
			
			int package_count=packArr.size();
			
			if (package_count==0) {
				sendSavedPackages(to_server_stream);
				return;
			}
			
			for (int p=0;p<package_count;p++) {
				byte[] sendBuf=packArr.get(p);
				int sendBufSize=sizeArr.get(p);
				
				if (dm.is_debug || this.is_tracing)  {
					mydebug("Sending buffer ["+(p+1)+"/"+package_count+"]  ");
					printByteArray(sendBuf, 0, sendBufSize);
					}
				
				try {
					to_server_stream.write(sendBuf, 0, sendBufSize);
					to_server_stream.flush();
				} catch(Exception e) {
					mylog("Exception@rewriteSqlToBuffer : " + genLib.getStackTraceAsStringBuilder(e).toString());
				}
			}
				
		} 
		else 
			sendSavedPackages(to_server_stream);
		
			
		
		
	}
	
	
	//----------------------------------------------------------------
	
	static final String[] ALTER_SESSION_STRARR=new String[]{"ALTER","SESSION","SET","CURRENT_SCHEMA"};
	static final String DBMS_APPLICATION_INFO="DBMS_APPLICATION_INFO";
	static final String USE_="USE";
	static final String[] SET_SEARCH_PATH_TO=new String[]{"SET","SEARCH_PATH","TO"};

	boolean isCommandToBeExecutedInParallelConnection() {
		
		if(dm.is_debug || is_tracing)  mydebug("isCommandToBeExecutedInParallelConnection start : ");
		
		
		//ALTER SESSION SET CURRENT_SCHEMA=xxxxxx;
		if ( dm.proxy_type.equals(dm.PROXY_TYPE_ORACLE_T2)) {
			int pos_of_alter_session=ddmLib.searchForStandaloneStringArray(sql_statement.toString().toUpperCase(), ALTER_SESSION_STRARR,0);
			if (pos_of_alter_session>-1) return true;
			int pos_of_dbms_app_info=sql_statement.toString().toUpperCase().indexOf(DBMS_APPLICATION_INFO);
			
			if (pos_of_dbms_app_info>-1) return true;
				
			return false;
		}
		else if (dm.proxy_type.equals(dm.PROXY_TYPE_MYSQL) && ddmLib.searchForStandaloneString(sql_statement.toString().toUpperCase(), USE_,0)>-1) {
			return true;
		}
		else if (dm.proxy_type.equals(dm.PROXY_TYPE_MSSQL_T2)  && ddmLib.searchForStandaloneString(sql_statement.toString().toUpperCase(), USE_,0)>-1) {
			return true;
		}
		else if (dm.proxy_type.equals(dm.PROXY_TYPE_POSTGRESQL)) {
			int pos_of_alter_session=ddmLib.searchForStandaloneStringArray(sql_statement.toString().toUpperCase(), SET_SEARCH_PATH_TO,0);
			if (pos_of_alter_session>-1) return true;
			
			
			return false;
		}
				
		return false;
	}
	
	

	
	
	
	
	//-----------------------------------------------------------------------
	public String CURRENT_SCHEMA="";
	public String CURRENT_CATALOG="";
	public String CURRENT_SERVER="";
	//-----------------------------------------------------------------------

	void setCurrentSchemaForOracle() {
		
		
		
		String sql="select SCHEMANAME from v$session where sid=? and serial#=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",session_sid});
		bindlist.add(new String[]{"INTEGER",session_serial_num});
		
		ArrayList<String[]> arr=ddmLib.getDbArray(connParallel, sql, 1, bindlist, 0);
		
		
		if (arr!=null && arr.size()==1) {
			CURRENT_SCHEMA=arr.get(0)[0];
			mydebug("Current Schema is set to : "+ CURRENT_SCHEMA);
			
		}
		
		
	}

	//-----------------------------------------------------------------------

	void setCurrentSchemaForPOSTGRESQL() {
		
		
		String normalized=sqlToExecuteInParallel.toString().replaceAll("\n|\r|\t", " ").toUpperCase();
		
		int pos=normalized.indexOf(" ON ");
		
		if (pos==-1) return;
		
		
		
			try {
				CURRENT_SCHEMA=normalized.substring(pos+4).trim();
				
				mydebug("Current Schema is set to : "+ CURRENT_SCHEMA);
			} catch(Exception e) {
				mylog("Exception@setCurrentSchemaForPOSTGRESQL :"+genLib.getStackTraceAsStringBuilder(e).toString());
			}
			
			
		
		
		
	}

		//-----------------------------------------------------------------------
	void setCurrentSchemaForMySql() {
		String sql="";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		ArrayList<String[]> arr=null;
		
		
		sql="SELECT DATABASE() FROM DUAL";

		arr=ddmLib.getDbArray(connParallel, sql, 1, bindlist, 0);
		
		if (arr!=null && arr.size()==1)  {
			CURRENT_SCHEMA=arr.get(0)[0];
			mydebug("Current Schema is set to : "+ CURRENT_SCHEMA);
			
		}
		
		
		
	}
	
	//-----------------------------------------------------------------------

	void setCurrentSchemaForHIVE() {
		
		
		String arr[]=sqlToExecuteInParallel.toString().replaceAll("\n|\r|\t", " ").split(" ");
		
		boolean use_found=false;
		
		for (int i=0;i<arr.length;i++) {
			String el=arr[i];
			if (el.toLowerCase().equals("use")) {
				use_found=true;
				continue;
			}
			
			if (use_found && el.length()>0) {
				CURRENT_SCHEMA=el;
				mydebug("Current Schema is set to : "+ CURRENT_SCHEMA);
				break;
			}
		}
		
		
		
		
		
	}
	
	//-----------------------------------------------------------------------
	
	ArrayList<String[]> changedSessionVariables=new ArrayList<String[]>();

	void setVariablesFromORACLEDb() {
		
		String sql="";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		ArrayList<String[]> arr=null;
		sql="select version from v$instance";

		arr=ddmLib.getDbArray(connParallel, sql, 1, bindlist, 0);
		
		if (arr!=null && arr.size()==1)  {
			DB_VERSION=arr.get(0)[0];
			ddmLib.setSessionKey(this,"DB_VERSION",DB_VERSION);
			//sessionInfoForConnArr.add(new String[]{"DB_VERSION",DB_VERSION});
		}
			
		
		
		sql="select username, osuser, machine, terminal, program, module, audsid from v$session where sid=? and serial#=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER", session_sid});
		bindlist.add(new String[]{"INTEGER", session_serial_num});
		
		arr=ddmLib.getDbArray(connParallel, sql, 1, bindlist, 0);
		
		
		
		if (arr!=null && arr.size()==1)  {
			session_username=arr.get(0)[0].trim();
			session_osuser=arr.get(0)[1].trim();
			session_machine=arr.get(0)[2].trim();
			session_terminal=arr.get(0)[3].trim();
			session_program=arr.get(0)[4].trim();
			session_module=arr.get(0)[5].trim();
			session_oracle_session_id=arr.get(0)[6].trim();
			
			if (session_username.length()>0) 			ddmLib.setSessionKey(this,"CURRENT_USER",session_username);   
			if (session_osuser.length()>0) 				ddmLib.setSessionKey(this,"OSUSER",session_osuser); 
			if (session_machine.length()>0) 			ddmLib.setSessionKey(this,"MACHINE",session_machine); 
			if (session_terminal.length()>0) 			ddmLib.setSessionKey(this,"TERMINAL",session_terminal); 
			if (session_program.length()>0) 			ddmLib.setSessionKey(this,"PROGRAM",session_program); 
			if (session_module.length()>0) 				ddmLib.setSessionKey(this,"MODULE",session_module); 
			if (session_oracle_session_id.length()>0) 	ddmLib.setSessionKey(this,"SESSIONID",session_oracle_session_id);
			
			
			//set changed session variables with changeLoginParametersORACLE if any 
			for (int h=0;h<changedSessionVariables.size();h++) {
				String changed_session_variable_name=changedSessionVariables.get(h)[0];
				String changed_session_variable_value=changedSessionVariables.get(h)[1];
				ddmLib.setSessionKey(this,changed_session_variable_name,changed_session_variable_value);
				
				this.mydebug("Replacing changed session variable ["+changed_session_variable_name+"] to "+changed_session_variable_value+" "+ddmLib.getSessionKey(this, changed_session_variable_name));
				
				if (changed_session_variable_name.contains("CURRENT_USER")) session_username=changed_session_variable_value;
				if (changed_session_variable_name.contains("OSUSER")) session_osuser=changed_session_variable_value;
				if (changed_session_variable_name.contains("MACHINE")) session_machine=changed_session_variable_value; 
				if (changed_session_variable_name.contains("TERMINAL")) session_terminal=changed_session_variable_value;
				if (changed_session_variable_name.contains("PROGRAM")) session_program=changed_session_variable_value;
				if (changed_session_variable_name.contains("MODULE")) session_module=changed_session_variable_value;
				
				
				
				
			}
			
			setCurrentSchemaForOracle();
			
			ddmLib.execSingleUpdateSQL(connParallel, "alter session set current_schema="+CURRENT_SCHEMA, null);
			
		}
		
		mydebug("Session session_username 				[Sid : "+session_sid+"]: "+session_username);
		mydebug("Session session_osuser 				[Sid : "+session_sid+"]: "+session_osuser);
		mydebug("Session session_machine	 			[Sid : "+session_sid+"]: "+session_machine);
		mydebug("Session session_terminal	 			[Sid : "+session_sid+"]: "+session_terminal);
		mydebug("Session session_program	 			[Sid : "+session_sid+"]: "+session_program);
		mydebug("Session session_module	 				[Sid : "+session_sid+"]: "+session_module);
		mydebug("Session session_oracle_session_id	 	[Sid : "+session_sid+"]: "+session_oracle_session_id);
		
		
		
		sql="select granted_role from DBA_ROLE_PRIVS where grantee=? and granted_role not in ('RESOURCE','CONNECT') order by 1";
		mydebug(sql);
		bindlist.clear();
		bindlist.add(new String[]{"STRING", session_username.toUpperCase()});
		arr=ddmLib.getDbArray(connParallel, sql, Integer.MAX_VALUE, bindlist, 0);
		
		session_granted_roles="";
		if (arr!=null && arr.size()>0)  {
		
			for (int i=0;i<arr.size();i++) {
				String a_role=arr.get(i)[0];
				if (i>0) session_granted_roles=session_granted_roles+",";
				session_granted_roles=session_granted_roles+a_role;
			}
			
			if (session_granted_roles.length()==0) session_granted_roles="-";
			
			
		}
		
		ddmLib.setSessionKey(this,"GRANTED_ROLES",session_granted_roles);
		//sessionInfoForConnArr.add(new String[]{"GRANTED_ROLES",session_granted_roles});
		
		
		//try {Thread.sleep(10000);} catch(Exception e) {}
		
		session_client_version="";
		session_client_driver="";
		session_client_oci_library="";
		
		sql="SELECT DISTINCT client_version as cv, client_driver as cd, client_oci_library as colib, AUTHENTICATION_TYPE   "+
				" FROM v$session_connect_info WHERE sid =? and serial#=?";
		
		mydebug(sql);
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER", session_sid});
		bindlist.add(new String[]{"INTEGER", session_serial_num});
		
		arr=ddmLib.getDbArray(connParallel, sql, 1, bindlist, 0);
		
		if (arr!=null && arr.size()==1)  {
			session_client_version=arr.get(0)[0].trim();
			session_client_driver=arr.get(0)[1].trim();
			session_client_oci_library=arr.get(0)[2].trim();
			session_authentication_type=arr.get(0)[3].trim();
			
			
			if (session_client_version.length()==0) session_client_version="Unknown";
			if (session_client_driver.length()==0) session_client_driver="NONE";
			if (session_client_oci_library.length()==0) session_client_oci_library="NONE";
			if (session_authentication_type.length()==0) session_authentication_type="DATABASE";
			if (session_proxy_client_name.length()==0 || session_proxy_client_name.equalsIgnoreCase(session_username)) session_proxy_client_name="NONE";

			
			
			ddmLib.setSessionKey(this,"CLIENT_VERSION",session_client_version);
			ddmLib.setSessionKey(this,"CLIENT_DRIVER",session_client_driver);
			ddmLib.setSessionKey(this,"CLIENT_OCI_LIBRARY",session_client_oci_library);
			ddmLib.setSessionKey(this,"AUTHENTICATION_TYPE",session_authentication_type);
			ddmLib.setSessionKey(this,"PROXY_CLIENT_NAME",session_proxy_client_name);
			
			

			
			
			mydebug("Session Client Version For Oracle 		[Sid : "+session_sid+"]: "+session_client_version);
			mydebug("Session Client Driver For Oracle 		[Sid : "+session_sid+"]: "+session_client_driver);
			mydebug("Session Client Oci Library For Oracle 	[Sid : "+session_sid+"]: "+session_client_oci_library);
			mydebug("Authentication Type For Oracle 		[Sid : "+session_sid+"]: "+session_authentication_type);
			mydebug("Proxy Client Name For Oracle 			[Sid : "+session_sid+"]: "+session_proxy_client_name);

			
		}
		
		bindlist.clear();
		
		sql="begin DBMS_APPLICATION_INFO.SET_MODULE('Maya TDM','Parallel Connection'); commit; end;";
		ddmLib.execSingleUpdateSQL(connParallel, sql, bindlist);

	}
	
	
	//-----------------------------------------------------------------------
	void setVariablesFromMicrosoftSQLDb() {
		String sql="";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		ArrayList<String[]> arr=null;
		
		sql="select loginame, hostname, program_name, hostprocess, nt_username,schema_name(), db_name(), @@SERVERNAME from sys.sysprocesses where spid=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER", session_sid});
		
		arr=ddmLib.getDbArray(connParallel, sql, 1, bindlist, 0);
		
		if (arr!=null && arr.size()==1)  {
			
			session_username=arr.get(0)[0].trim();
			session_machine=arr.get(0)[1].trim();
			session_program=arr.get(0)[2].trim();
			session_terminal=arr.get(0)[3].trim();
			session_osuser=arr.get(0)[4].trim();
			CURRENT_SCHEMA=arr.get(0)[5].trim();
			CURRENT_CATALOG=arr.get(0)[6].trim();
			CURRENT_SERVER=arr.get(0)[7].trim();
			
			if (session_username.length()>0)
				sessionInfoForConnArr.add(new String[]{"CURRENT_USER",session_username});
			if (session_osuser.length()>0)
				sessionInfoForConnArr.add(new String[]{"OSUSER",session_osuser});
			if (session_machine.length()>0)
				sessionInfoForConnArr.add(new String[]{"MACHINE",session_machine});
			if (session_terminal.length()>0)
				sessionInfoForConnArr.add(new String[]{"TERMINAL",session_terminal});
			if (session_program.length()>0)
				sessionInfoForConnArr.add(new String[]{"PROGRAM",session_program});
			if (CURRENT_CATALOG.length()>0)
				sessionInfoForConnArr.add(new String[]{"CURRENT_CATALOG",CURRENT_CATALOG});
			if (CURRENT_SCHEMA.length()>0)
				sessionInfoForConnArr.add(new String[]{"CURRENT_SCHEMA",CURRENT_SCHEMA});
			if (CURRENT_SERVER.length()>0)
				sessionInfoForConnArr.add(new String[]{"CURRENT_SERVER",CURRENT_SERVER});
			
		}
	}
	
	//-----------------------------------------------------------------------
	void setVariablesFromPOSTGRESQLDb() {
		String sql="";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		ArrayList<String[]> arr=null;
		
		sql="select usename, client_hostname, application_name, current_schema(), current_database(),version() from pg_stat_activity where pid=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER", session_sid});
		
		arr=ddmLib.getDbArray(connParallel, sql, 1, bindlist, 0);
		
		if (arr!=null && arr.size()==1)  {
			
			session_username=arr.get(0)[0].trim();
			session_machine=arr.get(0)[1].trim();
			session_program=arr.get(0)[2].trim();
			CURRENT_SCHEMA=arr.get(0)[3].trim();
			CURRENT_CATALOG=arr.get(0)[4].trim();
			DB_VERSION=arr.get(0)[5].trim();
			
			if (session_username.length()>0)
				sessionInfoForConnArr.add(new String[]{"CURRENT_USER",session_username});
			if (session_machine.length()>0)
				sessionInfoForConnArr.add(new String[]{"MACHINE",session_machine});
			if (session_terminal.length()>0)
				sessionInfoForConnArr.add(new String[]{"TERMINAL",session_terminal});
			if (session_program.length()>0)
				sessionInfoForConnArr.add(new String[]{"PROGRAM",session_program});
			if (CURRENT_SCHEMA.length()>0)
				sessionInfoForConnArr.add(new String[]{"CURRENT_SCHEMA",CURRENT_SCHEMA});
			if (CURRENT_CATALOG.length()>0)
				sessionInfoForConnArr.add(new String[]{"CURRENT_CATALOG",CURRENT_CATALOG});
			if (DB_VERSION.length()>0)
				sessionInfoForConnArr.add(new String[]{"DB_VERSION",DB_VERSION});
			
		}
	}
		
	//-------------------------------------------------------------------------------
	void setGenericSessionVariables() {
		
		mydebug("setGenericSessionVariables");
		sessionInfoForConnArr.add(new String[]{"CLIENT_HOST_ADDRESS",CLIENT_HOST_ADDRESS});
		sessionInfoForConnArr.add(new String[]{"CLIENT_PORT",""+CLIENT_PORT});

		
		is_authorized=true;
		
		proxy_session_id=dm.createNewProxySession(sessionInfoForConnArr,"generic");
		
		setPolicyGroup();
		
		
			
	}
	
	//-----------------------------------------------------------------------
	void setOracleSessionVariables(byte[] buf, int len) {
		
		if (is_authorized)  return;

		byte package_type=buf[4]; 
		
		
		
		//Accept
		if (package_type== (byte) 0x2) {
			mydebug("Checking accept package...");
			//server tarafindan kabul edilen paket versiyonu kabul edilir.
			oracle_package_version_number=ddmLib.byte2UnsignedInt(buf[9]);
			mydebug("Oracle Package Version : " + oracle_package_version_number);
			


			
			int tmp_max_pack_size=0;
			try{tmp_max_pack_size=buf[12]*256+buf[13];} catch(Exception e) { e.printStackTrace(); }
			if (tmp_max_pack_size>0) {
				max_package_size=tmp_max_pack_size;
				mydebug("max_package_size set to : " + tmp_max_pack_size);

			}
		}

		//if (package_type!= (byte) 0x6 || dummy_byte!= (byte) 8 ) return;
		if (package_type!= (byte) 0x6) return;


		
		sessionInfoForConnArr.clear();
		
		sessionInfoForConnArr.add(new String[]{"CLIENT_HOST_ADDRESS",CLIENT_HOST_ADDRESS});
		sessionInfoForConnArr.add(new String[]{"CLIENT_PORT",""+CLIENT_PORT});
				
		sessionInfoForConnArr.add(new String[]{"ORA_PROTOCOL_CHAR",""+oracle_protocol_characteristic});
		sessionInfoForConnArr.add(new String[]{"ORA_PACK_VERSION",""+oracle_package_version_number});
		
		byte[] key_start=new byte[]{ 		(byte) 0x08};		
		
		
		
		int get_session_type=1;
		
		int key_header_pos=ddmLib.IndexOfByteArray(buf, 10, len-1, key_start);
		mydebug("session var attempt 1 pos : "+key_header_pos);
		if (key_header_pos>-1) {
			byte[] X_AUTH_SESSION_ID="AUTH_SESSION_ID".getBytes();
			int pos_key=ddmLib.IndexOfByteArray(buf, key_header_pos, len-1, X_AUTH_SESSION_ID);
			if (pos_key==-1) {
				mydebug("Not a session parameter package.");
				return;
			}

			if (buf[key_header_pos+1]!= (byte) 0x01 ) get_session_type=2;
			
		}
		
		
		mydebug("*** Client Get Session Type : "+get_session_type);

		int cursor=key_header_pos+3;
		
		
		String key=null;
		String val=null;
		
		int byte_len=0;
		
		boolean sid_found=false;
		boolean serial_num_found=false;
		
		//encode sid and serial#
		if (session_sid.length()==0) 
			while(true) {
				
				if (sid_found && serial_num_found) {
					this.is_authorized=true;
					break;
				}
				
				if (cursor>=len) break;
				
				
				if (key==null) {
					if (get_session_type==1) cursor+=2; else  cursor+=4;
					
					byte_len=ddmLib.byte2UnsignedInt(buf[cursor]);
					
					cursor+=1; 
					
					key=new String(buf, cursor, byte_len);
					cursor+=byte_len;
				}
				
				if (val==null) {
					
					//if null
					if (buf[cursor]==(byte) 0x00) {
						val="";
						if (get_session_type==1) cursor+=2; else  cursor+=8;
					}
					else {
						if (get_session_type==1) cursor+=2; else  cursor+=4;
						
						byte_len=ddmLib.byte2UnsignedInt(buf[cursor]);
						cursor+=1;
						
						val=new String(buf, cursor, byte_len);
						cursor+=byte_len;
						
						//skip zero
						if (get_session_type==1) cursor+=1; else  cursor+=4;
						
					}
					
					
					
				}
				
				if (key!=null && val!=null) {
					//mylog("||||||||||||||   Adding Key "+key+"="+val);
					if (key.equals("AUTH_SESSION_ID")) {
						session_sid=val;
						mydebug("******  Session Id : " + session_sid);
						sid_found=true;
					}
					if (key.equals("AUTH_SERIAL_NUM")) {
						session_serial_num=val;
						mydebug("******  Session Serial Num : " + session_serial_num);
						serial_num_found=true;
					}
					key=null;
					val=null;
				}
				
			}
		
		
		
		
		
		if (is_authorized) {
			decodeOracleSessionVariables();
			if (ORADISC_is_chunk_discovered) 	
				oracleTnsLib.loadSaveOracleTnsChunkConf(this,oracleTnsLib.ACT_SAVE);
			else
				oracleTnsLib.loadSaveOracleTnsChunkConf(this,oracleTnsLib.ACT_LOAD);
		}


	}
	
	
	//-----------------------------------------------------------------------
	void decodeOracleSessionVariables() {
		
			
			sessionInfoForConnArr.add(new String[]{"SESSION_SID",session_sid});
			sessionInfoForConnArr.add(new String[]{"SESSION_SERIAL_NUM",session_serial_num});
			sessionInfoForConnArr.add(new String[]{"PROXY_CLIENT_NAME",session_proxy_client_name});

			
			try {
	    		String driver=dm.target_db_driver_name;
	    		String url=dm.target_db_url;
	    		String user=dm.target_db_username;
	    		String pass=dm.target_db_password;
	    		
	    		connParallel=ddmLib.getTargetDbConnection(driver, url, user, pass);
	    		
	    		if (connParallel!=null)  
	    			setVariablesFromORACLEDb();
	    		
	    		else {
	    			client_cancelled=true;
	    			mylog("Parallel connection is invalid. Client exit");
	    			return;
	    		}
	    		
	    			
	    	
	    	} catch(Exception e) {
	    		e.printStackTrace();
	    	}
			
			String username=ddmLib.getSessionKey(this,"CURRENT_USER");
			
			mydebug("--------------------------------------------------");
			mydebug(" Setting Initial Schema For Oracle Session : " + username);
			mydebug("--------------------------------------------------");
			String change_schema_sql="ALTER SESSION SET CURRENT_SCHEMA="+username;
			ddmLib.execSingleUpdateSQL(connParallel, change_schema_sql, null);
			
			setCurrentSchemaForOracle();
			
			proxy_session_id=dm.createNewProxySession(sessionInfoForConnArr,username);
			
			
			//replace changed parameters with original ones
			mydebug("Replacing changed session parameters with original values...");
			for (int c=0;c<sessionInfoForConnArrChanged.size();c++) {
				String changed_parameter_name=sessionInfoForConnArrChanged.get(c)[0].replace("AUTH_", "");
				String changed_parameter_val=sessionInfoForConnArrChanged.get(c)[1];
				mydebug("Changing "+changed_parameter_name+" to original => "+changed_parameter_val);
				ddmLib.setSessionKey(this,changed_parameter_name, changed_parameter_val);
			}
			
			
			
			setPolicyGroup();
			
			
			String sql="begin DBMS_APPLICATION_INFO.SET_CLIENT_INFO('InfoboxTDM(Sid,Serial#): "+session_sid+","+session_serial_num+", proxy_session_id: "+proxy_session_id+" '); commit; end; ";
			ddmLib.execSingleUpdateSQL(connParallel, sql, null);
			
			
			
			
		
	}
	
	
	
	
	
	//***********************************************************************
	static final String SQL_SERVER_TEST_STATEMENT="select 1";
	static final String POSTGRESQL_TEST_STATEMENT="select 1";
	static final String MYSQL_TEST_STATEMENT="select 1";
	
	boolean testConnection() {
		
		if (dm.proxy_type.equals(dm.PROXY_TYPE_ORACLE_T2) || dm.proxy_type.equals(dm.PROXY_TYPE_MSSQL_T2) ||  dm.proxy_type.equals(dm.PROXY_TYPE_GENERIC) || dm.proxy_type.equals(dm.PROXY_TYPE_MONGODB) ||  dm.proxy_type.equals(dm.PROXY_TYPE_HIVE))
			return true;
		
		boolean isconnok=false;
		if (dm.proxy_type.equals(dm.PROXY_TYPE_MSSQL_T2)) 
			try {
				ArrayList<String[]> testArr=ddmLib.getDbArray(connParallel, SQL_SERVER_TEST_STATEMENT, 1, null, 5);
				if (testArr!=null && testArr.size()==1) isconnok=true;
				} catch(Exception e) {
					mylog("Exception@testConnection :"+genLib.getStackTraceAsStringBuilder(e).toString());
					return false;
					}
		else if (dm.proxy_type.equals(dm.PROXY_TYPE_POSTGRESQL)) 
			try {
				ArrayList<String[]> testArr=ddmLib.getDbArray(connParallel, POSTGRESQL_TEST_STATEMENT, 1, null, 5);
				if (testArr!=null && testArr.size()==1) isconnok=true;
				} catch(Exception e) {
					mylog("Exception@testConnection :"+genLib.getStackTraceAsStringBuilder(e).toString());
					return false;
					}
		else if (dm.proxy_type.equals(dm.PROXY_TYPE_MYSQL)) 
			try {
				ArrayList<String[]> testArr=ddmLib.getDbArray(connParallel, MYSQL_TEST_STATEMENT, 1, null, 5);
				if (testArr!=null && testArr.size()==1) isconnok=true;
				} catch(Exception e) {
					mylog("Exception@testConnection :"+genLib.getStackTraceAsStringBuilder(e).toString());
					return false;
					}
		else 
			try {isconnok=connParallel.isValid(5);} catch(Exception e) {
				mylog("Exception@testConnection :"+genLib.getStackTraceAsStringBuilder(e).toString());
				return false;
				}
		
		if (isconnok) return true;
		return false;
		
		
	}
	
	//***********************************************************************
	
	public ArrayList<Integer> policyGroups=new ArrayList<Integer>();
	
	void setPolicyGroup() {
		
		
		ArrayList<String[]> policyGrpArrLocal=(ArrayList<String[]>) dm.hmConfig.get("POLICY_GROUPS");
		ArrayList<String[]> overridingParamArrLocal=(ArrayList<String[]>) dm.hmConfig.get("OVERRIDING_PARAMS");
		
		record_limit=0;
		
		if (policyGrpArrLocal==null) return;
		
		is_tracing=false;
		client_log_statement=dm.DDM_LOG_STATEMENT;
		client_iddle_timeout=dm.DYNAMIC_CLIENT_IDDLE_TIMEOUT;
		client_calendar_id=dm.DDM_CALENDAR_ID;
		client_session_validation_id=dm.DDM_SESSION_VALIDATION_ID;
		
		policyGroups.clear();
		
		String policy_group_session_val="";
		
		for (int i=0;i<policyGrpArrLocal.size();i++) {
			int policy_group_id=Integer.parseInt(policyGrpArrLocal.get(i)[0]);
			String policy_group_name=policyGrpArrLocal.get(i)[1];
			String check_field=policyGrpArrLocal.get(i)[2];
			String check_rule=policyGrpArrLocal.get(i)[3];
			String check_parameter=policyGrpArrLocal.get(i)[4].replaceAll(",", "\n");
			String case_sensitive=policyGrpArrLocal.get(i)[5];
			String plc_record_limit=policyGrpArrLocal.get(i)[6];
			String start_debuging=policyGrpArrLocal.get(i)[7];
			
			mydebug("Checking  " + policy_group_name);
			
			boolean is_matched=false;
				
			if (check_rule.equals("JAVASCRIPT")) {
				String js_code=policyGrpArrLocal.get(i)[4];
				String js_result=ddmLib.getResultWithJavaScript(this, js_code);
				is_matched=js_result.equalsIgnoreCase("true");
				 
			}  else {
				String session_key_val=ddmLib.getSessionKey(this,check_field);
				if (case_sensitive.equals("NO"))  session_key_val=session_key_val.toLowerCase();
				mydebug("\t if "+check_field+" ["+session_key_val.trim()+"] " + check_rule + " " + check_parameter);
				is_matched=ddmLib.testRule(session_key_val, check_rule, check_parameter, case_sensitive);
			}
			
			
			mydebug("\t returns "+is_matched);
			
			if (is_matched) {
				mydebug(".... Matched policy  group : " + policy_group_id + " = "+policy_group_name);
				policyGroups.add(policy_group_id);
				if (policy_group_session_val.length()>0) policy_group_session_val=policy_group_session_val+", ";
				policy_group_session_val=policy_group_session_val+policy_group_name;
				
				
				int plc_record_limit_INT=0;
				try {plc_record_limit_INT=Integer.parseInt(plc_record_limit);} catch(Exception e) {}
				if (plc_record_limit_INT>record_limit) {
					mydebug("Record limit is settting to " + plc_record_limit_INT);
					record_limit=plc_record_limit_INT;
				}
				
				if (start_debuging.equals("YES")) {
					is_tracing=true;
					mydebug("Setting initial tracing for session " + proxy_session_id +" "+session_username+" since it is mathced to '"+policy_group_name+"' policy group.");
				}
				
				int overriding_id=getPolicyGroupOverridingIndex(overridingParamArrLocal,""+policy_group_id);
				
				//sql="select policy_group_id, sql_logging, iddle_timeout, deny_connection, calendar_id, session_validation_id from tdm_proxy_param_override where app_id=? and valid='YES' order by id ";
				if (overriding_id>-1) {
					
					
					String sql_logging=overridingParamArrLocal.get(overriding_id)[1];
					String iddle_timeout=overridingParamArrLocal.get(overriding_id)[2];
					String deny_connection=overridingParamArrLocal.get(overriding_id)[3];
					String calendar_id=overridingParamArrLocal.get(overriding_id)[4];
					String session_validation_id=overridingParamArrLocal.get(overriding_id)[5];
					
					mydebug("Overriding client parameters for policy group : "+policy_group_name);
					mydebug("sql_logging                 : "+sql_logging);
					mydebug("iddle_timeout               : "+iddle_timeout);
					mydebug("deny_connection             : "+deny_connection);
					mydebug("calendar_id                 : "+calendar_id);
					mydebug("session_validation_id       : "+calendar_id);

					
					if (!sql_logging.equals("SYSTEM")) {
										
						client_log_statement=sql_logging.equals("YES");
						
						
						mydebug("Setting sql_logging to ["+client_log_statement+"] by policy group: "+policy_group_name);
						
					}
					
					int iddle_timeout_int=0;
					try {iddle_timeout_int=Integer.parseInt(iddle_timeout);} catch(Exception e) {}
					mydebug("client_iddle_timeout is setting to "+iddle_timeout_int);
					client_iddle_timeout=iddle_timeout_int;
					
					if (deny_connection.equals("YES")) {
						mydebug("Connection is denied by policy group "+policy_group_name);
						client_cancelled=true;
					}
					
					int calendar_id_INT=0;
					try{calendar_id_INT=Integer.parseInt(calendar_id);} catch(Exception e) {}	 
					if (calendar_id_INT>0) client_calendar_id=calendar_id_INT;
					
					int session_validation_id_INT=0;
					try{session_validation_id_INT=Integer.parseInt(session_validation_id);} catch(Exception e) {}	 
					if (session_validation_id_INT>0) client_session_validation_id=session_validation_id_INT;
					
				}
				
				
			}
			
		}
		
		
		if (client_calendar_id>0) {
			if (dm.hmConfig.containsKey("CALENDAR_EXCEPTIONS_FOR_"+client_calendar_id)) {
				calendarExceptionArr.clear();
				calendarExceptionArr.addAll((ArrayList<Date[]>) dm.hmConfig.get("CALENDAR_EXCEPTIONS_FOR_"+client_calendar_id));
			}
		}
		
		ddmLib.setSessionValidationVariables(this);
		
		ddmLib.setSessionKey(this,"POLICY_GROUPS", policy_group_session_val);
		
		client_last_configuration_ts=dm.last_configuration_load_time;
		
		
		setException();
		
	}
	
	
	
	//**********************************************************************
	int getPolicyGroupOverridingIndex(ArrayList<String[]> overridingParamArrLocal, String policy_group_id) {
		if (overridingParamArrLocal==null) return -1;
		
		for (int i=0;i<overridingParamArrLocal.size();i++) 
			if (overridingParamArrLocal.get(i)[0].equals(policy_group_id)) return i;
		
		return -1;
	}

	
	//**********************************************************************
	void setException() {
		
		user_exception_flag=false;
		
		for (int i=0;i<policyGroups.size();i++) {
			
			mydebug("setExemption checking... "+"APP_EXCEPTION_FOR_PLC_"+policyGroups.get(i)+"...");
			
			if (dm.hmConfig.containsKey("APP_EXCEPTION_FOR_PLC_"+policyGroups.get(i))) {
				mydebug("Setting user application exception for session : "+proxy_session_id);
				user_exception_flag=true;
				return;
			}
		}
		
		
	}
	
	
	
	 
	
	//*******************************************************************
	boolean analysePOSTGRESqlPackage(
			byte[] buf, 
			int len) {
		
		
		
		collectedBytes=new byte[len];
		collectedByteLen=0;
		
		
		boolean to_debug=dm.is_debug || is_tracing;
		
		sql_statement.setLength(0);
		
		System.arraycopy(buf, 0, collectedBytes, collectedByteLen,len);
		collectedByteLen+=len;
		
		if (to_debug)  {
			mydebug("*** collectedBytes : "+collectedByteLen);
			printByteArray(collectedBytes, collectedByteLen);
		}
		
		
		try {
			postgreWirePackage=new postgreWirePackage();
			postgreWirePackage.compile(this, collectedBytes, collectedByteLen, dm.proxy_encoding);
			
			if (postgreWirePackage.is_invalid || postgreWirePackage.sql_statement==null) return false;
			
			sql_statement.append(postgreWirePackage.sql_statement);
			
			return true;
		} catch(Exception e) {
			mylog("Exception@analysePOSTGRESqlPackage:" +genLib.getStackTraceAsStringBuilder(e).toString());
			return false;
		}
			
		
		
	}

	
	//*******************************************************************
	void resendPOSTGRESQLPackage(
			byte[] buf, 
			int len, 
			DataOutputStream to_server_stream
			) {
		
		
		boolean is_analysed=analysePOSTGRESqlPackage(buf,len);
		
		if (!is_analysed) {
			mydebug("POSTGRESql package analysis error.");
			sendSavedPackages(to_server_stream);
			return;
		}
		
		
		if (isCommandToBeExecutedInParallelConnection()) {
			sqlToExecuteInParallel.setLength(0);
			sqlToExecuteInParallel.append(sql_statement.toString());
			
			mydebug("Parallel statement found : "+sqlToExecuteInParallel.toString());
		}
		
		
		boolean to_be_masked=checkStatementForPOSTGRESQL();
		
		if (!to_be_masked) {
			if(dm.is_debug || is_tracing) mydebug("POSTGRESQL !!! No masking done. Sending original bytes !!!...");
			
			sendSavedPackages(to_server_stream);
			
			return;
		}
		
		if (dm.is_debug || this.is_tracing) mydebug("Masked statement : "+sql_statement_masked.toString());
		
		
		try {
			ArrayList<byte[]> packArr=new ArrayList<byte[]>();
			ArrayList<Integer> sizeArr=new ArrayList<Integer>();
			
			postgreWirePackage.setStatement(sql_statement_masked.toString());
			postgreWirePackage.rePack(Integer.MAX_VALUE, packArr, sizeArr);
			
			
			int package_count=packArr.size();
			
			if (package_count==0) {
				sendSavedPackages(to_server_stream);
				return;
			}
			
			for (int p=0;p<package_count;p++) {
				byte[] sendBuf=packArr.get(p);
				int sendBufSize=sizeArr.get(p);
				
				if (dm.is_debug || this.is_tracing)  {
					mydebug("Sending buffer ["+(p+1)+"/"+package_count+"] size:  "+sendBufSize);
					printByteArray(sendBuf, 0, sendBufSize);
					}
				
				try {
					to_server_stream.write(sendBuf, 0, sendBufSize);
					to_server_stream.flush();
				} catch(Exception e) {
					mylog("Exception@resendPOSTGRESQLPackage : " + genLib.getStackTraceAsStringBuilder(e).toString());
				}
			}
			
		} catch(Exception e) {
			mylog("Exception@resendPOSTGRESQLPackage:" +genLib.getStackTraceAsStringBuilder(e).toString());
			
			sendSavedPackages(to_server_stream);
			return;
		}
		
	}

	
	
	//********************************************************************
	public void feedPOSTGRESQLPack( 
			byte[] buf, 
			int len, 
			DataOutputStream to_server_stream
			) {

		byte[] packBuf=new byte[len];
		System.arraycopy(buf, 0, packBuf, 0, len);
		bufferArr.clear();
		bufferArr.add(packBuf);
		
		resendPOSTGRESQLPackage(buf,len,to_server_stream);
		
		if (sqlToExecuteInParallel.length()>0) {
			boolean is_ok=true;
			StringBuilder sberr=new StringBuilder();
			
			if (sqlToExecuteInParallel.toString().toUpperCase().contains("SET") && sqlToExecuteInParallel.toString().toUpperCase().contains("SEARCH_PATH") && sqlToExecuteInParallel.toString().toUpperCase().contains("TO") ) {
				mydebug("----------------------------------------------------");
				mydebug("--------    RUNNING PARALLEL STATEMENT       -------");
				mydebug("----------------------------------------------------");
				mydebug(sqlToExecuteInParallel.toString());

				is_ok=ddmLib.execSingleUpdateSQL(connParallel, sqlToExecuteInParallel.toString(), null, false, 0, sberr);
			}
			
			
			
			mydebug("Execution Returns : "+ is_ok); 
			if (!is_ok) mydebug("Execution err: "+sberr.toString());
			
			if (is_ok && sqlToExecuteInParallel.toString().toUpperCase().contains("SEARCH_PATH") ) {
				setCurrentSchemaForPOSTGRESQL();
				ddmLib.setSessionKey(this,"CURRENT_SCHEMA",CURRENT_SCHEMA);
				
				setVariablesFromPOSTGRESQLDb();
				//to force configuration load of client
				client_last_configuration_ts=dm.last_configuration_load_time-1000;
			}


			sqlToExecuteInParallel.setLength(0);
			mydebug("----------------------------------------------------");
		} // if (sqlToExecuteInParallel.length()>0)
		
		
		restartPackage();
		
		
			
	}
	
	//********************************************************************
	public void feedMicrosoftSQLPack( 
			byte[] buf, 
			int len, 
			DataOutputStream to_server_stream
			) {
		
		byte package_type=buf[0];
		if (package_type!=(byte) 0x1 && package_type!=(byte) 0x3) {
			if (dm.is_debug || is_tracing)
				mydebug("STATE_NO_SQL_PACKAGE : Not a SQL Batch or RPC Client Request package. ");
			
			sendBuffer(to_server_stream, buf, 0, len);
			restartPackage();
			bufferArr.clear();
			return;
		}
		
		int cursor=0;
		
		
		while(true) {
			
			
			int package_size=ddmLib.contertByteArray2Integer(buf, cursor+2, 2, ByteOrder.BIG_ENDIAN);
			
			package_type=buf[cursor+0];
			
			if (dm.is_debug || is_tracing) {
				mydebug("package_type    : "+package_type);
				mydebug("package_size    : "+package_size);
			}
			
			
			
			//sql batch or RPC Client request
			if (package_type==(byte) 0x1 || package_type==(byte) 0x3) {
				
				if (package_type==(byte) 0x3 && buf[cursor+8]==255 && buf[cursor+9]==255 && buf[cursor+10]!=11) {
					if (dm.is_debug || is_tracing)
						mydebug("STATE_NO_SQL_PACKAGE : Not a SQL Batch or RPC Client Request package. ");
					
					sendBuffer(to_server_stream, buf, 0, len);
					restartPackage();
					bufferArr.clear();
					return;
				} else {
					
					
					byte[] splitedBuf=new byte[package_size];
					System.arraycopy(buf, cursor+0, splitedBuf, 0, package_size);
					bufferArr.add(splitedBuf);
					
					try {
						feedMicrosoftSQLSinglePack(splitedBuf, package_size);
					} catch(Exception e) {
						mylog("Exception@feedMicrosoftSQLSinglePack :");
						mylog(genLib.getStackTraceAsStringBuilder(e).toString());
						sendBuffer(to_server_stream, buf, 0, len);
						package_state=STATE_START;
						clearPackage();
						break;
						
					}
				}
				
				
			} else {
				package_state=STATE_NO_DATA_PACKAGE;
			}


			if (dm.is_debug || is_tracing)
				mydebug("package_state ....................... : "+package_state);
			
			
			if (package_state==STATE_START) {
				if (dm.is_debug || is_tracing)
					mydebug("STATE_START");

				last_statement_start_ts=System.currentTimeMillis();
				sendBuffer(to_server_stream, buf, cursor+0, len);
			}
			else if (package_state==STATE_STATEMENT_BUILDING) {
				if (dm.is_debug || is_tracing)
					mydebug("STATE_STATEMENT_BUILDING : Waiting for more sql statement from client... ");
				
				last_statement_start_ts=System.currentTimeMillis();
			}
			else if (package_state==STATE_STATEMENT_COMPLETED) {
				if (dm.is_debug || is_tracing)
					mydebug("STATE_STATEMENT_COMPLETED");
				
				try {
					resendMicrosoftSQLPackage(to_server_stream);
				} catch(Exception e) {
					e.printStackTrace();
					mylog("Exception@feedMicrosoftSQLSinglePack :");
					mylog(genLib.getStackTraceAsStringBuilder(e).toString());
					sendBuffer(to_server_stream, buf, 0, len);
					package_state=STATE_START;
					clearPackage();
					break;
					
				}
				
				if (sqlToExecuteInParallel.length()>0) {
					mydebug("----------------------------------------------------");
					mydebug("--------   RUNNING MSSQL PARALLEL STATEMENT --------");
					mydebug("----------------------------------------------------");
					mydebug(sqlToExecuteInParallel.toString());

					StringBuilder sberr=new StringBuilder();
					boolean is_ok=ddmLib.execSingleUpdateSQL(connParallel, sqlToExecuteInParallel.toString(), null, false, 0, sberr);
					
					if (!is_ok || sberr.indexOf("The executeUpdate method must not return a result set.")>-1) {
						mydebug("Ignoring [The executeUpdate method must not return a result set.] exception by JDTS.");
						is_ok=true;
					}
					
					mydebug("sqlToExecuteInParallel Execution Returns : "+ is_ok); 
					
					if (!is_ok) mydebug("Execution err: "+sberr.toString());
						
					
					if (is_ok && sqlToExecuteInParallel.toString().toUpperCase().contains("USE ") ) {
						//setCurrentCatalogForMsSql();
						setVariablesFromMicrosoftSQLDb();
						ddmLib.setSessionKey(this,"CURRENT_CATALOG",CURRENT_CATALOG);
					}
						

					sqlToExecuteInParallel.setLength(0);
					mydebug("----------------------------------------------------");
				} // if (sqlToExecuteInParallel.length()>0)

				
				restartPackage();
				
				bufferArr.clear();
				
			}
			else {
				if (dm.is_debug || is_tracing)
					mydebug("!!! UNKNOWN_PACKAGE_STATE    : "  +package_state);
				sendBuffer(to_server_stream, buf, 0, len);
				//sendSavedPackages(to_server_stream);
				//sendBuffer(to_server_stream, buf, cursor+0, len);
				restartPackage();
				bufferArr.clear();
				break;
			}
		
			
			cursor+=package_size;
			
			if (cursor>=len)  break;
			
		} //while(true) {
		
		
		
		
		
		
		
	}
	
	//****************************************************************************
	void feedMicrosoftSQLSinglePack(byte[] buf, int len) {
		
		if (dm.is_debug || is_tracing)
			mydebug(":) SQL Batch or RPC Client Request package ");
		
		if (dm.is_debug || is_tracing) {
			mydebug("\n------------feedMicrosoftSQLSinglePack-----------");
			printByteArray(buf, 0, len);
			mydebug("\n-------------------------------------");
		}
		
		
		
		int statement_start_pos=0;
		int statement_end_pos=len-1;
		
		if (package_state==STATE_STATEMENT_BUILDING) 		
			statement_package_no++;
		
		
		
		if (package_state==STATE_START) {

			statement_package_no++;
			
			package_state=STATE_STATEMENT_BUILDING;
			
			
		} //if (package_state==STATE_START)
		
		
		//appendStatementByteArray(buf);
		
		byte last_package_flag=buf[1];
		if (dm.is_debug || is_tracing) 
			mydebug("last_package_flag : "+ last_package_flag);
		
		
		if (last_package_flag==(byte) 0x01) {
			
			convertMicrosoftSQLByteArraysToSqlStatement();
			package_state=STATE_STATEMENT_COMPLETED;
		}
		
		
	}
	
	
	//***************************************************************
	
	byte[] msSqlPackageHeaders=null;
	byte[] msSqlPostBytes=null;
	byte MicrosoftSQLPackageTypeByte=(byte) 1;
	
	
	tdsMicrosoftSqlPackage tdsMicrosoftSqlPack=null;
	oracleTnsPackage oracleTnsPackage=null;
	postgreWirePackage postgreWirePackage=null;

	//[31][4]	[208][0][0]
	byte[] MSSQL_PRE_STMT_BYTE_ARR=new byte[]{(byte) 4, (byte) 208, (byte) 0, (byte) 0 };
	
	void convertMicrosoftSQLByteArraysToSqlStatement() {
		
		sql_statement.setLength(0);
		
		int buffer_len=0;
		for (int i=0;i<bufferArr.size();i++) buffer_len+=bufferArr.get(i).length;
		
		byte[] buf=new byte[buffer_len];
		int len=0;
		
		
		int start_pos=0;
		
		for (int i=0;i<bufferArr.size();i++) {
			if (i>0) start_pos=8;
			System.arraycopy(bufferArr.get(i), start_pos, buf, len, bufferArr.get(i).length-start_pos);
			len+=bufferArr.get(i).length-start_pos;
		}

		
		MicrosoftSQLPackageTypeByte=buf[0];
		
		if (dm.is_debug || is_tracing) {
			mydebug("convertMicrosoftSQLByteArraysToSqlStatement for : "+len);
			printByteArray(buf, len);
		}
		
		
		msSqlPackageHeaders=null;
		msSqlPostBytes=null;
		
		int package_type=buf[0];
		printByteArray(buf, len);
		
		int statement_start_pos=8;
		int statement_len=len-8;
		
		if (dm.is_debug || is_tracing)
			mydebug("*********** package_type : "+package_type);
		
		if ( package_type==(byte) 3) {
			
			
			tdsMicrosoftSqlPack=new tdsMicrosoftSqlPackage();
			tdsMicrosoftSqlPack.compile(this, buf, buf.length, 8, dm.proxy_encoding); 
			tdsMicrosoftSqlPack.print();
			
			if (!tdsMicrosoftSqlPack.isRewritablePackage) return;
			
			int stmtParameterIndex=tdsMicrosoftSqlPack.getStatementParameterId();
			
			if (stmtParameterIndex==-1) {
				mydebug("no statement found in RPC request");
				return;
			}
			
			tdsMicrosoftSqlRPCParam stmtParam=tdsMicrosoftSqlPack.rpcParameters.get(stmtParameterIndex);
			 
			sql_statement.append(stmtParam.parametervalue_as_string);
			
		} else {
			tdsMicrosoftSqlPack=new tdsMicrosoftSqlPackage();
			tdsMicrosoftSqlPack.compile(this, buf, buf.length, 8, dm.proxy_encoding); 
			tdsMicrosoftSqlPack.print();
			
			if (!tdsMicrosoftSqlPack.isRewritablePackage) return;	
			sql_statement.append(tdsMicrosoftSqlPack.stmt);
			
		}
		
		if (dm.is_debug || is_tracing)
			mydebug("convertMicrosoftSQLByteArraysToSqlStatement sql : "+sql_statement.toString());
		
		
		
	}
	
	
	
	
	
	
	//***********************************************************************
	void resendMicrosoftSQLPackage(DataOutputStream to_server_stream) {
		
		boolean to_be_masked=checkStatementForMicrosoftSQLT2();
			
		
		if (isCommandToBeExecutedInParallelConnection()) {
			sqlToExecuteInParallel.setLength(0);
			sqlToExecuteInParallel.append(sql_statement.toString());
			
			mydebug("Parallel statement found : "+sqlToExecuteInParallel.toString());
		}
		
		if (!to_be_masked) {
			mydebug("MsSQL!!! No masking done. Sending original bytes !!!...");
			
			sendSavedPackages(to_server_stream);
			
			return;
		}
		
		
		
		
		if (MicrosoftSQLPackageTypeByte==(byte) 3) {
			if (dm.is_debug || this.is_tracing) {
				mydebug("----------------------------------------------------");
				mydebug("--------    MSSQL COMMAND SENDING FOR RPC    -------");
				mydebug("----------------------------------------------------");
				mydebug(sql_statement_masked.toString());
			}
			
			
			int stmtParameterIndex=tdsMicrosoftSqlPack.getStatementParameterId();
			
			if (stmtParameterIndex!=-1) {
				tdsMicrosoftSqlRPCParam stmtParam=tdsMicrosoftSqlPack.rpcParameters.get(stmtParameterIndex);
				stmtParam.parametervalue_as_string=sql_statement_masked.toString();
			}
			
			ArrayList<byte[]> packArr=new ArrayList<byte[]>();
			ArrayList<Integer> sizeArr=new ArrayList<Integer>();
			
			tdsMicrosoftSqlPack.rePack(dm.MAX_PACKAGE_SIZE, packArr, sizeArr);
			int package_count=packArr.size();
			
			for (int p=0;p<package_count;p++) {
				byte[] sendBuf=packArr.get(p);
				int sendBufSize=sizeArr.get(p);
				
				if (dm.is_debug || this.is_tracing)  {
					mydebug("Sending buffer ["+(p+1)+"/"+package_count+"]  ");
					printByteArray(sendBuf, 0, sendBufSize);
					}
				
				try {
					to_server_stream.write(sendBuf, 0, sendBufSize);
					to_server_stream.flush();
				} catch(Exception e) {
					mylog("Exception@rewriteSqlToBuffer : " + genLib.getStackTraceAsStringBuilder(e).toString());
				}
			}
			
		} else {
			
			
			if (dm.is_debug || this.is_tracing) {
				mydebug("----------------------------------------------------");
				mydebug("--------    MSSQL COMMAND SENDING FOR RPC    -------");
				mydebug("----------------------------------------------------");
				mydebug(sql_statement_masked.toString());
			}
			
			tdsMicrosoftSqlPack.stmt=sql_statement_masked.toString();
			
			ArrayList<byte[]> packArr=new ArrayList<byte[]>();
			ArrayList<Integer> sizeArr=new ArrayList<Integer>();
			
			tdsMicrosoftSqlPack.rePack(dm.MAX_PACKAGE_SIZE, packArr, sizeArr);
			int package_count=packArr.size();
			
			for (int p=0;p<package_count;p++) {
				byte[] sendBuf=packArr.get(p);
				int sendBufSize=sizeArr.get(p);
				
				if (dm.is_debug || this.is_tracing)  {
					mydebug("Sending buffer ["+(p+1)+"/"+package_count+"]  ");
					printByteArray(sendBuf, 0, sendBufSize);
					}
				
				try {
					to_server_stream.write(sendBuf, 0, sendBufSize);
					to_server_stream.flush();
				} catch(Exception e) {
					mylog("Exception@rewriteSqlToBuffer : " + genLib.getStackTraceAsStringBuilder(e).toString());
				}
			}
			
			
		} //if (MicrosoftSQLPackageTypeByte==(byte) 3)
		
	}
	
	
	
	//************************************************************
	void setMicrosoftSQLSessionVariables(byte[] buf, int len) {
		
		byte package_type=buf[0]; 
		
		if (package_type!= (byte) 4) {
			mydebug("setMicrosoftSQLSessionVariables : package_type!= (byte) 4)");
			return;
		}
		
		if (len<40) {
			mydebug("setMicrosoftSQLSessionVariables : len<40 => "+len);
			return;
		}
		
		
		session_sid=""+ddmLib.contertByteArray2Integer(buf, 4, 2, ByteOrder.BIG_ENDIAN);
		
		if (session_sid.equals("0"))  {
			mydebug("setMicrosoftSQLSessionVariables : session_sid.equals(0)");
			return;
		}
		
		sessionInfoForConnArr.clear();
		
		
		sessionInfoForConnArr.add(new String[]{"CLIENT_HOST_ADDRESS",CLIENT_HOST_ADDRESS});
		sessionInfoForConnArr.add(new String[]{"CLIENT_PORT",""+CLIENT_PORT});
		
		
		///BURADA SESSION VERILERI COZULMELI
		
		
		
		mydebug("Microsoft SQL SPID : " + session_sid);
		
		is_authorized=true;
		
		
			
		sessionInfoForConnArr.add(new String[]{"SESSION_SID",session_sid});

		
		try {
    		String driver=dm.target_db_driver_name;
    		String url=dm.target_db_url;
    		String user=dm.target_db_username;
    		String pass=dm.target_db_password;
    		connParallel=ddmLib.getTargetDbConnection(driver, url, user, pass);
    		
    		
    		
    		if (connParallel!=null)  {
    			//ddmLib.execSingleUpdateSQL(connParallel, dm.MSSQL_SET_TRANSACTION_LEVEL_STMT, null);
    			//ddmLib.execSingleUpdateSQL(connParallel, dm.MSSQL_SET_IMPLICIT_TRANSACTIONS_STMT, null);
    			
    			setVariablesFromMicrosoftSQLDb();
    		}
    	
    	} catch(Exception e) {
    		e.printStackTrace();
    	}
		
		String username=ddmLib.getSessionKey(this,"CURRENT_USER");
		
		
		
		proxy_session_id=dm.createNewProxySession(sessionInfoForConnArr,username);
		
		
		
		
		setPolicyGroup();
		
	
		
	}
	
	
	//************************************************************
	void setPOSTGRESQLSessionVariables(byte[] buf, int len) {
		
		byte package_type=buf[0]; 
		
		if (package_type!= (byte) 'R') {
			mydebug("setPOSTGRESQLSessionVariables : package_type!= (byte) 'R')");
			return;
		}
		
		if (len<20) {
			mydebug("setPOSTGRESQLSessionVariables : len<20 => "+len);
			return;
		}
		
		
		int cursor=ddmLib.IndexOfByteArray(buf, 100, len, ddmLib.string2ByteArr("K[0][0][0][12]"));
		
		if (cursor==-1) {
			mydebug("setPOSTGRESQLSessionVariables : K[0][0][0][12] not found");
			return;
		}
		
		int sid_pos=cursor+5;
		
		session_sid=""+ddmLib.contertByteArray2Integer(buf, sid_pos, 4, ByteOrder.BIG_ENDIAN);
		
		if (session_sid.equals("0"))  {
			mydebug("setPOSTGRESQLSessionVariables : session_sid.equals(0)");
			return;
		}
		
		

		
		
		
		sessionInfoForConnArr.clear();
		
		
		sessionInfoForConnArr.add(new String[]{"CLIENT_HOST_ADDRESS",CLIENT_HOST_ADDRESS});
		sessionInfoForConnArr.add(new String[]{"CLIENT_PORT",""+CLIENT_PORT});
		
		
		///BURADA SESSION VERILERI COZULMELI
		
		
		
		mydebug("POSTGRESQL SPID : " + session_sid);
		
		is_authorized=true;
		
		
			
		sessionInfoForConnArr.add(new String[]{"SESSION_SID",session_sid});

		
		try {
    		String driver=dm.target_db_driver_name;
    		String url=dm.target_db_url;
    		String user=dm.target_db_username;
    		String pass=dm.target_db_password;
    		connParallel=ddmLib.getTargetDbConnection(driver, url, user, pass);
    		
    		
    		
    		if (connParallel!=null)  {
    			//ddmLib.execSingleUpdateSQL(connParallel, dm.MSSQL_SET_TRANSACTION_LEVEL_STMT, null);
    			//ddmLib.execSingleUpdateSQL(connParallel, dm.MSSQL_SET_IMPLICIT_TRANSACTIONS_STMT, null);
    			
    			setVariablesFromPOSTGRESQLDb();
    		}
    	
    	} catch(Exception e) {
    		e.printStackTrace();
    	}
		
		String username=ddmLib.getSessionKey(this,"CURRENT_USER");
		
		
		
		proxy_session_id=dm.createNewProxySession(sessionInfoForConnArr,username);
		
		
		
		
		setPolicyGroup();
		
	
		
	}
	
	//********************************************************************
	
	static final byte[] HIVE_EXECUTE_STATEMENT_BYTES="ExecuteStatement".getBytes();
	
	public void feedHIVEPack( 
			byte[] buf, 
			int len, 
			DataOutputStream to_server_stream
			) {
		
		
		int ExecuteStatement_pos=-1;
		ExecuteStatement_pos=ddmLib.IndexOfByteArray(buf, 0, 30, HIVE_EXECUTE_STATEMENT_BYTES);
		
		
		
		mydebug("ExecuteStatement_pos    : "+ExecuteStatement_pos);
		
		if (ExecuteStatement_pos>-1) {
			mydebug(":) HIVE ExecuteStatement package ");
			
			byte[] originalBuf=new byte[len];
			System.arraycopy(buf, 0, originalBuf, 0, len);
			bufferArr.add(originalBuf);
			
			try {
				feedHIVESinglePack(buf, 0, len);
			} catch(Exception e) {
				e.printStackTrace();
				package_state=STATE_START;
				clearPackage();
			}
			
		} else {
			package_state=STATE_NO_DATA_PACKAGE;
		}
		
		
		if (package_state==STATE_START) {
			mydebug("STATE_START");
			bufferArr.clear();
			sendBuffer(to_server_stream, buf, 0, len);
		}
		else if (package_state==STATE_STATEMENT_BUILDING) {
			mydebug("STATE_STATEMENT_BUILDING : Waiting for more sql statement from client... ");
		}
		else if (package_state==STATE_STATEMENT_COMPLETED) {
			mydebug("STATE_STATEMENT_COMPLETED");
			

			resendHIVEPackage(to_server_stream);
			
			
			if (sqlToExecuteInParallel.length()>0) {
				mydebug("----------------------------------------------------");
				mydebug("--------    RUNNING PARALLEL STATEMENT       -------");
				mydebug("----------------------------------------------------");
				mydebug(sqlToExecuteInParallel.toString());

				boolean is_ok=ddmLib.execSingleUpdateSQL(
						connParallel,
						sqlToExecuteInParallel.toString(),
						null
						);
				mydebug("Execution Returns : "+ is_ok); 
				
				if (is_ok && sqlToExecuteInParallel.toString().toUpperCase().contains("USE") ) {
					setCurrentSchemaForHIVE();
					ddmLib.setSessionKey(this,"CURRENT_SCHEMA",CURRENT_SCHEMA);
				}
					

				sqlToExecuteInParallel.setLength(0);
				mydebug("----------------------------------------------------");
			} // if (sqlToExecuteInParallel.length()>0)
			
			restartPackage();
			
			bufferArr.clear();
			
		}
		else if (package_state==STATE_NO_DATA_PACKAGE) {
			mydebug("STATE_NO_DATA_PACKAGE : Not a ExecuteStatement package... ");
			
			sendBuffer(to_server_stream, buf, 0, len);
			
			restartPackage();
		}
		else {
			mydebug("!!! UNKNOWN_PACKAGE_STATE    : "  +package_state);
			restartPackage();
			sendBuffer(to_server_stream, buf, 0, len);
		}
		
	}
	
	
	//****************************************************************************
	
	static final byte[] HIVE_START_OF_STATEMENT_BYTES=new byte[]{ (byte) 0,(byte) 0,(byte) 11,(byte) 0,(byte) 2};
	
	void feedHIVESinglePack(byte[] buf, int cursor, int len) {
		
		mydebug("\n------------feedHIVESinglePack-----------");
		byte[] printBytes=new byte[len];
		System.arraycopy(buf, cursor, printBytes,0, len);
		printByteArray(printBytes, len);
		mydebug("\n-------------------------------------");
		
		int package_size=ddmLib.contertByteArray2Integer(buf, 0, 4, ByteOrder.BIG_ENDIAN);
		mydebug("package size : "+package_size);
		
		int start_of_stmt_pos=ddmLib.IndexOfByteArray(buf, 80, len-5, HIVE_START_OF_STATEMENT_BYTES);
		
		if (start_of_stmt_pos==-1) {
			mydebug("hive statement start position not found ");
			package_state=STATE_START;
			return;
		}
		
		
		
		
		//test amacli !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		//package_state=STATE_START;
		
		if (package_state==STATE_STATEMENT_BUILDING) {
			
			statement_package_no++;
		}
		
		
		if (package_state==STATE_START) {
			
			clearPackage();
			statement_package_no++;
			
			package_state=STATE_STATEMENT_BUILDING;
			
			
		} //if (package_state==STATE_START)
		
		
		int statement_size=ddmLib.contertByteArray2Integer(buf, start_of_stmt_pos+HIVE_START_OF_STATEMENT_BYTES.length, 4, ByteOrder.BIG_ENDIAN);
		mydebug("statement_size  : "+statement_size);
		
		int statement_start_pos=start_of_stmt_pos+HIVE_START_OF_STATEMENT_BYTES.length+4;
		
		byte[] stmt_tmp_bytes=new byte[statement_size];
		System.arraycopy(buf, statement_start_pos, stmt_tmp_bytes, 0, statement_size);
		
		mydebug("byte Array For Statement : ");
		printByteArray(stmt_tmp_bytes, statement_size);		
		appendStatementByteArray(stmt_tmp_bytes);
		
		boolean is_last_portion=false;
		if (buf[len-2]== (byte) 0   &&  buf[len-1]==(byte) 0) is_last_portion=true;
		
		byte package_status=buf[1];
		mydebug("package_status : "+ package_status);
		
		
		if (is_last_portion) {
			convertHIVEByteArraysToSqlStatement();
			package_state=STATE_STATEMENT_COMPLETED;
		}
		
		
		
	}
	
	//************************************************************
	void convertHIVEByteArraysToSqlStatement() {
		byte[] buf=new byte[stmtByteBufferArr_len];
		int len=0;
		
		
		
		for (int i=0;i<stmtByteBufferArr.size();i++) {
			System.arraycopy(stmtByteBufferArr.get(i), 0, buf, len, stmtByteBufferArr.get(i).length);
			len+=stmtByteBufferArr.get(i).length;
		}

		
		mydebug("convertHIVEByteArraysToSqlStatement for : "+len);
		printByteArray(buf, len);
		
		stmtByteBufferArr.clear();
		stmtByteBufferArr_len=0;
		sql_statement.setLength(0);
		
		try {
			sql_statement.append(new String(buf, 0, buf.length, Charset.forName(dm.proxy_encoding)));
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		
		
		mydebug("convertHIVEByteArraysToSqlStatement sql : "+sql_statement.toString());
	}
	
	
	//************************************************************
	void checkHiveAuthorization(byte[] buf, int len) {
		if (len!=5) {
			mydebug("Not a hive server authorization package.");
			return;
		}
		
		
		
		if (buf[0]!= (byte) 5 || buf[1]!= (byte) 0 || buf[2]!= (byte) 0 || buf[3]!= (byte) 0 || buf[4]!= (byte) 0) {
			mydebug("not a hive server authorization package.");
			return;
		}
		
		mydebug("Hive authorization ok.");
		
		is_authorized=true;
	}
	
	
	//************************************************************
	
	void setMONGOSessionVariables(byte[] buf, int len) {
		
		sessionInfoForConnArr.clear();
		
		
		sessionInfoForConnArr.add(new String[]{"CLIENT_HOST_ADDRESS",CLIENT_HOST_ADDRESS});
		sessionInfoForConnArr.add(new String[]{"CLIENT_PORT",""+CLIENT_PORT});

		
		
		String username=ddmLib.nvl(ddmLib.getSessionKey(this,"CURRENT_USER"),"UnknownUser");
		
		proxy_session_id=dm.createNewProxySession(sessionInfoForConnArr,username);
		
		setPolicyGroup();
		
		is_authorized=true;
		
	}
	
	//************************************************************
	static final byte[] HIVE_AUTH_BYTES =new byte[]{ (byte) 1, (byte) 0,(byte) 0,(byte) 0};
	
	void setHIVESessionVariables(byte[] buf, int len) {
		
		int auth_bytes_pos=ddmLib.IndexOfByteArray(buf, 0, 10, HIVE_AUTH_BYTES);
		if (auth_bytes_pos!=0) return;
		
		
		sessionInfoForConnArr.clear();
		
		
		sessionInfoForConnArr.add(new String[]{"CLIENT_HOST_ADDRESS",CLIENT_HOST_ADDRESS});
		sessionInfoForConnArr.add(new String[]{"CLIENT_PORT",""+CLIENT_PORT});

		
		try {
			//decoding client connect package
			// sample : [1][0][0][0][5]PLAIN[5][0][0][0][17][0]hadoop[0]anonymous
			int cursor=4;
			
			int len_of_conn_style=ddmLib.byte2UnsignedInt(buf[cursor]);
			cursor++;
			
			byte[] connStyleBytes=new byte[len_of_conn_style];
			System.arraycopy(buf, cursor, connStyleBytes, 0, len_of_conn_style);
			mydebug("connStyleBytes bytes");
			printByteArray(connStyleBytes, connStyleBytes.length);
			String connStyleStr=new String(connStyleBytes);
			sessionInfoForConnArr.add(new String[]{"PROGRAM",connStyleStr});
			
			cursor+=connStyleBytes.length;
			
			//skip byte
			cursor++;
			
			//skip lentgh [0][0][0][17]
			cursor+=4;
			
			//skip first null
			cursor++;
			
			byte[] tmpBytes=new byte[200];
			int tmp_cursor=0;
			while(true) {
				if (cursor>len-1) break;
				byte nextByte=buf[cursor];
				if (nextByte==(byte) 0) nextByte=(byte) 64;
				tmpBytes[tmp_cursor]=nextByte;
				tmp_cursor++;
				cursor++;
			}
			
			mydebug("UserName bytes");
			printByteArray(tmpBytes, tmp_cursor);
			String userNameStr=new String(tmpBytes, 0, tmp_cursor);
			sessionInfoForConnArr.add(new String[]{"CURRENT_USER",userNameStr});
			
			
			
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		
		try {
			String driver=dm.target_db_driver_name;
    		String url=dm.target_db_url;
    		String user=dm.target_db_username;
    		String pass=dm.target_db_password;
    		
    		connParallel=ddmLib.getTargetDbConnection(driver, url, user, pass);
    		
    		
    	
    	} catch(Exception e) {
    		e.printStackTrace();
    	}
		
		String username=ddmLib.nvl(ddmLib.getSessionKey(this,"CURRENT_USER"),"UnknownUser");
		
		proxy_session_id=dm.createNewProxySession(sessionInfoForConnArr,username);
		
		setPolicyGroup();
		
	}
		
	//----------------------------------------------------------------
	boolean isHIVECommandToBeExecutedInParallelConnection() {
		
		mydebug("isHIVECommandToBeExecutedInParallelConnection start : ");
		
		//ALTER SESSION SET CURRENT_SCHEMA=xxxxxx;
		if (sql_statement.toString().replaceAll("\n|\r|\t", " ").trim().toUpperCase().startsWith("USE ")) {
			
			//sql injection önlemek icin
			if (sql_statement.length()>50) return false;
			
			return true; 
		}
		
		mydebug("isHIVECommandToBeExecutedInParallelConnection end : ");
		
		return false;
	}
	//************************************************************************
	byte[] makeMaskedHIVEBytes() {
		byte[]  ret1=sql_statement_masked.toString().getBytes(Charset.forName(dm.proxy_encoding));
		return ret1;
	}
	
	//***********************************************************************
	void resendHIVEPackage(DataOutputStream to_server_stream) {
		
		
		if (isHIVECommandToBeExecutedInParallelConnection()) {
			sqlToExecuteInParallel.setLength(0);
			sqlToExecuteInParallel.append(sql_statement.toString());
			
			mydebug("Parallel statement found : "+sqlToExecuteInParallel.toString());
		}
		
		//boolean to_be_masked=checkStatement();
		boolean to_be_masked=false;
		
		if (!to_be_masked) {
			mydebug("...!!! No masking done. Sending original bytes !!!...");
			
			sendSavedPackages(to_server_stream);
			
			return;
		}
		
		
		byte[] sql_statement_bytes=makeMaskedHIVEBytes();
		int sql_statement_full_byte_length=sql_statement_bytes.length;
		
		mydebug("----------------------------------------------------");
		mydebug("--------            COMMAND SENDING          -------");
		mydebug("----------------------------------------------------");
		
		
		mydebug("Masked Query  : + "+sql_statement_masked.toString().getBytes().length);
		mydebug(sql_statement_masked.toString());
		printByteArray(sql_statement_bytes, sql_statement_bytes.length);
		
		int max_pack_size=sql_statement_bytes.length+1000;
		
		byte[] sendBuf=new byte[max_pack_size];
		
		int cursor=0;
		
		for (int i=0;i<bufferArr.size();i++) {
			byte[] buf=bufferArr.get(i);
			System.arraycopy(buf, 0, sendBuf, cursor, buf.length); 
			cursor+=buf.length;
		}
		
		int sendbuf_len=cursor;
		
		int start_of_stmt_bytes_pos=ddmLib.IndexOfByteArray(sendBuf, 80, sendBuf.length, HIVE_START_OF_STATEMENT_BYTES);
		mydebug("start_of_stmt_bytes_pos="+start_of_stmt_bytes_pos);
		
		int stmt_len=ddmLib.contertByteArray2Integer(sendBuf, start_of_stmt_bytes_pos+HIVE_START_OF_STATEMENT_BYTES.length, 4, ByteOrder.BIG_ENDIAN);
		mydebug("stmt_len="+stmt_len);
		
		int after_statement_bytes_pos=start_of_stmt_bytes_pos+HIVE_START_OF_STATEMENT_BYTES.length+4+stmt_len;
		int after_statement_bytes_len=sendbuf_len-after_statement_bytes_pos;
		
		mydebug("after_statement_bytes_pos="+after_statement_bytes_pos);
		mydebug("after_statement_bytes_len="+after_statement_bytes_len);
		
		byte[] afterStatementBytes=new byte[after_statement_bytes_len];
		System.arraycopy(sendBuf, after_statement_bytes_pos, afterStatementBytes, 0, after_statement_bytes_len);
		mydebug("afterStatementBytes");
		printByteArray(afterStatementBytes, afterStatementBytes.length);
		
		mydebug("copying masked statement bytes");
		System.arraycopy(sql_statement_bytes, 0, sendBuf, start_of_stmt_bytes_pos+HIVE_START_OF_STATEMENT_BYTES.length+4, sql_statement_full_byte_length);

		byte[] stmtLenBytes=ddmLib.convertInteger2ByteArray4Bytes(sql_statement_full_byte_length, ByteOrder.BIG_ENDIAN);
		mydebug("Copying stmtLenBytes ...");
		printByteArray(stmtLenBytes, stmtLenBytes.length);
		System.arraycopy(stmtLenBytes, 0, sendBuf, start_of_stmt_bytes_pos+HIVE_START_OF_STATEMENT_BYTES.length, stmtLenBytes.length);
		
		mydebug("Copying afterStatementBytes ...");
		System.arraycopy(afterStatementBytes, 0, sendBuf, start_of_stmt_bytes_pos+HIVE_START_OF_STATEMENT_BYTES.length+4+sql_statement_full_byte_length, afterStatementBytes.length);
		
		int final_size=start_of_stmt_bytes_pos+HIVE_START_OF_STATEMENT_BYTES.length+4+sql_statement_full_byte_length+afterStatementBytes.length;
		mydebug("final_size="+(final_size-4));
		

		byte[] packageLenBytes=ddmLib.convertInteger2ByteArray4Bytes(final_size-4, ByteOrder.BIG_ENDIAN);
		mydebug("Copying packageLenBytes ...");
		printByteArray(packageLenBytes, packageLenBytes.length);
		System.arraycopy(packageLenBytes, 0, sendBuf, 0, packageLenBytes.length);
		
		mydebug("finalBytes :");
		printByteArray(sendBuf, final_size);
		
		
		mydebug("Sending buffer : ");
		printByteArray(sendBuf, final_size);
		
		try {
			to_server_stream.write(sendBuf, 0, final_size);
			to_server_stream.flush();
		} catch(Exception e) {
			mylog("Exception@rewriteSqlToBuffer : " + genLib.getStackTraceAsStringBuilder(e).toString());
		}
		
		
		
	}
	
	
	
	//********************************************************************
	public void feedMySQLPack( 
			byte[] buf, 
			int len, 
			DataOutputStream to_server_stream
			) {
		
		
		
		byte package_type=buf[4];
		
		int package_size=ddmLib.contertByteArray2Integer(buf, 0, 3, ByteOrder.LITTLE_ENDIAN);
		
		mydebug("MySql.package_type    : "+package_type);
		mydebug("MySql.package_length  : "+package_size);
		
		//client connects
		/*if (!is_authorized && ddmLib.IndexOfByteArray(buf, 8, 50, dm.MYSQL_CONNECT_IDENTIFIER_BYTES)>-1) {
			mydebug("MySQL Client Connection Package, len : "+len);
			setMySQLSessionVariables(buf, len);
			package_state=STATE_START;
			bufferArr.clear();
			sendBuffer(to_server_stream, buf, 0, len);
			return;
		}
		else*/ 
		
		if (package_type==(byte) 0x03 ||  package_type==(byte) 0x16) {
			mydebug(":) My SQL Command or PreparedStatement package ");
			byte[] originalBuf=new byte[len];
			System.arraycopy(buf, 0, originalBuf, 0, len);
			bufferArr.add(originalBuf);
			
			try {
				feedMySQLSinglePack(buf, 0, len);
			} catch(Exception e) {
				e.printStackTrace();
				package_state=STATE_START;
				clearPackage();
			}
			
		} else {
			
			package_state=STATE_NO_DATA_PACKAGE;
			
		}
		
		
		
		if (package_state==STATE_START) {
			mydebug("STATE_START");
			bufferArr.clear();
			sendBuffer(to_server_stream, buf, 0, len);
		}
		else if (package_state==STATE_STATEMENT_BUILDING) {
			mydebug("STATE_STATEMENT_BUILDING : Waiting for more sql statement from client... ");
		}
		else if (package_state==STATE_STATEMENT_COMPLETED) {
			mydebug("STATE_STATEMENT_COMPLETED");
			

			resendMySQLPackage(to_server_stream);
			
			
			if (sqlToExecuteInParallel.length()>0) {
				mydebug("----------------------------------------------------");
				mydebug("--------    RUNNING PARALLEL STATEMENT       -------");
				mydebug("----------------------------------------------------");
				mydebug(sqlToExecuteInParallel.toString());

				boolean is_ok=ddmLib.execSingleUpdateSQL(
						connParallel,
						sqlToExecuteInParallel.toString(),
						null
						);
				mydebug("Execution Returns : "+ is_ok); 
				
				if (is_ok && sqlToExecuteInParallel.toString().toUpperCase().contains("USE ") ) {
					setCurrentSchemaForMySql();
					ddmLib.setSessionKey(this,"CURRENT_SCHEMA",CURRENT_SCHEMA);
				}
					

				sqlToExecuteInParallel.setLength(0);
				mydebug("----------------------------------------------------");
			} // if (sqlToExecuteInParallel.length()>0)

			
			restartPackage();
			
			bufferArr.clear();
			
		}
		else if (package_state==STATE_NO_DATA_PACKAGE) {
			mydebug("STATE_NO_DATA_PACKAGE : Not a SQL DATA package... ");
			
			sendBuffer(to_server_stream, buf, 0, len);
			
			restartPackage();
		}
		else {
			mydebug("!!! UNKNOWN_PACKAGE_STATE    : "  +package_state);
			restartPackage();
			sendBuffer(to_server_stream, buf, 0, len);
		}
		
	}
	
	//****************************************************************************
	void feedMySQLSinglePack(byte[] buf, int cursor, int len) {
		
		mydebug("\n------------feedMySQLSinglePack-----------");
		byte[] printBytes=new byte[len];
		System.arraycopy(buf, cursor, printBytes,0, len);
		printByteArray(printBytes, len);
		mydebug("\n-------------------------------------");
		
		
		int statement_start_pos=4;
		int statement_end_pos=len-1;
		
		
		if (package_state==STATE_START) {
			
			clearPackage();
			statement_package_no++;
			
			package_state=STATE_STATEMENT_BUILDING;
			
			
		} //if (package_state==STATE_START)
		
		
		int stmt_byte_arr_len=statement_end_pos-statement_start_pos+1;
		byte[] stmt_tmp_bytes=new byte[stmt_byte_arr_len];
		System.arraycopy(buf, statement_start_pos, stmt_tmp_bytes, 0, stmt_byte_arr_len);
		
		mydebug("byte Array For Statement : ");
		printByteArray(stmt_tmp_bytes, stmt_byte_arr_len);		
		appendStatementByteArray(stmt_tmp_bytes);
		
		//byte package_status=buf[1];
		//mydebug("package_status : "+ package_status);
		
		
		//if (package_status==(byte) 0x01) {
			convertMySQLByteArraysToSqlStatement();
			package_state=STATE_STATEMENT_COMPLETED;
		//}
		
		
	}
	
	
	//************************************************************
	int mysql_connection_id=0;
	
	void setMySQLSessionVariables(byte[] buf, int len) {

		
		byte package_type=buf[4];
		
		if (mysql_connection_id==0) {
			if (package_type!= (byte) 0x0a) {
				mydebug("Not connection accept package");
				return;
			}
			
			mydebug("Connection accept package found");
			
			int pos_of_connection_id=5;
			while(true) {
				if (buf[pos_of_connection_id]==0) break;
				pos_of_connection_id++;
			}
		 	
			//skip zero
			pos_of_connection_id++;
			
			mysql_connection_id=ddmLib.contertByteArray2Integer(buf, pos_of_connection_id, 4, ByteOrder.LITTLE_ENDIAN);
			
			mydebug("MySQL Connection id : "+mysql_connection_id);
			
			return;
		}
		
		is_authorized=true;
		
		sessionInfoForConnArr.clear();
		
		
		sessionInfoForConnArr.add(new String[]{"CLIENT_HOST_ADDRESS",CLIENT_HOST_ADDRESS});
		sessionInfoForConnArr.add(new String[]{"CLIENT_PORT",""+CLIENT_PORT});

		sessionInfoForConnArr.add(new String[]{"CONNECTION_ID",""+mysql_connection_id});

		int pos_accept=ddmLib.IndexOfByteArray(buf, 0, len, dm.MYSQL_CONNECT_ACCEPT_BYTES);
	
		if (pos_accept==-1) return;
		
		
		String username="UNKNOWN";
		String database="UNKNOWN";
		
		try {
    		String driver=dm.target_db_driver_name;
    		String url=dm.target_db_url;
    		String user=dm.target_db_username;
    		String pass=dm.target_db_password;
    		connParallel=ddmLib.getTargetDbConnection(driver, url, user, pass);
    		
    		String sql="SELECT user, db FROM INFORMATION_SCHEMA.PROCESSLIST where id=? ";
    		
    		ArrayList<String[]> bindlist=new ArrayList<String[]>();
    		bindlist.add(new String[]{"INTEGER",""+mysql_connection_id});
    		
    		
    		
    		ArrayList<String[]> arr=ddmLib.getDbArray(connParallel, sql, 1, bindlist, 3);
    		
    		if (arr!=null && arr.size()==1) {
    			username=arr.get(0)[0];
    			database=arr.get(0)[1];
    			
    			CURRENT_SCHEMA=database;
    			mydebug("Initial DB is set to : "+ CURRENT_SCHEMA);
    		} else {
    			mydebug("initial DB is not set. arr="+arr);
    		}
    		
    		
    	
    	} catch(Exception e) {
    		e.printStackTrace();
    	}
		
		
		sessionInfoForConnArr.add(new String[]{"CURRENT_USER",username});
		sessionInfoForConnArr.add(new String[]{"CURRENT_SCHEMA",database});

		
		proxy_session_id=dm.createNewProxySession(sessionInfoForConnArr,username);
		
		
		
		
		setPolicyGroup();
	
	
		
	}
	
	
	//************************************************************************
	byte[] makeMySqlBytes() {
		byte[]  ret1=sql_statement_masked.toString().getBytes(Charset.forName(dm.proxy_encoding));
		return ret1;
	}
	
	
	//***********************************************************************
	void resendMySQLPackage(DataOutputStream to_server_stream) {
		
		
		
		//boolean to_be_masked=checkStatement();
		//mysql tamamen yeniden yazilacak
		boolean to_be_masked=false;
		
		if (isCommandToBeExecutedInParallelConnection()) {
			sqlToExecuteInParallel.setLength(0);
			sqlToExecuteInParallel.append(sql_statement.toString());
			
			mydebug("Parallel statement found : "+sqlToExecuteInParallel.toString());
		}
		
		//test amacli kaldirilacak
		
		
		if (!to_be_masked) {
			mydebug("...!!! No masking done. Sending original bytes !!!...");
			
			sendSavedPackages(to_server_stream);
			
			return;
		}
		
		byte[] sql_statement_bytes=makeMySqlBytes();
		int sql_statement_full_byte_length=sql_statement_bytes.length;
		
		mydebug("----------------------------------------------------");
		mydebug("--------            COMMAND SENDING          -------");
		mydebug("----------------------------------------------------");
		
		mydebug("Masked Query  : + "+sql_statement_masked.toString().getBytes().length);
		mydebug(sql_statement_masked.toString());
		printByteArray(sql_statement_bytes, sql_statement_bytes.length);
		
		int max_pack_size=sql_statement_bytes.length+1000;
		
		byte[] sendBuf=new byte[max_pack_size];
		
		int cursor=0;
		
		for (int i=0;i<bufferArr.size();i++) {
			byte[] buf=bufferArr.get(i);
			System.arraycopy(buf, 0, sendBuf, cursor, buf.length); 
			cursor+=buf.length;
		}
				
		int start_of_stmt_bytes_pos=5;
		mydebug("start_of_stmt_bytes_pos="+start_of_stmt_bytes_pos);
		
		
		
		mydebug("copying masked statement bytes");
		System.arraycopy(sql_statement_bytes, 0, sendBuf, start_of_stmt_bytes_pos, sql_statement_full_byte_length);

		int final_size=sql_statement_full_byte_length+1;
		mydebug("final_size="+final_size);
		

		byte[] packageLenBytes=ddmLib.convertInteger2ByteArray4Bytes(final_size, ByteOrder.LITTLE_ENDIAN);
		mydebug("Copying packageLenBytes ...");
		printByteArray(packageLenBytes, packageLenBytes.length);
		System.arraycopy(packageLenBytes, 0, sendBuf, 0, 3);
		
		mydebug("finalBytes :");
		printByteArray(sendBuf, final_size+4);
		
		
		mydebug("Sending buffer : ");
		printByteArray(sendBuf, final_size+4);
		
		try {
			to_server_stream.write(sendBuf, 0, final_size+4);
			to_server_stream.flush();
		} catch(Exception e) {
			mylog("Exception@rewriteSqlToBuffer : " + genLib.getStackTraceAsStringBuilder(e).toString());
		}
		
		
	}
	
	
	
	//***************************************************************
	void convertMySQLByteArraysToSqlStatement() {
		byte[] buf=new byte[stmtByteBufferArr_len];
		int len=0;
		
		
		
		for (int i=0;i<stmtByteBufferArr.size();i++) {
			System.arraycopy(stmtByteBufferArr.get(i), 0, buf, len, stmtByteBufferArr.get(i).length);
			len+=stmtByteBufferArr.get(i).length;
		}

		
		mydebug("convertMySQLByteArraysToSqlStatement for : "+len);
		printByteArray(buf, len);
		
		stmtByteBufferArr.clear();
		stmtByteBufferArr_len=0;
		
		mydebug("convertMySQLByteArraysToSqlStatement for : "+buf.length);
		printByteArray(buf, buf.length);
		
		
		
		sql_statement.setLength(0);
		
		try {
			//ilk byte skip edilir. 3 ya da 22 (ox16)
			sql_statement.append(new String(buf, 1, buf.length-1, Charset.forName(dm.proxy_encoding)));
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		mydebug("convertMySQLByteArraysToSqlStatement sql : "+sql_statement.toString());
		
		
	}
	
	
	
	//********************************************************************
	
	String mongo_collection_name=null;
	BasicBSONDecoder BSONdecoder=new BasicBSONDecoder();
	BasicBSONEncoder BSONencoder=new BasicBSONEncoder();
	
	public int feedMONGOPack( 
			byte[] buf, 
			int len, 
			DataOutputStream target_stream,
			int origin
			) {
		
		if (origin==dm.FROM_CLIENT) {
			mydebug("FROM CLIENT  ........................:");
			printByteArray(buf, len);
			
			mongo_collection_name=null;
			
			boolean is_query_pack=ddmLib.isMongoQueryPack(buf,len);
			
			if (!is_query_pack) return len;
			
			mongo_collection_name=ddmLib.decodeMongoCollectionNameFromPack(buf,len);
			
			mydebug("mongo_collection_name="+mongo_collection_name);
		}
			
		else {
			mydebug("FROM SERVER  ........................:");
			printByteArray(buf, len);
			
			if (mongo_collection_name==null) return len;
			
			boolean to_be_masked=dm.hmConfig.containsKey("IS_TABLE_MASKED_"+mongo_collection_name);
			
			if (!to_be_masked) {
				mydebug(" collection ["+mongo_collection_name+"] is not to be masked. ");
				return len;
			}
			
			byte[] masked_buf=ddmLib.maskMongoPackage(this, buf, len);
			int masked_len=masked_buf.length;
			
			mydebug("masked_len="+masked_len);
			
			try {
				target_stream.write(masked_buf, 0,masked_len);
				//target_stream.flush();
				return -len;
			} catch(Exception e) {
				mydebug(genLib.getStackTraceAsStringBuilder(e).toString());
				return len;
			}
				
			
			
		}
		
		
		return len;
	}
	
	
	//******************************************************************************************
	
	boolean checkStatementForMicrosoftSQLT2() {
		
		if (sql_statement.length()==0) {
			mydebug("sql statement is null. Will not be masked.");
			return false;
		}
		
		
		boolean to_be_masked=false;
		
		long start_ts=System.currentTimeMillis();
			
		
				
		sql_statement_masked.setLength(0);
		sql_statement_masked.append(sql_statement.toString());
		
		boolean is_sql_in_exception_list=checkSqlExceptionList(sql_statement, sql_statement_masked);
		
		if (is_sql_in_exception_list) {
			if(dm.is_debug || is_tracing)  mydebug("Sql is modified since it is in statement exception list : " + sql_statement_masked.toString());
			is_rewritable_statement=false;
			bindList.clear();
			to_be_masked=true;
		} //if (is_sql_in_exception_list)
		
		else {

			to_be_masked=true;
			
			maskMicrosoftSQLCommandWithParser();
			
			ddmLib.validateSession(this);
			
			long log_ts=System.currentTimeMillis();
			
			if (client_log_statement && System.currentTimeMillis()>proxy_instance_start_ts+SQL_LOGGING_START_INTERVAL)
				ddmLib.addProxyEvent(
						dm,
						dm.proxyEventArray, 
						dm.SQL,
						""+log_ts,
						genLib.nvl(CURRENT_CATALOG, "${default}")+"."+CURRENT_SCHEMA,
						sql_statement.toString(),
						sql_statement.toString(),
						sql_statement_masked.toString(),
						this.proxy_session_id,
						"",
						null,
						"0" //sampleData.size()
						);
			
			if (sql_statement.length()==sql_statement_masked.length()) to_be_masked=false;
		
		} 
		
		if(dm.is_debug || is_tracing)  
			mydebug("checkMicrosoftSQLStatement returns masked:  "+to_be_masked+" in "+(System.currentTimeMillis()-start_ts) +" msecs");
		
		
		return to_be_masked;
	}
	
	
	
	
	//****************************************************************
	void maskMicrosoftSQLCommandWithParser() {
		
				
		ArrayList<Integer[]> locations=new ArrayList<Integer[]>();
		ArrayList<String> selectQueries=new ArrayList<String>();

		msSqlParser.locateSelectQueries(sql_statement.toString(), 0, locations, selectQueries);
		
		for (int i=selectQueries.size()-1;i>=0;i--) {
			Integer[] loc=locations.get(i);
			msSqlSTMT stmt=msSqlParser.parse(selectQueries.get(i) ,null, this);
		


			String rewritten_sql=stmt.rewriteSingleSQL(this, false, true, null);


			sql_statement_masked.delete(loc[0], loc[01]);
			sql_statement_masked.insert(loc[0], rewritten_sql+" ");
		}
		
		mydebug(" sql_statement_masked  :"+sql_statement_masked.toString());
		
	}
	
	
	
}

