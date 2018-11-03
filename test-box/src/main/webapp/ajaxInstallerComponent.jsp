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
	
	
	ret1.add("ALTER TABLE tdm_user ADD COLUMN domain_id INT(11) NULL");
	ret1.add("ALTER TABLE tdm_user ADD COLUMN module varchar(20) default NULL");
	
	
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
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (112,'TEST_CHANGE','Change Management')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (113,'TEST_REQUIREMENT','Requiremetn Management')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (114,'TEST_DESIGN','Test Design')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (115,'TEST_EXECUTION','Test Execution')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (116,'TEST_ANALYSE','Test Analysis')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (117,'TEST_ADMIN','Test Admin')");
	ret1.add("INSERT INTO tdm_role (id,shortcode,description) VALUES (118,'TEST_BUG','Bug')");

	
	
	ret1.add("CREATE TABLE tdm_user_role ( \n"+
			"  user_id int(11) NOT NULL, \n"+
			"  role_id int(11) NOT NULL \n"+
			") ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	
	ret1.add("truncate table tdm_user_role");

	ret1.add("insert into tdm_user_role values (1,1)");
	ret1.add("insert into tdm_user_role values (1,112)");
	ret1.add("insert into tdm_user_role values (1,113)");
	ret1.add("insert into tdm_user_role values (1,114)");
	ret1.add("insert into tdm_user_role values (1,115)");
	ret1.add("insert into tdm_user_role values (1,116)");
	ret1.add("insert into tdm_user_role values (1,117)");
	ret1.add("insert into tdm_user_role values (1,118)");
	
	
	
	ret1.add("CREATE TABLE tdm_parameters ( \n"+
			"  param_name varchar(200) DEFAULT NULL, \n"+
			"  param_value varchar(1000) DEFAULT NULL \n"+
			") ENGINE=InnoDB DEFAULT CHARSET=utf8");
	
	
	
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
	
	

	ret1.add("CREATE TABLE mad_permission ( \n" +
			"	  id INT NOT NULL AUTO_INCREMENT, \n" +
			"	  permission_name VARCHAR(200)  NULL, \n" +
			"	  permission_level VARCHAR(10)  default 'USER', \n" +
			"	  permission_description TEXT  NULL, \n" +
			"	  PRIMARY KEY (id) \n" +
			"	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
	
	
	ret1.add("truncate table mad_permission");

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
	
	ret1.add("CREATE TABLE tdm_test_domain ( \n" +
			 "  ID int(11) NOT NULL AUTO_INCREMENT, \n" +
			 "  domain_name varchar(100) DEFAULT NULL, \n" +
			 "  is_active varchar(3) default 'YES', \n" +
			 "  PRIMARY KEY (ID) \n" +
			" ) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_test_domain_user ( \n" +
			 " ID int(11) NOT NULL AUTO_INCREMENT, \n" +
			 " domain_id int(11), \n" +
			 " user_id  int(11), \n" +
			 " PRIMARY KEY (ID) \n" +
			 " ) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8");	
	
	ret1.add("CREATE TABLE tdm_test_tree ( \n" +
			 " ID bigint(11) NOT NULL, \n" +
			 " parent_tree_id bigint(11) DEFAULT '0', \n" +
			 " referenced_test_id bigint(11) DEFAULT '0', \n" +
			 " order_by int (5) default 1 , \n" +
			 " module varchar(20) DEFAULT NULL, \n" +
			 " domain_id int(11) DEFAULT NULL, \n" +
			 " tree_type varchar(10) DEFAULT 'container', \n" +
			 " tree_title varchar(1000) DEFAULT NULL, \n" +
			 " created_by int(11) DEFAULT '0', \n" +
			 " creation_date datetime DEFAULT CURRENT_TIMESTAMP, \n" +
			 " checked_out_by int(11) DEFAULT '0', \n" +
			 " version int(11) DEFAULT '0', \n" +
			 " checkin_date datetime DEFAULT NULL, \n" +
			 " checkout_date datetime DEFAULT NULL, \n" +
			 " checkin_note varchar(1000) DEFAULT NULL, \n" +
			 " PRIMARY KEY (ID), \n" +
			 " KEY ndx_test_tree_domain (domain_id), \n" +
			 " KEY ndx_test_tree_module (module), \n" +
			 " KEY ndx_test_tree_type (tree_type), \n" +
			 " KEY ndx_test_tree_created_by (created_by), \n" +
			 " KEY ndx_test_tree_checked_out_by (checked_out_by) \n" +
			" ) ENGINE=InnoDB DEFAULT CHARSET=utf8");	
	
	
	
	
	ret1.add("CREATE TABLE tdm_test_tree_check_history ( \n" +
			  " ID bigint(11) NOT NULL, \n" +
			  " tree_id bigint(11) DEFAULT '0', \n" +
			  " action_type varchar(10) DEFAULT 'CHECKIN', \n" +
			  " action_by int(11) DEFAULT '0', \n" +
			  " action_date datetime DEFAULT NULL, \n" +
			  " action_note varchar(1000) DEFAULT NULL, \n" +
			  " version int(11) DEFAULT '0', \n" +
			  " PRIMARY KEY (ID), \n" +
			  " KEY ndx_test_tree_check_tree_id (tree_id), \n" +
			  " KEY ndx_test_tree_check_action_by (action_by) \n" +
			" ) ENGINE=InnoDB DEFAULT CHARSET=utf8");	
	
	ret1.add("CREATE TABLE tdm_test_tree_values ( \n" +
			  " ID bigint(11) NOT NULL, \n" +
			  " tree_id bigint(11) DEFAULT '0', \n" +
			  " flex_field_id int(11) DEFAULT NULL, \n" +
			  " val_string varchar(1000) DEFAULT NULL, \n" +
			  " val_memo text, \n" +
			  " val_datetime datetime DEFAULT NULL, \n" +
			  " val_numeric decimal(15,6) DEFAULT NULL, \n" +
			  " created_by int(11) DEFAULT '0', \n" +
			  " creation_date datetime DEFAULT CURRENT_TIMESTAMP, \n" +
			  " PRIMARY KEY (ID), \n" +
			  " KEY ndx_test_tree_flex_tree_id (tree_id), \n" +
			  " KEY ndx_test_tree_flex_field_id (flex_field_id) \n" +
			" ) ENGINE=InnoDB DEFAULT CHARSET=utf8");	
	
	
	
	
	ret1.add("CREATE TABLE tdm_test_tree_parameters ( \n"+
			 " ID bigint(11) NOT NULL, \n"+
			 " tree_id bigint(11) DEFAULT '0', \n"+
			 " parameter_direction varchar(3) DEFAULT 'IN', \n"+
			 " parameter_scope varchar(6) DEFAULT 'GLOBAL', \n"+
			 " flex_field_id int(11) DEFAULT NULL, \n"+
			 " parameter_title varchar(200) DEFAULT NULL, \n"+
			 " parameter_name varchar(100) DEFAULT NULL, \n"+
			 " default_value varchar(1000) DEFAULT NULL, \n"+
			 " PRIMARY KEY (ID), \n"+
			 " KEY ndx_test_param_tree_id (tree_id), \n"+
			 " KEY ndx_test_param_flex_field_id (flex_field_id) \n"+
			 " ) ENGINE=InnoDB DEFAULT CHARSET=utf8");	
	
	ret1.add("CREATE TABLE tdm_test_call_parameter_values ( \n"+
			 " ID bigint(11) NOT NULL, \n"+
			 " tree_id bigint(11) DEFAULT '0', \n"+
			 " referenced_test_id bigint(11) DEFAULT '0', \n"+
			 " parameter_id bigint(11) DEFAULT '0', \n"+
			 " parameter_value varchar(1000) DEFAULT NULL, \n"+
			 " PRIMARY KEY (ID), \n"+
			 " KEY ndx_test_call_parameter_tree_id (tree_id), \n"+
			 " KEY ndx_test_call_parameter_referenced_test_id (referenced_test_id), \n"+
			 " KEY ndx_test_call_parameter_parameter_id (parameter_id) \n"+
			" ) ENGINE=InnoDB DEFAULT CHARSET=utf8");	 
		
	ret1.add("CREATE TABLE tdm_test_tree_fields ( \n"+
			 " ID bigint(11) NOT NULL, \n"+
			 " order_by int(5) DEFAULT '1', \n"+
			 " module varchar(20), \n"+
			 " domain_id int(11), \n"+
			 " tree_type varchar(10) DEFAULT 'element', \n"+
			 " flex_field_id int(11), \n"+
			 " PRIMARY KEY (ID) \n"+
			" ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_test_tree_link ( \n"+
			 " ID bigint(11) NOT NULL, \n"+
			 " tree_id bigint(11) DEFAULT '0', \n"+
			 " module varchar(20), \n"+
			 " linked_tree_id bigint(11) DEFAULT '0', \n"+
			 " PRIMARY KEY (ID), \n"+
			 " KEY ndx_test_tree_link_tree_id (tree_id), \n"+
			 " KEY ndx_test_tree_link_linked_tree_id (linked_tree_id) \n"+
			" ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
	
	ret1.add("CREATE TABLE tdm_test_tree_group ( \n"+
			 " ID bigint(11) NOT NULL, \n"+
			 " tree_id bigint(11) DEFAULT '0', \n"+
			 " group_id int(11), \n"+
			 " PRIMARY KEY (ID), \n"+
			 " KEY ndx_test_tree_group_tree_id (tree_id), \n"+
			 " KEY ndx_test_tree_group_group_id (group_id) \n"+
			" ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
	return ret1;
}




%>