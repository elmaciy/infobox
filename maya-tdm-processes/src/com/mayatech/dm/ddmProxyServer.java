package com.mayatech.dm;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.nio.ByteOrder;
import java.sql.Connection;
import java.sql.DriverManager;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.concurrent.ConcurrentHashMap;

import com.mayatech.baseLibs.genLib;
import com.mayatech.dm.dmOracleParser.oracleParser;
import com.mayatech.dm.protocolTns.oracleTnsLib;

public class ddmProxyServer {
	
	
	public int proxy_id;
	public String port;
	public int server_port;
	public String server_host;
	public String proxy_type;
	public String secure_client="NO";
	public String secure_public_key;
	public String proxy_encoding="utf-8";
	public int target_app_id=0;
	public int target_env_id=0;
	
	ThreadGroup clientThreadGroup = new ThreadGroup("Client Thread Group");

	byte[] public_key_byte_arr=null;
	
	boolean is_secure_client=false;
	
	boolean is_proxy_cancelled=false;
	
	int active_listener_count=0;
	
	boolean is_discovery_active=false;
	
	int MAX_PACKAGE_SIZE=2048;
	
	public ArrayList<String[]> monitoringColumnsArray=new ArrayList<String[]>();
	public ArrayList<String[]> monitoringExpressionsArray=new ArrayList<String[]>();
	public ArrayList<String[]> monitoringReceivedBytesArray=new ArrayList<String[]>();

	
	boolean is_client_status_loading=false;
	ArrayList<String[]> clientStatusArray=new ArrayList<String[]>();
	
	long last_configuration_load_time=0;
	

	ArrayList<String[]> sqlLoggingExceptionRules=new ArrayList<String[]>();
	ArrayList<String[]> sqlStatementExceptionRules=new ArrayList<String[]>();
	
	ArrayList<String[]> monitoringPolicies=new ArrayList<String[]>();
	ArrayList<String[]> monitoringEmailArr=new ArrayList<String[]>();


	String conf_db_driver="";
	String conf_db_url="";
	String conf_db_username="";
	String conf_db_password="";
	
	String target_db_driver_name="";
	String target_db_url="";
	String target_db_username="";
	String target_db_password="";
	
	public boolean is_debug=false;
	String proxy_extra_args="";

	
	
	Connection connConf=null;
	
	int BUFFER_SIZE=1024*1024;
	
	@SuppressWarnings("rawtypes")
	public ConcurrentHashMap hmConfig = new ConcurrentHashMap();
	public ConcurrentHashMap hmCache = new ConcurrentHashMap();
	public ConcurrentHashMap hmOracleChunkConfiguration = new ConcurrentHashMap();

	public int sample_size=1000;
	
	boolean DDM_LOG_STATEMENT=false;
	
	boolean force_configuration_load=false;
	boolean configuration_loading=false;
	
	long last_configuration_load_ts=0;
	int DDM_CONFIGURATION_RELOAD_INTERVAL=60*60*1000;
	
	
	long next_acrhive_monitoring_columns_ts=0;
	static final int ARCHIVE_MONITORING_COLUMNS_INTERVAL=12*60*60*1000;
	
	String JAVAX_EMAIL_USERNAME="";
	String JAVAX_EMAIL_PASSWORD="";
	String JAVAX_EMAIL_PROPERTIES="";
	
	final String PROXY_TYPE_ORACLE_T2	="ORACLE_T2";
	final String PROXY_TYPE_MSSQL_T2	="MSSQL_T2";
	final String PROXY_TYPE_POSTGRESQL	="POSTGRESQL";
	final String PROXY_TYPE_HIVE		="HIVE";
	final String PROXY_TYPE_MONGODB		="MONGODB";
	final String PROXY_TYPE_MYSQL		="MYSQL";
	final String PROXY_TYPE_GENERIC		="GENERIC";
	
	//[7][0][0][2]	[0][0][0][2]	[0][0][0]
	final byte[] MYSQL_CONNECT_ACCEPT_BYTES=new byte[]{ 
		(byte) 7, (byte) 0, (byte) 0, (byte) 2,
		(byte) 0, (byte) 0, (byte) 0, (byte) 2, 
		(byte) 0, (byte) 0, (byte) 0};
	
	ArrayList<String[]> proxyEventArray=new ArrayList<String[]>();
	
	String db_functions="";
	
	static final String db_functions_GENERAL=" " +
			" SELECT TOP DISTINCT FROM WHERE UNION MINUS ALL WITH GROUP BY HAVING BETWEEN LIKE NOT MOD AND OR XOR REGEXP NULL IS LIMIT "+
			" ".toUpperCase();
	
	
	static final String db_functions_MYSQL=" " +
			" CASE IF IFNULL NULLIF" + // Control Flow Functions
			" ASCII BIN BIT_LENGTH CHAR CHAR_LENGTH CHARACTER_LENGTH CONCAT CONCAT_WS ELT EXPORT_SET FIELD FIND_IN_SET FORMAT FROM_BASE64 HEX INSERT INSTR LCASE LEFT LENGTH LIKE LOAD_FILE LOCATE LOWER LPAD " + // String Functions
			" LTRIM MAKE_SET MATCH MID REGEXP OCT OCTET_LENGTH ORD POSITION QUOTE REPEAT REPLACE REVERSE RIGHT RLIKE RPAD RTRIM SOUNDEX SOUNDS SPACE STRCMP SUBSTR SUBSTRING SUBSTRING_INDEX TO_BASE64 TRIM UCASE UNHEX UPPER WEIGHT_STRING "  +
			" ABS ACOS ASIN ATAN ATAN2 CEIL CEILING CONV COS COT CRC32 DEGREES DIV EXP FLOOR LN LOG LOG10 LOG2 MOD PI " + // Numeric Functions and Operators
			" POW POWER RADIANS RAND ROUND SIGN SQRT TAN TRUNCATE " + 
			"  ADDDATE ADDTIME CONVERT_TZ CURDATE CURRENT_DATE  CURRENT_DATECURRENT_TIME  CURRENT_TIMECURRENT_TIMESTAMP CURRENT_TIMESTAMPCURTIME " +// Date and Time Functions
			" DATE DATE_ADD DATE_FORMAT DATE_SUB DATEDIFF DAY DAYNAME DAYOFMONTH DAYOFWEEK DAYOFYEAR EXTRACT FROM_DAYS FROM_UNIXTIME GET_FORMAT " +
			" HOUR LAST_DAY LOCALTIME  LOCALTIME LOCALTIMESTAMP LOCALTIMESTAMP MAKEDATE MAKETIME MICROSECOND MINUTE MONTH MONTHNAME NOW PERIOD_ADD PERIOD_DIFF " +
			" QUARTER SEC_TO_TIME SECOND STR_TO_DATE SUBDATE SUBTIME SYSDATE TIME TIME_FORMAT TIME_TO_SEC TIMEDIFF TIMESTAMP TIMESTAMPADD TIMESTAMPDIFF " +
			" TO_DAYS TO_SECONDS UNIX_TIMESTAMP UTC_DATE UTC_TIME UTC_TIMESTAMP WEEK WEEKDAY WEEKOFYEAR YEAR YEARWEEK " +
			" BINARY CAST CONVERT BIT_COUNT " + // Cast Functions
			" ExtractValue UpdateXML " + // XML Functions
			" AES_DECRYPT AES_ENCRYPT COMPRESS DECODE DES_DECRYPT DES_ENCRYPT ENCODE  ENCRYPT MD5 OLD_PASSWORD PASSWORD RANDOM_BYTES SHA1 SHA SHA2 UNCOMPRESS UNCOMPRESSED_LENGTH VALIDATE_PASSWORD_STRENGTH " + // Encryption  Functions
			" BENCHMARK CHARSET COERCIBILITY COLLATION CONNECTION_ID CURRENT_USER DATABASE FOUND_ROWS LAST_INSERT_ID ROW_COUNT SCHEMA SESSION_USER SYSTEM_USER USER VERSION  " + // Information  Functions
			" JSON_APPEND JSON_ARRAY JSON_ARRAY_APPEND JSON_ARRAY_INSERT JSON_CONTAINS JSON_CONTAINS_PATH JSON_DEPTH JSON_EXTRACT JSON_INSERTL " + // JSON Functions
			" JSON_KEYS JSON_LENGTH JSON_MERGE JSON_OBJECT JSON_QUOTE JSON_REMOVE JSON_REPLACE JSON_SEARCH JSON_SET JSON_TYPE JSON_UNQUOTE JSON_VALID " + 
			" ASYMMETRIC_DECRYPT ASYMMETRIC_DERIVE ASYMMETRIC_ENCRYPT ASYMMETRIC_SIGN ASYMMETRIC_VERIFY CREATE_ASYMMETRIC_PRIV_KEY CREATE_ASYMMETRIC_PUB_KEY CREATE_DH_PARAMETERS CREATE_DIGEST  " + // Enterprise Encryption Function
			" ANY_VALUE DEFAULT GET_LOCK INET_ATON INET_NTOA INET6_ATON INET6_NTOA IS_FREE_LOCK IS_IPV4 IS_IPV4_COMPAT IS_IPV4_MAPPED IS_IPV6  " + // MISC. Functions
			" IS_USED_LOCK MASTER_POS_WAIT NAME_CONST RAND RELEASE_ALL_LOCKS RELEASE_LOCK SLEEP UUID UUID_SHORT VALUES  " + 
			" AVG BIT_AND BIT_OR BIT_XOR COUNT DISTINCT GROUP_CONCAT MAX MIN STD STDDEV STDDEV_POP STDDEV_SAMP SUM VAR_POP VAR_SAMP VARIANCE  " + // GROUP BY (Aggregate) Functions
			"  ".toUpperCase();

	public int TEST_PARALLEL_DB_CONNECTION_TIMEOUT=2*60*1000;
	public int DYNAMIC_CLIENT_IDDLE_TIMEOUT=2*60*1000;
	public int DDM_CALENDAR_ID=0;
	public int DDM_SESSION_VALIDATION_ID=0;
	
	public int CHECK_CLIENT_CONFIGURATION=5*1000;
	
	
	
	
	
	 
	//*********************************************************************
	synchronized String createNewProxySession(
			ArrayList<String[]> sessionInfoForConnArr, 
			String username
			) {
		
		String proxy_session_id=""+ (long)  (System.currentTimeMillis() % 1000000000);
		
		
		
		ddmLib.addProxyEvent(
				this,
				proxyEventArray, 
				SESSION,
				""+System.currentTimeMillis(),
				username,
				null,
				null,
				null,
				proxy_session_id,
				null,
				ddmLib.getSessionInfoAsString(sessionInfoForConnArr),
				null
				);
		
		try{Thread.sleep(1);} catch(Exception e) {}
		
		return proxy_session_id;
	}
	
	
	
	//*******************************************************
	void setCheckListMappings(ConcurrentHashMap hmNew, String rule_id, String rule_type, String rule_parameter1, String db_id) {
		
		ArrayList<String[]> checkList=new ArrayList<String[]>();
		
		String arr_str=rule_parameter1;
		
		
		if (rule_parameter1.toLowerCase().trim().indexOf("select")>-1 && rule_parameter1.toLowerCase().trim().indexOf("from")>-1) {
			
			arr_str=getValuesFromDb(connConf, db_id, rule_parameter1);
			
		} else if (rule_parameter1.toUpperCase().trim().indexOf("LDAP:")>-1) {
			arr_str=getValuesFromLdap(connConf, db_id, rule_parameter1);
		}
		
		String[] arr=arr_str.split("\n|\r");
		
		for (int i=0;i<arr.length;i++) {
			if (arr[i].trim().length()==0) continue;
			checkList.add(new String[]{arr[i]});
		}
		
		ArrayList<String> containsAnyList=new ArrayList<String>();
		
		for (int i=0;i<checkList.size();i++) {
			String str=checkList.get(i)[0];
			
			if (rule_type.equals("IN")) {
				int hashcode=ddmLib.normalizeString(str.toUpperCase()).hashCode();
				String key="CHECKLIST_KEY_"+rule_id+"_"+hashcode;
				hmNew.put(key, true);
			}
			else {
				containsAnyList.add(ddmLib.normalizeString(str.toUpperCase()));
			}
			
			
		}
		
		if (rule_type.equals("CONTAINS_ANY")) 
			hmNew.put("CONTAIN_ANY_LIST_"+rule_id, containsAnyList);
		
		
		
	}
	
	
		
	
	//********************************************************
	String getValuesFromDb(Connection connConf, String db_id, String sqlin) {
		
		mydebug("getValuesFromDb sql  : " + sqlin);
		
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String db_driver_name="";
		String db_url="";
		String db_username="";
		String db_password="";
		
		if (db_id.equals("0") || db_id.length()==0) {
			db_driver_name=target_db_driver_name;
			db_url=target_db_url;
			db_username=target_db_username;
			db_password=target_db_password;
		} else {
			String sql="select db_driver, db_connstr, db_username, db_password from tdm_envs where id=?";
			
			
			bindlist.add(new String[]{"INTEGER",db_id});
			
			ArrayList<String[]> arr=ddmLib.getDbArray(connConf, sql, 1, bindlist, 0);
			
			if (arr!=null && arr.size()==1) {
				db_driver_name=arr.get(0)[0];
				db_url=arr.get(0)[1];
				db_username=arr.get(0)[2];
				db_password=genLib.passwordDecoder(arr.get(0)[3]) ;
			}
			
		}
		
		
		
		
		Connection connApp=ddmLib.getTargetDbConnection(db_driver_name,	db_url, db_username, db_password); 
		
		if (connApp!=null) {
			bindlist.clear();
			
			ArrayList<String[]> valList=ddmLib.getDbArray(connApp, sqlin, 1000, bindlist, 0);
		
			StringBuilder sb=new StringBuilder();
			for (int i=0;i<valList.size();i++) {
				if (sb.length()>0) sb.append("\n");
				sb.append(valList.get(i)[0]);
				mydebug("getValuesFromDb adding " + valList.get(i)[0]);
			}
			
			try {connApp.close();} catch(Exception e) {}
			
			return sb.toString();
			
			
		}
	 else return sqlin;
	}
	
	
	//********************************************************
	String getValuesFromLdap(Connection connConf, String db_id, String ldap_query) {
		
		mydebug("getValuesFromLdap sql  : " + ldap_query);
		
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String db_driver_name="";
		String db_url="";
		String db_username="";
		String db_password="";
		
		if (db_id.equals("0") || db_id.length()==0) {
			db_driver_name=target_db_driver_name;
			db_url=target_db_url;
			db_username=target_db_username;
			db_password=target_db_password;
		} else {
			String sql="select db_driver, db_connstr, db_username, db_password from tdm_envs where id=?";
			
			
			bindlist.add(new String[]{"INTEGER",db_id});
			
			ArrayList<String[]> arr=ddmLib.getDbArray(connConf, sql, 1, bindlist, 0);
			
			if (arr!=null && arr.size()==1) {
				db_driver_name=arr.get(0)[0];
				db_url=arr.get(0)[1];
				db_username=arr.get(0)[2];
				db_password=genLib.passwordDecoder(arr.get(0)[3]) ;
			}
			
		}
		
		
		
		
		Connection connApp=ddmLib.getTargetDbConnection(db_driver_name,	db_url, db_username, db_password); 
		
		if (connApp!=null) {
			bindlist.clear();
			
			ArrayList<String[]> valList=ddmLib.getDbArray(connApp, ldap_query, 1000, bindlist, 0);
		
			StringBuilder sb=new StringBuilder();
			for (int i=0;i<valList.size();i++) {
				if (sb.length()>0) sb.append("\n");
				sb.append(valList.get(i)[0]);
				mydebug("getValuesFromLdap adding " + valList.get(i)[0]);
			}
			
			try {connApp.close();} catch(Exception e) {}
			
			return sb.toString();
			
			
		}
	 else return ldap_query;
	}
		
	//********************************************************
	boolean loadLastConfiguration() {
		
		long start_ts=System.currentTimeMillis();
		
		
		if (!hmConfig.isEmpty()) {
			mylog("This is not a initial configuration loading. ");
			return false;
		}
		
		mylog("Loading previous configuration from repository... ");
		
		byte[] lastConfigByteArrCompressed=ddmLib.getInfoBin(connConf,"tdm_proxy",proxy_id,"last_configuration");
		
		
		
		if (lastConfigByteArrCompressed==null) {
			mylog("Previous configuration was not cached. ");
			return false;
		}
		
		ConcurrentHashMap hmTemp=null;
		
		
		
		try{
			
			byte[] lastConfigByteArr=ddmLib.decompress(lastConfigByteArrCompressed);
			//ddmLib.printByteArray(lastConfigByteArr, lastConfigByteArr.length);
			hmTemp=ddmLib.byteArrToHashMap(lastConfigByteArr);
		}
		catch(Exception e) {
			mylog("Previous configuration can not be converted. ");
			e.printStackTrace();
			return false;
		}
		
		
		if (hmTemp==null) {
			mylog("Previous configuration converted to null. ");
			return false;
		}
		
		
		hmConfig.clear();
		try{
			hmConfig.putAll(hmTemp);
			} catch(Exception e) {
				hmConfig.clear();
				e.printStackTrace();
				return false;
			}
		
		mylog("Previous configuration loaded from cache ("+(System.currentTimeMillis()-start_ts)+" msecs). ");
		
		return true;
	}
	
	//********************************************************
	void saveLastConfiguration() {
		
		byte[] configurationtoSave=ddmLib.hashMapToByteArr(hmConfig);
		
		if (configurationtoSave==null) {
			mylog("HashMap can not be serialized.");
			return;
		}
		
		byte[] lastConfigByteArrCompressed=ddmLib.compress(configurationtoSave);
		
		
		ddmLib.setBinInfo(connConf, "tdm_proxy",proxy_id,"last_configuration", lastConfigByteArrCompressed);
		
		mylog("Last configuration saved to cache. ");
	}
	
	//********************************************************
	synchronized void loadConfiguration() {
		mylog("Loading masking profiles...");
		
		if (configuration_loading) return;
		
		
		
		ConcurrentHashMap hmNew = new ConcurrentHashMap();
		
		
		force_configuration_load=false; 
		if (hmConfig.isEmpty()) configuration_loading=true;
		
		ddmLib.setProxyLoading(connConf, proxy_id);
		
		boolean is_last_conf_loaded=loadLastConfiguration();
		
		if (is_last_conf_loaded) {
			//unlock sessions while configuration loading...
			configuration_loading=false;
		}
		
		
		String sql="";
		
		long start_ts=System.currentTimeMillis();
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		//-----------------------------------------------------------------------------------------------------

		sample_size=1000;
		sql="select param_value from tdm_parameters where param_name='DISCOVERY_SAMPLE_SIZE'";
		
		String DISCOVERY_SAMPLE_SIZE="";
		try {
			
			DISCOVERY_SAMPLE_SIZE=ddmLib.getDbArray(connConf, sql, 1, null, 0).get(0)[0].trim(); 
			sample_size=Integer.parseInt(DISCOVERY_SAMPLE_SIZE);
			
		} catch(Exception e) {sample_size=1000;}
		
		if (sample_size<1) sample_size=1; else if (sample_size>1000) sample_size=1000;
		
		
		mylog("Sample size set to : "+sample_size);
		
		//-----------------------------------------------------------------------------------------------------

		
		DYNAMIC_CLIENT_IDDLE_TIMEOUT=120000;
		sql="select param_value from tdm_parameters where param_name='DYNAMIC_CLIENT_IDDLE_TIMEOUT'";
		
		String tmp_DYNAMIC_CLIENT_IDDLE_TIMEOUT="";
		try {
			tmp_DYNAMIC_CLIENT_IDDLE_TIMEOUT=ddmLib.getDbArray(connConf, sql, 1, null, 0).get(0)[0].trim(); 
			DYNAMIC_CLIENT_IDDLE_TIMEOUT=Integer.parseInt(tmp_DYNAMIC_CLIENT_IDDLE_TIMEOUT);
			
		} catch(Exception e) {DYNAMIC_CLIENT_IDDLE_TIMEOUT=120000;}
		
		if (DYNAMIC_CLIENT_IDDLE_TIMEOUT<60000) DYNAMIC_CLIENT_IDDLE_TIMEOUT=60000;
		else if (DYNAMIC_CLIENT_IDDLE_TIMEOUT>600000) DYNAMIC_CLIENT_IDDLE_TIMEOUT=600000;
		
		mylog("DYNAMIC_CLIENT_IDDLE_TIMEOUT set to : "+DYNAMIC_CLIENT_IDDLE_TIMEOUT);
		//-----------------------------------------------------------------------------------------------------
		
		sql="select param_value from tdm_parameters where param_name='DDM_CONFIGURATION_RELOAD_INTERVAL'";
		
		String tmp_DDM_CONFIGURATION_RELOAD_INTERVAL="";
		try {
			tmp_DDM_CONFIGURATION_RELOAD_INTERVAL=ddmLib.getDbArray(connConf, sql, 1, null, 0).get(0)[0].trim(); 
			DDM_CONFIGURATION_RELOAD_INTERVAL=Integer.parseInt(tmp_DDM_CONFIGURATION_RELOAD_INTERVAL)*60*1000;
			
		} catch(Exception e) {DYNAMIC_CLIENT_IDDLE_TIMEOUT=60*60*1000;}
		
		if (DDM_CONFIGURATION_RELOAD_INTERVAL<0) DDM_CONFIGURATION_RELOAD_INTERVAL=0;
		else if (DDM_CONFIGURATION_RELOAD_INTERVAL>720000) DDM_CONFIGURATION_RELOAD_INTERVAL=720000;
		
		mylog("DDM_CONFIGURATION_RELOAD_INTERVAL set to : "+DDM_CONFIGURATION_RELOAD_INTERVAL);
		//-----------------------------------------------------------------------------------------------------

		sql="select param_value from tdm_parameters where param_name='JAVAX_EMAIL_USERNAME'";
		try {JAVAX_EMAIL_USERNAME=ddmLib.getDbArray(connConf, sql, 1, null, 0).get(0)[0].trim();} catch(Exception e) {JAVAX_EMAIL_USERNAME="";}
		
		sql="select param_value from tdm_parameters where param_name='JAVAX_EMAIL_PASSWORD'";
		try {JAVAX_EMAIL_PASSWORD=ddmLib.getDbArray(connConf, sql, 1, null, 0).get(0)[0].trim();} catch(Exception e) {JAVAX_EMAIL_PASSWORD="";}
		
		sql="select param_value from tdm_parameters where param_name='JAVAX_EMAIL_PROPERTIES'";
		try {JAVAX_EMAIL_PROPERTIES=ddmLib.getDbArray(connConf, sql, 1, null, 0).get(0)[0].trim();} catch(Exception e) {JAVAX_EMAIL_PROPERTIES="";}

		//-----------------------------------------------------------------------------------------------------
		

		DDM_CALENDAR_ID=0;
		sql="select param_value from tdm_parameters where param_name='DDM_CALENDAR_ID'";
		
		String tmp_DDM_CALENDAR_ID="";
		try {
			tmp_DDM_CALENDAR_ID=ddmLib.getDbArray(connConf, sql, 1, null, 0).get(0)[0].trim(); 
			DDM_CALENDAR_ID=Integer.parseInt(tmp_DDM_CALENDAR_ID);
			
		} catch(Exception e) {DDM_CALENDAR_ID=0;}
		
		mylog("DDM_CALENDAR_ID set to : "+DDM_CALENDAR_ID);
		//-----------------------------------------------------------------------------------------------------


		DDM_SESSION_VALIDATION_ID=0;
		sql="select param_value from tdm_parameters where param_name='DDM_SESSION_VALIDATION_ID'";
		
		String tmp_DDM_SESSION_VALIDATION_ID="";
		try {
			tmp_DDM_SESSION_VALIDATION_ID=ddmLib.getDbArray(connConf, sql, 1, null, 0).get(0)[0].trim(); 
			DDM_SESSION_VALIDATION_ID=Integer.parseInt(tmp_DDM_SESSION_VALIDATION_ID);
			
		} catch(Exception e) {DDM_SESSION_VALIDATION_ID=0;}
		
		mylog("DDM_SESSION_VALIDATION_ID set to : "+DDM_SESSION_VALIDATION_ID);
		//-----------------------------------------------------------------------------------------------------
		
		DDM_LOG_STATEMENT=false;
		sql="select param_value from tdm_parameters where param_name='DDM_LOG_STATEMENT'";
		
		String tmp_DDM_LOG_STATEMENT="";
		try {
			tmp_DDM_LOG_STATEMENT=ddmLib.getDbArray(connConf, sql, 1, null, 0).get(0)[0].trim(); 
			DDM_LOG_STATEMENT=tmp_DDM_LOG_STATEMENT.equalsIgnoreCase("YES");
			
		} catch(Exception e) {}
		
		mylog("log_statement set to : "+DDM_LOG_STATEMENT);
		
		

		
		//-----------------------------------------------------------------------------------------------------
		sql="select check_field, check_rule, check_parameter, case_sensitive, env_id  from tdm_proxy_log_exception where valid='YES' and app_id=? ";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+target_app_id});
		
		sqlLoggingExceptionRules=ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
		
		for (int i=0;i<sqlLoggingExceptionRules.size();i++) {
			String check_parameter=sqlLoggingExceptionRules.get(i)[2];
			String check_parameter_db_id=sqlLoggingExceptionRules.get(i)[4];
			
			if (check_parameter.trim().toLowerCase().contains("select") && check_parameter.trim().toLowerCase().contains("from")) {
				
				check_parameter=getValuesFromDb(connConf, check_parameter_db_id, check_parameter);
				
				String[] arr=sqlLoggingExceptionRules.get(i);
				arr[2]=check_parameter;
				sqlLoggingExceptionRules.set(i, arr);
			}
		}
		
		
		mylog("sqlLoggingExceptionRules loaded. "+sqlLoggingExceptionRules.size()+" rules found.");
		
		//-----------------------------------------------------------------------------------------------------
		sql="select check_field, check_rule, check_parameter, new_command, case_sensitive, env_id   from tdm_proxy_statement_exception where valid='YES' and app_id=? ";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+target_app_id});
		
		sqlStatementExceptionRules=ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
		
		
		for (int i=0;i<sqlStatementExceptionRules.size();i++) {
			String check_parameter=sqlStatementExceptionRules.get(i)[2];
			String check_parameter_db_id=sqlStatementExceptionRules.get(i)[5];
			
			if (check_parameter.trim().toLowerCase().contains("select") && check_parameter.trim().toLowerCase().contains("from")) {
				
				check_parameter=getValuesFromDb(connConf, check_parameter_db_id, check_parameter);
				
				String[] arr=sqlStatementExceptionRules.get(i);
				arr[2]=check_parameter;
				sqlStatementExceptionRules.set(i, arr);
			}
		}
		
		
		mylog("sqlStatementExceptionRules loaded. "+sqlStatementExceptionRules.size()+" rules found.");
		
		//-----------------------------------------------------------------------------------------------------
		
		sql="select id, policy_group_name, check_field, check_rule, "+
				" check_parameter, case_sensitive, record_limit, start_debuging, env_id "+
				" from tdm_proxy_policy_group where valid='YES' ";
		bindlist.clear();
		ArrayList<String[]> policyGrpArr=ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
		
		for (int i=0;i<policyGrpArr.size();i++) {
			String check_parameter=policyGrpArr.get(i)[4];
			String check_parameter_db_id=policyGrpArr.get(i)[8];
			
			if (check_parameter.trim().toLowerCase().startsWith("select") && check_parameter.trim().toLowerCase().contains("from")) {
				
				
				check_parameter=getValuesFromDb(connConf, check_parameter_db_id, check_parameter);
				
				mydebug("replacing parameters with : "+check_parameter);
				
				String[] arr=policyGrpArr.get(i);
				arr[4]=check_parameter;
				policyGrpArr.set(i, arr);
			}
		}
		
		
		hmNew.put("POLICY_GROUPS", policyGrpArr);
		
		
		//-----------------------------------------------------------------------------------------------------
		
		sql="select policy_group_id, sql_logging, iddle_timeout, deny_connection, calendar_id, session_validation_id from tdm_proxy_param_override where app_id=? and valid='YES' order by id ";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+target_app_id});
		
		ArrayList<String[]> overridingParamArr=ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
		
		hmNew.put("OVERRIDING_PARAMS", overridingParamArr);
		
		
		loadCalendarException(hmNew,DDM_CALENDAR_ID);
		loadSessionValidation(hmNew,DDM_SESSION_VALIDATION_ID);
		
		//-----------------------------------------------------------------------------------------------------
		for (int i=0;i<overridingParamArr.size();i++) {
			String policy_group_id=overridingParamArr.get(i)[0];
			String calendar_id=overridingParamArr.get(i)[4];
			String session_validation_id=overridingParamArr.get(i)[5];
			
			int calendar_id_INT=0;
			try{calendar_id_INT=Integer.parseInt(calendar_id);} catch(Exception e) {}
			
			loadCalendarException(hmNew,calendar_id_INT);
			
			int session_validation_id_INT=0;
			try{session_validation_id_INT=Integer.parseInt(session_validation_id);} catch(Exception e) {}
			
			
			loadSessionValidation(hmNew,session_validation_id_INT);
		}
		
		
		
		//-----------------------------------------------------------------------------------------------------
		
		sql="select concat('APP_EXCEPTION_FOR_PLC_',policy_group_id) plc_key, null related_tab \n"+
				"	from tdm_proxy_exception  \n"+
				"	where exception_scope='APPLICATION' and exception_obj_id=? \n"+
				"		union all  \n"+
				"	select concat('RULE_EXCEPTION_',r.id,'_FOR_PLC_',policy_group_id) plc_key, null related_tab  \n"+
				"	from tdm_proxy_exception ex, tdm_proxy_rules  r \n"+
				"	where r.app_id=? and exception_scope='RULE' \n"+
				"	and exception_obj_id=r.id \n"+
				"		union all \n"+
				"	select concat('TABLE_EXCEPTION_',t.schema_name,'.',t.tab_name,'_FOR_PLC_',policy_group_id) plc_key, concat(t.cat_name,'.',t.schema_name,'.',t.tab_name) related_tab  \n"+
				"	from tdm_proxy_exception ex, tdm_tabs  t \n"+
				"	where t.app_id=? and exception_scope='TABLE' \n"+
				"	and exception_obj_id=t.id \n"+
				"		union all \n"+
				"	select concat('COLUMN_EXCEPTION_',t.schema_name,'.',t.tab_name,'.',f.field_name,'_FOR_PLC_',policy_group_id) plc_key, concat(t.cat_name,'.',t.schema_name,'.',t.tab_name) related_tab  \n"+
				"	from tdm_proxy_exception ex, tdm_tabs  t, tdm_fields f \n"+
				"	where t.app_id=? and t.id=f.tab_id and exception_scope='COLUMN' \n"+
				"	and exception_obj_id=f.id \n"+	
				"	";
		
		
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+target_app_id});
		bindlist.add(new String[]{"INTEGER",""+target_app_id});
		bindlist.add(new String[]{"INTEGER",""+target_app_id});
		bindlist.add(new String[]{"INTEGER",""+target_app_id});
		
		ArrayList<String[]> exceptionArr=ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
		for (int i=0;i<exceptionArr.size();i++) {
			
			String exception_key=exceptionArr.get(i)[0];
			String related_tab=exceptionArr.get(i)[1].replace("${default}.", "");
			
			mylog("Adding Exception  "+exception_key+" with related_tab="+related_tab);

			hmNew.put(exception_key, true);
			
			if (exception_key.startsWith("COLUMN_EXCEPTION_") && related_tab.length()>0) 
				hmNew.put("HAS_COLUMN_EXCEPTION_"+related_tab, true);
			else if (exception_key.startsWith("TABLE_EXCEPTION_") && related_tab.length()>0) 
				hmNew.put("HAS_TABLE_EXCEPTION_"+related_tab, true);
		}
		
		
		//-----------------------------------------------------------------------------------------------------
		
		
		sql="select "+
				" id, "+
				" rule_id, "+
				" hide_char, hide_after, " +
				" fixed_val, " + 
				" random_range, js_code  "+
				" from tdm_mask_prof " +
				" where valid='YES' "+
				" and rule_id in ('HIDE','FIXED','RANDOM_NUMBER','RANDOM_STRING','SETNULL','ENCAPSULATE','NOCOL') ";
		bindlist.clear();
		ArrayList<String[]> maskProfArr=ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
		
	
		
		
		
		for (int i=0;i<maskProfArr.size();i++) {
			String mask_prof_id=maskProfArr.get(i)[0];
			String mask_rule_id=maskProfArr.get(i)[1];
			String mask_hide_char=maskProfArr.get(i)[2];
			String mask_hide_after=maskProfArr.get(i)[3];
			String fixed_val=maskProfArr.get(i)[4];
			String random_range=maskProfArr.get(i)[5];
			String js_code=maskProfArr.get(i)[6];
			
			String par1="";
			String par2="";
			
			
			if (mask_rule_id.equals("FIXED")) 
				par1=fixed_val;
			else if (mask_rule_id.equals("ENCAPSULATE")) 
				par1=js_code;
			else if (mask_rule_id.equals("HIDE")) {
				par1=mask_hide_char;
				par2=mask_hide_after;
			}
			else if (mask_rule_id.equals("RANDOM_NUMBER") || mask_rule_id.equals("RANDOM_STRING")) {
				String[] betweenArr=random_range.split(",");
				
				
				try {par1=betweenArr[0].trim();} catch(Exception e) {};
				try {par2=betweenArr[1].trim();} catch(Exception e) {};
				
				
			} 
			else if (mask_rule_id.equals("SETNULL")) {
				//nothing to do
			}
			else if (mask_rule_id.equals("NOCOL")) {
				//nothing to do
			}
			
			hmNew.put("MASK_PROF_RULE_TYPE_"+mask_prof_id, mask_rule_id);
			hmNew.put("MASK_PROF_PAR_1_"+mask_prof_id, par1);
			hmNew.put("MASK_PROF_PAR_2_"+mask_prof_id, par2);
		}
		
		
		//-----------------------------------------------------------------------------------------------------
		sql="select id, rule_scope, rule_type, rule_parameter1, min_match_rate, mask_prof_id, env_id " + 
					" from tdm_proxy_rules " +
					" where app_id=? and valid='YES' order by rule_order";
		
		bindlist.clear();
		
		bindlist.add(new String[]{"INTEGER",""+target_app_id});
		ArrayList<String[]> ruleArr=ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
		
		
		ArrayList<String[]> sampleMaskingProfilesTemp=new ArrayList<String[]>();
		
		for (int r=0;r<ruleArr.size();r++) {
			
			String rule_id=ruleArr.get(r)[0];
			String rule_scope=ruleArr.get(r)[1];
			String rule_type=ruleArr.get(r)[2];
			String rule_parameter1=ruleArr.get(r)[3];
			String min_match_rate=ruleArr.get(r)[4];
			String mask_prof_id=ruleArr.get(r)[5];
			String env_id=ruleArr.get(r)[6];
			
			String masking_function=ddmLib.getMaskingFunction(hmNew, mask_prof_id);
			
			mylog(" Adding Sample Masking Profile ["+rule_id+" scope :"+rule_scope+"] : " + rule_type + " by "+ rule_parameter1 + " mask with " + masking_function);
			
			if (rule_type.equals("IN") || rule_type.equals("CONTAINS_ANY")) 
				setCheckListMappings(hmNew, rule_id, rule_type, rule_parameter1, env_id);
			
			
			sampleMaskingProfilesTemp.add(new String[]{
					rule_id,
					rule_scope,
					rule_type,		
					rule_parameter1,		
					min_match_rate,	
					masking_function,
					});
			
			
			
		}
		
		

		hmNew.put("SAMPLE_MASKING_PROFILES", sampleMaskingProfilesTemp);
		

		
		
		//-----------------------------------------------------------------------------------------------------
		
		
		
		if (proxy_type.equals(PROXY_TYPE_MSSQL_T2))
			sql="select concat(cat_name, '.', schema_name, '.',tab_name, '.',field_name) col_to_mask, mask_prof_id, tab_filter  "+
					"   from tdm_fields f, tdm_tabs t, tdm_apps a " +
					"	where a.id=? and f.tab_id=t.id and t.app_id=a.id and f.mask_prof_id>0 ";
		else 
			sql="select concat(schema_name, '.',tab_name, '.',field_name) col_to_mask, mask_prof_id, tab_filter "+
					"   from tdm_fields f, tdm_tabs t, tdm_apps a " +
					"	where a.id=? and f.tab_id=t.id and t.app_id=a.id and f.mask_prof_id>0 ";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+target_app_id});
		
		ArrayList<String[]> colRulesArr=ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
		mylog("Column Masked  Found : "+colRulesArr.size());
		
		
		
		
		ArrayList<String[]> maskedTableListTemp=new ArrayList<String[]>();
		
		for (int i=0;i<colRulesArr.size();i++) {
			
			//String col_path=colRulesArr.get(i)[0].toUpperCase();
			String col_path=colRulesArr.get(i)[0];
			String mask_prof_id=colRulesArr.get(i)[1];
			String tab_filter=colRulesArr.get(i)[2];
			
			String masking_function=ddmLib.getMaskingFunction(hmNew, mask_prof_id);
			
			mylog("Setting column masking  function : " +col_path +" = " + masking_function);
			
			
			
			hmNew.put("MASK_METHOD_FOR_COLUMN_"+col_path, masking_function);
			
			
			
			if (proxy_type.equals(PROXY_TYPE_MSSQL_T2)) {
				
				String[] arr=col_path.split("\\.");
				
				String cat_name=arr[0];
				String schema_name=arr[1];
				String table_name=arr[2];
				
				String table_path="IS_TABLE_MASKED_"+cat_name+"."+schema_name+"."+table_name+"";
				
				if (!hmNew.containsKey(table_path)) {
					hmNew.put(table_path, true);
					
					maskedTableListTemp.add(new String[]{cat_name, schema_name,table_name});
					
					if (tab_filter.trim().length()>0) {
						hmNew.put("TAB_FILTER_FOR_"+ cat_name+"."+schema_name+"."+table_name,tab_filter);
						mydebug("Setting table filter for table ["+cat_name+"].["+schema_name+"].["+table_name+"] :"+ tab_filter);
					}
					
					mydebug("Setting table masking  flag : " +table_path +" =true");
				}
			}
			
			if (proxy_type.equals(PROXY_TYPE_ORACLE_T2)) {
				String[] arr=col_path.split("\\.");
				
				String schema_name=arr[0];
				String table_name=arr[1];
				
				String table_path="IS_TABLE_MASKED_"+schema_name+"."+table_name;
				
				if (!hmNew.containsKey(table_path)) {
					hmNew.put(table_path, true);
					
					maskedTableListTemp.add(new String[]{schema_name,table_name});
					
					if (tab_filter.trim().length()>0) {
						hmNew.put("TAB_FILTER_FOR_"+ schema_name+"."+table_name,tab_filter);
						mydebug("Setting table filter for table "+schema_name+"."+table_name+" :"+ tab_filter);
					}
						
					
					
					mydebug("Setting table masking  flag : " +table_path +" =true");
				}
			}
			
			
			if (proxy_type.equals(PROXY_TYPE_MONGODB)) {
				String[] arr=col_path.split("\\.");
				
				String db_name=arr[0];
				String collection=arr[1];
				
				String table_path="IS_TABLE_MASKED_"+db_name+"."+collection;
				
				if (!hmNew.containsKey(table_path)) {
					hmNew.put(table_path, true);
					mydebug("Setting table masking  flag : " +table_path +" =true");
				}
			}
		}
		
		
		
		//----------------------------------------------------------------------------------------------------
		// LOAD BLACK LISTED SESSIONS
		sql="select distinct machine, osuser, dbuser from tdm_proxy_monitoring_blacklist where proxy_id=? and is_deactivated='NO' order by blacklist_time desc";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		ArrayList<String[]> blackListArr=ddmLib.getDbArray(connConf, sql, 1000, bindlist, 0);
		for (int i=0;i<blackListArr.size();i++) {
			String[] arr=blackListArr.get(i);
			String machine=arr[0];
			String osuser=arr[1];
			String dbuser=arr[2];
			
			mydebug("Adding blacklist for : "+machine+","+osuser+","+dbuser+"...");
			hmNew.put("BLACKLIST_FOR_"+machine+"_"+osuser+"_"+dbuser, true);

		}
		
		
		//-----------------------------------------------------------------------------------------------------
		//ARCHIVE AND CLEAR MONITORING COLUMN LIST
		ddmLib.archiveMonitoringColumns(this, connConf, proxy_id);
		//-----------------------------------------------------------------------------------------------------
		
		monitoringPolicies.clear();
		monitoringColumnsArray.clear();
		monitoringExpressionsArray.clear();
		
		sql="select id, monitoring_interval, monitoring_period, monitoring_threashold, monitoring_email, monitoring_blacklist, monitoring_threashold_recv_bytes "+
				" from tdm_proxy_monitoring "+
				" where is_active='YES' "+
				" and id in (select monitoring_id from tdm_proxy_monitoring_application where app_id=? )";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+target_app_id});
		monitoringPolicies.addAll(ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0));
		
		
		for (int i=0;i<monitoringPolicies.size();i++) {
			String monitoring_id=monitoringPolicies.get(i)[0];
	
			sql="select monitoring_id, policy_group_id from tdm_proxy_monitoring_policy_group where monitoring_id=?";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",monitoring_id});
			ArrayList<String[]> listOfMonitoredPolicyGroups=new ArrayList<String[]>();
			listOfMonitoredPolicyGroups.addAll(ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0));
			
					
			for (int m=0;m<listOfMonitoredPolicyGroups.size();m++) {
				String[] arr=listOfMonitoredPolicyGroups.get(m);
				String policy_group_id=arr[1];
				
				hmNew.put("IS_POLICY_GROUP_MONITORED_"+policy_group_id, true);
			}
			
			sql="select monitoring_id, rule_catalog_name, rule_schema_name, rule_object_name, rule_column_name from tdm_proxy_monitoring_policy_rules where monitoring_id=? and rule_type='COLUMN' and is_active='YES'";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",monitoring_id});
			ArrayList<String[]> listOfMonitoredColumns=new ArrayList<String[]>();
			listOfMonitoredColumns.addAll(ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0));
			
			hmNew.put("MONITORING_COLUMNS_FOR_"+monitoring_id, listOfMonitoredColumns);
			
			for (int c=0;c<listOfMonitoredColumns.size();c++) {
				String[] arr=listOfMonitoredColumns.get(c);
				
				monitoring_id=arr[0];
				String catalog_name=genLib.nvl(arr[1],"${default}");
				String schema_name=arr[2];
				String object_name=arr[3];
				String column_name=arr[4];
							
				hmNew.put("IS_COLUMN_MONITORED_"+catalog_name+"."+schema_name+"."+object_name+"."+column_name, true);
			}
			
			sql="select monitoring_id, rule_expression from tdm_proxy_monitoring_policy_rules where monitoring_id=? and rule_type='EXPRESSION' and is_active='YES'";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",monitoring_id});
			ArrayList<String[]> listOfMonitoredExpressions=new ArrayList<String[]>();
			listOfMonitoredExpressions.addAll(ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0));
			
			hmNew.put("MONITORING_EXPRESSIONS_FOR_"+monitoring_id, listOfMonitoredExpressions);
			
		}
		
		

		
		
		
		//-----------------------------------------------------------------------------------------------------
		
		sql="update tdm_proxy set last_reload_time=now() where id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		ddmLib.execSingleUpdateSQL(connConf, sql, bindlist);
		
		mylog("Loading masking profiles. Done : "+(System.currentTimeMillis()-start_ts)+ " msecs");
		
		last_configuration_load_time=System.currentTimeMillis();
		
		
		
		ddmLib.setProxyActive(connConf, proxy_id);
		
		
		
		configuration_loading=true;
				
		hmConfig.clear();
		hmConfig.putAll(hmNew);
		
		
		saveLastConfiguration();
		
		hmCache.clear();
		
		last_configuration_load_ts=System.currentTimeMillis();
		
		configuration_loading=false;
		
		
		
	}
	
	//------------------------------------------------------------------------
	void loadCalendarException(ConcurrentHashMap hmNew, int calendar_id) {
		if (calendar_id==0) return;
		String java_fomat="dd.MM.yyyy HH:mm:ss";
		String mysql_format="%d.%m.%Y %H:%i:%s";

		String sql="select calendar_exception_name,  DATE_FORMAT(exception_start_time,?) exception_start_time, DATE_FORMAT(exception_end_time,?) exception_end_time "+
				" from tdm_proxy_calendar_exception "+
				" where calendar_id=? and exception_end_time>exception_start_time "+
				" order by 2";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"STRING",mysql_format});
		bindlist.add(new String[]{"STRING",mysql_format});
		bindlist.add(new String[]{"INTEGER",""+calendar_id});
		
		ArrayList<String[]> arr=ddmLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
		
		
		ArrayList<Date[]> calendarExceptionArr=new ArrayList<Date[]>();
		
		for (int i=0;i<arr.size();i++) {
			String calendar_exception_name=arr.get(i)[0];
			String exception_start_time=arr.get(i)[1];
			String exception_end_time=arr.get(i)[2];
			
			mylog("loading Calendar Exc:" +calendar_exception_name+"...");
			
			Date d1;
			Date d2;
			
			try {
				DateFormat df = new SimpleDateFormat(java_fomat);
				d1 = df.parse(exception_start_time);
			} catch(Exception e) {
				mylog("Exception@loadCalendarException : "+genLib.getStackTraceAsStringBuilder(e).toString());
				continue;
			}
			
			try {
				DateFormat df = new SimpleDateFormat(java_fomat);
				d2 = df.parse(exception_end_time);
			} catch(Exception e) {
				mylog("Exception@loadCalendarException : "+genLib.getStackTraceAsStringBuilder(e).toString());
				continue;
			}
			mylog("Adding : "+exception_start_time+" "+exception_end_time);
			calendarExceptionArr.add(new Date[]{d1,d2});
			
		}
		
		
		hmNew.put("CALENDAR_EXCEPTIONS_FOR_"+calendar_id, calendarExceptionArr);
		
		
		
	}
	
	static final int FLD_SESSION_VALIDATION_session_validation_name=0;
	static final int FLD_SESSION_VALIDATION_for_statement_check_regex=1;
	static final int FLD_SESSION_VALIDATION_check_start=2;
	static final int FLD_SESSION_VALIDATION_check_duration=3;
	static final int FLD_SESSION_VALIDATION_limit_session_duration=4;
	static final int FLD_SESSION_VALIDATION_max_attempt_count=5;
	static final int FLD_SESSION_VALIDATION_extraction_js_for_par1=6;
	static final int FLD_SESSION_VALIDATION_extraction_js_for_par2=7;
	static final int FLD_SESSION_VALIDATION_extraction_js_for_par3=8;
	static final int FLD_SESSION_VALIDATION_extraction_js_for_par4=9;
	static final int FLD_SESSION_VALIDATION_extraction_js_for_par5=10;
	static final int FLD_SESSION_VALIDATION_controll_method=11;
	static final int FLD_SESSION_VALIDATION_controll_statement=12;
	static final int FLD_SESSION_VALIDATION_controll_db_id=13;
	static final int FLD_SESSION_VALIDATION_expected_result=14;
	static final int FLD_SESSION_VALIDATION_validate_identical_sessions=15;
	

	//------------------------------------------------------------------------
	void loadSessionValidation(ConcurrentHashMap hmNew, int session_validation_id) {
		if (session_validation_id==0) return;

		String sql="select "+
				" session_validation_name, "+
				" for_statement_check_regex,"+
				" check_start, "+
				" check_duration, "+
				" limit_session_duration, "+
				" max_attempt_count, "+
				" extraction_js_for_par1, extraction_js_for_par2, extraction_js_for_par3, extraction_js_for_par4, extraction_js_for_par5, "+ 
				" controll_method, controll_statement, controll_db_id, expected_result, validate_identical_sessions "+
				" from tdm_proxy_session_validation "+
				" where id=?";
				
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+session_validation_id});
		
		ArrayList<String[]> arr=ddmLib.getDbArray(connConf, sql, 1, bindlist, 0);
		
		if (arr==null || arr.size()==0) return;
		
		hmNew.put("SESSION_VALIDATION_"+session_validation_id, arr.get(0));
		
	}
	

	//------------------------------------------------------------------------
	ThreadGroup subThreadGroup = new ThreadGroup("Long HeartBeat Thread Group");
	
	void startLongHeartBeatThread() {
		String thread_name="DM_HEARTBEAT_THREAD";
		try {
			Thread thread=new Thread(subThreadGroup, 
					new heartbeatForDDMThread(this, proxy_id),thread_name);
			thread.start();
		} catch(Exception e) {
			
			e.printStackTrace();
		}
		
	}
	//********************************************************

	void startConfigurationListenerThread() {
		String thread_name="DM_CONF_LISTENER_THREAD";
		try {
			Thread thread=new Thread(subThreadGroup, 
					new clientStatusCheckerWriterThread(this, proxy_id),thread_name);
			thread.start();
		} catch(Exception e) {
			
			e.printStackTrace();
		}
		
	}
	
	//----------------------------------------------------------------------------
	int PERSIST_PROXY_EVENT_WRITE_INTERVAL=5000;
	long next_proxy_event_write_ts=0;
	
	void startProxyEventWriterThread(ArrayList<String[]> eventArr) {

		
		if (eventArr==null || eventArr.size()==0) return;
		
		//mydebug("starting startProxyEventWriterThread for "+eventArr.size()+" events.");
		
		
		try {
			Thread thread=new Thread(new proxyEventWriterThread(this, proxy_id, eventArr));
			thread.start();
			next_proxy_event_write_ts=System.currentTimeMillis()+PERSIST_PROXY_EVENT_WRITE_INTERVAL;
			
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		
	}
	//----------------------------------------------------------------------------
	void startProxyMonitoringThread() {
		String thread_name="DM_MONITORING_THREAD";
		try {
			Thread thread=new Thread(subThreadGroup, 
					new proxyMonitoringThread(this, proxy_id),thread_name);
			thread.start();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	
	//----------------------------------------------------------------------------
	void startProxyMonitoringEmailThread() {
		String thread_name="DM_MONITORING_EMAIL_THREAD";
		try {
			Thread thread=new Thread(subThreadGroup, 
					new proxyMonitoringEmailThread(this, proxy_id),thread_name);
			thread.start();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	

	
	//********************************************************
	public void initNewProxy(
			int proxy_id,
			String proxy_type, 
			String secure_client,
			String secure_public_key,
			String m_port, 
			String server_host, 
			int server_port, 
			String proxy_encoding,
			int target_app_id,
			int target_env_id,
			int max_package_size,
			String conf_db_driver,
			String conf_db_url,
			String conf_db_username,
			String conf_db_password,
			boolean is_debug,
			String proxy_extra_args
			) {
		this.proxy_id=proxy_id;
		this.port=m_port;
		this.server_host=server_host;
		this.server_port=server_port;
		this.proxy_type=proxy_type;
		
		this.proxy_encoding=proxy_encoding.trim();
		this.target_app_id=target_app_id;
		this.target_env_id=target_env_id;
		
		this.conf_db_driver=conf_db_driver;
		this.conf_db_url=conf_db_url;
		this.conf_db_username=conf_db_username;
		this.conf_db_password=conf_db_password;
		
		
		this.secure_client=secure_client;
		this.secure_public_key=secure_public_key;
		
		is_secure_client=false;
		
		if (this.secure_client.equals("YES")) {
			int key_len=secure_public_key.getBytes().length;
			
			if (key_len!=16) {
				mylog("Secure key byte length should be 16. Actual value is : "+key_len);
				is_secure_client=false;
				
			} else {
				public_key_byte_arr=secure_public_key.getBytes();
				is_secure_client=true;
			}
		} else {
			mydebug("secure_client=NO");
		}
		
		
		
		mylog("Setting is_secure_client="+is_secure_client);
		
		db_functions=db_functions_GENERAL;
		
		if (proxy_type.equals(PROXY_TYPE_MYSQL)) db_functions=db_functions+" "+db_functions_MYSQL;
		
		this.MAX_PACKAGE_SIZE=max_package_size;
		
		this.connConf=getDBConnection(conf_db_url, conf_db_driver,conf_db_username,conf_db_password,1);
		
		if (connConf==null) {
			mylog("Configuration connection is not established.");
			System.exit(0);
		}
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+target_env_id});
		String sql="select db_driver, db_connstr, db_username, db_password from tdm_envs where id=?";
		
		ArrayList<String[]> arr=ddmLib.getDbArray(connConf, sql, 1, bindlist, 10);
		
		if (arr==null || arr.size()==0) {
			mylog("Target db configuration is not found.");
			System.exit(0);
		}
		
		target_db_driver_name=arr.get(0)[0];
		target_db_url=arr.get(0)[1];
		target_db_username=arr.get(0)[2];
		target_db_password=genLib.passwordDecoder(arr.get(0)[3])  ;
	
			
		
		this.is_debug=is_debug;
		this.proxy_extra_args=proxy_extra_args;
		
		ddmLib.abortOldSessions(this);
		
		
		startLongHeartBeatThread();
		
		startConfigurationListenerThread();
		
		startProxyMonitoringThread();
		startProxyMonitoringEmailThread();
		
		
		ArrayList<Integer> portArr=new ArrayList<Integer>();
		
		String[] ports=port.split(",");
		
		for (int p=0;p<ports.length;p++) {
			String a_port=ports[p].trim();
			try {
				int port_n=Integer.parseInt(a_port);
				if (port_n<1) continue;
				if (port_n>65535) continue;
				portArr.add(port_n);
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		
		
		//----------------------------------------------------------------
		if (portArr.size()==0) {
			mylog("No valid listening port specified. breaking..");
			
		}
		else {
			
			
			for (int p=0;p<portArr.size();p++) {
				boolean is_started=startNewProxyListenerThread(this,portArr.get(p));
				if (is_started) active_listener_count++;
			}
			
			if (active_listener_count==0) {
				mylog("No proxy listener started. breaking..");
				
			}
			else {
				//ddmLib.setProxyActive(connConf, proxy_id);
				
				
				
				while(true) {
					try{Thread.sleep(5000);} catch(Exception e) {}
					if (is_proxy_cancelled) break;		
					//mylog("Active client thread count : "+clientThreadGroup.activeCount()+", heap rate : "+heapUsedRate()+"%, "+heapUsedAsMByte()+" Mbytes, log size: "+proxyEventArray.size());
				}
				
			}
				
			
		} //if (portArr.size()==0)
		
		
		
		flushLogs(true);
		
		
		mylog("Persisting all logs to database. Be patient...");
		persistProxyEvents(connConf,  proxyEventArray, this, proxy_id, true);
		mylog("Done...");
		
		mylog("Aborting all sessions. Be patient...");
		ddmLib.abortOldSessions(this);
		mylog("Done...");
		
		mylog("Bye From Proxy...");
		
		System.exit(0);
		

	}
	//******************************************
	ThreadGroup proxyListenerThreadGroup = new ThreadGroup("Proxy Listener Thread Group");
	
	boolean startNewProxyListenerThread(ddmProxyServer dm, int port_num) {
		String thread_name="PROXY_LISTENER_PORT_"+port_num;
		
		
		int thread_count=proxyListenerThreadGroup.activeCount();
		
		try {
			Thread thread=new Thread(proxyListenerThreadGroup, new proxyListenerThread(this, port_num),thread_name);
			thread.start();
		} catch(Exception e) {
			e.printStackTrace();
			return false;
		}
	
		long start_ts=System.currentTimeMillis();
		
		while(true) {
			
			try{Thread.sleep(100);} catch(Exception e) {}
			
			
			int thread_count2=proxyListenerThreadGroup.activeCount();
			if (thread_count2>thread_count) return true;
			
			if (System.currentTimeMillis()-start_ts>5000) {
				return false;
			}
		}
		
	
	}
	
	// *****************************************
	public Connection getDBConnection(String ConnStr, String Driver, String User, String Pass, int retry_count) {
		
		Connection ret1 = null;
		
		
		mylog("Connecting to : ");
		mylog("driver     :["+Driver+"]");
		mylog("connstr    :["+ConnStr+"]");
		mylog("user       :["+User+"]");
		mylog("pass       :["+"************]");	




		int retry=0;
		while (true) {
			if (retry>retry_count) break;
			retry++;
			try {
				Class.forName(Driver.replace("*",""));
				Connection conn = DriverManager.getConnection(ConnStr, User, Pass);
				
			
				boolean is_connection_valid=true;
				
				//try{ conn.isValid(60); } catch(Exception e) {is_connection_valid=true;}
				if (is_connection_valid) {
					ret1 = conn;
					break;
				}
					
				
	
			} catch (Exception ignore) {
				mylog("Exception@getconn : " + ignore.getMessage());
				ignore.printStackTrace();
				ret1=null;
				mylog("sleeping ...");
				
				try{Thread.sleep(5000);} catch(Exception e) {}
			}
			
			mylog("Connection is failed to db : retry("+retry+") ");
			mylog("driver     :"+Driver);
			mylog("connstr    :"+ConnStr);
			mylog("user       :"+User);
			mylog("pass       :"+"************");
			mylog("Sleeping...");
			
			
			
		}
		
		return ret1;
	}
	
	
	
	
	
	//----------------------------------------------------------------
	void mylog(String logstr) {
		mylogNLF(logstr);
		mylogNLF("\n");
	}
	
	//----------------------------------------------------------------
	void mydebug(String logstr) {
		if (!is_debug) return;
		mylogNLF(logstr);
		mylogNLF("\n");
	}
	
	//----------------------------------------------------------------
	void mylogNLF(String logstr) {
		System.out.print(logstr);
	}
	

	//----------------------------------------------------------------
	 
	 ArrayList<StringBuilder> logArray=new ArrayList<StringBuilder>();
	 int log_index=0;
	 static int MAX_LOG_COUNT=10000;
	 boolean filled_once=false;
	 
	 synchronized void addNewLog(StringBuilder newlog) {
	
		 if (filled_once) 
			try {logArray.set(log_index, new StringBuilder(newlog)  );} catch(Exception e) {}
		 else 
			try { logArray.add(new StringBuilder(newlog));} catch(Exception e) {}
		 
		 log_index++;
		 if (log_index>1000)  {
			 
			 flushLogs(true);
			 filled_once=true;
			 log_index=0;
		 }
	 }
	 
	//--------------------------------------------------------------------
	 
	long last_log_flush_ts=0;
	static final int LOG_FLUSH_INTERVAL=1000;
	
	synchronized void flushLogs(boolean force) {
		
		if (System.currentTimeMillis()<last_log_flush_ts+LOG_FLUSH_INTERVAL && !force) return;
		
		try {
			for (int i=0;i<logArray.size();i++) {
				if (logArray.get(i)==null) continue;
				System.out.print(logArray.get(i));
				logArray.set(i, null);
			}
		} catch(Exception e) {}
		
		last_log_flush_ts=System.currentTimeMillis();
	}
	 
	
	
	
	
	
	
	
	
	
	 
	int FROM_CLIENT=1;
	int FROM_SERVER=2;
	
	

	
	ArrayList<Integer> methodsToUse=new ArrayList<Integer>();

	static final String PACKAGE_LOG_PHASE_BEFORE="BEFORE";
	static final String PACKAGE_LOG_PHASE_AFTER="AFTER";
	
	

	
	//------------------------------------------------------
	int checkPackage(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin, 
			DataInputStream from_server_stream,
			DataOutputStream to_server_stream,
			DataInputStream from_client_stream,
			DataOutputStream to_client_stream
			) {
		
		
		
		//if configuration is loading, wait till load finished
		if (configuration_loading && origin==FROM_CLIENT) 
			while(configuration_loading) try{Thread.sleep(10);} catch(Exception e) {}
		
		
		
		if(packageObj.temporary_exception_flag ) {
			packageObj.mydebug("temprary_exception_flag set");
			return len;
		}
		else if(packageObj.user_exception_flag ) {
			packageObj.mydebug("user_exception_flag set");
			return len;
					
		}
		else if(packageObj.calendar_exception_flag ) {
			packageObj.mydebug("calendar_exception_flag set");
			return len;
					
		}
		else  if (System.currentTimeMillis()<(packageObj.client_start_ts+packageObj.GEN_PAR_Masking_Skip_Time)) {
			packageObj.mydebug("in GEN_PAR_Masking_Skip_Time");
			return len;	
		}
		
		
		if (is_debug || packageObj.is_tracing) {
			
			if (origin==FROM_CLIENT) packageObj.mylogNLF("**** CLIENT ["+len+"]\t");			
			else packageObj.mylogNLF("**** SERVER ["+len+"]\t");
			
			boolean truncated=false;
			int target=len;
			if (len>16348) {
				target=16348;
				truncated=true;
			}
			
			for (int i=0;i<target;i++){
				if (ddmLib.visible_chars.indexOf(buf[i])>-1)
					packageObj.mylogNLF(new String(buf,i,1));
				else 
					packageObj.mylogNLF("["+( ddmLib.byte2UnsignedInt(buf[i]) )+"]");
			}
			if(truncated) packageObj.mylogNLF("...[?truncated?]");
			
			packageObj.mylog("\n");
		}
		
		int ret1=len;
		
		if (origin==FROM_SERVER && packageObj.save_received_bytes) packageObj.bytes_received_buffer+=Math.abs(len);
		
		switch (proxy_type) {
			
			
			case PROXY_TYPE_ORACLE_T2: {
				ret1=checkPackageORACLE(packageObj, buf,len,origin,to_server_stream,to_client_stream);
				break;
			}
			
			
			case PROXY_TYPE_MSSQL_T2: {
				ret1=checkPackageMicrosoftSQL(packageObj, buf,len,origin,to_server_stream,to_client_stream);
				break;
			}
			case PROXY_TYPE_POSTGRESQL: {
				ret1=checkPackagePOSTGRESQL(packageObj, buf,len,origin,to_server_stream,to_client_stream);
				break;
			}
			case PROXY_TYPE_MONGODB: {
				ret1=checkPackageMONGODB(packageObj, buf,len,origin,to_server_stream,to_client_stream);
				break;
			}

			case PROXY_TYPE_HIVE: {
				ret1=checkPackageHIVE(packageObj, buf,len,origin,to_server_stream,to_client_stream);
				break;
			}
			case PROXY_TYPE_GENERIC: {
				ret1=checkPackageGeneric(packageObj, buf,len,origin,to_server_stream,to_client_stream);
				break;
			}
			
			case PROXY_TYPE_MYSQL: {
				ret1=checkPackageMySQL(packageObj, buf,len,origin,to_server_stream,to_client_stream);
				break;
			}
			
			default: ret1=len;
		}
		
		if (origin==FROM_CLIENT) {
			if (force_configuration_load)  loadConfiguration();
		}
		 
		
		
			
		
		
		
		return ret1;
		
	}
	
	
	
	
	
	
	
	
	
	
	//**************************************************
	int checkPackageORACLE(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin, 
			DataOutputStream to_server_stream,
			DataOutputStream to_client_stream) {
		
		
		if (origin==FROM_CLIENT) 
			return checkPackageORACLE_CLIENT(
					packageObj, 
					buf, 
					len, 
					origin,
					to_server_stream
					);
		else 
			return checkPackageORACLE_SERVER(
					packageObj, 
					buf, 
					len, 
					origin,
					to_client_stream
					);
		
	}
	
	//---------------------------------------------------------------------
	String getExtraArgumentParameter(String parameter_name) {
		String[] lines=proxy_extra_args.split("\n|\r");
		
		for (int i=0;i<lines.length;i++) {
			String a_line=lines[i];
			if (a_line.length()==0) continue;
						
			int pos=a_line.indexOf("=");
						
			if (pos<=0) continue;
			
			String p_name=a_line.substring(0,pos).trim();

			if (!p_name.equalsIgnoreCase(parameter_name)) continue;
			
			String param_val="";
			
			try {param_val=a_line.substring(pos+1);} catch(Exception e) {}
			
			return param_val;
			
		}
		
		
		return "";
	}
	
	//---------------------------------------------------------------------
	boolean  changeLoginParametersORACLE(
				ddmClient packageObj,
				byte[] buf, 
				int len, 
				DataOutputStream to_server_stream
			) {
		
		packageObj.mydebug("changeLoginParametersORACLE");
		packageObj.printByteArray(buf, len);
		
		if (buf[10]!=(byte) 3) {
			packageObj.mydebug("Not a login handshake package."); 
			return false;
		}
		
			
			
		if (buf[11]!=(byte) 's' && buf[11]!=(byte) 'v' ) {
			packageObj.mydebug("Not a login handshake package."); 
			return false;
		}
		
		if (packageObj.session_proxy_client_name.length()==0) 
			packageObj.session_proxy_client_name=ddmLib.extractOracleProxyClientName(packageObj,buf, len);
		
		
		String searchParameters=getExtraArgumentParameter("LOGIN_CHANGE_PARAMETER_NAME");
		String replaceFormula=getExtraArgumentParameter("LOGIN_CHANGE_REPLACE_FORMULA");
		
		
		//searchParameters="AUTH_MACHINE,AUTH_TERMINAL";
		//replaceFormula="APPEND:!!!"; //APPEND:!!! 	INSERT:!!!	CHANGETO:TDMMASK 

		packageObj.mydebug("changeLoginParametersORACLE searchParameters : ["+searchParameters+"]");
		packageObj.mydebug("changeLoginParametersORACLE replaceFormula   : ["+replaceFormula+"]");
		
		
		String[] arrSearch=searchParameters.split(",");
		String[] arrFormula=replaceFormula.split(",");
		
		byte[] bufNew=new byte[len];
		System.arraycopy(buf, 0, bufNew, 0, len);
		
		int pos_package_len=0;
		if (bufNew[0]==(byte) 0 && bufNew[1]==(byte) 0) pos_package_len=2;
		packageObj.mydebug("changeLoginParametersORACLE pos_package_len : "+pos_package_len);
		
		boolean is_changed=false;
		
		
		int protocol_characteristic=packageObj.oracle_protocol_characteristic;
		
		byte[] byte_test="AUTH_TERMINAL".getBytes();
		int pos_test=ddmLib.IndexOfByteArray(bufNew, 0, len, byte_test);
		if (bufNew[pos_test-2]==0) 
			protocol_characteristic=-14834;
		else 
			protocol_characteristic=20120;
		
		
		
		for (int a=0;a<arrSearch.length;a++) {
			
			try {
				
				
				String searchStr=arrSearch[a].trim();
				if (searchStr.length()<3) continue;
				
				packageObj.mydebug("changeLoginParametersORACLE for parameter : ["+searchStr+"]");
				
				String aFormula="CHANGETO:TDM";
				String changeFormulaMethod="CHANGETO";
				String changeFormulaParameter="INFOBOX_DDM";
				
				
				try{aFormula=arrFormula[a].trim();} catch(Exception e) {aFormula=arrFormula[0].trim();}
				
				try {changeFormulaMethod=aFormula.split("\\+")[0].trim();} catch(Exception e) {changeFormulaMethod="CHANGETO";}
				try {changeFormulaParameter=aFormula.split("\\+")[1].trim();} catch(Exception e) {changeFormulaParameter="INFOBOX_DDM";}
				
				if (changeFormulaParameter.length()==0) {
					packageObj.mydebug("changeFormulaParameter is zero length. Setting to X");
					changeFormulaParameter="X";
				}
				if (changeFormulaParameter.length()>200) {
					packageObj.mydebug("changeFormulaParameter ["+changeFormulaParameter+"] too long. Truncating to 200.");
					changeFormulaParameter=changeFormulaParameter.substring(0,200);
				}
				
				packageObj.mydebug("changeLoginParametersORACLE aFormula                 : ["+aFormula+"]");
				packageObj.mydebug("changeLoginParametersORACLE changeFormulaMethod      : ["+changeFormulaMethod+"]");
				packageObj.mydebug("changeLoginParametersORACLE changeFormulaParameter   : ["+changeFormulaParameter+"]");
				
				byte[] searchBytes=searchStr.getBytes();
				int pos_param_name=ddmLib.IndexOfByteArray(bufNew, 0, bufNew.length, searchBytes);
				
				if (pos_param_name==-1) {
					packageObj.mydebug("bytes not found for parameter : "+searchStr);
					continue;
				} else 
					packageObj.mydebug("parameter located @pos :"+pos_param_name);
				
				String current_parameter_value="";
				
				int len1=0;
				int len2=0;
				int multiplier=1;
				
				packageObj.mydebug("oracle_package_version_number           : "+packageObj.oracle_package_version_number);
				packageObj.mydebug("oracle_protocol_characteristic original : "+packageObj.oracle_protocol_characteristic);
				packageObj.mydebug("oracle_protocol_characteristic changed  : "+protocol_characteristic);
				
				if (protocol_characteristic==-14834) {
					
					len1=(int) bufNew[pos_param_name+searchBytes.length+0];
					len2=(int) bufNew[pos_param_name+searchBytes.length+4];
					multiplier=len1/len2;
					
					current_parameter_value=new String(bufNew,pos_param_name+searchBytes.length+5,len2);
					
				} else {
					len1=(int) bufNew[pos_param_name+searchBytes.length+1];
					len2=(int) bufNew[pos_param_name+searchBytes.length+2];
					multiplier=len1/len2;
					
					
					current_parameter_value=new String(bufNew,pos_param_name+searchBytes.length+3,len1);
				}
				
				
				packageObj.mydebug("len1                    : "+len1);
				packageObj.mydebug("len2                    : "+len2);
				packageObj.mydebug("multiplier              : "+multiplier);
				packageObj.mydebug("current_parameter_value :"+current_parameter_value);
				
				
				String changed_parameter_value=current_parameter_value;
				if (changeFormulaMethod.equals("APPEND")) changed_parameter_value=current_parameter_value+changeFormulaParameter;
				else if (changeFormulaMethod.equals("INSERT"))  changed_parameter_value=changeFormulaParameter+current_parameter_value;
				else changed_parameter_value=changeFormulaParameter;
				
				packageObj.mydebug("changed_parameter_value :"+changed_parameter_value);
				
				if (changed_parameter_value.equals(current_parameter_value)) {
					packageObj.mydebug("Nothing changed.");
					continue;
				}
				
				
				ddmLib.saveChangedSessionVar(packageObj,searchStr,current_parameter_value);
				//degisenleri degismemis olarak sesssion verilerinde tutmak icin sakliyoruz
				packageObj.mydebug("*Saving changed session variable ["+searchStr+"] ="+current_parameter_value);
				packageObj.changedSessionVariables.add(new String[]{searchStr,current_parameter_value});
				
				is_changed=true;
				
				int diff=changed_parameter_value.length()-current_parameter_value.length();
				packageObj.mydebug("diff                    :"+diff);
				
				int cursor_target=0;
				int cursor_source=0;
				
				byte[] tmpBuf=new byte[ bufNew.length+diff+100];
				System.arraycopy(bufNew, cursor_source , tmpBuf, cursor_target, pos_param_name);
				cursor_source+=pos_param_name;
				cursor_target+=pos_param_name;
				
				System.arraycopy(searchBytes, 0 , tmpBuf, cursor_target, searchBytes.length);
				cursor_source+=searchBytes.length;
				cursor_target+=searchBytes.length;
				
				byte[] lenBytes=null;
				
				if (protocol_characteristic==-14834) {
					lenBytes=new byte[5];
					lenBytes[0]=(byte) (changed_parameter_value.length()*multiplier);
					lenBytes[4]=(byte) (changed_parameter_value.length());
				} else {
					lenBytes=new byte[3];
					lenBytes[0]=1;
					lenBytes[1]=(byte) (changed_parameter_value.length()*multiplier);;
					lenBytes[2]=(byte) (changed_parameter_value.length());
				}
				
				packageObj.mydebug("lenBytes:");
				packageObj.printByteArray(lenBytes, lenBytes.length);
				
				System.arraycopy(lenBytes, 0 , tmpBuf, cursor_target, lenBytes.length);
				cursor_source+=lenBytes.length;
				cursor_target+=lenBytes.length;
				
				
				byte[] currentParamValueArr=current_parameter_value.getBytes();
				byte[] changedParamValueArr=changed_parameter_value.getBytes();
				
				System.arraycopy(changedParamValueArr, 0 , tmpBuf, cursor_target, changedParamValueArr.length);
				cursor_source+=currentParamValueArr.length;
				cursor_target+=changedParamValueArr.length;
				
				int remaining=bufNew.length-cursor_source;
				packageObj.mydebug("remaining : "+remaining);
				
				System.arraycopy(bufNew, cursor_source , tmpBuf, cursor_target, remaining);
				cursor_source+=remaining;
				cursor_target+=remaining;
				
				int current_package_len=ddmLib.getPackageLength(bufNew, 0);
				
				packageObj.mydebug("pos_package_len     : "+pos_package_len);
				packageObj.mydebug("current_package_len : "+current_package_len);
				
				int changed_package_len=current_package_len+diff;
				byte[] packageSizeByteArr=ddmLib.convertInteger2ByteArray4Bytes(changed_package_len, ByteOrder.BIG_ENDIAN);
				
				packageObj.mydebug("changed_package_len : "+changed_package_len);
				packageObj.mydebug("packageSizeByteArr : ");
				packageObj.printByteArray(packageSizeByteArr, packageSizeByteArr.length);
				
				
				System.arraycopy(packageSizeByteArr, 2, tmpBuf, pos_package_len, 2);
				
				
				
				bufNew=new byte[changed_package_len];
				System.arraycopy(tmpBuf, 0, bufNew, 0, changed_package_len);
				
				packageObj.mydebug("bufNew : ");
				packageObj.printByteArray(bufNew, bufNew.length);
				
			} catch(Exception e) {
				e.printStackTrace();
				packageObj.mylog("Exception@changeLoginParametersORACLE :"+genLib.getStackTraceAsStringBuilder(e).toString());
				return false;
			}

			
		} //for (int a=0;a<arrSearch.length;a++)
		
		
		if (is_changed) {
			packageObj.mydebug("Changed login handshake package : ");
			packageObj.printByteArray(bufNew, bufNew.length);
			packageObj.sendBuffer(to_server_stream,bufNew, 0, bufNew.length);
		}
		
		return is_changed;
	
	}
	
	
	
	//---------------------------------------------------------------------
	int checkPackageORACLE_CLIENT(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_server_stream) {
		
		try {
			
			//[0][0][0][10][6] [0][0][0]@
			//EOF - disconnect
			if (buf[4]==(byte) 6) {
				if (buf[9]==(byte) '@' && len==10) {
					packageObj.client_cancelled=true;
					packageObj.mydebug("Oracle EOF package from client. Gracefuly ending the session...");
					packageObj.printByteArray(buf, len);
					return  len;
				}
				else if (len<50) {
					return  len;
				}
				
			}
			
			if (!packageObj.is_authorized) {
				
				
				oracleTnsLib.discoverChunkConfiguration(packageObj,buf,len);
				
				
				boolean is_changed=changeLoginParametersORACLE(packageObj,buf,len,to_server_stream);
				
				if (is_changed) return -buf.length; //-len;//-buf.length;
				
				
			}
			
			
			
			packageObj.feedOraclePack(buf, len, to_server_stream);
						
			return -len;
		}
		catch(Exception e) {
			mylog("Exception@checkPackageORACLE_CLIENT:"+genLib.getStackTraceAsStringBuilder(e).toString());

			return len;
		}

	}
	

	
	//**************************************************
	int checkPackageORACLE_SERVER(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_client_stream) {
		
		if (packageObj.is_authorized) return len;
		
		packageObj.setOracleSessionVariables(buf, len);
		
		return len;

	}


	//**************************************************

	int checkPackageGeneric(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_server_stream,
			DataOutputStream to_client_stream) {
		
		
		if (origin==FROM_CLIENT) 
			return checkPackageGeneric_CLIENT(packageObj, buf, len, origin, to_server_stream);
		else 
			return checkPackageGeneric_SERVER(packageObj, buf, len, origin, to_client_stream);
		
	}
	//**************************************************

	
	int checkPackageGeneric_CLIENT(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_server_stream) {
		
		return len;
		
		
	}
	
	//**************************************************
	int checkPackageGeneric_SERVER(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_client_stream) {
		
		
		if (packageObj.is_authorized) return len;
		
		packageObj.setGenericSessionVariables();
		
		return len;
	}
	
	
	//**************************************************
	int checkPackagePOSTGRESQL(
			ddmClient ddmClient,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_server_stream,
			DataOutputStream to_client_stream) {
		
		
		
		if (origin==FROM_CLIENT) 
			return checkPackagePOSTGRESQL_CLIENT(ddmClient, buf, len, origin, to_server_stream);
		else 
			return checkPackagePOSTGRESQL_SERVER(ddmClient, buf, len, origin, to_client_stream);
		
	}
	
	//**************************************************
	int checkPackagePOSTGRESQL_CLIENT(
			ddmClient ddmClient,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_server_stream) {
		
		
		if (!ddmClient.is_authorized) return len;
		
		if (buf[0]!=(char) 'P') return len;
		
		try {
			ddmClient.feedPOSTGRESQLPack(buf, len, to_server_stream);
			return -len;
		}
		catch(Exception e) {
			e.printStackTrace();
			return len;
		}
		
		
		
		
	}
	
	//**************************************************
	int checkPackagePOSTGRESQL_SERVER(
			ddmClient ddmClient,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_client_stream) {
		
		
		
		
		if (ddmClient.is_authorized) return len;
		
		ddmClient.setPOSTGRESQLSessionVariables(buf, len);
		
		
		
		return len;
		
	}


	
	//**************************************************
	int checkPackageMicrosoftSQL(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_server_stream,
			DataOutputStream to_client_stream) {
		
		
		
		if (origin==FROM_CLIENT) 
			return checkPackageMicrosoftSQL_CLIENT(packageObj, buf, len, origin, to_server_stream);
		else 
			return checkPackageMicrosoftSQL_SERVER(packageObj, buf, len, origin, to_client_stream);
		
	}
	
	//**************************************************
	int checkPackageMicrosoftSQL_CLIENT(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_server_stream) {
		
		try {
			packageObj.feedMicrosoftSQLPack(buf, len, to_server_stream);
			return -len;
		}
		catch(Exception e) {
			e.printStackTrace();
			return len;
		}
		
		
		
		
	}
	
	//**************************************************
	int checkPackageMicrosoftSQL_SERVER(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_client_stream) {
		
		
		if (packageObj.is_authorized) return len;
		
		
		
		packageObj.setMicrosoftSQLSessionVariables(buf, len);
		
		
		
		return len;
	}

	
	
	//************************************************
	public int heapUsedRate() {
	//************************************************
		
	
	Runtime runtime = Runtime.getRuntime();
	int ret1=Math.round(100* (runtime.totalMemory()-runtime.freeMemory())  / runtime.maxMemory());
	
	runtime=null;
	
	return ret1;
	
	}
	
	//************************************************
	public int heapUsedAsMByte() {
	//************************************************
		
	
	Runtime runtime = Runtime.getRuntime();
	int ret1=Math.round((runtime.totalMemory())  / 1024);
	
	runtime=null;
	
	return ret1;
	
	}
	
	//*************************************************************************************************
	boolean checkSqlStatementToBeLogged(ddmProxyServer ddm, String username, String sql) {
		
		int hashcode=sql.hashCode();
		
		if (ddm.hmConfig.containsKey("LOGGING_STATUS_FOR_"+hashcode)) 
			return (boolean) ddm.hmConfig.get("LOGGING_STATUS_FOR_"+hashcode);
		
		boolean ret1=true;
		
		
		
		for (int i=0;i<ddm.sqlLoggingExceptionRules.size();i++) {
			
			String scope=ddm.sqlLoggingExceptionRules.get(i)[0];
			String rule=ddm.sqlLoggingExceptionRules.get(i)[1];
			String keys=ddm.sqlLoggingExceptionRules.get(i)[2];
			String case_sensitive=ddm.sqlLoggingExceptionRules.get(i)[3];
			
			mydebug("checkSqlStatementToBeLogged "+scope+" "+rule+ " " + keys+ " "+case_sensitive);
			
			boolean is_matched=false;
			
			if (scope.equals("SQL")) {
				is_matched=ddmLib.testRule(sql, rule, keys, case_sensitive);
			} else {
				is_matched=ddmLib.testRule(username, rule, keys, case_sensitive);
			}
			
			if (is_matched) {
				ret1=false;
				break;
			}
			
		}
		
		hmConfig.put("LOGGING_STATUS_FOR_"+hashcode, ret1);
		
		return ret1;
	}
	
	//*************************************************************************************************
	
	static final String proxy_create_session_sql="insert into tdm_proxy_session (id, proxy_id, status, username, start_date, last_activity_date, session_info) "+
			" values ( ?, ?, 'ACTIVE',?, now(), now(), ? )  ";
	static final String proxy_update_session_info_sql="update tdm_proxy_session set session_info=? where id=? and  proxy_id=? ";
	static final String sql_insert_sql="insert into tdm_proxy_log "+
			" (proxy_id, proxy_session_id, log_date, current_schema, original_sql, sample_sql, masking_sql, bind_info, sample_count, statement_type ) "+
			" values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ";

	static final String session_close_sql="update tdm_proxy_session set last_activity_date=?, finish_date=?, status='CLOSED', exception_time_to=null where id=? ";
	static final String session_disconnect_sql="update tdm_proxy_session set finish_date=?, status='ABORTED', exception_time_to=null where id=? ";
	static final String session_heartbeat_sql="update tdm_proxy_session set last_activity_date=? where id=? ";
	static final String session_blacklist_check_sql="select 1 from tdm_proxy_monitoring_blacklist where proxy_id=? and machine=? and osuser=? and dbuser=? and is_deactivated='NO' limit 0,1";
	static final String session_blacklist_insert_sql="insert into tdm_proxy_monitoring_blacklist (proxy_id, proxy_session_id, blacklist_time, machine, osuser, dbuser) values (?,?,?,?,?,?) ";

	
	final String DUMMY="DUMMY";
	final String SQL="SQL";
	final String NO_SQL="NO_SQL";
	final String SESSION="SESSION";
	final String UPDATE_SESSION_INFO="UPDATE_SESSION_INFO";
	final String HEARTBEAT="HEARTBEAT";
	final String CLOSE="CLOSE";
	final String ABORT="ABORT";
	final String BLACKLIST="BLACKLIST";

	void persistProxyEvents(
			Connection conn,
			ArrayList<String[]> eventArray,
			ddmProxyServer dm,
			int proxy_id, 
			boolean persist_all
			) {
		
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		int done_count=0;
		
		
		int arr_len=eventArray.size();
		
		for (int i=0;i<arr_len;i++) {
			
			
			//if (persist_all && (i% 100==0) ) mydebug("Persisting events : "+i+"/"+arr_len+"...");
			
			String[] arrP=eventArray.get(i);
			
			if (arrP==null)  continue;
			
			String log_type=arrP[0];


			
			String log_ts=arrP[1];
			String username=arrP[2];
			String original_sql=arrP[3];
			String sql_without_where_condition=arrP[4];
			String mask_sql=arrP[5];
			String session_id=arrP[6];
			String bind_info=arrP[7];
			String session_info=arrP[8];
			String sample_count=arrP[9];
			
			if (original_sql!=null && original_sql.length()>100000) original_sql=original_sql.substring(0,100000);
			if (sql_without_where_condition!=null && sql_without_where_condition.length()>100000) sql_without_where_condition=sql_without_where_condition.substring(0,100000);
			if (mask_sql!=null && mask_sql.length()>100000) mask_sql=mask_sql.substring(0,100000);
			if (bind_info!=null && bind_info.length()>100000) bind_info=bind_info.substring(0,100000);
			
			if (log_type.equals(SQL) || log_type.equals(NO_SQL)) {
				
				boolean to_be_logged=checkSqlStatementToBeLogged(dm, username, original_sql);
				
				if (to_be_logged) {
					
					String statement_type=ddmLib.getStatementType(this, original_sql);
					
					bindlist.clear();
					bindlist.add(new String[]{"INTEGER",""+proxy_id});
					bindlist.add(new String[]{"LONG",session_id});
					bindlist.add(new String[]{"TIMESTAMP",log_ts});
					bindlist.add(new String[]{"STRING",username});
					bindlist.add(new String[]{"STRING",original_sql});
					bindlist.add(new String[]{"STRING",sql_without_where_condition});
					bindlist.add(new String[]{"STRING",mask_sql});
					bindlist.add(new String[]{"STRING",bind_info});
					bindlist.add(new String[]{"INTEGER",sample_count});
					bindlist.add(new String[]{"STRING",statement_type});
					
					ddmLib.execSingleUpdateSQL(conn, sql_insert_sql, bindlist);
				}
				
				
			} 
			else if (log_type.equals(SESSION)) {
				
				
				bindlist.clear();
				bindlist.add(new String[]{"LONG",session_id});
				bindlist.add(new String[]{"LONG",""+proxy_id});
				bindlist.add(new String[]{"STRING",""+username});
				bindlist.add(new String[]{"STRING",""+session_info.toString()});
				
				ddmLib.execSingleUpdateSQL(conn, proxy_create_session_sql, bindlist);
				
				
			}
			else if (log_type.equals(UPDATE_SESSION_INFO)) {
				
				
				bindlist.clear();
				bindlist.add(new String[]{"STRING",""+session_info});
				bindlist.add(new String[]{"LONG",session_id});
				bindlist.add(new String[]{"LONG",""+proxy_id});
				
				ddmLib.execSingleUpdateSQL(conn, proxy_update_session_info_sql, bindlist);
				
				
			}
			else if (log_type.equals(HEARTBEAT)) {
				
				
				bindlist.clear();
				bindlist.add(new String[]{"TIMESTAMP",""+log_ts});
				bindlist.add(new String[]{"LONG",""+session_id});
				
				ddmLib.execSingleUpdateSQL(conn, session_heartbeat_sql, bindlist);
				
				
			}
			
			else if (log_type.equals(CLOSE)) {
				
				
				bindlist.clear();
				bindlist.add(new String[]{"TIMESTAMP",""+log_ts});
				bindlist.add(new String[]{"TIMESTAMP",""+log_ts});
				bindlist.add(new String[]{"LONG",""+session_id});
				
				ddmLib.execSingleUpdateSQL(conn, session_close_sql, bindlist);
				
				
			}
			
			else if (log_type.equals(ABORT)) {
				
				
				bindlist.clear();
				bindlist.add(new String[]{"TIMESTAMP",""+log_ts});
				bindlist.add(new String[]{"LONG",""+session_id});
				
				ddmLib.execSingleUpdateSQL(conn, session_disconnect_sql, bindlist);
				
				
			}
			else if (log_type.equals(BLACKLIST)) {
				
				String machine=arrP[2];
				String osuser=arrP[3];
				String dbuser=arrP[4];
				
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+proxy_id});
				bindlist.add(new String[]{"STRING",""+machine});
				bindlist.add(new String[]{"STRING",""+osuser});
				bindlist.add(new String[]{"STRING",""+dbuser});
				ArrayList<String[]> dupCheckArr=ddmLib.getDbArray(conn, session_blacklist_check_sql, 1, bindlist, 0);
				
				if (dupCheckArr!=null &&  dupCheckArr.size()==0) {
					bindlist.clear();
					bindlist.add(new String[]{"INTEGER",""+proxy_id});
					bindlist.add(new String[]{"LONG",""+session_id});
					bindlist.add(new String[]{"TIMESTAMP",""+log_ts});
					bindlist.add(new String[]{"STRING",""+machine});
					bindlist.add(new String[]{"STRING",""+osuser});
					bindlist.add(new String[]{"STRING",""+dbuser});

					ddmLib.execSingleUpdateSQL(conn, session_blacklist_insert_sql, bindlist);
				}
				
			}
			
			done_count++;
			if (done_count>=1000 && !persist_all) break;
			
			
			
		}
		
		
		
	}
	
	
	//**************************************************
	int checkPackageMONGODB(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_server_stream,
			DataOutputStream to_client_stream) {
		if (origin==FROM_CLIENT) {
			return  checkPackageMONGODB_CLIENT(packageObj, buf, len, origin, to_server_stream);
		}
			
		else {
			return checkPackageMONGODB_SERVER(packageObj, buf, len, origin, to_client_stream);
		}
			
		
	}
			
	//**************************************************	
	int checkPackageMONGODB_CLIENT(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_server_stream) {
		
		if (!packageObj.is_authorized) 
			packageObj.setMONGOSessionVariables(buf, len);
		
		
		try {
			return packageObj.feedMONGOPack(buf, len, to_server_stream, origin);
		}
		catch(Exception e) {
			e.printStackTrace();
			return len;
		}
		
		
		
		
	}
		
	//**************************************************
	int checkPackageMONGODB_SERVER(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_client_stream) {
		
		try {
			return packageObj.feedMONGOPack(buf, len, to_client_stream, origin);
		}
		catch(Exception e) {
			e.printStackTrace();
			return len;
		}
		
		
		
		
	}
	
	
	
	//**************************************************
	int checkPackageHIVE(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_server_stream,
			DataOutputStream to_client_stream) {
		if (origin==FROM_CLIENT) 
			return checkPackageHIVE_CLIENT(packageObj, buf, len, origin, to_server_stream);
		else 
			return checkPackageHIVE_SERVER(packageObj, buf, len, origin, to_client_stream);
		
	}
		
	
	int checkPackageHIVE_CLIENT(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_server_stream) {
		
		
		
		
		
		if (!packageObj.is_authorized) {
			packageObj.setHIVESessionVariables(buf, len);
		}
		
		
		try {
			packageObj.feedHIVEPack(buf, len, to_server_stream);
			return -len;
		}
		catch(Exception e) {
			e.printStackTrace();
			return len;
		}
		
		
		
		
	}
	
	//**************************************************
	int checkPackageHIVE_SERVER(
			ddmClient packageObj,
			byte[] buf, 
			int len, 
			int origin,
			DataOutputStream to_client_stream) {
		
		if (!packageObj.is_authorized) packageObj.checkHiveAuthorization(buf, len);
		
		return len;
		
		
	}
	
	
	//**************************************************
		int checkPackageMySQL(
				ddmClient packageObj,
				byte[] buf, 
				int len, 
				int origin,
				DataOutputStream to_server_stream,
				DataOutputStream to_client_stream) {
			if (origin==FROM_CLIENT) 
				return checkPackageMySQL_CLIENT(packageObj, buf, len, origin, to_server_stream);
			else 
				return checkPackageMySQL_SERVER(packageObj, buf, len, origin, to_client_stream);
			
		}
		
		//**************************************************


		int checkPackageMySQL_CLIENT(
				ddmClient packageObj,
				byte[] buf, 
				int len, 
				int origin,
				DataOutputStream to_server_stream) {
			
			if (!packageObj.is_authorized) return len;
			
			
			
			try {
				packageObj.feedMySQLPack(buf, len, to_server_stream);
				
				return -len;
			}
			catch(Exception e) {
				e.printStackTrace();
				return len;
			}
			
			
			
			
		}
		
		//**************************************************
		int checkPackageMySQL_SERVER(
				ddmClient packageObj,
				byte[] buf, 
				int len, 
				int origin,
				DataOutputStream to_client_stream) {
			
			if (packageObj.is_authorized) return len;
			
			packageObj.setMySQLSessionVariables(buf, len);
			
			
			return len;
		}

		
		
		
		//*******************************************************************************
		synchronized void decreaseActiveListenerCount() {
			active_listener_count--;
		}
		
		
		//****************************************************************
		
		static final String[] REFRESH_KEYWORD_ORCL=new String[]{"drop|create|alter"};
		
		static final String[] REFRESH_KEYWORD_ORCL1=new String[]{"create","or","replace","view","as","select","from"};
		static final String[] REFRESH_KEYWORD_ORCL2=new String[]{"alter","view"};
		static final String[] REFRESH_KEYWORD_ORCL3=new String[]{"alter","table"};
		static final String[] REFRESH_KEYWORD_ORCL4=new String[]{"create","view"};
		static final String[] REFRESH_KEYWORD_ORCL5=new String[]{"create","table"};
		static final String[] REFRESH_KEYWORD_ORCL6=new String[]{"alter","table"};
		static final String[] REFRESH_KEYWORD_ORCL7=new String[]{"alter","MATERIALIZED","VIEW"};
		static final String[] REFRESH_KEYWORD_ORCL8=new String[]{"drop","table"};
		static final String[] REFRESH_KEYWORD_ORCL9=new String[]{"drop","view"};
		static final String[] REFRESH_KEYWORD_ORCL10=new String[]{"drop","MATERIALIZED","VIEW"};

		boolean checkClearCacheNeededForOracle(String sql) {
			
			if (!oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_ORCL)) return false;
			
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_ORCL1))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_ORCL2))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_ORCL3))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_ORCL4))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_ORCL5))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_ORCL6))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_ORCL7))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_ORCL8))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_ORCL9))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_ORCL10)) return true;
			
			return false;
		}
		
		//****************************************************************
		
		
		
		static final String[] REFRESH_KEYWORD_POSTGRE=new String[]{"drop|create|alter"};
		
		static final String[] REFRESH_KEYWORD_POSTGRE1=new String[]{"create","or","replace","view","as","select","from"};
		static final String[] REFRESH_KEYWORD_POSTGRE2=new String[]{"alter","view"};
		static final String[] REFRESH_KEYWORD_POSTGRE3=new String[]{"alter","table"};
		static final String[] REFRESH_KEYWORD_POSTGRE4=new String[]{"create","view"};
		static final String[] REFRESH_KEYWORD_POSTGRE5=new String[]{"create","table"};
		static final String[] REFRESH_KEYWORD_POSTGRE6=new String[]{"alter","table"};
		static final String[] REFRESH_KEYWORD_POSTGRE7=new String[]{"alter","MATERIALIZED","VIEW"};
		static final String[] REFRESH_KEYWORD_POSTGRE8=new String[]{"drop","table"};
		static final String[] REFRESH_KEYWORD_POSTGRE9=new String[]{"drop","view"};
		static final String[] REFRESH_KEYWORD_POSTGRE10=new String[]{"drop","MATERIALIZED","VIEW"};
		
		boolean checkClearCacheNeededForPostgreSQL(String sql) {
			
			if (!oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_POSTGRE)) return false;
			
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_POSTGRE1))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_POSTGRE2))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_POSTGRE3))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_POSTGRE4))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_POSTGRE5))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_POSTGRE6))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_POSTGRE7))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_POSTGRE8))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_POSTGRE9))  return true;
			if (oracleParser.checkKeywordArrays(sql, REFRESH_KEYWORD_POSTGRE10)) return true;
			
			return false;
		}

		//*******************************************************************
	    void closeClient(String session_id) {
	    	ddmLib.addProxyEvent(
	    			this,
	    			this.proxyEventArray, 
	    			this.CLOSE,
					""+System.currentTimeMillis(),
					null,
					null,
					null,
					null,
					session_id,
					null,
					null,
					null
					);
	    }
	    
	  //*******************************************************************
	    void disconnectClient(String session_id) {
	    	ddmLib.addProxyEvent(
	    			this,
	    			this.proxyEventArray, 
	    			this.ABORT,
					""+System.currentTimeMillis(),
					null,
					null,
					null,
					null,
					session_id,
					null,
					null,
					null
					);
	    }
	   
}
