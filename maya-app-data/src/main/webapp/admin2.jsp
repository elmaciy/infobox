<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">



<%@include file="header2.jsp"%> 

<%

roleRestrict(session,response,"ADMIN");
request.setCharacterEncoding("utf-8");


Connection conn=getconn();


String sql="";

String action=nvl(request.getParameter("action"),"-");
String p_tab=nvl(request.getParameter("tab"),nvl((String) session.getAttribute("currtab"),"parameters"));

session.setAttribute("currtab", p_tab);

ArrayList<String[]> emptybinding=new ArrayList<String[]>();

boolean show_script_editor=false;
boolean edit_field_names=false;

if (action.equals("script_rule") || action.equals("field_names")) {
	show_script_editor=true;
	if (action.equals("field_names")) edit_field_names=true;
	action="-";
}

if (!nvl(request.getParameter("bt_save_script"),"-").equals("-")) {
	String v_rule_id=nvl(request.getParameter("script_rule_id"),"0");
	String v_rule_type=nvl(request.getParameter("script_rule_type"),"MATCHES");
	String fname="regex";
	if (v_rule_type.equals("JS")) fname="script";
	if (v_rule_type.equals("FIELDNAME")) fname="field_names";

	String v_script=nvl(request.getParameter("rule_script"),"");
	
	if (!v_rule_id.equals("0")) {
		sql="update tdm_discovery_rule set "+fname+"=? where id="+v_rule_id;
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.add(new String[]{"STRING",v_script});

		execDBConf(conn, sql, bindlist);
	}
}



if (!action.equals("-")) {
	

	
	if (action.equals("add_rule")) {
			sql="insert into tdm_discovery_rule (description,is_valid) values ('New Rule','YES')";
			execDBConf(conn, sql, emptybinding);
	} //add user
	
	
	if (action.equals("add_db")) {
		sql="insert into tdm_ref (ref_type,ref_desc) values ('DB_TYPE','NEW DB')";
		execDBConf(conn, sql, emptybinding);
	} //add db

	
	
	if (action.equals("delete_rule")) {
		String del_rule_id=nvl(request.getParameter("rule_id"),"-1");
			
		sql="delete from tdm_discovery_rule where id="+del_rule_id;
		execDBConf(conn, sql, emptybinding);
		
	} // delete user
	
	
	if (action.equals("delete_db")) {
		String del_db_id=nvl(request.getParameter("db_id"),"-1");
			
		sql="delete from tdm_ref where id="+del_db_id;
		execDBConf(conn, sql, emptybinding);
		
	} // delete user

	
	if (action.equals("update_rule")) {
		String rule_id=nvl(request.getParameter("rule_id"),"0");
		
		String rule_target_id=nvl(request.getParameter("rule_target_id"),"0");
		String rule_type=nvl(request.getParameter("rule_type"),"MATCHES");
		String rule_description=nvl(request.getParameter("rule_description"),"");
		String is_valid=nvl(request.getParameter("is_valid"),"YES");
		String rule_weight=nvl(request.getParameter("rule_weight"),"10");
		
			sql="update tdm_discovery_rule set "+
					"discovery_target_id=?,rule_type=?,description=?,is_valid=?, rule_weight=? " +
					" where id="+rule_id;

				ArrayList<String[]> bindlist=new ArrayList<String[]>();
			
				bindlist.add(new String[]{"INTEGER",""+rule_target_id});
				bindlist.add(new String[]{"STRING",rule_type});
				bindlist.add(new String[]{"STRING",rule_description});
				bindlist.add(new String[]{"STRING",is_valid});
				bindlist.add(new String[]{"INTEGER",rule_weight});

				execDBConf(conn, sql, bindlist);
	} // update rule
	
	
	
	if (action.equals("update_db")) {
		String del_db_id=nvl(request.getParameter("db_id"),"-1");
		
		String db_name=request.getParameter("db_name");
		String short_code=request.getParameter("short_code");
		String db_driver=request.getParameter("db_driver");
		String url_template=request.getParameter("url_template");
		String test_sql=request.getParameter("test_sql");
		String partition_sql=request.getParameter("partition_sql");
		String rowid_field=request.getParameter("rowid_field");
		


			sql="update tdm_ref set "+
					"ref_desc=?, flexval1=?, ref_name=?, flexval2=?, flexval3=? " +
					" where id="+del_db_id;

				ArrayList<String[]> bindlist=new ArrayList<String[]>();
			
				bindlist.add(new String[]{"STRING",db_name});
				bindlist.add(new String[]{"STRING",short_code});
				bindlist.add(new String[]{"STRING",db_driver});
				bindlist.add(new String[]{"STRING",test_sql+"|"+url_template+"|"+partition_sql});
				bindlist.add(new String[]{"STRING",rowid_field});

				execDBConf(conn, sql, bindlist);
	} // update rule	

	
	
	response.sendRedirect("admin2.jsp");

	
} //if (!action.equals("-")) {

StringBuilder sbEmailErr=new StringBuilder();
boolean is_email_ok=false;

if (!nvl(request.getParameter("bt_send_mail"),"-").equals("-")) {
	is_email_ok=testmail(conn,sbEmailErr);  
	session.setAttribute("EMAIL_TEST_LOGS",sbEmailErr.toString());
} else {
	sbEmailErr.setLength(0);
	sbEmailErr.append(nvl((String) session.getAttribute("EMAIL_TEST_LOGS"),"")); 
}



String p_javax_email_props=getParamByName(conn, "JAVAX_EMAIL_PROPERTIES");
String p_javax_email_address=getParamByName(conn, "JAVAX_EMAIL_ADDRESS");
String p_javax_email_username=getParamByName(conn, "JAVAX_EMAIL_USERNAME");
String p_javax_email_password=decode(getParamByName(conn, "JAVAX_EMAIL_PASSWORD"));
String p_javax_notification_period=nvl(getParamByName(conn, "JAVAX_MAIL_NOTIFICATION_PERIOD"),"10");
String p_tdm_process_home=getParamByName(conn, "TDM_PROCESS_HOME");
String p_config_username=getParamByName(conn, "CONFIG_USERNAME");
String p_config_password=decode(getParamByName(conn, "CONFIG_PASSWORD"));
String p_ldap_props=getParamByName(conn, "LDAP_PROPERTIES");
String p_authentication_type=nvl(getParamByName(conn, "AUTHENTICATION_METHOD"),"LOCAL");
String p_discovery_sample_size=nvl(getParamByName(conn, "DISCOVERY_SAMPLE_SIZE"),"1000");
String p_discovery_thread_count=nvl(getParamByName(conn, "DISCOVERY_THREAD_COUNT"),"10");
String p_discovery_schemas_to_skip=nvl(getParamByName(conn, "DISCOVERY_SCHEMAS_TO_SKIP"),"");
String p_discovery_fields_to_skip=nvl(getParamByName(conn, "DISCOVERY_FIELDS_TO_SKIP"),"");
String p_max_process_count=nvl(getParamByName(conn, "MAX_PROCESS_COUNT"),"100");
String p_max_table_count=nvl(getParamByName(conn, "MAX_TABLE_COUNT"),"1000");
String p_masking_keep_period=nvl(getParamByName(conn, "MASKING_KEEP_PERIOD"),"30");
String p_process_start_command_template=nvl(getParamByName(conn, "PROCESS_START_COMMAND_TEMPLATE"),"cmd /c start XXX");
String p_dynamic_client_iddle_timeout=nvl(getParamByName(conn, "DYNAMIC_CLIENT_IDDLE_TIMEOUT"),"120000");
String p_paralellism_count=nvl(getParamByName(conn, "PARALLELISM_COUNT"),"8");
String p_ddm_log_statement=nvl(getParamByName(conn, "DDM_LOG_STATEMENT"),"NO");
String p_ddm_calendar_id=nvl(getParamByName(conn, "DDM_CALENDAR_ID"),"0");
String p_ddm_session_validation_id=nvl(getParamByName(conn, "DDM_SESSION_VALIDATION_ID"),"0");
String p_ddm_configuration_reload_interval=nvl(getParamByName(conn, "DDM_CONFIGURATION_RELOAD_INTERVAL"),"60");





if (!nvl(request.getParameter("btsave"),"-").equals("-")) {
	
	
	p_javax_email_props=nvl(request.getParameter("JAVAX_EMAIL_PROPERTIES"),"").trim();	
	p_javax_email_address=nvl(request.getParameter("JAVAX_EMAIL_ADDRESS"),"").trim();
	p_javax_email_username=nvl(request.getParameter("JAVAX_EMAIL_USERNAME"),"").trim();	
	p_javax_email_password=nvl(request.getParameter("JAVAX_EMAIL_PASSWORD"),"");	
	p_javax_notification_period=nvl(request.getParameter("JAVAX_MAIL_NOTIFICATION_PERIOD"),"10");
	p_tdm_process_home=nvl(request.getParameter("TDM_PROCESS_HOME"),"");
	p_config_username=nvl(request.getParameter("CONFIG_USERNAME"),"");
	p_config_password=nvl(request.getParameter("CONFIG_PASSWORD"),"");
	p_ldap_props=nvl(request.getParameter("LDAP_PROPERTIES"),"");
	p_authentication_type=nvl(request.getParameter("AUTHENTICATION_METHOD"),"LOCAL");
	p_discovery_sample_size=nvl(request.getParameter("DISCOVERY_SAMPLE_SIZE"),"1000");	
	p_discovery_thread_count=nvl(request.getParameter("DISCOVERY_THREAD_COUNT"),"10");	
	p_discovery_schemas_to_skip=nvl(request.getParameter("DISCOVERY_SCHEMAS_TO_SKIP"),"");	
	p_discovery_fields_to_skip=nvl(request.getParameter("DISCOVERY_FIELDS_TO_SKIP"),"");	
	p_max_process_count=nvl(request.getParameter("MAX_PROCESS_COUNT"),"100");
	p_max_table_count=nvl(request.getParameter("MAX_TABLE_COUNT"),"1000");	
	p_masking_keep_period=nvl(request.getParameter("MASKING_KEEP_PERIOD"),"30");	
	p_process_start_command_template=nvl(request.getParameter("PROCESS_START_COMMAND_TEMPLATE"),"cmd /c start XXX");
	p_dynamic_client_iddle_timeout=nvl(request.getParameter("DYNAMIC_CLIENT_IDDLE_TIMEOUT"),"120000");
	p_paralellism_count=nvl(request.getParameter("PARALLELISM_COUNT"),"8");
	p_ddm_log_statement=nvl(request.getParameter("DDM_LOG_STATEMENT"),"NO");
	p_ddm_calendar_id=nvl(request.getParameter("DDM_CALENDAR_ID"),"0");
	p_ddm_session_validation_id=nvl(request.getParameter("DDM_SESSION_VALIDATION_ID"),"0");
	p_ddm_configuration_reload_interval=nvl(request.getParameter("DDM_CONFIGURATION_RELOAD_INTERVAL"),"60");

	//JAVAX_EMAIL_PROPERTIES
	setParamByName(conn, "JAVAX_EMAIL_PROPERTIES" , p_javax_email_props);
	
	
	//JAVAX_EMAIL_ADDRESS
	setParamByName(conn, "JAVAX_EMAIL_ADDRESS" , p_javax_email_address);
	

	//JAVAX_EMAIL_USERNAME
	setParamByName(conn, "JAVAX_EMAIL_USERNAME" , p_javax_email_username);
	
	
	//JAVAX_EMAIL_PASSWORD
	setParamByName(conn, "JAVAX_EMAIL_PASSWORD" , encode(p_javax_email_password));
	
	
	//JAVAX_MAIL_NOTIFICATION_PERIOD
	int not_period=10;
	try {
		not_period=Integer.parseInt(p_javax_notification_period);
	} catch(Exception e) {
		not_period=10;
	}
	
	if(not_period>120) not_period=120;
	if (not_period<10) not_period=10;

	setParamByName(conn, "JAVAX_MAIL_NOTIFICATION_PERIOD" , ""+not_period);
	

	//TDM_PROCESS_HOME
	setParamByName(conn, "TDM_PROCESS_HOME" , p_tdm_process_home);
	
	//PROCESS_START_COMMAND_TEMPLATE
	setParamByName(conn, "PROCESS_START_COMMAND_TEMPLATE" , p_process_start_command_template);
	
	//CONFIG_USERNAME / CONFIG_PASSWORD
	setParamByName(conn, "CONFIG_USERNAME" , p_config_username);
	setParamByName(conn, "CONFIG_PASSWORD" , encode(p_config_password));

	//AUTHENTICATION_METHOD
	setParamByName(conn, "AUTHENTICATION_METHOD" , p_authentication_type);
	
	//LDAP_PROPERTIES
	setParamByName(conn, "LDAP_PROPERTIES" , p_ldap_props);
	
	//DISCOVERY_SAMPLE_SIZE
	int sample_size=0;
	try {
		sample_size=Integer.parseInt(p_discovery_sample_size);
	} catch(Exception e) {
		sample_size=1000;
	}
	
	if(sample_size>10000) sample_size=10000;
	if (sample_size<100) sample_size=100;
	
	setParamByName(conn, "DISCOVERY_SAMPLE_SIZE" , ""+sample_size);
	
	
	
	//DISCOVERY_THREAD_COUNT
	int thread_count=5;
	try {
		thread_count=Integer.parseInt(p_discovery_thread_count);
	} catch(Exception e) {
		thread_count=10;
	}
	
	if(thread_count>100) thread_count=100;
	if (thread_count<1) thread_count=1;
	
	setParamByName(conn, "DISCOVERY_THREAD_COUNT" , ""+thread_count);
	
	//DISCOVERY_SCHEMAS_TO_SKIP
	setParamByName(conn, "DISCOVERY_SCHEMAS_TO_SKIP" , p_discovery_schemas_to_skip);
	
	//DISCOVERY_FIELDS_TO_SKIP
	setParamByName(conn, "DISCOVERY_FIELDS_TO_SKIP" , p_discovery_fields_to_skip);
	
	//MAX_TABLE_COUNT
	int max_table_count=0;
	try {
		max_table_count=Integer.parseInt(p_max_table_count);
	} catch(Exception e) {
		max_table_count=1000;
	}
	
	if(max_table_count>20000) max_table_count=20000;
	if (max_table_count<1000) max_table_count=1000;
	
	setParamByName(conn, "MAX_TABLE_COUNT" , ""+max_table_count);


	//MAX_TABLE_COUNT
	int masking_keep_period=0;
	try {
		masking_keep_period=Integer.parseInt(p_masking_keep_period);
	} catch(Exception e) {
		masking_keep_period=30;
	}
	
	if(masking_keep_period>360) masking_keep_period=360;
	if (masking_keep_period<10) masking_keep_period=10;
	
	setParamByName(conn, "MASKING_KEEP_PERIOD" , ""+masking_keep_period);
	
	
	
	//MAX_PROCESS_COUNT
	int process_count=0;
	try {
		process_count=Integer.parseInt(p_max_process_count);
	} catch(Exception e) {
		process_count=100;
	}
	
	if(process_count>1000) process_count=1000;
	if (process_count<0) process_count=0;
	
	setParamByName(conn, "MAX_PROCESS_COUNT" , ""+process_count);
	
	
	//DYNAMIC_CLIENT_IDDLE_TIMEOUT
	int int_dynamic_client_iddle_timeout=0;
	try {
		int_dynamic_client_iddle_timeout=Integer.parseInt(p_dynamic_client_iddle_timeout);
	} catch(Exception e) {
		int_dynamic_client_iddle_timeout=120000;
	}
	
	if(int_dynamic_client_iddle_timeout>600000) int_dynamic_client_iddle_timeout=600000;
	if (int_dynamic_client_iddle_timeout<60000) int_dynamic_client_iddle_timeout=60000;
	
	setParamByName(conn, "DYNAMIC_CLIENT_IDDLE_TIMEOUT" , ""+int_dynamic_client_iddle_timeout);
	
	
	
	//DDM_CONFIGURATION_RELOAD_INTERVAL	
	int int_p_ddm_configuration_reload_interval=0;
	try {
		int_p_ddm_configuration_reload_interval=Integer.parseInt(p_ddm_configuration_reload_interval);
	} catch(Exception e) {
		int_p_ddm_configuration_reload_interval=60;
	}
	
	if(int_p_ddm_configuration_reload_interval>720) int_p_ddm_configuration_reload_interval=720;
	if (int_p_ddm_configuration_reload_interval<0) int_p_ddm_configuration_reload_interval=0;
	
	setParamByName(conn, "DDM_CONFIGURATION_RELOAD_INTERVAL" , ""+int_p_ddm_configuration_reload_interval);
		
		
		
		//DDM_LOG_STATEMENT
		setParamByName(conn, "DDM_LOG_STATEMENT" , p_ddm_log_statement);
		
		//DDM_CALENDAR_ID
		setParamByName(conn, "DDM_CALENDAR_ID" , p_ddm_calendar_id);
		
		//DDM_LOG_STATEMENT
		setParamByName(conn, "DDM_SESSION_VALIDATION_ID" , p_ddm_session_validation_id);
		
		//PARALLELISM_COUNT
		int parallelism_count=0;
		try {
			parallelism_count=Integer.parseInt(p_paralellism_count);
		} catch(Exception e) {
			parallelism_count=8;
		}
		
		if(parallelism_count>64) parallelism_count=64;
		if (parallelism_count<2) parallelism_count=2;
		
		setParamByName(conn, "PARALLELISM_COUNT" , ""+parallelism_count);
		

	response.sendRedirect("admin2.jsp");
}



%>

  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>TDM</title>

    <link href="style/bootstrap/css/bootstrap.css" rel="stylesheet">
    <link href="style/bootstrap/css/fileinput.css" rel="stylesheet">
     
    <script src="style/bootstrap/js/jquery-1.11.1.js"></script>
    <script src="style/bootstrap/js/bootstrap.js"></script>
    <script src="style/bootstrap/js/bootbox.js"></script>
    <script src="style/bootstrap/js/fileinput.js"></script>
    <script src="jslib/tdmapp.js"></script>
	<script src="jslib.js" type="text/javascript"></script>
  </head>



<body style="background: url(img/bodyback.jpg); background-size:cover; ">

<%=printHeader(request,session)%>
<div class="container-fluid">


<div class="panel panel-primary">
<div class="panel-heading">
    Administration
</div>
<div class="panel-body">

<table border=1 cellspacing=4 cellpadding=0 width=100%>
<tr>
<td nowrap valign=top width=15%>


<!--  MENU AT LEFT SIZE -->
<%
ArrayList<String[]> menuList=new ArrayList<String[]>();
menuList.add(new String[]{"General","parameters"});
menuList.add(new String[]{"Discovery","discovery"});
menuList.add(new String[]{"DB List","dblist"});

for (int i=0;i<menuList.size();i++) {
	String m_title=menuList.get(i)[0];
	String m_tab=menuList.get(i)[1];
	if (p_tab.equals(m_tab)) {
		%>
		<li style="background-color:lightgray;"><h4><b><font color=blue><%=m_title %></font></b></h4></li>
		<%
	} 
	else {
		%>
		<li><h4><a href="admin2.jsp?tab=<%=m_tab%>"><%=m_title %></a></h4></li>
		<%
	}
}

%>
	

</td>


<td width=100% valign=top align=center>

<% if (p_tab.equals("parameters")) {%>
<form name=fmain>
	<table class="table table-bordered table-striped table-hover" style="width: 80%">
	
	
	<tr>
	<td align=right>
	<b>Notification Email Address  :</b>
	<br>
	Use <b><big>";"</big></b> as seperator for multiple mail addresses.<br>
	max 5 address will be used
	</td>
	
	<td>
		<input type=text name="JAVAX_EMAIL_ADDRESS" size=50 maxlength=1000 value="<%=p_javax_email_address %>">
		<br>
		<input type=submit name=bt_send_mail value="Send Test Mail">
		
		<%if (sbEmailErr.length()>0) {%>
		<br> Last Email Test Results : <br>
		<textarea readonly rows=3 style="width:100%;"><%=clearHtml(nvl(sbEmailErr.toString(),"EMAIL WAS SUCCESSFULY SENT")) %></textarea>
		<%}%>
	</td>
	
	</tr>
	
	

	
	
	
	<tr>
	<td align=right nowrap>
	<b>Javax.Email properties :</b><br>
	<a href="http://connector.sourceforge.net/doc-files/Properties.html" target="newW">[See JavaxEmail SMTP Props Here]</a>
	<br>
	<font size=2>
	<b>Sample for gmail</b> : <br>
	mail.smtp.auth=true<br>
	mail.smtp.starttls.enable=true<br>
	mail.smtp.host=smtp.gmail.com<br>
	mail.smtp.port=587
	</font>
	</td>
	
	<td>
		<textarea name="JAVAX_EMAIL_PROPERTIES" rows=8 cols=50 style="font-family:Courier New, Courier, monospace;"><%=p_javax_email_props %></textarea>
	</td>
	
	</tr>
	
	
	<tr>
	<td align=right>
	<b>Secure SMTP Username   :</b>
	</td>
	
	<td>
		<input type=text name="JAVAX_EMAIL_USERNAME" size=50 maxlength=200 value="<%=p_javax_email_username %>">
	</td>
	
	</tr>
	
	<tr>
	<td align=right>
	<b>Secure SMTP Password     :</b>
	</td>
	
	<td>
		<input type=password name="JAVAX_EMAIL_PASSWORD" size=20 maxlength=200 value="<%=p_javax_email_password %>">
	</td>
	
	</tr>
	
	
	<tr>
	<td align=right>
	<b>Mail Notification Period [10..120] :</b>
	</td>
	
	<td>
		<input type=text name="JAVAX_MAIL_NOTIFICATION_PERIOD" size=4 maxlength=3 value="<%=p_javax_notification_period %>">
	</td>
	
	</tr>
	
	
	
	
	
	<tr>
	<td align=right>
	<b>TDM mysql username and password :</b>
	</td>
	
	<td>
		<input type=text name="CONFIG_USERNAME" size=15 maxlength=15 value="<%=p_config_username %>">
		<input type=password name="CONFIG_PASSWORD" size=15 maxlength=15 value="<%=p_config_password %>">
	</td>
	
	</tr>
	
	
	
	<tr>
	<td align=right>
	<b>TDM Process System Home Directory :</b>
	</td>
	
	<td>
		<input type=text name="TDM_PROCESS_HOME" size=50 maxlength=200 value="<%=p_tdm_process_home %>">
	</td>
	
	</tr>
	
	
	<tr>
	<td align=right>
	<b>Process Start Command Template :</b>
	<br>  Windows sample : <b><font color=blue>cmd /c start XXX</font></b>
	<br> Linux sample : <b><font color=blue>bash /data/tdmuser/TDM/XXX 1 &</font></b>
	</td>
	
	<td>
		<input type=text name="PROCESS_START_COMMAND_TEMPLATE" size=30 maxlength=200 value="<%=p_process_start_command_template %>">
		
	</td>
	
	</tr>
	
	<tr>
	<td align=right>
	<b>Authentication Method  :</b>
	</td>
	
	<td>
	<%
	sql="select 'LOCAL' a, 'Local' b from dual union all select 'LDAP' a, 'Ldap' b from dual";
	
	out.println(makeCombo(conn, sql, "AUTHENTICATION_METHOD", "", p_authentication_type, 100));
	%>
	</td>
	
	</tr>
	
	
	<tr>
	<td align=right nowrap>
	<b>Ldap Properties :</b><br>
	<a href="http://docs.oracle.com/javase/jndi/tutorial/ldap/security/ldap.html" target="newW">[See LDAP Props Here]</a>
	<br><b>Sample </b> : <br>
	<font size=2>
		<b>java.naming.factory.initial</b>=com.sun.jndi.ldap.LdapCtxFactory<br>
		<b>java.naming.provider.url</b>=ldap://localhost:389/o=JNDITutorial<br>
		<b>java.naming.security.authentication</b>=simple<br>
		<b>java.naming.security.principal</b>=uid=<font color=red>%UID%</font>,ou=users,ou=system<br>
	</font>	
	</td>
	
	<td>
		<textarea name="LDAP_PROPERTIES" rows=8 cols=50 style="font-family:Courier New, Courier, monospace;"><%=p_ldap_props %></textarea>
	</td>
	
	</tr>
	
	
	<tr>
	<td align=right>
	<b>Discovery Default Sample Size [100..10,000] :</b>
	</td>
	
	<td>
		<input type=text name="DISCOVERY_SAMPLE_SIZE" size=4 maxlength=5 value="<%=p_discovery_sample_size %>">
	</td>
	
	</tr>
	
	
	<tr>
	<td align=right>
	<b>Discovery Thread Count[1..100] :</b>
	</td>
	
	<td>
		<input type=text name="DISCOVERY_THREAD_COUNT" size=4 maxlength=3 value="<%=p_discovery_thread_count %>">
	</td>
	
	</tr>
	
	<tr>
	<td align=right>
	<b>Discovery : Schema Names To Skip :</b>
	<br>
	Enter each schema name with line break.<br>
	<t>[Non Case sensitive]<t>
	</td>
	
	<td>
		<textarea name="DISCOVERY_SCHEMAS_TO_SKIP" rows="3" cols="50" style="font-family:Courier New, Courier, monospace; "><%=p_discovery_schemas_to_skip %></textarea>
	</td>
	
	</tr>
	
	<tr>
	<td align=right>
	<b>Discovery : Fields To Skip :</b>
	<br>
	Enter each field name with line break.<br>
	<t>[Non Case sensitive]<t><br>
	<t>[<b><font color=green>RegEx is ok</font></b>]
	</td>
	
	<td>
		<textarea name="DISCOVERY_FIELDS_TO_SKIP" rows="3" cols="50" style="font-family:Courier New, Courier, monospace; "><%=p_discovery_fields_to_skip %></textarea>
	</td>
	
	</tr>
	
	
	
	
	<tr>
	<td align=right>
	<b>Maximum Process Count (Master, Worker) [0..1000]:</b>
	</td>
	
	<td>
		<input type=text name="MAX_PROCESS_COUNT" size=4 maxlength=5 value="<%=p_max_process_count %>">
	</td>
	
	</tr>
	
	
	<tr>
	<td align=right>
	<b>Max Tables in design [1000..20,000] :</b>
	</td>
	
	<td>
		<input type=text name="MAX_TABLE_COUNT" size=8 maxlength=7 value="<%=p_max_table_count %>">
	</td>
	
	</tr>
	
	
	<tr>
	<td align=right>
	<b>Masking Tasks Keep Period (Days) [10..360] :</b>
	</td>
	
	<td>
		<input type=text name="MASKING_KEEP_PERIOD" size=8 maxlength=7 value="<%=p_masking_keep_period %>">
	</td>
	
	</tr>
	
	
	
	<tr>
	<td align=right>
	<b>DDM Client Iddle Timeout (msecs) [60,000..600,000] :</b>
		<br>
		1 sec=1000 msecs	
	</td>
	
	<td>
		<input type=text name="DYNAMIC_CLIENT_IDDLE_TIMEOUT" size=8 maxlength=8 value="<%=p_dynamic_client_iddle_timeout %>">
	</td>
	
	</tr>
	
	
	<tr>
	<td align=right>
	<b>DDM Configuration Reload Interval (minutes)  [0..720] :</b>
	<br> 0 : means never reload.
	</td>
	
	<td>
		<input type=text name="DDM_CONFIGURATION_RELOAD_INTERVAL" size=8 maxlength=8 value="<%=p_ddm_configuration_reload_interval %>">

	</td>
	
	</tr>
	
	<tr>
	<td align=right>
	<b>DDM Log Statements   :</b>
	</td>
	
	<td>
	<%
	sql="select 'YES' a, 'Yes' b from dual union all select 'NO' a, 'No' b from dual";
	
	out.println(makeCombo(conn, sql, "DDM_LOG_STATEMENT", "size=1", p_ddm_log_statement, 100));
	%>
	</td>
	
	</tr>
	
	<tr>
	<td align=right>
	<b>DDM Calendar   :</b>
	</td>
	
	<td>
	<%
	sql="select id, calendar_name from tdm_proxy_calendar order by 2";
	
	out.println(makeCombo(conn, sql, "DDM_CALENDAR_ID", "", p_ddm_calendar_id, 300));
	%>
	</td>
	
	</tr>
	
	
	<tr>
	<td align=right>
	<b>DDM Session Validation   :</b>
	</td>
	
	<td>
	<%
	sql="select id, session_validation_name from tdm_proxy_session_validation order by 2";
	
	out.println(makeCombo(conn, sql, "DDM_SESSION_VALIDATION_ID", "", p_ddm_session_validation_id, 300));
	%>
	</td>
	
	</tr>
	
	<tr>
	<td align=right>
	<b>Parallelism Count for DB :</b>
	</td>
	
	<td>
		<input type=text name="PARALLELISM_COUNT" size=8 maxlength=8 value="<%=p_paralellism_count %>">
	</td>
	
	</tr>
	
	
	<tr>
	<td align=center colspan=2>
	<input type=hidden name=btsave value="SAVE">
	<input type="button" value="Save Parameters" onclick="document.fmain.submit()" class="btn btn-success btn-sm">
	</td>
	</tr>
	
	</table>
</form>
<%}  %>
<!-- end if if page -->		




<%if (p_tab.equals("discovery")) {
	String action_rule_id=nvl(request.getParameter("rule_id"),"0");
%>
	<form name=fmain>
	
	
	<%if (show_script_editor) {
		String edit_rule_type="";
		String edit_rule_script="";
		
		
		sql="select rule_type, regex, script, field_names  from tdm_discovery_rule where id="+action_rule_id;
	
		if (!action_rule_id.equals("0")) {
						
			ArrayList<String[]> editList=getDbArrayConf(conn, sql, 1, emptybinding);
			
			edit_rule_type=editList.get(0)[0];
			
			
			
			if (edit_rule_type.equals("MATCHES")) 
				edit_rule_script=editList.get(0)[1];
			else if(edit_rule_type.equals("SQL"))
				edit_rule_script=nvl(editList.get(0)[1],"select 1 from table where field=?");
			else
				edit_rule_script=nvl(editList.get(0)[2],"function calcul(){\n\nvar orig_val=\"${1}\";\nvar ret1=true;\n\n//do something\n\nreturn ret1;\n}\n\n\nvar a=true;a=calcul();");
			
			
			if (edit_field_names) {
				edit_rule_script=editList.get(0)[3];
				edit_rule_type="FIELDNAME";
			}
			
			
			
		} //if (!edit_rule_id.equals("0")) {
	%>	
	
	<table class="table table-condensed">
	
	<tr bgcolor="#428bca">
		<td align=left colspan=2>
			<font color=white>Script Editor for (<%=edit_rule_type %>)</font>
			<% if (edit_rule_type.equals("MATCHES") || edit_rule_type.equals("FIELDNAME")) {%>
				<br><font color=yellow>Multiple lines allowed.</font>
			<% }%>
			
			<% if (edit_rule_type.equals("FIELDNAME")) {%>
				<br><font color=yellow><b>type=VARCHAR</b> notation is allowed as fieldname check.</font>
			<% }%>
		</td>
	</tr>

	<tr class=active>
	
	
		<td>
			<textarea name=rule_script id=rule_script rows=5 wrap="off" style="width:100%;overflow:scroll;font-family:Courier New, Courier, monospace; "><%=edit_rule_script %></textarea>
			
			<br>
			
			<% if (!edit_field_names && !edit_rule_type.equals("SQL")) { %>
				<input type=text size=80 id=testinput name=testinput value="Enter Text Here" id=testinput style="background: black; color: white;" onkeyup=testRuleScript()   onclick=starttestinput()>
				<input type=button name=bttest value=Test onclick=testRuleScript()>
			<% } %>
			<% if (edit_field_names) {%>
				<font color=black><b>Enter field names with line break. Regular expressions can be used.</b></font>
			<% } %>
		
		</td>
		
		<td align=center>
			
			<input type=submit name=bt_save_script value=" Save " class="btn btn-success btn-sm" style="width:100%">
			<br>
			<input type=submit name=bt_cancel_script value=" Cancel " class="btn btn-warning btn-sm" style="width:100%">
			
		</td>
	</tr>

	
	</table>
	
	<input type=hidden name=script_rule_type id=script_rule_type  value="<%=edit_rule_type%>">
	<input type=hidden name=script_rule_id value="<%=action_rule_id%>">
	
	
	<%} //if (action.equals("script_rule")) %>
	
	
	
	
	<table class="table table-condensed table-bordered">
	
	<tr class=active>
		<td colspan=6>
			<button class="btn btn-sm btn-default" onclick=ruleAdd()>
				<font color=green><span class="glyphicon glyphicon-plus"></span></font>
				Add new rule
			</button>
		</td>
	</tr>
	
	<tr bgcolor="#428bca">
		<td><b><font color=white>Valid</font></b></td>
		<td><b><font color=white>Description</font></b></td>
		<td><b><font color=white>Rule Target</font></b></td>
		<td><b><font color=white>Method</font></b></td>
		<td><b><font color=white>Weight</font></b></td>
		<td colspan=2><b><font color=white></font></b></td>
	</tr>
	
	<%
	sql="select id, description from tdm_discovery_target order by description";
	ArrayList<String[]> targetList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, emptybinding);
	
	
	sql="select 'MATCHES' a, 'Regex' b from dual union all select 'JS' a, 'JavaScript' b from dual union all select 'SQL' a, 'Sql' b from dual";
	ArrayList<String[]> typeList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, emptybinding);

	ArrayList<String[]> weightList=new ArrayList<String[]>();
	for (int i=0;i<=100;i++) weightList.add(new String[]{""+i,""+i});
	
	sql="select r.id, discovery_target_id,  rule_type, r.description, regex, script, field_names, r.is_valid, r.rule_weight " +  
		" from tdm_discovery_rule r order by discovery_target_id";
	ArrayList<String[]> ruleList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, emptybinding);
	
	
	
	
		
	
	

	for (int i=0;i<ruleList.size();i++) {
		String r_id=ruleList.get(i)[0];
		String r_discovery_target_id=ruleList.get(i)[1];
		String r_rule_type=ruleList.get(i)[2];
		String r_description=ruleList.get(i)[3];
		String r_regex=ruleList.get(i)[4];
		String r_script=ruleList.get(i)[5];
		String r_field_names=ruleList.get(i)[6];
		String is_valid=ruleList.get(i)[7];
		String rule_weight=ruleList.get(i)[8];
		

		String html_for_target_combo=makeComboArr(targetList, "discovery_target_id_"+r_id, "id=discovery_target_id_"+r_id, r_discovery_target_id, 0);
		String html_for_type_combo=makeComboArr(typeList, "rule_type_"+r_id, "id=rule_type_"+r_id, r_rule_type, 100);
		String html_for_weight_combo=makeComboArr(weightList, "rule_weight_"+r_id, "id=rule_weight_"+r_id, rule_weight, 80);

		String is_valid_checked="";
		if (is_valid.equals("YES")) 
			is_valid_checked="checked";
		
		String bg_class="active";
		if (r_id.equals(action_rule_id)) bg_class="warning";
		if (!is_valid.equals("YES")) bg_class="danger";
		
		%>
		<tr class="<%=bg_class%>">
			<td align=center><input type=checkbox name="is_valid_<%=r_id %>" id="is_valid_<%=r_id %>"  <%=is_valid_checked%> value="<%=is_valid %>"></td>
			<!-- <td><input type=text size=40 maxlength=100 id=description_<%=r_id%> value="<%=r_description %>"></td> -->
			<td>
				<%=makeText("description_"+r_id, r_description, " maxlength=100", 0) %>
			</td>
			
			<td><%=html_for_target_combo %></td>
			<td><%=html_for_type_combo %></td>
			<td><%=html_for_weight_combo %></td>
			
			
			
			<td nowrap align=center>
				
				<button class="btn btn-sm btn-default" onclick="ruleScriptEditor(<%=r_id %>);">
						<font color=black><span class="glyphicon glyphicon-flash"></span></font>
				</button>
				
				<button class="btn btn-sm btn-default" onclick="ruleFieldEditor(<%=r_id %>)"> 
					<font color=black><span class="glyphicon glyphicon-list"></span></font>
				</button>
				
			</td>
			
			<td nowrap nowrap align=center>
				
				<button class="btn btn-sm btn-default" onclick="ruleUpdate(<%=r_id %>);">
					<font color=black><span class="glyphicon glyphicon-floppy-disk"></span></font>
				</button>
				
				<button class="btn btn-sm btn-default" onclick="ruleDelete(<%=r_id %>);">
					<font color=red><span class="glyphicon glyphicon-remove"></span></font>
				</button>
				
				
			</td>
		</tr>
		<%
	}
	
	%>
	</table>
		<input type=hidden name=action id=action>
		<input type=hidden name=rule_id id=rule_id>
		<input type=hidden name=rule_target_id id=rule_target_id>
		<input type=hidden name=rule_type id=rule_type>
		<input type=hidden name=rule_description id=rule_description>
		<input type=hidden name=is_valid id=is_valid>
		<input type=hidden name=rule_weight id=rule_weight>
	</form>

<%}  %>
<%if (p_tab.equals("dblist")) {
	
	StringBuilder sb=new StringBuilder();

	sb.append("Add New Database : ");
	sb.append("<img src=\"add.png\" width=24 height=24 onclick=dbAdd()>");
	
	sb.append("<form name=fdb>");
	
	sb.append("<input type=hidden name=action>");
	sb.append("<input type=hidden name=db_id>");
	sb.append("<input type=hidden name=db_name>");
	sb.append("<input type=hidden name=short_code>");
	sb.append("<input type=hidden name=db_driver>");
	sb.append("<input type=hidden name=url_template>");
	sb.append("<input type=hidden name=test_sql>");
	sb.append("<input type=hidden name=partition_sql>");
	sb.append("<input type=hidden name=rowid_field>");
	
	sb.append("<table class=\"table .table-stripped\">");
	
	sb.append("<tr class=active>");
	sb.append("<td><b>DB name</b></td>");
	sb.append("<td><b>DB ShortCode</b></td>");
	sb.append("<td><b>DB Configuration</b></td>");
	sb.append("<td><b>Actions</b></td>");
	sb.append("</tr>");
	
	sql="select " + 
			"	r.id,   ref_desc db_name, r.flexval1 short_code, ref_name db_driver,flexval2 test_url_template, flexval3 rowid_field  " +  
			"	from tdm_ref r where ref_type='DB_TYPE' order by ref_desc";
		ArrayList<String[]> dbList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, emptybinding);

		for (int i=0;i<dbList.size();i++) {
			
			String db_id=dbList.get(i)[0];
			String db_name=dbList.get(i)[1];
			String short_code=dbList.get(i)[2];
			String db_driver=dbList.get(i)[3];
			String db_details=dbList.get(i)[4];
			String rowid_field=dbList.get(i)[5];
			String partition_sql="";
			
			String test_sql="";
			String url_template="";
			
			
			
			
			try {test_sql=db_details.split("\\|")[0];} catch(Exception e) {test_sql="select 1";}
			try {url_template=db_details.split("\\|")[1];} catch(Exception e) {url_template="jdbc:dbtype://<HOSTNAME>:<PORT>/<DBNAME>";}
			try {partition_sql=db_details.split("\\|")[2];} catch(Exception e) {partition_sql="";}
			
			
			sb.append("<tr>");
			
			sb.append(
				"<td valign=top>"+
					"<input id=db_name_"+db_id+" type=text size=15 value=\""+db_name+"\">"+
				"</td>");

			sb.append(
					"<td valign=top>"+
						"<input id=short_code_"+db_id+" type=text size=10 value=\""+short_code+"\">"+
					"</td>");

			

			sb.append(
					"<td valign=top>"+
						"<table class=\"table .table-condensed\" width=\"100%\" border=0>"+
					
							"<tr><td align=right><b>JDBC Driver : </b></td>"+
							"<td><input id=db_driver_"+db_id+" type=text size=60 value=\""+db_driver+"\"></td>"+
							"</tr>"+
									
							"<tr><td align=right><b>Test SQL : </b></td>"+
							"<td><input id=test_sql_"+db_id+" type=text size=60 value=\""+test_sql+"\"></td>"+
							"</tr>"+
									
							"<tr><td align=right><b>URL Template : </b></td>"+
							"<td><input id=url_template_"+db_id+" type=text size=60 value=\""+url_template+"\"></td>"+
							"</tr>"+
									
							"<tr><td align=right><b>Partition SQL : </b></td>"+
							"<td><input id=partition_sql_"+db_id+" type=text size=60 value=\""+partition_sql+"\"></td>"+
							"</tr>"+
			
							"<tr><td align=right><b>ROWID Column Name : </b></td>"+
							"<td><input id=rowid_field_"+db_id+" type=text size=60 value=\""+rowid_field+"\"></td>"+
							"</tr>"+
							
						
						"</table>"+
					"</td>");

		
			
			
			sb.append("<td valign=center nowrap>");
			sb.append("<br><br>");
			sb.append("<img src=\"save.png\" width=24 height=24 onclick=dbUpdate("+db_id +")>	");	
			sb.append("<br>");
			sb.append("<img src=\"delete.png\" width=24 height=24 onclick=dbDelete("+db_id +")>");
			sb.append("</td>");
		
			sb.append("</tr>");
		
			
		} //for (int i=0;i<ruleList.size();i++)
	
	sb.append("</table>");
	sb.append("</form>");
	
	out.println(sb.toString());
%>
	
<%}  %>
<!-- end if if page -->		

</td>
</tr>
</table>
<!--  end of page table -->

</div>
</div>

</div> <!--  container -->
</body>
</html>


<%
try {
conn.close();
conn=null;
} catch(Exception e) {e.printStackTrace();}
%>