
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

    <title>Infobxo TDM</title>

   
    
   
  	
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
roleRestrict(session,response,"DESIGN,ADMIN,RUN,COPYUSER");

%> 



<body onload=oncopyload() style="background: url(img/bodyback.jpg); background-size:cover; ">

 
	
	
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
		
		
		<div class="modal fade bs-example-modal-lg" id="failedWPDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="failedWPBody"  style="min-height: 0px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		<div class="modal fade bs-example-modal-md" id="dependedWPDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="dependedWPBody"  style="min-height: 0px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<div class="modal fade bs-example-modal-lg" id="tableCompareDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="tableCompareBody"  style="min-height: 0px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			        	<button type="button" class="btn btn-success" id=btStartCopy onclick="startCopyDO();">Start Copy</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<!--  SQL EDITOR -->
		<div class="modal fade bs-example-modal-lg" id="sqlDiv" data-keyboard="false" data-backdrop="static">
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
		
		
    <div class="container-fluid" id=CopyContainerDiv>
    
    	<div class=row>
    		
    		<div class="col-md-12" id=divCopyBody>
    			
    		</div>
    	
    	</div>
	

    </div> <!--  container -->


  </body>
</html>


