<%@ page language="java" contentType="text/html; charset=UTF-8"   pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">


<%@include file="header2.jsp" %> 

<%

roleRestrict(session,response,"DESIGN,ADMIN");

request.setCharacterEncoding("utf-8");


String v_delimiter=nvl(((String) session.getAttribute("column_delimiter")),";");

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

<%if (!nvl(request.getParameter("listList"),"-").equals("-")) {%>

<script>
curr_list_id=<%=request.getParameter("listList")%>
</script>
<% } %>
    
  </head>
  
  


<body onload=loadListofList() style="background: url(img/bodyback.jpg); background-size:cover; ">

<%=printHeader(request,session)%>


   		<!--  CREATE LIST FROM DB -->
		<div class="modal fade bs-example-modal-lg" id="listfromDBDiv" data-keyboard="false" data-backdrop="static">
			<div class="modal-dialog modal-lg">
			 	<div class="modal-content">
			 		<div class="modal-header" id=listfromDBHeader>
			 			<button type="button" class="close" data-dismiss="modal">
			 				<span aria-hidden="true">&times;</span>
			 				<span class="sr-only">Close</span>
			 			</button>
		        		<div class="modal-title" id="listfromDBTitle"><h3>Load list from database</h3></div>
			 		</div> <!--  modal header -->
			 		
			 	
				 	 <div class="modal-body" id="listfromDB_body"  style="min-height: 500px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;">
				        <p>One fine body&hellip;</p>
			      	</div> <!--  modal body -->
		      	
		      	
			      	<div class="modal-footer">
			      		<b>Item count to import</b> : 
			      		<input type=text value="1000" id=itemcount size=6 maxlength=6>
			      		&nbsp;&nbsp;&nbsp;&nbsp;
			      		<b>Distinct Values Only</b> : 
			      		<input type=checkbox id=uniqueonly checked>
			      		&nbsp;&nbsp;&nbsp;&nbsp;
			        	<button type="button" class="btn btn-success" onclick=createDBList();>Create List</button>
			      	</div>
		      	
			 	</div> <!--  modal content -->	 		
			</div> <!--  modal dialog -->
		</div> <!--  modal fade -->

<div class="container-fluid">

		<div class="row">
      
      <div class="col-md-4">
      	<div class="panel panel-primary">  	
	      	<div class="panel-heading">
				    <h3 class="panel-title">Lists </h3>
			</div>
			<div class="panel-body" id="listofListDiv"  style="min-height: 450px; max-height: 450px; ">
			</div>	  
			<div class="panel-footer  clearfix">
			<div class="pull-right">
				<a class="navbar-brand" href="#" onclick=addNewList()>
	              <span class="glyphicon glyphicon-plus-sign"></span>
				  <span class="glyphicon-class">Add</span>
			  	</a>
	
				<a class="navbar-brand" href="#" onclick=renameList()>
	              <span class="glyphicon glyphicon-edit"></span>
				  <span class="glyphicon-class">Rename</span>
			  	</a>
			  	
			  	<a class="navbar-brand" href="#" onclick=deleteList()>
	              <span class="glyphicon glyphicon-minus-sign"></span>
				  <span class="glyphicon-class">Delete</span>
			  	</a>
				</div>	<!--  pull right -->  					
			</div> <!--  panel footer -->
		</div> <!--  div class=panel-primary -->
      
      </div> <!--  div class=col-md3 -->
      
      <div class="col-md-8">
     	<div class="panel panel-primary">  	
     	
     		<div class="panel-heading">
     			Content of list
			</div>	
			
			<div class="panel-body" id="itemsofListDiv" style="min-height: 450px; max-height: 450px; overflow-x: scroll; overflow-y: scroll; ">
			
			</div>	  
			
			<div class="panel-footer  clearfix">
			
			
				
				<div class="col-md-3">
					<div class="input-group  input-group-sm">
					  <span class="input-group-addon">Delimiter :</span>
					  <input type="text" id=delimiter class="form-control" value="<%=v_delimiter%>" onchange=changeDelimiter()>
					</div>
				</div>

				<div class="col-md-9">
				
					<!--  <a class="navbar-brand" href="#" onclick=uploadFromFile()>-->
					<button type=button class="btn btn-md" onclick=uploadFromFile()>
		              <span class="glyphicon glyphicon-file">Load From File</span>
		            </button>
				  	<!--  </a>-->
				  	
					<!--  <a class="navbar-brand" href="#" onclick=createListFromDB()> -->
					<button type=button class="btn btn-md" onclick=createListFromDB()> 
		              <span class="glyphicon glyphicon-import">Load From Database</span>
	                </button>
				  	<!--  </a> -->
				  	
					
		

					<button type=button class="btn btn-md" onclick="downloadListToFile()"> 
		              <span class="glyphicon glyphicon-save">Download</span>
	                </button> 

				  </div>
			</div>	
			
		</div> <!--  div class=panel-primary -->
      </div> <!--  div class=col-md9 -->
      
      </div> <!--  div class=row -->
</div>


</body>

</html>