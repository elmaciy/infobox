

//*************************************************************************
function set_as_title(){
//*************************************************************************
	document.getElementById("setastitle").value="setastitle";
	document.fmain.submit();
}

//*************************************************************************
function savetitles(){
//*************************************************************************
var i=0;
var fid="";
var el=null;
var ret1="";
	while(true) {
		fid="ftitle_"+i;
		el=document.getElementById(fid);
		if (el==null) break;
		
		
		if (i>0) ret1=ret1+"|::|";
		ret1=ret1+el.value;
		i=i+1;
	}
	
	document.getElementById("field_titles").value=ret1;
	document.fmain.submit();

}


//*************************************************************************
function downloadlist(){
//*************************************************************************
	var listid="";
	listid=document.getElementById("listList").value;

	var url="downloadlist.jsp?listid="+listid;
	window.open (url,"mywindow");
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


var AJAX = createXMLHttpRequest();


//*************************************************************************
function handler() {
//*************************************************************************
document.getElementById('blockerDiv').style.display="none";

  if(AJAX.readyState == 4 && AJAX.status == 200) {
	  
      var json = eval('(' + AJAX.responseText +')');
      var CURRdivid=json.divid;
      
      document.getElementById(CURRdivid).innerHTML=json.html;
      document.getElementById(CURRdivid).style.display="block";
      
      
  }else if (AJAX.readyState == 4 && AJAX.status != 200) {
    alert('Something went wrong on ajax call...');
  }
}



//*************************************************************************
function ajax_update(action,par1,par2,par3){
//*************************************************************************	
  document.getElementById('blockerDiv').style.display="block";
  AJAX.onreadystatechange = handler_ajaxupdater;
  AJAX.open("GET", "ajaxupdater.jsp?action=" + action + "&par1=" + par1 + "&par2=" + par2 + "&par3="+par3);
  AJAX.send("");
};



//*************************************************************************
function handler_ajaxupdater() {
//*************************************************************************
document.getElementById('blockerDiv').style.display="none";

  if(AJAX.readyState == 4 && AJAX.status == 200) {
	  
      var json = eval('(' + AJAX.responseText +')');
      var msg=json.msg;
      
      
      if (msg.indexOf("refresh_form")>-1) document.fmain.submit();
      else alert("ok");
      
      
  }else if (AJAX.readyState == 4 && AJAX.status != 200) {
    alert('Something went wrong on ajax call...');
  }
}


//*************************************************************************
function showsamplejs(){
//*************************************************************************

	document.getElementById('js_code').value="function calcul()\n"+
											 "{\n"+
											 "return \"${1}\";\n"+
											 "}\n\n"+
											 "var a=\"\";\n"+
											 "a=calcul();\n";
}
	
//*************************************************************************
function testjs_code(){
//*************************************************************************
	
 var msg1='';
 var jsscript=document.getElementById('js_code').value;
 var par=document.getElementById('testval').value;
 
 var parList = par.split(",");
 alert(parList.length);
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
 } catch (e) {
	        msg1=msg1+'<br>Error : <b><font color=red>'+e.message+'</font></b>';
	}
 
 msg1=msg1+"<br>"+'Returns : [<font color=red><b>'+ ret1 +'</b></font>]';
 document.getElementById("jsret").innerHTML=msg1;
  
};



//*************************************************************************
function showcontenbytabid(filter_tab_id){
//*************************************************************************
	var envid="";
	var reccnt="100";
	var filter="";

	envid=document.getElementById("envList").value;
	
	showtable(envid,filter_tab_id,"",reccnt,filter);
}

//*************************************************************************
function showcontent(tabList){
//*************************************************************************
var envid="";
var tabid="";
var tabname="";
var reccnt="100";
var filter="";

envid=document.getElementById("envList").value;

if(tabList.name=="tableList") {
	tabname=tabList.value.replace("*",".");
	
	tabid="";
	
}
else {
	tabname="";
	tabid=tabList.value;
	
}


showtable(envid,tabid,tabname,reccnt,filter);
};


//*************************************************************************
function showtable(envid,tabid,tabname,reccnt,filter){
//*************************************************************************
	var url="showtablecontent.jsp?envid="+envid+"&reccnt=" + reccnt + "&tabid=" + tabid+ "&tabname=" + tabname + "&filter=x";
	window.open (url,"mywindow");
};

//*************************************************************************
function showlongdet(id,tab,fld,env_id){
//*************************************************************************
  var url="showlongdet.jsp?&id=" + id + "&tab=" + tab + "&fld="+fld+"&env_id="+env_id;
  window.open (url,"mywindow");
};



//*************************************************************************
function sampleformulas() {
//*************************************************************************
	alert("  cust_id\n  round(cust_id/10)\n  ascii(substr(nvl('D','x'),1,1))");
}


//*************************************************************************
function removetable(filter_tab_id) {
//*************************************************************************
	if (!confirm('sure to remove this table from design list?')) return;
	document.getElementById("filter_tab_id").value=filter_tab_id;
	savetabinfo('REMOVE_TABLE');
}


//*************************************************************************
function savetabinfo(action) {
//*************************************************************************

	document.getElementById("tableAction").value=action;
	
	if(action=='ADD_TABLE') {
		var elt1 = document.getElementById("tableList");
		if(elt1.selectedIndex==-1) {
			alert('Should pick a table to add');
			return;
		}
		

		var table_name=elt1.value;
				
		document.getElementById("tableActionObject").value=table_name;

	}
	

	if(action=='REMOVE_TABLE') {
		var elt2 = document.getElementById("filter_tab_id");
		if(elt2.selectedIndex==-1) {
			alert('Should pick a table to remove');
			return;
		}
		
		var tab_id=elt2.value;
	
		document.getElementById("tableActionObject").value=tab_id;

	}
	
	if(action=='ADD_MISSING_FIELDS') {

		var table_id_to_add = document.getElementById("filter_tab_id").value;
		var  fields_to_add = document.getElementById("fields_to_add").value;

	
		
		document.getElementById("tableActionObject").value=table_id_to_add;
		document.getElementById("tableActionObjectReference").value=fields_to_add;
		
	}	
	
	if(action=='DELETE_FIELD') {
		var table_id_to_add = document.getElementById("filter_tab_id").value;
		var  field_to_delete = document.getElementById("field_to_delete").value;
		
		if (!confirm('Are you sure to delete this field ['+ field_to_delete +'] ? ')) return;
	
		document.getElementById("tableActionObject").value=table_id_to_add;
		document.getElementById("tableActionObjectReference").value=field_to_delete;
		
	}	
	
	if(action=='CHANGE_MASK_LEVEL') {
		var table_id_to_change = document.getElementById("filter_tab_id").value;
		var new_mask_level=document.getElementById("mask_level").value;

		document.getElementById("tableActionObject").value=table_id_to_change;
		document.getElementById("tableActionObjectReference").value=new_mask_level;
		
	}	

	document.fmain.submit();

}



//*************************************************************************
function changeField(changetype,field_id,obj,newval2) {
//*************************************************************************
var newval=obj.value;

if (changetype=="is_conditional") {
	newval="NO";
	if (obj.checked) newval="YES";
}

if (changetype=="mask_prof_id") {
	newval=obj.options[obj.selectedIndex].value;
}

if (changetype=="is_pk") {
	if (newval2=='YES') newval='NO';
	if (newval2=='NO') newval='YES';
	if (!confirm("Are you sure to set/unset this field's Primary Key statys?")) return;
}

ajax_update(changetype,field_id,newval,newval2);

}

var envAction='';
var envName='';
var envDriver='';
var envConnstr='';
var envUsername='';
var evnPassword='';



//*************************************************************************
function envbox(act) {
//*************************************************************************
envAction=act;
envName='';
envDriver='';
envConnstr='';
envUsername='';
evPassword='';

if (act=='NEW') 
{
envName='New Environment';
}
else
{
	var elt = document.getElementById("envList");
	envName=elt.options[elt.selectedIndex].text;

	envDriver=document.getElementById("envDriver").value;
	envConnstr=document.getElementById("envConnstr").value;
	envUsername=document.getElementById("envUsername").value;
	envPassword=document.getElementById("envPassword").value;
}

if (act=='EDIT')  if (envName=='') return;
if (act=='DELETE')  if (envName=='') return;

document.getElementById('envEditor').style.display="block";

document.getElementById('editEnvName').value=envName;

document.getElementById('editEnvDriver').value=envDriver;
document.getElementById('editEnvConnstr').value=envConnstr;
document.getElementById('editEnvUsername').value=envUsername;
document.getElementById('editEnvPassword').value=envPassword;

document.getElementById('editEnvName').focus();

}



//*************************************************************************
function envsave() {
//*************************************************************************
envName=document.getElementById('editEnvName').value;

envDriver=document.getElementById('editEnvDriver').value;
envConnstr=document.getElementById('editEnvConnstr').value;
envUsername=document.getElementById('editEnvUsername').value;
envPassword=document.getElementById('editEnvPassword').value;

document.getElementById('envEditor').style.display="none";


document.getElementById('envAction').value=envAction;
document.getElementById('envName').value=envName;

document.getElementById('envDriver').value=envDriver;
document.getElementById('envConnstr').value=envConnstr;
document.getElementById('envUsername').value=envUsername;
document.getElementById('envPassword').value=envPassword;

document.fmain.submit();

}

//*************************************************************************
function envcancel() {
//*************************************************************************
document.getElementById('envEditor').style.display="none";
}



//*************************************************************************
function changerule() {
//*************************************************************************
document.getElementById("submitSource").value="RULECHANGE";
document.fmain.submit();
}



var profileAction='';
var profileName='';

//*************************************************************************
function profilebox(act) {
//*************************************************************************
profileAction=act;
profileName='New Mask Profile';

if (act=='NEW') {
	profileName='New Mask Profile';
}
else
{
	var elt = document.getElementById("profileList");
	profileName=elt.options[elt.selectedIndex].text;
}

if (act=='EDIT')  if (profileName=='') return;
if (act=='DELETE')  if (profileName=='') return;

document.getElementById('profileEditor').style.display="block";

var editbox=document.getElementById('profileEditName');
editbox.value=profileName;
editbox.focus();

}



//*************************************************************************
function profilesave() {
//*************************************************************************
profileName=document.getElementById('profileEditName').value;

document.getElementById('profileEditor').style.display="none";


document.getElementById('profileAction').value=profileAction;
document.getElementById('profileName').value=profileName;

document.fmain.submit();

}

//*************************************************************************
function profilecancel() {
//*************************************************************************
document.getElementById('profileEditor').style.display="none";
}


var listAction='';
var listName='';

//*************************************************************************
function listbox(act) {
//*************************************************************************
listAction=act;
listName='New Table';

if (act=='NEW') {
	listName='New Table';
}
else
{
	var elt = document.getElementById("listList");
	listName=elt.options[elt.selectedIndex].text;
}

if (act=='EDIT')  if (listName=='') return;
if (act=='DELETE')  if (listName=='') return;

document.getElementById('listEditor').style.display="block";

var editbox=document.getElementById('listEditName');
editbox.value=listName;
editbox.focus();

}



//*************************************************************************
function opentab(filter_tab_id) {
//*************************************************************************
	document.getElementById('filter_tab_id').value=filter_tab_id;
	document.fmain.submit();
}


//*************************************************************************
function listsave() {
//*************************************************************************
listName=document.getElementById('listEditName').value;

document.getElementById('listEditor').style.display="none";


document.getElementById('listAction').value=listAction;
document.getElementById('listName').value=listName;

document.fmain.submit();

}


//*************************************************************************
function listcancel() {
//*************************************************************************
document.getElementById('listEditor').style.display="none";
}

var tabAction='';
var tabName='';



//*************************************************************************
function tabbox(act) {
//*************************************************************************
tabAction=act;
tabName='New Table';
if (act!='NEW') {
	var elt = document.getElementById("filter_tab_id");
	tabName=elt.options[elt.selectedIndex].text;
}

if (act=='EDIT')  if (tabName=='') return;

document.getElementById('tabEditor').style.display="block";

var editbox=document.getElementById('editTableName');
editbox.value=tabName;
editbox.focus();

}



//*************************************************************************
function tabsave() {
//*************************************************************************
tabName=document.getElementById('editTableName').value;

document.getElementById('tabEditor').style.display="none";


document.getElementById('tabAction').value=tabAction;
document.getElementById('tabName').value=tabName;

document.fmain.submit();

}




//*************************************************************************
function tabcancel() {
//*************************************************************************
document.getElementById('tabEditor').style.display="none";
}




var schemaAction='';
var schemaName='';

//*************************************************************************
function schemabox(act) {
//*************************************************************************
schemaAction=act;
schemaName='New Schema';
if (act!='NEW') {
	var elt = document.getElementById("filter_schema_id");
	schemaName=elt.options[elt.selectedIndex].text;
}

if (act=='EDIT')  if (schemaName=='') return;

document.getElementById('schemaEditor').style.display="block";

var editbox=document.getElementById('editSchemaName');
editbox.value=schemaName;
editbox.focus();

}

//*************************************************************************
function schemasave() {
//*************************************************************************
schemaName=document.getElementById('editSchemaName').value;

document.getElementById('schemaEditor').style.display="none";


document.getElementById('schemaAction').value=schemaAction;
document.getElementById('schemaName').value=schemaName;

document.fmain.submit();

}






var appId='';
var appAction='';
var appName='';

//*************************************************************************
function appbox(id,act) {
//*************************************************************************
appId=id;
appAction=act;
appName='New Application';
if (act!='NEW') {
	var elt = document.getElementById("filter_app_id");
	appName=elt.options[elt.selectedIndex].text;
}

document.getElementById('appEditor').style.display="block";

var editbox=document.getElementById('editAppName');
editbox.value=appName;
editbox.focus();

}



//*************************************************************************
function appsave() {
//*************************************************************************
appName=document.getElementById('editAppName').value;

document.getElementById('appEditor').style.display="none";


document.getElementById('appId').value=appId;
document.getElementById('appAction').value=appAction;
document.getElementById('appName').value=appName;

document.fmain.submit();

}


//*************************************************************************
function appcancel() {
//*************************************************************************
document.getElementById('appEditor').style.display="none";
}



//*************************************************************************
function ajax_script_update(app_id, script_type, a_script){
//*************************************************************************
  document.getElementById('blockerDiv').style.display="block";
  AJAX.onreadystatechange = handler_ajaxscriptupdater;
  AJAX.open("POST", "ajaxscriptupdater.jsp?script_type=" + script_type+ "&script=" + escape(a_script)+ "&app_id=" + app_id);
  AJAX.send("");
};



//*************************************************************************
function handler_ajaxscriptupdater() {
//*************************************************************************
document.getElementById('blockerDiv').style.display="none";

  if(AJAX.readyState == 4 && AJAX.status == 200) {
	  
      var json = eval('(' + AJAX.responseText +')');

     //alert(msg);
      alert("ok");
      
      
  }else if (AJAX.readyState == 4 && AJAX.status != 200) {
    alert('Something went wrong on ajax call...');
  }
}





var prep_script="prep scrp";
var post_script="post scrpt";
var scriptType="";


//*************************************************************************
function scriptedit(id,script_type) {
//*************************************************************************
appId=id;
scriptType=script_type;


var url="scripteditor.jsp?appid="+id+"&scriptname="+script_type;
window.open(url,"newWindow");


}

//*************************************************************************
function scriptsave() {
//*************************************************************************

document.getElementById('scriptEditor').style.display="none";

var a_script="";

if (scriptType=="PREP_TASKS") var a_script=document.getElementById('scriptPrepMemo').value;
if (scriptType=="POST_TASKS") var a_script=document.getElementById('scriptPostMemo').value;

ajax_script_update(appId, scriptType, a_script);


}


//*************************************************************************
function scriptcancel() {
//*************************************************************************
document.getElementById('scriptEditor').style.display="none";
}







//*************************************************************************


var currId='';
var origContent='';
var origCondition='';
var condCount=0;
var condition='';
var fieldname='';
var formName='';

var arrCondition=new Array();
var elseProf='';

//*************************************************************************
function conditioneditor(divid,FieldName,field_id) {
//*************************************************************************
	currId=divid;
	origContent=document.getElementById('conditionEditor').innerHTML;
	document.getElementById('conditionEditor').style.display="block";

	origCondition=document.getElementById(divid).value;
	condCount=0;
	arrCondition={};

	condition=origCondition;
	//condition="IF[${CNTC_DATA_EXT}::=::1::MASK(6)]||IF[${CNTC_DATA_EXT}::=::2::MASK(7)]||ELSE[MASK(9)]";
	fieldname=FieldName;
	fieldId=field_id;
	
	var check_items=condition.split('||');
	var check_field='';
	var check_oper='';
	var check_val='';
	var check_prof='';
	
	
	var a_condition='';
	
	for (var i=0;i<check_items.length;i++) {
			var spl=check_items[i].split('::');
			if (spl[0].indexOf('IF[')==0) {
			
				check_field=spl[0].replace('IF[${','').replace('}','');
				check_oper=spl[1];
				check_val=spl[2];
				check_prof=spl[3].replace('MASK(','').replace(')]','');
								
				a_condition=check_field+"::"+check_oper+"::"+check_val+"::"+check_prof;
				arrCondition[condCount]=a_condition;
				condCount=condCount+1;
				
				
			}
			else {
				check_prof=check_items[i].replace('ELSE[MASK(','').replace(')]','');
				elseProf=check_prof;
				
			}
	}
	
	drawConditions();
}

//*************************************************************************
function drawConditions() {
//*************************************************************************
	
	
	dynaContent='<table class="table table-bordered table-striped">';

	dynaContent=dynaContent+newcondline('new','','','','');

	for (var i=0;i<condCount;i++) {
		var a_cond=arrCondition[i].split("::");
		var check_field=a_cond[0];
		var check_oper=a_cond[1];
		var check_val=a_cond[2];
		var check_prof=a_cond[3];
	
		dynaContent=dynaContent+newcondline(i,check_field,check_oper,check_val,check_prof);
	}
	
	
	dynaContent=dynaContent+'<tr bgcolor=#DADADA><td colspan=5 align=left>';
	dynaContent=dynaContent+'When Others then :' + makeComboFromArray('prof_else',profilesArr,elseProf);
	dynaContent=dynaContent+'</td></tr>';

	dynaContent=dynaContent+'</table>';
	
	
	var newContent=origContent;
	
	newContent=newContent.replace("#FIELDNAME#",fieldname);
	newContent=newContent.replace("#DYNAMICCONTENT#",dynaContent);


	document.getElementById('conditionEditor').innerHTML=newContent;
}


//*************************************************************************
function addnewCondition() {
//*************************************************************************
var new_field_name=document.getElementById('field_new').value;
var new_oper=document.getElementById('oper_new').value;
var new_val=document.getElementById('val_new').value;
var new_prof=document.getElementById('prof_new').value;

var err_msg='';

if (new_field_name=='') err_msg=err_msg+'\nError : Field name is empty!.';
if (new_oper=='') err_msg=err_msg+'\nError : Operation is empty!.';
if (new_oper=='') err_msg=err_msg+'\nError : Masking profile is empty!.';

if (err_msg!='') {
	alert(err_msg);
}
else {
	var a_new_cond=new_field_name+"::"+new_oper+"::"+new_val+"::"+new_prof;
	arrCondition[condCount]=a_new_cond;
	condCount++;
	drawConditions();
}


}

//*************************************************************************
function removeCondition(id) {
//*************************************************************************


var NEWarrCondition=new Array();
var t=0;
for (var i=0;i<condCount;i++) {
	if (id!=i) {
		NEWarrCondition[t]=arrCondition[i];
		t++;
	}
}

arrCondition=NEWarrCondition;



condCount--;
drawConditions();
}

//*************************************************************************
function newcondline(id, field1,oper1,val1,prof1) {
var ret1='';

var fieldsCombo=makeComboFromArray('field_'+id, fieldsArr,field1);
var operandsCombo=makeComboFromArray('oper_'+id, operandsArr,oper1);
var valsField='<input id="val_'+id+'"type=text value="'+val1+'" size=8>';
var profilesCombo=makeComboFromArray('prof_'+id,profilesArr,prof1);

var bgcolor='#DADADA';
if (field1=='') bgcolor='yellow';
ret1=ret1+'<tr bgcolor="'+bgcolor+'">';

ret1=ret1+'<td> IF '+fieldsCombo+'</td>';
ret1=ret1+'<td>'+operandsCombo+'</td>';
ret1=ret1+'<td>'+valsField+'</td>';
ret1=ret1+'<td>'+profilesCombo+'</td>';
if (field1!='') {
	ret1=ret1+'<td align=center>';
	ret1=ret1+' <a href="#" onclick="removeCondition('+id+');">Remove</a>';
	ret1=ret1+'</td>';
} 
else {
	ret1=ret1+'<td align=center><a href="#" onclick="addnewCondition();">Add</a></td>';
}

ret1=ret1+'</tr>';

//*************************************************************************
return ret1;
}

//*************************************************************************
function makeComboFromArray(id,arr,currval) {
//*************************************************************************
var ret1='<select id="'+id+'" size=1><option></option>';
var a_item='';
var a_val='';
var a_title='';
var selected='';
for(var i=1;i<arr.length;i++) {
	a_item=arr[i];
	var spl=a_item.split('::');
	a_val=spl[0];
	a_title=spl[1];
	selected='';
	if (currval==a_val) selected='selected';
	ret1=ret1+'<option '+selected+' value="'+a_val+'">'+a_title+'</option>';
}
ret1=ret1 + '</select>';
return ret1;

}
//*************************************************************************

//*************************************************************************
function savecondition() {
//*************************************************************************
	if(condCount==0) {
		alert('At least 1 condition should be defined.');
		return;
	}
	
	var elseprof=document.getElementById('prof_else').value;
	if(elseprof=='') {
		alert('ELSE profile must be defined.');
		return;
	}
	elseProf=elseprof;
	
	if(condCount==0) {
		alert('At least a conditional mask must be defined.');
		return;
	}

	document.getElementById('conditionEditor').innerHTML=origContent;
	
	var newCond='';
	
	
	//condition="IF[${CNTC_DATA_EXT}::=::1::MASK(6)]||IF[${CNTC_DATA_EXT}::=::2::MASK(7)]||ELSE[MASK(9)]";
	for (var i=0;i<condCount;i++) {
		var a_cond=arrCondition[i].split("::");
		var check_field=a_cond[0];
		var check_oper=a_cond[1];
		var check_val=a_cond[2];
		var check_prof=a_cond[3];
		
		newCond=newCond+'IF[${'+check_field+'}::'+check_oper+'::'+check_val+'::MASK('+check_prof+')]||';
	}
	
	newCond=newCond+'ELSE[MASK('+elseProf+')]';

	document.getElementById(currId).value=newCond;
	
	changeField("condition_expr",fieldId,this,newCond);
	
	document.getElementById('conditionEditor').style.display="none";

	

	}

//*************************************************************************
function cancelcondition() {
//*************************************************************************
	document.getElementById('conditionEditor').style.display="none";
	document.getElementById('conditionEditor').innerHTML=origContent;
}


//*************************************************************************
function user_add() {
//*************************************************************************
	
	document.fuser.action.value="add_user";
	
	document.fuser.submit();
}

//*************************************************************************
function user_delete(user_id) {
//*************************************************************************
	if (!confirm("sure to delete?")) return;
	
	document.fuser.action.value="delete_user";
	document.fuser.user_id.value=user_id;
	document.fuser.submit();
}

//*************************************************************************
function user_update(user_id) {
//*************************************************************************
	
	document.fuser.action.value="update_user";
	document.fuser.user_id.value=user_id;
	document.fuser.user_fname.value=document.getElementById("user_fname_"+user_id).value;
	document.fuser.user_lname.value=document.getElementById("user_lname_"+user_id).value;
	document.fuser.user_email.value=document.getElementById("user_email_"+user_id).value;
	document.fuser.submit();
}

//*************************************************************************
function user_setrole(user_id, role_id, cb) {
//*************************************************************************
	
	document.fuser.action.value="update_role_user";
	document.fuser.user_id.value=user_id;
	document.fuser.user_role_id.value=role_id;
	var checked="false";
	if (cb.checked) checked="true";
	
	document.fuser.user_role_value.value=checked;
	
	document.fuser.submit();
}


//*************************************************************************
function user_password(user_id) {
//*************************************************************************
	
	document.fuser.action.value="update_password";
	document.fuser.user_id.value=user_id;
	var pass=document.getElementById("password_"+user_id).value;
	if (pass.length<6) {
		alert("password must be at least 6 chars length.");
		return;
	}
	
	
	var pass2=prompt('Enter Password Again : ');
	
	if (pass2!=pass) {
		alert("Passwords entered does not match");
		return;
		
	}
	
	document.fuser.user_new_password.value=pass;
	
	document.fuser.submit();
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
        alert("invalid date => "+input+ "\n[should be formatted like "+myformat+"]");    
        obj.focus();
        obj.value=moment(Date()).format(myformat);
        mydate=null;
        return false;
    }

    
    return true;
}




//*************************************************************************
function deleteDiscovery(discovery_id){
//*************************************************************************
	if(!confirm("Are you sure to delete this discovery?")) return;
	
	location.href="discovery.jsp?discovery_id="+discovery_id+"&delete_discovery=YES";
}


//*************************************************************************
function ruleAdd(){
//*************************************************************************
	document.getElementById("action").value="add_rule";
	
	document.forms[0].submit();
}

//*************************************************************************
function ruleDelete(rule_id){
//*************************************************************************
	if(!confirm("Are you sure to delete this rule?")) return;
	
	document.getElementById("action").value="delete_rule";
	document.getElementById("rule_id").value=rule_id;
	
	document.forms[0].submit();
}

	
//*************************************************************************
function ruleUpdate(rule_id) {
//*************************************************************************
	var rule_desc="";
	var rule_type="";
	var rule_target="";
	var is_checked=true;
	var rule_weight="10";
	
	
	rule_desc=document.getElementById("description_"+rule_id).value;
	rule_type=document.getElementById("rule_type_"+rule_id).value;
	rule_target=document.getElementById("discovery_target_id_"+rule_id).value;
	is_checked=document.getElementById("is_valid_"+rule_id).checked;
	rule_weight=document.getElementById("rule_weight_"+rule_id).value;
	
	
	
	
	var is_checked_value="YES";
	if (!is_checked) is_checked_value="NO";

		
	document.getElementById("action").value="update_rule";
	document.getElementById("rule_id").value=rule_id;
	document.getElementById("rule_target_id").value=rule_target;
	document.getElementById("rule_type").value=rule_type;
	document.getElementById("rule_description").value=rule_desc;
	document.getElementById("is_valid").value=is_checked_value;
	document.getElementById("rule_weight").value=rule_weight;
		
	document.forms[0].submit();
}

	
//*************************************************************************
function ruleScriptEditor(rule_id){
//*************************************************************************
	document.getElementById("action").value="script_rule";
	document.getElementById("rule_id").value=rule_id;
	
	document.forms[0].submit();
}


//*************************************************************************
function ruleFieldEditor(rule_id){
//*************************************************************************
	document.getElementById("action").value="field_names";
	document.getElementById("rule_id").value=rule_id;
	
	document.forms[0].submit();
}

//*************************************************************************
function dbAdd(){
//*************************************************************************
	document.fdb.action.value="add_db";
	
	document.forms[0].submit();
}

//*************************************************************************
function dbDelete(db_id){
//*************************************************************************
	if(!confirm("Are you sure to remove this DB?")) return;
	
	document.fdb.action.value="delete_db";
	document.fdb.db_id.value=db_id;
	
	document.forms[0].submit();
}

//*************************************************************************
function dbUpdate(db_id){
//*************************************************************************

	
	
	var db_name=document.getElementById("db_name_"+db_id).value;
	var short_code=document.getElementById("short_code_"+db_id).value;
	var db_driver=document.getElementById("db_driver_"+db_id).value;
	var url_template=document.getElementById("url_template_"+db_id).value;
	var test_sql=document.getElementById("test_sql_"+db_id).value;
	var partition_sql=document.getElementById("partition_sql_"+db_id).value;
	var rowid_field=document.getElementById("rowid_field_"+db_id).value;

	document.fdb.action.value="update_db";
	document.fdb.db_id.value=db_id;
	document.fdb.db_name.value=db_name;
	document.fdb.short_code.value=short_code;
	document.fdb.db_driver.value=db_driver;
	document.fdb.url_template.value=url_template;
	document.fdb.test_sql.value=test_sql;
	document.fdb.partition_sql.value=partition_sql;
	document.fdb.rowid_field.value=rowid_field;
	
	
	
	document.fdb.submit();
}
	

//*************************************************************************
function starttestinput(){
//*************************************************************************
	var x=document.getElementById("testinput").value;
	if (x=="Enter Text Here") document.getElementById("testinput").value="";
}


//*************************************************************************
function testRuleScript(){
//*************************************************************************
	var rule_type=document.getElementById("script_rule_type").value;
	var rule_script=document.getElementById("rule_script").value;
	var input_string=document.getElementById("testinput").value;
	
	var ret1=false;
	
	
	if (rule_type=="MATCHES") {
		
		var regexArr=rule_script.split("\n");
		
		for (var s=0;s<regexArr.length;s++) {
			
			var a_regex=regexArr[s];
			var patt = new RegExp(a_regex);
			var res = patt.test(input_string);
			
			
			if (res==true) {
				ret1=true;
				break;
			}
		}
		
		
	}
	else {
		rule_script=rule_script.replace("${1}",input_string);
		
		try{
			ret1=eval(rule_script);
		} catch(e) {
			alert("Javascript Exception :("+e.name+") "+e.message);
			
		}
		
	}
	
	var bgcolor="green";
	if (!ret1) bgcolor="red";
	
	document.getElementById("testinput").style.background=bgcolor;

}


//*************************************************************************
function settarget(){
//*************************************************************************
	document.forms[0].submit();
}

//*************************************************************************
function change_mask_level(tab_id){
//*************************************************************************
	var sel=document.getElementById("mask_level");
	var ind=sel.selectedIndex;
	if (!confirm('All field counfiguration will be reset after "MASK LEVEL" changes. Are you sure?')) {
		if (ind==0) sel.selectedIndex=1;
		if (ind==1) sel.selectedIndex=0;
		return;
	}
	document.getElementById("filter_tab_id").value=tab_id;
	savetabinfo('CHANGE_MASK_LEVEL');
}


//*************************************************************************
function changeTab(tab_id,tab_count){
//*************************************************************************
	for (var i=1;i<=tab_count;i++) {
		var el=document.getElementById("tabButton"+i);
		el.className = "passiveTabButton";

		var el2=document.getElementById("tabContent"+i);
		el2.className = "tabContentInvisible";
	}
	
	var elact=document.getElementById("tabButton"+tab_id);
	elact.className = "activeTabButton";

	var elact=document.getElementById("tabContent"+tab_id);
	elact.className = "tabContentVisible";

}
