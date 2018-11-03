<%@ page import="java.util.*" %>
<%@page import="java.io.File"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@page import="java.io.IOException"%>
<%@page import="org.json.simple.JSONObject"%>
<%@ page import="javax.naming.*" %>
<%@ page import="javax.naming.directory.DirContext" %>
<%@ page import="javax.naming.directory.InitialDirContext" %>
<%@ page import="java.net.InetAddress" %>
<%@ page import="org.apache.commons.codec.binary.Base64" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import="javax.xml.parsers.DocumentBuilder" %>
<%@ page import="org.w3c.dom.*" %>

<%



request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");

String action="";
String div="";
String par1="";
String par2="";
String par3="";
String par4="";
String par5="";





try {
	action=nvl(request.getParameter("action"),"-");

	div=nvl(request.getParameter("div"),"-");
	par1	=	nvl(request.getParameter("par1"),"");
	par2	=	nvl(request.getParameter("par2"),"");
	par3	=	nvl(request.getParameter("par3"),"");
	par4	=	nvl(request.getParameter("par4"),"");
	par5	=	nvl(request.getParameter("par5"),"");


} catch(Exception e) {
	e.printStackTrace();
	action="-";
}



String sql="";
String html="";
ArrayList<String> htmlArr=new ArrayList<String>();
ArrayList<String> divArr=new ArrayList<String>();
String msg="ok";
ArrayList<String[]> bindlist=new ArrayList<String[]>();
JSONObject obj=new JSONObject();


	try {

	String[] arr_action=action.split("\\|");
	String[] arr_div=div.split("\\|");
	String[] arr_par1=par1.split("\\|");
	String[] arr_par2=par2.split("\\|");
	String[] arr_par3=par3.split("\\|");
	String[] arr_par4=par4.split("\\|");
	String[] arr_par5=par5.split("\\|");
	
	
	
	
	for (int a=0;a<arr_action.length;a++) {

		
		try {action=arr_action[a];} catch(Exception e) {action="";}
		try {div=arr_div[a];} catch(Exception e) {div="";}
		try {par1=arr_par1[a];} catch(Exception e) {par1="";}
		try {par2=arr_par2[a];} catch(Exception e) {par2="";}
		try {par3=arr_par3[a];} catch(Exception e) {par3="";}
		try {par4=arr_par4[a];} catch(Exception e) {par4="";}
		try {par5=arr_par5[a];} catch(Exception e) {par5="";}
		
		par1=par1.replaceAll("::NEWLINE::", "\n");
		par2=par2.replaceAll("::NEWLINE::", "\n");
		par3=par3.replaceAll("::NEWLINE::", "\n");
		par4=par4.replaceAll("::NEWLINE::", "\n");
		par5=par5.replaceAll("::NEWLINE::", "\n");

		/*
		System.out.println("action="+action);
		System.out.println("par1="+par1);
		System.out.println("par2="+par2);
		System.out.println("par3="+par3);
		System.out.println("par4="+par4);
		System.out.println("par5="+par5);
		*/

		

		html="";
		msg="";
		

		if (msg.indexOf("nok:")==-1) {	

			
			//**********************************************
			//connect_db
			//**********************************************
			if (action.equals("connect_db")) {
				String db_params=par1;
				
				
				String db_host="";
				String db_port="";
				String db_user="";
				String db_pass="";
				
				try {
					String[] arr=db_params.split("::");
					db_host=arr[0];
					db_port=arr[1];
					db_user=arr[2];
					db_pass=arr[3];
				} catch(Exception e) {
					e.printStackTrace();
				}
				
				if (db_host.equals("<EMPTY>")) db_host="";
				if (db_port.equals("<EMPTY>")) db_port="";
				if (db_user.equals("<EMPTY>")) db_user="";
				if (db_pass.equals("<EMPTY>")) db_pass="";
				
				session.setAttribute("db_host", db_host);
				session.setAttribute("db_port", db_port);
				session.setAttribute("db_user", db_user);
				session.setAttribute("db_pass", db_pass);
				
				String db_url="jdbc:mysql://"+db_host+":"+db_port+"/mysql?useUnicode=true&characterEncoding=utf8";
				System.out.println("Connecting to : " +db_url);
				Connection conn=getconn(session, db_url, db_user, db_pass);
				if (conn!=null) {
					System.out.println("Connection is established");
					session.setAttribute("installation_db_conn", conn);
					html="";
					msg="ok";
				}
				else
					session.setAttribute("installation_db_conn", null);
	
					
			}

			//**********************************************
			//installation_step
			//**********************************************
			if (action.equals("installation_step")) {
			String step="STEP_"+par1;
				
			StringBuilder sb=new StringBuilder();
			
			
			
			if (step.equals("STEP_1")) {
				
				String db_host=nvl((String) session.getAttribute("db_host"),"localhost");	
				String db_port=nvl((String) session.getAttribute("db_port"),"3306");	
				String db_user=nvl((String) session.getAttribute("db_user"),"root");	
				String db_pass=nvl((String) session.getAttribute("db_pass"),"");	
				
				String last_error_msg=nvl((String) session.getAttribute("last_error_msg"),"");

				String db_name=nvl((String) session.getAttribute("db_name"),"tdmdb");	
				String tdm_home=nvl((String) session.getAttribute("tdm_home"),nvl(System.getProperty("user.home"),""));	

				Connection conn=(Connection) session.getAttribute("installation_db_conn");

				
				sb.append("<table class=table>");

				sb.append("<tr>");
				sb.append("<td>");
				sb.append("<span class=\"label label-info\">MYSQL DB IP/HOSTNAME</span>");
				sb.append("</td>");
				sb.append("<td>");
				sb.append("<span class=\"label label-info\">MYSQL DB PORT</span>");
				sb.append("</td>");
				sb.append("<td>");
				sb.append("<span class=\"label label-info\">MYSQL DB USERNAME</span>");
				sb.append("</td>");
				sb.append("<td>");
				sb.append("<span class=\"label label-info\">MYSQL DB PASSWORD</span>");
				sb.append("</td>");
				sb.append("</tr>");
				

				sb.append("<tr>");
				sb.append("<td>");
				sb.append("<input type=text size=30 maxlength=100 id=db_host value=\""+db_host+"\">");
				sb.append("</td>");
				sb.append("<td>");
				sb.append("<input type=text size=10 maxlength=8 id=db_port value=\""+db_port+"\">");
				sb.append("</td>");
				sb.append("<td>");
				sb.append("<input type=text size=15 id=db_user value=\""+db_user+"\">");
				sb.append("</td>");
				sb.append("<td>");
				sb.append("<input type=password size=15 id=db_pass value=\""+db_pass+"\">");
				sb.append("</td>");
				sb.append("<tr>");

				sb.append("<tr>");
				sb.append("<td colspan=4 align=center>");
				sb.append("<button type=button class=\"btn btn-danger\" onclick=connectDB()>Connect to database</button>");
				if (conn!=null) 
					sb.append("<br><br><span class=\"label label-success\">Connection is successfull :)</span>");
				else {
					sb.append("<br><br><span class=\"label label-danger\">Connection is failed</span>");
					sb.append(" : "+last_error_msg);					
				}
				sb.append("</td>");
				sb.append("</tr>");
				
				if (conn==null) {
					html="";
					msg="nok:connection cannot be established. Check configuration.";
				} 
				else {
					sb.append("<tr>");
					sb.append("<td align=right valign=center>");
					sb.append("<span class=\"label label-info\">TDM DB NAME</span>");
					sb.append("</td>");
					
					sb.append("<td colspan=3 width=\"100%\">");
					//sb.append("<input type=text size=15 maxlength=10 id=db_name value=\""+db_name+"\">");
					ArrayList<String[]> arr=getSchemaListFromConn(conn);

					int schema_count=0;
					for (int i=0;i<arr.size();i++) {
						String owner=arr.get(i)[0];
						if (!",mysql,information_schema,performance_schema".contains(","+owner))
							schema_count++;
					}
					
					if (schema_count==0) {
						sql="create database tdmdb";
						execSQL(conn, sql,new ArrayList<String[]>());
						arr=getSchemaListFromConn(conn);
					}

					
					sb.append("<select size=1 id=db_name>");
					for (int i=0;i<arr.size();i++) {
						String owner=arr.get(i)[0];
						if (!",mysql,information_schema,performance_schema".contains(","+owner))
							sb.append("<option value=\""+owner+"\">"+owner+"</option>");
					}
					sb.append("</select>");
		
					sb.append("</td>");
					sb.append("<tr>");

				
					sb.append("<tr>");
					sb.append("<td align=right valign=center>");
					sb.append("<span class=\"label label-info\">TDM HOME DIRECTORY</span>");
					sb.append("</td>");
					
					sb.append("<td colspan=3 width=\"100%\">");
					sb.append("<input type=text size=50 maxlength=200 id=tdm_home value=\""+tdm_home+"\">");
					sb.append("</td>");
					sb.append("<tr>");
				
					sb.append("<tr>");
					sb.append("<td colspan=4 align=center>");
					sb.append("<button type=button class=\"btn btn-success\" onclick=installNow()>Start Installation</button>");
					
					String installation_err=nvl((String) session.getAttribute("installation_error"),"");
					String is_installed=nvl((String) session.getAttribute("installation_done"),"NO");
					
					if (installation_err.length()==0 && is_installed.equals("YES"))  {
						sb.append("<br><br><span class=\"label label-success\">Installation is successfull :)</span>");
						sb.append("<hr>");
						sb.append("click <a href=\"default2.jsp\"><b>here</b></a> to start");
						sb.append("<hr>");
						sb.append("<b>Please use this configuration in context.xml</b><br>");
						sb.append("<textarea cols=80 rows=8>"+
								  "  <Resource name=\"jdbc/tdmconfig\" auth=\"Container\" "+ "\n"+
						          "    type=\"javax.sql.DataSource\" driverClassName=\"com.mysql.jdbc.Driver\" "+ "\n"+
						          "    url=\"jdbc:mysql://localhost/"+db_name+"\" "+ "\n"+
						          "    username=\"tdmuser\"  "+ "\n"+
						          "    password=\"tdm123\" maxActive=\"20\" maxIdle=\"10\" "+ "\n"+
						          "    connectionProperties=\"useUnicode=yes;characterEncoding=utf8;\" "+ "\n"+
						          "    maxWait=\"-1\"/> "+ "\n"+
								  "</textarea>");
					}
						
					else {
						if (is_installed.equals("YES")) {
							sb.append("<br><br><span class=\"label label-danger\">Installation is failed</span>");
							sb.append(" : "+installation_err);
						}
					}
						
					
					
					sb.append("</td>");
					sb.append("</tr>");
				
				}

				
				sb.append("</table>"); //div row
			} // STEP 1
			
			html=sb.toString();
			msg="ok";
				
			}

			//**********************************************
			//install_tdm
			//**********************************************
			if (action.equals("install_tdm")) {
				String install_params=par1;

				String db_name="";
				String tdm_home="";
				
				try {
					String[] arr=install_params.split("::");
					db_name=arr[0];
					tdm_home=arr[1];
				} catch(Exception e) {
					e.printStackTrace();
				}
				
				
				session.setAttribute("db_name", db_name);
				session.setAttribute("tdm_home", tdm_home);
				
				String installation_msg="";
				session.setAttribute("installation_error", installation_msg);
				
				Connection conn=(Connection) session.getAttribute("installation_db_conn");
				
				session.setAttribute("installation_done","YES");
				
				
				if (conn==null) {
					installation_msg="DB connection is invalid. Reconnect!";
				}
				else {
					//check if schema is already exists
					ArrayList<String[]> schemaList=getSchemaListFromConn(conn);
					boolean is_db_exists=false;
					for (int i=0;i<schemaList.size();i++) {
						if (schemaList.get(i)[0].toUpperCase().equals(db_name.toUpperCase())) {
							is_db_exists=true;
							break;
						}
					}
					
					if (!is_db_exists) 
						installation_msg="There no such db name ["+db_name+"] in DB. Please change it.";
					else {
						boolean is_dir_valid=false;
						File tdmDir = new File(tdm_home);
						if (tdmDir.exists()) is_dir_valid=true;
						else {
							System.out.println("Directory is not there. try to create");
							try {
								tdmDir.mkdir();	
								File tdmDirCreated = new File(tdm_home);
								if (tdmDirCreated.exists())	is_dir_valid=true;
							} catch(Exception e) {e.printStackTrace();}
						}
						
						if (!is_dir_valid)
							installation_msg="The specified home directory ["+tdm_home+"] is invalid or cannot be created.";
						else 
						{

							String db_host=nvl((String) session.getAttribute("db_host"),"localhost");	
							String db_port=nvl((String) session.getAttribute("db_port"),"3306");	

							String xmlpath=application.getRealPath("/tdm_discovery_rule.xml");
							installation_msg=installTDM(conn, tdm_home, db_name, db_host, db_port,xmlpath);	
						} //if (!is_dir_valid)
					} //if (is_db_exists)
					
				} //if (conn==null)
				
				html="";
				msg="ok";

				if (installation_msg.length()>0) {
					System.out.println(installation_msg);
					session.setAttribute("installation_error", installation_msg);
				}
					
				
					
				

			}

		
		
		} // msg.indexOf(nok)==-1

			
			htmlArr.add(html);
			divArr.add(div);
			
			if (action.length()>0) {
				obj.put("html"+(a+1), htmlArr.get(a));
				obj.put("div"+(a+1), divArr.get(a));		
			}
			
			div="";
	
	} //for (int a=0;a<arr_action.length;a++

	obj.put("msg", msg);

} 
catch(Exception e) {
	e.printStackTrace();
}



		
try{ out.print(obj);   out.flush();} catch(IOException e) {	e.printStackTrace();  } 

%>




<%! 
public String nvl(String in, String out) {
	String r = "";
	try {
		r=in;
		if (r.equals("null")) r="";
	} catch (Exception e) {
		r = "";
	}

	if (r.length() == 0)
		r = out;

	return r;
}


//*************************************************************
private Connection getconn(HttpSession session, String db_url, String db_user, String db_pass) {
	Connection conn = null;
	final String JDBC_DRIVER = "com.mysql.jdbc.Driver";  

	try {
		Class.forName(JDBC_DRIVER);
		conn = DriverManager.getConnection(db_url,db_user,db_pass);
	} catch (Exception e) {
		conn=null;
		System.out.print("Exception@"+e.getMessage());
		session.setAttribute("last_error_msg",e.getMessage());
		e.printStackTrace();
	}
	
	return conn;
}


//****************************************
public ArrayList<String[]> getSchemaListFromConn(Connection con) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	String owner="";
	try{
		DatabaseMetaData md = con.getMetaData();
		ResultSet rs = md.getSchemas();
		
		while (rs.next()) {
			owner=rs.getString(1);
          ret1.add(new String[]{owner});
  		}
		rs.close();
		
		//sqls such as Mysql has hot schema, instead they have catalogs
		if (ret1.size()==0) {
			rs = md.getCatalogs();
			while (rs.next()) {
				owner=rs.getString(1);
	            ret1.add(new String[]{owner});
	    		}
			rs.close();
		}
	} catch(Exception e) {
		e.printStackTrace();
	} finally {

	}
	
	return ret1;
}

//********************************************************
private String installTDM(Connection conn, String tdm_home, String db_name,  String db_host, String db_port, String xmlpath) {
	String err="";
	ArrayList<String> cmdArr=loadCommands(tdm_home, "tdmuser", encode("tdm123"));
	
	String sql="";
	
	//create db
	//sql="create database "+db_name;
	//execSQL(conn, sql);
	
	//create user
	sql="CREATE USER 'tdmuser'@'localhost' IDENTIFIED BY 'tdm123'";
	execSQL(conn, sql, new ArrayList<String[]>());
	
	sql="GRANT ALL PRIVILEGES ON "+db_name+".* TO 'tdmuser'@'localhost'";
	execSQL(conn, sql, new ArrayList<String[]>());

	
	for (int i=0;i<cmdArr.size();i++) {
		sql=cmdArr.get(i);
		sql=sql.replace("insert into ", "insert into "+db_name+".");
		sql=sql.replace("INSERT INTO ", "insert into "+db_name+".");
		sql=sql.replace("create table ", "create table "+db_name+".");
		sql=sql.replace("CREATE TABLE ", "create table "+db_name+".");
		sql=sql.replace("truncate table ", "truncate table "+db_name+".");
		
		System.out.println("\n\nExecuting...........................:\n"+sql);
		execSQL(conn, sql, new ArrayList<String[]>());
	}


	String OS = System.getProperty("os.name").toLowerCase();
	boolean is_windows=false;
	if (OS.indexOf("win") >= 0) is_windows=true;
	
	ArrayList<String[]> scriptArr=getScripts(tdm_home, db_name, db_host, db_port, is_windows);
	
	for (int i=0;i<scriptArr.size();i++) {
		String filename=scriptArr.get(i)[0];
		String script=scriptArr.get(i)[1];
		String filepath="";
		if (is_windows) filepath=tdm_home+"\\"+filename;
		else filepath=tdm_home+"/"+filename;
		
		System.out.println("Creating file "+filepath);
		text2file(script, filepath);
	}



	installDiscoveryScripts(conn, db_name, xmlpath);

	
	return err;
}

// *****************************************
private void installDiscoveryScripts(Connection conn, String db_name, String xmlpath) {
	DocumentBuilderFactory dbf=null;
	DocumentBuilder db = null;
	Document doc = null;
	
	boolean is_parsed=false;
	try {
		
		dbf = DocumentBuilderFactory.newInstance();
		db = dbf.newDocumentBuilder();
		doc=db.parse(xmlpath);
		is_parsed=true;
		
	} catch(Exception e) {
		e.printStackTrace();
		System.out.println("xml could not be parsed. ");
	}
	
	if (is_parsed) {

	
		NodeList ruleArr = doc.getElementsByTagName("ROW");
		
		for (int i=0;i<ruleArr.getLength();i++) {
			String 	id="";
			String discovery_target_id="";
			String rule_type="";
			String description="";
			String regex="";
			String script="";
			String field_names="";

			Node aRule=ruleArr.item(i);
			NodeList fieldArr=aRule.getChildNodes();

			System.out.println("installing rule............................ :  "+(i+1)+"/"+ruleArr.getLength());
			
			for (int f=0;f<fieldArr.getLength();f++) {
				Node aField=fieldArr.item(f);
				String field_name=aField.getNodeName();
				String field_value=aField.getTextContent();
				
				//System.out.println(field_name+"="+field_value);
				
				if (field_name.equals("id")) id=field_value;
				if (field_name.equals("discovery_target_id")) discovery_target_id=field_value;
				if (field_name.equals("rule_type")) rule_type=field_value;
				if (field_name.equals("description")) description=field_value;
				if (field_name.equals("regex")) regex=field_value;
				if (field_name.equals("script")) script=field_value;
				if (field_name.equals("field_names")) field_names=field_value;
			}
			
			String sql="insert into "+db_name+".tdm_discovery_rule "+
						" (id, discovery_target_id, rule_type, description, regex, script, field_names, is_valid) "+
						" values (?, ?, ?, ?, ?, ?, ?, 'YES')";
			
			ArrayList<String[]> bindlist= new ArrayList<String[]>();
			if (id.length()>0) {
				bindlist.add(new String[]{"INTEGER",""+(i+1)});
				bindlist.add(new String[]{"INTEGER",discovery_target_id});
				bindlist.add(new String[]{"STRING",rule_type});
				bindlist.add(new String[]{"STRING",description});
				bindlist.add(new String[]{"STRING",regex});
				bindlist.add(new String[]{"STRING",script});
				bindlist.add(new String[]{"STRING",field_names});
				
				execSQL(conn, sql, bindlist);
			}

		}
	}
	
}
//*****************************************

//----------------------------------------------
public String getEnvValue(String key1) {
 String ret1 = "";

 Map<String, String> env = System.getenv();

 for (String envName : env.keySet()) {
     if (envName.toUpperCase().indexOf(key1.toUpperCase()) == 0) {
         ret1 = env.get(envName);
     }
 }
 
 ret1=ret1.replaceAll("\"", "");
 
 
 return ret1;
}

// *****************************************

private void text2file(String text, String filepath) {
	PrintWriter out = null;

	try {
		out = new PrintWriter(filepath);
		out.println(text);
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		out.close();
	}
}

//*************************************************************
ArrayList<String[]> getScripts(String tdm_home, String db_name, String db_host, String db_port, boolean is_windows) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	
		
	String ln=System.lineSeparator();
	


	if (is_windows)
	ret1.add(
			new String[]{
			"StartCommonPars.bat", 
			
			"set JAVA_HOME=%CD%\\jdk32"+ln+
			"set JAVA_SDK_HOME=%CD%\\jdk32\\bin"+ln+
			"set JAVA_SDK_LIB=%CD%\\jdk32\\lib"+ln+
			"set COMMON_LIB=%CD%\\libs"+ln+
			"set DEF_ENCODING=utf-8" +ln +
			"set PATH=%JAVA_HOME%;%JAVA_SDK_HOME%" +ln+
			"set CLASSPATH=.;%JAVA_SDK_LIB%;%COMMON_LIB%\\*" + ln +
			"echo on" + ln +
			"set CONFIG_DB_TYPE=\"MYSQL\"" + ln +
			"set CONFIG_DRIVER=\"com.mysql.jdbc.Driver\"" + ln +
			"set CONFIG_CONNSTR=\"jdbc:mysql://"+db_host+":"+db_port+"/"+db_name+"?useUnicode=true&characterEncoding=utf8\""+
			ln
			}
			);
	
	else {
		ret1.add(
				new String[]{
				"setEnv.sh", 
				
				"JAVA_HOME="+nvl(getEnvValue("JAVA_HOME"),"/usr/java/jdk1.5.0_07/bin")+"" + ln +
				"export JAVA_HOME" + ln +
				"JAVA_SDK_HOME=$JAVA_HOME/bin" + ln +
				"export JAVA_SDK_HOME" + ln +
				"JAVA_SDK_LIB=$JAVA_HOME/lib" + ln +
				"export JAVA_SDK_LIB" + ln +
				"COMMON_LIB="+tdm_home+"/libs" + ln +
				"export COMMON_LIB" + ln +
				"DEF_ENCODING=utf-8" + ln +
				"export DEF_ENCODING" + ln +
				"export PATH=$JAVA_HOME:$JAVA_SDK_HOME:$PATH" + ln +
				"export CLASSPATH=.:$JAVA_SDK_LIB:$COMMON_LIB/*" + ln +
				"export CONFIG_DRIVER=\"com.mysql.jdbc.Driver\"" + ln +
				"CONFIG_CONNSTR=\"jdbc:mysql://"+db_host+":"+db_port+"/"+db_name+"?useUnicode=true&characterEncoding=utf8\"" + ln +
				"export CONFIG_CONNSTR" + ln +
				ln
				}
				);
		
	}
	
	if (is_windows)
	ret1.add(
			new String[]{
			"startManager.bat", 

			"call StartCommonPars.bat " +ln+
			"jdk32\\bin\\java -Xms64m -Xmx512m -Dfile.encoding=%DEF_ENCODING%  com.mayatech.tdm.managerDriver"+ln+
			"exit"+ln
			}
			);
	else
		ret1.add(
				new String[]{
				"startManager.sh", 

				"#!/bin/bash"+ln+
				"source setEnv.sh"+ln+
				"echo \"JAVA_HOME=\"$JAVA_HOME"+ln+
				"echo \"JAVA_SDK_HOME=\"$JAVA_SDK_HOME"+ln+
				"echo \"JAVA_SDK_LIB=\"$JAVA_SDK_LIB"+ln+
				"echo \"COMMON_LIB=\"$COMMON_LIB"+ln+
				"echo \"DEF_ENCODING=\"$DEF_ENCODING"+ln+
				"echo \"CONFIG_DRIVER=\"$CONFIG_DRIVER"+ln+
				"echo \"CONFIG_CONNSTR=\"$CONFIG_CONNSTR"+ln+
				"echo \"PATH=\"$PATH"+ln+
				"echo \"CLASSPATH=\"$CLASSPATH"+ln+
				"nohup java -Xms50M -Xmx100M -XX:+UseG1GC -Dfile.encoding=$DEF_ENCODING com.mayatech.tdm.managerDriver >> manager.log &"+ln+
				ln
				}
				);
		

	if (is_windows)
	ret1.add(
			new String[]{
			"StartMaster.bat", 

			"call StartCommonPars.bat " +ln+
			"jdk32\\bin\\java -Xms64m -Xmx512m -Dfile.encoding=%DEF_ENCODING%  com.mayatech.tdm.masterDriver"+ln+
			"exit"+ln
			}
			);
	else
		ret1.add(
				new String[]{
				"startMaster.sh", 

				"#!/bin/bash"+ln+
				"source setEnv.sh"+ln+
				"echo \"JAVA_HOME=\"$JAVA_HOME"+ln+
				"echo \"JAVA_SDK_HOME=\"$JAVA_SDK_HOME"+ln+
				"echo \"JAVA_SDK_LIB=\"$JAVA_SDK_LIB"+ln+
				"echo \"COMMON_LIB=\"$COMMON_LIB"+ln+
				"echo \"DEF_ENCODING=\"$DEF_ENCODING"+ln+
				"echo \"CONFIG_DRIVE88R=\"$CONFIG_DRIVE88R"+ln+
				"echo \"CONFIG_CONNSTR=\"$CONFIG_CONNSTR"+ln+
				"echo \"PATH=\"$PATH"+ln+
				"echo \"CLASSPATH=\"$CLASSPATH"+ln+
				"nohup java -Xms50M -Xmx100M -XX:+UseG1GC -Dfile.encoding=$DEF_ENCODING com.mayatech.tdm.masterDriver >> master.log &"+ln+
				ln
				}
				);

	if (is_windows)
	ret1.add(
			new String[]{
			"StartWorker.bat", 

			"call StartCommonPars.bat " +ln+
			"jdk32\\bin\\java -Xms64m -Xmx512m -Dfile.encoding=%DEF_ENCODING%  com.mayatech.tdm.workerDriver"+ln+
			"exit"+ln
			}
			);
	else
		ret1.add(
			new String[]{
			"startWorker.sh", 

			"#!/bin/bash"+ln+
			"source setEnv.sh"+ln+
			"echo \"JAVA_HOME=\"$JAVA_HOME"+ln+
			"echo \"JAVA_SDK_HOME=\"$JAVA_SDK_HOME"+ln+
			"echo \"JAVA_SDK_LIB=\"$JAVA_SDK_LIB"+ln+
			"echo \"COMMON_LIB=\"$COMMON_LIB"+ln+
			"echo \"DEF_ENCODING=\"$DEF_ENCODING"+ln+
			"echo \"CONFIG_DRIVE88R=\"$CONFIG_DRIVE88R"+ln+
			"echo \"CONFIG_CONNSTR=\"$CONFIG_CONNSTR"+ln+
			"echo \"PATH=\"$PATH"+ln+
			"echo \"CLASSPATH=\"$CLASSPATH"+ln+
			"nohup java -Xms50M -Xmx100M -XX:+UseG1GC -Dfile.encoding=$DEF_ENCODING com.mayatech.tdm.workerDriver >> worker.log &"+ln+
			ln
			}
			);
	
	if (is_windows)
	ret1.add(
			new String[]{
			"startUtil.bat", 

			"call StartCommonPars.bat " +ln+
			"jdk32\\bin\\java -Xms64m -Xmx512m -Dfile.encoding=%DEF_ENCODING%  com.mayatech.tdm.maskutil"+ln+
			"exit"+ln
			}
			);
	else
		ret1.add(
				new String[]{
				"startUtil.sh", 

				"#!/bin/bash"+ln+
				"source setEnv.sh"+ln+
				"echo \"JAVA_HOME=\"$JAVA_HOME"+ln+
				"echo \"JAVA_SDK_HOME=\"$JAVA_SDK_HOME"+ln+
				"echo \"JAVA_SDK_LIB=\"$JAVA_SDK_LIB"+ln+
				"echo \"COMMON_LIB=\"$COMMON_LIB"+ln+
				"echo \"DEF_ENCODING=\"$DEF_ENCODING"+ln+
				"echo \"CONFIG_DRIVER=\"$CONFIG_DRIVER"+ln+
				"echo \"CONFIG_CONNSTR=\"$CONFIG_CONNSTR"+ln+
				"echo \"PATH=\"$PATH"+ln+
				"echo \"CLASSPATH=\"$CLASSPATH"+ln+
				"java -Xms50M -Xmx100M -XX:+UseG1GC -Dfile.encoding=$DEF_ENCODING com.mayatech.tdm.maskutil"+ln+
				ln
				}
				);

	return ret1;
}


//*******************************************************
public String encode(String a) {
	
	byte[]   bytesEncoded = Base64.encodeBase64URLSafe(a.getBytes());

	return new String(bytesEncoded);
}


//******************************************
public String gethostname() {
	String ret1 = "";
	InetAddress addr;
	try {
		addr = InetAddress.getLocalHost();
		ret1 = addr.getHostName();
	} catch (Exception e) {
		ret1 = "unknown";
	}
	
	return ret1;
}



//*************************************************************
	public boolean execSQL(Connection conn, String sql, ArrayList<String[]> bindlist) {
		boolean ret1 = true;
		PreparedStatement pstmt_execbind=null;

		try {
			pstmt_execbind = conn.prepareStatement(sql);
			
			for (int i = 1; i <= bindlist.size(); i++) {
				String[] a_bind = bindlist.get(i - 1);
				String bind_type = a_bind[0];
				String bind_val = a_bind[1];


				if (bind_type.equals("INTEGER")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.INTEGER);
					else
						pstmt_execbind.setInt(i, Integer.parseInt(bind_val));
				}
				else {
					pstmt_execbind.setString(i, bind_val);
				}
			}


			pstmt_execbind.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
			ret1 = false;
		} finally {
			try {
				conn.commit();
				pstmt_execbind.close();
				pstmt_execbind = null;
			} catch (Exception e) {
			}
		}

		return ret1;
	}


//*********************************************************
private ArrayList<String> loadCommands(String tdm_home, String tdm_user, String tdm_pass) {
	ArrayList<String> ret1=new ArrayList<String>();
	
	ret1.add("CREATE TABLE tdm_apps ( \n"+
			 " id int(11) NOT NULL AUTO_INCREMENT, \n"+
			 " name varchar(100) DEFAULT NULL, \n"+
			 " app_type varchar(20) DEFAULT NULL, \n"+
			 " prep_script mediumtext, \n"+
			 " post_script mediumtext, \n"+
			 " last_run_point_statement text, \n"+
			 " PRIMARY KEY (id), \n"+
			 " UNIQUE KEY id_UNIQUE (id) \n"+
			 " ) ENGINE=InnoDB AUTO_INCREMENT=999 DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_ref ( \n"+
			"  ID int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  ref_type varchar(45) NOT NULL, \n"+
			"  ref_name varchar(100) DEFAULT NULL, \n"+
			"  ref_desc varchar(100) DEFAULT NULL, \n"+
			"  flexval1 varchar(200) DEFAULT NULL, \n"+
			"  flexval2 varchar(200) DEFAULT NULL, \n"+
			"  flexval3 varchar(200) DEFAULT NULL, \n"+
			"  ref_order varchar(45) DEFAULT NULL, \n"+
			"  PRIMARY KEY (ID), \n"+
			"  UNIQUE KEY ID_UNIQUE (ID) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=999 DEFAULT CHARSET=utf8;");
	
	ret1.add("INSERT INTO tdm_ref (ref_type, ref_name, ref_desc, ref_order,flexval1,flexval2,flexval3) VALUES ('DB_TYPE', 'oracle.jdbc.driver.OracleDriver', 'Oracle', '1','ORACLE','select 1 from dual|jdbc:oracle:thin:@<TNS_NAME>|select PARTITION_NAME from ALL_TAB_PARTITIONS where table_name=?','ROWID')");
	ret1.add("INSERT INTO tdm_ref (ref_type, ref_name, ref_desc, ref_order,flexval1,flexval2,flexval3) VALUES ('DB_TYPE', 'com.ibm.db2.jcc.DB2Driver', 'Db2', '2','DB2','select IBMREQD x from SYSIBM.SYSDUMMY1|jdbc:db2://<HOST>:<PORT>/<DBNAME>','ROWID')");
	ret1.add("INSERT INTO tdm_ref (ref_type, ref_name, ref_desc, ref_order,flexval1,flexval2,flexval3) VALUES ('DB_TYPE', 'net.sourceforge.jtds.jdbc.Driver', 'Microsoft MS SQL', '4','MSSQL','select 1|jdbc:jtds:sqlserver://<HOST>:<PORT>/<DB>','')");
	ret1.add("INSERT INTO tdm_ref (ref_type, ref_name, ref_desc, ref_order,flexval1,flexval2,flexval3) VALUES ('DB_TYPE', 'net.sourceforge.jtds.jdbc.Driver*', 'Sybase', '4','SYBASE','select 1|jdbc:jtds:sqlserver://<HOST>:<PORT>/<DB>','')");
	ret1.add("INSERT INTO tdm_ref (ref_type, ref_name, ref_desc, ref_order,flexval1,flexval2,flexval3) VALUES ('DB_TYPE', 'com.mysql.jdbc.Driver', 'mySQL', '6','MYSQL','select 1 from dual|jdbc:mysql://<HOST>:<PORT>/<DB>','')");
	ret1.add("INSERT INTO tdm_ref (ref_type, ref_name, ref_desc, ref_order,flexval1,flexval2,flexval3) VALUES ('DB_TYPE', 'org.apache.cassandra.cql.jdbc.CassandraDriver', 'Cassandra', '7','CASSANDRA','select 1 from dual|jdbc:cassandra://<HOST>:<PORT>/<DB>','')");
	ret1.add("INSERT INTO tdm_ref (ref_type, ref_name, ref_desc, ref_order,flexval1,flexval2,flexval3) VALUES ('DB_TYPE', 'org.postgresql.Driver', 'PostgreSQL', '8','PostgreSQL','select version();|jdbc:postgresql://<HOST>:<PORT>/<DB>','')");
	ret1.add("commit");

	ret1.add("CREATE TABLE tdm_envs ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  app_id int(11) NOT NULL, \n"+
			"  name varchar(100) DEFAULT NULL, \n"+
			"  db_driver varchar(200) DEFAULT NULL, \n"+
			"  db_connstr varchar(1000) DEFAULT NULL, \n"+
			"  db_username varchar(45) DEFAULT NULL, \n"+
			"  db_password varchar(200) DEFAULT NULL, \n"+
			"  db_catalog varchar(45) DEFAULT '${default}', \n"+
			"  for_design varchar(3) DEFAULT 'NO', \n"+
			"  for_static varchar(3) DEFAULT 'NO', \n"+
			"  for_dynamic varchar(3) DEFAULT 'NO', \n"+
			"  name varchar(100) DEFAULT NULL, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=999 DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_target ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  target_name varchar(100) DEFAULT NULL, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_family ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  family_name varchar(100) DEFAULT NULL, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_target_family_env ( \n"+
			 " id int(11) NOT NULL AUTO_INCREMENT, \n"+
			 " target_id int(11), \n"+
			 " family_id int(11), \n"+
			 " env_id int(11), \n"+
			 " PRIMARY KEY (id), \n"+
			 " UNIQUE KEY id_UNIQUE (id) \n"+
			 " ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");

	ret1.add("CREATE TABLE tdm_fields ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  tab_id int(11) NOT NULL, \n"+
			"  field_name varchar(100) DEFAULT NULL, \n"+
			"  field_type varchar(100) DEFAULT NULL, \n"+
			"  field_size int(5) DEFAULT '0', \n"+
			"  is_pk varchar(3) DEFAULT NULL, \n"+
			"  mask_prof_id int(11) NOT NULL, \n"+
			"  list_field_name varchar(100) DEFAULT NULL, \n"+
			"  is_conditional varchar(3) DEFAULT NULL, \n"+
			"  condition_expr varchar(3000) DEFAULT NULL, \n"+
			"  calc_prof_id int(11) NOT NULL default '0', \n"+
			"  copy_ref_tab_id int(11) NOT NULL default '0', \n"+
			"  copy_ref_field_name varchar(1000) DEFAULT NULL, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id), \n"+
			"  KEY ndx_tdm_fields_tab_id (tab_id), \n"+
			"  KEY ndx_tdm_fields_prof_id (mask_prof_id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=999 DEFAULT CHARSET=utf8;");

	ret1.add("CREATE TABLE tdm_list ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  name varchar(100) DEFAULT NULL, \n"+
			"  title_list varchar(1000) DEFAULT NULL, \n"+
			"  sql_statement mediumtext, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=999 DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_list_items ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  list_id int(11) NOT NULL, \n"+
			"  list_val text DEFAULT NULL, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=6550 DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_manager ( \n"+
			"  status varchar(45) DEFAULT 'FREE', \n"+
			"  last_heartbeat datetime DEFAULT NULL, \n"+
			"  hostname varchar(100) DEFAULT NULL, \n"+
			"  cancel_flag varchar(3) DEFAULT NULL \n"+
			") ENGINE=MEMORY DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_mask_prof ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  name varchar(100) DEFAULT NULL, \n"+
			"  rule_id varchar(20) NOT NULL, \n"+
			"  valid varchar(3) DEFAULT 'YES', \n"+
			"  hide_char varchar(1) DEFAULT NULL, \n"+
			"  hide_after int(3) DEFAULT NULL, \n"+
			"  hide_by_word varchar(3) DEFAULT NULL, \n"+
			"  src_list_id int(11) DEFAULT NULL, \n"+
			"  random_range varchar(30) DEFAULT NULL, \n"+
			"  random_char_list varchar(1000) DEFAULT NULL, \n"+
			"  regex_stmt varchar(1000) DEFAULT NULL, \n"+
			"  post_stmt varchar(1000) DEFAULT NULL, \n"+
			"  format varchar(100) DEFAULT NULL, \n"+
			"  date_change_params varchar(100) DEFAULT NULL, \n"+
			"  pre_stmt varchar(1000) DEFAULT NULL, \n"+
			"  fixed_val varchar(200) DEFAULT NULL, \n"+
			"  js_code text, \n"+
			"  js_test_par varchar(1000) DEFAULT NULL, \n"+
			"  short_code varchar(45) DEFAULT NULL, \n"+
			"  run_on_server varchar(3) DEFAULT 'NO', \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;");
	
	ret1.add("INSERT INTO tdm_mask_prof (id,name,rule_id,valid,hide_char,hide_after,hide_by_word,src_list_id,random_range,random_char_list,regex_stmt,post_stmt,format,date_change_params,pre_stmt,fixed_val,js_code,js_test_par,short_code) VALUES (1,'00 No Change','NONE','YES',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'NONE')");
	ret1.add("INSERT INTO tdm_mask_prof (id,name,rule_id,valid,hide_char,hide_after,hide_by_word,src_list_id,random_range,random_char_list,regex_stmt,post_stmt,format,date_change_params,pre_stmt,fixed_val,js_code,js_test_par,short_code) VALUES (2,'01 Fixed in Group','GROUP','YES','',0,'',0,'','','','','','','','','','','GROUP_FIX')");
	ret1.add("INSERT INTO tdm_mask_prof (id,name,rule_id,valid,hide_char,hide_after,hide_by_word,src_list_id,random_range,random_char_list,regex_stmt,post_stmt,format,date_change_params,pre_stmt,fixed_val,js_code,js_test_par,short_code) VALUES (3,'02 Switch in Group','GROUP_MIX','YES','',0,'',0,'','','','','','','','','','','GROUP_MIX')");
	ret1.add("INSERT INTO tdm_mask_prof (id,name,rule_id,valid,hide_char,hide_after,hide_by_word,src_list_id,random_range,random_char_list,regex_stmt,post_stmt,format,date_change_params,pre_stmt,fixed_val,js_code,js_test_par,short_code) VALUES (4,'03 Switch in Records','MIX','YES','',0,'',0,'','','','','','','','','','','RECORD_MIX')");
	ret1.add("INSERT INTO tdm_mask_prof (id,name,rule_id,valid,hide_char,hide_after,hide_by_word,src_list_id,random_range,random_char_list,regex_stmt,post_stmt,format,date_change_params,pre_stmt,fixed_val,js_code,js_test_par,short_code) VALUES (5,'04 List Hashing Reference Field','HASH_REF','YES','',0,'',0,'','','','','','','','','','','HASH_REF')");
	ret1.add("INSERT INTO tdm_mask_prof (id,name,rule_id,valid,hide_char,hide_after,hide_by_word,src_list_id,random_range,random_char_list,regex_stmt,post_stmt,format,date_change_params,pre_stmt,fixed_val,js_code,js_test_par,short_code) VALUES (6,'05 Copy Reference Field','COPY_REF','YES','',0,'',0,'','','','','','','','','','','COPY_REF')");

	
	
	ret1.add("CREATE TABLE tdm_master ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  master_name varchar(200) DEFAULT NULL, \n"+
			"  status varchar(45) DEFAULT 'NEW', \n"+
			"  hired_worker_count int(11) DEFAULT '0', \n"+
			"  last_heartbeat datetime DEFAULT NULL, \n"+
			"  hostname varchar(100) DEFAULT NULL, \n"+
			"  assign_date datetime DEFAULT NULL, \n"+
			"  start_date datetime DEFAULT NULL, \n"+
			"  finish_date datetime DEFAULT NULL, \n"+
			"  cancel_flag varchar(3) DEFAULT NULL, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=MEMORY AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_master_log ( \n"+
			 " id int(11) NOT NULL AUTO_INCREMENT, \n"+
			 " master_id int(11) DEFAULT '0', \n"+
			 " work_package_id int(11) DEFAULT '0', \n"+
			 " status varchar(45) DEFAULT 'NEW', \n"+
			 " status_date datetime DEFAULT NULL, \n"+
			 " PRIMARY KEY (id), \n"+
			 " UNIQUE KEY id_UNIQUE (id) \n"+
			 " ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_tabs ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  app_id int(11) NOT NULL, \n"+
			"  db_type varchar(20) DEFAULT 'ORACLE', \n"+
			"  family_id int(11) , \n"+
			"  cat_name varchar(100) DEFAULT '${default}', \n"+
			"  schema_name varchar(100) DEFAULT NULL, \n"+
			"  tab_name varchar(100) DEFAULT NULL, \n"+
			"  mask_level varchar(45) DEFAULT NULL, \n"+
			"  tab_filter varchar(1000) DEFAULT NULL, \n"+
			"  tab_order_stmt varchar(1000) DEFAULT NULL, \n"+
			"  parallel_function varchar(10) DEFAULT 'MOD',\n"+
			"  parallel_field varchar(100) DEFAULT NULL, \n"+
			"  parallel_mod int(11) DEFAULT '1', \n"+
			"  tab_desc longtext, \n"+
			"  sample_size int(11) DEFAULT NULL, \n"+
			"  sample_filter varchar(1000) DEFAULT NULL, \n"+
			"  partition_flag varchar(3) DEFAULT 'NO', \n"+
			"  discovery_flag varchar(3) DEFAULT 'YES', \n"+
			"  partition_used varchar(3) DEFAULT 'NO', \n"+
			"  export_plan varchar(20) DEFAULT 'EXPORT_MASKING', \n"+ // EXPORT_MASKING, EXPORT_FIRST, EXPORT_FROM_CTAS
			"  skip_drop_index varchar(3) default 'NO', \n"+
			"  skip_drop_constraint varchar(3) default 'NO', \n"+
			"  skip_drop_trigger varchar(3) default 'NO', \n"+
			"  hint_after_select varchar(1000) default null, \n"+
			"  hint_before_table varchar(1000) default null, \n"+
			"  hint_after_table varchar(1000) default null, \n"+
		  	"  check_existence_action varchar(20) default 'NONE', " + 
			"  check_existence_sql text, " + 
			"  check_existence_on_fields text, " + 
			"  recursive_fields varchar(1000) default null, " + 
			"  rollback_needed varchar(3) default 'YES', " +
			"  tab_order int(3) DEFAULT '1', \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id), \n"+
			"  KEY ndx_tdm_tabs_app_id (app_id) \n" + 
			") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_discovery_rel ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  discovery_id int(11) DEFAULT NULL, \n"+
				"  tab_cat varchar(100) DEFAULT '${default}', \n"+
				"  tab_owner varchar(200) DEFAULT NULL, \n"+
				"  tab_name varchar(200) DEFAULT NULL, \n"+
				"  parent_tab_cat varchar(200) DEFAULT NULL, \n"+
				"  parent_tab_owner varchar(200) DEFAULT NULL, \n"+
				"  parent_tab_name varchar(200) DEFAULT NULL, \n"+
				"  child_rel_fields varchar(200) DEFAULT NULL, \n"+
				"  parent_pk_fields varchar(200) DEFAULT NULL, \n"+
				"  sample_count int(10) DEFAULT NULL, \n"+
				"  matched_count int(10) DEFAULT NULL, \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id), \n"+
				"	 KEY ndx_disc_rel_disc_id (discovery_id), \n"+
				"	 KEY ndx_disc_rel_tab_owner_name (tab_owner,tab_name), \n"+
				"	 KEY ndx_disc_rel_parent_tab_owner_name (parent_tab_owner,parent_tab_name) \n"+
				" ) ENGINE=InnoDB DEFAULT CHARSET=utf8");	
	
	
	ret1.add("CREATE TABLE tdm_tabs_rel ( \n"+
			" id int(11) NOT NULL AUTO_INCREMENT, \n"+
			" tab_id int(11), \n"+
			" rel_tab_id int(11), \n"+
			" rel_type varchar(20), \n"+
			" pk_fields varchar(200),\n"+
			" rel_on_fields varchar(200), \n"+
			" rel_filter varchar(1000), \n"+
			" rel_order int(4) default 0, \n"+ 
			" PRIMARY KEY (id), \n"+
		  	" UNIQUE KEY id_UNIQUE (id) \n"+
			" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");		
	
	ret1.add("CREATE TABLE tdm_tabs_need ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  tab_id int(11) DEFAULT NULL, \n"+
				"  app_id int(11) DEFAULT NULL, \n"+
				"  copy_filter_id int(11) DEFAULT NULL, \n"+
				"  rel_on_fields varchar(200) DEFAULT NULL, \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				" ) ENGINE=InnoDB AUTO_INCREMENT=100028 DEFAULT CHARSET=utf8;");	
	
	
	ret1.add("CREATE TABLE tdm_apps_rel ( \n"+
			" id int(11) NOT NULL AUTO_INCREMENT, \n"+
			" app_id int(11), \n"+
			" rel_app_id int(11), \n"+
			" filter_id int(11), \n"+
			" filter_value varchar(1000) DEFAULT NULL, \n"+
			" run_after_app_id int(11) default NULL, \n"+ 
			" rel_order int(4) default 0, \n"+ 
			" PRIMARY KEY (id), \n"+
	  	" UNIQUE KEY id_UNIQUE (id) \n"+
			" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");		
	
	ret1.add("CREATE TABLE tdm_task_assignment ( \n"+
			"  work_plan_id int(11) DEFAULT NULL, \n"+
			"  work_package_id int(11) DEFAULT NULL, \n"+
			"  task_id int(11) DEFAULT NULL, \n"+
			"  last_activity_date datetime DEFAULT NULL, \n"+
			"  status varchar(45) DEFAULT NULL, \n"+
			"  worker_id int(11) DEFAULT NULL, \n"+
			"  KEY tdm_task_ass_wp_ndx (work_plan_id), \n"+
			"  KEY tdm_task_ass_task_id (task_id) \n"+
			") ENGINE=MEMORY DEFAULT CHARSET=utf8;"); 
	
	ret1.add("CREATE TABLE tdm_work_package ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  wp_name varchar(1000) DEFAULT NULL, \n"+
			"  original_wpack_id int(11) DEFAULT NULL, \n"+
			"  work_plan_id int(11) DEFAULT NULL, \n"+
			"  status varchar(45) DEFAULT 'NEW', \n"+
			"  master_id int(11) DEFAULT NULL, \n"+
			"  execution_order int(5) DEFAULT 1, \n"+
			"  tab_id int(11) DEFAULT NULL, \n"+
			"  schema_name varchar(2000) DEFAULT NULL, \n"+
			"  table_name varchar(100) DEFAULT NULL, \n"+
			"  mask_level varchar(45) DEFAULT NULL, \n"+
			"  filter_condition varchar(1000) DEFAULT NULL, \n"+
			"  parallel_condition varchar(1000) DEFAULT NULL, \n"+
			"  order_by_stmt varchar(1000) DEFAULT NULL, \n"+
			"  sql_statement text, \n"+
			"  mask_params text, \n"+
			"  create_date datetime DEFAULT NULL, \n"+
			"  assign_date datetime DEFAULT NULL, \n"+
			"  start_date datetime DEFAULT NULL, \n"+
			"  end_date datetime DEFAULT NULL, \n"+
			"  last_activity_date datetime DEFAULT NULL, \n"+
			"  duration int(11) DEFAULT NULL, \n"+
			"  export_count int(11) DEFAULT NULL, \n"+
			"  all_count int(11) DEFAULT NULL, \n"+
			"  done_count int(11) DEFAULT NULL, \n"+
			"  success_count int(11) DEFAULT NULL, \n"+
			"  fail_count int(11) DEFAULT NULL, \n"+
			"  err_info longtext, \n"+
			"  last_rowid varchar(100) DEFAULT NULL, \n"+
			"  sample_size int(11) DEFAULT NULL, \n"+
			"  sample_filter varchar(1000) DEFAULT NULL, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id), \n"+
			"  KEY ndx_wpc_wpl_id (work_plan_id), \n"+
			"  KEY ndx_wpc_status (status) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_work_plan ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  work_plan_name varchar(1000) DEFAULT 'MASK', \n"+
			"  wplan_type varchar(20) DEFAULT NULL, \n"+
			"  status varchar(45) DEFAULT 'NEW', \n"+
			"  cancel_flag varchar(3) DEFAULT NULL, \n"+
			"  created_by int(11) DEFAULT NULL, \n"+
			"  create_date datetime DEFAULT NULL, \n"+
			"  start_date datetime DEFAULT NULL, \n"+
			"  end_date datetime DEFAULT NULL, \n"+
			"  last_activity_date datetime DEFAULT NULL, \n"+
			"  on_error_action varchar(10) default 'CONTINUE', \n"+
			"  execution_type varchar(10) default 'PARALLEL', \n"+
			"  env_id int(11) DEFAULT NULL, \n"+
			"  app_id int(11) DEFAULT NULL, \n"+
			"  target_env_id int(11) DEFAULT NULL, \n"+
			"  REC_SIZE_PER_TASK int(11) DEFAULT NULL, \n"+
			"  TASK_SIZE_PER_WORKER int(11) DEFAULT NULL, \n"+
			"  BULK_UPDATE_REC_COUNT int(11) DEFAULT NULL, \n"+
			"  COMMIT_LENGTH int(11) DEFAULT NULL, \n"+
			"  UPDATE_WPACK_COUNTS_INTERVAL int(11) DEFAULT NULL, \n"+
			"  RUN_TYPE varchar(45) DEFAULT NULL, \n"+
			"  INVALID_MESSAGE longtext, \n"+
			"  WARNING_MESSAGE longtext, \n"+
			"  target_owner_info longtext, \n"+
			"  master_limit int(11) DEFAULT NULL, \n"+
			"  worker_limit int(11) DEFAULT NULL, \n"+
			"  prep_script_log mediumtext, \n"+
			"  post_script_log mediumtext, \n"+
			"  copy_filter int(11), \n"+
			"  copy_filter_bind varchar(1000), \n"+
			"  copy_rec_count int(11), \n"+
			"  copy_repeat_count int(11), \n"+
			"  email_address varchar(100), \n"+
			"  run_options varchar(1000) default null,\n"+
			"  post_script mediumtext,\n"+
			"  repeat_period varchar(20) default 'NONE', \n" +
			"  repeat_by int(5) default 0, \n"+
			"  repeat_parameters text default null, \n"+
			"  main_work_plan_id int(11) default 0, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");

	ret1.add("CREATE TABLE tdm_work_plan_dependency ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  work_plan_id int(11), \n"+
			"  depended_work_plan_id int(11), \n"+
			"  dependency_order int(11) DEFAULT 0, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
		
	ret1.add("CREATE TABLE tdm_worker ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  worker_name varchar(100) DEFAULT NULL, \n"+
			"  status varchar(45) DEFAULT 'FREE', \n"+
			"  last_heartbeat datetime DEFAULT NULL, \n"+
			"  hostname varchar(100) DEFAULT NULL, \n"+
			"  assign_date datetime DEFAULT NULL, \n"+
			"  start_date datetime DEFAULT NULL, \n"+
			"  finish_date datetime DEFAULT NULL, \n"+
			"  hiring_master_id int(11) DEFAULT NULL, \n"+
			"  hiring_date datetime DEFAULT NULL, \n"+
			"  cancel_flag varchar(3) DEFAULT NULL, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=MEMORY AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
	
	
	ret1.add("CREATE TABLE tdm_discovery ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  discovery_type varchar(10) DEFAULT 'MASK', \n"+
				"  discovery_title varchar(1000) DEFAULT 'NEW', \n"+
				"  status varchar(45) DEFAULT 'NEW', \n"+
				"  cancel_flag varchar(3) DEFAULT 'NO', \n"+
				"  sector_id int(11) DEFAULT NULL, \n"+
				"  app_id int(11) DEFAULT NULL, \n"+
				"  env_id int(11) DEFAULT NULL, \n"+
				"  schema_name varchar(1000) DEFAULT 'NEW', \n"+
				"  sample_count int(6) DEFAULT 1000, \n"+
				"  create_date datetime DEFAULT NULL, \n"+
				"  start_date datetime DEFAULT NULL, \n"+
				"  heartbeat datetime DEFAULT NULL, \n"+
				"  finish_date datetime DEFAULT NULL, \n"+
				"  progress int(5) DEFAULT NULL, \n"+
				"  progress_desc varchar(1000) DEFAULT NULL, \n"+
				"  error_msg varchar(1000) DEFAULT NULL, \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE_DISC (id) \n"+
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_discovery_sector ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  description varchar(200), \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE_DISC_SECTOR (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_discovery_sector_rule ( \n"+
			 " id int(11) NOT NULL AUTO_INCREMENT, \n"+
			 " discovery_sector_id int(11) DEFAULT NULL, \n"+
			 " discovery_rule_id int(11) DEFAULT NULL, \n"+
			 " PRIMARY KEY (id), \n"+
			 " UNIQUE KEY id_UNIQUE_DISC_SECTOR_RULE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE tdm_discovery_target ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  description varchar(1000), \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE_DISC_TAR (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8");
	
	ret1.add("truncate table tdm_discovery_target");
	
	ret1.add("INSERT INTO tdm_discovery_target (id,description) VALUES (1,'Individual Info')");
	ret1.add("INSERT INTO tdm_discovery_target (id,description) VALUES (2,'Address Info')");
	ret1.add("INSERT INTO tdm_discovery_target (id,description) VALUES (3,'Email address')");
	ret1.add("INSERT INTO tdm_discovery_target (id,description) VALUES (4,'Birth Date')");
	ret1.add("INSERT INTO tdm_discovery_target (id,description) VALUES (5,'URI or IP info')");
	ret1.add("INSERT INTO tdm_discovery_target (id,description) VALUES (6,'Telephone/Fax/GSM Number Info')");
	ret1.add("INSERT INTO tdm_discovery_target (id,description) VALUES (7,'ID Info')");
	ret1.add("INSERT INTO tdm_discovery_target (id,description) VALUES (8,'Financial Info')");
	ret1.add("INSERT INTO tdm_discovery_target (id,description) VALUES (9,'Corporate Info')");
	ret1.add("INSERT INTO tdm_discovery_target (id,description) VALUES ('10', 'Other')");


	
	ret1.add("CREATE TABLE tdm_discovery_rule ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  discovery_target_id int(11) DEFAULT NULL, \n"+
			"  rule_type varchar(10) DEFAULT 'MATCHES', \n"+
			"  description varchar(1000), \n"+
			"  regex varchar(1000), \n"+
			"  script text, \n"+
			"  field_names varchar(4000), \n" + 
			"  rule_weight int(3) DEFAULT 10, \n" + 
			"  is_valid varchar(3) DEFAULT 'YES', \n" + 
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE_DISC_RULE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8");
	

	ret1.add("truncate table tdm_discovery_rule");
	
	ret1.add("CREATE TABLE tdm_discovery_result ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  discovery_id int(11) DEFAULT NULL, \n"+
			"  catalog_name varchar(100) DEFAULT '${default}', \n"+
			"  schema_name varchar(200), \n"+
			"  table_name varchar(200), \n"+
			"  field_name varchar(200), \n"+
			"  field_type varchar(200), \n"+
			"  discovery_target_id int(11) DEFAULT NULL, \n"+
			"  discovery_rule_id int(11) DEFAULT NULL, \n"+
			"  match_count int(11) DEFAULT NULL, \n"+
			"  sample_count int(11) DEFAULT NULL, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE_DISC_RES (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
	
	ret1.add("create table tdm_add_process ( \n"+
			"		process_class varchar(100) default null, \n"+
			"		process_count varchar(10) default null \n"+
			"		) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8;");
	
	ret1.add("CREATE TABLE tdm_task_summary ( \n"+
			"  work_plan_id int(11) DEFAULT NULL, \n"+
			"  work_package_id int(11) DEFAULT NULL, \n"+
			"  status varchar(20) DEFAULT NULL, \n"+
			"  task_count int(11) DEFAULT NULL, \n"+
			"  avg_duration int(11) DEFAULT NULL, \n"+
			"  rec_count int(11) DEFAULT NULL, \n"+
			"  done_count int(11) DEFAULT NULL, \n"+
			"  success_count int(11) DEFAULT NULL, \n"+
			"  fail_count int(11) DEFAULT NULL \n"+
			") ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	
	
	ret1.add("CREATE TABLE tdm_copy_filter ( \n"+
			 " id int(11) NOT NULL AUTO_INCREMENT, \n"+
			 " app_id int(11) NOT NULL, \n"+
			 " tab_id int(11) NOT NULL, \n"+
			 " filter_name varchar(200) DEFAULT NULL, \n"+
			 " filter_type varchar(20) DEFAULT NULL, \n"+
			 " filter_sql text DEFAULT NULL, \n"+
			 " format_1 varchar(1000) DEFAULT NULL, \n"+
			 " format_2 varchar(1000) DEFAULT NULL, \n"+
			 " list_id_1 int(11) , \n"+
			 " list_id_2 int(11) , \n"+
			 " list_source_1 varchar(10) default 'STATIC' , \n"+
			 " list_source_2 varchar(10) default 'STATIC' , \n"+
			 " PRIMARY KEY (id), \n"+
			 " UNIQUE KEY id_UNIQUE (id) \n"+
			 "  ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8; ");
	
	ret1.add("CREATE TABLE tdm_copy_app_checklist ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  app_id int(11) DEFAULT NULL, \n"+
				"  checklist_name varchar(200) DEFAULT NULL, \n"+
				"  checklist_statement text, \n"+
				"  not_check varchar(3) DEFAULT 'NO', \n"+
				"  operand varchar(30) DEFAULT 'EQUALS', \n"+
				"  operand_parameters text, \n"+
				"  valid varchar(3) DEFAULT 'NO', \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				" ) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8");


	ret1.add("CREATE TABLE tdm_user ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  username varchar(100) DEFAULT NULL, \n"+
			"  password varchar(100) DEFAULT NULL, \n"+
			"  email varchar(200) DEFAULT NULL, \n"+
			"  fname varchar(50) DEFAULT NULL, \n"+
			"  lname varchar(50) DEFAULT NULL, \n"+
			"  valid varchar(1) DEFAULT 'Y', \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=999 DEFAULT CHARSET=utf8;");
	
	
	ret1.add("truncate table tdm_user");
	ret1.add("INSERT INTO tdm_user (id,username,password,email,fname,lname,valid) VALUES (1,'admin','3659503239524c327a61493d','admin@acme.com','Admin','Admin','Y')");

	
	
	ret1.add("CREATE TABLE tdm_role ( \n"+
			 " id int(11) NOT NULL AUTO_INCREMENT, \n"+
			 " shortcode varchar(20) DEFAULT NULL, \n"+
			 " description varchar(100) DEFAULT NULL, \n"+
			 " PRIMARY KEY (id), \n"+
			 " UNIQUE KEY id_UNIQUE (id) \n"+
			 " ) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;");
	
	ret1.add("truncate table tdm_role");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (1,'ADMIN','Administrator')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (2,'DESIGN','Designer')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (3,'RUN','Runner')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (4,'COPYUSER','Copying User')");

	
	
	ret1.add("CREATE TABLE tdm_user_role ( \n"+
			"  user_id int(11) NOT NULL, \n"+
			"  role_id int(11) NOT NULL \n"+
			") ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	
	ret1.add("truncate table tdm_user_role");

	ret1.add("insert into tdm_user_role values (1,1)");
	ret1.add("insert into tdm_user_role values (1,2)");
	ret1.add("insert into tdm_user_role values (1,3)");
	ret1.add("insert into tdm_user_role values (1,4)");

	
	ret1.add("CREATE TABLE tdm_group ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  group_name VARCHAR(200)  NULL, \n" +
			"	  group_description TEXT  NULL, \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_group_members ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  group_id int(11), \n" +
			"	  member_id int(11), \n" +
			"	  group_membership_description TEXT , \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_group_environments ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  group_id int(11), \n" +
			"	  env_id int(11), \n" +
			"	  env_type varchar(10) DEFAULT NULL , \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_group_applications ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  group_id int(11), \n" +
			"	  app_id int(11), \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_parameters ( \n"+
			"  param_name varchar(200) DEFAULT NULL, \n"+
			"  param_value text DEFAULT NULL \n"+
			") ENGINE=InnoDB DEFAULT CHARSET=utf8");
	
	
	
	ret1.add("CREATE TABLE tdm_audit_logs ( \n"+
			 " id int(11) not null AUTO_INCREMENT, \n"+
			 " table_name varchar(100) not null, \n"+
			 " table_id int(11) not null, \n"+
			 " log_action varchar(10), \n" +
			 " log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n"+
			 " log_user varchar(100), \n"+
			 " old_record mediumtext, \n"+
			 " primary key (id), \n"+
			 " UNIQUE KEY id_UNIQUE (id) \n"+
			 " ) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8");

	ret1.add("truncate table tdm_parameters");

	ret1.add("insert into tdm_parameters (param_name, param_value) values ('EXPORT_STACK_SIZE','100000')");
	ret1.add("insert into tdm_parameters (param_name, param_value) values ('DISCOVERY_SAMPLE_SIZE','1000')");
	ret1.add("insert into tdm_parameters (param_name, param_value) values ('AUTHENTICATION_METHOD','LOCAL')");
	ret1.add("insert into tdm_parameters (param_name, param_value) values ('CONFIG_USERNAME','"+tdm_user+"')");
	ret1.add("insert into tdm_parameters (param_name, param_value) values ('CONFIG_PASSWORD','"+tdm_pass+"')");

	ret1.add("CREATE TABLE tdm_tab_comment ( " + 
				"  env_id int(11), " + 
				"  table_cat varchar(100) default '${default}', " + 
				"  table_owner varchar(100) default NULL, " + 
				"  table_name varchar(100) default NULL, " + 
				"  table_comment mediumtext, " + 
				"  app_type varchar(10) default 'COPY', " + 
				"  discard_flag varchar(3) default 'NO' " + 
				" ) ENGINE=InnoDB DEFAULT CHARSET=utf8");

	ret1.add("CREATE TABLE tdm_copy_script ( " + 
				"  id int(11) NOT NULL AUTO_INCREMENT, " + 
				"  app_id int(11) default null, " + 
				"  script_description varchar(200), " + 
				"  family_id int(11) default null, " + 
				"  stage varchar(10), " + 
				"  target varchar(10),  " + 
				"  script_body text, " + 
				"  script_order int(11) default 1, " + 
				"  PRIMARY KEY (id), " + 
				"  UNIQUE KEY id_UNIQUE_DISC (id) " + 
				") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE tdm_proxy ( \n" +
				"  id int(11) NOT NULL AUTO_INCREMENT, \n" +
				"  proxy_name varchar(200) DEFAULT NULL, \n" +
				"  status varchar(45) DEFAULT 'NEW', \n" +
				"  proxy_type varchar(45) DEFAULT 'ORACLE', \n" +
				"  secure_client varchar(3) default 'NO', \n" +
				"  secure_public_key varchar(1000), \n" +
				"  proxy_port VARCHAR(200) NOT NULL, \n" +
				"  target_host varchar(200) DEFAULT '127.0.0.1', \n" +
				"  target_port int(5) NOT NULL, \n" +
				"  proxy_charset varchar(100) DEFAULT 'UTF-8', \n" +
				"  target_app_id int(11), \n" +
				"  target_env_id int(11), \n" +
				"  protocol_configuration_id int(11) default 0, \n" +
				"  max_package_size int(10) default 4096, \n" +
				"  is_debug varchar(3) DEFAULT 'NO', \n" +
				"  extra_args varchar(1000), \n" +
				"  start_date datetime DEFAULT NULL, \n" +
				"  last_heartbeat datetime DEFAULT NULL, \n" +
				"  hostname varchar(100) DEFAULT NULL, \n" +
				"  cancel_flag varchar(3) DEFAULT NULL, \n" +
				"  reload_flag varchar(3) DEFAULT NULL, \n" +
				"  last_reload_time datetime DEFAULT NULL, \n" +
				"  error_log text, \n" +
				"  last_configuration mediumblob \n"+
				"  PRIMARY KEY (id), \n" +
				"  UNIQUE KEY id_UNIQUE (id) \n" +
				" ) ENGINE=InnoDB AUTO_INCREMENT=1  DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE tdm_proxy_session ( \n"+
				"  id int(11) NOT NULL, \n"+
				"  proxy_id int(11) DEFAULT NULL, \n"+
				"  status varchar(10) DEFAULT NULL, \n"+
				"  start_date datetime DEFAULT NULL, \n"+
				"  finish_date datetime DEFAULT NULL, \n"+
				"  username varchar(200) DEFAULT NULL, \n"+
				"  session_info text, \n"+
				"  last_activity_date datetime DEFAULT NULL, \n"+
				"  exception_time_to datetime DEFAULT NULL, \n"+
				"  cancel_flag varchar(3) DEFAULT 'NO', \n"+
				"  tracing_flag varchar(3) DEFAULT 'NO', \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id), \n"+
				"  KEY proxy_session_ndx_proxy_id (proxy_id) \n"+
				" ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_proxy_log ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  log_date datetime DEFAULT NULL, \n" +
				"  proxy_id int(11), \n"+
				"  proxy_session_id int(11), \n"+
				"  current_schema varchar(200) default null, \n"+
				"  statement_type varchar(50) default null, \n"+
				"  original_sql text, \n"+
				"  sample_sql text, \n"+
				"  masking_sql text, \n"+
				"  sample_count int(11), \n"+
				"  bind_info text, \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id),  \n"+
				"	  KEY proxy_log_ndx_proxy_id (proxy_id ASC), \n" +
				"	  KEY proxy_log_ndx_session_id (proxy_session_id ASC) \n" +
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE tdm_proxy_config_log (   \n" +
			"	  proxy_id int(11) DEFAULT NULL, \n" +
			"	  schema_name varchar(100) DEFAULT NULL, \n" +
			"	  table_name varchar(100) DEFAULT NULL, \n" +
			"	  last_activity_date datetime DEFAULT NULL, \n" +
			"	  log_info text, \n" +
			"	  KEY proxy_session_ndx_proxy_id (proxy_id) \n" +
			"	) ENGINE=InnoDB DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE tdm_proxy_policy_group ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  policy_group_name varchar(200) DEFAULT NULL, \n"+
				"  check_field varchar(200)  default 'CURRENT_USER', \n" +
				"  check_rule varchar(45) DEFAULT NULL, \n"+
				"  check_parameter text, \n"+
				"  env_id int(11) default null, \n"+
				"  case_sensitive varchar(10)  default 'YES', \n"+
				"  valid varchar(10)  default 'YES', \n"+
				"  record_limit int(11)  default 0, \n"+
				"  start_debuging varchar(10)  default 'NO', \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_proxy_log_exception ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  app_id int(11) , " + 
			"  check_field varchar(200)  default 'CURRENT_USER', \n" +
			"  check_rule varchar(45) DEFAULT NULL, \n"+
			"  check_parameter text, \n"+
			"  env_id int(11) default null, \n"+
			"  case_sensitive varchar(10)  default 'YES', \n"+
			"  valid varchar(10)  default 'YES', \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE tdm_proxy_param_override ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  app_id int(11) DEFAULT NULL, \n"+
				"  policy_group_id int(11) DEFAULT NULL, \n"+
				"  sql_logging varchar(45) DEFAULT 'SYSTEM', \n"+
				"  iddle_timeout varchar(45) DEFAULT 'SYSTEM', \n"+
				"  deny_connection varchar(45) DEFAULT 'NO', \n"+
				"  calendar_id int(11) DEFAULT NULL, \n"+
				"  session_validation_id int(11) DEFAULT NULL, \n"+
				"  valid varchar(3) DEFAULT 'YES', \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_proxy_statement_exception ( \n"+
			"	  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"	  app_id int(11), \n"+
			"  	  check_field varchar(20)  default 'SQL', \n" +
			"	  check_rule varchar(45) DEFAULT 'CONTAINS', \n"+
			"	  check_parameter text, \n"+
			"     env_id int(11) default null, \n"+
			"	  new_command text, \n"+
			"	  case_sensitive varchar(10) DEFAULT 'YES', \n"+
			"	  valid varchar(3) DEFAULT 'YES', \n"+
			"	  PRIMARY KEY (id), \n"+
			"	  UNIQUE KEY id_UNIQUE (id) \n"+
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_proxy_exception ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  exception_scope varchar(20) default 'APPLICATION', \n"+
				"  exception_obj_id int(11), \n"+
				"  policy_group_id int(11) DEFAULT NULL, \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_proxy_rules ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  app_id int(11) DEFAULT NULL, \n"+
				"  rule_order int(10) default 0, \n"+
				"  rule_scope varchar(10) default 'DATA', \n"+
				"  rule_type varchar(20) default 'CONTAINS', \n"+
				"  rule_parameter1 text, \n"+
				"  env_id int(11) default null, \n"+
				"  rule_parameter2 text, \n"+
				"  min_match_rate int(3), \n"+
				"  mask_prof_id int(11), \n"+
				"  rule_notes text, \n"+
				"  valid varchar(3) default 'YES', \n" + 
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id), \n"+
				"		KEY dm_rules_ndx_app_id (app_id ASC) \n"+
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_pool ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  app_id int(11) NOT NULL, \n"+
				"  family_id int(11) , \n"+
				"  base_sql text, \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE tdm_pool_lov ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  pool_id int(11) DEFAULT NULL, \n"+
				"  lov_name varchar(200) DEFAULT NULL, \n"+
				"  family_id int(11) DEFAULT 0, \n"+
				"  lov_statement text, \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_pool_group ( \n"+
				"	  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"	  pool_id int(11) DEFAULT NULL, \n"+
				"	  group_name varchar(200) DEFAULT NULL, \n"+
				"	  order_no int(3) default 1, \n"+
				"	  PRIMARY KEY (id), \n"+
				"	  UNIQUE KEY id_UNIQUE (id) \n"+
				"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE tdm_pool_property ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  pool_id int(11) NOT NULL, \n"+
				"  property_name varchar(40), \n"+
				"  property_title varchar(200), \n"+
				"  group_id int(11) default 0, \n"+
				"  is_searchable varchar(3) default 'YES', \n"+
				"  lov_id int(11) default 0, \n"+
				"  is_indexed varchar(3) default 'NO', \n"+
				"  is_visible_on_search varchar(3) default 'YES', \n"+
				"  data_type varchar(10) default 'STRING', \n"+
				"  get_method varchar(10) default 'DB', \n"+
				"  source_code text, \n"+
				"  property_family_id int(11), \n"+
				"  target_url varchar(1000), \n"+
				"  extract_method varchar(10) default 'NONE', \n"+
				"  extract_method_parameter text, \n"+
				"  order_no int(3) default 0, \n"+
				"  is_valid varchar(3) default 'YES', \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_pool_instance ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  app_id int(11) DEFAULT NULL, \n"+
				"  target_id varchar(200) DEFAULT NULL, \n"+
				"  target_pool_size int(11) default 0, \n"+
				"  is_debug varchar(3) default 'NO', \n"+
				"  paralellism_count int(4) default 10, \n"+
				"  status varchar(16) DEFAULT 'NEW', \n"+
				"  start_date datetime DEFAULT NULL, \n"+
				"  last_update_date datetime DEFAULT NULL, \n"+
				"  last_check_date datetime DEFAULT NULL, \n"+
				"  pool_size int(11) default 0, \n"+
				"  reserved_size int(11) default 0, \n"+
				"  cancel_flag varchar(3) default 'NO', \n"+
				"  reload_flag varchar(3) default 'NO', \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE tdm_proxy_calendar ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  calendar_name varchar(200) DEFAULT NULL, \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");

	
	ret1.add("CREATE TABLE tdm_proxy_monitoring ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  monitoring_name varchar(200) DEFAULT NULL, \n"+
				"  monitoring_interval int(5) DEFAULT 0, \n"+
				"  monitoring_period varchar(10) DEFAULT 'MINUTE', \n"+
				"  monitoring_threashold int(6) DEFAULT 0, \n"+
				"  monitoring_email varchar(200) DEFAULT null, \n"+
				"  monitoring_blacklist varchar(3) DEFAULT 'YES', \n"+
				"  is_active varchar(3) DEFAULT 'YES', \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_proxy_monitoring_policy_group ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  monitoring_id int(11) NOT NULL, \n"+
				"  policy_group_id int(11) DEFAULT NULL, \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				") ENGINE=InnoDB AUTO_INCREMENT=1  DEFAULT CHARSET=utf8");

	ret1.add("CREATE TABLE tdm_proxy_monitoring_application ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  monitoring_id int(11) NOT NULL, \n"+
			"  app_id int(11) DEFAULT NULL, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=1  DEFAULT CHARSET=utf8");

	ret1.add("CREATE TABLE tdm_proxy_monitoring_policy_rules ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  monitoring_id int(11) NOT NULL, \n"+
				"  rule_type varchar(20) DEFAULT 'COLUMN', \n"+
				"  rule_description varchar(200) DEFAULT NULL, \n"+
				"  rule_catalog_name varchar(200) DEFAULT NULL, \n"+
				"  rule_schema_name varchar(200) DEFAULT NULL, \n"+
				"  rule_object_name varchar(200) DEFAULT NULL, \n"+
				"  rule_column_name varchar(200) DEFAULT NULL, \n"+
				"  rule_expression varchar(200) DEFAULT NULL, \n"+
				"  is_active varchar(3) DEFAULT 'YES', \n"+
				" PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				") ENGINE=InnoDB AUTO_INCREMENT=1  DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_proxy_calendar_exception ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  calendar_id int(11) NOT NULL, \n"+
			"  calendar_exception_name varchar(200) DEFAULT NULL, \n"+
			"  exception_start_time datetime, \n"+
			"  exception_end_time datetime, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");

	
	ret1.add("CREATE TABLE tdm_proxy_session_validation ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  session_validation_name varchar(200) DEFAULT NULL, \n"+
				"  for_statement_check_regex varchar(1000), \n"+
				"  check_start int(11) DEFAULT 0, \n"+
				"  check_duration int(11) DEFAULT 60000, \n"+
				"  limit_session_duration int(11) DEFAULT 0, \n"+
				"  max_attempt_count int(11) DEFAULT 1, \n"+
				"  extraction_js_for_par1 text, \n"+
				"  extraction_js_for_par2 text, \n"+
				"  extraction_js_for_par3 text, \n"+
				"  extraction_js_for_par4 text, \n"+
				"  extraction_js_for_par5 text, \n"+
				"  controll_method varchar(10) default 'DATABASE', \n"+
				"  controll_statement text, \n"+
				"  controll_db_id int(11) default null, \n"+
				"  expected_result varchar(1000), \n"+ 
				"  validate_identical_sessions varchar(3) DEFAULT 'NO', \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id) \n"+
				") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8";
	
	ret1.add("CREATE TABLE tdm_proxy_monitoring_columns ( \n"+
				"  id int(11) NOT NULL, \n"+
				"  proxy_id int(11) NOT NULL, \n"+
				"  proxy_session_id int(11) DEFAULT '0', \n"+
				"  policy_group_id int(11) DEFAULT '0', \n"+
				"  monitoring_time datetime, \n"+
				"  catalog_name varchar(100) default '${default}', \n"+
				"  schema_name varchar(100) default NULL, \n"+
				"  object_name varchar(100) default NULL, \n"+
				"  column_name varchar(100) default NULL, \n"+
				"  expression varchar(200) default NULL, \n"+
				" PRIMARY KEY (id, proxy_id), \n"+
				"  UNIQUE KEY id_UNIQUE (id, proxy_id), \n"+
				"  KEY mon_catalog_ndx (catalog_name), \n"+
				"  KEY mon_schema_ndx (schema_name), \n"+
				"  KEY mon_object_ndx (object_name), \n"+
				"  KEY mon_column_ndx (column_name), \n"+
				"  KEY mon_expression_ndx (expression), \n"+
				"  KEY mon_proxy_id_ndx (proxy_id) \n"+
				" ) ENGINE=MEMORY DEFAULT CHARSET=utf8";
	
	ret1.add("CREATE TABLE tdm_proxy_monitoring_columns_archive ( \n"+
			"  id int(11) NOT NULL, \n"+
			"  proxy_id int(11) NOT NULL, \n"+
			"  proxy_session_id int(11) DEFAULT '0', \n"+
			"  policy_group_id int(11) DEFAULT '0', \n"+
			"  monitoring_time datetime, \n"+
			"  catalog_name varchar(100) default '${default}', \n"+
			"  schema_name varchar(100) default NULL, \n"+
			"  object_name varchar(100) default NULL, \n"+
			"  column_name varchar(100) default NULL, \n"+
			"  expression varchar(200) default NULL, \n"+
			" PRIMARY KEY (id, proxy_id), \n"+
			"  UNIQUE KEY id_UNIQUE (id, proxy_id), \n"+
			"  KEY mon_arc_catalog_ndx (catalog_name), \n"+
			"  KEY mon_arc_schema_ndx (schema_name), \n"+
			"  KEY mon_arc_object_ndx (object_name), \n"+
			"  KEY mon_arc_column_ndx (column_name), \n"+
			"  KEY mon_arc_expression_ndx (expression), \n"+
			"  KEY mon_arc_proxy_id_ndx (proxy_id) \n"+
			" ) ENGINE=InnoDB DEFAULT CHARSET=utf8";
	
	
	ret1.add("CREATE TABLE tdm_proxy_monitoring_blacklist ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  proxy_id int(11) DEFAULT NULL, \n"+
				"  proxy_session_id int(11) DEFAULT '0', \n"+
				"  blacklist_time datetime DEFAULT NULL, \n"+
				"  machine varchar(100) DEFAULT NULL, \n"+
				"  osuser varchar(100) DEFAULT NULL, \n"+
				"  dbuser varchar(100) DEFAULT NULL, \n"+
				"  is_deactivated varchar(3) DEFAULT 'NO', \n"+
				"  deactivated_by_user_id int(11) DEFAULT NULL, \n"+
				"  deactivation_time datetime DEFAULT NULL, \n"+
				"  deactivation_note varchar(100) DEFAULT NULL, \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id), \n"+
				"  KEY mon_proxy_id_ndx (proxy_id) \n"+
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_proxy_monitoring_email_log ( \n"+
				"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
				"  proxy_id int(11) DEFAULT NULL, \n"+
				"  monitoring_id int(11) DEFAULT '0', \n"+
				"  from_address varchar(200) DEFAULT NULL, \n"+
				"  to_address varchar(2000) DEFAULT NULL, \n"+
				"  email_body text DEFAULT NULL, \n"+
				"  sent_date datetime DEFAULT NULL, \n"+
				"  is_success varchar(3) DEFAULT 'NO', \n"+
				"  sending_logs text DEFAULT NULL, \n"+
				"  PRIMARY KEY (id), \n"+
				"  UNIQUE KEY id_UNIQUE (id), \n"+
				"  KEY mon_proxy_id_ndx (proxy_id) \n"+
				") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");

	//replace \ with \\
	String tdm_home_x="";
	for (int i=0;i<tdm_home.length();i++) {
		tdm_home_x=tdm_home_x+tdm_home.substring(i,i+1);
		if (tdm_home.substring(i,i+1).equals("\\")) tdm_home_x=tdm_home_x+"\\";
	}
	ret1.add("insert into tdm_parameters (param_name, param_value) values ('TDM_PROCESS_HOME','"+tdm_home_x+"')");
	
	
	return ret1;
}




%>