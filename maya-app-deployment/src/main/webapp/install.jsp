<%@ page language="java" contentType="text/html; charset=UTF-8"   pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

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
    <script src="style/bootstrap/js/bootbox.js"></script>


  </head>
  
  
<script>
var AJAX = createXMLHttpRequest();

var installation_step_no=1;

var targetdiv_id="";

var orig_div_content1="";
var orig_div_content2="";
var orig_div_content3="";
var orig_div_content4="";
var orig_div_content5="";
var orig_div_content6="";
var orig_div_content7="";
var orig_div_content8="";

//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1){
//*************************************************************************	
	ajaxDynamicComponentCaller(action,div_id,par1,"","","","");
}

//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1,par2){
//*************************************************************************	
	ajaxDynamicComponentCaller(action,div_id,par1,par2,"","","");
}

//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1,par2,par3){
//*************************************************************************	
	ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,"","");
}

//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,par4){
//*************************************************************************	
	ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,par4,"");
}

//*************************************************************************
function createXMLHttpRequest(){
//*************************************************************************
  // See http://en.wikipedia.org/wiki/XMLHttpRequest
  // Provide the XMLHttpRequest class for IE 5.x-6.x:
  if( typeof XMLHttpRequest == "undefined" ) XMLHttpRequest = function() {
    try { return new ActiveXObject("Msxml2.XMLHTTP.6.0"); } catch(e) {}
    try { return new ActiveXObject("Msxml2.XMLHTTP.3.0"); } catch(e) {}
    try { return new ActiveXObject("Msxml2.XMLHTTP"); } catch(e) {}
    try { return new ActiveXObject("Microsoft.XMLHTTP"); } catch(e) {}
    throw new Error( "This browser does not support XMLHttpRequest." );
  };
  return new XMLHttpRequest();
}

var myApp;
myApp = myApp || (function () {
    var pleaseWaitDiv = $('<div class="modal hide" id="pleaseWaitDialog" data-backdrop="static" data-keyboard="false"><div class="modal-header"><h1>Processing...</h1></div><div class="modal-body"><div class="progress progress-striped active"><div class="bar" style="width: 100%;"></div></div></div></div>');
    return {
        showPleaseWait: function() {
            pleaseWaitDiv.modal();
        },
        hidePleaseWait: function () {
            pleaseWaitDiv.modal('hide');
        },

    };
})();

//*********************************************
function showBlocker() {
//*********************************************
var el=document.getElementById("pleaseWaitDialog");

if (!el) return;

myApp.showPleaseWait();

}

//*********************************************
function hideBlocker() {
//*********************************************
var el=document.getElementById("pleaseWaitDialog");

if (!el) return;

myApp.hidePleaseWait();

}

//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,par4,par5){
//*************************************************************************	
	showBlocker();
	
	if (par1) par1 = par1.replace(/(?:\r\n|\r|\n)/g, '::NEWLINE::');
	if (par2) par2 = par2.replace(/(?:\r\n|\r|\n)/g, '::NEWLINE::');
	if (par3) par3 = par3.replace(/(?:\r\n|\r|\n)/g, '::NEWLINE::');
	if (par4) par4 = par4.replace(/(?:\r\n|\r|\n)/g, '::NEWLINE::');
	if (par5) par5 = par5.replace(/(?:\r\n|\r|\n)/g, '::NEWLINE::');
	
	
	orig_div_content1="";
	orig_div_content2="";
	orig_div_content3="";
	orig_div_content4="";
	orig_div_content5="";
	orig_div_content6="";
	orig_div_content7="";
	orig_div_content8="";

  var id=0;
  div_id.split('|').forEach(function(x){
	  id++;
	  if (x!="NONE")
		  {
		  if (id==1) orig_div_content1=document.getElementById(x).innerHTML;
		  if (id==2) orig_div_content2=document.getElementById(x).innerHTML;
		  if (id==3) orig_div_content3=document.getElementById(x).innerHTML;
		  if (id==4) orig_div_content4=document.getElementById(x).innerHTML;
		  if (id==5) orig_div_content5=document.getElementById(x).innerHTML;
		  if (id==6) orig_div_content6=document.getElementById(x).innerHTML;
		  if (id==7) orig_div_content7=document.getElementById(x).innerHTML;
		  if (id==8) orig_div_content8=document.getElementById(x).innerHTML;
		  
		  document.getElementById(x).innerHTML="<h1>Loading...</h1>";
 		  }
  });
  
  targetdiv_id=div_id;

  
  AJAX.onreadystatechange = handler_handler;
  
  par1=encodeURIComponent(par1);
  par2=encodeURIComponent(par2);
  par3=encodeURIComponent(par3);
  par4=encodeURIComponent(par4);
  par5=encodeURIComponent(par5);

  AJAX.open("POST", "ajaxInstallerComponent.jsp?action=" + action + "&div=" + div_id + "&par1=" + par1 + "&par2=" + par2 + "&par3="+par3+ "&par4="+par4+ "&par5="+par5, true);
  //AJAX.setRequestHeader( 'content-type', 'text/html;charset=UTF-8');
  AJAX.send("");
}


//*************************************************************************
function handler_handler() {
//*************************************************************************

  
	
  if(AJAX.readyState == 4 && AJAX.status == 200) {
	  
	  hideBlocker();
	  
	  
      var json = eval('(' + AJAX.responseText +')');
      var msg=json.msg;
      
      var html1=json.html1;
      var html2=json.html2;
      var html3=json.html3;
      var html4=json.html4;
      var html5=json.html5;
      var html6=json.html6;
      var html7=json.html7;
      var html8=json.html8;

      var div1=json.div1;
      var div2=json.div2;
      var div3=json.div3;
      var div4=json.div4;
      var div5=json.div5;
      var div6=json.div6;
      var div7=json.div7;
      var div8=json.div8;

      
      
      //-----------------------------------------------------------------------------
      if(html1) {
          var targetdiv=document.getElementById(div1);
          if (targetdiv) targetdiv.innerHTML=html1;
          if (html1.indexOf("javascript:")==0) runjs_code(html1.substring(11));
      } else 
    	  if (div1) 
    		  if (div1!="NONE")  document.getElementById(div1).innerHTML=orig_div_content1;
      
      //-----------------------------------------------------------------------------
      if(html2) {
          var targetdiv=document.getElementById(div2);
          if (targetdiv) targetdiv.innerHTML=html2;
          if (html2.indexOf("javascript:")==0) runjs_code(html2.substring(11));
      } else 
    	  if (div2) 
    		  if (div2!="NONE")  document.getElementById(div2).innerHTML=orig_div_content2;

      //-----------------------------------------------------------------------------
      if(html3) {
          var targetdiv=document.getElementById(div3);
          if (targetdiv) targetdiv.innerHTML=html3;
          if (html3.indexOf("javascript:")==0) runjs_code(html3.substring(11));
      } else 
    	  if (div3) 
    		  if (div3!="NONE")  document.getElementById(div3).innerHTML=orig_div_content3;

      //-----------------------------------------------------------------------------
      if(html4) {
          var targetdiv=document.getElementById(div4);
          if (targetdiv) targetdiv.innerHTML=html4;
          if (html4.indexOf("javascript:")==0) runjs_code(html4.substring(11));
      } else 
    	  if (div4) 
    		  if (div4!="NONE")  document.getElementById(div4).innerHTML=orig_div_content4;
      
      //-----------------------------------------------------------------------------
      if(html5) {
          var targetdiv=document.getElementById(div5);
          if (targetdiv) targetdiv.innerHTML=html5;
          if (html5.indexOf("javascript:")==0) runjs_code(html5.substring(11));
      } else 
    	  if (div5) 
    		  if (div5!="NONE")  document.getElementById(div5).innerHTML=orig_div_content5;
      //-----------------------------------------------------------------------------
      if(html6) {
          var targetdiv=document.getElementById(div6);
          if (targetdiv) targetdiv.innerHTML=html6;
          if (html6.indexOf("javascript:")==0) runjs_code(html6.substring(11));
      } else 
    	  if (div6) 
    		  if (div6!="NONE")  document.getElementById(div6).innerHTML=orig_div_content6;
      //-----------------------------------------------------------------------------
      if(html7) {
          var targetdiv=document.getElementById(div7);
          if (targetdiv) targetdiv.innerHTML=html7;
          if (html7.indexOf("javascript:")==0) runjs_code(html7.substring(11));
      } else 
    	  if (div7) 
    		  if (div7!="NONE")  document.getElementById(div7).innerHTML=orig_div_content7;
      //-----------------------------------------------------------------------------
      if(html8) {
          var targetdiv=document.getElementById(div8);
          if (targetdiv) targetdiv.innerHTML=html8;
          if (html8.indexOf("javascript:")==0) runjs_code(html8.substring(11));
      } else 
    	  if (div8) 
    		  if (div8!="NONE")  document.getElementById(div8).innerHTML=orig_div_content8;
      
            
      if (msg.indexOf("nok:")==0) {
 
   	  if (orig_div_content1!="") if (div1!="NONE")  document.getElementById(div1).innerHTML=orig_div_content1;
   	  if (orig_div_content2!="") if (div2!="NONE")  document.getElementById(div2).innerHTML=orig_div_content2;
   	  if (orig_div_content3!="") if (div3!="NONE")  document.getElementById(div3).innerHTML=orig_div_content3;
   	  if (orig_div_content4!="") if (div4!="NONE")  document.getElementById(div4).innerHTML=orig_div_content4;
   	  if (orig_div_content5!="") if (div5!="NONE")  document.getElementById(div5).innerHTML=orig_div_content5;
   	  if (orig_div_content6!="") if (div6!="NONE")  document.getElementById(div6).innerHTML=orig_div_content6;
   	  if (orig_div_content7!="") if (div7!="NONE")  document.getElementById(div7).innerHTML=orig_div_content7;
   	  if (orig_div_content8!="") if (div8!="NONE")  document.getElementById(div8).innerHTML=orig_div_content8;
    	  
    	  
    	  bootbox.alert(msg.substring(4));
      }
      
      
      orig_div_content1="";
      orig_div_content2="";
      orig_div_content3="";
      orig_div_content4="";
      orig_div_content5="";
      orig_div_content6="";
      orig_div_content7="";
      orig_div_content8="";
      
  }else if (AJAX.readyState == 4 && AJAX.status != 200) {
	 hideBlocker();
	 myalert('Something went wrong on ajax call...');
  }
}



//**************************************************************
function loadStep(step) {
		var action="installation_step";
		var div_id="installationDetailsDiv";
		var par1=""+step;

		ajaxDynamicComponentCaller(action, div_id, par1);
}

//**************************************************************
function nextInstallationStep() {
	installation_step_no=installation_step_no+1;
	
	if (installation_step_no>3) installation_step_no=3;
	else loadStep(installation_step_no);
}

//**************************************************************
function prevInstallationStep() {
	installation_step_no=installation_step_no-1;
	
	if (installation_step_no<1) installation_step_no=1;
	else loadStep(installation_step_no);
	
}

//**************************************************************
function connectDB() {
	
	var db_host=document.getElementById("db_host").value;
	var db_port=document.getElementById("db_port").value;
	var db_user=document.getElementById("db_user").value;
	var db_pass=document.getElementById("db_pass").value;
	
	if (db_host=="") db_host="<EMPTY>";	
	if (db_port=="") db_port="<EMPTY>";	
	if (db_user=="") db_user="<EMPTY>";	
	if (db_pass=="") db_pass="<EMPTY>";	
	
	var db_params=db_host+"::"+db_port+"::"+db_user+"::"+db_pass;
	
	var action="connect_db|installation_step";
	var div_id="NONE|installationDetailsDiv";
	var par1=db_params+"|"+installation_step_no;

	ajaxDynamicComponentCaller(action, div_id, par1);
	
}


//********************************************************
function installNow() {
	
	var db_name=document.getElementById("db_name").value;
	var tdm_home=document.getElementById("tdm_home").value;
	
	if (db_name.length==0) {
		bootbox.alert("Please enter db name to install");
		return;
	}
	
	if (tdm_home.length==0) {
		bootbox.alert("Please enter installation home");
		return;
	}

	
	bootbox.confirm("Do you want to start installation?", function(result) {
		
		if(!result) return;
		
		var db_name=document.getElementById("db_name").value;
		var tdm_home=document.getElementById("tdm_home").value;
		
		var install_params=db_name+"::"+tdm_home;

		var action="install_tdm|installation_step";
		var div_id="NONE|installationDetailsDiv";
		var par1=install_params+"|"+installation_step_no;

		ajaxDynamicComponentCaller(action, div_id, par1);

	}); 

	
}


</script>

<body onload=loadStep(1);  style="background: url(img/bodyback.jpg); background-size:cover; ">



<div class="container">

      

      
      <div class="col-md-12">
     	<div class="panel panel-primary">  	
     	
     		<div class="panel-heading">
     			Installation Details
			</div>	
			
			<div class="panel-body" id="installationDetailsDiv" style="min-height: 200px; max-height: 600px; ">
			
			</div>	  
			
			
		</div> <!--  div class=panel-primary -->
      </div> <!--  div class=col-md9 -->
      
</div>


</body>

</html>