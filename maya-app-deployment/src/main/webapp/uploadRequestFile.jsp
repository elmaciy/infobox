<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">


<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>


<%@include file="header2.jsp" %> 

<%

//roleRestrict(session,response,"DESIGN,ADMIN");


final String UPLOAD_DIRECTORY = "upload";
final int THRESHOLD_SIZE     = 1024 * 1024 * 3;  // 3MB
final int MAX_FILE_SIZE      = 1024 * 1024 * 40; // 40MB
final int MAX_REQUEST_SIZE   = 1024 * 1024 * 50; // 50MB



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
String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIRECTORY;
//creates the directory if it does not exist
File uploadDir = new File(uploadPath);
if (!uploadDir.exists()) 
 uploadDir.mkdir();

session.setAttribute("last_attachment_error", "");

try {

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
		        
		         System.out.println("File is being stored : " + filePath);
		        
		       
		        item.write(storeFile);
		        
		       
		        System.out.println("File is stored : " + filePath);
		        
				 
				
	       		String attachment_attachment_id=(String) session.getAttribute("attachment_attachment_id");
	       		
	       		
		        
		        ArrayList<String[]> bindlist=new ArrayList<String[]>();
		        String sql="";
		        
	        	Connection conn=null;
	        	try {
	        		conn=getconn();
	        		setMadRequestAttachment(conn, session, Integer.parseInt(attachment_attachment_id), filePath, fileName);  
	        	} catch(Exception e) {
	        		e.printStackTrace();
	        	} finally {
	        		closeconn(conn);
	        	}
		        
		        
				
		
		        storeFile.delete();
		        
		       
		        
	        } //if (fileName.length()>0)
	    } // if (!item.isFormField())
	} //while

} catch(Exception e) {
	e.printStackTrace();
	session.setAttribute("last_attachment_error", e.getMessage());
	
}

%>