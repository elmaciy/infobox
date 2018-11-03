	package com.mayatech.tdm;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.script.ScriptEngine;

import org.bson.Document;

import com.mayatech.baseLibs.genLib;
import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;
import com.mongodb.MongoClient;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoDatabase;
import com.mongodb.util.JSON;

public class maskLib {

	
	
	
	public String p_id="";
	
	boolean isBatchUpdateSupported=true;
	String start_ch="\"";
	String end_ch="\"";
	String middle_ch=".";
	
	
	
	boolean isExportingFinished=false;
	boolean isMaskingFinished=false;
	
	
	boolean isExportImportSameTime=true;
	boolean isExportByCtas=false;
	boolean isExportFirst=false;
	
	MongoClient mongoClient=null;
	MongoDatabase mongoDB=null;
	
	int master_id=0;
	
	@SuppressWarnings("rawtypes")
	
	ConcurrentHashMap hm = new ConcurrentHashMap();
	ConcurrentHashMap<Integer,Integer> hmProfiles = new ConcurrentHashMap<Integer,Integer>();
	
	
	ArrayList<String> field_names = new ArrayList<String>();
	ArrayList<String> field_types = new ArrayList<String>();
	ArrayList<Integer> field_sizes = new ArrayList<Integer>();
	ArrayList<String> field_PKs = new ArrayList<String>();
	ArrayList<String> field_mask_rules = new ArrayList<String>();
	ArrayList<String> field_mask_profiles=new ArrayList<String>();
	ArrayList<String> field_list_column_names= new ArrayList<String>();
	ArrayList<Integer> field_fixed_column_ids= new ArrayList<Integer>();
	
	boolean is_group_mixing=false;
	boolean is_record_mixing=false;
	
	int MAX_MASKER_THREAD_COUNT=10;
	
	public Connection confDB=null;
	Connection appDB=null;
	
	ArrayList<Connection> appDBForUpdate=new ArrayList<Connection>();
	ArrayList<Connection> confDBForUpdate=new ArrayList<Connection>();

	ArrayList<Integer> appDBForUpdateState=new ArrayList<Integer>();
	ArrayList<Long> appDBForUpdateLeasedTime=new ArrayList<Long>();

	boolean is_mongo=false;
	
	int env_id=0;
	String export_statement="";
	String update_on_server_statament="";

	String export_catalog="";
	String export_schema="";
	String export_table="";
	int export_tab_id=1;
	String export_partition="";
	String export_filter="";
	
	String repeat_parameters="";
	boolean is_paralleled_by_mod=false;
	
	
	boolean isRollbackRequired=true;
	boolean to_be_masked=false;
	boolean is_rollback=false;
	boolean cancellation_flag=false;
	
	boolean is_master_cancelled=false;
	boolean is_work_package_cancelled=false;
	
	boolean isExportsOfOtherWorkPackagesFinished=false;
	
	
	long export_limit=Long.MAX_VALUE;
	int REC_SIZE_PER_TASK=1000;
	ArrayList<String> fieldList=new ArrayList<String>();
	
	//ArrayList<Long> taskQueue=new ArrayList<Long>();

	long last_worker_heartbeat=System.currentTimeMillis();
	
	long last_check_cancel_ts=0;
	
	int work_plan_id=1;
	int work_package_id=11;
	
	commonLib cLib=null;
	
	java.util.Locale currLocale=new java.util.Locale("tr", "TR");
	
	static final String MASK_DEFAULT_CHAR_LIST="ABCÇDEFGHIÝJJKLMNOÖPQRSÞTUÜWXVYZabcçdefgðhýijklmnoöprsþtuüwxvyz";
	
	//dont change these keys
	static final int[] RANDOM_INT_ARRAY={1442, 9105, 9893, 1407, 8590, 869, 6283, 8822, 1762, 9193, 491, 3193, 1934, 5780, 9437, 
		7969, 9621, 8581, 8330, 4220, 3242, 8765, 7323, 5542, 2021, 2262, 8900, 1951, 4636, 2131, 
		7878, 9716, 311, 4196, 5888, 6037, 6022, 8562, 8715, 8438, 2056, 3908, 7997, 8801, 8310, 
		9789, 8409, 1080, 5356, 4547, 7716, 9904, 7624, 2921, 9823, 4518, 793, 7928, 339, 8808, 
		1916, 6196, 34, 3519, 8710, 4554, 4077, 1189, 3957, 8401, 3953, 7829, 2021, 9130, 4566, 
		7907, 7131, 8732, 1182, 821, 7230, 4576, 9599, 7695, 2991, 6337, 8199, 7117, 8877, 45, 
		2403, 7173, 2013, 1315, 432, 9044, 5091, 962, 4277, 4340};
	
	

	int original_thread_count=0;
	
	ArrayList<String[]> mask_Profiles=null;
	
	
	static final int MASK_PRFL_FLD_ID=0;
	static final int MASK_PRFL_FLD_NAME=1;
	static final int MASK_PRFL_FLD_RULE=2;
	
	static final int MASK_PRFL_FLD_HIDE_CHAR=3;
	static final int MASK_PRFL_FLD_HIDE_AFTER=4;
	static final int MASK_PRFL_FLD_HIDE_BY_WORD=5;
	
	static final int MASK_PRFL_FLD_SRC_LIST=6;
	static final int MASK_PRFL_FLD_RANDOM_RANGE=7;
	static final int MASK_PRFL_FLD_RANDOM_CHARLIST=8;
	static final int MASK_PRFL_FLD_REGEX_STMT=9;
	static final int MASK_PRFL_FLD_PRE_STATEMENT=10;
	static final int MASK_PRFL_FLD_POST_STATEMENT=11;
	static final int MASK_PRFL_FLD_FORMAT=12;
	static final int MASK_PRFL_FLD_DATE_CHANGE_PARAMS=13;
	
	static final int MASK_PRFL_FLD_FIXED_VAL=14;
	static final int MASK_PRFL_FLD_JS_CODE=15;
	
	static final int MASK_PRFL_FLD_SHORT_CODE=16;
	static final int MASK_PRFL_FLD_RUN_ON_SERVER=17;

	static final int MASK_PRFL_FLD_SCRAMBLE_PART_TYPE=18;
	static final int MASK_PRFL_FLD_SCRAMBLE_PART_TYPE_PAR1=19;
	static final int MASK_PRFL_FLD_SCRAMBLE_PART_TYPE_PAR2=20;

	
	public final String MASK_RULE_FIXED="FIXED";
	public final String MASK_RULE_NONE="NONE";
	public final String MASK_RULE_HIDE="HIDE";
	public final String MASK_RULE_HASHLIST="HASHLIST";
	public final String MASK_RULE_KEYMAP="KEYMAP";
	public final String MASK_RULE_REPLACE_ALL="REPLACE_ALL";
	public final String MASK_RULE_SCRAMBLE_PARTIAL="SCRAMBLE_PARTIAL";
	public final String MASK_RULE_SCRAMBLE_INNER="SCRAMBLE_INNER";
	public final String MASK_RULE_SCRAMBLE_RANDOM="SCRAMBLE_RANDOM";
	public final String MASK_RULE_SCRAMBLE_DATE="SCRAMBLE_DATE";
	public final String MASK_RULE_RANDOM_NUMBER="RANDOM_NUMBER";
	public final String MASK_RULE_RANDOM_STRING="RANDOM_STRING";
	public final String MASK_RULE_JAVASCRIPT="JAVASCRIPT";
	public final String MASK_RULE_SQL="SQL";
	public final String MASK_RULE_GROUP="GROUP";
	public final String MASK_RULE_GROUP_MIX="GROUP_MIX";
	public final String MASK_RULE_MIX="MIX";
	public final String MASK_RULE_HASH_REF="HASH_REF";
	
	public final String FIELD_TYPE_CALCULATED="CALCULATED";
	
	
	ThreadGroup maskerThreadGroup = new ThreadGroup("Masker Thread Group");
	ThreadGroup counterThreadGroup = new ThreadGroup("Counter Thread Group");
	ThreadGroup checkCancelThreadGroup = new ThreadGroup("Check Cancelation Thread Group");
	ThreadGroup maskerPostScriptThreadGroup = new ThreadGroup("Masker Post Script Thread Group");
	ThreadGroup heartbeatThreadGroup = new ThreadGroup("Long HeartBeat Thread Group");
	ThreadGroup dispatcherThreadGroup = new ThreadGroup("Dispatcher Thread Group");

	
	static final long COUNTER_INTERVAL=30000;
	long next_counter_ts=System.currentTimeMillis();
	
	
	static final long CHECK_CANCEL_INTERVAL=10000;
	long next_check_cancel_ts=System.currentTimeMillis()+CHECK_CANCEL_INTERVAL;
	
	//******************************************
	public maskLib(boolean connect) {
		
		cLib=new commonLib();
		
		p_id=cLib.getPID();
		
		if (connect) {
			
			String conf_driver=genLib.nvl(genLib.getEnvValue("CONFIG_DRIVER"),"<null>");
			String conf_connstr=genLib.nvl(genLib.getEnvValue("CONFIG_CONNSTR"),"<null>");
			String conf_username=genLib.nvl(genLib.getEnvValue("CONFIG_USERNAME"),"<null>");
			String conf_password=genLib.nvl(genLib.getEnvValue("CONFIG_PASSWORD"),"<null>");
			
			confDB=cLib.getDBConnection(conf_connstr, conf_driver, conf_username, conf_password, 1);
			
			if (confDB==null) {
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "Configuration DB is not accessible.");
				System.exit(0);
			}
			cLib.mylog(cLib.LOG_LEVEL_INFO, "Connected to configuration DB.");
			
			
		}
		
		
		
	}
	
	//****************************************
	void loadWorkPlanParameters(ConfDBOper dbCount) {
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String sql="select env_id, rec_size_per_task, worker_limit, run_type, repeat_parameters from tdm_work_plan where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+this.work_plan_id});
		
		ArrayList<String[]> arr=cLib.getDbArray(dbCount.connConf, sql, 1, bindlist);
		
		if (arr==null || arr.size()==0) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Work plan not found " + this.work_plan_id);
			return;
		}
		

		
		int env_id=Integer.parseInt(arr.get(0)[0]);
		int task_size=1000;
		try{task_size=Integer.parseInt(arr.get(0)[1]);} catch(Exception e) {task_size=1000;}
		try{this.MAX_MASKER_THREAD_COUNT=Integer.parseInt(arr.get(0)[2]);} catch(Exception e) {this.MAX_MASKER_THREAD_COUNT=0;}
		if (this.MAX_MASKER_THREAD_COUNT>10) this.MAX_MASKER_THREAD_COUNT=10;
		String run_type=arr.get(0)[3];
		this.repeat_parameters=arr.get(0)[4];
		
		is_rollback=false;
		if (run_type.indexOf("TEST:")==0) is_rollback=true;
		

		setRecordsInTask(task_size);
		setEnvId(env_id);
		


		
	}
	
	//****************************************
	void loadMaskingConfiguration(ConfDBOper db, boolean mask_flag) {
		
		loadWorkPlanParameters(db);
		
		//loading mask profiles
		mask_Profiles=loadMaskProfiles(db.connConf);
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String sql="";
		
		sql="select schema_name, table_name, mask_params, sql_statement, tab_id from tdm_work_package where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+this.work_package_id});
		
		ArrayList<String[]> arr=cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		if (arr.size()==0) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Mask Params for work package : " + work_package_id + " cannot loaded. ");
			return;
		}
	
		String catalog_schema_name=arr.get(0)[0];
		String catalog_name=catalog_schema_name.split("\\.")[0];
		String schema_name=catalog_schema_name.split("\\.")[1];
		
		String table_name=arr.get(0)[1];
		String params=arr.get(0)[2];
		String sql_statement=arr.get(0)[3];
		String tab_id=arr.get(0)[4];
		
		sql="select repeat_parameters from tdm_work_plan where id=?";  
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+this.work_plan_id});
		arr=cLib.getDbArray(db.connConf, sql, 1, bindlist);
		if (arr.size()==0) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Application parameter (repeat_parameters) for work package : " + work_package_id + " cannot loaded. ");
			return;
		}
		
		
		String repeat_parameters=arr.get(0)[0];
		
		String full_table_name = schema_name+"."+table_name;
		
		if (schema_name.length()==0 || schema_name.equals("null")) full_table_name = table_name;
		
		if (mask_flag)
			extractMaskParams(tab_id,full_table_name, params);
		
		this.fieldList.clear();
		this.fieldList.addAll(field_names);
		
		this.export_catalog=catalog_name;
		this.export_schema=schema_name;
		this.export_table=table_name;
		this.export_tab_id=Integer.parseInt(tab_id);
		this.export_statement=sql_statement;
		this.repeat_parameters=repeat_parameters;
		
		this.is_paralleled_by_mod=true;
		
		sql="select parallel_field, parallel_mod from tdm_tabs where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",tab_id});
		
		arr=cLib.getDbArray(db.connConf, sql, 1, bindlist);
		if (arr!=null && arr.size()==1) {
			String parallel_field=arr.get(0)[0];
			String parallel_mod=arr.get(0)[1];
			
			if (parallel_field.equals("1") || parallel_mod.equals("1"))
				this.is_paralleled_by_mod=false;
		}
		
		
		sql="select  rollback_needed, export_plan from tdm_tabs where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",tab_id});
		
		
		isRollbackRequired=true;
		isExportImportSameTime=true;
		isExportByCtas=false;
		isExportFirst=false;
		
		arr=cLib.getDbArray(db.connConf, sql, 1, bindlist);
		if (arr!=null && arr.size()==1) {
			String rollback_needed=arr.get(0)[0];
			String export_plan=arr.get(0)[1];
			
			
			if (rollback_needed.equals("NO")) isRollbackRequired=false;
			
			if (export_plan.equals("EXPORT_MASKING")) {
				isExportImportSameTime=true;
				isExportByCtas=false;
				isExportFirst=false;
			} 
			else if (export_plan.equals("EXPORT_FIRST")) {
				isExportImportSameTime=false;
				isExportByCtas=false;
				isExportFirst=true;
				
			}
			else if (export_plan.equals("EXPORT_FROM_CTAS")) {
				isExportImportSameTime=true;
				isExportByCtas=true;
				isExportFirst=false;
			}
		}
		



		
		
	}
	
	
	
	
	//****************************************
	
	ArrayList<String[]> serverBindList=new ArrayList<String[]>();
	
	boolean checkRunOnServerAvailability() {
		
		String sql="select field_name, f.mask_prof_id, rule_id, run_on_server " + 
						"	from  " + 
						"	tdm_work_package w, tdm_fields f, tdm_mask_prof p " + 
						"	where f.tab_id=w.tab_id and mask_prof_id=p.id " + 
						"	and w.id=? " + 
						"	union all " + 
						"	select field_name, 0, 'IS_CONDITIONAL', 'NO' run_on_server  " + 
						"	from  " + 
						"	tdm_work_package w, tdm_fields f " + 
						"	where f.tab_id=w.tab_id and is_conditional='YES' " + 
						"	and w.id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+work_package_id});
		bindlist.add(new String[]{"INTEGER",""+work_package_id});
		
		ArrayList<String[]> arr=cLib.getDbArray(confDB, sql, Integer.MAX_VALUE, bindlist);
		
		
		if (arr.size()==0) {
			return false;
		}
		
		String app_db_type=cLib.getDbTypeByEnvId(confDB, env_id);
		
		int none_run_on_server_count=0;
		int added_field=0;
		
		String FIELD_SET_STATEMENT="";
		serverBindList.clear();
		
		for (int i=0;i<arr.size();i++) {
			//String field_name=arr.get(i)[0];
			String field_name=addStartEndForColumn(arr.get(i)[0]);
			String mask_prof_id=arr.get(i)[1];
			String rule_id=arr.get(i)[2];
			String run_on_server=arr.get(i)[3];
			
			if (rule_id.equals("NONE") || run_on_server.equals("NO")) {
				none_run_on_server_count++;
				continue;
			}
			
			added_field++;
			
			int prof_arr_id=0;
			
			try {prof_arr_id=hmProfiles.get(Integer.parseInt(mask_prof_id));} catch(Exception e) {e.printStackTrace();}
			
			if (prof_arr_id==0) {
				System.out.println(" *** Profile ("+mask_prof_id+") not found ...");
				continue;
			}
			
			
			
			serverBindList.add(new String[]{"STRING",rule_id});
				
			
			if (rule_id.equals("FIXED")) {
				String FIXED_VAL=mask_Profiles.get(prof_arr_id)[MASK_PRFL_FLD_FIXED_VAL];
				serverBindList.add(new String[]{"STRING",FIXED_VAL});
				
				serverBindList.add(new String[]{"STRING",""});
				serverBindList.add(new String[]{"STRING",""});
				serverBindList.add(new String[]{"STRING",""});
				serverBindList.add(new String[]{"STRING",""});
				
			} else if (rule_id.equals("HIDE")) {
				String FLD_HIDE_CHAR=mask_Profiles.get(prof_arr_id)[MASK_PRFL_FLD_HIDE_CHAR];
				String FLD_HIDE_AFTER=mask_Profiles.get(prof_arr_id)[MASK_PRFL_FLD_HIDE_AFTER];
				String FLD_HIDE_BY_WORD=mask_Profiles.get(prof_arr_id)[MASK_PRFL_FLD_HIDE_BY_WORD];
				


				serverBindList.add(new String[]{"STRING",FLD_HIDE_CHAR});
				serverBindList.add(new String[]{"STRING",FLD_HIDE_AFTER});
				serverBindList.add(new String[]{"STRING",FLD_HIDE_BY_WORD});
				
				serverBindList.add(new String[]{"STRING",""});
				serverBindList.add(new String[]{"STRING",""});

			} else if (rule_id.equals("HASHLIST")) {
				String FLD_SRC_LIST=mask_Profiles.get(prof_arr_id)[MASK_PRFL_FLD_SRC_LIST];
				String LIST_ITEM_COUNT=""+(Integer) hm.get("LIST_"+FLD_SRC_LIST+"_SIZE");
				serverBindList.add(new String[]{"STRING",""+work_plan_id});
				serverBindList.add(new String[]{"STRING",FLD_SRC_LIST});
				serverBindList.add(new String[]{"STRING",LIST_ITEM_COUNT});
				
				serverBindList.add(new String[]{"STRING",""});
				serverBindList.add(new String[]{"STRING",""});
			}
			else if (rule_id.equals("RANDOM_NUMBER") || rule_id.equals("RANDOM_STRING")) {
				String FLD_RANDOM_RANGE=mask_Profiles.get(prof_arr_id)[MASK_PRFL_FLD_RANDOM_RANGE];
				String range_start="";
				String range_end="";

				
				try{range_start=FLD_RANDOM_RANGE.split(",")[0];} catch(Exception e) {};
				try{range_end=FLD_RANDOM_RANGE.split(",")[1];} catch(Exception e) {};
				
				serverBindList.add(new String[]{"STRING",range_start});
				serverBindList.add(new String[]{"STRING",range_end});
				
				serverBindList.add(new String[]{"STRING",""});
				serverBindList.add(new String[]{"STRING",""});
				serverBindList.add(new String[]{"STRING",""});
				
			} 
			else if (rule_id.equals("SQL")) {
				String INNER_SQL_STATEMENT=mask_Profiles.get(prof_arr_id)[MASK_PRFL_FLD_JS_CODE];
				if (INNER_SQL_STATEMENT.contains("?"))
					INNER_SQL_STATEMENT=INNER_SQL_STATEMENT.replace("?", field_name);

				if (INNER_SQL_STATEMENT.length()>0) {
					FIELD_SET_STATEMENT=FIELD_SET_STATEMENT+field_name+"= ("+INNER_SQL_STATEMENT+") ";
					
					//serverBindList.set(serverBindList.size()-1,  new String[]{"STRING","NONE"});
					
					serverBindList.remove(serverBindList.size()-1);
					/*
					serverBindList.add(new String[]{"STRING",""});
					serverBindList.add(new String[]{"STRING",""});
					serverBindList.add(new String[]{"STRING",""});
					serverBindList.add(new String[]{"STRING",""});
					serverBindList.add(new String[]{"STRING",""});
					*/
					
					
				}
				

			} else {
				serverBindList.add(new String[]{"STRING",""});
				serverBindList.add(new String[]{"STRING",""});
				serverBindList.add(new String[]{"STRING",""});
				serverBindList.add(new String[]{"STRING",""});
				serverBindList.add(new String[]{"STRING",""});
			}
				
			if (added_field>1) FIELD_SET_STATEMENT=FIELD_SET_STATEMENT+", \n";
			
			if (!rule_id.equals("SQL"))
				FIELD_SET_STATEMENT=FIELD_SET_STATEMENT+field_name+"=maya_tdm_mask("+field_name+",?,   ?, ?, ?, ?, ?)";
		}
		
		
		
		
		
		if (none_run_on_server_count>0) return false;
		
		buildExportStatement(appDB);
		
		String stmt_from=" from ";
		String stmt_where=" where ";
		
		int ind_from=export_statement.toLowerCase().indexOf(stmt_from);
		int ind_where=export_statement.toLowerCase().indexOf(" where ");

		
		String update_table="";
		String update_conditon="";
		
		try {
			if (ind_where==-1) 
				update_table=export_statement.substring(ind_from+stmt_from.length());
			else 
				update_table=export_statement.substring(ind_from+stmt_from.length(), ind_where);
			} catch(Exception e) {
				update_table=export_schema+"."+export_table;
			}
		
		try {
			if (ind_where>-1) 
				update_conditon=export_statement.substring(ind_where+stmt_where.length());
		} catch(Exception e) {
			update_conditon="";
		}
		
		
		String server_sql="";
		
		
		
		
		if (app_db_type.equals(genLib.DB_TYPE_ORACLE)) {
			String parallel_count=genLib.nvl(cLib.getParamByName(confDB, "PARALLELISM_COUNT"),"8");
			int parallelism_count_INT=8;
			try {parallelism_count_INT=Integer.parseInt(parallel_count);} catch(Exception e) {}
			
			server_sql=" UPDATE /* parallel("+parallelism_count_INT+") */ "+update_table+" NOLOGGING \n" +
						" set \n" +
						FIELD_SET_STATEMENT;
			
			if (ind_where>-1) 
				server_sql=server_sql+"\n where \n"+ update_conditon;
			
		} else if (app_db_type.equals(genLib.DB_TYPE_MYSQL)) {
						
			server_sql=" UPDATE "+update_table+"  \n" +
						" set \n" +
						FIELD_SET_STATEMENT;
			
			if (ind_where>-1) 
				server_sql=server_sql+"\n where \n"+ update_conditon;
			
		}
		else 
			return false;
		
		update_on_server_statament=server_sql;
		
		
		
		
		return true;
	}
	
	//***************************************
	
	int runOnServer() {
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		
		long duration=System.currentTimeMillis();
		
		cLib.mylog(cLib.LOG_LEVEL_INFO,"***************************");
		cLib.mylog(cLib.LOG_LEVEL_INFO,"**** RUNNING ON SERVER ****");
		cLib.mylog(cLib.LOG_LEVEL_INFO,update_on_server_statament);
		cLib.mylog(cLib.LOG_LEVEL_INFO,"***************************");
		for (int i=0;i<serverBindList.size();i++) 
			cLib.mylog(cLib.LOG_LEVEL_INFO,"BIND_"+(i+1)+" : {" + serverBindList.get(i)[1]+"}");
		
		cLib.mylog(cLib.LOG_LEVEL_INFO,"***************************");
		
		String heartbeat_key="HEARTBEAT_"+System.currentTimeMillis();
		hm.put(heartbeat_key, true);
		
		
		startLongHeartBeatThread(heartbeat_key);
		
		String sql="update tdm_work_package set start_date=now() where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+work_package_id});
		cLib.execSingleUpdateSQL(confDB, sql, bindlist);
		
		cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, master_id, cLib.WORK_PACKAGE_STATUS_MASKING);
		
		int update_count=cLib.execBatchUpdateSql(
					appDB, 
					false, 
					update_on_server_statament, 
					serverBindList, 
					serverBindList.size(), 
					Integer.MAX_VALUE,
					this,
					cLib.logStr,
					cLib.errStr
					);
		
		
		hm.remove(heartbeat_key);
		

		
		duration=System.currentTimeMillis()-duration;
		
		sql="update tdm_work_package set "+
					" duration=?, "+
					" export_count=?, all_count=?, done_count=?, success_count=?, fail_count=? "+
					" where id=?";
		

		bindlist.clear();
		bindlist.add(new String[]{"LONG",""+duration});
		bindlist.add(new String[]{"INTEGER",""+update_count});
		bindlist.add(new String[]{"INTEGER",""+update_count});
		bindlist.add(new String[]{"INTEGER",""+update_count});
		bindlist.add(new String[]{"INTEGER",""+update_count});
		bindlist.add(new String[]{"INTEGER",""+update_count});
		bindlist.add(new String[]{"INTEGER",""+work_package_id});
		
		cLib.execSingleUpdateSQL(confDB, sql, bindlist);
		
		sql="delete from tdm_task_"+work_plan_id+"_"+work_package_id;
		bindlist.clear();
		cLib.execSingleUpdateSQL(confDB, sql, bindlist);

		int fail_count=0;
		
		String task_status="FINISHED";

		if (cLib.errStr.indexOf("xception")>-1) {
			task_status="FAILED";
			fail_count=1;
		}
		
		int task_id=1;
		
		sql="insert into tdm_task_"+work_plan_id+"_"+work_package_id+" "+
					" ("+
					" id, task_name, task_order, work_plan_id, work_package_id, status, "+
					" create_date, start_date, end_date, last_activity_date, duration, "+
					" all_count, success_count, fail_count, done_count, retry_count " +
					" )"+
					" values "+
					"("+
					"?, 'TASK_1' , 1, ?, ?, ?, "+
					"now() , DATE_SUB(now(), INTERVAL ? MICROSECOND), now(), now(), ?, "+
					"? , ?, ?, ?, 0 "+
					")";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+task_id});
		bindlist.add(new String[]{"INTEGER",""+work_plan_id});
		bindlist.add(new String[]{"INTEGER",""+work_package_id});
		bindlist.add(new String[]{"STRING",""+task_status});
		bindlist.add(new String[]{"INTEGER",""+duration});
		bindlist.add(new String[]{"INTEGER",""+duration});
		bindlist.add(new String[]{"INTEGER",""+update_count});
		bindlist.add(new String[]{"INTEGER",""+update_count});
		bindlist.add(new String[]{"INTEGER",""+fail_count});
		bindlist.add(new String[]{"INTEGER",""+update_count});

		cLib.execSingleUpdateSQL(confDB, sql, bindlist);
		
		cLib.setBinInfo(confDB, "tdm_task_"+work_plan_id+"_"+work_package_id,task_id,"log_info_zipped", cLib.logStr);
		
		if (task_status.equals("FAILED")) {
			cLib.setBinInfo(confDB, "tdm_task_"+work_plan_id+"_"+work_package_id,task_id,"err_info_zipped", cLib.errStr);
			cLib.setworkPackageError(confDB, work_plan_id, work_package_id, cLib.errStr.toString());
			//cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, 0, cLib.WORK_PACKAGE_STATUS_FAILED);
		}
		 
		cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, 0, cLib.WORK_PACKAGE_STATUS_FINISHED);

	
		
		
		
		
		return update_count;
	}
	//****************************************
	public long  doWorkPackage(
			ConfDBOper db, 
			int master_id, 
			int work_plan_id, 
			int work_package_id, 
			boolean export_flag, 
			boolean mask_flag
			) {
		
		
		this.master_id=master_id;
		this.work_plan_id=work_plan_id;
		this.work_package_id=work_package_id;
		
		cLib.logStr.setLength(0);
		
		loadMaskingConfiguration(db, mask_flag);
		
		long export_count=0;
		
		
		if (checkRunOnServerAvailability()) {
			cLib.mylog(cLib.LOG_LEVEL_WARNING,"Running on server : " +update_on_server_statament);
			export_count=runOnServer();
			return export_count;
		}
		
		boolean final_export_flag=export_flag;
		
		if (final_export_flag) {
			String work_package_status=cLib.getWorkPackageStatus(confDB, this.work_package_id);


			if (work_package_status.equals(cLib.WORK_PACKAGE_STATUS_MASKING)) {
				cLib.mylog(cLib.LOG_LEVEL_WARNING, "Setting export_flag=false.");
				final_export_flag=false;
			}
		}
		
		if (is_rollback) 
			prepareTaskTableForRollback();
		
		
		startDispatcherThread();
		
		startCheckCancellationThread(true);

		startCounterThread(true);

		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		



		isExportingFinished=false;
		isMaskingFinished=false;
		
		
		 
		if (!is_rollback && final_export_flag) {
			if (is_mongo) export_count=exportMONGO(mask_flag);
			else export_count=export(mask_flag);
		
		}
		
		if (is_rollback)
			loadPersistedTasks(confDB,true);
			
		isExportingFinished=true;
		
		if (!cancellation_flag && export_count>=0)
			waitDispatcherFinishAllTasks();
		
		dropTempTable();
		
		stopDispatcherThread();
		
		isMaskingFinished=true;

		if (!cancellation_flag && export_count>=0) {
			countWorkPackage(db);
			cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, 0, cLib.WORK_PACKAGE_STATUS_FINISHED);
			
		} 
		// if !cancelled or Error occured (export_count=-1) persistAll
		else {
			
			if (!cancellation_flag)
				persistUnfinishedTasks(confDB);
			
			countWorkPackage(db);
			
			if (is_master_cancelled)
				cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, 0, cLib.WORK_PACKAGE_STATUS_NEW);

		}

		
		return export_count;
	}
	
	//*****************************************
	void prepareTaskTableForRollback() {
		
		// bu guncellemeler ekranda yapildigindan burada tekrar yapýlmýyor. 
		
		/*
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String task_table="tdm_task_"+work_plan_id+"_"+work_package_id;
		
		String sql="update "+task_table+" set status='NEW_X' where status='NEW'";
		
		cLib.execSingleUpdateSQL(confDB, sql, bindlist);
		
		
		sql="update "+task_table+" set status='NEW' where status!='NEW_X'";
		
		cLib.execSingleUpdateSQL(confDB, sql, bindlist);
		
		sql="update "+task_table+" set status='FINISHED' where status='NEW_X'";
		
		cLib.execSingleUpdateSQL(confDB, sql, bindlist);
		*/
	}
	
	//*****************************************
	void waitDispatcherFinishAllTasks() {
		
		boolean is_all_finished=false;
		int wpc_touch_counter=0;
		
		
		
		while(true) {

			cLib.heartbeat(confDB, cLib.TABLE_TDM_MASTER, 0, master_id);

			is_all_finished=true;
			
			if (cancellation_flag) break;
			
			for (int i=0;i<globalTaskArr.size();i++) 
				if (globalTaskArr.get(i)!=null && hmArrStatus.get(i)!=ARR_STAT_FREE) {
					is_all_finished=false;
					cLib.mylog(cLib.LOG_LEVEL_WARNING, "** unFinished task found in memory [task_id : "+hmTaskId.get(i)+"]=>  "+hmArrStatus.get(i));
					
					break;
				}
			
			if (is_all_finished) {
				
				cLib.mylog(cLib.LOG_LEVEL_WARNING, "waitDispatcherFinishAllTasks exit 1");
				
				is_all_finished=false;
				
				String sql="select 1 from tdm_task_"+work_plan_id+"_"+work_package_id+" where status in ('RETRY','NEW','ASSIGNED','RUNNING') limit 0,1";
				ArrayList<String[]> bindlist=new ArrayList<String[]>();
				ArrayList<String[]> arr=cLib.getDbArray(confDB, sql, 1, bindlist);
				if (arr!=null && arr.size()==0) {
					cLib.mylog(cLib.LOG_LEVEL_WARNING, "waitDispatcherFinishAllTasks exit 2");
					is_all_finished=true;
				}
				else 
					cLib.mylog(cLib.LOG_LEVEL_WARNING, "There area unfinished tasks in task table");
			}
			
			if (is_all_finished) {
				cLib.mylog(cLib.LOG_LEVEL_WARNING, "waitDispatcherFinishAllTasks break 1");
				break;
			}
				
			
			cLib.mylog(cLib.LOG_LEVEL_WARNING, "all tasks are not finished yet. waiting...");
			
			
			try {Thread.sleep(1000); } catch(Exception e) {}
			
			wpc_touch_counter++;
			
			if (wpc_touch_counter % 10 ==0) {
				wpc_touch_counter=0;
				cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, master_id, cLib.WORK_PACKAGE_STATUS_TOUCH);
			}
			
			
			if (last_worker_heartbeat<System.currentTimeMillis()-10*60*1000) {
				cLib.mylog(cLib.LOG_LEVEL_WARNING, "waitDispatcherFinishAllTasks break 2");
				break;
			}
			
			
		}
	}
	
	
	
	long next_get_stats_ts=0;
	static final int GET_STATS_INTERVAL=10000;
	
	//*****************************************
	int getTaskArrStatistics() {
		
		if (next_get_stats_ts>System.currentTimeMillis()) return 0;
		next_get_stats_ts=System.currentTimeMillis()+GET_STATS_INTERVAL;
		
		
		int unfinished_task_count=0;
		int null_task_count=0;
		int free_task_count=0;
		int filled_task_count=0;
		int busy_task_count=0;
		
		
		for (int i=0;i<globalTaskArr.size();i++) {
			if (globalTaskArr.get(i)==null) {
				null_task_count++;
				continue;
			}
			
			if (hmArrStatus.get(i)==ARR_STAT_FREE) free_task_count++;
			else if (hmArrStatus.get(i)==ARR_STAT_FILLED) filled_task_count++;
			else if (hmArrStatus.get(i)==ARR_STAT_ASSIGNED) busy_task_count++;
			else if (hmArrStatus.get(i)==ARR_STAT_RUNNING) busy_task_count++;
			
			
		}
			
		unfinished_task_count=filled_task_count+busy_task_count;
		
		System.out.println(" - - - - - - - - getTaskArrStatistics - - - - - - - - - - -");
		System.out.println("all_task_count \t : "+globalTaskArr.size());
		System.out.println("null_task_count \t : "+null_task_count);
		System.out.println("free_task_count \t : "+free_task_count);
		System.out.println("filled_task_count \t : "+filled_task_count);
		System.out.println("busy_task_count \t : "+busy_task_count);
		System.out.println("unfinished_task_count \t : "+unfinished_task_count);
		
		return unfinished_task_count;
	}
	//*****************************************
	void checkWorkPackageAndFinishWorkPlan() {
		

		
		//----------------------------------------------------------------
		String sql="update tdm_work_package set master_id=null where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",""+work_package_id});
		cLib.execSingleUpdateSQL(confDB, sql, bindlist);
		
		sql="select count(*) from tdm_work_package where work_plan_id=? and status!='FINISHED'";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+work_plan_id});
		ArrayList<String[]> arr=cLib.getDbArray(confDB, sql, 1, bindlist);
		
		int unfinished_work_package=1;
		
		try {unfinished_work_package=Integer.parseInt(arr.get(0)[0]);} catch(Exception e) {}
		
		
		if (unfinished_work_package==0) {
			sql="update tdm_work_plan set status='COMPLETED-EXECUTING',end_date=now(), post_script_log=null where id=?";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+work_plan_id});
			cLib.execSingleUpdateSQL(confDB, sql, bindlist);
			
			
			
			
			executePostScripts(); 
			
			
			sql="update tdm_work_plan set status='FINISHED',end_date=now(), post_script_log=? where id=?";
			bindlist.clear();
			bindlist.add(new String[]{"STRING",""+postScriptLogs.toString()});
			bindlist.add(new String[]{"INTEGER",""+work_plan_id});
			cLib.execSingleUpdateSQL(confDB, sql, bindlist);
			
			
		}
	}
	
	
	//****************************************
	
	StringBuilder postScriptLogs=new StringBuilder();
	
	void executePostScripts() {
		String sql="select post_script from tdm_work_plan where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+work_plan_id});
		ArrayList<String[]> arr=cLib.getDbArray(confDB, sql, 1, bindlist);
		
		String post_script=arr.get(0)[0];
		
		
		ArrayList<String> cmdArr=new ArrayList<String>();
		
		StringBuilder a_cmd=new StringBuilder();
		
		
		String[] lines=post_script.split("\n|\r");
		for (int i=0;i<lines.length;i++) {
			String a_line=lines[i];
			if (a_line.trim().equals("/")) {
				if (a_cmd.toString().trim().length()>0)
					cmdArr.add(a_cmd.toString());
					a_cmd.setLength(0);
					continue;
			}
			a_cmd.append(a_line);
			a_cmd.append("\n");
		}
		
		if (a_cmd.toString().trim().length()>0)
			cmdArr.add(a_cmd.toString());
		
		
		postScriptLogs.append("Number of scripts to execute : "+cmdArr.size());
		postScriptLogs.append("\n");
		
		
		Connection connDBScript=cLib.getApplicationDbConnectionByDBId(confDB,env_id);
		
		for (int i=0;i<cmdArr.size();i++) {
			
			String thread_name="Post Script of "+i;
			
			
				System.out.println("Executing("+(i+1)+") :\n" + cmdArr.get(i));
				
				postScriptLogs.append("Executing("+(i+1)+") ...\n ");
				postScriptLogs.append("----------------------------------------------------\n");
				postScriptLogs.append(cmdArr.get(i));
				postScriptLogs.append("----------------------------------------------------\n");
				postScriptLogs.append("\n");
				/*
				Thread thread=new Thread(
						maskerPostScriptThreadGroup, 
							new maskingPostScriptThread(this, cmdArr.get(i)),
							thread_name
						);
				thread.start();
				*/
				long start_ts=System.currentTimeMillis();

				
				
				PreparedStatement pstmt =null;
				
				try {
					pstmt = connDBScript.prepareStatement(cmdArr.get(i));
			 		
			 		pstmt.executeUpdate();


					if (!connDBScript.getAutoCommit()) 	connDBScript.commit();
					
					long duration=System.currentTimeMillis()-start_ts;
				 	cLib.mylog(cLib.LOG_LEVEL_INFO, "**** executed successfully : Duration " +duration+" msecs.");
				 	
				 	postScriptLogs.append("**** executed successfully : "+"Duration " +duration+" msecs. \n");
				 	
				 	
				 	
				} catch(Exception e) {
			 		cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@Executing SQL : \n");
			 		cLib.mylog(cLib.LOG_LEVEL_DANGER, cmdArr.get(i)+"\n");
			 		cLib.mylog(cLib.LOG_LEVEL_DANGER, genLib.getStackTraceAsStringBuilder(e).toString()+"\n");
			 		
			 		
			 		
			 		postScriptLogs.append("Exception@Executing SQL : \n"+
			 				cmdArr.get(i)+"\n"+
								genLib.getStackTraceAsStringBuilder(e).toString()+"\n"
			 				);
			 		
			 	}
				finally {
			 		try {pstmt.close();} catch(Exception e) {}
			 		
			 	}

				sql="update tdm_work_plan set post_script_log=? where id=?";
				bindlist.clear();
				bindlist.add(new String[]{"STRING",""+postScriptLogs.toString()});
				bindlist.add(new String[]{"INTEGER",""+work_plan_id});
				cLib.execSingleUpdateSQL(confDB, sql, bindlist);

			
		} //for (int i=0;i<cmdArr.size();i++)
		
		try {connDBScript.close();} catch(Exception e) {}
		
		
		
		
		
		
		
	}
	
	
	
	//*****************************************
	
	
	
	
	
	public void setEnvId(int env_id) {

		if (this.env_id==env_id) {
			boolean isConnectionValid=false;

			if (is_mongo) {
				try { 
					MongoClient test=cLib.getMongoClient(confDB, env_id);
					if (test!=null) isConnectionValid=true;
					test.close();
				} catch(Exception e) {}
				
				
			} else {
				isConnectionValid=true;
				//try { isConnectionValid=appDB.isValid(5); } catch(Exception e) {}
			}
			
			if (isConnectionValid) return;
			
		}
		
		
		this.env_id=env_id;
		
		is_mongo=false;
		String db_type=cLib.getDbTypeByEnvId(confDB, env_id);
		System.out.println("**\tDbType : "+db_type);
		if (db_type.toUpperCase().contains("MONGO")) is_mongo=true;
	
		if (is_mongo) {
			cLib.mylog(cLib.LOG_LEVEL_WARNING, "I am running on MONGODB. ");
			isBatchUpdateSupported=false;
			return;
		}
	
		
		appDB=cLib.getApplicationDbConnectionByDBId(confDB,env_id);
		
		if (appDB==null) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Application db is not accessible.");
			return;
		}
		
		
		try {
			isBatchUpdateSupported=appDB.getMetaData().supportsBatchUpdates();
			start_ch=appDB.getMetaData().getIdentifierQuoteString();
			end_ch=start_ch;
			middle_ch=genLib.nvl(appDB.getMetaData().getCatalogSeparator(),".");
			
			} catch (SQLException e) {
				cLib.mylog(cLib.LOG_LEVEL_WARNING, "Exception@supportsBatchUpdates : "+genLib.getStackTraceAsStringBuilder(e).toString());
				
				isBatchUpdateSupported=false;
				
				start_ch="";
				end_ch="";
				middle_ch=".";
				
				}
		
		//jdbc driverde batch destegi gelmiyor. Bu sekilde zorluyoruz. 
		//ayrica autocommit i true olarak zorluyoruz
		
		
		if (db_type.equals(genLib.DB_TYPE_SYBASE)) {
			
			try {isBatchUpdateSupported=appDB.getMetaData().supportsBatchUpdates();}  catch (SQLException e) {isBatchUpdateSupported=false;}
			try {appDB.setAutoCommit(true);} catch (SQLException e) {}
			
			
		}


		if (db_type.equals(genLib.DB_TYPE_MSSQL)) {
			try {isBatchUpdateSupported=appDB.getMetaData().supportsBatchUpdates();}  catch (SQLException e) {isBatchUpdateSupported=false;}
			try {appDB.setAutoCommit(true);} catch (SQLException e) {}
		}		
		
		cLib.mylog(cLib.LOG_LEVEL_WARNING, "db_type                 = "+db_type);
		cLib.mylog(cLib.LOG_LEVEL_WARNING, "isBatchUpdateSupported  = "+isBatchUpdateSupported);


		
		
		cLib.mylog(cLib.LOG_LEVEL_WARNING,"Application db connection is established.");
	}
	
	
	//*****************************************
	public void setExportStatement(String statement) {
		this.export_statement=statement;
		this.export_catalog="";
		this.export_schema="";
		this.export_table="";
		this.export_partition="";
		this.export_filter="";
	}
	
	
	//******************************************
	public void setExportStatement(String export_catalog, String export_schema, String export_table, String export_filter) {
		setExportStatement(export_catalog, export_schema, export_table, export_filter, "");
		
		
	}
	//*****************************************
	public void setExportStatement(String export_catalog, String export_schema, String export_table) {
		setExportStatement(export_catalog, export_schema, export_table, "", "");
		
	}
	
	//*****************************************
	public void setExportStatement(String export_catalog, String export_schema, String export_table, String export_filter, String export_partition) {
		this.export_catalog=export_catalog;
		this.export_schema=export_schema;
		this.export_table=export_table;
		this.export_partition=export_partition;
		this.export_filter=export_filter;
		
		this.export_statement="";
		this.update_on_server_statament="";
		
	}
	
	//******************************************
	public void setFieldList(ArrayList<String> fieldList) {
		this.fieldList=fieldList;
	}
	//*******************************************
	public void setExportLimit(long export_limit) {
		this.export_limit=export_limit;
	}
	//*******************************************
	public void setRecordsInTask(int records_in_task) {
		this.REC_SIZE_PER_TASK=records_in_task;
	}

	//*******************************************
	public long exportMONGO(boolean mask_flag) {
		
		return exportMONGO(
				this.export_limit, 
				this.REC_SIZE_PER_TASK, 
				this.fieldList,
				mask_flag);
		
	}
	
	
	//******************************************
		long exportMONGO(
				long export_limit, 
				int records_in_task, 
				ArrayList<String> fieldList,
				boolean mask_flag
				) {
			long read_count=0;
			long export_count=0;
			
			
			
			
			mongoClient=cLib.getMongoClient(confDB, env_id);
			
			if (mongoClient==null) {
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "Mongo client is not connected");
				return -1;
			}
			
			String mongo_db=export_schema;
			String mongo_collection=export_table;
			
			mongoDB=cLib.getMongoDB(mongoClient, mongo_db);
			
			if (mongoDB==null) {
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "Mongo DB is not available for : "+mongo_db);
				return -1;
			}
			
			this.export_limit=export_limit;
			this.REC_SIZE_PER_TASK=records_in_task;
			this.fieldList=fieldList;
			this.to_be_masked=mask_flag;
			
			//-------------------------------
			cLib.mylog(cLib.LOG_LEVEL_INFO, "Exporting MONGO collection : " + export_schema+"."+export_table);


			ArrayList<String[]> exportArr=new ArrayList<String[]>();
			
			
			boolean export_error=false;
			
			try {
				
				cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, master_id, cLib.WORK_PACKAGE_STATUS_EXPORTING);
				
				
				ArrayList<String[]> columnInfo=new ArrayList<String[]>();
				
				
				ArrayList<String> pkArr=new ArrayList<String>();
				
				for (int p=0;p<field_PKs.size();p++) {
					if (!field_PKs.get(p).equals("YES")) continue;
					
					pkArr.add(field_names.get(p));
					
					columnInfo.add(new String[]{
							field_names.get(p), //ColumnName,
							"0", // ""+ColumnType,
							"_id", //ColumnTypeName,
							"99999", //""+ColumnDisplayLength,
							"0" //""+ColumnScale
						});
				}
					
				
				
				columnInfo.add(new String[]{
						"DOCUMENT", //ColumnName,
						"0", // ""+ColumnType,
						"JSON", //ColumnTypeName,
						"99999", //""+ColumnDisplayLength,
						"0" //""+ColumnScale
					});
				int colcount =columnInfo.size();
				
				String[] exportInfo=new String[]{
						export_catalog,
						export_schema,
						export_table,
						export_statement,
						""+colcount,
						""+export_tab_id
					};
				
				
				
				
				ArrayList<String[]> taskHeader=new ArrayList<String[]>();
				taskHeader.add(exportInfo);
				taskHeader.addAll(columnInfo);
				
				
				
				int counter_for_task=0;
				
				
				StringBuilder sbfield=new StringBuilder();
				
				FindIterable<Document> iterable =null;
				String parallel_condition=getParallelCondition(confDB,work_package_id);
				String filter_condition=getFilterCondition(confDB,work_package_id);
				
				
				if (parallel_condition.trim().length()>0 || filter_condition.trim().length()>0) {
					
					if (parallel_condition.trim().length()>0) 
						cLib.mylog(cLib.LOG_LEVEL_INFO,"Parallelism Filter Query "  + parallel_condition);
					
					if (filter_condition.trim().length()>0) 
						cLib.mylog(cLib.LOG_LEVEL_INFO,"Filter Query "  + filter_condition);


					BasicDBObject queryParalellism = (BasicDBObject) JSON.parse(parallel_condition);
					BasicDBObject queryFilter = (BasicDBObject) JSON.parse(filter_condition);
					
					iterable = mongoDB.getCollection(mongo_collection).find(queryParalellism).filter(queryFilter);
					
				}
				else 	
					iterable = mongoDB.getCollection(mongo_collection).find();
				
				
				for (Document doc:iterable) {
					
					read_count++;
					
					cLib.heartbeat(confDB, cLib.TABLE_TDM_MASTER, export_count, master_id);
					String[] row =new String[colcount];
					for (int p=0;p<pkArr.size();p++) {
						if (doc.containsKey(pkArr.get(p))) {
							try {
								sbfield.setLength(0);
								sbfield.append("");
								try {
									sbfield.append(doc.getObjectId(pkArr.get(p)).toString());
								} catch(Exception e) {
									sbfield.append(doc.getString(pkArr.get(p)).toString());
								}
								row[p]=sbfield.toString();
							} catch(Exception e) {
								e.printStackTrace();
							}
						}
					}
						
					row[colcount-1]=doc.toJson();


					exportArr.add(row);
					counter_for_task++;
					export_count++;
					
					//startCounterThread(false);
					
					//startCheckCancellationThread(false);
					if (this.cancellation_flag) {
						if (is_work_package_cancelled) {
							//update master_id of the workpackage to null 
							//to prevent the work package to be RENEWED
							resetMasterIdOfWorkPackage();
						}
						break;
					}
					
					if (read_count % 1000==0) 
						cLib.mylog(cLib.LOG_LEVEL_INFO, export_table+" ["+work_package_id+"] : " + read_count + " records read, " + export_count+ " exported. wpc ["+work_package_id+"], master ["+master_id+"], Heap : %" + cLib.heapUsedRate());
					
					/*
					if (read_count % 100000==0 && cLib.heapUsedRate()>70) {
						cLib.mylog(cLib.LOG_LEVEL_WARNING, "Garbage collection performing... ");
						System.gc();
					}
					*/
					
					if (counter_for_task>=this.REC_SIZE_PER_TASK) {
						addMaskingTask( export_count, exportArr, taskHeader, counter_for_task);
						counter_for_task=0;
						exportArr.clear();
					}
					
					if (export_count>=this.export_limit) {
						cLib.mylog(cLib.LOG_LEVEL_INFO, "Export limit reached . ");
						break;
					}
						
				} // while (rs.next())
				
				cLib.mylog(cLib.LOG_LEVEL_INFO, "Exported  " + export_count + " records.");
				
				addMaskingTask( export_count, exportArr,taskHeader,counter_for_task);
				exportArr.clear();
				
			} 
			catch (Exception ex) {
				export_error=true;
				
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@export");
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@Message: "+ex.getMessage());
				ex.printStackTrace();
				
			} 
			
			if (this.cancellation_flag || export_error) {
				renewWorkPackageByMasterId(this.master_id);
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "Export interrupted with error or cancellation.");
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "cancellation_flag   : "+this.cancellation_flag);
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "export_error        : "+export_error);
				
				System.gc();
				
				return 0;
			}
			else {
				cLib.mylog(cLib.LOG_LEVEL_INFO, "Export completed. "+ export_count + " records exported. ");
				
				cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, 0, cLib.WORK_PACKAGE_STATUS_MASKING);
				
				
				System.gc();
				
				return export_count;
			}

		}
		
	
	//*******************************************
	public long export(boolean mask_flag) {
		
		return export(
				this.export_limit, 
				this.REC_SIZE_PER_TASK, 
				this.fieldList,
				mask_flag);
		
	}

	
	//******************************************
	
	long export(
			long export_limit, 
			int records_in_task, 
			ArrayList<String> fieldList,
			boolean mask_flag
			) {
		long read_count=0;
		long export_count=0;
		
		
		
		
		if (appDB==null) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Application db is not connected");
			return -1;
		} else {
			if (this.db_type.length()==0) 
				this.db_type=this.cLib.getDbTypeByEnvId(this.confDB, this.env_id);
		}
		
		
		
		
		this.export_limit=export_limit;
		this.REC_SIZE_PER_TASK=records_in_task;
		this.fieldList=fieldList;
		this.to_be_masked=mask_flag;
		
		buildExportStatement(appDB);


		cLib.setCatalogForConnection(appDB,export_catalog);
		
		int par=1;
		while (true) {
			
			if (par>10) break;
			
			String parStr="${"+par+"}";
			
			if (!export_statement.contains(parStr)) {par++; continue;} 
			
			String[] arr=repeat_parameters.split("\\|::\\|");
			String par_val="";
			
			try{par_val=arr[par-1];} catch(Exception e) {}

			StringBuilder dummySb=new StringBuilder(export_statement);
			
			int start_i=dummySb.indexOf(parStr);
			
			dummySb.delete(start_i, start_i+parStr.length());
			dummySb.insert(start_i, par_val);
			
			export_statement=dummySb.toString();
			
		}
		
		
		String final_export_statement=export_statement;
		
		System.out.println("final_export_statement : "+final_export_statement);
		
		if (isExportByCtas) {
			final_export_statement=sqlStatementFromCtas(export_statement);
			PreparedStatement pstmtdummy=null;
			ResultSet rsdummy=null; 
			
			try {
				pstmtdummy=appDB.prepareStatement(final_export_statement, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);
				rsdummy = pstmtdummy.executeQuery();
				while(rsdummy.next()) {
					break;
				}
				
			} catch(Exception e) {
				System.out.println("**** exception test export SQL :  " + genLib.getStackTraceAsStringBuilder(e).toString());
				final_export_statement=export_statement;
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@test export SQL : Export Statement is restored to original one : " + export_statement);
			} finally {
				if (rsdummy!=null) try {rsdummy.close();} catch(Exception e) {}
				if (pstmtdummy!=null) try {pstmtdummy.close();} catch(Exception e) {}
			}

		}
			
		
		
		cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, master_id, cLib.WORK_PACKAGE_STATUS_EXPORTING);
		
		
		
		
		
		
		if (final_export_statement.length()==0) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Export statement is empty");
			return -1;
		}
		
		//-------------------------------
		cLib.mylog(cLib.LOG_LEVEL_INFO, "Exporting : " + final_export_statement);
		
		PreparedStatement pstmt=null;
		ResultSet rs=null;
		ResultSetMetaData rsmd=null;
		ArrayList<String[]> exportArr=new ArrayList<String[]>();
		
		
		boolean export_error=false;
		
		StringBuilder errorSb=new StringBuilder();
		
		try {
			
			
			if (db_type.equals(genLib.DB_TYPE_MSSQL)) 
				try {
					String isolation_level_sql="SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ";
					cLib.execSingleUpdateSQL(appDB, isolation_level_sql, new ArrayList<String[]>());
				} catch(Exception e) {
					e.printStackTrace();
				}
				
			if (db_type.equals(genLib.DB_TYPE_SYBASE)) 
				try {
					String isolation_level_sql="set transaction isolation level 0 ";
					cLib.execSingleUpdateSQL(appDB, isolation_level_sql, new ArrayList<String[]>());
				} catch(Exception e) {
					e.printStackTrace();
				}
			if (db_type.equals(genLib.DB_TYPE_MYSQL)) 
				try {
					String isolation_level_sql="SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ";
					cLib.execSingleUpdateSQL(appDB, isolation_level_sql, new ArrayList<String[]>());
				} catch(Exception e) {
					e.printStackTrace();
				}
			
			
			pstmt=appDB.prepareStatement(final_export_statement, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);
			
			
			try{pstmt.setFetchSize(1000);} catch(Exception e) {}
			
			rs = pstmt.executeQuery();
			rsmd = rs.getMetaData();
			int colcount = rsmd.getColumnCount();
			
			
			
			ArrayList<String[]> columnInfo=new ArrayList<String[]>();
			StringBuilder confSb=new StringBuilder();
			
			
			for (int c=0;c<colcount;c++) {
				
				String ColumnName=rsmd.getColumnName(c+1);
				int ColumnType=rsmd.getColumnType(c+1);
				String ColumnTypeName=rsmd.getColumnTypeName(c+1);
				int ColumnDisplayLength=rsmd.getPrecision(c+1);
				int ColumnScale=rsmd.getScale(c+1);
				
				columnInfo.add(new String[]{
							ColumnName,
							""+ColumnType,
							ColumnTypeName,
							""+ColumnDisplayLength,
							""+ColumnScale
						});
				

				if (c>0)  confSb.append("\n");
				
				
				
			}
			
			String[] exportInfo=new String[]{
					export_catalog,
					export_schema,
					export_table,
					export_statement,
					""+colcount,
					""+export_tab_id
				};
			
			ArrayList<String[]> taskHeader=new ArrayList<String[]>();

			taskHeader.add(exportInfo);
			taskHeader.addAll(columnInfo);
			
			int counter_for_task=0;
			
			Integer bucketid=-1;
			Integer bucket_counter=-1;
			Integer hashkey_for_group=-1;
			ArrayList<ArrayList<String[]>> bucketRecordArr=new ArrayList<ArrayList<String[]>>();
			
			StringBuilder sbfield=new StringBuilder();
			
			
			String sql="truncate table tdm_task_"+work_plan_id+"_"+work_package_id;
			cLib.execSingleUpdateSQL(confDB, sql, null);
			
			

			while (rs.next()) {
				
				read_count++;
				
				
				
				cLib.heartbeat(confDB, cLib.TABLE_TDM_MASTER, export_count, master_id);
				
				

				
				
				String[] row = new String[colcount];
				
				
				for (int c=0; c <colcount; c++) {
				
					row[c] = getExportedColumnValueAsString(sbfield, Integer.parseInt(columnInfo.get(c)[1]), rs, c);
					
					if (row[c]==null) {
						cLib.mylog(cLib.LOG_LEVEL_DANGER, "Export error since (row[c]==null)");
						
						export_error=true;
						break;
					}
					
				} // for int c=0
				
				if (is_group_mixing)  {
					
					hashkey_for_group=calcGroupHashKeyForRecord(row);
					
					bucketid=(Integer) hm.get("BID_"+hashkey_for_group);
					
					
					if (bucketid==null) {
						
						
						bucket_counter++;
						hm.put("BID_"+hashkey_for_group, bucket_counter);
						
						ArrayList<String[]> dummyArr=new ArrayList<String[]>();
						bucketRecordArr.add(dummyArr);
						
						bucketid=bucket_counter;
						
						cLib.mylog( cLib.LOG_LEVEL_INFO, "New bucket Added  : " + bucketid);
					}
					
					
					bucketRecordArr.get(bucketid).add(row);
					
					if (bucketRecordArr.get(bucketid).size()>=this.REC_SIZE_PER_TASK) {
						counter_for_task=this.REC_SIZE_PER_TASK;
						exportArr.clear();
						exportArr.addAll(bucketRecordArr.get(bucketid).subList(0, counter_for_task)); //counter_for_task excluded
						int arr_size=bucketRecordArr.get(bucketid).size();
						
						bucketRecordArr.set(bucketid, 
								new ArrayList<String[]>(bucketRecordArr.get(bucketid).subList(counter_for_task, arr_size))
								);
						export_count+=exportArr.size();
					}
				}
				else {
					exportArr.add(row);
					counter_for_task++;
					export_count++;
				}

				if (read_count % 10000==0) 
					cLib.mylog(cLib.LOG_LEVEL_INFO, export_table+" : " + read_count + " records read, " + export_count+ " exported. wpc ["+work_package_id+"], master ["+master_id+"], Heap : %" + cLib.heapUsedRate());
				
				if (this.cancellation_flag) {
					if (is_work_package_cancelled) {
						//update master_id of the workpackage to null 
						//to prevent the work package to be RENEWED
						resetMasterIdOfWorkPackage();
					}
					
					break;
				}
				
				
				
				
				if (counter_for_task>=this.REC_SIZE_PER_TASK) {
					addMaskingTask( export_count, exportArr, taskHeader, counter_for_task);
					counter_for_task=0;
					exportArr.clear();
				}
				
				if (export_count>=this.export_limit) {
					cLib.mylog(cLib.LOG_LEVEL_INFO, "Export limit reached . ");
					break;
				}
					
				
			} // while (rs.next())
			
			
		
			cLib.mylog(cLib.LOG_LEVEL_INFO, "Exported  " + export_count + " records.");
			
			if (is_group_mixing) {
				for (int i=0;i<bucketRecordArr.size();i++) {
					
					exportArr.clear();
					exportArr.addAll(bucketRecordArr.get(i));
					export_count+=exportArr.size();
					counter_for_task=exportArr.size();
					
					addMaskingTask( export_count, exportArr,taskHeader,counter_for_task);
					
					cLib.heartbeat(confDB, cLib.TABLE_TDM_MASTER, export_count, master_id);
					
				}
				
				bucketRecordArr.clear();
				
			} else {
				addMaskingTask( export_count, exportArr,taskHeader,counter_for_task);
				exportArr.clear();
			}
			
			
			
			
		} catch (SQLException sqle) {
			export_error=true;
			
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@export");
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@export final_export_statement : "+final_export_statement);
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@errorCode : "+sqle.getErrorCode());
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@sqlState: "+sqle.getSQLState());
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@Message: "+sqle.getMessage());
			sqle.printStackTrace();
			
			errorSb.append(genLib.getStackTraceAsStringBuilder(sqle).toString());
			
		}  catch (Exception ex) {
			export_error=true;
			
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@export");
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@export final_export_statement : "+final_export_statement);
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@Message: "+genLib.getStackTraceAsStringBuilder(ex).toString());
			ex.printStackTrace();
			
			errorSb.append(genLib.getStackTraceAsStringBuilder(ex).toString());
			
		} 
		finally {
			try {pstmt.close();} catch(Exception e) {}
			try {rs.close();} catch(Exception e) {}
		} 
		
		//if (this.cancellation_flag || export_error) {
		if (this.cancellation_flag) {
			
			renewWorkPackageByMasterId(this.master_id);
			
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Export interrupted with error or cancellation.");
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "cancellation_flag   : "+this.cancellation_flag);
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "export_error        : "+export_error);
			
			System.gc();
			
			return 0;
		} else if (export_error) {
			cLib.mylog(cLib.LOG_LEVEL_INFO, "Export failed. "+ export_count + " records exported. ");
			
			
			
			int execution_order=cLib.getExecutionOrderOfWpc(confDB, work_package_id); 
			
			if (execution_order>0 && execution_order<3) {
				cLib.setExecutionOrderOfWpc(confDB, work_package_id,execution_order+1);
				cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, master_id, cLib.WORK_PACKAGE_STATUS_NEW);

			} 
			else {
				cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, master_id, cLib.WORK_PACKAGE_STATUS_FAILED);
				
				cLib.setworkPackageError(confDB, work_plan_id, work_package_id, errorSb.toString());
			}
			
			
			return -1;
		}
		else {
			cLib.mylog(cLib.LOG_LEVEL_INFO, "Export completed. "+ export_count + " records exported. ");
			
			
			cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, master_id, cLib.WORK_PACKAGE_STATUS_MASKING);
			
			
			System.gc();
			
			return export_count;
		}

	}


	
	//************************************
	void resetMasterIdOfWorkPackage() {
		String sql="update tdm_work_package set master_id=null where id=? and master_id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",""+work_package_id});
		bindlist.add(new String[]{"INTEGER",""+master_id});
		cLib.execSingleUpdateSQL(confDB, sql, bindlist);
	}
	
	//************************************
	int calcGroupHashKeyForRecord(String[] rec) {
		StringBuilder sb=new StringBuilder();
		for (int i=0;i<rec.length;i++) {
			if(field_mask_rules.get(i).equals(MASK_RULE_GROUP)) {
				sb.append(rec[i]);
				sb.append("_");
			}
		}
		
		
		return sb.toString().hashCode();
	}
	
	//*************************************
	String getExportedColumnValueAsString(StringBuilder sbfield, int colType, ResultSet rs, int c) {
		
		sbfield.setLength(0);
		
		try {
					
			if (colType==91 || colType==92 || colType==93) {
				Date d = rs.getDate(c+1);
				if (d == null)
					sbfield.append("");
				else
					sbfield.append(new SimpleDateFormat(genLib.DEFAULT_DATE_FORMAT).format(d));
			} 
			else if (colType==Types.BLOB || colType==Types.LONGVARBINARY || colType==Types.VARBINARY 
						|| colType==Types.OTHER || colType==Types.ARRAY || colType==Types.STRUCT 
						|| colType==Types.JAVA_OBJECT ) {
				
				
				byte[] ablob=rs.getBytes(c+1);
				sbfield.setLength(0);
				for(byte b: ablob) 
					sbfield.append(String.format("%02x", b&0xff));
			}
			else 
				sbfield.append(rs.getString(c+1));
			
			if (rs.wasNull() && sbfield.toString().equals("null")) return "";
			
			return sbfield.toString();
			
		} catch (Exception e) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@getExportedColumnValueAsString COL["+c+"] : " + field_names.get(c));
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@getExportedColumnValueAsString MSG : " + e.getMessage());
			e.printStackTrace();
			return null;
		}
		
	}
	
	//**************************************
	void renewWorkPackageByMasterId(int master_id) {
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		String sql="select id , work_plan_id from tdm_work_package where master_id=?";
		bindlist.add(new String[]{"INTEGER",""+master_id});
		
		ArrayList<String[]> arr=cLib.getDbArray(confDB, sql, Integer.MAX_VALUE, bindlist);
		
		if (arr!=null && arr.size()>0)
			for (int i=0;i<arr.size();i++) {
				int renewing_work_package_id=Integer.parseInt(arr.get(i)[0]);
				int renewing_work_plan_id=Integer.parseInt(arr.get(i)[1]);
				renewWorkPackage(renewing_work_plan_id, renewing_work_package_id);
			}
		
	}
	
	
	//*********************************************************
	private void renewWorkPackage(int renewing_work_plan_id,int renewing_work_pack_id) {

		cLib.mylog(cLib.LOG_LEVEL_WARNING,"Renewing work package : "+renewing_work_pack_id);
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String sql="";
		
		
		sql="update tdm_work_package set status='NEW', master_id=null where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+renewing_work_pack_id});
		cLib.execSingleUpdateSQL(confDB, sql, bindlist);
		
	}


	//**************************************
	int getAllThreadCount() {
		return getMaskingThreadCount();
	}

	//-----------------------------------------------------
	int getCheckCancelThreadCount() {
		
		if (System.currentTimeMillis()> this.last_check_cancel_ts+CHECK_CANCEL_INTERVAL*5)
			return 0;
		
		int ret1=checkCancelThreadGroup.activeCount();
		
		return ret1;
	}
	
	//-----------------------------------------------------

	int COUNTER_TIMEOUT=5000;

	
	
	
	//--------------------------------------------------
	int active_masking_thread_count=0;
	
	synchronized void changeActiveMaskingThreadCount(int what) {
		active_masking_thread_count+=what;
	}
	
	int getMaskingThreadCount() {
		
		//return maskerThreadGroup.activeCount();
		
		return active_masking_thread_count;

		
	}
	
	
	
//------------------------------------------------------------------------
void startCounterThread(boolean force) {
	//cLib.mylog(cLib.LOG_LEVEL_DEBUG, "@startCounterThread");
	//if (next_counter_ts>System.currentTimeMillis() && !force) {
	//	cLib.mylog(cLib.LOG_LEVEL_DEBUG, "@next time...");


	//	return;
	//}
	//if (getCountingThreadCount()>0 && !force) {
	//	System.out.println("... counting is already running..."+ work_package_id);
	//	cLib.mylog(cLib.LOG_LEVEL_DEBUG, "@counting is already running...");
	//	return;
	//}
	
	//next_counter_ts=System.currentTimeMillis()+COUNTER_INTERVAL;
	
	String thread_name="COUNTING_THREAD_"+System.currentTimeMillis();
	try {
		Thread thread=new Thread(counterThreadGroup, new countingThread(this, this.work_plan_id, this.work_package_id),thread_name);
		thread.start();
	} catch(Exception e) {
		cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@countingThread : "+ e.getMessage());
		e.printStackTrace();
	}
	
}

//------------------------------------------------------------------------
void startCheckCancellationThread(boolean force) {
	//if (next_check_cancel_ts>System.currentTimeMillis() && !force) return;
	//if (getCheckCancelThreadCount()>0 && !force) return;
	//next_check_cancel_ts=System.currentTimeMillis()+CHECK_CANCEL_INTERVAL;
	String thread_name="CHECK_CANCEL_THREAD_"+System.currentTimeMillis();
	try {
		Thread thread=new Thread(checkCancelThreadGroup, new checkCancelForMaskingThread(this, this.master_id, this.work_package_id),thread_name);
		thread.start();
	} catch(Exception e) {
		cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@startCheckCancellationThread : "+ e.getMessage());
		e.printStackTrace();
	}
	
}


	//------------------------------------------------------------------------
	void startLongHeartBeatThread(String heartbeat_key) {
		String thread_name="HEARTBEAT_THREAD_"+heartbeat_key;
		try {
			Thread thread=new Thread(heartbeatThreadGroup, 
					new heartbeatThread(this, heartbeat_key),thread_name);
			thread.start();
		} catch(Exception e) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@startLongHeartBeatThread : "+ e.getMessage());
			e.printStackTrace();
		}
		
	}

	//------------------------------------------------------------------------
	boolean startMaskerThread(ArrayList<Integer> globalTaskIdArr, int target_db_id) {
		
		ArrayList<Integer> taskIdArr=new ArrayList<Integer>();
		taskIdArr.addAll(globalTaskIdArr);
		
		
		String thread_name="MASKING_THREAD_"+System.currentTimeMillis();
		
		try {
			Thread thread=new Thread(
						maskerThreadGroup, 
						new maskingThread(this, target_db_id, this.work_plan_id, this.work_package_id, taskIdArr),
						thread_name
					);
			thread.start();
		} catch(Exception e) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@startMaskerThread : "+ e.getMessage());
			e.printStackTrace();
			return false;
		}
		
		return true;
	}
	

	 
	//*****************************************
	
	ArrayList<ArrayList<String[]>> globalTaskArr=new ArrayList<ArrayList<String[]>>();
	//ArrayList<byte[]> globalTaskArr=new ArrayList<byte[]>();
	int MAX_GLOBAL_TASK_ARR_SIZE=500;
	ConcurrentHashMap<Integer,Integer> hmArrStatus = new ConcurrentHashMap<Integer,Integer>();
	ConcurrentHashMap<Integer,Long> hmTaskId = new ConcurrentHashMap<Integer,Long>();
	ConcurrentHashMap<Integer,Long> hmTaskAssignTs = new ConcurrentHashMap<Integer,Long>();
	ConcurrentHashMap<Integer,Integer> hmTaskSize = new ConcurrentHashMap<Integer,Integer>();
	ConcurrentHashMap<Integer,Long> hmTaskStartTs = new ConcurrentHashMap<Integer,Long>();
	ConcurrentHashMap<Integer,Boolean> hmTaskFromConfDb = new ConcurrentHashMap<Integer,Boolean>();
	
	
	ConcurrentHashMap<Long,Boolean> hmInMemoryTaskList = new ConcurrentHashMap<Long,Boolean>();
	
	

	
	static final int ARR_STAT_FREE=0;
	static final int ARR_STAT_FILLED=1;
	static final int ARR_STAT_ASSIGNED=2;
	static final int ARR_STAT_RUNNING=3;

	
	void addMaskingTask(
			long task_id, 
			ArrayList<String[]> exportArr, 
			ArrayList<String[]> taskHeader, 
			int rec_count_in_task) {
		
		
		if (exportArr.size()==0) {
			cLib.mylog(cLib.LOG_LEVEL_INFO, "Task arraylist is empty");
			return;
		}
		
		ArrayList<String[]> arr=new ArrayList<String[]>();
		arr.addAll(taskHeader);
		arr.addAll(exportArr);
		
		

		
		int arr_index=getAvailableGlobalArrId();
		if (arr_index>-1) {
			addMaskingTaskToGlobalArr(task_id,arr_index,arr,rec_count_in_task, false);
		} 
		else {
			
			
			
			if (globalTaskArr.size()<=MAX_GLOBAL_TASK_ARR_SIZE) {
				addMaskingTaskToGlobalArr(task_id, -1, arr, rec_count_in_task, false);
				
				//stage="Append";
			} 
			else {
				
				if (cLib.heapUsedRate()<=60) {
					
					MAX_GLOBAL_TASK_ARR_SIZE+=10;
					cLib.mylog(cLib.LOG_LEVEL_INFO, "Incrementing MAX_GLOBAL_TASK_ARR_SIZE : " + MAX_GLOBAL_TASK_ARR_SIZE);
					
					addMaskingTaskToGlobalArr(task_id,-1,arr,rec_count_in_task, false);
					
					//stage="Extend&Append";
					
				}
				else {
					cLib.mylog(cLib.LOG_LEVEL_INFO, "Max Global Task Arr Size : "+MAX_GLOBAL_TASK_ARR_SIZE + " reached. Persisting to task table.");
					writeTaskRecord(confDB, work_plan_id, work_package_id, task_id, arr, rec_count_in_task, cLib.TASK_STATUS_NEW,true);
				}
			}
			
			
		}
		


		

	}
	
	//---------------------------------------------------------------------------------------------
	synchronized void addMaskingTaskToGlobalArr(
			long task_id, 
			int arr_index, 
			ArrayList<String[]> arr, 
			int rec_count_in_task,
			boolean isLoadedFromConfDb) {
		
		if (hmInMemoryTaskList.containsKey(task_id)) {
			//System.out.println("task_id "+task_id+" is already in memory...");
			return;
		}
		
		if (arr_index==-1) {
			
			int arr_index_new=globalTaskArr.size();
			
			globalTaskArr.add(arr);
			hmArrStatus.put(arr_index_new, ARR_STAT_FILLED);
			hmTaskAssignTs.put(arr_index_new, 0L);
			hmTaskId.put(arr_index_new, task_id);
			hmTaskSize.put(arr_index_new, rec_count_in_task);
			hmTaskStartTs.put(arr_index_new, System.currentTimeMillis());


			
			hmTaskFromConfDb.put(arr_index_new, isLoadedFromConfDb);
		}
		else
		{
			globalTaskArr.set(arr_index, arr);
			hmArrStatus.put(arr_index, ARR_STAT_FILLED);
			hmTaskAssignTs.put(arr_index, 0L);
			hmTaskId.put(arr_index, task_id);
			hmTaskSize.put(arr_index, rec_count_in_task);
			hmTaskStartTs.put(arr_index, System.currentTimeMillis());

		
			hmTaskFromConfDb.put(arr_index, isLoadedFromConfDb);
		}
		
		
		hmInMemoryTaskList.put(task_id, true);
	}
	
	//*****************************************************
	synchronized int getAvailableGlobalArrId() {
		int arr_index=-1;
 		
		for (int i=0;i<globalTaskArr.size();i++) {
			if (hmArrStatus.get(i)==ARR_STAT_FREE || globalTaskArr.get(i)==null) {
				arr_index=i;
				break;
			}
		}
		
		return arr_index;
	}
	//*****************************************************
	long next_load_persisted_task_ts=0;
	static final int LOAD_PERSISTED_TASKS_INTERVAL=10000;
	
	int loadPersistedTasks(Connection conn, boolean force) {

		//ora-01555 undo hatasini onlemek icin
		//paralel ve gruplularda
		//export bitmeden update yapmiyoruz, tasklari persist ediyorduk.
		//bu persist edilen tasklar export bitene kadar tekrar yuklenmesin
		//boylece task already exists hatasi almiyoruz. 		
		if (!force)
			if (!isExportImportSameTime &&  (is_paralleled_by_mod || is_group_mixing) ) {
				if (!isExportingFinished || !isExportsOfOtherWorkPackagesFinished) return 0;
			}

		if (System.currentTimeMillis()<next_load_persisted_task_ts) return 0;
		next_load_persisted_task_ts=System.currentTimeMillis()+LOAD_PERSISTED_TASKS_INTERVAL;
		
		int loaded_task_count=0;


		
		
		int arr_index=-1;
		
		String task_table_name="tdm_task_"+work_plan_id+"_"+work_package_id;
		
		String sql ="select id, all_count from "+task_table_name+
				" where status='NEW'  "+
				" and date_add(last_activity_date, interval  5 SECOND)<now() "+ //60 saniye gecmeden tekrar yuklemesin
				"  limit 0,1000 ";


	 	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	 	
	 	ArrayList<String[]> taskToRetryArr=cLib.getDbArray(conn, sql, Integer.MAX_VALUE, bindlist);
	 	
	 	//System.out.println("loadPersistedTasks. loaded task count : "+taskToRetryArr.size());
	 	if (taskToRetryArr==null || taskToRetryArr.size()==0) return 0;


	 	
	 	long task_id=0;
	 	int rec_count_in_task=0;
	 	
	 	
	 	for (int t=0;t<taskToRetryArr.size();t++) {
	 		
	 		try{task_id=Long.parseLong(taskToRetryArr.get(t)[0]);} catch(Exception e) { continue; }
			try{rec_count_in_task=Integer.parseInt(taskToRetryArr.get(t)[1]);} catch(Exception e) { continue;}
		
			
			ArrayList<String[]> taskArr=genLib.byteArrToArrayList(genLib.uncompress(getInfoBin(conn,task_table_name,task_id,"task_info_zipped")));
			
			if (taskArr==null) {
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "! NULL_TASK_CONTENT. Task id :  "+task_id+", work_package_id : "+work_package_id);
				cLib.setTaskStatus(conn, work_plan_id, work_package_id, task_id, cLib.TASK_STATUS_FAILED, 0);
				continue;
			}

			
	 		arr_index=getAvailableGlobalArrId();
						
	 		if (arr_index>-1) 
				addMaskingTaskToGlobalArr(task_id,arr_index,taskArr,rec_count_in_task, true);
			else {
				
				if (globalTaskArr.size()<=MAX_GLOBAL_TASK_ARR_SIZE) 
					addMaskingTaskToGlobalArr(task_id, -1, taskArr, rec_count_in_task, true);
				else {
					
					if (cLib.heapUsedRate()<=60) {
						
						MAX_GLOBAL_TASK_ARR_SIZE+=10;
						cLib.mylog(cLib.LOG_LEVEL_INFO, "Incrementing MAX_GLOBAL_TASK_ARR_SIZE : " + MAX_GLOBAL_TASK_ARR_SIZE);
						
						addMaskingTaskToGlobalArr(task_id,-1,taskArr,rec_count_in_task, true);
												
					}
					else 
						break;
				
				}
			}
			
			
			
			
			loaded_task_count++;
			
	 	} //for (int t=0;t<taskToRetryArr.size
		

		
		return loaded_task_count;
	}
	
	
	
	
	//*****************************************************
	
	long next_load_failed_task_ts=0;
	static final int LOAD_FAILED_TASKS_INTERVAL=10000;
	
	
	
	int loadTasksToRetry(Connection conn) {

		//ora-01555 undo hatasini onlemek icin
		//paralel ve gruplularda
		//export bitmeden update yapmiyoruz, tasklari persist ediyorduk.
		//bu persist edilen tasklar export bitene kadar tekrar yuklenmesin
		//boylece task already exists hatasi almiyoruz. 		
		if (!isExportImportSameTime &&  (is_paralleled_by_mod || is_group_mixing) ) {
			if (!isExportingFinished || !isExportsOfOtherWorkPackagesFinished) return 0;
		}
		
		if (System.currentTimeMillis()<next_load_failed_task_ts) return 0;
		next_load_failed_task_ts=System.currentTimeMillis()+LOAD_FAILED_TASKS_INTERVAL;

		int loaded_task_count=0;


		
		
		int arr_index=-1;
		
		String task_table_name="tdm_task_"+work_plan_id+"_"+work_package_id;
		


		String sql="select id, all_count, retry_count "+
					"  from "+task_table_name+
					" where status='RETRY' "+
					" and date_add(last_activity_date, interval  30 SECOND)<now() "+ //60 saniye gecmeden tekrar yuklemesin
					" limit 0,1000";
		
	 	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	 	
	 	ArrayList<String[]> taskToRetryArr=cLib.getDbArray(conn, sql, Integer.MAX_VALUE, bindlist);
	 	
	 	
	 	if (taskToRetryArr==null || taskToRetryArr.size()==0) return 0;
	 	
	 	

	 	long task_id=0;
	 	int rec_count_in_task=0;
	 	int retry_count=0;
	 	
	 	for (int t=0;t<taskToRetryArr.size();t++) {
	 		
	 		try{task_id=Long.parseLong(taskToRetryArr.get(t)[0]);} catch(Exception e) { continue; }
			try{rec_count_in_task=Integer.parseInt(taskToRetryArr.get(t)[1]);} catch(Exception e) { continue;}
			try{retry_count=Integer.parseInt(taskToRetryArr.get(t)[2]);} catch(Exception e) { continue;}
			
			if (retry_count>=cLib.MAX_RETRY_COUNT) {
				cLib.setTaskStatus(conn, work_plan_id, work_package_id, task_id, cLib.TASK_STATUS_FAILED, 0);
				continue;
			}
		
			cLib.IncreaseRetryCount(conn, task_table_name, task_id);
			
			ArrayList<String[]> taskArr=genLib.byteArrToArrayList(genLib.uncompress(getInfoBin(conn,task_table_name,task_id,"task_info_zipped")));
			
			if (taskArr==null) {
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "! NULL_TASK_CONTENT. Task id :  "+task_id+", work_package_id : "+work_package_id);
				cLib.setTaskStatus(conn, work_plan_id, work_package_id, task_id, cLib.TASK_STATUS_FAILED, 0);
				continue;
			}
	 		
			
			
	 		arr_index=getAvailableGlobalArrId();
						
	 		if (arr_index>-1) 
				addMaskingTaskToGlobalArr(task_id,arr_index,taskArr,rec_count_in_task, true);
			else {
				
				if (globalTaskArr.size()<=MAX_GLOBAL_TASK_ARR_SIZE) 
					addMaskingTaskToGlobalArr(task_id, -1, taskArr, rec_count_in_task, true);
				else {
					
					if (cLib.heapUsedRate()<=60) {
						
						MAX_GLOBAL_TASK_ARR_SIZE+=10;
						cLib.mylog(cLib.LOG_LEVEL_INFO, "Incrementing MAX_GLOBAL_TASK_ARR_SIZE : " + MAX_GLOBAL_TASK_ARR_SIZE);
						
						addMaskingTaskToGlobalArr(task_id,-1,taskArr,rec_count_in_task, true);
												
					}
					else 
						break;
					
				}
			}
			
	 		cLib.setTaskStatus(conn, work_plan_id, work_package_id, task_id, cLib.TASK_STATUS_TOUCH, 0);
			
			addMaskingTaskToGlobalArr(task_id,arr_index,taskArr,rec_count_in_task, true);
			
			loaded_task_count++;
			
	 	} //for (int t=0;t<taskToRetryArr.size
		

		
		return loaded_task_count;
	}
	
	//***********************************************
	public byte[] getInfoBin(Connection conn, String table_name, long p_id,String field_name) {

		byte[] ret1=null;
		String sql="select "+field_name+" from "+ table_name + " where id=?  limit 0,1 ";
		
		PreparedStatement pstmtConf = null;
		ResultSet rsetConf = null;
		
		try {
			
			
			pstmtConf = conn.prepareStatement(sql);
			pstmtConf.setLong(1, p_id);
			
			rsetConf = pstmtConf.executeQuery();
			
			while (rsetConf.next()) {
				try {
				ret1=rsetConf.getBytes(1); 
				} catch(Exception e) {ret1=null;}
				break;
			}
			
		} catch (Exception ignore) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "getDbArrayConf Exception : " + ignore.getMessage());
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
	
	//*****************************************
	boolean isTaskAlreadyFinished(
			Connection conn,
			int work_plan_id, 
			int work_package_id, 
			long task_id
			) {
	
		String task_table_name="tdm_task_"+work_plan_id+"_"+work_package_id;
		
		String sql ="";

	 	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	 	bindlist.add(new String[]{"LONG",""+task_id});
	 	
	 	sql = "select 1 from "+task_table_name+ " where id=? and status='FINISHED'  limit 0,1";
	 	
	 	ArrayList<String[]> dummy=cLib.getDbArray(confDB, sql, 1, bindlist);
	 	
	 	if (dummy!=null && dummy.size()==1) return true;
	 	
	 	return false;
	}
	
	//******************************************
	void persistUnfinishedTasks(Connection conn) {
		long task_id=0;
		int task_status=0;
		int task_record_count=0;
		
		int counter=0;
		
		for (int i=0;i<globalTaskArr.size();i++) {
			task_status=hmArrStatus.get(i);
			
			cLib.heartbeat(conn, cLib.TABLE_TDM_MASTER,0,master_id);

			if (task_status==ARR_STAT_FREE) continue;
			if (globalTaskArr.get(i)==null) continue;
			
			counter++;
			
			if (counter % 100==0) 
				cLib.mylog(cLib.LOG_LEVEL_INFO, "persistUnfinishedTasks : "+counter+" tasks persisted.");
			
			task_id=hmTaskId.get(i);
			task_record_count=hmTaskSize.get(i);
			
			writeTaskRecord(
					conn, 
					work_plan_id, 
					work_package_id, 
					task_id, 
					globalTaskArr.get(i), 
					task_record_count, 
					cLib.TASK_STATUS_FAILED, 
					true
					);
			
		}
		
		cLib.mylog(cLib.LOG_LEVEL_INFO, "persistUnfinishedTasks : "+counter+" tasks persisted.");
		
	}
	
	//******************************************
	void writeTaskRecord(
				Connection conn, 
				int work_plan_id, 
				int work_package_id, 
				long task_id, 
				ArrayList<String[]> taskinfo,
				//int global_task_id,
				int task_record_count,
				String initial_status,
				boolean persist_task_info
				) {
		 	

			
			
			String task_table_name="tdm_task_"+work_plan_id+"_"+work_package_id;
			
			String sql ="";

		 	ArrayList<String[]> bindlist=new ArrayList<String[]>();
		 	
		 	
		 	
		 	bindlist.add(new String[]{"LONG",""+task_id});
		 	
		 	sql = "select 1 from "+task_table_name+ " where id=?  limit 0,1";
		 	
		 	ArrayList<String[]> dummy=cLib.getDbArray(confDB, sql, 1, bindlist);
		 	
		 	if (dummy.size()==1) {
		 		cLib.mylog(cLib.LOG_LEVEL_DEBUG, "!!!  Task is already exists : "+task_id);
		 		return;
		 	}
		 	
		 	sql = "insert into "+ task_table_name +
		 					" (id, task_name, task_order, work_plan_id, work_package_id, status, all_count, retry_count, create_date, last_activity_date) " + 
		 					" values (?, ?, ?, ?, ?, ?, ?, 0, now(), now())";
		 	
		 	bindlist.clear();
		 	bindlist.add(new String[]{"INTEGER",""+task_id});
		 	bindlist.add(new String[]{"STRING","MASK_"+task_id});
		 	bindlist.add(new String[]{"INTEGER",""+task_id});
		 	bindlist.add(new String[]{"INTEGER",""+work_plan_id});
			bindlist.add(new String[]{"INTEGER",""+work_package_id});
			bindlist.add(new String[]{"STRING",initial_status});
			bindlist.add(new String[]{"INTEGER",""+task_record_count});
		 	
			
			
			boolean is_ok=cLib.execSingleUpdateSQL(conn, sql, bindlist);
			if (!is_ok) cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@execSingleUpdateSQL Pid : "+p_id);
		
		 	
			//the first 1M will anycase be persisted with its array
			if ((persist_task_info || task_id<=1000000 ))
				cLib.setBinInfo(conn, task_table_name, "id", task_id, "task_info_zipped", genLib.compress(genLib.arrayListToByte(taskinfo)) );
		}
	
	
	//------------------------------------------------------------------------
	void startDispatcherThread() {
		int active_thread_count=dispatcherThreadGroup.activeCount();
		if (active_thread_count>0) return;

		hm.put("DISPATCHER_THREAD_KEY", true);
		
		
		
		String thread_name="DISPATCHER_THREAD";
		
		try {
			Thread thread=new Thread(dispatcherThreadGroup, 
					new dispatcherThread(this, "DISPATCHER_THREAD_KEY"),thread_name);
			thread.start();
		} catch(Exception e) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@startDispatcherThread : "+ e.getMessage());
			e.printStackTrace();
		}
		
	}
	
	
	//*****************************************
	
	void stopDispatcherThread() {
		
		hm.remove("DISPATCHER_THREAD_KEY");
		cLib.mylog(cLib.LOG_LEVEL_DANGER, "Stopping Dispatcher...");
		long start_ts=System.currentTimeMillis();
		while(true) {
			int active_thread=dispatcherThreadGroup.activeCount();
			if (active_thread==0) break;
			if (System.currentTimeMillis()-start_ts>10000) break;
			try{Thread.sleep(1000);} catch(Exception e) {}
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "waiting...");
			cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, master_id, cLib.WORK_PACKAGE_STATUS_TOUCH);
		}
	
		cLib.mylog(cLib.LOG_LEVEL_DANGER, "Stopping Dispatcher. Done");
		
	}
	
	//*****************************************
	
	int last_global_arr_id=0;
	int MAX_TASK_ASSIGNMENT=5;
	
	
	int dispatchGlobalTaskArr(Connection conn) {
		
		
		long start_ts=System.currentTimeMillis();
		
		
		
		int all_dispatched_task_count=0;
		
		
		
		
		while (true) {
			int masking_thread_count=getMaskingThreadCount();
			
			
			if (masking_thread_count>=MAX_MASKER_THREAD_COUNT) {
				cLib.mylog(cLib.LOG_LEVEL_WARNING, "No Available maskingThread for WPC  : "+work_package_id);
				return all_dispatched_task_count ;
			}
			
			int target_db_id=getIddleTargetDbConnectionId(conn);
			
			if (target_db_id==-1) {
				cLib.mylog(cLib.LOG_LEVEL_WARNING, "No Available target DB for WPC  : "+work_package_id);
				return all_dispatched_task_count ;
				
			}
			
			ArrayList<Integer> globalTaskIdArr=new ArrayList<Integer>();

			int assigned_task=0;

			
			
			if (last_global_arr_id>=globalTaskArr.size()) last_global_arr_id=0;
			
			for (int i=last_global_arr_id;i<globalTaskArr.size();i++) {
				
				if (hmArrStatus.get(i)!=ARR_STAT_FILLED) continue;
					
				if (globalTaskArr.get(i)==null) {
					hmArrStatus.put(i, ARR_STAT_FREE);
					continue;
				}
				
				if (hmTaskStartTs.get(i)>System.currentTimeMillis())  continue;
				
				globalTaskIdArr.add(i);
				
				
				hmArrStatus.put(i, ARR_STAT_ASSIGNED);
				hmTaskAssignTs.put(i, System.currentTimeMillis());
				
				assigned_task++;
				all_dispatched_task_count++;
				
				if (assigned_task>=MAX_TASK_ASSIGNMENT) break;
					
				
			} // for 
			
			if (globalTaskIdArr.size()>0) {
				
				MAX_TASK_ASSIGNMENT++;
				if (MAX_TASK_ASSIGNMENT>50) MAX_TASK_ASSIGNMENT=50;
				
				boolean is_thread_ok=startMaskerThread(globalTaskIdArr,target_db_id);

				if (!is_thread_ok) {
					all_dispatched_task_count-=globalTaskIdArr.size();
					cLib.mylog(cLib.LOG_LEVEL_DANGER, "Thread Not Ok ");
					for (int t=0;t<globalTaskIdArr.size();t++) 
						hmArrStatus.put(t, ARR_STAT_FILLED);
					
					appDBForUpdateState.set(target_db_id, TARGET_DB_STATE_IDDLE);
					appDBForUpdateLeasedTime.set(target_db_id, (long) 0);
				}
				else
					cLib.mylog(cLib.LOG_LEVEL_INFO, ""+globalTaskIdArr.size()+" task assigned to a masking thread.");
				
			} else {
				
				MAX_TASK_ASSIGNMENT--;
				if (MAX_TASK_ASSIGNMENT<5) MAX_TASK_ASSIGNMENT=5;
				
				appDBForUpdateState.set(target_db_id, TARGET_DB_STATE_IDDLE);
				appDBForUpdateLeasedTime.set(target_db_id, (long) 0);
				break;
			}
				
		} //while true
		
		return all_dispatched_task_count;
				
	}
	
	
	//*********************************************************************
	static final int TARGET_DB_STATE_IDDLE=0;
	static final int TARGET_DB_STATE_LEASED=1;

	boolean last_connect_attempt_success=true;
	long last_connection_fail_ts=0;

	synchronized int getIddleTargetDbConnectionId(Connection conn) {
		int ret1=-1;


		for (int i=0;i<appDBForUpdateState.size();i++) {
			int state=appDBForUpdateState.get(i);
			long leased_time=appDBForUpdateLeasedTime.get(i);


			if (state==TARGET_DB_STATE_IDDLE) {
				ret1=i;
				break;
			}
			
			if (System.currentTimeMillis()>leased_time+TIMEOUT_FOR_STALLED_TASK) {
				ret1=i;
				break;
			}
		}
		
		
		//check if connection retry timeout passed
		if (last_connect_attempt_success && System.currentTimeMillis()>last_connection_fail_ts+TIMEOUT_FOR_STALLED_TASK) {
			last_connect_attempt_success=true;
		}
		
		if (
			ret1==-1 
			&& appDBForUpdateState.size()<MAX_MASKER_THREAD_COUNT 
			&& last_connect_attempt_success
				) {
			
			last_connect_attempt_success=false;
			last_connection_fail_ts=System.currentTimeMillis();
			
			appDBForUpdate.add(cLib.getApplicationDbConnectionByDBId(conn,env_id));
			
			if (db_type.equals(genLib.DB_TYPE_SYBASE)) {
				String isolation_level_sql="set transaction isolation level 0 ";
				cLib.execSingleUpdateSQL(appDBForUpdate.get(appDBForUpdate.size()-1), isolation_level_sql, new ArrayList<String[]>());
			}
			
			
			if (appDBForUpdate.get(appDBForUpdate.size()-1)!=null) {

				String conf_driver=genLib.nvl(genLib.getEnvValue("CONFIG_DRIVER"),"<null>");
				String conf_connstr=genLib.nvl(genLib.getEnvValue("CONFIG_CONNSTR"),"<null>");
				String conf_username=genLib.nvl(genLib.getEnvValue("CONFIG_USERNAME"),"<null>");
				String conf_password=genLib.nvl(genLib.getEnvValue("CONFIG_PASSWORD"),"<null>");
				
				
				confDBForUpdate.add(cLib.getDBConnection(conf_connstr, conf_driver, conf_username, conf_password, 1));

				if (confDBForUpdate.get(confDBForUpdate.size()-1)!=null) {
					
					ret1=appDBForUpdate.size()-1;
					
					cLib.setCatalogForConnection(appDBForUpdate.get(appDBForUpdate.size()-1), export_catalog);


					try {appDBForUpdate.get(appDBForUpdate.size()-1).setAutoCommit(appDB.getAutoCommit()); } catch(Exception e) {}
					
					
					appDBForUpdateState.add(TARGET_DB_STATE_IDDLE);
					appDBForUpdateLeasedTime.add((long) 0);
					
					last_connect_attempt_success=true;
					last_connection_fail_ts=0;
					
				}
				else {
					try {appDBForUpdate.get(appDBForUpdate.size()-1).close();} catch(Exception e) {}
					appDBForUpdate.remove(appDBForUpdate.size()-1);
					confDBForUpdate.remove(confDBForUpdate.size()-1);
					cLib.mylog(cLib.LOG_LEVEL_DANGER, "target Configuration db is not accessible.");
				}
				

			} else {
				//connection is unsuccessfull 
				appDBForUpdate.remove(appDBForUpdate.size()-1);
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "target Application db is not accessible.");
			}
		}
		
		
		
		if (ret1>-1) {
			appDBForUpdateState.set(ret1, TARGET_DB_STATE_LEASED);
			appDBForUpdateLeasedTime.set(ret1, System.currentTimeMillis());
		}
		
		return ret1;
	}
	
	
	//********************************************************
	boolean isLoadedFromConfDb(int global_task_id) {
		if (hmTaskFromConfDb.containsKey(global_task_id)) return false;
		return hmTaskFromConfDb.get(global_task_id);
	}
	
	
	
	long next_resumeStalledTasks_ts=0;
	static final int resumeStalledTasks_INTERVAL=10000;
	static final int TIMEOUT_FOR_STALLED_TASK=120000;

	//*****************************************
	
	
	void resumeStalledTasks() {
		
		if (next_resumeStalledTasks_ts>System.currentTimeMillis()) return;
		next_resumeStalledTasks_ts=System.currentTimeMillis()+resumeStalledTasks_INTERVAL;
		
		int resumed_task_count=0;
		
		int current_heap_rate=cLib.heapUsedRate();
		
		for (int i=0;i<globalTaskArr.size();i++) {
			
			long task_id_to_resume=hmTaskId.get(i);
			
			if (globalTaskArr.get(i)==null && hmArrStatus.get(i)!=ARR_STAT_FREE) {
				hmArrStatus.put(i, ARR_STAT_FREE);
				globalTaskArr.set(i, null);
				
				hmInMemoryTaskList.remove(task_id_to_resume);
				
				resumed_task_count++;
				
				continue;
			}
			
			if (hmArrStatus.get(i)!=ARR_STAT_ASSIGNED && hmArrStatus.get(i)!=ARR_STAT_RUNNING) continue;
			if (hmTaskAssignTs.get(i)+TIMEOUT_FOR_STALLED_TASK>System.currentTimeMillis()) continue;


			
				
			
			
			//persist it with retry or set status to retry
			if (!isLoadedFromConfDb(i)) {
			
				writeTaskRecord(confDB, 
						work_plan_id, 
						work_package_id, 
						task_id_to_resume, 
						globalTaskArr.get(i), 
						hmTaskSize.get(i), 
						cLib.TASK_STATUS_RETRY, 
						true);
			}
			else 
				cLib.setTaskStatus(
						confDB, 
						work_plan_id, 
						work_package_id, 
						task_id_to_resume, 
						cLib.TASK_STATUS_TOUCH, 
						0
						);
			
				
			resumed_task_count++;

			
			hmArrStatus.put(i, ARR_STAT_FREE);
			globalTaskArr.set(i, null);
			
			hmInMemoryTaskList.remove(task_id_to_resume);
				
		}

		if (resumed_task_count>0)
			cLib.mylog(cLib.LOG_LEVEL_WARNING, "! resumeStalledTasks  : "+resumed_task_count + " tasks resumed.");
		
		
		
		
	}
	
	//*****************************************
	long next_test_target_db_ts=0;
	int TEST_TARGET_TABLE_INTERVAL=120000;
	
	void testTargetDbConnections() {
		if (System.currentTimeMillis()<next_test_target_db_ts) return;
		next_test_target_db_ts=System.currentTimeMillis()+TEST_TARGET_TABLE_INTERVAL;
		cLib.mylog(cLib.LOG_LEVEL_INFO, "Testing ["+appDBForUpdate.size()+"] target db connections..."+master_id + " " + work_package_id);
		
		
		
		for (int i=0;i<appDBForUpdateState.size();i++) {
			int status=appDBForUpdateState.get(i);
			if (status==TARGET_DB_STATE_LEASED) continue;
			
			appDBForUpdateState.set(i, TARGET_DB_STATE_LEASED);
			
			if (db_type.equals(genLib.DB_TYPE_SYBASE)) {
				String test_sql="select 1";
				cLib.getDbArray(appDBForUpdate.get(i), test_sql, 1, null);
			} else {
				try {appDBForUpdate.get(i).isValid(5);} catch(Exception e) {}
			}
			
			try {confDBForUpdate.get(i).isValid(5);} catch(Exception e) {}
			//try {appDBForUpdate.get(i).commit();} catch(Exception e) {}
			
			
			appDBForUpdateState.set(i, TARGET_DB_STATE_IDDLE);
			
		}
		
		
	}
	
	
	//String IdentifierQuote="";
	String db_type="";
	
	
	//*****************************************
	
	int ctas_parallelism_count=4;
	
	
	
	void createTempTable() {
		if (!isExportByCtas) return;
		
		if (export_statement.length()==0) return;
		
		
		String parallel_count=genLib.nvl(cLib.getParamByName(confDB, "PARALLELISM_COUNT"),"4");
		ctas_parallelism_count=4;
		try {ctas_parallelism_count=Integer.parseInt(parallel_count);} catch(Exception e) {}
		
		String temp_table_name="tdm$_temp_"+work_package_id;
		
		if (db_type.equals(genLib.DB_TYPE_ORACLE)) {
			
			
			String found_row_id_statement="";
			
			int rowid_ind=export_statement.indexOf("\"ROWID\"");
			if (rowid_ind>-1) found_row_id_statement="\"ROWID\"";


			
			
			String ctas_statement="";
					
			if (rowid_ind==-1) {
				ctas_statement="create table "+temp_table_name+" nologging parallel (degree "+ctas_parallelism_count+") "+
						" as " + 
						export_statement;
			}
			else {
				
				StringBuilder sbtmp=new StringBuilder();
				sbtmp.append(export_statement);
				
				sbtmp.delete(rowid_ind, rowid_ind+found_row_id_statement.length());
				sbtmp.insert(rowid_ind, found_row_id_statement+" oracle_row_id");
				
				ctas_statement="create table "+temp_table_name+" nologging parallel (degree "+ctas_parallelism_count+") "+
						" as " + 
						sbtmp.toString();
			}
			
			
			
			
			runCreateTempTableAsCTAS(ctas_statement);
			
		} else if (db_type.equals(genLib.DB_TYPE_MSSQL)) {
			
			int from_ind=export_statement.toLowerCase().indexOf(" from ");
			//SELECT StudentID,LastName into tdm$_temp_xxxx from dbo.Student;
			String ctas_statement=export_statement.substring(0,from_ind)+" into " + temp_table_name+" " + export_statement.substring(from_ind);
			
			runCreateTempTableAsCTAS(ctas_statement);
			
		} else if (db_type.equals(genLib.DB_TYPE_SYBASE)) {
			
			int from_ind=export_statement.toLowerCase().indexOf(" from ");
			//SELECT StudentID,LastName into tdm$_temp_xxxx from dbo.Student;
			String ctas_statement=export_statement.substring(0,from_ind)+" into " + temp_table_name+" " + export_statement.substring(from_ind);
			
			runCreateTempTableAsCTAS(ctas_statement);
			
		} else if (db_type.equals(genLib.DB_TYPE_MYSQL)) {
			
			String ctas_statement="create table "+temp_table_name+" as " + export_statement;
			
			runCreateTempTableAsCTAS(ctas_statement);
			
		} else if (db_type.equals(genLib.DB_TYPE_POSTGRESQL)) {
			
			String ctas_statement="create table "+temp_table_name+" as " + export_statement;
			
			runCreateTempTableAsCTAS(ctas_statement);
			
		}
		
	}
	
	//*****************************************
	String sqlStatementFromCtas(String original_sql) {
		if (!isExportByCtas) return original_sql;
		
		if (original_sql.length()==0) return original_sql;
		
		String temp_table_name="tdm$_temp_"+work_package_id;
		
		if (db_type.equals(genLib.DB_TYPE_ORACLE)) {
			
			int comma_ind=original_sql.toLowerCase().indexOf(",");
			
			String stmt_from=" from ";
			
			int ind_from=original_sql.toLowerCase().indexOf(stmt_from);
			
			String ret1="select * from "  +		temp_table_name ;
			
			return ret1;
			
		} else if (db_type.equals(genLib.DB_TYPE_MSSQL)) {
			String ret1="select * from "  +		temp_table_name ;
			
			return ret1;
		} else if (db_type.equals(genLib.DB_TYPE_SYBASE)) {
			String ret1="select * from "  +		temp_table_name ;
			
			return ret1;
		} else if (db_type.equals(genLib.DB_TYPE_MYSQL)) {
			String ret1="select * from "  +		temp_table_name ;
			
			return ret1;
		} else if (db_type.equals(genLib.DB_TYPE_POSTGRESQL)) {
			String ret1="select * from "  +		temp_table_name ;
			
			return ret1;
		}
		
		
		return original_sql;
	}
	//*****************************************
	
	boolean isTemporaryTableCreating=false;
	
	boolean runCreateTempTableAsCTAS(String ctas_statement) {
		
		
		boolean ret1=false;
		
		cLib.mylog(cLib.LOG_LEVEL_INFO,"runCreateTempTableAsCTAS Running :  " + ctas_statement);
		long start_ts=System.currentTimeMillis();
		
		
		cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, master_id, cLib.WORK_PACKAGE_STATUS_EXPORTING);
		
		String heartbeat_key="HEARTBEAT_"+System.currentTimeMillis();
		hm.put(heartbeat_key, true);
		
		startLongHeartBeatThread(heartbeat_key);
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		genLib.setCatalogForConnection(appDB, export_catalog);
		
		//drop if exists
		dropTempTable();
		
		isTemporaryTableCreating=true;
		//120 minutes timeout
		
		
		
		ret1=cLib.execSingleUpdateSQL(appDB, ctas_statement, bindlist, 120*60);
		
		if (!ret1) {
			System.out.println("Exception@runCreateTempTableAsCTAS : CTAS SQL : "+ ctas_statement);
		}
		
		isTemporaryTableCreating=false;
		
		hm.remove(heartbeat_key);
		
		
		long duration=System.currentTimeMillis()-start_ts;
		cLib.mylog(cLib.LOG_LEVEL_INFO,"runCreateTempTableAsCTAS Done  ["+duration+" msecs]  :  " + ctas_statement);
		
		
		
		return ret1;
	}
	
	//*****************************************
	void dropTempTable() {
		if (!isExportByCtas) return;
		String drop_statement="";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String temp_table_name="tdm$_temp_"+work_package_id;
		
		genLib.setCatalogForConnection(appDB, export_catalog);
		
		if (db_type.equals(genLib.DB_TYPE_ORACLE)) {
			drop_statement="drop table "+temp_table_name;
			cLib.execSingleUpdateSQL(appDB, drop_statement, bindlist);
			cLib.mylog(cLib.LOG_LEVEL_INFO,"dropTempTable Done  ");
		} else if (db_type.equals(genLib.DB_TYPE_MYSQL)) {
			drop_statement="drop table IF EXISTS "+temp_table_name;
			cLib.execSingleUpdateSQL(appDB, drop_statement, bindlist);
			cLib.mylog(cLib.LOG_LEVEL_INFO,"dropTempTable Done  ");
		} else if (db_type.equals(genLib.DB_TYPE_SYBASE)) {
			drop_statement="drop table "+temp_table_name;
			cLib.execSingleUpdateSQL(appDB, drop_statement, bindlist);
			cLib.mylog(cLib.LOG_LEVEL_INFO,"dropTempTable Done  ");
		} else {
			drop_statement="drop table "+temp_table_name;
			cLib.execSingleUpdateSQL(appDB, drop_statement, bindlist);
			cLib.mylog(cLib.LOG_LEVEL_INFO,"dropTempTable Done  ");
		}
	}
	
	//****************************************
	String addStartEndForTable(String tabin) {
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
	String addStartEndForColumn(String colin) {
		if (colin.contains(start_ch)) return colin;
		String ret1=colin;
		
		
		try {
			ret1=start_ch+ret1+end_ch;
		} catch(Exception e) {e.printStackTrace();}
		
		return ret1;
		
	}
	//******************************************
	void buildExportStatement(Connection conn) {
		
		
		createTempTable();
		
		
		cLib.mylog(cLib.LOG_LEVEL_INFO,"buildExportStatement.export_statement: " + this.export_statement);
		cLib.mylog(cLib.LOG_LEVEL_DEBUG,"buildExportStatement.export_catalog: " + this.export_catalog);
		cLib.mylog(cLib.LOG_LEVEL_DEBUG,"buildExportStatement.export_schema: " + this.export_schema);
		cLib.mylog(cLib.LOG_LEVEL_DEBUG,"buildExportStatement.export_table: " + this.export_table);
		
		if (export_statement.length()>0) 
			return;
		
		DatabaseMetaData meta=null;
		ResultSet tables = null;
		
		
		String schema_delimiter=".";
		String field_list="*";
		String ext_before_fields="";
		String ext_after_table_name="";
		
		//String db_type=cLib.getDbType(confDB,appDB);
		String db_type=cLib.getDbTypeByEnvId(confDB, env_id);
		
		
		boolean table_exists=false;
		
		try {
			meta=conn.getMetaData();
			tables = meta.getTables(export_catalog, export_schema, export_table, new String[]{"TABLE","VIEW"});
			if (tables.next()) table_exists=true;
		} catch (SQLException e) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@buildExportStatement");
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Message : "+e.getMessage());
			e.printStackTrace();

		} finally {
			try {tables.close();} catch(Exception e) {}
		}
		
		if (!table_exists) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Table not found : " + export_catalog+"."+export_schema+"."+export_table);
			return;
		}
		
		if (fieldList.size()>0) {
			field_list="";
			for (int i=0;i<fieldList.size();i++) {
				if (i>0) field_list=field_list+", ";
				//field_list=field_list+start_ch+fieldList.get(i)+end_ch;
				field_list=field_list+addStartEndForColumn(fieldList.get(i));
			}
		}
		
		
		
		
		if (export_partition.length()>0) {
			if (db_type.equals(genLib.DB_TYPE_ORACLE)) 
				ext_after_table_name="PARTITION ("+export_partition+")";
			
		}
		
		
		if (db_type.equals(genLib.DB_TYPE_MSSQL)) {
			ext_after_table_name=ext_after_table_name+ " WITH (NOLOCK) ";
		}
		
		if (db_type.equals(genLib.DB_TYPE_SYBASE)) {
			ext_after_table_name=ext_after_table_name+ " NOHOLDLOCK ";
		}
		
		
		
		export_statement="select "+ ext_before_fields + " "+field_list+
							" from "+ addStartEndForTable(export_schema+"."+export_table);
							/*
							IdentifierQuote +export_schema+IdentifierQuote +
							schema_delimiter+
							IdentifierQuote+ export_table+IdentifierQuote;
							*/
		if (ext_after_table_name.length()>0)
			export_statement=export_statement+" "+ext_after_table_name;
		
		if (export_filter.length()>0)
			export_statement=export_statement+" WHERE " + export_filter;
		
		
		
		
		
		
		cLib.mylog(cLib.LOG_LEVEL_INFO,"buildExportStatement.export_statement: " + this.export_statement);
	
		
	}
	
	
	//******************************************
	public void closeAll() {
		long max_wait_before_exit=1*30*1000;


		long start_ts=System.currentTimeMillis();
		
		if (!cancellation_flag) {
			while(true) {
				int thread_count=getAllThreadCount();
				
				if (thread_count<=original_thread_count) break;
				
				if (thread_count==1 && System.currentTimeMillis()-start_ts>5000) break;
				
				cLib.sleep(1000);
				cLib.mylog(cLib.LOG_LEVEL_WARNING, "There are unfinished threads. running/original : " + thread_count+ " / " + original_thread_count);
				
				cLib.heartbeat(confDB, cLib.TABLE_TDM_MASTER, 0, master_id);
				
				cLib.setWorkPackageStatus(confDB, work_plan_id, work_package_id, master_id, cLib.WORK_PACKAGE_STATUS_TOUCH);
				
				if (System.currentTimeMillis()-start_ts>max_wait_before_exit) {
					cLib.mylog(cLib.LOG_LEVEL_WARNING, "Thread wait timeout " +max_wait_before_exit+ "  exceeded... So i am done.... ");
					break;
				}
			}
		
		cLib.mylog(cLib.LOG_LEVEL_WARNING, "All threads area finished.  " +  original_thread_count);
		} //if (!cancellation_flag)
			
		
		
		checkWorkPackageAndFinishWorkPlan();

		
		hm.clear();
		hmProfiles.clear();
		
		if (confDB!=null) 
			try {
				cLib.mylog(cLib.LOG_LEVEL_DEBUG, "Closing configuration db connection.");
				confDB.close();
				} catch(Exception e) {}
		
		if (appDB!=null) 
			try {
				cLib.mylog(cLib.LOG_LEVEL_DEBUG, "Closing application db connection.");
				if (!appDB.getAutoCommit()) 	appDB.commit();
				appDB.close();
				} catch(Exception e) {}
		
		for (int i=0;i<appDBForUpdate.size();i++) {
			if (appDBForUpdate.get(i)!=null) {
				
				try {
					cLib.mylog(cLib.LOG_LEVEL_DEBUG, "Closing target application db connection["+i+"].");
					if (!appDBForUpdate.get(i).getAutoCommit()) 	
						appDBForUpdate.get(i).commit();
					appDBForUpdate.get(i).close();
					} catch(Exception e) {}
				
				try {
					cLib.mylog(cLib.LOG_LEVEL_DEBUG, "Closing target conf db connection["+i+"].");
					if (!confDBForUpdate.get(i).getAutoCommit()) 	
						confDBForUpdate.get(i).commit();
					confDBForUpdate.get(i).close();
					} catch(Exception e) {}
			}
		}
		
		try {mongoClient.close();} catch(Exception e) {}
		
	}
	
	//----------------------------------------------
	
	
	//---------------------------------------------
	public String[] getMaskProfileById(int id) {
		//if (mask_Profiles==null) mask_Profiles=loadMaskProfiles(confDB);		
		if (id<1) return null;
		Integer arr_id=hmProfiles.get(id);
		if (arr_id==null) return null;
		return mask_Profiles.get(arr_id);
	}
	
	//----------------------------------------------
	public ArrayList<String[]> loadMaskProfiles(Connection conn) {

		cLib.mylog(cLib.LOG_LEVEL_INFO,"loading masking profiles... ");

		String sql="SELECT id,    name,    rule_id,     hide_char,    hide_after,    hide_by_word, " + 
				" src_list_id,    random_range,    random_char_list,    regex_stmt,     pre_stmt,  post_stmt, " + 
				" format,    date_change_params,      fixed_val, js_code, short_code, run_on_server,  "+
				" scramble_part_type, scramble_part_type_par1, scramble_part_type_par2 " +
				" FROM tdm_mask_prof where valid='YES' " + 
				" order by id ";
		
		ArrayList<String[]> ret1=cLib.getDbArray(confDB, sql, Integer.MAX_VALUE, null);

		cLib.mylog(cLib.LOG_LEVEL_INFO,"loading masking profiles...DONE. "+ ret1.size()+" profiles loaded.");
		
		cLib.mylog(cLib.LOG_LEVEL_INFO,"loading list items..");
		for (int i=0;i<ret1.size();i++) {
			int profile_id=Integer.parseInt(ret1.get(i)[MASK_PRFL_FLD_ID]);
			
			
			hmProfiles.put(profile_id, i);
			
			
			String profile_type=ret1.get(i)[MASK_PRFL_FLD_RULE];
			//if (!profile_type.equals(MASK_RULE_KEYMAP) && !profile_type.equals(MASK_RULE_KEYMAP)) continue;
			if (!profile_type.equals(MASK_RULE_HASHLIST)) continue;
			int list_id=0; 
			
			try{list_id=Integer.parseInt(ret1.get(i)[MASK_PRFL_FLD_SRC_LIST]);} catch(Exception e) {}
			
			if (list_id>0) loadList(conn, list_id);
			
			
			
		}
		cLib.mylog(cLib.LOG_LEVEL_INFO,"loading list items..DONE");
		
		
		return ret1;

	}
	
	
	
	ArrayList<ArrayList<String[]>> listArrayListArr=new ArrayList<ArrayList<String[]>>();
	
	//----------------------------------------------
	public void loadList(Connection conn, int list_id) {		
		cLib.mylog(cLib.LOG_LEVEL_INFO,"Loading list : " +list_id + "...") ;
		
		if (hm.containsKey("LIST_"+list_id+"_LOADED")) return;
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String sql="select list_val from tdm_list_items where list_id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+list_id});
		ArrayList<String[]> l= cLib.getDbArray(confDB, sql, Integer.MAX_VALUE, bindlist);
		
		sql="select title_list from tdm_list where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+list_id});
		String title_list=cLib.getDbArray(confDB, sql, 1, bindlist).get(0)[0];
		
		int title_count=0;
		ArrayList<String> titleArr=new ArrayList<String>();
		
		if (!genLib.nvl(title_list,"-").equals("-") && title_list.contains("|::|")) {
			String[] arr=title_list.split("\\|::\\|");
			for (int i=0;i<arr.length;i++) 
				if (arr[i].length()>0) {
					title_count++;
					titleArr.add(arr[i]);
					hm.put("LIST_"+list_id+"_COL_ID_"+arr[i], i);
				}
			
			
		}
		
		String k_base="LIST_"+list_id;
		StringBuilder sb=new StringBuilder();
		int pos=-1;
		
		cLib.heartbeat(conn, cLib.TABLE_TDM_MASTER, 0, master_id);
		
		ArrayList<String[]> newList=new ArrayList<String[]>();
		
		for (int i=0;i<l.size();i++) {
			
			
			if (title_count>0) {
				String[] row=new String[title_count];
				
				sb.setLength(0);
				sb.append(l.get(i)[0]);
				sb.append("|::|");
				
				
				if (i % 1000==0) 
					cLib.mylog(cLib.LOG_LEVEL_INFO,"Loading list .... "+(i+1)+"/"+l.size() );
				
				for (int j=0;j<title_count;j++) {
					pos=sb.indexOf("|::|");
					
					if (pos==0) 
						row[j]="";
					else 
						row[j]=sb.substring(0,pos);
			
					sb.delete(0, pos+4);
				}
				
				newList.add(row);
					
			}
			else {
				newList.add(new String[]{l.get(i)[0]});
			} 
			//hm.put(k_base+"_"+i, l.get(i)[0]);
			
			
		} //for
		
		hm.put(k_base+"_LOADED", "YES");
		hm.put(k_base+"_SIZE", l.size());
		
		listArrayListArr.add(newList);
		hm.put(k_base+"_ARRAYLIST_ID", listArrayListArr.size()-1);
		
		cLib.mylog(cLib.LOG_LEVEL_INFO,"Loading list : " +list_id + "...DONE") ;
		
	
	}
	
	
	//----------------------------------------------
	void extractMaskParams(String tab_id, String table_name, String params) {
			 //fname:VARCHAR:100:NO##11
			 //id:INTEGER:10:YES##0
			 //lname:VARCHAR:100:NO##IF[${fname}::=::ALI::MASK(11)]||ELSE[MASK(3)]
			
			
			
			String[] parts=params.split("\n");
			
			field_names.clear();
			field_types.clear();
			field_sizes.clear();
			field_PKs.clear();
			field_mask_rules.clear();
			field_mask_profiles.clear();
			
			for (int i=0;i<parts.length;i++) {
				String a_mask=parts[i];
				
				try {
					String a_field=a_mask.split("##")[0];

					String a_field_name=a_field.split(":")[0];
					String a_field_type=a_field.split(":")[1];
					String a_field_size=a_field.split(":")[2];
					String a_field_PK=a_field.split(":")[3];
					String a_field_mask_rule=a_field.split(":")[4];
					String a_list_field_name=a_field.split(":")[5];
					//if there is FIXED add it
					try {
						a_list_field_name=a_field.split(":")[5]+":"+a_field.split(":")[6];
					} catch(Exception e) {}
					
					int a_field_size_int=0;
					try{
						a_field_size_int=Integer.parseInt(a_field_size);
					} catch(Exception e) {
						a_field_size_int=0;
					}
					
					field_names.add(a_field_name);
					field_types.add(a_field_type);
					field_sizes.add(a_field_size_int);
					field_PKs.add(a_field_PK);
					field_mask_rules.add(a_field_mask_rule);
					
					
					if (a_list_field_name.contains(":FIXED")) {
						field_fixed_column_ids.add(i);
						field_list_column_names.add(a_list_field_name.split(":FIXED")[0]);
					} else {
						field_list_column_names.add(a_list_field_name);
					}
						
					
					if (a_field_mask_rule.equals(MASK_RULE_GROUP_MIX)) is_group_mixing=true;
					if (a_field_mask_rule.equals(MASK_RULE_MIX)) is_record_mixing=true;

					String a_mask_prof_id=a_mask.split("##")[1];
					
					field_mask_profiles.add(a_mask_prof_id);
					
					String hmkey="MASK_PROFILE_OF_"+table_name+"_"+tab_id+"."+a_field_name.toUpperCase();
					hm.put(hmkey, a_mask_prof_id);
					hmkey="FIELD_ID_"+table_name+"_"+tab_id+"."+a_field_name.toUpperCase();
					hm.put(hmkey, i);
					
				} catch(Exception e) {
					break;
				}
			}
				
		}
		
	//--------------------------------------------------------------------------------
	int decodeMaskParam(String tab_id, String table_name, String field, String[] cols) {
		int profile_id = -1;
		String ret1="";


		String hmkey="MASK_PROFILE_OF_"+table_name+"_"+tab_id+"."+field.toUpperCase();
		
		if (hm.containsKey(hmkey)) {
			ret1=(String) hm.get(hmkey);
			
			//conditional 
			if (ret1.indexOf("IF[${")==0) {
				
				String condition=genLib.nvl(ret1,"");
				String[] parts=condition.split("\\|\\|");
				if (parts.length>0) 
				for (int i=0;i<parts.length;i++) {
					String[] a_part=parts[i].split("::");
					
					String a_stmt=a_part[0];

					//no match found, else 
					if (a_stmt.indexOf("ELSE[")==0) {
						String a_mask_prof=a_stmt.split("\\(")[1].split("\\)")[0];
						ret1=a_mask_prof;
						break;
					} else {
						String check_field=a_stmt.split("\\{")[1].split("\\}")[0];
						int field_id=(int) hm.get("FIELD_ID_"+table_name+"_"+tab_id+"."+check_field.toUpperCase());
						//the first col is row id skipping
						String field_val=cols[field_id];
						
						String a_operand=a_part[1];
						String a_check_val=a_part[2];
						
						String a_mask_prof=a_part[3].split("\\(")[1].split("\\)")[0];

						if (checkIf(field_val, a_operand, a_check_val)) {
							ret1=a_mask_prof;
							break;
						}
					}
				} // for
				
				
			} // if IF
			
		}
		
		try {profile_id=Integer.parseInt(ret1);} catch(Exception e) {} 
		
		return profile_id;
	}

	//-----------------------------------------------------------------
	boolean checkIf(String val_to_check, String oper, String ctrl_vals) {
		// oper ========> =, !=, like, !like, in, !in,

		//System.out.println("*** Check if ["+val_to_check+"] "+oper + " ["+ ctrl_vals+"]");
		
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
			String[] ctrlArr=ctrl_vals.split(",");
			for (int i=0;i<ctrlArr.length;i++)
				if (ctrlArr[i].trim().indexOf(val_to_check) > -1)
				return true;
			return false;
		}

		if (oper.equals("!in")) {
			String[] ctrlArr=ctrl_vals.split(",");
			boolean found=false;
			for (int i=0;i<ctrlArr.length;i++)
				if (ctrlArr[i].trim().indexOf(val_to_check) > -1) {
					found=true;
					break;
				}
			return !found;
		}

		return false;

	}
	
	
	//-----------------------------------------------------------------
	public String maskList(
			String orig_value,
			int list_id, 
			StringBuilder list_hkey_ref_Value, 
			String list_field_name,
			String[] currFieldVals
			) {
		
		StringBuilder valSb=new StringBuilder();
		
		
		if (list_hkey_ref_Value.length()==0) 
			valSb.append(cLib.normalize(orig_value));
		else 
			valSb.append(cLib.normalize(list_hkey_ref_Value.toString()));
		
		int list_arraylist_id=(int) this.hm.get("LIST_"+list_id+"_ARRAYLIST_ID");
		
		int i=-1;
		try{
			
			if (field_fixed_column_ids.size()==0) {
				i=Math.abs(valSb.toString().hashCode()) % (int) this.hm.get("LIST_"+list_id+"_SIZE");
			} else {
				StringBuilder hkey=new StringBuilder();
				hkey.append("LIST_"+list_id+"_INDEX_ARRAYLIST_ID_FOR_");
				for (int f=0;f<field_fixed_column_ids.size();f++) {
					if (f>0) hkey.append(",");
					hkey.append(field_list_column_names.get(field_fixed_column_ids.get(f)));
					hkey.append("=");
					hkey.append(currFieldVals[field_fixed_column_ids.get(f)]);
				}
								
				if (hm.get(hkey.toString())==null)  
					indexList(list_id, list_arraylist_id, currFieldVals,hkey.toString());
				
				int index_array_id=-1;	
				
				while(index_array_id<0) {
					try{index_array_id=(int) hm.get(hkey.toString());} 
					catch(Exception e) {
						index_array_id--;
						}
					if (index_array_id<=-10000) break;
				}
				
				int index_arr_size=indexArrayArr.get(index_array_id).size();
				
				if (index_arr_size>0) {
					int index_id=Math.abs(valSb.toString().hashCode()) % index_arr_size;
					i=indexArrayArr.get(index_array_id).get(index_id);
				} else 
					return(orig_value);
				

			}
			
		} catch(Exception e) {
			i=-1;
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@maskList1 : "+ e.getMessage());
			e.printStackTrace();
			}
		
		
		try{
			
			if (i==-1) return(orig_value);
			
			if (!list_field_name.equals("-")) {
				int list_col_id=-1;
				list_col_id=(int) this.hm.get("LIST_"+list_id+"_COL_ID_"+list_field_name);


				return listArrayListArr.get(list_arraylist_id).get(i)[list_col_id];
			}
				


			return listArrayListArr.get(list_arraylist_id).get(i)[0];
		
			} catch(Exception e) {
				e.printStackTrace();
				cLib.mylog(cLib.LOG_LEVEL_DANGER, "Exception@maskList2 : "+ e.getMessage());
				
				return(orig_value);
				
			}

	}

	//-------------------------------------------------------------
	ArrayList<ArrayList<Integer>> indexArrayArr=new ArrayList<ArrayList<Integer>>();
	int index_counter=0;
	//-------------------------------------------------------------
	protected void indexList(int list_id, int list_arraylist_id, String[] currFieldVals, String hkey) {

		
		
		StringBuilder currFixedColumnVals=new StringBuilder();
		
		for (int f=0;f<field_fixed_column_ids.size();f++) {
			if (f>0) currFixedColumnVals.append(",");
			currFixedColumnVals.append(currFieldVals[field_fixed_column_ids.get(f)]);
		}
		
		long start_ts=System.currentTimeMillis();
		index_counter++;
		cLib.mylog(cLib.LOG_LEVEL_DEBUG, "*** INDEXING [Indexno:"+index_counter+"]: " + hkey);
		
		
		StringBuilder listFixedVals=new StringBuilder();
		ArrayList<Integer> indexArr=new ArrayList<Integer>();
		
		int indexing_list_arr_size=(int) this.hm.get("LIST_"+list_id+"_SIZE");
		
		for (int i=0;i<indexing_list_arr_size;i++) {
			String[] row=listArrayListArr.get(list_arraylist_id).get(i);
			listFixedVals.setLength(0);
			
			cLib.heartbeat(confDB, cLib.TABLE_TDM_MASTER, 0, master_id);
			
			for (int f=0;f<field_fixed_column_ids.size();f++) {
				if (f>0) listFixedVals.append(",");
				int list_col_id=(int) this.hm.get("LIST_"+list_id+"_COL_ID_"+field_list_column_names.get(field_fixed_column_ids.get(f)));
				listFixedVals.append(row[list_col_id]);
			}
			
			if (!listFixedVals.toString().equals(currFixedColumnVals.toString())) continue;
			
			indexArr.add(i);
			
			
		}
		
		hm.put(hkey, indexArrayArr.size());
		indexArrayArr.add(indexArr);
		
		
		cLib.mylog(cLib.LOG_LEVEL_DEBUG, "***"+currFixedColumnVals.toString()+" DONE. Size : "+indexArr.size() +" took " + (System.currentTimeMillis()-start_ts)+  " msecs");
	
	}
	//-------------------------------------------------------------
	protected String mask(
			int tab_id, 
			int col_id,
			String val, 
			StringBuilder hkey_ref_value,  
			int mask_profile_id,
			String[] mask_prof,
			String[] currFieldVals,
			ScriptEngine engine
			) {
	
		
		
	//liste tipi maskelemelerde multicolumn deðerlerde boþ alana da deðer yazýlýr
	if (val.length() == 0 && field_list_column_names.get(col_id).equals(genLib.MINUS) ) return "";	

	if (mask_prof==null) 		return val;
	
		

	String ret1="";
	
	switch(mask_prof[MASK_PRFL_FLD_RULE]) {
	//------------------------------------------------------------------
	case MASK_RULE_HASH_REF : {
		return val;
	}
	//------------------------------------------------------------------
	case MASK_RULE_GROUP_MIX : {
		return val;
	}
	//------------------------------------------------------------------
	case MASK_RULE_MIX : {
		return val;
	}
	case MASK_RULE_GROUP : {
		return val;
	}
	//------------------------------------------------------------------
	case MASK_RULE_HIDE : {
		String hide_char="";
		int hide_after=0;
		String hide_by_word="NO";
		try{hide_char=mask_prof[MASK_PRFL_FLD_HIDE_CHAR].substring(0,1);} catch(Exception e) {hide_char="*";}
		try{hide_after=Integer.parseInt(mask_prof[MASK_PRFL_FLD_HIDE_AFTER]);} catch(Exception e) {hide_after=2;}
		try{hide_by_word=mask_prof[MASK_PRFL_FLD_HIDE_BY_WORD];} catch(Exception e) {hide_by_word="NO";}
		
		ret1=maskHide(val,hide_after,hide_char,hide_by_word);
		break;	
		}
	//------------------------------------------------------------------
	case MASK_RULE_HASHLIST : {
		int list_id=0;
		try{list_id=Integer.parseInt(mask_prof[MASK_PRFL_FLD_SRC_LIST]);} catch(Exception e) {}
		if (list_id==0) 
			return val; 
		else
			{
			
			
			ret1=maskList(val,list_id, hkey_ref_value, field_list_column_names.get(col_id), currFieldVals);
			if (ret1==null) return val;
			}
		break;	
		}
	
	//------------------------------------------------------------------
	case MASK_RULE_SCRAMBLE_PARTIAL : {
		ret1= maskScramblePartial(val,
				mask_prof[MASK_PRFL_FLD_SCRAMBLE_PART_TYPE], 
				mask_prof[MASK_PRFL_FLD_SCRAMBLE_PART_TYPE_PAR1],
				mask_prof[MASK_PRFL_FLD_SCRAMBLE_PART_TYPE_PAR2],
				mask_prof[MASK_PRFL_FLD_RANDOM_CHARLIST]
						);
		break;	
		}
	//------------------------------------------------------------------
	case MASK_RULE_SCRAMBLE_INNER : {
		ret1= maskScrambleInner(val);
		break;	
		}
	//------------------------------------------------------------------
	case MASK_RULE_SCRAMBLE_RANDOM : {
		String char_list="";
		try{char_list=mask_prof[MASK_PRFL_FLD_RANDOM_CHARLIST];} catch(Exception e) {
			char_list=MASK_DEFAULT_CHAR_LIST;
			}
		if ((""+char_list).length()==0) char_list=MASK_DEFAULT_CHAR_LIST;
		ret1=maskScrambleRandom(val,char_list);
		break;	
		}
	//------------------------------------------------------------------
	case MASK_RULE_SCRAMBLE_DATE : {
		String date_format="";
		String date_change_params="";
		try{date_format=mask_prof[MASK_PRFL_FLD_FORMAT];} catch(Exception e) {
			date_format="";
			}
		if (date_format.length()==0) date_format=genLib.DEFAULT_DATE_FORMAT;
		
		try{date_change_params=mask_prof[MASK_PRFL_FLD_DATE_CHANGE_PARAMS];} catch(Exception e) {
			date_change_params="";
			}

		ret1=maskScrambleDate(val,date_format,date_change_params);
		break;	
		}
	//------------------------------------------------------------------
	case MASK_RULE_RANDOM_NUMBER : {
		String range="";
		try{range=mask_prof[MASK_PRFL_FLD_RANDOM_RANGE];} catch(Exception e) {
			range="";
			}
		ret1=maskRandomNumber(val,range);
		break;	
		}
	//------------------------------------------------------------------
	case MASK_RULE_NONE : {
		return val;
		}
	//------------------------------------------------------------------
	case MASK_RULE_FIXED : {
		String fix_val="";
		try{fix_val=mask_prof[MASK_PRFL_FLD_FIXED_VAL];} catch(Exception e) {fix_val="";}
		return fix_val;
		}
	//------------------------------------------------------------------
	case MASK_RULE_JAVASCRIPT : {
		String js_code="";
		try{js_code=mask_prof[MASK_PRFL_FLD_JS_CODE];} catch(Exception e) {js_code="";}
		ret1=maskJavascript(engine, tab_id, col_id, val, hkey_ref_value, js_code, currFieldVals, field_list_column_names.get(col_id), mask_prof);
		break;	
		}
	//------------------------------------------------------------------
	case MASK_RULE_SQL : {
		String sql_code="";
		try{sql_code=mask_prof[MASK_PRFL_FLD_JS_CODE];} catch(Exception e) {sql_code="";}
		ret1=maskSQL(tab_id, val, sql_code);
		break;	
		}
	//------------------------------------------------------------------
	case MASK_RULE_RANDOM_STRING : {
		String range="";
		String char_list="";
		try{range=mask_prof[MASK_PRFL_FLD_RANDOM_RANGE];} catch(Exception e) {
			range="";
			}
		try{char_list=mask_prof[MASK_PRFL_FLD_RANDOM_CHARLIST];} catch(Exception e) {
			char_list=MASK_DEFAULT_CHAR_LIST;
			}
		if ((""+char_list).length()==0) char_list=MASK_DEFAULT_CHAR_LIST;
		
		ret1=maskRandomString(val,range,char_list);
		break;	
		}
	}
	
	
	
	if (!mask_prof[MASK_PRFL_FLD_POST_STATEMENT].isEmpty()) {
		switch(mask_prof[MASK_PRFL_FLD_POST_STATEMENT]) {

		case "UPPERCASE" : {return ret1.toUpperCase(currLocale);  }
		case "LOWERCASE" : {return ret1.toLowerCase(currLocale);  }
		case "INITIALS" : {return initials(ret1);  }
		
		}
	}
	
	
	
	return ret1;
}
	private String initials(String in) {
		String ret1="";
		if (in==null) return "";
		String[] arr=in.split(" ");
		for (int i=0;i<arr.length;i++) {
			if(arr[i]==null) continue;
			if(arr[i].isEmpty()) continue;
			if (i>0) ret1=ret1+" ";
			ret1=ret1+arr[i].substring(0,1).toUpperCase(currLocale)+
					arr[i].substring(1).toLowerCase(currLocale);
		}
		return ret1;
	}
	//-----------------------------------------------------------
	
	private String maskHide(String orig_value,int show_count, String mask_asterix_char,String hide_by_word) {
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
	
	//****************************************
	String myReverseString(String org) {
		try {
			StringBuffer buffer = new StringBuffer(org);
			return buffer.reverse().toString();
		} catch(Exception e) {
			return org;
		}
		
	}
	
	//****************************************
	public String maskScrambleInner(String orig_value) {
		return maskScrambleInner(orig_value,0);
	}
	//****************************************
	public String maskScrambleInner(String orig_value, int level) {
		
		if (level>10) return orig_value;
		
		if (orig_value.length()<2) return orig_value;
		
		int half_len=orig_value.length()/2;
		
		if (((int) orig_value.charAt(0)) % 2==0)
			return myReverseString(maskScrambleInner(orig_value.substring(0,half_len),level+1))  +  myReverseString(maskScrambleInner(orig_value.substring(half_len),level+1));
		else 
			return myReverseString(maskScrambleInner(orig_value.substring(half_len),level+1)) +myReverseString(maskScrambleInner(orig_value.substring(0,half_len),level+1)) ;
		
	}

	/*
	public String maskScrambleInner(String orig_value) {
		
		if (orig_value.length()<2) return orig_value;
		
		char[] arr=orig_value.toCharArray();
		//int[] fabs=RANDOM_INT_ARRAY;
		int len=RANDOM_INT_ARRAY.length;
		int in_len=orig_value.length();
		int a=0;
		int b=0;
		char t_char='x';
		
		for (int i=0;i<len-1;i++) {
			a=(RANDOM_INT_ARRAY[i]) % in_len;
			b=(RANDOM_INT_ARRAY[i+1]) % in_len;
			if (a==b) continue;
			
			t_char=arr[a];
			arr[a]=arr[b];
			arr[b]=t_char;
		}
		

		
		return (new String().valueOf(arr));
	}
	*/
	//****************************************

	static final String PARTIAL_TYPE_ALL="ALL";
	static final String PARTIAL_TYPE_FIRST="FIRST";
	static final String PARTIAL_TYPE_LAST="LAST";
	static final String PARTIAL_TYPE_EXCEPT_FIRST="EXCEPT_FIRST";
	static final String PARTIAL_TYPE_EXCEPT_LAST="EXCEPT_LAST";
	static final String PARTIAL_TYPE_BETWEEN="BETWEEN";
	static final String PARTIAL_TYPE_BETWEEN_FIRST_LAST="BETWEEN_FIRST_LAST";
	static final String PARTIAL_TYPE_EXCEPT="EXCEPT";
	
	public String maskScramblePartial(String orig_value, String partial_type, String par1, String par2, String char_list) {
		
		
		
		switch (partial_type) {
		 case PARTIAL_TYPE_ALL: {
				return maskScrambleRandom(orig_value,char_list);
			}
		 
		 case PARTIAL_TYPE_FIRST: {
			 			int len1=Integer.parseInt(par1.trim());
				
						if (len1<=0) return orig_value;
						if (orig_value.length()<=len1) return maskScrambleInner(orig_value);
						return maskScrambleRandom(orig_value.substring(0,len1),char_list)+orig_value.substring(len1);
					}
		case PARTIAL_TYPE_LAST:{
						int len1=Integer.parseInt(par1.trim());
			
						if (len1<=0) return orig_value;
						int x=orig_value.length()-len1;
						if (orig_value.length()<=len1) return maskScrambleInner(orig_value);
						return orig_value.substring(0,x)+maskScrambleRandom(orig_value.substring(x),char_list);
		}
		case PARTIAL_TYPE_EXCEPT_FIRST:{
						int len1=Integer.parseInt(par1.trim());
						if (len1<=0) return orig_value;
						if (orig_value.length()<=len1) return orig_value;
						return orig_value.substring(0,len1)+maskScrambleRandom(orig_value.substring(len1),char_list);

		}
		case PARTIAL_TYPE_EXCEPT_LAST:{
						int len1=Integer.parseInt(par1.trim());
						
						if (len1<=0) return orig_value;
						if (orig_value.length()<=len1) return orig_value;
						int x=orig_value.length()-len1;
						return maskScrambleRandom(orig_value.substring(0,x),char_list)+orig_value.substring(x);
		}
		
		case PARTIAL_TYPE_BETWEEN:{
			
			
			int len1=Integer.parseInt(par1.trim());
			int len2=Integer.parseInt(par2.trim());
			
			if (len1<=0) return orig_value;
			if (len2<=0) return orig_value;
			if (len1>=len2) return orig_value;
			if (orig_value.length()<len1) return orig_value;
			if (orig_value.length()<len2) return orig_value;
			
			
			String a="";
			if (len1>1) a=orig_value.substring(0,len1-1);
			String b=orig_value.substring(len1-1,len2);
			String c="";
			if (len2<orig_value.length())
				c=orig_value.substring(len2);
			
			return a+maskScrambleRandom(b,char_list)+c;
			}			
			
		case PARTIAL_TYPE_BETWEEN_FIRST_LAST:{
			
			
			int len1=Integer.parseInt(par1.trim());
			int len2=Integer.parseInt(par2.trim()); 
			if (len1<=0) return orig_value;
			if (len2<=0) return orig_value;
			if ((len1+len2)>=orig_value.length()) return orig_value;



			
			String a=orig_value.substring(0,len1);
			String b=orig_value.substring(len1,len1+(orig_value.length()-len2-2)); 
			String c=orig_value.substring(orig_value.length()-len2);


			return a+maskScrambleRandom(b,char_list)+c;
			}
		case PARTIAL_TYPE_EXCEPT:{
				if (par1.length()==0)	
					return maskScrambleInner(orig_value);
				String[] arr=par1.split(",");
				for (int i=0;i<arr.length;i++) {
					if (arr[i].length()==0) continue;
					int ind=orig_value.indexOf(arr[i]);
					
					String a="";
					if (ind>0) a=orig_value.substring(0,ind);
					String b=arr[i];
					String c="";
					if (ind+arr[i].length()+1<orig_value.length())
						c=orig_value.substring(ind+arr[i].length());
					
					return maskScrambleRandom(a,char_list)+b+maskScrambleRandom(c,char_list);
				}
						
		}
		break;

		default:
			return orig_value;
		}
		 
		return orig_value;
	}
	
	//****************************************
	private String maskScrambleRandom(String orig_value,String char_list) {
		
		if (char_list.trim().length()==0) return maskScrambleInner(orig_value);
		if (orig_value.length()<2) return orig_value;
		
		char[] orig_arr=orig_value.toCharArray();
		char[] chars_arr=char_list.toCharArray();
		int[] fabs=RANDOM_INT_ARRAY;

		int orig_len=orig_value.length();
		int chars_len=char_list.length();
		int fab_len=fabs.length;

		int a=0;
		int b=0;
		
		for (int i=0;i<fab_len-1;i++) {
			a=(fabs[i]) % chars_len;
			b=(fabs[i+1]) % orig_len;
			if (orig_arr[b]==' ') continue;
			if (chars_arr[a]==orig_arr[b]) continue;
			orig_arr[b]=chars_arr[a];
		}
		
		
		return (new String().valueOf(orig_arr));
	}

	//****************************************
	private String maskScrambleDate(String orig_value,String date_format,String change_params) {
		int change_range_day=0;
		int change_range_month=0;
		int change_range_year=0;
		
		try{change_range_day=Integer.parseInt(change_params.split("day=")[1].split(",")[0]);} catch(Exception e) {}
		try{change_range_month=Integer.parseInt(change_params.split("month=")[1].split(",")[0]);} catch(Exception e) {}
		try{change_range_year=Integer.parseInt(change_params.split("year=")[1]);} catch(Exception e) {}
		
		Calendar cal=Calendar.getInstance();
		
		
		SimpleDateFormat df=new SimpleDateFormat(date_format);
		Date date=null;
		
		try {date=df.parse(orig_value);} catch(Exception e) {	return orig_value;}
		
		cal.setTime(date);
		
		int day=cal.get(Calendar.DAY_OF_MONTH);
		int mon=cal.get(Calendar.MONTH);
		int year=cal.get(Calendar.YEAR);
		
		int hour=cal.get(Calendar.HOUR_OF_DAY);
		int min=cal.get(Calendar.MINUTE);
		int sec=cal.get(Calendar.SECOND);
		
		int x=1;
		
		x=1;
		if (change_range_day>0) {
			if (mon % 2==1) x=-1;
			day=Math.abs(day+x*((mon%change_range_day)+1)) % 28 +1;
		}
		
		x=1;
		if (change_range_month>0) {
			if (year % 2==1) x=-1;
			mon=Math.abs(mon+x*(year%change_range_month)+1) % 12 +1;
		}

		x=1;
		if (change_range_year>0) {
			if (day % 2==1) x=-1;
			year=Math.abs(year+x*(day%change_range_year)+1);
		}

		cal.set(year, mon, day, hour, min, sec);
		
		return df.format(cal.getTime());
	}

	//****************************************
	private String maskRandomNumber(String orig_value,String range) {
		if (range.indexOf(",")==-1) return "-1";
		String[] arr=range.split(",");
		int range_start=0;
		int range_end=0;
		try { range_start=Integer.parseInt(arr[0]);} catch(Exception e) {return "-1";}
		try { range_end=Integer.parseInt(arr[1]);} catch(Exception e) {return "-1";}
		if (range_end==range_start) return ""+range_start;
		if (range_end<range_start) return "-1";
		int diff=range_end-range_start+1;
		
		return ""+(range_start+((int) (Math.random()*diff)));
	}

	//****************************************
	private String maskRandomString(String orig_value,String range,String char_list) {
		int str_len=Integer.parseInt(maskRandomNumber("1", range));
		if (str_len==-1) return "";
		char[] orig_arr=orig_value.toCharArray();
		char[] char_arr=char_list.toCharArray();
		int r=0;
		int orig_len=orig_value.length();
		int char_len=char_list.length();
		for (int i=0;i<orig_len;i++) {
			if (orig_arr[i]==' ') continue;
			r=(int) (Math.random()*char_len);
			orig_arr[i]=char_arr[r];
		}
		
		
		new String();
		return String.valueOf(orig_arr);
	}
	
	
	public String maskJavascript(
			ScriptEngine engine,
			int tab_id, 
			int col_id,
			String orig_value,
			StringBuilder hkey_ref_value, 
			String p_js_code, 
			String[] currFieldVals, 
			String list_field_name, 
			String[] mask_prof
			) {
	String ret1="";
	String js_code=p_js_code;
		
	if (js_code.length()>0) {
		if (js_code.contains("${")) {
			//replace quotes and double quotes with escaped versions
			try {
				if (orig_value.contains("\"")) {
					orig_value=orig_value.replaceAll("\"", "\\\"");
				}
				
				
				try {
					
					//cLib.mylog(cLib.LOG_LEVEL_DANGER,"Exception@${1}ReplaceALL : orig_value : "+orig_value);
					//cLib.mylog(cLib.LOG_LEVEL_DANGER,"Exception@${1}ReplaceALL : js_code : "+js_code);
					
					js_code=js_code.replaceAll("\\$\\{1\\}", orig_value.replaceAll("\"","\'").replaceAll("(\\r|\\n)", "\"+\n\t\""));
				}
				catch(Exception e) {
					
					cLib.mylog(cLib.LOG_LEVEL_DANGER,"Exception@${1}ReplaceALL : "+genLib.getStackTraceAsStringBuilder(e).toString());
				}
			
				StringBuilder scriptB=new StringBuilder();
				StringBuilder replaceB=new StringBuilder();
				scriptB.append(js_code);
			
				int s=0;
				int cursor=0;
				
				while(true) {	
					if (cursor>=scriptB.length()-1) break;
					
					if (scriptB.indexOf("${",cursor)==-1) break;
					if (scriptB.indexOf("}",cursor)==-1) break;
					
					if (s>100) break;
					int start_i=scriptB.indexOf("${");
					
					int end_i=scriptB.indexOf("}");
					if (end_i<start_i) break;
					
					replaceB.setLength(0);
					replaceB.append("");
					if (field_names.contains(scriptB.substring(start_i+2, end_i))) {
						replaceB.setLength(0);
						try {replaceB.append(currFieldVals[ field_names.indexOf(scriptB.substring(start_i+2, end_i)) ]);} catch(Exception e) {break;}
					} 
					else {
						cursor+=end_i+1;
						s++;
						continue;
					}
					
					if (/*replaceB.indexOf(" ")>-1 || */replaceB.indexOf("\n")>-1 || replaceB.indexOf("\r")>-1 || replaceB.indexOf("\t")>-1) 
						break;
					
					
					scriptB.delete(start_i, end_i+1);
					scriptB.insert(start_i, replaceB.toString().replaceAll("\"","\'").replaceAll("(\\r|\\n)", "\"+\n\t\""));
					
					
					cursor+=end_i+replaceB.toString().replaceAll("\"","\'").replaceAll("(\\r|\\n)", "\"+\n\t\"").length();
					s++;
					
				} //while 
				
				js_code=scriptB.toString();
				
			} catch (Exception e) {
				cLib.mylog(cLib.LOG_LEVEL_DANGER,"Exception@${1}Replacement : "+e.getMessage());
				cLib.mylog(cLib.LOG_LEVEL_DANGER,"at orig_value : [" + orig_value + "]");
				e.printStackTrace();
			}
			
		}
		
		
				
		//--------------------------
		if (js_code.contains("$mask(")) {
			
			String regex_mask="([$]mask)(\\()(.*?)(\\))(;)";
			String regex_mask_short_code="(\\()(.*?)(,)(')";
			String regex_mask_par="(,)(')(.*?)(')(,)";
			String regex_mask_variable="(')(,)(.*?)(\\))(;)";
			
			Pattern pattern_mask=Pattern.compile(regex_mask,Pattern.CASE_INSENSITIVE);
			Pattern pattern_short_code=Pattern.compile(regex_mask_short_code,Pattern.CASE_INSENSITIVE);
			Pattern pattern_par=Pattern.compile(regex_mask_par,Pattern.CASE_INSENSITIVE);
			Pattern pattern_variable=Pattern.compile(regex_mask_variable,Pattern.CASE_INSENSITIVE);
			
			String mask_profile_id="";
			
			
			
			while (true) {
				
				
				
				Matcher matcher_match = pattern_mask.matcher(js_code);
				if  (!matcher_match.find()) 
					break;
				else {
					String mask_piece=matcher_match.group();
					js_code=js_code.replaceFirst("([$])(mask)(\\()","//masked(");
					
					Matcher matcher_short_code = pattern_short_code.matcher(mask_piece);
					
					if (matcher_short_code.find()) {
						
						String short_code=matcher_short_code.group();
						short_code=short_code.substring(1, short_code.length()-2);
						
						Matcher matcher_mask_par = pattern_par.matcher(mask_piece);
						if (matcher_mask_par.find()) {
							String mask_par=matcher_mask_par.group();
							mask_par=mask_par.substring(2, mask_par.length()-2);
							
							String a="";
							
							if (short_code.equals("GET_FIELD_VALUE")) {
								int field_no=0;
								try{field_no=(int) hm.get("FIELD_NO_OF_"+mask_par.toUpperCase()+"_TAB_"+tab_id);} catch(Exception e) {field_no=-1;}
								if (field_no>-1) {
									a=currFieldVals[field_no];
								}
								else {
									a="FIELD NOT FOUND : "+mask_par;
								}
								
							}
							else {
								
								mask_profile_id=getMaskIdByShortCode(short_code);
								if(mask_profile_id.equals("-1")) {
									cLib.mylog(cLib.LOG_LEVEL_DANGER,"getMaskIdByShortCode("+short_code+") cannot be found");
									break;
								}
								
								String[] sub_mask_prof=null;
								
								try {
									int prof_arr_id=hmProfiles.get(Integer.parseInt(mask_profile_id));
									sub_mask_prof=mask_Profiles.get(prof_arr_id);
									} catch(Exception e) {
										cLib.mylog(cLib.LOG_LEVEL_DANGER,"profile id ["+mask_profile_id+"] not found in masking profile cache.");
										break;
										}
								
								
								if (sub_mask_prof==null) {
									cLib.mylog(cLib.LOG_LEVEL_DANGER,"sub profile not found for profild ["+mask_profile_id+"].");
									break;
								}
								
								/*
								cLib.mylog(cLib.LOG_LEVEL_DANGER," REF PROFILE SC : "+short_code);
								cLib.mylog(cLib.LOG_LEVEL_DANGER," REF PROFILE ID : "+mask_profile_id);
								cLib.mylog(cLib.LOG_LEVEL_DANGER," REF PROFILE VL : "+mask_par);								
								cLib.mylog(cLib.LOG_LEVEL_DANGER," REF PROFILE XX : "+js_code.replaceAll("\n|\r", " "));								
								*/
								
								a=mask(
										tab_id, 
										col_id,
										mask_par, 
										hkey_ref_value, 
										Integer.parseInt(mask_profile_id),
										sub_mask_prof,
										currFieldVals,
										engine
									);
								
								//cLib.mylog(cLib.LOG_LEVEL_DANGER," REF PROFILE RT : "+a);
								
							}
							
							
							Matcher matcher_mask_variable = pattern_variable.matcher(mask_piece);
							
							if (matcher_mask_variable.find()) {
								String mask_variable=matcher_mask_variable.group();
								mask_variable=mask_variable.substring(2, mask_variable.length()-2);
								try {
									js_code=js_code.replaceAll("([$])([{])"+mask_variable+"([}])",a);
								} catch(Exception e) {
									
									cLib.mylog(cLib.LOG_LEVEL_DANGER,"Exception@replaceMashVariable("+mask_variable+") with => "+a);
									cLib.mylog(cLib.LOG_LEVEL_DANGER,"Js Code : "+js_code);
									cLib.mylog(cLib.LOG_LEVEL_DANGER,"Trace   : "+genLib.getStackTraceAsStringBuilder(e).toString());

								}
								
							} //if (matcher_mask_variable.find()) {
							
							//cLib.mylog(cLib.LOG_LEVEL_DANGER," REF PROFILE XX2 : "+js_code.replaceAll("\n|\r", " "));
							
							
							
						} //if (matcher_mask_par.find()) {
						
					} //if (matcher_short_code.find()) {
					
				} //if  (!matcher.find()) break;
				
			} //while (true)
			
			//cLib.mylog(cLib.LOG_LEVEL_DANGER,"*********************************************************************");
			
		} //if (js_code.contains("$mask("))


		
		
		try {
			ret1=""+ engine.eval(js_code);
		} catch (Exception e) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER,"EXCEPTION AT SCRIP : ");
			cLib.mylog(cLib.LOG_LEVEL_DANGER,"=====================================");
			cLib.mylog(cLib.LOG_LEVEL_DANGER,js_code);
			cLib.mylog(cLib.LOG_LEVEL_DANGER,"=====================================");
			e.printStackTrace();
			ret1=orig_value;
		}
		
		
	}
	else {
		ret1=orig_value;
	}
	

	return ret1;
	
	}

	//**************************************************
	private String getMaskIdByShortCode(String shortCode) {
		String ret1="-1";
		for (int i=0;i<mask_Profiles.size();i++) {
			String[] a_profile=mask_Profiles.get(i);
			if (a_profile[MASK_PRFL_FLD_SHORT_CODE].equals(shortCode)) {
				ret1=a_profile[MASK_PRFL_FLD_ID];
				break;
			}
		}
		
		return ret1;
	}
	private String maskSQL(int tab_id, String val, String sql_code) {
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			if (sql_code.contains("=?") ||sql_code.contains("= ?")) {
				bindlist.add(new String[]{"STRING",val});
			}
			
			ArrayList<String[]> retArr=cLib.getDbArray(confDB, sql_code, 1, bindlist);
			
			if (retArr==null || retArr.size()==0)
				return "!NO_DATA_FOUND!";
			return retArr.get(0)[0];
			
		}
	
	
	
	static final String TYPE_LIST_STRING="VARCHAR2,CHAR,VARCHAR,LONGVARCHAR,NCHAR,NVARCHAR,NLONGVARCHAR,LONG,TEXT,CHARACTER,CHARACTER VARYING,BPCHAR";
	static final String TYPE_LIST_INT="NUMBER,TINYINT,SMALLINT,INTEGER,BIGINT,FLOAT,REAL,DOUBLE,NUMERIC,DECIMAL,INT IDENTITY,NUMERIC IDENTITY,SERIAL,INT2,INT4,BIGSERIAL,SMALLSERIAL";
	static final String TYPE_LIST_DATE="DATE,TIME,TIMESTAMP,SMALLDATETIME,DATETIME,DATETIME2,DATETIMEOFFSET,TIME";
	static final String TYPE_LIST_BLOB="BLOB,LONGBLOB,MEDIUMBLOB,TINYBLOB,LONGVARBINARY,BINARY,VARBINARY,OTHER,BYTEA";
	static final String TYPE_LIST_CLOB="CLOB,LONGCLOB,MEDIUMCLOB,TINYBCLOB,LONGVARCHAR,MEDIUMVARCHAR,XML,_TEXT,TSVECTOR";
	
	//-------------------------------------------------------------------------------
	
	String fieldtype2bindtype(String field_type,String orig_val) {

		String bindtype="UNKNOWN";
		
		if (TYPE_LIST_STRING.indexOf(field_type.toUpperCase()) > -1) return  "STRING";
		
		if (TYPE_LIST_INT.indexOf(field_type.toUpperCase()) > -1) {
			bindtype = "INTEGER";
			try {Long.parseLong(orig_val); bindtype = "LONG"; } catch (Exception e) {	}
			try {Integer.parseInt(orig_val); bindtype = "INTEGER"; } catch (Exception e) {	}
			return bindtype;
		}

		if (TYPE_LIST_DATE.indexOf(field_type.toUpperCase()) > -1) 	return "DATE";
		if (TYPE_LIST_CLOB.indexOf(field_type.toUpperCase()) > -1) 	return  "CLOB";
		if (TYPE_LIST_BLOB.indexOf(field_type.toUpperCase()) > -1) 	return  "BLOB";
		if ("ROWID".indexOf(field_type.toUpperCase()) > -1) return  "ROWID";
		
		return bindtype;
		
	}
	
	
	
	//-----------------------------------------------------------------
	DBObject maskJsonDocument(String docstr, String parent, ScriptEngine engine) {
		DBObject doc = (DBObject) JSON.parse(docstr);
		Map map=doc.toMap();
		char first_char='x';

		StringBuilder key=new StringBuilder();
		StringBuilder val=new StringBuilder();
		StringBuilder maskedVal=new StringBuilder();
		
		StringBuilder matchkeyname=new StringBuilder();
		
		int mask_profile_id=0;
		
		StringBuilder hkey_ref_value=new StringBuilder();
		
		for (Object obj:  map.keySet()) {
			key.setLength(0);			
			val.setLength(0);
			
			key.append(obj.toString());
			
			//catch nullPointerException
			try {
				val.append(map.get(key.toString()).toString());
			} catch(Exception e) {}
			
			
			
			
			if (val.length()==0) continue;
			
			matchkeyname.setLength(0);
			if (parent.length()>0) matchkeyname.append(parent+".");
			matchkeyname.append(key);
			
			
			
			try{first_char=val.toString().trim().charAt(0);} catch(Exception e) {first_char='x';}
			
			if (first_char=='{' || first_char=='[')  
				map.put(obj, maskJsonDocument(val.toString(),matchkeyname.toString(), engine));
			
				
			//-------------------------------------------------------------------
			for (int p=0;p<field_names.size();p++) {
				
				if (field_mask_rules.get(p).equals(MASK_RULE_HASH_REF)) {
					Pattern r = Pattern.compile(field_names.get(p));
					Matcher m = r.matcher(matchkeyname.toString());
					if (m.find()) 
						hkey_ref_value.append(val.toString());
				}
				
			}
			//-------------------------------------------------------------------
						
			for (int p=0;p<field_names.size();p++) {
				
				if (field_mask_rules.get(p).equals("NONE")) continue;
				
				
				
				Pattern r = Pattern.compile("^"+field_names.get(p)+"$");
				Matcher m = r.matcher(matchkeyname.toString());
				
				if (m.find()) {
					
					mask_profile_id=decodeMaskParam(
							""+export_tab_id, 
							export_schema+"."+export_table, 
							field_names.get(p), new String[1]);
					
					maskedVal.setLength(0);
					maskedVal.append(
								mask( 
									export_tab_id,
									p, 
									val.toString(),  
									hkey_ref_value, 
									mask_profile_id, 
									getMaskProfileById(mask_profile_id), 
									new String[1],
									engine
									)
								);
					
					
					//map.put(obj, "Masked " +val.toString());
					map.put(obj,maskedVal.toString());
					
					
					
					break;
				} 
			}
			
		}
		
		doc.putAll(map);
		
		return doc;
		
	}
	
	//-----------------------------------------------------------------
	String getParallelCondition(Connection conn, int  wpc_id) {
		String sql="select parallel_condition from tdm_work_package where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",""+wpc_id});
		ArrayList<String[]> arr=cLib.getDbArray(conn, sql, 1, bindlist);
		if (arr==null||arr.size()==0) return "";
		return arr.get(0)[0];
		
	}
	
	//-----------------------------------------------------------------
	String getFilterCondition(Connection conn, int  wpc_id) {
		String sql="select filter_condition from tdm_work_package where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",""+wpc_id});
		ArrayList<String[]> arr=cLib.getDbArray(conn, sql, 1, bindlist);
		if (arr==null||arr.size()==0) return "";
		return arr.get(0)[0];
		
	}
	
	//--------------------------------------------------------------------
		void countWorkPackage(ConfDBOper dbCount) {
			String sql="";
			
			
			
			sql="select id, status, all_count, done_count, success_count, fail_count, "+
				" TIMESTAMPDIFF(SECOND, assign_date, now()) assigned_for "+
					" from tdm_task_"+this.work_plan_id+"_"+this.work_package_id;
			
			ArrayList<String[]> arr=cLib.getDbArray(dbCount.connConf, sql, Integer.MAX_VALUE, null);
			if (arr==null) return;
			int task_size=arr.size();
			
			cLib.mylog(cLib.LOG_LEVEL_INFO, "Started Counting for "+ task_size + " tasks...");
			
			
			long task_id=0;
			int task_all_count=0;
			int task_done_count=0;
			int task_success_count=0;
			int task_fail_count=0;
			
			long wpc_all_count=0;
			long wpc_done_count=0;
			long wpc_success_count=0;
			long wpc_fail_count=0;
			
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			
			int STALLED_TASK_DURATION=10*60; // as seconds
			
			for (int i=0;i<task_size;i++) {
				task_id=Long.parseLong(arr.get(i)[0]);
				
				
				try{task_all_count=Integer.parseInt(arr.get(i)[2]);} catch(Exception e) {task_all_count=0;  e.printStackTrace();}
				try{task_done_count=Integer.parseInt(arr.get(i)[3]);} catch(Exception e) {task_done_count=0; }
				try{task_success_count=Integer.parseInt(arr.get(i)[4]);} catch(Exception e) {task_success_count=0; }
				try{task_fail_count=Integer.parseInt(arr.get(i)[5]);} catch(Exception e) {task_fail_count=0; }
				
				wpc_all_count+=task_all_count;
				wpc_done_count+= task_done_count;
				wpc_success_count+=task_success_count;
				wpc_fail_count+=task_fail_count;
				
				//mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_DEBUG, "checking task " + task_id + " "+task_success_count+"/"+task_all_count+" ... ");
			}
			
			//if (wpc_all_count-wpc_done_count<2000) wpc_done_count=wpc_all_count;
			
			sql="update tdm_work_package "+
					" set export_count=?, all_count=?, done_count=?, success_count=?, fail_count=? "+
					" where id=?";
			
			
			bindlist.clear();
			bindlist.add(new String[]{"LONG",""+wpc_all_count});
			bindlist.add(new String[]{"LONG",""+wpc_all_count});
			bindlist.add(new String[]{"LONG",""+wpc_done_count});
			bindlist.add(new String[]{"LONG",""+wpc_success_count});
			bindlist.add(new String[]{"INTEGER",""+wpc_fail_count});
			bindlist.add(new String[]{"INTEGER",""+work_package_id});
			
			cLib.execSingleUpdateSQL(dbCount.connConf, sql, bindlist);
			
			cLib.mylog(cLib.LOG_LEVEL_INFO, "Counting done for "+ task_size + " tasks...[wpc_id : "+work_package_id+"]");
			
			
		}
		
		
		
		

}
