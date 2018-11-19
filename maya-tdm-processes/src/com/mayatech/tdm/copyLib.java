package com.mayatech.tdm;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.concurrent.ConcurrentHashMap;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

import com.mayatech.baseLibs.genLib;



public class copyLib  {

	
	String target_owner_info="";
	String run_options="";

	boolean is_on_error_stop=true;
	
	boolean error_flag=false;
	int global_error_count=0;	


	ArrayList<Connection> connArr=new ArrayList<Connection>();
	//ArrayList<String> dbTypeArr=new ArrayList<String>();
	//ArrayList<String> dbIdArr=new ArrayList<String>();
	
	
	int source_id=0;
	int target_id=0;
	
	int work_plan_id=0;
	int work_package_id=0;
	
	long next_statistic_ts=0;
	int STATISTIC_INTERVAL=30000;
	
	long sum_retrieve_count=0;
	long sum_copy_count=0;
	long sum_fail_count=0;
	
	
	long last_heartbeat_ts=0;
	
	
	commonLib cLib=null;
	
	
	
	java.util.Locale currLocale=new java.util.Locale("tr", "TR");
	
	ArrayList<String[]> dbDataTypeMapping=new ArrayList<String[]>();
	
	final int ROOT_LEVEL=1;
	
	final int COMMIT_LENGTH=100;
	final int MAX_ROOT_TABLE_THREAD=100;
	final int MAX_COPY_THREAD=200;
	
	final String ROLLBACK_ACTION_DELETE="DEL";
	final String  ROLLBACK_ACTION_UPDATE="UPD";
	
	
	//ssping boolean isOriginatedFromNeed=false;
	
	StringBuilder log=new StringBuilder();
	StringBuilder logerr=new StringBuilder();
	
	ArrayList<String> rollbackSqlArr=new ArrayList<String>();
	ArrayList<Integer[]> rollbackFieldTypeIdArr=new ArrayList<Integer[]>();
	ArrayList<String[]> rollbackFieldTypeNameArr=new ArrayList<String[]>();
	ArrayList<String[]> rollbackArr=new ArrayList<String[]>();
	

	ArrayList<String> appList=new ArrayList<String>();
	
	

	
	public final String MASK_RULE_FIXED="FIXED";
	public final String MASK_RULE_NONE="NONE";
	public final String MASK_RULE_HIDE="HIDE";
	public final String MASK_RULE_HASHLIST="HASHLIST";
	public final String MASK_RULE_KEYMAP="KEYMAP";
	public final String MASK_RULE_REPLACE_ALL="REPLACE_ALL";
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
	public final String MASK_RULE_COPY_REF="COPY_REF";
	
	ArrayList<ArrayList<String[]>> globalListArr=new ArrayList<ArrayList<String[]>>();
	@SuppressWarnings("rawtypes")

	
	ConcurrentHashMap hm = new ConcurrentHashMap();
	
	ConcurrentHashMap<String, Boolean> hmNeed = new ConcurrentHashMap<String, Boolean>();
	ConcurrentHashMap<String, Boolean> hmCpOk = new ConcurrentHashMap<String, Boolean>();
	ConcurrentHashMap<String, String> hmMaskedVal = new ConcurrentHashMap<String, String>();
	ConcurrentHashMap<String, Boolean> hmwait= new ConcurrentHashMap<String, Boolean>();
	

	static final int FIELD_COLS_FIELD_NAME=0;
	static final int FIELD_COLS_FIELD_TYPE=1;
	static final int FIELD_COLS_IS_PK=2;
	static final int FIELD_COLS_BINDING_TYPE=3;
	static final int FIELD_COLS_MASK_PROF_ID=4;
	static final int FIELD_COLS_IS_CONDITIONAL=5;
	static final int FIELD_COLS_CONDITION_EXPR=6;
	static final int FIELD_COLS_LIST_FIELD_NAME=7;
	static final int FIELD_COLS_MASK_PROF_RULE_ID=8;
	static final int FIELD_COLS_COPY_REF_TAB_ID=9;
	static final int FIELD_COLS_COPY_REF_FIELD_NAME=10;
	static final int FIELD_COLS_COPY_REF_TAB_APP_ID=11;

	
	static final String CONST_NO="NO";
	static final String CONST_YES="YES";
	
	static final String CONST_UPPERCASE="UPPERCASE";
	static final String CONST_LOWERCASE="LOWERCASE";
	static final String CONST_INITIALS="INITIALS";
	static final String CONST_EMPTY_STR="";
	static final String CONST_DASH="-";
	
	ScriptEngineManager factory=null;
	ScriptEngine engine=null;

	
	//-------------------------------------------------------
	public copyLib() {
		cLib=new commonLib();
		
		try {
			String env_locale=genLib.getEnvValue("LOCALE");
			String locale_p1=env_locale.split(",")[0];
			String locale_p2=env_locale.split(",")[1];
			
			if (locale_p1.length()>0 && locale_p2.length()>0) currLocale=new java.util.Locale(locale_p1, locale_p2);
		} catch(Exception e) {}
		
		loadDbDataTypeMapping();
		
		String conf_driver=genLib.nvl(genLib.getEnvValue("CONFIG_DRIVER"),"<null>");
		String conf_connstr=genLib.nvl(genLib.getEnvValue("CONFIG_CONNSTR"),"<null>");
		String conf_username=genLib.nvl(genLib.getEnvValue("CONFIG_USERNAME"),"<null>");
		String conf_password=genLib.nvl(genLib.getEnvValue("CONFIG_PASSWORD"),"<null>");
		
		
		
		
		cLib.mylog(cLib.LOG_LEVEL_INFO, "Connected to configuration DB.");
	}
	
	
	//------------------------------
	void loadDbDataTypeMapping() {
		
		//ORACLE DATA TYPES
		dbDataTypeMapping.add(new String[]{"ORACLE","CHAR",				"STRING"});
		dbDataTypeMapping.add(new String[]{"ORACLE","VARCHAR2",			"STRING"});
		dbDataTypeMapping.add(new String[]{"ORACLE","VARCHAR",			"STRING"});
		dbDataTypeMapping.add(new String[]{"ORACLE","NCHAR",			"STRING"});
		dbDataTypeMapping.add(new String[]{"ORACLE","NVARCHAR2",		"STRING"});
		dbDataTypeMapping.add(new String[]{"ORACLE","CLOB",				"STRING"});
		dbDataTypeMapping.add(new String[]{"ORACLE","LONG",				"STRING"});
		dbDataTypeMapping.add(new String[]{"ORACLE","NCLOB",			"STRING"});
		dbDataTypeMapping.add(new String[]{"ORACLE","NUMBER",			"NUMERIC"});
		dbDataTypeMapping.add(new String[]{"ORACLE","FLOAT",			"NUMERIC"});
		dbDataTypeMapping.add(new String[]{"ORACLE","BINARY_FLOAT",		"FLOAT"});
		dbDataTypeMapping.add(new String[]{"ORACLE","BINARY_DOUBLE",	"DOUBLE"});
		dbDataTypeMapping.add(new String[]{"ORACLE","DATE",				"DATE"});
		dbDataTypeMapping.add(new String[]{"ORACLE","TIMESTAMP",		"TIMESTAMP"});
		dbDataTypeMapping.add(new String[]{"ORACLE","TIMESTAMP(6)",		"TIMESTAMP"});
		dbDataTypeMapping.add(new String[]{"ORACLE","TIMESTAMP(6) WITH TIME ZONE",		"TIMESTAMP"});
		dbDataTypeMapping.add(new String[]{"ORACLE","TIMESTAMP(6) WITH LOCAL TIME ZONE",		"TIMESTAMP"});
		dbDataTypeMapping.add(new String[]{"ORACLE","BLOB",				"BYTE"});
		dbDataTypeMapping.add(new String[]{"ORACLE","ROWID",			"BYTE"});
		dbDataTypeMapping.add(new String[]{"ORACLE","UROWID",			"BYTE"});
		dbDataTypeMapping.add(new String[]{"ORACLE","XMLTYPE",			"STRING"});
		
		
		
		dbDataTypeMapping.add(new String[]{"MSSQL","CHAR",				"STRING"});
		dbDataTypeMapping.add(new String[]{"MSSQL","NCHAR",				"STRING"});
		dbDataTypeMapping.add(new String[]{"MSSQL","VARCHAR",			"STRING"});
		dbDataTypeMapping.add(new String[]{"MSSQL","NVARCHAR",			"STRING"});
		dbDataTypeMapping.add(new String[]{"MSSQL","TEXT",				"STRING"});
		dbDataTypeMapping.add(new String[]{"MSSQL","NTEXT",				"STRING"});
		dbDataTypeMapping.add(new String[]{"MSSQL","INT IDENTITY",		"NUMERIC"});
		dbDataTypeMapping.add(new String[]{"MSSQL","INT",				"NUMERIC"});
		dbDataTypeMapping.add(new String[]{"MSSQL","BIGINT",			"NUMERIC"});
		dbDataTypeMapping.add(new String[]{"MSSQL","SMALLINT",			"NUMERIC"});
		dbDataTypeMapping.add(new String[]{"MSSQL","TINYLINT",			"NUMERIC"});
		dbDataTypeMapping.add(new String[]{"MSSQL","NUMERIC",			"NUMERIC"});
		dbDataTypeMapping.add(new String[]{"MSSQL","DECIMAL",			"FLOAT"});
		dbDataTypeMapping.add(new String[]{"MSSQL","MONEY",				"FLOAT"});
		dbDataTypeMapping.add(new String[]{"MSSQL","FLOAT",				"FLOAT"});
		dbDataTypeMapping.add(new String[]{"MSSQL","REAL",				"FLOAT"});
		dbDataTypeMapping.add(new String[]{"MSSQL","DATE",				"DATE"});
		dbDataTypeMapping.add(new String[]{"MSSQL","DATETIMEOFFSET",	"DATE"});
		dbDataTypeMapping.add(new String[]{"MSSQL","DATETIME",			"DATE"});
		dbDataTypeMapping.add(new String[]{"MSSQL","DATETIME2",			"DATE"});
		dbDataTypeMapping.add(new String[]{"MSSQL","TIME",				"DATE"});
		dbDataTypeMapping.add(new String[]{"MSSQL","TIMESTAMP",			"TIMESTAMP"});
		dbDataTypeMapping.add(new String[]{"MSSQL","SMALLDATETIME",		"DATE"});
		dbDataTypeMapping.add(new String[]{"MSSQL","BINARY",			"BYTE"});
		dbDataTypeMapping.add(new String[]{"MSSQL","IMAGE",				"BINARY"});
		dbDataTypeMapping.add(new String[]{"MSSQL","VARBINARY",			"BYTE"});
		dbDataTypeMapping.add(new String[]{"MSSQL","BIT",				"BOOLEAN"});

		
		
	}
	
	//-----------------------------
	String getBindingType(String db_type, String colType) {
		
		String check_col_type=colType.replaceAll(" identity", "");
		
		for (int i=0;i<dbDataTypeMapping.size();i++) {
			String a_db_type=dbDataTypeMapping.get(i)[0];
			String a_col_type=dbDataTypeMapping.get(i)[1];
			String a_binding_type=dbDataTypeMapping.get(i)[2];
			
			
			if (db_type.equals(a_db_type) && check_col_type.toUpperCase().equals(a_col_type.toUpperCase())) {
				return a_binding_type;
			}
		}
		
		
		
		return "UNKNOWN";
	}
	
	static final int MAX_LOG_LENGTH=5*1024*1024;
	
	//------------------------------
	void mylog(String logx) {
		
		
		System.out.println(logx);
		
		try {
			if (log!=null)  
				log.append(logx+"\n");
			if (logx.contains("Exception") || logx.contains("error")) myerr(logx);
			
			if (log.length()>MAX_LOG_LENGTH) 
				log.delete(0, MAX_LOG_LENGTH/5);
		} catch(Exception e) {
			
		}
		
	}
	
	//------------------------------
	void myerr( String logx) {
		System.out.println(logx);
		
		try {
			logerr.append(logx+"\n");
			
			if (logerr.length()>MAX_LOG_LENGTH) 
				logerr.delete(0, MAX_LOG_LENGTH/5);
		} catch(Exception e) {
			
		}
		
		
	} 


	
	
	
	//--------------------------------------
	void closeAll() {
		
		waitCancelCheckAndTestConnTheadsFinished();
		
		for (int i=0;i<connArr.size();i++) 
			try{
				mylog("Connection["+(i+1)+"] is closing...");
				connArr.get(i).close();
				} catch(Exception e) {}
		

		try {
			//confDb.close();
			mylog("Config db connection is closing...");
			} catch(Exception e) {}
		

		
	}
	//--------------------------------------------------------------------------
	void loadTableConfig(
			ConfDBOper db,
			ArrayList<copyTableObj> tableArr, 
			int app_id, 
			String copy_filter_id, 
			String user_filter_value) {
		
		
		String sql="";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String user_filter_type="";
		String user_filter_sql="";
		String user_filter_values=user_filter_value;
		
		
		sql="select filter_type, filter_sql from tdm_copy_filter where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",copy_filter_id});
		ArrayList<String[]> filterArr=cLib.getDbArray(db.connConf,sql, 1, bindlist);
		
		if (filterArr.size()==1) {
			user_filter_type=filterArr.get(0)[0];
			user_filter_sql=filterArr.get(0)[1];
			
			if (user_filter_type.equals("NO_FILTER")) user_filter_sql="";
			
			hm.put("FILTER_TYPE_"+copy_filter_id, user_filter_type);
		}
			
		String partition_name="";
		
		if (user_filter_type.equals("MANUAL_CONDITION") || user_filter_type.equals("BY_PARTITION")) {
			String par_tab_id="";
			String par_2="";
			
			int pospp=user_filter_values.indexOf("++");
			
			try{par_tab_id=user_filter_values.substring(0,pospp);} catch(Exception e) {par_tab_id="0";}
			try{par_2=user_filter_values.substring(pospp+2);} catch(Exception e) {par_2="";}
			
			if (!par_tab_id.equals("0")) par_tab_id=genLib.decrypt(par_tab_id);
			if (par_2.length()>0) par_2=genLib.decrypt(par_2);
			
			
			
			if (user_filter_type.equals("BY_PARTITION")) 	partition_name=par_2;
			
			
			if (user_filter_type.equals("MANUAL_CONDITION") && par_2.trim().length()>0) {
				
				user_filter_sql=par_2;
				//get table info from single table
				
			}
			
			sql="select id, cat_name, schema_name, tab_name, family_id from tdm_tabs t where id=? ";
			
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+par_tab_id});
			
			
		} else {
			//get all root tables of the application
			sql="select id, cat_name, schema_name, tab_name, family_id  "+
				"	from tdm_tabs t " + 
				"	where app_id=? " + 
				"	and not exists (select 1 from tdm_tabs_rel where rel_tab_id=t.id and rel_type='HAS') "+
				"   order by t.tab_order";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+app_id});
			
		}
		
		mylog("***************   sql "+sql);
		
		ArrayList<String[]> arr=cLib.getDbArray(db.connConf,sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<arr.size();i++) {
			int tab_id=Integer.parseInt(arr.get(i)[0]);
			String cat_name=arr.get(i)[1];
			String schema_name=arr.get(i)[2];
			String tab_name=arr.get(i)[3];
			String family_id=arr.get(i)[4];
			
			addNewTable(
					db, 
					app_id, 
					tableArr, 
					0, 
					tab_id, 
					ROOT_LEVEL, 
					cat_name, 
					schema_name, 
					tab_name, 
					partition_name, 
					user_filter_type, 
					user_filter_sql, 
					user_filter_values, 
					family_id
					);
		}
		
	}
	
	//--------------------------------------------------------------------------
	
	
	int addNewTable(
			ConfDBOper db,
			int app_id,
			ArrayList<copyTableObj> tableArr,
			int parent_tab_id, 
			int tab_id, 
			int level, 
			String catalog,
			String owner, 
			String table_name,
			String partition_name,
			String  user_filter_type,
			String  user_filter_sql,
			String user_filter_values,
			String family_id
			) {
		String sql="";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		

		copyTableObj ct=new copyTableObj();
		ct.setTable(parent_tab_id, tab_id, app_id, level, catalog, owner, table_name, family_id);
		
		
		ct.source_catalog=ct.catalog;
		ct.source_owner=ct.owner;
		ct.source_table_name=ct.table_name;
		ct.source_partition_name=partition_name;
		
		
		ct.target_catalog=ct.catalog;
		ct.target_owner=ct.owner;
		ct.target_table_name=ct.table_name;
		
		ct.family_id=family_id;
		
		ct.user_filter_type=user_filter_type;
		ct.user_filter_sql=user_filter_sql;
		ct.user_filter_values=user_filter_values;
		
		String parallel_function="";
		String parallel_field="";
		int parallel_count=1;
		
		if (level==ROOT_LEVEL) {
			sql="select parallel_function, parallel_field, parallel_mod from tdm_tabs where id=?";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+ct.tab_id});
			ArrayList<String[]> arr=cLib.getDbArray(db.connConf, sql, 1, bindlist);
			
			if (arr!=null && arr.size()==1) {
				parallel_function=arr.get(0)[0];
				parallel_field=arr.get(0)[1];
				try{parallel_count=Integer.parseInt(arr.get(0)[2]);} catch(Exception e) {
					parallel_count=1;
				}
			}
		}
		
		
		ct.parallel_function=parallel_function;
		ct.parallel_field=parallel_field;
		ct.parallel_count=parallel_count;
		
		
		
		String source_tab=cLib.extractCopySource(this.target_owner_info, catalog+"."+owner+"."+table_name);
		String target_tab=cLib.extractCopyTarget(this.target_owner_info, catalog+"."+owner+"."+table_name);
		
		try{
			String[] arr=source_tab.split("\\.");
			ct.source_catalog=arr[0];
			ct.source_owner=arr[1];
			ct.source_table_name=arr[2];
		} catch(Exception e) {e.printStackTrace();}
		
		try{
			String[] arr=target_tab.split("\\.");
			ct.target_catalog=arr[0];
			ct.target_owner=arr[1];
			ct.target_table_name=arr[2];
		} catch(Exception e) {e.printStackTrace();}
		
		String source_db_id="0";
		String target_db_id="0";
		
		sql="select env_id from tdm_target_family_env where target_id=? and family_id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+source_id});
		bindlist.add(new String[]{"INTEGER",family_id});
		ArrayList<String[]> dbarr1=cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		if (dbarr1!=null && dbarr1.size()==1) 
			source_db_id=dbarr1.get(0)[0];
		
		hm.put("DB_ID_"+source_id+"_"+family_id, source_db_id);
		
			
		
		sql="select env_id from tdm_target_family_env where target_id=? and family_id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+target_id});
		bindlist.add(new String[]{"INTEGER",family_id});
		ArrayList<String[]> dbarr2=cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		if (dbarr2!=null && dbarr2.size()==1) 
			target_db_id=dbarr2.get(0)[0];
		
		hm.put("DB_ID_"+target_id+"_"+family_id, target_db_id);
		
		
		int source_db_instance_id=getDBArrInstance(db, "SOURCE",source_db_id);
		int target_db_instance_id=getDBArrInstance(db, "TARGET",target_db_id);

		
		String source_db_type=getDbInstanceDbType(source_db_instance_id);
		String target_db_type=getDbInstanceDbType(target_db_instance_id);
	
		
		ct.setDbInfo(source_db_type, target_db_type, source_db_id, target_db_id);
		
		int next_tab_obj_id=tableArr.size();
		ct.setTableObjId(next_tab_obj_id);
		
		long ts_field_list=System.currentTimeMillis();
		
		ArrayList<String[]> SourceFieldList=cLib.getFieldListFromDb(
				connArr.get(source_db_instance_id), 
				ct.source_catalog,
				ct.source_owner, 
				ct.source_table_name, 
				source_db_type
				);
		
		ArrayList<String[]> TargetFieldList=cLib.getFieldListFromDb(
				connArr.get(target_db_instance_id), 
				ct.target_catalog,
				ct.target_owner, 
				ct.target_table_name, 
				target_db_type);
		
		
		//identity alanlarda (autoincrement) direk deðer insert etmeye izin vermesini saðlýyoruz
		if (target_db_type.equals("MSSQL")) {	
			String set_sql="SET IDENTITY_INSERT \""+ct.target_owner+"\".\""+ct.target_table_name+"\" ON";
			mylog("Executing : "+set_sql);
			cLib.setCatalogForConnection(connArr.get(target_db_instance_id), ct.target_catalog);
			boolean is_ok=cLib.execAppScript(connArr.get(target_db_instance_id), set_sql);
			if (is_ok) mylog("SET IDENTITY_INSERT OK");
		}
		
		
		tableArr.add(ct);
		
		sql="select f.field_name, "+
				" f.field_type, "+
				" f.is_pk, "+
				" f.mask_prof_id, "+
				" f.is_conditional, "+
				" f.condition_expr, "+
				" f.list_field_name, "+
				" (select rule_id from tdm_mask_prof where id=f.mask_prof_id ) mask_prof_rule_id, " + 
				" f.copy_ref_tab_id, "+
				" f.copy_ref_field_name, "+
				" t.app_id " + 
				" from tdm_fields f, tdm_tabs t, tdm_apps a where tab_id=? and tab_id=t.id and t.app_id=a.id";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+tab_id});
		
		ArrayList<String[]> arr=cLib.getDbArray(db.connConf, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<arr.size();i++) {

			
			String field_name=arr.get(i)[0];
			String field_type=arr.get(i)[1];
			String is_pk=arr.get(i)[2];
			String mask_prof_id=arr.get(i)[3];
			String is_conditional=arr.get(i)[4];
			String condition_expr=arr.get(i)[5];
			String list_field_name=arr.get(i)[6];
			String mask_prof_rule_id=arr.get(i)[7];
			String copy_ref_tab_id=arr.get(i)[8];
			String copy_ref_field_name=arr.get(i)[9];
			
			//skip field if not exists in source
			boolean found_on_source_or_target=false;
			for (int s=0;s<SourceFieldList.size();s++) 
				if (SourceFieldList.get(s)[0].equals(field_name)) {
					found_on_source_or_target=true;
					break;
				}
			
			for (int s=0;s<TargetFieldList.size();s++) 
				if (TargetFieldList.get(s)[0].equals(field_name)) {
					found_on_source_or_target=true;
					break;
				}
			
			if (!found_on_source_or_target) continue;
			
			String binding_type=getBindingType(ct.source_db_type, field_type);
			
			//mylog("\t...."+field_type+" binds to "+binding_type);
						
			ct.addField(
					field_name, 
					field_type, 
					is_pk, 
					binding_type, 
					mask_prof_id, 
					is_conditional, 
					condition_expr, 
					list_field_name,
					mask_prof_rule_id,
					copy_ref_tab_id,
					copy_ref_field_name
					);
			
		}
		
		//add new added source fields to the configuration field
		for (int s=0;s<SourceFieldList.size();s++) {
			

			String source_field_name=SourceFieldList.get(s)[0];
			boolean found_in_conf_field=false;
			for (int c=0;c<ct.fields.size();c++) {
				String conf_field_name=ct.fields.get(c)[0];
				if (conf_field_name.equals(source_field_name)) {
					found_in_conf_field=true;
					break;
				}
			}
			
			boolean found_in_target=false;
			
			for (int t=0;t<TargetFieldList.size();t++) 
				if (TargetFieldList.get(t)[0].equals(source_field_name)) {
					found_in_target=true;
					break;
				}
			
			if (found_in_conf_field) continue;
			if (!found_in_target) continue;

			String source_field_type=SourceFieldList.get(s)[1];
			String source_field_size=SourceFieldList.get(s)[2];
			String source_field_is_pk=SourceFieldList.get(s)[3];

			
			String binding_type=getBindingType(ct.source_db_type, source_field_type);
			

			
			ct.addField(
					source_field_name, 
					source_field_type, 
					source_field_is_pk, 
					binding_type, 
					"0", 	// mask_prof_id, 
					"NO", 	//is_conditional, 
					"", 	//condition_expr, 
					"",		//list_field_name,
					"", 	//mask_prof_rule_id,
					"",		//copy_ref_tab_id,
					""		//copy_ref_field_name
					);
		}
		
		
		//Adding Extra columns on target db
		
		String[] extraFieldActions=run_options.split("\n|\r");
		
		
		if (TargetFieldList.size()>0) {
			String extra_fields_sql="select ";
			
			int added_extra_field_count=0;
			
			for (int s=0;s<TargetFieldList.size();s++) {
				String target_field_name=TargetFieldList.get(s)[0];
				String target_field_type=TargetFieldList.get(s)[1];
				
				boolean found_in_conf_field=false;
				for (int c=0;c<ct.fields.size();c++) {
					String conf_field_name=ct.fields.get(c)[0];
					if (conf_field_name.equals(target_field_name)) {
						found_in_conf_field=true;
						break;
					}
				}
				
				if (found_in_conf_field) continue;
				
				String extra_col_info=ct.target_owner+"."+ct.target_table_name+"."+target_field_name;
				String action_id="SKIP";
				for (int a=0;a<extraFieldActions.length;a++) {
					if (extraFieldActions[a].trim().length()==0) continue;
					if (!extraFieldActions[a].trim().contains("=")) continue;
					int ind=extraFieldActions[a].indexOf("=");
					String col_info=extraFieldActions[a].substring(0,ind);
					if (!col_info.equals(extra_col_info)) continue;
					
					try {action_id=genLib.nvl(extraFieldActions[a].substring(ind+1),"SKIP");} catch(Exception e) {}
					
					break;
				}
				
				if (action_id.equals("SKIP")) continue;
				
				String binding_type=getBindingType(ct.target_db_type, target_field_type);
				

				if (ct.extraFields.size()>0) extra_fields_sql=extra_fields_sql+", " ;
				extra_fields_sql=extra_fields_sql+target_field_name;
				
				ct.addExtraField(
						target_field_name, 
						target_field_type, 
						binding_type, 
						action_id
						);
				added_extra_field_count++;
				
				
			} // for 
			
			extra_fields_sql=extra_fields_sql+" from " + ct.target_owner+"."+ct.target_table_name;
			
			if (added_extra_field_count>0) {
				try {
					
					long st_extra_field_stmt=System.currentTimeMillis();
					
					
					PreparedStatement pstmextra=connArr.get(target_db_instance_id).prepareStatement(extra_fields_sql);
					
					ResultSet rsextra=pstmextra.executeQuery();
					ResultSetMetaData rsmdextra = rsextra.getMetaData();
					
					
					for (int f=0;f<rsmdextra.getColumnCount();f++) {
						
						int 	ColumnType=rsmdextra.getColumnType(f+1);
						ct.extraFieldTypes.add(ColumnType);
					}
					
					
				} catch(Exception e) {
					e.printStackTrace();
					mylog("Exception@makeNewTable.ExtraFields : " + extra_fields_sql);
					mylog("Exception@makeNewTable.ExtraFields : " + genLib.getStackTraceAsStringBuilder(e).toString());
				}
			}
			
			
			
		} //if (TargetFieldList.size()>0)
		
		
		releaseDbInstance(source_db_instance_id);
		releaseDbInstance(target_db_instance_id);
		
		
		//Adding Child Tables
		sql="select t.id, cat_name, schema_name, tab_name, family_id  "+
			"	from tdm_tabs t, tdm_tabs_rel " + 
			"	where app_id=? and t.id=rel_tab_id" + 
			"	and rel_type='HAS' and tab_id=? "+
			" order by rel_order ";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+app_id});
		bindlist.add(new String[]{"INTEGER",""+tab_id});
		
		
		arr=cLib.getDbArray(db.connConf, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<arr.size();i++) {
			int child_tab_id=Integer.parseInt(arr.get(i)[0]);
			String child_cat_name=arr.get(i)[1];
			String child_schema_name=arr.get(i)[2];
			String child_tab_name=arr.get(i)[3];
			String child_partition_name="";
			String child_family_id=arr.get(i)[4];
			
			int child_tab_obj_id=addNewTable(db, app_id, tableArr, tab_id, child_tab_id,level+1,child_cat_name, child_schema_name,child_tab_name, child_partition_name,"", "", "", child_family_id);
			ct.addChildTabObjId(child_tab_obj_id);
		}
		
		
		//Adding Needs
		sql="select n.app_id, n.copy_filter_id, n.rel_on_fields, a.name application_name, f.filter_name  "+
				" from tdm_tabs_need n, tdm_apps a, tdm_copy_filter f " +
				" where n.tab_id=? "+
				" and n.app_id=a.id and n.copy_filter_id=f.id "+
				" order by n.id ";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+tab_id});
		
		arr=cLib.getDbArray(db.connConf, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<arr.size();i++) {
			
			String needing_app_id=arr.get(i)[0];
			String copy_filter_id=arr.get(i)[1];
			String rel_on_fields=arr.get(i)[2];
			String application_name=arr.get(i)[3];
			String filter_name=arr.get(i)[4];
			
			
			ct.needRelArr.add(new String[]{needing_app_id,copy_filter_id,rel_on_fields,application_name,filter_name});	

		}
		
		return next_tab_obj_id;
	}
	
	
	//--------------------------------------------------------------------------
	ArrayList<Integer> getRootTableIds(ArrayList<copyTableObj> tableArr) {
		
		ArrayList<Integer> rootTableObjIds=new ArrayList<Integer>();
		for (int i=0;i<tableArr.size();i++)
			if (tableArr.get(i).level==ROOT_LEVEL)
				rootTableObjIds.add(i);
		
		return rootTableObjIds;
	}
	
	
	//--------------------------------------------------------------------------
	
	
	ThreadGroup rootCopyThreadGroup=new ThreadGroup("ROOT_COPY_GRP");
	
	long copyTable(
			Connection connSource,
			Connection connTarget,
			ConfDBOper db,
			ArrayList<copyTableObj> copyTableArr,
			ArrayList<String> copyRefFieldsArr,
			copyTableObj ct, 
			ArrayList<String>  parentRecord,
			boolean is_changed,
			ArrayList<String> parentChangedRecord,
			ArrayList<Boolean> changeStatus,
			boolean RecursiveMode,
			boolean isOriginatedFromNeed,
			String filter_value
			) {
		
		if (error_flag) return 0;
		 
		long ret1=0;
		
		
		try {


			if (isOriginatedFromNeed ||    ct.parallel_count==1) {
									
				if (connSource!=null) 
					copyTableDo(
							connSource,
							connTarget,
							db, 
							copyTableArr,
							copyRefFieldsArr,
							ct, 
							parentRecord, 
							is_changed, 
							parentChangedRecord, 
							changeStatus, 
							RecursiveMode,
							isOriginatedFromNeed,
							0,
							filter_value
							);
				else {
					int source_db_instance_id=getDBArrInstance(db, "SOURCE",ct.source_db_id);
					int target_db_instance_id=getDBArrInstance(db, "TARGET",ct.target_db_id);
					
					copyTableDo(
							connArr.get(source_db_instance_id),
							connArr.get(target_db_instance_id),
							db, 
							copyTableArr,
							copyRefFieldsArr,
							ct, 
							parentRecord,
							is_changed, 
							parentChangedRecord, 
							changeStatus, 
							RecursiveMode,
							isOriginatedFromNeed,
							0,
							filter_value
							);
					
					releaseDbInstance(source_db_instance_id);
					releaseDbInstance(target_db_instance_id);
				}
					
				getStatistics(db, true,isOriginatedFromNeed);
				
			}
			else {
				
				ArrayList<ConfDBOper> dbArr=new ArrayList<ConfDBOper>();
				
				ArrayList<Integer> dbIdsRentedArr=new ArrayList<Integer>();
				
				for (int p=0;p<ct.parallel_count;p++) {
					try {
						
						String thread_name="ROOT_COPY_"+ct.tab_id+"-"+ct.table_name+"_"+p;
						
						int source_db_instance_id=getDBArrInstance(db, "SOURCE",ct.source_db_id);
						int target_db_instance_id=getDBArrInstance(db, "TARGET",ct.target_db_id);
						
						dbIdsRentedArr.add(source_db_instance_id);
						dbIdsRentedArr.add(target_db_instance_id);
						
						dbArr.add(new ConfDBOper(false));
						dbArr.get(p).master_id=db.master_id;
						
						Thread thread=new Thread(rootCopyThreadGroup, 
								new rootCopyThread(
												this,
												connArr.get(source_db_instance_id),
												connArr.get(target_db_instance_id),
												dbArr.get(p), 
												copyTableArr,
												copyRefFieldsArr,
												ct, 
												parentRecord, //parentRecord, 
												is_changed, 
												parentChangedRecord, 
												changeStatus, 
												RecursiveMode,
												p,
												filter_value
												),
								thread_name);
						
						thread.start();
						//thread.run();
						
						
					} catch(Exception e) {
						cLib.mylog(cLib.LOG_LEVEL_DANGER, "checkCancelForCopyingThread not initiated : "+ e.getMessage());
						e.printStackTrace();
					}
				} //for
				
				Thread.sleep(1000);
				
				waitRootCopyTheadsFinished(db);
				
				waitCancelCheckAndTestConnTheadsFinished();
				
				getStatistics(db, true, isOriginatedFromNeed);


				for (int p=0;p<ct.parallel_count;p++) {
					dbArr.get(p).closeAll();
				}
				
				for (int r=0;r<dbIdsRentedArr.size();r++) 
					releaseDbInstance(dbIdsRentedArr.get(r));
				
			}
					
	
			} catch(Exception e) {
				mylog("Exception@copyTable: "+ e.getMessage());
				mylog("StackTrace : "+genLib.getStackTraceAsStringBuilder(e).toString());
			}
		
		return ret1;
	}
	
	
	
	
	//--------------------------------------------------------------------------
	
	static final int BIND_TYPE=0;
	static final int BIND_VAL=1;
	//--------------------------------------------------------------------------
	ArrayList<String[]> makeBindValuesFromUserFilter(copyTableObj ct, String filter_value, boolean isOriginatedFromNeed) {
		ArrayList<String[]> bindlistUSERFILTER=new ArrayList<String[]>();
		
		
		if (ct.parallel_count>1 && ct.parallel_field.length()>0 && ct.parallel_function.length()>0) 
			bindlistUSERFILTER.add(new String[]{"INTEGER","%PARALLEL_NO%"});
		
		String bind_val_1="";
		String bind_val_2="";
		
		if (!ct.user_filter_type.equals("BY_PARTITION") && !ct.user_filter_type.equals("NO_FILTER") && !ct.user_filter_type.equals("MANUAL_CONDITION")) {
			try {
				bind_val_1=filter_value.split("\\+\\+")[0]; 
				if (bind_val_1.length()>0 && !isOriginatedFromNeed) bind_val_1=genLib.decrypt(bind_val_1);  
				} catch(Exception e) {
					bind_val_1="";
					}
			try {
				bind_val_2=filter_value.split("\\+\\+")[1];
				if (bind_val_2.length()>0 && !isOriginatedFromNeed) bind_val_2=genLib.decrypt(bind_val_2);  
				} catch(Exception e) {
					bind_val_2="";
					}
			
			int bind_count=0;


			
			if (ct.user_filter_sql.contains("?")) 
				bind_count=(" "+ct.user_filter_sql+" ").split("\\?").length-1;
			
			if (bind_val_1.trim().length()>0 && bind_count>0) 
		    	if (ct.user_filter_type.contains("_DATE"))
		    		bindlistUSERFILTER.add(new String[]{"SHORT_DATE_DOTTED",bind_val_1});
		    	else if (ct.user_filter_type.contains("_NUMBER"))
		    		bindlistUSERFILTER.add(new String[]{"INTEGER",bind_val_1});
		    	else
		    		bindlistUSERFILTER.add(new String[]{"STRING",bind_val_1});
			
			
			if (bind_val_2.trim().length()>0 && bind_count>1) 
		    	if (ct.user_filter_type.contains("_DATE"))
		    		bindlistUSERFILTER.add(new String[]{"SHORT_DATE_DOTTED",bind_val_2});
		    	else if (ct.user_filter_type.contains("_NUMBER"))
		    		bindlistUSERFILTER.add(new String[]{"INTEGER",bind_val_2});
		    	else
		    		bindlistUSERFILTER.add(new String[]{"STRING",bind_val_2});
		} //if (!user_filter_type.equals("BY_PARTITION"))
		
		return bindlistUSERFILTER;
	}
	
	

	
	//--------------------------------------------------------------------------
	void copyTableDo(
			Connection connSource,
			Connection connTarget,
			ConfDBOper db,
			ArrayList<copyTableObj> tableArr,
			ArrayList<String> copyRefFieldsArr,
			copyTableObj ct,
			ArrayList<String> parentRecord,
			boolean is_parent_changed,
			ArrayList<String> parentChangedRecord,
			ArrayList<Boolean> parentChangeStatus,
			boolean RecursiveMode,
			boolean isOriginatedFromNeed,
			int parallel_no,
			String filter_value
			) {

		if (error_flag) return;
		
		cLib.setCatalogForConnection(connSource, ct.source_catalog);
		cLib.setCatalogForConnection(connTarget, ct.target_catalog);
		
		boolean is_single=false;
		
		if (!ct.isRecursive &&  !ct.hasParent && !ct.hasChild && !ct.hasNeeds && !ct.hasCheckExistance && ct.extraFields.size()==0 && !isOriginatedFromNeed )
			is_single=true;
		
		boolean is_autocommit=true;
		if (is_single) is_autocommit=false;
		
		try {connTarget.setAutoCommit(is_autocommit);  } catch(Exception e) {}
		
		thread_start_heartbeat=System.currentTimeMillis();
				
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		if (RecursiveMode) {
			for (int r=0;r<ct.thisTablePKEYfieldORDERS.size();r++) {				
				bindlist.add(new String[]{
						ct.fields.get(ct.recursiveFieldIDs.get(r))[3],
						parentRecord.get(ct.thisTablePKEYfieldORDERS.get(r))
						});				
			}
		}
		else if (ct.hasParent &&  parentRecord!=null) {
				
			
				for (int r=0;r<ct.relParentTablePKFieldIDs.size();r++) {				
					bindlist.add(new String[]{
							ct.fields.get(ct.relThisTableFieldIDs.get(r))[3],
							parentRecord.get(ct.relParentTablePKFieldIDs.get(r))
							});
				}

			} 


		ArrayList<String[]> bindlistUSERFILTER=makeBindValuesFromUserFilter(ct, filter_value,isOriginatedFromNeed);
		

		for (int i=0;i<bindlistUSERFILTER.size();i++) {
			if (bindlistUSERFILTER.get(i)[BIND_VAL].equals("%PARALLEL_NO%"))
				bindlist.add(new String[]{bindlistUSERFILTER.get(i)[0],	""+(parallel_no)});
			else 
				bindlist.add(bindlistUSERFILTER.get(i));
			
		}
			
		
		
		StringBuilder userFilterAsStr=new StringBuilder();
		for (int r=0;r<bindlist.size();r++) {
			if (r>0) userFilterAsStr.append(",");
			userFilterAsStr.append(bindlist.get(r)[1]);
			
		}
		

		//if it is not a single table
		if (!is_single) 
			if (hmCpOk.containsKey("CPOK_"+ct.source_owner+"."+ct.source_table_name+"_WITH_"+userFilterAsStr.toString())) {
				return;
			}

		mylog("---------------------------------------------------");


		if (parallel_no>0)
			mylog("Copying "+ct.source_owner+"."+ct.source_table_name+" Params["+userFilterAsStr.toString()+"] Parallel ["+parallel_no+"]");
		else 
			mylog("Copying "+ct.source_owner+"."+ct.source_table_name+" Params["+genLib.nvl(userFilterAsStr.toString(),"${All}")+"]...");
		mylog("---------------------------------------------------");

		
		
		
		long rec_copy_count=0;
				
		
		PreparedStatement pstmtSource = null;
		ResultSet rsetSource = null;
		ResultSetMetaData rsmdSource = null;
		
		PreparedStatement pstmtTarget = null;
		
		boolean is_retrieval_success=false;
		
		
		
		try {
			
		
			
			if (RecursiveMode)
				pstmtSource = connSource.prepareStatement(ct.recursive_sql);
			else
				pstmtSource = connSource.prepareStatement(ct.retrieve_sql);
			
			

			
			for (int b = 0; b < bindlist.size(); b++) {
				 
				if (bindlist.get(b)[BIND_TYPE].equals("NUMERIC")) {
							
					
					boolean is_set=false;
					
					try {
						if (bindlist.get(b)[BIND_VAL].length()>0) {
							try {
								byte num=Byte.parseByte(bindlist.get(b)[BIND_VAL]);
								pstmtSource.setByte(b+1, num);
								is_set=true;
							} catch(Exception e) {}
						} else {
							pstmtSource.setNull(b+1, java.sql.Types.TINYINT);
							is_set=true;
						}
					} catch(Exception e) {} 

					if (!is_set) {
						try {
							if (bindlist.get(b)[BIND_VAL].length()>0) {
								try {
									short num=Short.parseShort(bindlist.get(b)[BIND_VAL]);
									pstmtSource.setShort(b+1, num);
									is_set=true;
								} catch(Exception e) {}
							} else {
								pstmtSource.setNull(b+1, java.sql.Types.SMALLINT);
								is_set=true;
							}
						} catch(Exception e) {} 
					}
					
					if (!is_set) {
						try {
							if (bindlist.get(b)[BIND_VAL].length()>0) {
								try {
									int num=Integer.parseInt(bindlist.get(b)[BIND_VAL]);
									pstmtSource.setInt(b+1, num);
									is_set=true;
								} catch(Exception e) {}
							} else {
								pstmtSource.setNull(b+1, java.sql.Types.INTEGER);
								is_set=true;
							}
						} catch(Exception e) {} 
					}
					
					

					if (!is_set) {
						try {
							if (bindlist.get(b)[BIND_VAL].length()>0) {
								try {
									long num=Long.parseLong(bindlist.get(b)[BIND_VAL]);
									pstmtSource.setLong(b+1, num);
									is_set=true;
								} catch(Exception e) {}
							} else {
								pstmtSource.setNull(b+1, java.sql.Types.BIGINT);
								is_set=true;
							}
						} catch(Exception e) {} 
					}
					
					if (!is_set) {
						try {
							if (bindlist.get(b)[BIND_VAL].length()>0) {
								try {
									float num=Float.parseFloat(bindlist.get(b)[BIND_VAL]);
									pstmtSource.setFloat(b+1, num);
									is_set=true;
								} catch(Exception e) {}
							} else {
								pstmtSource.setNull(b+1, java.sql.Types.FLOAT);
								is_set=true;
							}
						} catch(Exception e) {} 
					}
					
					if (!is_set) {
						try {
							if (bindlist.get(b)[BIND_VAL].length()>0) {
								try {
									double num=Double.parseDouble(bindlist.get(b)[BIND_VAL]);
									pstmtSource.setDouble(b+1, num);
									is_set=true;
								} catch(Exception e) {}
							} else {
								pstmtSource.setNull(b+1, java.sql.Types.DOUBLE);
								is_set=true;
							}
						} catch(Exception e) {} 
					}
						

				} else if (bindlist.get(b)[BIND_TYPE].equals("DATE")) {
					if (bindlist.get(b)[BIND_VAL] == null || bindlist.get(b)[BIND_VAL].equals(""))
						pstmtSource.setNull((b+1), java.sql.Types.DATE);
					else {
						try {
							SimpleDateFormat sdf=new SimpleDateFormat(BIND_DATE_TIME_DEFAULT_TYPE);
							java.sql.Date sqld=new java.sql.Date(sdf.parse(bindlist.get(b)[BIND_VAL]).getTime());
							pstmtSource.setDate((b+1), sqld);
						} catch(Exception e) {
							e.printStackTrace();
						}
					}
				}  else if (bindlist.get(b)[BIND_TYPE].equals("SHORT_DATE_DOTTED")) {
					if (bindlist.get(b)[BIND_VAL] == null || bindlist.get(b)[BIND_VAL].equals(""))
						pstmtSource.setNull((b+1), java.sql.Types.DATE);
					else {
						try {
							
							SimpleDateFormat sdf=new SimpleDateFormat(BIND_DATE_TIME_SHORT_DOTTED_TYPE);
							java.sql.Date sqld=new java.sql.Date(sdf.parse(bindlist.get(b)[BIND_VAL]).getTime());
							pstmtSource.setDate((b+1), sqld);
						} catch(Exception e) {
							e.printStackTrace();
						}
					}
				} else if (bindlist.get(b)[BIND_TYPE].equals("TIMESTAMP")) {
					if (bindlist.get(b)[BIND_VAL] == null || bindlist.get(b)[BIND_VAL].equals(""))
						pstmtSource.setNull((b+1), java.sql.Types.DATE);
					else {
						try {
							SimpleDateFormat sdf=new SimpleDateFormat(BIND_DATE_TIME_DEFAULT_TYPE);
							Timestamp ts=new Timestamp(sdf.parse(bindlist.get(b)[BIND_VAL]).getTime());
							
							pstmtSource.setTimestamp((b+1), ts);
						} catch(Exception e) {
							e.printStackTrace();
						}
					}
				} else if (bindlist.get(b)[BIND_TYPE].equals("DOUBLE")) {
					if (bindlist.get(b)[BIND_VAL] == null || bindlist.get(b)[BIND_VAL].equals(""))
						pstmtSource.setNull((b+1), java.sql.Types.DOUBLE);
					else
						pstmtSource.setDouble((b+1), Double.parseDouble(bindlist.get(b)[BIND_VAL]));
				} else if (bindlist.get(b)[BIND_TYPE].equals("FLOAT")) {
					if (bindlist.get(b)[BIND_VAL] == null || bindlist.get(b)[BIND_VAL].equals(""))
						pstmtSource.setNull((b+1), java.sql.Types.FLOAT);
					else
						pstmtSource.setFloat((b+1), Float.parseFloat(bindlist.get(b)[BIND_VAL]));
				} 
				else if (bindlist.get(b)[BIND_TYPE].equals("BINARY")) {
					
					if (bindlist.get(b)[BIND_VAL] == null || bindlist.get(b)[BIND_VAL].equals(""))
						pstmtSource.setNull((b+1), java.sql.Types.BINARY);
					else
						pstmtSource.setNull((b+1), java.sql.Types.BINARY);
				} 
				else if (bindlist.get(b)[BIND_TYPE].equals("BOOLEAN")) {
					if (bindlist.get(b)[BIND_VAL] == null || bindlist.get(b)[BIND_VAL].equals(""))
						pstmtSource.setNull((b+1), java.sql.Types.BOOLEAN);
					else {
						String boolVal=bindlist.get(b)[BIND_VAL];
						if (boolVal.equals("1")) 
							boolVal="true";
						else if (boolVal.equals("0")) 
							boolVal="false";
						pstmtSource.setBoolean((b+1), Boolean.parseBoolean(boolVal));
					}
						
						
				}
				else {
					pstmtSource.setString((b+1), bindlist.get(b)[BIND_VAL]);
				}
			} //for (int b = 0; b < bindlist.size(); b++)
			
			rsetSource = pstmtSource.executeQuery();
			
			
			is_retrieval_success=true;
		} catch(Exception e) {
			mylog("Exception@Binding@ MSG      : "+e.getMessage());
			mylog("Exception@Binding@ SQL      : "+ct.retrieve_sql);
			mylog("Exception@Binding@ BINDLIST : ");
			
			if (is_on_error_stop) {
				error_flag=true;
				global_error_count++;
			}
			
			if (bindlist.size()==0) {
				mylog("No binding");
			}
			else 
				for (int b=0;b<bindlist.size();b++) 
					mylog("	Binding... "+(b+1)+") "+bindlist.get(b)[BIND_TYPE]+"=["+bindlist.get(b)[BIND_VAL]+"]");
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			
			e.printStackTrace();
		}
		
		if (!is_retrieval_success) return;
		
		
			
		ArrayList<String> recOriginalArr=new ArrayList<String>();
		ArrayList<String> recChangedArr=new ArrayList<String>();
		ArrayList<Boolean> recChangeStatusArr=new ArrayList<Boolean>();
		
		ArrayList<String> fieldTypeNameArr=new ArrayList<String>();
		ArrayList<Integer> fieldTypeArr=new ArrayList<Integer>();
		
		boolean is_record_changed=false;
		boolean is_col_changed=false;
		
		StringBuilder field_string_val_original=new StringBuilder();
		StringBuilder field_string_val_changed=new StringBuilder();
		
		try {
			

			rsmdSource = rsetSource.getMetaData();
			
			
			for (int f=0;f<rsmdSource.getColumnCount();f++) {
				
				String 	ColumnTypeName=rsmdSource.getColumnTypeName(f+1);
				int 	ColumnType=rsmdSource.getColumnType(f+1);
				
				fieldTypeNameArr.add(ColumnTypeName);
				fieldTypeArr.add(ColumnType);
				
			}
			
			
			boolean is_work_plan_cancelled=false;
			boolean is_master_cancelled=false;
			
			int parent_changed_field_id=0;
			int target_field_id=0;
			
			boolean isRecordExistsOnTarget=false;
			boolean tobeUpdated=false;
			
			StringBuilder needCopyCheck=new StringBuilder();
			


			
			while(rsetSource.next()) {
				
					
				if(ct.level==ROOT_LEVEL && !isOriginatedFromNeed) sum_retrieve_count++;
				
				tobeUpdated=false;
				
				thread_start_heartbeat=System.currentTimeMillis();
				
				db.heartbeat(db.TABLE_TDM_MASTER, 0, db.master_id);
				
				testDBConnections();
				
				checkCancellations(db);
				
				if (error_flag) break;
				
				isRecordExistsOnTarget=checkExistanceOntarget(ct, connTarget, rsetSource, fieldTypeArr);
				
				if (isRecordExistsOnTarget) {
					mylog(ct.target_owner+"."+ct.target_table_name+"'s record is already exists on target db.");
					
					if (ct.check_existence_action.equals(COPY_EXIST_ACTION_SKIP)) {
						
						if (ct.level==ROOT_LEVEL && sum_retrieve_count>=MAX_COPY_REC_COUNT)  break;
						
						
						mylog("Skipping...") ;
						continue;
						
					} else if (ct.check_existence_action.equals(COPY_EXIST_ACTION_UPDATE)) {
						mylog("Updating...") ;
						
						tobeUpdated=true;
					}
						

				}


				
				if (tobeUpdated)
					pstmtTarget = connTarget.prepareStatement(ct.update_sql);
				else
					pstmtTarget = connTarget.prepareStatement(ct.insert_sql);
				
				
				recOriginalArr.clear();
				recChangedArr.clear();
				recChangeStatusArr.clear();
					
				is_record_changed=false;
				is_col_changed=false;

				target_field_id=-1;
				
				needCopyCheck.setLength(0);
				needCopyCheck.append("COPIED_"+ct.owner+"."+ct.table_name+"_KEY");
				
				
				for (int f=0;f<ct.fields.size();f++) {						

					if (ct.hasNeeds && ct.needingFieldIds.indexOf(f)>-1) {
						
						copyNeededApplications(connSource, connTarget, db, ct, f, rsetSource, fieldTypeArr);
						
						if (error_flag) break;
					}
					
					
					if (error_flag) break;
					
					is_col_changed=false;
					boolean to_be_changed=ct.fieldToBeMaskedArr.get(f);
					
					field_string_val_original.setLength(0);
					field_string_val_original.append(setTargetBinding(rsetSource, pstmtTarget, f, -1 ,  ct.fields.get(f)[3], fieldTypeArr.get(f), false, null));
					recOriginalArr.add(field_string_val_original.toString());
					
					recChangeStatusArr.add(false);
					recChangedArr.add(field_string_val_original.toString());
					
					
					
					//if it is PK
					if (ct.fields.get(f)[2].equals("YES")) 
						needCopyCheck.append("_"+recOriginalArr.toString());
					
						
						
					if (to_be_changed) {
						field_string_val_changed.setLength(0);
						
						//mask here
						field_string_val_changed.append(mask(db, ct, connTarget, field_string_val_original, f, recChangedArr,null));
						
						if (!field_string_val_changed.toString().equals(field_string_val_original.toString())) {
							is_col_changed=true;
							is_record_changed=true;
							
							recChangeStatusArr.set(recChangeStatusArr.size()-1, true);
							recChangedArr.set(recChangedArr.size()-1, field_string_val_changed.toString());
																							
							if (ct.hasCopyReferencingField) {
								String key=""+ct.tab_id+"."+ct.fields.get(f)[0];
								
								
								//if (copyRefFieldsArr.indexOf(key)>-1 && !is_single)
								if (copyRefFieldsArr.indexOf(key)>-1)
									hmMaskedVal.put(
											"T_"+ct.tab_id+"_F_"+ct.fields.get(f)[0]+"_V_"+field_string_val_original.toString(),
											field_string_val_changed.toString()
											);
							} //if (ct.hasCopyReferencingField)
								
								
								

						}
							
						
					} 
					//---------------------------------
					

					//set if parent column value changed
					if (is_parent_changed && ct.relThisTableFieldIDs.indexOf(f)>-1  ) {
						
						parent_changed_field_id=ct.relParentTablePKFieldIDs.get(ct.relThisTableFieldIDs.indexOf(f));
						
						if (parentChangeStatus.get(parent_changed_field_id)) {
							is_record_changed=true;
							is_col_changed=true;
							
							field_string_val_changed.setLength(0);
							field_string_val_changed.append(parentChangedRecord.get(parent_changed_field_id));
							
							
						}

					}
					
					if (tobeUpdated && ct.thisTablePKEYfieldORDERS.indexOf(f)>-1) 
						continue;
					else {
						target_field_id++;
						//mylog("ssping Bind  "+ct.fields.get(f)[0]+" "+ct.fields.get(f)[3]+" ["+fieldTypeArr.get(f)+"] with "+field_string_val_changed.toString());
						setTargetBinding(rsetSource, pstmtTarget, f, target_field_id, ct.fields.get(f)[3], fieldTypeArr.get(f), is_col_changed, field_string_val_changed);
						
					}
						
						
				}  // for fields.size()
				
				
				
				//check if it is copied before by need
				if (ct.hasPrimaryKey 
						&& (ct.hasNeeds || ct.isRecursive) 
						&& hm.containsKey(needCopyCheck.toString())) continue;
				
				if (error_flag) break;
				
				if (tobeUpdated) {
					for (int p=0;p<ct.thisTablePKEYfieldORDERS.size();p++) {
						int pk_field_id=ct.thisTablePKEYfieldORDERS.get(p);
						target_field_id++;
						setTargetBinding(rsetSource, pstmtTarget, pk_field_id, target_field_id, ct.fields.get(pk_field_id)[3], fieldTypeArr.get(pk_field_id), false, null);

					}
				} else {
					StringBuilder extra_val=new StringBuilder();
					StringBuilder random_val=new StringBuilder();
					ResultSet rsnull=null;
					for (int f=0;f<ct.extraFields.size();f++) {
						
						String extraFieldMaskProf=ct.extraFields.get(f)[3];
						
						int mask_prof_arr_id=(Integer) hm.get("ID_OF_PROFILE_"+extraFieldMaskProf);
						
						String short_code=maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_SHORT_CODE];

						
						extra_val.setLength(0);
						random_val.setLength(0);
						
						random_val.append(""+genLib.randomString(3));
						
						
						
						if (extraFieldMaskProf.equals("SET_NULL")) extra_val.append("${null}");
						else 
							extra_val.append(
									mask(db, ct, connTarget, random_val , f, recChangedArr, short_code)
									);
						
							
						int source_field_id=0;
						target_field_id=ct.fields.size()+f;
						int extra_field_type_id=ct.extraFieldTypes.get(f);
						
						setTargetBinding(
								rsnull, 
								pstmtTarget, 
								-1, 
								target_field_id, 
								ct.extraFields.get(f)[2], //bind type
								extra_field_type_id, 
								false, 
								extra_val);

					}
				}
				
				
				
				//---------------------------------------------------------
				boolean copy_success=false;
									
				try {
				
					
					int copied_record_count=pstmtTarget.executeUpdate();


					
					if (copied_record_count>0)
						copy_success=true;
					
					
					if (!is_single  & (ct.hasNeeds || ct.isRecursive)) 
						hm.put(needCopyCheck.toString(),true);
					
						
					
					
					
				} catch(Exception e) {
					
					
					if (is_on_error_stop) {
						error_flag=true;
						global_error_count++;
					}
					
					
					mylog("Exception@Insert : MSG : "+e.getMessage());
					mylog("Exception@Insert : SQL : "+ct.insert_sql);
					mylog("Exception@Insert : VAL : ");
					
					
					for (int b=0;b<recChangedArr.size();b++) 
						if (ct.fields.get(b)[0].length()>1000)
							mylog("Exception@Insert Val["+(b+1)+","+ct.fields.get(b)[0]+" (ft :"+ct.fields.get(b)[1]+")(bt :"+ct.fields.get(b)[3]+")] :  {"+recChangedArr.get(b).substring(0, 1000)+"...} (len:"+recChangedArr.get(b).length()+")");
						else 
							mylog("Exception@Insert Val["+(b+1)+","+ct.fields.get(b)[0]+" (ft :"+ct.fields.get(b)[1]+")(bt :"+ct.fields.get(b)[3]+")] :  {"+recChangedArr.get(b)+"} (len:"+recChangedArr.get(b).length()+")");
					
					
					mylog(genLib.getStackTraceAsStringBuilder(e).toString());
					
					e.printStackTrace();
				} finally {
					try{pstmtTarget.close();} catch(Exception e) {}
				}
				
				//---------------------------------------------------------
				
				
				if (tobeUpdated) {
					ArrayList<String[]> rolbackrec=cLib.getDbArray(connTarget, ct.retrieve_rollback_sql, 1, bindlist);
					
					
					
					if (rolbackrec!=null && rolbackrec.size()==1) {

						if (ct.hasCopyReferencingField) {
							for (int f=0;f<ct.fields.size();f++) {
								String key=""+ct.tab_id+"."+ct.fields.get(f)[0];
								if (copyRefFieldsArr.indexOf(key)==-1) continue;
								hmMaskedVal.put(
										"T_"+ct.tab_id+"_F_"+ct.fields.get(f)[0]+"_V_"+recOriginalArr.get(f),
										rolbackrec.get(0)[f]
										);
								
							}
						}
						
						//add rollback info for UPDATE
						String[]  rollbackInfoArr=new String[6+ct.fields.size()];
						rollbackInfoArr[0]=""+ct.target_catalog;
						rollbackInfoArr[1]=""+ct.target_owner;
						rollbackInfoArr[2]=""+ct.target_table_name;
						rollbackInfoArr[3]=ROLLBACK_ACTION_UPDATE;
						
						int rollback_sql_id=getRollbackSqlInfoId(ct,ROLLBACK_ACTION_UPDATE,fieldTypeArr);
						
						
						rollbackInfoArr[4]=""+rollback_sql_id;
						rollbackInfoArr[5]=ct.target_db_id;
						
						int ind=-1;
						for (int f=0;f<ct.fields.size();f++) {
							if (ct.thisTablePKEYfieldORDERS.indexOf(f)>-1) continue;
							ind++;
							rollbackInfoArr[6+ind]=rolbackrec.get(0)[f];
						}
						
						for (int p=0;p<ct.thisTablePKEYfieldORDERS.size();p++) {
							ind++;
							int pk_field_id=ct.thisTablePKEYfieldORDERS.get(p);
							
							rollbackInfoArr[6+ind]=rolbackrec.get(0)[pk_field_id];
							
						}
						
						saveRollbackInfo(db, rollbackInfoArr, false);
					}
				}
				
				
				if (copy_success || !is_on_error_stop) {
					
					if(copy_success && (ct.level==ROOT_LEVEL && !isOriginatedFromNeed)) sum_copy_count++;
					
					if (!tobeUpdated) {
						
						
						if (ct.hasCopyReferencingField) {
							for (int f=0;f<ct.fields.size();f++) {
								String key=""+ct.tab_id+"."+ct.fields.get(f)[0];
								if (copyRefFieldsArr.indexOf(key)==-1) continue;
								hmMaskedVal.put(
										"T_"+ct.tab_id+"_F_"+ct.fields.get(f)[0]+"_V_"+recOriginalArr.get(f),
										recChangedArr.get(f)
										);
								
							}
						}
						
						//add rollback info for INSERT
						String[] rollbackInfoArr=new String[6+ct.thisTablePKEYfieldORDERS.size()];
						rollbackInfoArr[0]=""+ct.target_catalog;
						rollbackInfoArr[1]=""+ct.target_owner;
						rollbackInfoArr[2]=""+ct.target_table_name;
						rollbackInfoArr[3]=ROLLBACK_ACTION_DELETE;
						int rollback_sql_id=getRollbackSqlInfoId(ct,ROLLBACK_ACTION_DELETE, fieldTypeArr);
						
						rollbackInfoArr[4]=""+rollback_sql_id;
						rollbackInfoArr[5]=ct.target_db_id;
						
						int ind=-1;
						
						for (int p=0;p<ct.thisTablePKEYfieldORDERS.size();p++) {
							ind++;
							int pk_field_id=ct.thisTablePKEYfieldORDERS.get(p);
							
							rollbackInfoArr[6+ind]=recChangedArr.get(pk_field_id);
							
						}
						saveRollbackInfo(db, rollbackInfoArr, false);
						
					} //if (!tobeUpdated) {
					
					
				}
				else {
					if (is_on_error_stop) {
						sum_fail_count++;
						error_flag=true;
						global_error_count++;
					}
					
					
					
					break;	
				}
				
				
				if (ct.hasNeeds || ct.isRecursive || isOriginatedFromNeed) 
					hmCpOk.put("CPOK_"+ct.source_owner+"."+ct.source_table_name+"_WITH_"+userFilterAsStr.toString(),true);
				
				
				if (ct.isRecursive) {
					
					copyTableDo(
							connSource, 
							connTarget, 
							db, 
							tableArr, 
							copyRefFieldsArr, 
							ct, 
							new ArrayList<String>(recOriginalArr), //parentRecord, 
							is_record_changed, 
							new ArrayList<String>(recChangedArr), //parentChangedRecord, 
							new ArrayList<Boolean>(recChangeStatusArr), //parentChangeStatus, 
							true, // RecursiveMode, 
							false, // isOriginatedFromNeed
							parallel_no,
							filter_value
							);
					
				} //if (ct.isRecursive) 
					
					
					
				if (ct.hasChild) {
					for (int c=0;c<ct.childTableObjIds.size();c++) {
						
						
						int child_tab_id=ct.childTableObjIds.get(c);
						

						copyTableDo(
								connSource, 
								connTarget, 
								db, 
								tableArr, 
								copyRefFieldsArr, 
								tableArr.get(child_tab_id), //ct, 
								new ArrayList<String>(recOriginalArr), //parentRecord, 
								is_record_changed, 
								new ArrayList<String>(recChangedArr), //parentChangedRecord, 
								new ArrayList<Boolean>(recChangeStatusArr), //parentChangeStatus, 
								false, // RecursiveMode, 
								false, // isOriginatedFromNeed
								parallel_no,
								filter_value
								);
						
						
						
					}
				} //if (ct.hasChild)
					
					
					
				

				if (!isRecordExistsOnTarget) {
					rec_copy_count++;
					tableArr.get(ct.copy_table_obj_id).copy_count++;
				}
				
				
				
				if (ct.level==ROOT_LEVEL && !RecursiveMode && sum_copy_count>=MAX_COPY_REC_COUNT) 
					break;
				
				//if (ct.level==ROOT_LEVEL && !RecursiveMode && tableArr.get(ct.copy_table_obj_id).copy_count>=MAX_COPY_REC_COUNT) 
				//	break;
				
				if ((rec_copy_count>0 && rec_copy_count % 100==0) || isOriginatedFromNeed) {
									
					//try {connTarget.commit();} catch(Exception e) {e.printStackTrace();}
					
					if (parallel_no==0)	
						getStatistics(db, false, isOriginatedFromNeed);
					
				}
				
				
				
				
				
				
				if (rec_copy_count>0 && rec_copy_count % 1000==0) {
					last_heartbeat_ts=System.currentTimeMillis();
					mylog(ct.source_owner+"."+ct.source_table_name+"=>"+ct.target_owner+"."+ct.target_table_name+" P_"+parallel_no+" : \t"  + 
										rec_copy_count + " copied so far... Heap :"+db.heapUsedRate()+"%"+
										" hm#:"+hm.size()+
										" hmCpOk#: "+hmCpOk.size()+
										" hmNeed#: "+hmNeed.size()+
										" hmMaskedVal#: "+hmMaskedVal.size()
							);
					
					//-------------------------------------------------------------
					//CHECK CANCEL STATUSES
					//-------------------------------------------------------------
					is_work_plan_cancelled=db.isWorkPlanCancelled(work_plan_id);
					if (is_work_plan_cancelled) {
						if (!ct.hasParent) mylog("Work plan is cancelled.");
						break;
					}
					is_master_cancelled=db.getMasterCancelFlag(db.master_id);
					if (is_master_cancelled) {
						if (!ct.hasParent)	mylog("Master is cancelled.");
						break;
					}
					//-------------------------------------------------------------
					
					
				}
				
				if (!is_autocommit && rec_copy_count % 10000==0) 
					try {connTarget.commit();} catch(Exception e) {e.printStackTrace();}

			} //while
			
			
		} catch(Exception e ) {
			
			
			
			if (is_on_error_stop) {
				error_flag=true;
				global_error_count++;
			}
			
			e.printStackTrace();
			mylog("Exception@Binding@ TAB      : "+ct.target_owner+"."+ct.target_table_name);
			mylog("Exception@Binding@ ERR      : "+genLib.getStackTraceAsStringBuilder(e).toString());
			
		} finally {
			try {rsetSource.close(); } catch(Exception e) {}
			try {pstmtSource.close(); } catch(Exception e) {}
			
			if (!is_autocommit) 
				try {connTarget.commit();} catch(Exception e) {e.printStackTrace();}
		}
		
		
		
		
		
		mylog("Copying Done : "  + ct.source_owner+"."+ct.source_table_name  + " with "+rec_copy_count + " records. GlbErrorCnt : "+global_error_count);
		
	}
	


	//--------------------------------------------------------------------------
	void doCopy(
			Connection connSource,
			Connection connTarget,
			ConfDBOper db, 
			ArrayList<copyTableObj> tableArr, 
			ArrayList<String> copyRefFieldsArr,
			boolean isOriginatedFromNeed,
			String filter_value
			) {
		ArrayList<Integer> rootTableObjIds=getRootTableIds(tableArr);
		
		int copied_root_table_count=0;
		
		while(true) {
			
			if (error_flag) break;
			
			if (copied_root_table_count==rootTableObjIds.size()) break;

			int next_root_table_obj_id=rootTableObjIds.get(copied_root_table_count);
						
			copyTableObj ct=tableArr.get(next_root_table_obj_id);
			
			copyTable(connSource, connTarget, db, tableArr, copyRefFieldsArr, ct, null,false,null,null,false,isOriginatedFromNeed, filter_value);
			
			copied_root_table_count++;
			
			
			
		}
		
		

		
		
		long all_copy_rec_count=0;
		
		
		for (int i=0;i<tableArr.size();i++) {
			all_copy_rec_count+=tableArr.get(i).copy_count;
			mylog("\t"+tableArr.get(i).copy_count+" records copied from ["+tableArr.get(i).source_catalog+"]."+tableArr.get(i).source_owner+"."+tableArr.get(i).source_table_name+" to ["+tableArr.get(i).target_catalog+"]." + tableArr.get(i).target_owner+"."+tableArr.get(i).target_table_name);
		}
		
		
		
	}
	
	


	
	long last_copy_email_sent_ts=0;
	static final int COPY_EMAIL_SEND_INTERVAL=30000;
	
	//------------------------------------------------------------------------------------
	void sendMail(ConfDBOper db, String email_stage, boolean isOriginatedFromNeed) {
		
		if (isOriginatedFromNeed) return;
			
		/*
		
		if (System.currentTimeMillis()<last_copy_email_sent_ts && email_stage.equals("COPY_STATUS")) 
			return;
		
		
		String sql="select created_by, work_plan_name from tdm_work_plan where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		
		bindlist.add(new String[]{"INTEGER",""+work_plan_id});
		
		ArrayList<String[]> arr=cLib.getDbArray(confDb, sql, 1, bindlist);
		
		if (arr==null || arr.size()==0) {
			mylog("Work plan not found : "+work_plan_id);
			return;
		}
		
		String created_by=opAutoLib.nvl(arr.get(0)[0],"0");
		String work_plan_name=arr.get(0)[1];
		
		sql="select email from tdm_user where id=?";
		
		bindlist.clear();
		
		bindlist.add(new String[]{"INTEGER",""+created_by});
		
		arr=cLib.getDbArray(confDb, sql, 1, bindlist);
				
				
		if (arr==null || arr.size()==0 || arr.get(0)[0].length()<3) {
			mylog("No email address found for work plan "+work_plan_id);
			return;
		}
		
		String email_address=arr.get(0)[0];
		
		String from="TDM@tdm.com";
		String to=email_address;
		
		
		String subject="";
		StringBuilder body=new StringBuilder();
		
		if (email_stage.equals("COPY_STARTED")) {
			subject="Copy Started ("+work_plan_id+") ["+work_plan_name+"]";
			body.append(subject);
		} else {
			if (email_stage.equals("COPY_FINISHED"))
				subject="Copy Finished ("+work_plan_id+") ["+work_plan_name+"]";
			else 
				subject="Copy Status ("+work_plan_id+") ["+work_plan_name+"]";
			
			body.append("<h4>"+work_plan_name+"</h4>");
			
			sql="select w.status, a.name application, src.name source_db, tar.name target_db, "+
					" copy_rec_count, copy_repeat_count, "+
					" (select sum(export_count)  from tdm_work_package where work_plan_id=w.id) retrieve_count, "+
					" (select sum(done_count)  from tdm_work_package where work_plan_id=w.id) copy_count "+
					" from tdm_work_plan w, tdm_apps a, tdm_envs src, tdm_envs tar "+
					" where w.app_id=a.id and w.env_id=src.id and w.target_env_id=tar.id " + 
					" and w.id=? "
					;
			
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+work_plan_id});
			
			arr=cLib.getDbArray(confDb, sql, Integer.MAX_VALUE, bindlist);
			
			if (arr==null|| arr.size()==0) {
				body.append("Work Plan not found");
			}
			
			String status=arr.get(0)[0];
			String application=arr.get(0)[1];
			String source_db=arr.get(0)[2];
			String target_db=arr.get(0)[3];
			String copy_rec_count=arr.get(0)[4];
			String copy_repeat_count=arr.get(0)[5];
			String retrieve_count=arr.get(0)[6];
			String copy_count=arr.get(0)[7];
			
			body.append("<table border=1 cellspacing=2 cellpadding=0>");
			
			body.append("<tr>");
			body.append("<td align=right nowrap><b>Work Plan Id</b></td>");
			body.append("<td>"+work_plan_id+"</td>");
			body.append("</tr>");
			
			body.append("<tr>");
			body.append("<td align=right nowrap><b>Work Plan Name</b></td>");
			body.append("<td>"+work_plan_name+"</td>");
			body.append("</tr>");
			
			body.append("<tr>");
			body.append("<td align=right nowrap><b>Status</b></td>");
			body.append("<td>"+status+"</td>");
			body.append("</tr>");
			
			body.append("<tr>");
			body.append("<td align=right nowrap><b>Application</b></td>");
			body.append("<td>"+application+"</td>");
			body.append("</tr>");
			
			body.append("<tr>");
			body.append("<td align=right nowrap><b>Source DB</b></td>");
			body.append("<td>"+source_db+"</td>");
			body.append("</tr>");
			
			body.append("<tr>");
			body.append("<td align=right nowrap><b>Target DB</b></td>");
			body.append("<td>"+target_db+"</td>");
			body.append("</tr>");
			
			body.append("<tr>");
			body.append("<td align=right nowrap><b>Copy Count</b></td>");
			body.append("<td>"+copy_rec_count+"</td>");
			body.append("</tr>");
			
			body.append("<tr>");
			body.append("<td align=right nowrap><b>Repeat Count</b></td>");
			body.append("<td>"+copy_repeat_count+"</td>");
			body.append("</tr>");
			
			body.append("<tr>");
			body.append("<td align=right nowrap><b>Retrieved</b></td>");
			body.append("<td>"+retrieve_count+"</td>");
			body.append("</tr>");
			
			body.append("<tr>");
			body.append("<td align=right nowrap><b>Copied</b></td>");
			body.append("<td>"+copy_count+"</td>");
			body.append("</tr>");
			
			body.append("</table>");
		}
		
		
		
		db.sendMail(from, to, subject, body);
		
		last_copy_email_sent_ts=System.currentTimeMillis()+COPY_EMAIL_SEND_INTERVAL;
		
		*/
	}
	//------------------------------------------------------------------------------------
	
	long MAX_COPY_REC_COUNT=Long.MAX_VALUE;
	
	
	
	
	
	
	
	
	
	//--------------------------------------------------------------------------
	void copyApplication(
			Connection connSource,
			Connection connTarget,
			ConfDBOper db, 
			int app_id, 
			String filter_id,
			String filter_value, 
			long max_row, 
			long repeat_count,
			boolean isOriginatedFromNeed
			) {
		
		

		if (error_flag) {
			System.out.println("Error occured ..");
			return;
		}
		
		boolean is_copying=hmwait.containsKey("NEED_COPYING_"+app_id+"_"+filter_id+"_"+filter_value);
		
		if (is_copying) 
			while(true) {
				try{Thread.sleep(10);} catch(Exception e) {}
				if (!hmwait.containsKey("NEED_COPYING_"+app_id+"_"+filter_id+"_"+filter_value)) 
					break;
			}
		
		if (hmNeed.containsKey("NEED_COPIED_"+app_id+"_"+filter_id+"_"+filter_value)) {
			System.out.println("Skipping... , Already Copied APP_"+app_id+"_FILTER_"+filter_id+"_VAL_"+filter_value);
			return;
		}
		
		if (isOriginatedFromNeed)
			hmwait.put("NEED_COPYING_"+app_id+"_"+filter_id+"_"+filter_value,true);
		
		boolean is_app_loading=hm.containsKey("APP_CONF_LOADING_"+app_id+"_FILTER_"+filter_id);
		
		if (is_app_loading)
			while(true) {
				try {Thread.sleep(10); } catch(Exception e) {}
				is_app_loading=hm.containsKey("APP_CONF_LOADING_"+app_id+"_FILTER_"+filter_id);
				if (!is_app_loading) break;
				//System.out.println("is_app_loading...");
			}
		
		
		boolean is_app_loaded_before=hm.containsKey("IS_APP_LOADED_BEFORE_"+app_id+"_FILTER_"+filter_id);
		
		
		ArrayList<copyTableObj> copyTableArr=new ArrayList<copyTableObj>();
		ArrayList<String> copyRefFieldsArr=new ArrayList<String>();
		
		long saved_MAX_COPY_REC_COUNT=MAX_COPY_REC_COUNT;
		
		if (max_row>0) 
			MAX_COPY_REC_COUNT=max_row;
		else 
			MAX_COPY_REC_COUNT=Long.MAX_VALUE;
		
		if (is_app_loaded_before) {
			copyTableArr=(ArrayList<copyTableObj>) hm.get("TABS_OF_APP_"+app_id+"_FILTER_"+filter_id);
			copyRefFieldsArr=(ArrayList<String>) hm.get("COPY_REF_FIELDS_ARR_FOR_"+app_id);
		}
		else
		{ 
			
			hm.put("APP_CONF_LOADING_"+app_id+"_FILTER_"+filter_id,true);
			
			long start_ts=System.currentTimeMillis();
			
			
			
			loadTableConfig(db, copyTableArr, app_id, filter_id, filter_value);
			compileApp(db, copyTableArr,copyRefFieldsArr, app_id);
			loadMaskingConfiguration(db);
			createMissingTables(db, copyTableArr, app_id);
			
			hm.put("TABS_OF_APP_"+app_id+"_FILTER_"+filter_id, copyTableArr);
			hm.put("IS_APP_LOADED_BEFORE_"+app_id+"_FILTER_"+filter_id,true);
			
			appList.add("TABS_OF_APP_"+app_id+"_FILTER_"+filter_id);
			
			
			hm.remove("APP_CONF_LOADING_"+app_id+"_FILTER_"+filter_id);
					
			
		}


		sendMail(db, "COPY_STARTED",isOriginatedFromNeed);
		
		runAppScripts(db, app_id,"PREP");
		
		copyPrerequisiteApplications(db, app_id);
		
		for (int i=0;i<repeat_count;i++)
			doCopy(connSource, connTarget, db, copyTableArr,copyRefFieldsArr,isOriginatedFromNeed, filter_value);
		
		getStatistics(db, true, isOriginatedFromNeed);
		
		runAppScripts(db, app_id,"POST");
		
		sendMail(db,"COPY_FINISHED",isOriginatedFromNeed);
		
		MAX_COPY_REC_COUNT=saved_MAX_COPY_REC_COUNT;
		
		hmNeed.put("NEED_COPIED_"+app_id+"_"+filter_id+"_"+filter_value, true);
		
		if (isOriginatedFromNeed)
			hmwait.remove("NEED_COPYING_"+app_id+"_"+filter_id+"_"+filter_value);
		
		
		
	}
	
	
	//------------------------------------------------------------------------
	void copyPrerequisiteApplications(ConfDBOper db, int app_id) {
		String sql="select rel_app_id, a.name application_name, filter_id, filter_value "+
					" from tdm_apps_rel ar, tdm_apps a, tdm_copy_filter cpf "+
					" where ar.rel_app_id=a.id and ar.app_id=? and ar.filter_id=cpf.id "+
					" order by ar.rel_order";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+app_id});
		
		
		ArrayList<String[]> arr=cLib.getDbArray(db.connConf, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<arr.size();i++) {
			int rel_app_id=Integer.parseInt(arr.get(i)[0]);
			String application_name=arr.get(i)[1];
			String filter_id=arr.get(i)[2];
			String filter_value=arr.get(i)[3];
			
			if (error_flag) break;
			
			mylog("------------------------------------------------------------");
			mylog("Running prerequisite application : "+application_name);
			mylog("------------------------------------------------------------");
			
			
			hmCpOk.clear();
			//hmNeed.clear();
			//hmMaskedVal.clear();
			hmwait.clear();
			
			copyApplication(null, null, db, rel_app_id, filter_id, filter_value, 0, 1, false);

		}
	}
	
	//-------------------------------------------------------------------------
	void runAppScripts(ConfDBOper db, int app_id,String stage) {
		String sql="select "+
					"	script_description, "+
					"	family_id,  "+
					"	target, "+
					"	script_body "+
					"	from tdm_copy_script  "+
					"	where app_id=? and stage=?  "+
					"	order by script_order ";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+app_id});
		bindlist.add(new String[]{"STRING",stage});
		
		ArrayList<String[]> scriptArr=cLib.getDbArray(db.connConf, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<scriptArr.size();i++) {
			String script_description=scriptArr.get(i)[0];
			String family_id=scriptArr.get(i)[1];
			String target=scriptArr.get(i)[2];
			String script_body=scriptArr.get(i)[3];
			
			if (script_body.trim().length()==0) continue;
			
			mylog("Executing "+stage + " script :");

			
			boolean is_success=runScript(db,family_id,target,script_body);
			
			//mylog(script_log);
			
			
		}
		
		
		
	}
	



	//--------------------------------------------------------------------------
	boolean runScript(ConfDBOper db,String family_id,String target,String script_body) {
		
		int script_target_id=0;
		
		if (target.equals("SOURCE")) script_target_id=source_id;
		if (target.equals("TARGET")) script_target_id=target_id;
		
		if (!hm.containsKey("DB_ID_"+script_target_id+"_"+family_id)) {
			mylog("Skipping script, since source or target db is not related.");
			return false;
		}
		
		String db_id=(String) hm.get("DB_ID_"+script_target_id+"_"+family_id);
		
		String[] arr=script_body.split("\n|\r");
		
		StringBuilder script=new StringBuilder();
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		int script_db_instance_id=getDBArrInstance(db, "ANY",db_id);
		
		for (int i=0;i<arr.length;i++) {
			
			if (!arr[i].trim().equals("/")) {
				script.append(arr[i]);
				script.append("\n");
			}
					
			
			
			
			if (arr[i].trim().equals("/") || i==arr.length-1) {
				
				if (script.toString().trim().length()>0) {
					mylog("Running...");
					mylog("--------------------------------------");
					mylog(script.toString());
					mylog("--------------------------------------");
					boolean is_ok=cLib.execSingleUpdateSQL(connArr.get(script_db_instance_id), script.toString(), bindlist);
					mylog("Script result  : "+is_ok);
				}
				
				script.setLength(0);
				
				continue;
			}
			
			
		}
		
		releaseDbInstance(script_db_instance_id);
		
		return true;
	}
	
	
	//--------------------------------------------------------------------------
	void createMissingTables(ConfDBOper db, ArrayList<copyTableObj> tableArr, int app_id) {
	
		if (hm.containsKey("MISSING_TABLES_CREATED_"+app_id)) return;
		
		hm.put("MISSING_TABLES_CREATED_"+app_id,true);
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		mylog("******  checking target tables and creating missing ones ****");
		
		for (int i=0;i<tableArr.size();i++) {
			db.heartbeat(db.TABLE_TDM_MASTER, 0, db.master_id);
			
			String db_type=tableArr.get(i).target_db_type;
			String original_schema_name=tableArr.get(i).owner;
			String original_table_name=tableArr.get(i).table_name;
			
			String source_schema_name=tableArr.get(i).source_owner;
			String source_table_name=tableArr.get(i).source_table_name;

			String target_schema_name=tableArr.get(i).target_owner;
			String target_table_name=tableArr.get(i).target_table_name;
			
			String source_db_id=tableArr.get(i).source_db_id;
			String target_db_id=tableArr.get(i).target_db_id;
			
			int source_db_instance_id=getDBArrInstance(db, "SOURCE",source_db_id);
			int target_db_instance_id=getDBArrInstance(db, "TARGET",target_db_id);
			
			
			createTable(
					connArr.get(source_db_instance_id), 
					connArr.get(target_db_instance_id),
					db_type, 
					source_schema_name, 
					source_table_name, 
					target_schema_name, 
					target_table_name);
			
			releaseDbInstance(source_db_instance_id);
			releaseDbInstance(target_db_instance_id);
			
		}
		
		
		
	}
	
	//************************************************
	void createTable(Connection sourceConn, Connection targetConn, String db_type, String source_schema_name, String source_table_name, String target_schema_name, String target_table_name) {

		/*
		if (db_type.equals(opAutoLib.DB_TYPE_ORACLE))
		{
			mylog("Table ["+ target_schema_name+"."+target_table_name +"]  checking in target...");	
			
			long ts_get_ddl=System.currentTimeMillis();
			String target_object_ddl=getDDLFromOracle(targetConn, "TABLE", target_table_name, target_schema_name);
			long duration=System.currentTimeMillis()-ts_get_ddl;
			
			if (target_object_ddl.length()>5) {
				mylog("Table ["+ target_schema_name+"."+target_table_name +"]  already exists in target. "+duration+ " msecs");
				return;
			}
			
			
			
			String create_ddl=getDDLFromOracle(sourceConn, "TABLE", source_table_name, source_schema_name);
			if (create_ddl.length()<5) {
				mylog("Table ["+ source_schema_name+"."+source_table_name +"] script cannot be generated "+duration+ " msecs");
				return;
			}
			
			
			create_ddl=create_ddl.substring(create_ddl.indexOf("(")-1);
			create_ddl="CREATE TABLE " + target_schema_name+"."+target_table_name + " \n "+ create_ddl;
			
			
			mylog("--------------------------------------------------");
			mylog(" CREATE TABLE ["+target_schema_name+"."+target_table_name+"] \n"+create_ddl);
		
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			boolean is_created=cLib.execSingleUpdateSQL(targetConn, create_ddl, bindlist);
			mylog("--------------------------------------------------");
			if (is_created) {
				mylog("Table ["+target_schema_name+"."+target_table_name+ "] Successfully Created.");
				mylog("--------------------------------------------------");
			}
			
		}
		
		*/
		
	}
	
	//***********************************************
	String getDDLFromOracle(Connection conn, String object_type, String object_name, String object_owner) {
		String ret1="";
		String sql="select dbms_metadata.get_ddl(?,?,?) from dual";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		if (object_type.toUpperCase().equals("TABLE")) {
			String ddl="begin";
			ddl=ddl  + "\n"+
					"DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false); \n"+
					"DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'TABLESPACE',false); \n"+
					"DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false); \n"+
					"DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'REF_CONSTRAINTS',false); \n"+
					"DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PARTITIONING',false); \n"+
					"DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS',false); \n";
			ddl=ddl + "commit; \n end;";
			bindlist.clear();
			cLib.execSingleUpdateSQL(conn, ddl, bindlist);
		}
		
		bindlist.clear();
		bindlist.add(new String[]{"STRING",object_type});
		bindlist.add(new String[]{"STRING",object_name});
		bindlist.add(new String[]{"STRING",object_owner});
		
		
		
		ArrayList<String[]> arr=cLib.getDbArray(conn, sql, 1, bindlist);
		if (arr==null || arr.size()==0)
			 return "";
		
		if (arr.size()==1)
			ret1=arr.get(0)[0];
		
		
		return ret1;
	
	}
	
	//--------------------------------------------------------------------------
	int getCopyTableObjIdByTabId(ArrayList<copyTableObj> tableArr, int tab_id) {
		for (int i=0;i<tableArr.size();i++) {
			if (tableArr.get(i).tab_id==tab_id) return i;
		}
		return -1;
	}
	
	
	
	//--------------------------------------------------------------------------
	void compileApp(
			ConfDBOper db,
			ArrayList<copyTableObj> tableArr,
			ArrayList<String> copyRefFieldsArr,
			int app_id
			) {
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		ArrayList<String[]> arr=new ArrayList<String[]>();
		
		String sql="";
		
		mylog("Compiling App : "+app_id+"...");
		
		ArrayList<String> tempRefFieldsArr=new ArrayList<String>();
		
		if (hm.containsKey("COPY_REF_FIELDS_ARR_FOR_"+app_id)) 
			tempRefFieldsArr.addAll( (ArrayList<String>) hm.get("COPY_REF_FIELDS_ARR_FOR_"+app_id) );
		else {
			sql="select distinct f.copy_ref_tab_id, f.copy_ref_field_name " + 
					"	from tdm_fields f, tdm_tabs t  " + 
					//"	where f.tab_id=t.id and t.app_id=? " + 
					"	where f.tab_id=t.id " + 
					"	and copy_ref_field_name is not null ";
				bindlist.clear();
				//bindlist.add(new String[]{"INTEGER",""+app_id});
				arr=cLib.getDbArray(db.connConf, sql, Integer.MAX_VALUE, bindlist);
				
				
				for (int i=0;i<arr.size();i++) {
					String copy_ref_tab_id=arr.get(i)[0];
					String copy_ref_field_name=arr.get(i)[1];
					tempRefFieldsArr.add(copy_ref_tab_id+"."+copy_ref_field_name);
					
				}
				
				hm.put("COPY_REF_FIELDS_ARR_FOR_"+app_id,tempRefFieldsArr);
		}
		
		copyRefFieldsArr.addAll(tempRefFieldsArr);
		
		
		String rel_sql="select  rel_type, pk_fields, rel_on_fields, rel_filter "+
				" from tdm_tabs_rel "+
				" where tab_id=? and rel_tab_id=? "+
				" order by rel_order  ";
		
		
		String tab_filter_sql="select " + 
								" tab_filter, hint_after_select, hint_before_table, hint_after_table, "+
								" check_existence_action, check_existence_sql, check_existence_on_fields, "+
								" recursive_fields "+
								" from tdm_tabs where id=?";
		
		
		
		
		for (int i=0;i<tableArr.size();i++) {
			copyTableObj ct=tableArr.get(i);
			int tab_id=ct.tab_id;
			
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+tab_id});
			arr=cLib.getDbArray(db.connConf, tab_filter_sql, 1, bindlist);
			
			if (arr!=null) {
				String tab_filter=arr.get(0)[0].trim();
				
				String hint_after_select=arr.get(0)[1].trim();
				String hint_before_table=arr.get(0)[2].trim();
				String hint_after_table=arr.get(0)[3].trim();
				
				String check_existence_action=arr.get(0)[4].trim();
				String check_existence_sql=arr.get(0)[5].trim();
				String check_existence_on_fields=arr.get(0)[6].trim();
				
				String recursive_fields=arr.get(0)[7].trim();
				
				ct.setTabFilter(tab_filter);
				
				ct.setRecursiveFields(recursive_fields);
				
				ct.setHints(hint_after_select,hint_before_table,hint_after_table);
				ct.setExistanceCheckConfig(check_existence_action, check_existence_sql, check_existence_on_fields);
			 
				
			}
			
			if (ct.level>ROOT_LEVEL) {
				
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+ct.parent_tab_id});
				bindlist.add(new String[]{"INTEGER",""+ct.tab_id});
				arr=cLib.getDbArray(db.connConf, rel_sql, Integer.MAX_VALUE, bindlist);
				
				if (arr.size()>0) {
					
					
					String rel_type=arr.get(0)[0];
					String parent_tab_pk_fields=arr.get(0)[1];
					String rel_on_fields=arr.get(0)[2];
					String rel_filter=arr.get(0)[3].trim();
					 
					int parent_table_obj_id=getCopyTableObjIdByTabId(tableArr, ct.parent_tab_id);
					ct.setParentRelation(rel_type, parent_tab_pk_fields, rel_on_fields, rel_filter, tableArr.get(parent_table_obj_id));
				
						
				}
			}
			
			ct.compile(copyRefFieldsArr);
			
			tableArr.set(i, ct);
		}
		
		
			
		
		
		mylog("Compiling App : "+app_id+"...Done.");
	}
	
	
	
	
	//---------------------------------------------------------------------------
	
	
	synchronized void getStatistics(ConfDBOper db, boolean force, boolean isOriginatedFromNeed) {
		
		
		if (System.currentTimeMillis()<next_statistic_ts && !force) return;
		
		if (isOriginatedFromNeed) return;
		
		
		try {
			String sql="update tdm_work_package "+
					" set export_count=?, all_count=?, done_count=?, success_count=?, fail_count=? "+
					" where id=?";
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			
			bindlist.add(new String[]{"INTEGER",""+sum_retrieve_count}); //export_count
			bindlist.add(new String[]{"INTEGER",""+sum_retrieve_count}); //all_count
			bindlist.add(new String[]{"INTEGER",""+sum_retrieve_count}); //done_count
			bindlist.add(new String[]{"INTEGER",""+sum_copy_count}); //sum_copy_count
			bindlist.add(new String[]{"INTEGER",""+sum_fail_count}); //fail_count
			bindlist.add(new String[]{"INTEGER",""+work_package_id}); //fail_count
			
			cLib.execSingleUpdateSQL(db.connConf, sql, bindlist);
			
			
			writeCopySummary(db, isOriginatedFromNeed);
		} catch(Exception e) {
			e.printStackTrace();
		}
				
		
		
		next_statistic_ts=System.currentTimeMillis()+STATISTIC_INTERVAL;
		
		
		sendMail(db, "COPY_STATUS",isOriginatedFromNeed);
		
		
	}
	
	//***************************************
	void writeCopySummary(ConfDBOper db,  boolean isOriginatedFromNeed) {
		if (error_flag) return;
		
		if (isOriginatedFromNeed) return;
		
		StringBuilder summary=new StringBuilder();
		
		ArrayList<copyTableObj> copyTableArr=new ArrayList<copyTableObj>();
		
		for (int a=0;a<appList.size();a++) {
			String tabkey=appList.get(a);
			copyTableArr=(ArrayList<copyTableObj>) hm.get(tabkey);
			
			for (int i=0;i<copyTableArr.size();i++) {
				copyTableObj ct=copyTableArr.get(i);
				
				int level=ct.level;
				String source_tab=ct.source_catalog+"."+ ct.source_owner+"."+ct.source_table_name;
				String target_tab=ct.target_catalog+"."+ct.target_owner+"."+ct.target_table_name;
				long copy_count=ct.copy_count;
				
				for (int l=1;l<level;l++) 
					summary.append("\t");
				
				summary.append("["+copy_count+"] records copied from ["+source_tab+"] to ["+target_tab+"]");
				
				summary.append("\n");
				
			} //for i
			
		}// for a
		
		
		
		
		String sql="update tdm_work_plan "+
				" set post_script=? "+
				" where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.add(new String[]{"STRING",summary.toString()}); 
		bindlist.add(new String[]{"INTEGER",""+work_plan_id}); 
		
		cLib.execSingleUpdateSQL(db.connConf, sql, bindlist);
		
	}
	
	//****************************************
	public long  doWorkPackage(ConfDBOper db, int master_id, int work_plan_id, int work_package_id, boolean export_flag, boolean mask_flag) {
		long copy_count=0;
		
		this.work_plan_id=work_plan_id;
		this.work_package_id=work_package_id;
		
		
		String sql="select app_id, env_id, target_env_id, "+
				" copy_filter, copy_filter_bind, copy_rec_count, "+
				" copy_repeat_count, target_owner_info, run_type, run_options, on_error_action "+
				" from tdm_work_plan where id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+work_plan_id});
		
		ArrayList<String[]> arr=cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		if (arr==null || arr.size()==0) {
			mylog("Exception@Work plan not found :"+work_plan_id);
			return 0;
		}
		
		
		
		int app_id=0;


		String filter_id="";
		String filter_value="";
		long max_row_to_copy=0;
		long repeat_count=0;
		String parallel_condition="";
		String run_type="";

		app_id=Integer.parseInt(arr.get(0)[0]);
		this.source_id=Integer.parseInt(arr.get(0)[1]);
		this.target_id=Integer.parseInt(arr.get(0)[2]);
		filter_id=arr.get(0)[3];
		filter_value=arr.get(0)[4];
		max_row_to_copy=Long.parseLong(arr.get(0)[5]);
		repeat_count=Long.parseLong(arr.get(0)[6]);
		target_owner_info=arr.get(0)[7];
		run_type=arr.get(0)[8];
		run_options=arr.get(0)[9];
		
		String on_error_action=arr.get(0)[10];
		
		this.is_on_error_stop=true;
		if (on_error_action.equals("CONTINUE"))  is_on_error_stop=false;
		
		if (max_row_to_copy<0) max_row_to_copy=0;
		if (repeat_count<1) repeat_count=1;
		
		
		
		if (run_type.equals("ROLLBACK")) {
			
			try {
				rollbackPerform(db, work_plan_id);
			} catch(Exception e) {
				e.printStackTrace();
				mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			}
			
			
			closeAll();
			return 0;
		} 

		
		clearRollbackFiles(db,work_plan_id);
		
		
		cLib.setWorkPackageStatus(
				db.connConf, 
				work_plan_id, 
				work_package_id,
				master_id, 
				cLib.WORK_PACKAGE_STATUS_EXPORTING);

		/********************************************************/
		/********************************************************/
		copyApplication(null, null, db, app_id, filter_id, filter_value, max_row_to_copy , repeat_count, false);
		/********************************************************/
		/********************************************************/
		
		
		
		cLib.setWorkPackageStatus(
				db.connConf, 
				work_plan_id, 
				work_package_id,
				master_id, 
				cLib.WORK_PACKAGE_STATUS_FINISHED);
		
		if (logerr.length()>0) {
			sql="update tdm_work_package set err_info=? where id=?";
			bindlist.clear();
			bindlist.add(new String[]{"STRING",""+logerr.toString()});
			bindlist.add(new String[]{"INTEGER",""+work_package_id});
			
			cLib.execSingleUpdateSQL(db.connConf, sql, bindlist);
		}
		
		sql="select count(*) from tdm_work_package where id!=? and work_plan_id=? and status!='FINISHED' ";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+work_package_id});
		bindlist.add(new String[]{"INTEGER",""+work_plan_id});
		
		arr=cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		if (arr.size()==1 && Integer.parseInt(arr.get(0)[0])==0) {
			sql="select status from tdm_work_plan where id=?";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+work_plan_id});
			arr=cLib.getDbArray(db.connConf, sql, 1, bindlist);
			
			if (arr!=null && arr.size()==1 && !arr.get(0)[0].equals("CANCELLED")) {
				db.setWorkPlanStatus(work_plan_id, "FINISHED");
			}
			
			
		}
		
		
		boolean rollback_needed=false;
		if (log.indexOf("Exception@")>-1) rollback_needed=true;
		saveRollbackInfo(db, null, true);
		
			
		closeAll();
		return copy_count;
	}
	
	
	
	
	//************************************************************
	
	int MAX_RB_REC_SIZE=100000;
	int RB_FILE_NUM=0;
	
	synchronized void saveRollbackInfo(ConfDBOper db, String[] rollbackInfoArr,  boolean force_save) {
		
		
		if (rollbackInfoArr!=null) 
			rollbackArr.add(rollbackInfoArr);
			
		
		
		if (rollbackArr.size()<MAX_RB_REC_SIZE && !force_save) return;
		
		if (hm.containsKey("ROLLBACK_WRITING")) {
			int c=0;
			while(hm.containsKey("ROLLBACK_WRITING")) {
				if (c % 100==0) mylog("Waiting rollback info write process...");
				c++;
				try{Thread.sleep(10);} catch(Exception e) {}
			}
			return;
		}
		
		hm.put("ROLLBACK_WRITING", true);
		
		ArrayList<String[]> tmpRollbackArr=new ArrayList<String[]>();
		tmpRollbackArr.addAll(rollbackArr);
		rollbackArr.clear();
		
		System.out.println("***************************************");
		System.out.println("        SAVE ROLLBACK INFO  ("+(RB_FILE_NUM+1)+")     ");
		System.out.println("***************************************");

		String tdm_home=cLib.getParamByName(db.connConf, "TDM_PROCESS_HOME");
		
		String tdm_rollback_path=tdm_home+File.separator+"rollback";
		
		File Ftdm=new File(tdm_rollback_path);
		
		boolean is_created=false;
		
		if (Ftdm.exists())
			is_created=true;
		else 
			try {
				mylog("Creating... "+tdm_rollback_path);
				is_created=Ftdm.mkdir();
			} catch(Exception e) { e.printStackTrace();}
		
		if (!is_created) {
			mylog("Rollback folder not created. ");
			return;
		}
		
		String file_name="";
		boolean is_success=false;
		
		//rollbackArr, rollbackSqlArr, rollbackFieldTypeIdArr, rollbackFieldTypeNameArr
		
		mylog("Rollback info is saving...");
		
		RB_FILE_NUM++;
		
		file_name=tdm_rollback_path+File.separator+work_plan_id+"_rollbackArr_"+RB_FILE_NUM+".bin";
		is_success=writeObj2File(tmpRollbackArr, file_name);
		
		if (!is_created) {
			mylog("rollbackArr Rollback info not created. ");
			return;
		}


			
		
		file_name=tdm_rollback_path+File.separator+work_plan_id+"_rollbackSqlArr.bin";
		is_success=writeObj2File(rollbackSqlArr, file_name);
		
		if (!is_created) {
			mylog("rollbackSqlArr Rollback info not created. ");
			return;
		}
		
		file_name=tdm_rollback_path+File.separator+work_plan_id+"_rollbackFieldTypeIdArr.bin";
		is_success=writeObj2File(rollbackFieldTypeIdArr, file_name);
		
		if (!is_created) {
			mylog("rollbackFieldTypeIdArr Rollback info not created. ");
			return;
		}
		
		file_name=tdm_rollback_path+File.separator+work_plan_id+"_rollbackFieldTypeNameArr.bin";
		is_success=writeObj2File(rollbackFieldTypeNameArr, file_name);
		
		if (!is_created) {
			mylog("rollbackFieldTypeNameArr Rollback info not created. ");
			return;
		}
		
		mylog("Rollback info saved for later use.");
		
		hm.remove("ROLLBACK_WRITING");

		
	}
	
	//**************************************************************
	boolean writeObj2File(Object Obj, String file_name) {
		 
		File f=new File(file_name);
		if (f.exists()) 
			try {f.delete();} catch(Exception e ) {}
		
		
		try {
			 FileOutputStream fos= new FileOutputStream(file_name);
			 ObjectOutputStream oos= new ObjectOutputStream(fos);
			 oos.writeObject(Obj);
	         oos.close();
	         fos.close();
		 } catch(Exception e) {
			 e.printStackTrace();
			 return false;
		 }
		
		return true;
	}
	
	//************************************************************
	void rollbackPerform(ConfDBOper db, int RB_work_plan_id) {
		
		System.out.println("***************************************");
		System.out.println("        START ROLLBACK PROCESS         ");
		System.out.println("***************************************");
		

		StringBuilder rollbackSQL=new StringBuilder();
		PreparedStatement pstmt=null;
		
		int LAST_ROLLBACK_NO=getLastRollbackFileNo(db, RB_work_plan_id);
		
		boolean is_first_load=true;
		
		for (int FILE_NO=LAST_ROLLBACK_NO;FILE_NO>=1;FILE_NO--) {
			boolean is_loaded=loadRollbackInfoFromFiles(db, RB_work_plan_id, FILE_NO, is_first_load);
			
			is_first_load=false;
			
			if (!is_loaded) break;
			
			String last_rollback_db_id="";
			int rollback_db_instance_id=-1;
			
			for (int r=rollbackArr.size()-1;r>=0;r--) {
				String[] arrRoll=rollbackArr.get(r);
				String rollback_catalog=arrRoll[0];
				String rollback_owner=arrRoll[1];
				String rollback_table_name=arrRoll[2];
				String copy_action=arrRoll[3];
				int RB_conf_id=Integer.parseInt(arrRoll[4]);
				String rollback_db_id=arrRoll[5];
				
				
				
				if (!last_rollback_db_id.equals(rollback_db_id)) {
					if (rollback_db_instance_id!=-1) 
						releaseDbInstance(rollback_db_instance_id);
					rollback_db_instance_id=getDBArrInstance(db, "ANY",rollback_db_id);
					cLib.setCatalogForConnection(connArr.get(rollback_db_instance_id), rollback_catalog);
					last_rollback_db_id=rollback_db_id;
				}
				
				
				if (r % 1000 == 0 ) 
					try {connArr.get(rollback_db_instance_id).commit();} catch(Exception e) {}
				
				if (error_flag) break;
				
				
				if (RB_conf_id==-1) continue;
				
				rollbackSQL.setLength(0);
				rollbackSQL.append(rollbackSqlArr.get(RB_conf_id));
				
				try {
					pstmt=connArr.get(rollback_db_instance_id).prepareStatement(rollbackSQL.toString());
					try{pstmt.setQueryTimeout(2);} catch(Exception e) {}
				} catch(Exception e) {
					mylog("Rollback MSG 1      : " +e.getMessage());
					//mylog("Exception@Rollback SQL        : " +rollbackSQL.toString());
					//mylog("Exception@Rollback STACKTRACE : " + opAutoLib.getStackTraceAsStringBuilder(e).toString());
					
					continue;
				}
				
				
				int start_IND=6;
				int targetFieldNo=-1;
				if (arrRoll.length>start_IND) 
					for (int f=start_IND;f<arrRoll.length;f++) {
						targetFieldNo++;
						//mylog("Rollback binding : ["+rollbackFieldTypeNameArr.get(RB_conf_id)[targetFieldNo]+"] => "+arrRoll[f]);
						setPstmtBinding(
								pstmt,
								targetFieldNo,
								rollbackFieldTypeIdArr.get(RB_conf_id)[targetFieldNo],
								rollbackFieldTypeNameArr.get(RB_conf_id)[targetFieldNo],
								arrRoll[f]);	
						
						
					}
				
				db.heartbeat(db.TABLE_TDM_MASTER, 0, db.master_id);
				
				try {
					long start_ts=System.currentTimeMillis();
					
					pstmt.executeUpdate();
					mylog("Rollback ["+rollback_catalog+"]"+rollback_owner+"."+rollback_table_name+" is successfull. Duration "+ (System.currentTimeMillis()-start_ts)+ " msecs");
				} catch(Exception e) {
					mylog("Rollback MSG  2      : " +e.getMessage());
					mylog("Exception@Rollback SQL : " +rollbackSQL.toString());
					mylog("Exception@Rollback MSG : " + e.getMessage());
				} finally {
					try {if (pstmt!=null) pstmt.close();} catch(Exception e) {}
				}

			}
			
			try {connArr.get(rollback_db_instance_id).commit();} catch(Exception e) {}
			
			if (error_flag) break;
			
			if (rollback_db_instance_id!=-1) 
				releaseDbInstance(rollback_db_instance_id);
		}
		
		
		
		
		
		
		
		
		
		
		String sql="";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		cLib.setWorkPackageStatus(
				db.connConf, 
				work_plan_id, 
				work_package_id,
				db.master_id, 
				cLib.WORK_PACKAGE_STATUS_FINISHED);
		
		if (logerr.length()>0) {
			sql="update tdm_work_package set err_info=? where id=?";
			bindlist.clear();
			bindlist.add(new String[]{"STRING",""+logerr.toString()});
			bindlist.add(new String[]{"INTEGER",""+work_package_id});
			
			cLib.execSingleUpdateSQL(db.connConf, sql, bindlist);
		}
		
		sql="select count(*) from tdm_work_package where id!=? and work_plan_id=? and status!='FINISHED' ";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+work_package_id});
		bindlist.add(new String[]{"INTEGER",""+work_plan_id});
		
		ArrayList<String[]>arr=cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		if (arr.size()==1 && Integer.parseInt(arr.get(0)[0])==0) {
			sql="select status from tdm_work_plan where id=?";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+work_plan_id});
			arr=cLib.getDbArray(db.connConf, sql, 1, bindlist);
			
			if (arr!=null && arr.size()==1 && !arr.get(0)[0].equals("CANCELLED")) {
				db.setWorkPlanStatus(work_plan_id, "FINISHED");
			}
			
			
		}
	}
	
	//***************************************************************************
	String getRollbackPath(ConfDBOper db) {
		String tdm_home=cLib.getParamByName(db.connConf, "TDM_PROCESS_HOME");
		
		String tdm_rollback_path=tdm_home+File.separator+"rollback"; 
		
		return tdm_rollback_path;
	}
	
	//****************************************************************************
	int clearRollbackFiles(ConfDBOper db, int RB_work_plan_id) {
		
		String tdm_rollback_path=getRollbackPath(db);
		
		
		for (int FILE_NO=1;FILE_NO<1000;FILE_NO++) {
			String filename=tdm_rollback_path+File.separator+RB_work_plan_id+"_rollbackArr_"+FILE_NO+".bin";
			File f=new File(filename);
			if (!f.exists()) break;
			try{f.delete();} catch(Exception e) {e.printStackTrace();}
		}
		
		return 0;
		
	}
	
	//****************************************************************************
	int getLastRollbackFileNo(ConfDBOper db, int RB_work_plan_id) {
		
		String tdm_rollback_path=getRollbackPath(db);
		
		
		for (int FILE_NO=1;FILE_NO<1000;FILE_NO++) {
			String filename=tdm_rollback_path+File.separator+RB_work_plan_id+"_rollbackArr_"+FILE_NO+".bin";
			File f=new File(filename);
			if (!f.exists()) return FILE_NO-1;
		}
		
		return 0;
		
	}
	
	//*****************************************************************************
	boolean loadRollbackInfoFromFiles(ConfDBOper db, int RB_work_plan_id, int FILE_NO, boolean is_first_load) {
				
		String tdm_rollback_path=getRollbackPath(db);
		
		File Ftdm=new File(tdm_rollback_path);
		
		boolean is_created=false;
		
		if (!Ftdm.exists()) {
			mylog("Rollback folder not exists. ");
			return false;
		}

		String file_name="";
		boolean is_success=false;
		
		//rollbackArr, rollbackSqlArr, rollbackFieldTypeIdArr, rollbackFieldTypeNameArr
		
		mylog("Rollback info is loading...");
		
		rollbackArr.clear();
		
		file_name=tdm_rollback_path+File.separator+RB_work_plan_id+"_rollbackArr_"+FILE_NO+".bin";
		rollbackArr=(ArrayList<String[]>) loadObjFromFile(file_name);
		
		if (rollbackArr==null) {
			mylog("rollbackArr is not loaded... ");
			rollbackArr=new ArrayList<String[]>();
			return false;
		}
		
		//no need to reload the others.
		if (!is_first_load) return true;
		
		rollbackSqlArr.clear();
		file_name=tdm_rollback_path+File.separator+RB_work_plan_id+"_rollbackSqlArr.bin";
		rollbackSqlArr=(ArrayList<String>) loadObjFromFile(file_name);
		if (rollbackSqlArr==null) {
			mylog("rollbackSqlArr is not loaded... ");
			rollbackSqlArr=new ArrayList<String>();
			return false;
		}
		
		rollbackFieldTypeIdArr.clear();
		file_name=tdm_rollback_path+File.separator+RB_work_plan_id+"_rollbackFieldTypeIdArr.bin";
		rollbackFieldTypeIdArr=(ArrayList<Integer[]>) loadObjFromFile(file_name);
		if (rollbackFieldTypeIdArr==null) {
			mylog("rollbackFieldTypeIdArr is not loaded... ");
			rollbackFieldTypeIdArr=new ArrayList<Integer[]>();
			return false;
		}

		rollbackFieldTypeNameArr.clear();
		file_name=tdm_rollback_path+File.separator+RB_work_plan_id+"_rollbackFieldTypeNameArr.bin";
		rollbackFieldTypeNameArr=(ArrayList<String[]>)loadObjFromFile( file_name);
		if (rollbackFieldTypeNameArr==null) {
			mylog("rollbackFieldTypeNameArr is not loaded... ");
			rollbackFieldTypeNameArr=new ArrayList<String[]>();
			return false;
		}

		mylog("Rollback info loaded successfully.");
		
		return true;

	}
	
	//****************************************************************************
	public Object loadObjFromFile(String file_name) {
		File f=new File(file_name);
		System.out.println("Loading object from "+file_name);
		
		if (!f.exists()) {
			mylog("File not found "+file_name);
			return null;
		}
		
		Object obj=null;
		
		try {
			FileInputStream fis = new FileInputStream(file_name);
			ObjectInputStream ois = new ObjectInputStream(fis);
			obj=ois.readObject();
			ois.close();
            fis.close();
		} catch(Exception e) {
			e.printStackTrace();
			mylog("Rollback load error : "+e.getMessage());
			return null;
		}
		
		System.out.println("Loading object done : "+file_name);

		
		return obj;
	}

	//*****************************************************************************

	ArrayList<String[]> maskProfileArr=new ArrayList<String[]>();
	
	final int PROFILE_FIELD_ID=0;
	final int PROFILE_FIELD_NAME=1;
	final int PROFILE_FIELD_RULE_ID=2;
	final int PROFILE_FIELD_POST_STMT=3;
	final int PROFILE_FIELD_HIDE_CHAR=4;
	final int PROFILE_FIELD_HIDE_AFTER=5;
	final int PROFILE_FIELD_HIDE_BY_WORD=6;
	final int PROFILE_FIELD_SRC_LIST_ID=7;
	final int PROFILE_FIELD_RANDOM_RANGE=8;
	final int PROFILE_FIELD_RANDOM_CHAR_LIST=9;
	final int PROFILE_FIELD_DATA_CHANGE_PARAMS=10;
	final int PROFILE_FIELD_FIXED_VAL=11;
	final int PROFILE_FIELD_JS_CODE=12;
	final int PROFILE_FIELD_SHORT_CODE=13;
	
	
	
	//------------------------------------------------------------------
	@SuppressWarnings("unchecked")
	void loadMaskingConfiguration(ConfDBOper db) {

		if (hm.containsKey("MASK_PROFILE_ARRAY")) return;
		
		
		String sql="select "+
					" id, "+
					" name, "+
					" rule_id, "+
					" post_stmt, "+
					" hide_char, "+
					" hide_after, "+
					" hide_by_word, " + 
					" src_list_id,  " +
					" random_range, " + 
					" random_char_list, "+
					" date_change_params, " +
					" fixed_val, "+
					" js_code, "+
					" short_code "+
					" from tdm_mask_prof "  + 
					" where valid='YES' ";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		maskProfileArr=cLib.getDbArray(db.connConf, sql, Integer.MAX_VALUE, bindlist);
		
		hm.put("MASK_PROFILE_ARRAY", maskProfileArr);
		
		if (maskProfileArr==null) maskProfileArr=new ArrayList<String[]>();
		
		for (int p=0;p<maskProfileArr.size();p++) {
			String mask_prof_id=maskProfileArr.get(p)[PROFILE_FIELD_ID];
			String short_code=maskProfileArr.get(p)[PROFILE_FIELD_SHORT_CODE];
			
			hm.put("ID_OF_PROFILE_"+mask_prof_id, p);
			hm.put("MASK_PROFILE_ID_BY_SHORT_CODE_"+short_code, Integer.parseInt(mask_prof_id));
		}
		
		
		
	}
	
	//***************************************************************
	@SuppressWarnings("unchecked")
	void loadListItems(ConfDBOper db, int list_id) {
		boolean is_loaded_or_loading=hm.containsKey("LIST_"+list_id+"_LOADED") || hm.containsKey("LIST_"+list_id+"_LOADING...");
		
		if (is_loaded_or_loading) return;
		
		
		
		hm.put("LIST_"+list_id+"_LOADING...", true);
		
		String sql="select title_list, name from tdm_list where id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+list_id});
		
		ArrayList<String[]> arrT=cLib.getDbArray(db.connConf, sql, 1, bindlist);
		
		String title_list=arrT.get(0)[0];
		String list_name=arrT.get(0)[1];
		
		cLib.mylog(cLib.LOG_LEVEL_INFO,"Loading list .... "+list_name );
		
		int title_count=0;
		ArrayList<String> titleArr=new ArrayList<String>();
		
		if (!genLib.nvl(title_list,"-").equals("-") && title_list.contains("|::|")) {
			String[] arr=title_list.split("\\|::\\|");
			for (int i=0;i<arr.length;i++) 
				if (arr[i].length()>0) {
					title_count++;
					titleArr.add(arr[i]);						
					}	
		}
		
		sql="select list_val from tdm_list_items where list_id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+list_id});
		
		
		ArrayList<String[]> litItems= cLib.getDbArray(db.connConf, sql, Integer.MAX_VALUE, bindlist);
		
		ArrayList<String[]> newList=new ArrayList<String[]>();
		StringBuilder sb=new StringBuilder();
		int pos=0;
		
		for (int k=0;k<litItems.size();k++) {
			if (title_count>0) {
				String[] row=new String[title_count];
				
				sb.setLength(0);
				sb.append(litItems.get(k)[0]);
				sb.append("|::|");
				
				if (k % 1000==0) 
					cLib.mylog(cLib.LOG_LEVEL_INFO,"Loading list .... "+(k+1)+"/"+litItems.size() );
				
				for (int j=0;j<title_count;j++) {
					pos=sb.indexOf("|::|");
					
					if (pos==0) 
						row[j]="";
					else 
						row[j]=sb.substring(0,pos);
			
					sb.delete(0, pos+4);
				}
				
				newList.add(row);
				
			} else 
				newList.add(new String[]{litItems.get(k)[0]});
			
		} // for k
		
		
		
		int list_Arr_Id=globalListArr.size();
		
		hm.put("LIST_"+list_id+"_GLOBAL_ARRAYLIST_ID", list_Arr_Id);
		hm.put("LIST_"+list_id+"_SIZE",newList.size());
		
		globalListArr.add(newList);
		
		
		for (int t=0;t<titleArr.size();t++) 
			hm.put("LIST_"+list_id+"_CELL_ID_OF_"+titleArr.get(t), t);
		
		hm.put("LIST_"+list_id+"_LOADED", true);
		hm.remove("LIST_"+list_id+"_LOADING...");
		
		cLib.mylog(cLib.LOG_LEVEL_INFO,"Done.  "+list_name +"." + litItems.size() + " items loaded.");
		
	}
	
	
	//***************************************
	private String maskJavascript(
			ConfDBOper db,
			String original_value, 
			String p_js_code,
			copyTableObj ct,
			Connection connTarget,
			ArrayList<String> fieldValArr,
			int field_id
			) {
		String ret1=original_value;
		
		if (p_js_code.length()==0) return original_value;
		
		StringBuilder js_code=new StringBuilder(p_js_code);
		
		if (js_code.indexOf("${")>-1 && js_code.indexOf("}")>-1) {
			//replace quotes and double quotes with escaped versions
			try {
				
				if (original_value.contains("\"")) 
					original_value=original_value.replaceAll("\"", "\\\"");
				
				//replace ${1} with original value
				if (js_code.indexOf("${1}")>-1)
					while(true) {
						int ind=js_code.indexOf("${1}");
						if (ind==-1) break;
						js_code.delete(ind, ind+4);
						js_code.insert(ind, original_value.replaceAll("\"","\'").replaceAll("(\\r|\\n)", "\"+\n\t\""));
					}

				//replace ${FIELD_NAME} with field values
				while(true) {
					int start_ind=js_code.indexOf("${");
					if (start_ind==-1) break;
					
					int end_ind=js_code.indexOf("}",start_ind);
					if (end_ind==-1) break;
					
					if (end_ind<start_ind) break;
					if (start_ind+2==end_ind) break; //break if no field name given
					
					String field_name=js_code.substring(start_ind+2,end_ind);
					
					int field_order=-1;
					
					for (int f=0;f<ct.fields.size();f++) 
						if (ct.fields.get(f)[0].equals(field_name)) {
							field_order=f;
							break;
						}
					
					js_code.delete(start_ind, end_ind+1);
					
					if (field_order>-1) 
						js_code.insert(start_ind, fieldValArr.get(field_order).replaceAll("\"","\'").replaceAll("(\\r|\\n)", "\"+\n\t\""));
					
				} //while(true)
				
				
				
				
				
				//$mask(${FIRST_NAME},MASK_SHORT_CODE)
				if (js_code.indexOf("$mask(")>-1) {
					
					while(true) {
						int start_ind=js_code.indexOf("$mask(");
						if (start_ind==-1) break;
						
						int end_ind=js_code.indexOf(")",start_ind);
						
						if (end_ind==-1) break;
						if (end_ind<start_ind) { System.out.println("**** "+ end_ind+"/"+start_ind); break; }
						
						if (start_ind+6==end_ind) break; //break if no field name given
						
						String inner_text=js_code.substring(start_ind+6,end_ind);
						
						js_code.delete(start_ind, end_ind+1);
						
						int commma_ind=inner_text.lastIndexOf(",");
						
						
						if (commma_ind>-1) {
							StringBuilder val_to_mask=new StringBuilder();
							String short_code="";
							
							
							
							if (commma_ind>0) val_to_mask.append(inner_text.substring(0,commma_ind));
							try {
								short_code=inner_text.substring(commma_ind+1);
								} catch(Exception e) {}
							
							
							if (short_code.length()>0)
								js_code.insert(start_ind, mask(db, ct, connTarget,val_to_mask, field_id, fieldValArr, short_code.trim()));
							
						} //if (commma_ind>-1)
					} //while true
				} //if (js_code.indexOf("$mask(")>-1)

				
			} catch (Exception e) {
				mylog("Exception@maskJavaScript.Replacement at orig_value : [" + original_value + "]: "+e.getMessage());
				mylog("Exception@maskJavaScript.Replacement   : "+genLib.getStackTraceAsStringBuilder(e).toString());
				e.printStackTrace();
			}
		}
		
		
		
		if (factory==null) 	{
			factory = new ScriptEngineManager();
			engine = factory.getEngineByName("JavaScript");
			

		}
		
		try {
			ret1=""+ engine.eval(js_code.toString());
		} catch (Exception e) {
			mylog("EXCEPTION AT SCRIP : "+e.getMessage());
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			mylog("=====================================");
			mylog( js_code.toString());
			mylog( "=====================================");
			
			
			e.printStackTrace();
			ret1=original_value;
		}
		
		return ret1;
	}
	
	
	
	
	//****************************************************************
	String mask(
			ConfDBOper db,
			copyTableObj ct,
			Connection connTarget,
			StringBuilder original_value,
			int f,
			ArrayList<String> fieldValArr,
			String short_code) {
		
		
		
		int mask_prof_id=-9999;
		
		if (short_code!=null && short_code.trim().length()>0) {
			try{
				mask_prof_id=(int) hm.get("MASK_PROFILE_ID_BY_SHORT_CODE_"+short_code);
				} 
			catch(Exception e) {
				mylog("Exception@Profile ID not found with shortcode : " + short_code);
				}

		}

		else {
			if (ct.fields.get(f)[FIELD_COLS_IS_CONDITIONAL].equals(CONST_NO)) 
				try {mask_prof_id=Integer.parseInt(ct.fields.get(f)[FIELD_COLS_MASK_PROF_ID]); }catch(Exception e) {e.printStackTrace();}
			else 
				mask_prof_id=decodeMaskParam(ct, ct.fields.get(f)[FIELD_COLS_CONDITION_EXPR], fieldValArr);
		}
		
		
		if (mask_prof_id==-9999) return original_value.toString();
		
		int mask_prof_arr_id=-1;
		try {
			mask_prof_arr_id=(int) hm.get("ID_OF_PROFILE_"+mask_prof_id);
		} catch(Exception e) { 
			mylog("Mask profile ("+mask_prof_id+") is not found in profile array.");
			return original_value.toString();
			}
		
		
		StringBuilder ret1=new StringBuilder(original_value.toString());
		
		if (ret1.length()==0) return ret1.toString();
		
		//liste tipi maskelemelerde multicolumn deðerlerde boþ alana da deðer yazýlýr
		//diger maskelemelerde bos geldiyse direk bos geri donulur
		if (original_value.length() == 0 && genLib.nvl(ct.fields.get(f)[FIELD_COLS_LIST_FIELD_NAME],CONST_DASH).equals(CONST_DASH) ) return CONST_EMPTY_STR;	
		
		//MASKING RULES
		switch(maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_RULE_ID]) {
			
			case MASK_RULE_JAVASCRIPT : {
				ret1.setLength(0);
				
				ret1.append(
						maskJavascript(
								db,
								original_value.toString(),
								maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_JS_CODE], //js_code
								ct,
								connTarget,
								fieldValArr,
								f
										)
											);
				
				break;
			}
			//------------------------------------------------------------------
			case MASK_RULE_HASHLIST : {
				int list_id=0;
				try{list_id=Integer.parseInt(maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_SRC_LIST_ID]);} catch(Exception e) {}
				if (list_id>0) 
					{
					StringBuilder list_ref_value=new StringBuilder(original_value);
					StringBuilder filter_list_value=new StringBuilder("");
					
					if (ct.hasFixedListColumns) {
						for (int x=0;x<ct.fixedFieldsArr.size();x++) 
							list_ref_value.append(fieldValArr.get(ct.fixedFieldsArr.get(x)));
					}
					
					ret1.setLength(0);
					ret1.append(maskList(
							db,
							original_value.toString(),
							list_id, 
							list_ref_value.toString(), 
							genLib.nvl(ct.fields.get(f)[FIELD_COLS_LIST_FIELD_NAME],CONST_DASH), 
							filter_list_value.toString()
							));
					
	
					}
				break;	
				}
			
				case MASK_RULE_COPY_REF : {
					
					String copy_ref_tab_id="";
					String copy_ref_field_name="";
					String copy_needed_app_id="";
					
					try{copy_ref_tab_id=ct.fields.get(f)[FIELD_COLS_COPY_REF_TAB_ID];} catch(Exception e) {copy_ref_tab_id="0";}
					try{copy_ref_field_name=ct.fields.get(f)[FIELD_COLS_COPY_REF_FIELD_NAME];} catch(Exception e) {copy_ref_field_name="";}
					try{copy_needed_app_id=ct.fields.get(f)[FIELD_COLS_COPY_REF_TAB_APP_ID];} catch(Exception e) {copy_needed_app_id="";}
					ret1.setLength(0);
					ret1.append(maskCopyRef(original_value.toString(),copy_ref_tab_id,copy_ref_field_name,copy_needed_app_id));
					
					break;	
					}
			
				case MASK_RULE_HIDE : {
					
					String hide_char="";
					int hide_after=0;
					String hide_by_word=CONST_NO;
					try{hide_char=maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_HIDE_CHAR].substring(0,1);} catch(Exception e) {hide_char="*";}
					try{hide_after=Integer.parseInt(maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_HIDE_AFTER]);} catch(Exception e) {hide_after=2;}
					try{hide_by_word=maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_HIDE_BY_WORD];} catch(Exception e) {hide_by_word=CONST_NO;}
					
					ret1.setLength(0);
					ret1.append(maskHide(original_value.toString(),hide_after,hide_char,hide_by_word));
					
					break;	
					}
				
				//------------------------------------------------------------------
				case MASK_RULE_SCRAMBLE_INNER : {
					ret1.setLength(0);
					ret1.append(maskScrambleInner(original_value.toString()));
					break;	
					}
				
				
				//------------------------------------------------------------------
				case MASK_RULE_SCRAMBLE_RANDOM : {
					String char_list="";
					try{char_list=maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_RANDOM_CHAR_LIST];} catch(Exception e) {
						char_list=MASK_DEFAULT_CHAR_LIST;
						}
					
					
					if ((""+char_list).length()==0) char_list=MASK_DEFAULT_CHAR_LIST;
					
					ret1.setLength(0);
					ret1.append(maskScrambleRandom(original_value.toString(),char_list));
					break;	
					}
				
				case MASK_RULE_SCRAMBLE_DATE : {
					String date_format="";
					String date_change_params=genLib.DEFAULT_DATE_FORMAT;
									
					try{date_change_params=maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_DATA_CHANGE_PARAMS];} catch(Exception e) {
						date_change_params="";
						}
	
					ret1.setLength(0);
					ret1.append(maskScrambleDate(original_value.toString(),date_format,date_change_params));
					break;	
					}
				
				
				//------------------------------------------------------------------
				case MASK_RULE_RANDOM_NUMBER : {
					String range="";
					try{range=maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_RANDOM_RANGE];} catch(Exception e) {
						range="";
						}
					ret1.setLength(0);
					ret1.append(maskRandomNumber(original_value.toString(),range));
					break;	
					}
				//------------------------------------------------------------------
				case MASK_RULE_NONE : {
					break;	
					}
				//------------------------------------------------------------------
				case MASK_RULE_FIXED : {
					ret1.setLength(0);
					ret1.append(maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_FIXED_VAL]);
	
					break;	
					}
				
				//------------------------------------------------------------------
				case MASK_RULE_RANDOM_STRING : {
					String range="";
					String char_list="";
					try{range=maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_RANDOM_RANGE];} catch(Exception e) {
						range="";
						}
					try{char_list=maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_RANDOM_CHAR_LIST];} catch(Exception e) {
						char_list=MASK_DEFAULT_CHAR_LIST;
						}
					if ((""+char_list).length()==0) char_list=MASK_DEFAULT_CHAR_LIST;
					
					ret1.setLength(0);
					ret1.append(maskRandomString(original_value.toString(),range,char_list));
					break;	
					}
				
				//------------------------------------------------------------------
				case MASK_RULE_SQL : {
					String sql_code="";
					try{sql_code=maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_JS_CODE];} catch(Exception e) {sql_code="";}
					
					
					
					ret1.setLength(0);
					ret1.append(maskSQL(
							ct,
							connTarget,
							original_value.toString(), 
							sql_code
							));
	
					break;	
					}
			
			
			
		}
		
		
		//POST PROCESS
		if (!maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_POST_STMT].isEmpty()) {
			StringBuilder sbbefore=new StringBuilder(ret1);
			switch(maskProfileArr.get(mask_prof_arr_id)[PROFILE_FIELD_POST_STMT]) {

				case CONST_UPPERCASE : {
					ret1.setLength(0);
					ret1.append(sbbefore.toString().toUpperCase(currLocale));
					break; 
					}
				case CONST_LOWERCASE : {
					ret1.setLength(0);
					ret1.append(sbbefore.toString().toLowerCase(currLocale));
					break; 
					}
				case CONST_INITIALS : {
					ret1.setLength(0);
					ret1.append(initials(sbbefore.toString()));
					break; 
					}
			
			}
		}
		
		return ret1.toString();
	}
	
	final long MASK_COPY_REF_WAIT_TIMEOUT=1*60*1000;
	
	//****************************************
	String maskCopyRef(String orig_value, String copy_ref_tab_id,String copy_ref_field_name, String needed_app_id) {
		
		if (hmMaskedVal.containsKey("T_"+copy_ref_tab_id+"_F_"+copy_ref_field_name+"_V_"+orig_value)) 
			return (String) hmMaskedVal.get("T_"+copy_ref_tab_id+"_F_"+copy_ref_field_name+"_V_"+orig_value);
		
		if (!hmMaskedVal.containsKey("T_"+copy_ref_tab_id+"_F_"+copy_ref_field_name+"_V_"+orig_value)) 
			return "${NO_REF_FOR_TAB_"+copy_ref_tab_id+"_FIELD_"+copy_ref_field_name+"val("+orig_value+")}";

		return (String) hmMaskedVal.get("T_"+copy_ref_tab_id+"_F_"+copy_ref_field_name+"_V_"+orig_value);
	}
	
	// ***************************************
	 String maskList(ConfDBOper db,  String orig_value,int list_id, String list_ref_value, String list_field_name, String list_filter_value) {

		int HASH_CODE=0;

		if (list_ref_value.length()>0) 
			HASH_CODE=normalize(list_ref_value.toString()).hashCode();
		else 
			HASH_CODE=normalize(orig_value).hashCode();
		
		loadListItems(db, list_id);
		
		int i=0;
		try{
			i=Math.abs(HASH_CODE) % (int) hm.get("LIST_"+list_id+"_SIZE");
		} catch(Exception e) {i=0;e.printStackTrace();}
		
		
		try{
			
			int list_global_array_id=-1;
			try {list_global_array_id=(int) hm.get("LIST_"+list_id+"_GLOBAL_ARRAYLIST_ID");} catch(Exception e) {}
			
			if (list_global_array_id==-1) return orig_value;
			
			int list_field_cell_id=0;
			
			if (!list_field_name.equals("-")) {
				
				try {list_field_cell_id=(int) hm.get("LIST_"+list_id+"_CELL_ID_OF_"+list_field_name);} catch(Exception e) {list_field_cell_id=-1;}
				if (list_field_cell_id==-1) return orig_value;
				
				
				if (!genLib.nvl(list_filter_value,"-").equals("-")) {
					
					
				}

			}
			
			/*
			mylog("*** list_ref_value \t:"+list_ref_value);
			mylog("*** list_field_name \t:"+list_field_name);
			mylog("*** list_filter_value \t:"+list_filter_value);
			*/
				
			return genLib.nvl(globalListArr.get(list_global_array_id).get(i)[list_field_cell_id], orig_value);
			
		
			} catch(Exception e) {
				return(orig_value);
			}
		
	}
	 
	// ******************************************
	@SuppressWarnings("unchecked")
	void indexList(int list_id, String index_fields) {
		
		String k_base="LIST_"+list_id;
		
		if (hm.containsKey(k_base+"_INDEXED_"+index_fields)) return;
		
		hm.put(k_base+"_INDEXED_"+index_fields, true);
	}
	
		
	static final String NORMAL_CHARS="ABCDEFGHIJKLMNOPQRSTUWXYZabcdefghijklmnopqrstuwxyz0123456789";
	 
	//******************************************
	public String normalize(String val) {
		
		String val1=val.toUpperCase();
		char[] arr=val1.toCharArray();
		for (int i=0;i<val1.length();i++) {
			String cin=val1.substring(i,i+1);
			if (NORMAL_CHARS.indexOf(cin)==-1) {
				String cout=""+replaceChar(cin);
				if (cin.equals(cout)) cout=" ";
				arr[i]=cout.charAt(0);
			}
		}
		
		return new String(arr).replace(" ", "");
		
	}
	
	static final String CONST_A_CHAR="çÇðÐýÝöÖþÞüÜ";
	static final String CONST_B_CHAR="CCGGIIOOSSUU";
	
	
	//******************************************
	private static final char replaceChar(String in) {
		int pos=CONST_A_CHAR.indexOf(in);
		if (pos==-1) return in.charAt(0);
		return CONST_B_CHAR.charAt(pos);
	}
	
	
	//***********************************************************************
	private String maskSQL(copyTableObj ct, Connection maskConn, String val, String sql_code) {
	//***********************************************************************
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String sql=sql_code;
		
		if (sql.contains("=?") ||sql.contains("= ?")) {
			bindlist.add(new String[]{"STRING",val});
		}
		
		if (sql.contains("%")) {
			if (sql.contains("%OWNER%")) sql=sql.replace("%OWNER%", ct.target_owner);
			else if (sql.contains("%SCHEMA%")) sql=sql.replace("%SCHEMA%", ct.target_owner);
			else if (sql.contains("%SCHEMA_NAME%")) sql=sql.replace("%SCHEMA_NAME%", ct.target_owner);
			else if (sql.contains("%TABLE%")) sql=sql.replace("%TABLE%", ct.target_table_name);
			else if (sql.contains("%TABLE_NAME%")) sql=sql.replace("%TABLE_NAME%", ct.target_table_name);
		}
		

		
		ArrayList<String[]> retArr=cLib.getDbArray(maskConn, sql, 1, bindlist, 100);
							
		if (retArr==null || retArr.size()==0)
			return val;
		return retArr.get(0)[0];
		
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
	
	static final String MASK_DEFAULT_CHAR_LIST="ABCÇDEFGHIÝJJKLMNOÖPQRSÞTUÜWXVYZabcçdefgðhýijklmnoöprsþtuüwxvyz";

	//****************************************
	private String maskScrambleRandom(String orig_value,String char_list) {
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
	private String maskHide(String orig_value,int show_count, String mask_asterix_char,String hide_by_word) {
		if (orig_value.length()<= show_count)
			return orig_value; 
		
		char asterix='*';
		
		try {asterix=mask_asterix_char.toCharArray()[0];} catch(Exception e) {asterix='*';}
		
		char[] arr=orig_value.toCharArray();
		int start_indicator=0;
		
		for (int i=0;i<arr.length;i++) {
			start_indicator++;
			if (start_indicator<=show_count) continue;
			if (arr[i]==' ') {if(hide_by_word.equals("YES")) start_indicator=0;continue;}
			arr[i]=asterix;
		}
		return (new String().valueOf(arr));
	}
	
	
	static final int[] RANDOM_INT_ARRAY={1442, 9105, 9893, 1407, 8590, 869, 6283, 8822, 1762, 9193, 491, 3193, 1934, 5780, 9437, 
		7969, 9621, 8581, 8330, 4220, 3242, 8765, 7323, 5542, 2021, 2262, 8900, 1951, 4636, 2131, 
		7878, 9716, 311, 4196, 5888, 6037, 6022, 8562, 8715, 8438, 2056, 3908, 7997, 8801, 8310, 
		9789, 8409, 1080, 5356, 4547, 7716, 9904, 7624, 2921, 9823, 4518, 793, 7928, 339, 8808, 
		1916, 6196, 34, 3519, 8710, 4554, 4077, 1189, 3957, 8401, 3953, 7829, 2021, 9130, 4566, 
		7907, 7131, 8732, 1182, 821, 7230, 4576, 9599, 7695, 2991, 6337, 8199, 7117, 8877, 45, 
		2403, 7173, 2013, 1315, 432, 9044, 5091, 962, 4277, 4340};
	
	//****************************************
	private String maskScrambleInner(String orig_value) {
		char[] arr=orig_value.toCharArray();
		int[] fabs=RANDOM_INT_ARRAY;
		int len=fabs.length;
		int in_len=orig_value.length();
		int a=0;
		int b=0;
		char t_char='x';
		
		for (int i=0;i<len-1;i++) {
			a=(fabs[i]) % in_len;
			b=(fabs[i+1]) % in_len;
			if (a==b) continue;
			
			t_char=arr[a];
			arr[a]=arr[b];
			arr[b]=t_char;
		}
		

		
		return (new String().valueOf(arr));
	}
	
	// ***************************************
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
	
	// ******************************************
	public int decodeMaskParam(copyTableObj ct, String condition, ArrayList<String> fieldValArr) {
			int ret1 = -9999;

			//conditional 
			if (condition.indexOf("IF[${")==0) {
				
				String[] parts=condition.split("\\|\\|");
				if (parts.length>0) 
				for (int i=0;i<parts.length;i++) {
					String[] a_part=parts[i].split("::");
					
					String a_stmt=a_part[0];

					//no match found, else 
					if (a_stmt.indexOf("ELSE[")==0) {
						String a_mask_prof=a_stmt.split("\\(")[1].split("\\)")[0];
	
						try{ret1=Integer.parseInt(a_mask_prof);} catch(Exception e) {return -9999;}
						break;
					} else {
						String check_field_name=a_stmt.split("\\{")[1].split("\\}")[0];
						int field_id=-1;
						for (int f=0;f<ct.fields.size();f++) {
							if (ct.fields.get(f)[FIELD_COLS_FIELD_NAME].equals(check_field_name)) {
								field_id=f;
								break;
							}
						}
						
						if (field_id==-1 || field_id>fieldValArr.size()-1) return -9999;
						//the first col is row id skipping
						String field_val=fieldValArr.get(field_id);
						
						String a_operand=a_part[1];
						String a_check_val=a_part[2];
						
						String a_mask_prof=a_part[3].split("\\(")[1].split("\\)")[0];

						if (checkIf(field_val, a_operand, a_check_val)) {
							try{ret1=Integer.parseInt(a_mask_prof);} catch(Exception e) {ret1 = -9999;}
							break;
						}
					}
				}
			}
		
		
		return ret1;
	}

	
	// *********************************************
	private boolean checkIf(String val_to_check, String oper, String ctrl_vals) {
		// oper ========> =, !=, like, !like, in, !in,

		//mylog("*** Check if ["+val_to_check+"] "+oper + " ["+ ctrl_vals+"]");
		
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
	
	
	final String BIND_TYPE_STRING="STRING";
	final String BIND_TYPE_NUMERIC="NUMERIC";
	final String BIND_TYPE_DATE="DATE";
	final String BIND_TYPE_TIMESTAMP="TIMESTAMP";
	final String BIND_TYPE_BOOLEAN="BOOLEAN";
	
	final String BIND_DATE_TIME_DEFAULT_TYPE="yyyy-MM-dd HH:mm:ss";
	final String BIND_DATE_TIME_SHORT_DOTTED_TYPE="dd.MM.yyyyy";
	
	//****************************************************************
	String setTargetBinding(
				ResultSet srcRset, 
				PreparedStatement tarPstmt, 
				int sourceFieldNo, 
				int targetFieldNo, 
				String fieldTypeName,
				int fieldType,
				boolean is_field_changed,
				StringBuilder changed_field_value
				) {
		String ret1="";
		
		
		
		if (sourceFieldNo==-1 && changed_field_value.toString().equals("${null}")) {
			//extra fields case
			try {
				tarPstmt.setNull(targetFieldNo+1,fieldType);
			} catch(Exception e) {
				e.printStackTrace();
			}
			return "";
		}
		
		
		
		
		
		try {
				switch(fieldTypeName) {
					
					case BIND_TYPE_STRING : {
						if (is_field_changed) {
							if (tarPstmt!=null) 
								tarPstmt.setString(targetFieldNo+1, changed_field_value.toString());
							ret1=changed_field_value.toString();
						} else {
							if (sourceFieldNo==-1) {
								tarPstmt.setString(targetFieldNo+1, changed_field_value.toString());
								ret1=changed_field_value.toString();
							} else {
								if (targetFieldNo>-1 && tarPstmt!=null) 
									tarPstmt.setString(targetFieldNo+1, srcRset.getString(sourceFieldNo+1));
								ret1=srcRset.getString(sourceFieldNo+1);
							}
							
						}
						break;
					}
					
					
					
					case BIND_TYPE_NUMERIC : {
						//------------------------------------------
						
						switch(fieldType) {
							case java.sql.Types.DOUBLE : {
								
								if (is_field_changed) {
									try{
										double changed_val=0;
										changed_val=Double.parseDouble(changed_field_value.toString());
										if (tarPstmt!=null)
											tarPstmt.setDouble(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
										} 
									catch(Exception e) {
										if (tarPstmt!=null)
											tarPstmt.setDouble(targetFieldNo+1, srcRset.getDouble(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
										
											
										
										e.printStackTrace();
									}
									
								} else {
									
									if (sourceFieldNo==-1) {
										double changed_val=0;
										changed_val=Double.parseDouble(changed_field_value.toString());
										tarPstmt.setDouble(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
									} else {
										if (targetFieldNo>-1 && tarPstmt!=null) 
											tarPstmt.setDouble(targetFieldNo+1, srcRset.getDouble(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
									}
									
								}
								
								break;
							}
							
							case java.sql.Types.FLOAT : {
								if (is_field_changed) {
									try{
										float changed_val=0;
										changed_val=Float.parseFloat(changed_field_value.toString());
										if (tarPstmt!=null) 
											tarPstmt.setFloat(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
										} 
									catch(Exception e) {
										if (tarPstmt!=null)
											tarPstmt.setFloat(targetFieldNo+1, srcRset.getFloat(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
										
										e.printStackTrace();
									}	
								} else {
									if (sourceFieldNo==-1) {
										float changed_val=0;
										changed_val=Float.parseFloat(changed_field_value.toString());
										tarPstmt.setFloat(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
									} else {
										if (targetFieldNo>-1 && tarPstmt!=null) 
											tarPstmt.setFloat(targetFieldNo+1, srcRset.getFloat(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
									}
										
								}
								
								break;
							}
							
							case java.sql.Types.BIGINT : {
								if (is_field_changed) {
									try{
										long changed_val=0;
										changed_val=Long.parseLong(changed_field_value.toString());
										if (tarPstmt!=null)
											tarPstmt.setLong(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
										} 
									catch(Exception e) {
										if (tarPstmt!=null)
											tarPstmt.setLong(targetFieldNo+1, srcRset.getLong(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
										
										e.printStackTrace();
									}	
								} else {
									if (sourceFieldNo==-1) {
										long changed_val=0;
										changed_val=Long.parseLong(changed_field_value.toString());
										tarPstmt.setLong(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
									} else {
										if (targetFieldNo>-1 && tarPstmt!=null) 
											tarPstmt.setLong(targetFieldNo+1, srcRset.getLong(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
									}
										
								}
								
								break;
							}
							
							case java.sql.Types.INTEGER : {
								if (is_field_changed) {
									try{
										int changed_val=0;
										changed_val=Integer.parseInt(changed_field_value.toString());
										if (tarPstmt!=null)
											tarPstmt.setInt(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
										} 
									catch(Exception e) {
										if (tarPstmt!=null)
											tarPstmt.setInt(targetFieldNo+1, srcRset.getInt(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
										
										e.printStackTrace();
									}	
								} else {
									if (sourceFieldNo==-1) {
										int changed_val=0;
										changed_val=Integer.parseInt(changed_field_value.toString());
										tarPstmt.setInt(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
									} else {
										if (targetFieldNo>-1 && tarPstmt!=null) 
											tarPstmt.setInt(targetFieldNo+1, srcRset.getInt(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
									}
										
								}
								
								break;
							}
							
							case java.sql.Types.SMALLINT : {
								if (is_field_changed) {
									try{
										short changed_val=0;
										changed_val=Short.parseShort(changed_field_value.toString());
										if (tarPstmt!=null)
											tarPstmt.setShort(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
										} 
									catch(Exception e) {
										if (tarPstmt!=null)
											tarPstmt.setShort(targetFieldNo+1, srcRset.getShort(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
										
										e.printStackTrace();
									}	
								} else {
									if (sourceFieldNo==-1) {
										short changed_val=0;
										changed_val=Short.parseShort(changed_field_value.toString());
										tarPstmt.setShort(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
									} else {
										if (targetFieldNo>-1 && tarPstmt!=null) 
											tarPstmt.setShort(targetFieldNo+1, srcRset.getShort(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
									}
										
								}
								
								break;
							}
							
							
							case java.sql.Types.TINYINT : {
								if (is_field_changed) {
									try{
										byte changed_val=0;
										changed_val=Byte.parseByte(changed_field_value.toString());
										if (tarPstmt!=null)
											tarPstmt.setByte(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
										} 
									catch(Exception e) {
										if (tarPstmt!=null)
											tarPstmt.setByte(targetFieldNo+1, srcRset.getByte(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
										
										e.printStackTrace();
									}	
								} else {
									if (sourceFieldNo==-1) {
										byte changed_val=0;
										changed_val=Byte.parseByte(changed_field_value.toString());
										tarPstmt.setByte(targetFieldNo+1, changed_val);
										ret1=changed_field_value.toString();
									} else {
										if (targetFieldNo>-1 && tarPstmt!=null) 
											tarPstmt.setByte(targetFieldNo+1, srcRset.getByte(sourceFieldNo+1));
										ret1=srcRset.getString(sourceFieldNo+1);
									}
									
								}
								
								break;
							}
							
							default : {
								
								if (srcRset!=null)
									ret1=srcRset.getString(sourceFieldNo+1);
								
								if (is_field_changed)
									ret1=changed_field_value.toString();
								
								try {
									if (is_field_changed) {
										try {
											double changed_val=0;
											changed_val=Double.parseDouble(changed_field_value.toString());
											if (tarPstmt!=null)
												tarPstmt.setDouble(targetFieldNo+1, changed_val);
										} 
										catch(Exception e) {
											if (tarPstmt!=null)
												tarPstmt.setDouble(targetFieldNo+1, srcRset.getDouble(sourceFieldNo+1));
											
											e.printStackTrace();
										}
									} else 
										if (sourceFieldNo==-1) {
											double changed_val=0;
											changed_val=Double.parseDouble(changed_field_value.toString());
											tarPstmt.setDouble(targetFieldNo+1, changed_val);
											ret1=changed_field_value.toString();
										} else {
											if (targetFieldNo>-1 && tarPstmt!=null) 							
												tarPstmt.setDouble(targetFieldNo+1, srcRset.getDouble(sourceFieldNo+1));
											
										}
										
											
								} catch(Exception e1) {
									//------------------------------------------
									try {
										e1.printStackTrace();
										if (is_field_changed) {
											try {
												float changed_val=0;
												changed_val=Float.parseFloat(changed_field_value.toString());
												if (tarPstmt!=null)
													tarPstmt.setFloat(targetFieldNo+1, changed_val);
											} 
											catch(Exception e) {
												if (tarPstmt!=null)
													tarPstmt.setFloat(targetFieldNo+1, srcRset.getFloat(sourceFieldNo+1));
												
												e.printStackTrace();
											}
										} else 
											if (sourceFieldNo==-1) {
												float changed_val=0;
												changed_val=Float.parseFloat(changed_field_value.toString());
												tarPstmt.setFloat(targetFieldNo+1, changed_val);
												ret1=changed_field_value.toString();
											} else {
												if (targetFieldNo>-1 && tarPstmt!=null) 
													tarPstmt.setFloat(targetFieldNo+1, srcRset.getFloat(sourceFieldNo+1));
											}
									} catch(Exception e2) {
										e1.printStackTrace();
										//------------------------------------------
										try {
											if (is_field_changed) {
												try {
													long changed_val=0;
													changed_val=Long.parseLong(changed_field_value.toString());
													if (tarPstmt!=null)
														tarPstmt.setLong(targetFieldNo+1, changed_val);
												} 
												catch(Exception e) {
													if (tarPstmt!=null)
														tarPstmt.setLong(targetFieldNo+1, srcRset.getLong(sourceFieldNo+1));
													
													e.printStackTrace();
												}
											} else 
												if (sourceFieldNo==-1) {
													long changed_val=0;
													changed_val=Long.parseLong(changed_field_value.toString());
													tarPstmt.setLong(targetFieldNo+1, changed_val);
													ret1=changed_field_value.toString();
												} else {
													if (targetFieldNo>-1 && tarPstmt!=null) 
														tarPstmt.setLong(targetFieldNo+1, srcRset.getLong(sourceFieldNo+1));
												}
										} catch(Exception e3) {
											e3.printStackTrace();
											//------------------------------------------
											try {
												if (is_field_changed) {
													try {
														int changed_val=0;
														changed_val=Integer.parseInt(changed_field_value.toString());
														if (tarPstmt!=null)
															tarPstmt.setInt(targetFieldNo+1, changed_val);
													} 
													catch(Exception e) {
														if (tarPstmt!=null)
															tarPstmt.setInt(targetFieldNo+1, srcRset.getInt(sourceFieldNo+1));
														
														e.printStackTrace();
													}
												} else 
													if (sourceFieldNo==-1) {
														int changed_val=0;
														changed_val=Integer.parseInt(changed_field_value.toString());
														tarPstmt.setInt(targetFieldNo+1, changed_val);
														ret1=changed_field_value.toString();
													} else {
														if (targetFieldNo>-1 && tarPstmt!=null) 
															tarPstmt.setInt(targetFieldNo+1, srcRset.getInt(sourceFieldNo+1));

													}
											} catch(Exception e4) {
												e4.printStackTrace();
												//------------------------------------------
												try {
													if (is_field_changed) {
														try {
															short changed_val=0;
															changed_val=Short.parseShort(changed_field_value.toString());
															if (tarPstmt!=null)
																tarPstmt.setShort(targetFieldNo+1, changed_val);
														} 
														catch(Exception e) {
															if (tarPstmt!=null)
																tarPstmt.setShort(targetFieldNo+1, srcRset.getShort(sourceFieldNo+1));
															
															e.printStackTrace();
														}
													} else 
														if (sourceFieldNo==-1) {
															short changed_val=0;
															changed_val=Short.parseShort(changed_field_value.toString());
															tarPstmt.setShort(targetFieldNo+1, changed_val);
															ret1=changed_field_value.toString();
														} else {
															if (targetFieldNo>-1 && tarPstmt!=null) 
																tarPstmt.setShort(targetFieldNo+1, srcRset.getShort(sourceFieldNo+1));

														}
												} catch(Exception e5) {
													e5.printStackTrace();
													//------------------------------------------
													try {
														if (is_field_changed) {
															try {
																byte changed_val=0;
																changed_val=Byte.parseByte(changed_field_value.toString());
																if (tarPstmt!=null)
																	tarPstmt.setByte(targetFieldNo+1, changed_val);
															} 
															catch(Exception e) {
																if (tarPstmt!=null)
																	tarPstmt.setByte(targetFieldNo+1, srcRset.getByte(sourceFieldNo+1));
																
																e.printStackTrace();
															}
														} else 
															if (sourceFieldNo==-1) {
																byte changed_val=0;
																changed_val=Byte.parseByte(changed_field_value.toString());
																tarPstmt.setByte(targetFieldNo+1, changed_val);
																ret1=changed_field_value.toString();
															} else {
																if (targetFieldNo>-1 && tarPstmt!=null) 
																	tarPstmt.setByte(targetFieldNo+1, srcRset.getByte(sourceFieldNo+1));
															}
																
													} catch(Exception e6) {
														e6.printStackTrace();
													}
												}
											}
										}
									}
								}
							}
						}
						
						
						break;
					}
					
					
					case BIND_TYPE_DATE : {
						
						SimpleDateFormat sdf=new SimpleDateFormat(BIND_DATE_TIME_DEFAULT_TYPE);
						
						if (is_field_changed) {
							try {
								Date changed_val=sdf.parse(changed_field_value.toString());
								java.sql.Date sqlDate=new java.sql.Date(changed_val.getTime());
								tarPstmt.setDate(targetFieldNo+1, sqlDate);
								ret1=changed_field_value.toString();
							} catch(Exception e) {
								tarPstmt.setDate(targetFieldNo+1, srcRset.getDate(sourceFieldNo+1));
								try {ret1=sdf.format(srcRset.getDate(sourceFieldNo+1));} catch(Exception ex) {ret1="";  }
								
								e.printStackTrace();
							}
						} else {
							if (sourceFieldNo==-1) {
								Date changed_val=sdf.parse(changed_field_value.toString());
								java.sql.Date sqlDate=new java.sql.Date(changed_val.getTime());
								tarPstmt.setDate(targetFieldNo+1, sqlDate);
								ret1=changed_field_value.toString();
							} else {
								if (targetFieldNo>-1) 
									tarPstmt.setDate(targetFieldNo+1, srcRset.getDate(sourceFieldNo+1));
								try {ret1=sdf.format(srcRset.getDate(sourceFieldNo+1));} catch(Exception ex) {ret1=""; }
							}
							
							
						}
						
						break;
					}
					
					case BIND_TYPE_TIMESTAMP : {
						
						SimpleDateFormat sdf=new SimpleDateFormat(BIND_DATE_TIME_DEFAULT_TYPE);
						
						if (is_field_changed) {
							try {
								
								tarPstmt.setTimestamp(targetFieldNo+1, srcRset.getTimestamp(sourceFieldNo+1));
								ret1=changed_field_value.toString();
							} catch(Exception e) {
								tarPstmt.setTimestamp(targetFieldNo+1, srcRset.getTimestamp(sourceFieldNo+1));
								try {ret1=sdf.format(srcRset.getDate(sourceFieldNo+1));} catch(Exception ex) {ret1="";  }
								
								e.printStackTrace();
							}
						} else {
							if (sourceFieldNo==-1) {
								Date changed_val=sdf.parse(changed_field_value.toString());
								java.sql.Date sqlDate=new java.sql.Date(changed_val.getTime());
								
								tarPstmt.setDate(targetFieldNo+1, sqlDate);
								ret1=changed_field_value.toString();
							} else {
								if (targetFieldNo>-1) 
									tarPstmt.setTimestamp(targetFieldNo+1, srcRset.getTimestamp(sourceFieldNo+1));
								try {ret1=sdf.format(srcRset.getDate(sourceFieldNo+1));} catch(Exception ex) {ret1="";  }
							}
								
						}
						
						
						
						break;
					}
					
					
					case BIND_TYPE_BOOLEAN : {
						

						if (is_field_changed) {
							try {
								boolean changed_val=false;
								changed_val=Boolean.parseBoolean(changed_field_value.toString().equals("1") ? "true" : changed_field_value.toString());
								if (tarPstmt!=null)
									tarPstmt.setBoolean(targetFieldNo+1, changed_val);
							} 
							catch(Exception e) {
								if (tarPstmt!=null)
									tarPstmt.setBoolean(targetFieldNo+1, srcRset.getBoolean(sourceFieldNo+1));
								
								e.printStackTrace();
							}
						} else 
							if (sourceFieldNo==-1) {
								boolean changed_val=false;
								changed_val=Boolean.parseBoolean(changed_field_value.toString().equals("1") ? "true" : changed_field_value.toString());
								tarPstmt.setBoolean(targetFieldNo+1, changed_val);
								ret1=changed_field_value.toString();
							} else {
								if (targetFieldNo>-1 && tarPstmt!=null) 
									tarPstmt.setBoolean(targetFieldNo+1, srcRset.getBoolean(sourceFieldNo+1));

							}
						
						
						
						break;
					}
					
					default : {
						if (sourceFieldNo==-1) {
							tarPstmt.setBytes(targetFieldNo+1, changed_field_value.toString().getBytes());
						} else {
							if (targetFieldNo>-1) 
								tarPstmt.setBytes(targetFieldNo+1, srcRset.getBytes(sourceFieldNo+1));
						}
							
					}
				} //switch 
				
				if (srcRset!=null && srcRset.wasNull()) {
					if (targetFieldNo>-1) 
						tarPstmt.setNull(targetFieldNo+1,fieldType);
					ret1="";
				}
				
			} catch(Exception e) {
				ret1=null;
				mylog("Exception@setTargetBinding : MSG   : "+e.getMessage());
				mylog("Exception@setTargetBinding : COLNO Source : "+(sourceFieldNo+1));
				mylog("Exception@setTargetBinding : COLNO Target : "+(targetFieldNo+1));
				mylog("Exception@setTargetBinding : TYPE  : "+fieldType);
				
				e.printStackTrace();
			}

		return ret1;

		
	}
	
	
	
	//****************************************************************
	void setPstmtBinding(
				PreparedStatement tarPstmt, 
				int targetFieldNo, 
				int fieldTypeId,
				String fieldTypeName,
				String binding_field_value
				) {

			
		
		try {
					switch(fieldTypeName) {
						
						case BIND_TYPE_STRING : {

							if (binding_field_value.length()==0) 
									tarPstmt.setNull(targetFieldNo+1, fieldTypeId);
								else 
									tarPstmt.setString(targetFieldNo+1, binding_field_value);							
							break;
						}
						
						
						
						case BIND_TYPE_NUMERIC : {
							//------------------------------------------
							switch(fieldTypeId) {
								case java.sql.Types.DOUBLE : {
									
									if (binding_field_value.length()==0) 
										tarPstmt.setNull(targetFieldNo+1, fieldTypeId);
									else
										try {
											double val=Double.parseDouble(binding_field_value);
											tarPstmt.setDouble(targetFieldNo+1, val);
										} catch(Exception e) {
											mylog("Exception@setStmtBinding Double : "+e.getMessage());
										}
									break;
								}
								
								case java.sql.Types.FLOAT : {
									if (binding_field_value.length()==0) 
										tarPstmt.setNull(targetFieldNo+1, fieldTypeId);
									else
										try {
											float val=Float.parseFloat(binding_field_value);
											tarPstmt.setFloat(targetFieldNo+1, val);
										} catch(Exception e) {
											mylog("Exception@setStmtBinding Float : "+e.getMessage());
										}
									
									break;
								}
								
								case java.sql.Types.BIGINT : {
									if (binding_field_value.length()==0) 
										tarPstmt.setNull(targetFieldNo+1, fieldTypeId);
									else
										try {
											long val=Long.parseLong(binding_field_value);
											tarPstmt.setLong(targetFieldNo+1, val);
										} catch(Exception e) {
											mylog("Exception@setStmtBinding Long : "+e.getMessage());
										}
									
									break;
								}
								
								case java.sql.Types.INTEGER : {
									

									
									if (binding_field_value.length()==0) 
										tarPstmt.setNull(targetFieldNo+1, fieldTypeId);
									else
										try {
											int val=Integer.parseInt(binding_field_value);
											tarPstmt.setInt(targetFieldNo+1, val);
										} catch(Exception e) {
											mylog("Exception@setStmtBinding Integer : "+e.getMessage());
										}
									
									break;
								}
								
								case java.sql.Types.SMALLINT : {
									if (binding_field_value.length()==0) 
										tarPstmt.setNull(targetFieldNo+1, fieldTypeId);
									else
										try {
											short val=Short.parseShort(binding_field_value);
											tarPstmt.setShort(targetFieldNo+1, val);
										} catch(Exception e) {
											mylog("Exception@setStmtBinding Short : "+e.getMessage());
										}
									
									break;
								}
								
								
								case java.sql.Types.TINYINT : {
									if (binding_field_value.length()==0) 
										tarPstmt.setNull(targetFieldNo+1, fieldTypeId);
									else
										try {
											byte val=Byte.parseByte(binding_field_value);
											tarPstmt.setByte(targetFieldNo+1, val);
										} catch(Exception e) {
											mylog("Exception@setStmtBinding Byte : "+e.getMessage());
										}
									
									break;
								}
								
								default : {
									
									try { 
										double val=Double.parseDouble(binding_field_value);
										tarPstmt.setDouble(targetFieldNo+1, val);
									} catch(Exception e1) {
										//------------------------------------------
										try {
											float val=Float.parseFloat(binding_field_value);
											tarPstmt.setFloat(targetFieldNo+1, val);
										} catch(Exception e2) {
											//------------------------------------------
											try {
												long val=Long.parseLong(binding_field_value);
												tarPstmt.setLong(targetFieldNo+1, val);
											} catch(Exception e3) {
												//------------------------------------------
												try {
													int val=Integer.parseInt(binding_field_value);
													tarPstmt.setInt(targetFieldNo+1, val);
												} catch(Exception e4) {
													//------------------------------------------
													try {
														short val=Short.parseShort(binding_field_value);
														tarPstmt.setShort(targetFieldNo+1, val);
													} catch(Exception e5) {
														//------------------------------------------
														try {
															byte val=Byte.parseByte(binding_field_value);
															tarPstmt.setByte(targetFieldNo+1, val);
														} catch(Exception e6) {
															mylog("Exception@setStmtBinding Default : "+e6.getMessage());
														}
													}
												}
											}
										}
									}
								}
							}
							
							
							break;
						}
						
						
						case BIND_TYPE_DATE : {
							if (binding_field_value.length()==0) 
								tarPstmt.setNull(targetFieldNo+1, fieldTypeId);
							else {
								try {
									SimpleDateFormat sdf=new SimpleDateFormat(BIND_DATE_TIME_DEFAULT_TYPE);
									Date valDate=sdf.parse(binding_field_value);
									java.sql.Date sqlDate=new java.sql.Date(valDate.getTime());
									tarPstmt.setDate(targetFieldNo+1, sqlDate);	
								} catch(Exception e) {
									mylog("Exception@setStmtBinding Date : "+e.getMessage());
								}
							}
								
							
							
							
							
	
							
							break;
						}
						
						default : {
							if (binding_field_value.length()==0) 
								tarPstmt.setNull(targetFieldNo+1, fieldTypeId);
							else {
								try {
									tarPstmt.setBytes(targetFieldNo+1, binding_field_value.getBytes());
								} catch(Exception e) {
									mylog("Exception@setStmtBinding Binary (Bytes[]) : "+e.getMessage());
								}
							}
						}
					} //switch 
			} catch(Exception e) {
			mylog("Exception@setTargetBinding : MSG          : "+e.getMessage());
			mylog("Exception@setTargetBinding : COLNO Target : "+(targetFieldNo+1));
			mylog("Exception@setTargetBinding : TYPE         : "+fieldTypeId);
			mylog("Exception@setTargetBinding : TYPE_NAME    : "+fieldTypeName);
			
			e.printStackTrace();
		}


		
	}
	
	
	final String COPY_EXIST_ACTION_NONE="NONE";
	final String COPY_EXIST_ACTION_SKIP="SKIP";
	final String COPY_EXIST_ACTION_UPDATE="UPDATE";
	
	
	//------------------------------------------------------------------
	boolean checkExistanceOntarget(copyTableObj ct, Connection connTarget, ResultSet rsSource,ArrayList<Integer> srcFieldTypeArr) {
				
		if (!ct.hasCheckExistance) return false;

		if (ct.check_existence_sql.trim().length()==0) 	 return false;

		
		StringBuilder hmkey=new StringBuilder();
		hmkey.append("ALREADY_CHECKED_"+ct.copy_table_obj_id);
		
		
		for (int i=0;i<ct.checkExistanceFieldIDs.size();i++) {
			int ch_field_id=ct.checkExistanceFieldIDs.get(i);
			//hmkey.setLength(0);
			hmkey.append(setTargetBinding(rsSource, null, ch_field_id, i, ct.fields.get(ch_field_id)[3], srcFieldTypeArr.get(ch_field_id), false, null));
		}
		
		
		
		//if checked before, dont execute query again to check 
		if (hm.containsKey(hmkey.toString())) {
			boolean aval=(boolean) hm.get(hmkey.toString());
			if (aval) return true; 
		}
		
		boolean ret1=false;
		
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ResultSetMetaData meta=null;
		
		StringBuilder sbindval=new StringBuilder();
		
		
		try {
						
			pstmt=connTarget.prepareStatement(ct.check_existence_sql);
			
			for (int i=0;i<ct.checkExistanceFieldIDs.size();i++) {
				int ch_field_id=ct.checkExistanceFieldIDs.get(i);
				setTargetBinding(rsSource, pstmt, ch_field_id, i, ct.fields.get(ch_field_id)[3], srcFieldTypeArr.get(ch_field_id), false, null);
			}
			
			
			rs = pstmt.executeQuery();
			meta=pstmt.getMetaData();
			
			StringBuilder sbx=new StringBuilder();
			
			while(rs.next()) {				
				
				for (int i=0;i<ct.thisTablePKEYfieldORDERS.size();i++) {
					int field_id=ct.thisTablePKEYfieldORDERS.get(i);
					String field_name=ct.fields.get(field_id)[0];
					
					sbx.setLength(0);
					sbx.append(
							setTargetBinding( 
									rs, 
									null, 
									i, 
									0, 
									ct.fields.get(i)[3],
									srcFieldTypeArr.get(field_id), 
									false,
									null)
					);
					
					
					
					hmMaskedVal.put("T_"+ct.tab_id+"_F_"+field_name+"_V_"+sbx.toString(), 
							sbx.toString());
				}
				
				ret1=true; 
				break;
				}
		} catch(Exception e) {
			mylog("Exception@checkExistance ERR  : " + e.getMessage());
			mylog("Exception@checkExistance TABLE  : " + ct.target_owner+"."+ct.target_table_name);
			mylog("Exception@checkExistance SQL  : " + ct.check_existence_sql);
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			
			e.printStackTrace();
			ret1=false;
			
		} finally {
			try {rs.close();} catch(Exception e) {}
			try {pstmt.close();} catch(Exception e) {}
		}
		
		
		
		hm.put(hmkey.toString(), ret1);
		
		return ret1;
		
		
	}
	
	//---------------------------------------------------------------------------
	@SuppressWarnings("unchecked")
	
	
	
	void copyNeededApplications(
				Connection connSource,
				Connection connTarget,
				ConfDBOper db, 
				copyTableObj ct, 
				int needing_field_id, 
				ResultSet rsSource,
				ArrayList<Integer> srcFieldTypeArr
			) {
				
		for (int i=0;i<ct.needingFieldIds.size();i++) {
			
			if (ct.needingFieldIds.get(i)!=needing_field_id) continue;
			int need_arr_id=ct.needingNeedArrIds.get(i);
			
			int needed_app_id=Integer.parseInt(ct.needRelArr.get(need_arr_id)[0]);
			String needed_copy_filter_id=ct.needRelArr.get(need_arr_id)[1];

			String needed_application_name=ct.needRelArr.get(need_arr_id)[3];
			String filter_name=ct.needRelArr.get(need_arr_id)[4];
			
			
			String needing_field_value=setTargetBinding(rsSource, null, needing_field_id, -1, ct.fields.get(needing_field_id)[3], srcFieldTypeArr.get(needing_field_id), false, null);
			
			if (needing_field_value.equals("null") || needing_field_value.length()==0)  continue;
			
			//to prevent infinite loop : parent_id=id ise sonsuz donguye girmesin diye... 
			if (needed_app_id==ct.app_id) {
				
				String pk_field_values="";
				
				
				for (int p=0;p<ct.thisTablePKEYfieldORDERS.size();p++) {
					int pk_field_id=ct.thisTablePKEYfieldORDERS.get(p);
					pk_field_values=pk_field_values
							+setTargetBinding(rsSource, null, pk_field_id, -1, ct.fields.get(pk_field_id)[3], srcFieldTypeArr.get(pk_field_id), false, null);
				}
				
				
				if (needing_field_value.equals(pk_field_values)) continue;
			}
			
			
			
			String filter_type= genLib.nvl((String) hm.get("FILTER_TYPE_"+needed_copy_filter_id),"");
			
			if (filter_type.equals("NO_FILTER")) needing_field_value="${COPY_ALL}";

			
			mylog("Copy Need ["+needed_application_name+"("+needing_field_value+")]");

			//need was already copied before
			if (hmNeed.containsKey("NEED_COPIED_"+needed_app_id+"_"+needed_copy_filter_id+"_"+needing_field_value)  ) {
				if (!filter_type.equals("NO_FILTER"))
					mylog("Need:Already Copied ["+needed_application_name+"("+needing_field_value+")]");
				continue;
			}
				
			
			
			mylog("\t *** Copying Needed Record : "+needed_application_name + " using filter ["+filter_name+"] with value ["+needing_field_value+"]...");
			
			copyApplication(connSource, connTarget, db, needed_app_id, needed_copy_filter_id, needing_field_value, 0, 1, true);

		}
		
		
		
	}
	
	//***************************************************************
	synchronized int getRollbackSqlInfoId(copyTableObj ct, String rollback_type, ArrayList<Integer> fieldTypeArr) {
		
		
		int rollback_sql_id=-1;
		if (rollback_type.equals(ROLLBACK_ACTION_UPDATE))
			rollback_sql_id=rollbackSqlArr.indexOf(ct.update_sql);
		else 
			rollback_sql_id=rollbackSqlArr.indexOf(ct.delete_rollback_sql);
		
		if (rollback_sql_id==-1) {
			
			if (rollback_type.equals(ROLLBACK_ACTION_UPDATE)) {
				rollbackSqlArr.add(ct.update_sql);
				rollback_sql_id=rollbackSqlArr.indexOf(ct.update_sql);
				
				rollbackFieldTypeIdArr.add(new Integer[]{0});
				rollbackFieldTypeNameArr.add(new String[]{""});
				
				Integer[] fieldTypeIdArrBase=new Integer[ct.fields.size()];
				String[] fieldTypeNameArrBase=new String[ct.fields.size()];
				
				int ind=-1;
				
				for (int f=0;f<ct.fields.size();f++) {
					if (ct.thisTablePKEYfieldORDERS.indexOf(f)>-1) continue;
					ind++;
					fieldTypeIdArrBase[ind]=fieldTypeArr.get(f);
					fieldTypeNameArrBase[ind]=ct.fields.get(f)[3]; //binding type
				}
				
				for (int p=0;p<ct.thisTablePKEYfieldORDERS.size();p++) {
					int field_id=ct.thisTablePKEYfieldORDERS.get(p);
					ind++;
					fieldTypeIdArrBase[ind]=fieldTypeArr.get(field_id);
					fieldTypeNameArrBase[ind]=ct.fields.get(field_id)[3]; //binding type
				}
				
				
				rollbackFieldTypeIdArr.set(rollback_sql_id, fieldTypeIdArrBase);
				rollbackFieldTypeNameArr.set(rollback_sql_id, fieldTypeNameArrBase);
			}
			
			if (rollback_type.equals(ROLLBACK_ACTION_DELETE)) {
				rollbackSqlArr.add(ct.delete_rollback_sql);
				rollback_sql_id=rollbackSqlArr.indexOf(ct.delete_rollback_sql);
				
				
				rollbackFieldTypeIdArr.add(new Integer[]{0});
				rollbackFieldTypeNameArr.add(new String[]{""});
				
				Integer[] fieldTypeIdArrBase=new Integer[ct.thisTablePKEYfieldORDERS.size()];
				String[] fieldTypeNameArrBase=new String[ct.thisTablePKEYfieldORDERS.size()];
				
				int ind=-1;
				
				for (int p=0;p<ct.thisTablePKEYfieldORDERS.size();p++) {
					int field_id=ct.thisTablePKEYfieldORDERS.get(p);
					ind++;
					fieldTypeIdArrBase[ind]=fieldTypeArr.get(field_id);
					fieldTypeNameArrBase[ind]=ct.fields.get(field_id)[3]; //binding type
				}
				
				
				rollbackFieldTypeIdArr.set(rollback_sql_id, fieldTypeIdArrBase);
				rollbackFieldTypeNameArr.set(rollback_sql_id, fieldTypeNameArrBase);
			}
				
			
		} //if (rollback_sql_id==-1)
		
		return rollback_sql_id;
	}
	
	
	//***********************************************************************
	int TEST_CONNECTION_INTERVAL=60*1000;
	long next_test_connection_ts=0;
	
	ThreadGroup testConnThreadGroup=new ThreadGroup("TEST_CONN_GRP");

	//***********************************************************************
	void testDBConnections() {
		if (System.currentTimeMillis()< next_test_connection_ts) return;
		
		next_test_connection_ts=System.currentTimeMillis()+TEST_CONNECTION_INTERVAL;
		
		int active_thread_count=testConnThreadGroup.activeCount();
		
		if (active_thread_count>0) return;
		
		String thread_name="TEST_CONN_"+System.currentTimeMillis();
		
		try {
			Thread thread=new Thread(testConnThreadGroup, new testConnectionThread(this),thread_name);
			thread.start();
		} catch(Exception e) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "testConnectionThread not initiated : "+ e.getMessage());
			e.printStackTrace();
		}
		
		
	}
	
	//**************************************************************************
	
	int CHECK_CANCELLATION_INTERVAL=5*1000;
	long next_check_cancellation_ts=0;
	
	ThreadGroup cancelCheckThreadGroup=new ThreadGroup("TEST_CONN_GRP");
	

	
	
	//**************************************************************************
	
	void checkCancellations(ConfDBOper db) {
		
		
		if (System.currentTimeMillis()< next_check_cancellation_ts) return;
		
		
		
		next_check_cancellation_ts=System.currentTimeMillis()+CHECK_CANCELLATION_INTERVAL;
		
		int active_thread_count=cancelCheckThreadGroup.activeCount();
		
		if (active_thread_count>0) return;
		
		
		String thread_name="CANCEL_CHECK_THREAD_"+System.currentTimeMillis();
		
		try {
			Thread thread=new Thread(cancelCheckThreadGroup, new checkCancelForCopyingThread(db, this, work_package_id),thread_name);
			thread.start();
		} catch(Exception e) {
			cLib.mylog(cLib.LOG_LEVEL_DANGER, "checkCancelForCopyingThread not initiated : "+ e.getMessage());
			e.printStackTrace();
		}
		
	}
	
	
	//*****************************************************************************
	void waitCancelCheckAndTestConnTheadsFinished() {
		
		long TIMEOUT=5000;
		long start_ts=System.currentTimeMillis();
		
		
		int active_thread_count=cancelCheckThreadGroup.activeCount()+testConnThreadGroup.activeCount();
		
		if (active_thread_count>0)
			while(true) {
				System.out.println("waitTheadsFinished...");
				try{Thread.sleep(1000);} catch(Exception e) {}
				active_thread_count=cancelCheckThreadGroup.activeCount()+testConnThreadGroup.activeCount();
				if (active_thread_count==0) break;
				if (System.currentTimeMillis()>=start_ts+TIMEOUT) break;
			}
	}
	
	
	
	
	//*****************************************************************************
	
	long thread_start_heartbeat=0;
	
	
	void waitRootCopyTheadsFinished(ConfDBOper db) {

		int active_thread_count=rootCopyThreadGroup.activeCount();

		long TIMEOUT=1*10*1000;
		
		if (active_thread_count>0)
			while(true) {
				//System.out.println("waiting root copies Finished..."+active_thread_count+" thread still active.");
				//rootCopyThreadGroup.list();
				try{Thread.sleep(10);} catch(Exception e) {}
				active_thread_count=rootCopyThreadGroup.activeCount();
				if (active_thread_count==0) break;
				checkCancellations(db);
				if (error_flag) break;
				db.heartbeat(db.TABLE_TDM_MASTER, 0, db.master_id);
				
				if (System.currentTimeMillis()>thread_start_heartbeat+TIMEOUT) break;

			}
		
		
	}
	
	
	//------------------------------------------------------------------------
	ArrayList<String[]> dbPropArr=new ArrayList<String[]>();
	
	synchronized int getDBArrInstance(ConfDBOper db, String direction, String db_id) {
		int instance_id=-1;
		
		
		
		for (int i=0;i<dbPropArr.size();i++) {
			String[] arr=dbPropArr.get(i);
			
			String arr_direction=arr[0];
			int arr_db_id=Integer.parseInt(arr[1]);
			//String arr_db_type=arr[2];
			String arr_lease_status=arr[3];
			
			if (
						Integer.parseInt(db_id)==arr_db_id && 
						(direction.equals("ANY") || direction.equals(arr_direction) )  &&  
						arr_lease_status.equals("FREE")
						) {
				instance_id=i;
				break;
			}
		}
		
		String[] arr=null;
		
		if (instance_id==-1) {
			
			connArr.add(cLib.getApplicationDbConnectionByDBId(db.connConf, Integer.parseInt(db_id)));
			String db_type=cLib.getDbTypeByEnvId(db.connConf, Integer.parseInt(db_id));
			
			arr=new String[] {direction, db_id, db_type, "FREE"};
			dbPropArr.add(arr);
			instance_id=dbPropArr.size()-1;
			
			//bunun true olmasi lazim cunku bu sekilde 
			//multithreadde iken diger connection un insert ettiklerini gormez
			try{connArr.get(instance_id).setAutoCommit(true);} catch(Exception e) {}
			
		} 
		
		arr=dbPropArr.get(instance_id);
		
		arr[3]="LEASED";
		
		dbPropArr.set(instance_id, arr);
		
		
		return instance_id;
	}
	
	//------------------------------------------------------------------------
	synchronized String getDbInstanceDbType(int db_instance_id) {
		try {

			return dbPropArr.get(db_instance_id)[2];
			
		} catch(Exception e) {
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			return "";
		}
	}
	
	//------------------------------------------------------------------------
	synchronized String getDbInstanceStatus(int db_instance_id) {
		try {

			return dbPropArr.get(db_instance_id)[3];
			
		} catch(Exception e) {
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			return "";
		}
	}
	//------------------------------------------------------------------------
	synchronized void releaseDbInstance(int db_instance_id) {
		
		try {
			String[] arr=dbPropArr.get(db_instance_id);
			arr[3]="FREE";
			dbPropArr.set(db_instance_id, arr);
			
		} catch(Exception e) {
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			
		}
		
		
	}
}
