<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">


<%@include file="header2.jsp"  %>  

<%

roleRestrict(session,response,"ADMIN,MADDES,MADRM,MADUSR,MADDES,MADPLN");

request.setCharacterEncoding("utf-8");

%>

<html>

  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>MAD Deployments</title>

    <script src="style/bootstrap/js/jquery-1.11.1.js"></script>
    <script src="style/bootstrap/js/joint.js"></script>
    <script src="style/bootstrap/js/bootstrap.js"></script>
    <script src="style/bootstrap/js/bootbox.js"></script>
    <script src="style/bootstrap/js/fileinput.js"></script>
    
    
    <link href="style/bootstrap/css/joint.css" rel="stylesheet">
    <link href="style/bootstrap/css/bootstrap.css" rel="stylesheet">
    <link href="style/bootstrap/css/fileinput.css" rel="stylesheet" type="text/css" media="all">
    
    <script src="jslib/tdmapp.js?update_date=2015_01_10"></script>
    
  </head>
  
  
<body onload=onLoadDeploymentList() style="background: url(img/bodyback.jpg); background-size:cover; ">

<%=printHeader(request,session)%>

		
		
		
		 
		

		
		
<div class="container-fluid" style="background-color:#dadada;">

			<div class=row>
			<div class="col-md-12" id="headerofDeploymentsDiv">
				
			</div>	  
			</div>
			
			<div class=row>
			
			
			
			
			<div class="col-md-2" style="min-height: 500px; max-height: 1200px; overflow-y: scroll; ">
				
			<div class=row>
			<div class="col-md-12" align=center>
			<div id=NOFADE_queryListDiv ></div>
			</div>
			</div>
				
				 
			</div>	
			
			<div class="col-md-10" id="listofRequestsDiv" style="min-height: 500px; max-height: 1200px; overflow-x: scroll; overflow-y: scroll; ">
				
			</div>	 
			
			
			 	  
			</div>


</div>


</body>

</html>