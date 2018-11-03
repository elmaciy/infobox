<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@include file="header.jsp"%>


<%


String work_plan_id="";
String script_type="";
String script_log="";






try {
	work_plan_id=nvl(request.getParameter("work_plan_id"),"-");
	script_type=request.getParameter("script_type");
} catch(Exception e) {
	work_plan_id="-";
}


if (!work_plan_id.equals("-")) {
	
	String sql="select XXXX from tdm_work_plan where id="+work_plan_id;
	
	String script_field="";
	
	if (script_type.equals("PREP_TASKS")) script_field="prep_script_log";

	if (script_type.equals("POST_TASKS")) script_field="post_script_log";
	
	sql=sql.replaceAll("XXXX", script_field);
	
	System.out.println(sql);
	
	boolean db_update=false;
	Connection conn=null;
	try {
		conn=getconn();

		script_log=getDBSingleVal(conn, sql);
		
		
		conn.close();
		conn=null;
		
	} 
	catch(Exception e) {e.printStackTrace();}
	finally {try {conn.close();conn=null;} catch(Exception e) {}} 
	

		
}




String html="<center><hr>";

try {
	html=html+"<textarea cols=80 rows=25>"+script_log+"</textarea>";
} catch(Exception e) {
	html="not found";
}

html=html+"<br>"+
	"<input type=button name=btdetclose value=Close onclick=\"document.getElementById('longTextDiv').style.display='none';\">";
html=html+"</center>";




JSONObject obj=new JSONObject();
obj.put("html", html);

try{ out.print(obj);    out.flush();} catch(IOException e) {	e.printStackTrace();  } 

%>

