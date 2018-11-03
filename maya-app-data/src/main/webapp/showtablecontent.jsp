<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@include file="header.jsp" %> 

<html>

<head>
<title>MAYA Test Data Management Suite</title>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8" />
<meta http-equiv="content-language" content="TR" />
<script src="jslib.js" type="text/javascript"></script>
<link rel="stylesheet" href="common.css" type="text/css">
</head>


<%

roleRestrict(session,response,"RUN,DESIGN,ADMIN");


String envid="";
String tabname="";
String tabid="";
String reccnt="";
String filter="";
String edsql="";

try {
	envid=request.getParameter("envid");
	tabid=request.getParameter("tabid");
	tabname=request.getParameter("tabname");
	reccnt=request.getParameter("reccnt");
	filter=request.getParameter("filter");
	edsql=nvl(request.getParameter("query"),"");
} catch(Exception e) {
	tabid="";
}

String html="";

if (tabname.length()>0 || tabid.length()>0) {
	
	
	Connection conn=getconn();

	if (tabname.length()==0) {
		String sql="select concat(schema_name,'.',tab_name) tn from tdm_tabs where id="+tabid;
		tabname=getDBSingleVal(conn, sql);	
	}

	//html_table=printTableinNewWindow(conn, envid,tabname,reccnt,filter);
	
		String app_sql = "select * from " + tabname;
		
		if (edsql.length()>0) app_sql=edsql;
		
		StringBuilder tabstr=new StringBuilder();
		
		tabstr.append("<form>");
		tabstr.append("<textarea name=query cols=100 rows=10>"+ app_sql +"</textarea>");
		tabstr.append("<br>");
		tabstr.append("<font color=white><b>Environment : </b></font>");
    	String sql = " select id, name from tdm_envs order by name ";
        tabstr.append(makeCombo(conn, sql, "envid", "id=envid  style=\"width:200px;\"", envid, 200));

        
		tabstr.append("<input type=submit name=btquery value=Query>");
		tabstr.append("<input type=hidden name=tabid value=\""+tabid+"\">");
		tabstr.append("<input type=hidden name=tabname value=\""+tabname+"\">");
		tabstr.append("<input type=hidden name=reccnt value=\""+reccnt+"\">");
		tabstr.append("<input type=hidden name=filter value=\""+filter+"\">");
		tabstr.append("<hr>");
		tabstr.append("</form>");

		
		Connection connApp=getconn(conn,envid);
		
		if (connApp!=null) {
			PreparedStatement pstmt = null;
			ResultSet rset = null;
			ResultSetMetaData rsmd = null;
			
			try {
				pstmt = connApp.prepareStatement(app_sql);
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

				int recno=0;
				int maxrec=0;
				try {maxrec=Integer.parseInt(reccnt);} catch(Exception e) {maxrec=100;}
				
				//max 1000 recs can be selected
				if (maxrec>1000) maxrec=1000;
				
				String bgcolor="";
				while (rset.next() && maxrec>recno) {
					recno++;
					bgcolor="#FAFAFA";
					if (recno % 2 ==0) bgcolor="#DCDCDC";
					tabstr.append("<tr bgcolor=" + bgcolor + ">");
					tabstr.append("<td>"+recno+"</td>");
					for (int i=1;i<=colcount;i++) {
						String aval="";
						try{aval= rset.getString(i);} catch(Exception e) {aval=e.getMessage();}
						tabstr.append("<td>" + aval + "</td>");
					}
					tabstr.append("</tr>");
				}
				tabstr.append("</table>");

				
			} catch(Exception e) {
				e.printStackTrace();
				tabstr.append("<table border=1>");
				tabstr.append("<tr bgcolor=#FADABC><td>");
				tabstr.append("SQL Exception@printTableinNewWindow : "+e.getMessage());
				tabstr.append("<hr>while execution SQL : "+app_sql);
				tabstr.append("</td></tr>");
				tabstr.append("</table>");
			}

			closeconn(connApp);
		} // if connApp!=null
	
	
	try {
		conn.close();
		conn=null;
		} catch(Exception e) {e.printStackTrace();}

	html="<center><b><font color=yellow><h4>"  + tabid + "</h4></font></b><hr>";

	html=html+tabstr.toString();

	html=html+"</center>"; 


}




out.println(html);


%>


</body>
</html>

