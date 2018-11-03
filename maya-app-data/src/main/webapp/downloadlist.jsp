<%@include file="header2.jsp" %> 

<%


roleRestrict(session,response,"DESIGN,ADMIN");

String listid="";

try {
	listid=request.getParameter("listid");
} catch(Exception e) {
	listid="";
}


if (listid.length()>0) {

	Connection conn=getconn();
	String sql="select list_val from tdm_list_items where list_id="+listid;
	boolean is_list_taken=true;
	ArrayList<String> list_vals=new ArrayList<String>();
	try {
		PreparedStatement stmt=conn.prepareStatement(sql);
		ResultSet rs=stmt.executeQuery();
		while(rs.next()) {
			list_vals.add(rs.getString(1));
		}
	} catch(Exception e) {
		is_list_taken=false;
	}

	if (is_list_taken) {
		response.setCharacterEncoding("UTF-8");
	    request.setCharacterEncoding("UTF-8");
		
	    String filename="listContent_"+listid+".txt";
		response.setContentType("APPLICATION/OCTET-STREAM");   
		response.setHeader("Content-Disposition","attachment; filename=\"" + filename + "\"");
		for (int i=0;i<list_vals.size();i++)
		{
			if (list_vals.get(i).trim().length()>0)
				out.println(list_vals.get(i));
		}
			
		
		out.flush();
		out.close();
	}
	
}

%>



