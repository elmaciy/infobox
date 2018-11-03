package com.mayatech.tdm;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.lang.management.ManagementFactory;
import java.lang.management.RuntimeMXBean;
import java.net.InetAddress;
import java.nio.ByteBuffer;
import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Random;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.DataFormatException;
import java.util.zip.Deflater;
import java.util.zip.Inflater;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

import oracle.sql.ROWID;

import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.bson.Document;

import com.jbase.jremote.DefaultJConnectionFactory;
import com.jbase.jremote.JConnection;
import com.jbase.jremote.JDynArray;
import com.jbase.jremote.JFile;
import com.jbase.jremote.JRemoteException;
import com.jbase.jremote.JResultSet;
import com.jbase.jremote.JStatement;
import com.mayatech.baseLibs.genLib;
import com.mayatech.buildDrivers.BuildDriver;
import com.mayatech.deployDrivers.DeployDriver;
import com.mayatech.repoDrivers.RepoExplorer;
import com.mongodb.DBObject;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoDatabase;
import com.mongodb.util.JSON;
import com.sun.mail.util.BASE64EncoderStream;

public class ConfDBOper {

	long worker_last_worked_ts = System.currentTimeMillis() - 10000000;
	Logger logger = LogManager.getLogger(this.getClass());

	String conf_db_type = "";
	String conf_driver = genLib.getEnvValue("CONFIG_DRIVER");
	String conf_connstr = genLib.getEnvValue("CONFIG_CONNSTR");
	String conf_username = genLib.getEnvValue("CONFIG_USERNAME");
	String conf_password = genLib.getEnvValue("CONFIG_PASSWORD");

	String app_db_type = "";
	String app_driver = "";
	String app_connstr = "";
	String app_username = "";
	String app_password = "";

	boolean is_mongo = false;

	String start_ch = "\"";
	String end_ch = "\"";
	String middle_ch = ".";

	static final String TAG_RECORD_START = "<r>";
	static final String TAG_RECORD_END = "</r>";

	static final String TAG_FIELD_START = "<f>";
	static final String TAG_FIELD_END = "</f>";

	String DB_TEST_SQL = "";

	public Connection connConf = null;
	Connection connApp = null;

	PreparedStatement pstmt_execbind = null;

	PreparedStatement pstmtLoop = null;
	ResultSet rsetLoop = null;
	ResultSetMetaData rsmdLoop = null;

	public String WORK_PLAN_TYPE = "";
	public int REC_SIZE_PER_TASK = 1000;
	public int TASK_SIZE_PER_WORKER = 10;
	private int BULK_UPDATE_REC_COUNT = 50;
	private int COMMIT_LENGTH = 20;
	public long UPDATE_COUNT_AND_STATUS_ALL_INTERVAL = 5 * 60 * 1000;
	public String RUN_TYPE = "TEST";
	public String EXECUTION_TYPE = "PARALLEL";
	public String ON_ERROR_ACTION = "CONTINUE";
	public String WORK_PLAN_MAIL_ADDRESS = "";

	public static final long HEARTBEAT_INTERVAL = 10000;
	private static final int FINISHED_TASK_REC_LIMIT = 100;
	public static final long CONTROLL_FINISHED_TASK_INTERVAL = 20000;
	public static final long ASSIGNMENT_TIMEOUT = 60000;
	public static final int TASK_SIZE_PER_LOOP = 1;
	public static final long CANCEL_FLAG_CHECK_INTERVAL = 10000;
	static final long WORKPLAN_TABLE_COUNT_INTERVAL = 30000;
	static final int TAB_COUNT_SIZE = 10;
	static final long CREATE_WPACK_INTERVAL = 10000;
	static final long KILL_DEAD_PROCESS_INTERVAL = 60 * 1000;
	static final long KILL_DEAD_PROCESS_TIMEOUT = 5 * 60 * 1000;
	static final long NEXT_WORKER_CHECK_INTERVAL = 5000;
	static final long NEXT_MASTER_CHECK_INTERVAL = 5000;
	static final long RESUME_STALLED_TIMEOUT = 2 * 60 * 1000;
	static final long WAIT_BEFORE_RESUME_TIMEOUT = 5 * 60 * 1000;
	static final long NEXT_WORK_PLAN_CANCEL_CHECK_INTERVAL = 20000;
	static final int DATABASE_RECORD_FETCH_SIZE = 1000;
	static final int MAX_TASK_RETRY_COUNT = 0;
	static final int NEXT_DISCIVERY_CANCEL_CHECK_INTERVAL = 5000;
	static final int NEXT_NEW_PROCESS_CHECK_INTERVAL = 10000;
	static final int NEXT_SCRIPT_RUNNER_INTERVAL = 30000;
	static final int NEXT_DISCOVE_TABLES_INTERVAL = 30000;
	static final int RESTART_FLAG_CHECK_INTERVAL = 5 * 1000;
	static final int NEXT_TASK_ACTIVITY_INTERVAL = 10 * 1000;
	static final int NEXT_MAD_NOTIFICATION_INTERVAL = 30000;
	static final int CREATE_MAD_DEPLOYMENT_WPLANS_INTERVAL = 15000;
	static final int NEXT_RUN_ACTION_METHOD_INTERVAL = 10000;

	@SuppressWarnings("rawtypes")
	HashMap hm = new HashMap();

	int uncommitted_block_count = 0;

	long last_heartbeat = 0;
	long last_task_update = 0;

	long next_table_count_ts = 0;
	long next_cancel_flag_ts = 0;
	long next_create_wpack_ts = 0;
	long next_kill_dead_masters_ts = 0;
	long next_worker_check_ts = 0;
	long next_master_check_ts = 0;
	long next_resume_stalled_ts = 0;
	long next_updateCountAndStatusAll_ts = 0;
	long next_work_plan_cancel_check_ts = 0;
	long next_discovery_cancel_check_ts = 0;
	long next_new_process_check_ts = 0;
	long next_script_runner_ts = 0;
	long next_discover_tables_ts = 0;

	long next_restart_flag_ts = 0;
	long next_task_activity_ts = 0;
	long next_mad_notification_ts = 0;
	long next_create_mad_deployment_work_plans_ts = 0;
	long next_run_action_method_ts = 0;

	String p_sid = "";
	String java_pid = "";
	String p_mid = "";
	public int worker_id = 0;
	public int master_id = 0;
	public int manager_id = 0;

	int work_plan_id = -1;
	int work_package_id = -1;

	int last_work_plan_id = 0;

	private StringBuilder log_info = new StringBuilder();
	private StringBuilder err_info = new StringBuilder();

	ArrayList<String[]> mask_Profiles = null;

	ScriptEngineManager factory = null;
	ScriptEngine engine = null;

	public static final int CONFIG_FLD_WORK_PLAN_ID = 0;
	public static final int CONFIG_FLD_WORK_PACK_ID = 1;
	public static final int CONFIG_FLD_TAB_NAME = 2;
	public static final int CONFIG_FLD_SQL_STMT = 3;
	public static final int CONFIG_FLD_MASK_PARAMS = 4;
	public static final int CONFIG_FLD_DB_DRIVER = 5;
	public static final int CONFIG_FLD_DB_CONNSTR = 6;
	public static final int CONFIG_FLD_DB_USERNAME = 7;
	public static final int CONFIG_FLD_DB_PASSWORD = 8;

	public static final String MASK_TYPE_FIELD = "FIELD";

	static final int MASK_PRFL_FLD_ID = 0;
	static final int MASK_PRFL_FLD_NAME = 1;
	static final int MASK_PRFL_FLD_RULE = 2;

	static final int MASK_PRFL_FLD_HIDE_CHAR = 3;
	static final int MASK_PRFL_FLD_HIDE_AFTER = 4;
	static final int MASK_PRFL_FLD_HIDE_BY_WORD = 5;

	static final int MASK_PRFL_FLD_SRC_LIST = 6;
	static final int MASK_PRFL_FLD_RANDOM_RANGE = 7;
	static final int MASK_PRFL_FLD_RANDOM_CHARLIST = 8;
	static final int MASK_PRFL_FLD_REGEX_STMT = 9;
	static final int MASK_PRFL_FLD_PRE_STATEMENT = 10;
	static final int MASK_PRFL_FLD_POST_STATEMENT = 11;
	static final int MASK_PRFL_FLD_FORMAT = 12;
	static final int MASK_PRFL_FLD_DATE_CHANGE_PARAMS = 13;

	static final int MASK_PRFL_FLD_FIXED_VAL = 14;
	static final int MASK_PRFL_FLD_JS_CODE = 15;

	static final int MASK_PRFL_FLD_SHORT_CODE = 16;

	static final String MASK_RULE_FIXED = "FIXED";
	static final String MASK_RULE_NONE = "NONE";
	static final String MASK_RULE_HIDE = "HIDE";
	static final String MASK_RULE_HASHLIST = "HASHLIST";
	static final String MASK_RULE_KEYMAP = "KEYMAP";
	static final String MASK_RULE_REPLACE_ALL = "REPLACE_ALL";
	static final String MASK_RULE_SCRAMBLE_INNER = "SCRAMBLE_INNER";
	static final String MASK_RULE_SCRAMBLE_RANDOM = "SCRAMBLE_RANDOM";
	static final String MASK_RULE_SCRAMBLE_DATE = "SCRAMBLE_DATE";
	static final String MASK_RULE_RANDOM_NUMBER = "RANDOM_NUMBER";
	static final String MASK_RULE_RANDOM_STRING = "RANDOM_STRING";
	static final String MASK_RULE_JAVASCRIPT = "JAVASCRIPT";
	static final String MASK_RULE_SQL = "SQL";
	static final String MASK_RULE_GROUP = "GROUP";
	static final String MASK_RULE_GROUP_MIX = "GROUP_MIX";
	static final String MASK_RULE_MIX = "MIX";
	static final String MASK_RULE_HASH_REF = "HASH_REF";

	static final String FIELD_TYPE_CALCULATED = "CALCULATED";

	static final String WORK_PLAN_TYPE_MASK = "MASK";
	static final String WORK_PLAN_TYPE_MASK2 = "MASK2";
	static final String WORK_PLAN_TYPE_COPY = "COPY";
	static final String WORK_PLAN_TYPE_COPY2 = "COPY2";
	static final String WORK_PLAN_TYPE_DEPL = "DEPL";
	static final String WORK_PLAN_TYPE_AUTO = "AUTO";
	static final String SILINECEK_WORK_PLAN_TYPE_DISC = "DISC";

	static final String MASK_DEFAULT_CHAR_LIST = "ABCÇDEFGHIÝJJKLMNOÖPQRSÞTUÜWXVYZabcçdefgðhýijklmnoöprsþtuüwxvyz";
	static final int[] RANDOM_INT_ARRAY = { 1442, 9105, 9893, 1407, 8590, 869,
			6283, 8822, 1762, 9193, 491, 3193, 1934, 5780, 9437, 7969, 9621,
			8581, 8330, 4220, 3242, 8765, 7323, 5542, 2021, 2262, 8900, 1951,
			4636, 2131, 7878, 9716, 311, 4196, 5888, 6037, 6022, 8562, 8715,
			8438, 2056, 3908, 7997, 8801, 8310, 9789, 8409, 1080, 5356, 4547,
			7716, 9904, 7624, 2921, 9823, 4518, 793, 7928, 339, 8808, 1916,
			6196, 34, 3519, 8710, 4554, 4077, 1189, 3957, 8401, 3953, 7829,
			2021, 9130, 4566, 7907, 7131, 8732, 1182, 821, 7230, 4576, 9599,
			7695, 2991, 6337, 8199, 7117, 8877, 45, 2403, 7173, 2013, 1315,
			432, 9044, 5091, 962, 4277, 4340 };

	static final String TYPE_LIST_STRING = "VARCHAR2,CHAR,VARCHAR,LONGVARCHAR,NCHAR,NVARCHAR,NLONGVARCHAR,LONG";
	static final String TYPE_LIST_INT = "NUMBER,TINYINT,SMALLINT,INTEGER,BIGINT,FLOAT,REAL,DOUBLE,NUMERIC,DECIMAL";
	static final String TYPE_LIST_DATE = "DATE,TIME,TIMESTAMP";
	static final String TYPE_LIST_BLOB = "BLOB,LONGBLOB,MEDIUMBLOB,TINYBLOB,LONGVARBINARY,BINARY,VARBINARY,OTHER";
	static final String TYPE_LIST_CLOB = "CLOB,LONGCLOB,MEDIUMCLOB,TINYBCLOB,LONGVARCHAR,MEDIUMVARCHAR";

	long master_done_count = 0;
	long worker_done_count = 0;
	long master_success_count = 0;
	long master_fail_count = 0;

	long work_done_count = 0;

	static final int TABLE_TDM_MANAGER = 1;
	static final int TABLE_TDM_MASTER = 2;
	static final int TABLE_TDM_WORKER = 3;

	java.util.Locale currLocale = new java.util.Locale("tr", "TR");

	JConnection JBASEconn = null;
	MongoClient MONGOclient = null;

	// ***********************************

	public ConfDBOper(boolean conntoappdb) {

		RuntimeMXBean rmxb = ManagementFactory.getRuntimeMXBean();
		java_pid = rmxb.getName();

		rmxb = null;

		if (("" + conf_driver).length() == 0) {

			conf_driver = "com.mysql.jdbc.Driver";
			conf_connstr = "jdbc:mysql://localhost/test?useUnicode=true&characterEncoding=utf8";
			conf_username = "ssping";
			conf_password = "123";

			app_db_type = genLib.DB_TYPE_ORACLE;

			app_driver = "oracle.jdbc.driver.OracleDriver";
			app_connstr = "jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=95.0.144.233)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME = orcl.localdomain)))";
			app_username = "mayatdm_demo";
			app_password = "mayatdm_demo";

		}

		connConf = getconn(conf_connstr, conf_driver, conf_username,
				conf_password);
		if (connConf == null) {
			closeAll();
			System.exit(0);
		} else {
			try {
				connConf.setAutoCommit(true);
			} catch (SQLException e) {
			}
		}

		if (conntoappdb) {
			connApp = getconn(app_connstr, app_driver, app_username,
					app_password);
			setConnCharacters(connApp);
			try {
				connApp.setAutoCommit(false);
			} catch (SQLException e) {
			}
		}

		String tdm_home = getParamByName("TDM_PROCESS_HOME");

		if (tdm_home.length() > 0) {
			String log4j_config_file = tdm_home + File.separator
					+ "log4j.properties";
			try {

				/*
				 * System.out.println(
				 * "Setting log4j.properties configuration file : "
				 * +log4j_config_file); Properties props = new Properties();
				 * props.load(new FileInputStream(log4j_config_file));
				 * PropertyConfigurator.configure(props); System.out.println(
				 * "Setting log4j.properties configuration file : "
				 * +log4j_config_file+" Done.");
				 */

			} catch (Exception e) {
				myerr("Exception@Load.log4j.properties : " + e.getMessage());
			}
		}

	}

	// *******************************************
	public void loadList(int list_id) {

		if (hm.containsKey("LIST_" + list_id + "_LOADED"))
			return;

		mylog(LOG_LEVEL_INFO, "Loading list : " + list_id + "...");

		String sql = "select list_val from tdm_list_items where list_id=?";
		ArrayList<String[]> l = getDbArrayConfInt(sql, Integer.MAX_VALUE,
				list_id);
		sql = "select title_list from tdm_list where id=?";
		String title_list = getDbArrayConfInt(sql, 1, list_id).get(0)[0];

		int title_count = 0;
		ArrayList<String> titleArr = new ArrayList<String>();

		if (!nvl(title_list, "-").equals("-") && title_list.contains("|::|")) {
			String[] arr = title_list.split("\\|::\\|");
			for (int i = 0; i < arr.length; i++)
				if (arr[i].length() > 0) {
					title_count++;
					titleArr.add(arr[i]);
				}

		}

		String k_base = "LIST_" + list_id;
		StringBuilder sb = new StringBuilder();
		int pos = -1;

		heartbeat(TABLE_TDM_WORKER, 0, worker_id);

		for (int i = 0; i < l.size(); i++) {
			if (title_count > 0) {

				sb.setLength(0);
				sb.append(l.get(i)[0]);
				sb.append("|::|");

				if (i % 1000 == 0)
					mylog(LOG_LEVEL_INFO, "Loading list .... " + (i + 1) + "/"
							+ l.size() + " heap : %" + heapUsedRate());

				if (i % 10000 == 0) {
					mylog(LOG_LEVEL_INFO, "garbage collection run...");
					System.gc();
				}

				for (int j = 0; j < title_count; j++) {
					pos = sb.indexOf("|::|");

					if (pos == 0)
						hm.put(k_base + "_" + i + "_" + titleArr.get(j), "");
					else
						hm.put(k_base + "_" + i + "_" + titleArr.get(j),
								sb.substring(0, pos));

					sb.delete(0, pos + 4);
				}

			} else
				hm.put(k_base + "_" + i, l.get(i)[0]);
		}
		hm.put(k_base + "_LOADED", "YES");
		hm.put(k_base + "_SIZE", l.size());

		mylog(LOG_LEVEL_INFO, "Loading list : " + list_id + "...DONE");

	}

	// ******************************************
	void indexList(int list_id, String index_fields) {

		String k_base = "LIST_" + list_id;
		if (hm.containsKey(k_base + "_INDEXED_" + index_fields))
			return;
		if (index_fields.length() == 0)
			return;
		mylog(LOG_LEVEL_INFO, " .......... Indexing " + k_base + " for {"
				+ index_fields + "} ...");

		int list_rec_size = (int) hm.get(k_base + "_SIZE");

		String[] fieldsArr = index_fields.split(",");
		StringBuilder indexkey = new StringBuilder();
		mylog(LOG_LEVEL_INFO,
				" * Indexing ... _KEYIDMAP_" + indexkey.toString());
		for (int i = 0; i < list_rec_size; i++) {
			indexkey.setLength(0);

			for (int k = 0; k < fieldsArr.length; k++)
				indexkey.append("["
						+ fieldsArr[k]
						+ "="
						+ (nvl(((String) hm.get(k_base + "_" + i + "_"
								+ fieldsArr[k])).replaceAll("\n|\r", ""), ""))
						+ "]");

			ArrayList<Integer> keyIdMap = (ArrayList<Integer>) hm.get(k_base
					+ "_KEYIDMAP_" + indexkey.toString());

			if (keyIdMap == null) {
				mylog(LOG_LEVEL_INFO,
						"Creating new KeyIDMAp for " + indexkey.toString());
				keyIdMap = new ArrayList<Integer>();
			}

			keyIdMap.add(i);

			hm.put(k_base + "_KEYIDMAP_" + indexkey.toString(), keyIdMap);

		} // for (int i=0;i<list_rec_size;i++)

		hm.put(k_base + "_INDEXED_" + index_fields, "YES");
	}

	// ******************************************
	public ArrayList<String[]> loadMaskProfiles() {

		mylog(LOG_LEVEL_INFO, "loading masking profiles... ");

		String sql = "SELECT id,    name,    rule_id,     hide_char,    hide_after,    hide_by_word, "
				+ " src_list_id,    random_range,    random_char_list,    regex_stmt,     pre_stmt,  post_stmt, "
				+ " format,    date_change_params,      fixed_val, js_code, short_code "
				+ " FROM tdm_mask_prof where valid='YES' order by id ";

		ArrayList<String[]> ret1 = getDbArrayConf(sql, Integer.MAX_VALUE);

		mylog(LOG_LEVEL_INFO, "loading masking profiles...DONE. ");
		return ret1;

	}

	// *******************************************
	public boolean testconn(Connection conn) {
		boolean ret1 = false;
		if (conn == null)
			return false;
		String test_sql = "";

		PreparedStatement stmt = null;
		ResultSet rset = null;
		mylog(LOG_LEVEL_INFO, "testing connection ....");
		try {

			String adriver = app_driver;

			if (conn.equals(connConf))
				adriver = conf_driver;

			String sql = "select flexval2 from  tdm_ref where ref_type='DB_TYPE' and ref_name='"
					+ adriver + "'";
			String template = "";

			try {
				template = getDbArrayConf(sql, 1).get(0)[0];
			} catch (Exception e) {
				template = "";
			}

			if (template.contains("|"))
				test_sql = template.split("\\|")[0];

			if (test_sql.length() == 0)
				test_sql = "select 1";

			stmt = conn.prepareStatement(test_sql);
			rset = stmt.executeQuery();
			while (rset.next()) {
				ret1 = true;
			}
			;

		} catch (Exception e) {
			mylog(LOG_LEVEL_WARNING, "test connection fails : " + test_sql);
			mylog(LOG_LEVEL_WARNING, "sql to test : " + test_sql);
			e.printStackTrace();
			ret1 = false;
		} finally {
			try {
				rset.close();
			} catch (Exception e) {
			}
			try {
				stmt.close();
			} catch (Exception e) {
			}
		}
		mylog(LOG_LEVEL_INFO, "testing connection ....DONE");
		// mylog("test connection returns : "+ret1);
		return ret1;
	}

	// *******************************************
	public void createAUTOWorkPackage(int wplan_id) {
		// *******************************************
		String sql = "select work_plan_name, a.name app_name from tdm_work_plan p, tdm_apps a where p.app_id=a.id and p.id=?";

		ArrayList<String[]> wplarr = getDbArrayConfInt(sql, 1, wplan_id);

		if (wplarr.size() == 0)
			return;

		String wp_name = wplarr.get(0)[0];
		String app_name = wplarr.get(0)[0];

		int wpack_id = 0;

		wpack_id = getNextWorkPackageSeq();

		createNewWorkPackage(wplan_id, wpack_id, 0, "NEW", app_name, "0", // tab_id
				"AUTOMATION", app_name, // tab_name,
				"AUTO", // mask_level,
				"", // tab_filter,
				"", // parallel_condition,
				"", // tab_order_stmt,
				"", // base_sql,
				"" // mask_params
		);

		mylog(LOG_LEVEL_INFO, "Creating task table for work package  : "
				+ wpack_id + " ...");
		createNewTaskTable(wplan_id, wpack_id);
		mylog(LOG_LEVEL_INFO, "done.");

	}

	// *******************************************
	public void createDEPLWorkPackage(int wplan_id) {
		// *******************************************
		String sql = "";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		// if this is sub deployment request, exit
		String run_type = "";
		sql = "select run_type from tdm_work_plan where id=?";
		ArrayList<String[]> charr = getDbArrayConfInt(sql, 1, wplan_id);
		if (charr.size() == 1)
			run_type = charr.get(0)[0];
		else
			return;

		if (run_type.equals("SUB"))
			return;

		ArrayList<String[]> verMemberDepList = new ArrayList<String[]>();

		sql = "select "
				+ "  rae.application_id, "
				+ "  rae.environment_id, "
				+ "  application_name, "
				+ "  p.id platform_id, "
				+ "  platform_name, "
				+ "  deployment_type, "
				+ "  e.on_error_action, "
				+ "  p.on_error_action "
				+ " from "
				+ "  mad_request_app_env rae, "
				+ "  mad_request r, "
				+ "  mad_application a, "
				+ "  mad_platform p, "
				+ "  mad_platform_env pe, "
				+ "  mad_platform_type pt, "
				+ "  mad_environment e"
				+ "  where "
				+ " rae.application_id=a.id "
				+ " and rae.request_id=r.id "
				+ " and a.platform_type_id=p.platform_type_id "
				+ " and p.platform_type_id=pt.id "
				+ " and rae.environment_id=pe.environment_id "
				+ " and pe.environment_id=e.id "
				+ " and pe.platform_id=p.id "
				+ " and exists (select 1 from mad_request_work_plan rwp where work_plan_id=? and rwp.request_id=r.id and rwp.deployment_attempt_no=r.deployment_attempt_no) "
				+ " and not exists "
				+ " (select 1 from  mad_request_platform_skip s where s.request_id=rae.request_id and s.platform_id=p.id) "
				+ " order by p.on_error_action "; // once on error CONTINUE
													// olanlar gelsin

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + wplan_id });
		ArrayList<String[]> depArr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		ArrayList<String> platformList = new ArrayList<String>();

		// list platform id's to deploy
		for (int i = 0; i < depArr.size(); i++) {
			String dep_platform_id = depArr.get(i)[3];
			if (platformList.contains(dep_platform_id))
				continue;
			platformList.add(dep_platform_id);
		}

		ArrayList<String[]> appPlatWPList = new ArrayList<String[]>();

		for (int d = 0; d < platformList.size(); d++) {
			String wpc_platform_id = platformList.get(d);

			for (int i = 0; i < depArr.size(); i++) {

				String dep_application_id = depArr.get(i)[0];
				String dep_environment_id = depArr.get(i)[1];
				String dep_application_name = depArr.get(i)[2];
				String dep_platform_id = depArr.get(i)[3];
				String dep_platform_name = depArr.get(i)[4];
				String dep_deployment_type = depArr.get(i)[5];
				String dep_on_error_action = nvl(
						nvl(depArr.get(i)[7], depArr.get(i)[6]), "CONTINUE");

				if (!wpc_platform_id.equals(dep_platform_id))
					continue;

				String work_plan_name = "Sub Deployment of " + wplan_id
						+ " for " + dep_application_name + "@"
						+ dep_platform_name;

				// Create Work Plan Here
				int sub_work_plan_id = getNextWorkPlanSeq();

				sql = "insert into tdm_work_plan (id, work_plan_name, env_id, app_id, target_env_id, wplan_type,"
						+ " on_error_action, execution_type, "
						+ "REC_SIZE_PER_TASK, TASK_SIZE_PER_WORKER, BULK_UPDATE_REC_COUNT, "
						+ " COMMIT_LENGTH, UPDATE_WPACK_COUNTS_INTERVAL, RUN_TYPE, "
						+ " master_limit, worker_limit,  "
						+ " start_date) values ( " + "?," + // id
						"?," + // work_plan_name
						"?," + // env_id
						"?," + // app_id
						"?," + // target_env_id
						"?," + // wplan_type
						"?," + // on_error_action
						"?," + // execution_type
						"?," + // REC_SIZE_PER_TASK
						"?," + // TASK_SIZE_PER_WORKER
						"?," + // BULK_UPDATE_REC_COUNT
						"?," + // COMMIT_LENGTH
						"?," + // UPDATE_WPACK_COUNTS_INTERVAL
						"?," + // run_type
						"?," + // master_limit
						"?," + // worker_limit
						"date_add(now(),  interval 10 SECOND)" + // start_time
						") ";

				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", "" + sub_work_plan_id });
				bindlist.add(new String[] { "STRING", work_plan_name });
				bindlist.add(new String[] { "INTEGER", dep_environment_id });
				bindlist.add(new String[] { "INTEGER", "" + wplan_id });
				bindlist.add(new String[] { "INTEGER", "0" });
				bindlist.add(new String[] { "STRING", "DEPL" });
				bindlist.add(new String[] { "STRING", dep_on_error_action });
				bindlist.add(new String[] { "STRING", dep_deployment_type });
				bindlist.add(new String[] { "LONG", "1" }); // REC_SIZE_PER_TASK
				bindlist.add(new String[] { "LONG", "1" }); // TASK_SIZE_PER_WORKER
				bindlist.add(new String[] { "LONG", "1" });
				bindlist.add(new String[] { "LONG", "1" });
				bindlist.add(new String[] { "LONG", "120000" });
				bindlist.add(new String[] { "STRING", "SUB" }); // run_type
				bindlist.add(new String[] { "INTEGER", "999" }); // master_limit
				bindlist.add(new String[] { "INTEGER", "999" }); // worker_limit

				execDBBindingConf(sql, bindlist);

				// link new created sub work plan to main work plan
				sql = "insert into tdm_work_plan_dependency (work_plan_id, depended_work_plan_id, dependency_order) values(?,?,?) ";
				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", "" + wplan_id });
				bindlist.add(new String[] { "INTEGER", "" + sub_work_plan_id });
				bindlist.add(new String[] { "INTEGER", "" + d });
				execDBBindingConf(sql, bindlist);

				// add to the list

				appPlatWPList.add(new String[] { dep_platform_id,
						dep_application_id, "" + sub_work_plan_id });

				sql = "select mram.id, mram.member_name, mram.request_id, member_path, member_version, member_tag_info, deployment_attempt_no "
						+ " from mad_request_application_member mram, mad_request r"
						+ " where mram.request_id=r.id "
						+ " and exists (select 1 from mad_request_work_plan rwp where work_plan_id=? and rwp.request_id=r.id and rwp.deployment_attempt_no=r.deployment_attempt_no) "
						+ " and mram.application_id=? "
						+ " and mram.to_skip='NO' "
						+ " and mram.status is null "
						+ " order by mram.member_order ";

				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", "" + wplan_id });
				bindlist.add(new String[] { "INTEGER", dep_application_id });

				ArrayList<String[]> memberArr = getDbArrayConf(sql,
						Integer.MAX_VALUE, bindlist);

				for (int m = 0; m < memberArr.size(); m++) {

					String dep_member_id = memberArr.get(m)[0];
					String dep_member_name = memberArr.get(m)[1];
					String dep_request_id = memberArr.get(m)[2];
					String dep_member_path = memberArr.get(m)[3];
					String dep_member_version = memberArr.get(m)[4];
					String dep_member_tag_info = memberArr.get(m)[5];
					String dep_deployment_attempt_no = memberArr.get(m)[6];

					int wpack_id = 0;

					for (int v = 0; v < verMemberDepList.size(); v++) {
						String comp_member_id = verMemberDepList.get(v)[0];
						String comp_member_path = verMemberDepList.get(v)[1];
						String comp_member_version = verMemberDepList.get(v)[2];
						String comp_platform_id = verMemberDepList.get(v)[3];
						String comp_member_wpack_id = verMemberDepList.get(v)[4];

						if (!comp_member_path.equals(dep_member_path)
								|| !comp_platform_id.equals(dep_platform_id))
							continue;

						int curr_ver = Integer.parseInt(dep_member_version);
						int comp_ver = Integer.parseInt(comp_member_version);

						// newer version is added before. use wplan
						if (comp_ver >= curr_ver) {
							mylog(LOG_LEVEL_INFO,
									"**** Newer or same version found : "
											+ comp_ver + " for "
											+ comp_member_path);
							wpack_id = Integer.parseInt(comp_member_wpack_id);
							break;
						}

						wpack_id = Integer.parseInt(comp_member_wpack_id);

						String deploy_params = "DEPLOY (member@app@platform@env):"
								+ comp_member_id
								+ "@"
								+ dep_application_id
								+ "@"
								+ dep_platform_id
								+ "@"
								+ dep_environment_id;

						sql = "update tdm_work_package set mask_params=? where id=?";
						bindlist.clear();
						bindlist.add(new String[] { "STRING", deploy_params });
						bindlist.add(new String[] { "INTEGER", "" + wpack_id });

						execDBBindingConf(sql, bindlist);

						verMemberDepList.set(v, new String[] { dep_member_id,
								dep_member_path, dep_member_version,
								dep_platform_id, "" + wpack_id });

						mylog(LOG_LEVEL_WARNING, "**** Older version found : "
								+ comp_ver + " for " + comp_member_path
								+ " and replaced with " + curr_ver);

						break;
					}

					if (wpack_id == 0) {

						wpack_id = getNextWorkPackageSeq();

						String wpc_name = "Deploy (" + dep_member_path + ")@"
								+ dep_application_name + " => "
								+ dep_platform_name;
						String request_name = dep_platform_name;
						String deploy_params = "DEPLOY (member@app@platform@env):"
								+ dep_member_id
								+ "@"
								+ dep_application_id
								+ "@"
								+ dep_platform_id
								+ "@"
								+ dep_environment_id;

						createNewWorkPackage(sub_work_plan_id, wpack_id, 0,
								"NEW", wpc_name, dep_request_id, // tab_id
								"DEPL", request_name, // tab_name,
								"DEPL", // mask_level,
								"", // tab_filter,
								"", // parallel_condition,
								"", // tab_order_stmt,
								"", // base_sql,
								deploy_params // mask_params
						);

						verMemberDepList.add(new String[] { dep_member_id,
								dep_member_path, dep_member_version,
								dep_platform_id, "" + wpack_id });

						// setting deployment order
						sql = "update tdm_work_package set execution_order=? where id=?";
						bindlist.clear();
						bindlist.add(new String[] { "INTEGER", "" + (m + 1) });
						bindlist.add(new String[] { "INTEGER", "" + wpack_id });
						execDBBindingConf(sql, bindlist);

					} // if (wpack_id==0)

					sql = "select 1 from tdm_work_package where work_plan_id=? and id=?";
					bindlist.clear();
					bindlist.add(new String[] { "INTEGER",
							"" + sub_work_plan_id });
					bindlist.add(new String[] { "INTEGER", "" + wpack_id });
					ArrayList<String[]> chWpc = getDbArrayConf(sql, 1, bindlist);

					if (chWpc.size() == 1) {
						// link request to work package
						sql = "insert into mad_request_work_package (request_id, work_plan_id, work_package_id, deployment_attempt_no)  values(?, ?, ?, ? ) ";
						bindlist.clear();
						bindlist.add(new String[] { "INTEGER", dep_request_id });
						bindlist.add(new String[] { "INTEGER",
								"" + sub_work_plan_id });
						bindlist.add(new String[] { "INTEGER", "" + wpack_id });
						bindlist.add(new String[] { "INTEGER",
								"" + dep_deployment_attempt_no });
						execDBBindingConf(sql, bindlist);
					}

				} // for (int m=0;m<memberArr.size();m++)
			} // for i=0 to depArr.size()
		} // for d=0

		// set work plan dependencies based on Application dependency
		// load all application dependencies
		sql = "select application_id, depended_application_id from mad_application_dependency";
		bindlist.clear();
		ArrayList<String[]> appDepList = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);
		ArrayList<String> appDepCheckArr = new ArrayList<String>();

		for (int i = 0; i < appDepList.size(); i++)
			appDepCheckArr.add(appDepList.get(i)[0] + "_"
					+ appDepList.get(i)[1]);

		for (int i = 0; i < appPlatWPList.size(); i++) {
			String wpl_platform_id = appPlatWPList.get(i)[0];
			String wpl_application_id = appPlatWPList.get(i)[1];
			String wpl_id = appPlatWPList.get(i)[2];

			for (int j = 0; j < appPlatWPList.size(); j++) {
				String depending_platform_id = appPlatWPList.get(j)[0];
				String depending_application_id = appPlatWPList.get(j)[1];
				String depending_wpl_id = appPlatWPList.get(j)[2];

				if (!appDepCheckArr.contains(wpl_application_id + "_"
						+ depending_application_id))
					continue;

				// check if it is already linked
				sql = "select 1 from tdm_work_plan_dependency where work_plan_id=? and depended_work_plan_id=?";
				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", "" + wpl_id });
				bindlist.add(new String[] { "INTEGER", "" + depending_wpl_id });
				ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);
				if (arr.size() == 1)
					continue;

				// link depended application's work plan
				sql = "insert into tdm_work_plan_dependency (work_plan_id, depended_work_plan_id, dependency_order) values(?,?,?) ";
				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", "" + wpl_id });
				bindlist.add(new String[] { "INTEGER", "" + depending_wpl_id });
				bindlist.add(new String[] { "INTEGER", "" + j });
				execDBBindingConf(sql, bindlist);

			} // int j
				//

		} // int i

		// remove work plans that has not work packages
		sql = "select id from tdm_work_plan wpl "
				+ " where run_type='SUB' and wplan_type='DEPL' "
				+ " and not exists "
				+ " (select 1 from tdm_work_package where work_plan_id=wpl.id)";
		bindlist.clear();
		ArrayList<String[]> wplWithNoWpcArr = getDbArrayConf(sql,
				Integer.MAX_VALUE, bindlist);

		for (int i = 0; i < wplWithNoWpcArr.size(); i++) {
			String wplan_with_no_wpc_id = wplWithNoWpcArr.get(i)[0];
			sql = "delete from tdm_work_plan_dependency where work_plan_id=? or depended_work_plan_id=?";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", wplan_with_no_wpc_id });
			bindlist.add(new String[] { "INTEGER", wplan_with_no_wpc_id });

			execDBBindingConf(sql, bindlist);

			sql = "delete from tdm_work_plan where id=?";

			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", wplan_with_no_wpc_id });

			execDBBindingConf(sql, bindlist);

		}

	}

	// *******************************************
	public void createMASKCOPYWorkPackage(int wplan_id) {
		// *******************************************

		String sql = "";
		sql = "delete from tdm_task_assignment where work_plan_id=" + wplan_id;
		execDBConf(sql);

		sql = "delete from tdm_task_summary where work_plan_id=" + wplan_id;
		execDBConf(sql);

		sql = "delete from tdm_work_package where work_plan_id=" + wplan_id;
		execDBConf(sql);

		if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK)
				|| WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK2))
			sql = "select t.id tab_id, concat(cat_name,'.',schema_name) schema_name, tab_name, t.mask_level, t.partition_used, field_name, field_type, field_size, is_pk,  \n"
					+ " mask_prof_id, calc_prof_id, rule_id, t.tab_filter, t.tab_order_stmt, t.parallel_function, t.parallel_field, t.parallel_mod,  \n"
					+ " is_conditional, condition_expr, target_owner_info,  list_field_name, copy_filter, copy_filter_bind, repeat_parameters \n"
					+ " from  \n"
					+ " tdm_work_plan wp, tdm_apps a, tdm_tabs t, tdm_fields f \n"
					+ " left join tdm_mask_prof p on f.mask_prof_id=p.id \n"
					+ " where  wp.app_id=a.id and wp.id=? \n"
					+ " and a.id=t.app_id \n"
					+ " and t.id=f.tab_id \n"
					+ " and (f.mask_prof_id>0 or length(condition_expr)>0 or is_pk='YES' or f.calc_prof_id>0) \n"
					+ " and t.mask_level not in ('DELETE') \n"
					+ " order by tab_id, \n" +
					// önce normal fieldler, sonra conditionaller, sonra da
					// javascriptler gelsin
					" if (p.rule_id='JAVASCRIPT' or p.rule_id='SQL' ,999999,1), is_conditional, f.id ";

		if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY))
			sql = "select t.id tab_id, concat(cat_name,'.',schema_name) schema_name, tab_name, t.mask_level, t.partition_used,  field_name, field_type, field_size, is_pk,   "
					+ " mask_prof_id, calc_prof_id, rule_id, t.tab_filter, t.tab_order_stmt, t.parallel_function, t.parallel_field, t.parallel_mod,  "
					+ " is_conditional, condition_expr, target_owner_info,  list_field_name, copy_filter, copy_filter_bind, repeat_parameters "
					+ " from  "
					+ " tdm_work_plan wp, tdm_apps a, tdm_tabs t, tdm_fields f "
					+ " left join tdm_mask_prof p on f.mask_prof_id=p.id "
					+ " where  wp.app_id=a.id and wp.id=? "
					+ " and a.id=t.app_id "
					+ " and t.id=f.tab_id "
					+ " and t.id not in (select rel_tab_id from tdm_tabs_rel) "
					+
					// " and (f.mask_prof_id>0 or length(condition_expr)>0 or is_pk='YES') "
					// +
					// " and f.mask_prof_id is not null " +
					" order by tab_id, " +
					// önce normal fieldler, sonra conditionaller, sonra da
					// javascriptler gelsin
					" if (p.rule_id='JAVASCRIPT' or p.rule_id='SQL' ,999999,1), is_conditional, f.id ";

		// kendi icinde tablolari cokladigindan, sadece 1 adet WPC olusturuur
		if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY2))
			sql = "select t.id tab_id, concat(cat_name,'.',schema_name) schema_name, tab_name, t.mask_level, t.partition_used,  field_name, field_type, field_size, is_pk,   "
					+ " mask_prof_id, calc_prof_id, rule_id, t.tab_filter, t.tab_order_stmt, t.parallel_function, t.parallel_field, t.parallel_mod,  "
					+ " is_conditional, condition_expr, target_owner_info,  list_field_name, copy_filter, copy_filter_bind, repeat_parameters "
					+ " from  "
					+ " tdm_work_plan wp, tdm_apps a, tdm_tabs t, tdm_fields f "
					+ " left join tdm_mask_prof p on f.mask_prof_id=p.id "
					+ " where  wp.app_id=a.id and wp.id=? "
					+ " and a.id=t.app_id "
					+ " and t.id=f.tab_id "
					+ " and t.id not in (select rel_tab_id from tdm_tabs_rel) "
					+ " limit 0,1 ";

		mylog(LOG_LEVEL_INFO,
				" ---------- Retrieve Apps/Tables/Fields  ----------------");

		ArrayList<String[]> confs = getDbArrayConfInt(sql, Integer.MAX_VALUE,
				wplan_id);
		mylog(LOG_LEVEL_INFO, " ---------- DONE  ----------------");

		String tab_id = "";
		String cat_schema_name = "";
		String cat_name = "";
		String schema_name = "";
		String tab_name = "";
		String mask_level = "";
		String partition_used = "";
		String field_name = "";
		String field_type = "";
		String field_size = "";
		String field_is_pk = "";
		String mask_prof_id = "";
		String calc_prof_id = "";
		String mask_prof_rule = "";
		String tab_filter = "";
		String tab_order_stmt = "";
		String parallel_function = "";
		String parallel_field = "";
		String parallel_mod = "";
		String is_conditional = "";
		String condition = "";
		String target_owner_info = "";
		String list_field_name = "";
		String copy_filter = "";
		String copy_filter_bind = "";
		String repeat_parameters = "";

		String next_tab_id = "";
		String mask_params = "";
		String wp_sql = " ";
		int field_no = 0;

		boolean is_filtered = false;
		String copy_partition_name = "";
		String copy_filter_sql = "";

		for (int i = 0; i < confs.size(); i++) {
			tab_id = confs.get(i)[0];
			cat_schema_name = confs.get(i)[1];

			cat_name = cat_schema_name.split("\\.")[0];
			schema_name = cat_schema_name.split("\\.")[1];

			tab_name = confs.get(i)[2];
			mask_level = confs.get(i)[3];
			partition_used = confs.get(i)[4];
			field_name = confs.get(i)[5];
			field_type = confs.get(i)[6];
			field_size = confs.get(i)[7];
			field_is_pk = confs.get(i)[8];
			mask_prof_id = confs.get(i)[9];
			calc_prof_id = nvl(confs.get(i)[10], "0");
			mask_prof_rule = confs.get(i)[11];
			tab_filter = confs.get(i)[12];
			parallel_function = confs.get(i)[14];
			parallel_field = confs.get(i)[15];
			parallel_mod = confs.get(i)[16];
			is_conditional = confs.get(i)[17];
			condition = confs.get(i)[18];
			target_owner_info = confs.get(i)[19];
			list_field_name = confs.get(i)[20];
			copy_filter = confs.get(i)[21];
			copy_filter_bind = confs.get(i)[22];
			repeat_parameters = confs.get(i)[23];

			if (i == 0
					&& (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY) || WORK_PLAN_TYPE
							.equals(WORK_PLAN_TYPE_COPY2))
					&& !nvl(copy_filter, "0").equals("0")) {
				is_filtered = true;

				sql = "select filter_type, filter_sql from tdm_copy_filter where id="
						+ copy_filter;

				ArrayList<String[]> filterArr = getDbArrayConf(sql, 1);

				if (filterArr.size() == 0)
					is_filtered = false;
				else {
					String filter_type = filterArr.get(0)[0];
					String filter_sql = filterArr.get(0)[1];

					if (filter_type.equals("BY_PARTITION"))
						try {
							copy_partition_name = copy_filter_bind.split("\\+")[0];
						} catch (Exception e) {
							e.printStackTrace();
						}
					else
						copy_filter_sql = filter_sql;
				}

			}

			ArrayList<String[]> partitionArr = new ArrayList<String[]>();

			partitionArr = (ArrayList<String[]>) hm.get("PARTITION_LIST_"+ tab_name);

			if (partitionArr == null
					|| (is_filtered && copy_partition_name.length() > 0)
					|| WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY2)) {

				partitionArr = new ArrayList<String[]>();
				partitionArr.add(new String[] { "" });
			}

			if (is_conditional.equals("YES"))
				mask_prof_id = condition;

			field_no++;
			if (mask_prof_rule.equals(MASK_RULE_GROUP)
					|| mask_prof_rule.equals(MASK_RULE_MIX)
					|| mask_prof_rule.equals(MASK_RULE_KEYMAP)) {
				tab_order_stmt = tab_order_stmt + "{" + (field_no - 1) + "="
						+ mask_prof_rule + "}";
			}

			mask_params = mask_params + field_name + ":" + field_type + ":"
					+ field_size + ":" + nvl(field_is_pk, "NO") + ":"
					+ nvl(mask_prof_rule, MASK_RULE_NONE) + ":"
					+ nvl(list_field_name, "-") + "##" + mask_prof_id + "\n";
			// wp_sql=wp_sql+", " +field_name;

			if (wp_sql.length() > 1)
				wp_sql = wp_sql + ",";
			if (field_type.equals("CALCULATED")) {
				if (!calc_prof_id.equals("0")) {
					String inner_sql = "";
					try {
						inner_sql = getDbArrayConf(
								"select js_code from tdm_mask_prof where id="
										+ calc_prof_id, 1).get(0)[0];
					} catch (Exception e) {
						e.printStackTrace();
					}

					if (inner_sql.trim().length() > 0) {
						String field_alias = field_name;
						// in oracle, field aliasses which is more than 30 chars
						// gives error. so trimmming it.
						if (field_alias.length() > 30)
							field_alias = field_alias.substring(0, 30);
						wp_sql = wp_sql + "(" + inner_sql + ") " + field_alias;
					}

				}
			} else
				wp_sql = wp_sql + addStartEndForColumn(field_name);

			try {
				next_tab_id = confs.get(i + 1)[0];
			} catch (Exception e) {
				next_tab_id = "xxxxxxxxxxxxxxxxxxxxx";
			}

			if (!tab_id.equals(next_tab_id)) {

				String parallel_condition = "";
				int paralel_task = 1;
				if (parallel_field.length() > 0) {
					try {
						paralel_task = Integer.parseInt(parallel_mod);
						if (parallel_mod.equals("1"))
							parallel_condition = "";
						else {
							if (parallel_function.equals("MOD"))
								parallel_condition = "mod(" + parallel_field
										+ "," + Integer.parseInt(parallel_mod)
										+ ")=?";
							else if (parallel_function.equals("$mod")) // mongo
								parallel_condition = parallel_field;
							else
								parallel_condition = parallel_field + " % "
										+ Integer.parseInt(parallel_mod) + "=?";
						}
					} catch (Exception e) {
						paralel_task = 0;
						parallel_condition = "";
					}
				}

				if (parallel_field.length() == 0
						|| WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY2))
					paralel_task = 1;

				String original_full_name = cat_name + "." + schema_name + "."
						+ tab_name;

				cat_name = genLib.decodeTableTargetInfo(target_owner_info,
						original_full_name, genLib.TABLE_PART_SOURCE,
						genLib.TABLE_PART_ONLY_CATALOG);
				schema_name = genLib.decodeTableTargetInfo(target_owner_info,
						original_full_name, genLib.TABLE_PART_SOURCE,
						genLib.TABLE_PART_ONLY_SCHEMA);
				tab_name = genLib.decodeTableTargetInfo(target_owner_info,
						original_full_name, genLib.TABLE_PART_SOURCE,
						genLib.TABLE_PART_ONLY_TABLE);

				/*
				 * System.out.println("decodeTableTargetInfo  returns cat_name="+
				 * cat_name+" for " + original_full_name);
				 * System.out.println("decodeTableTargetInfo  returns schema_name="
				 * +schema_name+" for " + original_full_name);
				 * System.out.println
				 * ("decodeTableTargetInfo  returns tab_name="+tab_name+" for "
				 * + original_full_name);
				 */

				if (schema_name.equals("null") || schema_name.length() == 0)
					wp_sql = " select " + wp_sql + " from \"" + tab_name + "\"";
				else
					wp_sql = " select " + wp_sql + " from "
							+ addStartEndForTable(schema_name + "." + tab_name);

				boolean alias_added=false;
				
				if (app_db_type.equals(genLib.DB_TYPE_MSSQL)) {
					wp_sql = wp_sql + " as t WITH (NOLOCK)  ";
					alias_added=true;
				}
					
				else if (app_db_type.equals(genLib.DB_TYPE_SYBASE)) {
					wp_sql = wp_sql + " as t NOHOLDLOCK  ";
					alias_added=true;
				}
					
				 
					
				
				if (is_filtered && copy_partition_name.length() > 0)
					wp_sql = wp_sql + " PARTITION( " + copy_partition_name	+ " ) ";
				else if (partition_used.equals("YES"))
					wp_sql = wp_sql + " ::PARTITION_EXPR:: ";


				if (!alias_added) wp_sql=wp_sql+" t ";
				
				StringBuilder sbFilter=new StringBuilder(tab_filter);
				tab_filter=replaceTableFilter(tab_filter,"t");
				
				for (int p = 0; p < paralel_task; p++) {
					String base_sql = wp_sql;

					if (tab_filter.replaceAll("\n|\r|\t| ", "").trim().length() > 0) {
						if (base_sql.indexOf("WHERE") == -1) {
							base_sql = base_sql + " WHERE " + tab_filter;
						} else
							base_sql = base_sql + " and " + tab_filter;
					}

					if (parallel_condition.trim().length() > 0) {
						if (base_sql.indexOf("WHERE") == -1) {
							base_sql = base_sql + " WHERE "
									+ parallel_condition.replace("?", "" + p);
						} else
							base_sql = base_sql + " and "
									+ parallel_condition.replace("?", "" + p);
					}

					if (is_filtered && copy_filter_sql.trim().length() > 0) {

						if (base_sql.indexOf("WHERE") == -1)
							base_sql = base_sql + " WHERE " + copy_filter_sql;
						else
							base_sql = base_sql + " and " + copy_filter_sql;
					}

					final int MAX_WPC_COUNT = 100;
					final int MAX_SQL_COUNT = 100;
					int part_group_size = 1;
					int part_count = partitionArr.size();
					if (part_count > MAX_WPC_COUNT)
						part_group_size = part_count / MAX_WPC_COUNT;

					if (part_group_size > MAX_SQL_COUNT)
						part_group_size = MAX_SQL_COUNT;

					String wpc_sql = "";
					int union_count = 0;

					for (int x = 0; x < partitionArr.size(); x++) {

						union_count++;
						String wp_name = schema_name + "." + tab_name;
						if (paralel_task > 1)
							wp_name = wp_name + " (" + (p + 1) + "/"
									+ paralel_task + ")";

						String partition_name = "";

						try {
							partition_name = partitionArr.get(x)[0];
						} catch (Exception e) {
							partition_name = "";
						}

						if (partition_name.length() > 0) {

							if (union_count == 1)
								wp_name = wp_name + " Partition ("
										+ partition_name + ")";

							if (union_count > 1)
								wpc_sql = wpc_sql + "\n union all \n";
							wpc_sql = wpc_sql
									+ base_sql.replace("::PARTITION_EXPR::",
											"PARTITION (" + partition_name
													+ ")");

						} // if (partition_name.length()>0)

						if ((x + 1) % part_group_size == 0
								|| x == (partitionArr.size() - 1)) {

							// mylog(wp_name + " : " + wpc_sql);

							int wpack_id = getNextWorkPackageSeq();

							if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY2)
									&& partition_name.length() > 0) {
								parallel_condition = "BY_PARTITION:"
										+ nvl(partition_name, "-");
							}

							if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK)) {
								int par = 1;

								while (true) {

									if (par > 10)
										break;

									String parStr = "${" + par + "}";

									if (!wpc_sql.contains(parStr)) {
										par++;
										continue;
									}

									String[] arr = repeat_parameters
											.split("\\|::\\|");
									String par_val = "";

									try {
										par_val = arr[par - 1];
									} catch (Exception e) {
									}

									StringBuilder dummySb = new StringBuilder(
											wpc_sql);

									int start_i = dummySb.indexOf(parStr);

									dummySb.delete(start_i,
											start_i + parStr.length());
									dummySb.insert(start_i, par_val);

									wpc_sql = dummySb.toString();

								}
							}

							createNewWorkPackage(wplan_id, wpack_id, 0, "NEW",
									wp_name, tab_id, cat_name + "."
											+ schema_name, tab_name,
									mask_level, tab_filter,
									parallel_condition.replace("?", "" + p),
									tab_order_stmt, nvl(wpc_sql, base_sql),
									mask_params);

							if (!WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY2)) {
								mylog(LOG_LEVEL_INFO,
										"Creating task table for work package  : "
												+ wpack_id + " ...");
								createNewTaskTable(wplan_id, wpack_id);
							}

							setWorkPlanStatus(wplan_id, "PREPARATION");

							union_count = 0;
							wpc_sql = "";

							// matchWorkerTask();
							matchMasterWorkPackage();
							balanceMasterProcesses();

							heartbeat(TABLE_TDM_MANAGER, 0, manager_id);
						}

					}

				}

				mask_params = "";
				wp_sql = " ";
				tab_order_stmt = "";
				field_no = 0;

			}
		}

		// set status for ready

	}
	
	
	//************************************************************************************
	String replaceTableFilter(String tab_filter, String alias) {
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

	// *******************************************
	int getRunningWorkpackageCount(int work_plan_id) {
		// *******************************************
		int ret1 = 0;
		String sql = "select count(*) " + " from tdm_work_package "
				+ " where work_plan_id=? "
				+ " and status not in ('NEW','FINISHED','FAILED') ";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + work_plan_id });

		ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);
		try {
			ret1 = Integer.parseInt(arr.get(0)[0]);
		} catch (Exception e) {
		}

		return ret1;
	}

	// *******************************************
	public void matchMasterWorkPackage() {
		// *******************************************

		if (System.currentTimeMillis() < next_master_check_ts)
			return;
		next_master_check_ts = System.currentTimeMillis()
				+ NEXT_MASTER_CHECK_INTERVAL;

		ArrayList<String[]> next_wplan_list = getRunningWorkPlanList();

		for (int p = 0; p < next_wplan_list.size(); p++) {

			int work_plan_id = Integer.parseInt(next_wplan_list.get(p)[0]);
			int master_limit = Integer.parseInt(next_wplan_list.get(p)[2]);
			String execution_type = next_wplan_list.get(p)[3];
			String work_plan_type = next_wplan_list.get(p)[4];
			

			int running_master = getActiveMasterCount(work_plan_id);

			master_limit = master_limit - running_master;
			if (master_limit < 0)
				master_limit = 0;

			if (execution_type.equals("SERIAL")) {
				int running_work_package_count = getRunningWorkpackageCount(work_plan_id);
				if (running_work_package_count > 0)
					continue;
				master_limit = 1;
			}

			ArrayList<String[]> next_master_list = getFreeMasterList(master_limit);

			if (next_master_list.size() > 0) {

				int first_free_master_id = Integer.parseInt(next_master_list.get(0)[0]);

				ArrayList<String[]> new_work_package_list = getNewWorkPackages(work_plan_id);

				if (new_work_package_list.size() > 0) {
					int next_wpc_pointer = 0;

					for (int m = 0; m < next_master_list.size(); m++) {

						int next_master_id = Integer.parseInt(next_master_list.get(m)[0]);
						int next_work_package_id = Integer.parseInt(new_work_package_list.get(next_wpc_pointer)[0]);
						int tab_id = 0;
						try{tab_id=Integer.parseInt(new_work_package_list.get(next_wpc_pointer)[3]);} catch(Exception e) {}

						mylog(LOG_LEVEL_INFO, "next_wpack_id="+ next_work_package_id);

						boolean is_assigned=assignWPack(next_master_id, work_plan_id, work_plan_type, tab_id, next_work_package_id);

						if (is_assigned) {
							mylog(LOG_LEVEL_INFO, "WPC Assigned " + next_master_id	+ " < " + next_work_package_id);
							closeWpackAssignment(next_master_id, "ASSIGNED");
						}

						next_wpc_pointer++;
						if (next_wpc_pointer == new_work_package_list.size())
							break;

					}

					// return; // only a w at a time
				}

			}

		} // for (int p=0;p<next_wplan_list.size();p++)

	}

	// *******************************************
	ArrayList<String[]> getNewWorkPackages(int work_plan_id) {
		/*
		 * String sql="select id from " + " tdm_work_package " +
		 * " where work_plan_id=? " + " and  status='NEW' " +
		 * " order by execution_order asc, last_activity_date desc";
		 */

		String sql = "select * from \n"
				+ "	( \n"
				+ "		select id , execution_order, last_activity_date, tab_id \n"
				+ "		from  \n"
				+ "		tdm_work_package  \n"
				+ "		 where work_plan_id=?  \n"
				+ "		and  status='NEW'  \n"
				+ "	union all \n"
				+
				// Rollbacked Mask Work Packages
				"		select id , execution_order, last_activity_date, tab_id \n"
				+ "		from tdm_work_package  \n"
				+ "		where work_plan_id=? \n"
				+ "		and  status='MASKING' \n"
				+ "		and exists  \n"
				+ "		( \n"
				+ "			select 1 from  \n"
				+ "			tdm_work_plan  \n"
				+ "			where id=work_plan_id and wplan_type='MASK2' and run_type='TEST:ACCURACY' \n"
				+ "		) \n"
				+ "	) a order by execution_order asc, last_activity_date desc";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + work_plan_id });
		bindlist.add(new String[] { "INTEGER", "" + work_plan_id });
		ArrayList<String[]> rec = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		if (rec != null)
			return rec;
		return new ArrayList<String[]>();
	}

	// *******************************************
	public String getWorkPlanType(int wplan_id) {
		// *******************************************
		String wplan_type = "";
		try {
			String sql = "select wplan_type from tdm_work_plan where id="
					+ wplan_id + " limit 0,1";
			wplan_type = getDbArrayConf(sql, 1).get(0)[0];
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		}

		return wplan_type;
	}

	// *******************************************
	public void createWorkPackage(int wplan_id) {
		// *******************************************

		mylog(LOG_LEVEL_INFO, "creating work packages for work plan "
				+ wplan_id + " ....");

		if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK)
				|| WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK2))
			createMASKCOPYWorkPackage(wplan_id);
		if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY)
				|| WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY2))
			createMASKCOPYWorkPackage(wplan_id);
		if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_AUTO))
			createAUTOWorkPackage(wplan_id);
		if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_DEPL))
			createDEPLWorkPackage(wplan_id);

		mylog(LOG_LEVEL_INFO, "done. creating work packages for work plan "
				+ wplan_id + " ....");

	}

	// ***************************************
	@SuppressWarnings("unchecked")
	private void extractMaskParams(String tab_id, String table_name,
			String params) {

		// fname:VARCHAR:100:NO##11
		// id:INTEGER:10:YES##0
		// lname:VARCHAR:100:NO##IF[${fname}::=::ALI::MASK(11)]||ELSE[MASK(3)]

		String[] parts = params.split("\n");

		field_names = new ArrayList<String>();
		field_types = new ArrayList<String>();
		field_sizes = new ArrayList<Integer>();
		field_PKs = new ArrayList<String>();
		field_mask_rules = new ArrayList<String>();

		for (int i = 0; i < parts.length; i++) {
			String a_mask = parts[i];

			try {
				String a_field = a_mask.split("##")[0];

				String a_field_name = a_field.split(":")[0];
				String a_field_type = a_field.split(":")[1];
				String a_field_size = a_field.split(":")[2];
				String a_field_PK = a_field.split(":")[3];
				String a_field_mask_rule = a_field.split(":")[4];
				String a_list_field_name = a_field.split(":")[5];
				// if there is FIXED add it
				try {
					a_list_field_name = a_field.split(":")[5] + ":"
							+ a_field.split(":")[6];
				} catch (Exception e) {
				}

				int a_field_size_int = 0;
				try {
					a_field_size_int = Integer.parseInt(a_field_size);
				} catch (Exception e) {
					a_field_size_int = 0;
				}

				field_names.add(a_field_name);
				field_types.add(a_field_type);
				field_sizes.add(a_field_size_int);
				field_PKs.add(a_field_PK);
				field_mask_rules.add(a_field_mask_rule);
				list_field_names.add(a_list_field_name);

				String a_mask_prof_id = a_mask.split("##")[1];

				String hmkey = "MASK_PROFILE_OF_" + table_name + "_" + tab_id
						+ "." + a_field_name.toUpperCase();
				hm.put(hmkey, a_mask_prof_id);
				hmkey = "FIELD_ID_" + table_name + "_" + tab_id + "."
						+ a_field_name.toUpperCase();
				hm.put(hmkey, i);

			} catch (Exception e) {
				break;
			}
		}

	}

	// ******************************************
	public String decodeMaskParam(String tab_id, String table_name,
			String field, String[] cols) {
		String ret1 = "-9999";

		String hmkey = "MASK_PROFILE_OF_" + table_name + "_" + tab_id + "."
				+ field.toUpperCase();

		if (hm.containsKey(hmkey)) {
			ret1 = (String) hm.get(hmkey);
			// conditional
			if (ret1.indexOf("IF[${") == 0) {

				String condition = nvl(ret1, "");
				String[] parts = condition.split("\\|\\|");
				if (parts.length > 0)
					for (int i = 0; i < parts.length; i++) {
						String[] a_part = parts[i].split("::");

						String a_stmt = a_part[0];

						// no match found, else
						if (a_stmt.indexOf("ELSE[") == 0) {
							String a_mask_prof = a_stmt.split("\\(")[1]
									.split("\\)")[0];
							// int mask_prof_id=0;
							// try{mask_prof_id=Integer.parseInt(a_mask_prof);}
							// catch(Exception e) {mask_prof_id=0;}
							// ret1=""+mask_prof_id;
							ret1 = a_mask_prof;
							// mylog("No condition matched. Catch all..");
							break;
						} else {
							String check_field = a_stmt.split("\\{")[1]
									.split("\\}")[0];
							int field_id = (int) hm.get("FIELD_ID_"
									+ table_name + "_" + tab_id + "."
									+ check_field.toUpperCase());
							// the first col is row id skipping
							String field_val = cols[field_id];

							String a_operand = a_part[1];
							String a_check_val = a_part[2];

							String a_mask_prof = a_part[3].split("\\(")[1]
									.split("\\)")[0];

							if (checkIf(field_val, a_operand, a_check_val)) {
								ret1 = a_mask_prof;
								break;
							}
						}
					}
			}
		}

		return ret1;
	}

	// *******************************************************************************
	String getDbType(String driver) {

		String ret1 = "";
		String sql = "select flexval1 from  tdm_ref where ref_type='DB_TYPE' and ref_name='"
				+ driver + "'";
		try {
			ret1 = getDbArrayConf(sql, 1).get(0)[0].toUpperCase();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return ret1;
	}

	// *******************************************************************************
	public Connection getconn(String ConnStr, String Driver, String User,
			String Pass) {
		return getconn(ConnStr, Driver, User, Pass, 3);
	}

	// *****************************************
	public Connection getconn(String ConnStr, String Driver, String User,
			String Pass, int retry_count) {
		Connection ret1 = null;
		mylog(LOG_LEVEL_INFO, "Connecting to : ");
		mylog(LOG_LEVEL_INFO, "driver     :" + Driver);
		mylog(LOG_LEVEL_INFO, "connstr    :" + ConnStr);
		mylog(LOG_LEVEL_INFO, "user       :" + User);
		mylog(LOG_LEVEL_INFO, "pass       :" + "************");

		int retry = 0;
		while (true) {
			if (retry > retry_count)
				break;
			retry++;
			try {
				Class.forName(Driver.replace("*", ""));
				Connection conn = DriverManager.getConnection(ConnStr, User,
						Pass);
				Statement stmt = conn.createStatement();

				if (connConf == null) {
					DB_TEST_SQL = "select 1 from dual";
				} else {
					String sql = "select flexval2 template from  tdm_ref where ref_type='DB_TYPE' and  ref_name='"
							+ Driver + "'";
					String template = "";

					ArrayList<String[]> arrFF = getDbArrayConf(sql, 1);

					try {
						template = arrFF.get(0)[0];
					} catch (Exception e) {
					}

					if (template.contains("|"))
						DB_TEST_SQL = template.split("\\|")[0];

					if (DB_TEST_SQL.length() == 0)
						DB_TEST_SQL = "select 1";

					app_db_type = getDbType(app_driver);
				}

				ResultSet rset = stmt.executeQuery(DB_TEST_SQL);
				while (rset.next()) {
					rset.getString(1);
					mylog(LOG_LEVEL_INFO, "Connected to DB : " + User + "@"
							+ ConnStr);

				}

				ret1 = conn;

				break;

			} catch (Exception ignore) {
				myerr("Exception@getconn : " + ignore.getMessage());
				ignore.printStackTrace();
				ret1 = null;
				mylog(LOG_LEVEL_INFO, "sleeping ...");
				sleep(5000);
			}

			mylog(LOG_LEVEL_ERROR, "Connection is failed to db : retry("
					+ retry + ") ");
			mylog(LOG_LEVEL_ERROR, "driver     :" + Driver);
			mylog(LOG_LEVEL_ERROR, "connstr    :" + ConnStr);
			mylog(LOG_LEVEL_ERROR, "user       :" + User);
			mylog(LOG_LEVEL_ERROR, "pass       :" + "************");
			mylog(LOG_LEVEL_ERROR, "Sleeping...");

			if (master_id > 0)
				heartbeat(TABLE_TDM_MASTER, master_done_count, master_id);
			if (worker_id > 0)
				heartbeat(TABLE_TDM_WORKER, worker_done_count, worker_id);

		}

		return ret1;
	}

	// **********************************************
	void setConnCharacters(Connection conn) {

		if (conn != null)
			try {
				start_ch = conn.getMetaData().getIdentifierQuoteString();
				end_ch = start_ch;

				if (app_db_type.toUpperCase().contains("ACCESS")) {
					start_ch = "[";
					end_ch = "]";
				}

				middle_ch = nvl(conn.getMetaData().getCatalogSeparator(), ".");

			} catch (Exception e) {
				start_ch = "";
				end_ch = "";
				middle_ch = ".";
				e.printStackTrace();
			}
	}

	// ********************************************
	public ArrayList<String[]> getDbArrayConfInt(String sql, int limit,
			int bindval_INT) {
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + bindval_INT });
		return getDbArrayConf(sql, limit, bindlist);
	}

	// ********************************************
	public ArrayList<String[]> getDbArrayConf(String sql, int limit) {
		return getDbArrayConf(sql, limit, null);
	}

	// ********************************************
	public ArrayList<String[]> getDbArrayConf(String sql, int limit,
			ArrayList<String[]> bindlist) {
		ArrayList<String[]> ret1 = new ArrayList<String[]>();

		PreparedStatement pstmtConf = null;
		ResultSet rsetConf = null;
		ResultSetMetaData rsmdConf = null;

		mylog(LOG_LEVEL_DEBUG, "getDbArrayConf SQL : " + sql);

		int reccnt = 0;

		try {

			if (connConf == null) {
				mylog(LOG_LEVEL_INFO, "Getting Connection ...");
				connConf = getconn(conf_connstr, conf_driver, conf_username,conf_password);
				mylog(LOG_LEVEL_INFO, "Getting Connection ...DONE");
			}

			if (pstmtConf == null) {
				pstmtConf = connConf.prepareStatement(sql);
				try{pstmtConf.setFetchSize(1000);} catch(Exception e) {}
			}
				

			// ------------------------------ end binding

			if (bindlist != null) {
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
					} else if (bind_type.equals("DATE")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.DATE);
						else {
							Date b = new Date();
							try {
								SimpleDateFormat df = new SimpleDateFormat(
										genLib.DEFAULT_DATE_FORMAT);
								b = df.parse(bind_val);
							} catch (Exception e) {
							}
							;
							Timestamp t = new Timestamp(b.getTime());
							pstmtConf.setTimestamp(i, t);
						}

					} else if (bind_type.equals("TIMESTAMP")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.TIMESTAMP);
						else {

							Timestamp ts = new Timestamp(
									System.currentTimeMillis());
							try {
								ts = new Timestamp(Long.parseLong(bind_val));
							} catch (Exception e) {
							}
							pstmtConf.setTimestamp(i, ts);
						}

					} else {
						pstmtConf.setString(i, bind_val);
					}
				}
				// ------------------------------ end binding
			} // if bindlist

			if (rsetConf == null)
				rsetConf = pstmtConf.executeQuery();
			if (rsmdConf == null)
				rsmdConf = rsetConf.getMetaData();

			int colcount = rsmdConf.getColumnCount();
			String a_field = "";
			while (rsetConf.next()) {
				reccnt++;
				if (reccnt > limit)
					break;
				String[] row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {
					try {
						a_field = rsetConf.getString(i);
						if (a_field.equals("null"))
							a_field = "";
					} catch (Exception enull) {
						a_field = "";
					}
					row[i - 1] = a_field;
				}
				ret1.add(row);
			}
		} catch (Exception ignore) {

			String msg = ignore.getMessage();
			mylog(LOG_LEVEL_ERROR, "getDbArrayConf Exception : " + msg);
			myerr("getDbArrayConf sql : " + sql);

			if (!testconn(connConf))
				connConf = null;

		} finally {
			try {
				rsmdConf = null;
			} catch (Exception e) {
			}
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

		mylog(LOG_LEVEL_DEBUG, "getDbArrayConf SQL : DONE");

		return ret1;
	}

	// ********************************************
	public String getDbSingleVal(Connection conn, String sql,
			ArrayList<String[]> bindlist) {
		String ret1 = null;

		PreparedStatement pstmt = null;

		try {
			mylog(LOG_LEVEL_DEBUG, "getDbArrayApp SQL : " + sql);
			pstmt = conn.prepareStatement(sql);
			try{pstmt.setQueryTimeout(10);} catch(Exception e) {}
			try{pstmt.setFetchSize(1000);} catch(Exception e) {}
		} catch (Exception e) {
		}
		if (pstmt == null)
			return null;

		if (bindlist != null) {
			try {
				for (int i = 1; i <= bindlist.size(); i++) {
					String[] a_bind = bindlist.get(i - 1);
					String bind_type = a_bind[0];
					String bind_val = a_bind[1];

					if (bind_type.equals("INTEGER")) {
						if (bind_val == null || bind_val.equals(""))
							pstmt.setNull(i, java.sql.Types.INTEGER);
						else
							pstmt.setInt(i, Integer.parseInt(bind_val));
					} else if (bind_type.equals("LONG")) {
						if (bind_val == null || bind_val.equals(""))
							pstmt.setNull(i, java.sql.Types.INTEGER);
						else
							pstmt.setLong(i, Long.parseLong(bind_val));
					} else if (bind_type.equals("DATE")) {
						if (bind_val == null || bind_val.equals(""))
							pstmt.setNull(i, java.sql.Types.DATE);
						else {
							Date b = new Date();
							try {
								SimpleDateFormat df = new SimpleDateFormat(
										genLib.DEFAULT_DATE_FORMAT);
								b = df.parse(bind_val);
							} catch (Exception e) {
							}
							;
							Timestamp t = new Timestamp(b.getTime());
							pstmt.setTimestamp(i, t);
						}

					} else {
						pstmt.setString(i, bind_val);
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			// ------------------------------ end binding
		} // if bindlist

		ResultSet rset = null;

		try {
			rset = pstmt.executeQuery();
		} catch (Exception e) {
		}
		if (rset == null)
			return null;

		try {
			while (rset.next()) {
				ret1 = rset.getString(1);
				if (rset.wasNull())
					ret1 = "";
				break;
			}
		} catch (Exception e) {

			String msg = e.getMessage();
			mylog(LOG_LEVEL_ERROR, "getDbSingleVal Exception : " + msg);
			myerr("getDbSingleVal SQL : " + sql);
			e.printStackTrace();

		} finally {
			try {
				rset.close();
			} catch (Exception e) {
			}
			try {
				pstmt.close();
			} catch (Exception e) {
			}
		}

		return ret1;

	}


	
	// ********************************************
	public ArrayList<String[]> getDbArrayApp(String sql, int limit,
			ArrayList<String[]> bindlist, int timeout_insecond) {
		return getDbArrayApp(sql, limit, bindlist, timeout_insecond, "", null);
	}
	// ********************************************
	public ArrayList<String[]> getDbArrayApp(String sql, int limit,
			ArrayList<String[]> bindlist, int timeout_insecond,
			String catalog_name) {
		return getDbArrayApp(sql, limit, bindlist, timeout_insecond, catalog_name, null);
	}
	// ********************************************
	public ArrayList<String[]> getDbArrayApp(String sql, int limit,
			ArrayList<String[]> bindlist, int timeout_insecond,
			String catalog_name, StringBuilder sbErr) {
		ArrayList<String[]> ret1 = new ArrayList<String[]>();

		PreparedStatement pstmtApp = null;
		ResultSet rsetApp = null;
		ResultSetMetaData rsmdApp = null;

		mylog(LOG_LEVEL_DEBUG, "getDbArrayApp SQL : " + sql);

		int reccnt = 0;

		try {

			if (connApp == null) {
				connApp = getconn(app_connstr, app_driver, app_username,app_password);
				setConnCharacters(connApp);
			}

			genLib.setCatalogForConnection(connApp, catalog_name);

			if (pstmtApp == null) {
				pstmtApp = connApp.prepareStatement(sql);
				try{pstmtApp.setFetchSize(1000);} catch(Exception e) {}
				}

			if (timeout_insecond>0)
				try {
					pstmtApp.setQueryTimeout(timeout_insecond);
				} catch (Exception e) {
	
				}

			try {pstmtApp.setFetchSize(1000);} catch (Exception e) {}
			
			// ------------------------------ end binding

			if (bindlist != null) {
				for (int i = 1; i <= bindlist.size(); i++) {
					String[] a_bind = bindlist.get(i - 1);
					String bind_type = a_bind[0];
					String bind_val = a_bind[1];

					if (bind_type.equals("INTEGER")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtApp.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtApp.setInt(i, Integer.parseInt(bind_val));
					} else if (bind_type.equals("LONG")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtApp.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtApp.setLong(i, Long.parseLong(bind_val));
					} else if (bind_type.equals("DATE")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtApp.setNull(i, java.sql.Types.DATE);
						else {
							Date b = new Date();
							try {
								SimpleDateFormat df = new SimpleDateFormat(
										genLib.DEFAULT_DATE_FORMAT);
								b = df.parse(bind_val);
							} catch (Exception e) {
							}
							;
							Timestamp t = new Timestamp(b.getTime());
							pstmtApp.setTimestamp(i, t);
						}

					} else {
						pstmtApp.setString(i, bind_val);
					}
				}
				// ------------------------------ end binding
			} // if bindlist


			if (rsetApp == null) rsetApp = pstmtApp.executeQuery();

			
			if (rsmdApp == null)
				rsmdApp = rsetApp.getMetaData();

			int colcount = rsmdApp.getColumnCount();
			String a_field = "";
			StringBuilder sbyte = new StringBuilder();
			while (rsetApp.next()) {
				reccnt++;

				String[] row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {
					int colType = rsmdApp.getColumnType(i);
					try {
						// if
						// ("DATE,TIMESTAMP".indexOf(rsmdApp.getColumnTypeName(i))
						// > -1) {
						if (colType == 91 || colType == 92 || colType == 93) {
							Date d = rsetApp.getDate(i);
							if (d == null)
								a_field = "";
							else
								a_field = new SimpleDateFormat(
										genLib.DEFAULT_DATE_FORMAT).format(d);
						}

						else if (colType == Types.BLOB
								|| colType == Types.LONGVARBINARY
								|| colType == Types.VARBINARY) {
							byte[] ablob = rsetApp.getBytes(i);
							sbyte.setLength(0);
							for (byte b : ablob)
								sbyte.append(String.format("%02x", b & 0xff));
							a_field = sbyte.toString();

							if (a_field.equals(NULL)) {
								if (rsetApp.wasNull())
									a_field = "";
							}
						}

						else {
							try {
								a_field = rsetApp.getString(i);
							} catch (Exception e) {
								a_field = "";
								e.printStackTrace();
							}
						}

						if (a_field.equals("null")) {
							if (rsetApp.wasNull())
								a_field = "";
						}
					} catch (Exception enull) {
						a_field = "";
					}
					row[i - 1] = a_field;
				}
				ret1.add(row);

				if (reccnt >= limit)
					break;
			}
		} catch (Exception ignore) {
			String msg = ignore.getMessage();
			mylog(LOG_LEVEL_ERROR, "getDbArrayApp Exception : " + msg);
			myerr("getDbArrayApp SQL : " + sql);
			ignore.printStackTrace();
			
			if (sbErr!=null) {
				
				sbErr.setLength(0);
				sbErr.append("getDbArrayApp Exception : " + msg);
			}

			if (!testconn(connApp))
				connApp = null;

		} finally {
			try {
				rsmdApp = null;
			} catch (Exception e) {
			}
			try {
				rsetApp.close();
				rsetApp = null;
			} catch (Exception e) {
			}
			try {
				pstmtApp.close();
				pstmtApp = null;
			} catch (Exception e) {
			}

		}
		return ret1;
	}

	// *********************************************
	public void closeLoopStatement() {
		try {
			rsmdLoop = null;
		} catch (Exception e) {
		}
		try {
			rsetLoop.close();
			rsetLoop = null;
		} catch (Exception e) {
		}
		try {
			pstmtLoop.close();
			pstmtLoop = null;
		} catch (Exception e) {
		}
	}

	ArrayList<String> field_names = new ArrayList<String>();
	ArrayList<String> field_types = new ArrayList<String>();
	ArrayList<Integer> field_sizes = new ArrayList<Integer>();
	ArrayList<String> field_PKs = new ArrayList<String>();
	ArrayList<String> field_mask_rules = new ArrayList<String>();
	ArrayList<String> list_field_names = new ArrayList<String>();

	boolean appdb_test_connection_need = true;

	// static final String DATE_TIMESTAMP_FINAL="DATE,TIMESTAMP";
	static final String NULL = "null";

	// ********************************************
	public ArrayList<String[]> getDbArrayAppLoop(String sql, int limit) {
		ArrayList<String[]> ret1 = new ArrayList<String[]>();

		int reccnt = 0;

		mylog(LOG_LEVEL_INFO, "start fetching for " + limit + " records.");

		try {
			if (appdb_test_connection_need || connApp == null) {
				connApp = getconn(app_connstr, app_driver, app_username,
						app_password);
				setConnCharacters(connApp);
				if (!testconn(connApp)) {
					closeApp();
					return null;
				}
				try {
					connApp.setAutoCommit(false);
				} catch (SQLException e) {
				}
				appdb_test_connection_need = false;
			}

			if (pstmtLoop == null) {
				pstmtLoop = connApp.prepareStatement(sql, ResultSet.TYPE_FORWARD_ONLY,ResultSet.CONCUR_READ_ONLY);
				try{pstmtLoop.setFetchSize(1000);} catch(Exception e) {}
			}
				
			if (rsetLoop == null) {
				rsetLoop = pstmtLoop.executeQuery();
			}

			if (rsmdLoop == null) {
				rsmdLoop = rsetLoop.getMetaData();
			}

			int colcount = rsmdLoop.getColumnCount();

			StringBuilder sbyte = new StringBuilder();
			while (rsetLoop.next()) {
				String a_field = "";

				String[] row = new String[colcount];

				for (int i = 1; i <= colcount; i++) {
					try {
						int colType = rsmdLoop.getColumnType(i);
						if (colType == 91 || colType == 92 || colType == 93) {
							Date d = rsetLoop.getDate(i);
							if (d == null)
								a_field = "";
							else
								a_field = new SimpleDateFormat(
										genLib.DEFAULT_DATE_FORMAT).format(d);
						} else if (colType == Types.BLOB
								|| colType == Types.LONGVARBINARY
								|| colType == Types.VARBINARY
								|| colType == Types.OTHER
								|| colType == Types.ARRAY
								|| colType == Types.STRUCT
								|| colType == Types.JAVA_OBJECT) {

							byte[] ablob = rsetLoop.getBytes(i);
							sbyte.setLength(0);
							for (byte b : ablob)
								sbyte.append(String.format("%02x", b & 0xff));
							a_field = sbyte.toString();

							if (a_field.equals(NULL)) {
								if (rsetLoop.wasNull())
									a_field = "";
							}
						} else
							a_field = rsetLoop.getString(i);

						if (a_field.equals(NULL)) {
							if (rsetLoop.wasNull())
								a_field = "";
						}
					} catch (Exception enull) {
						a_field = "";
					}
					row[i - 1] = a_field;

				}
				ret1.add(row);

				reccnt++;

				if (reccnt % 500 == 0) {
					mylog(LOG_LEVEL_INFO, "" + reccnt + " of " + limit
							+ " rows fetched so far..");
				}

				if (reccnt >= limit)
					break;

				if (reccnt % 5000 == 0) {
					if (last_work_plan_id > 0)
						if (getCancelFlag("tdm_master")) {
							closeLoopStatement();
							mylog(LOG_LEVEL_WARNING,
									"Cancel signal detected. Quiting...");
							stopMaster();
							return null;
						}

					if (last_work_plan_id > 0)
						if (isWorkPlanCancelled(last_work_plan_id)) {
							mylog(LOG_LEVEL_WARNING,
									"Workplan is cancelled. Going free...");
							return null;
						}

					heartbeat(TABLE_TDM_MASTER, master_done_count, master_id);

					setWpackExportCount(current_work_package_id, -1, false);

				}

			} // while
		} catch (Exception ignore) {
			String msg = ignore.getMessage();
			mylog(LOG_LEVEL_ERROR, "getDbArrayAppLoop Exception : " + msg);
			mylog(LOG_LEVEL_ERROR, "Exception@getDbArrayAppLoop msg : " + msg);
			mylog(LOG_LEVEL_ERROR, "Exception@getDbArrayAppLoop sql : " + sql);
			mylog(LOG_LEVEL_ERROR, "Exception@getDbArrayAppLoop db  : "
					+ app_connstr);

			ignore.printStackTrace();
			if (testconn(connApp))
				closeApp();
			appdb_test_connection_need = true;

			ret1 = null;
		} finally {
		}
		return ret1;
	}

	// ***************************************
	public void closeAll() {
		try {
			connConf.close();
			connConf = null;
		} catch (Exception e) {
		}

		try {
			rsmdLoop = null;
		} catch (Exception e) {
		}
		try {
			rsetLoop.close();
			rsetLoop = null;
		} catch (Exception e) {
		}
		try {
			pstmtLoop.close();
			pstmtLoop = null;
		} catch (Exception e) {
		}

		try {
			connApp.close();
			connApp = null;
		} catch (Exception e) {
		}

		if (JBASEconn != null)
			disconnectJBASE();

	}

	// ***************************************
	public void closeApp() {

		try {
			connApp.close();
		} catch (Exception e) {
		}
		connApp = null;

		if (JBASEconn != null)
			disconnectJBASE();

	}

	public void createDiscoveryTask(int p_work_plan_id, int p_work_pack_id,
			String schema_name, ArrayList<String> discList) {
		StringBuilder p_task_info = new StringBuilder();
		if (discList.size() == 0)
			return;

		for (int i = 0; i < discList.size(); i++)
			p_task_info.append(discList.get(i) + "\n");

		// createTask(p_work_plan_id, p_work_pack_id, discList.size(),
		// p_task_info, 1);

		createTask(p_work_plan_id, p_work_pack_id, discList.size(),
				p_task_info, 1, 0, "Discover " + p_task_info.toString());

	}

	// ************************************************
	public StringBuilder makeAutomatonCode(String app_id, String script_id,
			String automation_user_code) {
		StringBuilder SB_automation_user_code = new StringBuilder("");
		// **********************************************
		String[] lines = automation_user_code.split("\n|\r");
		ArrayList<String> relArr = new ArrayList<String>();

		for (int i = 0; i < lines.length; i++) {
			String line = lines[i];

			if (line.trim().length() > 0)
				SB_automation_user_code.append(line + "\n");
			if (line.trim().length() > 0 && line.contains(".runScript")
					&& line.trim().indexOf("//") != 0 && line.contains("(")
					&& line.contains(")") && line.contains(";")) {

				String sub_script = "";
				try {
					sub_script = line.split("\\)")[0].split("\\(")[1]
							.split("\"")[1].trim();
				} catch (Exception e) {
					sub_script = "";
				}

				mylog(LOG_LEVEL_INFO, "\t ... " + sub_script);

				String sql = "select id from tdm_auto_scripts where script_name='"
						+ sub_script + "'  and app_id=" + app_id;
				String sub_script_id = "";

				try {
					sub_script_id = getDbArrayConf(sql, 1).get(0)[0];
				} catch (Exception e) {
					mylog(LOG_LEVEL_ERROR, "Exception@makeAutomatonCode:"
							+ sub_script + " cannot found in repository");
					mylog(LOG_LEVEL_ERROR,
							"Exception@makeAutomatonCode:" + e.getMessage());
					continue;
				}

				String sub_script_code = "";

				if (!nvl(sub_script_id, "0").equals("0")) {
					try {
						sub_script_code = uncompress(getInfoBin(
								"tdm_auto_scripts",
								Integer.parseInt(sub_script_id), "script_body"));
						if (!relArr.contains(sub_script_id))
							relArr.add(sub_script_id);
						sub_script_code = makeAutomatonCode(app_id,
								sub_script_id, sub_script_code).toString();

					} catch (Exception e) {
						sub_script_code = "";
						e.printStackTrace();
					}

					if (sub_script_code.length() > 0) {
						SB_automation_user_code.append("\n\n");
						SB_automation_user_code
								.append("//-------------------------------------\n");
						SB_automation_user_code.append("//\t " + sub_script
								+ "\n\n");
						SB_automation_user_code
								.append("//-------------------------------------\n");
						SB_automation_user_code.append("\n\n");
						SB_automation_user_code.append(sub_script_code);
						SB_automation_user_code
								.append("\n//-------------------------------------\n");

					}

				}

			}
		}

		String sql = "delete from tdm_auto_scripts_dep where main_script_id=?";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", script_id });
		execDBBindingConf(sql, bindlist);

		for (int i = 0; i < relArr.size(); i++) {
			sql = "insert into tdm_auto_scripts_dep (main_script_id,reusable_script_id) values(?,?)";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", script_id });
			bindlist.add(new String[] { "INTEGER", relArr.get(i) });
			execDBBindingConf(sql, bindlist);

		}

		return SB_automation_user_code;
	}

	public void createAutomationTask(int p_work_plan_id, int p_work_pack_id,
			String script_id, String script_name, String app_id) {

		String automation_user_code = "";
		try {
			automation_user_code = uncompress(getInfoBin("tdm_auto_scripts",
					Integer.parseInt(script_id), "script_body"));
		} catch (Exception e) {
			automation_user_code = "";
		}

		StringBuilder SB_automation_user_code = makeAutomatonCode(app_id,
				script_id, automation_user_code);

		String AUTOMATION_MAIN_CODE = getParamByName("AUTOMATION_MAIN_CODE");

		String final_code = AUTOMATION_MAIN_CODE.replace(
				"#USERAUTOMATIONCODEHERE#", SB_automation_user_code.toString());
		final_code = final_code.replace("#USERAUTOMATIONCLASSNAME#",
				script_name);

		createTask(p_work_plan_id, p_work_pack_id, 1, new StringBuilder(
				final_code), 1, Integer.parseInt(script_id), script_name);

	}

	// *****************************************
	public void createTask(int p_work_plan_id, int p_work_pack_id,
			int p_all_count, StringBuilder p_task_info, int task_order) {
		createTask(p_work_plan_id, p_work_pack_id, p_all_count, p_task_info,
				task_order, 0, "TASK_" + task_order);
	}

	// *****************************************
	public void createTask(int p_work_plan_id, int p_work_pack_id,
			int p_all_count, StringBuilder p_task_info, int task_order,
			int script_id, String task_name) {

		if (p_all_count == 0)
			return;
		if (p_task_info.length() == 0)
			return;

		String sql = "insert into tdm_task_"
				+ p_work_plan_id
				+ "_"
				+ p_work_pack_id
				+ " (task_name, task_order, script_id, work_plan_id, work_package_id, status, all_count, task_info_zipped, last_activity_date) "
				+ " values (?, ?,?, ?,?,?,?,?, now())";

		byte[] compressed = compress(p_task_info.toString());

		PreparedStatement stmt = null;
		try {
			stmt = connConf.prepareStatement(sql);
			stmt.setString(1, task_name);
			stmt.setInt(2, task_order);
			stmt.setInt(3, script_id);
			stmt.setInt(4, p_work_plan_id);
			stmt.setInt(5, p_work_pack_id);
			stmt.setString(6, "NEW");
			stmt.setInt(7, p_all_count);
			stmt.setBytes(8, compressed);

			stmt.executeUpdate();
		} catch (Exception e) {
			mylog(LOG_LEVEL_ERROR, "Exception@createTask : " + e.getMessage());

			myerr("Exception@createTask : " + sql);

		} finally {
			try {
				stmt.close();
				stmt = null;
			} catch (Exception e) {
			}
		}

	}

	// *****************************************
	public void execDBConf(String sql) {

		mylog(LOG_LEVEL_DEBUG, "execDBConf SQL : " + sql);

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		execDBBindingConf(sql, bindlist);
	}

	// ******************************************
	public String gethostinfo() {
		String ret1 = "";
		InetAddress addr;
		try {
			addr = InetAddress.getLocalHost();
			ret1 = addr.getHostName() + " [" + addr.getHostAddress() + "]";
		} catch (Exception e) {
			ret1 = "unknown";
		}

		return ret1;
	}

	// *****************************************
	public int startMaster(String mid) {

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "";

		int id = (int) (System.currentTimeMillis() % 100000000);

		while (true) {
			sql = "select 1 from tdm_master where id=?";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", "" + id });
			ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);
			if (arr.size() == 0)
				break;
			id = (int) (System.currentTimeMillis() % 100000000);
			try {
				Thread.sleep(100);
			} catch (Exception e) {
			}
		}

		sql = "insert into tdm_master (id, master_name, status, last_heartbeat, hostname,start_date,hired_worker_count,cancel_flag) "
				+ " values (?, ?, ?,now(),?,now(),0,'NO')";

		p_mid = mid;

		String hostname = gethostinfo();

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + id });
		bindlist.add(new String[] { "STRING", "[p_id:" + java_pid + "]" });
		bindlist.add(new String[] { "STRING", "FREE" });
		bindlist.add(new String[] { "STRING", hostname });

		execDBBindingConf(sql, bindlist);

		return id;
	}

	// *****************************************
	public String startWorker(String sid) {
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "";

		int id = (int) (System.currentTimeMillis() % 100000000);

		while (true) {
			sql = "select 1 from tdm_worker where id=?";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", "" + id });
			ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);
			if (arr.size() == 0)
				break;
			id = (int) (System.currentTimeMillis() % 100000000);
			try {
				Thread.sleep(100);
			} catch (Exception e) {
			}
		}

		sql = "insert into tdm_worker (id, worker_name, status, last_heartbeat, hostname,start_date,cancel_flag) "
				+ " values (?, ?, ?, now(), ?, now(),'NO')";

		p_sid = sid;

		String hostname = gethostinfo();

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + id });
		bindlist.add(new String[] { "STRING", "[p_id:" + java_pid + "]" });
		bindlist.add(new String[] { "STRING", "FREE" });
		bindlist.add(new String[] { "STRING", hostname });

		execDBBindingConf(sql, bindlist);

		return "" + id;
	}

	// *****************************************
	public void stopMaster() {
		String sql = "delete from tdm_master where id=?";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + master_id });
		execDBBindingConf(sql, bindlist);
	}

	// *****************************************
	public void stopWorker() {

		resumeTasksByWorkerId(worker_id);

		String sql = "delete from tdm_worker where id=?";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + worker_id });
		execDBBindingConf(sql, bindlist);
	}

	// *****************************************
	public boolean getCancelFlag(String table_name) {
		boolean ret1 = false;
		if (System.currentTimeMillis() < next_cancel_flag_ts)
			return false;

		String sql = "select cancel_flag from " + table_name + " where id=?";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		if (table_name.equals("tdm_worker"))
			bindlist.add(new String[] { "INTEGER", "" + worker_id });
		else if (table_name.equals("tdm_master"))
			bindlist.add(new String[] { "INTEGER", "" + master_id });
		else
			// manager
			sql = "select cancel_flag from " + table_name;

		ArrayList<String[]> s = getDbArrayConf(sql, 1, bindlist);

		try {
			String[] arr = s.get(0);
			if (arr[0].equals("YES"))
				ret1 = true;
		} catch (Exception e) {
			// kayýtlar silinince de cancel yerine geçer
			// ancak baglanti koptuysa cancel yapýlmaz.
			if (connConf == null)
				return ret1 = false;
			else
				ret1 = true;
		}
		next_cancel_flag_ts = System.currentTimeMillis()
				+ CANCEL_FLAG_CHECK_INTERVAL;
		return ret1;
	}

	// *****************************************
	public boolean getRestartFlag(String table_name) {
		boolean ret1 = false;
		if (System.currentTimeMillis() < next_restart_flag_ts)
			return false;

		String sql = "select cancel_flag from " + table_name + " where id=?";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		if (table_name.equals("tdm_manager")) {
			sql = "select cancel_flag from " + table_name;
		} else {
			if (table_name.equals("tdm_worker"))
				bindlist.add(new String[] { "INTEGER", "" + worker_id });
			else
				bindlist.add(new String[] { "INTEGER", "" + master_id });

		}

		ArrayList<String[]> s = getDbArrayConf(sql, 1, bindlist);

		try {
			String[] arr = s.get(0);
			if (arr[0].equals("RES"))
				ret1 = true;
		} catch (Exception e) {
			// kayýtlar silinince de cancel yerine geçer
			// ancak baglanti koptuysa cancel yapýlmaz.
			return false;
		}
		next_restart_flag_ts = System.currentTimeMillis()
				+ RESTART_FLAG_CHECK_INTERVAL;
		return ret1;
	}

	// *****************************************
	public String getMasterStatus() {
		String ret1 = "";
		String sql = "select status from tdm_master where id=?";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + master_id });

		ArrayList<String[]> s = getDbArrayConf(sql, 2, bindlist);

		try {
			ret1 = s.get(0)[0];
		} catch (Exception e) {
			ret1 = "UNKNOWN";
		}
		return ret1;
	}

	// *****************************************
	public String getWorkerStatus() {
		String ret1 = "";
		String sql = "select status from tdm_worker where id=?";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + worker_id });

		ArrayList<String[]> s = getDbArrayConf(sql, 2, bindlist);

		try {
			ret1 = s.get(0)[0];
		} catch (Exception e) {
			ret1 = "UNKNOWN";
		}
		return ret1;
	}

	// *****************************************
	boolean isWorkPlanCancelled(int work_plan_id) {
		if (System.currentTimeMillis() < next_work_plan_cancel_check_ts)
			return false;
		String status = getWorkPlanStatus(work_plan_id);

		next_work_plan_cancel_check_ts = System.currentTimeMillis()
				+ NEXT_WORK_PLAN_CANCEL_CHECK_INTERVAL;

		if (status.equals("CANCELLED") || status.equals("PAUSED")
				|| status.equals("UNKNOWN"))
			return true;
		return false;
	}

	// *****************************************
	private String getWorkPlanStatus(int work_plan_id) {
		String ret1 = "";
		String sql = "select status from tdm_work_plan where id=?";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + work_plan_id });

		ArrayList<String[]> s = getDbArrayConf(sql, 1, bindlist);

		try {
			ret1 = s.get(0)[0];
		} catch (Exception e) {
			ret1 = "UNKNOWN";
		}
		return ret1;
	}

	// *****************************************
	private String getWorkPackageStatus(int work_package_id) {
		String ret1 = "";
		String sql = "select status from tdm_work_package where id=?";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + work_package_id });

		ArrayList<String[]> s = getDbArrayConf(sql, 1, bindlist);

		try {
			ret1 = s.get(0)[0];
		} catch (Exception e) {
			ret1 = "UNKNOWN";
		}
		return ret1;
	}

	// *****************************************
	public void setMasterStatus(String p_status) {
		String sql = "update tdm_master set status=? where id=?";
		if (p_status.equals("BUSY")) {
			sql = "update tdm_master set status=? where id=?";
		}
		if (p_status.equals("FREE")) {
			sql = "update tdm_master set status=?,finish_date=now() where id=?";
		}

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "STRING", p_status });
		bindlist.add(new String[] { "INTEGER", "" + master_id });

		execDBBindingConf(sql, bindlist);
	}

	// *****************************************
	public void setWorkerStatus(String p_status) {
		String sql = "update tdm_worker set status=? where id=?";
		if (p_status.equals("BUSY")) {
			sql = "update tdm_worker set status=? where id=?";
		}
		if (p_status.equals("FREE")) {
			sql = "update tdm_worker set status=?,finish_date=now() where id=?";
		}

		if (p_status.equals("ASSIGNED")) {
			sql = "update tdm_worker set status=?,last_heartbeat=now() where id=?";
		}

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "STRING", p_status });
		bindlist.add(new String[] { "INTEGER", "" + worker_id });

		execDBBindingConf(sql, bindlist);
	}

	// ************************************************
	public int getAssignedTaskCount() {
		int ret1 = 0;
		String sql = "select count(*)  from tdm_task_assignment where worker_id=? ";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + worker_id });

		try {
			ret1 = Integer.parseInt(getDbArrayConf(sql, 1, bindlist).get(0)[0]);
		} catch (Exception e) {
			e.printStackTrace();
			ret1 = 0;
		}

		return ret1;
	}

	// ***********************************************
	public void clearCloneTaskTables(int p_work_plan_id, int p_work_package_id) {
		// ***********************************************
		String sql = "";

		mylog(LOG_LEVEL_INFO, "Clearing clone  tasks for work_package : "
				+ p_work_package_id);
		sql = "select id from tdm_work_package where work_plan_id=? and original_wpack_id=?";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		bindlist.add(new String[] { "INTEGER", "" + p_work_plan_id });
		bindlist.add(new String[] { "INTEGER", "" + p_work_package_id });

		ArrayList<String[]> arr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		for (int i = 0; i < arr.size(); i++) {
			String clone_wpack_id = arr.get(i)[0];

			sql = "truncate table tdm_task_" + p_work_plan_id + "_"
					+ clone_wpack_id;
			execDBConf(sql);
		}

		sql = "truncate table tdm_task_" + p_work_plan_id + "_"
				+ p_work_package_id;
		execDBConf(sql);

		sql = "delete from tdm_work_package where original_wpack_id="
				+ p_work_package_id;
		execDBConf(sql);
	}

	// ***********************************************
	public void startWorkPackage(int p_work_plan_id, int p_work_package_id) {
		String sql = "";

		clearCloneTaskTables(p_work_plan_id, p_work_package_id);

		sql = "update tdm_work_package "
				+ " set status='EXPORTING',"
				+ " start_date=now(), "
				+ " export_count=0, "
				+ " all_count=0, "
				+ " done_count=0, "
				+ " success_count=0, "
				+ " fail_count=0, "
				+ " err_info=null, "
				+ "last_activity_date=DATE_ADD(NOW(), INTERVAL 2 HOUR) where id="
				+ p_work_package_id;
		execDBConf(sql);

		sql = "delete from tdm_task_assignment where work_package_id="
				+ p_work_package_id;
		execDBConf(sql);

		sql = "update tdm_master set last_heartbeat=DATE_ADD(NOW(), INTERVAL 2 HOUR) where id="
				+ master_id;
		execDBConf(sql);

		sql = "insert into tdm_master_log (master_id, work_package_id, status, status_date)  "
				+ " values ("
				+ master_id
				+ ", "
				+ p_work_package_id
				+ ", 'START', now())";

		execDBConf(sql);

	}

	// *****************************************
	public void startTask(int p_task_id, int p_work_plan_id,
			int p_work_package_id) {
		String sql = "update tdm_task_"
				+ p_work_plan_id
				+ "_"
				+ p_work_package_id
				+ " set status='RUNNING',start_date=now(),last_activity_date=now(), "
				+ " retry_count=retry_count+1  where id=? ";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + p_task_id });
		execDBBindingConf(sql, bindlist);

		sql = "update tdm_task_assignment "
				+ " set status='RUNNING',last_activity_date=now() "
				+ " where task_id=? and work_package_id=?";
		bindlist.add(new String[] { "INTEGER", "" + p_work_package_id });
		execDBBindingConf(sql, bindlist);

	}

	// *****************************************
	public void closeWorkPackage(int p_work_package_id, long p_duration,
			String err_info, String new_status) {

		String sql = "update tdm_work_package " + " set " + " status=?, "
				+ " master_id=null, " + " last_activity_date=now(), "
				+ " duration=?, err_info=?  " + " where id=?";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		bindlist.add(new String[] { "STRING", new_status });
		bindlist.add(new String[] { "LONG", "" + p_duration });
		bindlist.add(new String[] { "STRING", err_info });
		bindlist.add(new String[] { "INTEGER", "" + p_work_package_id });

		execDBBindingConf(sql, bindlist);

	}

	// *****************************************
	public void finishWorkPackage(int p_work_package_id, long p_duration,
			String p_err_info) {

		String sql = "update tdm_work_package " + " set " + " master_id=null, "
				+ " status='FINISHED', " + " last_activity_date=now(), "
				+ " duration=?, err_info=?  " + " where id=?";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		bindlist.add(new String[] { "LONG", "" + p_duration });
		bindlist.add(new String[] { "STRING", p_err_info });
		bindlist.add(new String[] { "INTEGER", "" + p_work_package_id });

		execDBBindingConf(sql, bindlist);

	}

	// *****************************************

	public void finishWorkPackageasEmpty(int p_work_package_id) {
		String sql = "update tdm_work_package "
				+ " set "
				+ " master_id=null, "
				+ " last_activity_date=now(),  "
				+ " status='FINISHED',  "
				+ " duration=0, export_count=0, all_count=0, done_count=0, success_count=0, fail_count=0 "
				+ " where id=?";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		bindlist.add(new String[] { "INTEGER", "" + p_work_package_id });

		execDBBindingConf(sql, bindlist);

	}

	// *****************************************
	public void finishTask(int p_task_id, int p_work_package_id,
			int p_work_plan_id, long p_done, long p_success, long p_fail,
			long p_duration) {
		String sql = "";

		String status = "FINISHED";
		if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK) && (p_success == 0)
				&& (p_done > 0))
			status = "FAILED";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		sql = "delete from tdm_task_assignment where  work_package_id=? and task_id=?";
		bindlist.add(new String[] { "INTEGER", "" + p_work_package_id });
		bindlist.add(new String[] { "INTEGER", "" + p_task_id });
		execDBBindingConf(sql, bindlist);

		sql = "update tdm_task_"
				+ p_work_plan_id
				+ "_"
				+ p_work_package_id
				+ " set status=?,end_date=now(),last_activity_date=now(), "
				+ " done_count=?,success_count=?,fail_count=?,duration=?, worker_id=null "
				+ " where id=?";
		bindlist = new ArrayList<String[]>();

		bindlist.add(new String[] { "STRING", "" + status });
		bindlist.add(new String[] { "INTEGER", "" + p_done });
		bindlist.add(new String[] { "INTEGER", "" + p_success });
		bindlist.add(new String[] { "INTEGER", "" + p_fail });
		bindlist.add(new String[] { "LONG", "" + p_duration });
		bindlist.add(new String[] { "INTEGER", "" + p_task_id });

		execDBBindingConf(sql, bindlist);

		if (err_info.length() > 0 || WORK_PLAN_TYPE.equals("AUTO")) {
			setBinInfo("tdm_task_" + p_work_plan_id + "_" + p_work_package_id,
					p_task_id, "log_info_zipped", log_info);
			if (err_info.length() > 0)
				setBinInfo("tdm_task_" + p_work_plan_id + "_"
						+ p_work_package_id, p_task_id, "err_info_zipped",
						err_info);
		}

	}

	// ********************************************
	void setBinInfo(String table_name, int id, String field_name,
			StringBuilder sb_info) {

		if (sb_info.length() == 0)
			return;

		byte[] compressed = compress(sb_info.toString());

		String sql = "update " + table_name + " set " + field_name
				+ " =? where id=?";
		PreparedStatement stmt = null;
		try {
			stmt = connConf.prepareStatement(sql);
			stmt.setBytes(1, compressed);
			stmt.setInt(2, id);
			stmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				stmt.close();
				stmt = null;
			} catch (Exception e) {
			}
		}
	}

	// ********************************************
	void setBinInfo(String table_name, int id, String field_name,
			byte[] byte_info) {

		if (byte_info == null || byte_info.length == 0)
			return;

		byte[] compressed = compress(byte_info);
		// byte[] compressed=byte_info;

		String sql = "update " + table_name + " set " + field_name
				+ " =? where id=?";
		PreparedStatement stmt = null;
		try {
			stmt = connConf.prepareStatement(sql);
			stmt.setBytes(1, compressed);
			stmt.setInt(2, id);
			stmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				stmt.close();
				stmt = null;
			} catch (Exception e) {
			}
		}
	}

	// *****************************************
	static final String[] table_list = new String[] { "tdm_manager",
			"tdm_master", "tdm_worker" };

	boolean is_heartbeat_busy = false;

	public void heartbeat(int table_id, long rec_cnt, int id) {
		if (is_heartbeat_busy)
			return;

		if ((System.currentTimeMillis() - last_heartbeat) > HEARTBEAT_INTERVAL) {
			is_heartbeat_busy = true;

			last_heartbeat = System.currentTimeMillis();

			try {
				work_done_count = rec_cnt;

				String sql = "";

				String table = table_list[table_id - 1];

				ArrayList<String[]> bindlist = new ArrayList<String[]>();

				sql = "update " + table + " set last_heartbeat=?  where id=?";
				if (table.equals("tdm_manager")) {
					sql = "update " + table + " set last_heartbeat=?";
					bindlist.add(new String[] { "TIMESTAMP",
							"" + System.currentTimeMillis() });
				} else {
					bindlist.add(new String[] { "TIMESTAMP",
							"" + System.currentTimeMillis() });
					bindlist.add(new String[] { "INTEGER", "" + id });
				}

				execDBBindingConf(sql, bindlist);

				if (table.equals("tdm_manager"))
					mylog(LOG_LEVEL_INFO, table + "[j.pid=" + java_pid
							+ "] heap:%" + heapUsedRate() + " heartbeat...@"
							+ (new Date()));
				else
					mylog(LOG_LEVEL_INFO, table + "[j.pid=" + java_pid
							+ "] heap:%" + heapUsedRate() + " heartbeat...@"
							+ (new Date()) + "=> " + rec_cnt
							+ " recs processed...");

			} catch (Exception e) {
				e.printStackTrace();
			}

		}

		is_heartbeat_busy = false;
	}

	// ***************************************
	public boolean execDBBindingConf(String sql, ArrayList<String[]> bindlist) {

		boolean ret1 = true;

		if (connConf == null) {
			connConf = getconn(conf_connstr, conf_driver, conf_username,
					conf_password);
		}

		StringBuilder using = new StringBuilder();
		try {
			pstmt_execbind = connConf.prepareStatement(sql);

			if (bindlist != null)
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
							pstmt_execbind
									.setInt(i, Integer.parseInt(bind_val));
					} else if (bind_type.equals("LONG")) {
						if (bind_val == null || bind_val.equals(""))
							pstmt_execbind.setNull(i, java.sql.Types.INTEGER);
						else
							pstmt_execbind.setLong(i, Long.parseLong(bind_val));
					} else if (bind_type.equals("DATE")) {
						if (bind_val == null || bind_val.equals(""))
							pstmt_execbind.setNull(i, java.sql.Types.DATE);
						else {
							Date d = new SimpleDateFormat(
									genLib.DEFAULT_DATE_FORMAT).parse(bind_val);
							java.sql.Date date = new java.sql.Date(d.getTime());
							pstmt_execbind.setDate(i, date);
						}
					} else if (bind_type.equals("TIMESTAMP")) {
						if (bind_val == null || bind_val.equals(""))
							pstmt_execbind.setNull(i, java.sql.Types.TIMESTAMP);
						else {
							Timestamp ts = new Timestamp(
									System.currentTimeMillis());
							try {
								ts = new Timestamp(Long.parseLong(bind_val));
							} catch (Exception e) {
								e.printStackTrace();
							}
							pstmt_execbind.setTimestamp(i, ts);
						}
					}
					/*
					 * else if (bind_type.equals("ROWID")) {
					 * 
					 * ROWID r = new ROWID();
					 * 
					 * 
					 * r.setBytes(bind_val.getBytes());
					 * pstmt_execbind.setRowId(i, r); r = null; }
					 */
					else {
						pstmt_execbind.setString(i, bind_val);
					}
				}

			mylog(LOG_LEVEL_DEBUG,
					"Executing SQL : " + sql + " using " + using.toString());

			pstmt_execbind.executeUpdate();

			mylog(LOG_LEVEL_DEBUG,
					"DONE : " + sql + " using " + using.toString());

			if (!connConf.getAutoCommit())
				connConf.commit();

		} catch (Exception e) {
			mylog(LOG_LEVEL_ERROR,
					"Exception@execDBBindingConf : " + e.getMessage());
			myerr("while " + "Executing SQL : " + sql + " using "
					+ using.toString());

			if ((!testconn(connConf)))
				connConf = null;

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

	// ***************************************
	public static byte[] hexStringToByteArray(String s) {
		int len = s.length();
		byte[] data = new byte[len / 2];
		for (int i = 0; i < len; i += 2) {
			data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4) + Character
					.digit(s.charAt(i + 1), 16));
		}
		return data;
	}

	boolean isBatchUpdateSupported = true;

	// ***************************************
	public int execDBBindingApp2(String sql, ArrayList<String[]> bindlist,
			int binding_size) {

		/*
		 * mylog(" /////////////  sql : " + sql);
		 * mylog(" /////////////  bindlist.size : " + bindlist.size());
		 * mylog(" /////////////  binding_size : " + binding_size);
		 */
		int ret1 = 0;
		ArrayList<String> usingArr = new ArrayList<String>();

		if (connApp == null) {
			connApp = getconn(app_connstr, app_driver, app_username,
					app_password);
			setConnCharacters(connApp);
			try {
				connApp.setAutoCommit(false);
			} catch (SQLException e) {
			}
			try {
				isBatchUpdateSupported = connApp.getMetaData()
						.supportsBatchUpdates();
			} catch (SQLException e) {
				isBatchUpdateSupported = false;
			}

			// isBatchUpdateSupported=false;

		}

		try {
			pstmt_execbind = connApp.prepareStatement(sql);

			pstmt_execbind.setQueryTimeout(120);

			int field_no = 0;
			StringBuilder using = new StringBuilder();

			mylog(LOG_LEVEL_DEBUG, "SQL : " + sql);

			for (int i = 1; i <= bindlist.size(); i++) {

				field_no++;
				String[] a_bind = bindlist.get(i - 1);
				String bind_type = a_bind[0];
				String bind_val = a_bind[1];

				// mylog(" ////////////////////  bind("+i+") "+bind_type+
				// " => "+bind_val);

				if (field_no > 1)
					using.append(", ");
				using.append("{" + bind_val + "}");

				if (bind_type.equals("INTEGER")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind
								.setNull(field_no, java.sql.Types.INTEGER);
					else {

						try {
							int int_val = Integer.parseInt(bind_val);
							pstmt_execbind.setInt(field_no, int_val);
						} catch (Exception e1) {
							try {
								float f_val = Float.parseFloat(bind_val
										.replace(',', '.'));
								pstmt_execbind.setFloat(field_no, f_val);
							} catch (Exception e2) {
								try {
									double d_val = Double.parseDouble(bind_val
											.replace(',', '.'));
									pstmt_execbind.setDouble(field_no, d_val);
								} catch (Exception e3) {
									e3.printStackTrace();
								}
							}
						}

					} // if (bind_val == null || bind_val.equals(""))

				} else if (bind_type.equals("LONG")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind
								.setNull(field_no, java.sql.Types.INTEGER);
					else
						pstmt_execbind.setLong(field_no,
								Long.parseLong(bind_val));
				} else if (bind_type.equals("DATE")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(field_no, java.sql.Types.DATE);
					else {
						Date d = new SimpleDateFormat(
								genLib.DEFAULT_DATE_FORMAT).parse(bind_val);
						java.sql.Date date = new java.sql.Date(d.getTime());
						pstmt_execbind.setDate(field_no, date);
					}
				} else if (bind_type.equals("BLOB")) {
					pstmt_execbind.setBytes(field_no,
							hexStringToByteArray(bind_val));

				} else if (bind_type.equals("ROWID")) {

					if (app_db_type.equals(genLib.DB_TYPE_ORACLE)) {
						ROWID r = new ROWID();
						r.setBytes(bind_val.getBytes());
						pstmt_execbind.setRowId(field_no, r);
						r = null;
					}

					if (app_db_type.equals(genLib.DB_TYPE_DB2)) {
						byte[] byterowid = hexStringToByteArray(bind_val);
						pstmt_execbind.setBytes(field_no, byterowid);
					}
				} else {

					pstmt_execbind.setString(field_no, bind_val);
				}

				if (field_no == binding_size) {
					field_no = 0;
					usingArr.add(using.toString());
					mylog(LOG_LEVEL_DEBUG, "Using : " + using.toString());
					using = new StringBuilder();

					if (isBatchUpdateSupported) {
						pstmt_execbind.addBatch();

					} else {
						boolean res = false;

						try {
							res = pstmt_execbind.execute();
						} catch (SQLException se) {
							mylog(LOG_LEVEL_ERROR,
									"Exception@execDBBindingApp2 MESSAGE   : "
											+ se.getMessage());
							mylog(LOG_LEVEL_ERROR,
									"Exception@execDBBindingApp2 ERRCODE   : "
											+ se.getErrorCode());
							mylog(LOG_LEVEL_ERROR,
									"Exception@execDBBindingApp2 SQLSTAT   : "
											+ se.getSQLState());
							mylog(LOG_LEVEL_ERROR,
									"Exception@execDBBindingApp2 STATEMENT : "
											+ sql);
							mylog(LOG_LEVEL_ERROR,
									"Exception@execDBBindingApp2 BINDLIST  : "
											+ using.toString());
							res = false;
							se.printStackTrace();
						} catch (Exception e) {
							mylog(LOG_LEVEL_ERROR,
									"Exception@execDBBindingApp2 : "
											+ e.getMessage());
							mylog(LOG_LEVEL_ERROR, "Exception@SQL : " + sql);
							res = false;
							e.printStackTrace();
						}

						if (res)
							ret1++;

						pstmt_execbind.close();
						pstmt_execbind = connApp.prepareStatement(sql);
						pstmt_execbind.setQueryTimeout(120);
					}

				}

			} // for (int i = 1; i <= bindlist.size(); i++)

			if (isBatchUpdateSupported) {
				ret1 = 0;
				int[] updates = pstmt_execbind.executeBatch();
				for (int u = 0; u < updates.length; u++)
					if (updates[u] >= 0)
						ret1++;

			}

		} catch (BatchUpdateException buex) {
			mylog(LOG_LEVEL_ERROR, "Contents of BatchUpdateException:");
			myerr("Contents of BatchUpdateException:");

			int upd_count = 0;

			int[] cnts = buex.getUpdateCounts();
			for (int a = 0; a < cnts.length; a++)
				if (cnts[a] > 0)
					upd_count++;

			ret1 = upd_count;

			// try {upd_count = pstmt_execbind.getUpdateCount();} catch
			// (SQLException e1) {upd_count=0;}
			// if (upd_count<0) upd_count=0;

			SQLException ex = buex.getNextException();

			while (ex != null) {

				String using = null;
				try {
					using = usingArr.get(upd_count);
				} catch (Exception e) {
					using = "Unknown";
				}

				mylog(LOG_LEVEL_ERROR, "BatchUpdateException@SQL        : "
						+ sql);
				mylog(LOG_LEVEL_ERROR, "BatchUpdateException@Using      : "
						+ using);
				mylog(LOG_LEVEL_ERROR, "BatchUpdateException@Message    : "
						+ ex.getMessage());
				mylog(LOG_LEVEL_ERROR, "BatchUpdateException@SQLSTATE   : "
						+ ex.getSQLState());
				mylog(LOG_LEVEL_ERROR, "BatchUpdateException@Errorcode  : "
						+ ex.getErrorCode());

				ex = ex.getNextException();
			}

			if ((!testconn(connApp)))
				connApp = null;

		} catch (Exception e) {

			ret1 = 0;

			mylog(LOG_LEVEL_ERROR,
					"Exception@execDBBindingApp : " + e.getMessage());

			myerr("Exception@execDBBindingApp : " + e.getMessage());

			if (!testconn(connApp))
				closeApp();

			e.printStackTrace();

		} finally {
			try {

				if (isBatchUpdateSupported && ret1 == 0)
					ret1 = pstmt_execbind.getUpdateCount();
				if (ret1 < 0)
					ret1 = 0;

				uncommitted_block_count++;
				if (uncommitted_block_count > COMMIT_LENGTH) {
					uncommitted_block_count = 0;
					if (!connApp.getAutoCommit()) {
						connApp.commit();
						// mylog("Committed :)");
					}
					if (isBatchUpdateSupported)
						pstmt_execbind.clearBatch();
				}

				try {
					pstmt_execbind.close();
					pstmt_execbind = null;
					usingArr = null;
				} catch (Exception e) {
				}

			} catch (Exception e) {
			}
		}

		try {
			if (!pstmt_execbind.isClosed()) {
				pstmt_execbind.close();
				pstmt_execbind = null;
				usingArr = null;
			}
		} catch (Exception e) {
		}

		return ret1;
	}

	// ******************************************************
	void loadRunParams(int curr_work_plan_id) {
		loadRunParams(curr_work_plan_id, false);
	}

	long last_work_plan_use_ts = 0;

	// ******************************************************
	private void loadRunParams(int curr_work_plan_id, boolean force_new_appconn) {

		if (last_work_plan_id != curr_work_plan_id || force_new_appconn
				|| last_work_plan_use_ts < System.currentTimeMillis()) {
			last_work_plan_use_ts = System.currentTimeMillis() + 300000;

			mylog(LOG_LEVEL_INFO,
					"Loading work plan parameters for work plan : "
							+ curr_work_plan_id);

			hm.clear();
			KeyMapHash.clear();

			if (JBASEconn != null)
				disconnectJBASE();
			if (MONGOclient != null)
				disconnectMONGO();

			String sql = " select " + " WPLAN_TYPE, " + " REC_SIZE_PER_TASK, "
					+ " TASK_SIZE_PER_WORKER, " + " BULK_UPDATE_REC_COUNT, "
					+ " COMMIT_LENGTH, " + " UPDATE_WPACK_COUNTS_INTERVAL, "
					+ " run_type, " + " env_id, " + " target_env_id, "
					+ " email_address, " + " execution_type, "
					+ " on_error_action " + " from tdm_work_plan  "
					+ " where id=?" + " limit 0,1";

			ArrayList<String[]> arr = getDbArrayConfInt(sql, 1,
					curr_work_plan_id);

			try {
				WORK_PLAN_TYPE = arr.get(0)[0];
			} catch (Exception e) {
				WORK_PLAN_TYPE = "";
			}

			try {
				REC_SIZE_PER_TASK = Integer.parseInt(arr.get(0)[1]);
			} catch (Exception e) {
				REC_SIZE_PER_TASK = 1000;
			}

			try {
				TASK_SIZE_PER_WORKER = Integer.parseInt(arr.get(0)[2]);
			} catch (Exception e) {
				TASK_SIZE_PER_WORKER = 5;
			}

			try {
				BULK_UPDATE_REC_COUNT = Integer.parseInt(arr.get(0)[3]);
			} catch (Exception e) {
				BULK_UPDATE_REC_COUNT = 50;
			}

			try {
				COMMIT_LENGTH = Integer.parseInt(arr.get(0)[4]);
			} catch (Exception e) {
				COMMIT_LENGTH = 20;
			}

			if (REC_SIZE_PER_TASK > 50000)
				REC_SIZE_PER_TASK = 50000;
			if (REC_SIZE_PER_TASK < 100)
				REC_SIZE_PER_TASK = 100;

			if (TASK_SIZE_PER_WORKER > 100)
				TASK_SIZE_PER_WORKER = 100;
			if (TASK_SIZE_PER_WORKER < 1)
				TASK_SIZE_PER_WORKER = 1;

			if (BULK_UPDATE_REC_COUNT > 100)
				BULK_UPDATE_REC_COUNT = 100;
			if (BULK_UPDATE_REC_COUNT < 1)
				BULK_UPDATE_REC_COUNT = 1;

			if (COMMIT_LENGTH > 100)
				COMMIT_LENGTH = 100;
			if (COMMIT_LENGTH < 10)
				COMMIT_LENGTH = 10;

			if (UPDATE_COUNT_AND_STATUS_ALL_INTERVAL > 300000)
				UPDATE_COUNT_AND_STATUS_ALL_INTERVAL = 300000;
			if (UPDATE_COUNT_AND_STATUS_ALL_INTERVAL < 120000)
				UPDATE_COUNT_AND_STATUS_ALL_INTERVAL = 120000;

			RUN_TYPE = arr.get(0)[6];

			String env_id = arr.get(0)[7];

			if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY) && (worker_id > 0))
				env_id = arr.get(0)[8];

			WORK_PLAN_MAIL_ADDRESS = arr.get(0)[9].trim();

			EXECUTION_TYPE = arr.get(0)[10];
			ON_ERROR_ACTION = arr.get(0)[11];

			if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY)
					&& RUN_TYPE.equals("ACTUAL:ACCURACY") && worker_id > 0)
				loadRelationInfo(curr_work_plan_id);

			if (!WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_AUTO)
					&& !WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_DEPL)) {
				sql = "select e.db_driver, e.db_connstr, e.db_username, e.db_password from tdm_envs e where id=" + env_id;
				arr = getDbArrayConf(sql, 1);
				
				if (arr.size()==1) {
					app_driver = arr.get(0)[0];
					app_connstr = arr.get(0)[1];
					app_username = arr.get(0)[2];
					app_password =genLib.passwordDecoder(arr.get(0)[3]) ;
				}

				

				app_db_type = getDbType(app_driver);
				if (app_db_type.toUpperCase().contains("MONGO"))
					is_mongo = true;

				if (is_mongo) {
					start_ch = "";
					end_ch = "";
					middle_ch = ".";

				} else {
					appdb_test_connection_need = false;
					connApp = getconn(app_connstr, app_driver, app_username, app_password);
					setConnCharacters(connApp);
				}

				mylog(LOG_LEVEL_INFO, "Changing db environment to : "
						+ app_connstr);

			} // if (!WORK_PLAN_TYPE.equals("AUTO"))

			closeApp();
			disconnectMONGO();

			last_work_plan_id = curr_work_plan_id;

		}

	}

	// ******************************************
	@SuppressWarnings("unchecked")
	private void loadRelationInfo(int work_plan_id) {
		mylog(LOG_LEVEL_INFO, "Loading relation info ...");
		String sql = "select  \n"
				+ "   concat(ptab.schema_name,'.',ptab.tab_name) master_tab,  \n"
				+ "	pk_fields,  \n"
				+ "	concat(ctab.schema_name,'.',ctab.tab_name) child_tab,  \n"
				+ "	rel_on_fields  \n"
				+ "	 from   \n"
				+ "	tdm_tabs_rel r, tdm_tabs ptab, tdm_tabs ctab   \n"
				+ "	where r.tab_id in  \n"
				+ " (select id from tdm_tabs where app_id=(select app_id from tdm_work_plan where id="
				+ work_plan_id + ")) \n" + "	and r.tab_id=ptab.id  \n"
				+ "	and r.rel_tab_id=ctab.id";
		mylog(LOG_LEVEL_DEBUG, sql);
		ArrayList<String[]> relArr = getDbArrayConf(sql, Integer.MAX_VALUE);

		String target_owner_info = "";
		try {
			sql = "select target_owner_info from tdm_work_plan where id="
					+ work_plan_id;
			target_owner_info = getDbArrayConf(sql, 1).get(0)[0];
		} catch (Exception e) {
		}

		for (int i = 0; i < relArr.size(); i++) {
			String master_table = extractCopyTarget(target_owner_info,
					relArr.get(i)[0]);
			String pk_fields = relArr.get(i)[1];
			String child_table = extractCopyTarget(target_owner_info,
					relArr.get(i)[2]);
			String rel_on_fields = relArr.get(i)[3];

			String[] FKfields = rel_on_fields.split(",");
			String[] PKfields = pk_fields.split(",");

			for (int f = 0; f < FKfields.length; f++) {
				String a_FK_field = "";
				String a_PK_field = "";

				a_FK_field = FKfields[f];
				try {
					a_PK_field = PKfields[f];
				} catch (Exception e) {
					a_PK_field = a_FK_field;
				}

				mylog(LOG_LEVEL_DEBUG, "    ...COPY_PARENT_OF_" + child_table
						+ "." + a_FK_field + "=" + master_table + "."
						+ a_PK_field);

				hm.put("COPY_PARENT_OF_" + child_table + "." + a_FK_field,
						master_table + "." + a_PK_field);
				hm.put("COPY_HAS_CHILD_" + master_table, "YES");
			}

		}

		mylog(LOG_LEVEL_INFO, "Loading relation info ...DONE");

	}

	// *****************************************
	void text2file(String text, String filepath) {
		BufferedWriter out = null;

		File f = new File(filepath);
		if (f.exists())
			f.delete();

		try {
			out = new BufferedWriter(new OutputStreamWriter(
					new FileOutputStream(filepath), "UTF-8"));
			out.append(text);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				out.close();
			} catch (Exception e) {
			}
		}
	}

	// *********************************************
	private void clearGlobalArrays() {
		// *********************************************

		if (globalArr.size() == 0)
			return;

		int before_heap_size = heapUsedRate();
		int before_arr_size = globalArr.size();

		mylog(LOG_LEVEL_DEBUG, "*******************************************");
		mylog(LOG_LEVEL_DEBUG, " CLEARING THE ARRAYS   ");
		mylog(LOG_LEVEL_DEBUG, "*******************************************");
		long start_ts = System.currentTimeMillis();

		int null_id = 0;

		for (int i = 0; i < globalArr.size(); i++) {
			if (globalArr.get(i) != null) {
				globalArr.set(null_id, globalArr.get(i));
				null_id++;
			}

			if (i % 10000 == 0) {
				heartbeat(TABLE_TDM_MASTER, 0, master_id);
				// mylog("clearing : " +i + " cleared : " + cleared);
			}

		}

		if (null_id > 0) {

			globalArr.subList(null_id, globalArr.size()).clear();
			globalArr.trimToSize();

			globalGroupIdArr.clear();
			globalGroupIdArr.trimToSize();
			globalSorthm.clear();

			Runtime.getRuntime().gc();
			System.gc();
		}

		mylog(LOG_LEVEL_INFO,
				"   Clearance is ok. Took  ["
						+ (System.currentTimeMillis() - start_ts)
						+ "] msecs   ");
		mylog(LOG_LEVEL_INFO, "   cleared                  : "
				+ (before_arr_size - globalArr.size()));
		mylog(LOG_LEVEL_INFO, "------------------------------------------");
		mylog(LOG_LEVEL_INFO, "   Before Heap Usage is %   : "
				+ before_heap_size);
		mylog(LOG_LEVEL_INFO, "   Befor globalArray size   : "
				+ before_arr_size);
		mylog(LOG_LEVEL_INFO, "------------------------------------------");
		mylog(LOG_LEVEL_INFO, "   After Heap Usage is %    :" + heapUsedRate());
		mylog(LOG_LEVEL_INFO,
				"   globalArray size :       : " + globalArr.size());
		mylog(LOG_LEVEL_INFO, "*******************************************");

	}

	HashMap<String, Integer> globalSorthm = new HashMap<String, Integer>();
	ArrayList<String[]> globalArr = new ArrayList<String[]>();
	ArrayList<ArrayList<Integer>> globalGroupIdArr = new ArrayList<ArrayList<Integer>>();

	// *****************************************************
	public ArrayList<Integer[]> groupAndSortArrayList(ArrayList<String[]> arr,
			ArrayList<Integer> fieldarr, int keymap_field_id,
			boolean force_sort_all) {
		// *****************************************************
		int start_loop = globalArr.size();

		if (!force_sort_all & heapUsedRate() > 60) {

			clearGlobalArrays();
			start_loop = 0;

		} // if (heapUsedRate()>80)

		for (int i = 0; i < arr.size(); i++) {
			globalArr.add(arr.get(i));
		}

		int end_loop = globalArr.size();
		StringBuilder hkey_bucket_id = new StringBuilder();

		// ------------------------------------------------------------------
		for (int i = start_loop; i < end_loop; i++) {
			String[] arec = globalArr.get(i);

			if (arec != null) {

				// StringBuilder hkey_bucket_id=new StringBuilder();
				hkey_bucket_id.setLength(0);

				hkey_bucket_id.append("BKID_");
				for (int f = 0; f < fieldarr.size(); f++) {
					int fid = fieldarr.get(f);

					if (keymap_field_id < 0)
						hkey_bucket_id.append(arec[fid]);
					else
						hkey_bucket_id.append(Math.abs(arec[fid].hashCode()
								% (KEYVAL_FILE_CHUNK_SIZE / 10)));
					hkey_bucket_id.append("_");
				}

				Object obj = globalSorthm.get(hkey_bucket_id.toString());

				Integer bucket_id = 0;

				if (obj == null) {
					bucket_id = globalGroupIdArr.size();
					globalSorthm.put(hkey_bucket_id.toString(), bucket_id);
					ArrayList<Integer> newL = new ArrayList<Integer>();
					newL.add(i);
					globalGroupIdArr.add(newL);
				} else {
					bucket_id = (Integer) obj;
					ArrayList<Integer> newL = globalGroupIdArr.get(bucket_id);
					newL.add(i);
					globalGroupIdArr.set(bucket_id, newL);

				}

			} // if (arec!=null)

		} // for i

		ArrayList<Integer[]> sortArr = new ArrayList<Integer[]>();

		for (int i = 0; i < globalGroupIdArr.size(); i++) {
			ArrayList<Integer> newL = globalGroupIdArr.get(i);
			int TASK_SIZE_LIMIT = newL.size()
					- (newL.size() % REC_SIZE_PER_TASK);

			if (force_sort_all)
				TASK_SIZE_LIMIT = newL.size();

			if (!force_sort_all && TASK_SIZE_LIMIT == 0) {
				int none_sort_count = 0;
				if (globalSorthm.containsKey("NONE_SORT_COUNT_OF_" + i))
					none_sort_count = globalSorthm.get("NONE_SORT_COUNT_OF_"
							+ i);

				if (none_sort_count >= 10 && newL.size() >= 10)
					TASK_SIZE_LIMIT = newL.size();
				else
					globalSorthm.put("NONE_SORT_COUNT_OF_" + i,
							none_sort_count + 1);
			}

			if (TASK_SIZE_LIMIT > 0)
				globalSorthm.put("NONE_SORT_COUNT_OF_" + i, 0);

			if (heapUsedRate() > 90)
				TASK_SIZE_LIMIT = newL.size();

			for (int j = 0; j < TASK_SIZE_LIMIT; j++) {
				// int id=newL.get(0);
				// newL.remove(0);
				int id = newL.get(j);
				int new_group = 0;
				if (j == 0)
					new_group = 1;
				sortArr.add(new Integer[] { id, new_group });
			} // for

			if (TASK_SIZE_LIMIT > 0) {
				newL.subList(0, TASK_SIZE_LIMIT).clear();
				newL.trimToSize();
			}

			globalGroupIdArr.set(i, newL);
		} // for

		mylog(LOG_LEVEL_INFO,
				" ... globalGroupIdArr.size=" + globalGroupIdArr.size()
						+ " globalArr.size=" + globalArr.size());

		return sortArr;

	}

	int current_work_package_id = 0;

	// *****************************************************
	public void runMaster() {

		String sql = " select \n"
				+ " work_plan_id, wpc.id work_package_id,wp_name, \n"
				+ " wpc.schema_name, wpc.table_name, wpc.tab_id, sql_statement, mask_params, wpc.mask_level, \n"
				+ " run_type, wpc.order_by_stmt, wplan_type "
				+ " from tdm_work_package wpc, tdm_work_plan p \n"
				+ " where wpc.work_plan_id=p.id  \n"
				+ " and wpc.master_id=? and p.status='RUNNING' \n"
				+ " order by wpc.id " + " limit 0,1";

		ArrayList<String[]> par = getDbArrayConfInt(sql, 1, master_id);

		if (par.size() == 0) {
			sql = "update tdm_work_package set master_id=null where master_id="
					+ master_id;
			execDBConf(sql);

			mylog(LOG_LEVEL_INFO, "No Assignment Found !!!");
			return;
		}

		err_info.setLength(0);
		log_info.setLength(0);

		this.work_plan_id = Integer.parseInt(par.get(0)[0]);
		this.work_package_id = Integer.parseInt(par.get(0)[1]);
		String work_pack_name = par.get(0)[2];
		String table_name = addStartEndForTable(par.get(0)[3] + "."
				+ par.get(0)[4]);
		if (par.get(0)[3].length() == 0 || par.get(0)[3].equals("null"))
			table_name = par.get(0)[4];
		String tab_id = par.get(0)[5];
		String sql_statement = par.get(0)[6];
		String mask_parameters = par.get(0)[7];
		String mask_level = par.get(0)[8];
		RUN_TYPE = par.get(0)[9];
		String order_by_stmt = par.get(0)[10];
		WORK_PLAN_TYPE = par.get(0)[11];

		current_work_package_id = work_package_id;

		String app_type = "";

		if (!WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_DEPL)) {
			sql = "select app_type from tdm_apps a where a.id in (select app_id from tdm_work_plan where id=?) ";
			app_type = getDbArrayConfInt(sql, 1, work_plan_id).get(0)[0];
		}

		if (WORK_PLAN_TYPE.equals("MASK2")) {
			// extractMaskParams(tab_id, table_name,mask_parameters);
			loadRunParams(this.work_plan_id, true);
			runMasterDOMASK2(this);

		}

		if (WORK_PLAN_TYPE.equals("DISC")) {
			loadRunParams(work_plan_id, true);
			if (app_type.equals("MASK"))
				runMasterDISCMASK(this.work_plan_id, this.work_package_id,
						work_pack_name);
			else
				runMasterDISCCOPY(this.work_plan_id, this.work_package_id,
						work_pack_name);
		}

		if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY2)) {
			extractMaskParams(tab_id, table_name, mask_parameters);

			runMasterDOCOPY2(this.work_plan_id, this.work_package_id);

		}

		if (WORK_PLAN_TYPE.equals("AUTO")) {
			loadRunParams(work_plan_id, true);
			runMasterDOAUTO(this.work_plan_id, this.work_package_id);

		}

		if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_DEPL)) {
			loadRunParams(work_plan_id, true);
			runMasterDODEPL(this.work_plan_id, this.work_package_id);

		}

		checkAndPerformOnErrorAction(this.work_plan_id, this.work_package_id, 0);

	}

	// ******************************************************
	void checkAndPerformOnErrorAction(int work_plan_id, int work_pack_id,
			int task_id) {
		if (ON_ERROR_ACTION.equals("CONTINUE"))
			return;

		String sql = "";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		String wpc_or_task_status = "";

		if (task_id > 0) {
			sql = "select status from tdm_task_" + work_plan_id + "_"
					+ work_pack_id + " where id=?";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", "" + task_id });
			ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);
			if (arr != null && arr.size() == 1)
				wpc_or_task_status = arr.get(0)[0];
		} else
			wpc_or_task_status = getWorkPackageStatus(work_pack_id);

		if (!wpc_or_task_status.equals("FAILED"))
			return;

		ArrayList<String> dependWorkPlans = getDependancyUnfinishedWorkPlans(""
				+ work_plan_id);

		for (int i = 0; i < dependWorkPlans.size(); i++) {
			int wpl_id = Integer.parseInt(dependWorkPlans.get(i));

			String wpl_status = getWorkPlanStatus(wpl_id);

			if (ON_ERROR_ACTION.equals("STOP")) {

				if (wpl_status.equals("NEW") || wpl_status.equals("FINISHED")
						|| wpl_status.equals("FAILED")
						|| wpl_status.contains("COMPLETED"))
					continue;

				setWorkPlanStatus(wpl_id, "FAILED");

			}

		}

	}

	// ******************************************************
	ArrayList<String> getDependancyUnfinishedWorkPlans(String work_plan_id) {
		ArrayList<String> wplist = new ArrayList<String>();
		wplist.add(work_plan_id);
		return getDependancyUnfinishedWorkPlans(wplist);
	}

	// ******************************************************
	ArrayList<String> getDependancyUnfinishedWorkPlans(ArrayList<String> wplist) {
		ArrayList<String> ret1 = wplist;

		String sql = "";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		for (int i = 0; i < wplist.size(); i++) {
			String wpl_id = wplist.get(i);

			sql = "select work_plan_id "
					+ " from tdm_work_plan_dependency wpd, tdm_work_plan w"
					+ " where depended_work_plan_id=? "
					+ " and work_plan_id=w.id "
					+ " and status not in ('COMPLETED','FINISHED') "
					+ " order by dependency_order ";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", wpl_id });

			ArrayList<String[]> arr = getDbArrayConf(sql, Integer.MAX_VALUE,
					bindlist);

			for (int r = 0; r < arr.size(); r++) {
				String dependant_work_plan_id = arr.get(r)[0];
				if (ret1.contains(dependant_work_plan_id))
					continue;

				ret1.addAll(getDependancyUnfinishedWorkPlans(dependant_work_plan_id));
			}
		}
		return ret1;
	}

	// ********************************************************************************************************

	ArrayList<Document> getDocuments(MongoDatabase mongodb, String collection,
			String filter, int limit) {

		ArrayList<Document> ret1 = new ArrayList<Document>();

		FindIterable<Document> iterable = mongodb.getCollection(collection)
				.find();

		int i = 0;
		for (Document doc : iterable) {
			ret1.add(doc);

			i++;
			if (limit > 0 && i == limit)
				break;
		}

		return ret1;
	}

	// ********************************************************************************************************
	boolean checkDocFieldDuplicate(ArrayList<String[]> arr,
			String sub_field_name, String sub_field_level,
			String sub_parent_field) {

		for (int a = 0; a < arr.size(); a++) {
			String main_field_name = arr.get(a)[0];
			String main_field_level = arr.get(a)[1];
			String main_parent_field = arr.get(a)[2];

			if (main_field_name.equals(sub_field_name)
					&& main_field_level.equals(sub_field_level)
					&& main_parent_field.equals(sub_parent_field)) {
				return true;

			}
		}

		return false;
	}

	// --------------------------------------
	@SuppressWarnings("rawtypes")
	ArrayList<String[]> getJsonKeyValue(String json, String parent) {

		ArrayList<String[]> ret1 = new ArrayList<String[]>();

		try {

			DBObject doc = (DBObject) JSON.parse(json);

			Map map = doc.toMap();
			char first_char = 'x';

			StringBuilder key = new StringBuilder();
			StringBuilder val = new StringBuilder();

			StringBuilder matchkeyname = new StringBuilder();

			for (Object obj : map.keySet()) {
				key.setLength(0);
				val.setLength(0);

				key.append(obj.toString());
				val.append(map.get(key.toString()).toString());

				matchkeyname.setLength(0);
				if (parent.length() > 0)
					matchkeyname.append(parent + ".");
				matchkeyname.append(key);

				try {
					first_char = val.toString().trim().charAt(0);
				} catch (Exception e) {
					first_char = 'x';
				}

				if (first_char == '{' || first_char == '[') {
					ret1.addAll(getJsonKeyValue(val.toString(),
							matchkeyname.toString()));
				} else {
					ret1.add(new String[] { matchkeyname.toString(),
							val.toString() });
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
			return ret1;
		}
		return ret1;
	}

	// ********************************************************************************************************
	@SuppressWarnings("rawtypes")
	ArrayList<String[]> getDocumentStructure(ArrayList<String[]> curFields,
			String doc, int level, String parent) {
		ArrayList<String[]> ret1 = curFields;
		if (ret1 == null)
			ret1 = new ArrayList<String[]>();

		DBObject dbObject = (DBObject) JSON.parse(doc);

		ArrayList<String> checkArr = new ArrayList<String>();

		Map map = dbObject.toMap();

		for (Object obj : map.keySet()) {
			String key = obj.toString();
			String val = map.get(key).toString();

			try {
				Integer.parseInt(key);
				key = "(\\d+)";
			} catch (Exception e) {
			}

			String full_key_path = key;
			if (parent.length() > 0)
				full_key_path = parent + "." + full_key_path;

			int chid = checkArr.indexOf(key);
			if (chid > -1)
				continue;
			checkArr.add(key);

			char first_char = 'x';
			try {
				first_char = val.trim().charAt(0);
			} catch (Exception e) {
			}

			if (first_char == '{' || first_char == '[') {
				if (!checkDocFieldDuplicate(ret1, key, "" + level, parent))
					ret1.add(new String[] { full_key_path, "" + level, parent,
							"NODE" });

				ArrayList<String[]> subFields = getDocumentStructure(null, val,
						level + 1, full_key_path);

				for (int s = 0; s < subFields.size(); s++) {
					String sub_field_name = subFields.get(s)[0];
					String sub_field_level = subFields.get(s)[1];
					String sub_parent_field = subFields.get(s)[2];

					boolean is_exists = checkDocFieldDuplicate(ret1,
							sub_field_name, sub_field_level, sub_parent_field);

					if (is_exists)
						continue;

					ret1.add(subFields.get(s));
				}

			} else {

				boolean is_exists = checkDocFieldDuplicate(ret1, key, ""
						+ level, parent);
				if (!is_exists) {
					if (key.equals("_id"))
						ret1.add(new String[] { full_key_path, "" + level,
								parent, "KEY" });
					else
						ret1.add(new String[] { full_key_path, "" + level,
								parent, "ENTITY" });
				}

			}

		}

		// --------------------------------------------
		if (level == 1) {

			for (int i = 0; i < ret1.size(); i++) {
				String key1 = ret1.get(i)[0];
				for (int j = i + 1; j < ret1.size(); j++) {
					String key2 = ret1.get(j)[0];
					if (key1.compareTo(key2) > 0) {
						String[] tmp = ret1.get(i);
						ret1.set(i, ret1.get(j));
						ret1.set(j, tmp);
					}
				}
			} // for i

			// set Field Types
			for (int i = 0; i < ret1.size(); i++) {

			}

		}

		return ret1;
	}

	// ******************************************************
	public void runMasterDISCMASK(int work_plan_id, int work_pack_id,
			String work_pack_name) {
		// ******************************************************

		long start_ts = System.currentTimeMillis();

		MongoClient mongoClient = null;

		if (is_mongo) {
			try {
				MongoClientURI muri = new MongoClientURI(app_connstr);
				mongoClient = new MongoClient(muri);
			} catch (Exception e) {
				e.printStackTrace();
				return;
			}
		} else {
			try {
				if (appdb_test_connection_need || connApp == null) {
					connApp = getconn(app_connstr, app_driver, app_username,
							app_password);
					if (!testconn(connApp)) {
						closeApp();
						return;
					}

					appdb_test_connection_need = false;
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		String sql = "select schema_name from tdm_work_package where id=?";

		String schema_name = nvl(
				getDbArrayConfInt(sql, 1, work_pack_id).get(0)[0], "All");

		if (schema_name.equals("null"))
			schema_name = "All";

		// -------------------------------------------
		// START GETTING SCHEMA LIST
		// ******************************************
		ArrayList<String> schemaArr = new ArrayList<String>();
		ArrayList<String> tablesArr = new ArrayList<String>();

		int tab_count = 0;
		int TABLE_PER_TASK = 1;
		DatabaseMetaData meta = null;

		if (!schema_name.equals("All")) {
			if (!schema_name.contains("|::|"))
				schemaArr.add(schema_name);
			else {
				String[] sarr = schema_name.split("\\|::\\|");
				mylog(LOG_LEVEL_DEBUG, "***** SARR.length=" + sarr.length);
				for (int s = 0; s < sarr.length; s++)
					schemaArr.add(sarr[s]);
			}
		} else {

			if (is_mongo) {
				try {
					for (String dbname : mongoClient.listDatabaseNames())
						schemaArr.add(dbname);
				} catch (Exception e) {
					e.printStackTrace();
				}
			} else {
				try {
					meta = connApp.getMetaData();
					ResultSet schemas = meta.getSchemas();
					while (schemas.next()) {
						String tableSchema = schemas.getString("TABLE_SCHEM"); // "TABLE_SCHEM"
						schemaArr.add(tableSchema);
					}
					schemas.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}

		String aSchema = "";
		// ------------------------------------
		// GET TABLE LIST
		// ------------------------------------
		ArrayList<String> jbaseTabsArr = new ArrayList<String>();
		boolean is_jbase = false;

		if (app_db_type.equals(genLib.DB_TYPE_JBASE)) {
			is_jbase = true;
			jbaseTabsArr = getJbaseTables();
		}

		String DISCOVERY_SCHEMAS_TO_SKIP = nvl(
				getParamByName("DISCOVERY_SCHEMAS_TO_SKIP"), "");

		try {
			for (int i = 0; i < schemaArr.size(); i++) {

				aSchema = schemaArr.get(i);

				boolean to_skip = false;

				try {
					String[] skipArr = DISCOVERY_SCHEMAS_TO_SKIP.split("\n|\r");

					for (int s = 0; s < skipArr.length; s++) {
						String skipline = skipArr[s];
						if (skipline.trim().length() == 0)
							continue;
						if (aSchema.toUpperCase()
								.equals(skipline.toUpperCase())) {
							to_skip = true;
							break;
						}

						try {
							Pattern pattern = Pattern.compile(skipline,
									Pattern.CASE_INSENSITIVE);
							Matcher matcher = pattern.matcher(aSchema);
							if (matcher.find()) {
								to_skip = true;
								break;
							}
						} catch (Exception e) {
						}

					}
				} catch (Exception e) {

				}

				if (to_skip)
					continue;

				if (is_mongo) {
					tablesArr.clear();
					MongoDatabase mongodb = mongoClient.getDatabase(aSchema);

					for (String collection : mongodb.listCollectionNames()) {
						heartbeat(TABLE_TDM_MASTER, master_done_count,
								master_id);

						String aTable = aSchema + "." + collection;

						mylog(LOG_LEVEL_INFO, aTable + " added. :)");
						tablesArr.add(aTable);
						tab_count++;
						master_done_count++;

						if ((tab_count % TABLE_PER_TASK) == 0 && tab_count > 0) {
							createDiscoveryTask(work_plan_id, work_pack_id,
									aSchema, tablesArr);
							tablesArr.clear();
						}

						if (getCancelFlag("tdm_master")) {
							mylog(LOG_LEVEL_WARNING,
									"Cancel signal detected. Quiting...");
							stopMaster();
							break;
						}

						if (isWorkPlanCancelled(work_plan_id)) {
							mylog(LOG_LEVEL_WARNING,
									"Workplan is cancelled. Going free...");
							break;
						}
					} // while

				} // if (is_mongo)
				else {
					if (meta == null) {
						try {
							meta = connApp.getMetaData();
						} catch (Exception e) {
							mylog(LOG_LEVEL_ERROR,
									"Metadata can not be created.");
							e.printStackTrace();
							break;

						}
					}
					ResultSet tables = meta.getTables(null, aSchema, "%",
							new String[] { "TABLE" });
					tablesArr.clear();
					while (tables.next()) {
						heartbeat(TABLE_TDM_MASTER, master_done_count,
								master_id);

						String aTable = aSchema + "."
								+ tables.getString("TABLE_NAME");
						// jbase
						if (aTable.indexOf(".") == 0)
							aTable = aTable.substring(1);

						if (is_jbase && jbaseTabsArr.indexOf(aTable) == -1) {
							mylog(LOG_LEVEL_INFO, aTable
									+ " is not included in VOC. Skipping....");
							tablesArr.clear();
							continue;
						}
						mylog(LOG_LEVEL_INFO, aTable + " added. :)");
						tablesArr.add(aTable);
						tab_count++;
						master_done_count++;

						if ((tab_count % TABLE_PER_TASK) == 0 && tab_count > 0) {
							createDiscoveryTask(work_plan_id, work_pack_id,
									aSchema, tablesArr);
							tablesArr.clear();
						}

						if (getCancelFlag("tdm_master")) {
							mylog(LOG_LEVEL_WARNING,
									"Cancel signal detected. Quiting...");
							stopMaster();
							break;
						}

						if (isWorkPlanCancelled(work_plan_id)) {
							mylog(LOG_LEVEL_WARNING,
									"Workplan is cancelled. Going free...");
							break;
						}
					} // while
					tables.close();
				} // else if (is_mongo)

			} // for
		} catch (Exception e) {
			e.printStackTrace();
			renewWorkPackage(work_pack_id, work_plan_id);
		} finally {
			closeApp();
			if (tab_count == 0)
				finishWorkPackageasEmpty(work_pack_id);
			else {
				setWpackExportCount(work_pack_id, tab_count, true);
				closeWorkPackage(work_pack_id,
						(System.currentTimeMillis() - start_ts), "",
						"DISCOVERING");
			}
		}

		setWpackExportCount(work_pack_id, tab_count, true);

		if (tab_count > 0) {
			createDiscoveryTask(work_plan_id, work_pack_id, aSchema, tablesArr);
			tablesArr.clear();
		}

		mylog(LOG_LEVEL_INFO, "Discovery table list is ok for : "
				+ work_pack_name);

	}

	// ******************************************************
	public void runMasterDOAUTO(int work_plan_id, int work_pack_id) {
		// ******************************************************

		long start_ts = System.currentTimeMillis();

		try {
			String sql = "select id, script_name, app_id from tdm_auto_scripts "
					+ " where app_id=(select app_id from tdm_work_plan where id="
					+ work_plan_id + ") " + "  and script_type='EXECUTABLE'";

			ArrayList<String[]> scriptArr = getDbArrayConf(sql,
					Integer.MAX_VALUE);

			for (int i = 0; i < scriptArr.size(); i++) {

				String aScript_id = scriptArr.get(i)[0];
				String aScript_name = scriptArr.get(i)[1];
				String app_id = scriptArr.get(i)[2];

				mylog(LOG_LEVEL_INFO, "Creating task for script : "
						+ aScript_name);
				createAutomationTask(work_plan_id, work_pack_id, aScript_id,
						aScript_name, app_id);

				if (getCancelFlag("tdm_master")) {
					mylog(LOG_LEVEL_WARNING,
							"Cancel signal detected. Quiting...");
					stopMaster();

					break;
				}

				if (isWorkPlanCancelled(work_plan_id)) {
					mylog(LOG_LEVEL_WARNING,
							"Workplan is cancelled. Going free...");
					break;
				}

				setWpackExportCount(work_pack_id, i, true);

			} // for (int i=0;i<schemaArr.size();i++) {

			mylog(LOG_LEVEL_INFO, "Automation list is ok for : " + work_plan_id);

		} catch (Exception e) {
			e.printStackTrace();
			renewWorkPackage(work_pack_id, work_plan_id);
		} finally {
			closeWorkPackage(work_pack_id,
					(System.currentTimeMillis() - start_ts), "", "EXECUTING");
		}

	}

	// *********************************************************
	String getRequestStage(String request_id) {

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "";

		sql = "select flow_id, status from mad_request r, mad_request_type rt where r.request_type_id=rt.id and r.id=?";

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", request_id });

		ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);

		if (arr == null || arr.size() == 0)
			return "X";

		String flow_id = arr.get(0)[0];
		String status = arr.get(0)[1];

		sql = "select state_stage from mad_flow_state where flow_id=? and state_name=?";

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", flow_id });
		bindlist.add(new String[] { "STRING", status });

		arr = getDbArrayConf(sql, 1, bindlist);

		if (arr == null || arr.size() == 0)
			return "X";

		return arr.get(0)[0];

	}

	// ******************************************************
	int getRelatedRequestCount(String request_id, int work_plan_id,
			int work_pack_id) {

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "";

		sql = "select count(*) from mad_request_work_package "
				+ " where work_plan_id=? and work_package_id=? and request_id!=?";

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + work_plan_id });
		bindlist.add(new String[] { "INTEGER", "" + work_pack_id });
		bindlist.add(new String[] { "INTEGER", "" + request_id });

		ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);

		if (arr == null || arr.size() == 0)
			return 0;

		try {
			return Integer.parseInt(arr.get(0)[0]);
		} catch (Exception e) {
			return 0;
		}

	}

	// ******************************************************
	public void runMasterDODEPL(int work_plan_id, int work_pack_id) {
		// ******************************************************

		long start_ts = System.currentTimeMillis();
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		ArrayList<String[]> dependedArr = new ArrayList<String[]>();

		String member_id = "";
		String application_id = "";
		String platform_id = "";
		String environment_id = "";

		boolean build_success = false;
		boolean deploy_success = false;
		boolean skip_deploy = false;

		try {
			String sql = "select wpc.mask_params  from tdm_work_package wpc where  wpc.id=? ";

			ArrayList<String[]> arr = getDbArrayConfInt(sql, 1, work_pack_id);

			String mask_params = arr.get(0)[0];

			mask_params = mask_params.split(":")[1];

			member_id = mask_params.split("\\@")[0];
			application_id = mask_params.split("\\@")[1];
			platform_id = mask_params.split("\\@")[2];
			environment_id = mask_params.split("\\@")[3];

			sql = "select request_id, deployment_attempt_no "
					+ " from mad_request_application_member ram, mad_request r "
					+ " where ram.id=? and ram.request_id=r.id ";

			arr = getDbArrayConfInt(sql, 1, Integer.parseInt(member_id));

			String request_id = arr.get(0)[0];
			String deployment_attempt_no = arr.get(0)[1];

			String status_stage = getRequestStage(request_id);

			int related_request_count = getRelatedRequestCount(request_id,
					work_plan_id, work_pack_id);

			StringBuilder build_logs = new StringBuilder();

			if (!status_stage.equals("DEPLOY") && related_request_count == 0) {

				mylog(LOG_LEVEL_WARNING,
						"Deploymet stage is not DEPLOY [current status="
								+ status_stage + ", related_request_count="
								+ related_request_count
								+ " ]. Deployment is skipping request "
								+ request_id + ".");
				skip_deploy = true;

				mylog(LOG_LEVEL_INFO, "BUILD SUCCESS : " + build_success);

				long p_duration = System.currentTimeMillis() - start_ts;

				closeWorkPackage(work_pack_id, p_duration, log_info.toString(),
						"FINISHED");

			}

			sql = "select request_id from mad_request_work_package where work_plan_id=? and work_package_id=?";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", "" + work_plan_id });
			bindlist.add(new String[] { "INTEGER", "" + work_pack_id });
			dependedArr = getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);

			for (int d = 0; d < dependedArr.size(); d++) {
				String depended_request_id = dependedArr.get(d)[0];
				String depended_request_state_stage = getRequestStage(depended_request_id);
				if (depended_request_state_stage.equals("DEPLOY"))
					setMadRequestStateRunning(work_pack_id,
							depended_request_id, member_id);
			}

			ArrayList<String[]> buildret = new ArrayList<String[]>();

			if (!skip_deploy) {
				buildret = MADBuildDeployApplication("build", request_id,
						deployment_attempt_no, application_id, environment_id,
						platform_id, member_id);
				try {
					build_success = Boolean.parseBoolean(buildret.get(0)[0]);
					build_logs.append(buildret.get(0)[1]);
				} catch (Exception e) {
					e.printStackTrace();
				}

				mylog(LOG_LEVEL_INFO, "BUILD SUCCESS : " + build_success);

				long p_duration = System.currentTimeMillis() - start_ts;

				if (!build_success) {
					closeWorkPackage(work_pack_id, p_duration,
							build_logs.toString(), "FAILED");
				} else {
					closeWorkPackage(work_pack_id, p_duration,
							build_logs.toString(), "DEPLOYING");

					ArrayList<String[]> deployret = MADBuildDeployApplication(
							"deploy", request_id, deployment_attempt_no,
							application_id, environment_id, platform_id,
							member_id);

					try {
						deploy_success = Boolean
								.parseBoolean(deployret.get(0)[0]);
						build_logs.append(deployret.get(0)[1]);
					} catch (Exception e) {
						e.printStackTrace();
					}

					mylog(LOG_LEVEL_WARNING, "DEPLOY SUCCESS : "
							+ deploy_success);

					p_duration = System.currentTimeMillis() - start_ts;

					if (!deploy_success) {
						closeWorkPackage(work_pack_id, p_duration,
								build_logs.toString(), "FAILED");
					} else {
						closeWorkPackage(work_pack_id, p_duration,
								build_logs.toString(), "FINISHED");
					}

				}
			} // if (!skip_deploy)

			for (int d = 0; d < dependedArr.size(); d++) {
				String depended_request_id = dependedArr.get(d)[0];
				String depended_request_state_stage = getRequestStage(depended_request_id);
				mylog(LOG_LEVEL_INFO, "Build & Deploy is finished for : WPL : "
						+ work_plan_id + ", WPC : " + work_pack_id);

				// check if it is still in deploy stage
				if (depended_request_state_stage.equals("DEPLOY")) {
					setMadRequestState(work_pack_id, depended_request_id,
							member_id, build_success && deploy_success);
					// System.out.println("xxxxx  setMadRequestState work_pack_id="+work_pack_id+", depended_request_id="+depended_request_id+", member_id="+member_id);
				}

			}

			mylog(LOG_LEVEL_INFO, "Build & Deploy is finished for WPL : "
					+ work_plan_id + ", WPC : " + work_pack_id);

			mylog(LOG_LEVEL_INFO, "build_success " + build_success);
			mylog(LOG_LEVEL_INFO, "deploy_success " + deploy_success);
			mylog(LOG_LEVEL_INFO, "ON_ERROR_ACTION " + ON_ERROR_ACTION);

			countAndSetStatusForMainDeploymentWpl(work_plan_id, skip_deploy);

		} catch (Exception e) {
			e.printStackTrace();
			mylog(LOG_LEVEL_ERROR, "Exception@runMasterDODEPL:"
					+ genLib.getStackTraceAsStringBuilder(e).toString());
			// renewWorkPackage(work_pack_id,work_plan_id);

			for (int d = 0; d < dependedArr.size(); d++) {
				String depended_request_id = dependedArr.get(d)[0];
				String depended_request_state_stage = getRequestStage(depended_request_id);
				mylog(LOG_LEVEL_INFO, "Build & Deploy is finished for : WPL : "
						+ work_plan_id + ", WPC : " + work_pack_id);
				// check if it is still in deploy stage
				// if (depended_request_state_stage.equals("DEPLOY"))
				setMadRequestState(work_pack_id, depended_request_id,
						member_id, false);
			}

			countAndSetStatusForMainDeploymentWpl(work_plan_id, skip_deploy);
		}

	}

	// ******************************************************
	private void setMadRequestStateRunning(int work_package_id,
			String request_id, String member_id) {
		String sql = "";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		sql = "update mad_request_application_member set status=?, work_package_id=? where id=?";
		bindlist.clear();
		bindlist.add(new String[] { "STRING", "RUNNING" });
		bindlist.add(new String[] { "INTEGER", "" + work_package_id });
		bindlist.add(new String[] { "INTEGER", member_id });
		execDBBindingConf(sql, bindlist);

	}

	// ******************************************************
	private void setMadRequestState(int work_package_id, String request_id,
			String member_id, boolean is_this_step_succeeded) {
		String sql = "";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		// sadece New-null olanlari update ediyoruz. Boylece ilki fail, sonrasi
		// pass ise hatali olan kalir
		sql = "update mad_request_application_member set status=?, skip_reason=null, work_package_id=? where id=? and (status is null or status='RUNNING')";

		bindlist.clear();
		if (is_this_step_succeeded)
			bindlist.add(new String[] { "STRING", "OK" });
		else {
			sql = "update mad_request_application_member set status=?, skip_reason=null, work_package_id=? where id=? ";
			bindlist.add(new String[] { "STRING", "NOK" });
		}

		bindlist.add(new String[] { "INTEGER", "" + work_package_id });
		bindlist.add(new String[] { "INTEGER", member_id });
		execDBBindingConf(sql, bindlist);

		/*
		 * if (!is_this_step_succeeded && ON_ERROR_ACTION.equals("CONTINUE")) {
		 * mylog(LOG_LEVEL_INFO,
		 * "This step is failed but Continuing on Error. "); return; }
		 */

		sql = "select distinct wpc.status \n"
				+ "	from \n"
				+ "	mad_request_work_package rwp, mad_request r, tdm_work_package wpc \n"
				+ "	where rwp.request_id=r.id \n"
				+ "	and rwp.work_package_id=wpc.id \n"
				+ "   and rwp.deployment_attempt_no=r.deployment_attempt_no \n"
				+ "	and rwp.request_id=? " + "   and wpc.id!=? ";

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", request_id });
		bindlist.add(new String[] { "INTEGER", "" + work_package_id });

		ArrayList<String[]> wpcStatArr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		boolean is_all_wpcs_but_this_finished = true;
		boolean is_all_wpcs_but_this_succeeded = true;
		boolean is_any_running_but_this = false;

		for (int i = 0; i < wpcStatArr.size(); i++) {
			String wpc_status = wpcStatArr.get(i)[0];
			if (wpc_status.equals("NEW") || wpc_status.equals("ASSIGNED")
					|| wpc_status.equals("RUNNING")
					|| wpc_status.equals("DEPLOYING")) {
				is_all_wpcs_but_this_finished = false;
				break;
			}
		}

		for (int i = 0; i < wpcStatArr.size(); i++) {
			String wpc_status = wpcStatArr.get(i)[0];
			if (!wpc_status.equals("FINISHED")) {
				is_all_wpcs_but_this_succeeded = false;
				break;
			}
		}

		for (int i = 0; i < wpcStatArr.size(); i++) {
			String wpc_status = wpcStatArr.get(i)[0];
			if (wpc_status.equals("RUNNING") || wpc_status.equals("DEPLOYING")
					|| wpc_status.equals("ASSIGNED")) {
				is_any_running_but_this = true;
				break;
			}
		}

		boolean any_error = !is_all_wpcs_but_this_succeeded
				|| !is_this_step_succeeded;

		System.out
				.println("******************************************************************");
		System.out.println("xxxxxx   is_this_step_succeeded         ="
				+ is_this_step_succeeded);
		System.out.println("xxxxxx   is_all_wpcs_but_this_finished  ="
				+ is_all_wpcs_but_this_finished);
		System.out.println("xxxxxx   is_all_wpcs_but_this_succeeded ="
				+ is_all_wpcs_but_this_succeeded);
		System.out.println("xxxxxx   any_error                      ="
				+ any_error);
		System.out.println("xxxxxx   is_any_running_but_this        ="
				+ is_any_running_but_this);
		System.out
				.println("******************************************************************");

		mylog(LOG_LEVEL_INFO,
				"setMadRequestState . work_plan_id                      =  "
						+ work_package_id);
		mylog(LOG_LEVEL_INFO,
				"setMadRequestState . request_id                        =  "
						+ request_id);
		mylog(LOG_LEVEL_INFO,
				"setMadRequestState . member_id                         =  "
						+ member_id);
		mylog(LOG_LEVEL_INFO,
				"setMadRequestState . is_this_step_succeeded            =  "
						+ is_this_step_succeeded);
		mylog(LOG_LEVEL_INFO,
				"setMadRequestState . is_all_wpcs_but_this_finished     =  "
						+ is_all_wpcs_but_this_finished);
		mylog(LOG_LEVEL_INFO,
				"setMadRequestState . is_all_wpcs_but_this_succeeded    =  "
						+ is_all_wpcs_but_this_succeeded);
		mylog(LOG_LEVEL_INFO,
				"setMadRequestState . any_error                         =  "
						+ any_error);
		mylog(LOG_LEVEL_INFO,
				"setMadRequestState . is_any_running_but_this           =  "
						+ is_any_running_but_this);

		if (is_any_running_but_this) {
			mylog(LOG_LEVEL_INFO,
					"Skip setMadRequestState . There are running WPCs. ");
			return;
		}

		if (!is_all_wpcs_but_this_finished) {

			if (any_error) {
				if (ON_ERROR_ACTION.equals("CONTINUE")) {
					mylog(LOG_LEVEL_INFO,
							"Skip setMadRequestState . This WPC not succeeded. [Continue on Error]. ");
					return;
				}
			} else {
				mylog(LOG_LEVEL_INFO,
						"Skip setMadRequestState . This WPC succeeded. Continue next WPC . ");
				return;
			}
		}

		String state_stage = "DEPLOY_SUCCESS";
		if (any_error)
			state_stage = "DEPLOY_FAIL";

		mylog(LOG_LEVEL_INFO,
				"setMadRequestState . State stage will be set to ["
						+ state_stage + "] ");

		sql = " select fs.id, state_name, rt.flow_id "
				+ " from mad_request r, mad_request_type rt, mad_flow_state fs "
				+ " where r.id=? " + " and r.request_type_id=rt.id "
				+ " and rt.flow_id=fs.flow_id " + " and state_stage=?";

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", request_id });
		bindlist.add(new String[] { "STRING", state_stage });

		ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);

		if (arr.size() == 0) {
			mylog(LOG_LEVEL_INFO,
					"Skipping setMadRequestState. Appropriate next state with stage ('"
							+ state_stage + "') not found");
			return;
		}

		String next_state_id = arr.get(0)[0];
		String next_state_name = arr.get(0)[1];
		String flow_id = arr.get(0)[2];

		sql = "select id from tdm_user where username='admin'";
		String admin_user_id = getDbArrayConf(sql, 1).get(0)[0];

		sql = "select id from mad_flow_state_action where next_state_id=? and action_type='JS'";
		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", next_state_id });

		arr = getDbArrayConf(sql, 1, bindlist);
		if (arr.size() == 0) {
			mylog(LOG_LEVEL_INFO,
					"Skipping setMadRequestState. Appropriate next state action with next state to  ('"
							+ next_state_name + "') not found");
			return;
		}
		String next_state_action_id = arr.get(0)[0];

		String action_id = next_state_action_id;
		String action_note = "Deployment is done with success="
				+ is_this_step_succeeded;
		String next_state_user = admin_user_id;

		sql = "update mad_request_flow_logs "
				+ " set "
				+ " status='CLOSED' , "
				+ " flow_state_action_id=?, "
				+ " action_note=?, "
				+ " next_state_id=?, "
				+ " next_state_user=?, "
				+ " time_spent=?, "
				+ " notification_attempt_date=DATE_ADD(now(), INTERVAL -10 MINUTE), "
				+ " next_state_date=now() " + " where "
				+ " request_id=? and status='OPEN'";

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", action_id });
		bindlist.add(new String[] { "STRINE", action_note });
		bindlist.add(new String[] { "INTEGER", next_state_id });
		bindlist.add(new String[] { "INTEGER", "" + next_state_user });
		bindlist.add(new String[] { "INTEGER", "" + "0" });
		bindlist.add(new String[] { "INTEGER", request_id });

		execDBBindingConf(sql, bindlist);

		sql = "insert into mad_request_flow_logs "
				+ " (request_id, flow_id, flow_state_id, curr_state_user, curr_state_date, status) "
				+ " values (?, ?, ?, ?, now(),'OPEN') ";
		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", request_id });
		bindlist.add(new String[] { "INTEGER", flow_id });
		bindlist.add(new String[] { "INTEGER", "" + next_state_id });
		bindlist.add(new String[] { "INTEGER", "" + next_state_user });

		execDBBindingConf(sql, bindlist);

		sql = "update mad_request set status=? where id=?";
		bindlist.clear();
		bindlist.add(new String[] { "STRING", next_state_name });
		bindlist.add(new String[] { "INTEGER", request_id });

		execDBBindingConf(sql, bindlist);

	}

	// ******************************************************
	public void runMasterDISCCOPY(int work_plan_id, int work_pack_id,
			String work_pack_name) {
		// ******************************************************

		long start_ts = System.currentTimeMillis();

		try {
			if (appdb_test_connection_need || connApp == null) {
				connApp = getconn(app_connstr, app_driver, app_username,
						app_password);
				if (!testconn(connApp)) {
					closeApp();
					return;
				}
				appdb_test_connection_need = false;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		String sql = "select schema_name, table_name from tdm_work_package where id=?";
		ArrayList<String[]> wpcArr = getDbArrayConfInt(sql, 1, work_pack_id);
		String schema_name = nvl(wpcArr.get(0)[0], "All");
		String table_name = nvl(wpcArr.get(0)[1], "xxx");

		// -------------------------------------------
		// START GETTING SCHEMA LIST
		// ******************************************
		sql = "select schema_name, tab_name from tdm_tabs "
				+ " where app_id=(select app_id from tdm_work_plan where id="
				+ work_plan_id + ") " + " and tab_name='" + table_name + "'";

		ArrayList<String[]> sourceTables = getDbArrayConf(sql,
				Integer.MAX_VALUE);
		ArrayList<String> schemaArr = new ArrayList<String>();
		ArrayList<String> linesArr = new ArrayList<String>();

		int tab_count = 0;
		int TABLE_PER_TASK = 1;

		try {

			DatabaseMetaData meta = connApp.getMetaData();

			if (!schema_name.equals("All"))
				schemaArr.add(schema_name);
			else {
				ResultSet schemas = meta.getSchemas();
				while (schemas.next()) {
					String tableSchema = schemas.getString("TABLE_SCHEM"); // "TABLE_SCHEM"
					schemaArr.add(tableSchema);
				}
				schemas.close();
			}

			String aSchema = "";
			// ------------------------------------
			// GET TABLE LIST
			// ------------------------------------
			String[] types = { "TABLE" };

			for (int t = 0; t < sourceTables.size(); t++) {

				String a_SourceTable = sourceTables.get(t)[0] + "."
						+ sourceTables.get(t)[1];

				for (int i = 0; i < schemaArr.size(); i++) {

					aSchema = schemaArr.get(i);

					ResultSet tables = meta
							.getTables(null, aSchema, "%", types);
					linesArr.clear();
					while (tables.next()) {

						heartbeat(TABLE_TDM_MASTER, master_done_count,
								master_id);

						String aLine = a_SourceTable + "|" + aSchema + "."
								+ tables.getString("TABLE_NAME");
						linesArr.add(aLine);
						tab_count++;
						master_done_count++;

						if ((tab_count % TABLE_PER_TASK) == 0 && tab_count > 0) {
							createDiscoveryTask(work_plan_id, work_pack_id,
									aSchema, linesArr);
							linesArr.clear();
						}

						if (getCancelFlag("tdm_master")) {
							mylog(LOG_LEVEL_WARNING,
									"Cancel signal detected. Quiting...");
							stopMaster();

							break;
						}

						if (isWorkPlanCancelled(work_plan_id)) {
							mylog(LOG_LEVEL_WARNING,
									"Workplan is cancelled. Going free...");
							break;
						}

					}

					tables.close();

					if (getCancelFlag("tdm_master")) {
						mylog(LOG_LEVEL_WARNING,
								"Cancel signal detected. Quiting...");
						stopMaster();

						break;
					}

					if (isWorkPlanCancelled(work_plan_id)) {
						mylog(LOG_LEVEL_WARNING,
								"Workplan is cancelled. Going free...");
						break;
					}

					setWpackExportCount(work_pack_id, tab_count, true);

				} // for (int i=0;i<schemaArr.size();i++)

			} // for (int t=0;t<sourceTables.size();t++)

			if (tab_count > 0) {
				createDiscoveryTask(work_plan_id, work_pack_id, aSchema,
						linesArr);
				linesArr.clear();
			}

			mylog(LOG_LEVEL_INFO, "Discovery table list is ok for : "
					+ work_pack_name);

		} catch (Exception e) {
			e.printStackTrace();
			renewWorkPackage(work_pack_id, work_plan_id);
		} finally {
			closeApp();
			if (tab_count == 0)
				finishWorkPackageasEmpty(work_pack_id);
			else {
				setWpackExportCount(work_pack_id, tab_count, true);
				closeWorkPackage(work_pack_id,
						(System.currentTimeMillis() - start_ts), "",
						"DISCOVERING");
			}
		}

	}

	// ******************************************************
	public void runMasterDOMASK2(ConfDBOper db) {

		maskLib m = new maskLib(true);
		m.doWorkPackage(db, master_id, work_plan_id, work_package_id, true,
				true);

		m.closeAll();

	}

	// ******************************************************
	public void runMasterDOCOPY2(int work_plan_id, int work_package_id) {

		copyLib cp = new copyLib();
		cp.doWorkPackage(this, master_id, work_plan_id, work_package_id, true,
				true);
		cp.closeAll();

	}

	// --------------------------------------------------------------------------------

	// ******************************************************
	private String extractCopyTarget(String target_info, String table_name) {

		String schema_name = "";
		String tab_name = table_name;

		if (table_name.contains(".")) {
			schema_name = table_name.split("\\.")[0];
			tab_name = table_name.split("\\.")[1];
		}

		String[] targets = target_info.split("\n");

		for (int t = 0; t < targets.length; t++) {
			String a_target = targets[t];
			if (a_target.contains("[") && a_target.contains("]")) {
				String a_orig_part = a_target.split("\\[")[0];
				if (a_orig_part.contains(".")) {
					String a_orig_schema = a_orig_part.split("\\.")[0];
					String a_orig_table = a_orig_part.split("\\.")[1];

					if (a_orig_schema.toLowerCase().equals(
							schema_name.toLowerCase())
							&& a_orig_table.toLowerCase().equals(
									tab_name.toLowerCase())) {
						String a_new_table = a_target.split("\\[")[1]
								.split("\\]")[0].split(":")[1];
						if (a_new_table.contains(".")) {
							schema_name = a_new_table.split("\\.")[0];
							tab_name = a_new_table.split("\\.")[1];
							break;
						}

					}
				}

			}

		} // for t

		return schema_name + "." + tab_name;
	}

	// ******************************************************
	private String extractCopySource(String target_info, String table_name) {

		String schema_name = "";
		String tab_name = table_name;

		if (table_name.contains(".")) {
			schema_name = table_name.split("\\.")[0];
			tab_name = table_name.split("\\.")[1];
		}

		String[] targets = target_info.split("\n");

		for (int t = 0; t < targets.length; t++) {
			String a_target = targets[t];
			if (a_target.contains("[") && a_target.contains("]")) {
				String a_orig_part = a_target.split("\\[")[0];
				if (a_orig_part.contains(".")) {
					String a_orig_schema = a_orig_part.split("\\.")[0];
					String a_orig_table = a_orig_part.split("\\.")[1];

					if (a_orig_schema.equals(schema_name)
							&& a_orig_table.toLowerCase().equals(
									tab_name.toLowerCase())) {
						String a_new_table = a_target.split("\\[")[1]
								.split("\\]")[0].split(":")[0];
						if (a_new_table.contains(".")) {
							schema_name = a_new_table.split("\\.")[0];
							tab_name = a_new_table.split("\\.")[1];
							break;
						}

					}
				}

			}

		} // for t

		return schema_name + "." + tab_name;
	}

	public String CURR_COPY_LEVEL = "SINGLETAB";




	private String fieldtype2bindtype(String field_type, String orig_val) {
		String bindtype = "UNKNOWN";

		if (TYPE_LIST_STRING.indexOf(field_type.toUpperCase()) > -1) {
			return "STRING";
		}

		if (TYPE_LIST_INT.indexOf(field_type.toUpperCase()) > -1) {

			bindtype = "INTEGER";

			try {
				long l = Long.parseLong(orig_val);
				bindtype = "LONG";
			} catch (Exception e) {
			}

			try {
				int l = Integer.parseInt(orig_val);
				bindtype = "INTEGER";
			} catch (Exception e) {
			}

			return bindtype;
		}

		if (TYPE_LIST_DATE.indexOf(field_type.toUpperCase()) > -1)
			return "DATE";

		if (TYPE_LIST_CLOB.indexOf(field_type.toUpperCase()) > -1)
			return "CLOB";

		if (TYPE_LIST_BLOB.indexOf(field_type.toUpperCase()) > -1)
			return "BLOB";

		if ("ROWID".indexOf(field_type.toUpperCase()) > -1)
			return "ROWID";

		return bindtype;
	}

	int last_work_package_id = 0;
	// String[] currFieldList=new String[100];

	long lastSuccessUpdateTS = 0;

	// ***************************************
	public void runWorker() {
		// ***************************************
		int task_id = 0;
		int work_plan_id = 0;
		int work_package_id = 0;
		int tab_id = 0;

		String sql = "";

		lastSuccessUpdateTS = System.currentTimeMillis();

		sql = "select t.task_id, t.work_plan_id, t.work_package_id, wpc.tab_id "
				+ " from tdm_task_assignment t, tdm_work_package wpc "
				+ " where t.status='ASSIGNED' and t.worker_id=? "
				+ " and t.work_package_id=wpc.id ";
		ArrayList<String[]> tlist = getDbArrayConfInt(sql, Integer.MAX_VALUE,
				worker_id);
		mylog(LOG_LEVEL_INFO, "Task Count : " + tlist.size());

		for (int t = 0; t < tlist.size(); t++) {

			if (getCancelFlag("tdm_worker")) {
				resumeTasksByWorkerId(worker_id);
				mylog(LOG_LEVEL_WARNING, "Worker Cancelled...");
				break;
			}

			mylog(LOG_LEVEL_INFO, "Start working on task #" + task_id);

			err_info.setLength(0);
			log_info.setLength(0);

			uncommitted_block_count = 0;

			task_id = Integer.parseInt(tlist.get(t)[0]);
			work_plan_id = Integer.parseInt(tlist.get(t)[1]);
			work_package_id = Integer.parseInt(tlist.get(t)[2]);
			tab_id = Integer.parseInt(tlist.get(t)[3]);

			try {
				connApp.commit();
			} catch (Exception e) {
			}
			loadRunParams(work_plan_id);

			if (WORK_PLAN_TYPE.equals("DISC")) {
				sql = "select app_type from tdm_apps where id=(select app_id from tdm_work_plan where id="
						+ work_plan_id + ")";
				String app_type = getDbArrayConf(sql, 1).get(0)[0];

				if (app_type.equals("MASK"))
					runWorkerDISCMASK(
							task_id,
							work_plan_id,
							work_package_id,
							getInfoBin("tdm_task_" + work_plan_id + "_"
									+ work_package_id, task_id,
									"task_info_zipped"));
				else
					runWorkerDISCCOPY(
							task_id,
							work_plan_id,
							work_package_id,
							getInfoBin("tdm_task_" + work_plan_id + "_"
									+ work_package_id, task_id,
									"task_info_zipped"));
			}

			if (WORK_PLAN_TYPE.equals("AUTO")) {

				runWorkerDOAUTO(
						task_id,
						work_plan_id,
						work_package_id,
						getInfoBin("tdm_task_" + work_plan_id + "_"
								+ work_package_id, task_id, "task_info_zipped"));
			}

			worker_last_worked_ts = System.currentTimeMillis();

			checkAndPerformOnErrorAction(work_plan_id, work_package_id, task_id);

		} // for t=0

		if (heapUsedRate() > 80)
			System.gc();

	}

	// ***************************************
	public void runWorkerDISCMASK(int task_id, int work_plan_id,
			int work_package_id, byte[] task_info) {
		// ***************************************

		err_info.setLength(0);
		log_info.setLength(0);

		long start_ts = System.currentTimeMillis();
		long duration = 0;
		startTask(task_id, work_plan_id, work_package_id);
		String[] recs = nvl(uncompress(task_info), "").split("\n");

		int done_count = 0;
		int success_count = 0;
		int fail_count = 0;

		int maxRec = 1000;
		try {
			maxRec = Integer.parseInt(getParamByName("DISCOVERY_SAMPLE_SIZE"));
		} catch (Exception e) {
			maxRec = 1000;
		}

		MongoClient mongoClient = null;

		if (is_mongo) {
			try {
				MongoClientURI muri = new MongoClientURI(app_connstr);
				mongoClient = new MongoClient(muri);
			} catch (Exception e) {
				e.printStackTrace();
				return;
			}
		} // if (is_mongo)
		else {
			try {
				if (appdb_test_connection_need || connApp == null) {
					connApp = getconn(app_connstr, app_driver, app_username,
							app_password);
					if (!testconn(connApp)) {
						closeApp();
						return;
					}
					appdb_test_connection_need = false;
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		} // if (is_mongo)

		// load all rules
		String sql = "select t.id, r.id rule_id, t.description target_desc, r.description rule_desc, r.rule_type, r.regex, r.script, r.field_names "
				+ " from tdm_discovery_target t, tdm_discovery_rule r "
				+ " where t.id=r.discovery_target_id "
				+ " and r.is_valid='YES' " + " order by 1;";
		ArrayList<String[]> matchList = getDbArrayConf(sql, Integer.MAX_VALUE);

		String fields_to_skip = getParamByName("DISCOVERY_FIELDS_TO_SKIP");
		String[] tmpArr = fields_to_skip.split("\n|\r");
		ArrayList<String> arrFieldsToSkip = new ArrayList<String>();

		for (int i = 0; i < tmpArr.length; i++)
			if (tmpArr[i].trim().length() > 0)
				arrFieldsToSkip.add(tmpArr[i]);

		boolean is_cancelled = false;
		try {
			for (int i = 0; i < recs.length; i++) {
				String table_name = recs[i];

				if (is_cancelled)
					break;

				if (table_name.length() > 0) {

					String[] arr = table_name.split("\\.");

					String aSchema = arr[arr.length - 2];
					String aTable = arr[arr.length - 1];

					// clear old discovery records
					sql = "delete from tdm_discovery_result where discovery_id=? and schema_name=? and table_name=?";
					ArrayList<String[]> bindlist = new ArrayList<String[]>();
					bindlist.add(new String[] { "INTEGER", "" + work_plan_id });
					bindlist.add(new String[] { "STRING", aSchema });
					bindlist.add(new String[] { "STRING", aTable });
					execDBBindingConf(sql, bindlist);

					int recno = 0;

					String fName = "";
					int fType = 0;

					ArrayList<String> fNameArr = new ArrayList<String>();
					ArrayList<Integer> fTypeArr = new ArrayList<Integer>();
					ArrayList<String[]> recsArr = new ArrayList<String[]>();

					sql = " select * from "
							+ addStartEndForTable(aSchema + "." + aTable);
					if (app_db_type.equals(genLib.DB_TYPE_MSSQL))
						sql = " select top  " + maxRec + " * from "
								+ addStartEndForTable(aSchema + "." + aTable);

					// Jbase
					if (aSchema.equals("null") || aSchema.length() == 0
							|| app_db_type.equals(genLib.DB_TYPE_JBASE)) {
						aSchema = "";
						aTable = table_name;
						sql = " select " + getJbaseFieldsWithComma(aTable)
								+ " from \"" + aTable + "\"";
						mylog(LOG_LEVEL_DEBUG, "JBASE SQL : " + sql);
					}

					mylog(LOG_LEVEL_INFO, "Discovering : " + aSchema + "."
							+ aTable);

					try {

						// -----------------------------------------------------
						// GETTING COLUMN LIST
						// *****************************************************
						int colcount = 0;
						Statement stmt = null;
						ResultSet rs = null;

						if (is_mongo) {
							mylog(LOG_LEVEL_INFO, "Getting mongo columns for "
									+ aSchema + "." + aTable);

							MongoDatabase mongodb = mongoClient
									.getDatabase(aSchema);
							ArrayList<Document> docs = getDocuments(mongodb,
									aTable, "", maxRec);

							ArrayList<String[]> mongoColArr = new ArrayList<String[]>();

							for (int d = 0; d < docs.size(); d++)
								mongoColArr = getDocumentStructure(mongoColArr,
										docs.get(d).toJson(), 1, "");
							colcount = mongoColArr.size();

							mylog(LOG_LEVEL_INFO, "Getting mongo columns for "
									+ aSchema + "." + aTable + " DONE. "
									+ colcount + " columns. found");

							for (int f = 0; f < colcount; f++) {
								fNameArr.add(mongoColArr.get(f)[0]);
								fTypeArr.add(1); // Evaluate all columns as
													// string
							}

						} // if (is_mongo)
						else {
							stmt = connApp.createStatement();
							stmt.setQueryTimeout(60);
							rs = stmt.executeQuery(sql);

							ResultSetMetaData rsmeta = null;
							rsmeta = rs.getMetaData();
							colcount = rsmeta.getColumnCount();

							for (int f = 0; f < colcount; f++) {
								fNameArr.add(rsmeta.getColumnName(f + 1));
								fTypeArr.add(rsmeta.getColumnType(f + 1));
							}
						} // else if (is_mongo)

						int field_match_count = 0;

						for (int c = 0; c < colcount; c++) {
							fName = fNameArr.get(c);

							mylog(LOG_LEVEL_DEBUG, "Checking field (" + fName
									+ ") for column name match...");

							for (int m = 0; m < matchList.size(); m++) {

								int target_id = Integer.parseInt(matchList
										.get(m)[0]);
								int rule_id = Integer
										.parseInt(matchList.get(m)[1]);
								String field_match = matchList.get(m)[7];

								String[] matchArr = field_match.split("\n|\r");

								field_match_count = 0;

								for (int p = 0; p < matchArr.length; p++) {
									if (matchArr[p].trim().length() > 0) {

										if (matchArr[p].toUpperCase().equals(
												fName.toUpperCase())) {
											mylog(LOG_LEVEL_DEBUG,
													"matched exactly : "
															+ matchArr[p]);
											field_match_count += maxRec * 90 / 100;
										}

									} // if (match_line.trim().length()>0)
								} // for (int p=0;p<matchArr.length;p++)

								if (field_match_count > maxRec)
									field_match_count = maxRec;

								if (field_match_count > 0) {
									sql = "insert into tdm_discovery_result (discovery_id,schema_name,table_name,"
											+ " field_name,discovery_target_id,discovery_rule_id,match_count, sample_count) values "
											+ " (?,?,?,?,?,?,?,?)";
									bindlist = new ArrayList<String[]>();
									bindlist.add(new String[] { "INTEGER",
											"" + work_plan_id });
									bindlist.add(new String[] { "STRING",
											"" + aSchema });
									bindlist.add(new String[] { "STRING",
											"" + aTable });
									bindlist.add(new String[] { "STRING",
											"" + fName });
									bindlist.add(new String[] { "INTEGER",
											"" + target_id });
									bindlist.add(new String[] { "INTEGER",
											"" + rule_id });
									bindlist.add(new String[] { "INTEGER",
											"" + field_match_count });
									bindlist.add(new String[] { "INTEGER",
											"" + maxRec });

									execDBBindingConf(sql, bindlist);

								}
							}

						} // for (int c=0;c<colcount;c++)

						recno = 0;
						mylog(LOG_LEVEL_INFO,
								"... Loading Table Sample Data : " + aSchema
										+ "." + aTable);

						if (is_mongo) {

							MongoDatabase mongodb = mongoClient
									.getDatabase(aSchema);
							ArrayList<Document> docs = getDocuments(mongodb,
									aTable, "", maxRec);

							StringBuilder fVal = new StringBuilder();

							for (int d = 0; d < docs.size(); d++) {

								String[] aRec = new String[colcount];

								for (int f = 0; f < colcount; f++) {

									fName = fNameArr.get(f);
									fType = fTypeArr.get(f);

									fVal.setLength(0);
									try {
										fVal.append(docs.get(d).toJson());
									} catch (Exception e) {
									}

									ArrayList<String[]> keyvalArr = getJsonKeyValue(
											fVal.toString(), "");

									fVal.setLength(0);
									for (int k = 0; k < keyvalArr.size(); k++) {
										String key = keyvalArr.get(k)[0];
										String val = keyvalArr.get(k)[1];

										try {
											Pattern r = Pattern.compile(fName);
											Matcher m = r.matcher(key);
											if (m.find()) {
												if (fVal.length() > 0)
													fVal.append(" ");
												fVal.append(val);
											}

										} catch (Exception e) {
										}

									}

									aRec[f] = fVal.toString();
								}

								recsArr.add(aRec);
							}

						} // if (is_mongo)
						else {
							StringBuilder fVal = new StringBuilder();

							if (rs != null)
								while (rs.next()) {

									if (is_cancelled)
										break;

									heartbeat(TABLE_TDM_WORKER, 0, 0);
									recno++;

									if (recno > maxRec)
										break;

									String[] aRec = new String[colcount];
									for (int f = 0; f < colcount; f++) {

										fName = fNameArr.get(f);
										fType = fTypeArr.get(f);

										fVal.setLength(0);

										// if Date
										if ((fType == 91) || (fType == 92)
												|| (fType == 93)) {
											Date d = rs.getDate(f + 1);
											if (d == null)
												fVal.append("");
											else
												fVal.append(new SimpleDateFormat(
														genLib.DEFAULT_DATE_FORMAT)
														.format(d));

										} else {
											// if string...
											if ((fType > 0) && (fType < 100))
												try {
													fVal.append(rs
															.getString(f + 1));
													// fVal=rs.getString(f+1);
												} catch (Exception e) {
													fVal.append("");
												}
										}

										if (fVal == null
												|| fVal.toString().equals(
														"null")) {
											fVal.setLength(0);
										}

										try {
											aRec[f] = fVal.toString();
										} catch (Exception e) {
										}

									} // for (int f=0;f<colcount;f++) {
									recsArr.add(aRec);
									aRec = null;
								} // while

							rs.close();
							stmt.close();
						} // if (is_mongo)

						// ----------------------------------------
						// START MATCH TEST COL by COL
						// -----------------------------------------

						field_match_count = 0;

						recno = 0;

						StringBuilder fVal = new StringBuilder();

						for (int c = 0; c < colcount; c++) {

							if (c == 0)
								recno++;

							int target_id = 0;
							int rule_id = 0;
							// String match_rule="";
							String regex = "";
							String js_code = "";

							if (is_cancelled)
								break;

							if (getCancelFlag("tdm_worker")) {
								mylog(LOG_LEVEL_WARNING, "Worker Cancelled...");
								is_cancelled = true;
							}

							Pattern pattern = null;
							int match_count = 0;

							if (arrFieldsToSkip.indexOf(fNameArr.get(c)) > -1)
								continue;

							for (int m = 0; m < matchList.size(); m++) {
								if (is_cancelled)
									break;

								target_id = Integer
										.parseInt(matchList.get(m)[0]);
								rule_id = Integer.parseInt(matchList.get(m)[1]);
								regex = matchList.get(m)[5];
								js_code = matchList.get(m)[6];

								match_count = 0;

								// if regex
								if (matchList.get(m)[4].equals("MATCHES"))
									try {
										pattern = Pattern.compile(regex,
												Pattern.CASE_INSENSITIVE);
									} catch (Exception e) {
										pattern = null;
										mylog(LOG_LEVEL_ERROR,
												"Exception@Pattern.compile REGEX : "
														+ regex);
										mylog(LOG_LEVEL_ERROR,
												"Exception@Pattern.compile ERROR : "
														+ e.getMessage());
										e.printStackTrace();
									}

								for (int r = 0; r < recsArr.size(); r++) {

									if (is_cancelled)
										break;
									heartbeat(TABLE_TDM_WORKER,
											worker_done_count, worker_id);

									fVal.setLength(0);
									fVal.append(recsArr.get(r)[c]);

									if ((fVal.length() > 5)
											&& (fVal.length() <= 255)) {

										// regex
										if (matchList.get(m)[4]
												.equals("MATCHES")
												&& pattern != null
												&& regex.trim().length() > 0) {
											Matcher matcher = pattern
													.matcher(fVal.toString());
											while (matcher.find()) {
												// mylog(aTable+"."+fNameArr.get(c)+
												// " is MATCHED at \"" +
												// matcher.group()+
												// "\" with => "+ target_desc +
												// " (" + rule_desc + ")");
												match_count++;
												break;
											}
										} // if regex

										// if Javascript
										if (matchList.get(m)[4].equals("JS")
												&& js_code.trim().length() > 0) {
											String res = "false";
											try {
												res = maskJavascript(0,
														fVal.toString(), null,
														js_code, null, null,
														null, null);
											} catch (Exception e) {
												e.printStackTrace();
												res = "false";
											}

											if (res.equals("true")) {
												// mylog(aTable+"."+fNameArr.get(c)+
												// " is MATCHED  with JS CODE  => "+
												// target_desc + " (" +
												// rule_desc + ")");
												match_count++;
											}
										} // jscript match

										// if SQL
										if (matchList.get(m)[4]
												.equals(MASK_RULE_SQL)
												&& regex.trim().length() > 0) {
											String match_sql = regex;
											bindlist.clear();
											if (match_sql.contains("?"))
												bindlist.add(new String[] {
														"STRING",
														fVal.toString() });
											ArrayList<String[]> tmpSQLArr = getDbArrayApp(
													match_sql, 1, bindlist, 5);
											if (tmpSQLArr != null
													&& tmpSQLArr.size() > 0) {
												match_count++;
											}

										}
									}

								}

								if (match_count > 0
										&& match_count > field_match_count) {

									bindlist = new ArrayList<String[]>();
									bindlist.add(new String[] { "INTEGER",
											"" + work_plan_id });
									bindlist.add(new String[] { "STRING",
											"" + aSchema });
									bindlist.add(new String[] { "STRING",
											"" + aTable });
									bindlist.add(new String[] { "STRING",
											"" + fNameArr.get(c) });
									bindlist.add(new String[] { "INTEGER",
											"" + target_id });
									bindlist.add(new String[] { "INTEGER",
											"" + rule_id });

									if (field_match_count > 0) {
										sql = "delete from tdm_discovery_result "
												+ " where "
												+ " work_plan_id=? "
												+ " and schema_name=? "
												+ " and table_name=? "
												+ " and field_name=? "
												+ " and discovery_target_id=? "
												+ " and discovery_rule_id=? ";
										execDBBindingConf(sql, bindlist);

									}

									sql = "insert into tdm_discovery_result (discovery_id,schema_name,table_name,"
											+ " field_name,discovery_target_id,discovery_rule_id,match_count, sample_count) values "
											+ " (?,?,?,?,?,?,?,?)";

									bindlist.add(new String[] { "INTEGER",
											"" + match_count });
									bindlist.add(new String[] { "INTEGER",
											"" + recsArr.size() });

									execDBBindingConf(sql, bindlist);

									match_count = 0;
								}

							} // for (int m=0;m<matchList.size();m++) {

						} // for c=0
						recsArr = null;
					} catch (Exception e) {
						e.printStackTrace();
					}

					done_count++;
					success_count++;

					worker_done_count++;
				} // if table_name.len>0

			} // for int i=0;

			duration = System.currentTimeMillis() - start_ts;
			if (success_count == done_count & !is_cancelled) {
				finishTask(task_id, work_package_id, work_plan_id, done_count,
						success_count, fail_count, duration);
				mylog(LOG_LEVEL_INFO, "task " + task_id + " is finished by "
						+ worker_id + ". Took  [" + duration + "] msecs for ("
						+ done_count + ") record(s)");
			} else
				resumeTasksByWorkerId(worker_id);

		} catch (Exception e) {
			mylog(LOG_LEVEL_ERROR, "Exception@work : " + e.getMessage());
			myerr("Exception@work : " + e.getMessage());
			e.printStackTrace();
		} finally {
			// closeApp();
			if (is_mongo)
				try {
					mongoClient.close();
				} catch (Exception e) {
				}
		}

	}

	// **********************************************
	void createDir(String dir) {
		File theDir = new File(dir);
		if (!theDir.exists()) {
			mylog(LOG_LEVEL_INFO, "creating directory: " + dir);

			try {
				theDir.mkdir();
			} catch (SecurityException se) {
				mylog(LOG_LEVEL_ERROR, genLib.getStackTraceAsStringBuilder(se)
						.toString());
			}
		}
	}

	// ****************************************
	boolean autoCompile(int work_plan_id, String script_id, String script_name,
			String source_code) {
		boolean ret1 = true;

		mylog(LOG_LEVEL_INFO,
				"------------------------------------------------");
		mylog(LOG_LEVEL_INFO, "            AUTOMATION COMPILE START ");
		mylog(LOG_LEVEL_INFO,
				"------------------------------------------------");

		StringBuilder a_line = new StringBuilder();

		String HomePath = getParamByName("TDM_PROCESS_HOME");
		String username = getParamByName("CONFIG_USERNAME");
		String password = decode(getParamByName("CONFIG_PASSWORD"));
		String CONFIG_PACKAGE = nvl(getParamByName("CONFIG_PACKAGE"),
				"com.mayatech.tdm");

		String CONFIG_SOURCE_PATH = "temp" + File.separator + "WPL_"
				+ work_plan_id;
		String AUTOMATION_PATH = HomePath + File.separator + CONFIG_SOURCE_PATH;

		String CONFIG_CLASS_NAME = script_name;

		String class_file = AUTOMATION_PATH;
		String[] arr = CONFIG_PACKAGE.split("\\.");
		for (int i = 0; i < arr.length; i++)
			class_file = class_file + File.separator + arr[i];

		class_file = class_file + File.separator + CONFIG_CLASS_NAME + ".class";

		File fdel = new File(class_file);
		if (fdel.exists())
			fdel.delete();

		createDir(AUTOMATION_PATH);

		String AUTOMATION_FILE_PATH = AUTOMATION_PATH + File.separator
				+ CONFIG_CLASS_NAME + ".java";

		mylog(LOG_LEVEL_INFO, "Writing source file : " + AUTOMATION_FILE_PATH);

		text2file(source_code, AUTOMATION_FILE_PATH);

		String OS = System.getProperty("os.name").toLowerCase();
		String file_to_run = "";

		if (OS.indexOf("win") >= 0)
			file_to_run = "StartAutoComp.bat";

		if (OS.indexOf("nix") >= 0 || OS.indexOf("nux") >= 0
				|| OS.indexOf("aix") > 0 || OS.indexOf("sunos") >= 0)
			file_to_run = "startAutoComp.sh";

		a_line.append("Executing : " + HomePath + File.separator + file_to_run
				+ "\n");

		try {

			ProcessBuilder pb = new ProcessBuilder(file_to_run);

			Map<String, String> mp = pb.environment();
			mp.put("CONFIG_USERNAME", username);
			mp.put("CONFIG_PASSWORD", password);
			mp.put("CONFIG_SOURCE_PATH", CONFIG_SOURCE_PATH);
			mp.put("CONFIG_PACKAGE", CONFIG_PACKAGE);
			mp.put("CONFIG_SOURCE_FILE", CONFIG_CLASS_NAME);

			pb.directory(new File(HomePath));

			Process p = pb.start();

			if (p == null)
				ret1 = false;

			InputStream is = p.getInputStream();
			InputStream iserr = p.getErrorStream();

			BufferedReader scr = new BufferedReader(new InputStreamReader(is,
					"UTF-8"));
			BufferedReader serr = new BufferedReader(new InputStreamReader(
					iserr, "UTF-8"));
			long start_ts = System.currentTimeMillis();

			while (p != null && true) {
				heartbeat(TABLE_TDM_WORKER, 1, worker_id);

				boolean is_ready = false;
				char rc = 'x';
				int ri = 0;
				long elapsed_time = System.currentTimeMillis() - start_ts;
				if (elapsed_time > 10000)
					break;
				try {
					is_ready = scr.ready();
				} catch (Exception e) {
					is_ready = false;
				}
				if (!is_ready)
					try {
						is_ready = serr.ready();
					} catch (Exception e) {
						is_ready = false;
					}

				if (!is_ready)
					try {
						Thread.sleep(500);
						if (new File(class_file).exists())
							break;
					} catch (Exception e) {
					}

				if (is_ready)
					while (true) {
						heartbeat(TABLE_TDM_WORKER, 1, worker_id);
						try {
							try {
								is_ready = scr.ready();
							} catch (Exception e) {
								is_ready = false;
								e.printStackTrace();
							}
							if (!is_ready)
								try {
									is_ready = serr.ready();
								} catch (Exception e) {
									is_ready = false;
								}

							if (!is_ready)
								try {
									Thread.sleep(500);
								} catch (Exception e) {
								}

							if (is_ready) {
								if (scr.ready())
									ri = scr.read();
								else
									ri = serr.read();

								rc = (char) ri;
								// to reset timeout
								start_ts = System.currentTimeMillis();

							} else
								ri = -1;
						} catch (IOException e) {
							e.printStackTrace();
							break;
						}
						if (ri == -1)
							break;
						a_line.append(rc);
						if (a_line.indexOf("exit") > -1)
							break;

					}

			}

		} catch (Exception e) {
			e.printStackTrace();
			ret1 = false;
		}

		File f = new File(class_file);
		if (!f.exists())
			ret1 = false;

		File fsrc = new File(AUTOMATION_FILE_PATH);
		if (fsrc.exists())
			fsrc.delete();

		mylog(LOG_LEVEL_INFO, a_line.toString());
		mylog(LOG_LEVEL_INFO, "Compile Result : " + ret1);
		return ret1;

	}

	// ****************************************
	boolean autoExecute(int work_plan_id, int work_package_id, int task_id,
			String script_id, String script_name) {
		boolean ret1 = true;

		mylog(LOG_LEVEL_INFO,
				"------------------------------------------------");
		mylog(LOG_LEVEL_INFO, "            AUTOMATION EXEC START ");
		mylog(LOG_LEVEL_INFO,
				"------------------------------------------------");

		StringBuilder a_line = new StringBuilder();

		String HomePath = getParamByName("TDM_PROCESS_HOME");
		String username = getParamByName("CONFIG_USERNAME");
		String password = decode(getParamByName("CONFIG_PASSWORD"));

		String CONFIG_SOURCE_PATH = "temp" + File.separator + "WPL_"
				+ work_plan_id;

		String CONFIG_PACKAGE = nvl(getParamByName("CONFIG_PACKAGE"),
				"com.mayatech.tdm");
		String CONFIG_CLASS_NAME = script_name;

		String OS = System.getProperty("os.name").toLowerCase();
		String file_to_run = "";

		if (OS.indexOf("win") >= 0)
			file_to_run = "StartAutoRun.bat";

		if (OS.indexOf("nix") >= 0 || OS.indexOf("nux") >= 0
				|| OS.indexOf("aix") > 0 || OS.indexOf("sunos") >= 0)
			file_to_run = "startAutoRun.sh";

		a_line.append("Executing : " + HomePath + File.separator + file_to_run
				+ "\n");

		int test_run_id = (int) (System.currentTimeMillis() % Integer.MAX_VALUE) + 1;

		String sql = "select env_id, run_options from tdm_work_plan where id=?";

		String run_options = "";
		String domain_instance_id = "";

		try {
			ArrayList<String[]> arr = getDbArrayConfInt(sql, 1, work_plan_id);
			domain_instance_id = arr.get(0)[0];
			run_options = arr.get(0)[1];
		} catch (Exception e) {
		}

		String automation_hub = getAutomationRunOptionVal(run_options,
				"AUTOMATION_HUB");
		String automation_node = getAutomationRunOptionVal(run_options,
				"AUTOMATION_NODE");
		String browser = getAutomationRunOptionVal(run_options,
				"AUTOMATION_BROWSER");
		String automation_lib = getAutomationRunOptionVal(run_options,
				"AUTOMATION_LIBRARY");
		String params_in = getAutomationRunOptionVal(run_options,
				"AUTOMATION_PARAMS_IN");

		mylog(LOG_LEVEL_INFO, "AUTOMATION_HUB        : {" + automation_hub
				+ "}");
		mylog(LOG_LEVEL_INFO, "AUTOMATION_NODE       : {" + automation_node
				+ "}");
		mylog(LOG_LEVEL_INFO, "AUTOMATION_BROWSER    : {" + browser + "}");
		mylog(LOG_LEVEL_INFO, "AUTOMATION_LIBRARY    : {" + automation_lib
				+ "}");
		mylog(LOG_LEVEL_INFO, "AUTOMATION_PARAMS_IN  : {" + params_in + "}");

		String sel_hub = "http://" + automation_hub + "/wd/hub";
		String start_url = "http://" + automation_hub + "/grid/console";

		String run_host_info = "" + "SEL_HUB=" + sel_hub + ";" + "SEL_NODE="
				+ automation_node + ";" + "SEL_START_URL=" + start_url + ";"
				+ "SEL_BROWSER=" + browser + ";";

		mylog(LOG_LEVEL_INFO, "run_host_info  : " + run_host_info);

		sql = "insert into tdm_test_run "
				+ " (id, script_id, work_package_id, task_id, domain_instance_id, automation_lib, "
				+ " params_in, run_host_info, test_status, crdate ) "
				+ " values (?, ?, ? , ?,  ?,  ?, ?, ?, 'NEW', now())";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INGEGER", "" + test_run_id });
		bindlist.add(new String[] { "INGEGER", "" + script_id });
		bindlist.add(new String[] { "INGEGER", "" + work_package_id });
		bindlist.add(new String[] { "INGEGER", "" + task_id });
		bindlist.add(new String[] { "INGEGER", "" + domain_instance_id });
		bindlist.add(new String[] { "STRING", "" + automation_lib });
		bindlist.add(new String[] { "STRING", "" + params_in });
		bindlist.add(new String[] { "STRING", "" + run_host_info });

		execDBBindingConf(sql, bindlist);

		long exec_start_ts = System.currentTimeMillis();
		sql = "update tdm_test_run set startdate=now() where id=" + test_run_id;
		execDBConf(sql);

		try {

			ProcessBuilder pb = new ProcessBuilder(file_to_run);

			Map<String, String> mp = pb.environment();
			mp.put("CONFIG_USERNAME", username);
			mp.put("CONFIG_PASSWORD", password);
			mp.put("CONFIG_SOURCE_PATH", CONFIG_SOURCE_PATH);
			mp.put("CONFIG_PACKAGE", CONFIG_PACKAGE);
			mp.put("CONFIG_SOURCE_FILE", CONFIG_CLASS_NAME);
			mp.put("CONFIG_AUTOMATION_SCRIPT_RUN_ID", "" + test_run_id);
			mp.put("CONFIG_AUTOMATION_WORKER_ID", "" + worker_id);

			pb.directory(new File(HomePath));

			Process p = pb.start();

			if (p == null)
				ret1 = false;

			InputStream is = p.getInputStream();
			InputStream iserr = p.getErrorStream();

			BufferedReader scr = new BufferedReader(new InputStreamReader(is,
					"UTF-8"));
			BufferedReader serr = new BufferedReader(new InputStreamReader(
					iserr, "UTF-8"));
			long start_ts = System.currentTimeMillis();

			while (p != null && true) {
				heartbeat(TABLE_TDM_WORKER, 1, worker_id);
				boolean is_ready = false;
				char rc = 'x';
				int ri = 0;
				long elapsed_time = System.currentTimeMillis() - start_ts;
				if (elapsed_time > 60000)
					break;
				try {
					is_ready = scr.ready();
				} catch (Exception e) {
					is_ready = false;
				}
				if (!is_ready)
					try {
						is_ready = serr.ready();
					} catch (Exception e) {
						is_ready = false;
					}

				if (!is_ready)
					try {
						Thread.sleep(500);
					} catch (Exception e) {
					}

				if (is_ready)
					while (true) {
						heartbeat(TABLE_TDM_WORKER, 1, worker_id);
						setTaskLastActivity(work_plan_id, work_package_id,
								task_id);
						try {
							try {
								is_ready = scr.ready();
							} catch (Exception e) {
								is_ready = false;
								e.printStackTrace();
							}
							if (!is_ready)
								try {
									is_ready = serr.ready();
								} catch (Exception e) {
									is_ready = false;
								}

							if (!is_ready)
								try {
									Thread.sleep(500);
								} catch (Exception e) {
								}

							if (is_ready) {
								if (scr.ready())
									ri = scr.read();
								else
									ri = serr.read();

								rc = (char) ri;
								// to reset timeout
								start_ts = System.currentTimeMillis();

							} else
								ri = -1;
						} catch (IOException e) {
							e.printStackTrace();
							break;
						}
						if (ri == -1)
							break;
						a_line.append(rc);
						if (a_line.indexOf("###TEST_RESULT_FAIL###") > -1
								|| a_line.indexOf("###TEST_RESULT_SUCCESS###") > -1
								|| a_line.indexOf("###TEST_RESULT_RETRY###") > -1)
							break;
					}

				if (a_line.indexOf("###TEST_RESULT_FAIL###") > -1
						|| a_line.indexOf("###TEST_RESULT_SUCCESS###") > -1
						|| a_line.indexOf("###TEST_RESULT_RETRY###") > -1)
					break;

			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		String test_exec_status = "FAIL";

		if (a_line.indexOf("###TEST_RESULT_SUCCESS###") > -1)
			test_exec_status = "SUCCESS";
		else if (a_line.indexOf("###TEST_RESULT_RETRY###") > -1) {
			test_exec_status = "RETRY";
			ret1 = false;
		} else {
			test_exec_status = "FAIL";
			ret1 = false;
		}

		int exec_duration = (int) (System.currentTimeMillis() - exec_start_ts);
		sql = "update tdm_test_run set test_status='" + test_exec_status
				+ "',enddate=now(),duration=" + exec_duration + " where id="
				+ test_run_id;
		execDBConf(sql);

		mylog(LOG_LEVEL_INFO, a_line.toString());
		mylog(LOG_LEVEL_INFO, "Compile Result : " + ret1);

		return ret1;

	}

	// ****************************************
	void setTaskLastActivity(int work_plan_id, int work_package_id, int task_id) {

		if (next_task_activity_ts > System.currentTimeMillis())
			return;
		next_task_activity_ts = System.currentTimeMillis()
				+ NEXT_TASK_ACTIVITY_INTERVAL;

		String sql = "update tdm_task_" + work_plan_id + "_" + work_package_id
				+ " set last_activity_date=now() where id=? ";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + task_id });
		execDBBindingConf(sql, bindlist);

		sql = "update tdm_task_assignment set last_activity_date=now() where task_id=? and work_package_id=?";
		bindlist.add(new String[] { "INTEGER", "" + work_package_id });
		execDBBindingConf(sql, bindlist);

	}

	// ***************************************
	public void runWorkerDOAUTO(int task_id, int work_plan_id,
			int work_package_id, byte[] task_info) {
		// ***************************************

		long start_ts = System.currentTimeMillis();
		long duration = 0;
		startTask(task_id, work_plan_id, work_package_id);
		String source_code = nvl(uncompress(task_info), "");
		String sql = "select script_id, task_name script_name "
				+ " from tdm_task_" + work_plan_id + "_" + work_package_id
				+ " where id=?";

		ArrayList<String[]> scriptArr = getDbArrayConfInt(sql, 1, task_id);

		String script_id = "";
		String script_name = "";

		try {
			script_id = scriptArr.get(0)[0];
			script_name = scriptArr.get(0)[1];
		} catch (Exception e) {
		}

		boolean is_success = false;

		try {

			if (script_id.length() > 0) {
				mylog(LOG_LEVEL_INFO, "Compiling : " + script_name + " ...");
				is_success = autoCompile(work_plan_id, script_id, script_name,
						source_code);
				mylog(LOG_LEVEL_INFO, "Compile successfull? " + is_success);

				if (is_success) {
					mylog(LOG_LEVEL_INFO, "Executing : " + script_name + " ...");
					is_success = autoExecute(work_plan_id, work_package_id,
							task_id, script_id, script_name);
					mylog(LOG_LEVEL_INFO, "Execute successfull? " + is_success);
				}

			} // if (script_id.length()>0)

			duration = System.currentTimeMillis() - start_ts;

			int success_count = 1;
			int fail_count = 0;

			if (!is_success) {
				success_count = 0;
				fail_count = 1;
			}

			if (is_success)
				finishTask(task_id, work_package_id, work_plan_id, 1,
						success_count, fail_count, duration);
			else
				resumeTasksByWorkerId(worker_id);

			mylog(LOG_LEVEL_INFO, "task " + task_id + " is finished by "
					+ worker_id + ". Took  [" + duration + "] msecs for (" + 1
					+ ") record(s)");

		} catch (Exception e) {
			mylog(LOG_LEVEL_ERROR, "Exception@work : " + e.getMessage());

			myerr("Exception@work : " + e.getMessage());

			e.printStackTrace();
		} finally {

		}

	}

	// ***************************************
	private ArrayList<int[]> getCombination(ArrayList<String[]> pkArr,
			ArrayList<String[]> fkArr) {
		// ***************************************
		ArrayList<int[]> ret1 = new ArrayList<int[]>();
		int[][] validFKIdsArr = new int[pkArr.size()][200];
		int[] validFKIdCountArr = new int[pkArr.size()];

		for (int i = 0; i < pkArr.size(); i++) {
			validFKIdCountArr[i] = 0;
			String aPkFType = pkArr.get(i)[1];

			for (int f = 0; f < fkArr.size(); f++) {
				String aFkFType = fkArr.get(f)[1];

				if (aFkFType.equals(aPkFType)
						|| fieldtype2bindtype(aFkFType, "1").equals("STRING")) {
					validFKIdsArr[i][validFKIdCountArr[i]] = f;
					validFKIdCountArr[i]++;
				}
			} // for f
			if (validFKIdCountArr[i] == 0)
				return ret1;
		} // for i

		// multipy all
		int combination_length = 1;
		for (int i = 0; i < validFKIdCountArr.length; i++)
			combination_length = combination_length * validFKIdCountArr[i];

		for (int i = 0; i < pkArr.size(); i++) {
			int add = combination_length / validFKIdCountArr[i] - 1;
			int start_i = validFKIdCountArr[i];
			for (int a = 0; a < add; a++) {
				for (int j = 0; j < validFKIdCountArr[i]; j++) {
					validFKIdsArr[i][start_i] = validFKIdsArr[i][j];
					start_i++;
				}
			} // a
		} // for i

		for (int i = 0; i < combination_length; i++) {
			int[] ax = new int[pkArr.size()];
			for (int a = 0; a < pkArr.size(); a++) {
				ax[a] = validFKIdsArr[a][i];
			}
			ret1.add(ax);
		}

		return ret1;
	}

	// ***************************************
	private int countUnique(ArrayList<String[]> arrin,
			ArrayList<String[]> fklist, int[] combArr) {
		// ***************************************

		ArrayList<String> tmparr = new ArrayList<String>();
		StringBuilder arr = new StringBuilder();
		if (combArr.length > 0)
			for (int i = 0; i < arrin.size(); i++) {

				arr.setLength(0);

				for (int j = 0; j < combArr.length; j++) {
					String a_val = arrin.get(i)[Integer.parseInt(fklist
							.get(combArr[j])[2])];
					// herhangi birisnde null varsa geç..
					// if (a_val.length()==0) return 0;
					arr.append(a_val);
				}

				// if (i % 10==0) mylog(""+i+"-"+arr.toString());

				if (!tmparr.contains(arr.toString()))
					tmparr.add(arr.toString());

			}

		return tmparr.size();

	}

	// ***************************************
	public void runWorkerDISCCOPY(int task_id, int work_plan_id,
			int work_package_id, byte[] task_info) {
		// ***************************************

		long start_ts = System.currentTimeMillis();
		long duration = 0;
		startTask(task_id, work_plan_id, work_package_id);

		String[] recs = nvl(uncompress(task_info), "").split("\n");

		int done_count = 0;
		int success_count = 0;
		int fail_count = 0;

		int maxRec = 100;

		try {
			maxRec = Integer.parseInt(getParamByName("DISCOVERY_SAMPLE_SIZE"));
		} catch (Exception e) {
			maxRec = 100;
		}

		try {
			if (appdb_test_connection_need || connApp == null) {
				connApp = getconn(app_connstr, app_driver, app_username,
						app_password);
				if (!testconn(connApp)) {
					closeApp();
					return;
				}
				appdb_test_connection_need = false;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		String sql = "";

		boolean is_cancelled = false;
		try {

			for (int i = 0; i < recs.length; i++) {
				String table_name = recs[i];

				if (table_name.length() > 0) {
					String sourceTableAll = table_name.split("\\|")[0];
					String targetTableAll = table_name.split("\\|")[1];

					String sourceSchema = sourceTableAll.split("\\.")[0];
					String sourceTable = sourceTableAll.split("\\.")[1];

					String targetSchema = targetTableAll.split("\\.")[0];
					String targetTable = targetTableAll.split("\\.")[1];

					sql = "select count(1) from tdm_discovery_rel " + " where "
							+ " discovery_id=" + work_plan_id
							+ " and source_tab_name='" + sourceTableAll + "'"
							+ " and rel_tab_name='" + targetTableAll + "'";

					String isalreadythere = getDbArrayConf(sql, 1).get(0)[0];

					if (isalreadythere.equals("0")) {
						mylog(LOG_LEVEL_INFO, "Discovering " + targetSchema
								+ "." + targetTable + " for Copy ("
								+ sourceTableAll + ")");

						ArrayList<String> sourceFieldNameArr = new ArrayList<String>();
						ArrayList<String> sourceFieldTypeArr = new ArrayList<String>();
						ArrayList<String[]> sourceRecsArr = new ArrayList<String[]>();
						ArrayList<String> importedKeyFields = new ArrayList<String>();

						sql = "delete from tdm_discovery_rel where "
								+ " discovery_id=" + work_plan_id
								+ " and source_tab_name='" + sourceTableAll
								+ "' and rel_tab_name='" + targetTableAll + "'";
						execDBBindingConf(sql, new ArrayList<String[]>());

						// -----------------------------------------
						// GET TARGET TABLE SAMPLE
						// -----------------------------------------
						sql = " select * from "
								+ addStartEndForTable(sourceTableAll);

						try {
							Statement stmt = connApp.createStatement();
							ResultSet rs = stmt.executeQuery(sql);
							ResultSetMetaData rsmeta = rs.getMetaData();
							int colcount = rsmeta.getColumnCount();

							for (int f = 0; f < colcount; f++) {
								sourceFieldNameArr.add(rsmeta
										.getColumnName(f + 1));
								sourceFieldTypeArr.add(rsmeta
										.getColumnTypeName(f + 1));
							}
							rs.close();
							stmt.close();

							sourceRecsArr = getDbArrayApp(sql, 1,
									new ArrayList<String[]>(), 1000);

							if (sourceRecsArr.size() > 0) {
								// ----------------------------------------
								// START COMPARING
								// -----------------------------------------

								ArrayList<String[]> pklist = new ArrayList<String[]>();
								ArrayList<String[]> fklist = new ArrayList<String[]>();
								ResultSet rspkfk = null;
								DatabaseMetaData meta = null;

								try {
									meta = connApp.getMetaData();
									rspkfk = meta.getPrimaryKeys(sourceSchema,
											null, sourceTable);
									while (rspkfk.next())
										pklist.add(new String[] {
												rspkfk.getString("COLUMN_NAME"),
												"x" });

									rspkfk.close();

									if (pklist.size() == 0) {
										rspkfk = meta.getPrimaryKeys(null,
												sourceSchema, sourceTable);
										while (rspkfk.next())
											pklist.add(new String[] {
													rspkfk.getString("COLUMN_NAME"),
													"x" });
										rspkfk.close();
									}
								} catch (Exception e) {
									e.printStackTrace();
								}

								String check_sql = "select 1 from "
										+ addStartEndForTable(sourceTableAll)
										+ " where ";

								String primary_key_fields = "";
								if (pklist.size() > 0) {

									// set field types for found PKs
									for (int p = 0; p < pklist.size(); p++) {
										if (p > 0)
											primary_key_fields = primary_key_fields
													+ ",";
										primary_key_fields = primary_key_fields
												+ pklist.get(p)[0];
										for (int j = 0; j < sourceFieldNameArr
												.size(); j++) {
											if (sourceFieldNameArr.get(j)
													.equals(pklist.get(p)[0])) {
												String[] a = new String[] {
														pklist.get(p)[0],
														sourceFieldTypeArr
																.get(j), "" + j };
												pklist.set(p, a);
												if (p > 0)
													check_sql = check_sql
															+ " and ";
												check_sql = check_sql
														+ pklist.get(p)[0]
														+ "=?";
												break; // j
											}
										} // for i

									} // for (int p=0;p<pklist.size();p++)

									mylog(LOG_LEVEL_DEBUG, " check sql : "
											+ check_sql);

									importedKeyFields.clear();

									// get Foreign keys of the target table
									mylog(LOG_LEVEL_INFO,
											"get foreign table for "
													+ targetSchema + "."
													+ targetTable);
									try {
										meta = connApp.getMetaData();
										rspkfk = meta
												.getImportedKeys(targetSchema,
														null, targetTable);
										while (rspkfk.next())
											if (rspkfk
													.getString("PKTABLE_NAME")
													.equals(sourceTable))
												fklist.add(new String[] {
														rspkfk.getString("FKCOLUMN_NAME"),
														"x" });
											else
												importedKeyFields
														.add(rspkfk
																.getString("FKCOLUMN_NAME"));

										rspkfk.close();

										if (fklist.size() == 0) {
											rspkfk = meta.getImportedKeys(
													connApp.getCatalog(),
													targetSchema, targetTable);
											while (rspkfk.next())
												if (rspkfk.getString(
														"PKTABLE_NAME").equals(
														sourceTable))
													fklist.add(new String[] {
															rspkfk.getString("FKCOLUMN_NAME"),
															"x" });

												else
													importedKeyFields
															.add(rspkfk
																	.getString("FKCOLUMN_NAME"));
											rspkfk.close();
										}
									} catch (Exception e) {
										e.printStackTrace();
									} finally {
										try {
											rspkfk.close();
										} catch (Exception ec) {
										}
									}

									// if a relation was found, add it and skip
									// to next
									if (fklist.size() > 0) {
										mylog(LOG_LEVEL_INFO,
												"*** a foreign key was found for "
														+ targetTableAll);

										String foreign_field_list = "";
										for (int f = 0; f < fklist.size(); f++) {
											if (f > 0)
												foreign_field_list = foreign_field_list
														+ ",";
											foreign_field_list = foreign_field_list
													+ fklist.get(f)[0];
										}

										int count = getDbArrayApp(
												"select 1 from "
														+ addStartEndForTable(targetTableAll),
												1, new ArrayList<String[]>(),
												10).size();

										if (count > 0)
											addRelation(work_plan_id, 100,
													sourceTableAll,
													targetTableAll,
													primary_key_fields,
													foreign_field_list);
										continue;
									}

									int target_pk_found = 0;
									String target_found_pk_field = "";

									// Get indexed columns of target table
									mylog(LOG_LEVEL_INFO, "get index info for "
											+ targetSchema + "." + targetTable);
									fklist.clear();
									try {
										rspkfk = meta.getIndexInfo(
												targetSchema, null,
												targetTable, false, true);
										while (rspkfk.next()) {
											String field_name = rspkfk
													.getString("COLUMN_NAME");
											if (!fklist.contains(field_name)
													&& field_name != null
													&& !field_name
															.equals("null"))
												fklist.add(new String[] {
														rspkfk.getString("COLUMN_NAME"),
														"x" });
										}
									} catch (Exception e) {
										mylog(LOG_LEVEL_ERROR,
												"step1Exception:"
														+ e.getMessage());
									} finally {
										rspkfk.close();
									}

									if (fklist.size() == 0) {
										try {
											rspkfk = meta.getIndexInfo(null,
													targetSchema, targetTable,
													false, true);
											while (rspkfk.next()) {
												String field_name = rspkfk
														.getString("COLUMN_NAME");
												if (!fklist
														.contains(field_name)
														&& field_name != null
														&& !field_name
																.equals("null"))
													fklist.add(new String[] {
															rspkfk.getString("COLUMN_NAME"),
															"x" });
											}
										} catch (Exception e) {
											mylog(LOG_LEVEL_ERROR,
													"step2Exception:"
															+ e.getMessage());
										} finally {
											rspkfk.close();
										}

									}

									if (fklist.size() == 0) {

										try {
											rspkfk = meta.getIndexInfo(
													connApp.getCatalog(),
													targetSchema, targetTable,
													false, true);
											while (rspkfk.next()) {
												String field_name = rspkfk
														.getString("COLUMN_NAME");
												if (!fklist
														.contains(field_name)
														&& field_name != null
														&& !field_name
																.equals("null"))
													fklist.add(new String[] {
															rspkfk.getString("COLUMN_NAME"),
															"x" });
											}
										} catch (Exception e) {
											mylog(LOG_LEVEL_ERROR,
													"step2.1Exception:"
															+ e.getMessage());
										} finally {
											rspkfk.close();
										}

									}
									mylog(LOG_LEVEL_INFO,
											"get index ok. index found : "
													+ fklist.size());

									// clear imported key fields from fkarray if
									// any
									int fk_size = fklist.size();
									for (int f = fk_size - 1; f >= 0; f--) {
										String fname = fklist.get(f)[0];
										if (importedKeyFields.contains(fname))
											fklist.remove(f);
									}

									// clear duplicated fields from fklist
									int target_fk_size = fklist.size();
									for (int f = target_fk_size - 1; f >= 0; f--) {
										String fname = fklist.get(f)[0];
										for (int j = 0; j < f - 1; f++) {
											String dup_fname = fklist.get(j)[0];
											if (dup_fname.equals(fname)) {
												fklist.remove(f);
												break;
											}
										} // for (int j=0;j<f-1;f++)
									}

									ArrayList<String> targetFieldNameArr = new ArrayList<String>();
									ArrayList<String> targetFieldTypeArr = new ArrayList<String>();
									ArrayList<String[]> targetRecsArr = new ArrayList<String[]>();

									sql = "select * from "
											+ addStartEndForTable(targetTableAll);

									Statement stmt2 = connApp.createStatement();
									ResultSet rs2 = stmt2.executeQuery(sql);
									ResultSetMetaData rsmeta2 = rs2
											.getMetaData();
									colcount = rsmeta2.getColumnCount();

									for (int f = 0; f < colcount; f++) {
										targetFieldNameArr.add(rsmeta2
												.getColumnName(f + 1));
										targetFieldTypeArr.add(rsmeta2
												.getColumnTypeName(f + 1));

									}
									rs2.close();
									stmt2.close();

									// set field types for found FKs
									for (int p = 0; p < fklist.size(); p++) {
										for (int j = 0; j < targetFieldNameArr
												.size(); j++) {
											if (targetFieldNameArr.get(j)
													.equals(fklist.get(p)[0])) {
												String[] a = new String[] {
														fklist.get(p)[0],
														targetFieldTypeArr
																.get(j), "" + j };
												fklist.set(p, a);
												break; // j
											}
										} // for j

									} // for (int p=0;p<fklist.size();p++)

									// find target Primary Keys
									rspkfk = meta.getPrimaryKeys(targetSchema,
											null, targetTable);
									while (rspkfk.next()) {
										String field_name = rspkfk
												.getString("COLUMN_NAME");
										target_pk_found++;
										target_found_pk_field = target_found_pk_field
												+ field_name;
									}
									rspkfk.close();
									if (target_pk_found == 0) {
										rspkfk = meta.getPrimaryKeys(
												connApp.getCatalog(),
												targetSchema, targetTable);
										while (rspkfk.next()) {
											String field_name = rspkfk
													.getString("COLUMN_NAME");
											target_pk_found++;
											target_found_pk_field = target_found_pk_field
													+ field_name;
										}
										rspkfk.close();
									}

									//

									// If there is only 1 field in PK, remove it
									// from indexed fields to skip
									if (target_pk_found == 1)
										for (int f = fklist.size() - 1; f >= 0; f--)
											if (target_found_pk_field
													.equals(fklist.get(f)[0])) {
												fklist.remove(f);
											}

									if (fklist.size() == 0)
										mylog(LOG_LEVEL_INFO,
												" Skipping [No indexed column] : "
														+ targetTableAll
														+ "\n------------------------------\n\n");

									if (fklist.size() > 0) {

										long ts = System.currentTimeMillis();
										targetRecsArr = getDbArrayApp(sql,
												maxRec,
												new ArrayList<String[]>(), 100);
										mylog(LOG_LEVEL_INFO,
												"Fetched "
														+ targetRecsArr.size()
														+ " record(s) in "
														+ (System
																.currentTimeMillis() - ts));

										ArrayList<String[]> bindlist = new ArrayList<String[]>();

										if (targetRecsArr.size() == 0)
											mylog(LOG_LEVEL_INFO,
													" Skipping [No record found] : "
															+ targetTableAll
															+ "\n------------------------------\n\n");

										if (targetRecsArr.size() > 0) {

											mylog(LOG_LEVEL_DEBUG,
													" ** checking for  : "
															+ check_sql);

											ArrayList<int[]> queryCombination = getCombination(
													pklist, fklist);

											String pk_field_names = "";
											for (int p = 0; p < pklist.size(); p++) {
												if (p > 0)
													pk_field_names = ",";
												pk_field_names = pk_field_names
														+ pklist.get(p)[0];
											}

											if (queryCombination.size() == 0)
												mylog(LOG_LEVEL_INFO,
														" Skipping [No valid combination] : "
																+ targetTableAll
																+ "\n------------------------------\n\n");

											for (int t = 0; t < queryCombination
													.size(); t++) {
												String fk_field_names = "";
												int[] aCombination = queryCombination
														.get(t);

												for (int c = 0; c < aCombination.length; c++) {
													int fk_field_id = aCombination[c];
													String fk_field_name = fklist
															.get(fk_field_id)[0];

													if (c > 0)
														fk_field_names = fk_field_names
																+ ",";
													fk_field_names = fk_field_names
															+ fk_field_name;
												}

												mylog(LOG_LEVEL_DEBUG,
														"..................... : "
																+ targetTableAll
																+ ".["
																+ fk_field_names
																+ "]");

												int uniqueCount = countUnique(
														targetRecsArr, fklist,
														aCombination);

												mylog(LOG_LEVEL_DEBUG,
														" unique Count : "
																+ targetTableAll
																+ ".["
																+ fk_field_names
																+ "] ("
																+ uniqueCount
																+ "/"
																+ targetRecsArr
																		.size()
																+ ")");

												if (uniqueCount < (targetRecsArr
														.size() / 10)) {
													mylog(LOG_LEVEL_DEBUG,
															"*** It seems not so unique. skipping : "
																	+ targetTableAll
																	+ ".["
																	+ fk_field_names
																	+ "] ("
																	+ uniqueCount
																	+ "/"
																	+ targetRecsArr
																			.size()
																	+ ")");
													continue;
												}

												int found_count = 0;
												boolean skip = false;

												for (int tr = 0; tr < targetRecsArr
														.size(); tr++) {
													if (tr % 1000 == 0
															|| tr == targetRecsArr
																	.size() - 1)
														mylog(LOG_LEVEL_DEBUG,
																"..."
																		+ targetTableAll
																		+ "["
																		+ (tr + 1)
																		+ "/"
																		+ targetRecsArr
																				.size()
																		+ "]");

													bindlist.clear();
													skip = false;

													for (int c = 0; c < aCombination.length; c++) {
														int fk_field_id = aCombination[c];

														String pk_field_type = pklist
																.get(c)[1];
														String fk_field_val = targetRecsArr
																.get(tr)[Integer
																.parseInt(fklist
																		.get(fk_field_id)[2])];
														String fk_field_type = fieldtype2bindtype(
																pk_field_type,
																fk_field_val);

														if (fk_field_val
																.length() == 0)
															skip = true;
														else {
															if (fk_field_type
																	.equals("INTEGER"))
																try {
																	Integer.parseInt(fk_field_val);
																} catch (Exception e) {
																	skip = true;
																}
															else if (fk_field_type
																	.equals("LONG"))
																try {
																	Integer.parseInt(fk_field_val);
																} catch (Exception e) {
																	skip = true;
																}
														}

														if (skip)
															break;

														bindlist.add(new String[] {
																fk_field_type,
																fk_field_val });
														// mylog(" ** binding : "
														// + fk_field_val);
													}

													if (skip)
														continue;

													heartbeat(TABLE_TDM_WORKER,
															0, worker_id);

													ArrayList<String[]> ctrlArr = getDbArrayApp(
															check_sql, 1,
															bindlist, 5);

													if (ctrlArr != null
															&& ctrlArr.size() > 0)
														found_count++;

												} // for (int
													// tr=0;tr<targetRecsArr.size();tr++)

												mylog(LOG_LEVEL_DEBUG,
														" found         : "
																+ found_count
																+ " / "
																+ targetRecsArr
																		.size());
												double found_rate = (100 * found_count)
														/ targetRecsArr.size();
												mylog(LOG_LEVEL_DEBUG,
														"found_rate:"
																+ found_rate);

												if (found_rate > 0) {
													if (found_rate >= 100)
														found_rate = 99;
													if (!sourceTableAll
															.equals(targetTableAll)
															|| !pk_field_names
																	.equals(fk_field_names))
														addRelation(
																work_plan_id,
																(int) found_rate,
																sourceTableAll,
																targetTableAll,
																primary_key_fields,
																fk_field_names);

												} // if (found_rate>0)

											} // for (int
												// t=0;t<queryCombination.size();t++)

										} // if (targetRecsArr.size()>0)

									} // if (fklist.size()>0)

								} // if (found_pk_count>0)

							} // if (sourceRecsArr.size()>0)

						} catch (Exception e) {
							e.printStackTrace();
						}

						done_count++;
						success_count++;

						worker_done_count++;

					} // if (isthere.equals("0")) {

				} // if table_name.len>0

			} // for int i=0;

			duration = System.currentTimeMillis() - start_ts;
			if (success_count == done_count & !is_cancelled) {
				finishTask(task_id, work_package_id, work_plan_id, done_count,
						success_count, fail_count, duration);
				mylog(LOG_LEVEL_INFO, "task " + task_id + " is finished by "
						+ worker_id + ". Took  [" + duration + "] msecs for ("
						+ done_count + ") record(s)");
			} else
				resumeTasksByWorkerId(worker_id);

		} catch (Exception e) {
			mylog(LOG_LEVEL_ERROR, "Exception@work : " + e.getMessage());

			myerr("Exception@work : " + e.getMessage());

			e.printStackTrace();
		} finally {
			// closeApp();
		}

	}

	// ****************************************
	private void addRelation(int work_plan_id, int found_rate,
			String parent_table, String child_table, String pk_fields,
			String on_fields)
	// ****************************************
	{
		mylog(LOG_LEVEL_INFO, "\n ** :) :) :) found :\n " + parent_table
				+ "==>" + child_table + "[" + on_fields + "]" + "\n");
		String sql = "insert into tdm_discovery_rel ("
				+ " discovery_id, found_rate, source_tab_name, rel_tab_name, rel_type, pk_fields, rel_on_fields) "
				+ " values " + "(" + work_plan_id + "," + found_rate + ","
				+ "'" + parent_table + "'," + "'" + child_table + "',"
				+ "'HAS'," + "'" + pk_fields + "'," + "'" + on_fields + "'"
				+ ")";
		execDBBindingConf(sql, new ArrayList<String[]>());
	}

	// ****************************************
	String addStartEndForTable(String tabin) {
		if (tabin.contains(start_ch))
			return tabin;
		if (app_db_type.equals(genLib.DB_TYPE_JBASE))
			return "\"" + tabin + "\"";
		String ret1 = tabin;

		try {
			ret1 = start_ch + tabin.split("\\.")[0] + end_ch + middle_ch
					+ start_ch + tabin.split("\\.")[1] + end_ch;
		} catch (Exception e) {
			e.printStackTrace();
		}

		return ret1;

	}

	// ****************************************
	String addStartEndForColumn(String colin) {
		if (colin.contains(start_ch))
			return colin;
		if (app_db_type.equals(genLib.DB_TYPE_JBASE))
			return "\"" + colin + "\"";
		String ret1 = colin;

		try {
			ret1 = start_ch + ret1 + end_ch;
		} catch (Exception e) {
			e.printStackTrace();
		}

		return ret1;

	}

	// ***************************************
	private String[] getMaskProfileById(String id) {
		if (mask_Profiles == null)
			mask_Profiles = loadMaskProfiles();
		for (int i = 0; i < mask_Profiles.size(); i++) {

			if (mask_Profiles.get(i)[MASK_PRFL_FLD_ID].equals(id))
				return mask_Profiles.get(i);
		}
		return null;
	}

	// ***************************************
	private String getMaskIdByShortCode(String shortCode) {
		String ret1 = "-1";
		if (mask_Profiles == null)
			mask_Profiles = loadMaskProfiles();
		for (int i = 0; i < mask_Profiles.size(); i++) {
			String[] a_profile = mask_Profiles.get(i);
			if (a_profile[MASK_PRFL_FLD_SHORT_CODE].equals(shortCode)) {
				ret1 = a_profile[MASK_PRFL_FLD_ID];
				break;
			}
		}

		return ret1;
	}

	// ***********************************************************************
	private String maskSQL(int tab_id, String val, String sql_code) {
		// ***********************************************************************
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		if (sql_code.contains("=?") || sql_code.contains("= ?")) {
			bindlist.add(new String[] { "STRING", val });
		}
		ArrayList<String[]> retArr = getDbArrayApp(sql_code, 1, bindlist, 100);

		if (retArr == null || retArr.size() == 0)
			return "!NO_DATA_FOUND!";
		return retArr.get(0)[0];

	}

	// ****************************************
	private String maskJavascript(int tab_id, String orig_value,
			String pk_val_str, String p_js_code,
			ArrayList<String> currFieldVals, ArrayList<String> currFieldNames,
			String list_field_name, String indexed_field_names) {

		String ret1 = "";
		String js_code = p_js_code;

		if (js_code.length() > 0) {
			if (js_code.contains("${")) {
				// replace quotes and double quotes with escaped versions
				try {
					if (orig_value.contains("\""))
						orig_value = orig_value.replaceAll("\"", "\\\"");

					try {
						js_code = js_code.replaceAll(
								"\\$\\{1\\}",
								orig_value.replaceAll("\"", "\'").replaceAll(
										"(\\r|\\n)", "\"+\n\t\""));
					} catch (Exception ei) {
						js_code = js_code;
					}

					StringBuilder scriptB = new StringBuilder();
					StringBuilder replaceB = new StringBuilder();
					scriptB.append(js_code);

					int s = 0;
					while (true) {
						if (currFieldNames == null)
							break;
						if (scriptB.indexOf("${") == -1)
							break;
						if (scriptB.indexOf("}") == -1)
							break;
						if (s > 100)
							break;
						int start_i = scriptB.indexOf("${");
						int end_i = scriptB.indexOf("}");
						if (end_i < start_i)
							break;

						replaceB.setLength(0);
						replaceB.append("");
						if (currFieldNames.contains(scriptB.substring(
								start_i + 2, end_i))) {
							replaceB.setLength(0);
							try {
								replaceB.append(currFieldVals.get(currFieldNames
										.indexOf(scriptB.substring(start_i + 2,
												end_i))));
							} catch (Exception e) {
								break;
							}

						}

						if (/* replaceB.indexOf(" ")>-1 || */replaceB
								.indexOf("\n") > -1
								|| replaceB.indexOf("\r") > -1
								|| replaceB.indexOf("\t") > -1)
							break;

						scriptB.delete(start_i, end_i + 1);
						scriptB.insert(start_i,
								replaceB.toString().replaceAll("\"", "\'")
										.replaceAll("(\\r|\\n)", "\"+\n\t\""));

						s++;

					} // while

					js_code = scriptB.toString();

				} catch (Exception e) {
					mylog(LOG_LEVEL_ERROR,
							"Exception@${1}Replacement : " + e.getMessage());
					mylog(LOG_LEVEL_ERROR, "at orig_value : [" + orig_value
							+ "]");
					e.printStackTrace();
				}

			}

			// --------------------------
			if (js_code.contains("$mask(")) {

				String regex = "([$]mask)(\\()(.*?)(\\))(;)";
				String regex_mask_short_code = "(\\()(.*?)(,)(')";
				String regex_mask_par = "(,)(')(.*?)(')(,)";
				String regex_mask_variable = "(')(,)(.*?)(\\))(;)";

				Pattern pattern = Pattern.compile(regex,
						Pattern.CASE_INSENSITIVE);
				Pattern pattern_short_code = Pattern.compile(
						regex_mask_short_code, Pattern.CASE_INSENSITIVE);
				Pattern pattern_par = Pattern.compile(regex_mask_par,
						Pattern.CASE_INSENSITIVE);
				Pattern pattern_variable = Pattern.compile(regex_mask_variable,
						Pattern.CASE_INSENSITIVE);

				String mask_profile_id = "";

				while (true) {
					Matcher matcher = pattern.matcher(js_code);
					if (!matcher.find())
						break;
					else {
						String mask_piece = matcher.group();
						js_code = js_code.replaceFirst("([$])(mask)(\\()",
								"//masked(");

						Matcher matcher_short_code = pattern_short_code
								.matcher(mask_piece);
						if (matcher_short_code.find()) {
							String short_code = matcher_short_code.group();
							short_code = short_code.substring(1,
									short_code.length() - 2);

							Matcher matcher_mask_par = pattern_par
									.matcher(mask_piece);
							if (matcher_mask_par.find()) {
								String mask_par = matcher_mask_par.group();
								mask_par = mask_par.substring(2,
										mask_par.length() - 2);

								String a = "";

								mask_profile_id = getMaskIdByShortCode(short_code);
								if (mask_profile_id.equals("-1")) {
									myerr("getMaskIdByShortCode(" + short_code
											+ ") cannot be found");
									break;
								}

								a = mask(tab_id, mask_par, pk_val_str,
										mask_profile_id, list_field_name,
										indexed_field_names, currFieldVals,
										currFieldNames);

								Matcher matcher_mask_variable = pattern_variable
										.matcher(mask_piece);
								if (matcher_mask_variable.find()) {
									String mask_variable = matcher_mask_variable
											.group();
									mask_variable = mask_variable.substring(2,
											mask_variable.length() - 2);
									try {
										js_code = js_code.replaceAll(
												"([$])([{])" + mask_variable
														+ "([}])", a);
									} catch (Exception e) {

										mylog(LOG_LEVEL_ERROR,
												"Exception@replaceMashVariable("
														+ mask_variable
														+ ") with => " + a);
										mylog(LOG_LEVEL_ERROR, "Js Code : "
												+ js_code);
										e.printStackTrace();
									}

								} // if (matcher_mask_variable.find()) {

							} // if (matcher_mask_par.find()) {

						} // if (matcher_short_code.find()) {

					} // if (!matcher.find()) break;

				} // while (true)

			} // if (js_code.contains("$mask("))

			if (factory == null) {
				factory = new ScriptEngineManager();
				engine = factory.getEngineByName("JavaScript");
			}

			try {
				ret1 = "" + engine.eval(js_code);
			} catch (Exception e) {
				mylog(LOG_LEVEL_ERROR, "EXCEPTION AT SCRIP : " + e.getMessage());
				mylog(LOG_LEVEL_ERROR, "=====================================");
				mylog(LOG_LEVEL_ERROR, js_code);
				mylog(LOG_LEVEL_ERROR, "=====================================");

				e.printStackTrace();
				// validation purpose
				if (orig_value.equals("$ORIGINAL_VALUE"))
					ret1 = "$JAVASCRIPT_ERR";
				else
					ret1 = orig_value;
			}

		} else {
			ret1 = orig_value;
		}

		return ret1;

	}

	// ****************************************
	private String maskHide(String orig_value, int show_count,
			String mask_asterix_char, String hide_by_word) {
		if (orig_value.length() <= show_count)
			return orig_value;

		char asterix = '*';

		try {
			asterix = mask_asterix_char.toCharArray()[0];
		} catch (Exception e) {
			asterix = '*';
		}

		char[] arr = orig_value.toCharArray();
		int start_indicator = 0;

		for (int i = 0; i < arr.length; i++) {
			start_indicator++;
			if (start_indicator <= show_count)
				continue;
			if (arr[i] == ' ') {
				if (hide_by_word.equals("YES"))
					start_indicator = 0;
				continue;
			}
			arr[i] = asterix;
		}
		return (new String().valueOf(arr));
	}

	// ****************************************
	private String maskScrambleInner(String orig_value) {
		char[] arr = orig_value.toCharArray();
		int[] fabs = RANDOM_INT_ARRAY;
		int len = fabs.length;
		int in_len = orig_value.length();
		int a = 0;
		int b = 0;
		char t_char = 'x';

		for (int i = 0; i < len - 1; i++) {
			a = (fabs[i]) % in_len;
			b = (fabs[i + 1]) % in_len;
			if (a == b)
				continue;

			t_char = arr[a];
			arr[a] = arr[b];
			arr[b] = t_char;
		}

		return (new String().valueOf(arr));
	}

	// ****************************************
	private String maskScrambleRandom(String orig_value, String char_list) {
		char[] orig_arr = orig_value.toCharArray();
		char[] chars_arr = char_list.toCharArray();
		int[] fabs = RANDOM_INT_ARRAY;

		int orig_len = orig_value.length();
		int chars_len = char_list.length();
		int fab_len = fabs.length;

		int a = 0;
		int b = 0;

		for (int i = 0; i < fab_len - 1; i++) {
			a = (fabs[i]) % chars_len;
			b = (fabs[i + 1]) % orig_len;
			if (orig_arr[b] == ' ')
				continue;
			if (chars_arr[a] == orig_arr[b])
				continue;
			orig_arr[b] = chars_arr[a];
		}

		return (new String().valueOf(orig_arr));
	}

	// ****************************************
	private String maskScrambleDate(String orig_value, String date_format,
			String change_params) {

		int change_range_day = 0;
		int change_range_month = 0;
		int change_range_year = 0;

		try {
			change_range_day = Integer.parseInt(change_params.split("day=")[1]
					.split(",")[0]);
		} catch (Exception e) {
		}
		try {
			change_range_month = Integer
					.parseInt(change_params.split("month=")[1].split(",")[0]);
		} catch (Exception e) {
		}
		try {
			change_range_year = Integer
					.parseInt(change_params.split("year=")[1]);
		} catch (Exception e) {
		}

		Calendar cal = Calendar.getInstance();

		SimpleDateFormat df = new SimpleDateFormat(date_format);
		Date date = null;

		try {
			date = df.parse(orig_value);
		} catch (Exception e) {
			return orig_value;
		}

		cal.setTime(date);

		int day = cal.get(Calendar.DAY_OF_MONTH);
		int mon = cal.get(Calendar.MONTH);
		int year = cal.get(Calendar.YEAR);

		int hour = cal.get(Calendar.HOUR_OF_DAY);
		int min = cal.get(Calendar.MINUTE);
		int sec = cal.get(Calendar.SECOND);

		int x = 1;

		x = 1;
		if (change_range_day > 0) {
			if (mon % 2 == 1)
				x = -1;
			day = Math.abs(day + x * ((mon % change_range_day) + 1)) % 28 + 1;
		}

		x = 1;
		if (change_range_month > 0) {
			if (year % 2 == 1)
				x = -1;
			mon = Math.abs(mon + x * (year % change_range_month) + 1) % 12 + 1;
		}

		x = 1;
		if (change_range_year > 0) {
			if (day % 2 == 1)
				x = -1;
			year = Math.abs(year + x * (day % change_range_year) + 1);
		}

		cal.set(year, mon, day, hour, min, sec);

		return df.format(cal.getTime());
	}

	// ****************************************
	private String maskRandomNumber(String orig_value, String range) {
		if (range.indexOf(",") == -1)
			return "-1";
		String[] arr = range.split(",");
		int range_start = 0;
		int range_end = 0;
		try {
			range_start = Integer.parseInt(arr[0]);
		} catch (Exception e) {
			return "-1";
		}
		try {
			range_end = Integer.parseInt(arr[1]);
		} catch (Exception e) {
			return "-1";
		}
		if (range_end == range_start)
			return "" + range_start;
		if (range_end < range_start)
			return "-1";
		int diff = range_end - range_start + 1;

		return "" + (range_start + ((int) (Math.random() * diff)));
	}

	// ****************************************
	private String maskRandomString(String orig_value, String range,
			String char_list) {
		int str_len = Integer.parseInt(maskRandomNumber("1", range));
		if (str_len == -1)
			return "";
		char[] orig_arr = orig_value.toCharArray();
		char[] char_arr = char_list.toCharArray();
		int r = 0;
		int orig_len = orig_value.length();
		int char_len = char_list.length();
		for (int i = 0; i < orig_len; i++) {
			if (orig_arr[i] == ' ')
				continue;
			r = (int) (Math.random() * char_len);
			orig_arr[i] = char_arr[r];
		}

		new String();
		return String.valueOf(orig_arr);
	}

	// ******************************************
	private static final char replaceChar(String in) {

		String a = "çÇðÐýÝöÖþÞüÜ";
		String b = "CCGGIIOOSSUU";

		int pos = a.indexOf(in);

		if (pos == -1)
			return in.charAt(0);
		return b.charAt(pos);
	}

	// ******************************************
	public String normalize(String val) {
		String normal_chars = "ABCDEFGHIJKLMNOPQRSTUWXYZabcdefghijklmnopqrstuwxyz0123456789";
		String val1 = val.toUpperCase();
		char[] arr = val1.toCharArray();
		for (int i = 0; i < val1.length(); i++) {
			String cin = val1.substring(i, i + 1);
			if (normal_chars.indexOf(cin) == -1) {
				String cout = "" + replaceChar(cin);
				if (cin.equals(cout))
					cout = " ";
				arr[i] = cout.charAt(0);
			}
		}

		return new String(arr).replace(" ", "");

	}

	HashMap<String, String> KeyMapHash = new HashMap<String, String>();
	int loaded_keymap_count = 0;
	int max_loaded_keymap_count = 0;

	// *******************************************
	public void loadKeyMapList(int list_id, String orig_value, int profile_id) {

		int chunk_no = getChunkNo(orig_value);

		if (KeyMapHash
				.containsKey("LIST_LOADED_" + profile_id + "_" + chunk_no))
			return;

		long start_ts = System.currentTimeMillis();

		if (heapUsedRate() > 90) {
			mylog(LOG_LEVEL_INFO, "CLEARING KEYMAP LISTS.....");

			KeyMapHash.clear();

			loaded_keymap_count = 0;
			System.gc();
			Runtime.getRuntime().gc();
		}

		StringBuilder key = new StringBuilder();
		StringBuilder val = new StringBuilder();

		InputStream fis = null;
		BufferedReader br = null;

		String KeyFileName = "";
		String filepath = "";

		try {

			if (KeyMapHash.containsKey("KEYMAP_FILE_PATH_" + profile_id))
				KeyFileName = KeyMapHash.get("KEYMAP_FILE_PATH_" + profile_id);
			else {
				KeyFileName = getDbArrayConfInt(
						"select random_char_list from tdm_mask_prof where id=?",
						1, profile_id).get(0)[0];
				KeyMapHash.put("KEYMAP_FILE_PATH_" + profile_id, KeyFileName);
			}

			filepath = getParamByName("TDM_PROCESS_HOME") + File.separator
					+ "list" + File.separator + KeyFileName + "_" + chunk_no;

			fis = new FileInputStream(filepath);
			br = new BufferedReader(new InputStreamReader(fis));
			StringBuilder sb = new StringBuilder();

			int i = 0;
			while (true) {
				try {
					sb.setLength(0);
					sb.append(br.readLine());
					if (sb.length() == 0 || sb.toString().equals("null"))
						break;
				} catch (Exception e) {
					break;
				}

				i++;
				if (i % 100000 == 0) {

					if (i % 1000000 == 0) {

						if (heapUsedRate() > 95) {
							KeyMapHash.clear();

							mylog(LOG_LEVEL_ERROR,
									"\n\n\n!!!! ************************************************************..");
							mylog(LOG_LEVEL_ERROR,
									"!!!! Exception : Heap usage is too high. Cancelling ..");
							mylog(LOG_LEVEL_ERROR,
									"!!!! loadKeyMapList Filename : "
											+ filepath);
							mylog(LOG_LEVEL_ERROR,
									"!!!! ************************************************************..\n\n\n");

							break;
						}
					}

				}

				heartbeat(TABLE_TDM_WORKER, i, worker_id);

				try {

					key.setLength(0);
					val.setLength(0);

					try {
						key.append(sb.toString().split(";")[0]);
						val.append(sb.toString().split(";")[1]);
					} catch (Exception e) {

					}

					KeyMapHash.put("" + profile_id + "_" + key.toString(),
							val.toString());

				} catch (Exception e) {
					mylog(LOG_LEVEL_ERROR,
							"\n\n\n!!!! ************************************************************..");
					mylog(LOG_LEVEL_ERROR,
							"!!!! Exception Problem. There must be at lease 2 columns in loadKeyMapList..");
					mylog(LOG_LEVEL_ERROR, "!!!! Error Occured At File : "
							+ filepath);
					mylog(LOG_LEVEL_ERROR,
							"!!!! Error Occured At Line : " + sb.toString());
					mylog(LOG_LEVEL_ERROR,
							"!!!! ************************************************************..\n\n\n");
					break;
				}
			}

		} catch (Exception e) {
			e.printStackTrace();

			mylog(LOG_LEVEL_ERROR,
					"\n\n\n!!!! ************************************************************..");
			mylog(LOG_LEVEL_ERROR, "!!!! Problem in loading list. ");
			mylog(LOG_LEVEL_ERROR, "!!!! Error Occured At File : " + filepath);
			mylog(LOG_LEVEL_ERROR,
					"!!!! ************************************************************..\n\n\n");

		} finally {
			try {
				br.close();
			} catch (Exception e) {

			}

		}

		loaded_keymap_count++;
		if (loaded_keymap_count > max_loaded_keymap_count)
			max_loaded_keymap_count = loaded_keymap_count;
		KeyMapHash.put("LIST_LOADED_" + profile_id + "_" + chunk_no, "YES");

		mylog(LOG_LEVEL_DEBUG,
				"Loaded KeyMap " + loaded_keymap_count + "/"
						+ max_loaded_keymap_count + " chunk :" + chunk_no
						+ " for [ " + orig_value + "] [pid=" + java_pid
						+ "] in " + (System.currentTimeMillis() - start_ts)
						+ " msec");

	}

	// HashMap<Integer, Integer> KeyMapHashInt=new HashMap<Integer, Integer>();

	ArrayList<HashMap<Integer, Integer>> superHash = new ArrayList<HashMap<Integer, Integer>>();

	int clear_pointer = 0;

	// *******************************************
	public void loadKeyMapList3(int list_id, int chunk_no, int profile_id) {

		// int chunk_no=getChunkNo(orig_value);

		if (KeyMapHash.containsKey("LIST_LOADED_" + chunk_no))
			return;

		long start_ts = System.currentTimeMillis();

		int loading_hm_id = superHash.size();
		for (int i = 0; i < superHash.size(); i++) {
			if (superHash.get(i) == null) {
				loading_hm_id = i;
				break;
			}
		}

		if (heapUsedRate() > 90) {
			mylog(LOG_LEVEL_INFO, "CLEARING KEYMAP LISTS.....");
			int cleared_count = 0;
			while (heapUsedRate() > 75) {

				int clearing_chunk_no = -1;

				try {
					clearing_chunk_no = Integer.parseInt(KeyMapHash
							.get("HM_POS_" + clear_pointer));
				} catch (Exception e) {
					clearing_chunk_no = -1;
					e.printStackTrace();
				}

				if (clearing_chunk_no > -1) {
					cleared_count++;
					KeyMapHash.remove("LIST_LOADED_" + clearing_chunk_no);
					loading_hm_id = clear_pointer;
					mylog(LOG_LEVEL_INFO, "... clearing chunk ("
							+ clearing_chunk_no + ")  from pos : "
							+ loading_hm_id + " " + heapUsedRate() + "%");
					superHash.set(clear_pointer, null);
					if (cleared_count % 4 == 3)
						Runtime.getRuntime().gc();

				}

				clear_pointer++;
				if (clear_pointer == superHash.size())
					clear_pointer = 0;
			}

		}

		StringBuilder key = new StringBuilder();
		StringBuilder val = new StringBuilder();

		InputStream fis = null;
		BufferedReader br = null;

		String KeyFileName = "";
		String filepath = "";

		HashMap<Integer, Integer> loadingHashMap = new HashMap<Integer, Integer>();

		try {

			if (KeyMapHash.containsKey("KEYMAP_FILE_PATH_" + profile_id))
				KeyFileName = KeyMapHash.get("KEYMAP_FILE_PATH_" + profile_id);
			else {
				KeyFileName = getDbArrayConfInt(
						"select random_char_list from tdm_mask_prof where id=?",
						1, profile_id).get(0)[0];
				KeyMapHash.put("KEYMAP_FILE_PATH_" + profile_id, KeyFileName);
			}

			filepath = getParamByName("TDM_PROCESS_HOME") + File.separator
					+ "list" + File.separator + KeyFileName + "_" + chunk_no;

			fis = new FileInputStream(filepath);
			br = new BufferedReader(new InputStreamReader(fis));
			StringBuilder sb = new StringBuilder();

			int i = 0;

			while (true) {
				try {
					sb.setLength(0);
					sb.append(br.readLine());
					if (sb.length() == 0 || sb.toString().equals("null"))
						break;
				} catch (Exception e) {
					break;
				}

				i++;

				heartbeat(TABLE_TDM_WORKER, i, worker_id);

				try {

					key.setLength(0);
					val.setLength(0);
					int keyint = 0;
					int valint = 0;

					try {
						key.append(sb.toString().split(";")[0]);
						val.append(sb.toString().split(";")[1]);

						keyint = Integer.parseInt(key.toString());
						valint = Integer.parseInt(val.toString());

						// KeyMapHashInt.put(keyint, valint);
						loadingHashMap.put(keyint, valint);

					} catch (Exception e) {
						mylog(LOG_LEVEL_ERROR, "Exception@loadKeyMapList3@"
								+ key + "=" + val);
					}

					// KeyMapHash.put(""+profile_id+"_"+key.toString(),
					// val.toString());

				} catch (Exception e) {
					mylog(LOG_LEVEL_ERROR,
							"\n\n\n!!!! ************************************************************..");
					mylog(LOG_LEVEL_ERROR,
							"!!!! Exception Problem. There must be at lease 2 columns in loadKeyMapList..");
					mylog(LOG_LEVEL_ERROR, "!!!! Error Occured At File : "
							+ filepath);
					mylog(LOG_LEVEL_ERROR,
							"!!!! Error Occured At Line : " + sb.toString());
					mylog(LOG_LEVEL_ERROR,
							"!!!! ************************************************************..\n\n\n");
					break;
				}
			}

		} catch (Exception e) {
			e.printStackTrace();

			mylog(LOG_LEVEL_ERROR,
					"\n\n\n!!!! ************************************************************..");
			mylog(LOG_LEVEL_ERROR, "!!!! Problem in loading list. ");
			mylog(LOG_LEVEL_ERROR, "!!!! Error Occured At File : " + filepath);
			mylog(LOG_LEVEL_ERROR,
					"!!!! ************************************************************..\n\n\n");

		} finally {
			try {
				br.close();
			} catch (Exception e) {

			}

		}

		if (loading_hm_id == superHash.size()) {
			loaded_keymap_count++;
			superHash.add(loadingHashMap);
		} else {
			superHash.set(loading_hm_id, loadingHashMap);

		}

		mylog(LOG_LEVEL_INFO, "...Loading to superHash Position  : "
				+ loading_hm_id + "(heap : " + heapUsedRate() + " %)");
		KeyMapHash.put("LIST_LOADED_" + chunk_no, "" + loading_hm_id);
		KeyMapHash.put("HM_POS_" + loading_hm_id, "" + chunk_no);

		if (loaded_keymap_count > max_loaded_keymap_count)
			max_loaded_keymap_count = loaded_keymap_count;

		mylog(LOG_LEVEL_INFO, "Loaded KeyMap " + loaded_keymap_count + "/"
				+ max_loaded_keymap_count + " chunk :" + chunk_no + " [pid="
				+ java_pid + "] in " + (System.currentTimeMillis() - start_ts)
				+ " msec");

	}

	final int KEYVAL_FILE_CHUNK_SIZE = 1000;

	// ***************************************
	int getChunkNo(String sb) {
		try {
			return Math.abs(sb.hashCode() % KEYVAL_FILE_CHUNK_SIZE);
		} catch (Exception e) {
			return 0;
		}

	}

	// ***************************************
	String maskKeyMapList(String orig_value, int list_id, int profile_id) {

		// loadKeyMapList(list_id, orig_value, profile_id);
		loadKeyMapList3(list_id, getChunkNo(orig_value), profile_id);

		try {
			int in = Integer.parseInt(orig_value);
			int hm_id = Integer.parseInt(KeyMapHash.get("LIST_LOADED_"
					+ getChunkNo(orig_value)));

			// if (KeyMapHashInt.containsKey(in)) return ""+((int)
			// KeyMapHashInt.get(in));
			if (superHash.get(hm_id).containsKey(in))
				return "" + (superHash.get(hm_id).get(in));
			else
				return orig_value;
		} catch (Exception e) {
			return null;

		}

	}

	// ***************************************
	@SuppressWarnings("unchecked")
	String maskList(String orig_value, int list_id, String list_ref_value,
			String list_field_name, String list_filter_value) {
		loadList(list_id);
		String hashkey_base_val = null;
		// if (!list_field_name.equals("-")) val=list_ref_value;
		if (!list_ref_value.toString().equals("-"))
			hashkey_base_val = normalize(list_ref_value.toString());
		else
			hashkey_base_val = normalize(orig_value);

		// mylog("* maskList  "+ orig_value+ " with " + pk_val_str
		// +"("+list_field_name+") indexed with "+indexed_list_fields);

		int i = 0;
		try {
			i = Math.abs(hashkey_base_val.hashCode())
					% (int) hm.get("LIST_" + list_id + "_SIZE");
		} catch (Exception e) {
			i = 0;
			e.printStackTrace();
		}

		try {
			if (!list_field_name.equals("-")) {

				if (!list_filter_value.equals("-")) {

					String hkey = "LIST_" + list_id + "_KEYIDMAP_"
							+ list_filter_value;
					// mylog(" * hkey = " + hkey);
					if (hm.get(hkey) == null) {
						String index_fields = "";

						String[] parts = list_filter_value.split("\\[");
						int field_count = 0;
						for (int p = 0; p < parts.length; p++)
							if (parts[p].length() > 0 && parts[p].contains("=")) {
								field_count++;
								if (field_count > 1)
									index_fields = index_fields + ",";
								index_fields = index_fields
										+ parts[p].split("=")[0];
							}

						indexList(list_id, index_fields);
					}

					ArrayList<Integer> keyMap = (ArrayList<Integer>) hm
							.get(hkey);
					if (keyMap == null)
						return null;

					try {
						i = keyMap.get(Math.abs(hashkey_base_val.hashCode())
								% keyMap.size());
					} catch (Exception e) {
						i = -1;
						e.printStackTrace();
					}

				}
				return (nvl(
						(String) hm.get("LIST_" + list_id + "_" + i + "_"
								+ list_field_name), orig_value));

			}

			return ((String) hm.get("LIST_" + list_id + "_" + i));

		} catch (Exception e) {
			return (orig_value);
		}

	}

	// ***************************************
	protected String mask(int tab_id, String val, String list_ref_value,
			String mask_profile_id, String list_field_name,
			String filter_list_value, ArrayList<String> currFieldVals,
			ArrayList<String> currFieldNames) {

		// rollback
		// kopyalama tipindeki rollbacklerde gercekten maskeleme yapmali.
		if (RUN_TYPE.equals("TEST:ACCURACY")
				&& WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK))
			return val;

		if (mask_profile_id.equals("-9999"))
			return val;
		if (mask_profile_id.equals("0"))
			return val;

		String ret1 = "";

		if (val.length() == 0 && list_field_name.equals("-"))
			return "";

		String[] mask_prof = getMaskProfileById(mask_profile_id);

		if (mask_prof == null) {
			mylog(LOG_LEVEL_WARNING, "No masking profile found for : "
					+ mask_profile_id);
			mylog(LOG_LEVEL_WARNING, "No masking profile found for : "
					+ mask_profile_id);

			return val;
		}

		// String mask_name=mask_prof[MASK_PRFL_FLD_NAME];
		String mask_rule = mask_prof[MASK_PRFL_FLD_RULE];
		String mask_post_stmt = mask_prof[MASK_PRFL_FLD_POST_STATEMENT];

		switch (mask_rule) {
		// ------------------------------------------------------------------
		case MASK_RULE_HIDE: {
			String hide_char = "";
			int hide_after = 0;
			String hide_by_word = "NO";
			try {
				hide_char = mask_prof[MASK_PRFL_FLD_HIDE_CHAR].substring(0, 1);
			} catch (Exception e) {
				hide_char = "*";
			}
			try {
				hide_after = Integer
						.parseInt(mask_prof[MASK_PRFL_FLD_HIDE_AFTER]);
			} catch (Exception e) {
				hide_after = 2;
			}
			try {
				hide_by_word = mask_prof[MASK_PRFL_FLD_HIDE_BY_WORD];
			} catch (Exception e) {
				hide_by_word = "NO";
			}

			ret1 = maskHide(val, hide_after, hide_char, hide_by_word);
			break;
		}
		// ------------------------------------------------------------------
		case MASK_RULE_HASHLIST: {
			int list_id = 0;
			try {
				list_id = Integer.parseInt(mask_prof[MASK_PRFL_FLD_SRC_LIST]);
			} catch (Exception e) {
			}
			if (list_id == 0)
				ret1 = val;
			else {
				ret1 = maskList(val, list_id, list_ref_value, list_field_name,
						filter_list_value);
				if (ret1 == null)
					ret1 = val;
			}
			break;
		}

		// ------------------------------------------------------------------
		case MASK_RULE_KEYMAP: {
			int list_id = 0;

			try {
				list_id = Integer.parseInt(mask_prof[MASK_PRFL_FLD_SRC_LIST]);
			} catch (Exception e) {
			}
			if (list_id == 0)
				ret1 = val;
			else {
				try {
					ret1 = maskKeyMapList(val, list_id,
							Integer.parseInt(mask_profile_id));
				} catch (Exception e) {
					ret1 = val;
				}
			}
			break;
		}

		// ------------------------------------------------------------------
		case MASK_RULE_SCRAMBLE_INNER: {
			ret1 = maskScrambleInner(val);
			break;
		}
		// ------------------------------------------------------------------
		case MASK_RULE_SCRAMBLE_RANDOM: {
			String char_list = "";
			try {
				char_list = mask_prof[MASK_PRFL_FLD_RANDOM_CHARLIST];
			} catch (Exception e) {
				char_list = MASK_DEFAULT_CHAR_LIST;
			}
			if (("" + char_list).length() == 0)
				char_list = MASK_DEFAULT_CHAR_LIST;
			ret1 = maskScrambleRandom(val, char_list);
			break;
		}
		// ------------------------------------------------------------------
		case MASK_RULE_SCRAMBLE_DATE: {
			String date_format = "";
			String date_change_params = "";
			try {
				date_format = mask_prof[MASK_PRFL_FLD_FORMAT];
			} catch (Exception e) {
				date_format = "";
			}
			if (date_format.length() == 0)
				date_format = genLib.DEFAULT_DATE_FORMAT;

			try {
				date_change_params = mask_prof[MASK_PRFL_FLD_DATE_CHANGE_PARAMS];
			} catch (Exception e) {
				date_change_params = "";
			}

			ret1 = maskScrambleDate(val, date_format, date_change_params);
			break;
		}
		// ------------------------------------------------------------------
		case MASK_RULE_RANDOM_NUMBER: {
			String range = "";
			try {
				range = mask_prof[MASK_PRFL_FLD_RANDOM_RANGE];
			} catch (Exception e) {
				range = "";
			}
			ret1 = maskRandomNumber(val, range);
			break;
		}
		// ------------------------------------------------------------------
		case MASK_RULE_NONE: {
			ret1 = val;
			break;
		}
		// ------------------------------------------------------------------
		case MASK_RULE_FIXED: {
			String fix_val = "";
			try {
				fix_val = mask_prof[MASK_PRFL_FLD_FIXED_VAL];
			} catch (Exception e) {
				fix_val = "";
			}
			ret1 = fix_val;
			break;
		}
		// ------------------------------------------------------------------
		case MASK_RULE_JAVASCRIPT: {
			String js_code = "";
			try {
				js_code = mask_prof[MASK_PRFL_FLD_JS_CODE];
			} catch (Exception e) {
				js_code = "";
			}
			ret1 = maskJavascript(tab_id, val, list_ref_value, js_code,
					currFieldVals, currFieldNames, list_field_name,
					filter_list_value);
			break;
		}
		// ------------------------------------------------------------------
		case MASK_RULE_SQL: {
			String sql_code = "";
			try {
				sql_code = mask_prof[MASK_PRFL_FLD_JS_CODE];
			} catch (Exception e) {
				sql_code = "";
			}
			ret1 = maskSQL(tab_id, val, sql_code);
			break;
		}
		// ------------------------------------------------------------------
		case MASK_RULE_RANDOM_STRING: {
			String range = "";
			String char_list = "";
			try {
				range = mask_prof[MASK_PRFL_FLD_RANDOM_RANGE];
			} catch (Exception e) {
				range = "";
			}
			try {
				char_list = mask_prof[MASK_PRFL_FLD_RANDOM_CHARLIST];
			} catch (Exception e) {
				char_list = MASK_DEFAULT_CHAR_LIST;
			}
			if (("" + char_list).length() == 0)
				char_list = MASK_DEFAULT_CHAR_LIST;

			ret1 = maskRandomString(val, range, char_list);
			break;
		}
		}

		if (!mask_post_stmt.isEmpty()) {
			switch (mask_post_stmt) {

			case "UPPERCASE": {
				ret1 = ret1.toUpperCase(currLocale);
				break;
			}
			case "LOWERCASE": {
				ret1 = ret1.toLowerCase(currLocale);
				break;
			}
			case "INITIALS": {
				ret1 = initials(ret1);
				break;
			}

			}
		}

		return ret1;
	}

	// ***************************************
	private String initials(String in) {
		String ret1 = "";
		if (in == null)
			return "";
		String[] arr = in.split(" ");
		for (int i = 0; i < arr.length; i++) {
			if (arr[i] == null)
				continue;
			if (arr[i].isEmpty())
				continue;
			if (i > 0)
				ret1 = ret1 + " ";
			ret1 = ret1 + arr[i].substring(0, 1).toUpperCase(currLocale)
					+ arr[i].substring(1).toLowerCase(currLocale);
		}
		return ret1;
	}

	// ***************************************
	public void sleep(long milis) {
		try {
			Thread.sleep(milis);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	public static final int LOG_LEVEL_DEBUG = 5;
	public static final int LOG_LEVEL_INFO = 4;
	public static final int LOG_LEVEL_WARNING = 3;
	public static final int LOG_LEVEL_ERROR = 2;
	public static final int LOG_LEVEL_FATAL = 1;

	static final int MAX_LOG_LENGTH = 20 * 1024 * 1024;

	// ***************************************
	public void mylog(int level, String plog) {

		if (plog.indexOf("xception") > -1) {
			System.out.println(java_pid + " " + p_sid + "> " + plog);
			myerr(plog);
		}

		if (level != LOG_LEVEL_DEBUG)
			log_info.append(java_pid + " " + (new Date().toString()) + " "
					+ plog + "\r");

		if (log_info.length() > MAX_LOG_LENGTH)
			log_info.delete(0, MAX_LOG_LENGTH / 4);

		if (logger == null) {
			System.out.println(java_pid + " " + plog);
			return;
		}

		switch (level) {
		case LOG_LEVEL_DEBUG: {
			logger.debug(java_pid + " " + (new Date().toString()) + " " + plog);
			break;
		}
		case LOG_LEVEL_INFO: {
			logger.info(java_pid + " " + (new Date().toString()) + " " + plog);
			break;
		}
		case LOG_LEVEL_WARNING: {
			logger.warn(java_pid + " " + (new Date().toString()) + " " + plog);
			break;
		}
		case LOG_LEVEL_ERROR: {
			logger.error(java_pid + " " + (new Date().toString()) + " " + plog);
			break;
		}
		case LOG_LEVEL_FATAL: {
			logger.fatal(java_pid + " " + (new Date().toString()) + " " + plog);
			break;
		}
		default:
			logger.debug(java_pid + " " + (new Date().toString()) + " " + plog);
		}

		// logger.error(java_pid+" "+plog);

	}

	// ***************************************
	public void myerr(String plog) {

		System.out.println(java_pid + " " + p_sid + "> " + plog);
		err_info.append(java_pid + " " + plog + "\r");

		if (err_info.length() > MAX_LOG_LENGTH)
			err_info.delete(0, MAX_LOG_LENGTH / 4);

		if (logger == null) {
			System.out.println(java_pid + " " + plog);
			return;
		}

		logger.error(java_pid + " " + plog);
	}

	// *****************************************
	public ArrayList<String[]> scrambleArrayList(ArrayList<String[]> list) {
		ArrayList<String[]> ret1 = new ArrayList<String[]>();
		int arr_size = list.size();
		int remain_size = arr_size;
		if (arr_size < 2)
			return list;

		int next_item_id = 0;
		for (int i = 0; i < arr_size; i++) {
			remain_size--;
			next_item_id = (int) (Math.random() * remain_size);
			next_item_id = i + next_item_id + 1;
			if (next_item_id > arr_size - 1)
				next_item_id = arr_size - 2;

			try {
				String[] t = list.get(next_item_id);
				ret1.add(t);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		if (RUN_TYPE.indexOf("ACTUAL") == -1)
			return list;
		return ret1;
	}

	

	// *****************************************
	public int getActiveMasterCount(int work_plan_id) {
		String sql = "select count(*) a from "
				+ " (select distinct master_id "
				+ " from tdm_work_package  "
				+ " where  work_plan_id=? and master_id is not null "
				+ " and master_id in (select id from tdm_master where status in('BUSY','ASSIGNED') and cancel_flag<>'YES') "
				+ ") t ";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + work_plan_id });

		int ret1 = 0;

		ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);

		try {
			ret1 = Integer.parseInt(arr.get(0)[0]);
		} catch (Exception e) {
			e.printStackTrace();
			ret1 = 0;
		}

		return ret1;
	}

	

	// *****************************************
	public ArrayList<String[]> getFreeMasterList(int limit) {

		String sql = ""
				+ " select id from  "
				+ " tdm_master  m"
				+ " where  "
				+ " status='FREE' and cancel_flag<>'YES' "
				+ " and last_heartbeat>DATE_ADD(NOW(), INTERVAL -5 MINUTE) "
				+ " and not exists (select 1 from tdm_work_package where master_id=m.id) ";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		return getDbArrayConf(sql, limit, bindlist);
	}

	// *****************************************
	public ArrayList<String[]> getRunningWorkPlanList() {
		String sql = "select id, worker_limit, master_limit, execution_type, wplan_type from tdm_work_plan "
				+ " where status in('RUNNING') and cancel_flag is null order by start_date  ";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		return getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);
	}

	// *****************************************
	public int getFreeMasterId() {
		int ret1 = 0;
		String sql = "select id from tdm_master where status='FREE' and cancel_flag<>'YES' and id not in (select master_id from tdm_work_package where master_id is not null)  order by start_date desc limit 0,1 ";
		try {
			ret1 = Integer.parseInt(getDbArrayConf(sql, 1).get(0)[0]);
		} catch (Exception e) {
			ret1 = 0;
		}
		return ret1;
	}

	// *****************************************
	public int getFreeWorkPackId() {
		int ret1 = 0;

		String sql = ""
				+ " select id from tdm_work_package where status='NEW' "
				+ " and work_plan_id in ( "
				+ " 	select id from tdm_work_plan wpl where status in ('RUNNING') "
				+ " 	and master_limit> "
				+ "       (select count(*) from tdm_work_package where  work_plan_id=wpl.id and status in('EXPORTING','ASSIGNED')) "
				+ "	)  " + " order by id limit 0,1 ";

		try {
			ret1 = Integer.parseInt(getDbArrayConf(sql, 1).get(0)[0]);
		} catch (Exception e) {
			ret1 = 0;
		}
		return ret1;
	}







	// *****************************************
	public boolean assignWPack(int p_master_id, int work_plan_id, String work_plan_type, int tab_id, int p_work_package_id) {
		
		String sql="";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		
		sql = "update tdm_work_package "
				+ " set status='ASSIGNED', master_id=?,"
				+ " assign_date=now(), last_activity_date=now(), success_count=0, fail_count=0, done_count=0"
				+ " where id=?";
		
		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + p_master_id });
		bindlist.add(new String[] { "INTEGER", "" + p_work_package_id });

		boolean is_ok=execDBBindingConf(sql, bindlist);
		
		return is_ok;



	}







	// *****************************************
	public void closeWpackAssignment(int p_master_id, String p_status) {
		String sql = "update tdm_master set status='" + p_status + "', "
				+ " assign_date=now() " + " where id=?";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + p_master_id });

		execDBBindingConf(sql, bindlist);
	}

	// ***********************************************

	public void setWorkPlanStatus(int p_work_plan_id, String p_status) {
		String sql = "";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", "" + p_work_plan_id });

		if (p_status.equals("RUNNING") || p_status.equals("PREPARATION"))
			sql = "update tdm_work_plan set status='" + p_status
					+ "',start_date=now() where id=?";
		else if (p_status.equals("COMPLETED") || p_status.equals("FINISHED"))
			sql = "update tdm_work_plan set status='" + p_status
					+ "',end_date=now() where id=?";
		else
			sql = "update tdm_work_plan set status='" + p_status
					+ "' where id=?";

		execDBBindingConf(sql, bindlist);

		sendWorkPlanStatusMail("" + p_work_plan_id, true);
	}

	// *************************************************
	public ArrayList<String[]> getFinishedTaskIds(int p_work_package_id,
			int p_work_plan_id) {
		String sql = "select id from tdm_task_" + p_work_plan_id + "_"
				+ p_work_package_id + " where status='FINISHED'";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		return getDbArrayConf(sql, FINISHED_TASK_REC_LIMIT, bindlist);
	}

	// *************************************************
	public ArrayList<String[]> getFinishedTaskCounts(int p_work_package_id,
			int p_work_plan_id) {
		String sql = "select sum(done_count) done_count, sum(success_count) success_count, sum(fail_count) fail_count "
				+ " from tdm_task_"
				+ p_work_plan_id
				+ "_"
				+ p_work_package_id
				+ " where status='FINISHED'";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		return getDbArrayConf(sql, FINISHED_TASK_REC_LIMIT, bindlist);
	}

	// *****************************************
	public boolean getMasterCancelFlag(int p_master_id) {
		boolean ret1 = false;
		String sql = "select cancel_flag from tdm_master where id=?";
		ArrayList<String[]> s = getDbArrayConfInt(sql, 100, p_master_id);
		try {
			String[] arr = s.get(0);
			if (arr[0].equals("YES")) {
				ret1 = true;
				sql = "update tdm_master set cancel_flag=null where id="
						+ p_master_id;
				execDBConf(sql);
			}

		} catch (Exception e) {
		}
		return ret1;
	}

	// ************************************************
	boolean getRunOptionasBoolean(int work_plan_id, String key) {
		String run_options = "";
		try {
			run_options = getDbArrayConfInt(
					"select run_options from tdm_work_plan where id=?", 1,
					work_plan_id).get(0)[0];
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		if (run_options.contains(key + "=YES;"))
			return true;

		return false;

	}

	// ************************************************
	String getAutomationRunOptionVal(String run_options, String key) {
		String[] opts = run_options.split("\n|\r");
		for (int i = 0; i < opts.length; i++) {
			String item = opts[i];
			if (item.indexOf(key + "=") == 0)
				return item.substring(new String(key + "=").length());
		}

		return "";
	}

	// ************************************************
	@SuppressWarnings("unchecked")
	private boolean validateWorkPlanMASK(int wplan_id, String app_type) {

		boolean ret1 = true;

		mylog(LOG_LEVEL_INFO, "Validating work plan : " + wplan_id);
		loadRunParams(wplan_id, true);
		String invalid_message = "";
		String warning_message = "";

		String sql = "";
		ArrayList<String[]> tabList = new ArrayList<String[]>();
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		sql = "update tdm_work_plan set INVALID_MESSAGE=null, WARNING_MESSAGE=null where id="
				+ wplan_id;
		execDBBindingConf(sql, new ArrayList<String[]>());

		// check warnings

		ArrayList<String[]> warningCheckArr = new ArrayList<String[]>();

		if (app_db_type.equals(genLib.DB_TYPE_ORACLE)) {

			warningCheckArr
					.add(new String[] { "Archive mod is active : ${1}",
							"select archiver from v$instance where archiver!='STOPPED'" });

			warningCheckArr
					.add(new String[] { "Force Logging mod is active : ${1}",
							"select force_logging from v$database where force_logging !='NO'" });

			warningCheckArr
					.add(new String[] {
							"Resource limit found : ${1} :  ${2} ",
							"select resource_name, limit from USER_RESOURCE_LIMITS where limit<>'UNLIMITED'" });

			warningCheckArr
					.add(new String[] {
							"System Trigger found :${1}.${2} Type =${3} ",
							"select owner,trigger_name,TRIGGER_TYPE from all_triggers where base_object_type in ('DATABASE','SCHEMA') and status='ENABLED'" });
		}

		if (app_db_type.equals(genLib.DB_TYPE_MSSQL)) {

			warningCheckArr
					.add(new String[] {
							"Resource governor found : Group : ${1} : Function : ${2} ",
							"SELECT object_schema_name(classifier_function_id) , object_name(classifier_function_id) FROM sys.resource_governor_configuration" });

			warningCheckArr
					.add(new String[] { "System Trigger found : ${1}  ",
							"SELECT name FROM sys.server_triggers where is_disabled='false'" });

		}

		// ------------------------------------------
		for (int i = 0; i < warningCheckArr.size(); i++) {
			String check_phrase = warningCheckArr.get(i)[0];
			String check_sql = warningCheckArr.get(i)[1];

			bindlist.clear();
			ArrayList<String[]> checkArr = getDbArrayApp(check_sql, 20,
					bindlist, 10);

			if (checkArr == null) {
				warning_message = warning_message
						+ "<br> DB Warning Check Error for => " + check_phrase
						+ " [" + check_sql + "]";
			} else {
				for (int c = 0; c < checkArr.size(); c++) {
					String[] checkRec = checkArr.get(c);
					String curr_rec_phrase = check_phrase;
					for (int r = 0; r < checkRec.length; r++) {
						try {
							curr_rec_phrase = curr_rec_phrase.replace("${"
									+ (r + 1) + "}", checkRec[r]);
						} catch (Exception e) {
							e.printStackTrace();
						}

					}

					warning_message = warning_message + "<br>"
							+ curr_rec_phrase;

				} // for
			}

		}

		if (warning_message.length() > 0) {
			mylog(LOG_LEVEL_WARNING, "Some warnings found : ");
			mylog(LOG_LEVEL_WARNING, warning_message);

			sql = "update tdm_work_plan set WARNING_MESSAGE=? where id=?";
			bindlist.clear();
			bindlist.add(new String[] { "STRING", warning_message });
			bindlist.add(new String[] { "STRING", "" + wplan_id });
			execDBBindingConf(sql, bindlist);
		}

		// check tables
		sql = "select t.id tab_id, t.cat_name, t.schema_name, t.tab_name, t.partition_used   "
				+ " from tdm_work_plan w, tdm_apps a, tdm_tabs t "
				+ " where w.app_id=a.id and t.app_id=a.id and w.id="
				+ wplan_id
				+ " and mask_level not in('DELETE') ";

		boolean skip_table_validation = getRunOptionasBoolean(wplan_id,
				"SKIP_TABLE_VALIDATION");
		boolean skip_fieldcheck_validation = getRunOptionasBoolean(wplan_id,
				"SKIP_FIELDCHECK_VALIDATION");

		if (app_db_type.equals(genLib.DB_TYPE_JBASE)) {
			skip_table_validation = true;
			skip_fieldcheck_validation = true;
		}

		tabList = getDbArrayConf(sql, Integer.MAX_VALUE);

		// IS AT LEAST A TABLE ADDED?
		if (tabList.size() == 0 && !WORK_PLAN_TYPE.equals("DISC"))
			invalid_message = invalid_message
					+ "Application should have at least a table.\n";

		// Check run on server and if the server side scripts are installed

		if (WORK_PLAN_TYPE.equals("MASK2")
				&& (app_db_type.equals(genLib.DB_TYPE_ORACLE) || app_db_type
						.equals(genLib.DB_TYPE_MYSQL))) {

			mylog(LOG_LEVEL_WARNING,
					"Checking server side script needed tables...");

			sql = "select concat(t.cat_name, '.', t.schema_name, '.', t.tab_name) run_on_server_cols \n"
					+ " from tdm_tabs t, tdm_fields f, tdm_mask_prof p  \n"
					+ " where f.tab_id=t.id and f.mask_prof_id=p.id and p.run_on_server='YES' \n"
					+ " and not exists (select 1 from tdm_fields fl where  fl.tab_id=f.tab_id and fl.is_conditional='YES') \n"
					+ " and not exists (select 1 from tdm_fields fl, tdm_mask_prof pl where  fl.tab_id=f.tab_id and fl.mask_prof_id=pl.id and pl.run_on_server!='YES') \n"
					+ " and t.app_id = (select app_id from tdm_work_plan where id=?) \n ";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", "" + wplan_id });

			ArrayList<String[]> runOnServerList = getDbArrayConf(sql,
					Integer.MAX_VALUE, bindlist);

			if (runOnServerList.size() > 0) {

				mylog(LOG_LEVEL_WARNING,
						"Server side script needed tables found. Checking server side masking function...");

				String server_side_script_sql = "select maya_tdm_mask('ABCDE','FIXED','DEF','','','','')";
				if (app_db_type.equals(genLib.DB_TYPE_ORACLE))
					server_side_script_sql = "select maya_tdm_mask('ABCDE','FIXED','DEF','','','','') from dual";

				bindlist.clear();

				ArrayList<String[]> testMaskFunctionArr = getDbArrayApp(
						server_side_script_sql, 1, bindlist, 0);

				if (testMaskFunctionArr.size() == 0
						|| !testMaskFunctionArr.get(0)[0].equals("DEF")) {
					invalid_message = invalid_message
							+ "Needed server side scripts are not installed or not valid.\n";
					invalid_message = invalid_message
							+ "Server side masking tables :\n";
					for (int a = 0; a < runOnServerList.size(); a++)
						invalid_message = invalid_message + "\t"
								+ runOnServerList.get(a)[0] + "\n";

				}

			} // if (runOnServerList.size()>1)

		} // if (app_db_type.equals(opAutoLib.DB_TYPE_ORACLE) ||
			// app_db_type.equals(opAutoLib.DB_TYPE_MYSQL))

		// if (!WORK_PLAN_TYPE.equals("DISC"))
		for (int t = 0; t < tabList.size(); t++) {

			// matchWorkerTask();
			matchMasterWorkPackage();
			balanceMasterProcesses();

			heartbeat(TABLE_TDM_MANAGER, 0, manager_id);

			String tab_id = tabList.get(t)[0];
			String catalog_name = tabList.get(t)[1];
			String schema_name = tabList.get(t)[2];
			String table_name = tabList.get(t)[3];
			String partition_used = tabList.get(t)[4];

			sql = "select field_name, field_type from tdm_fields where tab_id=?";
			bindlist = new ArrayList<String[]>();
			bindlist.add(new String[] { "INTEGER", tab_id });
			ArrayList<String[]> confFieldList = getDbArrayConf(sql,
					Integer.MAX_VALUE, bindlist);

			// IS TABLE EXISTS?

			boolean table_exists = false;

			if (is_mongo)
				skip_table_validation = true;

			if (skip_table_validation)
				table_exists = true;
			else {

				// jBASE case
				if (schema_name.equals("null") || schema_name.length() == 0) {
					if (table_name.indexOf(".") == 0)
						table_name = table_name.substring(1);
					sql = "select " + getJbaseFieldsWithComma(table_name)
							+ " from \"" + table_name + "\"";
				} else
					sql = "select * from "
							+ addStartEndForTable(schema_name + "."
									+ table_name);

				mylog(LOG_LEVEL_INFO," app_db_type :"+app_db_type);
				
				if (app_db_type.equals(genLib.DB_TYPE_MSSQL))
					sql = "select top 100 * from "	+ addStartEndForTable(schema_name + "."	+ table_name) + " with (NOLOCK) ";
				else if (app_db_type.equals(genLib.DB_TYPE_SYBASE))
					sql = "select top 100 * from "+ addStartEndForTable(schema_name + "."+ table_name) + " NOHOLDLOCK ";
				else if (app_db_type.equals(genLib.DB_TYPE_MYSQL))
					sql = "select * from "+ addStartEndForTable(schema_name + "."+ table_name) + " limit 0,100";
				else if (app_db_type.equals(genLib.DB_TYPE_POSTGRESQL))
					sql = "select * from "	+ addStartEndForTable(schema_name + "."	+ table_name) + " limit 100";
				else 
					sql ="select * from "+addStartEndForTable(schema_name + "."	+ table_name);
					
				mylog(LOG_LEVEL_INFO," ---------- Retrieve Check Table  ----------------");
				mylog(LOG_LEVEL_INFO, sql);

				mylog(LOG_LEVEL_INFO, " ---------- Done ----------------");

				/*
				bindlist.clear();
				ArrayList<String[]> tabCheck = getDbArrayApp(sql, 1, bindlist,	10, catalog_name);
				if (tabCheck.size() == 0)
					invalid_message = invalid_message
							+ "Table ["
							+ addStartEndForTable(schema_name + "."
									+ table_name)
							+ "] doesn't exists/accessible or empty.\n";
				else
					table_exists = true;
				*/
				
				bindlist.clear();
				
				StringBuilder sbErr=new StringBuilder();
				ArrayList<String[]> tabCheck = getDbArrayApp(sql, 1, bindlist,	10, catalog_name, sbErr);
				if (tabCheck.size() == 0 && sbErr.length()>0)
					invalid_message = invalid_message
							+ "Table ["
							+ addStartEndForTable(schema_name + "."
									+ table_name)
							+ "] doesn't exists/accessible : "+sbErr.toString()+".\n";
				else
					table_exists = true;
				
				
				if (table_exists) {

					if (!skip_fieldcheck_validation) {
						// get real field list from app db
						ArrayList<String> appFieldList = new ArrayList<String>();

						DatabaseMetaData md = null;
						ResultSet rs = null;
						try {
							md = connApp.getMetaData();
							rs = md.getColumns(connApp.getCatalog(),
									schema_name, table_name, null);

							while (rs.next()) {
								String f_name = rs.getString("COLUMN_NAME"); // 4
								System.out.println("Adding Field : " + f_name);
								appFieldList.add(f_name);
							}

						} catch (Exception e) {
							mylog(LOG_LEVEL_ERROR,
									"Exception@getAppFieldList : "
											+ e.getMessage());
							e.printStackTrace();
						} finally {
							try {
								md = null;
							} catch (Exception e) {
							}
							try {
								rs.close();
								rs = null;
							} catch (Exception e) {
							}
						}

						// find missing fields
						for (int f = 0; f < confFieldList.size(); f++) {
							String confFieldName = confFieldList.get(f)[0];
							String confFieldType = confFieldList.get(f)[1];
							boolean found = false;

							mylog(LOG_LEVEL_INFO,
									"Checking ....................... : "
											+ confFieldName + " ...");

							if (confFieldType.equals("CALCULATED"))
								found = true;
							else
								for (int c = 0; c < appFieldList.size(); c++) {
									if (appFieldList.get(c).equals(
											confFieldName)) {
										System.out
												.println("Checking Missing Field : "
														+ appFieldList.get(c)
														+ " with "
														+ confFieldName);
										found = true;
										break;
									}
								}

							if (",ROWID,".contains(","
									+ confFieldName.toUpperCase() + ","))
								found = true;

							// new field
							if (!found) {
								invalid_message = invalid_message + "Table ["
										+ schema_name + "." + table_name
										+ "] has missing field => ["
										+ confFieldName + "].\n";
							}
						}

						// find new fields
						for (int f = 0; f < appFieldList.size(); f++) {
							String appFieldName = appFieldList.get(f);
							boolean found = false;
							for (int i = 0; i < confFieldList.size(); i++)
								if (confFieldList.get(i)[0]
										.equals(appFieldName)) {
									found = true;
									break;
								}

							// new field
							if (!found)
								invalid_message = invalid_message + "Table ["
										+ schema_name + "." + table_name
										+ "] has new field  [" + appFieldName
										+ "] to add.\n";
						}
					} // if !skip_fieldcheck

					// check if partition used
					if (partition_used.equals("YES")) {
						boolean partition_found = true;

						String partition_sql = "";

						sql = "select flexval2 from  tdm_ref where ref_type='DB_TYPE' and ref_name='"
								+ app_driver + "'";
						String template = "";

						try {
							template = getDbArrayConf(sql, 1).get(0)[0];
						} catch (Exception e) {
							template = "";
						}
						;

						if (template.contains("|"))
							try {
								partition_sql = template.split("\\|")[2];
							} catch (Exception e) {
								partition_sql = "";
							}

						bindlist = new ArrayList<String[]>();
						if (partition_sql.contains("=?")
								|| partition_sql.contains("= ?"))
							bindlist.add(new String[] { "STRING", table_name });
						ArrayList<String[]> partitionArr = getDbArrayApp(
								partition_sql, Integer.MAX_VALUE, bindlist, 20);

						if (partitionArr == null || partitionArr.size() == 0)
							partition_found = false;
						else
							hm.put("PARTITION_LIST_" + table_name, partitionArr);

						if (!partition_found)
							invalid_message = invalid_message + "Table ["
									+ schema_name + "." + table_name
									+ "] has no partition.\n";

					}

				}

			} // if (WORK_PLAN_TYPE.equals("DISC") && app_type.equals("COPY"))

			// IS PK EXISTS?
			if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK)
					|| WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK2)) {
				sql = "select * from tdm_fields where is_pk='YES' and tab_id=?";
				bindlist = new ArrayList<String[]>();
				bindlist.add(new String[] { "INTEGER", tab_id });

				ArrayList<String[]> pkCheck = getDbArrayConf(sql, 1, bindlist);
				if (pkCheck.size() == 0)
					invalid_message = invalid_message + "Table [" + schema_name
							+ "." + table_name + "] have no Primary Key.\n";
			}

			if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK)
					|| WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK2)) {
				// IS AT LEAST A UPDATABLE MASKED FIELD EXISTS?
				sql = "select  id from tdm_fields where mask_prof_id>0 and mask_prof_id not in (select id from tdm_mask_prof where rule_id in('GROUP','NONE','HASH_REF')) and tab_id=?"
						+ " union all "
						+ "select  id from tdm_fields where is_conditional='YES' and tab_id=?";

				bindlist = new ArrayList<String[]>();
				bindlist.add(new String[] { "INTEGER", tab_id });
				bindlist.add(new String[] { "INTEGER", tab_id });

				ArrayList<String[]> maskCheck = getDbArrayConf(sql, 1, bindlist);
				if (maskCheck.size() == 0)
					invalid_message = invalid_message + "Table [" + schema_name
							+ "." + table_name
							+ "] have no updating masked field.\n";

				// IS AT LEAST A MASKED FIELD EXISTS?
				sql = "select  field_name  from tdm_fields where is_conditional='YES' and (condition_expr is null or condition_expr='') and tab_id=?";
				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", tab_id });

				ArrayList<String[]> conditionCheck = getDbArrayConf(sql,
						Integer.MAX_VALUE, bindlist);
				for (int c = 0; c < conditionCheck.size(); c++) {
					String f_name = conditionCheck.get(c)[0];
					invalid_message = invalid_message + "Table [" + schema_name
							+ "." + table_name + "] has conditional field ["
							+ f_name + "] with no condition given.\n";
				}

			}

			// CHECK PROFILES WITH NO LIST
			sql = "" + " select field_name,p.src_list_id, run_on_server "
					+ " from tdm_fields f, tdm_mask_prof p "
					+ " where tab_id=?" + " and mask_prof_id>0 "
					+ " and mask_prof_id=p.id " + " and p.src_list_id>0";
			bindlist = new ArrayList<String[]>();
			bindlist.add(new String[] { "INTEGER", tab_id });

			ArrayList<String[]> noListCheck = getDbArrayConf(sql,
					Integer.MAX_VALUE, bindlist);

			for (int i = 0; i < noListCheck.size(); i++) {
				String field_name = noListCheck.get(i)[0];
				int list_id = Integer.parseInt(noListCheck.get(i)[1]);
				String run_on_server = noListCheck.get(i)[2];

				boolean is_list_ok = true;

				sql = "select count(*) from tdm_list where id=?";
				String countx = getDbArrayConfInt(sql, 1, list_id).get(0)[0];
				if (countx.equals("0")) {
					invalid_message = invalid_message + "Table [" + schema_name
							+ "." + table_name
							+ "] specified list for field  (" + field_name
							+ ") does not exists.\n";
					is_list_ok = false;
				}

				sql = "select count(*) from tdm_list_items where list_id=? limit 0,10";
				countx = getDbArrayConfInt(sql, 1, list_id).get(0)[0];
				if (countx.equals("0")) {
					invalid_message = invalid_message + "Table [" + schema_name
							+ "." + table_name
							+ "] specified list for field  (" + field_name
							+ ") have no item.\n";
					is_list_ok = false;
				}

				if (is_list_ok && run_on_server.equals("YES")) {
					boolean is_added_to_server = addListItemsToTheServer(
							wplan_id, list_id);

					if (!is_added_to_server)
						invalid_message = invalid_message
								+ "tdm_list_items was not added successfully to the application DB server.\n";

				}

			}

			// CHECK MULTICOLUMN LIST CHECKS
			sql = "select f.field_name, f.list_field_name, l.title_list "
					+ "	from tdm_fields f,  tdm_mask_prof p, tdm_list l "
					+ "	where tab_id=? " + "	and mask_prof_id>0 "
					+ "	and mask_prof_id=p.id " + "	and p.src_list_id=l.id"
					+ "   and p.rule_id<>'KEYMAP'";

			bindlist = new ArrayList<String[]>();
			bindlist.add(new String[] { "INTEGER", tab_id });

			ArrayList<String[]> pkList = getDbArrayConf(sql, Integer.MAX_VALUE,
					bindlist);
			for (int i = 0; i < pkList.size(); i++) {
				String field_name = pkList.get(i)[0];
				String list_field_name = pkList.get(i)[1];
				String title_list = pkList.get(i)[2];

				if (title_list.contains("|::|")) {
					if (list_field_name.length() == 0
							&& title_list.length() > 0)
						invalid_message = invalid_message + "Table ["
								+ schema_name + "." + table_name
								+ "] no list column was specified for field ("
								+ field_name + ").\n";
					else {
						String[] titleArr = title_list.split("\\|::\\|");
						boolean found = false;
						if (list_field_name.contains(":FIXED"))
							list_field_name = list_field_name.split(":")[0];
						for (int j = 0; j < titleArr.length; j++) {
							if (titleArr[j].equals(list_field_name))
								found = true;
						}

						if (!found)
							invalid_message = invalid_message + "Table ["
									+ schema_name + "." + table_name
									+ "] specified list column name ["
									+ list_field_name
									+ "] was not found for field ("
									+ field_name + ").\n";

					} // if
				}
			}

			// --------------------------------------
			// CHECK JAVASCRIPT & SQL CODE
			// --------------------------------------
			sql = ""
					+ " select field_name,rule_id, js_code "
					+ " from tdm_fields f , tdm_mask_prof p "
					+ " where tab_id=? "
					+ " and mask_prof_id=p.id and rule_id in('JAVASCRIPT','SQL')";
			bindlist = new ArrayList<String[]>();
			bindlist.add(new String[] { "INTEGER", tab_id });

			ArrayList<String[]> jssqlList = getDbArrayConf(sql,
					Integer.MAX_VALUE, bindlist);

			for (int i = 0; i < jssqlList.size(); i++) {
				String field_name = jssqlList.get(i)[0];
				String rule_id = jssqlList.get(i)[1];
				String js_sql_code = jssqlList.get(i)[2];

				if (rule_id.equals(MASK_RULE_JAVASCRIPT)) {

					// referansli maskeleme iceren JS leri valide etme.
					if (js_sql_code.contains("$mask("))
						continue;

					String dummy = maskJavascript(0, "\\$ORIGINAL_VALUE", null,
							js_sql_code, null, null, "-", null);

					if (dummy.equals("$JAVASCRIPT_ERR"))
						invalid_message = invalid_message + "Table ["
								+ schema_name + "." + table_name + "].["
								+ field_name + "] script is invalid";
					else {
						String[] fields = js_sql_code.split("\\$\\{");
						// skipt the first one

						for (int f = 1; f < fields.length; f++) {
							String f_name = fields[f];
							if (f_name.contains("}"))
								f_name = f_name.split("\\}")[0];

							boolean found = false;
							if (f_name.equals("1"))
								found = true;
							if (!found)
								for (int p = 0; p < confFieldList.size(); p++) {

									if (confFieldList.get(p)[0].equals(f_name)) {
										found = true;
										break;
									}
								}

							if (!found)
								invalid_message = invalid_message + "Table ["
										+ schema_name + "." + table_name
										+ "].[" + field_name
										+ "] script refers unknown fieldname ("
										+ f_name + ")";
						}
					}

				} // if rule_id equals JS
			}

		} // for all tables in app

		if (invalid_message.length() > 0) {
			bindlist = new ArrayList<String[]>();
			sql = "update tdm_work_plan set invalid_message=? where id=?";
			bindlist.add(new String[] { "STRING", invalid_message });
			bindlist.add(new String[] { "INTEGER", "" + wplan_id });

			execDBBindingConf(sql, bindlist);

			ret1 = false;
		} else {
			if (app_type.equals("COPY")
					&& WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY))
				createCopyTargetTables(wplan_id);
		}

		closeApp();

		return ret1;
	}

	// ************************************************
	boolean addListItemsToTheServer(int work_plan_id, int list_id) {
		String sql = "";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + work_plan_id });
		bindlist.add(new String[] { "INTEGER", "" + list_id });

		sql = "delete from temp_list_items where work_plan_no=" + work_plan_id
				+ " and list_id=" + list_id;

		boolean is_ok = execAppScript(connApp, sql);

		if (!is_ok) {
			mylog(LOG_LEVEL_ERROR, "temp_list_items table not found");
			return false;
		}

		sql = "select list_val from tdm_list_items where list_id=?";
		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + list_id });

		ArrayList<String[]> arr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		for (int i = 0; i < arr.size(); i++) {
			sql = "insert into temp_list_items (work_plan_no, list_id, list_item_id, list_val) values (?, ?, ?, ?) ";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", "" + work_plan_id });
			bindlist.add(new String[] { "INTEGER", "" + list_id });
			bindlist.add(new String[] { "INTEGER", "" + i });
			bindlist.add(new String[] { "STRING", "" + arr.get(i)[0] });

			execDBBindingApp2(sql, bindlist, bindlist.size());

		}

		return true;
	}

	// ************************************************
	void createCopyTargetTables(int work_plan_id) {
		String sql = "select target_owner_info, env_id, target_env_id, app_id from tdm_work_plan where id=?";
		ArrayList<String[]> arr = getDbArrayConfInt(sql, 1, work_plan_id);
		if (arr == null || arr.size() == 0)
			return;

		String target_info = arr.get(0)[0];
		int source_env_id = 0;
		int target_env_id = 0;
		int app_id = 0;

		try {
			source_env_id = Integer.parseInt(arr.get(0)[1]);
		} catch (Exception e) {
			target_env_id = 0;
		}
		try {
			target_env_id = Integer.parseInt(arr.get(0)[2]);
		} catch (Exception e) {
			target_env_id = 0;
		}
		try {
			app_id = Integer.parseInt(arr.get(0)[3]);
		} catch (Exception e) {
			app_id = 0;
		}

		if (source_env_id == 0)
			return;
		if (target_env_id == 0)
			return;

		String ConnStr = "";
		String Driver = "";
		String User = "";
		String Pass = "";

		sql = "select db_connstr, db_driver, db_username, db_password from tdm_envs where id=?";
		arr = getDbArrayConfInt(sql, 1, target_env_id);
		if (arr == null || arr.size() == 0)
			return;
		ConnStr = arr.get(0)[0];
		Driver = arr.get(0)[1];
		User = arr.get(0)[2];
		Pass = genLib.passwordDecoder(arr.get(0)[3]) ;

		Connection targetConn = getconn(ConnStr, Driver, User, Pass, 1);

		if (targetConn == null)
			return;

		mylog(LOG_LEVEL_INFO,
				"******  checking target tables and creating missing ones ****");
		mylog(LOG_LEVEL_INFO, target_info);

		sql = "select db_type, schema_name, tab_name from tdm_tabs where app_id=?";
		arr = getDbArrayConfInt(sql, Integer.MAX_VALUE, app_id);
		if (arr == null || arr.size() == 0) {
			mylog(LOG_LEVEL_ERROR, "No table found. exit. app id : " + app_id);
			return;
		}

		for (int i = 0; i < arr.size(); i++) {
			String db_type = nvl(getDbType(Driver), arr.get(i)[0]);
			String original_schema_name = arr.get(i)[1];
			String original_table_name = arr.get(i)[2];

			String source_schema_tab = extractCopySource(target_info,
					original_schema_name + "." + original_table_name);
			String source_schema_name = original_schema_name;
			String source_table_name = original_table_name;
			try {
				source_schema_name = source_schema_tab.split("\\.")[0];
			} catch (Exception e) {
			}
			try {
				source_table_name = source_schema_tab.split("\\.")[1];
			} catch (Exception e) {
			}

			String target_schema_tab = extractCopyTarget(target_info,
					original_schema_name + "." + original_table_name);
			String target_schema_name = original_schema_name;
			String target_table_name = original_table_name;
			try {
				target_schema_name = target_schema_tab.split("\\.")[0];
			} catch (Exception e) {
			}
			try {
				target_table_name = target_schema_tab.split("\\.")[1];
			} catch (Exception e) {
			}

			createTable(targetConn, db_type, source_schema_name,
					source_table_name, target_schema_name, target_table_name);

		}

		// try {srcConn.close();} catch(Exception e) {}
		try {
			targetConn.close();
		} catch (Exception e) {
		}

	}

	// ************************************************
	void createTable(Connection targetConn, String db_type,
			String source_schema_name, String source_table_name,
			String target_schema_name, String target_table_name) {

		if (db_type.equals(genLib.DB_TYPE_ORACLE)) {
			String target_object_ddl = getDDLFromOracle(targetConn, "TABLE",
					target_table_name, target_schema_name);
			if (target_object_ddl.length() > 5) {
				mylog(LOG_LEVEL_WARNING, "Table [" + target_schema_name + "."
						+ target_table_name + "]  already exists in target.");
				return;
			}

			String create_ddl = getDDLFromOracle(connApp, "TABLE",
					source_table_name, source_schema_name);
			if (create_ddl.length() < 5) {
				mylog(LOG_LEVEL_WARNING, "Table [" + source_schema_name + "."
						+ source_table_name + "] script cannot be generated.");
				return;
			}

			create_ddl = create_ddl.substring(create_ddl.indexOf("(") - 1);
			create_ddl = "CREATE TABLE "
					+ addStartEndForTable(target_schema_name + "."
							+ target_table_name) + " \n " + create_ddl;

			mylog(LOG_LEVEL_INFO,
					"--------------------------------------------------");
			mylog(LOG_LEVEL_INFO, " CREATE TABLE [" + target_schema_name + "."
					+ target_table_name + "]");
			// mylog("--------------------------------------------------");
			// mylog(create_ddl);
			boolean is_created = execAppScript(targetConn, create_ddl);
			mylog(LOG_LEVEL_INFO,
					"--------------------------------------------------");
			if (is_created) {
				mylog(LOG_LEVEL_INFO, "Table [" + target_schema_name + "."
						+ target_table_name + "] Successfully Created.");
				mylog(LOG_LEVEL_INFO,
						"--------------------------------------------------");
			}

		}

	}

	// ************************************************
	private boolean validateWorkPlanAUTO(int wplan_id) {
		boolean ret1 = true;

		return ret1;
	}

	// ************************************************
	private boolean validateWorkPlanDEPL(int wplan_id) {
		boolean ret1 = true;

		return ret1;
	}

	// ************************************************
	private boolean validateWorkPlan(int wplan_id) {
		boolean ret1 = true;
		hm.clear();

		if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_DEPL))
			ret1 = validateWorkPlanDEPL(wplan_id);
		else {
			String sql = "select app_type from tdm_apps where id=(select app_id from tdm_work_plan where id="
					+ wplan_id + ")";

			String app_type = "";

			try {
				app_type = getDbArrayConf(sql, 1).get(0)[0];
			} catch (Exception e) {
				e.printStackTrace();
			}

			if (app_type.equals("MASK"))
				ret1 = validateWorkPlanMASK(wplan_id, app_type);

			if (app_type.equals("AUTO"))
				ret1 = validateWorkPlanAUTO(wplan_id);
		}

		return ret1;
	}

	// ************************************************
	void createNextWorkPlan(int work_plan_id, String repeat_period,
			int repeat_by) {

		mylog(LOG_LEVEL_INFO, "Duplicating work plan [" + work_plan_id
				+ "] for future run...");
		String sql = "";
		ArrayList<String[]> arr = new ArrayList<String[]>();

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		String repeat_parameters = "";

		sql = "select last_run_point_statement from tdm_apps where id=(select app_id from tdm_work_plan where id=?)";
		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + work_plan_id });
		arr = getDbArrayConf(sql, 1, bindlist);

		if (arr != null && arr.size() == 1) {
			String last_run_point_statement = arr.get(0)[0];

			loadRunParams(work_plan_id);

			bindlist.clear();
			arr = getDbArrayApp(last_run_point_statement, 1, bindlist, 240);

			if (arr != null && arr.size() == 1) {
				String[] rec = arr.get(0);
				for (int i = 0; i < rec.length; i++) {
					if (i > 0)
						repeat_parameters = repeat_parameters + "|::|";
					repeat_parameters = repeat_parameters + rec[i];
				}
			}
		}

		bindlist.clear();
		bindlist.add(new String[] { "STRING", repeat_parameters });

		sql = "" + " insert into tdm_work_plan (" + " work_plan_name, \n"
				+ " wplan_type, \n" + " created_by, \n" + " create_date, \n"
				+ " start_date, \n" + " end_date, \n" + " on_error_action, \n"
				+ " execution_type, \n" + " env_id, \n" + " app_id, \n"
				+ " target_env_id, \n" + " REC_SIZE_PER_TASK, \n"
				+ " TASK_SIZE_PER_WORKER, \n" + " BULK_UPDATE_REC_COUNT, \n"
				+ " COMMIT_LENGTH, \n" + " UPDATE_WPACK_COUNTS_INTERVAL, \n"
				+ " RUN_TYPE, \n" + " target_owner_info, \n"
				+ " master_limit, \n" + " worker_limit, \n"
				+ " copy_filter, \n" + " copy_filter_bind, \n"
				+ " copy_rec_count, \n" + " copy_repeat_count, \n"
				+ " email_address, \n" + " run_options, \n"
				+ " repeat_period, \n" + " repeat_by, \n"
				+ " repeat_parameters, \n" + " main_work_plan_id \n" + " ) \n"
				+ " select " + " work_plan_name, \n" + " wplan_type, \n"
				+ " created_by, \n" + " CURRENT_TIMESTAMP, " + // " now() , \n"+
				" DATE_ADD(start_date,INTERVAL "
				+ repeat_by
				+ " "
				+ repeat_period
				+ "), \n"
				+ // start_date
				" end_date, \n"
				+ " on_error_action, \n"
				+ " execution_type, \n"
				+ " env_id, \n"
				+ " app_id, \n"
				+ " target_env_id, \n"
				+ " REC_SIZE_PER_TASK, \n"
				+ " TASK_SIZE_PER_WORKER, \n"
				+ " BULK_UPDATE_REC_COUNT, \n"
				+ " COMMIT_LENGTH, \n"
				+ " UPDATE_WPACK_COUNTS_INTERVAL, \n"
				+ " RUN_TYPE, \n"
				+ " target_owner_info, \n"
				+ " master_limit, \n"
				+ " worker_limit, \n"
				+ " copy_filter, \n"
				+ " copy_filter_bind, \n"
				+ " copy_rec_count, \n"
				+ " copy_repeat_count, \n"
				+ " email_address, \n"
				+ " run_options, \n"
				+ " repeat_period, \n"
				+ " repeat_by, \n"
				+ " ?, \n"
				+ " id \n"
				+ // main_work_plan_id
				" from tdm_work_plan where id=" + work_plan_id;

		execDBBindingConf(sql, bindlist);

		mylog(LOG_LEVEL_INFO, "Duplicating work plan [" + work_plan_id
				+ "] for future run...Done");
	}

	// ************************************************
	public void createWorkPackages() {

		if (System.currentTimeMillis() < next_create_wpack_ts)
			return;

		// create work package for new work plans
		String sql = "select id, wplan_type, repeat_period, repeat_by  "
				+ " 	from tdm_work_plan wpl"
				+ " where status='NEW' and (start_date is null or start_date<now()) "
				+ " and not exists ( "
				+ "    select 1 from tdm_work_plan_dependency , tdm_work_plan wpd "
				+ "    where work_plan_id=wpl.id "
				+ "    and  depended_work_plan_id=wpd.id "
				+ "    and wpd.status not like 'FINISHED%' and wpd.status not like 'COMPLETED%' "
				+ " ) " + " order by 1";

		ArrayList<String[]> wplist = getDbArrayConf(sql, 10);

		for (int i = 0; i < wplist.size(); i++) {
			int wplan_id = 0;
			String repeat_period = "NONE";
			int repeat_by = 0;

			try {
				wplan_id = Integer.parseInt(wplist.get(i)[0]);
				WORK_PLAN_TYPE = wplist.get(i)[1];
				repeat_period = wplist.get(i)[2];
				repeat_by = Integer.parseInt(wplist.get(i)[3]);

				if (!repeat_period.equals("NONE") && repeat_by > 0)
					createNextWorkPlan(wplan_id, repeat_period, repeat_by);

			} catch (Exception e) {
				wplan_id = 0;
				WORK_PLAN_TYPE = "";
			}

			if (wplan_id > 0) {

				boolean is_valid = validateWorkPlan(wplan_id);

				if (is_valid) {

					createWorkPackage(wplan_id);

					if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK)
							|| WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK2))
						createWorkPlanPostScripts(wplan_id);

					// is valid ise direk scriptleri calistirsin, tum WPC lerin
					// olusmasi beklenmesin
					if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK)
							|| WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_MASK2))
						setWorkPlanStatus(wplan_id, "PREPARATION");

					if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY))
						setWorkPlanStatus(wplan_id, "PREPARATION");

					if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY2))
						setWorkPlanStatus(wplan_id, "RUNNING");

					if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_AUTO))
						setWorkPlanStatus(wplan_id, "RUNNING");

					if (WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_DEPL))
						setWorkPlanStatus(wplan_id, "RUNNING");

				} else {
					setWorkPlanStatus(wplan_id, "INVALID");
				}

			}

		}
		next_create_wpack_ts = System.currentTimeMillis()
				+ CREATE_WPACK_INTERVAL;

	}

	// **********************************************
	void createWorkPlanPostScripts(int wplan_id) {
		StringBuilder sbRebuild = new StringBuilder();
		StringBuilder sbLog = new StringBuilder();

		String sql = "select post_script from tdm_work_plan where id=?";
		String curr_script = "";

		try {
			curr_script = getDbArrayConfInt(sql, 1, wplan_id).get(0)[0];
		} catch (Exception e) {
		}

		// if the post script was generated before, do not overwrite it in case
		// of reply
		if (curr_script.length() > 5)
			return;

		if (app_db_type.equals(genLib.DB_TYPE_ORACLE))
			sbRebuild = createWorkPlanPostScriptsORACLE(wplan_id, sbLog);
		
		if (app_db_type.equals(genLib.DB_TYPE_SYBASE))
			sbRebuild = createWorkPlanPostScriptsSYBASE(wplan_id, sbLog);

		if (app_db_type.equals(genLib.DB_TYPE_MSSQL))
			sbRebuild = createWorkPlanPostScriptsSQLSRV(wplan_id, sbLog);


		
		if (sbRebuild.length() > 1) {
			mylog(LOG_LEVEL_INFO,
					"----------------------------------------------");
			mylog(LOG_LEVEL_INFO, "Saving post script.... : ");
			mylog(LOG_LEVEL_INFO,
					"----------------------------------------------");
			mylog(LOG_LEVEL_INFO, sbRebuild.toString());
			mylog(LOG_LEVEL_INFO,
					"----------------------------------------------");

		}
		
		
		sql = "update tdm_work_plan set post_script=?, prep_script_log=? where id=?";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		
		bindlist.add(new String[] { "STRING", sbRebuild.toString() });
		bindlist.add(new String[] { "STRING", sbLog.toString() });
		bindlist.add(new String[] { "INTEGER", "" + wplan_id });
		execDBBindingConf(sql, bindlist);
	}

	// ***********************************************
	StringBuilder createWorkPlanPostScriptsORACLE(int wplan_id,
			StringBuilder prep_script_log) {
		StringBuilder sb = new StringBuilder();

		mylog(LOG_LEVEL_INFO, "Creation Oracle Post Scripts ");

		ArrayList<String[]> tablist = getTabListToMaskByWp(wplan_id);
		String sql = "";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		ArrayList<String[]> arr = new ArrayList<String[]>();

		for (int i = 0; i < tablist.size(); i++) {
			int tab_id = Integer.parseInt(tablist.get(i)[0]);
			String table_cat = tablist.get(i)[1];
			String table_owner = tablist.get(i)[2];
			String table_name = tablist.get(i)[3];
			String skip_drop_index = tablist.get(i)[4];
			String skip_drop_constraint = tablist.get(i)[5];
			String skip_drop_trigger = tablist.get(i)[6];

			mylog(LOG_LEVEL_INFO, "Generating post scripts for table ["
					+ table_owner + "." + table_name + "]...");
			mylog(LOG_LEVEL_INFO,
					".....................................................................");

			if (skip_drop_trigger.equals("YES")) {
				mylog(LOG_LEVEL_INFO, "Skipping triggers ...");
			} else {
				mylog(LOG_LEVEL_INFO, "Checking triggers ...");
				sql = "select owner, trigger_name  from all_triggers  where table_owner=? and table_name=?";

				bindlist.clear();
				bindlist.add(new String[] { "STRING", table_owner });
				bindlist.add(new String[] { "STRING", table_name });

				arr = getDbArrayApp(sql, Integer.MAX_VALUE, bindlist, 120);
				if (arr != null)
					for (int a = 0; a < arr.size(); a++) {
						String trigger_owner = arr.get(a)[0];
						String trigger_name = arr.get(a)[1];

						String trigger_disable_script = "alter trigger "
								+ trigger_owner + "." + trigger_name
								+ " disable";
						
						execAppScript(connApp, trigger_disable_script,prep_script_log); 


						sb.append("alter trigger " + trigger_owner + "."+ trigger_name + " enable");
						sb.append("\n/\n\n");

					}
			}

			ArrayList<String> objectlist = new ArrayList<String>();

			ArrayList<String[]> fieldlist = getMaskingFieldListByTabId(tab_id);
			if (fieldlist != null)
				for (int f = 0; f < fieldlist.size(); f++) {
					String field_name = fieldlist.get(f)[0];

					if (skip_drop_constraint.equals("YES")) {
						mylog(LOG_LEVEL_INFO, "Skipping  constraints for ["
								+ table_owner + "." + table_name + "]."
								+ field_name);
					} else {
						mylog(LOG_LEVEL_INFO, "Checking constraints for ["
								+ table_owner + "." + table_name + "]."
								+ field_name);
						sql = "select distinct b.constraint_name "
								+ " from all_cons_columns a, all_constraints b "
								+ " where a.owner=?   "
								+ " and a.table_name=?  "
								+ " and a.column_name=?  "
								+ " and a.constraint_name=b.constraint_name "
								+ " and b.constraint_type not in('P')";

						bindlist.clear();
						bindlist.add(new String[] { "STRING", table_owner });
						bindlist.add(new String[] { "STRING", table_name });
						bindlist.add(new String[] { "STRING", field_name });

						arr = getDbArrayApp(sql, Integer.MAX_VALUE, bindlist,
								120);
						if (arr != null)
							for (int a = 0; a < arr.size(); a++) {
								String constraint_name = arr.get(a)[0];
								String object_name = "CONSTRAINT."
										+ constraint_name;
								if (objectlist.indexOf(object_name) > -1)
									continue;
								objectlist.add(object_name);
								String disable_code = "alter table  "+ table_owner + "." + table_name+ " disable constraint "+ constraint_name;
								mylog(LOG_LEVEL_INFO, disable_code);
								
								boolean success = execAppScript(connApp, disable_code,prep_script_log); 
								

								if (success) {
									sb.append("alter table  " + table_owner
											+ "." + table_name
											+ " enable novalidate constraint "
											+ constraint_name);
									sb.append("\n/\n\n");

									
								}

							}
					}

					if (skip_drop_index.equals("YES")) {
						mylog(LOG_LEVEL_INFO, "Skipping indexes for ["
								+ table_owner + "." + table_name + "]."
								+ field_name);
					} else {
						mylog(LOG_LEVEL_INFO, "Checking indexes for ["+ table_owner + "." + table_name + "]."+ field_name);
						sql = "select distinct index_owner, index_name "
								+ " from ALL_IND_COLUMNS where table_owner=?  and table_name=? and column_name=?";

						bindlist.clear();
						bindlist.add(new String[] { "STRING", table_owner });
						bindlist.add(new String[] { "STRING", table_name });
						bindlist.add(new String[] { "STRING", field_name });

						arr = getDbArrayApp(sql, Integer.MAX_VALUE, bindlist,120);
						if (arr != null)
							for (int a = 0; a < arr.size(); a++) {
								String index_owner = arr.get(a)[0];
								String index_name = arr.get(a)[1];
								String object_name = "INDEX." + index_owner	+ "." + index_name;
								if (objectlist.indexOf(object_name) > -1)
									continue;
								objectlist.add(object_name);

								String index_ddl = getDDLFromOracle(connApp,"INDEX", index_name, index_owner);
								String drop_index_code = "drop index "+ index_owner + "." + index_name;
																
								boolean success = execAppScript(connApp, drop_index_code,prep_script_log); 
								
								if (success) {
									if (index_ddl.length() > 0) {
										sb.append(index_ddl);
										sb.append("\n/\n\n");

										if (!index_ddl.toLowerCase().contains(" parallel"))
											index_ddl = index_ddl+ " PARALLEL (degree 16) ";

										
									}
								}
							}
					}

				} // for (int f=0;f<fieldlist.size();f++)

			mylog(LOG_LEVEL_INFO, "Done.");
		}

		return sb;
	}

	// ***********************************************
	StringBuilder createWorkPlanPostScriptsSQLSRV(int wplan_id,	StringBuilder prep_scrip_log) {
		StringBuilder sb = new StringBuilder();

		mylog(LOG_LEVEL_INFO, "Creation MS SQL Server Post Scripts ");

		ArrayList<String[]> tablist = getTabListToMaskByWp(wplan_id);
		String sql = "";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		ArrayList<String[]> arr = new ArrayList<String[]>();

		for (int i = 0; i < tablist.size(); i++) {
			int tab_id = Integer.parseInt(tablist.get(i)[0]);
			String table_cat = tablist.get(i)[1];
			String table_owner = tablist.get(i)[2];
			String table_name = tablist.get(i)[3];
			String skip_drop_index = tablist.get(i)[4];
			String skip_drop_constraint = tablist.get(i)[5];
			String skip_drop_trigger = tablist.get(i)[6];
			
			
			String use_db="use "+table_cat;
			
		


			mylog(LOG_LEVEL_INFO, "Generating post scripts for table ["	+ table_cat + "." + table_owner + "." + table_name + "]...");
			mylog(LOG_LEVEL_INFO, ".....................................................................");

			execAppScript(connApp, use_db, prep_scrip_log);
			
			sb.append(use_db);
			sb.append("\n/\n\n");
			
			if (skip_drop_trigger.equals("YES")) {
				mylog(LOG_LEVEL_INFO, "Skipping triggers ...");
			} else {
				mylog(LOG_LEVEL_INFO, "Checking triggers ...");
				sql = "select schema_Name(uid) as schema_name, name  "
						+ " from sysobjects  with (nolock) where type = 'TR' "
						+ " and parent_obj in  "
						+ " (select id from sysobjects   with (nolock) where  schema_Name(uid)=? and name=? and type='U' and parent_obj=0) \n"
						+ " and not  exists (select 1 from sys.triggers tr with (nolock)   where tr.object_id=id and is_disabled=1) ";

				bindlist.clear();
				bindlist.add(new String[] { "STRING", table_owner });
				bindlist.add(new String[] { "STRING", table_name });

				arr = getDbArrayApp(sql, Integer.MAX_VALUE, bindlist, 120, table_cat);
				
				if (arr != null)
					for (int a = 0; a < arr.size(); a++) {
						String trigger_owner = arr.get(a)[0];
						String trigger_name = arr.get(a)[1];
						
						String trigger_disable_code = "alter table ["+ table_cat + "].["+ table_owner + "].[" + table_name+ "] disable trigger [" + trigger_name + "]";
						execAppScript(connApp, trigger_disable_code, prep_scrip_log);

						sb.append("alter table [" + table_owner + "].["	+ table_name + "] enable trigger ["	+ trigger_name + "]");
						sb.append("\n/\n\n");

					}
			}

			ArrayList<String> objectlist = new ArrayList<String>();

			ArrayList<String[]> fieldlist = getMaskingFieldListByTabId(tab_id);
			if (fieldlist != null)
				for (int f = 0; f < fieldlist.size(); f++) {
					String field_name = fieldlist.get(f)[0];

					if (skip_drop_constraint.equals("YES")) {
						mylog(LOG_LEVEL_INFO, "Skipping constraints for ["+ table_owner + "." + table_name + "]."+ field_name);
					} else {
						mylog(LOG_LEVEL_INFO, "Checking constraints for ["+ table_owner + "." + table_name + "]."+ field_name);
						sql = "SELECT constraint_name \n"
								+ " FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE   with (nolock) \n"
								+ " where table_schema=? \n"
								+ " and table_name=? \n" + " and column_name=? ";

						bindlist.clear();
						bindlist.add(new String[] { "STRING", table_owner });
						bindlist.add(new String[] { "STRING", table_name });
						bindlist.add(new String[] { "STRING", field_name });

						arr = getDbArrayApp(sql, Integer.MAX_VALUE, bindlist,120, table_cat);
						if (arr != null)
							for (int a = 0; a < arr.size(); a++) {
								String constraint_name = arr.get(a)[0];
								String object_name = "CONSTRAINT."
										+ constraint_name;
								if (objectlist.indexOf(object_name) > -1)
									continue;
								objectlist.add(object_name);
								

								String constraint_disable_code = "alter table   [" + table_cat+ "].["+ table_owner	+ "].["	+ table_name+ "]  NOCHECK constraint ["+ constraint_name+"]";
								boolean success = execAppScript(connApp, constraint_disable_code, prep_scrip_log);

								if (success) {
									sb.append("alter table   [" + table_cat+ "].[" + table_owner+ "].[" + table_name+ "]  CHECK constraint ["+ constraint_name+"]");
									sb.append("\n/\n\n");

									
								}

							}
					}

					if (skip_drop_index.equals("YES")) {
						mylog(LOG_LEVEL_INFO, "Skipping indexes for ["
								+ table_owner + "." + table_name + "]."
								+ field_name);
					} else {
						mylog(LOG_LEVEL_INFO, "Checking indexes for ["
								+ table_owner + "." + table_name + "]."
								+ field_name);
						sql = "select distinct schema_Name(t.schema_id) as index_schema, i.name index_name  \n"
								+ " from sys.indexes i  with (nolock) , sys.index_columns ic  with (nolock) , sys.columns c  with (nolock) , sys.tables t  with (nolock)  \n"
								+ " where i.object_id=ic.object_id and i.index_id=ic.index_id  \n"
								+ " and ic.object_id=c.object_id and ic.column_id=c.column_id \n"
								+ " and i.is_primary_key='false' and i.type_desc!='HEAP' and i.type in (1,2) \n"
								+ " and i.object_id=t.object_id and t.type='U' and t.parent_object_id=0  \n"
								+ " and schema_Name(t.schema_id)=?  \n"
								+ " and t.name=? \n" + " and c.name=?";

						bindlist.clear();
						bindlist.add(new String[] { "STRING", table_owner });
						bindlist.add(new String[] { "STRING", table_name });
						bindlist.add(new String[] { "STRING", field_name });

						arr = getDbArrayApp(sql, Integer.MAX_VALUE, bindlist,120);
						if (arr != null)
							for (int a = 0; a < arr.size(); a++) {
								String index_owner = arr.get(a)[0];
								String index_name = arr.get(a)[1];
								String object_name = "INDEX." + index_owner
										+ "." + index_name;
								if (objectlist.indexOf(object_name) > -1)
									continue;
								objectlist.add(object_name);
								
								
								String index_disable_code = "alter index ["+ index_name + "] on [" + table_cat+ "].[" + table_owner+ "].[" + table_name + "] disable";
								boolean success = execAppScript(connApp,index_disable_code,prep_scrip_log);
								if (success) {
									//disable diye bir komut yok, rebuild ediyoruz
									//sb.append("alter index [" + index_name+ "] on [" + table_cat+ "].[" + table_owner + "].["+ table_name + "] enable");
									//sb.append("\n/\n\n");
									sb.append("alter index [" + index_name+ "] on [" + table_cat+ "].[" + table_owner + "].["+ table_name + "] rebuild");
									sb.append("\n/\n\n");

									
								}

							}
					}

				} // for (int f=0;f<fieldlist.size();f++)

			mylog(LOG_LEVEL_INFO, "Done.");
		}

		return sb;
	}
	
	
	// ***********************************************
	StringBuilder createWorkPlanPostScriptsSYBASE(
			int wplan_id,
			StringBuilder prep_scrip_log
			) {
		StringBuilder sb = new StringBuilder();

		mylog(LOG_LEVEL_INFO, "Creation SYBASE Server Post Scripts ");

		ArrayList<String[]> tablist = getTabListToMaskByWp(wplan_id);
		String sql = "";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		ArrayList<String[]> arr = new ArrayList<String[]>();

		for (int i = 0; i < tablist.size(); i++) {
			int tab_id = Integer.parseInt(tablist.get(i)[0]);
			String table_cat = tablist.get(i)[1];
			String table_owner = tablist.get(i)[2];
			String table_name = tablist.get(i)[3];
			String skip_drop_index = tablist.get(i)[4];
			String skip_drop_constraint = tablist.get(i)[5];
			String skip_drop_trigger = tablist.get(i)[6];
			
			
			
			mylog(LOG_LEVEL_INFO, "Generating post scripts for table ["+ table_cat + "." + table_owner + "." + table_name + "]...");
			mylog(LOG_LEVEL_INFO,".....................................................................");

			if (skip_drop_trigger.equals("YES")) {
				mylog(LOG_LEVEL_INFO, "Skipping triggers ...");
			} else {
				mylog(LOG_LEVEL_INFO, "Checking triggers ...");
				sql = "select \n"+
						"	(select name from sysusers where uid=o_tr.uid) triggger_owner, \n"+
						"	o_tr.name trigger_name \n"+
						"	from sysobjects o_tr \n"+
						"	where o_tr.type = 'TR' \n"+
						"	and deltrig in (select id from sysobjects o_tab , sysusers  usr where  o_tab.type='U' and usr.uid=o_tab.uid and usr.name=? and o_tab.name=?) ";

				bindlist.clear();
				bindlist.add(new String[] { "STRING", table_owner});
				bindlist.add(new String[] { "STRING", table_name});
				
				
				arr = getDbArrayApp(sql, Integer.MAX_VALUE, bindlist, 120, table_cat);
				

				for (int a = 0; a < arr.size(); a++) {
					
					String trigger_owner = arr.get(a)[0];
					String trigger_name = arr.get(a)[1];
					
					String trigger_disable_code = "alter table \""+table_cat+"\".\""+ table_owner + "\".\"" + table_name+ "\" disable trigger \"" + trigger_name + "\"";
					boolean is_dropped=execAppScript(connApp,trigger_disable_code,prep_scrip_log);

					if (!is_dropped) continue;
					
					String use_db="use "+table_cat;
					
					String trigger_enable_code = "alter table \""+table_cat+"\".\""+ table_owner + "\".\"" + table_name+ "\" enable trigger \"" + trigger_name + "\"";
					
					sb.append(use_db);
					sb.append("\n/\n\n");
					
					sb.append(trigger_enable_code);
					sb.append("\n/\n\n");

				}
			}
			
			//--------------------------------------------------------------------------------------
			//-- CONSTRAINTS 
			//--------------------------------------------------------------------------------------

			if (skip_drop_constraint.equals("YES")) {
				mylog(LOG_LEVEL_INFO, "Skipping constraints ...");
			} else {
				mylog(LOG_LEVEL_INFO, "Checking constraints ...");
				sql = "select name constraint_name \n"+
						"	from sysobjects where  \n"+
						"	type='R' \n"+
						"	and id in \n"+
						" ( \n"+
						"	select constrid from sysconstraints where status in (64,128,256) \n"+
						"	and tableid in (select id from sysobjects o_tab , sysusers  usr where  o_tab.type='U' and usr.uid=o_tab.uid and usr.name=? and o_tab.name=? ) \n"+
						" ) ";
						
				bindlist.clear();
				bindlist.add(new String[] { "STRING", table_owner});
				bindlist.add(new String[] { "STRING", table_name});
				
				
				arr = getDbArrayApp(sql, Integer.MAX_VALUE, bindlist, 120, table_cat);
				

				for (int a = 0; a < arr.size(); a++) {
					
					String constraint_name = arr.get(a)[0];
					String constraint_text="";
					sql="select c.text from syscomments c, sysobjects o where o.id=c.id and o.name=? order by c.colid";
					bindlist.clear();
					bindlist.add(new String[] { "STRING", constraint_name});
					
					ArrayList<String[]> arrText = getDbArrayApp(sql, Integer.MAX_VALUE, bindlist, 10, table_cat);
					if (arrText!=null && arrText.size()>0) 
						for (int c=0;c<arrText.size();c++) {
							if (constraint_text.length()>0) constraint_text=constraint_text+"\n";
							constraint_text=constraint_text+arrText.get(c)[0];
						}
							
					
					
					String constraint_drop_code = "ALTER TABLE \""+table_cat+"\".\""+ table_owner + "\".\"" + table_name+ "\"  DROP CONSTRAINT \""+constraint_name+"\"";
					
					boolean is_dropped=execAppScript(connApp,constraint_drop_code,prep_scrip_log);

					if (!is_dropped) continue;
					
					if (constraint_text.length()>0) {
						String use_db="use "+table_cat;
						String constraint_recreate_code = "ALTER TABLE  \""+table_cat+"\".\""+ table_owner + "\".\"" + table_name+ "\" ADD  "+constraint_text;
						
						sb.append(use_db);
						sb.append("\n/\n\n");
						
						sb.append(constraint_recreate_code);
						sb.append("\n/\n\n");
					}
					
				}
			}
			
			
			
			//--------------------------------------------------------------------------------------
			//-- INDEXES 
			//--------------------------------------------------------------------------------------

			if (skip_drop_index.equals("YES")) {
				mylog(LOG_LEVEL_INFO, "Skipping Indexes ...");
			} else {
				mylog(LOG_LEVEL_INFO, "Checking Indexes ...");
				sql = "select i.name, i.keycnt-1 colcnt, \n"+
						"	index_col('pubs2.dbo.test_table',indid,01) col01, \n"+
						"	index_col('pubs2.dbo.test_table',indid,02) col02, \n"+
						"	index_col('pubs2.dbo.test_table',indid,03) col03, \n"+
						"	index_col('pubs2.dbo.test_table',indid,04) col04, \n"+
						"	index_col('pubs2.dbo.test_table',indid,05) col05, \n"+
						"	index_col('pubs2.dbo.test_table',indid,06) col06, \n"+
						"	index_col('pubs2.dbo.test_table',indid,07) col07, \n"+
						"	index_col('pubs2.dbo.test_table',indid,08) col08, \n"+
						"	index_col('pubs2.dbo.test_table',indid,09) col09, \n"+
						"	index_col('pubs2.dbo.test_table',indid,10) col10, \n"+
						"	index_col('pubs2.dbo.test_table',indid,11) col11, \n"+
						"	index_col('pubs2.dbo.test_table',indid,12) col12, \n"+
						"	index_col('pubs2.dbo.test_table',indid,13) col13, \n"+
						"	index_col('pubs2.dbo.test_table',indid,14) col14, \n"+
						"	index_col('pubs2.dbo.test_table',indid,15) col15 \n"+
						"	from sysindexes i, sysobjects o , sysusers  usr \n"+
						"	where o.id = i.id and o.uid=usr.uid \n"+
						"	and usr.name=? and o.name = ? and i.indid >1";
						
				bindlist.clear();
				bindlist.add(new String[] { "STRING", table_owner});
				bindlist.add(new String[] { "STRING", table_name});
				
				
				arr = getDbArrayApp(sql, Integer.MAX_VALUE, bindlist, 120, table_cat);
				
				sql="select field_name from tdm_fields where tab_id=? and is_pk='NO' and (mask_prof_id>0 or is_conditional='YES')";
				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", ""+tab_id});
				
				ArrayList<String[]> maskingColList = getDbArrayConf(sql, Integer.MAX_VALUE,bindlist);

				
				
				for (int a = 0; a < arr.size(); a++) {
					
					String index_name = arr.get(a)[0];
					String index_recreate_code="";
					String related_cols="";
					
					int colcnt=Integer.parseInt(arr.get(a)[1]);
					
					for (int c=0;c<colcnt;c++) {
						if (related_cols.length()>0) related_cols=related_cols+",";
						related_cols=related_cols+"\""+arr.get(a)[2+c]+"\"";
					}



					int match_count=0;
					
					for (int f=0;f<maskingColList.size();f++) {
						String field_name=maskingColList.get(f)[0];
						if (related_cols.indexOf(""+field_name+"")>-1) {
							match_count++;
							break;
						}
					}
					
					if (match_count==0) continue;

					
					
					String constraint_drop_code = "DROP INDEX " + table_name+ "."+index_name+"";
					
					genLib.setCatalogForConnection(connApp, table_cat);
					
					boolean is_dropped=execAppScript(connApp,constraint_drop_code,prep_scrip_log);
					
					if (!is_dropped) continue;

					index_recreate_code = "CREATE INDEX "+index_name+" on \""+ table_owner + "\".\"" + table_name+ "\" ("+related_cols+") ";
					
					String use_db="use "+table_cat;

					sb.append(use_db);
					sb.append("\n/\n\n");
					
					sb.append(index_recreate_code);
					sb.append("\n/\n\n");
					
				}
			}
			
			mylog(LOG_LEVEL_INFO, "Done.");
		}

		return sb;
	}

	// ***********************************************
	boolean execAppScript(String sql) {
		return execAppScript(connApp, sql);
	}

	// ***********************************************
	boolean execAppScript(Connection conn, String sql) {
		boolean ret1 = false;
		// ************************
		mylog(LOG_LEVEL_DEBUG, sql);
		if (conn != null) {
			try {

				conn.createStatement().executeUpdate(sql);
				ret1 = true;
			} catch (Exception e) {
				mylog(LOG_LEVEL_ERROR,
						"Exception@execAppScript : " + e.getMessage());
				e.printStackTrace();
			}
		}

		return ret1;
	}
	// ***********************************************
	boolean execAppScript(Connection conn, String sql, StringBuilder sbLog) {
		boolean ret1 = false;
		// ************************
		sbLog.append("Executing :\n "+sql+"\n");
		mylog(LOG_LEVEL_DEBUG, sql);
		
		Statement stmt=null;
				
		if (conn != null) {
			try {
				long start_ts=System.currentTimeMillis();
				stmt=conn.createStatement();
				stmt.executeUpdate(sql);
				
				//conn.createStatement().executeUpdate(sql);
				ret1 = true;
				sbLog.append("\nExecuted Successfully. Duration : "+(System.currentTimeMillis()-start_ts)+"\n\n");
			} catch (Exception e) {
				mylog(LOG_LEVEL_ERROR,
						"Exception@execAppScript : " + e.getMessage());
				sbLog.append("Exception@execAppScript : "+genLib.getStackTraceAsStringBuilder(e).toString()+"\n\n");
				e.printStackTrace();
			} finally {
				try {stmt.close();} catch (SQLException e) {}
			}
		}

		return ret1;
	}

	// ***********************************************
	String getDDLFromOracle(Connection conn, String object_type,
			String object_name, String object_owner) {
		String ret1 = "";
		String sql = "select dbms_metadata.get_ddl(?,?,?) from dual";

		if (object_type.toUpperCase().equals("TABLE")) {
			String ddl = "begin";
			ddl = ddl
					+ "\n"
					+ "DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false); \n"
					+ "DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'TABLESPACE',false); \n"
					+ "DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false); \n"
					+ "DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'REF_CONSTRAINTS',false); \n"
					+ "DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PARTITIONING',false); \n"
					+ "DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS',false); \n";
			ddl = ddl + "commit; \n end;";
			execAppScript(conn, ddl);
		}

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "STRING", object_type });
		bindlist.add(new String[] { "STRING", object_name });
		bindlist.add(new String[] { "STRING", object_owner });

		// ArrayList<String[]> arr=getDbArrayApp(sql, Integer.MAX_VALUE,
		// bindlist, 120);
		String ddl = getDbSingleVal(conn, sql, bindlist);
		if (ddl != null)
			ret1 = ddl;

		// if (arr!=null && arr.size()>0) ret1=arr.get(0)[0];

		return ret1;

	}

	// ***********************************************
	ArrayList<String[]> getTabListToMaskByWp(int wplan_id) {
		String sql = "select distinct id, cat_name, schema_name, tab_name, skip_drop_index, skip_drop_constraint, skip_drop_trigger  "
				+ " from tdm_tabs  "
				+ " where app_id in(select app_id from tdm_work_plan where id="
				+ wplan_id + ") " + " and mask_level not in ('DELETE') ";
		return getDbArrayConf(sql, Integer.MAX_VALUE);
	}

	// ***********************************************
	ArrayList<String[]> getMaskingFieldListByTabId(int tab_id) {
		String sql = "select field_name " + " from tdm_fields  "
				+ " where tab_id=" + tab_id + " and is_pk<>'YES' "
				+ " and (mask_prof_id>0 or is_conditional='YES') "
				+ " and (calc_prof_id=0 or calc_prof_id is null)";
		return getDbArrayConf(sql, Integer.MAX_VALUE);
	}

	// ***********************************************
	public byte[] getInfoBin(String table_name, int p_id, String field_name) {

		byte[] ret1 = null;
		String sql = "select " + field_name + " from " + table_name
				+ " where id=?";

		PreparedStatement pstmtConf = null;
		ResultSet rsetConf = null;

		try {

			pstmtConf = connConf.prepareStatement(sql);
			pstmtConf.setInt(1, p_id);

			rsetConf = pstmtConf.executeQuery();

			while (rsetConf.next()) {
				try {
					ret1 = rsetConf.getBytes(1);
				} catch (Exception e) {
					ret1 = null;
				}
				break;
			}

		} catch (Exception ignore) {
			mylog(LOG_LEVEL_ERROR,
					"getDbArrayConf Exception : " + ignore.getMessage());
			myerr("getDbArrayConf sql : " + sql);
			ret1 = null;
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

	// *************************************************
	public static byte[] compress(String data) {
		byte[] input;
		try {
			input = data.getBytes();
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		return compress(input);
	}

	// *************************************************
	public static byte[] compress(byte[] input) {

		Deflater df = new Deflater();
		df.setLevel(Deflater.BEST_COMPRESSION);
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

	// ******************************************************
	public static String uncompress(byte[] input) {

		if (input == null)
			return "";

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
				return "ERROR";
			}
			baos.write(buff, 0, count);

		}

		byte[] output = baos.toByteArray();
		try {
			baos.close();
		} catch (IOException e) {
		}

		try {
			return new String(output, "UTF-8");
		} catch (Exception e) {
			return "ERROR";
		}

	}

	// *********************************************
	private boolean checkIf(String val_to_check, String oper, String ctrl_vals) {
		// oper ========> =, !=, like, !like, in, !in,

		// mylog("*** Check if ["+val_to_check+"] "+oper + " ["+ ctrl_vals+"]");

		if (oper.equals("=")) {
			if (val_to_check.equals(ctrl_vals))
				return true;
		}

		if (oper.equals("!=")) {
			if (!val_to_check.equals(ctrl_vals))
				return true;
		}

		if (oper.equals(">")) {
			try {
				int i_val_to_check = Integer.parseInt(val_to_check);
				int i_ctrl_vals = Integer.parseInt(ctrl_vals);
				if (i_val_to_check > i_ctrl_vals)
					return true;
			} catch (Exception e) {
				return false;
			}
		}

		if (oper.equals("<")) {
			try {
				int i_val_to_check = Integer.parseInt(val_to_check);
				int i_ctrl_vals = Integer.parseInt(ctrl_vals);
				if (i_val_to_check < i_ctrl_vals)
					return true;
			} catch (Exception e) {
				return false;
			}
		}

		if (oper.equals("isnull")) {
			if (val_to_check.length() == 0)
				return true;
		}

		if (oper.equals("notnull")) {
			if (val_to_check.length() > 0)
				return true;
		}

		if (oper.equals("like")) {
			if (val_to_check.indexOf(ctrl_vals) > -1)
				return true;
		}

		if (oper.equals("!like")) {
			if (val_to_check.indexOf(ctrl_vals) == -1)
				return true;
		}

		if (oper.equals("in")) {
			String[] ctrlArr = ctrl_vals.split(",");
			for (int i = 0; i < ctrlArr.length; i++)
				if (ctrlArr[i].trim().indexOf(val_to_check) > -1)
					return true;
			return false;
		}

		if (oper.equals("!in")) {
			String[] ctrlArr = ctrl_vals.split(",");
			boolean found = false;
			for (int i = 0; i < ctrlArr.length; i++)
				if (ctrlArr[i].trim().indexOf(val_to_check) > -1) {
					found = true;
					break;
				}
			return !found;
		}

		return false;

	}

	// *********************************************************
	public void killDeadProcesses() {
		if (System.currentTimeMillis() < next_kill_dead_masters_ts)
			return;
		next_kill_dead_masters_ts = System.currentTimeMillis()
				+ KILL_DEAD_PROCESS_INTERVAL;

		// Date expireDate = new Date(System.currentTimeMillis() -
		// KILL_DEAD_MASTER_TIMEOUT);

		String sql = "select id,'MASTER' proc_type from tdm_master where last_heartbeat<? "
				+ " union all "
				+ " select id,'WORKER' proc_type from tdm_worker where last_heartbeat<? ";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		// SimpleDateFormat df=new SimpleDateFormat(DEFAULT_DATE_FORMAT);
		// String date_str=df.format(expireDate);

		// bindlist.add(new String[]{"DATE",""+date_str});
		// bindlist.add(new String[]{"DATE",""+date_str});

		long killts = System.currentTimeMillis() - KILL_DEAD_PROCESS_TIMEOUT;

		bindlist.add(new String[] { "TIMESTAMP", "" + killts });
		bindlist.add(new String[] { "TIMESTAMP", "" + killts });

		ArrayList<String[]> expiredMasterList = getDbArrayConf(sql,
				Integer.MAX_VALUE, bindlist);
		if (expiredMasterList != null && expiredMasterList.size() == 0)
			mylog(LOG_LEVEL_INFO, "No Dead Process Found :)");

		for (int i = 0; i < expiredMasterList.size(); i++) {

			String aExpiredProcessId = expiredMasterList.get(i)[0];
			String aExpiredProcessType = expiredMasterList.get(i)[1];
			mylog(LOG_LEVEL_WARNING, "Expired " + aExpiredProcessType
					+ " found. Will be killed  :  " + aExpiredProcessId);

			bindlist = new ArrayList<String[]>();
			bindlist.add(new String[] { "INTEGER", "" + aExpiredProcessId });

			if (aExpiredProcessType.equals("MASTER")) {
				sql = "delete from tdm_master where id=?";
				execDBBindingConf(sql, bindlist);
				sql = "update tdm_work_package set status='NEW',master_id=null, last_activity_date=null where status='RUNNING' and master_id=?";
				execDBBindingConf(sql, bindlist);
			} else if (aExpiredProcessType.equals("WORKER")) {
				sql = "delete from tdm_worker where id=?";
				execDBBindingConf(sql, bindlist);
				resumeTasksByWorkerId(Integer.parseInt(aExpiredProcessId));

			}

		}

	}



	// *********************************************************
	public void resumeStalled() {

		if (System.currentTimeMillis() < next_resume_stalled_ts)
			return;

		mylog(LOG_LEVEL_INFO, "Checking for stalleds...");

		String sql = "select task_id id,'TASK' stall_type ,work_plan_id, work_package_id from tdm_task_assignment "
				+ " where status in ('RUNNING','ASSIGNED') "
				+ " and  work_plan_id in (select id from tdm_work_plan where status='RUNNING') "
				+ " and  last_activity_date<? "
				+ " union all "
				+ " select id,'WORK_PACKAGE' stall_type, work_plan_id, id work_package_id from tdm_work_package "
				+ " where status in ('MASKING','EXPORTING','ASSIGNED','COPYING') "
				+ " and  work_plan_id in (select id from tdm_work_plan where status='RUNNING' and wplan_type not in ('DEPL','COPY2') ) "
				+ " and  last_activity_date<?";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		long stall_ts = System.currentTimeMillis() - WAIT_BEFORE_RESUME_TIMEOUT;
		bindlist.add(new String[] { "TIMESTAMP", "" + stall_ts });
		bindlist.add(new String[] { "TIMESTAMP", "" + stall_ts });

		ArrayList<String[]> stalledList = getDbArrayConf(sql,
				Integer.MAX_VALUE, bindlist);
		for (int i = 0; i < stalledList.size(); i++) {

			String aStalledId = stalledList.get(i)[0];
			String aStalledType = stalledList.get(i)[1];
			String work_plan_id = stalledList.get(i)[2];
			String work_package_id = stalledList.get(i)[3];

			mylog(LOG_LEVEL_WARNING, "Stalled " + aStalledType
					+ " found. Will be resumed  :  " + aStalledId);
			bindlist = new ArrayList<String[]>();
			bindlist.add(new String[] { "INTEGER", "" + aStalledId });

			if (aStalledType.equals("WORK_PACKAGE")) {
				sql = "update tdm_work_package set status='NEW',master_id=null, last_activity_date=null, "
						+ " duration=0, export_count=0, done_count=0, success_count=0, fail_count=0 "
						+ " where id=?";
				execDBBindingConf(sql, bindlist);

			} else {
				sql = "update tdm_task_"
						+ work_plan_id
						+ "_"
						+ work_package_id
						+ " set status='NEW',worker_id=null,last_activity_date=null, "
						+ " duration=0, done_count=0, success_count=0, fail_count=0, retry_count=0 "
						+ " where id=?";
				execDBBindingConf(sql, bindlist);

				sql = "delete from tdm_task_assignment where task_id=? and work_package_id=?";
				bindlist.add(new String[] { "INTEGER", "" + work_package_id });

				execDBBindingConf(sql, bindlist);

			}
		}

		// assign edilip uzun suredir alinmayan wpc leri bosa cikar

		sql = "update tdm_work_package "
				+ " 	set status='NEW', master_id=null, assign_date=null "
				+ "	where status='ASSIGNED' and master_id in (select id from tdm_master) "
				+ "	and assign_date<=date_add(now(), INTERVAL  -5 MINUTE )";
		bindlist.clear();
		execDBBindingConf(sql, bindlist);

		next_resume_stalled_ts = System.currentTimeMillis()
				+ RESUME_STALLED_TIMEOUT;

	}

	// *********************************************************
	public void removeOldMaskingWorkPackages() {
		String sql = "";

		String keep_day = genLib.nvl(getParamByName("MASKING_KEEP_PERIOD"),
				"30");

		try {
			Integer.parseInt(keep_day);
		} catch (Exception e) {
			keep_day = "30";
		}

		sql = "delete from tdm_work_package where work_plan_id in ("
				+ " select  id from tdm_work_plan where wplan_type='MASK2' and  DATEDIFF(now(),create_date)>"
				+ keep_day + ")";

		execDBConf(sql);

		sql = "delete from tdm_work_plan where wplan_type='MASK2' and  DATEDIFF(now(),create_date)>"
				+ keep_day;

		execDBConf(sql);
	}

	static final long DELETE_UNUSED_TABLES_INTERVAL = 3 * 60 * 60 * 1000;
	long next_delete_unused_tables_ts = 0;

	// *********************************************************
	public void deleteUnusedTaskTables(boolean force) {

		if (System.currentTimeMillis() < next_delete_unused_tables_ts && !force)
			return;

		removeOldMaskingWorkPackages();

		mylog(LOG_LEVEL_INFO, "Checking for unused task tables...");

		String sql = "select table_name from information_schema.TABLES "
				+ " where table_name like 'tdm_task_%' or table_name like 'TDM_TASK_%' "
				+ " and table_schema=database()";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		ArrayList<String[]> unusedList = getDbArrayConf(sql, Integer.MAX_VALUE);

		mylog(LOG_LEVEL_INFO, "" + unusedList.size() + " task tables(s) found.");

		String wpc_sql = "select count(*) from tdm_work_package where work_plan_id=? and id=?";

		String wpl_sql = "select count(*) from tdm_work_plan where id=?";

		for (int i = 0; i < unusedList.size(); i++) {

			heartbeat(TABLE_TDM_MANAGER, 0, 0);

			String table_name = unusedList.get(i)[0];
			String[] arr = table_name.split("_");
			int work_plan_id = 0;
			int work_package_id = 0;
			try {
				work_plan_id = Integer.parseInt(arr[2]);
				work_package_id = Integer.parseInt(arr[3]);

				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", "" + work_plan_id });
				bindlist.add(new String[] { "INTEGER", "" + work_package_id });

				int wpc_count = Integer.parseInt(getDbArrayConf(wpc_sql, 1,
						bindlist).get(0)[0]);

				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", "" + work_plan_id });

				int wpl_count = Integer.parseInt(getDbArrayConf(wpl_sql, 1,
						bindlist).get(0)[0]);

				if (wpc_count == 0 || wpl_count == 0) {
					execDBConf("drop table " + table_name);
					mylog(LOG_LEVEL_INFO, "UNUSED Table dropped : "
							+ table_name);
				}

			} catch (Exception e) {
				mylog(LOG_LEVEL_INFO, "skipping : " + table_name);
			}

		}

		next_delete_unused_tables_ts = System.currentTimeMillis()
				+ DELETE_UNUSED_TABLES_INTERVAL;

	}

	long last_set_wpack_export_count_ts = 0;
	static final long SET_WPACK_EXPORT_COUNT_INTERVAL = 30000;

	// *********************************************************
	private void setWpackExportCount(int work_pack_id, long recno, boolean force) {
		if (System.currentTimeMillis() < last_set_wpack_export_count_ts
				&& !force)
			return;
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "";
		if (recno >= 0) {
			sql = "update tdm_work_package set export_count=?,";
			sql = sql + " last_activity_date=now() where id=?";
			bindlist.add(new String[] { "LONG", "" + recno });
			bindlist.add(new String[] { "INTEGER", "" + work_pack_id });
		} else {
			sql = "update tdm_work_package set last_activity_date=now() where id=?";
			bindlist.add(new String[] { "INTEGER", "" + work_pack_id });
		}

		execDBBindingConf(sql, bindlist);

		last_set_wpack_export_count_ts = System.currentTimeMillis()
				+ SET_WPACK_EXPORT_COUNT_INTERVAL;
	}

	// *********************************************************
	private void renewWorkPackage(int work_pack_id, int work_plan_id) {

		mylog(LOG_LEVEL_WARNING, "Renewing work package : " + work_pack_id);

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		String sql = "truncate table tdm_task_" + work_plan_id + "_"
				+ work_pack_id;

		if (!WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_DEPL)
				&& !WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_COPY2))
			execDBBindingConf(sql, bindlist);

		sql = "update tdm_work_package set status='NEW', master_id=null where id=?";
		bindlist.add(new String[] { "INTEGER", "" + work_pack_id });
		execDBBindingConf(sql, bindlist);

	}

	// *********************************************************

	void renewAllWorkPackagesByMasterId(int master_id) {
		String sql = "select id , work_plan_id from tdm_work_package where master_id=?";
		ArrayList<String[]> arr = getDbArrayConfInt(sql, Integer.MAX_VALUE,
				master_id);
		if (arr != null && arr.size() > 0)
			for (int i = 0; i < arr.size(); i++) {
				int work_package_id = Integer.parseInt(arr.get(i)[0]);
				int work_plan_id = Integer.parseInt(arr.get(i)[1]);
				renewWorkPackage(work_package_id, work_plan_id);
			}

	}

	// *********************************************************
	public void countAndSetStatusForMainDeploymentWpl(int work_plan_id,
			boolean skip_deploy) {
		String sql = "";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		sql = "select work_plan_name from tdm_work_plan where id=?";
		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + work_plan_id });
		ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);

		if (arr == null || arr.size() == 0)
			return;

		String work_plan_name = arr.get(0)[0];

		mylog(LOG_LEVEL_INFO, "Counting deployment sub package.["
				+ work_plan_name + "]");

		sql = "select status, count(*) from tdm_work_package where work_plan_id=? group by status";
		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + work_plan_id });

		ArrayList<String[]> wpcArr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		ArrayList<String> finishedStatusArr = new ArrayList<String>();
		finishedStatusArr.add("FINISHED");
		finishedStatusArr.add("FAILED");

		if (skip_deploy)
			finishedStatusArr.add("NEW");

		boolean is_work_plan_finished = true;

		for (int i = 0; i < wpcArr.size(); i++) {
			String wpc_status = wpcArr.get(i)[0];
			if (finishedStatusArr.indexOf(wpc_status) == -1) {
				is_work_plan_finished = false;
				break;
			}
		}

		if (is_work_plan_finished)
			setWorkPlanStatus(work_plan_id, "FINISHED");

		sql = "select wpd.work_plan_id, wpl.status "
				+ " from tdm_work_plan_dependency wpd, tdm_work_plan wpl "
				+ " where wpd.depended_work_plan_id=? "
				+ " and wpd.work_plan_id=wpl.id ";
		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + work_plan_id });

		ArrayList<String[]> mainWplArr = getDbArrayConf(sql, 1, bindlist);

		if (mainWplArr == null || mainWplArr.size() == 0) {
			mylog(LOG_LEVEL_ERROR,
					"Main Work Plan not found for sub work plan : "
							+ work_plan_id + ".");
			return;
		}

		String main_work_plan_id = mainWplArr.get(0)[0];
		String main_work_plan_status = mainWplArr.get(0)[1];

		if (main_work_plan_status.equals("FINISHED"))
			return;

		sql = "select count(*) \n"
				+ "	from tdm_work_plan_dependency wpd, tdm_work_plan wpl \n"
				+ "	where wpd.depended_work_plan_id=wpl.id \n"
				+ "	and wpd.work_plan_id=? \n"
				+ "	and wpl.status not in('FINISHED')";

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + main_work_plan_id });

		ArrayList<String[]> finishedCntArr = getDbArrayConf(sql, 1, bindlist);

		if (finishedCntArr == null || finishedCntArr.size() == 0) {
			mylog(LOG_LEVEL_ERROR, "Counting error for main work plan : "
					+ main_work_plan_id + ".");
			return;
		}

		int unfinished_sub_work_plan_count = -1;

		try {
			unfinished_sub_work_plan_count = Integer.parseInt(finishedCntArr
					.get(0)[0]);
		} catch (Exception e) {
			unfinished_sub_work_plan_count = -1;
		}

		if (unfinished_sub_work_plan_count == 0)
			setWorkPlanStatus(Integer.parseInt(main_work_plan_id), "FINISHED");

		mylog(LOG_LEVEL_INFO, "Done.Counting deployment sub package.["
				+ work_plan_name + "]");

	}

	// ********************************
	int checkCompletedWorkPlanSucces(int work_plan_id, String wplan_type,
			String run_type) {
		int ret1 = 100;

		if (app_db_type.equals(genLib.DB_TYPE_JBASE))
			return ret1;

		return ret1;
	}

	// *******************************
	public String nvl(String in, String out) {
		String r = "";
		try {
			r = in;
			if (r.equals("null"))
				r = "";
		} catch (Exception e) {
			r = "";
		}

		if (r.length() == 0)
			r = out;

		return r;
	}

	// *****************************************
	public void balanceMasterProcesses() {
		if (System.currentTimeMillis() < next_new_process_check_ts)
			return;

		/*
		String tabList = "tdm_master,tdm_worker";
		String classList = "com.mayatech.tdm.masterDriver,com.mayatech.tdm.workerDriver";
		String paramList = "TARGET_MASTER_COUNT,TARGET_WORKER_COUNT";
		*/
		
		String tabList = "tdm_master";
		String classList = "com.mayatech.tdm.masterDriver";
		String paramList = "TARGET_MASTER_COUNT";
		
		String[] tabs = tabList.split(",");
		for (int i = 0; i < tabs.length; i++) {

			String tab_name = tabs[i];
			String class_name = classList.split(",")[i];
			String param_name = paramList.split(",")[i];

			String sql = "select count(*) x from " + tab_name;
			int active_count = 0;
			int target_count = 0;

			try {
				active_count = Integer
						.parseInt(getDbArrayConf(sql, 1).get(0)[0]);
			} catch (Exception e) {
				active_count = -1;
				continue;
			}
			try {
				target_count = Integer.parseInt(nvl(getParamByName(param_name),
						"0"));
			} catch (Exception e) {
				target_count = 0;
				continue;
			}

			if (param_name.equals("TARGET_MASTER_COUNT")) {
				if (target_count > LIC_MASTER_LIMIT) {
					target_count = LIC_MASTER_LIMIT;
					setParamByName(param_name, "" + target_count);
				}

			}

			if (param_name.equals("TARGET_WORKER_COUNT")) {
				if (target_count > LIC_WORKER_LIMIT) {
					target_count = LIC_WORKER_LIMIT;
					setParamByName(param_name, "" + target_count);
				}

			}

			if (active_count >= 0) {
				// add new processes
				if (active_count < target_count) {
					int dif = target_count - active_count;
					if (dif > 5)
						dif = 5;
					startNewProcess(class_name, dif, null);
					mylog(LOG_LEVEL_INFO, "starting new " + class_name + "... ");
				}

				// drop processes
				if (active_count > target_count) {
					int dif = active_count - target_count;
					if (tab_name.equals("tdm_worker"))
						sql = "select id from " + tab_name
								+ " where cancel_flag<>'YES'";
					else
						sql = "select id from " + tab_name
								+ " where status='FREE' ";
					ArrayList<String[]> killList = getDbArrayConf(sql, dif);
					for (int k = 0; k < killList.size(); k++) {
						String kill_id = killList.get(k)[0];
						mylog(LOG_LEVEL_INFO, "killing " + class_name
								+ " of id :  " + kill_id);
						sql = "update " + tab_name
								+ " set cancel_flag='YES' where id=" + kill_id;
						execDBConf(sql);
					}
				}
			}

		}

		String sql = "select process_class, process_count from tdm_add_process";
		ArrayList<String[]> processArr = getDbArrayConf(sql, 100);
		sql = "delete from tdm_add_process";
		execDBConf(sql);

		if (processArr.size() > 10)
			return;
		for (int i = 0; i < processArr.size(); i++) {
			String process_class = processArr.get(i)[0];
			try {
				int process_count = Integer.parseInt(processArr.get(i)[1]);
				startNewProcess(process_class, process_count, null);
			} catch (Exception e) {
				e.printStackTrace();
				return;
			}

		}

		next_new_process_check_ts = System.currentTimeMillis()
				+ NEXT_NEW_PROCESS_CHECK_INTERVAL;

	}

	// ************************************************
	public void startNewProcess(String run_classname, int process_count,
			ArrayList<String> additional_env_params) {

		String HomePath = getParamByName("TDM_PROCESS_HOME");
		String username = getParamByName("CONFIG_USERNAME");
		String password = decode(getParamByName("CONFIG_PASSWORD"));

		int additional_env_params_size = 0;
		if (additional_env_params != null)
			additional_env_params_size = additional_env_params.size();

		String[] envparams = new String[2 + additional_env_params_size];

		envparams[0] = "CONFIG_USERNAME=" + username;
		envparams[1] = "CONFIG_PASSWORD=" + password;

		if (additional_env_params_size > 0)
			for (int i = 0; i < additional_env_params_size; i++)
				envparams[2 + i] = additional_env_params.get(i);

		/*
		 * String[] envparams=new String[]{ "CONFIG_USERNAME="+username,
		 * "CONFIG_PASSWORD="+password };
		 */

		mylog(LOG_LEVEL_INFO, "new " + run_classname + " is being started : "
				+ process_count);
		String fname;
		String system_type = "";
		String run_cmd = "";

		String OS = System.getProperty("os.name").toLowerCase();
		if (OS.indexOf("win") >= 0) {
			run_cmd = "cmd /c start XXX";
			system_type = ".bat";
		}

		if (OS.indexOf("nix") >= 0 || OS.indexOf("nux") >= 0
				|| OS.indexOf("aix") > 0 || OS.indexOf("sunos") >= 0) {
			run_cmd = "/home/oracle/tdm/bin/XXX 1 &";
			system_type = ".sh";
		}

		run_cmd = nvl(getParamByName("PROCESS_START_COMMAND_TEMPLATE"),
				"/home/oracle/tdm/bin/XXX 1 &");

		mylog(LOG_LEVEL_INFO, "system type : " + system_type);
		File dir = new File(".");
		File[] filesList = dir.listFiles();
		for (File file : filesList) {
			if (file.isFile()) {
				fname = file.getName();
				if (fname.toLowerCase().contains(system_type)) {
					try {
						Scanner scanner = new Scanner(file);
						while (scanner.hasNextLine()) {
							final String lineFromFile = scanner.nextLine();
							if (lineFromFile.contains(run_classname)
									&& lineFromFile.contains("java")) {
								// a match!
								mylog(LOG_LEVEL_INFO, "Running new process "
										+ run_classname + " " + process_count
										+ " times..");
								System.out.println("Running new process "
										+ run_classname + " " + process_count
										+ " times..");

								for (int i = 0; i < process_count; i++) {

									run_cmd = run_cmd.replaceAll("XXX", fname);
									mylog(LOG_LEVEL_INFO, "Running command : "
											+ run_cmd);
									System.out.println("Running command : "
											+ run_cmd);

									Runtime.getRuntime().exec(run_cmd,
											envparams, new File(HomePath));
									sleep(50);
								}
								return;
							}
						}
						scanner.close();
					} catch (Exception e) {
						e.printStackTrace();
					}
				}

			}
		}

	}

	// *****************************************************
	public boolean amITheFirstMaster() {
		// *****************************************************
		String sql = "";

		sql = "select id master_id from tdm_master where status='FREE' and cancel_flag<>'YES'  "
				+ " and last_heartbeat>DATE_ADD(now(), INTERVAL -5 MINUTE) "
				+ " order by id ";
		ArrayList<String[]> masterArr = getDbArrayConf(sql, 1);

		if (masterArr == null)
			return false;

		if (masterArr.size() == 0)
			return false;

		// it is not me to execute the script
		if (!masterArr.get(0)[0].equals("" + master_id))
			return false;

		return true;
	}

	// *****************************************************
	public boolean amITheFirstWorker() {
		// *****************************************************
		String sql = "";

		sql = "select id worker_id from tdm_worker where status='FREE' and cancel_flag<>'YES' "
				+ " and last_heartbeat>DATE_ADD(now(), INTERVAL -5 MINUTE) "
				+ " order by id ";
		ArrayList<String[]> workerArr = getDbArrayConf(sql, 1);

		if (workerArr == null)
			return false;

		if (workerArr.size() == 0)
			return false;

		// it is not me to execute the script
		if (!workerArr.get(0)[0].equals("" + worker_id))
			return false;

		return true;
	}

	long next_mad_delete_unsaved_requests_and_temp_ts = 0;
	static final int NEXT_MAD_DELETE_UNSAVED_REQUESTS_AND_TEMP_INTERVAL = 10 * 60 * 1000;

	// ******************************************************
	public void deleteUnsavedMadRequestsAndTempFiles() {
		if (System.currentTimeMillis() < next_mad_delete_unsaved_requests_and_temp_ts)
			return;

		mylog(LOG_LEVEL_INFO,
				"deleteUnsavedMadRequestsAndTempFiles... Start...");
		next_mad_delete_unsaved_requests_and_temp_ts = System
				.currentTimeMillis()
				+ NEXT_MAD_DELETE_UNSAVED_REQUESTS_AND_TEMP_INTERVAL;

		String sql = "select id from mad_request "
				+ " where is_saved='NO' and entdate<DATE_SUB(now(),INTERVAL 1 DAY) "
				+ " limit 0,100";

		ArrayList<String[]> arr = getDbArrayConf(sql, 1000);

		if (arr == null || arr.size() == 0) {
			mylog(LOG_LEVEL_INFO, "No unsaved request to clean...");

		}

		long start_ts = System.currentTimeMillis();

		int DELETE_LIMIT = 20 * 1000;

		String[] sqlsToDelete = new String[] {
				"delete from mad_request_application where request_id=?",
				"delete from mad_request_app_env where request_id=?",
				"delete from mad_request_application_member where request_id=?",
				"delete from mad_request_attachment where request_id=?",
				"delete from mad_request_env_fields where request_id=?",
				"delete from mad_request_fields where request_id=?",
				"delete from mad_request_link where request_id=?",
				"delete from mad_request where id=?" };

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		int deleted = 0;

		if (arr != null)
			for (int i = 0; i < arr.size(); i++) {
				if (System.currentTimeMillis() > start_ts + DELETE_LIMIT)
					break;
				String request_id = arr.get(i)[0];
				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", request_id });
				mylog(LOG_LEVEL_INFO, "Clearing usaved request id : "
						+ request_id + " ...");
				for (int s = 0; s < sqlsToDelete.length; s++) {
					execDBBindingConf(sqlsToDelete[s], bindlist);

				}
				deleted++;
			}

		String PURGE_DEPLOYMENT_FOLDERS = nvl(
				getParamByName("PURGE_DEPLOYMENT_FOLDERS"), "NO");

		if (PURGE_DEPLOYMENT_FOLDERS.equals("YES")) {

			String deployment_base_path = getDeploymentBaseDir();

			String PURGE_DEPLOYMENT_INTERVAL = nvl(
					getParamByName("PURGE_DEPLOYMENT_INTERVAL"), "1");

			long LONG_PURGE_DEPLOYMENT_INTERVAL = 1;

			try {
				LONG_PURGE_DEPLOYMENT_INTERVAL = Long
						.parseLong(PURGE_DEPLOYMENT_INTERVAL);
			} catch (Exception e) {
			}

			// convert to msecs
			LONG_PURGE_DEPLOYMENT_INTERVAL = LONG_PURGE_DEPLOYMENT_INTERVAL * 60 * 60 * 1000;

			File baseFile = null;

			try {
				baseFile = new File(deployment_base_path);
				if (!baseFile.exists()) {
					mylog(LOG_LEVEL_WARNING, deployment_base_path
							+ " not exists");
				} else if (!baseFile.isDirectory()) {
					mylog(LOG_LEVEL_WARNING, deployment_base_path
							+ " is not a directory");
				} else {
					File[] reqDirs = baseFile.listFiles();
					if (reqDirs != null)
						for (int r = 0; r < reqDirs.length; r++) {
							if (!reqDirs[r].isDirectory())
								continue;

							String reqFilePath = reqDirs[r].getPath();
							mylog(LOG_LEVEL_INFO, "Checking " + reqFilePath
									+ "....");
							File fAttempts = new File(reqFilePath);
							File[] attemptDirs = fAttempts.listFiles();

							if (attemptDirs == null || attemptDirs.length == 0) {
								try {
									fAttempts.delete();
									deleted++;
								} catch (Exception e) {
									e.printStackTrace();
								}
							} else
								for (int s = 0; s < attemptDirs.length; s++) {
									if (!attemptDirs[s].isDirectory())
										continue;

									String attempthFilePath = attemptDirs[s]
											.getPath();

									long last_modified = attemptDirs[s]
											.lastModified();

									if (last_modified <= System
											.currentTimeMillis()
											- LONG_PURGE_DEPLOYMENT_INTERVAL) {

										try {
											org.apache.commons.io.FileUtils
													.deleteDirectory(attemptDirs[s]);
											deleted++;
											mylog(LOG_LEVEL_INFO,
													"Temp Folder Deleted  : "
															+ attemptDirs[s]
																	.getPath());
										} catch (Exception e) {
											e.printStackTrace();
										}

									}

								}
						}

				}
			} catch (Exception e) {
				mylog(LOG_LEVEL_WARNING, genLib.getStackTraceAsStringBuilder(e)
						.toString());
			}

		} // if (PURGE_DEPLOYMENT_FOLDERS.equals("YES"))

		mylog(LOG_LEVEL_INFO,
				"deleteUnsavedMadRequestsAndTempFiles... Finish..." + deleted
						+ " Request or Temp File cleared, ");

	}

	// *****************************************************
	String getDeploymentBaseDir() {
		// *****************************************************
		String deployment_base_path = getParamByName("MAD_BASE_DIRECTORY");

		if (deployment_base_path.length() == 0) {
			deployment_base_path = System.getProperty("user.home");
		}

		deployment_base_path = deployment_base_path + File.separator + "build";

		return deployment_base_path;
	}

	// *****************************************************
	public void sendMadNotifications(boolean force) {
		// *****************************************************
		if (System.currentTimeMillis() < next_mad_notification_ts && !force)
			return;

		next_mad_notification_ts = System.currentTimeMillis()+ NEXT_MAD_NOTIFICATION_INTERVAL;
		String sql = "";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		ArrayList<String[]> arr = new ArrayList<String[]>();

		if (!amITheFirstMaster() && !force)
			return;

		setMasterStatus("BUSY");
		// setWorkerStatus("BUSY");

		mylog(LOG_LEVEL_INFO, "Start : sendMadNotifications ");

		try {

			String fromEmail = "";
			String fromName = "";
			String subject = "";
			StringBuilder body = new StringBuilder();
			ArrayList<String> toEmailList = new ArrayList<String>();
			ArrayList<String> toNameList = new ArrayList<String>();

			ArrayList<String> ccEmailList = new ArrayList<String>();
			ArrayList<String> ccNameList = new ArrayList<String>();

			ArrayList<String> bccEmailList = new ArrayList<String>();
			ArrayList<String> bccNameList = new ArrayList<String>();

			sql = "select \n"
					+ "	id, request_id, flow_id, flow_state_action_id, action_note, next_state_id, next_state_user, next_state_date \n"
					+ "	from mad_request_flow_logs \n"
					+ "	where notification_sent='NO' and status='CLOSED' \n"
					+ "   and notification_attempt_date<=DATE_ADD(now(), INTERVAL -5 MINUTE) "
					+ "	order by next_state_date limit 0,50 ";

			bindlist.clear();
			ArrayList<String[]> notArr = getDbArrayConf(sql, Integer.MAX_VALUE,	bindlist);

			// set notification_attempt_date as now()
			sql = "update mad_request_flow_logs set notification_attempt_date=now() where id=?";
			for (int i = 0; i < notArr.size(); i++) {
				String request_flow_log_id = notArr.get(i)[0];

				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", request_flow_log_id });
				execDBBindingConf(sql, bindlist);

			}

			if (notArr.size() == 0) {
				mylog(LOG_LEVEL_INFO, "Empty notification list..");
			}

			for (int i = 0; i < notArr.size(); i++) {
				if (master_id > 0)
					heartbeat(TABLE_TDM_MASTER, 0, master_id);
				else
					heartbeat(TABLE_TDM_WORKER, 0, worker_id);

				String request_flow_log_id = notArr.get(i)[0];
				String request_id = notArr.get(i)[1];
				String flow_id = notArr.get(i)[2];
				String flow_state_action_id = notArr.get(i)[3];
				String action_note = notArr.get(i)[4];
				String next_state_id = notArr.get(i)[5];
				String next_state_user = notArr.get(i)[6];
				String next_state_date = notArr.get(i)[7];

				body.setLength(0);

				toEmailList.clear();
				toNameList.clear();

				ccEmailList.clear();
				ccNameList.clear();

				bccEmailList.clear();
				bccNameList.clear();

				// request owner i ve aksiyon owneri cc ye ekle

				sql = "select id, email, concat(fname, ' ', lname) from tdm_user where id in(select entuser from mad_request where id=?) ";

				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", request_id });
				arr = getDbArrayConf(sql, 1, bindlist);

				if (arr.size() == 0) {
					mylog(LOG_LEVEL_WARNING,
							"Request openers user info not found for request id : "
									+ request_id);
					continue;
				}

				String request_user_id = arr.get(0)[0];
				String request_owner_email_address = arr.get(0)[1];
				String request_owner_name = arr.get(0)[2];
				// add request owner to cc
				toEmailList.add(request_owner_email_address);
				toNameList.add(request_owner_name);

				sql = "select email, concat(fname, ' ', lname) from tdm_user where id=?";

				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", next_state_user });
				arr = getDbArrayConf(sql, 1, bindlist);

				String action_taker_email_address = "";
				String action_taker_name = "";

				if (arr.size() == 0) {
					mylog(LOG_LEVEL_WARNING,"Action owner's email address not found for user id : "	+ next_state_user);
					continue;
				} else {
					// add action taker to cc

					action_taker_email_address = arr.get(0)[0];
					action_taker_name = arr.get(0)[1];

					ccEmailList.add(action_taker_email_address);
					ccNameList.add(action_taker_name);
				}

				String notification_id = "";
				sql = "select email_template_id from mad_flow_state_action where id=?";
				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", flow_state_action_id });
				arr = getDbArrayConf(sql, 1, bindlist);

				if (arr.size() == 1)
					notification_id = arr.get(0)[0];

				// no template found for the taken action. look for default
				// notification template for the flow
				if (notification_id.length() == 0) {

					sql = "select email_template_id from mad_flow where id=?";
					bindlist.clear();
					bindlist.add(new String[] { "INTEGER", flow_id });
					arr = getDbArrayConf(sql, 1, bindlist);

					if (arr.size() == 0) {
						mylog(LOG_LEVEL_WARNING,
								"No default notification template found for flow id : "
										+ flow_id);
						continue;
					}

					notification_id = arr.get(0)[0];
				}

				sql = "select email_subject, email_body, from_type, from_email, from_name from mad_email_template where id=?";
				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", notification_id });
				arr = getDbArrayConf(sql, 1, bindlist);

				if (arr.size() == 0) {
					mylog(LOG_LEVEL_WARNING,
							"Notification template not found with id  : "
									+ notification_id);
					continue;
				}

				String tmp_email_subject = arr.get(0)[0];
				String tmp_email_body = arr.get(0)[1];
				String tmp_from_type = arr.get(0)[2];
				String tmp_from_email = arr.get(0)[3];
				String tmp_from_name = arr.get(0)[4];

				if (tmp_from_type.equals("FIXED")) {
					fromEmail = tmp_from_email;
					fromName = tmp_from_name;
				} else if (tmp_from_type.equals("OPENER")) {
					fromEmail = request_owner_email_address;
					fromName = request_owner_name;
				} else if (tmp_from_type.equals("OPENER")) {
					fromEmail = action_taker_email_address;
					fromName = action_taker_name;
				}

				if (fromEmail.length() == 0) {
					fromEmail = "noreply@mayatech.com.tr";
					fromName = "Maya MAD";
				}

				subject = replaceMailSubjectBody(tmp_email_subject, request_id,
						request_flow_log_id);
				body.append(replaceMailSubjectBody(tmp_email_body, request_id,
						request_flow_log_id));

				// Get Email addresses of all next possible actions
				sql = "select distinct permission_id \n"
						+ "	from mad_flow_state_action_permissions \n"
						+ "	where flow_state_action_id in ( \n"
						+ "			select id  \n"
						+ "			from mad_flow_state_action  \n"
						+ "			where flow_state_id=?  \n"
						+ "			and action_type='HUMAN')";

				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", next_state_id });
				ArrayList<String[]> nextActionPermsArr = getDbArrayConf(sql,
						Integer.MAX_VALUE, bindlist);

				ArrayList<String[]> nextActionEmailList = getEmailListByPermission(
						nextActionPermsArr, request_user_id);

				for (int n = 0; n < nextActionEmailList.size(); n++) {

					String next_action_email_address = nextActionEmailList
							.get(n)[0];
					String next_action_email_name = nextActionEmailList.get(n)[1];

					if (!toEmailList.contains(next_action_email_address)) {

						toEmailList.add(next_action_email_address);
						toNameList.add(next_action_email_name);

					}
				}

				// Adding additional notification groups
				sql = "select group_id, group_name, common_email_address "
						+ " from mad_flow_state_action_groups fsag, mad_group g "
						+ " where flow_state_action_id=? and group_id=g.id and g.group_type='NOTIFICATION'";
				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", flow_state_action_id });
				ArrayList<String[]> notifyGrpArr = getDbArrayConf(sql,
						Integer.MAX_VALUE, bindlist);

				for (int g = 0; g < notifyGrpArr.size(); g++) {
					String notify_group_id = notifyGrpArr.get(g)[0];
					String notify_group_name = notifyGrpArr.get(g)[1];
					String notify_common_email_address = notifyGrpArr.get(g)[2];

					if (notify_common_email_address.contains("@")
							&& notify_common_email_address.contains(".")) {

						if (!toEmailList.contains(notify_common_email_address)) {
							toEmailList.add(notify_common_email_address);
							toNameList.add(notify_group_name);
						}

						continue;
					}

					// get group member recursively

					ArrayList<String[]> groupList = getGroupEmailInfoList(
							notify_group_id, 1);

					for (int l = 0; l < groupList.size(); l++) {
						String group_member_email_addr = groupList.get(l)[0];
						String group_member_name = groupList.get(l)[1];

						if (toEmailList.contains(group_member_email_addr))
							continue;

						toEmailList.add(group_member_email_addr);
						toNameList.add(group_member_name);

					}

				} // for (int g=0;g<notifyGrpArr.size();g++)

				sendMadNotificationMail(request_id, request_flow_log_id,
						fromEmail, fromName, subject, body, toEmailList,
						toNameList, ccEmailList, ccNameList, bccEmailList,
						bccNameList);

			} // for arrNot

		} catch (Exception e) {
			mylog(LOG_LEVEL_ERROR,
					"Exception@sendMadNotifications : " + e.getMessage());
			e.printStackTrace();
		}

		setMasterStatus("FREE");
		// setWorkerStatus("FREE");
		mylog(LOG_LEVEL_INFO, "End : sendMadNotifications ");

		next_mad_notification_ts = System.currentTimeMillis()
				+ NEXT_MAD_NOTIFICATION_INTERVAL;

	}

	// *****************************************************************************************
	ArrayList<String[]> getEmailListByPermission(
			ArrayList<String[]> nextActionPermsArr, String request_user_id) {
		ArrayList<String[]> userArr = new ArrayList<String[]>();

		for (int i = 0; i < nextActionPermsArr.size(); i++) {
			String permission_id = nextActionPermsArr.get(i)[0];

			if (Integer.parseInt(permission_id) > 0)
				userArr.addAll(getPermissionUserList(request_user_id));
			else {
				// request owner already added before. so skip it.
				if (permission_id.equals("-1"))
					continue;

				if (permission_id.equals("-2"))
					userArr.addAll(getManagerUserList(request_user_id));

				if (permission_id.equals("-3"))
					userArr.addAll(getRoleBasedUserList("ADMIN"));

				if (permission_id.equals("-4"))
					userArr.addAll(getRoleBasedUserList("MADRM"));

				if (permission_id.equals("-5"))
					userArr.addAll(getGroupMembersUserList(request_user_id));
			}

		}

		ArrayList<String[]> ret1 = new ArrayList<String[]>();

		// get email info's of users
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "select email, concat(fname, ' ', lname) from tdm_user where id=?";

		for (int i = 0; i < userArr.size(); i++) {
			String user_id = userArr.get(i)[0];
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", user_id });

			ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);

			if (arr.size() == 0)
				continue;

			ret1.add(new String[] { arr.get(0)[0], arr.get(0)[1] });
		}

		return ret1;
	}

	// ********************************************************************************************
	ArrayList<String[]> getPermissionUserList(String permission_id) {

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "select distinct member_id from "
				+ "	mad_group_permission gp, mad_group g, mad_group_members gm"
				+ "	where gp.permission_id=?"
				+ "	and gp.group_id=g.id and g.group_type='USER'"
				+ "	and g.id=gm.group_id and member_type='USER'";

		bindlist.add(new String[] { "STRING", permission_id });
		return getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);

	}

	// ********************************************************************************************
	ArrayList<String[]> getManagerUserList(String user_id) {
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "select distinct g.manager_user_id "
				+ "	from mad_group_members gm, mad_group g, tdm_user u "
				+ "	where member_type='USER'  "
				+ "	and member_id=? and gm.group_id=g.id and g.manager_user_id=u.id   "
				+ "	and g.group_type='USER'";

		bindlist.add(new String[] { "STRING", user_id });
		return getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);

	}

	// ********************************************************************************************
	ArrayList<String[]> getRoleBasedUserList(String role) {
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "select user_id from tdm_user_role  "
				+ " where role_id=(select id from tdm_role where shortcode=?)";
		bindlist.add(new String[] { "STRING", role });
		return getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);
	}

	// ********************************************************************************************

	ArrayList<String[]> getGroupMembersUserList(String user_id) {

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "select distinct gm2.member_id "
				+ "	from  "
				+ "	mad_group_members gm, mad_group g, mad_group_members gm2, mad_group g2 "
				+ "	where gm.member_type='USER'  " + "	and gm.member_id=? "
				+ "	and gm.group_id=g.id and g.group_type='USER' "
				+ "	and g.id=gm2.group_id and gm2.member_type='USER'  "
				+ "	and gm2.group_id=g2.id and g2.group_type='USER'";

		bindlist.add(new String[] { "STRING", user_id });
		return getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);
	}

	// ***************************************************************************************
	String clearHtml(String instr) {

		StringBuilder sb = new StringBuilder();
		sb.append(instr);

		ArrayList<String[]> replArr = new ArrayList<String[]>();

		replArr.add(new String[] { "<", "&#60;" });
		replArr.add(new String[] { ">", "&#62;" });
		replArr.add(new String[] { "&#32;", " " }); // space

		for (int i = 0; i < replArr.size(); i++) {
			String what = replArr.get(i)[0];
			String with = replArr.get(i)[1];

			while (true) {
				int pos = sb.indexOf(what);
				if (pos == -1)
					break;
				sb.delete(pos, pos + what.length());
				sb.insert(pos, with);
			}
		} // for

		return sb.toString();

	}

	// ****************************************************************************************
	String replaceMailSubjectBody(String instr, String request_id,
			String request_flow_log_id) {
		StringBuilder sb = new StringBuilder();

		ArrayList<String[]> confArr = new ArrayList<String[]>();

		confArr.add(new String[] { "REQUEST_ID", "request_id",
				"select ? from dual" });

		confArr.add(new String[] { "REQUEST_DESCRIPTION", "request_id",
				"select description from mad_request where id=?" });

		confArr.add(new String[] { "REQUEST_DATE", "request_id",
				"select entdate from mad_request where id=?" });

		confArr.add(new String[] {
				"REQUEST_TYPE",
				"request_id",
				"select (select request_type from mad_request_type where id=request_type_id) from mad_request where id=?" });

		confArr.add(new String[] {
				"REQUEST_USER",
				"request_id",
				"select (select concat(fname, ' ', lname) from tdm_user where id=entuser) from mad_request where id=?" });

		confArr.add(new String[] { "REQUEST_STATUS", "request_id",
				"select status from mad_request where id=?" });

		confArr.add(new String[] {
				"ACTION",
				"request_flow_log_id",
				"select (select action_name from mad_flow_state_action where id=flow_state_action_id)  from mad_request_flow_logs where id=?" });

		confArr.add(new String[] {
				"OLD_STATUS",
				"request_flow_log_id",
				"select (select state_title from mad_flow_state where id=flow_state_id)  from mad_request_flow_logs where id=?" });

		confArr.add(new String[] {
				"NEW_STATUS",
				"request_flow_log_id",
				"select (select state_title from mad_flow_state where id=next_state_id)  from mad_request_flow_logs where id=?" });

		confArr.add(new String[] {
				"ACTION_USER",
				"request_flow_log_id",
				"select (select concat(fname, ' ', lname) from tdm_user where id=next_state_user)  from mad_request_flow_logs where id=?" });

		confArr.add(new String[] { "ACTION_NOTE", "request_flow_log_id",
				"select action_note  from mad_request_flow_logs where id=?" });

		confArr.add(new String[] { "ACTION_DATE", "request_flow_log_id",
				"select next_state_date  from mad_request_flow_logs where id=?" });

		String sql = "select field_parameter_name, field_value, rf.flex_field_id  \n"
				+ "	from  \n"
				+ "	mad_request r, mad_request_type_field rtf, mad_request_fields rf \n"
				+ "	where r.request_type_id=rtf.request_type_id \n"
				+ "	and r.id=rf.request_id and rtf.flex_field_id=rf.flex_field_id \n"
				+ "	and r.id=?";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		bindlist.add(new String[] { "INTEGER", request_id });
		ArrayList<String[]> arr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		for (int i = 0; i < arr.size(); i++) {
			String field_parameter_name = arr.get(i)[0];
			String field_value = arr.get(i)[1];
			String flex_field_id = arr.get(i)[2];

			if (field_parameter_name.length() == 0)
				field_parameter_name = "FIELD_" + flex_field_id;

			confArr.add(new String[] { field_parameter_name, "flex_field",
					field_value });
		}

		sb.append(instr);

		while (true) {
			boolean found = false;

			for (int i = 0; i < confArr.size(); i++) {
				String param_name = confArr.get(i)[0];
				String bind_name = confArr.get(i)[1];
				sql = confArr.get(i)[2];

				param_name = "${" + param_name + "}";
				int pos = sb.indexOf(param_name);
				if (pos == -1)
					continue;

				String bindval = "";
				String replace_val = "";

				if (bind_name.equals("request_id"))
					bindval = request_id;
				else if (bind_name.equals("request_flow_log_id"))
					bindval = request_flow_log_id;
				else if (bind_name.equals("flex_field"))
					replace_val = sql;

				if (!bind_name.equals("flex_field")) {
					bindlist.clear();
					if (bindval.length() > 0)
						bindlist.add(new String[] { "INTEGER", bindval });

					arr = getDbArrayConf(sql, 1, bindlist);
					if (arr.size() == 0)
						continue;
					replace_val = clearHtml(arr.get(0)[0]);

				}

				while (pos > -1) {
					pos = sb.indexOf(param_name);
					if (pos > -1) {
						sb.delete(pos, pos + param_name.length());
						sb.insert(pos, replace_val);
					}

				}

			}

			if (!found)
				break;
		}

		return sb.toString();

	}

	// *********************************************************************************
	void sendMadNotificationMail(String request_id, String request_flow_log_id,
			String fromEmail, String fromName, String subject,
			StringBuilder body, ArrayList<String> toEmailList,
			ArrayList<String> toNameList, ArrayList<String> ccEmailList,
			ArrayList<String> ccNameList, ArrayList<String> bccEmailList,
			ArrayList<String> bccNameList) {

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "";

		boolean email_success = false;
		StringBuilder email_log = new StringBuilder();
		String recipient_email_addr = "";
		String recipient_name = "";

		final String username = getParamByName("JAVAX_EMAIL_USERNAME");
		final String password = decode(getParamByName("JAVAX_EMAIL_PASSWORD"));

		Properties props = System.getProperties();
		String props_str = getParamByName("JAVAX_EMAIL_PROPERTIES");
		if (props_str.length() == 0) {
			mylog(LOG_LEVEL_ERROR, "JAVAX_EMAIL_PROPERTIES is empty ");
			email_log.append("JAVAX_EMAIL_PROPERTIES is empty \n");
		} else {
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
					email_log.append("\nSetting Javax Email Property : " + par
							+ "=" + val);
					props.put(par, val);
				}

			}

		}

		email_log.append("\nproperties was set... ");

		Session session = null;

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
			email_log.append("\nNot authenticated. : " + auth_err_msg);
			props = null;
		} else
			email_log.append("\nauthenticated... ");

		Message msg = new MimeMessage(session);

		try {

			boolean is_html = false;
			if (body.indexOf("</") > -1 && body.indexOf("<") > -1
					&& body.indexOf(">") > -1)
				is_html = true;
			if (is_html)
				msg.setContent(body.toString(), "text/html; charset=utf-8");
			else
				msg.setText(body.toString());

			msg.setFrom(new InternetAddress(fromEmail, nvl(fromName, fromEmail)));

			// TO recipients
			for (int r = 0; r < toEmailList.size(); r++) {
				String rec_address = toEmailList.get(r);
				String rec_name = toEmailList.get(r);

				if (recipient_email_addr.length() > 0) {
					recipient_email_addr = recipient_email_addr + ";";
					recipient_name = recipient_name + ";";
				}

				recipient_email_addr = recipient_email_addr + rec_address;
				recipient_name = recipient_name + rec_name;

				msg.addRecipients(Message.RecipientType.TO,
						InternetAddress.parse(rec_address, false));

			}

			// CC recipients
			for (int r = 0; r < ccEmailList.size(); r++) {
				String rec_address = ccEmailList.get(r);
				String rec_name = ccEmailList.get(r);

				if (recipient_email_addr.length() > 0) {
					recipient_email_addr = recipient_email_addr + ";";
					recipient_name = recipient_name + ";";
				}

				recipient_email_addr = recipient_email_addr + rec_address;
				recipient_name = recipient_name + rec_name;

				msg.addRecipients(Message.RecipientType.CC,
						InternetAddress.parse(rec_address, false));

			}

			// BCC recipients
			for (int r = 0; r < bccEmailList.size(); r++) {
				String rec_address = bccEmailList.get(r);
				String rec_name = bccEmailList.get(r);

				if (recipient_email_addr.length() > 0) {
					recipient_email_addr = recipient_email_addr + ";";
					recipient_name = recipient_name + ";";
				}

				recipient_email_addr = recipient_email_addr + rec_address;
				recipient_name = recipient_name + rec_name;

				msg.addRecipients(Message.RecipientType.BCC,
						InternetAddress.parse(rec_address, false));

			}

			msg.setSubject(subject);
			msg.setSentDate(new Date());

			// last minute check for duplicate notification
			sql = "select notification_sent from mad_request_flow_logs where id=?";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", request_flow_log_id });
			String notification_sent = "YES";
			try {
				notification_sent = getDbArrayConf(sql, 1, bindlist).get(0)[0];
			} catch (Exception e) {
			}

			if (notification_sent.equals("YES"))
				return;

			email_log.append("\nmessage is ready to send. transporting... ");

			Transport.send(msg);

			email_log.append("\nmail was sent successfully to : "
					+ recipient_email_addr);

			email_success = true;

		} catch (Exception e) {
			email_log.append("\nException@sendmail : " + e.getMessage());
			e.printStackTrace();
		} finally {
			props = null;
			msg = null;
		}

		String send_status = "YES";
		if (!email_success)
			send_status = "NO";

		mylog(LOG_LEVEL_DEBUG, email_log.toString());

		// Log Email

		sql = "insert into mad_request_notification_log ( "
				+ " request_flow_log_id, request_id, send_status, "
				+ " send_date, from_email_addr, from_name, "
				+ " to_email_addr, to_name, " + " email_subject, email_body, "
				+ " trans_logs, entuser, entdate " + " )" + " values ("
				+ "?, ?, ?, " + "now() , ?, ?, " + "?, ?, " + "?, ?, "
				+ "?, 0 , now() " + ")";

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", request_flow_log_id });
		bindlist.add(new String[] { "INTEGER", request_id });
		bindlist.add(new String[] { "STRING", send_status });
		bindlist.add(new String[] { "STRING", fromEmail });
		bindlist.add(new String[] { "STRING", fromName });
		bindlist.add(new String[] { "STRING", recipient_email_addr });
		bindlist.add(new String[] { "STRING", recipient_name });
		bindlist.add(new String[] { "STRING", subject });
		bindlist.add(new String[] { "STRING", body.toString() });
		bindlist.add(new String[] { "STRING", email_log.toString() });

		execDBBindingConf(sql, bindlist);

		sql = "update mad_request_flow_logs set notification_sent=? where id=?";
		bindlist.clear();
		bindlist.add(new String[] { "STRING", send_status });
		bindlist.add(new String[] { "INTEGER", request_flow_log_id });
		execDBBindingConf(sql, bindlist);

	}

	// *********************************************************************************

	ArrayList<String> dupCheckGroupList = new ArrayList<String>();

	public ArrayList<String[]> getGroupEmailInfoList(String group_id, int level) {
		ArrayList<String[]> ret1 = new ArrayList<String[]>();
		String sql = "";

		if (level == 1)
			dupCheckGroupList.clear();

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		sql = "select group_name, common_email_address from mad_group where id=?";
		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", group_id });
		ArrayList<String[]> arr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		if (arr.size() == 0) {
			mylog(LOG_LEVEL_WARNING, "Group not found with group id : "
					+ group_id);
			return ret1;
		}

		String group_name = arr.get(0)[0];
		String common_email_address = arr.get(0)[1];

		if (common_email_address.contains("@")
				&& common_email_address.contains(".")) {
			ret1.add(new String[] { common_email_address, group_name });
			return ret1;
		}

		sql = "select member_id, member_type from mad_group_members where group_id=?";

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", group_id });

		arr = getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);

		for (int i = 0; i < arr.size(); i++) {
			String group_member_id = arr.get(i)[0];
			String group_member_type = arr.get(i)[1];

			if (dupCheckGroupList.contains(group_member_type + "_"
					+ group_member_id))
				continue;

			dupCheckGroupList.add(group_member_type + "_" + group_member_id);

			if (group_member_type.equals("USER")) {
				sql = "select email, concat(fname, ' ', lname) from tdm_user where id=?";
				bindlist.clear();
				bindlist.add(new String[] { "INTEGER", group_member_id });
				ArrayList<String[]> user = getDbArrayConf(sql, 1, bindlist);

				if (user.size() == 1) {
					ret1.add(new String[] { user.get(0)[0], user.get(0)[1] });
				} else {
					mylog(LOG_LEVEL_WARNING,
							"user info not found for user id : "
									+ group_member_id);
				}

				continue;
			}

			ArrayList<String[]> subGrpInfo = getGroupEmailInfoList(
					group_member_id, level + 1);

			ret1.addAll(subGrpInfo);
		}

		return ret1;
	}

	// *****************************************************
	public void runScriptPREPPOST() {
		// *****************************************************

		if (System.currentTimeMillis() < next_script_runner_ts)
			return;
		next_script_runner_ts = System.currentTimeMillis()
				+ NEXT_SCRIPT_RUNNER_INTERVAL;

		String sql = "";

		if (!amITheFirstMaster())
			return;

		setMasterStatus("BUSY");

		sql = "select wp.id, wp.status, a.prep_script, a.post_script "
				+ " from tdm_work_plan wp left join tdm_apps a on wp.app_id=a.id "
				+ " where wp.status in ('PREPARATION','COMPLETED') "
				+ " order by wp.id";

		ArrayList<String[]> scriptArr = new ArrayList<String[]>();
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		scriptArr = getDbArrayConf(sql, 1);

		if (scriptArr.size() > 0) {

			int script_work_plan_id = Integer.parseInt(scriptArr.get(0)[0]);
			String status = scriptArr.get(0)[1];
			String script = "";

			if (status.equals("PREPARATION")) {
				script = scriptArr.get(0)[2];
				sql = "select schema_name, tab_name from tdm_tabs where mask_level in ('DELETE')  and app_id in (select app_id from tdm_work_plan where id="
						+ script_work_plan_id + ")";

				ArrayList<String[]> delArr = getDbArrayConf(sql,
						Integer.MAX_VALUE);

				if (delArr != null)
					for (int i = 0; i < delArr.size(); i++) {
						String schema_name = delArr.get(i)[0];
						String table_name = delArr.get(i)[1];
						sql = "truncate table "
								+ addStartEndForTable(schema_name + "."
										+ table_name);

						script = script + sql;
						script = script + "\n/\n\n";
					}
			} else {
				script = scriptArr.get(0)[3];
				sql = "select post_script from tdm_work_plan where id=?";
				String wp_post_script = "";
				try {
					wp_post_script = getDbArrayConfInt(sql, 1, script_work_plan_id)
							.get(0)[0];
				} catch (Exception e) {
				}
				if (wp_post_script.length() > 10)
					script = script + "\n\n/\n\n" + wp_post_script;
			}

			// ---------- START SCRIPT RUNNING

			String[] lines = script.split("\n|\r");
			String a_line = "";
			String a_script = "";
			String logger = "";

			loadRunParams(script_work_plan_id);

			if (!is_mongo && !WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_AUTO)
					&& !WORK_PLAN_TYPE.equals(WORK_PLAN_TYPE_DEPL)) {

				mylog(LOG_LEVEL_INFO, "Script : " + script);
				mylog(LOG_LEVEL_INFO, "Size : " + lines.length);

				if (appdb_test_connection_need || connApp == null) {
					connApp = getconn(app_connstr, app_driver, app_username,app_password);
					if (!testconn(connApp)) {
						closeApp();
						return;
					}
					try {
						connApp.setAutoCommit(false);
					} catch (SQLException e) {
					}
				}

				closeApp();
				connApp = null;
				Statement stmt = null;

				sql = "update tdm_work_plan set status='" + status	+ "-EXECUTING' where id=" + script_work_plan_id;
				execDBBindingConf(sql, bindlist);

				for (int i = 0; i < lines.length; i++) {

					a_line = "" + lines[i];
					mylog(LOG_LEVEL_INFO, a_line);

					if (a_line.trim().equals("/")) {

						// -----------------------------
						// establish and test the connection if needed
						if (connApp == null) {

							connApp = getconn(app_connstr, app_driver, app_username, app_password);
							if (!testconn(connApp)) {
								closeApp();
								break;
							}

							try {
								connApp.setAutoCommit(false);
							} catch (SQLException e) {
							}
							try {
								stmt = connApp.createStatement();
								stmt.setQueryTimeout(3 * 60 * 60);
							} catch (SQLException e) {
								e.printStackTrace();
							}

							// appdb_test_connection_need=false;
						}

						mylog(LOG_LEVEL_INFO,
								"--------------------------------------------\n");
						mylog(LOG_LEVEL_INFO, a_script + "\n");

						logger = logger
								+ "\n--------------------------------------------\n";
						logger = logger + a_script + "\n";

						try {
							if (getCancelFlag("tdm_master")) {
								mylog(LOG_LEVEL_WARNING,
										"Master is cancelled...");
								break;
							}

							sql = "update tdm_master set last_heartbeat=DATE_ADD(NOW(), INTERVAL 2 HOUR) where id="
									+ master_id;
							execDBConf(sql);

							long start_ts = System.currentTimeMillis();
							stmt.execute(a_script);

							closeApp();
							connApp = null;

							mylog(LOG_LEVEL_INFO,
									"\nExecuted Successfully. Duration : "
											+ (System.currentTimeMillis() - start_ts)
											+ " msecs ");

							logger = logger
									+ "\nExecuted Successfully. Duration : "
									+ (System.currentTimeMillis() - start_ts)
									+ " msecs ";

						} catch (Exception e) {
							mylog(LOG_LEVEL_ERROR,
									"\n\nException@runScriptRunner : "
											+ e.getMessage());

							logger = logger + "\nException@runScriptRunner : "
									+ e.getMessage();

							e.printStackTrace();

							closeApp();
							connApp = null;

						}

						a_script = "";
						// -----------------------------

					} else {
						a_script = a_script + a_line + "\n";
					}

					if (getCancelFlag("tdm_master")) {
						mylog(LOG_LEVEL_WARNING, "Master is cancelled...");
						break;
					}
				}
			} // if (!WORK_PLAN_TYPE.equals("AUTOMATION"))

			bindlist.clear();
			
			if (status.equals("PREPARATION")) {
				status = "RUNNING";				
				sql = "update tdm_work_plan set status='" + status	+ "' where id=" + script_work_plan_id;
				execDBBindingConf(sql, bindlist);
			}			
			
			if (status.equals("COMPLETED")) {
				status = "FINISHED";
				sql = "update tdm_work_plan set status='" + status
						+ "', post_script_log=?, end_date=now() where id="
						+ script_work_plan_id;
				bindlist.add(new String[] { "STRING", logger });
				execDBBindingConf(sql, bindlist);
			}

			

			// to force mail sending
			sendWorkPlanStatusMail("" + script_work_plan_id, true);

		} // if scriptArr.size()>0

		

		setMasterStatus("FREE");

		next_script_runner_ts = System.currentTimeMillis()
				+ NEXT_SCRIPT_RUNNER_INTERVAL;
	}

	// **********************************************************************
	public void resumeTasksByWorkerId(int p_worker_id) {

		String work_plan_filter = "status in ('RUNNING','CANCELLED') ";
		String work_package_filter = "";
		String task_filter = "worker_id=" + p_worker_id
				+ " and status in ('ASSIGNED','RUNNING')";
		String update_set_clause = "status='NEW', worker_id=null, start_date=null, end_date=null, "
				+ " duration=null, success_count=0, fail_count=0, done_count=0,"
				+ " log_info_zipped=null, err_info_zipped=null,  retry_count=0";

		updateTask(work_plan_filter, work_package_filter, task_filter,
				update_set_clause);

		String sql = "delete from tdm_task_assignment where worker_id="
				+ p_worker_id;
		execDBConf(sql);
	}

	// **********************************************************************
	public void updateTask(String work_plan_filter, String work_package_filter,
			String task_filter, String update_set_clause) {
		String sql = "select id from tdm_work_plan";
		if (work_plan_filter.length() > 0)
			sql = sql + " where " + work_plan_filter;
		ArrayList<String[]> wplArr = getDbArrayConf(sql, Integer.MAX_VALUE);

		for (int i = 0; i < wplArr.size(); i++) {
			String work_plan_id = wplArr.get(0)[0];

			sql = "select id from tdm_work_package where work_plan_id="
					+ work_plan_id;
			if (work_package_filter.length() > 0)
				sql = sql + " and  " + work_package_filter;

			ArrayList<String[]> wpcArr = getDbArrayConf(sql, Integer.MAX_VALUE);

			for (int j = 0; j < wpcArr.size(); j++) {
				String work_package_id = wpcArr.get(0)[0];

				sql = "update tdm_task_" + work_plan_id + "_" + work_package_id
						+ " set " + update_set_clause + " where  "
						+ task_filter;

				execDBConf(sql);

			}

		}

	}

	// ***********************************************

	long next_email_report_ts = System.currentTimeMillis();

	public void sendWorkPlanStatusMail(String work_plan_id, boolean force) {

		if (System.currentTimeMillis() < next_email_report_ts && !force)
			return;

		String JAVAX_MAIL_NOTIFICATION_PERIOD = getParamByName("JAVAX_MAIL_NOTIFICATION_PERIOD");
		int per = 10 * 60 * 1000;
		try {
			per = Integer.parseInt(JAVAX_MAIL_NOTIFICATION_PERIOD.trim());
		} catch (Exception e) {
		}

		next_email_report_ts = System.currentTimeMillis() + per;

		String sql = "";
		String from = "info@infobox.com.tr";
		String to = nvl(WORK_PLAN_MAIL_ADDRESS,
				getParamByName("JAVAX_EMAIL_ADDRESS"));

		if (to.trim().length() == 0)
			return;

		StringBuilder sb = new StringBuilder();

		sql = "select work_plan_name, status from tdm_work_plan where wplan_type not in ('DEPL','AUTO') and id="
				+ work_plan_id;
		ArrayList<String[]> arrWp = getDbArrayConf(sql, 1);

		if (arrWp.size() == 0)
			return;

		String subject = "Work Plan report for : " + arrWp.get(0)[0];
		String wp_status = arrWp.get(0)[1];

		sb.append("<div>");

		sb.append("<h4>Status : <font color=blue>" + wp_status + "</font></h4>");

		sb.append("<hr>");

		sb.append("<h3>Work Packages :</h3>");
		sb.append("<table border=0>");

		sql = " select " + " concat(t.tab_name,'@',w.schema_name) tab_name, "
				+ " w.status,  " + " sum(export_count) export_count, "
				+ " sum(done_count) done_count, "
				+ " sum(success_count) success_count, "
				+ " sum(fail_count) fail_count "
				+ " from tdm_work_package w, tdm_tabs t "
				+ " where work_plan_id=" + work_plan_id + " "
				+ " and tab_id=t.id " + " group by  "
				+ " concat(t.tab_name,'@',w.schema_name) , " + " w.status";

		sb.append("<tr bgcolor=#FAFAFA>");
		sb.append("<td><b>Table</b></td>");
		sb.append("<td><b>Status</b></td>");
		sb.append("<td><b>Export#</b></td>");
		sb.append("<td><b>Done Rec#</b></td>");
		sb.append("<td><b>Succes#</b></td>");
		sb.append("<td><b>Failed#</b></td>");
		sb.append("</tr>");

		ArrayList<String[]> taskArr = getDbArrayConf(sql, Integer.MAX_VALUE);

		String color = "white";
		String status = "";
		for (int i = 0; i < taskArr.size(); i++) {
			String[] rec = taskArr.get(i);
			status = rec[1];
			if (status.equals("NEW"))
				color = "white";
			if (status.equals("MASKING"))
				color = "yellow";
			if (status.equals("EXPORTING"))
				color = "yellow";
			if (status.equals("FINISHED"))
				color = "lightgreen";

			sb.append("<tr bgcolor=\"" + color + "\">");
			sb.append("<td><b>" + rec[0] + "</b></td>");
			sb.append("<td><b>" + rec[1] + "</b></td>");
			for (int r = 2; r < rec.length; r++)
				sb.append("<td align=right>" + rec[r] + "</td>");
			sb.append("</tr>");

		}

		sb.append("</table>");

		sb.append("<hr>");

		sb.append("<h3>Tasks :</h3>");
		sb.append("<table border=0>");

		sql = " select status,  " + " sum(task_count) task_count,"
				+ " round(avg(avg_duration)) avg_duration,"
				+ " sum(rec_count) rec_count, "
				+ " sum(done_count) done_count,"
				+ " sum(success_count) success_count,"
				+ " sum(fail_count) fail_count" + " from tdm_task_summary a "
				+ " where work_plan_id=" + work_plan_id
				+ " group by status order by 1 ";

		sb.append("<tr bgcolor=#FAFAFA>");
		sb.append("<td><b>Status</b></td>");
		sb.append("<td><b>Task#</b></td>");
		sb.append("<td><b>Duration</b></td>");
		sb.append("<td><b>Rec#</b></td>");
		sb.append("<td><b>Done Rec#</b></td>");
		sb.append("<td><b>Succes#</b></td>");
		sb.append("<td><b>Failed#</b></td>");
		sb.append("</tr>");

		taskArr = getDbArrayConf(sql, Integer.MAX_VALUE);

		for (int i = 0; i < taskArr.size(); i++) {
			String[] rec = taskArr.get(i);
			status = rec[0];
			if (status.equals("NEW"))
				color = "white";
			if (status.equals("RUNNING"))
				color = "yellow";
			if (status.equals("ASSIGNED"))
				color = "blue";
			if (status.equals("FINISHED"))
				color = "lightgreen";

			sb.append("<tr bgcolor=\"" + color + "\">");
			sb.append("<td><b>" + rec[0] + "</b></td>");
			for (int r = 1; r < rec.length; r++)
				sb.append("<td align=right>" + rec[r] + "</td>");
			sb.append("</tr>");

		}

		sb.append("</table>");

		sb.append("</div>");

		mylog(LOG_LEVEL_INFO, "properties was set... ");

		mylog(LOG_LEVEL_INFO, "message is ready to send. transporting... ");

		boolean is_ok = sendMail(from, to, subject, sb);

		if (is_ok)
			mylog(LOG_LEVEL_INFO, "mail was sent successfully to : " + to);
		else
			mylog(LOG_LEVEL_ERROR, "mail sending error : " + to);

	}

	Session session = null;

	// ***********************************************************
	void createEmailSession() {

		final String username = getParamByName("JAVAX_EMAIL_USERNAME");
		final String password = decode(getParamByName("JAVAX_EMAIL_PASSWORD"));

		Properties props = System.getProperties();

		String props_str = getParamByName("JAVAX_EMAIL_PROPERTIES");

		if (props_str.length() == 0)
			return;

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
				mylog(LOG_LEVEL_INFO, "Setting Javax Email Property : " + par
						+ "=" + val);
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

			if (session == null)
				mylog(LOG_LEVEL_ERROR, "Not authenticated. : " + auth_err_msg);
			else
				mylog(LOG_LEVEL_INFO, "authenticated... ");

		} catch (Exception e) {
			props = null;
			session = null;
			mylog(LOG_LEVEL_ERROR,
					"Exception@createEmailSession : " + e.getMessage());
			mylog(LOG_LEVEL_ERROR, "Exception@createEmailSession : "
					+ genLib.getStackTraceAsStringBuilder(e).toString());

			e.printStackTrace();
		} finally {
			props = null;
		}

	}

	// ************************************************************
	boolean sendMail(String from, String to, String subject, StringBuilder body) {

		if (session == null)
			createEmailSession();

		if (session == null) {
			mylog(LOG_LEVEL_ERROR, "Email session not successfull.");
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
			mylog(LOG_LEVEL_ERROR, "Exception@sendmail : " + e.getMessage());
			e.printStackTrace();
			return false;
		} finally {

			msg = null;
		}

		return true;
	}

	// *************************************************************
	public void setParamByName(String param_name, String param_value) {
		// *************************************************************
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "delete from tdm_parameters where param_name=?";

		bindlist.add(new String[] { "STRING", param_name });
		execDBBindingConf(sql, bindlist);

		sql = "insert into tdm_parameters (param_name, param_value) values (?,?)";

		bindlist.add(new String[] { "STRING", param_value });
		execDBBindingConf(sql, bindlist);

	}

	// *************************************************************
	public String getParamByName(String param_name) {
		// *************************************************************
		String ret1 = "";
		String sql = "select param_value from tdm_parameters where param_name='"
				+ param_name + "' limit 0,1";

		try {
			ret1 = getDbArrayConf(sql, 1).get(0)[0];
		} catch (Exception e) {
			ret1 = "";
		}

		return ret1;

	}

	// *************************************************************
	public String encrypt(String input) {
		// *************************************************************
		String ret1 = input;
		Cipher ecipher;
		SecretKey key;
		try {
			String theKey = "01234567";
			key = KeyGenerator.getInstance("DES").generateKey();
			key = new SecretKeySpec(theKey.getBytes("UTF-8"), "DES");
			ecipher = Cipher.getInstance("DES");
			ecipher.init(Cipher.ENCRYPT_MODE, key);

			byte[] utf8 = input.getBytes("UTF8");
			byte[] enc = ecipher.doFinal(utf8);
			enc = BASE64EncoderStream.encode(enc);

			// convert to hex
			StringBuilder sb = new StringBuilder();
			for (int i = 0; i < enc.length; i++)
				sb.append(Integer.toString((enc[i] & 0xff) + 0x100, 16)
						.substring(1));

			ret1 = sb.toString();
		} catch (Exception e) {
			e.printStackTrace();
		}

		return ret1;
	}

	// *******************************************************
	public String encode(String a) {

		byte[] bytesEncoded = Base64.encodeBase64URLSafe(a.getBytes());

		return new String(bytesEncoded);
	}

	// *******************************************************
	public String decode(String a) {
		byte[] valueDecoded = Base64.decodeBase64(a);
		return new String(valueDecoded);

	}

	// *******************************************************
	public void createNewTaskTable(int wplan_id, int wpack_id) {
		// create tdm_task table

		String sql = "CREATE TABLE `tdm_task_" + wplan_id + "_" + wpack_id
				+ "` ( " + " `id` int(11) NOT NULL AUTO_INCREMENT, "
				+ " `task_name` varchar(100) DEFAULT 'TASK', "
				+ " `task_order` int(11) DEFAULT 0, "
				+ " `script_id` int(11) DEFAULT 0, "
				+ " `work_plan_id` int(11) DEFAULT NULL, "
				+ " `work_package_id` int(11) DEFAULT NULL, "
				+ " `status` varchar(45) DEFAULT 'NEW', "
				+ " `worker_id` int(11) DEFAULT NULL, "
				//+ " `create_date` datetime DEFAULT CURRENT_TIMESTAMP, "
				+ " `create_date` datetime DEFAULT NULL, "
				+ " `assign_date` datetime DEFAULT NULL, "
				+ " `start_date` datetime DEFAULT NULL, "
				+ " `end_date` datetime DEFAULT NULL, "
				+ " `last_activity_date` datetime DEFAULT NULL, "
				+ " `duration` int(11) DEFAULT NULL, "
				+ " `all_count` int(11) DEFAULT NULL, "
				+ " `success_count` int(11) DEFAULT NULL, "
				+ " `fail_count` int(11) DEFAULT NULL, "
				+ " `done_count` int(11) DEFAULT NULL, "
				+ " `task_info_zipped` mediumblob, "
				+ " `log_info_zipped` mediumblob, "
				+ " `err_info_zipped` mediumblob, "
				+ " `rollback_info_zipped` mediumblob, "
				+ " `retry_count` int(5) DEFAULT 0, " + " PRIMARY KEY (`id`), "
				+ " UNIQUE KEY `id_UNIQUE` (`id`), "
				+ " KEY `task_work_plan_id_ndx` (`work_plan_id`), "
				+ " KEY `task_work_pack_id_ndx` (`work_package_id`), "
				+ " KEY `task_status_ndx` (`status`), "
				+ " KEY `task_worker_id_ndx` (`worker_id`) "
				+ "  ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;	";
		execDBConf(sql);

	}

	// *************************************************************
	public void createNewWorkPackage(int wplan_id, int wpack_id,
			int original_wpack_id, String wp_status, String wp_name,
			String tab_id, String schema_name, String tab_name,
			String mask_level, String tab_filter, String parallel_condition,
			String tab_order_stmt, String base_sql, String config_list) {
		// *************************************************************
		String sql = "";
		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		String execution_order = "1";
		if (EXECUTION_TYPE.equals("SERIAL")) {

			sql = "select max(execution_order) from tdm_work_package where work_plan_id=?";

			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", "" + wplan_id });
			ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);
			if (arr != null && arr.size() == 1)
				try {
					execution_order = ""
							+ (Integer.parseInt(arr.get(0)[0]) + 1);
				} catch (Exception e) {
				}

		}

		sql = "insert into tdm_work_package  "
				+ " (id, wp_name, original_wpack_id, status, work_plan_id, execution_order, tab_id, schema_name, table_name, mask_level,filter_condition, "
				+ " parallel_condition, order_by_stmt, sql_statement, mask_params, last_activity_date) "
				+ " values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, now())";

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", "" + wpack_id });
		bindlist.add(new String[] { "STRING", wp_name });
		bindlist.add(new String[] { "INTEGER", "" + original_wpack_id });
		bindlist.add(new String[] { "STRING", wp_status });
		bindlist.add(new String[] { "INTEGER", "" + wplan_id });
		bindlist.add(new String[] { "INTEGER", execution_order });
		bindlist.add(new String[] { "INTEGER", tab_id });
		bindlist.add(new String[] { "STRING", schema_name });
		bindlist.add(new String[] { "STRING", tab_name });
		bindlist.add(new String[] { "STRING", mask_level });
		bindlist.add(new String[] { "STRING", tab_filter });
		bindlist.add(new String[] { "STRING", parallel_condition });
		bindlist.add(new String[] { "STRING", tab_order_stmt });
		bindlist.add(new String[] { "STRING", base_sql });
		bindlist.add(new String[] { "STRING", config_list });

		execDBBindingConf(sql, bindlist);

	}

	// *************************************************************
	int getNextWorkPlanSeq() {

		String sql = "SELECT AUTO_INCREMENT FROM information_schema.tables WHERE table_name = 'tdm_work_plan' AND table_schema = DATABASE( ) ;";

		try {
			return Integer.parseInt(getDbArrayConf(sql, 1).get(0)[0]);
		} catch (Exception e) {
			e.printStackTrace();
		}

		return -1;

	}

	// *************************************************************
	int last_work_pack_seq_id = -1;

	// *************************************************************
	int getNextWorkPackageSeq() {
		if (last_work_pack_seq_id > 0) {
			last_work_pack_seq_id++;
			return last_work_pack_seq_id;
		}

		String sql = "SELECT AUTO_INCREMENT FROM information_schema.tables WHERE table_name = 'tdm_work_package' AND table_schema = DATABASE( ) ;";

		try {
			return Integer.parseInt(getDbArrayConf(sql, 1).get(0)[0]);
		} catch (Exception e) {
			e.printStackTrace();
		}

		return -1;

	}

	// ******************************************************************
	private boolean isfileexists(String fname) {
		File f = new File(fname);
		if (f.exists())
			return true;
		return false;
	}

	// ******************************************************************
	String LIC_OWNER_COMPANY = "";
	String LIC_OWNER_CONTACT = "";
	String LIC_OWNER_EMAIL = "";
	Date LIC_END = new Date();
	int LIC_WORKER_LIMIT = 0;
	int LIC_MASTER_LIMIT = 0;
	int LIC_DB_LIMIT = 0;

	// ******************************************************************

	public void checkLicence() {

		String curr_host_name = gethostname();
		String curr_serial_no = getserialno();
		String curr_os = System.getProperty("os.name").toLowerCase();

		String working_dir = nvl(getParamByName("TDM_PROCESS_HOME"),
				System.getProperty("user.dir"));
		String file_seperator = System.getProperty("file.separator");

		boolean licence_ok = true;

		String licence_file = working_dir + file_seperator + "licence.lic";
		long licence_checksum = 0;
		long calculated_checksum = 0;

		if (!isfileexists(licence_file)) {
			licence_ok = false;
		} else {
			File licFile = new File(licence_file);
			try {
				BufferedReader reader = new BufferedReader(
						new InputStreamReader(new FileInputStream(licFile),
								"UTF8"));
				String line = "";
				while ((line = reader.readLine()) != null) {
					if (line.trim().length() > 0) {
						String licence = uncompress(hexStringToByteArray(line
								.trim()));

						String[] lines = licence.split("\n");
						for (int i = 0; i < lines.length; i++) {
							String a_line = lines[i];
							if (a_line.contains("=")) {
								String key = a_line.split("=")[0];
								String val = a_line.split("=")[1];
								// mylog(key+"="+val);

								if (key.equals("HOSTNAME")
										&& !val.equals(curr_host_name)) {
									licence_ok = false;
								}
								if (key.equals("SERIAL")
										&& !val.equals(curr_serial_no)) {
									licence_ok = false;
								}
								if (key.equals("OS") && !val.equals(curr_os)) {
									licence_ok = false;
								}

								if (!licence_ok) {
									mylog(LOG_LEVEL_DEBUG,
											"licence break for key " + key
													+ " " + val + "."
													+ curr_host_name);
									break;
								}

								if (key.equals("OWNER_COMPANY"))
									LIC_OWNER_COMPANY = val;
								if (key.equals("OWNER_CONTACT"))
									LIC_OWNER_CONTACT = val;
								if (key.equals("OWNER_EMAIL"))
									LIC_OWNER_EMAIL = val;

								if (key.equals("END_DATE")) {
									Date b = new Date();
									try {
										SimpleDateFormat df = new SimpleDateFormat(
												"dd/MM/yyyy");
										b = df.parse(val);
									} catch (Exception e) {
										e.printStackTrace();
									}
									;
									LIC_END = b;
								}

								if (key.equals("WORKER"))
									LIC_WORKER_LIMIT = Integer.parseInt(val);
								if (key.equals("MASTER"))
									LIC_MASTER_LIMIT = Integer.parseInt(val);
								if (key.equals("DB"))
									LIC_DB_LIMIT = Integer.parseInt(val);
								if (key.equals("CHECKSUM")) {
									mylog(LOG_LEVEL_DEBUG, "CHECKSUM .... : "
											+ val);
									licence_checksum = Long.parseLong(val);
								}

								if (!key.equals("CHECKSUM"))
									calculated_checksum += val.hashCode();

								if (!"HOSTNAME,SERIAL,OS,CHECKSUM"
										.contains(key))
									setParamByName("LICENCE_" + key, val);

							} // if (a_line.contains("="))
						} // for
					}

				} // while
				reader.close();
			} catch (Exception e) {
				e.printStackTrace();
			}

			if (licence_checksum != calculated_checksum
					|| calculated_checksum == 0 || licence_checksum == 0) {
				licence_ok = false;
			}

			if (LIC_END.before(new Date())) {
				licence_ok = false;
			}

		}

		if (!licence_ok) {

			execDBConf("delete from tdm_parameters where param_name like 'LICENCE_%'");

			String licence_info_file = working_dir + file_seperator
					+ "licence.info";
			// if (!isfileexists(licence_info_file)) {

			String licence_info = "";

			licence_info = licence_info + "HOSTNAME=" + curr_host_name + "\n";
			licence_info = licence_info + "SERIAL=" + curr_serial_no + "\n";
			licence_info = licence_info + "OS="
					+ System.getProperty("os.name").toLowerCase() + "\n";
			licence_info = encode(licence_info);

			text2file(licence_info, licence_info_file);

			// } //if (!isfileexists(licence_info_file))

			mylog(LOG_LEVEL_ERROR, "/////////////////////////////////////");
			mylog(LOG_LEVEL_ERROR, "_____________________________________");
			mylog(LOG_LEVEL_ERROR, "-------------------------------------");
			mylog(LOG_LEVEL_ERROR, "Sorry. No valid licence was found for  ["
					+ curr_host_name + "]");
			mylog(LOG_LEVEL_ERROR, "'licence.info' file was created in path :");
			mylog(LOG_LEVEL_ERROR, "[" + working_dir + "]");
			mylog(LOG_LEVEL_ERROR,
					"Send this file to 'info@infobox.com.tr' to have a valid 'licence.lic' file");
			mylog(LOG_LEVEL_ERROR, "_____________________________________");
			mylog(LOG_LEVEL_ERROR, "-------------------------------------");
			mylog(LOG_LEVEL_ERROR, "/////////////////////////////////////");

			closeAll();
			System.exit(0);

		}

		mylog(LOG_LEVEL_WARNING,
				"/////////////////////////////////////////////////////////////////////");
		mylog(LOG_LEVEL_WARNING,
				"_____________________________________________________________________");
		mylog(LOG_LEVEL_WARNING,
				"---------------------------------------------------------------------");
		mylog(LOG_LEVEL_WARNING, " This product is licenced  :           ");
		mylog(LOG_LEVEL_WARNING, "* Licenced Company  ...............:"
				+ LIC_OWNER_COMPANY);
		mylog(LOG_LEVEL_WARNING, "* Licenced Contact  ...............:"
				+ LIC_OWNER_CONTACT);
		mylog(LOG_LEVEL_WARNING, "* Licenced Email  .................:"
				+ LIC_OWNER_EMAIL);
		mylog(LOG_LEVEL_WARNING, "* Licence Valid To (dd/mm/yyyy)....:"
				+ LIC_END);
		mylog(LOG_LEVEL_WARNING, "* Worker Limit.....................:"
				+ LIC_WORKER_LIMIT);
		mylog(LOG_LEVEL_WARNING, "* Master Limit.....................:"
				+ LIC_MASTER_LIMIT);
		mylog(LOG_LEVEL_WARNING, "* Database Limit...................:"
				+ LIC_DB_LIMIT);
		mylog(LOG_LEVEL_WARNING,
				"_____________________________________________________________________");
		mylog(LOG_LEVEL_WARNING,
				"---------------------------------------------------------------------");
		mylog(LOG_LEVEL_WARNING,
				"/////////////////////////////////////////////////////////////////////");

	}

	// ******************************************
	public String gethostname() {
		String ret1 = "";
		InetAddress addr;
		try {
			addr = InetAddress.getLocalHost();
			ret1 = addr.getHostName();
		} catch (Exception e) {
			ret1 = "unknownHOSTNAME";
		}

		return ret1;
	}

	// ******************************************
	public String getserialno() {

		return "unknownSerialID";

	}

	// ************************************************
	public int heapUsedRate() {
		// ************************************************

		Runtime runtime = Runtime.getRuntime();
		int ret1 = Math.round(100
				* (runtime.totalMemory() - runtime.freeMemory())
				/ runtime.maxMemory());

		runtime = null;

		return ret1;

	}

	// ************************************************
	JDynArray updateJBASEDynArrByVal(JDynArray inarr, String oldval,
			String newval) {
		// ************************************************
		ByteBuffer bf = ByteBuffer.allocate(inarr.getBytes().length * 2);

		int len = 0;
		final byte SPLIT_ATTR = -2;
		final byte SPLIT_VALS = -3;
		final byte SPLIT_SUB_VALS = -4;
		StringBuilder sb = new StringBuilder();
		bf.position(0);

		int attrcount = inarr.getNumberOfAttributes();

		for (int attr = 1; attr <= attrcount; attr++) {

			if (attr > 1) {
				bf.put(SPLIT_ATTR);
				len++;
			}

			for (int vals = 1; vals <= inarr.getNumberOfValues(attr); vals++) {

				if (vals > 1) {
					bf.put(SPLIT_VALS);
					len++;
				}

				for (int sval = 1; sval <= inarr.getNumberOfSubValues(attr,
						vals); sval++) {

					if (sval > 1) {
						bf.put(SPLIT_SUB_VALS);
						len++;
					}

					sb.setLength(0);
					sb.append(inarr.get(attr, vals, sval));

					// KEY cannot be changed
					if (sb.toString().equals(oldval)) {
						sb.setLength(0);
						sb.append(newval);

						if (newval.toCharArray().length != oldval.toCharArray().length)
							ByteBuffer.allocate(bf.capacity()
									+ (newval.toCharArray().length - oldval
											.toCharArray().length));
					}

					len += sb.toString().toCharArray().length;
					bf.put(sb.toString().getBytes());

				} // for sval

			} // for vals

		} // for attr

		ByteBuffer bfret = ByteBuffer.allocate(len);
		for (int i = 0; i < len; i++)
			bfret.put(bf.get(i));

		return new JDynArray(bfret.array());

	}

	// ************************************************
	void connectJBASE() {
		// ************************************************
		if (JBASEconn == null) {
			// JBASEfactory=new DefaultJConnectionFactory();

			// String
			// db_connstr="jdbc:jbase:thin:@localhost:20002?SSL=YES&ABC=X&CDE=Y";
			// String db_connstr="jdbc:jbase:thin:@localhost:20002";
			String db_connstr = app_connstr;

			String hostport = "";

			try {
				hostport = db_connstr.split("\\@")[1].split("\\?")[0];
			} catch (Exception e) {
				hostport = db_connstr.split("\\@")[1];
			}

			String host = "";

			try {
				host = hostport.split(":")[0];
			} catch (Exception e) {
				host = "";
			}

			String port = "";
			try {
				port = hostport.split(":")[1];
			} catch (Exception e) {
				port = "";
			}

			try {

				DefaultJConnectionFactory dcf = new DefaultJConnectionFactory();
				dcf.setHost(host);
				dcf.setPort(Integer.parseInt(port));

				JBASEconn = dcf.getConnection(app_username, app_password);

				mylog(LOG_LEVEL_INFO, "Connection is opened");

			} catch (JRemoteException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}

	}

	// ************************************************
	void disconnectJBASE() {
		// ************************************************
		if (JBASEconn == null)
			return;
		try {
			JBASEconn.close();
			mylog(LOG_LEVEL_INFO, "Connection is closed");
		} catch (Exception e) {
			e.printStackTrace();
		}
		JBASEconn = null;
	}

	// ************************************************
	void disconnectMONGO() {
		// ************************************************
		if (MONGOclient == null)
			return;
		try {
			MONGOclient.close();
			mylog(LOG_LEVEL_INFO, "Connection is closed");
		} catch (Exception e) {
			e.printStackTrace();
		}
		MONGOclient = null;
		is_mongo = false;
	}

	// ************************************************
	String getJbaseFieldsWithComma(String table_name) {
		StringBuilder sb = new StringBuilder();
		ArrayList<String> fields = getJbaseFields(table_name);

		for (int i = 0; i < fields.size(); i++) {
			if (i > 0)
				sb.append(", ");
			sb.append(fields.get(i));
		}

		if (sb.length() == 0)
			sb.append("1");
		return sb.toString();
	}

	// ************************************************
	ArrayList<String> getJbaseFields(String table_name) {
		ArrayList<String> ret1 = new ArrayList<String>();

		String cmd_for_fields_ext = nvl(getParamByName("JBASE_CMD_FIELDS"),
				" WITH (F1 EQ \"D\" OR F1 EQ \"I\") AND F2 NE \"0\" ONLY");

		String cmd_for_fields = "LIST " + table_name + "]D "
				+ cmd_for_fields_ext;

		ret1 = getJbaseCommandRes(cmd_for_fields);
		for (int i = 0; i < ret1.size(); i++) {
			if (ret1.get(i).indexOf(".") > -1)
				ret1.set(i, ret1.get(i).replaceAll("\\.", "_"));
		}

		return ret1;
	}

	// ************************************************
	ArrayList<String> getJbaseTables() {
		ArrayList<String> ret1 = new ArrayList<String>();
		String cmd_for_tabs = nvl(getParamByName("JBASE_CMD_TABLES"),
				"LIST VOC  WITH F1 EQ \"F...\" ONLY");

		ret1 = getJbaseCommandRes(cmd_for_tabs);

		disconnectJBASE();

		return ret1;
	}

	// ************************************************
	ArrayList<String> getJbaseCommandRes(String cmd) {
		ArrayList<String> ret1 = new ArrayList<String>();

		if (JBASEconn == null)
			connectJBASE();
		mylog(LOG_LEVEL_DEBUG, " ******************************** ");
		mylog(LOG_LEVEL_DEBUG, "       getJbaseCommandRes         ");
		mylog(LOG_LEVEL_DEBUG, cmd);
		mylog(LOG_LEVEL_DEBUG, " ******************************** ");

		try {
			JStatement stmt = JBASEconn.createStatement();
			JResultSet res = stmt.execute(cmd);

			while (res.next()) {
				JDynArray row1 = res.getRow();
				for (int i = 1; i <= row1.getNumberOfAttributes(); i++) {
					for (int j = 1; j <= row1.getNumberOfValues(i); j++) {
						for (int t = 1; t <= row1.getNumberOfSubValues(i, j); t++) {
							String a_val = row1.get(i, j, t);
							ret1.add(a_val);
						}
					}
				}
			}

		} catch (JRemoteException e) {
			e.printStackTrace();

		}
		return ret1;
	}

	ArrayList<String[]> jbaseUpdateArr = new ArrayList<String[]>();
	String jbaseUpdateFile = "";

	// ************************************************
	void updateJBASEFile(String filename, String keyid, String oldvalue,
			String newvalue) {
		// ************************************************
		if (jbaseUpdateArr.size() == 0)
			jbaseUpdateFile = filename;
		// mylog("write " + oldvalue+ " [to] " + newvalue);
		jbaseUpdateArr.add(new String[] { keyid, oldvalue, newvalue });
	}

	// ************************************************
	void commmitJBASE() {
		// ************************************************

		if (jbaseUpdateArr.size() == 0) {
			mylog(LOG_LEVEL_WARNING, "nothing to update on Jbase Array");
			return;
		}

		mylog(LOG_LEVEL_DEBUG,
				"Commit size for Jbase :  " + jbaseUpdateArr.size());

		connectJBASE();
		JFile Jfile = null;
		JDynArray JDynarr = null;
		String last_keyid = "";

		try {
			Jfile = JBASEconn.open(jbaseUpdateFile);

			for (int i = 0; i < jbaseUpdateArr.size(); i++) {

				String keyid = jbaseUpdateArr.get(i)[0];
				String oldvalue = jbaseUpdateArr.get(i)[1];
				String newvalue = jbaseUpdateArr.get(i)[2];

				if (!last_keyid.equals(keyid)
						|| i == (jbaseUpdateArr.size() - 1)) {

					if (last_keyid.length() > 0
							|| i == (jbaseUpdateArr.size() - 1)) {
						// mylog("writing key  :  " + last_keyid);
						Jfile.write(last_keyid, JDynarr);
					}

					if (i < (jbaseUpdateArr.size() - 1)) {

						if (Jfile.exists(keyid)) {
							JDynarr = Jfile.read(keyid);
							last_keyid = keyid;
						} else {
							mylog(LOG_LEVEL_WARNING, "Key Not Found  : "
									+ keyid);
							continue;
						}

					}
				}

				if (keyid.length() > 0) {
					// mylog("replace " + oldvalue + " [to] " + newvalue);
					JDynarr = updateJBASEDynArrByVal(JDynarr, oldvalue,
							newvalue);
				}

			}

		} catch (Exception e) {
			mylog(LOG_LEVEL_ERROR, "Exception@updateJBASE : " + e.getMessage());
			e.printStackTrace();
		} finally {
			try {
				Jfile.close();
			} catch (JRemoteException e) {
				e.printStackTrace();
			}

		}

		jbaseUpdateArr.clear();
		disconnectJBASE();

	}

	// ************************************************
	void makeDir(String dir) {

		mylog(LOG_LEVEL_INFO, "Creating directory " + dir);
		File f = new File(dir);
		if (!f.exists())
			try {
				f.mkdir();
			} catch (Exception e) {
				e.printStackTrace();
			}

	}

	// ************************************************
	@SuppressWarnings("rawtypes")
	public ArrayList<String[]> MADBuildDeployApplication(String action,
			String request_id, String deployment_attempt_no,
			String application_id, String environment_id,
			String target_platform_id, String deploy_member_id) {
		// ************************************************
		ArrayList<String[]> ret1 = new ArrayList<String[]>();
		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		ArrayList<String[]> arr = new ArrayList<String[]>();
		ArrayList<String[]> paramList = new ArrayList<String[]>();
		RepoExplorer re = new RepoExplorer();

		String deployment_base_path = getDeploymentBaseDir();

		String deployment_build_path = deployment_base_path + File.separator
				+ request_id + File.separator + deployment_attempt_no;

		makeDir(deployment_base_path);
		makeDir(deployment_build_path);

		String sql = "";

		sql = "select \n" + "	p.id platform_id, \n"
				+ "	p.platform_type_id platform_type_id, \n"
				+ "	platform_name, \n" + "	a.application_name, \n"
				+ "	r.repository_name, \n" + "	r.class_name, \n"
				+ "	r.par_hostname,  \n" + "	r.par_port,  \n"
				+ "	r.par_username,  \n" + "	r.par_password,  \n"
				+ "	r.par_flex_1,  \n" + "	r.par_flex_2,  \n"
				+ "	r.par_flex_3,  \n" + "	app_repo_root,  \n"
				+ "	app_repo_filter,  \n" + "	app_repo_tag_path,  \n"
				+ "	app_repo_tag_filter,  \n" + "	build_driver_id,  \n"
				+ "	deploy_driver_id,  \n" + "	app_repo_script,  \n"
				+ "	version_calculation_script,  \n" + "	export_type,  \n"
				+ "	pre_deploy_method_id,  \n" + "	post_deploy_method_id  \n"
				+ "	from  \n" + "	mad_request_app_env rae,   \n"
				+ "	mad_application a,   \n" + "	mad_platform_env pe,  \n"
				+ "	mad_platform p,  \n" + "	mad_repository r  \n"
				+ "	where rae.application_id=a.id  \n"
				+ "	and a.platform_type_id=p.platform_type_id  \n"
				+ "	and a.repository_id=r.id  \n"
				+ "	and rae.environment_id=pe.environment_id  \n"
				+ "	and pe.platform_id=p.id  \n" + "	and a.id=?  \n"
				+ "   and rae.request_id=?  \n";

		bindlist.add(new String[] { "INTEGER", application_id });
		bindlist.add(new String[] { "INTEGER", request_id });

		if (target_platform_id != null) {
			sql = sql + " and p.id=?  \n";
			bindlist.add(new String[] { "INTEGER", target_platform_id });
		}

		ArrayList<String[]> depList = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		String app_driver_class = "";
		String app_driver_success_keyword = "";

		for (int i = 0; i < depList.size(); i++) {
			String platform_id = depList.get(i)[0];
			String platform_type_id = depList.get(i)[1];
			String platform_name = depList.get(i)[2];
			String application_name = depList.get(i)[3];
			String repository_name = depList.get(i)[4];
			String repo_class_name = depList.get(i)[5];
			String repo_par_hostname = depList.get(i)[6];
			String repo_par_port = depList.get(i)[7];
			String repo_par_username = depList.get(i)[8];
			String repo_par_password = depList.get(i)[9];
			String repo_par_flex_1 = depList.get(i)[10];
			String repo_par_flex_2 = depList.get(i)[11];
			String repo_par_flex_3 = depList.get(i)[12];
			String app_repo_root = depList.get(i)[13];
			String app_repo_filter = depList.get(i)[14];
			String app_repo_tag_path = depList.get(i)[15];
			String app_repo_tag_filter = depList.get(i)[16];
			String app_build_driver_id = depList.get(i)[17];
			String app_deploy_driver_id = depList.get(i)[18];
			String app_repo_script = depList.get(i)[19];
			String version_calculation_script = depList.get(i)[20];
			String export_type = depList.get(i)[21];
			String pre_deploy_method_id = genLib.nvl(depList.get(i)[22], "0");
			String post_deploy_method_id = genLib.nvl(depList.get(i)[23], "0");

			if ((app_build_driver_id.length() == 0 && action.equals("build"))
					|| (app_deploy_driver_id.length() == 0 && action
							.equals("deploy"))) {

				mylog(LOG_LEVEL_ERROR, "Missing driver ");
				ret1.add(new String[] { "false", log_info.toString() });
				return ret1;
			}

			String dirPlatform = deployment_build_path + File.separator
					+ "platform_" + platform_id;
			String dirApplication = dirPlatform + File.separator + "app_"
					+ application_id;
			createDir(dirPlatform);
			createDir(dirApplication);

			mylog(LOG_LEVEL_INFO, "\n\n\nDeploying application ");
			mylog(LOG_LEVEL_INFO, "Application Name \t: " + application_name);
			mylog(LOG_LEVEL_INFO, "Target Platform \t: " + platform_name);
			mylog(LOG_LEVEL_INFO, "Repository \t: " + repository_name + " ["
					+ repo_class_name + "] " + repo_par_hostname);
			mylog(LOG_LEVEL_INFO,
					"-----------------------------------------------------------------------");

			paramList.clear();

			// adding standart parameters
			paramList.add(new String[] { "CURRENT_REQUEST_ID", request_id });
			paramList.add(new String[] { "CURRENT_ENVIRONMENT_ID",
					environment_id });
			paramList.add(new String[] { "CURRENT_PLATFORM_ID", platform_id });
			paramList.add(new String[] { "CURRENT_PLATFORM_TYPE_ID",
					platform_type_id });
			paramList
					.add(new String[] { "CURRENT_PLATFORM_NAME", platform_name });
			paramList.add(new String[] { "CURRENT_APPLICATION_ID",
					application_id });
			paramList.add(new String[] { "CURRENT_APPLICATION_NAME",
					application_name });

			// set repository parameters
			paramList.add(new String[] { "MAD_BASE_DIRECTORY",
					deployment_base_path });
			paramList.add(new String[] { "MAD_BUILD_DIRECTORY",
					deployment_build_path });
			paramList
					.add(new String[] { "MAD_REPOSITORY_NAME", repository_name });
			paramList.add(new String[] { "MAD_REPOSITORY_CLASS_NAME",
					repo_class_name });
			paramList.add(new String[] { "MAD_REPOSITORY_HOSTNAME",
					repo_par_hostname });
			paramList
					.add(new String[] { "MAD_REPOSITORY_PORT", repo_par_port });
			paramList.add(new String[] { "MAD_REPOSITORY_USERNAME",
					repo_par_username });
			paramList.add(new String[] { "MAD_REPOSITORY_PASSWORD",
					repo_par_password });
			paramList
					.add(new String[] { "MAD_REPOSITORY_PAR1", repo_par_flex_1 });
			paramList
					.add(new String[] { "MAD_REPOSITORY_PAR2", repo_par_flex_2 });
			paramList
					.add(new String[] { "MAD_REPOSITORY_PAR3", repo_par_flex_3 });

			// get all flexible fields and put as parameters
			sql = "select flex_field_id, field_value from mad_request_fields where request_id=?";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", request_id });
			arr = getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);
			for (int p = 0; p < arr.size(); p++)
				paramList.add(new String[] { "FLEX_FIELD_" + arr.get(p)[0],
						arr.get(p)[1] });

			// get all platform parameters
			sql = "select distinct " + "	pff.flex_field_id, "
					+ "	pff.field_parameter_name, " + "	ref.field_value "
					+ "	from  " + "	mad_request_env_fields ref, "
					+ "	mad_platform p, "
					+ "	mad_platform_type_flex_fields pff " + "	where  "
					+ "	platform_id=p.id "
					+ "	and pff.platform_type_id=p.platform_type_id "
					+ "	and pff.flex_field_id=ref.flex_field_id "
					+ "	and application_id=0 " + "	and request_id=? "
					+ "	and environment_id=? " + "	and platform_id=?";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", request_id });
			bindlist.add(new String[] { "INTEGER", environment_id });
			bindlist.add(new String[] { "INTEGER", platform_id });

			arr = getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);
			for (int p = 0; p < arr.size(); p++)
				paramList.add(new String[] { arr.get(p)[1], arr.get(p)[2] });

			// get all platform - application parameters
			sql = "select  distinct " + "	ref.flex_field_id, "
					+ "	field_parameter_name, " + "	ref.field_value "
					+ "	from  " + "	mad_request_env_fields ref,  "
					+ "	mad_application_flex_fields aff " + "	where  "
					+ "	ref.application_id=aff.application_id "
					+ "	and ref.flex_field_id=aff.flex_field_id "
					+ "	and ref.application_id>0 " + "	and request_id=? "
					+ "	and environment_id=? " + "	and platform_id=? "
					+ " 	and ref.application_id=? ";

			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", request_id });
			bindlist.add(new String[] { "INTEGER", environment_id });
			bindlist.add(new String[] { "INTEGER", platform_id });
			bindlist.add(new String[] { "INTEGER", application_id });

			arr = getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);
			for (int p = 0; p < arr.size(); p++)
				paramList.add(new String[] { arr.get(p)[1], arr.get(p)[2] });

			// Collect Application Members

			sql = "select "
					+ "	id, member_path, member_name, member_version, member_tag_info  "
					+ "	from  " + "	mad_request_application_member "
					+ "	where request_id=? " + "	and application_id=? "
					+ "	order by member_order ";

			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", request_id });
			bindlist.add(new String[] { "INTEGER", application_id });

			if (deploy_member_id != null) {
				sql = "select "
						+ "	id, member_path, member_name, member_version, member_tag_info  "
						+ "	from  " + "	mad_request_application_member "
						+ "	where request_id=? " + "	and application_id=? "
						+ "   and id=? " + "	order by member_order ";
				bindlist.add(new String[] { "INTEGER", deploy_member_id });
			}

			ArrayList<String[]> itemList = getDbArrayConf(sql,
					Integer.MAX_VALUE, bindlist);
			ArrayList<String[]> memberParams = new ArrayList<String[]>();

			for (int p = 0; p < itemList.size(); p++) {

				memberParams.clear();

				String member_id = itemList.get(p)[0];
				String member_path = itemList.get(p)[1];
				String member_name = itemList.get(p)[2];
				String member_version = itemList.get(p)[3];
				String member_tag_info = itemList.get(p)[4];

				Date d = new Date();
				String curr_date = new SimpleDateFormat("yyyymmdd_HHmm")
						.format(d);

				String dirItem = dirApplication + File.separator + "item_"
						+ member_id + "_" + curr_date;
				dirItem = dirApplication + File.separator + "item_" + member_id;
				createDir(dirItem);
				String project_name = "project";

				try {
					String[] x = member_path.split("/");
					project_name = x[x.length - 2];
					mylog(LOG_LEVEL_INFO, project_name);
				} catch (Exception e) {
					e.printStackTrace();
				}

				String dirProject = dirItem + File.separator + project_name;
				createDir(dirProject);

				memberParams.add(new String[] { "MAD_REQUEST_PROJECT_NAME",
						project_name });
				memberParams.add(new String[] { "MAD_REQUEST_ITEM_DIRECTORY",
						dirItem });
				memberParams.add(new String[] { "MAD_REQUEST_ITEM_PATH",
						member_path });
				memberParams.add(new String[] { "MAD_REQUEST_ITEM_NAME",
						member_name });
				memberParams.add(new String[] { "MAD_REQUEST_ITEM_VERSION",
						member_version });
				memberParams.add(new String[] { "MAD_REQUEST_ITEM_TAG_INFO",
						member_tag_info });

				String export_dir = member_path;
				String export_file = "";

				/*
				 * if
				 * (member_path.lastIndexOf(member_name)+member_name.length()==
				 * member_path.length()) { export_dir=member_path.substring(0,
				 * member_path.lastIndexOf(member_name)-1); }
				 * 
				 * if (export_type.equals("FILE")) { export_file=member_name; }
				 */

				if (export_type.equals("FILE")
						&& member_path.lastIndexOf(member_name)
								+ member_name.length() == member_path.length()) {
					export_dir = member_path.substring(0,
							member_path.lastIndexOf(member_name) - 1);
				}

				if (export_type.equals("FILE")) {
					export_file = member_name;
				} else { // FOLDER
					export_dir = member_path;
					export_file = "";
				}

				if (export_type.equals("FILE")
						&& member_path.lastIndexOf(member_name)
								+ member_name.length() == member_path.length()) {
					export_dir = member_path.substring(0,
							member_path.lastIndexOf(member_name) - 1);
				}

				if (export_type.equals("FILE")) {
					export_file = member_name;
				} else { // FOLDER
					export_dir = member_path;
					export_file = "";
				}

				String converted_export_dir = convertRepositoryPath(
						app_repo_root, app_repo_tag_path, export_dir,
						member_name, member_tag_info, member_version,
						app_repo_script, memberParams);

				String calculated_application_version = calculateApplicationVersion(
						version_calculation_script, memberParams);

				memberParams.add(new String[] {
						"MAD_CALCULATED_APPLICATION_VERSION",
						calculated_application_version });

				mylog(LOG_LEVEL_INFO, "repository_name\t" + repository_name);
				mylog(LOG_LEVEL_INFO, "repo_class_name\t" + repo_class_name);
				mylog(LOG_LEVEL_INFO, "repo_par_hostname\t" + repo_par_hostname);
				mylog(LOG_LEVEL_INFO, "app_repo_root\t" + app_repo_root);
				mylog(LOG_LEVEL_INFO, "app_repo_tag_path\t" + app_repo_tag_path);
				mylog(LOG_LEVEL_INFO, "export_file\t" + export_file);
				mylog(LOG_LEVEL_INFO, "original export_dir\t" + export_dir);
				mylog(LOG_LEVEL_INFO, "converted export_dir\t"
						+ converted_export_dir);
				mylog(LOG_LEVEL_INFO, "member_name\t" + member_name);
				mylog(LOG_LEVEL_INFO, "dirProject\t" + dirProject);
				mylog(LOG_LEVEL_INFO, "action\t [" + action + "]");

				if (action.equals("build")) {

					mylog(LOG_LEVEL_INFO, "Start exportFolder ...");

					StringBuilder repoExportLogs = new StringBuilder();

					re.exportFolder(repo_class_name, repo_par_hostname,
							repo_par_username, repo_par_password,
							converted_export_dir, export_file, member_version,
							dirProject, repoExportLogs);

					mylog(LOG_LEVEL_INFO, repoExportLogs.toString());

				} // if (action.equals("build"))

				memberParams.addAll(paramList);

				sql = "select class_name, success_keyword from mad_driver where id=?";
				bindlist.clear();
				if (action.equals("build"))
					bindlist.add(new String[] { "INTEGER", app_build_driver_id });
				else
					bindlist.add(new String[] { "INTEGER", app_deploy_driver_id });

				app_driver_class = "";
				app_driver_success_keyword = "";

				arr = getDbArrayConf(sql, 1, bindlist);
				if (arr.size() == 1) {
					app_driver_class = arr.get(0)[0];
					app_driver_success_keyword = arr.get(0)[1];
				}

				if (app_driver_class.length() == 0) {
					mylog(LOG_LEVEL_ERROR, "*** Note : Class is empty!...");
					ret1.add(new String[] { "false", log_info.toString() });
					return ret1;

				}

				genLib.printParameters(memberParams);

				if (action.equals("build")) {
					BuildDriver builder = new BuildDriver();
					ret1 = builder.build(app_driver_class, memberParams);
				}

				if (action.equals("deploy")) {

					boolean pre_method_res = true;

					if (!pre_deploy_method_id.equals("0")) {
						pre_method_res = runPrePostMethod(request_id, "PREP",
								pre_deploy_method_id);

					}

					if (pre_method_res) {
						DeployDriver deployer = new DeployDriver();
						ret1 = deployer.deploy(app_driver_class, memberParams);

						if (ret1.size() > 0
								&& !post_deploy_method_id.equals("0")) {
							String[] retArr = ret1.get(0);

							if (retArr[0].equals("true")) {
								boolean post_method_res = runPrePostMethod(
										request_id, "POST",
										post_deploy_method_id);

								if (!post_method_res) {
									retArr[0] = "false";
									retArr[1] = retArr[1] + "\n"
											+ "Post method execution failed.";

									ret1.clear();
									ret1.add(retArr);
								}
							}

						}

					} else {
						ret1.clear();
						ret1.add(new String[] { "false",
								"Preparation method execution failed." });
					}

				} // if (action.equals("deploy"))

			} // for loop in itemList

		} // for loop in depList

		if (ret1.size() > 0) {
			boolean is_expectation_met = true;
			String[] retArr = ret1.get(0);

			if (retArr[0].equals("true")) {
				if (!retArr[1].contains(app_driver_success_keyword))
					is_expectation_met = false;

				// try again with regular expression
				if (!is_expectation_met) {
					String regex = app_driver_success_keyword;
					try {
						Pattern pattern = Pattern.compile(regex,
								Pattern.CASE_INSENSITIVE);
						Matcher matcher = pattern.matcher(retArr[1]);
						if (matcher.find())
							is_expectation_met = true;
					} catch (Exception e) {
						mylog(LOG_LEVEL_ERROR, "Exception@is_expectation_met:"
								+ e.getMessage());
					}

				}

			}

			// merge logs
			log_info.append("\n");
			log_info.append(retArr[1]);

			ret1.set(0, new String[] { retArr[0], log_info.toString() });

			if (!is_expectation_met)
				ret1.set(0, new String[] { "false", log_info.toString() });

		}

		return ret1;

		// Collect application info

	}

	// ****************************************************************
	static final String AB = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	static Random rnd = new Random();

	String generateToken() {
		int len = 20;
		StringBuilder sb = new StringBuilder(len);
		for (int i = 0; i < len; i++)
			sb.append(AB.charAt(rnd.nextInt(AB.length())));
		return sb.toString();
	}

	// ********************************************************
	boolean runPrePostMethod(String request_id, String stage, String method_id) {

		String sql = "";

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		sql = "select method_name from mad_method where id=? ";
		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", method_id });

		ArrayList<String[]> arr = getDbArrayConf(sql, 1, bindlist);

		if (arr == null || arr.size() == 0) {
			mylog(LOG_LEVEL_ERROR, "Method [" + stage + "] with id ["
					+ method_id + "] not found");
			return false;
		}

		String method_name = arr.get(0)[0];
		getDbSingleVal(connConf, sql, bindlist);

		mylog(LOG_LEVEL_INFO, "Running [" + stage + "] method [" + method_id
				+ "] => " + method_name);

		String url = getParamByName("METHOD_RUN_URL");
		if (url.length() == 0) {
			mylog(LOG_LEVEL_ERROR,
					"METHOD_RUN_URL parameter is not defined or null");
			return false;
		}

		sql = "SELECT AUTO_INCREMENT FROM information_schema.tables WHERE table_name = 'mad_method_call_logs' AND table_schema = DATABASE( )";
		bindlist.clear();

		arr = getDbArrayConf(sql, 1, bindlist);

		if (arr == null || arr.size() == 0) {
			mylog(LOG_LEVEL_ERROR,
					"AUTO_INCREMENT of mad_method_call_logs not retrieved.");
			return false;
		}

		String mad_method_call_logs_id = arr.get(0)[0];
		String token = "" + System.currentTimeMillis() + generateToken();

		sql = "insert into mad_method_call_logs (id, request_id, method_id, token, request_flow_logs_id, flow_state_action_id, status) "
				+ " values (?, ?, ?, ?, 0, 0, 'NEW') ";

		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", mad_method_call_logs_id });
		bindlist.add(new String[] { "INTEGER", request_id });
		bindlist.add(new String[] { "INTEGER", method_id });
		bindlist.add(new String[] { "STRING", token });

		boolean is_ok = execDBBindingConf(sql, bindlist);

		if (!is_ok) {
			mylog(LOG_LEVEL_ERROR, "mad_method_call_logs.");
			return false;
		}

		String thread_name = "METHOD_RUN_THREAD_" + System.currentTimeMillis();
		String params = "id=" + mad_method_call_logs_id + "&token=" + token;
		int timeout = 30 * 60 * 1000;

		try {
			Thread thread = new Thread(methodRunThreadGroup,
					new methodRunThread(url, params, timeout), thread_name);
			thread.run(); // run synchronisedly
		} catch (Exception e) {
			mylog(LOG_LEVEL_ERROR,
					"Exception@methodRunThread : " + e.getMessage());
			mylog(LOG_LEVEL_ERROR, "StackTrace : \n"
					+ genLib.getStackTraceAsStringBuilder(e).toString());
			e.printStackTrace();
		}

		sql = "select execution_result, execution_log from mad_method_call_logs where id=?";
		bindlist.clear();
		bindlist.add(new String[] { "INTEGER", mad_method_call_logs_id });

		arr = getDbArrayConf(sql, 1, bindlist);

		if (arr == null || arr.size() == 0) {
			mylog(LOG_LEVEL_ERROR,
					"method execution results are not retrieved.");
			return false;
		}

		String res = arr.get(0)[0];
		String log = arr.get(0)[1];

		mylog(LOG_LEVEL_INFO, log);

		if (!res.toLowerCase().trim().equals("true"))
			return false;

		return true;

	}

	// ********************************************************
	String calculateApplicationVersion(String version_calculation_script,
			ArrayList<String[]> paramList) {
		String ret1 = "";

		String js_code = version_calculation_script;

		js_code = genLib.replaceAllParams(js_code, paramList);

		ScriptEngineManager factory = null;
		ScriptEngine engine = null;

		try {
			factory = new ScriptEngineManager();
			engine = factory.getEngineByName("JavaScript");
			ret1 = "" + engine.eval(js_code);
		} catch (Exception e) {
			e.printStackTrace();
			ret1 = "";
		}

		return ret1;
	}

	// ********************************************************
	String convertRepositoryPath(String app_repo_path, String app_tag_path,
			String original_member_path, String member_name, String member_tag,
			String member_version, String conversion_script,
			ArrayList<String[]> paramList) {
		String ret1 = original_member_path;

		if (conversion_script.trim().length() == 0)
			return ret1;

		String js_code = conversion_script;

		js_code = js_code.replaceAll("\\$\\{APP_REPO_ROOT\\}", app_repo_path);
		js_code = js_code.replaceAll("\\$\\{APP_TAG_ROOT\\}", app_tag_path);
		js_code = js_code.replaceAll("\\$\\{MEMBER_FULL_PATH\\}",
				original_member_path);
		js_code = js_code.replaceAll("\\$\\{MEMBER_NAME\\}", member_name);
		js_code = js_code.replaceAll("\\$\\{MEMBER_TAG\\}", member_tag);
		js_code = js_code.replaceAll("\\$\\{MEMBER_VERSION\\}", member_version);

		js_code = genLib.replaceAllParams(js_code, paramList);

		ScriptEngineManager factory = null;
		ScriptEngine engine = null;

		try {
			factory = new ScriptEngineManager();
			engine = factory.getEngineByName("JavaScript");
			ret1 = "" + engine.eval(js_code);
		} catch (Exception e) {

			e.printStackTrace();
			ret1 = original_member_path;
		}

		return ret1;
	}

	// ********************************************************
	public Date getNextDayOfWeek(int week_day_id) {
		Calendar chcal = Calendar.getInstance();
		chcal.setTimeInMillis(System.currentTimeMillis());
		Integer[] daynums = new Integer[] { Calendar.MONDAY, Calendar.TUESDAY,
				Calendar.WEDNESDAY, Calendar.THURSDAY, Calendar.FRIDAY,
				Calendar.SATURDAY, Calendar.SUNDAY };

		int target_day = daynums[week_day_id];

		while (true) {
			if (chcal.get(Calendar.DAY_OF_WEEK) == target_day)
				break;
			chcal.add(Calendar.DAY_OF_WEEK, 1);
		}

		return chcal.getTime();

	}

	ThreadGroup methodRunThreadGroup = new ThreadGroup(
			"Method Runner Thread Group");

	// ********************************************************************************************

	long next_check_dm_process_ts = 0;
	static final int CHECK_DM_PROCESS_INTERVAL = 10000;

	void checkDMProcess() {
		if (System.currentTimeMillis() < next_check_dm_process_ts)
			return;
		next_check_dm_process_ts = System.currentTimeMillis()
				+ CHECK_DM_PROCESS_INTERVAL;

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		String sql = "select id, proxy_name, proxy_type, secure_client, secure_public_key, proxy_port, target_host, target_port, proxy_charset, "
				+ " target_app_id, target_env_id, max_package_size, is_debug, extra_args, protocol_configuration_id  "
				+ " from tdm_proxy " + " where status='START' ";

		ArrayList<String[]> arr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		String dm_class_name = "com.mayatech.dm.proxyDriver";

		for (int i = 0; i < arr.size(); i++) {
			String proxy_id = arr.get(i)[0];
			String proxy_name = arr.get(i)[1];
			String proxy_type = arr.get(i)[2];
			String secure_client = arr.get(i)[3];
			String secure_public_key = arr.get(i)[4];
			String proxy_port = arr.get(i)[5];
			String target_host = arr.get(i)[6];
			String target_port = arr.get(i)[7];
			String proxy_charset = arr.get(i)[8];
			String target_app_id = arr.get(i)[9];
			String target_env_id = arr.get(i)[10];
			String max_package_size = arr.get(i)[11];
			String is_debug = arr.get(i)[12];
			String extra_args = arr.get(i)[13];
			String protocol_configuration_id = arr.get(i)[14];

			String protocol_configuration_name = "Default";

			if (protocol_configuration_id.equals("0")) {
				sql = "select protocol_name from tdm_protocol_configuration where id=?";
				bindlist.clear();
				bindlist.add(new String[] { "INTEGER",
						protocol_configuration_id });
				arr = getDbArrayConf(sql, 1, bindlist);

				if (arr != null && arr.size() == 1) {
					protocol_configuration_name = arr.get(0)[0];
				}
			}

			mylog(LOG_LEVEL_INFO, "Starting new proxy  [" + proxy_type + "]: "
					+ proxy_name + " " + proxy_port + "=>" + target_host + ":"
					+ target_port);

			System.out
					.println("----------------------------------------------");
			System.out
					.println("--- STARTING NEW DYNAMIC DATA MASKING PROXY --");
			System.out
					.println("----------------------------------------------");
			System.out.println("proxy_id.................................. : "
					+ proxy_id);
			System.out.println("proxy_type................................ : "
					+ proxy_type);
			System.out.println("secure_client............................. : "
					+ secure_client);
			System.out.println("secure_public_key......................... : "
					+ secure_public_key);
			System.out.println("proxy_port................................ : "
					+ proxy_port);
			System.out.println("target_host............................... : "
					+ target_host);
			System.out.println("target_port............................... : "
					+ target_port);
			System.out.println("proxy_charset............................. : "
					+ proxy_charset);
			System.out.println("target_app_id............................. : "
					+ target_app_id);
			System.out.println("target_env_id............................. : "
					+ target_env_id);
			System.out.println("max_package_size.......................... : "
					+ max_package_size);
			System.out.println("conf_driver............................... : "
					+ conf_driver);
			System.out.println("conf_connstr.............................. : "
					+ conf_connstr);
			System.out.println("conf_username............................. : "
					+ conf_username);
			System.out.println("conf_password............................. : "
					+ "************");
			System.out.println("is_debug.................................. : "
					+ is_debug);
			System.out.println("extra_args................................ : "
					+ extra_args);
			System.out.println("protocol_configuration_id................. : "
					+ protocol_configuration_id + " : "
					+ protocol_configuration_name);
			System.out
					.println("----------------------------------------------");

			ArrayList<String> envParams = new ArrayList<String>();

			envParams.add("DM_PROXY_ID=" + proxy_id);
			envParams.add("DM_PROXY_TYPE=" + proxy_type);
			envParams.add("DM_SECURE_CLIENT=" + secure_client);
			envParams.add("DM_SECURE_PUBLIC_KEY=" + secure_public_key);
			envParams.add("DM_PROXY_PORT=" + proxy_port);
			envParams.add("DM_PROXY_TARGET_HOST=" + target_host);
			envParams.add("DM_PROXY_TARGET_PORT=" + target_port);
			envParams.add("DM_PROXY_CHARSET=" + proxy_charset);
			envParams.add("DM_PROXY_TARGET_APP_ID=" + target_app_id);
			envParams.add("DM_PROXY_TARGET_ENV_ID=" + target_env_id);
			envParams.add("DM_MAX_PACKAGE_SIZE=" + max_package_size);
			envParams.add("DM_PROXY_CONFIG_DB_DRIVER=" + conf_driver);
			envParams.add("DM_PROXY_CONFIG_DB_URL=" + conf_connstr);
			envParams.add("DM_PROXY_CONFIG_DB_USERNAME=" + conf_username);
			envParams.add("DM_PROXY_CONFIG_DB_PASSWORD=" + conf_password);
			envParams.add("DM_DEBUG=" + is_debug);
			envParams.add("DM_EXTRA_ARGS=" + extra_args);
			envParams.add("DM_PROTOCOL_CONFIGURATION_ID="
					+ protocol_configuration_id);

			startNewProcess(dm_class_name, 1, envParams);

			sql = "update tdm_proxy set status='INITIALIZING', start_date=now() where id=?";

			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", proxy_id });

			execDBBindingConf(sql, bindlist);

		}

		sql = "select id, proxy_name  from tdm_proxy where status='ACTIVE'  and last_heartbeat<date_add(now(), interval -5 minute)";
		bindlist.clear();

		ArrayList<String[]> stalledArr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		for (int i = 0; i < stalledArr.size(); i++) {
			String proxy_id = stalledArr.get(i)[0];
			String proxy_name = stalledArr.get(i)[1];

			System.out
					.println("----------------------------------------------");
			System.out
					.println("---   STALLED PROXY FOUND. INACTIVATING     --");
			System.out
					.println("----------------------------------------------");
			System.out.println("proxy_id.................................. : "
					+ proxy_id);
			System.out.println("proxy_name................................ : "
					+ proxy_name);
			System.out
					.println("----------------------------------------------");

			sql = "update tdm_proxy set status='INACTIVE' where id=? ";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", proxy_id });

			execDBBindingConf(sql, bindlist);
		}

	}

	// ********************************************************************************************

	long next_check_datapool_process_ts = 0;
	static final int CHECK_DATAPOOL_PROCESS_INTERVAL = 10000;

	void checkDataPoolProcess() {
		if (System.currentTimeMillis() < next_check_datapool_process_ts)
			return;
		next_check_datapool_process_ts = System.currentTimeMillis()
				+ CHECK_DATAPOOL_PROCESS_INTERVAL;

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		String sql = "select id, app_id, target_id, target_pool_size, is_debug, paralellism_count from tdm_pool_instance  where status='START' ";

		ArrayList<String[]> arr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		String dm_class_name = "com.mayatech.datapool.poolDriver";

		for (int i = 0; i < arr.size(); i++) {
			String data_pool_instance_id = arr.get(i)[0];
			String app_id = arr.get(i)[1];
			String target_id = arr.get(i)[2];
			String target_pool_size = arr.get(i)[3];
			String is_debug = arr.get(i)[4];
			String paralellism_count = arr.get(i)[5];

			mylog(LOG_LEVEL_INFO, "Starting new data pool  ["
					+ data_pool_instance_id + "]: " + app_id + " " + target_id);

			System.out
					.println("----------------------------------------------");
			System.out.println("--- STARTING NEW DATA POOL INSTANCE --");
			System.out
					.println("----------------------------------------------");
			System.out.println("Instance id............................... : "
					+ data_pool_instance_id);
			System.out.println("app_id.................................... : "
					+ app_id);
			System.out.println("target_id................................. : "
					+ target_id);
			System.out.println("target_pool_size.......................... : "
					+ target_pool_size);
			System.out.println("is_debug.................................. : "
					+ is_debug);
			System.out.println("paralellism_count......................... : "
					+ paralellism_count);
			System.out.println("conf_driver............................... : "
					+ conf_driver);
			System.out.println("conf_connstr.............................. : "
					+ conf_connstr);
			System.out.println("conf_username............................. : "
					+ conf_username);
			System.out.println("conf_password............................. : "
					+ "************");
			System.out
					.println("----------------------------------------------");

			ArrayList<String> envParams = new ArrayList<String>();

			envParams.add("DATA_POOL_INSTANCE_ID=" + data_pool_instance_id);
			envParams.add("DATA_APP_ID=" + app_id);
			envParams.add("DATA_TARGET_ID=" + target_id);
			envParams.add("DATA_TARGET_POOL_SIZE=" + target_pool_size);
			envParams.add("DATA_TARGET_IS_DEBUG=" + is_debug);
			envParams.add("DATA_TARGET_PARALELLISM_COUNT=" + paralellism_count);
			envParams.add("DATA_TARGET_POOL_SIZE=" + target_pool_size);
			envParams.add("DM_PROXY_CONFIG_DB_DRIVER=" + conf_driver);
			envParams.add("DM_PROXY_CONFIG_DB_URL=" + conf_connstr);
			envParams.add("DM_PROXY_CONFIG_DB_USERNAME=" + conf_username);
			envParams.add("DM_PROXY_CONFIG_DB_PASSWORD=" + conf_password);

			startNewProcess(dm_class_name, 1, envParams);

			sql = "update tdm_pool_instance set status='INITIALIZING', start_date=now() where id=?";

			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", data_pool_instance_id });

			execDBBindingConf(sql, bindlist);

		}

		sql = "select id  from tdm_pool_instance where status in('ACTIVE','INITIALIZING','REFRESH')  and last_check_date<date_add(now(), interval -5 minute)";
		bindlist.clear();

		ArrayList<String[]> stalledArr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		for (int i = 0; i < stalledArr.size(); i++) {
			String id = stalledArr.get(i)[0];

			System.out
					.println("----------------------------------------------");
			System.out
					.println("---   STALLED DATA POOL FOUND. INACTIVATING --");
			System.out
					.println("----------------------------------------------");
			System.out
					.println("instance_id.................................. : "
							+ id);
			System.out
					.println("----------------------------------------------");

			sql = "update tdm_pool_instance set status='INACTIVE' where id=? ";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", id });

			execDBBindingConf(sql, bindlist);
		}

	}

	// ********************************************************************************************

	long next_check_mask_discovery_process_ts = 0;
	static final int CHECK_MASKDISC_PROCESS_INTERVAL = 10000;

	void checkMaskDiscoveryProcess() {
		if (System.currentTimeMillis() < next_check_mask_discovery_process_ts)
			return;
		next_check_mask_discovery_process_ts = System.currentTimeMillis()
				+ CHECK_MASKDISC_PROCESS_INTERVAL;

		ArrayList<String[]> bindlist = new ArrayList<String[]>();

		String sql = "select id,discovery_title  from tdm_discovery  where status='NEW' ";

		ArrayList<String[]> arr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		String process_class_name = "com.mayatech.maskdisc.maskDiscDriver";

		for (int i = 0; i < arr.size(); i++) {
			String discovery_id = arr.get(i)[0];
			String discovery_title = arr.get(i)[1];

			mylog(LOG_LEVEL_INFO, "Starting Mask Discovery  [" + discovery_id
					+ "]: " + discovery_title);

			System.out
					.println("----------------------------------------------");
			System.out.println("--- STARTING NEW MASKIN DISCOVERY INSTANCE --");
			System.out
					.println("----------------------------------------------");
			System.out.println("Discovery id.............................. : "
					+ discovery_id);
			System.out.println("discovery_title........................... : "
					+ discovery_title);
			System.out.println("conf_driver............................... : "
					+ conf_driver);
			System.out.println("conf_connstr.............................. : "
					+ conf_connstr);
			System.out.println("conf_username............................. : "
					+ conf_username);
			System.out.println("conf_password............................. : "
					+ "************");
			System.out
					.println("----------------------------------------------");

			ArrayList<String> envParams = new ArrayList<String>();

			envParams.add("DISCOVERY_ID=" + discovery_id);
			envParams.add("CONFIG_DB_DRIVER=" + conf_driver);
			envParams.add("CONFIG_DB_URL=" + conf_connstr);
			envParams.add("CONFIG_DB_USERNAME=" + conf_username);
			envParams.add("CONFIG_DB_PASSWORD=" + conf_password);

			startNewProcess(process_class_name, 1, envParams);

			sql = "update tdm_discovery set status='INITIALIZING', start_date=now(), heartbeat=now() where id=?";

			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", discovery_id });

			execDBBindingConf(sql, bindlist);

		}

		sql = "select id  from tdm_discovery where status in('RUNNING','INITIALIZING')  and heartbeat<date_add(now(), interval -5 minute)";
		bindlist.clear();

		ArrayList<String[]> stalledArr = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);

		for (int i = 0; i < stalledArr.size(); i++) {
			String id = stalledArr.get(i)[0];

			System.out
					.println("----------------------------------------------");
			System.out
					.println("---   STALLED MASKING DISCOVERY FOUND. KILLED --");
			System.out
					.println("----------------------------------------------");
			System.out.println("id.................................. : " + id);
			System.out
					.println("----------------------------------------------");

			sql = "update tdm_discovery set status='KILLED' where id=? ";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", id });

			execDBBindingConf(sql, bindlist);
		}

	}

	// ********************************************************************************************
	void runActionMethods() {

		if (System.currentTimeMillis() < next_run_action_method_ts)
			return;
		next_run_action_method_ts = System.currentTimeMillis()
				+ NEXT_RUN_ACTION_METHOD_INTERVAL;

		int active_thread_count = methodRunThreadGroup.activeCount();

		if (active_thread_count > 0)
			return;

		// String url="http://localhost:9090/mayapp-deployment/runMethod.jsp";
		String url = getParamByName("METHOD_RUN_URL");
		if (url.length() == 0) {
			mylog(LOG_LEVEL_ERROR,
					"METHOD_RUN_URL parameter is not defined or null");
			return;
		}

		int max_rec = 100;
		int timeout = 60 * 1000;

		int MAX_THREAD = 10;

		String sql = "select cl.id, cl.token \n"
				+ "	from mad_method_call_logs cl, mad_flow_state_action_methods am \n"
				+ "	where cl.status not in ('FINISHED') \n"
				+ "	and action_method_id=am.id \n"
				+ "	and cl.attempt_no<am.retry_count+1 \n" + "	order by 1 desc";

		ArrayList<String[]> arr = getDbArrayConf(sql, max_rec);

		for (int i = 0; i < arr.size(); i++) {

			String id = arr.get(i)[0];
			String token = arr.get(i)[1];

			String params = "id=" + id + "&token=" + token;

			mylog(LOG_LEVEL_INFO, "Running ASYNCH method (" + params + ")...");

			String thread_name = "METHOD_RUN_THREAD_"
					+ System.currentTimeMillis();

			try {
				Thread thread = new Thread(methodRunThreadGroup,
						new methodRunThread(url, params, timeout), thread_name);
				thread.start();
				Thread.sleep(100);
			} catch (Exception e) {
				mylog(LOG_LEVEL_ERROR,
						"Exception@methodRunThread : " + e.getMessage());
				mylog(LOG_LEVEL_ERROR, "StackTrace : \n"
						+ genLib.getStackTraceAsStringBuilder(e).toString());
				e.printStackTrace();
			}

			active_thread_count = methodRunThreadGroup.activeCount();

			if (active_thread_count >= MAX_THREAD) {
				int x = 0;

				while (true) {

					mylog(LOG_LEVEL_ERROR, "Max Method Runner Thread ["
							+ MAX_THREAD + "] reached. Waiting... ");
					try {
						Thread.sleep(1000);
					} catch (Exception e) {
					}
					x++;
					active_thread_count = methodRunThreadGroup.activeCount();
					if (active_thread_count < MAX_THREAD)
						break;
					if (x > 120)
						break;
				}

				if (x > 120)
					break;
			}

		}

	}

	// ********************************************************************************************
	void createMadDeploymentMainWorkPlan() {
		if (System.currentTimeMillis() < next_create_mad_deployment_work_plans_ts)
			return;

		ArrayList<String[]> bindlist = new ArrayList<String[]>();
		String sql = "";

		sql = "select distinct r.id request_id, rae.environment_id, \n"
				+ "   e.on_error_action, e.environment_name, r.deployment_attempt_no, \n"
				+ "   DATE_FORMAT(deployment_date,'%d.%m.%Y %H:%i:%s') deployment_time"
				+ "	from  \n"
				+ "	  mad_request r , mad_request_type rt, mad_flow_state fs, \n"
				+ " 	  mad_request_app_env rae, mad_environment e \n"
				+ "	where r.request_type_id=rt.id \n"
				+ "	  and rt.flow_id=fs.flow_id and state_name=r.status and state_stage='DEPLOY' \n"
				+ "	  and r.id=rae.request_id and rae.environment_id=e.id  \n"
				+
				// "	  and r.deployment_date>=DATE_SUB(now(),INTERVAL 300 SECOND) \n"
				// +
				"	  and not exists (select 1 from mad_request_work_plan rwp where rwp.request_id=r.id and rwp.deployment_attempt_no=r.deployment_attempt_no) \n"
				+ "   order by environment_id, deployment_date, r.deployment_attempt_no, r.id ";

		ArrayList<String[]> arrReq = getDbArrayConf(sql, Integer.MAX_VALUE,
				bindlist);
		String current_environment_id = "";

		int current_work_plan_id = -1;
		String current_deployment_date = "";

		for (int i = 0; i < arrReq.size(); i++) {
			String request_id = arrReq.get(i)[0];
			String environment_id = arrReq.get(i)[1];
			String on_error_action = arrReq.get(i)[2];
			String environment_name = arrReq.get(i)[3];
			String deployment_attempt_no = arrReq.get(i)[4];
			String deployment_date = arrReq.get(i)[5];

			if (!current_environment_id.equals(environment_id)
					|| !current_deployment_date.equals(deployment_date)) {

				current_environment_id = environment_id;
				current_deployment_date = deployment_date;

				current_work_plan_id = getNextWorkPlanSeq();

				String work_plan_name = "Deployment for environment @"
						+ environment_name + "[" + current_deployment_date
						+ "]";

				mylog(LOG_LEVEL_INFO, "Creating work plan : ["
						+ current_work_plan_id + "] : " + work_plan_name);

				sql = "insert into tdm_work_plan (id, work_plan_name, env_id, app_id, target_env_id, wplan_type,"
						+ " on_error_action, "
						+ "REC_SIZE_PER_TASK, TASK_SIZE_PER_WORKER, BULK_UPDATE_REC_COUNT, "
						+ " COMMIT_LENGTH, UPDATE_WPACK_COUNTS_INTERVAL,RUN_TYPE, target_owner_info, "
						+ " master_limit, worker_limit, "
						+ " start_date) values ( " + "?," + // id
						"?," + // work_plan_name
						"?," + // env_id
						"?," + // app_id
						"?," + // target_env_id
						"?," + // wplan_type
						"?," + // on_error_action
						"?," + // REC_SIZE_PER_TASK
						"?," + // TASK_SIZE_PER_WORKER
						"?," + // BULK_UPDATE_REC_COUNT
						"?," + // COMMIT_LENGTH
						"?," + // UPDATE_WPACK_COUNTS_INTERVAL
						"?," + // run_type
						"?," + // target_owner_info
						"?," + // master_limit
						"?," + // worker_limit
						"STR_TO_DATE(?,'%d.%m.%Y %H:%i:%s')" + // start_time
						") ";

				bindlist.clear();
				bindlist.add(new String[] { "INTEGER",
						"" + current_work_plan_id });
				bindlist.add(new String[] { "STRING", work_plan_name });
				bindlist.add(new String[] { "INTEGER", environment_id });
				bindlist.add(new String[] { "INTEGER", "" + environment_id });
				bindlist.add(new String[] { "INTEGER", "0" });
				bindlist.add(new String[] { "STRING", "DEPL" });
				bindlist.add(new String[] { "STRING", on_error_action });
				bindlist.add(new String[] { "LONG", "1" }); // REC_SIZE_PER_TASK
				bindlist.add(new String[] { "LONG", "1" }); // TASK_SIZE_PER_WORKER
				bindlist.add(new String[] { "LONG", "1" });
				bindlist.add(new String[] { "LONG", "1" });
				bindlist.add(new String[] { "LONG", "120000" });
				bindlist.add(new String[] { "STRING", "MAIN" }); // run_type
				bindlist.add(new String[] { "STRING", "" }); // target_owner_info
				bindlist.add(new String[] { "INTEGER", "99" }); // master_limit
				bindlist.add(new String[] { "INTEGER", "99" }); // worker_limit
				bindlist.add(new String[] { "STRING", current_deployment_date }); // start_date

				execDBBindingConf(sql, bindlist);

				mylog(LOG_LEVEL_INFO, "Done.");
			}

			mylog(LOG_LEVEL_INFO, "Linking request " + request_id + " with "
					+ current_work_plan_id);
			sql = "insert into mad_request_work_plan (request_id, work_plan_id, deployment_attempt_no) values (?, ?, ?)";
			bindlist.clear();
			bindlist.add(new String[] { "INTEGER", request_id });
			bindlist.add(new String[] { "INTEGER", "" + current_work_plan_id });
			bindlist.add(new String[] { "INTEGER", "" + deployment_attempt_no });
			execDBBindingConf(sql, bindlist);

			mylog(LOG_LEVEL_INFO, "Done.");

		}

		next_create_mad_deployment_work_plans_ts = System.currentTimeMillis()
				+ CREATE_MAD_DEPLOYMENT_WPLANS_INTERVAL;
	}

	// -----------------------------------------------------------------
	boolean mad_checked = false;
	boolean mad_installed = false;

	boolean isMadInstalled() {
		boolean ret1 = false;

		if (!mad_checked) {
			String sql = "select * from information_schema.tables where table_schema =  DATABASE() and table_name ='mad_request'";
			ArrayList<String[]> arr = getDbArrayConf(sql, 1);
			mad_checked = true;
			mad_installed = false;

			if (arr != null && arr.size() == 1)
				mad_installed = true;
		}

		return mad_installed;

	}

	// ----------------------------------------------------------------
	boolean dm_checked = false;
	boolean dm_installed = false;

	boolean isDMInstalled() {
		boolean ret1 = false;

		if (!dm_checked) {
			String sql = "select * from information_schema.tables where table_schema =  DATABASE() and table_name ='tdm_proxy'";
			ArrayList<String[]> arr = getDbArrayConf(sql, 1);
			dm_checked = true;
			dm_installed = false;

			if (arr != null && arr.size() == 1)
				dm_installed = true;
		}

		return dm_installed;

	}

	// ----------------------------------------------------------------
	boolean datapool_checked = false;
	boolean datapool_installed = false;

	boolean isDataPoolInstalled() {
		boolean ret1 = false;

		if (!datapool_checked) {
			String sql = "select * from information_schema.tables where table_schema =  DATABASE() and table_name ='tdm_pool_instance'";
			ArrayList<String[]> arr = getDbArrayConf(sql, 1);
			datapool_checked = true;
			datapool_installed = false;

			if (arr != null && arr.size() == 1)
				datapool_installed = true;
		}

		return datapool_installed;

	}

	// ----------------------------------------------------------------
	boolean mask_disc_checked = false;
	boolean mask_disc_installed = false;

	boolean isMaskDiscoveryInstalled() {
		boolean ret1 = false;

		if (!mask_disc_checked) {
			String sql = "select * from information_schema.tables where table_schema =  DATABASE() and table_name ='tdm_discovery'";
			ArrayList<String[]> arr = getDbArrayConf(sql, 1);
			mask_disc_checked = true;
			mask_disc_installed = false;

			if (arr != null && arr.size() == 1)
				mask_disc_installed = true;
		}

		return mask_disc_installed;

	}

	// *********************************************

	ThreadGroup keepAliveConfDbThreadGroup = new ThreadGroup(
			"keepAliveConfDbThreadGroup");
	boolean keepAliveConfDbFlag = false;

	void startKeepAliveConfDB() {
		String thread_name = "KEEP_ALIVE_CONF_DB_THREAD";
		keepAliveConfDbFlag = true;
		try {
			System.out.println("startKeepAliveConfDB started...");
			Thread thread = new Thread(keepAliveConfDbThreadGroup,
					new keepAliveConfDBThread(this), thread_name);
			thread.start();
		} catch (Exception e) {
			mylog(LOG_LEVEL_ERROR,
					"Exception@startKeepAliveConfDB : " + e.getMessage());
			e.printStackTrace();
		}
	}

	// *********************************************
	void stopKeepAliveConfDB() {
		keepAliveConfDbFlag = false;

		long start_ts = System.currentTimeMillis();
		while (true) {
			int active_count = keepAliveConfDbThreadGroup.activeCount();

			if (active_count == 0)
				break;

			if (System.currentTimeMillis() - start_ts >= 10000)
				break;

			try {
				Thread.sleep(1000);
			} catch (Exception e) {
				e.printStackTrace();
			}

			mylog(LOG_LEVEL_WARNING,
					"Waiting Keep Alive thread to be finished.");
		}

	}

}
