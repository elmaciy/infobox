<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="javax.naming.*" %>
<%@ page import="javax.naming.directory.DirContext" %>
<%@ page import="javax.naming.directory.InitialDirContext" %>
<%@ page import="java.util.*" %> 
<%@page import="java.io.IOException"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@page import="java.io.File"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.BufferedWriter"%>
<%@page import="java.net.InetAddress"%>
<%@page import="java.io.OutputStreamWriter"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.sun.mail.util.BASE64DecoderStream" %>
<%@page import="com.sun.mail.util.BASE64EncoderStream" %>
<%@page import="javax.crypto.Cipher" %>
<%@page import="javax.crypto.KeyGenerator" %>
<%@page import="javax.crypto.SecretKey" %>
<%@page import="javax.crypto.spec.SecretKeySpec" %>
<%@page import="org.apache.commons.codec.binary.Base64" %>

<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.OutputStream"%>

<%@page import="javax.script.ScriptEngine" %>
<%@page import="javax.script.ScriptEngineManager" %>

<%@page import="java.util.regex.Matcher" %>
<%@page import="java.util.regex.Pattern" %>

<%@page import="oracle.sql.ROWID"%>

<%

request.setCharacterEncoding("utf-8");



String currurl="";

currurl=nvl(request.getRequestURL().toString(),"").toLowerCase();

String curruser=nvl((String) session.getAttribute("username"),"");


initModules();



if (!currurl.contains("default.jsp")  && !currurl.contains("about.jsp") && !currurl.contains("ajaxdynamiccomponent.jsp")  && curruser.length()==0) {
	response.sendRedirect("default.jsp");	
}


 
%>


<%! 


final String DEFAULT_DATE_FORMAT="dd/MM/yyyy HH:mm:ss";
String mysql_format="%d.%m.%Y %H:%i:%s";



//*************************************************************
public ArrayList<String[]> getDbArrayConf(Connection connConf, String sql, int limit,ArrayList<String[]> bindlist) {
//*************************************************************
	return  getDbArrayConf(connConf, sql, limit, bindlist,9999);
	}
//*************************************************************

public ArrayList<String[]> getDbArrayConf(Connection connConf, String sql, int limit,ArrayList<String[]> bindlist, int timeout_insecond) {
	return getDbArrayConf(connConf,sql,limit, bindlist,timeout_insecond,null);
}

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
public ArrayList<String[]> getDbArrayApp(Connection connconf,String env_id, String sql, int limit,ArrayList<String[]> bindlist, ArrayList<String> colList) {
//*************************************************************
	ArrayList<String[]> ret1 = new ArrayList<String[]>();

	
	Connection connApp=getconn(connconf, env_id);
	ret1=getDbArrayApp(connApp, sql, limit, bindlist, colList);
		
	closeconn(connApp);
	
	return ret1;
}
	
//*********************************************************************************************	
public ArrayList<String[]> getDbArrayApp(
		Connection connApp,
		String sql, 
		int limit,
		ArrayList<String[]> bindlist, 
		ArrayList<String> colList) {
	
	ArrayList<String[]> ret1 = new ArrayList<String[]>();
	
	int reccnt = 0;
	
	PreparedStatement pstmtApp = null;
	ResultSet rsetApp = null;
	ResultSetMetaData rsmdApp = null;
	
	try {
		
		pstmtApp = connApp.prepareStatement(sql);
		
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
						java.util.Date b=new java.util.Date();
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
		
		if (colList!=null) {
			colList.clear();
			for (int i=1;i<=colcount;i++) 
				colList.add(rsmdApp.getColumnName(i));
			
			
		}
		
		
		String a_field = "";
		while (rsetApp.next()) {
			reccnt++;
			if (reccnt > limit) break;
			String[] row = new String[colcount];
			for (int i = 1; i <= colcount; i++) {
				try {
					if ("DATE,TIMESTAMP,DATETIME".indexOf(rsmdApp.getColumnTypeName(i).toUpperCase()) > -1) {
						java.sql.Date d = rsetApp.getDate(i);
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
		System.out.println("Exception@getDbArrayApp : " + sql);
	} finally {
		try {rsmdApp = null;} catch (Exception e) {}
		try {rsetApp.close();rsetApp = null;} catch (Exception e) {}
		try {pstmtApp.close();pstmtApp = null;} catch (Exception e) {}
	}
	return ret1;
}
//****************************************************************
String getStringIdByName(Connection conn, HttpSession session, String string_name) {
	
	String lang=nvl((String) session.getAttribute("curr_lang"),"");
	
	String session_string_id=nvl((String) session.getAttribute(string_name+"/"+lang),"");
	
	if (session_string_id.length()>0) return session_string_id;
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select id from mad_string where string_name=? and lang=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",string_name});
	bindlist.add(new String[]{"STRING",lang});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr!=null && arr.size()==1) {
		String string_id=arr.get(0)[0];
		session.setAttribute(string_name+"/"+lang, string_id);	
		return string_id;
	}
		
	sql="select id from mad_string where string_name=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",string_name});
	
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr!=null && arr.size()==1) {
		String string_id=arr.get(0)[0];
		session.setAttribute(string_name+"/"+lang, string_id);
		return string_id;
	}
	
	return "";
	
}


//********************************************************************************
String decodeLovSql(String lov_type) {
	String sql="";
	
	if (lov_type.equals("method"))
		sql="select id, concat(method_type, ' [',method_name,']') from mad_method where is_valid='YES' order by  method_type,method_name ";
	
	if (lov_type.equals("method_type"))
		sql="select 'JAVASCRIPT', 'JavaScript' from dual "+
				" union all "+
				"select 'DATABASE','Database JDBC Call' from dual"+
				" union all "+
				"select 'SHELL','Shell Command' from dual "+
				" union all "+
				"select 'JAVA','Java by Reflection' from dual";
	
	if (lov_type.equals("lang_list"))
		sql="select lang, lang_desc from mad_lang order by 2";
	if (lov_type.equals("flex_field"))
		sql="select id, title from mad_flex_field order by 2";
	if (lov_type.equals("flex_field_type"))
		sql="select 'TEXT','Single Line Text Box' from dual union all " + 
			"select 'NUMBER','Number / Currency' from dual union all " +
			"select 'MEMO','Multi Line Text' from dual union all " +
			"select 'LIST','List Box' from dual union all " +
			"select 'LOV','List of Value (LOV) ' from dual union all " +
			"select 'CHECKBOX','Checkbox' from dual union all " +
			"select 'PICKLIST','Pick List' from dual union all " +
			"select 'DATE','Date Picker' from dual union all " +
			"select 'DATETIME','Date Time Picker' from dual union all " +
			"select 'ATTACHMENT','File Attachment' from dual union all " +
			"select 'PASSWORD','Password' from dual";
	
			;
	if (lov_type.equals("group_type"))
		sql="select 'USER', 'User Group' from dual union all select 'NOTIFICATION','Notification Group' from dual";
	if (lov_type.equals("group"))
		sql="select id, group_name from mad_group where group_type='USER' order by 2";
	if (lov_type.equals("role"))
		sql="select id, description from tdm_role order by 2";
	
	return sql;
	
}

//***********************

ArrayList<String[]> getLovArrayList(Connection conn, HttpSession session, String lov_type, String lov_parameters, String to_refresh) {
	String sql= "";
	
	ArrayList<String[]> lovArr=new ArrayList<String[]>();
	


	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	boolean use_cache=true;
	if (to_refresh.equals("YES"))  use_cache=false;
	
	sql=decodeLovSql(lov_type);
	
	bindlist.clear();
	
	lovArr=(ArrayList<String[]>) session.getAttribute(lov_type);
	
	if (lovArr==null || !use_cache) {
		lovArr=getDbArrayConf(conn, sql, 10000, bindlist);
		session.putValue(lov_type, lovArr);
	}
			
		
	
	return lovArr;
}

//********************************************************************************
String fillLovList(Connection conn, ArrayList<String[]> arr, String curr_value, String filter_value) {
	StringBuilder sb=new StringBuilder();
	
	if (arr==null) arr=new ArrayList<String[]>();
	
	StringBuilder cells=new StringBuilder();
	StringBuilder values=new StringBuilder();
	
	sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
	
	int matched_count=0;
	
	for (int i=0;i<arr.size();i++) {
		String val=""; 

		values.setLength(0);
		cells.setLength(0);
		
		try{val=arr.get(i)[0];} catch(Exception e) {};
		
		int start_c=0;
		if (arr.get(i).length>1) start_c=1;
		
		for (int c=start_c;c<arr.get(i).length;c++) {
			values.append(arr.get(i)[c]);
			cells.append("<td nowrap>"+arr.get(i)[c]+"</td>");
		}
		
		
		
		
		if (filter_value.length()>0 && !values.toString().toUpperCase().contains(filter_value.toUpperCase())) continue;
		matched_count++;
		
		String style="";
		boolean selected=false;
		if (curr_value.equals(val)) selected=true;
			
		if (selected) 
			sb.append("<tr class=danger>");
		else 
			sb.append("<tr>");
		
		sb.append("<td>");
		
		if (selected)
			sb.append("<input name=lovradiogroup type=radio checked onclick=\"setLovSelection('"+i+"','"+codehtml(val)+"');\" ondblclick=\"selectLOV();\">");
		else 
			sb.append("<input name=lovradiogroup type=radio  onclick=\"setLovSelection('"+i+"','"+codehtml(val)+"');\" ondblclick=\"selectLOV();\">");

		sb.append("</td>");
		sb.append(cells.toString());
		sb.append("</tr>");
			


	}
	
	
	
	if (matched_count==0) 
		return "<font color=red>No item is matching.</font>";
	
	
	return sb.toString();
}

//********************************************************************************
String makeLov(
		Connection conn,
		HttpSession session,
		String lov_title,
		String lov_type, 
		String lov_parameters, 
		String curr_value,
		String fireEvent) {
	
	ArrayList<String[]> lovArr=getLovArrayList(conn, session, lov_type, lov_parameters, "YES");
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<h4><span class=\"label label-danger\">"+lov_title+"</span></h4>");
	sb.append("<table class=table>");
	sb.append("<tr>");
	sb.append("<td width=\"100%\">");
	sb.append(makeText("filter_lov_box", "", "placeholder=\"Search for ...\" onkeypress=\"filterLovOnEnter(event)\"", 0));
	sb.append("</td>");
	sb.append("<td nowrap >");
	sb.append("<big><big><font color=blue><span class=\"glyphicon glyphicon-filter\" onclick=\"filterLov(false)\"></span></font></big></big>");
	sb.append(" ");
	sb.append("<big><big><font color=green><span class=\"glyphicon glyphicon-refresh\" onclick=\"filterLov(true)\"></span></font></big></big>");
	sb.append("</td>");
	sb.append("</tr>");
	sb.append("</table>");
	
	sb.append("<input type=hidden id=lov_fireEvent value=\""+fireEvent+"\">");
	sb.append("<input type=hidden id=lov_type value=\""+lov_type+"\">");
	sb.append("<input type=hidden id=lov_parameters value=\""+clearHtml(lov_parameters)+"\">");

	sb.append("<input type=hidden id=lov_selected_value value=\""+curr_value+"\">");
	sb.append("<div id=lovListItemsDiv>");
	sb.append(fillLovList(conn, lovArr, curr_value,""));
	sb.append("</div>");
	
	
	
	return sb.toString();
}

//*****************************************************
String makeHintButton(Connection conn, HttpSession session, String string_name) {
	StringBuilder sb=new StringBuilder();

	
	String string_id=getStringIdByName(conn, session, string_name);
	
	
	if (string_id.length()>0) {
		sb.append(" <span class=badge onclick=\"viewHtmlContent('"+string_id+"');\">");
		sb.append("<small><span class=\"glyphicon glyphicon-info-sign\"></span></small>");
		sb.append("</span> ");
		return sb.toString(); 
	}
	
	sb.append(" <span class=badge onclick=\"myalert('Undefined string : ["+codehtml(string_name)+"]');\" >");
	sb.append("<span class=\"glyphicon glyphicon-info-sign\"></span>");
	sb.append("</span> ");
	
	return sb.toString();
}



//----------------------------------------------
String getStringContent(Connection conn, HttpSession session, String string_id, String field) {

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select short_desc, long_desc from mad_string where id=?";
	if (field.equals("short_desc")) 
		sql="select short_desc from mad_string where id=?";
	
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",string_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) 
		return "no content for string id " + string_id;
	
	
				
	String short_desc="";
	String long_desc="";
	
	if (field.equals("short_desc")) {
		short_desc=arr.get(0)[0];
		
		return short_desc;
		
	} else {
		short_desc=arr.get(0)[0];
		long_desc=arr.get(0)[1];
		
		StringBuilder sb=new StringBuilder();
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-12\"></div>");
		sb.append("<h3> <span class=\"label label-warning\"> <span class=\"glyphicon glyphicon-info-sign\"></span> "+short_desc+"</span></h3>");
		sb.append("</div>");
		sb.append("</div>");
		

		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-12\" style=\"min-height: 0px; max-height: 400px; overflow-y: scroll;\">");
		if (long_desc.length()==0)
			sb.append("No Content is available");
		else 
			sb.append(long_desc);
		sb.append("</div>");
		sb.append("</div>");
		
		return sb.toString();		
	}
	
	
				
	
	
}

//----------------------------------------------
String getStringContentByName(Connection conn, HttpSession session, String string_name, String field) {

	String lang=nvl((String) session.getAttribute("curr_lang"),"EN");
	
	
	String string_id=getStringIdByName(conn, session, string_name);
	
	if (string_id.length()>0) {
		String session_string_content=nvl((String) session.getAttribute(string_id+"/"+field),"");
		
		if (session_string_content.length()>0) 
			return session_string_content;
		
		String content=getStringContent(conn, session, string_id, field);
		
		session.setAttribute(string_id+"/"+field, content);
		
		return content;
	}
		
	
			
	return "no content for string name (" + string_name + ") language ("+lang+")";	
	
}
//--------------------------------------------------------------------------
String decodeStringTitle(Connection conn, HttpSession session, String entry_title, String string_name, boolean hintbutton) {
	
	String string_id=getStringIdByName(conn, session, string_name);
	
	if (string_id.length()==0) return entry_title;
	
	String short_desc=getStringContentByName(conn, session, string_name,"short_desc");
	
	if (short_desc.trim().length()==0) return entry_title;
	if (hintbutton)
		return short_desc+ " " + makeHintButton(conn, session, string_name)+ "<!-- "+clearHtml(string_name)+" -->";
	else 
		return short_desc+ "<!-- "+clearHtml(string_name)+" -->";
	

}


ArrayList<String[]> moduleArr=new ArrayList<String[]>();

static final int MODULE_FLD_NAME=0;
static final int MODULE_FLD_MENU_TITLE=1;
static final int MODULE_FLD_ROLES=2;
static final int MODULE_FLD_MODULE_TYPE=3;



//*********************************************************************************************
void initModules() {
	moduleArr.clear();
	moduleArr.add(new String[]{
				"home",				
				"Home",			
				"",
				"HOME" //module type
				});
	moduleArr.add(new String[]{
			"requirement",		
			"Requirement",	
			"ADMIN,TEST_ADMIN,TEST_REQUIREMENT",
			"TREE" //module type
			});
	moduleArr.add(new String[]{
			"design",			
			"Test Case",		
			"ADMIN,TEST_ADMIN,TEST_DESIGN",
			"TREE" //module type
			});
	moduleArr.add(new String[]{
			"organize",				
			"Organize",			
			"ADMIN,TEST_ADMIN,TEST_DESIGN",
			"TREE" //module type
			});
	moduleArr.add(new String[]{
			"execution",			
			"Execute",	
			"ADMIN,TEST_ADMIN,TEST_EXECUTION",
			"TREE" //module type
			});
	moduleArr.add(new String[]{
			"bug",				
			"Bug",			
			"ADMIN,TEST_ADMIN,TEST_BUG",
			"NOTREE" //module type
			});
	moduleArr.add(new String[]{
			"analyse",			
			"Analyse",		
			"ADMIN,TEST_ADMIN,TEST_ANALYSE",
			"TREE" //module type
			});
	moduleArr.add(new String[]{
			"administration",	
			"Admin",		
			"ADMIN,TEST_ADMIN",
			"NOTREE" //module type
			});
}




//*********************************************************************************************
int getModuleIdByName(String module) {
	int ret1=-1;
	for (int i=0;i<moduleArr.size();i++) {
		//System.out.println("comparing "+module +" and " +moduleArr.get(i)[MODULE_FLD_NAME]);
		
		if (nvl(module,"x").equals(moduleArr.get(i)[MODULE_FLD_NAME])) ret1=i;
	}
	return ret1;
}
//*********************************************************************************************
String getModuleName(Connection conn, HttpSession session, String module) {

	String title="unknown module";
	
	int module_id=getModuleIdByName(module);
	if (module_id>-1)
		title=moduleArr.get(module_id)[MODULE_FLD_MENU_TITLE];
	
	String string_name="SYS_MENU_ITEM_FOR_"+module;
	String menu_title_by_lang=decodeStringTitle(conn, session, title, string_name, false);
	
	return menu_title_by_lang;
}
//*********************************************************************************************
String getModuleRoles(Connection conn, HttpSession session, String module) {

	String role="unknown role";
	
	int module_id=getModuleIdByName(module);
	
	
	if (module_id>-1)
		role=moduleArr.get(module_id)[MODULE_FLD_ROLES];
	return role;
}

//*********************************************************************************************
public String newMenuItem(
		Connection conn, 
		HttpSession session, 
		String module) {

	String menu_title_by_lang=getModuleName(conn,session,module);
	
	String curr_module=nvl((String) session.getAttribute("curr_module"),"home");
	
	String def_class="";

	String style="";
	
	if(curr_module.equals(module)) 
		style="text-alignment:left; background-color:#428bca; color: white;   ";
	 else 
		style="text-alignment:left; background-color:#white; color: black;    ";
		
	
	 return		"<button class=\"btn btn-sm\" onclick=\"openModule('"+module+"')\" style=\""+style+"\" >"+
	 					"<img src=\"img/modules/"+module+".png\" border=0 width=16 height=16>"+ menu_title_by_lang+
				 "</button>";
		
		
}




//***********************************
public String printMenu(Connection conn, HttpServletRequest request, HttpSession session) {
//***********************************

	StringBuilder sb=new StringBuilder();
	
	String curr_lang=nvl((String) session.getAttribute("curr_lang"),"");
	String curr_domain=nvl((String) session.getAttribute("curr_domain"),"");
	String userid=""+(Integer) session.getAttribute("userid");
	String username=nvl((String) session.getAttribute("username"),"");
	String userfname=nvl((String) session.getAttribute("userfname"),"");
	String userlname=nvl((String) session.getAttribute("userlname"),"");
	
	


  	ArrayList<String[]> langArr=(ArrayList<String[]>) session.getAttribute("langArr");
  	
  	String lang_combo=makeComboArr(langArr, "", "size=1  id=langCombo onchange=\"setUserLang()\" ", curr_lang, 0);
  	
  	ArrayList<String[]> bindlist=new ArrayList<String[]>();
    
  	String sql="select id, domain_name from tdm_test_domain where is_active='YES' order by 2";
  	if (!checkrole(session, "ADMIN")) {
  		bindlist.add(new String[]{"INTEGER",userid});
  		sql="select id, domain_name from tdm_test_domain d where is_active='YES' and exists (select 1 from tdm_test_domain_user where user_id=? and domain_id=d.id) order by 2";
  	}
  		
  	
  	ArrayList<String[]> domainArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);

  	String domain_combo=makeComboArr(domainArr, "", "id=domainCombo onchange=\"setUserDomain()\" ", curr_domain, 0);
  	
  	
  	sb.append("<table border=0 cellspacing=1 cellpadding=1 width=\"100%\">");
  	sb.append("<tr bgcolor=#DFDFD1>");
  	
	for (int m=0;m<moduleArr.size();m++) {
		String module=moduleArr.get(m)[MODULE_FLD_NAME];
		String module_roles=getModuleRoles(conn, session, module);
		
		if (!checkroleAny(session, module_roles))  continue;
		
		sb.append("<td>");
		sb.append(newMenuItem(conn, session, module));
		sb.append("</td>");
		
	}
	
	
	sb.append("<td align=right width=\"100%\">");

	  	sb.append("<table>");
	  	sb.append("<tr>");
	  	
	  	sb.append("<td width=20></td>");
	  	sb.append("<td align=center>");
		sb.append("<a href=\"http://www.infobox.com.tr\" target=_new><img src=\"img/infobox-logo.png\" border=0 height=32></a>");
		sb.append("</td>");
		sb.append("<td width=20></td>");
	  	
		sb.append("<td align=right>");
		sb.append("<span class=badge> Domain</span>");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(domain_combo);
		sb.append("</td>");
		
		sb.append("<td align=right>");
		sb.append("<span class=badge> Language</span>");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(lang_combo);
		sb.append("</td>");
		
		
		
		sb.append("<td  nowrap>");
		sb.append(" <span class=badge> "+username+ " </span>");
		sb.append("</td>");
		
		sb.append("<td  nowrap>");
		sb.append("<img src=\"img/icons/logout.png\" border=0 width=24 height=24 onclick=logout()>");
		sb.append("</td>");
		
		
		sb.append("<td width=20></td>");
		
		sb.append("</tr>");
		sb.append("</table>");
  	
  	sb.append("</td>");
  	
  	sb.append("</tr>");
  	sb.append("</table>");


	return sb.toString();
}

//********************************************
void setUserLang(Connection conn, HttpSession session, String lang) {
	
	
	session.setAttribute("curr_lang", lang);
	
	String userid=""+(Integer) session.getAttribute("userid");
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="update tdm_user set lang=? where id=?";
	
	bindlist.add(new String[]{"STRING",lang});
	bindlist.add(new String[]{"INTEGER",userid});
	
	execDBConf(conn, sql, bindlist);
	
	
	
	
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

String start_char="\"";
String end_char="\"";
String middle_char=".";

//*************************************************************
private Connection getconn(Connection connconf, String env_id) {
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",env_id});
	
	String sql="select db_driver, db_connstr, db_username, db_password from tdm_envs where id=?";
	ArrayList<String[]> recs=getDbArrayConf(connconf, sql, 1, bindlist);
	
	if (recs.size()==0) {
		System.out.println("Exception@getconn : Environment parameters cannot be retrieved. Environment id : "+env_id);
		return null;
	}
	
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
		
		ret1=getconn(db_driver, db_connstr, db_username, db_password, test_sql);
			

	return ret1;
	}

//*************************************************************
private Connection getconn(String db_driver, String db_connstr, String db_username, String db_password, String test_sql) {
	Connection ret1=null;
	
	
	
	try {
		Class.forName(db_driver);
		Connection conn = DriverManager.getConnection(db_connstr, db_username, db_password);
		
		Statement stmt = conn.createStatement();
		ResultSet rset = stmt.executeQuery(test_sql);
		while (rset.next()) {rset.getString(1);	}

		ret1=conn; 
		
		if(conn!=null && conn.getMetaData().getIdentifierQuoteString().trim().length()>0) 
			try {
				start_char=conn.getMetaData().getIdentifierQuoteString();
				end_char=start_char;
				middle_char=nvl(conn.getMetaData().getCatalogSeparator(),".");
			} catch(Exception e) {
				e.printStackTrace();
			}
		
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

//**************************************************************
public String codehtml(String a) {
//**************************************************************
//if (nvl(a,"").length()==0) return "";
if (a==null) return "";
return a.replaceAll("\"", "&quot;");
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


	//********************************************************************
ArrayList<String[]> getArrayForList(Connection conn, HttpSession session, String id, String sql, String env_or_method_id, boolean use_cache) {
	ArrayList<String[]> arr=new ArrayList<String[]>();
	
	
	String source_type="DATABASE";
	
	if (env_or_method_id.contains("-")) {
		source_type="METHOD";
		env_or_method_id=env_or_method_id.replace("-", "");
	}

	if (use_cache)
		arr=(ArrayList<String[]>) session.getAttribute(id);
	else 
		arr=null;
	
	if (arr==null) {
		
		arr=new ArrayList<String[]>();
		
		
		if (sql.toLowerCase().indexOf("select")<10 && sql.toLowerCase().indexOf("select")>-1)
			{
			
				
				ArrayList<String[]> bindlist=new ArrayList<String[]>();
				
				arr=getDbArrayApp(conn, env_or_method_id, sql, Integer.MAX_VALUE, bindlist, null);
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
		
		session.setAttribute(id, arr);
	} //if (arr==null)
	
	return arr;
}

//********************************************************************
String makeList(Connection conn, HttpSession session, String id, String sql, String curr_value, String additional, int width, String env_or_method_id, String field_mode, boolean use_cache) {
	StringBuilder sb=new StringBuilder();
	
	
	ArrayList<String[]> arr=getArrayForList(conn, session, id, sql, env_or_method_id, use_cache);
	
	
	
	
	if (field_mode.equals("EDITABLE"))
		sb.append(makeComboArr(arr, "", "id=\""+id+"\" "+additional, curr_value, width));
	else if (field_mode.equals("READONLY")) {
		sb.append(makeComboArr(arr, "", "id=\""+id+"\" disabled "+additional, curr_value, width));
	}
	else {
		ArrayList<String[]> targetArr=new ArrayList<String[]>();
		String[] arrx=curr_value.split("\\|::\\|");
		for (int i=0;i<arrx.length;i++)
			if (arrx[i].trim().length()>0) targetArr.add(new String[]{arrx[i]});
		
		sb.append(makePickList("0","search_of_"+id, arr, targetArr, "", "", ""+additional,"EDITABLE"));
	}
		
	
	return sb.toString();

}
//**************************************************************
public String makeComboArr(ArrayList<String[]> arr, String name, String additional, String curr_value, int width) {
//**************************************************************
//String a="<div>";

String v_width="100%";
if (width>0) v_width=""+width+"px"; 
if (width<0) v_width=""+Math.abs(width)+"%";



	String a="<select style=\"width:"+v_width+"; \" class=\"form-control\" #SIZE#  "+additional+">";
	
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
		
		a=a+"<option "+selected+" value=\""+codehtml(val)+"\">" +codehtml(cap)+ "</option>";	
	}
	
	//a=a+"</select></div>";
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
	public int checkuser(Connection conn, String username, String password) {
	//*************************************************************
	int ret1=0;
	
	String p_authentication_method=nvl(getParamByName(conn, "AUTHENTICATION_METHOD"),"LOCAL");
	
	if (username.equals("admin")) 
		p_authentication_method="LOCAL";
	else {
		String sql=sql="select authentication_method from tdm_user where valid='Y' and upper(username)=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"STRING",username.toUpperCase()});
		ArrayList<String[]>  res=getDbArrayConf(conn, sql, 1, bindlist);
		
		String user_authentication_method="SYSTEM";
		if (res.size()>0) 
			user_authentication_method=res.get(0)[0];
		
		
		
		if (!user_authentication_method.equals("SYSTEM"))  
			p_authentication_method=user_authentication_method;
		
	}
	
	
	System.out.println("p_authentication_method :  " + p_authentication_method);

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
		rolevar=nvl((String) session.getAttribute("hasrole_"+role_name),"false");;
		if (rolevar.equals("true")) ret1=true;
	} catch(Exception e) {	}
	
	return ret1;
	}


	//*************************************************************
	public boolean checkroleAny(HttpSession session, String role_names) {
	//*************************************************************
	// skip check role for admin
	if (nvl((String) session.getAttribute("username"),"-").equals("admin")) return true;
	
	//if no role required (home), return true
	if (role_names.trim().length()==0 || role_names.trim().equals("ANY")) return true;		
			
	boolean hasany=false;
	
	String[] rolesArr=role_names.split(",");
	for (int i=0;i<rolesArr.length;i++) {
		if (checkrole(session,rolesArr[i])) {
			hasany=true;
			break;
		}
	}
	
	return hasany;
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
	sb.append("<input type=\"text\" "+disabled+" id=\""+id+"\" class=\"form-control\" value=\""+codehtml(curr_val)+"\" "+additional+" >");
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
	sb.append(makeComboArr(arrF, "", "id=\"formula_type_"+id+"\"   onchange=\"setDateFormulaPeriodCountField('"+id+"');\" ", formula_type, 150));
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
		sb.append("<div class=\"col-md-3\" style=\"white-space: nowrap;\" align=right> <font color=blue><small>From :</small></font> ");
		sb.append("<input "+start_checked+" type=checkbox id=\"ch_from_of_"+id+"\" onclick=\"setDateTimeVisibility(this,'search_start','"+id+"');\">");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeDate("0","search_start_"+id, curr_val_start, additional, "SEARCH_START"));
		sb.append("</div>");
		sb.append("</div>");
				
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" style=\"white-space: nowrap;\" align=right> <font color=blue><small>To :</small></font> ");
		sb.append("<input "+end_checked+" type=checkbox id=\"ch_to_of_"+id+"\" onclick=\"setDateTimeVisibility(this,'search_end','"+id+"');\">");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\" >");
		sb.append(makeDate("0","search_end_"+id, curr_val_end, additional, "SEARCH_END"));
		sb.append("</div>");
		sb.append("</div>");
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" style=\"white-space: nowrap;\" align=right> <font color=blue><small>Formula :</small></font> ");
		sb.append("<input "+formula_checked+" type=checkbox id=\"ch_formula_of_"+id+"\" onclick=\"setDateTimeVisibility(this,'formula','"+id+"');\">");
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
		String max_val,
		String additional
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
		sb.append("<td><input "+start_checked+" type=checkbox id=\"ch_from_of_"+id+"\" onclick=\"setNumberVisibility(this,'search_start','"+id+"');\"> :</td>");
		sb.append("<td>");
		sb.append(makeNumber("0","search_start_"+id, curr_val_start, "", "SEARCH_START", 
				fixed_length, 
				decimal_length,
				grouping_char,
				decimal_char,
				currency_symbol,
				min_val,
				max_val,
				additional));
		sb.append("</td>");
		
		sb.append("<td width=80px; align=right><font color=blue>To :</font></td>");
		sb.append("<td><input "+end_checked+" type=checkbox id=\"ch_to_of_"+id+"\" onclick=\"setNumberVisibility(this,'search_end','"+id+"');\"> : </td>");
		sb.append("<td>");
		sb.append(makeNumber("0","search_end_"+id, curr_val_end, "", "SEARCH_END",
				fixed_length, 
				decimal_length,
				grouping_char,
				decimal_char,
				currency_symbol,
				min_val,
				max_val,
				additional
				));
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
				max_val,
				additional));
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
	if (month==1 || month==3 || month==5 || month==7 || month==8 || month==10 || month==12) max_day=31;
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
	 
	//sb.append("<td><span class=\"glyphicon glyphicon-calendar\"></span></td>");
	sb.append("<td>"+makeComboArr(arrDay, "", disabled + script+size_1+"  id=datepicker_day_of_"+id, ""+day, 70)+"</td>");
	sb.append("<td>"+makeComboArr(arrMonth, "", disabled + script+size_1+" id=datepicker_month_of_"+id, ""+month, 100)+"</td>");
	sb.append("<td>"+makeComboArr(arrYear, "", disabled + script+size_1+" id=datepicker_year_of_"+id, ""+year, 85)+"</td>");

	if (hour_part.length()>0) {
		ArrayList<String[]> arrHour=new ArrayList<String[]>();
		ArrayList<String[]> arrMinute=new ArrayList<String[]>();
		ArrayList<String[]> arrSecond=new ArrayList<String[]>();
		
		for (int i=0;i<24;i++) arrHour.add(new String[]{""+i,""+i});
		for (int i=0;i<60;i++) {arrMinute.add(new String[]{""+i,""+i}); arrSecond.add(new String[]{""+i,""+i});}
		
		sb.append("<td><span class=\"glyphicon glyphicon-dashboard\"></span></td>");
		sb.append("<td>"+makeComboArr(arrHour, "", disabled + script+size_1+" id=datepicker_hour_of_"+id, ""+hour, 70)+"</td>");
		sb.append("<td><big><big>:</big></big><td>");
		sb.append("<td>"+makeComboArr(arrMinute, "", disabled + script+size_1+" id=datepicker_minute_of_"+id, ""+minute, 70)+"</td>");
		sb.append("<td><big><big>:</big></big><td>");
		sb.append("<td>"+makeComboArr(arrSecond, "", disabled + script+size_1+" id=datepicker_second_of_"+id, ""+second, 70)+"</td>");
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
		String max_val,
		String additional
		) {
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

	
	String disabled="";
	if (field_mode.equals("READONLY")) disabled="disabled";

	sb.append(
  		"  <input type=hidden   id=\""+id+"\" value=\""+curr_val+"\" min_val=\""+min_val+"\" max_val=\""+max_val+"\" "+js_script_code+" "+additional+" > \n"+
		"   \n"+
		"  <table border=0 cellspacing=0 cellpadding=0> \n"+
		"  <tr> \n"+
		"  <td> \n"+
		"  	<input type=\"text\" "+disabled+" id=\""+id+"_fixed\" value=\""+curr_val_fixed+"\" size="+fixed_length+" maxlength="+fixed_length+" style=\"text-align: right;\"  grouping=\""+grouping_char+"\"  onfocus=onNumericFieldEnter(this,'fixed') onblur=onNumericFieldExit(this,'fixed')  > \n"+
		"  </td> \n");
	
	if (decimal_char.length()>0 && Integer.parseInt(decimal_length)>0)
		sb.append("  <td><b>"+decimal_char+"</b></td> \n");
	
	if (!nvl(decimal_length,"0").equals("0"))
		sb.append(
			"  <td> \n"+
			"  <input type=\"text\" "+disabled+" id=\""+id+"_decimal\" value=\""+curr_val_decimal+"\" size="+decimal_length+" maxlength="+decimal_length+" style=\"text-align: left;\"   onfocus=onNumericFieldEnter(this,'decimal') onblur=onNumericFieldExit(this,'decimal')> \n"+
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
String makeCheckbox(String table_id, String id, String curr_value, String additional) {
	return makeCheckbox(table_id, id, curr_value, additional, "EDITABLE");
}


//********************************************************************
String makeCheckbox(
		String table_id, 
		String id, 
		String curr_value, 
		String additional, 
		String field_mode
		) {
	StringBuilder sb=new StringBuilder();
		
	if (field_mode.equals("SEARCH")) {
		ArrayList<String[]> arr=new ArrayList<String[]>();
		arr.add(new String[]{"ALL","Any"});
		arr.add(new String[]{"YES","Yes"});
		arr.add(new String[]{"NO","No"});
		
		sb.append(makeComboArr(arr, "", "size=1 id=\""+id + "\" "+additional, nvl(clearHtml(curr_value),"ALL"), 120));
	}
	else {
		
		String disabled="";
		if (!field_mode.equals("EDITABLE")) disabled="disabled";

		String checked="";
		if (curr_value.equals("YES")) checked="checked";
		sb.append("<div class=\"checkbox\"><label>");
		sb.append("<input type=hidden id=\""+id+"\" value=\""+clearHtml(curr_value)+"\"  "+additional+">");
		
		sb.append("<input type=\"checkbox\" "+disabled+" id=\"checkbox_of_flexfield_"+id+"\" "+checked+"  value=\""+clearHtml(curr_value)+"\"   onclick=setCheckboxValue(this,'"+id+"') > ");
		sb.append("</label></div>");

	}
	
	  
	
	return sb.toString();

}


//********************************************************************
String clearHtml(String instr) {
	
	StringBuilder sb=new StringBuilder();
	sb.append(instr);
	
	ArrayList<String[]> replArr=new ArrayList<String[]>();
	
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
	return makePickList(table_id, id, source_arr, picked_arr, picklist_header, event_listener, "","EDITABLE");
}

//***********************************************
String makePickList(
		String table_id,
		String id, 
		ArrayList<String[]> source_arr, 
		ArrayList<String[]> picked_arr, 
		String picklist_header, 
		String event_listener,
		String additional,
		String field_mode) {
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> source_arr_edited=new ArrayList<String[]>();
	source_arr_edited.addAll(source_arr);
	
	/*
	for (int i=source_arr.size()-1;i>=0;i--) {
		for (int j=0;j<picked_arr.size();j++) {
			if (source_arr.get(i)[0].equals(picked_arr.get(j)[0])) {
				picked_arr.set(j, source_arr_edited.get(i));
				source_arr_edited.remove(i);
				break;
			}		
		}
	}
	*/
	
	String curr_val="";
	for (int i=0;i<picked_arr.size();i++) {
		String a_val=picked_arr.get(i)[0];
		if (i>0) curr_val=curr_val+"|::|";
		curr_val=curr_val+a_val;
	}
	
	if (picklist_header.length()>0) {
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-12 active\">");
		sb.append("<b><span class=\"label label-info\">"+picklist_header+"</label></b>"); 
		sb.append("</div>");
		sb.append("</div>");
	}
	sb.append("<input type=hidden id=\""+id+"\" value=\""+codehtml(curr_val)+"\"  "+additional+">");
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
	
	if (!field_mode.equals("EDITABLE")) {
		add_all_disabled="disabled";
		remove_all_disabled="disabled";
	}
	
	sb.append("<button disabled class=\"btn btn-sm btn-default\" id=\"bt_add_one_"+id+"\" onclick=\"pickListAction('"+table_id+"','"+id+"','ADD_ONE');\"><span class=\"glyphicon glyphicon-step-forward\"></span></button>");
	sb.append("<br>");
	sb.append("<button "+add_all_disabled+" class=\"btn btn-sm btn-default\" id=\"bt_add_all_"+id+"\" onclick=\"pickListAction('"+table_id+"','"+id+"','ADD_ALL');\"><span class=\"glyphicon glyphicon-fast-forward\"></span></button>");
	
	sb.append("<br>");
	
	sb.append("<button disabled class=\"btn btn-sm btn-default\" id=\"bt_remove_one_"+id+"\" onclick=\"pickListAction('"+table_id+"','"+id+"','REMOVE_ONE');\"><span class=\"glyphicon glyphicon-step-backward\"></span></button>");
	sb.append("<br>");
	sb.append("<button "+remove_all_disabled+" class=\"btn btn-sm btn-default\" id=\"bt_remove_all_"+id+"\" onclick=\"pickListAction('"+table_id+"','"+id+"','REMOVE_ALL');\"><span class=\"glyphicon glyphicon-fast-backward\"></span></button>");
	
	sb.append("</div>"); 
	
	ArrayList<String[]> editedPickedArr=new ArrayList<String[]>();
	for (int i=0;i<picked_arr.size();i++) {
		String[] item=picked_arr.get(i);
		
		if (item.length>1) {
			editedPickedArr.add(item);
			continue;
		}
		
		String caption=item[0];
		
		for (int t=0;t<source_arr.size();t++) {
			System.out.println("checking : "+caption+" with "+source_arr.get(t)[0]);
			if (source_arr.get(t)[0].equals(caption)) {
				System.out.println("!!! FOUND ");
				if (source_arr.get(t).length>1) caption=source_arr.get(t)[1];
				break;
			}
		}
		
		editedPickedArr.add(new String[]{item[0],caption});
	}
	
	sb.append("<div class=\"col-md-5\"  align=left>");
	sb.append(makeComboArr(editedPickedArr, "", disabled+" size=5 id=\"target_list_"+id+"\" onclick=\"setPicklistButtons('TARGET','"+id+"');\" onDblClick=\"pickListAction('"+table_id+"','"+id+"','REMOVE_ONE');\" ", "", -100));
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
	sb.append("<img width=18 height=18 src=\"img/conf/"+icon+"\"> <b> "+title + "</b>");
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
String addTab(String id,ArrayList<String[]> tabItems, String active_tab_id) {
	
	StringBuilder sb=new StringBuilder();
	StringBuilder sbTitle=new StringBuilder();
	StringBuilder sbBody=new StringBuilder();
	
	String active_id=active_tab_id;
	if (active_id.length()==0 && tabItems.size()>0) active_id=tabItems.get(0)[0];
	
		

	for (int i=0;i<tabItems.size();i++) {
		String tab_item_id=tabItems.get(i)[0];
		String tab_item_title=tabItems.get(i)[1];
		String tab_item_body=tabItems.get(i)[2];
		String tab_item_icon=tabItems.get(i)[3];
		String tab_item_onclick="";
		
		
		if (tabItems.get(i).length==5) tab_item_onclick=tabItems.get(i)[4];
		
		
		String jsonclick="";
		if (tab_item_onclick.length()>0) 
			jsonclick=" onclick=\""+tab_item_onclick+"\" ";
		
		if (tab_item_id.equals(active_id))
			sbTitle.append("<li  role=\"presentation\" class=active >");
		else 
			sbTitle.append("<li  role=\"presentation\" >");
		
		sbTitle.append("<a href=\"#"+tab_item_id+"\"  "+jsonclick+"  aria-controls=\""+tab_item_id+"\" role=\"tab\" data-toggle=\"tab\">");
		sbTitle.append("<img src=\"img/conf/"+tab_item_icon+"\" width=16 height=16>");
		sbTitle.append("<small>"+tab_item_title+"</small>");
		sbTitle.append("</a>");
		sbTitle.append("</li>");
		
		if (tab_item_id.equals(active_id))
			sbBody.append("<div class=\"tab-pane active\" role=\"tabpanel\" id=\""+tab_item_id+"\" >");
		else 
			sbBody.append("<div class=\"tab-pane\" role=\"tabpanel\" id=\""+tab_item_id+"\" >"); 
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
	//sb.append("<br>");
	sb.append(sbBody.toString());
	sb.append("</div>");
	
	sb.append("</ul>"); 
	
	
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
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colGeneral","General","","general.png","javascript:makeGeneralParameterList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colDomains","Domain","","domain.png","javascript:makeDomainList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colLangs","Language","","lang.png","javascript:makeLangList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colStrings","String","","string.png","javascript:makeStringList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colFlexFields","Fields","","field.png","javascript:makeFlexFieldList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colForms","Forms","","form.png","javascript:makeFormList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colPermissions","Permission","","permission.png","javascript:makePermissionList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colUsers","User","","user.png","javascript:makeUserList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colGroups","Group","","group.png","javascript:makeGroupList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colEmailTemplates","Email","","email.png","javascript:makeEmailTemplateList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colDatabases","Database","","database.png","javascript:makeDatabaseList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colMethods","Method","","method.png","javascript:makeMethodList()"});
	if (checkrole(session, "ADMIN"))
		collapseItems.add(new String[]{"colFlows","Flow","","flow.png","javascript:makeFlowList()"});
	

	
	sb.append(addTab("tdmConfigurationMenu",collapseItems,""));

	
	
	return sb.toString();
}


//*****************************************************************
boolean doLoginAttempt(Connection conn, HttpSession session, String input_username, String input_password) {
	
	
	String username=decrypt(input_username);
	String password=decrypt(input_password);


	
	int user_id=checkuser(conn,username,password);

	if (user_id==0) {
		session.setAttribute("invalid_user_attempt", "true");
		return false;
	}
	
	
	

	String sql="select fname, lname, email, lang, authentication_method,domain_id,module from tdm_user where valid='Y' and id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	ArrayList<String[]> res=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",""+user_id});
	

	res=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (res==null || res.size()==0) {
		session.setAttribute("invalid_user_attempt", "true");
		return false;
	}

	String fname=res.get(0)[0];
	String lname=res.get(0)[1];
	String email=res.get(0)[2];
	String lang=res.get(0)[3];
	//String authentication_method=res.get(0)[4];
	String domain_id=res.get(0)[5];
	String module=res.get(0)[6];
	
	
	session.setAttribute("username", username);	
	session.setAttribute("userid", user_id);	
	session.setAttribute("userfname", fname);	
	session.setAttribute("userlname", lname);	
	session.setAttribute("useremail", email);	
	session.setAttribute("curr_lang", lang);
	session.setAttribute("curr_domain", domain_id);
	session.setAttribute("curr_module", module);
	//session.setAttribute("authentication_method", authentication_method);
	
	
	
	
	
	
	
	sql="select shortcode from tdm_user_role ur, tdm_role r where ur.role_id=r.id and user_id=" + user_id;
	
	bindlist=new ArrayList<String[]>();
	res=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	for (int i=0;i<res.size();i++) {
		session.setAttribute("hasrole_"+res.get(i)[0], "true");
	}
	
	loadUserPermissions(conn,session,""+user_id);
	
	initFlexFields(conn,session);
	
	
	
	sql="select lang, lang_desc from mad_lang order by 2";
	bindlist.clear();
	ArrayList<String[]> langArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	session.setAttribute("langArr", langArr);
	
	
	
	session.setAttribute("invalid_user_attempt", null);
	
	return true;
}


//*****************************************************************
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

//*********************************************************************************************
void loadUserPermissions(Connection conn, HttpSession session, String user_id) {

	ArrayList<String[]> permList=getUserPermissions(conn, session, user_id);
	
	for (int i=0;i<permList.size();i++) {
		String permission_id=permList.get(i)[0];
		String permission_name=permList.get(i)[1];

		session.setAttribute("haspermission_id_"+permission_id, "true"); 
		session.setAttribute("haspermission_name_"+permission_name, "true"); 
	}
	
}

//*********************************************************************************************
ArrayList<String[]> getUserPermissions(Connection conn, HttpSession session, String user_id) {
	
	String sql="select group_id from mad_group_members where member_type='USER' and member_id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",user_id});
	ArrayList<String[]> grpArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	ArrayList<String[]> permList=new ArrayList<String[]>();
	session.setAttribute("permission_group_id_list","");
	for (int i=0;i<grpArr.size();i++) {
		String group_id=grpArr.get(i)[0];
		ArrayList<String[]> permGrp=getPermissionOfGroup(conn,session,group_id);
		
		for (int p=0;p<permGrp.size();p++) {
			String permission_id=permGrp.get(p)[0];
			String permission_name=permGrp.get(p)[1];
			if (permList.contains(permission_name)) continue;
			permList.add(new String[]{permission_id,permission_name});
		}
		
	}
	
	
	
	return permList;
}


//*********************************************************************************************
ArrayList<String[]> getPermissionOfGroup(Connection conn, HttpSession session, String group_id) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	String group_id_list=(String) session.getAttribute("permission_group_id_list");
	//to prevent infinit loops
	if (group_id_list.contains("("+ group_id +")")) return ret1;
	
	String sql="select permission_id , permission_name  from mad_group_permission m, mad_permission p  	" +
				"	where  group_id=? 	" + 
				"	and permission_id=p.id   ";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",group_id});
	
	ArrayList<String[]> permArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	for (int i=0;i<permArr.size();i++) {
		String permission_id=permArr.get(i)[0];
		String permission_name=permArr.get(i)[1];
		ret1.add(new String[]{permission_id,permission_name});
	}
	
	group_id_list=group_id_list+"("+group_id+")";
	session.setAttribute("permission_group_id_list",group_id_list);
	
	return ret1;
}

//*********************************************************************************
boolean checkLogin(Connection conn, HttpSession session) {
	
	String curruser=nvl((String) session.getAttribute("username"),"");
	
	if (curruser.length()==0) return false;
	
	return true;
}
//*********************************************************************************
String fillLoginBox(Connection conn, HttpSession session) {
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	
	
	
	sb.append("<div class=\"col-md-6	\">");
	
		sb.append("<div style=\"margin-bottom: 25px\" class=\"input-group\">");
		sb.append("	<span class=\"input-group-addon\"><i class=\"glyphicon glyphicon-user\"></i></span>");
		sb.append("	<input id=\"login_username\"  type=\"text\" autofocus class=\"form-control\" name=\"username\" value=\"\" placeholder=\"enter username\">");                            
		sb.append("</div>");
		sb.append("<div style=\"margin-bottom: 25px\" class=\"input-group\">");
		sb.append("	<span class=\"input-group-addon\"><i class=\"glyphicon glyphicon-lock\"></i></span>");
		sb.append("	<input id=\"login_password\" type=\"password\" class=\"form-control\" name=\"password\" >");
		sb.append("</div>");
	
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-6\">");
	sb.append("<img src=\"img/infobox-logo.png\" border=0>");
	sb.append("</div>");

	sb.append("</div>");
	
	
	

	return sb.toString();
}


//***********************************************************************************
void logoutFromSystem(Connection conn, HttpSession session) {

	session.setAttribute("username", "");	
	session.setAttribute("userid", 0);	
	session.setAttribute("userfname","");	
	session.setAttribute("userlname", "");	
	session.setAttribute("useremail", "");	
	session.setAttribute("curr_lang", null);
	session.setAttribute("hostname", "");
	session.setAttribute("curr_module", "");
	session.setAttribute("curr_domain", "");
	
	session.setAttribute("langArr", null);

	session.removeAttribute("FLEX_FIELDS_ARR");
	
	String sql="select shortcode from tdm_role";
	ArrayList<String[]> allRoles=getDbArrayConf(conn, sql, Integer.MAX_VALUE, new ArrayList<String[]>());
	
	
	for (int i=0;i<allRoles.size();i++) 
		session.setAttribute("hasrole_"+allRoles.get(i)[0], "false");
	
	Enumeration<String> attributeNames= session.getAttributeNames();
	
	 while(attributeNames.hasMoreElements()) {
         String current = (String) attributeNames.nextElement();

         System.out.println(current + "=" + session.getAttribute(current));            

         session.removeAttribute(current);     
     }   
		
		
	//response.sendRedirect("default.jsp");

}


//********************************************
void setUserDomain(Connection conn, HttpSession session, String domain_id) {
	
	
	session.setAttribute("curr_domain", domain_id);
	
	String userid=""+(Integer) session.getAttribute("userid");
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="update tdm_user set domain_id=? where id=?";
	
	bindlist.add(new String[]{"INTEGER",domain_id});
	bindlist.add(new String[]{"INTEGER",userid});
	
	execDBConf(conn, sql, bindlist);
	
	
	
	
}


//*********************************************************************************
String openModule(Connection conn, HttpSession session, String module) {
	
	StringBuilder sb=new StringBuilder();
	
	String module_to_open=module;
	
	if (module_to_open.equals("CURRENT"))
		module_to_open=nvl((String) session.getAttribute("curr_module"),"home");
	
	String required_roles=getModuleRoles(conn,session,module_to_open);
	boolean has_role=checkroleAny(session, required_roles);
	
	if (!has_role) {
		sb.append("Restricted area. Need to have one of these roles ["+required_roles+"] to access.");
		return sb.toString();
	}
	
	session.setAttribute("curr_module", module_to_open);
	
	
	String userid=""+(Integer) session.getAttribute("userid");
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="update tdm_user set module=? where id=?";
	
	bindlist.add(new String[]{"STRING",module_to_open});
	bindlist.add(new String[]{"INTEGER",userid});
	
	execDBConf(conn, sql, bindlist);
	
	
	int module_id=getModuleIdByName(module_to_open);
	String module_type=moduleArr.get(module_id)[MODULE_FLD_MODULE_TYPE];
	
	boolean is_tree=false;
	
	//if (module_to_open.equals("home") || module_to_open.equals("administration"))
	if (module_type.equals("TREE"))
		is_tree=true;
	
	
	
	if (is_tree) {

		
		sb.append("<div class=row>");

			//--------------------------------------------
			sb.append("<div class=\"col-md-4\"  style=\"min-height: 1000px; overflow-x: scroll; overflow-y: scroll;\">");
	
				sb.append("<div class=row>");
					sb.append("<div id=moduleTreeToolBoxDiv  class=\"col-md-12\">");
					sb.append("</div>");
				sb.append("</div>");
				
				sb.append("<div class=row>");
				sb.append("<div id=moduleTreeDiv  class=\"col-md-12\">");
				sb.append("</div>");
				sb.append("</div>");

			sb.append("</div>");

			//--------------------------------------------
			sb.append("<div class=\"col-md-8\"  style=\"min-height: 1000px; overflow-x: scroll; overflow-y: scroll;\">");
				sb.append("<div id=moduleContentDiv  class=\"col-md-12\" >");
				
				sb.append(makeModuleContent(conn, session));
				
				sb.append("</div>");
			sb.append("</div>");

		sb.append("</div>");
	}
	else {

		sb.append("<div class=row>");
		
		sb.append("<div id=moduleContentDiv  class=\"col-md-12\"  style=\"min-height: 1000px; overflow-x: scroll; overflow-y: scroll;\">");
		
		sb.append(makeModuleContent(conn, session));
		
		sb.append("</div>");
		
		sb.append("</div>");
	}
	
	
	

	return sb.toString();
}


//*********************************************************************************
String makeModuleTreeToolbox(Connection conn, HttpSession session) {
	
	StringBuilder sb=new StringBuilder();
	
	String module=getCurrentModule(session);
	
	sb.append("makeModuleTreeToolbox of "+module);
	
	return sb.toString();
}


//*********************************************************************************
String getCurrentModule(HttpSession session) {
	return nvl((String) session.getAttribute("curr_module") ,"home");	
}
//*********************************************************************************
String getCurrentDomain(HttpSession session) {
	return nvl((String) session.getAttribute("curr_domain") ,"0");
}

//*********************************************************************************
String getCurrentTreeId(HttpSession session) {
	String module=getCurrentModule(session);
	String domain_id=getCurrentDomain(session);
	
	return nvl((String) session.getAttribute("curr_tree_id_for_"+module+"_"+domain_id) ,"0");
}

//*********************************************************************************
void setCurrentTreeId(HttpSession session, String tree_id) {
	String module=getCurrentModule(session);
	String domain_id=getCurrentDomain(session);
	
	session.setAttribute("curr_tree_id_for_"+module+"_"+domain_id ,tree_id);
}

//*********************************************************************************
String makeModuleTree(Connection conn, HttpSession session) {
	
	StringBuilder sb=new StringBuilder();
	
	String module=getCurrentModule(session);

	sb.append(makeModuleTreeRecursive(conn,session,getCurrentModule(session),getCurrentDomain(session),"0",0));
	
	return sb.toString();
}


//*********************************************************************************
String makeModuleContent(Connection conn, HttpSession session) {
	
	StringBuilder sb=new StringBuilder();
	
	String module=getCurrentModule(session);
	
	if (module.equals("administration")) {
		sb.append(makeModuleContentForAdministration(conn,session));
	}
	else 
	sb.append("content of module ["+module+"] is under construction... ");
	
	return sb.toString();
}

//*********************************************************************************
String makeModuleContentForAdministration(Connection conn, HttpSession session) {
	
	if (!checkrole(session, "TEST_ADMIN") && !checkrole(session, "ADMIN")) return "Unauthorized access attempt!";
	
	StringBuilder sb=new StringBuilder();
	
	sb.append(loadConfigurationMenu(conn,session));
	
	return sb.toString();
}




//*********************************************************************************
String makeModuleTreeRecursive(
		Connection conn, 
		HttpSession session, 
		String module,
		String domain_id,
		String tree_id,
		int level
		) {
	StringBuilder sb=new StringBuilder();
	
	
			
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"STRING",module});
	bindlist.add(new String[]{"INTEGER",domain_id});
	bindlist.add(new String[]{"LONG",tree_id});


	
	String sql="select tree_title,tree_type, checked_out_by from tdm_test_tree where module=? and domain_id=? and  id=?";
	
	ArrayList<String[]> treeArr=new ArrayList<String[]>();
	
	if (tree_id.equals("0")) {
		treeArr.add(new String[]{"[Root]","container","0"});
	}
	else
		treeArr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	
	String  tree_title="";
	String  tree_type="";
	String  checked_out_by="";
	
	if(treeArr.size()==0) {
		 tree_title="[tree node notfound"+tree_id+"]";
		 tree_type="container";
		 checked_out_by="0";
	}
	else {
		 tree_title=treeArr.get(0)[0];
		 tree_type=treeArr.get(0)[1];		
		 checked_out_by=treeArr.get(0)[2];		
	}
	
	String is_expanded=nvl((String) session.getAttribute("is_exp_"+tree_id),"NO");
	String active_tree_id=getCurrentTreeId(session);
	
	String userid=""+(Integer) session.getAttribute("userid");
	boolean is_checked_out=false;
	boolean is_checked_out_by_current_user=false;
	
	if (!checked_out_by.equals("0")) {
		is_checked_out=true;
		if (checked_out_by.equals(userid)) 
			is_checked_out_by_current_user=true;
	}
	
	sb.append("<div id=\"div_of_tree_"+tree_id+"\">");

	sb.append("<input type=hidden id=level_of_tree_"+tree_id+" value=\""+level+"\">");
	
	sb.append("<table width=\"100%\" border=0 cellspacing=0 cellpadding=0>");
	sb.append("<tr>");

	sb.append("<td width=20></td>");
	
	sb.append("<td nowrap valign=top>");
	
	String div_color="default";
	if (active_tree_id.equals(tree_id))
		div_color="#f4e400";
 	
	sb.append("<div id=\"title_div_of_tree_"+tree_id+"\" style=\"font-family: monospace; background-color:"+div_color+";\">");

	if (tree_type.equals("container")) {
		if (is_expanded.equals("YES")) 
			sb.append("<img src=\"img/icons/node_expanded.png\" width=12 height=12 onclick=\"collapseTree('"+tree_id+"')\">");
		else {
			boolean has_child=false;
			sql="select 1 from tdm_test_tree where module=? and domain_id=? and parent_tree_id=? limit 0,1";
			bindlist.clear();
			bindlist.add(new String[]{"STRING",getCurrentModule(session)});
			bindlist.add(new String[]{"INTEGER",getCurrentDomain(session)});
			bindlist.add(new String[]{"LONG",tree_id});
			
			ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
			if (arr.size()==1) has_child=true;
			
			if (has_child)
				sb.append("<img src=\"img/icons/node_collapsed.png\" width=12 height=12  onclick=\"expandTree('"+tree_id+"')\">");
			else 
				sb.append("<img src=\"img/icons/node_fixed.png\" width=12 height=12>");

		}
			
	}
	else 
		sb.append("<img src=\"img/icons/node_fixed.png\" width=12 height=12>");
	
	
	
	sb.append(" <a href=\"javascript:setActiveTree('"+tree_id+"');\">");
	sb.append(" <img src=\"img/icons/node_type_"+tree_type+".png\" width=12 height=12>");
	sb.append(" ");
	
	if (is_checked_out) {
		if (is_checked_out_by_current_user)
			sb.append("<img src=\"img/icons/checked_out_by_me.png\" width=16 height=16 border=0>");
		else 
			sb.append("<img src=\"img/icons/checked_out.png\" width=16 height=16 border=0>");
		
		sb.append(" ");
	}
	
	
	
	if (!isClipBoardEmpty(session)) {
		String clipboard_id=getClipboardId(session);
		if (clipboard_id.equals(tree_id)) {
			String clipboard_action=getClipboardAction(session);
			if (clipboard_action.equals("COPY"))
				sb.append("[<img src=\"img/icons/edit_copy.png\" width=16 height=16 border=0>]");
			else 
				sb.append("[<img src=\"img/icons/edit_cut.png\" width=16 height=16 border=0>]");

			sb.append(" ");
		}
		
	}
	
	
	if (tree_type.equals("container")) {
		sb.append("<b>");
		sb.append(limitString(clearHtml(tree_title),120));
		sb.append("</b>");		
	}
	else {
		
		sb.append("<i>");
		sb.append(limitString(clearHtml(tree_title),120));
		sb.append("</i>");				
	}
	
	sb.append("</a>");

	
	sb.append("</div>");
	

	if (is_expanded.equals("YES")) {
		
		
		sql="select id  "+
			" from tdm_test_tree "+
			" where module=? and domain_id=? and parent_tree_id=? and tree_type!='step' order by  order_by ";
		
		bindlist.clear();
		bindlist.add(new String[]{"STRING",module});
		bindlist.add(new String[]{"INTEGER",domain_id});
		bindlist.add(new String[]{"LONG",tree_id});
		
		
		ArrayList<String[]> childTreeArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		
		for (int i=0;i<childTreeArr.size();i++) 
			sb.append(makeModuleTreeRecursive(conn, session, module, domain_id, childTreeArr.get(i)[0],level+1));
		
	}
	
	
	sb.append("</td>");
	sb.append("</tr>");
	sb.append("</table>");
	
	sb.append("</div>");
	
	return sb.toString();
}

//**************************************************************************************
void expandTree(Connection conn, HttpSession session, String tree_id) {
	session.setAttribute("is_exp_"+tree_id, "YES");
}

//**************************************************************************************
void collapseTree(Connection conn, HttpSession session, String tree_id) {
	
	session.removeAttribute("is_exp_"+tree_id);
	
}

//**************************************************************************************
String redrawTree(Connection conn, HttpSession session, String tree_id, String level) {
	StringBuilder sb=new StringBuilder();

	int level_int=0;
	try{level_int=Integer.parseInt(level);} catch(Exception e) {}
	
	
	
	sb.append(makeModuleTreeRecursive(conn,session,getCurrentModule(session),getCurrentDomain(session),tree_id, level_int));
	
	
	return sb.toString();
}

//*********************************************************************************
String makeTreeContent(Connection conn, HttpSession session,  String tree_id) {
	
	String module=getCurrentModule(session);
	String domain=getCurrentDomain(session);
	
	return makeTreeContent(conn, session, module, domain, tree_id);
}

//*********************************************************************************
String makeTreeContent(Connection conn, HttpSession session, String module, String domain, String tree_id) {
	
	StringBuilder sb=new StringBuilder();

	if (tree_id.equals("0")) {
		sb.append(".");
		return sb.toString();
	}

	
	String sql="select tree_type, tree_title from tdm_test_tree where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",tree_id});

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==0) {
		sb.append("Tree node ["+tree_id+"] not found");
		return sb.toString();
	}
	
	String tree_type=arr.get(0)[0];
	String tree_title=arr.get(0)[1];
	
	boolean is_editable_bool=isCheckinAvailable(conn, session, tree_id);
	
	String is_editable="NO";
	if (is_editable_bool) is_editable="YES";
	
	if (tree_type.equals("container")) 
		sb.append(makeTreeContentContainer(conn,session, module, domain, tree_id,tree_type, tree_title,is_editable));
	else 
		sb.append(makeTreeContentElement(conn,session, module, domain, tree_id, tree_type, tree_title,is_editable));

	return sb.toString();
}

//*********************************************************************************
String getUserFullNameById(Connection conn, HttpSession session, String user_id) {
	
	String sql="select concat(fname,' ',lname) from tdm_user where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INT",user_id});

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr==null || arr.size()==0) return "user ["+user_id+"] not found";
	
	return arr.get(0)[0];
	
}
//*********************************************************************************
String limitString(String instr, int limit) {
	if(instr==null) return "";
	if (instr.length()<=limit) return instr;
	return instr.substring(0,limit)+"...";
}

//*********************************************************************************
String getTreeElementPath(Connection conn, HttpSession session, String tree_id) {

	StringBuilder sb=new StringBuilder();

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select parent_tree_id from tdm_test_tree where id=?";
	
	String next_tree_id=tree_id;
	
	while(true) {
		bindlist.clear();
		bindlist.add(new String[]{"LONG",next_tree_id});

		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		String parent_tree_id=getTreeAttributeValue(conn, session, next_tree_id, "parent_tree_id");
		
		if (nvl(parent_tree_id,"0").equals("0")) break;
		
		String tree_title=getTreeAttributeValue(conn, session, parent_tree_id, "tree_title");
		
		sb.insert(0, "<font color=gray>"+clearHtml(tree_title)+"</font>");
		
		sb.insert(0, "<font color=blue><b>/</b></font>");
		
		next_tree_id=parent_tree_id;
	}
	
	String module=getTreeAttributeValue(conn, session, tree_id, "module");
	
	
	
	String module_name=getModuleName(conn, session, module);
	sb.insert(0, "<font color=gray>["+module_name+"]</font>");
	
	
		
	return sb.toString();
	
}
//*********************************************************************************
String makeTreeContentToolBox(
		Connection conn, 
		HttpSession session, 
		String tree_id,
		String tree_type,
		String tree_title,
		String checked_out_by_user_id,
		String version,
		String creation_date,
		String checkin_date,
		String checkout_date,
		String checkin_note,
		String is_editable
		) {
	
	
	StringBuilder sb=new StringBuilder();
	
	boolean is_root=false;
	if (tree_id.equals("0")) is_root=true;
	
	

	String module=getCurrentModule(session);
	
	
	String curr_userid=""+(Integer) session.getAttribute("userid");
	
	boolean checked_out_by_someone=false;
	boolean checked_out_by_me=false;
	
	
	String full_path=getTreeElementPath(conn,session,tree_id);

	
	//
	
	
	sb.append("<table width=\"100%\">");
	
	sb.append("<tr>");
	sb.append("<td>");
	
		sb.append("<table width=\"100%\" border=0 cellspacing=0 cellpadding=0>");
		
		sb.append("<tr bgcolor=white>");
		sb.append("<td colspan=2 nowrap>");
		sb.append("<big><b>");
		sb.append(limitString(full_path,200));
		sb.append("</b></big>");
		sb.append("</td>");
		sb.append("</tr>");
		
		
		sb.append("<tr>");
		sb.append("<td>");
		sb.append(makeText("header_tree_id", tree_id, " readonly style=\"background-color:darkblue; text-align:center; color:white; font-weight:bold; \"", 150));
		sb.append("</td>");
		sb.append("<td nowrap  width=\"100%\">");
		sb.append(makeText("header_tree_title", limitString(clearHtml(tree_title),200), " readonly style=\"background-color:darkblue; color:white;  \"", 0));
		sb.append("</td>");
		sb.append("</tr>");
		
		
		
		sb.append("</table>");
	
	
	sb.append("</td>");
	sb.append("</tr>");

	
	
	sb.append("<tr bgcolor=gray>");
	sb.append("<td>");
	
	
		
		sb.append("<table>");
		sb.append("<tr>");
		
		
		sb.append("<td>");
		sb.append("<button class=\"btn btn-md  btn-success\" onclick=setActiveTree('"+tree_id+"')>");
		sb.append("<font color=white><span class=\"glyphicon glyphicon-refresh\"></span></font>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("<td width=10></td>");
		
		
		if (curr_userid.equals(checked_out_by_user_id)) {
			
			checked_out_by_someone=true;
			checked_out_by_me=true;
			
			sb.append("<td>");
			sb.append("<button class=\"btn btn-md  btn-primary\" onclick=checkinTreeNode('"+tree_id+"')>");
			sb.append("<font color=lightgreen><span class=\"glyphicon glyphicon-saved\"></span></font>");
			sb.append(" Check In");
			sb.append("</button>");
			sb.append("</td>");
			
			if (tree_type.equals("element")) {
				sb.append("<td>");
				sb.append("<button class=\"btn btn-md  btn-default\" onclick=saveTreeNode('"+tree_id+"')>");
				sb.append("<font color=green><span class=\"glyphicon glyphicon-floppy-save\"></span></font>");
				sb.append(" Save Changes");
				sb.append("</button>");
				sb.append("</td>");
			}
			
			
		}
		else  {
			
			if (checked_out_by_user_id.equals("0")) {
				sb.append("<td>");
				sb.append("<button class=\"btn btn-md  btn-primary\" onclick=checkoutTreeNode('"+tree_id+"')>");
				sb.append("<font color=white><span class=\"glyphicon glyphicon-open\"></span></font>");
				sb.append(" Check Out");
				sb.append("</button>");
				sb.append("</td>");
			} 
			else {
				checked_out_by_someone=true;
				
				//admin ve test_admin checkout u iptal edebilir.
				if (checkrole(session, "ADMIN") || checkrole(session, "TEST_ADMIN") ) {
					sb.append("<td>");
					sb.append("<button class=\"btn btn-md  btn-default\" onclick=cancelCheckinForTreeNode('"+tree_id+"')>");
					sb.append("<font color=red><span class=\"glyphicon glyphicon-floppy-remove\"></span></font>");
					sb.append(" Cancel Checkout");
					sb.append("</button>");
					sb.append("</td>");
				}
			}
			
			
				
		}
		
		
	if (!is_root) {
			
			if (checked_out_by_me) {
				
				sb.append("<td width=10></td>");
				
				sb.append("<td>");
				sb.append("<button class=\"btn btn-md btn-default\"  onclick=renameTreeNode('"+tree_id+"','"+tree_type+"')>");
				sb.append("<font color=blue><span class=\"glyphicon glyphicon-edit\"></span></font>");
				sb.append("</button>");
				sb.append("</td>");
				
				sb.append("<td>");
				sb.append("<button class=\"btn btn-md btn-default\"  onclick=removeTreeNode('"+tree_id+"')>");
				sb.append("<font color=red><span class=\"glyphicon glyphicon-minus\"></span></font>");
				sb.append("</button>");
				sb.append("</td>");
				
				
				
				
			}
			
			
			if (tree_type.equals("element") && module.equals("design")) {
				
				sb.append("<td width=10></td>");
				
				sb.append("<td>");
				sb.append("<button class=\"btn btn-md btn-default\"  onclick=showTestParameter('"+tree_id+"')>");
				sb.append("<font color=black><span class=\"glyphicon glyphicon-cog\"></span></font>");
				sb.append("</button>");
				sb.append("</td>");
			}
		}

	
		
		
		sb.append("</tr>");
		


		sb.append("</table>");
		
	sb.append("</td>");
	sb.append("</tr>");
	
	


	
	
	
	
	
	sb.append("</table>");


	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
		sb.append("<table class=\"table table-bordered table-striped table-condensed\">");
		
		sb.append("<tr>");
		sb.append("<td><b>Created By</b></td>");
		sb.append("<td><b>Creation Date</b></td>");
		sb.append("<td><b>Version</b></td>");
		if (checked_out_by_someone) {
			sb.append("<td><b>Checked out by</b></td>");
			sb.append("<td><b>Checked out date</b></td>");
		}
		else
			sb.append("<td><b>Last check-in note</b></td>");	
		
		sb.append("</tr>");
		
		String curr_user_full_name=getUserFullNameById(conn,session,curr_userid);
		
		sb.append("<tr>");
		
		sb.append("<td>"+clearHtml(curr_user_full_name)+"</td>");
		sb.append("<td>"+creation_date+"</td>");
		
		sb.append("<td align=center>");
		sb.append("<a href=\"javascript:showTreeCheckHistory('"+tree_id+"')\"><span class=badge>"+version+"</span></a>");
		sb.append("</b>");
		sb.append("</td>");

		
		if (checked_out_by_someone) {
			String checked_out_by_full_name =getUserFullNameById(conn,session,checked_out_by_user_id);
			sb.append("<td>"+clearHtml(checked_out_by_full_name)+"</td>");
			sb.append("<td>"+checkout_date+"</td>");
		}
		else	
			sb.append("<td><small>"+limitString(clearHtml(checkin_note), 120) +"</small></td>");
		
		sb.append("</tr>");
		
		
		sb.append("</table>");


	sb.append("</div>");
	sb.append("</div>");
	
	
	
	
	return sb.toString();

}
//*********************************************************************************
String makeTreeContentCommon(Connection conn, HttpSession session, String tree_id, String tree_title, String is_editable) {
	
	StringBuilder sb=new StringBuilder();

	String sql="select tree_type, checked_out_by, version, creation_date, "+
			" DATE_FORMAT(checkin_date,?) checkin_date, "+
			" DATE_FORMAT(checkout_date,?) checkout_date, checkin_note "+
			" from tdm_test_tree where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});

	bindlist.add(new String[]{"LONG",tree_id});

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==0) {
		sb.append("Tree node ["+tree_id+"] not found");
		return sb.toString();
	}
	
	String tree_type=arr.get(0)[0];
	String checked_out_by=arr.get(0)[1];
	String version=arr.get(0)[2];
	String creation_date=arr.get(0)[3];
	String checkin_date=arr.get(0)[4];
	String checkout_date=arr.get(0)[5];
	String checkin_note=arr.get(0)[6];
	
	sb.append("<input type=hidden id=editing_tree_id value="+tree_id+">");
	

	sb.append(makeTreeContentToolBox(
			conn, 
			session, 
			tree_id, 
			tree_type, 
			tree_title, 
			checked_out_by, 
			version, 
			creation_date,
			checkin_date,
			checkout_date,
			checkin_note,
			is_editable
			)); 
	
	

	
	return sb.toString();
}


//*********************************************************************************
String makeTreeContentContainer(
		Connection conn, 
		HttpSession session, 
		String module,
		String domain,
		String tree_id, 
		String tree_type,
		String tree_title, 
		String is_editable
		) {
	
	StringBuilder sb=new StringBuilder();
	
	sb.append(makeTreeContentCommon(conn, session, tree_id, tree_title,is_editable));
	
	
	
	sb.append(makeTreeContentElementList(conn, session, module, domain, tree_id, is_editable));
	
	return sb.toString();
}

//*********************************************************************************
String makeTreeContentElementList(
		Connection conn, 
		HttpSession session, 
		String module,
		String domain,
		String tree_id, 
		String is_editable
		) {
	
	StringBuilder sb=new StringBuilder();
	
	
	ArrayList<String[]> elementArr=getTreeNodes(conn,session,module, domain, tree_id, "all_but_step", false);
	
	if (elementArr.size()==0) {
		sb.append("No element found.");
		return sb.toString();
	}
	
	String userid=""+(Integer) session.getAttribute("userid");
	
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr>");
	sb.append("<td nowrap><b><small></small></b></td>");
	sb.append("<td nowrap><b><small></small></b></td>");
	sb.append("<td nowrap><b><small>#</small></b></td>");
	sb.append("<td nowrap><b><small>Title</small></b></td>");
	sb.append("<td nowrap><b><small>Created By</small></b></td>");
	sb.append("<td nowrap><b><small>Creation Date</small></b></td>");
	sb.append("<td nowrap><b><small>Ver.</small></b></td>");
	sb.append("<td nowrap></td>");
	sb.append("</tr>");
	
	for (int i=0;i<elementArr.size();i++) {
		
		String id=elementArr.get(i)[TREE_FIELD_id];
		String parent_tree_id=elementArr.get(i)[TREE_FIELD_parent_tree_id];
		String tree_title=elementArr.get(i)[TREE_FIELD_tree_title];
		String created_by=getUserFullNameById(conn, session, elementArr.get(i)[TREE_FIELD_created_by]);
		String creation_date=elementArr.get(i)[TREE_FIELD_creation_date];
		String version=elementArr.get(i)[TREE_FIELD_version];
		String checked_out_by=elementArr.get(i)[TREE_FIELD_checked_out_by];
		String tree_type=elementArr.get(i)[TREE_FIELD_tree_type];
		
		String check_in_content="";
		
		
		if (!checked_out_by.equals("0")) {
			if (checked_out_by.equals(userid)) 
				check_in_content="<img src=\"img/icons/checked_out_by_me.png\" border=0 width=24 height=24>";
			else 
				check_in_content="<img src=\"img/icons/checked_out.png\" border=0 width=24 height=24>";
		}
		
		sb.append("<tr>");
		
		sb.append("<td nowrap>"+check_in_content+"</td>");

		sb.append("<td nowrap><a href=\"javascript:setActiveTree('"+id+"')\"><img src=\"img/icons/node_type_"+tree_type+".png\" border=0 width=24 height=24></a></td>");

		sb.append("<td nowrap align=right>");
		sb.append("<a href=\"javascript:setActiveTree('"+id+"')\"><span class=badge>"+id+"</span></a>");
		sb.append("</td>");
		
		if (tree_type.equals("element"))
			sb.append("<td nowrap width=\"100%\"><small>"+clearHtml(tree_title)+"</small></td>");
		else
			sb.append("<td nowrap width=\"100%\"><b><small>"+clearHtml(tree_title)+"</small></b></td>");

		sb.append("<td nowrap><small>"+created_by+"</small></td>");
		sb.append("<td nowrap><small>"+creation_date+"</small></td>");
		sb.append("<td nowrap align=right><small>"+version+"</small></td>");
		
		sb.append("<td nowrap align=center>");
		
		String buttons_disabled="";
		if (is_editable.equals("NO"))  buttons_disabled="disabled";
		
		if (i<elementArr.size()-1) {
			sb.append("<button "+buttons_disabled+" class=\"btn btn-sm btn-default\" onclick=setTreeOrder('"+id+"','"+parent_tree_id+"','DOWN')>");
			sb.append("<font color=blue><span class=\"glyphicon glyphicon-arrow-down\"></span></font>");
			sb.append("</button>");
		}
		
		if (i>0) {
			sb.append("<button "+buttons_disabled+" class=\"btn btn-sm btn-default\" onclick=setTreeOrder('"+id+"','"+parent_tree_id+"','UP')>");
			sb.append("<font color=blue><span class=\"glyphicon glyphicon-arrow-up\"></span></font>");
			sb.append("</button>");
		}
		
		sb.append("</td>");
		



		sb.append("</tr>");
	}
	
	sb.append("</table>");

	
	return sb.toString();
}


//*********************************************************************************

static final int TREE_FIELD_id					=0;
static final int TREE_FIELD_parent_tree_id		=1;
static final int TREE_FIELD_referenced_test_id	=2;
static final int TREE_FIELD_tree_type			=3;
static final int TREE_FIELD_tree_title			=4;
static final int TREE_FIELD_created_by			=5;
static final int TREE_FIELD_creation_date		=6;
static final int TREE_FIELD_version				=7;
static final int TREE_FIELD_checkout_date		=8;
static final int TREE_FIELD_checked_out_by		=9;
static final int TREE_FIELD_checkin_date		=10;
static final int TREE_FIELD_checkin_note		=11;


ArrayList<String[]> getTreeNodes(
		Connection conn,
		HttpSession session,
		String module,
		String domain,
		String starting_parent_tree_id, 
		String tree_type,
		boolean is_recursive
		) {
	return getTreeNodes(conn,session,module,domain,starting_parent_tree_id,tree_type,is_recursive,"");
}

//*********************************************************************************
ArrayList<String[]> getTreeNodes(
		Connection conn,
		HttpSession session,
		String module,
		String domain,
		String starting_parent_tree_id, 
		String tree_type,
		boolean is_recursive,
		String text_to_search
		) {
	ArrayList<String[]> ret1=new ArrayList<String[]>();
	
	
	
	String original_sql="select \n"+
		" id, \n"+
		" parent_tree_id, \n"+
		" referenced_test_id, \n"+
		" tree_type, \n"+
		" tree_title, \n"+
		" created_by, \n"+
		" date_format(creation_date,?) creation_date, \n"+
		" version, \n"+
		" date_format(checkout_date,?) checkout_date, \n"+
		" checked_out_by, \n"+
		" date_format(checkin_date,?) checkin_date, \n"+
		" checkin_note \n"+
		" from tdm_test_tree \n"+
		" where module=? and domain_id=? and parent_tree_id=? ";
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"STRING",mysql_format});

	bindlist.add(new String[]{"STRING",module});
	bindlist.add(new String[]{"INTEGER",domain});
	bindlist.add(new String[]{"LONG",starting_parent_tree_id});
	
	
	String search_sql="";
	ArrayList<String[]> text_search_bindings=new ArrayList<String[]>();
	
	if (text_to_search.length()>0) {
		String[] filters=text_to_search.split(" ");
		for (int s=0;s<filters.length;s++) {
			String a_filter=filters[s];
			if (a_filter.length()==0) continue;
			if (search_sql.length()>0) search_sql=search_sql+" OR ";
			search_sql=search_sql+" upper(tree_title) like upper(?) ";
			text_search_bindings.add(new String[]{"STRING","%"+a_filter+"%"});	
		}
	}
	
	if (text_search_bindings.size()>0) {
		original_sql=original_sql+" AND ("+search_sql+") ";
		bindlist.addAll(text_search_bindings);
	}
	
	original_sql=original_sql+" order by order_by";
	

	String sql=original_sql;
	
	

	
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	for (int i=0;i<arr.size();i++) {
		String res_tree_type=arr.get(i)[TREE_FIELD_tree_type];
		if (nvl(tree_type,"all").toLowerCase().equals("all") || nvl(tree_type,"all").equals(res_tree_type)) {
				ret1.add(arr.get(i));
		} else if (nvl(tree_type,"x").toLowerCase().equals("all_but_step") && !res_tree_type.equals("step")) {
			ret1.add(arr.get(i));
		}
			
		
		if (is_recursive) {
			String id=arr.get(i)[TREE_FIELD_id];
			ret1.addAll(getTreeNodes(conn,session,module, domain, id,tree_type,is_recursive));
		}
	}
	

	
	
	
	return ret1;
}
//*********************************************************************************
String makeTreeContentElement(
		Connection conn, 
		HttpSession session, 
		String module,
		String domain,
		String tree_id, 
		String tree_type,
		String tree_title, 
		String is_editable
		) {
	
	StringBuilder sb=new StringBuilder();

	sb.append(makeTreeContentCommon(conn, session, tree_id, tree_title,is_editable));
	
	
	sb.append(makeFlexForm(conn, session, tree_id, tree_type, is_editable, "vertical",tree_id));
	
	String curr_module=getCurrentModule(session);
	
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();
	
	String id="";
	String collapse_item_title="";
	String collapse_item_body="";
	String collapse_item_icon="";
	String collapse_item_onclick="";
	
	String active_design_detail_tab="";
	
	
	if (module.equals("requirement")) {
		
		active_design_detail_tab=nvl((String) session.getAttribute("active_"+curr_module+"_detail_tab"),"TAB_element_detail_design");
		
		id="TAB_element_detail_design";
		collapse_item_title="Linked Requirements";
		collapse_item_body=makeTreeContentLinkDetails(conn, session, tree_id,  "design", is_editable);
		collapse_item_icon="design.png";
		collapse_item_onclick="setActiveTestDetailsTabId('"+id+"')";
		 
		
		collapseItems.add(new String[]{id,collapse_item_title,collapse_item_body,collapse_item_icon,collapse_item_onclick});
		
		
	}

	
	if (module.equals("design")) {
		
		active_design_detail_tab=nvl((String) session.getAttribute("active_"+curr_module+"_detail_tab"),"TAB_element_detail_steps");
		
		id="TAB_element_detail_steps";
		collapse_item_title="Steps";
		collapse_item_body=makeTreeContentElementDetails(conn, session, tree_id, module, domain, is_editable);
		collapse_item_icon="step.png";
		collapse_item_onclick="setActiveTestDetailsTabId('"+id+"')";
		
		collapseItems.add(new String[]{id,collapse_item_title,collapse_item_body,collapse_item_icon,collapse_item_onclick});
		
		
		
		id="TAB_element_detail_requirements";
		collapse_item_title="Linked Requirements";
		collapse_item_body=makeTreeContentLinkDetails(conn, session, tree_id,  "requirement", is_editable);
		collapse_item_icon="requirement.png";
		collapse_item_onclick="setActiveTestDetailsTabId('"+id+"')";
		 
		
		collapseItems.add(new String[]{id,collapse_item_title,collapse_item_body,collapse_item_icon,collapse_item_onclick});
		
		
	
		
		id="TAB_element_detail_executions";
		collapse_item_title="Executions";
		collapse_item_body=makeTreeContentLinkDetails(conn, session, tree_id,  "execution", is_editable);
		collapse_item_icon="execution.png";
		collapse_item_onclick="setActiveTestDetailsTabId('"+id+"')";
		
		collapseItems.add(new String[]{id,collapse_item_title,collapse_item_body,collapse_item_icon,collapse_item_onclick});
		
		
	
		
		id="TAB_element_detail_bugs";
		collapse_item_title="Linked Bugs";
		collapse_item_body=makeTreeContentLinkDetails(conn, session, tree_id, "bug", is_editable);
		collapse_item_icon="bug.png";
		collapse_item_onclick="setActiveTestDetailsTabId('"+id+"')";
		
		collapseItems.add(new String[]{id,collapse_item_title,collapse_item_body,collapse_item_icon,collapse_item_onclick});
		
		
	}
	
	
	
	if (module.equals("organize")) {
		
		
		active_design_detail_tab=nvl((String) session.getAttribute("active_"+curr_module+"_detail_tab"),"TAB_element_detail_design");
		
		
		id="TAB_element_detail_design";
		collapse_item_title="Assigned Test Cases";
		collapse_item_body=makeTreeContentLinkDetails(conn, session, tree_id,  "design", is_editable);
		collapse_item_icon="design.png";
		collapse_item_onclick="setActiveTestDetailsTabId('"+id+"')";
		 
		
		collapseItems.add(new String[]{id,collapse_item_title,collapse_item_body,collapse_item_icon,collapse_item_onclick});
		
				
		id="TAB_element_detail_groups";
		collapse_item_title="Groups";
		collapse_item_body=makeOrganizationGroupTab(conn, session, tree_id, is_editable);
		collapse_item_icon="group.png";
		collapse_item_onclick="setActiveTestDetailsTabId('"+id+"')";
		
		collapseItems.add(new String[]{id,collapse_item_title,collapse_item_body,collapse_item_icon,collapse_item_onclick});
		
		
	}

	
	StringBuilder sbdet=new StringBuilder();
	
	sbdet.append(addTab("elementDetailsTab",collapseItems,active_design_detail_tab));
	
	sb.append(sbdet.toString());
	
	return sb.toString();
}

//*********************************************************************************
String makeOrganizationGroupToolBox(Connection conn, HttpSession session, String tree_id, String is_editable) {
	StringBuilder sb=new StringBuilder();
	
	String disabled="";
	if (is_editable.equals("NO")) disabled="disabled";
	
	
	sb.append("<table width=\"100%\">");
	
	
	sb.append("<tr bgcolor=gray>");
	
	
	sb.append("<td>");
	sb.append("<button type=button "+disabled+" class=\"btn btn-sm btn-default\" onclick=addNewOrganizationGroup('"+tree_id+"')>");
	sb.append(" <img src=\"img/conf/group.png\" width=16 height=16>");
	sb.append(" <font color=green><span class=\"glyphicon glyphicon-plus\"></span><font>");
	sb.append(" New Group");
	sb.append("</button>");
	sb.append("</td>");
	
	sb.append("<td align=right>");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=makeOrganizationGroupList('"+tree_id+"')>");
	sb.append(" <font color=white><span class=\"glyphicon glyphicon-refresh\"></span><font>");
	sb.append("</button>");
	sb.append("</td>");
	
	
	sb.append("</tr>");
	
	
	sb.append("</table>");
	
	return sb.toString();
}

//*********************************************************************************
String makeOrganizationGroupList(Connection conn, HttpSession session, String tree_id, String is_editable) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select tg.id, group_id, group_name from tdm_test_tree_group tg, mad_group g "+
				"	where group_id=g.id and tree_id=? order by group_name";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.add(new String[]{"LONG",tree_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	if (arr.size()==0) return "No group assigned";
	
	String disabled="";
	if (is_editable.equals("NO")) disabled="disabled";
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	sb.append("<tr class=info>");
	sb.append("<td></td>");
	sb.append("<td><b>Assigned Group</b></td>");
	sb.append("</tr>");
	
	for (int i=0;i<arr.size();i++) {
		
		String org_group_id=arr.get(i)[0];
		String group_id=arr.get(i)[1];
		String group_name=arr.get(i)[2];
		
		sb.append("<tr>");
		
		sb.append("<td>");
		sb.append("<button type=button "+disabled+" class=\"btn btn-sm btn-default\" onclick=removeOrganizationGroup('"+tree_id+"','"+group_id+"')>");
		sb.append(" <font color=red><span class=\"glyphicon glyphicon-minus\"></span><font>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("<td width=\"100%\">");
		sb.append(group_name);
		sb.append("</td>");
		
		sb.append("</tr>");
	}
	
	
	
	sb.append("</table>");	
	
	return sb.toString();
}

//*********************************************************************************
String makeOrganizationGroupTab(Connection conn, HttpSession session, String tree_id, String is_editable) {
	StringBuilder sb=new StringBuilder();
	
	sb.append(makeOrganizationGroupToolBox(conn, session, tree_id, is_editable));
	
	sb.append("<div id=OrganizationGroupDivFor_"+tree_id+">");
	sb.append(makeOrganizationGroupList(conn, session, tree_id, is_editable));
	sb.append("</div>");
	
	return sb.toString();
}

//*********************************************************************************
void setActiveTestDetailsTabId(Connection conn, HttpSession session, String active_id) {
	
	String module=getCurrentModule(session);
	
	session.setAttribute("active_"+module+"_detail_tab", active_id);
}
//*********************************************************************************
String makeTreeContentElementDetails(Connection conn, HttpSession session, String tree_id, String module, String domain, String is_editable) {
	
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> stepsArr=getTreeNodes(conn, session, module, domain, tree_id, "step", false);
	
	sb.append(makeStepsToolBox(conn, session, tree_id,stepsArr, is_editable));
	
	if (stepsArr.size()==0) {
		sb.append("No step found");
		return sb.toString();
	}
	
	String step_buttons_disabled="";
	if (is_editable.equals("NO"))  step_buttons_disabled="disabled";
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	//sb.append("<tr class=info>");
	//sb.append("</tr>");
	
	for (int i=0;i<stepsArr.size();i++) {
		String step_id=stepsArr.get(i)[TREE_FIELD_id];
		String parent_tree_id=stepsArr.get(i)[TREE_FIELD_parent_tree_id];
		String tree_title=stepsArr.get(i)[TREE_FIELD_tree_title];
		String referenced_test_id=stepsArr.get(i)[TREE_FIELD_referenced_test_id];
		
		
		sb.append("<tr>");
		
		sb.append("<td align=right>");
		sb.append("<span class=\"badge\">");
		sb.append(""+(i+1));
		sb.append("</span>");
		sb.append("</td>");
		
		sb.append("<td width=\"100%\">");
		
		
		
		sb.append(makeText(step_id+"_stepTitle", clearHtml(tree_title), step_buttons_disabled+"  name=\"fields_of_tree_"+tree_id+"\"", 0));
		
		if (referenced_test_id.equals("0"))
			sb.append(makeFlexForm(conn, session, step_id, "step", is_editable,"horizontal",tree_id));
		else 	
			sb.append(makeReferenceTestForm(conn, session, step_id, referenced_test_id, is_editable, tree_id));
		sb.append("</td>");
		
		
		if (step_buttons_disabled.length()==0) {
			sb.append("<td nowrap align=center>");
			
			if (i<stepsArr.size()-1) {
				sb.append("<button "+step_buttons_disabled+" class=\"btn btn-sm btn-default\" onclick=setTreeOrder('"+step_id+"','"+tree_id+"','DOWN')>");
				sb.append("<font color=blue><span class=\"glyphicon glyphicon-arrow-down\"></span></font>");
				sb.append("</button>");
			}
			
			if (i>0) {
				sb.append("<button "+step_buttons_disabled+" class=\"btn btn-sm btn-default\" onclick=setTreeOrder('"+step_id+"','"+tree_id+"','UP')>");
				sb.append("<font color=blue><span class=\"glyphicon glyphicon-arrow-up\"></span></font>");
				sb.append("</button>");
			}
			
			sb.append("</td>");
			

			
			sb.append("<td nowrap>");
			sb.append("<button "+step_buttons_disabled+" class=\"btn btn-sm btn-default\" onclick=removeTreeNode('"+step_id+"')>");
			sb.append("<font color=red><span class=\"glyphicon glyphicon-minus\"></span></font>");
			sb.append("</button>");
			sb.append("</td>");
		}
		
		
		
		sb.append("</tr>");
		
		
	}
	
	
	sb.append("</table>");
	
	return sb.toString();
}

//*********************************************************************************
String makeLinkToolBox(Connection conn, HttpSession session, String tree_id, String linked_module,  String is_editable) {
	
	
	StringBuilder sb=new StringBuilder();
	
	String module_name=getModuleName(conn, session, linked_module);
	
	sb.append("<table width=\"100%\">");
	sb.append("<tr bgcolor=gray>");
	sb.append("<td>");

		sb.append("<table>");
		sb.append("<tr>");
		
		if (!linked_module.equals("execution")) {
			String edit_disabled="";
			
			if (is_editable.equals("NO")) edit_disabled="disabled";
			
			sb.append("<td>");
			sb.append("<button "+edit_disabled+" class=\"btn btn-sm btn-default\" onclick=\"linkTreeNode('"+tree_id+"','"+linked_module+"','0')\">");
			sb.append("<img src=\"img/modules/"+linked_module+".png\" border=0 width=16 height=16>");
			sb.append(" <font color=green><span class=\"glyphicon glyphicon-link\"></span></font>");
			sb.append(" Link new "+module_name);
			sb.append("</button>");
			sb.append("</td>");
		}
		
		
		
		
		
		sb.append("</tr>");	
		sb.append("</table>");
	sb.append("</td>");

	sb.append("<td align=right>");
	sb.append("<button class=\"btn btn-sm btn-success\" onclick=\"makeTreeContentLinkList('"+tree_id+"','"+linked_module+"')\">");
	sb.append("<span class=\"glyphicon glyphicon-refresh\"></span>");
	sb.append("</button>");
	sb.append("</td>");
		
	
	
	sb.append("</tr>");	
	sb.append("</table>");
	
	
	
	
	return sb.toString();
}
//*********************************************************************************
ArrayList<String[]> getTreeNodeLinks(
		Connection conn,
		HttpSession session,
		String tree_id,
		String module,
		String linked_module,
		String is_editable) {
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	String sql="select id, tree_id, module, linked_tree_id, linked_tree_id path_tree_id from tdm_test_tree_link where tree_id=? and module=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",tree_id});
	bindlist.add(new String[]{"STRING",linked_module});

	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	//requirement ve design icin iki tarafli liste verilir
	String str=module+","+linked_module;
	if (str.contains("requirement") && str.contains("design")) {
		sql="select id,  tree_id, module, linked_tree_id, tree_id path_tree_id from tdm_test_tree_link where linked_tree_id=? and module=?";

		bindlist.clear();
		bindlist.add(new String[]{"LONG",tree_id});
		bindlist.add(new String[]{"STRING",module});
		
		arr.addAll(getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist));
	}
	
	
	
	
	return arr;
}
//*********************************************************************************
String makeTreeContentLinkDetails(Connection conn, HttpSession session, String tree_id, String linked_module, String is_editable) {
	
	StringBuilder sb=new StringBuilder();
	
	
	sb.append(makeLinkToolBox(conn, session, tree_id, linked_module, is_editable));
	
	sb.append("<div id="+linked_module+"_details_for_"+tree_id+">");
	
	sb.append(makeTreeContentLinkList(conn, session, tree_id, linked_module, is_editable));
	
	sb.append("</div>");
	
	return sb.toString();
}
//*********************************************************************************
String makeTreeContentLinkList(
		Connection conn, 
		HttpSession session, 
		String tree_id, 
		String linked_module, 
		String is_editable) { 

	String curr_module=getCurrentModule(session);
	
	ArrayList<String[]> linksArr=getTreeNodeLinks(conn,session,tree_id, curr_module, linked_module, is_editable);
	
	StringBuilder sb=new StringBuilder();

	String module_name=getModuleName(conn, session, linked_module);
	
	if (linksArr.size()==0) {
		sb.append("No "+module_name+" linked");
		return sb.toString();
	}

	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	sb.append("<tr class=info>");
	if (!linked_module.equals("execution"))
		sb.append("<td><b></b></td>");	
	sb.append("<td></td>");	
	sb.append("<td colspan=2><b>Linked "+module_name+"</b></td>");	
	sb.append("</tr>");
	
	String del_button_disabled="";
	if (is_editable.equals("NO")) del_button_disabled="disabled";
	
	for (int i=0;i<linksArr.size();i++) {
		
		String link_id=linksArr.get(i)[0];
		String from_tree_id=linksArr.get(i)[1];
		String to_module=linksArr.get(i)[2];
		String to_tree_id=linksArr.get(i)[3];
		String path_tree_id=linksArr.get(i)[4];
		
		String to_tree_path=getTreeElementPath(conn, session, path_tree_id);
		String to_tree_title=getTreeAttributeValue(conn, session, path_tree_id, "tree_title");
		
		sb.append("<tr>");
		
		if (!linked_module.equals("execution")) {
			sb.append("<td>");	
			sb.append("<button "+del_button_disabled+" class=\"btn btn-sm btn-default\" onclick=unlinkTreeNode('"+from_tree_id+"','"+linked_module+"','"+to_tree_id+"')>");
			sb.append("<font color=red><span class=\"glyphicon glyphicon-minus\"></span></font>");
			sb.append("</button>");
			sb.append("</td>");	
		}
		
		
		sb.append("<td><span class=badge>"+path_tree_id+"</span></td>");	
		sb.append("<td nowrap>"+to_tree_path+"</font></b></td>");	
		sb.append("<td nowrap width=\"100%\">"+to_tree_title+"</font></b></td>");	
		
		sb.append("</tr>");
	}
	
	
	sb.append("</table>");
	
	return sb.toString();
}
//*********************************************************************************
String makeStepsToolBox(Connection conn, HttpSession session, String tree_id, ArrayList<String[]> stepsArr, String is_editable) {
	
	
	StringBuilder sb=new StringBuilder();
	
	
	sb.append("<table width=\"100%\">");
	sb.append("<tr bgcolor=gray>");
	sb.append("<td>");

		sb.append("<table>");
		sb.append("<tr>");
		
		String edit_disabled="";
		
		if (is_editable.equals("NO")) edit_disabled="disabled";
		
		sb.append("<td>");
		sb.append("<button "+edit_disabled+" class=\"btn btn-sm btn-default\" onclick=addTreeNode('"+tree_id+"','step','new')>");
		sb.append("<img src=\"img/icons/node_type_step.png\" border=0 width=16 height=16>");
		sb.append(" <font color=green><span class=\"glyphicon glyphicon-plus\"></span></font>");
		sb.append(" New Step");
		sb.append("</button>");
		sb.append("</td>");
		
		
		sb.append("<td>");
		sb.append("<button "+edit_disabled+" class=\"btn btn-sm btn-warning\" onclick=addTreeNode('"+tree_id+"','step','ref')>");
		sb.append("<img src=\"img/icons/node_type_element.png\" border=0 width=16 height=16>");
		sb.append(" <font color=green><span class=\"glyphicon glyphicon-plus\"></span></font>");
		sb.append(" Test Call");
		sb.append("</button>");
		sb.append("</td>");

		sb.append("</tr>");	
		sb.append("</table>");

	
	sb.append("</td>");
	sb.append("</tr>");	
	sb.append("</table>");
	
	
	
	
	return sb.toString();
}
//*********************************************************************************
String getTreeAttributeValue(Connection conn, HttpSession session, String tree_id, String attribute) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select "+attribute+" from tdm_test_tree where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"LONG",tree_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==0) return null;
	
	return arr.get(0)[0];
}
//*********************************************************************************
void editTreeNode(Connection conn, HttpSession session, String tree_id, String action) {
	String module=getCurrentModule(session);
	session.setAttribute("CLIPBOARD_TREE_ID_"+module, tree_id);
	session.setAttribute("CLIPBOARD_ACTION_"+module, action);
}
//*********************************************************************************
void pasteTreeNode(Connection conn, HttpSession session, String parent_tree_id) {
	String module=getCurrentModule(session);
	String clipboard_tree_id=nvl((String) session.getAttribute("CLIPBOARD_TREE_ID_"+module),"0");
	String clipboard_action=(String) session.getAttribute("CLIPBOARD_ACTION_"+module);
	
	if (clipboard_tree_id.equals("0")) return;
	
	if (clipboard_tree_id.equals(parent_tree_id)) return;
	
	if (clipboard_action.equals("COPY")) 
		pasteTreeNodeFromCopy(conn, session, parent_tree_id, clipboard_tree_id);
	else
		pasteTreeNodeFromCut(conn, session, parent_tree_id, clipboard_tree_id);
	
}
//*********************************************************************************
void pasteTreeNodeFromCopy(Connection conn, HttpSession session, String parent_tree_id, String clipboard_tree_id) {


	
}

//*********************************************************************************
void pasteTreeNodeFromCut(Connection conn, HttpSession session, String parent_tree_id, String clipboard_tree_id) {

	String sql="update tdm_test_tree set parent_tree_id=? where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"LONG",parent_tree_id});
	bindlist.add(new String[]{"LONG",clipboard_tree_id});
	
	execDBConf(conn, sql, bindlist);
	
	//reset clipboard
	editTreeNode(conn, session, "0", "CUT");
}
//*********************************************************************************
boolean isClipBoardEmpty(HttpSession session) {
	String module=getCurrentModule(session);
	
	String clipboard_tree_id=nvl((String) session.getAttribute("CLIPBOARD_TREE_ID_"+module),"0");
	String clipboard_action=(String) session.getAttribute("CLIPBOARD_ACTION_"+module);
	
	if (clipboard_tree_id.equals("0")) return true;
	
	return false;
}

//*********************************************************************************
String getClipboardId(HttpSession session) {
	String module=getCurrentModule(session);
	
	return  nvl((String) session.getAttribute("CLIPBOARD_TREE_ID_"+module),"0"); 
}

//*********************************************************************************
String getClipboardAction(HttpSession session) {
	String module=getCurrentModule(session);
	
	return  nvl((String) session.getAttribute("CLIPBOARD_ACTION_"+module),"0"); 
}

//*********************************************************************************
String makeTreeToolBox(Connection conn, HttpSession session, String tree_id) {
	
	StringBuilder sb=new StringBuilder();

	boolean is_root=false;
	if (tree_id.equals("0")) is_root=true;
	
	String tree_type=nvl(getTreeAttributeValue(conn,session,tree_id,"tree_type"),"container");
	

	String module=getCurrentModule(session);
	String moduleTitle=getModuleName(conn, session, module);

	sb.append("<table border=0 cellspacing=0 cellpadding=0 width=\"100%\">");
	
	
	sb.append("<tr>");
	sb.append("<td nowrap valign=middle width=\"100%\">");
	sb.append("<img src=\"img/modules/"+module+".png\" width=24 height=24 border=0>");
	sb.append(" <b><big><big>[ "+moduleTitle+" ]</big></big></b>");
	sb.append("</td>");
	sb.append("</tr>");

	sb.append("<tr bgcolor=gray>");
	sb.append("<td>");


		sb.append("<table border=0 cellspacing=0 cellpadding=0 >");
		sb.append("<tr>");
		
		String tree_buttons_disabled="";
		if (tree_type.equals("element")) tree_buttons_disabled="disabled";
	
		
		sb.append("<td>");
		sb.append("<button "+tree_buttons_disabled+" class=\"btn btn-sm btn-success\" onclick=redrawTree('"+tree_id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-refresh\"></span>");
		sb.append("</button>");			
		sb.append("</td>");

		sb.append("<td>");
		sb.append("<button "+tree_buttons_disabled+" class=\"btn btn-sm  btn-default\" onclick=addTreeNode('"+tree_id+"','container')>");
		sb.append("<img src=\"img/icons/node_type_container.png\" border=0 width=16 height=16>");
		sb.append(" <font color=green><span class=\"glyphicon glyphicon-plus\"></span></font>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append("<button "+tree_buttons_disabled+" class=\"btn btn-sm  btn-default\" onclick=addTreeNode('"+tree_id+"','element')>");
		sb.append(" <img src=\"img/icons/node_type_element.png\" border=0 width=16 height=16>");
		sb.append("<font color=green><span class=\"glyphicon glyphicon-plus\"></span></font>");
		sb.append("</button>");
		sb.append("</td>");
		
			
		
		
		sb.append("<td width=20>");
		sb.append("</td>");
		
		
		String copy_cut_disabled="";
		
		if (is_root) 
			copy_cut_disabled="disabled";
		else if (isCheckinAvailable(conn, session, tree_id))  copy_cut_disabled="disabled";
			
		
		sb.append("<td>");
		sb.append("<button "+copy_cut_disabled+" class=\"btn btn-sm  btn-default\" onclick=copyTreeNode('"+tree_id+"')>");
		sb.append(" <img src=\"img/icons/edit_copy.png\" border=0 width=16 height=16>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append("<button "+copy_cut_disabled+" class=\"btn btn-sm  btn-default\" onclick=cutTreeNode('"+tree_id+"')>");
		sb.append(" <img src=\"img/icons/edit_cut.png\" border=0 width=16 height=16>");
		sb.append("</button>");
		sb.append("</td>");
		
		
		String clipboard_id=getClipboardId(session);
		
		String paste_disabled="";
		if (!tree_type.equals("container") || isClipBoardEmpty(session) || clipboard_id.equals(tree_id))
			paste_disabled="disabled";
		
		
		sb.append("<td>");
		sb.append("<button "+paste_disabled+" class=\"btn btn-sm  btn-default\" onclick=pasteTreeNode('"+tree_id+"')>");
		sb.append(" <img src=\"img/icons/edit_paste.png\" border=0 width=16 height=16>");
		sb.append("</button>");
		sb.append("</td>");
		
		
	
	
		/*
		String tree_search_filter=nvl((String) session.getAttribute("tree_search_filter"),"");
		
		
		
		sb.append("<td width=\"100%\">");
		sb.append(makeText("txtTreeSearch", tree_search_filter, "placeholder=\"Search for...\"", 0));
		sb.append("</td>");
	
		sb.append("<td>");
		sb.append("<button class=\"btn btn-sm btn-default\">");
		sb.append("<font color=black><span class=\"glyphicon glyphicon-filter\"></span></font>");
		sb.append("</button>");			
		sb.append("</td>");
		*/
		
		sb.append("</tr>");
		sb.append("</table>");

	
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr bgcolor=gray>");
	sb.append("<td>");
	String tree_search_filter=nvl((String) session.getAttribute("tree_search_filter"),"");
	sb.append(makeText("txtTreeSearch", tree_search_filter, "placeholder=\"Search for...\"", 0));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	
	
	
	sb.append("</table>");


	


	
	return sb.toString();
}

//*********************************************************************************
String makeAddRenameTreeNodeBox(Connection conn, HttpSession session, String parent_tree_id, String tree_type, String mode, String step_type) {
	
	StringBuilder sb=new StringBuilder();

	String module=getCurrentModule(session);
	String module_name=getModuleName(conn, session, module);

	if (mode.equals("NEW")) {
		sb.append("<input type=hidden id=adding_parent_tree_id value="+parent_tree_id+">");
		sb.append("<input type=hidden id=adding_module_name value="+module_name+">");
		sb.append("<input type=hidden id=adding_tree_type value="+tree_type+">");
		sb.append("<input type=hidden id=adding_step_type value="+step_type+">");
		
	} else {
		sb.append("<input type=hidden id=renaming_tree_id value="+parent_tree_id+">");
		sb.append("<input type=hidden id=renaming_module_name value="+module_name+">");
		sb.append("<input type=hidden id=renaming_step_type value="+step_type+">");

		
	}

	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" style=\"background-color:lightgray;\">");
	sb.append("<h4><b>"+getTreeElementPath(conn, session, parent_tree_id)+"</b></h4>");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<hr>");
	
	

	String tree_title="";
	String onkeypressscript="onkeypress=\"if (event.keyCode == 13) {addTreeNodeDO() ; return false;} else return true; \"";
	
	if (mode.equals("RENAME")) {
		tree_title=getTreeAttributeValue(conn, session, parent_tree_id, "tree_title");
		onkeypressscript="onkeypress=\"if (event.keyCode == 13) {renameTreeNodeDO() ; return false;} else return true; \"";
	}
	
	

	sb.append("<div class=row>");

	sb.append("<div class=\"col-md-1\" align=center>");
	sb.append("<img src=\"img/icons/node_type_"+tree_type+".png\" width=48 height=48>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-11\">");
	sb.append(makeText("tree_node_title", tree_title, " autofocus maxLength=250  "+onkeypressscript, 0));
	sb.append("</div>");
	
	
	sb.append("</div>");
	



	if (mode.equals("NEW") && !tree_type.equals("step")) {
		String is_checked="";
		String activate_added_item=nvl((String) session.getAttribute("activate_added_item"),"NO");
		if (activate_added_item.equals("YES"))
			is_checked="checked";
			
		
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-12\">");
		sb.append("<label class=\"checkbox-inline\"><input "+is_checked+" type=\"checkbox\" id=activate_added_item>Go to new item</label>");
		sb.append("</div>");
		sb.append("</div>");
		
	}

	if (tree_type.equals("step") && step_type.equals("ref")) 
		sb.append(makeStepTestReferenceForm(conn, session));
		
	
	return sb.toString();
}

//*********************************************************************************
synchronized String getTS() {
	String ts=""+System.currentTimeMillis();
	try{Thread.sleep(1);} catch(Exception e) {}
	return ts;
}
//*********************************************************************************
String addTreeNodeDO(Connection conn, HttpSession session, 
		String parent_tree_id, 
		String tree_node_title, 
		String tree_type, 
		String referenced_test_id
		) {

		String module=getCurrentModule(session);
		String domain=getCurrentDomain(session);
	
		String tree_id=getTS();
		String curr_userid=""+(Integer) session.getAttribute("userid");
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String sql="select max(order_by)+1 from tdm_test_tree where parent_tree_id=?";
		bindlist.clear();
		bindlist.add(new String[]{"LONG",parent_tree_id});
		
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		int order_by=1;
		try {order_by=Integer.parseInt(arr.get(0)[0]);} catch(Exception e) {}
		
		sql="insert into tdm_test_tree "+
					" (id, parent_tree_id, referenced_test_id, module, domain_id, tree_title, tree_type, created_by, version, checked_out_by, checkout_date, order_by)  "+
					" values (?,?,?,?,?,?,?,?,?,?,now(),?)";
		
		
		bindlist.clear();
		bindlist.add(new String[]{"LONG",tree_id});
		bindlist.add(new String[]{"LONG",parent_tree_id});
		bindlist.add(new String[]{"LONG",referenced_test_id});
		bindlist.add(new String[]{"STRING",module});
		bindlist.add(new String[]{"INTEGER",domain});
		bindlist.add(new String[]{"STRING",tree_node_title});
		bindlist.add(new String[]{"STRING",tree_type});
		bindlist.add(new String[]{"INTEGER",curr_userid});
		bindlist.add(new String[]{"INTEGER","0"});
		bindlist.add(new String[]{"INTEGER",curr_userid});
		bindlist.add(new String[]{"INTEGER",""+order_by});


		boolean is_success=execDBConf(conn, sql, bindlist);
		
		
		if (is_success) 
			expandTree(conn, session, parent_tree_id);
		
		if (!is_success) return "0";
		
		return tree_id;
}


//*********************************************************************************
void renameTreeNodeDO(Connection conn, HttpSession session, String tree_id, String tree_node_title, StringBuilder err) {
		
	boolean is_checkin_available=isCheckinAvailable(conn,session,tree_id);
	
	if (!is_checkin_available) {
		err.append("This node is not available for check in.");
		return;
	}
	
	String active_tree_id=getCurrentTreeId(session);
	
	if (!active_tree_id.equals(tree_id)) {
		err.append("This node is not open for edit. Hacking me? Try harder ;) ");
		return;
	}
	
	
		String sql="update tdm_test_tree set tree_title=? where id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.clear();
		bindlist.add(new String[]{"STRING",tree_node_title});
		bindlist.add(new String[]{"LONG",tree_id});
		
		boolean is_success=execDBConf(conn, sql, bindlist);
		
}

//*********************************************************************************
void removeTreeNodeDO(Connection conn, HttpSession session, String tree_id, String parent_tree_id, boolean force, StringBuilder err) {
		
	String sql="";
	
	boolean is_checkin_available=force || isCheckinAvailable(conn,session,tree_id) || isCheckinAvailable(conn,session,parent_tree_id);
		
		if (!is_checkin_available) {
			err.append("This node is not available for check in.");
			return;
		}
		
		String active_tree_id=getCurrentTreeId(session);
		
		if (!active_tree_id.equals(tree_id) && !active_tree_id.equals(parent_tree_id)) {
			err.append("This node is not open for edit. Hacking me? Try harder ;) ");
			return;
		}
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String tree_type=getTreeAttributeValue(conn, session, tree_id, "tree_type");
		
		if (tree_type.equals("element")) {
			sql="select 1 from tdm_test_tree_link where linked_tree_id=? limit 0,1";
			bindlist.clear();
			bindlist.add(new String[]{"LONG",tree_id});
			
			ArrayList<String[]> linkArr=getDbArrayConf(conn, sql, 1, bindlist);
			if (linkArr.size()==1) {
				err.append("This node is linked to another node. Click <a href=\"javascript:listDependingNodes("+tree_id+")\"><b>here</b></a> to see dependencies. ");
				return;
			}
			
			 
			sql="select 1 from tdm_test_tree_link where linked_tree_id=? limit 0,1";
			bindlist.clear();
			bindlist.add(new String[]{"LONG",tree_id});
			
			ArrayList<String[]> refArr=getDbArrayConf(conn, sql, 1, bindlist);
			if (refArr.size()==1) {
				err.append("This node is referenced by a step. ");
				return;
			}
			
		}
		
		
		
		
		sql="select id from tdm_test_tree where parent_tree_id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"LONG",tree_id});
		
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<arr.size();i++) {
			String child_tree_id=arr.get(i)[0];
			removeTreeNodeDO(conn, session, child_tree_id,tree_id, true, err);
			if (err.length()>0) return;
		}
		
		sql="delete from tdm_test_tree_values where tree_id=?";
				
		bindlist.clear();
		bindlist.add(new String[]{"LONG",tree_id});
		
		boolean is_deleted1=execDBConf(conn, sql, bindlist);
		
		if (!is_deleted1) {
			err.append("flexValues Can not deleted!");
			return;
		}
			
		
		//hem bu testin linklerini, hem de u teste olan linkleri siler
		sql="delete from tdm_test_tree_link where tree_id=? or linked_tree_id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"LONG",tree_id});
		bindlist.add(new String[]{"LONG",tree_id});
		
		boolean is_deleted2=execDBConf(conn, sql, bindlist);
		
		if (!is_deleted2) {
			err.append("Node Links Can not deleted!");
			return;
		}
			
	
		sql="delete from tdm_test_tree where id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"LONG",tree_id});
		
		boolean is_deleted3=execDBConf(conn, sql, bindlist);
		
		if (!is_deleted3) {
			err.append("Can not deleted!");
			return;
		}
			
		
}


//*********************************************************************************
boolean isCheckoutAvailable(Connection conn, HttpSession session, String tree_id) {
		
		if (checkrole(session, "ADMIN")) return true;
		if (checkrole(session, "TEST_ADMIN")) return true;
	
		String userid=""+(Integer) session.getAttribute("userid");	
	
		String sql="select checked_out_by from tdm_test_tree where id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.clear();
		bindlist.add(new String[]{"LONG",tree_id});
		
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		if (arr==null || arr.size()==0) {
			System.out.println("isCheckoutAvailable:tree record not found.");
			return false;
		}
		
		String checked_out_by=arr.get(0)[0];
		
		System.out.println("checked_out_by="+checked_out_by);
		System.out.println("userid="+userid);
		
		if (!checked_out_by.equals("0") && checked_out_by.equals(userid)) {
			System.out.println("isCheckoutAvailable:already check out by current user.");
			return false;
		}
		


		return true;
}


//*********************************************************************************
void makeTreeCheckHistory(Connection conn,HttpSession session,String tree_id,String action_type,String action_by,String action_note,String version) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="insert into tdm_test_tree_check_history "+
			" (ID, tree_id, action_type, action_by, action_date, action_note, version) "+
			" values (?, ?, ?, ?, now(), ?, ?) ";
	String hist_id=getTS();
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",hist_id});
	bindlist.add(new String[]{"LONG",tree_id});
	bindlist.add(new String[]{"STRING",action_type});
	bindlist.add(new String[]{"INTEGER",action_by});
	bindlist.add(new String[]{"STRING",action_note});
	bindlist.add(new String[]{"INTEGER",version});
	
	execDBConf(conn, sql, bindlist);

}


//*********************************************************************************
boolean makeCheckoutTreeNodeControll(Connection conn, HttpSession session, String tree_id, StringBuilder checkres) {
		
		boolean is_checkout_available=isCheckoutAvailable(conn,session,tree_id);
		
		checkres.append("<input type=hidden id=checkoutavailabilityresult value="+is_checkout_available+">");
		
		if (!is_checkout_available) {
			checkres.append("This node is not available for check out.");
			
					
			String sql="";
			
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			
			return false;
		}
		else {
			checkres.append("Check-out is available. Click button to check-out for edit.");
		}
		return true;
		
}

//*********************************************************************************
boolean checkoutTreeNodeDO(Connection conn, HttpSession session, String tree_id, StringBuilder cherr) {
		
		boolean is_checkout_available=isCheckoutAvailable(conn,session,tree_id);
		
		if (!is_checkout_available) {
			cherr.append("This node is not available for check out.");
			return false;
		}
	
		String sql="";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String userid=""+(Integer) session.getAttribute("userid");		

		sql="update tdm_test_tree set checked_out_by=?, checkout_date=now(), checkin_date=null where id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",userid});
		bindlist.add(new String[]{"LONG",tree_id});
		
		boolean is_ok= execDBConf(conn, sql, bindlist);
		
		if (!is_ok) {
			cherr.append("Cannot be checked out due to technical issues.");
			return false;
		}
		
		String version=getTreeAttributeValue(conn, session, tree_id, "version");
		
		makeTreeCheckHistory(conn,session,tree_id,"CHECKOUT",userid,"CHECKED OUT",version);
		
		return true;
		
}

//*********************************************************************************
String makeCheckinTreeNodeBox(Connection conn, HttpSession session, String tree_id) {
	
	StringBuilder sb=new StringBuilder();



	sb.append("<input type=hidden id=checkin_tree_id value="+tree_id+">");
		

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append("Enter check in note");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append(makeText("checkin_note", "", " autofocus maxLength=250  ", 0));
	sb.append("</div>");
	sb.append("</div>");
	



	
	return sb.toString();
}


//*********************************************************************************
boolean isCheckinAvailable(Connection conn, HttpSession session, String tree_id) {
		
		String userid=""+(Integer) session.getAttribute("userid");
		
	
		String sql="select 1 from tdm_test_tree where checked_out_by=? and id=?";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",userid});
		bindlist.add(new String[]{"LONG",tree_id});
		
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		if (arr==null || arr.size()==0) return false;
		
		return true;
}

//*********************************************************************************
boolean checkinTreeNodeDO(Connection conn, HttpSession session, String tree_id, String checkin_note, StringBuilder cherr) {
		
		boolean is_checkin_available=isCheckinAvailable(conn,session,tree_id);
		
		if (!is_checkin_available) {
			cherr.append("This node is not available for check in.");
			return false;
		}
		
		String active_tree_id=getCurrentTreeId(session);
		
		if (!active_tree_id.equals(tree_id)) {
			cherr.append("This node is not open for edit. Hacking me? Try harder ;) ");
			return false;
		}
	
		String sql="";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String userid=""+(Integer) session.getAttribute("userid");		

		sql="update tdm_test_tree "+
			" set "+
			" checked_out_by=0, checkout_date=null, checkin_date=now(), version=version+1,checkin_note=? "+
			" where id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"STRING",checkin_note});
		bindlist.add(new String[]{"LONG",tree_id});
		
		boolean is_ok= execDBConf(conn, sql, bindlist);
		
		if (!is_ok) {
			cherr.append("Cannot be checked in due to technical issues.");
			return false;
		}
		
		String new_version=getTreeAttributeValue(conn, session, tree_id, "version");
		
		makeTreeCheckHistory(conn,session,tree_id,"CHECKIN",userid,checkin_note,new_version);
		
		return true;
		
}



//*********************************************************************************
boolean saveTreeNodeDO(Connection conn, HttpSession session, String tree_id, String flexFormContent, StringBuilder cherr) {
		
		boolean is_checkin_available=isCheckinAvailable(conn,session,tree_id);
		
		if (!is_checkin_available) {
			cherr.append("This node is not available for check in.");
			return false;
		}
		
		String active_tree_id=getCurrentTreeId(session);
		
		if (!active_tree_id.equals(tree_id)) {
			cherr.append("This node is not open for edit. Hacking me? Try harder ;) ");
			return false;
		}
	
		String sql="";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
				
		
		StringBuilder sb=new StringBuilder();
		
		sb.append(decrypt(flexFormContent));
		
		//System.out.println("flexFormContent : \n"+sb.toString());
		
		
		String tag_tree_id_BEGIN="<tree_id>";
		String tag_tree_id_END="</tree_id>";
		
		String tag_flexField_id_BEGIN="<flexField_id>";
		String tag_flexField_id_END="</flexField_id>";
		
		String tag_flexField_value_BEGIN="<flexField_value>";
		String tag_flexField_value_END="</flexField_value>";
		
		ArrayList<String[]> flexArr=new ArrayList<String[]>();
		
		ArrayList<String[]> paramsArr=new ArrayList<String[]>();
		
		int loc_tree_id_start=0;

		
		while (true) {
			
			loc_tree_id_start++;
			
			loc_tree_id_start=sb.indexOf(tag_tree_id_BEGIN, loc_tree_id_start);
			
			if (loc_tree_id_start==-1) break;
			
			int loc_tree_id_end=sb.indexOf(tag_tree_id_END, loc_tree_id_start+tag_tree_id_BEGIN.length());
			
			String flex_tree_id="";
			if (loc_tree_id_end>loc_tree_id_start) flex_tree_id=sb.substring(loc_tree_id_start+tag_tree_id_BEGIN.length(),loc_tree_id_end);
			if (flex_tree_id.length()==0) continue;
			//System.out.println("flex_tree_id="+flex_tree_id);
			
			int loc_flexField_id_BEGIN=sb.indexOf(tag_flexField_id_BEGIN, loc_tree_id_end+tag_tree_id_END.length());
			
			if (loc_flexField_id_BEGIN==-1) break;
			
			int loc_flexField_id_END=sb.indexOf(tag_flexField_id_END, loc_flexField_id_BEGIN+tag_flexField_id_BEGIN.length());
			
			if (loc_flexField_id_END==-1) continue;
			
			String flex_field_id="";
			if (loc_flexField_id_END>loc_flexField_id_BEGIN) 
				flex_field_id=sb.substring(loc_flexField_id_BEGIN+tag_flexField_id_BEGIN.length(),loc_flexField_id_END);
			if (flex_field_id.length()==0) continue;
			//System.out.println("flex_field_id="+flex_field_id);
			
			
			
			int loc_flexField_value_BEGIN=sb.indexOf(tag_flexField_value_BEGIN, loc_flexField_id_END+tag_flexField_id_END.length());
			
			if (loc_flexField_value_BEGIN==-1) break;
			
			int loc_flexField_value_END=sb.indexOf(tag_flexField_value_END, loc_flexField_value_BEGIN+tag_flexField_value_BEGIN.length());
			
			
			String flex_field_value="";
			if (loc_flexField_id_END>loc_flexField_id_BEGIN) 
				flex_field_value=sb.substring(loc_flexField_value_BEGIN+tag_flexField_value_BEGIN.length(),loc_flexField_value_END);

			//System.out.println("flex_field_value="+flex_field_value);
			
			int i=sb.indexOf("<dataType>",loc_flexField_id_END)+"<dataType>".length();
			String dataType=sb.substring(i,i+1);

			if (dataType.equals("F"))
				flexArr.add(new String[]{flex_tree_id,flex_field_id,flex_field_value});
			else {

				String step_id=flex_tree_id.split("\\.")[0];
				String referenced_tree_id=flex_tree_id.split("\\.")[1];
				String parameter_id=flex_field_id;
				String parameter_value=flex_field_value;
				
				paramsArr.add(new String[]{step_id,referenced_tree_id,parameter_id,parameter_value});
			}
				
		}
		
		
		
		
		StringBuilder sbSql=new StringBuilder();
		
		bindlist.clear();
		
		String userid=""+(Integer) session.getAttribute("userid");
		
		initFlexFields(conn, session);

		boolean is_ok=false;
		
		for (int i=0;i<flexArr.size();i++) {
			String flex_tree_id=flexArr.get(i)[0];
			String flex_field_id=flexArr.get(i)[1];
			String flex_field_value=flexArr.get(i)[2];


			String flex_entry_type="stepTitle";
			int flex_field_arr_id=getFlexFieldArrId(flex_field_id);
			if (flex_field_arr_id>-1)
				flex_entry_type=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_ENTRY_TYPE];
			
			
			
			if (flex_entry_type.equals("stepTitle")) {
				sbSql.setLength(0);
				sbSql.append("update tdm_test_tree set tree_title=? where id=?");
				bindlist.clear();
				bindlist.add(new String[]{"STRING",flex_field_value});
				bindlist.add(new String[]{"LONG",flex_tree_id});
				
				
				//System.out.println("Executing :"+sbSql.toString());
				is_ok=execDBConf(conn, sbSql.toString(), bindlist);
				if (!is_ok) {
					cherr.append("Exception : "+sbSql.toString());
					return false;
				}

			} 
			else {
				sbSql.setLength(0);
				sbSql.append("delete from tdm_test_tree_values where tree_id=? and flex_field_id=?");
				bindlist.clear();
				bindlist.add(new String[]{"LONG",flex_tree_id});
				bindlist.add(new String[]{"INTEGER",flex_field_id});
				//System.out.println("Executing :"+sbSql.toString());
				is_ok=execDBConf(conn, sbSql.toString(), bindlist);
				if (!is_ok) {
					cherr.append("Exception : "+sbSql.toString());
					return false;
				}
				
				sbSql.setLength(0);
				
				if (flex_entry_type.equals("DATE") || flex_entry_type.equals("DATETIME")) 
					sbSql.append("insert into tdm_test_tree_values (id,tree_id,flex_field_id,val_datetime,created_by,creation_date) values (?,?,?,str_to_date(?,'%e.%c.%Y %H:%i:%S'),?,now())");
				else if (flex_entry_type.equals("NUMBER")) {
					flex_field_value=nvl(flex_field_value,"0.0");
					sbSql.append("insert into tdm_test_tree_values (id,tree_id,flex_field_id,val_numeric,created_by,creation_date) values (?,?,?,?,?,now())");
				}
				else if (flex_entry_type.equals("MEMO")) 
					sbSql.append("insert into tdm_test_tree_values (id,tree_id,flex_field_id,val_memo,created_by,creation_date) values (?,?,?,?,?,now())");
				else
					sbSql.append("insert into tdm_test_tree_values (id,tree_id,flex_field_id,val_string,created_by,creation_date) values (?,?,?,?,?,now())");
				
				bindlist.clear();
				bindlist.add(new String[]{"LONG",""+getTS()});
				bindlist.add(new String[]{"LONG",flex_tree_id});
				bindlist.add(new String[]{"INTEGER",flex_field_id});
				//System.out.println("Updating with "+flex_field_value);
				bindlist.add(new String[]{"STRING",flex_field_value});
				bindlist.add(new String[]{"INTEGER",userid});
				
				//System.out.println("Executing :"+sbSql.toString());
				is_ok=execDBConf(conn, sbSql.toString(), bindlist);
				if (!is_ok) {
					cherr.append("Exception : "+sbSql.toString());
					return false;
				}
				
				
			}
			
		}


		String CHECK_PARAMETER_SQL="select 1 from tdm_test_call_parameter_values  where tree_id=? and referenced_test_id=? and parameter_id=?";
		String UPDATE_PARAMETER_SQL="update tdm_test_call_parameter_values set parameter_value=?  where tree_id=? and referenced_test_id=? and parameter_id=?";
		String INSERT_PARAMETER_SQL="insert into tdm_test_call_parameter_values  (id, tree_id, referenced_test_id, parameter_id, parameter_value) values (?,?,?,?,?) ";
		
		//SAVE PARAMETERS
		for (int i=0;i<paramsArr.size();i++) {
			String step_id=paramsArr.get(i)[0];
			String referenced_tree_id=paramsArr.get(i)[1];
			String parameter_id=paramsArr.get(i)[2];
			String parameter_value=paramsArr.get(i)[3];
			
			
			bindlist.clear();
			bindlist.add(new String[]{"LONG",step_id});
			bindlist.add(new String[]{"LONG",referenced_tree_id});
			bindlist.add(new String[]{"LONG",parameter_id});
			
			ArrayList<String[]> arrCheck=getDbArrayConf(conn, CHECK_PARAMETER_SQL, 1, bindlist);
			
			boolean param_exist=false;
			if (arrCheck.size()==1) param_exist=true;
			
			if (param_exist) {
				
				bindlist.clear();
				bindlist.add(new String[]{"STRING",parameter_value});
				bindlist.add(new String[]{"LONG",step_id});
				bindlist.add(new String[]{"LONG",referenced_tree_id});
				bindlist.add(new String[]{"LONG",parameter_id});
				
				is_ok=execDBConf(conn, UPDATE_PARAMETER_SQL, bindlist);
				if (!is_ok) {
					cherr.append("Exception : "+UPDATE_PARAMETER_SQL);
					return false;
				}
			}
			else {
				bindlist.clear();
				bindlist.add(new String[]{"LONG",getTS()});
				bindlist.add(new String[]{"LONG",step_id});
				bindlist.add(new String[]{"LONG",referenced_tree_id});
				bindlist.add(new String[]{"LONG",parameter_id});
				bindlist.add(new String[]{"STRING",parameter_value});
				
				is_ok=execDBConf(conn, INSERT_PARAMETER_SQL, bindlist);
				if (!is_ok) {
					cherr.append("Exception : "+INSERT_PARAMETER_SQL);
					return false;
				}
			}
			
			
			
		}

		return true;
		
}


//*********************************************************************************
String makeTreeCheckHistory(Connection conn, HttpSession session, String tree_id) {
	
	StringBuilder sb=new StringBuilder();

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select action_type, action_by, date_format(action_date,?) action_date, action_note, version "+
				" from tdm_test_tree_check_history "+
				" where tree_id=? "+
				" order by action_date desc";
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"LONG",tree_id});
		

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	String tree_title=getTreeAttributeValue(conn, session, tree_id, "tree_title");
	String tree_path=getTreeElementPath(conn, session, tree_id);
	
	sb.append("<big>");
	sb.append(tree_path+" ["+tree_title+"]");
	sb.append("</big>");
	
	sb.append("<table class=\"table table-striped table-bordered table-condensed\">");
	
	sb.append("<tr class=info>");
	sb.append("<td><b>Action</b></td>");
	sb.append("<td><b>By</b></td>");
	sb.append("<td><b>Version</b></td>");
	sb.append("<td><b>Date</b></td>");
	sb.append("<td><b>Note</b></td>");
	sb.append("</tr>");
	
	
	for (int i=0;i<arr.size();i++) {
		
		String action_type=arr.get(i)[0];
		String action_by=getUserFullNameById(conn, session, arr.get(i)[1]);
		String action_date=arr.get(i)[2];
		String action_note=arr.get(i)[3];
		String version=clearHtml(arr.get(i)[4]);

		
		sb.append("<tr>");
		sb.append("<td>"+action_type+"</td>");
		sb.append("<td nowrap>"+action_by+"</td>");
		sb.append("<td>"+version+"</td>");
		sb.append("<td nowrap>"+action_date+"</td>");
		sb.append("<td>"+action_note+"</td>");
		sb.append("</tr>");
	}

	sb.append("</table>");


	
	return sb.toString();
}


//********************************************************************************
void reorderTableOrderByGroup(
		Connection conn,
		HttpSession session,
		String table_name,
		String table_pk_id_val,
		String table_pk_bind_type,
		String direction,
		String group_field_names,
		String group_field_bind_types,
		String group_field_values,
		String order_field_name
		) {
	
	String sql="";
	ArrayList<String[]> arr=new ArrayList<String[]>();
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String curr_order="";
	String swap_id="";
	String swap_order="";
	
	sql="select  " + order_field_name + " from " + table_name + " where id=?";
	
	
	bindlist.clear();
	bindlist.add(new String[]{table_pk_bind_type,table_pk_id_val});

	arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==0) {
		System.out.println("current order not found !");
		return;
	}
	curr_order=arr.get(0)[0];


	
	String[] groupFieldsArr=group_field_names.split("\\|::\\|");
	String[] groupFieldBindsArr=group_field_bind_types.split("\\|::\\|");
	String[] groupFieldValsArr=group_field_values.split("\\|::\\|");
	
	String group_finder_sql="";
	
	bindlist.clear();
	
	for (int g=0;g<groupFieldsArr.length;g++) {
		String a_field_name=groupFieldsArr[g];
		String a_field_bind=groupFieldBindsArr[g];
		String a_field_value=groupFieldValsArr[g];
		
		group_finder_sql=group_finder_sql+" and " + a_field_name+"=? ";
		bindlist.add(new String[]{a_field_bind,a_field_value});
	}
	
	//DOWN
	sql="select  id," + order_field_name + " from " + table_name + " where true "+group_finder_sql+" and "+order_field_name+">? order by 2 ";
	if (direction.equals("UP"))
		sql="select  id, " + order_field_name + " from " + table_name + " where true "+group_finder_sql+" and  "+order_field_name+"<? order by 2 desc ";
	
	
	
	bindlist.add(new String[]{"INTEGER",curr_order});
	
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==0) {
		System.out.println("swap record not found !");
		return;
	}
	
	swap_id=arr.get(0)[0];
	swap_order=arr.get(0)[1];
	
	
	sql="update " + table_name +  " set " + order_field_name  + "=? where id=?";

	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",swap_order});
	bindlist.add(new String[]{table_pk_bind_type,table_pk_id_val});
	execDBConf(conn, sql, bindlist);
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",curr_order});
	bindlist.add(new String[]{table_pk_bind_type,swap_id});
	execDBConf(conn, sql, bindlist);
		
}

//********************************************************************************
void updateTableField(
		Connection conn,
		HttpSession session,
		String table_name,
		String table_id,
		String field_name,
		String field_value
		) {
	updateTableField(conn, session, table_name, table_id, field_name, field_value, "INTEGER");
}
//********************************************************************************
void updateTableField(
		Connection conn,
		HttpSession session,
		String table_name,
		String table_id,
		String field_name,
		String field_value,
		String key_bind_type
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	if (field_value.length()==0) {
		sql="update  "+table_name+" set  "+field_name+"=null  where id=? ";
		
		bindlist.add(new String[]{key_bind_type,table_id});
	}
	else {
		sql="update  "+table_name+" set  "+field_name+"=?  where id=? ";
		
		bindlist.add(new String[]{"STRING",field_value});
		bindlist.add(new String[]{key_bind_type,table_id});
	}
	
	execDBConf(conn, sql, bindlist);

}
//********************************************************************************
void updateTableData(
		Connection conn,
		HttpSession session,
		String table_name,
		String tree_type,
		String column_name,
		String value,
		String table_pk_value,
		StringBuilder err
		) {
	
	String check_tree_id="";
	
	//steplerde edit edilebilmesi icin ilgili testin checkout olmasi lazim
	if (table_name.equals("tdm_test_tree") && tree_type.equals("step")) 
		check_tree_id=getTreeAttributeValue(conn, session, table_pk_value, "parent_tree_id");
	else 	 
		check_tree_id=table_pk_value;
	
	
	
	
	if (check_tree_id.length()>0) {
		
		
		boolean is_checkin_available=isCheckinAvailable(conn,session,check_tree_id);
		
		if (!is_checkin_available) {
			err.append("This node is not available for check in.");
			return;
		}
		
		String active_tree_id=getCurrentTreeId(session);
		
		
		if (!active_tree_id.equals(check_tree_id)) {
			err.append("This node is not open for edit. Hacking me? Try harder ;) ");
			return;
		}
	}
	
	String sql="update "+table_name + " set "+column_name+"=? where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	bindlist.clear();
	bindlist.add(new String[]{"STRING",value});
	
	
	if (table_name.equals("tdm_test_tree"))
		bindlist.add(new String[]{"LONG",table_pk_value});
	else 
		bindlist.add(new String[]{"INTEGER",table_pk_value});
	
	boolean is_ok=execDBConf(conn, sql, bindlist);
	
	if (!is_ok) 
		err.append("Step cannot updated. See logs.");
	
	
	
		
}


//*********************************************************************************
boolean cancelCheckinForTreeNode(Connection conn, HttpSession session, String tree_id, StringBuilder cherr) {
		
		boolean is_checkin_available=isCheckinAvailable(conn,session,tree_id) || checkrole(session, "ADMIN") || checkrole(session, "TEST_ADMIN");
		
		if (!is_checkin_available) {
			cherr.append("This node is not available for check in.");
			return false;
		}
		
		String active_tree_id=getCurrentTreeId(session);
		
		if (!active_tree_id.equals(tree_id)) {
			cherr.append("This node is not open for edit. Hacking me? Try harder ;) ");
			return false;
		}
		
		String userid=""+(Integer) session.getAttribute("userid");
		String checkin_note="Checkout cancelled by "+getUserFullNameById(conn, session, userid);
	
		String sql="";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		

		sql="update tdm_test_tree "+
			" set "+
			" checked_out_by=0, checkout_date=null, checkin_date=now(), version=version+1,checkin_note=? "+
			" where id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"STRING",checkin_note});
		bindlist.add(new String[]{"LONG",tree_id});
		
		boolean is_ok= execDBConf(conn, sql, bindlist);
		
		if (!is_ok) {
			cherr.append("Cannot be checked in due to technical issues.");
			return false;
		}
		
		String new_version=getTreeAttributeValue(conn, session, tree_id, "version");
		
		makeTreeCheckHistory(conn,session,tree_id,"CHECKIN",userid,checkin_note,new_version);
		
		return true;
		
}


//********************************************************************************
String makeLangList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, lang, lang_desc from mad_lang order by 2 ";
	bindlist.clear();
	
	ArrayList<String[]> langList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	
	for (int i=0;i<langList.size();i++) {
		
		String lang_id=langList.get(i)[0];
		String lang=langList.get(i)[1];
		String lang_desc=langList.get(i)[2];
		
		if (lang.length()>0) 
			lang_desc=lang_desc+" ("+lang+")";
		
		
		sbContent.setLength(0);
		sbContent.append(makeLangEditor(conn, session, lang_id));
		
		collapseItems.add(new String[]{"colLangContent_"+lang_id,lang_desc,sbContent.toString(),"lang.png"});

		
		
		
	}

	
	sb.append(makeLangHeader());
	sb.append(addCollapse("listLang",collapseItems));

	return sb.toString();
}

//********************************************************************************
String makeLangHeader() {
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewLang();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Language");
	sb.append("</span>");
	sb.append("</button>");
	sb.append("</div>");
	sb.append("</div>");
	
	return sb.toString();
}
//********************************************************************************
String makeLangEditor(
		Connection conn,
		HttpSession session,
		String lang_id
		) {
	
	
	String sql="";


	sql="select lang, lang_desc from mad_lang where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",lang_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String lang=arr.get(0)[0];
	String lang_desc=arr.get(0)[1];
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=lang_editor_"+lang_id+">");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteLang('"+lang_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete Language \"" + lang_desc +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	sb.append("</div>");
	sb.append("</div>");
	

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Language Code : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("lang", lang, " onchange=\"saveLangField(this, '"+lang_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Language Description : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("lang_desc", lang_desc, " onchange=\"saveLangField(this, '"+lang_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");

	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}

//********************************************************************************
int addNewLang(
		Connection conn,
		HttpSession session,
		String lang_desc
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from mad_lang where lang_desc=? and lang=?";
	bindlist.add(new String[]{"STRING",lang_desc});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  mad_lang (lang_desc) values(?) ";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",lang_desc});

	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	
	return 0;
}

//********************************************************************************
String deleteLang(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from mad_string where lang in (select lang from mad_lang where id=?)";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) {
		return "This language is used by strings.Cannot be deleted.";
	}
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	
	sql="delete from  mad_lang where id=? ";
	execDBConf(conn, sql, bindlist);
	
	return "";

}


//********************************************************************************
String makeStringList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, string_name, lang from mad_string order by 2,3 ";
	bindlist.clear();
	
	
	String filter=nvl((String) session.getAttribute("search_for_strings"),"");
	if (filter.trim().length()>0) {
		sql="select id, string_name, lang from mad_string where string_name like ? order by 2";
		filter=filter.replace(" ", "%");
		filter="%"+filter+"%";
		bindlist.add(new String[]{"STRING",filter});
	}
	
	ArrayList<String[]> strList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	
	for (int i=0;i<strList.size();i++) {
		
		String string_id=strList.get(i)[0];
		String string_name=strList.get(i)[1];
		String lang=strList.get(i)[2];
		
		if (lang.length()>0) 
			string_name=string_name+" ("+lang+")";
		
		
		sbContent.setLength(0);
		sbContent.append(makeStringEditor(conn, session, string_id));
		
		collapseItems.add(new String[]{"colStringContent_"+string_id,string_name,sbContent.toString(),"string.png"});

		
		
		
	}

	
	sb.append(makeStringHeader(session));
	sb.append(addCollapse("listString",collapseItems));

	return sb.toString();
}

//********************************************************************************
String makeStringHeader(HttpSession session) {
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewString();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New String");
	sb.append("</span>");
	sb.append("</button>");
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" >");
	String search_value=nvl((String) session.getAttribute("search_for_strings"),"");
	sb.append(makeText("search_for_strings", search_value, "placeHolder=\"Search for ...\"; onkeyup=onConfigSearchEnterStrings(event) style=\"background-color:yellow;\"", 0));
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}


//********************************************************************************
String makeStringEditor(
		Connection conn,
		HttpSession session,
		String string_id
		) {
	
	
	String sql="";


	sql="select lang, string_name, " +
			"	short_desc , long_desc  " +
			"	from mad_string where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",string_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String lang=arr.get(0)[0];
	String string_name=arr.get(0)[1];
	String short_desc=arr.get(0)[2];
	String long_desc=arr.get(0)[3];
	

	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=string_editor_"+string_id+">");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteString('"+string_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete String \"" + string_name +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	sb.append("</div>");
	sb.append("</div>");
	

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">String Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("string_name", string_name, " onchange=\"saveStringField(this, '"+string_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Language (Empty : Default) : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select lang, lang_desc from mad_lang";
	sb.append(makeCombo(conn, sql, "", "disabled id=lang onchange=\"saveStringField(this, '"+string_id+"');\"", lang, 0));	
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Short Content (Title) : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("short_desc", short_desc, " onchange=\"saveStringField(this, '"+string_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Long Content : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append("<textarea rows=10 style=\"width:100%;\" id=long_desc onchange=\"saveStringField(this, '"+string_id+"');\" >");
	sb.append(clearHtml(long_desc));
	sb.append("</textarea>");
	sb.append("<span class=\"badge\" onclick=\"viewHtmlContent('"+string_id+"');\">View Html Content</span>");
	sb.append("</div>");
	sb.append("</div>");


	

	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}


//********************************************************************************
int addNewString(
		Connection conn,
		HttpSession session,
		String string_name,
		String lang
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from mad_string where string_name=? and lang=?";
	bindlist.add(new String[]{"STRING",string_name});
	bindlist.add(new String[]{"STRING",lang});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  mad_string (string_name, lang) values(?, ?) ";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",string_name});
	bindlist.add(new String[]{"STRING",lang});
	

	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	
	return 0;
}

//********************************************************************************
String deleteString(
		Connection conn,
		HttpSession session,
		String id
		) {
	

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="delete from  mad_string where id=? ";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	execDBConf(conn, sql, bindlist);
	
	return "";
	

	
}


//********************************************************************************
String makeFlexFieldList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select id, title from mad_flex_field order by 2";
	bindlist.clear();
	
	String filter=nvl((String) session.getAttribute("search_for_flexible_fields"),"");
	if (filter.trim().length()>0) {
		sql="select id, title from mad_flex_field where title like ? order by 2";
		filter=filter.replace(" ", "%");
		filter="%"+filter+"%";
		bindlist.add(new String[]{"STRING",filter});
	}
	
	
	ArrayList<String[]> fieldList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbAppContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<fieldList.size();i++) {
		
		String field_id=fieldList.get(i)[0];
		String field_title=fieldList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeFlexFieldEditor(conn, session, field_id));
		
		collapseItems.add(new String[]{"colFlexFieldContent_"+field_id,field_title,sbAppContent.toString(),"field.png"});
		
	}

	sb.append(makeFlexFieldHeader(session));
	sb.append(addCollapse("listFlexField",collapseItems));
	
	return sb.toString();
}

//********************************************************************************
String makeFlexFieldHeader(HttpSession session) {
	
	StringBuilder sb=new StringBuilder();

	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewFlexField();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Flexible Field");
	sb.append("</span>");
	sb.append("</button>");
	sb.append("</div>");
	sb.append("</div>");

	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" >");
	String search_value=nvl((String) session.getAttribute("search_for_flexible_fields"),"");
	sb.append(makeText("search_for_flexible_fields", search_value, "placeHolder=\"Search for ...\"; onkeyup=onConfigSearchEnterFlexFields(event) style=\"background-color:yellow;\"", 0));
	sb.append("</div>");
	sb.append("</div>");

	
	return sb.toString();
}


//********************************************************************************
String makeFlexFieldEditor(
		Connection conn,
		HttpSession session,
		String flex_field_id
		) {
	
	String sql="";
	sql="select title, entry_type, entry_validation_regex,  " +
		" is_validated, validation_sql, validation_env_id, field_size, " + 
		" tab_request_type_id, tab_delete_allowed, " +
		" num_fixed_length, num_decimal_length, num_grouping_char, num_decimal_char, num_currency_symbol, num_min_val, num_max_val, " +
		" string_name " + 
		" from mad_flex_field where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",flex_field_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String field_title=arr.get(0)[0];
	String entry_type=arr.get(0)[1];
	String entry_validation_regex=arr.get(0)[2];
	String is_validated=arr.get(0)[3];
	String validation_sql=arr.get(0)[4];
	String validation_env_id=arr.get(0)[5];
	String field_size=arr.get(0)[6];
	String tab_request_type_id=arr.get(0)[7];
	String tab_delete_allowed=arr.get(0)[8];
	
	String num_fixed_length=arr.get(0)[9];
	String num_decimal_length=arr.get(0)[10];
	String num_grouping_char=arr.get(0)[11];
	String num_decimal_char=arr.get(0)[12];
	String num_currency_symbol=arr.get(0)[13];
	String num_min_val=arr.get(0)[14];
	String num_max_val=arr.get(0)[15];

	String string_name=arr.get(0)[16];
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=request_type_editor_"+flex_field_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteFlexField('"+flex_field_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete Flexible Field" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Title : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("title", field_title, " onchange=\"saveFlexField(this, '"+flex_field_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sql="select distinct string_name from mad_string order by 1";
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">String : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeCombo(conn, sql, "", "id=string_name onchange=\"saveFlexField(this, '"+flex_field_id+"');\"", string_name, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	ArrayList<String[]> fieldTypArr=new ArrayList<String[]>();
	fieldTypArr.add(new String[]{"TEXT","Single Line Text Box"});
	fieldTypArr.add(new String[]{"NUMBER","Numeric / Currency"});
	fieldTypArr.add(new String[]{"MEMO","Multi Line Text"});
	fieldTypArr.add(new String[]{"LIST","List Box"});
	fieldTypArr.add(new String[]{"CHECKBOX","Checkbox"});
	fieldTypArr.add(new String[]{"PICKLIST","Pick List"});
	fieldTypArr.add(new String[]{"DATE","Date Picker"});
	fieldTypArr.add(new String[]{"DATETIME","Date Time Picker"});
	fieldTypArr.add(new String[]{"ATTACHMENT","File Attachment"});
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Field Type : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(fieldTypArr, "", "size=1 disabled id=entry_type onchange=\"saveFlexField(this, '"+flex_field_id+"');\" " , entry_type, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	if (entry_type.equals("LIST") || entry_type.equals("LOV") || entry_type.equals("PICKLIST")) {
		
		
		sql=	"select id, concat('{Database} ',name) from tdm_envs "+
				" UNION ALL "+
				"select -id, concat('{Javascript} ',method_name) from mad_method where method_type='JAVASCRIPT' order by 2";
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Data Source : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeCombo(conn, sql, "", "id=validation_env_id onchange=\"saveFlexField(this, '"+flex_field_id+"');\" " , validation_env_id, 0));
		sb.append("</div>");
		sb.append("</div>");
		
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">List Items/SQL : </label>");
		sb.append("<br>");
		sb.append("<b>Item1:Item Title 1</b><br>");
		sb.append("<b>Item2:Item Title 2</b><br>");
		sb.append("<b>Item3:Item Title 3</b>");
		
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(
				"<textarea id=validation_sql rows=4 style=\"width:100%;\" onchange=\"saveFlexField(this, '"+flex_field_id+"');\" >"+
					validation_sql+
				"</textarea>"
				);
		sb.append("</div>");
		sb.append("</div>");
	}
	
	
	if (entry_type.equals("TEXT")) {
		
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Regular Expression : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeText("entry_validation_regex", entry_validation_regex, "name=entry_validation_regex_"+flex_field_id+" onchange=\"saveFlexField(this, '"+flex_field_id+"');\"", 0));
		sb.append("</div>");
		sb.append("</div>");
		
		
		String regex_test_value=(String) session.getAttribute("entry_validation_regex_tester_"+flex_field_id);
		if (regex_test_value==null) regex_test_value="";
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Regex Tester : </label>");
		sb.append("</div>");
		
		sb.append("<div class=\"col-md-6\">");
		sb.append(makeText("entry_validation_regex_tester_"+flex_field_id, regex_test_value, " style=\"background-color:#FAFAFA;\" onchange=\"testFlexFieldRegex('"+flex_field_id+"');\"", 0));
		sb.append("</div>");
		
		sb.append("<div class=\"col-md-3\" align=left>");
		sb.append("<button type=button class=\"btn btn-md btn-warning\"  onclick=\"testFlexFieldRegex('"+flex_field_id+"');\">");
		sb.append("<span class=\"glyphicon glyphicon-fire\"> Test </span>");
		sb.append("</button>");
		sb.append("</div>");
		
		sb.append("</div>");
		
		
		ArrayList<String[]> yesnoArr=new ArrayList<String[]>();
		yesnoArr.add(new String[]{"YES","Yes"});
		yesnoArr.add(new String[]{"NO","No"});
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Validated by SQL : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeComboArr(yesnoArr, "", "size=1 id=is_validated onchange=\"saveFlexField(this, '"+flex_field_id+"');\" " , is_validated, 0));
		sb.append("</div>");
		sb.append("</div>");
		
		
		if (is_validated.equals("YES")) {
			sql="select id, name from tdm_envs order by 2";
					
					
			
			sb.append("<div class=row>");
			sb.append("<div class=\"col-md-3\" align=right>");
			sb.append("<label class=\"label label-info\">Database : </label>");
			sb.append("</div>");
			sb.append("<div class=\"col-md-9\">");
			sb.append(makeCombo(conn, sql, "", "size=1 id=validation_env_id onchange=\"saveFlexField(this, '"+flex_field_id+"');\" " , validation_env_id, 0));
			sb.append("</div>");
			sb.append("</div>");
			
			
			sb.append("<div class=row>");
			sb.append("<div class=\"col-md-3\" align=right>");
			sb.append("<label class=\"label label-info\">Validion SQL : </label>");
			sb.append("</div>");
			sb.append("<div class=\"col-md-9\">");
			sb.append(
					"<textarea id=validation_sql rows=3 style=\"width:100%;\" onchange=\"saveFlexField(this, '"+flex_field_id+"');\" >"+
						validation_sql+
					"</textarea>"
					);
			sb.append("</div>");
			sb.append("</div>");
		}
		
		
	}
	

	
	if (entry_type.equals("NUMBER")) {
		
		
		//String onchange_script="";
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Fixed Part Size : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeNumber(flex_field_id, "num_fixed_length_"+flex_field_id, num_fixed_length, "saveFlexFieldByFieldID('num_fixed_length', '"+flex_field_id+"')", "EDITABLE",
				"2", //num_fixed_length
				"0", //num_decimal_length
				"", //num_grouping_char
				"", //num_decimal_char
				"Digit", //num_currency_symbol
				"1", //num_min_val
				"24", //num_max_val
				""
				));
		sb.append("</div>");
		sb.append("</div>");
		
		
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Decimal Part Size : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeNumber(flex_field_id, "num_decimal_length_"+flex_field_id, num_decimal_length, "saveFlexFieldByFieldID('num_decimal_length', '"+flex_field_id+"')", "EDITABLE",
				"2", //num_fixed_length
				"0", //num_decimal_length
				"", //num_grouping_char
				"", //num_decimal_char
				"Digit", //num_currency_symbol
				"0", //num_min_val
				"8", //num_max_val
				""
				));
		sb.append("</div>");
		sb.append("</div>");
		
		

		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Fixed part Grouping symbol : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeText("num_grouping_char", num_grouping_char, "size=1 maxlength=1  onchange=\"saveFlexField(this, '"+flex_field_id+"');\" style=\"font-style: bold; font-size: 20px; \" ", 100));
		sb.append("</div>");
		sb.append("</div>");
		
		

		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Decmial part sepearation symbol : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeText("num_decimal_char", num_decimal_char, "size=1 maxlength=1 onchange=\"saveFlexField(this, '"+flex_field_id+"');\" style=\"font-style: bold; font-size: 20px; \" ", 100));
		sb.append("</div>");
		sb.append("</div>");
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\"> Amount or Currency symbol : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeText("num_currency_symbol", num_currency_symbol, "size=3 maxlength=10  onchange=\"saveFlexField(this, '"+flex_field_id+"');\" style=\"font-style: bold; font-size: 20px; \" ", 100));
		sb.append("</div>");
		sb.append("</div>");
		
		
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Minimum Value : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeNumber(flex_field_id, "num_min_val_"+flex_field_id, nvl(num_min_val,"0"), "saveFlexFieldByFieldID('num_min_val', '"+flex_field_id+"')", "EDITABLE",
				"24", //num_fixed_length
				"8", //num_decimal_length
				",", //num_grouping_char
				".", //num_decimal_char
				"", //num_currency_symbol
				"0", //num_min_val
				""+Integer.MAX_VALUE, //num_max_val
				""
				));
		sb.append("</div>");
		sb.append("</div>");
		
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Minimum Value : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeNumber(flex_field_id, "num_max_val_"+flex_field_id, nvl(num_max_val,""+Integer.MAX_VALUE), "saveFlexFieldByFieldID('num_max_val', '"+flex_field_id+"')", "EDITABLE",
				"24", //num_fixed_length
				"8", //num_decimal_length
				",", //num_grouping_char
				".", //num_decimal_char
				"", //num_currency_symbol
				"0", //num_min_val
				""+Integer.MAX_VALUE, //num_max_val
				""
				));
		sb.append("</div>");
		sb.append("</div>");
		
	
	}
		
	sb.append("</div>");
	sb.append("</div>");
	
	



	
	
	return sb.toString();
}

//********************************************************************************
int addNewFlexField(
		Connection conn,
		HttpSession session,
		String flex_field_type,
		String field_title
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from mad_flex_field where title=?";
	bindlist.add(new String[]{"STRING",field_title});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  mad_flex_field (entry_type, title, field_size) values(?,?,?) ";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",flex_field_type});
	bindlist.add(new String[]{"STRING",field_title});
	bindlist.add(new String[]{"INTEGER","0"});
	
	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	
	return 0;
}
//********************************************************************************
String deleteFlexField(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from dual where 0=? ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) {
		return "This record is being used. Cannot be removed.";
	}
	
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	sql="delete from  mad_request_type_state_field_override where flex_field_id=? ";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from  mad_flex_field where id=? ";
		
	execDBConf(conn, sql, bindlist);
	
	return "";
	
}
//********************************************************************************
String makePermissionList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, permission_name from mad_permission order by 2";
	bindlist.clear();
	ArrayList<String[]> permList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	StringBuilder sbAppContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<permList.size();i++) {
		
		String permission_id=permList.get(i)[0];
		String permission_name=permList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makePermissionEditor(conn, session, permission_id));
		/*
		collapseItems.add(new String[]{
				"colPermissionContent_"+permission_id,
				permission_name,
				sbAppContent.toString(),
				"permission.png",
				"makePermissionEditor('"+permission_id+"');"});
		*/
		collapseItems.add(new String[]{
				"colPermissionContent_"+permission_id,
				permission_name,
				sbAppContent.toString(),
				"permission.png"
				});
	}

	sb.append(makePermissionHeader());
	sb.append(addCollapse("listPermission",collapseItems));
	
	return sb.toString();
}

//********************************************************************************
String makePermissionHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewPermission();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Permission");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}

//********************************************************************************
String makePermissionEditor(
		Connection conn,
		HttpSession session,
		String permission_id
		) {
	
	
	String sql="";
	sql="select permission_name, permission_level, permission_description "+
		" from mad_permission where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",permission_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String permission_name=arr.get(0)[0];
	String permission_level=arr.get(0)[1];
	String permission_description=arr.get(0)[2];
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=permission_editor_"+permission_id+">");
	
	String disabled="";
	if (permission_level.equals("SYSTEM")) disabled="disabled";
	
	if (!permission_level.equals("SYSTEM")) {
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-12\" align=right>");
		sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deletePermission('"+permission_id+"');\">");
		sb.append("<span class=\"glyphicon glyphicon-remove\">");
		sb.append(" Delete Permission \"" + permission_name +"\"" );
		sb.append("</span>");
		sb.append("</button>");
		sb.append(" ");
		sb.append("</div>");
		sb.append("</div>");
	}
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Permission Name : </label>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("permission_name", permission_name, disabled+ " onchange=\"savePermissionField(this, '"+permission_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Permission Level : </label>");
	sb.append("</div>");

	sql="select 'SYSTEM', 'System Permission' from dual union all select 'USER', 'User Permission' from dual";
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeCombo(conn, sql, "", "disabled size=1 id=permission_level  onchange=\"savePermissionField(this, '"+permission_id+"');\"", permission_level, 0));
	sb.append("</div>");
	sb.append("</div>");

	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Permission Description : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append("<textarea rows=2 style=\"width:100%\" id=permission_description onchange=\"savePermissionField(this, '"+permission_id+"');\" >"+permission_description+"</textarea>");
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>"); 
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Groups Granted : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, group_name from mad_group where group_type='USER'  order by 2";
	bindlist.clear();
	ArrayList<String[]> groupsAllArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select group_id, group_name " 
		+"	from mad_group_permission m, mad_group g  " 
		+"	where  permission_id=? " 
		+"	and  group_id=g.id  " 
		+"	order by 2";


	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",permission_id});
	ArrayList<String[]> grantedGroupsArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	String event_listener="javascript:addRemovePermissionGroup(\""+permission_id+"\",\"#\");";
	sb.append(makePickList("0","granted_groups_"+permission_id, groupsAllArr, grantedGroupsArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");

	
	
	
		
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	return sb.toString();
}
//********************************************************************************
int addNewPermission(
		Connection conn,
		HttpSession session,
		String permission_name
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from mad_permission where permission_name=?";
	bindlist.add(new String[]{"STRING",permission_name});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  mad_permission (permission_name) values(?) ";
	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	
	return 0;
}
//********************************************************************************
String deletePermission(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from mad_flow_state_edit_permissions where permission_id=? "+
		" union all "+
		" select 1 from mad_flow_state_action_permissions where permission_id=?  ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	bindlist.add(new String[]{"INTEGER",id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) {
		return "This record is being used. Cannot be removed.";
	}
	
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	sql="delete from  mad_group_permission where permission_id=? ";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from  mad_permission where id=? ";
	
	
	execDBConf(conn, sql, bindlist);
	
	return "";
	
}
//********************************************************************************
void addRemoveGroupPermission(
		Connection conn,
		HttpSession session,
		String group_id,
		String addremove,
		String permission_id) {
	
	String sql="insert into mad_group_permission (group_id,permission_id ) values (?,?)";
	if (addremove.equals("REMOVE"))
		sql="delete from mad_group_permission where group_id=? and permission_id=? ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",group_id});
	bindlist.add(new String[]{"INTEGER",permission_id});
	
	execDBConf(conn, sql, bindlist);
	
}

//********************************************************************************
String makeUserList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, concat(username, ' [', lname, ', ', fname, ' ]')   from tdm_user order by 2";
	bindlist.clear();
	
	String filter=nvl((String) session.getAttribute("search_for_users"),"");
	if (filter.trim().length()>0) {
		sql="select id, concat(username, ' [', lname, ', ', fname, ' ]')   from tdm_user where concat(username,' ',fname,' ',lname) like ? order by 2";
		filter=filter.replace(" ", "%");
		filter="%"+filter+"%";
		bindlist.add(new String[]{"STRING",filter});
	}
	
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
				"makeUserEditor('"+user_id+"');"});
		
	}

	sb.append(makeUserHeader(session));
	sb.append(addCollapse("listUser",collapseItems));
	
	return sb.toString();
}

//********************************************************************************
String makeUserHeader(HttpSession session) {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	if (checkrole(session, "ADMIN")) { 
		sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewUser();\">");
		sb.append("<span class=\"glyphicon glyphicon-plus\">");
		sb.append(" Add New User");
		sb.append("</span>");
		sb.append("</button>");
	}
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" >");
	String search_value=nvl((String) session.getAttribute("search_for_users"),"");
	sb.append(makeText("search_for_users", search_value, "placeHolder=\"Search for ...\"; onkeyup=onConfigSearchUsers(event) style=\"background-color:yellow;\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}


//********************************************************************************
String makeUserEditor(
		Connection conn,
		HttpSession session,
		String user_id
		) {
	
	
	String sql="";
	sql="select username, email, fname, lname , valid, lang, authentication_method  from tdm_user where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",user_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String username=arr.get(0)[0];
	String email=arr.get(0)[1];
	String fname=arr.get(0)[2];
	String lname=arr.get(0)[3];
	String is_valid=arr.get(0)[4];
	String lang=arr.get(0)[5];
	String authentication_method=arr.get(0)[6];
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=user_editor_"+user_id+">");
	
	if (checkrole(session, "ADMIN")) { 
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-12\" align=right>");
		sb.append("<button type=button class=\"btn btn-sm btn-warning\" onclick=\"javascript:setUserPassword('"+user_id+"');\">");
		sb.append("<span class=\"glyphicon glyphicon-lock\">");
		sb.append(" Set Password " );
		sb.append("</span>");
		sb.append("</button>");
		sb.append(" ");
		
		if (!username.equals("admin")) {
			sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteUser('"+user_id+"');\">");
			sb.append("<span class=\"glyphicon glyphicon-remove\">");
			sb.append(" Delete User \"" + username +"\"" );
			sb.append("</span>");
			sb.append("</button>");
			sb.append(" ");
		}
	}
	
	
	
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">User Name : </label>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("username", username, " disabled onchange=\"saveUserField(this, '"+user_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Email : </label>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("email", email, " onchange=\"saveUserField(this, '"+user_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">First Name : </label>");
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("fname", fname, " onchange=\"saveUserField(this, '"+user_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Last Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("lname", lname, " onchange=\"saveUserField(this, '"+user_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Active : </label>");
	sb.append("</div>");	
	sb.append("<div class=\"col-md-9\">");
	sql="select 'Y', 'Yes' from dual union all select 'N', 'No' from dual";
	sb.append(makeCombo(conn, sql, "", "size=1 id=valid onchange=\"saveUserField(this, '"+user_id+"');\"", is_valid, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	String event_listener="";
	
	if (checkrole(session, "ADMIN")) {
		
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
		
		event_listener="javascript:addRemoveUserRole(\""+user_id+"\",\"#\");";
		sb.append(makePickList("0", "group_roles_"+user_id, rolesAllArr, userRolesArr, "", event_listener));
		sb.append("</div>");
		sb.append("</div>");
	}
	
	
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Group Membership : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, group_name from mad_group order by 2";
	bindlist.clear();
	ArrayList<String[]> groupsAllArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select group_id, group_name " 
		+"	from mad_group_members m, tdm_user u, mad_group g " 
		+"	where member_type='USER' and member_id=? " 
		+"	and member_id=u.id  and group_id=g.id " 
		+"	order by 2";
	

	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",user_id});
	ArrayList<String[]> grpMemArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	event_listener="javascript:addRemoveUserMembership(\""+user_id+"\",\"#\");";
	sb.append(makePickList("0", "group_membership_"+user_id, groupsAllArr, grpMemArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Language : </label>");
	sb.append("</div>");	
	sb.append("<div class=\"col-md-9\">");
	sql="select lang, lang_desc from mad_lang order by 2";
	sb.append(makeCombo(conn, sql, "", " id=lang onchange=\"saveUserField(this, '"+user_id+"');\"", lang, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Authentication Method : </label>");
	sb.append("</div>");	
	sb.append("<div class=\"col-md-9\">");
	sql="select 'SYSTEM','System Default' from dual union all select 'LOCAL','Local' from dual union all select 'LDAP','Ldap' from dual";
	sb.append(makeCombo(conn, sql, "", "size=1 id=authentication_method onchange=\"saveUserField(this, '"+user_id+"');\"", authentication_method, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
		
	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}
//********************************************************************************
int addNewUser(
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
void addRemoveUserMembership(
		Connection conn,
		HttpSession session,
		String user_id,
		String addremove,
		String group_id) {
	
	String sql="insert into mad_group_members (group_id, member_id, member_type ) values (?,?,'USER')";
	if (addremove.equals("REMOVE"))
		sql="delete from mad_group_members where group_id=? and member_id=? and member_type='USER'";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",group_id});
	bindlist.add(new String[]{"INTEGER",user_id});
	
	execDBConf(conn, sql, bindlist);
	
}
//********************************************************************************
String deleteUser(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from tdm_user_role  where user_id=? "+
			" union all "+
		"select 1 from mad_group_members  where member_id=? and member_type='USER'"+
			"";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	bindlist.add(new String[]{"INTEGER",id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) {
		return "This record is being used. Cannot be removed.";
	}

		
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	sql="delete from mad_group_members where member_id=? and member_type='USER' ";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from tdm_user_role where user_id=?";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from tdm_user where id=? ";
	
	
	execDBConf(conn, sql, bindlist);
	
	return "";
	
}
//********************************************************************************
String makeSetPassword(
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
void setUserPassword(
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
String makeGroupList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, group_type, group_name from mad_group order by group_type desc, group_name";
	bindlist.clear();
	ArrayList<String[]> groupList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbAppContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<groupList.size();i++) {
		
		String group_id=groupList.get(i)[0];
		String group_type=groupList.get(i)[1];
		String group_name=groupList.get(i)[2];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeGroupEditor(conn, session, group_id));
		
		collapseItems.add(new String[]{
				"colGroupContent_"+group_id,
				group_name,
				sbAppContent.toString(),
				"group_"+group_type+".png",
				"makeGroupEditor('"+group_id+"');"});
		
	}

	sb.append(makeGroupHeader());
	sb.append(addCollapse("listGroup",collapseItems));
	
	return sb.toString();
}

//********************************************************************************
String makeGroupHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewGroup();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Group");
	sb.append("</span>");
	sb.append("</button>");
	
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
	sql="select group_name, group_type, common_email_address, manager_user_id, group_description  from mad_group where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String group_name=arr.get(0)[0];
	String group_type=arr.get(0)[1];
	String common_email_address=arr.get(0)[2];
	String manager_user_id=arr.get(0)[3];
	String group_description=arr.get(0)[4];

	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=group_editor_"+group_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteGroup('"+group_id+"');\">");
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
	sb.append(makeText("group_name", group_name, " onchange=\"saveGroupField(this, '"+group_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Group Type : </label>");
	sb.append("</div>");

	sql="select 'USER', 'User Group' from dual union all select 'NOTIFICATION','Notification Group' from dual";
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeCombo(conn, sql, "", "id=group_type disabled  onchange=\"saveGroupField(this, '"+group_id+"');\"", group_type, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	

	if (group_type.equals("USER")) {
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Manager : </label>");
		sb.append("</div>");
		sql="select id, concat(fname, ' ', lname) from tdm_user where valid='Y' order by 2";
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeCombo(conn, sql, "", "id=manager_user_id   onchange=\"saveGroupField(this, '"+group_id+"');\"", manager_user_id, 0));
		sb.append("</div>");
		sb.append("</div>");
	}
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Common Email Address : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("common_email_address", common_email_address, "onchange=\"saveGroupField(this, '"+group_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Description : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append("<textarea rows=2 style=\"width:100%\" id=group_description onchange=\"saveGroupField(this, '"+group_id+"');\" >"+group_description+"</textarea>");
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
		+"	from mad_group_members m, tdm_user u  " 
		+"	where member_type='USER' and group_id=? " 
		+"	and member_id=u.id  " 
		+"	order by 2";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_id});
	ArrayList<String[]> usersInGrpArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	event_listener="javascript:addRemoveGroupMember(\""+group_id+"\",\"#\",\"USER\");";
	
	sb.append(makePickList("0", "users_in_group_"+group_id, usersAllArr, usersInGrpArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");

	
	sb.append("<div class=row>"); 
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Groups In Group : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, group_name from mad_group where id!=? order by 2";
	//user group can only have user groups
	if (group_type.equals("USER")) 
		sql="select id, group_name from mad_group where id!=? and group_type='USER' order by 2";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_id});
	ArrayList<String[]> groupsAllArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select member_id, group_name " 
		+"	from mad_group_members m, mad_group u  " 
		+"	where member_type='GROUP' and group_id=? " 
		+"	and member_id=u.id  " 
		+"	order by 2";


	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_id});
	ArrayList<String[]> groupsInGrpArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	event_listener="javascript:addRemoveGroupMember(\""+group_id+"\",\"#\",\"GROUP\");";
	sb.append(makePickList("0", "groups_in_group_"+group_id, groupsAllArr, groupsInGrpArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");
	
	
	if (group_type.equals("USER")) {
		
		sb.append("<div class=row>"); 
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Permissions Granted : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sql="select id, permission_name from mad_permission  order by 2";
		bindlist.clear();
		ArrayList<String[]> permsAllArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		sql="select permission_id, permission_name " 
			+"	from mad_group_permission m, mad_permission p  " 
			+"	where  group_id=? " 
			+"	and permission_id=p.id  " 
			+"	order by 2";


		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",group_id});
		ArrayList<String[]> permsInGrpArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		event_listener="javascript:addRemoveGroupPermission(\""+group_id+"\",\"#\");";
		sb.append(makePickList("0", "permissions_in_group_"+group_id, permsAllArr, permsInGrpArr, "", event_listener));
		sb.append("</div>");
		sb.append("</div>");
		
		
		
		
		sb.append("<div class=row>"); 
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Role Grant/Revoke : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		
		sb.append("<button type=button class=\"bt btn-sm btn-success\" onclick=assignRoleToGroup('"+group_id+"','GRANT')>");
		sb.append("<span class=\"glyphicon glyphicon-plus\"> Grant a Role to Group ["+group_name+"]</span>");
		sb.append("</button>");
		
		sb.append(" ");
		
		sb.append("<button type=button class=\"bt btn-sm btn-danger\" onclick=assignRoleToGroup('"+group_id+"','REVOKE')>");
		sb.append("<span class=\"glyphicon glyphicon-minus\"> Revoke a Role from Group ["+group_name+"]</span>");
		sb.append("</button>");

		sb.append("</div>");
		sb.append("</div>");
	} //if (group_type.equals("USER"))
	
		
	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}
//********************************************************************************
int addNewGroup(
		Connection conn,
		HttpSession session,
		String group_type,
		String group_name
		) {
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from mad_group where group_name=? and group_type=?";
	bindlist.add(new String[]{"STRING",group_name});
	bindlist.add(new String[]{"STRING",group_type});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  mad_group (group_name, group_type) values(?,?) ";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",group_name});
	bindlist.add(new String[]{"STRING",group_type});
	
	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	
	return 0;
}

//********************************************************************************
String deleteGroup(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from mad_group_members where member_type='GROUP' and member_id=? "+
		" union all"+
		" select 1 from mad_flow_state_action_groups where group_id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	bindlist.add(new String[]{"INTEGER",id});
	
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) {
		return "This record is being used. Cannot be removed.";
	}
	
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	
	
	sql="delete from mad_group_permission where group_id=?";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from mad_group where id=? ";
	
	
	execDBConf(conn, sql, bindlist);
	
	return "";

	
}
//********************************************************************************
void addRemoveGroupMember(
		Connection conn,
		HttpSession session,
		String group_id,
		String member_type,
		String addremove,
		String member_id) {
	
	String sql="insert into mad_group_members (group_id,member_id, member_type ) values (?,?,?)";
	if (addremove.equals("REMOVE"))
		sql="delete from mad_group_members where group_id=? and member_id=? and member_type=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",group_id});
	bindlist.add(new String[]{"INTEGER",member_id});
	bindlist.add(new String[]{"STRING",member_type}); 
	
	execDBConf(conn, sql, bindlist);
	
}
//------------------------------------------------------------------------------------
ArrayList<String> getUserListByGroup(Connection conn, HttpSession session, String group_id) {
	ArrayList<String> ret1=new ArrayList<String>();
	
	String sql="select member_id, member_type from mad_group_members where group_id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",group_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	for (int i=0;i<arr.size();i++) {
		String member_id=arr.get(i)[0];
		String member_type=arr.get(i)[1];
		
		if (member_type.equals("GROUP")) {
			ret1.addAll(getUserListByGroup(conn,session,member_id));
			continue;
		}
		
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
String makeEmailTemplateList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, template_name from mad_email_template order by 2";
	bindlist.clear();
	ArrayList<String[]> templateList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbAppContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<templateList.size();i++) {
		
		String email_template_id=templateList.get(i)[0];
		String email_template_type=templateList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeEmailTemplateEditor(conn, session, email_template_id));
		
		collapseItems.add(new String[]{
				"colEmailTemplateContent_"+email_template_id,
				email_template_type,
				sbAppContent.toString(),
				"email.png",
				""});
		
	}

	sb.append(makeEmailTemplateHeader());
	sb.append(addCollapse("listEmailTemplate",collapseItems));
	
	return sb.toString();
}

//********************************************************************************
String makeEmailTemplateHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewEmailTemplate();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Teplate");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}
//********************************************************************************
String makeEmailTemplateEditor(
		Connection conn,
		HttpSession session,
		String email_template_id
		) {
	
	
	String sql="";
	sql="select template_name, email_subject, email_body, from_type, from_email, from_name from mad_email_template where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",email_template_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String template_name=arr.get(0)[0];
	String email_subject=arr.get(0)[1];
	String email_body=arr.get(0)[2];
	String from_type=arr.get(0)[3];
	String from_email=arr.get(0)[4];
	String from_name=arr.get(0)[5];
	
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=email_template_editor_"+email_template_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteEmailTemplate('"+email_template_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete Template \"" + template_name +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Template Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("template_name", template_name, " onchange=\"saveEmailTemplateField(this, '"+email_template_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Sender Type: </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	ArrayList<String[]> arrFType=new ArrayList<String[]>();
	arrFType.add(new String[]{"FIXED","Fixed Email Sender"});
	arrFType.add(new String[]{"OPENER","Request Opener"});
	arrFType.add(new String[]{"ACTION","Action Taker"});
	sb.append(makeComboArr(arrFType, "", "id=from_type  onchange=\"saveEmailTemplateField(this, '"+email_template_id+"');\"", from_type, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Fixed Sender Email Address : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("from_email", from_email, " onchange=\"saveEmailTemplateField(this, '"+email_template_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Fixed Sender Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("from_name", from_name, " onchange=\"saveEmailTemplateField(this, '"+email_template_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");

	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Email Subject : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("email_subject", email_subject, " onchange=\"saveEmailTemplateField(this, '"+email_template_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Email Body : </label>");
	sb.append("<a href=\"javascript:showNotificationParams();\"><span class=badge>?</span></a>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append("<textarea rows=8 style=\"width:100%\" id=email_body onchange=\"saveEmailTemplateField(this, '"+email_template_id+"');\" >"+email_body+"</textarea>");
	sb.append("</div>");
	sb.append("</div>");
	
		
	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}
//********************************************************************************
int addNewEmailTemplate(
		Connection conn,
		HttpSession session,
		String template_name
		) {
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from mad_email_template where template_name=?";
	bindlist.add(new String[]{"STRING",template_name});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  mad_email_template (template_name) values(?) ";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",template_name});
	
	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	
	return 0;
}
//********************************************************************************
String deleteEmailTemplate(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from mad_flow where email_template_id=? "+
		" union all "+
		" select 1 from mad_flow_state_action where email_template_id=? ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	bindlist.add(new String[]{"INTEGER",id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) {
		return "This record is being used. Cannot be removed.";
	}
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	sql="delete from mad_email_template where id=? ";
	
	
	execDBConf(conn, sql, bindlist);
	
	return "";
	

	
}

//********************************************************************************
String makeDatabaseList(
		Connection conn,
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
		sbAppContent.append(makeDatabaseEditor(conn, session, db_id)); 
		
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
String makeDatabaseEditor(
		Connection conn,
		HttpSession session,
		String db_id
		) {
	
	
	String sql="";
	sql="select name,  db_driver, db_connstr, db_username, db_password   from tdm_envs where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",db_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String db_name=arr.get(0)[0];
	String db_driver=arr.get(0)[1];
	String db_connstr=arr.get(0)[2];
	String db_username=arr.get(0)[3];
	String db_password=arr.get(0)[4];

	
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
	sb.append(makePassword("db_password", db_password, " onchange=\"saveDatabaseField(this, '"+db_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("</div>");
	sb.append("</div>");

	
	return sb.toString();
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
boolean deleteDatabase(Connection conn, HttpSession session, String id) {
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="delete from tdm_envs where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	
	boolean is_ok=execDBConf(conn, sql, bindlist);
	
	return is_ok;
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
	String db_password=arr.get(0)[3];
	
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
//********************************************************************************
String makeMethodList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, method_name, method_type from mad_method order by 2";
	bindlist.clear();
	ArrayList<String[]> methodList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbAppContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<methodList.size();i++) {
		
		String method_id=methodList.get(i)[0];
		String method_name=methodList.get(i)[1];
		String method_type=methodList.get(i)[2];

		
		sbAppContent.setLength(0);
		sbAppContent.append(makeMethodEditor(conn, session, method_id));
		
		
		
		collapseItems.add(new String[]{
				"colMethodContent_"+method_id,
				method_name,
				sbAppContent.toString(),
				"method_"+method_type+".png",
				"makeMethodEditor('"+method_id+"');"});
		
	}

	sb.append(makeMethodHeader());
	sb.append(addCollapse("listMethod",collapseItems));
	
	return sb.toString();
}


//********************************************************************************
String makeMethodHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewMethod();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Method");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}


//********************************************************************************
String makeMethodEditor(
		Connection conn,
		HttpSession session,
		String method_id
		) {
	
	
	String sql="";
	sql="select method_name, method_description, method_type, is_valid, "+
		" reflection_classname, reflection_methodname, source_code, parameter_count, " +
		" database_id, start_directory, success_keyword " +
		" from mad_method where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",method_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String method_name=arr.get(0)[0];
	String method_description=arr.get(0)[1];
	String method_type=arr.get(0)[2];
	String is_valid=arr.get(0)[3];
	String reflection_classname=arr.get(0)[4];
	String reflection_methodname=arr.get(0)[5];
	String source_code=arr.get(0)[6];
	String parameter_count=arr.get(0)[7];
	String database_id=arr.get(0)[8];
	String start_directory=arr.get(0)[9];
	String success_keyword=arr.get(0)[10];
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=method_editor_"+method_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");

	sb.append("<button type=button class=\"btn btn-sm btn-warning\" onclick=\"javascript:testMadMethod('"+method_id+"','0');\">");
	sb.append("<span class=\"glyphicon glyphicon-play\">");
	sb.append(" Test Method" );
	sb.append("</span>");
	sb.append("</button> ");

	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteMethod('"+method_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete Method \"" + method_name +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append(" ");
	sb.append("</div>");
	sb.append("</div>");

	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Method Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("method_name", method_name, " onchange=\"saveMethodField(this, '"+method_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Method Type : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select 'JAVASCRIPT', 'JavaScript' from dual "+
		" union all "+
		"select 'DATABASE','Database JDBC Call' from dual"+
		" union all "+
		"select 'SHELL','Shell Command' from dual "+
		" union all "+
		"select 'JAVA','Java by Reflection' from dual";
	sb.append(makeCombo(conn, sql, "", "disabled id=method_type", method_type,0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Active : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select 'YES', 'Yes' from dual  union all select 'NO','No' from dual";
	sb.append(makeCombo(conn, sql, "", "size=1 id=is_valid   onchange=\"saveMethodField(this, '"+method_id+"');\" ", is_valid,0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Description : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append("<textarea rows=2 style=\"width:100%\" id=method_description onchange=\"saveMethodField(this, '"+method_id+"');\" >"+method_description+"</textarea>");
	sb.append("</div>");
	sb.append("</div>");
	
	if (method_type.equals("JAVA")) {
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Java Class : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeText("reflection_classname", reflection_classname, " onchange=\"saveMethodField(this, '"+method_id+"');\"", 0));
		sb.append("</div>");
		sb.append("</div>");
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Java Method : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeText("reflection_methodname", reflection_methodname, " onchange=\"saveMethodField(this, '"+method_id+"');\"", 0));
		sb.append("</div>");
		sb.append("</div>");
		
	} else {
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Source Code : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append("<textarea rows=8 style=\"width:100%;  font-family: monospace; \" id=source_code onchange=\"saveMethodField(this, '"+method_id+"');\" >"+source_code+"</textarea>");
		sb.append("</div>");
		sb.append("</div>");
	}
	
	
	if (method_type.equals("DATABASE")) {
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Execute on Database : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sql="select id, name from tdm_envs order by 2";
		sb.append(makeCombo(conn, sql, "", "id=database_id   onchange=\"saveMethodField(this, '"+method_id+"');\" ", database_id,0));
		sb.append("</div>");
		sb.append("</div>");
	}
	
	
	if (method_type.equals("SHELL")) {
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Starting Directory : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeText("start_directory", start_directory, " onchange=\"saveMethodField(this, '"+method_id+"');\"", 0));
		sb.append("</div>");
		sb.append("</div>");
		
		sb.append("<div class=row>");
		sb.append("<div class=\"col-md-3\" align=right>");
		sb.append("<label class=\"label label-info\">Expected Keyword (Regex ok) : </label>");
		sb.append("</div>");
		sb.append("<div class=\"col-md-9\">");
		sb.append(makeText("success_keyword", success_keyword, " onchange=\"saveMethodField(this, '"+method_id+"');\"", 0));
		sb.append("</div>");
		sb.append("</div>");
		
	}
	
	
	ArrayList<String[]> paramCountArr=new ArrayList<String[]>();
	for (int p=0;p<=10;p++) paramCountArr.add(new String[]{""+p});
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Parameter count : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(paramCountArr, "", "size=1 id=parameter_count  onchange=\"saveMethodField(this, '"+method_id+"');\" ", parameter_count, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");

	sb.append("<div class=\"col-md-12\" id=parameterListForMethod_"+method_id+">");
	sb.append(makeMethodParameterEditor(conn,session,method_id));
	sb.append("</div>");
	sb.append("</div>");
	
		
	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}



//********************************************************************************
String makeMethodParameterEditor(
		Connection conn,
		HttpSession session,
		String method_id
		) {
	
	String sql="select parameter_count, method_type from mad_method where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",method_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String parameter_count=arr.get(0)[0];
	String method_type=arr.get(0)[1];

	StringBuilder sb=new StringBuilder();
	
	int param_count=0;
	
	try {param_count=Integer.parseInt(parameter_count);} catch(Exception e) {e.printStackTrace();}
	
	if (param_count==0) {
		sb.append("No parameter defined.");
		return sb.toString();
	}
	
	sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
	
	sb.append("<tr class=info>");
	sb.append("<td><b>Parameter Name</b></td>");
	sb.append("<td><b>Default Value</b></td>");
	sb.append("<td><b>Parameter Type</b></td>");
	sb.append("</tr>");
	
	ArrayList<String[]> paramTypeArr=new ArrayList<String[]>();
	
	if (method_type.equals("JAVA")) {
		paramTypeArr.add(new String[]{"String"});
		paramTypeArr.add(new String[]{"Integer"});
	} else if (method_type.equals("DATABASE")) { 
		paramTypeArr.add(new String[]{"String"});
		paramTypeArr.add(new String[]{"Integer"});
	} else {
		paramTypeArr.add(new String[]{"Not Applicable"});
	}
	
	for (int i=1;i<=param_count;i++) {
		sql="select param_name_"+i+", param_type_"+i+", param_default_val_"+i + " from mad_method where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",method_id});
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		String param_name=arr.get(0)[0];
		String param_type=arr.get(0)[1];
		String param_val=arr.get(0)[2];
		
		sb.append("<tr>");
		
		sb.append("<td>");
		sb.append(makeText("param_name_"+i, param_name, " onchange=\"saveMethodField(this, '"+method_id+"');\"", 0));
		sb.append("</td>");
		
		
		sb.append("<td>");
		sb.append(makeText("param_default_val_"+i, param_val, " onchange=\"saveMethodField(this, '"+method_id+"');\"", 0));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(paramTypeArr, "", "id=param_type_"+i+"  onchange=\"saveMethodField(this, '"+method_id+"');\" ", param_type, 0));
		sb.append("</td>");
		
		sb.append("</tr>");
		
	}
	
	sb.append("</table>");
	
	return sb.toString();
}

//********************************************************************************
int addNewMethod(
		Connection conn,
		HttpSession session,
		String method_name,
		String method_type
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from mad_method where method_name=?";
	bindlist.add(new String[]{"STRING",method_name});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  mad_method (method_name, method_type) values(?,?) ";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",method_name});
	bindlist.add(new String[]{"STRING",method_type});
	
	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	return 0;
}
//********************************************************************************
String deleteMethod(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql=" select 1 from mad_flow_state_action_methods where method_id=? "+
		" union all " + 
		" select 1 from mad_flex_field where validation_env_id=-1*?"
		;
	
		
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	bindlist.add(new String[]{"INTEGER",id});

	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) {
		return "This record is being used. Cannot be removed.";
	}
	
		
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});

	sql="delete from  mad_method where id=? ";
	
	
	execDBConf(conn, sql, bindlist);
	
	return "";
}

//********************************************************************************
String makeFlowList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, flow_name from mad_flow order by 2";
	bindlist.clear();
	ArrayList<String[]> flowList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbAppContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<flowList.size();i++) {
		
		String flow_id=flowList.get(i)[0];
		String flow_name=flowList.get(i)[1];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeFlowEditor(conn, session, flow_id));
		
		collapseItems.add(new String[]{
				"colFlowContent_"+flow_id,
				flow_name,
				sbAppContent.toString(),
				"flow.png",
				"makeFlowEditor('"+flow_id+"');"});
		
	}

	sb.append(makeFlowHeader());
	sb.append(addCollapse("listFlow",collapseItems));
	
	return sb.toString();
}


//********************************************************************************
String makeFlowHeader() {
	StringBuilder sb=new StringBuilder();
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewFlow();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Flow");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}
//********************************************************************************
String makeFlowEditor(
		Connection conn,
		HttpSession session,
		String flow_id
		) {
	
	
	String sql="";
	sql="select flow_name, flow_description, email_template_id "+
		" from mad_flow where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",flow_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String flow_name=arr.get(0)[0];
	String flow_description=arr.get(0)[1];
	String email_template_id=arr.get(0)[2];

	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=flow_editor_"+flow_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	
	sb.append("<button type=button class=\"btn btn-sm btn-primary\" onclick=\"javascript:duplicateFlow('"+flow_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-copy\">");
	sb.append(" Duplicate \"" + flow_name +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");

			
	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteFlow('"+flow_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete Flow \"" + flow_name +"\"" );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	
	sb.append("</div>");
	sb.append("</div>");

	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Flow Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("flow_name", flow_name, " onchange=\"saveFlowField(this, '"+flow_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Default Email Template : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, template_name from mad_email_template order by 2";
	sb.append(makeCombo(conn, sql, "", "id=email_template_id onchange=\"saveFlowField(this, '"+flow_id+"');\"", email_template_id,0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Flow Description : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append("<textarea rows=2 style=\"width:100%\" id=flow_description onchange=\"saveFlowField(this, '"+flow_id+"');\" >"+flow_description+"</textarea>");
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	
	
	//sb.append("<hr>");


	
	sb.append("<div class=row>");
	
	sb.append("<div class=\"col-md-2\" id=flow_state_list_div_"+flow_id+" >");
	sb.append(makeFlowStateList(conn,session,flow_id));
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-10\" id=flow_state_editor_div_"+flow_id+">");
	sb.append("");
	sb.append("</div>");
	
	



	sb.append("</div>");
	
		
	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}


//********************************************************************************
int addNewFlow(
		Connection conn,
		HttpSession session,
		String flow_name
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from mad_flow where flow_name=?";
	bindlist.add(new String[]{"STRING",flow_name});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  mad_flow (flow_name) values(?) ";
	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	String[] initial_states=new String[]{"NEW","CLOSED"};
	sql="select id from mad_flow where flow_name=?";
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	String flow_id=arr.get(0)[0];
	
	for (int i=0;i<initial_states.length;i++) {
		String states=initial_states[i];
		sql="insert into mad_flow_state (flow_id, state_type, state_name, state_title) values (?, ?, ?, ?)";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",flow_id});
		bindlist.add(new String[]{"STRING","SYSTEM"});
		bindlist.add(new String[]{"STRING",states});
		bindlist.add(new String[]{"STRING",states});
		
		execDBConf(conn, sql, bindlist);
	}
	
	
	return 0;
}
//******************************************************************
String testMethod(Connection conn, HttpSession session, String method_id, String action_method_id) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	StringBuilder sb=new StringBuilder();
	
	
	sql="select " +
			" 	parameter_count, method_name, method_type, "+
			"	source_code, reflection_classname, reflection_methodname,  "+
			"	param_name_1, param_name_2, param_name_3, param_name_4, param_name_5,  " +
			"	param_name_6, param_name_7, param_name_8, param_name_9, param_name_10, " +
			"	param_default_val_1, param_default_val_2, param_default_val_3, param_default_val_4, param_default_val_5,  " +
			"	param_default_val_6, param_default_val_7, param_default_val_8, param_default_val_9, param_default_val_10 " +
			"	from  " +
			"	mad_method m " +
			"	where m.id=? ";
		
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",method_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	int parameter_count=Integer.parseInt(arr.get(0)[0]);
	String method_name=arr.get(0)[1];
	String method_type=arr.get(0)[2];
	String source_code=arr.get(0)[3];
	String reflection_classname=arr.get(0)[4];
	String reflection_methodname=arr.get(0)[5];
	
	
	String[] param_names=new String[10];
	String[] values=new String[10];
	
	for (int i=0;i<10;i++) {
		param_names[i]=nvl(arr.get(0)[6+i],"Parameter "+(i+1));
		values[i]=arr.get(0)[6+10+i];
	}
	
	
	//if action method id given, override the values
	if (!nvl(action_method_id,"0").equals("0")) {
		sql="select "+
				" value_1, value_2, value_3, value_4, value_5, "+
				" value_6, value_7, value_8, value_9, value_10 "+
				" from mad_flow_state_action_methods where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",action_method_id});
		
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		if (arr!=null && arr.size()==1) {
			for (int i=0;i<10;i++) {
				values[i]=arr.get(0)[i];
			}
		}
		
		
	}

	sb.append("<input type=hidden id=test_method_id value=\""+method_id+"\">");
	sb.append("<input type=hidden id=test_action_method_id value=\""+action_method_id+"\">");
	sb.append("<input type=hidden id=test_parameter_count value=\""+parameter_count+"\">");

	
	
	sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
	sb.append("<tr class=primary>");
	sb.append("<td bgcolor=blue>");
	sb.append("<h4><font color=black> [<b>"+method_name+"</b>]</font></h4>");
	sb.append("</td>");
	sb.append("</tr>");	
	sb.append("</table>");
	
	sb.append("<h4><span class=\"label label-primary\">Executable Source :</span></h4>");
	
	if (method_type.equals("JAVA")) {
		sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
		
		sb.append("<tr>");
		sb.append("<td align=right nowrap><b>Java Class : </b></td>");
		sb.append("<td>");
		sb.append(reflection_classname);
		sb.append("</td>");
		sb.append("</tr>");	
		
		sb.append("<tr>");
		sb.append("<td align=right nowrap><b>Java Method : </b></td>");
		sb.append("<td>");
		sb.append(reflection_methodname);
		sb.append("</td>");
		sb.append("</tr>");	

		sb.append("</table>");
	} else {
		sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
		
		sb.append("<tr>");
		sb.append("<td>");
		sb.append("<textarea readonly rows=4 style=\"width:100%; background-color:black; color:white; font-family: monospace;\">"+clearHtml(source_code)+"</textarea>");
		sb.append("</td>");
		sb.append("</tr>");	

		sb.append("</table>");
	}
	
	
	if (parameter_count==0) 
		sb.append("No parameters to edit.");
	else {
		
		sb.append("<h4><span class=\"label label-primary\">Parameters :</span></h4>");
		sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
		
		for (int i=0;i<parameter_count;i++) {
			sb.append("<tr>");
			sb.append("<td align=right nowrap><b>"+param_names[i]+" </b></td>");
			sb.append("<td>");
			sb.append(makeText("value_"+(i+1), clearHtml(values[i]), " onchange=\"saveFlowStateActionMethodField(this,'"+action_method_id+"'); \" ", 0));
			sb.append("</td>");
			sb.append("</tr>");		
		}
		sb.append("</table>");
	}
	
	
	
	sb.append("<h4><span class=\"label label-primary\">Test Result :</span></h4>");
	sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
	sb.append("<tr>");
	sb.append("<td>");
	sb.append("<div id=testMethodResultDiv></div>");
	sb.append("</td>");
	sb.append("</tr>");	
	sb.append("</table>");
	
	sb.append("<h4><span class=\"label label-primary\">Logs :</span></h4>");
	sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
	sb.append("<tr>");
	sb.append("<td>");
	sb.append("<div id=testMethodLogsDiv></div>");
	sb.append("</td>");
	sb.append("</tr>");	
	sb.append("</table>");

	return sb.toString();
}

//******************************************************************
String executeMethod(
		Connection conn, 
		HttpSession session, 
		String method_id, 
		String action_method_id, 
		String parameters
		) {
	
	return executeMethod(
				conn, 
				session, 
				method_id,
				action_method_id,
				parameters,
				new StringBuilder(),
				new StringBuilder(),
				new StringBuilder()
			);
}

//******************************************************************
String executeMethod(
		Connection conn, 
		HttpSession session, 
		String method_id, 
		String action_method_id, 
		String parameters,
		StringBuilder executable,
		StringBuilder result, 
		StringBuilder logs) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> arr=new ArrayList<String[]>();
	
	/*
	ArrayList<String[]> paramArr=new ArrayList<String[]>();
	if (!test_request_id.equals("0")) 
		paramArr=getRequestParameters(conn, session, test_request_id);
		
	*/
	

	
	
	
	sql="select " +
			" 	parameter_count, method_name, method_type, "+
			"	source_code, reflection_classname, reflection_methodname, database_id, start_directory, success_keyword " +
			"	from  " +
			"	mad_method m " +
			"	where m.id=? ";
		
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",method_id});
	
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	int parameter_count=Integer.parseInt(arr.get(0)[0]);
	String method_name=arr.get(0)[1];
	String method_type=arr.get(0)[2];
	String source_code=arr.get(0)[3];
	String reflection_classname=arr.get(0)[4];
	String reflection_methodname=arr.get(0)[5];
	String database_id=arr.get(0)[6];
	String start_directory=arr.get(0)[7];
	String success_keyword=arr.get(0)[8];
	
	//source_code=replaceAllParams(source_code,paramArr);
	//reflection_classname=replaceAllParams(reflection_classname,paramArr);
	//reflection_methodname=replaceAllParams(reflection_methodname,paramArr);
	
	//start_directory=replaceAllParams(start_directory,paramArr);
	//success_keyword=replaceAllParams(success_keyword,paramArr);
	
	String[] param_names=new String[10];
	String[] values=new String[10];
	String[] types=new String[10];
	
	
	
	
	String[] splitArr=parameters.split("\n|\r");
	int param_count=0;
	
	
	
	sql="";
	
	for (int i=0;i<splitArr.length;i++) {
		String line=splitArr[i];
		int ind=line.indexOf("=");
		if (ind==-1) continue;
		String param_name=line.substring(0,ind);
		String param_val="";
		try {param_val=line.substring(ind+1);} catch(Exception e) {}
		param_count++;
		param_names[param_count-1]=param_name;
		
		//values[param_count-1]=replaceAllParams(param_val,paramArr);
		
		sql="select param_type_"+param_count +" from mad_method where id=?";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER", method_id});
		
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		String type="";
		
		if (arr!=null && arr.size()==1) type=arr.get(0)[0];
		
		types[param_count-1]=type;
		
	}
	
	
	
	
	/*
	for (int p=0;p<param_count;p++) 
		paramArr.add(new String[]{param_names[p], replaceAllParams(values[p],paramArr)});
	*/
	
	
	executable.setLength(0);
	
	logs.append("Executable Source  : \n");
	
	logs.append("------------------------------------------------------------\n");
	if (method_type.equals("JAVA")) {
		logs.append("Java Class :  ={"+reflection_classname+"}\n");
		logs.append("Java Method :  ={"+reflection_methodname+"}\n");
		
		executable.append(reflection_classname+"."+reflection_methodname);
	}
	else {
		logs.append(source_code+"\n");
		executable.append(source_code);
	}
		
	logs.append("------------------------------------------------------------\n");
	
	session.setAttribute("last_method_execution_logs", logs);
	
	
	
	executeMethodNow(conn, session, 
			method_id,
			method_name, 
			method_type, 
			source_code, 
			reflection_classname, 
			reflection_methodname, 
			database_id, 
			start_directory,
			success_keyword,
			param_count,
			types,
			values,
			result, 
			logs);
	
	
	
	sb.append("<textarea readonly rows=2 style=\"width:100%; background-color:yellow; color:black; font-family: monospace;\">"+result.toString()+"</textarea>");

	return sb.toString();
}

//******************************************************************
void 	executeMethodNow(Connection conn, HttpSession session, 
		String method_id, 
		String method_name, 
		String method_type,
		String source_code, 
		String reflection_classname, 
		String reflection_methodname, 
		String database_id,
		String start_directory,
		String success_keyword,
		int parameter_count,
		String[] typeArr,
		String[] valueArr,
		StringBuilder result, 
		StringBuilder logs) {
	
	
	long start_ts=System.currentTimeMillis();
	
	
	
	
	logs.append("Executing... : "+method_name+"\n");
	
	result.setLength(0);
	boolean is_success=true;

	
	if (method_type.equals("DATABASE")) {
		
		logs.append("Connecting to database... \n");
		Connection app=getconn(conn, database_id);
		if (app!=null) logs.append("Connected. \n");
		else {
			logs.append("DB connection is not successfull : "+last_connection_error+". \n");
			return;
		}
		
		
		PreparedStatement stmt=null;
		try {
			
			stmt=app.prepareStatement(source_code);
			for (int p=0;p<parameter_count;p++) {
				String type=typeArr[p];
				String val=valueArr[p];
				logs.append("Binding ["+(p+1)+"] ("+type+") : {"+val+"}\n");
				
				if (type.equals("Integer")) 
					stmt.setInt(p+1, Integer.parseInt(val));
				else 
					stmt.setString(p+1, val);
			}
			
			int x=stmt.executeUpdate();
			logs.append("Executed successfully. "+x+ " records affected.");
		} catch(Exception e) {
			is_success=false;
			logs.append("Exception@Execution db command : " +e.getMessage()+"\n");
		} finally {
			try {stmt.close();} catch(Exception e) {}
			try {app.close();} catch(Exception e) {}
		}
		
		
	} else if (method_type.equals("JAVASCRIPT")) {
		ScriptEngineManager factory=null;
		ScriptEngine engine=null;
		try {
			factory = new ScriptEngineManager();
			
			
			engine = factory.getEngineByName("JavaScript");
			//engine = factory.getEngineByName("nashorn");
			String ret1=""+ engine.eval(source_code);
			logs.append("Javascript Eval Returns : " + ret1+"\n");
			if (ret1.length()>0 && !ret1.equals("null"))
				result.append(ret1);
			
			if (result.indexOf("false")==0) {
				is_success=false;
				result.setLength(0);
				result.append("false");

			}
			
		} catch(Exception e) {
			is_success=false;
			logs.append("Exception@Execution javascript : " +e.getMessage()+"\n");
		}
		
	} 
	else if (method_type.equals("SHELL")) {
		
		String start_cmd="cmd";
		String start_path="";
		
		
		
		try {start_cmd=valueArr[0];}  catch(Exception e) {start_cmd="cmd";}
		
		StringBuilder shellLogs=new StringBuilder();
		
		is_success=runShellScript(source_code, start_directory, shellLogs);
		
		if (is_success && success_keyword.trim().length()>0) {
			is_success=checkStrings(shellLogs.toString(), success_keyword);
		}
		
		logs.append(shellLogs.toString());
		
		if (is_success)
			result.append("true");
		else 
			result.append("false");
		
		System.out.println("shell logs  : "+shellLogs.toString());

	}
	else {
		result.append("true");
	}
	
	if (result.length()==0)
		if (is_success) 
			result.append("true");
		else 
			result.append("false");
	
	
	
	String duration=""+(System.currentTimeMillis()-start_ts);

	logs.append("Executed... : "+method_name+", Duration  : ("+formatnum(""+duration)+") msecs\n");

}

//------------------------------------------------------------------------------------
public  boolean testRegex(String test_str, String regex_str) {
	Pattern pattern = null;
	
	try {
		pattern=Pattern.compile(regex_str);
		Matcher matcher = pattern.matcher(test_str);
		while (matcher.find()) return true;
	} catch(Exception e) {
		e.printStackTrace();
		return false;
	}
	
			
	
	return false;
	
}

//----------------------------------------------------------------
public boolean testStrings(String test_str, String search_str) {
	if (test_str.indexOf(search_str)>-1) return true;
	
	return false;
	
}

//-----------------------------------------------------------------
public boolean checkStrings(String test_str, String search_str) {
	
	String[] arr=search_str.split("\n|\r");
	if (arr.length==1) arr=search_str.split("\\|\\|");
	
	for (int i=0;i<arr.length;i++) {
		if (arr[i].trim().length()==0) continue;
		boolean check_res=testStrings(test_str, arr[i]) || testRegex(test_str, arr[i]);
		if (check_res) return true;
	}
	
	
	return false;
	
}
//******************************************************************
boolean runShellScript(String source_code, String start_directory, StringBuilder shellLogs) {
	
	String command_to_run="";
	Runtime r=null;
	ProcessBuilder pb=null;
	Process p=null;
	
	BufferedReader output = null;
	OutputStream sendkeys =null;
	
	String[] cmds=source_code.split("\n|\r");
	ArrayList<String> cmdArr=new ArrayList<String>();
	
	for (int i=0;i<cmds.length;i++) {
		command_to_run=cmds[i];
		if (command_to_run.trim().length()==0) continue;
		cmdArr.add(command_to_run);
	}
	
	
	if (cmdArr.size()==0) {
		shellLogs.append("No command to execute...\n");
		return false;
	}
	
	try {
		
		String start_command=cmdArr.get(0);
		
		
		
		pb=new ProcessBuilder(start_command.split(" "));
		
		if (start_directory.trim().length()>0) {
			File start_dirF=new File(start_directory);
			try {
				pb.directory(start_dirF);
			} catch(Exception e) {
				e.printStackTrace();
				
			}
			
		}
		
		
		
		
		pb.redirectErrorStream(true);
		shellLogs.append("Running start command : " + start_command);
		p=pb.start();
		
		output = new BufferedReader(new  InputStreamReader(p.getInputStream()));
		sendkeys=p.getOutputStream();

		waitCommandOutput(p, output, 1000, "", shellLogs);
		long timeout=30*60*1000;
		String waitstr="";
		
		for (int i=1;i<cmdArr.size();i++) {
			String a_cmd_line=cmdArr.get(i);
			
			System.out.println("running ["+i+"]: " + a_cmd_line);
			
			if (a_cmd_line.toLowerCase().indexOf("@waittime")==0) {
				int first_id=a_cmd_line.indexOf("(");
				int last_id=a_cmd_line.lastIndexOf(")");

				if (first_id>-1 && last_id>-1 && last_id>first_id+1) {
					String wait_timeout=a_cmd_line.substring(first_id+1, last_id);
					try {timeout=Long.parseLong(wait_timeout);} catch(Exception e) {timeout=1000; e.printStackTrace(); }
				}
				
				shellLogs.append("set wait time ["+timeout+"]");
				continue;
			} 
			
			if (a_cmd_line.toLowerCase().indexOf("@waitstr")==0) {
				int first_id=a_cmd_line.indexOf("(");
				int last_id=a_cmd_line.lastIndexOf(")");

				if (first_id>-1 && last_id>-1 && last_id>first_id+1) {
					waitstr=a_cmd_line.substring(first_id+1, last_id);
				}
				shellLogs.append("set wait string ["+waitstr+"]");
				continue;
			} 
			
			sendkeys.write(a_cmd_line.getBytes());
			sendkeys.write(System.lineSeparator().getBytes());
			
			try {sendkeys.flush(); } catch(Exception e) {}
			
			boolean cmd_success=waitCommandOutput(p, output, timeout, waitstr, shellLogs);
			
			if (!cmd_success) return false;
			
		}
		
			
	}  catch(Exception e) {
		shellLogs.append("Exception@runShellScript :  "+e.getMessage()+"\n");
		return false;
	} finally {
		try  {output.close(); } catch(Exception e) {}
		try  {sendkeys.close(); } catch(Exception e) {}
		try {p.destroy(); }  catch(Exception e) {}
		
	}
	
	
	return true;
}

//******************************************************************
boolean waitCommandOutput(Process p,  BufferedReader output, long timeout, String waitstr, StringBuilder shellLogs) {
	
	StringBuilder sb=new StringBuilder();
	try { 

		int value = -1;
		long last_read_ts=System.currentTimeMillis();
		while(true) {
			if (output.ready())   {
				last_read_ts=System.currentTimeMillis();
				
				value=output.read();
				System.out.print((char) value);
				
          	if (value==-1) continue;
              
          	sb.append((char) value);
			} else {
				Thread.sleep(100);
			}
			
			if (System.currentTimeMillis()>last_read_ts+timeout) {
				
				if (waitstr.trim().length()>0 &&  checkStrings(sb.toString(), waitstr.trim())==false) {
					shellLogs.append(sb.toString());
					return false;
				}
				shellLogs.append(sb.toString());
				break;
			}
			
			if (waitstr.trim().length()>0 &&  checkStrings(sb.toString(), waitstr.trim())) {
				shellLogs.append(sb.toString());
				return true;
			}
			
		} //while
	
		return true;
		
	} catch(Exception e) {
		sb.append("Exception@waitCommandOutput :  "+e.getMessage()+"\n");
		shellLogs.append(sb.toString());
		return false;
	} 
	
}


//******************************************************************
String getLastExecuteMethodLogs(Connection conn, HttpSession session) {

	StringBuilder sb=new StringBuilder();
	StringBuilder logs=(StringBuilder) session.getAttribute("last_method_execution_logs");
	
	if (logs==null)
		sb.append("No log found.");
	else 
		sb.append("<textarea readonly rows=12 style=\"width:100%; background-color:black; color:lightgreen; font-family: monospace;\" >"+logs.toString()+"</textarea>");
	

	return sb.toString();
}

//********************************************************************************
String deleteFlow(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select 1 from dual where 0=? ";
	
		
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) {
		return "This record is being used. Cannot be removed.";
	}
	
		
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	
	
	sql="delete from mad_flow_state_action_permissions where flow_state_action_id in (select id from mad_flow_state_action where flow_state_id in (select id from mad_flow_state where flow_id=?))";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from mad_flow_state_action_groups where flow_state_action_id in (select id from mad_flow_state_action where flow_state_id in (select id from mad_flow_state where flow_id=?))";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from mad_flow_state_edit_permissions where flow_state_id in (select id from mad_flow_state where flow_id=?)";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from mad_flow_state_action where flow_state_id in (select id from mad_flow_state where flow_id=?)";
	execDBConf(conn, sql, bindlist);
	
	
	
	sql="delete from mad_flow_state where flow_id=?";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from  mad_flow where id=? ";
	
	
	execDBConf(conn, sql, bindlist);
	
	return "";
}
//********************************************************************************
int addNewFlowState(
		Connection conn,
		HttpSession session,
		String flow_id,
		String state_name
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from mad_flow_state where state_name=? and flow_id=?";
	bindlist.add(new String[]{"STRING",state_name});
	bindlist.add(new String[]{"INTEGER",flow_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="select 1 from mad_flow_state where state_title=? and flow_id=?";
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  mad_flow_state (state_name, state_title, flow_id) values(?, ?, ?) ";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",state_name});
	bindlist.add(new String[]{"STRING",state_name});
	bindlist.add(new String[]{"INTEGER",flow_id});
	
	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;

	
	return 0;
}

//********************************************************************************
String makeFlowStateList(
		Connection conn,
		HttpSession session,
		String flow_id
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	StringBuilder sb=new StringBuilder();
	StringBuilder sbAppContent=new StringBuilder();
	
	sql="select id, state_type, state_name, state_title from mad_flow_state where flow_id=? order by state_title";
	bindlist.add(new String[]{"INTEGER",flow_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	sb.append("<div class=\"btn-group-vertical\" data-toggle=\"buttons\" >");
	
	sb.append("<button type=\"radio\" class=\"btn btn-success\" onclick=addNewFlowState('"+flow_id+"')>");
	sb.append("<span class=\"glyphicon glyphicon-plus\"> Add New State</span>");
	sb.append("</button>");
	
	
	
	
	for (int i=0;i<arr.size();i++) {
		String state_id=arr.get(i)[0];
		String state_type=arr.get(i)[1];
		String state_name=arr.get(i)[2];
		String state_title=arr.get(i)[3];
		
		String label_class="btn btn-default";
		String checked="";
		if (state_name.equals("NEW")) {
			 checked="checked";
			label_class="btn btn-default active";
		}
		
		if (state_type.equals("SYSTEM")) state_title=state_title+" (*) ";
			
		
		sb.append("<label class=\""+label_class+"\"  onclick=makeFlowStateEditor('"+flow_id+"','"+state_id+"')>");
		sb.append("<input type=\"radio\" name=\"flow_states_of_"+flow_id+"\" id=\"flow_states_of_"+flow_id+"_option_"+i+"\" autocomplete=\"off\" "+checked+"> "+state_title);
		sb.append("</label>");
	}
	sb.append("</div>");
	
	
	return sb.toString();
}

//********************************************************************************
String makeFlowStateEditor(
		Connection conn,
		HttpSession session,
		String flow_id,
		String flow_state_id
		) {
	String sql="";
	sql="select state_type, state_name,  state_title, state_stage, state_description "+
		" from mad_flow_state where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",flow_state_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String state_type=arr.get(0)[0];
	String state_name=arr.get(0)[1];
	String state_title=arr.get(0)[2];
	String state_stage=arr.get(0)[3];
	String state_description=arr.get(0)[4];


	String disabled="";
	if (state_type.equals("SYSTEM")) disabled="disabled";
	

	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=flow_state_editor_"+flow_id+"_"+state_name+" style=\"background-color:#DADADA; \">");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	sb.append("<button "+disabled+" type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteFlowState('"+flow_id+"','"+flow_state_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete Flow State " );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	sb.append("</div>");
	
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">State Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("state_name", state_name, disabled+" onchange=\"saveFlowStateField(this, '"+flow_state_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">State Title : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("state_title", state_title, " onchange=\"saveFlowStateField(this, '"+flow_state_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">State Stage : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	ArrayList<String[]> stateArr=new ArrayList<String[]>();
	stateArr.add(new String[]{"START","Start"});
	stateArr.add(new String[]{"FINISH","Finish"});
	stateArr.add(new String[]{"PROCESS","Processing"});
	stateArr.add(new String[]{"STALL","Stalling"});
	stateArr.add(new String[]{"APPROVAL","Waiting Approval"});
	stateArr.add(new String[]{"APPROVED","Approval OK"});
	stateArr.add(new String[]{"REJECTED","Approval Rejected"});
	
	sb.append(makeComboArr(stateArr, "", "id =state_stage onchange=\"saveFlowStateField(this, '"+flow_state_id+"');\"" , state_stage, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>"); 
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Permissions to Edit: </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, concat(permission_level,'.',permission_name) from mad_permission  order by 2";
	bindlist.clear();
	ArrayList<String[]> permsAllArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	permsAllArr.add(0, new String[]{"-1","REQUEST [Owner]"});
	permsAllArr.add(0, new String[]{"-2","REQUEST [Direct Manager of Owner]"});
	permsAllArr.add(0, new String[]{"-3","GENERAL [Administator]"});
	permsAllArr.add(0, new String[]{"-4","GENERAL [Release Manager]"});
	permsAllArr.add(0, new String[]{"-5","GENERAL [Group Member]"});
	
	String inner_sql="select id, permission_name from mad_permission pi ";
	int a=0;
	for (int i=0;i<permsAllArr.size();i++) {
		String p_id=permsAllArr.get(i)[0];
		String p_name=permsAllArr.get(i)[1];
		if (Integer.parseInt(p_id)<0) {
			a++;
			inner_sql=inner_sql+ "\n union all \n";
			inner_sql=inner_sql+ " select '"+p_id+"','"+p_name+"' from dual \n";
		}
		else break;
	}
	
	
	sql="select permission_id, permission_name \n" 
		+"	from mad_flow_state_edit_permissions m, ("+inner_sql+") p  \n" 
		+"	where  flow_state_id=? \n" 
		+"	and permission_id=p.id  \n"+
		" order by 2";	
	


	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",flow_state_id});
	ArrayList<String[]> permsInActionArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	String event_listener="javascript:addRemoveStateEditPermission(\""+flow_state_id+"\",\"#\");";
	sb.append(makePickList("0", "permissions_to_edit_"+flow_state_id, permsAllArr, permsInActionArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">State Description : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append("<textarea rows=2 style=\"width:100%\" id=state_description onchange=\"saveFlowStateField(this, '"+flow_state_id+"');\" >"+state_description+"</textarea>");
	sb.append("</div>");
	sb.append("</div>");



	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=colFlowStateActions_"+flow_state_id+"Body>");
	sb.append(makeFlowStateActionList(conn,session,flow_state_id));
	sb.append("</div>");
	sb.append("</div>");
	
		
	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}
//********************************************************************************
String makeFlowStateActionList(
		Connection conn,
		HttpSession session,
		String flow_state_id
		) {
	String sql="";
	sql="select id,action_type, action_name "+
		" from mad_flow_state_action where flow_state_id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",flow_state_id});
	ArrayList<String[]> actionList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	StringBuilder sb=new StringBuilder();
	
	StringBuilder sbAppContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	for (int i=0;i<actionList.size();i++) {
		
		String action_id=actionList.get(i)[0];
		String action_type=actionList.get(i)[1];
		String action_name=actionList.get(i)[2];
		
		
		sbAppContent.setLength(0);
		sbAppContent.append(makeFlowStateActionEditor(conn, session, action_id));
		
		collapseItems.add(new String[]{
				"colFlowStateActionContent_"+action_id,
				action_name,
				sbAppContent.toString(),
				"action.png"});
		
	}
	
	sb.append(makeFlowStateActionHeader(flow_state_id));
	sb.append(addTab("listFlowStateAction",collapseItems,""));
	
	
	return sb.toString();
}
//********************************************************************************
String makeFlowStateActionHeader(String flow_state_id) {
	StringBuilder sb=new StringBuilder();
	sb.append("<hr>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewFlowStateAction('"+flow_state_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Action");
	sb.append("</span>");
	sb.append("</button>");
	
	sb.append("</div>");
	sb.append("</div>");

	return sb.toString();
}
//********************************************************************************
String makeFlowStateActionEditor(
		Connection conn,
		HttpSession session,
		String action_id
		) {
	
	
	String sql="";
	sql="select flow_state_id, action_name, action_type, action_description, "+
		" next_state_id, email_template_id, repository_action "+
		" from mad_flow_state_action where id=?";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",action_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	
	String flow_state_id=arr.get(0)[0];
	String action_name=arr.get(0)[1];
	String action_type=arr.get(0)[2];
	String action_description=arr.get(0)[3];
	String next_state_id=arr.get(0)[4];
	String email_template_id=arr.get(0)[5];
	String repository_action=arr.get(0)[6];

	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=flow_state_action_editor_"+action_id+">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" align=right>");
	sb.append("<button type=button class=\"btn btn-sm btn-danger\" onclick=\"javascript:deleteFlowStateAction('"+flow_state_id+"','"+action_id+"');\">");
	sb.append("<span class=\"glyphicon glyphicon-remove\">");
	sb.append(" Delete Action  " );
	sb.append("</span>");
	sb.append("</button>");
	sb.append(" ");
	sb.append("</div>");
	sb.append("</div>");

	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Action Name : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("action_name", action_name, " onchange=\"saveFlowStateActionField(this, '"+action_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Action Description : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append("<textarea rows=2 style=\"width:100%\" id=action_description onchange=\"saveFlowStateActionField(this, '"+action_id+"');\" >"+action_description+"</textarea>");
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Action Type : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select 'HUMAN','Manual Action' from dual union all select 'JS','Automated Action' from dual";
	bindlist.clear();
	ArrayList<String[]> actTypeArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append(makeComboArr(actTypeArr, "", "id=action_type onchange=\"saveFlowStateActionField(this, '"+action_id+"');\"", action_type, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Next State : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, concat(state_title,' (',state_name,')') from mad_flow_state where  id!=? and flow_id in (select flow_id from mad_flow_state where id=?) order by 2";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",flow_state_id});
	bindlist.add(new String[]{"INTEGER",flow_state_id});
	ArrayList<String[]> nextStateArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sb.append(makeComboArr(nextStateArr, "", "id=next_state_id onchange=\"saveFlowStateActionField(this, '"+action_id+"');\"", next_state_id, 0));
	sb.append("</div>");
	sb.append("</div>");
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Methots to execute : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\" id=\"methodsToExecuteDivForAction_"+action_id+"\" >");
	sb.append(makeFlowStateActionMethodList(conn, session,action_id));
	sb.append("</div>");
	sb.append("</div>");
	

	
	
	
	sb.append("<div class=row>"); 
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Permissions Needed : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, concat(permission_name,' [',permission_level,']') from mad_permission  order by 2";
	bindlist.clear();
	ArrayList<String[]> permsAllArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	permsAllArr.add(0, new String[]{"-1","REQUEST [Owner]"});
	permsAllArr.add(0, new String[]{"-2","REQUEST [Direct Manager of Owner]"});
	permsAllArr.add(0, new String[]{"-3","GENERAL [Administator]"});
	permsAllArr.add(0, new String[]{"-4","GENERAL [Release Manager]"});
	permsAllArr.add(0, new String[]{"-5","GENERAL [Group Member]"});
	
	String inner_sql="select id, permission_name from mad_permission pi ";
	int a=0;
	for (int i=0;i<permsAllArr.size();i++) {
		String p_id=permsAllArr.get(i)[0];
		String p_name=permsAllArr.get(i)[1];
		if (Integer.parseInt(p_id)<0) {
			a++;
			inner_sql=inner_sql+ "\n union all \n";
			inner_sql=inner_sql+ " select '"+p_id+"','"+p_name+"' from dual \n";
		}
		else break;
	}
	
	
	sql="select permission_id, permission_name \n" 
		+"	from mad_flow_state_action_permissions m, ("+inner_sql+") p  \n" 
		+"	where  flow_state_action_id=? \n" 
		+"	and permission_id=p.id  \n"+
		" order by 2";	
	


	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",action_id});
	ArrayList<String[]> permsInActionArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	String event_listener="javascript:addRemoveActionPermission(\""+action_id+"\",\"#\");";
	sb.append(makePickList("0", "permissions_in_action_"+action_id, permsAllArr, permsInActionArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Email Template : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, template_name from mad_email_template order by 2";
	sb.append(makeCombo(conn, sql, "", "id=email_template_id onchange=\"saveFlowStateActionField(this, '"+action_id+"');\"", email_template_id,0));
	sb.append("</div>");
	sb.append("</div>");
	
	
	sb.append("<div class=row>"); 
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Groups to Notify: </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sql="select id, group_name from mad_group where group_type='NOTIFICATION'  order by 2";
	bindlist.clear();
	ArrayList<String[]> groupsAllArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	sql="select group_id, group_name " 
		+"	from mad_flow_state_action_groups m, mad_group g  " 
		+"	where  flow_state_action_id=? " 
		+"	and  group_id=g.id  " 
		+"	order by 2";


	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",action_id});
	ArrayList<String[]> notifyGroupsArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	event_listener="javascript:addRemoveNotificationGroup(\""+action_id+"\",\"#\");";
	sb.append(makePickList("0", "notification_groups_"+action_id, groupsAllArr, notifyGroupsArr, "", event_listener));
	sb.append("</div>");
	sb.append("</div>");
	
	
	
	


	
	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}
//********************************************************************************
String makeFlowStateActionMethodList(Connection conn, HttpSession session, String action_id) {
	StringBuilder sb=new StringBuilder();
	
	String sql="select id, execution_order, execution_type, method_id, is_valid, retry_count, on_fail "+
				" from mad_flow_state_action_methods "+
				" where flow_state_action_id=? order by execution_order";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",action_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	if (arr.size()==0) {
		sb.append("No method added. <b><a href=\"javascript:addNewActionMethod('"+action_id+"')\">Click here</a></b>  to add a method");
		return sb.toString();
	}
	
	
	sb.append("<button type=button class=\"btn btn-success btn-sm\" onclick=addNewActionMethod('"+action_id+"')>");
	sb.append("Add New Method");
	sb.append("</button>");
	
	sb.append("<table class=\"table table-condensed table-striped table-bordered\">");
	
	sb.append("<tr class=info>");
	sb.append("<td></td>");
	sb.append("<td><b>Method</b></td>");
	sb.append("<td><b>Par.</b></td>");
	sb.append("<td><b>Type</b></td>");
	sb.append("<td><b>On Fail</b></td>");
	sb.append("<td><b>Retry#</b></td>");
	sb.append("<td><b>Active</b></td>");
	sb.append("<td></td>");
	sb.append("</tr>");
	
	sql="select id, concat(method_name, ' [',method_type,']') from mad_method order by 2"; 
	bindlist.clear();
	ArrayList<String[]> methodArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	ArrayList<String[]> execType=new ArrayList<String[]>();
	execType.add(new String[]{"SYNCH"});
	execType.add(new String[]{"ASYNCH"});
	
	ArrayList<String[]> yesnoArr=new ArrayList<String[]>();
	yesnoArr.add(new String[]{"YES"});
	yesnoArr.add(new String[]{"NO"});
	
	ArrayList<String[]> retryArr=new ArrayList<String[]>();
	for (int i=0;i<100;i++) retryArr.add(new String[]{""+i});
	
	ArrayList<String[]> onFailArr=new ArrayList<String[]>();
	onFailArr.add(new String[]{"STOP","Stop"});
	onFailArr.add(new String[]{"CONTINUE","Continue"});
		
	
	for (int i=0;i<arr.size();i++) {
		String action_method_id=arr.get(i)[0];
		String execution_order=arr.get(i)[1];
		String execution_type=arr.get(i)[2];
		String method_id=arr.get(i)[3];
		String is_valid=arr.get(i)[4];
		String retry_count=arr.get(i)[5];
		String on_fail=arr.get(i)[6];
		
		sb.append("<tr>");
		
		
		sb.append("<td align=center nowrap>");
		if (i>0) {
			sb.append("<span class=badge onclick=reorderFlowStateActionMethod('"+action_id+"','"+execution_order+"','UP')>");
			sb.append("<span class=\"glyphicon glyphicon-arrow-up\"></span>");
			sb.append("</span>");
		}
		
		if (i<arr.size()-1) {
			sb.append("<span class=badge onclick=reorderFlowStateActionMethod('"+action_id+"','"+execution_order+"','DOWN')>");
			sb.append("<span class=\"glyphicon glyphicon-arrow-down\"></span>");
			sb.append("</span>");
		}
		sb.append("</td>");
		

		
		sb.append("<td>");
		sb.append(makeComboArr(methodArr, "", "size=1 id=method_id  onchange=\"saveFlowStateActionMethodField(this, '"+action_method_id+"');\"", method_id, 0));
		sb.append("</td>");
		
		sb.append("<td align=center>");
		sb.append("<button type=button class=\"btn btn-primary btn-sm\" onclick=setFlowStateActionMethodParameters('"+action_method_id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-edit\"></span>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(execType, "", "size=1 id=execution_type  onchange=\"saveFlowStateActionMethodField(this, '"+action_method_id+"');\"", execution_type, 90));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(onFailArr, "", "size=1 id=on_fail  onchange=\"saveFlowStateActionMethodField(this, '"+action_method_id+"');\"", on_fail, 100));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(retryArr, "", "size=1 id=retry_count  onchange=\"saveFlowStateActionMethodField(this, '"+action_method_id+"');\"", retry_count, 80));
		sb.append("</td>");
		
		sb.append("<td>");
		sb.append(makeComboArr(yesnoArr, "", "size=1 id=is_valid  onchange=\"saveFlowStateActionMethodField(this, '"+action_method_id+"');\"", is_valid, 80));
		sb.append("</td>");

		

		sb.append("<td align=center>");
		sb.append("<button type=button class=\"btn btn-danger btn-sm\" onclick=removeFlowStateActionMethod('"+action_id+"','"+action_method_id+"')>");
		sb.append("<span class=\"glyphicon glyphicon-remove\"></span>");
		sb.append("</button>");
		sb.append("</td>");

		sb.append("</tr>");
		
	}
	sb.append("</table>");
	return sb.toString();
}
//********************************************************************************
void deleteFlowState(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",id});
	
	sql="delete from  mad_flow_state_action where flow_state_id in (select id from mad_flow_state where id=?)  ";
	execDBConf(conn, sql, bindlist);
	
	sql="delete from  mad_flow_state where id=? ";
	
	
	execDBConf(conn, sql, bindlist);
	
}
//********************************************************************************
void addRemoveStateEditPermission(
		Connection conn,
		HttpSession session,
		String flow_state_id,
		String addremove,
		String permission_id) {
	
	String sql="insert into mad_flow_state_edit_permissions (flow_state_id,permission_id ) values (?,?)";
	if (addremove.equals("REMOVE"))
		sql="delete from mad_flow_state_edit_permissions where flow_state_id=? and permission_id=? ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",flow_state_id});
	bindlist.add(new String[]{"INTEGER",permission_id});
	
	execDBConf(conn, sql, bindlist);
}

//********************************************************************************
int addNewFlowStateAction(
		Connection conn,
		HttpSession session,
		String flow_state_id,
		String action_name
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from mad_flow_state_action where action_name=? and flow_state_id=?";
	bindlist.add(new String[]{"STRING",action_name});
	bindlist.add(new String[]{"INTEGER",flow_state_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  mad_flow_state_action (action_name, flow_state_id, action_type) values(?, ?, 'HUMAN') ";
	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;

	
	return 0;
}

//********************************************************************************
void deleteFlowStateAction(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",id});
	
	
	sql="delete from  mad_flow_state_action where id=? ";
	
	
	execDBConf(conn, sql, bindlist);
}

//********************************************************************************
void addRemoveActionPermission(
		Connection conn,
		HttpSession session,
		String flow_state_action_id,
		String addremove,
		String permission_id) {
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="insert into mad_flow_state_action_permissions (flow_state_action_id,permission_id ) values (?,?)";
	if (addremove.equals("REMOVE"))
		sql="delete from mad_flow_state_action_permissions where flow_state_action_id=? and permission_id=? ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",flow_state_action_id});
	bindlist.add(new String[]{"INTEGER",permission_id});
	
	execDBConf(conn, sql, bindlist);
	
}

//********************************************************************************
void addRemoveActionGroup(
		Connection conn,
		HttpSession session,
		String flow_state_action_id,
		String addremove,
		String group_id) {
	
	String sql="insert into mad_flow_state_action_groups (group_id,flow_state_action_id ) values (?,?)";
	if (addremove.equals("REMOVE"))
		sql="delete from mad_flow_state_action_groups where group_id=? and flow_state_action_id=? ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",group_id});
	bindlist.add(new String[]{"INTEGER",flow_state_action_id});
	
	execDBConf(conn, sql, bindlist);
	
}
//********************************************************************************
int addNewMadActionMethod(
		Connection conn,
		HttpSession session,
		String action_id,
		String method_id
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String execution_order="1";
	
	sql="select max(execution_order) from mad_flow_state_action_methods where flow_state_action_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",action_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) 
		try{execution_order=""+(Integer.parseInt(arr.get(0)[0])+1);} catch(Exception e) {execution_order="1";}
	
	sql="select "+
		" param_default_val_1, "+
		" param_default_val_2, "+
		" param_default_val_3, "+
		" param_default_val_4, "+
		" param_default_val_5, "+
		" param_default_val_6, "+
		" param_default_val_7, "+
		" param_default_val_8, "+
		" param_default_val_9, "+
		" param_default_val_10 "+
		" from mad_method where id=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",method_id});
	ArrayList<String[]> parArr=getDbArrayConf(conn, sql, 1, bindlist);

	
	sql="insert into  mad_flow_state_action_methods (flow_state_action_id, method_id, execution_order, "+
				" value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10 " +
				"	) "+
		" values( ?, ?, ?,"+
				" ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ) ";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",action_id});
	bindlist.add(new String[]{"INTEGER",method_id});
	bindlist.add(new String[]{"INTEGER",execution_order});
	
	for (int v=0;v<parArr.get(0).length;v++) 
		bindlist.add(new String[]{"STRING",parArr.get(0)[v]});

	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	
	
	
	return 0;
}

//******************************************************************
void reorderFlowStateActionMethod(Connection conn, HttpSession session, String action_id, String execution_order, String direction) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	
	sql="select id from mad_flow_state_action_methods where flow_state_action_id=? and execution_order=?";
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",action_id});
	bindlist.add(new String[]{"INTEGER",execution_order});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String curr_id=arr.get(0)[0];
	
	sql="select id,execution_order  from mad_flow_state_action_methods where flow_state_action_id=?";
	
	if (direction.equals("UP")) 
		sql=sql +" and execution_order<? order by execution_order desc";
	else 
		sql=sql +" and execution_order>? order by execution_order asc";
		
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",action_id});
	bindlist.add(new String[]{"INTEGER",execution_order});
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String swap_id=arr.get(0)[0];
	String swap_execution_order=arr.get(0)[1];
	
	
	
	
	sql="update mad_flow_state_action_methods set execution_order=? where id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",swap_execution_order});
	bindlist.add(new String[]{"INTEGER",curr_id});
	execDBConf(conn, sql, bindlist);
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",execution_order});
	bindlist.add(new String[]{"INTEGER",swap_id});
	execDBConf(conn, sql, bindlist);
}

//********************************************************************************
void deleteFlowStateActionMethod(
		Connection conn,
		HttpSession session,
		String id
		) {
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"INTEGER",id});
	
	
	sql="delete from  mad_flow_state_action_methods where id=? ";
	execDBConf(conn, sql, bindlist);
}

//******************************************************************
String setMadFlowStateActionMethodParameters(Connection conn, HttpSession session, String action_method_id) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	StringBuilder sb=new StringBuilder();
	
	
	sql="select " +
		" 	parameter_count, method_name, method_id, "+
		"	param_name_1, param_name_2, param_name_3, param_name_4, param_name_5,  " +
		"	param_name_6, param_name_7, param_name_8, param_name_9, param_name_10, " +
		"	value_1, value_2, value_3, value_4, value_5,  " +
		"	value_6, value_7, value_8, value_9, value_10 " +
		"	from  " +
		"	mad_flow_state_action_methods am , mad_method m " +
		"	where am.id=? " +
		"	and am.method_id=m.id";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",action_method_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	int parameter_count=Integer.parseInt(arr.get(0)[0]);
	String method_name=arr.get(0)[1];
	String method_id=arr.get(0)[2];
	
	String[] param_names=new String[10];
	String[] values=new String[10];
	
	for (int i=0;i<10;i++) {
		param_names[i]=arr.get(0)[3+i];
		values[i]=arr.get(0)[3+10+i];
	}
	
	
	sb.append("<input type=hidden id=editing_method_id value="+method_id+">");
	sb.append("<input type=hidden id=editing_action_method_id value="+action_method_id+">");
	
	if (parameter_count==0) {
		sb.append("No parameters to edit.");
		return sb.toString();
	}
	
	
	
	
	sb.append("<h4><span class=\"label label-warning\">Parameters of  method [<b>"+method_name+"</b>]</span></h4>");
	
	sb.append("<table class=\"table table-condensed table-bordered table-striped\">");
	
	for (int i=0;i<parameter_count;i++) {
		sb.append("<tr>");
		sb.append("<td align=right nowrap><b>"+param_names[i]+" </b></td>");
		sb.append("<td>");
		sb.append(makeText("value_"+(i+1), clearHtml(values[i]), " onchange=\"saveFlowStateActionMethodField(this,'"+action_method_id+"'); \" ", 0));
		sb.append("</td>");
		sb.append("</tr>");		
	}
	sb.append("</table>");
	
	return sb.toString();
	
}

//------------------------------------------------------------------------------------
String getOtherColumnNames(Connection conn, HttpSession session, 
		String table_name, String naming_column_name, String link_column_name ) {
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	String sql="select column_name from information_schema.columns \n"+
				"	where table_name='"+table_name+"' and table_schema = DATABASE() \n"+
				"	and column_name not in ('id','"+naming_column_name+"','"+link_column_name+"')  \n"+
				"	order by ordinal_position";
	
	bindlist.clear();
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	String ret1="";
	for (int i=0;i<arr.size();i++) {
		String col_name=arr.get(i)[0];
		ret1=ret1+", "+col_name;
	} 
	
	return ret1;
}
//------------------------------------------------------------------------------------
void duplicateFlow(Connection conn, HttpSession session, String flow_id) {
	
	
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="SELECT AUTO_INCREMENT FROM information_schema.tables WHERE table_name = 'mad_flow' AND table_schema = DATABASE( )";
	bindlist.clear();
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String new_flow_id=arr.get(0)[0];
	sql="insert into mad_flow (id, flow_name #fields ) select ?, concat(flow_name,' Copy') #fields from mad_flow where id=?" ;
	
	
	String other_columns=getOtherColumnNames(conn, session, "mad_flow", "flow_name", "");
	sql=sql.replaceAll("#fields", other_columns);
	
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",new_flow_id});
	bindlist.add(new String[]{"INTEGER",flow_id});
	
	execDBConf(conn, sql, bindlist);
	
	
	
	ArrayList<String[]> flowStateMap=new ArrayList<String[]>();
	
	String other_fstate_columns=getOtherColumnNames(conn, session, "mad_flow_state", "", "flow_id");
	
	sql="select id from mad_flow_state where flow_id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",flow_id});
	
	ArrayList<String[]> flowStateArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	for (int fs=0;fs<flowStateArr.size();fs++) {
		
		
		
		sql="SELECT AUTO_INCREMENT FROM information_schema.tables WHERE table_name = 'mad_flow_state' AND table_schema = DATABASE( )";
		bindlist.clear();
		arr=getDbArrayConf(conn, sql, 1, bindlist);
		
		String flow_state_id=flowStateArr.get(fs)[0];
		String new_flow_state_id=arr.get(0)[0];
		
		
		
		sql="insert into mad_flow_state (id, flow_id #fields)   select ?, ? #fields from mad_flow_state where id=? ";
		sql=sql.replaceAll("#fields", other_fstate_columns);
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",new_flow_state_id});
		bindlist.add(new String[]{"INTEGER",new_flow_id});
		bindlist.add(new String[]{"INTEGER",flow_state_id});

		execDBConf(conn, sql, bindlist);
		
		flowStateMap.add(new String[]{flow_state_id,new_flow_state_id});
	}
	
	
	String cols_mad_flow_state_edit_permissions=getOtherColumnNames(conn, session, "mad_flow_state_edit_permissions", "", "flow_state_id");
	String cols_mad_flow_state_action=getOtherColumnNames(conn, session, "mad_flow_state_action", "next_state_id", "flow_state_id");
	
	ArrayList<String[]> flowStateActionMap=new ArrayList<String[]>();
	
	for (int i=0;i<flowStateMap.size();i++) {
		String flow_state_id=flowStateMap.get(i)[0];
		String new_flow_state_id=flowStateMap.get(i)[1];
		
		sql="insert into mad_flow_state_edit_permissions (flow_state_id #fields)   select ? #fields from mad_flow_state_edit_permissions where flow_state_id=? ";
		sql=sql.replaceAll("#fields", cols_mad_flow_state_edit_permissions);
		
		
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",new_flow_state_id});
		bindlist.add(new String[]{"INTEGER",flow_state_id});
		
		execDBConf(conn, sql, bindlist);
		
		sql="select id, next_state_id from mad_flow_state_action where flow_state_id=?";
		
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",flow_state_id});

		ArrayList<String[]> flowStateActionArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		
		for (int fsa=0;fsa<flowStateActionArr.size();fsa++) {
			
			
			String flow_state_action_id=flowStateActionArr.get(fsa)[0];
			String next_state_id=flowStateActionArr.get(fsa)[1];
			
			for (int m=0;m<flowStateMap.size();m++) {
				if (next_state_id.equals(flowStateMap.get(m)[0])) {
					//System.out.println("changing action["+flow_state_action_id+"] next_state from " +next_state_id+" to " +flowStateMap.get(m)[1]);
					next_state_id=flowStateMap.get(m)[1];
					break;
				}
			}
			
			sql="SELECT AUTO_INCREMENT FROM information_schema.tables WHERE table_name = 'mad_flow_state_action' AND table_schema = DATABASE( )";
			bindlist.clear();
			arr=getDbArrayConf(conn, sql, 1, bindlist);
			
			String new_flow_state_action_id=arr.get(0)[0];
			
			
			sql="insert into mad_flow_state_action (id, flow_state_id, next_state_id #fields)   select ?, ?, ? #fields from mad_flow_state_action where id=? ";
			sql=sql.replaceAll("#fields", cols_mad_flow_state_action);
			
			bindlist.clear();
			bindlist.add(new String[]{"INTEGER",new_flow_state_action_id});
			bindlist.add(new String[]{"INTEGER",new_flow_state_id});
			bindlist.add(new String[]{"INTEGER",next_state_id});
			bindlist.add(new String[]{"INTEGER",flow_state_action_id});
			
			execDBConf(conn, sql, bindlist);
			
			flowStateActionMap.add(new String[]{flow_state_action_id, new_flow_state_action_id});
			
		}
		
		
	}
	
	String cols_mad_flow_state_action_groups=getOtherColumnNames(conn, session, "mad_flow_state_action_groups", "", "flow_state_action_id");
	String cols_mad_flow_state_action_methods=getOtherColumnNames(conn, session, "mad_flow_state_action_methods", "", "flow_state_action_id");
	String cols_mad_flow_state_action_permissions=getOtherColumnNames(conn, session, "mad_flow_state_action_permissions", "", "flow_state_action_id");

	
	for (int i=0;i<flowStateActionMap.size();i++) {
		String flow_state_action_id=flowStateActionMap.get(i)[0];
		String new_flow_state_action_id=flowStateActionMap.get(i)[1];
		
		sql="insert into mad_flow_state_action_groups (flow_state_action_id #fields)   select ? #fields from mad_flow_state_action_groups where flow_state_action_id=? ";
		sql=sql.replaceAll("#fields", cols_mad_flow_state_action_groups);
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",new_flow_state_action_id});
		bindlist.add(new String[]{"INTEGER",flow_state_action_id});
		execDBConf(conn, sql, bindlist);
		
		sql="insert into mad_flow_state_action_methods (flow_state_action_id #fields)   select ? #fields from mad_flow_state_action_methods where flow_state_action_id=? ";
		sql=sql.replaceAll("#fields", cols_mad_flow_state_action_methods);
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",new_flow_state_action_id});
		bindlist.add(new String[]{"INTEGER",flow_state_action_id});
		execDBConf(conn, sql, bindlist);
		
		sql="insert into mad_flow_state_action_permissions (flow_state_action_id #fields)   select ? #fields from mad_flow_state_action_permissions where flow_state_action_id=? ";
		sql=sql.replaceAll("#fields", cols_mad_flow_state_action_permissions);
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",new_flow_state_action_id});
		bindlist.add(new String[]{"INTEGER",flow_state_action_id});
		execDBConf(conn, sql, bindlist);
		
		
	}
			
}

//*********************************************************************************
ArrayList<String[]> allFlexFieldsArr=new ArrayList<String[]>();

static final int FLEX_FIELDS_FLD_ID=0;
static final int FLEX_FIELDS_FLD_TITLE=1;
static final int FLEX_FIELDS_FLD_STRING_NAME=2;
static final int FLEX_FIELDS_FLD_ENTRY_TYPE=3;
static final int FLEX_FIELDS_FLD_ENTRY_VALIDATION_REGEX=4;
static final int FLEX_FIELDS_FLD_VALIDATION_SQL=5;
static final int FLEX_FIELDS_FLD_VALIDATION_ENV_ID=6;
static final int FLEX_FIELDS_FLD_FIELD_SIZE=7;
static final int FLEX_FIELDS_FLD_NUM_FIXED_LENGTH=8;
static final int FLEX_FIELDS_FLD_NUM_DECIMAL_LENGTH=9;
static final int FLEX_FIELDS_FLD_NUM_GROUPING_CHAR=10;
static final int FLEX_FIELDS_FLD_NUM_DECIMAL_CHAR=11;
static final int FLEX_FIELDS_FLD_NUM_CURRENCY_SYMBOL=12;
static final int FLEX_FIELDS_FLD_NUM_MIN_VAL=13;
static final int FLEX_FIELDS_FLD_NUM_MAX_VAL=14;


//*********************************************************************************
void initFlexFields(Connection conn,HttpSession session) {
	
	allFlexFieldsArr=(ArrayList<String[]>) session.getAttribute("FLEX_FIELDS_ARR");
	
	if (allFlexFieldsArr!=null) return;
	
	String sql="select \n"+
				"	id, \n"+
				"    title, \n"+
				"    string_name, \n"+
				"    entry_type, \n"+
				"    entry_validation_regex, \n"+
				"    validation_sql, \n"+
				"    validation_env_id, \n"+
				"    field_size, \n"+
				"    num_fixed_length, \n"+
				"    num_decimal_length, \n"+
				"    num_grouping_char, \n"+
				"    num_decimal_char, \n"+
				"    num_currency_symbol, \n"+
				"    num_min_val, \n"+
				"    num_max_val \n"+
				" from mad_flex_field ";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	allFlexFieldsArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
}

//*********************************************************************************
ArrayList<String[]> getFlexFields(
		Connection conn, 
		HttpSession session, 
		String module,
		String domain,
		String tree_type
		) {
	
	ArrayList<String[]> flexFields=new ArrayList<String[]>();
	
	String sql="select flex_field_id "+
				" from tdm_test_tree_fields "+
				" where module=? and domain_id=? and tree_type=? "+
				" order by order_by ";
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",module});
	bindlist.add(new String[]{"INTEGER",domain});
	bindlist.add(new String[]{"STRING",tree_type});

	flexFields=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	


	return flexFields;
}

//*********************************************************************************
int getFlexFieldArrId(String flex_field_db_id) {
	
	
	for (int i=0;i<allFlexFieldsArr.size();i++) {
		if (allFlexFieldsArr.get(i)[FLEX_FIELDS_FLD_ID].equals(flex_field_db_id)) return i;
	}
	return -1;
}
//*********************************************************************************

static final String FLEX_VALUES_SQL=""+
		"select flex_field_id, "+
			" val_string, "+
			" val_memo, "+
			" date_format(val_datetime,?) val_datetime, "+
			" round(val_numeric,8) val_numeric "+
		" from tdm_test_tree_values "+
		" where tree_id=?";

ArrayList<String[]> getFlexValues(
		Connection conn, 
		HttpSession session, 
		String flex_form_id
		) {
	
	ArrayList<String[]> flexValues=new ArrayList<String[]>();
	
	if (nvl(flex_form_id,"0").equals("0")) return flexValues;

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"STRING",mysql_format});
	bindlist.add(new String[]{"LONG",flex_form_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, FLEX_VALUES_SQL, Integer.MAX_VALUE, bindlist);
	
	for (int i=0;i<arr.size();i++) {
		String flex_field_db_id=arr.get(i)[0];
		int flex_field_arr_id=getFlexFieldArrId(flex_field_db_id);
		if (flex_field_arr_id==-1) continue;
		String entry_type=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_ENTRY_TYPE];
		
		String val="";
		if (entry_type.equals("NUMBER")) 
			val=arr.get(i)[4];
		else if (entry_type.equals("DATE") || entry_type.equals("DATETIME")) 
			val=arr.get(i)[3];
		else if (entry_type.equals("MEMO")) 
			val=arr.get(i)[2];
		else 
			val=arr.get(i)[1];
		
		
		flexValues.add(new String[]{flex_field_db_id,val});
		
	}
	
	
	return flexValues;
}

//*********************************************************************************
String makeFlexForm(
		Connection conn, 
		HttpSession session,
		String tree_id, 
		String tree_type, 
		String is_editable, 
		String direction,
		String parent_id
		) {
	
	StringBuilder sb=new StringBuilder();

	String module=getCurrentModule(session);
	String domain=getCurrentDomain(session);
	
	String flex_form_id=nvl(tree_id,"0");
	
	ArrayList<String[]> flexFields=getFlexFields(conn,session, module,domain,tree_type);
	
	if (flexFields.size()==0) return "";
	
	ArrayList<String[]> flexValues=getFlexValues(conn,session,tree_id);
	
	int FLEX_VAL_FIELD_ID=0;
	int FLEX_VAL_FIELD_VAL=1;
	
	initFlexFields(conn, session);
	
	ArrayList<String[]> fieldsArr=new ArrayList<String[]>();
	
	
	
	
	for (int f=0;f<flexFields.size();f++) {

		String flex_field_db_id=flexFields.get(f)[0];
		int flex_field_arr_id=getFlexFieldArrId(flex_field_db_id);
		
		if (flex_field_arr_id==-1) {
			System.out.println("Flex field is not loaded.");
			continue;
		}
		
		
		String curr_val="";
		for (int v=0;v<flexValues.size();v++) {
			if (flexValues.get(v)[FLEX_VAL_FIELD_ID].equals(flex_field_db_id)) {
				curr_val=flexValues.get(v)[FLEX_VAL_FIELD_VAL];
				break;
			}
		}
		
		
		
		String flex_field_title			=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_TITLE];
		String flex_field_string_name	=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_STRING_NAME];

		
		String flex_field_title_decoded	=decodeStringTitle(conn, session, flex_field_title, flex_field_string_name, true);
		String flex_field_entry_type	=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_ENTRY_TYPE];
		
		
		String field_str="";
		String id=tree_id+"_"+flex_field_db_id;
		
		String disabled="";		
		if (is_editable.equals("NO")) disabled="disabled";
		
		String field_name_id=tree_id;
		if (tree_type.equals("step")) field_name_id=parent_id;
		
		if (flex_field_entry_type.equals("TEXT")) {
			field_str=makeText(id, curr_val, disabled+" name=\"fields_of_tree_"+field_name_id+"\" ", 0);
		}
		else if (flex_field_entry_type.equals("PASSWORD")) {
			field_str=makePassword(id, curr_val, disabled+" name=\"fields_of_tree_"+field_name_id+"\" ", 0);
		}
		else if (flex_field_entry_type.equals("LIST")) {
			String flex_field_sql			=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_VALIDATION_SQL];
			String flex_field_env_id		=nvl(allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_VALIDATION_ENV_ID],"0");
			
			String field_mode="EDITABLE";
			
			field_str=makeList(conn, session, id, flex_field_sql, curr_val,  disabled+" name=\"fields_of_tree_"+field_name_id+"\" ", 0, flex_field_env_id, field_mode, true);
			
		}
		else if (flex_field_entry_type.equals("PICKLIST")) {
			
			
			String flex_field_sql			=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_VALIDATION_SQL];
			String flex_field_env_id		=nvl(allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_VALIDATION_ENV_ID],"0");
			
			ArrayList<String[]> arrPicklist=getArrayForList(conn, session, "picklist_content_of_"+flex_field_db_id, flex_field_sql, flex_field_env_id, true);
			
			ArrayList<String[]> picked_arr=new ArrayList<String[]>();
			String[] arritems=curr_val.split("\\|::\\|");
			for (int a=0;a<arritems.length;a++) {
				if (arritems[a].trim().length()==0) continue;
				picked_arr.add(new String[]{arritems[a]});
			}
			
			String field_mode="EDITABLE";
			if (disabled.equals("disabled")) field_mode="READONLY";
			
			field_str=makePickList("0", id, arrPicklist, picked_arr, "", "  ", " name=\"fields_of_tree_"+field_name_id+"\"  ", field_mode);
			
			
		}
		else if (flex_field_entry_type.equals("MEMO")) {
			field_str="<textarea "+ disabled+" name=\"fields_of_tree_"+field_name_id+"\" rows=3 id=\""+id+"\" style=\"width:100%; font-family: monospace; \">"+clearHtml(curr_val)+"</textarea>";
			
		}
		else if (flex_field_entry_type.equals("CHECKBOX")) {
			String ch_def_val="NO";
			String field_mode="EDITABLE";
			if (disabled.equals("disabled")) field_mode="READONLY";
			field_str=makeCheckbox("0", id, codehtml(nvl(curr_val,ch_def_val)), " name=\"fields_of_tree_"+field_name_id +"\" ", field_mode);
			
		}
		else if (flex_field_entry_type.equals("DATE")) {
			String field_mode="EDITABLE";
			if (disabled.equals("disabled")) field_mode="READONLY";
			field_str=makeDate("0", id, curr_val,  " name=\"fields_of_tree_"+field_name_id+"\" ",field_mode);
			
		}
		else if (flex_field_entry_type.equals("DATETIME")) {
			String field_mode="EDITABLE";
			if (disabled.equals("disabled")) field_mode="READONLY";
			
			field_str=makeDate("0", id, curr_val, " name=\"fields_of_tree_"+field_name_id+"\" ",field_mode);
			
			
		}
		else if (flex_field_entry_type.equals("NUMBER")) {
			
			String num_fixed_length=nvl(allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_NUM_FIXED_LENGTH],"12");
			String num_decimal_length=nvl(allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_NUM_DECIMAL_LENGTH],"0");
			String num_grouping_char=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_NUM_GROUPING_CHAR];
			String num_decimal_char=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_NUM_DECIMAL_CHAR];
			String num_currency_symbol=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_NUM_CURRENCY_SYMBOL];
			String num_min_val=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_NUM_MIN_VAL];
			String num_max_val=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_NUM_MAX_VAL];
			
			String field_mode="EDITABLE";
			if (disabled.equals("disabled")) field_mode="READONLY";
			String validation_script="";
			
			field_str=makeNumber("0", 
					id, 
					curr_val ,
					validation_script, 
					field_mode, 
					num_fixed_length, 
					num_decimal_length,
					num_grouping_char,
					num_decimal_char,
					num_currency_symbol,
					num_min_val,
					num_max_val,
					" name=\"fields_of_tree_"+field_name_id+"\"");
			
		}
		else 
			field_str="Unsupported entry type : "+flex_field_entry_type;
		
		fieldsArr.add(new String[]{id, flex_field_title_decoded, field_str});
		
		
		
		
	}
	
	//sb.append("<table class=\"table table-condensed table-sriped table-bordered\">");
	sb.append("<table width=\"100%\" border=0 cellspacin=0 cellpadding=0>");
	
	if (direction.equals("horizontal")) sb.append("<tr>");
	
	for (int f=0;f<fieldsArr.size();f++) {
		String title_str=fieldsArr.get(f)[1];
		String field_str=fieldsArr.get(f)[2];
		
		
		if (direction.equals("vertical")) sb.append("<tr>");
		
		
		if (direction.equals("vertical")) {
			sb.append("<td align=right valign=top width=\"20%\">");
			sb.append("<b>");
			sb.append(title_str);
			sb.append(" : </b>");
			sb.append("</td>");
		}
		


		if (direction.equals("vertical"))
			sb.append("<td width=\"85%\">");
		else 
			sb.append("<td>");
		
		if (direction.equals("horizontal")) {
			sb.append("<b>");
			sb.append(title_str);
			sb.append(" : </b>");
			sb.append("<br>");
		}
		
		sb.append(field_str);
		sb.append("</td>");
		
		if (direction.equals("vertical"))  sb.append("</tr>");
		
	}
	if (direction.equals("horizontal")) sb.append("</tr>");
	sb.append("</table>");
	
	return sb.toString();
}

//*********************************************************************************
String makeSetTestParameterForm(Connection conn, HttpSession session, String tree_id) {
	
	StringBuilder sb=new StringBuilder();
	
	boolean is_editing=isCheckinAvailable(conn, session, tree_id);
	String disabled="";
	if (!is_editing) disabled="disabled";
	
	String tree_title=getTreeAttributeValue(conn, session, tree_id, "tree_title");
	String tree_path=getTreeElementPath(conn, session, tree_id);
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select id, parameter_direction, flex_field_id, parameter_title, parameter_name, parameter_scope, default_value  "+
			" from tdm_test_tree_parameters "+
			" where tree_id=?  order by parameter_title ";
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",tree_id});
	
	ArrayList<String[]> parameters=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	ArrayList<String[]> dirArr=new ArrayList<String[]>();
	dirArr.add(new String[]{"IN","Input Parameters"});
	dirArr.add(new String[]{"OUT","Output Parameters"});
	
	ArrayList<String[]> scopeArr=new ArrayList<String[]>();
	scopeArr.add(new String[]{"GLOBAL","Global"});
	scopeArr.add(new String[]{"LOCAL","Local"});
	
	sql="select id, title  from mad_flex_field where entry_type in ('TEXT','LIST','PASSWORD') order by 2 ";
	bindlist.clear();
	ArrayList<String[]> flexArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	sb.append("<table class=table>");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right><b>ID</b></td>");
	sb.append("<td width=\"100%\">");
	sb.append("<big><big><span class=\"label label-info\">"+tree_id+"</span></big></big>");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right><b>Path</b></td>");
	sb.append("<td width=\"100%\">");
	sb.append(limitString(tree_path, 200));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right><b>Title</b></td>");
	sb.append("<td width=\"100%\">");
	sb.append(limitString(tree_title, 200));
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("</table>");
	
	sb.append("<input type=hidden id=test_parameter_tree_id value="+tree_id+">");
	
	for (int d=0;d<dirArr.size();d++) {
		String direction=dirArr.get(d)[0];
		String direction_title=dirArr.get(d)[1];
		
	
		sb.append("<table class=table>");
		

		sb.append("<tr class=warning >");

		
		sb.append("<td>");
		sb.append("<button "+disabled+" type=button class=\"btn btn-sm btn-default\" onclick=addTestParameter('"+direction+"')>");
		sb.append("<font color=green><span class=\"glyphicon glyphicon-plus\"></span></font> Add ["+direction+"] Parameter");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("<td width=\"100%\">");
		sb.append("<b><big>"+direction_title+"</big></b>");
		sb.append("</td>");
		
		
		sb.append("</tr>");
		
		sb.append("</table>");
		
		
		sb.append("<table class=\"table table-condensed\">");
		
		int c=0;
		
		for (int p=0;p<parameters.size();p++) {
			String parameter_id=parameters.get(p)[0];
			String parameter_direction=parameters.get(p)[1];
			
			if (!parameter_direction.equals(direction)) continue;
			
			String flex_field_id=parameters.get(p)[2];
			String parameter_title=parameters.get(p)[3];
			String parameter_name=parameters.get(p)[4];
			String parameter_scope=parameters.get(p)[5];
			String default_value=parameters.get(p)[6];
			
			
			c++;
			
			sb.append("<tr class=success>");
			sb.append("<td>");
			sb.append("<big><span class=\"badge\">["+direction+"  "+(c)+"]</span></big>");
			sb.append("</td>");
			sb.append("<td align=right>");
			sb.append("<button "+disabled+" type=button class=\"btn btn-sm btn-default\" onclick=removeTestParameter('"+parameter_id+"')>");
			sb.append("<font color=red><span class=\"glyphicon glyphicon-minus\"></span></font>");
			sb.append("</button>");
			sb.append("</td>");
			sb.append("</tr>");
			
			sb.append("<tr>");
			sb.append("<td nowrap align=right><b>Parameter Title : </b></td>");
			sb.append("<td width=\"80%\">");
			sb.append(makeText("parameter_title", parameter_title, disabled+" onchange=saveTestParameterField(this,'"+parameter_id+"') ", 0));
			sb.append("</td>");
			sb.append("</tr>");
			
			sb.append("<tr>");
			sb.append("<td nowrap align=right><b>Parameter Name : </b></td>");
			sb.append("<td width=\"80%\">");
			sb.append(makeText("parameter_name", parameter_name, disabled+" onchange=saveTestParameterField(this,'"+parameter_id+"') ", 0));
			sb.append("</td>");
			sb.append("</tr>");
			
			if (direction.equals("IN")) {
				
				sb.append("<tr>");
				sb.append("<td nowrap align=right><b>Scope : </b></td>");
				sb.append("<td width=\"80%\">");
				sb.append(makeComboArr(scopeArr, "", disabled+" id=parameter_scope  size=1  onchange=saveTestParameterField(this,'"+parameter_id+"') ", parameter_scope, 0));
				sb.append("</td>");
				sb.append("</tr>");
				
				sb.append("<tr>");
				sb.append("<td nowrap align=right><b>Flex Field : </b></td>");
				sb.append("<td width=\"80%\">");
				sb.append(makeComboArr(flexArr, "", disabled+" id=flex_field_id   onchange=saveTestParameterField(this,'"+parameter_id+"') ", flex_field_id, 0));
				sb.append("</td>");
				sb.append("</tr>");
				
				sb.append("<tr>");
				sb.append("<td nowrap align=right><b>Default : </b></td>");
				sb.append("<td width=\"80%\">");
				sb.append(makeText("default_value", default_value, disabled+" onchange=saveTestParameterField(this,'"+parameter_id+"') ", 0));
				sb.append("</td>");
				sb.append("</tr>");
				
			}
			
			
			
			
			

			
		}
		
		sb.append("</table>");
		
		
	}
	
	return sb.toString();
}


//*********************************************************************************
void addTestParameter(Connection conn, HttpSession session, String test_id, String direction) {
	
	String sql="insert into tdm_test_tree_parameters (ID,tree_id, parameter_direction, parameter_title, parameter_name)  values (?,?,?,?,?)";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String id=getTS();
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",getTS()});
	bindlist.add(new String[]{"LONG",test_id});
	bindlist.add(new String[]{"STRING",direction});
	bindlist.add(new String[]{"STRING","PARAM_"+id});
	bindlist.add(new String[]{"STRING","PARAM_"+id});
	
	execDBConf(conn, sql, bindlist);
	
}
//*********************************************************************************
void removeTestParameterDO(Connection conn, HttpSession session, String tree_id, String parameter_id,  StringBuilder err) {
		
	
	boolean is_checkin_available=isCheckinAvailable(conn,session,tree_id);
		
		if (!is_checkin_available) {
			err.append("This node is not available for check in.");
			return;
		}
		
		String active_tree_id=getCurrentTreeId(session);
		
		if (!active_tree_id.equals(tree_id)) {
			err.append("This node is not open for edit. Hacking me? Try harder ;) ");
			return;
		}
		
		String sql="delete from tdm_test_tree_parameters where id=? and tree_id=?";
		
		ArrayList<String[]> bindlist=new 	ArrayList<String[]>();
		
		bindlist.clear();
		bindlist.add(new String[]{"LONG",parameter_id});
		bindlist.add(new String[]{"LONG",tree_id});
		
		boolean is_deleted=execDBConf(conn, sql, bindlist);
		
		
		if (!is_deleted) 
			err.append("Can not deleted!");
		
}

//*********************************************************************************
String maketreeNodePicker(
		Connection conn, 
		HttpSession session,
		String element_id,
		String module,
		String domain,
		String curr_tree_id
		) {
	
	StringBuilder sb=new StringBuilder();


	
	
	sb.append("<input type=hidden id=\""+element_id+"\" value=\""+curr_tree_id+"\">");
	sb.append("<input type=hidden id=\"MODULE_OF_"+element_id+"\" value=\""+module+"\">");
	sb.append("<input type=hidden id=\"DOMAIN_OF_"+element_id+"\" value=\""+domain+"\">");
	sb.append("<input type=hidden id=\"CLICKED_OF_"+element_id+"\" value=\""+curr_tree_id+"\">");
	
	
	
	sb.append("<button  type=button class=\"btn btn-sm btn-default\" onclick=\"openTreeNodePicker('"+element_id+"');\" >");
	sb.append("<font color=black><span class=\"glyphicon glyphicon-folder-open\"></span></font> ... ");
	sb.append("</button>");
	
	sb.append("<div id=\"TREE_PICKER_DIV_"+element_id+"\">");
	sb.append(maketreeNodePickerSelection(conn, session, element_id, curr_tree_id));
	sb.append("</div>");
	
	
	
	return sb.toString();
	
}

//*********************************************************************************
String maketreeNodePickerSelection(
		Connection conn, 
		HttpSession session,
		String element_id,
		String curr_tree_id
		) {
	
	StringBuilder sb=new StringBuilder();
	
	String picked_tree_path="";
	String picked_tree_title="";
	
	if (!nvl(curr_tree_id,"0").equals("0")) {
		picked_tree_path=getTreeElementPath(conn, session, curr_tree_id);
		picked_tree_title=getTreeAttributeValue(conn, session, curr_tree_id, "tree_title");

			sb.append("<table class=table>");
			
			sb.append("<tr class=warning>");
			sb.append("<td>");
			sb.append("<big><span class=\"label label-info\">"+curr_tree_id+"</span></big>");
			sb.append("</td>");
			sb.append("</tr>");
			
			sb.append("<tr class=warning>");
			sb.append("<td>");
			sb.append(nvl(picked_tree_path,"none"));
			sb.append("</td>");
			sb.append("</tr>");
			
			
			
			
			sb.append("<tr class=warning>");
			sb.append("<td>");
			sb.append(" ["+clearHtml(picked_tree_title)+"]");
			sb.append("</td>");
			sb.append("</tr>");
	
			
			sb.append("</table>");	
		
	} 
	
	
	
	
	
	return sb.toString();
	
}

//*********************************************************************************
String makeStepTestReferenceForm(Connection conn, HttpSession session) {

	StringBuilder sb=new StringBuilder();

	
	
	sb.append("<table class=table>");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right><b>Reference Test : </b></td>");
	sb.append("<td width=\"100%\">");
	
	
	
	String id="calling_test_id";
	String sel_module=getCurrentModule(session);
	String sel_domain=getCurrentDomain(session);
	String onNodeSelectionEvent="";
	 
	
	
	sb.append(
				maketreeNodePicker(
					conn, 
					session, 
					id, 
					sel_module, 
					sel_domain, 
					"0"
				)
			);
	
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("</table>");
	
	
	
	
	return sb.toString();
}
//*********************************************************************************
String makeReferenceTestForm(Connection conn, HttpSession session, 
		String step_id, 
		String referenced_test_id, 
		String is_editable,
		String parent_tree_id
		) {

	StringBuilder sb=new StringBuilder();
	
	
	
	
	String ref_tree_path=getTreeElementPath(conn, session, referenced_test_id);
	String ref_tree_title=getTreeAttributeValue(conn, session, referenced_test_id, "tree_title");

	sb.append("<table class=table>");
	
	sb.append("<tr class=warning>");
	sb.append("<td colspan=2>");
	sb.append("<span class=\"badge\">"+referenced_test_id+"</span> ");
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr class=warning>");
	sb.append("<td nowrap align=right><b>Calling Test : </b></td>");
	sb.append("<td nowrap width=\"100%\">");
	sb.append(clearHtml(ref_tree_title));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr class=warning>");
	sb.append("<td nowrap align=right><b>Calling Path : </b></td>");
	sb.append("<td width=\"100%\">");
	sb.append(ref_tree_path);
	sb.append("</td>");
	sb.append("</tr>");
	

	

	
	sb.append("<tr class=warning>");
	sb.append("<td nowrap align=right><b>Parameters : </b></td>");
	sb.append("<td width=\"100%\">");
	sb.append(makeReferenceTestParameterEntryForm(conn,session,step_id,referenced_test_id,is_editable, parent_tree_id));
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("</table>");
	
	
	
	
	return sb.toString();
}
//*********************************************************************************
String makeReferenceTestParameterEntryForm(Connection conn, HttpSession session, 
		String step_id, 
		String referenced_test_id, 
		String is_editable,
		String parent_tree_id
		) {

	StringBuilder sb=new StringBuilder();
	
	String sql="";
	sql="select id, parameter_title , parameter_name, default_value, flex_field_id "+
		" from tdm_test_tree_parameters where parameter_direction='IN' and parameter_scope='GLOBAL' and flex_field_id!=null and tree_id=? "+
		" order by parameter_title";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"LONG",referenced_test_id});
	
	
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	if (arr.size()==0) return "<span class=\"label label-warning\">no global input parameter defined!</span>";
	
	sql="select parameter_id, parameter_value "+
		" from tdm_test_call_parameter_values "+
		" where tree_id=? and referenced_test_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"LONG",step_id});
	bindlist.add(new String[]{"LONG",referenced_test_id});

	ArrayList<String[]> valsArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	String disabled="";
	if (is_editable.equals("NO")) disabled="disabled";

	sb.append("<table class=table>");
	
	sb.append("<tr class=info>");
	sb.append("<td><b><small>#</small></b></td>");
	sb.append("<td><b><small>Title</small></b></td>");
	sb.append("<td><b><small>Actual Value</small></b></td>");
	sb.append("<td><b><small>Param Name</small></b></td>");
	sb.append("<td><b><small>Default</small></b></td>");
	sb.append("</tr>");
	
	initFlexFields(conn, session);
	
	for (int i=0;i<arr.size();i++) {
		String parameter_id=arr.get(i)[0];
		String parameter_title=arr.get(i)[1];
		String parameter_name=arr.get(i)[2];
		String default_value=arr.get(i)[3];
		String flex_field_id=arr.get(i)[4];
		int flex_field_arr_id=getFlexFieldArrId(flex_field_id);
		
		if (flex_field_arr_id==-1) {
			System.out.println("flex_field_arr_id="+flex_field_arr_id+" not found  for "+flex_field_id+", tree_id="+step_id+", referenced_test_id="+referenced_test_id);
			continue;
		}
		
		
		
		String entry_type=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_ENTRY_TYPE];
		
		String curr_parameter_val=default_value;

		
		for (int v=0;v<valsArr.size();v++) 
			if (valsArr.get(v)[0].equals(parameter_id)) {
				curr_parameter_val=valsArr.get(v)[1];
				break;
			}
		
		sb.append("<tr>");
		sb.append("<td class=info><small><span class=badge>P"+(i+1)+"</span></small></td>");
		sb.append("<td nowrap align=right><small>"+limitString(clearHtml(parameter_title),40)+" : </small></td>");
		sb.append("<td width=\"100%\">");
		
		String id=step_id+"."+referenced_test_id+"_"+parameter_id;
		
		if (entry_type.equals("LIST")) {
			String flex_field_sql			=allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_VALIDATION_SQL];
			String flex_field_env_id		=nvl(allFlexFieldsArr.get(flex_field_arr_id)[FLEX_FIELDS_FLD_VALIDATION_ENV_ID],"0");
			
			String field_mode="EDITABLE";
			
			sb.append(makeList(conn, session, id, flex_field_sql, curr_parameter_val,  disabled+" name=\"parameters_of_tree_"+parent_tree_id+"\" ", 0, flex_field_env_id, field_mode, true));
			
		}
		else if (entry_type.equals("PASSWORD"))
			sb.append(makePassword(id, curr_parameter_val, disabled+" name=\"parameters_of_tree_"+parent_tree_id+"\" ", 0));
		else 
			sb.append(makeText(id, curr_parameter_val, disabled+" name=\"parameters_of_tree_"+parent_tree_id+"\" ", 0));
		
		sb.append("</td>");
		sb.append("<td><small>${<b>"+clearHtml(parameter_name)+"</b>}</small></td>");
		sb.append("<td><small>"+clearHtml(default_value)+"</small></td>");
		sb.append("</tr>");
	}
	
	
	
	
	
	sb.append("</table>");
	
	
	
	
	return sb.toString();
}


//*********************************************************************************
String makeFormList(Connection conn, HttpSession session) {

	StringBuilder sb=new StringBuilder();
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();

	
	initModules();
	ArrayList<String[]> modules=new ArrayList<String[]>();
	for (int i=0;i<moduleArr.size();i++)
		modules.add(new String[]{moduleArr.get(i)[MODULE_FLD_NAME],moduleArr.get(i)[MODULE_FLD_MENU_TITLE]});

	
	sql="select id,domain_name from tdm_test_domain where is_active='YES' order by 2";
	ArrayList<String[]> domains=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	ArrayList<String[]> tree_types=new ArrayList<String[]>();
	//tree_types.add(new String[]{"container","Container (Folder) "});
	tree_types.add(new String[]{"element","Element"});
	tree_types.add(new String[]{"step","Step"});

	sql="select id,title from mad_flex_field order by 2";	
	ArrayList<String[]> fields=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	String form_module=nvl((String) session.getAttribute("form_module"),"");
	String form_domain=nvl((String) session.getAttribute("form_domain"),"");
	String form_tree_type=nvl((String) session.getAttribute("form_tree_type"),"");
	String form_field=nvl((String) session.getAttribute("form_field"),"");
	

	String comboForModules=makeComboArr(modules, "", "id=form_module onchange=setFormFieldsFilter()", form_module, 0);
	String comboForDomains=makeComboArr(domains, "", "id=form_domain onchange=setFormFieldsFilter()", form_domain, 0);
	String comboForTreeTypes=makeComboArr(tree_types, "", "id=form_tree_type onchange=setFormFieldsFilter()", form_tree_type, 0);
	String comboForFields=makeComboArr(fields, "", "id=form_field onchange=setFormFieldsFilter()", form_field, 0);
	
	
	
	sb.append("<div class=row>");
		sb.append("<div class=\"col-md-2\">");
			sb.append("<table class=\"table table-condensed table-striped\">");
			
			sb.append("<tr>");
			sb.append("<td><b>Module</b></td>");
			sb.append("</tr>");
			
			sb.append("<tr>");
			sb.append("<td>");
			sb.append(comboForModules);
			sb.append("</td>");
			sb.append("</tr>");
		
			sb.append("<tr>");
			sb.append("<td><b>Domain</b></td>");
			sb.append("</tr>");
			
			sb.append("<tr>");
			sb.append("<td>");
			sb.append(comboForDomains);
			sb.append("</td>");
			sb.append("</tr>");
			
			sb.append("<tr>");
			sb.append("<td><b>Level</b></td>");
			sb.append("</tr>");
			
			sb.append("<tr>");
			sb.append("<td>");
			sb.append(comboForTreeTypes);
			sb.append("</td>");
			sb.append("</tr>");
			
		
			sb.append("<tr>");
			sb.append("<td><b>Field</b></td>");
			sb.append("</tr>");
			
			sb.append("<tr>");
			sb.append("<td>");
			sb.append(comboForFields);
			sb.append("</td>");
			sb.append("</tr>");
			
			
			sb.append("</table>");
			
		sb.append("</div>");
		sb.append("<div class=\"col-md-10\" id=formFieldListDiv>");
		sb.append(makeListFormFields(conn,session));
		sb.append("</div>");
	sb.append("</div>");
	
	return sb.toString();
}


//*********************************************************************************
String makeListFormFields(Connection conn, HttpSession session) {

	StringBuilder sb=new StringBuilder();
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();

	String form_module=nvl((String) session.getAttribute("form_module"),"");
	String form_domain=nvl((String) session.getAttribute("form_domain"),"");
	String form_tree_type=nvl((String) session.getAttribute("form_tree_type"),"");
	String form_field=nvl((String) session.getAttribute("form_field"),"");
	
	sql="select ttf.id, module, domain_name domain, tree_type, ff.title flex_field "+
			" from tdm_test_tree_fields ttf, mad_flex_field ff, tdm_test_domain d "+
			" where ttf.flex_field_id=ff.id  "+
			" and ttf.domain_id=d.id ";
	
	if (form_module.length()>0) {
		sql=sql+" AND module=?";
		bindlist.add(new String[]{"STRING",form_module});
	}
	if (form_domain.length()>0) {
		sql=sql+" AND domain_id=?";
		bindlist.add(new String[]{"INTEGER",form_domain});
	}
	if (form_tree_type.length()>0) {
		sql=sql+" AND tree_type=?";
		bindlist.add(new String[]{"STRING",form_tree_type});
	}
	if (form_field.length()>0) {
		sql=sql+" AND flex_field_id=?";
		bindlist.add(new String[]{"INTEGER",form_field});
	}
	
	sql=sql+" order by order_by";
	
	ArrayList<String[]> fiedsArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	boolean show_set_order_button=false;
	if(form_module.length()>0 && form_domain.length()>0 && form_tree_type.length()>0) show_set_order_button=true;
	if (form_tree_type.length()==0) show_set_order_button=false;
	
	sb.append("<table class=\"table table-condensed table-striped\">");
	
	sb.append("<tr>");
	sb.append("<td colspan=6>");
	sb.append("<button type=button class=\"btn btn-sm btn-default\" onclick=addNewFormField()>");
	sb.append("<font color=green><span class=\"glyphicon glyphicon-plus\"></span></font> Add New Field");
	sb.append("</button>");
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("<tr class=info>");
	sb.append("<td><b>Module</b></td>");
	sb.append("<td><b>Domain</b></td>");
	sb.append("<td><b>Level</b></td>");
	sb.append("<td><b>Field</b></td>");
	sb.append("<td><b>Validation</b></td>");
	sb.append("<td><b></b></td>");
	sb.append("</tr>");
	
	
	for (int f=0;f<fiedsArr.size();f++) {
		
		String id=fiedsArr.get(f)[0];
		String module=fiedsArr.get(f)[1];
		String domain=fiedsArr.get(f)[2];
		String tree_type=fiedsArr.get(f)[3];
		String flex_field=fiedsArr.get(f)[4];
		String validation="No Validate";
		
		String module_name=getModuleName(conn, session, module);
		
		sb.append("<tr>");
		sb.append("<td>"+module+"</td>");
		sb.append("<td>"+domain+"</td>");
		sb.append("<td>"+tree_type+"</td>");
		sb.append("<td>"+flex_field+"</td>");
		sb.append("<td>"+validation+"</td>");
		
		

		sb.append("<td nowrap>");
		
		
		
		if (show_set_order_button) {
			
			String group_fields=form_module+"|::|"+form_domain+"|::|"+form_tree_type;
			String order_up_disabled="";
			String order_down_disabled="";
			
			
			if (f==0) order_up_disabled="disabled";
			if (f==(fiedsArr.size()-1)) order_down_disabled="disabled";
			
			sb.append("<button "+order_up_disabled+" type=button class=\"btn btn-sm btn-default\" onclick=\"setFormFieldOrder('"+id+"','"+group_fields+"','UP');\">");
			sb.append("<span class=\"glyphicon glyphicon-arrow-up\"></span>");
			sb.append("</button>");
			
			sb.append("<button "+order_down_disabled+" type=button class=\"btn btn-sm btn-default\" onclick=\"setFormFieldOrder('"+id+"','"+group_fields+"','DOWN');\">");
			sb.append("<span class=\"glyphicon glyphicon-arrow-down\"></span>");
			sb.append("</button>");
		}
		

		sb.append("<button type=button class=\"btn btn-sm btn-default\" onclick=removeFormField('"+id+"')>");
		sb.append("<font color=red><span class=\"glyphicon glyphicon-minus\"></span></font>");
		sb.append("</button>");
		sb.append("</td>");
		
		sb.append("</tr>");
		
	}
	
	sb.append("</table>");
	
	if(fiedsArr.size()==0) sb.append("No field defined for this level");
	
	return sb.toString();
}



//*********************************************************************************
String makeAddNewFormFieldForm(Connection conn, HttpSession session) {

	StringBuilder sb=new StringBuilder();
	
	String sql="";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();

	String form_module=nvl((String) session.getAttribute("form_module"),"");
	String form_domain=nvl((String) session.getAttribute("form_domain"),"");
	String form_tree_type=nvl((String) session.getAttribute("form_tree_type"),"");
	String form_field=nvl((String) session.getAttribute("form_field"),"");

	
	initModules();
	
	ArrayList<String[]> modules=new ArrayList<String[]>();
	for (int i=0;i<moduleArr.size();i++)
		modules.add(new String[]{moduleArr.get(i)[MODULE_FLD_NAME],moduleArr.get(i)[MODULE_FLD_MENU_TITLE]});

	
	sql="select id,domain_name from tdm_test_domain where is_active='YES' order by 2";
	ArrayList<String[]> domains=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	
	ArrayList<String[]> tree_types=new ArrayList<String[]>();
	//tree_types.add(new String[]{"container","Container (Folder) "});
	tree_types.add(new String[]{"element","Element"});
	tree_types.add(new String[]{"step","Step"});

	sql="select id,title from mad_flex_field order by 2";	
	ArrayList<String[]> fields=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);

	String comboForModules=makeComboArr(modules, "", "id=new_field_module", form_module, 0);
	String comboForDomains=makeComboArr(domains, "", "id=new_field_domain", form_domain, 0);
	String comboForTreeTypes=makeComboArr(tree_types, "", "id=new_field_tree_type", form_tree_type, 0);
	String comboForFields=makeComboArr(fields, "", "id=new_field_field", "", 0);
	
	sb.append("<table class=\"table table-condensed table-striped\">");
	
	sb.append("<tr>");
	sb.append("<td><b>Module</b></td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td>");
	sb.append(comboForModules);
	sb.append("</td>");
	sb.append("</tr>");

	sb.append("<tr>");
	sb.append("<td><b>Domain</b></td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td>");
	sb.append(comboForDomains);
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td><b>Level</b></td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td>");
	sb.append(comboForTreeTypes);
	sb.append("</td>");
	sb.append("</tr>");
	

	sb.append("<tr>");
	sb.append("<td><b>Field</b></td>");
	sb.append("</tr>");
	
	sb.append("<tr>");
	sb.append("<td>");
	sb.append(comboForFields);
	sb.append("</td>");
	sb.append("</tr>");
	
	
	sb.append("</table>");
	
	return sb.toString();
}

//*********************************************************************************
void addNewFormFieldDO(Connection conn, HttpSession 
		session, String module, 
		String domain, 
		String tree_type, 
		String flex_field_id, 
		StringBuilder err
		) {

	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	String sql="select 1 from tdm_test_tree_fields where module=? and domain_id=? and tree_type=? and flex_field_id=?";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",module});
	bindlist.add(new String[]{"INTEGER",domain});
	bindlist.add(new String[]{"STRING",tree_type});
	bindlist.add(new String[]{"INTEGER",flex_field_id});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) {
		err.append("This field already added");
		return;
	}
	
	
	
	sql="select ifnull(max(order_by)+1,1) from tdm_test_tree_fields where module=? and domain_id=? and tree_type=? ";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",module});
	bindlist.add(new String[]{"INTEGER",domain});
	bindlist.add(new String[]{"STRING",tree_type});
	
	String order_no="1";
	arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) try {order_no=arr.get(0)[0];} catch(Exception e) {};
	
	
	sql="insert into tdm_test_tree_fields (ID,module,domain_id,tree_type,flex_field_id,order_by) values (?,?,?,?,?,?)";
	
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",getTS()});
	bindlist.add(new String[]{"STRING",module});
	bindlist.add(new String[]{"INTEGER",domain});
	bindlist.add(new String[]{"STRING",tree_type});
	bindlist.add(new String[]{"INTEGER",flex_field_id});
	bindlist.add(new String[]{"INTEGER",order_no});
	
	boolean is_ok=execDBConf(conn, sql, bindlist);
	
	if (!is_ok) 
		err.append("Field not added due to technical issue.");


}


//*********************************************************************************
void removeFormField(Connection conn, HttpSession session, String form_field_id) {
	String sql="delete from tdm_test_tree_fields where id=?";
	
	ArrayList<String[]> bindlist=new 	ArrayList<String[]>();
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",form_field_id});
	
	execDBConf(conn, sql, bindlist);
			
}
//*********************************************************************************
void expandCurrentElementTree(Connection conn,HttpSession session,String module, String domain, String element_id, String node_id) {
		
	if (nvl(node_id,"0").equals("0")) return;
	
	String loop_tree_id=node_id;
	while(true) {
		String parent_id=getTreeAttributeValue(conn, session, loop_tree_id, "parent_tree_id");
		if (parent_id.equals("0")) break;
		session.setAttribute("is_node_expanded_"+module+"_"+domain+"_"+element_id, true);
		loop_tree_id=parent_id;
	}

}

//*********************************************************************************
String makeTreeNodePickerWindow(
		Connection conn, 
		HttpSession session, 
		String module,
		String domain,
		String element_id, 
		String curr_tree_id
		) {

	StringBuilder sb=new StringBuilder();
	
	expandCurrentElementTree(conn,session,module, domain, element_id, curr_tree_id);
	
	String module_name=getModuleName(conn, session, module);
	
	String clicked_container_id=getTreeAttributeValue(conn, session, curr_tree_id, "parent_tree_id");
	
	String include_sub_tree=nvl((String) session.getAttribute("include_sub_tree_"+module+"_"+domain+"_"+element_id),"YES");
	String text_to_search=nvl((String) session.getAttribute("text_to_search_"+module+"_"+domain+"_"+element_id),"");

	
	sb.append("<input type=hidden id=CLICKED_CONTAINER_OF_"+element_id+" value=\""+clicked_container_id+"\">");
	
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-5\">");
	
	
		sb.append("<table width=\"100%\" border=0 cellspacing=0 cellpadding=0>");
		
		
		String checked="";
		if (include_sub_tree.equals("YES")) checked="checked";
		
		sb.append("<tr>");
		sb.append("<td colspan=2 nowrap>");
		sb.append("<input type=checkbox "+checked+" id=include_sub_folders_for_"+element_id+" onclick=listPickerElements('"+element_id+"','')>");
		sb.append(" <b>Search including sub folders</b>");
		sb.append("</td>");
		sb.append("</tr>");
		
		sb.append("<tr>");
		sb.append("<td>");
		sb.append(makeText("text_to_search_picker_for_"+element_id, text_to_search, "placeholder=\"Search for ...\"  onchange=listPickerElements('"+element_id+"','') ", 0));
		sb.append("</td>");
		sb.append("<td>");
		sb.append("<span class=\"glyphicon glyphicon-filter\" onclick=listPickerElements('"+element_id+"','')></span>");
		sb.append("</td>");
		sb.append("</tr>");
		
		
		
		sb.append("<tr>");
		sb.append("<td colspan=2>");
		sb.append(getNodePickerList(conn,session,module,domain,element_id,curr_tree_id,"0"));
		sb.append("<td>");
		sb.append("</tr>");
		
	
		sb.append("</table>");
	
	sb.append("</div>");
	
	sb.append("<div class=\"col-md-7\" id=treeNodePickerElementListDiv>");
	String curr_container_id=getTreeAttributeValue(conn, session, curr_tree_id, "parent_tree_id");
	
	
	sb.append(listPickerElements(conn, session, module, domain, element_id, curr_container_id,text_to_search, include_sub_tree));
	sb.append("</div>");
	
	sb.append("</div>");


	
	return sb.toString();
}

//*********************************************************************************
int getTreeNodeLevel(Connection conn,HttpSession session,String node_id) {
		
	if (node_id.equals("0")) return 0;
	
	int ret1=0;
	String loop_tree_id=node_id;
	while(true) {
		String parent_id=getTreeAttributeValue(conn, session, loop_tree_id, "parent_tree_id");
		if (parent_id.equals("0")) return ret1;
		loop_tree_id=parent_id;
		ret1++;
	}

}
//*********************************************************************************
String getNodePickerList(
		Connection conn, 
		HttpSession session, 
		String module,
		String domain,
		String element_id, 
		String curr_tree_id,
		String parent_tree_id
		) {

	StringBuilder sb=new StringBuilder();
	
	ArrayList<String[]> roots=getTreeNodes(conn, session,  module, domain, parent_tree_id, "container", false);
		
	int level=getTreeNodeLevel(conn, session, parent_tree_id)+1;
	
	for (int i=0;i<roots.size();i++) {
		String[] node=roots.get(i);
		
		String tree_id=node[TREE_FIELD_id];
		String tree_type=node[TREE_FIELD_tree_type];
		String tree_title=node[TREE_FIELD_tree_title];


		sb.append("<table border=0 cellspacing=0 cellpadding=0>");
		sb.append("<tr>");
		
		for (int l=0;l<level;l++)   sb.append("<td><img src=\"img/icons/empty.png\" width=8 height=3></td>");

		if (tree_id.equals(curr_tree_id)) 
			sb.append("<td nowrap width=\"100%\" bgcolor=lightgreen>");
		else 
			sb.append("<td nowrap width=\"100%\">");
		
		sb.append("<a href=\"javascript:expandcollapsePickerTreeContainer('"+element_id+"','"+tree_id+"')\">");
		sb.append("<img src=\"img/icons/node_type_"+tree_type+".png\" width=16 height=16> ");
		sb.append("</a>");
		
		sb.append("<a href=\"javascript:listPickerElements('"+element_id+"','"+tree_id+"')\">");
		sb.append("<b>"+clearHtml(limitString(tree_title,120))+"</b>");
		sb.append("</a>");
		
		sb.append("<div id=child_of_node_"+tree_id+">");
		
		boolean is_expanded=false;
		if (session.getAttribute("is_node_expanded_"+module+"_"+domain+"_"+element_id+"_"+tree_id)!=null) is_expanded=true;
		
		if (is_expanded) { 
			sb.append(
					getNodePickerList(
							conn, 
							session, 
							module,
							domain,
							element_id, 
							curr_tree_id,
							tree_id
							)
				);
		} //if (is_expanded)
		
		sb.append("</div>");
		
		
		
		
		
		sb.append("</td>");
		

		
		
		sb.append("</tr>");
		sb.append("</table>");
		
		
		
		
	}
	
	
	return sb.toString();
}

//*********************************************************************************
String listPickerElements(
		Connection conn, 
		HttpSession session, 
		String module, 
		String domain, 
		String element_id,
		String starting_tree_id, 
		String text_to_search,
		String include_sub_tree
		) {
	
	StringBuilder sb=new StringBuilder();
	
	session.setAttribute("text_to_search_"+module+"_"+domain+"_"+element_id,text_to_search);
	session.setAttribute("include_sub_tree_"+module+"_"+domain+"_"+element_id,include_sub_tree);
	
	
	boolean is_recursive=false;
	if (include_sub_tree.equals("YES")) is_recursive=true;
	ArrayList<String[]> roots=getTreeNodes(conn, session,  module, domain, starting_tree_id, "element", is_recursive, text_to_search);
	
	String module_name=getModuleName(conn, session, module);
	
	sb.append("<big><big><big>"+ module_name+" list	</big></big></big><br>");
	
	if (roots.size()==0) {
		return "No "+module_name+" found!";
	}
	
	sb.append("<table class=\"table table-striped table-condensed table-bordered\">");
	
	sb.append("<tr class=info>");
	sb.append("<td><b></b></td>");
	sb.append("<td><b>#</b></td>");
	sb.append("<td><b>Path</b></td>");
	sb.append("<td><b>Title</b></td>");
	sb.append("<td><b>Ver.</b></td>");
	sb.append("</tr>");
	
	
	
	for (int i=0;i<roots.size();i++) {
		String[] node=roots.get(i);
		
		String tree_id=node[TREE_FIELD_id];
		String tree_title=node[TREE_FIELD_tree_title];
		String checked_out_by=node[TREE_FIELD_checked_out_by];
		String version=node[TREE_FIELD_version];
		


		
		sb.append("<tr>");
		
		sb.append("<td align=center>");
		if (!checked_out_by.equals("0")) 
			sb.append("<img src=\"img/icons/checked_out.png\" width=16 height=16>");
		else
			sb.append("<input type=radio  name=radio_group_for_node_select onclick=\"clickedPickerTreeElement('"+element_id+"','"+tree_id+"')\"> ");
		sb.append("</td>");
		

		sb.append("<td>");
		sb.append("<span>"+tree_id+"</span>");
		sb.append("</td>");
		
		sb.append("<td nowrap>");
		sb.append(getTreeElementPath(conn, session, tree_id));
		sb.append("</td>");
		
		sb.append("<td nowrap>");
		sb.append(clearHtml(limitString(tree_title,120)));
		sb.append("</td>");


		sb.append("<td>");
		sb.append("<a href=\"javascript:showTreeCheckHistory('"+tree_id+"')\"><span class=badge>"+version+"</span></a>");
		sb.append("</td>");
		
		sb.append("</tr>");
		
		
		
	}
	
	sb.append("</table>");
	
	
	
	return sb.toString();
}
//*********************************************************************************
String makeLinkTreeNodeBox(Connection conn, HttpSession session, String tree_id, String linked_module, String linked_node_id) {
	
	StringBuilder sb=new StringBuilder();

	String module_name=getModuleName(conn, session, linked_module);
		
	sb.append("<table class=table>");
	
	sb.append("<tr>");
	sb.append("<td nowrap align=right><b>Linked "+module_name+" : </b></td>");
	sb.append("<td width=\"100%\">");
	
	
	
	String id="linking_node_id";
	String sel_domain=getCurrentDomain(session);
	 
	
	
	sb.append(
				maketreeNodePicker(
					conn, 
					session, 
					id, 
					linked_module, 
					sel_domain, 
					linked_node_id
				)
			);
	
	sb.append("</td>");
	sb.append("</tr>");
	
	sb.append("</table>");

	
	return sb.toString();
}


//*********************************************************************************
boolean linkTreeNodes(Connection conn, HttpSession session, String tree_id, String module, String linked_tree_id, StringBuilder errmsg) {
	
	ArrayList<String[]> bindlist=new 	ArrayList<String[]>();
	
	String sql="select 1 from tdm_test_tree_link where tree_id=? and module=? and linked_tree_id=? ";
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",tree_id});
	bindlist.add(new String[]{"STRING",module});
	bindlist.add(new String[]{"LONG",linked_tree_id});
	
	System.out.println("tree_id="+tree_id);
	System.out.println("module="+module);
	System.out.println("linked_tree_id="+linked_tree_id);
	
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) {
		errmsg.append("Already linked. Can be linked only one time.");
		return false;
	}
	
	sql="insert into tdm_test_tree_link (id, tree_id,module,linked_tree_id) values (?,?,?,?)";
	
	
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",getTS()});
	bindlist.add(new String[]{"LONG",tree_id});
	bindlist.add(new String[]{"STRING",module});
	bindlist.add(new String[]{"LONG",linked_tree_id});
	
	execDBConf(conn, sql, bindlist);
	
	return true;
			
}

//*********************************************************************************
void unlinkTreeNodes(Connection conn, HttpSession session, String tree_id, String linked_tree_id) {
	
	ArrayList<String[]> bindlist=new 	ArrayList<String[]>();
	
	String sql="delete from tdm_test_tree_link where tree_id=? and linked_tree_id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",tree_id});
	bindlist.add(new String[]{"LONG",linked_tree_id});


	execDBConf(conn, sql, bindlist);
	
			
}

//*********************************************************************************
void addNewOrganizationGroupDO(Connection conn, HttpSession session, String tree_id, String group_id) {
	
	ArrayList<String[]> bindlist=new 	ArrayList<String[]>();
	
	String sql="select 1 from tdm_test_tree_group where tree_id=? and group_id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",tree_id});
	bindlist.add(new String[]{"INTEGER",group_id});

	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	if (arr.size()==1) return;
	
	sql="insert into tdm_test_tree_group (id,tree_id, group_id) values (?,?,?)";
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",getTS()});
	bindlist.add(new String[]{"LONG",tree_id});
	bindlist.add(new String[]{"INTEGER",group_id});
	
	execDBConf(conn, sql, bindlist);


	
			
}
//*********************************************************************************
void removeOrganizationGrou(Connection conn, HttpSession session, String tree_id, String group_id) {
	
	ArrayList<String[]> bindlist=new 	ArrayList<String[]>();
	
	String sql="delete from tdm_test_tree_group where tree_id=? and group_id=?";
	
	bindlist.clear();
	bindlist.add(new String[]{"LONG",tree_id});
	bindlist.add(new String[]{"INTEGER",group_id});

	execDBConf(conn, sql, bindlist);


	
			
}



//********************************************************************************
String makeDomainList(
		Connection conn,
		HttpSession session) {
	String sql="";
	StringBuilder sb=new StringBuilder();
	
	
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	sql="select id, domain_name from tdm_test_domain order by 2 ";
	bindlist.clear();
	
	ArrayList<String[]> domainList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
	
	
	StringBuilder sbContent=new StringBuilder();
	ArrayList<String[]> collapseItems=new ArrayList<String[]>();

	
	for (int i=0;i<domainList.size();i++) {
		
		String domain_id=domainList.get(i)[0];
		String domain_name=domainList.get(i)[1];
		
		
		
		sbContent.setLength(0);
		sbContent.append(makeDomainEditor(conn, session, domain_id));
		
		collapseItems.add(new String[]{"colDomainContent_"+domain_id,domain_name,sbContent.toString(),"domain.png"});

		
		
		
	}

	
	sb.append(makeDomainHeader());
	sb.append(addCollapse("listDomain",collapseItems));

	return sb.toString();
}


//********************************************************************************
String makeDomainHeader() {
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\">");
	sb.append("<button type=button class=\"btn btn-sm btn-success\" onclick=\"javascript:addNewDomain();\">");
	sb.append("<span class=\"glyphicon glyphicon-plus\">");
	sb.append(" Add New Domain");
	sb.append("</span>");
	sb.append("</button>");
	sb.append("</div>");
	sb.append("</div>");
	
	return sb.toString();
}
//********************************************************************************
String makeDomainEditor(
		Connection conn,
		HttpSession session,
		String domain_id
		) {
	
	
	String sql="";


	sql="select domain_name, is_active from tdm_test_domain where id=?";
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",domain_id});
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	
	String domain_name=arr.get(0)[0];
	String is_active=arr.get(0)[1];
	
	StringBuilder sb=new StringBuilder();
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-12\" id=lang_editor_"+domain_id+">");


	

	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Language Code : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeText("domain_name", domain_name, " onchange=\"saveDomainField(this, '"+domain_id+"');\"", 0));
	sb.append("</div>");
	sb.append("</div>");
	
	ArrayList<String[]> yesNoArr=new ArrayList<String[]>();
	yesNoArr.add(new String[]{"YES"});
	yesNoArr.add(new String[]{"NO"});
	
	sb.append("<div class=row>");
	sb.append("<div class=\"col-md-3\" align=right>");
	sb.append("<label class=\"label label-info\">Active : </label>");
	sb.append("</div>");
	sb.append("<div class=\"col-md-9\">");
	sb.append(makeComboArr(yesNoArr, "", "id=is_active size=1 onchange=\"saveDomainField(this, '"+domain_id+"');\"", is_active, 0));
	sb.append("</div>");
	sb.append("</div>");

	sb.append("</div>");
	sb.append("</div>");
	
	
	return sb.toString();
}


//********************************************************************************
int addNewDomain(
		Connection conn,
		HttpSession session,
		String domain_name
		) {
	String sql="";
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	
	
	sql="select 1 from tdm_test_domain where domain_name=? ";
	bindlist.add(new String[]{"STRING",domain_name});
	
	ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
	if (arr.size()==1) return -1;
	
	sql="insert into  tdm_test_domain (domain_name) values(?) ";
	bindlist.clear();
	bindlist.add(new String[]{"STRING",domain_name});

	boolean is_success=execDBConf(conn, sql, bindlist);
	if (!is_success) return -2;
	
	
	return 0;
}


%>



