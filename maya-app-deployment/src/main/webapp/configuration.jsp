<%@ page language="java" contentType="text/html; charset=UTF-8"   pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">


<%@include file="header2.jsp" %>  

<%

roleRestrict(session,response,"ADMIN,MADRM,MADPLN");

request.setCharacterEncoding("utf-8");

%>

<html>

  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Configuration</title>

    <script src="style/bootstrap/js/joint.js"></script>

    <script src="style/bootstrap/js/jquery-1.11.1.js"></script>
    <script src="style/bootstrap/js/bootstrap.js"></script>
    <script src="style/bootstrap/js/bootbox.js"></script>
     
     <link href="style/bootstrap/css/joint.css" rel="stylesheet">
     <link href="style/bootstrap/css/bootstrap.css" rel="stylesheet">
     
    
    <script src="jslib/tdmapp.js?update_date=2015_01_10"></script>
    
  </head>
  
  
<body onload=onLoadConfiguration() style="background: url(img/bodyback.jpg); background-size:cover; ">

<%=printHeader(request,session)%>

		<div class="modal fade bs-example-modal-md" id="lovDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="lovBody"  style="min-height: 0px; max-height: 450px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			        	<button type="button" class="btn btn-success" id=btSelectLOV onclick="selectLOV();">Select</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<div class="modal fade bs-example-modal-sm" id="testConnectionDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-sm">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="testConnectionBody"">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		<div class="modal fade bs-example-modal-md" id="flexFieldEditorDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="flexFieldEditorBody"  style="min-height: 0px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<div class="modal fade bs-example-modal-md" id="setPasswordDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="setPasswordBody"  style="min-height: 0px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			        	<button type="button" class="btn btn-success" id=btSetPwd onclick="setPassword();">Set Password</button>
			        	
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->		
		
		
		
		<div class="modal fade bs-example-modal-lg" id="fieldSettingsDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		<div class="modal-header" id=taskHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
			 		</div> <!--  modal header -->
				 	 <div class="modal-body" id="fieldSettingsBody"  style="min-height: 0px; max-height: 400px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->	
		
		
		
		<div class="modal fade bs-example-modal-md" id="notificationParamsDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="notificationParamsBody"  style="min-height: 0px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			        	
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->		
		
		
		
		<div class="modal fade bs-example-modal-lg" id="appRepoScriptTestDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="appRepoScriptTestBody"  style="min-height: 0px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
				
<div class="container">

	<div class=row>
		<div class="col-md-12" id=configLeftDiv>
		</div>

	</div>		

</div>	

</body>

</html>

