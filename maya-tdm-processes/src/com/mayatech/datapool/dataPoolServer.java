package com.mayatech.datapool;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;

import com.mayatech.baseLibs.genLib;

public class dataPoolServer {
	
	int data_pool_instance_id=0;
	int app_id=0;
	int target_id=0;
	int target_pool_size=0;
	boolean is_debug=false;
	int paralellism_count=10;
	
	int SPACE_MAX_SIZE=1000;
	
	
	int written_count=0;
	
	
	int pool_id=0;
	String pool_base_sql="";
	String pool_base_insert_sql="";
	int pool_family_id=0;
	
	ArrayList<String[]> dbArr=new ArrayList<String[]>();
	ArrayList<String[]> lovArr=new ArrayList<String[]>();
	ArrayList<String[]> propertyArr=new ArrayList<String[]>();
	
	boolean is_server_cancelled=false;
	
	boolean is_commiting=false;
	
	
	Connection connConf=null;
	Connection connConfListener=null;
	Connection connConfCancel=null;
	Connection connConfWriter=null;

	ArrayList<Connection> connArr=new ArrayList<Connection>();
	ArrayList<Integer> connArrStatus=new ArrayList<Integer>();
	ArrayList<Integer> connArrFamily=new ArrayList<Integer>();
	
	static final int DB_STATE_FREE=0;
	static final int DB_STATE_BUSY=1;
	
	@SuppressWarnings("rawtypes")
	ConcurrentHashMap hm = new ConcurrentHashMap();
	
	

	
	//-------------------------------------------------
	void mylog(String logstr) {
		System.out.println(logstr);
	}
	
	//-------------------------------------------------
	void mydebug(String logstr) {
		if (!is_debug) return;
		System.out.println(logstr);
	}
	//-------------------------------------------------
	void initNewDataPoolServer(
			int data_pool_instance_id, 
			int app_id,
			int target_id,
			int target_pool_size,
			boolean is_debug,
			int paralellism_count,
			String conf_db_driver,
			String conf_db_url,
			String conf_db_username,
			String conf_db_password) {
		
		
		this.data_pool_instance_id=data_pool_instance_id;
		this.app_id=app_id;
		this.target_id=target_id;
		this.target_pool_size=target_pool_size;
		this.is_debug=is_debug;
		this.paralellism_count=paralellism_count;
		
		resetVariables();
		
		
		if (this.target_pool_size==0) this.target_pool_size=Integer.MAX_VALUE;
		
		mylog("Initializing data pool server...");
		
		connConf=poolLib.getDBConnection(conf_db_url, conf_db_driver, conf_db_username, conf_db_password, 1);
		connConfListener=poolLib.getDBConnection(conf_db_url, conf_db_driver, conf_db_username, conf_db_password, 1);
		connConfCancel=poolLib.getDBConnection(conf_db_url, conf_db_driver, conf_db_username, conf_db_password, 1);
		connConfWriter=poolLib.getDBConnection(conf_db_url, conf_db_driver, conf_db_username, conf_db_password, 1);


		
		if (!is_server_cancelled) startrefresherTreadGrpThread();
		
		if (!is_server_cancelled) startCheckCancelThread();
		
		if (!is_server_cancelled) startWriterThread();
		
		if (!is_server_cancelled) startServer();
		
		
	}
	//--------------------------------------------------
	void resetVariables() {
		SPACE_MAX_SIZE=100*paralellism_count;
		if (SPACE_MAX_SIZE<1000) SPACE_MAX_SIZE=1000;
		if (SPACE_MAX_SIZE>100000) SPACE_MAX_SIZE=100000;
		
		
		recArr.clear();
		recStatArr.clear();
		
		written_count=0;
	}
	//--------------------------------------------------
	boolean loadConfiguration() {
		mylog("loadConfiguration...");
		
		hm.clear();
		
		try {
			String sql="";
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			
			mylog("---------------------------------------------------------");
			mylog("---- Checking pool instance parameters                ---");
			mylog("---------------------------------------------------------");
			sql="select target_pool_size, is_debug, paralellism_count from tdm_pool_instance where id=?";
			
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+data_pool_instance_id});
			
			ArrayList<String[]> paramsarr=poolLib.getDbArray(connConf, sql, 1, bindlist, 0);
			
			try { target_pool_size=Integer.parseInt(paramsarr.get(0)[0]); } catch(Exception e) {e.printStackTrace();}
			try { String tmp=paramsarr.get(0)[1]; is_debug=false; if (tmp.equals("YES")) is_debug=true; } catch(Exception e) {e.printStackTrace();}
			try { paralellism_count=Integer.parseInt(paramsarr.get(0)[2]); } catch(Exception e) {e.printStackTrace();}
			
			resetVariables();
			
			mylog("---------------------------------------------------------");
			mylog("---- Checking pool base parameters                    ---");
			mylog("---------------------------------------------------------");
			sql="select id, base_sql, family_id from tdm_pool where app_id=?";
			
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+app_id});
			
			ArrayList<String[]> arr=poolLib.getDbArray(connConf, sql, 1, bindlist, 0);
			
			if (arr==null || arr.size()==0) {
				mylog("Pool is not configured with app_id : "+ app_id);
				return false;
			}
			
			String str_pool_id=arr.get(0)[0];
			
			try {
				pool_id=Integer.parseInt(str_pool_id);
			} catch(Exception e) {
				mylog("Pool id is not valid : "+ str_pool_id);
				return false;
			}
			
			pool_base_sql=arr.get(0)[1];
			try{pool_family_id=Integer.parseInt(arr.get(0)[2]);} catch(Exception e) {pool_family_id=0;}
			
			mylog("---------------------------------------------------------");
			mylog("---- Loading Family List Configuration                ---");
			mylog("---------------------------------------------------------");
			
			sql="select id, family_name from tdm_family";
			bindlist.clear();
			ArrayList<String[]> familyArr=poolLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
			
			
			
			for (int i=0;i<familyArr.size();i++) {
				int family_id=Integer.parseInt(familyArr.get(i)[0]);
				String family_name=familyArr.get(i)[1];
				mylog("... Family ["+family_id+"]: "+family_name);
				
				hm.put("FAMILY_NAME_"+family_id, family_name);
				
			}
			
			if (!hm.containsKey("FAMILY_NAME_"+pool_family_id)) {
				mylog("Base sql family id is not valid : "+ pool_family_id);
				return false;
			}
			
			
			
			mylog("---------------------------------------------------------");
			mylog("---- Loading DB Configuration                         ---");
			mylog("---------------------------------------------------------");
			
			sql="select id, db_driver, db_connstr, db_username, db_password from tdm_envs";
			
			bindlist.clear();
			
			
			dbArr.clear();
			dbArr=poolLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
			
			for (int i=0;i<dbArr.size();i++) {
				int db_id=Integer.parseInt(dbArr.get(i)[0]);
				String db_driver	=dbArr.get(i)[1];
				String db_connstr	=dbArr.get(i)[2];
				String db_username	=dbArr.get(i)[3];
				String db_password	=genLib.passwordDecoder(dbArr.get(i)[4]) ;
				
				mydebug("DB_INDEX_"+db_id+"="+i + "["+db_connstr+"]");
				
				hm.put("DB_INDEX_"+db_id, i);
				
			}
			
			
			mylog("---------------------------------------------------------");
			mylog("---- Checking Family-DB Configuration                 ---");
			mylog("---------------------------------------------------------");
			
			sql="select family_id, env_id from tdm_target_family_env where target_id=?";
			
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+target_id});
			
			ArrayList<String[]> envArr=poolLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
			
			boolean db_check_ok=true;
			
			for (int i=0;i<envArr.size();i++) {
				int family_id=Integer.parseInt(envArr.get(i)[0]);
				int db_id=Integer.parseInt(envArr.get(i)[1]);
				
				if (!hm.containsKey("FAMILY_NAME_"+family_id)) {
					db_check_ok=false;
					break;
				}
				
				if (!hm.containsKey("DB_INDEX_"+db_id)) {
					db_check_ok=false;
					break;
				}
				
				int db_index=(int) hm.get("DB_INDEX_"+db_id);
				
				mydebug("DB_INDEX_OF_FAMILY_"+family_id+"="+db_index);
				 
				hm.put("DB_INDEX_OF_FAMILY_"+family_id, db_index);
				
			}
			
			if (!db_check_ok) {
				mylog("There is missing database configuration");
				return false;
			}
			
			
			mylog("---------------------------------------------------------");
			mylog("---- Loading Lov Configuration                        ---");
			mylog("---------------------------------------------------------");
			
			sql="select id, lov_name, family_id, lov_statement from tdm_pool_lov where pool_id=?";
			
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+pool_id});
			
			lovArr.clear();
			lovArr=poolLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
			
			
			for (int i=0;i<lovArr.size();i++) {
				int lov_id=Integer.parseInt(lovArr.get(i)[0]);
				String lov_name			=lovArr.get(i)[1];
				
				mydebug("... Lov ["+lov_id+"]: "+lov_name);
				
				hm.put("LOV_NAME_"+lov_id, lov_name);
				hm.put("LOV_INDEX_"+lov_id, i);
			}
			
			
			mylog("---------------------------------------------------------");
			mylog("---- Loading Property Configuration                   ---");
			mylog("---------------------------------------------------------");
			
			sql="select "+
					" id,  "+
					" property_name, "+
					" data_type, "+
					" is_indexed, "+ 
					" is_searchable, "+ 
					" lov_id, " +
					" get_method, "  +
					" source_code, "+
					" property_family_id, "+
					" target_url, "+
					" extract_method, " + 
					" extract_method_parameter " + 
					" from tdm_pool_property "+
					" where pool_id=? and is_valid='YES' order by order_no ";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+pool_id});
			
			propertyArr.clear();
			propertyArr=poolLib.getDbArray(connConf, sql, Integer.MAX_VALUE, bindlist, 0);
			
			mylog("---------------------------------------------------------");
			mylog("---- Compiling property SQL's                         ---");
			mylog("---------------------------------------------------------");
			for (int i=0;i<propertyArr.size();i++) {
				String property_id=propertyArr.get(i)[0];
				String get_method=propertyArr.get(i)[6];
				
				ArrayList<Integer> bindOrder=new ArrayList<Integer>();
				StringBuilder sb=new StringBuilder();
				if (get_method.equals("DB")) {
					String source_code=propertyArr.get(i)[7];
					
					sb.append(source_code);
					mylog("SQL decode for : "+source_code);
					decodeSqlStatement(bindOrder,sb);
					mylog("SQL decoded : "+sb.toString());
				}


				
				hm.put("BIND_ORDER_OF_"+i, bindOrder);
				hm.put("SQL_STATEMENT_OF_"+i, sb.toString());
			}
			
			
			mylog("---------------------------------------------------------");
			mylog("---- Testing base SQL                                 ---");
			mylog("---------------------------------------------------------");
			mylog(pool_base_sql);
			mylog("---------------------------------------------------------");
			
			Connection testconn=leaseConnection(pool_family_id);
			bindlist.clear();
			ArrayList<String[]> testArr=poolLib.getDbArray(testconn, pool_base_sql, 1, bindlist, 0);
			
			releaseConnection(testconn);
			
			if (testArr==null || testArr.size()==0) {
				mylog("Test is not successfull :(");
				return false;
				
			} else 
				mylog("Test is successfull :)");	
		} catch(Exception e) {
			e.printStackTrace();
			return false;
		}
		
		
		
		
		return true;
		
		
	}
	
	//------------------------------------------------
	void decodeSqlStatement(ArrayList<Integer> bindOrder,StringBuilder sb) {
		
		ArrayList<String> parArr=new ArrayList<String>();
		ArrayList<Integer> parPosArr=new ArrayList<Integer>();
		ArrayList<Integer> parPropMapArr=new ArrayList<Integer>();
		
		int i=0;
		
		while(true) {
			try {
				i=sb.indexOf("${",i);
				if (i==-1) break;
				int ie=sb.indexOf("}",i+2);
				
				if (ie==i) break;
				
				String key=sb.substring(i+2, ie);
				mydebug("Adding key : " + key);
				
				parArr.add(key);
				parPosArr.add(i);
				parPropMapArr.add(-1);
				
				
				i=ie;
			} catch(Exception e) {
				e.printStackTrace();
			}
			
		
			
		}
		
		//---------------------------------
		ArrayList<String> propNameArr=new ArrayList<String>();
		for (int k=0;k<propertyArr.size();k++) {
			propNameArr.add(propertyArr.get(k)[1].toUpperCase());
		}
		
		//---------------------------------
		for (int k=0;k<parArr.size();k++) {
			String key=parArr.get(k).toUpperCase();
			mydebug("Checking map for "+ key);
			
			int map_id=propNameArr.indexOf(key);
			if (map_id>-1) {
				parPropMapArr.set(k, map_id);
				mydebug("Adding bind Order : "+map_id);
				bindOrder.add(map_id);
			}
		}
		
		//---------------------------------
		for (int k=parArr.size()-1;k>=0;k--) {
			
			int map_id=parPropMapArr.get(k);
			if (map_id==-1) continue;
			
			int pos=parPosArr.get(k);
			String key=parArr.get(k);
			int end=pos+key.length()+3;
			sb.delete(pos, end);
			
			sb.insert(pos, "?");
		}
	}
	
	
	
	//------------------------------------------------
	void replaceOldTables() {
		String data_table_temp="tdm_pool_data_"+data_pool_instance_id+"_tmp";
		String lov_table_temp="tdm_pool_data_lov_"+data_pool_instance_id+"_tmp";
		
		String data_table_original="tdm_pool_data_"+data_pool_instance_id;
		String lov_table_original="tdm_pool_data_lov_"+data_pool_instance_id;
		
		dropIfExists(data_table_original);
		dropIfExists(lov_table_original);
		
		String sql="";
		
		sql="ALTER TABLE "+data_table_temp+" RENAME "+data_table_original;
		mydebug(sql);
		poolLib.execSingleUpdateSQL(connConf, sql, null);
		
		
		sql="ALTER TABLE "+lov_table_temp+" RENAME "+lov_table_original;
		mydebug(sql);
		poolLib.execSingleUpdateSQL(connConf, sql, null);
		
	}
	
	//-------------------------------------------------
	void dropIfExists(String table_name) {
		String sql="select * from information_schema.tables where table_schema =  DATABASE() and table_name ='"+table_name+"'";
		ArrayList<String[]> arr=poolLib.getDbArray(connConf, sql, 1, null, 0);
		
		if (arr!=null && arr.size()==1) {
			sql="drop table "+table_name;
			mydebug(sql);
			poolLib.execSingleUpdateSQL(connConf, sql, null);
		}
	}
	
	//--------------------------------------------------
	synchronized Connection leaseConnection(Integer db_family_id) {
		int found_id=-1;
		
		for (int i=0;i<connArr.size();i++) {
			if (connArrStatus.get(i)==DB_STATE_BUSY) continue;
			
			if (connArrFamily.get(i)!=db_family_id) continue;
			
			found_id=i;
			
			break;
		}
		
		if (found_id>-1) {
			
			mydebug("Connection leased " + connArr.get(found_id).hashCode());
			
			connArrStatus.set(found_id, DB_STATE_BUSY);
			return connArr.get(found_id);
		}
		
		try {
			int db_index=(int) hm.get("DB_INDEX_OF_FAMILY_"+db_family_id);
			
			mydebug("Db index : " + db_index);
			
			String[] dbinfo=dbArr.get(db_index);
			
			String db_driver	=dbinfo[1];
			String db_connstr	=dbinfo[2];
			String db_username	=dbinfo[3];
			String db_password	=dbinfo[4];
			
			mydebug("db_driver        : " + db_driver);
			mydebug("db_connstr       : " + db_connstr);
			mydebug("db_username      : " + db_username);
			mydebug("db_password      : " + "********");
			
			
			
			connArr.add(poolLib.getDBConnection(db_connstr, db_driver, db_username, db_password, 0));
			connArrStatus.add(DB_STATE_BUSY);
			connArrFamily.add(db_family_id);
			
			mydebug("Connection leased " + connArr.get(connArr.size()-1).hashCode());
			
			return connArr.get(connArr.size()-1);
		} catch(Exception e) {
			e.printStackTrace();
			return null;
		}
		
		
		
		
	}
	
	//--------------------------------------------------
	synchronized void releaseConnection(Connection conn) {
		
		int found_id=-1;
		
		int search_hashcode=conn.hashCode();
		
		for (int i=0;i<connArr.size();i++) {
			if (connArrStatus.get(i)==DB_STATE_FREE) continue;

			
			if (connArr.get(i).hashCode()!=search_hashcode) continue;
			
			found_id=i;
			
			break;
		}
		
		if (found_id>-1) {
			mydebug("Connection released " + search_hashcode);
			connArrStatus.set(found_id, DB_STATE_FREE);
		}
	}
	
	//--------------------------------------------------
	ThreadGroup refresherTreadGrp = new ThreadGroup("Refresher Thread Group");
	
	void startrefresherTreadGrpThread() {
		mylog("startrefresherTreadGrpThread...");
		
		String thread_name="DPOOL_CONF_LISTENER_THREAD";
		try {
			Thread thread=new Thread(refresherTreadGrp, 
					new dataPoolRefreshThread(this, data_pool_instance_id),thread_name);
			thread.start();
		} catch(Exception e) {
			e.printStackTrace();
		}
		
	}
	
	
	//--------------------------------------------------
	ThreadGroup CheckCancelTreadGrp = new ThreadGroup("Check Cancel Listener Thread Group");
	
	void startCheckCancelThread() {
		mylog("startCheckCancelThread...");
		
		String thread_name="DPOOL_CHECK_CANCEL_THREAD";
		try {
			Thread thread=new Thread(CheckCancelTreadGrp, 
					new dataPoolCheckCancelThread(this, data_pool_instance_id),thread_name);
			thread.start();
		} catch(Exception e) {
			e.printStackTrace();
		}
		
	}
	
	//--------------------------------------------------
	ThreadGroup WriterTreadGrp = new ThreadGroup("Writer Thread Group");
	
	void startWriterThread() {
		mylog("startWriterThread...");
		
		String thread_name="DPOOL_WRITER_THREAD";
		try {
			Thread thread=new Thread(WriterTreadGrp, 
					new dataPoolWriterThread(this, data_pool_instance_id),thread_name);
			thread.start();
		} catch(Exception e) {
			e.printStackTrace();
		}
		
	}
	
	
	//--------------------------------------------------
	
	ArrayList<String> ColumnNames=new ArrayList<String>();
	ArrayList<String> ColumnBindTypes=new ArrayList<String>();
	
	void createTempTables() {
		
		
		
		clearTempTables();
		
		String data_table="tdm_pool_data_"+data_pool_instance_id+"_tmp";
		String lov_table="tdm_pool_data_lov_"+data_pool_instance_id+"_tmp";
		
		
				
		ColumnNames.clear();
		ColumnBindTypes.clear();
		
		String sql="CREATE TABLE "+data_table+" ( \n"+
				" id int(11) AUTO_INCREMENT,  \n"+
				" is_reserved varchar(1) default 'N', \n"+
				" reservation_date datetime, \n"+
				" reserved_by int(11) default 0, \n"+
				" reservation_note varchar(1000), \n"+
				" PRIMARY KEY (id),  \n" + 
				" UNIQUE KEY id_UNIQUE (id)  \n"+
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8";
		
		mylog(sql);
		poolLib.execSingleUpdateSQL(connConf, sql, null);
		
		
		
		
		sql="CREATE TABLE "+lov_table+" ( \n"+
				" id int(11) AUTO_INCREMENT,  \n"+
				" property_id int(11), \n"+
				" lov_value varchar(200), \n"+
				" lov_title varchar(200), \n"+
				" PRIMARY KEY (id),  \n" + 
				" UNIQUE KEY id_UNIQUE (id)  \n"+
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8";
		
		mylog(sql);
		poolLib.execSingleUpdateSQL(connConf, sql, null);
		
		for (int i=0;i<propertyArr.size();i++) {
			String property_name=propertyArr.get(i)[1];
			String data_type=propertyArr.get(i)[2];
			
			String bind_type="STRING";
			if (data_type.equals("NUMBER")) bind_type="INTEGER";
			if (data_type.equals("DATE")) bind_type="DATE";
			
			ColumnNames.add(property_name);
			ColumnBindTypes.add(bind_type);
			
			
			sql="alter table "+data_table+" add "+ 
					property_name;
			
			if (data_type.equals("DATE")) 
				sql=sql+" varchar(1000) ";
			else if (data_type.equals("NUMBER")) 
				sql=sql+" int(11) ";
			else if (data_type.equals("MEMO")) 
				sql=sql+" text ";
			else sql=sql+" varchar(200) ";
			
			mydebug(sql);
			
			poolLib.execSingleUpdateSQL(connConf, sql, null);
			
			
		}
		
		
		
		
		//----------------------------------------------------------------------
		pool_base_insert_sql="insert into "+ data_table+ " ("+
				"#INSERT_FIELDS# "+
				") "+
				" values "+
				"( "+
				"#INSERT_BINDS# "+
				")";
		
		String insert_fields="";
		String insert_binds="";
		for (int i=0;i<ColumnNames.size();i++) {
			if (insert_fields.length()>0) insert_fields=insert_fields+", ";
			insert_fields=insert_fields+ColumnNames.get(i);
			
			if (insert_binds.length()>0) insert_binds=insert_binds+", ";
			insert_binds=insert_binds+"?";
			
		}
		
		pool_base_insert_sql=pool_base_insert_sql.replace("#INSERT_FIELDS#", insert_fields);
		pool_base_insert_sql=pool_base_insert_sql.replace("#INSERT_BINDS#", insert_binds);
		
		mylog("Insert Statement  : \n"+pool_base_insert_sql);
	}
	
	//-------------------------------------------------
	void extractLovValues() {
		
		String lov_table="tdm_pool_data_lov_"+data_pool_instance_id+"_tmp";
		
		for (int i=0;i<propertyArr.size();i++) {
			String property_id=propertyArr.get(i)[0];
			String lov_id=propertyArr.get(i)[5];
			
			if (lov_id.equals("0")) continue;
  			
			int lov_index=(int) hm.get("LOV_INDEX_"+lov_id);
			String lov_name=(String) hm.get("LOV_NAME_"+lov_id);
			int lov_family_id=0;
			String lov_statement="";
			
			//"select id, lov_name, family_id, lov_statement from tdm_pool_lov where pool_id=?";
			
			try {
				lov_family_id=Integer.parseInt(lovArr.get(lov_index)[2]);
				lov_statement=lovArr.get(lov_index)[3];
			} catch(Exception e) {
				e.printStackTrace();
				continue;
			}
			
			
			
			mylog("Extraction Lov :"+ lov_name);
			
			boolean is_sql_based=false;
			if ((" "+lov_statement.trim()+" ").replaceAll("\n|\r", " ").toLowerCase().indexOf(" select ")>-1)
				is_sql_based=true;
			
			ArrayList<String[]> arr=new ArrayList<String[]>();
			
			if (is_sql_based) {
				
				Connection lovConn=leaseConnection(lov_family_id);
				arr=poolLib.getDbArray(lovConn, lov_statement, 200, null, 0);
				releaseConnection(lovConn);
				
				for (int a=0;a<arr.size();a++) {
					String[] els=arr.get(a);
					if (els.length>1) continue;
					String[] arrStr=new String[2];
					arrStr[0]=els[0];
					arrStr[1]=els[0];
					
					arr.set(a, arrStr);
				}
				
			} else {
				String[] lines=lov_statement.split("\n|\r");
				for (int v=0;v<lines.length;v++) {
					String a_line=lines[v];
					if (a_line.trim().length()==0) continue;
					String[] elements=a_line.split(":");
					String[] arrStr=new String[2];
					try {arrStr[0]=elements[0];} catch(Exception e) {continue;}
					try {arrStr[1]=elements[1];} catch(Exception e) {arrStr[0]=elements[0];}
					
					arr.add(arrStr);
				}
			}
			
			String sql="insert into "+lov_table  + "(property_id, lov_value, lov_title) values (?,?,?)";
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			for (int k=0;k<arr.size();k++) {
				String lov_value=arr.get(k)[0];
				String lov_title=arr.get(k)[1];
				
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",property_id});
				bindlist.add(new String[]{"STRING",lov_value});
				bindlist.add(new String[]{"STRING",lov_title});
				
				poolLib.execSingleUpdateSQL(connConf, sql, bindlist);
			}
			
		}
	}
	
	//-------------------------------------------------
	void createIndexes() {
		String sql="";
		
		String data_table="tdm_pool_data_"+data_pool_instance_id+"_tmp";
		String lov_table="tdm_pool_data_lov_"+data_pool_instance_id+"_tmp";
		
		for (int i=0;i<propertyArr.size();i++) {
			String property_name=propertyArr.get(i)[1];
			String data_type=propertyArr.get(i)[2];
			String is_indexed=propertyArr.get(i)[3];
			String is_searchable=propertyArr.get(i)[4];
			
			
			if (is_searchable.equals("YES")) is_indexed="YES";
			
			
			if (is_indexed.equals("YES") && !data_type.equals("MEMO")) {
				sql="ALTER TABLE "+data_table+" ADD INDEX ndx_pool_"+data_pool_instance_id+"_"+System.currentTimeMillis()+" ("+property_name+" ASC)";
				
				mylog(sql);
				
				poolLib.execSingleUpdateSQL(connConf, sql, null);
			}
		}
	}
	
	//-------------------------------------------------
	void clearTempTables() {
		
		String data_table="tdm_pool_data_"+data_pool_instance_id+"_tmp";
		String lov_table="tdm_pool_data_lov_"+data_pool_instance_id+"_tmp";
		
		dropIfExists(data_table);
		dropIfExists(lov_table);
	}
	
	
	//--------------------------------------------------
	
	ThreadGroup subThreadGroup = new ThreadGroup("Sub Thread Group");
	
	void startSubThreads() {
		mylog("startSubThreads... : " + paralellism_count);
		
		for (int i=0;i<paralellism_count;i++) {
			String thread_name="DPOOL_SUB_THREAD_"+i;
			try {
				Thread thread=new Thread(subThreadGroup, 
						new dataSubThread(this, i),thread_name);
				thread.start();
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		
		
		
	}
	
	//--------------------------------------------------
	
	boolean reload_success=true;
	int base_sql_colcount = 0;
	boolean is_all_records_processed=false;
	
	
	
	void reloadDataPool() {
		
		boolean is_conf_ok=loadConfiguration();
		
		if (!is_conf_ok) {
			mylog("Configuration is not successfully loaded...");
			return;
		}
		
		
		setPoolStatus("REFRESH");
		
		createTempTables();
		
		extractLovValues();
		
		startSubThreads();
		
		
		
		
		
		
		reload_success=true;
		is_all_records_processed=false;
		
		PreparedStatement pstmtConf = null;
		ResultSet rsetConf = null;
		ResultSetMetaData rsmdConf = null;
		
		Connection conn=leaseConnection(pool_family_id);
		
		int property_field_count=propertyArr.size();

		try {
			
			
			pstmtConf = conn.prepareStatement(pool_base_sql);
			
			mydebug("Executing base sql");
			rsetConf = pstmtConf.executeQuery();
			mydebug("Executing base sql. done.");
			rsmdConf = rsetConf.getMetaData();

			base_sql_colcount = rsmdConf.getColumnCount();
			
			
			
			for (int i=0;i<base_sql_colcount;i++) {
				String col_name=rsmdConf.getColumnLabel(i+1).toUpperCase();
				
				hm.put("BASE_COL_"+i, col_name);
				
			}	
			
			int retrieved_count=0;
			
			
			
			while (rsetConf.next()) {
				
				if (is_server_cancelled) break;
				
				retrieved_count++;
				
				if (retrieved_count>target_pool_size) break;
				
				String[] rec=new String[base_sql_colcount+property_field_count];
				
				for (int i=0;i<base_sql_colcount;i++) {
					rec[i]=rsetConf.getString(i+1);
				}
				
				putRecord(rec);
			} 
			
			waitAllRecordFinished();
			
		} catch(Exception e) {
			reload_success=false;
		} finally {
			try{rsetConf.close();} catch(Exception e) {}
			try{pstmtConf.close();} catch(Exception e) {}
		}
		
		releaseConnection(conn);
		
		if (reload_success) {
			createIndexes();
			replaceOldTables();
		}
		else 
			clearTempTables();
		
		recStatArr.clear();
		recArr.clear();
		
		//----------------------------------------------------
		
		if (!is_server_cancelled) {
			String sql="update tdm_pool_instance set last_update_date=now() where id=?";
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			bindlist.add(new String[]{"INTEGER",""+data_pool_instance_id});
			
			poolLib.execSingleUpdateSQL(connConf, sql, bindlist);
			
			
			setPoolStatus("ACTIVE");
		}
		
		
		
	}
	//--------------------------------------------------
	ArrayList<String[]> recArr=new ArrayList<String[]>();
	ArrayList<Byte> recStatArr=new ArrayList<Byte>();
	
	static byte REC_STAT_EMPTY=0;
	static byte REC_STAT_NEW=1;
	static byte REC_STAT_BUSY=2;	
	static byte REC_STAT_DONE=3;
	

	
	//--------------------------------------------------
	void putRecord(String[] rec) {
		if (recArr.size()<SPACE_MAX_SIZE) {
			recArr.add(rec);
			recStatArr.add(REC_STAT_NEW);
			mydebug("put rec to " + (recStatArr.size()-1));
			return;
		}
		
		while (true) {
			int found_id=-1;
			for (int i=0;i<SPACE_MAX_SIZE;i++) {
				if (recStatArr.get(i)==REC_STAT_EMPTY) {
					found_id=i;
					break;
				}
			}
			
			if (found_id>-1) {
				mydebug("put rec to " + found_id);
				recArr.set(found_id, rec);
				recStatArr.set(found_id, REC_STAT_NEW);
				break;
			}
			
			mydebug("looking for an empty space");
			try {Thread.sleep(100); } catch(Exception e) {}
		}
	}
	
	
	//--------------------------------------------------
	void waitAllRecordFinished() {
		int waiting_index=-1;
		long last_waiting_ts=System.currentTimeMillis();
		
		while (true) {
			if (is_server_cancelled) break;
			
			int non_empty_id=-1;
			for (int i=0;i<recStatArr.size();i++) {
				if (recStatArr.get(i)!=REC_STAT_EMPTY) {
					non_empty_id=i;
					break;
				}
			}
			
			if (non_empty_id==-1) {
				is_all_records_processed=true;
				if (is_commiting) 
					mylog("Waiting commit to be finished...");
				else if (subThreadGroup.activeCount()>1)
					mylog("Waiting sub threads to be finished... "+ subThreadGroup.activeCount()+ " remaining");
				else 
					break;
			}
			
			
			mylog("waitAllRecordFinished... : " + non_empty_id);
			
			if (waiting_index!=non_empty_id) {
				waiting_index=non_empty_id;
				last_waiting_ts=System.currentTimeMillis();
			}
			else {
				if ((System.currentTimeMillis()-last_waiting_ts)>60000) {
					mylog("Waiting sub threads to be finished timed out");
					is_all_records_processed=true;
					break;
				}
			}
			
			try {Thread.sleep(1000); } catch(Exception e) {}
		}
		
		
		
	}
	
	//--------------------------------------------------
	void setPoolStatus(String status) {
		
		
		
		String sql="update tdm_pool_instance set status=?, cancel_flag='NO' where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"STRING",status});
		bindlist.add(new String[]{"INTEGER",""+data_pool_instance_id});
		
		

		
		poolLib.execSingleUpdateSQL(connConf, sql, bindlist);
		
		if (status.equals("ACTIVE")) {
			sql="update tdm_pool_instance set start_date=now()  where id=?";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+data_pool_instance_id});
			
			poolLib.execSingleUpdateSQL(connConf, sql, bindlist);
		}
		
		if (status.equals("INACTIVE")) {
			sql="update tdm_pool_instance set start_date=null where id=?";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+data_pool_instance_id});
			
			poolLib.execSingleUpdateSQL(connConf, sql, bindlist);
		}
		
		
		if (status.equals("REFRESH")) {
			sql="update tdm_pool_instance set pool_size=0, reserved_size=0, reload_flag='NO' where id=?";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+data_pool_instance_id});
			
			poolLib.execSingleUpdateSQL(connConf, sql, bindlist);
		}
		
		mylog("Status set to " + status);
	}

	//-------------------------------------------------
	void heartbeat() {
		
		String sql="update tdm_pool_instance set last_check_date=now() where id=? ";
		
		mydebug("heartbeat..."+data_pool_instance_id);
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",""+data_pool_instance_id});
		
		poolLib.execSingleUpdateSQL(connConf, sql, bindlist,0);
	}
	//--------------------------------------------------
	void startServer() {
		
		int dummy=0;
		
		setPoolStatus("ACTIVE");
		
		while(true) {
			if (is_server_cancelled) break;
			
			try{Thread.sleep(1000);} catch(Exception e) {}
			
			//mylog("Running data pool server...");
			
			dummy++;
			
			if (dummy%10==0) 
				heartbeat();
			if (dummy==Integer.MAX_VALUE) dummy=0;
		}
		
		setPoolStatus("INACTIVE");
		
		closeAll();
	}
	
	//------------------------------------------------------------
	void closeAll() {
		
		mylog("Closing....");
		is_server_cancelled=true;
		
		try{connConf.close();} catch(Exception e) {}
		try{connConfListener.close();} catch(Exception e) {}
		try{connConfCancel.close();} catch(Exception e) {}
		try{connConfWriter.close();} catch(Exception e) {}
		
		for (int i=0;i<connArr.size();i++) {
			try{connArr.get(i).close();} catch(Exception e) {}
		}
		
		mylog("Bye....");
	}
	
	
	//-----------------------------------------------------------------------------
	void checkCancel() {
		
		if (is_server_cancelled) return;
		
		String sql="select cancel_flag, status from tdm_pool_instance \n" + 
					"	where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+data_pool_instance_id});
		
		ArrayList<String[]> arr=poolLib.getDbArray(connConfCancel, sql, Integer.MAX_VALUE, bindlist, 0);
		
		if (arr==null || arr.size()==0) {
			mylog("Server deleted...");
			is_server_cancelled=true;
			return;
		}
		
		String cancel_flag=arr.get(0)[0];
		String status=arr.get(0)[1];
		
		if (cancel_flag.equals("YES") || status.equals("INACTIVE")) {
			mylog("Server cancelled...");
			is_server_cancelled=true;
		}
			

		
		
	}
	
}
