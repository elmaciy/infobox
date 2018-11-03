<%@ page language="java" contentType="image/png; charset=UTF-8"   pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>

<%@page import="java.io.OutputStream"%>


<%
     
   String step_id=(String) request.getParameter("step_id");
   if (step_id==null || step_id.length()==0) step_id="0";
   //response.setContentType("image/png");
   
   byte[] imageData = (byte[])pageContext.getSession().getAttribute("image_"+step_id);
   
   
   if (imageData!=null) {
	   try{
		   
	      OutputStream outStream = response.getOutputStream();
	      outStream.write(imageData);
	      outStream.flush(); 
	      outStream.close(); 
	      return;
		
		   }catch(Exception ioe){
		      ioe.printStackTrace();
		   }  
   } else System.out.println("image is null");
   
   
    
    
%>