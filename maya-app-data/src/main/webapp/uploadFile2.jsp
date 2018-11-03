<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">


<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>


<%@include file="header.jsp" %> 

<%

roleRestrict(session,response,"DESIGN,ADMIN");


final String UPLOAD_DIRECTORY = "upload";
final int THRESHOLD_SIZE     = 1024 * 1024 * 3;  // 3MB
final int MAX_FILE_SIZE      = 1024 * 1024 * 40; // 40MB
final int MAX_REQUEST_SIZE   = 1024 * 1024 * 50; // 50MB

String list_id=(String) session.getAttribute("currlistid");


//checks if the request actually contains upload file
if (!ServletFileUpload.isMultipartContent(request)) {
 PrintWriter writer = response.getWriter();
 writer.println("Request does not contain upload data");
 writer.flush();
 return;
}

//configures upload settings
DiskFileItemFactory factory = new DiskFileItemFactory();
factory.setSizeThreshold(THRESHOLD_SIZE);
factory.setRepository(new File(System.getProperty("java.io.tmpdir")));

ServletFileUpload upload = new ServletFileUpload(factory);
upload.setFileSizeMax(MAX_FILE_SIZE);
upload.setSizeMax(MAX_REQUEST_SIZE);

//constructs the directory path to store upload file
String uploadPath = getServletContext().getRealPath("")
 + File.separator + UPLOAD_DIRECTORY;
//creates the directory if it does not exist
File uploadDir = new File(uploadPath);
if (!uploadDir.exists()) {
 uploadDir.mkdir();
}





List<FileItem> formItems = upload.parseRequest(request);
Iterator<?> iter = formItems.iterator();



 
// iterates over form's fields
while (iter.hasNext()) {
	
	
    FileItem item = (FileItem) iter.next();
    // processes only fields that are not form fields
    if (!item.isFormField()) {
        String fileName = new File(item.getName()).getName();
        if (fileName.length()>0) {
			
        	
			 
	        String filePath = uploadPath + File.separator + fileName;
	        File storeFile = new File(filePath);
	        // saves the file on disk
	        item.write(storeFile);

	        Connection conn=getconn();
	        String sql="insert into tdm_list_items (list_id, list_val) values (?,?)";
	        BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(storeFile), "UTF8"));
	        ArrayList<String[]> bindlist=new ArrayList<String[]>();
	        execDBConf(conn,"delete from tdm_list_items where list_id="+list_id, bindlist);
	        
	        int recno=0;
	        String         line = null;
	        String         ls = System.getProperty("line.separator");
	        String delimiter=nvl((String) session.getAttribute("column_delimiter"),";");

	        while( ( line = reader.readLine() ) != null ) {
				if (line.trim().length()>0) {
					recno++;
					
					bindlist=new ArrayList<String[]>();
					
					if (recno==1) {
						int colcount=line.split(delimiter).length;
						String title="";
						if (colcount>1) {
							for (int i=1;i<=colcount;i++) {
								title=title+"f"+i;
								if (i<colcount) title=title+"|::|";
							}
							String tsql="update tdm_list set title_list=? where id=?";
		
							bindlist.add(new String[]{"STRING", ""+title});
							bindlist.add(new String[]{"INTEGER", ""+list_id});
							execDBConf(conn, tsql, bindlist);
						}
						
						bindlist=new ArrayList<String[]>();
					}
					
					bindlist.add(new String[]{"INTEGER", ""+list_id});
					bindlist.add(new String[]{"STRING", ""+line.replaceAll(delimiter,"|::|")});
					
					execDBConf(conn, sql, bindlist);
				}
	        }
	        
	        reader.close();
	        conn.close();
	
	        storeFile.delete();
	        
        } //if (fileName.length()>0)
    }
}

response.sendRedirect("list2.jsp?listList="+list_id);


%>