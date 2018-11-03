<%@page import="java.net.InetAddress"%>
<%@page import="org.omg.CORBA.INVALID_ACTIVITY"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.File"%>
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
<%@ page import="javax.mail.Message" %>
<%@ page import="javax.mail.MessagingException" %>
<%@ page import="javax.mail.PasswordAuthentication" %>
<%@ page import="javax.mail.Session" %>
<%@ page import="javax.mail.Transport" %>
<%@ page import="javax.mail.internet.AddressException" %>
<%@ page import="javax.mail.internet.InternetAddress" %>
<%@ page import="javax.mail.internet.MimeMessage" %>
<%@ page import="com.sun.mail.util.BASE64DecoderStream" %>
<%@ page import="com.sun.mail.util.BASE64EncoderStream" %>
<%@ page import="javax.crypto.Cipher" %>
<%@ page import="javax.crypto.KeyGenerator" %>
<%@ page import="javax.crypto.SecretKey" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="org.apache.commons.codec.binary.Base64" %>



<%
 

request.setCharacterEncoding("utf-8");


String bt_login="";
String username="";
String password="";
String logout="";

bt_login=nvl(request.getParameter("btlogin"),"");
username=nvl(request.getParameter("username"),"");
password=nvl(request.getParameter("password"),"");
logout=nvl(request.getParameter("logout"),"");

//System.out.println(bt_login);
//System.out.println(username);






//session.setAttribute("invalid_user_attempt", "false");



if (!bt_login.isEmpty() && !username.isEmpty()) {
	int user_id=0;
	Connection connconf=getconn();

	if (connconf!=null) 
		user_id=checkuser(connconf,username,password);
	
	if (user_id==0) session.setAttribute("invalid_user_attempt", "true");
	
	if (user_id>0) {

		String sql="select fname, lname, email from tdm_user where valid='Y' and id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		ArrayList<String[]> res=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",""+user_id});
		
		String fname="";
		String lname="";
		String email="";

		res=getDbArrayConf(connconf, sql, 1, bindlist);
	
		fname=res.get(0)[0];
		lname=res.get(0)[1];
		email=res.get(0)[1];

		session.setAttribute("username", username);	
		session.setAttribute("userid", user_id);	
		session.setAttribute("userfname", fname);	
		session.setAttribute("userlname", lname);	
		session.setAttribute("useremail", email);	
		
		sql="select shortcode from tdm_user_role ur, tdm_role r where ur.role_id=r.id and user_id=" + user_id;
		
		bindlist=new ArrayList<String[]>();
		res=getDbArrayConf(connconf, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<res.size();i++) {
			session.setAttribute("hasrole_"+res.get(i)[0], "true");
		}
			
		
	}
	
	response.sendRedirect("admin.jsp");

	try {
		connconf.close();
		connconf=null;
	} catch(Exception e) {}

}

if (logout.equals("YES")) 	{
	session.setAttribute("username", "");	
	session.setAttribute("userid", 0);	
	session.setAttribute("userfname","");	
	session.setAttribute("userlname", "");	
	session.setAttribute("useremail", "");	

	session.setAttribute("hasrole_ADMIN", "");
	session.setAttribute("hasrole_DESIGN", "");
	session.setAttribute("hasrole_RUN", "");
	
	
	response.sendRedirect("default.jsp");
}


String currurl="";

currurl=nvl(request.getRequestURL().toString(),"");

String curruser="";

curruser=nvl((String) session.getAttribute("username"),"");

if (!currurl.contains("default.jsp") && curruser.isEmpty()) {
	session.setAttribute("username", "");	
		
	response.sendRedirect("default.jsp");	
}


 
%>


<%! 


final String DEFAULT_DATE_FORMAT="dd/MM/yyyy HH:mm:ss";



//***********************************
public String printHeader(HttpServletRequest request, HttpSession session) {
//***********************************
	String ret1="<body background=\"img/bodyback.jpg\">";

	ret1=ret1+"<link rel=\"stylesheet\" href=\"style/bootstrap/css/bootstrap.css\" />\n"+
				" <link rel=\"stylesheet\" href=\"style/maya-data-mask.css\" />\n\n";


				
    ret1= ret1 + "<div class=\"container\">\n" +
    		"<table class=table border=0>\n"+
            "<tr bgcolor=#FDFDFD>";
           
            if (checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 
            	ret1=ret1 +"<td><a href=\"list.jsp\"><img src=\"img/menu_list.png\" border=0 width=20 height=20> Lists</a></td>";
            	
            if (checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 
	         	ret1=ret1+"<td><a href=\"profile.jsp\"><img src=\"img/menu_prof.png\" border=0 width=20 height=20> Mask Profiles</a></td>";

            if (checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 
	         	ret1=ret1+"<td><a href=\"discovery.jsp\"><img src=\"img/menu_disc.png\" border=0 width=20 height=20> Discovery</a></td>";

		    if (checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 
           		ret1=ret1+"<td><a href=\"designer.jsp\"><img src=\"img/menu_desi.png\" border=0 width=20 height=20> Design</a></td>";
            	
            if (checkrole(session, "RUN") || checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 
            	ret1=ret1 + "<td><a href=\"run.jsp\"><img src=\"img/menu_exec.png\" border=0 width=20 height=20> Execution</a></td>";

            if (checkrole(session, "RUN") || checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 
				ret1=ret1+"<td><a href=\"monitoring.jsp\"><img src=\"img/menu_moni.png\" border=0 width=20 height=20> Monitoring</a></td>";
				
            if (checkrole(session, "DESIGN") || checkrole(session, "ADMIN")) 
            	ret1=ret1+"<td><a href=\"process.jsp\"><img src=\"img/menu_proc.png\" border=0 width=20 height=20> Processes</a></td>";
	         
            if (checkrole(session, "ADMIN")) 
            	ret1=ret1 +"<td><a href=\"admin.jsp\"><img src=\"img/menu_admi.png\" border=0 width=20 height=20> Administration</a></td>";
           
            
            ret1=ret1+
	            "<td>";
            
            
            String curruser="";
            
			try{curruser=(String) session.getAttribute("username");} catch(Exception e) {curruser="";}
	        
			
			int len=0;
			try {len=curruser.length();} catch(Exception e) {len=0;}
            if (len==0) {
	            ret1=ret1+
	            "<form class=\"form-inline\" role=\"form\" name=\"flogin\">\n" +
	            "  <td>\n" +
	            "    <font color=blue>Username</font>\n" +
	            "    <input class=\"form-control\" id=\"txtUsername\" placeholder=\"Username\" name=\"username\">\n" +
	            "  </td>\n" +
	            "  <td>\n" +
	            "    <font color=blue>Password</font>\n" +
	            "    <input type=\"password\" class=\"form-control\" id=\"password\" placeholder=\"Password\" name=\"password\">\n" +
	            "  </td>\n"+
	            "  <td>\n" +
	            "  <input type=\"submit\" name=btlogin class=\"btn-primary btn-sm\" value=\"Login\" />\n";
	           if (nvl(((String) session.getAttribute("invalid_user_attempt")),"-").equals("true")) 
	           	ret1=ret1+"<br><center><font color=red size=2>Invalid username or password!!!</font></center>";
	            		
	           ret1=ret1+ 
	        		   "</form>" +
	        		   "</td>";
            }
            else {
            	ret1=ret1+
            			"<td>"+
            			"<font color=blue>" +
            				"["+curruser+"]" + " <a href=\"default.jsp?logout=YES\"><img src=\"logout.png\" border=0 width=30 height=30></a>"+
            			"</font>" +
            			"</td>";
            }
            
            		
            ret1=ret1+		
            "</tr>" +
            "</table>";


	
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





//*************************************************************
private Connection getconn(Connection connconf, String env_id) {
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",env_id});
	
	String sql="select db_driver, db_connstr, db_username, db_password from tdm_envs where id=?";
	ArrayList<String[]> recs=getDbArrayConf(connconf, sql, 1, bindlist);
	
	String db_driver="";
	String db_connstr="";
	String db_username="";
	String db_password="";
	
	try{
	db_driver=recs.get(0)[0];
	db_connstr=recs.get(0)[1];
	db_username=recs.get(0)[2];
	db_password=recs.get(0)[3]; 
	
	
	} catch(Exception e) {
		e.printStackTrace();
		return null;
	}
	
		Connection ret1 = null;
		
		String test_sql="";
		if (db_connstr.contains("jdbc:db2")) test_sql="select 'A' x from SYSIBM.SYSDUMMY1";
		if (db_connstr.contains("jdbc:oracle")) test_sql="select 'A' x from DUAL";
		if (db_connstr.contains("jdbc:mysql")) test_sql="select 'A' x from DUAL";
		if (db_connstr.contains("jdbc:jtds:sqlserver")) test_sql="select 1";
		if (db_connstr.contains("jdbc:cassandra")) test_sql="SELECT host_id FROM system.local";
		
		if (test_sql.length()==0) test_sql="select 1";
		

			try {
				Class.forName(db_driver);
				Connection conn = DriverManager.getConnection(db_connstr, db_username, db_password);
				
				Statement stmt = conn.createStatement();
				ResultSet rset = stmt.executeQuery(test_sql);
				while (rset.next()) {rset.getString(1);	}
	
				ret1=conn; 
				
			} catch (Exception ignore) {
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
	String sql="select id, status from tdm_work_package where work_plan_id="+work_plan_id;
	if(!nvl(a_filter,"-").equals("-") && !nvl(a_filter,"-").equals("ALL")) sql=sql +" and tab_id=" + a_filter;
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	return getDbArrayConf(connconf, sql, Integer.MAX_VALUE, bindlist);
}

//*************************************************************
public ArrayList<String> getTabList(Connection connconf,String env_id, String owner) {
	
	ArrayList<String> ret1=new ArrayList<String>();
	
	Connection conn=getconn(connconf, env_id);
	ResultSet rs = null;
	DatabaseMetaData md=null;
	
	String tname="";
	String[] type_filter=new String[] {"TABLE"};
	int cnt=0;
	
	if (conn!=null) {
		try {

			md = conn.getMetaData();
			rs = md.getTables(null, owner, "%", type_filter);
			while (rs.next()) {
				cnt++;
				if (cnt>20000) break;
				tname=nvl(rs.getString("TABLE_SCHEM"),rs.getString("TABLE_CAT"))+"*"+rs.getString(3);
				ret1.add(tname);
				}
			rs.close();
		
			
			if(ret1.size()==0) {
				rs = md.getTables(owner, null, "%", type_filter);
				while (rs.next()) {
					cnt++;
					if (cnt>20000) break;
					tname=nvl(rs.getString("TABLE_SCHEM"),rs.getString("TABLE_CAT"))+"*"+rs.getString(3);
					ret1.add(tname);
					}
				rs.close();
			}
			
			
		
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {md = null;} catch (Exception e) {}
			try {rs.close();rs = null;} catch (Exception e) {}
			try {conn.close();conn= null;} catch (Exception e) {}

		}
	
	}
	
	return ret1;
	
	
}

//*************************************************************
public String getSqlDataTypeName(String val) {
//*************************************************************
String ret1="NOT/FOUND";
int i=0;
try{
i=Integer.parseInt(val);
} catch(Exception e) {
	i=0;
	e.printStackTrace();
}

switch(i) {
	case -6 : ret1="TINYINT"; break;
	case 5 : ret1="SMALLINT"; break;
	case 4 : ret1="INTEGER"; break;
	case -5 : ret1="BIGINT"; break;
	case 6 : ret1="FLOAT"; break;
	case 7 : ret1="REAL"; break;
	case 8 : ret1="DOUBLE"; break;
	case 2 : ret1="NUMERIC"; break;
	case 3 : ret1="DECIMAL"; break;
	case 1 : ret1="CHAR"; break;
	case 12 : ret1="VARCHAR"; break;
	case -1 : ret1="LONGVARCHAR"; break;
	case 91 : ret1="DATE"; break;
	case 92 : ret1="TIME"; break;
	case 93 : ret1="TIMESTAMP"; break;
	case -2 : ret1="BINARY"; break;
	case -3 : ret1="VARBINARY"; break;
	case -4 : ret1="LONGVARBINARY"; break;
	case 0 : ret1="NULL"; break;
	case 1111 : ret1="OTHER"; break;
	case 2000 : ret1="JAVA_OBJECT"; break;
	case 2001 : ret1="DISTINCT"; break;
	case 2002 : ret1="STRUCT"; break;
	case 2003 : ret1="ARRAY"; break;
	case 2004 : ret1="BLOB"; break;
	case 2005 : ret1="CLOB"; break;
	case 2006 : ret1="REF"; break;
	case -8 : ret1="ROWID"; break;
	case -15 : ret1="NCHAR"; break;
	case -9 : ret1="NVARCHAR"; break;
	case -16 : ret1="LONGNVARCHAR"; break;
	case 2011 : ret1="NCLOB"; break;
	case 2009 : ret1="SQLXML"; break;
	default:ret1="NOT/FOUND"; break;

}

return ret1;

}

//*************************************************************
public ArrayList<String[]> getFieldList(Connection connconf, String env_id, String owner, String table) {
//*************************************************************

	long s=System.currentTimeMillis();
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	Connection conn=getconn(connconf, env_id);
	DatabaseMetaData md=null;
	
	String f_name="";
	String f_type="";
	String f_size="";
	String f_is_pk="";
	
	String env_db_rowid=getEnvDBParam(connconf, env_id, "ROWID");
	ArrayList<String> pklist=new ArrayList<String>();

	//if db have row id add it as a first column
	if (env_db_rowid.length()>0) {
		String[] arr=new String[]{env_db_rowid, "ROWID", "0","YES"};
		ret1.add(arr);
	} 
	
		
	try {
	DatabaseMetaData meta = conn.getMetaData();
	
	
	ResultSet rspk = meta.getPrimaryKeys(owner, null, table);
	while (rspk.next()) {
	      String columnName = rspk.getString(4); //"COLUMN_NAME"
	      pklist.add(columnName);
	    }
	rspk.close();

	if (pklist.size()==0) {
		rspk = meta.getPrimaryKeys(null, owner, table);
		while (rspk.next()) {
		      String columnName = rspk.getString(4); //"COLUMN_NAME"
		      pklist.add(columnName);
		    }
		rspk.close();
	}
	
	} catch(Exception e) {
		
	}
	
	

	String[] type_filter=new String[] {"TABLE"};
	
	if (conn!=null) {

		ResultSet rs = null;

		try {

			md = conn.getMetaData();
			rs = md.getColumns(conn.getCatalog(), owner, table, null);
			
			while (rs.next()) {
				f_name=rs.getString("COLUMN_NAME"); //4
				f_type=getSqlDataTypeName(rs.getString("DATA_TYPE")); //+"."+rs.getString("TYPE_NAME");			
				f_size=rs.getString("COLUMN_SIZE");
				f_is_pk="NO";
				
				for (int p=0;p<pklist.size();p++)
					if (f_name.equals(pklist.get(p))) f_is_pk="YES";
				
				String[] arr=new String[]{f_name, f_type, f_size, f_is_pk};
				ret1.add(arr);
				}
		
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {md = null;} catch (Exception e) {}
			try {rs.close();rs = null;} catch (Exception e) {}
			try {conn.close();conn= null;} catch (Exception e) {}

		}
	
	}
	
	
	return ret1;

}


//*************************************************************
public String getEnvDBParam(Connection conn, String env_id, String param_name) {
//*************************************************************
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
		System.out.println("Error on loading db info");
		e.printStackTrace();
	}

	return ret1;

}

//*************************************************************
public int addNewTable(Connection conn, String env_id, String app_id,String tableActionObject) {
//*************************************************************
	String owner="";
	String table="";
	int ret1=0;
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();

	String env_db_type=nvl(getEnvDBParam(conn, env_id, "DB_TYPE"),"ORACLE");

	try {
		owner=tableActionObject.split("\\*")[0];
		table=tableActionObject.split("\\*")[1];
	} catch (Exception e) {
		return 0;
	}
	
	String sql="insert into tdm_tabs(app_id, db_type, schema_name, tab_name, mask_level, parallel_field, parallel_mod) values (?,?,?,?,'FIELD','1',1)";
	
	bindlist.add(new String[]{"INTEGER",app_id});
	bindlist.add(new String[]{"STRING",env_db_type});
	bindlist.add(new String[]{"STRING",owner});
	bindlist.add(new String[]{"STRING",table});
	
	execDBConf(conn, sql, bindlist);
	
	bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",app_id});
	sql="select max(id) x from tdm_tabs where app_id=?";
	
	String tab_id="";
	
	try {
		tab_id=getDbArrayConf(conn, sql, 1, bindlist).get(0)[0];				
	} catch(Exception e) {
		e.printStackTrace();
		return 0;
	}
	
	sql="insert into tdm_fields (tab_id,field_name, field_type, field_size, is_pk, mask_prof_id) values(?,?,?,?,?,0)";
	ArrayList<String[]> fields=getFieldList(conn, env_id, owner, table);
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
				
		bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",tab_id});
		bindlist.add(new String[]{"STRING",a_field_name});
		bindlist.add(new String[]{"STRING",a_field_type});
		bindlist.add(new String[]{"INTEGER",a_field_size});
		bindlist.add(new String[]{"STRING",a_field_is_pk});
		execDBConf(conn, sql, bindlist);
	}
	

	try {
		ret1=Integer.parseInt(tab_id);	
	} catch(Exception e) {ret1=0;}
	
	return ret1;
	
}



//*************************************************************
public void removeTable(Connection conn, String tab_id) {
//*************************************************************
ArrayList<String[]> bindlist=new ArrayList<String[]>();
bindlist.add(new String[]{"INTEGER",tab_id});

String sql="delete from tdm_fields where tab_id=?";
execDBConf(conn, sql, bindlist);


sql="delete from tdm_tabs where id=?";
execDBConf(conn, sql, bindlist);
}


//*************************************************************
public void changeTableMaskLevel(Connection conn, String tab_id,String mask_level) {
//*************************************************************
ArrayList<String[]> bindlist=new ArrayList<String[]>();
bindlist.add(new String[]{"INTEGER",tab_id});

String sql="update tdm_fields set mask_prof_id=0, is_conditional=null, condition_expr=null where tab_id=?";
execDBConf(conn, sql, bindlist);

sql="update tdm_tabs set mask_level='"+mask_level+"' where id=?";
execDBConf(conn, sql, bindlist);

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
					} else {
						pstmtConf.setString(i, bind_val);
					}
				}
				//------------------------------ end binding
			}  // if bindlist 
			
			if (rsetConf == null) rsetConf = pstmtConf.executeQuery();
			if (rsmdConf == null) rsmdConf = rsetConf.getMetaData();

			int colcount = rsmdConf.getColumnCount();
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
//*************************************************************
		ArrayList<String[]> ret1 = new ArrayList<String[]>();

		PreparedStatement pstmtApp = null;
		ResultSet rsetApp = null;
		ResultSetMetaData rsmdApp = null;

		int reccnt = 0;
		Connection connApp=null;
		try {

			connApp=getconn(connconf, env_id);
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
			String a_field = "";
			while (rsetApp.next()) {
				reccnt++;
				if (reccnt > limit) break;
				String[] row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {
					try {
						if ("DATE,TIMESTAMP,DATETIME".indexOf(rsmdApp.getColumnTypeName(i)) > -1) {
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
			ignore.printStackTrace();
			System.out.println("Exception@getDbArrayConf : " + sql);
		} finally {
			try {rsmdApp = null;} catch (Exception e) {}
			try {rsetApp.close();rsetApp = null;} catch (Exception e) {}
			try {pstmtApp.close();pstmtApp = null;} catch (Exception e) {}
			try {connApp.close();connApp= null;} catch (Exception e) {}
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
String a="<div>";

	
	a+="<select style=\"width:"+width+"px\" class=\"form-control\" #SIZE# name=\""+name+"\" "+additional+">";
	
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
		
		a=a+"<option "+selected+" value=\""+val+"\">" +cap+ "</option>";	
	}
	
	a=a+"</select></div>";
	
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
"<img src=\"prog_completed.png\" border=0 height=14 width=\"" +  completed + "\" alt=\"" + alt_text + "\">" + 
"<img src=\"prog_not_completed.png\" border=0 height=14 width=\"" +  not_completed + "\" alt=\"" + alt_text + "\">" + 
" [<font color=red><b>" + d + "%</b></font>]" + 
"<br><center><font size=2>(" + alt_text + ")</font><center>";

if (b==0) progressbar="-";

return progressbar;

}

//***********************************************
public byte[] getInfoBin(Connection conn, String table_name, int id,String fldname) {
//******************************************************

	byte[] ret1=null;
	String sql="select "+fldname+" from " +table_name+  " where id=?";
	
	PreparedStatement pstmt = null;
	ResultSet rset = null;
	
	conn=getconn();
	
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
			// TODO Auto-generated catch block
			//e.printStackTrace();
			return "ERROR";
		}
      baos.write(buff, 0, count); 
      try {baos.close();} catch (IOException e){}
  }
 
  byte[] output = baos.toByteArray();

  try {
  return new String(output,"UTF-8");
  
  } 	
  catch(Exception e) 
  	{
	  return "ERROR";
	  }
}

//**************************************************************
public String printMonitoringDetails(Connection connconf, String work_plan_id,String tab_name, String status, String only_failed, String a_filter) {
//**************************************************************
String sql="";

StringBuilder html=new StringBuilder();
if (tab_name.equals("TDM_WORK_PACKAGE")) {
	sql="select id, wp_name, status, " + 
		" start_date, end_date, duration, all_count, export_count, " + 
		" done_count, success_count, fail_count  "+
		" from tdm_work_package where status=? and work_plan_id=?";
	if (!nvl(a_filter,"-").equals("-") && !nvl(a_filter,"-").equals("ALL")) sql = sql + " and tab_id=" + a_filter;
		sql=sql + " order by id ";
	
	html.append(""+
			"<table border=1 cellspacing=0 cellpadding=0 width=\"100%\">"+
			"<tr bgcolor=#FFDDAA>"+
			"<td>#</td>"+
			"<td>Wpack Name</td>"+
			"<td>Status</td>"+
			"<td>Start Time</td>"+
			"<td>End Time</td>"+
			"<td>Duration</td>"+
			"<td>Export#</td>"+
			"<td>Masking Progress</td>"+
			"<td>Fail#</td>"+
			"<td>Err.</td>"+
			"</tr>");
} 

if (tab_name.equals("TDM_TASK")) {
	sql="select id, status, " + 
			" start_date, end_date, duration,  " + 
			" all_count, done_count, success_count, fail_count  "+
			" from tdm_task_"+work_plan_id+"_xxWPACKIDxx where status=? ";
	
	if (nvl(only_failed,"-").equals("YES")) sql=sql + " and fail_count>0 ";
	sql=sql + " order by id ";
		
		html.append(""+
				"<table border=1 cellspacing=0 cellpadding=0 width=\"100%\">"+
				"<tr bgcolor=#FFDDAA>"+
				"<td>#</td>"+
				"<td>Status</td>"+
				"<td>Start Time</td>"+
				"<td>End Time</td>"+
				"<td>Duration</td>"+
				"<td>Progress</td>"+
				"<td>Success#</td>"+
				"<td>Fail#</td>"+
				"<td>Task</td>"+
				"<td>Log.</td>"+
				"<td>Err.</td>"+
				"</tr>");
	
}

	


ArrayList<String[]> bindlist=new ArrayList<String[]>();
bindlist.add(new String[]{"STRING",status});
if (tab_name.equals("TDM_WORK_PACKAGE")) bindlist.add(new String[]{"INTEGER",work_plan_id});


	
	
					
	if (tab_name.equals("TDM_WORK_PACKAGE")) {
		ArrayList<String[]> recs=getDbArrayConf(connconf, sql, 100, bindlist);	

		for (int i=0;i<recs.size();i++) {
			String[] arec=recs.get(i);
			
			html.append(""+
					"<tr bgcolor=#DADADA>"+
					"<td>"+arec[0]+"</td>"+ //id
					"<td>"+arec[1]+"</td>"+ //wp name
					"<td>"+arec[2]+"</td>"+ // status
					"<td>"+arec[3]+"</td>"+ //start
					"<td>"+arec[4]+"</td>"+ //end
					"<td>"+formatnum(arec[5])+"</td>"+ //duration
					//"<td>"+progressbar(arec[7],arec[6])+"</td>"+ //exp progress
					"<td>"+arec[7]+"</td>"+ //exp progress
					"<td>"+progressbar(arec[8],arec[7])+"</td>"+ //done progress
					"<td>"+formatnum(arec[10])+"</td>");//fail
					
					
					if (Integer.parseInt(nvl(arec[10],"0"))>0) 
						html.append("<td><a href=\"#\" onclick=\"javascript:showlongdet('longTextDiv','"+arec[0]+"','TDM_WORK_PACKAGE','ERR_INFO');\">Show Err.</a></td>");
					else 
						html.append("<td>-</td>");
					
					
					html.append("</tr>");
		} //for (int i=0;i<recs.size();i++) {
	}  //if (tab_name.equals("TDM_WORK_PACKAGE")) {
	
		
		
		
	if (tab_name.equals("TDM_TASK")) {
		int task_count=0;
		
		
		ArrayList<String[]> currWpcArr=getWpcListByWorkPlan(connconf, work_plan_id,a_filter);
		
		String env_id=getDBSingleVal(connconf, "select env_id from tdm_work_plan where id="+work_plan_id);
		
		for (int w=0;w<currWpcArr.size();w++) {
			
			if (task_count>100) break;
		
			String work_package_id=currWpcArr.get(w)[0];
			
			ArrayList<String[]> recs=getDbArrayConf(connconf, sql.replaceAll("xxWPACKIDxx", work_package_id), 100, bindlist);	
			for (int i=0;i<recs.size();i++) {
				task_count++;
				if (task_count>100) break;
			
				String[] arec=recs.get(i);
				html.append(""+
						"<tr bgcolor=#DADADA>"+
						"<td>"+arec[0]+"</td>"+ //id
						"<td>"+arec[1]+"</td>"+ // status
						"<td>"+arec[2]+"</td>"+ //start
						"<td>"+arec[3]+"</td>"+ //end
						"<td>"+formatnum(arec[4])+"</td>"+ //duration
						"<td>"+progressbar(arec[6], arec[5])+"</td>"+ //export
						"<td>"+formatnum(arec[7])+"</td>"+ //success
						"<td>"+formatnum(arec[8])+"</td>"+ //fail
						"<td><input type=button value=\"Show Task Details\" onclick=\"javascript:showlongdet('"+arec[0]+"','TDM_TASK_"+work_plan_id+"_"+work_package_id+"','TASK_INFO_ZIPPED','"+env_id+"');\" class=\"btn btn-success btn-sm\"></td>"+
						"<td><input type=button value=\"Show Logs\"         onclick=\"javascript:showlongdet('"+arec[0]+"','TDM_TASK_"+work_plan_id+"_"+work_package_id+"','LOG_INFO_ZIPPED','"+env_id+"');\" class=\"btn btn-success btn-sm\"></td>"
						);
						
						
						if (Integer.parseInt(nvl(arec[8],"0"))>0) 
							html.append("<td><input type=button value=\"Show Errors\" onclick=\"javascript:showlongdet('"+arec[0]+"','TDM_TASK_"+work_plan_id+"_"+work_package_id+"','ERR_INFO_ZIPPED');\" class=\"btn btn-success btn-sm\"></td>");
						else 
							html.append("<td>-</td>");
						html.append("</tr>");
			} //for (int i=0;i<recs.size();i++) {
			
		} //for (int w=0;w<currWpcArr.size();w++) {

	}


html.append("</table>");

return html.toString();
}

		
/*		
//**************************************************************
public String printLongDet(Connection connconf,  String env_id, String id, String tab, String fld) {
//**************************************************************
	
	String sql="select " + fld + " from "+tab.toLowerCase()+" where id="+id;
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String lines="";
	
	if (fld.indexOf("_ZIPPED")>-1) {
		try {
			lines=uncompress(getInfoBin(connconf, tab,Integer.parseInt(id),fld));
			
			
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
	if (fld.equals("TASK_INFO_ZIPPEDxx")) {
		
		
		
		StringBuilder tmp=new StringBuilder();
		
		String a_line="";
		String rowid="";
		String table_name="";
		String task_status="";
		
		try {
			task_status=getDBSingleVal(connconf, "select status from " + tab + " where id="+id);
		} catch(Exception e) {};
		
		String[] lineArr=lines.split("\n");
		
		int recno=0;
		String header="";
		StringBuilder orig_sql=new StringBuilder();
		
		for (int i=0;i<lineArr.length;i++) {
			a_line=lineArr[i];

			
			if (a_line.indexOf("<start_of_file>")==0) {
				header= "<table border=0 cellspacing=1 cellpadding=0 width=\"100%\">"+
						"<tr bgcolor=#DAFAFF>";
			}
			else if (a_line.indexOf("<end_of_file>")==0) {
				tmp.append("</table>");
			}
			else if (a_line.indexOf("<record>")==0) {
				recno++;
				
				table_name=a_line.split("\\|::\\|")[2];
				fld=table_name;
				
				tmp.append("<tr bgcolor=#C1C1C1>");
				//tmp.append("<td align=right>"+recno+"@"+table_name+"</td>");
			}
			else if (a_line.indexOf("</record>")==0) {
				if (recno==1) header=header+"</tr>";
				tmp.append("</tr>");	
				
				if (task_status.equals("FINISHED")) {
					orig_sql.append(" from " + table_name + " where rowid=?");
					bindlist=new ArrayList<String[]>();
					bindlist.add(new String[]{"ROWID", rowid});
					ArrayList<String[]> origRec=getDbArrayApp(connconf, env_id, orig_sql.toString(), 1, bindlist);
					orig_sql=new StringBuilder();
					if (origRec.size()>0) {
						String[] aRec=origRec.get(0);
						tmp.append("<tr bgcolor=white>");
						tmp.append("<td align=right></td>"); // rowid
						for (int k=1;k<aRec.length;k++) 
							tmp.append("<td><b>"+aRec[k]+"</b></td>");
							
						tmp.append("</tr>");	
						
					}
				
					if (recno>=100) break;
				} //if (task_status.equals("FINISHED")) {
				
				
			}
			else if (a_line.indexOf("<field>")==0) {
				
				String fArr[]=a_line.split("\\|::\\|");
				
				String fname=fArr[1];
				String ftype=fArr[2];
				String fmask=fArr[3];
				String fval=fArr[4];

				
				
				if (recno==1) header=header+"<td nowrap align=center>"+
											"<b>"+fname+"</b><br>["+ftype+"]"+
											"</td>";
					tmp.append("<td><strike>"+fval+"</strike></td>");
				
				
					if (ftype.equals("ROWID:0")) {
						orig_sql.append("select "+fname);
						rowid=fval;
					} else {
						orig_sql.append(", "+fname);
					}
						
			}
			
			a_line=null;
		} //for
		
		
		lines=header+tmp.toString();
		tmp=null;
	} //if (fld.equals("TASK_INFO_ZIPPED"))
	else {
		lines="<textarea cols=120 rows=25>"+lines+"</textarea>";
	}
	


	String html="<center>"+
			"<table border=0 cellspacing=0 cellpadding=0><tr><td bgcolor=yellow><h3>"+
			fld+"@"+tab+"["+id+"]"+
			"</h3></td></tr></table>"+
			lines+
			"</center>";
	
	lines=null;
	
	return html;

    
    

}
	
*/
	
	
	
	
//**************************************************************
public String printLongDet2(Connection connconf,  String env_id, String id, String tab, String fld) {
//**************************************************************
	
	String sql="select " + fld + " from "+tab.toLowerCase()+" where id="+id;
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String lines="";
	
	if (fld.indexOf("_ZIPPED")>-1) {
		try {
			lines=uncompress(getInfoBin(connconf, tab,Integer.parseInt(id),fld));
			
			
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
	if (fld.equals("TASK_INFO_ZIPPED")) {
		
		
		
		StringBuilder tmp=new StringBuilder();
		
		String a_line="";
		String table_name="";
		String task_status="";
		
		ArrayList<String> fieldSelectList=new ArrayList<String>();
		ArrayList<String[]> fieldWhereList=new ArrayList<String[]>();
		
		try {
			task_status=getDBSingleVal(connconf, "select status from " + tab + " where id="+id);
		} catch(Exception e) {};
		
		if (task_status.length()==0) return "Task is not there.";
		
		String[] lineArr=lines.split("\n");
		
		int recno=0;
		String header="";
		StringBuilder orig_sql=new StringBuilder();
		
		for (int i=0;i<lineArr.length;i++) {
			a_line=lineArr[i];

			
			if (a_line.indexOf("<start_of_file>")==0) {
				header= "<table border=0 cellspacing=1 cellpadding=0 width=\"100%\">"+
						"<tr bgcolor=#DAFAFF>";
			}
			else if (a_line.indexOf("<end_of_file>")==0) {
				tmp.append("</table>");
			}
			else if (a_line.indexOf("<record>")==0) {
				recno++;
				
				table_name=a_line.split("\\|::\\|")[2];
				fld=table_name;
				
				tmp.append("<tr bgcolor=#C1C1C1>");
				//tmp.append("<td align=right>"+recno+"@"+table_name+"</td>");
			}
			else if (a_line.indexOf("</record>")==0) {
				if (recno==1) header=header+"</tr>";
				tmp.append("</tr>");	
				
				if (task_status.equals("FINISHED")) {
					orig_sql.append("select ");
					
					int fno=0;
					
					//select pk keys first
					for (int f=0;f<fieldWhereList.size();f++) {
						fno++;
					
						String fname=fieldWhereList.get(f)[0];
						if (fno>1)  orig_sql.append(", ");
						orig_sql.append(fname);
						
					}

					//than select another fields
					for (int f=0;f<fieldSelectList.size();f++) {
						fno++;

						String fname=fieldSelectList.get(f);
						if (fno>1)  orig_sql.append(", ");
						orig_sql.append(fname);
						
					}
					
					orig_sql.append(" from  " + table_name);
					orig_sql.append(" where ");
					
					
					bindlist=new ArrayList<String[]>();
					
					for (int f=0;f<fieldWhereList.size();f++) {
						String fname=fieldWhereList.get(f)[0];
						String ftype=fieldWhereList.get(f)[1];
						String fval=fieldWhereList.get(f)[2];

						if (f>0) orig_sql.append("and  ");
						orig_sql.append(fname + "=? ");
						
						bindlist.add(new String[]{ftype, fval});  //
					}
				

					ArrayList<String[]> origRec=getDbArrayApp(connconf, env_id, orig_sql.toString(), 1, bindlist);
					orig_sql=new StringBuilder();
					if (origRec.size()>0) {
						String[] aRec=origRec.get(0);
						tmp.append("<tr bgcolor=white>");
						int pkCount=fieldWhereList.size();
						//tmp.append("<td align=right colspan="+pkCount+"></td>"); // PK Fields
						for (int k=pkCount-1;k<aRec.length;k++) 
							tmp.append("<td nowrap><b>"+aRec[k]+"</b></td>");
							
						tmp.append("</tr>");	
					}
					
					//reset arrays
					fieldSelectList=new ArrayList<String>();
					fieldWhereList=new ArrayList<String[]>();

				
					if (recno>=10) break;
				} //if (task_status.equals("FINISHED")) {
				
				
			}
			else if (a_line.indexOf("<field>")==0) {
				
				String fArr[]=a_line.split("\\|::\\|");
				
				String fname=fArr[1];
				String ftype=fArr[2].split(":")[0];
				String f_ispk=fArr[3];
				String fmask=fArr[4];
				String fmask_rule=fArr[5];
				String fval=fArr[6];
				
				
				if (f_ispk.equals("YES")) fieldWhereList.add(new String[]{fname,ftype,fval});
				else fieldSelectList.add(fname);

				
				
				if (recno==1) header=header+"<td nowrap align=center>"+
											"<b>"+fname+"</b><br>["+ftype+"]"+
											"</td>";
					tmp.append("<td><strike>"+fval+"</strike></td>");
				
			}
			
			a_line=null;
		} //for
		
		
		lines=header+tmp.toString();
		tmp=null;
	} //if (fld.equals("TASK_INFO_ZIPPED"))
	else {
		lines="<textarea cols=120 rows=25>"+lines+"</textarea>";
	}
	


	String html="<center>"+
			"<table border=0 cellspacing=0 cellpadding=0><tr><td bgcolor=yellow><h3>"+
			fld+"@"+tab+"["+id+"]"+
			"</h3></td></tr></table>"+
			lines+
			"</center>";
	
	lines=null;
	
	return html;

  
  

}




//**************************************************************
public StringBuilder discoveryPrint(Connection connconf,String app_id, String env_id, String schema_name,String act) {
//**************************************************************

StringBuilder sb=new StringBuilder();


ArrayList<String[]> bindlist=new ArrayList<String[]>();

String sql="select count(*) x from tdm_discovery where app_id="+app_id+" and env_id="+env_id+" and schema_name='" + schema_name + "'";
String cntx=getDBSingleVal(connconf, sql);
int discovery_id=0;
String discovery_status="";

if (Integer.parseInt(cntx)==0 && act.equals("add")) {
	sql="insert into tdm_discovery (status, app_id, env_id, schema_name) values ('NEW',"+app_id+","+env_id+",'" +schema_name+ "')";
	execDBConf(connconf, sql, bindlist);
}




sql="select id  from tdm_discovery where app_id="+app_id+" and env_id="+env_id+" and schema_name='" + schema_name + "'";
discovery_id=Integer.parseInt(getDBSingleVal(connconf, sql));	


if (act.equals("start")) {
	sql="delete from tdm_discovery_result where discovery_id="  + discovery_id;
	execDBConf(connconf, sql, bindlist);
	
	sql="update tdm_discovery set status='NEW',progress=0, progress_desc='',error_msg='' where id="  + discovery_id;
	execDBConf(connconf, sql, bindlist);

}

if (act.equals("stop")) {
	sql="update tdm_discovery set status='FINISHED' where id="  + discovery_id;
	execDBConf(connconf, sql, bindlist);

}

sql="select status  from tdm_discovery where app_id="+app_id+" and env_id="+env_id+" and schema_name='" + schema_name + "'";
discovery_status=getDBSingleVal(connconf, sql);	

sql="select id, description from tdm_discovery_target t " + 
	" where exists (select * from tdm_discovery_result r where discovery_id="+ discovery_id  +" and discovery_target_id=t.id and match_count>10) " + 
	" order by description";
ArrayList<String[]> targetArr=getDbArrayConf(connconf, sql, 100, bindlist);



if (discovery_status.equals("FINISHED") || discovery_status.equals("FAILED"))
sb.append("&nbsp;<input type=submit name=start_discovery value=\"Start  / Restart\" class=\"btn btn-success btn-sm\">");

if (discovery_status.equals("RUNNING"))		
	sb.append("&nbsp;<input type=submit name=stop_discovery value=\"Stop\" class=\"btn btn-success btn-sm\">");

sb.append("&nbsp;<img src=\"" +discovery_status+ ".gif\" border=0 width=30 height=24>&nbsp;<font color=white>" + discovery_status+"</font>");

if (discovery_status.equals("RUNNING")) {
	sql="select progress  from tdm_discovery where app_id="+app_id+" and env_id="+env_id+" and schema_name='" + schema_name + "'";
	String progress=getDBSingleVal(connconf, sql);	
	sql="select progress_desc  from tdm_discovery where app_id="+app_id+" and env_id="+env_id+" and schema_name='" + schema_name + "'";
	String progress_desc=getDBSingleVal(connconf, sql);	

	sb.append("<table border=0 cellspacing=0 cellpadding=0 width=\"100%\"><tr bgcolor=white><td><font color=green><b>Progress : </b> % " + progress+" (" + progress_desc + ") </font></td></tr></table>");

}

if (discovery_status.equals("FAILED")) {
	sql="select error_msg  from tdm_discovery where app_id="+app_id+" and env_id="+env_id+" and schema_name='" + schema_name + "'";
	String discovery_error_msg=getDBSingleVal(connconf, sql);	
	sb.append("<table border=0 cellspacing=0 cellpadding=0 width=\"100%\"><tr bgcolor=white><td><font color=red><b>Error Details:</b> " + discovery_error_msg+"</font></td></tr></table>");

}

sb.append("<input type=hidden id=discoveryStatus value=\""+discovery_status+"\">");

sb.append("<table border=1 width=\"100%\">");
	
	
int found_target_count=0;

for (int t=0;t<targetArr.size();t++) {
	String target_id=targetArr.get(t)[0];
	String target_description=targetArr.get(t)[1];
	
	
	sql="select schema_name, table_name, sum(match_count) " +
			" from tdm_discovery_result  " +
			" where discovery_id=" +discovery_id+ " " +
		 	" and discovery_target_id="+ target_id  + " " +
			" group by schema_name, table_name " +
			" having sum(match_count)>=100 " +
			" order by 3 desc " ;
	ArrayList<String[]> resTableArr=getDbArrayConf(connconf, sql, Integer.MAX_VALUE, bindlist);
	
	if (resTableArr.size()>0) 
		sb.append(
				"<tr bgcolor=#DADADA>"+
				"<td bgcolor=blue align=center><big><font color=white><b>"+target_description+"</b></font></big></td>"+
				"</tr>"+
				"<tr bgcolor=#FAFAFA>"+
				"<td>");

	
	sb.append("<table border=1 cellspacing=0 cellpadding=0 width=\"100%\">");
			
	for (int rt=0;rt<resTableArr.size();rt++) {
		String disc_schema_name=resTableArr.get(rt)[0];
		String disc_table_name=resTableArr.get(rt)[1];
		String disc_match_count=resTableArr.get(rt)[2];
		
		found_target_count++;

		sb.append(
				"<tr bgcolor=#DADADA>"+
				"<td width=360px valign=top bgcolor=#FAFAFA><font color=black size=2 >"+
				 "<a href=\"#\" onclick=\"javascript:showtable('"+env_id+"','','"+disc_schema_name+"."+disc_table_name+"','100','tab_filter');\">"+
                "<img src=\"table.png\" border=0 width=20 height=20></a>"+
				"<b>"+disc_schema_name+"."+disc_table_name+
				 "  </b></font></td>"+
				"<td>");
				
				sql="select " + 
				" field_name, rl.description,sum(match_count)  " +
				" from tdm_discovery_result rs, tdm_discovery_rule rl " +
				" where rs.discovery_id=" +discovery_id+ " " +
				" and rs.discovery_rule_id=rl.id " +
				" and rs.discovery_target_id="+ target_id  + " " +
				" and schema_name='"+ disc_schema_name  + "' " +
				" and table_name='"+ disc_table_name  + "' " +
				" group by field_name, rl.description " +
				" having sum(match_count)>10 " +
				" order by 1 ";
				
				ArrayList<String[]> resFieldArr=getDbArrayConf(connconf, sql, Integer.MAX_VALUE, bindlist);
				sb.append("<table border=0 cellspacing=0 cellpadding=0 width=\"100%\">");
				
				String last_field_name="";
				for (int rf=0;rf<resFieldArr.size();rf++) {
					String disc_field_name=resFieldArr.get(rf)[0];
					String disc_rule_desc=resFieldArr.get(rf)[1];
					String disc_field_match_count=resFieldArr.get(rf)[2];
					
					if (last_field_name.equals(disc_field_name)) disc_field_name="";
					else last_field_name=disc_field_name;
					
					double likelihood=Math.floor((100 * Integer.parseInt(disc_field_match_count)/1000));
					
					String bgcolor="#D4D4D4";
					if (likelihood>=10 && likelihood<=100) bgcolor="lightgreen";
					
					sb.append(
							"<tr color=#DDDDDD>"+
									"<td width=\"200px\"><font size=2><b>" + disc_field_name +"</b></font></td>"+
									"<td align=right width=\"120px\" bgcolor=" +bgcolor+ ">" + disc_field_match_count + " matches &nbsp;</td>"+
									"<td> " + disc_rule_desc +"</td>"+
							"</tr>");
							
							
				}
				
				sb.append("</table></td></tr>");

		} //for (int rt=0;rt<resTableArr.size();rt++) {
			
		if (resTableArr.size()>0) {
			sb.append("</table>");	
			sb.append(
					"</td>"+
					"</tr>");
			}
		

			
} //for (int t=0;t<targetArr.size();t++) {
	

	sb.append("</table>");

	if (found_target_count==0) 
		sb.insert(0, "<big><big><b><font color=red>No result found by discovery. :(</></b></big></big><br>");


return sb;

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
		owners_tar=getSchemaListFromConn(connTar);
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
	public boolean validateSQLStatement(Connection connconf,String env_id, String sql) {
//*************************************************************
		boolean ret1 = false;

		Connection connApp=null;
		PreparedStatement pstmtApp=null;
		
		try {

			connApp=getconn(connconf, env_id);
			pstmtApp = connApp.prepareStatement(sql);
			pstmtApp.setQueryTimeout(30);
			pstmtApp.executeQuery();
			ret1=true;
		} catch (Exception ignore) {
			ignore.printStackTrace();
			System.out.println("Exception@validateSQLStatement : " + sql);
		} finally {
			try {pstmtApp.close();pstmtApp = null;} catch (Exception e) {}
			try {connApp.close();connApp= null;} catch (Exception e) {}
		}
		
		return ret1;
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
	
	
	//***********************************************
	public void testmail(Connection conn) {
	//***********************************************
		
		String sql="";
		String from="TDM@tdm.com";
		String to=getParamByName(conn,"JAVAX_EMAIL_ADDRESS");
		if (to.trim().length()==0) return;

		final String username=getParamByName(conn,"JAVAX_EMAIL_USERNAME");
		final String password=decode(getParamByName(conn,"JAVAX_EMAIL_PASSWORD"));

		Properties props=System.getProperties();

		String props_str=getParamByName(conn,"JAVAX_EMAIL_PROPERTIES");
		
		if (props_str.length()==0) return; 
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
			return;
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
			
		} catch (Exception e) {
			System.out.println("Exception@sendmail : "+e.getMessage());
			e.printStackTrace();
		}
		finally {
			props=null;
			msg=null;
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
	
	if (username.equals("admin")) p_authentication_method="LOCAL";

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
		
		String sql="select upper(username), id from tdm_user where valid='Y' and upper(username)=? and password=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		ArrayList<String[]> res=null;
		String dbusername="";
		String encpass="";
	
		try {
			encpass=encrypt(password);
			bindlist.add(new String[]{"STRING",username.toUpperCase()});
			bindlist.add(new String[]{"STRING",encpass});
			res=getDbArrayConf(conn, sql, 1, bindlist);
			if (res.size()>0) 
				dbusername=res.get(0)[0];
		} catch(Exception e) {
			dbusername="";
			e.printStackTrace();
		}
	
	
		
		if (dbusername.length()>0 && username.length()>0 && encpass.length()>0 && res.size()==1) {
			if (dbusername.equals(username.toUpperCase())) {
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
		rolevar=(String) session.getAttribute("hasrole_"+role_name);
		if (rolevar.equals("true")) ret1=true;
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
			response.sendRedirect("default.jsp");
		} catch(Exception e) {}
	
	}



	
	//************************************************
	public void startManager(Connection conn) {
	

		String HomePath=getParamByName(conn, "TDM_PROCESS_HOME");
		String username=getParamByName(conn, "CONFIG_USERNAME");
		String password=decode(getParamByName(conn, "CONFIG_PASSWORD"));
		
		/*
		System.out.println("------------------  startManager ----------------------");

		System.out.println("TDM_PROCESS_HOME="+HomePath);
		System.out.println("CONFIG_USERNAME="+username);
		System.out.println("CONFIG_PASSWORD=*******");
		*/
		
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
			run_cmd="cmd /c start XXX "+username+" " + password;
			system_type=".bat";
		}
			
		if (OS.indexOf("nix") >= 0 || OS.indexOf("nux") >= 0 || OS.indexOf("aix") > 0 || OS.indexOf("sunos") >= 0) {
			run_cmd="./XXX "+username+" " + password+ " 1 &";
			system_type=".sh";
		}
			
		System.out.println("system type : "+system_type);
		File dir = new File(HomePath);
		File[] filesList = dir.listFiles();
		for (File file : filesList) {
		    if (file.isFile()) {
		       fname=file.getName();
		       if (fname.toLowerCase().contains(system_type)) {
		    	   try {
					Scanner scanner = new Scanner(file);
					while (scanner.hasNextLine()) {
						   final String lineFromFile = scanner.nextLine();
						   if(lineFromFile.contains(run_classname) && lineFromFile.contains("java")) { 
						       // a match!
						       System.out.println("Running new process " +run_classname+ " " +process_count + " times..");
						       for (int i=0;i<process_count;i++) {						    	   
							       try {
							    	   Runtime.getRuntime().exec(run_cmd.replaceAll("XXX", fname),envparams, new File(HomePath));   
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


        //burasi kaldirilabilir 
        /*
        if (mask_level.equals("RELATIONxxxxxxxx")) {
        	
        	if (!nvl(orderby_validation_message,"-").equals("-"))
        		tab_order_stmt=request.getParameter("tab_order_stmt");
        
           html=html+""+
           "<tr>"+
           "<td align=left >Order By : <font color=red><b>" + orderby_validation_message + "</b></font>"+
           "<br>"+
           "<textarea name=tab_order_stmt id=tab_order_stmt cols=25 rows=3>" +
        	tab_order_stmt +
           "</textarea>"+
           "</td>"+
           "</tr>";
       }
       */


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
	
	
%>



