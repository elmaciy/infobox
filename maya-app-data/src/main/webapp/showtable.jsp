<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@include file="header.jsp" %> 


<%

roleRestrict(session,response,"RUN,DESIGN,ADMIN");

String envid="";
String divid="";
String tabid="";
String reccnt="";
String filter="";

try {
	envid=request.getParameter("envid");
	divid=request.getParameter("divid");
	tabid=request.getParameter("tabid");
	reccnt=request.getParameter("reccnt");
	filter=request.getParameter("filter");
} catch(Exception e) {
	tabid="";
}

if (tabid.length()>0) {
	Connection conn=getconn();
	//printTable(conn, out,envid,divid,tabid,reccnt,filter);
	//printTableforDiscovery(conn, out,envid,divid,tabid,reccnt,filter);
	try {
		conn.close();
		conn=null;
		} catch(Exception e) {e.printStackTrace();}
}

%>