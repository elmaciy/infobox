<%@include file="header2.jsp" %> 

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
	<link rel="shortcut icon" href="favicon.ico">
	
    <title>Infobox TDM</title>

   
    
   
  	
    <script src="style/bootstrap/js/jquery-1.11.1.js"></script>
    <script src="style/bootstrap/js/bootstrap.js"></script>
    <script src="style/bootstrap/js/bootbox.js"></script>
    <script src="jslib/tdmapp.js"></script>
    
  
   	<script src="style/bootstrap/js/highcharts.js"></script>
   	<script src="style/bootstrap/js/highcharts-more.js"></script>
  	<script src="style/bootstrap/js/exporting.js"></script>
    
     <link href="style/bootstrap/css/bootstrap.css" rel="stylesheet">
     
    
  </head>




<%
roleRestrict(session,response,"DESIGN,ADMIN");

%> 



<body onload=ondiscoveryload() style="background: url(img/bodyback.jpg); background-size:cover; ">

 
	
	
<%=printHeader(request,session)%>


		<div class="modal fade bs-example-modal-md" id="lovDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="lovBody"  style="min-height: 0px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			        	<button type="button" class="btn btn-success" id=btSelectLOV onclick="selectLOV();">Select</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		<div class="modal fade bs-example-modal-lg" id="discoveryListDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="discoveryListBody"  style="min-height: 0px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		
		<div class="modal fade bs-example-modal-lg" id="startDiscoveryDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="startDiscoveryBody"  style="min-height: 0px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			        	<button type="button" class="btn btn-success" onclick=startDiscovery()>Start Discovery </button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		<!--  APP LIST -->
		<div class="modal fade bs-example-modal-md" id="appListDiv">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
			 		 <div class="modal-header" id=appListHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
			 		</div> <!--  modal header -->
				 	 <div class="modal-body" id="appListBody" style="min-height: 1px; max-height: 400px;  overflow-y: scroll; ">
			      	</div> <!--  modal body -->
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->		
		
		
		<!--  SQL EDITOR -->
		<div class="modal fade bs-example-modal-lg" id="sqlDiv">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		<div class="modal-header" id=sqlHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
			 		</div> <!--  modal header -->
			 		
			 	
				 	 <div class="modal-body" id="sqlBody">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
 
		
    <div class="container-fluid" id=MonitoringContainerDiv>
    
    	<div class=row>
    		<div class="col-md-4" id=divDiscoveryLeft  style="min-height: 80%; max-height: 80%; overflow-x: scroll; overflow-y: scroll;">
    			
    		</div>
    		
    		
    		<div class="col-md-8" id=divDiscoveryBody  style="min-height: 80%; max-height: 80%; overflow-x: scroll; overflow-y: scroll;">
    			
    		</div>
    	
    	</div>
	

    </div> <!--  container -->


  </body>
</html>


