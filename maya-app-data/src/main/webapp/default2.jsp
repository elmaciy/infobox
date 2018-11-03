

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@include file="header2.jsp" %> 

<html>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="favicon.ico">

    <title>Infobox TDM</title>

    <link href="style/bootstrap/css/bootstrap.css" rel="stylesheet">
     
    <script src="style/bootstrap/js/jquery-1.11.1.js"></script>
    <script src="style/bootstrap/js/bootstrap.js"></script>
    <script src="style/bootstrap/js/bootbox.js"></script>
    <script src="jslib/tdmapp.js"></script>
    
    <script>
    function getstarted() {
    	var el=document.getElementById("txtUsername");
    	if (!el) window.location.href="designer2.jsp";
    	el.focus();
    }
    </script>
  </head>
  
  
<body style="background: url(img/bodyback.jpg); background-size:cover; ">
<%=printHeader(request, session)%>
<div class="container-fluid">
<div class="row">
		
<div class="panel panel-primary">

    <div class="panel-body">
        <div class="jumbotron" style="width=100%; background-image: url(img/background_tdm.jpg); background-size: cover;">
        
        	<table class="table table-condensed " >
        	
        	
        	<tr><td valign=top align=center></td></tr>
 			
        	<tr>
            <td valign=top align=center>
            
            	<table border=0 cellspacing=0 cellpadding=0>
            	<tr>
	            	<td>
	            		<img src="img/info_kare_small_black.PNG" height="80%" weight="80%"> 
	            	</td>
            	</tr>
            	</table>
            	
            </td>
            </tr>
            
        	
			<tr><td valign=top align=center></td></tr>
			
            
            </table>
        </div>
    </div>
</div> <!--  panel primary -->

</div> <!--  row -->

</div> <!--  container -->



</body>
</html>