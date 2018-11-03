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
	ajaxDynamicComponentCaller(action,div_id,par1,"","","","","");
}

//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1,par2){
//*************************************************************************	
	ajaxDynamicComponentCaller(action,div_id,par1,par2,"","","","");
}

//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1,par2,par3){
//*************************************************************************	
	ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,"","","");
}

//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,par4){
//*************************************************************************	
	ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,par4,"","");
}

//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,par4,par5){
//*************************************************************************	
	ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,par4,par5,"");
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
//*********************************************
function DOshowBlocker() {
//*********************************************
var el=document.getElementById("pleaseWaitDialogx");

if (!el) return;

myAppForWait.showPleaseWait();
try {window.clearTimeout(blockerTimeout);} catch(err) {}

}


//*********************************************
function showBlocker() {
//*********************************************
	blockerTimeout=setTimeout(function(){DOshowBlocker();},500);
}

//*********************************************
function hideBlocker() {
//*********************************************
try {window.clearTimeout(blockerTimeout);} catch(err) {}
	
var el=document.getElementById("pleaseWaitDialogx");

if (!el) return;

myAppForWait.hidePleaseWait();

}


var orig_div_contents=[];


//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,par4,par5,par6){
//*************************************************************************	
	

	if (div_id!="NONE" && div_id.indexOf("NOFADE_")==-1) showBlocker();
	
	 
	
	if (par1) {
		par1 = par1.replace(/(?:\r\n|\r|\n)/g, '**NEWLINE**');
	}
	if (par2) {
		par2 = par2.replace(/(?:\r\n|\r|\n)/g, '**NEWLINE**');
	}
	if (par3) {
		par3 = par3.replace(/(?:\r\n|\r|\n)/g, '\**NEWLINE**');
	}
	if (par4) {
		par4 = par4.replace(/(?:\r\n|\r|\n)/g, '**NEWLINE**');
	}
	if (par5) {
		par5 = par5.replace(/(?:\r\n|\r|\n)/g, '**NEWLINE**');
	}
	if (par6) {
		par6 = par6.replace(/(?:\r\n|\r|\n)/g, '**NEWLINE**');
	}
	
	
	
	
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
	  console.log("par6 : " + par6);
	  
	  
	  
	  queueForAction[queueForAction.length]=action;
	  queueForDiv[queueForDiv.length]=div_id;
	  quueueForPar1[quueueForPar1.length]=par1;
	  quueueForPar2[quueueForPar2.length]=par2;
	  quueueForPar3[quueueForPar3.length]=par3;
	  quueueForPar4[quueueForPar4.length]=par4;
	  quueueForPar5[quueueForPar5.length]=par5;
	  quueueForPar6[quueueForPar6.length]=par6;
	  
	  
	  return;
  }
  
  AJAX.onreadystatechange = handler_handler;
  
  par1=encodeURIComponent(par1);
  par2=encodeURIComponent(par2);
  par3=encodeURIComponent(par3);
  par4=encodeURIComponent(par4);
  par5=encodeURIComponent(par5);
  par6=encodeURIComponent(par6);
  
  
  
  
  var AJAX_URL="ajaxDynamicComponent.jsp?action=" + action + "&div=" + div_id + "&par1=" + par1 + "&par2=" + par2 + "&par3="+par3+ "&par4="+par4+ "&par5="+par5+ "&par6="+par6;
  var async=true;
  AJAX.open("POST", AJAX_URL , async);
  AJAX.setRequestHeader( 'content-type', 'text/html;charset=UTF-8');
  AJAX.timeout = 1200000;
  AJAX.ontimeout = function () { myalert("Ajax Timed out!!!");   restoreDivOriginalContents(); };
  AJAX.send("");
  
}

var queueForAction=[];
var queueForDiv=[];
var quueueForPar1=[];
var quueueForPar2=[];
var quueueForPar3=[];
var quueueForPar4=[];
var quueueForPar5=[];
var quueueForPar6=[];


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
	  
	 
	  hideBlocker();
	  clearHourGlass();
	  
	  var json =null;
	  
	  try {json=JSON.parse( AJAX.responseText ); } catch(err) {
		  json =null;
		  myalert("Json Parse Error : " +err+" (See browser's console for AJAX response.)");
		  console.log("AJAX.responseText : " +AJAX.responseText);
		  location.href="default2.jsp";
		  return;
		  }
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
    	  
    	  
    	  restoreDivOriginalContents();
    	  myalert(msg.substring(4));
    	 
      }
      else if (msg && msg.indexOf("ok:javascript:")==0) {
    	  
    	  var js_code_to_execute=msg.substring(14);
    	  runjs_code(js_code_to_execute);
    	  
      }
      else if (!msg) {
    	  restoreDivOriginalContents();
    	  myalert("Message is not transmitted to the client.");
    	  console.log("Message is not transmitted to the client.");
    	  
    	  
      } else if (msg!="ok") {
    	  console.log("exceptional msg : " + msg);
      }
      
      
      orig_div_contents=[];
      
      setActiveTableRow();
      setActiveList();
      showTableValidationResults();
      setToOriginalScrollTops();
      
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
	  quueueForPar6=[];
	  
	  hideBlocker();
	 clearHourGlass();
	 //restoreDivOriginalContents();
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
	var queue_par6=quueueForPar6[0];
	
	console.log("executing action ["+queue_action+"] from queue");
	
	ajaxDynamicComponentCaller(queue_action, queue_div, queue_par1, queue_par2, queue_par3, queue_par4, queue_par5, queue_par6);
	
	//delete first item
	tmpForAction=queueForAction;
	tmpForDiv=queueForDiv;
	tmpForPar1=quueueForPar1;
	tmpForPar2=quueueForPar2;
	tmpForPar3=quueueForPar3;
	tmpForPar4=quueueForPar4;
	tmpForPar5=quueueForPar5;
	tmpForPar6=quueueForPar6;
	
	queueForAction=[];
	queueForDiv=[];
	quueueForPar1=[];
	quueueForPar2=[];
	quueueForPar3=[];
	quueueForPar4=[];
	quueueForPar5=[];
	quueueForPar6=[];
	
	for (var i=1;i<tmpForAction.length;i++) {
		queueForAction[queueForAction.length]=tmpForAction[i];
		queueForDiv[queueForDiv.length]=tmpForDiv[i];
		quueueForPar1[quueueForPar1.length]=tmpForPar1[i];
		quueueForPar2[quueueForPar2.length]=tmpForPar2[i];
		quueueForPar3[quueueForPar3.length]=tmpForPar3[i];
		quueueForPar4[quueueForPar4.length]=tmpForPar4[i];
		quueueForPar5[quueueForPar5.length]=tmpForPar5[i];
		quueueForPar6[quueueForPar6.length]=tmpForPar6[i];
	}
	
	


}

//***********************************************
function restoreDivOriginalContents() {
//***********************************************
	hideBlocker();
	clearHourGlass();
	
	var divArr=Object.keys(orig_div_contents);

	for (var d=0;d<divArr.length;d++) {
		  var div_id=divArr[d];
		  var div_content=orig_div_contents[d];
		  if (!div_content) continue;
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

function showModal(modaldivid) {
	var el=document.getElementById(modaldivid);
	if (!el) myalert("Modal not found : " + modaldivid);
	z_index_counter++;
	el.style.zIndex=""+z_index_counter;
	
	
	$('#'+modaldivid).modal('show');
}

//******************************************************************************************************
function bodyonload() {

	var action="fill_app_type"   +":::::fill_app_list"      +":::::fill_env_list"      +":::::fill_app_table"   ;
	var div_id="div_app_type"  	 +":::::div_app"            +":::::div_env"            +":::::div_app_table"    ;
	var par1=   curr_app_type    +":::::"+curr_app_type     +":::::"+curr_app_id       +":::::"+curr_app_id     ;
	var par2=   "x"              +":::::"+curr_app_id       +":::::"+curr_env_id       +":::::x"                ;
	var par3=   "x"              +":::::x"                  +":::::"+curr_app_type     +":::::x"                ;                 

	
	action=action +":::::fill_table_list_header" +":::::fill_table_list";
	div_id=div_id +":::::div_table_list_header"       +":::::div_table";
	par1= par1    +":::::"+curr_env_id     +":::::All|All";
	par2= par2    +":::::x"                +":::::"+curr_env_id;
	par3= par3    +":::::x"                +":::::"+curr_app_type;                 



	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	

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

//*************************
function fillAppList() {
//*************************	
	var app_type=document.getElementById("filter_app_type").value;
	curr_app_type=app_type;
	
	
	
	var action="fill_app_list";
	var div_id="div_app";
	var par1=app_type;
	var par2=curr_app_id;

	if (app_type!="") {
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
	}
}



//*********************************
function openAppById(app_id) {
//*************************	
	document.getElementById("filter_app_id").value=app_id;
	fillEnvList();
	
	$("#tableEditorDiv").modal("hide");
}


//*********************************
function openAppByIdFromAppList(app_id) {
//*************************	
	document.getElementById("filter_app_id").value=app_id;
	fillEnvList();
	
	$("#appListForTableDiv").modal("hide");
	$("#discoverForCopyDiv").modal("hide");
}

//*************************
function fillEnvList() {
//*************************	
	
	var app_id="0";
	if (document.getElementById("filter_app_id"))
		app_id=document.getElementById("filter_app_id").value;
	
	curr_app_id=app_id;
	
	var action="fill_env_list:::::fill_app_table";
	var div_id="div_env:::::div_app_table";
	var par1=app_id+":::::"+app_id;
	var par2=curr_env_id+":::::x";
	var par3=curr_app_type+":::::x";
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}


//**********************************
function changeMaskLevel(tab_id) {
	
	var el=document.getElementById("ch_mask_level_"+tab_id);
	if (!el) return;
	
	bootbox.confirm("Are you sure to change mask level of this table?", function(result) {
		
		if(!result) {
			el.checked=!el.checked;
			return;
		}

		var app_id=document.getElementById("filter_app_id").value;
		var mask_level="FIELD";
		
		if (el.checked) mask_level="DELETE";
		
		var action="change_mask_level:::::fill_app_table";
		var div_id="NONE:::::div_app_table";
		var par1=tab_id+":::::"+app_id;
		var par2=mask_level+":::::x";
		var par3="x"+":::::x";
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

	}); 
}


//***************************
function fillAppTabList() {
	var app_id=document.getElementById("filter_app_id").value;
	curr_app_id=app_id;
	
	var filter="";
	
	try {
		filter=document.getElementById("app_table_filter").value;
	} catch(err) {
		filter="";
	}
		
	var action="fill_app_table";
	var div_id="div_app_table";
	var par1=""+app_id;
	var par2=filter;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}



//*************************
function fillSchemaDomainInstanceList() {
//*************************	
	
	
	var env_id=document.getElementById("envList").value;
	var app_type=document.getElementById("filter_app_type").value;
	
	curr_env_id=env_id;
	
	var action="fill_table_list_header:::::fill_table_list";
	var div_id="div_table_list_header:::::div_table";
	var par1=env_id+":::::All|All";
	var par2="x:::::"+curr_env_id;
	var par3="x:::::"+curr_app_type;
	
	if (env_id!="")
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);


}


//*************************
function fillSchemaList() {
//*************************	
	var catalog=document.getElementById("catalogList").value;
	
	var action="fill_schema_list";
	var div_id="div_schema";
	var par1=catalog;
	var par2=curr_env_id;
	
	
	
	ajaxDynamicComponentCaller(action, div_id, par1,par2);
	
	
}

//***************************
function refreshEnvironment() {
	
	
	var env_id=document.getElementById("envList").value;

	if (env_id.length==0) {
			myalert("You should select an environment  to reconnect.");
			return;
	} 
	
	
	
	var action="fill_table_list_header";
	var div_id="div_table_list_header";
	var par1=env_id;
	var par2="REFRESH";
	
	
	if (env_id!="")
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//*************************
function fillTableList() {
//*************************	
	var catalog=document.getElementById("catalogList").value;
	var schema=document.getElementById("ownerList").value;
	curr_schema=schema;
	
	if (catalog=="") catalog="All";
	if (schema=="") schema="All";
	
	var action="fill_table_list";
	var div_id="div_table";
	var par1=catalog+"|"+schema;
	var par2=curr_env_id;
	var par3=curr_app_type;
	var par4="";
	var par5="";
	
	try{par4=document.getElementById("tableNameFilter").value;} catch(err) {}
	
	
	
	
	var include_added_tables="x";
	var include_commented_tables="x";
	var include_discarded_tables="x";
	
	var el1=document.getElementById("include_added_tables");
	if (el1 && el1.checked) include_added_tables="checked";
	
	var el2=document.getElementById("include_commented_tables");
	if (el2 && el2.checked) include_commented_tables="checked";
	
	var el3=document.getElementById("include_discarded_tables");
	if (el3 && el3.checked) include_discarded_tables="checked";
	
	par5=include_added_tables+":"+include_commented_tables+":"+include_discarded_tables;
	
	
	
	
	ajaxDynamicComponentCaller(action, div_id, par1,par2, par3, par4, par5);
	
	
}


//*****************************
function setActiveTableRow() {
//*****************************
	for (var i=1;i<1000;i++) {
		var el=document.getElementById("table_no_"+i);
		if (!el) break;
		var tabid=el.getAttribute("tabid");
		el.className="";
		if (tabid==curr_tab_id) el.className="active";
	}
}


//*****************************
function setActiveList() {
//*****************************
if (curr_list_id==-1) return;

var el=document.getElementById("listList");
if (!el) return;

var options= el.options;
for (var i=0; i<options.length; i++) {
    if (options[i].value===""+curr_list_id) {
        options[i].selected= true;
        break;
    }
}




}

//*****************************
function changeDelimiter() {
	var delimiter=document.getElementById("delimiter").value;
	var action="change_delimiter";
	var div_id="NONE";
	var par1=delimiter;

	ajaxDynamicComponentCaller(action, div_id, par1);
	

}


//*****************************
function openTableScriptDetails(envid, tabid_script_id) {
	curr_env_id=envid;
	curr_tab_id=tabid_script_id;
	
		
	if (curr_app_type=="MASK") {
		var el=document.getElementById("ch_mask_level_"+tabid_script_id);
		if (el) {
			var to_delete=el.checked;
			if (to_delete) 
				{
				myalert("Table to be deleted cannot be opened for edit. ");
				return;
				}
		}
	}
		
		
	
	var action="fill_table_details:::::fill_field_details";
	var div_id="div_tab_details:::::div_fields";
	var par1=tabid_script_id+":::::"+tabid_script_id;
	var par2=curr_env_id+":::::"+"0";
	var par3="x:::::"+curr_env_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	showModal("tableEditorDiv");
	
	//$('#tableEditorDiv').on('hidden.bs.modal', function () {fillAppTabList();});
	
}

//*****************************
function closeTableEditor() {
	
	$("#tableEditorDiv").modal("hide");
}

//*****************************
function setTableFieldFilterCheck(tab_id, obj) {
	var is_checked=obj.checked;
	var filter="x";
	if (is_checked) filter="checked";
	
	var action="set_field_filter:::::fill_field_details";
	var div_id="NONE:::::div_fields";
	var par1=tab_id+":::::"+tab_id;
	var par2=filter+":::::0";
	var par3="x:::::"+curr_env_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//*****************************
function changeDiscoveryFlag(tabid, discovery_flag) {

	

		var action="change_discovery_flag:::::fill_app_table";
		var div_id="NONE:::::div_app_table";
		var par1=tabid+":::::"+curr_app_id;
		var par2=discovery_flag+":::::x";
	
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);

	
	
}

//-----------------------------------------------------------------
function showSqlEditor(env_id, tab_id, tab_name, sql, cat) {

	
	
	var action="show_sql_editor";
	var div_id="sqlBody";
	var par1=env_id;
	var par2=tab_id;
	var par3=tab_name;
	var par4=sql;
	var par5=cat;
	
	if (tab_name.indexOf(".")==0) {
		par3=tab_name.substr(1);
	}
	
	if (tab_name.indexOf("null.")==0) {
		par3=tab_name.substr(5);
	}
	

	$("#sqlDiv").modal("show");
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
}



//*************************************************************************
function changeSqlEditorEnvironment() {
	
	var action="make_sql_editor_catalog_combo";
	var div_id="sqlEditorCatComboDiv";
	var par1=document.getElementById("sql_editor_env_id").value;
	

	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
/*
//*************************************************************************
function showcontent(){
//*************************************************************************
	var tab=document.getElementById("tableList").value;
	var arr=tab.split("*");
	var tab_name=arr[0]+"."+arr[1];
	if (arr[0]=="" || arr[0]=="null") tab_name=arr[1];
	
	showSqlEditor(curr_env_id,0,tab_name,"");
};
*/
//*************************************************************************
function runPreQueryExecution() {
	document.getElementById("sqlEditorQueryButton").disabled=true;
	
}//*************************************************************************
function runPostQueryExecution() {
	document.getElementById("sqlEditorQueryButton").disabled=false;
}


//*************************************************************************
function fillSqlEditorResult() {
	
	var env_id=document.getElementById("sql_editor_env_id").value;
	var query_catalog=document.getElementById("query_catalog").value;
	var sql_statement=document.getElementById("sql_statement").value;
	var querying_table=document.getElementById("querying_table").value;
	
	
	var action="fill_sql_editor_results";
	var div_id="sqlEditorResultsDiv";
	var par1=env_id;
	var par2=query_catalog;
	var par3=sql_statement;
	var par4=querying_table;
	
	
	runPreQueryExecution();

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}


//*************************************************************************
function showtable(envid,tabid,tabname,reccnt,filter){
//*************************************************************************
	var url="showtablecontent.jsp?envid="+envid+"&reccnt=" + reccnt + "&tabid=" + tabid+ "&tabname=" + tabname + "&filter=x";
	window.open (url,"mywindow");
};



//*************************************************************************
function showcontentbytabid(filter_tab_id){
//*************************************************************************
	showSqlEditor(curr_env_id,filter_tab_id,"","","");
}



//********************************************
function addTableAsChild(table_name) {
//********************************************
	var el;
	var field;
	var rel_on_fields="";
	var family_id="0";
	
	var familyel=document.getElementById("curr_family_id");
	if (familyel) family_id=familyel.value;
	
	
	for (var i=0;i<100;i++) {
		el=document.getElementById("fk_field_"+i);
		if (!el) break;
		
		field=el.value;
		
		if (field.length==0) {
			myalert("Should match each primary keys to proceed.");
			return;
		}
		
		if (i>0) rel_on_fields=rel_on_fields+",";
		rel_on_fields=rel_on_fields+field;

	}
	
	if (rel_on_fields=="") {
		myalert("There must be at least one relation key defined.");
		return;
	}
	
	
	var table_name=document.getElementById("child_tab_name").value;

	var parent_tab_id=document.getElementById("parent_table").value;
	
	if (parent_tab_id=="") {
		myalert("select a parent table to proceed.");
		return;
	}
	
	var action="add_new_table:::::fill_app_table";
	var div_id="NONE:::::div_app_table";
	var par1=table_name+":::::"+curr_app_id;
	var par2=curr_env_id+":::::"+"x";
	var par3=curr_app_id+":::::"+"x";
	var par4=parent_tab_id+":"+rel_on_fields+":::::x";
	var par5=document.getElementById("rel_type").value+":::::x";
	var par6=family_id+":::::x";
	
	var child_tab_id=document.getElementById("curr_child_tab_id").value;

	
	
	
	if (child_tab_id!="0") {
		
		action="update_table_relation:::::fill_app_table:::::refill_parent_table_info";
		div_id="NONE:::::div_app_table:::::parentTabInfoDiv"+child_tab_id;
		par1=child_tab_id+":::::"+curr_app_id+":::::"+child_tab_id;
		par2=parent_tab_id+":::::x:::::x";
		par3=rel_on_fields+":::::x:::::x";
		par4=document.getElementById("rel_type").value;+":::::x:::::";
		
		
		
	}
	
	$("#childTableDiv").modal("hide");
	

	ajaxDynamicComponentCaller(action, div_id, par1,par2,par3,par4, par5, par6);
	
}


//***********************************************************
function addTableAsChildFromDiscovery(parent_tab_id, table_name, rel_on_fields, family_id) {
//***********************************************************
	
	if (family_id=="" || family_id=="0") {
		myalert("Family of parent table not set.");
		return;
	}
	
	bootbox.confirm("Sure to add this table as a child?", function(result) {
		
		if(!result) return;

		var action="add_new_table";
		var div_id="NONE";
		var par1=table_name;
		var par2=curr_env_id;
		var par3=curr_app_id;
		var par4=parent_tab_id+":"+rel_on_fields;
		var par5="HAS";
		var par6=family_id;
		
		
		ajaxDynamicComponentCaller(action, div_id, par1,par2,par3,par4, par5, par6);
		
	}); 
}

var curr_parent_tab_id="";



//********************************************
function addTableAndLink(parent_tab_id,table_name,child_tab_id, family_id) {
//********************************************
	showModal("childTableDiv");
	
	curr_tab_name=table_name;
	curr_parent_tab_id=parent_tab_id;
	
	
	
	var action="show_table_add";
	var div_id="childTableBody";
	var par1=parent_tab_id;
	var par2=table_name;
	var par3=curr_app_type;
	var par4=curr_env_id;
	var par5=child_tab_id;
	var par6=family_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5, par6);

}




//*****************************
function showtabconfig(tab_id) {
	
	var action="make_table_config_menu";
	var div_id="tableConfigBody";
	var par1=tab_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
	$("#tableConfigDiv").modal("show");
}

//*****************************
function saveTableConfiguration() {
	
	var config_tab_id=document.getElementById("config_tab_id").value;
	var skip_drop_index="NO";
	var skip_drop_constraint="NO";
	var skip_drop_trigger="NO";
	
	
	if (document.getElementById("skip_drop_index").checked) skip_drop_index="YES";
	if (document.getElementById("skip_drop_constraint").checked) skip_drop_constraint="YES";
	if (document.getElementById("skip_drop_trigger").checked) skip_drop_trigger="YES";
	
	var hint_after_select="";
	var hint_before_table="";
	var hint_after_table="";
	
	var check_existence_action="";
	var check_existence_sql="";
	var check_existence_on_fields="";
	
	var isel=document.getElementById("hint_after_select");
	if (isel) {
		hint_after_select=document.getElementById("hint_after_select").value;
		hint_before_table=document.getElementById("hint_before_table").value;
		hint_after_table=document.getElementById("hint_after_table").value;
		
		
		
		var icopy=document.getElementById("check_existence_action"); 
		
		if (icopy) {
			check_existence_action=document.getElementById("check_existence_action").value;
			check_existence_sql=document.getElementById("check_existence_sql").value;
			check_existence_on_fields=document.getElementById("check_existence_on_fields").value;
		}
		else {
			check_existence_action="";
			check_existence_sql="";
			check_existence_on_fields="";
		}
		
		
	}
	
	
	
	var action="save_table_config";
	var div_id="NONE";
	var par1=config_tab_id;
	var par2=skip_drop_index+":"+skip_drop_constraint+":"+skip_drop_trigger;
	var par3=hint_after_select+"|::|"+hint_before_table+"|::|"+hint_after_table;
	var par4=check_existence_action;
	var par5=check_existence_sql;
	var par6=check_existence_on_fields;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5, par6);
	
	
	$("#tableConfigDiv").modal("hide");
}

//*****************************
function refreshLinkDlg() {
	var parent_tab_id=document.getElementById("parent_table").value;
	var child_tab_id=document.getElementById("curr_child_tab_id").value;
	var tab_name=document.getElementById("child_tab_name").value;

	
	addTableAndLink(parent_tab_id,tab_name,child_tab_id);
}


//------------------------------------------------------------------
function addTableToApp(table_name) {
	
	if (curr_app_type!="COPY") {
		
		
		
		addTableToAppDo(table_name, '0');
		return;
	} 
		
	
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Family";
	var par2="family_list";
	var par3="x";
	var par4="x";
	var par5="addTableToAppDo('"+table_name+"','#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}


//*****************************
function addTableToAppDo(table_name, family_id) {
	
	var elapp=document.getElementById("filter_app_id");
	
	if (elapp.value=="") {
		myalert('Should pick an application');
		return;
	}
	
	

	if (curr_app_type=="COPY") {
		
		var elroot=document.getElementById("roottable");
		
		
			
		
		var elradiochecked=document.querySelector('input[name="selecttable"]:checked'); 
		
		
		var selected_tab_id="0";
		
			
		try{selected_tab_id=elradiochecked.value;} catch(err) {selected_tab_id="0";}
					
		if (selected_tab_id!="0") {
			addTableAndLink(selected_tab_id,table_name,"0", family_id);
			return;
		}
				
	}
	
	curr_tab_name=table_name;


	var action="add_new_table";
	var div_id="NONE";
	var par1=table_name;
	var par2=curr_env_id;
	var par3=curr_app_id;
	var par4="0";
	var par5="0";
	var par6=family_id;


	

	
	ajaxDynamicComponentCaller(action, div_id, par1,par2,par3,par4,par5,par6);

		
	
}

//*****************************
function removeTableFromAppDiscovery(app_id, tab_id, discovery_id, match_rate) {
	curr_app_id=app_id;
	
	bootbox.confirm("Are you sure to delete this table from the application?", function(result) {
		
		if(!result) return;

		var action="remove_table_from_app:::::show_discovery_copying_report";
		var div_id="NONE:::::discBody";
		var par1=tab_id+":::::"+discovery_id;
		var par2="x:::::"+match_rate;
		var par3="x:::::"+document.getElementById("parent_table").value;
	
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

	}); 
	
}
//*****************************
function removeTableFromApp(tab_id) {
	
	
	bootbox.confirm("Are you sure to delete this table from the application?", function(result) {
		
		if(!result) return;
		
		curr_tab_id="";
		
		var curr_env_id=document.getElementById("envList").value;

		var action="remove_table_from_app";
		var div_id="NONE";
		var par1=tab_id;
		var par2=curr_env_id;
	
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);

	}); 
	
}

//*****************************************************
function showAppListForTable(table_cat, table_owner, table_name) {
	
	var app_type=document.getElementById("filter_app_type").value;
	
	var action="show_app_list_for_table";
	var div_id="appListForTableBody";
	var par1=table_owner;
	var par2=table_owner;
	var par3=table_name;
	var par4=app_type;

	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	$("#appListForTableDiv").modal();
	
}

function redrawTableCell(env_id, table_cat, table_owner, table_name) {
	
	var divIDTarget="tableCellDivFor"+table_cat+"."+table_owner+"."+table_name;
	
	var divTarget=document.getElementById(divIDTarget);
	
	if (!divIDTarget) {
		console.log("Div not found id : "+divIDTarget);
		return;
	}
	
	var app_type=document.getElementById("filter_app_type").value;
	
	var action="redraw_table_cell";
	var div_id=divIDTarget;
	var par1=env_id;
	var par2=table_cat;
	var par3=table_owner;
	var par4=table_name;
	var par5=app_type;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4,par5);
	
	
}




//********************************************
function myalert(msg1) {
//********************************************
	bootbox.alert(msg1);
}

var curr_list_id=-1;

//***********************************************
function loadListofList() {
//***********************************************
	clearDivContent("itemsofListDiv");
	
	var action="list_of_list";
	var div_id="listofListDiv";
	var par1="";
		
	if (curr_list_id>-1) {
		action=action+":::::items_of_list";
		div_id=div_id+":::::itemsofListDiv";
		par1=par1+":::::"+curr_list_id;
	}
	
	ajaxDynamicComponentCaller(action, div_id, par1);
 
	
}



//***********************************************
function openListItems() {
//***********************************************
	var elt1 = document.getElementById("listList");
	if(elt1.selectedIndex==-1) {
		myalert('Should pick a list to open');
		return;
	}
	var list_id=elt1.value;
	
	curr_list_id=parseInt(list_id);
	
	var action="items_of_list";
	var div_id="itemsofListDiv";
	var par1=list_id;
	
	
	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
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





//**************************************************
function addNewList() {
//**************************************************
	bootbox.prompt("Enter list name to add ", function(result) {                
		  if (result !== null) {
			  
			  if (result.length==0) {
				  myalert("list name cannot be empty");
				  return;
			  }
			  
			  clearDivContent("itemsofListDiv");
			  
			  	
			    var action="add_new_list";
				var div_id="NONE";
				var par1=result;  
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
				
		    
		  }
		});	
}



//*****************************
function deleteList() {
	
	var elt1 = document.getElementById("listList");
	if(elt1.selectedIndex==-1) {
		myalert('Should pick a list to delete');
		return;
	}
	var list_id=elt1.value;
	
	bootbox.confirm("Are you sure to delete this list?", function(result) {
		
		if(!result) return;


		var action="delete_list";
		var div_id="NONE";
		var par1=list_id;  
		
		ajaxDynamicComponentCaller(action, div_id, par1);

	}); 
	
	
}


//*****************************
function renameList() {
	
	var elt1 = document.getElementById("listList");
	if(elt1.selectedIndex==-1) {
		myalert('Should pick a list to rename');
		return;
	}
	var list_id=elt1.value;
	var list_name=elt1.options[elt1.selectedIndex].text;
	
	bootbox.prompt("Enter list name ("+list_name+") : ", function(result) {                
		  if (result !== null) {
			  
			  if (result.length==0) {
				  myalert("list name cannot be empty");
				  return;
			  }
			  			  
			  	clearDivContent("itemsofListDiv");
			  	
			  	var action="rename_list";
				var div_id="NONE";
				var par1=list_id;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
				
		    
		  }
		});	
	
	
}

//***********************************************
function uploadFromFile() {
//***********************************************
	
	
	var elt1 = document.getElementById("listList");
	if(elt1.selectedIndex==-1) {
		myalert('Should pick a list to upload a file');
		return;
	}
	var list_id=elt1.value;
	
	var html=""+
		"<form action=\"uploadFile2.jsp\" method=\"post\" enctype=\"multipart/form-data\">"+
		"<h3>Select File To Upload</h3> \n" +
		"	<div class=\"form-group\">"+
		"		<input id=\"file\" name=\"file\" type=\"file\" multiple=true data-preview-file-type=\"any\">"+
		"	</div>"+
		"</form>"+
		""+
		"<script>\n"+
		"$(\"#file\").fileinput({ \n"+
		"maxFileSize: 100000, \n"+
		"maxFilesNum: 1, \n"+
		"});"+
		"</script>";
	
	
	
	
bootbox.alert(html); 
	
}




//***********************************************
function downloadListToFile() {
//***********************************************
	
	
	var elt1 = document.getElementById("listList");
	if(elt1.selectedIndex==-1) {
		myalert('Should pick a list to download content');
		return;
	}
	var list_id=elt1.value;
	
	var url="downloadlist.jsp?listid="+list_id;
	window.open (url,"mywindow");
	
}






//****************************************
function savetabinfo() {
//***************************************	
	if (curr_tab_id.length==0) {
		myalert("Select a table first.");
	}
	
	if (is_table_filter_validated==false) {
		myalert("Table filter has been changed but not validated yet. Validate it firts before proceeding. ");
	}
	
	if (is_table_parallel_mod_validated==false) {
		myalert("Table parallelism formula has been changed but  not validated yet. Validate it firts before proceeding. ");
	}
	
	var tab_desc="";
	var mask_level="";
	var tab_filter="";
	var parallel_mod="";
	var parallel_field="";
	var partition_use="NO";
	var family_id="0";
	var rollback_needed="YES";
	var export_plan="EXPORT_MASKING";

	tab_desc=document.getElementById("tab_desc").value;	
	tab_filter=document.getElementById("tab_filter").value;
	try {parallel_mod=document.getElementById("parallel_mod").value;} catch(e) {parallel_mod="1";}
	try {parallel_field=document.getElementById("parallel_field").value;} catch(e) {parallel_field="1";}
	try {partition_use=document.getElementById("partition_use").value;} catch(e) {partition_use="NO";}
	try {family_id=document.getElementById("family_id").value;	} catch(e) {family_id="0";}
	try {rollback_needed=document.getElementById("rollback_needed").value;	} catch(e) {rollback_needed="YES";}
	try {export_plan=document.getElementById("export_plan").value;	} catch(e) {export_plan="EXPORT_MASKING";}

	
	var tab_info_summary="";
	
	tab_info_summary=tab_info_summary + tab_desc +"::";
	tab_info_summary=tab_info_summary + tab_filter +"::";
	tab_info_summary=tab_info_summary + parallel_mod +"::";
	tab_info_summary=tab_info_summary + parallel_field +"::";
	tab_info_summary=tab_info_summary + partition_use +"::";
	tab_info_summary=tab_info_summary + family_id +"::";
	tab_info_summary=tab_info_summary + rollback_needed +"::";
	tab_info_summary=tab_info_summary + export_plan +"";

	
	
	var action="save_table_info:::::fill_table_details";
	var div_id="NONE:::::div_tab_details";
	var par1=curr_tab_id+":::::"+curr_tab_id;
	var par2=tab_info_summary+":::::"+curr_env_id;
	
	//myalert(par2);
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2); 
	
	
}


//****************************************
function showsample() {
//***************************************	
	var sample=""+
		"<h4>This statments should generate numerical results :</h4><hr> "+
		"CUSTOMER_ID<br>"+
		"ROUND(CUSTOMER_ID/10)<br>"+
		"ASCII(SUBSTR(NVL(CITY_CODE,'X'),-1,1))<br>"+
		"TO_NUMBER(TO_CHAR(UPD_DATE,'MMDD'))";
	
	myalert(sample);
}

//****************************************
function showmongosample() {
//***************************************	
	var sample=""+
		"<h4><big><b>?</b></big> represents paralellism number :</h4><hr> "+
		"<textarea rows=10 style=\"width:100%;\">"+
		"Last Character :  "+
		"{\"restaurant_id\":{ \"$regex\": \".{0,}[?]$\" } }"+
		"\n\n"+
		"First Character :  "+
		"{\"restaurant_id\":{ \"$regex\": \"^[?].{0,}$\" } }"+
		"\n\n"+
		"</textarea>";
	
	
	
	myalert(sample);
}




//***********************************************
function validateTableFilter() {
//***********************************************
	
	if (curr_env_id.length==0) {
		myalert("Pick an environment to validate the filter.");
		is_table_filter_validated=false;
		return;
	}
	
	if (curr_tab_id.length==0) {
		myalert("Select a table first.");
		is_table_filter_validated=false;
		return;
	}
	
		
	var tab_filter="";
	tab_filter=document.getElementById("tab_filter").value;
	
	

	//if (tab_filter.length==0) return;
	
	is_table_filter_validated=false;
	
	var action="validate_table_filter";
	var div_id="NONE";
	var par1=curr_tab_id;
	var par2=tab_filter;
	var par3=curr_env_id;
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3); 	
}


//***********************************************
function validateTableParallelField() {
//***********************************************
	
	if (curr_env_id.length==0) {
		myalert("Pick an environment to validate the parallism formula.");
		is_table_filter_validated=false;
		return;
	}
	
	if (curr_tab_id.length==0) {
		myalert("Select a table first.");
		is_table_filter_validated=false;
		return;
	}
	
		
	var parallel_field="";
	parallel_field=document.getElementById("parallel_field").value;
	
	

	//if (parallel_field=="1" || parallel_field=="0") return;
	
	is_table_parallel_mod_validated=false;
	var action="validate_parallel_field";
	var div_id="NONE";
	var par1=curr_tab_id;
	var par2=parallel_field;
	var par3=curr_env_id;
	


	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3); 	
}


//*************************************
function showTableValidationResults() {
//*************************************
	

	var el=document.getElementById("tab_filter");
	
	if (el) {
		if (!is_table_filter_validated) 
			el.style.backgroundColor="#FFA100";
		else {
			el.style.backgroundColor="";
		}
		
	}
	
	
	var el=document.getElementById("parallel_field");
	
	if (el) {
		if (!is_table_parallel_mod_validated) 
			el.style.backgroundColor="#FFA100";
		else {
			el.style.backgroundColor="";
		}
	}
	
	
}

//*************************************
function isEnvSelected() {
	if (curr_env_id.length==0) {
		myalert("Select environment to change this field");
		return false;
	}
	
	return true;
}


//*************************************
function mynotification(msgx) {
//*************************************
myalert(msgx);
}


//**************************************
function changeFieldConfig(field_id, field_name, field_value) {
	
	var action="change_field_config:::::fill_field_details";
	var div_id="NONE:::::tr_field_"+field_id;
	var par1=field_id+":::::"+curr_tab_id;
	var par2=field_name+":::::"+field_id;
	var par3=field_value+":::::"+curr_env_id;


	if (field_name=='delete')
		bootbox.confirm("Are you sure to delete this field?", function(result) {
			
			if(!result) return;

			div_id="NONE:::::div_fields";
			par2=field_name+":::::0";

			ajaxDynamicComponentCaller(action, div_id, par1, par2, par3); 	
		}); 
	else
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3); 	
	
}


var curr_script_type="";

//*************************************************************************
function scriptedit(script_type) {
//*************************************************************************
	var app_id=document.getElementById("filter_app_id").value;
	
	if (app_id.length==0) {
		myalert("You should select an application to show script editor.");
		return;
	}
	
	
	
	curr_script_type=script_type;
	document.getElementById("scriptTitle").innerHTML="<h3>Script Editor ["+script_type+"]</h3>";
	showModal("scriptDiv");
	
	var action="get_app_script";
	var div_id="scriptBody";
	var par1=curr_app_id;
	var par2=curr_script_type;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);

}

//****************************************************
function saveScript() {
	var action="save_app_script";
	var div_id="NONE";
	var par1=curr_app_id;
	var par2=curr_script_type;
	var par3=document.getElementById("ascript").value;

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

	$("#scriptDiv").modal("hide");

}







//*********************************************

function showAttachment(step_id) {
	var action="open_attachment";
	var div_id="showAttachmentMain";
	var par1=step_id;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("showAttachmentDiv");
}

//*********************************************
function applicationBox(app_action) {
	
	if ((app_action=="RENAME" ||app_action=="REMOVE") && curr_app_id.length==0) {
		myalert("You should select an application to " + app_action);
		return;
	}
	
	if (app_action=="REMOVE") {
		bootbox.confirm("Are you sure to delete this application?", function(result) {
			
			if(!result) return;
			/*
			var action="remove_application:::::fill_app_list";
			var div_id="NONE:::::div_app";
			var par1=curr_app_id+":::::"+curr_app_type;
			*/
			var action="remove_application";
			var div_id="NONE";
			var par1=curr_app_id;
			ajaxDynamicComponentCaller(action, div_id, par1);
			
			curr_app_id="";
		}); 
		
	} 
	else
	{
		
		bootbox.prompt("Enter application name to " + app_action, function(result) {                
			  if (result !== null) {
				  
				  if (result.length==0) {
					  myalert("application name cannot be empty");
					  return;
				  }

				
					
					
				  if (app_action=="ADD") {
					    var action="add_application:::::fill_app_list";
						var div_id="NONE:::::div_app";
						var par1=curr_app_type+":::::"+curr_app_type;
						var par2=result+":::::x";
							
						ajaxDynamicComponentCaller(action, div_id, par1, par2);
				  }
				  
				  if (app_action=="RENAME") {
					    var action="rename_application:::::fill_app_list";
						var div_id="NONE:::::div_app";
						var par1=curr_app_id+":::::"+curr_app_type;
						var par2=result+":::::"+curr_app_id;
							
						ajaxDynamicComponentCaller(action, div_id, par1, par2);
				  }
				  
				  
			  }
			});	
	}
	
	
}

var curr_condition_field_id="";
var curr_condition_field_name="";

//**************************************************
function openConditionEditor(field_id, field_name, session_field_name, session_field_value) {
	
	document.getElementById("conditionEditorTitle").innerHTML="<h4>Condition Editor for : <b>[" + field_name +"]<b></h4>";
	showModal("conditionEditor");
	if (session_field_name=="") {
		var action="draw_condition";
		var div_id="conditionEditorBody";
		var par1=field_id;
		
		curr_condition_field_id=field_id;
		curr_condition_field_name=field_name;
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	}
	else 
		{
		var action="set_session_attribute:::::draw_condition";
		var div_id="NONE:::::conditionEditorBody";
		var par1=session_field_name+":::::"+field_id;
		var par2=session_field_value+":::::x";

		ajaxDynamicComponentCaller(action, div_id, par1,par2);
		}
		
	
}




//****************************************************
function removeCondition(condition_item_id) {
	
	
	bootbox.confirm("Are you sure to delete this condition item?", function(result) {
		
		if(!result) return;

		var action="remove_condition_item:::::draw_condition";
		var div_id="NONE:::::conditionEditorBody";
		var par1=curr_condition_field_id+":::::"+curr_condition_field_id;
		var par2=(condition_item_id-1)+":::::x";
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
	}); 
	
}


//****************************************************
function buildConditionExpr(condition_item_id) {
	var err_msg="";

	var el_field=document.getElementById("condition_field_"+condition_item_id);
	var el_operand=document.getElementById("condition_operand_"+condition_item_id);
	var el_value=document.getElementById("condition_value_"+condition_item_id);
	var el_mask_prof_id=document.getElementById("condition_mask_prof_"+condition_item_id);
	var el_list_field_name=document.getElementById("condition_list_field_name_"+condition_item_id);
	var el_list_field_fixed=document.getElementById("condition_list_field_fixed_"+condition_item_id);
	
	var el_mask_prof_id_else=document.getElementById("condition_mask_prof_else");
	if (el_field.value.length==0) 
		err_msg=err_msg + "<br>"+ "Please select a field.";
	
	if (el_operand.value.length==0) 
		err_msg=err_msg + "<br>"+ "Please select a operand.";
	
	if (el_value.value.length==0) 
		err_msg=err_msg + "<br>"+ "Please type a value to check.";
	
	if (el_mask_prof_id.value.length==0) 
		err_msg=err_msg + "<br>"+ "Please select a masking profile to apply.";
	
	if (el_list_field_name) 
		if (el_list_field_name.value.length==0)
			err_msg=err_msg + "<br>"+ "Please select a list column name.";
	
	if (!el_mask_prof_id_else || el_mask_prof_id_else.value.length==0) 
		err_msg=err_msg + "<br>"+ "Please select which profile to apply for ELSE/CATCH ALL case.";

	if (err_msg.length>0) {
		myalert(err_msg);
		return "";
	}

	if (el_list_field_name) {
		var list_field_name=el_list_field_name.value;
		if (el_list_field_fixed.checked) list_field_name=list_field_name+":FIXED";
		
		return "IF[${"+el_field.value+"}::"+el_operand.value+"::"+el_value.value+"::MASK("+el_mask_prof_id.value+":"+list_field_name+")]";
	}
	else
		return "IF[${"+el_field.value+"}::"+el_operand.value+"::"+el_value.value+"::MASK("+el_mask_prof_id.value+")]";

	
}

//****************************************************
function saveCondition(condition_item_id) {
	
	var condition_expr="";
	
	if (condition_item_id>-1) {
		condition_expr=buildConditionExpr(condition_item_id);
		if (condition_expr.length==0) return;
	}
	
	if (condition_item_id==-1) {
		var el1=document.getElementById("condition_field_1");
		if (!el1) {
			myalert("You should add at least one condition to change ELSE condition");
			return;
		}
	}
	
	var else_prof_mask_id=document.getElementById("condition_mask_prof_else").value;
	var el_else_list_field_name=document.getElementById("list_field_name_else");
	if (else_prof_mask_id.length==0) {
		else_prof_mask_id="0";
	}
	
	if (el_else_list_field_name) {
		var list_field_name=el_else_list_field_name.value;
		if (list_field_name=="") 
			list_field_name="x";
		
		else_prof_mask_id =else_prof_mask_id +":"+list_field_name;
	}
	
	var else_expr=else_prof_mask_id;
	var el_else_list_field_name=document.getElementById("condition_list_field_name_-1");
	var el_else_list_field_fixed=document.getElementById("condition_list_field_fixed_-1");
	
	if(el_else_list_field_name)
		else_expr=else_expr+":"+el_else_list_field_name.value;
	
	if (el_else_list_field_fixed) 
		if (el_else_list_field_fixed.checked) else_expr=else_expr+":FIXED";
	
	
	else_expr="ELSE[MASK("+ else_expr +")]";
	
	var action="save_condition_item:::::draw_condition";
	var div_id="NONE:::::conditionEditorBody";
	
	var par1=curr_condition_field_id+":::::"+curr_condition_field_id;
	var par2=condition_item_id+":::::x";
	var par3=condition_expr+":::::x";
	var par4=else_expr+":::::x";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}


//*************************************************************************
function openRunDialog() {
//*************************************************************************
	var app_id=document.getElementById("filter_app_id").value;
	var env_id=document.getElementById("envList").value;
	
	if (app_id.length==0) {
		myalert("You should select an application to run.");
		return;
	}
	
	
	if (env_id.length==0) {
		myalert("You should select an environment  to run.");
		return;
	}
	
	if (curr_app_type=="COPY") {
		myalert("copy run is not allowed here. Use [<a href=\"copy.jsp\">Copy</a>] screen instead.");
		return;
	}
	
	if (curr_app_type=="DMASK") {
		myalert("dynamic masking is not allowed here. Use [<a href=\"dm.jsp\">Protect</a>] screen instead.");
		return;
	}
	
	if (curr_app_type=="DPOOL") {
		myalert("copy run is not allowed here. Use [<a href=\"datapool.jsp\">Pool</a>] screen instead.");
		return;
	}
	
	var action="open_run_dialog";
	var div_id="runnerBody";
	
	var par1=curr_app_type;
	var par2=curr_app_id;
	var par3=curr_env_id;
	
	
	showModal("runnerDiv");
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);


}

var last_target_env_id="";


//***********************************************
function fillSchemaChangeDiv(showhide) {
//***********************************************
	
	var eltargetenv=document.getElementById("target_env_id");
	
	
	var action="fill_schema_changer_div";
	var div_id="targetSetterDiv";
	var par1=showhide;
	var par2=curr_app_id;
	var par3=curr_env_id;
	var par4="-1";
	
	var elapptype=document.getElementById("filter_app_type");
	
	if (elapptype && elapptype.value=="COPY") {
		par4=eltargetenv.value;
		last_target_env_id=eltargetenv.value;
		
		
	}
	
	var elsourceenv=document.getElementById("source_env_id");
	
	if (elsourceenv) 
		par3=elsourceenv.value;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}


//***********************************************
function createWorkPlan() {
//***********************************************	

	var action="create_work_plan";
	var div_id="NONE";
	
	
	var par1=curr_app_type;
	
	
	var direct_masking=false;
	var directMEl=document.getElementById("direct_masking");
	if (directMEl)  direct_masking=directMEl.checked;
	if (direct_masking) par1="MASK2";
		
	var par2=curr_app_id;
	//var par3=curr_env_id;
	var par3="0";
	
	
	par3=document.getElementById("source_env_id").value;
	
	
	var par4=run_paramaters="";
	var par5="0"; //target_env_id
	
	
	
	
	var elemail=document.getElementById("email_address");
	if (elemail && elemail.value.length>0) {
		if (!testRegex(elemail.value,"^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$")) {
			myalert("Email address is invalid.");
			return;
		}
	}
	
	
	
	
	

	var target_owner_info="";

	var elcurrentschema=document.getElementById("source_schema_0");
	var elcurrenttable=document.getElementById("source_table_0");
	var eltargetschema=document.getElementById("target_schema_0");
	var eltargettable=document.getElementById("target_table_0");
	
	var elorigtable=document.getElementById("orig_table_name_0");
	
	
	if (elorigtable) {
		
		
		changed=0;
		for (var i=0;i<10000;i++) {
			
			elcurrentschema=document.getElementById("source_schema_"+i);
			elcurrenttable=document.getElementById("source_table_"+i);
			
			
			eltargetschema=document.getElementById("target_schema_"+i);
			eltargettable=document.getElementById("target_table_"+i);
			
			
			
			if (!eltargetschema) {
				eltargetschema=elcurrentschema;
				eltargettable=elcurrenttable;
			}
			
			elorigtable=document.getElementById("orig_table_name_"+i);
			
			if (!elorigtable) break;
			
			if(elcurrentschema.value=="" || eltargetschema.value=="") {
				myalert("All schema must be set.");
				return;
			}
			
			if(elcurrenttable.value=="" || eltargettable.value=="") {
				myalert("All table names must be filled.");
				return;
			}
			
			
			//skip is unchanged
			changed++;
			if (
					elorigtable.value!=(elcurrentschema.value+"."+elcurrenttable.value)
					||
					elorigtable.value!=(eltargetschema.value+"."+eltargettable.value)
					) {
				if (changed>0) target_owner_info=target_owner_info+"\n";
				changed++;
				
				 target_owner_info=target_owner_info+
					elorigtable.value+
					"["+
					elcurrentschema.value+"."+elcurrenttable.value+
					":"+
					eltargetschema.value+"."+eltargettable.value+
					"]";
			} //if (elcurrentschema.value!=eltargetschema.value || elcurrenttable.value!=eltargettable.value)
			
			
				
		} //for (var i=0;i<100;i++)
		
	} //if (elorigtable)

	
		
	if (target_owner_info=="") target_owner_info="-";
	
	
		
	var copy_filter="0";
	var copy_filter_bind="-";
	var copy_rec_count="1";
	var copy_repeat_count="1";
	var email_address="-";
	
	

	
	//--------------------
	var run_options="";
	
	var skip_table_validation=document.getElementById("skip_table_validation").checked;
	
	if (skip_table_validation) 
		run_options=run_options+"SKIP_TABLE_VALIDATION=YES;";
	else 
		run_options=run_options+"SKIP_TABLE_VALIDATION=NO;";
	
	var skip_fieldcheck_validation=document.getElementById("skip_fieldcheck_validation").checked;
	if (skip_fieldcheck_validation) 
		run_options=run_options+"SKIP_FIELDCHECK_VALIDATION=YES;";
	else 
		run_options=run_options+"SKIP_FIELDCHECK_VALIDATION=NO;";

	
	
	//--------------------------------------------------------------------------------
	var depended_application="";
	var elwpdep=document.getElementById("depended_work_plan_list");
	if (elwpdep) {
		var wps=elwpdep.value.split("|::|");
		for (var i=0;i<wps.length;i++) {
			if (i>0)  depended_application=depended_application+",";
			depended_application=depended_application+wps[i];
		}
	}
	
	if (depended_application=="") depended_application="x";
	
	var execution_type="PARALLEL";
	try{execution_type=document.getElementById("work_plan_execution_type").value;} catch(err) {}
	
	var on_error_action="CONTINUE";
	try{on_error_action=document.getElementById("work_plan_on_error_action").value;} catch(err) {}
	
	var on_error_action="CONTINUE";
	try{on_error_action=document.getElementById("work_plan_on_error_action").value;} catch(err) {}
	
	var repeat_period="NONE";
	try{repeat_period=document.getElementById("repeat_period").value;} catch(err) {}
	
	var repeat_by="0";
	try{repeat_by=document.getElementById("repeat_by").value;} catch(err) {}
	
	
	//--------------------------------------------------------------------------------
	
	par4=	""+
			document.getElementById("work_plan_name").value +	"::::" +
			"ACTUAL:ACCURACY"+	"::::" +
			document.getElementById("start_date").value +	"::::" +
			document.getElementById("master_limit").value +	"::::" +
			document.getElementById("worker_limit").value +	"::::" +
			document.getElementById("REC_SIZE_PER_TASK").value +	"::::" +
			document.getElementById("TASK_SIZE_PER_WORKER").value +	"::::" +
			document.getElementById("UPDATE_WPACK_COUNTS_INTERVAL").value+	"::::" +
			target_owner_info + "::::" +
			copy_filter + "::::" +
			copy_filter_bind + "::::" +
			copy_rec_count + "::::" +
			copy_repeat_count + "::::" +
			email_address + "::::" +
			run_options + "::::" +
			depended_application+"::::"+
			execution_type+"::::"+
			on_error_action+"::::"+
			repeat_period+"::::"+
			repeat_by+"::::"+
			"";
	
	
	$('#runnerDiv').modal('hide');

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);


}

//****************************************************
function addMissingFields() {
	
	bootbox.confirm("Want to add new fields ?", function(result) {
		
		if(!result) return;

		var action="add_new_table:::::fill_field_details";
		var div_id="NONE:::::div_fields";
		var par1=curr_tab_id+":::::"+curr_tab_id;
		var par2=curr_env_id+":::::"+"0";
		var par3=curr_app_id+":::::"+curr_env_id;
		var par4="0:::::x";
		var par5="0:::::x";
		var par6="0:::::x";

		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3,  par4, par5, par6);

	}); 

}




//****************************************************************
function onmonitoringload2() {
	drawMonitoringAreas();
	
	
	
	
}

var monitoringinterval=null;

//****************************************************************
function setRefreshInterval(interval_type) {
	var el=document.getElementById("refresh_interval_for_"+interval_type);
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
		
		console.log("setting timer to "+refresh_interval);
	}
	
	var action="set_refresh_interval";
	var div_id="NONE";
	var par1=refresh_interval;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//****************************************************************
function drawMonitoringAreas() {
	var action="draw_monitoring_areas";
	var div_id="MonitoringContainerDiv";
	var par1="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1);
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
	
	bootbox.confirm("Are you sure to save work plan parameters?", function(result) {
		
		if(!result) return;
		
		var editing_work_plan_id=document.getElementById("editing_work_plan_id").value;
		var wp_email_address=document.getElementById("wp_email_address").value;
		var wp_execution_type=document.getElementById("wp_execution_type").value;
		var wp_on_error_action=document.getElementById("wp_on_error_action").value;
		var wp_REC_SIZE_PER_TASK=document.getElementById("wp_REC_SIZE_PER_TASK").value;
		var wp_master_limit=document.getElementById("wp_master_limit").value;
		var wp_worker_limit=document.getElementById("wp_worker_limit").value;
		var wp_repeat_period=document.getElementById("wp_repeat_period").value;
		var wp_repeat_by=document.getElementById("wp_repeat_by").value;
		var wp_repeat_parameters=document.getElementById("wp_repeat_parameters").value;
		

		var action="save_work_plan_parameters";
		var div_id="NONE";
		var par1=""+editing_work_plan_id;
		var par2=""+wp_email_address;
		var par3=""+wp_execution_type;
		var par4=""+wp_on_error_action;
		var par5=""+wp_REC_SIZE_PER_TASK+":"+wp_master_limit+":"+wp_worker_limit+":"+wp_repeat_period+":"+wp_repeat_by+":"+wp_repeat_parameters;


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

//***************************************************************
function setToOriginalScrollTops() {
	
	
	var el2=document.getElementById("discReportResult");
	if (el2) el2.scrollTop=div_discovery_scrollTop;
	
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


//****************************************************************
function setProcessStatus(process_type, process_id, process_action) {
	
	var confirm_msg="Manager will be stopped. Are you sure?"
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
	var refresh_interval=document.getElementById("refresh_interval_for_WORK_PLAN_LIST").value;
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
function skipValidation(wpid,caller) {
	
	
	
	bootbox.confirm("Are you sure to skip invalid status?", function(result) {
		
		if(!result) return;

		var action="skip_validation";
		var div_id="NONE";
		var par1=wpid;
		var par2=caller;

		ajaxDynamicComponentCaller(action, div_id, par1, par2);

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

//*************************************************************************
function changeListColName(list_id, fid,elid) {
	var msg="";
	var new_val=elid.value;
	
	var re = new RegExp("^[a-zA-Z_][a-zA-Z0-9_]*$");
	
	if (!new_val.match(re)) {
		msg=msg + "<br>" +"Column name should comply with variable name syntax. ";
	}
	
	//check duplication of name
	for (var i=0;i<100;i++) {
		var el=document.getElementById("col_name_"+i);
		if (!el) break;
		if (fid!=i) {
			if (el.value==new_val) {
				msg=msg + "<br>" +"Duplicated column name. ";
			}
		}
	}
	
	if (msg.length>0) {
		elid.style.background="red";
		myalert(msg);
		elid.focus();
		return;
	}
	
	elid.style.background="white";

	var new_title_list="";
	for (var i=0;i<100;i++) {
		var el=document.getElementById("col_name_"+i);
		if (!el) break;
		if (i>0) new_title_list=new_title_list+":";
		new_title_list=new_title_list+el.value;
	}



	
	var action="save_title_list";
	var div_id="NONE";
	var par1=list_id;
	var par2=new_title_list;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}


var curr_mask_prof_id=0;


//***********************************************
function loadListofProfile() {
//***********************************************
		var action="list_of_profile";
		var div_id="listofProfileDiv";
		var par1=""+curr_mask_prof_id;
		var par2="ALL"; //curr_app_type
		var par3="0"; //curr_field_id
		var par4="ALL"; //pick_for

		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
 
	
}



//**************************************************
function addNewProfile() {
//**************************************************
	bootbox.prompt("Enter profile name to add ", function(result) {                
		  if (result !== null) {
			  
			  if (result.length==0) {
				  myalert("profile name cannot be empty");
				  return;
			  }
			  
			  clearDivContent("profileDetailsDiv");
			  var action="add_new_profile";
			  var div_id="NONE";
			  var par1=result;  
				
			  ajaxDynamicComponentCaller(action, div_id, par1);
				
				
		    
		  }
		});	
}


//**************************************************************************
function openProfileDetail() {
	var mask_prof_id=document.getElementById("listProfile").value;
	
	
	curr_mask_prof_id=mask_prof_id;

    var action="details_of_profile";
	var div_id="profileDetailsDiv";
	var par1=mask_prof_id;  
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}


//**************************************************************************
function openProfileDetailByID(mask_prof_id) {
	curr_mask_prof_id=mask_prof_id;

    var action="details_of_profile";
	var div_id="profileDetailsDiv";
	var par1=mask_prof_id;  
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//*****************************
function deleteProfile() {
	var el=document.getElementById("p_rule_id");
	if (!el) return;
	
	var elt1 = document.getElementById("listProfile");
	if(elt1.selectedIndex==-1) {
		myalert('Should pick a profile to delete');
		return;
	}
	var profile_id=elt1.value;
	
	bootbox.confirm("Are you sure to delete this profile?", function(result) {
		
		if(!result) return;

		
		var action="delete_profile:::::list_of_profile:::::clear_div";
		var div_id="NONE:::::listofProfileDiv:::::profileDetailsDiv";
		var par1=profile_id+":::::x:::::x";  
		
		ajaxDynamicComponentCaller(action, div_id, par1);

	}); 
	
	
}




//*****************************
function renameProfile() {
	
	var el=document.getElementById("p_rule_id");
	if (!el) return;
	
	var elt1 = document.getElementById("listProfile");
	if(elt1.selectedIndex==-1) {
		myalert('Should pick a profile to rename');
		return;
	}
	var profile_id=elt1.value;
	var profile_name=elt1.options[elt1.selectedIndex].text;
	
	bootbox.prompt("Enter profile name ("+profile_name+") : ", function(result) {                
		  if (result !== null) {
			  
			  if (result.length==0) {
				  myalert("profile name cannot be empty");
				  return;
			  }
			  			  
			  var action="rename_profile:::::list_of_profile";
				var div_id="NONE:::::listofProfileDiv";
				var par1=profile_id+":::::x";
				var par2=result+":::::x";
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
				
		    
		  }
		});	
	
	
}



//*************************************************************************
function showsamplejs(){
//*************************************************************************

	document.getElementById('p_js_code').value="function calcul()\n"+
											 "{\n"+
											 "return \"${1}\";\n"+
											 "}\n\n"+
											 "var a=\"\";\n"+
											 "a=calcul();\n";
	
	document.getElementById('p_js_test_val').value="1=ABC";
}



//*************************************************************************
function testjs_code(){
//*************************************************************************
	
 var msg1='';
 var jsscript=document.getElementById('p_js_code').value;
 var par=document.getElementById('p_js_test_val').value;
 
 
 var parList = par.split(",");

 for (var i=0;i<parList.length;i++) {
	 var aPar=parList[i];
	
	 var aKey='';
	 var aVal='';
	 if (aPar.indexOf("=")>-1) {
		 aKey=aPar.split("=")[0];
		 aVal=aPar.split("=")[1];
		 
		 msg1=msg1+aKey+"="+aVal;
		 if(jsscript.indexOf("${"+aKey+"}")==-1) msg1=msg1+" <font color=red>*Not Such Parameter Found</font>";
		 else {
			 jsscript=jsscript.replace("${"+aKey+"}",aVal);
		 }
		 msg1=msg1 + "<br>";
	 }
 }
 
 if(parList.length==0) {
	 jsscript=jsscript.replace("${1}",par);
 }
 
 
 var ret1='';
 
 try {
	 ret1=eval(jsscript);
	 msg1=msg1+"<br>"+'Returns : [<font color=green><b>'+ ret1 +'</b></font>]';
 } catch (e) {
	        msg1=msg1+'<br>Error : <b><font color=red>'+e.message+'</font></b>';
	}
 

 document.getElementById("jsret").innerHTML=msg1;
 
 
 
};



//****************************************
function removePipes(instr) {
	var ret1=instr;
	/*
	while(true) {
		ret1=ret1.replace( new RegExp("\\|") , "::PIPE::");
		if (ret1.indexOf("|")==-1) break;
	}
	*/
	return ret1;
}


//*************************************************************************
function testsql_code(){
//*************************************************************************
	
var el=document.getElementById("env_id");
	
	if (el.value=="") {
		myalert("Should pick a db to test the script");
		return;
	}
	
	
	
	var action="test_sql_code";
	var div_id="sql_result";
	var par1=el.value;
	var par2=document.getElementById("p_js_code").value;
	var par3=document.getElementById("p_sql_test_val").value;
	
	
	var par4=curr_profile_pick_for;
	var par5="";
	
	try {par5=par5+curr_tab_id;} catch(Err) {}

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);

};

//*******************************************************
function changeProfileField(field_name,new_val) {
	var prof_id=curr_mask_prof_id;
	
	
	
	if (field_name=='hide_by_word') {
		var el=document.getElementById("hide_by_word");
		if (el) {
			var ischecked=el.checked;
			if (ischecked==true) new_val="YES";
			else new_val="NO";
		}
	}
	
	if (field_name=='date_change_params') {
		var p_day=document.getElementById("date_change_params_day").value;
		var p_month=document.getElementById("date_change_params_month").value;
		var p_year=document.getElementById("date_change_params_year").value;


		
		var day_int=0;
		var month_int=0;
		var year_int=0;
		
		try {day_int=parseInt(p_day);} 		catch(e) 	{myalert("Should be number.");  return;}
		try {month_int=parseInt(p_month);} 	catch(e) 	{myalert("Should be number.");  return;}
		try {year_int=parseInt(p_year);} 	catch(e) 	{myalert("Should be number.");  return;}
		
		
		if (day_int<0) day_int=0;
		if (day_int>28) day_int=28;

		if (month_int<0) month_int=0;
		if (month_int>12) month_int=12;
		
		if (year_int<0) year_int=0;
		if (year_int>100) year_int=100;
		
		
		new_val="day="+day_int+",month="+month_int+",year="+year_int;
	}
	
	
	if (field_name=='random_range') {
		var p_start=document.getElementById("random_range_start").value;
		var p_end=document.getElementById("random_range_end").value;
	
		var comparation_ok=false;
		try {
			if (parseInt(p_start)>parseInt(p_end)) p_start=p_end;
			else 
			if (parseInt(p_end)<parseInt(p_start)) p_end=p_start;
			comparation_ok=true;
		} catch(e) {
			
		}
		
		if (!comparation_ok) {
			if (p_start>p_end) p_start=p_end;
			else
			if (p_end<p_start) p_end=p_start;
		}
		
		new_val=p_start+","+p_end;
		
	}
	
	
	
    var action="change_profile_field:::::details_of_profile";
	var div_id="NONE:::::profileDetailsDiv";
	var par1=prof_id+":::::"+prof_id;  
	var par2=field_name+":::::x";
	var par3=new_val+":::::x";
	
	
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
}

var curr_profile_pick_for="MASK";

//*********************************************
function pickProfile(field_id, profile_id,pick_for) {
	
	curr_field_id=field_id;
	
	document.getElementById("profileDetailsDiv").innerHTML="";

	showModal("profileDiv");

	var action="list_of_profile";
	var div_id="listofProfileDiv";
	var par1=""+profile_id;
	var par2="x";
	var par3=""+field_id;
	var par4=pick_for;
	
	curr_profile_pick_for=pick_for;
	
	var el=document.getElementById("filter_app_type");
	if (el) par2=el.value;
	
	if (profile_id=="") par1="0";
	
	if (par1=="0")
		curr_mask_prof_id="";
	else
		{
		curr_mask_prof_id=""+profile_id;
		action=action+":::::details_of_profile";
		div_id=div_id+":::::profileDetailsDiv";
		par1=par1+":::::"+profile_id;
		par2="x:::::x";
		par3=""+field_id+":::::x";
		par4=pick_for+":::::x";
	}


	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
}
//*********************************************
function fillFieldDetails(field_id) {
	var action="fill_field_details";
	var div_id="tr_field_"+field_id;
	var par1=curr_tab_id;
	var par2=field_id;
	var par3=curr_env_id;
	
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//*********************************************
function setFieldProfile() {
	
	var selected_rule_id="";
	
	try {selected_rule_id=document.getElementById("p_rule_id").value;} catch(err) {}
	
	var keymap_field_id=document.getElementById("keymap_field_id").value;
	
	if (selected_rule_id=="KEYMAP" && keymap_field_id!="0") {
		myalert("This KeyMAP profile is already used for this table. Can be used once per table. ");
		return;
	}
	
	
	$("#profileDiv").modal("hide");
	
	var picked_profile_id=0;
	
	var el=document.getElementById("listProfile");
	
	if (!el) return;
	
	picked_profile_id=el.value;
	
	if (picked_profile_id=="") {
		myalert("No profile picked.");
		return;
	}
	
	
	var action="change_field_config";
	var div_id="NONE";
	var par1=curr_field_id;
	var par2="mask_prof_id";
	var par3=picked_profile_id;
	
	if (curr_profile_pick_for=="CALC")
		par2="calc_prof_id";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

}

//*********************************************
function openDiscoveryDialog() {
	
		
		var app_id=document.getElementById("filter_app_id").value;
		var env_id=document.getElementById("envList").value;
		
		var elsch=document.getElementById("ownerList");
		
		if (!elsch) {
			myalert("You should select a database to start discovery.");
			return;
		}
		
		var schema_name=document.getElementById("ownerList").value;
		if(schema_name=='') schema_name='All';
	
		if (app_id.length==0) {
			myalert("You should select an application to start discovery.");
			return;
		}



		if (env_id.length==0) {
			myalert("You should select an environment  to run.");
			return;
		}
		
		
		
		
		
	bootbox.confirm("Are you sure to start a discovery for this application?", function(result) {
		
		if(!result) return;

		
	    var action="create_new_discovery";
		var div_id="NONE";
		var par1=app_id;
		var par2=env_id;
		var par3=schema_name;
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	});	
}


var last_disc_rep_id='0';









//*******************************************
function showCopyingDiscoveryReport(discovery_wp_id) {
    
	
	var eldisc=document.getElementById("discReportResult");
	
	div_discovery_scrollTop=0;
	if (eldisc) 
		div_discovery_scrollTop=eldisc.scrollTop;

	
	
	var match_rate=20;
	
	var el=document.getElementById("result_rates");
	
	if (el) 
		match_rate=parseInt(el.value);
	
	var parent_table="";
	var el2=document.getElementById("parent_table");
	if (el2) parent_table=el2.value;


	var action="show_discovery_copying_report";
	var div_id="discBody";
	var par1=discovery_wp_id;
	var par2=""+match_rate;
	var par3=parent_table; 
	
	showModal("discDiv");
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

}

//*******************************************************************************************
function showAddTableToAppList(dis_wp_id, disc_id, table_name, disc_env_id, disc_app_id) {
	
	var action="make_application_list";
	var div_id="appListBody";
	var par1=""+dis_wp_id;
	var par2=""+disc_id;
	var par3=""+table_name;
	var par4=""+disc_env_id;
	var par5=""+disc_app_id;
	
	
	

	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	$("#appListDiv").modal("show");
	
}

//*******************************************************************************************
function addTableToAppFromDisMask(dis_wp_id, disc_id, table_name, disc_env_id, disc_app_id) {
	
	
	bootbox.confirm("Are you sure to add this to current application?", function(result) {
		
		if(!result) return;

		var action="add_new_table";
		var div_id="NONE";
		
		var par1=""+table_name;
		var par2=""+disc_env_id;
		var par3=""+disc_app_id;
		var par4=""+disc_id;
		var par5="0";
		var par6="0";
		
		ajaxDynamicComponentCaller(action, div_id, par1,par2,par3, par4, par5, par6);
		
		
		$("#appListDiv").modal("hide");
		
	});		
	
	
}


//*****************************
function setDiscoveryRelFilter(dis_wp_id, discovery_rel_id,filter) {
	
	var match_rate=document.getElementById("result_rates").value;
	
	var eldisc=document.getElementById("discReportResult");
	div_discovery_scrollTop=0;
	if (eldisc) 
		div_discovery_scrollTop=eldisc.scrollTop;
	
	var action="set_discovery_filter:::::show_discovery_copying_report";
	var div_id="NONE:::::discBody";
	var par1=discovery_rel_id+":::::"+dis_wp_id;
	var par2=filter+":::::"+match_rate;
	var par3="x:::::"+document.getElementById("parent_table").value;
	
	ajaxDynamicComponentCaller(action, div_id, par1,par2,par3);
}

//*********************************************************************
function setJdbcUrlTemplate() {
	
	var el=document.getElementById("db_driver");
	
	if (el.value=="") return;
	
	var action="set_jdbc_template";
	var div_id="NONE";
	var par1=el.value;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}




//*********************************************************************
function testConnectionByDbId(db_id) {

	var action="test_connection_by_db_id";
	var div_id="testConnectionBody";
	var par1=db_id;
		
	$("#testConnectionDiv").modal();
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

var list_sql_validated=false;

//***********************************************************************
function createListFromDB() {
//***********************************************************************
	var elt1 = document.getElementById("listList");
	if(elt1.selectedIndex==-1) {
		myalert('Should pick a list to upload a file');
		return;
	}
	
	
	var action="show_dblist_dialog";
	var div_id="listfromDB_body";
	var par1=""+elt1.value;

	list_sql_validated=false;
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("listfromDBDiv");
	
}



//***********************************************************************
function runListSql() {
//***********************************************************************
	var eltsql = document.getElementById("listsql");
	if(eltsql.value=="") {
		myalert('Should type a sql statement to execute');
		return;
	}
	
	var eltenv = document.getElementById("env_id");
	if(eltenv.value=="") {
		myalert('Should pick a database to execute sql');
		return;
	}
	
	
	var action="run_dblist_sql";
	var div_id="listItemsDiv";
	var par1=eltsql.value;
	var par2=eltenv.value;

	list_sql_validated=true;
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}


//***************************************************************
function refreshProcessWindow(ptype) {
	var pstatus="";
	try{pstatus=document.getElementById("process_status_filter").value;} catch(err) {}
	
	showProcessWindow(ptype,pstatus);
}

//***********************************************************************
function createDBList() {
//***********************************************************************
	var eltsql = document.getElementById("listsql");
	if(eltsql.value=="") {
		myalert('Should type a sql statement to execute');
		return;
	}
	
	var eltenv = document.getElementById("env_id");
	if(eltenv.value=="") {
		myalert('Should pick a database to execute sql');
		return;
	}
	
	if (!list_sql_validated || !document.getElementById("SQLOK")) {
		myalert('Please validate sql first');
		return;
	}
	
	
	var isok=false;

	try {
		parseInt(document.getElementById("itemcount").value);
		isok=true;
	} catch(err) {}
	
	if (!isok) {
		myalert('item count should be number');
		return;
	}
	
	var uniqueonly="NO";
	if (document.getElementById("uniqueonly").checked) uniqueonly="YES";
	
	var selected_fields="";
	
	var elfields=document.getElementById("selected_field_0");
	var selected_field_count=0;
	
	if (elfields) {
		for (var i=0;i<1000;i++) {
			elfields=document.getElementById("selected_field_"+i);
			if (!elfields) break;
			
			if (elfields.checked) {
				selected_field_count++;
				if (selected_field_count>1) selected_fields=selected_fields+",";
				selected_fields=selected_fields+elfields.value;
			}
			
		}
	}
	
	
	
	if (selected_fields.length==0) {
		myalert('At least a field should be selected');
		return;
	}
	
	
	var action="create_db_list";
	var div_id="NONE";
	var par1=document.getElementById("listList").value;
	var par2=eltenv.value;
	var par3=document.getElementById("itemcount").value;
	var par4=uniqueonly;
	var par5=selected_fields;
	
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	
	
	$("#listfromDBDiv").modal("hide");
}


//***********************************************************************
function selectallfields() {
//***********************************************************************
	var selection=document.getElementById("selected_all").checked;
	var el=document.getElementById("selected_field_0");
	if (el) 
		for (var i=0;i<1000;i++) {
			el=document.getElementById("selected_field_"+i);
			if (el) el.checked=selection;
			else break;
		}
}


//***********************************************************************
function copyFromField() {
//***********************************************************************
	
	
	var action="list_conditional_fields";
	var div_id="conditionCopyBody";
	var par1=curr_tab_id;
	var par2=curr_condition_field_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("conditionCopyDiv");
}

//**********************************************************************
function copyFromFieldDone() {
//**********************************************************************
var source_field_id=document.getElementById("copyFromFieldId").value;

if (source_field_id.length==0) {
	myalert("Pick a field to copy from.");
	return;
}


var action="copy_condition_from_field:::::draw_condition";
var div_id="NONE:::::conditionEditorBody";
var par1=curr_tab_id+":::::"+curr_condition_field_id;
var par2=source_field_id+":::::x";
var par3=curr_condition_field_id+":::::x";

ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);


$("#conditionCopyDiv").modal("hide");

	
}



//*************************************
function printabout() {
	
	var action="print_about";
	var div_id="aboutDiv";
	var par1="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1);

}



//****************************************
function addCalculatedField() {
	
	
	bootbox.prompt("Enter calculated field name: ", function(result) {                
		  if (result !== null) {
			  
			  if (result.length==0) {
				  myalert("field name cannot be empty");
				  return;
			  }
			  
			  if (result.length>30) {
				  myalert("field name is very long");
				  return;
			  }
			  
			  	var patt = new RegExp("^[a-zA-Z_][a-zA-Z0-9_]*$");
				var res = patt.test(result);
				
				if (res==false) {
				 myalert("field name is  not comply with naming convention");
				  return;
				}
				
				
				var action="add_new_calculated_field:::::fill_field_details";
				var div_id="NONE:::::div_fields";
				var par1=curr_tab_id+":::::"+curr_tab_id;
				var par2=result+":::::0";
				var par3="x:::::"+curr_env_id;
				
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
				
				
		    
		  }
		});	
	
}

	
//**************************************************
function openCopyTableDlg() {
//**************************************************

	var action="open_copy_table_dlg";
	var div_id="copyTableBody";

	var env_id=document.getElementById("envList").value;
	if (env_id=="") {
		myalert("Should pick database to proceed");
		return;
	}
	
	var par1=document.getElementById("filter_app_id").value;
	
	if (par1=="") {
		myalert("Should pick an application to copy to");
		return;
	}


	
	showModal("copyTableDiv");
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}





//**************************************************
function openBulkConfigDlg() {
//**************************************************
	var app_id=document.getElementById("filter_app_id").value;
	var env_id=document.getElementById("envList").value;

	if (env_id=="") {
		myalert("Should pick database to proceed");
		return;
	}
	
	if (par1=="") {
		myalert("Should pick an application to copy to");
		return;
	}
	
	var action="open_bulk_config_dlg";
	var div_id="configImportBody";
	
	var par1=app_id;
	var par2=env_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("configImportDiv");
}


//**************************************************
function testBulkConfig() {
//**************************************************
	var app_id=document.getElementById("bulk_config_app_id").value;
	var env_id=document.getElementById("bulk_config_env_id").value;
	var bulk_config_memo=document.getElementById("bulk_config_memo").value;
	
	var action="test_or_import_bulk_config";
	var div_id="testResults";
	
	var par1=app_id;
	var par2=env_id;	
	var par3=encrypt(bulk_config_memo);	
	var par4="NO";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	}


//**************************************************
function importBulkConfig() {
//**************************************************
	
	var bulk_configtest_done=document.getElementById("bulk_config_memo");

	if (!bulk_configtest_done) {
		myalert("Test the config first before importing.");
		return;
	}
	
	bootbox.confirm("Start importing?", function(result) {
		
		if(!result) return;

		var app_id=document.getElementById("bulk_config_app_id").value;
		var env_id=document.getElementById("bulk_config_env_id").value;
		var bulk_config_memo=document.getElementById("bulk_config_memo").value;
		
		var action="test_or_import_bulk_config";
		var div_id="testResults";
		
		var par1=app_id;
		var par2=env_id;	
		var par3=encrypt(bulk_config_memo);	
		var par4="YES";

		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);

	}); 
	
	
	}

//****************************************************
function fillCopyTableList() {
	var source_app_id=document.getElementById("source_app_id").value;
	
	var action="fill_copy_table_list";
	var div_id="tableCopyListDiv";
	var par1=source_app_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1);
}


function setAllCopyTableList() {
	var el=document.getElementById("copy_ch_0");
	if (!el) return;
	
	var setresetval=document.getElementById("set_all").checked;
	
	for (var i=0;i<1000;i++) {
		el=document.getElementById("copy_ch_"+i);
		if (!el) break;
		el.checked=setresetval;
	}
	
}

//****************************************************
function copyTableToApp() {
//****************************************************
	var source_app_id=document.getElementById("source_app_id");
	if (source_app_id.value=="") {
		myalert("No application was selected");
		return;
	}
	
	var selected_tab_ids="";
	
	
	
	var el=document.getElementById("copy_ch_0");
	var found_count=0;
	
	for (var i=0;i<1000;i++) {
		el=document.getElementById("copy_ch_"+i);
		if (!el) break;
		if (el.checked) {
			found_count++;
			if (found_count>1) selected_tab_ids=selected_tab_ids+",";
			selected_tab_ids=selected_tab_ids+el.value;
		}	}
	
	
	if (selected_tab_ids.length==0) {
		myalert("no table selected. ");
		return;
	}
	
	$("#copyTableDiv").modal("hide");
	
	var app_id=document.getElementById("filter_app_id").value;
	
	var action="copy_table_to_app:::::fill_app_table";
	var div_id="NONE:::::div_app_table";
	var par1=app_id+":::::"+app_id;
	var par2=selected_tab_ids+":::::x";
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
	
}




//************************************************
function openFilterTableDlg() {
	
	
	var el=document.getElementById("selecttable");
	
	if (!el) {
		myalert("At least a table should be added to configure copy filter.");
		return;
	}
	
	var action="copy_filter_table_dialog";
	var div_id="filterTabBody";
	var par1=curr_app_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("filterTabDiv");
}


//************************************************
function openChecklistDlg() {
	
	
	
	
	var action="make_checklist_dialog";
	var div_id="checkListBody";
	var par1=curr_app_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("checkListDiv");
}



//************************************************
function checkProblems() {
	
	var action="check_copy_app_problems";
	var div_id="problemsBody";
	var par1=curr_app_id;
	var par2=curr_env_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("problemsDiv");
}
//************************************************
function openAppDependancyDlg() {
	
	var action="depended_applicatons_dialog";
	var div_id="dependedAppsBody";
	var par1=curr_app_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("dependedAppsDiv");
}

//************************************************
function openScriptDlg(stage) {
	
	var action="db_scripts_dialog";
	var div_id="dbScriptBody";
	var par1=curr_app_id;
	var par2=stage;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("dbScriptDiv");
}

//************************************************
function addNewScript(app_id,stage) {
	bootbox.prompt("Enter script description to add ", function(result) {                
		  if (result !== null) {
			  
			  if (result.length==0) {
				  myalert("script description cannot be empty");
				  return;
			  }
			  
			  addNewScriptPickFamily(app_id,stage, result);
				
		    
		  }
		});	
}

//***********************************************
function addNewScriptPickFamily(app_id,stage, script_description) {
	
	
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Family";
	var par2="family_list";
	var par3="x";
	var par4="x";
	var par5="addNewScriptDo('"+app_id+"','"+stage+"','"+script_description+"','#')";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
	
}

//***********************************************
function addNewScriptDo(app_id, stage,script_description,family_id) {
	var action="add_new_script";
	var div_id="NONE";
	var par1=app_id;
	var par2=stage;
	var par3=script_description;
	var par4=family_id;
	

		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
}

//***********************************************
function removeScript(app_id, stage, script_id) {
	bootbox.confirm("Are you sure to remove this script?", function(result) {
		
		if(!result) return;

		var action="remove_script";
		var div_id="NONE";
		var par1=app_id;
		var par2=stage;
		var par3=script_id;
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

	}); 
}

//***********************************************
function reorderScript(app_id, stage, script_id, direction) {

	var action="reorder_script";
	var div_id="NONE";
	var par1=app_id;
	var par2=stage;
	var par3=script_id;
	var par4=direction;

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);

	
}

//************************************************
function addNewTableFilter(filter_app_id, filter_tab_id) {
	var action="add_new_table_filter";
	var div_id="NONE";
	var par1=filter_app_id;
	var par2=filter_tab_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//***************************************************
function deleteTableFilter(filter_id) {
	
	bootbox.confirm("Are you sure to delete this table filter?", function(result) {
		
		if(!result) return;

		var action="delete_table_filter";
		
		var div_id="NONE";
		var par1=filter_id;
		
		ajaxDynamicComponentCaller(action, div_id, par1);

	}); 
	
	
	
}


//***************************************************
function savePrepAppField(el, rel_app_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_rel_app_field";
	var div_id="NONE";
	var par1=""+rel_app_id;	
	var par2=field_name;
	var par3=field_value;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//***************************************************
function saveScriptField(el, script_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_script_field";
	var div_id="NONE";
	var par1=""+script_id;	
	var par2=field_name;
	var par3=field_value;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//***************************************************
function changeTableFilter(filter_id) {
	
	
	var action="change_table_filter";
	
	var div_id="NONE";
	var par1=filter_id;
	var par2=document.getElementById("filter_name_"+filter_id).value;
	var par3=document.getElementById("filter_type_"+filter_id).value;
	var par4="";
	var el_filtersql=document.getElementById("filter_sql_"+filter_id);
	if (el_filtersql) par4=el_filtersql.value;
	
	var format_1="-";
	var el=document.getElementById("format_1_"+filter_id);
	if (el) format_1=el.value;
	if (format_1.length=="") format_1="-";
	
	var format_2="-";
	var el=document.getElementById("format_2_"+filter_id);
	if (el) format_2=el.value;
	if (format_2.length=="") format_2="-";
	
	var list_id_1="0";
	var list_source_1="STATIC";
	
	var el=document.getElementById("list_id_1_"+filter_id);
	if (el) {
			list_id_1=el.value;
			list_source_1=document.getElementById("list_source_1_"+filter_id).value;
		}
	if (list_id_1.length=="") list_id_1="0";
	
	var list_id_2="0";
	var list_source_2="STATIC";
	
	var el=document.getElementById("list_id_2_"+filter_id);
	if (el) {
		list_id_2=el.value;
		list_source_2=document.getElementById("list_source_2_"+filter_id).value;
	}
	if (list_id_2.length=="") list_id_2="0";
	
	var par5=format_1+"::::"+format_2+"::::"+list_id_1+"::::"+list_id_2+"::::"+list_source_1+"::::"+list_source_2;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);

	
}




//************************************************
function changeCopyFilter() {
	var action="change_copy_filter";
	
	var div_id="CurrentCopyFilterDiv";
	var par1=curr_app_id;
	var par2=document.getElementById("target_env_id").value;
	if (par2=="") par2="0";
	
	var par3="0";
	if (document.getElementById("filter_id"))
		par3=document.getElementById("filter_id").value;
	
	if (par3=="") par3="0";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//*****************************************************

function runAppFilter(e) {
    if (e.keyCode == 13) {
    	fillAppTabList();
        return false;
    }
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
	
	try{new_val_float=parseFloat(new_val);} catch(err) { console.log("err new_val_float"); }
	
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
		
		try{out_limit_fixed=parseInt(x.split(".")[0]);} catch(err) { console.log("err out_limit_fixed"); }
		try{out_limit_decimal=parseInt(x.split(".")[1]);} catch(err) { console.log("err out_limit_decimal"); }
		
		
		el_fixed.value=""+out_limit_fixed;
		try{el_decimal.value=""+out_limit_decimal;} catch(err) { console.log("err el_decimal"); }
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

		setPicklistHiddenField(id);
		
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
	
	
	
	setPicklistButtons("SOURCE",id);
	setPicklistButtons("TARGET",id);
	
	try{
		validateEntry(table_id, id, "TEXT", "", "YES", "YES","");
		} 
	catch(err) 
		{ console.log("err@validateEntry@pickListAction"); }
	
	
}


//********************************
function validateEntry(request_id, field_object_id, entry_type, regex, is_validated, is_mandatory, fire_event) {
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
function buildDateFilter(id) {
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


//***************************************************
function onLoadConfiguration() {
	
	var action="load_configuration_menu";
	var div_id="configLeftDiv";
	var par1="x";
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function filterLovOnEnter(e) {

	if (event.which == 13 || event.keyCode == 13) {
		 filterLov();
	        return false;
	    }
	 return true;
}

//**************************************************
function filterLov() {
	var lov_type=document.getElementById("lov_type").value;
	var curr_value=document.getElementById("lov_selected_value").value;
	var entered_filter=document.getElementById("filter_lov_box").value;
	
	
	
	var action="set_lov_filter";
	var div_id="lovListItemsDiv";
	var par1=lov_type;
	var par2=curr_value;
	var par3=entered_filter;
	
	if (par3=="") par3="${null}"
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
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
function setLovDefaultChecked() {
	var elval=document.getElementById("lov_selected_value");
	
	
	
	for (var i=0;i<10000;i++) {
		el=document.getElementById("lov_radio_"+i);
		if (!el) return;
		if (!el.checked) continue;

		elval.value=el.value;
	}
}

//**************************************************
function selectLOV() {
	setLovDefaultChecked();
	
	var el=document.getElementById("lov_selected_value");
	var selectedVal=el.value;
	if (selectedVal=="" || selectedVal=="x") {
		myalert("Pick a value");
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
function addNewSector() {
	
	bootbox.prompt("Enter sector name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("sector cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_sector";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
	
}

//**************************************************
function addNewMadGroup() {

	bootbox.prompt("Enter Group Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Group Name cannot be empty");
				  return;
			  }
			  
			    var action="add_mad_group";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}



//**************************************************
function makeMadGroupList() {
	
	var action="make_mad_group_list";
	var div_id="colGroupsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}


//**************************************************
function makeEnvironmentList() {
	
	var action="make_environment_list";
	var div_id="colEnvironmentsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makePolicyGroupList() {
	
	var action="make_policy_group_list";
	var div_id="colPolicyGroupsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeCalendarList() {
	
	var action="make_calendar_list";
	var div_id="colCalendarBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeSessionValidationList() {
	
	var action="make_session_validation_list";
	var div_id="colSessionValidationBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMonitoringList() {
	
	var action="make_monitoring_list";
	var div_id="colMonitoringBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeCalendarExceptionList(calendar_id) {
	
	var action="make_calendar_exception_list";
	var div_id="colCalendarExceptionFor_"+calendar_id;
	var par1=calendar_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}



//**************************************************
function updateCalendarExceptionDate(calendar_exception_id,  startend) {
	
	var update_field_name="exception_start_time";
	
	if (startend==2) update_field_name="exception_end_time";
	
	var update_field_value=document.getElementById(update_field_name+"_"+calendar_exception_id).value;
	
	var action="update_calendar_exception_date";
	var div_id="NONE";
	var par1=""+calendar_exception_id;	
	var par2=update_field_name;	
	var par3=update_field_value;	

	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
	
}


//**************************************************
function makeDatabaseList() {
	
	var action="make_database_list";
	var div_id="colDatabasesBody";
	var par1="x";	
	
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
function makeMadUserList() {
	
	var action="make_mad_user_list";
	var div_id="colUsersBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeSectorList() {
	
	var action="make_sector_list";
	var div_id="colSectorBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMadUserEditor(user_id) {
	
	var action="make_mad_user_editor";
	var div_id="colUserContent_"+user_id+"Body";
	var par1=""+user_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}


//**************************************************
function makeSectorEditor(sector_id) {
	
	var action="make_sector_editor";
	var div_id="colSectorContent_"+sector_id+"Body";
	var par1=""+sector_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeDatabaseEditor(database_id) {
	
	var action="make_database_editor";
	var div_id="colDatabaseContent_"+database_id+"Body";
	var par1=""+database_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makePolicyGroupEditor(policy_group_id) {
	
	var action="make_policy_group_editor";
	var div_id="colPolicyGroupContent_"+policy_group_id+"Body";
	var par1=""+policy_group_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeCalendarEditor(calendar_id) {
	
	var action="make_calendar_editor";
	var div_id="colCalendarContent_"+calendar_id;
	var par1=""+calendar_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeSessionValidationEditor (session_validation_id) {
	
	var action="make_session_validation_editor";
	var div_id="colSessionValidationContent_"+session_validation_id;
	var par1=""+session_validation_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMonitoringEditor(monitoring_id) {
	
	var action="make_monitoring_editor";
	var div_id="colMonitoringContent_"+monitoring_id;
	var par1=""+monitoring_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
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
function saveSectorField(el, sector_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_sector_field";
	var div_id="NONE";
	var par1=""+sector_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
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
function deleteSector(sector_id) {
	
	bootbox.confirm("Are you sure to remove this user?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_sector";
		var div_id="NONE";
		var par1=""+sector_id;	
		
		
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
function addRemoveUserRole(user_id, action_and_id) {
	var action="add_remove_user_role";
	var div_id="NONE";
	var par1=""+user_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}


//**************************************************
function addRemoveSectorRule(sector_id, action_and_id) {
	var action="add_remove_sector_rule";
	var div_id="NONE";
	var par1=""+sector_id;	
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


//-----------------------------------------------------------------
function assignWorkPackage(work_package_id) {
	var action="make_work_package_assignment_list";
	var div_id="workPackageAssignBody";
	var par1=""+work_package_id;
	
	$("#workPackageAssignDiv").modal("show");
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//-----------------------------------------------------------------
function assignWorkPackageDO(work_package_id, master_id) {
	var action="assign_work_package";
	var div_id="NONE";
	var par1=""+work_package_id;
	var par2=""+master_id;
	
	
	$("#workPackageAssignDiv").modal("hide");
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}


//-----------------------------------------------------------------
function ondiscoveryload() {
	var action="load_discovery_left";
	var div_id="divDiscoveryLeft";
	var par1="x";

	ajaxDynamicComponentCaller(action, div_id, par1);
	
}


//------------------------------------------------------------------
function startNewMaskingDiscovery() {
	var action="start_new_discovery_window";
	var div_id="startDiscoveryBody";
	var par1="MASK";

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#startDiscoveryDiv").modal("show");
}

//------------------------------------------------------------------
function fillDiscCatalogSchemaList() {
	
	var disc_env_id=document.getElementById("disc_env_id").value;
	
	
	
	var action="fill_discovery_catalog_list:::::fill_discovery_schema_list";
	var div_id="discCatalogListDiv:::::discSchemaListDiv";
	var par1=disc_env_id+":::::"+disc_env_id;
	var par2="x"+":::::"+"All";

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}

//------------------------------------------------------------------
function fillDiscSchemaList() {
	
	var disc_env_id=document.getElementById("disc_env_id").value;
	var disc_catalog_filter=document.getElementById("disc_catalog_filter").value
	if (disc_catalog_filter=="") disc_catalog_filter="All";
	
	
	var action="fill_discovery_schema_list";
	var div_id="discSchemaListDiv";
	var par1=disc_env_id;
	var par2=disc_catalog_filter;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}


//------------------------------------------------------------------
function startDiscovery() {

	
	var discovery_type=document.getElementById("disc_discovery_type").value;
	var discovery_title=document.getElementById("disc_discovery_title").value;
	var app_id=document.getElementById("disc_application_id").value;
	var env_id=document.getElementById("disc_env_id").value;
	var sector_id="0";
	try{sector_id=document.getElementById("disc_discovery_sector").value;} catch(err) {}
	var sample_count=document.getElementById("disc_sample_count").value;
	
	
	if (discovery_type=="") {
		myalert("You should type a discovery type to proceed");
		return;
	}
	
	if (discovery_title=="") {
		myalert("You should type a discovery title to proceed");
		return;
	}
	
	if (app_id=="") {
		myalert("You should select an application to proceed");
		return;
	}
	
	if (env_id=="") {
		myalert("You should select a database to proceed");
		return;
	}
	
	var el=document.getElementById("disc_schema_list");
	
	
	if(!el) {
		myalert("You should select a valid database to proceed");
		return;
	}
	
	var schema_list=el.value;
	if(schema_list=='') schema_list='All';
	
	if(sector_id=='') sector_id='0';

	bootbox.confirm("Are you sure to start a discovery?", function(result) {
		
		if(!result) return;

		
	    var action="create_new_masking_discovery";
		var div_id="NONE";
		var par1=discovery_type;
		var par2=app_id;
		var par3=env_id;
		var par4=schema_list;
		var par5=discovery_title;
		var par6=sample_count+":"+sector_id;
		
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5, par6);
		
		$("#startDiscoveryDiv").modal("hide");
	
	});	
}
//------------------------------------------------------------------
function openDiscoveryList() {
	var action="open_discovery_list";
	var div_id="discoveryListBody";
	var par1="x";

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#discoveryListDiv").modal("show");
}

//-------------------------------------------------------------------
function setActiveDiscoveryId(discovery_id) {
	var action="set_active_discovery_id";
	var div_id="NONE";
	var par1=""+discovery_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#discoveryListDiv").modal("hide");
}

//-------------------------------------------------------------------
function loadDiscoveryReport() {
	
	var include_discarded="NO";
	var group_by="CATEGORY";
	var filter_catalog="";
	var filter_owner="";
	var filter_category="";
	var match_rate="0";
	var filter_table="";
	var filter_column="";
	var comparing_discovery_id="";
	
	if (document.getElementById("includeDiscarded").checked) include_discarded="YES";
	group_by=document.getElementById("groupBy").value;
	filter_catalog=document.getElementById("catalogList").value;
	filter_owner=document.getElementById("schemaList").value;
	filter_category=document.getElementById("targetList").value;
	match_rate=document.getElementById("match_rate").value;
	filter_table=document.getElementById("table_name").value;
	filter_column=document.getElementById("field_name").value;
	comparing_discovery_id=document.getElementById("compareTo").value;
	
	if (filter_table=="") filter_table="${null}";
	if (filter_column=="") filter_column="${null}";
	if (comparing_discovery_id=="") comparing_discovery_id="${null}";
	
	var action="load_discovery_report";
	var div_id="divDiscoveryBody";
	var par1=include_discarded;
	var par2=group_by;
	var par3=filter_catalog;
	var par4=filter_owner;
	var par5=filter_category;
	var par6=match_rate+":"+filter_table+":"+filter_column+":"+comparing_discovery_id;
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5, par6);
}

//**************************************************
function pickMaskingDiscoveryReportType(discovery_id) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Report Format";
	var par2="discovery_report_type";
	var par3="x";
	var par4="x";
	var par5="generateMaskingDiscoveryReport('"+discovery_id+"','#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//*******************************************
function generateMaskingDiscoveryReport(discovery_id, report_type) {
	var action="write_masking_report";
	var div_id="NONE";
	var par1=discovery_id;
	var par2=report_type;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//*******************************************
function downloadMaskingDiscoveryReport(rep_file) {
	window.open("upload/"+rep_file);
}


//*******************************************
function exportMaskingConfiguration() {
	
	var export_app_id=document.getElementById("filter_app_id").value;
	
	if (export_app_id=="") {
		myalert("Pick an application to proceed.");
		return;
	}
	
	var action="export_masking_configuration";
	var div_id="NONE";
	var par1=export_app_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//*******************************************
function downloadMaskingExportedFile(rep_file) {
	window.open("upload/"+rep_file);
}


//-----------------------------------------------------------------
function oncopyload() {
	
	listMyCopyTasks();
	
}


//------------------------------------------------------------------
function startNewCopy() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Copy Application";
	var par2="copy_application";
	var par3="x";
	var par4="x";
	var par5="loadCopyAppParams('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}
//-------------------------------------------------------------------
function loadCopyAppParams(app_id ) {
	var action="load_copy_app_params";
	var div_id="divCopyBody";
	var par1=app_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
}

//------------------------------------------------------------------
function listMyCopyTasks() {
	
	var filter_options="";
	
	var elx=document.getElementById("search_copy_id");
	
	if (elx) {
		var search_copy_id=document.getElementById("search_copy_id").value;
		var search_copy_work_plan_name=document.getElementById("search_copy_work_plan_name").value;
		var search_created_by=document.getElementById("search_created_by").value;
		var search_copy_status=document.getElementById("search_copy_status").value;
		var search_copy_application=document.getElementById("search_copy_application").value;
		var search_copy_source_db=document.getElementById("search_copy_source_db").value;
		var search_copy_target_db=document.getElementById("search_copy_target_db").value;
		
		
		//if (search_copy_id!="") 
			filter_options=filter_options+"|::|search_copy_id="+search_copy_id;
		//if (search_copy_work_plan_name!="") 
			filter_options=filter_options+"|::|search_copy_work_plan_name="+search_copy_work_plan_name;
		//if (search_created_by!="") 
			filter_options=filter_options+"|::|search_created_by="+search_created_by;
		//if (search_copy_status!="") 
			filter_options=filter_options+"|::|search_copy_status="+search_copy_status;
		//if (search_copy_application!="") 
			filter_options=filter_options+"|::|search_copy_application="+search_copy_application;
		//if (search_copy_source_db!="") 
			filter_options=filter_options+"|::|search_copy_source_db="+search_copy_source_db;
		//if (search_copy_target_db!="") 
			filter_options=filter_options+"|::|search_copy_target_db="+search_copy_target_db;
		
	}
	
	
	var action="list_my_copy_tasks";
	var div_id="divCopyBody";
	var par1=filter_options;

	ajaxDynamicComponentCaller(action, div_id, par1);
}

//-------------------------------------------------------------------
function fillCopyFilterVals(elfilter, app_id, target_div,filter_value) {
	
	var filter_id="";
	var source_env_id="0";
	var target_env_id="0";
	
	
	
	filter_id=elfilter.value;
	if (filter_id=="") filter_id="0";
	
	var srcenvel=document.getElementById("source_env_id");
	if (srcenvel) source_env_id=srcenvel.value;
	
	if (source_env_id=="") {
		myalert("Select source environment to proceed");
		document.getElementById("filter_id").selectedIndex = 0;
		return;
	}
	
	var tarenvel=document.getElementById("target_env_id");
	if (tarenvel) target_env_id=tarenvel.value;
	if (source_env_id=="") {
		source_env_id="0";
	}
	
	var action="fill_copy_filter_vals";
	var div_id=target_div;	
	var par1=app_id;
	var par2=filter_id;
	var par3=source_env_id;
	var par4=target_env_id;
	var par5=filter_value;

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
}


//---------------------------------------------------------------
function savePrereqAppFilterValues(apps_rel_id) {
	
	var eldiv=document.getElementById("copyFilterValsDivFor_"+apps_rel_id);
	
	if (!eldiv) return;

	var children = eldiv.getElementsByTagName('*');
	
	var val_1="";
	var val_2="";
	
	for (var i=0;i<children.length;i++) {
		var elx=children[i];
		if (elx.id=="val_1") val_1=elx.value;
		if (elx.id=="val_2") val_2=elx.value;
	}
	

	var filter_value=val_1+"++"+val_2;
	
	
	var action="save_prerequisite_application_filter_value";
	var div_id="NONE";	
	var par1=apps_rel_id;
	var par2=filter_value;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);

	
}

//---------------------------------------------------------------
function onManualConditionChange(app_id, el) {
	var condition_tab_id=el.value;
	if (condition_tab_id=="") 
		fillTargetInfo(app_id);
	else 
		fillTargetInfo(app_id,condition_tab_id);
}
//---------------------------------------------------------------
function fillTargetInfo(app_id) {
	fillTargetInfo(app_id,"ALL")
}
//---------------------------------------------------------------
function fillTargetInfo(app_id,condition_tab_id) {
	
	var source_id=document.getElementById("source_env_id").value;
	var target_id=document.getElementById("target_env_id").value;
	
	if (source_id=="") source_id="0";
	if (target_id=="") target_id="0";
	
	
	var action="fill_target_info";
	var div_id="targetInfoDiv";	
	var par1=app_id;
	var par2=source_id;
	var par3=target_id;
	var par4=condition_tab_id;
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
}

//--------------------------------------------------------------
function checkFormat(obj,forder) {
	var regex=document.getElementById("filter_format_"+forder).value;
	var str_to_test=document.getElementById("val_"+forder).value;
	var is_ok=false;
	
	if (regex=="") is_ok=true;
	else {
		is_ok=testRegex(str_to_test, regex);
	}

	var validation_result="YES";
	var border_color="green";
	
	if (!is_ok) {
		validation_result="NO";
		border_color="red";
	}
	
	document.getElementById("validation_result_"+forder).value=validation_result;
	
	
	document.getElementById("val_"+forder).style.borderColor=border_color;
}




//----------------------------------------------------------------------------
function startCopy(app_id) {
	var source_id=document.getElementById("source_env_id").value;
	var target_id=document.getElementById("target_env_id").value;
	var copy_count=document.getElementById("copy_count").value;
	var repeat_count=document.getElementById("repeat_count").value;
	var filter_id=document.getElementById("filter_id").value;
	var copy_schedule_date=document.getElementById("copy_schedule_date").value;
	var on_error_action=document.getElementById("on_error_action").value;
	
	if (document.getElementById("copy_all").checked) copy_count="2147483647";
	
	if (source_id=="") {
		myalert("Pick source to proceed");
		return;
	}
	if (target_id=="") {
		myalert("Pick target to proceed");
		return;
	}

	if (filter_id=="") {
		myalert("Pick copy filter to proceed");
		return;
	}
	
	var elval1=document.getElementById("val_1");
	var elval2=document.getElementById("val_2");
	
	var val_1="";
	var val_2="";
	
	if (elval1) {
		var validation_result_1=document.getElementById("validation_result_1").value;
		val_1=elval1.value;
		if (val_1=="") {
			myalert("Enter filter value 1 to proceed");
			return;
		}
		
		if (validation_result_1=="NO") {
			myalert("Entered filter value is invalid. ");
			return;
		}
	}
	
	if (elval2) {
		var validation_result_2=document.getElementById("validation_result_2").value;
		val_2=elval2.value;
		if (val_2=="") {
			myalert("Enter filter value 2 to proceed");
			return;
		}
		
		if (validation_result_2=="NO") {
			myalert("Entered filter value is invalid. ");
			return;
		}
	}
	
	//----------------------------------------
	
	
	var target_owner_info="";
	
	var elcurrentschema=document.getElementById("source_schema_0");
	var elcurrenttable=document.getElementById("source_table_0");
	var eltargetschema=document.getElementById("target_schema_0");
	var eltargettable=document.getElementById("target_table_0");
	
	var elorigtable=document.getElementById("orig_table_name_0");
	var elorigtableid=document.getElementById("orig_table_id_0");	
	
	if (elorigtable) {
		
		var changed=0;
		
		for (var i=0;i<10000;i++) {
			elcurrentschema=document.getElementById("source_schema_"+i);
			elcurrenttable=document.getElementById("source_table_"+i);
			
			
			eltargetschema=document.getElementById("target_schema_"+i);
			eltargettable=document.getElementById("target_table_"+i);
			
			if (!eltargetschema) {
				eltargetschema=elcurrentschema;
				eltargettable=elcurrenttable;
			}
			
			elorigtable=document.getElementById("orig_table_name_"+i);
			elorigtableid=document.getElementById("orig_table_id_"+i);
			
			if (!elorigtable) break;
			
			if(elcurrentschema.value=="" || eltargetschema.value=="") {
				myalert("All schema must be set.");
				return;
			}
			
			if(elcurrenttable.value=="" || eltargettable.value=="") {
				myalert("All table names must be filled.");
				return;
			}
			
			
			if (changed>0) target_owner_info=target_owner_info+"\n";
			
			changed++;
	
			target_owner_info=target_owner_info+
			elorigtableid.value+
			"*"+
			elorigtable.value+
			"["+
			elcurrentschema.value+"."+elcurrenttable.value+
			":"+
			eltargetschema.value+"."+eltargettable.value+
			"]";
			
			
		}
		
	} //if (elorigtable)
	
	
	if (target_owner_info=="") target_owner_info="-";
	
	
	
	var copy_filter=document.getElementById("filter_id").value;
	var copy_filter_bind="-";
	var copy_rec_count=""+copy_count;
	var copy_repeat_count=""+repeat_count;
	var email_address="-";
	
	var filter_type=document.getElementById("filter_type").value;
	
	val_1=encrypt(val_1);
	val_2=encrypt(val_2);

	copy_filter_bind=val_1+"++"+val_2;
	
	var run_options="x";
	
	var execution_type="PARALLEL";
	var start_date=copy_schedule_date;
	var master_limit="9999";
	var worker_limit="10";
	var REC_SIZE_PER_TASK="1000";
	var TASK_SIZE_PER_WORKER="10";
	var UPDATE_WPACK_COUNTS_INTERVAL="120000";
	
	setCopyWorkPlanName();
	
	var work_plan_name=document.getElementById("work_plan_name").value;
	
	if (work_plan_name=="") work_plan_name="x";
	
	
	var repeat_period="NONE";
	try{repeat_period=document.getElementById("repeat_period").value;} catch(err) {}
	
	var repeat_by="0";
	try{repeat_by=document.getElementById("repeat_by").value;} catch(err) {}
	
	//--------------------------------------------------------------------------------
	var depended_application="";
	var elwpdep=document.getElementById("depended_work_plan_list");
	if (elwpdep) {
		var wps=elwpdep.value.split("|::|");
		for (var i=0;i<wps.length;i++) {
			if (i>0)  depended_application=depended_application+",";
			depended_application=depended_application+wps[i];
		}
	}
	
	if (depended_application=="") depended_application="x";
	
	
	var wp_params=	""+
	work_plan_name +	"::::" +
	"ACTUAL:ACCURACY"+	"::::" +
	start_date +	"::::" +
	master_limit +	"::::" +
	worker_limit +	"::::" +
	REC_SIZE_PER_TASK +	"::::" +
	TASK_SIZE_PER_WORKER +	"::::" +
	UPDATE_WPACK_COUNTS_INTERVAL+	"::::" +
	target_owner_info + "::::" +
	copy_filter + "::::" +
	copy_filter_bind + "::::" +
	copy_rec_count + "::::" +
	copy_repeat_count + "::::" +
	email_address + "::::" +
	run_options + "::::" +
	depended_application+"::::"+
	execution_type+"::::"+
	on_error_action+"::::"+
	repeat_period+"::::"+
	repeat_by
	"";
	
	
	
	
	
	
	var action="show_check_and_compare_table_results";
	var div_id="tableCompareBody";
	var par1="COPY2";
	var par2=app_id;
	var par3=source_id;
	var par4=wp_params;
	var par5=target_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	$("#tableCompareDiv").modal();
	

	
	
	
}



//*******************************************************************
function startCopyDO() {
	
	var elerr=document.getElementById("comparing_error_count");
	
	if (!elerr) {
		myalert("Compare is not finished yet.");
		return;
	}
	
	var error_count=document.getElementById("comparing_error_count").value;
	
	if (error_count!="0") {
		myalert("[<b>"+error_count+"</b>] show stopper errors to fix. Fix erors to proceed.");
		return;
	}


	var app_id=document.getElementById("comparing_app_id").value;
	var source_env_id=document.getElementById("comparing_source_env_id").value;
	var target_env_id=document.getElementById("comparing_target_env_id").value;
	var wp_params=document.getElementById("comparing_wp_params").value;
	var error_actions=document.getElementById("error_actions").value;
	
	if (error_actions!="")
		wp_params=wp_params+"::::"+error_actions;
	else wp_params=wp_params+"::::-";

	var action="create_work_plan";
	var div_id="NONE";
	var par1="COPY2";
	var par2=app_id;
	var par3=source_env_id;
	var par4=wp_params;
	var par5=target_env_id;
	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	$("#tableCompareDiv").modal("hide");


	
}

//-------------------------------------------
function setCopyWorkPlanName() {
	var wpel=document.getElementById("work_plan_name");
	
	var curr_name=wpel.value;
	
	var app_name=document.getElementById("app_name").value;
	var source_db_name="undefined";
	var target_db_name="undefined";
	var filter_name="undefined";
	var filter_params="undefined";
	
	var elsource=document.getElementById("source_env_id");
	var eltarget=document.getElementById("target_env_id");
	
	if (elsource.value!="")
		source_db_name=elsource.options[elsource.selectedIndex].text;
	
	if (eltarget.value!="")
		target_db_name=eltarget.options[eltarget.selectedIndex].text;
	
	curr_name="Copy "+app_name;
		
	if (source_db_name!="undefined") 
		curr_name=curr_name+" From [" + source_db_name+"]";
	
	if (target_db_name!="undefined") 
		curr_name=curr_name+" To [" + target_db_name+"]";
	
	var elfiter=document.getElementById("filter_id");
	if (elfiter.value!="")
		filter_name=elfiter.options[elfiter.selectedIndex].text;
	
	if (filter_name!="undefined")
		curr_name=curr_name+" via filter  ["+filter_name  + "]";
	
	var elval1=document.getElementById("val_1");
	var elval2=document.getElementById("val_2");
	
	
	if (elval2 && elval1) 
		filter_params=elval1.value+","+elval2.value;
	else if (elval1)
		filter_params=elval1.value;
	
	if (filter_params.length>50) filter_params=filter_params.substring(0,50)+"...";
	
	if (filter_params!="undefined") 
		curr_name=curr_name+" with Parameters ["+filter_params+"]";
	
	//curr_name=curr_name+" @" + new Date();
	
	wpel.value=curr_name
	
	
	
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
function savePolicyGroupField(el, policy_group_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_policy_group_field";
	var div_id="NONE";
	var par1=""+policy_group_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveCalendarField(el, calendar_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_calendar_field";
	var div_id="NONE";
	var par1=""+calendar_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveSessionValidationField(el, session_validation_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_session_validation_field";
	var div_id="NONE";
	var par1=""+session_validation_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMonitoringField(el, monitoring_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_monitoring_field";
	var div_id="NONE";
	var par1=""+monitoring_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//**************************************************
function saveMonitoringRuleField(el, monitoring_id, monitoring_rule_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_monitoring_rule_field";
	var div_id="NONE";
	var par1=""+monitoring_id;	
	var par2=""+monitoring_rule_id;	
	var par3=field_name;
	var par4=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}
//**************************************************
function saveCalendarExceptionField(el, calendar_exception_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_calendar_exception_field";
	var div_id="NONE";
	var par1=""+calendar_exception_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveLogExceptionField(el, exception_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_log_exception_field";
	var div_id="NONE";
	var par1=""+exception_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function saveStatementExceptionField(el, exception_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_statement_exception_field";
	var div_id="NONE";
	var par1=""+exception_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function addRemoveGroupMember(group_id, action_and_id) {
	var action="add_remove_group_member";
	var div_id="NONE";
	var par1=""+group_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}


//**************************************************
function addRemoveGroupEnvironment(group_id, action_and_id,env_type) {
	var action="add_remove_group_environment";
	var div_id="NONE";
	var par1=""+group_id;	
	var par2=""+action_and_id;
	var par3=""+env_type;
		
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
function addRemoveGroupCopyApplication(group_id, action_and_id) {
	var action="add_remove_group_application";
	var div_id="NONE";
	var par1=""+group_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**************************************************
function setCopyAll(elch) {
	var elmax_fixed=document.getElementById("copy_count_fixed");
	var elmax_value=document.getElementById("copy_count");
	//2147483647
	
	var is_max=elch.checked;
	
	if (is_max) {
		elmax_fixed.disabled=true;
	} else {
		elmax_fixed.disabled=false;
	}
}

//******************************************************
function changeCopyRefTable(el, field_id) {
	
	
	var curr_copy_ref_tab_id=el.value;
	if (curr_copy_ref_tab_id=="") curr_copy_ref_tab_id="0";
	
	var action="change_copy_ref_table";
	var div_id="NONE";
	var par1=""+field_id;	
	var par2=""+curr_copy_ref_tab_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}



//******************************************************
function makeCopyFieldNameCombo(field_id, copy_ref_tab_id) {
	
	
	var action="make_copy_field_name_combo";
	var div_id="divCopyRefFieldOf"+field_id;
	var par1=""+field_id;	
	var par2=""+copy_ref_tab_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//******************************************************
function changeCopyRefField(el, field_id) {
	
	
	var curr_copy_ref_field_name=el.value;
	
	
	var action="change_copy_ref_field_name";
	var div_id="NONE";
	var par1=""+field_id;	
	var par2=""+curr_copy_ref_field_name;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}

//*******************************************************
function addTableNeed(tabid) {

	var action="add_table_need";
	var div_id="tableNeedBody";
	var par1=""+tabid;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#tableNeedDiv").modal();
	
}

//*******************************************************
function editTableNeed(tabid,need_id) {

	var action="edit_table_need";
	var div_id="tableNeedBody";
	var par1=""+tabid;	
	var par2=""+need_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#tableNeedDiv").modal();
	
}

//*******************************************************
function removeTableNeed(tabid,need_id) {

bootbox.confirm("Are you sure to remove this need?", function(result) {
	
		if(!result) return;
		

		var action="remove_table_need";
		var div_id="NONE";
		var par1=""+tabid;
		var par2=""+need_id;
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		

	}); 

	
	
}

//*******************************************************
function loadTabNeedList(tabid) {

	var action="load_table_need_list";
	var div_id="tabNeedDivFor"+tabid;
	var par1=""+tabid;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}

//********************************************************
function fillNeedFilterList() {
	var need_app_id=document.getElementById("need_app_id").value;
	
	var action="load_need_filter_list";
	var div_id="needFilterListDiv";
	var par1=""+need_app_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}


//*******************************************************
function saveTableNeed() {

	var need_id=document.getElementById("current_need_id").value;
	var need_tab_id=document.getElementById("current_need_tab_id").value;
	
	var need_app_id=document.getElementById("need_app_id").value;
	var need_filter_id=document.getElementById("need_filter_id").value;
	var need_rel_on_fields=document.getElementById("need_rel_on_fields").value;
	
	if (need_app_id=="") {
		myalert("Please pick an application to proceed.");
		return;
	}
	
	if (need_filter_id=="") {
		myalert("Please pick a filter to proceed.");
		return;
	}
	
	if (need_rel_on_fields=="") {
		myalert("Please pick a field to proceed.");
		return;
	}
	
	
	
	var action="save_need";
	var div_id="NONE";
	var par1=""+need_id;	
	var par2=""+need_tab_id;
	var par3=""+need_app_id;
	var par4=""+need_filter_id;
	var par5=""+need_rel_on_fields;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	$("#tableNeedDiv").modal("hide");
	
	
}


//----------------------------------------------------------------------------------
function checkAndChangeAllTargets(el,changing_target_id) {
	
	var old_value=document.getElementById("original_target_schema_"+changing_target_id).value;
	
	var new_value=el.value;
	
	document.getElementById("original_target_schema_"+changing_target_id).value=new_value;
	
	
	var to_be_changed_count=0;
	
	for (var i=0;i<1000;i++) {
		var elx=document.getElementById("original_target_schema_"+i);
		if (!elx) continue;
		
		var elxval=elx.value;
		
		
		if (elxval==old_value) to_be_changed_count++;
	}
	

	
	if (to_be_changed_count>0)
		bootbox.confirm("Are you sure to change other target schema's named ["+old_value+"] to ["+new_value+"]?", function(result) {
			
			if(!result) return;

			for (var i=0;i<1000;i++) {
				var elx=document.getElementById("original_target_schema_"+i);
				if (!elx) continue;
				
				var elxval=elx.value;
				
				
				if (elxval==old_value) {
					elx.value=new_value;
					document.getElementById("target_schema_"+i).value=new_value;
				}
				
			}
		}); 

	
	
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

//****************************************************************
function deletePolicyGroup(policy_group_id) {
	bootbox.confirm("Are you sure to remove?", function(result) {
		
		if(!result) return;
		
		var action="remove_policy_group";
		var div_id="NONE";
		var par1=""+policy_group_id;	
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	}); 
}

//****************************************************************
function deleteCalendar(calendar_id) {
	bootbox.confirm("Are you sure to remove?", function(result) {
		
		if(!result) return;
		
		var action="remove_calendar";
		var div_id="NONE";
		var par1=""+calendar_id;	
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	}); 
}
//****************************************************************
function deleteSessionValidation(session_validation_id) {
	bootbox.confirm("Are you sure to remove?", function(result) {
		
		if(!result) return;
		
		var action="remove_session_validation";
		var div_id="NONE";
		var par1=""+session_validation_id;	
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	}); 
}
//****************************************************************
function deleteMonitoring(monioring_id) {
	bootbox.confirm("Are you sure to remove?", function(result) {
		
		if(!result) return;
		
		var action="remove_monitoring";
		var div_id="NONE";
		var par1=""+monioring_id;	
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	}); 
}
//****************************************************************
function deleteCalendarException(calendar_id, calendar_exception_id) {
	bootbox.confirm("Are you sure to remove?", function(result) {
		
		if(!result) return;
		
		var action="remove_calendar_exception";
		var div_id="NONE";
		var par1=""+calendar_id;	
		var par2=""+calendar_exception_id;	
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
	}); 
}




//****************************************************************
function removeTarget(target_id) {
	bootbox.confirm("Are you sure to remove?", function(result) {
		
		if(!result) return;
		
		var action="remove_target";
		var div_id="NONE";
		var par1=""+target_id;	
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	}); 
}

//****************************************************************
function removeFamily(family_id) {
	bootbox.confirm("Are you sure to remove?", function(result) {
		
		if(!result) return;
		
		var action="remove_family";
		var div_id="NONE";
		var par1=""+family_id;	
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	}); 
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

//****************************************************************
function addNewPolicyGroup() {
	bootbox.prompt("Enter Policy Group Name to add ", function(result) {                
		  if (result== null) return;
			  
			  if (result.length==0) {
				  myalert("Name cannot be empty");
				  return;
			  }
		  
			var action="add_policy_group";
			var div_id="NONE";
			var par1=""+result;	
				
			ajaxDynamicComponentCaller(action, div_id, par1);
				
		});	
}

//****************************************************************
function addNewSessionValidation() {
	bootbox.prompt("Enter Session Validation Name to add ", function(result) {                
		  if (result== null) return;
			  
			  if (result.length==0) {
				  myalert("Name cannot be empty");
				  return;
			  }
		  
			var action="add_new_session_validation";
			var div_id="NONE";
			var par1=""+result;	
				
			ajaxDynamicComponentCaller(action, div_id, par1);
				
		});	
}

//****************************************************************
function addNewMonitoring() {
	bootbox.prompt("Enter Monitoring Name to add ", function(result) {                
		  if (result== null) return;
			  
			  if (result.length==0) {
				  myalert("Name cannot be empty");
				  return;
			  }
		  
			var action="add_new_monitoring";
			var div_id="NONE";
			var par1=""+result;	
				
			ajaxDynamicComponentCaller(action, div_id, par1);
				
		});	
}


//****************************************************************
function addNewCalendar() {
	bootbox.prompt("Enter Calendar Name to add ", function(result) {                
		  if (result== null) return;
			  
			  if (result.length==0) {
				  myalert("Name cannot be empty");
				  return;
			  }
		  
			var action="add_new_calendar";
			var div_id="NONE";
			var par1=""+result;	
				
			ajaxDynamicComponentCaller(action, div_id, par1);
				
		});	
}

//****************************************************************
function addNewCalendarException(calendar_id) {
	var action="add_new_calendar_exception";
	var div_id="NONE";
	var par1=calendar_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
}
//****************************************************************
function addTarget() {
	bootbox.prompt("Enter Environment Name to add ", function(result) {                
		  if (result== null) return;
			  
			  if (result.length==0) {
				  myalert("Name cannot be empty");
				  return;
			  }
		  
			var action="add_target";
			var div_id="NONE";
			var par1=""+result;	
				
			ajaxDynamicComponentCaller(action, div_id, par1);
				
		});	
}

//****************************************************************
function addFamily() {
	bootbox.prompt("Enter Family Name to add ", function(result) {                
		  if (result== null) return;
			  
			  if (result.length==0) {
				  myalert("Name cannot be empty");
				  return;
			  }
		  
			var action="add_family";
			var div_id="NONE";
			var par1=""+result;	
				
			ajaxDynamicComponentCaller(action, div_id, par1);
				
		});	
}

//*******************************************************************
function changeTargetName(el,target_id) {
	var target_name=el.value;
	 
	if (target_name.length==0) {
		  myalert("Name cannot be empty");
		  makeEnvironmentList();
		  return;
	  }
	
	var action="rename_target";
	var div_id="NONE";
	var par1=target_id;	
	var par2=target_name;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);

	
}

//*******************************************************************
function changeFamilyName(el,family_id) {
	var family_name=el.value;
	 
	if (family_name.length==0) {
		  myalert("Name cannot be empty");
		  makeEnvironmentList();
		  return;
	  }
	
	var action="rename_family";
	var div_id="NONE";
	var par1=family_id;	
	var par2=family_name;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);

	
}



//*******************************************************************
function setTargetFamilyEnv(target_id, family_id) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Database";
	var par2="database_list";
	var par3="x";
	var par4="x";
	var par5="setTargetFamilyEnvDO('"+target_id+"','"+family_id+"','#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//*******************************************************************
function setTargetFamilyEnvDO(target_id, family_id, env_id) {
	var action="set_target_family_db";
	var div_id="NONE";
	var par1=target_id;	
	var par2=family_id;
	var par3=env_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);



}

//*******************************************************************
function removeTargetFamilyDb(target_id, family_id) {

	bootbox.confirm("Are you sure to delete this database from environment?", function(result) {
		
		if(!result) return;

		var action="remove_target_family_db";
		var div_id="NONE";
		var par1=target_id;	
		var par2=family_id;
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2);

	}); 


}

//**************************************************************
function showFailedWorkPackageList(work_plan_id) {
	
	
	var action="show_failed_work_package_list";
	var div_id="failedWPBody";
	var par1=work_plan_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#failedWPDiv").modal();
	
}

//**************************************************************
function showCopySummary(work_plan_id) {
	
	
	var action="show_copy_summary";
	var div_id="failedWPBody";
	var par1=work_plan_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#failedWPDiv").modal();
	
}




//***************************************************************

function printWpcError() {
	
	var work_package_id=document.getElementById("failed_work_package_list").value;
	
	var action="print_work_package_error";
	var div_id="failedWPErrorDiv";
	var par1=work_package_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
}


//**************************************************************
function showWaitingWorkPlanList(work_plan_id) {
	
	
	var action="show_waiting_work_plan_list";
	var div_id="dependedWPBody";
	var par1=work_plan_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#dependedWPDiv").modal();
	
}
//****************************************************************
function setRecursiveFields(tab_id) {
	var recursive_fields=document.getElementById("recursive_fields").value;
	
	var action="set_recursive_fields";
	var div_id="NONE";
	var par1=tab_id;	
	var par2=recursive_fields;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);

}

//****************************************************************
function openAppOptions(app_id) {
	var action="make_app_options";
	var div_id="appOptionsBody";
	var par1=app_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#appOptionsDiv").modal();
	
}


//****************************************************************
function openAppOptions(app_id) {
	var action="make_app_options";
	var div_id="appOptionsBody";
	var par1=app_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#appOptionsDiv").modal();
	
}


//****************************************************************
function saveAppOptions() {
	var app_id=document.getElementById("opt_app_id").value;
	var last_run_point_statement=document.getElementById("last_run_point_statement").value;
	
	
	var action="save_app_options";
	var div_id="NONE";
	var par1=""+app_id;	
	var par2=""+last_run_point_statement;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#appOptionsDiv").modal("hide");
	
}

//****************************************************************
function hideShowNeededTables() {
	var el=document.getElementById("hide_needed_tables");
	if (!el) return;
	var checked_str="";
	if (el.checked) checked_str="checked";
	
	var action="set_hide_needed_tables_checked";
	var div_id="NONE";
	var par1=""+checked_str;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}

//****************************************************************
function setFamilyIdFilter() {
	var el=document.getElementById("filter_family_id");
	if (!el) return;
	var filter_family_id=el.value;
	
	var action="set_filter_family_id";
	var div_id="NONE";
	var par1=""+filter_family_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}

//****************************************************************
function rollbackCopyWorkPlan(rollback_wp_id) {
bootbox.confirm("Are you sure to roll this copy back?", function(result) {
		
		if(!result) return;

		var action="rollback_copy";
		var div_id="NONE";
		var par1=rollback_wp_id;	
			
		ajaxDynamicComponentCaller(action, div_id, par1);

	}); 
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

	location.href="default2.jsp";
	
}

//*********************************************************************
function showLoginError() {
	myalert("Invalid username or password");
}

//********************************************************************
function checkErrorCount() {
	var error_count=parseInt(document.getElementById("original_error_count").value);
	var elfinalerrcnt=document.getElementById("comparing_error_count");
	var final_error_count=error_count;
	
	var elactions=document.getElementById("error_actions");
	var actions="";
	
	var err_no=0;
	var fix_no=0;
	
	for (var i=0;i<error_count;i++) {
		err_no=i+1;
		var el=document.getElementById("missing_column_action_"+err_no);
		if (el.value!="") {
			final_error_count--;
			fix_no++;
			
			var elcolinfo=document.getElementById("missing_column_info_"+err_no);
			if (fix_no>1) actions=actions+"\n";
			actions=actions+elcolinfo.value+"="+el.value;
		}
		
	}
	
	elfinalerrcnt.value=""+final_error_count;
	elactions.value=""+actions;
	
}



//****************************************************
function showCommentForTable(env_id, table_cat, table_owner, table_name) {
	
	var app_type=document.getElementById("filter_app_type").value;
	
	
	var action="show_comment_for_table";
	var div_id="commentForTableBody";
	var par1=env_id;
	var par2=table_cat;	
	var par3=table_owner;	
	var par4=table_name;
	var par5=app_type;
	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	$("#commentForTableDiv").modal();
	
	
}


//****************************************************
function setDiscardFlagForTable(env_id,table_cat, table_owner, table_name, discard_flag) {
	
	var app_type=document.getElementById("filter_app_type").value;
	
	var action="set_discard_flag_for_table";
	var div_id="NONE";
	var par1=env_id;
	var par2=table_cat;	
	var par3=table_owner;	
	var par4=table_name;
	var par5=discard_flag;
	var par6=app_type;
	

		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5, par6);
	
	
	
}

//******************************************************
function removeTableComment() {
	var app_type=document.getElementById("filter_app_type").value;
	
	var comment_env_id=document.getElementById("comment_env_id").value;
	var comment_table_cat=document.getElementById("comment_table_cat").value;
	var comment_table_owner=document.getElementById("comment_table_owner").value;
	var comment_table_name=document.getElementById("comment_table_name").value;
	var comment_table_comment=document.getElementById("comment_table_comment").value;
	
	var action="set_comment_for_table";
	var div_id="NONE";
	var par1="REMOVE_COMMENT:"+app_type;	
	var par2=comment_table_cat;
	var par3=comment_table_owner;
	var par4=comment_table_name;
	var par5=comment_table_comment;
	var par6=comment_env_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5, par6);
	
	$("#commentForTableDiv").modal("hide");
	
}

//******************************************************
function saveTableComment() {
	
	var app_type=document.getElementById("filter_app_type").value;
	
	
	var comment_env_id=document.getElementById("comment_env_id").value;
	var comment_table_cat=document.getElementById("comment_table_cat").value;
	var comment_table_owner=document.getElementById("comment_table_owner").value;
	var comment_table_name=document.getElementById("comment_table_name").value;
	var comment_table_comment=document.getElementById("comment_table_comment").value;
	
	
	var action="set_comment_for_table";
	var div_id="NONE";
	var par1="SAVE_COMMENT:"+app_type;	
	var par2=comment_table_cat;
	var par3=comment_table_owner;
	var par4=comment_table_name;
	var par5=comment_table_comment;
	var par6=comment_env_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5, par6);
	
	$("#commentForTableDiv").modal("hide");
	
}

//**************************************************************************
function reorderTableRelInApp(tab_id, direction) {
	var action="reorder_table_relation_in_app";
	var div_id="NONE";
	var par1=tab_id;	
	var par2=direction;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}


//**************************************************************************
function reorderTable(tab_id, direction) {
	var action="reorder_table_in_app";
	var div_id="NONE";
	var par1=tab_id;	
	var par2=direction;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**********************************
function setCopyTableOrder(tab_id) {
	
	var action="set_copy_table_order";
	var div_id="copyTableOrderBody";
	var par1=tab_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#copyTableOrderDiv").modal();
}

//**********************************
function setCopyTableOrderDo() {
	
	var tab_id=document.getElementById("ordering_tab_id").value;
	var set_after_tab_id=document.getElementById("set_after_tab_id").value;
	var set_after_parent_tab_id=document.getElementById("set_after_parent_tab_id").value;
	
	if (set_after_tab_id=="") {
		myalert("Pick table to reorder");
		return;
	}
	
	var action="set_copy_table_order_do";
	var div_id="NONE";
	var par1=tab_id;	
	var par2=set_after_tab_id;	
	var par3=set_after_parent_tab_id;

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	$("#copyTableOrderDiv").modal("hide");


}

//****************************************************************************
function changeTableOrder(app_id, changing_tab_order, before_tab_order) {
	var action="change_table_order";
	var div_id="NONE";
	var par1=app_id;	
	var par2=changing_tab_order;	
	var par3=before_tab_order;

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//****************************************************************************
function addNewDependedApplication(app_id) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Application";
	var par2="copy_application_list";
	var par3="x";
	var par4="x";
	var par5="addNewDependedApplicationDo('"+app_id+"','#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//****************************************************************************
function addNewDependedApplicationDo(app_id, depended_app_id) {
	var action="add_depended_copy_application";
	var div_id="NONE";
	var par1=app_id;	
	var par2=depended_app_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//****************************************************************************
function deleteDependedCopyApp(app_rel_id) {

bootbox.confirm("Are you sure to remove this application ?", function(result) {
		
		if(!result) {
			el.checked=!el.checked;
			return;
		}

		var action="delete_apps_rel";
		var div_id="NONE";
		var par1=app_rel_id;	
			
		ajaxDynamicComponentCaller(action, div_id, par1);

	});
	
	
}


//****************************************************************************
function reorderDependedCopyApp(app_rel_id,direction) {

		var action="reorder_apps_rel";
		var div_id="NONE";
		var par1=app_rel_id;
		var par2=direction;
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2);

}


//***************************************************************************
function installServerSideScripts(db_id) {
	
	var action="install_server_side_scripts";
	var div_id="NONE";
	var par1=db_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//***************************************************************************
function discoverCopy(tab_id, discovery_type) {
	
	var el=document.getElementById("envList");
	
	if (el.value=="") {
		myalert("Pick a database to discover");
		return;
	}
	
	var env_id=el.value;
	
	var action="discover_for_copy";
	var div_id="discoverForCopyBody";
	var par1=env_id;
	var par2=tab_id;
	var par3=discovery_type;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
	$("#discoverForCopyDiv").modal();
	
}

//--------------------------------------------------------------
function listDMProxies() {
	var action="draw_dm_screen";
	var div_id="dmContainerDiv";
	var par1="x";
		
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//--------------------------------------------------------------
function addNewDMProxy() {
	var action="add_new_dm_proxy";
	var div_id="addNewDMProxyBody";
	var par1="x";
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("addNewDMProxyDiv");
}

//--------------------------------------------------------------
function showDMProxyActions(proxy_id) {
	
	var action="show_dm_proxy_actions";
	var div_id="addNewDMProxyBody";
	var par1=proxy_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("addNewDMProxyDiv");
}

//--------------------------------------------------------------
function showDMProxySessions(proxy_id, proxy_session_filter) {
	
	var action="show_dm_proxy_sessions";
	var div_id="proxySessionListBody";
	var par1=proxy_id;
	var par2=proxy_session_filter;
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("proxySessionListDiv");
}

//--------------------------------------------------------------
function startDMProxy(proxy_id) {
	
	var action="start_dm_proxy";
	var div_id="NONE";
	var par1=proxy_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
	$("#addNewDMProxyDiv").modal("hide");

	
}

//--------------------------------------------------------------
function stopDMProxy(proxy_id) {
	
	bootbox.confirm("Are you sure to stop the proxy?", function(result) {
		
		if(!result) {
			return;
		}

		var action="stop_dm_proxy";
		var div_id="NONE";
		var par1=proxy_id;
			
		ajaxDynamicComponentCaller(action, div_id, par1);
		
		
		$("#addNewDMProxyDiv").modal("hide");

	}); 

	
}


//--------------------------------------------------------------
function reloadDMProxyConfigurations(app_id) {
	
	bootbox.confirm("Are you sure to reload configuration for all proxies?", function(result) {
		
		if(!result) {
			return;
		}

		var action="reload_all_dm_proxy";
		var div_id="NONE";
		var par1=app_id;
			
		ajaxDynamicComponentCaller(action, div_id, par1);
		

	}); 

	
}

//--------------------------------------------------------------
function reloadDMProxy(proxy_id) {
	
	bootbox.confirm("Are you sure to reload configuration for this proxy?", function(result) {
		
		if(!result) {
			return;
		}

		var action="reload_dm_proxy";
		var div_id="NONE";
		var par1=proxy_id;
			
		ajaxDynamicComponentCaller(action, div_id, par1);
		
		
		$("#addNewDMProxyDiv").modal("hide");

	}); 

	
}

//-----------------------------------------------------------------------------
function saveDMConfiguration() {
	
	
	
	var active_proxy_id=document.getElementById("active_proxy_id").value;
	
	var proxy_name=document.getElementById("proxy_name").value;
	var proxy_type=document.getElementById("proxy_type").value;
	var secure_client=document.getElementById("secure_client").value;
	var secure_public_key=document.getElementById("secure_public_key").value;
	var proxy_port=document.getElementById("proxy_port").value;
	var target_host=document.getElementById("target_host").value;
	var target_port=document.getElementById("target_port").value;
	var proxy_charset=document.getElementById("proxy_charset").value;
	var target_app_id=document.getElementById("target_app_id").value;
	var target_env_id=document.getElementById("target_env_id").value;
	var max_package_size=document.getElementById("max_package_size").value;
	var is_debug=document.getElementById("is_debug").value;
	var extra_args=document.getElementById("extra_args").value;

	
	if (proxy_name.length=="") {
		myalert("Proxy name is empty");
		return;
	}
	
	if (proxy_port.length=="") {
		myalert("Proxy port is empty");
		return;
	} else {
		var valid_port_count=0;
				
		var ports=proxy_port.split(",");
		var dup_check="";
		
		for (var px=0;px<ports.length;px++) {
			var a_port=ports[px].trim();
			
			
			if (a_port=="") continue;
						
			if (isNaN(a_port)) {
				myalert("'"+a_port+"' is not a valid port number.");
				return;
			}
			
			var port_n=parseInt(a_port);
			
			if (port_n<1 || port_n>65535) {
				myalert("port number '"+a_port+"' is not a valid port number. Should be between 1 and 65535");
				return;
			}
			
			if (dup_check.indexOf(a_port)>-1)  continue;
			
			if (dup_check!="") dup_check=dup_check+",";
			dup_check=dup_check+a_port;
			valid_port_count++;

		}
		
		if (valid_port_count==0) {
			myalert("No a valid port specified.");
			return;
		}
				
		proxy_port=dup_check;
	}
	
	if (target_host.length=="") {
		myalert("Target host is empty");
		return;
	}
	
	if (target_port.length=="") {
		myalert("Target port is empty");
		return;
	}
	
	if (proxy_charset.length=="") {
		myalert("Proxy charset is empty");
		return;
	}
	
	
	if (target_app_id.length=="") {
		myalert("Application is empty");
		return;
	}
	
	if (target_env_id.length=="") {
		myalert("Target Database is empty");
		return;
	}
	
	if (secure_public_key=="") {
		secure_public_key="-";
	}
	
	var action="save_dm_configuration";
	var div_id="NONE";
	var par1=active_proxy_id;
	var par2=proxy_name;
	var par3=proxy_type+":"+secure_client+":"+secure_public_key+":"+proxy_port+":"+target_host+":"+target_port+":"+proxy_charset+":"+max_package_size+":"+is_debug+":"+extra_args;
	var par4=target_app_id;
	var par5=target_env_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	$("#addNewDMProxyDiv").modal("hide");
	
	
	
	
}

//--------------------------------------------------------------
function removeDMProxy(proxy_id) {
	
	bootbox.confirm("Are you sure to remove for this proxy?", function(result) {
		
		if(!result) {
			return;
		}

		var action="remove_dm_proxy";
		var div_id="NONE";
		var par1=proxy_id;
			
		ajaxDynamicComponentCaller(action, div_id, par1);
		
		
		$("#addNewDMProxyDiv").modal("hide");

	}); 

	
}





//****************************************************************
function openDynamicMaskingConfiguration(app_id) {
	var action="make_dynamic_masking_confiruration";
	var div_id="dynamicMaskingConfBody";
	var par1=app_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#dynamicMaskingConfDiv").modal();
	
}

//******************************************************************
function makeDynamicMaskingContentRules(app_id) {
	var action="make_content_based_content_rule";
	var div_id="contentRules";
	var par1=app_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//******************************************************************
function makeDynamicMaskingStatementExceptions(app_id) {
	var action="make_statement_exceptions";
	var div_id="statementExceptions";
	var par1=app_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//******************************************************************
function makeDynamicMaskingLogExceptions(app_id) {
	var action="make_rule_exceptions";
	var div_id="logExceptions";
	var par1=app_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//****************************************************************
function addNewContentBasedRule(app_id) {
	var action="add_new_content_based_rule";
	var div_id="NONE";
	var par1=app_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//****************************************************************
function addNewLogException(app_id) {
	var action="add_new_log_exception";
	var div_id="NONE";
	var par1=app_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//****************************************************************
function addNewStatementException(app_id) {
	var action="add_new_statement_exception";
	var div_id="NONE";
	var par1=app_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//****************************************************************
function removeContentBasedRule(app_id,rule_id) {
	
	bootbox.confirm("Are you sure to remove this rule?", function(result) {
		
		if(!result) 
			return;
		
		var action="remove_content_based_rule";
		var div_id="NONE";
		var par1=app_id;	
		var par2=rule_id;	
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		

	}); 
	
	
	
}

//****************************************************************
function removeLogException(app_id,exception_id) {
	
	bootbox.confirm("Are you sure to remove this log exception?", function(result) {
		
		if(!result) 
			return;
		
		var action="remove_log_exception";
		var div_id="NONE";
		var par1=app_id;	
		var par2=exception_id;	
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		

	}); 
	
	
	
}

//****************************************************************
function removeStatementException(app_id,exception_id) {
	
	bootbox.confirm("Are you sure to remove this statement exception?", function(result) {
		
		if(!result) 
			return;
		
		var action="remove_statement_exception";
		var div_id="NONE";
		var par1=app_id;	
		var par2=exception_id;	
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		

	}); 
	
	
	
}

//****************************************************************
function setContentBasedRuleOrder(app_id,rule_id,direction) {
	
	var action="reorder_content_based_rule";
	var div_id="NONE";
	var par1=app_id;	
	var par2=rule_id;	
	var par3=direction;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
	
}

//*****************************************************************
function changeContentBasedRuleField(el, app_id, rule_id, rule_field_name) {
	
	var field_value=el.value;
	
	if (rule_field_name=="env_id" && field_value=="" ) field_value="0";
	
	var action="change_content_based_rule_field_value";
	var div_id="NONE";
	var par1=app_id;
	var par2=rule_id;	
	var par3=rule_field_name;	
	var par4=field_value;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
}

//**********************************************************************
function selectSessionAll() {
	var select_all_el=document.getElementById("ch_select_all_sessions");
	
	if (!select_all_el) return;
	
	var is_all_checked=select_all_el.checked;
	
	for (var i=0;i<1000;i++) {
		var el=document.getElementById("session_ch_"+i);
		if (!el) break;
		
		el.checked=is_all_checked;
		
	}
}

//***********************************************************************
function getSelectedSessionIds() {
	
	var ret1="";
	var found=0;
	
	for (var i=0;i<1000;i++) {
		var el=document.getElementById("session_ch_"+i);
		if (!el) break;
		
		if (!el.checked) continue;
		
		
		
		if (found>0) ret1=ret1+",";
		ret1=ret1+el.value;
		
		found++;
		
	}
	
	return ret1;
	
}

//***********************************************************************
function listSessionCommands(proxy_id,proxy_session_filter) {
	
	var selected_Session_ids=getSelectedSessionIds();
	
	if (selected_Session_ids=="") {
		myalert("Pick at least a session to proceed");
		return;
	}
	
	
	
	var action="list_session_commands";
	var div_id="divSessionCommandsBody";
	var par1=proxy_id;
	var par2=selected_Session_ids;	
	var par3=proxy_session_filter;	
		
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
	$("#divSessionCommandsDiv").modal();
	
}

//***********************************************************************
function listBlacklistedSessionCommands(proxy_id,session_id,blacklist_id) {
	
	
	var action="list_blacklisted_session_commands";
	var div_id="divBlackListedSessionCommandsBody";
	var par1=proxy_id;
	var par2=session_id;	
	var par3=blacklist_id;	
		
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	
	$("#divBlackListedSessionCommandsDiv").modal();
	
}




//***********************************************************************
function setExceptionForSession(proxy_id) {
	
	var selected_Session_ids=getSelectedSessionIds();
	
	if (selected_Session_ids=="") {
		myalert("Pick at least a session to proceed");
		return;
	}
	
	var action="set_exception_for_sessions_dlg";
	var div_id="divSetExceptionForSessionsBody";
	var par1=proxy_id;
	var par2=selected_Session_ids;	
		
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
	$("#divSetExceptionForSessionsDiv").modal();
	
}


//***********************************************************************
function setExceptionForSessionDO() {
	
	var exception_proxy_id=document.getElementById("exception_proxy_id").value;
	var exception_selected_session_ids=document.getElementById("exception_selected_session_ids").value;
	var exception_duration=document.getElementById("exception_duration").value;
	var exception_period=document.getElementById("exception_period").value;
	var proxy_session_filter=document.getElementById("proxy_session_filter").value;
	
	
	
	var action="set_exception_for_sessions";
	var div_id="NONE";
	var par1=exception_proxy_id;
	var par2=exception_selected_session_ids;	
	var par3=exception_duration;
	var par4=exception_period;
	var par5=proxy_session_filter;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	
	$("#divSetExceptionForSessionsDiv").modal("hide");
	
}



//***********************************************************************
function clearExceptionForSession(proxy_id) {
	
	var selected_Session_ids=getSelectedSessionIds();
	var proxy_session_filter=document.getElementById("proxy_session_filter").value;
	
	if (selected_Session_ids=="") {
		myalert("Pick at least a session to proceed");
		return;
	}
	
	
	bootbox.confirm("Are you sure to clear exception for selected sessions?", function(result) {
		
		if(!result) {
			
			return;
		}

		var action="clear_exception_for_sessions";
		var div_id="NONE";
		var par1=proxy_id;
		var par2=selected_Session_ids;
		var par3=proxy_session_filter;
			
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

	}); 

	
}



//***********************************************************************
function terminateSessions(proxy_id) {
	
	var selected_Session_ids=getSelectedSessionIds();
	var proxy_session_filter=document.getElementById("proxy_session_filter").value;
	
	if (selected_Session_ids=="") {
		myalert("Pick at least a session to proceed");
		return;
	}
	
	
	bootbox.confirm("Are you sure to terminate selected sessions?", function(result) {
		
		if(!result) {
			
			return;
		}

		var action="terminate_sessions";
		var div_id="NONE";
		var par1=proxy_id;
		var par2=selected_Session_ids;
		var par3=proxy_session_filter;
			
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

	}); 

	
}


//***********************************************************************
function traceSessions(proxy_id, start_stop) {
	
	var selected_Session_ids=getSelectedSessionIds();
	var proxy_session_filter=document.getElementById("proxy_session_filter").value;
	
	if (selected_Session_ids=="") {
		myalert("Pick at least a session to proceed");
		return;
	}
	
	var conf_msg="Are you sure to start tracing for selected sessions?";
	if (start_stop=="STOP")
		conf_msg="Are you sure to stop tracing for selected sessions?";
	
	bootbox.confirm(conf_msg, function(result) {
		
		if(!result) {
			
			return;
		}

		var action="trace_sessions";
		var div_id="NONE";
		var par1=proxy_id;
		var par2=selected_Session_ids;
		var par3=proxy_session_filter;
		var par4=start_stop;
			
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);

	}); 

	
}
//***********************************************************************
function getMaskedResultList(log_id) {
	
	var action="get_masked_result_list";
	var div_id="divMaskedSampleBody";
	var par1=log_id;
		
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
	$("#divMaskedSampleDiv").modal();
	
}


//--------------------------------------------------------------
function setFilterSessions(proxy_id, proxy_session_filter, origin) {
	
	var action="set_dm_proxy_filter";
	var div_id="proxySessionFilterBody";
	var par1=proxy_id;
	var par2=proxy_session_filter;
	var par3=origin;
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	$("#proxySessionFilterDiv").modal();
	
	
}





//--------------------------------------------------------------
function clearFilterSessionsDO() {
	document.getElementById("filter_username").value="";
	document.getElementById("filter_session_info").value="";
	document.getElementById("filter_command").value="";
	
	setFilterSessionsDO();
}

//--------------------------------------------------------------
function setFilterSessionsDO() {
	
	var session_filter_proxy_id=document.getElementById("session_filter_proxy_id").value;
	var session_filter_proxy_session_filter=document.getElementById("session_filter_proxy_session_filter").value;
	var session_filter_origin=document.getElementById("session_filter_origin").value;
	
	
	var filter_username=document.getElementById("filter_username").value;
	var filter_session_info=document.getElementById("filter_session_info").value;
	var filter_command=document.getElementById("filter_command").value;
	
	var action="set_dm_proxy_filter_do_SESSION";
	if (session_filter_origin=="COMMAND") action="set_dm_proxy_filter_do_COMMAND";
	var div_id="NONE";
	var par1=session_filter_proxy_id;
	var par2=session_filter_proxy_session_filter;
	var par3=filter_username;
	var par4=filter_session_info;
	var par5=filter_command;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	$("#proxySessionFilterDiv").modal("hide");
}

//****************************************************************************
function addNewException() {
	var exception_scope=document.getElementById("exception_scope").value;
	var exception_obj_id=document.getElementById("exception_obj_id").value;
	var new_policy_group_id=document.getElementById("new_policy_group_id").value;
	
	if (new_policy_group_id=="") {
		myalert("Pick a policy group to proceed :");
		return;
	}
	
	var action="add_new_exception";
	var div_id="NONE";
	var par1=exception_scope;
	var par2=exception_obj_id;
	var par3=new_policy_group_id;
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//*************************************************************************
function removeException(exception_id) {
	bootbox.confirm("Sure to add this table as a child?", function(result) {
		
		if(!result) return;

		
		var exception_scope=document.getElementById("exception_scope").value;
		var exception_obj_id=document.getElementById("exception_obj_id").value;
		
		var action="remove_exception";
		var div_id="NONE";
		var par1=exception_scope;
		var par2=exception_obj_id;
		var par3=exception_id;
		
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
		
	}); 
}


//****************************************************************
function openDynamicMaskingExceptionWindow(exception_scope, exception_obj_id) {
	var action="make_exception_window:::::make_exception_button";
	var div_id="exceptionBody:::::exception_"+exception_scope+"_"+exception_obj_id;
	var par1=exception_scope+":::::"+exception_scope;	
	var par2=exception_obj_id+":::::"+exception_obj_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#exceptionDiv").modal();
	
}

//****************************************************************
function openDataPoolConfigurationDlg(data_pool_app_id) {
	
	var data_pool_env_id=document.getElementById("envList").value;
	
	if (data_pool_env_id=="") {
		myalert("Pick a database to proceed");
		return;
	}
	
	var action="open_data_pool_configuration_dlg";
	var div_id="dataPoolConfigurationBody";
	var par1=data_pool_app_id;
	var par2=data_pool_env_id;
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#dataPoolConfigurationDiv").modal();
	
	
}


//****************************************************************
function openDataPoolLovDlg(data_pool_app_id) {
	
	var data_pool_env_id=document.getElementById("envList").value;
	
	if (data_pool_env_id=="") {
		myalert("Pick a database to proceed");
		return;
	}
	
	var action="open_data_pool_lov_dlg";
	var div_id="dataPoolLovBody";
	var par1=data_pool_app_id;
	var par2=data_pool_env_id;
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#dataPoolLovDiv").modal();
	
	
}


//****************************************************************
function openDataPoolGroupDlg(data_pool_app_id) {
	
	var data_pool_env_id=document.getElementById("envList").value;
	
	if (data_pool_env_id=="") {
		myalert("Pick a database to proceed");
		return;
	}
	
	var action="open_data_pool_group_dlg";
	var div_id="dataPoolGroupBody";
	var par1=data_pool_app_id;
	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#dataPoolGroupDiv").modal();
	
	
}
//****************************************************************
function saveDataPoolConfiguration() {
	var pool_id=document.getElementById("pool_id").value;
	var family_id=document.getElementById("family_id").value;
	var base_sql=document.getElementById("base_sql").value;
	
	if (family_id=="") {
		myalert("Pick a family to proceed");
		return;
	}
	
	
	var action="save_data_pool_configuration";
	var div_id="NONE";
	var par1=pool_id;
	var par2=family_id;
	var par3=base_sql;
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	$("#dataPoolConfigurationDiv").modal("hide");
	
}
//****************************************************************
function addNewDataPoolPropertyDlg(data_pool_app_id, property_id) {
	
	var data_pool_env_id=document.getElementById("envList").value;
	
	if (data_pool_env_id=="") {
		myalert("Pick a database to proceed");
		return;
	}
	
	var action="open_data_pool_property_dlg";
	var div_id="dataPoolPropertyBody";
	var par1=data_pool_app_id;
	var par2=data_pool_env_id;
	var par3=property_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	$("#dataPoolPropertyDiv").modal();
	
	
}

//**************************************************
function addNewPoolLov(app_id, pool_id) {
	var action="add_pool_lov";
	var div_id="NONE";
	var par1=""+pool_id;	
	var par2=""+app_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**************************************************
function addNewPoolGroup(app_id, pool_id) {
	var action="add_pool_group";
	var div_id="NONE";
	var par1=""+pool_id;	
	var par2=""+app_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**************************************************
function removePoolLov(app_id, pool_lov_id) {
	bootbox.confirm("Sure to remove this LOV?", function(result) {
		
		if(!result) return;

		var action="remove_pool_lov";
		var div_id="NONE";
		var par1=""+pool_lov_id;	
		var par2=""+app_id;	
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		
	}); 


}

//**************************************************
function removePoolGroup(app_id, pool_group_id) {
	bootbox.confirm("Sure to remove this Group?", function(result) {
		
		if(!result) return;

		var action="remove_pool_group";
		var div_id="NONE";
		var par1=""+pool_group_id;	
		var par2=""+app_id;	
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		
	}); 


}


//**************************************************
function removePoolProperty(app_id, pool_property_id) {
	bootbox.confirm("Sure to remove this property?", function(result) {
		
		if(!result) return;

		var action="remove_pool_property";
		var div_id="NONE";
		var par1=""+pool_property_id;	
		var par2=""+app_id;	
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		
	}); 


}

//**************************************************
function reorderPoolGroup(app_id, pool_group_id, direction) {


	var action="reorder_pool_group_group";
	var div_id="NONE";
	var par1=""+pool_group_id;	
	var par2=""+app_id;	
	var par3=direction;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

}
//**************************************************
function savePoolLovField(el, pool_lov_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_pool_lov_field";
	var div_id="NONE";
	var par1=""+pool_lov_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function savePoolGroupField(el, pool_group_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_pool_group_field";
	var div_id="NONE";
	var par1=""+pool_group_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//*****************************************************************
function makePropertyGetMethodDetails(property_id) {
	
	var get_method=document.getElementById("get_method").value;

	if (get_method=="") {
		return;
	}
	
	var action="make_property_get_method_details";
	var div_id="dataPoolPropertyGetMethodDetailsDiv";
	var par1=property_id;
	var par2=get_method;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}

//******************************************************************
function saveDataPoolProperty() {
	
	var pool_app_id=document.getElementById("filter_app_id").value;
	var property_pool_id=document.getElementById("property_pool_id").value;
	var property_id="";
	
	property_id=document.getElementById("property_id").value;
	
	var property_name=document.getElementById("property_name").value;
	var property_title=document.getElementById("property_title").value;
	var get_method=document.getElementById("get_method").value;
	
	if (property_name=="") {
		myalert("Enter property name");
		return;
	}
	
	if (property_title=="") {
		myalert("Enter property title");
		return;
	}
	
	if (get_method=="") {
		myalert("Enter get method");
		return;
	}
	
	
	var action="";
	var div_id="";
	var par1="";
	var par2="";
	

	
	if (property_id=="0" || property_id==0) {
		action="create_new_pool_property";
		div_id="NONE";
		par1=property_pool_id;
		par2="x";
	} else {
		action="set_pool_property_id";
		div_id="NONE";
		par1=property_id;
		par2="x";
	}
	
	
	
	
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"property_title";
	par2=par2+		":::::"+property_title;
	
	
	
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"property_name";
	par2=par2+		":::::"+property_name;
	
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"get_method";
	par2=par2+		":::::"+get_method;
	
	var data_type=document.getElementById("data_type").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"data_type";
	par2=par2+		":::::"+data_type;
	
	var group_id=document.getElementById("group_id").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"group_id";
	par2=par2+		":::::"+group_id;
	
	var is_searchable=document.getElementById("is_searchable").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"is_searchable";
	par2=par2+		":::::"+is_searchable;
	
	var lov_id=document.getElementById("lov_id").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"lov_id";
	par2=par2+		":::::"+lov_id;
	
	var is_indexed=document.getElementById("is_indexed").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"is_indexed";
	par2=par2+		":::::"+is_indexed;
	
	var is_visible_on_search=document.getElementById("is_visible_on_search").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"is_visible_on_search";
	par2=par2+		":::::"+is_visible_on_search;
	
	var target_url=document.getElementById("target_url").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"target_url";
	par2=par2+		":::::"+target_url;
	
	var source_code=document.getElementById("source_code").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"source_code";
	par2=par2+		":::::"+source_code;
	
	var property_family_id=document.getElementById("property_family_id").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"property_family_id";
	par2=par2+		":::::"+property_family_id;
	
	var extract_method=document.getElementById("extract_method").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"extract_method";
	par2=par2+		":::::"+extract_method;
	
	var extract_method_parameter=document.getElementById("extract_method_parameter").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"extract_method_parameter";
	par2=par2+		":::::"+extract_method_parameter;
	

	
	var is_valid=document.getElementById("is_valid").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"is_valid";
	par2=par2+		":::::"+is_valid;
	
	
	var is_valid=document.getElementById("is_valid").value
	action=action+	":::::"+"set_pool_property_field";
	div_id=div_id+	":::::"+"NONE";
	par1=par1+		":::::"+"is_valid";
	par2=par2+		":::::"+is_valid;
	
	
	//---------------------------------------------
	
	action=action+	":::::"+"list_pool_properties";
	div_id=div_id+	":::::"+"divPoolProperties";
	par1=par1+		":::::"+pool_app_id;
	par2=par2+		":::::"+"x";
	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
	$("#dataPoolPropertyDiv").modal("hide");

	
}

//***********************************************************************
function listPoolProperties(pool_app_id) {
	var action="list_pool_properties";
	var div_id="divPoolProperties";
	var par1=pool_app_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1);
}



//-----------------------------------------------------------------
function listPoolInstances() {
	
	var action="draw_pool_screen";
	var div_id="divDataPoolBody";
	var par1="x";

	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//-----------------------------------------------------------------
function addNewDataPoolInstance() {
	var action="add_new_data_pool_instancel_dlg";
	var div_id="newDataPoolInsBody";
	var par1="x";

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#newDataPoolInsDiv").modal();
}

//-----------------------------------------------------------------
function addNewDataPoolInstanceDO() {
	
	var pool_ins_app_id=document.getElementById("pool_ins_app_id").value;
	var pool_ins_target_id=document.getElementById("pool_ins_target_id").value;
	var target_pool_size=document.getElementById("target_pool_size").value;
	var is_debug=document.getElementById("is_debug").value;
	var paralellism_count=document.getElementById("paralellism_count").value;
	
	if (pool_ins_app_id=="") {
		myalert("Pick an application to proceed");
		return;
	}
	
	if (pool_ins_target_id=="") {
		myalert("Pick a target to proceed");
		return;
	}
	
	var action="add_new_data_pool_instance";
	var div_id="NONE";
	var par1=""+pool_ins_app_id;
	var par2=""+pool_ins_target_id;
	var par3=""+target_pool_size;
	var par4=""+is_debug;
	var par5=""+paralellism_count;

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	$("#newDataPoolInsDiv").modal("hide");
}

//-----------------------------------------------------------------
function removeDataPoolInstance(pool_instance_id) {
	
	
	
	bootbox.confirm("Sure to remove this pool instance?", function(result) {
		
		if(!result) return;

		var action="remove_data_pool_instance";
		var div_id="NONE";
		var par1=pool_instance_id;
		
		ajaxDynamicComponentCaller(action, div_id, par1);
		
	}); 

}

//-----------------------------------------------------------------
function removeDataPoolInstance(pool_instance_id) {
	
	
	
	bootbox.confirm("Sure to remove this pool instance?", function(result) {
		
		if(!result) return;

		var action="remove_data_pool_instance";
		var div_id="NONE";
		var par1=pool_instance_id;
		
		ajaxDynamicComponentCaller(action, div_id, par1);
		
	}); 

}

//-----------------------------------------------------------------
function startDataPoolInstance(pool_instance_id) {
	
	
	
	bootbox.confirm("Sure to start this pool instance?", function(result) {
		
		if(!result) return;

		var action="start_data_pool_instance";
		var div_id="NONE";
		var par1=pool_instance_id;
		
		ajaxDynamicComponentCaller(action, div_id, par1);
		
	}); 

}
//-----------------------------------------------------------------
function stopDataPoolInstance(pool_instance_id) {
	
	
	
	bootbox.confirm("Sure to stop this pool instance?", function(result) {
		
		if(!result) return;

		var action="stop_data_pool_instance";
		var div_id="NONE";
		var par1=pool_instance_id;
		
		ajaxDynamicComponentCaller(action, div_id, par1);
		
	}); 

}

//-----------------------------------------------------------------
function refreshDataPoolInstance(pool_instance_id) {
	
	
	
	bootbox.confirm("Sure to refresh this pool instance?", function(result) {
		
		if(!result) return;

		var action="refresh_data_pool_instance";
		var div_id="NONE";
		var par1=pool_instance_id;
		
		ajaxDynamicComponentCaller(action, div_id, par1);
		
	}); 

}


//-----------------------------------------------------------------
function setDataPoolInstanceParameters(pool_instance_id) {
		var action="set_data_pool_instance_parameters_dlg";
		var div_id="editDataPoolInsBody";
		var par1=pool_instance_id;
		
		ajaxDynamicComponentCaller(action, div_id, par1);
		
		$("#editDataPoolInsDiv").modal();


}



//-----------------------------------------------------------------
function reserveDataPoolInstance(pool_instance_id) {
	
	var action="reservation_data_pool_instance_dlg";
	var div_id="reservationBody";
	var par1=pool_instance_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	$("#reservationDiv").modal();

}


//-----------------------------------------------------------------
function setDataPoolInstanceParametersDO() {
		
	var pool_instance_id=document.getElementById("editing_pool_instance_id").value;
	var target_pool_size=document.getElementById("editing_target_pool_size").value;
	var is_debug=document.getElementById("editing_is_debug").value;
	var paralellism_count=document.getElementById("editing_paralellism_count").value;
	
	var action="set_data_pool_instance_parameters_do";
	var div_id="NONE";
	var par1=pool_instance_id;
	var par2=target_pool_size;
	var par3=is_debug;
	var par4=paralellism_count;
	
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
	$("#editDataPoolInsDiv").modal("hide");


}

//-----------------------------------------------------------------
function reloadPoolDataList(pool_instance_id) {
	
	var action="reload_pool_data_list";
	var div_id="divPoolDataList";
	var par1=pool_instance_id;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	

}

//-----------------------------------------------------------------
function pickFromDataPool(pool_instance_id,data_id) {
	
	var action="pick_from_data_pool";
	var div_id="pickDataPoolBody";
	var par1=pool_instance_id;
	var par2=data_id;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#pickDataPoolDiv").modal();

}

//-----------------------------------------------------------------
function pickFromDataPoolDO() {
	
	var pool_instance_id=document.getElementById("picking_pool_instance_id").value;
	var data_id=document.getElementById("picking_data_id").value;
	var reservation_note=document.getElementById("reservation_note").value;
	
	var action="pick_from_data_pool_do";
	var div_id="NONE";
	var par1=pool_instance_id;
	var par2=data_id;
	var par3=reservation_note;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	$("#pickDataPoolDiv").modal("hide");
	

}

//-------------------------------------------------------------------
function setDataPoolFilters(pool_instance_id)  {
	
	var action="";
	var div_id="";
	var par1="";
	var par2="";
	var par3="";
	
	
	
	for (var p=0;p<1000;p++) {
		var propEl=document.getElementById("filter_property_name_"+p);
		if (!propEl) break;
		var prop_name=propEl.value;
		var prop_val=document.getElementById("val_of_"+prop_name).value;
		
		
		
		
		action=		action+"set_data_pool_filter"		+":::::";
		div_id=		div_id+"NONE"						+":::::";
		par1=		par1+pool_instance_id				+":::::";
		par2=		par2+prop_name						+":::::";
		par3=		par3+prop_val						+":::::";
		
	}
	
	
	action=		action+"reload_pool_data_list";
	div_id=		div_id+"divPoolDataList";
	par1=		par1+pool_instance_id;
	par2=		par2+"x";
	par3=		par3+"x";


	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//-------------------------------------------------------------------
function dataPoolSetShowOnlyMyReservations(pool_instance_id) {

	var show_only_my_reservatinons="NO";
	if (document.getElementById("ch_show_only_my_reservatinons").checked) show_only_my_reservatinons="YES";
	
	var action="set_only_my_reservations_filter";
	var div_id="NONE";
	var par1=pool_instance_id;
	var par2=show_only_my_reservatinons;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**************************************************
function reorderPoolProperty(app_id, pool_property_id, direction) {


	var action="reorder_pool_property";
	var div_id="NONE";
	var par1=""+pool_property_id;	
	var par2=""+app_id;	
	var par3=direction;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

}
//**************************************************
function setMaskDiscoveryAction(discovery_id, action_name) {

	var conf_msg="";
	if (action_name=="CANCEL") conf_msg="Sure to cancel?";
	else if (action_name=="RESTART") conf_msg="Sure to restart?";
	else if (action_name=="DELETE") conf_msg="Sure to remove?";

	bootbox.confirm(conf_msg, function(result) {
		
		if(!result)  return;

		
		var action="set_mask_discovery_action";
		var div_id="NONE";
		var par1=""+discovery_id;	
		var par2=""+action_name;
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);

	}); 

	

}

//**************************************************
function changeProxyDebugFlag(proxy_id, current_debug_flag) {

	bootbox.confirm("Are you sure to change  debug flag for this proxy?", function(result) {
		
		if(!result) {
			return;
		}

		var action="set_proxy_debug_flag";
		var div_id="NONE";
		var par1=proxy_id;
		var par2=current_debug_flag;
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		
		
		$("#addNewDMProxyDiv").modal("hide");

	}); 


	

}


//**************************************************
function saveCopyFilterField(el, checklist_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_copy_checklist_field";
	var div_id="NONE";
	var par1=""+checklist_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//************************************************
function addNewCopyCheckList(related_app_id) {
	bootbox.prompt("Enter check name  to add ", function(result) {                
		  if (result !== null) {
			  
			  if (result.length==0) {
				  myalert(" check name cannot be empty");
				  return;
			  }
			  
			  var action="add_new_copy_checklist";
				var div_id="NONE";
				var par1=""+related_app_id;	
				var par2=result;

				ajaxDynamicComponentCaller(action, div_id, par1, par2);

		  }
		});	
}

//--------------------------------------------------------------
function removeCopyCheckList(checklist_id) {
	
	bootbox.confirm("Are you sure to remove this check ?", function(result) {
		
		if(!result) {
			return;
		}

		var action="remove_copy_checklist";
		var div_id="NONE";
		var par1=checklist_id;
			
		ajaxDynamicComponentCaller(action, div_id, par1);
		
		

	}); 

	
}

//**************************************************
function openDatabaseCatalogList(db_id, db_catalog) {
	
	
	var action="open_database_catalog_list";
	var div_id="CatalogListDivBody";
	var par1=""+db_id;	
	var par2=db_catalog;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#CatalogListDiv").modal();
	
}

//**************************************************
function setDatabaseCatalog(db_id, db_catalog) {
	
	
	var action="set_database_catalog";
	var div_id="NONE";
	var par1=""+db_id;	
	var par2=db_catalog;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	$("#CatalogListDiv").modal("hide");
	
}
//**************************************************
function makeDatabaseCatalogField(db_id, db_catalog) {
	
	
	var action="make_database_catalog_field";
	var div_id="Divcat_for_"+db_id;
	var par1=""+db_id;	
	var par2=db_catalog;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}


//**************************************************
function changeScramblePartialType(p_mask_prof_id) {
	
	var scramble_type=document.getElementById("scramble_part_type").value;
	
	var action="change_scramble_partial_type";
	var div_id="NONE";
	var par1=""+p_mask_prof_id;	
	var par2=scramble_type;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}

//**************************************************
function makeScramblePartialParameters(p_mask_prof_id) {
	
	
	var action="make_scramble_partial_parameters";
	var div_id="scramblePartialParsDiv";
	var par1=""+p_mask_prof_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}

//**************************************************
function onPartitionTableChange(app_id,el) {
	
	var partition_tab_id=el.value;
	var source_env_id=document.getElementById("source_env_id").value;
	
	if (partition_tab_id=="") {
		partition_tab_id="0";
		fillTargetInfo(app_id);
	} else {
		fillTargetInfo(app_id,partition_tab_id);
	}
	
	
	var action="make_partition_list_for_table";
	var div_id="partitionListDiv";
	var par1=""+partition_tab_id;	
	var par2=""+source_env_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}



//**************************************************
function saveOverrideParamField(el, override_id, app_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_override_param_field";
	var div_id="NONE";
	var par1=""+override_id;	
	var par2=""+app_id;	
	var par3=field_name;
	var par4=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}

//************************************************
function makeDynamicMaskingOverrideParams(app_id){
	var action="make_override_param_list";
	var div_id="overrideParams";
	var par1=app_id;
	

		
	ajaxDynamicComponentCaller(action, div_id, par1);
}
 
//****************************************************************************
function addNewOverrideParameter(app_id) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Policy Group";
	var par2="policy_group_list";
	var par3="x";
	var par4="x";
	var par5="addNewOverrideParameterDO('"+app_id+"','#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	//showModal("lovDiv");
	
	$("#lovDiv").modal('show');
}

//***********************************************
function addNewOverrideParameterDO(app_id, policy_group_id) {
	var action="add_new_overrideparameter";
	var div_id="NONE";
	var par1=app_id;
	var par2=policy_group_id;
	

		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//****************************************************************
function removeOverrideParam(app_id,overriding_id) {
	
	bootbox.confirm("Are you sure to remove this overriding?", function(result) {
		
		if(!result) 
			return;
		
		var action="remove_overriding_param";
		var div_id="NONE";
		var par1=app_id;	
		var par2=overriding_id;	
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		

	}); 
}


//--------------------------------------------------------------------
function changeDbPassword(db_id) {
	var action="make_change_db_password_form";
	var div_id="passwordDivBody";
	var par1=db_id;	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("passwordDiv");
}

//--------------------------------------------------------------------
function testSessionValidationRegex(session_validation_id, test_regex_field_name) {
	var action="make_test_session_validation_form";
	var div_id="testRegexBody";
	var par1=session_validation_id;	
	var par2=test_regex_field_name;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("testRegexDiv");
}



//--------------------------------------------------------------------
function changeDbPasswordDO() {
	
	var change_password_db_id=document.getElementById("change_password_db_id").value;
	var db_new_password=document.getElementById("db_new_password").value;
	
	if (db_new_password=="") {
		myalert("Enter a password to proceed");
		return;
	}
	
	$("#passwordDiv").modal("hide");
	
	var encoded_password=encrypt(db_new_password);
	
	
	var action="change_db_password_form";
	var div_id="NONE";
	var par1=change_password_db_id;	
	var par2=encoded_password;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}

//--------------------------------------------------------------------
function executeRegexTest() {
	var test_regex_statement=document.getElementById("test_regex_statement").value;
	var test_for_statement_check_regex=document.getElementById("test_for_statement_check_regex").value;
	
	var patt = new RegExp(test_for_statement_check_regex);
	var res = patt.test(test_regex_statement);
	
	
	if (res==true) 
		document.getElementById("test_regex_result").value="Test OK";
	else 
		document.getElementById("test_regex_result").value="Test Not OK";
	
}


//--------------------------------------------------------------------
function saveSessionValidationRegex() {

	var session_validation_id=document.getElementById("test_session_validation_id").value;
	var test_session_validation_regex_field_name=document.getElementById("test_session_validation_regex_field_name").value;
	var test_for_statement_check_regex=document.getElementById("test_for_statement_check_regex").value;
	
	
	var action="save_session_validation_regex";
	var div_id="NONE";
	var par1=session_validation_id;	
	var par2=test_session_validation_regex_field_name;	
	var par3=encrypt(test_for_statement_check_regex);	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	$("#testRegexDiv").modal("hide");
}


//--------------------------------------------------------------------
function buildSessionValidationScript(session_validation_id, script_field) {
	var action="build_session_validation_script";
	var div_id="scriptBuilderBody";
	var par1=session_validation_id;	
	var par2=script_field;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	showModal("scriptBuilderDiv");

	
}

//--------------------------------------------------------------------
function saveScriptTestClause() {

	var session_validation_id=document.getElementById("build_script_session_validation_id").value;
	var session_validation_script_test_clause=document.getElementById("session_validation_script_test_clause").value;
	
	session_validation_script_test_clause=encrypt(session_validation_script_test_clause);
	
	var action="save_session_validation_test_clause";
	var div_id="NONE";
	var par1=session_validation_id;	
	var par2=session_validation_script_test_clause;	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}

//--------------------------------------------------------------------
function setScriptChanged() {

	document.getElementById("build_script_changed").value="YES";
	
	var session_validation_id=document.getElementById("build_script_session_validation_id").value;
	var build_script_field=document.getElementById("build_script_field").value;
	
	
	var action="reset_session_validation_script_validated";
	var div_id="NONE";
	var par1=session_validation_id;	
	var par2=build_script_field;	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}

//--------------------------------------------------------------------
function checkScriptChange() {
	var session_validation_id=document.getElementById("build_script_session_validation_id").value;
	var is_changed=document.getElementById("build_script_changed").value;
	
	if (is_changed=="YES") {
		bootbox.confirm("Script has changed. are you sure to close without saving the changes?", function(result) {
			
			if(!result) return;
			
			$("#scriptBuilderDiv").modal("hide");
			makeSessionValidationEditor(""+session_validation_id);
			
		}); 
	} else {
		$("#scriptBuilderDiv").modal("hide");
		makeSessionValidationEditor(""+session_validation_id);
	}
}
//--------------------------------------------------------------------
function saveSessionValidationScript() {
	
	var build_script_changed=document.getElementById("build_script_changed").value;
	
	if (build_script_changed=="NO") {
		myalert("No change to save.");
		return;
	}

	var session_validation_id=document.getElementById("build_script_session_validation_id").value;
	var build_script_field=document.getElementById("build_script_field").value;
	var building_script=document.getElementById("building_script").value;
	
	building_script=encrypt(building_script);
	
	var action="save_session_validation_script";
	var div_id="NONE";
	var par1=session_validation_id;	
	var par2=build_script_field;	
	var par3=building_script;	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	//$("#scriptBuilderDiv").modal("hide");
}


//--------------------------------------------------------------------
function compileParameters() {
	var ret1="";
	
	for (var p=0;p<100;p++) {
		var el=document.getElementById("script_test_param_"+p);
		if (!el) break;
		
		var par_name=el.name;
		var par_value=el.value;
		
		if (ret1!="") ret1=ret1+"|::|";
		ret1=ret1+par_name+"="+par_value;
	}
	
	return ret1;
}
//--------------------------------------------------------------------
function executeScriptTest() {

	
	
	var session_validation_id=document.getElementById("build_script_session_validation_id").value;
	var build_script_field=document.getElementById("build_script_field").value;
	var building_script=document.getElementById("building_script").value;
	var session_validation_script_test_clause=document.getElementById("session_validation_script_test_clause").value;
	
	building_script=encrypt(building_script);
	session_validation_script_test_clause=encrypt(session_validation_script_test_clause);
	
	var action="execute_session_validation_script";
	var div_id="scriptTestResultsDiv";
	var par1=session_validation_id;	
	var par2=build_script_field;	
	var par3=building_script;	
	var par4=session_validation_script_test_clause;	
	var par5=encrypt(compileParameters());
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
}
//--------------------------------------------------------------------
function scriptSaved() {
	document.getElementById("build_script_changed").value="NO";
	myalert("Script saved.");
	
}


//--------------------------------------------------------------------
function insertParameterIntoScript(par_name) {
	var elScriptMemo=document.getElementById("building_script");
	
	
	par_name="${"+par_name+"}";
	
	if (elScriptMemo.selectionStart || elScriptMemo.selectionStart != 0) {
		var startPos = elScriptMemo.selectionStart;
	     var endPos = elScriptMemo.selectionEnd;

	     elScriptMemo.value = elScriptMemo.value.substring(0, startPos) + par_name +elScriptMemo.value.substring(endPos, elScriptMemo.value.length);
		
	     elScriptMemo.selectionStart = startPos;
	     elScriptMemo.selectionEnd = startPos + par_name.length;
	} else {
		elScriptMemo.value += par_name;
	}
	
	makeEditTestJSParamList();
	
	elScriptMemo.focus();
	
	

	
}



//*************************************************************************
function setInitialJavaScriptForSessionValidationScript(){
//*************************************************************************

	document.getElementById('building_script').value="function calcul()\n"+
											 "{\n"+
											 "return \"${CLAUSE}\";\n"+
											 "}\n\n"+
											 "var a=\"\";\n"+
											 "a=calcul();\n";

	setScriptChanged();

}

//--------------------------------------------------------------------
function makeEditTestJSParamList() {

	var session_validation_id=document.getElementById("build_script_session_validation_id").value;
	var build_script_field=document.getElementById("build_script_field").value;
	var building_script=document.getElementById("building_script").value;
	
	building_script=encrypt(building_script);
	
	var action="make_edit_test_js_param_list";
	var div_id="scriptTestParametersDiv";
	var par1=session_validation_id;	
	var par2=build_script_field;	
	var par3=building_script;	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//--------------------------------------------------------------------
function makeEditTestJSParamList() {

	var session_validation_id=document.getElementById("build_script_session_validation_id").value;
	var build_script_field=document.getElementById("build_script_field").value;
	var building_script=document.getElementById("building_script").value;
	
	building_script=encrypt(building_script);
	
	var action="make_edit_test_js_param_list";
	var div_id="scriptTestParametersDiv";
	var par1=session_validation_id;	
	var par2=build_script_field;	
	var par3=building_script;	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}


//-------------------------------------------------------------------------
function setJsTestParam(el,param_name) {
	
	var param_val=el.value;
	if (param_val=="") param_val="-";

	var action="set_js_test_param";
	var div_id="NONE";
	var par1=param_name;
	var par2=encrypt(param_val);
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	

}

//--------------------------------------------------------------------
function removessionValidationScript() {
	
	var session_validation_id=document.getElementById("build_script_session_validation_id").value;
	var build_script_field=document.getElementById("build_script_field").value;
	
	building_script=encrypt(building_script);
	
	var action="remove_session_validation_script";
	var div_id="NONE";
	var par1=session_validation_id;	
	var par2=build_script_field;	
	
	bootbox.confirm("Sure to remove the script?", function(result) {
		
		if(!result) return;
		
		$("#scriptBuilderDiv").modal("hide");
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		
	}); 

}

//-------------------------------------------------------------------------------
function makeMonitoringPolicyGroupEditor(monitoring_id) {
	var action="make_monitoring_policy_group_editor";
	var div_id="divPolicyGroupsFor"+monitoring_id;
	var par1=monitoring_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}
//-------------------------------------------------------------------------------
function makeMonitoringApplicationEditor(monitoring_id) {
	var action="make_monitoring_application_editor";
	var div_id="divApplicationFor"+monitoring_id;
	var par1=monitoring_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}
//-------------------------------------------------------------------------------
function makeMonitoringColumnsEditor(monitoring_id) {
	var action="make_monitoring_columns_editor";
	var div_id="divMonitoringColumnsFor"+monitoring_id;
	var par1=monitoring_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}
//-------------------------------------------------------------------------------
function makeMonitoringExpressionsEditor(monitoring_id) {
	var action="make_monitoring_expressions_editor";
	var div_id="divMonitoringExpressionsFor"+monitoring_id;
	var par1=monitoring_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}
//-------------------------------------------------------------------------------
function updateMonitoringPolicyGroup(monitoring_id, policy_group_id, method) {
	var action="update_monitoring_policy_group";
	var div_id="NONE";
	var par1=monitoring_id;	
	var par2=policy_group_id;	
	var par3=method;	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}
//-------------------------------------------------------------------------------
function updateMonitoringApplication(monitoring_id, app_id, method) {
	var action="update_monitoring_application";
	var div_id="NONE";
	var par1=monitoring_id;	
	var par2=app_id;	
	var par3=method;	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}
//--------------------------------------------------------------------------------
function removeMonitoringRule(monitoring_id, monitoring_rule_id, rule_type) {
	
	
	bootbox.confirm("Sure to remove the rule?", function(result) {
		
		if(!result) return;
		
		var action="remove_monitoring_rule";
		var div_id="NONE";
		var par1=monitoring_id;	
		var par2=monitoring_rule_id;	
		var par3=rule_type;
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
		
		
	}); 

}



//************************************************
function addNewMonitoringRule(monitoring_id, rule_type) {
	var action="add_new_monitoring_rule";
	var div_id="NONE";
	var par1=monitoring_id;
	var par2=rule_type;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}


//***********************************************************************
function blacklistSessions(proxy_id) {
	
	var selected_Session_ids=getSelectedSessionIds();
	var proxy_session_filter=document.getElementById("proxy_session_filter").value;
	
	if (selected_Session_ids=="") {
		myalert("Pick at least a session to proceed");
		return;
	}
	
	
	bootbox.confirm("Are you sure to add selected sessions to blacklist?", function(result) {
		
		if(!result) {
			
			return;
		}

		var action="blacklist_sessions";
		var div_id="NONE";
		var par1=proxy_id;
		var par2=selected_Session_ids;
		var par3=proxy_session_filter;
			
			
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);

	}); 

	
}



//--------------------------------------------------------------
function manageDMProxyBlacklist(proxy_id) {
	
	var action="manage_proxy_blacklist";
	var div_id="proxyManageBlacklistBody";
	var par1=proxy_id;
	
		
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	showModal("proxyManageBlacklistDiv");
}




//--------------------------------------------------------------
function listBlackist() {
	
	var searchBlackListProxyId=document.getElementById("searchBlackListProxyId").value;
	var searchtext=document.getElementById("searchTextForBlacklist").value;
	var searchCheckBoxForBlackList=document.getElementById("searchCheckBoxForBlackList");
	
	var only_active="NO";
	if (searchCheckBoxForBlackList.checked) only_active="YES";
	
	
	var action="list_black_list";
	var div_id="listOfBlackListDiv";
	var par1=searchBlackListProxyId;
	var par2=encrypt(searchtext);
	var par3=only_active;
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);


	
	
}
