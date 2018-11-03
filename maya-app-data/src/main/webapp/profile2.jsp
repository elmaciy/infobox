<%@ page language="java" contentType="text/html; charset=UTF-8"   pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">


<%@include file="header2.jsp" %> 

<%
roleRestrict(session,response,"DESIGN,ADMIN");

request.setCharacterEncoding("utf-8");
%>

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
    <link href="style/bootstrap/css/fileinput.css" rel="stylesheet">
     
    <script src="style/bootstrap/js/jquery-1.11.1.js"></script>
    <script src="style/bootstrap/js/bootstrap.js"></script>
    <script src="style/bootstrap/js/bootbox.js"></script>
    <script src="style/bootstrap/js/fileinput.js"></script>
    <script src="jslib/tdmapp.js"></script>

    
  </head>
  
  


<body onload=loadListofProfile() style="background: url(img/bodyback.jpg); background-size:cover; ">

<%=printHeader(request,session)%>

<div class="container-fluid">

		<div class="row">
      
      <div class="col-md-4">
      	<div class="panel panel-primary">  	
	      	<div class="panel-heading">
				    <h3 class="panel-title">Masking Profiles </h3>
			</div>
			<div class="panel-body" id="listofProfileDiv"  style="min-height: 440px; max-height: 440px;  ">
			</div>	  
			<div class="panel-footer  clearfix">
			<div class="pull-right">
				<a class="navbar-brand" href="#" onclick=addNewProfile()>
	              <span class="glyphicon glyphicon-plus-sign"></span>
				  <span class="glyphicon-class">Add</span>
			  	</a>
	
				<a class="navbar-brand" href="#" onclick=renameProfile()>
	              <span class="glyphicon glyphicon-edit"></span>
				  <span class="glyphicon-class">Rename</span>
			  	</a>
			  	
			  	<a class="navbar-brand" href="#" onclick=deleteProfile()>
	              <span class="glyphicon glyphicon-minus-sign"></span>
				  <span class="glyphicon-class">Delete</span>
			  	</a>
				</div>	<!--  pull right -->  					
			</div> <!--  panel footer -->
		</div> <!--  div class=panel-primary -->
      
      </div> <!--  div class=col-md3 -->
      
      <div class="col-md-8">
     	<div class="panel panel-primary">  	
     	
			
			<div class="panel-body" id="profileDetailsDiv" style="min-height: 500px; max-height: 500px; overflow-x: scroll; overflow-y: scroll; ">
			
			</div>	  
			

			
		</div> <!--  div class=panel-primary -->
      </div> <!--  div class=col-md9 -->
      
      </div> <!--  div class=row -->
</div>


</body>

</html>