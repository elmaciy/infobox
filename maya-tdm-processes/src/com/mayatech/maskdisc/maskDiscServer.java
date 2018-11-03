package com.mayatech.maskdisc;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

import com.mayatech.baseLibs.genLib;
import com.mayatech.datapool.poolLib;

public class maskDiscServer {
	
	boolean is_debug=false;

	
	Connection connConf=null;
	Connection connConfCancel=null;
	
	Connection connTarget=null;
	
	int discovery_id=0;
	int paralellism_count=10;
	
	int sample_size=1000;
	String sector_id="0";
	
	String fields_to_skip="";
	String schemas_to_skip="";
	
	String conf_driver="";
	String conf_connstr="";
	String conf_username="";
	String conf_password="";

	ArrayList<String[]> rulesArr=new ArrayList<String[]>();
	

	String app_db_driver="";
	String app_db_connstr="";
	String app_db_username="";
	String app_db_password="";
	
	boolean is_server_cancelled=false;
	boolean is_discovery_finished=false;
	
	
	ArrayList<String[]> tableArr=new ArrayList<String[]>();
	ArrayList<Integer> tableStatusArr=new ArrayList<Integer>();
	ArrayList<ArrayList<String[]>> tableResultArr=new ArrayList<ArrayList<String[]>>();
	ArrayList<Long> tableAssignmentTSArr=new ArrayList<Long>();


	static final int STATE_NEW=0;
	static final int STATE_ASSIGNED=1;
	static final int STATE_DISCOVERING=2;
	static final int STATE_DONE=3;
	static final int STATE_PERSISTED=4;
	
	
	
	static final int FIELD_RULE_ID=0;
	static final int FIELD_RULE_DESCRIPTION=1;
	static final int FIELD_RULE_TARGET_ID=2;
	static final int FIELD_RULE_TYPE=3;
	static final int FIELD_RULE_REGEX=4;
	static final int FIELD_RULE_SCRIPT=5;
	static final int FIELD_RULE_FIELD_NAMES=6;
	
	
	

	static final int RES_MASK_FIELD_FIELD_NAME=0;
	static final int RES_MASK_FIELD_FIELD_TYPE=1;
	static final int RES_MASK_FIELD_TARGET_ID=2;
	static final int RES_MASK_FIELD_RULE_ID=3;
	static final int RES_MASK_FIELD_MATCH_COUNT=4;
	static final int RES_MASK_FIELD_SAMPLE_COUNT=5;
	
	static final int RES_COPY_FIELD_TAB_CATALOG=0;
	static final int RES_COPY_FIELD_TAB_OWNER=1;
	static final int RES_COPY_FIELD_TAB_NAME=2;
	static final int RES_COPY_FIELD_PARENT_TAB_CATALOG=3;
	static final int RES_COPY_FIELD_PARENT_TAB_OWNER=4;
	static final int RES_COPY_FIELD_PARENT_TAB_NAME=5;
	static final int RES_COPY_FIELD_CHILD_REL_FIELDS=6;
	static final int RES_COPY_FIELD_PARENT_PK_FIELDS=7;
	static final int RES_COPY_FIELD_MATCH_COUNT=8;
	static final int RES_COPY_FIELD_SAMPLE_COUNT=9;
	
	
	ArrayList<String> skipOwnerList=new ArrayList<String>();
	ArrayList<String> skipFieldList=new ArrayList<String>();
	
	ConcurrentHashMap<String, ArrayList<String[]>> pkList=new ConcurrentHashMap<String, ArrayList<String[]>>();
	ConcurrentHashMap<String, Boolean> hmIsEmptyTable=new ConcurrentHashMap<String, Boolean>();
	ConcurrentHashMap<String, String> hm=new ConcurrentHashMap<String, String>();
	
	ConcurrentHashMap<String, ArrayList<String[]>> hmDataCache=new ConcurrentHashMap<String, ArrayList<String[]>>();

	//-------------------------------------------------
	void mydebug(String logstr) {
		if (!is_debug) return;
		System.out.println(logstr.replace("\u0007", ""));
	}
	
	//-------------------------------------------------
	synchronized void mylog(String logstr) {
		System.out.println(logstr.replace("\u0007", ""));
	}
	
	//-------------------------------------------------

	void initNewMaskDiscoveryServer(
			int discovery_id,
			String conf_driver, 
			String conf_connstr, 
			String conf_username, 
			String conf_password
			) {
		
		this.discovery_id=discovery_id;
		
		this.conf_driver=conf_driver;
		this.conf_connstr=conf_connstr;
		this.conf_username=conf_username;
		this.conf_password=conf_password;
		
		
		mylog("Initializing discovery server...");
		
		connConf=mDiscLib.getDBConnection(conf_connstr, conf_driver, conf_username, conf_password, 1);
		connConfCancel=mDiscLib.getDBConnection(conf_connstr, conf_driver, conf_username, conf_password, 1);
		
		if (connConf!=null) {
			int thread_count=10;
			try {
				thread_count=Integer.parseInt(mDiscLib.getParamByName(connConf, "DISCOVERY_THREAD_COUNT"));
			} catch(Exception e) {
				
			}
			this.paralellism_count=thread_count;
		}
		
		
		
		
	}
	

	
	
	//-------------------------------------------------
	
	int app_id=0;
	int env_id=0;
	String discovery_title="";
	String schema_name="";
	String discovery_type="";

	boolean loadParameters() {
		mylog("Loading parameters .... ");
		
		String sql="select app_id, env_id, schema_name, discovery_title, sample_count, sector_id, discovery_type from tdm_discovery where id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+discovery_id});
		
		ArrayList<String[]> arr=mDiscLib.getDbArray(connConf, sql, 1, bindlist, 0);
		
		if (arr==null || arr.size()==0) {
			mylog("Discovery not found. Id : "+discovery_id);
			return false;
		}
		
		sample_size=1000;
		
		try {
			app_id=Integer.parseInt(arr.get(0)[0]);
			env_id=Integer.parseInt(arr.get(0)[1]);
			schema_name=arr.get(0)[2];
			discovery_title=arr.get(0)[3];	
			sample_size=Integer.parseInt(arr.get(0)[4]);
			sector_id=arr.get(0)[5];
			discovery_type=arr.get(0)[6];	
		} catch(Exception e) {
			e.printStackTrace();
			mylog("Discovery configuration error. Id : "+discovery_id);
			return false;
		}
		
		mylog("discovery_type         : "+discovery_type);
		mylog("app_id                 : "+app_id);
		mylog("env_id                 : "+env_id);
		mylog("schema_name            : "+schema_name);
		mylog("discovery_title        : "+discovery_title);
		mylog("sample_size            : "+sample_size);
		mylog("sector_id              : "+sector_id);
		
		
		
		
		
		
		fields_to_skip="";
		
		sql="select param_value from tdm_parameters where param_name='DISCOVERY_FIELDS_TO_SKIP'";
		bindlist.clear();
		arr=mDiscLib.getDbArray(connConf, sql, 1, bindlist, 0);
		try {fields_to_skip=arr.get(0)[0];} catch(Exception e) {fields_to_skip="";}
		mylog("fields_to_skip          : "+fields_to_skip);
		
		skipFieldList.clear();
		String[] arsFields=fields_to_skip.split("\n|\r");
		for (int i=0;i<arsFields.length;i++) {
			if (arsFields[i].trim().length()==0) continue;
			skipFieldList.add(arsFields[i].trim().toLowerCase());
		}

		
		schemas_to_skip="";
		
		sql="select param_value from tdm_parameters where param_name='DISCOVERY_SCHEMAS_TO_SKIP'";
		bindlist.clear();
		arr=mDiscLib.getDbArray(connConf, sql, 1, bindlist, 0);
		try {schemas_to_skip=arr.get(0)[0];} catch(Exception e) {schemas_to_skip="";}
		mylog("schemas_to_skip         : "+schemas_to_skip);
		
		skipOwnerList.clear();
		String[] arsSchema=schemas_to_skip.split("\n|\r");
		for (int i=0;i<arsSchema.length;i++) {
			if (arsSchema[i].trim().length()==0) continue;
			skipOwnerList.add(arsSchema[i].trim().toLowerCase());
		}

		
		if (discovery_type.equals("MASK")) {
			
			bindlist.clear();
			
			sql="select \n "+
					"	id, description, discovery_target_id, rule_type, regex, script, field_names \n "+
					"	from tdm_discovery_rule r  \n "+
					"	where is_valid='YES' \n ";
			
			if (!sector_id.equals("0") && sector_id.length()>0) {
				sql=sql+" and exists (select 1 from tdm_discovery_sector_rule where discovery_sector_id=? and discovery_rule_id=r.id)  ";
				bindlist.add(new String[]{"INTEGER",sector_id});
			}
					
			sql=sql+"  order by 1";
				
				arr=mDiscLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
				
				rulesArr.clear();
				mylog("Rules found : "+ arr.size());
				for (int i=0;i<arr.size();i++) {
					String[] arule=arr.get(i);
					String rule_name=arule[FIELD_RULE_DESCRIPTION];
					mylog(rule_name);
					
					rulesArr.add(arule);
				}
		}
		
		
		
		mylog("Loading parameters . OK ");
		
		return true;
		
		
	}
	
	//--------------------------------------------------
	ThreadGroup CheckCancelTreadGrp = new ThreadGroup("Check Cancel Listener Thread Group");
	
	void startCheckCancelThread() {
		mylog("startCheckCancelThread...");
		
		String thread_name="CHECK_CANCEL_THREAD";
		try {
			Thread thread=new Thread(CheckCancelTreadGrp, 
					new maskDiscCheckCancelThread(this, discovery_id),thread_name);
			thread.start();
		} catch(Exception e) {
			e.printStackTrace();
		}
		
	}
	
	//-----------------------------------------------------------------------------
	void checkCancel() {
		
		if (is_server_cancelled) return;
		
		String sql="select cancel_flag, status from tdm_discovery \n" + 
					"	where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+discovery_id});
		
		ArrayList<String[]> arr=poolLib.getDbArray(connConfCancel, sql, Integer.MAX_VALUE, bindlist, 0);
		
		if (arr==null || arr.size()==0) {
			mylog("Discovery deleted...");
			is_server_cancelled=true;
			return;
		}
		
		String cancel_flag=arr.get(0)[0];
		String status=arr.get(0)[1];
		
		if (cancel_flag.equals("YES") || status.equals("INACTIVE")) {
			mylog("Discovery cancelled...");
			is_server_cancelled=true;
		}
			

		
		
	}
	
	
	
	//----------------------------------------------------------------------------
	
	
	Connection getAppConn() {
		String sql="select db_driver, db_connstr, db_username, db_password from tdm_envs where id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+env_id});
		
		ArrayList<String[]> arr=mDiscLib.getDbArray(connConf, sql, 1, bindlist, 0);
		
		if (arr==null || arr.size()==0) {
			mylog("Target connection info not found.... ");
			return null;
		}
		
		
		
		app_db_driver=arr.get(0)[0];
		app_db_connstr=arr.get(0)[1];
		app_db_username=arr.get(0)[2];
		app_db_password=genLib.passwordDecoder(arr.get(0)[3]) ;
		
		

		return mDiscLib.getDBConnection(app_db_connstr, app_db_driver, app_db_username, app_db_password, 1);
		
		
	}
	
	//----------------------------------------------------------------------------
	String start_ch="\"";
	String end_ch="\"";
	String middle_ch=".";
	
	//**********************************************
	void setConnCharacters(Connection conn) {

	if(conn!=null) 
		try {
			start_ch=conn.getMetaData().getIdentifierQuoteString();
			end_ch=start_ch;
			middle_ch=genLib.nvl(conn.getMetaData().getCatalogSeparator(),".");
			
		} catch(Exception e) {
			start_ch="";
			end_ch="";
			middle_ch=".";
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
	//----------------------------------------------------------------------------
	boolean startDiscovery() {
		mylog("Discovery started.");
		
		setRunning();

		connTarget=getAppConn();
		
		if (connTarget==null) {
			mylog("Target connection is not valid .... ");
			return false;
		}
		
		setConnCharacters(connTarget);
		
		
		
		
		
		
		extractTableArray();
		
		startThreads();
		
		try{Thread.sleep(1000);} catch(Exception e) {}
		
		while(true) {
			if (is_server_cancelled) {
				mylog("Cancelled .... ");
				return false;
			}
			
			is_discovery_finished=isAllFinished();
			
			if (is_discovery_finished) break;
			
			mylog("is_discovery_finished="+is_discovery_finished+" active threads : "+procesTreadGrp.activeCount());
			
			if (!is_discovery_finished) listBusyTables();
			
			
			persistDiscoveryResults();
			
			
			try {Thread.sleep(1000);} catch(Exception e) {}
		}
		
		persistDiscoveryResults();
		
		mylog("Discovery finished . OK ");
		return true;
	}
	//----------------------------------------------------------------------------
	void listBusyTables() {
		
		try {
			for (int i=0;i<tableArr.size();i++) {
				if (tableArr.get(i)==null) continue;
				if (tableStatusArr.get(i)==STATE_ASSIGNED || tableStatusArr.get(i)==STATE_DISCOVERING) {
					System.out.print("UNFINISHED TABLE : ");
					for (int c=0;c<tableArr.get(i).length;c++) {
						System.out.print(tableArr.get(i)[c]+"\t");
					}
					System.out.println();
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		
	}
	//----------------------------------------------------------------------------
	boolean isOracle() {
		String str=app_db_connstr.toLowerCase();
		if (str.contains("oracle")) return true;
		return false;
	}
	//----------------------------------------------------------------------------
	boolean isMssql() {
		String str=app_db_connstr.toLowerCase();
		if (str.contains("sqlserver")) return true;
		return false;
	}
	//----------------------------------------------------------------------------
	boolean isSybase() {
		String str=app_db_connstr.toLowerCase();
		if (str.contains("sybase")) return true;
		return false;
	}
	//----------------------------------------------------------------------------
	boolean isMysql() {
		String str=app_db_connstr.toLowerCase();
		if (str.contains("mysql")) return true;
		return false;
	}
	//----------------------------------------------------------------------------
	boolean isDb2() {
		String str=app_db_connstr.toLowerCase();
		if (str.contains("db2")) return true;
		return false;
	}
	//-------------------------------------------------------------------------------------
	ArrayList<String> getCatalogList(Connection conn) {
		
		ArrayList<String> catalogArr=new ArrayList<String>();
		ResultSet rs = null;
		DatabaseMetaData md=null;
		try {
			md = conn.getMetaData();
			ResultSet rsCat=md.getCatalogs();
			while(rsCat.next()) {
				String catalog_name=rsCat.getString("TABLE_CAT");
				catalogArr.add(catalog_name);
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		finally {try {rs.close();} catch(Exception e) {}}
		
		if (catalogArr.size()==0) catalogArr.add("${default}");
		return catalogArr;
	}
	
	//----------------------------------------------------------------------------
	void setCatalog(Connection conn, String catalog_name) {
		mylog("setCatalog : "+catalog_name);
		
		if (catalog_name.length()>0 && !catalog_name.equals("${default}")) {
			try {
				String current_catalog=conn.getCatalog();
				if (!current_catalog.equals(catalog_name)) {
					conn.setCatalog(catalog_name);
					mylog("catalog changing to : "+catalog_name);
				}
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	//----------------------------------------------------------------------------
	void extractTableArray() {
		ArrayList<String> catalogArr=getCatalogList(connTarget);
		
		if (catalogArr.size()==0)
			catalogArr.add("${default}");
		
		for(int i=0;i<catalogArr.size();i++) {
			String catalog_name=catalogArr.get(i);
			extractTableArrayByCatalog(catalog_name);
		}
		
	}
	

	
	//-------------------------------------------------------------------------------------
	//String TABLE_SQL_ORACLE="select '${default}' table_catalog, owner, table_name from all_tables where status='VALID' ";
	//String TABLE_SQL_ORACLE=" select * from (select '${default}' table_catalog, owner table_schema, object_name table_name from all_objects where object_type in ('TABLE','VIEW','MATERIALIZED VIEW') and status='VALID') ";
	String TABLE_SQL_ORACLE=" select * from (select '${default}' table_catalog, owner table_schema, object_name table_name from all_objects where object_type in ('TABLE','MATERIALIZED VIEW') and status='VALID') ";
	String TABLE_SQL_MSSQL="SELECT table_catalog, table_schema, table_name FROM INFORMATION_SCHEMA.TABLES  ";
	String TABLE_SQL_MYSQL="select table_schema, table_schema, table_name from information_schema.tables  ";
	String TABLE_SQL_SYBASE="";

	void extractTableArrayByCatalog(String catalog_name) {
		
		String base_sql=TABLE_SQL_ORACLE;
		if (isMssql()) base_sql=TABLE_SQL_MSSQL;
		else if (isMysql()) base_sql=TABLE_SQL_MYSQL;
		else if (isSybase()) base_sql="select db_name() table_catalog, u.name table_schema, obj.name table_name "+
				" from "+catalog_name+".dbo.sysobjects as obj,  "+catalog_name+".dbo.sysusers as u "+
				" where obj.type in ('U','V') and obj.uid=u.uid ";
		
		mylog("TABLE_BASE_SQL : "+base_sql);
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		try {
			String[] tabArr=schema_name.split("\\|::\\|"); 
			
			for (int i=0;i<tabArr.length;i++) {
				String catalog_schema_list=tabArr[i];
				if (catalog_schema_list.trim().length()==0) catalog_schema_list="";
				if (catalog_schema_list.trim().equals("All")) catalog_schema_list="";
				
				String tab_sql=base_sql;
				bindlist.clear();
				
				
 				
				if (catalog_schema_list.length()>0) {
					if(isOracle())
						tab_sql=tab_sql+" WHERE table_catalog=? AND table_schema=? ";
					else if (isMssql())
						tab_sql=tab_sql+" WHERE table_catalog=? AND table_schema=? ";
					else if (isMysql())
						tab_sql=tab_sql+" WHERE table_schema=? AND table_schema=? ";
					else if (isSybase())
						tab_sql="select db_name() table_catalog, u.name table_schema, obj.name table_name "+
								" from "+catalog_name+".dbo.sysobjects as obj,  "+catalog_name+".dbo.sysusers as u "+
								" where obj.type in ('U','V') and obj.uid=u.uid "+
								" and db_name()=? AND u.name=? ";
					else 
						tab_sql=tab_sql+" WHERE table_catalog=? AND table_schema=? ";
					
					String catalog_filter=catalog_schema_list;
					String owner_filter=catalog_schema_list;
					
					if (catalog_schema_list.indexOf(".")>-1) {
						catalog_filter=catalog_schema_list.split("\\.")[0];
						owner_filter=catalog_schema_list.split("\\.")[1];
					}
					
					
					bindlist.add(new String[]{"STRING",catalog_filter});
					bindlist.add(new String[]{"STRING",owner_filter});
				}
				
				mylog("TABLE_FINAL_SQL      : "+tab_sql);
				mylog("TABLE_FINAL_BINDINGS : ");
				for (int b=0;b<bindlist.size();b++) {
					mylog("\t"+bindlist.get(b)[1]);
				}
				
				setCatalog(connTarget, catalog_name);

				ArrayList<String[]> arr=mDiscLib.getDbArray(connTarget, tab_sql, Integer.MAX_VALUE, bindlist, 0);
				
				mylog("table(s) found : "+arr.size());
				
				
				for (int t=0;t<arr.size();t++) {
					String a_tab_catalog=arr.get(t)[0];
					String a_tab_owner=arr.get(t)[1];
					String a_tab_name=arr.get(t)[2];
					
					
					if (a_tab_owner.length()>0 && skipOwnerList.indexOf(a_tab_owner.toLowerCase())>-1) continue;
					
					mylog("Adding : "+a_tab_catalog+"."+a_tab_owner+"."+a_tab_name);
					
					tableStatusArr.add(STATE_NEW);
					tableArr.add(new String[]{a_tab_catalog, a_tab_owner,a_tab_name});
					tableResultArr.add(null);
					tableAssignmentTSArr.add(Long.MAX_VALUE);
				}
				
			}
					
		} catch(Exception e) {
			e.printStackTrace();
		}
		
	}
	
	//----------------------------------------------------------------------------
	int all_done_count=0;
	
	void persistDiscoveryResults() {
		
	if (discovery_type.equals("MASK")) 
		persistMaskDiscoveryResults();
	else 
		persistCopyDiscoveryResults();
		
		
	}
	
	//---------------------------------------------------------------------------
	void persistMaskDiscoveryResults() {
		int done_count=0;
		
		String sql="insert into tdm_discovery_result "+
				" (discovery_id, catalog_name, schema_name, table_name, field_name, field_type, discovery_target_id, discovery_rule_id, match_count, sample_count) "+
				" values "+
				" (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ";
		
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		 
		for (int i=0;i<tableStatusArr.size();i++) {
			if (tableStatusArr.get(i)!=STATE_DONE && tableStatusArr.get(i)!=STATE_PERSISTED ) continue;
			
			if (tableStatusArr.get(i)==STATE_DONE && tableResultArr.get(i)!=null) {
				
				
				ArrayList<String[]> resArr=tableResultArr.get(i);
				
				String table_catalog=tableArr.get(i)[0];
				String table_owner=tableArr.get(i)[1];
				String table_name=tableArr.get(i)[2];

				if (resArr!=null) 
					for (int r=0;r<resArr.size();r++) {
						String field_name=resArr.get(r)[RES_MASK_FIELD_FIELD_NAME];
						String field_type=resArr.get(r)[RES_MASK_FIELD_FIELD_TYPE];
						String target_id=resArr.get(r)[RES_MASK_FIELD_TARGET_ID];
						String rule_id=resArr.get(r)[RES_MASK_FIELD_RULE_ID];
						String match_count=resArr.get(r)[RES_MASK_FIELD_MATCH_COUNT];
						String sample_count=resArr.get(r)[RES_MASK_FIELD_SAMPLE_COUNT];
						
						
						bindlist.clear();
						bindlist.add(new String[]{"INTEGER",""+discovery_id});
						bindlist.add(new String[]{"STRING",table_catalog});
						bindlist.add(new String[]{"STRING",table_owner});
						bindlist.add(new String[]{"STRING",table_name});
						bindlist.add(new String[]{"STRING",field_name});
						bindlist.add(new String[]{"STRING",field_type});
						bindlist.add(new String[]{"INTEGER",target_id});
						bindlist.add(new String[]{"INTEGER",rule_id});
						bindlist.add(new String[]{"INTEGER",match_count});
						bindlist.add(new String[]{"INTEGER",sample_count});
						
						mDiscLib.execSingleUpdateSQL(connConf, sql, bindlist);
						
					}
				
				
			} //if (tableStatusArr.get(i)==STATE_DONE
			
			
			tableStatusArr.set(i, STATE_PERSISTED);
			//tableResultArr.set(i, null);
			//tableArr.set(i, null);
			
			done_count++;
			
		}
		
		all_done_count=done_count;
		int all_count=tableStatusArr.size();
		
		if (all_done_count>all_count) all_done_count=all_count;
		
		int progress_rate=0;
		
		try {progress_rate=(all_done_count*100)/all_count;} catch(Exception e) {}
		if (progress_rate>100) progress_rate=100;
		
		
		String progress_msg=""+all_done_count+" of " + all_count+" completed";
		
		sql="update tdm_discovery set progress=?, progress_desc=?, heartbeat=now() where id=?";


		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+progress_rate});
		bindlist.add(new String[]{"STRING",""+progress_msg});
		bindlist.add(new String[]{"INTEGER",""+discovery_id});
		
		mDiscLib.execSingleUpdateSQL(connConf, sql, bindlist);
	}
	
	//---------------------------------------------------------------------------
	void persistCopyDiscoveryResults() {
		int done_count=0;
		
		String sql="insert into tdm_discovery_rel "+
				" (discovery_id, tab_cat,  tab_owner, tab_name, parent_tab_cat, parent_tab_owner, parent_tab_name, child_rel_fields, parent_pk_fields, matched_count, sample_count) "+
				" values "+
				" (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ";
		
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		for (int i=0;i<tableStatusArr.size();i++) {
			if (tableStatusArr.get(i)!=STATE_DONE) continue;
			
			ArrayList<String[]> resArr=tableResultArr.get(i);
			
			String table_owner=tableArr.get(i)[0];
			String table_name=tableArr.get(i)[1];

			if (resArr!=null)
			for (int r=0;r<resArr.size();r++) {
				String tab_catalog=resArr.get(r)[RES_COPY_FIELD_TAB_CATALOG];
				String tab_owner=resArr.get(r)[RES_COPY_FIELD_TAB_OWNER];
				String tab_name=resArr.get(r)[RES_COPY_FIELD_TAB_NAME];
				String parent_tab_catalog=resArr.get(r)[RES_COPY_FIELD_PARENT_TAB_CATALOG];
				String parent_tab_owner=resArr.get(r)[RES_COPY_FIELD_PARENT_TAB_OWNER];
				String parent_tab_name=resArr.get(r)[RES_COPY_FIELD_PARENT_TAB_NAME];
				String child_rel_fields=resArr.get(r)[RES_COPY_FIELD_CHILD_REL_FIELDS];
				String parent_pk_fields=resArr.get(r)[RES_COPY_FIELD_PARENT_PK_FIELDS];
				String match_count=resArr.get(r)[RES_COPY_FIELD_MATCH_COUNT];
				String sample_count=resArr.get(r)[RES_COPY_FIELD_SAMPLE_COUNT];
				
				
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+discovery_id});
				bindlist.add(new String[]{"STRING",tab_catalog});
				bindlist.add(new String[]{"STRING",tab_owner});
				bindlist.add(new String[]{"STRING",tab_name});
				bindlist.add(new String[]{"STRING",parent_tab_catalog});
				bindlist.add(new String[]{"STRING",parent_tab_owner});
				bindlist.add(new String[]{"STRING",parent_tab_name});
				bindlist.add(new String[]{"STRING",child_rel_fields});
				bindlist.add(new String[]{"STRING",parent_pk_fields});
				bindlist.add(new String[]{"INTEGER",match_count});
				bindlist.add(new String[]{"INTEGER",sample_count});
				
				mDiscLib.execSingleUpdateSQL(connConf, sql, bindlist);
				
			}
			
			tableStatusArr.set(i, STATE_PERSISTED);
			tableResultArr.set(i, null);
			
			done_count++;
			
		}
		
		all_done_count+=done_count;
		int all_count=tableStatusArr.size();
		
		if (all_done_count>all_count) all_done_count=all_count;
		
		int progress_rate=0;
		
		try {progress_rate=(all_done_count*100)/all_count;} catch(Exception e) {}
		if (progress_rate>100) progress_rate=100;
		
		
		String progress_msg=""+all_done_count+" of " + all_count+" completed";
		
		sql="update tdm_discovery set progress=?, progress_desc=?, heartbeat=now() where id=?";


		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+progress_rate});
		bindlist.add(new String[]{"STRING",""+progress_msg});
		bindlist.add(new String[]{"INTEGER",""+discovery_id});
		
		mDiscLib.execSingleUpdateSQL(connConf, sql, bindlist);
	}
	//----------------------------------------------------------------------------
	 
	static final long timeoutforassignment=120000;
	
	boolean isAllFinished() {
		
		
		boolean ret1=true;
				
		long nowts=System.currentTimeMillis();
		for (int i=0;i<tableStatusArr.size();i++) {
			
			//if (tableArr.get(i)!=null)
			//	mylog("isAllFinished["+i+"] : "+tableArr.get(i)[0]+"."+tableArr.get(i)[1]+"."+tableArr.get(i)[2]+ " : "+tableStatusArr.get(i));
			
			if ((tableStatusArr.get(i)==STATE_ASSIGNED || tableStatusArr.get(i)==STATE_DISCOVERING)  && (tableAssignmentTSArr.get(i)+timeoutforassignment)<nowts) {
				tableStatusArr.set(i, STATE_DONE);
			}
			
			if (tableStatusArr.get(i)!=STATE_PERSISTED  ) 
				//ret1=false;
				return false;
			//else 
			//	mylog("isAllFinished !STATE_PERSISTED: "+tableArr.get(i)[0]+"."+tableArr.get(i)[0]+"."+tableArr.get(i)[0]+" tableStatus : "+tableStatusArr.get(i));
			
		}
		
		//return ret1;
		return true;
	}
	
	//----------------------------------------------------------------------------
	void setRunning() {
		
		
		String sql="update tdm_discovery set status='RUNNING', cancel_flag=null, start_date=now() where id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+discovery_id});
		
		mDiscLib.execSingleUpdateSQL(connConf, sql, bindlist);
		
		
		if (discovery_type.equals("MASK")) {
			sql="delete from tdm_discovery_result where discovery_id=?";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+discovery_id});
			
			mDiscLib.execSingleUpdateSQL(connConf, sql, bindlist);
		}
		
		
		
		if (discovery_type.equals("COPY")) {
			sql="delete from tdm_discovery_rel where discovery_id=?";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+discovery_id});
			
			mDiscLib.execSingleUpdateSQL(connConf, sql, bindlist);
		}
		
	}
	
	//---------------------------------------------------------------------------
	void startThreads() {
		//startDiscoveryThread(0);
		mylog("Starting "+paralellism_count+" threads.");
		for (int i=0;i<paralellism_count;i++) startDiscoveryThread(i);
		
		
	}
	//--------------------------------------------------
	ThreadGroup procesTreadGrp = new ThreadGroup("Discovery Thread Group");
	
	void startDiscoveryThread(int thread_id) {
		mylog("startDiscoveryThread...");
		
		if (discovery_type.equals("MASK")) {
			String thread_name="MASK_DISCOVERY_THREAD_"+thread_id;
			try {
				Thread thread=new Thread(procesTreadGrp, 
						new maskDiscoveryThread(this,thread_id),thread_name);
				thread.start();
				//thread.run();
			} catch(Exception e) {
				e.printStackTrace();
			}
		} else {
			String thread_name="COPY_DISCOVERY_THREAD_"+thread_id;
			try {
				Thread thread=new Thread(procesTreadGrp, 
						new copyDiscoveryThread(this,thread_id),thread_name);
				thread.start();
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		
		
		try{Thread.sleep(1000);} catch(Exception e) {}
	}
	//----------------------------------------------------------------------------
	void finishDiscovery(boolean is_success) {
		String status="FINISHED";
		if (!is_success) status="UNFINISHED";
		
		String sql="update tdm_discovery set status=?, finish_date=now(), cancel_flag=null where id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.clear();
		bindlist.add(new String[]{"STRING",""+status});
		bindlist.add(new String[]{"INTEGER",""+discovery_id});
		
		mDiscLib.execSingleUpdateSQL(connConf, sql, bindlist);
	}
	
	//----------------------------------------------------------------------------
	void closeAll() {

		mylog("Closing...");

		try {connConf.close();} catch (Exception e) {}
		try {connConfCancel.close();} catch (Exception e) {}
		try {connTarget.close();} catch (Exception e) {}
	}
	
	//------------------------------------------------------------------------------
	synchronized int getNextTableId() {
		
		for (int i=0;i<tableStatusArr.size();i++) {
			if (tableStatusArr.get(i)==STATE_NEW) {
				tableStatusArr.set(i, STATE_ASSIGNED);
				tableAssignmentTSArr.set(i, System.currentTimeMillis());
				return i;
			}
		}
		
		return -1;
	}
	
	//---------------------------------------------------------------------------------------
	void addMaskDiscoveryResult(
			ArrayList<String[]> arr, 
			String col_name, 
			String col_type, 
			int rule_arr_id, 
			int match_count,
			int sample_count
			) {
		
		String discovery_target_id=rulesArr.get(rule_arr_id)[FIELD_RULE_TARGET_ID];
		String rule_id=rulesArr.get(rule_arr_id)[FIELD_RULE_ID];

		mylog("++++++++++ addMaskDiscoveryResult : "+col_name+" "+col_type+" "+rule_id+" "+match_count+"/"+sample_count);
		
		String[] tmp=new String[]
				{
				col_name,
				col_type,
				discovery_target_id,
				rule_id,
				""+match_count,
				""+sample_count
				};
		
		arr.add(tmp);
	}
	
	//---------------------------------------------------------------------------------------
	void addCopyDiscoveryResult(ArrayList<String[]> arr, 
			String tab_catalog,
			String tab_owner,
			String tab_name,
			String parent_tab_catalog,
			String parent_tab_owner,
			String parent_tab_name,
			String child_rel_fields,
			String parent_pk_fields,
			 int match_count, 
			 int sample_count
			) {
		

		//mylog("Matched  : "+col_name+ " with "+rule_name);
		
		String[] tmp=new String[]
				{
				tab_catalog,
				tab_owner,
				tab_name,
				parent_tab_catalog,
				parent_tab_owner,
				parent_tab_name,
				child_rel_fields,
				parent_pk_fields,
				""+match_count,
				""+sample_count
				};
		
		arr.add(tmp);
	}
	//------------------------------------------------------------------------------
	
	static final String RULE_TYPE_MATCHES="MATCHES";
	static final String RULE_TYPE_JS="JS";
	static final String RULE_TYPE_SQL="SQL";
	
	
	void performMaskDiscovery(
			Connection connApp, 
			int thread_id,  
			int tab_arr_id,
			ScriptEngineManager factory, 
			ScriptEngine engine
			) {
		
		tableStatusArr.set(tab_arr_id, STATE_DISCOVERING);
		
		String[] tab=tableArr.get(tab_arr_id);
		
		String table_catalog=tab[0];
		String table_owner=tab[1];
		String table_name=tab[2];
		
		setCatalog(connApp, table_catalog);
		
		ArrayList<String[]> resArr=new ArrayList<String[]>();

		String  BASE_SQL="";
		if (isOracle()) BASE_SQL="Select * from "+addStartEndForTable(table_owner+"."+table_name)+"";
		else if (isMysql()) BASE_SQL="Select * from "+addStartEndForTable(table_owner+"."+table_name) +" limit 0,"+sample_size;
		else if (isMssql()) BASE_SQL="Select top "+sample_size+" * from "+addStartEndForTable(table_owner+"."+table_name)+" WITH (NOLOCK) ";
		else if (isSybase()) BASE_SQL="Select top "+sample_size+" * from "+table_catalog+"."+addStartEndForTable(table_owner+"."+table_name)+" noholdlock ";
		else  BASE_SQL="Select * from "+addStartEndForTable(table_owner+"."+table_name)+"";
			
		
		ArrayList<String> colList=new ArrayList<String>();
		ArrayList<String> colTypeList=new ArrayList<String>();
		

		setCatalog(connApp, table_catalog);
		ArrayList<String[]> sampleData=mDiscLib.getDbArray(connApp, BASE_SQL, sample_size, null, 20, colList, colTypeList);
		
		
		int actual_data_size=sampleData.size();
		
		
		if (actual_data_size==0) {
			tableResultArr.set(tab_arr_id, resArr);
			tableStatusArr.set(tab_arr_id, STATE_DONE);
		}
		 
		int match_count=0;
		
		
		ArrayList<Pattern> pattern=new ArrayList<Pattern>();

		
		StringBuilder data=new StringBuilder();
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		 if (actual_data_size>0)
			for (int col=0;col<colList.size();col++) {
				
				if (is_server_cancelled) break;
				
				String col_name=colList.get(col);
				String col_type=colTypeList.get(col);
				
				String data_cache_key=table_owner+"."+table_name+"."+col_name;
				
				mylog("------------------------------------------------------------------------------------");
				mylog("Checking column["+col+"] name="+table_catalog+"."+table_owner+"."+table_name+"."+col_name+", type="+col_type);
				
				if (skipFieldList.indexOf(col_name.toLowerCase())>-1) continue;
				
				boolean is_matched=false;
				
				
				hmDataCache.clear();
				
				for (int r=0;r<rulesArr.size();r++) {
					if (is_server_cancelled) break;
					mylog("\nChecking Rule : "+rulesArr.get(r)[FIELD_RULE_DESCRIPTION]);
					String fields=rulesArr.get(r)[FIELD_RULE_FIELD_NAMES];
					
					String[] fieldsArr=fields.split("\n|\r");
					
					is_matched=false;
					
					for (int f=0;f<fieldsArr.length;f++) {
						if (col_name.trim().length()==0) continue;
						
						data.setLength(0);
						data.append(fieldsArr[f].trim().toLowerCase());
						
						if (data.length()==0) continue;
						
						if (data.indexOf("type=")==0) {
							String expected_col_type="";
							int ind=data.indexOf("=");
							try{expected_col_type=data.substring(ind+1).trim().toLowerCase();} catch(Exception e) {}
							
							if (expected_col_type.length()==0) continue;
							
							
									
							//mylog("Check if coltype ["+col_type.trim().toLowerCase()+"] contains "+expected_col_type);
							
							if (col_type.trim().toLowerCase().contains(expected_col_type)) {
								mylog("matched: coltype ["+col_type.trim().toLowerCase()+"] contains "+expected_col_type);
								is_matched=true;
								break;
							}
						}
						else {
							//mylog("Check if colname ["+col_name.trim().toLowerCase()+"] equals "+data.toString());
	
							if (col_name.trim().toLowerCase().equals(data.toString())) {
								mylog("matched : colname ["+col_name.trim().toLowerCase()+"] equals "+data.toString());
								is_matched=true;
								break;
							}
						}
						
						
						
					} //for (int f=0;f<fieldsArr.length;f++)
					
					if (is_matched) {
						
						addMaskDiscoveryResult(resArr, col_name, col_type, r, actual_data_size, actual_data_size);
						continue;
					}
					
					
					
					String sql=BASE_SQL.replace("*", addStartEndForColumn(col_name));
					
					if (isOracle()) sql=sql+" where "+addStartEndForColumn(col_name)+" is not null ";
					else if (isMysql()) sql="Select "+addStartEndForColumn(col_name)+" from "+addStartEndForTable(table_owner+"."+table_name) +" where "+addStartEndForColumn(col_name)+" is not null  limit 0,"+sample_size;
					else if (isMssql()) sql=sql+" where "+addStartEndForColumn(col_name)+" is not null   ";
					else if (isSybase()) sql=sql+" where "+addStartEndForColumn(col_name)+" is not null  ";
					
					
					
					tableAssignmentTSArr.set(tab_arr_id, System.currentTimeMillis());
					
					
					boolean is_get=hmDataCache.containsKey(data_cache_key);
					
					if (is_get) {
						if(sampleData!=null) sampleData.clear();
						sampleData.clear();
						sampleData=(ArrayList<String[]>) hmDataCache.get(data_cache_key) ;
						mylog(":)))))))))))))))))) Get From Cache."+data_cache_key);
					}
					else {
						if(sampleData!=null) sampleData.clear();
						sampleData=mDiscLib.getDbArray(connApp, sql, sample_size, null, 5, null, null);
						hmDataCache.put(data_cache_key, sampleData);
						mylog("!!!!!!!!!!!!!!!!!!!!  Get From Database.");
					}
						
					
					int col_sample_size=sampleData.size();
					
					//mylog("["+col_sample_size+"] recs found.");
					
					//tekrar tekrar bos kayit gelecek halde bakmasin
					if (col_sample_size==0) {
						hm.put(addStartEndForTable(table_owner+"."+table_name+"."+col_name), "EMPTY");
						continue;
					}
					
					
					tableAssignmentTSArr.set(tab_arr_id, System.currentTimeMillis());
					
					String rule_type=rulesArr.get(r)[FIELD_RULE_TYPE];
					
					String regex=rulesArr.get(r)[FIELD_RULE_REGEX];
					String script=rulesArr.get(r)[FIELD_RULE_SCRIPT];
					
					if (regex.trim().length()==0 && script.trim().length()==0) continue;
					
					pattern.clear();
					
					if (rule_type.equals(RULE_TYPE_MATCHES)) {
						
						if (regex.trim().length()==0) continue;
						
						String[] regexArr=regex.split("\n|\r");
						
						for (int t=0;t<regexArr.length;t++) {
							String a_regex=regexArr[t];
							if (a_regex.trim().length()==0) continue;
							
							try {
								Pattern tmppattern=Pattern.compile(a_regex,Pattern.CASE_INSENSITIVE);
								if (tmppattern==null) continue;
								pattern.add(tmppattern);
								} catch(Exception e) {
									pattern=null;
									mylog("Exception@Pattern.compile REGEX : " + regex);
									mylog("Exception@Pattern.compile ERROR : " + e.getMessage());
								}
						}
					}
					else if (rule_type.equals(RULE_TYPE_JS)){
						if (script.trim().length()==0) continue;
					} 
					else if (rule_type.equals(RULE_TYPE_SQL)) {
						if (regex.trim().length()==0) continue;
					}
					
									
					
					
					match_count=0;
					
					for (int s=0;s<col_sample_size;s++) {
						
						if (is_server_cancelled) break;
						
	
						
						data.setLength(0);
						data.append(sampleData.get(s)[0]);
						
	
						
						if (data.length()==0 || data.length()>1000) {
							col_sample_size--;
							continue;
							
						}
							
						
						
	
						
						if (rule_type.equals(RULE_TYPE_MATCHES)) {
							
							for (int p=0;p<pattern.size();p++) {
								
								try {
									//mylog("Matching "+data.length()+" bytes data @ for table "+table_catalog+"."+table_owner+"."+table_name+"."+col_name);
									Matcher matcher = pattern.get(p).matcher(data.toString());
									if (matcher.find()) {
										match_count++;
										break;
									}
								} catch(Exception e) {
									e.printStackTrace();
								}
							}
	
							
						} 
						else if (rule_type.equals(RULE_TYPE_JS)) {
							
							boolean is_ok=testJS(factory, engine,script,data);
							if (is_ok) match_count++;
	
						} 
						else if (rule_type.equals(RULE_TYPE_SQL)) {
							if (regex.contains("?")) {
								bindlist.clear();
								bindlist.add(new String[]{"STRING",data.toString()});
							}
								
							ArrayList<String[]> tmpSQLArr=mDiscLib.getDbArray(connApp, regex, 1, bindlist, 5);
							
							if (tmpSQLArr!=null && tmpSQLArr.size()>0)  match_count++;
								
						}
					} //for (int s=0;s<actual_data_size;s++)
					
					
	
					
					if (match_count>0) {
						addMaskDiscoveryResult(resArr, col_name, col_type, r, match_count, col_sample_size);
					}
	
				
				} //for rule
				
				
			}
		
		tableResultArr.set(tab_arr_id, resArr);
		tableStatusArr.set(tab_arr_id, STATE_DONE);
	}
	
	
	
	//------------------------------------------------------------
	static final String js_par="${1}";
	static final int js_par_len=js_par.length();
	
	boolean testJS(ScriptEngineManager factory, ScriptEngine engine, String code,StringBuilder data) {
		String ret1="";
		StringBuilder js_code=new StringBuilder(code);
		
		if (js_code.indexOf(js_par)>-1 && data.length()>0) {
			try {
				
				while(true) {
					int i=js_code.indexOf(js_par);
					if (i==-1) break;
					js_code.delete(i, i+js_par_len);
					js_code.insert(i, data.toString().replaceAll("\"", "\\\""));
				}
				
			} catch(Exception e) {
				return false;
			}
		}
		
		try {
			ret1=""+ engine.eval(js_code.toString());
		} catch (Exception e) {
			mylog("EXCEPTION AT SCRIP : "+e.getMessage().replace("\u0007", ""));
			mylog("=====================================");
			mylog(js_code.toString().replace("\u0007", "")); //removing beep. blocks the  system...
			mylog("=====================================");
			
			
			//e.printStackTrace();
			return false;
		}
		
		if (ret1.trim().toLowerCase().contains("true")) return true;
		
		return false;
	}
	
	//**********************************************************************************************************************************************
	void performCopyDiscovery(
			Connection connApp, 
			int thread_id,  
			int tab_arr_id
			) {
		
		tableStatusArr.set(tab_arr_id, STATE_DISCOVERING);
		
		String[] tab=tableArr.get(tab_arr_id);
		String table_catalog=tab[0];
		String table_owner=tab[1];
		String table_name=tab[2];
		
		
		setCatalog(connApp, table_catalog);
		
		/*
		String sql="Select 1 from \""+table_owner+"\".\""+table_name+"\"";
		if (isMysql()) sql="Select 1 from "+table_owner+"."+table_name+ " limit 0,"+sample_size;
		if (isMssql()) sql="Select top "+sample_size+" 1 from \""+table_owner+"\".\""+table_name+"\" WITH (NOLOCK) ";
		*/
		
		
		String sql="Select 1 from "+addStartEndForTable(table_owner+"."+table_name)+"";
		if (isMysql()) sql="Select 1 from "+addStartEndForTable(table_owner+"."+table_name)+ " limit 0,"+sample_size;
		if (isMssql()) sql="Select top "+sample_size+" 1 from "+addStartEndForTable(table_owner+"."+table_name)+" WITH (NOLOCK) ";
		
		mylog("Discovering for copy ["+tab_arr_id+"]: "+sql +" by thread "   + thread_id);
		
		ArrayList<String[]> sampleData=mDiscLib.getDbArray(connApp, sql, sample_size, null, 10);
		
		
		int actual_data_size=sampleData.size();
		 
		StringBuilder data=new StringBuilder();
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		StringBuilder sqlSampleData=new StringBuilder();
		StringBuilder sqlCheckParent=new StringBuilder();
		
		
		  
		ArrayList<String[]> resArr=new ArrayList<String[]>();
		
		if (actual_data_size>0) 	
			for (int p=0;p<tableArr.size();p++) {
				
				String parent_tab_catalog=tableArr.get(p)[0];
				String parent_tab_owner=tableArr.get(p)[1];
				String parent_tab_name=tableArr.get(p)[2];
				
				if (!table_catalog.equals(parent_tab_catalog)) setCatalog(connApp, parent_tab_catalog);
				
				if (mDiscLib.isTableEmpty(this,connApp, parent_tab_owner, parent_tab_name)) {
					mylog("!table ["+parent_tab_catalog+"]."+parent_tab_owner+"."+parent_tab_name+" is empty. skipping.");
					continue;
				}
				
				ArrayList<String[]> parentPKFields=mDiscLib.getPrimaryKeyFields(this, connApp,parent_tab_catalog, parent_tab_owner, parent_tab_name);
				
				if (parentPKFields.size()==0) {
					mylog("!table "+parent_tab_owner+"."+parent_tab_name+" has no PK.");
					continue;
				} 
				
				
				String parent_pk_fields="";
				
				for (int pk=0;pk<parentPKFields.size();pk++) {
					if (parent_pk_fields.length()>0) parent_pk_fields=parent_pk_fields+",";
					parent_pk_fields=parent_pk_fields+parentPKFields.get(pk)[0];
				}
				mydebug(":) table "+parent_tab_owner+"."+parent_tab_name+" PK fields : "+parent_pk_fields);
				
				if (!table_catalog.equals(parent_tab_catalog)) setCatalog(connApp, table_catalog);
				
				ArrayList<String[]> colCombination=mDiscLib.getColumnNamesCombination(this, connApp, table_catalog, table_owner, table_name,parentPKFields);
				
				if (colCombination.size()==0) {
					mylog("!table ["+table_catalog+"]."+table_owner+"."+table_name+" has no key combination.");
					continue;
				}
				
				
				
				
				mylog("Thread "+thread_id+" Comparing " + table_name+" to " +parent_tab_name);

				
				sqlCheckParent.setLength(0);
				sqlCheckParent.append("select ");
				if (isMssql()) sqlCheckParent.append(" TOP 1 ");
				sqlCheckParent.append(" 1 ");
				
				sqlCheckParent.append(" from ");
				
				
				sqlCheckParent.append(addStartEndForTable(parent_tab_owner+"."+parent_tab_name));
				
				
				if (isMssql()) sqlCheckParent.append(" WITH (NOLOCK) ");
				
				sqlCheckParent.append(" where ");
				
				for (int pk=0;pk<parentPKFields.size();pk++) {
					//String pk_col_name=parentPKFields.get(pk)[0];
					String pk_col_name=addStartEndForColumn(parentPKFields.get(pk)[0]);
					if (pk>0)  sqlCheckParent.append(" and ");
					sqlCheckParent.append(pk_col_name+"=?");
				}
				
				
				if (isMysql()) sqlCheckParent.append(" limit 0,1");
				
				
				for (int col=0;col<colCombination.size();col++) {
					
					String[] colList=colCombination.get(col);
					
					String child_rel_fields="";
		
					sqlSampleData.setLength(0);
					
					
					
					sqlSampleData.append("select ");
					
					
					if (isMssql()) sqlSampleData.append(" TOP "+sample_size+" ");
					
					
					
					for (int fk=0;fk<colList.length;fk++) {
						String col_name=colList[fk];
						
						if (fk>0) child_rel_fields=child_rel_fields+",";
						child_rel_fields=child_rel_fields+col_name;
						
						if (fk>0)  sqlSampleData.append(", ");
						sqlSampleData.append(col_name);
					}
					
					
					
					
					sqlSampleData.append(" from ");
					
					
					sqlSampleData.append(addStartEndForTable(table_owner+"."+table_name));
					
					
					
					boolean where_put=false;
					int nullable_count=0;
					
					for (int fk=0;fk<colList.length;fk++) {
						//String col_name=colList[fk];
						String col_name=addStartEndForColumn(colList[fk]);
						String is_nullable=(String) hm.get("NULLABLE_OF_"+table_catalog+"."+table_owner+"."+table_name+"."+col_name);
						if (is_nullable==null) is_nullable="";
						
						if (!is_nullable.equals("YES")) {
							if (!where_put) {
								sqlSampleData.append(" where ");
								where_put=true;
							}
							nullable_count++;
							if (nullable_count>1) sqlSampleData.append(" and ");
							
							sqlSampleData.append(col_name+" is not null ");
							

						}
					}
					
					
					
					
					
					if (isMysql()) sqlSampleData.append(" limit 0,"+sample_size);


					int matched_count=0;
					
					ArrayList<String> sampleColList=new ArrayList<String>();
					ArrayList<String> sampleColTypeList=new ArrayList<String>();

					if (!table_catalog.equals(parent_tab_catalog)) setCatalog(connApp, table_catalog);
					
					ArrayList<String[]> sampleDataArr=mDiscLib.getDbArray(connApp, sqlSampleData.toString(), sample_size, null, 10, sampleColList, sampleColTypeList);
					
					if (sampleDataArr.size()==0) {
						mylog("!["+table_catalog+"]."+table_owner+"."+table_name+".["+child_rel_fields+"] has no sample data. skipping.");
						continue;
					}
					int actual_sample_data_size=sampleDataArr.size();
					mylog(""+actual_sample_data_size+" Sample data found for ["+table_catalog+"]."+table_owner+"."+table_name+".["+child_rel_fields+"]");
					
					
					bindlist.clear();
					
					
					for (int fk=0;fk<sampleColList.size();fk++) {
						String col_name=colList[fk];
						String data_type=(String) hm.get("DATA_TYPE_OF_"+table_catalog+"."+table_owner+"."+table_name+"."+col_name);
						if (data_type==null) data_type="-999";
						int data_type_int=Integer.parseInt(data_type);
						
						String bind_type="STRING";
						String bind_val="";
						
						if (data_type_int==java.sql.Types.INTEGER) bind_type="INTEGER";
						else if (data_type_int==java.sql.Types.NUMERIC) bind_type="INTEGER";
						else if (data_type_int==java.sql.Types.SMALLINT) bind_type="INTEGER";
						
						bindlist.add(new String[]{bind_type,bind_val});
						
					}
					
					for (int s=0;s<actual_sample_data_size;s++) {
						
						String[] aSampleArr=sampleDataArr.get(s);
						
						boolean has_empty_column=false;
						boolean has_decimal_part=false;
						boolean too_long_value=false;
						
						for (int c=0;c<aSampleArr.length;c++) {
							if (aSampleArr[c].trim().length()==0) {
								has_empty_column=true;
								break;
							}
							
							if (bindlist.get(c)[0].equals("INTEGER") && (aSampleArr[c].contains(".") || aSampleArr[c].contains(",")) ) {
								has_decimal_part=true;
								break;
							}
							
							if (aSampleArr[c].length()>255) {
								too_long_value=true;
								break;
							}
							
							//mylog("Setting bindval ["+c+"] to "+aSampleArr[c]);
							
							String[] bindEl=bindlist.get(c);
							bindEl[1]=aSampleArr[c];
							bindlist.set(c, bindEl);
						}
						
						
						
						if (has_empty_column) {
							mylog("!["+table_catalog+"]."+table_owner+"."+table_name+" Sample record["+s+"] has empty columns "+Arrays.toString(aSampleArr));
							continue;
						}
						
						if (has_decimal_part) {
							mylog("!["+table_catalog+"]."+table_owner+"."+table_name+" Sample record["+s+"] has decimal part for columns "+Arrays.toString(aSampleArr));
							continue;
						}
						
						if (too_long_value) {
							mylog("!["+table_catalog+"]."+table_owner+"."+table_name+" Sample record["+s+"] is too long for relation");
							continue;
						}
						
						//mylog(sqlCheckParent.toString());
						//for (int b=0;b<bindlist.size();b++) 
						//	mylog("\t"+bindlist.get(b)[1]+" ["+bindlist.get(b)[0]+"]");
						
						if (!table_catalog.equals(parent_tab_catalog)) setCatalog(connApp, parent_tab_catalog);
						
						ArrayList<String[]> checkArr=mDiscLib.getDbArray(connApp, sqlCheckParent.toString(), 1, bindlist, 5);
						if (checkArr.size()==1) matched_count++;
						
					} //for (int s=0;s<actual_sample_data_size;s++)
					
					
					if (matched_count>0) 
						addCopyDiscoveryResult(resArr,	
								table_catalog,table_owner,table_name,
								parent_tab_catalog,parent_tab_owner,parent_tab_name,
								child_rel_fields,parent_pk_fields,matched_count, actual_sample_data_size);
				} //for (int col=0;col<colList.size()
				 
				
			
			
			} //for (int p=0;p<tableArr.size();p++)
			
		
		
		
			
		
		tableResultArr.set(tab_arr_id, resArr);
		tableStatusArr.set(tab_arr_id, STATE_DONE);
	}
	
}
