<%@include file="header2.jsp" %> 
<%@ page trimDirectiveWhitespaces="true" %>
<%


roleRestrict(session,response,"DESIGN,ADMIN,MADDES,MADRM,MADUSR,MADPLN");

String attachment_id="";

try {
	attachment_id=decode(request.getParameter("id"));
} catch(Exception e) {
	attachment_id="";
}


if (attachment_id.length()>0) {
	Connection conn=null;
	try {
		conn=getconn();
		String sql="select file_name from mad_request_attachment where id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",attachment_id});
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
		String filename=arr.get(0)[0];
		System.out.println("Filename to download  : " +filename);
		
		
		byte[] filecontent=getInfoBin(conn, "mad_request_attachment", Integer.parseInt(attachment_id), "file_blob");
		System.out.println("Get compressed file size : " +filecontent.length);
		
		filecontent=uncompresstobyte(filecontent);
		System.out.println("Get UNcompressed file size : " +filecontent.length);
		
		
		
		
		
		
		response.setContentType("APPLICATION/OCTET-STREAM");   
		response.setHeader("Content-Disposition","attachment; filename=\"" + filename + "\"");
		
		//out.print(filecontent);

		ServletOutputStream o = response.getOutputStream();
		o.write(filecontent);
		try {o.flush();} catch(Exception e) {}
		try {o.close();} catch(Exception e) {}

		
		
		
	} catch(Exception e) {
		e.printStackTrace();
	}
	finally {
		closeconn(conn);
	}
	
}

%>



