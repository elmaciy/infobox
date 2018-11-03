
var AJAX = createXMLHttpRequest();

var delim=":::::";

var z_index_counter=9999;



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




var orig_div_contents=[];


//*************************************************************************
function ajaxDynamicComponentCaller(action,div_id,par1,par2,par3,par4,par5){
//*************************************************************************	


	
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
	  
	 
	  clearHourGlass();
	  
	  var json =null;
	  
	  try {json=JSON.parse( AJAX.responseText ); } catch(err) {
		  json =null;
		  myalert("Json Parse Error : " +err+" (See browser's console for AJAX response.)");
		  console.log("AJAX.responseText : " +AJAX.responseText);
		  location.href="default.jsp";
		  return;
		  }
	  
	 // AJAX.responseText
	  
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

//********************************
function validateEntry(request_id, field_object_id, entry_type, regex, is_validated, is_mandatory, fire_event) {
	//table_id : request_id
	var entry_field=document.getElementById(field_object_id);
	if(!entry_field) {
		console.log("no such object found : "  + field_object_id);
		return;
	}
	var entered_val=entry_field.value;

	
	var warning_box=document.getElementById("warning_box_"+field_object_id);
	
	
	try{warning_box.innerHTML="";} catch(err) {console.log("warning box not found.");}
	
	enableMadRequestButton(request_id);
	
	var validation_msg=getFlexFieldValidationMsg(entry_type, regex, is_validated, is_mandatory,entered_val);
	
	if (validation_msg.length>0) {
		warning_box.innerHTML="<font color=red>Invalid Entry!</font>";
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
function setCheckboxValue(chel, hidden_id) {
	
	var elhidden=document.getElementById(hidden_id);
	
	
	var val_to_set="NO";
	if (chel.checked) val_to_set="YES";
	
	elhidden.value=val_to_set;
	
	
	
	
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


//*******************************************************************
function doLoginOnEnter(e) {
	if (e.keyCode == 13) {
        doLogin();
        return false;
    }
}


//********************************************************************
function doLogin() {
	var user=document.getElementById("login_username").value;
	var pass=document.getElementById("login_password").value;
	
	
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
	
	
	hideModalByBaseId("loginBox");
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
//**********************************************************************

function gotoHome() {

	try  {location.href="default.jsp";} catch(e) {}
	
	
}




//*************************************
function printabout() {
	
	var action="print_about";
	var div_id="aboutDiv";
	var par1="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1);

}

//*************************************
function checkLogin() {
	
	var action="check_login_on_load";
	var div_id="NONE";
	var par1="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
	

}



//*************************************
function showModalByBaseId(baseId) {
	var modaldivid=baseId+"Div";
	var el=document.getElementById(modaldivid);
	if (!el) myalert("Modal not found : " + modaldivid);
	z_index_counter++;
	el.style.zIndex=""+z_index_counter;
	$('#'+modaldivid).modal('show');
}
//*************************************
function hideModalByBaseId(baseId) {
	var modaldivid=baseId+"Div";
	var el=document.getElementById(modaldivid);
	if (!el)  {
		console.log("Modal not found : " + modaldivid);
		return;
	}
	

	
	$('#'+modaldivid).modal('hide');
}
//**********************************
function makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent) {
	 
	
	var el=document.getElementById(divBaseId+"Div");

	if (el) {
		z_index_counter++;
		el.style.zIndex = ""+z_index_counter;
		return;
	}
	

	
	
	var modal_html=	""+
	"		 <div class=\"modal fade bs-example-modal-"+modalSize+"\" id=\""+divBaseId+"Div\" data-keyboard=\"true\" data-backdrop=\"static\" style=\"z-index: "+(++z_index_counter)+"; \"> \n"+
	"		<div class=\"modal-dialog modal-"+modalSize+"\"> \n";
	
	if (modalTitle!="")
		modal_html=modal_html+
		"		      	<div class=\"modal-content\" style=\"background-color:black; \"> \n"+
		"		        	 <font color=\"white\"><b><big>&nbsp;"+modalTitle+"&nbsp;</big></b></font> \n";
			
	if(showCloseButton)
		modal_html=modal_html+
			"		 			<button type=\"button\" class=\"close\"  data-dismiss=\"modal\" > \n" +
			"						<font color=white>  "+			
			"		 				<span aria-hidden=\"true\">&times;</span> \n" +
			"		 				<span class=\"sr-only\">Close</span> \n" +
			"						</font> 		"+			
			"		 			</button>  \n";
		
		modal_html=modal_html+"		      	</div> \n";
	
		
		modal_html=modal_html+
			"		 	<div class=\"modal-content\"> \n"+
			"			 	 <div class=\"modal-body\" id=\""+divBaseId+"Body\" style=\"min-height: 0px; max-height: 500px; overflow-x: scroll; overflow-y: scroll;\" > \n"+
			"			        <p>"+initialContent+"</p> \n"+
			"		      	</div> <!--  modal body --> \n";
	
		if (showCloseButton || buttonTitle!="") {
			modal_html=modal_html+
			"<div class=\"modal-footer\"  style=\"background-color:lightgray; \"> \n";
		
		if(showCloseButton) 
			modal_html=modal_html+
			"<button type=\"button\" class=\"btn btn-default btn-sm\"  data-dismiss=\"modal\" >Close</button> \n";
		
			
		if (buttonTitle!="") 
			modal_html=modal_html+
				"<button type=\"button\" class=\"btn btn-primary btn-sm\" onclick=\""+buttonScript+"\">"+buttonTitle+"</button> \n";
			
		modal_html=modal_html+
			"</div> \n";
		}
		
		
	modal_html=modal_html+
	"		 	</div> <!--  modal content --> \n"+
	"		</div> <!--  modal dialog -->  \n"+
	"	</div> <!--  modal fade -->"; 

	$('body').append(modal_html);
	
	//showModalByBaseId(divBaseId);
}


//*************************************
function showLoginBox() {
	
	
	
	hideModalByBaseId("loginBox");
	
	var divBaseId="loginBox";
	var modalSize="md";
	var modalTitle="Login Required!";
	var buttonTitle="Login";
	var buttonScript="doLogin()";
	var showCloseButton=false;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);
	
	showModalByBaseId(divBaseId);
	
	var action="fiil_login_box";
	var div_id=divBaseId+"Body";
	var par1="x";

	ajaxDynamicComponentCaller(action, div_id, par1);

}

//*********************************************************************
function showLoginError() {
	
	hideWaitingModal();
	
	hideModalByBaseId("loginBox");
	
	var divBaseId="loginError";
	var modalSize="md";
	var modalTitle="Login Failed!";
	var buttonTitle="OK";
	var buttonScript="hideModalByBaseId('loginError'); showLoginBox()";
	var showCloseButton=false;
	var initialContent="Invalid username or password";
	
	
	
	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);
	
	showModalByBaseId(divBaseId);
}

//---------------------------------------------------------------
function printMenu() {
	
	
	hideWaitingModal();
	
	var action="print_main_menu";
	var div_id="MenuDiv";
	var par1="x";

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}

//---------------------------------------------------------------
function makeModuleTree() {
	var eltreedivid="moduleTreeDiv";
	var el=document.getElementById(eltreedivid);
	if (!el) return;
	
	var action="make_module_tree";
	var div_id=eltreedivid;
	var par1="x";

	ajaxDynamicComponentCaller(action, div_id, par1)
}

//---------------------------------------------------------------
function logout() {
	
	bootbox.confirm("Logout?", function(result) {
		
		if(!result) return;

		
		var action="logout";
		var div_id="NONE";
		var par1="x";
		

		ajaxDynamicComponentCaller(action, div_id, par1);
		
		
	}); 



}

//---------------------------------------------------------------
function openModule(module) {
	var action="open_module";
	var div_id="MainDiv";
	var par1=module;

	ajaxDynamicComponentCaller(action, div_id, par1);
}

//---------------------------------------------------------------
function openCurrentModule() {
	openModule("CURRENT");
}

//---------------------------------------------------------------
function setUserDomain() {
	var domain_id=document.getElementById("domainCombo").value;
	
	
	var action="set_domain";
	var div_id="NONE";
	var par1=domain_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
}

//----------------------------------------------------------------
function expandTree(tree_id) {

	var level_of_tree=document.getElementById("level_of_tree_"+tree_id).value;

	var action="expand_tree";
	var div_id="div_of_tree_"+tree_id;
	var par1=tree_id;
	var par2=level_of_tree;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}

//----------------------------------------------------------------
function collapseTree(tree_id) {
	var level_of_tree=document.getElementById("level_of_tree_"+tree_id).value;

	var action="collapse_tree";
	var div_id="div_of_tree_"+tree_id;
	var par1=tree_id;
	var par2=level_of_tree;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}

//---------------------------------------------------------------
function redrawTree(tree_id) {
	
	var level_of_tree=document.getElementById("level_of_tree_"+tree_id).value;
	
	var action="redraw_tree";
	var div_id="div_of_tree_"+tree_id;
	var par1=tree_id;
	var par2=level_of_tree;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//----------------------------------------------------------------
function setActiveTree(tree_id) {
	var action="set_active_tree";
	var div_id="NONE";
	var par1=tree_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//---------------------------------------------------------------
function unligthTreeNode(tree_id) {
	var eldiv=document.getElementById("title_div_of_tree_"+tree_id);
	if (!eldiv) return;
	eldiv.style.backgroundColor = "initial";
}

//---------------------------------------------------------------
function ligthTreeNode(tree_id) {
	
	var eldiv=document.getElementById("title_div_of_tree_"+tree_id);
	if (!eldiv) return;
	eldiv.style.backgroundColor = "#f4e400";
	
	
}


//----------------------------------------------------------------
function showTreeContent(tree_id) {
	var action="show_tree_content";
	var div_id="moduleContentDiv";
	var par1=tree_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//----------------------------------------------------------------
function showActiveTreeContent() {
	var action="show_active_tree_content";
	var div_id="moduleContentDiv";
	var par1="x";

	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//----------------------------------------------------------------
function makeTreeToolBox(tree_id) {
	var action="make_tree_toolbox";
	var div_id="moduleTreeToolBoxDiv";
	var par1=tree_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//---------------------------------------------------------------
function addTreeNode(tree_id,tree_type,step_type) {
	addTreeNode(tree_id,tree_type,"");
}
//---------------------------------------------------------------
function addTreeNode(tree_id,tree_type,step_type) {

	var divBaseId="addTreeNode";
	var modalSize="lg";
	var modalTitle="Add new folder";
	if (tree_type=="element") modalTitle="Add new element";
	else if (tree_type=="step") modalTitle="Add new step";
	var buttonTitle="Add";
	var buttonScript="addTreeNodeDO()";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);

	var action="fiil_add_rename_tree_node_box";
	var div_id=divBaseId+"Body";
	var par1=tree_id;
	var par2="NEW";
	var par3=tree_type;
	var par4=step_type;

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}

//---------------------------------------------------------------
function addTreeNodeDO() {

	var parent_tree_id=document.getElementById("adding_parent_tree_id").value;
	var tree_node_title=document.getElementById("tree_node_title").value;
	var module_name=document.getElementById("adding_module_name").value;
	var tree_type=document.getElementById("adding_tree_type").value;
	
	var referenced_test_id="0";
	var elref=document.getElementById("calling_test_id");
	if (elref) referenced_test_id=elref.value;

	
	var activate_added_item="NO";
	if(document.getElementById("activate_added_item") && document.getElementById("activate_added_item").checked)
		activate_added_item="YES";
	
	if (tree_node_title=="") {
		myalert("title is empty!");
		return;
	}
	

	var divBaseId="addTreeNode";
	hideModalByBaseId(divBaseId);
	
	

	var action="add_tree_node_do";
	var div_id="NONE";
	var par1=parent_tree_id;
	var par2=tree_node_title;
	var par3=tree_type;
	var par4=referenced_test_id;
	var par5=activate_added_item;
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);

	
}

//---------------------------------------------------------------
function renameTreeNode(tree_id,tree_type) {

	var divBaseId="renameTreeNode";
	var modalSize="md";
	var modalTitle="Rename Tree Node";
	var buttonTitle="Rename";
	var buttonScript="renameTreeNodeDO()";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);

	var action="fiil_add_rename_tree_node_box";
	var div_id=divBaseId+"Body";
	var par1=tree_id;
	var par2="RENAME";
	var par3=tree_type;
	var par4="x";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}

//---------------------------------------------------------------
function renameTreeNodeDO() {

	var tree_id=document.getElementById("renaming_tree_id").value;
	var tree_node_title=document.getElementById("tree_node_title").value;
	var module_name=document.getElementById("renaming_module_name").value;

	
	if (tree_node_title=="") {
		myalert(module_name+" is empty");
		return;
	}
	
	
	
	var divBaseId="renameTreeNode";
	hideModalByBaseId(divBaseId);

	var action="rename_tree_node_do";
	var div_id="NONE";
	var par1=tree_id;
	var par2=tree_node_title;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);


}

//---------------------------------------------------------------
function removeTreeNode(tree_id) {
	bootbox.confirm("Sure to remove?", function(result) {
		
		if(!result) return;

		
		var action="remove_tree_node";
		var div_id="NONE";
		var par1=tree_id;

		ajaxDynamicComponentCaller(action, div_id, par1);
		
		
	}); 

		
}



//---------------------------------------------------------------
function checkoutTreeNode(tree_id) {

	var divBaseId="checkoutTreeNode";
	var modalSize="md";
	var modalTitle="Check-out Tree Node";
	var buttonTitle="Check out";
	var buttonScript="checkoutTreeNodeDO('"+tree_id+"')";
	var showCloseButton=true;
	var initialContent="Checking...";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);

	
	
	
	var action="check_out_node_controll";
	var div_id=divBaseId+"Body";
	var par1=tree_id;


	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//---------------------------------------------------------------
function checkoutTreeNodeDO(tree_id) {
		
	var el=document.getElementById("checkoutavailabilityresult");
	
	if (!el) {
		myalert("Controll is in progress. Hold on...");
		return;
	}
	
	if (el.value!="true") {
		myalert("Checkout is not available.");
		return;
	}

	
	var divBaseId="checkoutTreeNode";
	hideModalByBaseId(divBaseId);
	
	var action="checkout_tree_node";
	var div_id="NONE";
	var par1=tree_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
}

//---------------------------------------------------------------
function checkinTreeNode(tree_id) {

	var divBaseId="checkinTreeNode";
	var modalSize="md";
	var modalTitle="Check-in Tree Node";
	var buttonTitle="Check in";
	var buttonScript="checkinTreeNodeDO()";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);

	var action="fiil_checkin_tree_node_box";
	var div_id=divBaseId+"Body";
	var par1=tree_id;


	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//---------------------------------------------------------------
function checkinTreeNodeDO() {

	var tree_id=document.getElementById("checkin_tree_id").value;
	var checkin_note=document.getElementById("checkin_note").value;

	
	if (checkin_note=="") {
		myalert("Enter a check in note!");
		return;
	}
	
	
	
	var divBaseId="checkinTreeNode";
	hideModalByBaseId(divBaseId);

	var action="checkin_tree_node_do";
	var div_id="NONE";
	var par1=tree_id;
	var par2=checkin_note;

	ajaxDynamicComponentCaller(action, div_id, par1, par2);


}

//---------------------------------------------------------------
function showTreeCheckHistory(tree_id) {

	var divBaseId="checkTreeHistory";
	var modalSize="md";
	var modalTitle="Node History";
	var buttonTitle="";
	var buttonScript="";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);

	var action="fiil_tree_history_box";
	var div_id=divBaseId+"Body";
	var par1=tree_id;


	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//------------------------------------------------------------------------------
function copyTreeNode(tree_id) {
	var action="copy_tree_node";
	var div_id="NONE";
	var par1=tree_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
}

//------------------------------------------------------------------------------
function cutTreeNode(tree_id) {
	var action="cut_tree_node";
	var div_id="NONE";
	var par1=tree_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
}

//------------------------------------------------------------------------------
function pasteTreeNode(parent_tree_id) {
	var action="paste_tree_node";
	var div_id="NONE";
	var par1=parent_tree_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
}


//---------------------------------------------------------------
function setTreeOrder(tree_id,parent_tree_id,direction) {
	var action="reorder_tree_node";
	var div_id="NONE";
	var par1=tree_id;
	var par2=parent_tree_id;
	var par3=direction;
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//---------------------------------------------------------------
function cancelCheckinForTreeNode(tree_id) {
	bootbox.confirm("Sure to cancel checkout?", function(result) {
		
		if(!result) return;

		
		var action="cancel_check_in";
		var div_id="NONE";
		var par1=tree_id;

		ajaxDynamicComponentCaller(action, div_id, par1);
		
		
	}); 

		
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
function configSearchStrings() {
	 var el=document.getElementById("search_for_strings");
	 if (!el) return;
	 
	 var search_value=el.value;


 	var action="search_configuration";
	var div_id="colStringsBody";
	var par1=""+"strings";
	var par2=""+search_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	 
}

//**************************************************
function configSearchFlexFields() {
	 var el=document.getElementById("search_for_flexible_fields");
	 if (!el) return;
	 
	 var search_value=el.value;


 	var action="search_configuration";
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


 	var action="search_configuration";
	var div_id="colUsersBody";
	var par1=""+"users";
	var par2=""+search_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	 
}
//**************************************************
function makeLangList() {
	
	var action="make_lang_list";
	var div_id="colLangsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeDomainList() {
	
	var action="make_domain_list";
	var div_id="colDomainsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function saveLangField(el, lang_id) {
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
function deleteLang(lang_id) {
	
	bootbox.confirm("Are you sure to remove this language ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_lang";
		var div_id="NONE";
		var par1=""+lang_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}


//**************************************************
function addNewLang() {
	bootbox.prompt("Enter Language Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Language Name cannot be empty");
				  return;
			  }
			  
			    var action="add_lang";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
}


//**************************************************
function makeStringList() {
	
	var action="make_string_list";
	var div_id="colStringsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}




//**************************************************
function addNewString() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Language";
	var par2="lang_list";
	var par3="x";
	var par4="x";
	var par5="addNewStringDO('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//**************************************************
function addNewStringDO(lang) {
	bootbox.prompt("Enter String Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("String Name cannot be empty");
				  return;
			  }
			  
			    var action="add_string";
				var div_id="NONE";
				var par1=result;
				var par2=lang;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
	});
	
}

//**************************************************
function saveStringField(el, string_id) {
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
function deleteString(string_id) {
	
	bootbox.confirm("Are you sure to remove this string ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_string";
		var div_id="NONE";
		var par1=""+string_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
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


//**************************************************
function makeFlexFieldList() {
	
	var action="make_flex_field_list";
	var div_id="colFlexFieldsBody";
	var par1="x";	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeFlexFieldEditor(flex_field_id) {
	
	var action="make_flex_field_editor";
	var div_id="colFlexFieldContent_"+flex_field_id+"Body";
	var par1=flex_field_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function addNewFlexField() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Field Type";
	var par2="flex_field_type";
	var par3="x";
	var par4="x";
	var par5="addNewFlexFieldDO('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//**************************************************
function addNewFlexFieldDO(flex_field_type) {
	  
	bootbox.prompt("Enter Field Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Field Name cannot be empty");
				  return;
			  }
			  
			  var action="add_flexible_field";
			  var div_id="NONE";
			  var par1=flex_field_type;
			  var par2=result;
				
			  ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
	
		
}


//**************************************************
function saveFlexFieldByFieldID(fieldId, flex_field_id) {
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
function saveFlexField(el, flex_field_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_flex_field";
	var div_id="NONE";
	var par1=""+flex_field_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
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
//**************************************************
function deleteFlexField(flex_field_id) {
	
	bootbox.confirm("Are you sure to remove this field?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_flex_field";
		var div_id="NONE";
		var par1=""+flex_field_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
	
}

//**************************************************
function makePermissionList() {

	var action="make_permission_list";
	var div_id="colPermissionsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function addNewPermission() {
	
	bootbox.prompt("Enter permission name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("permission name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_permission";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
	
}

//**************************************************
function deletePermission(permission_id) {
	
	bootbox.confirm("Are you sure to remove this permission?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_permission";
		var div_id="NONE";
		var par1=""+permission_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}
//**************************************************
function savePermissionField(el, permission_id) {
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
function addRemovePermissionGroup(permission_id, action_and_id) {
	var action="add_remove_permission_group";
	var div_id="NONE";
	var par1=""+permission_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//**************************************************
function makeUserList() {
	
	var action="make_user_list";
	var div_id="colUsersBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeUserEditor(cuser_id) {
	
	var action="make_user_editor";
	var div_id="colUserContent_"+cuser_id+"Body";
	var par1=""+cuser_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function addNewUser() {
	
	bootbox.prompt("Enter username to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("username name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_user";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
	
}
//**************************************************
function saveUserField(el, user_id) {
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
function addRemoveUserMembership(user_id, action_and_id) {
	var action="add_remove_user_membership";
	var div_id="NONE";
	var par1=""+user_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}
//**************************************************
function deleteUser(user_id) {
	
	bootbox.confirm("Are you sure to remove this user?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_user";
		var div_id="NONE";
		var par1=""+user_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}
//**************************************************
function setUserPassword(user_id) {
	
	var divBaseId="setPassword";
	var modalSize="md";
	var modalTitle="Set Password";
	var buttonTitle="Set Password";
	var buttonScript="setUserPasswordDO()";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);
	
	var action="make_user_set_password";
	var div_id=divBaseId+"Body";
	var par1=user_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}
//**************************************************
function setUserPasswordDO() {
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
	
	var divBaseId="setPassword";
	hideModalByBaseId(divBaseId);
	
	var action="set_user_password";
	var div_id="NONE";
	var par1=""+user_id;	
	var par2=""+password_1;	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
	
}

//**************************************************
function makeGroupList() {
	
	var action="make_group_list";
	var div_id="colGroupsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeGroupEditor(group_id) {
	
	var action="make_group_editor";
	var div_id="colGroupContent_"+group_id+"Body";
	var par1=""+group_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}


//**************************************************
function addNewGroup() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Group Type";
	var par2="group_type";
	var par3="x";
	var par4="x";
	var par5="addNewGroupDO('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}
//**************************************************
function addNewGroupDO(group_type) {
	
	bootbox.prompt("Enter Group Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Group Name cannot be empty");
				  return;
			  }
			  
			    var action="add_group";
				var div_id="NONE";
				var par1=group_type;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
	
}

//**************************************************
function saveGroupField(el, group_id) {
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
function deleteGroup(group_id) {
	
	bootbox.confirm("Are you sure to remove this group?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_group";
		var div_id="NONE";
		var par1=""+group_id;	
		
		
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
//**************************************************
function addRemoveGroupPermission(group_id, action_and_id) {
	var action="add_remove_group_permission";
	var div_id="NONE";
	var par1=""+group_id;	
	var par2=""+action_and_id;
	
	
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//-------------------------------------------------------------------
function assignRoleToGroup(group_id,role_action) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Role";
	var par2="role";
	var par3="x";
	var par4="x";
	var par5="assignRoleToGroupDO('"+group_id+"','#','"+role_action+"')";
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}
//--------------------------------------------------------------------
function assignRoleToGroupDO(group_id, role_id,role_action) {

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
function makeEmailTemplateList() {
	
	var action="make_email_template_list";
	var div_id="colEmailTemplatesBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function addNewEmailTemplate() {
	bootbox.prompt("Enter Template Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Template name cannot be empty");
				  return;
			  }
			  
			    var action="add_email_template";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
	
}
//**************************************************
function saveEmailTemplateField(el, template_id) {
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
function deleteEmailTemplate(email_template_id) {
	
	bootbox.confirm("Are you sure to remove this template?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_email_template";
		var div_id="NONE";
		var par1=""+email_template_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}


//**************************************************
function makeDatabaseList() {
	
	var action="make_database_list";
	var div_id="colDatabasesBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeDatabaseEditor(database_id) {
	
	var action="make_database_editor";
	var div_id="colDatabaseContent_"+database_id+"Body";
	var par1=""+database_id;	
	
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

	
	var divBaseId="testConnection";
	var modalSize="md";
	var modalTitle="Test Connection";
	var buttonTitle="";
	var buttonScript="";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);
	
	var action="test_connection_by_db_id";
	var div_id=divBaseId+"Body";
	var par1=db_id;
	
	showModalByBaseId(divBaseId);
		
	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function makeMethodList() {
	
	var action="make_method_list";
	var div_id="colMethodsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeMethodEditor(method_id) {
	
	var action="make_method_editor";
	var div_id="colMethodContent_"+method_id+"Body";
	var par1=""+method_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function saveMethodField(el, method_id) {
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
function addNewMethod() {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Method Type";
	var par2="method_type";
	var par3="x";
	var par4="x";
	var par5="addNewMethodDO('#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}
//**************************************************
function addNewMethodDO(method_type) {
	bootbox.prompt("Enter method name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("method name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_method";
				var div_id="NONE";
				var par1=result;
				var par2=method_type;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
	});
}

//**************************************************
function deleteMethod(method_id) {
	
	bootbox.confirm("Are you sure to remove this method?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_method";
		var div_id="NONE";
		var par1=""+method_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}
//***************************************************
function makeMethodParameterEditor(method_id) {
	var action="make_method_parameter_editor";
	var div_id="parameterListForMethod_"+method_id;
	var par1=""+method_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}

//**************************************************
function makeFlowList() {
	
	var action="make_flow_list";
	var div_id="colFlowsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function makeFlowEditor(flow_id) {
	
	var action="make_flow_editor";
	var div_id="colFlowContent_"+flow_id+"Body";
	var par1=""+flow_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function addNewFlow() {
	
	bootbox.prompt("Enter flow name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("flow name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_flow";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
	
}


//*********************************************************************
function testMadMethod(method_id, action_method_id) {
	
	
	var divBaseId="testMethod";
	var modalSize="lg";
	var modalTitle="Test Method";
	var buttonTitle="Run";
	var buttonScript="executeMethod()";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);
	
	var action="test_method";
	var div_id=divBaseId+"Body";
	var par1=method_id;
	var par2=action_method_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
	
	
}


//**********************************************************************
function executeMethod() {
	
	
	showWaitingModal();
	
	var test_method_id=document.getElementById("test_method_id").value;
	var test_action_method_id=document.getElementById("test_action_method_id").value;
	var test_parameter_count=document.getElementById("test_parameter_count").value;
	
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
	
	var action="execute_method";
	var div_id="testMethodResultDiv";
	var par1=test_method_id;
	var par2=test_action_method_id;
	var par3=parameters;
	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**********************************************************************
function getLastExecuteMethodLogs () {
	
	hideWaitingModal();
	
	var action="get_last_execute_method_logs";
	var div_id="testMethodLogsDiv";
	var par1="x";

	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function saveFlowField(el, flow_id) {
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
function deleteFlow(flow_id) {
	
	bootbox.confirm("Are you sure to remove this flow?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_flow";
		var div_id="NONE";
		var par1=""+flow_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
});
	
	 
}

//**************************************************
function makeFlowStateList(flow_id) {
	
	var action="make_flow_state_list";
	var div_id="flow_state_list_div_"+flow_id;
	var par1=""+flow_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
}
//**************************************************
function makeFlowStateEditor(flow_id, state_id) {
	
	var action="make_flow_state_editor";
	var div_id="flow_state_editor_div_"+flow_id;
	var par1=""+flow_id;	
	var par2=""+state_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}
//**************************************************
function addNewFlowState(flow_id) {
	
	bootbox.prompt("Enter state name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("state name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_flow_state";
				var div_id="NONE";
				var par1=""+flow_id;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
	});
	
}
//**************************************************
function deleteFlowState(flow_id, flow_state_id) {
	
	bootbox.confirm("Are you sure to remove this state?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_flow_state";
		var div_id="NONE";
		var par1=""+flow_id;
		var par2=""+flow_state_id;
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
}

//**************************************************
function saveFlowStateField(el, state_id) {
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
function addRemoveStateEditPermission(flow_state_id, action_and_id) {
	var action="add_remove_state_edit_permission";
	var div_id="NONE";
	var par1=""+flow_state_id;	
	var par2=""+action_and_id;
		
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}
//**************************************************
function makeFlowStateActionList(flow_state_id) {
	
	var action="make_flow_state_action_list";
	var div_id="colFlowStateActions_"+flow_state_id+"Body";
	var par1=""+flow_state_id;	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function addNewFlowStateAction(flow_state_id) {
	
	bootbox.prompt("Enter action name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("action name cannot be empty");
				  return;
			  }
			  
			  	var action="add_new_flow_state_action";
				var div_id="NONE";
				
				var par1=flow_state_id;
				var par2=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1, par2);
				
	});
	
	
}


//**************************************************
function deleteFlowStateAction(flow_state_id, action_id) {
	
	bootbox.confirm("Are you sure to remove this action?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_flow_state_action";
		var div_id="NONE";
		var par1=""+action_id;	
		var par2=""+flow_state_id;
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
});
	
	 
}


//**************************************************
function saveFlowStateActionField(el, action_id) {
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
function addRemoveActionPermission(action_id, action_and_id) {
	var action="add_remove_action_permission";
	var div_id="NONE";
	var par1=""+action_id;	
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
function addNewActionMethod(action_id) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Method to execute";
	var par2="method";
	var par3="x";
	var par4="x";
	var par5="addNewActionMethodDO('"+action_id+"','#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}

//**************************************************
function addNewActionMethodDO(action_id, method_id) {
	
	var action="add_new_mad_action_method";
	var div_id="NONE";
	var par1=action_id;
	var par2=method_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
}

//*************************************************
function makeMadActionMethodList(action_id) {
	var action="make_flow_state_action_method_list";
	var div_id="methodsToExecuteDivForAction_"+action_id;
	var par1=action_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}
//**************************************************
function reorderFlowStateActionMethod(action_id, execution_order, direction) {
	
	var action="reorder_flow_state_action_method";
	var div_id="NONE";
	var par1=action_id;
	var par2=execution_order;
	var par3=direction;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}
//*************************************************
function makeActionMethodList(action_id) {
	var action="make_flow_state_action_method_list";
	var div_id="methodsToExecuteDivForAction_"+action_id;
	var par1=action_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}
//**************************************************
function removeFlowStateActionMethod(action_id, action_method_id) {
	
	bootbox.confirm("Are you sure to remove this method from execution list?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="delete_flow_state_action_method";
		var div_id="NONE";
		var par1=""+action_id;	
		var par2=""+action_method_id;
		
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2);
	});
	
	 
}

//**************************************************
function setFlowStateActionMethodParameters(action_method_id) {
	
	var divBaseId="flowStateModalParam";
	var modalSize="lg";
	var modalTitle="Method parameters";
	var buttonTitle="";
	var buttonScript="";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);
	
	var action="make_flow_state_action_method_parameter_editor";
	var div_id=divBaseId+"Body";
	var par1=""+action_method_id;	
	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}
//**************************************************
function saveFlowStateActionMethodField(el, action_method_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_action_method_field";
	var div_id="NONE";
	var par1=""+action_method_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//*******************************************************************************
function duplicateFlow(flow_id ) {
	bootbox.confirm("Are you sure to duplicate ?", function(result) {
		
		if(!result) {
			return;
		}
		
		var action="duplicate_flow";
		var div_id="NONE";
		var par1=""+flow_id;	
		
		
		ajaxDynamicComponentCaller(action, div_id, par1);
	});
}


//---------------------------------------------------------------
function showTestParameter(test_id) {

	var divBaseId="showTestParameter";
	var modalSize="lg";
	var modalTitle="Edit Test Parameters";
	var buttonTitle="";
	var buttonScript="";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);

	var action="fiil_set_test_parameters_box";
	var div_id=divBaseId+"Body";
	var par1=test_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}




//---------------------------------------------------------------
function makeFlexFormContentXML(main_tree_id) {
	var field_name="fields_of_tree_"+main_tree_id;
	
	var ret1="";
	
	var elArr=document.getElementsByName(field_name);
	
	
	// COMPILING FLEX FORM VALUES
	if (elArr) {
		
		
		for(var x=0;x<elArr.length;x++){
		    var el=elArr[x];
		    
		    var id=el.id;
		    var tree_id="";
		    var flex_field_id="";
		    
		    try{ tree_id=id.split("_")[0];} catch(err) {console.log("error@element_id");}
		    try{ flex_field_id=id.split("_")[1];} catch(err) {console.log("error@flex_field_id");}

		    if (tree_id=="") continue;
		    
		    ret1=ret1+"<flexField><tree_id>"+tree_id+"</tree_id><flexField_id>"+flex_field_id+"</flexField_id><flexField_value>"+el.value+"</flexField_value></flexField><dataType>F</dataType>\n";
		} 
	}
	
	
	field_name="parameters_of_tree_"+main_tree_id;
	elArr=document.getElementsByName(field_name);
	
	// COMPILING PARAMETER VALUES
	
	if (elArr) {
		for(var x=0;x<elArr.length;x++){
		    var el=elArr[x];
		    
		    var id=el.id;
		    var tree_id="";
		    var flex_field_id="";
		    
		    try{ tree_id=id.split("_")[0];} catch(err) {console.log("error@element_id");}
		    try{ flex_field_id=id.split("_")[1];} catch(err) {console.log("error@flex_field_id");}

		    if (tree_id=="") continue;
		    
		    ret1=ret1+"<flexField><tree_id>"+tree_id+"</tree_id><flexField_id>"+flex_field_id+"</flexField_id><flexField_value>"+el.value+"</flexField_value></flexField><dataType>P</dataType>\n";
		} 
	}
	
	
	ret1="<treeData>\n"+ret1+"</treeData>";

	return ret1;
}
//---------------------------------------------------------------
function saveTreeNode(tree_id) {

	var flexFormContent=makeFlexFormContentXML(tree_id);
	
	//myalert("<textarea>"+flexFormContent+"</textarea>");
	
	
	var action="save_tree_node";
	var div_id="NONE";
	var par1=tree_id;
	var par2=encrypt(flexFormContent);
	
	showWaitingModal();
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}


//---------------------------------------------------------------
function showTestParameter(test_id) {

	var divBaseId="showTestParameter";
	var modalSize="lg";
	var modalTitle="Edit Test Parameters";
	var buttonTitle="";
	var buttonScript="";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);

	var action="fiil_set_test_parameters_box";
	var div_id=divBaseId+"Body";
	var par1=test_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}

//---------------------------------------------------------------
function addTestParameter(direction) {

	var test_id=document.getElementById("test_parameter_tree_id").value;


	var action="add_test_parameter";
	var div_id="NONE";
	var par1=test_id;
	var par2=direction;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}

//---------------------------------------------------------------
function removeTestParameter (parameter_id) {
	bootbox.confirm("Sure to remove?", function(result) {
		
		if(!result) return;

		var test_id=document.getElementById("test_parameter_tree_id").value;

		
		var action="remove_test_parameter";
		var div_id="NONE";
		var par1=test_id;
		var par2=parameter_id;

		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		
		
	}); 

		
}

//**************************************************
function saveTestParameterField(el, parameter_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	
	var action="update_test_parameter_field";
	var div_id="NONE";
	var par1=""+parameter_id;	
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//**************************************************
function makeFormList() {
	var action="make_form_list";
	var div_id="colFormsBody";
	var par1="x";	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function setFormFieldsFilter() {
	
	var module=document.getElementById("form_module").value;
	var domain=document.getElementById("form_domain").value;
	var tree_type=document.getElementById("form_tree_type").value;
	var field=document.getElementById("form_field").value;
	
	var action="set_form_fields_filter";
	var div_id="NONE";
	var par1=module;	
	var par2=domain;	
	var par3=tree_type;	
	var par4=field;	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}

//**************************************************
function listFormFields() {
	var action="list_form_fields";
	var div_id="formFieldListDiv";
	var par1="x";	
	
	
	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function addNewFormField() {
	
	var divBaseId="newFormField";
	var modalSize="md";
	var modalTitle="Add New Form Field";
	var buttonTitle="Add";
	var buttonScript="addNewFormFieldDO()";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);
	
	var action="make_add_new_form_field_form";
	var div_id=divBaseId+"Body";
	var par1="x";

	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}

//**************************************************
function closeAddNewFieldModal() {
	var divBaseId="newFormField";
	hideModalByBaseId(divBaseId);
}


//**************************************************
function addNewFormFieldDO(flex_field_id) {
	
	
	var module=document.getElementById("new_field_module").value;
	var domain=document.getElementById("new_field_domain").value;
	var tree_type=document.getElementById("new_field_tree_type").value;
	var field=document.getElementById("new_field_field").value;
	
	if (module=="") {
		myalert("Module is mandatory.");
		return;
	}
	
	if (domain=="") {
		myalert("Domain is mandatory.");
		return;
	}
	
	if (tree_type=="") {
		myalert("Level is mandatory.");
		return;
	}
	
	if (field=="") {
		myalert("Field is mandatory.");
		return;
	}
	
	var action="add_new_form_field";
	var div_id="NONE";
	var par1=module;	
	var par2=domain;	
	var par3=tree_type;	
	var par4=field;	
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
	
}
//---------------------------------------------------------------
function removeFormField(form_field_id) {
	bootbox.confirm("Sure to remove?", function(result) {
		
		if(!result) return;

		var action="remove_form_field";
		var div_id="NONE";
		var par1=form_field_id;

		ajaxDynamicComponentCaller(action, div_id, par1);
		
		
	}); 

		
}

//---------------------------------------------------------------
function setFormFieldOrder(form_field_id,group_values,direction) {
	var action="reorder_form_field";
	var div_id="NONE";
	var par1=form_field_id;
	var par2=group_values;
	var par3=direction;
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
}

//---------------------------------------------------------------
function openTreeNodePicker(tree_picker_field_id) {
	
	var divBaseId="treeNodePicker";
	var modalSize="lg";
	var modalTitle="Node Picker";
	var buttonTitle="Select";
	var buttonScript="openTreeNodePickerDO('"+tree_picker_field_id+"')";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);
	
	var module=document.getElementById("MODULE_OF_"+tree_picker_field_id).value;
	var domain=document.getElementById("DOMAIN_OF_"+tree_picker_field_id).value;
	var curr_id=document.getElementById(tree_picker_field_id).value;
	
	var action="make_tree_picker_window";
	var div_id=divBaseId+"Body";
	var par1=module;
	var par2=domain;
	var par3=tree_picker_field_id;
	var par4=curr_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
}

//---------------------------------------------------------------
function clickedPickerTreeElement(tree_picker_field_id,picked_node_id) {
	document.getElementById("CLICKED_OF_"+tree_picker_field_id).value=picked_node_id;
}
//---------------------------------------------------------------
function openTreeNodePickerDO(tree_picker_field_id) {
	
	var picked_node_id=document.getElementById("CLICKED_OF_"+tree_picker_field_id).value;
	
	if (picked_node_id=="0") {
		myalert("Pick an element to proceed.");
		return;
	}
	
	document.getElementById(tree_picker_field_id).value=picked_node_id;
	
	var divBaseId="treeNodePicker";
	hideModalByBaseId(divBaseId);
	
	var action="make_tree_node_picker_area";
	var div_id="TREE_PICKER_DIV_"+tree_picker_field_id;
	var par1=tree_picker_field_id;
	var par2=picked_node_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}
//---------------------------------------------------------------
function expandcollapsePickerTreeContainer(tree_picker_field_id, clicked_node_id) {
	
	var child_div_id="child_of_node_"+clicked_node_id;
	var div_content=document.getElementById(child_div_id).innerHTML;
	var is_expanded=false;
	if (div_content.length>10)  is_expanded=true;
	

	if (is_expanded) {
		clearDivContent(child_div_id);
		
		var action="collapse_tree_picker_node";
		var div_id="NONE";
		var par1=module;
		var par2=domain;
		var par3=tree_picker_field_id;
		var par4=clicked_node_id;
		
		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4);
		
		return;
	}
	
	var module=document.getElementById("MODULE_OF_"+tree_picker_field_id).value;
	var domain=document.getElementById("DOMAIN_OF_"+tree_picker_field_id).value;
	var curr_id=document.getElementById(tree_picker_field_id).value;
	
	
	var action="expand_tree_picker_node";
	var div_id=child_div_id;
	var par1=module;
	var par2=domain;
	var par3=tree_picker_field_id;
	var par4=curr_id;
	var par5=clicked_node_id;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	
	
}

//---------------------------------------------------------------
function listPickerElements(tree_picker_field_id, clicked_container_id) {
	
	var module=document.getElementById("MODULE_OF_"+tree_picker_field_id).value;
	var domain=document.getElementById("DOMAIN_OF_"+tree_picker_field_id).value;
	var text_to_search=document.getElementById("text_to_search_picker_for_"+tree_picker_field_id).value;
	
	if (clicked_container_id=="") 
		clicked_container_id=document.getElementById("CLICKED_CONTAINER_OF_"+tree_picker_field_id).value;
	else 
		document.getElementById("CLICKED_CONTAINER_OF_"+tree_picker_field_id).value=clicked_container_id;
	
	
	var is_checked=document.getElementById("include_sub_folders_for_"+tree_picker_field_id).checked;
	var include_sub_tree="NO";
	if (is_checked) include_sub_tree="YES";

	var action="list_picker_elements";
	var div_id="treeNodePickerElementListDiv";
	var par1=module;
	var par2=domain;
	var par3=tree_picker_field_id;
	var par4=clicked_container_id;
	var par5=include_sub_tree+":"+encrypt(text_to_search);
	

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
}

//---------------------------------------------------------------
function linkTreeNode(tree_id, linked_module, linked_node_id) {

	var divBaseId="linkTreeNode";
	var modalSize="lg";
	var modalTitle="Link";
	var buttonTitle="Set Link";
	var buttonScript="linkTreeNodeDO('"+tree_id+"')";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);

	var action="fiil_link_tree_node_box";
	var div_id=divBaseId+"Body";
	var par1=tree_id;
	var par2=linked_module;
	var par3=linked_node_id;


	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

//---------------------------------------------------------------
function linkTreeNodeDO(tree_id) {
	
	var linked_tree_id=document.getElementById("linking_node_id").value;
	var module=document.getElementById("MODULE_OF_linking_node_id").value;
	
	var action="link_tree_node";
	var div_id="NONE";
	var par1=tree_id;
	var par2=module;
	var par3=linked_tree_id;

	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
	var divBaseId="linkTreeNode";
	hideModalByBaseId(divBaseId);
}

//------------------------------------------------------------------------
function setActiveTestDetailsTabId(active_id) {
	var action="set_active_test_details_tab_id";
	var div_id="NONE";
	var par1=active_id;

	ajaxDynamicComponentCaller(action, div_id, par1);
}


//---------------------------------------------------------------
function unlinkTreeNode(node_id, module, linked_node_id) {
	bootbox.confirm("Sure to remove the link?", function(result) {
		
		if(!result) return;

		var action="unlink_tree_node";
		var div_id="NONE";
		var par1=node_id;
		var par2=module;
		var par3=linked_node_id;

		ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
		
		
	}); 

		
}


//------------------------------------------------------------------------
function makeTreeContentLinkList(node_id, module) {
	
	var action="make_tree_content_link_list";
	var div_id=module+"_details_for_"+node_id;
	var par1=node_id;
	var par2=module;


	ajaxDynamicComponentCaller(action, div_id, par1, par2);
}

//---------------------------------------------------------------
function listDependingNodes(tree_id_INT) {

	var tree_id=""+tree_id_INT;
	
	var divBaseId="dependingTreeNodeList";
	var modalSize="md";
	var modalTitle="Depending Tree Nodes for ["+tree_id+"]";
	var buttonTitle="Check out";
	var buttonScript="";
	var showCloseButton=true;
	var initialContent="";

	makeModal(divBaseId,modalSize,modalTitle,buttonTitle,buttonScript,showCloseButton,initialContent);

	showModalByBaseId(divBaseId);

	
	
	
	var action="make_depending_tree_nodes_list";
	var div_id=divBaseId+"Body";
	var par1=tree_id;


	ajaxDynamicComponentCaller(action, div_id, par1);
	
}

//**************************************************
function addNewOrganizationGroup(tree_id) {
	var action="show_lov_dialog";
	var div_id="lovBody";
	var par1="Group to add";
	var par2="group";
	var par3="x";
	var par4="x";
	var par5="addNewOrganizationGroupDO('"+tree_id+"','#')";
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3, par4, par5);
	
	showModal("lovDiv");
}


//**************************************************
function addNewOrganizationGroupDO(tree_id, group_id) {

	var action="add_new_organization_group";
	var div_id="NONE";
	var par1=tree_id;
	var par2=group_id;


	ajaxDynamicComponentCaller(action, div_id, par1, par2);
	
	
}

//**************************************************
function makeOrganizationGroupList(tree_id) {

	var action="make_organization_group_list";
	var div_id="OrganizationGroupDivFor_"+tree_id;
	var par1=tree_id;


	ajaxDynamicComponentCaller(action, div_id, par1);
	
	
}

//---------------------------------------------------------------
function removeOrganizationGroup(tree_id, group_id) {
	bootbox.confirm("Sure to remove the group?", function(result) {
		
		if(!result) return;

		var action="remove_organization_group";
		var div_id="NONE";
		var par1=tree_id;
		var par2=group_id;

		ajaxDynamicComponentCaller(action, div_id, par1, par2);
		
		
	}); 

		
}

//**************************************************
function addNewDomain() {
	bootbox.prompt("Enter Domain Name to add ", function(result) {                
		  if (result === null) return;
			  
			  if (result.length==0) {
				  myalert("Domain Name cannot be empty");
				  return;
			  }
			  
			    var action="add_new_domain";
				var div_id="NONE";
				var par1=result;
				
				ajaxDynamicComponentCaller(action, div_id, par1);
				
	});
}




//**************************************************
function saveDomainField(el, domain_id) {
	var field_name=el.getAttribute('id');
	var field_value=el.value;
	
	var action="update_domain_field";
	var div_id="NONE";
	var par1=""+domain_id;
	var par2=field_name;
	var par3=field_value;
	
	ajaxDynamicComponentCaller(action, div_id, par1, par2, par3);
	
}

