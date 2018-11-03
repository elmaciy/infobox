<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>


<%@include file="header.jsp"%>

<%


String app_id="";
String script_type="";
String script="";





try {
	app_id=nvl(request.getParameter("app_id"),"-");
	script=request.getParameter("script");
	script_type=request.getParameter("script_type");
	


} catch(Exception e) {
	app_id="-";
}


if (!app_id.equals("-")) {
	
	String update_sql="update tdm_apps set XXXX=? where id=?";
	
	String script_field="";
	
	if (script_type.equals("PREP_TASKS")) script_field="prep_script";

	if (script_type.equals("POST_TASKS")) script_field="post_script";
	
	update_sql=update_sql.replaceAll("XXXX", script_field);
	
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.add(new String[]{"STRING",script});
	bindlist.add(new String[]{"INTEGER",app_id});
	
	
	System.out.println(update_sql);
	if (!update_sql.isEmpty()) {
		boolean db_update=false;
		Connection conn=null;
		try {
			conn=getconn();

			db_update=execDBConf(conn, update_sql,bindlist);
			
			conn.close();
			conn=null;
			
		} 
		catch(Exception e) {e.printStackTrace();}
		finally {try {conn.close();conn=null;} catch(Exception e) {}} 
	}

		
}







JSONObject obj=new JSONObject();
obj.put("msg", "zzz");

try{ out.print(obj);    out.flush();} catch(IOException e) {	e.printStackTrace();  } 

%>

