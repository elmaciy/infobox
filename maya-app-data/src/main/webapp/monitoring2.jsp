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
roleRestrict(session,response,"RUN,DESIGN,ADMIN");

%> 



<body onload=onmonitoringload2() style="background: url(img/bodyback.jpg); background-size:cover; ">

 
	
	
<%=printHeader(request,session)%>
 
 
 		
		
		<!--  WORK PLAN WINDOW -->
		<div class="modal fade bs-example-modal-lg" id="workPlanWindowDiv">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	<div class="modal-body" id="workPlanWindowBody"  style="min-height: 300px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		<!--  PROCESS LIST-->
		<div class="modal fade bs-example-modal-lg" id="processListDiv">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		<div class="modal-header" id=processListHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
			 		</div> <!--  modal header -->
				 	 <div class="modal-body" id="processListBody"  style="min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
	
		
		
		<!--  WORK PACKAGE LIST-->
		<div class="modal fade bs-example-modal-lg" id="workPackageListDiv">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	<div class="modal-body" id="workPackageListBody"  style="min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		<!--  ASSIGN WORK PACKAGE-->
		<div class="modal fade bs-example-modal-md" id="workPackageAssignDiv">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	<div class="modal-body" id="workPackageAssignBody"  style="min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		<!--  TASK LIST-->
		<div class="modal fade bs-example-modal-lg" id="taskListDiv">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	<div class="modal-body" id="taskListBody"  style="min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		
		<!--  TASK INFO -->
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
		
		
		<!--  WORK PLAN EDITOR -->
			<div class="modal fade bs-example-modal-md" id="workPlanParamsEditorDiv">
				<div class="modal-dialog modal-md">
				 	<div class="modal-content">
				 		
					 	 <div class="modal-body" id="workPlanParamsEditorBody">
					        <p>One fine body&hellip;</p>
				      	</div> <!--  modal body -->
			      	
			      	
				      	<div class="modal-footer">
				        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				        	<button type="button" class="btn btn-success" onclick=saveWorkPlanParameters()>Save </button>
				      	</div>
			      	
				 	</div> <!--  modal content -->	 		
				</div> <!--  modal dialog -->
			</div> <!--  modal fade -->
		 
 		<!--  DISCOVERY -->
		<div class="modal fade bs-example-modal-lg" id="discDiv" >
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		<div class="modal-header" id=discHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
			 		</div> <!--  modal header -->
			 		
			 	
				 	 <div class="modal-body" id="discBody"  style="min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-success" onclick=generateDiscoveryReport()>Download Report </button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		
    
   		<!--  TABLE CONFIGURATION -->
		<div class="modal fade bs-example-modal-lg" id="tableEditorDiv">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		<div class="modal-header" id=tableEditorHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
			 		</div> <!--  modal header -->
			 		
				 	 <div class="modal-body" id="tableEditorBody">
						<div class="panel panel-primary"  style="min-height: 580px; max-height: 580px; overflow-y: scroll;">
					
							  <div id="div_tab_details" class="panel-body">
							  </div>

						  	  <div class="panel-body" id="div_fields" >
					  		  </div>

				  		</div> <!-- panel panel-success -->
				  
			      	</div> <!--  modal body -->

			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
    
    
    	
		<!--  CONDITION EDITOR -->
		<div class="modal fade bs-example-modal-lg" id="conditionEditor">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		<div class="modal-header" id=conditionEditorHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
		        		<div class="modal-title" id="conditionEditorTitle"><h3>Condition Editor</h3></div>
			 		</div> <!--  modal header -->
			 		
			 	
				 	 <div class="modal-body" id="conditionEditorBody">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			      		<button class="btn btn-info btn-md" onclick=copyFromField()>
			      			<span class="glyphicon glyphicon-import">Copy From</span>
			      		</button>
			        	<button type="button" class="btn btn-success">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
    
   		<!--  CONDITION COPY -->
		<div class="modal fade" id="conditionCopyDiv">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="conditionCopyBody">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			      		<button class="btn btn-info btn-success" onclick=copyFromFieldDone()>
			      			<span class="glyphicon glyphicon-import">Copy</span>
			      		</button>
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
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

    
    		<!--  PROFILE PICKER -->
		<div class="modal fade bs-example-modal-lg" id="profileDiv">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="profileBody">
			<!--  ***************************************************************************** -->
						<div class="row">
				      
					      <div class="col-md-4">
					      	<div class="panel panel-primary">  	
						      	<div class="panel-heading">
									    <h3 class="panel-title">Mask Profile Lists </h3>
								</div>
								<div class="panel-body" id="listofProfileDiv"  style="min-height: 440px; max-height: 440px; overflow-x: scroll; overflow-y: scroll; ">
								</div>	  
								<div class="panel-footer  clearfix">
									<a class="navbar-brand" href="#" onclick=addNewProfile()>
						              <span class="glyphicon glyphicon-plus-sign"></span>
									  <span class="glyphicon-class"></span>
								  	</a>
						
									<a class="navbar-brand" href="#" onclick=renameProfile()>
						              <span class="glyphicon glyphicon-edit"></span>
									  <span class="glyphicon-class"></span>
								  	</a>
								  	
								  	<a class="navbar-brand" href="#" onclick=deleteProfile()>
						              <span class="glyphicon glyphicon-minus-sign"></span>
									  <span class="glyphicon-class"></span>
								  	</a>
								</div> <!--  panel footer -->
							</div> <!--  div class=panel-primary -->
					      
					      </div> <!--  div class=col-md3 -->
					      
					      <div class="col-md-8">
					     	<div class="panel panel-primary">  	
					     	
					     		<div class="panel-heading">
					     			Masking Profile Configuration 
								</div>	
								
								<div class="panel-body" id="profileDetailsDiv" style="min-height: 500px; max-height: 500px; overflow-x: scroll; overflow-y: scroll; ">
								
								</div>	  
								
					
								
							</div> <!--  div class=panel-primary -->
					      </div> <!--  div class=col-md9 -->
				      
				      </div> <!--  div class=row -->
			<!--  ***************************************************************************** -->


			      	</div> <!--  modal body -->

			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
			        	<button type="button" class="btn btn-success" onclick="setFieldProfile();"> PICK PROFILE </button>
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
		
		
		

		
			
		
    <div class="container-fluid" id=MonitoringContainerDiv>
    
    
	

    </div> <!--  container -->


  </body>
</html>


