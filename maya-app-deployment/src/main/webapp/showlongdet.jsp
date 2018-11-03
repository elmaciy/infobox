<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@include file="header.jsp"%> 

<html>

<head>
<title>MAYA Test Data Management Suite</title>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8" />
<meta http-equiv="content-language" content="TR" />
<script src="jslib.js" type="text/javascript"></script>
<link rel="stylesheet" href="common.css" type="text/css">
</head>

<body>

<%

roleRestrict(session,response,"RUN,DESIGN,ADMIN");


String id="";
String fld="";
String tab="";
String env_id="";
try {
	id=request.getParameter("id");
	fld=request.getParameter("fld");
	tab=request.getParameter("tab").toLowerCase();
	env_id=request.getParameter("env_id");
} catch(Exception e) {
	id="";
}

String html="";

if (id.length()>0) {
	Connection conn=getconn();

		html=printLongDet2(conn,env_id,id,tab,fld);
	try {
		conn.close();
		conn=null;
		} catch(Exception e) {e.printStackTrace();}
}

out.println(html);
%>


</body>
</html>
