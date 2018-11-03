<%@include file="header2.jsp" %> 

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>



<html>

  <head>
    <meta charset="utf-8">
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

    
  </head>




<%


roleRestrict(session,response,"DESIGN,ADMIN");



String curr_app_type=nvl(request.getParameter("app_type"),nvl((String) session.getAttribute("app_type"),"MASK"));
String curr_app_id=nvl(request.getParameter("app_id"),nvl((String) session.getAttribute("app_id"),""));
String curr_env_id=nvl(request.getParameter("env_id"),nvl((String) session.getAttribute("env_id"),""));
if (curr_app_type.equals("AUTO"))
	curr_env_id=nvl((String) session.getAttribute("domain_id"),"0");

String curr_schema_name=nvl(request.getParameter("schema_name"),nvl((String) session.getAttribute("schema_name"),"-"));
String curr_tab_id=nvl(request.getParameter("tab_id"),nvl((String) session.getAttribute("tab_id"),""));

if (curr_tab_id.equals("0")) curr_tab_id="";
%>

<script>

var curr_app_type="<%= curr_app_type %>";
var curr_app_id="<%= curr_app_id %>";
var curr_env_id="<%= curr_env_id %>";
var curr_schema="<%= curr_schema_name %>";
var curr_tab_id="<%= curr_tab_id %>";





</script>


 <body onload=bodyonload() style="background: url(img/bodyback.jpg); background-size:cover; ">



	
	
    <%=printHeader(request,session)%>
 
 
<!--  RUNNER -->
		<div class="modal fade bs-example-modal-lg" id="runnerDiv">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="runnerBody">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			        	<button type="button" class="btn btn-success" onclick=createWorkPlan()>Run Application </button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<!--  APP OPTIONS -->
		<div class="modal fade bs-example-modal-md" id="appOptionsDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="appOptionsBody">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-success" onclick=saveAppOptions()>Save </button>
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		
		<!--  COPY FILTER -->
		<div class="modal fade bs-example-modal-lg" id="filterTabDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="filterTabBody"   style="min-height: 0px; max-height: 500px; overflow-y: scroll; ">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		

		<!--  DEPENDED APPS -->
		<div class="modal fade bs-example-modal-lg" id="dependedAppsDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="dependedAppsBody"   style="min-height: 0px; max-height: 400px; overflow-y: scroll; ">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		<!--  DB SCRIPTS -->
		<div class="modal fade bs-example-modal-lg" id="dbScriptDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="dbScriptBody"   style="min-height: 0px; max-height: 400px; overflow-y: scroll; ">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<!--  CHECK LIST -->
		<div class="modal fade bs-example-modal-lg" id="checkListDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="checkListBody"   style="min-height: 0px; max-height: 400px; overflow-y: scroll; ">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		

		
		
		<!--  PROBLEMS FOR COPY APP -->
		<div class="modal fade bs-example-modal-lg" id="problemsDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="problemsBody"   style="min-height: 0px; max-height: 400px; overflow-y: scroll; ">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
				
		<!--  CHILD TABLE -->
		<div class="modal fade bs-example-modal-md" id="childTableDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
			 		<div class="modal-header" id=childTableHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
			 		</div> <!--  modal header -->
			 		
			 	
				 	 <div class="modal-body" id="childTableBody">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
		      			<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			   	     	<button type="button" class="btn btn-success" onclick=addTableAsChild()>Save</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<!--  COPY TABLE -->
		<div class="modal fade bs-example-modal-lg" id="copyTableDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog">
			 	<div class="modal-content">
			 		<div class="modal-header" id=copyTableHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
			 		</div> <!--  modal header -->
			 		
				 	 <div class="modal-body" id="copyTableBody" style="white-space: nowrap;  min-height: 40%; max-height: 40%; overflow-x: scroll;  overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-success" onclick=copyTableToApp()>Copy Selected Tables To The Current Application</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->		
			
		
		
		
		<!--  TABLE CONFIGURATION -->
		<div class="modal fade bs-example-modal-lg" id="tableEditorDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		 <div class="modal-header" id=tableEditorHeader>
			 			<button type="button" class="close" onclick=closeTableEditor()>
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
			 		</div> <!--  modal header -->
			 		
				 	 <div class="modal-body" id="tableEditorBody">
				 	 
						<div class=row>
							<div class="col-md-12"  style="min-height: 500px; max-height: 500px; overflow-y: scroll; overflow-x: scroll;">
								<div class=row><div id="div_tab_details" class="col-md-12"></div></div>
								<div class=row><div id="div_fields" class="col-md-12"></div></div>
							</div>
						</div>
			      	</div> <!--  modal body -->
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<!--  TABLE CONFIG -->
		<div class="modal fade" id="tableConfigDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="tableConfigBody" style="min-height: 0px; max-height: 500px; overflow-y: scroll; ">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			      		<button class="btn btn-success btn-md" onclick=saveTableConfiguration()>
			      			<span class="glyphicon glyphicon-import">Save Configuration</span>
			      		</button>
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<!--  CONDITION EDITOR -->
		<div class="modal fade bs-example-modal-lg" id="conditionEditor"  data-keyboard="false" data-backdrop="static">
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
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		


		<!--  CONDITION COPY -->
		<div class="modal fade" id="conditionCopyDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="conditionCopyBody">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	
			      	<div class="modal-footer">
			      		<button class="btn btn-success btn-md" onclick=copyFromFieldDone()>
			      			<span class="glyphicon glyphicon-import">Copy</span>
			      		</button>
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		
		
		
		<!-- PRE POST SCRIPT EDITOR -->
		<div class="modal fade bs-example-modal-lg" id="scriptDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		<div class="modal-header" id=scriptHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
		        		<div class="modal-title" id="scriptTitle"><h3>Script Editor</h3></div>
			 		</div> <!--  modal header -->
			 		
			 	
				 	 <div class="modal-body" id="scriptBody">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-success" onclick=saveScript()>Save</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->


		<!--  PROFILE PICKER -->
		<div class="modal fade bs-example-modal-lg" id="profileDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="profileBody">
			<!--  ***************************************************************************** -->
						<div class="row">
				      
					      <div class="col-md-4" style="min-height: 480px; max-height: 480px;  ">
					      	<div class="panel panel-primary">  	
						      	<div class="panel-heading">
									    <h3 class="panel-title">Mask Profile Lists </h3>
								</div>
								<div class="panel-body" id="listofProfileDiv"  >
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
					      
					      <div class="col-md-8" style="min-height: 480px; max-height: 480px; overflow-x: scroll; overflow-y: scroll; ">
					     	<div class="panel panel-primary">  	
					     	
					     		<div class="panel-heading">
					     			Masking Profile Configuration 
								</div>	
								
								<div class="panel-body" id="profileDetailsDiv" >
								
								</div>	  
								
					
								
							</div> <!--  div class=panel-primary -->
					      </div> <!--  div class=col-md9 -->
				      
				      </div> <!--  div class=row -->
			<!--  ***************************************************************************** -->


			      	</div> <!--  modal body -->

			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
			        	<button type="button" class="btn btn-success" onclick=setFieldProfile()>PICK PROFILE </button>
			      	</div>

			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		
			
		
		
		<!--  TABLE CONFIG -->
		<div class="modal fade" id="tableNeedDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="tableNeedBody" >
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			      		<button class="btn btn-success btn-md" onclick=saveTableNeed()>
			      			<span class="glyphicon glyphicon-import">Save</span>
			      		</button>
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->

		

		

		<!--  DISVOERY FOR TABLE -->
		<div class="modal fade" id="discoverForCopyDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="discoverForCopyBody" style="min-height: 0px; max-height: 500px; overflow-y: scroll; ">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
				
		
		<!--  APP LIST FOR TABLE -->
		<div class="modal fade" id="appListForTableDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="appListForTableBody" style="min-height: 0px; max-height: 500px; overflow-y: scroll; ">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		

		<!--  COMMENT FOR TABLE -->
		<div class="modal fade" id="commentForTableDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="commentForTableBody" style="min-height: 0px; max-height: 500px; overflow-y: scroll; ">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			        	<button type="button" class="btn btn-danger" id=btRemoveComment onclick="removeTableComment();">Remove</button>
			        	<button type="button" class="btn btn-success" id=btSelectLOV onclick="saveTableComment();">Save</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		
		
		
		<!--  SET COPY TABLE ORDER -->
		<div class="modal fade" id="copyTableOrderDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
				 	 <div class="modal-body" id="copyTableOrderBody" >
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
			      	<div class="modal-footer">
			      		<button class="btn btn-success btn-md" onclick=setCopyTableOrderDo()>
			      			<span class="glyphicon glyphicon-import">Set Order</span>
			      		</button>
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<!-- BULK CONFIG IMPORT -->
		<div class="modal fade bs-example-modal-lg" id="configImportDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		<div class="modal-header" id=configImportHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
			 		</div> <!--  modal header -->
			 		
			 	
				 	 <div class="modal-body" id="configImportBody">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			        	<button type="button" class="btn btn-warning" onclick=testBulkConfig()>Test Import</button>
			        	<button type="button" class="btn btn-success" onclick=importBulkConfig()>Run Import</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<!--  CONTENT BASED DYNAMIC MASKING RULES -->
		<div class="modal fade bs-example-modal-lg" id="dynamicMaskingConfDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="dynamicMaskingConfBody" style="min-height: 550px; max-height: 550px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		<!--  EXCEPTION WINDOW -->
		<div class="modal fade bs-example-modal-md" id="exceptionDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="exceptionBody" style="min-height: 300px; max-height: 300px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		
		
		<!--  DATA POOL CONF WINDOW -->
		<div class="modal fade bs-example-modal-lg" id="dataPoolConfigurationDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="dataPoolConfigurationBody" style="min-height: 300px; max-height: 300px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-success" onclick=saveDataPoolConfiguration()> Save Configuration </button>
			        	<button type="button" class="btn btn-default" data-dismiss="modal"> Close </button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		<!--  DATA POOL LOV WINDOW -->
		<div class="modal fade bs-example-modal-lg" id="dataPoolLovDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="dataPoolLovBody" style="min-height: 400px; max-height: 400px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal"> Close </button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		<!--  DATA POOL GROUP WINDOW -->
		<div class="modal fade bs-example-modal-md" id="dataPoolGroupDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-md">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="dataPoolGroupBody" style="min-height: 400px; max-height: 400px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-default" data-dismiss="modal"> Close </button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->
		
		<!--  DATA POOL PROPERTY WINDOW -->
		<div class="modal fade bs-example-modal-lg" id="dataPoolPropertyDiv"  data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		
				 	 <div class="modal-body" id="dataPoolPropertyBody" style="min-height: 450px; max-height: 450px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			        	<button type="button" class="btn btn-success" onclick=saveDataPoolProperty()> Save Property </button>
			        	<button type="button" class="btn btn-default" data-dismiss="modal"> Close </button>
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
		
		    
   
<div class="container-fluid">


			
<div class="row">

<div class="col-md-3" id="div_app_type">
</div>



<div  class="col-md-5" id="div_app"> 
</div>


 
 <div class="col-md-4" id="div_env">
</div>

</div> <!--  header row -->


<div class="row">
      
      <div class="col-md-4"   style="white-space: nowrap;  min-height: 80%; max-height: 80%; overflow-x: scroll;  overflow-y: scroll;">
 	      <div class="row">
             <div id=div_table_list_header  class="col-md-12"></div>
	      </div> 
	      <div class="row" >
			  <div id=div_table class="col-md-12" ></div>
	      </div> 
      
      </div> <!-- col-md-3 -->
      
	    <div class="col-md-8"  style="white-space: nowrap;  min-height: 80%; max-height: 80%; overflow-x: scroll;  overflow-y: scroll;">
 			  <div class="row" id="div_app_table"></div>
			 
 
      	</div> <!--col-md-9-->
    

    </div>


  </body>
</html>


