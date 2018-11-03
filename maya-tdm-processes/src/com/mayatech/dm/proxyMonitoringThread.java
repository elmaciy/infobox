package com.mayatech.dm;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import com.mayatech.baseLibs.genLib;


class proxyMonitoringThread implements Runnable  {
	
	ddmProxyServer dm;
	int proxy_id;
	
	
	Connection connMonitoring;
	
	
	static final String monitoring_column_expression_insert_sql="insert into tdm_proxy_monitoring_columns "+
			" (id, proxy_id,proxy_session_id,policy_group_id,monitoring_time,catalog_name,schema_name,object_name,column_name, expression, bytes_received) "+
			" values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";



	int MONITORING_EXECUTION_INTERVAL=5*1000;
	long next_monitoring_check_ts=System.currentTimeMillis()+MONITORING_EXECUTION_INTERVAL;

	
	proxyMonitoringThread(
			ddmProxyServer dm,
			int proxy_id
			) {
		
		this.dm=dm;
		this.proxy_id=proxy_id;
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		
		connMonitoring=ddmLib.getTargetDbConnection(dm.conf_db_driver, dm.conf_db_url, dm.conf_db_username,dm.conf_db_password);
		
		if (!ddmLib.validateMySQLConnection(connMonitoring)) {
			dm.mylog("Connection connLogWriter is not valid. Monitoring is not checked...");
			
			return;
		}
		
		int DB_VALIDATION_INTERVAL=10000;
		long next_db_validation_ts=System.currentTimeMillis()+DB_VALIDATION_INTERVAL;
		

		
		ArrayList<String[]> columnList=new ArrayList<String[]>();
		ArrayList<String[]> expressionList=new ArrayList<String[]>();
		ArrayList<String[]> receivedBytesList=new ArrayList<String[]>();
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		
		while(true) {
			if (dm.is_proxy_cancelled) break;
			
			if (System.currentTimeMillis()>next_db_validation_ts) {
				boolean is_db_valid=ddmLib.validateMySQLConnection(connMonitoring);
				if (!is_db_valid) {
					//retry one time to reconnect
					connMonitoring=ddmLib.getTargetDbConnection(dm.conf_db_driver, dm.conf_db_url, dm.conf_db_username,dm.conf_db_password);
					is_db_valid=ddmLib.validateMySQLConnection(connMonitoring);
					if (!is_db_valid && dm.monitoringPolicies.size()>0) {
						dm.mylog("proxyMonitoringThread configuration db connection is invalid. Since there are at least one monitoring policy active, closing the proxy.");
						dm.is_proxy_cancelled=true;
						break;
					} 
					
				}
				next_db_validation_ts=System.currentTimeMillis()+DB_VALIDATION_INTERVAL;
			}
			
			if (System.currentTimeMillis()>next_monitoring_check_ts) {
				executeMonitoringPolicies(connMonitoring);
				clearAndSynchronizeSentBlackList();
				next_monitoring_check_ts=System.currentTimeMillis()+MONITORING_EXECUTION_INTERVAL;
			}
			
			
			ddmLib.getSetMonitoringColumnsList(dm, columnList, ddmLib.MONITORING_ACTION_GET, 100);
			
			
			
			if (columnList.size()==0) 
				try {Thread.sleep(100);} catch(Exception e) {}
			
			
			long id=System.currentTimeMillis() % 1000000000;
			
			for (int i=0;i<columnList.size();i++) {
				String[] arr=columnList.get(i);
				
				
				String policy_group_id=arr[6];
				
				
				
				
				String catalog_name=genLib.nvl(arr[0],"${default}");
				String schema_name=arr[1];
				String object_name=arr[2];
				String column_name=arr[3];
				String expression="";
				String bytes_received="0";
				
				
				
				if (!dm.hmConfig.containsKey("IS_COLUMN_MONITORED_"+catalog_name+"."+schema_name+"."+object_name+"."+column_name)) 
					continue; 
				
				
				
				String proxy_session_id=arr[4];
				String timestamp=arr[5];
				
				id++;
				
				bindlist.clear();
				bindlist.add(new String[]{"LONG",""+id});
				bindlist.add(new String[]{"INTEGER",""+dm.proxy_id});
				bindlist.add(new String[]{"INTEGER",proxy_session_id});
				bindlist.add(new String[]{"INTEGER",policy_group_id});
				bindlist.add(new String[]{"TIMESTAMP",timestamp});
				bindlist.add(new String[]{"STRING",catalog_name});
				bindlist.add(new String[]{"STRING",schema_name});
				bindlist.add(new String[]{"STRING",object_name});
				bindlist.add(new String[]{"STRING",column_name});
				bindlist.add(new String[]{"STRING",expression});
				bindlist.add(new String[]{"INTEGER",bytes_received});
				
				ddmLib.execSingleUpdateSQL(connMonitoring, monitoring_column_expression_insert_sql, bindlist);
				
				
			}
			

			if (columnList.size()>0) 
				ddmLib.archiveMonitoringColumns(dm, connMonitoring, proxy_id);

			String par_expression="";
			String par_proxy_session_id="";
			int par_policy_group_id=0;
			long par_ts=0;
			
			ddmLib.getSetMonitoringExpressionList(dm, par_expression,par_proxy_session_id,par_policy_group_id,par_ts,expressionList,ddmLib.MONITORING_ACTION_GET, 100);
			
			if (expressionList.size()==0) 
				try {Thread.sleep(100);} catch(Exception e) {}
			
			for (int i=0;i<expressionList.size();i++) {
				
				String[] arr=expressionList.get(i);
				
				String expression=arr[0];
				String proxy_session_id=arr[1];
				String policy_group_id=arr[2];
				String timestamp=arr[3];
				
				String catalog_name="";
				String schema_name="";
				String object_name="";
				String column_name="";
				String bytes_received="";
				
				id++;
				
				bindlist.clear();
				bindlist.add(new String[]{"LONG",""+id});
				bindlist.add(new String[]{"INTEGER",""+dm.proxy_id});
				bindlist.add(new String[]{"INTEGER",proxy_session_id});
				bindlist.add(new String[]{"INTEGER",policy_group_id});
				bindlist.add(new String[]{"TIMESTAMP",timestamp});
				bindlist.add(new String[]{"STRING",catalog_name});
				bindlist.add(new String[]{"STRING",schema_name});
				bindlist.add(new String[]{"STRING",object_name});
				bindlist.add(new String[]{"STRING",column_name});
				bindlist.add(new String[]{"STRING",expression});
				bindlist.add(new String[]{"INTEGER",bytes_received});


				
				ddmLib.execSingleUpdateSQL(connMonitoring, monitoring_column_expression_insert_sql, bindlist);
				
			}
			
			
			ddmLib.getSetMonitoringReceivedBytesList(dm, (int) 0,par_proxy_session_id,par_policy_group_id,par_ts,receivedBytesList,ddmLib.MONITORING_ACTION_GET, 100);
			
			if (receivedBytesList.size()==0) 
				try {Thread.sleep(100);} catch(Exception e) {}
			
			for (int i=0;i<receivedBytesList.size();i++) {
				
				String[] arr=receivedBytesList.get(i);
				
				String bytes_received=arr[0];
				String proxy_session_id=arr[1];
				String policy_group_id=arr[2];
				String timestamp=arr[3];
				
				String catalog_name="";
				String schema_name="";
				String object_name="";
				String column_name="";
				String expression="";

				id++;
				
				bindlist.clear();
				bindlist.add(new String[]{"LONG",""+id});
				bindlist.add(new String[]{"INTEGER",""+dm.proxy_id});
				bindlist.add(new String[]{"INTEGER",proxy_session_id});
				bindlist.add(new String[]{"INTEGER",policy_group_id});
				bindlist.add(new String[]{"TIMESTAMP",timestamp});
				bindlist.add(new String[]{"STRING",catalog_name});
				bindlist.add(new String[]{"STRING",schema_name});
				bindlist.add(new String[]{"STRING",object_name});
				bindlist.add(new String[]{"STRING",column_name});
				bindlist.add(new String[]{"STRING",expression});
				bindlist.add(new String[]{"INTEGER",bytes_received});


				
				ddmLib.execSingleUpdateSQL(connMonitoring, monitoring_column_expression_insert_sql, bindlist);
				
			}


			
			
		}
		



		ddmLib.closeConn(connMonitoring);
	
	}
	

	//-------------------------------------------------------------------------------
	void clearAndSynchronizeSentBlackList() {
		
		
		String sql="select machine, osuser, dbuser from tdm_proxy_monitoring_blacklist where proxy_id=? and is_deactivated='NO'";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+proxy_id});
		
		ArrayList<String[]> latestBlackListArr=ddmLib.getDbArray(connMonitoring, sql, 10000, bindlist, 0);
		ConcurrentHashMap hmClearCheck = new ConcurrentHashMap();


		for (int i=0;i<latestBlackListArr.size();i++) {
			String[] arr=latestBlackListArr.get(i);
			String machine=arr[0];
			String osuser=arr[1];
			String dbuser=arr[2];
			
			String hmkey="BLACKLIST_FOR_"+machine+"_"+osuser+"_"+dbuser;
			
			hmClearCheck.put(hmkey, true);
			
			if (dm.hmConfig.containsKey(hmkey)) continue;
			dm.mydebug("Adding new blacklist for "+hmkey);
			dm.hmConfig.put(hmkey, true);
		}
		
		//silimesi gereken blacklistleri temizler
		try {
			Iterator it =dm.hmConfig.entrySet().iterator();
			while (it.hasNext()) {
				Map.Entry pair = (Map.Entry)it.next();
				String key=(String) pair.getKey();
				
				if (!key.startsWith("BLACKLIST_FOR_")) continue;
				if (hmClearCheck.containsKey(key)) continue;

				it.remove();
			}
		} catch(Exception e) {
			e.printStackTrace();
		}

		
		try {
			Iterator it =dm.hmCache.entrySet().iterator();
			while (it.hasNext()) {
				Map.Entry pair = (Map.Entry)it.next();
				String key=(String) pair.getKey();
				
				if (!key.startsWith("ALREADY_BLACKLISTED_SESSION_FOR_")) continue;
					
				Long val=(Long) pair.getValue();

				
				if (val>System.currentTimeMillis()-60000) continue;
				it.remove();
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		
	}
	
	
	int FLD_SESSION_ID=0;
	int FLD_VIOLATION_TYPE=1; //COLUMN,EXPRESSION
	int FLD_VIOLATED_CATALOG=2;
	int FLD_VIOLATED_SCHEMA=3;
	int FLD_VIOLATED_OBJECT=4;
	int FLD_VIOLATED_COLUMN=5;
	int FLD_VIOLATED_EXPRESSION=6;
	int FLD_VIOLATION_COUNT=7;
	
	//-------------------------------------------------------------------------------
	void executeMonitoringPolicies(Connection conn) {
		

		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		StringBuilder suspect_sql_for_recv_bytes=new StringBuilder();

		suspect_sql_for_recv_bytes.append("select proxy_session_id, sum(bytes_received) from tdm_proxy_monitoring_columns where proxy_id=? \n");
		suspect_sql_for_recv_bytes.append(" and monitoring_time between ? and ?\n");
		suspect_sql_for_recv_bytes.append(" group by proxy_session_id having sum(bytes_received)>=?");
		
		StringBuilder suspect_sql_for_columns=new StringBuilder();

		suspect_sql_for_columns.append("select proxy_session_id, count(*) from tdm_proxy_monitoring_columns where proxy_id=? \n");
		suspect_sql_for_columns.append(" and catalog_name=? and schema_name=? and object_name=? and column_name=?\n");
		suspect_sql_for_columns.append(" and monitoring_time between ? and ?\n");
		suspect_sql_for_columns.append(" group by proxy_session_id having count(*)>=?");
		
		
		StringBuilder suspect_sql_for_expressions=new StringBuilder();
		suspect_sql_for_expressions.append("select proxy_session_id, count(*) from tdm_proxy_monitoring_columns where proxy_id=? \n");
		suspect_sql_for_expressions.append(" and expression=?  \n");
		suspect_sql_for_expressions.append(" and monitoring_time between ? and ?\n");
		suspect_sql_for_expressions.append(" group by proxy_session_id having count(*)>=?");

		ArrayList<String[]> violationArr=new ArrayList<String[]>();
		

		for (int p=0;p<dm.monitoringPolicies.size();p++) {
			String[] arr=dm.monitoringPolicies.get(p);

			String monitoring_id=arr[0];
			String monitoring_interval=arr[1]; //10
			String monitoring_period=arr[2];  //MINUTES
			String monitoring_threashold=arr[3];
			String monitoring_email=arr[4];
			String monitoring_blacklist=arr[5];
			String monitoring_threashold_recv_bytes=arr[6];
			
			int monitoring_threashold_INT=0;
			try {monitoring_threashold_INT=Integer.parseInt(monitoring_threashold);} catch(Exception e) {continue;}
			
			int monitoring_interval_INT=0;
			try {monitoring_interval_INT=Integer.parseInt(monitoring_interval);} catch(Exception e) {continue;}
			
			long monitoring_threashold_recv_bytes_LONG=0;
			try {monitoring_threashold_recv_bytes_LONG=Long.parseLong(monitoring_threashold_recv_bytes);} catch(Exception e) {monitoring_threashold_recv_bytes_LONG=0;}
			
			int diff=generateDateTimeDiff(monitoring_interval_INT,monitoring_period);
			
			if (diff<=0) continue;
			
			violationArr.clear();
			
			
			long start_of_monitoring_time=System.currentTimeMillis()-diff;
			long end_of_monitoring_time=System.currentTimeMillis();
			
			if (monitoring_threashold_recv_bytes_LONG>0) {
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+dm.proxy_id});
				bindlist.add(new String[]{"TIMESTAMP",""+start_of_monitoring_time});
				bindlist.add(new String[]{"TIMESTAMP",""+end_of_monitoring_time});
				bindlist.add(new String[]{"INTEGER",""+monitoring_threashold_recv_bytes_LONG});
				
				ArrayList<String[]> listOfSuspects=ddmLib.getDbArray(conn, suspect_sql_for_recv_bytes.toString(), Integer.MAX_VALUE, bindlist, 30);
				
				if (listOfSuspects.size()>0) dm.mydebug("Suspected sessions detected  :"+listOfSuspects.size());
				
				for (int s=0;s<listOfSuspects.size();s++) {
					arr=listOfSuspects.get(s);
					String suspected_proxy_session_id=arr[0];
					String received_bytes=arr[1];
					
					//tekrar tekrar ayni session icin blacklist e atmayi engeller
					if (dm.hmCache.containsKey("ALREADY_BLACKLISTED_SESSION_FOR_"+suspected_proxy_session_id)) continue;
					
				
					dm.mydebug("Session ["+suspected_proxy_session_id+"] is detected as suspected with ["+received_bytes+"] bytes received. ");
					dm.hmCache.put("ALREADY_BLACKLISTED_SESSION_FOR_"+suspected_proxy_session_id, System.currentTimeMillis());
					dm.hmCache.put("BLACKLISTED_SESSION_FOR_"+suspected_proxy_session_id, monitoring_blacklist);
					
					String violated_session_id=suspected_proxy_session_id;
					String violation_type="BYTES";
					String violated_catalog="";
					String violated_schema="";
					String violated_object="";
					String violated_column="";
					String violated_expression="";
					String violation_count=received_bytes;
					
					violationArr.add(new String[]{violated_session_id,violation_type,violated_catalog,violated_schema,violated_object,violated_column,violated_expression,violation_count});
				}
			}
			
			ArrayList<String[]> listOfMonitoredColumns=(ArrayList<String[]>) dm.hmConfig.get("MONITORING_COLUMNS_FOR_"+monitoring_id);
			
			if (listOfMonitoredColumns==null || listOfMonitoredColumns.size()==0) continue;
			
			
			
			
			
			for (int r=0;r<listOfMonitoredColumns.size();r++) {
				arr=listOfMonitoredColumns.get(r);
				
				String catalog_name=genLib.nvl(arr[1],"${default}");
				String schema_name=arr[2];
				String object_name=arr[3];
				String column_name=arr[4];
				
				
				
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+dm.proxy_id});
				bindlist.add(new String[]{"STRING",catalog_name});
				bindlist.add(new String[]{"STRING",schema_name});
				bindlist.add(new String[]{"STRING",object_name});
				bindlist.add(new String[]{"STRING",column_name});
				bindlist.add(new String[]{"TIMESTAMP",""+start_of_monitoring_time});
				bindlist.add(new String[]{"TIMESTAMP",""+end_of_monitoring_time});
				bindlist.add(new String[]{"INTEGER",""+monitoring_threashold_INT});
				
				ArrayList<String[]> listOfSuspects=ddmLib.getDbArray(conn, suspect_sql_for_columns.toString(), Integer.MAX_VALUE, bindlist, 30);
				
				if (listOfSuspects.size()>0) dm.mydebug("Suspected sessions detected  :"+listOfSuspects.size());
				
				
				for (int s=0;s<listOfSuspects.size();s++) {
					arr=listOfSuspects.get(s);
					String suspected_proxy_session_id=arr[0];
					String count_of_access=arr[1];
					
					
					
					//tekrar tekrar ayni session icin blacklist e atmayi engeller
					if (dm.hmCache.containsKey("ALREADY_BLACKLISTED_SESSION_FOR_"+suspected_proxy_session_id)) continue;
					
				
					dm.mydebug("Session ["+suspected_proxy_session_id+"] is detected as suspected with ["+count_of_access+"] act. ");
					dm.hmCache.put("ALREADY_BLACKLISTED_SESSION_FOR_"+suspected_proxy_session_id, System.currentTimeMillis());
					dm.hmCache.put("BLACKLISTED_SESSION_FOR_"+suspected_proxy_session_id, monitoring_blacklist);
					
					String violated_session_id=suspected_proxy_session_id;
					String violation_type="COLUMN";
					String violated_catalog=catalog_name;
					String violated_schema=schema_name;
					String violated_object=object_name;
					String violated_column=column_name;
					String violated_expression="";
					String violation_count=count_of_access;
					
					violationArr.add(new String[]{violated_session_id,violation_type,violated_catalog,violated_schema,violated_object,violated_column,violated_expression,violation_count});
					
					
					
				}
				
				
				
			}
			
			
			
			
			ArrayList<String[]> listOfMonitoredExpressions=(ArrayList<String[]>) dm.hmConfig.get("MONITORING_EXPRESSIONS_FOR_"+monitoring_id);
			
			if (listOfMonitoredExpressions==null || listOfMonitoredExpressions.size()==0) continue;
			
			for (int r=0;r<listOfMonitoredExpressions.size();r++) {
				arr=listOfMonitoredExpressions.get(r);
				
				String expression=arr[1];
				
				
				
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+dm.proxy_id});
				bindlist.add(new String[]{"STRING",expression});
				bindlist.add(new String[]{"TIMESTAMP",""+start_of_monitoring_time});
				bindlist.add(new String[]{"TIMESTAMP",""+end_of_monitoring_time});
				bindlist.add(new String[]{"INTEGER",""+monitoring_threashold_INT});
				
				ArrayList<String[]> listOfSuspects=ddmLib.getDbArray(conn, suspect_sql_for_expressions.toString(), Integer.MAX_VALUE, bindlist, 30);
				
				if (listOfSuspects.size()>0) dm.mydebug("Suspected sessions detected  :"+listOfSuspects.size());
				
				
				for (int s=0;s<listOfSuspects.size();s++) {
					arr=listOfSuspects.get(s);
					String suspected_proxy_session_id=arr[0];
					String count_of_access=arr[1];
					
					dm.mydebug("Session ["+suspected_proxy_session_id+"] is detected as suspected with ["+count_of_access+"] act. ");
					
					
					//tekrar tekrar ayni session icin blacklist e atmayi engeller
					if (dm.hmCache.containsKey("ALREADY_BLACKLISTED_SESSION_FOR_"+suspected_proxy_session_id)) continue;
					
				
					dm.mydebug("Session ["+suspected_proxy_session_id+"] is detected as suspected with ["+count_of_access+"] act. ");
					dm.hmCache.put("ALREADY_BLACKLISTED_SESSION_FOR_"+suspected_proxy_session_id, System.currentTimeMillis());
					dm.hmCache.put("BLACKLISTED_SESSION_FOR_"+suspected_proxy_session_id, monitoring_blacklist);


					String violated_session_id=suspected_proxy_session_id;
					String violation_type="COLUMN";
					String violated_catalog="";
					String violated_schema="";
					String violated_object="";
					String violated_column="";
					String violated_expression="";
					String violation_count=count_of_access;
					
					violationArr.add(new String[]{violated_session_id,violation_type,violated_catalog,violated_schema,violated_object,violated_column,violated_expression,violation_count});
					
				
					
				}
				
				
			}
			
			
			if (violationArr.size()>0) {

				Long last_email_sent_ts=(Long) dm.hmCache.get("LAST_EMAIL_SENT_TS_FOR_MONITORING_"+monitoring_id);
				if (last_email_sent_ts==null || System.currentTimeMillis()>(last_email_sent_ts) ) {
					dm.hmCache.put("LAST_EMAIL_SENT_TS_FOR_MONITORING_"+monitoring_id,System.currentTimeMillis());
					addMonitoringEmailTask(monitoring_id,new StringBuilder(monitoring_email), violationArr);
				}
			}
			
			
		}
	}
	
	//------------------------------------------------------------------------------------
	void addMonitoringEmailTask(String monitoring_id, StringBuilder to_email, ArrayList<String[]> violationArr) {
		dm.mydebug("----------------------------------------------------------------");
		
		dm.mydebug("addMonitoringEmailTask  :"+monitoring_id);
		StringBuilder sbEmail=new StringBuilder();
		StringBuilder sbViolation=new StringBuilder();
		
		String sql_session_info="select session_info from tdm_proxy_session where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		
		String sql_monitoring="select monitoring_name, monitoring_interval, monitoring_period, monitoring_threashold, monitoring_threashold_recv_bytes "+
								" from tdm_proxy_monitoring where id=? ";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",monitoring_id});
		ArrayList<String[]> arrMon=ddmLib.getDbArray(connMonitoring, sql_monitoring, 1, bindlist, 0);
		
		if (arrMon==null || arrMon.size()==0) return;
		String[] arr=arrMon.get(0);
		
		String monitoring_name=arr[0];
		String monitoring_interval=arr[1];
		String monitoring_period=arr[2];
		String monitoring_threashold=arr[3];
		String monitoring_threashold_recv_bytes=arr[4];
		
		sbViolation.append("<h1>MONITORING INFO :</h1>");
		sbViolation.append("<table border=2 width=\"100%\">");
		
		sbViolation.append("<tr>");
		sbViolation.append("<td><b> Monitoring Name :</b></td>");
		sbViolation.append("<td><b> Check Period :</b></td>");
		sbViolation.append("<td><b> Treshold value :</b></td>");
		sbViolation.append("<td><b> Treshold Received Bytes :</b></td>");
		sbViolation.append("</tr>");
		
		sbViolation.append("<tr>");
		sbViolation.append("<td>"+monitoring_name+"</td>");
		sbViolation.append("<td>"+monitoring_interval+" "+monitoring_period+"</td>");
		sbViolation.append("<td>"+monitoring_threashold+"</td>");
		sbViolation.append("<td>"+monitoring_threashold_recv_bytes+"</td>");
		sbViolation.append("</tr>");
		
		sbViolation.append("</table>");
		
		sbViolation.append("<hr>");
		
		sbViolation.append("<h1>VIOLATION LIST :</h1>");
		sbViolation.append("<table border=1 width=\"100%\">");
		
		sbViolation.append("<tr bgcolor=lightgreen>");
		sbViolation.append("<td><b>#</b></td>");
		sbViolation.append("<td><b>Session Id</b></td>");
		sbViolation.append("<td><b>Machine</b></td>");
		sbViolation.append("<td><b>OS User</b></td>");
		sbViolation.append("<td><b>DB User</b></td>");
		sbViolation.append("<td><b>Type</b></td>");
		sbViolation.append("<td><b>Violated Rule</b></td>");
		sbViolation.append("<td><b>Violated Value</b></td>");
		sbViolation.append("</tr>");
		

		for (int i=0;i<violationArr.size();i++) {
			arr=violationArr.get(i);
			
			String violated_session_id=arr[FLD_SESSION_ID];
			String violation_type=arr[FLD_VIOLATION_TYPE];
			String violated_catalog=arr[FLD_VIOLATED_CATALOG];
			String violated_schema=arr[FLD_VIOLATED_SCHEMA];
			String violated_object=arr[FLD_VIOLATED_OBJECT];
			String violated_column=arr[FLD_VIOLATED_COLUMN];
			String violated_expression=arr[FLD_VIOLATED_EXPRESSION];
			String violation_value=arr[FLD_VIOLATION_COUNT];
			
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",violated_session_id});
			
			String session_info="";
			try{session_info=ddmLib.getDbArray(connMonitoring, sql_session_info, 1, bindlist, 0).get(0)[0];} catch(Exception e) {}
			
			ArrayList<String[]> params=ddmLib.getSessionVariablesAsArrayList(session_info);
			String machine=genLib.nvl(ddmLib.getSessionKey(params, "MACHINE"),ddmLib.getSessionKey(params, "TERMINAL"));
			String osuser=ddmLib.getSessionKey(params, "OSUSER");
			String dbuser=ddmLib.getSessionKey(params, "CURRENT_USER");
			
			String rule=violated_expression;
			if (violation_type.equals("COLUMN")) rule=violated_catalog+"."+violated_schema+"."+violated_object+"."+violated_column;
			else if (violation_type.equals("BYTES")) rule="Received Bytes";

			if (i % 2==0)
				sbViolation.append("<tr  bgcolor=white>");
			else 
				sbViolation.append("<tr bgcolor=lightgreen>");
			sbViolation.append("<td align=right>"+(i+1)+"</td>");
			sbViolation.append("<td align=right>"+violated_session_id+"</td>");
			sbViolation.append("<td>"+machine+"</td>");
			sbViolation.append("<td>"+osuser+"</td>");
			sbViolation.append("<td>"+dbuser+"</td>");
			sbViolation.append("<td>"+violation_type+"</td>");
			sbViolation.append("<td>"+rule+"</td>");
			sbViolation.append("<td align=right>"+violation_value+"</td>");
			sbViolation.append("</tr>");
		}
		
		sbViolation.append("</table>");
		
		
		sbEmail.append("<html>");
		sbEmail.append(sbViolation.toString());
		sbEmail.append("</html>");
		 
		ddmLib.setGetViolationEmailList(dm, new StringBuilder(monitoring_id), sbEmail, to_email, ddmLib.MONITORING_ACTION_SET); 
		


	} 
	//------------------------------------------------------------------------------------
	int generateDateTimeDiff(int interval, String period) {
		//SECONDS
		//MINUTES
		//HOURS
		if (interval<=0) return 0;
		
		if (period.contains("SECOND")) {
			return interval*1000;
		} else if (period.contains("MINUTE")) {
			return interval*60*1000;
		} else if (period.contains("HOUR")) {
			return interval*60*60*1000;
		}
		return 0;
	}
	
	
}
