
var AJAX = createXMLHttpRequest();

var delim=":::::";

var z_index_counter=9999;

var curr_tab_name="";
var current_condition_field_id="";
var expanded_work_plan_id="";
var detailed_work_plan_id="";
var curr_table_filter="";
var curr_process_type="";
var curr_process_status="";
var curr_field_id="";

var active_tab_id="workplanTab";
var div_workplan_scrollTop=0;
var div_discovery_scrollTop=0;


var is_table_filter_validated=true;
var is_table_parallel_mod_validated=true;

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
    try { return new ActiveXObject("Msxml2.XMLHTTP.6.0"); } catch(e) {  console.log(e); }
    try { return new ActiveXObject("Msxml2.XMLHTTP.3.0"); } catch(e) { console.log(e); }
    try { return new ActiveXObject("Msxml2.XMLHTTP"); } catch(e) { console.log(e); }
    try { return new ActiveXObject("Microsoft.XMLHTTP"); } catch(e) { console.log(e); }
    throw new Error( "This browser does not support XMLHttpRequest." );
  };
  return new XMLHttpRequest();
}





var blockerTimeout;
var hourglassTimeout;

function DoHourGlassShow() {
	  var divArr=Object.keys(orig_div_contents);

	  for (var d=0;d<divArr.length;d++) {
		  var div_id=divArr[d];
		  if (div_id=="NONE" || div_id.indexOf("NOFADE_")==0) {
			  continue;
		  }
		  var el=document.getElementById(div_id);
		  if (!el) {
			  console.log("div ["+div_id+"] not found@DoHourGlassShow");
			  continue;
		  }
		  el.innerHTML="<h3><img src=\"img/hourglass.gif\" width=50 height=50 border=0> <font color=green>Loading...</font></h3>";
		  
	  }
}


//*********************************************
function showHourGlass() {
	hourglassTimeout=setTimeout(function(){DoHourGlassShow();},500);
}
//*********************************************
function clearHourGlass() {
	try {window.clearTimeout(hourglassTimeout);} catch(err) {console.log(err);};
}


/*
var myAppForWait;
myAppForWait = myAppForWait || (function () {
    var pleaseWaitDivx = $('<div class="modal hide" id="pleaseWaitDialogx" data-backdrop="static" data-keyboard="false"><div class="modal-header"><h1>Processing...</h1></div><div class="modal-body"><div class="progress progress-striped active"><div class="bar" style="width: 100%;"></div></div></div></div>');
    return {
        showPleaseWait: function() {
        	
        	z_index_counter++;
        	pleaseWaitDivx.style.zIndex=""+z_index_counter;
        	
        	pleaseWaitDivx.modal();
        },
        hidePleaseWait: function () {
        	pleaseWaitDivx.modal('hide');
        },

    };
})();

*/


//*********************************************
//function showBlocker() {
//*********************************************
//	blockerTimeout=setTimeout(function(){DOshowBlocker();},500);
//}

//*********************************************
//function hideBlocker() {
//*********************************************

	
//try {window.clearTimeout(blockerTimeout);} catch(err) {}
	
//var el=document.getElementById("pleaseWaitDialogx");

//if (!el) return;

//myAppForWait.hidePleaseWait();

//}

//*********************************************
//function DOshowBlocker() {
//*********************************************
	
//	var el=document.getElementById("pleaseWaitDialogx");

//	if (!el) return;

//	myAppForWait.showPleaseWait();
//	try {window.clearTimeout(blockerTimeout);} catch(err) {}

//}





var orig_div_contents=[];


//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,par4,par5){
//*************************************************************************	
	

	// ssping if (div_id!="NONE" && div_id.indexOf("NOFADE_")==-1) showBlocker();
	
	
	if (par1) 
		par1 = par1.replace(/(?:\r\n|\r|\n)/g, '**NEWLINE**');
	
	if (par2) 
		par2 = par2.replace(/(?:\r\n|\r|\n)/g, '**NEWLINE**');
	
	if (par3) 
		par3 = par3.replace(/(?:\r\n|\r|\n)/g, '**NEWLINE**');
	
	if (par4) 
		par4 = par4.replace(/(?:\r\n|\r|\n)/g, '**NEWLINE**');
	
	if (par5) 
		par5 = par5.replace(/(?:\r\n|\r|\n)/g, '**NEWLINE**');
	
	
	
	
	
  div_id.split(':::::').forEach(function(curr_div_id){
	  if (curr_div_id!="NONE" && curr_div_id.indexOf("NOFADE_")==-1)
		  {
		  var el=document.getElementById(curr_div_id);
		  if (!el) 
			  console.log("No such div found id : " + curr_div_id + " @ajaxDynamicComponentCaller");
		  else 
			  {
			  orig_div_contents[curr_div_id]=el.innerHTML;
			  }
 		  }
  });
  
  showHourGlass();
  
  
  
  
  if(AJAX.readyState == 1 || AJAX.readyState == 2 || AJAX.readyState == 3 ) {
	  
	  console.log("AJAX.readyState " + AJAX.readyState);
	  console.log("AJAX.status " + AJAX.status);
	  
	  console.log("queued action : "  + action);
	  console.log("div_id : " + div_id);
	  console.log("par1 : " + par1);
	  console.log("par2 : " + par2);
	  console.log("par3 : " + par3);
	  console.log("par4 : " + par4);
	  console.log("par5 : " + par5);
	  
	  
	  
	  queueForAction[queueForAction.length]=action;
	  queueForDiv[queueForDiv.length]=div_id;
	  quueueForPar1[quueueForPar1.length]=par1;
	  quueueForPar2[quueueForPar2.length]=par2;
	  quueueForPar3[quueueForPar3.length]=par3;
	  quueueForPar4[quueueForPar4.length]=par4;
	  quueueForPar5[quueueForPar5.length]=par5;
	  
	  
	  return;
  }
  
  AJAX.onreadystatechange = handler_handler;
  
  par1=encodeURIComponent(par1);
  par2=encodeURIComponent(par2);
  par3=encodeURIComponent(par3);
  par4=encodeURIComponent(par4);
  par5=encodeURIComponent(par5);

  
  
  
  
  var AJAX_URL="ajaxDynamicComponent.jsp?action=" + action + "&div=" + div_id + "&par1=" + par1 + "&par2=" + par2 + "&par3="+par3+ "&par4="+par4+ "&par5="+par5;
  var async=true;
  AJAX.open("POST", AJAX_URL , async);
  AJAX.setRequestHeader( 'content-type', 'text/html;charset=UTF-8');
  AJAX.timeout = 300000; //5 mins
  AJAX.ontimeout = function () { myalert("Ajax Timed out!!!");   restoreDivOriginalContents(); hideWaitingModal(); };
  AJAX.send("");
}

var queueForAction=[];
var queueForDiv=[];
var quueueForPar1=[];
var quueueForPar2=[];
var quueueForPar3=[];
var quueueForPar4=[];
var quueueForPar5=[];


//*************************************************************************
function runjs_code(jsscript){
//*************************************************************************
var msg1="";
 
 try {
	 ret1=eval(jsscript);
 } catch (e) {
	        msg1='<br>Error : <b><font color=red>'+e.message+'</font></b>';
	        console.log(msg1);
	        console.log("while executing javascript : ");
	        console.log(jsscript);
	}
  
};


//*************************************************************************
function handler_handler() {
//*************************************************************************
  if(AJAX.readyState == 4 && AJAX.status == 200) {
	  
	 
	  //hideBlocker();
	  clearHourGlass();
	  
	  var json =null;
	  
	  try {json=JSON.parse( AJAX.responseText ); } catch(err) {
		  json =null;
		  myalert("Json Parse Error : " +err+" (See browser's console for AJAX response.)");
		  console.log("AJAX.responseText : " +AJAX.responseText);
		  location.href="default2.jsp";
		  return;
		  }
	  
	  AJAX.responseText
	  
      var msg=json.msg;

      for (var i=1;i<1000;i++) {
    	  var div=json["div"+i];
    	  if (!div) break;
    	  
    	  var html=json["html"+i];
    	  
    	  if(html) {
              var targetdiv=document.getElementById(div);
              if (targetdiv) targetdiv.innerHTML=html;
              if (html.indexOf("javascript:")==0) runjs_code(html.substring(11));
          } else {
        	  if (div!="NONE")  document.getElementById(div).innerHTML=orig_div_contents[div];
          }
      } //for (var i=1;i<1000;i++)
      
      
      if (msg && msg.indexOf("nok:")==0) {
    	  
    	  hideWaitingModal();
    	  
    	  restoreDivOriginalContents();
    	  
    	  myalert(msg.substring(4));
      }
      else if (msg && msg.indexOf("ok:javascript:")==0) {
    	  
    	  var js_code_to_execute=msg.substring(14);
    	  runjs_code(js_code_to_execute);
    	  
      }
      else if (!msg) {
    	  myalert("Message is not transmitted to the client.");
    	  console.log("Message is not transmitted to the client.");
    	  restoreDivOriginalContents();
    	  hideWaitingModal();
    	  
      } else if (msg!="ok") {
    	  console.log("exceptional msg : " + msg);
      }
      
      
      orig_div_contents=[];
      
     
      
      performActionQueue();
      
      
      
  } else if (AJAX.readyState == 4 && AJAX.status != 200) {
	  
	  //clear qyeye on error
	  queueForAction=[];
	  queueForDiv=[];
	  quueueForPar1=[];
	  quueueForPar2=[];
	  quueueForPar3=[];
	  quueueForPar4=[];
	  quueueForPar5=[];
	  
	  
	  //hideBlocker();
	 clearHourGlass();
	 //restoreDivOriginalContents();
	 hideWaitingModal();
	 var alertcontent='Something went wrong on ajax call...(AJAX.readyState='+AJAX.readyState+', AJAX.status='+AJAX.status+')' ;
	 alertcontent=alertcontent  + 
	 	"<hr>"+
	 	"<span class=\"label label-danger\">Details of Error</span>"+
	 	"<hr>"+
	 	"<textarea style=\"width:100%; font-family: monospace; background-color:red; color:white;\" rows=10>"+AJAX.responseText+"</textarea>";
	 
	 myalert(alertcontent);
	 
	 
  }  
  
}

//***********************************************
function performActionQueue() {
//***********************************************
	
	if (queueForAction.length==0) {
		//console.log("no action waiting in queue");
		return;
	}
	
	console.log("action queue size : " + queueForAction.length);
	
	var queue_action=queueForAction[0];
	var queue_div=queueForDiv[0];
	var queue_par1=quueueForPar1[0];
	var queue_par2=quueueForPar2[0];
	var queue_par3=quueueForPar3[0];
	var queue_par4=quueueForPar4[0];
	var queue_par5=quueueForPar5[0];
	
	console.log("executing action ["+queue_action+"] from queue");
	
	ajaxDynamicComponentCaller(queue_action, queue_div, queue_par1, queue_par2, queue_par3, queue_par4, queue_par5);
	
	//delete first item
	tmpForAction=queueForAction;
	tmpForDiv=queueForDiv;
	tmpForPar1=quueueForPar1;
	tmpForPar2=quueueForPar2;
	tmpForPar3=quueueForPar3;
	tmpForPar4=quueueForPar4;
	tmpForPar5=quueueForPar5;
	
	queueForAction=[];
	queueForDiv=[];
	quueueForPar1=[];
	quueueForPar2=[];
	quueueForPar3=[];
	quueueForPar4=[];
	quueueForPar5=[];
	
	for (var i=1;i<tmpForAction.length;i++) {
		queueForAction[queueForAction.length]=tmpForAction[i];
		queueForDiv[queueForDiv.length]=tmpForDiv[i];
		quueueForPar1[quueueForPar1.length]=tmpForPar1[i];
		quueueForPar2[quueueForPar2.length]=tmpForPar2[i];
		quueueForPar3[quueueForPar3.length]=tmpForPar3[i];
		quueueForPar4[quueueForPar4.length]=tmpForPar4[i];
		quueueForPar5[quueueForPar5.length]=tmpForPar5[i];
	}
	
	


}

//***********************************************
function restoreDivOriginalContents() {
//***********************************************
	//hideBlocker();
	clearHourGlass();
	showWaitingModal();
	
	var divArr=Object.keys(orig_div_contents);
	for (var d=0;d<divArr.length;d++) {
		  var div_id=divArr[d];
		  var div_content=orig_div_contents[d];
		  if (div_id=="NONE" || div_id.indexOf("NOFADE_")==0) continue;
		  if (div_content.length==0) continue;
		  
		  var el=document.getElementById(div_id);
		  if (!el) {
			  console.log("div ["+div_id+"] not found@handler_handler");
			  continue;
		  }
		  el.innerHTML=div_content;
		  
	}

}

//******************************************************************************************************
function makeLovModal() {
	
	
	var el=document.getElementById("lovDiv");

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-md\" id=\"lovDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-md\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"			 	 <div class=\"modal-body\" id=\"lovBody\"  style=\"min-height: 0px; max-height: 480px; overflow-x: scroll; overflow-y: scroll;\"> \n" +
	"			        <div id=viewExecuteBody></div> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-success\" id=btSelectLOV onclick=\"selectLOV();\"> \n"+
	"		        		<span class=\"glyphicon glyphicon-save\"></span> Select  \n"+
	"		        	</button> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
}


//******************************************************************************************************

function showModal(modaldivid) {
	
	makeLovModal();
	
	var el=document.getElementById(modaldivid);
	if (!el) myalert("Modal not found : " + modaldivid);
	z_index_counter++;
	el.style.zIndex=""+z_index_counter;
	
	clearDivContent("lovBody");
	
	$('#'+modaldivid).modal('show');
}


//****************************************************************
function changeDatePicker(table_id, obj, id, field_mode, additional) {
	
	
	var year=0;
	var month=0;
	var day=0;
	
	var hour=-1;
	var minute=-1;
	var second=-1;
	
	try{year=parseInt(document.getElementById("datepicker_year_of_"+id).value);} catch(err) {console.log(err);}
	try{month=parseInt(document.getElementById("datepicker_month_of_"+id).value);} catch(err) {console.log(err);}
	try{day=parseInt(document.getElementById("datepicker_day_of_"+id).value);} catch(err) {console.log(err);}
	
	try{hour=parseInt(document.getElementById("datepicker_hour_of_"+id).value);} catch(err) {}
	try{minute=parseInt(document.getElementById("datepicker_minute_of_"+id).value);} catch(err) {}
	try{second=parseInt(document.getElementById("datepicker_second_of_"+id).value);} catch(err) {}
	
	var curr_date=day+"."+month+"."+year;
	if (hour>-1) 
		curr_date=curr_date+" "+hour+":"+minute+":"+second;
	
	var action="datetimepicker_validate";
	var div_id="NOFADE_datepicker_"+id;
	var par1=table_id; //request_id
	var par2=id;
	var par3=curr_date;
	var par4=field_mode;
	var par5=additional;
	
	
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	
	
}
//********************************************************
function fireOnChangeDateTime(table_id, id) {
	//-----------------------------------------
	var el=document.getElementById(id);
	if (el) {
		var fire_event=el.getAttribute("onchange");

		if (fire_event && fire_event!="undefined" && fire_event.length>0) 
			runjs_code(fire_event);
	}
	
	validateEntry(table_id, id, "TEXT", "", "YES", "YES","");
}


//*********************************************************
function setDateFormulaFieldValue(id) {
	var formula_type=document.getElementById("formula_type_"+id).value;
	var formula_count=document.getElementById("formula_period_count_"+id).value;

	if (formula_type=="") formula_count="NONE";
	if (formula_count=="") formula_count="0";
	
	var el_val=document.getElementById("formula_"+id);
	
	el_val.value=formula_type+":"+formula_count;
	
}


//*********************************************************
function setDateFormulaFieldValue(id) {
	var formula_type=document.getElementById("formula_type_"+id).value;
	var formula_count=document.getElementById("formula_period_count_"+id).value;

	if (formula_type=="") formula_count="NONE";
	if (formula_count=="") formula_count="0";
	
	var el_val=document.getElementById("formula_"+id);
	
	el_val.value=formula_type+":"+formula_count;
	
}



//*********************************************************
function setDateFormulaPeriodCountField(id) {
	var el_count=document.getElementById("formula_period_count_"+id);
	var el_type=document.getElementById("formula_type_"+id);
	
	var el_count_value=el_count.value;
	var el_count_integer=1;
	try{if (!isNaN(parseInt(el_count_value))) el_count_integer=parseInt(el_count_value);} catch(err) { el_count_integer=1; console.log(err); }
	el_count.value=el_count_integer;
	
	var formula_type=el_type.value;
	
	if (formula_type.indexOf("THIS")==0) {
		el_count.disabled=true;
		el_count.value="";
	} else {
		el_count.disabled=false;
	}
	
	setDateFormulaFieldValue(id);
}

//*************************
function setCheckboxVal(table_id, hidden_id) {
	
	var el=document.getElementById(hidden_id);
	var val_to_set=el.value;
	
	if (val_to_set=="YES") val_to_set="NO"; else val_to_set="YES";
	el.value=val_to_set;
	
	
	validateEntry(table_id, hidden_id, "TEXT", "", "YES", "NO","");
	
}


//********************************************
function myalert(msg1) {
//********************************************
	bootbox.alert(msg1);
	hideWaitingModal();
}


//**************************************************
function clearDivContent(divid) {
//**************************************************
	document.getElementById(divid).innerHTML="";
}

//**************************************************
function setDivContent(divid,content) {
//**************************************************
	document.getElementById(divid).innerHTML=content;
}






//***********************************************
function makeAttachFileToMadRequestModal() {
	 
	var el=document.getElementById("attachmentDiv");
	//if (el) $("#attachmentDiv").remove();

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-md\" id=\"attachmentDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-md\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"		 		<div class=\"modal-header\" id=attachmentHeader> \n" +
	"		 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n" +
	"		 				<span aria-hidden=\"true\">&times;</span> \n" +
	"		 				<span class=\"sr-only\">Close</span> \n" +
	"		 			</button> \n" +
	"		 			<iframe name='hiddenframe' width=\"0\" id=”results” name=\"results\" height=\"0\" border=\"0\" frameborder=\"0\" scrolling=\"auto\" align=\"center\" hspace=\"0\" vspace=\"\">  \n" +
  	"					</iframe> \n" +
  	"					 \n" +
	"		 		</div> <!--  modal header --> \n" +
	"			 	 <div class=\"modal-body\" id=\"attachmentBody\"  style=\"min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;\"> \n" +
	"			        <div id=attachmentFormDiv></div> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
}

//***********************************************
function attachMadFileToRequest(request_id,flex_field_id) {
		
	makeAttachFileToMadRequestModal();
	
	var action="add_mad_request_attachment";
	var div_id="attachmentFormDiv";
	var par1=""+request_id;
	var par2=""+flex_field_id;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("attachmentDiv");
	
}


//***********************************************
function closeAttachmentWindow(request_id, flex_field_id) {
	$("#attachmentDiv").modal("hide");
	
	 waitForAttachmentCompleted(request_id,flex_field_id);
	
}


//***********************************************
function waitForAttachmentCompleted(request_id, flex_field_id) {
	showWaitingModal();
	
	var action="wait_for_attachment_completed";
	var div_id="NONE";
	var par1=request_id;
	var par2=flex_field_id;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}

//***********************************************
function finishAttachment(is_timeout, request_id, flex_field_id, err_msg) {
	hideWaitingModal();
	
	if (is_timeout) {
		myalert("Attachment process is timeout. ");
	} else if (err_msg!="") {
		myalert(err_msg);
	}
	
	redrawAttachmentFieldContent(request_id, flex_field_id);
}

//******************************************************
function redrawAttachmentFieldContent(request_id,flex_field_id) {
	var action="redraw_attachment_field_content";
	var div_id="attachmentFieldDiv_"+request_id+"_"+flex_field_id;
	var par1=request_id;
	var par2=flex_field_id;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//***********************************************
function showMadAttchmentInfo(request_id, flex_field_id, file_name,file_size, entuser, entdate) {
	
	var confirm_info="";
	confirm_info=confirm_info+"<table class=table>";
	confirm_info=confirm_info+"<tr><td align=right> File Name : </td><td><b>"+file_name+"</b></td></tr>";
	confirm_info=confirm_info+"<tr><td align=right> File Size : </td><td><b>"+file_size+"</b></td></tr>";
	confirm_info=confirm_info+"<tr><td align=right> Attached By : </td><td><b>"+entuser+"</b></td></tr>";
	confirm_info=confirm_info+"<tr><td align=right> Attachment Date : </td><td><b>"+entdate+"</b></td></tr>";
	confirm_info=confirm_info+"<tr><td align=center colspan=2>";
	confirm_info=confirm_info+"<button data-dismiss=modal type=button class=\"btn btn-warning\" onclick=\"viewAttachment('"+request_id+"','"+flex_field_id+"');\">";
	confirm_info=confirm_info+"<span class=\"glyphicon glyphicon-download-alt\"></span> Download File";
	confirm_info=confirm_info+"</button>";
	confirm_info=confirm_info+"</td></tr>";
	confirm_info=confirm_info+"</table>";
	
	myalert(confirm_info);
	

}

//***********************************************
function deleteMadFileFromRequest(request_id, flex_field_id) {
	
	
	bootbox.confirm("Are you sure to delete this file?", function(result) {
		
		if(!result) return;

		
		var action="delete_mad_request_attachment";
		var div_id="NONE";
		var par1=""+request_id;
		var par2=""+flex_field_id;

		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		
		
	}); 

}

//***********************************************
function viewAttachment(request_id, flex_field_id) {
	
	var action="view_mad_request_attachment";
	var div_id="attachmentBody";
	var par1=""+request_id;
	var par2=""+flex_field_id;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	

}

//***********************************************
function downloadMadAttachment(id) {
//***********************************************
	var url="downloadfile.jsp?id="+id;
	window.open(url,"mywindow");
	
}




//*************************************
function mynotification(msgx) {
//*************************************
myalert(msgx);
}


//*************************************************************************
function validateDateTime(obj){
//*************************************************************************
var input=obj.value;

if (input=='') return true;

var myformat="DD/MM/YYYY HH:mm:ss";
var mydate = moment(input,myformat);
var strdate=mydate.format(myformat);

//if (!mydate.isValid()) {
if (strdate!=input) {
    myalert("invalid date => "+input+ "\n[should be formatted like "+myformat+"]");    
    obj.focus();
    obj.value=moment(Date()).format(myformat);
    mydate=null;
    return false;
}


return true;
}

//****************************************************************
function drawMonitoringAreas() {
	var action="draw_monitoring_areas";
	var div_id="MonitoringContainerDiv";
	var par1="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}


//****************************************************************
function onmonitoringload2() {
	drawMonitoringAreas();
	
	
}





var monitoringinterval=null;

//****************************************************************
function setRefreshInterval() {
	var el=document.getElementById("refresh_interval");
	if (!el) {
		console.log("refresh_interval element not found.");
		return;
	}
	var refresh_interval=el.value;
	
	
	if (refresh_interval=="manual") {
		console.log("clear Refresh timer");
		try{clearInterval(monitoringinterval);} catch(err) {}
		
	} else {
		var interval_as_sec=60*1000;
		try{interval_as_sec=parseInt(refresh_interval)*1000;} catch(err) {}
		try{clearInterval(monitoringinterval);} catch(err) {}
		monitoringinterval=setInterval(function(){makeWorkPlanList();}, interval_as_sec);
	}
	
	var action="set_refresh_interval";
	var div_id="NONE";
	var par1=refresh_interval;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//****************************************************************
function myPeriodikTask() {
	
	
	var openmodalcount=($('#monitorDiv').hasClass('in')+$('#taskDiv').hasClass('in')+$('#discDiv').hasClass('in')+$('#sqlDiv').hasClass('in'));
	
	if (openmodalcount>0) return;
	
	var active_tab="workplanTab";
	
	if (active_tab_id.toString().indexOf("processTab")>-1)  active_tab="processTab";

	if (active_tab=='processTab')  fillProcessSummary();
	
	if (active_tab=='workplanTab')  fillWorkPlanSummary();
	
	console.log("myPeriodikTask : ..." + active_tab);

	
}




//**************************************************************
function editWorkPlan(wpid) {
	
	
	var action="edit_work_plan_parameters";
	var div_id="workPlanParamsEditorBody";
	var par1=wpid;
	
	$("#workPlanParamsEditorDiv").modal("show");

	ajaxDynamicComponentCaller(action, div_id, par1);

}

//**************************************************************
function saveWorkPlanParameters() {
	
	bootbox.confirm("Are you sure to change work plan parameters?", function(result) {
		
		if(!result) return;
		
		var editing_work_plan_id=document.getElementById("editing_work_plan_id").value;
		var wp_email_address=document.getElementById("wp_email_address").value;
		var wp_execution_type=document.getElementById("wp_execution_type").value;
		var wp_on_error_action=document.getElementById("wp_on_error_action").value;
		var wp_REC_SIZE_PER_TASK=document.getElementById("wp_REC_SIZE_PER_TASK").value;
		var wp_master_limit=document.getElementById("wp_master_limit").value;
		var wp_worker_limit=document.getElementById("wp_worker_limit").value;

		var action="save_work_plan_parameters";
		var div_id="NONE";
		var par1=""+editing_work_plan_id;
		var par2=""+wp_email_address;
		var par3=""+wp_execution_type;
		var par4=""+wp_on_error_action;
		var par5=""+wp_REC_SIZE_PER_TASK+":"+wp_master_limit+":"+wp_worker_limit;
		

		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);	
		
		$("#workPlanParamsEditorDiv").modal("hide");


	}); 
}

//**************************************************************
function openWorkPlanWindow(wpid) {
	
	detailed_work_plan_id=wpid;
	
	var action="open_work_plan_window";
	var div_id="workPlanWindowBody";
	var par1=wpid;

	$("#workPlanWindowDiv").modal("show");
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	gauge=null;
}



//****************************************************************
function showProcessWindow(ptype,pstatus) {
	var action="show_process_window";
	var div_id="processListBody";
	var par1=ptype;
	var par2=pstatus;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#processListDiv").modal("show");
	
}

//***************************************************************
function refreshProcessWindow(ptype) {
	var pstatus=document.getElementById("process_status_filter").value;
	showProcessWindow(ptype,pstatus);
}

//****************************************************************
function setProcessStatus(process_type, process_id, process_action) {
	
	var confirm_msg="Manager will be stopped. Are you sure?"
		
	if (process_action=="start") confirm_msg="Manager will be started. Are you sure?"
			
	if (process_action=="restart") confirm_msg="Manager will be restarted. Are you sure?"
		
	if (process_type=="master" || process_type=="worker") 
		confirm_msg=process_type+" count will be changed. Are you sure?"
		
	bootbox.confirm(confirm_msg, function(result) {
			
			if(!result) {
				return;
			}
			
			var action="set_process_status";
			var div_id="NONE";
			var par1=process_type;
			var par2=process_id;
			var par3=process_action;

			
			ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	}); 

	
	
}

//****************************************************************
function makeWorkPlanList() {
	var refresh_interval=document.getElementById("refresh_interval").value;
	var work_plan_type_filter=document.getElementById("work_plan_type_filter").value;
	var work_plan_status_filter=document.getElementById("work_plan_status_filter").value;
	
	var action="make_work_plan_list";
	var div_id="workPlanListDiv";
	var par1=work_plan_type_filter;
	var par2=work_plan_status_filter;
	var par3=refresh_interval;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
}
//****************************************************************
function setProcessAction(process_type, process_id, process_action, process_status) {
	
	var action="set_process_action";
	var div_id="NONE";
	var par1=process_type;
	var par2=process_id;
	var par3=process_action;
	var par4=process_status;

	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}



//****************************************************************
function changeProcessLimitInList(limit_type, wpid, limitEl) {
	
	try {
		parseInt(limitEl.value);
	} catch(err) {
		limitEl.focus();
		return;
	}
	
	var action="change_work_plan_process_limit";
	var div_id="NONE";
	var par1=""+wpid;
	var par2=""+limit_type;
	var par3=""+limitEl.value;

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);	
	
}


//-----------------------------------------------------------------
function setWorkPlanStatus2(wpid, status) {
	
	confirm_msg="";
	if (status=='CANCEL') confirm_msg="Sure to stop?";
	if (status=='PAUSE') confirm_msg="Sure to pause?";
	if (status=='RESUME') confirm_msg="Sure to resume?";
	if (status=='REPLAY') confirm_msg="Sure to replay?";
	if (status=='ROLLBACK') confirm_msg="Sure to rollback?";
	if (status=='PURGE') confirm_msg="Sure to purge?";
	if (status.indexOf("REPEAT:")==0) confirm_msg="Sure to repeat this failed tasks?";


	bootbox.confirm(confirm_msg, function(result) {
		
		if(!result) return;
		
		
		var action="set_work_plan_status:::::open_work_plan_window";
		var div_id="NONE:::::workPlanWindowBody";
		var par1=wpid+":::::"+wpid;
		var par2=status+":::::x";

		ajaxDynamicComponentCaller(action, div_id, par1, par2);	


	}); 

	
	
}


//********************************************************************
function showWorkPackageList(work_plan_id,det_status) {
	var action="get_work_package_list_by_status";
	var div_id="workPackageListBody";
	var par1=work_plan_id;
	var par2=det_status;

	$("#workPackageListDiv").modal("show");
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}

//********************************************************************
function showTaskList(work_plan_id,task_status,only_failed) {
	var action="get_wp_detail_list";
	var div_id="taskListBody";
	var par1=work_plan_id;
	var par2="TDM_TASK";
	var par3=task_status;
	var par4=only_failed;
	var par5="ALL";
	
	$("#taskListDiv").modal("show");
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
}

//***********************************************************************
function showInfoDetail(rec_id, rec_type, field) {
	var action="get_long_detail";
	var div_id="div_task_info";
	var par1=detailed_work_plan_id;
	var par2=rec_type;
	var par3=rec_id;
	var par4=field;
	
	

	$("#taskDiv").modal("show");
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}



//***********************************************************************
function showWorkPlanScriptLog(work_plan_id, field) {
	var action="show_work_plan_script_log";
	var div_id="div_task_info";
	var par1=work_plan_id;
	var par2=field;

	$("#taskDiv").modal("show");

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}



//************************************************************************
function showInvalidMsg(wpid) {
	
	var action="show_invalid_msg";
	var div_id="NONE";
	var par1=wpid;

	ajaxDynamicComponentCaller(action, div_id, par1);

	
}

//************************************************************************
function showWarningMsg(wpid) {
	
	var action="show_warning_msg";
	var div_id="NONE";
	var par1=wpid;

	ajaxDynamicComponentCaller(action, div_id, par1);

	
}


//************************************************************************
function skipValidation(wpid) {
	
	
	
	bootbox.confirm("Are you sure to skip invalid status?", function(result) {
		
		if(!result) return;

		var action="skip_validation";
		var div_id="NONE";
		var par1=wpid;

		ajaxDynamicComponentCaller(action, div_id, par1);

	});
	
	


	
}


//*************************************************************************
function testRegex(str_to_test, regex) {
	
	if (regex.length==0) return true;
	try {
		var re = new RegExp(regex);
		if (str_to_test.match(re)) return true;
	} catch(err) {return false;}
	
	
	return false;
}

//****************************************
function removePipes(instr) {
	var ret1=instr;
	while(true) {
		ret1=ret1.replace( new RegExp("\\|") , "::PIPE::");
		if (ret1.indexOf("|")==-1) break;
	}
	
	return ret1;
}



//*************************************
function printabout() {
	
	var action="print_about";
	var div_id="aboutDiv";
	var par1="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1);

}

var mad_warning_interval=null;



var mad_lock_request_sending_interval=null;

//**********************************
function onLoadDeploymentList() {
	var action="load_deployment_header:::::load_request_list:::::load_mad_queries";
	var div_id="headerofDeploymentsDiv:::::listofRequestsDiv:::::NOFADE_queryListDiv";
	var par1="x:::::FILTER:::::x";
	var par2="x:::::x:::::x";
	var par3="x:::::NO:::::x";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
	mad_warning_interval=setInterval(function () {getMADWarning();}, 60000);
	
	window.setTimeout(function(){getMADWarning();}, 1000);
	
	mad_lock_request_sending_interval=setInterval(function () {sendLockRequests();}, 15000);
	
	
}


//**********************************
function setNumericFielValues(obj,part) {
	
	var id=obj.id;
	
	id=id.substring(0,id.length-part.length-1);
	
	var el=document.getElementById(id);
	var el_fixed=document.getElementById(id+"_fixed");
	var el_decimal=document.getElementById(id+"_decimal");
	
	var old_val=el.value;
	
	var fixed_part="0";
	var decimal_part="0";
	
	fixed_part=el_fixed.value;
	try{decimal_part=el_decimal.value;} catch(err) {}
	
	if (fixed_part=="") fixed_part="0";
	if (decimal_part=="") decimal_part="0";
	
	
	var new_val=fixed_part+"."+decimal_part;
	
	var min_val=0.0;
	var max_val=0.0;
	
	max_val+=Number.MAX_VALUE;
	
	try{min_val=parseFloat(el.getAttribute("min_val"));} catch(err) {}
	try{max_val=parseFloat(el.getAttribute("max_val"));} catch(err) {}

	var new_val_float=0.0;
	
	try{new_val_float=parseFloat(new_val);} catch(err) {}
	
	var in_limit=true;
	if (new_val_float<min_val) {
		in_limit=false;
		new_val_float=min_val;
	}
	if (new_val_float>max_val) {
		in_limit=false;
		new_val_float=max_val;
	}
	
	
	
	el.value=""+new_val_float;
	
	if (!in_limit) {
		var x=el.value;
		
		var out_limit_fixed=0;
		var out_limit_decimal=0;
		
		try{out_limit_fixed=parseInt(x.split(".")[0]);} catch(err) {}
		try{out_limit_decimal=parseInt(x.split(".")[1]);} catch(err) {}
		
		
		el_fixed.value=""+out_limit_fixed;
		try{el_decimal.value=""+out_limit_decimal;} catch(err) {}
	}
	
	//check if changed
	//and execute event if so
	if (el_fixed.value!=old_val) {
		var fire_event=el.getAttribute("onchange");
		if (fire_event && fire_event!="undefined" && fire_event.length>0) 
			el.onchange();
		
	}
	

}

//**********************************
function groupNumber(x,grouping_char,part) {
	var ret1= "";

	var numerics="0123456789";
	var p=0;
	for (var i=x.length-1;i>=0;i--) {
		
		var chr=x.charAt(i);
		if (numerics.indexOf(chr)==-1) continue;
		p++;
		ret1=chr+ret1;
		if (part=="fixed" && (p>1) && (p % 3==0) && (i!=0)) ret1=grouping_char+ret1;
	}
    if (ret1=="") ret1="0";
	return ret1;
}

//**********************************
function numericFieldGroup(obj,part) {
	var grouping_char="";
	var field_length="";
	try{grouping_char=obj.getAttribute("grouping");} catch(err) {}
	try{field_length=obj.getAttribute("maxlength");} catch(err) {}
	
	if (part=="fixed") 
		return groupNumber(obj.value,grouping_char,part);
	
	var decimal_length=0;
	try{decimal_length=parseInt(field_length);} catch(err) { console.log(err); }
	
	if (decimal_length>0) {
		var x=obj.value+"000000000000";
		return x.substring(0, decimal_length);
	}
}
//**********************************
function numericFieldUngroup(obj) {
	
	var numerics="0123456789";
	var curr_val=obj.value;
	var ret1="";

	for (var i=0;i<curr_val.length;i++) {
		
		var chr=curr_val.charAt(i);
		if (numerics.indexOf(chr)==-1) continue;
		ret1=ret1+chr;
	}
    if (ret1=="") ret1="0";
    
	return ret1;
	
}

//**********************************
function onNumericFieldEnter(obj,part) {
	if (part=="fixed") obj.value=numericFieldUngroup(obj);
}

//**********************************
function onNumericFieldExit(obj,part) {

	setNumericFielValues(obj,part);
	
	obj.value=numericFieldGroup(obj,part);
	
}


//**********************************

function loadMadQueries() {
	var action="load_mad_queries";
	var div_id="NOFADE_queryListDiv";
	var par1="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}



//**********************************
function makeCongifQueryModal() {
	 
	var el=document.getElementById("queryEditorDiv");
	//if (el) $("#queryEditorDiv").remove();
	
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		 <div class=\"modal fade bs-example-modal-md\" id=\"queryEditorDiv\" data-keyboard=\"false\" data-backdrop=\"static\" style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-md\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"			 	 <div class=\"modal-body\" id=\"queryEditorBody\"  style=\"min-height: 0px; max-height: 400px; overflow-x: scroll; overflow-y: scroll;\"> \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		        	<button type=\"button\" class=\"btn btn-warning\" id=btEditMadQuery onclick=\"editMadQuery();\"> \n"+
	"		        		<span class=\"glyphicon glyphicon-remove\"> Edit Query </span> \n"+
	"		        	</button> \n"+
	"		        	<button type=\"button\" class=\"btn btn-danger\" id=btDeleteMadQuery onclick=\"removeMadQuery();\"> \n"+
	"		        		<span class=\"glyphicon glyphicon-remove\"> Remove </span> \n"+
	"		        	</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content --> \n"+
	"		</div> <!--  modal dialog -->  \n"+
	"	</div> <!--  modal fade -->"; 

	$('body').append(modal_html);
	
	
}

//**********************************
function configMadQuery(query_id) {
	makeCongifQueryModal();
	
	var action="edit_mad_private_filter";
	var div_id="queryEditorBody";
	var par1=""+query_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("queryEditorDiv");
}

//**********************************

function editMadQuery() {
	
	var query_id=document.getElementById("editing_query_id").value;


	
	
	var elch=document.getElementById("query_ch_"+query_id);
	if (elch) elch.checked=true;
	
	var action="show_mad_search_box";
	var div_id="NOFADE_madSearchBody";
	var par1="FILTER";
	var par2=query_id;
	var par3="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	$("#queryEditorDiv").modal("hide");
	makeSearchBoxModal("x");
	showModal("madSearchDiv");
}



//**********************************

function renameMadQueryName() {
	
	
	var query_id=document.getElementById("editing_query_id").value;
	var query_name=document.getElementById("editing_query_name").value;
	
	if (query_name=="") {
		myalert("Query name cannot be empty");
		return;
	}
	
	var action="rename_mad_private_filter";
	var div_id="NONE";
	var par1=""+query_id;
	var par2=""+query_name;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("queryEditorDiv");
}

//**********************************
function removeMadQuery() {
	var query_id=document.getElementById("editing_query_id").value;
	
	
	bootbox.confirm("Are you sure to remove this query ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="remove_mad_private_filter";
		var div_id="NONE";
		var par1=""+query_id;
		
		ajaxDynamicComponentCaller(action, div_id, par1);
		
		$("#queryEditorDiv").modal("hide");
		
	});
	
}





//**********************************
function setMadWaitingActionQuery() {


	var action="unset_mad_all_queries:::::set_mad_waiting_action_query:::::load_mad_queries:::::load_request_list";
	var div_id="NONE:::::NONE:::::NOFADE_queryListDiv:::::listofRequestsDiv";
	var par1="x:::::x:::::x:::::FILTER";
	var par2="x:::::x:::::x:::::x";
	var par3="x:::::x:::::x:::::NO";

	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}




//**********************************
function setMadQuery(obj,query_id) {
	
	var state="UNSET";
	if (obj.checked) state="SET";
	
	var clicking_query_type=document.getElementById("query_ch_"+query_id).value;
	
	if (state=="SET" && clicking_query_type=="USER") {
		for (var i=0;i<1000;i++) {
			var el=document.getElementById("query_id_of_"+i);
			if (!el) continue;

			var el_query_id=el.value;
			var query_type=document.getElementById("query_ch_"+el_query_id).value;
			if (el_query_id==query_id || query_type=="SYSTEM") continue;
			
			document.getElementById("query_ch_"+el_query_id).checked=false;
			
			
		}
	}
	
	if (clicking_query_type=="USER") {
		var action="unset_mad_user_queries:::::set_mad_query";
		var div_id="NONE:::::NONE";
		var par1="x:::::"+query_id;
		var par2="x:::::"+state;

		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
	}
	else {
		var action="set_mad_query";
		var div_id="NONE";
		var par1=""+query_id;
		var par2=""+state;

		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
	}
	
}

//**********************************
function getMADWarning() {
	
	var el=document.getElementById("btwaitingaction");
	if (el) {
		el.disabled=true;
		el.text="Loading....";
	}
	
	var action="get_MAD_Warnings";
	var div_id="NOFADE_MADalertDiv";
	var par1="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}
//**********************************
function disableMadRequestButton(request_id) {
	
	try{document.getElementById("btPlaceRequestBtn_"+request_id).disabled=true;} catch(err) {}
	try{document.getElementById("btRouteRequest_"+request_id).disabled=true;} catch(err) {}
	
}

//**********************************
function enableMadRequestButton(request_id) {
	try{document.getElementById("btPlaceRequestBtn_"+request_id).disabled=false;} catch(err) {}
	try{document.getElementById("btRouteRequest_"+request_id).disabled=false;} catch(err) {}

}

//**********************************
function disableMadRequestSaveButton(request_id) {
	
	try{document.getElementById("btPlaceRequestBtn_"+request_id).disabled=true;} catch(err) {}
	
}



//**********************************
function makSelectRequestTypeModal() {
	 
	var el=document.getElementById("requestTypeDiv");
	//if (el) $("#requestTypeDiv").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	

	
	
	var modal_html=	""+
	"		 <div class=\"modal fade bs-example-modal-md\" id=\"requestTypeDiv\" data-keyboard=\"false\" data-backdrop=\"static\" style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-md\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"			 	 <div class=\"modal-body\" id=\"requestTypeBody\" > \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content --> \n"+
	"		</div> <!--  modal dialog -->  \n"+
	"	</div> <!--  modal fade -->"; 

	$('body').append(modal_html);
	
	
}

//**********************************
function addNewMadRequest(request_group) {
	
	
	
	makSelectRequestTypeModal();
	showModal("requestTypeDiv");
	
	var action="make_request_type_picker";
	var div_id="requestTypeBody";
	var par1=request_group;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}




//**********************************
function createMadRequestDo(request_type_id,request_group) {

	$("#requestTypeDiv").modal("hide");

	var action="create_new_request";
	var div_id="NONE";
	var par1=request_type_id;
	var par2=request_group;
	var par3="0";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**********************************
function addNewMadSubRequest(main_request_id,request_type_id) {
	
	var action="create_new_request";
	var div_id="NONE";
	var par1=request_type_id;
	var par2="REQUEST";
	var par3=main_request_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**********************************
function removeMadSubRequest(main_request_id, sub_request_id, tab_request_type_id) {
	var action="remove_sub_request";
	var div_id="NONE";
	var par1=main_request_id;
	var par2=sub_request_id;
	var par3=tab_request_type_id;
	
	
	bootbox.confirm("Are you sure to remove?", function(result) {
		
		if(!result)  return;
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

	}); 
	
	
}


//**********************************
function reloadRequestTableContent(main_request_id, tab_request_type_id) {
	var action="make_request_table_content";
	var div_id="table_content_of_"+main_request_id+"_"+tab_request_type_id;
	var par1=main_request_id;
	var par2=tab_request_type_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}



//**********************************
function makeRequestModal(request_id) {
	 
	hideWaitingModal();
	
	
	var modal_id="request_"+request_id;
	
	
	var el=document.getElementById(modal_id+"Div");
	if (el) {
		z_index_counter++;
		el.style.zIndex = z_index_counter;
		return;
	}
	
	var modal_html=	"<div class=\"modal fade bs-example-modal-lg\" id=\""+modal_id+"Div\" data-keyboard=\"false\" data-backdrop=\"static\" style=\"z-index: "+(++z_index_counter)+"; \"> " + 
	"<div class=\"modal-dialog modal-lg\"> " + 
	" 	<div class=\"modal-content\"> " + 
	" 	 " + 
	" 		<div class=\"modal-header\" id=\""+modal_id+"Header\"   style=\"background-color:#428bca;\"> " + 
//	" 			<button type=\"button\" class=\"close\" onclick=closeRequestModal('"+request_id+"')> " + 
//	" 				<span aria-hidden=\"true\">&times;</span> " + 
//	" 				<span class=\"sr-only\">Close</span> " + 
//	" 			</button> " + 
	"    		<div class=\"modal-title\" id=\""+modal_id+"Title\"> " + 
	"    			div title " + 
	"    		</div> " + 
	" 		</div>  " + 
	" 		 " + 
	"	 	 <div class=\"modal-body\" id=\""+modal_id+"Body\"  style=\"min-height: 0px; max-height: 495px; overflow-x: scroll; overflow-y: scroll;\"> " + 
	"	        <p>One fine body&hellip;</p> " + 
	"      	</div> <!--  modal body --> " + 
	"      	 " + 
	"      	<div class=\"modal-footer\" id=\""+modal_id+"Footer\"> " + 
	"	      	</div> " + 
	"      	 " + 
	"	 	</div> <!--  modal content -->	  " + 		
	"	</div> <!--  modal dialog --> " + 
	"</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
}

var lockRequestIdArr=[];

//**********************************
function sendLockRequests() {
	
	console.log("sendLockRequests : " + sendLockRequests.length);
	
	if (lockRequestIdArr.length==0) return;
	
	var locking_request_ids="";
	
	for (var i=0;i<lockRequestIdArr.length;i++) {
		if (i>0) locking_request_ids=locking_request_ids+",";
		locking_request_ids=locking_request_ids+lockRequestIdArr[i];
	}

	var action="send_lock_requests";
	var div_id="NONE";
	var par1=locking_request_ids;
	
	

	ajaxDynamicComponentCaller(action, div_id, par1);

}

//**********************************
function addRemoveLockingRequestArr(addremove,request_id) {
	
	if (!request_id || request_id=="0" || request_id=="undefined") return;
	
	if (addremove=="ADD") {
		var is_already_added=false;
		for (var i=0;i<lockRequestIdArr.length;i++) 
			if (lockRequestIdArr[i]==request_id) {
				is_already_added=true;
				break;
			}
		
		if (!is_already_added) {
			lockRequestIdArr[lockRequestIdArr.length]=request_id;
			
			var action="send_lock_requests";
			var div_id="NONE";
			var par1=request_id;

			ajaxDynamicComponentCaller(action, div_id, par1);
		}
			
		
	} else {
		var lockRequestIdArrTEMP=[];
		for (var i=0;i<lockRequestIdArr.length;i++) {
			if (lockRequestIdArr[i]!=request_id) 
				lockRequestIdArrTEMP[lockRequestIdArrTEMP.length]=request_id;
		}
		lockRequestIdArr=lockRequestIdArrTEMP;
		
		var action="remove_lock";
		var div_id="NONE";
		var par1=request_id;

		ajaxDynamicComponentCaller(action, div_id, par1);
	}

}

//**********************************
function showRootSuccessAndReopenRequest(routing_request_id,request_group, main_request_id) {
	
	
	
	myalert("The reqeust <span class=badge>"+ routing_request_id +"</span> is successfully routed.");
	openRequest(routing_request_id,request_group,main_request_id);
}


//*********************************
function closeRequestModal(request_id) {
	
	var modal_id="request_"+request_id+"Div";
	
	
	var is_saved="YES";
	
	var elsaved=document.getElementById("is_saved_of_"+request_id);
	
	if (elsaved) is_saved=elsaved.value;
	
	if (is_saved=="YES") {
		$("#"+modal_id).modal("hide");
		addRemoveLockingRequestArr('REMOVE',request_id);
	}
	else 
	bootbox.confirm("Form is not saved. Do you want to close request?", function(result) {
		if(!result)  return;
		$("#"+modal_id).modal("hide");
		addRemoveLockingRequestArr('REMOVE',request_id);
		}); 
	
	
	
}

//**********************************
function openRequest(opening_request_id,request_group, main_request_id) {
	
	makeRequestModal(opening_request_id);
	
	setRequestModalHeader(request_group, opening_request_id);
	
	showModal("request_"+opening_request_id+"Div");

	addRemoveLockingRequestArr('ADD',opening_request_id);
	addRemoveLockingRequestArr('ADD',main_request_id);
	

	fillRequestContent(opening_request_id,request_group);
	
	

}

//**********************************
function fillRequestContent(opening_request_id,request_group) {
	
	var modal_body_div_id="request_"+opening_request_id+"Body"; 
	var action="open_mad_request";
	var div_id=modal_body_div_id;
	var par1=opening_request_id;
	var par2=request_group;
	
	clearDivContent(modal_body_div_id);
	
	showWaitingModal();
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**********************************
function setRequestModalHeader(request_group, request_id) {

	var header_div="";
	var header_content="";

	header_div="request_"+request_id+"Title";
	header_content=
			"<table border=0 cellspacing=0 cellpadding=0>"+
			"<tr>"+
			"<td width=\"100%\">"+
			"<font color=white><img width=20 height=20 src=\"img/mad/"+request_group+".png\"> "+request_group+" : [<b>" + request_id + "</b>]</font>"+
			"</td>"+
			"<td>"+
			" <button class=\"btn btn-success btn-sm\" onclick=\"fillRequestContent('"+request_id+"','"+request_group+"');\" >"+
			"<span class=\"glyphicon glyphicon-refresh\"></span>"+
			"</button> "+
			"</td>"+
			"<td>"+
			" <button class=\"btn btn-danger btn-sm\" onclick=\"closeRequestModal('"+request_id+"');\" >"+
			"<span class=\"glyphicon glyphicon-remove\"></span>"+
			"</button> "+
			"</td>"+
			"</tr>"+
			"</table>";
			
	setDivContent(header_div,header_content);
}



//**********************************
function removeRequest(request_id) {


	bootbox.confirm("Are you sure to remove this request?", function(result) {

	if(!result)  return;
	
	var action="remove_request:::::load_request_list";
	var div_id="NONE:::::listofRequestsDiv";
	var par1=request_id+":::::FILTER";
	var par2="x:::::NO";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);

	}); 
	
}



//**********************************
function makeEntryList(request_id) {
	var el=document.getElementById("request_type_"+request_id);
	if (!el) return;
	
	var request_type_id=el.value;
	
	
	var action="make_entry_list:::::set_request_footer";
	var div_id="entryListDiv_"+request_id+":::::request_"+request_id+"Footer";
	var par1=""+request_type_id+":::::"+request_type_id;
	var par2=""+request_id+":::::"+request_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	disableMadRequestButton(request_id);
	
	
	
	
}

//********************************
function validateAllRequestFlexFields(request_id) {
	
	
	disableMadRequestButton(request_id);
	
	var prefix="entry";
	for (var i=0;i<100;i++) {
		var field_object_id=prefix+"_TAB"+request_id+"_flex_field_id_"+i;
		
		var el=document.getElementById("id_of_"+field_object_id);
		if (!el) break;
		var entryel=document.getElementById(field_object_id);
		if (!entryel) break;
		
		var entered_val=entryel.value;
		
		var entry_type=document.getElementById("entry_type_of_"+field_object_id).value;
		var regex=document.getElementById("regex_of_"+field_object_id).value;
		var is_validated=document.getElementById("is_validated_of_"+field_object_id).value;
		var is_mandatory=document.getElementById("is_mandatory_of_"+field_object_id).value;
	
		var warning_box=document.getElementById("warning_box_"+field_object_id);
		try{warning_box.innerHTML="";} catch(err) {console.log("warning box not found.");}
		
		var validation_msg=getFlexFieldValidationMsg(entry_type, regex, is_validated, is_mandatory, entered_val);
		
		if (validation_msg.length>0) {
			try{warning_box.innerHTML="<font color=red>"+validation_msg+"</font>";} catch(err) {}
			disableMadRequestButton(request_id);
			try{entry_field.focus();} catch(err) {}
			return;
		}
		
		
	}
	
	enableMadRequestButton(request_id);
}

//********************************
function validateEntry(request_id, field_object_id, entry_type, regex, is_validated, is_mandatory, fire_event) {
	//table_id : request_id
	var entry_field=document.getElementById(field_object_id);
	if(!entry_field) {
		console.log("no such object found : "  + field_object_id);
		return;
	}
	var entered_val=entry_field.value;
	
	//console.log("Validating ... request :"+request_id+", field_object_id: "+field_object_id);

	
	var warning_box=document.getElementById("warning_box_"+field_object_id);
	
	
	var is_warningbox=true;
	
	
	try{warning_box.innerHTML="";} catch(err) {console.log("warning box not found."); is_warningbox=false;}
	
	enableMadRequestButton(request_id);
	
	var validation_msg=getFlexFieldValidationMsg(entry_type, regex, is_validated, is_mandatory,entered_val);
	
	if (validation_msg.length>0) {
		
		if (is_warningbox) 
			try{warning_box.innerHTML="<font color=red>Invalid Entry!</font>";} catch(err) {console.log("warning box not found.");}
		else 
			alert("Invalid Entry!");
		
		if(request_id!="0") disableMadRequestButton(request_id);
		try{entry_field.focus();} catch(err) {}
		return;
	} 
	
	
	if (fire_event!="") {
		
		
		var jscode=fire_event;
		jscode=jscode.replace("#","'"+entered_val.replace(/'/g, "\\'")+"'");
		try {
			runjs_code(jscode);
		} catch(err) {
			console.log("Error on validateEntry : " + err);
			console.log(jscode);
		}
	}
	
	
	redrawDependedFields(request_id,field_object_id);
	
	
}

//*************************************************
function getFlexFieldValidationMsg(entry_type, regex, is_validated, is_mandatory, entered_val) {
	if (entry_type=="TEXT") {
		var regex_stmt=regex;
		if (regex_stmt.length>0) {
			if (!testRegex(entered_val,regex_stmt)) 
				return "Invalid Entry!";
		}
	}
	
	if (is_mandatory=="YES" && entered_val=="") 
		return "Can't be empty!";
	
	return "";
}

//*************************************************
function redrawDependedFields(request_id, depended_field_object_id) {
	
	var depended_field_flex_field=document.getElementById("id_of_"+depended_field_object_id)
	
	if (!depended_field_flex_field) {
		console.log("redrawDependedFields:depended field element no found with id: "+depended_field_object_id);
		return;
	}
	
	var depended_field_flex_field_id=depended_field_flex_field.value;
	
	for (var i=0;i<1000;i++) {
		var field_object_path="entry_TAB"+request_id+"_flex_field_id_"+i;
		var field=document.getElementById("id_of_"+field_object_path);
		
		if (!field) break;
		
		var flex_field_id=field.value;
		
		var el_dependency_list=document.getElementById("dependency_of_"+field_object_path);
		
		if (!el_dependency_list) {
			console.log("redrawDependedFields:dependency list not found for : "+field_object_path);
			continue;
		}
		
		var dependency_list=el_dependency_list.value;
		
		if (dependency_list=="") continue;
		
		
		
		var str_array = dependency_list.split(',');

		var is_depended=false;
		
		for(var a = 0; a < str_array.length; a++) {
			console.log("Checking : "+str_array[a]+" to "+depended_field_flex_field_id);
			
			if (str_array[a]==depended_field_flex_field_id) {
				console.log("matched");
				is_depended=true;
				break;
			}
		}
			
		
		if (is_depended) {
			console.log("Dependency found ["+dependency_list+"] betweeen "+depended_field_flex_field_id+" and "+field_object_path);
			remakeCalculatedField(request_id,flex_field_id,i);
		}
			
		
		
	}
}
//************************************************
function getFieldValuesById(request_id, flex_field_id_list) {
	
	
	var str_array = flex_field_id_list.split(',');
	
	var ret1="";
	
	for (var i=0;i<1000;i++) {
		var field_object_path="entry_TAB"+request_id+"_flex_field_id_"+i;
		var field=document.getElementById("id_of_"+field_object_path);
		
		if (!field) break;
		
		var flex_field_id=field.value;
		
		var is_matched=false;
		
		for(var a = 0; a < str_array.length; a++) 
			if (str_array[a]==flex_field_id) {
				is_matched=true;
				break;
			}
			
		
		if (is_matched) {
			var parameter_name=document.getElementById("parameter_name_of_"+field_object_path).value;
			var field_value=document.getElementById(field_object_path).value;
			if (ret1!="") ret1=ret1+",";
			ret1=ret1+parameter_name+"="+encrypt(field_value);
		}
		
		
		
		
	}
	
	return ret1;
}
//************************************************
function remakeCalculatedField(request_id, flex_field_id, field_index) {
	var field_object_path="entry_TAB"+request_id+"_flex_field_id_"+field_index;
	
	var depended_list=document.getElementById("dependency_of_"+field_object_path).value;
	var depended_field_values=getFieldValuesById(request_id,depended_list);
	
	
	
	var action="remake_calculated_field";
	var div_id="CALCDIV_for_"+field_object_path;
	var par1=""+request_id;
	var par2=""+flex_field_id;
	var par3=""+field_index;
	var par4=depended_field_values;


	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	
}
//************************************************
function validateRequestFields(request_id,request_type, request_desc, validate_for) {

	
	if (request_type.length==0) {
		disableMadRequestButton(request_id);
		myalert("Should enter a request type");
		return false;
	}
	
	
	if (request_desc.length==0) {
		disableMadRequestButton(request_id);
		myalert("Should enter a description");
		return false;
	}


	if (validate_for=="SAVE")  //SAVE or ROUTE
		disableMadRequestSaveButton(request_id);
	



	
	var prefix="entry_TAB"+request_id;
	
	for (var i=0;i<1000;i++) {
		var el=document.getElementById("id_of_"+prefix+"_flex_field_id_"+i);
		if (!el) break;
		var flex_field_id=el.value;
		var flex_field_type=document.getElementById("entry_type_of_"+prefix+"_flex_field_id_"+i).value;
		if (flex_field_type=="TABLE") continue;
		var flex_field_is_mandatory=document.getElementById("is_mandatory_of_"+prefix+"_flex_field_id_"+i).value;
		
		var flex_field_value=document.getElementById(prefix+"_flex_field_id_"+i).value;
		
		if (flex_field_is_mandatory=="YES" && flex_field_value=="") {
			disableMadRequestButton(request_id);
			//myalert("Mandatory fields should be entered.");
			validateAllRequestFlexFields(request_id)
			return false;
		}

	}
	
	return true;
	
}

//*************************************************
function placeRequest(request_id) {
	
	var request_type=document.getElementById("request_type_"+request_id).value;
	var request_desc=document.getElementById("deployment_description_"+request_id).value;
	
	var is_form_ok= validateRequestFields(request_id, request_type,request_desc,"SAVE");
	
	if (!is_form_ok) return;

	

	var action="save_mad_request";
	var div_id="NONE";
	var par1=request_id;
	var par2=request_type;
	var par3=request_desc;
	
	var prefix="entry_TAB"+request_id;
	
	for (var i=0;i<1000;i++) {
		var el=document.getElementById("id_of_"+prefix+"_flex_field_id_"+i);
		if (!el) break;
		var flex_field_id=el.value;
		var flex_field_type=document.getElementById("entry_type_of_"+prefix+"_flex_field_id_"+i).value;
		if (flex_field_type=="TABLE") continue;
		var flex_field_is_mandatory=document.getElementById("is_mandatory_of_"+prefix+"_flex_field_id_"+i).value;
		
		var flex_field_old_value=document.getElementById("old_value_of_"+prefix+"_flex_field_id_"+i).value;
		
		var flex_field_value=document.getElementById(prefix+"_flex_field_id_"+i).value;
		
		if (flex_field_value==flex_field_old_value) {
			console.log(prefix + "is being skipped...");
			continue;
		}
		
		action=action+":::::set_flex_field";
		div_id=div_id+":::::NONE";
		par1=par1+":::::"+request_id;
		par2=par2+":::::"+flex_field_id;
		par3=par3+":::::"+flex_field_value;
	
		
	}
	
	var main_request_id=document.getElementById("main_request_id_of_"+request_id).value;
	
	if(main_request_id=="0") {
		action=action+":::::load_request_list";
		div_id=div_id+":::::listofRequestsDiv";
		par1=par1+":::::FILTER";
		par2=par2+":::::x";
		par3=par3+":::::NO";
		
	} else {
		var tab_div_id="table_content_of_"+main_request_id+"_"+request_type;
		
		action=action+":::::make_request_table_content";
		div_id=div_id+":::::"+tab_div_id;
		par1=par1+":::::"+main_request_id;
		par2=par2+":::::"+request_type;
		par3=par3+":::::x";
		
		$("#request_"+request_id+"Div").modal("hide");
		
		
	}
	
	
	
	action=action+":::::show_saved_successfully_notification";
	div_id=div_id+":::::NONE";
	par1=par1+":::::"+request_id;
	par2=par2+":::::x";
	par3=par3+":::::x";
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}


//*************************************************
function setOldValuesAfterSave(request_id) {
	
	var prefix="entry_TAB"+request_id;
	
	for (var i=0;i<1000;i++) {
		var el=document.getElementById("id_of_"+prefix+"_flex_field_id_"+i);
		if (!el) break;

		var elold=document.getElementById("old_value_of_"+prefix+"_flex_field_id_"+i);
		var elnew=document.getElementById(prefix+"_flex_field_id_"+i);
			
		var flex_field_old_value=elold.value;
		
		var flex_field_value=elnew.value;
		
		if (flex_field_value!=flex_field_old_value) 
			elold.value=elnew.value;
		
	}
}

//*************************************************
function showMadSaveNotification(request_id) {
	$('#btPlaceRequestBtn_'+request_id).popover('show');
	
	setOldValuesAfterSave(request_id);
	
	var elsaved=document.getElementById("is_saved_of_"+request_id);
	
	if (elsaved) {
		if (elsaved.value=="NO") elsaved.value="YES";
	}
	
	//reloadRequestList(false);
	

}
//**************************************************
function setPicklistButtons(listtype,id) {

	var el_source_list=document.getElementById("source_list_"+id);
	var el_target_list=document.getElementById("target_list_"+id);
	var btn_add_one=document.getElementById("bt_add_one_"+id);
	var btn_remove_one=document.getElementById("bt_remove_one_"+id);
	
	var selindex=-1;
	
	if (listtype=="SOURCE") {
		selindex=el_source_list.selectedIndex;
	}
	else {
		selindex=el_target_list.selectedIndex;
	}

	if (selindex==-1) {
		if (listtype=="SOURCE") btn_add_one.disabled=true;
		else  btn_remove_one.disabled=true;
	}
	else {
		if (listtype=="SOURCE") btn_add_one.disabled=false;
		else  btn_remove_one.disabled=false;
	}
	
	if (el_source_list.options.length==0) 
		document.getElementById("bt_add_all_"+id).disabled=true;
	else 
		document.getElementById("bt_add_all_"+id).disabled=false;
	
	if (el_target_list.options.length==0) 
		document.getElementById("bt_remove_all_"+id).disabled=true;
	else 
		document.getElementById("bt_remove_all_"+id).disabled=false;
	
}



//***********************************************
function pickListAction(table_id, id,act) {
	var single_action="ADD";
	var el_from_list=document.getElementById("source_list_"+id);
	var el_to_list=document.getElementById("target_list_"+id);
	if (act.indexOf("REMOVE")==0) {
		el_from_list=document.getElementById("target_list_"+id);
		el_to_list=document.getElementById("source_list_"+id);
		single_action="REMOVE";
	}
	
	if (el_from_list.selectedIndex==-1 && act.indexOf("ALL")==-1) {
		myalert("Pick an item to move");
		return;
	}
	
	var start_i=0;
	var end_i=0;
	
	if (act.indexOf("ALL")>-1) {
		start_i=0;
		end_i=el_from_list.options.length;
	}
	else {
		start_i=el_from_list.selectedIndex;
		end_i=start_i+1;
	}
	
	for (var i=end_i-1;i>=start_i;i--) {
		
		var from_selected_index=i;

		var AddOpt = el_from_list.options[from_selected_index];
		var from_val=AddOpt.value;
		
		var to_index=el_to_list.options.length;
		el_to_list.options[to_index] = new Option( AddOpt.text, AddOpt.value, false, false);
		
		
		try {el_from_list.remove(from_selected_index, null); } catch(err) { el_from_list.remove(from_selected_index); }

		
		var jsscript="";
		try{
			var eljs=document.getElementById("event_listener_for_"+id);
			
			if (eljs) {
				jsscript=eljs.value;

				
				jsscript=jsscript.replace("#", single_action+":"+from_val);
			}
			if (jsscript!="") {
				console.log("Executing..  : " + jsscript);
				runjs_code(jsscript);
				
			}
			
			
		} catch(err) {
			console.log("Event listener not executed  : " + jsscript);
			console.log("Error : " + err.message);
		}
		
	} //for (var i=start_i;i<end_i;i++)
	
	setPicklistHiddenField(id);
	
	setPicklistButtons("SOURCE",id);
	setPicklistButtons("TARGET",id);
	
	try{
		validateEntry(table_id, id, "TEXT", "", "YES", "YES","");
		} 
	catch(err) 
		{ console.log("err@validateEntry@pickListAction"); }
	
	
}

//**********************************************
function makeApplicationRepoConfig(request_id) {
	
	var action="make_application_repo_config";
	var div_id="applicationRepoConfigDiv_REQUEST"+request_id;
	var par1=request_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
}


//***********************************************
function setPicklistHiddenField(id) {
	var el=document.getElementById(id);
	if (!el) return;
	var elpicked=document.getElementById("target_list_"+id);
	if (!elpicked) return;
	var hidden_val="";
	picked_options=elpicked.options;
	for (var i=0;i<picked_options.length;i++) {
		if (i>0) hidden_val=hidden_val+"|::|";
		hidden_val=hidden_val+picked_options[i].value;
	}
	el.value=hidden_val;
}


//**********************************
function makeFileContentModal(member_id) {
	 
	var el=document.getElementById("fileContentOf"+member_id+"Div");
	//if (el) return;// $("#"+repo_tree_div+"Div").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		 <div class=\"modal fade bs-example-modal-lg\" id=\"fileContentOf"+member_id+"Div\" data-keyboard=\"false\" data-backdrop=\"static\" style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-lg\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"				<div class=\"modal-header\" id=taskHeader> \n"+
	"					<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n"+
	"						<span aria-hidden=\"true\">&times;</span> \n"+
	"						<span class=\"sr-only\">Close</span> \n"+
	"					</button> \n"+
	"				</div> <!--  modal header --> \n"+
	"			 	 <div class=\"modal-body\" id=\"fileContentOf"+member_id+"Body\"  style=\"background-color=black;min-height: 500px; max-height: 500px; \"> \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content --> \n"+
	"		</div> <!--  modal dialog -->  \n"+
	"	</div> <!--  modal fade -->"; 

	$('body').append(modal_html);
	
	
}

//**********************************
function showFileContentOnVersionChange(request_id, member_id) {
	var member_version=document.getElementById("file_content_version_"+request_id).value;
	var compare_version=document.getElementById("file_content_compare_version_"+request_id).value;

	showFileContent(request_id, member_id, member_version,compare_version);
}

//**********************************
function showFileContent(request_id, member_id, member_version, compare_version) {
	
	makeFileContentModal(request_id);

	
	var action="show_file_content";
	var div_id="fileContentOf"+request_id+"Body";
	var par1=request_id;
	var par2=member_id;
	var par3=member_version;
	var par4=compare_version;


	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	showModal("fileContentOf"+request_id+"Div");
	
}


//**********************************
function showFileContentByUrl(request_id, application_id, repo_url) {
	
	
	
	makeFileContentModal(request_id);
	
	var action="show_file_content_by_url";
	var div_id="fileContentOf"+request_id+"Body";
	var par1=application_id;
	var par2=repo_url;
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("fileContentOf"+request_id+"Div");
	
}

//**********************************
function makeRepoTreeModal(repo_tree_div) {
	 
	var el=document.getElementById(repo_tree_div+"Div");
	//if (el) return;// $("#"+repo_tree_div+"Div").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		 <div class=\"modal fade bs-example-modal-lg\" id=\""+repo_tree_div+"Div\" data-keyboard=\"false\" data-backdrop=\"static\" style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-lg\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"				<div class=\"modal-header\" id=taskHeader> \n"+
	"		        	<button type=\"button\" class=\"btn btn-success\" id=btReloadRepoWindow onclick=\"reloadRepoWindow();\"> \n"+
	"		        		<span class=\"glyphicon glyphicon-refresh\"> Refresh Reposiyory List </span> \n"+
	"		        	</button> \n"+
	"					<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n"+
	"						<span aria-hidden=\"true\">&times;</span> \n"+
	"						<span class=\"sr-only\">Close</span> \n"+
	"					</button> \n"+
	"				</div> <!--  modal header --> \n"+
	"			 	 <div class=\"modal-body\" id=\""+repo_tree_div+"\"  style=\"background-color:black; min-height: 400px; max-height: 400px; overflow-x: scroll; overflow-y: scroll;\"> \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content --> \n"+
	"		</div> <!--  modal dialog -->  \n"+
	"	</div> <!--  modal fade -->"; 

	$('body').append(modal_html);
	
	
}

//***********************************************
function fillRepo(package_id,application_id) {
	
	var repo_tree_div="repo_items_"+package_id+"_"+application_id;
	
	makeRepoTreeModal(repo_tree_div);
	showModal(repo_tree_div+"Div");
	
	var action="initialize_repo_folder";
	var div_id=repo_tree_div;
	var par1=package_id;
	var par2=application_id;
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}

//************************************************
function reloadRepoWindow() {
	var el_pack=document.getElementById("repo_window_package_id");
	var el_app=document.getElementById("repo_window_application_id");
	
	if (!el_pack) {
		console.log("repo_window_package_id not found!");
		return;
	}
	
	var package_id=el_pack.value;
	var application_id=el_app.value;
	
	fillRepo(package_id,application_id);
	
}
//************************************************
function openRepoTreeFolder(package_id, application_id, item_id, dir_to_open,level) {
	
	var action="open_repo_folder";
	var div_id="NOFADE_sub_tree_items_of_"+package_id+"_"+application_id+"_"+item_id;
	var par1=package_id;
	var par2=application_id;
	var par3=dir_to_open;
	var par4=level;
	
	
	
	var el=document.getElementById(div_id);
	
	var repo_div_content=el.innerHTML;
	if (repo_div_content.length>10 && repo_div_content.indexOf("Loading...")==-1) {
		
		var disp=el.style.display;
		if (disp.length==0) disp="block";
		if (disp=="block") el.style.display="none";
		else el.style.display="block";
		
		return;
	}
	
	
	el.innerHTML="<font color=lightgray>&nbsp;&nbsp;&nbsp;Loading...</font>";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}


//**************************************************************
function addRemoveItemOfPackagedApplication(origin,package_id, application_id, item_name, item_path, version, item_id) {
	
	if (item_name=="." || item_name=="..") return;
	
	var ch_el_id="ch_file_"+package_id+"_"+application_id+"_"+item_id;
	var ch_el=document.getElementById(ch_el_id);
	if (!ch_el) {
		console.log("no such item found id="+ch_el_id);
		//return;
	}
	
	var is_checked=false;
	
	try{is_checked=ch_el.checked;} catch(err) {is_checked=false;}
	if (origin=="TABLE") is_checked=false;

	var action="";
	var div_id="";
	var par1="";
	var par2="";
	var par3="";
	var par4="";
	var par5="";
	
	var is_already_item_id="file_in_pack_"+package_id+"_"+application_id+"_"+item_id;
	var is_already_added=document.getElementById(is_already_item_id);
	
	//adding 
	if (is_checked) {
		

		if (is_already_added && origin!="TABLE") {
			myalert("This item is already added in application.");
			return;
		}
		
		action="add_item_to_application";
		div_id="NONE";
		par1=package_id;
		par2=application_id;
		par3=item_name;
		par4=item_path;
		par5=version;
		
		action=action+":::::show_added_app_items";
		div_id=div_id+":::::NOFADE_added_app_items_"+package_id+"_"+application_id;
		par1=par1+":::::"+package_id;
		par2=par2+":::::"+application_id;
		par3=par3+":::::x";
		par4=par4+":::::x";
		par5=par5+":::::x";
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
		
	} else {
		if (!is_already_added) {
			return;
		}

		bootbox.confirm("Are you sure to remove this item ?", function(result) {
			
			if(!result) {
				try{if (!ch_el.checked) ch_el.checked=true;} catch(err) {}
				return;
			}
			
			
			action="remove_item_from_application";
			div_id="NONE";
			par1=package_id;
			par2=application_id;
			par3=item_name;
			par4=item_path;
			par5=version;
			
			action=action+":::::show_added_app_items";
			div_id=div_id+":::::NOFADE_added_app_items_"+package_id+"_"+application_id;
			par1=par1+":::::"+package_id;
			par2=par2+":::::"+application_id;
			par3=par3+":::::x";
			par4=par4+":::::x";
			par5=par5+":::::x";
			
			ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
			
			if (ch_el) ch_el.checked=false;
		});

		
	}

}

function refreshApplicationMembersInPackage(package_id, application_id) {
	var action="show_added_app_items";
	var div_id="NOFADE_added_app_items_"+package_id+"_"+application_id;
	var par1=""+package_id;
	var par2=""+application_id;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2); 
}

//*************************************************************
function reorderItemOfPackagedApplication(package_id,application_id,id1,id2) {
	
	var action="reorder_item_of_application:::::show_added_app_items";
	var div_id="NONE:::::NOFADE_added_app_items_"+package_id+"_"+application_id;
	var par1=id1+":::::"+package_id;
	var par2=id2+":::::"+application_id;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2); 
	
}

//*************************************************************
function reorderItemOfDeploymentRequest(request_id,application_id,id1,id2) {
	
	var action="reorder_item_of_application:::::write_deployment_list_of_request";
	var div_id="NONE:::::NOFADE_deplomentOrderingDiv_"+request_id;
	var par1=id1+":::::"+request_id;
	var par2=id2+":::::x";
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2); 
	
}


//***************************************************************
function selectedChCount(startwith) {
	var sel_count=0;
	for (var i=0;i<1000;i++) {
		var elsel=document.getElementById(startwith+i);
		if (!elsel) break;
		if (elsel.checked) {sel_count++; }
	}
	return sel_count;
}

//***************************************************************
function linkAppEnv(request_id,origin,obj) {
	var is_checked=obj.checked;
	
	if (request_id=="0") {
		obj.checked=false;
		return;
	}
	
	
	var act="ADD";
	if (!is_checked) act="DEL";
	
	var elenv=document.getElementById("environment_id_"+request_id);
	var environment_id=elenv.value;
	if (environment_id=="") {
		obj.checked=false;
		myalert("Please select environment to proceed.");
		return;
	}
	
	var checked_app_count= selectedChCount("selected_app_"+request_id+"_");
	if (checked_app_count>0) elenv.disabled=true;
	else elenv.disabled=false;
	
	
	var action="link_app_environment";
	var div_id="NONE";
	var par1=request_id;
	var par2=act;
	var par3=origin;
	var par4=obj.value;
	var par5=environment_id;
	
	if (act=="DEL") {
		bootbox.confirm("Are you sure to remove this application from deployment list?", function(result) {
			
			if(!result) {
				obj.checked=true;
				return;
			}

			ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
		});
	}
	else {
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);

	}

	
	
}






//****************************************************************
function addPackageToRequest(main_request_id) {
	
	var elenv=document.getElementById("environment_id_"+main_request_id);
	if (!elenv) return;
	var environment_id=elenv.value;
	
	if (environment_id=="" || environment_id=="0") {
		myalert("select Environment to proceed");
		return;
	}


	showMadSearchBox("SELECT",main_request_id);
	
	
}




//****************************************************************
function setDeploymentSlot(request_id) {
	
	var elenv=document.getElementById("environment_id_"+request_id);
	if (!elenv) return;
	var environment_id=elenv.value;
	
	if (environment_id=="") {
		myalert("select Environment to deploy to proceed");
		return;
	}


	showMadDeploymentSlot(request_id,environment_id);
	
}


//***********************************************************************
function makeDeploymentSlotModal() {
	 
	var el=document.getElementById("DeploymentSlotDiv");
	//if (el) return; 
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-md\" id=\"DeploymentSlotDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-md\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"		 		<div class=\"modal-header\" id=taskHeader> \n"+
	"		 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n"+
	"		 				<span aria-hidden=\"true\">&times;</span> \n"+
	"		 				<span class=\"sr-only\">Close</span> \n"+
	"		 			</button> \n"+
	"		 		</div> <!--  modal header --> \n"+
	"			 	 <div class=\"modal-body\" id=\"DeploymentSlotBody\"  style=\"min-height: 0px; max-height: 300px; overflow-x: scroll; overflow-y: scroll;\"> \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"              <div class=\"modal-footer\"> \n"+
	"                 <button type=\"button\" class=\"btn btn-sm btn-default\" data-dismiss=\"modal\">Close</button> \n"+  
	"				  <button type=\"button\" class=\"btn btn-sm btn-success\" onclick=\"setRequestDeploymentSlot();\"> \n" + 
	"				  	<span class=\"glyphicon glyphicon-floppy-disk\"></span> Save \n" +
	"				  </button> \n"+
	"              </div> \n"+
	"		 	</div> <!--  modal content -->	\n"+
	"		</div> <!--  modal dialog --> \n"+
	"	</div> <!--  modal fade -->";

	$('body').append(modal_html);
	
	
	
	
}

//****************************************************************
function showMadDeploymentSlot(request_id, environment_id) {
	
	makeDeploymentSlotModal();
	
	var action="show_mad_deployment_slot";
	var div_id="DeploymentSlotBody";
	var par1=request_id;
	var par2=environment_id;
	
	showModal("DeploymentSlotDiv");
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//***************************************************************
function setRequestDeploymentSlot() {
	var request_id=document.getElementById("deployment_slot_request_id").value;

	var elSlotDetailId=document.getElementById("list_deployment_slot_detail_id");
	
	
	if (elSlotDetailId) {
		var  slot_detail_id=elSlotDetailId.value;
		if (slot_detail_id=="") {
			myalert("Pick a Deployment Slot to proceed");
			return;
		}
		
		
		var action="set_mad_deployment_slot";
		var div_id="NONE";
		var par1=request_id;
		var par2=slot_detail_id;
		var par3="x";
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	}
	
	var elFreeTime=document.getElementById("free_deployment_time");
	
	if (elFreeTime) {
		var free_time=elFreeTime.value;
		
		
		var action="set_mad_deployment_slot";
		var div_id="NONE";
		var par1=request_id;
		var par2="0";
		var par3=free_time;
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	}
	
	
	$("#DeploymentSlotDiv").modal("hide");
	
	
	
}

//***********************************************************************
function makeDeploymentSlotButton(request_id) {
	var action="make_mad_deployment_button";
	var div_id="deploymentDateDiv"+request_id;
	var par1=request_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//***********************************************************************
function makeDeploymentSlotButton(request_id) {
	var action="make_mad_deployment_button";
	var div_id="deploymentDateDiv"+request_id;
	var par1=request_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//****************************************************************
function packinRequestSelectDeselectAll(request_id) {
	
	var elchall=document.getElementById("ch_pack_all_"+request_id);
  	
  	
  	for (var i=0;i<1000;i++) {
  		var el=document.getElementById("ch_pack_"+request_id+"_"+i);
  		if(!el) continue;
  		el.checked=elchall.checked;
  	}
  	
}

//****************************************************************
function packSelectDeselectAll() {
	
	var elchall=document.getElementById("select_packaged_ch_all");
  	
  	
  	for (var i=0;i<1000;i++) {
  		var el=document.getElementById("select_packaged_ch_"+i);
  		if(!el) continue;
  		if(el.disabled) continue;
  		el.checked=elchall.checked;
  	}
  	
}



//****************************************************************
function addPackageToRequestPerform(request_id) {
	
	
	var package_ids="";
  	var cnt=0;
  	
  	for (var i=0;i<1000;i++) {
  		var el=document.getElementById("select_packaged_ch_"+i);
  		if(!el) continue;
  		if(!el.checked) continue;
  		cnt++;
  		if (cnt>1) package_ids=package_ids+",";
  		package_ids=package_ids+el.value;
  	}
  	
  	if (package_ids=="") {
  		myalert("Pick package to add.");
  		return;
  	}
  	
	
	var environment_id=document.getElementById("environment_id_"+request_id).value;
	
	var action="add_package_to_request";
	var div_id="NONE";
	var par1=request_id;
	var par2=package_ids;
	var par3=environment_id;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	$("#madSearchDiv").modal("hide");
	
	showWaitingModal();
	
	
}

//****************************************************************
function showWaitingModal() {
	
	var el=document.getElementById("waitingModal");
	
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		$("#waitingModal").modal();
		return;
	}
	
	
	
	var modal_html=	""+
	"		<div class=\"modal  bs-example-modal-sm\" id=\""+"waitingModal\" data-keyboard=\"false\" data-backdrop=\"static\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-sm\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"			 	 <div class=\"modal-body\" id=\"waitingModalBody\" style=\"background-color:lightgray;\" > \n" +
	"			        <div id=maxViewBody> \n" +
	"						<center><img src=\"img/hourglass.gif\" border=0 width=100 height=100></center>\n" +		
	"			        </div> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	$("#waitingModal").modal();
	

}

//****************************************************************
function hideWaitingModal() {
	
	$("#waitingModal").modal("hide");
} 

//****************************************************************
function selectAllPackagesInRequest() {
	var elall=document.getElementById("ch_select_all_pack");
	if (!elall) return;
	for (var i=0;i<1000;i++) {
		var el=document.getElementById("ch_pack_"+i);
		if (!el) break;
		el.checked=elall.checked;
	}
}
//****************************************************************
function removePackagesFromRequest(request_id) {
	var packs_to_remove="0";
	
	for (var i=0;i<1000;i++) {
		var el=document.getElementById("ch_pack_"+request_id+"_"+i);
		if (!el) break;
		if (el.checked) {
			packs_to_remove=packs_to_remove+","+el.value;
		}
	}
	
	if (packs_to_remove=="0") {
		myalert("No package selected.");
		return;
	}
	
		bootbox.confirm("Are you sure to remove selected packages from the request?", function(result) {
		
		if(!result) {
			return;
		}
		
	  	var elenv=document.getElementById("environment_id_"+request_id);
	  	var environment_id=elenv.value;
	  	
	  	
		var action="remove_packages_from_request";
		var div_id="NONE";
		var par1=request_id;
		var par2=packs_to_remove;
		var par3=environment_id;
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
		
		showWaitingModal();
		
	});
}

//****************************************************************
function refreshAllRequestPackageDivs(request_id) {
	
	
	var action="write_package_list_in_request:::::write_applications_in_request:::::write_request_app_environment_link:::::write_deployment_list_of_request";
	var div_id="NOFADE_deploymentPackLinkedDiv_"+request_id+":::::NOFADE_applicationsInReqDiv_"+request_id+":::::NOFADE_appEnvTargetDiv_"+request_id+":::::NOFADE_deplomentOrderingDiv_"+request_id+"";
	var par1=request_id+":::::"+request_id+":::::"+request_id+":::::"+request_id;
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}

//****************************************************************
function refreshRequestDeploymentList(request_id) {

	var action="write_deployment_list_of_request";
	var div_id="NOFADE_deplomentOrderingDiv_"+request_id;
	var par1=request_id;
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}

//****************************************************************
function refreshRequestApppEnvList(request_id) {

	var action="write_request_app_environment_link";
	var div_id="NOFADE_appEnvTargetDiv_"+request_id;
	var par1=request_id;
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}



//**********************************
function makeTaglistModal() {
	 
	var el=document.getElementById("tagPickerDiv");
	//if (el) $("#tagPickerDiv").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-md\" id=\"tagPickerDiv\" data-keyboard=\"false\" data-backdrop=\"static\" style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-md\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"			 	 <div class=\"modal-body\" id=\"tagPickerBody\"  style=\"min-height: 0px; max-height: 400px; overflow-x: scroll; overflow-y: scroll;\"> \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"		      	 \n"+
	"		      	<div class=\"modal-footer\"> \n"+
	"		      		 \n"+
	"		      		 \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		        	<button type=\"button\" class=\"btn btn-success\" id=btPlaceTag onclick=\"placeTag();\">Set Tag & Version</button> \n"+
	"		      	</div> \n"+
	"	      	 \n"+
	"		 	</div> <!--  modal content -->	 		 \n"+
	"		</div> <!--  modal dialog -->  \n"+
	"	</div> <!--  modal fade -->";

	$('body').append(modal_html);
	
	
}





//****************************************************************
function showTagList(application_id, member_id, current_tag, current_ver) {
	
	
	makeTaglistModal();
	showModal("tagPickerDiv");
	
	var action="show_tag_picker";
	var div_id="tagPickerBody";
	var par1=application_id;
	var par2=member_id;
	var par3=current_tag;
	var par4=current_ver;
	var par5="YES";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	
	
	curr_tag_member_id=member_id;
}

var curr_tag_member_id="0";


//****************************************************************
function reloadTagList(application_id, member_id, current_tag, current_ver) {
	
	var action="show_tag_picker";
	var div_id="tagPickerBody";
	var par1=application_id;
	var par2=member_id;
	var par3=current_tag;
	var par4=current_ver;
	var par5="NO";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	

	
}

//*****************************************************************
function clickTag(application_id, member_id, origin) {
	var eltag=document.getElementById("tag_list_of_"+member_id);
	if (!eltag) return;
	
	var curr_tag=eltag.value;
	if (curr_tag.length==0) {
		myalert("Should pick a tag!");
		return;
	}
	
	var elver=document.getElementById("tag_version_list");
	
	var curr_version="";
	try {curr_version=elver.value;}  catch(err) {curr_version="";}
	
	if (origin=="TAG") curr_version="LATEST";
	if (curr_version=="") curr_version="LATEST";
	
	var action="set_version_info";
	var div_id="versionDetailDiv";
	var par1=application_id;
	var par2=member_id;
	var par3=curr_tag;
	var par4=curr_version;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	clearDivContent("versionDetailDiv");
	
}

//*****************************************************************
function placeTag() {
	
	var tag_info_to_set="";
	var el=document.getElementById("tag_list_of_"+curr_tag_member_id);
	if (!el) return;
	
	
	tag_info_to_set=el.value;
	if (tag_info_to_set.length==0) {
		myalert("Pick a tag to set");
		return;
	}
	
	
	var elver=document.getElementById("tag_version_list");
	if (!elver) return;
	
	var version_to_set="";
	try {version_to_set=elver.value;}  catch(err) {version_to_set="";}
	if (version_to_set=="") {
		myalert("Pick a version to set");
		return;
	}
	
	var set_all_application_items="NO";
	var elchsetallapp=document.getElementById("set_all_items_in_application");
	if (elchsetallapp) {
		if (elchsetallapp.checked)
			set_all_application_items="YES";
	}
	
	
	var action="set_tag_info";
	var div_id="NONE";
	var par1=curr_tag_member_id;
	var par2=tag_info_to_set;
	var par3=version_to_set;
	var par4=set_all_application_items;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	$("#tagPickerDiv").modal("hide");
	
} 




//**************************************************
function onFreeTextSearchEnterFILTER(event) {
	if (event.which == 13 || event.keyCode == 13) {
		 	freeTextSearch();
	        return false;
	    }
	 return true;
}

//**************************************************
function onFreeTextSearchEnterDLG(event) {
	
	
	if (event.which == 13 || event.keyCode == 13) {
		 	setMadFiltersAndRun("LIST","","x");
	        return false;
	    }
	    
	 return true;
}

//**************************************************
function onMemberPathEnterDLG(event) {
	
	if (event.which == 13 || event.keyCode == 13) {
		 	setMadFiltersAndRun("LIST","","x");
	        return false;
	    }
	    
	 return true;
}


//**************************************************
function clearFreeTextSearch() {
	
	var elsearch=document.getElementById("free_text_search_box");
	if(!elsearch) return;
	elsearch.value="";
	
}

//**************************************************
function freeTextSearch() {
	
	var elsearch=document.getElementById("free_text_search_box");
	if(!elsearch) return;
	var search_text=elsearch.value;
	
	
	var action="search_request_by_text";
	var div_id="NONE";
	var par1=search_text;
	var par2="FILTER";
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}


//**********************************
function reloadRequestList(skip_filter) {
	
	showWaitingModal();
	
	var action="load_request_list";
	var div_id="listofRequestsDiv";
	var par1="FILTER";
	var par2="x";
	var par3=""+skip_filter;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

	
}


//************************************
function IndexRequest(request_id) {
	var action="index_request";
	var div_id="NONE";
	var par1=""+request_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}
//************************************
function setIndexRequestTimer(request_id) {
	window.setTimeout(function(){IndexRequest(request_id);}, 3000);
}



//**********************************
function makeSearchBoxModal(main_request_id) {
	 
	var el=document.getElementById("madSearchDiv");
	//if (el)	return; //$("#madSearchDiv").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	var modal_html=	""+
					"	<div class=\"modal fade bs-example-modal-lg\" id=\"madSearchDiv\" data-keyboard=\"false\" data-backdrop=\"static\"style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
					"		<div class=\"modal-dialog modal-lg\"> \n" +
					"		 	<div class=\"modal-content\"> \n" +
					"		 		<div class=\"modal-header\" id=taskHeader> \n"+
					"		 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n"+
					"		 				<span aria-hidden=\"true\">&times;</span> \n"+
					"		 				<span class=\"sr-only\">Close</span> \n"+
					"		 			</button> \n"+
					"		 		</div> <!--  modal header --> \n"+
					"			 	 <div class=\"modal-body\" id=\"NOFADE_madSearchBody\"  style=\"min-height: 0px; max-height: 100px;  \"> \n" +
					"			        <p>One fine body&hellip;</p> \n" +
					"		      	</div> <!--  modal body --> \n" +
					"		      	<div class=\"modal-footer\"> \n" +
					"	     			<br> \n" +
					"	     			<button type=\"button\" class=\"btn btn-success\" id=btSearchMAD onclick=\"setMadFiltersAndRun('LIST','','"+main_request_id+"');\"> \n" +
					"		        		<span class=\"glyphicon glyphicon-flash\"></span> Run Query  \n" +
					"		        	</button> \n" +
					"		      		<button type=\"button\" class=\"btn btn-warning\" id=btSaveQuery onclick=\"saveAsPrivateQuery();\"> \n" +
					"	     				<span class=\"glyphicon glyphicon-floppy-save\"></span> Save as a Filter\n" +
					"	     			</button> \n" +
					"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n" +
					"		      	</div> \n" +
					"	      	 \n" +
					"		 	</div> <!--  modal content -->	 		 \n" +
					"		</div> <!--  modal dialog --> \n" +
					"	</div> <!--  modal fade --> \n" ;

	$('body').append(modal_html);
	
	
	
}



//**************************************
function showMadSearchBox(search_mode,main_request_id) {

	
	makeSearchBoxModal(main_request_id);
	
	showModal("madSearchDiv");
	
	$('#madSearchDiv').on('hidden.bs.modal', function () { 
			var search_mode=document.getElementById("mad_search_box_mode").value;
			if(search_mode=="FILTER") {
				reloadRequestList('NO');
			}
			 
		});
	
	
	var action="show_mad_search_box";
	var div_id="NOFADE_madSearchBody";
	var par1=""+search_mode;
	var par2="x";
	var par3=main_request_id;
	
	if (par2=="") par2="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
	
}


//******************************************
function onRepoConfigChange(application_id, config_name) {
	var TYPE_FILTER="";
	var MAXLEVEL="";
	var NAME_FILTER="";
	
	
	
	try{TYPE_FILTER=document.getElementById("TYPE_FILTER_of_"+config_name+"_for_app_"+application_id).value;} catch(err) {}
	try{MAXLEVEL=document.getElementById("MAXLEVEL_of_"+config_name+"_for_app_"+application_id).value;} catch(err) {}
	try{NAME_FILTER=document.getElementById("NAME_FILTER_of_"+config_name+"_for_app_"+application_id).value;} catch(err) {}


	
	var final_config="";
	
	if (TYPE_FILTER!="") final_config=final_config+"\nTYPE_FILTER="+TYPE_FILTER;
	if (MAXLEVEL!="") final_config=final_config+"\nMAXLEVEL="+MAXLEVEL;
	if (NAME_FILTER!="") final_config=final_config+"\nNAME_FILTER="+NAME_FILTER;
	
	var field_name=config_name;
	var field_value=final_config;
	
	
	var action="update_application_field";
	var div_id="NONE";
	var par1=""+application_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//******************************************
function setDateTimeVisibility(chobj,enttype, datetime_id) {
	var dt_div_id="NOFADE_datepicker_"+enttype+"_"+datetime_id;
	var el=document.getElementById(dt_div_id);
	if (el) {
		if (chobj.checked) {
			el.style.visibility='visible';
			if (enttype.indexOf("search")==0) {
				document.getElementById("NOFADE_datepicker_formula_"+datetime_id).style.visibility='hidden';
				document.getElementById("ch_formula_of_"+datetime_id).checked=false;
			}
			else {
				document.getElementById("NOFADE_datepicker_search_start_"+datetime_id).style.visibility='hidden';
				document.getElementById("NOFADE_datepicker_search_end_"+datetime_id).style.visibility='hidden';
				document.getElementById("ch_from_of_"+datetime_id).checked=false;
				document.getElementById("ch_to_of_"+datetime_id).checked=false;
				
			}
			}
		
		else el.style.visibility='hidden';
	}
	
}

//******************************************
function setNumberVisibility(chobj,enttype, number_id) {
	var number_div_id="NOFADE_numberinput_"+enttype+"_"+number_id;

	var el=document.getElementById(number_div_id);
	if (el) {
		if (chobj.checked)  
			el.style.visibility='visible';
		else 
			el.style.visibility='hidden';
	}
	
}

//*******************************************
function clearAllMadFilters() {
	
	var action="clear_flex_field_filters";
	var div_id="NONE";
	var par1="FILTER";
	var par2="x";
	var par3="x";


	//------------- UnSet Waiting My Action Filter
	action=action+":::::unset_mad_waiting_action_query";
	div_id=div_id+":::::NONE";
	par1=par1+":::::x";
	par2=par2+":::::x";
	par3=par3+":::::x";
	
	document.getElementById("free_text_search_box").value="";
	
	//------------- Clear Search Filter 
	action=action+":::::clear_mad_all_search_filters";
	div_id=div_id+":::::NONE";
	par1=par1+":::::FILTER";
	par2=par2+":::::x";
	par3=par3+":::::x";
	
	//------------- Unset All Mad Queries
	action=action+":::::unset_mad_all_queries";
	div_id=div_id+":::::NONE";
	par1=par1+":::::x";
	par2=par2+":::::x";
	par3=par3+":::::x";
	
	//------------- Reload queries
	action=action+":::::load_mad_queries";
	div_id=div_id+":::::NOFADE_queryListDiv";
	par1=par1+":::::x";
	par2=par2+":::::x";
	par3=par3+":::::x";
	
	
	action=action+":::::load_request_list";
	div_id=div_id+":::::listofRequestsDiv";
	par1=par1+":::::FILTER";
	par2=par2+":::::x";
	par3=par3+":::::NO";
		
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
}





//*******************************************
function setMadFiltersAndRun(for_target, query_id,main_request_id) {
	
	showWaitingModal();
	
	var search_mode=document.getElementById("mad_search_box_mode").value;

	var action="unset_mad_waiting_action_query";
	var div_id="NONE";
	var par1="x";
	var par2="x";
	var par3="x";
	var par4="x";
	
	//clear search filters
	action=action+":::::clear_mad_all_search_filters";
	div_id=div_id+":::::NONE";
	par1=par1+":::::"+search_mode;
	par2=par2+":::::x";
	par3=par3+":::::x";
	par4=par4+":::::x";
	
	//clear flex field filters
	action=action+":::::clear_flex_field_filters";
	div_id=div_id+":::::NONE";
	par1=par1+":::::"+search_mode;
	par2=par2+":::::x";
	par3=par3+":::::x";
	par4=par4+":::::x";
	
	//------------- Set Free Text Search Filter
	var filter_keyword=document.getElementById("filter_keyword").value;
	
	if(filter_keyword=="") filter_keyword="${null}";
	
	action=action+":::::search_request_by_text";
	div_id=div_id+":::::NONE";
	par1=par1+":::::"+filter_keyword;
	par2=par2+":::::"+search_mode;
	par3=par3+":::::x";
	par4=par4+":::::x";
	
	//------------- Set Member Path Search Filter
	var elFILTER_MEMBER_PATH=document.getElementById("FILTER_MEMBER_PATH");
	
	if (elFILTER_MEMBER_PATH) {
		var FILTER_MEMBER_PATH=elFILTER_MEMBER_PATH.value;
		
		if(FILTER_MEMBER_PATH=="") FILTER_MEMBER_PATH="${null}";
		
		action=action+":::::set_mad_filter";
		div_id=div_id+":::::NONE";
		par1=par1+":::::FILTER_MEMBER_PATH";
		par2=par2+":::::"+FILTER_MEMBER_PATH;
		par3=par3+":::::"+search_mode;
		par4=par4+":::::x";
	}
	
	
	//------------- Set Application Search Filter
	var elFILTER_APPLICATIONS=document.getElementById("FILTER_APPLICATIONS");
	
	if (elFILTER_APPLICATIONS) {
		var FILTER_APPLICATIONS=elFILTER_APPLICATIONS.value;
		
		if(FILTER_APPLICATIONS=="") FILTER_APPLICATIONS="${null}";
		
		action=action+":::::set_mad_filter";
		div_id=div_id+":::::NONE";
		par1=par1+":::::FILTER_APPLICATIONS";
		par2=par2+":::::"+FILTER_APPLICATIONS;
		par3=par3+":::::"+search_mode;
		par4=par4+":::::x";
	}
	
	//------------- Set Environments Search Filter
	var elFILTER_ENVIRONMENTS=document.getElementById("FILTER_ENVIRONMENTS");
	
	if (elFILTER_ENVIRONMENTS) {
		var FILTER_ENVIRONMENTS=elFILTER_ENVIRONMENTS.value;
		
		if(FILTER_ENVIRONMENTS=="") FILTER_ENVIRONMENTS="${null}";
		
		action=action+":::::set_mad_filter";
		div_id=div_id+":::::NONE";
		par1=par1+":::::FILTER_ENVIRONMENTS";
		par2=par2+":::::"+FILTER_ENVIRONMENTS;
		par3=par3+":::::"+search_mode;
		par4=par4+":::::x";
	}
	
	//------------- Set Request Group  Filter
	var filter_request_group=document.getElementById("filter_request_group").value;
	action=action+":::::set_mad_filter";
	div_id=div_id+":::::NONE";
	par1=par1+":::::filter_request_group";
	par2=par2+":::::"+filter_request_group;
	par3=par3+":::::"+search_mode;
	par4=par4+":::::x";
	
	//------------- Set Request Type Filter
	var filter_request_type=document.getElementById("filter_request_type").value;
	action=action+":::::set_mad_filter";
	div_id=div_id+":::::NONE";
	par1=par1+":::::filter_request_type";
	par2=par2+":::::"+filter_request_type;
	par3=par3+":::::"+search_mode;
	par4=par4+":::::x";
	
	
	//------------- Set Request Status Filter
	var filter_request_status=document.getElementById("filter_request_status").value;
	if (filter_request_status=="") filter_request_status="${empty}";
	action=action+":::::set_mad_filter";
	div_id=div_id+":::::NONE";
	par1=par1+":::::filter_request_status";
	par2=par2+":::::"+filter_request_status;
	par3=par3+":::::"+search_mode;
	par4=par4+":::::x";
	
	//------------- Set Request Created By Filter
	var filter_request_created_by=document.getElementById("filter_request_created_by").value;
	action=action+":::::set_mad_filter";
	div_id=div_id+":::::NONE";
	par1=par1+":::::filter_request_created_by";
	par2=par2+":::::"+filter_request_created_by;
	par3=par3+":::::"+search_mode;
	par4=par4+":::::x";
	
	//------------- Set Request Creation Date Filter
	var filter_request_date=buildDateFilter("filter_request_date");
	action=action+":::::set_mad_filter";
	div_id=div_id+":::::NONE";
	par1=par1+":::::filter_request_date";
	par2=par2+":::::"+filter_request_date;
	par3=par3+":::::"+search_mode;
	par4=par4+":::::x";
	
	
	//------------- Set Request Deployment Date Filter
	
	var filter_deployment_date=buildDateFilter("filter_deployment_date");
	action=action+":::::set_mad_filter";
	div_id=div_id+":::::NONE";
	par1=par1+":::::filter_deployment_date";
	par2=par2+":::::"+filter_deployment_date;
	par3=par3+":::::"+search_mode;
	par4=par4+":::::x";
		
	
	for (var i=0;i<100;i++) {
		var flex_field_id="";
		var flex_field_type="";
		var filter_value="";
		
		var el=document.getElementById("id_of_search_TAB0_flex_field_id_"+i);
		if (!el) break;
		flex_field_id=el.value;
		
		el=document.getElementById("entry_type_of_search_TAB0_flex_field_id_"+i);
		flex_field_type=el.value;
		
		
		if (flex_field_type=="LIST") {
			filter_value=document.getElementById("search_of_search_TAB0_flex_field_id_"+i).value;
		}
		if (flex_field_type=="CHECKBOX") {
			filter_value=document.getElementById("value_of_search_TAB0_flex_field_id_"+i).value;
		}
		if (flex_field_type=="TEXT") {
			filter_value=document.getElementById("search_TAB0_flex_field_id_"+i).value;
		}
		if (flex_field_type=="PICKLIST") {
			filter_value=document.getElementById("search_TAB0_flex_field_id_"+i).value;
		}
		if (flex_field_type=="DATE" || flex_field_type=="DATETIME") {
			
			filter_value=buildDateFilter("search_TAB0_flex_field_id_"+i);
		}
		if (flex_field_type=="NUMBER") {
			
			filter_value=buildNumberFilter("search_TAB0_flex_field_id_"+i);
		}
		if (filter_value=="") continue;
		
		action=action+":::::set_flex_field_filter";
		div_id=div_id+":::::NONE";
		par1=par1+":::::"+flex_field_type;
		par2=par2+":::::"+flex_field_id;
		par3=par3+":::::"+filter_value;
		par4=par4+":::::"+search_mode;
	}
	
	
	//------------- Reload result list
	action=action+":::::load_request_list";
	div_id=div_id+":::::searchBoxResultsDiv";
	par1=par1+":::::"+search_mode;
	par2=par2+":::::"+main_request_id;
	par3=par3+":::::YES"; //TEST : sadece Filtre editorde //REAL : GErcek listeleri doldururken
	par4=par4+":::::x";
	
	if (for_target=="SAVE") {
		action=action+":::::set_mad_private_filter_parameters";
		div_id=div_id+":::::NONE";
		par1=par1+":::::"+query_id;
		par2=par2+":::::x";
		par3=par3+":::::x";
		par4=par4+":::::x";
	}
	
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	
	
}


function makeMemberConflictModal(member_id) {
	 
	var el=document.getElementById("memberConflictDiv"+member_id);
	//if (el) return;
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"memberConflictDiv"+member_id+"\" data-keyboard=\"false\" data-backdrop=\"static\"style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-lg\">  \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"		 		<div class=\"modal-header\" id=memberConflictHeader"+member_id+"\"> \n" +
	"		 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n" +
	"		 				<span aria-hidden=\"true\">&times;</span> \n" +
	"		 				<span class=\"sr-only\">Close</span> \n" +
	"		 			</button> \n" +
	"		 		</div>  \n" +
	"			 	 <div class=\"modal-body\" id=\"memberConflictBody"+member_id+"\"  style=\"min-height: 0px; max-height: 550px; \" > \n" +
	"			        <p>One fine body&hellip;</p> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n" +
	"		      		<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n" +
	"		      	</div> \n" +
	"		 	</div> <!--  modal content -->  \n" +
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->";

	$('body').append(modal_html);
	
	
}

//*******************************************
function showMadMemberConflict(request_id,member_id) {
	makeMemberConflictModal(member_id);
	
	showModal("memberConflictDiv"+member_id);
	
	var action="show_mad_member_conflict";
	var div_id="memberConflictBody"+member_id;
	var par1=""+request_id;
	var par2=""+member_id;


	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}



//*******************************************
function gotoStartOfsearchBoxResultsDiv() {
	location.hash = "#StartOfsearchBoxResultsDiv";
}

//*******************************************
function changedSavingQueryList() {
	var el_list=document.getElementById("saving_query_list");
	var el_text=document.getElementById("saving_query_name");
	
	
	if (el_list.value=="") {
		el_text.value="New Filter";
		el_text.disabled=false;
		el_text.focus();
		el_text.select();
	} else {
		el_text.value=$('#saving_query_list option:selected').text();
		el_text.disabled=true;
	}
	
}


function makeSaveAsFilterModal() {
	 
	var el=document.getElementById("saveFilterAsDiv");
	//if (el) $("#saveFilterAsDiv").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-md\" id=\"saveFilterAsDiv\" data-keyboard=\"false\" data-backdrop=\"static\"style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-md\">  \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"		 		<div class=\"modal-header\" id=saveFilterAsHeader\"> \n" +
	"		 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n" +
	"		 				<span aria-hidden=\"true\">&times;</span> \n" +
	"		 				<span class=\"sr-only\">Close</span> \n" +
	"		 			</button> \n" +
	"		 		</div>  \n" +
	"			 	 <div class=\"modal-body\" id=\"saveFilterAsBody\"  style=\"min-height: 0px; max-height: 550px; \" > \n" +
	"			        <p>One fine body&hellip;</p> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n" +
	"		      		<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n" +
	"		        	<button type=\"button\" class=\"btn btn-success\" id=btSaveMADFilter onclick=\"saveMadFilterDo();\"> \n" +
	"		        		<span class=\"glyphicon glyphicon-floppy-save\"> Save </span> \n" +
	"		        	</button> \n" +
	"		      	</div> \n" +
	"		 	</div> <!--  modal content -->  \n" +
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->";

	$('body').append(modal_html);
	
	
}

//*******************************************
function saveAsPrivateQuery() {
	
	makeSaveAsFilterModal();
	
	var current_query_id=document.getElementById("mad_search_query_id").value;

	var action="make_save_as_private_filter_dlg";
	var div_id="saveFilterAsBody";
	var par1=""+current_query_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("saveFilterAsDiv");
}


//*******************************************
function saveMadFilterDo() {
	
	var saving_query_id=document.getElementById("saving_query_list").value;
	var saving_query_name=document.getElementById("saving_query_name").value;

	if (saving_query_name=="") {
		myalert("Please enter a filter name");
		return;
	}
	
	if (saving_query_id=="") {
		var action="add_new_mad_private_filter:::::load_mad_queries";
		var div_id="NONE:::::NOFADE_queryListDiv";
		var par1=""+saving_query_name+":::::x";
		
		ajaxDynamicComponentCaller(action, div_id, par1);
		$("#saveFilterAsDiv").modal("hide");
		
	} else {
		bootbox.confirm("Do you want to overwrite filter '"+saving_query_name+"' ?", function(result) {
			if(!result)	return;
			
			setMadFiltersAndRun("SAVE", saving_query_id);
			
			$("#saveFilterAsDiv").modal("hide");
			
		});
	}
	
	
	
	
	
	
	
}


//*******************************************
function buildDateFilter(id) {
	
	
	var elvar=document.getElementById("ch_formula_of_"+id);
	if (!elvar) return "x";
		
	var formula_checked=document.getElementById("ch_formula_of_"+id).checked;
	var start_date_checked=document.getElementById("ch_from_of_"+id).checked;
	var end_date_checked=document.getElementById("ch_to_of_"+id).checked;
	
	var formula_filter="x";
	var start_date_filter="x";
	var end_date_filter="x";
	
	if (formula_checked) formula_filter=document.getElementById("formula_"+id).value;
	if (start_date_checked) start_date_filter=document.getElementById("search_start_"+id).value;
	if (end_date_checked) end_date_filter=document.getElementById("search_end_"+id).value;
	
	if (start_date_filter=="x" && end_date_filter=="x" && formula_filter=="x" ) {
		return "x";
	}
	 return start_date_filter+ "to"+ end_date_filter+"with"+formula_filter;
}


//*******************************************
function buildNumberFilter(id) {
	var start_number_checked=document.getElementById("ch_from_of_"+id).checked;
	var end_number_checked=document.getElementById("ch_to_of_"+id).checked;
	
	var start_number_filter="x";
	var end_number_filter="x";
	
	if (start_number_checked) start_number_filter=document.getElementById("search_start_"+id).value;
	if (end_number_checked) end_number_filter=document.getElementById("search_end_"+id).value;
	
	return start_number_filter+ "to"+ end_number_filter;
}

//*******************************************
function makeRequesTypeFilterCombo() {
	
	var search_mode=document.getElementById("mad_search_box_mode").value;
	
	var request_group=document.getElementById("filter_request_group").value;
	
	var action="make_request_type_filter_combo:::::make_request_type_status_list";
	var div_id="RequesTypeFilterComboDiv:::::RequesTypeStatusFilterDiv";
	var par1=request_group+":::::"+request_group;
	var par2=search_mode+":::::0";
	var par3="x:::::"+search_mode;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//*******************************************
function filterRequestTypeChanged() {
	
	var request_group=document.getElementById("filter_request_group").value;
	var request_type_id=document.getElementById("filter_request_type").value;
	var search_mode=document.getElementById("mad_search_box_mode").value;
	
	var action="make_request_type_status_list:::::make_request_type_flex_field_filter_list";
	var div_id="RequesTypeStatusFilterDiv:::::RequesTypeFlexFieldsFilterListDiv";
	
	var par1=request_group+":::::"+request_type_id;
	var par2=request_type_id+":::::"+search_mode;
	var par3=search_mode+":::::x";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}
//*******************************************
function setMadFilter(filter_name, filter_val) {
	var action="set_mad_filter";
	var div_id="NONE";
	var par1=filter_name;
	var par2=filter_val;
	if (par2=="") par2="x";
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}



//***************************************************
function onLoadConfiguration() {
	
	var action="load_configuration_menu";
	var div_id="configLeftDiv";
	var par1="x";
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function setLovSelection(id,val) {
	var el=document.getElementById("lov_selected_value");
	el.value=val;
	
	
	for (var i=0;i<10000;i++) {
		el=document.getElementById("lov_row_"+i);
		if (!el) return;
		if (parseInt(id)==i)
			el.style.backgroundColor = "#DADADA";
		else
			el.style.backgroundColor = "";
		
	}
	
	
}
//**************************************************
function selectLOV() {
	var el=document.getElementById("lov_selected_value");
	var selectedVal=el.value;
	if (selectedVal=="" || selectedVal=="x") {
		myalert("Pick a value to proceed");
		return;
	}
	
	var elevent=document.getElementById("lov_fireEvent");
	if (elevent) {
		var fireevent=elevent.value;
		fireevent=fireevent.replace("#",selectedVal);
		runjs_code(fireevent);
	}
	
	$("#lovDiv").modal("hide");
}

//**************************************************
function updateMadPlatformParameter(platform_id,flex_field_id,new_value) {
	var action="update_mad_platform_parameter_value";
	var div_id="NONE";
	var par1=""+platform_id;
	var par2=""+flex_field_id;
	var par3=""+new_value;
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//**************************************************
function addNewMadRequestType() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Request Group";
	var par2="request_group";
	var par3="x";
	var par4="x";
	var par5="fireAddMadRequestType('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}





//**************************************************
function addNewMadDeploymentSlot() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Deployment Slot Type";
	var par2="slot_type";
	var par3="x";
	var par4="x";
	var par5="fireAddMadDeploymentSlot('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}


//**************************************************
function addNewPlatformTypeModifierGroup(platform_type_id) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Modifier Group";
	var par2="modifier_group";
	var par3="x";
	var par4="x";
	var par5="fireAddMadPlatformTypeModifierGroup('"+platform_type_id+"','#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}


//**************************************************
function addNewMadFlexField() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Field Type";
	var par2="flex_field_type";
	var par3="x";
	var par4="x";
	var par5="fireAddMadFlexField('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//**************************************************
function fireAddMadFlexField(flex_field_type) {
	  
	bootbox.prompt("Enter Field Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Field Name cannot be empty");
				  return;
			  }
			  
			  var action="add_mad_flexible_field";
			  var div_id="NONE";
			  var par1=flex_field_type;
			  var par2=result;
				
			  ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
	
		
}

//**************************************************
function fireAddMadPlatformTypeModifierGroup(platform_type_id,modifier_group) {
	
	
	  var action="add_mad_platform_type_modifier_group";
	  var div_id="NONE";
	  var par1=platform_type_id;
	  var par2=modifier_group;
		
	  ajaxDynamicComponentCaller(action, div_id, par1, par2);

	
	
}
//**************************************************
function addNewMadPlatform() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Platform Type";
	var par2="platform_type";
	var par3="x";
	var par4="x";
	var par5="fireAddMadPlatform('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//**************************************************
function addNewMadRepository() {
	bootbox.prompt("Enter Platform Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Repository Name cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_repository";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
}

//**************************************************
function addNewMadString() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Language";
	var par2="lang_list";
	var par3="x";
	var par4="x";
	var par5="addNewMadStringDO('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//**************************************************
function addNewMadLang() {
	bootbox.prompt("Enter Language Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Language Name cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_lang";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
}

//**************************************************
function addNewMadStringDO(lang) {
	bootbox.prompt("Enter String Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("String Name cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_string";
				var div_id="NONE";
				var par1=result;
				var par2=lang;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
	});
	
}

//**************************************************
function addNewMadGroup() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Group Type";
	var par2="group_type";
	var par3="x";
	var par4="x";
	var par5="fireAddMadGroup('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}
//**************************************************
function addNewMadEmailTemplate() {
	bootbox.prompt("Enter Template Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Template name cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_email_template";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
	
}
//**************************************************
function addNewMadClass() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Class Type";
	var par2="class_type";
	var par3="x";
	var par4="x";
	var par5="fireAddMadClass('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
	
}
//**************************************************
function fireAddMadClass(class_type) {
	bootbox.prompt("Enter Class to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Class cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_class";
				var div_id="NONE";
				var par1=class_type;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
	});
}
//**************************************************
function addNewMadDriver() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Driver Type";
	var par2="driver_type";
	var par3="x";
	var par4="x";
	var par5="fireAddMadDriver('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
	
}

//**************************************************
function fireAddMadDriver(driver_type) {
	bootbox.prompt("Enter Driver Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Driver cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_driver";
				var div_id="NONE";
				var par1=driver_type;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
	});
}
//**************************************************
function addNewMadModifierGroup() {
	bootbox.prompt("Enter Modifier Group Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Modifier Group cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_modifier_group";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
}

//**************************************************
function addNewMadModifierRule(modifier_group_id) {
	bootbox.prompt("Enter Modifier Rule Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Modifier Rule name cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_modifier_rule";
				var div_id="NONE";
				var par1=""+modifier_group_id;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
	});
	
}

//**************************************************
function fireAddMadPlatform(platform_type_id) {
	
	bootbox.prompt("Enter Platform Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Platform Name cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_platform";
				var div_id="NONE";
				var par1=platform_type_id;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
	
}


//**************************************************
function fireAddMadGroup(group_type) {
	
	bootbox.prompt("Enter Group Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Group Name cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_group";
				var div_id="NONE";
				var par1=group_type;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
	
}

//**************************************************
function fireAddMadRequestType(request_group) {
	
	bootbox.prompt("Enter Request Type Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Request Type Name cannot be empty");
				  return;
			  }
			  
			  var action="add_mad_request_type";
				var div_id="NONE";
				var par1=request_group;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
	
}

//**************************************************
function fireAddMadDeploymentSlot(slot_type) {
	
	bootbox.prompt("Enter Slot Name Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Slot Name cannot be empty");
				  return;
			  }
			  
			  var action="add_mad_deployment_slot";
				var div_id="NONE";
				var par1=slot_type;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
	
}



//**************************************************
function addNewMadDashSql() {
	
	bootbox.prompt("Enter Sql Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Sql Name cannot be empty");
				  return;
			  }
			  
			  var action="add_mad_dashboard_sql";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
	
}

//**************************************************
function addNewMadDashParameter() {
	
	bootbox.prompt("Enter Parameter Title to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Parameter Name cannot be empty");
				  return;
			  }
			  
			  var action="add_mad_dashboard_parameter";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
	
}

//**************************************************
function addNewMadDashView() {
	

	var action="show_lov_dialog";
		var div_id="lovBody";
		var par1="View Type";
		var par2="view_type";
		var par3="x";
		var par4="x";
		var par5="addNewMadDashViewDo('#')";
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
		
		showModal("lovDiv");
	
	
}


//**************************************************
function addNewMadDashViewDo(view_type) {
	
	bootbox.prompt("Enter View Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("View Name cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_dashboard_view";
				var div_id="NONE";
				var par1=result;
				var par2=view_type;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
	
}

//**************************************************
function addNewMadDashViewFilter(view_id) {
	

	var action="show_lov_dialog";
		var div_id="lovBody";
		var par1="Dashboard Filter";
		var par2="dashboard_filter";
		var par3="x";
		var par4="x";
		var par5="addNewMadDashViewFilterDo('"+view_id+"','#')";
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
		
		showModal("lovDiv");
	
	
}



//**************************************************
function addNewMadDashViewFilterDo(view_id,parameter_id) {
	var action="add_mad_dashboard_view_parameter";
	var div_id="NONE";
	var par1=view_id;
	var par2=parameter_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**************************************************
function makeMadDashViewFilterList(view_id) {
	var action="make_mad_dash_view_filter_list";
	var div_id="divFilterListForView"+view_id;
	var par1=view_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//**************************************************
function addNewMadDeploymentSlotDetail(slot_id) {
	
	bootbox.prompt("Enter Slot Time Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Slot Time Name cannot be empty");
				  return;
			  }
			  
			  var action="add_mad_deployment_slot_detail";
				var div_id="NONE";
				var par1=slot_id;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
	
}

//**************************************************
function saveMadDeploymentSlotDetail(slot_detail_id) {
	
	var daily_time="";
	var slot_name="";
	var is_valid="YES";
	
	try{daily_time=document.getElementById("daily_time_"+slot_detail_id).value;} catch(err) {}
	try{slot_name=document.getElementById("slot_name_"+slot_detail_id).value;} catch(err) {}
	try{ if (!document.getElementById("is_valid_"+slot_detail_id).checked) is_valid="NO";} catch(err) {}
	
	var action="update_mad_deployment_slot_detail";
	var div_id="NONE";
	var par1=""+slot_detail_id;	
	var par2=""+daily_time;	
	var par3=""+slot_name;	
	var par4=""+is_valid;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	
}

//**************************************************
function removeMadDeploymentSlotDetail(slot_id, slot_detail_id) {
	
	bootbox.confirm("Are you sure to remove this deployment slot from the list?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="remove_mad_deployment_slot_detail";
		var div_id="NONE";
		var par1=""+slot_id;	
		var par2=""+slot_detail_id;	
		
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
});
	
	
}

//**************************************************
function addMadFlexField(parent_table,parent_table_id) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Flexible Fields";
	var par2="flex_field_for_"+parent_table;
	var par3="x";
	var par4="x";
	var par5="fireAddMadTableFlexField('"+parent_table+"',"+parent_table_id+",#)";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//**************************************************
function fireAddMadTableFlexField(parent_table,parent_table_id,flex_field_id) {
	
	var action="add_flex_field";
	var div_id="NONE";
	var par1=""+parent_table;
	var par2=""+parent_table_id;
	var par3=""+flex_field_id;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}


//**************************************************
function makeMadPlatformTypeModifierGroupEditor(platform_type_id) {
	
	var action="make_mad_platform_type_modifier_group_editor";
	var div_id="modifier_group_Div_for_"+platform_type_id;
	var par1=""+platform_type_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadFlexField(parent_table,parent_table_id) {
	
	var action="make_flex_field_table";
	var div_id="NOFADE_flex_fields_"+parent_table+"_"+parent_table_id;
	var par1=parent_table;
	var par2=""+parent_table_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}

//**************************************************
function removeMadFlexFieldTable(parent_table, parent_table_id, id) {
	
	bootbox.confirm("Are you sure to remove this flexible field from the list?", function(result) {
			
			if(!result) {
				return;
			}
			
			var action="remove_flex_field";
			var div_id="NONE";
			var par1=""+parent_table;	
			var par2=""+parent_table_id;	
			var par3=""+id;	
			
			
			ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	});
	
	
}

//**************************************************
function reorderMadModifierRule(group_field_id,rule_id,updown) {
	var action="reorder_mad_modifier_rule";
	var div_id="NONE";
	var par1=""+group_field_id;
	var par2=""+rule_id;
	var par3=updown;
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//**************************************************
function reorderMadFlexField(table_name,group_field_name,group_field_id,table_id,updown) {
	var action="reorder_mad_flex_field";
	var div_id="NONE";
	var par1=""+table_name;
	var par2=""+group_field_name;
	var par3=""+group_field_id;
	var par4=""+table_id;
	var par5=""+updown;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
}


//**************************************************
function addNewMadEnvironment() {
	
	bootbox.prompt("Enter environment name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Environment name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_mad_environment";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
	
}

//**************************************************
function addNewMadPlatformType() {
	
	bootbox.prompt("Enter platform type name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("platform type name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_mad_platform_type";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
	
}

//**************************************************
function addNewMadUser() {
	
	bootbox.prompt("Enter username to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("username name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_mad_user";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
	
}

//**************************************************
function addNewMadApplication() {
	
	bootbox.prompt("Enter application name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("application name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_mad_application";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
	
}

//**************************************************
function addNewMadPermission() {
	
	bootbox.prompt("Enter permission name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("permission name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_mad_permission";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
	
}


//**************************************************
function addNewMadMethod() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Method Type";
	var par2="method_type";
	var par3="x";
	var par4="x";
	var par5="fireAddMadMethod('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}
//**************************************************
function fireAddMadMethod(method_type) {
	bootbox.prompt("Enter method name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("method name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_mad_method";
				var div_id="NONE";
				var par1=result;
				var par2=method_type;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
	});
}


//**************************************************
function addNewActionMethod(action_id) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Method to execute";
	var par2="method";
	var par3="x";
	var par4="x";
	var par5="fireAddMadActionMethod('"+action_id+"','#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//**************************************************
function fireAddMadActionMethod(action_id, method_id) {
	
	var action="add_new_mad_action_method";
	var div_id="NONE";
	var par1=action_id;
	var par2=method_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}


//**************************************************
function reorderMadFlowStateActionMethod(action_id, execution_order, direction) {
	
	var action="reorder_flow_state_action_method";
	var div_id="NONE";
	var par1=action_id;
	var par2=execution_order;
	var par3=direction;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//*************************************************
function makeMadActionMethodList(action_id) {
	var action="make_flow_state_action_method_list";
	var div_id="methodsToExecuteDivForAction_"+action_id;
	var par1=action_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}

//**************************************************
function addNewMadFlow() {
	
	bootbox.prompt("Enter flow name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("flow name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_mad_flow";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
}


//**************************************************
function addNewMadFlowState(flow_id) {
	
	bootbox.prompt("Enter state name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("state name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_mad_flow_state";
				var div_id="NONE";
				var par1=""+flow_id;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
	});
	
}


//**************************************************
function addNewMadFlowStateAction(flow_state_id) {
	
	bootbox.prompt("Enter action name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("action name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_mad_flow_state_action";
				var div_id="NONE";
				
				var par1=flow_state_id;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
	});
	
	
}

//**************************************************
function makeMadPlatformTypeList() {
	
	var action="make_mad_platform_type_list";
	var div_id="colPlatformTypesBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadPlatformList() {
	
	var action="make_mad_platform_list";
	var div_id="colPlatformsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadPlatformEditor(platform_id) {
	
	var action="make_mad_platform_editor";
	var div_id="colPlatformContent_"+platform_id+"Body";
	var par1=platform_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadRepositoryList() {
	
	var action="make_mad_repository_list";
	var div_id="colRepositoriesBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadStringList() {
	
	var action="make_mad_string_list";
	var div_id="colStringsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadLangList() {
	
	var action="make_mad_lang_list";
	var div_id="colLangsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadClassList() {
	
	var action="make_mad_class_list";
	var div_id="colClassesBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadDriverList() {
	
	var action="make_mad_driver_list";
	var div_id="colDriversBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadModifierGroupList() {
	
	var action="make_mad_modifier_group_list";
	var div_id="colModifierGroupsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadModifierRuleList(modifier_group_id) {
	
	var action="make_mad_modifier_rule_list";
	var div_id="colModifierGroupContent_"+modifier_group_id+"Body";
	var par1=modifier_group_id;	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadModifierRuleEditor(modifier_rule_id) {
	
	var action="make_mad_modifier_rule_editor";
	var div_id="colModifierRuleContent_"+modifier_rule_id+"Body";
	var par1=modifier_rule_id;	

	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadFlexFieldList() {
	
	var action="make_mad_flex_field_list";
	var div_id="colFlexFieldsBody";
	var par1="x";	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadFlexFieldEditor(flex_field_id) {
	
	var action="make_mad_flex_field_editor";
	var div_id="colFlexFieldContent_"+flex_field_id+"Body";
	var par1=flex_field_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadRequestTypeList() {
	
	var action="make_mad_request_type_list";
	var div_id="colRequestTypesBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadEnvironmentList() {
	
	var action="make_mad_environment_list";
	var div_id="colEnvironmentsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadApplicationList() {
	
	var action="make_mad_application_list";
	var div_id="colApplicationsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadPermissionList() {
	
	var action="make_mad_permission_list";
	var div_id="colPermissionsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadMethodList() {
	
	var action="make_mad_method_list";
	var div_id="colMethodsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadFlowList() {
	
	var action="make_mad_flow_list";
	var div_id="colFlowsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}





//**************************************************
function makeMadDeploymentSlotList() {
	
	var action="make_mad_deployment_slot_list";
	var div_id="colDeploymentSlotsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadDashSqlList() {
	
	var action="make_mad_dashboard_sql_list";
	var div_id="colDashSqlsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadDashParameterList() {
	
	var action="make_mad_dashboard_parameter_list";
	var div_id="colDashParametersBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadDashViewList() {
	
	var action="make_mad_dashboard_view_list";
	var div_id="colDashViewsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadDashViewList() {
	
	var action="make_mad_dashboard_view_list";
	var div_id="colDashViewsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadDeploymentSlotDetailList(slot_id) {
	
	var action="make_mad_deployment_slot_detail_list";
	var div_id="slotDetailDiv"+slot_id;
	var par1=slot_id;	 
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadFlowStateList(flow_id) {
	
	var action="make_mad_flow_state_list";
	var div_id="flow_state_list_div_"+flow_id;
	var par1=""+flow_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}
//**************************************************
function makeMadFlowStateActionList(flow_state_id) {
	
	var action="make_mad_flow_state_action_list";
	var div_id="colFlowStateActions_"+flow_state_id+"Body";
	var par1=""+flow_state_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadUserList() {
	
	var action="make_mad_user_list";
	var div_id="colUsersBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadGroupList() {
	
	var action="make_mad_group_list";
	var div_id="colGroupsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadEmailTemplateList() {
	
	var action="make_mad_email_template_list";
	var div_id="colEmailTemplatesBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadApplicationEditor(application_id) {
	
	var action="make_mad_application_editor";
	var div_id="colAppContent_"+application_id+"Body";
	var par1=""+application_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadPermissionEditor(permission_id) {
	
	var action="make_mad_permission_editor";
	var div_id="colPermissionContent_"+permission_id+"Body";
	var par1=""+permission_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadMethodEditor(method_id) {
	
	var action="make_mad_method_editor";
	var div_id="colMethodContent_"+method_id+"Body";
	var par1=""+method_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadFlowEditor(flow_id) {
	
	var action="make_mad_flow_editor";
	var div_id="colFlowContent_"+flow_id+"Body";
	var par1=""+flow_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadDeploymentSlotEditor(slot_id) {
	
	var action="make_mad_deployment_slot_editor";
	var div_id="colDeploymentSlotContent_"+slot_id+"Body";
	var par1=""+slot_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadDashSqlEditor(sql_id) {
	
	var action="make_mad_dashboard_sql_editor";
	var div_id="colDashSqlContent_"+sql_id+"Body";
	var par1=""+sql_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadDashParameterEditor(parameter_id) {
	
	var action="make_mad_dashboard_parameter_editor";
	var div_id="colDashSqlContent_"+parameter_id+"Body";
	var par1=""+parameter_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadDashViewEditor(view_id) {
	
	var action="make_mad_dashboard_view_editor";
	var div_id="colDashViewContent_"+view_id+"Body";
	var par1=""+view_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMadFlowStateEditor(flow_id, state_id) {
	
	var action="make_mad_flow_state_editor";
	var div_id="flow_state_editor_div_"+flow_id;
	var par1=""+flow_id;	
	var par2=""+state_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**************************************************
function makeMadUserEditor(cuser_id) {
	
	var action="make_mad_user_editor";
	var div_id="colUserContent_"+cuser_id+"Body";
	var par1=""+cuser_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadGroupEditor(group_id) {
	
	var action="make_mad_group_editor";
	var div_id="colGroupContent_"+group_id+"Body";
	var par1=""+group_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function saveMadRequestFlowLogField(el, request_flow_log_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_request_flow_log_field";
	var div_id="NONE";
	var par1=""+request_flow_log_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}


//**************************************************
function saveMadFlexFieldByFieldID(fieldId, flex_field_id) {
	var obj=document.getElementById(fieldId+"_"+flex_field_id);
	if (!obj) {
		console.log("Flex field field not found : " + fieldId +" for id  : " + flex_field_id);
		return;
	}
	//saveMadFlexField(obj, flex_field_id);
	
	var field_name=fieldId;
	var field_value=obj.value;
	
	var action="update_flex_field";
	var div_id="NONE";
	var par1=""+flex_field_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//**************************************************
function saveMadFlexField(el, flex_field_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_flex_field";
	var div_id="NONE";
	var par1=""+flex_field_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadRequestTypeField(el, request_type_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_request_type_field";
	var div_id="NONE";
	var par1=""+request_type_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadPlatformTypeModifierGroupField(el, platform_type_modifier_group_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;

	
	var action="update_platform_type_modifier_group_id_field";
	var div_id="NONE";
	var par1=""+platform_type_modifier_group_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadPlatformTypeField(el, platform_type_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_platform_type_field";
	var div_id="NONE";
	var par1=""+platform_type_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadPlatformField(el, platform_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_platform_field";
	var div_id="NONE";
	var par1=""+platform_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadRepositoryField(el, repository_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_repository_field";
	var div_id="NONE";
	var par1=""+repository_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveMadStringField(el, string_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_string_field";
	var div_id="NONE";
	var par1=""+string_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveMadLangField(el, lang_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_lang_field";
	var div_id="NONE";
	var par1=""+lang_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadClassField(el, class_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_class_field";
	var div_id="NONE";
	var par1=""+class_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadDriverField(el, driver_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_driver_field";
	var div_id="NONE";
	var par1=""+driver_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadModifierGroupField(el, modifier_group_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_modifier_group_field";
	var div_id="NONE";
	var par1=""+modifier_group_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadModifierRuleField(el, modifier_rule_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_modifier_rule_field";
	var div_id="NONE";
	var par1=""+modifier_rule_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadEnvironmentField(el, environment_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_environment_field";
	var div_id="NONE";
	var par1=""+environment_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadApplicationField(el, application_id) {
	var field_name=el.getAttribute('id');
	
	
	var field_value=el.value;
	
	
	
	
	var action="update_application_field";
	var div_id="NONE";
	var par1=""+application_id;	
	var par2=field_name;
	var par3=field_value;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadPermissionField(el, permission_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_permission_field";
	var div_id="NONE";
	var par1=""+permission_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadMethodField(el, method_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_method_field";
	var div_id="NONE";
	var par1=""+method_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadFlowStateActionMethodField(el, action_method_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_action_method_field";
	var div_id="NONE";
	var par1=""+action_method_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//***************************************************
function makeMethodParameterEditor(method_id) {
	var action="make_method_parameter_editor";
	var div_id="parameterListForMethod_"+method_id;
	var par1=""+method_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//**************************************************
function saveMadFlowField(el, flow_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_flow_field";
	var div_id="NONE";
	var par1=""+flow_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}



//**************************************************
function saveMadDeploymentSlotFieldById(field_name, slot_id) {
	
	
	var field_value=document.getElementById(field_name+"_"+slot_id).value;
	
	
	var action="update_deployment_slot_field";
	var div_id="NONE";
	var par1=""+slot_id;	
	var par2=field_name;
	var par3=field_value;
	
	console.log("selam" + field_value);
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveMadDeploymentSlotField(el, slot_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_deployment_slot_field";
	var div_id="NONE";
	var par1=""+slot_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveMadDashSqlField(el, sql_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_dashboard_sql_field";
	var div_id="NONE";
	var par1=""+sql_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveMadDashParameterField(el, parameter_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_dashboard_parameter_field";
	var div_id="NONE";
	var par1=""+parameter_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveMadDashViewField(el, view_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_dashboard_view_field";
	var div_id="NONE";
	var par1=""+view_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function changeDeploymentSlotDetail(obj,slot_id) {
	var val=obj.value;
	var state="UNSET";
	if (obj.checked) state="SET";
	
	var day_id="-1";
	var minute_id="-1";
	
	var arr=val.split("_");
	try{day_id=arr[0];} catch(err) {}
	try{minute_id=arr[1];} catch(err) {}
	
	
	var action="update_deployment_slot_detail_hourly";
	var div_id="NONE";
	var par1=""+slot_id;	
	var par2=day_id;
	var par3=minute_id;
	var par4=state;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	
}


//**************************************************
function changeDeploymentSlotDetailAll(obj,slot_id,time_id) {
	var val=obj.value;
	var state="UNSET";
	if (obj.checked) state="SET";
	
	
	
	var action="";
	var div_id="";
	var par1="";	
	var par2="";
	var par3="";
	var par4="";
	
	for (var d=0;d<7;d++) {
		
		var el=document.getElementById("ch_ts_item_"+slot_id+"_"+d+"_"+time_id);
		if (el) el.checked=obj.checked;
		
		if (d>0) {
			action=action+":::::";
			div_id=div_id+":::::";
			par1=par1+":::::";
			par2=par2+":::::";
			par3=par3+":::::";
			par4=par4+":::::";
		}
		
		
		
		action=action+"update_deployment_slot_detail_hourly";
		div_id=div_id+"NONE";
		par1=par1+slot_id;
		par2=par2+d;
		par3=par3+time_id;
		par4=par4+state;
	}
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	
}
//**************************************************
function saveMadFlowStateField(el, state_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_flow_state_field";
	var div_id="NONE";
	var par1=""+state_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveMadFlowStateActionField(el, action_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_flow_state_action_field";
	var div_id="NONE";
	var par1=""+action_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMadUserField(el, user_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_user_field";
	var div_id="NONE";
	var par1=""+user_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveMadGroupField(el, group_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_group_field";
	var div_id="NONE";
	var par1=""+group_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveMadEmailTemplateField(el, template_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_email_template_field";
	var div_id="NONE";
	var par1=""+template_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function deletePlatformTypeModifierGroup(platform_type_id,id) {
	
	bootbox.confirm("Are you sure to remove this modifier group from this  platform type?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_platform_type_modifier_group";
		var div_id="NONE";
		var par1=""+platform_type_id;
		var par2=""+id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
}

//**************************************************
function deleteMadFlexField(flex_field_id) {
	
	bootbox.confirm("Are you sure to remove this field?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_flex_field";
		var div_id="NONE";
		var par1=""+flex_field_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}

//**************************************************
function deleteMadRequestType(request_type_id) {
	
	bootbox.confirm("Are you sure to remove this request type?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_request_type";
		var div_id="NONE";
		var par1=""+request_type_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}

//**************************************************
function deleteMadPlatform(platform_id) {
	
	bootbox.confirm("Are you sure to remove this platform ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_platform";
		var div_id="NONE";
		var par1=""+platform_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}

//**************************************************
function deleteMadRepository(repository_id) {
	
	bootbox.confirm("Are you sure to remove this repository ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_repository";
		var div_id="NONE";
		var par1=""+repository_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}

//**************************************************
function deleteMadString(string_id) {
	
	bootbox.confirm("Are you sure to remove this string ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_string";
		var div_id="NONE";
		var par1=""+string_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}


//**************************************************
function deleteMadLang(lang_id) {
	
	bootbox.confirm("Are you sure to remove this language ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_lang";
		var div_id="NONE";
		var par1=""+lang_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}

//**************************************************
function deleteMadClass(class_id) {
	
	bootbox.confirm("Are you sure to remove this class ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_class";
		var div_id="NONE";
		var par1=""+class_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}
//**************************************************
function deleteMadDriver(driver_id) {
	
	bootbox.confirm("Are you sure to remove this driver ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_driver";
		var div_id="NONE";
		var par1=""+driver_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}
//**************************************************
function deleteMadModifierGroup(modifier_group_id) {
	
	bootbox.confirm("Are you sure to remove this modifier group ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_modifier_group";
		var div_id="NONE";
		var par1=""+modifier_group_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}

//**************************************************
function deleteMadModifierRule(modifier_group_id, modifier_rule_id) {
	
	bootbox.confirm("Are you sure to remove this rule ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_modifier_rule";
		var div_id="NONE";
		var par1=""+modifier_group_id;
		var par2=""+modifier_rule_id;
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
}
//**************************************************
function deleteMadPlatformType(platform_type_id) {
	
	bootbox.confirm("Are you sure to remove this platform type?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_platform_type";
		var div_id="NONE";
		var par1=""+platform_type_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}

//**************************************************
function deleteMadEnvironment(environment_id) {
	
	bootbox.confirm("Are you sure to remove this environment?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_environment";
		var div_id="NONE";
		var par1=""+environment_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	
}
//**************************************************
function deleteMadApplication(application_id) {
	
	bootbox.confirm("Are you sure to remove this application?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_application";
		var div_id="NONE";
		var par1=""+application_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}

//**************************************************
function deleteMadPermission(permission_id) {
	
	bootbox.confirm("Are you sure to remove this permission?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_permission";
		var div_id="NONE";
		var par1=""+permission_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}


//**************************************************
function deleteMadMethod(method_id) {
	
	bootbox.confirm("Are you sure to remove this method?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_method";
		var div_id="NONE";
		var par1=""+method_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}


//**************************************************
function deleteMadFlow(flow_id) {
	
	bootbox.confirm("Are you sure to remove this flow?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_flow";
		var div_id="NONE";
		var par1=""+flow_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}


//**************************************************
function deleteMadDeploymentSlot(slot_id) {
	
	bootbox.confirm("Are you sure to remove this slot?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_deployment_slot";
		var div_id="NONE";
		var par1=""+slot_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}

//**************************************************
function deleteMadDashSql(sql_id) {
	
	bootbox.confirm("Are you sure to remove this sql?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_dashboard_sql";
		var div_id="NONE";
		var par1=""+sql_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}

//**************************************************
function deleteMadDashParameter(parameter_id) {
	
	bootbox.confirm("Are you sure to remove this filter?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_dashboard_parameter";
		var div_id="NONE";
		var par1=""+parameter_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}


//**************************************************
function deleteMadDashView(view_id) {
	
	bootbox.confirm("Are you sure to remove this view?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_dashboard_view";
		var div_id="NONE";
		var par1=""+view_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}

//**************************************************
function deleteMadDashViewFilter(view_id, view_parameter_id) {
	
	bootbox.confirm("Are you sure to remove this filter?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_dashboard_view_parameter";
		var div_id="NONE";
		var par1=""+view_id;	
		var par2=""+view_parameter_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
});
	
	 
}
//**************************************************
function deleteMadFlowState(flow_id, flow_state_id) {
	
	bootbox.confirm("Are you sure to remove this state?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_flow_state";
		var div_id="NONE";
		var par1=""+flow_id;
		var par2=""+flow_state_id;
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
});
	
	 
}

//**************************************************
function makeMadFieldSettingForm(request_type_id) {

	var action="make_mad_flow_field_setting_form";
	var div_id="fieldSettingsBody";
	var par1=""+request_type_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("fieldSettingsDiv");
	
	
}
//**************************************************
function setMadFlowStateFieldOverride(obj,flow_state_id,permission_id,flex_field_id) {

	var override_key=obj.id;
	var request_type_id=document.getElementById("overriding_request_type_id").value;
	
	var action="set_mad_flow_state_field_override";
	var div_id="divOv_"+flow_state_id+"_"+flex_field_id+"_"+permission_id+"_"+override_key;
	var par1=""+request_type_id;
	var par2=""+flow_state_id;
	var par3=""+permission_id;
	var par4=""+flex_field_id;
	var par5=""+override_key;
	
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
}
//**************************************************
function deleteMadFlowStateAction(flow_state_id, action_id) {
	
	bootbox.confirm("Are you sure to remove this action?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_flow_state_action";
		var div_id="NONE";
		var par1=""+action_id;	
		var par2=""+flow_state_id;
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
});
	
	 
}

//**************************************************
function removeMadFlowStateActionMethod(action_id, action_method_id) {
	
	bootbox.confirm("Are you sure to remove this method from execution list?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_flow_state_action_method";
		var div_id="NONE";
		var par1=""+action_id;	
		var par2=""+action_method_id;
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
});
	
	 
}



//-----------------------------------------------------------------------------
function makeFlowStateActionMethodParameterModal() {
	
	var el=document.getElementById("flowStateModalParamDiv");

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"flowStateModalParamDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-lg\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"			 	 <div class=\"modal-body\" id=\"flowStateModalParamBody\"  style=\"min-height: 0px; max-height: 480px; overflow-x: scroll; overflow-y: scroll;\"> \n" +
	"			        <div id=viewExecuteBody></div> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		        	<button type=\"button\" class=\"btn btn-warning\" id=bt_test_module onclick=\"testActionMethod();\"><span class=\"glyphicon glyphicon-play\"></span> Test</button>\n" +
	"		      	</div> \n"+
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
	
	
	
}


//**************************************************
function setMadFlowStateActionMethodParameters(action_method_id) {
	makeFlowStateActionMethodParameterModal();
	
	clearDivContent("flowStateModalParamBody");
	
	$("#flowStateModalParamDiv").modal();
	
	var action="make_flow_state_action_method_parameter_editor";
	var div_id="flowStateModalParamBody";
	var par1=""+action_method_id;	
	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function testActionMethod() {
	
	var editing_method_id=document.getElementById("editing_method_id").value;
	var editing_action_method_id=document.getElementById("editing_action_method_id").value;
	
	testMadMethod(editing_method_id, editing_action_method_id);
}

//**************************************************
function deleteMadUser(user_id) {
	
	bootbox.confirm("Are you sure to remove this user?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_user";
		var div_id="NONE";
		var par1=""+user_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}

//**************************************************
function deleteMadGroup(group_id) {
	
	bootbox.confirm("Are you sure to remove this group?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_group";
		var div_id="NONE";
		var par1=""+group_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}

//**************************************************
function deleteMadEmailTemplate(email_template_id) {
	
	bootbox.confirm("Are you sure to remove this template?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_mad_email_template";
		var div_id="NONE";
		var par1=""+email_template_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}


//**************************************************
function saveMadFlexFieldTableById(fieldName,el_id, parent_table, application_id, id) {
	
	var field_name=fieldName;
	var field_value=document.getElementById(el_id).value;
	
	
	var action="update_table_flex_field";
	var div_id="NONE";
	var par1=parent_table;
	var par2=""+application_id;	
	var par3=""+id;	
	var par4=field_name;
	var par5=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
}

//**************************************************
function saveMadFlexFieldTable(el, parent_table, application_id, id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_table_flex_field";
	var div_id="NONE";
	var par1=parent_table;
	var par2=""+application_id;	
	var par3=""+id;	
	var par4=field_name;
	var par5=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
}


//**************************************************
function addRemovePlatformEnv(environment_id, action_and_id, platform_type_id) {
	var action="add_remove_platform_environment";
	var div_id="NONE";
	var par1=""+environment_id;	
	var par2=""+action_and_id;
	var par3=""+platform_type_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//**************************************************
function addRemoveGroupMember(group_id, action_and_id, member_type) {
	var action="add_remove_group_member";
	var div_id="NONE";
	var par1=""+group_id;	
	var par2=""+action_and_id;
	var par3=""+member_type;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//**************************************************
function addRemoveUserMembership(user_id, action_and_id) {
	var action="add_remove_user_membership";
	var div_id="NONE";
	var par1=""+user_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}


//**************************************************
function addRemoveRequestTypeApplication(request_type_id, action_and_id) {
	var action="add_remove_request_type_application";
	var div_id="NONE";
	var par1=""+request_type_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**************************************************
function addRemoveRequestTypeEnvironment(request_type_id, action_and_id) {
	var action="add_remove_request_type_environment";
	var div_id="NONE";
	var par1=""+request_type_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}
//**************************************************
function addRemoveDependedApplication(application_id, action_and_id) {
	var action="add_remove_depended_applicaion";
	var div_id="NONE";
	var par1=""+application_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**************************************************
function addRemoveGroupPermission(group_id, action_and_id) {
	var action="add_remove_group_permission";
	var div_id="NONE";
	var par1=""+group_id;	
	var par2=""+action_and_id;
	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}
//**************************************************
function addRemoveStateEditPermission(flow_state_id, action_and_id) {
	var action="add_remove_state_edit_permission";
	var div_id="NONE";
	var par1=""+flow_state_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}
//**************************************************
function addRemoveActionPermission(action_id, action_and_id) {
	var action="add_remove_action_permission";
	var div_id="NONE";
	var par1=""+action_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}
//**************************************************
function addRemovePermissionGroup(permission_id, action_and_id) {
	var action="add_remove_permission_group";
	var div_id="NONE";
	var par1=""+permission_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}
//**************************************************
function addRemoveNotificationGroup(action_id, action_and_id) {
	var action="add_remove_action_group";
	var div_id="NONE";
	var par1=""+action_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}
//**************************************************
function addRemoveUserRole(user_id, action_and_id) {
	var action="add_remove_user_role";
	var div_id="NONE";
	var par1=""+user_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**************************************************
function addRemoveRequestApplication(request_id, action_and_id) {
	var action="add_remove_request_application";
	var div_id="NONE";
	var par1=""+request_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**************************************************
function setMadUserPassword(user_id) {
	var action="make_user_set_password";
	var div_id="setPasswordBody";
	var par1=""+user_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("setPasswordDiv");
}

//**************************************************
function setPassword() {
	var el=document.getElementById("password_user_id");
	if (!el) return;
	var user_id=el.value;
	
	var password_1=document.getElementById("password_field_1").value;
	var password_2=document.getElementById("password_field_2").value;
	
	if (password_1.length<6) {
		myalert("password must be at least 6 chars length.");
		return;
	}
	
	if (password_2!=password_1) {
		myalert("Passwords entered does not match");
		return;
		
	}
	
	
	var action="set_user_password";
	var div_id="NONE";
	var par1=""+user_id;	
	var par2=""+password_1;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#setPasswordDiv").modal("hide");
	
}
//**************************************************
function makeMadEvironmentEditor(environment_id,active_platform_type_id) {
	var action="make_mad_environment_editor";
	var div_id="NOFADE_colEnvPlat_"+environment_id+"Body";
	var par1=""+environment_id;	
	var par2=""+active_platform_type_id;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//****************************************************
function testFlexFieldRegex(id) {
	var el=document.getElementById("entry_validation_regex_tester_"+id);
	if (!el) return;
	var val=el.value;
	var color="red";
	
	try {
		var regexEl=document.getElementsByName("entry_validation_regex_"+id)[0];
		var regex_stmt=regexEl.value;
		var is_ok=testRegex(val, regex_stmt);
		if (is_ok) color="lightgreen";
	} catch (err) {
		color="red";
	}
	
	el.style.backgroundColor=color;
	
	var action="set_session_attribute";
	var div_id="NONE";
	var par1="entry_validation_regex_tester_"+id;	
	var par2=""+val;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}

//***********************************************
function openMultipleFlexFieldEditor(flex_field_id, platform_type_id) {

	
	var action="open_multiple_flex_field_editor";
	var div_id="flexFieldEditorBody";
	var par1=flex_field_id;
	var par2=platform_type_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("flexFieldEditorDiv");
}

//**************************************************
function saveMultiplePlatformFlexField(id,new_val) {
	
	var action="save_multiple_platform_field";
	var div_id="NONE";
	var par1=""+id;
	var par2=new_val;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("flexFieldEditorDiv");
}

//**************************************************
function onTagSearchEnter(event) {

	if (event.which == 13 || event.keyCode == 13) {
			performTagSearch();
	        return false;
	    }
	 return true;
}

//****************************************************
function performTagSearch() {
	var el=document.getElementById("tag_search_box");
	if (!el) return;
	
	var search_val=el.value;
	
	var application_id=document.getElementById("tag_search_application_id").value;
	var member_id=document.getElementById("tag_search_member_id").value;
	var current_tag=document.getElementById("tag_search_current_tag").value;
	
	var action="search_tag_list";
	var div_id="tagListSearchDiv";
	var par1=""+application_id;
	var par2=""+member_id;
	var par3=""+current_tag;
	var par4=search_val;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	
	
}

//**************************************************
function filterLovOnEnter(event) {

	if (event.which == 13 || event.keyCode == 13) {
		 filterLov(false);
	        return false;
	    }
	 return true;
}

//**************************************************
function filterLov(to_refresh) {
	var lov_type=document.getElementById("lov_type").value;
	var curr_value=document.getElementById("lov_selected_value").value;
	var entered_filter=document.getElementById("filter_lov_box").value;
	var lov_parameters=document.getElementById("lov_parameters").value;
	
	
	var action="set_lov_filter";
	var div_id="lovListItemsDiv";
	var par1=lov_type;
	var par2=curr_value;
	var par3=entered_filter;
	var par4=lov_parameters;
	var par5="NO";
	
	
	if (par3=="") par3="${null}"
	if (to_refresh) par5="YES";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
}

//**************************************************
function onConfigSearchEnterFlexFields(event) {
	 if (event.which == 13 || event.keyCode == 13) {
		 	configSearchFlexFields();
	        return false;
	    }
	 return true;
}

//**************************************************
function onConfigSearchUsers(event) {
	 if (event.which == 13 || event.keyCode == 13) {
		 	configSearchUsers();
	        return false;
	    }
	 return true;
}

//**************************************************
function onConfigSearchEnterStrings(event) {
	 if (event.which == 13 || event.keyCode == 13) {
		 	configSearchStrings();
	        return false;
	    }
	 return true;
}

//**************************************************
function configSearchFlexFields() {
	 var el=document.getElementById("search_for_flexible_fields");
	 if (!el) return;
	 
	 var search_value=el.value;


 	var action="search_mad_configuration";
	var div_id="colFlexFieldsBody";
	var par1=""+"flexible_fields";
	var par2=""+search_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	 
}

//**************************************************
function configSearchUsers() {
	 var el=document.getElementById("search_for_users");
	 if (!el) return;
	 
	 var search_value=el.value;


 	var action="search_mad_configuration";
	var div_id="colUsersBody";
	var par1=""+"users";
	var par2=""+search_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	 
}

//**************************************************
function configSearchStrings() {
	 var el=document.getElementById("search_for_strings");
	 if (!el) return;
	 
	 var search_value=el.value;


 	var action="search_mad_configuration";
	var div_id="colStringsBody";
	var par1=""+"strings";
	var par2=""+search_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	 
}


//****************************************************
function makeRouteRequestModal() {
	 
	var el=document.getElementById("routeRequestDiv");
	//if (el) $("#routeRequestDiv").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-md\" id=\"routeRequestDiv\" data-keyboard=\"false\" data-backdrop=\"static\"style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-md\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"		 		<div class=\"modal-header\" id=taskHeader> \n"+
	"		 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n"+
	"		 				<span aria-hidden=\"true\">&times;</span> \n"+
	"		 				<span class=\"sr-only\">Close</span> \n"+
	"		 			</button> \n"+
	"		 		</div> <!--  modal header --> \n"+
	"			 	 <div class=\"modal-body\" id=\"routeRequestBody\"  style=\"min-height: 0px; max-height: 400px; overflow-x: scroll; overflow-y: scroll;\"> \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		        	<button type=\"button\" class=\"btn btn-success\" id=btroute onclick=\"sendRoute();\">Route</button> \n"+
	"		      	</div> \n"+
	"	      	 \n"+
	"		 	</div> <!--  modal content -->  \n"+
	"		</div> <!--  modal dialog --> \n"+
	"	</div> <!--  modal fade --> ";

	$('body').append(modal_html);
	
	
}

//****************************************************
function routeRequest(request_id) {

	var request_type=document.getElementById("request_type_"+request_id).value;
	var request_description=document.getElementById("deployment_description_"+request_id).value;
	
	var is_form_ok=validateRequestFields(request_id, request_type,request_description,"ROUTE");
	
	if (!is_form_ok) return;
	
	makeRouteRequestModal();
	
	var action="show_route_menu";
	var div_id="routeRequestBody";
	var par1=""+request_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("routeRequestDiv");
}


//****************************************************
function makeRoutingLogsModal() {
	 
	var el=document.getElementById("logsRequesRouteDiv");
	//if (el) $("#logsRequesRouteDiv").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"logsRequesRouteDiv\" data-keyboard=\"false\" data-backdrop=\"static\"style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-lg\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"		 		<div class=\"modal-header\" id=taskHeader> \n"+
	"		 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n"+
	"		 				<span aria-hidden=\"true\">&times;</span> \n"+
	"		 				<span class=\"sr-only\">Close</span> \n"+
	"		 			</button> \n"+
	"		 		</div> <!--  modal header --> \n"+
	"			 	 <div class=\"modal-body\" id=\"logsRequesRouteBody\"  style=\"min-height: 0px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;\"> \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"	      	 \n"+
	"		 	</div> <!--  modal content -->	 \n"+
	"		</div> <!--  modal dialog --> \n"+
	"	</div> <!--  modal fade -->";

	$('body').append(modal_html);
	
	
}




//****************************************************
function makeChangeLogsModal() {
	 
	var el=document.getElementById("logsRequesChangeDiv");
	//if (el) $("#logsRequesRouteDiv").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"logsRequesChangeDiv\" data-keyboard=\"false\" data-backdrop=\"static\"style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-lg\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"		 		<div class=\"modal-header\" id=taskHeader> \n"+
	"		 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n"+
	"		 				<span aria-hidden=\"true\">&times;</span> \n"+
	"		 				<span class=\"sr-only\">Close</span> \n"+
	"		 			</button> \n"+
	"		 		</div> <!--  modal header --> \n"+
	"			 	 <div class=\"modal-body\" id=\"logsRequesChangeBody\"  style=\"min-height: 0px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;\"> \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"	      	 \n"+
	"		 	</div> <!--  modal content -->	 \n"+
	"		</div> <!--  modal dialog --> \n"+
	"	</div> <!--  modal fade -->";

	$('body').append(modal_html);
	
	
}

//****************************************************
function showRoutingLogs(request_id) {

	makeRoutingLogsModal();
	
	var action="show_route_logs";
	var div_id="logsRequesRouteBody";
	var par1=""+request_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("logsRequesRouteDiv");
	
}


//****************************************************
function showChangeLogs(request_id) {

	makeChangeLogsModal();
	
	var action="show_change_logs";
	var div_id="logsRequesChangeBody";
	var par1=""+request_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("logsRequesChangeDiv");
	
}

//****************************************************
function sendRoute() {
	var el=document.getElementById("routing_request_id");
	if (!el) {
		console.log("No routing request found");
		myalert("No Action to take.");
		return;
	}
	
	var routing_request_id=el.value;
	var new_action="";
	var action_memo="";
	
	el=document.getElementById("flow_state_action_id");
	
	if (el) new_action=el.value;
	
	if (new_action=="") {
		myalert("Please select an action to proceed.");
		return;
	}
	
	el=document.getElementById("action_note");
	
	if (el) action_memo=el.value;
	
	if (action_memo=="") {
		myalert("Please enter action note to proceed.");
		return;
	}

	
	/*
	var spent_hour=parseInt(document.getElementById("time_spent_hour").value);
	var spent_min=parseInt(document.getElementById("time_spent_minute").value);
	var time_spent=spent_hour*60+spent_min;
	*/
	var time_spent=0;
	
	showWaitingModal();

	var action="route_request";
	var div_id="NONE";
	var par1=""+routing_request_id;
	var par2=new_action;
	var par3=action_memo;
	var par4=""+time_spent;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	
	$("#routeRequestDiv").modal("hide");
	
	//showWaitingModal();
	
}




//*******************************************************************
function showNotificationParams() {
	
	var action="show_notification_parameters";
	var div_id="notificationParamsBody";
	var par1="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("notificationParamsDiv");
	
}




function makeDeploymentProgressModal() {
	 
	var el=document.getElementById("deploymentProgressDiv");
	//if (el)  $("#deploymentProgressDiv").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"deploymentProgressDiv\" data-keyboard=\"false\" data-backdrop=\"static\"  style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-lg\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"		 		<div class=\"modal-header\" id=taskHeader> \n"+
	"		 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n"+
	"		 				<span aria-hidden=\"true\">&times;</span> \n"+
	"		 				<span class=\"sr-only\">Close</span> \n"+
	"		 			</button> \n"+
	"		 		</div> <!--  modal header --> \n"+
	"			 	 <div class=\"modal-body\" id=\"deploymentProgressBody\"  style=\"min-height: 0px; max-height: 400px; overflow-x: scroll; overflow-y: scroll;\"> \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content --> \n"+
	"		</div> <!--  modal dialog --> \n"+
	"	</div> <!--  modal fade -->";

	$('body').append(modal_html);
	
	
}

var maddeployprogressinterval;


//*******************************************************************
function showMadDeployProgress(request_id) {

	makeDeploymentProgressModal();
	
	var current_deployment_work_plan_id="0";
	
	try {current_deployment_work_plan_id=document.getElementById("request_work_plans").value;}
	catch(err) {current_deployment_work_plan_id="0";}
	
	var action="show_mad_deploy_progress";
	var div_id="deploymentProgressBody";
	var par1=""+request_id;
	var par2=""+current_deployment_work_plan_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("deploymentProgressDiv");
	
	if(maddeployprogressinterval) clearInterval(maddeployprogressinterval);
	
	maddeployprogressinterval=setInterval(function () {writeMadDeployWPLInfo('TIMER');}, 5000);
	
}




//*******************************************************************
function writeMadDeployWPLInfo(origin) {
	var el=document.getElementById("request_work_plans");
	if (!el) return;
	var work_plan_id=el.value;
	
	if (origin=="TIMER") {
		var ch=document.getElementById("check_auto_refresh_deploy_info").checked;
		if (!ch) return;
	}
	
	var work_plan_request_id=document.getElementById("work_plan_request_id").value;
	
	
	
	var action="write_mad_deployment_wpl_info";
	var div_id="NOFADE_deploymentWPLInfoDiv";
	var par1=""+work_plan_id;
	var par2=""+work_plan_request_id;

	
	var eldiv=document.getElementById("deploymentProgressDiv");
	var divdisplay=eldiv.style.display;
	if (divdisplay!="block") clearInterval(maddeployprogressinterval);
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}


function makeWorkPackageErrInfoModal() {
	 
	var el=document.getElementById("taskDiv");
	//if (el) $("#taskDiv").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"taskDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-lg\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"		 		<div class=\"modal-header\" id=taskHeader> \n"+
	"		 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n"+
	"		 				<span aria-hidden=\"true\">&times;</span> \n"+
	"		 				<span class=\"sr-only\">Close</span> \n"+
	"		 			</button> \n"+
	"		 		</div> <!--  modal header --> \n"+
	"			 	 <div class=\"modal-body\" id=\"div_task_info\"  style=\"min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;\"> \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"		 	</div> <!--  modal content -->	\n"+
	"		</div> <!--  modal dialog --> \n"+
	"	</div> <!--  modal fade -->";

	$('body').append(modal_html);
	
	
}

//***********************************************************************
function showWorkPackageErrInfo(rec_id, rec_type, field) {
	
	makeWorkPackageErrInfoModal();
	
	var action="get_long_detail";
	var div_id="div_task_info";
	var par1=rec_id;
	var par2=rec_type;
	var par3=rec_id;
	var par4=field;

	showModal("taskDiv");
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}

//*********************************************************************
function setMadMemberSkip(request_id, req_app_member_id,skip_status) {
	
	if (skip_status=="NO") {
		setMadMemberSkipDo(request_id, req_app_member_id,skip_status, '');
		return;
	}
	
	
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Skip Reason";
	var par2="skip_reason";
	var par3="x";
	var par4="x";
	var par5="setMadMemberSkipDo('"+request_id+"','"+req_app_member_id+"','"+skip_status+"','#')";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
	
	
	
}

//*********************************************************************
function setMadMemberSkipDo(request_id, req_app_member_id,skip_status, skip_reason) {
	
	
	var action="set_req_app_member_skip";
	var div_id="NONE";
	var par1=""+request_id;
	var par2=""+req_app_member_id;
	var par3=""+skip_status;
	var par4=""+skip_reason;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}

//*********************************************************************
function setMadPlatformSkip(request_id, platform_id,chobj) {

	var skip_status="NO";
	if (!chobj.checked) skip_status="YES";
	
	var action="set_req_platform_skip";
	var div_id="NONE";
	var par1=""+request_id;
	var par2=""+platform_id;
	var par3=skip_status;
	
	
	if (skip_status=="YES") {
		bootbox.confirm("Are you sure to exclude this platform from deployment ?", function(result) {
			
			if(!result) {
				chobj.checked=true;
				return;
			}
			
			ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
		});
	} 
	else ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
	
}

//******************************************************************************
function setMadRequestEnvFieldValue(request_id ,platform_id, application_id, flex_field_id, new_val) {

	
	var action="set_platform_parameter";
	var div_id="NONE";
	var par1=""+request_id;
	var par2=""+platform_id;
	var par3=""+application_id;
	var par4=""+flex_field_id;
	var par5=""+new_val;


	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
}

//******************************************************************************
function makeMadFlowDrawing(flow_id) {
	
	var inner_div=document.getElementById("flowDrawInnerBody_Flow"+flow_id).innerHTML;
	if (inner_div.length>10) {
		clearDivContent("flowDrawInnerBody_Flow"+flow_id);
		return;
	} 
	
	var action="get_mad_flow_info";
	var div_id="NONE";
	var par1=""+flow_id;


	ajaxDynamicComponentCaller(action, div_id, par1);
}


//******************************************************************************
function makeMadFlowDrawingForRequest(flow_id, request_id) {
	
	
	clearDivContent("RequestFlowDiv");

	var action="get_mad_flow_info_for_request";
	var div_id="NONE";
	var par1=""+flow_id;
	var par2=""+request_id;


	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}



//******************************************************************************
function remakeMadFlowDrawing(flow_id) {
	
	var inner_div=document.getElementById("flowDrawInnerBody_Flow"+flow_id).innerHTML;
	if (inner_div.length<10)  return;


	var action="get_mad_flow_info";
	var div_id="NONE";
	var par1=""+flow_id;


	ajaxDynamicComponentCaller(action, div_id, par1);
	
}






//******************************************************************************
function drawMadFlow(paper_div, flow_id, flow_info,request_id) {

	var states=[];
	var arrstates=flow_info.split(";");
	
	for (var i=0;i<arrstates.length;i++) {
		var state_info=arrstates[i];
		states[states.length]=state_info;
	}
	
	var elcount=states.length;
	var elwidth=150;
	var boxwidth=140;
	var boxheight=52;
	var paper_width=5000;
	var paper_height=600;
		
	var graph = new joint.dia.Graph;
	clearDivContent(paper_div);
	var paper = new joint.dia.Paper({
		el: $('#'+paper_div),
		width: paper_width,
		height: paper_height,
		model: graph,
		gridSize: 1
	});
	
	var recArr=[];
	var rectIdArr =[];
	
	
	
	for (var i=0;i<states.length;i++) {
		var a_state=states[i];
		var arr = a_state.split(",");
		var state_id=arr[0];
		var state_name=arr[1];
		var state_title=arr[2];
		var state_status=arr[3];
		var state_loc_info=arr[4];
		
		var state_status_count="0";
		var starr=state_status.split(":");
		
		try{state_status=starr[0];} catch(err) {};
		try{state_status_count=starr[1];} catch(err) {};
		
		if (!state_status_count) state_status_count="0";
		
		if (state_status_count!="0" && state_status_count!="1") state_title=state_title +" ["+state_status_count+"]";
		
		var box_no=1;
		var box_count_in_row=1;
		
		var box_pos_x=elwidth*(i)+boxwidth/2;
		var box_pos_y=(paper_height/box_count_in_row)/2-(box_no)*(boxheight/2);
		
		var arrloc=state_loc_info.split(":");
		var state_saved_loc_x=parseInt(arrloc[0]);
		var state_saved_loc_y=parseInt(arrloc[1]);
		
		if (state_saved_loc_x>-1 && state_saved_loc_y>-1)  {
			box_pos_x=state_saved_loc_x;
			box_pos_y=state_saved_loc_y;
		}
			
		
		var box_fill="blue";
		if (state_status=="OPEN") box_fill="red";
		if (state_status=="CLOSED") box_fill="black";
		
		var rect = new joint.shapes.basic.Rect({
			name : state_name,
			position: { x: box_pos_x, y: box_pos_y },
			size: { width: boxwidth, height: boxheight },
			attrs: { rect: { fill: box_fill }, 
				text: { text: state_title, fill: 'white', 'font-size': 12, 'font-weight': 'bold', 'font-variant': 'small-caps' } }
		});
				
		if (request_id=="0") {
			rect.on('change:position', function(element) {
				saveFlowBoxLocationTimer(flow_id, element.get('name'), element.get('position'));
			});
		}  else {
			console.log("skippppp.");
		}
		
		
		recArr[recArr.length]=rect;
		rectIdArr[state_name]=rect.id;

	}
	

	graph.addCells(recArr);
	
	
	var lnkArr=[];
	
	for (var i=0;i<states.length;i++) {
		var a_state=states[i];
		var arr = a_state.split(",");
		var state_name=arr[1];
		var next_actions=arr[5];
		//if (next_actions=="-" || next_actions=="")  continue;
		
		
		var arr2 = next_actions.split("+");
		
		for (var a=0;a<arr2.length;a++) {
			var next_action=arr2[a];
			if (next_action=="") continue;

			var arr3 = next_action.split(":");
			var action_title=arr3[0];
			var next_action_state=arr3[1];
			var action_status=arr3[2];
			
			
			//var stroke_color='#3498DB';
			var stroke_color='black';
			var stroke_dash_array='5 5';
			var stroke_width=3;
			
			if (action_status=="CLOSED") {
				stroke_color='yellow';
				stroke_dash_array='1 1';
				stroke_width=5;
			}
			
			var id_from="";
			var id_to="";
			
			try {id_from=rectIdArr[state_name]; } catch(err) {console.log("err1");}
			try {id_to=rectIdArr[next_action_state]; } catch(err) {console.log("err2");}
			
			if (id_from!="" && id_to!="" && id_from!="undefined" && id_to!="undefined" )  {
				
				//console.log("linking " + state_name + " to " + action_state);
				var link = new joint.dia.Link({
					attrs: { 
							'.connection' : { stroke: stroke_color, 'stroke-width': stroke_width, 'stroke-dasharray': stroke_dash_array },
							'.marker-target': { label: action_title, fill: 'black', d: 'M 10 0 L 0 5 L 10 10 z'} 
							},
					source: { id: id_from },
					target: { id: id_to },
					smooth: true,
					router: { name: 'orthogonal' },
				    connector: { name: 'rounded' },
					labels: [
					         { position: .2, attrs: { text: { text: action_title, fill: 'black', 'font-size': 10, 'font-family': 'sans-serif' }, rect: { stroke: '#D8D8D8', 'stroke-width': 15, rx: 5, ry: 5 } }}
					     ]
					});
		
				lnkArr[lnkArr.length]=link;
			}
			
		
		}
	
		

	}
	
	graph.addCells(lnkArr);
	
	
	
	
}

var setBoxLocationInterval;



//********************************************************
function saveFlowBoxLocationTimer(flow_id, saving_state, box_location) {


	var loc_x=""+box_location.x;
	var loc_y=""+box_location.y;

	clearTimeout(setBoxLocationInterval);
	setBoxLocationInterval=setTimeout(function () {
		saveFlowBoxLocation(flow_id, saving_state, loc_x, loc_y);
		}, 200);

}


//********************************************************
function saveFlowBoxLocation(flow_id, saving_state, loc_x, loc_y) {
	var action="save_mad_flow_box_location";
	var div_id="NONE";
	var par1=""+flow_id;
	var par2=""+saving_state;
	var par3=""+loc_x;
	var par4=""+loc_y;

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	


}


//***********************************************************
function onfileuploaded(event, data, previewId, index) {
	
	
	var form = data.form;
	var files = data.files;
	var extra = data.extra;
	var response = data.response;
	var reader = data.reader;
	
	
	console.log('File uploaded triggered');

}


function makeMonitoringGraphData() {
	
	var el=document.getElementById("detailed_work_plan_id");
	if (!el) {
		console.log("no work plan found...");
		return;
	}
	
	var detailed_work_plan_id=el.value;
	
	var action="make_work_plan_graph_data";
	var div_id="workPlanGraphDataDiv";
	var par1=""+detailed_work_plan_id;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//--------------------------------------------------------
function drawMonitoringGraphs() {
	
	var curr_exported_recs_in_k=0;
	var curr_masked_recs_in_k=0;
	
	var task_all_count=0;
	var task_new_count=0;
	var task_assigned_count=0;
	var task_running_count=0;
	var task_completed_count=0;
	var task_failed_count=0;
	var task_retry_count=0;
	
	try{curr_exported_recs_in_k=parseInt(document.getElementById("curr_exported_recs_in_k").value);} catch(err) {}
	try{curr_masked_recs_in_k=parseInt(document.getElementById("curr_masked_recs_in_k").value);} catch(err) {}

	try {
		drawSpeedGauge(curr_exported_recs_in_k, curr_masked_recs_in_k);
	} catch(err) {
		console.log("Error @drawSpeedGauge : " + err);
	}
	
	try{task_all_count=parseInt(document.getElementById("task_all_count").value);} catch(err) {}
	try{task_new_count=parseInt(document.getElementById("task_new_count").value);} catch(err) {}
	try{task_assigned_count=parseInt(document.getElementById("task_assigned_count").value);} catch(err) {}
	try{task_running_count=parseInt(document.getElementById("task_running_count").value);} catch(err) {}
	try{task_completed_count=parseInt(document.getElementById("task_completed_count").value);} catch(err) {}
	try{task_failed_count=parseInt(document.getElementById("task_failed_count").value);} catch(err) {}
	try{task_retry_count=parseInt(document.getElementById("task_retry_count").value);} catch(err) {}
	

	
	try {
		drawWorkerPieChart(
				task_all_count,
				task_new_count,
				task_assigned_count,
				task_running_count,
				task_completed_count,
				task_failed_count,
				task_retry_count);
	} catch(err) {
		console.log("Error @drawWorkerPieChart : " + err);
	}
	
	
	
	
}

//------------------------------------------------
function drawSpeedGauge( export_speed, mask_speed ) {
	
	
	var max_val=export_speed;
	if (mask_speed>max_val) max_val=export_speed;
	if (max_val<100) max_val=100;
	
	var plot_band1=max_val*2;
	var plot_band2=max_val*3;
	var plot_band3=max_val*4;
	
	 // Build the speed gauge
    $('#speedGraphDiv').highcharts({

        chart: {
            type: 'gauge',
            plotBackgroundColor: null,
            plotBackgroundImage: null,
            plotBorderWidth: 0,
            plotShadow: false,
            width: 250
        },

        title: {
            text: 'Speedometer',
            y:-1000 // to hide
        },

        pane: {
            startAngle: -150,
            endAngle: 150,
            background: [{
                backgroundColor: {
                    linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                    stops: [
                        [0, '#FFF'],
                        [1, '#333']
                    ]
                },
                borderWidth: 0,
                outerRadius: '109%'
            }, {
                backgroundColor: {
                    linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                    stops: [
                        [0, '#333'],
                        [1, '#FFF']
                    ]
                },
                borderWidth: 1,
                outerRadius: '107%'
            }, {
                // default background
            }, {
                backgroundColor: '#DDD',
                borderWidth: 0,
                outerRadius: '105%',
                innerRadius: '103%'
            }]
        },

        // the value axis
        yAxis: {
            min: 0,
            max: plot_band3,

            minorTickInterval: 'auto',
            minorTickWidth: 1,
            minorTickLength: 10,
            minorTickPosition: 'inside',
            minorTickColor: '#666',

            tickPixelInterval: 5,
            tickWidth: 2,
            tickPosition: 'inside',
            tickLength: 10,
            tickColor: '#666',
            labels: {
                step: 2,
                rotation: 'auto'
            },
            title: {
                text : 'K rec / min',
                style : {color: 'blue', fontWeight: 'bold'},
                y : 15
            },
            plotBands: [
                        {from: 0,to: plot_band1,color: '#55BF3B' /* green */}, 
                        {from: plot_band1,to: plot_band2,color: '#DDDF0D' /* yellow */ }, 
                        {from: plot_band2,to: plot_band3,color: '#DF5353' /* red */}
                       ]
        },

        series: [
                 {name: 'Export Speed', data: [export_speed], tooltip: {valueSuffix: ' K recs / min'}},
                 {name: 'Mask Speed',data: [mask_speed], tooltip: {valueSuffix: ' K recs / min'}}
                 ]

    });
	
}
//-------------------------------------------------------------
function drawWorkerPieChart(
		all_count,
		new_count, 
		assigned_count, 
		running_count, 
		completed_count, 
		failed_count, 
		retry_count
		) {
	
	    // Build the chart
        $('#taskGraphDiv').highcharts({
            chart: {
                type: 'bar',
                width:400
            },
            title: {
            	align:'center',
            	verticalAlign: 'top',
            	y : -1000,
                text : 'Task Status',
                style: {fontWeight: 'bold'}
            },
            legend : {
            	enabled: false
            },
            xAxis: {
                categories: [
                             '[ALL]', 
                             'New', 
                             'Assigned', 
                             'Running', 
                             'Completed', 
                             'Failed', 
                             'Retry'
                             ]
            },

            plotOptions: {
                series: {
                    cursor: 'pointer',
                    point: {
                        	events: {click: function () {location.href = this.options.url;}
                        	}
                    }
                }
            },

            series: [{
                data: [
                       {y: all_count, 	url: 'javascript:showTaskListByStatus("ALL")', color : 'black'}, 
                       {y: new_count, 	url: 'javascript:showTaskListByStatus("NEW")', color : 'lightgray'}, 
                       {y: assigned_count, 	url: 'javascript:showTaskListByStatus("ASSIGNED")', color : 'orange'},
                       {y: running_count, 	url: 'javascript:showTaskListByStatus("RUNNING")', color : 'yellow'},
                       {y: completed_count, 	url: 'javascript:showTaskListByStatus("FINISHED")', color : "lightgreen"},
                       {y: failed_count, 	url: 'javascript:showTaskListByStatus("FAILED")', color : 'red'},
                       {y: retry_count, 	url: 'javascript:showTaskListByStatus("RETRY")', color : 'gray'}
                       ]
            }]
        });
    

	
}


//-------------------------------------------------------------------
function showTaskListByStatus(status) {
	var work_plan_id=document.getElementById("detailed_work_plan_id").value;
	showTaskList(work_plan_id, status,"NO");
}

//-------------------------------------------------------------------
function showFailedTaskList() {
	var work_plan_id=document.getElementById("detailed_work_plan_id").value;
	showTaskList(work_plan_id, status,"YES");
}

//-------------------------------------------------------------------
function assignRoleToGroup(group_id,role_action) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Role";
	var par2="role";
	var par3="x";
	var par4="x";
	var par5="fireAssignRoleToGroup('"+group_id+"','#','"+role_action+"')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}
//--------------------------------------------------------------------
function fireAssignRoleToGroup(group_id, role_id,role_action) {

	if (role_id=="x") {
		myalert("Pick a role to proceed!");
		return;
	}
	
	
	var action="assign_role_to_group";
	var div_id="NONE";
	var par1=""+group_id;
	var par2=""+role_id;
	var par3=""+role_action;
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

}


//----------------------------------------------------------------------
function testAppRepoScript(application_id) {
	var test_request_id=document.getElementById("app_repo_script_test_for_app"+application_id).value;
	
	if (test_request_id=="") {
		myalert("Enter request id to test.");
		return;
	}
	
	try{var r=0; r=parseInt(test_request_id);} catch(err) {
		myalert("Enter valid request id to test.");
		return;
	}
	
	
	var action="test_app_repo_script";
	var div_id="appRepoScriptTestBody";
	var par1=""+test_request_id;
	var par2=""+application_id;
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#appRepoScriptTestDiv").modal("show");
	
	
	
}


//------------------------------------------------
function showSampleAppScript() {
	
	
	var js_script="<span style=\"font-family: monospace;\">"+
				"function calcul() <br>"+
				"{<br>"+
				"var app_repo_root=\"<b>${APP_REPO_ROOT</b>}\";<br>"+
				"var app_tag_root=\"<b>${APP_TAG_ROOT</b>}\";<br>"+
				"var member_tag=\"<b>${MEMBER_TAG</b>}\";<br>"+
				"var member_version=\"<b>${MEMBER_VERSION</b>}\";<br>"+
				"var member_full_path=\"<b>${MEMBER_FULL_PATH</b>}\";<br>"+
				"var member_name=\"<b>${MEMBER_NAME</b>}\";<br>"+
				"<br>"+
				"var ret1=member_full_path;<br>"+
				"<br>"+
				"return ret1;<br>"+
				"}<br>"+
				"<br>"+
				"var a=\"\";<br>"+
				"a=calcul();<br>"+
				"</span>";
			
	myalert(js_script);
	
	
}



//------------------------------------------------
function showSampleListJScript() {
	
	
	var js_script="<span style=\"font-family: monospace;\">"+
				"function calcul() <br>"+
				"{<br>"+
				"var app_repo_root=\"<b>${APP_REPO_ROOT</b>}\";<br>"+
				"var app_tag_root=\"<b>${APP_TAG_ROOT</b>}\";<br>"+
				"var member_tag=\"<b>${MEMBER_TAG</b>}\";<br>"+
				"var member_version=\"<b>${MEMBER_VERSION</b>}\";<br>"+
				"var member_full_path=\"<b>${MEMBER_FULL_PATH</b>}\";<br>"+
				"var member_name=\"<b>${MEMBER_NAME</b>}\";<br>"+
				"<br>"+
				"var ret1=member_full_path;<br>"+
				"<br>"+
				"return ret1;<br>"+
				"}<br>"+
				"<br>"+
				"var a=\"\";<br>"+
				"a=calcul();<br>"+
				"</span>";
			
	myalert(js_script);
	
	
}

//*********************************
function testJsCode(tab_name, col_name, rec_id) {
	makeTestJSCodeModal()
	
	
	var action="test_js_code";
	var div_id="testJSCodeBody";
	var par1=tab_name;
	var par2=col_name;
	var par3=rec_id;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	showModal("testJSCodeDiv");
}


//***********************************************
function makeTestJSCodeModal() {
	 
	var el=document.getElementById("testJSCodeDiv");
	//if (el) $("#attachmentDiv").remove();

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"testJSCodeDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-lg\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"		 		<div class=\"modal-header\" id=testJSCodeHeader> \n" +
	"		 			<button type=\"button\" class=\"close\" onclick=onCloseJsTest()> \n" +
	"		 				<span aria-hidden=\"true\">&times;</span> \n" +
	"		 				<span class=\"sr-only\">Close</span> \n" +
	"		 			</button> \n" +
	"		 		</div> <!--  modal header --> \n" +
	"			 	 <div class=\"modal-body\" id=\"testJSCodeBody\"  style=\"min-height: 300px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;\"> \n" +
	"			        <div id=attachmentFormDiv></div> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"      			<div class=\"modal-footer\" id=\"testJSCodeFooter\"> " + 
	"		    		<button type=\"button\" class=\"btn btn-success\"  onclick=\"executeJSCode();\"> \n"+
	"		       		 Test <span class=\"glyphicon glyphicon-forward\"></span> \n"+
	"		    		</button> \n"+
	" 					<button type=\"button\" class=\"btn btn-sm btn-default\" onclick=onCloseJsTest()>Close</button> " +
	"	     		</div> " + 
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
}

//**********************************
function executeJSCode() {
	var params_to_set="";
	
	var jscode_original=document.getElementById("jscode_original").value;
	var jscode_modified=jscode_original;
	var test_result="test result";
	
	for (var i=0;i<1000;i++) {
		var el=document.getElementById("param_name_"+i);
		if (!el) break;
		
		var param_name=el.value;
		var param_value=document.getElementById("js_param_"+i).value;
		
		if (i>0) params_to_set=params_to_set+"|::|";
		params_to_set=params_to_set+param_name+"="+param_value;
		
		jscode_modified=jscode_modified.replace("${"+param_name+"}",param_value);
		
	}
	
	
	if (params_to_set!="") {
		var action="set_js_parameters";
		var div_id="NONE";
		var par1=params_to_set;
		
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	}
	
	
	
	try {
		test_result=eval(jscode_modified);
	 } catch (e) {
		 test_result=e.message;
		}
	
	
	
	document.getElementById("js_test_result").value=test_result;
	document.getElementById("jscode_modified").value=jscode_modified;
	
	myalert(test_result);

	
}

//**********************************
function setJsChanged() {
	document.getElementById("js_changed").value="YES";
}

//**********************************
function onCloseJsTest() {
	var el=document.getElementById("js_changed");
	
	if (!el) $("#testJSCodeDiv").modal("hide");
	
	
	
	var is_changed="NO";
	
	if (el) is_changed=el.value;
	
	if (is_changed=="NO") {
		$("#testJSCodeDiv").modal("hide");
		return;
	}  
	
	bootbox.confirm("You changed the code. Sure to close?", function(result) {
		if(!result) return;
		$("#testJSCodeDiv").modal("hide");
	}); 
	
}


//**********************************
function makeRequestEnvListModal(request_id) {
	 
	var modal_id="requestEnvList_"+request_id;
	
	
	var el=document.getElementById(modal_id+"Div");
	//if (el)  return; //$("#"+modal_id+"Div").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	"<div class=\"modal fade bs-example-modal-md\" id=\""+modal_id+"Div\" data-keyboard=\"false\" data-backdrop=\"static\" style=\"z-index: "+(++z_index_counter)+"; \"> " + 
	"<div class=\"modal-dialog modal-md\"> " + 
	" 	<div class=\"modal-content\"> " + 
	" 	 " + 
	" 		<div class=\"modal-header\" id=\""+modal_id+"Header\"  > " + 
	" 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> " + 
	" 				<span aria-hidden=\"true\">&times;</span> " + 
	" 				<span class=\"sr-only\">Close</span> " + 
	" 			</button> " + 
	" 		</div>  " + 
	" 		 " + 
	"	 	 <div class=\"modal-body\" id=\""+modal_id+"Body\"  style=\"min-height: 0px; max-height: 480px; overflow-x: scroll; overflow-y: scroll;\"> " + 
	"	        <p>One fine body&hellip;</p> " + 
	"      	</div> <!--  modal body --> " + 
	"      	 " + 
	"      	<div class=\"modal-footer\" id=\""+modal_id+"Footer\"> " + 
	" 			<button type=\"button\" class=\"btn btn-sm btn-default\" data-dismiss=\"modal\">Close</button> " +
	"	     </div> " + 
	"      	 " + 
	"	 	</div> <!--  modal content -->	  " + 		
	"	</div> <!--  modal dialog --> " + 
	"</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
}

//----------------------------------------------------
function makeRequestEnvList(request_id) {
	
	makeRequestEnvListModal(request_id);
	
	var action="make_request_env_list";
	var div_id="requestEnvList_"+request_id+"Body";
	var par1=request_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	showModal("requestEnvList_"+request_id+"Div");
}


//------------------------------------------------------------------------
function changeDeploymentEnvironmet(request_id,selected_env_id, env_name ) {

	var action="change_deployment_environment";
	var div_id="NONE";
	var par1=request_id;
	var par2=selected_env_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	document.getElementById("environment_id_"+request_id).value=selected_env_id;
	document.getElementById("environment_id_title_"+request_id).value=env_name;
	
	$("#requestEnvList_"+request_id+"Div").modal("hide");
	
}


function makeHtmlContentModal(string_id) {
	 
	var el=document.getElementById("htmlContentDiv"+string_id);
	//if (el) return;
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-md\" id=\"htmlContentDiv"+string_id+"\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-md\">  \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"			 	 <div class=\"modal-body\" id=\"htmlContentBody"+string_id+"\"  style=\"min-height: 0px; max-height: 550px; \" > \n" +
	"			        <p>One fine body&hellip;</p> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n" +
	"		      		<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n" +
	"		      	</div> \n" +
	"		 	</div> <!--  modal content -->  \n" +
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->";

	$('body').append(modal_html);
	
	
}

//------------------------------------------------------------------------
function viewHtmlContent(string_id) {

	var action="view_html_content";
	var div_id="htmlContentBody"+string_id;
	var par1=string_id;

	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	makeHtmlContentModal(string_id);
	
	showModal("htmlContentDiv"+string_id);
	
}

//-------------------------------------------------------------------------
function setUserLang() {
	
	var langEl=document.getElementById("langCombo");
	
	if (langEl==null) return;
	
	var lang=langEl.value;
	
	if (lang=="") return;
	
	var action="set_user_lang";
	var div_id="NONE";
	var par1=lang;

	
	ajaxDynamicComponentCaller(action, div_id, par1);

}

//-------------------------------------------------------------------------

function reloadCurrentPage() {

	location.reload();
	
}

//-------------------------------------------------------------------------
function onLoadDashboard() {
	var action="load_dashboard_top_menu:::::load_dashboard_main";
	var div_id="dashboardTop:::::dashboardMainDiv";
	var par1="x:::::x";

	startDashboardTimer();
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//-------------------------------------------------------------------------
var dashboard_timer=null;
function startDashboardTimer() {
	dashboard_timer = setInterval(dashboardRefresher, 1000);
}
//-------------------------------------------------------------------------
function dashboardRefresher() {
	var els=document.getElementsByName("dashboard_div_ids");
	
	for (var i=0;els.length;i++) {
		var el=els[i];
		if (el==null) break;
		var dashboard_div_id=el.value;
		
		var refresh_interval=document.getElementById("refresh_interval_for_"+dashboard_div_id).value;
		var view_id=""+document.getElementById("view_id_for_"+dashboard_div_id).value;
		
		if (refresh_interval=="MANUAL") continue;
		var remaining_time_as_second=0;
		
		
		
		remaining_time_as_second=parseInt(document.getElementById("remaining_time_as_second_for_"+dashboard_div_id).value);
		
		remaining_time_as_second=remaining_time_as_second-1;

		document.getElementById("remaining_time_as_second_for_"+dashboard_div_id).value=""+remaining_time_as_second;
		
		if (remaining_time_as_second<=0) 
			reloadView(view_id,dashboard_div_id);
		
		
	}
}

//-----------------------------------------------------------------------------
function makeDashboardViewExecuteModal() {
	
	var el=document.getElementById("viewExecuteDiv");

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"viewExecuteDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-lg\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"		 		<div class=\"modal-header\" id=viewExecuteHeader> \n" +
	"		 			<button type=\"button\" class=\"close\" data-dismiss=\"modal\"> \n" +
	"		 				<span aria-hidden=\"true\">&times;</span> \n" +
	"		 				<span class=\"sr-only\">Close</span> \n" +
	"		 			</button> \n" +
	"		 			<iframe name='hiddenframe' width=\"0\" id=”results” name=\"results\" height=\"0\" border=\"0\" frameborder=\"0\" scrolling=\"auto\" align=\"center\" hspace=\"0\" vspace=\"\">  \n" +
  	"					</iframe> \n" +
  	"					 \n" +
	"		 		</div> <!--  modal header --> \n" +
	"			 	 <div class=\"modal-body\" id=\"viewExecuteBody\"  style=\"min-height: 0px; max-height: 480px; overflow-x: scroll; overflow-y: scroll;\"> \n" +
	"			        <div id=viewExecuteBody></div> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-success\" id=btrunMadView onclick=\"runMadView();\"> \n"+
	"		        		<span class=\"glyphicon glyphicon-play\"></span> Run  \n"+
	"		        	</button> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
}


//----------------------------------------------------------------------

function runMadDashView(view_id,DashboardDivId,runMode) {
	
	makeDashboardViewExecuteModal();
	
	var action="make_run_mad_dashboard_view_dlg";
	var div_id="viewExecuteBody";
	var par1=view_id;
	var par2=DashboardDivId;
	var par3=runMode;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
	$("#viewExecuteDiv").modal();
}


//----------------------------------------------------------------------

function runMadView() {

	
	var view_id=document.getElementById("running_view_id").value;
	var view_user_title=document.getElementById("view_user_title").value;
	var runMode=document.getElementById("view_runMode").value;
	var target_div=document.getElementById("view_target_div").value;
	
	var run_parameters="";
	
	var parameter_count=0;
	
	
	parameter_count=parseInt(document.getElementById("view_parameter_count").value);
	
	var added=0;
	
	for (var i=0;i<parameter_count;i++) {
		var el=document.getElementById("search_of_search_TABNONE_flex_field_id_"+i);
		if (!el) continue;
		var param_val=el.value;
		if (param_val=="") continue;
		added++;
		if (added>1) run_parameters=run_parameters+"\n";
		var flex_field_id=document.getElementById("id_of_search_TABNONE_flex_field_id_"+i).value;
		
		 run_parameters=run_parameters+flex_field_id+"="+param_val;
	}
	
	
	
	var action="run_mad_dashboard_view";
	var div_id=""+target_div;
	
	var par1=view_id;
	var par2=view_user_title;
	var par3=run_parameters;
	var par4=runMode;
	var par5=target_div;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	if (runMode=="LIVE") {
		 $("#viewExecuteDiv").modal("hide");
		 //runMadDashView(view_id,target_div,'LIVE');
	} 
	                     

	
}

//*******************************************************
function assignDashboardView(DashboardDivId) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Select View";
	var par2="dashboard_view";
	var par3="x";
	var par4="x";
	var par5="assignDashboardViewDo('#','"+DashboardDivId+"')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}


//***********************************************************
function assignDashboardViewDo(view_id, DashboardDivId) {
	runMadDashView(view_id,DashboardDivId,'LIVE');
}




//***********************************************************
function reloadView(view_id, DashboardDivId) {
	
	var action="build_dashboard_view";
	var div_id=""+DashboardDivId;
	var par1=DashboardDivId;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
	
}

//-----------------------------------------------------------------------------
function makeDashboardMaxViewBodyModal() {
	
	var el=document.getElementById("maxViewDiv");

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"maxViewDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-lg\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"			 	 <div class=\"modal-body\" id=\"maxViewBody\"  style=\"min-height: 0px; max-height: 480px; overflow-x: scroll; overflow-y: scroll;\"> \n" +
	"			        <div id=maxViewBody></div> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" onclick=closeMaxView()>Close</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
}

//***********************************************************
function maximizeView(DashboardDivId) {
	
		makeDashboardMaxViewBodyModal();
		$("#maxViewDiv").modal();
		var divcontent=document.getElementById(DashboardDivId).innerHTML;
		setDivContent("maxViewBody", divcontent);
		
		return;
}

//***********************************************************
function closeMaxView() {
	
	$("#maxViewDiv").modal("hide");
	clearDivContent('maxViewBody');
}

//***********************************************************
function removeView(view_id, DashboardDivId) {
	
bootbox.confirm("Are you sure to remove this view?", function(result) {
		
		if(!result) return;

		
		var action="remove_dashboard_view";
		var div_id=""+DashboardDivId;
		var par1=view_id;
		var par2=DashboardDivId;
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		
		
	}); 
	
	
	
}


//***********************************************************
function changeDashboardLayout() {
	
	var layout=document.getElementById("dashboard_layout").value;
	
	var action="change_dashboard_layout";
	var div_id="NONE";
	var par1=layout;
	
	ajaxDynamicComponentCaller(action, div_id, par1);

	
}


//-----------------------------------------------------------------------------
function makeDashboardDataDownloadModal() {
	
	var el=document.getElementById("downloadDataDiv");

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-sm\" id=\"downloadDataDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-sm\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"			 	 <div class=\"modal-body\" id=\"downloadDataBody\"  style=\"min-height: 0px; max-height: 480px; overflow-x: scroll; overflow-y: scroll;\"> \n" +
	"			        <div id=maxViewBody></div> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" onclick=cancelDownload()>Cancel Download</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
}

var is_downloading=true;

//***********************************************************
function downloadDashboardData(view_id, DashboardDivId) {
	makeDashboardDataDownloadModal();
	$("#downloadDataDiv").modal();
	
	var action="download_dashboard_data";
	var div_id="downloadDataBody";
	var par1=view_id;
	var par2=DashboardDivId;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	is_downloading=true;
	
	
	
	
}


//*********************************************************
function cancelDownload() {
	is_downloading=false;
	
	$("#downloadDataDiv").modal("hide");
	
	myalert("Download cancelled by user.");
	
}


//***********************************************************
function downloadDashboardDataGet(filename) {
	
	if (!is_downloading) return;
	
	is_downloading=false;
	
	$("#downloadDataDiv").modal("hide");
	
	myalert("File is ready... "+
				" Click <a href=\""+filename+"\" target=_new><b>here</b></a> to get the file.");
	
}


//-----------------------------------------------------------------------------
function makeDashboardConfigModal() {
	
	var el=document.getElementById("viewConfigDiv");

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-md\" id=\"viewConfigDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-md\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"			 	 <div class=\"modal-body\" id=\"viewConfigBody\"  style=\"min-height: 0px; max-height: 480px; overflow-x: scroll; overflow-y: scroll;\"> \n" +
	"			        <div id=viewExecuteBody></div> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-success\" id=btsaveMadDashboardViewConfig onclick=\"saveDashboardViewConfig();\"> \n"+
	"		        		<span class=\"glyphicon glyphicon-save\"></span> Save  \n"+
	"		        	</button> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
}


//***********************************************************
function configureDashboardView(view_id, DashboardDivId) {
	makeDashboardConfigModal();
	
	var action="make_dashboard_configuration_window";
	var div_id="viewConfigBody";
	var par1=view_id;
	var par2=DashboardDivId;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#viewConfigDiv").modal();
	
}

//*************************************************************
function saveDashboardViewConfig() {
	
	
	var config_id=document.getElementById("config_id").value;
	var original_vals=document.getElementById("original_vals").value;
	
	var height=document.getElementById("height").value;
	var refresh_by=document.getElementById("refresh_by").value;
	var refresh_interval=document.getElementById("refresh_interval").value;
	var send_notification=document.getElementById("send_notification").value;
	var notification_groups=document.getElementById("notification_groups").value;
	
	
	var action="save_dashboard_view_config";
	var div_id="NONE";
	var par1=config_id;
	var par2=original_vals;
	var par3=height;
	var par4=refresh_by+","+refresh_interval+","+send_notification+","+notification_groups;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	$("#viewConfigDiv").modal("hide");
	
	
}


//**************************************************
function makeDatabaseList() {
	
	var action="make_database_list";
	var div_id="colDatabasesBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//****************************************************************
function addNewDatabase() {
	bootbox.prompt("Enter Database Name to add ", function(result) {                
		  if (result== null) return;
			  
			  if (result.length==0) {
				  myalert("Name cannot be empty");
				  return;
			  }
		  
			var action="add_database";
			var div_id="NONE";
			var par1=""+result;	
				
			ajaxDynamicComponentCaller(action, div_id, par1);
				
		});	
}

//**************************************************
function saveDatabaseField(el, database_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_database_field";
	var div_id="NONE";
	var par1=""+database_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function makeDatabaseEditor(database_id) {
	
	var action="make_database_editor";
	var div_id="colDatabaseContent_"+database_id+"Body";
	var par1=""+database_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//****************************************************************
function deleteDatabase(db_id) {
	bootbox.confirm("Are you sure to remove?", function(result) {
		
		if(!result) return;
		
		var action="remove_database";
		var div_id="NONE";
		var par1=""+db_id;	
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	}); 
}

//*********************************************************************
function testConnectionByDbId(db_id) {

	var action="test_connection_by_db_id";
	var div_id="testConnectionBody";
	var par1=db_id;
		
	$("#testConnectionDiv").modal();
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}


//************************************************************************
function addRemoveSortField(action_and_id) {
	var action="add_remove_sort_field";
	var div_id="NONE";
	var par1=""+action_and_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//*************************************************************************
function makeSortFieldsConfiguration() {
	var action="make_sort_field_configuration";
	var div_id="sortFieldsConfigurationDiv";
	var par1="x";	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//************************************************************************
function setSortFieldDirection(id) {
	
	var field_name=document.getElementById("sort_field_name_"+id).value;
	var sort_ascdesc=document.getElementById("sort_ascdesc_"+id).value;
	
	var action="set_sort_field_direction";
	var div_id="NONE";
	var par1=""+field_name;	
	var par2=""+sort_ascdesc;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//************************************************************************
function setSortFieldDirectionAndReloadList(field_name, sort_ascdesc) {
	
	var action="set_sort_field_direction_and_reload_list";
	var div_id="NONE";
	var par1=""+field_name;	
	var par2=""+sort_ascdesc;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//************************************************************************
function removeSortField(field_name) {
		
	var action="remove_sort_field_and_reload_list";
	var div_id="NONE";
	var par1=""+field_name;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
}


//*******************************************************************
function doLoginOnEnter(e) {
	if (e.keyCode == 13) {
        doLogin();
        return false;
    }
}


//********************************************************************
function doLogin() {
	var user=document.getElementById("txtUsername").value;
	var pass=document.getElementById("txtPassword").value;
	
	
	if (user=="") {
		myalert("Please enter username");
		return;
	} 
	
	if (pass=="") {
		myalert("Please enter password");
		return;
	} 
	
	
	var user_enc=encrypt(user);
	var pass_enc=encrypt(pass);
	
	
	showWaitingModal();
	
	var action="do_login";
	var div_id="NONE";
	var par1=user_enc;	
	var par2=pass_enc;
	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**********************************************************************
function encrypt(val) {
	var ret1="";
	for (var i=0;i<val.length;i++) {
		var n=""+val.charCodeAt(i);
		ret1=ret1+n.length;
		ret1=ret1+val.charCodeAt(i);
	}
	
	return ret1;
}

//**********************************************************************

function gotoHome() {

	try  {location.href="default2.jsp";} catch(e) {}
	
	
}

//*********************************************************************
function showLoginError() {
	myalert("Invalid username or password");
}


//-----------------------------------------------------------------------------
function makeListOfParentRequestsModal(request_id) {
	
	var el=document.getElementById("listOfPArentRequestsForRequest"+request_id);

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\""+"listOfPArentRequestsForRequest"+request_id+"\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-lg\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"			 	 <div class=\"modal-body\" id=\"listOfPArentRequestsForRequest"+request_id+"Body\"  style=\"min-height: 0px; max-height: 480px; overflow-x: scroll; overflow-y: scroll;\"> \n" +
	"			        <div id=maxViewBody></div> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
}

//*********************************************************************
function listOfParentRequests(request_id) {
	makeListOfParentRequestsModal(request_id);
	
	$("#listOfPArentRequestsForRequest"+request_id).modal();
	
	
	var action="list_parent_requests";
	var div_id="listOfPArentRequestsForRequest"+request_id+"Body";
	var par1=request_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}


//-----------------------------------------------------------------------------
function makeTestMethodModal() {
	
	var el=document.getElementById("testMethodDiv");

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"testMethodDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-lg\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"			 	 <div class=\"modal-body\" id=\"testMethodBody\"  style=\"min-height: 0px; max-height: 480px; overflow-x: scroll; overflow-y: scroll;\"> \n" +
	"			        <div id=viewExecuteBody></div> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		        	<button type=\"button\" class=\"btn btn-success\" id=bt_test_module onclick=\"executeMethod();\">\n" +
	"						Run"+
	"					</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
	
	
	
}




//*********************************************************************
function testMadMethod(method_id, action_method_id) {
	makeTestMethodModal();
	
	
	var action="test_mad_method";
	var div_id="testMethodBody";
	var par1=method_id;
	var par2=action_method_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#testMethodDiv").modal();
	
	
	
}


//**********************************************************************
function executeMethod() {
	
	
	showWaitingModal();
	
	var test_method_id=document.getElementById("test_method_id").value;
	var test_action_method_id=document.getElementById("test_action_method_id").value;
	var test_parameter_count=document.getElementById("test_parameter_count").value;
	var test_request_id=document.getElementById("test_request_id").value;
	
	var parameters="";
	
	var param_count_int=parseInt(test_parameter_count);
	
	
	for (var i=0;i<param_count_int;i++) {
		var elname=document.getElementById("param_name_"+(i+1));
		if (!elname) continue;
		var el=document.getElementById("value_"+(i+1));
		if (!el) continue;
		
		var param_name=elname.value;
		var param_value=el.value;
		
		if (i>0) parameters=parameters+"\n";
		parameters=parameters+param_name+"="+param_value;
	}
	
	var action="execute_mad_method";
	var div_id="testMethodResultDiv";
	var par1=test_method_id;
	var par2=test_action_method_id;
	var par3=test_request_id;
	var par4=parameters;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}


//**********************************************************************
function getLastExecuteMethodLogs () {
	
	hideWaitingModal();
	
	var action="get_last_execute_method_logs";
	var div_id="testMethodLogsDiv";
	var par1="x";

	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}


//***********************************************************************

function makeMethodCallLogDetailModal() {
	
	var el=document.getElementById("methodCallLogDetailDiv");

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"methodCallLogDetailDiv\" style=\"z-index: "+(++z_index_counter)+"; \"> \n" +
	"		<div class=\"modal-dialog modal-lg\"> \n" +
	"		 	<div class=\"modal-content\"> \n" +
	"			 	 <div class=\"modal-body\" id=\"methodCallLogDetailBody\"  style=\"min-height: 0px; max-height: 480px; overflow-x: scroll; overflow-y: scroll;\"> \n" +
	"		      	</div> <!--  modal body --> \n" +
	"		      	<div class=\"modal-footer\"> \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"		 	</div> <!--  modal content -->	 	 \n" +	
	"		</div> <!--  modal dialog --> \n" +
	"	</div> <!--  modal fade -->	";

	$('body').append(modal_html);
	
	
	
	
	
}


//***********************************************************************
function openMethodCallLogDetail(log_id) {
	
	makeMethodCallLogDetailModal();
	
	var action="open_method_call_log_details";
	var div_id="methodCallLogDetailBody";
	var par1=log_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#methodCallLogDetailDiv").modal();
}

//*************************************************
function getNeededParameterListOfRequest(request_id, depended_fields_list, target) {
	
	
	var ret1="";
	
	var arr=depended_fields_list.split(",");
	
	var cnt=0;
	
	for (var i=0;i<arr.length;i++) {
		
		var depended_parameter_name=arr[i];
		
		for (var f=0;f<1000;f++) {
			
			var elcheck=document.getElementById("parameter_name_of_entry_TAB"+request_id+"_flex_field_id_"+f);
			if (!elcheck) break;
			var param_name=elcheck.value;
			if (param_name=="") continue;
			
			if (param_name!=depended_parameter_name) continue;
			
			var elval=document.getElementById("entry_TAB"+request_id+"_flex_field_id_"+f);
			if (!elval) continue;
			
			cnt++;
			if (target=="VALUES") {
				
				
				if (cnt>1) ret1=ret1+"\n";
				ret1=ret1+param_name+"="+elval.value;
			}
			else { //IS_CHANGED
 				
				var eloldval=document.getElementById("old_value_of_entry_TAB"+request_id+"_flex_field_id_"+f);
				if (!eloldval) continue;
				
				
				if (eloldval.value!=elval.value) {
					return "true";
				}
				
			}
			
			
			
			
		}
		
		
	}
	
	if (target=="VALUES") {
		return ret1;
	} 

	//IS_CHANGED
	if (ret1=="") ret1="false";
	
}

//**************************************************
function openLovWindow(curr_val, title, request_id, flex_field_id,field_obj_id,width) {
	
	var depended_fields_list=document.getElementById("depended_fields_"+field_obj_id).value;
	
	var is_depended_fields_changed=getNeededParameterListOfRequest(request_id,depended_fields_list,"IS_CHANGED");
	if (curr_val=="") is_depended_fields_changed=false;
	
	if (is_depended_fields_changed=="true") {
		myalert("Please save the form first to see updated LOV");
		return;
	}
	
	var request_field_parameters=getNeededParameterListOfRequest(request_id,depended_fields_list,"VALUES");
	
		
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1=title;
	var par2="lov:"+flex_field_id;
	var par3=request_id+":"+request_field_parameters;
	var par4=curr_val;
	var par5="fireSetLovFieldValue('"+request_id+"','"+flex_field_id+"','"+field_obj_id+"','"+width+"','#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//**************************************************
function fireSetLovFieldValue(request_id, flex_field_id, field_obj_id, width, lov_value) {
	var action="set_lov_field_value";
	var div_id="LOV_DIV_"+field_obj_id;
	var par1=request_id;
	var par2=flex_field_id;
	var par3=field_obj_id;
	var par4=width;
	var par5=lov_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
}
//**************************************************
function reloadDBObjectList(package_id,application_id) {
	
	if (document.getElementById("db_schema_list_for_"+package_id).value=="") return;
	if (document.getElementById("db_object_type_list_for_"+package_id).value=="") return;

	var schema=document.getElementById("db_schema_list_for_"+package_id).value;
	var object_type=document.getElementById("db_object_type_list_for_"+package_id).value;
	var object_filter=document.getElementById("db_object_filter_for_"+package_id).value;
	
	
	var action="reload_db_repository_object_list";
	var div_id="dbObjectListDivFor_"+package_id;
	var par1=package_id;
	var par2=application_id;
	var par3=schema;
	var par4=object_type;
	var par5=object_filter;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);

	
}


//**********************************
function makeCheckOutHistoryModal() {
	 
	var el=document.getElementById("checkoutHistoryDiv");
	//if (el) $("#tagPickerDiv").remove();
	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	
	var modal_html=	""+
	"		<div class=\"modal fade bs-example-modal-lg\" id=\"checkoutHistoryDiv\" data-keyboard=\"false\" data-backdrop=\"static\" style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-lg\"> \n"+
	"		 	<div class=\"modal-content\"> \n"+
	"			 	 <div class=\"modal-body\" id=\"checkoutHistoryBody\"  style=\"min-height: 0px; max-height: 400px; overflow-x: scroll; overflow-y: scroll;\"> \n"+
	"			        <p>One fine body&hellip;</p> \n"+
	"		      	</div> <!--  modal body --> \n"+
	"		      	 \n"+
	"		      	<div class=\"modal-footer\"> \n"+
	"		      		 \n"+
	"		      		 \n"+
	"		        	<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button> \n"+
	"		      	</div> \n"+
	"	      	 \n"+
	"		 	</div> <!--  modal content -->	 		 \n"+
	"		</div> <!--  modal dialog -->  \n"+
	"	</div> <!--  modal fade -->";

	$('body').append(modal_html);
	
	
}


//*******************************************************************************
function showCheckOutHistory(application_id, member_path) {
	makeCheckOutHistoryModal();
	showModal("checkoutHistoryDiv");
	
	var action="show_checkout_history";
	var div_id="checkoutHistoryBody";
	var par1=application_id;
	var par2=member_path;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//*******************************************************************************
function duplicateMadPlatformType(platform_type_id ) {
	bootbox.confirm("Are you sure to duplicate ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="duplicate_mad_platform_type";
		var div_id="NONE";
		var par1=""+platform_type_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
}

//*******************************************************************************
function duplicateMadPlatform(platform_id ) {
	bootbox.confirm("Are you sure to duplicate ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="duplicate_mad_platform";
		var div_id="NONE";
		var par1=""+platform_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
}

//*******************************************************************************
function duplicateMadModifierGroup(modifier_group_id ) {
	bootbox.confirm("Are you sure to duplicate ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="duplicate_mad_modifier_group";
		var div_id="NONE";
		var par1=""+modifier_group_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
}

//*******************************************************************************
function duplicateMadApplication(application_id ) {
	bootbox.confirm("Are you sure to duplicate ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="duplicate_mad_application";
		var div_id="NONE";
		var par1=""+application_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
}

//*******************************************************************************
function duplicateMadFlow(flow_id ) {
	bootbox.confirm("Are you sure to duplicate ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="duplicate_mad_flow";
		var div_id="NONE";
		var par1=""+flow_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
}

//*******************************************************************************
function duplicateMadRequestType(request_type_id ) {
	bootbox.confirm("Are you sure to duplicate ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="duplicate_mad_request_type";
		var div_id="NONE";
		var par1=""+request_type_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
}
//**************************************************
function addRemoveGroupMember(group_id, action_and_id, member_type) {
	var action="add_remove_group_member";
	var div_id="NONE";
	var par1=""+group_id;	
	var par2=""+action_and_id;
	var par3=""+member_type;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}