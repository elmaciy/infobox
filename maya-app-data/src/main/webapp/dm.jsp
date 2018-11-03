
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



<body onload=listDMProxies() style="background: url(img/bodyback.jpg); background-size:cover; ">

 
	
	
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
		
		
		<div class="modal fade bs-example-modal-lg" id="addNewDMProxyDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="addNewDMProxyBody"  style="min-height: 0px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-success" onclick=saveDMConfiguration()>Save & Close</button>
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<div class="modal fade bs-example-modal-lg" id="proxySessionListDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="proxySessionListBody"  style="min-height: 0px; max-height: 90%; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<!--  ERROR INFO -->
		<div class="modal fade bs-example-modal-lg" id="taskDiv">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="div_task_info"  style="min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
			</div> <!--  modal fade -->
			
			
			<!--  SESSION COMMANDS LIST -->
			<div class="modal fade bs-example-modal-lg" id="divSessionCommandsDiv">
				<div class="modal-dialog modal-lg">
				 	<div class="modal-content">
					 	 <div class="modal-body" id="divSessionCommandsBody"  style="min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;">
					        <p>One fine body&hellip;</p>
				      	</div> <!--  modal body -->
				      	<div class="modal-footer">
				        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				      	</div>
				 	</div> <!--  modal content -->	 		
				</div> <!--  modal dialog -->
			</div> <!--  modal fade -->
			
			
			<!-- SET EXCEPTION FOR SESSIONS DLG -->
			<div class="modal fade bs-example-modal-md" id="divSetExceptionForSessionsDiv">
				<div class="modal-dialog modal-md">
				 	<div class="modal-content">
					 	 <div class="modal-body" id="divSetExceptionForSessionsBody">
					        <p>One fine body&hellip;</p>
				      	</div> <!--  modal body -->
				      	<div class="modal-footer">
				        	<button type="button" class="btn btn-success" onclick=setExceptionForSessionDO()>Set Exception</button>
				        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				      	</div>
				 	</div> <!--  modal content -->	 		
				</div> <!--  modal dialog -->
			</div> <!--  modal fade -->
			
			
			<!--  MASKED SAMPLE DATA -->
			<div class="modal fade bs-example-modal-lg" id="divMaskedSampleDiv">
				<div class="modal-dialog modal-lg">
				 	<div class="modal-content">
					 	 <div class="modal-body" id="divMaskedSampleBody"  style="min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;">
					        <p>One fine body&hellip;</p>
				      	</div> <!--  modal body -->
				      	<div class="modal-footer">
				        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				      	</div>
				 	</div> <!--  modal content -->	 		
				</div> <!--  modal dialog -->
			</div> <!--  modal fade -->
			
			
			<!-- SET EXCEPTION FOR SESSIONS DLG -->
			<div class="modal fade bs-example-modal-md" id="proxySessionFilterDiv">
				<div class="modal-dialog modal-md">
				 	<div class="modal-content">
					 	 <div class="modal-body" id="proxySessionFilterBody">
					        <p>One fine body&hellip;</p>
				      	</div> <!--  modal body -->
				      	<div class="modal-footer">
				        	<button type="button" class="btn btn-warning" onclick=clearFilterSessionsDO()>Clear Filter</button>
				        	<button type="button" class="btn btn-success" onclick=setFilterSessionsDO()>Set Filter</button>
				        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				      	</div>
				 	</div> <!--  modal content -->	 		
				</div> <!--  modal dialog -->
			</div> <!--  modal fade -->
		
		
			<!-- MANAGE BLACKLIST -->
			<div class="modal fade bs-example-modal-lg" id="proxyManageBlacklistDiv">
				<div class="modal-dialog modal-lg">
				 	<div class="modal-content">
					 	 <div class="modal-body" id="proxyManageBlacklistBody">
					        <p>One fine body&hellip;</p>
				      	</div> <!--  modal body -->
				      	<div class="modal-footer">
				        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				      	</div>
				 	</div> <!--  modal content -->	 		
				</div> <!--  modal dialog -->
			</div> <!--  modal fade -->
			
			
			<!--  BLACKLISTED SESSION COMMANDS LIST -->
			<div class="modal fade bs-example-modal-lg" id="divBlackListedSessionCommandsDiv">
				<div class="modal-dialog modal-lg">
				 	<div class="modal-content">
					 	 <div class="modal-body" id="divBlackListedSessionCommandsBody"  style="min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;">
					        <p>One fine body&hellip;</p>
				      	</div> <!--  modal body -->
				      	<div class="modal-footer">
				        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				      	</div>
				 	</div> <!--  modal content -->	 		
				</div> <!--  modal dialog -->
			</div> <!--  modal fade -->
		
    <div class="container-fluid" id=dmContainerDiv>
    
    	
	

    </div> <!--  container -->


  </body>
</html>


