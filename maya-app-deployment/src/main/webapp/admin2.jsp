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






if (!nvl(request.getParameter("bt_send_mail"),"-").equals("-")) {
	testmail(conn);
}





String p_javax_email_props=getParamByName(conn, "JAVAX_EMAIL_PROPERTIES");
String p_javax_email_address=getParamByName(conn, "JAVAX_EMAIL_ADDRESS");
String p_javax_email_username=getParamByName(conn, "JAVAX_EMAIL_USERNAME");
String p_javax_email_password=decode(getParamByName(conn, "JAVAX_EMAIL_PASSWORD"));
String p_tdm_process_home=getParamByName(conn, "TDM_PROCESS_HOME");
String p_config_username=getParamByName(conn, "CONFIG_USERNAME");
String p_config_password=decode(getParamByName(conn, "CONFIG_PASSWORD"));
String p_ldap_props=getParamByName(conn, "LDAP_PROPERTIES");
String p_authentication_type=nvl(getParamByName(conn, "AUTHENTICATION_METHOD"),"LOCAL");
String p_max_process_count=nvl(getParamByName(conn, "MAX_PROCESS_COUNT"),"100");
String p_process_start_command_template=nvl(getParamByName(conn, "PROCESS_START_COMMAND_TEMPLATE"),"cmd /c start XXX");
String p_purge_temp_deployment_folders=nvl(getParamByName(conn, "PURGE_DEPLOYMENT_FOLDERS"),"NO");
String p_purge_temp_deployment_interval=nvl(getParamByName(conn, "PURGE_DEPLOYMENT_INTERVAL"),"1");
String p_method_run_url=nvl(getParamByName(conn, "METHOD_RUN_URL"),"");

if (!nvl(request.getParameter("btsave"),"-").equals("-")) {
	p_javax_email_props=nvl(request.getParameter("JAVAX_EMAIL_PROPERTIES"),"").trim();	
	p_javax_email_address=nvl(request.getParameter("JAVAX_EMAIL_ADDRESS"),"").trim();
	p_javax_email_username=nvl(request.getParameter("JAVAX_EMAIL_USERNAME"),"").trim();	
	p_javax_email_password=nvl(request.getParameter("JAVAX_EMAIL_PASSWORD"),"");	
	p_tdm_process_home=nvl(request.getParameter("TDM_PROCESS_HOME"),"");
	p_config_username=nvl(request.getParameter("CONFIG_USERNAME"),"");
	p_config_password=nvl(request.getParameter("CONFIG_PASSWORD"),"");
	p_ldap_props=nvl(request.getParameter("LDAP_PROPERTIES"),"");
	p_authentication_type=nvl(request.getParameter("AUTHENTICATION_METHOD"),"LOCAL");
	p_max_process_count=nvl(request.getParameter("MAX_PROCESS_COUNT"),"100");
	p_process_start_command_template=nvl(request.getParameter("PROCESS_START_COMMAND_TEMPLATE"),"cmd /c start XXX");
	p_purge_temp_deployment_folders=nvl(request.getParameter("PURGE_DEPLOYMENT_FOLDERS"),"NO");
	p_purge_temp_deployment_interval=nvl(request.getParameter("PURGE_DEPLOYMENT_INTERVAL"),p_purge_temp_deployment_interval);
	p_method_run_url=nvl(request.getParameter("METHOD_RUN_URL"),"");  

	//JAVAX_EMAIL_PROPERTIES
	setParamByName(conn, "JAVAX_EMAIL_PROPERTIES" , p_javax_email_props);
	
	
	//JAVAX_EMAIL_ADDRESS
		
	setParamByName(conn, "JAVAX_EMAIL_ADDRESS" , p_javax_email_address);
	

	//JAVAX_EMAIL_USERNAME
	setParamByName(conn, "JAVAX_EMAIL_USERNAME" , p_javax_email_username);
	
	
	//JAVAX_EMAIL_PASSWORD
	setParamByName(conn, "JAVAX_EMAIL_PASSWORD" , encode(p_javax_email_password));
	

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
	
	
	//PURGE_DEPLOYMENT_FOLDERS
	setParamByName(conn, "PURGE_DEPLOYMENT_FOLDERS" , p_purge_temp_deployment_folders);
	
	
	//PURGE_DEPLOYMENT_INTERVAL
	int purge_deployment_interval_INT=0;
	try {
		purge_deployment_interval_INT=Integer.parseInt(p_purge_temp_deployment_interval);
		setParamByName(conn, "PURGE_DEPLOYMENT_INTERVAL" , ""+purge_deployment_interval_INT);
		System.out.println("PURGE_DEPLOYMENT_INTERVAL:"+p_purge_temp_deployment_interval);
	} catch(Exception e) {
		e.printStackTrace();
	}
	
	//METHOD_RUN_URL
	setParamByName(conn, "METHOD_RUN_URL" , p_method_run_url);
		
	

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
<div class="container">


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

for (int i=0;i<menuList.size();i++) {
	String m_title=menuList.get(i)[0];
	String m_tab=menuList.get(i)[1];
	if (p_tab.equals(m_tab)) {
		%>
		<li style="background-color:yellow;"><h4><b><font color=red><%=m_title %></font></b></h4></li>
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
	<b>Maximum Process Count (Master, Worker) [0..1000]:</b>
	</td>
	
	<td>
		<input type=text name="MAX_PROCESS_COUNT" size=4 maxlength=5 value="<%=p_max_process_count %>">
	</td>
	
	</tr>
	
	<tr>
	<td align=right>
	<b>Method Run Url  : </b>
	<br>
	<%=clearHtml("http://localhost:8080/mayapp-deployment/runMethod.jsp") %>
	</td>
	
	<td>
		
		
	<input type=text name=METHOD_RUN_URL value="<%=clearHtml(p_method_run_url) %>" size=50>
		
	</td>
	
	</tr>
	
	
	<tr>
	<td align=right>
	<b>Purge Temporary Deployment Folders  : </b>
	</td>
	
	<td>
		<%
		ArrayList<String[]> arrYesNo=new ArrayList<String[]>();
		arrYesNo.add(new String[]{"YES","Yes"});
		arrYesNo.add(new String[]{"NO","No"});
		String combo_for_purge_temp_deployment_folders=makeComboArr(arrYesNo, "PURGE_DEPLOYMENT_FOLDERS", "size=1 id=PURGE_DEPLOYMENT_FOLDERS", p_purge_temp_deployment_folders, 200); 
		
		%>
		
		<%= combo_for_purge_temp_deployment_folders%>
		
		
	</td>
	
	</tr>
	
	
	<% if (p_purge_temp_deployment_folders.equals("YES")) { %>
	
	<tr>
	<td align=right>
	<b>Purge Temporary Deployment Interval (As Hours)  : </b>
	</td>
	<td>
	<%
	String purge_interval_disabled="disabled";
	if (p_purge_temp_deployment_folders.equals("YES")) purge_interval_disabled="";
	
	%>
		<input type=text <%=purge_interval_disabled %> name="PURGE_DEPLOYMENT_INTERVAL" size=4 maxlength=5 value="<%=p_purge_temp_deployment_interval %>">
	</td>
	
	</tr>
	<%} %>
	
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