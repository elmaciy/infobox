<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@include file="header2.jsp" %>

<%
roleRestrict(session,response,"DESIGN,ADMIN,RUN");
request.setCharacterEncoding("utf-8");
%>

<html>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>TDM</title>

    <link href="style/bootstrap/css/bootstrap.css" rel="stylesheet">
     
    <script src="style/bootstrap/js/jquery-1.11.1.js"></script>
    <script src="style/bootstrap/js/bootstrap.js"></script>
    <script src="jslib/sorubox.js"></script>
  </head>
  
  
<body onload=printabout() style="background: url(img/bodyback.jpg); background-size:cover; ">
<%=printHeader(request, session)%>
<div class="container">
<div class="row">


		
<div class="panel panel-primary">

    <div class="panel-body">
        <div class="jumbotron" id=aboutDiv style="width=100%; ">
            
        </div>
    </div>
</div> <!--  panel primary -->

</div> <!--  row -->

</div> <!--  container -->



</body>
</html>