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




	
	return err;
}



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
	ret1.add("INSERT INTO tdm_ref (ref_type, ref_name, ref_desc, ref_order,flexval1,flexval2,flexval3) VALUES ('DB_TYPE', 'net.sourceforge.jtds.jdbc.Driver', 'Sybase', '5','SYBASE','select 1 from dual|jdbc:jtds:sybase://<HOST>:<PORT>/<DB>','')");
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
			"  db_password varchar(45) DEFAULT NULL, \n"+
			"  asp_connstr varchar(1000) DEFAULT NULL, \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=999 DEFAULT CHARSET=utf8;");	

	
	
	ret1.add("CREATE TABLE tdm_manager ( \n"+
			"  status varchar(45) DEFAULT 'FREE', \n"+
			"  last_heartbeat datetime DEFAULT NULL, \n"+
			"  hostname varchar(100) DEFAULT NULL, \n"+
			"  cancel_flag varchar(3) DEFAULT NULL \n"+
			") ENGINE=MEMORY DEFAULT CHARSET=utf8;");
	
	
	
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
			"  schema_name varchar(100) DEFAULT NULL, \n"+
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
			"  email_address varchar(100), \n"+
			"  run_options varchar(1000) default null,\n"+
			"  post_script mediumtext,\n"+
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
	
	ret1.add("CREATE TABLE tdm_user ( \n"+
			"  id int(11) NOT NULL AUTO_INCREMENT, \n"+
			"  username varchar(100) DEFAULT NULL, \n"+
			"  password varchar(100) DEFAULT NULL, \n"+
			"  email varchar(200) DEFAULT NULL, \n"+
			"  fname varchar(50) DEFAULT NULL, \n"+
			"  lname varchar(50) DEFAULT NULL, \n"+
			"  lang varchar(20) DEFAULT NULL, \n"+
			"  authentication_method varchar(6) DEFAULT 'SYSTEM', \n"+
			"  valid varchar(1) DEFAULT 'Y', \n"+
			"  PRIMARY KEY (id), \n"+
			"  UNIQUE KEY id_UNIQUE (id) \n"+
			") ENGINE=InnoDB AUTO_INCREMENT=999 DEFAULT CHARSET=utf8;");
	
	
	ret1.add("truncate table tdm_user");
	ret1.add("INSERT INTO tdm_user (id,username,password,email,fname,lname,authentication_method, valid) VALUES (1,'admin','3659503239524c327a61493d','admin@acme.com','Admin','Admin','LOCAL','Y')");

	
	
	ret1.add("CREATE TABLE tdm_role ( \n"+
			 " id int(11) NOT NULL AUTO_INCREMENT, \n"+
			 " shortcode varchar(20) DEFAULT NULL, \n"+
			 " description varchar(100) DEFAULT NULL, \n"+
			 " PRIMARY KEY (id), \n"+
			 " UNIQUE KEY id_UNIQUE (id) \n"+
			 " ) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;");
	
	ret1.add("truncate table tdm_role");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (1,'ADMIN','Administrator')");
	//ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (2,'DESIGN','Designer')");
	//ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (3,'RUN','Runner')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (4,'MADDES','MAD Designer')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (5,'MADRM','MAD Release Manager')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (6,'MADUSR','MAD Consumer')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (7,'MADPLN','MAD Planner')");
	
	
	ret1.add("CREATE TABLE tdm_user_role ( \n"+
			"  user_id int(11) NOT NULL, \n"+
			"  role_id int(11) NOT NULL \n"+
			") ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	
	ret1.add("truncate table tdm_user_role");

	ret1.add("insert into tdm_user_role values (1,1)");
	ret1.add("insert into tdm_user_role values (1,2)");
	ret1.add("insert into tdm_user_role values (1,3)");
	ret1.add("insert into tdm_user_role values (1,4)");
	ret1.add("insert into tdm_user_role values (1,5)");
	
	
	
	ret1.add("CREATE TABLE tdm_parameters ( \n"+
			"  param_name varchar(200) DEFAULT NULL, \n"+
			"  param_value varchar(1000) DEFAULT NULL \n"+
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

	ret1.add("insert into tdm_parameters (param_name, param_value) values ('AUTHENTICATION_METHOD','LOCAL')");
	ret1.add("insert into tdm_parameters (param_name, param_value) values ('CONFIG_USERNAME','"+tdm_user+"')");
	ret1.add("insert into tdm_parameters (param_name, param_value) values ('CONFIG_PASSWORD','"+tdm_pass+"')");
	
	//replace \ with \\
	String tdm_home_x="";
	for (int i=0;i<tdm_home.length();i++) {
		tdm_home_x=tdm_home_x+tdm_home.substring(i,i+1);
		if (tdm_home.substring(i,i+1).equals("\\")) tdm_home_x=tdm_home_x+"\\";
	}
	ret1.add("insert into tdm_parameters (param_name, param_value) values ('TDM_PROCESS_HOME','"+tdm_home_x+"')");
	
	
	ret1.add("CREATE TABLE mad_request ( \n"+
			" id int(11) NOT NULL AUTO_INCREMENT, \n"+
			" request_type_id int(11), \n"+
			" is_saved varchar(3) default 'NO', " + 
			" status varchar(20) default 'NEW', \n"+
			" description varchar(400), \n"+
			" long_description text, \n"+
			" entuser int(11), \n"+
			" entdate timestamp, \n"+
			" deployment_slot_id int(11) default null, \n"+
			" deployment_slot_detail_id int(11) default null, \n"+
			" deployment_date timestamp null default null, \n"+
			" deployment_attempt_no  int(5) default 0, \n"+
			" PRIMARY KEY (id), \n"+
			" UNIQUE KEY id_UNIQUE (id), \n"+
			"   KEY ndx_mad_req_req_type_id (request_type_id), \n"+
			"   KEY ndx_mad_req_entuser (entuser), \n"+
			"   KEY ndx_mad_req_status (status) \n"+
			" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_history (  \n"+
			" id int(11) NOT NULL AUTO_INCREMENT,  \n"+
			" request_id int(11),  \n"+
			" description varchar(400),  \n"+
			" status varchar(20),  \n"+
			" deployment_slot_id int(11) default null,  \n"+
			" deployment_slot_detail_id int(11) default null,  \n"+
			" deployment_date timestamp null default null,  \n"+
			" history_action varchar(10),  \n"+
			" history_user int(11),  \n"+
			" history_date timestamp,  \n"+
			" history_host varchar(100),  \n"+
			" PRIMARY KEY (id),  \n"+
			" UNIQUE KEY id_UNIQUE (id),  \n"+
			"   KEY ndx_mad_req_hist_request_id (request_id) \n"+
			" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_work_plan ( \n" + 
			 " id INT NOT NULL AUTO_INCREMENT, \n" + 
			 " request_id VARCHAR(100) NULL, \n" + 
			 " work_plan_id INT NULL, \n" + 
			 " deployment_attempt_no  int(5), \n" + 
			 " PRIMARY KEY (id), \n" + 
			 " INDEX ndx_mad_req_wp_request_id (request_id ASC), \n" + 
			 " INDEX ndx_mad_req_wp_work_plan_id (work_plan_id ASC) \n" + 
			 " ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_work_package ( \n" + 
			 " id INT NOT NULL AUTO_INCREMENT, \n" + 
			 " request_id VARCHAR(100) NULL, \n" + 
			 " work_plan_id INT NULL, \n" + 
			 " work_package_id INT NULL, \n" + 
			 " deployment_attempt_no  int(11) default 0, " + 
			 " PRIMARY KEY (id), \n" + 
			 " INDEX ndx_mad_req_wp_request_id (request_id ASC), \n" + 
			 " INDEX ndx_mad_req_wp_work_package_id (work_package_id ASC) \n" + 
			 " ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	
	
	ret1.add("CREATE TABLE mad_keywords ( \n" +
			 " id INT NOT NULL AUTO_INCREMENT, \n" +
			 " object_type VARCHAR(100) NULL, \n" +
			 " object_id INT NULL, \n" +
			 " keywords MEDIUMTEXT NULL, \n" +
			 " PRIMARY KEY (id), \n" +
			 " INDEX ndx_mad_keywords_obj_type (object_type ASC), \n" +
			 " INDEX ndx_mad_keywords_obj_id (object_id ASC), \n" +
			 " FULLTEXT  ndx_mad_keywords_searchtext (keywords) \n" +
			 " ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	

	ret1.add("CREATE TABLE mad_deployment_slot ( \n" +
			 " id INT NOT NULL AUTO_INCREMENT, \n" +
			 " slot_type VARCHAR(20) default 'DAILY', \n" +
			 " slot_name varchar(200) NULL, \n" +
			 " is_valid varchar(3) default 'YES', \n" +
			 " freeze_period int(5) default 0, \n" +
			 " freeze_period_after int(5) default 0, \n" +
			 " PRIMARY KEY (id) \n" +
			 " ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	
	
	ret1.add("CREATE TABLE mad_deployment_slot_detail ( \n" +
			 " id INT NOT NULL AUTO_INCREMENT, \n" +
			 " slot_id VARCHAR(20) default 'DAILY', \n" +
			 " slot_name varchar(200), \n" +
			 " slot_description text, \n" +
			 " hourly_day_id int(2) null default -1, \n" +
			 " hourly_minute_id int(4) null default -1, \n" +
			 " daily_time timestamp null default null, \n" +
			 " is_valid varchar(3) default 'YES', \n" +
			 " PRIMARY KEY (id) \n" +
			 " ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	
	
	
	ret1.add("CREATE TABLE mad_query (  \n" +
			 " id INT NOT NULL AUTO_INCREMENT, \n" +
			 " query_name VARCHAR(200) NULL, \n" +
			 " query_statement TEXT NULL, \n" +
			 " created_user int(11) default 0, \n" +
			 " query_user int(11) default 0, \n" +
			 " PRIMARY KEY (id) \n" +
			 " ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	
	
	ret1.add("truncate table mad_query");
	
	ret1.add("INSERT INTO mad_query (id,query_name,query_statement,created_user,query_user) VALUES (1,'All','request_type_id in (select id from mad_request_type)',0,0)");
	ret1.add("INSERT INTO mad_query (id,query_name,query_statement,created_user,query_user) VALUES (2,'Only Packages','request_type_id in (select id from mad_request_type where request_group=\'PACKAGE\')',0,0)");
	ret1.add("INSERT INTO mad_query (id,query_name,query_statement,created_user,query_user) VALUES (3,'Only Deployments','request_type_id in (select id from mad_request_type where request_group=\'DEPLOYMENT\')',0,0)");
	ret1.add("INSERT INTO mad_query (id,query_name,query_statement,created_user,query_user) VALUES (4,'Only Requests','request_type_id in (select id from mad_request_type where request_group=\'REQUEST\')',0,0)");
	ret1.add("INSERT INTO mad_query (id,query_name,query_statement,created_user,query_user) VALUES (5,'Opened By Me','entuser=${curruser}',0,0)");
	ret1.add("INSERT INTO mad_query (id,query_name,query_statement,created_user,query_user) VALUES (6,'Opened By My Group','entuser in(${currgroup})',0,0)");
	ret1.add("INSERT INTO mad_query (id,query_name,query_statement,created_user,query_user) VALUES (7,'Waiting my action','id in (${actionrequestids})',0,0)");
	ret1.add("INSERT INTO mad_query (id,query_name,query_statement,created_user,query_user) VALUES (15,'Opened Last week','entdate between date_sub(now(),INTERVAL 1 WEEK) and now()',0,0)");
	ret1.add("INSERT INTO mad_query (id,query_name,query_statement,created_user,query_user) VALUES (16,'Opened Last Month','entdate between date_sub(now(),INTERVAL 1 MONTH) and now()',0,0)");
	
	ret1.add("CREATE TABLE mad_dashboard_sql ( \n" +
			"	  id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	  sql_name varchar(200) DEFAULT NULL, \n" +
			"	  query_statement text, \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	
	
	
	ret1.add("CREATE TABLE mad_dashboard_parameter ( \n" +
			"	  id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	  parameter_title varchar(200) DEFAULT NULL, \n" +
			"	  flex_field_id int(11) DEFAULT NULL, \n" +
			"	  field_parameter_name varchar(200) DEFAULT NULL, \n" +
			"	  sql_statement text, \n" +
			"	  bind_type varchar(20) DEFAULT 'STRING', \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	
	
	ret1.add("CREATE TABLE mad_dashboard_view ( \n" +
			"	  id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	  view_name varchar(200) DEFAULT NULL, \n" +
			"	  view_type varchar(20) DEFAULT 'RAW', \n" +
			"	  short_code varchar(100) DEFAULT NULL, \n" +
			"	  sql_id int (11) DEFAULT NULL, \n" +
			"	  sql_filter text, \n" +
			"	  env_id int (11) DEFAULT NULL, \n" +
			"	  order_by varchar(200) DEFAULT NULL, \n" +
			"	  permission_id int(11) DEFAULT NULL, \n" +
			"	  field_list text DEFAULT NULL, \n" +
			"	  title_list text DEFAULT NULL, \n" +
			"	  color_list text DEFAULT NULL, \n" +
			"	  group_by varchar(1000) DEFAULT NULL, \n" +
			"	  x_field varchar(200) DEFAULT NULL, \n" +
			"	  y_field varchar(200) DEFAULT NULL, \n" +
			"	  sum_field varchar(200) DEFAULT NULL, \n" +
			"	  sum_function varchar(10) default 'SUM', \n" +
			"	  decimal_size int(5) default 0, \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	
	
	ret1.add("CREATE TABLE mad_dashboard_view_parameter ( \n" +
			"	  id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	  view_id int(11) DEFAULT NULL, \n" +
			"	  parameter_id int(11) DEFAULT NULL, \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	
	
	
	ret1.add("CREATE TABLE mad_dashboard_user_configuration ( \n" +
			"	  id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	  user_id int(11) DEFAULT NULL, \n" +
			"	  divid varchar(200) DEFAULT NULL, \n" +
			"	  view_id int(11) DEFAULT NULL, \n" +
			"	  report_title varchar(1000) DEFAULT NULL, \n" +
			"	  parameters text DEFAULT NULL, \n" +
			"	  refresh_interval varchar(20) default 'MINUTE', \n"+
			"     refresh_by int(5) default 10,  \n"+
			"     send_notification varchar(3) default 'NO',  \n"+
			"     notification_groups varchar(1000) default NULL, "+
			"     height int(5) default 240, \n"+
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	
	
	ret1.add("CREATE TABLE mad_request_link ( \n" +
				"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
				"	request_id int(11), \n" +
				"	linked_request_id int(11), \n" +
				"	entuser int(11), \n" +
				"	entdate timestamp, \n" +
				"	PRIMARY KEY (id), \n" +
				"	UNIQUE KEY id_UNIQUE (id), \n" +
				"	KEY ndx_req_lnk_req_id (request_id), \n" +
				"	KEY ndx_req_lnk_linked_req_id (linked_request_id) \n" +
				"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	
	
	ret1.add("CREATE TABLE mad_request_link_history (  \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT,  \n" +
			"	request_link_id int(11),  \n" +
			"	request_id int(11),  \n" +
			"	linked_request_id int(11) default null,  \n" +
			"	history_action varchar(10),  \n" +
			"	history_user int(11),  \n" +
			"	history_date timestamp,  \n" +
			"	history_host varchar(100),  \n" +
			"	PRIMARY KEY (id),  \n" +
			"	UNIQUE KEY id_UNIQUE (id),  \n" +
			"	  KEY ndx_request_link_history_request_id (request_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");	

	ret1.add("CREATE TABLE mad_request_application ( \n" +
				"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
				"	request_id int(11), \n" +
				"	application_id int(11), \n" +
				"	entuser int(11), \n" +
				"	entdate timestamp, \n" +
				"	PRIMARY KEY (id), \n" +
				"	UNIQUE KEY id_UNIQUE (id), \n" +
				"	KEY ndx_mad_req_app_request_id (request_id), \n" +
				"	KEY ndx_mad_req_app_application_id (application_id) \n" +
				"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_application_member (  \n" +
				"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
				"	request_id int(11), \n" +
				"	application_id int(11), \n" +
				"	member_name varchar(200), \n" +
				"	member_path text, \n" +
				"	member_version varchar(100), \n" +
				"	member_tag_info varchar(100), \n" +
				"	member_order int(5), \n" +
				"	member_memo text, \n" +
				"	to_skip varchar(3) default 'NO', \n" +
				"	skip_reason varchar(20) default 'CANCELLED', \n" +
				"	status varchar(10), \n" +
				"	work_package_id int (11) default 0, " +
				"	entuser int(11), \n" +
				"	entdate timestamp, \n" +
				"	PRIMARY KEY (id), \n" +
				"	UNIQUE KEY id_UNIQUE (id), \n" +
				"	KEY ndx_mad_ram_request_id (request_id), \n" +
				"	KEY ndx_mad_ram_application_id (application_id), \n" +
				"	KEY ndx_mad_ram_member_version (member_version), \n" +
				"	KEY ndx_mad_ram_member_order (member_order), \n" +
				"	KEY ndx_mad_ram_member_tag_info (member_tag_info) \n" +
				"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_checkout_log ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT,\n" +
			"	request_id int(11),\n" +
			"	application_id int(11),\n" +
			"	member_id int(11),\n" +
			"	member_path varchar(200),\n" +
			"	member_version varchar(100),\n" +
			"	status varchar(10) default 'OPEN',\n" +
			"	repository_id int(11),\n" +
			"	check_out_user_info varchar(200),\n" +
			"	check_out_machine_info varchar(200),\n" +
			"	check_out_date timestamp default now(),\n" +
			"	check_in_user_info varchar(200),\n" +
			"	check_in_machine_info varchar(200),\n" +
			"	check_in_date timestamp,\n" +
			"	check_in_note text,\n" +
			"	check_out_code longtext,\n" +
			"	check_in_code longtext,\n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id), \n" +
			"	  KEY mad_checkout_ndx_request_id (request_id ASC), \n" +
			"	  KEY mad_checkout_ndx_application_id (application_id ASC), \n" +
			"	  KEY mad_checkout_ndx_member_id (member_id ASC), \n" +
			"	  KEY mad_checkout_ndx_member_path (member_path ASC), \n" +
			"	  KEY mad_checkout_ndx_repository_id (repository_id ASC) \n" +
			"  ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_application_member_history ( \n" + 
			"	id int(11) NOT NULL AUTO_INCREMENT,  \n" +
			"	request_application_member_id int(11),  \n" +
			"	request_id int(11),  \n" +
			"	application_id int(11) default null,  \n" +
			"	member_name varchar(200) DEFAULT NULL, \n" +
			"	member_path text, \n" +
			"	member_version varchar(100) DEFAULT NULL, \n" +
			"	member_order int(5) DEFAULT NULL, \n" +
			"	to_skip varchar(3) DEFAULT 'NO', \n" +
			"	skip_reason varchar(20) DEFAULT 'CANCELLED', \n" +
			"	member_tag_info varchar(100) DEFAULT NULL, \n" +
			"	history_action varchar(10),  \n" +
			"	history_user int(11),  \n" +
			"	history_date timestamp,  \n" +
			"	history_host varchar(100),  \n" +
			"	PRIMARY KEY (id),  \n" +
			"	UNIQUE KEY id_UNIQUE (id),  \n" +
			"	  KEY ndx_mad_request_application_member_hist_request_id (request_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_fields ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	request_id int(11), \n" +
			"	flex_field_id int(11), \n" +
			"	field_value text, \n" +
			"	field_value_ts timestamp NULL DEFAULT NULL, \n" +
			"	field_value_num double(32,8) NULL DEFAULT NULL, \n" +
			"	entuser int(11), \n" +
			"	entdate timestamp, \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id), \n" +
			"	KEY ndx_mad_req_fld_request_id (request_id), \n" +
			"	KEY ndx_mad_req_flex_field_id (flex_field_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");

	ret1.add("CREATE TABLE mad_request_fields_history (  \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT,  \n" +
			"	request_fields_id int(11),  \n" +
			"	request_id int(11),  \n" +
			"	flex_field_id int(11) default null,  \n" +
			"	field_value text, \n" +
			"	field_value_ts timestamp, \n" +
			"	field_value_num double(32,8), \n" +
			"	history_action varchar(10),  \n" +
			"	history_user int(11),  \n" +
			"	history_date timestamp,  \n" +
			"	history_host varchar(100),  \n" +
			"	PRIMARY KEY (id),  \n" +
			"	UNIQUE KEY id_UNIQUE (id),  \n" +
			"	  KEY ndx_mad_request_env_fields_hist_request_id (request_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_request_attachment ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	request_id int(11), \n" +
			"	flex_field_id int(11), \n" +
			"	file_name varchar(200), \n" +
			"	file_size int(11), \n" +
			"	file_blob longblob, \n" +
			"	entuser int(11), \n" +
			"	entdate timestamp, \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id), \n" +
			"	KEY ndx_mad_req_attachment_request_id (request_id), \n" +
			"	KEY ndx_mad_req_attachment_flex_field_id (flex_field_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_env_fields ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	request_id int(11), \n" +
			"	environment_id int(11), \n" +
			"	platform_id int(11), \n" +
			"	application_id int(11), \n" +
			"	flex_field_id int(11), \n" +
			"	field_value text, \n" +
			"	entuser int(11), \n" +
			"	entdate timestamp, \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id), \n" +
			"	KEY ndx_mad_req_env_fld_request_id (request_id), \n" +
			"	KEY ndx_mad_req_env_flex_env_id (environment_id), \n" +
			"	KEY ndx_mad_req_env_flex_plat_id (platform_id), \n" +
			"	KEY ndx_mad_req_env_flex_app_id (application_id), \n" +
			"	KEY ndx_mad_req_env_flex_field_id (flex_field_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_env_fields_history (  \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT,  \n" +
			"	request_env_fields_id int(11),  \n" +
			"	request_id int(11),  \n" +
			"	environment_id int(11) default null,  \n" +
			"	platform_id int(11) default null,  \n" +
			"	application_id int(11) default null,  \n" +
			"	flex_field_id int(11) default null,  \n" +
			"	field_value text, \n" +
			"	history_action varchar(10),  \n" +
			"	history_user int(11),  \n" +
			"	history_date timestamp,  \n" +
			"	history_host varchar(100),  \n" +
			"	PRIMARY KEY (id),  \n" +
			"	UNIQUE KEY id_UNIQUE (id),  \n" +
			"	  KEY ndx_mad_request_env_fields_hist_request_id (request_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_platform_skip ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	request_id int(11), \n" +
			"	platform_id int(11), \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id), \n" +
			"	KEY ndx_mad_request_platform_skip_request_id (request_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");

	ret1.add("CREATE TABLE mad_request_platform_skip_history (  \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT,  \n" +
			"	request_platform_skip_id int(11),  \n" +
			"	request_id int(11),  \n" +
			"	platform_id int(11),  \n" +
			"	history_action varchar(10),  \n" +
			"	history_user int(11),  \n" +
			"	history_date timestamp,  \n" +
			"	history_host varchar(100),  \n" +
			"	PRIMARY KEY (id),  \n" +
			"	UNIQUE KEY id_UNIQUE (id),  \n" +
			"	  KEY ndx_request_platform_skip_history_request_id (request_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");

	
	ret1.add("CREATE TABLE mad_request_type ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	request_type varchar(100), \n" +
			"	request_group varchar(20),  \n" +
			"	permission int(11), \n" +
			"	flow_id int(11), \n" +
			"	is_visible varchar(3) default 'YES', \n" +
			"	deployment_slot_id int(11) default null, \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_flex_field ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	title varchar(100), \n" +
			"	string_name varchar(200) default null, \n" +
			"	entry_type varchar(20), \n" +
			"	entry_validation_regex varchar(200), \n" +
			"	is_validated varchar(3) default 'NO', \n" +
			"	validation_sql text, \n" +
			"	validation_env_id int(11), \n" +
			"	field_size int(5), \n" +
			"	tab_request_type_id int(11), \n" +
			"	tab_delete_allowed varchar(3) default 'YES', \n" +
			"	num_fixed_length int(2), \n" +
			"	num_decimal_length int(2), \n" +
			"	num_grouping_char varchar(1), \n" +
			"	num_decimal_char varchar(1), \n" +
			"	num_currency_symbol varchar(10), \n" +
			"	num_min_val double(32,8), \n" +
			"	num_max_val double(32,8), \n" +
			"	calc_data_type varchar(10), \n" +
			"	calc_display_type varchar(10), \n" +
			"	calc_display_format varchar(200), \n" +
			"	calc_statement text, \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_request_type_field ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	request_type_id int(11), \n" +
			"	flex_field_id int(11), \n" +
			"	field_parameter_name varchar(200), \n" +
			"	default_value text, \n" +
			"	is_mandatory varchar(3) default 'NO', \n" +
			"	is_editable varchar(3) default 'YES', \n" +
			"	is_visible varchar(3) default 'YES', \n" +
			"	field_order int(4) default 0, \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");

	ret1.add("CREATE TABLE mad_request_type_environment ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	request_type_id int(11), \n" +
			"	environment_id int(11), \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_type_application ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	request_type_id int(11), \n" +
			"	application_id int(11), \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_type_state_field_override ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	request_type_id int(11), \n" +
			"	flow_state_id int(11), \n" +
			"	flex_field_id int(11), \n" +
			"	permission_id int(11), \n" +
			"	overriding_key varchar(10), \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_driver ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	driver_name varchar(100), \n" +
			"	class_name varchar(200), \n" +
			"	driver_type varchar(10), \n" +
			"	success_keyword varchar(1000), \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("truncate table mad_driver");
	
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (1, 'SOA Builder','com.mayatech.buildDrivers.SOABuilder','BUILD','BUILD SUCCESSFUL')");
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (2, 'SOA Deployer','com.mayatech.deployDrivers.SOADeployer','DEPLOY','INFO: Received HTTP response from the server, response code=200')");
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (3, 'ANT Builder','com.mayatech.buildDrivers.ANTBuildDriver','BUILD','BUILD SUCCESSFUL')");
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (4, 'ANT Deployer','com.mayatech.deployDrivers.ANTDeployer','DEPLOY','BUILD SUCCESSFUL')");
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (5, 'DB Builder','com.mayatech.buildDrivers.DBBuilder','BUILD','')");
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (6, 'DB Deployer','com.mayatech.deployDrivers.DBDeployer','DEPLOY','')");
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (7, 'Weblogic Deployer','com.mayatech.deployDrivers.WLDeployer','DEPLOY','Initiating start operation for application')");
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (8, 'Package Downloader','com.mayatech.buildDrivers.PACKDownloader','BUILD','')");
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (9, 'Dummy Builder','com.mayatech.buildDrivers.DUMMYBuildDriver','BUILD','')");
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (10, 'Dummy Deployer','com.mayatech.deployDrivers.DUMMYDeployer','DEPLOY','')");
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (11, 'Shell Builder', 'com.mayatech.buildDrivers.ShellDriver','BUILD','')");
	ret1.add("insert into mad_driver(id, driver_name, class_name, driver_type, success_keyword) values (12, 'Shell Deployer','com.mayatech.buildDrivers.ShellDriver','DEPLOY','')");
	
	ret1.add("CREATE TABLE mad_application ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	application_name varchar(100), \n" +
			"	repository_id  int(11), \n" +
			"	export_type varchar(10) default 'FILE', \n" +
			"	item_repo_selection_type varchar(10) default 'FILE', \n" +
			"	prevent_older_version varchar(3) default 'NO', \n" +
			"	build_driver_id int(11), \n" +
			"	deploy_driver_id int(11), \n" +
			"	pre_deploy_method_id int(11), \n" +
			"	post_deploy_method_id int(11), \n" +
			"	platform_type_id int(11), \n" +
			"	app_repo_root text, \n" +
			"   app_repo_policy varchar(20) default 'APP_REPO_ROOT', \n" + 
			"	app_repo_tag_path text, \n" +
			"	app_repo_filter text, \n" +
			"	app_repo_tag_filter text, \n" +
			"	permission int(11), \n" +
			"	conflict_level int(1) default 1, \n" +
			"	app_repo_script text, \n" +
			"	version_calculation_script text, \n" +
			"	item_view_script text, \n" +
			"	is_valid varchar(3) default 'YES', \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_application_flex_fields ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	application_id int(11), \n" +
			"	flex_field_id int(11), \n" +
			"	field_parameter_name varchar(200), \n" +
			"	default_value text, \n" +
			"	is_mandatory varchar(3) default 'NO', \n" +
			"	is_editable varchar(3)  default 'YES', \n" +
			"	is_visible varchar(3)  default 'YES', \n" +
			"	field_order int(4) default 0, \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_application_dependency ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	application_id int(11), \n" +
			"	depended_application_id int(11), \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_class (\n" +
			"  id INT NOT NULL AUTO_INCREMENT,\n" +
			"  class_name VARCHAR(200) NULL,\n" +
			"  class_desc VARCHAR(200) NULL,\n" +
			"  class_type VARCHAR(10) default 'REPO',\n" +
			"  PRIMARY KEY (id)\n" +
			" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("truncate table mad_class");
	
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.repoDrivers.SVNRepoExplorer','com.mayatech.repoDrivers.SVNRepoExplorer','REPO')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.repoDrivers.GITRepoExplorer','com.mayatech.repoDrivers.GITRepoExplorer','REPO')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.repoDrivers.FileLocalRepoExplorer','com.mayatech.repoDrivers.FileLocalRepoExplorer','REPO')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('oracle.jdbc.driver.OracleDriver','oracle.jdbc.driver.OracleDriver','REPO')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.buildDrivers.SOABuilder','com.mayatech.buildDrivers.SOABuilder','BUILD')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.buildDrivers.DBBuilder','com.mayatech.buildDrivers.DBBuilder','BUILD')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.buildDrivers.ANTBuildDriver','com.mayatech.buildDrivers.ANTBuildDriver','BUILD')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.deployDrivers.SOADeployer','com.mayatech.deployDrivers.SOADeployer','DEPLOY')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.deployDrivers.DBDeployer','com.mayatech.deployDrivers.DBDeployer','DEPLOY')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.deployDrivers.ANTDeployer','com.mayatech.deployDrivers.ANTDeployer','DEPLOY')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.deployDrivers.WLDeployer','com.mayatech.deployDrivers.WLDeployer','DEPLOY')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.buildDrivers.PACKDownloader','com.mayatech.buildDrivers.PACKDownloader','BUILD')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.buildDrivers.DUMMYBuildDriver','com.mayatech.buildDrivers.DUMMYBuildDriver','BUILD')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.deployDrivers.DUMMYDeployer','com.mayatech.deployDrivers.DUMMYDeployer','DEPLOY')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.buildDrivers.ShellDriver','com.mayatech.buildDrivers.ShellDriver','BUILD')");
	ret1.add("insert into mad_class(class_name,class_desc,class_type) values ('com.mayatech.buildDrivers.ShellDriver','com.mayatech.buildDrivers.ShellDriver','DEPLOY')");
	
	ret1.add("CREATE TABLE mad_repository ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	repository_name varchar(100), \n" +
			"	class_name varchar(200), \n" +
			"	par_hostname varchar(100), \n" +
			"	par_port varchar(10), \n" +
			"	par_username varchar(100), \n" +
			"	par_password varchar(100), \n" +
			"	par_flex_1 text, \n" +
			"	par_flex_2 text, \n" +
			"	par_flex_3 text, \n" +
			"	par_flex_4 text, \n" +
			"	par_flex_5 text, \n" +
			"	par_flex_6 text, \n" +
			"	par_flex_7 text, \n" +
			"	is_valid varchar(3) default 'YES', \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_environment ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	environment_name varchar(100), \n" +
			"	permission int(11), \n" +
			"	on_error_action varchar(20) default 'CONTINUE', \n" +
			"	deployment_slot_id int(11) null default null, \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	

	ret1.add("CREATE TABLE mad_platform_type ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	platform_type_name varchar(100), \n" +
			"	deployment_type varchar(10) default 'SERIAL', \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_platform_type_flex_fields (  \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	platform_type_id int(11), \n" +
			"	field_parameter_name varchar(200), \n" +
			"	flex_field_id int(11), \n" +
			"	default_value text, \n" +
			"	is_mandatory varchar(3) default 'NO', \n" +
			"	is_editable varchar(3)  default 'YES', \n" +
			"	is_visible varchar(3)  default 'YES', \n" +
			"	field_order int(4) default 0, \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_modifier_group ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	modifier_group_name varchar(200), \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_modifier_rule ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	modifier_group_id int(11), \n" +
			"	modifier_name varchar(200), \n" +
			"	modifier_order int(5), \n" +
			"	is_valid varchar(3) default 'YES', \n" +
			"	rule_locator_type varchar(20), \n" +
			"	rule_locator_statement varchar(400), \n" +
			"	rule_locator_options varchar(400), \n" +
			"	rule_changer_action varchar(20), \n" +
			"	rule_changer_statement TEXT, \n" +
			"	rule_changer_options varchar(400), \n" +
			"	when_value_to_check varchar(1000), \n" +
			"	when_operand varchar(10), \n" +
			"	when_values varchar(1000), \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_platform_type_modifier_group ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	platform_type_id int(11), \n" +
			"	file_name varchar(200), \n" +
			"	modifier_group_id int(11), \n" +
			"	application_id int(11), \n" +
			"	include_sub_folders varchar(3) default 'NO', \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_platform ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	platform_type_id int(11), \n" +
			"	platform_name varchar(100), \n" +
			"	edit_permission_id int(11), \n" +
			"	on_error_action varchar(20) default 'CONTINUE', \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_platform_fields ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	platform_id int(11), \n" +
			"	flex_field_id int(11), \n" +
			"	field_value text, \n" +
			"	entuser int(11), \n" +
			"	entdate timestamp, \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id), \n" +
			"	KEY ndx_mad_plat_fld_platform_id (platform_id), \n" +
			"	KEY ndx_mad_plat_flex_field_id (flex_field_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_platform_env ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	platform_id int(11), \n" +
			"	environment_id int(11), \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_app_env ( \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT, \n" +
			"	request_id int(11), \n" +
			"	application_id int(11), \n" +
			"	environment_id int(11), \n" +
			"	entuser int(11), \n" +
			"	entdate timestamp, \n" +
			"	PRIMARY KEY (id), \n" +
			"	UNIQUE KEY id_UNIQUE (id), \n" +
			"	KEY ndx_mad_req_app_env_request_id (request_id), \n" +
			"	KEY ndx_mad_req_app_env_application_id (application_id), \n" +
			"	KEY ndx_mad_req_app_env_environment_id (environment_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_app_env_history (  \n" +
			"	id int(11) NOT NULL AUTO_INCREMENT,  \n" +
			"	request_app_env_id int(11),  \n" +
			"	request_id int(11),  \n" +
			"	application_id int(11) default null,  \n" +
			"	environment_id int(11) default null,  \n" +
			"	history_action varchar(10),  \n" +
			"	history_user int(11),  \n" +
			"	history_date timestamp,  \n" +
			"	history_host varchar(100),  \n" +
			"	PRIMARY KEY (id),  \n" +
			"	UNIQUE KEY id_UNIQUE (id),  \n" +
			"	  KEY ndx_mad_req_hist_request_id (request_id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");

	ret1.add("CREATE TABLE mad_permission ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  permission_name VARCHAR(200)  NULL, \n" +
			"	  permission_level VARCHAR(10)  default 'USER', \n" +
			"	  permission_description TEXT  NULL, \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("truncate table mad_permission");

	ret1.add("insert into mad_permission(permission_name,permission_level,permission_description) values ('REQUEST_PARTIAL_DEPLOYMENT','SYSTEM','Ability to exclude items of deployment package')");
	ret1.add("insert into mad_permission(permission_name,permission_level,permission_description) values ('PACKAGE_MULTI_DEPLOMENT','SYSTEM','Multiple deployment permission for the same deployment request')");
	ret1.add("insert into mad_permission(permission_name,permission_level,permission_description) values ('SKIP_PLATFORM_DEPLOYMENT','SYSTEM','Skip a platform in deployment request')");
	ret1.add("insert into mad_permission(permission_name,permission_level,permission_description) values ('CREATE_REQUEST','SYSTEM','Create Request')");
	ret1.add("insert into mad_permission(permission_name,permission_level,permission_description) values ('CREATE_PACKAGE','SYSTEM','Create Package Permission')");
	ret1.add("insert into mad_permission(permission_name,permission_level,permission_description) values ('CREATE_DEPLOYMENT_REQUEST','SYSTEM','Create deployment request permission')");
	ret1.add("insert into mad_permission(permission_name,permission_level,permission_description) values ('DEPLOYMENT_TIME_CHANGE','SYSTEM','Change deployment time permissions')");

	ret1.add("CREATE TABLE mad_group ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  group_type VARCHAR(20) default 'USER', \n" +
			"	  group_name VARCHAR(200)  NULL, \n" +
			"	  common_email_address varchar(200), \n" +
			"	  manager_user_id int(11), \n" +
			"	  group_description TEXT  NULL, \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_group_members ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  group_id int(11), \n" +
			"	  member_id int(11), \n" +
			"	  member_type VARCHAR(10) default 'USER', \n" +
			"	  group_membership_description TEXT , \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_group_permission ( \n" +
				"  id INT NOT NULL AUTO_INCREMENT, \n" +
				"  group_id int(11), \n" +
				"  permission_id int(11), \n" +
				"  PRIMARY KEY (id) \n" +
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_flow ( \n" +
				"  id INT NOT NULL AUTO_INCREMENT, \n" +
				"  flow_name VARCHAR(200)  NULL, \n" +
				"  flow_description TEXT  NULL, \n" +
				"  email_template_id int(11), \n" +
				"  PRIMARY KEY (id) \n" +
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
		
	ret1.add("CREATE TABLE mad_flow_state  ( \n" +
			 " id INT NOT NULL AUTO_INCREMENT, \n" +
			 " flow_id int(11), \n" +
			 " state_type VARCHAR(10) default 'SYSTEM', \n" +
			 " state_stage varchar(20), \n" +
			 " state_name varchar(100), \n" +
			 " state_title varchar(100), \n" +
			 " state_description TEXT , \n" +
			 " loc_x int(10), \n" +
			 " loc_y int(10), \n" +
			 " PRIMARY KEY (id) \n" +
			 " ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_flow_state_edit_permissions  ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  flow_state_id int(11), \n" +
			"	  permission_id int(11), \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_email_template  ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  template_name varchar(100), \n" +
			"	  from_type varchar(10) default 'FIXED', \n" +
			"	  from_email varchar(200), \n" +
			"	  from_name varchar(200), \n" +
			"	  email_subject VARCHAR(255), \n" +
			"	  email_body TEXT, \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_flow_state_action  ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  flow_state_id int(11), \n" +
			"	  action_type VARCHAR(10) default 'HUMAN', \n" +
			"	  action_name varchar(100), \n" +
			"	  action_description TEXT , \n" +
			"	  next_state_id int(11) , \n" +
			"	  email_template_id int(11), \n" +
			"	  repository_action VARCHAR(10) default 'NONE', \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_flow_state_action_permissions  ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  flow_state_action_id int(11), \n" +
			"	  permission_id int(11), \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_flow_state_action_groups  ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  flow_state_action_id int(11), \n" +
			"	  group_id int(11), \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_flow_logs (  \n" +
			"  id INT NOT NULL AUTO_INCREMENT, \n" +
			"  request_id int(11), \n" +
			"  flow_id int(11), \n" +
			"  flow_state_id int(11), \n" +
			"  curr_state_user int(11), \n" +
			"  curr_state_date timestamp  null default null, \n" +
			"  status varchar(10) default 'OPEN', \n" +
			"  flow_state_action_id int(11), \n" +
			"  action_note text, \n" +
			"  next_state_id int(11), \n" +
			"  next_state_user int(11), \n" +
			"  next_state_date timestamp, \n" +
			"  time_spent int(5) default 0, \n" +
			"  notification_sent varchar(3) default 'NO', \n" +
			"  notification_attempt_date timestamp null default null, \n" +
			"  PRIMARY KEY (id), \n" +
			"  KEY ndx_mad_mad_request_flow_logs_request_id (request_id), \n" +
			"  KEY ndx_mad_mad_request_flow_logs_flow_id (flow_id), \n" +
			"  KEY ndx_mad_mad_request_flow_logs_status (status), \n" +
			"  KEY ndx_mad_mad_request_flow_logs_flow_state_id (flow_state_id), \n" +
			"  KEY ndx_mad_mad_request_flow_logs_next_state_id (next_state_id), \n" +
			"  KEY ndx_mad_mad_request_flow_logs_flow_action_id (flow_state_action_id), \n" +
			"  KEY ndx_mad_mad_request_flow_logs_notification_sent (notification_sent) \n" +
			" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_lock (  \n" +
			  "	request_id int(11),  \n" +
			  " lock_user_id int(11), \n" +
			  "	lock_date  timestamp, \n" +
			  "	KEY ndx_mad_request_lock_request_id (request_id)  \n" +
			  "	) ENGINE=MEMORY DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_request_notification_log (  \n" +
			 " id INT NOT NULL AUTO_INCREMENT, \n" +
			 " request_flow_log_id int(11), \n" +
			 " request_id int(11), \n" +
			 " send_status varchar(3) default 'YES', \n" +
			 " send_date  timestamp, \n" +
			 " from_email_addr varchar(200), \n" +
			 " from_name varchar(200), \n" +
			 " to_email_addr text, \n" +
			 " to_name text, \n" +
			 " email_subject varchar(1000), \n" +
			 " email_body text, \n" +
			 " trans_logs text, \n" +
			 " entuser int(11), \n" +
			 " entdate timestamp, \n" +
			 " PRIMARY KEY (id), \n" +
			 " KEY ndx_mad_mad_request_notification_log_request_id (request_id), \n" +
			 " KEY ndx_mad_mad_request_notification_log_log_id (request_flow_log_id), \n" +
			 " KEY ndx_mad_mad_request_notification_log_status (send_status) \n" +
			 " ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_lang (\n" +
			"  id INT NOT NULL AUTO_INCREMENT,\n" +
			"  lang VARCHAR(20) NULL, \n" +
			"  lang_desc VARCHAR(200) NULL,\n" +
			"  PRIMARY KEY (id) \n" +
			" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("truncate table mad_lang");
	
	ret1.add("insert into mad_lang(lang, lang_desc) values ('TR','Türkçe')");
	ret1.add("insert into mad_lang(lang, lang_desc) values ('EN','English')");


	
	ret1.add("CREATE TABLE mad_string (\n" +
			"  id INT NOT NULL AUTO_INCREMENT,\n" +
			"  lang VARCHAR(20) NULL, \n" +
			"  string_name VARCHAR(200) NULL,\n" +
			"  short_desc VARCHAR(2000) NULL,\n" +
			"  long_desc text,\n" +
			"  PRIMARY KEY (id), \n" +
			"  KEY ndx_mad_string_string_name (string_name) \n" +
			" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE mad_method ( \n" +
				"	  id int(11) NOT NULL AUTO_INCREMENT, \n" +
				"	  method_name varchar(200) DEFAULT NULL, \n" +
				"	  method_description text, \n" +
				"	  method_type varchar(20) DEFAULT 'JAVASCRIPT', \n" +
				"	  is_valid varchar(3) default 'YES', \n" +
				"	  reflection_classname varchar(1000) DEFAULT NULL, \n" +
				"	  reflection_methodname varchar(1000) DEFAULT NULL, \n" +
				"	  source_code text, \n" +
				"	  database_id int(11) default null, \n" +
				"	  success_keyword varchar(2000) default null, \n" +
				"	  parameter_count int(3) default 1, \n" +
				"	  param_name_1 varchar(200) default null, \n" +
				"	  param_name_2 varchar(200) default null, \n" +
				"	  param_name_3 varchar(200) default null, \n" +
				"	  param_name_4 varchar(200) default null, \n" +
				"	  param_name_5 varchar(200) default null, \n" +
				"	  param_name_6 varchar(200) default null, \n" +
				"	  param_name_7 varchar(200) default null, \n" +
				"	  param_name_8 varchar(200) default null, \n" +
				"	  param_name_9 varchar(200) default null, \n" +
				"	  param_name_10 varchar(200) default null, \n" +
				"	  param_default_val_1 varchar(1000) default null, \n" +
				"	  param_default_val_2 varchar(1000) default null, \n" +
				"	  param_default_val_3 varchar(1000) default null, \n" +
				"	  param_default_val_4 varchar(1000) default null, \n" +
				"	  param_default_val_5 varchar(1000) default null, \n" +
				"	  param_default_val_6 varchar(1000) default null, \n" +
				"	  param_default_val_7 varchar(1000) default null, \n" +
				"	  param_default_val_8 varchar(1000) default null, \n" +
				"	  param_default_val_9 varchar(1000) default null, \n" +
				"	  param_default_val_10 varchar(1000) default null, \n" +
				"	  param_type_1 varchar(20) default null,	 \n" +
				"	  param_type_2 varchar(20) default null,	 \n" +
				"	  param_type_3 varchar(20) default null,	 \n" +
				"	  param_type_4 varchar(20) default null,	 \n" +
				"	  param_type_5 varchar(20) default null,	 \n" +
				"	  param_type_6 varchar(20) default null,	 \n" +
				"	  param_type_7 varchar(20) default null,	 \n" + 
				"	  param_type_8 varchar(20) default null,	 \n" +
				"	  param_type_9 varchar(20) default null,	 \n" + 
				"	  param_type_10 varchar(20) default null,	 \n" +
				"	  PRIMARY KEY (id) \n" +
				"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_flow_state_action_methods ( \n" + 
			"	  id int(11) NOT NULL AUTO_INCREMENT, \n" + 
			"	  request_flow_logs_id int(11) DEFAULT NULL, \n" + 
			"	  flow_state_action_id int(11) DEFAULT NULL, \n" + 
			"	  execution_order int(3) DEFAULT 1, \n" + 
			"	  execution_type varchar(10) default 'SYNCH',   \n" + 
			"	  is_valid varchar(3) default 'YES',   \n" + 
			"	  method_id int(11) DEFAULT NULL, \n" + 
			"	  value_1 varchar(1000) default null, \n" +
			"	  value_2 varchar(1000) default null, \n" +
			"	  value_3 varchar(1000) default null, \n" +
			"	  value_4 varchar(1000) default null, \n" +
			"	  value_5 varchar(1000) default null, \n" +
			"	  value_6 varchar(1000) default null, \n" +
			"	  value_7 varchar(1000) default null, \n" +
			"	  value_8 varchar(1000) default null, \n" +
			"	  value_9 varchar(1000) default null, \n" +
			"	  value_10 varchar(1000) default null, \n" +
			"	  PRIMARY KEY (id) \n" + 
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_method_call_logs ( \n" +
				"  id int(11) NOT NULL AUTO_INCREMENT, \n" +
				"  token varchar(100) DEFAULT NULL, \n" +
				"  request_id int(11) DEFAULT NULL, \n" +
				"  flow_state_action_id int(11) DEFAULT NULL, \n" +
				"  method_id int(11) DEFAULT NULL, \n" +
				"  action_method_id int(11) DEFAULT NULL, \n" +
				"  status varchar(10) DEFAULT 'STOP', \n" +
				"  last_execution_date timestamp, \n" +
				"  attempt_no int(5) DEFAULT '1', \n" +
				"  executable text, \n" +
				"  parameters text, \n" +
				"  duration int(11) DEFAULT NULL, \n" +
				"  execution_result text, \n" +
				"  execution_log text, \n" +
				"  entdate timestamp, \n" +
				"  PRIMARY KEY (id), \n" +
				"  KEY mad_method_call_log_request_id (request_id), \n" +
				"  KEY mad_method_call_log_token (token), \n" +
				"  KEY mad_method_call_log_flow_state_action_id (flow_state_action_id), \n" +
				"  KEY mad_method_call_log_flow_state_status (status) \n" +
				") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("CREATE TABLE mad_generic_history ( \n" +
				" id int(11) NOT NULL AUTO_INCREMENT,  \n" +
				" table_name varchar(50),  \n" +
				" table_id int(11),  \n" +
				" change_id int(11), \n" +
				" field_name int(11), \n" +
				" field_value varchar(1000), \n" +
				" history_action varchar(10),  \n" +
				" history_user int(11),  \n" +
				" history_date timestamp,  \n" +
				" history_host varchar(100),  \n" +
				" PRIMARY KEY (id),  \n" +
				" UNIQUE KEY id_UNIQUE (id),  \n" +
				"  KEY ndx_mad_generic_history_table_name (table_name), \n" +
				"  KEY ndx_mad_generic_history_table_id (table_id) \n" +
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	return ret1;
}




%>