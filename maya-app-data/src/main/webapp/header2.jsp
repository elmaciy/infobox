<%@page import="com.ibm.db2.jcc.am.oe"%>
<%@page import="java.security.acl.Owner"%>
<%@page import="com.ibm.db2.jcc.am.ap"%>
<%@page import="org.xml.sax.InputSource"%>
<%@page import="java.net.InetAddress"%>
<%@page import="java.net.HttpURLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.io.DataInputStream"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.File"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.BufferedWriter"%>
<%@page import="java.io.ObjectInputStream"%>
<%@page import="java.io.ByteArrayInputStream"%>
<%@page import="java.io.OutputStreamWriter"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.StringReader"%>
<%@page import="java.io.FileReader"%>

<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="javax.naming.directory.DirContext" %>
<%@ page import="javax.naming.directory.InitialDirContext" %>
<%@ page import="javax.sql.*" %>
<%@ page import="java.util.*" %> 
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.io.ByteArrayOutputStream"%>
<%@page import="java.util.zip.*"%>
<%@page import="java.util.Date"%>
<%@page import="javax.servlet.*"%>
<%@page import="oracle.sql.ROWID"%>
<%@page import="java.sql.DatabaseMetaData"%>
<%@page import="javax.mail.Message" %>
<%@page import="javax.mail.MessagingException" %>
<%@page import="javax.mail.PasswordAuthentication" %>
<%@page import="javax.mail.Session" %>
<%@page import="javax.mail.Transport" %>
<%@page import="javax.mail.internet.AddressException" %>
<%@page import="javax.mail.internet.InternetAddress" %>
<%@page import="javax.mail.internet.MimeMessage" %>
<%@page import="com.sun.mail.util.BASE64DecoderStream" %>
<%@page import="com.sun.mail.util.BASE64EncoderStream" %>
<%@page import="javax.crypto.Cipher" %>
<%@page import="javax.crypto.KeyGenerator" %>
<%@page import="javax.crypto.SecretKey" %>
<%@page import="javax.crypto.spec.SecretKeySpec" %>
<%@page import="org.apache.commons.codec.binary.Base64" %>
<%@page import="org.apache.commons.io.FileUtils" %>
<%@page import="com.jbase.jremote.DefaultJConnectionFactory" %>
<%@page import="com.jbase.jremote.JDynArray" %>
<%@page import="com.jbase.jremote.JRemoteException" %>
<%@page import="com.jbase.jremote.JResultSet" %>
<%@page import="com.jbase.jremote.JStatement" %>
<%@page import="com.jbase.jremote.JConnection" %>
<%@page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@page import="javax.xml.parsers.DocumentBuilder" %>
<%@page import="org.w3c.dom.*" %>


<%@page import="javax.script.ScriptEngine" %>
<%@page import="javax.script.ScriptEngineManager" %>

<%@page import="java.util.regex.Matcher" %>
<%@page import="java.util.regex.Pattern" %>



<%@page import="org.bson.Document"%>
<%@page import="org.bson.types.ObjectId"%>

<%@page import="com.mongodb.MongoClient"%>
<%@page import="com.mongodb.MongoClientURI"%>
<%@page import="com.mongodb.MongoCredential"%>
<%@page import="com.mongodb.ServerAddress"%>
<%@page import="com.mongodb.client.FindIterable"%>
<%@page import="com.mongodb.client.MongoDatabase"%>

<%@page import="com.mongodb.DBObject"%>
<%@page import="com.mongodb.BasicDBObject"%>

<%@page import="com.mongodb.util.JSON"%>

<%@page import="org.apache.poi.hssf.usermodel.HSSFSheet"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFWorkbook"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFRow"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFCell"%>


<%

request.setCharacterEncoding("utf-8");



String logout=nvl(request.getParameter("logout"),"");

if (logout.equals("YES")) 	{
	session.setAttribute("username", "");	
	session.setAttribute("userid", 0);	
	session.setAttribute("userfname","");	
	session.setAttribute("userlname", "");	
	session.setAttribute("useremail", "");	
	
	
	session.setAttribute("WAITING_ACTION_LIST", null);
	
	session.setAttribute("FLOW_STATE_LIST", null);
	
	Connection connconf=getconn();

	if (connconf!=null)  {
		String sql="select shortcode from tdm_role";
		ArrayList<String[]> allRoles=getDbArrayConf(connconf, sql, Integer.MAX_VALUE, new ArrayList<String[]>());
		closeconn(connconf);
		
		for (int i=0;i<allRoles.size();i++) {
			session.setAttribute("hasrole_"+allRoles.get(i)[0], "false");
		}
		


		
		//clear filters
		
		Enumeration<String> attributeNames= session.getAttributeNames();
		
		 while(attributeNames.hasMoreElements()) {
	         String current = (String) attributeNames.nextElement();

	         System.out.println("clearing ... " +current);            

	         session.removeAttribute(current);     
	     } 

		
		
	}
	
	
	closeconn(connconf);
	
	
	//clear all session attributes
	Enumeration<String> attributeNames= session.getAttributeNames();
	 while(attributeNames.hasMoreElements()) {
        String current = (String) attributeNames.nextElement();
        session.removeAttribute(current);     
    }   
	
	response.sendRedirect("default2.jsp");
}


String currurl="";

currurl=nvl(request.getRequestURL().toString(),"");

String curruser="";

curruser=nvl((String) session.getAttribute("username"),"");

if ((!currurl.contains("default2.jsp") && !currurl.contains("install.jsp"))  && curruser.isEmpty()) {
	session.setAttribute("username", "");	
		
	response.sendRedirect("default2.jsp");	
}


 
%>


 <%! 


final String DEFAULT_DATE_FORMAT="dd/MM/yyyy HH:mm:ss";
String mysql_format="%d.%m.%Y %H:%i:%s";



//*********************************************************************************************

public String newMenuItem(HttpServletRequest request, String icon, String title, String page) {

	String def_class="navbar-brand";
	String style="";
	
	if(request.getRequestURI().contains(page)) {
		style="background-color:#428bca; color: white; ";
	}
		


		return 
				"<a class=\""+def_class+"\" href=\""+page+"\" style=\""+style+"\">" +
			            "<small><span class=\"glyphicon glyphicon-"+icon+"\" ></span> <b>"+title +"</b></small>" +
					  "</a>";
		
}


//***********************************
public String printHeader(HttpServletRequest request, HttpSession session) {
//***********************************

	String curruser="";
	            
	try{curruser=(String) session.getAttribute("username");} catch(Exception e) {curruser="";}
	
	int len=0;
	try {len=curruser.length();} catch(Exception e) {len=0;}

	String html="";

    html=html +"\n"+
    	    "<div class=\"modal hide\" id=\"pleaseWaitDialog\" data-backdrop=\"static\" data-keyboard=\"false\">\n"+
    	    " <div class=\"modal-header\">\n"+
    	    "     <h1>Processing...</h1>\n"+
    	    " </div>\n"+
    	    " <div class=\"modal-body\">\n"+
    	    "     <div class=\"progress progress-striped active\">\n"+
    	    "         <div class=\"bar\" style=\"width: 100%;\"></div>\n"+
    	    "    </div>\n"+
    	    " </div>\n"+
    	    "</div>";    		
	 
	
   html = html +  "<div class=\"alert alert-success hide\" role=\"alert\" id=\"myAlert\">MyAlertMessage</div>";

		

	  html = html +
	  "<nav >"+
	      "<div class=\"container-fluid\">\n";
	          
      html=html +  "<ul class=\"nav navbar-nav\">";
	          
	          
   	  html=html+ newMenuItem(request, "home", "Home", "default2.jsp");


				  

      if (checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 
     	  html=html+ newMenuItem(request, "eye-open", "Discover", "discovery.jsp");
	        	  
	  if (checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 	
		  html=html+newMenuItem(request, "list", "List", "list2.jsp");

		  
	  if (checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 	  
		html=html+newMenuItem(request, "edit", "Profile", "profile2.jsp");
		  
	  if (checkrole(session, "DESIGN") || checkrole(session, "ADMIN"))
		  html=html+ newMenuItem(request, "record", "Design", "designer2.jsp");

	  if (checkrole(session, "RUN") || checkrole(session, "DESIGN") || checkrole(session, "ADMIN") || checkrole(session, "COPYUSER")) 
		  html=html+ newMenuItem(request, "transfer", "Copy", "copy.jsp");
		
	  if (checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 
		  html=html+ newMenuItem(request, "filter", "Protect", "dm.jsp");
		
	  if (checkrole(session, "RUN") || checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 
		  html=html+ newMenuItem(request, "picture", "Monitor", "monitoring2.jsp");
	  
	  
	  if (checkrole(session, "MADRM") || checkrole(session, "ADMIN")) 	
		  html=html+newMenuItem(request, "wrench", "Configure", "configuration.jsp");
	  
	  
	  if (checkrole(session, "ADMIN"))
		  html=html+ newMenuItem(request, "wrench", "Admin", "admin2.jsp");


	  if (checkrole(session, "RUN") || checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 
		  html=html+ newMenuItem(request, "info-sign", "", "about.jsp");
	  
	  html=html+"</ul>";
			  
	  html=html +  "<ul class=\"nav navbar-nav navbar-right\">";
	  
	  if (len==0) {
      	html=html+
          "<form class=\"form-inline\" role=\"form\" name=\"flogin\">\n" +
          "  <div class=\"form-group\" style=\"margin:5px;\">\n" +
          "    <label class=\"sr-only\" for=\"txtUsername\">Username</label>\n" +
          "    <input class=\"form-control\" id=\"txtUsername\" placeholder=\"Username\" name=\"username\">\n" +
          "  </div>\n" +
          "  <div class=\"form-group\">\n" +
          "    <label class=\"sr-only\" for=\"password\">Password</label>\n" +
          "    <input type=\"password\" id=\"txtPassword\" class=\"form-control\" id=\"password\" placeholder=\"Password\" name=\"password\">\n" +
          "  </div>\n"+
          "  <input type=\"button\" name=btlogin class=\"btn-primary btn-sm\" value=\"Login\"  onclick=\" doLogin();\" />\n";
          
         if (nvl(((String) session.getAttribute("invalid_user_attempt")),"-").equals("true")) 
      	   html=html+"<br><center><font color=red size=2>Invalid username or password!!!</font></center>";
          		
         html=html+"</form>";
      }
      else {
			
    	  html=html+"<li> <span class=\"glyphicon glyphicon-user\"> [<font color=blue>"+curruser+"</font>]</li>";
    	  
    	  html=html+"<li><a href=\"default2.jsp?logout=YES\">Logout <span class=\"glyphicon glyphicon-log-out\"></span></a></li>";
      }
				
	  html=html+    "</ul>\n";
	        
           
				  
  	html=html+				  
      "</div>\n" +
    "</nav>\n" ;

	    
		

	return html;
}


//***********************************************
public boolean testmail(Connection conn, StringBuilder sbLog) {
//***********************************************
	
	String sql="";
	String from=nvl(getParamByName(conn,"JAVAX_TEST_EMAIL_ADDRESS"), "TDM@tdmexpert.com");
	
	String to=getParamByName(conn,"JAVAX_EMAIL_ADDRESS");
	if (to.trim().length()==0) {
		sbLog.append("JAVAX_EMAIL_ADDRESS parameter not found");
		return false;
	}

	final String username=getParamByName(conn,"JAVAX_EMAIL_USERNAME");
	final String password=decode(getParamByName(conn,"JAVAX_EMAIL_PASSWORD"));
	
	System.out.println("*****************   TEST MAIL *************************");
	System.out.println("JAVAX_TEST_EMAIL_ADDRESS : " + from);
	System.out.println("JAVAX_EMAIL_USERNAME : " + username);
	
	Properties props=System.getProperties();

	String props_str=getParamByName(conn,"JAVAX_EMAIL_PROPERTIES");
	
	if (props_str.length()==0) {
		sbLog.append("JAVAX_EMAIL_PROPERTIES parameter not found");
		return false;
	}
	else 
	{
		String[] arr=props_str.split("\n");
		for (int i=0;i<arr.length;i++) {
			String line=arr[i].trim();
			String par="";
			String val="";
			if (line.contains("=")) {
				par=line.split("=")[0];
				val=line.split("=")[1];
			}
			if (par.length()>0) {
				System.out.println("Setting Javax Email Property : " + par+"="+val);
				props.put(par, val);
			}
			
		}
		
	}
	
	
	
	
	StringBuilder sb=new StringBuilder();
	sb.append("test mail");
	
	Session session=null;
	String auth_err_msg="";
	if (username.length()==0) 
			session=Session.getInstance(props);
	else {
		try {
		session=Session.getInstance(props,new javax.mail.Authenticator() {
			protected PasswordAuthentication getPasswordAuthentication() {
				return new PasswordAuthentication(username, password);
			}
		  });
		} catch(Exception e) {auth_err_msg=e.getMessage(); e.printStackTrace();}
	}
	
	if (session==null) {
		System.out.println("Not authenticated. : "+auth_err_msg);
		props=null;
		sbLog.append("Not authenticated. : "+auth_err_msg);
		return false;
	}
	else
		System.out.println("authenticated... ");

	
	
	Message msg=new MimeMessage(session);
	
	try {

				msg.setContent(sb.toString(), "text/html; charset=utf-8");
				sb=null;
				msg.setFrom(new InternetAddress(from));

				String[] targetAddresses=to.split(";");
				for (int t=0;t<targetAddresses.length;t++) {
					String atarget=targetAddresses[t].trim();
					if (atarget.length()>0) {
					msg.addRecipients(Message.RecipientType.TO, InternetAddress.parse(atarget,false));
					}
				}
				
			

				msg.setSubject("test mail from data masking");

				System.out.println("message is ready to send. transporting... ");

				Transport.send(msg);

				System.out.println("mail was sent successfully to : "+to);
				
				sbLog.append("Email was successfully sent");
				return true;
	} catch (Exception e) {
		System.out.println("Exception@Transport.send : "+e.getMessage());
		//e.printStackTrace();
		sbLog.append("Exception@Transport.send : "+e.getMessage());
		return false;
	}
	finally {
		props=null;
		msg=null;
		
	}
	
	
	
}




// ----------------------------------------------
public String getEnvValue(String key1) {
    String ret1 = "";

    Map<String, String> env = System.getenv();

    for (String envName : env.keySet()) {
        if (envName.toUpperCase().indexOf(key1.toUpperCase()) == 0) {
            ret1 = env.get(envName);
        }
    }
    
    ret1=ret1.replaceAll("\"", "");
    //System.out.println(key1+"="+ret1);
    
    
    return ret1;
}


//*************************************************************
private boolean testconn(Connection connconf, String env_id) {
//************************************************************
boolean ret1=true;
Connection conn=getconn(connconf, env_id);
if (conn==null) ret1=false;
closeconn(conn);
return ret1;
}




//*************************************************************
private Connection getconn() {
	Connection conn = null;

	try {
		Context initContext = new InitialContext();
		Context envContext  = (Context)initContext.lookup("java:/comp/env");
		DataSource ds = (DataSource) envContext.lookup("jdbc/tdmconfig");
		
		try {ds.setLoginTimeout(20);} catch(Exception e) {}

		try {
			
			conn = ds.getConnection();
			
		} catch (SQLException e) {
			conn=null;
			System.out.print("getconn@"+e.getMessage());
			e.printStackTrace();
		}
		
	} catch (NamingException e) {
		conn=null;
		System.out.print("NamingException@"+e.getMessage());
		e.printStackTrace();
	}
	


	return conn;
}



String last_connection_error="";

/*
String start_char="\"";
String end_char="\"";
String middle_char=".";
*/
//*************************************************************
private Connection getconn(Connection connconf, String env_id) {
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",env_id});
	
	String sql="select db_driver, db_connstr, db_username, db_password, db_catalog from tdm_envs where id=?";
	ArrayList<String[]> recs=getDbArrayConf(connconf, sql, 1, bindlist);
	
	if (recs.size()==0) {
		System.out.println("Exception@getconn : Environment parameters cannot be retrieved. Environment id : "+env_id);
		return null;
	}
	
	String db_driver="";
	String db_connstr="";
	String db_username="";
	String db_password="";
	String db_catalog="${default}";
	
	try{
	db_driver=recs.get(0)[0];
	db_connstr=recs.get(0)[1];
	db_username=recs.get(0)[2];
	db_password=passwordDecoder(recs.get(0)[3]); 
	db_catalog=recs.get(0)[4]; 
	
	
	} catch(Exception e) {
		e.printStackTrace();
		return null;
	}
	
		Connection ret1 = null;
		String test_sql="";
		
		sql="select flexval1, flexval2 from  tdm_ref where ref_type='DB_TYPE' and ref_name='"+db_driver+"'";
		
		ArrayList<String[]> retdb=getDbArrayConf(connconf, sql, 1, new ArrayList<String[]>());
		
		if (retdb.size()==0) {
			System.out.println("Exception@getconn : Database type parameters cannot be retrieved. db driver : "+db_driver);
			return null;
		}
		
		String db_type=retdb.get(0)[0];
		String template=retdb.get(0)[1];
		

		
		if (template.contains("|")) 
			test_sql=template.split("\\|")[0];
		
		if (test_sql.length()==0) test_sql="select 1";
		

			try {
				Class.forName(db_driver.replace("*",""));
				Connection conn = DriverManager.getConnection(db_connstr, db_username, db_password);
				
				setCatalogForConnection(conn, db_catalog);
				
				Statement stmt = conn.createStatement();
				ResultSet rset = stmt.executeQuery(test_sql);
				while (rset.next()) {rset.getString(1);	}
	
				ret1=conn; 
				
				
				
			} catch (Exception ignore) {
				last_connection_error=ignore.getMessage();
				ignore.printStackTrace();
				ret1=null;
			}

	return ret1;
	}

//*************************************************************
private void closeconn(Connection conn) {
		if (conn==null) return;
		try {
			conn.close();
			conn=null;
		} catch (SQLException e) {
			conn=null;
			System.out.print("closeconn@"+e.getMessage());
		}
		
}

//*************************************************************
public ArrayList<String[]> getWpcListByWorkPlan(Connection connconf,String work_plan_id, String a_filter) {
	String sql="select id,status from tdm_work_package where work_plan_id="+nvl(work_plan_id,"0");
	if(!nvl(a_filter,"-").equals("-")  && !nvl(a_filter,"-").equals("ALL")) sql=sql +" and tab_id=" + a_filter;
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	return getDbArrayConf(connconf, sql, Integer.MAX_VALUE, bindlist);
}


String TABLE_SQL_ORACLE="select '${default}' table_catalog, owner, table_name from all_tables where status='VALID' and '${default}'=?";
String TABLE_SQL_ORACLE_FOR_DMASK=
	"select * from ( "+
	"select '${default}' table_catalog, owner, table_name from dba_all_tables where status='VALID'"+
	" union all "+
	"select '${default}' table_catalog, owner, view_name table_name from all_views "+
	") where table_catalog=?";
			
String TABLE_SQL_MSSQL="SELECT table_catalog, table_schema, table_name FROM INFORMATION_SCHEMA.TABLES where TABLE_TYPE='BASE TABLE' and table_catalog=? ";
String TABLE_SQL_MSSQL_FOR_DMASK="SELECT table_catalog, table_schema, table_name FROM INFORMATION_SCHEMA.TABLES where TABLE_TYPE in('BASE TABLE','VIEW') and table_catalog=? ";

String TABLE_SQL_MYSQL="select table_schema, table_schema, table_name from information_schema.tables where TABLE_TYPE='BASE TABLE' and table_schema=? ";
String TABLE_SQL_MYSQL_FOR_DMASK="select table_schema, table_schema, table_name from information_schema.tables where TABLE_TYPE in('BASE TABLE','VIEW') and table_schema=? ";


String TABLE_SQL_POSTGRESQL="SELECT table_catalog, table_schema, table_name FROM INFORMATION_SCHEMA.TABLES where TABLE_TYPE='BASE TABLE' and table_catalog=? ";
String TABLE_SQL_POSTGRESQL_FOR_DMASK="SELECT table_catalog, table_schema, table_name FROM INFORMATION_SCHEMA.TABLES where TABLE_TYPE in('BASE TABLE','VIEW') and table_catalog=?";

String TABLE_OWNER_FILTER_SQL_ORACLE=" and owner=?";
String TABLE_OWNER_FILTER_SQL_MSSQL=" and table_schema=?";
String TABLE_OWNER_FILTER_SQL_MYSQL=" and table_schema=?";
String TABLE_OWNER_FILTER_SQL_POSTGRESQL=" and table_schema=?";

//*************************************************************
public ArrayList<String> getTabList(Connection connconf,String env_id, String app_type, String catalog_filter, String owner_filter, String table_filter) {
	
	
	ArrayList<String> ret1=new ArrayList<String>();
	
	Connection connApp=getconn(connconf, env_id);
	
	String db_type=getEnvDBParam(connconf, env_id, "DB_TYPE");
	
	
	
	
	ResultSet rs = null;
	DatabaseMetaData md=null;
	
	String tname="";
	String[] type_filter=new String[] {"TABLE"};
	String schema_filter=owner_filter;
	if (nvl(schema_filter,"All").equals("All"))  schema_filter=null;
	int cnt=0;
	
	if (connApp==null) {
		System.out.println("Error@getTabList : connection is invalid.");
		return ret1;
	}
	
	try {
		
		int MAX_TAB_COUNT=1000;
		try{MAX_TAB_COUNT=Integer.parseInt(nvl(getParamByName(connconf, "MAX_TABLE_COUNT"),"1000"));} catch(Exception e) {MAX_TAB_COUNT=1000;}
		
		ArrayList<String[]> catList=getCatalogListFromConn(connApp, db_type);
		
		
		md = connApp.getMetaData();
		
		for (int c=0;c<catList.size();c++) {
			
			if (cnt>MAX_TAB_COUNT) break;
			
			String cat=nvl(catList.get(c)[0],"${default}");
			
			if (!nvl(catalog_filter,"All").equals("All") && !cat.equals(catalog_filter)) continue;
			
			if (db_type.equals("MSSQL") && isCatalogMSSQLOffline(connApp, cat) ) {
				System.out.println("Skipping offine catalog : "+cat);
				continue;
			}
			
			String table_view_sql="";
			
			if (db_type.equals("ORACLE")) {
				if (app_type.equals("DMASK"))
					table_view_sql=TABLE_SQL_ORACLE_FOR_DMASK;
				else
					table_view_sql=TABLE_SQL_ORACLE;
			}
			else if (db_type.equals("MSSQL")) {
				if (app_type.equals("DMASK"))
					table_view_sql=TABLE_SQL_MSSQL_FOR_DMASK;
				else
					table_view_sql=TABLE_SQL_MSSQL;
			}
			else if (db_type.equals("MYSQL")) {
				if (app_type.equals("DMASK"))
					table_view_sql=TABLE_SQL_MYSQL_FOR_DMASK;
				else
					table_view_sql=TABLE_SQL_MYSQL;
			}
			else if (db_type.equals("SYBASE")) {
				if (app_type.equals("DMASK"))
					table_view_sql="exec sp_tables '%', '%', '"+cat+"', \"'TABLE','VIEW'\"";
				else
					table_view_sql="exec sp_tables '%', '%', '"+cat+"', \"'TABLE'\"";
			}
			else if (db_type.equals("POSTGRESQL")) {
				if (app_type.equals("DMASK"))
					table_view_sql=TABLE_SQL_POSTGRESQL_FOR_DMASK;
				else
					table_view_sql=TABLE_SQL_POSTGRESQL;
			}
			
			
			if (table_view_sql.length()>0) {
				int remaining=MAX_TAB_COUNT-cnt;	
				
				ArrayList<String[]> bindlist=new ArrayList<String[]>();
				
				
				bindlist.add(new String[]{"STRING",cat});
				
				if (db_type.equals("SYBASE")) 
					bindlist.clear();
				
				String table_list_sql=table_view_sql;
				
				String splitted_owner=owner_filter;
				
				if (!nvl(owner_filter,"All").equals("All")) {

					if (owner_filter.contains(".")) {
						try {splitted_owner=owner_filter.substring(owner_filter.indexOf(".")+1);} catch(Exception e) {
							System.out.println("Exception@getTabList.splitOwner ["+owner_filter+"]: "+e.getMessage());
						}
					}
					else {
						splitted_owner=owner_filter;
					}
						
					
					
					
					if (db_type.equals("ORACLE")) {
						table_list_sql=table_list_sql+TABLE_OWNER_FILTER_SQL_ORACLE;
						bindlist.clear();
						bindlist.add(new String[]{"STRING",cat});
						bindlist.add(new String[]{"STRING",splitted_owner}); 
					}
					else if (db_type.equals("MSSQL")) {
						table_list_sql=table_list_sql+TABLE_OWNER_FILTER_SQL_MSSQL;
						bindlist.clear();
						bindlist.add(new String[]{"STRING",cat});
						bindlist.add(new String[]{"STRING",splitted_owner}); 
					}
					else if (db_type.equals("MYSQL")) {
						table_list_sql=table_list_sql+TABLE_OWNER_FILTER_SQL_MYSQL;
						bindlist.clear();
						bindlist.add(new String[]{"STRING",cat});
						bindlist.add(new String[]{"STRING",splitted_owner}); 
					}
					else if (db_type.equals("SYBASE")) {
						if (app_type.equals("DMASK"))
							table_view_sql="exec sp_tables '%', '"+splitted_owner+"', '"+cat+"', \"'TABLE','VIEW'\"";
						else
							table_view_sql="exec sp_tables '%', '"+splitted_owner+"', '"+cat+"', \"'TABLE'\"";
						
						bindlist.clear();
						 
					}
					else if (db_type.equals("POSTGRESQL")) {
						table_list_sql=table_list_sql+TABLE_OWNER_FILTER_SQL_POSTGRESQL;
						bindlist.clear();
						bindlist.add(new String[]{"STRING",cat});
						bindlist.add(new String[]{"STRING",splitted_owner}); 
					}
					
					
				}
				
				System.out.println("table_list_sql="+table_list_sql);
				System.out.println("catalog_filter="+catalog_filter);
				System.out.println("splitted_owner="+splitted_owner);

				System.out.println("setCatalogForConnection="+cat);         
				setCatalogForConnection(connApp, cat);
				
				ArrayList<String[]> tabArr=getDbArrayApp(connApp, table_list_sql, remaining, bindlist, false, "");
				
				
				for (int t=0;t<tabArr.size();t++) {
					
					if (cnt>MAX_TAB_COUNT) break;
					
					String table_catalog=tabArr.get(t)[0];
					String table_schema=tabArr.get(t)[1];
					String table_name=tabArr.get(t)[2];
					
					if (table_schema==null || table_schema.length()==0) table_schema=table_catalog;
					
					tname=nvl(table_catalog,"${default}")+"*"+table_schema+"*"+table_name;

					if (!nvl(splitted_owner,"All").equals("All") &&  !table_schema.toLowerCase().equals(splitted_owner.trim().toLowerCase())) {
						System.out.println("Skipped :["+tname+"], since schema filter ["+splitted_owner+"] not matched.");
						continue;
					}
					

					if (table_filter.trim().length()>0 &&  !table_name.toLowerCase().contains(table_filter.trim().toLowerCase())) {
						System.out.println("Skipped :["+tname+"], since table filter ["+table_filter+"] not matched.");
						continue;
					}
					
					if (cnt % 10==0)
						System.out.println("Added ["+cnt+"] :["+tname+"] from information view.");
					
					ret1.add(tname);
					
					cnt++;
				}
				
				
			} else {
				
				try {
					System.out.println("getting tables for catalog "+cat);
							
					rs = md.getTables(null, null, null, type_filter);
					
					if (rs==null) {
						System.out.println("metadata resultset is null for table");
						continue;
					}
							
					while (rs.next()) {
						
						
						if (cnt>MAX_TAB_COUNT) break;
						String table_catalog=rs.getString("TABLE_CAT");
						String table_schema=rs.getString("TABLE_SCHEM");
						String table_name=rs.getString("TABLE_NAME");
						
						if (table_schema==null || table_schema.length()==0) table_schema=table_catalog;
						
						
						
						//tname=nvl(table_catalog,"${default}")+"*"+table_schema+"*"+table_name;
						tname=cat+"*"+table_schema+"*"+table_name;
						
						System.out.println("Added ["+cnt+"] :["+tname+"] from jdbc.");
						
						ret1.add(tname);
						
						cnt++;
					}
					
				} catch(Exception e) {
					e.printStackTrace();
				} finally {
					try {rs.close();} catch(Exception e) {}
				}
			}
			
			
			
		}
		
		
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		closeconn(connApp);

	}
	
	return ret1;
	
}

//*************************************************************
String getDbName(Connection conn) {
//*************************************************************
	String url="";

	try {url=conn.getMetaData().getURL();} catch(Exception e) {}
	
	String split_str="";
	if (url.indexOf("database=")>-1) split_str="database=";
	if (url.indexOf("databaseName=")>-1) split_str="databaseName=";
	if (url.indexOf("DatabaseName=")>-1) split_str="DatabaseName=";
	if (url.indexOf("db=")>-1) split_str="db=";
	if (url.indexOf("dbname=")>-1) split_str="dbname=";
	
	String db_name="";
	try{db_name=url.split(split_str)[1].split(";")[0];} catch(Exception e) {}
	
	return db_name;
}

//*************************************************************
void setCatalogForConnection(Connection conn, String cat) {
	if (cat.length()>0 && !cat.equals("${default}")) {
		
		String curr_cat="";
		try { curr_cat=nvl(conn.getCatalog(),"");} catch(Exception e) {e.printStackTrace();}
		
		if (!curr_cat.equals(cat)) {
			System.out.println("setting catalog to ="+cat);
			try { conn.setCatalog(cat);} catch(Exception e) {e.printStackTrace();}	
		}
			
	}
}

//*************************************************************
ArrayList<String> getPrimaryKeyList(Connection conn, String cat, String owner, String table, String db_type) {
	ArrayList<String> pklist=new   ArrayList<String>();
	ArrayList<String> pkorder=new   ArrayList<String>();

	System.out.println("Getting primary keys for "+cat+"."+owner+"."+table);
	
	setCatalogForConnection(conn, cat);
			
	try {
	DatabaseMetaData meta = conn.getMetaData();
	
	ResultSet rspk = null;
	
	try {
		
		rspk = meta.getPrimaryKeys(owner, null, table);

		while (rspk!=null && rspk.next()) {
		      
			  String columnName = rspk.getString("COLUMN_NAME"); 
		      String keySeq=rspk.getString("KEY_SEQ");
		      pklist.add(columnName);
		      pkorder.add(keySeq);
		    }
	} catch(Exception e) { } finally {try{rspk.close();} catch(Exception e){}}
	

	if (pklist.size()==0) {
		try {
			
			rspk = meta.getPrimaryKeys(cat, owner, table);

			while (rspk!=null && rspk.next()) {
				  String columnName = rspk.getString("COLUMN_NAME"); 
			      String keySeq=rspk.getString("KEY_SEQ");
			      pklist.add(columnName);
			      pkorder.add(keySeq);
			    }
		} catch(Exception e) { } finally {try{rspk.close();} catch(Exception e){}}
	}
	
	if (pklist.size()==0) {
		try {
			
			rspk = meta.getPrimaryKeys(null, null, table);

			while (rspk!=null && rspk.next()) {
				  String columnName = rspk.getString("COLUMN_NAME"); 
			      String keySeq=rspk.getString("KEY_SEQ");
			      pklist.add(columnName);
			      pkorder.add(keySeq);
			    }
		} catch(Exception e) { } finally {try{rspk.close();} catch(Exception e){}}
	}
	
	//DBs like SQL Server
	
	if (pklist.size()==0) {
		String db_name=getDbName(conn);

		
		if (db_name.length()>0) {
			rspk = meta.getPrimaryKeys(owner, owner, table);

			while (rspk!=null && rspk.next()) {
				  String columnName = rspk.getString("COLUMN_NAME");
			      String keySeq=rspk.getString("KEY_SEQ");
			      pklist.add(columnName);
			      pkorder.add(keySeq);
			    }
			rspk.close();
		} //if (db_name.length()>0)
		
	}
	
	} catch(Exception e) {}
	
	
	
	if (pklist.size()==0) {
		if (db_type.equals("SYBASE")) 
			getPrimaryKeyListForSybase(conn,cat, owner, table, pklist, pkorder);
		
	}
	
	ArrayList<String> ret1=new ArrayList<String>();
	
	
	for (int i=1;i<100;i++) {
		int x=pkorder.indexOf(""+i);
		if (x==-1) break;
		ret1.add(pklist.get(x));
	}
	

	return ret1;
}

//*************************************************************
void getPrimaryKeyListForSybase(Connection conn, String cat, String owner, String table, ArrayList<String> pklist, ArrayList<String> pkorder) {
	
	setCatalogForConnection(conn, cat);
	
	
	String sql="select "+
			" keycnt, key1, key2, key3, key4, key5, key6, key7, key8 "+
			" from  "+
			" sysobjects o  , sysusers  u , syskeys k "+
			" where  "+
			" o.type='U' and u.name=? and o.name=? "+
			" and o.uid = u.uid  "+
			" and o.id = k.id and k.type=1 /*pk*/";
	
	

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",owner});
	bindlist.add(new String[]{"STRING",table});
	
	
	ArrayList<String[]> pkArr=getDbArrayApp(conn, sql, 1, bindlist, false, "");
	
	if (pkArr.size()==0) {
		System.out.println("getPrimaryKeyListForSybase : no PK found");
		return;
	}
	
	sql="select  c.colid, c.name "+
		"	from  "+
		"	sysobjects o  , sysusers  u, syscolumns c "+
		"	where  "+
		"	o.type='U' and u.name=? and o.name=? "+
		"	and o.uid = u.uid  "+
		"	and o.id = c.id "+
		"	order by colid";
	
	ArrayList<String[]> colArr=getDbArrayApp(conn, sql, 1, bindlist, false, "");
	
	if (colArr.size()==0) {
		System.out.println("getPrimaryKeyListForSybase : no columns found");
		return;
	}
	
	int keycnt=0;
	
	try{keycnt=Integer.parseInt(pkArr.get(0)[0]);} catch(Exception e) {}
	
	if (keycnt==0) {
		System.out.println("getPrimaryKeyListForSybase : keycnt=0");
		return;
	}
	
	
	for (int i=1;i<=keycnt;i++) {
		int colid=0;
		try{colid=Integer.parseInt(pkArr.get(0)[i]);} catch(Exception e) {}
		if (keycnt==0) break;
		
		for (int c=0;c<colArr.size();c++) {
			String arr_col_id=colArr.get(c)[0];
			String arr_col_name=colArr.get(c)[1];
			
			if (!arr_col_id.equals(""+colid)) continue;
			
			 pklist.add(arr_col_name);
		     pkorder.add(arr_col_id);
		}
	}
	
	
	
}
//*************************************************************
String getCatalog(Connection conn,String owner, String table) {
	String ret1="Northwind";
	String[] types = {"TABLE"};
	DatabaseMetaData md=null;
	ResultSet rs =null;
	
	try {
		md = conn.getMetaData();
		
		rs = md.getTables(null, owner, table, types);
		if (rs.next()) {
			return nvl(rs.getString("TABLE_CAT"),"");
		} else 
			System.out.println("Table not found [owner="+owner+",table="+table+"]");
		
	} catch(Exception e) {
		e.printStackTrace();
	} finally {
		try {rs.close();}catch(Exception e) {}
	}
	
	return ret1;
}


//*************************************************************
public ArrayList<String[]> getFieldListFromApp(Connection conn, String env_db_rowid, String cat, String owner, String table, String db_type) {
//*************************************************************

	long s=System.currentTimeMillis();
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	
	
	DatabaseMetaData md=null;
	
	String f_name="";
	String f_type="";
	String f_size="";
	String f_is_pk="";
	String f_cat="";
	String f_schema="";
	String f_table="";
	
	setCatalogForConnection(conn, cat);
		
	
	
	ArrayList<String> pklist=new ArrayList<String>();

	//if db have row id add it as a first column
	if (env_db_rowid.trim().length()>0) {
		String[] arr=new String[]{env_db_rowid, env_db_rowid, "0","YES"};
		ret1.add(arr);
	} 
	else
	{
		pklist=getPrimaryKeyList(conn, cat, owner, table, db_type);
		
	} //if (env_db_rowid.length()>0) 
	
		
		

	String[] type_filter=new String[] {"TABLE"};
	
	if (conn!=null) {
		
		
		if (db_type.equals("JBASE")) {
			ArrayList<String> jbaseFields=getJbaseFields(table);
			for (int i=0;i<jbaseFields.size();i++) {
				
				String field_name=jbaseFields.get(i);
				String is_pk="NO";
				
				if (field_name.indexOf("*")==0) {
					field_name=field_name.substring(1);
					is_pk="YES";
				}

				String[] arr=new String[]{field_name, "VARCHAR", "1000", is_pk};
				ret1.add(arr);
			}
		}
		else {
			
			
			
			ResultSet rs = null;

			try {
				System.out.println("Getting column list for : " + owner+"."+table);
				
				md = conn.getMetaData();


				rs = md.getColumns(null, owner, table, null);
				
				int c=0;
				
				
				while (rs.next()) {
					boolean is_added=false;
					c++;
					
					
					f_name=rs.getString("COLUMN_NAME"); //4
					f_type=rs.getString("TYPE_NAME");
					f_size=rs.getString("COLUMN_SIZE");
					f_cat=nvl(rs.getString("TABLE_CAT"),"");
					f_schema=nvl(rs.getString("TABLE_SCHEM"),"");
					f_table=nvl(rs.getString("TABLE_NAME"),"");
					
					
					f_is_pk="NO";
					
					if (!f_table.toUpperCase().equals(table.toUpperCase())) {
						System.out.println("Skip for different table column..."+f_schema+"."+f_table);
								
						continue;
					}
					

					
					for (int p=0;p<pklist.size();p++)
						if (f_name.equals(pklist.get(p))) 
							f_is_pk="YES";
					
					//for some tables (partitioned eg.) column names may be duplicated
					for (int f=0;f<ret1.size();f++)
						if (f_name.equals(ret1.get(f)[0])) is_added=true;
						
					String[] arr=new String[]{f_name, f_type, f_size, f_is_pk};
					if (!is_added) ret1.add(arr);
					}
			
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {md = null;} catch (Exception e) {}
				try {rs.close();rs = null;} catch (Exception e) {}
			}
			
		} // else if (db_type.equals("JBASE"))
		
	
	}
	
	
	
	return ret1;

}

//************************************************


String limitString(String instr, int limit) {

	if (instr==null || instr.length()<=limit) return instr;
	return instr.substring(0,limit)+"...";
}

//************************************************
String getTabContent(Connection conn, String env_id, String editor_sql, String tab_name , String cat) {
	StringBuilder tabstr=new StringBuilder();
	int recno=0;
	int maxrec=100;
	
	
	String db_type=getEnvDBParam(conn, env_id, "DB_TYPE");
	
	if (db_type.toUpperCase().contains("MONGO")) {
		tabstr.append(getMongoCollectionContent(conn, env_id,editor_sql,maxrec, cat));
		
		return tabstr.toString();
		
	} 
	
	
	if (!testconn(conn, env_id)) {
		tabstr.append("<table border=1>");
		tabstr.append("<tr bgcolor=#FADABC><td>");
		tabstr.append("Database is not valid");
		tabstr.append("</td></tr>");
		tabstr.append("</table>");
		
		return tabstr.toString();
	}
	
	Connection connApp=getconn(conn,env_id);
	
	
	
	
	setCatalogForConnection(connApp, cat);
	
	
	PreparedStatement pstmt = null;
	ResultSet rset = null;
	ResultSetMetaData rsmd = null;
	
	try {
		pstmt = connApp.prepareStatement(editor_sql);
		
		try {pstmt.setFetchSize(1000);} catch(Exception e) {}

		try {pstmt.setQueryTimeout(120);} catch(Exception e) {}
		
		rset = pstmt.executeQuery();
		rsmd = rset.getMetaData();
		
		int colcount = rsmd.getColumnCount();
		tabstr.append("<table border=1 cellspacing=0 cellpadding=0>");
		
		tabstr.append("<tr bgcolor=#FFDDAA>");
		tabstr.append("<td>#</td>");
		for (int i=1;i<=colcount;i++) {
			String aval="";
			try{aval= rsmd.getColumnName(i);} catch(Exception e) {aval="<<!!ERROR!!>>";}
			tabstr.append("<td>" + aval + "</td>");
		}
		tabstr.append("</tr>");

		
		
		
		String bgcolor="";
		while (rset.next() && maxrec>recno) {
			recno++;
			bgcolor="#FAFAFA";
			if (recno % 2 ==0) bgcolor="#DCDCDC";
			tabstr.append("<tr bgcolor=" + bgcolor + ">");
			tabstr.append("<td>"+recno+"</td>");
			for (int i=1;i<=colcount;i++) {
				String aval="";
				try{aval= rset.getString(i);} catch(Exception e) {aval="Error on cell content : "+clearHtml(e.getMessage());}
				tabstr.append("<td>" + clearHtml(limitString(aval,200)) + "</td>");
			}
			tabstr.append("</tr>");
		}
		tabstr.append("</table>");

		
	} catch(Exception e) {
		e.printStackTrace();
		tabstr.append("<table border=1>");
		tabstr.append("<tr bgcolor=#FADABC><td>");
		tabstr.append("SQL Exception@printTableinNewWindow : "+e.getMessage());
		tabstr.append("<hr>while execution SQL : "+editor_sql);
		tabstr.append("</td></tr>");
		tabstr.append("</table>");
	}
	finally {
		closeconn(connApp);
	}

	closeconn(connApp);

	
	
	
	return tabstr.toString();
}

//************************************************
	ArrayList<String> getJbaseCommandRes(JConnection JBASEconn, String cmd) {
		ArrayList<String> ret1=new ArrayList<String>();
		
		if (JBASEconn==null)  return ret1;
		System.out.println(" ******************************** " );
		System.out.println(cmd);
		System.out.println(" ******************************** " );
		
		try {
			JStatement stmt=JBASEconn.createStatement();
			JResultSet res=stmt.execute(cmd);
			
			while(res.next()) {
				JDynArray row1=res.getRow();
				for (int i=1;i<=row1.getNumberOfAttributes();i++) {
					for (int j=1;j<=row1.getNumberOfValues(i);j++) {
						for (int t=1;t<=row1.getNumberOfSubValues(i,j);t++) {
							String a_val=row1.get(i, j, t);
							ret1.add(a_val);
						}
					}
				}
			}
			
		} 
		catch (JRemoteException e) {
			e.printStackTrace();

		}
		return ret1;
	}

//*************************************************************
String getJbaseFieldsWithComma(String table_name) {
	StringBuilder sb=new StringBuilder();
	ArrayList<String> fields=getJbaseFields(table_name);
	
	for (int i=0;i<fields.size();i++) {
		String fname=fields.get(i);
		if (fname.indexOf("*")==0) fname=fname.substring(1);
		if (i>0) sb.append(", ");
		sb.append(fname);
	}
	
	if (sb.length()==0) sb.append("1");
	return sb.toString();
}

//*************************************************************
ArrayList<String> getJbaseFields(String table_name) {
	ArrayList<String> ret1=new ArrayList<String>();
	
	JConnection JBASEconn=null;	
	String sql="select db_connstr, db_username, db_password from tdm_envs where db_driver='com.jbase.jdbc.driver.JBaseJDBCDriver'";
	
	ArrayList<String[]> jbaseparams=getDbArrayConf(getconn(), sql, 1, new ArrayList<String[]>());
	
	if (jbaseparams.size()==0) return ret1;
	
	String db_connstr=jbaseparams.get(0)[0];
	String db_username=jbaseparams.get(0)[1];
	String db_password=passwordDecoder(jbaseparams.get(0)[2]) ;
	
	String hostport="";
	
	try { hostport=db_connstr.split("\\@")[1].split("\\?")[0];} catch(Exception e) {hostport=db_connstr.split("\\@")[1];}
	String params="";
	try { params=db_connstr.split("\\@")[1].split("\\?")[1];} catch(Exception e) {params="";}
	String host="";
	try {host=hostport.split(":")[0];} catch(Exception e) {host="";}
	String port="";
	try {port=hostport.split(":")[1];} catch(Exception e) {port="";}
	
	
	
	DefaultJConnectionFactory dcf=new DefaultJConnectionFactory();
	
	dcf.setHost(host);
	dcf.setPort(Integer.parseInt(port));
	String cmd_for_pks_ext=nvl(getParamByName(getconn(), "JBASE_CMD_PKS")," WITH (F1 EQ \"D\" OR F1 EQ \"I\") AND F4 NE \"@ID\" AND F2 EQ \"0\" ONLY");
	String cmd_for_fields_ext=nvl(getParamByName(getconn(), "JBASE_CMD_FIELDS")," WITH (F1 EQ \"D\" OR F1 EQ \"I\") AND F2 NE \"0\" ONLY");

	try {
		JBASEconn=dcf.getConnection(db_username,db_password);
		String cmd_for_pks="LIST "+table_name + "]D "+cmd_for_pks_ext;

		ret1=getJbaseCommandRes(JBASEconn,cmd_for_pks);
		
		if (ret1.size()==0) ret1.add("RECID");
		
		for (int i=0;i<ret1.size();i++) 
				ret1.set(i,"*"+ret1.get(i));
		
		
		
		String cmd_for_fields="LIST "+table_name + "]D "+cmd_for_fields_ext;

		ArrayList<String> tmp=getJbaseCommandRes(JBASEconn,cmd_for_fields);
		
		for (int i=0;i<tmp.size();i++)  
			if (ret1.indexOf("*"+tmp.get(i))==-1)
			ret1.add(tmp.get(i));
		
		//replace . with _
		for (int i=0;i<ret1.size();i++) {
			if (ret1.get(i).indexOf(".")>-1)
				ret1.set(i,ret1.get(i).replaceAll("\\.", "_"));
		}
		
		
		return ret1;
		
	} catch (JRemoteException e) {
		e.printStackTrace();
	} finally {
		try {
			JBASEconn.close();
			System.out.println("Connection is closed");
		} catch(Exception e) {
			e.printStackTrace();
		} 
	}
	
	
	
	return ret1;
}




//*************************************************************
public ArrayList<String[]> getFieldList(Connection connconf, String app_type, String env_id, 
		String cat, String owner, String table, String db_type) {
//*************************************************************

	
	Connection connApp=getconn(connconf, env_id);
	String env_db_rowid="";
	String env_db_type=getEnvDBParam(connconf, env_id, "DB_TYPE");
	if (app_type.equals("MASK"))
		env_db_rowid=getEnvDBParam(connconf, env_id, "ROWID");
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	if (env_db_type.toUpperCase().contains("MONGO"))
		ret1=getFieldListFromMongoDB(connconf, env_id, owner, table);
	else 
		ret1=getFieldListFromApp(connApp, env_db_rowid, cat, owner,  table, env_db_type);

	try {connApp.close();connApp= null;} catch (Exception e) {}
	
	return ret1;

}


//*************************************************************
public String getEnvDBParam(Connection conn, String env_id, String param_name) {
//*************************************************************
	if (nvl(env_id,"0").equals("0")) return "";

	ArrayList<String[]> bindlist=new ArrayList<String[]>();

	
	String sql="";
	String fname="";
	String ret1="";
	
	
	
	if (param_name.equals("DB_TYPE")) fname="flexval1";
	if (param_name.equals("TEST_SQL")) fname="flexval2";
	if (param_name.equals("ROWID")) fname="flexval3";
	
	
	sql="select r." + fname + " from  tdm_envs e, tdm_ref r where e.id="+env_id+" and e.db_driver=r.ref_name"; 
	

	ArrayList<String[]> env=getDbArrayConf(conn, sql, 1, bindlist);
	

	try {
		ret1=env.get(0)[0].replaceAll("null", "");
	} catch(Exception e) {
		System.out.println("Error on loading db info (env_id="+env_id+",param_name="+param_name+"): MSG : "+e.getMessage());
	}

	return ret1;

}

//**************************************************************
public String codehtml(String a) {
//**************************************************************
//if (nvl(a,"").length()==0) return "";
if (a==null) return "";
return a.replaceAll("\"", "&quot;");
}


//**************************************************************
private String getParallelFunction(Connection connconf, String env_id, String catalog, String owner,String table , String db_type) {
//**************************************************************
	String ret1="";
	String table_name_to_test=owner+"."+table;
	if (owner.length()==0) 
		table_name_to_test=table;
	
	table_name_to_test=addStartEnd(connconf, env_id, table_name_to_test);
	
	
	String sql="NONE";
	
	Connection connApp=getconn(connconf, env_id);
	if (connApp==null) return "";
	
	setCatalogForConnection(connApp, catalog);
	
	
	//%
	sql="select * from " + table_name_to_test + " where 1 % 1=0";
	if (db_type.equals("MSSQL") || db_type.equals("SYBASE")) 
		sql="select top 100 * from " + table_name_to_test + "  where 1 % 1=0 ";
	if (db_type.equals("JBASE")) 
		sql="select "  + getJbaseFields(table_name_to_test) +  " from " + table_name_to_test + " where 1 % 1=0";
	if (validateSQLStatement(connApp,sql,new StringBuilder())) {
		if (connApp!=null) try {connApp.close();} catch(Exception e) {}
		return "%";
	}
	
	//MOD
	sql="select * from " + table_name_to_test + " where mod(1,1)=0";
	if (db_type.equals("MSSQL") || db_type.equals("SYBASE")) 
		sql="select top 100 * from " + table_name_to_test + " where mod(1,1)=0 ";
	if (db_type.equals("JBASE")) 
		sql="select "  + getJbaseFields(table_name_to_test) +  " from " + table_name_to_test + " where mod(1,1)=0";
	if (validateSQLStatement(connApp, sql,new StringBuilder())) {
		if (connApp!=null) try {connApp.close();} catch(Exception e) {}
		return "MOD";
	}

	closeconn(connApp);
	
	return ret1;
}


//**************************************************************
private String getPartitionFlag(Connection connconf, String env_id, String catalog, String owner, String table) {
//**************************************************************
	String ret1="NO";
	
	String sql="";
	String partition_sql="";

	
	sql="select flexval2 from  tdm_ref where ref_type='DB_TYPE' and ref_name=(select db_driver from tdm_envs where id="+env_id+")";
	System.out.println(sql);
	String template=getDBSingleVal(connconf, sql);
	
	if (template.contains("|")) 
		try {partition_sql=template.split("\\|")[2];} catch(Exception e) {partition_sql="";}
		
	if (partition_sql.length()>0) {
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		if (partition_sql.indexOf("?")>-1) {
			//bir tane mi 2 tane mi bind edelim?
			if (partition_sql.indexOf("?")!=partition_sql.lastIndexOf("?")) {
				bindlist.add(new String[]{"STRING",owner});
				bindlist.add(new String[]{"STRING",table});
			} else {
				bindlist.add(new String[]{"STRING",table});
			}
			
		}
		
		
		Connection connApp=getconn(connconf, env_id);
		setCatalogForConnection(connApp, catalog);
		ArrayList<String[]> recs=getDbArrayApp(connApp, partition_sql, 2, bindlist, false, "");
		closeconn(connApp);
		
		if (recs!=null && recs.size()>1) ret1="YES";
	}
	
	return ret1;
}

//*************************************************************
public int addNewTable(
		Connection conn, 
		String app_type, 
		String env_id, 
		String app_id,
		String tableActionObject, 
		String discovery_rel_id,
		String rel_type,
		String family_id
		) {
//*************************************************************
	String cat="";
	String owner="";
	String table="";
	int ret1=0;
	String tab_id="";
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String[] tabArr=tableActionObject.split(",");
	
	System.out.println("Environmen id :"+env_id);
	
	String env_db_type=nvl(getEnvDBParam(conn, env_id, "DB_TYPE"),"ORACLE");
	
	boolean is_mongo=false;
	
	if (env_db_type.toUpperCase().contains("MONGO")) is_mongo=true;
	
	String env_db_rowid=getEnvDBParam(conn, env_id, "ROWID");
	if (is_mongo)  env_db_rowid="";
	
	//copy tipinde application da PK olarak ROWID bulunmaz
	if (app_type.equals("COPY")) env_db_rowid="";
	
	
	
		for (int t=0;t<tabArr.length;t++) {
			String table_name=tabArr[t];
			tab_id="";
			System.out.println("Adding table :"+table_name);
						
				try  {
					 int tab_id_INT=Integer.parseInt(table_name);
					 tab_id=""+tab_id_INT;
					 sql="select cat_name, schema_name, tab_name from tdm_tabs where id="+tab_id;
					 ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>());
					 cat=arr.get(0)[0];
					 owner=arr.get(0)[1];
					 table=arr.get(0)[2];
				} catch(Exception e) {
					try {
						
						if (table_name.contains("*")) {
							cat=table_name.split("\\*")[0];
							owner=table_name.split("\\*")[1];
							table=table_name.split("\\*")[2];
						}
						else
						if (table_name.contains(".")) {
							cat=table_name.split("\\.")[0];
							owner=table_name.split("\\.")[1];
							table=table_name.split("\\.")[2];
						}
						
					} catch (Exception x) {
						return 0;
					}
				}	
				
				
				
	
			//JBASE case, null comes as SCHEMA name
			if (owner.equals("null")) owner="";	
			
			if (tab_id.length()==0) {
				System.out.println("...adding table header.");
				
				String parallel_function="";
				String partition_flag="";
				
				if (is_mongo) {
					parallel_function="$mod";
					partition_flag="NO";
				} else {
					parallel_function=getParallelFunction(conn, env_id, cat, owner, table, env_db_type);
					partition_flag=getPartitionFlag(conn, env_id, cat, owner, table);
					
					
				}
				
				sql="select max(tab_order) from tdm_tabs where app_id=?";
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",app_id});

				String tab_order="1";
				try {tab_order=""+(Integer.parseInt(getDbArrayConf(conn, sql, 1, bindlist).get(0)[0])+1);} catch(Exception e) {tab_order="1";}
				
				
				
				sql="insert into tdm_tabs (app_id, db_type, cat_name, schema_name, tab_name, mask_level, parallel_function, "+
						" parallel_field, parallel_mod, partition_flag, family_id, tab_order) "+
						" values "+
						" (?,?,?,?,?,'FIELD',?, '1',1,?, ?, ?)";
				
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",app_id});
				bindlist.add(new String[]{"STRING",env_db_type});
				bindlist.add(new String[]{"STRING",cat});
				bindlist.add(new String[]{"STRING",owner});
				bindlist.add(new String[]{"STRING",table});
				bindlist.add(new String[]{"STRING",parallel_function});
				bindlist.add(new String[]{"STRING",partition_flag});
				bindlist.add(new String[]{"INTEGER",family_id});
				bindlist.add(new String[]{"INTEGER",tab_order});
				

				execDBConf(conn, sql, bindlist);
				
				tab_id=getDBSingleVal(conn, "select max(id) from tdm_tabs where app_id="+app_id);
				
				System.out.println("added table id : "+tab_id+" to app "+app_id);
				
	
			} //if (tab_id.length()==0)
	
			
			
			ArrayList<String[]> fields=new ArrayList<String[]>();
			if (is_mongo)
				fields=getFieldListFromMongoDB(conn, env_id, owner, table );
			else 
				fields=getFieldList(conn, app_type, env_id, cat, owner, table, env_db_type);
			
			
			
			String a_field_name="";
			String a_field_type="";
			String a_field_size="";
			String a_field_is_pk="";
	
			
			for (int i=0;i<fields.size();i++) {
				
				String[] arr=fields.get(i);
				a_field_name=arr[0];
				a_field_type=arr[1];
				a_field_size=arr[2];
				a_field_is_pk=arr[3];
				
				
				
				//System.out.println("...checking if field exists : "+a_field_name);
				String field_id=getDBSingleVal(conn, "select id from tdm_fields where tab_id="+tab_id+ " and field_name='"+a_field_name+"'");
				
				if (field_id.length()==0) {
					//System.out.println("...not found. inserting field :"+a_field_name);
					sql="insert into tdm_fields (tab_id,field_name, field_type, field_size, is_pk, mask_prof_id, calc_prof_id) values(?,?,?,?,?,0,0)";
					bindlist=new ArrayList<String[]>();
					bindlist.add(new String[]{"INTEGER",tab_id});
					bindlist.add(new String[]{"STRING",a_field_name});
					bindlist.add(new String[]{"STRING",a_field_type});
					bindlist.add(new String[]{"INTEGER",a_field_size});
					bindlist.add(new String[]{"STRING",a_field_is_pk});
					execDBConf(conn, sql, bindlist);
				} //if (field_id.length()==0)
			} 		
		} //for (int t=0;t<tabArr.length;t++)
			
	System.out.println("OK. Added.");
		
	//add table relation 
	if (!discovery_rel_id.equals("0")) {
		
		boolean from_discovery=false;
		String source_tab_name="";
		String curr_rel_type="";
		String rel_on_fields="";
		String parent_tab_id="";
		
		
		try{int a=Integer.parseInt(discovery_rel_id); from_discovery=true;} catch(Exception e) {}
		
		if (from_discovery) {
			
			sql="select source_tab_name, rel_type, rel_on_fields from tdm_discovery_rel where id="+discovery_rel_id;
			ArrayList<String[]> discArr=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>());
			
			
			source_tab_name=discArr.get(0)[0];
			curr_rel_type=discArr.get(0)[1];
			rel_on_fields=discArr.get(0)[2];
			
			
			
			sql="select id from tdm_tabs where app_id="+app_id+" and concat(schema_name,'.',tab_name)='"+source_tab_name+"'";
			discArr=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>());
			//parent tablosu silinmis olabilir. bu durumda relation kurma
			try {
				parent_tab_id=discArr.get(0)[0];
			} catch(Exception e) {
				parent_tab_id="0";
			}
			
			
		} //if (from_discovery)
		else {
			parent_tab_id=discovery_rel_id.split(":")[0];
			rel_on_fields=discovery_rel_id.split(":")[1];
		}
		
		
		
		
		if (!parent_tab_id.equals("0")) {
			
			sql="select field_name from tdm_fields where tab_id="+parent_tab_id+" and is_pk='YES' order by id";
			ArrayList<String[]> pkArr=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>());
			String pk_fields="";
			for (int p=0;p<pkArr.size();p++) {
				if (pk_fields.length()>0) pk_fields=pk_fields+",";
				pk_fields=pk_fields+pkArr.get(p)[0];
			}
			
			
			
			sql="insert into tdm_tabs_rel (tab_id, rel_tab_id, rel_type, pk_fields, rel_on_fields, rel_order) "+
					" values (" +
						parent_tab_id+", "+
						tab_id+", "+
						"'"+rel_type+"',"+
						"'"+pk_fields+"',"+
						"'"+rel_on_fields+"',"+
						"'999'"+
					")";
			execDBConf(conn, sql, new ArrayList<String[]>());
			
			System.out.println("OK. Relation added.");
		}
		
	} //if (!discovery_rel_id.equals("0"))
			
	
	try {return Integer.parseInt(tab_id);} catch(Exception e) {return 0;}
	 
	

	
}


//**************************************************************
ArrayList<String> getTabListToRemove(Connection conn, String tab_id) {
	ArrayList<String> ret1=new ArrayList<String>();
	ret1.add(tab_id);
	
	String sql="select rel_tab_id from tdm_tabs_rel where tab_id="+tab_id;
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, new ArrayList<String[]>());
	
	ArrayList<String> subtabs=new ArrayList<String>();
	
	for (int i=0;i<arr.size();i++) {
		subtabs=getTabListToRemove(conn, arr.get(i)[0]);
		for (int s=0;s<subtabs.size();s++) ret1.add(subtabs.get(s));
	}
	
	
	
	return ret1;
}
//**************************************************************


//*************************************************************
public void removeTable(Connection conn, String tab_id) {
//*************************************************************
ArrayList<String[]> bindlist=new ArrayList<String[]>();

ArrayList<String> tabstodelete=getTabListToRemove(conn,tab_id);

for (int i=tabstodelete.size()-1;i>=0;i--) {

	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",tabstodelete.get(i)});

	String sql="delete from tdm_fields where tab_id=?";
	execDBConf(conn, sql, bindlist);

	sql="delete from tdm_tabs where id=?";
	execDBConf(conn, sql, bindlist);

	sql="delete from tdm_tabs_rel where tab_id=?";
	execDBConf(conn, sql, bindlist);

	sql="delete from tdm_tabs_rel where rel_tab_id=?";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from tdm_copy_filter where tab_id=?";
	execDBConf(conn, sql, bindlist);
	
}


}


//*************************************************************
public void removeScript(Connection conn, String script_id) {
//*************************************************************
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",script_id});

	String sql="delete from tdm_auto_scripts where id=?";
	execDBConf(conn, sql, bindlist);

}


//*************************************************************
public void reorderScript(Connection conn, String app_id, String stage , String script_id, String direction) {
//*************************************************************
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();

	
	String sql="select id from tdm_copy_script where app_id=? and stage=? order by script_order";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"STRING",stage});

	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	for (int i=0;i<arr.size();i++) {
		String id=arr.get(i)[0];

		
		if (script_id.equals(id)) {
			
			int swap_id=0;
			

			if (direction.equals("UP")) 
				swap_id=i-1;
			else  
				swap_id=i+1;
			
			String tmp_id=arr.get(swap_id)[0];

			
			arr.set(swap_id, new String[]{id});
			arr.set(i, new String[]{tmp_id});
			
			break;
			
		}
		
		
	} //for 
	
	sql="update tdm_copy_script set script_order=? where id=?";
			
	for (int i=0;i<arr.size();i++) {
		String id=arr.get(i)[0];

		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+i});
		bindlist.add(new String[]{"INTEGER",id});
		
		execDBConf(conn, sql, bindlist);
	}

	

}


//*************************************************************
public void addMissingFields(Connection conn, String v_env_id, String tab_id,String fields_to_add) {
//*************************************************************

String[] arr=null;

try{
	arr=fields_to_add.split("\\|");
} catch(Exception e) {e.printStackTrace(); return;}


String sql="insert into tdm_fields (tab_id,field_name,field_type,field_size,mask_prof_id,is_pk) values(?,?,?,?,0,'NO')";
for (int i=0;i<arr.length;i++) {
	String a_field_name="";
	String a_field_type="";
	String a_field_size="";
	
	try{a_field_name=arr[i].split(":")[0];} catch(Exception e) {e.printStackTrace(); a_field_name="";}
	try{a_field_type=arr[i].split(":")[1];} catch(Exception e) {e.printStackTrace(); a_field_name="";}
	try{a_field_size=arr[i].split(":")[2];} catch(Exception e) {e.printStackTrace(); a_field_name="";}
	
	if (a_field_name.length()>0) {
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",tab_id});
		bindlist.add(new String[]{"STRING",a_field_name});
		bindlist.add(new String[]{"STRING",a_field_type});
		bindlist.add(new String[]{"INTEGER",a_field_size});
		execDBConf(conn, sql, bindlist);
		
	}
}


}



//*************************************************************
public void deleteField(Connection conn, String v_env_id, String tab_id,String field_to_delete) {
//*************************************************************
String sql="delete from  tdm_fields where tab_id=? and field_name=?";	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",tab_id});
	bindlist.add(new String[]{"STRING",field_to_delete});
	execDBConf(conn, sql, bindlist);
}

//*************************************************************
public ArrayList<String[]> getDbArrayConf(Connection connConf, String sql, int limit,ArrayList<String[]> bindlist) {
//*************************************************************
	return  getDbArrayConf(connConf, sql, limit, bindlist,9999);
	}
//*************************************************************

public ArrayList<String[]> getDbArrayConf(Connection connConf, String sql, int limit,ArrayList<String[]> bindlist, int timeout_insecond) {
	return getDbArrayConf(connConf,sql,limit, bindlist,timeout_insecond,null);
}
//*************************************************************
	public ArrayList<String[]> getDbArrayConf(Connection connConf, String sql, int limit,ArrayList<String[]> bindlist, int timeout_insecond, ArrayList<String> columnList) {
//*************************************************************
		ArrayList<String[]> ret1 = new ArrayList<String[]>();

		PreparedStatement pstmtConf = null;
		ResultSet rsetConf = null;
		ResultSetMetaData rsmdConf = null;


		int reccnt = 0;
		try {
			if (pstmtConf == null) 	pstmtConf = connConf.prepareStatement(sql);
			
			//------------------------------ end binding

			if (bindlist!=null) {
				for (int i = 1; i <= bindlist.size(); i++) {
					String[] a_bind = bindlist.get(i - 1);
					String bind_type = a_bind[0];
					String bind_val = a_bind[1];
	
					if (bind_type.equals("INTEGER")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtConf.setInt(i, Integer.parseInt(bind_val));
					} else if (bind_type.equals("LONG")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtConf.setLong(i, Long.parseLong(bind_val));
					} else if (bind_type.equals("DOUBLE")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.DOUBLE);
						else
							pstmtConf.setDouble(i, Double.parseDouble(bind_val));
					} else if (bind_type.equals("FLOAT")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtConf.setNull(i, java.sql.Types.FLOAT);
						else
							pstmtConf.setFloat(i, Float.parseFloat(bind_val));
					} 
					else {
						pstmtConf.setString(i, bind_val);
					}
				}
				//------------------------------ end binding
			}  // if bindlist 
			
			pstmtConf.setQueryTimeout(timeout_insecond);
			
			if (rsetConf == null) rsetConf = pstmtConf.executeQuery();
			if (rsmdConf == null) rsmdConf = rsetConf.getMetaData();

			int colcount = rsmdConf.getColumnCount();
			
			if (columnList!=null) {
				columnList.clear();
				for (int i=1;i<=colcount;i++) {
					columnList.add(rsmdConf.getColumnName(i));
				}
			}
			
			
			String a_field = "";
			while (rsetConf.next()) {
				reccnt++;
				if (reccnt > limit) break;
				String[] row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {
					try {
						a_field = rsetConf.getString(i);
						if (a_field.equals("null")) a_field=""; 
						} 
					catch (Exception enull) {a_field = "";}
					row[i - 1] = a_field;
				}
				ret1.add(row);
			}
		} catch (Exception ignore) {
			ignore.printStackTrace();
			System.out.println("Exception@getDbArrayConf : " + sql);
		} finally {
			try {rsmdConf = null;} catch (Exception e) {}
			try {rsetConf.close();rsetConf = null;} catch (Exception e) {}
			try {pstmtConf.close();	pstmtConf = null;} catch (Exception e) {}
		}
		return ret1;
	}
	
	
//*************************************************************
public ArrayList<String[]> getDbArrayApp(Connection connconf,String env_id, String sql, int limit,ArrayList<String[]> bindlist) {

	return getDbArrayApp(connconf, env_id, sql, limit, bindlist, false, "");
}

String last_db_sql_error="";

//*************************************************************
public ArrayList<String[]> getDbArrayApp(Connection connconf,String env_id, String sql, int limit, ArrayList<String[]> bindlist, boolean include_columns, String current_schema) {
//*************************************************************
	
	String decoded_current_catalog="";
	String decoded_current_schema=current_schema;
	
	if (current_schema.contains(".")) {
		decoded_current_catalog=current_schema.split("\\.")[0];
		try{decoded_current_schema=current_schema.split("\\.")[1];} catch(Exception e) {decoded_current_schema="";}
	}
	
	Connection connApp=getconn(connconf,env_id);
	
	if (decoded_current_catalog.length()>0)
		setCatalogForConnection(connApp, decoded_current_catalog);
		
	ArrayList<String[]> ret1 = getDbArrayApp(connApp, sql, limit, bindlist, include_columns, decoded_current_schema);
	return ret1;
	
	}

//*************************************************************
public ArrayList<String[]> getDbArrayApp(Connection connApp, String sql, int limit,ArrayList<String[]> bindlist, boolean include_columns, String current_schema) {
//*************************************************************
		ArrayList<String[]> ret1 = new ArrayList<String[]>();
		
		last_db_sql_error="";

		PreparedStatement pstmtApp = null;
		ResultSet rsetApp = null;
		ResultSetMetaData rsmdApp = null;

		int reccnt = 0;
		try {
			
			if (current_schema.length()>0) {
				String set_current_schema_sql="ALTER SESSION SET CURRENT_SCHEMA="+current_schema;
				Statement schstmt=null;
				try {
					schstmt=connApp.createStatement();
					boolean is_changed=schstmt.execute(set_current_schema_sql);
					if (is_changed) System.out.println("Schema is changed to "+current_schema);
				} catch(Exception e) {
					e.printStackTrace();
				} finally {
					try {schstmt.close();} catch(Exception e) {}
				}
				
			}
			
			if (pstmtApp == null) 	pstmtApp = connApp.prepareStatement(sql);
			
			//------------------------------ end binding

			if (bindlist!=null) {
				for (int i = 1; i <= bindlist.size(); i++) {
					String[] a_bind = bindlist.get(i - 1);
					String bind_type = a_bind[0];
					String bind_val = a_bind[1];
	
					if (bind_type.equals("INTEGER")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtApp.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtApp.setInt(i, Integer.parseInt(bind_val));
					} else if (bind_type.equals("LONG")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtApp.setNull(i, java.sql.Types.INTEGER);
						else
							pstmtApp.setLong(i, Long.parseLong(bind_val));
					} else if (bind_type.equals("ROWID")) {
							ROWID r = new ROWID();
							r.setBytes(bind_val.getBytes());
							pstmtApp.setRowId(i, r);
					} else if (bind_type.equals("DATE") || bind_type.equals("DATETIME") || bind_type.equals("TIMESTAMP")) {
						if (bind_val == null || bind_val.equals(""))
							pstmtApp.setNull(i, java.sql.Types.DATE);
						else
						{
							Date b=new Date();
							try {
								SimpleDateFormat df=new SimpleDateFormat(DEFAULT_DATE_FORMAT);
								b=df.parse(bind_val);
							} catch(Exception e) {};
							java.sql.Date sqld=new java.sql.Date(b.getTime());
							//pstmtConf.setDate(i, sqld);
							Timestamp t=new Timestamp(b.getTime());
							pstmtApp.setTimestamp(i, t);
						}
							
					} else {
						pstmtApp.setString(i, bind_val);
					}
				}
				//------------------------------ end binding
			}  // if bindlist 
			
			if (rsetApp == null) rsetApp = pstmtApp.executeQuery();
			if (rsmdApp == null) rsmdApp = rsetApp.getMetaData();

			int colcount = rsmdApp.getColumnCount();
			
			if (include_columns) {
				String[] field_name_row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {
					field_name_row[i-1]=rsmdApp.getColumnLabel(i);
				}
				ret1.add(field_name_row);
			}
			
			String a_field = "";
			while (rsetApp.next()) {
				reccnt++;
				if (reccnt > limit) break;
				String[] row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {
					try {
						if ("DATE,TIMESTAMP,DATETIME".indexOf(rsmdApp.getColumnTypeName(i).toUpperCase()) > -1) {
							Date d = rsetApp.getDate(i);
							if (d == null)	a_field = "";
							else a_field = new SimpleDateFormat(DEFAULT_DATE_FORMAT).format(d);
						} else
							a_field = rsetApp.getString(i);
							if (a_field.equals("null")) {
								if (rsetApp.wasNull()) a_field="";
							}
						} 
					catch (Exception enull) {a_field = "";}
					row[i - 1] = a_field;
				}
				ret1.add(row);
			}
		} catch (Exception ignore) {
			last_db_sql_error=ignore.getMessage();
			ignore.printStackTrace();
			System.out.println("Exception@getDbArrayApp : " + sql);
		} finally {
			try {rsmdApp = null;} catch (Exception e) {}
			try {rsetApp.close();rsetApp = null;} catch (Exception e) {}
			try {pstmtApp.close();pstmtApp = null;} catch (Exception e) {}
		}
		return ret1;
	}
//*************************************************************
	public boolean execDBConf(Connection conn, String sql,	ArrayList<String[]> bindlist) {
		boolean ret1 = true;
		PreparedStatement pstmt_execbind=null;

		StringBuilder using = new StringBuilder();
		try {
			pstmt_execbind = conn.prepareStatement(sql);

			for (int i = 1; i <= bindlist.size(); i++) {
				String[] a_bind = bindlist.get(i - 1);
				String bind_type = a_bind[0];
				String bind_val = a_bind[1];
				if (i > 1)
					using.append(", ");
				using.append("{" + bind_val + "}");

				if (bind_type.equals("INTEGER")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.INTEGER);
					else
						pstmt_execbind.setInt(i, Integer.parseInt(bind_val));
				} else if (bind_type.equals("LONG")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.INTEGER);
					else
						pstmt_execbind.setLong(i, Long.parseLong(bind_val));
				} else if (bind_type.equals("DATE")) {
					if (bind_val == null || bind_val.equals(""))
						pstmt_execbind.setNull(i, java.sql.Types.DATE);
					else {
						java.util.Date d = new SimpleDateFormat("dd/MM/yyyy").parse(bind_val);
						java.sql.Date date = new java.sql.Date(d.getTime());
						pstmt_execbind.setDate(i, date);
					}
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
				pstmt_execbind.close();
				pstmt_execbind = null;
			} catch (Exception e) {
			}
		}

		return ret1;
	}
	

	// *******************************
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


//**************************************************************
public String makeComboArr(ArrayList<String[]> arr, String name, String additional, String curr_value, int width) {
//**************************************************************
//String a="<div>";

String v_width="100%";
if (width>0) v_width=""+width+"px"; 
if (width<0) v_width=""+Math.abs(width)+"%";

String a="<select style=\"width:"+v_width+"; \" class=\"form-control\" #SIZE# name=\""+name+"\" "+additional+">";
	
	if (additional.toLowerCase().contains("size=")) 
		a=a.replace("#SIZE#", "");
	else {		
		a=a.replace("#SIZE#", "size=1");
		a=a+"<option></option>";
	}
	
	String selected="";
	
	if (arr!=null)
	for (int i=0;i<arr.size();i++) {
		String[] opt=arr.get(i);
		String val="";
		String cap="";
		
		val=opt[0];
		
		try{cap=opt[1];} catch(Exception e) {cap=val;}
		
		selected="";
		if (val.equals(curr_value)) selected="selected";
		
		a=a+"<option "+selected+" value=\""+codehtml(val)+"\">" +clearHtml(cap)+ "</option>";	
	}
	
	
	a=a+"</select>";
	
	return a;
}

//**************************************************************
public String makeCombo(Connection connconf, String sql, String name, String additional, String curr_value, int width) {
//**************************************************************
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> arr=getDbArrayConf(connconf, sql, Integer.MAX_VALUE, bindlist);
	
	return makeComboArr(arr, name, additional, curr_value, width);
}

//**************************************************************
public String makeComboArray(Connection connconf, String sql, String name) {
//**************************************************************
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> arr=getDbArrayConf(connconf, sql, Integer.MAX_VALUE, bindlist);
	
	String ret1="var " + name + "=new Array(ARRAYLIST);";
	String arritems="\"\"";
	
	

	
	for (int i=0;i<arr.size();i++) {
		String[] opt=arr.get(i);
		arritems=arritems + ",\"" + opt[0] +"::" +  opt[1] + "\"";
	}
	
	ret1=ret1.replaceAll("ARRAYLIST", arritems);
	
	
	return ret1;
	
	
}


//**************************************************************
public String makeMemo(Connection conn, String sql, String name, String cols, String rows ) {
//**************************************************************
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);

    String a = "<div class=\"input-group\">";

	a+="<textarea style=\"width:700px\" name=\""+name+"\" cols=\""+cols+"\" rows=\""+rows+"\" class=\"form-control\">";
	
	for (int i=0;i<arr.size();i++) {
		String[] opt=arr.get(i);
		a=a+opt[0]+"\n";	
	}
	
	a=a+"</textarea></div>";
	
	
	return a;
	
	
}


//**************************************************************
public String getDBSingleVal(Connection connconf, String sql) {
//**************************************************************
String ret1="";
ArrayList<String[]> bindlist=new ArrayList<String[]>();
try {
	ret1=getDbArrayConf(connconf, sql, 1, bindlist).get(0)[0];
} catch(Exception e) {ret1="";}

return ret1;
}

//----------------------------------------------------------------------
public String formatnum(String num) {
	
	long l=0;
	
	try{l=Long.parseLong(num);} catch(Exception e) {l=0;}
	String t=""+l;
	String ret1="";
	int z=0;
	
	for (int i=t.length()-1;i>=0;i--) {
			ret1=""+t.charAt(i)+ret1;
			if (z>0 && i>0 && (z+1) %3==0) ret1=","+ret1;
			z++;
	}
	
	
	return ret1;
}


//----------------------------------------------------------------------
public String progressbar(String ax, String bx) {
	
long a=0;
long b=0;

try{a=Long.parseLong(ax);} catch(Exception e) {a=0;}

try{b=Long.parseLong(bx);} catch(Exception e) {b=0;}

double d=0;

if (b>0) d=100*a/b; else d=0;

if (d>100) d=100;

int carpan=1;
int completed=(int) d*carpan;
int not_completed=(100-(int) d)*carpan;

String alt_text=nvl(formatnum(ax),"0") + " / " + formatnum(bx);

String progressbar=	"" + 
"<img src=\"img/prog_completed.png\" border=0 height=14 width=\"" +  completed + "\" alt=\"" + alt_text + "\">" + 
"<img src=\"img/prog_not_completed.png\" border=0 height=14 width=\"" +  not_completed + "\" alt=\"" + alt_text + "\">" + 
" [<font color=red><b>" + d + "%</b></font>]" + 
"<br><center><font size=2>(" + alt_text + ")</font><center>";

if (b==0) progressbar="-";

return progressbar;

}


//********************************************
private void setBinInfo(Connection conn, String table_name, int id, String field_name, StringBuilder sb_info) {
	
	if (sb_info.length()==0) return;
	
	byte[] compressed=compress(sb_info.toString());
	
	String sql="update "+table_name+" set "+field_name+" =? where id=?";
	PreparedStatement stmt=null;
	try {
		stmt = conn.prepareStatement(sql);
		stmt.setBytes(1, compressed);
		stmt.setInt(2, id);
		stmt.executeUpdate();
	}  catch (Exception e) {
		e.printStackTrace();
	} finally {
		try {stmt.close();stmt = null;} catch (Exception e) {	}
	}
}

//********************************************
void setBinInfo(Connection conn, String table_name, int id, String field_name, byte[] byte_info) {
	
	if (byte_info==null || byte_info.length==0) return;
	
	byte[] compressed=compress(byte_info);
	
	String sql="update "+table_name+" set "+field_name+" =? where id=?";
	PreparedStatement stmt=null;
	try {
		stmt = conn.prepareStatement(sql);
		stmt.setBytes(1, compressed);
		stmt.setInt(2, id);
		stmt.executeUpdate();
	}  catch (Exception e) {
		e.printStackTrace();
	} finally {
		try {stmt.close();stmt = null;} catch (Exception e) {	}
	}
}

//***********************************************
public byte[] getInfoBin(Connection conn, String table_name, int id,String fldname) {
//******************************************************

	byte[] ret1=null;
	String sql="select "+fldname+" from " +table_name+  " where id=?";
	
	PreparedStatement pstmt = null;
	ResultSet rset = null;
	
	if (conn==null) conn=getconn();
	
	if (conn!=null)
	{
		try {
			
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, id);
			
			rset = pstmt.executeQuery();
			
			while (rset.next()) {
				try {
				ret1=rset.getBytes(1); 
				
				} catch(Exception e) {ret1=null;}
				break;
			}
			
		} catch (Exception ignore) {
			ignore.printStackTrace();
			ret1=null;
		} finally {
			try {rset.close();rset = null;} catch (Exception e) {}
			try {pstmt.close();	pstmt = null;} catch (Exception e) {}
		}
	} //if (conn!=null)
	
	return ret1;
}


//*************************************************
public static byte[] compress(String data){
	byte[] input;
	try {
		input = data.getBytes();
	} catch (Exception e) {
		e.printStackTrace();
		return null;
	}
    Deflater df = new Deflater();
    df.setLevel(Deflater.BEST_COMPRESSION);
    df.setInput(input);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(input.length);
    df.finish();
    byte[] buff = new byte[1024];
    while (!df.finished()) {
        int count = df.deflate(buff);
        baos.write(buff, 0, count);
    }
    try {
		baos.close();
	} catch (IOException e) {
		e.printStackTrace();
	}
    byte[] output = baos.toByteArray();

    return output;
}


//*************************************************
public static byte[] compress(byte[] input){
	
    Deflater df = new Deflater();
    df.setLevel(Deflater.BEST_COMPRESSION);
    df.setInput(input);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(input.length);
    df.finish();
    byte[] buff = new byte[1024];
    while (!df.finished()) {
        int count = df.deflate(buff);
        baos.write(buff, 0, count);
    }
    try {
		baos.close();
	} catch (IOException e) {
		e.printStackTrace();
	}
    byte[] output = baos.toByteArray();

    return output;
}


//******************************************************
public static String uncompress(byte[] input)  {
//******************************************************
  Inflater ifl = new Inflater();
  ifl.setInput(input);

  ByteArrayOutputStream baos = new ByteArrayOutputStream(input.length);
  
  byte[] buff = new byte[1024];
  while (!ifl.finished()) {
      int count;
		try {
			count = ifl.inflate(buff);
		} catch (DataFormatException e) {
			return "ERROR";
		}
      baos.write(buff, 0, count); 
  }
 
  byte[] output = baos.toByteArray();
  try {baos.close();} catch (IOException e){}
 
  
  try {
  return new String(output,"UTF-8");
  
  } 	
  catch(Exception e) 
  	{
	  return "ERROR";
	  }
}



//******************************************************
byte[]  uncompresstobyte(byte[] input)  {
//******************************************************
if (input==null) return null;
Inflater ifl = new Inflater();
ifl.setInput(input);

ByteArrayOutputStream baos = new ByteArrayOutputStream(input.length);

byte[] buff = new byte[1024];
while (!ifl.finished()) {
    int count;
		try {
			count = ifl.inflate(buff);
		} catch (DataFormatException e) {
			return null;
		}
    baos.write(buff, 0, count); 
}

byte[] output = baos.toByteArray();
try {baos.close();} catch (IOException e){}


return output;
}
//**************************************************************
public String printMonitoringDetails(Connection connconf, String work_plan_id,String tab_name, String status, String only_failed, String a_filter) {
//**************************************************************
String sql="";

sql="select wplan_type from tdm_work_plan where id="+work_plan_id;
String wp_type=getDBSingleVal(connconf, sql);

StringBuilder html=new StringBuilder();
if (tab_name.toUpperCase().equals("TDM_WORK_PACKAGE")) {
	sql="select id, wp_name, status, " + 
		" start_date, end_date, duration, all_count, export_count, " + 
		" done_count, success_count, fail_count  "+
		" from tdm_work_package where status=? and work_plan_id=?";
	
	if (!wp_type.equals("AUTO") && !nvl(a_filter,"-").equals("-") && !nvl(a_filter,"-").equals("ALL")) sql = sql + " and tab_id=" + a_filter;
		sql=sql + " order by id ";
	
	html.append(""+
			"<table class=table>"+
			"<tr>"+
			"<td>#</td>"+
			"<td>Wpack Name</td>"+
			"<td>Status</td>"+
			"<td>Start Time</td>"+
			"<td>End Time</td>"+
			"<td>Duration</td>"+
			"<td>Export#</td>"+
			"<td>Progress</td>"+
			"<td>Fail#</td>"+
			"<td>Err.</td>"+
			"</tr>");
} 

if (tab_name.toUpperCase().contains("TDM_TASK")) {
	sql="select id, task_name, status, " + 
			" start_date, end_date, duration,  " + 
			" all_count, done_count, success_count, fail_count, retry_count  "+
			" from tdm_task_"+work_plan_id+"_xxWPACKIDxx  ";
	
	if (nvl(status,"ALL").equals("ALL"))  sql = sql + " where status!=? ";
	else sql = sql + " where status=? ";
	
	if (nvl(only_failed,"-").equals("YES")) 
		sql=sql + " and fail_count>0 ";
	
	if (wp_type.equals("AUTO") && !nvl(a_filter,"-").equals("-") && !nvl(a_filter,"-").equals("ALL"))  
		sql=sql + " and script_id="+a_filter;
	
	sql=sql + " order by id ";
	
	
		html.append(""+
				"<table  class=\"table table-condensed\">"+
				"<tr class=active>"+
				"<td>Task# / Retry#</td>"+
				"<td>Task Name</td>"+
				"<td>Task<br>Status</td>"+
				"<td>Start/End Time</td>"+
				"<td>Duration</td>");
		if (wp_type.equals("AUTO"))
			html.append("<td>Test<br>Status</td>"+
					"<td>Script</td>"+
					"<td>Log.</td>");
		else
			html.append("<td>All#</td>"+
				"<td>Success#</td>"+
				"<td>Fail#</td>"+
				"<td>Task<br>Content</td>"+
				"<td>Log.</td>");
		
		if (wp_type.equals("AUTO")) 
			html.append("<td>Report</td>");
		else 
			html.append("<td>Error</td>");
		html.append("</tr>");
}

	


ArrayList<String[]> bindlist=new ArrayList<String[]>();
bindlist.add(new String[]{"STRING",status});
if (tab_name.toUpperCase().equals("TDM_WORK_PACKAGE")) 
	bindlist.add(new String[]{"INTEGER",work_plan_id});


	
	
					
	if (tab_name.toUpperCase().equals("TDM_WORK_PACKAGE")) {
		ArrayList<String[]> recs=getDbArrayConf(connconf, sql, 100, bindlist);	

		for (int i=0;i<recs.size();i++) {
			String[] arec=recs.get(i);
			String wpc_status=arec[2];
			html.append(""+
					"<tr>"+
					"<td>"+arec[0]+"</td>"+ //id
					"<td>"+arec[1]+"</td>"+ //wp name
					"<td>"+wpc_status+"</td>"+ // status
					"<td>"+arec[3]+"</td>"+ //start
					"<td>"+arec[4]+"</td>"+ //end
					"<td>"+formatnum(arec[5])+"</td>"+ //duration
					"<td>"+arec[7]+"</td>"+ //exp progress
					"<td>"+progressbar(arec[9],arec[7])+"</td>"+ //done progress
					"<td>"+formatnum(arec[10])+"</td>");//fail
					
					
					if (wpc_status.equals("FAILED") || Integer.parseInt(nvl(arec[10],"0"))>0) 
						html.append("<td><a href=\"#\" onclick=\"showInfoDetail('"+arec[0]+"','tdm_work_package','err_info');\">Show Err.</a></td>");
					else 
						html.append("<td>-</td>");
					
					
					html.append("</tr>");
		} //for (int i=0;i<recs.size();i++) {
	}  //if (tab_name.equals("TDM_WORK_PACKAGE")) {
	
		
		
		
	if (tab_name.toUpperCase().contains("TDM_TASK")) {
		int task_count=0;
		int MAX_TASK_SHOW=100;
		
		
		String wpc_filter=a_filter;
		if (wp_type.equals("AUTO")) {
			MAX_TASK_SHOW=Integer.MAX_VALUE;
			wpc_filter="ALL";
		}
		ArrayList<String[]> currWpcArr=getWpcListByWorkPlan(connconf, work_plan_id,wpc_filter);
		
		String env_id=getDBSingleVal(connconf, "select env_id from tdm_work_plan where id="+work_plan_id);
		
		for (int w=0;w<currWpcArr.size();w++) {
			
			if (task_count>MAX_TASK_SHOW) break;
		
			String work_package_id=currWpcArr.get(w)[0];
			
			ArrayList<String[]> recs=getDbArrayConf(connconf, sql.replaceAll("xxWPACKIDxx", work_package_id), 100, bindlist);	
			for (int i=0;i<recs.size();i++) {
				task_count++;
				if (task_count>100) break;
				String[] arec=recs.get(i);
				String task_status=arec[2];
			
				
					html.append(""+
							"<tr>"+
							"<td>"+arec[0]+" / "+arec[10]+" @Wpc "+work_package_id+"</td>"+ //id
							"<td>"+arec[1]+"</td>"+ // status
							"<td>"+task_status+"</td>"+ // status
							"<td nowrap>"+arec[3]+"<br>"+arec[4]+"</td>"+ //start end
							"<td>"+formatnum(arec[5])+"</td>" //duration
							); 
							if (wp_type.equals("AUTO")) {
								if (arec[8].equals("1")) html.append("<td class=success>SUCCESS</td>");
								else html.append("<td class=danger>FAIL</td>");
							} else {
								html.append("<td>"+formatnum(arec[6])+"</td>"+ //export
										"<td>"+formatnum(arec[8])+"</td>"+ //success
										"<td>"+formatnum(arec[9])+"</td>"); //fail
							}
							
							html.append(
							"<td><input type=button value=\"...\" onclick=\"showInfoDetail('"+arec[0]+"','tdm_task_"+work_plan_id+"_"+work_package_id+"','task_info_zipped','"+env_id+"');\" class=\"btn btn-warning btn-sm\"></td>"+
							"<td><input type=button value=\"...\"         onclick=\"showInfoDetail('"+arec[0]+"','tdm_task_"+work_plan_id+"_"+work_package_id+"','log_info_zipped','"+env_id+"');\" class=\"btn btn-info btn-sm\"></td>"
							);
				
						if (wp_type.equals("AUTO")) {
							if (Integer.parseInt(nvl(arec[8],"0"))>0) {
								sql="select max(id) from tdm_test_run where work_package_id=? and task_id=?";
								bindlist.clear();
								bindlist.add(new String[]{"INTEGER",""+work_package_id});
								bindlist.add(new String[]{"INTEGER",""+arec[0]});
								ArrayList<String[]> arr=getDbArrayConf(connconf, sql, 1, bindlist);
								
								String test_run_id="";
								if (arr.size()>0) test_run_id=arr.get(0)[0];
								
								if (!nvl(test_run_id,"0").equals("0"))
									html.append("<td><input type=button value=\"...\" onclick=\"openTestReport('"+test_run_id+"');\" class=\"btn btn-danger btn-sm\"></td>");
								else html.append("<td>-</td>");
							}
							else
								html.append("<td>-</td>");
						} //if (wp_type.equals("AUTO"))
						else {
							if (Integer.parseInt(nvl(arec[9],"0"))>0) 
								html.append("<td><input type=button value=\"Error\" onclick=\"showInfoDetail('"+arec[0]+"','tdm_task_"+work_plan_id+"_"+work_package_id+"','err_info_zipped');\" class=\"btn btn-danger btn-sm\"></td>");
							else 
								//html.append("<td><input type=button value=\"Show Rollbacks\" onclick=\"showInfoDetail('"+arec[0]+"','tdm_task_"+work_plan_id+"_"+work_package_id+"','rollback_info_zipped');\" class=\"btn btn-success btn-sm\"></td>");
								html.append("<td>-</td>");
						}
						
						html.append("</tr>");
			} //for (int i=0;i<recs.size();i++) {
			
		} //for (int w=0;w<currWpcArr.size();w++) {

	}


html.append("</table>");

return html.toString();
}

		
		
static final String TYPE_LIST_STRING="VARCHAR2,CHAR,VARCHAR,LONGVARCHAR,NCHAR,NVARCHAR,NLONGVARCHAR,LONG,TEXT,CHARACTER,CHARACTER VARYING,BPCHAR";
static final String TYPE_LIST_INT="NUMBER,TINYINT,SMALLINT,INTEGER,BIGINT,FLOAT,REAL,DOUBLE,NUMERIC,DECIMAL,INT IDENTITY,NUMERIC IDENTITY,SERIAL,INT2,INT4,BIGSERIAL,SMALLSERIAL";
static final String TYPE_LIST_DATE="DATE,TIME,TIMESTAMP,SMALLDATETIME,DATETIME,DATETIME2,DATETIMEOFFSET,TIME";
static final String TYPE_LIST_BLOB="BLOB,LONGBLOB,MEDIUMBLOB,TINYBLOB,LONGVARBINARY,BINARY,VARBINARY,OTHER,BYTEA";
static final String TYPE_LIST_CLOB="CLOB,LONGCLOB,MEDIUMCLOB,TINYBCLOB,LONGVARCHAR,MEDIUMVARCHAR,XML,_TEXT,TSVECTOR";

private String fieldtype2bindtype(String field_type,String orig_val) {
	String bindtype = "UNKNOWN";

	if (TYPE_LIST_STRING.indexOf(field_type.toUpperCase()) > -1) {
		return  "STRING";
	}

	if (TYPE_LIST_INT.indexOf(field_type.toUpperCase()) > -1) {

		bindtype = "INTEGER";

		try {
			long l = Long.parseLong(orig_val);
			bindtype = "LONG";
		} catch (Exception e) {	}

		try {
			int l = Integer.parseInt(orig_val);
			bindtype = "INTEGER";
		} catch (Exception e) {	}
		
		return bindtype;
	}

	if (TYPE_LIST_DATE.indexOf(field_type.toUpperCase()) > -1) 
		return "DATE";
	
	if (TYPE_LIST_BLOB.indexOf(field_type.toUpperCase()) > -1) 
		return  "BLOB";

	if (TYPE_LIST_BLOB.indexOf(field_type.toUpperCase()) > -1) 
		return  "BLOB";

	if ("ROWID".indexOf(field_type.toUpperCase()) > -1) 
		return  "ROWID";
		
	return bindtype;
}


//****************************************
String addStartEnd(Connection conn, String env_id, String tabin) {
	
	String start_char="\"";
	String end_char="\"";
	String middle_char=".";
	
	Connection connApp=getconn(conn, env_id);
	 
	try {
		if(connApp.getMetaData().getIdentifierQuoteString().trim().length()>0) 
			try {
				start_char=connApp.getMetaData().getIdentifierQuoteString();
				end_char=start_char;
				middle_char=nvl(connApp.getMetaData().getCatalogSeparator(),".");
			} catch(Exception e) {
				e.printStackTrace();
			}
	} catch(Exception e) {
		e.printStackTrace();
	} finally {
		closeconn(connApp);
	}
	

	if (tabin.contains(start_char)) return tabin;
	String ret1=tabin;
	try {
		ret1=
				start_char+tabin.split("\\.")[0]+end_char+
				middle_char+
				start_char+tabin.split("\\.")[1]+end_char;
	} catch(Exception e) {
		ret1=start_char+tabin+end_char;
	}
	
	String[] arr=tabin.split("\\.");
	return ret1;
	
}

//**************************************************************
String makeRunApplicationDlg(
		Connection conn, 
		HttpSession session, 
		String app_id,
		String env_id,
		String dateformat
		) {
//**************************************************************
	StringBuilder sb=new StringBuilder();
	String  sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();

	String app_name=getDBSingleVal(conn, "select name from tdm_apps where id="+app_id);
	String env_name=getDBSingleVal(conn, "select name from tdm_envs where id="+env_id);
	String db_type=getEnvDBParam(conn, env_id, "DB_TYPE");
	
	sb.append("<div class=\"panel panel-primary\">");
	
	sb.append("<div class=\"panel-body\"  style=\"min-height: 120px; max-height: 450px; overflow-y: scroll;\">");
	
	boolean is_db_ok=true;
	boolean ischecksok=false;
	boolean is_mongo=false;
	
	if (db_type.toUpperCase().contains("MONGO")) is_mongo=true;
	
	
	String check_result="success";
	
	if (is_mongo) {
		is_db_ok=testMongoClient(conn,env_id);
		if (!is_db_ok) check_result="fail";
	}
	else {
		Connection testconn=getconn(conn, env_id);
		if (testconn==null) {check_result="fail";is_db_ok=false;}
		else closeconn(testconn);
	}
	
	
	
	
	
	if (!is_db_ok) 
		 return "<font color=red>[" + env_name + "] is invalid . </font>";
	
		
	
	
		
	sb.append("<table class=\"table .table-condensed .table-striped\">");
	sb.append("<tr class=success>");
	sb.append("<td align=right>" +
				  "<h4><span class=\"label label-info\">Applicaton to run : </span></h4>"+
				  "</td>");
	sb.append("<td>"+app_name + "</td>");
	sb.append("</tr>");
	
	
	
	sb.append("<tr>");
	sb.append("<td align=right>"+
			"<h4><span class=\"label label-info\">Execution Name : </span></h4>"+
			"</td>");

	String def_wp_name="Run " + app_name + "@" + env_name;
	sb.append("<td>"+
			"<input type=text name=\"work_plan_name\" id=work_plan_name style=\"width:100%; \"  maxlength=200 value=\""+def_wp_name+"\">"); 
	sb.append("</td>");
	sb.append("</tr>");	


	sb.append("<tr>");
	sb.append("<td align=right><h4><span class=\"label label-info\">Execution Type : </span></h4>");
	sb.append("</td>");
	sb.append("<td>"); 
	ArrayList<String[]> arrExType=new ArrayList<String[]>();
	arrExType.add(new String[]{"PARALLEL","Parallel Execution"});
	arrExType.add(new String[]{"SERIAL","Serial Execution"});
	sb.append(makeComboArr(arrExType, "", "size=1 id=work_plan_execution_type", "PARALLEL", 0));
	sb.append("</td>");
	sb.append("</tr>");	
	
	
	sb.append("<tr>");
	sb.append("<td align=right><h4><span class=\"label label-info\">On Error : </span></h4>");
	sb.append("</td>");
	sb.append("<td>"); 
	ArrayList<String[]> onErrorArr=new ArrayList<String[]>();
	onErrorArr.add(new String[]{"CONTINUE","> Continue"});
	onErrorArr.add(new String[]{"STOP","! Stop"});
	onErrorArr.add(new String[]{"ROLLBACK","< Rollback"});
	sb.append(makeComboArr(onErrorArr, "", "size=1 id=work_plan_on_error_action", "CONTINUE", 0));
	sb.append("</td>");
	sb.append("</tr>");	
	
	
	sb.append("<tr>");
	sb.append("<td align=right>"+
			"<h4><span class=\"label label-info\">Notification E-Mail : </span></h4>");
	sb.append("</td>");
	sb.append("<td>" +
			      "<input type=text name=\"email_address\" id=email_address style=\"width:100%; \" maxlength=200 value=\"\">" +
				  "</td>");
	sb.append("</tr>");	
	
	
	
	sb.append("<tr>");
	sb.append("<td align=right>"+
	              "<h4><span class=\"label label-info\">Target Database : </span></h4>"+
			      "</td>");
			      
			      
    sql="select id, name from tdm_envs where for_static='YES' order by name";
	String combo_source_env=makeCombo(conn, sql, "source_env_id", "id=source_env_id size=1 onchange=fillSchemaChangeDiv()", env_id, 0);
	
	
	sb.append("<td>");
	sb.append(combo_source_env);
	
	sb.append("</td>");
	sb.append("</tr>");


	sb.append("<tr>");
	sb.append("<td colspan=2><div id=targetSetterDiv></div></td>");
	sb.append("</tr>");

	
	
	sb.append("<tr>");


	sb.append("<td align=right>"+
			"<h4><span class=\"label label-info\">Run Options : </span></h4>");
	sb.append("</td>");
	
	sb.append("<td>");
	sb.append("<input type=checkbox  id=skip_table_validation value=\"YES\">");
	sb.append(" Skip Table Emptiness Validation");
	sb.append("<br>");
	
	sb.append("<input type=checkbox  id=skip_fieldcheck_validation value=\"YES\">");
	sb.append(" Skip Table Column Check Validation");
	sb.append("<br>");
	
	
	sb.append("<input disabled checked type=checkbox  id=direct_masking value=\"YES\">");
	sb.append(" <font color=red>Direct Masking (!)</font>");
	sb.append("<br>");

	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("<tr>");
	sb.append("<td colspan=2>");
	
	sb.append("<table class=\"table .table-condensed\">");
	
	
	
	sb.append("<tr>");
	
	sb.append("<td>"+
	       		  "<h4><span class=\"label label-info\">Master Max. </span></h4>"+ 
	 			  "</td>");
	
	sb.append("<td>" +
	               "<h4><span class=\"label label-info\">Worker Max. </span></h4>"+ 
			 	   "</td>");
			 	   
	
	sb.append("<td>" +
               "<h4><span class=\"label label-info\">Record count in task </span></h4>"+ 
	 	   "</td>");
	 	   
	sb.append("<td>" +
              "<h4><span class=\"label label-info\">Task assignment </span></h4>"+ 
 	   	"</td>");	
 	   	
	sb.append("<td>" +
              "<h4><span class=\"label label-info\">Commit Length </span></h4>"+ 
 	   	"</td>");	
	 	   	

   
	sb.append("</tr>");
	
	
	
	sb.append("<tr>");

	sql="" +
			" select '9999' f1, 'Unlimited' f2 from dual union all " + 
			" select '0' f1, '0' f2 from dual union all " + 
			" select '1' f1, '1' f2 from dual union all " + 
			" select '2' f1, '2' f2 from dual union all " + 
			" select '5' f1, '5' f2 from dual union all " + 
			" select '10' f1, '10' f2 from dual union all " + 
			" select '20' f1, '20' f2 from dual union all " + 
			" select '30' f1, '30' f2 from dual union all " + 
			" select '40' f1, '40' f2 from dual union all " + 
			" select '50' f1, '50' f2 from dual union all " + 
			" select '60' f1, '60' f2 from dual union all " + 
			" select '70' f1, '70' f2 from dual union all " + 
			" select '80' f1, '80' f2 from dual union all " + 
			" select '90' f1, '90' f2 from dual union all " + 
			" select '100' f1, '100' f2 from dual";

	sb.append("<td>"+
			  makeCombo(conn, sql, "master_limit", "id=master_limit", "9999", 100)+ 
 			  "</td>");


	sb.append("<td>" +
		      makeCombo(conn, sql, "worker_limit", "id=worker_limit", "5", 100)+
		 	   "</td>");
		 	   
    
   	sb.append("<td>" +
    		"<input type=text size=5 maxlength=10 name=\"REC_SIZE_PER_TASK\" id=REC_SIZE_PER_TASK value=\"1000\">"+ 
 	   "</td>");
 	   
   	sb.append("<td>" +
    		"<input type=text size=5 maxlength=10 name=\"TASK_SIZE_PER_WORKER\" id=TASK_SIZE_PER_WORKER value=5>"+ 
	   	"</td>");	
   
   	sb.append("<td>" +
			"<input type=text size=5 maxlength=10 name=\"UPDATE_WPACK_COUNTS_INTERVAL\" id=UPDATE_WPACK_COUNTS_INTERVAL value=120000>"+ 
	   	"</td>");	
    
    sb.append("</tr>");
	
    sb.append("</table>");


    sb.append("</td>");
    sb.append("</tr>");



    sb.append("<tr>");
    sb.append("<td  align=right>");
    sb.append("<h4><span class=\"label label-info\">First Schedule : </span></h4>");
    sb.append("</td>");
	Calendar cal=GregorianCalendar.getInstance();
	SimpleDateFormat format1 = new SimpleDateFormat(dateformat); 
	String p_dt_formatted=format1.format(cal.getTime());
	sb.append("<td>");
	sb.append(makeDate("0","start_date", p_dt_formatted, "name=start_date "));;
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
    sb.append("<td  align=right>");
    sb.append("<h4><span class=\"label label-info\">Schedule Interval : </span></h4>");
    sb.append("</td>");
    ArrayList<String[]> repeatArr=new ArrayList<String[]>();
    repeatArr.add(new String[]{"NONE","No Repeat"});
    repeatArr.add(new String[]{"DAILY","Daily"});
    repeatArr.add(new String[]{"HOURLY","Hourly"});
    repeatArr.add(new String[]{"MINUTE","Every ? Minute"});
    sb.append("<td>");
	sb.append(makeComboArr(repeatArr, "", "id=repeat_period size=1 ", "NONE", 200));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	
	sb.append("<tr>");
    sb.append("<td  align=right>");
    sb.append("<h4><span class=\"label label-info\">Schedule Period : </span></h4>");
    sb.append("</td>");
    sb.append("<td>");
	sb.append(makeNumber("0", "repeat_by", "0", "", "EDITABLE", "5", "0", ",", "", "", "1", "99999"));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("</tr>");
	sb.append("<tr>");
	sb.append("<td align=right>"+
			"<h4><span class=\"label label-info\">Depended Work Plan(s) : </span></h4>"+
			"</td>");
	sb.append("<td>");
	
	sb.append(makeWPListToDepend(conn,session,"MASK2"));
	
	
	sb.append("</td>");
	sb.append("</tr>");
	
	


	
	sb.append("</div> <!-- panel body -->");
	
	sb.append("<div> <!-- panel-->");



return sb.toString();
}


//*************************************************************
String makeWPListToDepend(Connection conn, HttpSession session, String wpl_type) {
		
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select id, concat(id, '.',work_plan_name) from tdm_work_plan "+
		" where wplan_type=? "+
		" and status not like 'COMPLETED%' and status not like 'FINISHED%' order by id desc";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",wpl_type});
	ArrayList<String[]> source_arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	ArrayList<String[]> picked_arr=new ArrayList<String[]>();
	sb.append(makePickList("0", "depended_work_plan_list", source_arr, picked_arr, "",""));
	return sb.toString();
}

//**************************************************************
public String printLongDet2(Connection connconf, String wp_type, String env_id, String id, String tab, String fld) {
//**************************************************************
	
	
	final String TAG_RECORD_START="<r>";
	final String TAG_RECORD_END="</r>";
	
	final String TAG_FIELD_START="<f>";
	final String TAG_FIELD_END="</f>";
	
	
	String sql="select " + fld.toLowerCase() + " from "+ tab.toLowerCase()+ " where id="+id;
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String lines="";
	
	String db_type=getEnvDBParam(connconf, env_id, "DB_TYPE");
	boolean is_mongo=false;
	if (db_type.toUpperCase().contains("MONGO")) is_mongo=true;
	
	if (fld.toUpperCase().indexOf("_ZIPPED")>-1) {
		try {
			lines=uncompress(getInfoBin(connconf, tab.toLowerCase(),Integer.parseInt(id),fld.toLowerCase()));
		} catch(Exception e) {lines=e.getMessage();}
	}
	else
	{
		ArrayList<String[]> recs=getDbArrayConf(connconf, sql, Integer.MAX_VALUE, bindlist);
		
		try {
			lines=recs.get(0)[0];
		} catch(Exception e) {lines="Exception@printLongDet:" + e.getMessage();}
	}
	
	//-----------------------------------
	if (fld.toUpperCase().equals("TASK_INFO_ZIPPED") && wp_type.equals("MASK2")) {
		ArrayList<String[]> taskArr=null;
		
		
		try { 
			String task_table_name=tab.toLowerCase();

			ByteArrayInputStream bis=new ByteArrayInputStream(
					uncompresstobyte(
							getInfoBin(connconf, task_table_name,Integer.parseInt(id),fld.toLowerCase())
									)
							);
			ObjectInputStream ois = new ObjectInputStream(bis);
			
			taskArr=(ArrayList<String[]>) ois.readObject();
			ois.close();
		} catch(Exception e) {
			System.out.println("Exception@maskingThread : " + e.getMessage());
			e.printStackTrace();
		} 
		
		StringBuilder tmp=new StringBuilder();
		
		if (taskArr!=null) {
			String[] exportInfo=taskArr.get(0);
			
			String export_catalog=exportInfo[0];
			String export_schema=exportInfo[1];
			if (export_schema.indexOf(".")>-1) export_schema=export_schema.split("\\.")[1];
			String export_table=exportInfo[2];
			String export_statement=exportInfo[3];
			
			
			
			int colcount=Integer.parseInt(exportInfo[4]);
			
			int export_tab_id=Integer.parseInt(exportInfo[5]);
			
			
			
			String masking_table_name=export_schema+"."+addStartEnd(connconf, env_id, export_table);
			if (export_schema.length()==0 || export_schema.equals("null")) masking_table_name=export_table;
			
			ArrayList<String[]> columnInfo=new ArrayList<String[]>();
			ArrayList<String> isPKArr=new ArrayList<String>();
			
			String app_sql="select ";
			
			if (db_type.equals("MSSQL") || db_type.equals("SYBASE")) 
				app_sql=app_sql + " top 1 ";
			
			sql="select 1 from tdm_fields where tab_id=?  and field_name=? and is_pk='YES'";
			for (int i=1;i<1+colcount;i++)  {
				columnInfo.add(taskArr.get(i));
				String field_name=columnInfo.get(i-1)[0];
				
				String isPk="NO";
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+export_tab_id});
				bindlist.add(new String[]{"STRING",""+field_name});
				
				ArrayList<String[]> arr=getDbArrayConf(connconf, sql, 1, bindlist);
				if (arr.size()==1) isPk="YES";
				isPKArr.add(isPk);
				
				
				if (i>1) app_sql=app_sql+ ", ";
				app_sql=app_sql+ addStartEnd(connconf,env_id, field_name);
				
			}
			
			app_sql=app_sql + "  from " + masking_table_name;
			
			if (db_type.equals("MSSQL")) app_sql=app_sql + " with (NOLOCK) ";
			
			if (db_type.equals("SYBASE")) app_sql=app_sql + " NOHOLDLOCK ";
			
			app_sql=app_sql + " where ";
			
			int k=0;
			for (int c=0;c<columnInfo.size();c++)  {
				String field_name=columnInfo.get(c)[0];
				if (!isPKArr.get(c).equals("YES")) continue;
				k++;
				if (k>1) app_sql= app_sql+ " and ";
				app_sql= app_sql + addStartEnd(connconf,env_id, field_name) + "=? ";
			}
			
			
			int rec_start=1+colcount;
			

			String task_status=getDBSingleVal(connconf, "select status from " + tab.toLowerCase() + " where id="+id);
			
			tmp.append("<table class=table>");
			tmp.append("<tr class=info>");
			
			for (int c=0;c<columnInfo.size();c++)  {
				String field_name=columnInfo.get(c)[0];
				tmp.append("<td><b>"+field_name+"</b></td>");
			}
			
			if (is_mongo && task_status.equals("FINISHED")) {
				tmp.append("<td><b> DOCUMENT [Masked]  "+"</b></td>");
			}
			
			tmp.append("</tr>");
			
			
			
			if (task_status.length()==0) return "Task is not there.";
			int max_rec=taskArr.size();
			if (max_rec>100) max_rec=100;
			
			
			
			sql="select field_name from tdm_fields where tab_id=? and (mask_prof_id>0 or is_conditional='YES' or is_pk='YES');";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+export_tab_id});
			ArrayList<String[]> maskedFieldList=getDbArrayConf(connconf, sql, Integer.MAX_VALUE, bindlist);

			Connection connApp=null;
			if (!is_mongo && task_status.equals("FINISHED")) {
				connApp=getconn(connconf,env_id);
				setCatalogForConnection(connApp, export_catalog);
			}
			
			for (int i=rec_start;i<max_rec;i++) {
				String[] row=taskArr.get(i);
				
				tmp.append("<tr class=active>");
				for (int c=0;c<row.length;c++) {
					
					
					String field_type=columnInfo.get(c)[2];
					
					if (field_type.equals("JSON")) {
						
						tmp.append("<td>"+Json2Html(maskedFieldList,row[c],"")+"</td>");
						
						if (task_status.equals("FINISHED")) {
							String[] keys=new String[columnInfo.size()-1];
							String[] vals=new String[columnInfo.size()-1];
							
							for (int p=0; p<columnInfo.size()-1;p++) {
								keys[p]=columnInfo.get(p)[0];
								vals[p]=row[p];
							}
							
							String masked_json=getMONGODocumentById(connconf, env_id, export_schema, export_table, keys, vals);
							tmp.append("<td class=success>"+Json2Html(maskedFieldList, masked_json,"")+"</td>");
						}
					}
						
					else 
						tmp.append("<td>"+row[c]+"</td>");
				}
				tmp.append("</tr>");
				
				if (!is_mongo && task_status.equals("FINISHED")) {
					
					
					bindlist.clear();
					for (int c=0;c<row.length;c++) {
						if (!isPKArr.get(c).equals("YES")) continue;
						String bindval=row[c];
						String bindtype=fieldtype2bindtype(columnInfo.get(c)[2], bindval);
						
						bindlist.add(new String[]{bindtype,bindval});
						
						
						//System.out.println("bindtype="+bindtype+",bindval="+bindval+"columnInfo.get(c)[2]="+columnInfo.get(c)[2]);
					}
					
					ArrayList<String[]>  arr=getDbArrayApp(connApp, app_sql, 1, bindlist, false, "");
					if (arr==null || arr.size()==0) continue;
					
					
					String[] mrow=arr.get(0);
					tmp.append("<tr class=success>");
					for (int c=0;c<mrow.length;c++) {
						tmp.append("<td>"+mrow[c]+"</td>");
					}
					tmp.append("</tr>");
				}
			}
			
			tmp.append("</table>");
			
			if (!is_mongo && task_status.equals("FINISHED"))
				closeconn(connApp);
			
		} //if (taskArr!=null) {
		else {
			tmp.append("Array cannot be decoded.");
		}
		lines=tmp.toString();
	} 
	//-----------------------------------
	else if (fld.toUpperCase().equals("TASK_INFO_ZIPPED") && (wp_type.equals("MASK") || wp_type.equals("COPY")) ) {

		StringBuilder tmp=new StringBuilder();
		
		String a_line="";
		String table_name="";
		String task_status="";
		
		try {
			task_status=getDBSingleVal(connconf, "select status from " + tab.toLowerCase() + " where id="+id);
		} catch(Exception e) {};
		
		if (task_status.length()==0) return "Task is not there.";
		
		String[] lineArr=lines.split("\n");
		
		int recno=0;
		int fieldno=0;
		final int MAXFIELDCOUNT=300;
		
		String[] aRec=new String[MAXFIELDCOUNT];
		ArrayList<String[]> recs=new ArrayList<String[]>();
		
		ArrayList<String> fieldNames=new ArrayList<String>();
		ArrayList<String> fieldTypes=new ArrayList<String>();
		ArrayList<String> fieldIsPK=new ArrayList<String>();
		
		boolean printTable=false;
		int level=0;

		for (int i=0;i<lineArr.length;i++) {
			a_line=lineArr[i];

			
			if (a_line.indexOf("<start_of_file>")==0) {
				
				if (wp_type.equals("MASK")) table_name=a_line.split("\\|::\\|")[1];
			}
			
			if (a_line.indexOf("<end_of_file>")==0 || printTable) {

				printTable=false;
				
				if (recs.size()>0) {
				
					tmp.append("<table class=\"table table-condensed\">");
					
					tmp.append("<tr class=warning>");
					//for (int l=0;l<level;l++) 	tmp.append("<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>");
					tmp.append("<td colspan="+fieldno+"><big><b>"+table_name+"</b></big></td>");
					tmp.append("</tr>");
					
					tmp.append("<tr class=active>");
					//for (int l=0;l<level;l++) 	tmp.append("<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>");
					for (int r=0;r<fieldNames.size();r++) {
						tmp.append("<td>");
						tmp.append("<b>"+fieldNames.get(r));
						tmp.append("</td>");
					}
					tmp.append("</tr>");
					
					
					ArrayList<String[]> actrecs=new ArrayList<String[]>();
					if (task_status.equals("FINISHED")) {
						StringBuilder sqlbulk=new StringBuilder();
						bindlist.clear();
						for (int r=0;r<recs.size();r++) {
							if (r>0) sqlbulk.append("\nUNION ALL\n");
							sqlbulk.append("select ");
							int a=0;
							for (int f=0;f<fieldno;f++) {
								 
									if (f>0) sqlbulk.append(", ");
									
									if (fieldTypes.get(f).equals("CALCULATED")) 
										sqlbulk.append("'$CALCULATED'");
									else
										sqlbulk.append(fieldNames.get(f));
								
								
							} 
							sqlbulk.append(" from "+table_name +  " where ");
							
							int pk_count=0;
							for (int f=0;f<fieldno;f++) {
								if (fieldIsPK.get(f).equals("YES")) {
									pk_count++;
									if (pk_count>1) sqlbulk.append(" and ");
									sqlbulk.append(fieldNames.get(f)+"=? ");
									String bindval=recs.get(r)[f];
									if (bindval.equals("${EMPTY}")) bindval="";
									
									bindlist.add(new String[]{fieldtype2bindtype(fieldTypes.get(f), bindval),bindval});
								}
							}
							
						} //for (int r=0;r<recs.size();r++)
						//System.out.println(sqlbulk.toString());
						
						actrecs=getDbArrayApp(connconf, env_id, sqlbulk.toString(), Integer.MAX_VALUE, bindlist);
						
					} //if (task_status.equals("FINISHED"))
				
					int maxRec=recs.size();
					if (recs.size()>100) maxRec=100;
					
					for (int r=0;r<maxRec;r++) {
						tmp.append("<tr>");
						//for (int l=0;l<level;l++) 	tmp.append("<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>");
						for (int f=0;f<fieldno;f++) {
							tmp.append("<td>");
							if (recs.get(r)[f].length()<=100)
								tmp.append(recs.get(r)[f]);
							else {
								tmp.append(recs.get(r)[f].substring(0, 99));
								tmp.append("...");
							}
							
							tmp.append("</td>");
						} 
						tmp.append("</tr>");
						
						if (recs.size()==actrecs.size()) {
							tmp.append("<tr>");
							//for (int l=0;l<level;l++) 	tmp.append("<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>");
							for (int f=0;f<fieldno;f++) {
								tmp.append("<td class=success>");
								//if (!fieldIsPK.get(f).equals("YES")) 
									if (actrecs.get(r)[f].length()<=100)
										tmp.append(actrecs.get(r)[f]);
									else {
										tmp.append(actrecs.get(r)[f].substring(0, 99));
										tmp.append("...");
									}
								 
								tmp.append("</td>");
							}
							tmp.append("</tr>");
						}
						
					} //for (int r=0;r<recs.r++)
						
					tmp.append("</table>");
							
										
					
					recs.clear();
					fieldNames.clear();
					fieldTypes.clear();
					fieldIsPK.clear();
					recno=0;
					
				} //if (recs.size()>0)
					
			
			} //if (a_line.indexOf("<end_of_file>")==0)
			
			if (a_line.indexOf(TAG_RECORD_START)==0) {
				
				
				
				if (wp_type.equals("COPY")) {
					table_name=a_line.split("\\|::\\|")[3];
					
					try {level=Integer.parseInt(a_line.split("\\|::\\|")[4]);} catch(Exception e) {level=0;}
					
					
				}
				
				
				recno++;
				fieldno=0;
				
			}
			
			if (a_line.indexOf(TAG_FIELD_START)==0) {
				
				String fArr[]=a_line.split("\\|::\\|");
				
				if (recno==1) {
					String fname=fArr[1];
					String ftype=fArr[2].split(":")[0];
					String f_ispk=fArr[3];
					
					fieldNames.add(fname);
					fieldTypes.add(ftype);
					fieldIsPK.add(f_ispk);
				}
				
				
				String  fval="";

				short line_no=0;
				do {
					i++;
					line_no++;
					if (line_no>1) fval=fval+"\n";
					fval=fval+lineArr[i];
					
				} while(!lineArr[i+1].equals(TAG_FIELD_END));
				
				aRec[fieldno]=fval; 
				fieldno++;				
			} //if (a_line.indexOf(TAG_FIELD_START)==0)
				
			
			if (a_line.indexOf(TAG_RECORD_END)==0) {
				
				recs.add(aRec);
				aRec=new String[MAXFIELDCOUNT];
				
				if (wp_type.equals("COPY")) {

					int n=i;
					do {
						n++;
						
						if (lineArr[n].indexOf(TAG_RECORD_START)==0) {
							String next_table_name=lineArr[n].split("\\|::\\|")[1];
							int next_level=0;
							try {next_level=Integer.parseInt(lineArr[n].split("\\|::\\|")[2]);} catch(Exception e) {next_level=0;}
							
							if (!next_table_name.equals(table_name) || next_level!=level)
								printTable=true;
							
							
							break;
						}
						
						
					} while(lineArr[n+1].indexOf("<end_of_file>")==-1); 
						
						
					
					
					
				}
				
			} //if (a_line.indexOf("</record>")==0)
			
			
			
			
			
			
		} //for
		
		
				
		lines=tmp.toString();
		tmp.setLength(0);
		
		
	} //if (fld.equals("TASK_INFO_ZIPPED"))
	else {
		lines="<textarea rows=19 style=\"width:100%; font-family: monospace; background-color:black; color:white; \">"+lines+"</textarea>";
	}
	


	String html="<center>"+
			"<table border=0 cellspacing=0 cellpadding=0><tr><td><b>"+
			fld+"@"+tab+"["+id+"]"+
			"</b></td></tr></table>"+
			lines+
			"</center>";
	
	lines=null;
	
	return html;

  
  

}






//**************************************************************
public StringBuilder discoveryCopyingPrint(Connection connconf,int discovery_id, int match_rate, String parent_table) {
//**************************************************************

StringBuilder sb=new StringBuilder();


String sql="";


ArrayList<String[]> bindlist=new ArrayList<String[]>();



sql="select env_id from tdm_work_plan where id="+discovery_id;
String env_id=getDBSingleVal(connconf, sql);

sql="select app_id from tdm_work_plan where id="+discovery_id;
String app_id=getDBSingleVal(connconf, sql);

sql="select work_plan_name from tdm_work_plan where id="+discovery_id;
String discovery_name=getDBSingleVal(connconf, sql);

int maxRec=1000;
try { 
		maxRec=Integer.parseInt(getParamByName(connconf, "DISCOVERY_SAMPLE_SIZE"));
} catch(Exception e) {
	maxRec=1000;
}
int match_count=(match_rate*maxRec/100);
int fifty_percent=(maxRec/2);

ArrayList<String[]> arr=new ArrayList<String[]>();
arr.add(new String[]{"0","0%"});
arr.add(new String[]{"10","10%"});
arr.add(new String[]{"20","20%"});
arr.add(new String[]{"30","30%"});
arr.add(new String[]{"40","40%"});
arr.add(new String[]{"50","50%"});
arr.add(new String[]{"60","60%"});
arr.add(new String[]{"70","70%"});
arr.add(new String[]{"80","80%"});
arr.add(new String[]{"90","90%"});
arr.add(new String[]{"100","100%"});

String combo_rate=makeComboArr(arr, "result_rates", "id=result_rates size=1 onchange=showCopyingDiscoveryReport('"+discovery_id+"')", ""+match_rate, 120);

sql="select distinct source_tab_name from tdm_discovery_rel where discovery_id="+discovery_id+ " order by 1";
String combo_parent_table=makeCombo(connconf, sql, "parent_table", "id=parent_table onchange=showCopyingDiscoveryReport('"+discovery_id+"');", parent_table, 300);

sb.append("<table class=\"table table-striped\" width=\"100%\">");

sb.append("<tr>");
sb.append("<td colspan=10 align=center>");
sb.append("<h4>"+discovery_name+"</h4>");
sb.append("</td>");
sb.append("</tr>");

sb.append("<tr class=info>");

sb.append("<td align=right>");
sb.append(" Match Rate >= ");
sb.append("</td>");

sb.append("<td>");
sb.append(combo_rate);
sb.append("</td>");

sb.append("<td align=right>");
sb.append(" Parent Table ");
sb.append("</td>");


sb.append("<td>");
sb.append(combo_parent_table);
sb.append("</td>");



sb.append("<td align=right>");
sb.append("<button type=button class=\"btn btn-success btn-sm\" onclick=showCopyingDiscoveryReport('"+discovery_id+"')>"+
			"<span class=\"glyphicon glyphicon-repeat\">Refresh</span>"+
		   "</button>");
sb.append("</td>");

sb.append("</tr>");

sb.append("</table>");
		
sb.append("<div id=discReportResult  style=\"min-height: 100px; max-height: 450px; overflow-x: scroll; overflow-y: scroll;\">" );

sql="select id, source_tab_name, rel_tab_name, rel_on_fields, found_rate, " + 
	 	" (  \n"+
	 	" select  \n"+
		" max(tdet.id) id \n"+
		" from tdm_tabs_rel tr, tdm_tabs tmas, tdm_tabs tdet \n"+
		" where tr.tab_id=tmas.id \n"+
		" and tr.rel_tab_id=tdet.id \n"+
		" and concat(tmas.schema_name,'.',tmas.tab_name)=source_tab_name \n"+
		"  and concat(tdet.schema_name,'.',tdet.tab_name)=rel_tab_name  \n"+
	 	" ) in_app,  \n"+
		" rel_filter \n " +
	 	" from tdm_discovery_rel r " + 
	" where discovery_id="+ discovery_id;
	
	if (parent_table.length()>0)
		sql=sql+" and source_tab_name='"+parent_table+"' \n";

	sql=sql + 
		" and found_rate>=" + match_rate + 
		" order by source_tab_name, rel_tab_name, rel_on_fields";

	ArrayList<String[]> discRes=getDbArrayConf(connconf, sql, Integer.MAX_VALUE, new ArrayList<String[]>());


	if (discRes.size()==0) 
	sb.append("<big><b><font color=red>No result.</></b></big>");
	else 
	{
	
		sb.append("<table class=\"table table-condensed\">");

		String group_field_val1="";
		for (int i=0;i<discRes.size();i++) {
			
			String discovery_rel_id=discRes.get(i)[0];
			String source_tab_name=discRes.get(i)[1];
			String rel_tab_name=discRes.get(i)[2];
			String rel_on_fields=discRes.get(i)[3];
			String found_rate=discRes.get(i)[4];
			String in_app_tab_id=nvl(discRes.get(i)[5],"0");
			String rel_filter=nvl(discRes.get(i)[6],"NO");

			if (!group_field_val1.equals(source_tab_name)) {
				group_field_val1=source_tab_name;
				
				sb.append("<tr class=active>");

				sb.append("<td></td>");

				sb.append("<td nowrap colspan=5>");
				sb.append("<h4><b>"+source_tab_name+"</b></h4>");
				sb.append("</td>");

				sb.append("</tr>");
			}
			
			
			

			String tr_class="";
			
			
			if (Integer.parseInt(found_rate)>=50) tr_class="warning";
			if (rel_filter.equals("YES")) tr_class="danger";
			if (!in_app_tab_id.equals("0")) tr_class="success";

			sb.append("<tr class="+tr_class+">");

			sb.append("<td nowrap>");
			
			sb.append("<button type=button class=\"btn btn-info btn-sm\" "+
					"onclick=\"showSqlEditor('"+env_id+"','0','"+rel_tab_name+"','','${default}');\" >");
			sb.append("<span class=\"glyphicon glyphicon-list-alt\"></span>");
			sb.append("</button>");
			
			if (in_app_tab_id.equals("0")) {
				
				if (rel_filter.equals("YES")) {
					sb.append("<button type=button class=\"btn  btn-default btn-sm\" "+
							"onclick=setDiscoveryRelFilter('"+discovery_id+"','"+discovery_rel_id+"','NO'); >");
					sb.append("<span class=\"glyphicon glyphicon-ok\"></span>");
					sb.append("</button>");
				}
				else {
					
					sb.append("<button type=button class=\"btn btn-success btn-sm\" "+
							"onclick=\"showAddTableToAppList("+discovery_id+",'"+discovery_rel_id+"','"+rel_tab_name+"','"+env_id+"','"+app_id+"');\" >");
					sb.append("<span class=\"glyphicon glyphicon-plus\"></span>");
					sb.append("</button>");
				
					sb.append("<button type=button class=\"btn btn-none btn-sm\" "+
							"onclick=setDiscoveryRelFilter('"+discovery_id+"','"+discovery_rel_id+"','YES'); >");
					sb.append("<span class=\"glyphicon glyphicon-remove\"></span>");
					sb.append("</button>");
				}
			}  
			else {
				
				sb.append("<a href=\"javascript:removeTableFromAppDiscovery('"+app_id+"','"+in_app_tab_id+"','"+discovery_id+"','"+match_rate+"');\" >");
				sb.append("<font color=red><span class=\"glyphicon glyphicon-minus\"></span></font>");
				sb.append("</a>");
				
				
				sb.append(
						"   <a href=\"javascript:openTableScriptDetails('"+env_id+"','"+in_app_tab_id+"')\">"+
						"     <span class=\"glyphicon glyphicon-folder-open\"></span>"+
						"   </a>"
						);
				
			}
			
			sb.append("</td>");
				
			sb.append("<td nowrap>");
			sb.append(""+rel_tab_name+"");
			sb.append("</td>");

			
			sb.append("<td nowrap>");
			sb.append(rel_on_fields);
			sb.append("</td>");
			
			
			sb.append("<td nowrap>");
			sb.append("<b>"+found_rate+" %</b>");
			sb.append("</td>");
			
			sb.append("</tr>");

		} // for 
	
		sb.append("</table>");

	} // if size=0

	sb.append("</div>");

return sb;

}





//****************************************
public StringBuilder checkSchemaList(Connection connconf, HttpServletRequest request, String app_id, String env_id) {
	
	StringBuilder html=new StringBuilder();


	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select  distinct schema_name owner from tdm_tabs where app_id=? order by 1";
	bindlist.add(new String[]{"INTEGER",app_id});
	
	ArrayList<String[]> owners_src=getDbArrayConf(connconf, sql, Integer.MAX_VALUE, bindlist);
	
	bindlist=new ArrayList<String[]>();

	ArrayList<String[]> owners_tar=new ArrayList<String[]>();
	String owners_tar_str="";

	Connection connTar=getconn(connconf, env_id);
	
	if (connTar!=null) {
		owners_tar=getSchemaListFromConn(connTar,"${default}");
		try{
			connTar.close();	
		} catch(Exception e) {
			
		}
		
		connTar=null;
	}
	
	for (int i=0;i<owners_tar.size();i++) owners_tar_str=owners_tar_str+","+owners_tar.get(i)[0]+",";
	String check_result="";
	String a_owner="";
	int fail_cnt=0;
	
	String upd_schema_code="";
	String target_set_owner="";
	String target_owner_info="";
	html.append("<table border=0 cellspacing=0 cellpadding=0>");
	for (int i=0;i<owners_src.size();i++) {
		check_result="success";
		upd_schema_code="";
		a_owner=owners_src.get(i)[0];
		target_set_owner=nvl(request.getParameter("TARGET_FOR_"+a_owner),"-");
		if(!owners_tar_str.contains(","+a_owner+",")) { 
			if (target_set_owner.equals("-")) {
				check_result="fail"; 
				fail_cnt++;
				upd_schema_code=""+
				makeComboArr(owners_tar, "TARGET_FOR_"+a_owner, "onchange=document.fmain.submit(); ", "", 200);
			} else {
				upd_schema_code=makeComboArr(owners_tar, "TARGET_FOR_"+a_owner, "onchange=document.fmain.submit(); ", target_set_owner, 200);
				target_owner_info=target_owner_info+","+a_owner+"::"+target_set_owner+",";
			}
			}
		html.append(
				"<tr>"+
				"<td>" + a_owner +"</td>"+
				"<td><img src=\""+check_result+".png\" border=0 width=25 height=24></td>"+
				"<td>"+upd_schema_code+"</td>"+
				"</tr>");
	}
	html.append("</table>"+
		"<input type=hidden name=target_owner_info value=\""+target_owner_info+"\">");



	return html;
}


//*************************************************************
	public boolean validateSQLStatement(Connection connApp, String sql, StringBuilder sbErr) {
//*************************************************************
		boolean ret1 = false;

		PreparedStatement pstmtApp=null;
		
		try {

			pstmtApp = connApp.prepareStatement(sql);
			try {
				pstmtApp.setQueryTimeout(600);
			} catch(Exception e) {
				System.out.println("DB does not support setQueryTimeout. dont worry :) skipping... ");
			}
			
			pstmtApp.executeQuery();
			ret1=true;
		
		} catch (Exception ignore) {
			//ignore.printStackTrace();
			System.out.println("Exception@validateSQLStatement SQL : " + sql);
			System.out.println("Exception@validateSQLStatement MSG : " + ignore.getMessage());
			String tmp="<br><b>Exception @SQL </b>: " + clearHtml(sql);
			   tmp=tmp+"<br><b>Exception MSG </b>: " + clearHtml(ignore.getMessage());

			sbErr.append(tmp.replaceAll("'", "\"").replaceAll("\n|\r","<br>"));
		} finally {
			try {pstmtApp.close();pstmtApp = null;} catch (Exception e) {}
		}
		
		return ret1;
	}

//*************************************************************
	public boolean validateSQLStatement(Connection connconf, String env_id, String catalog,  String sql, StringBuilder sbErr) {
//*************************************************************
		boolean ret1 = false;
		Connection connApp=getconn(connconf, env_id);

		if (connApp==null) return false;
		
		setCatalogForConnection(connApp, catalog);
		
		ret1=validateSQLStatement(connApp,sql, sbErr);
		closeconn(connApp);
		
		return ret1;
	}

//*************************************************************
	public boolean validateMongoQuery(Connection conn,String env_id, String db_name, String collection, String mongo_query) {
//*************************************************************
		

		String url="";
		String sql="select db_connstr from tdm_envs where id="+env_id;
		url=getDBSingleVal(conn, sql);
		
		try {
			MongoClient mongo=getMongoClient(url);
			MongoDatabase mongodb=mongo.getDatabase(db_name);
			BasicDBObject query = (BasicDBObject) JSON.parse(mongo_query);
			FindIterable<Document> iterable=mongodb.getCollection(collection).find(query);
			for (Document doc:iterable) {
				return true;
			}
			//no data found
			System.out.println("No Data Found "); 
			System.out.println("Exception@validateMongoQuery  db_name    : "+db_name);
			System.out.println("Exception@validateMongoQuery  collection : "+collection);
			System.out.println("Exception@validateMongoQuery  query      : "+mongo_query);
			
			return false;
		} catch(Exception e) {
			System.out.println("Exception@validateMongoQuery  msg        : "+e.getMessage());
			System.out.println("Exception@validateMongoQuery  db_name    : "+db_name);
			System.out.println("Exception@validateMongoQuery  collection : "+collection);
			System.out.println("Exception@validateMongoQuery  query      : "+mongo_query);
			e.printStackTrace();
			return false;
		}
		

		
	}

	//*************************************************************
	public String getParamByName(Connection conn, String param_name) {
	//*************************************************************
	String ret1="";
	String sql="select param_value from tdm_parameters where param_name='"+param_name+"'";

	ret1=getDBSingleVal(conn, sql);
	
	return ret1;
	
	}

	
	//*************************************************************
	public void setParamByName(Connection conn, String param_name, String param_value) {
	//*************************************************************
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="delete from tdm_parameters where param_name=?";

	bindlist.add(new String[]{"STRING",param_name});
	execDBConf(conn, sql, bindlist);

	sql="insert into tdm_parameters (param_name, param_value) values (?,?)";

	bindlist.add(new String[]{"STRING",param_value});
	execDBConf(conn, sql, bindlist);
	
	
	
	}
	
	//*************************************************************
	void setProcessStatus(Connection conn, HttpSession session, String ptype, String pid, String paction) {
		
		String sql="";
		
		if (ptype.equals("manager")) {
			if (paction.equals("start")) {
				startManager(conn);
			}
			
			if (paction.equals("restart")) {
				sql="update tdm_manager set cancel_flag='RES'";
				execDBConf(conn, sql, new ArrayList<String[]>());
			}
			
			if (paction.equals("stop")) {
				sql="update tdm_manager set cancel_flag='YES'";
				//sql="delete from tdm_manager";
				execDBConf(conn, sql, new ArrayList<String[]>());
			}
		}
		
		
		
		

		
		
		if (ptype.equals("master")) {
			if (paction.equals("set_limit")) {
				try {
					int process_count=Integer.parseInt(pid);

					int max_count=0;
					try {
						max_count=Integer.parseInt(nvl(getParamByName(conn, "MAX_PROCESS_COUNT"),"100"));
					} catch(Exception e) {
						max_count=100;
					}
					
					if (process_count>max_count) process_count=max_count;
					if (process_count<0) process_count=0;

					setParamByName(conn, "TARGET_MASTER_COUNT", ""+process_count);
				} catch(Exception e) {	}
			}
			
			if (paction.equals("stop")) {
				sql="update tdm_master set cancel_flag='YES' where id="+pid;
				execDBConf(conn, sql, new ArrayList<String[]>());
			}
		}
		
		
		
		if (ptype.equals("worker")) {
			if (paction.equals("set_limit")) {
				try {
					int process_count=Integer.parseInt(pid);
					
					int max_count=0;
					try {
						max_count=Integer.parseInt(nvl(getParamByName(conn, "MAX_PROCESS_COUNT"),"100"));
					} catch(Exception e) {
						max_count=100;
					}
					
					if (process_count>max_count) process_count=max_count;
					if (process_count<0) process_count=0;

					setParamByName(conn, "TARGET_WORKER_COUNT", ""+process_count);
				} catch(Exception e) {	}
			}
			
			if (paction.equals("stop")) {
				sql="update tdm_worker set cancel_flag='YES' where id="+pid;
				execDBConf(conn, sql, new ArrayList<String[]>());
			}
		}

	}
	
	

	//*************************************************************
	public String encrypt(String input) {
	//*************************************************************
	String ret1=input;
	Cipher ecipher;
    SecretKey key;
	try {
		String theKey = "01234567";
        key = KeyGenerator.getInstance("DES").generateKey();
        key=new SecretKeySpec(theKey.getBytes("UTF-8"), "DES");
        ecipher = Cipher.getInstance("DES");
        ecipher.init(Cipher.ENCRYPT_MODE, key);
        
        byte[] utf8 = input.getBytes("UTF8");
        byte[] enc = ecipher.doFinal(utf8);
        enc = BASE64EncoderStream.encode(enc);

        //convert to hex
        StringBuilder sb = new StringBuilder();
        for(int i=0; i< enc.length ;i++)
            sb.append(Integer.toString((enc[i] & 0xff) + 0x100, 16).substring(1));

        ret1 = sb.toString();
	} catch (Exception e) {
		e.printStackTrace();
	}

	return ret1;
	}


	
	
	//*************************************************************
	public boolean checkLDAPAuthentication(Connection conn, String username, String password) {
	//*************************************************************
	boolean ret1=true;
	
	
	String ldap_properties=nvl(getParamByName(conn, "LDAP_PROPERTIES"),"");
	if (ldap_properties.length()==0) return false;
	
	Hashtable<String, Object> env = new Hashtable<String, Object>();

	String[] lines=ldap_properties.split("\n");
	
	for (int i=0;i<lines.length;i++) {
		String aline=lines[i].trim();
		if (aline.length()>0 && aline.contains("=")) {
			int aloc=aline.indexOf("=");
			String prop_name=aline.substring(0, aloc);
			String prop_val=aline.substring(aloc+1);

			if (prop_name.equals(Context.SECURITY_PRINCIPAL))
				prop_val=prop_val.replace("%UID%", username);
			
			System.out.println(prop_name+"="+prop_val);
			
			
			env.put(prop_name, prop_val);
		} //if
	} //for

	env.put(Context.SECURITY_CREDENTIALS, password);
	
	try {
        DirContext authContext = new InitialDirContext(env);

    } catch (Exception ex) {
    	ex.printStackTrace();
        return false;
    }
	
	
	
	return ret1;
	}
	
	//*************************************************************
	public int checkuser(Connection conn, String username, String password) {
	//*************************************************************
	int ret1=0;
	
	
	
	
	
	
	String p_authentication_method=nvl(getParamByName(conn, "AUTHENTICATION_METHOD"),"LOCAL");
	
	
	
	if (username.toLowerCase().equals("admin")) p_authentication_method="LOCAL";
	
	System.out.println("AUTHENTICATION_METHOD : "+p_authentication_method);

	if (p_authentication_method.equals("LDAP")) {

		String sql="select username, id from tdm_user where valid='Y' and username=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		ArrayList<String[]> res=null;
		String dbusername="";
		int dbuserid=0;
	
		try {
			bindlist.add(new String[]{"STRING",username});
			res=getDbArrayConf(conn, sql, 1, bindlist);
			if (res.size()>0) {
				dbusername=res.get(0)[0]; 
				dbuserid=Integer.parseInt(res.get(0)[1]);
				}
		} catch(Exception e) {
			dbusername="";
			dbuserid=0;
			e.printStackTrace();
		}
		
		if (dbusername.length()>0) {
			boolean is_ldap_ok=checkLDAPAuthentication(conn, dbusername,password);
			if (is_ldap_ok) return dbuserid; 
			return 0;
		}
	
		
	}

	
	
	if (p_authentication_method.equals("LOCAL"))
	{
		
		String sql="select lower(username), id from tdm_user where valid='Y' and lower(username)=? and password=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		ArrayList<String[]> res=null;
		String dbusername="";
		String encpass="";
	
		try {
			encpass=encrypt(password);
			System.out.println("sql      : "+sql);
			System.out.println("username : "+username.toLowerCase(new Locale("en", "US")));
			//System.out.println("encpass  : "+encpass);
			
			bindlist.add(new String[]{"STRING",username});
			bindlist.add(new String[]{"STRING",encpass});
			res=getDbArrayConf(conn, sql, 1, bindlist);
			if (res.size()>0) 
				dbusername=res.get(0)[0];
		} catch(Exception e) {
			dbusername="";
			e.printStackTrace();
		}
	
	
		
		if (dbusername.length()>0 && username.length()>0 && encpass.length()>0 && res.size()==1) {
			if (dbusername.equals(username)) {
				ret1=Integer.parseInt(res.get(0)[1]);
			}
		}

	} //if (p_authentication_method.equals("LOCAL"))

	
	return ret1;
	
	
	
	}
	
	
	//*************************************************************
	public boolean checkrole(HttpSession session, String role_name) {
	//*************************************************************
	boolean ret1=false;
	String rolevar="";
	try {
		rolevar=nvl((String) session.getAttribute("hasrole_"+role_name),"false");;
		if (rolevar.equals("true")) ret1=true;
	} catch(Exception e) {	}
	
	return ret1;
	}
	
	//*************************************************************
	public boolean checkpermissionByName(HttpSession session, String permission_name) {
	//*************************************************************
	boolean ret1=false;
	String permissionvar="";
	try {
		permissionvar=nvl((String) session.getAttribute("haspermission_name_"+permission_name),"false");
		if (permissionvar.equals("true")) ret1=true;
	} catch(Exception e) {	}
	
	return ret1;
	}
	
	//*************************************************************
	public boolean checkpermissionById(HttpSession session, String permission_id) {
	//*************************************************************
	boolean ret1=false;
	String permissionvar="";
	
	try {
		permissionvar=nvl((String) session.getAttribute("haspermission_id_"+permission_id),"false");
		if (permissionvar.equals("true")) ret1=true;
	} catch(Exception e) {	}
	
	return ret1;
	}

	//*************************************************************
	public void roleRestrict(HttpSession session,  HttpServletResponse response, String role_names) {
	//*************************************************************
	
	// skip check role for admin
	if (nvl((String) session.getAttribute("username"),"-").equals("admin")) return;
	
	boolean hasany=false;
	
	String[] rolesArr=role_names.split(",");
	for (int i=0;i<rolesArr.length;i++) {
		if (checkrole(session,rolesArr[i])) {
			hasany=true;
			break;
		}
	}
	

	if (!hasany) 
		try {
			System.out.println("There is no authorization for this page to user : "+((String) session.getAttribute("username")  ));
			response.sendRedirect("default2.jsp");
		} catch(Exception e) {}
	
	}



	
	//************************************************
	public void startManager(Connection conn) {
	

		String HomePath=getParamByName(conn, "TDM_PROCESS_HOME");
		String username=getParamByName(conn, "CONFIG_USERNAME");
		String password=decode(getParamByName(conn, "CONFIG_PASSWORD"));

		String[] envparams=new String[]{
					"CONFIG_USERNAME="+username,
					"CONFIG_PASSWORD="+password
					};


		int process_count=1;
		String run_classname="managerDriver";
		System.out.println("new "+run_classname+ " is being started : "+process_count);
		String fname;
		String system_type="";
		String run_cmd="";

		String OS = System.getProperty("os.name").toLowerCase();
		if (OS.indexOf("win") >= 0) {
			run_cmd="cmd /c start XXX";
			system_type=".bat";
		}
			
		if (OS.indexOf("nix") >= 0 || OS.indexOf("nux") >= 0 || OS.indexOf("aix") > 0 || OS.indexOf("sunos") >= 0) {
			//run_cmd="./XXX "+username+" " + password+ " 1 &";
			run_cmd="cd "+HomePath+";sh "+HomePath+"/XXX  1 &";
			system_type=".sh";
		}
			
		run_cmd=nvl(getParamByName(conn, "PROCESS_START_COMMAND_TEMPLATE"),"/data/oracle/MayaTDM/XXX 1 &");
		
		System.out.println("system type : "+system_type);
		System.out.println("run_cmd     : "+run_cmd);
		System.out.println("HomePath    : "+HomePath);
		
		File dir = new File(HomePath);
		File[] filesList = dir.listFiles();
		
		if (filesList==null) {
			System.out.println("startManager:filesList is null");
			return;
		}
		System.out.println("File found :"+filesList.length);
		
		for (File file : filesList) {
		    if (file.isFile()) {
		       fname=file.getName();
		       System.out.println("File checking : "+fname);
		       
		       if (fname.toLowerCase().contains(system_type)) {
		    	   System.out.println("File type ("+system_type+") matched. Checking content...");
		    	   try {
					Scanner scanner = new Scanner(file);
					while (scanner.hasNextLine()) {
						   final String lineFromFile = scanner.nextLine();
						   if(lineFromFile.contains(run_classname) && lineFromFile.contains("java")) { 
						       // a match!
						       System.out.println("Running new process " +run_classname+ " " +process_count + " times..");
						       for (int i=0;i<process_count;i++) {						    	   
							       try {
							    	   
							       	   run_cmd=run_cmd.replaceAll("XXX", fname);
							       	   System.out.println("Executiong : " +run_cmd);
							    	   Runtime.getRuntime().exec(run_cmd,envparams, new File(HomePath));   
							       } catch(Exception ex) {
							    	   System.out.println("Exception@ Runtime.getRuntime().exec : "+ex.getMessage());
							    	   ex.printStackTrace();
							       }
						    	   
						       }
						       return;
						   }
					} 
					scanner.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
		       }
		        
		    }
		}
		
		
	}

	
	
	//**********************************************
	void createDir(String dir) {
		File theDir = new File(dir);
		if (!theDir.exists()) {
		    boolean result = false;

		    try{
		        theDir.mkdir();
		        result = true;
		     } catch(SecurityException se){
		        //handle it
		     }        
		}
	}
	
	
	// *****************************************
	private void text2file(String text, String filepath) {
			BufferedWriter out = null;
			
			File f=new File(filepath);
			if (f.exists()) f.delete();
		
		try {
			out=new BufferedWriter(new OutputStreamWriter(new FileOutputStream(filepath),"UTF-8"));
			out.append(text);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {out.close();} catch(Exception e) {}
		}
	}
	
	
	
  //********************************************************

	private Runtime runtime = Runtime.getRuntime();

    public String Info() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.OsInfo());
        sb.append(this.MemInfo());
        sb.append(this.DiskInfo());
        return sb.toString();
    }

    public String OSname() {
        return System.getProperty("os.name");
    }

    public String OSversion() {
        return System.getProperty("os.version");
    }

    public String OsArch() {
        return System.getProperty("os.arch");
    }

    public long totalMem() {
        return Runtime.getRuntime().totalMemory();
    }

    public long usedMem() {
        return Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
    }

    public String MemInfo() {
        NumberFormat format = NumberFormat.getInstance();
        StringBuilder sb = new StringBuilder();
        long maxMemory = runtime.maxMemory();
        long allocatedMemory = runtime.totalMemory();
        long freeMemory = runtime.freeMemory();
        sb.append("Free memory                     : ");
        sb.append(format.format(freeMemory / 1024)+" MBs\n");
        sb.append("Allocated memory                : ");
        sb.append(format.format(allocatedMemory / 1024)+" MBs\n");
        sb.append("Max memory                      : ");
        sb.append(format.format(maxMemory / 1024)+" MBs\n");
        sb.append("Total free memory               : ");
        sb.append(format.format((freeMemory + (maxMemory - allocatedMemory)) / 1024)+" MBs\n");
        return sb.toString();

    }

    public String OsInfo() {
        StringBuilder sb = new StringBuilder();
        sb.append("Operation System                : ");
        sb.append(this.OSname());
        sb.append(" ");
        sb.append(this.OSversion());
        sb.append(" ");
        sb.append(this.OsArch());
        sb.append("\n");
        sb.append("Available processors (cores)    : ");
        sb.append(runtime.availableProcessors());
        sb.append("\n");
        return sb.toString();
    }

    public String DiskInfo() {
        /* Get a list of all filesystem roots on this system */
        File[] roots = File.listRoots();
        StringBuilder sb = new StringBuilder();
        NumberFormat format = NumberFormat.getInstance();

        /* For each filesystem root, print some info */
        for (File root : roots) {
            sb.append("\n----------------------------------------------------------\n");
            sb.append("File system root : ");
            sb.append(root.getAbsolutePath());
            sb.append("\n");
            sb.append("Total space      : ");
            sb.append(format.format(root.getTotalSpace() / 1024)+" MBs\n");
            sb.append("Free space       : ");
            sb.append(format.format(root.getFreeSpace() / 1024)+" MBs");
        }
        return sb.toString();
    }
    
	//*******************************************************
	public String encode(String a) {
		
		byte[]   bytesEncoded = Base64.encodeBase64(a.getBytes());

		return new String(bytesEncoded);
	}

	//*******************************************************
	public String decode(String a) {
		byte[] valueDecoded= Base64.decodeBase64(a);
		return new String(valueDecoded);
		
	}

	
	
	//************************************************
	public String getTablesForMaskApp(Connection conn, String app_id,String curr_tab_id) {
	//************************************************
	
	StringBuilder sb=new StringBuilder();
	
	String sql="select distinct id, concat(tab_name,'@',schema_name) tab  from tdm_tabs where app_id= " + app_id + " order by tab_name";
	
	ArrayList<String[]> bindlist=new  ArrayList<String[]>();
    ArrayList<String[]> tablistarr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
    
    
    for (int i=0;i<tablistarr.size();i++) {
		String tabid=tablistarr.get(i)[0];	
		String tabname=tablistarr.get(i)[1];
		String color="#FAFAFA";
		
		//if (Integer.parseInt(tabid)==Integer.parseInt(nvl(filter_tab_id,"0")))
		if (tabid.equals(curr_tab_id)) color="yellow";
		
		sb.append(
				"<tr bgcolor="+color+">"+
				"<td align=center><img src=\"delete.png\" border=0 width=12 height=12 onclick=removetable('"+tabid+"')><td>"+
				"<td align=center><img src=\"table.png\" border=0 width=12 height=12 onclick=showcontenbytabid('"+tabid+"')><td>"+
				"<td nowrap><b><a href=\"#\" onclick=opentab('"+tabid+"')>"+tabname+"</a></b><td>"+
				"<td align=center><img src=\"success.png\" border=0 width=12 height=12><td>"+
				"</tr>"
				);
	}

	
	return sb.toString();
	
	}
	
	//************************************************
	public String getTablesForCopyApp(Connection conn, String app_id,String curr_tab_id) {
	//************************************************
	
	StringBuilder sb=new StringBuilder();
	
	
	String sql="select distinct id, concat(tab_name,'@',schema_name) tab  from tdm_tabs where app_id= " + app_id + " order by tab_name";
	
	ArrayList<String[]> bindlist=new  ArrayList<String[]>();
    ArrayList<String[]> tablistarr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
    
    
    for (int i=0;i<tablistarr.size();i++) {
		String tabid=tablistarr.get(i)[0];	
		String tabname=tablistarr.get(i)[1];
		String color="#FAFAFA";
		
		//if (Integer.parseInt(tabid)==Integer.parseInt(nvl(filter_tab_id,"0")))
		if (tabid.equals(curr_tab_id)) color="yellow";
		
		sb.append(
				"<tr bgcolor="+color+">"+
				"<td align=center><img src=\"delete.png\" border=0 width=12 height=12 onclick=removetable('"+tabid+"')><td>"+
				"<td align=center><img src=\"table.png\" border=0 width=12 height=12 onclick=showcontenbytabid('"+tabid+"')><td>"+
				"<td nowrap><b><a href=\"#\" onclick=opentab('"+tabid+"')>"+tabname+"</a></b><td>"+
				"<td align=center><img src=\"success.png\" border=0 width=12 height=12><td>"+
				"</tr>"
				);
	}

	

	return sb.toString();
	
	}	
	
	//************************************************
	public String getChildTables(
			Connection conn, 
			HttpSession session, 
			String tab_id, 
			int level, 
			String filter,
			String filter_family_id
			) {
		StringBuilder sb=new StringBuilder();
		
		
		String sql=""+
			" select  "+
			" t.id, \n"+
			" concat(t.tab_name,'@',t.schema_name,' [',t.cat_name,']') tab, \n"+
			" t.tab_desc, \n"+
			" t.discovery_flag,\n"+
			" a.app_type ,\n"+
			" t.mask_level, \n" + 
			" tr.pk_fields,\n"+
			" tr.rel_on_fields, \n"+
			" tr.rel_type, \n"+
			" recursive_fields, \n" +
			" (select family_name from tdm_family f where f.id=family_id) family_name \n"+
			" from tdm_tabs t,  tdm_apps a, tdm_tabs_rel tr\n"+
			" where \n"+
			" t.app_id=a.id \n"+
			" TABNAMEFILTER \n"+
			" FAMILYIDFILTER \n"+
			" and t.id=tr.rel_tab_id\n"+
			" and t.id in (select rel_tab_id from tdm_tabs_rel where tab_id="+tab_id+")  \n"+
			" order by rel_order ";
		
		if (level==0) {
			sql="select  "+
				" t.id, "+
				" concat(tab_name,'@',schema_name,' [',t.cat_name,']') tab, "+
				" tab_desc, "+
				" discovery_flag, "+
				" app_type, "+
				" mask_level, "+
				" '' pk_fields, "+
				" '' rel_on_fields, "+
				" '' rel_type, "+
				" recursive_fields,   " +
				" (select family_name from tdm_family f where f.id=family_id) family_name " + 
				" from tdm_tabs t, tdm_apps a  where app_id= " + tab_id + 
				" TABNAMEFILTER \n"+
				" FAMILYIDFILTER\n " +
				" and t.id not in (select rel_tab_id from tdm_tabs_rel) " +
				" and t.app_id=a.id " + 
				" order by t.tab_order";
			
		}
		
		if (filter.length()>0) {
			String like_statatement=" and t.tab_name like '%"+filter+"%'";
			sql=sql.replaceAll("TABNAMEFILTER", like_statatement);
		}
		else 
			sql=sql.replaceAll("TABNAMEFILTER", "");
		
		if (!nvl(filter_family_id,"0").equals("0")) {
			String statatement=" and t.family_id="+filter_family_id;
			sql=sql.replaceAll("FAMILYIDFILTER", statatement);
		}
		else 
			sql=sql.replaceAll("FAMILYIDFILTER", "");
		
		
		System.out.println(sql);
		
		
		ArrayList<String[]> bindlist=new  ArrayList<String[]>();
	    //ArrayList<String[]> tablistarr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	    ArrayList<String[]> tablistarr=getDbArrayConf(conn, sql, 500, bindlist);
		
	    int tab_count=tablistarr.size();
		
	    
	    if (level ==0 && tab_count==500) {
	    	
	    	sb.append("<div class=\"alert alert-info\" role=\"alert\">"+
	    				"Cool! At least "+tab_count+ " tables in the application!!. "+
	    				" Maybe more. filter to see yours if it's not here." + 
	    				"</div>");
	    }
	    
	    sb.append("<ul>");
	    
	    
	    
	   String hide_needed_tables=nvl((String) session.getAttribute("hide_needed_tables"),"");
	    
	    for (int i=0;i<tablistarr.size();i++) {
			String tabid=tablistarr.get(i)[0];	
			String tabname=tablistarr.get(i)[1];
			String tabdesc=tablistarr.get(i)[2];
			String discovery_flag=nvl(tablistarr.get(i)[3],"YES");
			String app_type=tablistarr.get(i)[4];
			String mask_level=tablistarr.get(i)[5];
			String pk_fields=tablistarr.get(i)[6];
			String fk_fields=tablistarr.get(i)[7];
			String rel_type=tablistarr.get(i)[8];
			String recursive_fields=tablistarr.get(i)[9];
			String db_family=nvl(tablistarr.get(i)[10],"?");

			
			
			
			sb.append("<li>");

			if (level==0) 
				sb.append("<span id=roottable></span>");
			
			String discovery_icon="glyphicon glyphicon-eye-open";
			String new_discovery_flag="NO";
			String discovery_class="btn-success";
			String disccolor="black";
			String disabled="";
			
			if (discovery_flag.equals("NO")) {
				discovery_icon="glyphicon glyphicon-eye-close";
				new_discovery_flag="YES";
				discovery_class="btn-warning";
				disccolor="gray";
				disabled="disabled";
			}
			
			
			if (app_type.equals("COPY")) 
				sb.append("<input "+disabled+" type=radio name=selecttable id=selecttable value=\""+tabid+"\">");
			
			String cat="";
			String owner="";
			String table="";
			
			try {cat=tabname.split("\\[")[1].split("\\]")[0];} catch(Exception e) {}
			try {table=tabname.split("\\[")[0].split("@")[0];} catch(Exception e) {}
			try {owner=tabname.split("\\[")[0].split("@")[1];} catch(Exception e) {}
			
			if (app_type.equals("DMASK")) {
				sb.append("<span id=exception_TABLE_"+tabid+">");
				sb.append(makeExceptionButton(conn, session, "TABLE",tabid));
				sb.append("</span> ");
			}
	
			sb.append(" <span class=\"glyphicon glyphicon-list-alt\" onclick=showcontentbytabid('"+tabid+"')></span>");

			sb.append(" <a href=\"javascript:openTableScriptDetails(curr_env_id, '"+tabid+"')\">");
			if (app_type.equals("COPY"))
				if (cat.equals("${default}"))
					sb.append("&nbsp;<font color="+disccolor+"><b><font color=blue>"+owner+"</font>."+table + "<font color=green>@"+db_family+"</font></b></font>&nbsp;");
				else 
					sb.append("&nbsp;<font color="+disccolor+"><b>[<font color=darkgreen>"+cat+"</font>].<font color=blue>"+owner+"</font>."+table + "<font color=green>@"+db_family+"</font></b></font>&nbsp;");
			else 
				if (cat.equals("${default}"))
					sb.append("&nbsp;<font color="+disccolor+"><b><font color=blue>"+owner+"</font>."+table + "</b></font>&nbsp;");
				else 
					sb.append("&nbsp;<font color="+disccolor+"><b>[<font color=darkgreen>"+cat+"</font>].<font color=blue>"+owner+"</font>."+table + "</b></font>&nbsp;");
			
			sb.append("</a>");
			
			if (recursive_fields.length()>0) {
				sb.append("<font color=#DA4AA1>");
				sb.append("<span class=\"glyphicon glyphicon-repeat\" data-toggle=\"popover\" title=\"Recursive Copy\"></span>");
				sb.append("</font>");
			}
			
			
			
			sb.append(
					"  <a href=\"javascript:removeTableFromApp('"+tabid+"')\">"+
					"    <font color=red><span class=\"glyphicon glyphicon-remove\"></span></font>"+
					"  </a>"
					);

		


			if (app_type.equals("COPY")) {
				
				sb.append(" ");
				
				if (level>0) {
					if (i>0)
						sb.append("<font color=orange><span class=\"glyphicon glyphicon-chevron-up\" onclick=\"reorderTableRelInApp('"+tabid+"','UP');\"></font>");
					
					if (i<tablistarr.size()-1)
						sb.append("<font color=orange><span class=\"glyphicon glyphicon-chevron-down\" onclick=\"reorderTableRelInApp('"+tabid+"','DOWN');\"></font>");

					if (tablistarr.size()>10) 
						sb.append(" <font color=#ff33cc><span class=\"glyphicon glyphicon-indent-left\" onclick=\"setCopyTableOrder('"+tabid+"');\"></font>");
						
				}
				else {
					if (i>0)
						sb.append("<font color=orange><span class=\"glyphicon glyphicon-chevron-up\" onclick=\"reorderTable('"+tabid+"','UP');\"></font>");
	
					if (i<tablistarr.size()-1)
						sb.append("<font color=orange><span class=\"glyphicon glyphicon-chevron-down\" onclick=\"reorderTable('"+tabid+"','DOWN');\"></font>");

					if (tablistarr.size()>10) 
						sb.append(" <font color=#ff33cc><span class=\"glyphicon glyphicon-indent-left\" onclick=\"setCopyTableOrder('"+tabid+"');\"></font>");
					
				}
			}

			
			if (app_type.equals("MASK")) {
						String checked="";	
						String color="white";
						if (mask_level.equals("DELETE")) {
							checked="checked";
							color="#DADADA";
						}
							
						sb.append("  <span style=\"background-color:"+color+";\">");
						sb.append(" <input type=checkbox "+checked+" id=ch_mask_level_"+tabid+" onclick=changeMaskLevel("+tabid+")> <b> Empty This Table</b>");
						sb.append("</span>");
						}

			if (level>0) {
				
				
						


				sb.append("&nbsp;<span class=\"glyphicon "+discovery_icon+"\" onclick=changeDiscoveryFlag('"+ tabid +"','"+new_discovery_flag+"')></span>&nbsp;");
				
				
				if (level>0) {
					
					
					String rel_icon="glyphicon glyphicon-certificate";
					if (rel_type.equals("HAS")) rel_icon="glyphicon glyphicon-arrow-right";
					
					String rel_stmt="&nbsp;"+
							"<b><font color=blue><span class=\""+rel_icon+"\"></span></font></b>&nbsp;"+ 
							"<font size=2 color=gray>"+
							"["+pk_fields+"]"+
							"<font color=green><span class=\"glyphicon glyphicon-random\"></span></font>"+
							"["+ fk_fields+ "]"+
							"</font>";
					
						sb.append(rel_stmt);
				}
				
				
			}
				
			
			
			if (app_type.equals("COPY") && !hide_needed_tables.equals("checked")) 
				sb.append(makeTableNeedList(conn, tabid, true));
			
			
						
			

			sb.append("</li>");
			
			sb.append(getChildTables(conn, session, tabid, level+1, filter, filter_family_id));
		}
	    
	    
	    sb.append("</ul>");


	    
		return sb.toString();
	}
	
	//************************************************
	String makeCopyTableOrderDlg(Connection conn, HttpSession session, String tab_id) {
		StringBuilder sb=new StringBuilder();
		
		String sql="";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		sql="select tab_id from tdm_tabs_rel where rel_tab_id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",tab_id});
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
		int parent_tab_id=0;
		
		
		if (arr.size()>0) 
			parent_tab_id=Integer.parseInt(arr.get(0)[0]);

		sql="select app_id,schema_name, tab_name from tdm_tabs t where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",tab_id});
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		int app_id=0;
		String curr_schema_name="";
		String curr_tab_name="";
		
		if (arr.size()>0) {
			app_id=Integer.parseInt(arr.get(0)[0]);
			curr_schema_name=arr.get(0)[1];
			curr_tab_name=arr.get(0)[2];
		}
		
		
		if (parent_tab_id==0) {
			sql="select id, concat(tab_name, '@', schema_name)  "+
					" from tdm_tabs t where app_id=? and id!=? "+
					" and not exists (select 1 from tdm_tabs_rel where rel_tab_id=t.id) " +
					" order by tab_order";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+app_id});
			bindlist.add(new String[]{"INTEGER",""+tab_id});
		}
		else {
			sql="select t.id, concat(t.tab_name, '@', t.schema_name)  "+
					" from tdm_tabs t " + 
					" where t.app_id=? and t.id!=? "+
					" and t.id in (select rel_tab_id from tdm_tabs_rel where tab_id=?) " +
					" order by tab_order";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+app_id});
			bindlist.add(new String[]{"INTEGER",""+tab_id});
			bindlist.add(new String[]{"INTEGER",""+parent_tab_id});
		}
		
		
		ArrayList<String[]> tabList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		sb.append("<h4><b>"+curr_schema_name+"."+curr_tab_name+"</b> set order after </h4>");	
		
		sb.append("<input type=hidden id=ordering_tab_id value="+tab_id+">");
		sb.append("<input type=hidden id=set_after_parent_tab_id value="+parent_tab_id+">");

		
		sb.append(makeComboArr(tabList, "", "id=set_after_tab_id", "", 0));

		
		
		
		return sb.toString();
	}
	
	//************************************************
	void setCopyTableOrderDo(
			Connection conn,
			HttpSession session,
			String tab_id,
			String set_after_tab_id,
			String set_after_parent_tab_id
			) {
		String sql="";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		sql="select app_id, tab_order from tdm_tabs where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",set_after_tab_id});
		
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		int app_id=0;
		int tab_order=0;
		
		try{app_id=Integer.parseInt(arr.get(0)[0]);} catch(Exception e) {}
		try{tab_order=Integer.parseInt(arr.get(0)[1]);} catch(Exception e) {}
		
		if (tab_order==0) {
			System.out.println("sss");
			return;
		}
		
		if (set_after_parent_tab_id.equals("0")) {
			sql="select id  "+
					" from tdm_tabs t where app_id=?  "+
					" and not exists (select 1 from tdm_tabs_rel where rel_tab_id=t.id) " +
					" order by tab_order";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+app_id});

		}
		else {
			sql="select t.id   "+
					" from tdm_tabs t " + 
					" where t.app_id=? "+
					" and t.id in (select rel_tab_id from tdm_tabs_rel where tab_id=?) " +
					" order by tab_order";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+app_id});
			bindlist.add(new String[]{"INTEGER",""+set_after_parent_tab_id});
		}
		
		
		ArrayList<String[]> tabList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		sql="update tdm_tabs set tab_order=? where id=?";
		if (!set_after_parent_tab_id.equals("0")) 
			sql="update tdm_tabs_rel set rel_order=? where rel_tab_id=?"; 
		
		
		int order=0;
		
		for (int i=0;i<tabList.size();i++) {
			String id=tabList.get(i)[0];
			
			if (id.equals(tab_id)) continue;
			
			if (id.equals(set_after_tab_id)) {
				order++;
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+order});
				bindlist.add(new String[]{"INTEGER",id});
				execDBConf(conn, sql, bindlist);
				
				System.out.println("set id "+id+"="+order);
				
				order++;
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+order});
				bindlist.add(new String[]{"INTEGER",tab_id});
				execDBConf(conn, sql, bindlist);
				

				
				continue;
			}
			
			order++;
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+order});
			bindlist.add(new String[]{"INTEGER",id});
			execDBConf(conn, sql, bindlist);
			
			System.out.println("set id "+id+"="+order);

			
		}
		
	}
	
	//************************************************
	void changeTableOrder(Connection conn, HttpSession session, String app_id, String changing_tab_order, String before_tab_order) {
		String sql="select id, tab_order from tdm_tabs where app_id=? order by tab_order";
			
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",app_id});
		
		ArrayList<String[]> tabArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		int INT_changing_tab_order=Integer.parseInt(changing_tab_order);
		int INT_before_tab_order=Integer.parseInt(before_tab_order);
		
		for (int i=0;i<tabArr.size();i++) {
			String[] arr=tabArr.get(i);
			
			int tab_order=Integer.parseInt(arr[1]);
			
			if (tab_order==INT_changing_tab_order) {
				arr[1]=""+INT_before_tab_order;
				tabArr.set(i, arr);
				continue;
			}
			if (tab_order>=INT_before_tab_order) {
				arr[1]=""+(tab_order+1);
				tabArr.set(i, arr);
				continue;
			}
			
			
		}
		
		sql="update tdm_tabs set tab_order=? where id=?";
		
		
		for (int i=0;i<tabArr.size();i++) {
			String[] arr=tabArr.get(i);
			int tab_id=Integer.parseInt(arr[0]);
			int tab_order=Integer.parseInt(arr[1]);
			
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",""+tab_order});
			bindlist.add(new String[]{"INTEGER",""+tab_id});
			
			execDBConf(conn, sql, bindlist);
			

		}
		
	}
	
	//************************************************
	String makeTableNeedList(Connection conn,  String tabid, boolean readonly) {
		
		StringBuilder sb=new StringBuilder();
		
		String sql="select n.id, n.app_id, a.name application_name, rel_on_fields, filter_name \n"+
				"	from tdm_tabs_need n, tdm_copy_filter f,  tdm_apps a \n"+
				"	where  n.tab_id=? \n"+
				"	and n.app_id=a.id and copy_filter_id=f.id";
			
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",tabid});
			
			
			
		ArrayList<String[]> needArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		if (readonly && needArr!=null && needArr.size()==0) 
			return "";
		
		if (!readonly)
			sb.append("<a href=\"javascript:discoverCopy('"+tabid+"','NEED')\"><span class=\"glyphicon glyphicon glyphicon-eye-open\"></span> discover</a>");
			
		sb.append("<table border=1 cellspacing=0 cellpadding=0>");
		
		sb.append("<tr bgcolor=#C6C6A9>");
		sb.append("<td><b>Needs</b></td>");
		sb.append("<td><b>Filter</b></td>");
		sb.append("<td><b>Field </b></td>");

		if (!readonly) {
			sb.append("<td align=center>");
			sb.append(" <font color=green><span class=\"glyphicon glyphicon-plus\" onclick=\"addTableNeed('"+tabid+"')\"></span></font> ");
			sb.append("</td>");
		}
			
		
		sb.append("</tr>");
		
		if (needArr.size()>0) {
			for (int n=0;n<needArr.size();n++) {
				
				String need_id=needArr.get(n)[0];
				String need_app_id=needArr.get(n)[1];
				String need_application_name=needArr.get(n)[2];
				String rel_on_fields=needArr.get(n)[3];
				String filter_name=needArr.get(n)[4];
				
				sb.append("<tr>");


				sb.append("<td><small>");
				sb.append("<font color=blue><span class=\"glyphicon glyphicon-share-alt\" onclick=openAppById('"+need_app_id+"')></span></font> ");
				if (readonly) 
					sb.append("<b>"+need_application_name+"</b>");
				else
					sb.append("<a href=\"javascript:editTableNeed('"+tabid+"', '"+need_id+"')\"><b>"+need_application_name+"</b></a>");
				sb.append("</small></td>");

				sb.append("<td><small>"+filter_name+"</small></td>");
				sb.append("<td><small>"+rel_on_fields+"</small></td>");
				

				if (!readonly) {
					sb.append("<td nowrap align=center><small>");
					sb.append(" <font color=red><span class=\"glyphicon glyphicon-minus\" onclick=\"removeTableNeed('"+tabid+"', '"+need_id+"')\"></span></font> ");
					sb.append("</small></td>");
				}
				
				

				sb.append("</tr>");
				
			}
			
		}
		sb.append("</table>");
		
		return sb.toString();
	}
	
	//*************************************************
	public void changeMaskLevel(Connection conn, String tab_id, String mask_level) {
		String sql="update tdm_tabs set mask_level='"+mask_level+"' where id="+tab_id;
		execDBConf(conn, sql, new ArrayList<String[]>());
	}

	
	//************************************************
	public String getTabConfigForMaskApp(
			Connection conn, 
			String filter_tab_id,
			String table_title, 
			String mask_level, 
			String tab_filter, 
			String filter_validation_message,
			String parallel_mod,
			String parallel_field,
			String mode_validation_message) {
	//************************************************
	
	String html="";
	String sql="";
	
	html=html+""+
            "<tr bgcolor=#FFDDAA>"+
            "<td align=center>"+
            "<b>" +table_title+ "</b>"+
            "</td>"+
            "</tr>";
	
    sql="select 'FIELD' f1,'Field Based Masking' f2 from dual  union all select 'RELATION' f1,'Record Based Masking' f2 from dual";


    html=html+""+
        "<tr>"+
        "<td align=left>Mask Level<br>"+
        makeCombo(conn, sql, "mask_level", "id=mask_level size=2 onchange=\"return change_mask_level("+filter_tab_id+");\" ", nvl(mask_level,"-"), 200)+
        "</td>"+
        "</tr>";

        
        
        html=html+""+
        "<tr>"+
        "<td align=left> Filter : <font color=red><b>" + filter_validation_message + "</b></font>"+
        "<br>"+
        "<textarea name=tab_filter id=tab_filter cols=25 rows=3>" +
        tab_filter +
        "</textarea>"+
        "</td>"+
        "</tr>";


		html=html+""+
		"<tr>"+
        "<td align=left nowrap>Partitioning Info :";

        sql="" +
                " select '1' f1, '1' f2 from dual union all " +
                " select '2' f1, '2' f2 from dual union all " +
                " select '3' f1, '3' f2 from dual union all " +
                " select '5' f1, '5' f2 from dual union all " +
                " select '8' f1, '8' f2 from dual union all " +
                " select '10' f1, '10' f2 from dual union all " +
                " select '15' f1, '15' f2 from dual union all " +
                " select '20' f1, '20' f2 from dual union all " +
                " select '30' f1, '30' f2 from dual union all " +
                " select '50' f1, '50' f2 from dual union all " +
                " select '100' f1, '100' f2 from dual union all " +
                " select '200' f1, '200' f2 from dual union all " +
                " select '500' f1, '500' f2 from dual union all " +
                " select '1000' f1, '1000' f2 from dual union all " +
                " select '10000' f1, '10000' f2 from dual union all " +
                " select '50000' f1, '50000' f2 from dual ";

            html=html + makeCombo(conn, sql, "parallel_mod", "  ", nvl(parallel_mod,"0"), 80);


    html=html+""+
        "<br>Using : <font color=red><b>" + mode_validation_message + "</b></font>"+
         "<br>"+
        "<font color=blue><b>mod(</b></font>"+
        "<input type=text maxlength=100 name=parallel_field value=\""+parallel_field+"\">"
        +"<font color=red><b>,?)</b></font>"+
        "<br><a href=\"#\" onclick=sampleformulas();>sample</a>";

    html=html+""+
        "</td>"+
        "</tr>";
	
	
	
	
	
	
	return html;
	
	}
	
	//************************************************
	public String getTabConfigForCopyApp(
			Connection conn, 
			String filter_tab_id,
			String table_title, 
			String mask_level, 
			String tab_filter, 
			String filter_validation_message
			)  {
	//************************************************
	
	
	String html="";
	String sql="";
	
	html=html+""+
            "<tr bgcolor=#FFDDAA>"+
            "<td align=center>"+
            "<b>" +table_title+ "</b>"+
            "</td>"+
            "</tr>";
	
    sql="select 'FIELD' f1,'Field Based Masking' f2 from dual  union all select 'RELATION' f1,'Record Based Masking' f2 from dual";


    html=html+""+
        "<tr>"+
        "<td align=left>Mask Level<br>"+
        makeCombo(conn, sql, "mask_level", "id=mask_level size=2 onchange=change_mask_level("+filter_tab_id+"); ", nvl(mask_level,"-"), 200)+
        "</td>"+
        "</tr>";

        
        
        html=html+""+
        "<tr>"+
        "<td align=left> Filter : <font color=red><b>" + filter_validation_message + "</b></font>"+
        "<br>"+
        "<textarea name=tab_filter id=tab_filter cols=25 rows=3>" +
        tab_filter +
        "</textarea>"+
        "</td>"+
        "</tr>";

	
	return html;
			
	
	}		
	
//*************************************************
public String getFieldRow(
			Connection conn,
			HttpSession session,
			String db_type,
			String app_type,
			String field_id,
			String field_name,
			String field_type,
			String field_size,
			String is_pk,
			String mask_prof_id,
			String calc_prof_id,
			String condition_expr,
			String is_conditional,
			String list_field_name,
			ArrayList<String[]> profArr,
			boolean field_ok
		) {
	StringBuilder sb=new StringBuilder();

	boolean is_mongo=false;
	if (db_type.toUpperCase().contains("MONGO")) is_mongo=true;

	
	String tr_class="default";
	if (is_pk.equals("YES")) tr_class="success";
	if (is_conditional.equals("YES") || Integer.parseInt(nvl(mask_prof_id,"0"))>0) tr_class="warning";
	if (!field_ok) tr_class="danger";
	if (field_type.equals("CALCULATED")) tr_class="info";
	
	sb.append("<td align=center class=\""+tr_class+"\">");
		
	if (field_ok && !field_type.equals("CALCULATED"))
		sb.append("<span class=\"glyphicon glyphicon-ok-circle\"></span>");
	else
		sb.append(
				"<button type=\"button\" class=\"btn btn-danger btn-sm\"  onclick=changeFieldConfig('"+field_id+"','delete','x')> "+
					"<span class=\"glyphicon glyphicon-trash\"></span>"+
				"</button>"
				);
		
	sb.append("</td>");		
	
	
	
	sb.append("<td align=center class=\""+tr_class+"\">");
	if (is_pk.equals("YES")) {
		sb.append("<button type=\"button\" class=\"btn btn-danger btn-sm\" onclick=changeFieldConfig('"+field_id+"','is_pk','NO')>");
		sb.append("<span class=\"glyphicon glyphicon-star\"></span>");
		sb.append("</button>");
	}
	else if (!field_type.equals("CALCULATED") && !field_type.equals("NODE") &  !(is_mongo && field_name.contains("."))) 
	{
		sb.append("<button type=\"button\" class=\"btn btn-default btn-sm\" onclick=changeFieldConfig('"+field_id+"','is_pk','YES')>");
		sb.append("<span class=\"glyphicon glyphicon-star-empty\"></span>");
		sb.append("</button>");
	}
	sb.append("</td>");

	sb.append("<td nowrap class=\""+tr_class+"\"><font size=2>");
	if (app_type.equals("DMASK")) {
		sb.append("<span id=exception_COLUMN_"+field_id+">");
		sb.append(makeExceptionButton(conn, session, "COLUMN",field_id));
		sb.append("</span> ");
	}
	sb.append(field_name);
	sb.append("</td>");

	if (field_type.equals("CALCULATED")) {
		sb.append("<td class=\""+tr_class+"\">");
		sb.append("<font size=2>[Calculated]</font>");
		sb.append("</td>");
	}
	else 
		sb.append("<td class=\""+tr_class+"\"><font size=2>"+field_type+"(<b>"+field_size+"<b>)"+"</font></td>");
	
	
	if (!app_type.equals("DMASK")) {
		
	
		if ( is_pk.equals("YES") && app_type.equals("MASK")) {
			sb.append("<td  colspan=3 class=\""+tr_class+"\" align=center>");
			sb.append("");
			sb.append("</td>");	
		}
		else
		{
			sb.append("<td class=\""+tr_class+"\" align=center>");
		
			if (is_mongo && !field_type.equals("ENTITY")) {
				sb.append("");
			} else {
				if (is_conditional.equals("YES")) 
					sb.append("<input type=checkbox checked id=is_conditional name=is_conditional onclick=changeFieldConfig('"+field_id+"','is_conditional','NO')>");						
				else 
					sb.append("<input type=checkbox id=is_conditional name=is_conditional onclick=changeFieldConfig('"+field_id+"','is_conditional','YES')>");	
			}
			
			sb.append("</td>");
		}
	} //if (!app_type.equals("DMASK")) 
	
	
	
	
	

	sb.append("<td nowrap align=left class=\""+tr_class+"\" >");
	
	if ((is_pk.equals("YES") && app_type.equals("MASK")))
		sb.append("");
	else
	{
		if (is_conditional.equals("YES")) {
			sb.append("<td colspan=2  class=\""+tr_class+"\" align=left>");
			sb.append("<button type=\"button\" class=\"btn btn-default btn-sm\" onclick=openConditionEditor('"+field_id+"','"+field_name+"','','')>");
			sb.append("	<font color=orange><span class=\"glyphicon glyphicon-edit\"></span></font>");
			sb.append(" Edit Condition ");
			sb.append("</button>");
			sb.append("</td>");
		}
		else if (is_mongo && !field_type.equals("ENTITY")) {
			sb.append("<td colspan=2  class=\""+tr_class+"\" align=left>");
			sb.append("");
			sb.append("</td>");
		}
		else {
			
			sb.append("<td nowrap colspan=2 align=left class=\""+tr_class+"\" >");
			sb.append("<table border=0 cellspacing=0 cellpadding=0>");
			
			if (field_type.equals("CALCULATED")) {
				sb.append("<tr>");
				sb.append("<td colspan=2 nowrap  class=\""+tr_class+"\" align=left>");
				sb.append("<button class=\"btn btn-default btn-sm\" onclick=pickProfile('"+field_id+"','"+calc_prof_id+"','CALC')><font color=blue><span class=\"glyphicon glyphicon-flash\"></span></font></button>");
				
				if (!calc_prof_id.equals("0")) {
					sb.append("<button class=\"btn btn-default btn-sm\" onclick=changeFieldConfig('"+field_id+"','calc_prof_id','')><font color=red><span class=\"glyphicon glyphicon-remove\"></span></font></button>");
					String sql_stmt=getDBSingleVal(conn, "select js_code from tdm_mask_prof where id="+calc_prof_id);
					if (sql_stmt.length()>50) sql_stmt=sql_stmt.substring(0, 49)+"...";
					sb.append(" <p><b>[</b><small><small>"+sql_stmt.replaceAll("\n|\r", "<br>")+"</small></small><b>]</b></p>");
				}
				
				sb.append("</td>");
				sb.append("<tr>");
			}
			
			sb.append("<tr>");
			
			sb.append("<td nowrap align=left class=\""+tr_class+"\" >");
			sb.append("<button class=\"btn btn-default btn-sm\" onclick=pickProfile('"+field_id+"','"+mask_prof_id+"','"+app_type+"')><span class=\"glyphicon glyphicon-list-alt\"></span></button>");
			if (!mask_prof_id.equals("0"))
				sb.append("<button class=\"btn btn-default btn-sm\" onclick=changeFieldConfig('"+field_id+"','mask_prof_id','')><font color=red><span class=\"glyphicon glyphicon-remove\"></span></font></button>");
			sb.append("</td>");
			
			if (!mask_prof_id.equals("0")) {
				
				
				String mask_prof_name="";
				String mask_rule_id="";
				
				String curr_list_field_name="";
				String curr_list_field_fixed="";
				
				
				String sql="select if(run_on_server='YES',concat(name,' (*) '),name) , rule_id from tdm_mask_prof where id=?";
				
				ArrayList<String[]> bindlist=new ArrayList<String[]>();
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+mask_prof_id});
				
				ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
				
				if (arr==null || arr.size()==0) mask_prof_name="! Mask Profile Not Found!...";
				else {
					mask_prof_name=arr.get(0)[0];
					mask_rule_id=arr.get(0)[1];
				}
					

				try {
					curr_list_field_name=list_field_name.split(":")[0];
					curr_list_field_fixed=list_field_name.split(":")[1];
					} catch(Exception e) {
						curr_list_field_name=list_field_name;
						curr_list_field_fixed="";
					}
				
				sb.append("<td>");
				sb.append("[<small>"+mask_prof_name+"</small>]");
				sb.append("</td>");
				
				if (mask_rule_id.equals("HASHLIST"))
					sb.append(makeListFieldNameCombo(conn, mask_prof_id, field_id, curr_list_field_name, curr_list_field_fixed, "NON_CONDITON", "", 200 ));
				
				if (mask_rule_id.equals("COPY_REF"))
					sb.append(makeCopyRefFields(conn, field_id));
				
			}
			
			
			sb.append("</tr>");
			

			sb.append("</table>");
			sb.append("</td>");
			

		}
		
		
	}
	
	
	
	
	return sb.toString();

}

//-----------------------------------------------------------------------------------
String makeCopyRefFields(Connection conn, String field_id) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select app_id, tab_id, copy_ref_tab_id, copy_ref_field_name "+
				" from tdm_fields f, tdm_tabs t, tdm_apps a "+
				" where f.id=? "+
				" and t.id=f.tab_id "+
				" and a.id=t.app_id ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",field_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String app_id=arr.get(0)[0];
	String tab_id=arr.get(0)[1];
	String copy_ref_tab_id=nvl(arr.get(0)[2],"0");
	String copy_ref_field_name=arr.get(0)[3];
	
	
	//sql="select id, concat(schema_name, '.', tab_name) from tdm_tabs where app_id=? order by 2";
	sql="select id, concat(schema_name, '.', tab_name) from tdm_tabs where app_id=? \n"+
		" UNION ALL \n"+
		"select  t.id, concat('* ',schema_name,'.',tab_name,' [',a.name,']') app_name \n"+
		"	from tdm_apps a, tdm_tabs t where t.app_id=a.id and app_type='COPY' \n"+
		//"	and not exists (select 1 from tdm_tabs_rel tr where tab_id=t.id) \n"+ //parenti olmayan
		"	and not exists (select 1 from tdm_tabs_rel tr where rel_tab_id=t.id) \n"+ //hicbirseye child olmayan
		//"	and app_id in (select app_id from tdm_tabs_need where tab_id in (select id from tdm_tabs where app_id=?))"+
		"";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	//bindlist.add(new String[]{"INTEGER",app_id});

	ArrayList<String[]> listOfTabs=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	sb.append("<td>");
	sb.append(makeComboArr(listOfTabs, "", "id=copy_ref_tab_id onchange=\"changeCopyRefTable(this, '"+field_id+"');\" ", copy_ref_tab_id, 200));
	sb.append("</td>");
	
	
	sb.append("<td>");
	sb.append("<div id=divCopyRefFieldOf"+field_id+">");
	sb.append(makeCopyFieldNameCombo(conn, field_id, copy_ref_tab_id));
	sb.append("</div>");
	sb.append("</td>");
	
	
	
	return sb.toString();
}


//-----------------------------------------------------------------------------------
void changeCopyRefTable(Connection conn, HttpSession session, String field_id, String curr_copy_ref_tab_id) {
	String sql="update tdm_fields set copy_ref_tab_id=?, copy_ref_field_name=null where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",curr_copy_ref_tab_id});
	bindlist.add(new String[]{"INTEGER",field_id});
	
	execDBConf(conn, sql, bindlist);
}


//-----------------------------------------------------------------------------------
String makeCopyFieldNameCombo(Connection conn, String field_id, String copy_ref_tab_id ) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select  copy_ref_field_name   from tdm_fields  where id=? ";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",field_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String copy_ref_field_name=arr.get(0)[0];
	
	sql="select  field_name from tdm_fields where tab_id=? and is_pk='YES'  ";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",copy_ref_tab_id});
	
	ArrayList<String[]> listOfFields=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append(makeComboArr(listOfFields, "", "id=copy_ref_field_name onchange=\"changeCopyRefField(this,'"+field_id+"')\"", copy_ref_field_name, 200));
	
	return sb.toString();
	
}

//-----------------------------------------------------------------------------------
void changeCopyRefFieldName(Connection conn, HttpSession session, String field_id, String copy_ref_field_name) {
	String sql="update tdm_fields set copy_ref_field_name=? where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",copy_ref_field_name});
	bindlist.add(new String[]{"INTEGER",field_id});
	
	execDBConf(conn, sql, bindlist);
}

//-----------------------------------------------------------------------------------
String makeApplicationList(
		Connection conn, 
		String dis_wp_id, 
		String disc_id, 
		String table_name, 
		String disc_env_id, 
		String disc_app_id
		) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select id, name from tdm_apps where app_type in (select app_type from tdm_apps where id=?) order by 2";
	bindlist.add(new String[]{"INTEGER",disc_app_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<table class=\"table table-condensed\">");
	for (int i=0;i<arr.size();i++) {
		String app_id=arr.get(i)[0];
		String app_name=arr.get(i)[1];
		
		sql="select 1 from tdm_tabs where app_id=? and concat(cat_name,'.',schema_name,'.',tab_name)=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",app_id});
		bindlist.add(new String[]{"STRING",table_name});
		
		ArrayList<String[]> checkArr=getDbArrayConf(conn, sql, 1, bindlist);
		
		
		
		String tr_class="";
		if (checkArr.size()==1) tr_class="danger";
		
		String onclick_script="addTableToAppFromDisMask('"+dis_wp_id+"','"+disc_id+"','"+table_name+"','"+disc_env_id+"','"+app_id+"')";
		
		sb.append("<tr class="+tr_class+">");
		sb.append("<td>"+app_name+"</td>");
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm\" onclick=" +onclick_script+ ">");
		sb.append("<span class=\"glyphicon glyphicon-plus\"> Add to application</span>");
		sb.append("</button>");
		sb.append("</td>");
		sb.append("</tr>");
	}
	
	
	sb.append("</table>");
	
	
	return sb.toString();
}


//-----------------------------------------------------------------------------------
public String makeListFieldNameCombo(
		Connection conn, 
		String mask_prof_id, 
		String field_id, 
		String curr_list_field_name,
		String curr_list_field_fixed,
		String source,
		String condition_id,
		int len) {
	
	String is_fixed="NO";
	if (curr_list_field_fixed.equals("FIXED")) 
		is_fixed="YES";

	String html="";
	String sql="select l.title_list from tdm_list l, tdm_mask_prof p " +
			"	where l.id=src_list_id and src_list_id>0 " +
			"	and p.id=" + nvl(mask_prof_id,"-1") + 
			"	and title_list like '%|::|%' "+
			" and rule_id!='KEYMAP'";
	ArrayList<String[]> listArr=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>());
	if (listArr.size()>0) {
		String[] list_title=listArr.get(0)[0].split("\\|::\\|");
		
		ArrayList<String[]> arr=new ArrayList<String[]>();
		for (int f=0;f<list_title.length;f++)
			if (list_title[f].trim().length()>0)
        arr.add(new String[]{list_title[f],list_title[f]});
        
		if (source.equals("CONDITION")) {
			if(condition_id.equals("0")) {
				html = html +  makeComboArr(arr, "", "id=condition_list_field_name_"+condition_id+" onchange=openConditionEditor(curr_condition_field_id,curr_condition_field_name,'list_field_name_0',document.getElementById('condition_list_field_name_"+condition_id+"').value)", curr_list_field_name,len);	
		        if (is_fixed.equals("YES"))
		        	html = html + " <input checked id=condition_list_field_fixed_"+condition_id+" type=checkbox value=\"YES\" onclick=openConditionEditor(curr_condition_field_id,curr_condition_field_name,'list_field_fixed_0','')>";
		        else
		        	html = html + " <input id=condition_list_field_fixed_"+condition_id+" type=checkbox value=\"YES\" onclick=openConditionEditor(curr_condition_field_id,curr_condition_field_name,'list_field_fixed_0','FIXED')>";
		        html=html+" Fixed";
			}
			else
			{
				
				html = html +  makeComboArr(arr, "", "id=condition_list_field_name_"+condition_id+" onchange=saveCondition("+condition_id+")", curr_list_field_name,len);	
				if (is_fixed.equals("YES"))
		        	html = html + " <input id=condition_list_field_fixed_"+condition_id+" checked type=checkbox value=\"YES\" onclick=saveCondition("+condition_id+")>";
		        else
		        	html = html + " <input id=condition_list_field_fixed_"+condition_id+" type=checkbox value=\"YES\" onclick=saveCondition("+condition_id+")>";
		        html=html+" Fixed";
		        
			}
			
		}
		else 
		{
			html=html+"<td>";
			html = html + "&nbsp;"+ makeComboArr(arr, "", "onchange=changeFieldConfig('"+field_id+"','list_field_name',this.value)", curr_list_field_name,len);	
			html=html+"</td>"; 
			html=html+"<td>";
			if (is_fixed.equals("YES"))
	        	html = html + "&nbsp;<input checked type=checkbox value=\"YES\" onclick=changeFieldConfig('"+field_id+"','list_field_name_fixed','')>";
	        else
	        	html = html + "&nbsp;<input type=checkbox value=\"YES\" onclick=changeFieldConfig('"+field_id+"','list_field_name_fixed',':FIXED')>";
        	 html=html+"&nbsp;Fixed";
        	 html=html+"</td>"; 	
		}
        
	}
	return html;
}



//******************************************
public void setDiscoveryFlag(Connection conn, String tab_id,String discovery_flag) {
	String sql="update tdm_tabs set discovery_flag='"+discovery_flag+"' where id="+tab_id;
	execDBConf(conn, sql, new ArrayList<String[]>());
}
	

//*******************************************
private String drawChildTableDialog(Connection conn, String app_type, String env_id, String parent_tab_id, String table_name, String child_tab_id, String db_type, String family_id) {
	StringBuilder sb=new StringBuilder();


	String v_parent_tab_id=parent_tab_id;
	
	String cat="";
	String owner="";
	String table="";
	String rel_on_fields="";
	String rel_type="";
	
	try{cat=table_name.split("\\*")[0];} catch(Exception e) {}
	try{owner=table_name.split("\\*")[1];} catch(Exception e) {}
	try{table=table_name.split("\\*")[2];} catch(Exception e) {}
	
	String sql="";
	
	if (table.length()==0) {
		sql="select cat_name, schema_name, tab_name from tdm_tabs where id="+child_tab_id;
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>());
		if (arr!=null && arr.size()>0) {
			cat=arr.get(0)[0];
			owner=arr.get(0)[1];
			table=arr.get(0)[2];
			
			sql="select tab_id, rel_on_fields, rel_type from tdm_tabs_rel where rel_tab_id="+child_tab_id;
			
			arr=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>());
			if (arr!=null && arr.size()>0) {
				v_parent_tab_id=arr.get(0)[0];
				rel_on_fields=arr.get(0)[1];
				rel_type=arr.get(0)[2];
			}
			
			
			
			
		}
	}
	
	
	
	sql="select id, field_name from tdm_fields where is_pk='YES' and tab_id="+v_parent_tab_id + " order by id";
	
	ArrayList<String[]> pklist=getDbArrayConf(conn, sql, Integer.MAX_VALUE, new ArrayList<String[]>());
	
	
	
	
	//sql="select field_name from tdm_fields where tab_id=?";
	//ArrayList<String[]> bindlist=new ArrayList<String[]>();
	//bindlist.add(new String[]{"INTEGER",parent_tab_id});
	
	//ArrayList<String[]> fieldlist=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	ArrayList<String[]> fieldlist=getFieldList(conn, app_type, env_id, cat, owner, table,db_type);
	
	ArrayList<String[]> farr=new ArrayList<String[]>();
	
	for (int i=0;i<fieldlist.size();i++) 
		farr.add(new String[]{fieldlist.get(i)[0]});
	
	
	
	
	sql="select id, concat(cat_name,'.',schema_name,'.',tab_name) tab"+
		" from tdm_tabs " + 
		" where app_id in (select app_id from tdm_tabs where id in ("+v_parent_tab_id+","+child_tab_id+") ) ";
	if (!child_tab_id.equals("0")) 
		sql=sql + " and id<>"+child_tab_id;
	sql=sql + " order by 2 ";
	
	String disabled="";
	if (child_tab_id.equals("0")) disabled="disabled";
		
	String combo_parent_tabs=makeCombo(conn, sql, "", "id=parent_table onchange=refreshLinkDlg() " + disabled, v_parent_tab_id, 200);
	
	
	ArrayList<String[]> relTypeArr=new ArrayList<String[]>();
	relTypeArr.add(new String[]{"HAS","Has"});
	//relTypeArr.add(new String[]{"NEEDS","Needs"});
	
	
	
	String rel_combo=makeComboArr(relTypeArr, "", "size=1 id=rel_type", rel_type, 80);
	 
	sb.append("<input type=hidden id=curr_parent_tab_id value=\""+v_parent_tab_id+"\">");	
	sb.append("<input type=hidden id=curr_child_tab_id value=\""+child_tab_id+"\">");
	sb.append("<input type=hidden id=child_tab_name value=\""+cat+"*"+owner+"*"+table+"\">");
	sb.append("<input type=hidden id=curr_family_id value=\""+family_id+"\">");

	
	sb.append("<table class=\"table table-condensed\">");


	
	
	sb.append("<tr class=\"active\">");
	sb.append("<td><span class=\"label label-info\">Parent Table</span></td>");
	sb.append("<td><span class=\"label label-info\">Relation</span></td>");
	sb.append("<td><span class=\"label label-info\">Child Table</span></td>");
	sb.append("</tr>");
	
	sb.append("<tr class=\"active\">");
	sb.append("<td>"+combo_parent_tabs+"</td>");
	sb.append("<td>"+rel_combo+"</td>");
	sb.append("<td><b>"+owner+"."+table+"</b></td>");
	sb.append("</tr>");
	
	
	
	
	sb.append("<tr class=\"active\">");
	sb.append("<td><span class=\"label label-info\">Primary Key Field(s)</span></td>");
	sb.append("<td></td>");
	sb.append("<td><span class=\"label label-info\">Foreign Key Field(s)</span></td>");
	sb.append("</tr>");
	
	
	
	for (int i=0;i<pklist.size();i++) {
		
		String pk_field_id=pklist.get(i)[0];
		String pk_field_name=pklist.get(i)[1];
		String curr_rel_field="";
		try{curr_rel_field=rel_on_fields.split(",")[i];} catch(Exception e) {}
		
		String combo_fields=makeComboArr(farr, "fk_field_"+i, "id=fk_field_"+i, curr_rel_field, 200);
		
		sb.append("<tr>");
		sb.append("<td><font color=red>"+pk_field_name+"</font></td>");
		sb.append("<td align=center> --------> </td>");
		sb.append("<td>"+combo_fields+"</td>");
		sb.append("</tr>");
	}
	
	sb.append("</table>");
	
	return sb.toString();
}

//**********************************************************************
public void updateTableRelation(
		Connection conn, 
		String child_tab_id, 
		String new_parent_tab_id, 
		String rel_on_fields,
		String rel_type
		) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String pk_fields="";
	
	sql="select field_name from tdm_fields where tab_id=? and is_pk='YES' order by id ";
	
	bindlist.add(new String[]{"INTEGER",new_parent_tab_id});
	ArrayList<String[]> pkArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	for (int i=0;i<pkArr.size();i++) {
		if (i>0) pk_fields=pk_fields+",";
		pk_fields=pk_fields+pkArr.get(i)[0];
	}
	
	sql="select id from tdm_tabs_rel where tab_id=? and rel_tab_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",new_parent_tab_id});
	bindlist.add(new String[]{"INTEGER",child_tab_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==0) {
		System.out.println("deleting/inserting...");
		
		sql="delete from tdm_tabs_rel where rel_tab_id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",child_tab_id});
		execDBConf(conn, sql, bindlist);
		
		
		sql="insert into tdm_tabs_rel (rel_type, rel_on_fields, pk_fields, tab_id, rel_tab_id, rel_order) values (?, ?, ?, ?, ?)";
		
		bindlist.clear();
		bindlist.add(new String[]{"STRING",rel_type});
		bindlist.add(new String[]{"STRING",rel_on_fields});
		bindlist.add(new String[]{"STRING",pk_fields});
		bindlist.add(new String[]{"INTEGER",new_parent_tab_id});
		bindlist.add(new String[]{"INTEGER",child_tab_id});
		bindlist.add(new String[]{"INTEGER","9999"});
		
		execDBConf(conn, sql, bindlist);
		
	}
	else {
		System.out.println("updating...");
		sql="update tdm_tabs_rel set rel_type=?, rel_on_fields=?, pk_fields=?, tab_id=? where rel_tab_id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"STRING",rel_type});
		bindlist.add(new String[]{"STRING",rel_on_fields});
		bindlist.add(new String[]{"STRING",pk_fields});
		bindlist.add(new String[]{"INTEGER",new_parent_tab_id});
		bindlist.add(new String[]{"INTEGER",child_tab_id});
		
		execDBConf(conn, sql, bindlist);
	}
	
	
}

//**********************************************************************
public String showDBListDialog(Connection conn, String listsql) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select id, name from tdm_envs order by name";
	
	String combo_envs=makeCombo(conn, sql, "env_id", "id=env_id  onchange=\"list_sql_validated=false;\"", "", 300);
	
	sb.append("<table class=table>");
	
	sb.append("<tr>");
	sb.append("<td align=right>");
	sb.append("<b>From DB : </b> ");
	sb.append("</td>");
	sb.append("<td>");
	sb.append(combo_envs);
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right>");
	sb.append("<b>SQL to retrieve list</b> : ");
	sb.append("</td>");
	sb.append("<td>");
	sb.append("<textarea cols=80 rows=4 id=listsql onkeypress=\"list_sql_validated=false;\">"+listsql+"</textarea>");
	sb.append("</td>");
	sb.append("</tr>");
	

	
	sb.append("<tr>");
	sb.append("<td>");
	sb.append("</td>");
	sb.append("<td>");
	sb.append("<button type=button class=\"btn btn-info\" onclick=runListSql()>Validate Query & Retrieve Sample Records</button>");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("</table>");
	
	sb.append("  <div id=\"listItemsDiv\">");
	sb.append("  </div>	");
	
	return sb.toString();
}



//*************************************************************
	public String[] getFieldNames(Connection conn, String env_id, String sql) {
//*************************************************************

		Connection connApp=null;
		PreparedStatement pstmtApp=null;
		ResultSet rsetApp = null;
		ResultSetMetaData rsmdApp = null;
		
		try {
			
			connApp=getconn(conn, env_id);
			pstmtApp = connApp.prepareStatement(sql);
			try {
				pstmtApp.setQueryTimeout(30);
			} catch(Exception e) {
				System.out.println("DB does not support setQueryTimeout. dont worry :) skipping... ");
			}
			
			rsetApp = pstmtApp.executeQuery();
			rsmdApp = rsetApp.getMetaData();
			int colcount = rsmdApp.getColumnCount();
			
			String[] ret1=new String[colcount];
			
			for (int i = 0; i < colcount; i++) 
				ret1[i]=rsmdApp.getColumnName(i+1);
			
			
			return ret1;
			
		} catch (Exception ignore) {
			ignore.printStackTrace();
			System.out.println("Exception@getFieldNames : " + sql);
		} finally {
			try {pstmtApp.close();pstmtApp = null;} catch (Exception e) {}
			try {connApp.close();connApp = null;} catch (Exception e) {}
		}
		
		return null;
	}


//**********************************************************************
public String runListSQL(Connection conn, String sql, String env_id) {
	StringBuilder sb=new StringBuilder();
	
	StringBuilder sbErr=new StringBuilder();

	boolean isvalid=validateSQLStatement(conn, env_id, "${default}", sql, sbErr);
	
	if (!isvalid) {
		sb.append("<font color=red><b>!!! SQL is invalid. Please correct it. </b></font>");
		sb.append("<hr>");
		sb.append(sbErr.toString());
		return sb.toString();
	}
	
	
	
	ArrayList<String[]> arr=getDbArrayApp(conn, env_id, sql, 100, null);
	sb.append("<input type=hidden id=SQLOK>");
	sb.append("<table class=\"table table-striped\">");
	
	sb.append("<tr class=active>");
	
	String[] farr=getFieldNames(conn,env_id,sql);
	sb.append("<td class=info><b><font color=red>All</font></b><br><input type=checkbox id=selected_all onclick=selectallfields()></td>");
	for (int i=0;i<farr.length;i++) 
		sb.append("<td><b>"+farr[i]+"</b><br><input type=checkbox id=selected_field_"+i+" value=\""+farr[i]+"\"></td>");
	
	sb.append("</tr>");
	
	for (int i=0;i<arr.size();i++) {
		String[] arec=arr.get(i);
		sb.append("<tr>");
		sb.append("<td class=info align=right><b>"+i+"</b></td>");
		for (int r=0;r<arec.length;r++) 
			sb.append("<td>"+arec[r]+"</td>");
		sb.append("</tr>");

	}
	sb.append("</table>");
	
	return sb.toString();
}


//******************************************************************
public String createDBListItems(Connection conn, String env_id, String list_id, String listsql, int maxitemcount, String is_distinct, String selected_fields ) {
	
	
	String[] farr=getFieldNames(conn,env_id,listsql);
	
	ArrayList<String> dbFields=new ArrayList<String>();
	for (int i=0;i<farr.length;i++)
		dbFields.add(farr[i]);
	
	ArrayList<Integer> pickedFieldIDs=new ArrayList<Integer>();
	
	String[] pickedFields=selected_fields.split(",");	
	for (int i=0;i<pickedFields.length;i++) {
		int id=dbFields.indexOf(pickedFields[i]);
		if (id>-1) pickedFieldIDs.add(id);
	}
	
	ArrayList<String[]> arr=getDbArrayApp(conn, env_id, listsql, maxitemcount, null);


	
	String sql="delete from tdm_list_items where list_id="+list_id;
	execDBConf(conn, sql, new ArrayList<String[]>());
	
	String title_list="";
	for (int i=0;i<pickedFields.length;i++) {
		if (i>0) title_list=title_list+"|::|";
		title_list=title_list+pickedFields[i];
	}
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	sql="update tdm_list set title_list=?, sql_statement=? where id="+list_id;
	bindlist.add(new String[]{"STRING",title_list});
	bindlist.add(new String[]{"STRING",listsql});
	execDBConf(conn, sql,bindlist);
	
	StringBuilder sqls=new StringBuilder();
	bindlist.clear();
	
	ArrayList<String> distinctArr=new ArrayList<String>();
	int added_count=0;
	
	for (int i=0;i<arr.size();i++) {
		String[] rec=arr.get(i);
		String a_item="";
		int found=0;
		for (int f=0;f<rec.length;f++) {
			if (pickedFieldIDs.contains(f)) {
				found++;
				if (found>1) a_item=a_item+"|::|";
				a_item=a_item+rec[f];
			}
		}		
		
		if ((!distinctArr.contains(a_item) || is_distinct.equals("NO")) && a_item.trim().length()>0) {
			
			if (added_count==0) {
				bindlist.clear();
				sqls.setLength(0);
				sqls.append("insert into tdm_list_items (list_id, list_val) values(?,?)");
			}
			
			bindlist.add(new String[]{"INTEGER",list_id});
			bindlist.add(new String[]{"STRING",a_item});

			//execDBConf(conn, sqls.toString(), bindlist);
			
			if (is_distinct.equals("YES")) distinctArr.add(a_item);
			
			added_count++;
			
			if (added_count>=maxitemcount) break;
		}
		
		if (i % 100==0 || i==arr.size()-1)
		System.out.println("added " + added_count+" items / "+ i);

	} //for (int i=0;i<arr.size();i++)
		
		
	
		if (bindlist.size()>0) {
			System.out.println("inserting lists as bulk for "+(bindlist.size()/2));
			PreparedStatement pstmt=null;
			try {
				pstmt=conn.prepareStatement(sqls.toString());
				conn.setAutoCommit(false);
				for (int i=0;i<bindlist.size();i=i+2) {
					pstmt.setInt(1, Integer.parseInt(bindlist.get(i)[1]));
					pstmt.setString(2, bindlist.get(i+1)[1]);
					pstmt.addBatch();
				}
				pstmt.executeBatch();
				conn.commit();
				pstmt.clearBatch();
				conn.setAutoCommit(true);
				
				
			} catch(Exception e) {
				System.out.println("exception@inserting lists as bulk ");
				e.printStackTrace();
			} finally {
				try {pstmt.close();} catch(Exception e) {}
			}
			
			
			
			System.out.println("inserting lists Ok");
		}
	
		
		
	
	return "javascript:openListItems();";
}


//************************************************************************
public void log_trial(Connection conn, String table_name, int id, String user, String action) {
	
	ArrayList<String[]> fields=getFieldListFromApp(conn, "", "${default}", "" , table_name,"MYSQL");

	String sql="select ";
	for (int i=0;i<fields.size();i++)
	{
		if (i>0) sql=sql+",";
		sql=sql+fields.get(i)[0];
	}
	sql=sql+" from "+table_name + " where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",""+id});
	ArrayList<String[]> currRec=getDbArrayConf(conn, sql, 1, bindlist, 10);
	StringBuilder sb=new StringBuilder();

	
	for (int i=0;i<currRec.size();i++) {
		sb.append("<REC>\n");
		String[] arec=currRec.get(i);
		for (int f=0;f<arec.length;f++)
			sb.append("<FIELD name=\""+fields.get(f)[0]+"\">\n"+arec[f]+"\n</FIELD>\n");
		sb.append("</REC>");
	}
	
	
	sql="insert into tdm_audit_logs (table_name, table_id, log_action, log_user, old_record) values (?,?,?,?,?) ";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",""+table_name});
	bindlist.add(new String[]{"INTEGER",""+id});
	bindlist.add(new String[]{"STRING",""+action});
	bindlist.add(new String[]{"STRING",""+user});
	bindlist.add(new String[]{"STRING",""+sb.toString()});
	
	execDBConf(conn, sql, bindlist);
	
	
}



//***************************************************
String createCopyAppDlg(Connection conn, String target_app_id) {
//***************************************************
	StringBuilder sb=new StringBuilder();

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select app_type from tdm_apps where id="+target_app_id;
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String app_type=arr.get(0)[0];
	
	sql="select id, name, app_type from tdm_apps where app_type='"+app_type+"' and id<>"+target_app_id+" order by name";
	
	String app_combo=makeCombo(conn, sql, "", "id=source_app_id onchange=fillCopyTableList()", "", 300);
	
	sb.append("<table class=\"table\">");
	sb.append("<tr>");
	sb.append("<td><b>From Application : </b></td>");
	sb.append("<td>"+app_combo+"</td>");
	sb.append("</tr>");
	sb.append("</table>");
	sb.append("<div id=tableCopyListDiv></div>");
	
	
	
	
	return sb.toString();

}



//**************************************************
String fillCopyTableList(Connection conn, String source_app_id) {
	
	if (source_app_id.length()==0) return "";
	
	StringBuilder sb=new StringBuilder();
	
	
	String sql="select id, replace(concat('[',cat_name,'].',schema_name,'.',tab_name),'[${default}].','') from tdm_tabs where app_id="+source_app_id+" order by 2";
	ArrayList<String[]> tabList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, null);
	
	
	
	sb.append("<table class=\"table\">");
	
	sb.append("<tr class=active>");
	sb.append("<td align=right><input type=checkbox id=set_all onclick=setAllCopyTableList()></td>");
	sb.append("<td>Select/Deselect All</td>");
	sb.append("<tr>");
	
	for (int i=0;i<tabList.size();i++) {
		sb.append("<tr>");
		sb.append("<td align=right><input type=checkbox id=copy_ch_"+i+" value=\""+tabList.get(i)[0]+"\"></td>");
		sb.append("<td><b>"+tabList.get(i)[1]+"</b></td>");
		sb.append("<tr>");
	}
	
	sb.append("</table>");
	
		
	return sb.toString();
}


//*********************************************
void copyTablesToApp(Connection conn, String target_app_id,  String tab_ids) {
//*********************************************
	String[] tabidArr=tab_ids.split(",");
	ArrayList<String[]> tabFields=  getFieldListFromApp(conn, "", "${default}", "", "tdm_tabs","MYSQL");
	ArrayList<String[]> fieldFields=getFieldListFromApp(conn, "", "${default}", "", "tdm_fields","MYSQL");

	for (int i=0;i<tabidArr.length;i++) {
		String sql="";
		String tab_id=tabidArr[i];
		
		String fields1="";
		String fields2="";
				
		for (int f=0;f<tabFields.size();f++) {
			
			String fied_name=tabFields.get(f)[0];
			if (fields1.length()>0) fields1=fields1+",";
			if (fields2.length()>0) fields2=fields2+",";
			
			if (!fied_name.equals("id")) fields1=fields1+fied_name;
			if (!fied_name.equals("id") && !fied_name.equals("app_id"))  fields2=fields2+fied_name;
			if (fied_name.equals("app_id")) fields2=fields2+target_app_id;
				 
		}
		sql="insert into tdm_tabs ("+fields1+") select "+fields2+" from tdm_tabs where id="+tab_id;
		execDBConf(conn, sql, new ArrayList<String[]>());
		
		sql="select max(id) from tdm_tabs  " + 
			" where concat(cat_name,'.',schema_name,'.',tab_name)=  " + 
			" (select concat(cat_name,'.',schema_name,'.',tab_name) from tdm_tabs where id="+tab_id+")  ";
		String new_tab_id=getDBSingleVal(conn, sql);
		
	 	fields1="";
		fields2="";
		
		for (int f=0;f<fieldFields.size();f++) {
			
			String fied_name=fieldFields.get(f)[0];
			if (fields1.length()>0) fields1=fields1+",";
			if (fields2.length()>0) fields2=fields2+",";
			
			if (!fied_name.equals("id")) fields1=fields1+fied_name;
			if (!fied_name.equals("id") && !fied_name.equals("tab_id"))  fields2=fields2+fied_name;
			if (fied_name.equals("tab_id")) fields2=fields2+new_tab_id;
			
		}
		
		sql="insert into tdm_fields ("+fields1+") select "+fields2+" from tdm_fields where tab_id="+tab_id;
		//System.out.println(sql);
		
		execDBConf(conn, sql,  new ArrayList<String[]>());
		
	}
		
	
}




//************************************************************
String filterTableDlg(Connection conn, String app_id) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select  id, concat(tab_name,'@',schema_name) tab   " +
			" from tdm_tabs t  where app_id= " + app_id + 
			" and t.id not in (select rel_tab_id from tdm_tabs_rel) " +
			" order by tab_name";
	
	String root_tab_id="";
	String root_tab_name="";
	
	ArrayList<String[]> arrRoot=getDbArrayConf(conn, sql, 1,  new ArrayList<String[]>());
	
	try {
		root_tab_id=arrRoot.get(0)[0];
		root_tab_name=arrRoot.get(0)[1];
	} catch(Exception e) {
		e.printStackTrace();
	}
	
	
	
	sb.append("<h3>" +root_tab_name  +" Table Filter Configuration</h3>");
	ArrayList<String[]> filterTypes=new ArrayList<String[]>();
	
	
	
	filterTypes.add(new String[]{"SINGLE_STRING","Single Value"});
	filterTypes.add(new String[]{"SINGLE_NUMBER","Single Number"});
	filterTypes.add(new String[]{"SINGLE_DATE","Single Dates"});
	filterTypes.add(new String[]{"SINGLE_LIST","Single List"});

	filterTypes.add(new String[]{"BETWEEN_STRING","Between Value"});
	filterTypes.add(new String[]{"BETWEEN_NUMBER","Between Number"});
	filterTypes.add(new String[]{"BETWEEN_DATE","Between Dates"});
	filterTypes.add(new String[]{"BETWEEN_LIST","Between Lists"});
	
	filterTypes.add(new String[]{"BY_PARTITION","By Partition"});
	
	filterTypes.add(new String[]{"NO_FILTER","Copy All-No Filter"});

	
	filterTypes.add(new String[]{"MANUAL_CONDITION","Set Manual Condition"});
	

	
	sb.append("<table class=\"table table-striped table-condensed\">");
	
	sb.append("<tr class=active>");
	
	sb.append("<td>");
	sb.append("<button class=\"btn btn-sm btn-success\" onclick=addNewTableFilter('"+app_id+"','"+root_tab_id+"')>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"></span>");
	sb.append("</button>");
	sb.append("</td>");
	
	
	sb.append("<td><h4><span class=\"label label-info\">Filter Name / Type</span> </h4></td>");
	sb.append("<td><h4><span class=\"label label-info\">SQL</span> </h4></td>");
	sb.append("<td><h4><span class=\"label label-info\">Filter Formats (RegEx) / Lists</span> </h4></td>");
	
	
	sb.append("<tr>");
	
	sql="select id, filter_type, filter_name, filter_sql, "+
		" format_1, format_2, list_id_1, list_id_2, list_source_1, list_source_2 "+
		" from tdm_copy_filter where app_id="+app_id+" order by 1";
	ArrayList<String[]> filterArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, new ArrayList<String[]>());
	
	for (int i=0;i<filterArr.size();i++) {
		
		
		String a_filter_id=filterArr.get(i)[0];
		String a_filter_type=filterArr.get(i)[1];
		String a_filter_name=filterArr.get(i)[2];
		String a_filter_sql=filterArr.get(i)[3];
		String a_format_1=filterArr.get(i)[4];
		String a_format_2=filterArr.get(i)[5];
		String a_list_id_1=filterArr.get(i)[6];
		String a_list_id_2=filterArr.get(i)[7];
		String a_list_source_1=filterArr.get(i)[8];
		String a_list_source_2=filterArr.get(i)[9];
		
	

		sb.append("<tr>");
		
		
		sb.append("<td nowrap>");
		sb.append("<button class=\"btn btn-sm btn-danger\" onclick=deleteTableFilter('"+a_filter_id+"')><span class=\"glyphicon glyphicon-remove\"></span></button>");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append("<input type=text id=filter_name_"+ a_filter_id +"  value=\""+codehtml(a_filter_name)+"\" size=24 maxlength=200 onchange=changeTableFilter('"+a_filter_id+"')>");
		sb.append("<br>");
		sb.append(makeComboArr(filterTypes, "", "id=filter_type_"+ a_filter_id +" size=1 onchange=changeTableFilter('"+a_filter_id+"')", a_filter_type, 220));
		sb.append("</td>");
		
		sb.append("<td>");
		if (!a_filter_type.equals("BY_PARTITION") && !a_filter_type.equals("NO_FILTER") && !a_filter_type.equals("MANUAL_CONDITION"))
			sb.append("<textarea cols=30 rows=3 id=filter_sql_"+ a_filter_id +" onchange=changeTableFilter('"+a_filter_id+"') >"+a_filter_sql+"</textarea>");
		sb.append("</td>");
		
		
		
		
		sb.append("<td>");
		
		sb.append("<table>");
		sb.append("<tr>");
		
		if (a_filter_type.equals("SINGLE_STRING") || a_filter_type.equals("BETWEEN_STRING") ) {
			sb.append("<td>");
			sb.append("<input type=text id=format_1_"+ a_filter_id +"  value=\""+codehtml(a_format_1)+"\" size=24 maxlength=200 onchange=changeTableFilter('"+a_filter_id+"')>");
			sb.append("</td>");
		}
		
		if (a_filter_type.equals("BETWEEN_STRING")) {
			sb.append("<td>");
			sb.append("<input type=text id=format_2_"+ a_filter_id +"  value=\""+codehtml(a_format_2)+"\" size=24 maxlength=200 onchange=changeTableFilter('"+a_filter_id+"')>");
			sb.append("</td>");
		}
		
		ArrayList<String[]> listSourceArr=new ArrayList<String[]>();
		listSourceArr.add(new String[]{"STATIC","From Static List"});
		listSourceArr.add(new String[]{"SOURCE","From Source DB"});
		listSourceArr.add(new String[]{"TARGET","From Target DB"});
		
		if (a_filter_type.equals("SINGLE_LIST") || a_filter_type.equals("BETWEEN_LIST")) {
			sql="select id, name  from tdm_list order by 2";
			
			sb.append("<td>");
			
			sb.append("<table>");
			sb.append("<tr><td>List 1</td></tr>");
			sb.append("<tr>");
			sb.append("<td>");
			sb.append(makeCombo(conn,sql, "", "id=list_id_1_"+ a_filter_id +" onchange=changeTableFilter('"+a_filter_id+"')", a_list_id_1, 220));
			sb.append("</td>");
			sb.append("</tr>");
			sb.append("<tr>");
			sb.append("<td>");
			sb.append(makeComboArr(listSourceArr, "", "size=1 id=list_source_1_"+a_filter_id + " onchange=changeTableFilter('"+a_filter_id+"') ", a_list_source_1, 0));
			sb.append("</td>");
			sb.append("</tr>");
			sb.append("</table>");
			
			sb.append("<td>");
			

		}
			
		
		if (a_filter_type.equals("BETWEEN_LIST")) {
			sql="select id, name  from tdm_list order by 2";
			
			sb.append("<td>");
			
			sb.append("<table>");
			sb.append("<tr><td>List 2</td></tr>");
			sb.append("<tr>");
			sb.append("<td>");
			sb.append(makeCombo(conn,sql, "", "id=list_id_2_"+ a_filter_id +" onchange=changeTableFilter('"+a_filter_id+"')", a_list_id_2, 220));
			sb.append("</td>");
			sb.append("</tr>");
			sb.append("<tr>");
			sb.append("<td>");
			sb.append(makeComboArr(listSourceArr, "", "size=1 id=list_source_2_"+a_filter_id + " onchange=changeTableFilter('"+a_filter_id+"') ", a_list_source_2, 0));
			sb.append("</td>");
			
			sb.append("</tr>");
			sb.append("</table>");
			
			sb.append("<td>");
		}
		
		sb.append("</tr>");

		sb.append("</table>");
		
		sb.append("</td>");
	
		
		sb.append("<tr>");
	}
	
	
	
	sb.append("</table>");
	
	filterTypes.add(new String[]{"",""});
	
	return sb.toString();
}


//************************************************************
String dependedAppsDlg(Connection conn, HttpSession session, String app_id) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select "+
				"	ar.id, a.id, a.name, filter_id, filter_value, run_after_app_id  "+
				"	from tdm_apps_rel ar, tdm_apps a "+
				"	where app_id=? "+
				"	and rel_app_id=a.id "+
				"	order by rel_order";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addNewDependedApplication('"+app_id+"')>");
	sb.append("Add New Application");
	sb.append("</button>");
	sb.append("</div>");
	sb.append("</div>");
	
	if (arr.size()==0) {
		sb.append("No depended application");
		return sb.toString();
	}
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	
	sb.append("<tr class=warning>");
	sb.append("<td colspan=2></td>");
	sb.append("<td nowrap><b>Application to run</b></td>");
	sb.append("<td><b>Run After</b></td>");
	sb.append("<td colspan=3><b>Run With Parameters</b></td>");
	sb.append("</tr>");
	
	sql="select rel_app_id, a.name application_name  "+
			" from tdm_apps_rel ar, tdm_apps a "+
			" where ar.rel_app_id=a.id and ar.app_id=? "+
			" order by ar.rel_order";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	ArrayList<String[]> runAfterAppList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	for (int i=0;i<arr.size();i++) {
		String id=arr.get(i)[0];
		String dep_app_id=arr.get(i)[1];
		String dep_app_name=arr.get(i)[2];
		String filter_id=arr.get(i)[3];
		String filter_value=arr.get(i)[4];
		String run_after_app_id=arr.get(i)[5];
		
		sb.append("<td>");
		sb.append("<font color=red><span class=\"glyphicon glyphicon-minus\" onclick=deleteDependedCopyApp('"+id+"')></span></span>");
		sb.append("</td>");
		
		sb.append("<td nowrap align=center>");
		if (i>0)
			sb.append("<font color=blue><span class=\"glyphicon glyphicon-chevron-up\" onclick=\"reorderDependedCopyApp('"+id+"','UP')\"></span></span>");
		if (i<arr.size()-1)
			sb.append("<font color=blue><span class=\"glyphicon glyphicon-chevron-down\" onclick=\"reorderDependedCopyApp('"+id+"','DOWN')\"></span></span>");
		sb.append("</td>");

		sb.append("<td nowrap>");
		sb.append(dep_app_name);
		sb.append("</td>");
		
		sb.append("<td nowrap>");
		sb.append(makeComboArr(runAfterAppList, "", "id=run_after_app_id onchange=\"savePrepAppField(this,'"+id+"');\" ", run_after_app_id, 200));
		sb.append("</td>");
		
		ArrayList<String[]> filterList=getAvailableFilterList(conn,session,dep_app_id);
		
		sb.append("<td>");
		sb.append(makeComboArr(filterList, "", "id=filter_id onchange=\"fillCopyFilterVals(this, '"+dep_app_id+"','copyFilterValsDivFor_"+id+"','"+filter_value+"');  savePrepAppField(this,'"+id+"');\"" , filter_id, 300));
		sb.append("</td>");
		
		sb.append("<td width=\"100%\" >");
		sb.append("<div id=\"copyFilterValsDivFor_"+id+"\">");
		sb.append(fillCopyFilterVals(conn,session,dep_app_id,filter_id, "0", "0", filter_value));
		sb.append("</div>");
		sb.append("</td>");
		
		
		sb.append("<td>");
		sb.append("<button class=\"btn btn-sm btn-info\" onclick=savePrereqAppFilterValues('"+id+"')>");
		sb.append("Save Parameters");
		sb.append("</button>");
		sb.append("</td>");
		
		
		

		sb.append("</tr>");
		
	}
	
	
	sb.append("</table>");
	
	
	return sb.toString();
}



//************************************************************
String dbScriptDlg(Connection conn, HttpSession session, String app_id, String stage) {
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select name from tdm_apps where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	String app_name="Unknown application";
	
	try{app_name=arr.get(0)[0];} catch(Exception e) {}
	
	if (stage.equals("PREP"))
		sb.append("<h4>Scripts BEFORE <b>"+app_name+"</b></h4>");
	else
		sb.append("<h4>Scripts AFTER <b>"+app_name+"</b></h4>");

	
	sb.append("<input type=hidden id=script_app_id value=\""+app_id+"\">");
	sb.append("<input type=hidden id=script_stage value=\""+stage+"\">");
	
	sql="select id, script_description, family_id, target, script_body "+
		" from tdm_copy_script "+
		" where app_id=? and stage=?"+
		" order by script_order";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"STRING",stage});
	
	arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	sb.append("<table class=\"table table-striped table-condense\">");
	
	sb.append("<tr class=info>");
	sb.append("<td colspan=3>");
	sb.append("<button class=\"btn btn-sm btn-success\" onclick=addNewScript('"+app_id+"','"+stage+"')>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"><span>");
	sb.append(" Add New Script");
	sb.append("</button>");
	sb.append("</td>");
	sb.append("<td><b>DB Family</b></td>");
	sb.append("<td><b>Side</b></td>");
	sb.append("<td><b>Script</b></td>");
	sb.append("</tr>");
	
	
	sql="select id, family_name from tdm_family order by 2";
	bindlist.clear();
	ArrayList<String[]> familyArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);


	ArrayList<String[]> targetArr=new ArrayList<String[]>();
	targetArr.add(new String[]{"SOURCE","On Source"});
	targetArr.add(new String[]{"TARGET","On Target"});

	for (int i=0;i<arr.size();i++) {
		
		String script_id=arr.get(i)[0];
		String script_description=arr.get(i)[1];
		String family_id=arr.get(i)[2];
		String target=arr.get(i)[3];
		String script_body=arr.get(i)[4];
		
		
		sb.append("<tr>");
		
		sb.append("<td nowrap align=center>");
		if (i>0) sb.append("<font color=orange><span class=\"glyphicon glyphicon-chevron-up\" onclick=reorderScript('"+app_id+"','"+stage+"','"+script_id+"','UP') ></font>");
		if (i<arr.size()-1) sb.append("<font color=orange><span class=\"glyphicon glyphicon-chevron-down\"  onclick=reorderScript('"+app_id+"','"+stage+"','"+script_id+"','DOWN')></font>");
		sb.append("</td>");

		sb.append("<td>");
		sb.append("<font color=red><span class=\"glyphicon glyphicon-minus\" onclick=removeScript('"+app_id+"','"+stage+"','"+script_id+"')></font>");
		sb.append("</td>");

		
		sb.append("<td>");
		sb.append(makeText("script_description", clearHtml(script_description), " onchange=\"saveScriptField(this,'"+script_id+"')\" ", 200));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(familyArr, "", "size=1 id=family_id onchange=\"saveScriptField(this,'"+script_id+"')\" ", family_id, 200));
		sb.append("</td>");
		



		sb.append("<td>");
		sb.append(makeComboArr(targetArr, "", "size=1 id=target onchange=\"saveScriptField(this,'"+script_id+"')\" ", target, 120));
		sb.append("</td>");

		sb.append("<td width=\"100%\">");
		sb.append("<textarea  id=script_body onchange=\"saveScriptField(this,'"+script_id+"')\" rows=8 style=\"width:100%; background-color:black; color:white; font-family:Courier New, Courier, monospace;\">");
		sb.append(clearHtml(script_body));
		sb.append("</textarea>");
		sb.append("</td>");


		
		sb.append("</tr>");
		
	}
	
	sb.append("</table>");
			
	return sb.toString();
}

//*************************************************************
void addNewScript(Connection conn, HttpSession session, String app_id, String stage, String script_description, String family_id) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select max(script_order)+1 from tdm_copy_script where app_id=? and stage=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"STRING",stage});

	String script_order="1";
	try {script_order=getDbArrayConf(conn, sql, 1, bindlist).get(0)[0];} catch(Exception e) {script_order="1";}
	
	if (script_order.length()==0) script_order="1";
 	
	sql="insert into tdm_copy_script (app_id, stage, script_description, target, family_id, script_order) values (?, ?, ?, ?, ?, ?) ";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"STRING",stage});
	bindlist.add(new String[]{"STRING",script_description});
	bindlist.add(new String[]{"STRING","TARGET"});
	bindlist.add(new String[]{"STRING",family_id});
	bindlist.add(new String[]{"INTEGER",script_order});

	execDBConf(conn, sql, bindlist);
}


//*************************************************************
void removeScript(Connection conn, HttpSession session, String script_id) {
	String sql="delete from tdm_copy_script where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();


	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",script_id});



	execDBConf(conn, sql, bindlist);
}

//************************************************************
void filterTableAddNew(Connection conn, String app_id, String tab_id) {
	String sql="insert into tdm_copy_filter (app_id, tab_id, filter_type,filter_name) values (?, ?, 'NO_FILTER','All')";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"INTEGER",tab_id});
	
	execDBConf(conn, sql, bindlist);
}


//************************************************************
void filterTableDelete(Connection conn, String filter_id) {
	execDBConf(conn, "delete from tdm_copy_filter where id="+filter_id, new ArrayList<String[]>());
}


//************************************************************
void filterTableChange(Connection conn, String filter_id, 
		String filter_name, String filter_type, String filter_sql,
		String format_1, String format_2,
		String list_id_1, String list_id_2,
		String list_source_1, String list_source_2
		) {
	String sql="update tdm_copy_filter set "+
				" filter_name=?, filter_type=?, filter_sql=?, "+
				" format_1=?, format_2=?, list_id_1=?, list_id_2=?, " + 
				" list_source_1=?, list_source_2=? " +
				" where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.add(new String[]{"STRING",filter_name});
	bindlist.add(new String[]{"STRING",filter_type});
	bindlist.add(new String[]{"STRING",filter_sql});
	
	bindlist.add(new String[]{"STRING",format_1});
	bindlist.add(new String[]{"STRING",format_2});
	
	bindlist.add(new String[]{"INTEGER",list_id_1});
	bindlist.add(new String[]{"INTEGER",list_id_2});
	
	bindlist.add(new String[]{"STRING",list_source_1});
	bindlist.add(new String[]{"STRING",list_source_2});
	
	bindlist.add(new String[]{"INTEGER",filter_id});
	
	
	
	

	execDBConf(conn, sql, bindlist);
	
}


//*****************************************************************
String getCopyFilter(Connection conn, String app_id, String env_id, String filter_id) {
	StringBuilder sb=new StringBuilder();
	String sql="";
	String curr_filter_id=filter_id;
	
	if (filter_id.equals("0")) {
		sql="select id from tdm_copy_filter where app_id="+app_id;
		try {
			curr_filter_id=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>()).get(0)[0];
		} catch(Exception e) {
			curr_filter_id="";
		}
		
	}
	
	if (curr_filter_id.length()==0) {
		return "<font color=red>No Filter defined!</font><input type=hidden id=NO_FILTER_DEFINED>";
	}
	
	
	sql="select id, filter_type, filter_name, filter_sql, format_1, format_2, list_id_1, list_id_2 from tdm_copy_filter where id="+curr_filter_id+" order by 1";
	ArrayList<String[]> filterArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, new ArrayList<String[]>());
	
	for (int i=0;i<filterArr.size();i++) {
		
		
		String a_filter_id=filterArr.get(i)[0];
		String a_filter_type=filterArr.get(i)[1];
		String a_filter_name=filterArr.get(i)[2];
		String a_filter_sql=filterArr.get(i)[3];
		String a_format_1=filterArr.get(i)[4];
		String a_format_2=filterArr.get(i)[5];
		String a_list_id_1=filterArr.get(i)[6];
		String a_list_id_2=filterArr.get(i)[7];
		
		sb.append("<table class=\"table table-striped\">");
		
		sb.append("<tr class=info>");
		
		sb.append("<td>");
		sql="select id, filter_name from tdm_copy_filter where app_id="+app_id+ " order by id";
		sb.append("<b>Copy Filter :</b>");
		sb.append(makeCombo(conn, sql, "", "id=filter_id size=1 onchange=changeCopyFilter()", a_filter_id, 400));
		sb.append("<input type=hidden id=filter_type value=\""+a_filter_type+"\">");
		
		if (a_filter_type.equals("SINGLE_NUMBER") || a_filter_type.equals("BETWEEN_NUMBER")) 
		{
			a_format_1="^(([0-9]*)|(([0-9]*).([0-9]*)))$";
			a_format_2=a_format_1;
		}
		
		sb.append("<input type=hidden id=filter_format_1 value=\""+codehtml(a_format_1)+"\">");
		sb.append("<input type=hidden id=filter_format_2 value=\""+codehtml(a_format_2)+"\">");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append("<b>Record count :</b><br><input type=text id=copy_count value=\""+Integer.MAX_VALUE+"\" size=10 maxlength=10>");
		sb.append("</td>");
		
		sb.append("</tr>");
		
		
		sb.append("<tr class=active>");


		if (a_filter_type.equals("SINGLE_STRING") || a_filter_type.equals("BETWEEN_STRING") || 
				a_filter_type.equals("SINGLE_NUMBER") || a_filter_type.equals("BETWEEN_NUMBER")
				) 
		{
			sb.append("<td nowrap>"); 
			if (a_filter_type.equals("BETWEEN_STRING")|| a_filter_type.equals("BETWEEN_NUMBER")) 
				sb.append("Between ");
			sb.append("<input type=text id=val_1 size=24 maxlength=200 onchange=checkFormat('"+a_format_1+"')>");
			sb.append("</td>");
		}
		
		if (a_filter_type.equals("BETWEEN_STRING") || a_filter_type.equals("BETWEEN_NUMBER")){
			sb.append("<td>"); 
			sb.append("And ");
			sb.append("<input type=text id=val_2 size=24 maxlength=200 onchange=checkFormat('"+a_format_2+"')>");
			sb.append("</td>");
		}
		
		
		Calendar cal=GregorianCalendar.getInstance();
		SimpleDateFormat format1 = new SimpleDateFormat(DEFAULT_DATE_FORMAT); 
		String p_dt_formatted=format1.format(cal.getTime());
		
		
		if (a_filter_type.equals("SINGLE_DATE") || a_filter_type.equals("BETWEEN_DATE")) {
			sb.append("<td nowrap>"); 
			if (a_filter_type.equals("BETWEEN_DATE")) 
				sb.append("Between<br> ");
			sb.append("<input type=text id=val_1 size=18 maxlength=24  value=\""+p_dt_formatted+"\" onchange=validateDateTime(this)>");
			sb.append("<br> ["+DEFAULT_DATE_FORMAT+"]");
			sb.append("</td>");
		}
		
		
		if (a_filter_type.equals("BETWEEN_DATE")){
			sb.append("<td>"); 
			sb.append("And<br> ");
			sb.append("<input type=text id=val_2 size=18 maxlength=24  value=\""+p_dt_formatted+"\" onchange=validateDateTime(this)>");
			sb.append("<br> ["+DEFAULT_DATE_FORMAT+"]");
			sb.append("</td>");
		}
		
		
		if (a_filter_type.equals("SINGLE_LIST") || a_filter_type.equals("BETWEEN_LIST")) {
			sb.append("<td nowrap>"); 
			if (nvl(a_list_id_1,"0").equals("0")) {
				sb.append("<font color=red>List configuration is missing!!!</font>");
			}
			else {
				if (a_filter_type.equals("BETWEEN_LIST"))
					sb.append("Between ");
				sql="select list_val from tdm_list_items where list_id="+a_list_id_1;
				ArrayList<String[]> listArr=getDbArrayConf(conn, sql, 1000, new ArrayList<String[]>());
				for (int l=0;l<listArr.size();l++) {
					
					if (listArr.get(l)[0].contains("|::|")) 
						listArr.set(l
								, 
								new String[]{
								listArr.get(l)[0].split("\\|::\\|")[0],
								listArr.get(l)[0].split("\\|::\\|")[1]
										}
						);
						}
					
				sb.append(makeComboArr(listArr, "", "id=val_1", "", 300));
				
				//sb.append(makeCombo(conn, sql, "", "id=val_1", "", 300));
				}
				
				
				
			sb.append("</td>");
			}
			
			
		
		
		if (a_filter_type.equals("BETWEEN_LIST")){
			sb.append("<td>"); 
			if (nvl(a_list_id_2,"0").equals("0")) {
				sb.append("<font color=red>List configuration is missing!!!</font>");
			}
			else {
				if (a_filter_type.equals("BETWEEN_LIST"))
					sb.append("And ");
				sql="select list_val from tdm_list_items where list_id="+a_list_id_2;
				ArrayList<String[]> listArr=getDbArrayConf(conn, sql, 1000, new ArrayList<String[]>());
				for (int l=0;l<listArr.size();l++) {
					
					if (listArr.get(l)[0].contains("|::|")) 
						listArr.set(l
								, 
								new String[]{
								listArr.get(l)[0].split("\\|::\\|")[0],
								listArr.get(l)[0].split("\\|::\\|")[1]
										}
						);
						}
					
				sb.append(makeComboArr(listArr, "", "id=val_2", "", 300));
				//sb.append(makeCombo(conn, sql, "", "id=val_2", "", 300));
			}
			sb.append("</td>");
		}
		
		
		if (a_filter_type.equals("BY_PARTITION")){
			sb.append("<td>"); 
			sb.append("Partition to copy ");
			sql="select concat(cat_name,'.',schema_name,'.',tab_name) , family_id from tdm_tabs where id=(select tab_id from tdm_copy_filter where id="+a_filter_id+")";
		    ArrayList<String[]> partArr=getDbArrayConf(conn, sql, 1, null);
		    
		    
		    String table_name=partArr.get(0)[0];
		    String family_id=partArr.get(0)[1];
			
			partArr=getPartitionList(conn, env_id, family_id, table_name);
			if (partArr.size()==0) 
				sb.append("<br><font color=red>Partition list cannot be fetched or empty!!!</font>");
			else
				sb.append(makeComboArr(partArr, "", "id=val_1", "", 300));
			sb.append("</td>");
		}
		
		
		
		
		
		sb.append("</tr>");
		
		sb.append("</table>");
		
	}
	
	return sb.toString();
}


//*****************************************************
ArrayList<String[]> getPartitionList(Connection conn, String target_id, String family_id, String table_name) {
	
	String db_id="0";
	
	String sql="select env_id from tdm_target_family_env where target_id="+target_id+" and family_id="+family_id;
	db_id=getDBSingleVal(conn, sql);
	
	if (nvl(db_id,"0").equals("0")) {
		
		return new ArrayList<String[]>();
	}
	
	String partition_sql="";
	sql="select db_driver from tdm_envs where id="+db_id;
		
	String app_driver=getDBSingleVal(conn, sql);
	
	sql="select flexval2 from  tdm_ref where ref_type='DB_TYPE' and ref_name='"+app_driver+"'";
	String template="";
	
	try {
		template=getDbArrayConf(conn,sql, 1,new ArrayList<String[]>() ).get(0)[0];
	} catch(Exception e) {template="";};
	
	
	if (template.contains("|")) 
		try {partition_sql=template.split("\\|")[2];} catch(Exception e) {e.printStackTrace();  partition_sql="";}
	
	
	
			
	String curr_cat_name="";
	String curr_schema_name="";
	String curr_tab_name=table_name;
	
	if (table_name.contains(".")) {
		curr_cat_name=table_name.split("\\.")[0];
		curr_schema_name=table_name.split("\\.")[1];
		curr_tab_name=table_name.split("\\.")[2];
	}
		
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.add(new String[]{"STRING",curr_schema_name});
	bindlist.add(new String[]{"STRING",curr_tab_name});
	
	Connection connApp=getconn(conn, db_id);
	
	
	
	setCatalogForConnection(connApp, curr_cat_name);
	ArrayList<String[]> partitionArr=getDbArrayApp(connApp, partition_sql, Integer.MAX_VALUE, bindlist, false, "");


	closeconn(connApp);
	
	if (partitionArr==null) return new ArrayList<String[]>();
	
	return partitionArr;
	
}


//************************************************
int getProgressRate(Connection conn, String wpid) {
	int progress=0;
	
	String sql="select round((100*sum(success_count)/sum(export_count))) a from tdm_work_package " +
			" where work_plan_id=? and export_count>0";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",wpid});		
	
	try { progress=Integer.parseInt(getDbArrayConf(conn, sql, 1, bindlist).get(0)[0]);} catch(Exception e) {progress=0;}
	
	if (progress<0) progress=0;
	if (progress>100) progress=100;
	
	return progress;
}


//***************************************************
void changeScriptDescription(Connection conn, String script_id, String script_desc) {
	
	String sql="update tdm_auto_scripts set description=? where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"STRING",script_desc});
	bindlist.add(new String[]{"INTEGER",script_id});
	execDBConf(conn, sql, bindlist);
}



int editDomain(Connection conn, String domain_id, String domain_name) {
	
	String sql="select count(*) from tdm_domain_class where domain_class_name=? and id<>?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"STRING",domain_name});
	bindlist.add(new String[]{"INTEGER",domain_id});

	String x="";
	try{x=getDbArrayConf(conn, sql, 1, bindlist).get(0)[0];} catch(Exception e){}
	
	if (!nvl(x,"0").equals("0")) return 1;
	sql="update tdm_domain_class set domain_class_name=? where id=?";
	
	boolean is_ok=execDBConf(conn, sql, bindlist);
	if (!is_ok) return 2;
	return 0;
	
	
}

//***************************************************
String makeAppActionMenu(String app_type) {
	String ret1= ""+
			"<div class=\"dropdown btn-group-sm\">\n"+
			  "<button class=\"btn btn-default dropdown-toggle\" type=\"button\" id=\"dropdownMenu1\" data-toggle=\"dropdown\" aria-expanded=\"true\">\n"+
			    "..."+
			    "<span class=\"caret\">\n"+"</span>\n"+
			  "</button>\n"+
			  "<ul class=\"dropdown-menu\" role=\"menu\" aria-labelledby=\"dropdownMenu1\">\n"+
			  
			    "<li role=\"presentation\">\n"+
			    	"<button type=\"button\" class=\"btn btn-sm btn-info\" onclick=\"applicationBox('ADD');\" data-toggle=\"tooltip\" data-placement=\"left\" title=\"Add new application\">\n"+
				    	"<span class=\"glyphicon glyphicon-plus\">\n"+"</span>\n"+
				    "</button>\n"+
	   				" Add "+
				"</li><br>\n"+
				
			    "<li role=\"presentation\">\n"+
	   			    "<button type=\"button\" class=\"btn btn-sm btn-info\" onclick=\"applicationBox('RENAME');\" data-toggle=\"tooltip\" data-placement=\"left\" title=\"Rename application\">\n"+
				    	"<span class=\"glyphicon glyphicon-pencil\">\n"+"</span>\n"+
				    "</button>\n"+
	   				" Rename "+
				"</li><br>\n"+	
				
			    "<li role=\"presentation\">\n"+
				    "<button type=\"button\" class=\"btn btn-sm btn-danger\" onclick=\"applicationBox('REMOVE');\" data-toggle=\"tooltip\" data-placement=\"left\" title=\"Remove\">\n"+
				   		"<span class=\"glyphicon glyphicon-minus\">\n"+"</span>\n"+
				    "</button>\n"+
	   				" Delete "+
				"</li><br>\n" 
				;
				
				
				if (!app_type.equals("COPY") && !app_type.equals("DMASK") && !app_type.equals("DPOOL"))	
					ret1 = ret1 + 
					"<li role=\"presentation\">\n"+
					    "<button type=\"button\" class=\"btn btn-sm btn-default\"  onclick=\"scriptedit('PREP_SCRIPT');\" data-toggle=\"tooltip\" data-placement=\"left\" title=\"Preparing script editor\">\n"+
					  	  	"<span class=\"glyphicon glyphicon-log-in\">\n"+"</span>\n"+
					    "</button>\n"+
		   				" PrepScript "+
					"</li><br>\n"+	
				    "<li role=\"presentation\">\n"+
					    "<button type=\"button\" class=\"btn btn-sm btn-default\"  onclick=\"scriptedit('POST_SCRIPT');\" data-toggle=\"tooltip\" data-placement=\"left\" title=\"Post script editor\">\n"+
					    	"<span class=\"glyphicon glyphicon-log-out\">\n"+"</span>\n"+
					    "</button>\n"+
		   				" PostScript "+
					"</li>\n";
				
				ret1= ret1 + 
					"</ul>\n"+
				    "</div>\n";
			    
			    return ret1;
}

//***************************************************
String makeEnvActionMenu(String app_type) {
	
	
	String ret1="<button type=\"button\" class=\"btn btn-sm btn-default\"  onclick=\"refreshEnvironment();\" data-toggle=\"tooltip\" data-placement=\"left\" title=\"Refresh\">\n"+
	  	  	"<font color=green><span class=\"glyphicon glyphicon-refresh\"></span></font>\n"+
	    "</button>";
	    
	return ret1;
}

//*********************************************
String makeDomainInstanceCombo(Connection conn, String domain_id) {
	String sql="select id, domain_instance_name from tdm_domain_instance where domain_class_id="+domain_id+" order by 2";
	return "<b>Instance : </b><br>"+
			makeCombo(conn, sql, "", "id=domainInstanceList onchange=listDomainInstanceProperties(); size=1 ", "", 240);
}


//*********************************************
String makeDomainPropertiesList(Connection conn, String domain_id) {

	StringBuilder sb=new StringBuilder();
		
	

	String[] types=new String[]{"VARIABLE","PASSWORD","DB","FTP","TERMINAL"};
	String[] types_title=new String[]{"Variable","Password","Database","FTP Server","Platform"};									

	for (int t=0;t<types.length;t++) {	
		
		String prop_type=types[t];
		String prop_type_title=types_title[t];
		
		sb.append("<table class=\"table table-striped\">");

		sb.append("<tr class=success>");
		sb.append("<td valign=bottom>");
		sb.append("<img width=24 height=24 border=0 src=\"img/prop/"+prop_type+".png\"> <b><big>"+prop_type_title+"</big></b>");
		sb.append("</td>");
		
		sb.append("<tr class=info>");
		sb.append("<td>");
		sb.append("<button class=\"btn btn-sm btn-success\" onclick=\"addDomainProperty('"+prop_type+"','"+domain_id+"');\"><span class=\"glyphicon glyphicon-plus\"></span></button>");
		sb.append(" <button class=\"btn btn-sm btn-danger\" onclick=\"deleteDomainProperty('"+prop_type+"');\"><span class=\"glyphicon glyphicon-minus\"></span></button>");
		sb.append(" <button class=\"btn btn-sm btn-info\" onclick=\"configDomainProperty('"+prop_type+"');\"><span class=\"glyphicon glyphicon-cog\"></span></button>");
		sb.append("</td>");
		sb.append("</tr>");

		sb.append("</tr>");
		
		
		String sql="select id, domain_element_name "+
				" from tdm_domain_element "+
				" where domain_class_id=? and domain_element_type=? "+
				" order by domain_element_name";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",domain_id});
		bindlist.add(new String[]{"STRING",prop_type});

		ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<arr.size();i++) {
			String prop_id=arr.get(i)[0];
			String prop_name=arr.get(i)[1];
			
			sb.append("<tr>");
			sb.append("<td nowrap>");
			sb.append("<input type=checkbox id=check_"+prop_type+"_"+ i+ " value=\""+prop_id+"\">");
			sb.append(" <input type=text id=\""+prop_type+"_"+ i +"\" size=20 maxlength=100 value=\""+prop_name+"\" onchange=\"renameDomainProperty('"+domain_id+"','"+prop_id+"',this)\">");
			sb.append("</td>");
			sb.append("</tr>");


		}
		
		sb.append("</table>");
	}

	return sb.toString();
}



//******************************************
public String gethostinfo() {
	String ret1 = "";
	InetAddress addr;
	try {
		addr = InetAddress.getLocalHost();
		ret1 = addr.getHostName()+" ["+addr.getHostAddress()+"]";
	} catch (Exception e) {
		ret1 = "unknown";
	}
	
	return ret1;
}




//********************************************************************
String makeText(String id, String curr_val,String additional, int width) {
	return makeText(id, curr_val, additional, width, "EDITABLE");
}

//********************************************************************
String makeText(String id, String curr_val,String additional, int width, String field_mode) {
	StringBuilder sb=new StringBuilder();
	String width_str=""+Math.abs(width)+"px";
	if (width==0) width_str="100%";
	if (width<0) width_str=""+Math.abs(width)+"%";
	
	String disabled=""; 
	if (!field_mode.equals("EDITABLE") & !field_mode.equals("SEARCH")) disabled="disabled";
	
	sb.append("<div class=\"input-group\" style=\"width:"+width_str+";\">");
	sb.append("<input type=\"text\" "+disabled+" id=\""+id+"\" class=\"form-control\" value=\""+curr_val+"\" "+additional+" >");
	sb.append("</div>");
	
	return sb.toString();
}
//********************************************************************
String makePassword(String id, String curr_val,String additional, int width) {
	return makePassword(id, curr_val, additional, width, "EDITABLE");
}
//********************************************************************
String makePassword(String id, String curr_val,String additional, int width, String field_mode) {
	StringBuilder sb=new StringBuilder();
	String width_str=""+Math.abs(width)+"px";
	if (width==0) width_str="100%";
	if (width<0) width_str=""+Math.abs(width)+"%";
	
	String disabled=""; 
	if (!field_mode.equals("EDITABLE") & !field_mode.equals("SEARCH")) disabled="disabled";
	
	sb.append("<div class=\"input-group\" style=\"width:"+width_str+";\">");
	sb.append("<input type=\"password\" "+disabled+" id=\""+id+"\" class=\"form-control\" value=\""+curr_val+"\" "+additional+" >");
	sb.append("</div>");
	
	return sb.toString();
}

//********************************************************************

String makeDateCondition(String FILTER_DATETIME, ArrayList<String[]> datecondbindlist) {
	StringBuilder sb=new StringBuilder();
	
	String from_date="x";
	String to_date="x";
	String formula="x";
	
	try{from_date=FILTER_DATETIME.split("with")[0].split("to")[0];} catch(Exception e) {}
	try{to_date=FILTER_DATETIME.split("with")[0].split("to")[1];} catch(Exception e) {}
	try{formula=FILTER_DATETIME.split("with")[1];} catch(Exception e) {}
	
	
	String from_date_formatted="";
	String to_date_formatted="";
	
	String condition_type="between";
	
	if(!from_date.equals("x") && !to_date.equals("x") && formula.equals("x")) {
		condition_type="between";
		from_date_formatted=from_date;
		to_date_formatted=to_date;
	}
	
	if(from_date.equals("x") && !to_date.equals("x")) {
		condition_type="to";
		to_date_formatted=to_date;
	}
	
	if(!from_date.equals("x") && to_date.equals("x")) {
		condition_type="from";
		from_date_formatted=from_date;
	}
	
	if(from_date.equals("x") && to_date.equals("x")) {
		condition_type="formula";
	}
	
	if (condition_type.equals("between") && from_date.equals(to_date)) {
		condition_type="equals";
		from_date_formatted=from_date;
		to_date_formatted=to_date;
	}
	
	if (condition_type.equals("between")) {
		sb.append( " between STR_TO_DATE(?,'"+mysql_format+"') and STR_TO_DATE(?,'"+mysql_format+"') ");
		datecondbindlist.add(new String[]{"STRING",""+from_date_formatted});
		datecondbindlist.add(new String[]{"STRING",""+to_date_formatted});
	}
	
	if (condition_type.equals("to")) {
		sb.append( " <= STR_TO_DATE(?,'"+mysql_format+"') ");
		datecondbindlist.add(new String[]{"STRING",""+to_date_formatted});
	}
	
	if (condition_type.equals("from")) {
		sb.append( " >= STR_TO_DATE(?,'"+mysql_format+"') ");
		datecondbindlist.add(new String[]{"STRING",""+from_date_formatted});
	}
	
	if (condition_type.equals("equals")) {
		sb.append( " = STR_TO_DATE(?,'"+mysql_format+"') ");
		datecondbindlist.add(new String[]{"STRING",""+from_date_formatted});
	}
	
	if (condition_type.equals("formula")) {


		String formula_type="";
		int formula_count=0;
		
		try {formula_type=formula.split(":")[0]; } catch(Exception e) {e.printStackTrace();} 
		try {formula_count=Integer.parseInt(formula.split(":")[1]); } catch(Exception e) {e.printStackTrace();}
		
		if (formula_type.indexOf("THIS_")==0) {
			String date_function="";
			if (formula_type.equals("THIS_YEAR")) 
				sb.append( " >=DATE_SUB(CURDATE(),INTERVAL DAYOFYEAR(CURDATE())-1 DAY) ");
			if (formula_type.equals("THIS_MONTH")) 
				sb.append( " >=DATE_SUB(CURDATE(),INTERVAL DAYOFMONTH(CURDATE())-1 DAY) ");
			if (formula_type.equals("THIS_WEEK")) 
				sb.append( " >=DATE_SUB(CURDATE(),INTERVAL WEEKDAY(CURDATE()) DAY) ");
			if (formula_type.equals("THIS_DAY")) 
				sb.append( " >=CURDATE() ");
		} else {
			sb.append( " >=DATE_SUB(now(), INTERVAL ? "+formula_type+") ");
			datecondbindlist.add(new String[]{"INTEGER",""+formula_count});
		}
	}
	
	return sb.toString();
}



//********************************************************************

String makeNumberCondition(String FILTER_NUMBER, ArrayList<String[]> datecondbindlist) {
	StringBuilder sb=new StringBuilder();
	
	String from_number="x";
	String to_number="x";
	
	
	
	try{from_number=FILTER_NUMBER.split("to")[0];} catch(Exception e) {}
	try{to_number=FILTER_NUMBER.split("to")[1];} catch(Exception e) {}
	
	
	String condition_type="none";
	
	if(!from_number.equals("x") && !to_number.equals("x")) {
		if (from_number.equals(to_number)) condition_type="equals";
		else  condition_type="between";
	}
	
	if(from_number.equals("x") && !to_number.equals("x")) {
		condition_type="to";
	}
	
	if(!from_number.equals("x") && to_number.equals("x")) {
		condition_type="from";
	}
	
	if(from_number.equals("x") && to_number.equals("x")) {
		condition_type="none";
	}
	
	
	
	if (condition_type.equals("between")) {
		sb.append( " between ? and ? ");
		datecondbindlist.add(new String[]{"DOUBLE",""+from_number});
		datecondbindlist.add(new String[]{"DOUBLE",""+to_number});
	}
	
	if (condition_type.equals("equals")) {
		sb.append( " = ? ");
		datecondbindlist.add(new String[]{"DOUBLE",""+from_number});
	}
	
	
	if (condition_type.equals("to")) {
		sb.append( " <= ? ");
		datecondbindlist.add(new String[]{"DOUBLE",""+to_number});
	}
	
	if (condition_type.equals("from")) {
		sb.append( " >= ? ");
		datecondbindlist.add(new String[]{"DOUBLE",""+from_number});
	}
	
	
	return sb.toString();
}
//********************************************************************
String makeDateFormula(String id, String curr_date_formula) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> arrF=new ArrayList<String[]>();
	arrF.add(new String[]{"THIS_DAY","Today"});
	arrF.add(new String[]{"THIS_WEEK","This Week"});
	arrF.add(new String[]{"THIS_MONTH","This Month"});
	arrF.add(new String[]{"THIS_YEAR","This Year"});
	arrF.add(new String[]{"DAY","Day(s) old"});
	arrF.add(new String[]{"WEEK","Week(s) old"});
	arrF.add(new String[]{"MONTH","Month(s) old"});
	arrF.add(new String[]{"YEAR","Year(s) old"});
	arrF.add(new String[]{"HOUR","Hour(s) old"});
	arrF.add(new String[]{"MINUTE","Minute(s) old"});
	
	String formula_type="";
	int formula_count=1;
	
	try{formula_type=curr_date_formula.split(":")[0];} catch(Exception e) {}
	try{formula_count=Integer.parseInt(curr_date_formula.split(":")[1]);} catch(Exception e) {}
	
	sb.append("<input type=hidden id=\"formula_"+id+"\" value=\""+curr_date_formula+"\">");
	
	sb.append("<div class=\"row\">");
	sb.append("<div class=\"col-md-12\">");
	sb.append("<table>");
	sb.append("<tr>");
	sb.append("<td>");
	sb.append(makeText("formula_period_count_"+id, ""+formula_count, " onchange=\"setDateFormulaPeriodCountField('"+id+"');\" ", 80));
	sb.append("</td>");
	sb.append("<td>");
	sb.append(makeComboArr(arrF, "", "id=\"formula_type_"+id+"\"   onchange=\"setDateFormulaPeriodCountField('"+id+"');\" ", formula_type, 200));
	sb.append("</td>");
	sb.append("</tr>");
	sb.append("</table>");
	sb.append("</div>");
	sb.append("</div>");
	return sb.toString();
}

//********************************************************************
String makeDate(String table_id, String id, String curr_val, String additional) {
	
	return makeDate(table_id, id, curr_val, additional, "EDITABLE");
}
//********************************************************************
String makeDate(String table_id, String id, String curr_val, String additional, String field_mode) {
	StringBuilder sb=new StringBuilder();
	
	if (field_mode.equals("SEARCH")) {
		
		String curr_val_start="";
		String curr_val_end="";
		String curr_val_formula="";
		
		String[] arr=curr_val.split("with");
		try{curr_val_formula=arr[1];} catch(Exception e) {curr_val_formula="";}
		
		
		
		try{curr_val_start=arr[0].split("to")[0];} catch(Exception e) {curr_val_start="";}
		try{curr_val_end=arr[1].split("to")[1];} catch(Exception e) {curr_val_end=curr_val_start;}
		
		if (curr_val_start.equals("x")) curr_val_start="";
		if (curr_val_end.equals("x")) curr_val_end="";
		if (nvl(curr_val_formula,"x").equals("x")) curr_val_formula="";

		String start_checked="";
		String end_checked="";
		String formula_checked="";
		String formula_style="visibility:hidden; ";
		
		if (curr_val_start.length()>0) start_checked="checked";
		if (curr_val_end.length()>0) end_checked="checked";
		if (curr_val_formula.length()>0) {
			formula_checked="checked";
			formula_style="";
		}
		
		
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-1\" align=right style=\"white-space: nowrap; \"> <font color=blue>From</font> ");
		sb.append("<input "+start_checked+" type=checkbox id=\"ch_from_of_"+id+"\" onclick=setDateTimeVisibility(this,'search_start','"+id+"');> :");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeDate("0","search_start_"+id, curr_val_start, additional, "SEARCH_START"));
		sb.append("</div>");
		sb.append("</div>");
				
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-1\" align=right style=\"white-space: nowrap; \"> <font color=blue>To</font> ");
		sb.append("<input "+end_checked+" type=checkbox id=\"ch_to_of_"+id+"\" onclick=setDateTimeVisibility(this,'search_end','"+id+"');> : ");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\" >");
		sb.append(makeDate("0","search_end_"+id, curr_val_end, additional, "SEARCH_END"));
		sb.append("</div>");
		sb.append("</div>");
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-1\" align=right style=\"white-space: nowrap; \"> <font color=blue>Formula</font> ");
		sb.append("<input "+formula_checked+" type=checkbox id=\"ch_formula_of_"+id+"\" onclick=setDateTimeVisibility(this,'formula','"+id+"');> : ");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append("<div id=\"NOFADE_datepicker_formula_"+id+"\" style=\""+formula_style+"\">");
		sb.append(makeDateFormula(id, curr_val_formula));
		sb.append("</div>");
		sb.append("</div>");
		sb.append("</div>");
				
		
	} else {
		String style="";
		if ((field_mode.equals("SEARCH_START") || field_mode.equals("SEARCH_END")) && curr_val.length()==0) {
			style="visibility:hidden;";
		}


		
		sb.append("<div id=\"NOFADE_datepicker_"+id+"\" style=\""+style+"\">");
		sb.append(makeDateContent(table_id, id, curr_val, additional, field_mode));
		sb.append("</div>");
	}
	
	
	return sb.toString(); 
}


//********************************************************************
String makeNumber(String table_id, String id, String curr_val, String onchange_script, String field_mode, 
		String fixed_length, 
		String decimal_length,
		String grouping_char,
		String decimal_char,
		String currency_symbol,
		String min_val,
		String max_val
		) {
	
	StringBuilder sb=new StringBuilder();
	
	
	if (field_mode.equals("SEARCH")) {
		
		String curr_val_start="";
		String curr_val_end="";
		
		try{curr_val_start=curr_val.split("to")[0];} catch(Exception e) {curr_val_start="";}
		try{curr_val_end=curr_val.split("to")[1];} catch(Exception e) {curr_val_end=curr_val_start;}
		
		if (curr_val_start.equals("x")) curr_val_start="";
		if (curr_val_end.equals("x")) curr_val_end="";

		String start_checked="";
		String end_checked="";
		
		if (curr_val_start.length()>0) start_checked="checked";
		if (curr_val_end.length()>0) end_checked="checked";
		
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-12\">");
		
		
		sb.append("<table border=0 cellspacing=0 cellpadding=0>");
		sb.append("<tr>");
		
		sb.append("<td width=80px; align=right><font color=blue>From :</font></td>");
		sb.append("<td><input "+start_checked+" type=checkbox id=\"ch_from_of_"+id+"\" onclick=setNumberVisibility(this,'search_start','"+id+"');> :</td>");
		sb.append("<td>");
		sb.append(makeNumber("0","search_start_"+id, curr_val_start, "", "SEARCH_START", 
				fixed_length, 
				decimal_length,
				grouping_char,
				decimal_char,
				currency_symbol,
				min_val,
				max_val));
		sb.append("</td>");
		
		sb.append("<td width=80px; align=right><font color=blue>To :</font></td>");
		sb.append("<td><input "+end_checked+" type=checkbox id=\"ch_to_of_"+id+"\" onclick=setNumberVisibility(this,'search_end','"+id+"');> : </td>");
		sb.append("<td>");
		sb.append(makeNumber("0","search_end_"+id, curr_val_end, "", "SEARCH_END",
				fixed_length, 
				decimal_length,
				grouping_char,
				decimal_char,
				currency_symbol,
				min_val,
				max_val));
		sb.append("</td>");
		sb.append("</tr>");
		sb.append("</table>");
		
		
		
		
		
		sb.append("</div>");
		sb.append("</div>");

		
		
	} else {
		String style="";
		if ((field_mode.equals("SEARCH_START") || field_mode.equals("SEARCH_END")) && curr_val.length()==0) {
			style="visibility:hidden;";
		}


		

		sb.append("<div id=\"NOFADE_numberinput_"+id+"\" style=\""+style+"\">");
		sb.append(makeNumberContent(table_id, id, curr_val, field_mode, onchange_script, 
				fixed_length, 
				decimal_length,
				grouping_char,
				decimal_char,
				currency_symbol,
				min_val,
				max_val));
		sb.append("</div>");
	}
	
	
	return sb.toString(); 
}



//********************************************************************
String makeDateContent(String table_id, String id, String curr_val, String additional, String field_mode) {
	StringBuilder sb=new StringBuilder();
	Calendar cal=Calendar.getInstance();
	//dd.mm.yyyy or dd.mm.yyyy hh24:mi:ss
	int day=cal.get(Calendar.DAY_OF_MONTH);
	int month=cal.get(Calendar.MONTH)+1;
	int year= cal.get(Calendar.YEAR);
	int hour=cal.get(Calendar.HOUR_OF_DAY);
	int minute=cal.get(Calendar.MINUTE);
	int second=cal.get(Calendar.SECOND);
	String size_1=" size=1 ";
	
	
	
	
	
	String date_part=curr_val;
	String hour_part="";
	
	//check if 
	if (curr_val.contains(" ")) {
		date_part=curr_val.split(" ")[0];
		hour_part=curr_val.split(" ")[1];
		
		
	}
	
	if (hour_part.length()>0) {
		String[] arr=hour_part.split(":");
		try{hour=Integer.parseInt(arr[0]);} catch(Exception e) {}
		try{minute=Integer.parseInt(arr[1]);} catch(Exception e) {}
		try{second=Integer.parseInt(arr[2]);} catch(Exception e) {}
		
	}
	
	
	String[] arr=date_part.split("\\.");
	try{day=Integer.parseInt(arr[0]);} catch(Exception e) {}
	try{month=Integer.parseInt(arr[1]);} catch(Exception e) {}
	try{year=Integer.parseInt(arr[2]);} catch(Exception e) {}
	
	if (year<1900) year=1900;
	if (year>2100) year=2100;
	
	if (month<1) month=1;
	if (month>12) month=12;
	
	if (day<1) day=1;
	int max_day=30;
	if (month==1 || month==3 || month==5 || month==7 || month==8 || month==11) max_day=31;
	if (month==2) {
		max_day=28;
		if (year % 4==0) max_day=29;
	}

	if (day>max_day) day=max_day;
	
	
	Locale locale = Locale.getDefault();
	
	String[] monthlist=new String[]{"January","February","March","April","May","June","July","August","September","October","November","December"};
	
	ArrayList<String[]> arrDay=new ArrayList<String[]>();
	ArrayList<String[]> arrMonth=new ArrayList<String[]>();
	ArrayList<String[]> arrYear=new ArrayList<String[]>();
	
	
	
	for (int i=1;i<=max_day;i++) arrDay.add(new String[]{""+i,""+i});
	for (int i=1;i<=12;i++) arrMonth.add(new String[]{""+i,""+i+"."+monthlist[i-1]});
	int curr_year= cal.get(Calendar.YEAR);
	for (int i=curr_year-50;i<=curr_year+20;i++) arrYear.add(new String[]{""+i,""+i});
	
	String script=" onchange=\"changeDatePicker('"+table_id+"',this,'"+id+"','"+field_mode+"','"+additional+"');\"  ";
	
	String disabled="";
	if (!field_mode.equals("EDITABLE") && field_mode.indexOf("SEARCH")==-1)  disabled="disabled ";
	
	String valid_curr_val=""+day+"."+month+"."+year;
	if (hour_part.length()>0) 
		valid_curr_val=valid_curr_val+" "+hour+":"+minute+":"+second;
	sb.append("<input type=hidden id=\""+id+"\" value=\""+valid_curr_val+"\" "+additional+" >");
	
	sb.append("<table border=0 cellspacing=0 cellpadding=0>");
	sb.append("<tr>"); 
	 
	sb.append("<td><span class=\"glyphicon glyphicon-calendar\"></span></td>");
	sb.append("<td>"+makeComboArr(arrDay, "", disabled + script+size_1+" id=datepicker_day_of_"+id, ""+day, 75)+"</td>");
	sb.append("<td>"+makeComboArr(arrMonth, "", disabled + script+size_1+" id=datepicker_month_of_"+id, ""+month, 120)+"</td>");
	sb.append("<td>"+makeComboArr(arrYear, "", disabled + script+size_1+" id=datepicker_year_of_"+id, ""+year, 90)+"</td>");

	if (hour_part.length()>0) {
		ArrayList<String[]> arrHour=new ArrayList<String[]>();
		ArrayList<String[]> arrMinute=new ArrayList<String[]>();
		ArrayList<String[]> arrSecond=new ArrayList<String[]>();
		
		for (int i=0;i<24;i++) arrHour.add(new String[]{""+i,""+i});
		for (int i=0;i<60;i++) {arrMinute.add(new String[]{""+i,""+i}); arrSecond.add(new String[]{""+i,""+i});}
		
		sb.append("<td><span class=\"glyphicon glyphicon-dashboard\"></span></td>");
		sb.append("<td>"+makeComboArr(arrHour, "", disabled + script+size_1+" id=datepicker_hour_of_"+id, ""+hour, 80)+"</td>");
		sb.append("<td><big><big>:</big></big><td>");
		sb.append("<td>"+makeComboArr(arrMinute, "", disabled + script+size_1+" id=datepicker_minute_of_"+id, ""+minute, 80)+"</td>");
		sb.append("<td><big><big>:</big></big><td>");
		sb.append("<td>"+makeComboArr(arrSecond, "", disabled + script+size_1+" id=datepicker_second_of_"+id, ""+second, 80)+"</td>");
	}
	
	sb.append("</tr>");
	sb.append("</table>");
	
	
	
	return sb.toString();
}


//********************************************************************
String groupNumber(String numberin, String grouping_char) {
	String ret1="";
	String numerics="0123456789";
	int p=0;
	for (int i=numberin.length()-1;i>=0;i--) {
		
		char chr=numberin.charAt(i);
		if (numerics.indexOf(""+chr)==-1) continue;
		p++;
		ret1=chr+ret1;
		if ((p>1) && (p % 3==0) && (i!=0)) ret1=grouping_char+ret1;
	}
    if (ret1.length()==0) ret1="0";
	return ret1;
}
//********************************************************************
String makeNumberContent(String table_id, String id, String curr_val, String field_mode, String onchange_script,
		String fixed_length, 
		String decimal_length,
		String grouping_char,
		String decimal_char,
		String currency_symbol,
		String min_val,
		String max_val) {
	StringBuilder sb=new StringBuilder();
	
	
	String js_script_code="";
	if (onchange_script.length()>0) js_script_code=" onchange=\""+onchange_script+"\" ";
	

	
	String curr_val_fixed="0";
	String curr_val_decimal="0";
	try {curr_val_fixed=curr_val.split("\\.")[0];} catch(Exception e) {}
	try {curr_val_decimal=curr_val.split("\\.")[1];} catch(Exception e) {}
		
	if (curr_val_decimal.length()>Integer.parseInt(decimal_length)) 
		try{curr_val_decimal=curr_val_decimal.substring(0,Integer.parseInt(decimal_length));} catch(Exception e) { e.printStackTrace(); }
	if (Integer.parseInt(decimal_length)==0)
		curr_val_decimal="";
	else 
		try{curr_val_decimal=(curr_val_decimal+"0000000000").substring(0,Integer.parseInt(decimal_length));} catch(Exception e) { e.printStackTrace(); }
	
	curr_val_fixed=groupNumber(curr_val_fixed,grouping_char);

	

	sb.append(
  		"  <input type=hidden id=\""+id+"\" value=\""+curr_val+"\" min_val=\""+min_val+"\" max_val=\""+max_val+"\" "+js_script_code+"  > \n"+
		"   \n"+
		"  <table border=0 cellspacing=0 cellpadding=0> \n"+
		"  <tr> \n"+
		"  <td> \n"+
		"  	<input type=\"text\" id=\""+id+"_fixed\" value=\""+curr_val_fixed+"\" size="+fixed_length+" maxlength="+fixed_length+" style=\"text-align: right;\"  grouping=\""+grouping_char+"\"  onfocus=onNumericFieldEnter(this,'fixed') onblur=onNumericFieldExit(this,'fixed')  > \n"+
		"  </td> \n");
	
	if (decimal_char.length()>0 && Integer.parseInt(decimal_length)>0)
		sb.append("  <td><b>"+decimal_char+"</b></td> \n");
	
	if (!nvl(decimal_length,"0").equals("0"))
		sb.append(
			"  <td> \n"+
			"  <input type=\"text\" id=\""+id+"_decimal\" value=\""+curr_val_decimal+"\" size="+decimal_length+" maxlength="+decimal_length+" style=\"text-align: left;\"   onfocus=onNumericFieldEnter(this,'decimal') onblur=onNumericFieldExit(this,'decimal')> \n"+
			"  </td>  \n");
	
	if (decimal_char.length()>0)
		sb.append("  <td><span class=\"badge\">"+currency_symbol+"</span></td> \n");
	
	sb.append(
		"  \n"+
		"  </tr> \n"+
		"  </table> \n"
	);
	
	
	return sb.toString();
}

//********************************************************************
String makeList(Connection conn, String id, String sql, String curr_value, String additional, int width, String env_id) {
	return makeList(conn, id, sql, curr_value, additional, width, env_id, "EDITABLE");
}

//********************************************************************
String makeList(Connection conn, String id, String sql, String curr_value, String additional, int width, String env_id, String field_mode) {
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> arr=new ArrayList<String[]>();

	
	if (sql.toLowerCase().indexOf("select")<10 && sql.toLowerCase().indexOf("select")>-1)
		{
		
			
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			
			arr=getDbArrayApp(conn, env_id, sql, Integer.MAX_VALUE, bindlist);
			if (arr==null) arr=new ArrayList<String[]>();
		}
	else {
		String[] lines=sql.split("\n|\r");
		for (int i=0;i<lines.length;i++) {
			String val="";
			String title="";
			try {val=lines[i].split(":")[0];} catch(Exception e) {val=lines[i];}
			try {title=lines[i].split(":")[1];} catch(Exception e) {title=lines[i];}
			if (val.length()>0) arr.add(new String[]{val,title});
		}
		
	}
	
	if (field_mode.equals("EDITABLE"))
		sb.append(makeComboArr(arr, "", "id=\""+id+"\" "+additional, curr_value, width));
	else if (field_mode.equals("READONLY")) {
		sb.append(makeComboArr(arr, "", "id=\""+id+"\" disabled", curr_value, width));
	}
	else {
		ArrayList<String[]> targetArr=new ArrayList<String[]>();
		String[] arrx=curr_value.split("\\|::\\|");
		for (int i=0;i<arrx.length;i++)
			if (arrx[i].trim().length()>0) targetArr.add(new String[]{arrx[i]});
		
		sb.append(makePickList("0","search_of_"+id, arr, targetArr, "", "", "EDITABLE"));
	}
		
	
	return sb.toString();

}

//********************************************************************
String makeCheckbox(String table_id, String id, String curr_value, String additional) {
	return makeCheckbox(table_id, id, curr_value, additional, "EDITABLE");
}


//********************************************************************
String makeCheckbox(String table_id, String id, String curr_value, String additional, String field_mode) {
	StringBuilder sb=new StringBuilder();
		
	if (field_mode.equals("SEARCH")) {
		ArrayList<String[]> arr=new ArrayList<String[]>();
		arr.add(new String[]{"ALL","Any"});
		arr.add(new String[]{"YES","Yes"});
		arr.add(new String[]{"NO","No"});
		
		sb.append(makeComboArr(arr, "", "size=1 id=value_of_"+id + " ", nvl(curr_value,"ALL"), 120));
	}
	else {
		
		String disabled="";
		if (!field_mode.equals("EDITABLE")) disabled="disabled";

		String checked="";
		if (curr_value.equals("YES")) checked="checked";
		
		sb.append("<input type=\"checkbox\" "+disabled+" id=\""+id+"\" "+checked+"  onclick=setCheckboxVal('"+table_id+"','"+id+"'); value=\""+curr_value+"\"  "+additional+" > ");
	}
	
	  
	
	return sb.toString();

}

//********************************************************************
public static String humanReadableByteCount(long bytes) {
    boolean si=true;
	int unit = si ? 1000 : 1024;
    if (bytes < unit) return bytes + " B";
    int exp = (int) (Math.log(bytes) / Math.log(unit));
    String pre = (si ? "kMGTPE" : "KMGTPE").charAt(exp-1) + (si ? "" : "i");
    return String.format("%.1f %sB", bytes / Math.pow(unit, exp), pre);
}

//********************************************************************
String clearHtml(String instr) {
	
	StringBuilder sb=new StringBuilder();
	sb.append(instr);
	
	ArrayList<String[]> replArr=new ArrayList<String[]>();
	
	
	replArr.add(new String[]{"\"","&quot;"});
	replArr.add(new String[]{"<","&#60;"});
	replArr.add(new String[]{">","&#62;"});
	replArr.add(new String[]{"&#32;"," "}); //space
	
	for (int i=0;i<replArr.size();i++) {
		String what=replArr.get(i)[0];
		String with=replArr.get(i)[1];
		
		while(true) {
			int pos=sb.indexOf(what);
			if (pos==-1) break;
			sb.delete(pos, pos+what.length());
			sb.insert(pos, with);
		}
	} //for
	
	//clear "
	//for (int i=sb.length()-1;i>=0;i--) if (sb.charAt(i)=='"') sb.insert(i, "\\");
	

	return sb.toString();
	
}


//********************************************************************
String getListTitleById(String listval,String list_items) {
	String ret1=listval;
	String[] lines=list_items.split("\n|\r");
	StringBuilder a_val=new StringBuilder();
	StringBuilder a_title=new StringBuilder();
	StringBuilder a_line=new StringBuilder();
	
	
	for (int i=0;i<lines.length;i++) {
		
		a_line.setLength(0);
		a_line.append(lines[i]);
		a_val.setLength(0);
		a_title.setLength(0);
		
		try{a_val.append(a_line.toString().split(":")[0]);} catch(Exception e) {};
		try{a_title.append(a_line.toString().split(":")[1]);} catch(Exception e) {a_title.append(a_val);};
				
		if (a_val.toString().equals(listval)) return a_title.toString();
	}
	
	return ret1;
}


//********************************************************************
String formatNumber(
		String unformattedval,
		String num_fixed_length, 
		String num_decimal_length, 
		String num_grouping_char, 
		String num_decimal_char, 
		String num_currency_symbol) {
	
	String ret1="";
	
	String fixed_part="0";
	String decimal_part="0";
	
	try {fixed_part=unformattedval.split("\\.")[0];} catch(Exception e) {}
	try {decimal_part=unformattedval.split("\\.")[1];} catch(Exception e) {}
	
	fixed_part=groupNumber(fixed_part, num_grouping_char);
	
	ret1=fixed_part;
	if (num_decimal_char.length()>0) {
		String uncut_decimal_part=decimal_part+"000000";
		try {
			uncut_decimal_part=uncut_decimal_part.substring(0,Integer.parseInt(num_decimal_length));
		} catch(Exception e) {
			uncut_decimal_part=decimal_part;
			
		}
		
		ret1=ret1+num_decimal_char+uncut_decimal_part;
	}
		
	
	if (num_currency_symbol.length()>0) 
		ret1=ret1+"  <font color=blue>"+num_currency_symbol+"</font>";


	
	return ret1;
}



//***********************************************
String makePickList(
		String table_id,
		String id, 
		ArrayList<String[]> source_arr, 
		ArrayList<String[]> picked_arr, 
		String picklist_header, 
		String event_listener) {
	return makePickList(table_id, id, source_arr, picked_arr, picklist_header, event_listener, "EDITABLE");
}

//***********************************************
String makePickList(
		String table_id,
		String id, 
		ArrayList<String[]> source_arr, 
		ArrayList<String[]> picked_arr, 
		String picklist_header, 
		String event_listener,
		String field_mode) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> source_arr_edited=source_arr;

	
	for (int i=source_arr.size()-1;i>=0;i--) {
		for (int j=0;j<picked_arr.size();j++) {
			if (source_arr.get(i)[0].equals(picked_arr.get(j)[0])) {
				picked_arr.set(j, source_arr_edited.get(i));
				source_arr_edited.remove(i);
				break;
			}
				
		}
			
	}
	
	String curr_val="";
	for (int i=0;i<picked_arr.size();i++) {
		String a_val=picked_arr.get(i)[0];
		if (i>0) curr_val=curr_val+"|::|";
		curr_val=curr_val+a_val;
	}
	
	if (picklist_header.length()>0) {
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-12 active\">");
		sb.append("<h4><span class=\"label label-info\">"+picklist_header+"</label></h4>"); 
		sb.append("</div>");
		sb.append("</div>");
	}
	sb.append("<input type=hidden id=\""+id+"\" value=\""+codehtml(curr_val)+"\">");
	sb.append("<input type=hidden id=\"event_listener_for_"+id+"\" value=\""+codehtml(event_listener)+"\">");
	
	
	String disabled="";
	if (!field_mode.equals("EDITABLE") && !field_mode.equals("SEARCH")) disabled="disabled";
	
	sb.append("<div class=row>");
	
	sb.append("<div class=\"col-md-6\" align=right>");

	sb.append(makeComboArr(source_arr_edited, "", disabled+" size=5 id=\"source_list_"+id+"\" onclick=\"setPicklistButtons('SOURCE','"+id+"');\"  onDblClick=\"pickListAction('"+table_id+"','"+id+"','ADD_ONE');\" ", "", -100));
	sb.append("</div>"); //col-md-5
	
	sb.append("<div class=\"col-md-1\" align=center>");
	
	String add_all_disabled="";
	String remove_all_disabled="";
	
	if (source_arr_edited.size()==0) add_all_disabled="disabled";
	if (picked_arr.size()==0) remove_all_disabled="disabled";
	
	sb.append("<button disabled class=\"btn btn-sm btn-default\" id=\"bt_add_one_"+id+"\" onclick=\"pickListAction('"+table_id+"','"+id+"','ADD_ONE');\"><span class=\"glyphicon glyphicon-step-forward\"></span></button>");
	sb.append("<br>");
	//sb.append("<button "+add_all_disabled+" class=\"btn btn-sm btn-default\" id=\"bt_add_all_"+id+"\" onclick=\"pickListAction('"+table_id+"','"+id+"','ADD_ALL');\"><span class=\"glyphicon glyphicon-fast-forward\"></span></button>");
	sb.append("<button disabled class=\"btn btn-sm btn-default\" id=\"bt_add_all_"+id+"\" onclick=\"pickListAction('"+table_id+"','"+id+"','ADD_ALL');\"><span class=\"glyphicon glyphicon-fast-forward\"></span></button>");
	
	sb.append("<br>");
	
	sb.append("<button disabled class=\"btn btn-sm btn-default\" id=\"bt_remove_one_"+id+"\" onclick=\"pickListAction('"+table_id+"','"+id+"','REMOVE_ONE');\"><span class=\"glyphicon glyphicon-step-backward\"></span></button>");
	sb.append("<br>");
	//sb.append("<button "+remove_all_disabled+" class=\"btn btn-sm btn-default\" id=\"bt_remove_all_"+id+"\" onclick=\"pickListAction('"+table_id+"','"+id+"','REMOVE_ALL');\"><span class=\"glyphicon glyphicon-fast-backward\"></span></button>");
	sb.append("<button disabled class=\"btn btn-sm btn-default\" id=\"bt_remove_all_"+id+"\" onclick=\"pickListAction('"+table_id+"','"+id+"','REMOVE_ALL');\"><span class=\"glyphicon glyphicon-fast-backward\"></span></button>");
	
	sb.append("</div>"); //col-md-1
	
	sb.append("<div class=\"col-md-5\"  align=left>");
	sb.append(makeComboArr(picked_arr, "", disabled+" size=5 id=\"target_list_"+id+"\" onclick=\"setPicklistButtons('TARGET','"+id+"');\" onDblClick=\"pickListAction('"+table_id+"','"+id+"','REMOVE_ONE');\" ", "", -100));
	sb.append("</div>"); //col-md-5
	
	sb.append("</div>"); //row
	
	return sb.toString();
}





//********************************************************************************
String addCollapseItem(String accordion_id, String accordion_item_id, String title,String body, String icon, String onclick) {
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=\"panel-heading\" role=\"tab\" id=\"heading_"+accordion_item_id+"\" >");
	
	sb.append("<h4 class=\"panel-title\">");
	
	String jsonclick="";
	if (onclick.length()>0) 
		jsonclick=" onclick=\""+onclick+"\" ";
	
	sb.append("<a data-toggle=\"collapse\" "+jsonclick+" data-parent=\"#"+accordion_id+"\" href=\"#"+accordion_item_id+"\" aria-expanded=\"true\" aria-controls=\""+accordion_item_id+"\">");
	sb.append("<img width=18 height=18 src=\"img/mad/"+icon+"\"> <b> "+title + "</b>");
	sb.append("</a>");
	
	
	sb.append("</h4>");
	
	
	sb.append("<div id=\""+accordion_item_id+"\" class=\"panel-collapse collapse\" role=\"tabpanel\" aria-labelledby=\"heading_"+accordion_item_id+"\">");
	
	sb.append("<div class=\"panel-body\" id=\""+accordion_item_id+"Body\">");
	sb.append(body);
	sb.append("</div>"); // panel-body
	
	sb.append("</div>"); // panel-collapse collapse in
	
	sb.append("</div>"); //"panel-heading
	
	return sb.toString();
}




//********************************************************************************
String addCollapse(String id,ArrayList<String[]> collapseItems) {
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=\"panel-group\" id=\""+id+"\" role=\"tablist\" aria-multiselectable=\"false\">");
	
	sb.append("<div class=\"panel panel-default\">");
	
	for (int i=0;i<collapseItems.size();i++) {
		String collapse_item_id=collapseItems.get(i)[0];
		String collapse_item_title=collapseItems.get(i)[1];
		String collapse_item_body=collapseItems.get(i)[2];
		String collapse_item_icon=collapseItems.get(i)[3];
		String collapse_item_additional="";
		if (collapseItems.get(i).length==5) collapse_item_additional=collapseItems.get(i)[4];
		
		sb.append(addCollapseItem(id,collapse_item_id,collapse_item_title, collapse_item_body, collapse_item_icon, collapse_item_additional));
		
	}
	
	sb.append("</div>"); //"panel panel-default
	
	sb.append("</div>"); // panel-group
	
	
	return sb.toString();
}




//********************************************************************************
String addTab(String id,ArrayList<String[]> tabItems) {
	
	StringBuilder sb=new StringBuilder();
	StringBuilder sbTitle=new StringBuilder();
	StringBuilder sbBody=new StringBuilder();

	for (int i=0;i<tabItems.size();i++) {
		String tab_item_id=tabItems.get(i)[0];
		String tab_item_title=tabItems.get(i)[1];
		String tab_item_body=tabItems.get(i)[2];
		String tab_item_icon=tabItems.get(i)[3];
		String tab_item_additional="";
		if (tabItems.get(i).length==5) tab_item_additional=tabItems.get(i)[4];
		String active="";
		if (i==0) active="active";
		
		
		String jsonclick="";
		if (tab_item_additional.length()>0) 
			jsonclick=" onclick=\""+tab_item_additional+"\" ";
		
		sbTitle.append("<li  role=\"presentation\" class=\""+active+"\">");
		sbTitle.append("<a href=\"#"+tab_item_id+"\"  "+jsonclick+"  aria-controls=\""+tab_item_id+"\" role=\"tab\" data-toggle=\"tab\">");
		sbTitle.append("<img src=\"img/mad/"+tab_item_icon+"\" width=30 height=30>");
		sbTitle.append(tab_item_title);
		sbTitle.append("</a>");
		sbTitle.append("</li>");
		
		
		sbBody.append("<div class=\"tab-pane "+active+"\" role=\"tabpanel\" id=\""+tab_item_id+"\" >"); 
		sbBody.append("<div id=\""+tab_item_id+"Body\">");
		sbBody.append(tab_item_body); 
		sbBody.append("</div>"); 
		sbBody.append("</div>");
		
		
	}
	
	
	sb.append("<ul class=\"nav nav-pills\" id=\""+id+"\" role=\"tablist\" >");
	sb.append(sbTitle.toString());
	
	sb.append("<div class=\"tab-content\">");
	sb.append("<br>");
	sb.append("<br>");
	sb.append("<br>");
	sb.append(sbBody.toString());
	sb.append("</div>");
	
	sb.append("</ul>"); 
	
	
	return sb.toString();
}

//********************************************************************************
void updateMadTableField(
		Connection conn,
		HttpSession session,
		String table_name,
		String table_id,
		String field_name,
		String field_value
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	if (field_value.length()==0) {
		sql="update  "+table_name+" set  "+field_name+"=null  where id=? ";
		
		bindlist.add(new String[]{"INTEGER",table_id});
	}
	else {
		sql="update  "+table_name+" set  "+field_name+"=?  where id=? ";
		
		bindlist.add(new String[]{"STRING",field_value});
		bindlist.add(new String[]{"INTEGER",table_id});
	}
	
	
	execDBConf(conn, sql, bindlist);
	
}


//********************************************************************************
String makeUserHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewMadUser();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New User");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}

//********************************************************************************
String makeSectorHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewSector();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Sector");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}


//********************************************************************************
int addNewMadGroup(
		Connection conn,
		HttpSession session,
		String group_name
		) {
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from tdm_group where group_name=? ";
	bindlist.add(new String[]{"STRING",group_name});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  tdm_group (group_name) values(?) ";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",group_name});
	
	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	
	return 0;
}

//********************************************************************************
String makeGroupHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewMadGroup();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Group");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}

//********************************************************************************
String makeDatabaseHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewDatabase();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Database");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}

//********************************************************************************
String makePolicyGroupHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewPolicyGroup();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Policy Group");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}

//********************************************************************************
String makeCalendarHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewCalendar();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Calendar");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}

//********************************************************************************
String makeSessionValidationHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewSessionValidation();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Session Validation");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}

//********************************************************************************
String makeMonitoringHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewMonitoring();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Monitoring");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}
//********************************************************************************
String decodeLovSql(HttpSession session, String lov_type) {
	String sql="";
	
	if (lov_type.equals("copy_application_list")) 
		sql="select id, name from tdm_apps where app_type='COPY' order by 2";
	
	if (lov_type.equals("database_list")) 
		sql="select id, name from tdm_envs order by 2";
	
	if (lov_type.equals("copy_application_list")) 
		sql="select id, name from tdm_apps where app_type='COPY' order by 2";
	
	if (lov_type.equals("policy_group_list")) 
		sql="select id, policy_group_name from tdm_proxy_policy_group  order by 2";
	
	if (lov_type.equals("family_list")) 
		sql="select id, family_name from tdm_family order by 2";
	
	if (lov_type.equals("discovery_report_type"))
		sql="select 'CSV_COMMA','Comma Delimited CSV' from dual union all " + 
			"select 'CSV_TAB','Tab Delimited CSV' from dual union all " +
			"select 'EXCEL','Excel' from dual";
	
	String curruser=""+((Integer) session.getAttribute("userid"));
	
	if (lov_type.equals("copy_application")) {
		if (checkrole(session, "ADMIN")) 
			sql="select id, name from tdm_apps where app_type='COPY' order by 2";
		else 
			sql="select id, name from tdm_apps where app_type='COPY' \n"+
					" and id in \n"+
					" ( \n"+
					" select app_id from tdm_group_applications where group_id in \n"+
							"(select group_id from tdm_group_members where member_id="+curruser+") \n"+
					") \n"+
					" order by 2";
	}
		
	
	if (lov_type.equals("role"))
		sql="select id, description from tdm_role order by 2";
	
	return sql;
	
}

//********************************************************************************
String makeLov(
		Connection conn,
		HttpSession session,
		String lov_title,
		String lov_type, 
		String lov_for_id, 
		String curr_value,
		String fireEvent) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql= decodeLovSql(session, lov_type);
	
	sb.append("<h4><span class=\"label label-danger\">"+lov_title+"</span></h4>");
	sb.append("<table class=table>");
	sb.append("<tr>");
	sb.append("<td>");
	sb.append(makeText("filter_lov_box", "", "placeholder=\"Search for ...\" onkeyup=\"filterLovOnEnter()\"", 0));
	sb.append("</td>");
	sb.append("<td><big><big><span class=\"glyphicon glyphicon-filter\" onclick=\"filterLov()\"></span></big></big></td>");
	sb.append("</tr>");
	sb.append("</table>");
	
	sb.append("<input type=hidden id=lov_for_id value=\""+lov_for_id+"\">");
	sb.append("<input type=hidden id=lov_fireEvent value=\""+fireEvent+"\">");
	sb.append("<input type=hidden id=lov_type value=\""+lov_type+"\">");

	sb.append("<input type=hidden id=lov_selected_value value=\""+curr_value+"\">");
	sb.append("<div id=lovListItemsDiv>");
	sb.append(fillLovList(conn, sql, curr_value,""));
	sb.append("</div>");
	
	return sb.toString();
}

//********************************************************************************
String setLovFilter(Connection conn, HttpSession session, String lov_type, String curr_value, String filter_value) {
	StringBuilder sb=new StringBuilder();
	
	String sql= decodeLovSql(session, lov_type);
	
	
	sb.append(fillLovList(conn, sql, curr_value,filter_value));
	
	return sb.toString();
	
}
//********************************************************************************
String fillLovList(Connection conn, String sql, String curr_value, String filter_value) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	for (int i=0;i<arr.size();i++) {
		String val=""; 
		String title="";
		try{val=arr.get(i)[0];} catch(Exception e) {};
		try{title=arr.get(i)[1];} catch(Exception e) {title=val;};
		
		//System.out.println(title+" "+filter_value.length()+ " " + title.contains(filter_value));
		
		if (filter_value.length()>0 && !title.toUpperCase().contains(filter_value.toUpperCase())) continue;
		
		String style="";
		String checked="";
		
		if (curr_value.equals(val) || arr.size()==1) {
			style="background-color:#DADADA;";
			checked="checked";
		}
		sb.append("<div class=row id=lov_row_"+i+" style=\""+style+"\">");
		sb.append("<div class=\"col-md-2\" align=right>");
		sb.append("<input name=lovradiogroup type=radio "+checked+" id=lov_radio_"+i+" value=\""+codehtml(val)+"\" onclick=\"setLovSelection('"+i+"','"+codehtml(val)+"');\" ondblclick=\"selectLOV();\">");
		sb.append("</div>");
		sb.append("<div class=\"col-md-10\">");
		sb.append(title);
		sb.append("</div>");
		sb.append("</div>");
	}
	
	System.out.println(""+sb.length());
	
	if (sb.length()==0) {
		sb.append("<font color=red>No item is matching.</font>");
	}
	
	return sb.toString();
}


//********************************************************************************
int addNewMadUser(
		Connection conn,
		HttpSession session,
		String username
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from tdm_user where lower(username)=?";
	bindlist.add(new String[]{"STRING",username.toLowerCase()});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  tdm_user (username,fname, lname) values(?,'undefined','') ";
	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	
	return 0;
}


//********************************************************************************
int addNewSector(
		Connection conn,
		HttpSession session,
		String sector_name
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from tdm_discovery_sector where description=?";
	bindlist.add(new String[]{"STRING",sector_name});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  tdm_discovery_sector (description) values(?) ";
	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	
	return 0;
}

//********************************************************************************
void deleteMadUser(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",id});
	
	sql="delete from tdm_group_members where member_id=?  ";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from tdm_user_role where user_id=?";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from tdm_user where id=? ";
	execDBConf(conn, sql, bindlist);
	

	
}



//********************************************************************************
void deleteSector(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",id});
	
	sql="delete from tdm_discovery_sector_rule where discovery_sector_id=?  ";
	execDBConf(conn, sql, bindlist);

	
	sql="delete from tdm_discovery_sector where id=? ";
	execDBConf(conn, sql, bindlist);
	

	
}

//********************************************************************************
String deleteMadGroup(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	
	sql="delete from tdm_group_environments where group_id=? ";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from tdm_group_applications where group_id=? ";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from tdm_group_members where group_id=? ";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from tdm_group where id=? ";
	execDBConf(conn, sql, bindlist);
	
	return "";

	
}


//********************************************************************************
String makeMadSetPassword(
		Connection conn,
		HttpSession session,
		String user_id) {
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();

		
	StringBuilder sb=new StringBuilder();


	sb.append("<input type=hidden id=password_user_id value="+user_id+">");
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-5\" align=right>");
	sb.append("<label class=\"label label-info\">Enter new  password : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-7\">");
	sb.append(makePassword("password_field_1", "", "", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-5\" align=right>");
	sb.append("<label class=\"label label-info\">Enter new password again : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-7\">");
	sb.append(makePassword("password_field_2", "", "", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}


//********************************************************************************
void setMadUserPassword(
		Connection conn,
		HttpSession session,
		String user_id, 
		String new_password) {
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="update tdm_user set  password=?   where id=?";
	bindlist.add(new String[]{"STRING",encrypt(new_password)});
	bindlist.add(new String[]{"INTEGER",""+user_id});
	
	execDBConf(conn, sql, bindlist);
}


//********************************************************************************
String makeUserEditor(
		Connection conn,
		HttpSession session,
		String user_id
		) {
	
	
	String sql="";
	sql="select username, email, fname, lname , valid  from tdm_user where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",user_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String username=arr.get(0)[0];
	String email=arr.get(0)[1];
	String fname=arr.get(0)[2];
	String lname=arr.get(0)[3];

	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=user_editor_"+user_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	
	sb.append("<button type=button class=\"btn btn-sm btn-warning\" onclick=\"javascript:setMadUserPassword('"+user_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-lock\">");
	sb.append(" Set Password " );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	
	if (!username.equals("admin")) {
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteMadUser('"+user_id+"');\">");
		sb.append("<span class=\"glyphicon glyphicon-remove\">");
		sb.append(" Delete User \"" + username +"\"" );
		sb.append("</span>");
		sb.append("</button>");
		sb.append(" ");
	}
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">User Name : </label>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("username", username, " disabled onchange=\"saveMadUserField(this, '"+user_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Email : </label>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("email", email, " onchange=\"saveMadUserField(this, '"+user_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">First Name : </label>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("fname", fname, " onchange=\"saveMadUserField(this, '"+user_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Last Name : </label>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("lname", lname, " onchange=\"saveMadUserField(this, '"+user_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Roles : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, description from tdm_role order by 2";
	bindlist.clear();
	ArrayList<String[]> rolesAllArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select role_id,description " 
		+"	from tdm_user_role ur, tdm_role r " 
		+"	where user_id=? " 
		+"	and role_id=r.id " 
		+"	order by 2";
	

	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",user_id});
	ArrayList<String[]> userRolesArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	String event_listener="javascript:addRemoveUserRole(\""+user_id+"\",\"#\");";
	sb.append(makePickList("0", "group_roles_"+user_id, rolesAllArr, userRolesArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Group Membership : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, group_name from tdm_group order by 2";
	bindlist.clear();
	ArrayList<String[]> groupsAllArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select group_id, group_name " 
		+"	from tdm_group_members m, tdm_user u, tdm_group g " 
		+"	where member_id=? " 
		+"	and member_id=u.id  and group_id=g.id " 
		+"	order by 2";
	

	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",user_id});
	ArrayList<String[]> grpMemArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	event_listener="javascript:addRemoveUserMembership(\""+user_id+"\",\"#\");";
	sb.append(makePickList("0", "group_membership_"+user_id, groupsAllArr, grpMemArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");
	
		
	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}



//********************************************************************************
String makeSectorEditor(
		Connection conn,
		HttpSession session,
		String sector_id
		) {
	
	
	String sql="";
	sql="select description  from tdm_discovery_sector where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",sector_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String description=arr.get(0)[0];


	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=sector_editor_"+sector_id+">");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	

	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteSector('"+sector_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete \"" + description +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Sector Name : </label>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("description", description, " onchange=\"saveSectorField(this, '"+sector_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");


	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Discovery Rules : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, description from tdm_discovery_rule where is_valid='YES' order by 2";
	bindlist.clear();
	ArrayList<String[]> rulesAllArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select discovery_rule_id,description " 
		+"	from tdm_discovery_sector_rule sr, tdm_discovery_rule r " 
		+"	where discovery_sector_id=? " 
		+"	and discovery_rule_id=r.id " 
		+"	order by 2";
	

	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",sector_id});
	ArrayList<String[]> sectorRulesArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	String event_listener="javascript:addRemoveSectorRule(\""+sector_id+"\",\"#\");";
	sb.append(makePickList("0", "sector_rules_"+sector_id, rulesAllArr, sectorRulesArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");


	
		
	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}


//********************************************************************************
String makeGroupEditor(
		Connection conn,
		HttpSession session,
		String group_id
		) {
	
	
	String sql="";
	sql="select group_name,  group_description  from tdm_group where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String group_name=arr.get(0)[0];
	String group_description=arr.get(0)[1];

	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=group_editor_"+group_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteMadGroup('"+group_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete Group \"" + group_name +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Group Name : </label>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("group_name", group_name, " onchange=\"saveMadGroupField(this, '"+group_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Description : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append("<textarea rows=2 style=\"width:100%\" id=group_description onchange=\"saveMadGroupField(this, '"+group_id+"');\" >"+group_description+"</textarea>");
	sb.append("</div>");
	sb.append("</div>");
	
	
	String event_listener="";
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Users In Group : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, concat(username,  '  [',lname, ', ', fname,']') from tdm_user order by 2";
	bindlist.clear();
	ArrayList<String[]> usersAllArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select member_id, concat(username,  '  [',lname, ', ', fname,']') " 
		+"	from tdm_group_members m, tdm_user u  " 
		+"	where group_id=? " 
		+"	and member_id=u.id  " 
		+"	order by 2";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_id});
	ArrayList<String[]> usersInGrpArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	event_listener="javascript:addRemoveGroupMember(\""+group_id+"\",\"#\");";
	
	sb.append(makePickList("0", "users_in_group_"+group_id, usersAllArr, usersInGrpArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");

	
		
		
		
	sb.append("<div class=row>"); 
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Role Grant/Revoke : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	
	sb.append("<button type=button class=\"bt btn-sm btn-success\" onclick=assignRoleToGroup('"+group_id+"','GRANT')>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"></span> Grant a Role to Group ["+group_name+"]");
	sb.append("</button>");
	
	sb.append(" ");
	
	sb.append("<button type=button class=\"bt btn-sm btn-danger\" onclick=assignRoleToGroup('"+group_id+"','REVOKE')>");
	sb.append("<span class=\"glyphicon glyphicon-minus\"></span> Revoke a Role from Group ["+group_name+"]");
	sb.append("</button>");

	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sql="select id, name from tdm_apps where app_type='COPY' order by 2 ";
	bindlist.clear();
	ArrayList<String[]> allCopyAppsArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Copy Applications : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	
	sql="select app_id from tdm_group_applications where group_id=? ";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_id});
	
	ArrayList<String[]> grantedCopyAppArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	event_listener="javascript:addRemoveGroupCopyApplication(\""+group_id+"\",\"#\");";
	sb.append(makePickList("0", "application_"+group_id, allCopyAppsArr, grantedCopyAppArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sql="select id, target_name from tdm_target order by 2 ";
	bindlist.clear();
	ArrayList<String[]> allTargetArr1=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Source Db Targets Granted : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	
	sql="select env_id from tdm_group_environments where group_id=? and env_type='SOURCE'";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_id});
	
	ArrayList<String[]> grantedSrcEnvArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	event_listener="javascript:addRemoveGroupEnvironment(\""+group_id+"\",\"#\",\"SOURCE\");";
	sb.append(makePickList("0", "source_env_"+group_id, allTargetArr1, grantedSrcEnvArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sql="select id, target_name from tdm_target order by 2 ";
	bindlist.clear();
	ArrayList<String[]> allTargetArr2=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Target Db Targets Granted : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	
	sql="select env_id from tdm_group_environments where group_id=? and env_type='TARGET'";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_id});
	
	ArrayList<String[]> grantedTarEnvArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	event_listener="javascript:addRemoveGroupEnvironment(\""+group_id+"\",\"#\",\"TARGET\");";
	sb.append(makePickList("0", "target_env_"+group_id, allTargetArr2, grantedTarEnvArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");
	
		
	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}

//********************************************************************************
String makeDatabaseEditor(
		Connection conn,
		ServletContext application,
		HttpSession session,
		String db_id
		) {
	
	
	String sql="";
	sql="select name,  db_driver, db_connstr, db_username, db_password, db_catalog, for_static, for_dynamic, for_design   from tdm_envs where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",db_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String db_name=arr.get(0)[0];
	String db_driver=arr.get(0)[1];
	String db_connstr=arr.get(0)[2];
	String db_username=arr.get(0)[3];
	String db_password=passwordDecoder(arr.get(0)[4]) ;
	String db_catalog=arr.get(0)[5];
	String for_static=arr.get(0)[6];
	String for_dynamic=arr.get(0)[7];
	String for_design=arr.get(0)[8];

	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=database_editor_"+db_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	
	
	sb.append("<button type=button class=\"btn btn-sm btn-warning\" onclick=\"javascript:testConnectionByDbId('"+db_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-ok-circle\">");
	sb.append(" Test Connection");
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	
	String server_side_script_location=getDbServerSideScriptLocation(conn, application, session, db_id); 
	if (server_side_script_location!=null) {
		sb.append("<button type=button class=\"btn btn-sm btn-info\" onclick=\"javascript:installServerSideScripts('"+db_id+"');\">");
		sb.append("<span class=\"glyphicon glyphicon-flash\">");
		sb.append(" Install Server Side Scripts");
		sb.append("</span>");
		sb.append("</button>");
		sb.append(" ");
	}
	
	

	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteDatabase('"+db_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete Database \"" + db_name +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	
	
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Database Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("name", db_name, " onchange=\"saveDatabaseField(this, '"+db_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">JDBC Driver : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select ref_name, ref_desc from tdm_ref where ref_type='DB_TYPE' order by 2";
	bindlist.clear();
	ArrayList<String[]> arrDbDrv=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	sb.append(makeComboArr(arrDbDrv, "", "id=db_driver onchange=\"saveDatabaseField(this, '"+db_id+"');\"", db_driver, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">JDBC Connection Str : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("db_connstr", db_connstr, " onchange=\"saveDatabaseField(this, '"+db_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");

	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Username : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("db_username", db_username, " onchange=\"saveDatabaseField(this, '"+db_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");

	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Password : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	//sb.append(makePassword("db_password", db_password, " onchange=\"saveDatabaseField(this, '"+db_id+"');\"", 0));
	sb.append("<button type=button class=\"btn btn-sm btn-primary\" onclick=\"javascript:changeDbPassword('"+db_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-asterisk\">");
	sb.append(" Change Password " );
	sb.append("</span>");
	sb.append("</button>");	
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Catalog : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\" id=Divcat_for_"+db_id+">");
	sb.append(makeDatabaseCatalogField(conn,session,db_id, db_catalog));
	sb.append("</div>");
	sb.append("</div>");
	
	
	ArrayList<String[]> yesNoArr=new ArrayList<String[]>();
	yesNoArr.add(new String[]{"YES","Yes"});
	yesNoArr.add(new String[]{"NO","No"});
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Used for Design : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(yesNoArr, "", "size=0 id=for_design onchange=\"saveDatabaseField(this, '"+db_id+"');\"", for_design, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Used for Static Masking : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(yesNoArr, "", "size=0 id=for_static onchange=\"saveDatabaseField(this, '"+db_id+"');\"", for_static, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Used for Dynamic Masking : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(yesNoArr, "", "size=0 id=for_dynamic onchange=\"saveDatabaseField(this, '"+db_id+"');\"", for_dynamic, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("</div>");
	sb.append("</div>");

	
	return sb.toString();
}
//********************************************************************************
String makeDatabaseCatalogField(
		Connection conn,
		HttpSession session,
		String db_id,
		String db_catalog
		) {
StringBuilder sb=new StringBuilder();
sb.append("<table border=0 cellspacing=0 cellpadding=0 width=\"100%\">");
sb.append("<tr>");
sb.append("<td width=\"100%\" >");
sb.append(makeText("db_catalog_"+db_id, db_catalog, " readonly ", 0));
sb.append("</td>");
sb.append("<td>");
sb.append("<button class=\"btn btn-sm btn-primary\" onclick=openDatabaseCatalogList('"+db_id+"','"+db_catalog+"')>");
sb.append("<span class=\"glyphicon glyphicon-share-alt\"></span>");
sb.append("</button>");
sb.append("</td>");
sb.append("</tr>");
sb.append("</table>");
return sb.toString();
}


//********************************************************************************
String makeDatabaseCatalogList(
		Connection conn,
		HttpSession session,
		String db_id,
		String db_catalog
		) {
StringBuilder sb=new StringBuilder();

String sql="select name from tdm_envs where id=?";
ArrayList<String[]> bindlist=new ArrayList<String[]>();
bindlist.add(new String[]{"INTEGER",db_id});



String db_name=getDbArrayConf(conn, sql, 1, bindlist).get(0)[0];

sb.append("<h4>Catalog list for <b>"+db_name+"</b> </h4>");
sb.append("<hr>");


StringBuilder errmsg=new StringBuilder();
ArrayList<String[]> arrCatalog=getDesignerCatalogList(conn, session, db_id, errmsg);

if (errmsg.length()>0) {
	sb.append("Cannot get catalog list since connection is invalid : <b>"+clearHtml(errmsg.toString())+"</b>");
	return sb.toString();
}

if (!arrCatalog.get(0)[0].equals("${default}")) 
	arrCatalog.add(new String[]{"${default}"});



sb.append("<table border=0 cellspacing=0 cellpadding=0 width=\"100%\">");


for (int i=0;i<arrCatalog.size();i++) {
	
	String cat_name=arrCatalog.get(i)[0];
	
	
	
	sb.append("<tr>");
	sb.append("<td width=\"100%\" >");
	sb.append(makeText("db_catalog_list_"+db_id, cat_name, " readonly ", 0));
	sb.append("</td>");
	sb.append("<td>");
	
	if (db_catalog.equals(cat_name)) {
		sb.append("<span class=\"glyphicon glyphicon-check\"></span>");
	}
	else {
		sb.append("<button class=\"btn btn-sm btn-primary\" onclick=setDatabaseCatalog('"+db_id+"','"+cat_name+"')>");
		sb.append("<span class=\"glyphicon glyphicon-share-alt\"></span>");
		sb.append("</button>");
	}
	
	sb.append("</td>");
	sb.append("</tr>");
}





sb.append("</table>");




return sb.toString();
}
//********************************************************************************
void setDatabaseCatalog(
		Connection conn,
		HttpSession session,
		String db_id,
		String db_catalog
		) {
	String sql="update tdm_envs set db_catalog=? where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"STRING",db_catalog});
	bindlist.add(new String[]{"INTEGER",db_id});
	
	execDBConf(conn, sql, bindlist);


}
//********************************************************************************
void fillSessionVariableArray(ArrayList<String[]> arr) {
	
	arr.clear();
	arr.add(new String[]{"CLIENT_HOST_ADDRESS"});
	arr.add(new String[]{"CLIENT_PORT"});
	arr.add(new String[]{"CURRENT_CATALOG"});
	arr.add(new String[]{"CURRENT_SCHEMA"});
	arr.add(new String[]{"CURRENT_USER"});
	arr.add(new String[]{"AUTH_TERMINAL"});
	arr.add(new String[]{"AUTH_PROGRAM_NM"});
	arr.add(new String[]{"AUTH_MACHINE"});
	arr.add(new String[]{"OSUSER"});
	arr.add(new String[]{"MACHINE"});
	arr.add(new String[]{"TERMINAL"});
	arr.add(new String[]{"PROGRAM"});
	arr.add(new String[]{"MODULE"});
	arr.add(new String[]{"DB_VERSION"});
	arr.add(new String[]{"CLIENT_VERSION"});
	arr.add(new String[]{"CLIENT_DRIVER"});
	arr.add(new String[]{"CLIENT_OCI_LIBRARY"});
	arr.add(new String[]{"AUTHENTICATION_TYPE"});
	arr.add(new String[]{"PROXY_CLIENT_NAME"});
	arr.add(new String[]{"ORA_PROTOCOL_CHAR"});
	arr.add(new String[]{"ORA_PACK_VERSION"});
	arr.add(new String[]{"GRANTED_ROLES"});

	arr.add(new String[]{"EXTRACTED_PAR1"});
	arr.add(new String[]{"EXTRACTED_PAR2"});
	arr.add(new String[]{"EXTRACTED_PAR3"});
	arr.add(new String[]{"EXTRACTED_PAR4"});
	arr.add(new String[]{"EXTRACTED_PAR5"});


}

//********************************************************************************
String makePolicyGroupEditor(
		Connection conn,
		HttpSession session,
		String policy_group_id
		) {
	
	
	String sql="";
	sql="select policy_group_name, check_field, check_rule, check_parameter, env_id,  "+
		" 	case_sensitive, valid, record_limit, start_debuging "+
		" from tdm_proxy_policy_group where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",policy_group_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String policy_group_name=arr.get(0)[0];
	String check_field=arr.get(0)[1];
	String check_rule=arr.get(0)[2];
	String check_parameter=arr.get(0)[3];
	String env_id=arr.get(0)[4];
	String case_sensitive=arr.get(0)[5];
	String valid=arr.get(0)[6];
	String record_limit=arr.get(0)[7];
	String start_debuging=arr.get(0)[8];
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=policy_group_editor_"+policy_group_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	
	

	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deletePolicyGroup('"+policy_group_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete \"" + policy_group_name +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	
	
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Database Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("policy_group_name", policy_group_name, " onchange=\"savePolicyGroupField(this, '"+policy_group_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	ArrayList<String[]> checkField=new ArrayList<String[]>();
	
	fillSessionVariableArray(checkField);
	
	checkField.add(0,new String[]{"ALL","ALL"});
	

	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Session Variable : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(checkField, "", "size=1 id=check_field  onchange=\"savePolicyGroupField(this, '"+policy_group_id+"');\" ", check_field, 0));
	sb.append("</div>");
	sb.append("</div>");	
	
	
	ArrayList<String[]> checkList=new ArrayList<String[]>();
	
	checkList.add(new String[]{"EQUALS","Equals"});
	checkList.add(new String[]{"NOT_EQUALS","Not Equals"});
	checkList.add(new String[]{"CONTAINS","Contains"});
	checkList.add(new String[]{"NOT_CONTAINS","Doesn't Contain"});
	checkList.add(new String[]{"IS_EMPTY","Is Empty"});
	checkList.add(new String[]{"IS_NOT_EMPTY","Is Not Empty"});
	checkList.add(new String[]{"REGEX","Matches Regular Expression"});
	checkList.add(new String[]{"NOT_REGEX","Doesn't Match Regular Expression"});
	checkList.add(new String[]{"JAVASCRIPT","Javascript Engine"});

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Operator : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(checkList, "", "size=1 id=check_rule  onchange=\"savePolicyGroupField(this, '"+policy_group_id+"');\" ", check_rule, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Parameters : </label>");
	sb.append("<br><small>Use line feed {enter} as seperator for multiple values. SQL select statement also permitted.<br> for AD queries => LDAP:***</small>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append("<textarea id=check_parameter rows=4 style=\"width:100%;\" onchange=\"savePolicyGroupField(this, '"+policy_group_id+"');\" >");
	sb.append(clearHtml(check_parameter));
	sb.append("</textarea>");
	sb.append("</div>");
	sb.append("</div>");
	
	
	sql="select id, name from tdm_envs order by 2";
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Source Database : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeCombo(conn, sql, "", "id=env_id  onchange=\"savePolicyGroupField(this, '"+policy_group_id+"');\" ", env_id, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	ArrayList<String[]> yesnoArr=new ArrayList<String[]>();
	
	yesnoArr.add(new String[]{"YES","Yes - Case Sensitive"});
	yesnoArr.add(new String[]{"NO","No - Case Insensitive"});
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Case Sensitivity : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(yesnoArr, "", "size=1 id=case_sensitive  onchange=\"savePolicyGroupField(this, '"+policy_group_id+"');\" ", case_sensitive, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	yesnoArr=new ArrayList<String[]>();
	
	yesnoArr.add(new String[]{"YES","Yes"});
	yesnoArr.add(new String[]{"NO","No"});
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Valid : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(yesnoArr, "", "size=1 id=valid  onchange=\"savePolicyGroupField(this, '"+policy_group_id+"');\" ", valid, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Record Limit ('0' means no limit): </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("record_limit", record_limit, " onchange=\"savePolicyGroupField(this, '"+policy_group_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Start Debuging : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(yesnoArr, "", "size=1 id=start_debuging  onchange=\"savePolicyGroupField(this, '"+policy_group_id+"');\" ", start_debuging, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("</div>");
	sb.append("</div>");

	
	return sb.toString();
}


//********************************************************************************
String makeCalendarEditor(
		Connection conn,
		HttpSession session,
		String calendar_id
		) {
	
	
	String sql="";
	sql="select calendar_name from tdm_proxy_calendar where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",calendar_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String calendar_name=arr.get(0)[0];


	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=calendar_editor_"+calendar_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	
	

	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteCalendar('"+calendar_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete \"" + calendar_name +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	
	
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Calendar Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("calendar_name", calendar_name, " onchange=\"saveCalendarField(this, '"+calendar_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=colCalendarExceptionFor_"+calendar_id+">");
	sb.append(makeCalendarExceptionList(conn, session, calendar_id));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("</div>");
	sb.append("</div>");

	
	return sb.toString();
}


//********************************************************************************
String makeSessionValidationEditor(
		Connection conn,
		HttpSession session,
		String session_validation_id
		) {
	
	
	String sql="";
	
	sql="select "+
			" session_validation_name, "+
			" for_statement_check_regex,"+
			" check_start, "+
			" check_duration, "+
			" limit_session_duration, "+
			" max_attempt_count, "+
			" extraction_js_for_par1, extraction_js_for_par2, extraction_js_for_par3, extraction_js_for_par4, extraction_js_for_par5, "+ 
			" controll_method, controll_statement, controll_db_id, expected_result, "+
			" validate_identical_sessions "+
			" from tdm_proxy_session_validation "+
			" where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",session_validation_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String session_validation_name=arr.get(0)[0];
	String for_statement_check_regex=arr.get(0)[1];
	String check_start=arr.get(0)[2];
	String check_duration=arr.get(0)[3];
	String limit_session_duration=arr.get(0)[4];
	String max_attempt_count=arr.get(0)[5];
	
	ArrayList<String> jsArr=new ArrayList<String>();
	jsArr.add(arr.get(0)[6]);
	jsArr.add(arr.get(0)[7]);
	jsArr.add(arr.get(0)[8]);
	jsArr.add(arr.get(0)[9]);
	jsArr.add(arr.get(0)[10]);

	String controll_method=arr.get(0)[11];
	String controll_statement=arr.get(0)[12];
	String controll_db_id=arr.get(0)[13];
	String expected_result=arr.get(0)[14];
	String validate_identical_sessions=arr.get(0)[15];

	

	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=session_validation_editor_"+session_validation_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	
	

	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteSessionValidation('"+session_validation_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete \"" + session_validation_name +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	
	
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Session Validation Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("session_validation_name", session_validation_name, " onchange=\"saveSessionValidationField(this, '"+session_validation_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");


	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Regex to check statement: </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append(makeText("for_statement_check_regex", clearHtml(for_statement_check_regex), " readonly onclick=\"javascript:testSessionValidationRegex('"+session_validation_id+"','for_statement_check_regex');\"  ", 0));
	sb.append("</div>");
	sb.append("<div class=\"col-md-1\" align=left>");
	sb.append("<span class=badge onclick=\"javascript:testSessionValidationRegex('"+session_validation_id+"','for_statement_check_regex');\">");
	sb.append("Build");
	sb.append("</span>");
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Start validation after ? (msecs) : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeNumber("0", "check_start", check_start, "saveSessionValidationField(this, '"+session_validation_id+"')", "EDIT", "6", "0", ",", ".", "", "0", "999999"));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Validation duration (msecs) : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeNumber("0", "check_duration", check_duration, "saveSessionValidationField(this, '"+session_validation_id+"')", "EDIT", "6", "0", ",", ".", "", "0", "999999"));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Limit session duration (msecs) : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-2\">");
	sb.append(makeNumber("0", "limit_session_duration", limit_session_duration, "saveSessionValidationField(this, '"+session_validation_id+"')", "EDIT", "7", "0", ",", ".", "", "0", "3600000"));
	sb.append("</div>");
	sb.append("<div class=\"col-md-7\" align=left>");
	sb.append(" (0 Means no limit)");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Max. attempt count : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeNumber("0", "max_attempt_count", max_attempt_count, "saveSessionValidationField(this, '"+session_validation_id+"')", "EDIT", "3", "0", ",", ".", "", "1", "999"));
	sb.append("</div>");
	sb.append("</div>");
	
	for (int i=1;i<=5;i++) {
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">${PARAMETER"+i+"} Extraction Script : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-8\">");
		sb.append("<textarea readonly rows=2 style=\"width:100%;\"\" onclick=\"buildSessionValidationScript('"+session_validation_id+"','extraction_js_for_par"+i+"');\">"+clearHtml(jsArr.get(i-1))+"</textarea>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-1\" align=left>");
		sb.append("<label class=\"badge\" onclick=\"buildSessionValidationScript('"+session_validation_id+"','extraction_js_for_par"+i+"');\">Build</label>");
		sb.append("</div>");
		sb.append("</div>");
	}
	
	ArrayList<String[]> methodArr=new ArrayList<String[]>();
	methodArr.add(new String[]{"DATABASE","SQL Query"});
	methodArr.add(new String[]{"JAVASCRIPT","Javascript Engine"});
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Controll Method: </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(methodArr, "", "size=1 id=controll_method  onchange=\"javascript:saveSessionValidationField(this, '"+session_validation_id+"');\" ", controll_method, 200));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Controll Statement : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append("<textarea readonly rows=2 style=\"width:100%;\"\" onclick=\"buildSessionValidationScript('"+session_validation_id+"','controll_statement');\">"+clearHtml(controll_statement)+"</textarea>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-1\" align=left>");
	sb.append("<label class=\"badge\" onclick=\"buildSessionValidationScript('"+session_validation_id+"','controll_statement');\">Build</label>");
	sb.append("</div>");
	sb.append("</div>");
	
	sql="select id, name from tdm_envs order by 2";
	ArrayList<String[]> dbArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, null);
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Controll Source Database : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(dbArr, "", "id=controll_db_id  onchange=\"javascript:saveSessionValidationField(this, '"+session_validation_id+"');\" ", controll_db_id, 0));
	sb.append("</div>");
	sb.append("</div>");
	
		sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Expected Result (Regex allowed): </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append(makeText("expected_result", clearHtml(expected_result), "readonly  onclick=\"javascript:testSessionValidationRegex('"+session_validation_id+"','expected_result');\" ", 0));
	sb.append("</div>");
	sb.append("<div class=\"col-md-1\" align=left>");
	sb.append("<span class=badge onclick=\"javascript:testSessionValidationRegex('"+session_validation_id+"','expected_result');\">");
	sb.append(" Build ");
	sb.append("</span>");
	sb.append("</div>");
	sb.append("</div>");
	
	ArrayList<String[]> yesNoArr=new ArrayList<String[]>();
	yesNoArr.add(new String[]{"YES","Yes"});
	yesNoArr.add(new String[]{"NO","No"});
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Validate Identical Sessions : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(yesNoArr, "", "size=1 id=validate_identical_sessions  onchange=\"saveSessionValidationField(this, '"+session_validation_id+"');\" ", validate_identical_sessions, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("</div>");
	sb.append("</div>");

	
	return sb.toString();
}


//********************************************************************************
String makeMonitoringEditor(
		Connection conn,
		HttpSession session,
		String monitoring_id
		) {
	
	
	String sql="";
	
	sql="select "+
			" monitoring_name, "+
			" monitoring_interval,"+
			" monitoring_period, "+
			" monitoring_threashold, "+
			" monitoring_threashold_recv_bytes, "+
			" monitoring_email, "+
			" monitoring_blacklist, "+
			" is_active "+ 
			" from tdm_proxy_monitoring "+
			" where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",monitoring_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String monitoring_name=arr.get(0)[0];
	String monitoring_interval=arr.get(0)[1];
	String monitoring_period=arr.get(0)[2];
	String monitoring_threashold=arr.get(0)[3];
	String monitoring_threashold_recv_bytes=arr.get(0)[4];
	String monitoring_email=arr.get(0)[5];
	String monitoring_blacklist=arr.get(0)[6];
	String is_active=arr.get(0)[7];
	

	

	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=monitoring_editor_"+monitoring_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	
	

	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteMonitoring('"+monitoring_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete \"" + monitoring_name +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	
	
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Monitoring Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("monitoring_name", monitoring_name, " onchange=\"saveMonitoringField(this, '"+monitoring_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	ArrayList<String[]> intervalArr=new ArrayList<String[]>();
	intervalArr.add(new String[]{"SECOND","Seconds"});
	intervalArr.add(new String[]{"MINUTE","Minutes"});
	intervalArr.add(new String[]{"HOUR","Hours"});

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Threshold Interval : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeNumber("0", "monitoring_interval", monitoring_interval, "saveMonitoringField(this, '"+monitoring_id+"')", "EDIT", "5", "0", ",", ".", "", "0", "99999"));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Threshold Period : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(intervalArr, "", "size=1 id=monitoring_period  onchange=\"javascript:saveMonitoringField(this, '"+monitoring_id+"');\" ", monitoring_period, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Threshold For Statement Violation : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeNumber("0", "monitoring_threashold", monitoring_threashold, "saveMonitoringField(this, '"+monitoring_id+"')", "EDIT", "6", "0", ",", ".", "", "0", "999999"));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Threshold For Received Bytes : </label>");
	sb.append("<br><small>0 for unlimited</small>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeNumber("0", "monitoring_threashold_recv_bytes", monitoring_threashold_recv_bytes, "saveMonitoringField(this, '"+monitoring_id+"')", "EDIT", "10", "0", ",", ".", "", "0", ""+Integer.MAX_VALUE));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Notification Email Addresses : </label>");
	sb.append("<br><small>Multiple addresses are comma seperated allowed</small>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("monitoring_email", monitoring_email, " onchange=\"saveMonitoringField(this, '"+monitoring_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	ArrayList<String[]> yesnoArr=new ArrayList<String[]>();
	yesnoArr.add(new String[]{"YES","Yes"});
	yesnoArr.add(new String[]{"NO","No"});
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Add to redklist : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(yesnoArr, "", "size=1 id=monitoring_blacklist  onchange=\"javascript:saveMonitoringField(this, '"+monitoring_id+"');\" ", monitoring_blacklist, 0));
	sb.append("</div>");
	sb.append("</div>");

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Active : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(yesnoArr, "", "size=1 id=is_active  onchange=\"javascript:saveMonitoringField(this, '"+monitoring_id+"');\" ", is_active, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=left>");
	sb.append("<label class=\"label label-info\">Policy Groups : </label>");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=divPolicyGroupsFor"+monitoring_id+" style=\"min-height: 1px; min-height: 20px; max-height: 150px;  overflow-y: scroll; \">");
	sb.append(makeMonitoringPolicyGroupEditor(conn,session,monitoring_id));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=left>");
	sb.append("<label class=\"label label-info\">Applications : </label>");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=divApplicationFor"+monitoring_id+" style=\"min-height: 1px; min-height: 20px; max-height: 150px;  overflow-y: scroll; \">");
	sb.append(makeMonitoringApplicationEditor(conn,session,monitoring_id));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=left>");
	sb.append("<label class=\"label label-info\">Columns to monitor : </label>");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append("<button class=\"btn btn-sm btn-success\" onclick=addNewMonitoringRule('"+monitoring_id+"','COLUMN')><span class=\"glyphicon glyphicon-plus\"></span></button>");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=divMonitoringColumnsFor"+monitoring_id+" style=\"min-height: 1px; min-height: 20px; max-height: 150px;  overflow-y: scroll; \">");
	sb.append(makeMonitoringColumnsEditor(conn,session,monitoring_id));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=left>");
	sb.append("<label class=\"label label-info\">Expressions to monitor : </label>");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append("<button class=\"btn btn-sm btn-success\" onclick=addNewMonitoringRule('"+monitoring_id+"','EXPRESSION')><span class=\"glyphicon glyphicon-plus\"></span></button>");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=divMonitoringExpressionsFor"+monitoring_id+" style=\"min-height: 1px; min-height: 20px; max-height: 150px;  overflow-y: scroll; \">");
	sb.append(makeMonitoringExpressionsEditor(conn,session,monitoring_id));
	sb.append("</div>");
	sb.append("</div>");


	sb.append("</div>");
	sb.append("</div>");

	
	return sb.toString();
}

//********************************************************************************
String makeMonitoringColumnsEditor(
		Connection conn,
		HttpSession session,
		String monitoring_id
		) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id,rule_description,rule_catalog_name,rule_schema_name,rule_object_name,rule_column_name,is_active "+
		" from tdm_proxy_monitoring_policy_rules "+
		" where monitoring_id=? and rule_type='COLUMN' ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",monitoring_id});
	ArrayList<String[]> colArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);

	ArrayList<String[]> yesnoArr=new ArrayList<String[]>();
	yesnoArr.add(new String[]{"YES","Yes"});
	yesnoArr.add(new String[]{"NO","No"});

	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	sb.append("<tr class=info>");
	
	sb.append("<td><b>Description</b></td>");
	sb.append("<td><b>Catalog</b></td>");
	sb.append("<td><b>Schema/Owner</b></td>");
	sb.append("<td><b>Table/View</b></td>");
	sb.append("<td><b>Column</b></td>");
	sb.append("<td><b>Active</b></td>");
	sb.append("<td></td>");
	sb.append("</tr>");
	
	for (int i=0;i<colArr.size();i++) {
		String rule_id=colArr.get(i)[0];
		String rule_description=colArr.get(i)[1];
		String rule_catalog_name=colArr.get(i)[2];
		String rule_schema_name=colArr.get(i)[3];
		String rule_object_name=colArr.get(i)[4];
		String rule_column_name=colArr.get(i)[5];
		String is_active=colArr.get(i)[6];

		if (is_active.equals("YES"))
			sb.append("<tr>");
		else 
			sb.append("<tr class=danger>");
		
		sb.append("<td>");
		sb.append(makeText("rule_description", rule_description, " onchange=\"saveMonitoringRuleField(this,'"+monitoring_id+"', '"+rule_id+"');\"", 0));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeText("rule_catalog_name", rule_catalog_name, " onchange=\"saveMonitoringRuleField(this,'"+monitoring_id+"', '"+rule_id+"');\"", 0));
		sb.append("</td>");

		sb.append("<td>");
		sb.append(makeText("rule_schema_name", rule_schema_name, " onchange=\"saveMonitoringRuleField(this,'"+monitoring_id+"', '"+rule_id+"');\"", 0));
		sb.append("</td>");

		sb.append("<td>");
		sb.append(makeText("rule_object_name", rule_object_name, " onchange=\"saveMonitoringRuleField(this,'"+monitoring_id+"', '"+rule_id+"');\"", 0));
		sb.append("</td>");

		sb.append("<td>");
		sb.append(makeText("rule_column_name", rule_column_name, " onchange=\"saveMonitoringRuleField(this,'"+monitoring_id+"', '"+rule_id+"');\"", 0));
		sb.append("</td>");

		sb.append("<td>");
		sb.append(makeComboArr(yesnoArr, "", "size=1 id=is_active  onchange=\"javascript:saveMonitoringRuleField(this,'"+monitoring_id+"', '"+rule_id+"');\" ", is_active, 120));
		sb.append("</td>");
		
		sb.append("<td align=right>");
		sb.append("<button class=\"btn btn-sm btn-danger\" onclick=removeMonitoringRule('"+monitoring_id+"','"+rule_id+"','COLUMN')><span class=\"glyphicon glyphicon-remove\"></span></button>");
		sb.append("</td>");
		
		sb.append("</tr>");
	}
	sb.append("</table>");
	
	return sb.toString();
}



//********************************************************************************
String makeMonitoringExpressionsEditor(
		Connection conn,
		HttpSession session,
		String monitoring_id
		) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id,rule_description,rule_expression,is_active "+
		" from tdm_proxy_monitoring_policy_rules "+
		" where monitoring_id=? and rule_type='EXPRESSION' ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",monitoring_id});
	ArrayList<String[]> colArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);

	ArrayList<String[]> yesnoArr=new ArrayList<String[]>();
	yesnoArr.add(new String[]{"YES","Yes"});
	yesnoArr.add(new String[]{"NO","No"});

	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	sb.append("<tr class=info>");
	
	sb.append("<td><b>Description</b></td>");
	sb.append("<td><b>Expression</b> (Regular Expression)</td>");
	sb.append("<td><b>Active</b></td>");
	sb.append("<td></td>");
	sb.append("</tr>");
	
	for (int i=0;i<colArr.size();i++) {
		String rule_id=colArr.get(i)[0];
		String rule_description=colArr.get(i)[1];
		String rule_expression=colArr.get(i)[2];
		String is_active=colArr.get(i)[3];

		if (is_active.equals("YES"))
			sb.append("<tr>");
		else 
			sb.append("<tr class=danger>");
		
		sb.append("<td>");
		sb.append(makeText("rule_description", rule_description, " onchange=\"saveMonitoringRuleField(this,'"+monitoring_id+"', '"+rule_id+"');\"", 0));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeText("rule_expression", rule_expression, " onchange=\"saveMonitoringRuleField(this,'"+monitoring_id+"', '"+rule_id+"');\"", 0));
		sb.append("</td>");

		
		sb.append("<td>");
		sb.append(makeComboArr(yesnoArr, "", "size=1 id=is_active  onchange=\"javascript:saveMonitoringRuleField(this,'"+monitoring_id+"', '"+rule_id+"');\" ", is_active, 120));
		sb.append("</td>");
		
		sb.append("<td align=right>");
		sb.append("<button class=\"btn btn-sm btn-danger\" onclick=removeMonitoringRule('"+monitoring_id+"','"+rule_id+"','EXPRESSION')><span class=\"glyphicon glyphicon-remove\"></span></button>");
		sb.append("</td>");
		
		sb.append("</tr>");
	}
	sb.append("</table>");
	
	return sb.toString();
}

//********************************************************************************
String makeMonitoringPolicyGroupEditor(
		Connection conn,
		HttpSession session,
		String monitoring_id
		) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select policy_group_id from tdm_proxy_monitoring_policy_group where monitoring_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",monitoring_id});
	ArrayList<String[]> selectedPolicyGroups=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	ArrayList<String> arrCheck=new ArrayList<String>();
	for (int i=0;i<selectedPolicyGroups.size();i++) arrCheck.add(selectedPolicyGroups.get(i)[0]);
	
	sql="select id, policy_group_name from tdm_proxy_policy_group where valid='YES' order by 1 desc";
	bindlist.clear();
	ArrayList<String[]> allPolicyGroups=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	for (int i=0;i<allPolicyGroups.size();i++) {
		
		String policy_group_id=allPolicyGroups.get(i)[0];
		String policy_group_name=allPolicyGroups.get(i)[1];
		boolean checked=false;
		if (arrCheck.indexOf(policy_group_id)>-1) checked=true;
		
		sb.append("<tr>");
		sb.append("<td>");
		if (checked)
			sb.append("<input type=checkbox checked  onclick=\"updateMonitoringPolicyGroup('"+monitoring_id+"','"+policy_group_id+"','REMOVE');\">");
		else 
			sb.append("<input type=checkbox onclick=\"updateMonitoringPolicyGroup('"+monitoring_id+"','"+policy_group_id+"','ADD');\" >");
		sb.append("</td>");
		sb.append("<td width=\"100%\">");
		sb.append(clearHtml(policy_group_name));
		sb.append("</td>");
		sb.append("</tr>");
	}
	sb.append("</table>");
	
	return sb.toString();
}


//********************************************************************************
String makeMonitoringApplicationEditor(
		Connection conn,
		HttpSession session,
		String monitoring_id
		) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select app_id from tdm_proxy_monitoring_application where monitoring_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",monitoring_id});
	ArrayList<String[]> selectedApplications=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	ArrayList<String> arrCheck=new ArrayList<String>();
	for (int i=0;i<selectedApplications.size();i++) arrCheck.add(selectedApplications.get(i)[0]);
	
	sql="select id, name from tdm_apps where app_type='DMASK' order by 1 desc";
	bindlist.clear();
	ArrayList<String[]> allApps=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	for (int i=0;i<allApps.size();i++) {
		
		String app_id=allApps.get(i)[0];
		String app_name=allApps.get(i)[1];
		boolean checked=false;
		if (arrCheck.indexOf(app_id)>-1) checked=true;
		
		sb.append("<tr>");
		sb.append("<td>");
		if (checked)
			sb.append("<input type=checkbox checked  onclick=\"updateMonitoringApplication('"+monitoring_id+"','"+app_id+"','REMOVE');\">");
		else 
			sb.append("<input type=checkbox onclick=\"updateMonitoringApplication('"+monitoring_id+"','"+app_id+"','ADD');\" >");
		sb.append("</td>");
		sb.append("<td width=\"100%\">");
		sb.append(clearHtml(app_name));
		sb.append("</td>");
		sb.append("</tr>");
	}
	sb.append("</table>");
	
	return sb.toString();
}
//********************************************************************************
void addRemoveUserRole(
		Connection conn,
		HttpSession session,
		String user_id,
		String addremove,
		String role_id) {
	
	String sql="insert into tdm_user_role (user_id, role_id ) values (?,?)";
	if (addremove.equals("REMOVE"))
		sql="delete from tdm_user_role where user_id=? and role_id=? ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",user_id});
	bindlist.add(new String[]{"INTEGER",role_id});
	
	execDBConf(conn, sql, bindlist);
	
}


//********************************************************************************
void addRemoveSectorRule(
		Connection conn,
		HttpSession session,
		String sector_id,
		String addremove,
		String rule_id) {
	
	String sql="insert into tdm_discovery_sector_rule (discovery_sector_id, discovery_rule_id ) values (?,?)";
	if (addremove.equals("REMOVE"))
		sql="delete from tdm_discovery_sector_rule where discovery_sector_id=? and discovery_rule_id=? ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",sector_id});
	bindlist.add(new String[]{"INTEGER",rule_id});
	
	execDBConf(conn, sql, bindlist);
	
}

//********************************************************************************
String makeMadUserList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, concat(username, ' [', lname, ', ', fname, ' ]')   from tdm_user order by 2";
	bindlist.clear();
	ArrayList<String[]> userList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbAppContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<userList.size();i++) {
		
		String user_id=userList.get(i)[0];
		String user_name=userList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeUserEditor(conn, session, user_id));
		
		collapseItems.add(new String[]{
				"colUserContent_"+user_id,
				user_name,
				sbAppContent.toString(),
				"user.png",
				"makeMadUserEditor('"+user_id+"');"});
		
	}

	sb.append(makeUserHeader());
	sb.append(addCollapse("listUser",collapseItems));
	
	return sb.toString();
}


//********************************************************************************
String makeSectorList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, description   from tdm_discovery_sector order by 2";
	bindlist.clear();
	ArrayList<String[]> sectorList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbAppContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<sectorList.size();i++) {
		
		String sector_id=sectorList.get(i)[0];
		String sector_name=sectorList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeSectorEditor(conn, session, sector_id));
		
		collapseItems.add(new String[]{
				"colSectorContent_"+sector_id,
				sector_name,
				sbAppContent.toString(),
				"user.png",
				"makeSectorEditor('"+sector_id+"');"});
		
	}

	sb.append(makeSectorHeader());
	sb.append(addCollapse("listSector",collapseItems));
	
	return sb.toString();
}


//********************************************************************************
String makeMadGroupList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, group_name from tdm_group order by group_name";
	bindlist.clear();
	ArrayList<String[]> groupList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbAppContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<groupList.size();i++) {
		
		String group_id=groupList.get(i)[0];
		String group_name=groupList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeGroupEditor(conn, session, group_id));
		
		collapseItems.add(new String[]{
				"colGroupContent_"+group_id,
				group_name,
				sbAppContent.toString(),
				"group.png",
				"makeMadGroupEditor('"+group_id+"');"});
		
	}

	sb.append(makeGroupHeader());
	sb.append(addCollapse("listGroup",collapseItems));
	
	return sb.toString();
}

//********************************************************************************
String makeDatabaseList(
		Connection conn,
		ServletContext application,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, name from tdm_envs order by 2";
	bindlist.clear();
	ArrayList<String[]> dbList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbAppContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<dbList.size();i++) {
		
		String db_id=dbList.get(i)[0];
		String db_name=dbList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeDatabaseEditor(conn, application, session, db_id)); 
		
		collapseItems.add(new String[]{
				"colDatabaseContent_"+db_id,
				db_name,
				sbAppContent.toString(),
				"database.png",
				"makeDatabaseEditor('"+db_id+"');"});
		
	}

	sb.append(makeDatabaseHeader());
	sb.append(addCollapse("listDatabase",collapseItems));
	
	return sb.toString();
}


//********************************************************************************
String makeEnvironmentList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, target_name from tdm_target order by 2";
	bindlist.clear();
	ArrayList<String[]> targetList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select id, family_name from tdm_family order by 2";
	bindlist.clear();
	ArrayList<String[]> familyList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<table class=\"table table-striped table-condensed table-bordered\">");
	sb.append("<tr>");
	
	
	
	
	if (targetList.size()==0) {
		sb.append("<td align=right>");
		sb.append("No target added yet");
		sb.append("</td>");
	}
	else 
		sb.append("<td></td>");
	
	
	for (int t=0;t<targetList.size();t++) {
		String target_id=targetList.get(t)[0];	
		String target_name=targetList.get(t)[1];
		
		sb.append("<td>");
		
		sb.append("<table border=0 cellspacing=0 cellpadding=0>");
		sb.append("<tr>");
		sb.append("<td>");
		sb.append(makeText("target_"+target_id, target_name, "onchange=\"changeTargetName(this,'"+target_id+"')\"", 140));
		sb.append("</td>");
		sb.append("<td align=left>");
		sb.append("<a href=\"javascript:removeTarget('"+target_id+"')\"><font color=red><span class=\"glyphicon glyphicon-remove\"></span></font></a>");
		sb.append("</td>");
		sb.append("</tr>");
		sb.append("</table>");		
		sb.append("</td>");
	}
	
	sb.append("<td>");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addTarget()><span class=\"glyphicon glyphicon-plus\"></span>Add New Environment</button>");
	sb.append("</td>");
	
	sb.append("</tr>");
	
	if (familyList.size()==0) {
		sb.append("<tr>");
		
		sb.append("<td>");
		sb.append("No family added yet");
		sb.append("</td>");
		
		sb.append("</tr>");
	}
	
	for (int f=0;f<familyList.size();f++) {
		String family_id=familyList.get(f)[0];	
		String family_name=familyList.get(f)[1];
		
		sb.append("<tr>");
		
		sb.append("<td>");
		
		sb.append("<table border=0 cellspacing=0 cellpadding=0>");
		sb.append("<tr>");
		sb.append("<td>");
		sb.append(makeText("target_"+family_id, family_name, "onchange=\"changeFamilyName(this,'"+family_id+"')\"", 240));
		sb.append("</td>");
		sb.append("<td align=left>");
		sb.append("<a href=\"javascript:removeFamily('"+family_id+"')\"><font color=red><span class=\"glyphicon glyphicon-remove\"></span></font></a>");
		sb.append("</td>");
		sb.append("</tr>");
		sb.append("</table>");
		
		sb.append("</td>");
		
		for (int t=0;t<targetList.size();t++) {
			String target_id=targetList.get(t)[0];	
			String target_name=targetList.get(t)[1];
			
			sb.append("<td>");
			sb.append(makeTargetFamilyCell(conn,session,target_id,family_id));
			sb.append("</td>");
		}
		
		
		sb.append("<td></td>");
		
		sb.append("</tr>");
	}
	
	sb.append("<tr>");
	
	sb.append("<td>");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addFamily()><span class=\"glyphicon glyphicon-plus\"></span>Add New Family</button>");
	sb.append("</td>");
	
	sb.append("</tr>");

	sb.append("</table>");
	
	return sb.toString();
}

//********************************************************************************
String makePolicyGroupList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, policy_group_name from tdm_proxy_policy_group order by 2";
	bindlist.clear();
	ArrayList<String[]> policyGroupList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);

	StringBuilder sbAppContent=new StringBuilder();

	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<policyGroupList.size();i++) {
		
		String policy_group_id=policyGroupList.get(i)[0];
		String policy_group_name=policyGroupList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makePolicyGroupEditor(conn, session, policy_group_id)); 
		
		collapseItems.add(new String[]{
				"colPolicyGroupContent_"+policy_group_id,
				policy_group_name,
				sbAppContent.toString(),
				"database.png",
				"makePolicyGroupEditor('"+policy_group_id+"');"});
		
	}

	sb.append(makePolicyGroupHeader());
	sb.append(addCollapse("listPolicyGroup",collapseItems));
	
	return sb.toString();
}



//********************************************************************************
String makeCalendarList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, calendar_name from tdm_proxy_calendar order by 2";
	bindlist.clear();
	ArrayList<String[]> calendarList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);

	StringBuilder sbAppContent=new StringBuilder();

	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<calendarList.size();i++) {
		
		String calendar_id=calendarList.get(i)[0];
		String calendar_name=calendarList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeCalendarEditor(conn, session, calendar_id)); 
		
		collapseItems.add(new String[]{
				"colCalendarContent_"+calendar_id,
				calendar_name,
				sbAppContent.toString(),
				"calendar.png",
				"makeCalendarEditor('"+calendar_id+"');"});
		
	}

	sb.append(makeCalendarHeader());
	sb.append(addCollapse("listCalendar",collapseItems));
	
	return sb.toString();
}


//********************************************************************************
String makeSessionValidationList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, session_validation_name from tdm_proxy_session_validation order by 2";
	bindlist.clear();
	ArrayList<String[]> validationList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);

	StringBuilder sbAppContent=new StringBuilder();

	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<validationList.size();i++) {
		
		String session_validation_id=validationList.get(i)[0];
		String session_validation_name=validationList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeSessionValidationEditor(conn, session, session_validation_id)); 
		
		collapseItems.add(new String[]{
				"colSessionValidationContent_"+session_validation_id,
				session_validation_name,
				sbAppContent.toString(),
				"validation.png",
				"makeSessionValidationEditor('"+session_validation_id+"');"});
		
	}

	sb.append(makeSessionValidationHeader());
	sb.append(addCollapse("listSessionValidation",collapseItems));
	
	return sb.toString();
}


//********************************************************************************
String makeMonitoringList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, monitoring_name from tdm_proxy_monitoring order by 2";
	bindlist.clear();
	ArrayList<String[]> monitoringList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);

	StringBuilder sbAppContent=new StringBuilder();

	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<monitoringList.size();i++) {
		
		String monitoring_id=monitoringList.get(i)[0];
		String monitoring_name=monitoringList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeMonitoringEditor(conn, session, monitoring_id)); 
		
		collapseItems.add(new String[]{
				"colMonitoringContent_"+monitoring_id,
				monitoring_name,
				sbAppContent.toString(),
				"policy.png",
				"makeMonitoringEditor('"+monitoring_id+"');"});
		
	}

	sb.append(makeMonitoringHeader());
	sb.append(addCollapse("listMonitoring",collapseItems));
	
	return sb.toString();
}




//********************************************************************************
String makeCalendarExceptionHeader(String calendar_id) {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewCalendarException('"+calendar_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append("Add Exception");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}


//********************************************************************************
String makeCalendarExceptionList(
		Connection conn,
		HttpSession session,
		String calendar_id
		) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, calendar_exception_name,  DATE_FORMAT(exception_start_time,?) exception_start_time, DATE_FORMAT(exception_end_time,?) exception_end_time "+
			" from tdm_proxy_calendar_exception where calendar_id=? order by 2";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"INTEGER",calendar_id});
	ArrayList<String[]> calendarExceptionList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);

	StringBuilder sbAppContent=new StringBuilder();

	ArrayList<String[]> collapseItems=new ArrayList<String[]>();
	
	sb.append(makeCalendarExceptionHeader(calendar_id));
	
	
	if (calendarExceptionList.size()==0) {
		sb.append("<br>No exception defined yet.");
		return sb.toString();
	}
	
	sb.append("<table class=table>");
	sb.append("<tr class=info>");
	sb.append("<td><b>Exception Description</b></td>");
	sb.append("<td><b>Start Time / End Time</b></td>");
	sb.append("<td><b></b></td>");
	sb.append("</tr>");

	for (int i=0;i<calendarExceptionList.size();i++) {
		
		String calendar_exception_id=calendarExceptionList.get(i)[0];
		String calendar_exception_name=calendarExceptionList.get(i)[1];
		String exception_start_time=calendarExceptionList.get(i)[2];
		String exception_end_time=calendarExceptionList.get(i)[3];
		
		
		sb.append("<tr class=active>");
		
		sb.append("<td>");
		sb.append(makeText("calendar_exception_name", clearHtml(calendar_exception_name), " onchange=saveCalendarExceptionField(this,'"+calendar_exception_id+"')", 300));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeDate("0", "exception_start_time_"+calendar_exception_id, exception_start_time, "onchange=updateCalendarExceptionDate("+calendar_exception_id+",1)"));
		
		sb.append(makeDate("0", "exception_end_time_"+calendar_exception_id, exception_end_time, "onchange=updateCalendarExceptionDate("+calendar_exception_id+",2)"));
		sb.append("</td>");
		
		sb.append("<td align=left>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteCalendarException('"+calendar_id+"','"+calendar_exception_id+"');\">");
		sb.append("<span class=\"glyphicon glyphicon-remove\">");
		sb.append("</span>");
		sb.append("</button>");		sb.append("</td>");
		
		sb.append("</tr>");
		
		
		

	}

	sb.append("</table>");

	
	return sb.toString();
}
//********************************************************************************
String makeTargetFamilyCell(Connection conn, HttpSession session, String target_id, String family_id) {
	
	String sql="";
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select e.id, e.name from tdm_envs e, tdm_target_family_env tfe "+
		" where env_id=e.id "+ 
		" and target_id=? and family_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",target_id});
	bindlist.add(new String[]{"INTEGER",family_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String curr_db_id="";
	String curr_db_name="";
	
	if (arr!=null && arr.size()==1) {
		curr_db_id=arr.get(0)[0];
		curr_db_name=arr.get(0)[1];
	}
	
	
	
	sb.append("<table border=0 cellspacing=0 cellpadding=0>");
	
	sb.append("<tr>");
	
	
	sb.append("<td>");
	sb.append("<a href=\"javascript:setTargetFamilyEnv('"+target_id+"','"+family_id+"')\"><font color=blue><span class=\"glyphicon glyphicon-list\"></span></font></a>");
	sb.append("</td>");
	
	if (curr_db_name.length()>0) {
		sb.append("<td>");
		sb.append("<a href=\"javascript:removeTargetFamilyDb('"+target_id+"','"+family_id+"')\"><font color=red><span class=\"glyphicon glyphicon-remove\"></span></font></a>");
		sb.append("</td>");
	}

	sb.append("<td width=\"100%\">");
	
	if (curr_db_name.length()>0) 
		sb.append("<span class=\"label label-primary\">"+curr_db_name+"</span>");
	else 
		sb.append("<a href=\"javascript:setTargetFamilyEnv('"+target_id+"','"+family_id+"')\"><span class=\"label label-warning\" style=\"width:100%\">No Database Set!</span></a>");
	
	sb.append("</td>");
	
	
	
	
	sb.append("</tr>");
	
	sb.append("</table>");


	
	return sb.toString();
}

//********************************************************************************
String loadConfigurationMenu(
		Connection conn,
		HttpSession session) {
	
	String sql="";
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();
	sql="";
	
	
	
	
	collapseItems.clear();
	collapseItems.add(new String[]{"colUsers","User","","user.png","javascript:makeMadUserList()"});
	collapseItems.add(new String[]{"colGroups","Group","","group.png","javascript:makeMadGroupList()"});
	collapseItems.add(new String[]{"colDatabases","Database","","database.png","javascript:makeDatabaseList()"});
	collapseItems.add(new String[]{"colEnvironments","Environment","","environment.png","javascript:makeEnvironmentList()"});
	collapseItems.add(new String[]{"colPolicyGroups","Policy Group","","policy_group.png","javascript:makePolicyGroupList()"});
	collapseItems.add(new String[]{"colCalendar","Calendar","","calendar.png","javascript:makeCalendarList()"});
	collapseItems.add(new String[]{"colMonitoring","Monitoring","","policy.png","javascript:makeMonitoringList()"});
	collapseItems.add(new String[]{"colSessionValidation","Validation","","validation.png","javascript:makeSessionValidationList()"});
	collapseItems.add(new String[]{"colSector","Sector","","sector.png","javascript:makeSectorList()"});
	
	sb.append(addTab("madConfigurationMenu",collapseItems));

	
	
	return sb.toString();
}



//--------------------------------------------------
String changeWorkPlanProcessLimit(Connection conn, HttpSession session, String work_plan_id, String limit_type, String limit) {
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="";
	
	sql="update tdm_work_plan set worker_limit=? ";
	if (limit_type.equals("master")) sql="update tdm_work_plan set master_limit=? ";
	
	sql=sql + "where id=?";
	
	try {
		int limit_INT=Integer.parseInt(limit);
		
		
		bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER", ""+limit_INT});
		bindlist.add(new String[]{"INTEGER", work_plan_id});
		execDBConf(conn, sql, bindlist);
		
	} catch(Exception e) {
		e.printStackTrace();
	}

	return sb.toString();
}

//-----------------------------------------------------------------------------------------------
String makeProcessSummary(Connection conn, HttpSession session) {
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="";
	boolean readonly=true;
	//kill stalled manager
	sql="delete from tdm_manager where  last_heartbeat<DATE_ADD(NOW(), INTERVAL -15 MINUTE)";
	bindlist.clear();
	execDBConf(conn, sql, bindlist);
	
	//kill stalled masters
	sql="delete from tdm_master where  last_heartbeat<DATE_ADD(NOW(), INTERVAL -15 MINUTE)";
	bindlist.clear();
	execDBConf(conn, sql, bindlist);
	
	//kill stalled workers
	sql="delete from tdm_worker where  last_heartbeat<DATE_ADD(NOW(), INTERVAL -15 MINUTE)";
	bindlist.clear();
	execDBConf(conn, sql, bindlist);
	
	
	sql="select status, last_heartbeat, hostname, cancel_flag from tdm_manager";
	bindlist.clear();
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	String status="";
	String last_heartbeat="";
	String hostname="";
	String cancel_flag="";

	if (arr.size()==1) {
		status=arr.get(0)[0];
		last_heartbeat=arr.get(0)[0];
		hostname=arr.get(0)[0];
		cancel_flag=arr.get(0)[0];
	}
	else 
	{
		status="stopped";
	}
	
	
	String status_img="running.gif";
	if (status.equals("stopped")) status_img="stopping.png";
	if (cancel_flag.equals("YES")) status_img="cancelling.png";
	
	sb.append("<table border=0 cellpadding=0 cellspacing=0 width=\100%\">");
	
	sb.append("<tr>");
	sb.append("<td nowrap><small><a href=\"javascript:showProcessWindow('manager','ALL');\"><b>Manager</b></a> : </small></td>");
	sb.append("<td nowrap>");
	sb.append("<img src=\"img/"+status_img+"\" width=24 height=24> &nbsp;&nbsp;");
	sb.append("</td>");
	
	int p_target_worker_count=0;
	int p_target_master_count=0;
	int running_worker_count=0;
	int running_master_count=0;

	try {
			p_target_master_count=Integer.parseInt(nvl(getParamByName(conn, "TARGET_MASTER_COUNT"),"0"));
			
			p_target_worker_count=Integer.parseInt(nvl(getParamByName(conn, "TARGET_WORKER_COUNT"),"0"));	
			
			sql="select count(*) from tdm_master";
			running_master_count=Integer.parseInt(getDBSingleVal(conn, sql));
			
			sql="select count(*) from tdm_worker";
			running_worker_count=Integer.parseInt(getDBSingleVal(conn, sql));
			
		} catch(Exception e) {
			p_target_master_count=0;
			p_target_worker_count=0;
			running_worker_count=0;
			running_master_count=0;
		}
	
	
	sb.append("<td nowrap><small><a href=\"javascript:showProcessWindow('master','ALL');\">Master</a> : </small></td>");
	sb.append("<td nowrap>");
	sb.append(""+running_master_count + " / <font color=red><b>" + p_target_master_count+"</b></font>&nbsp;&nbsp;");
	sb.append("</td>");
	
	
	
	sb.append("<td nowrap><small> <a href=\"javascript:showProcessWindow('worker','ALL');\">Worker</a> : </small></td>");
	
	sb.append("<td nowrap>");
	sb.append(""+running_worker_count + " / <font color=red><b>" + p_target_worker_count+"</b></font>&nbsp;&nbsp;");
	sb.append("</td>");
	
	sb.append("</tr>");
	
	
	sb.append("</table>");
	
	
	
	
	
	return sb.toString();
}

//-----------------------------------------------------------------------------------------------
String makeWorkPlanList(Connection conn, HttpSession session, 
		String work_plan_type_filter, 
		String work_plan_status_filter,
		String refresh_interval) {
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="";
	
	session.setAttribute("work_plan_type_filter", work_plan_type_filter);
	session.setAttribute("work_plan_status_filter", work_plan_status_filter);
	session.setAttribute("refresh_interval_for_WORK_PLAN_LIST", nvl(refresh_interval,"manual"));
	
	sql="select "+
			" id, "+
			" wplan_type, "+
			" status, "+
			" work_plan_name,  " +
			" master_limit,  " +
			" worker_limit,  " +
			" DATE_FORMAT(start_date,?) start_date, " + 
			" DATE_FORMAT(end_date,?) end_date, " +
			" app_id, "+
			" env_id, " + 
			" length(WARNING_MESSAGE) len_warning, " +
			" (select concat(fname, ' ', lname ) from tdm_user where id=created_by) created_by " + 
			" from tdm_work_plan";
	
	bindlist.add(new String[]{"STRING",""+mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	
	if (work_plan_type_filter.length()>0) {
		if (!sql.contains("WHERE")) sql=sql+ " WHERE ";
		else sql=sql+ " AND ";
		
		sql=sql+ " wplan_type=?";
		bindlist.add(new String[]{"STRING",work_plan_type_filter});
	}
	
	if (work_plan_status_filter.length()>0) {
		if (!sql.contains("WHERE")) sql=sql+ " WHERE ";
		else sql=sql+ " AND ";
		
		sql=sql+ "  status=?";
		bindlist.add(new String[]{"STRING",work_plan_status_filter});
	}
		
	sql=sql+ " order by 1 desc";
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 100, bindlist);
	
	if (arr.size()==0) return "<br><font color=red> ! No work plan matched...</font>";

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	int wpno=0;
	int wpperline=3;
	int col_md_size=(12-wpperline) /wpperline;
	
	
	
	for (int i=0;i<arr.size();i++) {
			String wp_id=arr.get(i)[0];
			String wplan_type=arr.get(i)[1];
			String status=arr.get(i)[2];
			String wplan_name=arr.get(i)[3];
			String master_limit=arr.get(i)[4];
			String worker_limit=arr.get(i)[5];
			String start_date=arr.get(i)[6];
			String end_date=arr.get(i)[7];
			String app_id=arr.get(i)[8];
			String env_id=arr.get(i)[9];
			String len_warning=nvl(arr.get(i)[10],"0");
			String created_by=arr.get(i)[11];
			
			
			wpno++;
			
			if (wpno % wpperline==1) sb.append("<div class=row>");
			
			String bgcolor="#996633";
			if (status.equals("NEW")) bgcolor="#999966";
			if (status.equals("PREPARATION")) bgcolor="#996633";
			if (status.equals("RUNNING")) bgcolor="#FF9933";
			if (status.equals("FINISHED")) bgcolor="#004700";
			if (status.equals("CANCELLED")) bgcolor="#B22400";
			if (status.equals("PAUSED")) bgcolor="#666633";
			if (status.equals("FAILED")) bgcolor="#B22400";
			
			
			String rounding_corner_style=" style=\"background: #FFFFD1; "+
							"height=300px; "+
							"-moz-border-radius: 6px; "+
							"-webkit-border-radius:6px; "+
							"border-radius: 6px; "+
							"box-shadow: 6px 6px 5px #888888; "+
							" border: 5px ridge #98bf21;padding:3px; border-color: #CCCCFF; " + 
							" \" ";
			
			if (wpno % wpperline!=1) {
				sb.append("<div class=\"col-md-1\">");
				sb.append("</div>");
			}

			
					
			sb.append("<div class=\"col-md-"+col_md_size+"\" id=wpDivForWpID"+wp_id+" "+rounding_corner_style+">");
			
			
		
			
			//---------------------
			sb.append("<div class=row>");
			
			rounding_corner_style=" style=\"background: "+bgcolor+"; "+
					"height=300px;  \" ";
			
			sb.append("<div class=\"col-md-3\" align=center "+rounding_corner_style+">"); //left div
			
			sb.append("<b><font color=white>["+wp_id+"]</font></b>");
			sb.append("<br>");
			sb.append("<font color=lightgreen><span class=\"glyphicon glyphicon-folder-open\" onclick=openWorkPlanWindow('"+wp_id+"');></span></font>");
			sb.append("&nbsp;<font color=lightblue><span class=\"glyphicon glyphicon-cog\" onclick=editWorkPlan('"+wp_id+"');></span></font>");
			sb.append("<br>");
			sb.append("</div>");
			
			
			
			sb.append("<div class=\"col-md-9\">");  //main div md 9
			
			
			
			sb.append("<div class=row>");
			sb.append("<div class=\"col-md-10\" align=center>");
			sb.append("  <small><small><b><font color=#663300>"+wplan_name+"</font></b></small></small></span>");
			sb.append("</div>");
			
			sb.append("<div class=\"col-md-2\" align=left>");
			sb.append("<img width=18 height=18 src=\"img/wptypes/"+wplan_type+".png\" >");
			sb.append("</div>");
			
			sb.append("</div>");
			
			
			sb.append("<div class=row>");
			sb.append("<div class=\"col-md-4\" align=right><font color=#1A1A4C><small>By :</small></font></div>");
			sb.append("<div class=\"col-md-8\">");
			sb.append("<font color=#003300><small><b>"+created_by+"</b></small></font>");
			sb.append("</div>");
			sb.append("</div>");
			
			sb.append("<div class=row>");
			sb.append("<div class=\"col-md-4\" align=right><font color=#1A1A4C><small>Status :</small></font></div>");
			sb.append("<div class=\"col-md-8\">");
			sb.append("<font color=#003300><small><b>"+status+"</b></small></font>");
			sb.append("</div>");
			sb.append("</div>");
			
			
			int progress=getProgressRate(conn, wp_id);
			String progress_str="<div class=\"progress\" style=\"width:80%;  background-color:gray; \">"+
								"<div class=\"progress-bar\" role=\"progressbar\" aria-valuenow=\""+progress+"\" aria-valuemin=\"0\" aria-valuemax=\"100\" style=\"width: "+progress+"%;\">"+
							 	progress+" %"+
								"</div>"+
								"</div>";
			
								
			sb.append("<div class=row>");
			sb.append("<div class=\"col-md-4\" align=right><font color=#1A1A4C><small>Progress :</small></font></div>");
			sb.append("<div class=\"col-md-8\">");
			sb.append(progress_str);
			sb.append("</div>");
			sb.append("</div>");
			
			
			if (!len_warning.equals("0")) {
				
				sb.append("<div class=row>");
				sb.append("<div class=\"col-md-4\" align=right><font color=#1A1A4C><small>Warnings :</small></font></div>");
				sb.append("<div class=\"col-md-8\">");
				
				sb.append("<button type=button class=\"btn btn-sm btn-warning\" onclick=\"showWarningMsg('"+wp_id+"')\">");
				sb.append("<span class=\"glyphicon glyphicon-info-sign\"></span>");
				sb.append("</button>");
				
				sb.append("</div>");
				sb.append("</div>");
			}
			
			
			
			
			if (status.equals("INVALID")) {
							
				sb.append("<div class=row>");
				sb.append("<div class=\"col-md-4\" align=right><font color=#1A1A4C><small>Problems :</small></font></div>");
				sb.append("<div class=\"col-md-8\">");
				
				sb.append(" <button type=button class=\"btn btn-sm btn-danger\" onclick=\"showInvalidMsg('"+wp_id+"')\">");
				sb.append("<span class=\"glyphicon glyphicon-ban-circle\"></span>");
				sb.append("</button>");
				
				sql="select count(*) from tdm_work_package where work_plan_id="+wp_id;
				String wpc_count=getDBSingleVal(conn, sql);
				//if masking validation is not passed
				if (!wpc_count.equals("0")) {
					sb.append(" <button type=button class=\"btn btn-success btn-sm\" onclick=\"skipValidation('"+wp_id+"','list');\">");
					sb.append(" <span class=\"glyphicon glyphicon-ok\">Skip</span>");
					sb.append("</button>");
				}
				
				
				sb.append("</div>");
				sb.append("</div>");
			}
			
			
			
			
			
			
			if (wplan_type.equals("DISC") || wplan_type.equals("MASK") || wplan_type.equals("MASK2") || wplan_type.equals("COPY")) {
				
				String app_name=getDBSingleVal(conn,"select name from tdm_apps where id="+app_id);
				String env_name=getDBSingleVal(conn,"select name from tdm_envs where id="+env_id);
				
				sb.append("<div class=row>");
				sb.append("<div class=\"col-md-4\" align=right><font color=#1A1A4C><small>App. :</small></font></div>");
				sb.append("<div class=\"col-md-8\"><font color=#003300><small><b>"+nvl(app_name,"-")+"</b></small></font></div>");
				sb.append("</div>");
				
				sb.append("<div class=row>");
				sb.append("<div class=\"col-md-4\" align=right><font color=##1A1A4C><small>Env. :</small></font></div>");
				sb.append("<div class=\"col-md-8\"><font color=#003300><small><b>"+nvl(env_name,"-")+"</b></small></font></div>");
				sb.append("</div>");
					
			}


			sb.append("<div class=row>");
			sb.append("<div class=\"col-md-4\" align=right><font color=#1A1A4C><small>Start :</small></font></div>");
			sb.append("<div class=\"col-md-8\"><font color=#003300><small><b>"+start_date+"</b></small></font></div>");
			sb.append("</div>");

			if (end_date.length()>0) {
				sb.append("<div class=row>");
				sb.append("<div class=\"col-md-4\" align=right><font color=#1A1A4C><small>Finish :</small></font></div>");
				sb.append("<div class=\"col-md-8\"><font #003300=yellow><small><b>"+end_date+"</b></small></font></div>");
				sb.append("</div>");
			}
			
			
			sb.append("<div class=row>");
			sb.append("<div class=\"col-md-4\" align=right><font color=#1A1A4C><small>Process :</small></font></div>");
			sb.append("<div class=\"col-md-8\"><font color=#003300><small><b>"+master_limit+" / "+worker_limit+" </b></small></font></div>");
			sb.append("</div>");
			
			
			
			//---------------------
			
			sb.append("</div>"); // sb.append("<div class=\"col-md-9\">"); 
			sb.append("</div>");
			sb.append("</div>");
			
			if (wpno % wpperline==0)  {
				sb.append("</div>");
				
				sb.append("<br>");
			}
			
	}
	
	sb.append("</div>");
	sb.append("</div>");

	
	
	return sb.toString();
}
//-----------------------------------------------------------------------------------------------
String makeWorkPlanDiv(Connection conn, HttpSession session) {
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="";
	
	String work_plan_type_filter=nvl((String) session.getAttribute("work_plan_type_filter"),"");
	String work_plan_status_filter=nvl((String) session.getAttribute("work_plan_status_filter"),"");
	
	
	
	sb.append("<table border=0 cellspacing=0 cellpadding=0 width=\"100%\">");
	sb.append("<tr>");


	sb.append("<td nowrap><b>Type : </b></td>");
	sb.append("<td>");	
	
	sql=	" select '','[All]' from dual union all "+
			" select 'DISC','Discovery' from dual union all " +
			" select 'MASK2','Masking' from dual union all "+
			" select 'COPY2','Copying' from dual";
	
	sb.append(makeCombo(conn, sql, "", "size=0 id=work_plan_type_filter onchange=makeWorkPlanList() ", work_plan_type_filter, 120));
	
	sb.append("</td>");

	sb.append("<td nowrap><b>Status : </b></td>");
	sb.append("<td>");	
	sb.append("<div class=\"col-md-8\">");
	sql=	"select '','[All]' from dual union all "+
			"select  'NEW','New' from dual union all "+
			" select 'RUNNING','Running' from dual union all " +
			" select 'COMPLETED','Completed' from dual union all"+
			" select 'FINISHED','Finished' from dual union all"+
			" select 'CANCELLED','Cancelled' from dual union all"+
			" select 'PAUSED','Paused' from dual union all"+
			" select 'PREPARATION','Preparation' from dual union all"+
			" select 'INVALID','Invalid' from dual";
	sb.append(makeCombo(conn, sql, "", "size=0 id=work_plan_status_filter onchange=makeWorkPlanList() ", work_plan_status_filter, 120));
	sb.append("</td>");	
	
	
	sb.append("<td nowrap><b>Refresh : </b></td>");
	sb.append("<td nowrap>");	
	sb.append(makeRefreshmentIntervalCombobox(session,"WORK_PLAN_LIST"));
	sb.append("</td>");
	
	sb.append("<td nowrap>");	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=makeWorkPlanList()>");
	sb.append("<span class=\"glyphicon glyphicon-refresh\"></span>");
	sb.append("</button>");
	sb.append("</td>");
	
	sb.append("</tr>");
	sb.append("</table>");
	
	return sb.toString();
}

//---------------------------------------------------
String makeRefreshmentIntervalCombobox(HttpSession session, String interval_type) {
	StringBuilder sb=new StringBuilder();
	
	String curr_refresh_interval=nvl((String) session.getAttribute("refresh_interval_for_"+interval_type),"manual");
	
	ArrayList<String[]> arr=new ArrayList<String[]>();
	arr.add(new String[]{"manual","Manual"});
	arr.add(new String[]{"1","Realtime"});
	arr.add(new String[]{"15","15 sec"});
	arr.add(new String[]{"30","30 sec"});
	arr.add(new String[]{"60","1 min"});
	arr.add(new String[]{"120","2 min"});
	arr.add(new String[]{"180","3 min"});
	arr.add(new String[]{"300","5 min"});
	arr.add(new String[]{"600","10 min"});
	arr.add(new String[]{"1200","20 min"});
	arr.add(new String[]{"1800","30 min"});
	sb.append(makeComboArr(arr, "", "size=1 id=refresh_interval_for_"+interval_type+" onchange=setRefreshInterval('"+interval_type+"') ", curr_refresh_interval, 0));

	
	return sb.toString();
	
	

}

//---------------------------------------------------

String drawMonitoringAreas(Connection conn, ServletContext application, HttpSession session) {
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-8\">");
	sb.append(makeWorkPlanDiv(conn, session));
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-4\" align=right>");
	sb.append(makeProcessSummary(conn, session));
	sb.append("</div>");

	
	sb.append("<div class=row>");
	
	
	sb.append("<div class=\"col-md-12\" id=monitoringRightDiv style=\"min-height: 500px; max-height: 5000px; overflow-y: scroll;\">");
	
	String work_plan_type_filter=nvl((String) session.getAttribute("work_plan_type_filter"),"");
	String work_plan_status_filter=nvl((String) session.getAttribute("work_plan_status_filter"),"");
	String curr_refresh_interval=nvl((String) session.getAttribute("refresh_interval"),"manual");
	
	sb.append("<div id=workPlanListDiv>");
	sb.append(makeWorkPlanList(conn, session, work_plan_type_filter, work_plan_status_filter,curr_refresh_interval));
	sb.append("</div>");
	sb.append("</div>"); 
	
	sb.append("</div>");
	    
	    
	return sb.toString();
}


//---------------------------------------------------
String makeProcessWindow(Connection conn, HttpSession session, String ptype, String pstatus) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select id, status, hostname, start_date, cancel_flag, "+
				" last_heartbeat, TIMESTAMPDIFF(MINUTE,last_heartbeat,NOW()) last_heartbeat_as_minute, "+
				ptype+"_name " +
				" from tdm_"+ptype;
	
	if (!pstatus.equals("ALL")) {
		sql = sql + " where status='"+ pstatus +"'";
	}
	
	sql=sql + " order by id";
	
	if (ptype.equals("manager"))
		sql="select 0 id, status, hostname, 'N/A' start_date, cancel_flag, last_heartbeat, "+
				" TIMESTAMPDIFF(MINUTE,last_heartbeat,NOW()) last_heartbeat_as_minute, '-' man_name   "+
				" from tdm_"+ptype;
	
	
	ArrayList<String[]> pArr=getDbArrayConf(conn, sql, 1000, new ArrayList<String[]>());
	
	sb.append("<div class=\"panel panel-primary\">");

	sb.append("<div class=\"panel-heading\">");
	
	if (ptype.equals("manager")) {
		String status="";
		String last_heartbeat="";
		String hostname="";
		String cancel_flag="";
		
		if (pArr.size()==1) {
			status=pArr.get(0)[0];
			last_heartbeat=pArr.get(0)[0];
			hostname=pArr.get(0)[0];
			cancel_flag=pArr.get(0)[0];
		}
		else 
			status="stopped";
		
		String status_img="running.gif";
		if (status.equals("stopped")) status_img="stopping.png";
		if (cancel_flag.equals("YES")) status_img="cancelling.png";
		
		sb.append("Manager  : ");
		sb.append("<img src=\"img/"+status_img+"\" width=24 height=24 data-toggle=\"popover\" title=\""+ hostname +" ["+last_heartbeat+"]\"> ");
	
		if (status.equals("stopped")) {
			sb.append(
				" <button type=\"button\" class=\"btn btn-sm btn-success\" onclick=setProcessStatus('manager',0,'start') data-toggle=\"tooltip\" data-placement=\"left\" title=\"Start\">\n" +
				  " <span class=\"glyphicon glyphicon-play\" aria-hidden=\"true\" alt=\"Start\">\n" +" </span>\n" +
				" </button>\n");
		}
	
	}
		
	
	if (ptype.equals("master")) {
		
		int p_target_master_count=0;
		try {p_target_master_count=Integer.parseInt(nvl(getParamByName(conn, "TARGET_MASTER_COUNT"),"0"));} catch(Exception e) {p_target_master_count=0;}
		
		sb.append("Masters ("+pstatus+") : <span class=badge>"+pArr.size()+"</span>");
		sb.append(" / ");
		sb.append("<input type=text name=TARGET_MASTER_COUNT id=TARGET_MASTER_COUNT size=2 maxlength=2 value=\""+p_target_master_count+"\"  style=\"color:red; \" onchange=setProcessStatus('master',this.value,'set_limit')>");
	
	}
		

	if (ptype.equals("worker")) {
		int p_target_worker_count=0;
		try {p_target_worker_count=Integer.parseInt(nvl(getParamByName(conn, "TARGET_WORKER_COUNT"),"0"));} catch(Exception e) {p_target_worker_count=0;}
		
		sb.append("Workers ("+pstatus+") : <span class=badge>"+pArr.size()+"</span>");
		sb.append(" / ");
		sb.append("<input type=text name=TARGET_WORKER_COUNT id=TARGET_WORKER_COUNT size=2 maxlength=2 value=\""+p_target_worker_count+"\"  style=\"color:red; \" onchange=setProcessStatus('worker',this.value,'set_limit')>");
	}
		
	
	

	sb.append("</div> <!-- panel heading -->");
	sb.append("<div class=\"panel-body\">");

	
	sb.append("<div class=row>");
	
	if (!ptype.equals("manager")) {
		sb.append("<div class=\"col-md-2\" align=right>");
		sb.append("<b> Process Status : </b> ");
		sb.append("</div>");
		
		sb.append("<div class=\"col-md-3\">");
		ArrayList<String[]> pStateArr=new ArrayList<String[]>();
		pStateArr.add(new String[]{"ALL","All"});
		pStateArr.add(new String[]{"FREE","Free"});
		pStateArr.add(new String[]{"BUSY","Busy"});
		pStateArr.add(new String[]{"ASSIGNED","Assigned"});
		
		sb.append(makeComboArr(pStateArr, "", "size=0 id=process_status_filter onchange=refreshProcessWindow('"+ptype+"'); ", pstatus, 0));
		sb.append("</div>");
	}
	
	
	
	sb.append("<div class=\"col-md-1\">");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=refreshProcessWindow('"+ptype+"'); >");
	sb.append("<span class=\"glyphicon glyphicon-refresh\"></span>");
	sb.append("</button>");
	sb.append("</div>");
	
	
	sb.append("</div>");
		
	sb.append("<table class=\"table table-striped\">"+
		"<tr>"+
			"<td><b>ID</b></td>"+
			"<td><b>NAME</b></td>"+
			"<td><b>STATUS</b></td>"+
			"<td><b>HOST INFO</b></td>"+
			"<td><b>START</b></td>"+
			"<td><b>HEARTBEAT</b></td>"+
			"<td><b>BUSY ON</b></td>"+
			"<td><b></b></td>"+
		"</tr>");
		
	for (int m=0;m<pArr.size();m++) {
		
		String tr_class="success";
		String status=pArr.get(m)[1];
		
		if (status.equals("BUSY")) tr_class="warning";
		if (status.equals("ASSIGNED")) tr_class="warning";
		
		String busy_on="IDDLE";
		
		if (status.equals("BUSY")) {
			if (ptype.equals("master")) 
				sql="select wp_name from tdm_work_package where master_id="+pArr.get(m)[0];
			else 
				sql="select max(wp_name) "+
					" from tdm_work_package "+
					" where id in(select work_package_id from tdm_task_assignment where worker_id="+pArr.get(m)[0]+") ";
			busy_on=getDBSingleVal(conn, sql);
		}
		
		if (ptype.equals("manager")) busy_on="-";
	
		String process_id=pArr.get(m)[0];
		String host_info=pArr.get(m)[2];
		String start_time=pArr.get(m)[3];
		String cancel_flag=pArr.get(m)[4];
		String last_heartbeat=pArr.get(m)[5];
		Integer last_heartbeat_as_minute=Integer.parseInt(pArr.get(m)[6]);
		
		String process_name=pArr.get(m)[7];
		
		if (last_heartbeat_as_minute>5) {
			last_heartbeat="<font color=red><span class=\"glyphicon glyphicon-remove-sign\"></span></font> " +last_heartbeat;
		} else {
			last_heartbeat=" <font color=green><span class=\"glyphicon glyphicon-ok-sign\"></span></font> " +last_heartbeat;
		}
		
		if (cancel_flag.equals("YES")) {
			cancel_flag="<font color=red><span class=\"glyphicon glyphicon-remove\"></span></font>";
		}
			
		else {
			cancel_flag="<input type=\"button\" class=\"btn btn-sm btn-danger\" value=\"Stop\" onclick=\"setProcessAction('"+ptype+"','"+process_id+"','stop','"+pstatus+"');\">";

			if (status.equals("RUNNING") && !cancel_flag.equals("YES")) 
				
				cancel_flag=cancel_flag+			
						" <button type=\"button\" class=\"btn btn-sm  btn-warning\" onclick=setProcessStatus('manager',0,'restart')  data-toggle=\"tooltip\" data-placement=\"left\" title=\"Restart Manager\">\n" +
						  " Restart \n" +
						" </button>\n";
			
		}
			
		
			
		
		sb.append(""+
					"<tr class=\""+tr_class+"\">"+
					"<td>"+process_id+"</td>"+
					"<td>"+process_name+"</td>"+
					"<td>"+status+"</td>"+
					"<td>"+host_info+"</td>"+
					"<td>"+start_time+"</td>"+
					"<td>"+last_heartbeat+"</td>"+
					"<td>"+nvl(busy_on,"-")+"</td>"+
					"<td>"+cancel_flag+"</td>"+
					"</tr>");
				
	}
	
	sb.append("</table>");

	sb.append("</div> <!-- panel body -->");

	sb.append("</div> <!-- panel-->");
	
	return sb.toString();
}

//***************************************************************
String makeWorkPlanParamEditor(Connection conn, HttpSession session, String work_plan_id) {
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select work_plan_name, status, email_address, on_error_action, execution_type, REC_SIZE_PER_TASK, " + 
				" master_limit, worker_limit, " +
				" repeat_period, repeat_by, repeat_parameters " + 
				" from tdm_work_plan where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",work_plan_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==0) 
		return "workplan not found " + work_plan_id;
	
	String work_plan_name=arr.get(0)[0];
	String status=arr.get(0)[1];
	String email_address=arr.get(0)[2];
	String on_error_action=arr.get(0)[3];
	String execution_type=arr.get(0)[4];
	String REC_SIZE_PER_TASK=arr.get(0)[5];
	String master_limit=arr.get(0)[6];
	String worker_limit=arr.get(0)[7];
	String repeat_period=arr.get(0)[8];
	String repeat_by=arr.get(0)[9];
	String wp_repeat_parameters=arr.get(0)[10];
	
	sb.append("<input type=hidden id=editing_work_plan_id value="+work_plan_id+">");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><b> Work Plan Id : </b></div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append("<span class=badge>"+work_plan_id+"</span>");
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><b> Status : </b></div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append("<span class=badge>"+status+"</span>");
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><b> Notification E-Mail : </b></div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append(makeText("wp_email_address", email_address, "", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><b> Execution Type : </b></div>");
	sb.append("<div class=\"col-md-8\">");
	ArrayList<String[]> arrExType=new ArrayList<String[]>();
	arrExType.add(new String[]{"PARALLEL","Parallel Execution"});
	arrExType.add(new String[]{"SERIAL","! Serial Executions"});	
	sb.append(makeComboArr(arrExType, "", "id=wp_execution_type size=0 ", execution_type, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><b> On error : </b></div>");
	sb.append("<div class=\"col-md-8\">");
	ArrayList<String[]> arrOnErr=new ArrayList<String[]>();
	arrOnErr.add(new String[]{"CONTINUE","> Continue"});
	arrOnErr.add(new String[]{"STOP","! Stop"});	
	sb.append(makeComboArr(arrOnErr, "", "id=wp_on_error_action size=0 ", on_error_action, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><b> Record count in task : </b></div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append(makeNumber("0", "wp_REC_SIZE_PER_TASK", REC_SIZE_PER_TASK, "", "EDIT", "6","0", ",", "", "", "1", "100000"));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><b> Master Limit : </b></div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append(makeNumber("0", "wp_master_limit", master_limit, "", "EDIT", "4","0", ",", "", "", "0", "999"));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><b> Worker Limit : </b></div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append(makeNumber("0", "wp_worker_limit", worker_limit, "", "EDIT", "4","0", ",", "", "", "0", "999"));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><b> Schedule Interval : </b></div>");
	sb.append("<div class=\"col-md-8\">");
	ArrayList<String[]> repeatArr=new ArrayList<String[]>();
    repeatArr.add(new String[]{"NONE","No Repeat"});
    repeatArr.add(new String[]{"DAILY","Daily"});
    repeatArr.add(new String[]{"HOURLY","Hourly"});
    repeatArr.add(new String[]{"MINUTE","Every ? Minute"});
    sb.append(makeComboArr(repeatArr, "", "id=wp_repeat_period size=1 ", repeat_period, 200));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><b> Schedule Period : </b></div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append(makeNumber("0", "wp_repeat_by", repeat_by, "", "EDIT", "6","0", ",", "", "", "0", "99999"));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><b> Repeat Parameters : </b></div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append(makeText("wp_repeat_parameters", wp_repeat_parameters, "", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	return sb.toString();
}

//***************************************************************
void saveWorkPlanParams(Connection conn, HttpSession session,
		String work_plan_id,
		String wp_email_address,
		String wp_execution_type,
		String wp_on_error_action,
		String wp_options) {
	
	


	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String wp_REC_SIZE_PER_TASK="1000";
	String wp_master_limit="";
	String wp_worker_limit="";
	String wp_repeat_period="";
	String wp_repeat_by="";
	String wp_repeat_parameters="";
	
	System.out.println("wp_options="+wp_options);
	
	String[] arr=wp_options.split(":");
	try {
		wp_REC_SIZE_PER_TASK=arr[0];
		wp_master_limit=arr[1];
		wp_worker_limit=arr[2];
		wp_repeat_period=arr[3];
		wp_repeat_by=arr[4];
		try {wp_repeat_parameters=arr[5];} catch(Exception e) {}
	} catch(Exception e) {
		
		e.printStackTrace();
		
	}
	
	
	String sql="select wplan_type from tdm_work_plan where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",work_plan_id});
	
	ArrayList<String[]> typeArr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String wplan_type="";
	try{wplan_type=typeArr.get(0)[0];} catch(Exception e) {}
	
	
	int wp_worker_limit_INT=10;
	try{wp_worker_limit_INT=Integer.parseInt(wp_worker_limit);} catch(Exception e) {wp_worker_limit_INT=10;}
	
	System.out.println("wplan_type="+wplan_type);
	
	if (wplan_type.equals("MASK2")) {
		if (wp_worker_limit_INT>10) wp_worker_limit_INT=10;
		if (wp_worker_limit_INT<0)  wp_worker_limit_INT=0;
	}
	
	
	sql="update  tdm_work_plan "+
			" set email_address=?, execution_type=?, on_error_action=?, REC_SIZE_PER_TASK=?, "+
			" master_limit=?, worker_limit=?, repeat_period=?, repeat_by=?, repeat_parameters=?  " + 
			" where id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",wp_email_address});
	bindlist.add(new String[]{"STRING",wp_execution_type});
	bindlist.add(new String[]{"STRING",wp_on_error_action});
	bindlist.add(new String[]{"INTEGER",wp_REC_SIZE_PER_TASK});
	bindlist.add(new String[]{"INTEGER",wp_master_limit});
	bindlist.add(new String[]{"INTEGER",""+wp_worker_limit_INT});
	bindlist.add(new String[]{"STRING",wp_repeat_period});
	bindlist.add(new String[]{"INTEGER",wp_repeat_by});
	bindlist.add(new String[]{"STRING",wp_repeat_parameters});
	bindlist.add(new String[]{"INTEGER",work_plan_id});
	
	
	execDBConf(conn, sql, bindlist);
	
}


//--------------------------------------------------------------------------------
String makeWorkPlanWindow(Connection conn, HttpSession session, String work_plan_id) {
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select work_plan_name " + 
				" from tdm_work_plan " + 
				" where id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",work_plan_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==0) return "work plan not found : "  + work_plan_id;
	
	String work_plan_name=arr.get(0)[0];
	
	sb.append("<input type=hidden id=detailed_work_plan_id value="+work_plan_id+">");
	
	sb.append("<div id=workPlanGraphDataDiv>");
	sb.append(makeGraphData(conn,session,work_plan_id));
	sb.append("</div>");
	
	sb.append("<table class=\"table table-condensed\">");
	sb.append("<tr class=info>");
	
	
	sb.append("<td>");

	sb.append("<big><span class=\"label label-info\">["+work_plan_id+"] "+work_plan_name+"</span></big>");
	sb.append("</td>");
	
	sb.append("<td align=right>");
	
	sb.append("<table border=0 cellspacing=0 cellpadding=0>");
	sb.append("<tr>");
	sb.append("<td>");
	

	sb.append("</td>");
	
	sb.append("<td>");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=openWorkPlanWindow('"+work_plan_id+"')>");
	sb.append("<span class=\"glyphicon glyphicon-refresh\"></span>");
	sb.append("</button>");
	sb.append("</td>");
	
	sb.append("</tr>");
	sb.append("</table>");
	
	sb.append("<td>");
	sb.append("</tr>");
	
	
	sb.append("<tr>");
	sb.append("<td colspan=2>");
	
	sb.append(makeWorkPlanWindowDetail(conn,session,work_plan_id));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("</table>");
	
	
	return sb.toString();
}


//-------------------------------------------------------------------------
String makeWorkPlanWindowDetail(Connection conn, HttpSession session, String work_plan_id) {
	
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select "+
				" status, " +
				" wplan_type, " +
				" DATE_FORMAT(create_date,?) create_date, "+
				" DATE_FORMAT(start_date,?) start_date, "+
				" DATE_FORMAT(end_date,?) end_date, "+
				" app_id, "+
				" (select app_type from tdm_apps where id=app_id) app_type, " + 
				" env_id, "+
				" on_error_action, "+
				" execution_type, "+
				" length(prep_script_log) is_prep_script_log, " +
				" length(post_script_log) is_post_script_log, " +
				" master_limit, "+
				" worker_limit, " +
				" length(WARNING_MESSAGE) len_warning, " +
				" (select concat(fname, ' ', lname ) from tdm_user where id=created_by) created_by " + 
				" from tdm_work_plan " + 
				" where id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"INTEGER",work_plan_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String status=arr.get(0)[0];
	String wplan_type=arr.get(0)[1];
	String create_date=arr.get(0)[2];
	String start_date=arr.get(0)[3];
	String end_date=arr.get(0)[4];
	String app_id=arr.get(0)[5];
	String app_type=arr.get(0)[6];
	String env_id=arr.get(0)[7];
	String on_error_action=arr.get(0)[8];
	String execution_type=arr.get(0)[9];
	String is_prep_script_log=arr.get(0)[10];
	String is_post_script_log=arr.get(0)[11];
	String master_limit=arr.get(0)[12];
	String worker_limit=arr.get(0)[13];
	String len_warning=nvl(arr.get(0)[14],"0");
	String created_by=arr.get(0)[15];
	
	int prep_script_len=0;
	int post_script_len=0;
	
	try{prep_script_len=Integer.parseInt(is_prep_script_log);} catch(Exception e) {}
	try{post_script_len=Integer.parseInt(is_post_script_log);} catch(Exception e) {}
	
	String app_name=getDBSingleVal(conn,"select name from tdm_apps where id="+app_id);
	String env_name=getDBSingleVal(conn,"select name from tdm_envs where id="+env_id);

	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" id=workPlanDetailLeftDiv>");
	
	sb.append("<table class=\"table table-condensed\">");
	
	sb.append("<tr>");
	sb.append("<td align=center colspan=2>");
	sb.append(makeWorkPlanActionButtons(work_plan_id,wplan_type,app_type,status,2));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("<tr>");
	sb.append("<td align=right><b>Configure : </b></td>");
	sb.append("<td>");
	sb.append("<a href=\"javascript:editWorkPlan('"+work_plan_id+"');\"><span class=\"glyphicon glyphicon-cog\"></span></a> ");
	sb.append("</td>");
	sb.append("</tr>");


	sb.append("<tr>");
	sb.append("<td align=right><b>By : </b></td>");
	sb.append("<td>");
	sb.append("<span class=badge>"+created_by+"</span>");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b>Status : </b></td>");
	sb.append("<td>");
	sb.append("<span class=badge>"+status+"</span>");
	sb.append("</td>");
	sb.append("</tr>");
	
	if (!len_warning.equals("0")) {
		sb.append("<tr>");
		sb.append("<td align=right><b>Warnings : </b></td>");
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-warning\" onclick=\"showWarningMsg('"+work_plan_id+"')\">");
		sb.append("<span class=\"glyphicon glyphicon-info-sign\"></span>");
		sb.append("</button>");
		sb.append("</td>");
		sb.append("</tr>");
	}
	
	if (status.equals("INVALID")) {
		sb.append("<tr>");
		sb.append("<td align=right><b>Problems : </b></td>");
		sb.append("<td>");
		sb.append(" <button type=button class=\"btn btn-sm btn-danger\" onclick=\"showInvalidMsg('"+work_plan_id+"')\">");
		sb.append("<span class=\"glyphicon glyphicon-ban-circle\"></span>");
		sb.append("</button>");
		
		sql="select count(*) from tdm_work_package where work_plan_id="+work_plan_id;
		String wpc_count=getDBSingleVal(conn, sql);
		//if masking validation is not passed
		if (!wpc_count.equals("0")) {
			sb.append(" <button type=button class=\"btn btn-success btn-sm\" onclick=\"skipValidation('"+work_plan_id+"','window');\">");
			sb.append(" <span class=\"glyphicon glyphicon-ok\">Skip</span>");
			sb.append("</button>");
		}
		
		sb.append("</td>");
		sb.append("</tr>");
		
		
		
		
		
		
	}
	
	
	
	
	if (wplan_type.equals("DISC") || wplan_type.equals("MASK") || wplan_type.equals("MASK2") || wplan_type.equals("COPY")) {
		sb.append("<tr>");
		sb.append("<td align=right><b>Application : </b></td>");
		sb.append("<td>");
		sb.append("<span class=badge>"+nvl(app_name,"-")+"</span>");
		sb.append("</td>");
		sb.append("</tr>");
		sb.append("<tr>");
		
		sb.append("<td align=right><b>Environment : </b></td>");
		sb.append("<td>");
		sb.append("<span class=badge>"+nvl(env_name,"-")+"</span>");
		sb.append("</td>");
		sb.append("</tr>");
		
		if (wplan_type.equals("MASK") || wplan_type.equals("MASK2")) {
			
			String current_filter="";
			
			String filter_combo="";
			sql=	" select 'ALL','All' from dual "+
					"union all " +
					"select id, concat(tab_name,'@',schema_name) tab " +
					" from tdm_tabs  " +
					" where app_id=(select app_id from tdm_work_plan where id="+work_plan_id+") " +
					" order by 2";
			filter_combo=makeCombo(conn, sql, "work_plan_filter", " size=1 onchange=changeWorkPlanTableFilter(this.value);", current_filter, 220);	

			
			sb.append("<td align=right><b>Filter : </b></td>");
			sb.append("<td>");
			sb.append(filter_combo);
			sb.append("</td>");
			sb.append("</tr>");
		}
	}
	
	
	if (start_date.length()>0) {
		sb.append("<tr>");
		sb.append("<td align=right><b>Started@ : </b></td>");
		sb.append("<td nowrap>");
		sb.append("["+start_date+"]");
		if (prep_script_len>0)
			sb.append(" <span class=\"glyphicon glyphicon-list-alt\" onclick=showWorkPlanScriptLog('"+work_plan_id+"','prep');></span>");
		sb.append("</td>");
		sb.append("</tr>");
	}
	
	if (end_date.length()>0) {
		sb.append("<tr>");
		sb.append("<td align=right><b>Finished@ : </b></td>");
		sb.append("<td nowrap>");
		sb.append("["+end_date+"]");
		if (post_script_len>0)
			sb.append(" <span class=\"glyphicon glyphicon-list-alt\" onclick=showWorkPlanScriptLog('"+work_plan_id+"','post');></span>");
		sb.append("</td>");
		sb.append("</tr>");
	}
	
	sb.append("<tr>");
	sb.append("<td colspan=2>");
	sb.append("<div id=workPackageStatusDiv>");
	sb.append(makeWorkPackageStatusTable(conn,session,work_plan_id));
	sb.append("</div>");
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("</table>");
	
	sb.append("</div>");  // div col-md-4
	
	
	sb.append("<div class=\"col-md-8\" id=workPlanDetailMainDiv>");
	
	
	
	sb.append("<table class=table>");
	
	sb.append("<tr class=active>");
	sb.append("<td colspan=2 align=right>");
	sb.append(makeProcessSummary(conn, session));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td colspan=2>");
	sb.append(makeTaskSummaryTable(conn,session, work_plan_id));
	sb.append("</td>");
	sb.append("</tr>");


	sb.append("<tr>");
	sb.append("<td>");
	sb.append("<div id=taskGraphDiv style=\"height:250px; \"></div>");
	sb.append("</td>");
	sb.append("<td>");
	sb.append("<div id=speedGraphDiv style=\"height:250px; \"></div>");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("</table>");

	sb.append("</div>");  // div col-md-8
	
	sb.append("</div>");
	
	
	return sb.toString();
}

//-------------------------------------------------------------------------------------------
String makeWorkPackageStatusTable(Connection conn, HttpSession session, String work_plan_id) {
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select status, count(*) wpc_count, sum(export_count) export_count " + 
				" from tdm_work_package where work_plan_id=? group by status  order by 1";
	
	bindlist.add(new String[]{"INTEGER",work_plan_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	if (arr==null || arr.size()==0) return "No work package found";
	
	
	sb.append("<table class=\"table table-condensed\">");
	
	sb.append("<tr class=active>");
	sb.append("<td><small><b>WPC Status</b></small></td>");
	sb.append("<td><small><b>Count</b></small></td>");
	sb.append("<td align=right><small><b>Export#</b></small></td>");
	sb.append("</tr>");
	
	int sum_wpc_count=0;
	long sum_rec_count=0;
	
	for (int i=0;i<arr.size();i++) {
		String wpc_status=arr.get(i)[0];
		String wpc_count=nvl(arr.get(i)[1],"0");
		String wpc_export_count=nvl(arr.get(i)[2],"0");
		
		try {sum_wpc_count+=Integer.parseInt(wpc_count);} catch(Exception e) {e.printStackTrace();}
		try {sum_rec_count+=Long.parseLong(wpc_export_count);} catch(Exception e) {e.printStackTrace();}
		
		sb.append("<tr>");
		sb.append("<td><small>");
		sb.append("<a href=\"javascript:showWorkPackageList('"+work_plan_id+"','"+wpc_status+"');\">" + wpc_status+"</a>");
		sb.append("</small></td>");
		sb.append("<td><small>"+wpc_count+"</small></td>");
		sb.append("<td align=right><small>"+formatnum(wpc_export_count)+"</small></td>");
		sb.append("</tr>");
	}
	
	
	sb.append("<tr class=active>");
	sb.append("<td><small>");
	sb.append("<a href=\"javascript:showWorkPackageList('"+work_plan_id+"','ALL');\"><b>ALL</b></a>");
	sb.append("</small></td>");
	sb.append("<td><small><b>"+sum_wpc_count+"</b></small></td>");
	sb.append("<td align=right><small><b>"+formatnum(""+sum_rec_count)+"</b></small></td>");
	sb.append("</tr>");
	
	sb.append("</table>");
	
	return sb.toString();
}

//-------------------------------------------------------------------------------------------
void setWorkPlanSummary(Connection conn, HttpSession session, String work_plan_id) {
String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	long all_task_count=0;
	long all_rec_count=0;
	long all_new_count=0;
	long all_assigned_count=0;
	long all_running_count=0;
	long all_finished_count=0;
	long all_retry_count=0;
	long all_failed_count=0;
	
	
	
	ArrayList<String[]> wpcArr=getWpcListByWorkPlan(conn, work_plan_id, "");
	for (int i=0;i<wpcArr.size();i++) {
		String work_package_id=wpcArr.get(i)[0];
		String work_package_status=wpcArr.get(i)[1];
		
		if (work_package_status.equals("NEW")) continue;
		
		sql="select status, "+
				" count(*) task_count, "+
				" sum(all_count) all_count, "+
				" sum(success_count) success_count, "+
				" sum(fail_count) fail_count "+
				" from tdm_task_"+work_plan_id+"_"+work_package_id  + 
				" group by status";
		
		ArrayList<String[]> taskArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		String task_status="";
		int task_count=0;
		int all_count=0;
		int success_count=0;
		int fail_count=0;
		
		for (int t=0;t<taskArr.size();t++) {
			
		
			task_status=taskArr.get(t)[0];
			try{task_count=Integer.parseInt(taskArr.get(t)[1]);} catch(Exception e) {task_count=0;} 
			try{all_count=Integer.parseInt(taskArr.get(t)[2]);} catch(Exception e) {all_count=0;} 
			try{success_count=Integer.parseInt(taskArr.get(t)[3]);} catch(Exception e) {success_count=0;} 
			try{fail_count=Integer.parseInt(taskArr.get(t)[4]);} catch(Exception e) {fail_count=0;} 
			
			all_task_count+=task_count;
			all_rec_count+=all_count;
			if (task_status.equals("NEW")) all_new_count+=all_count;
			if (task_status.equals("ASSIGNED")) all_assigned_count+=all_count;
			if (task_status.equals("RUNNING")) all_running_count+=all_count;
			if (task_status.equals("FINISHED")) all_finished_count+=success_count;
			if (task_status.equals("RETRY")) all_retry_count+=all_count;
			
			if (fail_count>0) all_failed_count+=fail_count;
			
			
			
		}
	}
	
	
	sql="select  abs(TIMESTAMPDIFF(SECOND,  start_date, IFNULL(end_date,now()))) time_diff_as_hour from tdm_work_plan where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",""+work_plan_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	int masked_recs_in_k=0;
	int exported_recs_in_k=0;
	

	
	if (arr.size()==1) {
		int time_diff_as_second=0;
		
		try{time_diff_as_second=Integer.parseInt(arr.get(0)[0]);} catch(Exception e) {}
		long exported_count_as_k=all_rec_count/1000;
		long finished_count_as_k=all_finished_count/1000;

		
		if (time_diff_as_second>0) {
			exported_recs_in_k=Math.round(60*exported_count_as_k/time_diff_as_second);
			masked_recs_in_k=Math.round(60*finished_count_as_k/time_diff_as_second);
		}
			
		
			

	}
			
	session.setAttribute("all_task_count", ""+all_task_count);
	session.setAttribute("all_rec_count", ""+all_rec_count);
	session.setAttribute("new_count", ""+all_new_count);
	session.setAttribute("assigned_count", ""+all_assigned_count);
	session.setAttribute("running_count", ""+all_running_count);
	session.setAttribute("finished_count", ""+all_finished_count);
	session.setAttribute("retry_count", ""+all_retry_count);
	session.setAttribute("failed_count", ""+all_failed_count);
	
	
	session.setAttribute("curr_exported_recs_in_k", ""+exported_recs_in_k);
	session.setAttribute("curr_masked_recs_in_k", ""+masked_recs_in_k);
	
	session.setAttribute("task_all_count", ""+all_rec_count);
	session.setAttribute("task_new_count", ""+all_new_count);
	session.setAttribute("task_assigned_count", ""+all_assigned_count);
	session.setAttribute("task_running_count", ""+all_running_count);
	session.setAttribute("task_completed_count", ""+all_finished_count);
	session.setAttribute("task_retry_count", ""+all_retry_count);
	session.setAttribute("task_failed_count", ""+all_failed_count);
	
	
}

//--------------------------------------
String makeTaskSummaryTable(Connection conn, HttpSession session, String work_plan_id) {
	StringBuilder sb=new StringBuilder();
	
	
	
	
	String sql="";
	
	
	
	long all_task_count=0;
	long all_rec_count=0;
	long new_count=0;
	long assigned_count=0;
	long running_count=0;
	long finished_count=0;
	long retry_count=0;
	long failed_count=0;
	
	int export_speed=0;
	int mask_speed=0;
	
	setWorkPlanSummary(conn, session, work_plan_id);
	
	try{all_task_count=Long.parseLong((String) session.getAttribute("all_task_count"));} catch(Exception e) {all_task_count=0;}
	try{all_rec_count=Long.parseLong((String) session.getAttribute("all_rec_count"));} catch(Exception e) {all_rec_count=0;}
	try{new_count=Long.parseLong((String) session.getAttribute("new_count"));} catch(Exception e) {new_count=0;}
	try{assigned_count=Long.parseLong((String) session.getAttribute("assigned_count"));} catch(Exception e) {assigned_count=0;}
	try{running_count=Long.parseLong((String) session.getAttribute("running_count"));} catch(Exception e) {running_count=0;}
	try{finished_count=Long.parseLong((String) session.getAttribute("finished_count"));} catch(Exception e) {finished_count=0;}
	try{retry_count=Long.parseLong((String) session.getAttribute("retry_count"));} catch(Exception e) {retry_count=0;}
	try{failed_count=Long.parseLong((String) session.getAttribute("failed_count"));} catch(Exception e) {failed_count=0;}
	
	try{export_speed=Integer.parseInt((String) session.getAttribute("curr_exported_recs_in_k"));} catch(Exception e) {export_speed=0;}
	try{mask_speed=Integer.parseInt((String) session.getAttribute("curr_masked_recs_in_k"));} catch(Exception e) {mask_speed=0;}


	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr>");
	sb.append("<td class=primary align=left><b>Task Count</b></td>");
	sb.append("<td class=primary align=left><b>All</b></td>");
	sb.append("<td class=primary align=left><b>New</b></td>");
	sb.append("<td class=primary align=left><b>Assigned</b></td>");
	sb.append("<td class=primary align=left><b>Running</b></td>");
	sb.append("<td class=primary align=left><b>Finished</b></td>");
	sb.append("<td class=primary align=left><b>Retry</b></td>");
	sb.append("<td class=primary align=left><b>Failed</b></td>");
	sb.append("<td class=primary align=left><b>Export/Mask Speed</b></td>");
	sb.append("</tr>");

	
	sb.append("<tr>");
	sb.append("<td align=right>["+formatnum(""+all_task_count)+"]</td>");
	sb.append("<td align=right>["+formatnum(""+all_rec_count)+"]</td>");
	sb.append("<td align=right>["+formatnum(""+new_count)+"]</td>");
	sb.append("<td align=right>["+formatnum(""+assigned_count)+"]</td>");
	sb.append("<td align=right>["+formatnum(""+running_count)+"]</td>");
	sb.append("<td align=right>["+formatnum(""+finished_count)+"]</td>");
	
	if (retry_count==0) 
		sb.append("<td align=right>-</td>");
	else
		sb.append("<td align=right>["+formatnum(""+retry_count)+"]</td>");
	
	sb.append("<td align=right nowrap>");
	
	
	if (failed_count==0) 
		sb.append("-");
	else {
		
		
		sb.append("<a href=\"javascript:showFailedTaskList()\">");
		sb.append("["+formatnum(""+failed_count)+"]");
		sb.append("</a>");
		
		sb.append("<button type=button class=\"btn btn-warning btn-sm\" onclick=setWorkPlanStatus2('"+work_plan_id+"','REPEAT:ALL')>");
		sb.append("<span class=\"glyphicon glyphicon-repeat\">");
		sb.append("</button>");
	}
	sb.append("</td>");
	
	sb.append("<td align=right>[<b>"+formatnum(""+export_speed)+"</b>]/[<b>"+formatnum(""+mask_speed)+"</b>] <small>K rec/min</small></td>");
	sb.append("</tr>");
	
	
	sb.append("</table>");
	
	return sb.toString();
}


//------------------------------------
String makeGraphData(Connection conn, HttpSession session, String work_plan_id) {
	StringBuilder sb=new StringBuilder();
	
	long curr_exported_recs_in_k=0;
	long curr_masked_recs_in_k=0;

	long task_all_count=0;
	long task_new_count=0;
	long task_assigned_count=0;
	long task_running_count=0;
	long task_completed_count=0;
	long task_failed_count=0;
	long task_retry_count=0;
	
	curr_exported_recs_in_k=Long.parseLong(nvl((String) session.getAttribute("curr_exported_recs_in_k"),"0"));
	curr_masked_recs_in_k=Long.parseLong(nvl((String) session.getAttribute("curr_masked_recs_in_k"),"0"));
	
	task_all_count=Long.parseLong(nvl((String) session.getAttribute("task_all_count"),"0"));
	task_new_count=Long.parseLong(nvl((String) session.getAttribute("task_new_count"),"0"));
	task_assigned_count=Long.parseLong(nvl((String) session.getAttribute("task_assigned_count"),"0"));
	task_running_count=Long.parseLong(nvl((String) session.getAttribute("task_running_count"),"0"));
	task_completed_count=Long.parseLong(nvl((String) session.getAttribute("task_completed_count"),"0"));
	task_failed_count=Long.parseLong(nvl((String) session.getAttribute("task_failed_count"),"0"));
	task_retry_count=Long.parseLong(nvl((String) session.getAttribute("task_retry_count"),"0"));
	
	
	sb.append("<input type=hidden id=curr_masked_recs_in_k value="+curr_masked_recs_in_k+">");
	sb.append("<input type=hidden id=curr_exported_recs_in_k value="+curr_exported_recs_in_k+">");
	
	
	sb.append("<input type=hidden id=task_all_count value="+task_all_count+">");
	sb.append("<input type=hidden id=task_new_count value="+task_new_count+">");
	sb.append("<input type=hidden id=task_assigned_count value="+task_assigned_count+">");
	sb.append("<input type=hidden id=task_running_count value="+task_running_count+">");
	sb.append("<input type=hidden id=task_completed_count value="+task_completed_count+">");
	sb.append("<input type=hidden id=task_failed_count value="+task_failed_count+">");
	sb.append("<input type=hidden id=task_retry_count value="+task_retry_count+">");
	        		
	return sb.toString();
}


//------------------------------------
String getWorkPackageListByStatus(Connection conn, HttpSession session, String work_plan_id, String status) {
	
	StringBuilder sb=new StringBuilder();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select id, wp_name, status,  DATE_FORMAT(start_date,?) start_date, DATE_FORMAT(end_date,?) end_date, " + 
				" round(duration/1000/60) duration_as_min, export_count,  success_count, fail_count, master_id, execution_order " + 
				" from tdm_work_package "+
				" where work_plan_id=? ";
	if (!status.equals("ALL"))
		sql=sql + " and status=? ";
	
	sql=sql + " order by wp_name ";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"INTEGER",work_plan_id});
	if (!status.equals("ALL"))
		bindlist.add(new String[]{"STRING",status});

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	if (arr==null || arr.size()==0) return "No work package found";
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=showWorkPackageList('"+work_plan_id+"','"+status+"')>");
	sb.append("<span class=\"glyphicon glyphicon-refresh\"></span>");
	sb.append("</button>");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<table class=\"table table-condensed\">");
	
	sb.append("<tr class=active>");
	sb.append("<td><b>#</b></td>");
	sb.append("<td><b>Name</b></td>");
	sb.append("<td><b>Exec#</b></td>");
	sb.append("<td><b>Status</b></td>");
	sb.append("<td><b>Start & Finish</b></td>");
	sb.append("<td><b>Master#</b></td>");
	sb.append("<td><b>Duration (min)</b></td>");
	sb.append("<td><b>Exported#</b></td>");
	sb.append("<td><b>Success#</b></td>");
	sb.append("<td><b>Failed#</b></td>");
	sb.append("</tr>");
	
	for (int i=0;i<arr.size();i++) {
		
		String wpc_id=arr.get(i)[0];
		String wpc_name=arr.get(i)[1];
		String wpc_status=arr.get(i)[2];
		String start_date=arr.get(i)[3];
		String end_date=arr.get(i)[4];
		String duration_as_min=arr.get(i)[5];
		String export_count=arr.get(i)[6];
		String success_count=arr.get(i)[7];
		String fail_count=arr.get(i)[8];
		String master_id=nvl(arr.get(i)[9],"-");
		String execution_order=arr.get(i)[10];

		String progress=progressbar(success_count, export_count);

		
		
		sb.append("<tr class=active>");
		sb.append("<td>"+wpc_id+"</td>");
		sb.append("<td>"+wpc_name+"</td>");
		sb.append("<td align=right>"+execution_order+"</td>");
		
		if (wpc_status.equals("FAILED")) {
			
			sb.append("<td>"+wpc_status+" "+
			"<button type=button class=\"btn btn-sm btn-danger\" onclick=\"showInfoDetail('"+wpc_id+"','tdm_work_package','err_info');\">Error</button>"+
			"</td>"
			);
		}
		else 
			sb.append("<td>"+wpc_status+"<br>"+progress+"</td>");
		sb.append("<td>["+start_date+"] / ["+end_date+"]</td>");

		boolean master_is_invalid=false;
		
		if (!nvl(master_id,"-").equals("-")) {
			sql="select 1 from tdm_master where id=? and last_heartbeat>DATE_SUB(now(),INTERVAL 5 MINUTE)";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",master_id});
			
			ArrayList<String[]> chArr=getDbArrayConf(conn, sql, 1, bindlist);
			if (chArr==null || chArr.size()==0) master_is_invalid=true;
		}
		
		if (!wpc_status.equals("FINISHED") && nvl(master_id,"-").equals("-")) {
			sb.append("<td>");
			sb.append("<button type=button class=\"btn btn-sm btn-info\" onclick=assignWorkPackage('"+wpc_id+"');>");
			sb.append("<span class=\"glyphicon glyphicon-log-in\"> Assign</span>");
			sb.append("</button>");
			sb.append("</td>");
		}
		else if (!wpc_status.equals("FINISHED") && master_is_invalid) {
			sb.append("<td>");
			sb.append("<button type=button class=\"btn btn-sm btn-warning\" onclick=assignWorkPackage('"+wpc_id+"');>");
			sb.append("<span class=\"glyphicon glyphicon-log-in\"> re-Assign</span>");
			sb.append("</button>");
			sb.append("</td>");
		}
		else 
			sb.append("<td>["+master_id+"]</td>");
		
		sb.append("<td align=right>"+formatnum(duration_as_min)+"</td>");
		sb.append("<td align=right>"+formatnum(export_count)+"</td>");
		sb.append("<td align=right>"+formatnum(success_count)+"</td>");
		sb.append("<td align=right>"+formatnum(fail_count)+"</td>");
		sb.append("</tr>");
	}
	
	        		
	return sb.toString();
}

//-------------------------------------------------------------------
String makeWorkPlanActionButtons(
		String work_plan_id,
		String work_plan_type,
		String app_type,
		String status,
		int type
		) {
	StringBuilder sb=new StringBuilder();
	
			
	if ("RUNNING,NEW,ASSIGNED,PREPARATION,BUILDING".indexOf(status)>-1)
		sb.append( 
					" <button type=\"button\" class=\"btn btn-danger btn-sm\" onclick=setWorkPlanStatus"+type+"('"+work_plan_id+"','CANCEL')  data-toggle=\"tooltip\" data-placement=\"left\" title=\"Stop\">"+
						"<span class=\"glyphicon glyphicon-stop\"></span>"+
					" </button>");
	
	if ("RUNNING".indexOf(status)>-1)
		sb.append( 
				" <button type=\"button\" class=\"btn btn-warning btn-sm\"  onclick=setWorkPlanStatus"+type+"('"+work_plan_id+"','PAUSE') data-toggle=\"tooltip\" data-placement=\"left\" title=\"Pause\">"+
					"<span class=\"glyphicon glyphicon-pause\" alt=\"Pause\"></span>"+
				" </button>");
	
	if ("PAUSED".indexOf(status)>-1)
		sb.append( 
				" <button type=\"button\" class=\"btn btn-warning btn-sm\"  onclick=setWorkPlanStatus"+type+"('"+work_plan_id+"','RESUME') data-toggle=\"tooltip\" data-placement=\"left\" title=\"Resume\">"+
					"<span class=\"glyphicon glyphicon-play\" alt=\"Resume\"></span>"+
				" </button>");
	if ("CANCELLED,INVALID,FINISHED,FAILED".indexOf(status)>-1 || status.contains("EXECUTING")) {
		sb.append(  
				" <button type=\"button\" class=\"btn btn-warning btn-sm\" onclick=setWorkPlanStatus"+type+"('"+work_plan_id+"','REPLAY') data-toggle=\"tooltip\" data-placement=\"left\" title=\"Replay\">"+
					"<span class=\"glyphicon glyphicon-repeat\" alt=\"Replay\"></span>"+
				" </button>");

		if (work_plan_type.equals("MASK") || work_plan_type.equals("MASK2") || work_plan_type.equals("COPY"))	
			sb.append( 
					" <button type=\"button\" class=\"btn btn-info btn-sm\" onclick=setWorkPlanStatus"+type+"('"+work_plan_id+"','ROLLBACK') data-toggle=\"tooltip\" data-placement=\"left\" title=\"Rollback\">"+
						"<span class=\"glyphicon glyphicon-fast-backward\" alt=\"Rollback\"></span>"+
					" </button>") ;
		sb.append( 		
				" <button type=\"button\" class=\"btn btn-danger btn-sm\"  onclick=setWorkPlanStatus"+type+"('"+work_plan_id+"','PURGE') data-toggle=\"tooltip\" data-placement=\"left\" title=\"Purge\">"+
					"<span class=\"glyphicon glyphicon-trash\" alt=\"Purge\"></span>"+
				" </button>");
	
	}
			
	if (work_plan_type.equals("DISC")) 	{
		if (app_type.equals("COPY"))
			sb.append( 
			" <button type=\"button\" class=\"btn btn-active btn-sm\"  onclick=showCopyingDiscoveryReport('"+work_plan_id+"') data-toggle=\"tooltip\" data-placement=\"left\" title=\"Discovery Report\">"+
				"<span class=\"glyphicon glyphicon-eye-open\" alt=\"Discovery Report\"></span>"+
			" </button>");
	}
	
		
	return sb.toString();
	
}

//----------------------------------------------------------------
String makeWorkPackageAssignmentList(Connection conn, HttpSession session, String work_package_id) {
	StringBuilder sb=new StringBuilder();
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from tdm_work_package where id=? and master_id in (select 1 from tdm_master where last_heartbeat>DATE_SUB(now(),INTERVAL 5 MINUTE) ) ";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",work_package_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	if (arr!=null && arr.size()==1) 
		return "Workpackage is already assigned.";
				
	sql="select " + 
		"	id, hostname, DATE_FORMAT(start_date,?) start_date " + 
		"	from tdm_master  " + 
		"	where status='FREE'  " + 
		"	and last_heartbeat>DATE_SUB(now(),INTERVAL 5 MINUTE) " + 
		"	order by last_heartbeat";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	ArrayList<String[]> masterList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	if (masterList==null || masterList.size()==0) 
		return "No available master for assignment.";
				
	
	
	sb.append("<table class=\"table table-condensed table-striped\">");
				
	sb.append("<tr>");
	sb.append("<td><b>#</b></td>");
	sb.append("<td><b>Host</b></td>");
	sb.append("<td><b>Start@</b></td>");
	sb.append("<td>-</td>");
	sb.append("</tr>");
	
	for (int i=0;i<masterList.size();i++) {
		String master_id=masterList.get(i)[0];
		String hostname=masterList.get(i)[1];
		String start_date=masterList.get(i)[2];
		
		sb.append("<tr>");
		
		sb.append("<td>"+master_id+"</td>");
		sb.append("<td>"+hostname+"</td>");
		sb.append("<td>"+start_date+"</td>");
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-info\" onclick=\"assignWorkPackageDO('"+work_package_id+"','"+master_id+"');\">");
		sb.append("<span class=\"glyphicon glyphicon-log-in\"> Assign</span>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("</tr>");
	}
		
	sb.append("</table>");
	return sb.toString();
}

//---------------------------------------------------------------------
boolean assignWorkPackage(Connection conn, HttpSession session, String work_package_id, String master_id) {
	StringBuilder sb=new StringBuilder();
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from tdm_master where id=? and status='FREE'";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",master_id});
	ArrayList<String[]> masterList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	if (masterList==null || masterList.size()==0) 
		return false;
	
	sql="update tdm_work_package set master_id=? where id=?";	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",master_id});
	bindlist.add(new String[]{"INTEGER",work_package_id});

	boolean is_ok=execDBConf(conn, sql, bindlist);
	if (!is_ok) return false;
	

	
	sql="update tdm_master set status=? where id=?";	
	bindlist.clear();
	bindlist.add(new String[]{"STRING","ASSIGNED"});
	bindlist.add(new String[]{"INTEGER",master_id});
	
	is_ok=execDBConf(conn, sql, bindlist);

	
	if (!is_ok) return false;
	
	return true;
}



//----------------------------------------------------------------------------------------------------------------
String  testMongoDBConnection(String url) {
	MongoClient mongo =getMongoClient(url);
	return connection_error;
}

String connection_error="";

//----------------------------------------------------------------------------------------------------------------
MongoClient getMongoClient(String url) {
	System.out.println("Getting mongo client for ["+url+"]...");
	connection_error="";
	MongoClient mongoClient = null;
	
	try {
		MongoClientURI muri=new MongoClientURI(url);
		mongoClient = new MongoClient(muri);
	} catch(Exception e) {
		connection_error=e.getMessage();
		e.printStackTrace();
		return null;
	}
	
	return mongoClient;
}


//--------------------------------------------------------------------------
ArrayList<String[]> getMongoDbList(Connection conn, String env_id) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	String url="";
	String sql="select db_connstr from tdm_envs where id="+env_id;
	url=getDBSingleVal(conn, sql);
	
	MongoClient mongo=getMongoClient(url);
	
	try {
		
		for (String dbname : mongo.listDatabaseNames()) {
			ret1.add(new String[]{dbname});
		}
	} catch(Exception e) {
		e.printStackTrace();
	}
	
	
	return ret1;
}

//--------------------------------------------------------------------------
boolean testMongoClient(Connection conn, String env_id) {
	String url="";
	String sql="select db_connstr from tdm_envs where id="+env_id;
	url=getDBSingleVal(conn, sql);
	MongoClient mongo=getMongoClient(url);
	if (mongo==null) return false;
	return true;
}
//--------------------------------------------------------------------------
ArrayList<String> getMongoCollectionList(Connection conn, String env_id, String owner_filter) {
	ArrayList<String> ret1=new ArrayList<String>();
	
	System.out.println("Mongo db filter : "+owner_filter);
	
	String filter_db=owner_filter;
	try {filter_db=owner_filter.split("\\.")[1]; }  catch(Exception e) {}
	
	String url="";
	String sql="select db_connstr from tdm_envs where id="+env_id;
	url=getDBSingleVal(conn, sql);
	
	MongoClient mongo=getMongoClient(url);
	
	
	try {
		
		for (String dbname : mongo.listDatabaseNames()) {
			if (!dbname.equals(filter_db) && !filter_db.equals("All") ) continue;
			ret1.addAll(getCollectionListByDB(mongo,dbname));
			
		}
	} catch(Exception e) {
		e.printStackTrace();
	}
	
	
	return ret1;
}

//--------------------------------------------------------
ArrayList<String> getCollectionListByDB(MongoClient mongo, String db_name) {
	ArrayList<String> ret1=new ArrayList<String>();
	
	
	
	
	MongoDatabase mongodb=mongo.getDatabase(db_name);
	
	try {
		System.out.println("Mongo Db name : "+db_name);
		
		for (String collection : mongodb.listCollectionNames()) {
			
		
			ret1.add(db_name+"*"+db_name+"*"+collection);
		}
	} catch(Exception e) {
		e.printStackTrace();
	}
	
	
	return ret1;
}

//************************************************
String Json2Html(ArrayList<String[]> maskedFields, String json, String parent) {
	StringBuilder sb=new StringBuilder();
	DBObject dbObject = (DBObject) JSON.parse(json);
	
	Map map=dbObject.toMap();
	
	
	
	if (map.size()>0) 
		sb.append("<ul>");
	
	for (Object obj:  map.keySet()) {
		String key=obj.toString();
		String val=map.get(key).toString();
		
		String full_key=key;
		if (parent.length()>0) full_key=parent+"."+key;
		
		boolean is_masked=false;
		
		if (maskedFields!=null) {
			for (int m=0;m<maskedFields.size();m++) {
				String masked_field_pattern=maskedFields.get(m)[0];
				Pattern r = Pattern.compile("^"+masked_field_pattern+"$");
				Matcher match = r.matcher(full_key);
				if (match.find()) {
					is_masked=true;
					break;
				}
				
			}
		}
		
		char first_char='x';
		try{first_char=val.trim().charAt(0);} catch(Exception e) {}
		
		
		sb.append("<li>");
		if (is_masked)
			sb.append("<b><small><span style=\"background-color:yellow;\">"+key+"</span></small></b> : ");
		else 
			sb.append("<b><small>"+key+"</small></b> : ");
		
		if (first_char!='{' && first_char!='[') {
			if (is_masked)
				sb.append("<small><b>[</b><span style=\"background-color:yellow;\">");
			else 
				sb.append("<small><b>[</b>");
			
			if (val.length()>200)
				sb.append(val.substring(0,200)+"...");
			else 
				sb.append(val);
			sb.append("</span><b>]</b></small>");
		}
			
		sb.append("</li>");
		
		
			
		
		if (first_char=='{' || first_char=='[')  {
			sb.append(Json2Html(maskedFields,val, full_key));
		}
		
		
	}
	
	
	if (map.size()>0) 
		sb.append("</ul>");
	return sb.toString();
}
//************************************************
void decodeMongoQuery(String query, StringBuilder sbcoll,StringBuilder sbfilter)		 {
	String query_cleared=query.toUpperCase();
	
	int first_par_pos=query_cleared.indexOf('(');
	int last_par_pos=query_cleared.indexOf(')');
	
	if (first_par_pos==-1 && last_par_pos==-1) {
		sbcoll.append(query);
		return;
	}
	
	
	if (first_par_pos>-1 && last_par_pos>-1 && last_par_pos>first_par_pos)
		sbfilter.append(query.substring(first_par_pos+1,last_par_pos));
	
	if (first_par_pos>-1 && last_par_pos>-1) {
		int pos_db=query.indexOf("db");
		int dot_after_db=query.indexOf('.', pos_db);
		
		
		
		int pos_dot_before_find=query.substring(0,last_par_pos).lastIndexOf(".");
		
		
		if (pos_dot_before_find>-1) 
			try{sbcoll.append(query.substring(dot_after_db+1,pos_dot_before_find));} catch(Exception e) {e.printStackTrace();}
		
		
	}
}
		
//************************************************
String getMongoCollectionContent(Connection conn, String env_id, String query, int limit, String mongo_db) {
	StringBuilder sb=new StringBuilder();
	
	
	StringBuilder sbcoll=new StringBuilder();
	StringBuilder sbfilter=new StringBuilder();
	
	decodeMongoQuery(query, sbcoll,sbfilter);
	
	
	
	String collection=sbcoll.toString();
	String mongo_query=sbfilter.toString();
	
	
	
	String url="";
	String sql="select db_connstr from tdm_envs where id="+env_id;
	url=getDBSingleVal(conn, sql);
	
	MongoClient mongo=getMongoClient(url);
	
	if (mongo==null) return "Database connection not valid : " + url;
	
	MongoDatabase mongodb=mongo.getDatabase(mongo_db);
	
	if (mongo==null) return "Database  not valid : "+mongo_db;
	
	FindIterable<Document> iterable = null;
	
	
	if (nvl(mongo_query,"").length()>0) {
		
		System.out.println("mongo_query="+mongo_query);
		
		BasicDBObject queryFilter = null;
		try {
			queryFilter = (BasicDBObject) JSON.parse(mongo_query);
		} catch(Exception e) {
			try {mongo.close();}  catch(Exception e1) {}
			
			return "Query is not valid ["+mongo_query+"]";
		}
		
		iterable=mongodb.getCollection(collection).find(queryFilter).limit(limit);
		
	}
		
	else 
		iterable=mongodb.getCollection(collection).find();
	
	
	ArrayList<Document> docs=new ArrayList<Document>();
	int cntx=0;
	
	try {
		
		
		for (Document doc:iterable) {
			docs.add(doc);
			cntx++;
			if (limit>0 && cntx==limit) break;
		}
	} catch(Exception e) {
		try {mongo.close();}  catch(Exception e1) {}
		
		
		sb.append("<table class=\"table table-condensed table-striped\">");
		
		sb.append("<tr>");
		sb.append("<td>collection : "+collection+"</td>");
		sb.append("</tr>");
		
		sb.append("<tr>");
		sb.append("<td>query : "+mongo_query+"</td>");
		sb.append("</tr>");
		
		
		sb.append("<tr>");
		sb.append("<td>Exception : "+e.getMessage()+"</td>");
		sb.append("</tr>");
		sb.append("</table>");
		return sb.toString();
		
	}
	
	
	
	
	
	if (cntx==0) {
		sb.append("<table class=\"table table-condensed table-striped\">");
		
		sb.append("<tr>");
		sb.append("<td>collection : "+collection+"</td>");
		sb.append("</tr>");
		
		sb.append("<tr>");
		sb.append("<td>query : "+mongo_query+"</td>");
		sb.append("</tr>");
		
		sb.append("<tr>");
		sb.append("<td>No document found</td>");
		sb.append("</tr>");
		sb.append("</table>");
		return sb.toString();
	}
	
	sb.append("<table class=\"table table-condensed table-striped\">");
	
	sb.append("<tr>");
	sb.append("<td>collection : "+collection+"</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td>query : "+mongo_query+"</td>");
	sb.append("</tr>");
	
	for (int i=0;i<docs.size();i++) {
		Document adoc=docs.get(i);
		
		sb.append("<tr>");
		sb.append("<td>");
		sb.append(""+(i+1));
		sb.append("</td>");
		sb.append("<td>");
		sb.append(Json2Html(null, adoc.toJson(),""));
		sb.append("</td>");
		sb.append("</tr>");
		
	}
	
	
	
	
	return sb.toString();
}

//--------------------------------------------------------------------------------------------
ArrayList<Document> getDocuments(MongoClient mongo, String dbname, String collection, String filter, int limit) {
	
	ArrayList<Document> ret1=new ArrayList<Document>();

	MongoDatabase mongodb=mongo.getDatabase(dbname);
	
	
	
	FindIterable<Document> iterable = mongodb.getCollection(collection).find();
	
	int i=0;
	for (Document doc:iterable) {
		ret1.add(doc);
		
		i++;
		if (limit>0 && i==limit) break;
	}
	

	return ret1;
}


//----------------------------------------
boolean checkDocFieldDuplicate(
		ArrayList<String[]> arr, String sub_field_name, String sub_field_level, String sub_parent_field) {
	
	for (int a=0;a<arr.size();a++) {
		String main_field_name=arr.get(a)[0];
		String main_field_level=arr.get(a)[1];
		String main_parent_field=arr.get(a)[2];
		
		if (
				main_field_name.equals(sub_field_name) 
				&& main_field_level.equals(sub_field_level)
				&& main_parent_field.equals(sub_parent_field)) {
			return true;
			
		}
	}
	
	return false;
}
	
	//----------------------------------------

	ArrayList<String[]> getDocumentStructure(ArrayList<String[]> curFields, String doc, int level, String parent) {
		ArrayList<String[]> ret1=curFields;
		if (ret1==null) ret1=new ArrayList<String[]>();
		
			
		DBObject dbObject = (DBObject) JSON.parse(doc);
	
		ArrayList<String> checkArr=new ArrayList<String>();
		
		Map map=dbObject.toMap();
		
		for (Object obj:  map.keySet()) {
			String key=obj.toString();
			String val=map.get(key).toString();
			
			
			boolean is_array_num=false;
			try {
				Integer.parseInt(key);  
				is_array_num=true;
				key="(\\d+)";
				} catch(Exception e) {is_array_num=false;}
			
			if(checkArr.indexOf(key)>-1) continue;
			
			
			checkArr.add(key);
			
			String full_key_path=key;
			if (parent.length()>0) full_key_path=parent+"."+full_key_path;
			
			char first_char='x';
			try{first_char=val.trim().charAt(0);} catch(Exception e) {}
			
			if (first_char=='{' || first_char=='[')  {
				if(!checkDocFieldDuplicate(ret1, key, ""+level, parent))
					ret1.add(new String[]{full_key_path,""+level,parent,"NODE"});
				
				ArrayList<String[]> subFields=getDocumentStructure(null, val, level+1, full_key_path);
				
				for (int s=0;s<subFields.size();s++) {
					String sub_field_name=subFields.get(s)[0];
					String sub_field_level=subFields.get(s)[1];
					String sub_parent_field=subFields.get(s)[2];
					
					boolean is_exists=checkDocFieldDuplicate(ret1, sub_field_name, sub_field_level, sub_parent_field);
	
					if (is_exists) continue;
					
					ret1.add(subFields.get(s));
				}
				
			}
			else {
				
				boolean is_exists=checkDocFieldDuplicate(ret1, key, ""+level, parent);
				if (!is_exists) {
					if (key.equals("_id"))
						ret1.add(new String[]{full_key_path,""+level,parent,"KEY"});
					else 
						ret1.add(new String[]{full_key_path,""+level,parent,"ENTITY"});
				}
				
			}
			
		}
	
		
		//--------------------------------------------
		if (level==1) 
			for (int i=0;i<ret1.size();i++) {
				String key1=ret1.get(i)[0];
				for (int j=i+1;j<ret1.size();j++) {
					String key2=ret1.get(j)[0];
					
					if (key1.compareTo(key2)>0) {
						String[] tmp=ret1.get(i);
						ret1.set(i, ret1.get(j));
						ret1.set(j, tmp);
					}
				}
			}
	
		return ret1;
	}
		
//---------------------------------------------------------------
String makeTableConfig(Connection conn, HttpSession session, String tab_id) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select schema_name, tab_name, skip_drop_index, skip_drop_constraint, skip_drop_trigger, app_type, "+
				" hint_after_select, hint_before_table, hint_after_table, "+
				" check_existence_action, check_existence_sql, check_existence_on_fields "+
				" from tdm_tabs t, tdm_apps a "+
				" where t.app_id=a.id " +
				" and t.id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.add(new String[]{"INTEGER",tab_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) return "No such table found. ID : "+tab_id;
	
	String schema_name=arr.get(0)[0];
	String tab_name=arr.get(0)[1];
	String skip_drop_index=arr.get(0)[2];
	String skip_drop_constraint=arr.get(0)[3];
	String skip_drop_trigger=arr.get(0)[4];
	String app_type=arr.get(0)[5];

	String hint_after_select=arr.get(0)[6];
	String hint_before_table=arr.get(0)[7];
	String hint_after_table=arr.get(0)[8];
	
	String check_existence_action=arr.get(0)[9];
	String check_existence_sql=arr.get(0)[10];
	String check_existence_on_fields=arr.get(0)[11];
	
	String skip_drop_index_checked="";
	String skip_drop_constraint_checked="";
	String skip_drop_trigger_checked="";
	
	if (skip_drop_index.equals("YES")) skip_drop_index_checked="checked";
	if (skip_drop_constraint.equals("YES")) skip_drop_constraint_checked="checked";
	if (skip_drop_trigger.equals("YES")) skip_drop_trigger_checked="checked";
	
	
	sb.append("<input type=hidden id=config_tab_id value="+tab_id+">");
	
	sb.append("<h4>");
	sb.append("<b>"+schema_name+"</b>."+tab_name);
	sb.append("</h4>");
	
	sb.append("<table class=table>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Don't drop/disable indexes : </b></td>");
	sb.append("<td>");
	sb.append("<input type=checkbox "+skip_drop_index_checked+" id=skip_drop_index>");
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Don't drop/disable constraints : </b></td>");
	sb.append("<td>");
	sb.append("<input type=checkbox "+skip_drop_constraint_checked+" id=skip_drop_constraint>");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Don't drop/disable triggers : </b></td>");
	sb.append("<td>");
	sb.append("<input type=checkbox "+skip_drop_trigger_checked+" id=skip_drop_trigger>");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Hint after 'select' keyword  : </b></td>");
	sb.append("<td>");
	sb.append("<font color=blue>select <br>");
	sb.append(makeText("hint_after_select", hint_after_select, "", 0));
	sb.append("* from table1 ");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Hint before from   : </b></td>");
	sb.append("<td>");
	sb.append("<font color=blue>select *   <br>");
	sb.append(makeText("hint_before_table", hint_before_table, "", 0));
	sb.append("from table1 ");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Hint after table name  : </b></td>");
	sb.append("<td>");
	sb.append("<font color=blue>select * from table1 <br>");
	sb.append(makeText("hint_after_table", hint_after_table, "", 0));
	sb.append("where field1='X'</font>");
	sb.append("</td>");
	sb.append("</tr>");
	
	if (app_type.equals("COPY")) {
		
		
		
		
		sb.append("<tr>");
		sb.append("<td align=right><b> Check Existance Action  : </b></td>");
		ArrayList<String[]> existActArr=new ArrayList<String[]>();
		existActArr.add(new String[]{"NONE","Don't Check Existance"});
		existActArr.add(new String[]{"SKIP","Skip Record Copying"});
		existActArr.add(new String[]{"UPDATE","Update Record"});

		
		sb.append("<td>");
		sb.append(makeComboArr(existActArr, "", "size=1 id=check_existence_action", check_existence_action, 0));
		sb.append("</td>");
		sb.append("</tr>");
		
		
		sql="select field_name from tdm_fields where tab_id=? order by 1";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",tab_id});
		ArrayList<String[]> allfields=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		ArrayList<String[]> picked_fields=new ArrayList<String[]>();
				
		String[] arrx=check_existence_on_fields.split("\\|::\\|");
		for (int i=0;i<arrx.length;i++)
			if (arrx[i].trim().length()>0)
				picked_fields.add(new String[]{arrx[i].trim()});

		
		sb.append("<tr>");
		sb.append("<td colspan=2>");
		sb.append("<b> Check Existance SQL  : </b><br>");
		sb.append("<textarea id=check_existence_sql rows=3 style=\"width:100%; \">"+check_existence_sql+"</textarea>");
		sb.append("</td>");
		sb.append("</tr>");
		
		sb.append("<tr>");
		sb.append("<td colspan=2>");
		sb.append("<b> Check Existance Base On Fields  : </b><br>");
		sb.append(makePickList("0", "check_existence_on_fields", allfields, picked_fields, "", ""));
		sb.append("</td>");
		sb.append("</tr>");
		
		
		
		
		
	}
	
	
	sb.append("</table>");
	
	return sb.toString();
}


//---------------------------------------------------------------
void saveTableConfig(
		Connection conn, 
		HttpSession session, 
		String tab_id, 
		
		String skip_drop_index,
		String skip_drop_constraint,
		String skip_drop_trigger,
		
		String hint_after_select,
		String hint_before_table,
		String hint_after_table,
		
		String check_existence_action, 
		String check_existence_sql, 
		String check_existence_on_fields
		) {
	
	String sql="update tdm_tabs set "+
				" skip_drop_index=?, "	+		
				" skip_drop_constraint=?, "	+	
				" skip_drop_trigger=?, "	+
				" hint_after_select=?, "+
				" hint_before_table=?, "+
				" hint_after_table=?, " + 
				" check_existence_action=?, " + 
				" check_existence_sql=?, " + 
				" check_existence_on_fields=? " +
				" where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	bindlist.add(new String[]{"STRING",skip_drop_index});
	bindlist.add(new String[]{"STRING",skip_drop_constraint});
	bindlist.add(new String[]{"STRING",skip_drop_trigger});
	
	bindlist.add(new String[]{"STRING",hint_after_select});
	bindlist.add(new String[]{"STRING",hint_before_table});
	bindlist.add(new String[]{"STRING",hint_after_table});
	
	bindlist.add(new String[]{"STRING",check_existence_action});
	bindlist.add(new String[]{"STRING",check_existence_sql});
	bindlist.add(new String[]{"STRING",check_existence_on_fields});
	
	
	bindlist.add(new String[]{"INTEGER",tab_id});
	
	execDBConf(conn, sql, bindlist);
	
}
	
//---------------------------------------------------------------
ArrayList<String[]> getFieldListFromMongoDB(Connection conn, String env_id, String db_name, String table ) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	String url="";
	String sql="select db_connstr from tdm_envs where id="+env_id;
	url=getDBSingleVal(conn, sql);
	
	MongoClient mongo=getMongoClient(url);
	
	if (mongo==null) return ret1;
	
	ArrayList<Document> docs=getDocuments(mongo, db_name, table, "", 100);
	
	ArrayList<String[]> arr=new ArrayList<String[]>();
	
	for (int i=0;i<docs.size();i++) 
		arr=getDocumentStructure(arr, docs.get(i).toJson(),1, "");
	
	for (int i=0;i<arr.size();i++) {
		String field_name=arr.get(i)[0];
		String a_field_type=arr.get(i)[3];
		String a_field_size="999";
		String is_pk="NO";
		if (a_field_type.equals("KEY")) is_pk="YES";
		
		ret1.add(new String[]{field_name,a_field_type,a_field_size,is_pk});
		
	}
	return ret1;
}

//---------------------------------------------------------
String getMONGODocumentById(Connection conn, String env_id, String db_name, String collection, String[] keys, String vals[]) {
		if (keys.length==0) return "";
		MongoClient mongo=null;
		String ret1="";
		
		try {
			
			
			
			BasicDBObject query = new BasicDBObject();
			for (int i=0;i<keys.length;i++) {
				
				String key=keys[i];
				String val=vals[i];
				if (key.equals("_id"))
					query.append(key, new ObjectId(val));
				else 
					query.append(key, val);
				
			}
			
			String url="";
			String sql="select db_connstr from tdm_envs where id="+env_id;
			url=getDBSingleVal(conn, sql);
			mongo=getMongoClient(url);
			MongoDatabase mdb=mongo.getDatabase(db_name);
			
			//FindIterable<Document> iterable = mdb.getCollection(collection).find(qdoc);
			FindIterable<Document> iterable = mdb.getCollection(collection).find(query);
			
			
			System.out.println(" db_name : " + db_name);
			System.out.println(" iterable : " + iterable.toString());
			
			for (Document doc:iterable) {
				ret1=doc.toJson();
				break;
			}
			 
		}
		catch(Exception e) {
			e.printStackTrace();
			
		} finally {
			try {mongo.close();} catch(Exception e) {}
		}
		
		return nvl(ret1,"{}");
	}

//--------------------------------------------------------------------
String startNewDiscoveryWindow(Connection conn, HttpSession session,String disc_type) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new  ArrayList<String[]>();
	
	String sql="";
	
	
	sb.append("<input type=hidden id=discovery_type value="+disc_type+">");
	
	sb.append("<table class=\"table table-condensed table-striped\" >");
	
	
	sql="select 'MASK','For Masking' from dual union all select 'COPY','For Copying' from dual";
	
	sb.append("<tr>");
	sb.append("<td align=right><span class=\"label label-info\">Discovery Type : </span></td>");
	sb.append("<td>");
	sb.append(makeCombo(conn, sql, "", "id=disc_discovery_type", "", 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("<tr>");
	sb.append("<td align=right><span class=\"label label-info\">Discovery Name : </span></td>");
	sb.append("<td>");
	sb.append(makeText("disc_discovery_title", "New Discovery @ " + (new Date()), "", 0));
	sb.append("</td>");
	sb.append("</tr>");


	
	

	sql="select id, description from tdm_discovery_sector order by 2";
	sb.append("<tr>");
	sb.append("<td align=right><span class=\"label label-info\">Target Sector : </span></td>");
	sb.append("<td>");
	sb.append(makeCombo(conn, sql, "", "id=disc_discovery_sector", "", 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sql="select id, name application from tdm_apps where app_type='MASK' order by 2";
	
	sb.append("<tr>");
	sb.append("<td align=right><span class=\"label label-info\">Application : </span></td>");
	sb.append("<td>");
	sb.append(makeCombo(conn, sql, "", "id=disc_application_id", "", 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	
	sql="select id, name environment from tdm_envs order by 2";
	sb.append("<tr>");
	sb.append("<td align=right><span class=\"label label-info\">Database : </span></td>");
	sb.append("<td>");
	sb.append(makeCombo(conn, sql, "", "id=disc_env_id onchange=fillDiscCatalogSchemaList()", "", 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><span class=\"label label-info\">Catalog : </span></td>");
	sb.append("<td>");
	sb.append("<div id=discCatalogListDiv>");
	sb.append("Pick a database to fill catalog list...");
	sb.append("</div>");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><span class=\"label label-info\">Schema : </span></td>");
	sb.append("<td>");
	sb.append("<div id=discSchemaListDiv>");
	sb.append("Pick a database to fill schema list...");
	sb.append("</div>");
	sb.append("</td>");
	sb.append("</tr>");
	

	
	String default_discovery_sample_count=nvl(getParamByName(conn, "DISCOVERY_SAMPLE_SIZE"),"1000");
	
	sb.append("<tr>");
	sb.append("<td align=right><span class=\"label label-info\">Sample Count : </span></td>");
	sb.append("<td>");
	sb.append(makeNumber("0", "disc_sample_count", default_discovery_sample_count, "", "EDIT", "6", "0", ",", "", "", "100", "999999"));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	String thread_count=nvl(getParamByName(conn, "DISCOVERY_THREAD_COUNT"),"10");
	
	sb.append("<tr>");
	sb.append("<td align=right><span class=\"label label-info\">Discovery Thread Count : </span>   <br>(can be changed <a href=\"admin2.jsp\">Admin</a> page)</td>");
	sb.append("<td>");
	sb.append("<b><big>"+thread_count+"</big></b>");
	sb.append("</td>");
	sb.append("</tr>");
	
	
	
	sb.append("</table>");
	
	return sb.toString();
}

//--------------------------------------------------------------------
String startNewDiscovery(
		Connection conn, 
		HttpSession session,
		String discovery_type, 
		String app_id, 
		String env_id, 
		String schema_name, 
		String discovery_title,
		String sample_count,
		String sector_id
		) {
	String new_discovery_id="0";
	
	String sql="SELECT AUTO_INCREMENT FROM information_schema.tables WHERE table_name = 'tdm_discovery' AND table_schema = DATABASE( ) ;";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	new_discovery_id=arr.get(0)[0];
	
	sql="insert into tdm_discovery (id, discovery_type, status, app_id, env_id, schema_name, discovery_title, sample_count, sector_id, create_date) "+
		" values (?,?,'NEW',?,?,?,?,?,?,now()) ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",new_discovery_id});
	bindlist.add(new String[]{"STRING",discovery_type});
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"INTEGER",env_id});
	bindlist.add(new String[]{"STRING",schema_name});
	bindlist.add(new String[]{"STRING",discovery_title});
	bindlist.add(new String[]{"INTEGER",sample_count});
	bindlist.add(new String[]{"INTEGER",sector_id});
	
	boolean is_ok=execDBConf(conn, sql, bindlist);
	
	if (!is_ok) return "0";
	
	
	return new_discovery_id;
}


//--------------------------------------------------------------------
String fillDiscoveryCatalogList(Connection conn, HttpSession session, String disc_env_id) {
	StringBuilder sb=new StringBuilder();
	
	
	
	StringBuilder errmsg=new StringBuilder();
	ArrayList<String[]> catArr=getDesignerCatalogList(conn, session, disc_env_id, errmsg);
	if (errmsg.length()>0) 
		System.out.println("Error@fillDiscoveryCatalogList.getDesignerCatalogList : "+errmsg.toString());
	
	ArrayList<String[]> emptyList=new ArrayList<String[]>();
			
	sb.append(makeComboArr(catArr, "", "id=disc_catalog_filter onchange=fillDiscSchemaList()", "", 0));
	
	return sb.toString();
}

//--------------------------------------------------------------------
String fillDiscoverySchemaList(Connection conn, HttpSession session, String disc_env_id, String disc_catalog_filter) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new  ArrayList<String[]>();
	
	StringBuilder errmsg=new StringBuilder();
	ArrayList<String[]> schemaArr=getDesignerSchemaList(conn, session, disc_env_id, disc_catalog_filter, errmsg);
	if (errmsg.length()>0) 
		System.out.println("Error@fillDiscoverySchemaList.getDesignerSchemaList : "+errmsg.toString());
	
	ArrayList<String[]> emptyList=new ArrayList<String[]>();
			
	sb.append(makePickList("0", "disc_schema_list", schemaArr, emptyList, "", ""));
	
	return sb.toString();
}
//--------------------------------------------------------------------
String makeDiscoveryList(Connection conn, HttpSession session) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new  ArrayList<String[]>();
	
	String sql="";
	
	String active_discovery_id=nvl((String) session.getAttribute("active_discovery_id"),"0");


	
	bindlist.add(new String[]{"STRING",mysql_format});
	
	sql="select disc.id, discovery_type, discovery_title, a.name application, e.name environment , "+
		" (select description from tdm_discovery_sector where id=sector_id) sector_description, "+
		" DATE_FORMAT(create_date,?) create_date, disc.status status, progress, progress_desc "+
		" from tdm_discovery disc, tdm_apps a, tdm_envs e "+
		" where disc.app_id=a.id and disc.env_id=e.id " +
		" order by 1 desc";
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<table class=\"table table-condensed\">");
	
	sb.append("<tr>");
	sb.append("<td><span class=\"label label-warning\">#</span></td>");
	sb.append("<td><span class=\"label label-warning\">Discovery Type</span></td>");
	sb.append("<td><span class=\"label label-warning\">Sector</span></td>");
	sb.append("<td><span class=\"label label-warning\">Discovery Name</span></td>");
	sb.append("<td><span class=\"label label-warning\">Application</span></td>");
	sb.append("<td><span class=\"label label-warning\">Environment</span></td>");
	sb.append("<td><span class=\"label label-warning\">Created@</span></td>");
	sb.append("<td><span class=\"label label-warning\">Status</span></td>");
	sb.append("<td align=center><span class=\"label label-warning\">Progress</span></td>");
	sb.append("<td><span class=\"label label-warning\">Progress Detail</span></td>");
	sb.append("</tr>");
	
	
	for (int i=0;i<arr.size();i++) {
		String discovery_id=arr.get(i)[0];
		String discovery_type=arr.get(i)[1];
		String work_plan_name=arr.get(i)[2];
		String application=arr.get(i)[3];
		String environment=arr.get(i)[4];
		String sector=nvl(arr.get(i)[5],"Any");
		String create_date=arr.get(i)[6];
		String status=arr.get(i)[7];
		String progress=nvl(arr.get(i)[8],"0");
		String progress_desc=arr.get(i)[9];
		
		String tr_class="";
		if (discovery_id.equals(active_discovery_id)) tr_class="danger";
		
		
		sb.append("<tr class=\""+tr_class+"\">");
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=setActiveDiscoveryId('"+discovery_id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-remove\">"+discovery_id+"</span>");
		sb.append("</button>");
		sb.append("</td>");
		sb.append("<td>"+discovery_type+"</td>");
		sb.append("<td>"+sector+"</td>");
		sb.append("<td>"+work_plan_name+"</td>");
		sb.append("<td>"+application+"</td>");
		sb.append("<td>"+environment+"</td>");
		sb.append("<td>"+create_date+"</td>");
		sb.append("<td>"+status+"</td>");
		sb.append("<td align=center>"+progress+" %</td>");
		sb.append("<td>"+progress_desc+"</td>");
		sb.append("</tr>");
		
		
	}
	
	sb.append("</table>");
	
	return sb.toString();
}

//--------------------------------------------------------------------
void setActiveDiscoveryId(Connection conn, HttpSession session, String discovery_id) {
	session.setAttribute("active_discovery_id", discovery_id);
}

//--------------------------------------------------------------------
String loadDiscoveryLeft(Connection conn, HttpSession session) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new  ArrayList<String[]>();
	ArrayList<String[]> arr=new  ArrayList<String[]>();
	String sql="";
	
	String active_discovery_id=nvl((String) session.getAttribute("active_discovery_id"),"0");
	String active_discovery_type="x";
	String active_discovery_name="Pick a discovery or create one";

	String app_id="";
	String app_name="";
	String env_id="";
	String env_name="";
	
	
	if (!active_discovery_id.equals("0")) {
		sql="select discovery_type, discovery_title from tdm_discovery where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",active_discovery_id});
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		active_discovery_type=arr.get(0)[0];
		active_discovery_name=arr.get(0)[1];
	}
	
	
	sb.append("<div class=row style=\"background-color:darkblue;\">");
	
	sb.append("<table>");
	sb.append("<tr>");
	sb.append("<td>-</td>");
	sb.append("<td align=center>");
	sb.append("<b><font color=white>"+clearHtml(active_discovery_name)+"</font></b>");
	sb.append("</td>");
	sb.append("<td>-</td>");
	sb.append("</tr>");
	sb.append("</table>");
	
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	
	sb.append("<table class=\"table table-condensed table-striped\">");
	
	sb.append("<tr>");
	
	
	
	sb.append("<div class=\"btn-group btn-group-justified\" role=\"group\" aria-label=\"...\">");
	sb.append("  <div class=\"btn-group\" role=\"group\">");
	sb.append("    <button type=\"button\" class=\"btn btn-default\" onclick=openDiscoveryList()><span class=\"glyphicon glyphicon-folder-open\"> Open</span></button>");
	sb.append("  </div>");
	sb.append("  <div class=\"btn-group\" role=\"group\">");
	sb.append("    <button type=\"button\" class=\"btn btn-default\" onclick=startNewMaskingDiscovery()><span class=\"glyphicon glyphicon-plus\"> Start New</span></button>");
	sb.append("  </div>");
	sb.append("  <div class=\"btn-group\" role=\"group\">");
	sb.append("    <button type=\"button\" class=\"btn btn-sm btn-success\" onclick=loadDiscoveryReport()><span class=\"glyphicon glyphicon-repeat\"> Refresh</span></button>");
	sb.append("  </div>  ");
	sb.append("</div>");
	
	sb.append("</tr>");
	
	sb.append("</table>");
	
	sb.append("</div>");
	
	
	
	
	if (active_discovery_id.equals("0")) return sb.toString();
	
	
	ArrayList<String[]> emptyPickedList=new ArrayList<String[]>();
	
	sb.append("<div class=row>");
	sb.append("<table class=\"table table-condensed\">");
	
	ArrayList<String[]> matchRateArr=new ArrayList<String[]>();
	matchRateArr.add(new String[]{"0","0%"});
	matchRateArr.add(new String[]{"10","10%"});
	matchRateArr.add(new String[]{"20","20%"});
	matchRateArr.add(new String[]{"30","30%"});
	matchRateArr.add(new String[]{"40","40%"});
	matchRateArr.add(new String[]{"50","50%"});
	matchRateArr.add(new String[]{"60","60%"});
	matchRateArr.add(new String[]{"70","70%"});
	matchRateArr.add(new String[]{"80","80%"});
	matchRateArr.add(new String[]{"90","90%"});
	matchRateArr.add(new String[]{"100","100%"});
	
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right>Match Rate>=</td>");
	sb.append("<td>");
	sb.append(makeComboArr(matchRateArr, "", "id=match_rate size=1 onchange=loadDiscoveryReport()", "50", 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	
	
	ArrayList<String[]> groupByArr=new ArrayList<String[]>();
	if (active_discovery_type.equals("MASK"))
		groupByArr.add(new String[]{"CATEGORY","Discovery Category"}); 
	groupByArr.add(new String[]{"CATALOG","Table Catalog"});
	groupByArr.add(new String[]{"OWNER","Table Owner"});
	groupByArr.add(new String[]{"TABLE","Table"});
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right>Group By</td>");
	sb.append("<td>");
	sb.append(makeComboArr(groupByArr, "", "id=groupBy size=1 onchange=loadDiscoveryReport()", "CATEGORY", 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right></td>");
	sb.append("<td nowrap colspan=2>");
	sb.append("<input type=checkbox id=includeDiscarded onclick=loadDiscoveryReport()>");
	sb.append(" Include Discarded Table/Columns");
	sb.append("</td>");
	sb.append("</tr>");
	
	if (active_discovery_type.equals("MASK")) {
		ArrayList<String[]> allTargetList=new ArrayList<String[]>();
		
		sql="select id, description from tdm_discovery_target order by 2";
		bindlist.clear();
		allTargetList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		sb.append("<tr>");
		sb.append("<td colspan=2>");
		sb.append(makePickList("", "targetList", allTargetList, emptyPickedList, "", ""));
		sb.append("</td>");
		sb.append("</tr>");
	}
	else 
		sb.append("<input type=hidden id=targetList>");
	
	
	ArrayList<String[]> allCatalogList=new ArrayList<String[]>();
	ArrayList<String[]> allSchemaList=new ArrayList<String[]>();
	
	if (active_discovery_type.equals("COPY")) {
		sql="select distinct tab_cat from tdm_discovery_rel where discovery_id=? order by 1";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",active_discovery_id});
		allCatalogList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		sql="select distinct tab_owner from tdm_discovery_rel where discovery_id=? order by 1";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",active_discovery_id});
		allSchemaList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		
	}
	else {
		
		
		sql="select distinct catalog_name from tdm_discovery_result where discovery_id=? order by 1";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",active_discovery_id});
		allCatalogList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		sql="select distinct schema_name from tdm_discovery_result where discovery_id=? order by 1";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",active_discovery_id});
		allSchemaList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		
	}
	
	
	
	String event_listener="loadDiscoveryReport()";
	
	
	sb.append("<tr>");
	sb.append("<td colspan=2>");
	sb.append(makePickList("", "catalogList", allCatalogList, emptyPickedList, "", event_listener));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td colspan=2>");
	sb.append(makePickList("", "schemaList", allSchemaList, emptyPickedList, "", event_listener));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right>Table Name</td>");
	sb.append("<td>");
	sb.append("<input type=text id=table_name style=\"width:100%;\" onchange=loadDiscoveryReport()>");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right>Column Name</td>");
	sb.append("<td>");
	sb.append("<input type=text id=field_name style=\"width:100%;\" onchange=loadDiscoveryReport()>");
	sb.append("</td>");
	sb.append("</tr>");
	
	if (active_discovery_type.equals("MASK")) {
		sql="select id, concat('',id, ' ', discovery_title)  "+
				" from tdm_discovery  "+
				" where  id<>? and discovery_type='"+active_discovery_type+"' " + 
				" order by 1 desc";
			bindlist.clear();
			
			bindlist.add(new String[]{"INTEGER",active_discovery_id});
			
			ArrayList<String[]> compareToArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
			
			sb.append("<tr>");
			sb.append("<td nowrap align=right>Compare To</td>");
			sb.append("<td>");
			sb.append(makeComboArr(compareToArr, "", "id=compareTo onchange=loadDiscoveryReport()", "", 0));
			sb.append("</td>");
			sb.append("</tr>");
	} else 
		sb.append("<input type=hidden id=compareTo>");
	
	
	
	sb.append("</table>");
	sb.append("</div>");
	
	
	return sb.toString();
}

//--------------------------------------------------------------------
String loadDiscoveryReport(
		Connection conn, 
		HttpSession session, 
		String discovery_id,
		String include_discarded,
		String group_by,
		String filter_catalog,
		String filter_owner,
		String filter_category,
		String match_rate_filter,
		String filter_table,
		String filter_column,
		String comparing_discovery_id
		) {
	
	
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new  ArrayList<String[]>();
	ArrayList<String[]> arr=new  ArrayList<String[]>();
	String sql="";
	
	String active_discovery_id=discovery_id;
	String active_discovery_name="";
	String app_id="";
	String discovery_type="";
	String app_name="";
	String env_id="";
	String env_name="";
	String progress="";
	String status="";
	String progress_desc="";
	String sample_count="";
	String sector="";
	String cancel_flag="";

	
	if (!active_discovery_id.equals("0")) {
		sql="select discovery_type, discovery_title, disc.env_id, e.name env_name, disc.app_id, "+
			" a.name app_name, status, progress, progress_desc, sample_count, "+
			" (select description from tdm_discovery_sector where id=sector_id) sector_description, "+
			" cancel_flag "+
			" from tdm_discovery disc, tdm_envs e, tdm_apps a "+
			" where disc.env_id=e.id and disc.app_id=a.id "+
			" and disc.id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",active_discovery_id});
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		if (arr!=null && arr.size()==1) {
			discovery_type=arr.get(0)[0];
			active_discovery_name=arr.get(0)[1];
			env_id=arr.get(0)[2];
			env_name=arr.get(0)[3];
			app_id=arr.get(0)[4];
			app_name=arr.get(0)[5];
			status=arr.get(0)[6];
			progress=arr.get(0)[7];
			progress_desc=arr.get(0)[8];
			sample_count=arr.get(0)[9];
			sector=nvl(arr.get(0)[10],"Any");
			cancel_flag=nvl(arr.get(0)[11],"NO");
		}
		
		
	}
	
	
	
	
	sb.append("<div class=row>");
	sb.append("<table class=\"table table-condensed\">");
	
	
	sb.append("<tr class=active>");
	
	sb.append("<td align=right>");
	sb.append("<b>#</b>");
	sb.append("</td>");
	
	sb.append("<td>");
	sb.append("<b>Type</b>");
	sb.append("</td>");
	
	sb.append("<td>");
	sb.append("<b>Application</b>");
	sb.append("</td>");
	
	
	
	sb.append("<td>");
	sb.append("<b>Environment</b>");
	sb.append("</td>");
	
	sb.append("<td>");
	sb.append("<b>Sample#</b>");
	sb.append("</td>");
	
	sb.append("<td>");
	sb.append("<b>Sector</b>");
	sb.append("</td>");
	
	sb.append("<td>");
	sb.append("<b>Status</b>");
	sb.append("</td>");
	
	sb.append("<td align=center>");
	sb.append("<b>Progres</b>");
	sb.append("</td>");
	
	sb.append("<td>");
	sb.append("<b>Detail</b>");
	sb.append("</td>");
	
	sb.append("<td align=center>");
	sb.append("<b></b>");
	sb.append("</td>");
	
	sb.append("</tr>");
	
	
	
	
	sb.append("<tr>");
	
	
	
	sb.append("<td class=warning align=right>");
	sb.append(discovery_id);
	sb.append("</td>");
	
	sb.append("<td class=warning>");
	if (discovery_type.equals("MASK")) sb.append("For Masking"); else  sb.append("For Copying");
	
	sb.append("</td>");
	
	sb.append("<td class=warning>");
	sb.append(app_name);
	sb.append("</td>");
	
	
	
	sb.append("<td class=warning>");
	sb.append("@"+env_name);
	sb.append("</td>");
	
	sb.append("<td class=warning align=center>");
	sb.append(sample_count);
	sb.append("</td>");
	
	sb.append("<td class=warning align=center>");
	sb.append(sector);
	sb.append("</td>");
	
	sb.append("<td class=warning>");
	if (cancel_flag.equals("YES"))
		sb.append("CANCELLED");
	else 
		sb.append(status);
	sb.append("</td>");
	
	sb.append("<td class=warning align=center>");
	sb.append(progress+" %");
	sb.append("</td>");
	
	sb.append("<td class=warning>");
	sb.append(progress_desc);
	sb.append("</td>");
	
	
	sb.append("<td class=warning align=center>");
	
	if (cancel_flag.equals("NO") && status.equals("RUNNING") ) {
		sb.append(" <font color=green>");
		sb.append("<span class=\"glyphicon glyphicon-stop\" onclick=setMaskDiscoveryAction('"+discovery_id+"','CANCEL')></span>");
		sb.append("</font>");
	}
	
	if (status.equals("FINISHED") || status.equals("UNFINISHED") || status.equals("KILLED") || status.equals("INITIALIZING") || status.equals("CANCELLED") ) {
		sb.append(" <font color=green>");
		sb.append("<span class=\"glyphicon glyphicon-refresh\" onclick=setMaskDiscoveryAction('"+discovery_id+"','RESTART')></span>");
		sb.append("</font>");
		
		sb.append(" <font color=red>");
		sb.append("<span class=\"glyphicon glyphicon-remove\" onclick=setMaskDiscoveryAction('"+discovery_id+"','DELETE')></span>");
		sb.append("</font>");
	}
	
	
	

	sb.append(" <font color=blue>");
	sb.append("<span class=\"glyphicon glyphicon-save\" onclick=pickMaskingDiscoveryReportType('"+discovery_id+"')></span>");
	sb.append("</font>");
	
	sb.append("</td>");
	
	sb.append("</tr>");
	
	
	sb.append("</table>");
	sb.append("</div>");
	
	if (discovery_type.equals("MASK"))
		sb.append(loadDiscoveryReportForMasking(
				conn,
				session,
				active_discovery_id,
				env_id,
				app_id,
				match_rate_filter,
				filter_catalog,
				filter_owner,
				filter_category,
				filter_table,
				filter_column,
				comparing_discovery_id,
				group_by
				));	
	else 
		sb.append(loadDiscoveryReportForCopying(
				conn,
				session,
				active_discovery_id,
				env_id,
				app_id,
				match_rate_filter,
				filter_catalog,
				filter_owner,
				filter_table,
				filter_column,
				comparing_discovery_id,
				group_by
				));
	return sb.toString();
}

//-----------------------------------------------------------------
String loadDiscoveryReportForCopying(
		Connection conn,
		HttpSession session,
		String active_discovery_id,
		String env_id,
		String app_id,
		String match_rate_filter,
		String filter_catalog,
		String filter_owner,
		String filter_table,
		String filter_column,
		String comparing_discovery_id,
		String group_by
		) {

	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	StringBuilder sb=new StringBuilder();
	
	
	
	sql="select id, tab_cat, tab_owner, tab_name, child_rel_fields, parent_tab_cat, parent_tab_owner, parent_tab_name, parent_pk_fields, \n"+
			" sample_count, matched_count \n"  + 
			" from tdm_discovery_rel \n"+
			" where  discovery_id=? \n"+
			" and sample_count>0 \n";
			
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",active_discovery_id});
	
	
	if (filter_catalog.length()>0) {
		String[] catArr=filter_catalog.split("\\|::\\|");
		
		sql=sql+" and tab_cat in (";
		for (int i=0;i<catArr.length;i++) {
			if (i>0) sql=sql+", ";
			sql=sql+"?";
			bindlist.add(new String[]{"STRING",catArr[i]});
		}
		sql=sql+") \n";
	}
	
	
	if (filter_owner.length()>0) {
		String[] owArr=filter_owner.split("\\|::\\|");
		
		sql=sql+" and tab_cat in (";
		for (int i=0;i<owArr.length;i++) {
			if (i>0) sql=sql+", ";
			sql=sql+"?";
			bindlist.add(new String[]{"STRING",owArr[i]});
		}
		sql=sql+") \n";
	}
	
	if (filter_table.trim().length()>0) {
		sql=sql+" and ( upper(tab_name) like upper('%"+filter_table+"%') or upper(parent_tab_name) like upper('%"+filter_table+"%')  )  \n";
	}
	
	if (filter_column.trim().length()>0) {
		sql=sql+" and ( upper(child_rel_fields) like upper('%"+filter_column+"%') or upper(parent_pk_fields) like upper('%"+filter_column+"%') )  \n";
	}
			
	
	if (group_by.equals("CATALOG")) sql=sql+" order by sample_count desc, tab_cat \n";
	if (group_by.equals("OWNER")) sql=sql+" order by sample_count desc, tab_name \n";
	if (group_by.equals("TABLE")) sql=sql+" order by sample_count desc, tab_owner \n";
	
	sql=sql+" ,matched_count/sample_count desc";
	
	System.out.println(sql);
	for (int i=0;i<bindlist.size();i++) {
		System.out.println("\t"+bindlist.get(i)[0]+"="+bindlist.get(i)[1]);
	}
	
	ArrayList<String[]> resList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	sb.append("<table class=\"table table-striped table-condensed\">");
	
	sb.append("<tr class=info>");
	sb.append("<td></td>");
	sb.append("<td><span class=\"label label-warning\">Table</span></td>");
	sb.append("<td><span class=\"label label-warning\">Column</span></td>");
	sb.append("<td></td>");
	sb.append("<td><span class=\"label label-warning\">Parent Table</span></td>");
	sb.append("<td><span class=\"label label-warning\">Parent Table Columns</span></td>");
	sb.append("<td align=center><span class=\"label label-warning\">Matched</span></td>");
	sb.append("<td align=center><span class=\"label label-warning\">Sample</span></td>");
	sb.append("<td align=center><span class=\"label label-warning\">Matching %</span></td>");
	
	
	
	int count=0;
	
	
	
	for (int i=0;i<resList.size();i++) {
		String discovery_result_id=resList.get(i)[0];
		String catalog_name=resList.get(i)[1];
		String schema_name=resList.get(i)[2];
		String table_name=resList.get(i)[3];
		String field_name=resList.get(i)[4];
		String parent_tab_catalog=resList.get(i)[5];
		String parent_tab_owner=resList.get(i)[6];
		String parent_tab_name=resList.get(i)[7];
		String parent_pk_fields=resList.get(i)[8];
		int res_sample_count=Integer.parseInt(resList.get(i)[9]);
		int res_match_count=Integer.parseInt(resList.get(i)[10]);
		int match_rate_percent=(100*res_match_count)/res_sample_count;
		
		if (match_rate_percent<Integer.parseInt(match_rate_filter)) continue;
		
		
		
		
		
		
		sb.append("<tr>");
		
		
		sb.append("<td nowrap>");		
		sb.append("<span class=\"glyphicon glyphicon-list-alt\" onclick=\"showSqlEditor('"+env_id+"','0','"+schema_name+"."+table_name+"','','"+catalog_name+"');\"></span>");
		sb.append("</td>");
		sb.append("<td nowrap><small>["+catalog_name+"].<b>"+schema_name+"</b>."+table_name+"</small></td>");
		sb.append("<td nowrap><small>"+field_name.replaceAll(",","<br>")+"</small></td>");
		
		
		sb.append("<td nowrap>");		
		sb.append("<span class=\"glyphicon glyphicon-list-alt\" onclick=\"showSqlEditor('"+env_id+"','0','"+parent_tab_owner+"."+parent_tab_name+"','','"+parent_tab_catalog+"');\"></span>");
		sb.append("</td>");
		sb.append("<td nowrap><small>["+parent_tab_catalog+"].<b>"+parent_tab_owner+"</b>."+parent_tab_name+"</small></td>");
		sb.append("<td nowrap><small>"+parent_pk_fields.replaceAll(",","<br>")+"</small></td>");
		
		
		
		sb.append("<td nowrap align=right>");
		sb.append("<small>"+res_match_count+"</small>");
		sb.append("</td>");

		sb.append("<td nowrap align=right>");
		sb.append("<small>"+res_sample_count+"</small>");
		sb.append("</td>");

		sb.append("<td nowrap align=center>");
		sb.append("<small><span class=\"label label-info\">"+match_rate_percent+" %<span></small>");
		sb.append("</td>");
		
		sb.append("</tr>");
		
		count++;
		
	} //for (int i=0;i<resList.size();i++)
		
		
	sb.append("</table>");
	
	if (count==0) sb.append("<font color=red>No masking result found.</font>");
	
	return sb.toString();
}

//-----------------------------------------------------------------
String loadDiscoveryReportForMasking(
		Connection conn,
		HttpSession session,
		String active_discovery_id,
		String env_id,
		String app_id,
		String match_rate_filter,
		String filter_catalog,
		String filter_owner,
		String filter_category,
		String filter_table,
		String filter_column,
		String comparing_discovery_id,
		String group_by
		) {

	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select distinct concat(cat_name,'.',schema_name,'.',tab_name,'.',field_name)  "+
			" from tdm_fields f, tdm_tabs t, tdm_apps a"+
			" where f.tab_id=t.id and t.app_id=a.id and app_type='MASK'";
	bindlist.clear();
	ArrayList<String[]> arrListF=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	HashMap<String, String> hm=new HashMap<String, String>();
	
	for (int i=0;i<arrListF.size();i++) {
		String fieldname=arrListF.get(i)[0];
		
		hm.put("FIELD_"+fieldname,"z");
	}
	
	
	bindlist.clear();
	
	sql="select res.id, \n"+
		//" replace(concat(catalog_name,'.', schema_name),'${default}.','') schema_name, \n"+
		" catalog_name, \n"+
		" schema_name, \n"+
		" table_name, \n"+
		" field_name, \n"+
		" field_type, \n"+
		" tar.description discovery_target, rl.description discovery_rule, \n" +
		" sample_count, match_count, rule_weight \n"  + 
		" from tdm_discovery_result res, tdm_discovery_target tar, tdm_discovery_rule rl \n"+
		" where res.discovery_target_id=tar.id and discovery_rule_id=rl.id \n" +
		" and discovery_id=? \n"+
		" and sample_count>0 \n";
		
		
		
		
		bindlist.add(new String[]{"INTEGER",active_discovery_id});
		
		
		if (filter_catalog.length()>0) {
			String[] catArr=filter_catalog.split("\\|::\\|");
			sql=sql+" and catalog_name in (";
			for (int i=0;i<catArr.length;i++) {
				if (i>0) sql=sql+", ";
				sql=sql+"?";
				bindlist.add(new String[]{"STRING",catArr[i]});
			}
			sql=sql+") \n";
		}
		
		
		if (filter_owner.length()>0) {
			String[] owArr=filter_owner.split("\\|::\\|");
			sql=sql+" and schema_name in (";
			for (int i=0;i<owArr.length;i++) {
				if (i>0) sql=sql+", ";
				sql=sql+"?";
				bindlist.add(new String[]{"STRING",owArr[i]});
			}
			sql=sql+") \n";
		}
		
		if (filter_category.length()>0) {
			String[] catArr=filter_category.split("\\|::\\|");
			sql=sql+" and res.discovery_target_id in (";
			for (int i=0;i<catArr.length;i++) {
				if (i>0) sql=sql+", ";
				sql=sql+"?";
				bindlist.add(new String[]{"INTEGER",catArr[i]});
			}
			sql=sql+") \n";
		}
	
		if (filter_table.trim().length()>0) {
			sql=sql+" and upper(table_name) like upper('%"+filter_table+"%') \n";
		}
		
		if (filter_column.trim().length()>0) {
			sql=sql+" and upper(field_name) like upper('%"+filter_column+"%') \n";
		}
		
		if (comparing_discovery_id.length()>0) {
			sql = sql + 
					" and (res.catalog_name, res.schema_name, res.table_name, res.field_name, res.discovery_rule_id) not in  \n " +  
					" (select cmp.catalog_name, cmp.schema_name, cmp.table_name, cmp.field_name, cmp.discovery_rule_id  \n" + 
					" from tdm_discovery_result cmp  \n" + 
					" where discovery_id=? ) \n";
			bindlist.add(new String[]{"INTEGER",comparing_discovery_id});
		}
		
		
	if (group_by.equals("CATEGORY")) sql=sql+" order by res.discovery_target_id \n";
	if (group_by.equals("CATALOG")) sql=sql+" order by catalog_name \n";
	if (group_by.equals("OWNER")) sql=sql+" order by schema_name \n";
	if (group_by.equals("TABLE")) sql=sql+" order by table_name \n";
	
	sql=sql+" ,match_count/sample_count desc";
	
	
	
	
	ArrayList<String[]> resList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<table class=\"table table-striped table-condensed\">");
	
	sb.append("<tr class=info>");
	sb.append("<td></td>");
	
	if (!group_by.equals("CATALOG"))
		sb.append("<td><span class=\"label label-warning\">Catalog</span></td>");
	if (!group_by.equals("OWNER"))
		sb.append("<td><span class=\"label label-warning\">Owner</span></td>");
	if (!group_by.equals("TABLE"))
		sb.append("<td><span class=\"label label-warning\">Table</span></td>");
	
	sb.append("<td><span class=\"label label-warning\">Column</span></td>");
	sb.append("<td><span class=\"label label-warning\">Type</span></td>");
	sb.append("<td align=center><span class=\"label label-warning\">Matched</span></td>");
	sb.append("<td align=center><span class=\"label label-warning\">Sample</span></td>");
	sb.append("<td align=center><span class=\"label label-warning\">Matching %</span></td>");
	sb.append("<td align=center><span class=\"label label-warning\">Score</span></td>");
	
	if (!group_by.equals("CATEGORY"))
		sb.append("<td><span class=\"label label-warning\">Matching Category</span></td>");
	sb.append("<td><span class=\"label label-warning\">Matching Rule</span></td>");
	sb.append("</tr>");
	
	int count=0;
	
	String last_group_val="";
	String curr_group_val="";
	
	for (int i=0;i<resList.size();i++) {
		String discovery_result_id=resList.get(i)[0];
		String catalog_name=resList.get(i)[1];
		String schema_name=resList.get(i)[2];
		String table_name=resList.get(i)[3];
		String field_name=resList.get(i)[4];
		String field_type=resList.get(i)[5];
		String discovery_target=resList.get(i)[6];
		String discovery_rule=resList.get(i)[7];
		
		
		int res_sample_count=Integer.parseInt(resList.get(i)[8]);
		int res_match_count=Integer.parseInt(resList.get(i)[9]);
		int rule_weight_int=10;
		try{rule_weight_int=Integer.parseInt(resList.get(i)[10]);} catch(Exception e) {}
		
		int match_rate_percent=(100*res_match_count)/res_sample_count;
		
		if (match_rate_percent<Integer.parseInt(match_rate_filter)) continue;
		
		int score=match_rate_percent*rule_weight_int/100;
		
		if (group_by.equals("CATEGORY")) curr_group_val=discovery_target;
		else if (group_by.equals("CATALOG")) curr_group_val=catalog_name;
		else if (group_by.equals("OWNER")) curr_group_val=schema_name;
		else curr_group_val=table_name;
		
		
		
		if (!curr_group_val.equals(last_group_val)) {
			sb.append("<tr>");
			sb.append("<td colspan=16><span class=\"label label-primary\">"+curr_group_val+"</span></td>");
			sb.append("</tr>");
			
			last_group_val=curr_group_val;
		}
		
		sb.append("<tr>");
		
		sb.append("<td nowrap>");
		
		String full_field_path=catalog_name+"."+schema_name+"."+table_name+"."+field_name;


		boolean is_masked=hm.containsKey("FIELD_"+full_field_path);
		
		if (is_masked) sb.append("<font color=orange><b>");
		
		sb.append(" <small><span class=\"glyphicon glyphicon-plus\"  onclick=\"showAddTableToAppList("+active_discovery_id+",'0','"+catalog_name+"."+schema_name+"."+table_name+"','"+env_id+"','"+app_id+"');\"></span></small>");
		
		if (is_masked) sb.append("</font>");
		
		sb.append(" <small><span class=\"glyphicon glyphicon-list-alt\" onclick=\"showSqlEditor('"+env_id+"','0','"+catalog_name+"."+schema_name+"."+table_name+"','','"+catalog_name+"');\"></span></small>");
		
		
		
		sb.append("</td>");
		
		if (!group_by.equals("CATALOG"))
			sb.append("<td nowrap><small>"+catalog_name+"</small></td>");
		if (!group_by.equals("OWNER"))
			sb.append("<td nowrap><small>"+schema_name+"</small></td>");
		if (!group_by.equals("TABLE"))
			sb.append("<td nowrap><small>"+table_name+"</small></td>");
		
		sb.append("<td nowrap><small>"+field_name+"</small></td>");
		sb.append("<td nowrap><small>"+field_type+"</small></td>");
		
		

		sb.append("<td nowrap align=right>");
		sb.append("<small>"+res_match_count+"</small>");
		sb.append("</td>");

		sb.append("<td nowrap align=right>");
		sb.append("<small>"+res_sample_count+"</small>");
		sb.append("</td>");

		sb.append("<td nowrap align=right>");
		sb.append("<small>"+match_rate_percent+"%</small>");
		sb.append("</td>");
		
		sb.append("<td nowrap align=right>");
		sb.append("<small>"+score+"</small>");
		sb.append("</td>");

		
		if (!group_by.equals("CATEGORY"))
			sb.append("<td nowrap><small>"+discovery_target+"</small></td>");
		sb.append("<td nowrap><small>"+discovery_rule+"</small></td>");
		sb.append("</tr>");
		
		count++;
	}
	
	
	sb.append("</table>");
	
	if (count==0) sb.append("<font color=red>No masking result found.</font>");
	
	return sb.toString();
}


//-----------------------------------------------------------------
String loadCopyAppParams(Connection conn, HttpSession session, String app_id) {
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	sql="select name from tdm_apps where app_type='COPY' and id=?";
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	if (arr.size()==0) {
		return "Application not found";
	}
	
	String app_name=arr.get(0)[0];
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-8\">");
	sb.append("<span class=badge><big><big><b>"+app_name+"</b></big></big></span>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-4\" align=right>");
	
	sb.append("<button type=button class=\"btn btn-sm btn-warning\" oncLick=listMyCopyTasks()>");
	sb.append("<span class=\"glyphicon glyphicon-transfer\"></span> Cancel ");
	sb.append("</button>");
	
	sb.append(" ");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" oncLick=startCopy('"+app_id+"')>");
	sb.append("<span class=\"glyphicon glyphicon-transfer\"></span> Start Copy ");
	sb.append("</button>");
	
	
	
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<input type=hidden id=app_name value=\""+codehtml(app_name)+"\">");
	
	
	ArrayList<String[]> sourceDbList=getAvailableCopyDbList(conn,session,app_id,"SOURCE");
	ArrayList<String[]> targetDbList=getAvailableCopyDbList(conn,session,app_id,"TARGET");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=right>Task Name : </div>");
	sb.append("<div class=\"col-md-10\">");
	sb.append(makeText("work_plan_name", "", "readonly", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=right>From : </div>");
	sb.append("<div class=\"col-md-4\">");
	sb.append(makeComboArr(sourceDbList, "", "id=source_env_id onchange=fillTargetInfo('"+app_id+"'); ", "", 0));
	sb.append("</div>");

	sb.append("<div class=\"col-md-2\" align=right>To : </div>");
	sb.append("<div class=\"col-md-4\">");
	sb.append(makeComboArr(targetDbList, "", "id=target_env_id onchange=fillTargetInfo('"+app_id+"');" , "", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	
	
	ArrayList<String[]> filterList=getAvailableFilterList(conn,session,app_id);
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=right>Filter : </div>");
	sb.append("<div class=\"col-md-10\">");
	sb.append(makeComboArr(filterList, "", "id=filter_id onchange=\"fillCopyFilterVals(this, '"+app_id+"','copyFilterValsDiv','');  \"" , "", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\">");
	sb.append("</div>");
	sb.append("<div id=copyFilterValsDiv class=\"col-md-10\">");
	sb.append("<font color=red>Select filter to enter criterias.</font>");
	sb.append("</div>");
	sb.append("</div>");
	


	
	sql="select date_format(now(), ?) from dual";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	String curr_date_time=arr.get(0)[0];

	
	



	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=right> Copy Count :  </div>");

	sb.append("<div class=\"col-md-3\">");
	sb.append("<table border=0 cellspacing=0 cellpadding=0>");
	sb.append("<tr>");
	sb.append("<td>");
	sb.append(makeNumber("0", "copy_count", "1", "", "EDIT", "12", "0", ",", "", "", "1", "99999999"));
	sb.append("</td>");
	sb.append("<td>");
	sb.append("<span class=badge><input type=checkbox checked id=copy_all onclick=setCopyAll(this)> All</span>");
	sb.append("</td>");
	sb.append("</tr>");
	sb.append("</table>");
	sb.append("</div>");

	
	sb.append("<div class=\"col-md-2\" align=right> Repeat :  </div>");
	
	sb.append("<div class=\"col-md-3\">");
	sb.append(makeNumber("0", "repeat_count", "1", "", "EDIT", "12", "0", ",", "", "", "1", "99999999"));
	sb.append("</div>");

	sb.append("</div>");
	
	
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=right> Schedule : </div>");
	sb.append("<div class=\"col-md-10\">");
	sb.append(makeDate("0", "copy_schedule_date", curr_date_time, ""));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=right> Run After : </div>");
	sb.append("<div class=\"col-md-10\">");
	sb.append(makeWPListToDepend(conn,session,"COPY2"));
	sb.append("</div>");
	sb.append("</div>");
	
	ArrayList<String[]> onErrActionArr=new ArrayList<String[]>();
	onErrActionArr.add(new String[]{"STOP","Stop"});
	onErrActionArr.add(new String[]{"CONTINUE","Continue"});

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=right>On Error : </div>");
	sb.append("<div class=\"col-md-10\">");
	sb.append(makeComboArr(onErrActionArr, "", "size=1 id=on_error_action " , "", 120));
	sb.append("</div>");
	sb.append("</div>");
		
	
		
	
	sb.append("<div class=row>");
	sb.append("<div id=targetInfoDiv class=\"col-md-12\" align=right>");
	sb.append("-");
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	return sb.toString();
}

//-----------------------------------------------------------------
String listMyCopyTasks(Connection conn, HttpSession session, String filter_options) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	String curruser=""+((Integer) session.getAttribute("userid"));
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select wpl.id, work_plan_name, "+
		" (select concat(fname, ' ', lname) from tdm_user where id=created_by) created_by, \n"+
		" a.name application_name, \n"+
		" srce.target_name source, tare.target_name target, \n"+
		" DATE_FORMAT(create_date, ?) create_date, \n"+
		" DATE_FORMAT(start_date, ?) start_date, \n"+
		" DATE_FORMAT(end_date, ?) end_date, \n"+
		" status, copy_rec_count, copy_repeat_count, \n"+
		" (select sum(export_count) from tdm_work_package where work_plan_id=wpl.id) retrieve_count, \n"+
		" (select sum(success_count) from tdm_work_package where work_plan_id=wpl.id) copied_count, \n "+
		" (select count(*) from tdm_work_package where work_plan_id=wpl.id and length(err_info)>0) err_count \n, "+
		" run_type, \n"+
		" (select count(*) from tdm_work_plan_dependency wd, tdm_work_plan dwpl where wd.work_plan_id=wpl.id and depended_work_plan_id=dwpl.id and dwpl.status!='FINISHED') dep_wpl_count \n "+
		" from tdm_work_plan wpl, tdm_target srce, tdm_target tare, tdm_apps a \n" + 
		" where \n"+
		" wpl.env_id=srce.id and wpl.target_env_id=tare.id and wpl.app_id=a.id \n" + 
		" and wplan_type='COPY2' and created_by=? \n"+
		" ::ADDITIONALFILTERS:: \n" + 
		" order by 1 desc";
	
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	
	bindlist.add(new String[]{"INTEGER",curruser});
	

	
	session.setAttribute("search_copy_id", "");
	session.setAttribute("search_copy_work_plan_name", "");
	session.setAttribute("search_copy_status", "");
	session.setAttribute("search_copy_application", "");
	session.setAttribute("search_copy_source_db", "");
	session.setAttribute("search_copy_target_db", "");
	
	
	String[] filterArr=filter_options.split("\\|::\\|");
	
	String filter_sql="";
	
	
	if (!checkrole(session, "DESIGN") && !checkrole(session, "ADMIN")) {
		filter_sql=filter_sql+" AND wpl.created_by=?";
		bindlist.add(new String[]{"INTEGER",curruser});
	}
	
	for (int i=0;i<filterArr.length;i++) {
		String afilter=filterArr[i];
		
		
		
		if (afilter.trim().length()==0) continue;
		
		
		String filter_key=afilter.substring(0,afilter.indexOf("="));
		String filter_value=afilter.substring(afilter.indexOf("=")+1);
		
		
		
		if (filter_key.equals("search_copy_id")) {
			session.setAttribute("search_copy_id", filter_value);
			if (filter_value.trim().length()==0) 
				session.setAttribute("search_copy_id", "");
			else {
				try {
					Integer.parseInt(filter_value);
					filter_sql=filter_sql+" AND wpl.id=?";
					bindlist.add(new String[]{"INTEGER",filter_value});
					
				} catch(Exception e) {}
			}
			
		}
		
		if (filter_key.equals("search_copy_work_plan_name")) {
			session.setAttribute("search_copy_work_plan_name", filter_value);
			if (filter_value.trim().length()==0) 
				session.setAttribute("search_copy_work_plan_name", "");
			else {
				String[] arrLike=filter_value.split(" ");
				for (int k=0;k<arrLike.length;k++) {
					String alike=arrLike[k];
					if (alike.trim().length()==0) continue;
					filter_sql=filter_sql+" AND work_plan_name like concat('%',?,'%') ";
					bindlist.add(new String[]{"STRING",filter_value});
					
				}
			}
		} 
		
		if (filter_key.equals("search_created_by")) {
			
			session.setAttribute("search_created_by", filter_value);
			if (filter_value.trim().length()==0) 
				session.setAttribute("search_created_by", "");
			else {
				filter_sql=filter_sql+" AND exists (select 1 from tdm_user  where upper(concat(fname,' ',lname)) like concat('%',upper(?),'%') )";
				bindlist.add(new String[]{"STRING",filter_value});
			}
		} 
		
		if (filter_key.equals("search_copy_status")) {
			session.setAttribute("search_copy_status", filter_value);
			if (filter_value.trim().length()==0) 
				session.setAttribute("search_copy_status", "");
			else {
				filter_sql=filter_sql+" AND wpl.status=?";
				bindlist.add(new String[]{"STRING",filter_value});
			}
			
		}  
		
		if (filter_key.equals("search_copy_application")) {
			session.setAttribute("search_copy_application", filter_value);
			if (filter_value.trim().length()==0) 
				session.setAttribute("search_copy_application", "");
			else {
				filter_sql=filter_sql+" AND wpl.app_id=?";
				bindlist.add(new String[]{"INTEGER",filter_value});
			}
			
		}  
		
		if (filter_key.equals("search_copy_source_db")) {
			session.setAttribute("search_copy_source_db", filter_value);
			if (filter_value.trim().length()==0) 
				session.setAttribute("search_copy_source_db", "");
			else {
				filter_sql=filter_sql+" AND wpl.env_id=?";
				bindlist.add(new String[]{"INTEGER",filter_value});
			}
			
		}  
		
		if (filter_key.equals("search_copy_target_db")) {
			session.setAttribute("search_copy_target_db", filter_value);
			if (filter_value.trim().length()==0) 
				session.setAttribute("search_copy_target_db", "");
			else {
				filter_sql=filter_sql+" AND wpl.target_env_id=?";
				bindlist.add(new String[]{"INTEGER",filter_value});
			}
			
		} 
		
		
		
	}
	
	StringBuilder tmp=new StringBuilder(sql);
	int addi=tmp.indexOf("::ADDITIONALFILTERS::");
	tmp.delete(addi, addi+"::ADDITIONALFILTERS::".length());
	if (filter_sql.length()>0) tmp.insert(addi, filter_sql);
	
	sql=tmp.toString();
	

	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	
	
	sb.append("<table class=\"table table-striped table-condensed\">");
	sb.append("<tr>");
	
	sb.append("<td  colspan=15 >");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\"  onclick=startNewCopy()>");
	sb.append("<span class=\"glyphicon glyphicon-star-empty\"></span> Start New Copy");
	sb.append("</button> ");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\"  onclick=listMyCopyTasks()>");
	sb.append("<span class=\"glyphicon glyphicon-refresh\"></span>");
	sb.append("</button>");
	sb.append("</td>");

	sb.append("</tr>");
	
	sb.append("<tr class=info>");
	sb.append("<td><b>Id</b></td>");
	sb.append("<td><b>Task Name</b></td>");
	sb.append("<td><b>Created By</b></td>");
	sb.append("<td><b>Status</b></td>");
	sb.append("<td><b></b></td>"); //Error 
	sb.append("<td><b>Application</b></td>");
	sb.append("<td><b>Source</b></td>");
	sb.append("<td><b>Target</b></td>");
	sb.append("<td><b>Retrieved</b></td>");
	sb.append("<td><b>Copied</b></td>");
	sb.append("<td><b>Max#</b></td>");
	sb.append("<td><b>Repeat#</b></td>");
	
	sb.append("<td><b>Created@</b></td>");
	sb.append("<td><b>Start@</b></td>");
	sb.append("<td><b>Finish@</b></td>");
	
	sb.append("</tr>");
	
	sb.append("<tr class=warning>");
	
	sb.append("<td>"); //Id
	String search_copy_id=nvl((String) session.getAttribute("search_copy_id"),"");
	sb.append(makeText("search_copy_id", search_copy_id, "onchange=listMyCopyTasks()", 80));
	sb.append("</td>");
	
	
	sb.append("<td>"); //Task Name
	String search_copy_work_plan_name=nvl((String) session.getAttribute("search_copy_work_plan_name"),"");
	sb.append(makeText("search_copy_work_plan_name", search_copy_work_plan_name, "onchange=listMyCopyTasks()", 300));
	sb.append("</td>");
	
	sb.append("<td>"); //Created By
	String search_created_by=nvl((String) session.getAttribute("search_created_by"),"");
	sb.append(makeText("search_created_by", search_created_by, "onchange=listMyCopyTasks()", 120));
	sb.append("</td>");
	
	sb.append("<td>"); //Status
	ArrayList<String[]> statusArr=new ArrayList<String[]>();
	statusArr.add(new String[]{"NEW","New"});
	statusArr.add(new String[]{"RUNNING","Running"});
	statusArr.add(new String[]{"FINISHED","Finished"});
	String search_copy_status=nvl((String) session.getAttribute("search_copy_status"),"");
	sb.append(makeComboArr(statusArr, "", "id=search_copy_status onchange=listMyCopyTasks()", search_copy_status, 80));
	sb.append("</td>");
	
	sb.append("<td></td>"); //Max#
	
	sb.append("<td>"); //Application
	sql="select id, name from tdm_apps where app_type='COPY' order by 2";
	bindlist.clear();
	ArrayList<String[]> appArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	String search_copy_application=nvl((String) session.getAttribute("search_copy_application"),"");
	sb.append(makeComboArr(appArr, "", "id=search_copy_application onchange=listMyCopyTasks()", search_copy_application, 120));
	sb.append("</td>");
	
	
	sql="select id, name from tdm_envs order by 2";
	bindlist.clear();
	ArrayList<String[]> dbArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<td>"); //Source
	String search_copy_source_db=nvl((String) session.getAttribute("search_copy_source_db"),"");
	sb.append(makeComboArr(dbArr, "", "id=search_copy_source_db onchange=listMyCopyTasks()", search_copy_source_db, 120));
	sb.append("</td>");
	
	sb.append("<td>"); //Target
	String search_copy_target_db=nvl((String) session.getAttribute("search_copy_target_db"),"");
	sb.append(makeComboArr(dbArr, "", "id=search_copy_target_db onchange=listMyCopyTasks()", search_copy_target_db, 120));
	sb.append("</td>");
	
	
	sb.append("<td></td>"); //Max#
	sb.append("<td></td>"); //Repeat#
	sb.append("<td></td>"); //Retrieved
	sb.append("<td></td>"); //Copied
	sb.append("<td></td>"); //Created@
	sb.append("<td></td>"); //Start@
	sb.append("<td></td>"); //Finish@
	sb.append("</tr>");
	
	for (int i=0;i<arr.size();i++) {
		
		String work_plan_id=arr.get(i)[0];
		String work_plan_name=arr.get(i)[1];
		String created_by=arr.get(i)[2];
		String application_name=arr.get(i)[3];
		String source_db=arr.get(i)[4];
		String target_db=arr.get(i)[5];
		String create_date=arr.get(i)[6];
		String start_date=arr.get(i)[7];
		String end_date=arr.get(i)[8];
		String status=arr.get(i)[9];
		String copy_rec_count=formatnum(arr.get(i)[10]);
		String copy_repeat_count=formatnum(arr.get(i)[11]);
		String copy_retrieve_count=formatnum(arr.get(i)[12]);
		String copy_success_count=formatnum(arr.get(i)[13]);
		int err_count=Integer.parseInt(arr.get(i)[14]);
		String run_type=arr.get(i)[15];
		String dep_wpl_count=arr.get(i)[16];
		
		String stat_link="";
		if (err_count>0) 
			stat_link="<a href=\"javascript:rollbackCopyWorkPlan('"+work_plan_id+"')\"><font color=blue><big><span class=\"glyphicon glyphicon-fast-backward\"></span></big></font></a>"+
					  " "+
					  "<a href=\"javascript:showFailedWorkPackageList('"+work_plan_id+"')\"><font color=red><big><span class=\"glyphicon glyphicon-warning-sign\"></span></big></font></a>"+
					  " "+
					  "<a href=\"javascript:showCopySummary('"+work_plan_id+"')\"><font color=black><big><span class=\"glyphicon glyphicon-film\"></span></big></font></a> ";
					  
		if (status.equals("FINISHED") && !run_type.equals("ROLLBACK") && err_count==0) {
			stat_link="<a href=\"javascript:rollbackCopyWorkPlan('"+work_plan_id+"')\"><font color=blue><big><span class=\"glyphicon glyphicon-fast-backward\"></span></big></font></a>"+
					  " "+
					  "<a href=\"javascript:showCopySummary('"+work_plan_id+"')\"><font color=black><big><span class=\"glyphicon glyphicon-film\"></span></big></font></a> ";
						
		}
		if (status.equals("RUNNING"))
			stat_link=
					  "<a href=\"javascript:showCopySummary('"+work_plan_id+"')\"><font color=black><big><span class=\"glyphicon glyphicon-film\"></span></big></font></a> ";
		if (status.equals("FINISHED") && run_type.equals("ROLLBACK")) 
			status="ROLLEDBACK";
		//if (( status.equals("FINISHED")) && err_count==0 )
		//	stat_link="<font color=lightgreen><big><span class=\"glyphicon glyphicon-ok\"></span></big></font>";

		if (copy_rec_count.equals(formatnum("2147483647"))) copy_rec_count="[<b>All</b>]";
		
		
		sb.append("<tr>");
		
		sb.append("<td align=right><small><b>"+work_plan_id+"</b></small></td>");
		sb.append("<td><small>"+work_plan_name+"</small></td>");
		sb.append("<td><small>"+created_by+"</small></td>");
		
		if (status.equals("NEW") && !dep_wpl_count.equals("0")) 
			sb.append("<td><small>Waiting [<a href=\"javascript:showWaitingWorkPlanList('"+work_plan_id+"')\"><b>"+dep_wpl_count+"</b></a>] Task(s)...</small></td>");
		else 
			sb.append("<td><small>"+status+"</small></td>");
		
		sb.append("<td align=right nowrap>"+stat_link+"</td>");
		sb.append("<td><small>"+application_name+"</small></td>");
		sb.append("<td><small>"+source_db+"</small></td>");
		sb.append("<td><small>"+target_db+"</small></td>");
		sb.append("<td align=right><small>"+copy_retrieve_count+"</small></td>");
		sb.append("<td align=right><small>"+copy_success_count+"</small></td>");
		sb.append("<td align=right><small>"+copy_rec_count+"</small></td>");
		sb.append("<td align=right><small>"+copy_repeat_count+"</small></td>");
		sb.append("<td align=right><small>"+create_date+"</small></td>");
		sb.append("<td align=right><small>"+start_date+"</small></td>");
		sb.append("<td align=right><small>"+end_date+"</small></td>");
		
		sb.append("</tr>");
	}
	
	sb.append("</table>");
	
	return sb.toString();
}
//-------------------------------------------------------
ArrayList<String[]> getAvailableCopyDbList(Connection conn, HttpSession session, String app_id, String kind) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select id, target_name from tdm_target order by 2";
	
	if (!checkrole(session, "ADMIN")) {
		sql="select id, target_name from tdm_target \n"+
				" where id in \n"+
				" ( \n"+
				" select env_id from tdm_group_environments "+
				" where env_type=? and group_id in \n"+
						"(select group_id from tdm_group_members where member_id=?) \n"+
				") \n"+
				" order by 2";
		
		String curruser=""+((Integer) session.getAttribute("userid"));
		
		
		bindlist.add(new String[]{"STRING",kind});
		bindlist.add(new String[]{"INTEGER",curruser});
	}
	
	
	
	ret1=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	return ret1;
}

//-------------------------------------------------------
ArrayList<String[]> getAvailableFilterList(Connection conn, HttpSession session, String app_id) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	String sql="select id, filter_name from tdm_copy_filter where app_id=? order by 2";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	ret1=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	return ret1;
}

//-------------------------------------------------------
String getDbIdFromFilter(Connection conn, HttpSession session, String target_id, String filter_id) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select env_id from \n"+
				"	tdm_target_family_env fe, tdm_tabs t , tdm_copy_filter cf \n"+
				"	where  \n"+
				"	cf.id=? and target_id=? \n"+ 
				"	and cf.tab_id=t.id \n"+
				"	and t.family_id=fe.family_id";
	
	bindlist.add(new String[]{"INTEGER",filter_id});
	bindlist.add(new String[]{"INTEGER",target_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) return "0";
	
	return arr.get(0)[0];

}
//-------------------------------------------------------
String fillCopyFilterVals(Connection conn, HttpSession session, String app_id, String filter_id, String source_env_id, String target_env_id, String filter_value) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select id, filter_name, filter_type, filter_sql, "+
				" format_1, format_2, list_id_1, list_id_2, " +
				" list_source_1, list_source_2 " +
				" from tdm_copy_filter where app_id=? and id=? ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"INTEGER",filter_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	if (arr==null || arr.size()==0) {
		return "Select a filter.";
	}
	
	String 	filter_name=arr.get(0)[1];
	String 	filter_type=arr.get(0)[2];
	String 	filter_sql=arr.get(0)[3];
	String 	format_1=arr.get(0)[4];
	String 	format_2=arr.get(0)[5];
	String 	list_id_1=arr.get(0)[6];
	String 	list_id_2=arr.get(0)[7];
	String 	list_source_1=arr.get(0)[8];
	String 	list_source_2=arr.get(0)[9];
	
	StringBuilder filter_cols=new StringBuilder();
	
	String filter_value_1="";
	String filter_value_2="";
	
	try {filter_value_1=filter_value.split("\\+\\+")[0];} catch(Exception e) {filter_value_1="";}
	try {filter_value_2=filter_value.split("\\+\\+")[1];} catch(Exception e) {filter_value_2="";}


	 
	if (filter_type.equals("SINGLE_NUMBER") || filter_type.equals("BETWEEN_NUMBER")) 
	{
		format_1="^(([0-9]*)|(([0-9]*).([0-9]*)))$";
		format_2=format_1;
	}
	
	sb.append("<input type=hidden id=filter_type value=\""+filter_type+"\">");
	
	sb.append("<input type=hidden id=filter_format_1 value=\""+codehtml(format_1)+"\">");
	sb.append("<input type=hidden id=filter_format_2 value=\""+codehtml(format_2)+"\">");
	
	
	sb.append("<input type=hidden id=validation_result_1 value=\"YES\">");
	sb.append("<input type=hidden id=validation_result_2 value=\"YES\">");
	
	
	if (filter_type.equals("SINGLE_STRING") || filter_type.equals("BETWEEN_STRING") || filter_type.equals("SINGLE_NUMBER") || filter_type.equals("BETWEEN_NUMBER")) 
	{
		
		filter_cols.append("<td nowrap>"); 
		if (filter_type.equals("BETWEEN_STRING")|| filter_type.equals("BETWEEN_NUMBER")) 
			filter_cols.append("Between<br>");
		filter_cols.append(makeText("val_1", filter_value_1, "onchange=checkFormat(this,'1')", 0));
		filter_cols.append("</td>");
	}
	
	if (filter_type.equals("BETWEEN_STRING") || filter_type.equals("BETWEEN_NUMBER")){
		filter_cols.append("<td>"); 
		filter_cols.append("And ");
		filter_cols.append(makeText("val_2", filter_value_2, "onchange=checkFormat(this,'2')", 0));		
		filter_cols.append("</td>");
	}
	

	if (filter_type.equals("SINGLE_DATE") || filter_type.equals("BETWEEN_DATE")) {
		filter_cols.append("<td nowrap>"); 
		if (filter_type.equals("BETWEEN_DATE")) 
			filter_cols.append("Between<br> ");
		filter_cols.append(makeDate("", "val_1", filter_value_1, ""));
		filter_cols.append("</td>");
	}
	
	if (filter_type.equals("BETWEEN_DATE")){
		filter_cols.append("<td>"); 
		filter_cols.append("And<br> ");
		filter_cols.append(makeDate("", "val_2", filter_value_2, ""));
		filter_cols.append("</td>");
	}
	
	
	if (filter_type.equals("SINGLE_LIST") || filter_type.equals("BETWEEN_LIST")) {
		filter_cols.append("<td nowrap>"); 
		if (nvl(list_id_1,"0").equals("0")) {
			filter_cols.append("<font color=red>List configuration is missing!!!</font>");
		}
		else {
			if (filter_type.equals("BETWEEN_LIST"))
				filter_cols.append("Between<br> ");
			
			ArrayList<String[]> listArr=new ArrayList<String[]>();
			
			if (list_source_1.equals("STATIC")) {
				sql="select list_val from tdm_list_items where list_id="+list_id_1;
				listArr=getDbArrayConf(conn, sql, 1000, new ArrayList<String[]>());
				for (int l=0;l<listArr.size();l++) {	
					if (listArr.get(l)[0].contains("|::|")) 
						listArr.set(l
								, 
								new String[]{
								listArr.get(l)[0].split("\\|::\\|")[0],
								listArr.get(l)[0].split("\\|::\\|")[1]
										}
						);
						}
				} //if (list_source_1.equals("STATIC"))
				else {
					String list_db_id="0";
					
					
					if (list_source_1.equals("SOURCE") && !source_env_id.equals("0")) {
						list_db_id=getDbIdFromFilter(conn, session, source_env_id, filter_id);
					}
					
					if (list_source_1.equals("TARGET") && !target_env_id.equals("0"))  {
						list_db_id=getDbIdFromFilter(conn, session, target_env_id, filter_id);
					}
					
					System.out.println("list_db_id="+list_db_id);
					
					sql="select sql_statement from tdm_list where id=?";
					bindlist.clear();
					bindlist.add(new String[]{"INTEGER",list_id_1});
					arr=getDbArrayConf(conn, sql, 1, bindlist);
					
					if (arr!=null && arr.size()==1) {
						String list_sql=arr.get(0)[0];
						listArr=getDbArrayApp(conn, list_db_id, list_sql, 1000, new ArrayList<String[]>());
					}
				}
				
				
			filter_cols.append(makeComboArr(listArr, "", "size=1 id=val_1", filter_value_1, 0));
			
			}
			
		filter_cols.append("</td>");
		}
	
	
	if (filter_type.equals("BETWEEN_LIST")){
		filter_cols.append("<td>"); 
		if (nvl(list_id_2,"0").equals("0")) {
			filter_cols.append("<font color=red>List configuration is missing!!!</font>");
		}
		else {
			if (filter_type.equals("BETWEEN_LIST"))
				filter_cols.append("And<br> ");
			
			ArrayList<String[]> listArr=new ArrayList<String[]>();
			
			if (list_source_2.equals("STATIC")) {
				sql="select list_val from tdm_list_items where list_id="+list_id_2;
				listArr=getDbArrayConf(conn, sql, 1000, new ArrayList<String[]>());
				for (int l=0;l<listArr.size();l++) {
					
					if (listArr.get(l)[0].contains("|::|")) 
						listArr.set(l
								, 
								new String[]{
								listArr.get(l)[0].split("\\|::\\|")[0],
								listArr.get(l)[0].split("\\|::\\|")[1]
										}
						);
						}
			} //list_source_2.equals("STATIC")
			else {
					String list_db_id="0";
					
					if (list_source_2.equals("SOURCE") && !source_env_id.equals("0")) 
						list_db_id=getDbIdFromFilter(conn, session, source_env_id, filter_id);
					
					if (list_source_2.equals("TARGET") && !target_env_id.equals("0"))  
						list_db_id=getDbIdFromFilter(conn, session, target_env_id, filter_id);
					
					sql="select sql_statement from tdm_list where id=?";
					bindlist.clear();
					bindlist.add(new String[]{"INTEGER",list_id_2});
					arr=getDbArrayConf(conn, sql, 1, bindlist);
					
					if (arr!=null && arr.size()==1) {
						String list_sql=arr.get(0)[0];
						listArr=getDbArrayApp(conn, list_db_id, list_sql, 1000, new ArrayList<String[]>());
					}
				}
			
				
			filter_cols.append(makeComboArr(listArr, "", "size=1 id=val_2", filter_value_2, 0));
		}
		filter_cols.append("</td>");
	}
	
	
	/*
	if (filter_type.equals("BY_PARTITION")){
		filter_cols.append("<td>"); 
		filter_cols.append("Partition to copy ");
		sql="select concat(cat_name,'.',schema_name,'.',tab_name), family_id from tdm_tabs where id=(select tab_id from tdm_copy_filter where id="+filter_id+")";
		//String table_name=getDBSingleVal(conn, sql);
		ArrayList<String[]> partArr=getDbArrayConf(conn, sql, 1, null);
		String table_name=partArr.get(0)[0];
		String family_id=partArr.get(0)[1];
		
		partArr=getPartitionList(conn, source_env_id, family_id, table_name);
		
		if (partArr.size()==0) 
			filter_cols.append("<br><font color=red>Partition list cannot be fetched or empty!!!</font>");
		else
			filter_cols.append(makeComboArr(partArr, "", "id=val_1", filter_value_1, 0));
		filter_cols.append("</td>");
	}
	*/
	
	
	if (filter_type.equals("BY_PARTITION")){
		filter_cols.append("<td>"); 


		sql="select id, replace(concat(cat_name,'.',schema_name,'.',tab_name),'${default}.','') from tdm_tabs where app_id=? order by 2";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",app_id});
	    ArrayList<String[]> tabArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	    
	    
		if (tabArr.size()==0) {
			filter_cols.append("<br><font color=red>no table to copy!!!</font>");
		}
		else {
			filter_cols.append("<table>");
			
			filter_cols.append("<tr>");
			filter_cols.append("<td nowrap align=right><font color=red>Select Table To Copy :</font></td>");
			filter_cols.append("<td width=\"100%\">");
			filter_cols.append(makeComboArr(tabArr, "", "id=val_1 onchange=onPartitionTableChange('"+app_id+"',this); ", "", 0));
			filter_cols.append("</td>");
			filter_cols.append("</tr>");
			
			filter_cols.append("<tr>");
			filter_cols.append("<td nowrap align=right><font color=red>Partition : </font></td>");
			filter_cols.append("<td width=\"100%\">");
			
			filter_cols.append("<div id=partitionListDiv>");
			
			String partition_tab_id="0";
			filter_cols.append(makePartitionListForTable(conn, session, source_env_id, partition_tab_id));
			
			
			filter_cols.append("</div>");
			
			filter_cols.append("</td>");
			filter_cols.append("</tr>");
			
			filter_cols.append("</table>");
		}
		
		filter_cols.append("</td>");
	}
	
	
	
	if (filter_type.equals("MANUAL_CONDITION")){
		filter_cols.append("<td>"); 


		sql="select id, replace(concat(cat_name,'.',schema_name,'.',tab_name),'${default}.','') from tdm_tabs where app_id=? order by 2";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",app_id});
	    ArrayList<String[]> tabArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	    
	    
		if (tabArr.size()==0) {
			filter_cols.append("<br><font color=red>no table to copy!!!</font>");
		}
		else {
			filter_cols.append("<table>");
			
			filter_cols.append("<tr>");
			filter_cols.append("<td nowrap align=right><font color=red>Select Table To Copy :</font></td>");
			filter_cols.append("<td width=\"100%\">");
			filter_cols.append(makeComboArr(tabArr, "", "id=val_1 onchange=onManualConditionChange('"+app_id+"',this)", "", 0));
			filter_cols.append("</td>");
			filter_cols.append("</tr>");
			
			filter_cols.append("<tr>");
			filter_cols.append("<td nowrap align=right><font color=red>Condition , Where :  ...</font></td>");
			filter_cols.append("<td width=\"100%\">");
			filter_cols.append("<textarea id=val_2 style=\"width:100%;\" >");
			filter_cols.append("</textarea>");
			filter_cols.append("</td>");
			filter_cols.append("</tr>");
			
			filter_cols.append("</table>");
		}
		
		filter_cols.append("</td>");
	}
	
	sb.append("<table class=\"table\">");
	sb.append("<tr class=info>");
	sb.append(filter_cols.toString());
	sb.append("</tr>");
	sb.append("</table>");
	
	
	return sb.toString();
}


//-------------------------------------------------------
String makePartitionListForTable(Connection conn, HttpSession session, String source_env_id, String partition_tab_id) {
	
	StringBuilder sb=new StringBuilder();

	String sql="select concat(cat_name,'.',schema_name,'.',tab_name), family_id from tdm_tabs where id="+partition_tab_id;
	//String table_name=getDBSingleVal(conn, sql);
	ArrayList<String[]> partArr=getDbArrayConf(conn, sql, 1, null);
	
	if (partArr.size()==0) 
		sb.append("<font color=blue>Pick a table for partition list</font>");
	else {
		String table_name=partArr.get(0)[0];
		String family_id=partArr.get(0)[1];
		
		partArr=getPartitionList(conn, source_env_id, family_id, table_name);
		
		if (partArr.size()==0) 
			sb.append("<font color=red>Partition list cannot be fetched or empty!!!</font>");
		else
			sb.append(makeComboArr(partArr, "", "id=val_2", "", 0));
	}
	
	return sb.toString();
}

//-------------------------------------------------------
ArrayList<String[]> compileTabListInApp(Connection conn, HttpSession session,String app_id, String condition_tab_id) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	ArrayList<String[]> appTables=new ArrayList<String[]>();
	
	String sql="";
	
	sql="select rel_app_id from tdm_apps_rel where app_id=? order by rel_order";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	ArrayList<String[]> relAppArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	for (int i=0;i<relAppArr.size();i++) {
		String rep_app_id=relAppArr.get(i)[0];
		
		appTables.addAll(compileTabListInApp(conn,  session, rep_app_id,condition_tab_id));
	}
	
	
	sql="select id, cat_name, schema_name, tab_name,  id, family_id from tdm_tabs where app_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	if (!condition_tab_id.equals("ALL") && !condition_tab_id.equals("undefined")) {
		sql=sql+" and id=?";
		bindlist.add(new String[]{"INTEGER",condition_tab_id});
	}
	ArrayList<String[]> mainTables=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	ArrayList<Integer> loopCheck=new ArrayList<Integer>();
	
	for (int i=0;i<mainTables.size();i++) {
		String tab_id=mainTables.get(i)[0];
		String source_catalog=mainTables.get(i)[1];	
		String source_schema=mainTables.get(i)[2];	
		String source_table=mainTables.get(i)[3];
		String needed_app_id=app_id;
		String family_id=mainTables.get(i)[5];
		
		appTables.add(new String[]{tab_id, source_catalog, source_schema,source_table, needed_app_id, family_id});
		
		ArrayList<String[]> neededTabArr=getNeededTables(conn, app_id, tab_id, loopCheck, true);
		
		appTables.addAll(neededTabArr);
		
		
	}
	
	
	//clear duplicates
	ArrayList<String> dupCheck=new ArrayList<String>();
	
	for (int i=appTables.size()-1;i>=0;i--) {
		String tab_id=appTables.get(i)[0];
		String cat=appTables.get(i)[1];
		String schema=appTables.get(i)[2];
		String tab_name=appTables.get(i)[3];
		String needed_app_id=appTables.get(i)[4];
		String family=appTables.get(i)[5];
		
		String checkstr=cat+"."+schema+"."+tab_name+"@"+family;
		if (dupCheck.indexOf(checkstr)==-1) {
			dupCheck.add(checkstr);
			continue;
		}
		
		appTables.remove(i);
		
	}
	
	return appTables;
}

//-------------------------------------------------------
String getCopyAppLevel(Connection conn, HttpSession session, String app_id) {
	String level="SINGLELEVEL";
	String sql="select 1 from tdm_tabs_rel where tab_id in (select id from tdm_tabs where app_id =?)";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);

	if (arr!=null && arr.size()==1) level="MULTILEVEL";
	
	return level;
}

//-------------------------------------------------------
String fillTargetInfo(Connection conn, HttpSession session, String app_id, String source_id, String target_id, String condition_tab_id) {
	
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sb.append("<table class=\"table table-condensed\" border=0");
	
	sb.append("<tr class=active>");
	sb.append("<td colspan=3 align=center><b>Source</b></td>");
	sb.append("<td colspan=3 align=center><b>Target</b></b></td>");
	sb.append("</tr>");
	
	/*
	String copy_level="SINGLELEVEL";
	
	
	sql="select count(*) from tdm_tabs_rel where tab_id in (select id from tdm_tabs where app_id =?)";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	int relcount=0;
	try {relcount=Integer.parseInt(getDbArrayConf(conn, sql, 1, bindlist).get(0)[0]);} catch(Exception e) {e.printStackTrace();}
	if (relcount>1) copy_level="MULTILEVEL";
	*/
	String copy_level=getCopyAppLevel(conn,session,app_id);
	
	ArrayList<String[] >appTables=compileTabListInApp(conn,session,app_id, condition_tab_id);
	
	ArrayList<String[]> ownerList=new ArrayList<String[]>();
	ArrayList<String[]> newOwnerList=new ArrayList<String[]>();
	
	
	ArrayList<String[]> arr=new ArrayList<String[]>();

	for (int i=0;i<appTables.size();i++) {
		String source_tab_id=appTables.get(i)[0];
		String source_catalog=appTables.get(i)[1];	
		String source_schema=appTables.get(i)[2];	
		String source_table=appTables.get(i)[3];
		String needed_app_id=appTables.get(i)[4];
		String family_id=appTables.get(i)[5];
		
		String source_db_id="";
		String target_db_id="";
		
		String source_db_name="";
		String target_db_name="";
		
		
		
		sql="select env_id, name from tdm_target_family_env fae, tdm_envs e where target_id=? and family_id=? and env_id=e.id";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",source_id});
		bindlist.add(new String[]{"INTEGER",family_id});
		
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		if (arr!=null && arr.size()==1) {
			source_db_id=arr.get(0)[0];
			source_db_name=arr.get(0)[1];
		}
		
		sql="select env_id, name from tdm_target_family_env fae, tdm_envs e where target_id=? and family_id=? and env_id=e.id";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",target_id});
		bindlist.add(new String[]{"INTEGER",family_id});
		
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		if (arr!=null && arr.size()==1) {
			target_db_id=arr.get(0)[0];
			target_db_name=arr.get(0)[1];
		}
		
		StringBuilder errmsg=new StringBuilder();
		
		
		System.out.println("Getting schema list for source env_id : "+source_db_id);
		
		ownerList=getDesignerSchemaList(conn, session, source_db_id, "All", errmsg);
		if (errmsg.length()>0) 
			System.out.println("Error@getSource schemas for copy"+errmsg.toString());
		
		
		System.out.println("Getting schema list for target env_id : "+target_db_id);
		
		newOwnerList=getDesignerSchemaList(conn, session, target_db_id, "All", errmsg);
		if (errmsg.length()>0) 
			System.out.println("Error@getSource schemas for copy"+errmsg.toString());
		
		
		sb.append("<input type=hidden id=orig_table_name_"+i+" value=\""+source_catalog+"."+source_schema+"."+source_table+"\">");
		sb.append("<input type=hidden id=orig_table_id_"+i+" value=\""+source_tab_id+"\">");

		sb.append("<tr>");
		sb.append("<td class=warning>");
		sb.append(nvl(source_db_name, "No DB Family Set"));
		sb.append("</td>");

		sb.append("<td class=warning>");
		sb.append(makeComboArr(ownerList, "", "readonly id=source_schema_"+i, source_catalog+"."+source_schema, 120));
		sb.append("</td>");
		sb.append("<td class=warning>");
		sb.append("<input disabled type=text size=24 id=source_table_"+i+" value=\""+source_table+"\" maxlength=50>");
		sb.append("</td>");
		
		sb.append("<td class=success>");
		sb.append(nvl(target_db_name, "No DB Family Set"));
		sb.append("</td>");

		
		sb.append("<td class=success>");
		sb.append("<input type=hidden id=original_target_schema_"+i+" value=\""+source_schema+"\">");
		sb.append(makeComboArr(newOwnerList, "", "onchange=\"checkAndChangeAllTargets(this,'"+i+"')\" id=target_schema_"+i, source_catalog+"."+source_schema, 120));
		sb.append("</td>");
		
		
		
		
		sb.append("<td class=success>");
		if (copy_level.equals("MULTILEVEL"))
			sb.append("<input disabled type=text size=24 id=target_table_"+i+"  value=\""+source_table+"\" maxlength=50>");
		else
			sb.append("<input type=text size=24 id=target_table_"+i+"  value=\""+source_table+"\" maxlength=50>");
		sb.append("</td>");
		
		sb.append("</tr>");
	}
	
	sb.append("</table>");
	
	return sb.toString();
}

//------------------------------------------------------------------------------------
ArrayList<String[]> getNeededTables(Connection conn, String app_id, String needing_tab_id, ArrayList<Integer> loopCheckArr, boolean getRecursive) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	String sql="";
	
	if (loopCheckArr.indexOf(Integer.parseInt(needing_tab_id))>-1) {
		return ret1;
	}
	
	loopCheckArr.add(Integer.parseInt(needing_tab_id));
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select t.id, cat_name, schema_name, tab_name, n.app_id, family_id \n" + 
		"	from tdm_tabs_need n, tdm_tabs t  \n" + 
		"	where n.app_id=t.app_id \n" + 
		"	and tab_id=?" ;
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",needing_tab_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	for (int i=0;i<arr.size();i++) {
		String needed_tab_id=arr.get(i)[0];
		String catalog_name=arr.get(i)[1];
		String schema_name=arr.get(i)[2];
		String tab_name=arr.get(i)[3];
		String needing_app_id=arr.get(i)[4];
		String family_id=arr.get(i)[5];
		
		ret1.add(new String[]{needed_tab_id, catalog_name, schema_name,tab_name,needing_app_id, family_id});
		
		if (getRecursive)
			ret1.addAll(getNeededTables(conn, needing_app_id, needed_tab_id,loopCheckArr, true));
		
	}
	
	return ret1;
}

//------------------------------------------------------------------------------------
ArrayList<String> getUserListByGroup(Connection conn, HttpSession session, String group_id) {
	ArrayList<String> ret1=new ArrayList<String>();
	
	String sql="select member_id  from tdm_group_members where group_id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	for (int i=0;i<arr.size();i++) {
		String member_id=arr.get(i)[0];
		
		ret1.add(member_id);
	}
	
	return ret1;
}
//------------------------------------------------------------------------------------
int assignDeassignRoleToGroup(Connection conn, HttpSession session, String group_id, String role_id, String action) {
	int ret1=0;
	
	ArrayList<String> userList=getUserListByGroup(conn, session, group_id);
	
	String sql="select  1 from tdm_user_role where user_id=? and role_id=?";
	String insert_sql="insert into tdm_user_role (user_id, role_id) values (?,?)";
	if (action.equals("REVOKE"))
		insert_sql="delete from tdm_user_role where user_id=? and role_id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> arr=new ArrayList<String[]>();
	
	for (int i=0;i<userList.size();i++) {
		String user_id=userList.get(i);
		System.out.println("user_id : " + user_id);
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",user_id});
		bindlist.add(new String[]{"INTEGER",role_id});
		
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		if (action.equals("GRANT") && arr!=null && arr.size()==1) continue;
		
		if (action.equals("REVOKE") && arr!=null && arr.size()==0) continue;

		ret1++;
		
		execDBConf(conn, insert_sql, bindlist);
		
		
	}
	
	return ret1;
}


//********************************************************************************
void addRemoveGroupMember(
		Connection conn,
		HttpSession session,
		String group_id,
		String addremove,
		String member_id) {
	
	String sql="insert into tdm_group_members (group_id,member_id) values (?,?)";
	if (addremove.equals("REMOVE"))
		sql="delete from tdm_group_members where group_id=? and member_id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",group_id});
	bindlist.add(new String[]{"INTEGER",member_id});
	
	execDBConf(conn, sql, bindlist);
	
}

//********************************************************************************
void addRemoveGroupEnvironment(
		Connection conn,
		HttpSession session,
		String group_id,
		String addremove,
		String environment_id,
		String env_type
		) {
	
	String sql="insert into tdm_group_environments (group_id,env_id,env_type) values (?,?,?)";
	if (addremove.equals("REMOVE"))
		sql="delete from tdm_group_environments where group_id=? and env_id=? and env_type=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",group_id});
	bindlist.add(new String[]{"INTEGER",environment_id});
	bindlist.add(new String[]{"STRING",env_type});
	
	execDBConf(conn, sql, bindlist);
	
}

//********************************************************************************
void addRemoveGroupCopyApplication(
		Connection conn,
		HttpSession session,
		String group_id,
		String addremove,
		String application_id
		) {
	
	String sql="insert into tdm_group_applications (group_id,app_id) values (?,?)";
	if (addremove.equals("REMOVE"))
		sql="delete from tdm_group_applications where group_id=? and app_id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",group_id});
	bindlist.add(new String[]{"INTEGER",application_id});
	
	execDBConf(conn, sql, bindlist);
	
}


//********************************************************************************
void addRemoveUserMembership(
		Connection conn,
		HttpSession session,
		String user_id,
		String addremove,
		String group_id) {
	
	String sql="insert into tdm_group_members (group_id, member_id) values (?,?)";
	if (addremove.equals("REMOVE"))
		sql="delete from tdm_group_members where group_id=? and member_id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",group_id});
	bindlist.add(new String[]{"INTEGER",user_id});
	
	execDBConf(conn, sql, bindlist);
	
}


//******************************************************************
String makeTableNeedForm(Connection conn,HttpSession session,String tabid, String need_id) {

	StringBuilder sb=new StringBuilder();
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String curr_need_id=need_id;
	String curr_app_id="";
	String curr_filter_id="";
	String curr_rel_on_fields="";
	
	if (!curr_need_id.equals("0")) {
		sql="select app_id, copy_filter_id, rel_on_fields from tdm_tabs_need where id=?";


		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",need_id});
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		if (arr!=null && arr.size()==1) {
			curr_app_id=arr.get(0)[0];
			curr_filter_id=arr.get(0)[1];
			curr_rel_on_fields=arr.get(0)[2];
		}
	}
	
	
	
	
	sql="select id, name from tdm_apps where app_type='COPY' order by 2";
	bindlist.clear();
	ArrayList<String[]> appList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select field_name from tdm_fields where tab_id=? order by 1";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",tabid});
	ArrayList<String[]> fieldList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	sb.append("<input type=hidden id=current_need_id value=\""+need_id+"\">");
	sb.append("<input type=hidden id=current_need_tab_id value=\""+tabid+"\">");
	
	sql="select concat(schema_name, '.', tab_name) from tdm_tabs where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",tabid});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	String tab_name="";
	if (arr.size()==1) tab_name=arr.get(0)[0];
	
	sb.append("<h4>[<b>"+tab_name+"</b>] Needs </h4>");
	sb.append("<hr>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\"><span class=badge>Needed Application : </span></div>");
	sb.append("<div class=\"col-md-12\">");
	sb.append(makeComboArr(appList, "", "id=need_app_id onchange=fillNeedFilterList()", curr_app_id, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\"><span class=badge>On Filter : </span></div>");
	sb.append("<div class=\"col-md-12\" id=needFilterListDiv>");
	sb.append(makeNeedFilterList(conn, session, nvl(curr_app_id,"0"), nvl(curr_filter_id,"0")));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\"><span class=badge>On Field : </span></div>");
	sb.append("<div class=\"col-md-12\">");
	sb.append(makeComboArr(fieldList, "", "id=need_rel_on_fields", curr_rel_on_fields, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	return sb.toString();
	
}
//******************************************************************
String makeNeedFilterList(Connection conn, HttpSession session, String app_id, String filter_id) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select id, filter_name from tdm_copy_filter where app_id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append(makeComboArr(arr, "", "id=need_filter_id", filter_id, 0));
	
	return sb.toString();
}
//******************************************************************
void removeTableNeed(Connection conn,HttpSession session, String need_id) {
	String sql="delete from tdm_tabs_need where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",need_id});
	
	execDBConf(conn, sql, bindlist);
	
	
}

//*****************************************************************
String  saveNeed(
		Connection conn, 
		String need_id, 
		String need_tab_id, 
		String need_app_id, 
		String need_filter_id, 
		String need_rel_on_fields) {
	
	String sql="update tdm_tabs_need set app_id=?, copy_filter_id=?, rel_on_fields=? where id=?";
	
	if (need_id.equals("0")) 
		sql="insert into tdm_tabs_need (app_id,copy_filter_id,rel_on_fields,tab_id) values (?,?,?,?)";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",need_app_id});
	bindlist.add(new String[]{"INTEGER",need_filter_id});
	bindlist.add(new String[]{"STRING",need_rel_on_fields});
	
	if (!need_id.equals("0")) 
		bindlist.add(new String[]{"INTEGER",need_id});
	else 
		bindlist.add(new String[]{"INTEGER",need_tab_id});
	
	execDBConf(conn, sql, bindlist);
	
	String field_id="";
	
	sql="select id from tdm_fields where tab_id=? and field_name=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",need_tab_id});
	bindlist.add(new String[]{"STRING",need_rel_on_fields});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr!=null && arr.size()==1) {
		 field_id=arr.get(0)[0];
		 
		//find mask prof id for reference 
		String copy_ref_mask_prof_id="0";
		sql="select id from tdm_mask_prof where rule_id='COPY_REF'";
		bindlist.clear();
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		if (arr!=null && arr.size()==1) 
			copy_ref_mask_prof_id=arr.get(0)[0];
		
		//find root table of needed app
		sql="select t.id from tdm_tabs t where app_id=? " +  
			"	and not exists (select 1 from tdm_tabs_rel where rel_tab_id=t.id)";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",need_app_id});
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		if (arr!=null && arr.size()==1) {
			String app_root_table_id=arr.get(0)[0];
			
			sql="select field_name from tdm_fields where tab_id=? and is_pk='YES'";
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",app_root_table_id});
			arr=getDbArrayConf(conn, sql, 1, bindlist);
			if (arr!=null && arr.size()==1) {
				String app_root_table_pk_field_name=arr.get(0)[0];
				
				sql="update tdm_fields set mask_prof_id=?, is_conditional=?, copy_ref_tab_id=?, copy_ref_field_name=? where id=?";
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",copy_ref_mask_prof_id});
				bindlist.add(new String[]{"STRING","NO"});
				bindlist.add(new String[]{"INTEGER",app_root_table_id});
				bindlist.add(new String[]{"STRING",app_root_table_pk_field_name});
				bindlist.add(new String[]{"INTEGER",field_id});
				
				execDBConf(conn, sql, bindlist);
			}
			
			
		}
			

		
			
	}
	  
	
	
	
	   
	
	return field_id;
	
	
}


//**************************************************************************
boolean removeDatabase(Connection conn, HttpSession session, String id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from tdm_target_family_env where env_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) return false;
	
	
	sql="select 1 from tdm_work_plan where env_id=? limit 0,1";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) return false;
	
	
	sql="select 1 from tdm_work_plan where target_env_id=? limit 0,1";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) return false;
	
	
	sql="delete from tdm_envs where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	boolean is_ok=execDBConf(conn, sql, bindlist);
	
	return is_ok;
}



//**************************************************************************
boolean removePolicyGroup(Connection conn, HttpSession session, String id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from tdm_proxy_exception where policy_group_id=?"+
		" union all "+
		"select 1 from tdm_proxy_monitoring_policy_group where policy_group_id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	bindlist.add(new String[]{"INTEGER",id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) return false;
	
	
	
	
	
	sql="delete from tdm_proxy_policy_group where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	boolean is_ok=execDBConf(conn, sql, bindlist);
	
	return is_ok;
}


//**************************************************************************
boolean removeCalendar(Connection conn, HttpSession session, String id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from tdm_proxy_param_override where calendar_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) return false;
	
	boolean is_ok=false;
	
	sql="delete from tdm_proxy_calendar_exception where calendar_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	is_ok=execDBConf(conn, sql, bindlist);
	if (!is_ok) return false;
	
	sql="delete from tdm_proxy_calendar where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	is_ok=execDBConf(conn, sql, bindlist);
	
	return is_ok;
}

//**************************************************************************
boolean removeSessionValidation(Connection conn, HttpSession session, String id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from tdm_proxy_param_override where session_validation_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) return false;
	
	boolean is_ok=false;
	
	sql="delete from tdm_proxy_session_validation where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	return execDBConf(conn, sql, bindlist);
	
}
//**************************************************************************
boolean removeMonitoring(Connection conn, HttpSession session, String id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();

	boolean is_ok=false;
	
	sql="delete from tdm_proxy_monitoring_policy_group where monitoring_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	is_ok=execDBConf(conn, sql, bindlist);
	if (!is_ok) return false;	
	
	sql="delete from tdm_proxy_monitoring_application where monitoring_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	is_ok=execDBConf(conn, sql, bindlist);
	if (!is_ok) return false;
	
	sql="delete from tdm_proxy_monitoring_policy_rules where monitoring_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	is_ok=execDBConf(conn, sql, bindlist);
	if (!is_ok) return false;
	
	sql="delete from tdm_proxy_monitoring where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	return execDBConf(conn, sql, bindlist);
	
}
//**************************************************************************
void removeCalendarException(Connection conn, HttpSession session, String id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	sql="delete from tdm_proxy_calendar_exception where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	execDBConf(conn, sql, bindlist);
	
}

//**************************************************************************
boolean removeTarget(Connection conn, HttpSession session, String id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from tdm_work_plan where env_id=? or target_env_id=? and wplan_type='COPY2' limit 0,1";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	bindlist.add(new String[]{"INTEGER",id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) return false;
	
	
	sql="delete from tdm_target_family_env where target_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	execDBConf(conn, sql, bindlist);
	
	sql="delete from tdm_target where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	execDBConf(conn, sql, bindlist);
	
	return true;
}

//**************************************************************************
boolean removeFamily(Connection conn, HttpSession session, String id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from tdm_tabs where family_id=? limit 0,1";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) return false;
	
	sql="delete from tdm_target_family_env where family_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	execDBConf(conn, sql, bindlist);
	
	sql="delete from tdm_family where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	execDBConf(conn, sql, bindlist);
	
	return true;
	
}


//**************************************************************************
void addDatabase(Connection conn, HttpSession session, String database_name) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="insert into tdm_envs (app_id, name) values (0,?)";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",database_name});
	
	execDBConf(conn, sql, bindlist);
}

//**************************************************************************
void addPolicyGroup(Connection conn, HttpSession session, String policy_group_name) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="insert into tdm_proxy_policy_group (policy_group_name) values (?)";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",policy_group_name});
	
	execDBConf(conn, sql, bindlist);
}
//**************************************************************************
void addNewSessionValidation(Connection conn, HttpSession session, String session_validation_name) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="insert into tdm_proxy_session_validation (session_validation_name) values (?)";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",session_validation_name});
	
	execDBConf(conn, sql, bindlist);
}
//**************************************************************************
void addNewMonitoring(Connection conn, HttpSession session, String monitoring_name) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="insert into tdm_proxy_monitoring (monitoring_name) values (?)";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",monitoring_name});
	
	execDBConf(conn, sql, bindlist);
}
//**************************************************************************
void addCalendar(Connection conn, HttpSession session, String calendar_name) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="insert into tdm_proxy_calendar (calendar_name) values (?)";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",calendar_name});
	
	execDBConf(conn, sql, bindlist);
}

//**************************************************************************
void addCalendarException(Connection conn, HttpSession session, String calendar_id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="insert into tdm_proxy_calendar_exception (calendar_id, exception_start_time, exception_end_time) values (?, now(), now())";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",calendar_id});
	
	execDBConf(conn, sql, bindlist);
}


//**************************************************************************
void addTarget(Connection conn, HttpSession session, String target_name) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="insert into tdm_target (target_name) values (?)";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",target_name});
	
	execDBConf(conn, sql, bindlist);


}

//**************************************************************************
void addFamily(Connection conn, HttpSession session, String family_name) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="insert into tdm_family (family_name) values (?)";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",family_name});
	
	execDBConf(conn, sql, bindlist);


}

//**************************************************************************
void renameTarget(Connection conn, HttpSession session, String target_id, String target_name) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="update tdm_target set target_name=? where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",target_name});
	bindlist.add(new String[]{"INTEGER",target_id});
	
	execDBConf(conn, sql, bindlist);


}

//**************************************************************************
void renameFamily(Connection conn, HttpSession session, String family_id, String family_name) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="update tdm_family set family_name=? where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",family_name});
	bindlist.add(new String[]{"INTEGER",family_id});
	
	execDBConf(conn, sql, bindlist);


}

//**************************************************************************
void removeTargetFamilyDb(Connection conn, HttpSession session, String target_id, String family_id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="delete from tdm_target_family_env where target_id=? and family_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",target_id});
	bindlist.add(new String[]{"INTEGER",family_id});
	
	execDBConf(conn, sql, bindlist);


}

//**************************************************************************
void setRecursiveFields(Connection conn, HttpSession session, String tab_id, String recursive_fields) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="update tdm_tabs set recursive_fields=? where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",recursive_fields});
	bindlist.add(new String[]{"INTEGER",tab_id});
	
	execDBConf(conn, sql, bindlist);


}

//**************************************************************************
void setTargetFamilyDb(Connection conn, HttpSession session, String target_id, String family_id, String env_id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="delete from tdm_target_family_env where target_id=? and family_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",target_id});
	bindlist.add(new String[]{"INTEGER",family_id});
	
	execDBConf(conn, sql, bindlist);
	
	sql="insert into tdm_target_family_env (target_id, family_id, env_id) values (?,?,?) ";
	bindlist.add(new String[]{"INTEGER",env_id});
	
	execDBConf(conn, sql, bindlist);
	


}

//***************************************************************************
String passwordDecoder(String password) {
	if (!password.startsWith("DEC:"))  return password;
	
	try {
		String tmp=password.substring(4);
		return decrypt(tmp);
		
	} catch(Exception e) {
		e.printStackTrace();
		return "";
	}
	
}

//***************************************************************************
boolean testConnectionByDbId(Connection conn, HttpSession session, String db_id, StringBuilder errmsg) {
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select db_driver, db_connstr, db_username, db_password from tdm_envs where id=?";
	
	
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",db_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) {
		errmsg.append("Db not found.");
		return false;
	}
	
	String db_driver=arr.get(0)[0];
	String db_connstr=arr.get(0)[1];
	String db_username=arr.get(0)[2];
	String db_password=passwordDecoder(arr.get(0)[3]);


	
	sql="select flexval1, flexval2 from  tdm_ref where ref_type='DB_TYPE' and ref_name=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",db_driver});
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) {
		errmsg.append("Db type definition not found. : " + db_driver);
		return false;
	}
	
	String db_type=arr.get(0)[0];
	String template=arr.get(0)[1];
	
	String test_sql="";
	
	if (template.contains("|")) 
		test_sql=template.split("\\|")[0];
	
	boolean test_ok=false;
	Connection conntest = null;

	
	if (db_type.toUpperCase().contains("MONGO")) {
		String conn_error=testMongoDBConnection(db_connstr);
		if (conn_error.length()==0) 
			return true;
		else {
			errmsg.append(conn_error);
			return false;
		}
	}
	else {
		try {
			Class.forName(db_driver.replace("*",""));
			conntest = DriverManager.getConnection(db_connstr, db_username, db_password);
			
			Statement stmt = conntest.createStatement();
			ResultSet rset = stmt.executeQuery(test_sql);
			while (rset.next()) {rset.getString(1);	}
			return true;
					
		} catch (Exception ignore) {
			String conn_error=ignore.getMessage();
			errmsg.append(conn_error);
			ignore.printStackTrace();
			return false;
			
		} finally {
			if (conntest!=null) try{conntest.close();} catch(Exception e) {}
		}
		
		
	}
	
	
}

//*****************************************************************
String refillParentTable(Connection conn, HttpSession session, String tab_id) {

	StringBuilder sb=new StringBuilder();
	
	String sql="select tr.tab_id, concat(t.schema_name, '.',t.tab_name) " +
   		"	from tdm_tabs_rel tr, tdm_tabs t  " +
   		"	where tr.tab_id=t.id and rel_tab_id=? ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
   	bindlist.clear();
   	bindlist.add(new String[]{"INTEGER",tab_id});
   	
   	String parent_table_id="";
   	String parent_table="";
   	
   	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
   	
   	if (arr!=null && arr.size()==1) {
   		parent_table_id=arr.get(0)[0];
   		parent_table=arr.get(0)[1];
   	}
    	
    	
	if (parent_table.length()>0)
		sb.append("[<a href=\"javascript:openTableScriptDetails(curr_env_id, '"+parent_table_id+"')\">"+parent_table+"</a>]");

	
	sb.append(" <button type=\"button\" class=\"btn btn-default btn-sm\" onclick=\"addTableAndLink('"+nvl(parent_table_id,"0")+"','','"+tab_id+"');\">"+
			"<font color=blue><span class=\"glyphicon glyphicon-link\"></span></font>"+
			"</button>"	
			);
	
	
	return sb.toString();
	
}


//*****************************************************************
String showFailedWorkPackageList(Connection conn, HttpSession session, String work_plan_id) {

	StringBuilder sb=new StringBuilder();
	
	String sql="select id, wp_name from tdm_work_package where work_plan_id=? and length(err_info)>10 order by 2";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
 	bindlist.clear();
 	bindlist.add(new String[]{"INTEGER",work_plan_id});
 	
 	
 	
 	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
 	
 	if (arr.size()==0) return "no failed work package found";
 	
 	
 	
 	sb.append("<div class=row>");
 	sb.append("<div class=\"col-md-4\" align=right>Failed Work Package For [<b>"+work_plan_id+"</b>] : </div>");
 	sb.append("<div class=\"col-md-8\">");
 	sb.append(makeComboArr(arr, "", "id=failed_work_package_list size=1 onchange=printWpcError()", "", 0));
 	sb.append("</div>");
 	sb.append("</div>");
 	
 	String first_work_package_id=arr.get(0)[0];
 	
 	sb.append("<div class=row>");
 	sb.append("<div class=\"col-md-12\" id=failedWPErrorDiv>");
 	sb.append(printWorkPackageError(conn, session, first_work_package_id));
 	sb.append("</div>");
 	sb.append("</div>");
 	
	
	return sb.toString();
	
}


//*****************************************************************
String showCopySummary(Connection conn, HttpSession session, String work_plan_id) {

	StringBuilder sb=new StringBuilder();
	
	String sql="select post_script from tdm_work_plan where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
 	bindlist.clear();
 	bindlist.add(new String[]{"INTEGER",nvl(work_plan_id,"0")});
 	
 	
 	
 	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
 	
 	if (arr.size()==0) return "no  work plan found";
 	
 	
 	
 	
 	
 	String err_msg=arr.get(0)[0];


 	
 	sb.append("<div class=row>");
 	sb.append("<div class=\"col-md-12\">");
 	sb.append("<textarea rows=20 style=\"width:100%; background-color:black; color:white; font-family:Courier New, Courier, monospace; \">");
 	sb.append(err_msg);
 	sb.append("</textarea>");
 	sb.append("</div>");
 	sb.append("</div>");
 	
	
	return sb.toString();
	
}

//*******************************************************************************************

String printWorkPackageError(Connection conn, HttpSession session, String work_package_id) {

	StringBuilder sb=new StringBuilder();
	
	String sql="select err_info from tdm_work_package where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
 	bindlist.clear();
 	bindlist.add(new String[]{"INTEGER",nvl(work_package_id,"0")});
 	
 	
 	
 	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
 	
 	if (arr.size()==0) return "no  work package found";
 	
 	
 	
 	
 	
 	String err_msg=arr.get(0)[0];


 	
 	sb.append("<div class=row>");
 	sb.append("<div class=\"col-md-12\">");
 	sb.append("<textarea rows=20 style=\"width:100%; background-color:black; color:white; font-family:Courier New, Courier, monospace; \">");
 	sb.append(err_msg);
 	sb.append("</textarea>");
 	sb.append("</div>");
 	sb.append("</div>");
 	
	
	return sb.toString();
	
}


//*******************************************************************************************

String printDependedWorkPlanList(Connection conn, HttpSession session, String work_plan_id) {

	StringBuilder sb=new StringBuilder();
	
	String sql="select dwpl.id, dwpl.work_plan_name  " + 
				"	from tdm_work_plan_dependency wd, tdm_work_plan dwpl  " + 
				"	where wd.work_plan_id=?  " + 
				"	and depended_work_plan_id=dwpl.id  " + 
				"	and dwpl.status!='FINISHED'  " + 
				"	order by dwpl.id";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",nvl(work_plan_id,"0")});
	
	
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	if (arr.size()==0) return "no depended work plan found";
	
	
	sb.append("<h4><b>Waiting work plan list for "+work_plan_id+"</b></h4>");
	
	sb.append("<table class=table>");

	sb.append("<tr class=info>");
	sb.append("<td><b>Task Id</b></td>");
	sb.append("<td><b>Task Name</b></td>");
	sb.append("</tr>");
	
	for (int i=0;i<arr.size();i++) {
		
		String dep_work_plan_id=arr.get(i)[0];
		String dep_work_plan_name=arr.get(i)[1];
		
		sb.append("<tr>");
		sb.append("<td>"+dep_work_plan_id+"</td>");
		sb.append("<td>"+dep_work_plan_name+"</td>");
		sb.append("</tr>");
	}

	sb.append("</table>");

	
	
	return sb.toString();
	
}
//*******************************************************************************************

String makeAppOptions(Connection conn, HttpSession session, String app_id) {

	StringBuilder sb=new StringBuilder();
	
	String sql="select name, app_type, last_run_point_statement from tdm_apps where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",nvl(app_id,"0")});
	
	
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	if (arr.size()==0) return "no  application found";
	
	sb.append("<input type=hidden id=opt_app_id value=\""+app_id+"\">");
	
	
	String app_name=arr.get(0)[0];
	String app_type=arr.get(0)[1];
	String last_run_point_statement=arr.get(0)[2];

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append("<h4>Options for : <span class=\"label label-primary\">"+app_name+"</span></h4>");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<hr>");
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-4\" align=right><span class=\"label label-warning\">Last Pointer SQL Statement :</span></div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append("<textarea id=last_run_point_statement rows=4 style=\"width:100%; font-family:Courier New, Courier, monospace; \">");
 	sb.append(last_run_point_statement);
 	sb.append("</textarea>");
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	
	return sb.toString();
	
}


//*******************************************************************************************

void saveAppOptions(Connection conn, HttpSession session, String app_id, String last_run_point_statement) {

	
	String sql="update tdm_apps set last_run_point_statement=?  where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",last_run_point_statement});
	bindlist.add(new String[]{"INTEGER",nvl(app_id,"0")});
	
	execDBConf(conn, sql, bindlist);
	
	
	
}

//********************************************************************
String generateMaskDiscoveryReportContent(Connection conn, String discovery_id, String rep_type) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select discovery_type from tdm_discovery where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",discovery_id});
	
	ArrayList<String[]> tmpArr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String discovery_type=tmpArr.get(0)[0];
	
	if (discovery_type.equals("MASK"))
		sql="select \n"+
					"	res.id result_id, \n"+
					"	discovery_title discovery_name, \n"+
					"	DATE_FORMAT(create_date,'%d.%m.%Y %H:%i:%s') create_date, \n"+
					"	res.catalog_name, \n"+
					"	res.schema_name, \n"+
					"	res.table_name, \n"+
					"	(select round(sum(match_count/res.sample_count*rl.rule_weight),2) \n"+
					"		       from tdm_discovery_result resx  \n"+
					"		       where resx.discovery_id=dis.id  \n"+
					"					and resx.catalog_name=res.catalog_name  \n"+
					"		            and resx.schema_name=res.schema_name \n"+
					"		            and resx.table_name=res.table_name \n"+
					"		    ) table_score, \n"+
					"	res.field_name, \n"+
					"	res.field_type, \n"+
					"	tar.description rule_group, \n"+
					"	rl.description rule, \n"+
					"	match_count, \n"+
					"	res.sample_count, \n"+
					"	rl.rule_weight, \n"+
					"   (select case when sign(count(*))=0 then 'NO' else 'YES' end  from tdm_fields f, tdm_tabs t, tdm_apps a \n"+
					"		where f.tab_id=t.id and t.app_id=a.id and app_type='MASK' \n"+
					"       and t.cat_name=res.catalog_name and t.schema_name=res.schema_name \n"+
					"       and t.tab_name=res.table_name and f.field_name=res.field_name) is_masked \n"+
					"	from  \n"+
					"		tdm_discovery dis, tdm_discovery_result res, tdm_discovery_target tar, tdm_discovery_rule rl \n"+
					"	where  \n"+
					"		dis.id=? \n"+
					"		and res.discovery_id=dis.id  \n"+
					"		and res.discovery_target_id=tar.id \n"+
					"		and res.discovery_rule_id=rl.id ";
	else 
		sql="select \n"+
				"	res.id result_id, \n"+
				"	discovery_title discovery_name, \n"+
				"	DATE_FORMAT(create_date,'%d.%m.%Y %H:%i:%s') create_date, \n"+
				"	res.tab_owner, \n"+
				"	res.tab_name, \n"+
				"	res.child_rel_fields, \n"+
				"	res.parent_tab_owner, \n"+
				"	res.parent_tab_name, \n"+
				"	res.parent_pk_fields, \n"+
				"	matched_count, \n"+
				"	res.sample_count \n"+
				"	from   tdm_discovery dis, tdm_discovery_rel res \n"+
				"	where   dis.id=? \n"+
				"		and res.discovery_id=dis.id ";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",discovery_id});
	
	
	StringBuilder sb=new StringBuilder();
	ArrayList<String> colList=new ArrayList<String>();
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist, 1200, colList);
	
	
	String rep_name="";
	String upload_dir=makeUploadFolder();
		
	
	if (rep_type.equals("EXCEL")) {
		
		rep_name="discovery_repory_"+discovery_id+"_"+System.currentTimeMillis()+".xls";
		String filepath = upload_dir+File.separator+rep_name;
		
		String tmp=generateExcelFile(conn, filepath, colList, arr);
		
		if (tmp.length()==0) return "";

		
	} else {
		rep_name="discovery_repory_"+discovery_id+"_"+System.currentTimeMillis()+".csv";
		String delimiter="\t";
		if (rep_type.equals("CSV_COMMA")) delimiter=",";
		
		for (int i=0;i<colList.size();i++) {
			sb.append(colList.get(i));
			sb.append(delimiter);
		}
		sb.append("\n");
		
		for (int i=0;i<arr.size();i++) {
			String[] row=arr.get(i);
			for (int r=0;r<row.length;r++) {
				sb.append(row[r]);
				sb.append(delimiter);
			}
			sb.append("\n");
		}
		
		String filepath = upload_dir+File.separator+rep_name;
		
		File f=new File(filepath);
      	if (f.exists()) f.delete();
      	
		text2file(sb.toString(), filepath);
		
	}
	
	return rep_name;
	
	
	
}


//********************************************************************
String exportMaskingConfiguration(Connection conn, String app_id) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	String sql="select \n"+
				" cat_name, schema_name, tab_name, field_name, short_code \n"+
				"	from tdm_fields f, tdm_tabs t, tdm_apps a, tdm_mask_prof p \n"+
				"	where mask_prof_id>0 \n"+
				"	and f.tab_id=t.id and t.app_id=a.id and mask_prof_id=p.id and a.id=? \n"+
				"	order by cat_name, schema_name, tab_name, field_name ";
				
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	StringBuilder sb=new StringBuilder();
	ArrayList<String> colList=new ArrayList<String>();
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist, 1200, colList);
	
	String rep_name="";
	String upload_dir=makeUploadFolder();
		
	rep_name="configuration_export_"+app_id+"_"+System.currentTimeMillis()+".xls";
	String filepath = upload_dir+File.separator+rep_name;
	
	String tmp=generateExcelFile(conn, filepath, colList, arr);
	
	if (tmp.length()==0) return "";
	return rep_name; 

	
}

//****************************************************************
String makeUploadFolder() {
	String upload_dir=getServletContext().getRealPath("")+File.separator+"upload";
	try {
		File theDir = new File(upload_dir);
		if (!theDir.exists()) {
			 theDir.mkdir();
		}
	} catch(Exception e) {
		System.out.println("Error on creation :"+upload_dir);
		e.printStackTrace();
		return "";
	}
		
	return upload_dir;
}

//****************************************************************
String  generateExcelFile(Connection conn, String filepath, ArrayList<String> colList, ArrayList<String[]> arr) {
	
	try {
      	
      	
        HSSFWorkbook workbook = new HSSFWorkbook();
        HSSFSheet sheet = workbook.createSheet("raw");  
        
        HSSFRow rowhead = sheet.createRow((short)0);
        
        
        for (int i=0;i<colList.size();i++) {
			rowhead.createCell(i).setCellValue(colList.get(i));
		}

        
        for (int i=0;i<arr.size();i++) {
			String[] rec=arr.get(i);
			
			HSSFRow row = sheet.createRow(i+1);
			
			for (int r=0;r<rec.length;r++) {

				if (colList.get(r).contains("_count") || colList.get(r).contains("_id") ) {
					try {
						int val=Integer.parseInt(rec[r]);
						row.createCell(r).setCellValue(val);
					} catch(Exception e) {
						row.createCell(r).setCellValue("");
					}
					
				}
				else if (colList.get(r).contains("_weight")|| colList.get(r).contains("_score")) {
					try {
						float val=Float.parseFloat(rec[r]);
						row.createCell(r).setCellValue(val);
					} catch(Exception e) {
						row.createCell(r).setCellValue("");
					}
				}
				else 
					row.createCell(r).setCellValue(rec[r]);
			}
		}
        
      	File f=new File(filepath);
      	if (f.exists()) f.delete();

        FileOutputStream fileOut = new FileOutputStream(filepath);
        workbook.write(fileOut);
        fileOut.close();
        
		
    } catch ( Exception ex ) {
        System.out.println(ex);
        
        return "";
    } 
	
	return filepath;
}

//****************************************************************
void rollbackCopyWorkPlan(Connection conn, String work_plan_id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="update tdm_work_plan set status='RUNNING',run_type='ROLLBACK' where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",work_plan_id});
	
	execDBConf(conn, sql, bindlist);
	
	sql="update tdm_work_package set"+
		" status='NEW'," + 
		" end_date=null, "+
		" last_activity_date=now(), "+
		" duration=null, " +
		" export_count=0, "+
		" all_count=0, "+
		" done_count=0, "+
		" success_count=0, "+
		" fail_count=0, "+
		" err_info=null "+
		" where work_plan_id=? ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",work_plan_id});
	
	execDBConf(conn, sql, bindlist);
}

//*****************************************************************
boolean checkSourceTargetDb(Connection conn, HttpSession session, String app_id, String env_id, String target_env_id, String wp_params) {
	
	return true;
}

//*****************************************************************
String userpassdecrypy(String val) {
	String ret1="";
	int i=0;
	while (true) {
		int char_len=0;
		try {char_len=Integer.parseInt(val.substring(i,i+1));} catch(Exception e) {break;}
		char c=(char) Integer.parseInt(val.substring(i+1,i+1+char_len));
		ret1=ret1+c;
		i=i+char_len+1;
	}
	
	return ret1;
}

//*****************************************************************
boolean doLoginAttempt(Connection conn, HttpSession session, String input_username, String input_password) {
	
	
	String username=userpassdecrypy(input_username);
	String password=userpassdecrypy(input_password);
	
	System.out.println(input_username+"=>"+username);
	//System.out.println(input_password+"=>"+password.substring(2)+"****");
	
	int user_id=checkuser(conn,username,password);

	if (user_id==0) {
		session.setAttribute("invalid_user_attempt", "true");
		System.out.println("Invalid User Id : "+0);
		return false;
	}
	
	
	String sql="select fname, lname, email from tdm_user where valid='Y' and id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",""+user_id});
	

	ArrayList<String[]>  res=getDbArrayConf(conn, sql, 1, bindlist);
	if (res==null || res.size()==0) {
		session.setAttribute("invalid_user_attempt", "true");
		return false;
	}

	String fname=res.get(0)[0];
	String lname=res.get(0)[1];
	String email=res.get(0)[2];

	session.setAttribute("username", username);	
	session.setAttribute("userid", user_id);	
	session.setAttribute("userfname", fname);	
	session.setAttribute("userlname", lname);	
	session.setAttribute("useremail", email);	
	
	sql="select shortcode from tdm_user_role ur, tdm_role r where ur.role_id=r.id and user_id=" + user_id;
	
	bindlist=new ArrayList<String[]>();
	res=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	for (int i=0;i<res.size();i++) {
		session.setAttribute("hasrole_"+res.get(i)[0], "true");
	}
	
	session.setAttribute("invalid_user_attempt", null);
	
	return true;
}

//******************************************************************************
boolean isTableExistsOnDb(Connection connconf, Connection connApp, String env_id, String catalog, String owner_table) {
	
	
	System.out.println("isTableExistsOnDb  for catalog="+catalog+", owner_table="+owner_table);
			
	try {
		
		
		String q_cat=catalog;
		String q_schema="";
		String q_table="";
		
		if (owner_table.contains(".")) {
			String[] tmpArr=owner_table.split("\\.");
			q_schema=tmpArr[0];
			q_table=tmpArr[1];
		} else {
			q_table=owner_table;
		}
		
		String db_type=getEnvDBParam(connconf, env_id, "DB_TYPE");
		
		
		
		
		
		String sql="";
		
		if (db_type.equals("ORACLE")) sql=TABLE_SQL_ORACLE + " and owner=? and table_name=?";
		else if (db_type.equals("MSSQL")) sql=TABLE_SQL_MSSQL + " and table_schema=? and table_name=?";
		else if (db_type.equals("MYSQL")) sql=TABLE_SQL_MYSQL + " and table_schema=? and table_name=?";
		else return true;
		
		/*
		System.out.println("\t... owner_table    ="+owner_table);
		System.out.println("\t... q_cat    ="+q_cat);
		System.out.println("\t... q_schema ="+q_schema);
		System.out.println("\t... q_table  ="+q_table);
		System.out.println("\t... db_type  ="+db_type);
		System.out.println("\t... sql      ="+sql);
		*/
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"STRING",q_cat});
		bindlist.add(new String[]{"STRING",q_schema});
		bindlist.add(new String[]{"STRING",q_table});
		
		setCatalogForConnection(connApp, q_cat);
		
		ArrayList<String[]> arr=getDbArrayApp(connApp, sql, 1, bindlist, false, "");
		
		if (arr==null || arr.size()==0) return false;
		
		return true;
		
		/*
		
		DatabaseMetaData meta = connApp.getMetaData();
		
		ResultSet res = null;
		
		meta.getTables(q_cat, q_schema, q_table, new String[] {"TABLE"});
		
		int rec_count=0;
		while (res.next()) {
			rec_count++;
			break;
		} 
		res.close();
		
		if (rec_count==0) return false;
		
		return true;
		
		*/
		
	} catch(Exception e) {
		return false;
	}
	
	
}
//****************************************
String decrypt(String val) {
	String ret1="";
	int i=0;
	while (true) {
		int char_len=0;
		try {char_len=Integer.parseInt(val.substring(i,i+1));} catch(Exception e) {break;}
		char c=(char) Integer.parseInt(val.substring(i+1,i+1+char_len));
		ret1=ret1+c;
		i=i+char_len+1;
	}
	
	return ret1;
}

//******************************************************************************
boolean checkTableManualCondition(
		Connection conn,
		HttpSession session,
		String source_env_id,
		String copy_filter_id,
		String copy_filter_binds,
		StringBuilder sbCheckMc
		) {

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select filter_type from tdm_copy_filter where id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",copy_filter_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==0) {
		sbCheckMc.append("filter not found with id : "+copy_filter_id);
		return false;
	}
	
	String filter_type=arr.get(0)[0];
	
	if (!filter_type.equals("MANUAL_CONDITION")) return true;
	
	int pospp=copy_filter_binds.indexOf("++");
	
	if (pospp==-1) {
		sbCheckMc.append("++ not found : "+copy_filter_binds);
		return false;
	}
	
	String tab_id="0";
	String manual_condition="";
	
	
	try {
		tab_id=copy_filter_binds.substring(0,pospp);
		manual_condition= copy_filter_binds.substring(pospp+2);
		
		
		tab_id=decrypt(tab_id);
		manual_condition=decrypt(manual_condition);
		
	} catch(Exception e) {
		sbCheckMc.append(e.toString());
		return false;
	}
	
	
	String db_id=getDbIdFromFilter(conn, session, source_env_id, copy_filter_id);
	
	
	StringBuilder sbErr=new StringBuilder();
	
	boolean is_sql_valid=isTableFilterValid(conn,db_id,tab_id,manual_condition,sbErr); 
	
	if (is_sql_valid) {
		sbCheckMc.append("<font color=green>Manual condition is valid :[<b>"+clearHtml(manual_condition)+"</b>]</font>");
		return true;
	}
	
	sbCheckMc.append("<font color=red>Manual condition is invalid : [<b>"+clearHtml(manual_condition)+"</b>]</font>");
	sbCheckMc.append("<br>");
	sbCheckMc.append(sbErr.toString());

	return false;
	
	
}

//******************************************************************************
String showTableCheckCompareStatus(Connection conn, HttpSession session, 
		String app_type, 
		String app_id, 
		String source_id, 
		String target_id, 
		String wp_params
		) {
	StringBuilder sb=new StringBuilder();
	
	
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	ArrayList<String[]> arr=new ArrayList<String[]>();
	
	String[] wpParArr=wp_params.split("::::");
	String task_name=wpParArr[0];
	String target_owner_info=wpParArr[8];
	String copy_filter=wpParArr[9];
	String copy_filter_bind=wpParArr[10];
	
	
	sb.append("<table class=table><tr class=success><td><b>"+task_name+"</b></td></tr></table>");
	
	sb.append("<input type=hidden id=comparing_app_type value=\""+app_type+"\">");
	sb.append("<input type=hidden id=comparing_app_id value=\""+app_id+"\">");
	sb.append("<input type=hidden id=comparing_source_env_id value=\""+source_id+"\">");
	sb.append("<input type=hidden id=comparing_target_env_id value=\""+target_id+"\">");
	sb.append("<input type=hidden id=comparing_wp_params value=\""+wp_params+"\">");
	
	StringBuilder sbCheckMc=new StringBuilder();
	
	boolean is_manual_condition_valid=checkTableManualCondition(conn,session,source_id,copy_filter,copy_filter_bind,sbCheckMc);
	
	sb.append(sbCheckMc.toString());
	
	if (!is_manual_condition_valid) {
		
		
		sb.append("<hr>");
		sb.append("<input type=text disabled size=2 id=comparing_error_count value=1>");
		sb.append("<font color=red> error(s) to fix.</font>");
		return sb.toString();
	}
	
	
	String[] tabsArr=target_owner_info.split("\n|\r");
	
	ArrayList<String> tabList=new ArrayList<String>();
	ArrayList<String[]> confList=new ArrayList<String[]>();
	ArrayList<String[]> sourceList=new ArrayList<String[]>();
	ArrayList<String[]> targetList=new ArrayList<String[]>();
	
	for (int i=0;i<tabsArr.length;i++) {
		String el=tabsArr[i];
		if (el.trim().length()==0) continue;
		int pos_0=el.indexOf("*");
		int pos_1=el.indexOf("[");
		int pos_2=el.indexOf("]");
		int pos_3=el.indexOf(":");

		if (pos_0==-1 || pos_1==-1 || pos_2==-1 || pos_3==-1 ) continue;
		
		String tab_id=el.substring(0, pos_0);
		tabList.add(tab_id);
		
		String conf=el.substring(pos_0+1,pos_1);
		
		int pos_dot=conf.indexOf(".");
		if (pos_dot==-1) continue;
		
		String conf_owner=conf.substring(0,pos_dot);
		String conf_table=conf.substring(pos_dot+1);
		
		confList.add(new String[]{conf_owner, conf_table});
		
		String temp1=el.substring(pos_1,pos_2);
		
		//---------------------------------------
		String source=el.substring(pos_1+1,pos_3);
		pos_dot=source.indexOf(".");
		if (pos_dot==-1) continue;
		
		String source_owner=source.substring(0,pos_dot);
		String source_table=source.substring(pos_dot+1);
		
		sourceList.add(new String[]{source_owner, source_table});
		
		//----------------------------------------
		String target=el.substring(pos_3+1,pos_2);
		pos_dot=target.indexOf(".");
		if (pos_dot==-1) continue;
		
		String target_owner=target.substring(0,pos_dot);
		String target_table=target.substring(pos_dot+1);
		
		targetList.add(new String[]{target_owner, target_table});
		
	}
	
	boolean is_db_connection_error=false;
	int error_count=0;
	
	ArrayList<Connection> connArr=new ArrayList<Connection>();
	ArrayList<String> dbArr=new ArrayList<String>();
	ArrayList<String> dbTypeArr=new ArrayList<String>();

	ArrayList<String> sourceDbIdArr=new ArrayList<String>();
	ArrayList<String> targetDbIdArr=new ArrayList<String>();
	
	
	ArrayList<String> sourceDbNameArr=new ArrayList<String>();
	ArrayList<String> targetDbNameArr=new ArrayList<String>();
	
	//Collect Source and target 
	for (int i=0;i<tabList.size();i++) {
		String tab_id=tabList.get(i);
		
		sql="select family_id from tdm_tabs where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",tab_id});
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		String family_id=arr.get(0)[0];
		
		String source_db_id="";
		String target_db_id="";
		
		String source_db_name="";
		String target_db_name="";

		
		sql="select env_id, name from tdm_target_family_env fae, tdm_envs e where target_id=? and family_id=? and env_id=e.id";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",source_id});
		bindlist.add(new String[]{"INTEGER",family_id});
		
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		if (arr!=null && arr.size()==1) {
			source_db_id=arr.get(0)[0];
			source_db_name=arr.get(0)[1];
		}
		
		
		sql="select env_id, name from tdm_target_family_env fae, tdm_envs e where target_id=? and family_id=? and env_id=e.id";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",target_id});
		bindlist.add(new String[]{"INTEGER",family_id});
		
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		if (arr!=null && arr.size()==1) {
			target_db_id=arr.get(0)[0];
			target_db_name=arr.get(0)[1];
		}
		
		sourceDbIdArr.add(source_db_id);
		sourceDbNameArr.add(source_db_name);
		targetDbIdArr.add(target_db_id);
		targetDbNameArr.add(target_db_name);
		
		if (dbArr.indexOf(source_db_id)==-1) {
			dbArr.add(source_db_id);
			String db_type=getEnvDBParam(conn, source_db_id, "DB_TYPE");
			dbTypeArr.add(db_type);
			connArr.add(getconn(conn, source_db_id));
			if (connArr.get(connArr.size()-1)!=null) {
				sb.append("<font color=green><h4>"+source_db_name+" [<b>"+db_type+"</b>] Source connection is valid.</h4></font>");
			}
			else {
				sb.append("<font color=red><h4>"+source_db_name+" connection is not established.["+last_connection_error+"]</h4></font>");
				is_db_connection_error=true;
				error_count++;
			}
		}
		
		
		if (dbArr.indexOf(target_db_id)==-1) {
			dbArr.add(target_db_id);
			String db_type=getEnvDBParam(conn, target_db_id, "DB_TYPE");
			dbTypeArr.add(db_type);
			connArr.add(getconn(conn, target_db_id));
			if (connArr.get(connArr.size()-1)!=null) {
				sb.append("<font color=green><h4>"+target_db_name+" [<b>"+db_type+"</b>] DB connection is valid.</h4></font>");
			}
			else {
				sb.append("<font color=red><h4>"+target_db_name+" [<b>"+db_type+"</b>] DB connection is not established.["+last_connection_error+"]</h4></font>");
				is_db_connection_error=true;
				error_count++;
			}
		}
	}
	
	
	if (!is_db_connection_error) {
		sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
		
		sb.append("<tr class=info>");
		sb.append("<td><b>Configured</b></td>");
		sb.append("<td><b>Source</b></td>");
		sb.append("<td><b>Target</b></td>");
		sb.append("<td><b>Status</b></td>");
		sb.append("<td><b>Details</b></td>");
		sb.append("</tr>");
		
		for (int i=0;i<confList.size();i++) {
			
			String conf_tab_id=tabList.get(i);
			String conf_owner=confList.get(i)[0];
			String conf_table=confList.get(i)[1];
			String source_owner=sourceList.get(i)[0];
			String source_table=sourceList.get(i)[1];
			String target_owner=targetList.get(i)[0];
			String target_table=targetList.get(i)[1];
			
			String source_db_id=sourceDbIdArr.get(i);
			String source_db_name=sourceDbNameArr.get(i);
			
			String target_db_id=targetDbIdArr.get(i);
			String target_db_name=targetDbNameArr.get(i);
			
			
			
			
			String check_results="";
			
			
			boolean is_source_table_exists=isTableExistsOnDb(conn, connArr.get(dbArr.indexOf(source_db_id)), source_db_id, source_owner, source_table);
			boolean is_target_table_exists=isTableExistsOnDb(conn, connArr.get(dbArr.indexOf(target_db_id)), target_db_id, target_owner, target_table);
			
			String source_tbl_check_icon="<font color=lightgreen><span class=\"glyphicon glyphicon-ok\"></span></font>";
			String target_tbl_check_icon="<font color=lightgreen><span class=\"glyphicon glyphicon-ok\"></span></font>";
			
			
			if (!is_source_table_exists) {
				source_tbl_check_icon="<font color=red><span class=\"glyphicon glyphicon-exclamation-sign\"></span></font>";
				error_count++;
				if (check_results.length()>0) check_results=check_results+"<br>";
				check_results=check_results+"<font color=red>Table ["+source_owner+"."+source_table+"] not found in source database</font>";
			}
			
			if (!is_target_table_exists) {
				target_tbl_check_icon="<font color=red><span class=\"glyphicon glyphicon-exclamation-sign\"></span></font>";
				if (check_results.length()>0) check_results=check_results+"<br>";
				check_results=check_results+"<font color=brown>Table ["+target_owner+"."+target_table+"] not found in target database. Will be created.</font>";
			}
			
			
			
			ArrayList<String[]> sourceFieldList=getFieldListFromApp(connArr.get(dbArr.indexOf(source_db_id)), "", "${default}", source_owner, source_table, dbTypeArr.get(dbArr.indexOf(source_db_id)));
			ArrayList<String[]> targetFieldList=getFieldListFromApp(connArr.get(dbArr.indexOf(target_db_id)), "", "${default}", target_owner, target_table, dbTypeArr.get(dbArr.indexOf(target_db_id)));
				
			
			
			ArrayList<String[]> compareErrors=compareAppTables(sourceFieldList, targetFieldList);
			
			boolean field_check_success=true;

			if (compareErrors.size()>0) {
				
				
				String warning_sign="<font color=#96A30A><span class=\"glyphicon glyphicon-exclamation-sign\"></span></font>";
				String error_sign="<font color=red><span class=\"glyphicon glyphicon-exclamation-sign\"></span></font>";
				
				if (is_target_table_exists)
					for (int c=0;c<compareErrors.size();c++) {
						String compare_result=compareErrors.get(c)[0];
						String compare_direction=compareErrors.get(c)[1];
						String compare_field=compareErrors.get(c)[2];
						String compare_detail=compareErrors.get(c)[3];
						
						System.out.println(compare_result+":"+compare_direction+":"+compare_field+":"+compare_detail);
						
						if (check_results.length()>0) check_results=check_results+"<br>";
						
						if (compare_result.equals("ERROR")) {
							field_check_success=false;
							check_results=check_results+error_sign;
							error_count++;
						}
						else 
							check_results=check_results+warning_sign;
							
						
						
						if (compare_direction.equals("SOURCE")) 
							check_results=check_results+" ["+source_owner+"."+source_table;
						 else 
							check_results=check_results+" ["+target_owner+"."+target_table;
						
						
						check_results=check_results+"]."+compare_field+":"+compare_detail;
						 
						 
						if (compare_result.equals("ERROR") && compare_direction.equals("TARGET")) {
							
							sql="select id, concat(name, ' [',rule_id,']') "+
								" 	from tdm_mask_prof " + 
								"	where rule_id in ('HASHLIST','SCRAMBLE_DATE','FIXED','RANDOM_STRING','RANDOM_NUMBER','JAVASCRIPT','SQL') " + 
								"	order by 2";
							bindlist.clear();
							ArrayList<String[]> actionArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
							actionArr.add(0, new String[]{"SET_NULL",	"*** Set Null"});
							actionArr.add(0, new String[]{"SKIP",		"*** Don't copy"});
							
							String col_info=target_owner+"."+target_table+"."+compare_field;
							
							sb.append("<input type=hidden id=missing_column_info_"+error_count+" value=\""+codehtml(col_info)+"\">");
							
							check_results=check_results+""+
								"<table class=\"table table-striped table-bordered\"><tr class=info>"+
									"<td>"+
										makeComboArr(actionArr, "", "id=missing_column_action_"+error_count+" onchange=checkErrorCount()", "", 0)+
									"</td>"+
								"</tr></table>";
							
						}
	
						
					}
			}
			
			boolean final_result=is_source_table_exists & field_check_success;
			
			sb.append("<tr>");
			sb.append("<td class=info><b>"+conf_owner+"."+conf_table+"</b></td>");
			sb.append("<td nowrap>"+source_tbl_check_icon+ " " + source_owner+"."+source_table+"<br>@"+source_db_name+"</td>");
			sb.append("<td nowrap>"+target_tbl_check_icon+ " " + target_owner+"."+target_table+"<br>@"+target_db_name+"</td>");
			
			String status_sign="<font color=red><span class=\"glyphicon glyphicon-exclamation-sign\"></span></font>";
			if (final_result) 
				status_sign="<font color=lightgreen><span class=\"glyphicon glyphicon-ok\"></span></font>";
			
			sb.append("<td class=active align=center><big><big>"+status_sign+"</big></big></td>");
			sb.append("<td class=active>"+nvl(check_results,"-")+"</td>");
			sb.append("</tr>");
			
			
		}
		
		sb.append("</table>");
	}
	
	for (int i=0;i<connArr.size();i++) 
		closeconn(connArr.get(i));
	
	
	sb.append("<input type=hidden id=error_actions>");

	
	sb.append("<input type=hidden id=original_error_count value=\""+error_count+"\">");

	if (error_count>0) {
		sb.append("<input type=text disabled size=2 id=comparing_error_count value=\""+error_count+"\">");
		sb.append("<font color=red> error(s) to fix.</font>");
	}
		
	else 
		sb.append("<input type=hidden id=comparing_error_count value=\""+error_count+"\">");

	sb.append("<input type=hidden id=comparing_error_count value=\""+error_count+"\">");
	
	
	return sb.toString();
}

//-------------------------------------------------------------------------
ArrayList<String[]> compareAppTables(ArrayList<String[]> fieldArrSource, ArrayList<String[]> fieldArrTarget) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	
	//SOURCE TO TARGET
	for (int i=0;i<fieldArrSource.size();i++) {
		String source_field_name=fieldArrSource.get(i)[0];
		String source_type=fieldArrSource.get(i)[1];
		String source_field_size=fieldArrSource.get(i)[2];
		
		
		
		boolean found=false;
		
		for (int j=0;j<fieldArrTarget.size();j++) {
			String target_field_name=fieldArrTarget.get(j)[0];
			String target_type=fieldArrTarget.get(j)[1];
			String target_field_size=fieldArrTarget.get(j)[2];
			
			if (!source_field_name.equals(target_field_name)) continue;
			
			found=true;
			
			if (!source_type.equals(target_type)) 
				ret1.add(new String[]{"WARNING","SOURCE",source_field_name,"Type is inconsistent [SRC:"+source_type+",TARGET:"+target_type+"]",""});
			else if (!source_field_size.equals(target_field_size)) 
				ret1.add(new String[]{"WARNING","SOURCE",source_field_name,"Size is inconsistent [SRC:"+source_field_size+",TARGET:"+target_field_size+"]",""});
		}
		
		if(!found) 
			ret1.add(new String[]{"WARNING","SOURCE",source_field_name,"Extra column on source, will not be copied",""});
		
	}
	
	
	
	
	for (int i=0;i<fieldArrTarget.size();i++) {
		String target_field_name=fieldArrTarget.get(i)[0];
		String target_type=fieldArrTarget.get(i)[1];
		String target_field_size=fieldArrTarget.get(i)[2];
		
		boolean found=false;
		
		for (int j=0;j<fieldArrSource.size();j++) {
			String source_field_name=fieldArrSource.get(j)[0];
			String source_type=fieldArrSource.get(j)[1];
			String sourcetarget_field_size=fieldArrSource.get(j)[2];
			
			if (!source_field_name.equals(target_field_name)) continue;
			
			found=true;
			break;


		}
		
		if(!found) 
			ret1.add(new String[]{"ERROR","TARGET",target_field_name,"Extra Column on target",""});
		
	}
	
	return ret1;
}

//***********************************************************************************************
String fillTableListInDB(
		Connection conn, 
		HttpSession session,  
		String env_id, 
		String app_type
		) {
	StringBuilder sb=new StringBuilder();
	
	String db_type=getEnvDBParam(conn, env_id, "DB_TYPE");
	boolean is_mongo=false;
	if (db_type.toUpperCase().contains("MONGO")) is_mongo=true;
	
	String catalog_filter=nvl( (String) session.getAttribute("catalog_name_filter_for_"+env_id),"All");
	String owner_filter=nvl( (String) session.getAttribute("schema_name_filter_for_"+env_id),"All");
	String table_name_filter=nvl( (String) session.getAttribute("table_name_filter_for_"+env_id),"");

	if (is_mongo && !owner_filter.equals("All")) owner_filter="${default}."+owner_filter;
	
	
	ArrayList<String> tabList=new ArrayList<String>();
	
	
	tabList=(ArrayList<String>) session.getAttribute("TABLE_LIST_OF_"+env_id);
	if (tabList==null) {
		
		if (is_mongo) {
			tabList=getMongoCollectionList(conn, env_id,owner_filter);
			
		}
		else {
			tabList=getTabList(conn, env_id, app_type,  catalog_filter, owner_filter, table_name_filter);
			
			
		}
		
		session.setAttribute("TABLE_LIST_OF_"+env_id, tabList);
	}
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();

	String sql="";
	
	
	ArrayList<String> commentTabList=new ArrayList<String>();
	ArrayList<String> commentCommentList=new ArrayList<String>();
	ArrayList<String> commentDiscardList=new ArrayList<String>();
	
	
	sql="select concat(table_cat,'.',table_owner,'.',table_name), table_comment, discard_flag  from tdm_tab_comment where env_id=? and app_type=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",env_id});
	bindlist.add(new String[]{"STRING",app_type});
	
	ArrayList<String[]> commentArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	for (int i=0;i<commentArr.size();i++) {
		commentTabList.add(commentArr.get(i)[0]);
		commentCommentList.add(commentArr.get(i)[1]);
		commentDiscardList.add(commentArr.get(i)[2]);
		
	}
	
	
	
	
	sql="select concat(cat_name,'.',schema_name,'.',tab_name) from tdm_tabs t, tdm_apps a where  app_id=a.id  and  app_id=a.id and app_type=?";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",app_type});
	

	ArrayList<String[]> tabInAppsArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	ArrayList<String> tabInAppsList=new ArrayList<String>();
	
	for (int i=0;i<tabInAppsArr.size();i++) 
		tabInAppsList.add(tabInAppsArr.get(i)[0]);
	
	ArrayList<String[]> arr=new ArrayList<String[]>();
	
	int tab_listed=0;

	
	
	sb.append("<table class=\"table table-striped table-condensed table-bordered\">");
	
	StringBuilder cellSb=new StringBuilder();
	
	//System.out.println("size="+tabList.size());
	
	for (int i=0;i<tabList.size();i++) {
		String table=tabList.get(i);
		
		
		String table_name=table.split("\\*")[2];
		String table_owner="";
		String table_cat="";
		
		try{table_owner=nvl(table.split("\\*")[1],"-");} catch(Exception e) {table_owner="-";}
		try{table_cat=nvl(table.split("\\*")[0],"-");} catch(Exception e) {table_cat="-";}
		
		
		//System.out.println("owner_filter="+owner_filter+", table_cat="+table_cat+"."+table_owner+", ");
		
		
		if (!catalog_filter.equals("All") && catalog_filter.length()>0 && !catalog_filter.equals(table_cat)) {
			
			continue;
		}
			
		
		
		
		if (owner_filter.equals("All") || owner_filter.equals(table_cat+"."+table_owner)) {
    		
    		if (table_name_filter.toLowerCase().length()>0 &&  !table_name.toLowerCase().contains(table_name_filter.toLowerCase())) 
    			continue;
    		
    			
    		
    		cellSb.setLength(0);
    		cellSb.append(makeTableCell(conn, session, env_id, app_type, table_cat, table_owner, table_name, tabInAppsList, commentTabList, commentCommentList, commentDiscardList));
    		
    		if (cellSb.length()==0) continue;
    		
    		
    		tab_listed++;
    		
    		sb.append("<tr>");
    		sb.append("<td>");
    		
    		sb.append("<div id=\"tableCellDivFor"+table_cat+"."+table_owner+"."+table_name+"\">");
    		sb.append(cellSb.toString());
    		sb.append("</div>");
    		
    		sb.append("</td>");
    		sb.append("</tr>");
    	} 
	}
	
	sb.append("</table>");
	
	
	
	if (tab_listed==0) {
		sb.append("<br>");
		sb.append("No table found");
		return sb.toString();
	}


	
	return sb.toString();
	
	
}


//****************************************************************
String makeTableCell(
		Connection conn, 
		HttpSession session,
		String env_id,
		String app_type,
		String table_cat,
		String table_owner, 
		String table_name,
		ArrayList<String> tabInAppsList,
		ArrayList<String> commentTabList,
		ArrayList<String> commentCommentList,
		ArrayList<String> commentDiscardList
		) {
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();

	String sql="";
	
	
	
	String include_added_tables=nvl( (String) session.getAttribute("include_added_tables_for_"+env_id),"checked");
	String include_commented_tables=nvl( (String) session.getAttribute("include_commented_tables_for_"+env_id),"checked");
	String include_discarded_tables=nvl( (String) session.getAttribute("include_discarded_tables_for_"+env_id),"checked");
	
	
	if (commentTabList==null) {
		commentTabList=new ArrayList<String>();
		commentCommentList=new ArrayList<String>();
		commentDiscardList=new ArrayList<String>();
		
		sql="select concat(table_cat,'.',table_owner,'.',table_name), table_comment, discard_flag "+
			" from tdm_tab_comment "+
			" where env_id=? and table_cat=? and table_owner=? and table_name=? and app_type=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",env_id});
		bindlist.add(new String[]{"STRING",table_cat});
		bindlist.add(new String[]{"STRING",table_owner});
		bindlist.add(new String[]{"STRING",table_name});
		bindlist.add(new String[]{"STRING",app_type});
		
		ArrayList<String[]> commentArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<commentArr.size();i++) {
			commentTabList.add(commentArr.get(i)[0]);
			commentCommentList.add(commentArr.get(i)[1]);
			commentDiscardList.add(commentArr.get(i)[2]);
		}
	}
	
	
	if (tabInAppsList==null) {
		tabInAppsList=new ArrayList<String>();
		
		sql="select concat(cat_name,'.', schema_name,'.',tab_name) from tdm_tabs t, tdm_apps a where  app_id=a.id and app_type=?";
		bindlist.clear();
		bindlist.add(new String[]{"STRING",app_type});

		ArrayList<String[]> tabInAppsArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<tabInAppsArr.size();i++) 
			tabInAppsList.add(tabInAppsArr.get(i)[0]);
	}
	
	/*
	ArrayList<String> tabInAppsList,
	ArrayList<String> commentTabList,
	ArrayList<String> commentCommentList,
	ArrayList<String> commentDiscardList
	*/
	
	/*
	ArrayList<String> prArr=new ArrayList<String>();
	prArr.addAll(tabInAppsList);
	for (int a=0;a<prArr.size();a++) System.out.println("tabInAppsList ["+a+"]  : "+prArr.get(a));
	*/
	
	StringBuilder sb=new StringBuilder();
	
	boolean is_added_to_any_app=false;
	boolean is_table_commented=false;
	boolean is_table_discarded=false;
	boolean is_added_to_multiple_app=false;

	int app_idx=tabInAppsList.indexOf(table_cat+"."+table_owner+"."+table_name);
	
	if (app_idx>-1)  {
		is_added_to_any_app=true;
		if (tabInAppsList.lastIndexOf(table_cat+"."+table_owner+"."+table_name)>app_idx)
			is_added_to_multiple_app=true;
	}
	
	if (commentTabList.indexOf(table_cat+"."+table_owner+"."+table_name)>-1) is_table_commented=true;
	
	if (is_table_commented) {
		int idx=commentTabList.indexOf(table_cat+"."+table_owner+"."+table_name);
		if (commentTabList.get(idx).length()==0) is_table_commented=false;
		if (commentDiscardList.get(idx).equals("YES")) is_table_discarded=true;
		
	}
	
	if (is_added_to_any_app && !include_added_tables.equals("checked")) return "";
	if (is_table_discarded  && !include_discarded_tables.equals("checked")) return "";
	if (is_table_commented  && !include_commented_tables.equals("checked")) return "";

	
	String sql_tab_name=table_owner+"."+table_name;
	if (table_owner.equals("null") || table_owner.equals("-"))
		sql_tab_name=table_name;

	sb.append("<table width=\"100%\">");
	sb.append("<tr>");
	
	sb.append("<td>");
	if (!app_type.equals("DPOOL"))
		sb.append("<font color=green><small><span class=\"glyphicon glyphicon-plus\" onclick=\"addTableToApp('"+table_cat+"*"+table_owner+"*"+table_name+"');\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Add table to current application\" ></span></small></font>");
	sb.append("</td>");

	sb.append("<td>");
	sb.append("<font color=blue><small><span class=\"glyphicon glyphicon-list-alt\" onclick=\"showSqlEditor('"+env_id+"',0,'"+sql_tab_name+"','','"+table_cat+"');\"  data-placement=\"top\" title=\"Show table content\"></span></small></font>");
	sb.append("</td>");
	
	sb.append("<td width=\"100%\" nowrap>");
	
	sb.append("<small><small>");
	
	StringBuilder tabComment=new StringBuilder();
	
	
	tabComment.setLength(0);
	int idOfComment=commentTabList.indexOf(table_cat+"."+table_owner+"."+table_name);
	if (idOfComment>-1) 
		tabComment.append(commentCommentList.get(idOfComment));
	
	
	String full_tab_name=(("["+table_cat+"].").replace("[${default}].",""))+table_owner+"."+table_name;
	
	
	if (tabComment.length()>0) 
		sb.append("&nbsp;<font color=orange><small><span class=\"glyphicon glyphicon-comment\"  data-toggle=\"tooltip\" data-placement=\"top\" title=\""+clearHtml(tabComment.toString().replaceAll("\n|\r", "<br>"))+"\"  onclick=\"showCommentForTable('"+env_id+"','"+table_cat+"','"+table_owner+"','"+table_name+"');\"></span></small></font>&nbsp;");
	else 
		sb.append("&nbsp;<font color=gray><small><span class=\"glyphicon glyphicon-comment\" onclick=\"showCommentForTable('"+env_id+"','"+table_cat+"','"+table_owner+"','"+table_name+"');\"></span></small></font>&nbsp;");
 	
	
	if (is_table_discarded) {
		sb.append("&nbsp;<font color=green><small><span class=\"glyphicon glyphicon-eye-open\" onclick=\"setDiscardFlagForTable('"+env_id+"','"+table_cat+"','"+table_owner+"','"+table_name+"','NO');\"></span></small></font>&nbsp;");
		sb.append("<u><font color=gray><small><strike>"+full_tab_name+"</strike></font></u>");
	} else {
		sb.append("&nbsp;<font color=red><small><span class=\"glyphicon glyphicon-eye-close\"  onclick=\"setDiscardFlagForTable('"+env_id+"','"+table_cat+"','"+table_owner+"','"+table_name+"','YES');\"></span></small></font>&nbsp;");
		
		
		if (is_added_to_any_app) 
			sb.append("<b><i><font color=blue><small>"+full_tab_name+"</small></font></i></b>");
		else 
			sb.append("<b><i><font color=black><small>"+full_tab_name+"</small></font></i></b>");
		
			
	}
	
	
	
	if (is_added_to_any_app) {
		if (is_added_to_multiple_app)
			sb.append("&nbsp;<font color=red><small><span class=\"glyphicon glyphicon-exclamation-sign\" onclick=\"showAppListForTable('"+table_cat+"','"+table_owner+"','"+table_name+"');\"  data-toggle=\"tooltip\"   data-placement=\"top\" title=\"Added to multiple times & to multiple application\"></span></small></font>");
		
		sb.append("&nbsp;<font color=blue><small><span class=\"glyphicon glyphicon-share-alt\" onclick=\"showAppListForTable('"+table_cat+"','"+table_owner+"','"+table_name+"');\" data-toggle=\"tooltip\"   data-placement=\"top\" title=\"Show included applications\"></span></small></font>");
	}
		
	
	
	
		
	sb.append("</small></small>");
	
	sb.append("</td>");
	
	
	if (tabComment.length()>30) {
		tabComment.setLength(30);
		tabComment.append("...");
	}
	
	sb.append("<td nowrap align=right>");
	sb.append("<font color=gray><small><small>"+clearHtml(tabComment.toString())+"</small></small></font>");
	sb.append("</td>");
	
	
	
	sb.append("</tr>");
	sb.append("</table>");
	
	return sb.toString();
}

//***************************************************************
String showAppListForTable(Connection conn, HttpSession session, String app_type, String table_cat,  String table_owner, String table_name) {
	
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select app_id, name, app_type, count(1) added_time " +
				"	from tdm_tabs t, tdm_apps a where t.app_id=a.id " +
				"	and schema_name=? and tab_name=? "  +
				"	and app_type=?	" + 
				"group by app_id, name, app_type ";
	
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",table_owner});
	bindlist.add(new String[]{"STRING",table_name});
	bindlist.add(new String[]{"STRING",app_type});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<h4>"+table_owner+".<b>"+table_name+"</b></h4>");
	
	if (arr.size()==0) {
		sb.append("No application found with this table !");
		return sb.toString();
	}
	
	sb.append("<table class=\"table table-condensed table-striped\">");
	
	for (int i=0;i<arr.size();i++) {
		String lst_app_id=arr.get(i)[0];
		String lst_app_name=arr.get(i)[1];
		String lst_app_type=arr.get(i)[2];
		String lst_added_time=arr.get(i)[3];
		
		sb.append("<tr>");
		sb.append("<td><a href=\"javascript:openAppByIdFromAppList('"+lst_app_id+"'); \"><span class=\"glyphicon glyphicon-share-alt\"></span></a></td>");
		sb.append("<td>"+lst_app_type+"</td>");
		sb.append("<td nowrap width=\"100%\">"+clearHtml(lst_app_name)+"</td>");
		sb.append("<td nowrap >"+lst_added_time+" time(s)</td>");
		sb.append("</tr>");
		
		
	}
	
	sb.append("</table>");
	
	return sb.toString();
}



//***************************************************************
String showCommentForTable(Connection conn, HttpSession session, String app_type, String env_id, String table_cat, String table_owner, String table_name) {
	
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select table_comment " +
				"	from tdm_tab_comment " +
				"	where table_cat=? and  table_owner=? and table_name=? and env_id=? and app_type=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",table_cat});
	bindlist.add(new String[]{"STRING",table_owner});
	bindlist.add(new String[]{"STRING",table_name});
	bindlist.add(new String[]{"INTEGER",env_id});
	bindlist.add(new String[]{"STRING",app_type});

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	String comment="";
	try{comment=arr.get(0)[0];} catch(Exception e) {}
	
	sb.append("<h4>Comment For : <b>"+table_cat+"."+table_owner+"."+table_name+"</b></h4>");
	
	sb.append("<input type=hidden id=comment_env_id value=\""+env_id+"\">");
	sb.append("<input type=hidden id=comment_table_cat value=\""+table_cat+"\">");
	sb.append("<input type=hidden id=comment_table_owner value=\""+table_owner+"\">");
	sb.append("<input type=hidden id=comment_table_name value=\""+table_name+"\">");
	
	sb.append("<textarea id=comment_table_comment rows=10 style=\"width:100%; background-color:black; color:white; font-family:Courier New, Courier, monospace;\">");	
	sb.append(clearHtml(comment));
	sb.append("</textarea>");
	
	return sb.toString();
}


//***************************************************************
void setCommentForTable(
		Connection conn, 
		HttpSession session, 
		String comment_action,
		String app_type,
		String env_id,
		String table_cat, 
		String table_owner, 
		String table_name, 
		String table_comment
		) {
	
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();


	
	String sql="delete from tdm_tab_comment where table_cat=? and  table_owner=? and table_name=? and env_id=? and app_type=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",table_cat});
	bindlist.add(new String[]{"STRING",table_owner});
	bindlist.add(new String[]{"STRING",table_name});
	bindlist.add(new String[]{"INTEGER",env_id});
	bindlist.add(new String[]{"STRING",app_type});

	
	execDBConf(conn, sql, bindlist);
	
	if (comment_action.equals("SAVE_COMMENT")) {
		sql="insert into tdm_tab_comment (app_type, table_cat, table_owner, table_name, table_comment, env_id)  values (?, ?, ?, ?, ?, ?)";
		bindlist.clear();
		bindlist.add(new String[]{"STRING",app_type});
		bindlist.add(new String[]{"STRING",nvl(table_cat,"${default}")});
		bindlist.add(new String[]{"STRING",table_owner});
		bindlist.add(new String[]{"STRING",table_name});
		bindlist.add(new String[]{"STRING",table_comment});
		bindlist.add(new String[]{"INTEGER",env_id});
		execDBConf(conn, sql, bindlist);
	}
	


}

//***************************************************************
void setDiscardFlagForTable(
		Connection conn, 
		HttpSession session, 
		String app_type,
		String env_id,
		String table_cat,
		String table_owner, 
		String table_name, 
		String discard_flag
		) {
	
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();


	
	String sql="select 1 from tdm_tab_comment where table_owner=? and table_name=? and env_id=? and app_type=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",table_owner});
	bindlist.add(new String[]{"STRING",table_name});
	bindlist.add(new String[]{"INTEGER",env_id});
	bindlist.add(new String[]{"STRING",app_type});
	
	ArrayList<String[]> tmpArr=getDbArrayConf(conn, sql, 1, bindlist);
	
	boolean is_existed=false;
	
	if (tmpArr.size()==1) is_existed=true;
	
	if (!is_existed) {
		sql="insert into tdm_tab_comment (app_type, table_owner, table_name, discard_flag, env_id)  values (?, ?, ?, ?, ?)";
		bindlist.clear();
		bindlist.add(new String[]{"STRING",app_type});
		bindlist.add(new String[]{"STRING",table_owner});
		bindlist.add(new String[]{"STRING",table_name});
		bindlist.add(new String[]{"STRING",discard_flag});
		bindlist.add(new String[]{"INTEGER",env_id});
		
		execDBConf(conn, sql, bindlist);
	}
	else {
		sql="update tdm_tab_comment set discard_flag=? where table_owner=? and table_name=? and env_id=? and app_type=?";
		bindlist.clear();
		bindlist.add(new String[]{"STRING",discard_flag});
		bindlist.add(new String[]{"STRING",table_owner});
		bindlist.add(new String[]{"STRING",table_name});
		bindlist.add(new String[]{"INTEGER",env_id});
		bindlist.add(new String[]{"STRING",app_type});

		execDBConf(conn, sql, bindlist);
	}
	


}

//***********************************************************
void reorderTableInApp(Connection conn, HttpSession session, String tab_id, String direction) {
	String sql="select tab_id from tdm_tabs_rel where rel_tab_id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",tab_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	if (arr==null || arr.size()==0) return;
	

	
	String parent_app_id=arr.get(0)[0];
	
	sql="select id, rel_tab_id from tdm_tabs_rel where tab_id=? order by rel_order";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",parent_app_id});
	
	arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	for (int i=0;i<arr.size();i++) {
		String rel_id=arr.get(i)[0];
		String rel_tab_id=arr.get(i)[1];
		
		if (rel_tab_id.equals(tab_id)) {
			
			int swap_id=0;
			

			if (direction.equals("UP")) 
				swap_id=i-1;
			else  
				swap_id=i+1;
			
			String tmp_rel_id=arr.get(swap_id)[0];
			String tmp_rel_tab_id=arr.get(swap_id)[1];
			
			arr.set(swap_id, new String[]{rel_id,rel_tab_id});
			arr.set(i, new String[]{tmp_rel_id,tmp_rel_tab_id});
			
			break;
			
		}
		
		
	} //for 
	
	sql="update tdm_tabs_rel set rel_order=? where id=?";
			
	for (int i=0;i<arr.size();i++) {
		String rel_id=arr.get(i)[0];
		String rel_tab_id=arr.get(i)[1];
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+i});
		bindlist.add(new String[]{"INTEGER",rel_id});
		
		execDBConf(conn, sql, bindlist);
	}
	
	
	
	
}

//***********************************************************
void reorderTable(Connection conn, HttpSession session, String tab_id, String direction) {
	String sql="select app_id from tdm_tabs where id=? ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",tab_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	if (arr==null || arr.size()==0) return;
	

	
	String app_id=arr.get(0)[0];
	
	sql="select id from tdm_tabs t where app_id=? "+
		" and not exists (select 1 from tdm_tabs_rel where rel_tab_id=t.id) "+
			" order by t.tab_order";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	for (int i=0;i<arr.size();i++) {
		String id=arr.get(i)[0];
		
		if (id.equals(tab_id)) {
			
			int swap_id=0;
			

			if (direction.equals("UP")) 
				swap_id=i-1;
			else  
				swap_id=i+1;
			
			String tmp_tab_id=arr.get(swap_id)[0];
			
			arr.set(swap_id, new String[]{tab_id});
			arr.set(i, new String[]{tmp_tab_id});
			
			break;
			
		}
		
		
	} //for 
	
	sql="update tdm_tabs  set tab_order=? where id=?";
			
	for (int i=0;i<arr.size();i++) {
		String id=arr.get(i)[0];
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+(i+1)});
		bindlist.add(new String[]{"INTEGER",id});
		
		execDBConf(conn, sql, bindlist);
	}
	
	
	
	
}

//*****************************************************************
void addDependedCopyApplication(Connection conn, HttpSession session, String app_id, String depended_app_id) {
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	String sql="select max(rel_order) from tdm_apps_rel where app_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	String rel_order="1";
	try {rel_order=""+(Integer.parseInt(getDbArrayConf(conn, sql, 1, bindlist).get(0)[0])+1);} catch(Exception e) {} 
	
	sql="insert into tdm_apps_rel (app_id, rel_app_id, rel_order ) values (?, ?, ?)";
	
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"INTEGER",depended_app_id});
	bindlist.add(new String[]{"INTEGER",rel_order});
	
	execDBConf(conn, sql, bindlist);
	
}

//*****************************************************************
void deleteApplicationRel(Connection conn, HttpSession session, String app_rel_id) {
	String sql="delete from tdm_apps_rel where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.add(new String[]{"INTEGER",app_rel_id});
	
	execDBConf(conn, sql, bindlist);
	
}
 
 
//***********************************************************
void reorderApplicationRel(Connection conn, HttpSession session, String ordering_rel_id, String direction) {
	String sql="select app_id from tdm_apps_rel where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",ordering_rel_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	if (arr==null || arr.size()==0) return;
	

	
	String parent_app_id=arr.get(0)[0];
	
	sql="select id from tdm_apps_rel where app_id=? order by rel_order";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",parent_app_id});
	
	arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	for (int i=0;i<arr.size();i++) {
		String rel_id=arr.get(i)[0];
		
		if (rel_id.equals(ordering_rel_id)) {
			
			int swap_id=0;
			

			if (direction.equals("UP")) 
				swap_id=i-1;
			else  
				swap_id=i+1;
			
			String tmp_rel_id=arr.get(swap_id)[0];
			
			arr.set(swap_id, new String[]{rel_id});
			
			arr.set(i, new String[]{tmp_rel_id});
			
			break;
			
		}
		
		
	} //for 
	
	sql="update tdm_apps_rel set rel_order=? where id=?";
			
	for (int i=0;i<arr.size();i++) {
		String rel_id=arr.get(i)[0];
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+i});
		bindlist.add(new String[]{"INTEGER",rel_id});
		
		execDBConf(conn, sql, bindlist);
	}
	
	
	
	
} 


//********************************************************************************
void updateTdmTableField(
		Connection conn,
		HttpSession session,
		String table_name,
		String table_id,
		String field_name,
		String field_value
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	if (field_value.length()==0) {
		sql="update  "+table_name+" set  "+field_name+"=null  where id=? ";
		
		bindlist.add(new String[]{"INTEGER",table_id});
	}
	else {
		sql="update  "+table_name+" set  "+field_name+"=?  where id=? ";
		
		bindlist.add(new String[]{"STRING",field_value});
		bindlist.add(new String[]{"INTEGER",table_id});
	}
	
	
	execDBConf(conn, sql, bindlist);
	
}

//********************************************************************************
void savePrereqAppFilterValues(
		Connection conn,
		HttpSession session,
		String apps_rel_id,
		String filter_value
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="update tdm_apps_rel set filter_value=? where id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",filter_value});
	bindlist.add(new String[]{"INTEGER",apps_rel_id});
	
	execDBConf(conn, sql, bindlist);
	
}


//*************************************************************************************
String getDbServerSideScriptLocation(Connection conn, ServletContext application, HttpSession session, String db_id) {
	String db_type=getEnvDBParam(conn, db_id, "DB_TYPE");
	
	String install_file_name="serversideScriptsFor"+db_type.toUpperCase()+".sql";
	String path=application.getRealPath("/"+install_file_name);
	
	File f=new File(path);
	
	if (!f.exists()) {
		//System.out.println(" Server installatin file not found : " + install_file_name);
		return null;
	}
	
	return path;
}

//*************************************************************************************
boolean installServerSideScripts(
		Connection conn,
		ServletContext application,
		HttpSession session,
		String db_id,
		StringBuilder installLogs
		) {
	
	String path=getDbServerSideScriptLocation(conn,application,session,db_id);
	
	if (path==null) {
		installLogs.append("Installation file not found");
		installLogs.append("\n");
		return false;
	}
	
	File f=new File(path);
	
	StringBuilder script=new StringBuilder();
	BufferedReader br =null;
	try {
		br = new BufferedReader(new FileReader(f));
		String line = null;
		while ((line = br.readLine()) != null) {
			script.append(line+"\n");
		}
		br.close();
	} catch(Exception e) {
		installLogs.append("Exception : "+e.getMessage());
		installLogs.append("\n");
		e.printStackTrace();
		return false;
	} finally {
		try{br.close();} catch(Exception e) {}
	}
	
	String[] lines=script.toString().split("\n|\r");
	Connection connInstall=getconn(conn, db_id);
	
	if (connInstall==null) {
		System.out.println("Database connection was not successfull.");
		installLogs.append("Database connection was not successfull. : "+last_connection_error);
		installLogs.append("\n");
		return false;
	}
	
	boolean success=true;
	
	StringBuilder cmd=new StringBuilder();
	
	PreparedStatement stmt=null;
			
	for (int i=0;i<lines.length;i++) {
		
		if (lines[i].trim().equals("/")) {
			
			System.out.println(cmd.toString());
			installLogs.append(cmd.toString().split("\n|\r")[0]+" ... ");
			installLogs.append("\n");
			boolean is_success=false;
			
			try {
				stmt=connInstall.prepareStatement(cmd.toString());
				is_success=stmt.execute();
				installLogs.append("Executed successfully.\n ");
			} catch(SQLException e) {
				success=false;
				installLogs.append("Exception : "+e.getMessage());
				installLogs.append("\n");
				
				e.printStackTrace();
				
			} finally {
				try {stmt.close(); } catch(Exception e) {}
				installLogs.append("----------------------------------------------------------------------------------------\n");
			}
			
			
			
			cmd.setLength(0);
			
			continue;
		}
		
		if (lines[i].trim().length()>0)
			cmd.append(lines[i]+"\n");
	}
	
	try {connInstall.close(); } catch(Exception e) {}
	
	
	return success;
}

//*********************************************
String discoverCopy(Connection conn, HttpSession session, String env_id, String tab_id, String discovery_type) {
	StringBuilder sb=new StringBuilder();
	
	Connection connApp=getconn(conn, env_id);
	String db_type=getEnvDBParam(conn, env_id, "DB_TYPE");
	
	if (connApp==null) {
		sb.append("Db is invalid.");
		return sb.toString();
	}
	
	DatabaseMetaData md=null;
	
	try {md=connApp.getMetaData();} catch(Exception e) {md=null;}
	
	if (md==null) {
		closeconn(connApp);
		sb.append("Metadata is not valid.");
		return sb.toString();
	}
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	String cat="";
	String owner="";
	String table_name="";
	String family_id="0";
	sql="select cat_name, schema_name, tab_name, family_id from tdm_tabs where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",tab_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) {
		cat=arr.get(0)[0];
		owner=arr.get(0)[1];
		table_name=arr.get(0)[2];
		family_id=arr.get(0)[3];
	} else {
		closeconn(connApp);
		sb.append("Table info not found.");
		return sb.toString();
	}
	
	
	ArrayList<String> childNeedList=new ArrayList<String>();
	sql="select  concat(cat_name,'.',schema_name,'.',tab_name) a " + 
			"	from tdm_tabs_need n, tdm_copy_filter f, tdm_tabs t " + 
			"	where n.tab_id=? and copy_filter_id=f.id and f.tab_id=t.id";
	
	if (discovery_type.equals("CHILD")) 
		sql="select  concat(cat_name,'.',schema_name,'.',tab_name) a " + 
				"	from tdm_tabs_rel  tr, tdm_tabs t " + 
				"	where tab_id=? and rel_tab_id=t.id";
		
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",tab_id});
	arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	for (int i=0;i<arr.size();i++) childNeedList.add(arr.get(i)[0]);
	
	String key_type="IMPORTED";
	if (discovery_type.equals("CHILD")) key_type="EXPORTED";
	ArrayList<String[]> keys=getRelations(md, owner, table_name, key_type);
	ArrayList<String> orderedPkList=getPrimaryKeyList(connApp,cat, owner,table_name, db_type);
	closeconn(connApp);
	
	if (keys.size()==0) {
		sb.append("No related table found.");
	}
	
	sql="select concat(table_owner,'.',table_name) from tdm_tab_comment where env_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",env_id});
	
	ArrayList<String[]> tmpArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);

	ArrayList<String> commentTabList=new ArrayList<String>();
	
	for (int i=0;i<tmpArr.size();i++) 
		commentTabList.add(tmpArr.get(i)[0]);
	
	
	
	
	sb.append("<h4>Physical relations found for : <b>"+owner+"."+table_name+"</b></h4>");
	
	sb.append("<table class=\"table table-striped table-bordered table-condensed\">");
	sb.append("<tr class=info>");
	sb.append("<td><b>Relation Type</b></td>");
	sb.append("<td><b>Related Table</b></td>");
	sb.append("<td><b>Relation On Columns</b></td>");
	sb.append("</tr>");
	
	ArrayList<String> dupCheckList=new ArrayList<String>();
	

	
	for (int i=0;i<keys.size();i++) {
		
		String rel_cat="";
		String rel_owner="";
		String rel_table="";
		
		if (discovery_type.equals("CHILD")) {
			rel_cat=nvl(keys.get(i)[4],"${default}");
			rel_owner=keys.get(i)[5];
			rel_table=keys.get(i)[6];
		} else {
			rel_cat=nvl(keys.get(i)[0],"${default}");
			rel_owner=keys.get(i)[1];
			rel_table=keys.get(i)[2];
		}
		
		if (childNeedList.indexOf(rel_owner+"."+rel_table)>-1) continue;
		
		
		

		
		if (dupCheckList.indexOf(rel_owner+"."+rel_table)>-1) continue;
		dupCheckList.add(rel_owner+"."+rel_table);
		
		sb.append("<tr>");
		sb.append("<td>"+discovery_type+"</td>");
		sb.append("<td nworap width=\"100%\">");
		
		int idOfComment=commentTabList.indexOf(rel_owner+"."+rel_table);
		if (idOfComment>-1) 
			sb.append("&nbsp;<font color=yellow><span class=\"glyphicon glyphicon-comment\" onclick=\"showCommentForTable('"+env_id+"','${default}','"+rel_owner+"','"+rel_table+"');\"></span></font>&nbsp;");
		else 
			sb.append("&nbsp;<font color=gray><span class=\"glyphicon glyphicon-comment\" onclick=\"showCommentForTable('"+env_id+"','${default}','"+rel_owner+"','"+rel_table+"');\"></span></font>&nbsp;");
		
		sb.append("<span class=\"glyphicon glyphicon-list-alt\" onclick=\"showSqlEditor('"+env_id+"','0','"+rel_owner+"."+rel_table+"','','${default}');\"></span> ");

		if (!rel_cat.equals("${default]")) sb.append("<font color=red><b>"+rel_cat+"</b></font>.");
		sb.append("<font color=blue><b>"+rel_owner+"</b></font>."+rel_table+"");
		sb.append("<font color=red><b><span class=\"glyphicon glyphicon-share-alt\" onclick=\"showAppListForTable('${default}','"+rel_owner+"','"+rel_table+"');\"></span></b></font>");
		sb.append("</td>");
		sb.append("<td>");
		sb.append(discoveryLinkInfo(conn, session, orderedPkList, keys, discovery_type, rel_cat, rel_owner, rel_table, tab_id, family_id));
		sb.append("</td>");
		sb.append("</tr>");
		

		
	}
		
		
	


	sb.append("</table>");
	
	
	sb.append("<h4>Recommendations from discovery for : <b>"+owner+"."+table_name+"</b></h4>");
	
	if (discovery_type.equals("CHILD")) {
		sql="select tab_cat, tab_owner, tab_name, child_rel_fields, parent_pk_fields, \n"+
				"	round(100*sum(matched_count)/sum(rel.sample_count)) rate  \n"+
				"	from  tdm_discovery_rel rel, tdm_discovery disc \n"+
				"	where env_id=? and rel.sample_count>0 \n"+
				"	and discovery_id=disc.id \n"+
				"	and parent_tab_owner=? \n"+
				"	and parent_tab_name=? \n"+
				"	group by tab_owner, tab_name, child_rel_fields, parent_pk_fields \n"+
				"	order by rel.sample_count desc, tab_name, matched_count/rel.sample_count desc";
				
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",env_id});
				bindlist.add(new String[]{"STRING",owner});
				bindlist.add(new String[]{"STRING",table_name});
	}
	else {
		sql="select parent_tab_cat, parent_tab_owner, parent_tab_name, child_rel_fields, parent_pk_fields, \n"+
				"	round(100*sum(matched_count)/sum(rel.sample_count)) rate \n"+
				"	from  tdm_discovery_rel rel, tdm_discovery disc \n"+
				"	where env_id=? and rel.sample_count>0 \n"+
				"	and discovery_id=disc.id \n"+
				"	and tab_owner=? \n"+
				"	and tab_name=? \n"+
				"	group by parent_tab_owner, parent_tab_name, child_rel_fields, parent_pk_fields \n"+
				"	order by rel.sample_count desc, tab_name, matched_count/rel.sample_count desc";
				
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",env_id});
				bindlist.add(new String[]{"STRING",owner});
				bindlist.add(new String[]{"STRING",table_name});
	}
			
	ArrayList<String[]> discRes=getDbArrayConf(conn, sql, 50, bindlist);
	
	if (discRes.size()==0) {
		sb.append("<font color=red>No discovery recommendation found for this database. Consider discovering this database once!.</font>");
		return sb.toString();
	}
	
	sb.append("<table class=\"table table-striped table-bordered table-condensed\">");
	sb.append("<tr class=info>");
	sb.append("<td><b>Relation Type</b></td>");
	sb.append("<td><b>Related Table</b></td>");
	sb.append("<td><b>Relation On Columns</b></td>");
	sb.append("<td><b>Matched Rate %</b></td>");
	if (discovery_type.equals("CHILD"))
		sb.append("<td><b>Add as child</b></td>");
	sb.append("</tr>");
	
	
	for (int i=0;i<discRes.size();i++) {
		String tab_cat=discRes.get(i)[0];
		String tab_owner=discRes.get(i)[1];
		String tab_name=discRes.get(i)[2];
		String child_rel_fields=discRes.get(i)[3];
		String parent_pk_fields=discRes.get(i)[4];
		String match_rate=discRes.get(i)[5];
		
		
		sb.append("<tr>");
		sb.append("<td>"+discovery_type+"</td>");
		sb.append("<td nworap>");
		
		int idOfComment=commentTabList.indexOf(tab_owner+"."+tab_name);
		if (idOfComment>-1) 
			sb.append("&nbsp;<font color=yellow><span class=\"glyphicon glyphicon-comment\" onclick=\"showCommentForTable('"+tab_cat+"','"+env_id+"','"+tab_owner+"','"+tab_name+"');\"></span></font>&nbsp;");
		else 
			sb.append("&nbsp;<font color=gray><span class=\"glyphicon glyphicon-comment\" onclick=\"showCommentForTable('"+tab_cat+"','"+env_id+"','"+tab_owner+"','"+tab_name+"');\"></span></font>&nbsp;");
		
		sb.append("<span class=\"glyphicon glyphicon-list-alt\" onclick=\"showSqlEditor('"+env_id+"','0','"+tab_owner+"."+tab_name+"','','"+tab_cat+"');\"></span>");
		sb.append(" ");
		if (!tab_cat.equals("${default]")) sb.append("<font color=red><b>"+tab_cat+"</b></font>.");
		sb.append("<font color=blue><b>"+tab_owner+"</b></font>."+tab_name+"");
		sb.append(" "); 
		sb.append("<font color=red><b><span class=\"glyphicon glyphicon-share-alt\" onclick=\"showAppListForTable('"+tab_cat+"','"+tab_owner+"','"+tab_name+"');\"></span></b></font>");
		sb.append("</td>");
		sb.append("<td>");
		if (discovery_type.equals("CHILD"))
			sb.append(parent_pk_fields+"=>"+child_rel_fields);
		else 
			sb.append(child_rel_fields+"=>"+parent_pk_fields);
		sb.append("</td>");
		
		
		
		sb.append("<td align=right>");
		sb.append(match_rate+" %");
		sb.append("</td>");
		
		if (discovery_type.equals("CHILD")) {
			sb.append("<td align=center>");
			sb.append("<span class=\"glyphicon glyphicon-plus\" onclick=\"addTableAsChildFromDiscovery('"+tab_id+"','"+tab_cat+"*"+tab_owner+"*"+tab_name+"','"+child_rel_fields+"','"+family_id+"')\"></span>");
			sb.append("</td>");
		}
		

		sb.append("</tr>");
		
		
	}
	
	sb.append("</table>");
	
	return sb.toString();
}

//********************************************************************************
String discoveryLinkInfo(
		Connection conn, 
		HttpSession session, 
		ArrayList<String> orderedPkList,
		ArrayList<String[]>keys, 
		String discovery_type,  
		String rel_cat,
		String rel_owner, 
		String rel_table,
		String parent_tab_id,
		String family_id) {
	
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> linkInfo=new ArrayList<String[]>();
	for (int i=0;i<orderedPkList.size();i++)
		linkInfo.add(new String[]{"?",orderedPkList.get(i)});
	
	for (int i=0;i<keys.size();i++) {
		
		String owner="";
		String table="";
		String field="";
		String rel_field="";
		String rel_order="";
		
		if (discovery_type.equals("CHILD")) {
			owner=keys.get(i)[5];
			table=keys.get(i)[6];
			rel_field=keys.get(i)[7];
			rel_order=keys.get(i)[8];
			
			
			if (!owner.equals(rel_owner) || !table.equals(rel_table)) continue;
			
			if (orderedPkList.size()<Integer.parseInt(rel_order)) continue;
			
			String pk_field=orderedPkList.get(Integer.parseInt(rel_order)-1);
			
			linkInfo.set(Integer.parseInt(rel_order)-1, new String[]{rel_field, pk_field});
			
		} 

	} //for
	
	String rel_on_fields="";
			
	sb.append("<table class=table>");
			
	
	for (int i=0;i<linkInfo.size();i++) {
		
		
		sb.append("<tr>");
		
		if (rel_on_fields.length()>0) rel_on_fields=rel_on_fields+",";
		rel_on_fields=rel_on_fields+linkInfo.get(i)[1];
				
		for (int c=0;c<linkInfo.get(i).length;c++) 
			sb.append("<td><b><small>"+linkInfo.get(i)[c]+"</small></b></td>");
		
		sb.append("<td>");
		sb.append("<font color=green>");
		if (discovery_type.equals("CHILD"))
			sb.append("<span class=\"glyphicon glyphicon-plus\" onclick=\"addTableAsChildFromDiscovery('"+parent_tab_id+"','"+rel_cat+"*"+rel_owner+"*"+rel_table+"','"+rel_on_fields+"','"+family_id+"')\"></span>");
		else 
			sb.append("-");
		sb.append("</font>");
		sb.append("</td>");
		
		sb.append("</tr>");
	}
	
	
	
	sb.append("</table>");
	
	return sb.toString();
}


//*********************************************************************************
ArrayList<String[]> getRelations(DatabaseMetaData md,String owner, String table_name, String key_type) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	ResultSet rs=null;
	ResultSetMetaData rsmd=null;
	
	try {
		if (key_type.equals("EXPORTED"))
			rs=md.getExportedKeys(null, owner, table_name);
		else 
			rs=md.getImportedKeys(null, owner, table_name);
			
		rsmd=rs.getMetaData();
		int colcount=rsmd.getColumnCount();
		for (int i=0;i<colcount;i++) 
			System.out.print(rsmd.getColumnName(i+1)+"\t");
		
		
		while(rs.next()) {
			String[] row=new String[colcount];
			System.out.print("\n");
			for (int i=0;i<colcount;i++) {
				row[i]=rs.getString(i+1);
				System.out.print(row[i]+"\t");
			}
				
			ret1.add(row);
		}
		
	} catch(Exception e) {
		e.printStackTrace();
	} finally {
		try{rs.close();} catch(Exception e) {}
	}
	
	return ret1;
}


//**********************************************************************
String makeBulkConfigDlg(Connection conn, HttpSession session, String target_app_id, String target_env_id) {
	StringBuilder sb=new StringBuilder();
	
	

	sb.append("<input type=hidden id=bulk_config_app_id value="+target_app_id+">");
	sb.append("<input type=hidden id=bulk_config_env_id value="+target_env_id+">");

	
	sb.append("<h4>Bulk Configuration Import :</h4> ");


	
	sb.append("<ul>");
	sb.append("<li><b>Step 1</b>: Click <a href=\"sampleBulkConf.xlsx\">here</a> to download sample file</li>");
	sb.append("<li><b>Step 2</b>: Fill the file without changing it's structure</li>");
	sb.append("<li><b>Step 3</b>: Paste the content of the file below</li>");
	sb.append("<li><b>Step 4</b>: Click <b>Test Import</b> button to review</li>");
	sb.append("<li><b>Step 5</b>: Click <b>Run Import</b> button to finish</li>");
	sb.append("</ul>");

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append("<textarea id=bulk_config_memo rows=6 style=\"width:100%; font-family:Courier New, Courier, monospace; \" onclick=\"this.value='';\">");
	sb.append("</textarea>");
	sb.append("</div");
	sb.append("</div");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=testResults>");
	sb.append("</div");
	sb.append("</div");
	
	return sb.toString();
}
//**********************************************************************
String ORACLE_COL_LIST_SQL="select COLUMN_NAME from all_tab_columns where upper(OWNER)=upper(?) and upper(TABLE_NAME)=upper(?) ";
String MSQL_SYBASE_COL_LIST_SQL="select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where upper(TABLE_CATALOG)=upper(?) and upper(TABLE_SCHEMA)=upper(?) and upper(TABLE_NAME)=upper(?)";

ArrayList<String[]> getColList(Connection connApp, String db_type, String catalog, String schema, String table) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	setCatalogForConnection(connApp, catalog);
	
	if (db_type.equals("ORACLE")) {
		sql=ORACLE_COL_LIST_SQL;
		bindlist.add(new String[]{"STRING",schema});
		bindlist.add(new String[]{"STRING",table});
	}
	else if (db_type.equals("MSSQL") && db_type.equals("SYBASE")) {
		sql=MSQL_SYBASE_COL_LIST_SQL;
		bindlist.add(new String[]{"STRING",catalog});
		bindlist.add(new String[]{"STRING",schema});
		bindlist.add(new String[]{"STRING",table});
	}
	
	
	return getDbArrayApp(connApp, sql, Integer.MAX_VALUE, bindlist, false, schema);

}
	

//**********************************************************************
String testOrImportBulkConfig(Connection conn, HttpSession session, String target_app_id, String target_env_id, String bulk_config_memo, String to_perform) {
	StringBuilder sb=new StringBuilder();
	
	String db_type=getEnvDBParam(conn, target_env_id, "DB_TYPE");
	
	Connection connApp=getconn(conn, target_env_id);
	if (connApp==null) {
		sb.append("connection is not established.");
		return sb.toString();
	}

	sb.append("<input type=hidden id=bulk_configtest_done value=YES>");

	
	sb.append("<h4>Test Results :</h4> ");
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	sb.append("<tr>");
	sb.append("<td><b>Catalog</b></td>");
	sb.append("<td><b>Schema</b></td>");
	sb.append("<td><b>Table/View</b></td>");
	sb.append("<td><b>Column</b></td>");
	sb.append("<td><b>Masking Method</b></td>");
	sb.append("<td><b>Result</b></td>");
	sb.append("</tr>");
	


	String[] lines=bulk_config_memo.split("\n|\r");
	for (int i=0;i<lines.length;i++) {
		String line=lines[i];
		if (line.trim().length()<10) continue;
		if (line.toUpperCase().contains("CATALOG") &&line.contains("SCHEMA") &&line.contains("TABLE_NAME") &&line.contains("COLUMN_NAME") &&line.contains("MASKING_CODE") )
			continue;
		
		String catalog="";
		String schema="";
		String table_name="";
		String column_name="";
		String masking_code="";
		String masking_name="";
		String masking_id="0";

		
		String[] cols=line.split("\t");
		
		try {catalog=nvl(cols[0].trim().toUpperCase(),"${default}");} catch(Exception e) {continue;}
		try {schema=cols[1].trim().toUpperCase();} catch(Exception e) {continue;}
		try {table_name=cols[2].trim().toUpperCase();} catch(Exception e) {continue;}
		try {column_name=cols[3].trim().toUpperCase();} catch(Exception e) {continue;}
		try {masking_code=cols[4].trim().toUpperCase();} catch(Exception e) {continue;}
		masking_name=masking_code;
		
		
		ArrayList<String[]> colList=getColList(connApp, db_type, catalog, schema, table_name);
		
		boolean col_found=false;
		boolean table_found=true;
		boolean function_found=false;
		
		String sql="select id,name from tdm_mask_prof where short_code=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"STRING",masking_code});

		
		ArrayList<String[]> maskArr=getDbArrayConf(conn, sql, 1, bindlist);
		
		if (maskArr.size()==1) {
			function_found=true;
			masking_id=maskArr.get(0)[0];
			masking_name=maskArr.get(0)[1];
		}
		
		
		if (colList.size()==0) table_found=false;
		
		for (int c=0;c<colList.size();c++) {
			if (colList.get(c)[0].equalsIgnoreCase(column_name)) {
				column_name=colList.get(c)[0];
				col_found=true;
				break;
			}
		}
		
		String result="";
		boolean to_import=false;
		
		if (!table_found) result=result+"<br><font color=red>Column not found</font>";
		if (!col_found && result.length()==0) result=result+"<br><font color=red>Table/View not found</font>";
		if (!function_found && result.length()==0) result=result+"<br><font color=red>Masking Function not found</font>";
 

		System.out.println("TO_ PERFORM"+to_perform);
		
		if (table_found && col_found && function_found && to_perform.equals("YES")) { 
			boolean is_imported=importMaskingFunctions(conn,session,target_app_id,target_env_id,catalog, schema, table_name, column_name, masking_id);
			if (!is_imported) result=result+"<br><font color=red>Configuration is not imported</font>";
			
		}
		
		if (result.length()==0) {
			result="<font color=green>OK</font>";
		}
		
		sb.append("<tr>");
		sb.append("<td>"+catalog+"</td>");
		sb.append("<td>"+schema+"</td>");
		sb.append("<td>"+table_name+"</td>");
		sb.append("<td>"+column_name+"</td>");
		sb.append("<td>"+masking_name+"</td>");
		sb.append("<td>"+result+"</td>");
		sb.append("</tr>");
	} 
	
	sb.append("</table>");

	closeconn(connApp);

	
	return sb.toString();
}
//*******************************************************************
boolean importMaskingFunctions(Connection conn, HttpSession session, String app_id, String env_id, 
		String catalog, 
		String schema, 
		String table_name, 
		String column_name,
		String masking_id) {
	
	String tab_id_sql="select id from tdm_tabs where cat_name=? and schema_name=? and tab_name=? and app_id=?";
	String update_mask_id_sql="update tdm_fields set mask_prof_id=?  "+
								" where field_name=? "+
								" and tab_id in  (select id from tdm_tabs where cat_name=? and schema_name=? and tab_name=? and app_id=?) ";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	

	int tab_id=0;
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",catalog});
	bindlist.add(new String[]{"STRING",schema});
	bindlist.add(new String[]{"STRING",table_name});
	bindlist.add(new String[]{"INTEGER",app_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, tab_id_sql, 1, bindlist);
	if (arr.size()==1) 
		tab_id=Integer.parseInt(arr.get(0)[0]);
	
	if (tab_id==0) {
		String adding_table_name=catalog+"*"+schema+"*"+table_name;
		tab_id=addNewTable(conn, "DMASK", env_id, app_id, adding_table_name, "0","0", "0");
	}
		
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",masking_id});
	bindlist.add(new String[]{"STRING",column_name});
	bindlist.add(new String[]{"STRING",catalog});
	bindlist.add(new String[]{"STRING",schema});
	bindlist.add(new String[]{"STRING",table_name});
	bindlist.add(new String[]{"INTEGER",app_id});
	
	return execDBConf(conn, update_mask_id_sql, bindlist);
		
		
	
}
//*******************************************************************
String makeDMScreen(Connection conn, HttpSession session) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select p.id, proxy_name, p.status,  proxy_type, secure_client, proxy_port, "+
				"   target_host, target_port, proxy_charset, \n" + 
				"	target_app_id, (select a.name from tdm_apps a where id=target_app_id) target_application_name, \n" +
				"	target_env_id,  (select e.name from tdm_envs e where id=target_env_id)  target_env_name, \n" +
				"	date_format(start_date,?) start_date, "+
				"	date_format(last_heartbeat,?) last_heartbeat, "+
				"	date_format(last_reload_time,?) last_reload_time, "+
				" 	max_package_size, is_debug "+
				"	from tdm_proxy p \n" +
				"	order by  proxy_name";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	sb.append("<tr class=info>");
	
	sb.append("<td>");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addNewDMProxy(); >");
	sb.append("<span class=\"glyphicon glyphicon-plus\"></span>");
	sb.append(" Add New DM Proxy");
	sb.append("</button>");
	sb.append("</td>");
	
	sb.append("<td align=right>");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=listDMProxies(); >");
	sb.append("<span class=\"glyphicon glyphicon-refresh\"></span>");
	sb.append("</button>");
	sb.append("</td>");
	
	sb.append("</tr>");
	sb.append("</table>");
	
	if (arr.size()==0) {
		
		sb.append("No proxy found.");
		return sb.toString();
	}
	

	
	
	int col_count=3;
	int max_cols=12;
	int col_size=max_cols/col_count;
	
	StringBuilder sbDivs=new StringBuilder();
	StringBuilder sbProxy=new StringBuilder();

	
	String active_session_count_sql="select count(*) from tdm_proxy_session where proxy_id=? and status='ACTIVE'";
	
	for (int i=0;i<arr.size();i++) {
		String proxy_id=arr.get(i)[0];
		String proxy_name=arr.get(i)[1];
		String proxy_status=arr.get(i)[2];
		String proxy_type=arr.get(i)[3];
		String secure_client=arr.get(i)[4];
		String proxy_port=arr.get(i)[5];
		String proxy_target_host=arr.get(i)[6];
		String proxy_target_port=arr.get(i)[7];
		String proxy_charset=arr.get(i)[8];
		String proxy_target_app_id=arr.get(i)[9];
		String proxy_target_app_name=arr.get(i)[10];
		String proxy_target_env_id=arr.get(i)[11];
		String proxy_target_env_name=arr.get(i)[12];
		String start_date=arr.get(i)[13];
		String last_heartbeat=arr.get(i)[14];
		String last_reload_time=arr.get(i)[15];
		String max_package_size=arr.get(i)[16];
		String is_debug=arr.get(i)[17];
		
		String active_session_count="0";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",proxy_id});
		ArrayList<String[]> countArr=getDbArrayConf(conn, active_session_count_sql, 1, bindlist);
		 
		if (countArr!=null && countArr.size()==1) active_session_count=countArr.get(0)[0];
	
		
		
		sbProxy.setLength(0);
		sbProxy.append("<table class=table \"table-condensed table-striped\" width=\"80%\">");
		
		sbProxy.append("<tr bgcolor=\"#428bca\">");
		sbProxy.append("<td align=left style=\"vertical-align:middle\"width=\"100%\"><span class=badge>"+proxy_id+"</span> <b><font color=white>"+clearHtml(proxy_name)+"</font></b></td>");
		sbProxy.append("<td align=left style=\"vertical-align:middle\"><img src=\"img/db/"+proxy_type+".png\" border=0 width=80 height=40  style=\"border-radius: 50%;\"></td>");
		sbProxy.append("<td align=right style=\"vertical-align:middle\"><img src=\"img/proxy_status/"+proxy_status+".png\" border=0 width=30 height=30 alt=\""+proxy_status+"\"   style=\"border-radius: 50%;\"></td>");
		sbProxy.append("</tr>");
		
		sbProxy.append("<tr class=info>");
		sbProxy.append("<td align=left colspan=3>");
		
		if (proxy_status.equals("FAILED")) 
			sbProxy.append(" <button type=button class=\"btn btn-sm btn-danger\" onclick=\"showInfoDetail('"+proxy_id+"','tdm_proxy','error_log')\">...</button>");
		
		sbProxy.append(" <button type=button class=\"btn btn-sm btn-success\" onclick=\"showDMProxySessions('"+proxy_id+"','ACTIVE');\" data-toggle=\"tooltip\" title=\"Show active sessions\">");
		sbProxy.append("<span class=\"glyphicon glyphicon-user\"></span>");
		sbProxy.append("</button>");
		
		sbProxy.append(" <button type=button class=\"btn btn-sm btn-default\" onclick=\"showDMProxySessions('"+proxy_id+"','ALL');\" data-toggle=\"tooltip\" title=\"Show all sessions\" >");
		sbProxy.append("<span class=\"glyphicon glyphicon-user\"></span>");
		sbProxy.append("</button>");
		
		sbProxy.append(" <button type=button class=\"btn btn-sm btn-danger\" onclick=\"manageDMProxyBlacklist('"+proxy_id+"');\" data-toggle=\"tooltip\" title=\"Manage blacklist\" >");
		sbProxy.append("<span class=\"glyphicon glyphicon-ban-circle\"></span>");
		sbProxy.append("</button>");

		sbProxy.append(" <button type=button class=\"btn btn-sm btn-primary\" onclick=showDMProxyActions('"+proxy_id+"');  data-toggle=\"tooltip\" title=\"Open proxy configuration\" >");
		sbProxy.append("<span class=\"glyphicon glyphicon-cog\"></span>");
		sbProxy.append("</button>");

		sbProxy.append("</td>");
		sbProxy.append("</tr>");
		
		sbProxy.append("<tr class=active>");
		sbProxy.append("<td colspan=3>");
		
		
		
		sbProxy.append("<table class=\"table table-condensed table-striped table-bordered\">");
		sbProxy.append("<tr><td align=right width=\"30%\"><b><small> Active# :</small></b></td><td><span class=badge>"+active_session_count+"</span></td></tr>");
		sbProxy.append("<tr><td align=right width=\"30%\"><b><small> Database :</small></b></td><td>"+proxy_target_env_name+"</td></tr>");
		sbProxy.append("<tr><td align=right width=\"30%\"><b><small> Application :</small></b></td><td>"+proxy_target_app_name+"</td></tr>");
		sbProxy.append("<tr><td align=right width=\"30%\"><b><small> Listening :</small></b></td><td>"+proxy_port+"</td></tr>");
		sbProxy.append("<tr><td align=right width=\"30%\"><b><small> Forwarding :</small></b></td><td>"+proxy_target_host+":"+proxy_target_port+"</td></tr>");
		sbProxy.append("<tr><td align=right width=\"30%\"><b><small> Started@ :</small></b></td><td>"+start_date+"</td></tr>");
		sbProxy.append("<tr><td align=right width=\"30%\"><b><small> Heartbeat@ :</small></b></td><td>"+last_heartbeat+"</td></tr>");
		sbProxy.append("<tr><td align=right width=\"30%\"><b><small> Reconfigured@ :</small></b></td><td>"+last_reload_time+"</td></tr>");
		sbProxy.append("<tr><td align=right width=\"30%\"><b><small> Degugging :</small></b></td><td>"+is_debug+"</td></tr>");
		sbProxy.append("</table>");
		
		
		sbProxy.append("</td>");
		sbProxy.append("</tr>");
		
		sbProxy.append("</table>");

		int col_id=i % col_count;
		
		if (col_id==0) {
			sbDivs.setLength(0);
			sbDivs.append("<div class=row>");
			for (int c=0;c<col_count;c++) {
				sbDivs.append("<div class=\"col-md-"+col_size+"\" align=center>");
				sbDivs.append("#COLCONTENT_"+c);
				sbDivs.append("</div>");
			}
			sbDivs.append("</div>");
		}
		
		String search_str="#COLCONTENT_"+col_id;
		int pos=sbDivs.indexOf(search_str);
		if (pos>-1) {
			sbDivs.delete(pos, pos+search_str.length());
			sbDivs.insert(pos, sbProxy.toString());
		}
		
		
		if (col_id==col_count-1 || i==arr.size()-1)  sb.append(sbDivs.toString());

	}
	
	for (int i=0;i<col_count;i++) {
		String search_str="#COLCONTENT_"+i;
		int pos=sb.indexOf(search_str);
		if (pos>-1) sb.delete(pos, pos+search_str.length());
	}


	
	return sb.toString();
}

//*********************************************************************************
String makeDMConfigForm(Connection conn, HttpSession session, String proxy_id) {
	
	StringBuilder sb=new StringBuilder();
	
	String editing_proxy_id=nvl(proxy_id,"0");
	
	String proxy_name="";
	String proxy_type="";
	String proxy_port="10001";
	String target_host="localhost";
	String target_port="1521";
	String proxy_charset="";
	String target_app_id="0";
	String target_env_id="0";
	String max_package_size="2048";
	String is_debug="NO";
	String extra_args="";
	String protocol_configuration_id="0";
	String proxy_status="NEW";
	String secure_client="NO";
	String secure_public_key="";
	
	String sql="";

	if (!editing_proxy_id.equals("0")) {
		sql= "select proxy_name, proxy_type, proxy_port, target_host, target_port, proxy_charset, "+
				" target_app_id, target_env_id, max_package_size, is_debug, extra_args, "+
				" protocol_configuration_id, status, secure_client, secure_public_key \n" + 
				" from tdm_proxy p \n"+
				" where p.id=?";
	
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",proxy_id});
		
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		
		if (arr==null || arr.size()==0) {
			sb.append("No proxy found.");
			return sb.toString();
		}
		
		proxy_name=arr.get(0)[0];
		proxy_type=arr.get(0)[1];
		proxy_port=arr.get(0)[2];
		target_host=arr.get(0)[3];
		target_port=arr.get(0)[4];
		proxy_charset=arr.get(0)[5];
		target_app_id=arr.get(0)[6];
		target_env_id=arr.get(0)[7];
		max_package_size=arr.get(0)[8];
		is_debug=arr.get(0)[9];
		extra_args=arr.get(0)[10];
		protocol_configuration_id=arr.get(0)[11];
		proxy_status=arr.get(0)[12];
		secure_client=arr.get(0)[13];
		secure_public_key=arr.get(0)[14];
		
	}
	
	
	String disabled="disabled";
	if (proxy_status.equals("NEW") || proxy_status.equals("INACTIVE") || proxy_status.equals("STOP")) disabled="";

	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" style=\"min-height: 450px; max-height: 450px; overflow-x: scroll; overflow-y: scroll;\">");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Proxy Status :</b></td>");
	sb.append("<td>");
	sb.append(proxy_status);
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Proxy Name :</b></td>");
	sb.append("<td>");
	if (disabled.equals("disabled")) 
		sb.append(proxy_name);
	else 
		sb.append(makeText("proxy_name", proxy_name, "", 0));
	sb.append("</td>");
	sb.append("</tr>");
	


	
	
	sql="select 'ORACLE_T2','Oracle' from dual "+
			" union all  select 'MSSQL_T2','Microsoft SQL' from dual "+
			" union all  select 'MYSQL','MySQL' from dual "+
			" union all  select 'POSTGRESQL','PostgreSQL' from dual"+
			" union all select 'MONGODB','MongoDB' from dual "+
			" union all select 'HIVE','Hive' from dual "+
			" union all select 'GENERIC','Generic Proxy' from dual";
	sb.append("<tr>");
	sb.append("<td align=right><b> Proxy Type :</b></td>");
	sb.append("<td>");
	sb.append(makeCombo(conn, sql, "", disabled+" size=1 id=proxy_type", proxy_type, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sql="select 'YES' from dual union all select 'NO' from dual";
	sb.append("<tr>");
	sb.append("<td align=right><b> Secure Client :</b></td>");
	sb.append("<td>");
	sb.append(makeCombo(conn, sql, "", disabled+" size=1 id=secure_client", secure_client, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Security Public Key :</b></td>");
	sb.append("<td>");
	if (disabled.equals("disabled")) 
		sb.append(secure_public_key);
	else 
		sb.append(makeText("secure_public_key", secure_public_key, ""+disabled, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Listening Ports (comma delimited) :</b></td>");
	sb.append("<td>");
	if (disabled.equals("disabled")) 
		sb.append(proxy_port);
	else 
		sb.append(makeText("proxy_port", proxy_port, ""+disabled, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Target Host Address :</b></td>");
	sb.append("<td>");
	sb.append(makeText("target_host", target_host, ""+disabled, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Target Port :</b></td>");
	sb.append("<td>");
	if (disabled.equals("disabled")) 
		sb.append(target_port);
	else 
		sb.append(makeNumber("", "target_port", target_port, "", "EDIT", "5", "0", "", "", "", "1", "65535"));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Proxy Charset :</b></td>");
	sb.append("<td>");
	sb.append(makeText("proxy_charset", proxy_charset, ""+disabled, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	sql="select id, name from tdm_apps where app_type='DMASK' order by 2";
	sb.append("<tr>");
	sb.append("<td align=right><b> Configuration Application :</b></td>");
	sb.append("<td>");
	sb.append(makeCombo(conn, sql, "", disabled+" size=1  id=target_app_id", target_app_id, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sql="select id, name from tdm_envs where for_dynamic='YES' order by 2";
	sb.append("<tr>");
	sb.append("<td align=right><b> Target Database :</b></td>");
	sb.append("<td>");
	sb.append(makeCombo(conn, sql, "", disabled+" size=1 id=target_env_id", target_env_id, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Max. Package Size :</b></td>");
	sb.append("<td>");
	if (disabled.equals("disabled")) 
		sb.append(max_package_size);
	else 
		sb.append(makeNumber("", "max_package_size", max_package_size, "", "EDIT", "6", "0", "", "", "", "1", "999999"));
	sb.append("</td>");
	sb.append("</tr>");

	sql="select 'YES' from dual union all select 'NO' from dual";
	sb.append("<tr>");
	sb.append("<td align=right><b> Debug Mode :</b></td>");
	sb.append("<td>");
	sb.append(makeCombo(conn, sql, "", disabled+" size=1 id=is_debug", is_debug, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Arguments <a href=\"javascript:showProxyArguments()\"><span class=badge>?<span></a> :</b></td>");
	sb.append("<td>");
	sb.append("<textarea "+disabled+" id=extra_args rows=3 style=\"width:100%;\">"+extra_args+"</textarea>");
	sb.append("</td>");
	sb.append("</tr>");
	


	
	sb.append("</table>");
	
	sb.append("</div>");
	sb.append("</div>");
	
	return sb.toString();
}


//******************************************************************************
String makeAddnewDMProxyForm(Connection conn, HttpSession session) {
	StringBuilder sb=new StringBuilder();
	
	sb.append("<input type=hidden id=active_proxy_id value=\"0\">");
	
	sb.append(makeDMConfigForm(conn,session, "0"));
	
	return sb.toString();
}

//******************************************************************************
String makeDMProxyActions(Connection conn, HttpSession session, String proxy_id) {
	StringBuilder sb=new StringBuilder();
	
	String sql= "select proxy_name, p.status, is_debug from tdm_proxy p  where p.id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	sb.append("<input type=hidden id=active_proxy_id value=\""+proxy_id+"\">");
	
	if (arr==null || arr.size()==0) {
		sb.append("No proxy found.");
		return sb.toString();
	}
	
	String proxy_name=arr.get(0)[0];
	String proxy_status=arr.get(0)[1];
	String is_debug=arr.get(0)[2];
	
	
	
	sb.append("<h4><b>"+proxy_name+"</b></h4>");
	
	
	if (proxy_status.equals("ACTIVE")) {
		
		sb.append("<div class=\"row\">");
		sb.append("<div class=\"col-md-3\">");
	
	
		
		sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
		
		
		sb.append("<tr>");
		
		sb.append("<td align=center>");
		
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=stopDMProxy('"+proxy_id+"'); style=\"width:100%;\" >");
		sb.append("<span class=\"glyphicon glyphicon-unchecked\"></span>");
		sb.append(" Stop Proxy ");
		sb.append("</button>");
		
		sb.append("</td>");

		sb.append("</tr>");
		sb.append("<tr>");

		sb.append("<td align=center>");
		
		sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=reloadDMProxy('"+proxy_id+"');  style=\"width:100%;\" >");
		sb.append("<span class=\"glyphicon glyphicon-refresh\"></span>");
		sb.append(" Reload Proxy Configuration ");
		sb.append("</button>");
		
		sb.append("</td>");
		
		sb.append("</tr>");
		sb.append("<tr>");
		
		String debug_button_caption=" Stop Debugging ";
		if (is_debug.equals("NO"))
			debug_button_caption=" Start Debugging ";
		
		sb.append("<td align=center>");
		
		sb.append("<button type=button class=\"btn btn-sm btn-info\" onclick=changeProxyDebugFlag('"+proxy_id+"','"+is_debug+"');  style=\"width:100%;\" >");
		sb.append("<span class=\"glyphicon glyphicon-eye-open\"></span>");
		sb.append(debug_button_caption);
		sb.append("</button>");
		
		sb.append("</td>");
		sb.append("</tr>");
		
		sb.append("</table>");
		sb.append("</div>");
		
		
		sb.append("<div class=\"col-md-9\">");
		
		sb.append(makeDMConfigForm(conn,session,proxy_id));
		
		sb.append("</div>");
		sb.append("</div>");
		
		
		
		sb.append(makeProxyConfigLogs(conn,session, proxy_id));
		
		
	} 
	else  {
		
		sb.append("<div class=\"row\">");
		sb.append("<div class=\"col-md-3\">");
		
		sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
		
		sb.append("<tr>");

		sb.append("<td align=center colspan=2>");
		sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=startDMProxy('"+proxy_id+"');  style=\"width:100%;\" >");
		sb.append("<span class=\"glyphicon glyphicon-expand\"></span>");
		sb.append(" Start Proxy ");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("</tr>");
		sb.append("<tr>");
		
		sb.append("<td align=center colspan=2>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=removeDMProxy('"+proxy_id+"');  style=\"width:100%;\" >");
		sb.append("<span class=\"glyphicon glyphicon-remove\"></span>");
		sb.append(" Remove Proxy ");
		sb.append("</button>");
		sb.append("</td>");
		sb.append("</tr>");

		
		
		
		sb.append("</table>");
		sb.append("</div>");
		
		
		sb.append("<div class=\"col-md-9\">");
		
		sb.append(makeDMConfigForm(conn,session,proxy_id));
		
		sb.append("</div>");
		sb.append("</div>");
		
		
	} 
	
	
	return sb.toString();
}

//******************************************************************************
String makeProxyConfigLogs(Connection conn, HttpSession session, String proxy_id) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql= "select schema_name,table_name, log_info from tdm_proxy_config_log p  where p.proxy_id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	ArrayList<String[]> arrLog=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	if (arrLog.size()==0) {
		sb.append("No configuration error or warning found");
		return sb.toString();
	}
	
	sb.append("<span class=\"label label-warning\">Errors on Configuration Load : </span>");
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");

	for (int i=0;i<arrLog.size();i++) {
		String schema_name=arrLog.get(i)[0];
		String table_name=arrLog.get(i)[1];
		String log_info=arrLog.get(i)[2];
		
		
		sb.append("<tr>");
		sb.append("<td nowrap><b>"+schema_name+"."+table_name+"</b></td>");
		sb.append("<td width=\"100%\">");
		sb.append("<textarea readonly rows=3 style=\"width:100%\">");
		sb.append(log_info);
		sb.append("</textarea>");
		sb.append("</td>");
		sb.append("</tr>");
	}

	
	
	sb.append("</table>");
	
	return sb.toString();
}



//******************************************************************************
String makeDMFilterButon(Connection conn, HttpSession session, String proxy_id, String proxy_session_filter, String origin) {
	StringBuilder sb=new StringBuilder();
	
	String filter_username=nvl((String) session.getAttribute(proxy_id+"_"+proxy_session_filter+"_filter_username") ,"");
	String filter_session_info=nvl((String) session.getAttribute(proxy_id+"_"+proxy_session_filter+"_filter_session_info") ,"");
	String filter_command=nvl((String) session.getAttribute(proxy_id+"_"+proxy_session_filter+"_filter_command") ,"");
	
	String bt_class="btn btn-sm btn-primary";
	if (filter_username.trim().length()>0 || filter_session_info.trim().length()>0 || filter_command.trim().length()>0)
		bt_class="btn btn-md btn-warning";
	
	sb.append(" <button type=button  class=\""+bt_class+"\"  onclick=\"setFilterSessions('"+proxy_id+"','"+proxy_session_filter+"','"+origin+"');\" >");
	sb.append("<span class=\"glyphicon glyphicon-filter\"></span>");
	sb.append("</button>");

	
	return sb.toString();
}


//******************************************************************************
String makeDMProxySessionList(Connection conn, HttpSession session, String proxy_id, String proxy_session_filter) {
	StringBuilder sb=new StringBuilder();
	
	String sql= "select  \n" + 
				"	id,  \n" + 
				"	username,  \n" + 
				"	status,  \n" + 
				"   cancel_flag, \n" +
				"   tracing_flag, \n" +
				"	date_format(start_date, ?) start_date,  \n" + 
				"	date_format(finish_date, ?) finish_date,  \n" + 
				"	date_format(last_activity_date, ?) last_activity_date,  \n" + 
				"	date_format(exception_time_to, ?) exception_time_to,  \n" + 
				"	session_info \n" + 
				"	from tdm_proxy_session session  \n" + 
				"	where proxy_id=? #STATUSFILTER# #USERFILTER# #SESSIONFILTER# #COMMANDFILTER#\n" + 
				"	order by id ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	if (proxy_session_filter.equals("ALL"))
		sql=sql.replace("#STATUSFILTER#", "");
	else {
		sql=sql.replace("#STATUSFILTER#", " and status=? ");
		bindlist.add(new String[]{"STRING",proxy_session_filter});

	}

	String filter_username=nvl((String) session.getAttribute(proxy_id+"_"+proxy_session_filter+"_filter_username") ,"");
	String filter_session_info=nvl((String) session.getAttribute(proxy_id+"_"+proxy_session_filter+"_filter_session_info") ,"");
	String filter_command=nvl((String) session.getAttribute(proxy_id+"_"+proxy_session_filter+"_filter_command") ,"");
	
	//----------------------------------------------------
	String username_sql_in="";
	String[] arrx=filter_username.split(" ");
	for (int i=0;i<arrx.length;i++) {
		String el=arrx[i];
		if (el.trim().length()==0) continue;
		if (username_sql_in.length()>0) username_sql_in=username_sql_in+",";
		username_sql_in=username_sql_in+"'"+el.toUpperCase()+"'";
	}
	if (username_sql_in.length()>0)
		sql=sql.replace("#USERFILTER#", "\n and username in ("+username_sql_in+") ");
	else  
		sql=sql.replace("#USERFILTER#", "");
	
	//----------------------------------------------------
	String filter_session="";
	if (filter_session_info.contains("%")) 
		filter_session=" upper(session_info) like '%"+filter_session_info.toUpperCase()+"%' ";
	else  {
		arrx=filter_session_info.split(" ");
		for (int i=0;i<arrx.length;i++) {
			String el=arrx[i];
			if (el.trim().length()==0) continue;
			if (filter_session.length()>0) filter_session=filter_session+" or ";
			
			
			filter_session=filter_session+" upper(session_info) like '%"+el.toUpperCase()+"%' ";
		}
	}
	if (filter_session.length()>0)
		sql=sql.replace("#SESSIONFILTER#", "\n and  ("+filter_session+") ");
	else 
		sql=sql.replace("#SESSIONFILTER#", "");
	
	
	//----------------------------------------------------
	
	String filter_command_sql="";
	if (filter_command.contains("%")) 
		filter_command_sql=" upper(original_sql) like '%"+filter_command.toUpperCase()+"%' ";
	else  {
		arrx=filter_command.split(" ");
		for (int i=0;i<arrx.length;i++) {
			String el=arrx[i];
			if (el.trim().length()==0) continue;
			if (filter_command_sql.length()>0) filter_command_sql=filter_command_sql+" or ";
			
			
			filter_command_sql=filter_command_sql+" upper(original_sql) like '%"+el.toUpperCase()+"%' ";
		}
	}
	if (filter_command_sql.length()>0)
		sql=sql.replace("#COMMANDFILTER#", "\n and  exists  ( select 1 from tdm_proxy_log where proxy_session_id=session.id and ( "+filter_command_sql+" ) ) ");
	else 
		sql=sql.replace("#COMMANDFILTER#", "");


	

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 200, bindlist);
	
	
	sb.append("<input type=hidden id=proxy_session_filter value=\""+proxy_session_filter+"\" >");
	
	
	sb.append("<table class=\"table\"><tr>");

	
	
	sb.append("<td nowrap>");
	
	sb.append(" <button type=button  onclick=\"listSessionCommands('"+proxy_id+"', '"+proxy_session_filter+"');\" >");
	sb.append("<span class=\"glyphicon glyphicon-flash\"></span> Show Commands");
	sb.append("</button>");
	
	
	sql="select proxy_type from tdm_proxy where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	ArrayList<String[]> arrType=getDbArrayConf(conn, sql, 1, bindlist);
	
	String proxy_type=arrType.get(0)[0];
	
	if (proxy_session_filter.equals("ACTIVE")) {
		sb.append(" <button type=button  onclick=\"setExceptionForSession('"+proxy_id+"');\" >");
		sb.append("<span class=\"glyphicon glyphicon-time\"></span> Set Exception");
		sb.append("</button>");
		
		sb.append(" <button type=button  onclick=\"clearExceptionForSession('"+proxy_id+"');\" >");
		sb.append("<font color=red><span class=\"glyphicon glyphicon-time\"></font> </span> Clear Exception");
		sb.append("</button>");
		
		sb.append(" <button type=button  onclick=\"traceSessions('"+proxy_id+"','START');\" >");
		sb.append("<span class=\"glyphicon glyphicon-eye-open\"></span> Set Tracing ");
		sb.append("</button>");
		
		sb.append(" <button type=button  onclick=\"traceSessions('"+proxy_id+"','STOP');\" >");
		sb.append("<font color=red><span class=\"glyphicon glyphicon-eye-open\"></span></font> Clear Tracing ");
		sb.append("</button>");
		
		sb.append(" <button type=button  onclick=\"terminateSessions('"+proxy_id+"');\" >");
		sb.append("<span class=\"glyphicon glyphicon-stop\"></span> Terminate");
		sb.append("</button>");
	}
	
	
	sb.append(" <button type=button  onclick=\"blacklistSessions('"+proxy_id+"');\" >");
	sb.append("<span class=\"glyphicon glyphicon-ban-circle\"></span> Add to Redlist");
	sb.append("</button>");
	
	sb.append("</td>");
	

	
	
	sb.append("<td nowrap align=right>");
	
	sb.append(makeDMFilterButon(conn, session,proxy_id, proxy_session_filter,"SESSION"));


	
	sb.append(" <button type=button class=\"btn btn-sm btn-success\" onclick=\"showDMProxySessions('"+proxy_id+"','"+proxy_session_filter+"');\" >");
	sb.append("<span class=\"glyphicon glyphicon-refresh\"></span>");
	sb.append("</button>");
	
	sb.append("</td>");
	
	
	
	sb.append("</tr></table>");
	
	if (arr==null || arr.size()==0) {
		sb.append("No session found.");
		return sb.toString();
	}
	
	
	String selected_Session_ids=nvl((String) session.getAttribute("SELECTED_SESSION_IDS_FOR_PROXY_"+proxy_id+"_"+proxy_session_filter) ,"");
	String[] arrSIds=selected_Session_ids.split(",");
	ArrayList<String> selectedIdArr=new ArrayList<String>();
	for (int i=0;i<arrSIds.length;i++) selectedIdArr.add(arrSIds[i]);
	
	
	sb.append("<div   style=\"min-height: 430px; max-height: 430px; overflow-x: scroll; overflow-y: scroll;\" >");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\" >");
	
	sb.append("<tr class=info>");
	sb.append("<td align=center><b><input type=checkbox id=ch_select_all_sessions onclick=selectSessionAll()></b></td>");
	sb.append("<td><b>User</b></td>");
	sb.append("<td><b>Status</b></td>");
	sb.append("<td><b>Terminate</b></td>");
	sb.append("<td><b>Trace</b></td>");
	sb.append("<td><b>Except@</b></td>");
	sb.append("<td><b>Session Info</b></td>");
	sb.append("<td><b>Start@</b></td>");
	sb.append("<td><b>Last Active@</b></td>");
	sb.append("<td><b>Finish@</b></td>");
	sb.append("</tr>");
	
	
	
	
	
	for (int i=0;i<arr.size();i++) {
		String session_id=arr.get(i)[0];
		String user=arr.get(i)[1];
		String status=arr.get(i)[2];
		String cancel_flag=arr.get(i)[3];
		String tracing_flag=arr.get(i)[4];
		String start_date=arr.get(i)[5];
		String finish_date=arr.get(i)[6];
		String last_activity_date=arr.get(i)[7];
		String exception_time_to=arr.get(i)[8];
		String session_info=arr.get(i)[9];
		
		
		
		String tr_class="active";
		if (status.equals("ACTIVE")) tr_class="success";
		else if (status.equals("ABORTED") || status.equals("CLOSED")) tr_class="danger";
		
		
		String ch_checked="";
		if (selectedIdArr.indexOf(session_id)>-1) ch_checked="checked";




		
		sb.append("<tr class="+tr_class+">");
		
		sb.append("<td align=center> <input type=checkbox  "+ch_checked+" id=\"session_ch_"+i+"\" value=\""+session_id+"\"> </td>");
		sb.append("<td><small>"+user+"</small></td>");
		sb.append("<td><small>"+status+"</small></td>");
		
		if (cancel_flag.equals("YES")) 
			sb.append("<td align=center><small><font color=red><span class=\"glyphicon glyphicon-warning-sign\"></span></small></td>");
		else 
			sb.append("<td align=center>-</td>");
		
		if (tracing_flag.equals("YES")) 
			sb.append("<td align=center><small><font color=blue><span class=\"glyphicon glyphicon-eye-open\"></span></small></td>");
		else 
			sb.append("<td align=center>-</td>");
		
		
		
		
		if (exception_time_to.length()==0)
			sb.append("<td>-</td>");
		else 
			sb.append("<td><small><font color=red><span class=\"glyphicon glyphicon-warning-sign\"></span></font> "+exception_time_to+"</small></td>");



		sb.append("<td nowrap>");
		sb.append(makeDDMSessionInfoTable(conn, session, session_id, session_info, tr_class));
		sb.append("</td>");
		
		sb.append("<td nowrap><small>"+start_date+"</small></td>");
		sb.append("<td nowrap><small>"+last_activity_date+"</small></td>");
		sb.append("<td nowrap><small>"+finish_date+"</small></td>");
		

		
		sb.append("</tr>");
		
	}
	
	sb.append("</table>");
	
	
	sb.append("</div>"); //scrolling div
	
	return sb.toString();
}


//*********************************************************************************
String makeDDMSessionInfoTable(Connection conn, HttpSession session, String proxy_session_id, String session_info, String tr_class) {
	
	StringBuilder sb=new StringBuilder();
	
	StringBuilder sbSessionheader=new StringBuilder();
	StringBuilder sbSessioninfo=new StringBuilder();
	
	
	
	sb.append("<table class=\"table table-condensed table-striped\">");
	ArrayList<String[]> params=getSessionVariablesAsArrayList(session_info);
	for (int s=0;s<params.size();s++) {
		String key=params.get(s)[0];
		String val=params.get(s)[1];
		
		sb.append("<tr>");
		sb.append("<td nowrap><b><small><small>"+key+ " : </small></small><b></td><td nowrap><small><small>"+clearHtml(val)+"</small></small></td>");
		sb.append("</tr>");
	}
		
	sb.append("</table>");
	
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();
	collapseItems.add(new String[]{
			"colSessionParamsForSession_"+proxy_session_id,
			"Session Parameters for ["+proxy_session_id+"]",
			sb.toString(),
			"user.png",
			""});
					
	return addCollapse("listOfSessionParametersForSession"+proxy_session_id,collapseItems);
	
	
	//return sb.toString();
}

//*********************************************************************************
ArrayList<String[]> getSessionVariablesAsArrayList(String session_info) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	String[] lines=session_info.split("\n");
	
	
	for (int s=0;s<lines.length;s++) {
		try {
			String a_line=lines[s];
			if (a_line.trim().length()==0) continue;
			int ind=a_line.indexOf("=");
			if (ind==-1) continue;
			String key=a_line.substring(0,ind);
			String val=a_line.substring(ind+1);
			
			ret1.add(new String[]{key,val});

			
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		
		
	}
	
	return ret1;
}
//*********************************************************************************
void  setDMProxyStatus(Connection conn, HttpSession session, String proxy_id, String status) {
	String sql= "update tdm_proxy set status=? where id=? ";

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",status});
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	execDBConf(conn, sql, bindlist);


}


//*********************************************************************************
void  reloadDMProxyConfigurations(Connection conn, HttpSession session, String proxy_id) {
	String sql= "update tdm_proxy set reload_flag='YES' where target_app_id=? and status<>'INACTIVE'";

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	execDBConf(conn, sql, bindlist);


}

//*********************************************************************************
void  reloadDMProxy(Connection conn, HttpSession session, String proxy_id) {
	String sql= "update tdm_proxy set reload_flag='YES' where id=? ";

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	execDBConf(conn, sql, bindlist);


}

//*********************************************************************************
void  changeProxyDebugFlag(Connection conn, HttpSession session, String proxy_id, String current_debug_flag) {
	String sql= "update tdm_proxy set reload_flag='YES', is_debug=? where id=? ";

	String new_debug_flag="NO";
	if (current_debug_flag.equals("NO")) new_debug_flag="YES";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",new_debug_flag});
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	execDBConf(conn, sql, bindlist);


}
//*********************************************************************************
void  removeDMProxy(Connection conn, HttpSession session, String proxy_id) {
	String sql= "delete from tdm_proxy where id=? ";

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	execDBConf(conn, sql, bindlist);


}


//*********************************************************************************
void  saveProxyInfo(Connection conn, HttpSession session, 
		String proxy_id, 
		String proxy_name,
		String proxy_info,
		String target_app_id,
		String target_env_id) {
	
	String sql= "";

	
	String proxy_type="";
	String secure_client="NO";
	String secure_public_key="";
	String proxy_port="0";
	String target_host="";
	int target_port=0;
	String proxy_charset="utf-8";
	int max_package_size=4096;
	String is_debug="NO";
	String extra_args="";


	String[] arr=proxy_info.split(":");
	
	try {proxy_type=arr[0];} catch(Exception e) {}
	try {secure_client=arr[1];} catch(Exception e) {}
	try {secure_public_key=arr[2];} catch(Exception e) {}
	if (secure_public_key.equals("-")) secure_public_key="";
	
	try {proxy_port=arr[3];} catch(Exception e) {}
	try {target_host=arr[4];} catch(Exception e) {}
	try {target_port=Integer.parseInt(arr[5]);} catch(Exception e) {}
	try {proxy_charset=arr[6];} catch(Exception e) {}
	try {max_package_size=Integer.parseInt(arr[7]);} catch(Exception e) {}
	try {is_debug=arr[8];} catch(Exception e) {}
	try {extra_args=arr[9];} catch(Exception e) {}

	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",proxy_name});
	bindlist.add(new String[]{"STRING",proxy_type});
	bindlist.add(new String[]{"STRING",secure_client});
	bindlist.add(new String[]{"STRING",secure_public_key});
	bindlist.add(new String[]{"STRING",""+proxy_port});
	bindlist.add(new String[]{"STRING",target_host});
	bindlist.add(new String[]{"INTEGER",""+target_port});
	bindlist.add(new String[]{"STRING",proxy_charset});
	bindlist.add(new String[]{"INTEGER",target_app_id});
	bindlist.add(new String[]{"INTEGER",target_env_id});
	bindlist.add(new String[]{"INTEGER",""+max_package_size});
	bindlist.add(new String[]{"STRING",is_debug});
	bindlist.add(new String[]{"STRING",extra_args});


	if (proxy_id.equals("0")) {
		sql= "insert into tdm_proxy  (proxy_name, proxy_type, secure_client, secure_public_key, proxy_port, target_host, target_port, proxy_charset, target_app_id, target_env_id, max_package_size, is_debug, extra_args)   "+
				" values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ";
	} else {
		sql= "update tdm_proxy set proxy_name=?, proxy_type=?, secure_client=?, secure_public_key=?, "+
				" proxy_port=?, target_host=?, target_port=?, proxy_charset=?, "+
				" target_app_id=?, target_env_id=?, max_package_size=?, is_debug=?, extra_args=? "+
				" where id=? ";
		
		bindlist.add(new String[]{"INTEGER",proxy_id});
		
	}
	
	
	
	
	
	execDBConf(conn, sql, bindlist);


}

//******************************************************************************************
String makeDynamicMaskingContentRules(Connection conn, HttpSession session, String app_id) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select "+
		" id, rule_order, rule_scope, rule_type, rule_parameter1, env_id, min_match_rate, mask_prof_id, rule_notes, valid " + 
		" from tdm_proxy_rules "+
		" where app_id=?  "+
		" order by rule_order";
	
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	ArrayList<String[]> ruleArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addNewContentBasedRule('"+app_id+"')>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"></span>");
	sb.append(" Add New Rule ");
	sb.append("</button>");
	
	if (ruleArr.size()==0) {
		sb.append("No rule defined!");
		return sb.toString();
	}
	
	
	ArrayList<String[]> ruleList=new ArrayList<String[]>();
	ruleList.add(new String[]{"EQUALS","Equals To"});
	ruleList.add(new String[]{"IN","Eqauals Any In a List"});
	ruleList.add(new String[]{"CONTAINS","Contains"});
	ruleList.add(new String[]{"CONTAINS_ANY","Contains Any in a List"});
	ruleList.add(new String[]{"REGEX","Regular Expression"});
	ruleList.add(new String[]{"JAVASCRIPT","Javascript Engine"});
	ruleList.add(new String[]{"STARTS_WITH","Starts With"});
	ruleList.add(new String[]{"ENDS_WITH","Ends With"});
	
	ArrayList<String[]> matchRateList=new ArrayList<String[]>();
	for (int i=1;i<=100;i++)
		matchRateList.add(new String[]{""+i, ""+i +" %" });
	
	ArrayList<String[]> yesnoList=new ArrayList<String[]>();
	yesnoList.add(new String[]{"YES","YES"});
	yesnoList.add(new String[]{"NO","NO"});
	
	ArrayList<String[]> scopeList=new ArrayList<String[]>();
	scopeList.add(new String[]{"DATA","Data"});
	scopeList.add(new String[]{"COL","Name"});
	scopeList.add(new String[]{"COL_TYPE","Type"});
	scopeList.add(new String[]{"EXPR","Expression"});

	sql="select id, name "+
		" from tdm_mask_prof "+
		" where valid='YES' "+
		" and rule_id in ('HIDE','FIXED','RANDOM_NUMBER','RANDOM_STRING','SETNULL','ENCAPSULATE') "+
		" order by 2";
	bindlist.clear();
	ArrayList<String[]> maskProfList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr class=info>");
	sb.append("<td><b></b></td>");
	sb.append("<td><b>Note</b></td>");
	sb.append("<td><b>Scope</b></td>");
	sb.append("<td><b>Search Type</b></td>");
	sb.append("<td><b>Search Parameter (sql permitted) </b></td>");
	sb.append("<td><b>Source Database</b></td>");
	sb.append("<td><b>Min. %</b></td>");
	sb.append("<td><b>Masking Profile</b></td>");
	sb.append("<td><b>Exception</b></td>");
	sb.append("<td><b>Valid</b></td>");
	sb.append("<td><b></b></td>");
	sb.append("</tr>");
	
	
	
	for (int i=0;i<ruleArr.size();i++) {
		
		String rule_id=ruleArr.get(i)[0];
		String rule_order=ruleArr.get(i)[1];
		String rule_scope=ruleArr.get(i)[2];
		String rule_type=ruleArr.get(i)[3];
		String rule_parameter1=ruleArr.get(i)[4];
		String env_id=ruleArr.get(i)[5];
		String min_match_rate=ruleArr.get(i)[6];
		String mask_prof_id=ruleArr.get(i)[7];
		String rule_notes=ruleArr.get(i)[8];
		String valid=ruleArr.get(i)[9];
		
		
		String tr_class="active";
		if (valid.equals("NO")) tr_class="danger";
		
		sb.append("<tr class=\""+tr_class+"\">");
		
		sb.append("<td align=center nowrap >");
		if (i>0) {
			sb.append("<font color=blue ><b>");
			sb.append("<span class=\"glyphicon glyphicon-arrow-up\" onclick=setContentBasedRuleOrder('"+app_id+"','"+rule_id+"','UP')></span>");
			sb.append("</b></font>");
		}
		
		sb.append(" ");
		
		if (i<ruleArr.size()-1) {
			sb.append("<font color=blue><b>");
			sb.append("<span class=\"glyphicon glyphicon-arrow-down\" onclick=setContentBasedRuleOrder('"+app_id+"','"+rule_id+"','DOWN')></span>");
			sb.append("</b></font>");
		}
		
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append("<input type=text id=br_rule_notes_"+rule_id+" onchange=\"changeContentBasedRuleField(this, '"+app_id+"', '"+rule_id+"','rule_notes');\" value=\""+clearHtml(rule_notes)+"\" size=20>");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(scopeList, "", "size=1 id=cbr_rule_scope_"+rule_id+" onchange=\"changeContentBasedRuleField(this, '"+app_id+"', '"+rule_id+"','rule_scope');\" ", rule_scope, 100));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(ruleList, "", "size=1 id=cbr_rule_type_"+rule_id+" onchange=\"changeContentBasedRuleField(this, '"+app_id+"', '"+rule_id+"','rule_type');\" ", rule_type, 150));
		sb.append("</td>");
		
		
		sb.append("<td width=\"50%\">");
		sb.append("<textarea id=br_rule_parameter1_"+rule_id+" rows=3 style=\"width:200px; \" onchange=\"changeContentBasedRuleField(this, '"+app_id+"', '"+rule_id+"','rule_parameter1');\" >");
		sb.append(clearHtml(rule_parameter1));
		sb.append("</textarea>");	
		sb.append("</td>");
		
		sql="select id, name from tdm_envs order by 2";
		sb.append("<td>");
		sb.append(makeCombo(conn, sql, "", "id=cbr_env_id"+rule_id+" onchange=\"changeContentBasedRuleField(this, '"+app_id+"', '"+rule_id+"','env_id');\" ", env_id, 180));
		sb.append("</td>");
		
		
		sb.append("<td>");
		sb.append(makeComboArr(matchRateList, "", "size=1 id=cbr_min_match_rate_"+rule_id+" onchange=\"changeContentBasedRuleField(this, '"+app_id+"', '"+rule_id+"','min_match_rate');\" ", min_match_rate, 80));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(maskProfList, "", " id=cbr_mask_prof_id_"+rule_id+" onchange=\"changeContentBasedRuleField(this, '"+app_id+"', '"+rule_id+"','mask_prof_id');\" ", mask_prof_id, 180));
		sb.append("</td>");
		
		
		sb.append("<td align=center>");
		sb.append("<div id=exception_RULE_"+rule_id+">");
		sb.append(makeExceptionButton(conn, session, "RULE",rule_id));
		sb.append("</div>");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(yesnoList, "", "size=1 id=cbr_valid_"+rule_id+" onchange=\"changeContentBasedRuleField(this, '"+app_id+"', '"+rule_id+"','valid');\" ", valid, 80));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=removeContentBasedRule('"+app_id+"','"+rule_id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-remove\"></span>");
		sb.append("</button>");
		sb.append("</td>");
	
		

		
		
		sb.append("</tr>");
	}
	
	sb.append("</table>");


	return sb.toString();
}


//******************************************************************************************
String makeDynamicMaskingStatementExceptions(Connection conn, HttpSession session, String app_id) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	sql="select id, check_field, check_rule, check_parameter, env_id, "+
		" new_command, case_sensitive, valid "+
		" from tdm_proxy_statement_exception "+
		" where app_id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",""+app_id});
	
	ArrayList<String[]> arrStmtEx=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addNewStatementException('"+app_id+"')>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"></span>");
	sb.append(" Add New Statement Exception ");
	sb.append("</button>");
	
	if (arrStmtEx.size()==0) {
		sb.append("<br>No rule defined!");
		return sb.toString();
	}
	
	
	
	
	ArrayList<String[]> checkFieldArr=new ArrayList<String[]>();
	checkFieldArr.add(new String[]{"SQL","SQL Statement"});
	checkFieldArr.add(new String[]{"TYPE","Type of Statement"});
	
	ArrayList<String[]> checkList=new ArrayList<String[]>();
	
	checkList.add(new String[]{"EQUALS","Equals"});
	checkList.add(new String[]{"NOT_EQUALS","Not Equals"});
	checkList.add(new String[]{"CONTAINS","Contains"});
	checkList.add(new String[]{"NOT_CONTAINS","Doesn't Contain"});
	checkList.add(new String[]{"IS_EMPTY","Is Empty"});
	checkList.add(new String[]{"IS_NOT_EMPTY","Is Not Empty"});
	checkList.add(new String[]{"REGEX","Matches Regular Expression"});
	checkList.add(new String[]{"NOT_REGEX","Doesn't Match Regular Expression"});
	
	ArrayList<String[]> yesnoArr=new ArrayList<String[]>();
	yesnoArr.add(new String[]{"YES","Yes"});
	yesnoArr.add(new String[]{"NO","No"});
	
	
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	
	
	sb.append("<tr class=info>");
	sb.append("<td><b>Scope</b></td>");
	sb.append("<td><b>Check</b></td>");
	sb.append("<td><b>Parameter (SQL allowed)</b></td>");
	sb.append("<td><b>Source Database</b></td>");
	sb.append("<td><b>Change To</b></td>");
	sb.append("<td><b>Case Sensitive</b></td>");
	sb.append("<td><b>Valid</b></td>");
	sb.append("<td><b></b></td>");
	sb.append("</tr>");
	
	for (int i=0;i<arrStmtEx.size();i++) {
		String id=arrStmtEx.get(i)[0];
		String check_field=arrStmtEx.get(i)[1];
		String check_rule=arrStmtEx.get(i)[2];
		String check_parameter=arrStmtEx.get(i)[3];
		String env_id=arrStmtEx.get(i)[4];
		String new_command=arrStmtEx.get(i)[5];
		String case_sensitive=arrStmtEx.get(i)[6];
		String valid=arrStmtEx.get(i)[7];
		
		if (valid.equals("YES"))
			sb.append("<tr>");
		else 
			sb.append("<tr class=danger>");
		
		
		sb.append("<td>");
		sb.append(makeComboArr(checkFieldArr, "", "size=1 id=check_field  onchange=\"saveStatementExceptionField(this,'"+id+"');\"", check_field, 200));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(checkList, "", "size=1 id=check_rule  onchange=\"saveStatementExceptionField(this,'"+id+"');\"", check_rule, 200));
		sb.append("</td>");
		
		sb.append("<td width=\"30%\">");
		sb.append("<textarea id=check_parameter rows=4 style=\"width:200px;\" onchange=\"saveStatementExceptionField(this,'"+id+"');\" >" );
		sb.append(clearHtml(check_parameter));
		sb.append("</textarea>");
		sb.append("</td>");
		
		sql="select id, name from tdm_envs order by 2";
		sb.append("<td>");
		sb.append(makeCombo(conn, sql, "", "id=env_id  onchange=\"saveStatementExceptionField(this,'"+id+"');\" ", env_id, 180));
		sb.append("</td>");
		
		sb.append("<td width=\"30%\">");
		sb.append("<textarea id=new_command rows=4 style=\"width:200px;\" onchange=\"saveStatementExceptionField(this,'"+id+"');\" >" );
		sb.append(clearHtml(new_command));
		sb.append("</textarea>");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(yesnoArr, "", "size=1 id=case_sensitive  onchange=\"saveStatementExceptionField(this,'"+id+"');\"" , case_sensitive, 80));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(yesnoArr, "", "size=1 id=valid  onchange=\"saveStatementExceptionField(this,'"+id+"');\"", valid, 80));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=removeStatementException('"+app_id+"','"+id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-remove\"></span>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("</tr>");
		
	}
	

	sb.append("</table>");
	
	

	return sb.toString();
}

//******************************************************************************************
String makeDynamicMaskingLogExceptions(Connection conn, HttpSession session, String app_id) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, check_field, check_rule, check_parameter, env_id, case_sensitive, valid from tdm_proxy_log_exception where app_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",""+app_id});
	
	ArrayList<String[]> arrLogEx=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addNewLogException('"+app_id+"')>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"></span>");
	sb.append(" Add New Log Exception ");
	sb.append("</button>");
	
	if (arrLogEx.size()==0) {
		sb.append("<br>No rule defined!");
		return sb.toString();
	}
	
	ArrayList<String[]> scopeArr=new ArrayList<String[]>();
	scopeArr.add(new String[]{"SQL","SQL Statement"});
	scopeArr.add(new String[]{"USERNAME","DB Username"});
	
	ArrayList<String[]> checkList=new ArrayList<String[]>();
	
	checkList.add(new String[]{"EQUALS","Equals"});
	checkList.add(new String[]{"NOT_EQUALS","Not Equals"});
	checkList.add(new String[]{"CONTAINS","Contains"});
	checkList.add(new String[]{"NOT_CONTAINS","Doesn't Contain"});
	checkList.add(new String[]{"IS_EMPTY","Is Empty"});
	checkList.add(new String[]{"IS_NOT_EMPTY","Is Not Empty"});
	checkList.add(new String[]{"REGEX","Matches Regular Expression"});
	checkList.add(new String[]{"NOT_REGEX","Doesn't Match Regular Expression"});
	
	ArrayList<String[]> yesnoArr=new ArrayList<String[]>();
	yesnoArr.add(new String[]{"YES","Yes"});
	yesnoArr.add(new String[]{"NO","No"});
	
	
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr class=info>");
	sb.append("<td><b>Scope</b></td>");
	sb.append("<td><b>Check</b></td>");
	sb.append("<td><b>Parameter (SQL is permitted)</b></td>");
	sb.append("<td><b>Source Database</b></td>");
	sb.append("<td><b>Case Sensitive</b></td>");
	sb.append("<td><b>Valid</b></td>");
	sb.append("<td><b></b></td>");
	sb.append("</tr>");
	
	for (int i=0;i<arrLogEx.size();i++) {
		String id=arrLogEx.get(i)[0];
		String check_field=arrLogEx.get(i)[1];
		String check_rule=arrLogEx.get(i)[2];
		String check_parameter=arrLogEx.get(i)[3];
		String env_id=arrLogEx.get(i)[4];
		String case_sensitive=arrLogEx.get(i)[5];
		String valid=arrLogEx.get(i)[6];
		
		
		if (valid.equals("YES"))
			sb.append("<tr class=active>");
		else 
			sb.append("<tr class=danger>");
		
		
		
		sb.append("<td>");
		sb.append(makeComboArr(scopeArr, "", "size=1 id=check_field  onchange=\"saveLogExceptionField(this,'"+id+"');\"", check_field, 200));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(checkList, "", "size=1 id=check_rule  onchange=\"saveLogExceptionField(this,'"+id+"');\"", check_rule, 200));
		sb.append("</td>");
		
		sb.append("<td width=\"100%\">");
		sb.append("<textarea id=check_parameter rows=4 style=\"width:100%;\" onchange=\"saveLogExceptionField(this,'"+id+"');\" >" );
		sb.append(clearHtml(check_parameter));
		sb.append("</textarea>");
		sb.append("</td>");
		
		sql="select id, name from tdm_envs order by 2";
		sb.append("<td>");
		sb.append(makeCombo(conn, sql, "", "id=env_id onchange=\"saveLogExceptionField(this,'"+id+"');\" ", env_id, 180));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(yesnoArr, "", "size=1 id=case_sensitive  onchange=\"saveLogExceptionField(this,'"+id+"');\"" , case_sensitive, 120));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(yesnoArr, "", "size=1 id=valid  onchange=\"saveLogExceptionField(this,'"+id+"');\"", valid, 120));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=removeLogException('"+app_id+"','"+id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-remove\"></span>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("</tr>");
		
	}
	

	sb.append("</table>");
	
	return sb.toString();
}



//******************************************************************************************
String makeDynamicMaskingOverrideParams(Connection conn, HttpSession session, String app_id) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, policy_group_id, sql_logging, iddle_timeout, deny_connection, calendar_id, session_validation_id, valid from tdm_proxy_param_override where app_id=? order by id";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",""+app_id});
	
	ArrayList<String[]> overrideArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addNewOverrideParameter('"+app_id+"')>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"></span>");
	sb.append(" Add New Overriding ");
	sb.append("</button>");
	
	if (overrideArr.size()==0) {
		sb.append("<br>No record found!");
		return sb.toString();
	}
	
	sql="select id, policy_group_name from tdm_proxy_policy_group order by 2";
	bindlist.clear();
	ArrayList<String[]> policyGroupArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	ArrayList<String[]> scopeArr=new ArrayList<String[]>();
	scopeArr.add(new String[]{"SQL","SQL Statement"});
	scopeArr.add(new String[]{"USERNAME","DB Username"});
	
	ArrayList<String[]> iddletimeoutArr=new ArrayList<String[]>();
	iddletimeoutArr.add(new String[]{"SYSTEM","System"});
	for (int i=60;i<=600;i=i+60)
		iddletimeoutArr.add(new String[]{""+(i*1000),""+(i*1000)+" msec"});

	
	ArrayList<String[]> yesnosystemArr=new ArrayList<String[]>();
	yesnosystemArr.add(new String[]{"SYSTEM","System"});
	yesnosystemArr.add(new String[]{"YES","Yes"});
	yesnosystemArr.add(new String[]{"NO","No"});
	
	
	ArrayList<String[]> yesnoArr=new ArrayList<String[]>();
	yesnoArr.add(new String[]{"YES","Yes"});
	yesnoArr.add(new String[]{"NO","No"});
	
	
	sql="select id, calendar_name from tdm_proxy_calendar order by 2";
	bindlist.clear();
	ArrayList<String[]> calendarArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	calendarArr.add(0, new String[]{"0","System"});
	
	sql="select id, session_validation_name from tdm_proxy_session_validation order by 2";
	bindlist.clear();
	ArrayList<String[]> validationArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	validationArr.add(0, new String[]{"0","System"});
	
	String default_sql_logging=nvl(getParamByName(conn, "DDM_LOG_STATEMENT"),"NO");
	String default_iddle_timeout=nvl(getParamByName(conn, "DYNAMIC_CLIENT_IDDLE_TIMEOUT"),"60000");
	
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr class=info>");
	sb.append("<td><b>Policy Group</b></td>");
	sb.append("<td><b>Sql Logging <br>("+default_sql_logging+")</b></td>");
	sb.append("<td><b>Idle Timeout<br>("+default_iddle_timeout+")</b></td>");
	sb.append("<td><b>Connection Denied</b></td>");
	sb.append("<td><b>Calendar</b></td>");
	sb.append("<td><b>Session Validation</b></td>");
	sb.append("<td><b>Valid</b></td>");
	sb.append("<td><b></b></td>");
	sb.append("</tr>");
	
	for (int i=0;i<overrideArr.size();i++) {
		String id=overrideArr.get(i)[0];
		String policy_group_id=overrideArr.get(i)[1];
		String sql_logging=overrideArr.get(i)[2];
		String iddle_timeout=overrideArr.get(i)[3];
		String deny_connection=overrideArr.get(i)[4];
		String calendar_id=overrideArr.get(i)[5];
		String session_validation_id=overrideArr.get(i)[6];
		String valid=overrideArr.get(i)[7];
		
		if (valid.equals("YES"))
			sb.append("<tr class=active>");
		else 
			sb.append("<tr class=danger>");
		
		
		sb.append("<td>");
		sb.append(makeComboArr(policyGroupArr, "", "disabled id=policy_group_id ", policy_group_id, 200));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(yesnosystemArr, "", "size=1 id=sql_logging  onchange=\"saveOverrideParamField(this,'"+id+"','"+app_id+"');\"", sql_logging, 200));
		sb.append("</td>");

		
		sb.append("<td>");
		sb.append(makeComboArr(iddletimeoutArr, "", "size=1 id=iddle_timeout  onchange=\"saveOverrideParamField(this,'"+id+"','"+app_id+"');\"" , iddle_timeout, 160));
		sb.append("</td>");
		
		
		sb.append("<td>");
		sb.append(makeComboArr(yesnoArr, "", "size=1 id=deny_connection  onchange=\"saveOverrideParamField(this,'"+id+"','"+app_id+"');\"", deny_connection, 90));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(calendarArr, "", "size=1 id=calendar_id  onchange=\"saveOverrideParamField(this,'"+id+"','"+app_id+"');\"", calendar_id, 160));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(validationArr, "", "size=1 id=session_validation_id  onchange=\"saveOverrideParamField(this,'"+id+"','"+app_id+"');\"", session_validation_id, 160));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(yesnoArr, "", "size=1 id=valid  onchange=\"saveOverrideParamField(this,'"+id+"','"+app_id+"');\"", valid, 90));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=removeOverrideParam('"+app_id+"','"+id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-remove\"></span>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("</tr>");
		
	}
	

	sb.append("</table>");
	
	return sb.toString();
}


//******************************************************************************************
String makeDynamicMaskingConfiguration(Connection conn, HttpSession session, String app_id) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	StringBuilder sbContentRules=new StringBuilder(makeDynamicMaskingContentRules(conn, session, app_id));
	StringBuilder sbStatementEx=new StringBuilder(makeDynamicMaskingStatementExceptions(conn, session, app_id));
	StringBuilder sbLogEx=new StringBuilder(makeDynamicMaskingLogExceptions(conn, session, app_id));
	StringBuilder sbOverrideParams=new StringBuilder(makeDynamicMaskingOverrideParams(conn, session, app_id));

	sb.append("<ul class=\"nav nav-tabs\" role=tablist>");
	sb.append("<li role=\"presentation\" class=\"active\">	<a role=\"tab\" data-toggle=\"tab\" aria-controls=\"contentRules\" href=\"#contentRules\">Column Based Masking Rules</a></li>");
	sb.append("<li role=\"presentation\">					<a role=\"tab\" data-toggle=\"tab\" aria-controls=\"statementExceptions\" href=\"#statementExceptions\">Statement Modifying Rules</a></li>");
	sb.append("<li role=\"presentation\">					<a role=\"tab\" data-toggle=\"tab\" aria-controls=\"logExceptions\" href=\"#logExceptions\">Log Exception</a></li>");
	sb.append("<li role=\"presentation\">					<a role=\"tab\" data-toggle=\"tab\" aria-controls=\"overrideParams\" href=\"#overrideParams\">Overriding</a></li>");
	sb.append("</ul>");
	
	sb.append("<div id=myConfContent class=\"tab-content\">");
	
	sb.append("<div role=tabpanel id=contentRules class=\"tab-pane fade in active\" aria-labelledby=\"contentRules\" >");
	sb.append(sbContentRules.toString());
	sb.append("</div>");
	
	sb.append("<div role=tabpanel id=statementExceptions class=\"tab-pane\" aria-labelledby=\"statementExceptions\" >");
	sb.append(sbStatementEx.toString());
	sb.append("</div>");
	
	sb.append("<div role=tabpanel id=logExceptions class=\"tab-pane\" aria-labelledby=\"logExceptions\" >");
	sb.append(sbLogEx.toString());
	sb.append("</div>");
	
	
	sb.append("<div role=tabpanel id=overrideParams class=\"tab-pane\" aria-labelledby=\"overrideParams\" >");
	sb.append(sbOverrideParams.toString());
	sb.append("</div>");
	
	
	sb.append("</div>");
	

	return sb.toString();
}


//******************************************************************************************
String openDynamicMaskingExceptionWindow(Connection conn, HttpSession session, String exception_scope, String exception_obj_id) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select name from tdm_apps where id=?";
	if (exception_scope.equals("RULE"))
		sql="select rule_notes from tdm_proxy_rules where id=?";
	else if (exception_scope.equals("TABLE"))
		sql="select concat(schema_name,'.',tab_name) from tdm_tabs where id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",exception_obj_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String scope_object_name="";
	if (arr!=null && arr.size()==1) scope_object_name=arr.get(0)[0];
	
	
	sql="select id, policy_group_name from tdm_proxy_policy_group g "+
		" where not exists (select 1 from tdm_proxy_exception where policy_group_id=g.id and exception_scope=? and exception_obj_id=? )";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",exception_scope});
	bindlist.add(new String[]{"INTEGER",exception_obj_id});
	
	ArrayList<String[]> policyGroupArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	sql="select \n"+
			"	e.id exception_id, \n"+
			"	policy_group_name \n"+
			"	from tdm_proxy_exception e,  tdm_proxy_policy_group p \n"+
			"	where policy_group_id=p.id \n"+
			"	and exception_scope=? \n"+
			"	and exception_obj_id=?";
		
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",exception_scope});
	bindlist.add(new String[]{"INTEGER",exception_obj_id});
	
	ArrayList<String[]> exceptionArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<input type=hidden id=exception_scope value=\""+exception_scope+"\">");
	sb.append("<input type=hidden id=exception_obj_id value=\""+exception_obj_id+"\">");
	
	sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
	sb.append("<tr class=info>");
	sb.append("<td>");
	sb.append("Exception For "+exception_scope.toLowerCase()+": <b>"+scope_object_name+"</b>");
	sb.append("</td>");	
	sb.append("</tr>");
	sb.append("</table>");
	
	sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
	sb.append("<tr class=active>");
	
	sb.append("<td nowrap>");
	sb.append(" Policy Group : ");
	sb.append("</td>");
	
	sb.append("<td width=\"100%;\">");
	sb.append(makeComboArr(policyGroupArr, "", "id=new_policy_group_id", "", 0));
	sb.append("</td>");
	
	sb.append("<td>");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addNewException()>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"></span>");
	sb.append("</button>");
	sb.append("</td>");
	
	sb.append("</tr>");
	sb.append("</table>");
	
	
	if (exceptionArr.size()==0) {
		sb.append("No exception defined.");
		return sb.toString();
	}
	
	sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
	for (int i=0;i<exceptionArr.size();i++) {
		String exception_id=exceptionArr.get(i)[0];
		String policy_group_name=exceptionArr.get(i)[1];
		
		sb.append("<tr class=success>");
		
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=removeException('"+exception_id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-minus\"></span>");
		sb.append("</button>");
		sb.append("</td>");
		sb.append("<td  width=\"100%;\">");
		sb.append("<li> "+policy_group_name+"</li> ");
		sb.append("</td>");
		
		
		
		sb.append("</tr>");
	}

	sb.append("</table>");
	
	
	return sb.toString();
}

//*************************************************************************************
void addNewDynamicMaskingRule(Connection conn, HttpSession session, String app_id) {
	String sql= "";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	sql="select max(rule_order) from  tdm_proxy_rules where app_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	int next_rule_order=1;
	if (arr!=null && arr.size()==1) {
		try{next_rule_order=Integer.parseInt(arr.get(0)[0]);} catch(Exception e) {}
	}
	
	sql="insert into tdm_proxy_rules (app_id, rule_order, rule_notes, rule_type, min_match_rate) values (?, ?, 'New Rule','EQUALS',1)";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"INTEGER",""+next_rule_order});

	
	

	execDBConf(conn, sql, bindlist);
}

//*************************************************************************************
void addNewLogException(Connection conn, HttpSession session, String app_id) {
	String sql= "";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="insert into tdm_proxy_log_exception (app_id) values (?)";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});

	execDBConf(conn, sql, bindlist);
}

//*************************************************************************************
void addStatementLogException(Connection conn, HttpSession session, String app_id) {
	String sql= "";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="insert into tdm_proxy_statement_exception (app_id) values (?)";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});

	execDBConf(conn, sql, bindlist);
}

//*********************************************************************************

void removeDynamicMaskingRule(Connection conn, HttpSession session, String rule_id) {
	String sql= "";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	sql="delete from  tdm_proxy_rules where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",rule_id});
	
	

	execDBConf(conn, sql, bindlist);
}

//*********************************************************************************

void removeLogException(Connection conn, HttpSession session, String rule_id) {
	String sql= "";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	sql="delete from  tdm_proxy_log_exception where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",rule_id});
	
	

	execDBConf(conn, sql, bindlist);
}

//*********************************************************************************

void removeStatementException(Connection conn, HttpSession session, String rule_id) {
	String sql= "";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	sql="delete from  tdm_proxy_statement_exception where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",rule_id});
	
	

	execDBConf(conn, sql, bindlist);
}

//*********************************************************************************

void reorderDynamicMaskingRule(Connection conn, HttpSession session, String app_id, String ordering_rule_id, String direction) {
	String sql= "";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id from tdm_proxy_rules where app_id=? order by rule_order";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",""+app_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	int change_id=-1;
	int source_id=-1;

	for (int i=0;i<arr.size();i++) {
		String rule_id=arr.get(i)[0];
		
		
		
		if (rule_id.equals(ordering_rule_id)) {
			source_id=i;
			if (direction.equals("UP"))  change_id=i-1;
			else if (direction.equals("DOWN"))  change_id=i+1;
		} 
	}
	
	
	String[] tmp=arr.get(source_id);
	arr.set(source_id, arr.get(change_id));
	arr.set(change_id, tmp);
	
	sql="update tdm_proxy_rules set rule_order=? where id=?";
	
	for (int i=0;i<arr.size();i++) {
		String rule_id=arr.get(i)[0];
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+(i+1)});
		bindlist.add(new String[]{"INTEGER",""+rule_id});
		
		execDBConf(conn, sql, bindlist);
	}

	
}

//*********************************************************************************
void  changeContentBasedRuleField(Connection conn, HttpSession session, String rule_id, String rule_field_name, String field_value) {
	
	String sql= "update tdm_proxy_rules set "+ rule_field_name +"=? where id=?";

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	
	if (rule_field_name.equals("min_match_rate"))
		bindlist.add(new String[]{"INTEGER",field_value});
	else if (rule_field_name.equals("mask_prof_id")) {
		bindlist.add(new String[]{"INTEGER",nvl(field_value,"0")});
	}
	else 
		bindlist.add(new String[]{"STRING",field_value});
	
	bindlist.add(new String[]{"INTEGER",rule_id});
	
	execDBConf(conn, sql, bindlist);


}




//******************************************************************************
String makeDMProxySessionCommandList(Connection conn, HttpSession session, String proxy_id, String selected_Session_ids, String proxy_session_filter) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select proxy_type from tdm_proxy where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	ArrayList<String[]> ptArr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String proxy_type=ptArr.get(0)[0];
	
	sql= "select \n"+
					"		log.id log_id, \n"+
					"		username,	\n"+
					"		current_schema,	\n"+
					"		date_format(log.log_date,?) log_date, \n"+
					"		original_sql, \n"+
					"		statement_type, \n"+
					"		bind_info \n"+
					"	from tdm_proxy_log log, tdm_proxy_session s \n"+
					"	where  \n"+
					"	log.proxy_id=? and s.proxy_id=? \n"+
					"	and proxy_session_id in (#SESSION_FILTER#) #COMMANDFILTER#  \n"+
					"	and proxy_session_id=s.id \n"+
					"	order by log.id desc \n"+
					"	limit 0,1000";
	
	
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"INTEGER",proxy_id});
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	
	sql=sql.replace("#SESSION_FILTER#", selected_Session_ids);
	
	String filter_command=nvl((String) session.getAttribute(proxy_id+"_"+proxy_session_filter+"_filter_command") ,"");
	
	String filter_command_sql="";
	if (filter_command.contains("%")) 
		filter_command_sql=" upper(original_sql) like '%"+filter_command.toUpperCase()+"%' ";
	else  {
		String[] arrx=filter_command.split(" ");
		for (int i=0;i<arrx.length;i++) {
			String el=arrx[i];
			if (el.trim().length()==0) continue;
			if (filter_command_sql.length()>0) filter_command_sql=filter_command_sql+" or ";
			
			
			filter_command_sql=filter_command_sql+" upper(original_sql) like '%"+el.toUpperCase()+"%' ";
		}
	}
	
	if (filter_command_sql.length()>0)
		sql=sql.replace("#COMMANDFILTER#", "\n and ( "+filter_command_sql+" )  ");
	else 
		sql=sql.replace("#COMMANDFILTER#", "");
	
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\" >");
	sb.append("<tr>");
	sb.append("<td align=right>");
	
	
	sb.append(makeDMFilterButon(conn, session,proxy_id, proxy_session_filter,"COMMAND"));
	

	
	sb.append(" <button type=button class=\"btn btn-sm btn-success\" onclick=\"listSessionCommands('"+proxy_id+"','"+proxy_session_filter+"');\" ><span class=\"glyphicon glyphicon-refresh\"></span></button>");
	sb.append("</td>");
	sb.append("</tr>");
	sb.append("</table>");
	

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1000, bindlist);
	
	if (arr==null || arr.size()==0) {
		sb.append("No command found.");
		return sb.toString();
	}
	
	
	
	

	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\" >");
	
	sb.append("<tr class=info>");
	sb.append("<td><b>Session User</b></td>");
	sb.append("<td><b>Active Catalog.Schema</b></td>");
	sb.append("<td><b>Executed@</b></td>");
	sb.append("<td><b>Type@</b></td>");
	sb.append("<td><b>Command@</b></td>");
	sb.append("<td><b>Binding</b></td>");
	sb.append("</tr>");
	
	
	StringBuilder sbSessionheader=new StringBuilder();
	StringBuilder sbSessioninfo=new StringBuilder();
	
	
	for (int i=0;i<arr.size();i++) {
		String log_id=arr.get(i)[0];
		String username=arr.get(i)[1];
		String current_schema=nvl(arr.get(i)[2],username);
		String log_date=arr.get(i)[3];
		String original_sql=arr.get(i)[4];
		String statement_type=nvl(arr.get(i)[5],"unknown");
		String bind_info=nvl(arr.get(i)[6],"-");
		
		
		
		
		sb.append("<tr>");
		
		sb.append("<td><small>"+username+"</small></td>");
		sb.append("<td><small>"+current_schema+"</small></td>");
		sb.append("<td><small>"+log_date+"</small></td>");
		sb.append("<td><small>"+statement_type+"</small></td>");
		
		if (statement_type.contains("sstselect")) 
			if (proxy_type.equals("ORACLE_ARW"))
				sb.append("<td><small>"+clearHtml(original_sql).replaceAll("\n|\r", "<br>")+"</small></td>");
			else 
				sb.append("<td><small> <b><font color=green><span class=\"glyphicon glyphicon-flash\" onclick=getMaskedResultList('"+log_id+"')></span></font></b> "+clearHtml(original_sql).replaceAll("\n|\r", "<br>")+"</small></td>");
		else 
			sb.append("<td><small>"+clearHtml(original_sql).replaceAll("\n|\r", "<br>")+"</small></td>");
		
		sb.append("<td><small>"+clearHtml(bind_info).replaceAll("\n|\r", "<br>")+"</small></td>");

		sb.append("</tr>");
		
	}
	
	sb.append("</table>");
	
	return sb.toString();
}

//******************************************************************************
String makeDMProxyBlackListedSessionCommandList(Connection conn, HttpSession session, String proxy_id, String session_id, String blacklist_id) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select date_format(blacklist_time,?)  from tdm_proxy_monitoring_blacklist where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"INTEGER",blacklist_id});
	
	ArrayList<String[]> ptArr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String blacklist_time=ptArr.get(0)[0];
	
	sql= "select \n"+
					"		log.id log_id, \n"+
					"		username,	\n"+
					"		current_schema,	\n"+
					"		date_format(log.log_date,?) log_date, \n"+
					"		original_sql, \n"+
					"		statement_type, \n"+
					"		bind_info \n"+
					"	from tdm_proxy_log log, tdm_proxy_session s \n"+
					"	where  \n"+
					"	log.proxy_id=? and s.proxy_id=? \n"+
					"	and proxy_session_id=? "+
					"   and log.log_date between DATE_ADD(str_to_date(?,?),INTERVAL -30 SECOND) and DATE_ADD(str_to_date(?,?),INTERVAL 30 SECOND) \n"+
					"	and proxy_session_id=s.id \n"+
					"	order by log.id desc \n"+
					"	limit 0,1000";
	
	
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"INTEGER",proxy_id});
	bindlist.add(new String[]{"INTEGER",proxy_id});
	bindlist.add(new String[]{"INTEGER",session_id});
	bindlist.add(new String[]{"STRING",blacklist_time});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",blacklist_time});
	bindlist.add(new String[]{"STRING",mysql_format});
	
	




	

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1000, bindlist);
	
	if (arr==null || arr.size()==0) {
		sb.append("No command found.");
		return sb.toString();
	}
	
	
	
	

	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\" >");
	
	sb.append("<tr class=info>");
	sb.append("<td><b>Session User</b></td>");
	sb.append("<td><b>Active Catalog.Schema</b></td>");
	sb.append("<td><b>Executed@</b></td>");
	sb.append("<td><b>Type@</b></td>");
	sb.append("<td><b>Command@</b></td>");
	sb.append("<td><b>Binding</b></td>");
	sb.append("</tr>");
	
	
	StringBuilder sbSessionheader=new StringBuilder();
	StringBuilder sbSessioninfo=new StringBuilder();
	
	
	for (int i=0;i<arr.size();i++) {
		String log_id=arr.get(i)[0];
		String username=arr.get(i)[1];
		String current_schema=nvl(arr.get(i)[2],username);
		String log_date=arr.get(i)[3];
		String original_sql=arr.get(i)[4];
		String statement_type=nvl(arr.get(i)[5],"unknown");
		String bind_info=nvl(arr.get(i)[6],"-");
		
		
		
		
		sb.append("<tr>");
		
		sb.append("<td><small>"+username+"</small></td>");
		sb.append("<td><small>"+current_schema+"</small></td>");
		sb.append("<td><small>"+log_date+"</small></td>");
		sb.append("<td><small>"+statement_type+"</small></td>");
		sb.append("<td><small>"+clearHtml(original_sql).replaceAll("\n|\r", "<br>")+"</small></td>");
		sb.append("<td><small>"+clearHtml(bind_info).replaceAll("\n|\r", "<br>")+"</small></td>");

		sb.append("</tr>");
		
	}
	
	sb.append("</table>");
	
	return sb.toString();
}
//******************************************************************************
String makeDMExceptionForSessionDialog(Connection conn, HttpSession session, String proxy_id, String selected_Session_ids) {
	StringBuilder sb=new StringBuilder();
	
	sb.append("<input type=hidden id=exception_proxy_id value=\""+proxy_id+"\">");
	sb.append("<input type=hidden id=exception_selected_session_ids value=\""+selected_Session_ids+"\">");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\" >");
	
	sb.append("<tr class=active><td><b>Exception Duration</b></td><td><b>Exception Period</b></td></tr>");
	
	ArrayList<String[]> periodArr=new ArrayList<String[]>();
	periodArr.add(new String[]{"MINUTE","Minute"});
	periodArr.add(new String[]{"HOUR","Hour"});
	
	
	sb.append("<tr>");
	
	sb.append("<td>");
	sb.append(makeNumber("x", "exception_duration", "1", "", "EDITABLE", "10", "0", "", "", "", "1", "999"));
	sb.append("</td>");
	
	sb.append("<td>");
	sb.append(makeComboArr(periodArr, "", "size=1 id=exception_period", "MINUTE", 0));
	sb.append("</td>");
	
	
	sb.append("</tr>");
	
	
	sb.append("</table>");
	
	return sb.toString();
}

//*************************************************************************************************************
void setDMProxySessionException(
		Connection conn, 
		HttpSession session, 
		String exception_proxy_id, 
		String exception_selected_session_ids, 
		String exception_duration, 
		String exception_period) {
	
	String sql="update tdm_proxy_session \n"+
				" set \n"+
				"  exception_time_to = DATE_ADD(now() , INTERVAL "+exception_duration+" "+exception_period+")  \n "+
				" where proxy_id=? and status='ACTIVE' and id in (#SESSINIDS#)";
	
	sql=sql.replace("#SESSINIDS#", exception_selected_session_ids);
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"LONG",exception_proxy_id});
	

	
	execDBConf(conn, sql, bindlist);
	
}

//*************************************************************************************************************
void clearDMProxySessionException(
		Connection conn, 
		HttpSession session, 
		String exception_proxy_id, 
		String exception_selected_session_ids) {
	
	String sql="update tdm_proxy_session \n"+
				" set \n"+
				"  exception_time_to = null  \n "+
				" where proxy_id=? and status='ACTIVE' and id in (#SESSINIDS#) and exception_time_to is not null ";
	
	sql=sql.replace("#SESSINIDS#", exception_selected_session_ids);
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",exception_proxy_id});
	
	
	execDBConf(conn, sql, bindlist);
	
}

//*************************************************************************************************************
void terminateSessions(
		Connection conn, 
		HttpSession session, 
		String exception_proxy_id, 
		String exception_selected_session_ids) {
	
	String sql="update tdm_proxy_session \n"+
				" set \n"+
				" cancel_flag='YES'  \n "+
				" where proxy_id=? and status='ACTIVE' and id in (#SESSINIDS#)";
	
	sql=sql.replace("#SESSINIDS#", exception_selected_session_ids);
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",exception_proxy_id});
	
	
	execDBConf(conn, sql, bindlist);
	
}


//*************************************************************************************************************
void traceSessions(
		Connection conn, 
		HttpSession session, 
		String exception_proxy_id, 
		String exception_selected_session_ids,
		String start_stop) {
	
	String sql="update tdm_proxy_session \n"+
				" set \n"+
				" tracing_flag=?  \n "+
				" where proxy_id=? and status='ACTIVE' and id in (#SESSINIDS#)";
	
	sql=sql.replace("#SESSINIDS#", exception_selected_session_ids);
	
	String flag="YES";
	if (start_stop.equals("STOP")) flag="NO";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",flag});
	bindlist.add(new String[]{"INTEGER",exception_proxy_id});
	
	
	execDBConf(conn, sql, bindlist);
	
}


//******************************************************************************
String getMaskedResultList(Connection conn, HttpSession session, String log_id) {
	StringBuilder sb=new StringBuilder();
	

	String sql="select \n"+
				"		e.id env_id, log.current_schema,  \n"+
				"		log.masking_sql, log.original_sql \n"+
				"	from  \n"+
				"		tdm_proxy_log log, tdm_proxy_session s, tdm_proxy p , tdm_envs e \n"+
				"	where log.id=? and log.proxy_session_id=s.id and  s.proxy_id=p.id and target_env_id=e.id ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",log_id});

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) {
		sb.append("Log ["+log_id+"] not found");
		return sb.toString();
	}
	
	String env_id=arr.get(0)[0];
	String current_schema=arr.get(0)[1];
	String masking_sql=arr.get(0)[2];
	String original_sql=arr.get(0)[3];
	
	if (masking_sql.trim().length()==0) masking_sql=original_sql;
	
	bindlist.clear();
	
	
	
	ArrayList<String[]> arrSample=getDbArrayApp(conn, env_id, masking_sql, 100, bindlist, true, current_schema);
	
	//sb.append("<textarea rows=3 style=\"width:100%;\">"+clearHtml(masking_sql)+"</textarea>");
	
	
	if (arrSample==null || arrSample.size()==0) {
		sb.append("Sql execution error ! " + last_db_sql_error);
		return sb.toString();
	}
	
	
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\" >");
	
	String[] colNames=arrSample.get(0);
	
	sb.append("<tr class=info>");
	for (int i=0;i<colNames.length;i++) 
		sb.append("<td><b><small>"+clearHtml(colNames[i])+"</small></b></td>");
	sb.append("</tr>");
	
	for (int i=1;i<arrSample.size();i++) {
		String[] arow=arrSample.get(i);
		
		sb.append("<tr>");
		for (int c=0;c<arow.length;c++) 
			sb.append("<td><small>"+clearHtml(arow[c])+"</small></td>");
		sb.append("</tr>");
	}
	
	
	sb.append("</table>");
	
	return sb.toString();
}


//******************************************************************************
String makeSessionFilterDlg(Connection conn, HttpSession session, String proxy_id, String proxy_session_filter, String origin) {
	StringBuilder sb=new StringBuilder();
	
	sb.append("<input type=hidden id=session_filter_proxy_id value=\""+proxy_id+"\">");
	sb.append("<input type=hidden id=session_filter_proxy_session_filter value=\""+proxy_session_filter+"\">");
	sb.append("<input type=hidden id=session_filter_origin value=\""+origin+"\">");

	String filter_username=nvl((String) session.getAttribute(proxy_id+"_"+proxy_session_filter+"_filter_username") ,"");
	String filter_session_info=nvl((String) session.getAttribute(proxy_id+"_"+proxy_session_filter+"_filter_session_info") ,"");
	String filter_command=nvl((String) session.getAttribute(proxy_id+"_"+proxy_session_filter+"_filter_command") ,"");
	
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\" >");
	
	

	if (origin.equals("SESSION")) {
		sb.append("<tr>");
		sb.append("<td class=active align=right><b> Username : </b></td>");
		sb.append("<td>");
		sb.append(makeText("filter_username", clearHtml(filter_username), "", 0));
		sb.append("</td>");
		sb.append("</tr>");
		
		
		sb.append("<tr>");
		sb.append("<td class=active align=right><b> Session Info : </b></td>");
		sb.append("<td>");
		sb.append(makeText("filter_session_info", clearHtml(filter_session_info) , "", 0));
		sb.append("</td>");
		sb.append("</tr>");
	} else {
		sb.append("<input type=hidden id=filter_username value=\""+clearHtml(filter_username)+"\">");
		sb.append("<input type=hidden id=filter_session_info value=\""+clearHtml(filter_session_info)+"\">");
	}
	
	
	
	sb.append("<tr>");
	sb.append("<td class=active align=right><b> Sql Commands : </b></td>");
	sb.append("<td>");
	sb.append(makeText("filter_command", clearHtml(filter_command), "", 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	
	
	sb.append("</table>");
	
	return sb.toString();
}

//*******************************************************************
void setDmProxyFilter(
		Connection conn, 
		HttpSession session,
		String session_filter_proxy_id,
		String session_filter_proxy_session_filter,
		String filter_username,
		String filter_session_info,
		String filter_command
		) {
	
	 session.setAttribute(session_filter_proxy_id+"_"+session_filter_proxy_session_filter+"_filter_username",filter_username);
	 session.setAttribute(session_filter_proxy_id+"_"+session_filter_proxy_session_filter+"_filter_session_info",filter_session_info);
	 session.setAttribute(session_filter_proxy_id+"_"+session_filter_proxy_session_filter+"_filter_command",filter_command);
}


//*************************************************************************************************************
void addNewException(
		Connection conn, 
		HttpSession session, 
		String exception_scope, 
		String exception_obj_id,
		String new_policy_group_id) {
	
	String sql="insert into tdm_proxy_exception (exception_scope, exception_obj_id, policy_group_id) values (?, ?, ?) ";
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",exception_scope});
	bindlist.add(new String[]{"INTEGER",exception_obj_id});
	bindlist.add(new String[]{"INTEGER",new_policy_group_id});
	
	
	execDBConf(conn, sql, bindlist);
	
}

//*************************************************************************************************************
void removeException(
		Connection conn, 
		HttpSession session, 
		String exception_id) {
	
	String sql="delete from  tdm_proxy_exception where id=? ";
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",exception_id});
	
	
	execDBConf(conn, sql, bindlist);
	
}

//***************************************************************************
String makeExceptionButton(Connection conn, HttpSession session, String exception_scope, String exception_obj_id) {
	
	
	String sql="select count(*) from tdm_proxy_exception where exception_scope=? and exception_obj_id=?";
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",exception_scope});
	bindlist.add(new String[]{"INTEGER",exception_obj_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	String count=arr.get(0)[0];
	
	StringBuilder sb=new StringBuilder();
	


	
	if (count.equals("0"))
		sb.append(
					" <font color=green >"+
					" <span class=\"glyphicon glyphicon-plus\" onclick=\"openDynamicMaskingExceptionWindow('"+exception_scope+"','"+exception_obj_id+"');\"></span>"+
					"</font>"
					);
	else 
		sb.append(
				" <span class=badge onclick=\"openDynamicMaskingExceptionWindow('"+exception_scope+"','"+exception_obj_id+"');\" >"+count+"</span>"
				);
	
	
	return sb.toString();
}



//----------------------------------------------------------------------------
String makeDataPoolConfigurationDlg(Connection conn, HttpSession session, String app_id, String env_id) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> arr=new ArrayList<String[]>();
	
	
	
	String sql="";
	
	sql="select name from tdm_apps where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	String pool_name=arr.get(0)[0];
	String pool_id="";
	String family_id="";
	String base_sql="";
	
	sql="select id, family_id, base_sql from tdm_pool where app_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==0) {
		sql="SELECT AUTO_INCREMENT FROM information_schema.tables WHERE table_name = 'tdm_pool' AND table_schema = DATABASE()";
		bindlist.clear();
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		pool_id=arr.get(0)[0];
		sql="insert into tdm_pool (id, app_id) values (?,?)";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",pool_id});
		bindlist.add(new String[]{"INTEGER",app_id});
		execDBConf(conn, sql, bindlist);
		
	}
	else {
		pool_id=arr.get(0)[0];
		family_id=arr.get(0)[1];
		base_sql=arr.get(0)[2];
		
	}
	
	sb.append("<input type=hidden id=pool_id value="+pool_id+">");
	
	sb.append("<h4>Data Pool Configuration for <b>"+pool_name+"</b></h4>");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Db Family : </b> </td>");
	sb.append("<td width=\"100%\">");
	sql="select id, family_name from tdm_family order by 2";
	sb.append(makeCombo(conn, sql, "", "id=family_id", family_id, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Base SQL  : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append("<textarea id=base_sql rows=5 style=\"width:100%;\">"+clearHtml(base_sql)+"</textarea>");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("</table>");
	
	return sb.toString();
}


//-----------------------------------------------------------------------------------------------------------------------
void saveDataPoolConfiguration(Connection conn, HttpSession session, String pool_id, String family_id, String base_sql) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="update tdm_pool set family_id=?, base_sql=? where id=? ";
	bindlist.add(new String[]{"INTEGER",family_id});
	bindlist.add(new String[]{"STRING",base_sql});
	bindlist.add(new String[]{"INTEGER",pool_id});
	
	execDBConf(conn, sql, bindlist);
}



//----------------------------------------------------------------------------
String makeDataPoolLovDlg(Connection conn, HttpSession session, String app_id, String env_id) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> arr=new ArrayList<String[]>();
	
	
	
	String sql="";
	
	sql="select name from tdm_apps where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	String pool_name=arr.get(0)[0];
	String pool_id="0";
	
	sql="select id from tdm_pool where app_id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr!=null && arr.size()==1) 
		pool_id=arr.get(0)[0];
	
	if (pool_id.equals("0")) {
		sb.append("Complete pool configuration first.");
		return sb.toString();
	}
	

	sql="select id , lov_name, family_id, lov_statement from tdm_pool_lov where pool_id=? ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	ArrayList<String[]>  lovArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<h4>LOV Configuration for <b>"+pool_name+"</b></h4>");
			
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addNewPoolLov('"+app_id+"','"+pool_id+"')>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"></span> Add new LOV");
	sb.append("</button>");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
			
	sb.append("<tr class=active>");
	sb.append("<td><b>Lov Name</b></td>");
	sb.append("<td><b>Data Source</b></td>");
	sb.append("<td><b>LOV Statement</b> (Sql statement or comma delimited lines)</td>");
	sb.append("<td><b></b></td>");
	sb.append("</tr>");
	
	sql="select id, family_name from tdm_family order by 2";
	bindlist.clear();
	ArrayList<String[]>  familyArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	for (int i=0;i<lovArr.size();i++) {
		String id=lovArr.get(i)[0];
		String lov_name=lovArr.get(i)[1];
		String family_id=lovArr.get(i)[2];
		String lov_statement=lovArr.get(i)[3];
		
		
		sb.append("<tr>");
		
		sb.append("<td>");
		sb.append(makeText("lov_name", lov_name, "onchange=\"savePoolLovField(this,'"+id+"');\"", 240));
		sb.append("</td>");

		sb.append("<td>");
		sb.append(makeComboArr(familyArr, "", "id=family_id onchange=\"savePoolLovField(this,'"+id+"');\" ", family_id, 240));
		sb.append("</td>");
		
		sb.append("<td width=\"100%\">");
		sb.append("<textarea id=lov_statement rows=3 style=\"width:100%;\" onchange=\"savePoolLovField(this,'"+id+"');\" >");
		sb.append(clearHtml(lov_statement));
		sb.append("</textarea>");
		sb.append("</td>");
		
		
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=removePoolLov('"+app_id+"','"+id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-minus\"></span>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("</tr>");
		
	}
	
	
	
	
	sb.append("</table>");
	
	return sb.toString();
}


//----------------------------------------------------------------------------
String makeDataPoolGroupDlg(Connection conn, HttpSession session, String app_id) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> arr=new ArrayList<String[]>();
	
	
	
	String sql="";
	
	sql="select name from tdm_apps where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	String pool_name=arr.get(0)[0];
	String pool_id="0";
	
	sql="select id from tdm_pool where app_id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr!=null && arr.size()==1) 
		pool_id=arr.get(0)[0];
	
	if (pool_id.equals("0")) {
		sb.append("Complete pool configuration first.");
		return sb.toString();
	}
	

	sql="select id , group_name from tdm_pool_group where pool_id=? order by order_no ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	ArrayList<String[]>  lovArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<h4>Group Configuration for <b>"+pool_name+"</b></h4>");
			
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addNewPoolGroup('"+app_id+"','"+pool_id+"')>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"></span> Add new Group");
	sb.append("</button>");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
		
	
	
	sb.append("<tr class=active>");
	sb.append("<td><b></b></td>");
	sb.append("<td><b>Group Name</b></td>");
	sb.append("<td><b></b></td>");
	sb.append("</tr>");
	
	
	
	
	for (int i=0;i<lovArr.size();i++) {
		String id=lovArr.get(i)[0];
		String group_name=lovArr.get(i)[1];
		
		
		sb.append("<tr>");
		
		
		sb.append("<td nowrap align=center>");
		
		if (i>0) {
			sb.append("<button type=button class=\"btn btn-sm btn-primary\" onclick=reorderPoolGroup('"+app_id+"','"+id+"','UP')>");
			sb.append("<span class=\"glyphicon glyphicon-arrow-up\"></span>");
			sb.append("</button>");
		}
		
		
		sb.append(" ");
		
		if (i<lovArr.size()-1) {
			sb.append("<button type=button class=\"btn btn-sm btn-primary\" onclick=reorderPoolGroup('"+app_id+"','"+id+"','DOWN')>");
			sb.append("<span class=\"glyphicon glyphicon-arrow-down\"></span>");
			sb.append("</button>");
		}
		
		sb.append("</td>");
		
		sb.append("<td width=\"100%\">");
		sb.append(makeText("group_name", group_name, "onchange=\"savePoolGroupField(this,'"+id+"');\"", 0));
		sb.append("</td>");


		
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=removePoolGroup('"+app_id+"','"+id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-minus\"></span>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("</tr>");
		
	}
	
	
	
	
	sb.append("</table>");
	
	return sb.toString();
}

//----------------------------------------------------------------------------
void addNewPoolLov(Connection conn, HttpSession session, String pool_id) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="insert into tdm_pool_lov (pool_id) values (?)";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	
	execDBConf(conn, sql, bindlist);
}

//----------------------------------------------------------------------------
void addNewPoolGroup(Connection conn, HttpSession session, String pool_id) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="";
	
	
	
	sql="select max(order_no)+1 from tdm_pool_group where pool_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	

	String order_no="1";
	
	if (arr.size()==1) {
		order_no=arr.get(0)[0];
	}
	
	sql="insert into tdm_pool_group (pool_id, order_no) values (?, ?)";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	bindlist.add(new String[]{"INTEGER",order_no});
	
	execDBConf(conn, sql, bindlist);
}

//----------------------------------------------------------------------------
boolean removePoolLov(Connection conn, HttpSession session, String pool_lov_id) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select pool_id from tdm_pool_lov where id=? ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_lov_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) return false; 
	
	String pool_id=arr.get(0)[0];
	
	sql="select 1 from tdm_pool_property where lov_id=? and pool_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_lov_id});
	bindlist.add(new String[]{"INTEGER",pool_id});
	
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==1) return false;
	
	sql="delete from tdm_pool_lov where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_lov_id});
	
	boolean is_ok=execDBConf(conn, sql, bindlist);
	
	return is_ok;
	


}


//----------------------------------------------------------------------------
boolean removePoolGroup(Connection conn, HttpSession session, String pool_group_id) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select pool_id from tdm_pool_group where id=? ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_group_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) return false; 
	
	String pool_id=arr.get(0)[0];
	
	sql="select 1 from tdm_pool_property where group_id=? and pool_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_group_id});
	bindlist.add(new String[]{"INTEGER",pool_id});
	
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==1) return false;
	
	sql="delete from tdm_pool_group where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_group_id});
	
	boolean is_ok=execDBConf(conn, sql, bindlist);
	
	return is_ok;
	


}


//----------------------------------------------------------------------------
boolean removePoolProperty(Connection conn, HttpSession session, String pool_property_id) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();


	String sql="delete from tdm_pool_property where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_property_id});
	
	boolean is_ok=execDBConf(conn, sql, bindlist);
	
	return is_ok;
	


}


//----------------------------------------------------------------------------
String getNextPoolPropertyName(Connection conn, HttpSession session, String pool_id) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String id="1";
	String property_name="NEW_PROPERTY_1";
	
	String sql="select count(*)+1 from tdm_pool_property where pool_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr!=null && arr.size()==1) id=arr.get(0)[0];
	
	sql="select 1 from tdm_pool_property where upper(property_name)=upper(?) and pool_id=?";
	while(true) {
		bindlist.clear();
		bindlist.add(new String[]{"STRING","PROPERTY_"+id});
		bindlist.add(new String[]{"INTEGER",pool_id});
		
		 arr=getDbArrayConf(conn, sql, 1, bindlist);
		 
		 if (arr.size()==0) break;
		 
		 id=""+ (Integer.parseInt(id)+1);
	}
	
	return "PROPERTY_"+id;
}

//----------------------------------------------------------------------------
String makeDataPoolPropertyDlg(Connection conn, HttpSession session, String app_id, String env_id, String property_id) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> arr=new ArrayList<String[]>();
	
	
	
	String sql="";
	
	sql="select name from tdm_apps where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	String pool_name=arr.get(0)[0];
	String pool_id="";
	String family_id="";
	String base_sql="";
	
	sql="select id, family_id, base_sql from tdm_pool where app_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==0) {
		sb.append("Set pool configuration first");
		return sb.toString();
		
	}
	
	pool_id=arr.get(0)[0];
	family_id=arr.get(0)[1];
	base_sql=arr.get(0)[2];
		
	
	
	
	
	String property_name="";
	String property_title="";
	String is_searchable="YES";
	String is_indexed="NO";
	String is_visible_on_search="YES";
	String data_type="";
	String get_method="";
	String is_valid="";
	String lov_id="0";
	String group_id="0";
	
	if (!property_id.equals("0")) {
		sql="select property_name, property_title, is_searchable, is_indexed, "+
				" is_visible_on_search, data_type, get_method, is_valid, lov_id, group_id "+
				" from tdm_pool_property where id=? ";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",property_id});
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		property_name=arr.get(0)[0];
		property_title=arr.get(0)[1];
		is_searchable=arr.get(0)[2];
		is_indexed=arr.get(0)[3];
		is_visible_on_search=arr.get(0)[4];
		data_type=arr.get(0)[5];
		get_method=arr.get(0)[6];
		is_valid=arr.get(0)[7];
		lov_id=arr.get(0)[8];
		group_id=arr.get(0)[9];
		
	}
	
	if (property_name.length()==0) {
		property_name=getNextPoolPropertyName(conn,session,pool_id);
		property_title=property_name;
	}
	
	sb.append("<input type=hidden id=property_pool_id value="+pool_id+">");
	sb.append("<input type=hidden id=property_id value="+property_id+">");
	
	sb.append("<h4>Property for <b>"+pool_name+"</b></h4>");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
			
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Title : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeText("property_title", property_title, "", 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Property Name : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeText("property_name", property_name, "", 240));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	ArrayList<String[]> dataTypeArr=new ArrayList<String[]>();
	dataTypeArr.add(new String[]{"STRING"});
	dataTypeArr.add(new String[]{"INTEGER"});
	dataTypeArr.add(new String[]{"LONG"});
	dataTypeArr.add(new String[]{"DOUBLE"});
	dataTypeArr.add(new String[]{"DATE"});
	dataTypeArr.add(new String[]{"MEMO"});
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Data Type : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeComboArr(dataTypeArr, "", "size=1 id=data_type", data_type, 240));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	
	
	sql="select id, group_name from tdm_pool_group where pool_id=? order by 2";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	ArrayList<String[]> groupArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	groupArr.add(0,new String[]{"0","Ungrouped"});
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Property Group : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeComboArr(groupArr, "", "size=1 id=group_id", group_id, 240));
	sb.append("</td>");
	sb.append("</tr>");
	
	ArrayList<String[]> yesNoArr=new ArrayList<String[]>();
	yesNoArr.add(new String[]{"YES"});
	yesNoArr.add(new String[]{"NO"});
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Searchable : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeComboArr(yesNoArr, "", "size=1 id=is_searchable", is_searchable, 240));
	sb.append("</td>");
	sb.append("</tr>");
	
	sql="select id, lov_name from tdm_pool_lov where pool_id=? order by 2";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	ArrayList<String[]> lovArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	lovArr.add(0,new String[]{"0","None"});
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> List Of Values : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeComboArr(lovArr, "", "size=1 id=lov_id", lov_id, 240));
	sb.append("</td>");
	sb.append("</tr>");

	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Indexed : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeComboArr(yesNoArr, "", "size=1 id=is_indexed", is_indexed, 240));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Visible on search list : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeComboArr(yesNoArr, "", "size=1 id=is_visible_on_search", is_visible_on_search, 240));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	
	
	ArrayList<String[]> getMethodArr=new ArrayList<String[]>();
	getMethodArr.add(new String[]{"PATTERN","Pattern"});
	getMethodArr.add(new String[]{"DB","Database SQL"});
	getMethodArr.add(new String[]{"JS","JavaScript"});
	getMethodArr.add(new String[]{"HTTP","Http Call"});
	
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Get Method : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeComboArr(getMethodArr, "", "id=get_method onchange=\"makePropertyGetMethodDetails('"+property_id+"');\"", get_method, 240));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Get Method Details : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append("<div id=\"dataPoolPropertyGetMethodDetailsDiv\">");
	sb.append(makePropertyGetMethodDetails(conn,session, property_id, get_method));
	sb.append("</div>");
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right> <b> Valid : </b> </td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeComboArr(yesNoArr, "", "size=1 id=is_valid", is_valid, 240));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("</table>");
	
	return sb.toString();
}

//----------------------------------------------------------------------------
String makePropertyGetMethodDetails(Connection conn, HttpSession session, String property_id, String get_method) {
	StringBuilder sb=new StringBuilder();
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	if (get_method.length()==0) {
		sb.append("Pick a get method");
		return sb.toString();	
	}
	
	String source_code="";
	String property_family_id="";
	String target_url="";
	String extract_method="";
	String extract_method_parameter="";
	
	if (!property_id.equals("0")) {
		sql="select source_code, property_family_id, target_url, extract_method, extract_method_parameter from tdm_pool_property where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",property_id});
		
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		source_code=arr.get(0)[0];
		property_family_id=arr.get(0)[1];
		target_url=arr.get(0)[2];
		extract_method=arr.get(0)[3];
		extract_method_parameter=arr.get(0)[4];
		
	}
	
	sb.append("<table class=\"table table-condensed\">");
	
	if (get_method.equals("DB")) {
		
		sb.append("<tr>");
		sb.append("<td nowrap align=right> SQL Statement :  </td>");
		sb.append("<td width=\"100%\">");
		sb.append("<textarea id=source_code rows=3 style=\"width:100%;\">"+clearHtml(source_code)+"</textarea>");
		sb.append("</td>");
		sb.append("</tr>");
		
		
		sb.append("<tr>");
		sb.append("<td nowrap align=right>  Db Family :  </td>");
		sb.append("<td width=\"100%\">");
		sql="select id, family_name from tdm_family order by 2";
		sb.append(makeCombo(conn, sql, "", "id=property_family_id", property_family_id, 0));
		sb.append("</td>");
		sb.append("</tr>");
		
		
		sb.append("<input type=hidden id=target_url>");

		
	}
	
	
	if (get_method.equals("PATTERN")) {
		
		if (source_code.length()==0) source_code="${xxx}";
		
		sb.append("<tr>");
		sb.append("<td nowrap align=right>  Pattern :  </td>");
		sb.append("<td width=\"100%\">");
		sb.append("<textarea id=source_code rows=2 style=\"width:100%;\">"+clearHtml(source_code)+"</textarea>");
		sb.append("</td>");
		sb.append("</tr>");
		
		sb.append("<input type=hidden id=target_url>");
		sb.append("<input type=hidden id=property_family_id>");
		sb.append("<input type=hidden id=target_url>");
		
	}
	
	
	if (get_method.equals("JS")) {
		
		sb.append("<tr>");
		sb.append("<td nowrap align=right>  JavaScript Code :  </td>");
		sb.append("<td width=\"100%\">");
		sb.append("<textarea id=source_code rows=3 style=\"width:100%;\">"+clearHtml(source_code)+"</textarea>");
		sb.append("</td>");
		sb.append("</tr>");
		
		sb.append("<input type=hidden id=target_url>");
		sb.append("<input type=hidden id=property_family_id>");
		sb.append("<input type=hidden id=target_url>");
		
	}
	
	if (get_method.equals("HTTP")) {
		
		sb.append("<tr>");
		sb.append("<td nowrap align=right>  Target Url :  </td>");
		sb.append("<td width=\"100%\">");
		sb.append(makeText("target_url", target_url, "", 0));
		sb.append("</td>");
		sb.append("</tr>");
		
		
		sb.append("<tr>");
		sb.append("<td nowrap align=right>  HTTP Load :  </td>");
		sb.append("<td width=\"100%\">");
		sb.append("<textarea id=source_code rows=3 style=\"width:100%;\">"+clearHtml(source_code)+"</textarea>");
		sb.append("</td>");
		sb.append("</tr>");
		
		sb.append("<input type=hidden id=property_family_id>");
		
	}
	
	
	ArrayList<String[]> extractMethodArr=new ArrayList<String[]>();
	extractMethodArr.add(new String[]{"NONE","None"});
	extractMethodArr.add(new String[]{"REGEX","Regular Expression"});
	extractMethodArr.add(new String[]{"JS","JavaScript"});
	extractMethodArr.add(new String[]{"XPATH","XPath"});
	
	
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right>  Extraction Method :  </td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeComboArr(extractMethodArr, "", "size=1 id=extract_method", extract_method, 240));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right>  Extraction Method Parameter :  </td>");
	sb.append("<td width=\"100%\">");
	sb.append("<textarea id=extract_method_parameter rows=3 style=\"width:100%;\">"+clearHtml(extract_method_parameter)+"</textarea>");
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("</table>");
	
	return sb.toString();	
}

//*************************************************************************************************

boolean isFieldNameOk(Connection conn, HttpSession session, String pool_id, String  id, String property_name) {
	
	if (property_name.length()>64) return false;
	
	if (property_name.length()==0) return false;
	
	if ("{id} {pool_id} {environment_id} {pool_date} {is_reserved} {reservation_date} {reserved_by} {reservation_note}  ".toUpperCase().indexOf("{"+property_name.toUpperCase()+"}")>-1) return false;
	
	Pattern r = Pattern.compile("^[a-zA-Z_][a-zA-Z0-9_]*$");
	Matcher match = r.matcher(property_name);

	
	if (match.find())  return true;
	
	
	return false;
}
//*************************************************************************************************
String getDataPoolProperties(Connection conn, HttpSession session, String app_id) {
	StringBuilder sb=new StringBuilder();
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id  from tdm_pool where app_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==0) {
		sb.append("Set pool configuration first");
		return sb.toString();
		
	}
	
	String pool_id=arr.get(0)[0];
		
	
	
	sql="select "+
		"id, "+
		" property_name, "+
		" (select group_name from tdm_pool_group where id=group_id) group_name, "+
		" is_searchable, "+
		" (select lov_name from tdm_pool_lov where id=lov_id) lov_name, "+
		" is_visible_on_search, "+
		" data_type, get_method, is_valid" +
		" from tdm_pool_property where pool_id=? "+
		" order by order_no ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	
	arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr class=active>");
	sb.append("<td><b></b></td>");
	sb.append("<td></td>");
	sb.append("<td><b>Group</b></td>");
	sb.append("<td><b>Name</b></td>");
	sb.append("<td><b>Type</b></td>");
	sb.append("<td><b>LOV</b></td>");
	sb.append("<td><b>Method</b></td>");
	sb.append("</tr>");
	
	
	for (int i=0;i<arr.size();i++) {
		String id=arr.get(i)[0];
		String property_name=arr.get(i)[1];
		String group_name=nvl(arr.get(i)[2],"Ungrouped");
		String is_searchable=arr.get(i)[3];
		String lov_name=nvl(arr.get(i)[4],"-");
		String is_visible_on_search=arr.get(i)[5];
		String data_type=arr.get(i)[6];
		String get_method=arr.get(i)[7];
		String is_valid=arr.get(i)[8];
		
		boolean is_field_ok=isFieldNameOk(conn, session, pool_id, id, property_name);
		
		String tr_class="";
		if (is_valid.equals("NO")) {
			tr_class="danger";
		}
		
		
		sb.append("<tr class=\""+tr_class+"\">");
		

	sb.append("<td nowrap align=center>");
		
		if (i>0) 
			sb.append("<font color=blue><span class=\"glyphicon glyphicon-arrow-up\" onclick=reorderPoolProperty('"+app_id+"','"+id+"','UP') ></span></font>");
		
		
		
		sb.append(" ");
		
		if (i<arr.size()-1) 
			sb.append("<font color=blue><span class=\"glyphicon glyphicon-arrow-down\"  onclick=reorderPoolProperty('"+app_id+"','"+id+"','DOWN')></span></font>");
		
		
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=removePoolProperty('"+app_id+"','"+id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-minus\"></span>");
		sb.append("</button>");
		sb.append("</td>");

		
		sb.append("<td>"+clearHtml(group_name)+"</td>");
		
		if (!is_field_ok)
			sb.append("<td><small><font color=red><span class=\"glyphicon glyphicon-exclamation-sign\"></span></font> <a href=\"javascript:addNewDataPoolPropertyDlg('"+app_id+"','"+id+"');\">"+clearHtml(property_name)+"</a></small></td>");
		else 
			sb.append("<td><small><a href=\"javascript:addNewDataPoolPropertyDlg('"+app_id+"','"+id+"');\">"+clearHtml(property_name)+"</a></small></td>");
		sb.append("<td><small>"+data_type+"</small></td>");
		sb.append("<td nowrap><small>"+clearHtml(lov_name)+"</small></td>");
		sb.append("<td><small>"+get_method+"</small></td>");
		
		
		sb.append("</tr>");

	}
	
	sb.append("</table>");
	
	return sb.toString();	
}

//*************************************************************************************************
void createNewProperty(Connection conn, HttpSession session, String pool_id) {
	String sql="SELECT AUTO_INCREMENT FROM information_schema.tables WHERE table_name = 'tdm_pool_property' AND table_schema = DATABASE()";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String pool_property_id="0";
	
	if (arr.size()==1) pool_property_id=arr.get(0)[0];
	
	setPoolPropertyId(conn,session,pool_property_id);
	
	sql="select max(order_no)+1 from tdm_pool_property where pool_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	int order_no=1;
	try {order_no=Integer.parseInt(arr.get(0)[0]);} catch(Exception e) {}
	
	sql="insert tdm_pool_property (id, pool_id, order_no) values (?, ?, ?) ";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_property_id});
	bindlist.add(new String[]{"INTEGER",pool_id});
	bindlist.add(new String[]{"INTEGER",""+order_no});
	
	execDBConf(conn, sql, bindlist);
	
	
}
//*************************************************************************************************
void setPoolPropertyId(Connection conn, HttpSession session, String pool_property_id) {
	session.setAttribute("pool_property_id", pool_property_id);
}

//*************************************************************************************************
String getPoolPropertyId(Connection conn, HttpSession session) {
	String pool_property_id=nvl((String) session.getAttribute("pool_property_id"),"0");
	
	return pool_property_id;
}


//*************************************************************************************************
String drawPoolScreen(Connection conn, HttpSession session) {
	StringBuilder sb=new StringBuilder();
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	
	sql="select \n" + 
		" id , "+
		" (select name from tdm_apps where id=app_id) app_name, \n" + 
		" (select target_name from tdm_target where id=target_id) target_name, \n" + 
		" status, \n" + 
		" date_format(start_date,?) start_date,\n"  + 
		" date_format(last_update_date,?) last_update_date,\n"  + 
		" date_format(last_check_date,?) last_check_date,\n"  + 
		" target_pool_size, pool_size, reserved_size, \n"+
		" cancel_flag, reload_flag, \n"   + 
		" is_debug, paralellism_count \n" + 
		" from tdm_pool_instance \n";
	
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	
	ArrayList<String[]> poolInsArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<table width=\"100%\">");
	sb.append("<tr>");
	sb.append("<td>");
	if (checkrole(session, "ADMIN"))
		sb.append(
		"<button type=button class=\"btn btn-sm btn-success\" onclick=\"addNewDataPoolInstance()\">"+
		" <span class=\"glyphicon glyphicon-plus\"></span> Add New Pool Instance "+
		"</button>"
		);
	sb.append("</td>");
	
	sb.append("<td align=right>");
	if (checkrole(session, "ADMIN"))
		sb.append(
		"<button type=button class=\"btn btn-sm btn-success\" onclick=\"listPoolInstances()\">"+
		" <span class=\"glyphicon glyphicon-refresh\"></span>"+
		"</button>"
		);
	sb.append("</td>");
	
	sb.append("</tr>");
	sb.append("</table>");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr class=active>");
	sb.append("<td><b>#</b></td>");
	sb.append("<td><b>Pool Application</b></td>");
	sb.append("<td><b>Target</b></td>");
	sb.append("<td><b>Status</b></td>");
	
	if (checkrole(session, "ADMIN")) {
		sb.append("<td><b>Debug</b></td>");
		sb.append("<td><b>Paralel#</b></td>");
		sb.append("<td><b>Target Size</b></td>");
		sb.append("<td><b>Times</b></td>");
		sb.append("<td><b>Stop</b></td>");
		sb.append("<td><b>Refresh</b></td>");
		
	}
	sb.append("<td><b>Actual Size</b></td>");
	sb.append("<td><b>Reserved</b></td>");
	sb.append("<td></td>");
	sb.append("</tr>");
	
	for (int i=0;i<poolInsArr.size();i++) {
		String id=poolInsArr.get(i)[0];
		String app_name=poolInsArr.get(i)[1];
		String target_name=poolInsArr.get(i)[2];
		String status=poolInsArr.get(i)[3];
		String start_date=poolInsArr.get(i)[4];
		String last_update_date=poolInsArr.get(i)[5];
		String last_check_date=poolInsArr.get(i)[6];
		String target_pool_size=poolInsArr.get(i)[7];
		String pool_size=poolInsArr.get(i)[8];
		String reserved_size=poolInsArr.get(i)[9];
		String cancel_flag=poolInsArr.get(i)[10];
		String reload_flag=poolInsArr.get(i)[11];
		String is_debug=poolInsArr.get(i)[12];
		String paralellism_count=poolInsArr.get(i)[13];
		
		String timesx="<table width=\"100%\">"+
				"<tr><td nowrap align=right><b>Start :</b></td>   <td nowrap width=\"200px;\"> "+nvl(start_date,"-")+"</td></tr>"+
				"<tr><td nowrap align=right><b>Update :</b></td>  <td nowrap width=\"200px;\"> "+nvl(last_update_date,"-")+"</td></tr>"+
				"<tr><td nowrap align=right><b>Check :</b></td>   <td nowrap width=\"200px;\"> "+nvl(last_check_date,"-")+"</td></tr>"+
				"</table>";
		
		String tr_class="";
		if (status.equals("START")) tr_class="warning";
		if (status.equals("ACTIVE")) tr_class="success";
		if (cancel_flag.equals("YES") || status.equals("INACTIVE")) tr_class="danger";

		sb.append("<tr class="+tr_class+">");
		sb.append("<td>"+id+"</td>");
		sb.append("<td>"+app_name+"</td>");
		sb.append("<td>"+target_name+"</td>");
		sb.append("<td>"+status+"</td>");
		if (checkrole(session, "ADMIN")) {
			sb.append("<td>"+is_debug+"</td>");
			sb.append("<td align=right>"+paralellism_count+"</td>");
			sb.append("<td align=right>"+formatnum(target_pool_size)+"</td>");
			sb.append("<td>"+timesx+"</td>");
			sb.append("<td>"+cancel_flag+"</td>");
			sb.append("<td>"+reload_flag+"</td>");
			
		}
		sb.append("<td align=right>"+formatnum(pool_size)+"</td>");
		sb.append("<td align=right>"+formatnum(reserved_size)+"</td>");
		
		
		sb.append("<td nowrap>");
		
		if (checkrole(session, "ADMIN") && (status.equals("INACTIVE") || status.equals("NEW") || status.equals("INITIALIZING") || cancel_flag.equals("YES")) )
			sb.append(
					" <button type=button class=\"btn btn-sm btn-success\" onclick=\"startDataPoolInstance('"+id+"')\">"+
					" <span class=\"glyphicon glyphicon-start\"></span> Start "+
					"</button>"
					);
		
		if (checkrole(session, "ADMIN") && (status.equals("ACTIVE") || status.equals("REFRESH")  || status.equals("START")) )
			sb.append(
					" <button type=button class=\"btn btn-sm btn-warning\" onclick=\"stopDataPoolInstance('"+id+"')\">"+
					" <span class=\"glyphicon glyphicon-stop\"></span> Stop "+
					"</button>"
					);
		
		if (checkrole(session, "ADMIN") && !status.equals("ACTIVE") && !status.equals("REFRESH") && !status.equals("START") && !status.equals("INITIALIZING"))
			sb.append(
					" <button type=button class=\"btn btn-sm btn-danger\" onclick=\"removeDataPoolInstance('"+id+"')\">"+
					" <span class=\"glyphicon glyphicon-tras\"></span> Remove "+
					"</button>"
					);		
		
		if (checkrole(session, "ADMIN") && status.equals("ACTIVE"))
			sb.append(
					" <button type=button class=\"btn btn-sm btn-success\" onclick=\"refreshDataPoolInstance('"+id+"')\">"+
					" <span class=\"glyphicon glyphicon-refresh\"></span> Refresh "+
					"</button>"
					);
		
		if (status.equals("ACTIVE"))
			sb.append(
					" <button type=button class=\"btn btn-sm btn-primary\" onclick=\"reserveDataPoolInstance('"+id+"')\">"+
					" <span class=\"glyphicon glyphicon-book\"></span> Reservation "+
					"</button>"
					);
		
		if (checkrole(session, "ADMIN"))
			sb.append(
					" <button type=button class=\"btn btn-sm btn-info\" onclick=\"setDataPoolInstanceParameters('"+id+"')\">"+
					" <span class=\"glyphicon glyphicon-cog\"></span>"+
					"</button>"
					);
		
		sb.append("</td>");
		
		
		sb.append("</tr>");
		
		
	}
	
	sb.append("</table>");
	
	return sb.toString();	
}



//*************************************************************************************************
String makeNewDataPoolInstanceDlg(Connection conn, HttpSession session) {
	StringBuilder sb=new StringBuilder();
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, name from tdm_apps where app_type='DPOOL' order by 2";
	ArrayList<String[]> appArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select id, target_name from tdm_target order by 2";
	ArrayList<String[]> targetArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select 'YES' from dual union all select 'NO' from dual";
	ArrayList<String[]> yesNoArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	sb.append("<h4><b>Add new pool instance</b></h4>");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Application : </b></td>");
	sb.append("<td>");
	sb.append(makeComboArr(appArr, "", "size=1 id=pool_ins_app_id", "", 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Target : </b></td>");
	sb.append("<td>");
	sb.append(makeComboArr(targetArr, "", "size=1 id=pool_ins_target_id", "", 0));
	sb.append("</td>");
	sb.append("</tr>");
		
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Target Pool Size : </b> (0 : unlimited)</td>");
	sb.append("<td>");
	sb.append(makeNumber("0", "target_pool_size", "0", "", "EDITABLE", "9", "0", ",", ".", "", "0", "999999999"));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Debug Mode : </b></td>");
	sb.append("<td>");
	sb.append(makeComboArr(yesNoArr, "", "size=1 id=is_debug", "NO", 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Paralellism Count : </b> (0 : unlimited)</td>");
	sb.append("<td>");
	sb.append(makeNumber("0", "paralellism_count", "1", "", "EDITABLE", "3", "0", ",", ".", "", "1", "999"));
	sb.append("</td>");
	sb.append("</tr>");
		
	
	
	sb.append("</table>");
	
	return sb.toString();	
}

//*************************************************************************************************
void addNewDataPoolInstance(
		Connection conn, 
		HttpSession session, 
		String pool_ins_app_id, 
		String pool_ins_target_id, 
		String target_pool_size,
		String is_debug, 
		String paralellism_count) {
	
	String sql="insert into tdm_pool_instance (app_id, target_id, target_pool_size, is_debug, paralellism_count) values (?, ?, ?, ?, ?)";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_ins_app_id});
	bindlist.add(new String[]{"INTEGER",pool_ins_target_id});
	bindlist.add(new String[]{"INTEGER",target_pool_size});
	bindlist.add(new String[]{"STRING",is_debug});
	bindlist.add(new String[]{"INTEGER",paralellism_count});

	execDBConf(conn, sql, bindlist);
	
}

//*************************************************************************************************
void removeDataPoolInstance(Connection conn, HttpSession session, String pool_instance_id) {
	
	String sql="delete from tdm_pool_instance where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_instance_id});
	
	execDBConf(conn, sql, bindlist);
	
}

//*************************************************************************************************
void startDataPoolInstance(Connection conn, HttpSession session, String pool_instance_id) {
	
	String sql="update tdm_pool_instance set status='START' where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_instance_id});
	
	execDBConf(conn, sql, bindlist);
}
	
//*************************************************************************************************
void stopDataPoolInstance(Connection conn, HttpSession session, String pool_instance_id) {
	
	String sql="update tdm_pool_instance set cancel_flag='YES' where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_instance_id});
	
	execDBConf(conn, sql, bindlist);
	
}

//*************************************************************************************************
void refreshDataPoolInstance(Connection conn, HttpSession session, String pool_instance_id) {
	
	String sql="update tdm_pool_instance set reload_flag='YES' where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_instance_id});
	
	execDBConf(conn, sql, bindlist);
	
}


//*************************************************************************************************
String makeDataPoolInstanceParametersDlg(Connection conn, HttpSession session, String pool_instance_id) {
	StringBuilder sb=new StringBuilder();
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select app_id, target_id, target_pool_size, is_debug, paralellism_count from tdm_pool_instance where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_instance_id});
	
	ArrayList<String[]> currIns=getDbArrayConf(conn, sql, 1, bindlist);
	
	String app_id=currIns.get(0)[0];
	String target_id=currIns.get(0)[1];
	String target_pool_size=currIns.get(0)[2];
	String is_debug=currIns.get(0)[3];
	String paralellism_count=currIns.get(0)[4];
	
	
	sql="select id, name from tdm_apps where app_type='DPOOL' order by 2";
	bindlist.clear();
	ArrayList<String[]> appArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select id, target_name from tdm_target order by 2";
	bindlist.clear();
	ArrayList<String[]> targetArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select 'YES' from dual union all select 'NO' from dual";
	bindlist.clear();
	ArrayList<String[]> yesNoArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	sb.append("<h4><b>Edit pool instance parameters</b></h4>");
	
	sb.append("<input type=hidden id=editing_pool_instance_id value="+pool_instance_id+">");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Application : </b></td>");
	sb.append("<td>");
	sb.append(makeComboArr(appArr, "", "disabled size=1 id=editing_pool_ins_app_id", app_id, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Target : </b></td>");
	sb.append("<td>");
	sb.append(makeComboArr(targetArr, "", "disabled  size=1 id=editing_pool_ins_target_id", target_id, 0));
	sb.append("</td>");
	sb.append("</tr>");
		
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Target Pool Size : </b> (0 : unlimited)</td>");
	sb.append("<td>");
	sb.append(makeNumber("0", "editing_target_pool_size", target_pool_size, "", "EDITABLE", "9", "0", ",", ".", "", "0", "999999999"));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Debug Mode : </b></td>");
	sb.append("<td>");
	sb.append(makeComboArr(yesNoArr, "", "size=1 id=editing_is_debug", is_debug, 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td align=right><b> Paralellism Count : </b> (0 : unlimited)</td>");
	sb.append("<td>");
	sb.append(makeNumber("0", "editing_paralellism_count", paralellism_count, "", "EDITABLE", "3", "0", ",", ".", "", "1", "999"));
	sb.append("</td>");
	sb.append("</tr>");
		
	
	
	sb.append("</table>");
	
	return sb.toString();	
}


//*************************************************************************************************
void updateDataPoolInstanceParameters(
		Connection conn, 
		HttpSession session, 
		String pool_instance_id, 
		String target_pool_size, 
		String is_debug, 
		String paralellism_count) {
	
	String sql="update tdm_pool_instance set target_pool_size=?, is_debug=?, paralellism_count=? where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",target_pool_size});
	bindlist.add(new String[]{"STRING",is_debug});
	bindlist.add(new String[]{"INTEGER",paralellism_count});
	bindlist.add(new String[]{"INTEGER",pool_instance_id});
	
	execDBConf(conn, sql, bindlist);
	
}

//*************************************************************************************************
String get_data_table_name(Connection conn, HttpSession session, String pool_instance_id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select table_name "+
		" from information_schema.tables  "+
		" where table_name in ('tdm_pool_data_"+pool_instance_id+"','tdm_pool_data_"+pool_instance_id+"_tmp') "+
		" and table_schema=DATABASE() order by 1";
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr!=null && arr.size()==1) return arr.get(0)[0];
	
	return "";
}

//*************************************************************************************************
String get_lov_table_name(Connection conn, HttpSession session, String pool_instance_id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select table_name "+
		" from information_schema.tables  "+
		" where table_name in ('tdm_pool_data_lov_"+pool_instance_id+"','tdm_pool_data_lov_"+pool_instance_id+"_tmp') "+
		" and table_schema=DATABASE() order by 1";
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr!=null && arr.size()==1) return arr.get(0)[0];
	
	return "";
}

//*************************************************************************************************
String makeReserveDataPoolInstanceDlg(Connection conn, HttpSession session, String pool_instance_id) {
	StringBuilder sb=new StringBuilder();
	String sql="";
	
	String table_name_for_data=get_data_table_name(conn,session,pool_instance_id);
	String table_name_for_lov=get_lov_table_name(conn,session,pool_instance_id);
	
	if (table_name_for_data.length()==0) {
		sb.append("</font color=red>");
		sb.append("<h4>No data found. Reload data pool first!</h4>");
		sb.append("</font>");
		return sb.toString();
	}
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select p.id from "+
		"	tdm_pool_instance pi, tdm_pool p "+
		"	where pi.app_id=p.app_id  "+
		"	and pi.id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTGER",pool_instance_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) {
		sb.append("</font color=red>");
		sb.append("<h4>Pool is not found!</h4>");
		sb.append("</font>");
		return sb.toString();
	}
	
	String pool_id=arr.get(0)[0];
	
	//--------------------------------------
	StringBuilder sbFilter=new StringBuilder();
	
	getDataPoolFilters(conn, session, pool_instance_id, pool_id, table_name_for_lov, sbFilter);
	
	sb.append(sbFilter.toString());
	
	//--------------------------------------
	sb.append("<table width=\"100%\" cellspacing=0 cellpadding=0 border=0>");
	sb.append("<tr>");
	
	sb.append("<td>");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"setDataPoolFilters('"+pool_instance_id+"');\" >");
	sb.append("<span class=\"glyphicon glyphicon-play\"></span> Execute Query ");
	sb.append("</button>");
	sb.append("</td>");
	
	sb.append("<td align=right>");
	
	String show_only_my_reservatinons=nvl((String) session.getAttribute("show_only_my_reservations_for_ins_"+pool_instance_id),"NO");
	String is_checked="";
	
	if (show_only_my_reservatinons.equals("YES")) is_checked="checked";
	sb.append(" <b><font color=#D490A1>Show only my reservations</font></b>");
	sb.append(" <input type=checkbox "+is_checked+" id=ch_show_only_my_reservatinons onclick=dataPoolSetShowOnlyMyReservations('"+pool_instance_id+"')> ");
	sb.append("</td>");
	
	sb.append("</tr>");
	sb.append("</table>");
	//--------------------------------------
	StringBuilder sbRes=new StringBuilder();
	
	getDataPoolResults(conn, session, pool_instance_id, pool_id, table_name_for_data, table_name_for_lov, 100, sbRes);
	
	sb.append("<div id=divPoolDataList>");
	sb.append(sbRes.toString());
	sb.append("</div>");
	
	return sb.toString();	
}
//*************************************************************************************************
String makeloadPoolDataList(Connection conn, HttpSession session, String pool_instance_id ) {
	StringBuilder sb=new StringBuilder();
	String sql="";
	
	String table_name_for_data=get_data_table_name(conn,session,pool_instance_id);
	String table_name_for_lov=get_lov_table_name(conn,session,pool_instance_id);
	
	if (table_name_for_data.length()==0) {
		sb.append("</font color=red>");
		sb.append("<h4>No data found. Reload data pool first!</h4>");
		sb.append("</font>");
		return sb.toString();
	}
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select p.id from "+
		"	tdm_pool_instance pi, tdm_pool p "+
		"	where pi.app_id=p.app_id  "+
		"	and pi.id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTGER",pool_instance_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) {
		sb.append("</font color=red>");
		sb.append("<h4>Pool is not found!</h4>");
		sb.append("</font>");
		return sb.toString();
	}
	
	String pool_id=arr.get(0)[0];
	
	StringBuilder sbRes=new StringBuilder();
	
	getDataPoolResults(conn, session, pool_instance_id, pool_id, table_name_for_data, table_name_for_lov, 100, sbRes);
	
	sb.append(sbRes.toString());
	
	return sb.toString();	
	
	
}
 
//*************************************************************************************************
void getDataPoolFilters(
		Connection conn, 
		HttpSession session, 
		String pool_instance_id,
		String pool_id, 
		String table_name_for_lov,
		StringBuilder sb) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, group_name from tdm_pool_group where pool_id=? \n"+
		"	and id in (select group_id from tdm_pool_property where pool_id=?) \n"+
		"	order by order_no";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	bindlist.add(new String[]{"INTEGER",pool_id});
	
	ArrayList<String[]> arrGrp=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append("<div>");
	
	
	
	sb.append("<ul class=\"nav nav-pills\" role=\"tablist\">");
	 
	
	
	for (int i=0;i<arrGrp.size();i++) {
		String group_id=arrGrp.get(i)[0];
		String group_name=arrGrp.get(i)[1];
		
		String tab_class="";
		if (i==0) tab_class="active";
		
		sb.append("<li role=\"presentation\" class=\""+tab_class+"\"><a href=\"#grp"+group_id+"\" aria-controls=\"grp"+group_id+"\" role=\"tab\" data-toggle=\"tab\">"+group_name+"</a></li>");
	}
	
	sb.append("</ul>");
	
	sb.append("<div class=\"tab-content\">");
	
	int prop_id=0;
	
	for (int i=0;i<arrGrp.size();i++) {
		String group_id=arrGrp.get(i)[0];
		String group_name=arrGrp.get(i)[1];
		
		String tab_class="";
		if (i==0) tab_class="active";
		
		
		sb.append("<div role=\"tabpanel\" class=\"tab-pane "+tab_class+" \" id=\"grp"+group_id+"\" style=\"min-height: 240px; max-height: 240px; overflow-x: scroll; overflow-y: scroll;\">");

		sql="select id, property_name, property_title, data_type, lov_id "+
				" from tdm_pool_property "+
				" where pool_id=? and is_searchable='YES' and is_valid='YES' "+
				" and group_id=? "+
				" order by order_no";
			
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",pool_id});
		bindlist.add(new String[]{"INTEGER",group_id});
		
		ArrayList<String[]> listPropArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		

		
		//sb.append("<table width=\"100%\" cellspacing=0 cellpadding=0 border=0>");
		sb.append("<table class=\"table table-condensed table-striped\">");
		for (int p=0;p<listPropArr.size();p++) {
			String property_id=listPropArr.get(p)[0];
			String property_name=listPropArr.get(p)[1];
			String property_title=listPropArr.get(p)[2];
			String data_type=listPropArr.get(p)[3];
			String lov_id=nvl(listPropArr.get(p)[4],"0");
			
			
			sb.append("<tr>");
			
			sb.append("<td align=right nowrap>");
			sb.append("<b>"+clearHtml(property_title)+" : </b>  ");
			sb.append("</td>");
			
			sb.append("<td width=\"80%\">");


			sb.append("<input type=hidden id=filter_property_name_"+prop_id+ " value=\""+property_name+"\" >");
			prop_id++;
			//----------------------
			String key="filter_for_ins_"+pool_instance_id+"_field_val_of_"+property_name;
			String curr_val=nvl((String) session.getAttribute(key),"");
			
			
			
			if (!lov_id.equals("0")) {
				sql="select lov_value, IFNULL(lov_title,lov_value) lov_title "+
					" from "+table_name_for_lov+
					" where property_id=?";
				
				
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",property_id});
				
				ArrayList<String[]> listLov=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
				ArrayList<String[]> pickedArr=new ArrayList<String[]>();
						
				String[] currArr=curr_val.split("\\|::\\|");
				for (int v=0;v<currArr.length;v++) pickedArr.add(new String[]{currArr[v]});
				
				sb.append(makePickList("0", "val_of_"+property_name, listLov, pickedArr, "", ""));
			} 
			else if (data_type.equals("DATE")) {
				sb.append(makeDate("0", "val_of_"+property_name, curr_val, "", "SEARCH"));
			}
			else if (data_type.equals("INTEGER") || data_type.equals("LONG") || data_type.equals("DOUBLE")) {
				sb.append(makeNumber("0", "val_of_"+property_name, curr_val, "", "SEARCH", "12", "2", ",", ".", "", "0", "999999999999"));
			}
			else {
				sb.append(makeText("val_of_"+property_name, curr_val, "", 0));
			}
			//----------------------
			sb.append("</td>");
			
			sb.append("</tr>");
			
			
		}
		sb.append("</table>");
		
		sb.append("</div>");
	}
	
	
	sb.append("</div>"); //<div class=\"tab-content\"> 
	
	
	sb.append("</div>");
	
}
//*************************************************************************************************
void getDataPoolResults(
		Connection conn, 
		HttpSession session, 
		String pool_instance_id,
		String pool_id,
		String table_name_for_data,
		String table_name_for_lov,
		int res_limit,
		StringBuilder sb
		) {
	String sql="";
	
	
	
	if (table_name_for_data.length()==0) {
		sb.append("</font color=red>");
		sb.append("<h4>No data found. Reload data pool first!</h4>");
		sb.append("</font>");
		return;
	}
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();


	
	sql="select id, property_name, property_title, data_type "+
		" from tdm_pool_property "+
		" where pool_id=? and is_visible_on_search='YES' and is_valid='YES' "+
		" order by order_no";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	
	ArrayList<String[]> listPropArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	sql="select property_id, lov_value, lov_title  from  "+table_name_for_lov;
		
	bindlist.clear();		
	ArrayList<String[]> lovArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
	HashMap<String, String> hm=new HashMap<String, String>();
	
	for (int i=0;i<lovArr.size();i++) {
		String property_id=lovArr.get(i)[0];
		String lov_value=lovArr.get(i)[1];
		String lov_title=nvl(lovArr.get(i)[2],lov_value);
		
		hm.put("LOV_OF_"+property_id+"_FOR_"+lov_value,lov_title);
	}
	
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr class=info>");
	sb.append("<td></td>");
	
	StringBuilder sbSql=new StringBuilder();
	sbSql.append("select id, is_reserved, reservation_date, reserved_by ");
	
	
	
	for (int i=0;i<listPropArr.size();i++) {
		String property_id=listPropArr.get(i)[0];
		String property_name=listPropArr.get(i)[1];
		String property_title=nvl(listPropArr.get(i)[2],property_name);
		
		sb.append("<td><b>");
		
		sb.append(clearHtml(property_title));
		
		sb.append("</b></td>");
		
		sbSql.append("," + property_name+" ");
	}
	
	sb.append("</tr>");
	sbSql.append(" from  "+table_name_for_data);
	
	bindlist.clear();
	
	String show_only_my_reservations=nvl((String ) session.getAttribute("show_only_my_reservations_for_ins_"+pool_instance_id),"NO");
	
	if (show_only_my_reservations.equals("YES")) {
		sbSql.append(" where is_reserved='Y' and reserved_by=?");
		int user_id=(Integer) session.getAttribute("userid");
		bindlist.add(new String[]{"INTEGER",""+user_id});
	}
	else {
		sbSql.append(" where is_reserved='N' ");
		
		
		
		StringBuilder whereCond=new StringBuilder();
		ArrayList<String[]> whereBindlist=new ArrayList<String[]>();
		makePoolWhereCondition(conn, session,pool_instance_id, pool_id, whereCond, whereBindlist);
		
		if (whereCond.length()>0) {
			sbSql.append(whereCond.toString());
			bindlist.addAll(whereBindlist);
		}
		
	}
	
	
	
	
	ArrayList<String[]> resArr=getDbArrayConf(conn, sbSql.toString(), res_limit, bindlist);
	
	
	
	for (int r=0;r<resArr.size();r++) {
		
		String data_id=resArr.get(r)[0];
		
		sb.append("<tr>");
		
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-info\" onclick=\"pickFromDataPool('"+pool_instance_id+"','"+data_id+"'); \">");
		sb.append("<span class=\"glyphicon glyphicon-book\"></span>");
		sb.append("</button>");
		sb.append("</td>");
		
		for (int c=0;c<listPropArr.size();c++) {
			
			String val=resArr.get(r)[c+4];
			
			String property_id=listPropArr.get(c)[0];
			String data_type=listPropArr.get(c)[3];
			
			if (hm.containsKey("LOV_OF_"+property_id+"_FOR_"+val))
				val=hm.get("LOV_OF_"+property_id+"_FOR_"+val);
			
			if (data_type.equals("INTEGER") || data_type.equals("LONG"))
				sb.append("<td>");
			else 
				sb.append("<td>");
			
			sb.append(nvl(clearHtml(val),"-"));
			sb.append("</td>");
		}
		sb.append("</tr>");
	}
	
	
	
	sb.append("</table>");
	
}

//*************************************************************************************************
String makePickFromDataPoolDlg(
		Connection conn, 
		HttpSession session, 
		String pool_instance_id,
		String data_id
		) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	String table_name_for_data=get_data_table_name(conn,session,pool_instance_id);
	String table_name_for_lov=get_lov_table_name(conn,session,pool_instance_id);
	
	
	if (table_name_for_data.length()==0) {
		sb.append("</font color=red>");
		sb.append("<h4>No data found. Reload data pool first!</h4>");
		sb.append("</font>");
		return sb.toString();
	}
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();


	sql="select p.id from "+
			"	tdm_pool_instance pi, tdm_pool p "+
			"	where pi.app_id=p.app_id  "+
			"	and pi.id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTGER",pool_instance_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) {
		sb.append("</font color=red>");
		sb.append("<h4>Pool is not found!</h4>");
		sb.append("</font>");
		return sb.toString();
	}
	
	String pool_id=arr.get(0)[0];
	sql="select id, property_name, property_title, data_type "+
		" from tdm_pool_property "+
		" where pool_id=? and is_valid='YES' "+
		" order by order_no ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	
	ArrayList<String[]> listPropArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select property_id, lov_value, lov_title  from  "+table_name_for_lov;
		
	bindlist.clear();		
	ArrayList<String[]> lovArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
	HashMap<String, String> hm=new HashMap<String, String>();
	
	for (int i=0;i<lovArr.size();i++) {
		String property_id=lovArr.get(i)[0];
		String lov_value=lovArr.get(i)[1];
		String lov_title=nvl(lovArr.get(i)[2],lov_value);
		
		hm.put("LOV_OF_"+property_id+"_FOR_"+lov_value,lov_title);
	}
	
	
	StringBuilder sbSql=new StringBuilder();
	sbSql.append("select id, is_reserved, reservation_date, reserved_by, reservation_note ");
	
	
	
	for (int i=0;i<listPropArr.size();i++) {
		String property_id=listPropArr.get(i)[0];
		String property_name=listPropArr.get(i)[1];
		
		
		sbSql.append("," + property_name+" ");
	}
	
	sbSql.append(" from  "+table_name_for_data+" where id=?");
	sbSql.append(" and ( is_reserved='N' or (is_reserved='Y' and reserved_by=?) ) ");
	
	int user_id=(Integer) session.getAttribute("userid");
	
	bindlist.clear();
	bindlist.add(new String[]{"INTGER",data_id});
	bindlist.add(new String[]{"INTGER",""+user_id});

	
	ArrayList<String[]> resArr=getDbArrayConf(conn, sbSql.toString(), 1, bindlist);
	
	if (resArr==null || resArr.size()==0) {
		sb.append("</font color=red>");
		sb.append("<h4>Pool data is not found!</h4>");
		sb.append("</font>");
		return sb.toString();
	}
	
	sb.append("<h4><b>Confirm Reservation</b></h4>");
	
	sb.append("<input type=hidden id=picking_data_id value=\""+data_id+"\">");
	sb.append("<input type=hidden id=picking_pool_instance_id value=\""+pool_instance_id+"\">");
	
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr class=info>");
	sb.append("<td align=right><b>Data ID : </b></td>");
	sb.append("<td width=\"70%\">"+data_id+"</td>");
	sb.append("</tr>");
	
	String reservation_note=resArr.get(0)[4];
	
	sb.append("<tr class=info>");
	sb.append("<td align=right><b>Reservation Note : </b></td>");
	sb.append("<td width=\"70%\">");
	sb.append("<textarea id=reservation_note cols=3 style=\"width:100%;\" >"+clearHtml(reservation_note)+"</textarea>");
	sb.append("</td>");
	sb.append("</tr>");
	
	int r=0;
	
	for (int c=0;c<listPropArr.size();c++) {
		
		String property_id=listPropArr.get(c)[0];
		String property_name=listPropArr.get(c)[1];
		String property_title=listPropArr.get(c)[2];
		String data_type=listPropArr.get(c)[3];

		
		sb.append("<tr>");
		sb.append("<td align=right nowrap><b>"+clearHtml(property_title)+" : </b></td>");
		
		String val=resArr.get(r)[c+5];
		
		
		if (hm.containsKey("LOV_OF_"+property_id+"_FOR_"+val))
			val=hm.get("LOV_OF_"+property_id+"_FOR_"+val);
		
		sb.append("<td width=\"70%\">");
		
		sb.append(nvl(clearHtml(val),"-"));
		sb.append("</td>");
		
		sb.append("</td>");
	}
	
	
	
	sb.append("</table>");
	
	return sb.toString();
	
}

//*************************************************************************************************
void pickFromDataPool(
		Connection conn, 
		HttpSession session, 
		String pool_instance_id,
		String data_id,
		String reservation_note) {
	
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	String table_name_for_data=get_data_table_name(conn,session,pool_instance_id);
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="update "+table_name_for_data+" set is_reserved='Y',reservation_date=now(), reserved_by=?, reservation_note=? where id=?";
	
	String user_id=""+ (Integer) session.getAttribute("userid");
	
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",user_id});
	bindlist.add(new String[]{"STRING",reservation_note});
	bindlist.add(new String[]{"INTEGER",data_id});
	
	execDBConf(conn, sql, bindlist);
}


//*************************************************************************************************
void dataPoolSetFilter(
		Connection conn, 
		HttpSession session, 
		String pool_instance_id,
		String filter_field_name,
		String filter_field_value) {
	
	String key="filter_for_ins_"+pool_instance_id+"_field_val_of_"+filter_field_name;
	
	session.setAttribute(key, filter_field_value);

}

//*************************************************************************************************
void dataPoolSetShowOnlyMyReservations(
		Connection conn, 
		HttpSession session, 
		String pool_instance_id,
		String filter_val) {
	
	String key="show_only_my_reservations_for_ins_"+pool_instance_id;
	
	session.setAttribute(key, filter_val);
	
}

//*************************************************************************************************
void makePoolWhereCondition(
		Connection conn, 
		HttpSession session,
		String pool_instance_id, 
		String pool_id,
		StringBuilder whereCond, 
		ArrayList<String[]> whereBindlist
		) {
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select id, property_name, data_type, lov_id "+
			" from tdm_pool_property "+
			" where pool_id=? and is_searchable='YES' and is_valid='YES' "+
			" order by order_no ";
		
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",pool_id});
	
	ArrayList<String[]> queryPropArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	for (int p=0;p<queryPropArr.size();p++) {
		String property_id=queryPropArr.get(p)[0];
		String property_name=queryPropArr.get(p)[1];
		String data_type=queryPropArr.get(p)[2];
		String lov_id=nvl(queryPropArr.get(p)[3],"0");
		
		String key="filter_for_ins_"+pool_instance_id+"_field_val_of_"+property_name;
		String filter_val=nvl((String) session.getAttribute(key),"");
		if (filter_val.length()==0) continue;
		
		if (!lov_id.equals("0")) {
			String inner_sql="";
			String[] valArr=filter_val.split("\\|::\\|");
			int x=0;
			for (int i=0;i<valArr.length;i++) {
				String a_val=valArr[i];
				if (a_val.length()==0) continue;
				if (x>0) inner_sql=inner_sql+", ";
				inner_sql=inner_sql+"?";
				x++;
				whereBindlist.add(new String[]{data_type,a_val});
			}
			
			if (inner_sql.length()>0) {
				inner_sql= " and "+property_name+" in ("+inner_sql+") ";
				whereCond.append(inner_sql);
			}
			
			
		}
		else if (data_type.equals("DATE")) {
			String inner_sql=" and "+property_name+"=?  ";
			whereBindlist.add(new String[]{data_type,filter_val});
		}
		else if (data_type.equals("INTEGER") || data_type.equals("LONG") || data_type.equals("DOUBLE")) {
			String inner_sql=" and "+property_name+"=?  ";
			whereBindlist.add(new String[]{data_type,filter_val});
		}
		else {
			String inner_sql="";
			String[] valArr=filter_val.split(" ");
			int x=0;
			for (int i=0;i<valArr.length;i++) {
				String a_val=valArr[i];
				if (a_val.length()==0) continue;
				if (x>0) inner_sql=inner_sql+" OR  ";
				inner_sql=inner_sql+property_name+"=?";
				x++;
				whereBindlist.add(new String[]{data_type,a_val});
			}
			
			if (inner_sql.length()>0) {
				inner_sql= " and ("+inner_sql+") ";
				whereCond.append(inner_sql);
			}
			
		}
		
		
		
	} //for 


}


//----------------------------------------------------------------------------
void reorderByGroup(
		Connection conn, 
		HttpSession session, 
		String table_name, 
		String group_field, 
		String current_id, 
		String direction) {
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select "+group_field+" from "+table_name+" where id=? ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",current_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) {
		return; 
	}
	
	String group_field_val=arr.get(0)[0];
	
	sql="select id from "+table_name+" where "+group_field+"=? order by order_no";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_field_val});
	
	
	arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	if (arr==null || arr.size()==1) {
		return;
	}
	
	int loc_id=-1;
	
	for (int i=0;i<arr.size();i++) {
		String id=arr.get(i)[0];
		if (id.equals(current_id)) {
			loc_id=i;
			break;
		}
	}
	
	
	if (loc_id==-1) {
		return;
	}
	
	

	int swap_id=loc_id;
	
	if (direction.equals("UP")) swap_id=loc_id-1;
	if (direction.equals("DOWN")) swap_id=loc_id+1;

	if (swap_id<0) {
		return;
	}
	if (swap_id>arr.size()-1) {
		return;
	}
	
	if (swap_id==loc_id) return;
	
	//swap
	String[] tmp=arr.get(loc_id);
	arr.set(loc_id, arr.get(swap_id));
	arr.set(swap_id, tmp);
	
	sql="update "+table_name+" set order_no=? where id=?";
	
	
	for (int i=0;i<arr.size();i++) {
		String id=arr.get(i)[0];
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",""+(i+1)});
		bindlist.add(new String[]{"INTEGER",id});
		
		execDBConf(conn, sql, bindlist);
		
	}
	


}
//----------------------------------------------------------------------------
void setMaskDiscoveryAction(
		Connection conn, 
		HttpSession session, 
		String discovery_id, 
		String action_name) {
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="";
	
	if (action_name.equals("CANCEL"))
		sql="update tdm_discovery set cancel_flag='YES' where id=?";
	else if (action_name.equals("RESTART"))
		sql="update tdm_discovery set status='NEW',cancel_flag=null where id=?";
	else if (action_name.equals("DELETE"))
		sql="delete from tdm_discovery where id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",discovery_id});
	
	execDBConf(conn, sql, bindlist);
	
	if (action_name.equals("DELETE")) {
		sql="delete from tdm_discovery_rel where discovery_id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",discovery_id});
		
		execDBConf(conn, sql, bindlist);
		
		sql="delete from tdm_discovery_result where discovery_id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",discovery_id});
		
		execDBConf(conn, sql, bindlist);
		
	}
}



//************************************************************
String checkListDlg(Connection conn, String app_id) {
	
	StringBuilder sb=new StringBuilder();
	
	String sql="select id, checklist_name, checklist_statement, not_check, operand, operand_parameters, valid from tdm_copy_app_checklist where app_id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	ArrayList<String[]> checkListArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	ArrayList<String[]> operList=new ArrayList<String[]>();
	operList.add(new String[]{"EQUALS","Equals"});
	operList.add(new String[]{"GREATER","Greater Than"});
	operList.add(new String[]{"LESS","Less Than"});
	operList.add(new String[]{"EXISTS","Record Exists"});
	operList.add(new String[]{"CONTAINS","Contains"});
	operList.add(new String[]{"STARTS","Starts With"});
	operList.add(new String[]{"ENDS","Ends With"});
	operList.add(new String[]{"REGEX","Matches Regex"});
	
	ArrayList<String[]> yesNoArr=new ArrayList<String[]>();
	yesNoArr.add(new String[]{"YES","Yes"});
	yesNoArr.add(new String[]{"NO","No"});
	
	ArrayList<String[]> notArr=new ArrayList<String[]>();
	notArr.add(new String[]{"NOT","NOT!"});
		
	sb.append("<h4>Checklist after copy completed</h4>");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=addNewCopyCheckList('"+app_id+"')>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"> Add New Checklist");
	sb.append("</button>");

	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr class=active>");
	sb.append("<td><b>Check Name</b></td>");
	sb.append("<td><b>Statement</b></td>");
	sb.append("<td colspan=2><b>Operand</b></td>");
	sb.append("<td><b>Parameters</b></td>");
	sb.append("<td><b>Valid</b></td>");
	sb.append("<td><b></b></td>");
	sb.append("</tr>");

	
	 
	for (int i=0;i<checkListArr.size();i++) {
		
		String checklist_id=checkListArr.get(i)[0];
		String checklist_name=checkListArr.get(i)[1];
		String checklist_statement=checkListArr.get(i)[2];
		String not_check=checkListArr.get(i)[3];
		String operand=checkListArr.get(i)[4];
		String operand_parameters=checkListArr.get(i)[5];
		String valid=checkListArr.get(i)[6];
		
		if (valid.equals("NO"))
			sb.append("<tr class=danger>");
		else 
			sb.append("<tr>");
		
		sb.append("<td>");
		sb.append(makeText("checklist_name", checklist_name, "onchange=\"saveCopyFilterField(this,'"+checklist_id+"');\" ", 0));
		sb.append("</td>");

		sb.append("<td>");
		sb.append("<textarea id=checklist_statement rows=3 style=\"width:100%; \" onchange=\"saveCopyFilterField(this,'"+checklist_id+"');\" >"+clearHtml(checklist_statement)+"</textarea>");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(notArr, "", "id=not_check onchange=\"saveCopyFilterField(this,'"+checklist_id+"');\" ", not_check, 90));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(operList, "", "id=operand size=1 onchange=\"saveCopyFilterField(this,'"+checklist_id+"');\" ", operand, 150));
		sb.append("</td>");

		sb.append("<td>");
		sb.append("<textarea id=operand_parameters rows=3 style=\"width:100%; \" onchange=\"saveCopyFilterField(this,'"+checklist_id+"');\" >"+clearHtml(operand_parameters)+"</textarea>");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(yesNoArr, "", "id=valid size=1 onchange=\"saveCopyFilterField(this,'"+checklist_id+"');\" ", valid, 90));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=removeCopyCheckList('"+checklist_id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-minus\">");
		sb.append("</button>");		
		sb.append("</td>");


		sb.append("</tr>");
		
		
		
	}
	
	
	sb.append("</table>");
	
	if (checkListArr.size()==0) 
		sb.append("No checklist added yet.");
	
	
	return sb.toString();
	
}




//************************************************************
int getTabOrderInApp(Connection conn, HttpSession session, String app_id, String catalog, String schema, String table) {
	int ret1=-1;
	String sql= "select tab_order from tdm_tabs where app_id=? and cat_name=? and schema_name=? and tab_name=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"STRING",catalog});
	bindlist.add(new String[]{"STRING",schema});
	bindlist.add(new String[]{"STRING",table});
	ArrayList<String[]> tabList=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (tabList!=null && tabList.size()==1) {
		try{ret1=Integer.parseInt(tabList.get(0)[0]);} catch(Exception e) {}
		return ret1;
	}
	
	
	sql="SELECT rel_app_id FROM test.tdm_apps_rel where app_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	ArrayList<String[]> relApps=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	System.out.println("********* Related APPS : "+relApps.size());
	for (int r=0;r<relApps.size();r++) {
		String rel_app_id=relApps.get(r)[0];
		ret1=getTabOrderInApp(conn, session, rel_app_id,catalog, schema, table);
		if (ret1>-1) {
			return 0;
		}
	}
	
	
	return -1;
}

//************************************************************
boolean isDuplicatedInApp(Connection conn, HttpSession session, String app_id, String tab_id, String catalog, String schema, String table) {
	int ret1=-1;
	String sql= "select 1 from tdm_tabs where app_id=? and cat_name=? and schema_name=? and tab_name=? and id!=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"STRING",catalog});
	bindlist.add(new String[]{"STRING",schema});
	bindlist.add(new String[]{"STRING",table});
	bindlist.add(new String[]{"INTEGER",tab_id});

	ArrayList<String[]> tabList=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (tabList!=null && tabList.size()==1) {
		return true;
	}
	
	
	return false;
}
//************************************************************
String checkProblems(Connection conn, HttpSession session, String app_id, String db_id) {
	
	
	
	StringBuilder sb=new StringBuilder();
	
String copy_level=getCopyAppLevel(conn,session,app_id);
	
	if (copy_level.equals("SINGLELEVEL")) {
		sb.append("Should be single level application.");
		return sb.toString();
	}

	String sql= "";

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql= "select id, family_id, cat_name, schema_name, tab_name, tab_order, recursive_fields "+
			" from tdm_tabs where app_id=? order by tab_order";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	
	ArrayList<String[]> tabList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	if (tabList.size()==0) {
		sb.append("No table in application.");
		return sb.toString();
	}
	
	
	
	Connection connApp=getconn(conn, db_id);
	
	if (connApp==null) {
		sb.append("invalid databae id : "+db_id+ "=>"+last_connection_error);
		return sb.toString();
	}
	
	DatabaseMetaData md=null;
	
	try {md=connApp.getMetaData();} catch(Exception e) {md=null;}
	
	if (md==null) {
		closeconn(connApp);
		sb.append("Metadata is not valid.");
		return sb.toString();
	}
	
	sb.append("<p align=right>");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=checkProblems()><span class=\"glyphicon glyphicon-refresh\"></button>");
	sb.append("</p>");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	sb.append("<tr class=info>");
	sb.append("<td><b>Table</b></td>");
	sb.append("<td><b>Problems</b></td>");
	sb.append("</tr>");
	
	for (int i=0;i<tabList.size();i++) {
		String tab_id=tabList.get(i)[0];
		String family_id=tabList.get(i)[1];
		String cat_name=tabList.get(i)[2];
		String schema_name=tabList.get(i)[3];
		String tab_name=tabList.get(i)[4];
		int tab_order=Integer.parseInt(tabList.get(i)[5]);
		String recursive_fields=tabList.get(i)[6];

		String problems="";
		//foreign keyleri al
		ArrayList<String[]> keys=getRelations(md, schema_name, tab_name, "IMPORTED");
		
		System.out.println("\n...Parent Tables for : "+cat_name+"."+schema_name+"."+tab_name+" => "+keys.size());
		
		for (int k=0;k<keys.size();k++) {
			String parent_tab_cat=nvl(keys.get(k)[0],"${default}");
			String parent_tab_owner=keys.get(k)[1];
			String parent_tab_table=keys.get(k)[2];
			
			
			
			int parent_tab_order=getTabOrderInApp(conn,session,app_id, parent_tab_cat, parent_tab_owner, parent_tab_table);
			
			if (parent_tab_order==-1) {
				problems=problems+"<tr class=danger><td width=\"50%\">"+parent_tab_cat+"."+parent_tab_owner+"."+parent_tab_table+"</td><td>Not Found in any app</td><td width=\"15%\" align=center><input type=button value=Fix onclick=addTableToApp('"+parent_tab_cat+"*"+parent_tab_owner+"*"+parent_tab_table+"')></td></tr>";
			}
			
			if (parent_tab_order>tab_order) {
				problems=problems+"<tr class=danger><td width=\"50%\">"+parent_tab_cat+"."+parent_tab_owner+"."+parent_tab_table+"</td><td>Should Come Before</td><td width=\"15%\" align=center><input type=button value=Fix onclick=changeTableOrder('"+app_id+"','"+parent_tab_order+"','"+tab_order+"')></td></tr>";
			}
			
			if (parent_tab_order==tab_order && recursive_fields.length()==0) {
				problems=problems+"<tr class=danger><td width=\"50%\">"+parent_tab_cat+"."+parent_tab_owner+"."+parent_tab_table+"</td><td>Recursive</td><td width=\"15%\">-</td></tr>";
			}
		}
		
		boolean isDuplicated=isDuplicatedInApp(conn,session,app_id, tab_id, cat_name, schema_name, tab_name);
		
		if (isDuplicated) {
			problems=problems+"<tr class=danger><td width=\"50%\">"+cat_name+"."+schema_name+"."+tab_name+"</td><td> Multiple Instance</td><td width=\"15%\" align=center><input type=button value=Fix onclick=removeTableFromApp('"+tab_id+"')></td></tr>";
		}
		
		if (problems.length()>0) {
			problems="<table class=\"table table-striped table-condensed\">"+problems+"</table>";
		}
		
		
		sb.append("<tr>");
		sb.append("<td>"); 
		sb.append("<b><font color=red>"+cat_name+"</font></b>");
		sb.append(".<b><font color=blue>"+schema_name+"</font></b>");
		sb.append(".<font color=black>"+tab_name+"</font>");
		sb.append("</td>");
		sb.append("<td width=\"50%\">"+problems+"</td>");
		sb.append("</tr>");
	}

	sb.append("</table>");
	
	closeconn(connApp);
	
	return sb.toString();
	
}

//*********************************************************************************
void  addNewCopyCheckList(Connection conn, HttpSession session, String app_id, String checklist_name) {
	String sql= "insert into tdm_copy_app_checklist (app_id, checklist_name) values (?,?)";

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"STRING",checklist_name});
	
	execDBConf(conn, sql, bindlist);


}
//*********************************************************************************
void  removeCopyCheckList(Connection conn, HttpSession session, String checklist_id) {
	String sql= "delete from tdm_copy_app_checklist where id=? ";

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",checklist_id});
	
	execDBConf(conn, sql, bindlist);


}

//************************************************************************************
String getProfileUsage(Connection conn,String mask_prof_id) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql=""+
			" select app_type, a.name,schema_name,tab_name,field_name "+
			" from tdm_fields f, tdm_tabs t, tdm_apps a "+
			" where f.tab_id=t.id and t.app_id=a.id "+
			" and (mask_prof_id=? or condition_expr like concat('%MASK(',?,')%')  )"+
			" order by 1,2,3";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",mask_prof_id});
	bindlist.add(new String[]{"STRING",mask_prof_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 8, bindlist);

	sb.append("<table class=table>");
	sb.append("<tr class=active>");
	sb.append("<td>Type</td>");
	sb.append("<td>Application</td>");
	sb.append("<td>Schema</td>");
	sb.append("<td>Table</td>");
	sb.append("<td>Column</td>");
	sb.append("</tr>");
	
	for (int i=0;i<arr.size();i++) {
		sb.append("<tr>");
		sb.append("<td><small><small>"+arr.get(i)[0]+"</small></small></td>");
		sb.append("<td><small><small>"+arr.get(i)[1]+"</small></small></td>");
		sb.append("<td><small><small>"+arr.get(i)[2]+"</small></small></td>");
		sb.append("<td><small><small>"+arr.get(i)[3]+"</small></small></td>");
		sb.append("<td><small><small>"+arr.get(i)[4]+"</small></small></td>");
		sb.append("</tr>");
	}
	
	sb.append("</table>");
	
	return sb.toString();
}


//****************************************
public ArrayList<String[]> getCatalogListFromConn(Connection connApp, String db_type) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	String catalog="";
	
	DatabaseMetaData md = null;
	ResultSet rs = null;
	
	try{
		md = connApp.getMetaData();
		rs = md.getCatalogs();
		
		System.out.println("Getting xxxxxxxxxxxxxxx");
		while (rs.next()) {
			
			System.out.println("cat...");
			catalog=nvl(rs.getString("TABLE_CAT"),"null");
			System.out.println("catalog : "+catalog);
			
			if (db_type.equals("MSSQL") && isCatalogMSSQLOffline(connApp,catalog)) {
				System.out.println("getCatalogListFromConn:skip => "+catalog);
				continue;
			}
			
        ret1.add(new String[]{catalog});
		}
		rs.close();
		
		//Oracle does not have catalog
		if (ret1.size()==0) 
			ret1.add(new String[]{"${default}"});
		
	} catch(Exception e) {
		e.printStackTrace();
	} finally {
		try{rs.close();} catch(Exception e) {}
	}
	
	return ret1;
}

//****************************************
public ArrayList<String[]> getSchemaListFromConn(Connection conn, String target_catalog) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	String owner="";
	
	DatabaseMetaData md = null;
	ResultSet rs = null;
	try{
		md = conn.getMetaData();
		
		setCatalogForConnection(conn, target_catalog);
		
		rs = md.getSchemas();
		 
		
		
		while (rs.next()) {
			try{owner=nvl(rs.getString("TABLE_SCHEM"),"${default}");} catch(Exception e) {owner="${default}";}
			
			

          ret1.add(new String[]{target_catalog+"."+owner});
  		}
		rs.close();
		
		
	} catch(Exception e) {
		e.printStackTrace();
	} finally {
		try{rs.close();} catch(Exception e) {}
	}
	
	return ret1;
}

//************************************************************************************
ArrayList<String[]> getDesignerCatalogList(Connection conn, HttpSession session, String env_id, StringBuilder errmsg) {

	
	ArrayList<String[]> ownerList=(ArrayList<String[]>) session.getAttribute("CATALOG_LIST_OF_"+env_id);
	if (ownerList!=null) return ownerList;
		
	
	String db_type=getEnvDBParam(conn, env_id, "DB_TYPE");
	
	if (db_type.toUpperCase().contains("MONGO")) {
		ownerList=new ArrayList<String[]>();
		ownerList.addAll(getMongoDbList(conn, env_id));
		return ownerList;
	}
	
	Connection appconn=getconn(conn, env_id);
	
     if (appconn==null) {
     	errmsg.setLength(0);
     	errmsg.append("<font color=red>Catalog list not obtained. Connection is invalid</font> :<br>"+last_connection_error);
        ownerList=new ArrayList<String[]>();
        }
     else {
     	 ownerList=new ArrayList<String[]>();
     	 ownerList=getCatalogListFromConn(appconn, db_type);
     	 session.setAttribute("CATALOG_LIST_OF_"+env_id, ownerList);
     }
     
     closeconn(appconn);
	
      
		
	
	
	return ownerList;
}
//************************************************************************************
ArrayList<String[]> filterSchemaListByCatalog(ArrayList<String[]> ownerList,String catalog_filter) {


	
	System.out.println("Filtering schema list with catalog : "+catalog_filter);
	
	ArrayList<String[]> filteredArr=new ArrayList<String[]>();
	
	//filter by catalog
	for (int i=0;i<ownerList.size();i++) {
		String item=ownerList.get(i)[0];
		String catalog="${default}";
		String schema=ownerList.get(i)[0];
		//System.out.println("Checking : "+item);
		int dot_pos=item.indexOf(".");
		if (dot_pos>-1) {
			//System.out.println(". is found at "+dot_pos);
			catalog=nvl(item.substring(0, dot_pos),"${default}");
			try{schema=item.substring(dot_pos+1);} catch(Exception e) {}
			
			
		}
		
		if (catalog_filter.length()==0 || catalog_filter.equals("All") || catalog_filter.equals("${default}") || catalog.contains(catalog_filter)) 
			filteredArr.add(new String[]{item,item.replace("${default}.", "")});
		
		
		
	}
	
	return filteredArr;
}
//************************************************************************************
ArrayList<String[]> getDesignerSchemaList(Connection conn, HttpSession session, String env_id, String catalog_filter, StringBuilder errmsg) {

	if (nvl(env_id,"0").equals("0")) 
		return new ArrayList<String[]>();
	
	ArrayList<String[]> ownerList=(ArrayList<String[]>) session.getAttribute("SCHEMA_LIST_OF_"+env_id);
	if (ownerList!=null) {
		System.out.println("Getting schema list from cache ...");
		return filterSchemaListByCatalog(ownerList,catalog_filter);
	}
		
		
	String db_type=getEnvDBParam(conn, env_id, "DB_TYPE");
	boolean is_mongo=false;
	if (db_type.toUpperCase().contains("MONGO")) is_mongo=true;
	
	if (is_mongo) {
			ownerList=getMongoDbList(conn, env_id);
			session.setAttribute("SCHEMA_LIST_OF_"+env_id, ownerList);
	}
	else {
		Connection appconn=getconn(conn, env_id);
        if (appconn==null) {
        	errmsg.setLength(0);
        	errmsg.append("<font color=red>Schema list not obtained. Connection is invalid</font> :<br>"+last_connection_error);
	        ownerList=new ArrayList<String[]>();
	        }
        else {
        	 ownerList=new ArrayList<String[]>();
        	
        	 System.out.println("Getting schema list from db ...");
        	 
        	// ArrayList<String[]> catalogList=getCatalogListFromConn(appconn);
        	 ArrayList<String[]> catalogList=getDesignerCatalogList(conn, session, env_id, errmsg);
        	 
        	  
        	 
        	 for (int c=0;c<catalogList.size();c++) {
        		 String a_catalog=catalogList.get(c)[0];
        		 
        		 if (db_type.toUpperCase().contains("MSSQL") && isCatalogMSSQLOffline(appconn,a_catalog)) {
        			 System.out.println("DB "+a_catalog+" is offline. Skipping....");
        			 continue;
        		 }
        		 
        		 System.out.println("Adding schemas for catalog :"+a_catalog+"...");
        		 ownerList.addAll(getSchemaListFromConn(appconn,a_catalog));
        		 
        		 
        		 if (db_type.toUpperCase().contains("MYSQL")) {
        			 ownerList.add(new String[]{a_catalog+"."+a_catalog});
        		 }
        	 }
        		
        	 
        	
        	
        	 
        	 session.setAttribute("SCHEMA_LIST_OF_"+env_id, ownerList);
        }
        closeconn(appconn);
	}
     
	
	
	
	return filterSchemaListByCatalog(ownerList, catalog_filter);
}

//************************************************************************************

boolean isCatalogMSSQLOffline(Connection connapp, String cat) {
	String sql="SELECT 1 FROM sys.databases db INNER JOIN sys.master_files mf ON db.database_id = mf.database_id "+
			" WHERE db.state = 6 and db.name=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"STRING",cat});
	
	ArrayList<String[]> arr=getDbArrayConf(connapp, sql, 1, bindlist);
	if (arr.size()==1) return true;
	return false;
}

//************************************************************************************
String fillTableListHeader(Connection conn, HttpSession session,String env_id,String to_refresh) {

	
	
	if (to_refresh.equals("REFRESH")) {
		session.setAttribute("CATALOG_LIST_OF_"+env_id, null);
		session.setAttribute("SCHEMA_LIST_OF_"+env_id, null);
		session.setAttribute("TABLE_LIST_OF_"+env_id, null);
	}
	
	session.setAttribute("env_id", env_id);
	
	
	
	StringBuilder sb=new StringBuilder();
	StringBuilder errmsg=new StringBuilder();
	
	if (env_id.equals("0")) {
		sb.append("Choose a database to proceed");
		return sb.toString();
	}
	
	
		 
	
       	
	String curr_catalog_name=nvl((String) session.getAttribute("catalog_name_filter_for_"+env_id),"");
   	String table_name_filter=nvl((String) session.getAttribute("table_name_filter_for_"+env_id),"");
   	
   	String include_added_tables=nvl((String) session.getAttribute("include_added_tables_for_"+env_id),"checked");;
   	String include_commented_tables=nvl((String) session.getAttribute("include_commented_tables_for_"+env_id),"checked");
   	String include_discarded_tables=nvl((String) session.getAttribute("include_discarded_tables_for_"+env_id),"checked");
   	
   	ArrayList<String[]> catalogList=getDesignerCatalogList(conn, session, env_id, errmsg);
   	
   	if (errmsg.length()>0) 	return errmsg.toString();
   	
   	

   	sb.setLength(0);
      	
      	sb.append("<table width=\"100%\">"+
      				"<tr>"+
   				"<td colspan=2 align=center>"+
  						"<input type=checkbox "+include_added_tables+" id=include_added_tables  onclick=fillTableList()> Added "+
  						"<input type=checkbox "+include_commented_tables+" id=include_commented_tables  onclick=fillTableList()> Commented "+
  						"<input type=checkbox "+include_discarded_tables+" id=include_discarded_tables onclick=fillTableList()> Discarded "+
  					"</td>"+
  					"</tr>"+
  					"<tr>"+
			    		"<td align=right><b>Catalog </b></td>"+
  	    			    "<td>"+
     					    makeComboArr(catalogList, "catalogList", "id=catalogList onchange=\"fillSchemaList();\" ", curr_catalog_name, 0)+
     				     "</td>"+
    				"</tr>"+
  					"<tr>"+
  			    		"<td align=right><b>Owner </b></td>"+
      	    			"<td>"+
         					"<div id=div_schema>"+
         							fillSchemaList(conn, session, env_id, curr_catalog_name)+
      	    				"</div>"+
         				"</td>"+
     				"</tr>"+
  					"<tr>"+
  					"<td align=right><b>Table </b></td>"+
  					"<td>"+
  					"<input type=text id=tableNameFilter value=\""+table_name_filter+"\" style=\"width:100%; \" onchange=fillTableList() \">"+
  					"</td>"+
	   				"</tr>"+
  				"</table>");
      	


   

    return sb.toString();

}

//************************************************************************************
String fillSchemaList(Connection conn, HttpSession session, String env_id, String catalog_filter) {
	StringBuilder sb=new StringBuilder();
	
	System.out.println("Getting schema list for catalog : "+catalog_filter);
	
	StringBuilder errmsg=new StringBuilder();

	ArrayList<String[]> ownerList=getDesignerSchemaList(conn, session, env_id, catalog_filter, errmsg);
	
	if (errmsg.length()>0) 	return errmsg.toString();
	
	String curr_schema_name=nvl((String) session.getAttribute("schema_name_filter_for_"+env_id),"All");
	
	sb.append(makeComboArr(ownerList, "ownerList", "id=ownerList onchange=\"fillTableList();\" ", curr_schema_name, 0));
	
	return sb.toString();
}

//****************************************************************************************
String makeSqlEditorWindow(Connection conn, HttpSession session, 
		String env_id,
		String tab_id,
		String tab_name,
		String in_sql,
		String cat
		) {
	String editor_sql="";
	boolean is_jbase=false;
	boolean is_mssql=false;
	boolean is_mysql=false;
	boolean is_mongo=false;
	
	StringBuilder sb=new StringBuilder();
	
	String db_type=getEnvDBParam(conn, env_id, "DB_TYPE");
	
	String final_catalog=cat;
	
	String full_tab_name="";
	String filter="";
	
	if (db_type.equals("JBASE")) is_jbase=true;
	if (db_type.equals("MSSQL")) is_mssql=true;
	if (db_type.equals("MYSQL")) is_mysql=true;
	if (db_type.toUpperCase().contains("MONGO")) is_mongo=true;
	
	if (in_sql.length()>0) 
		editor_sql=in_sql;
	else
	{	
		if (!tab_id.equals("0") && !tab_id.equals("x")) {
			String sql="select concat(cat_name,'*',schema_name,'*',tab_name) full_tab_name, tab_filter from tdm_tabs where id="+tab_id;
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			
			ArrayList<String[]> tabInfoArr=getDbArrayConf(conn, sql, 1, bindlist);
			
			
			
			//String full_tab_name=getDBSingleVal(conn, sql);
			
			
			if (tabInfoArr.size()==1) {
				full_tab_name=tabInfoArr.get(0)[0];
				filter=tabInfoArr.get(0)[1];
			}
			else 
				full_tab_name="table*not*found";
			
			
			
			String[] arr=full_tab_name.split("\\*");
			
			String t_cat_name=arr[0];
			String t_schema_name=arr[1];
			String t_tab_name=arr[2];
			
			final_catalog=t_cat_name;
			
			if (is_mongo) {
				tab_name=t_tab_name;
			} else {
				
				tab_name=t_schema_name+"."+t_tab_name;
				
				if (!is_jbase) tab_name=addStartEnd(conn, env_id, tab_name);
			}
			
			 
		}
		else {
			
			
			String[] arr=tab_name.split("\\.");
			
			

			if (is_mongo) {
				
				String[] arrx=tab_name.split("\\.");
				final_catalog=arrx[0];
				try{tab_name=arrx[2];} catch(Exception e) {tab_name=arrx[1];}
			}
			else {
				
				if (arr.length==2) {
					tab_name=cat+"."+tab_name;
					arr=tab_name.split("\\.");
				}
				
				String t_cat_name=arr[0];
				String t_schema_name=arr[1];
				String t_tab_name=arr[2];
				
				final_catalog=cat;
				tab_name=t_schema_name+"."+t_tab_name; 
				
				
				
				if (!is_jbase)
					tab_name=addStartEnd(conn, env_id, tab_name); 
			}
			
		}
		
		if (is_jbase)
			editor_sql="select "+getJbaseFieldsWithComma(tab_name)+" from \""+tab_name+"\"";
		else if (is_mongo)
			editor_sql="db."+tab_name+".find()";
		else if (is_mssql)
			editor_sql="select top 100 * from "+tab_name+"  as t";
		else if (is_mysql)
			editor_sql="select  * from "+tab_name+ " t limit 0,100";
		else 
			editor_sql="select * from "+tab_name+" t ";
		
		if (!is_jbase && !is_mongo && filter.replaceAll("\n|\r| |\t", "").length()>0) 
			editor_sql=editor_sql+"\nwhere "+replaceTableFilter(filter, "t");
		
		
		
	}
	
	
	
	String sql="select id, name from tdm_envs order by name";
	String combo_envs=makeCombo(conn, sql, "size=1 env_id", "id=sql_editor_env_id onchange=changeSqlEditorEnvironment() ", env_id , 320);
	
	
	
	
	sb.append( ""+
			"<input type=hidden id=querying_table value=\""+codehtml(tab_name)+"\">"+
			
			"<table width=\"100%\">"+
			 
			
			"<tr>"+
				"<td colspan=2>" + 
						"<textarea  id=sql_statement rows=4 style=\"width:100%; background-color:black; color:yellow; font-family:Courier New, Courier, monospace; \">"+editor_sql+"</textarea>"+
				"</td>"+
			"</tr>"+

			"<tr bgcolor=lightgray>"+
			"<td nowrap> "+
				"<table border=0><tr>"+
				"<td><b>Database :"+"</b> </td><td>"+combo_envs+"</td> " +
				"<td><b>Catalog :"+"</b> </td><td>"+
				"<div id=sqlEditorCatComboDiv>"+
					makeSqlEditorCatalogCombo(conn,session,env_id, final_catalog)+
				"</div>"+
				"</td> " +
				"<td align=center><button type=button id=sqlEditorQueryButton class=\"btn btn-success btn-sm\" onclick=fillSqlEditorResult()> Run Query </button></td> " +
				"</tr></table>"+
			 "</td>"+
		   "</tr>"+

		"</table>");
	
				
		
		sb.append("<div id=sqlEditorResultsDiv style=\"min-height: 400px; max-height: 400px; overflow-x: scroll; overflow-y: scroll;\"></div>");
		
		return sb.toString();
}

//**********************************************************************************************************
String fillSqlEditorResult(Connection conn, HttpSession session, String env_id, String cat, String editor_sql, String tab_name) {
	
	StringBuilder sb=new StringBuilder();
	
	
	if (!checkrole(session, "DESIGN") && !checkrole(session, "ADMIN"))  {
		sb.setLength(0);
		sb.append("<table border=1>");
		sb.append("<tr bgcolor=#FADABC><td>");
		sb.append("You dont have permission to run sql");
		sb.append("</td></tr>");
		sb.append("</table>");
	}
	
	
	
	sb.append(getTabContent(conn, env_id, editor_sql, tab_name, cat)); 
	
	return sb.toString();
}
//**********************************************************************************************************
String makeSqlEditorCatalogCombo(Connection conn, HttpSession session, String env_id, String cat) {
	StringBuilder errmsg=new StringBuilder();
	
	System.out.println("cat="+cat);
	
	ArrayList<String[]> catList=getDesignerCatalogList(conn, session, env_id, errmsg);
	
	
	String combo_catalog=makeComboArr(catList, "", "size=1 id=query_catalog ", cat, 320); 
	
	if (errmsg.length()>0)
		System.out.println("Error@ makeSqlEditorCatalogCombo : " +errmsg.toString());
	
	return combo_catalog;
	
}

//**********************************************************************************************************
String fillAppTables(Connection conn, HttpSession session, String app_id, String filter) {
	if (filter.equals("-") || filter.trim().length()==0 || filter.equals("*") || filter.equals("x"))
		filter="";
	
	session.setAttribute("app_table_filter", filter);
	
	String sql="select app_type from tdm_apps where id="+app_id;
	
	String app_type=getDBSingleVal(conn, sql);
	
	String app_filter=nvl((String) session.getAttribute("app_table_filter"),"");
	String filter_family_id=nvl((String) session.getAttribute("filter_family_id"),"");
	
	StringBuilder sb=new StringBuilder();
	
	if (app_type.equals("MASK") || app_type.equals("DMASK") ) {
		sb.append("<table class=\"table table-condensed\">"+
				"<tr class=active>");
		
		
		sb.append("<td>");
		
				
		sb.append(
				"<td>"+
				"&nbsp;&nbsp;&nbsp;" + 
				"<input type=text id=app_table_filter size=20 maxlength=100 value=\""+app_filter+"\" onkeypress=\"return runAppFilter(event)\">" + 
				"<button  type=button class=\"btn btn-default btn-sm\" onclick=fillAppTabList()>"+
				" <font color=black><span class=\"glyphicon glyphicon-search\"></span></font>"+
				"</button>"
				);
				
		sb.append( 		
				"&nbsp;<button  type=button class=\"btn btn-default btn-sm\" onclick=openCopyTableDlg()>"+
				" <font color=darkblue><span class=\"glyphicon glyphicon-import\"></span></font>"+
				"  Copy From"  + 
				"</button>");
		
		sb.append( 		
				"&nbsp;<button  type=button class=\"btn btn-default btn-sm\" onclick=exportMaskingConfiguration()>"+
				" <font color=darkblue><span class=\"glyphicon glyphicon-export\"></span></font>"+
				"  Export"  + 
				"</button>");

		sb.append( 		
				"&nbsp;<button  type=button class=\"btn btn-default btn-sm\" onclick=openBulkConfigDlg()>"+
				" <font color=darkblue><span class=\"glyphicon glyphicon-import\"></span></font>"+
				"  Import"  + 
				"</button>");
		

		if (app_type.equals("MASK")) 
			sb.append(
					"&nbsp;<button  type=button class=\"btn btn-default btn-sm\" onclick=openAppOptions('"+app_id+"')>"+
					" <font color=black><span class=\"glyphicon glyphicon-cog\"></span></font>"+
					"</button>");
				
		if (app_type.equals("DMASK")) {
			
			
			sb.append(
					"&nbsp;<button  type=button class=\"btn btn-default btn-sm\" onclick=openDynamicMaskingConfiguration('"+app_id+"')>"+
					" <font color=black><span class=\"glyphicon glyphicon-cog\"></span></font>"+
					"  Configuration "  + 
					"</button>");
			
			sb.append( 		
					"&nbsp;<button  type=button class=\"btn btn-default btn-sm\" onclick=reloadDMProxyConfigurations('"+app_id+"')>"+
					" <font color=green><span class=\"glyphicon glyphicon-refresh\"></span></font>"+
					"  Reload Configuration "  + 
					"</button>");
			
			sb.append(
					"&nbsp;<span id=exception_APPLICATION_"+app_id+"> "+ 
					makeExceptionButton(conn, session, "APPLICATION",app_id)  +  
					"</span> ");
			
			
		}
			
		sb.append("</td>");	
		
		sb.append(
				"</tr>"+
				"</table>");
				
				
	}
		
			
	if (app_type.equals("COPY")) {
		
		String hide_needed_tables_checked=nvl((String) session.getAttribute("hide_needed_tables"),"");	

		String family_list_sql="select id, family_name from tdm_family order by 2";
							
		sb.append("<table class=\"table\">"+
				"<tr class=active>"+
					"<td>"+
					"<button type=button class=\"btn btn-sm btn-default\" onclick=\"openFilterTableDlg()\">"+
					" <font color=black><span class=\"glyphicon glyphicon-filter\"></span></font> Filters"+
					"</button>"+
					"</td>"+
					"<td>"+
					"<button type=button class=\"btn btn-sm btn-default\" onclick=\"openAppDependancyDlg()\">"+
					" <font color=black><span class=\"glyphicon glyphicon-flash\"></span></font> Prereq. Apps "+
					"</button>"+
					"</td>"+
					"<td>"+
					"<button type=button class=\"btn btn-sm btn-default\" onclick=\"openScriptDlg('PREP')\">"+
					" <font color=black><span class=\"glyphicon glyphicon-import\"></span></font> Prep. Scripts "+
					"</button>"+
					"</td>"+
					"<td>"+
					"<button type=button class=\"btn btn-sm btn-default\" onclick=\"openScriptDlg('POST')\">"+
					" <font color=black><span class=\"glyphicon glyphicon-export\"></span></font> Post Scripts "+
					"</button>"+
					"</td>"+
					"<td>"+
					"<button type=button class=\"btn btn-sm btn-default\" onclick=\"openChecklistDlg()\">"+
					" <font color=black><span class=\"glyphicon glyphicon-check\"></span></font> Checklist "+
					"</button>"+
					"</td>"+
					"<td>"+
					"<button type=button class=\"btn btn-sm btn-default\" onclick=\"checkProblems()\">"+
					" <font color=black><span class=\"glyphicon glyphicon-exclamation-sign\"></span></font> Problems "+
					"</button>"+
					"</td>"+
					"<td>"+
					makeCombo(conn, family_list_sql, "", "id=filter_family_id onchange=setFamilyIdFilter() ", filter_family_id, 150)+
					"</td>"+
					"<td align=right width=\"100%\">"+
					"<input type=checkbox id=hide_needed_tables "+hide_needed_tables_checked+" onclick=hideShowNeededTables()>"+
					" <small>Hide Needs</small>"+
					"</td>"+
				"</tr>"+
				"</table>");
	}
		
	
	if (app_type.equals("DPOOL")) {
		

							
		sb.append("<table class=\"table\">"+
				"<tr class=active>"+
					
					
					
					"<td>"+ 
					
					" <button type=button class=\"btn btn-sm btn-primary\" onclick=\"openDataPoolConfigurationDlg('"+app_id+"')\">"+
					" <span class=\"glyphicon glyphicon-cog\"></span> Base SQL"+
					"</button>"+

					" <button type=button class=\"btn btn-sm btn-primary\" onclick=\"openDataPoolLovDlg('"+app_id+"')\">"+
					" <span class=\"glyphicon glyphicon-cog\"></span> LOV"+
					"</button>"+
							
					" <button type=button class=\"btn btn-sm btn-primary\" onclick=\"openDataPoolGroupDlg('"+app_id+"')\">"+
					" <span class=\"glyphicon glyphicon-cog\"></span> Group"+
					"</button>"+

					"</td>"+
					
					"<td align=right>"+
					"<button type=button class=\"btn btn-sm btn-success\" onclick=\"addNewDataPoolPropertyDlg('"+app_id+"','0')\">"+
					" <span class=\"glyphicon glyphicon-plus\"></span> Add New Property "+
					"</button>"+
					"</td>"+
				"</tr>"+
				"</table>");
	}
	 
	if (app_type.equals("DPOOL")) {
		sb.append("<div id=divPoolProperties>");
		sb.append(getDataPoolProperties(conn, session, app_id));
		sb.append("</div>");
	}
		
	else 
		sb.append(getChildTables(conn, session, app_id, 0, filter, filter_family_id));
	
	return sb.toString();
}

//************************************************************************************
void changeScramblePartialType(Connection conn, HttpSession session, String mask_prof_id, String scramble_type) {
	String sql="update tdm_mask_prof set scramble_part_type=?   where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"STRING",scramble_type});
	bindlist.add(new String[]{"INTEGER",mask_prof_id});
	
	execDBConf(conn, sql, bindlist);
	
}
//************************************************************************************
String makeScramblePartialParameters(Connection conn, HttpSession session, String mask_prof_id) {
	StringBuilder sb=new StringBuilder();

	
	String sql="select scramble_part_type, scramble_part_type_par1, scramble_part_type_par2, random_char_list from tdm_mask_prof where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",mask_prof_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (bindlist.size()==0) 
		return "Profile not found!";
	
	String scramble_part_type=arr.get(0)[0];
	String scramble_part_type_par1=arr.get(0)[1];
	String scramble_part_type_par2=arr.get(0)[2];
	String random_char_list=arr.get(0)[3];
	
	
	
	if (scramble_part_type.length()==0) 
		return "Pick a scramble method";
	
	String sample_str="No sample found";
	boolean put_par1=false;
	boolean put_par2=false;
	boolean par1_as_numeric=true;
	
	if ("EXCEPT".equals(scramble_part_type)) {
		put_par1=true;
		put_par2=false;
		par1_as_numeric=false;
		sample_str="<i>Except 'BA'</i> :  BA<b>1234567</b> ==> BA<b>7654132</b>";

	}
	else if ("ALL".equals(scramble_part_type)) {
		put_par1=false;
		put_par2=false;
		par1_as_numeric=false;
		sample_str="<i>Except 'BA'</i> :  <b>123456</b> ==> <b>623541</b>";

	} 
	else if ("FIRST,LAST,EXCEPT_FIRST,EXCEPT_LAST".contains(scramble_part_type) ) {
		put_par1=true;
		put_par2=false;
		par1_as_numeric=true;
		
		if (scramble_part_type.equals("FIRST")) 
			sample_str="<i>First 4</i> :  <b>1234</b>56789 ==> <b>4213</b>56789";
		else if (scramble_part_type.equals("LAST")) 
			sample_str="<i>Last 4</i> :  12345<b>6789</b> ==> 12345<b>7986</b>";
		else if (scramble_part_type.equals("EXCEPT_FIRST")) 
			sample_str="<i>Except First 3 chars</i> :  123<b>456789</b> ==> 123<b>954876</b>";
		else if (scramble_part_type.equals("EXCEPT_LAST")) 
			sample_str="<i>Except Last 5 chars</i> :  <b>1234</b>56789 ==> <b>4123</b>56789";

	}
	else if ("BETWEEN_FIRST_LAST".contains(scramble_part_type)) {
		put_par1=true;
		put_par2=true;
		par1_as_numeric=true;
		sample_str="<i>Between first 2 and last 1 </i> :  CC<b>123456</b>F ==> CC<b>653241</b>F";
	} else if ("BETWEEN".contains(scramble_part_type)) {
		put_par1=true;
		put_par2=true;
		par1_as_numeric=true;
		sample_str="<i>Between 3 and 5</i> :  12<b>345</b>6789 ==> 12<b>534</b>6789";
	}
	 else {
		return "unknown scramble method";
	}
	
	
	sb.append("<table class=table>");
	
	sb.append("<tr class=active>");
	sb.append("<td>");
	sb.append("Sample : [" + sample_str+"]");
	sb.append("</td>");
	sb.append("</tr>");
	
	if (put_par1) {
		sb.append("<tr>");
		sb.append("<td><b>Parameter 1:</b></td>");
		sb.append("</td>");
		sb.append("<tr>");
		sb.append("<td>");
		
		if (par1_as_numeric)
			sb.append(makeNumber("", "scramble_part_type_par1", scramble_part_type_par1, "changeProfileField('scramble_part_type_par1',this.value)", "EDIT", "3", "0", ",", ".", "", "1", "999"));
		else {
			sb.append("<input type=text id=scramble_part_type_par1 size=50 maxlength=1000 value=\""+clearHtml(scramble_part_type_par1)+"\" onchange=changeProfileField('scramble_part_type_par1',this.value)>");
			sb.append("<br>");
			sb.append("comma(,) as delimiter");
		}
			
		sb.append("</td>");
		sb.append("</tr>");
	}
	
	if (put_par2) {
		sb.append("<tr>");
		sb.append("<td><b>Parameter 2:</b></td>");
		sb.append("</td>");
		sb.append("<tr>");
		sb.append("<td>");
		sb.append(makeNumber("", "scramble_part_type_par2", scramble_part_type_par2, "changeProfileField('scramble_part_type_par2',this.value)", "EDIT", "3", "0", ",", ".", "", "1", "999"));
		sb.append("</td>");
		sb.append("</tr>");
	}
	
	
	sb.append("<tr>");
	sb.append("<td><b>Using these characters :</b></td>");
	sb.append("</td>");
	sb.append("<tr>");
	sb.append("<td>");
	sb.append("<textarea name=random_char_list  rows=3 style=\"width:100%;\" onchange=\"changeProfileField('random_char_list',this.value);\">" + clearHtml(random_char_list) + "</textarea>");
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("</table>");

	
	return sb.toString();
}

//******************************************************************************
boolean isTableFilterValid(Connection conn, String env_id, String tab_id, String tab_filter, StringBuilder sbErr) {
	
	
	boolean is_sql_valid=false;
	
	String sql="select cat_name, schema_name, tab_name from tdm_tabs where id="+tab_id;
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> tabnameArr=getDbArrayConf(conn, sql, 1,  bindlist);

	String table_name_to_test="";
	
	String cat_name="";
	String owner="";
	String table="";
	
	try {
		
		
		cat_name=tabnameArr.get(0)[0];
		owner=tabnameArr.get(0)[1];
		table=tabnameArr.get(0)[2];
		
		table_name_to_test=addStartEnd(conn, env_id, owner+"."+table);
		
	} catch(Exception e) {
		table_name_to_test="NOT_FOUND";
	}
	
	boolean is_jbase=false;
	boolean is_mssql=false;
	boolean is_mysql=false;
	boolean is_mongo=false;
	
	String db_type=getEnvDBParam(conn, env_id, "DB_TYPE");
	
	if (db_type.equals("JBASE")) is_jbase=true;
	if (db_type.equals("MSSQL")) is_mssql=true;
	if (db_type.equals("MYSQL")) is_mysql=true;
	if (db_type.toUpperCase().contains("MONGO")) is_mongo=true;
	
	if (is_jbase)
		sql="select "+getJbaseFieldsWithComma(table_name_to_test)+" from \""+table_name_to_test+"\" t ";
	else if (is_mssql)
		sql="select top 1 * from "+table_name_to_test+" as t ";
	else if (is_mysql)
		sql="select  * from "+table_name_to_test+" t ";
	else 
		sql="select * from "+table_name_to_test+" t ";
    
	String replaced_table_filter=replaceTableFilter(tab_filter, "t");
	System.out.println("replaced_table_filter :"+replaced_table_filter);
	
	
	if (replaced_table_filter.trim().length()>0) sql= sql+ " where " + replaced_table_filter;	
	
	if (is_mysql) sql= sql+ " limit 0,1";	
	
	

    if (sql.contains("${") || sql.contains("?")) is_sql_valid=true;
    else {
    	if (is_mongo) {
			String mongo_query=tab_filter;
			is_sql_valid=validateMongoQuery(conn, env_id, owner, table, mongo_query);
		}
		else 
			is_sql_valid=validateSQLStatement(conn,env_id,cat_name, sql,sbErr); 
    }
    
    
    return is_sql_valid;
}
    
//************************************************************************************
String replaceTableFilter(String tab_filter, String alias) {
	StringBuilder sb=new StringBuilder(tab_filter);
	String findstr="${this}";
	while(true) {
		int pos=sb.toString().toLowerCase().indexOf(findstr);
		if (pos==-1) break;
		sb.delete(pos,pos+findstr.length());
		sb.insert(pos, alias);
	}
	
	return sb.toString();
}
//******************************************************************************
boolean isTableParallelFunctionValid(Connection conn, String env_id, String tab_id, String parallel_field, StringBuilder sbErr) {
	
	
	boolean is_sql_valid=false;
	
	String sql="select cat_name, schema_name, tab_name, parallel_function from tdm_tabs where id="+tab_id;
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> tabnameArr=getDbArrayConf(conn, sql, 1,  bindlist);

	String table_name_to_test="";
	String parallel_function="";
	
	String cat_name="";
	String owner="";
	String table="";
	
	try {
		
		cat_name=tabnameArr.get(0)[0];
		owner=tabnameArr.get(0)[1];
		table=tabnameArr.get(0)[2];
		
		table_name_to_test=addStartEnd(conn, env_id, owner+"."+table);
		
		parallel_function=tabnameArr.get(0)[3];
	} catch(Exception e) {
		table_name_to_test="xxNOT_FOUNDxx";
		parallel_function="xxx";
	}
	
	
	
	boolean is_jbase=false;
	boolean is_mssql=false;
	boolean is_mysql=false;
	boolean is_mongo=false;
	
	String db_type=getEnvDBParam(conn, env_id, "DB_TYPE");
	
	if (db_type.equals("JBASE")) is_jbase=true;
	if (db_type.equals("MSSQL")) is_mssql=true;
	if (db_type.equals("MYSQL")) is_mysql=true;
	if (db_type.toUpperCase().contains("MONGO")) is_mongo=true;
	
	if (is_jbase)
		sql="select "+getJbaseFieldsWithComma(table_name_to_test)+" from \""+table_name_to_test+"\"";
	else if (is_mssql)
		sql="select top 1 * from "+table_name_to_test;
	else if (is_mysql)
		sql="select  * from "+table_name_to_test;
	else 
		sql="select * from "+table_name_to_test;
    
	
 
	if (parallel_function.equals("MOD"))
		sql=sql + " where mod(" + parallel_field+",1)=0";	
	
	if (parallel_function.equals("%"))
		sql=sql + " where " + parallel_field+" % 1 =0";	
	
	if (is_mysql) sql=sql + " limit 0,1";


	
	 
	if (is_mongo) {
		String mongo_query=parallel_field.replace("?", "1");
		is_sql_valid=validateMongoQuery(conn, env_id, owner, table, mongo_query);
	}
	else
		is_sql_valid=validateSQLStatement(conn, env_id, cat_name, sql, sbErr); 
 	
    
  
  return is_sql_valid;
}

//******************************************************************************
boolean isOverrideParamExists(Connection conn, HttpSession session, String app_id, String policy_group_id) {
	String sql="select 1 from tdm_proxy_param_override where app_id=? and policy_group_id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"INTEGER",policy_group_id});

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr!=null && arr.size()==1) return true;
	
	return false;
}

//******************************************************************************
void addNewOverrideParameter(Connection conn, HttpSession session, String app_id, String policy_group_id) {
	String sql="insert into tdm_proxy_param_override (app_id,policy_group_id) values (?,?)";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"INTEGER",policy_group_id});
	
	execDBConf(conn, sql, bindlist);
}


//******************************************************************************
void removeOverridingParam(Connection conn, HttpSession session, String overriding_id) {
	String sql="delete from tdm_proxy_param_override where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",overriding_id});
	
	execDBConf(conn, sql, bindlist);
}

//******************************************************************************
void updateCalendarExceptionDate(Connection conn, HttpSession session, String calendar_exception_id, String field_name, String field_value) {
	String sql="update  tdm_proxy_calendar_exception set "+field_name+"=STR_TO_DATE(?, ?)  where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",field_value});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"INTEGER",calendar_exception_id});
	
	execDBConf(conn, sql, bindlist);
}

//************************************************************************************
String makeChangeDbPasswordForm(Connection conn, HttpSession session, String db_id) {
	StringBuilder sb=new StringBuilder();

	sb.append("<input type=hidden id=change_password_db_id value="+db_id+">");

	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append("Enter New Password");
	sb.append("</div>");
	sb.append("</div>");


	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append(makePassword("db_new_password", "", "", 0));
	sb.append("</div>");
	sb.append("</div>");
	

	
	return sb.toString();
}

//************************************************************************************
String makeSessionValidationRegexForm(Connection conn, HttpSession session, String session_validation_id, String test_regex_field_name) {
	StringBuilder sb=new StringBuilder();

	sb.append("<input type=hidden id=test_session_validation_id value="+session_validation_id+">");
	sb.append("<input type=hidden id=test_session_validation_regex_field_name value="+test_regex_field_name+">");

	String sql="select "+test_regex_field_name+" from tdm_proxy_session_validation where id="+session_validation_id;
	
	String regex_val=getDBSingleVal(conn, sql);
	

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=\"right\">");
	sb.append("<span class=\"label label-info\">Statement to test :</span>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-10\">");
	sb.append("<textarea id=test_regex_statement rows=4 style=\"width:100%;\"></textarea>");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=\"right\">");
	sb.append("<span class=\"label label-info\">Regular Expression to test :</span>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-10\">");
	sb.append(makeText("test_for_statement_check_regex", clearHtml(regex_val), "", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<hr>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=\"right\">");
	sb.append("</div>");
	sb.append("<div class=\"col-md-10\" align=\"left\">");
	sb.append("<button class=\"btn btn-sm btn-primary\" onclick=executeRegexTest()> Execute Test >>>>> </button>");
	sb.append("</div>");
	sb.append("</div>");
	

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=\"right\">");
	sb.append("</div>");
	sb.append("<div class=\"col-md-10\" align=\"right\">");
	sb.append(makeText("test_regex_result", "Click the button above to see the test result", "readonly", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");
	sb.append("</div>");

	
	return sb.toString();
}

//******************************************************************************
boolean changeDbPassword(Connection conn, HttpSession session, String change_password_db_id, String encoded_password) {
	
	String new_password="DEC:"+encoded_password;
	
	System.out.println(" update "+change_password_db_id+" with "+new_password);
	
	String sql="update tdm_envs set db_password=? where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",new_password});
	bindlist.add(new String[]{"INTEGER",change_password_db_id});
	
	return execDBConf(conn, sql, bindlist);
}

//******************************************************************************
void saveSessionValidationRegex(Connection conn, HttpSession session, String session_validation_id, String validation_regex_field_name, String test_for_statement_check_regex) {
	
	
	String sql="update tdm_proxy_session_validation set "+validation_regex_field_name+"=? where id=?";
	System.out.println(sql);
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",test_for_statement_check_regex});
	bindlist.add(new String[]{"INTEGER",session_validation_id});
	
	execDBConf(conn, sql, bindlist);
}


//******************************************************************************************
String getJSTestParamVal(Connection conn, HttpSession session, String param_name) {
	
	String param_val=nvl((String) session.getAttribute("val_of_param_"+param_name),"");

	return param_val;
	
}

//******************************************************************************************
void setJSTestParamVal(Connection conn, HttpSession session, String param_name, String param_val) {
	
	session.setAttribute("val_of_param_"+param_name, param_val);

	
}
//******************************************************************************************
String makeEditTestJSParamList(Connection conn, HttpSession session, String session_validation_id, String session_validation_field, String js_code) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String> paramList=new ArrayList<String>();
	
	try {
		int cursor=0;
		while(true) {
			
			int start_ind=js_code.indexOf("${", cursor);
			if (start_ind==-1) break;
			cursor=start_ind+2;
			
			int end_ind=js_code.indexOf("}", cursor);
			if (end_ind==-1) break;
			
			cursor=end_ind+1;
			
			String param_name=js_code.substring(start_ind+2,end_ind).trim();
			
			if (param_name.trim().length()==0) continue;
			
			if (paramList.indexOf(param_name)>-1) continue;
			
			paramList.add(param_name);
			
		}
	} catch(Exception e) {
		e.printStackTrace();
	}
	
	if (paramList.size()==0) {
		sb.append("No parameter detected");
		return sb.toString();
	}
	
	sb.append("<table class=\"table table-condensed\">");
	
	for (int i=0;i<paramList.size();i++) {
		String param_name=paramList.get(i);

		String curr_val=getJSTestParamVal(conn,session,param_name);
		String param_id="script_test_param_"+i;
		String param_text_name=param_name;
		
		
		sb.append("<tr>");
		sb.append("<td nowrap align=right><span class=badge>${"+limitString(clearHtml(param_name), 50) +"}</span></td>");
		sb.append("<td width=\"100%\">");
		sb.append(makeText(param_id, curr_val, "name=\""+param_text_name+"\" onchange=setJsTestParam(this,'"+param_name+"')", 0));
		sb.append("</td>");
		sb.append("</tr>");
	}
	
	sb.append("</table>");
	
	return sb.toString();
}
//************************************************************************************
String buildSessionValidationScript(Connection conn, HttpSession session, String session_validation_id, String script_field) {
	StringBuilder sb=new StringBuilder();

	

	String sql="";
	
	sql="select "+script_field+" from tdm_proxy_session_validation where id="+session_validation_id;
	String script_field_value=getDBSingleVal(conn, sql);
	
	
	sql="select  controll_method from tdm_proxy_session_validation where id="+session_validation_id;
	String controll_method=getDBSingleVal(conn, sql);
	if (script_field.startsWith("extraction_js_for")) controll_method="JAVASCRIPT";
	
	sql="select  controll_db_id from tdm_proxy_session_validation where id="+session_validation_id;
	String controll_db_id=getDBSingleVal(conn, sql);
	
	
	sb.append("<input type=hidden id=build_script_session_validation_id value="+session_validation_id+">");
	sb.append("<input type=hidden id=build_script_field value="+script_field+">");
	sb.append("<input type=hidden id=build_script_controll_method value="+controll_method+">");
	sb.append("<input type=hidden id=build_script_controll_db_id value="+controll_db_id+">");
	sb.append("<input type=hidden id=build_script_changed value=NO>");
	
	
	sb.append("<span class=\"badge\">"+script_field+"</span>");
	sb.append("<br>");
	
	
	ArrayList<String[]> sessionParArr=new ArrayList<String[]>();
	fillSessionVariableArray(sessionParArr);
	
	StringBuilder sbPars=new StringBuilder();
	
	for (int p=0;p<sessionParArr.size();p++) {
		if (p>0) sbPars.append(" ");
		String par_name=sessionParArr.get(p)[0];
		if (p % 2==0)
			sbPars.append("<a href=\"javascript:insertParameterIntoScript('"+par_name+"')\">"+par_name+"</a>");
		else 
			sbPars.append("<b><a href=\"javascript:insertParameterIntoScript('"+par_name+"')\">"+par_name+"</a></b>");
	}
	
	
	
	
	String session_validation_script_test_clause=nvl((String) session.getAttribute("test_clause_for_session_validation_id_"+session_validation_id),"");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=\"right\">");
	sb.append("<span class=\"label label-info\">Clause to test :</span>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-10\">");
	sb.append("<b><a href=\"javascript:insertParameterIntoScript('CLAUSE')\">Click to use in script ${CLAUSE}</a></b>");
	sb.append("<br>");
	sb.append("<textarea id=session_validation_script_test_clause rows=2 style=\"width:100%;\" onBlur=\"saveScriptTestClause()\">"+clearHtml(session_validation_script_test_clause)+"</textarea>");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=\"right\">");
	sb.append("<span class=\"label label-info\">Script to build :</span>");
	if (controll_method.equals("JAVASCRIPT")) {
		sb.append("<br><br><br>");
		sb.append("<b><a href=\"javascript:setInitialJavaScriptForSessionValidationScript()\">Paste JS code snippet >>>> </a></b>");
	}
	sb.append("</div>");
	sb.append("<div class=\"col-md-8\">");
	sb.append("<textarea id=building_script rows=10 style=\"width:100%; background-color:yellow;\" onkeypress=setScriptChanged() >"+clearHtml(script_field_value)+"</textarea>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-2\">");
	sb.append("<small><small>"+sbPars.toString()+"</small></small>");
	sb.append("</div>");
	sb.append("</div>");
	
	if (controll_method.equals("DATABASE")) {
		sql="select id, name from tdm_envs order by 2";
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-2\" align=\"right\">");
		sb.append("<span class=\"label label-info\">Database to execute :</span>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-10\">");
		sb.append(makeCombo(conn, sql, "", "disabled", controll_db_id, 0));
		sb.append("</div>");
		sb.append("</div>");
	}
	
	
	
	
	
	sb.append("<hr>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-5\" align=\"right\" id=scriptTestParametersDiv>");
	sb.append(makeEditTestJSParamList(conn, session, session_validation_id, script_field, script_field_value));
	sb.append("</div>");
	sb.append("<div class=\"col-md-1\" align=\"center\">");
	sb.append("<button class=\"btn btn-sm btn-primary\" onclick=executeScriptTest()> Validate >>>>> </button>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-6\" align=\"left\" id=scriptTestResultsDiv>");
	sb.append("<textarea disabled id=session_validation_script_results rows=3 style=\"width:100%;\">Click the validate button to see the result</textarea>");
	sb.append("</div>");
	sb.append("</div>");
	

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-2\" align=\"left\">");
	sb.append("</div>");
	sb.append("<div class=\"col-md-10\" align=\"right\" id=scriptTestResultsDiv>");
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");
	sb.append("</div>");

	
	return sb.toString();
}


//******************************************************************
public String replaceAllParams(String str, ArrayList<String[]> params) {
	StringBuilder ret1=new StringBuilder(str);

	if (params==null) return str;
	
	for (int i=0;i<params.size();i++) {
		String param_name="${"+params.get(i)[0]+"}";
		String param_val=params.get(i)[1];
		
		while (true) {
			int loc=ret1.toString().toUpperCase().indexOf(param_name.toUpperCase());
			if (loc==-1) break;
			
			int len=param_name.length();
			
			ret1.delete(loc, loc+len);
			ret1.insert(loc, param_val);
		}
	}
	
	
	return ret1.toString();
}


//******************************************************************************
void decompileParameters(ArrayList<String[]> parametersArr,String script_parameters, String clause_to_test) {
	String[] parts=script_parameters.split("\\|::\\|");
	for (int p=0;p<parts.length;p++) {
		int pos=parts[p].indexOf("=");
		if (pos==-1) continue;
		
		String par_name=parts[p].substring(0, pos);
		String par_value="";
		try {par_value=parts[p].substring(pos+1);} catch(Exception e) {}
		
		if (par_name.equals("CLAUSE")) par_value=clause_to_test;
		
		parametersArr.add(new String[]{par_name,par_value});
	}
}

//******************************************************************************
boolean executeScriptTest(
		Connection conn, 
		HttpSession session, 
		String session_validation_id, 
		String build_script_field, 
		String script_to_execute, 
		String clause_to_test,
		String script_parameters,
		StringBuilder sbResults,
		StringBuilder sbLogs
		) {
	
	
	String sql="select controll_method, controll_db_id, expected_result from tdm_proxy_session_validation where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",session_validation_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==0) {
		sbResults.append("<ERR>tdm_proxy_session_validation not found  :"+session_validation_id);
		return false;
	}
	
	String controll_method=arr.get(0)[0];
	String controll_db_id=arr.get(0)[1];
	String expected_result=arr.get(0)[2];
	
	if (build_script_field.startsWith("extraction_js_for")) controll_method="JAVASCRIPT";
	
	ArrayList<String[]> parametersArr=new ArrayList<String[]>();

	decompileParameters(parametersArr,script_parameters, clause_to_test.replaceAll("\n|\r", " "));
	
	
	
	
	//replace parameters.
	
	
	
	if (controll_method.equals("DATABASE")) {

		
		String final_script=decodeControllStatementAndBindings(parametersArr, script_to_execute,bindlist);
		sbLogs.append("\n final_script :"+final_script);
		for (int b=0;b<bindlist.size();b++) sbLogs.append("\n binding : "+bindlist.get(b)[0]+"="+bindlist.get(b)[1]);
		
		ArrayList<String[]> arrRes=getDbArrayApp(conn, controll_db_id, final_script, 100, bindlist);
		
		
		if (arrRes.size()==0) {
			
			if (last_db_sql_error.length()==0)
				sbResults.append("<NO_RECORD_FOUND>");
			else 
				sbResults.append("<ERR> "+last_db_sql_error);
				
			return false;
		}
		
		sbLogs.append("\nSuccessfuly executed");

		
		for (int r=0;r<arrRes.size();r++) {
			String[] row=arrRes.get(r);
			if (r>0) sbResults.append("\n");
			for (int c=0;c<row.length;c++) {
				if (c>0) sbResults.append("\t");
				sbResults.append(row[c]);
			}
				
		}
		
		return true;
		
	} else {
		ScriptEngineManager factory=null;
		ScriptEngine engine=null;
		try {
			factory = new ScriptEngineManager();
			
			StringBuilder sbStmt=new StringBuilder(replaceAllParams(script_to_execute, parametersArr));
			sbLogs.append("Executing JS: "+sbStmt.toString());
			
			engine = factory.getEngineByName("JavaScript");
			String ret1=""+ engine.eval(sbStmt.toString());
			sbLogs.append("\n------------ \n Javascript Eval Returns : " + ret1+"\n");
			
			if (ret1.length()>0 && !ret1.equals("null"))
				sbResults.append(ret1);
			else 
				sbResults.append("<NULL>");
			
		} catch(Exception e) {
			sbResults.append(e.getMessage());
			sbLogs.append("Exception@Execution javascript : " +e.getMessage()+"\n");
			return false;
		}
	}
	
	
	return true;
}

//*********************************************************************
String decodeControllStatementAndBindings(ArrayList<String[]> sourceParams, String controll_statement,ArrayList<String[]> bindlist) {
	
	 
	 ArrayList<String> pars=new ArrayList<String>();
	 ArrayList<Integer> positions=new ArrayList<Integer>();
	 ArrayList<Integer> parIndexes=new ArrayList<Integer>();
	 
	 for (int p=0;p<sourceParams.size();p++) {
		 String par_name="${"+sourceParams.get(p)[0]+"}";
		 int startIndex=0;
		 while(true) {
			 int pos=controll_statement.indexOf(par_name, startIndex);
			 if (pos==-1) break;
		 
			 pars.add(par_name);
			 positions.add(pos);
			 parIndexes.add(p);
			 
			 startIndex=pos+par_name.length();
			 
			 
		 }
		
	 }
	 
	 //order by position
	 for (int i=0;i<positions.size();i++) {
		 for (int j=i+1;j<positions.size();j++) {
			 if (positions.get(i)>positions.get(j)) {
				 int pos=positions.get(i);
				 positions.set(i, positions.get(j));
				 positions.set(j, pos);
				 
				 int index=parIndexes.get(i);
				 parIndexes.set(i, parIndexes.get(j));
				 parIndexes.set(j, index);
				 
				 String par_name=pars.get(i);
				 pars.set(i, pars.get(j));
				 pars.set(j, par_name);
			 }
		 }
	 }
	 
	 bindlist.clear();
	 StringBuilder sbRet=new StringBuilder(controll_statement);
	 
	 for (int p=pars.size()-1;p>=0;p--) {
		 String par_name=pars.get(p);
		 int pos=positions.get(p);
		 int index=parIndexes.get(p);
		 
		 sbRet.delete(pos, pos+par_name.length());
		 sbRet.insert(pos,"?");
		 bindlist.add(0,new String[]{"STRING",sourceParams.get(index)[1]});
		 
	 }
	 
	 
	 
	 return sbRet.toString();
 }

//*********************************************************************
void updateMonitoringPolicyGroup(Connection conn, HttpSession session, String monitoring_id, String policy_group_id, String method) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	if (method.equals("ADD")) {
		sql="insert into tdm_proxy_monitoring_policy_group (monitoring_id,policy_group_id) values (?,?)";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",monitoring_id});
		bindlist.add(new String[]{"INTEGER",policy_group_id});
		execDBConf(conn, sql, bindlist);
	} else {
		sql="delete from tdm_proxy_monitoring_policy_group where monitoring_id=? and  policy_group_id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",monitoring_id});
		bindlist.add(new String[]{"INTEGER",policy_group_id});
		execDBConf(conn, sql, bindlist);
	}
	
	
}
//*********************************************************************
void updateMonitoringApplication(Connection conn, HttpSession session, String monitoring_id, String app_id, String method) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	if (method.equals("ADD")) {
		sql="insert into tdm_proxy_monitoring_application (monitoring_id,app_id) values (?,?)";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",monitoring_id});
		bindlist.add(new String[]{"INTEGER",app_id});
		execDBConf(conn, sql, bindlist);
	} else {
		sql="delete from tdm_proxy_monitoring_application where monitoring_id=? and  app_id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",monitoring_id});
		bindlist.add(new String[]{"INTEGER",app_id});
		execDBConf(conn, sql, bindlist);
	}
	
	
}
//*********************************************************************
void addNewMonitoringRule(Connection conn, HttpSession session, String monitoring_id, String rule_type) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	sql="insert into tdm_proxy_monitoring_policy_rules (monitoring_id,rule_type) values (?,?)";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",monitoring_id});
	bindlist.add(new String[]{"STRING",rule_type});
	execDBConf(conn, sql, bindlist);
	
	
}

//*********************************************************************
void removeMonitoringRule(Connection conn, HttpSession session, String monitoring_rule_id) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	sql="delete from tdm_proxy_monitoring_policy_rules where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",monitoring_rule_id});
	execDBConf(conn, sql, bindlist);
	
	
}
//*************************************************************************************************************
public String getSessionKey(String session_key, ArrayList<String[]> sessionArr) {
	String ret1="";
	
	for (int i=0;i<sessionArr.size();i++) {
		String arr_session_key=sessionArr.get(i)[0];
		String arr_session_val=sessionArr.get(i)[1];
		if (session_key.equals(arr_session_key)) return arr_session_val;
	}
	
	return ret1;
}
//*************************************************************************************************************
void blacklistSessions(
		Connection conn, 
		HttpSession session, 
		String blacklist_proxy_id, 
		String blacklist_selected_session_ids) {
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String[] ids=blacklist_selected_session_ids.split(",");
	for (int i=0;i<ids.length;i++) {
		String session_id=ids[i];
		if (session_id.length()==0) continue;
		
		sql="select session_info from tdm_proxy_session where proxy_id=? and id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",blacklist_proxy_id});
		bindlist.add(new String[]{"INTEGER",session_id});
		
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		if (arr==null || arr.size()==0) {
			System.out.println("Session not found");
			continue;
		}
		
		String session_info=arr.get(0)[0];
		
		ArrayList<String[]> params=getSessionVariablesAsArrayList(session_info);
		
		String machine=nvl(getSessionKey("MACHINE",params),getSessionKey("TERMINAL",params));
		String osuser=getSessionKey("OSUSER",params);
		String dbuser=getSessionKey("CURRENT_USER",params);
		
		sql="select 1 from tdm_proxy_monitoring_blacklist where proxy_id=? and machine=? and osuser=? and dbuser=? and is_deactivated='NO'";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",blacklist_proxy_id});
		bindlist.add(new String[]{"STRING",machine});
		bindlist.add(new String[]{"STRING",osuser});
		bindlist.add(new String[]{"STRING",dbuser});
		
		ArrayList<String[]> arrDup=getDbArrayConf(conn, sql, 1, bindlist);
		
		if (arrDup!=null && arrDup.size()==1){
			System.out.println("Session was already in blaclist");
			continue;
		}
		
		sql="insert into  tdm_proxy_monitoring_blacklist (proxy_id, proxy_session_id, blacklist_time, machine, osuser, dbuser) values (?,?,now(),?,?,?)";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",blacklist_proxy_id});
		bindlist.add(new String[]{"INTEGER",session_id});
		bindlist.add(new String[]{"STRING",machine});
		bindlist.add(new String[]{"STRING",osuser});
		bindlist.add(new String[]{"STRING",dbuser});
		
		boolean is_ok=execDBConf(conn, sql, bindlist);
		
		System.out.println("is_ok="+is_ok);
		
	}
	
	
	
}



//******************************************************************************
String makeManageBlacklistDialog(Connection conn, HttpSession session, String proxy_id) {
	StringBuilder sb=new StringBuilder();
	

	sb.append("<input type=hidden id=searchBlackListProxyId value="+proxy_id+">");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\" >");
	
	sb.append("<tr>");
	sb.append("<td align=right nowrap>");
	sb.append("<b>Enter Filter To Search :</b>");
	sb.append("</td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeText("searchTextForBlacklist", "", " onchange=listBlackist()", 0, "EDITABLE"));
	sb.append("</td>");
	sb.append("<td nowrap >");
	sb.append("<input type=checkbox id=searchCheckBoxForBlackList checked onclick=listBlackist()> Show Only non-Inactivated");
	sb.append("</td>");
	sb.append("<td>");
	sb.append("<button class=\"btn btn-md btn-default\" style=\"width:100%;\" onclick=listBlackist()><span class=\"glyphicon glyphicon-search\"></span></button>");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("</table>");

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=listOfBlackListDiv   style=\"min-height: 340px; max-height: 340px; overflow-x: scroll; overflow-y: scroll;\">");
	sb.append(listBlacklist(conn,session,proxy_id,"","YES"));
	sb.append("</div>");
	sb.append("</div>");
	
	return sb.toString();
}


//******************************************************************************
String listBlacklist(Connection conn, HttpSession session, String proxy_id, String search_str, String only_active) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select proxy_session_id, id, machine, osuser, dbuser, date_format(blacklist_time,?) blacklist_time, "+
				" is_deactivated, date_format(deactivation_time,?) deactivation_time, "+
				" (select username from tdm_user where id=deactivated_by_user_id) deactivated_by_user, deactivation_note"+
				" from tdm_proxy_monitoring_blacklist "+
				" where proxy_id=?  ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"INTEGER",proxy_id});
	
	String additional_filter="";
	
	String[] searchArr=search_str.split(" ");
	for (int s=0;s<searchArr.length;s++) {
		String a_search_str=searchArr[s];
		if (a_search_str.length()==0) continue;
		if (additional_filter.length()>0) additional_filter=additional_filter+" or ";
		additional_filter=additional_filter+" upper(machine)=upper(?)  or upper(osuser)=upper(?)  or upper(dbuser)=upper(?) ";
		bindlist.add(new String[]{"STRING",a_search_str});
		bindlist.add(new String[]{"STRING",a_search_str});
		bindlist.add(new String[]{"STRING",a_search_str});
	}
	
	if (additional_filter.length()>0)  sql=sql+" and ("+additional_filter+") ";
	
	if (only_active.equals("YES")) sql=sql+" and is_deactivated='NO' ";
	
	sql=sql+" order by id";
	
	

	ArrayList<String[]> blacklistArr=getDbArrayConf(conn, sql, 1000, bindlist);
	
	if (blacklistArr.size()==0) {
		sb.append("No session in blaclist");
		return sb.toString();
	}


	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\" >");
	
	
	sb.append("<tr class=info>");
	sb.append("<td><b>SessionId</b></td>");
	sb.append("<td><b>Machine</b></td>");
	sb.append("<td><b>OS User</b></td>");
	sb.append("<td><b>DB User</b></td>");
	sb.append("<td><b>Redlist Time</b></td>");
	sb.append("<td><b>Redlists Deactivated?</b></td>");
	sb.append("<td><b>Deact. Time</b></td>");
	sb.append("<td><b>Deact. By</b></td>");
	sb.append("<td><b>Note</b></td>");
	sb.append("</tr>");
	
	for (int i=0;i<blacklistArr.size();i++) {
		
	
		String proxy_session_id=blacklistArr.get(i)[0];
		String blacklist_id=blacklistArr.get(i)[1];
		String machine=blacklistArr.get(i)[2];
		String osuser=blacklistArr.get(i)[3];
		String dbuser=blacklistArr.get(i)[4];
		String blacklist_time=blacklistArr.get(i)[5];
		String is_deactivated=blacklistArr.get(i)[6];
		String deactivation_time=blacklistArr.get(i)[7];
		String deactivated_by_user=blacklistArr.get(i)[8];
		String deactivation_note=blacklistArr.get(i)[9];
		
		
		
		sb.append("<tr>");
		sb.append("<td><a href=\"javascript:listBlacklistedSessionCommands('"+proxy_id+"','"+proxy_session_id+"','"+blacklist_id+"')\">"+proxy_session_id+"</a></td>");
		sb.append("<td>"+machine+"</td>");
		sb.append("<td>"+osuser+"</td>");
		sb.append("<td>"+dbuser+"</td>");
		sb.append("<td>"+blacklist_time+"</td>");
		sb.append("<td>"+is_deactivated+"</td>");
		
		if (is_deactivated.equals("YES")) {
			sb.append("<td>"+deactivation_time+"</td>");
			sb.append("<td>"+deactivated_by_user+"</td>");
			sb.append("<td>"+clearHtml(deactivation_note)+"</td>");
		} else {
			sb.append("<td colspan=3>");
			sb.append("<button class=\"btn btn-md btn-success\" style=\"width:100%;\" onclick=removeFromBlackList('"+blacklist_id+"')><span class=\"glyphicon glyphicon-remove\"></span> Remove from blacklist</button>");
			sb.append("</td>");
		}
		
		sb.append("</tr>");
	}
	
	sb.append("</table>");
	
	return sb.toString();
}




//********************************************************************
String makeGDPRReferencesPage(Connection conn, HttpSession session) {
	StringBuilder sb=new StringBuilder();
	
	String current_gdpr_reference_menu=nvl((String) session.getAttribute("current_gdpr_reference_menu"),"");
	
	sb.append("<div class=row>");
	
	sb.append("<div class=\"col-md-2\" id=gdprReferencesSideMenuDiv>");
	sb.append(makeGDPRReferencesMenuItems(conn,session,current_gdpr_reference_menu));
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-10\" id=gdprReferencesMainDiv>");
	sb.append("</div>");
	
	sb.append("</div>");
	
	
	return sb.toString();
}


//********************************************************************
String makeGDPRReferencesMenuItems(Connection conn, HttpSession session, String current_menu) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> menuItems=new ArrayList<String[]>();
	menuItems.add(new String[]{"gdpr_ref_data_class","Class"});
	menuItems.add(new String[]{"gdpr_ref_data_pattern","Pattern"});
	menuItems.add(new String[]{"gdpr_ref_party_type","Party Type"});
	menuItems.add(new String[]{"gdpr_ref_medium_type","Medium Type"});
	menuItems.add(new String[]{"gdpr_ref_medium","Medium"});
	menuItems.add(new String[]{"gdpr_ref_discovery_driver","Discovery Driver"});
	menuItems.add(new String[]{"gdpr_ref_data_interaction","Interactions"});

	session.setAttribute("current_gdpr_menu",current_menu);
	
	String current_menu_final=nvl(current_menu,nvl( (String) session.getAttribute("current_gdpr_reference_menu"),"gdpr_ref_data_class" ));
	
	
	sb.append("<table class=\"table table-condensed\">");
	
	for (int m=0;m<menuItems.size();m++) {
		String menu_item=menuItems.get(m)[0];
		String menu_title=menuItems.get(m)[1];
		
		boolean is_active=false;
		if (current_menu_final.equals(menu_item)) is_active=true;
		
		if (is_active)   sb.append("<tr class=info>");
		else  sb.append("<td>");

		sb.append("[<b><a href=\"javascript:openGDPRReferenceMenu('"+menu_item+"')\">"+menu_title+"</a></b>]");

		sb.append("</td>");
		sb.append("</tr>");
	}
	
	sb.append("</table>");
	
	return sb.toString();
}
 %>
 
 
 