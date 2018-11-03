<%@include file="header.jsp"%> 

 
<% 




request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");

String action="";
String div="";
String par1="";
String par2="";
String par3="";
String par4="";
String par5="";





try {
	action=nvl(request.getParameter("action"),"-");

	div=nvl(request.getParameter("div"),"-");
	par1	=	nvl(request.getParameter("par1"),"");
	par2	=	nvl(request.getParameter("par2"),"");
	par3	=	nvl(request.getParameter("par3"),"");
	par4	=	nvl(request.getParameter("par4"),"");
	par5	=	nvl(request.getParameter("par5"),"");


} catch(Exception e) {
	e.printStackTrace();
	action="-";
}



String sql="";
String html="";
ArrayList<String> htmlArr=new ArrayList<String>();
ArrayList<String> divArr=new ArrayList<String>();
String msg="ok";
ArrayList<String[]> bindlist=new ArrayList<String[]>();
Connection conn=null;
JSONObject obj=new JSONObject(); 


	try {

	String curr_param_delimiter=":::::";	
		
	String[] arr_action=action.split(curr_param_delimiter);
	String[] arr_div=div.split(curr_param_delimiter);
	String[] arr_par1=par1.split(curr_param_delimiter);
	String[] arr_par2=par2.split(curr_param_delimiter);
	String[] arr_par3=par3.split(curr_param_delimiter);
	String[] arr_par4=par4.split(curr_param_delimiter);
	String[] arr_par5=par5.split(curr_param_delimiter);
	
	
	for (int a=0;a<arr_action.length;a++) {

		
		
		try {action=arr_action[a];} catch(Exception e) {action="";}
		try {div=arr_div[a];} catch(Exception e) {div="";}
		try {par1=arr_par1[a];} catch(Exception e) {par1="";}
		try {par2=arr_par2[a];} catch(Exception e) {par2="";}
		try {par3=arr_par3[a];} catch(Exception e) {par3="";}
		try {par4=arr_par4[a];} catch(Exception e) {par4="";}
		try {par5=arr_par5[a];} catch(Exception e) {par5="";}
		
		par1=par1.replaceAll("\\*\\*NEWLINE\\*\\*", "\n");
		par2=par2.replaceAll("\\*\\*NEWLINE\\*\\*", "\n");
		par3=par3.replaceAll("\\*\\*NEWLINE\\*\\*", "\n");
		par4=par4.replaceAll("\\*\\*NEWLINE\\*\\*", "\n");
		par5=par5.replaceAll("\\*\\*NEWLINE\\*\\*", "\n");
		
		/*
		par1=par1.replaceAll("::PIPE::", "|");
		par2=par2.replaceAll("::PIPE::", "|");
		par3=par3.replaceAll("::PIPE::", "|");
		par4=par4.replaceAll("::PIPE::", "|");
		par5=par5.replaceAll("::PIPE::", "|");
		*/
		
		
		
		/*
		System.out.println("action="+action);
		System.out.println("par1="+par1);
		System.out.println("par2="+par2);
		System.out.println("par3="+par3);
		System.out.println("par4="+par4);
		System.out.println("par5="+par5);
		*/

		if (a==0) {
			
			conn=getconn();
			
			if (conn==null) {
				System.out.println("Connection cannot be established");
				msg="nok:Connection cannot be established";
				html="-";
			}


		}
		

		
		
		long start_ts=System.currentTimeMillis();
		
		html="";
		//msg="";
		

		
			if (msg.indexOf("nok:")==-1) {	
	
				
				
					
				
				
				//**********************************************
				//print_about
				//**********************************************
				if (action.equals("print_about")) {
							
					String licence_owner=getParamByName(conn, "LICENCE_OWNER_COMPANY");
					String licence_contact=getParamByName(conn, "LICENCE_OWNER_CONTACT");
					String licence_email=getParamByName(conn, "LICENCE_OWNER_EMAIL");
					String licence_valid_to=getParamByName(conn, "LICENCE_END_DATE");
					
					if (licence_owner.length()==0)
						html="<h4><font color=red>Not registered yet.</font></h4>";
					else
					
					html="<h2>Licenced to  : </h2>" +
				         "   <ul>"+
				         "   	<li>"+licence_owner+"</li>"+
				         "       <li>"+licence_contact+"</li>"+
				         "       <li>"+licence_email+"</li>"+
				         "       <li> Valid to : "+licence_valid_to+"</li>"+
				         "   </ul>";
					
					msg="ok";
				}
				
				//**********************************************
				//set_session_attribute
				//**********************************************
				if (action.equals("set_session_attribute")) {
					
					String attr=par1;
					String val=par2;
					
					session.setAttribute(attr, val);
					
					html="-";
					msg="ok";

				}
				//**********************************************
				//do_login
				//**********************************************
				if (action.equals("do_login")) {
					
					String input_username=par1;
					String input_password=par2;
					
					
					boolean is_connection_ok=doLoginAttempt(conn, session, input_username, input_password); 
					
					
					System.out.println("is_connection_ok="+is_connection_ok);
	
					html="-";
	
					if (is_connection_ok) {
						
						try {
							String hostname=""+nvl(request.getRemoteHost(),"Unknown")+"["+nvl(request.getRemoteAddr(),"unknown")+"]" ;
							session.setAttribute("hostname",hostname);
						} catch(Exception e) {
							e.printStackTrace();
							session.setAttribute("hostname","Unknown");
						}
						
						closeconn(conn); 
						msg="ok:javascript:printMenu()";
						break;
						 
					}
					else 
						msg="ok:javascript:showLoginError()";
					
				}
				
				
				//**********************************************
				//check_login_on_load
				//**********************************************
				if (action.equals("check_login_on_load")) {
					
					boolean is_logged_in=checkLogin(conn,session);
					
					if (is_logged_in) {
						html="-";
						msg="ok:javascript:openCurrentModule()";
					} else {
						html="-";
						msg="ok:javascript:showLoginBox()";
					}
					
					
				}
				//**********************************************
				//fiil_login_box
				//**********************************************
				if (action.equals("fiil_login_box")) {
					
					html=fillLoginBox(conn,session); 
					msg="ok";
					
					
				}
				//**********************************************
				//print_main_menu
				//**********************************************
				if (action.equals("print_main_menu")) {
					
					html=printMenu(conn, request, session) ;
					msg="ok:javascript:makeModuleTree()";
					
					
				}
				
				//**********************************************
				//show_lov_dialog
				//**********************************************
				if (action.equals("show_lov_dialog")) {
					
					String lov_title=par1;
					String lov_type=par2;
					String lov_parameters=par3;
					String curr_value=par4;
					String fireEvent=par5;
					
					
					html=makeLov(conn,session,lov_title,lov_type, lov_parameters, curr_value, fireEvent); 
					msg="ok";			
					
				}
				
				//**********************************************
				//make_module_tree
				//**********************************************
				if (action.equals("make_module_tree")) {
					
					html=makeModuleTree(conn, session); 
					msg="ok:javascript:showActiveTreeContent(); ";
					
					
				}
				
				//**********************************************
				//set_user_lang
				//**********************************************
				if (action.equals("set_user_lang")) {
					
					String lang=par1;
					setUserLang(conn, session, lang); 
					
					html="-";			
					msg="ok:javascript:reloadCurrentPage()";
				}
				
				
				//**********************************************
				//logout
				//**********************************************
				if (action.equals("logout")) {
					
					logoutFromSystem(conn, session); 
					html="-";			
					msg="ok:javascript:gotoHome()";
				}
				
				//**********************************************
				//open_module
				//**********************************************
				if (action.equals("open_module")) {
					String module=par1;
					
					html=openModule(conn, session,module); 
					msg="ok:javascript:printMenu()";
					
					
				}
				
				
				//**********************************************
				//set_domain
				//**********************************************
				if (action.equals("set_domain")) {
					String domain_id=par1;
					
					setUserDomain(conn,session,domain_id);
					
					html="-"; 
					msg="ok:javascript:openCurrentModule()";
					
					
				}
				
				
				//**********************************************
				//expand_tree
				//**********************************************
				if (action.equals("expand_tree")) {
					String tree_id=par1;
					String level=par2;
					
					expandTree(conn, session,tree_id); 
					
					html=redrawTree(conn, session,tree_id,level);  
					msg="ok";
				}
				
				
				//**********************************************
				//collapse_tree
				//**********************************************
				if (action.equals("collapse_tree")) {
					String tree_id=par1;
					String level=par2;
					
					collapseTree(conn, session,tree_id); 
					
					html=redrawTree(conn, session,tree_id,level); 
					msg="ok";
				}
				
				//**********************************************
				//redraw_tree
				//**********************************************
				if (action.equals("redraw_tree")) {
					String tree_id=par1;
					String level=par2;
					
					html=redrawTree(conn, session,tree_id,level); 
					
					String active_tree_id=getCurrentTreeId(session);
					
					if (active_tree_id.equals(tree_id))
						msg="ok:javascript:setActiveTree('"+tree_id+"'); ";
					else
						msg="ok";
				}
				//**********************************************
				//set_active_tree
				//**********************************************
				if (action.equals("set_active_tree")) {
					String tree_id=par1;
					
					String previous_active_tree_id=getCurrentTreeId(session);
					
					setCurrentTreeId(session,tree_id);
					
					
					html="-"; 
					msg="ok:javascript:unligthTreeNode('"+previous_active_tree_id+"'); ligthTreeNode('"+tree_id+"'); showTreeContent('"+tree_id+"'); makeTreeToolBox('"+tree_id+"'); ";
				}
				
				//**********************************************
				//show_tree_content
				//**********************************************
				if (action.equals("show_tree_content")) {
					String tree_id=par1;
					
					html=makeTreeContent(conn, session,tree_id); 
					msg="ok";
				}
				
				//**********************************************
				//show_active_tree_content
				//**********************************************
				if (action.equals("show_active_tree_content")) {
					String tree_id=getCurrentTreeId(session);
					
					html=makeTreeContent(conn, session,tree_id); 
					msg="ok:javascript:ligthTreeNode('"+tree_id+"'); makeTreeToolBox('"+tree_id+"');";
				}
				//**********************************************
				//make_tree_toolbox
				//**********************************************
				if (action.equals("make_tree_toolbox")) {
					String tree_id=par1;
					
					html=makeTreeToolBox(conn, session,tree_id); 
					msg="ok";
				}
				
				//**********************************************
				//fiil_add_rename_tree_node_box
				//**********************************************
				if (action.equals("fiil_add_rename_tree_node_box")) {
					String parent_tree_id=par1;
					String mode=par2;
					String tree_type=par3;
					String step_type=par4;
					
					boolean is_checkin_available=true;
					if (mode.equals("RENAME"))
						is_checkin_available=isCheckinAvailable(conn, session, parent_tree_id);
					
					if (is_checkin_available) {
						html=makeAddRenameTreeNodeBox(conn, session,parent_tree_id, tree_type, mode, step_type);  
						msg="ok";
					} else {
						html="Not Checked out!";
						msg="ok ";
					}
					
					
				}

				//**********************************************
				//add_tree_node_do
				//**********************************************
				if (action.equals("add_tree_node_do")) {
					String parent_tree_id=par1;
					String tree_node_title=par2;
					String tree_type=par3;
					String referenced_test_id=par4;
					String activate_added_item=par5;
					

					
					String tree_id=addTreeNodeDO(conn, session,parent_tree_id,tree_node_title, tree_type, referenced_test_id);  
					
					if (tree_id.equals("0")) {
						html="-"; 
						msg="ok:javascript:myalert('Node can not be added!')";
					}
					else {
						html="-";
						
						session.setAttribute("activate_added_item", activate_added_item);
						
						if (activate_added_item.equals("YES"))
							msg="ok:javascript:redrawTree('"+parent_tree_id+"'); setActiveTree('"+tree_id+"');";
						else
							msg="ok:javascript:redrawTree('"+parent_tree_id+"'); setActiveTree('"+parent_tree_id+"'); ";
					}
				}

				
				//**********************************************
				//rename_tree_node_do
				//**********************************************
				if (action.equals("rename_tree_node_do")) {
					String tree_id=par1;
					String tree_node_title=par2;
					
					StringBuilder err=new StringBuilder();
					
					renameTreeNodeDO(conn, session,tree_id,tree_node_title,err);  
					
					
					
					if (err.length()==0) {
						html="-";
						msg="ok:javascript:redrawTree('"+tree_id+"');  ";
					} else {
						html="-";
						msg="ok:javascript:myalert('"+err.toString()+"');  ";
					}
					
					
					
				}

				//**********************************************
				//remove_tree_node
				//**********************************************
				if (action.equals("remove_tree_node")) {
					String tree_id=par1;
					
					String parent_tree_id=getTreeAttributeValue(conn, session, tree_id, "parent_tree_id");
					
					StringBuilder err=new StringBuilder();
					
					boolean force=false;
					
					removeTreeNodeDO(conn, session,tree_id, parent_tree_id, force, err); 
					
					if (err.length()>0) {
						html="-"; 
						msg="ok:javascript:myalert('"+err.toString()+"')";
					}
					else {
						html="-";
						msg="ok:javascript:redrawTree('"+parent_tree_id+"'); setActiveTree('"+parent_tree_id+"'); ";
					}
				
			
				}
				
				//**********************************************
				//check_out_node_controll
				//**********************************************
				if (action.equals("check_out_node_controll")) {
					String tree_id=par1;
					
					
					StringBuilder checkres=new StringBuilder();
					
					boolean checkout_success=makeCheckoutTreeNodeControll(conn, session,tree_id,checkres);
					
					html=checkres.toString();
					msg="ok";					
				}
				
				//**********************************************
				//checkout_tree_node
				//**********************************************
				if (action.equals("checkout_tree_node")) {
					String tree_id=par1;
					
					StringBuilder cherr=new StringBuilder();
					
					boolean is_ok=checkoutTreeNodeDO(conn, session,tree_id,cherr);  
					
					if (!is_ok) {
						html="-"; 
						msg="ok:javascript:myalert('"+clearHtml(cherr.toString())+"')";
					}
					else {
						html="-";
						//msg="ok:javascript:redrawTree('"+tree_id+"'); setActiveTree('"+tree_id+"');  ";
						msg="ok:javascript:redrawTree('"+tree_id+"');  ";
					}
				
			
				}
				
				//**********************************************
				//fiil_checkin_tree_node_box
				//**********************************************
				if (action.equals("fiil_checkin_tree_node_box")) {
					String tree_id=par1;
					
					html=makeCheckinTreeNodeBox(conn, session,tree_id);  
					msg="ok";
				}
				
				//**********************************************
				//checkin_tree_node_do
				//**********************************************
				if (action.equals("checkin_tree_node_do")) {
					String tree_id=par1;
					String checkin_note=par2;
					
					StringBuilder cherr=new StringBuilder();
					
					boolean is_ok=checkinTreeNodeDO(conn, session,tree_id,checkin_note,cherr);  
					
					if (!is_ok) {
						html="-"; 
						msg="ok:javascript:myalert('"+clearHtml(cherr.toString())+"')";
					}
					else {
						html="-";
						msg="ok:javascript:redrawTree('"+tree_id+"'); setActiveTree('"+tree_id+"');  ";
					}
				
			
				}
				
				
				//**********************************************
				//fiil_tree_history_box
				//**********************************************
				if (action.equals("fiil_tree_history_box")) {
					String tree_id=par1;
					
					html=makeTreeCheckHistory(conn, session,tree_id);   
					msg="ok";
				}
				
				
				//**********************************************
				//copy_tree_node
				//**********************************************
				if (action.equals("copy_tree_node")) {
					String tree_id=par1;
					
					String old_clipboard_id=getClipboardId(session);
					
					editTreeNode(conn,session,tree_id,"COPY");
					
					html="-";
					msg="ok:javascript:redrawTree('"+old_clipboard_id+"');  redrawTree('"+tree_id+"'); setActiveTree('"+tree_id+"');  ";
				
			
				}
				
				//**********************************************
				//copy_tree_node
				//**********************************************
				if (action.equals("cut_tree_node")) {
					String tree_id=par1;
					
					String old_clipboard_id=getClipboardId(session);
					
					editTreeNode(conn,session,tree_id,"CUT"); 
					
					html="-";
					msg="ok:javascript:redrawTree('"+old_clipboard_id+"'); redrawTree('"+tree_id+"'); setActiveTree('"+tree_id+"');  ";
				
			
				}
				
				
				//**********************************************
				//paste_tree_node
				//**********************************************
				if (action.equals("paste_tree_node")) {
					String parent_tree_id=par1;
					
					String clipboard_action=getClipboardAction(session);
					String clipboard_id=getClipboardId(session);
					
					String parent_of_clipboard_id="0";
					
					if (clipboard_action.equals("CUT"))
						parent_of_clipboard_id=getTreeAttributeValue(conn, session, clipboard_id, "parent_tree_id");
					
					pasteTreeNode(conn, session, parent_tree_id);
					
					html="-";
					
					if (clipboard_action.equals("CUT"))	{
						
						msg="ok:javascript:redrawTree('"+parent_of_clipboard_id+"');  redrawTree('"+parent_tree_id+"'); expandTeeNode('"+parent_tree_id+"'); setActiveTree('"+parent_tree_id+"');  ";
					}
					else
						msg="ok:javascript:redrawTree('"+parent_tree_id+"'); expandTeeNode('"+parent_tree_id+"'); setActiveTree('"+parent_tree_id+"');  ";
				
			
				}
				
				//**********************************************
				//reorder_tree_node
				//**********************************************
				if (action.equals("reorder_tree_node")) {
					String tree_id=par1;
					String parent_tree_id=par2;
					String p_direction=par3;
					
					String table_name="tdm_test_tree";
					String table_pk_id_val=tree_id;
					String table_pk_bind_type="LONG";
					String direction=p_direction;
					String group_field_names="parent_tree_id";
					String group_field_bind_types="LONG";
					String group_field_values=parent_tree_id;
					String order_field_name="order_by";
					
					reorderTableOrderByGroup(conn, session, table_name, table_pk_id_val, table_pk_bind_type, direction, group_field_names, group_field_bind_types, group_field_values, order_field_name); 


					html="-";
					msg="ok:javascript: redrawTree('"+parent_tree_id+"'); setActiveTree('"+parent_tree_id+"');  ";
			
				}
				
				//**********************************************
				//cancel_check_in
				//**********************************************
				if (action.equals("cancel_check_in")) {
					String tree_id=par1;
					
					
					StringBuilder cherr=new StringBuilder();
					
					boolean is_ok=cancelCheckinForTreeNode(conn, session,tree_id,cherr);  
					
					if (!is_ok) {
						html="-"; 
						msg="ok:javascript:myalert('"+clearHtml(cherr.toString())+"')";
					}
					else {
						html="-";
						msg="ok:javascript:redrawTree('"+tree_id+"'); setActiveTree('"+tree_id+"');  ";
					}
				
			
				}
				
				//**********************************************
				//search_configuration
				//**********************************************
				if (action.equals("search_configuration")) {
					String search_what="search_for_"+par1;
					String search_value=par2;
					html="-";
					
					session.setAttribute(search_what, search_value);
					
					
					if (search_what.equals("search_for_strings")) 
						html=makeStringList(conn, session);
					else	
						if (search_what.equals("search_for_flexible_fields")) 
							html=makeFlexFieldList(conn, session);
					else
					if (search_what.equals("search_for_users")) 
						html=makeUserList(conn, session);
						
					msg="ok";
				}	
				
				//**********************************************
				//make_mad_lang_list
				//**********************************************
				if (action.equals("make_lang_list")) {
					html=makeLangList(conn, session); 
					msg="ok";
				}
				
				//**********************************************
				//update_lang_field
				//**********************************************
				if (action.equals("update_lang_field")) {
					String lang_id=par1;
					String field_name=par2;
					String field_value=par3;
					 
					updateTableField(conn,session,"mad_lang",lang_id, field_name, field_value); 
					html="-";
					msg="ok";			
					
				}
				
				//**********************************************
				//delete_lang
				//**********************************************
				if (action.equals("delete_lang")) {
					String lang_id=par1;
					 
					String err_msg=deleteLang(conn,session,lang_id); 
					
					if (err_msg.length()==0) {
						html="-";
						msg="ok:javascript:makeLangList()";
					}
					else {
						html="-";
						msg="nok:"+err_msg;
					}
					
				}
				
				//**********************************************
				//add_lang
				//**********************************************
				if (action.equals("add_lang")) {
					String lang_desc=par1;
					
					 
					int res=addNewLang(conn,session,lang_desc); 
					if (res<0) {
						
						if (res==-1) {
							html="-";
							msg="nok:there is already a language named :  ("+lang_desc+")";
						}
						
						if (res==-2) {
							html="-";
							msg="language cannot be added.";
						}
						
					}
					else {
						html="-";
						msg="ok:javascript:makeLangList()";
					}
				}
				//**********************************************
				//make_string_list
				//**********************************************
				if (action.equals("make_string_list")) {
					html=makeStringList(conn, session);
					msg="ok";
				}
				//**********************************************
				//add_string
				//**********************************************
				if (action.equals("add_string")) {
					String string_name=par1;
					String lang=par2;
					
					 
					int res=addNewString(conn,session,string_name, lang); 
					if (res<0) {
						if (res==-1) {
							html="-";
							msg="nok:there is already a string named :  ("+string_name+") with language ("+lang+")";
						}
						if (res==-2) {
							html="-";
							msg="string cannot be added.";
						}
					}
					else {
						html="-";
						msg="ok:javascript:makeStringList()";
					}
				}
				//**********************************************
				//update_string_field
				//**********************************************
				if (action.equals("update_string_field")) {
					String string_id=par1;
					String field_name=par2;
					String field_value=par3;
					 
					updateTableField(conn,session,"mad_string",string_id, field_name, field_value);
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//delete_string
				//**********************************************
				if (action.equals("delete_string")) {
					String string_id=par1;
					 
					String err_msg=deleteString(conn,session,string_id);
					
					if (err_msg.length()==0) {
						html="-";
						msg="ok:javascript:makeStringList()";
					}
					else {
						html="-";
						msg="nok:"+err_msg;
					}
					
				}
				//**********************************************
				//view_html_content
				//**********************************************
				if (action.equals("view_html_content")) {
					
					String string_id=par1;


					html=getStringContent(conn, session, string_id,"long_desc");
					msg="ok";
				}
				//**********************************************
				//make_flex_field_list
				//**********************************************
				if (action.equals("make_flex_field_list")) {
					html=makeFlexFieldList(conn, session); 
					msg="ok";
				}
				//**********************************************
				//make_flex_field_editor
				//**********************************************
				if (action.equals("make_flex_field_editor")) {
					String flex_field_id=par1;
					html=makeFlexFieldEditor(conn, session, flex_field_id);
					msg="ok";
				}
				//**********************************************
				//add_flexible_field
				//**********************************************
				if (action.equals("add_flexible_field")) {
					String flex_field_type=par1;
					String field_title=par2;
					 
					int res=addNewFlexField(conn,session,flex_field_type,field_title);
					if (res<0) {
						
						if (res==-2) {
							html="-";
							msg="nok:modifier group cannot be added.";
						} 
					}
					else {
						html="-";
						msg="ok:javascript:makeFlexFieldList()";
					}
								
					
				}
				//**********************************************
				//delete_flex_field
				//**********************************************
				if (action.equals("delete_flex_field")) {
					String flex_field_id=par1;
					 
					String err_msg=deleteFlexField(conn,session,flex_field_id);
					if (err_msg.length()==0) {
						html="-";
						msg="ok:javascript:makeFlexFieldList()";	
					}
					else {
						html="-";
						msg="nok:"+err_msg;
					}
				}
				//**********************************************
				//update_flex_field
				//**********************************************
				if (action.equals("update_flex_field")) {
					String flex_field_id=par1;
					String field_name=par2;
					String field_value=par3;
					 
					
					updateTableField(conn,session,"mad_flex_field",flex_field_id, field_name, field_value);
					html="-";
					msg="ok:javascript:makeFlexFieldEditor('"+flex_field_id+"')";			
					
				}
				//**********************************************
				//make_permission_list
				//**********************************************
				if (action.equals("make_permission_list")) {
					html=makePermissionList(conn, session);
					msg="ok";
				}
				//**********************************************
				//add_new_permission
				//**********************************************
				if (action.equals("add_new_permission")) {
					String permission_name=par1;
					 
					int res=addNewPermission(conn,session,permission_name);
					if (res<0) {
						if (res==-1) { 
							html="-";
							msg="nok:there is already an permission named :  ("+permission_name+")";
						}
						if (res==-2) {
							html="-";
							msg="nok:permission cannot be added.";
						}
					}
					else {
						html="-";
						msg="ok:javascript:makePermissionList()";
					}
								
					
				}
				//**********************************************
				//update_permission_field
				//**********************************************
				if (action.equals("update_permission_field")) {
					String permission_id=par1;
					String field_name=par2;
					String field_value=par3; 
					 
					updateTableField(conn,session,"mad_permission",permission_id, field_name, field_value);
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//add_remove_permission_group
				//**********************************************
				if (action.equals("add_remove_permission_group")) {
					String permission_id=par1;
					String action_and_id=par2;
					String addremove="ADD";
					String group_id="0";
					try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
					try {group_id=action_and_id.split(":")[1];} catch(Exception e){}
					
					addRemoveGroupPermission(conn,session,group_id,addremove,permission_id);
					
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//delete_permission
				//**********************************************
				if (action.equals("delete_permission")) {
					String permission_id=par1;
					 
					String err_msg=deletePermission(conn,session,permission_id); 
					
					if (err_msg.length()==0) {
						html="-";
						msg="ok:javascript:makePermissionList()";
					}
					else {
						html="-";
						msg="nok:"+err_msg;
					}
								
					
				}
				//**********************************************
				//make_user_list
				//**********************************************
				if (action.equals("make_user_list")) {
					html=makeUserList(conn, session);
					msg="ok";
				}
				//**********************************************
				//make_user_editor
				//**********************************************
				if (action.equals("make_user_editor")) {
					String user_id=par1;
					
					html=makeUserEditor(conn, session, user_id);
					msg="ok";
				}
				//**********************************************
				//add_new_user
				//**********************************************
				if (action.equals("add_new_user")) {
					String entered_username=par1;
					 
					int res=addNewUser(conn,session,entered_username); 
					if (res<0) { 
						if (res==-1) {
							html="-";
							msg="nok:there is already a username named :  ("+entered_username+")";
						}
						if (res==-2) {
							html="-";
							msg="nok:username cannot be added.";
						}
					}
					else {
						html="-";
						msg="ok:javascript:makeUserList()";
					}
				}
				//**********************************************
				//update_user_field
				//**********************************************
				if (action.equals("update_user_field")) {
					String updating_user_id=par1;
					String field_name=par2;
					String field_value=par3; 
					 
					updateTableField(conn,session,"tdm_user",updating_user_id, field_name, field_value);
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//add_remove_user_membership
				//**********************************************
				if (action.equals("add_remove_user_membership")) {
					String member_user_id=par1;
					String action_and_id=par2;
					String addremove="ADD";
					String group_id="0";
					try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
					try {group_id=action_and_id.split(":")[1];} catch(Exception e){}
					
					addRemoveUserMembership(conn,session,member_user_id,addremove,group_id);
					
					html="-";
					msg="ok";			
				}
				//**********************************************
				//delete_user
				//**********************************************
				if (action.equals("delete_user")) {
					String deleted_user_id=par1;
					 
					String err_msg=deleteUser(conn,session,deleted_user_id);
					
					if (err_msg.length()==0) {
						html="-";
						msg="ok:javascript:makeUserList()";	
					}
					else {
						html="-";
						msg="nok:"+err_msg;
					}
				}
				
				//**********************************************
				//make_user_set_password
				//**********************************************
				if (action.equals("make_user_set_password")) {
					String password_user_id=par1;
					
					html=makeSetPassword(conn, session, password_user_id);
					msg="ok";			
					
				}
				//**********************************************
				//set_user_password
				//**********************************************
				if (action.equals("set_user_password")) {
					String password_user_id=par1;
					String new_password=par2;
					
					setUserPassword(conn, session, password_user_id, new_password);
					
					html="-";
					msg="nok:Password is changed successfully.";			
					
				}
				//**********************************************
				//make_group_list
				//**********************************************
				if (action.equals("make_group_list")) {
					html=makeGroupList(conn, session);
					msg="ok";
				}
				//**********************************************
				//make_group_editor
				//**********************************************
				if (action.equals("make_group_editor")) {
					String group_id=par1;
					
					html=makeGroupEditor(conn, session, group_id);
					msg="ok";
				}
				//**********************************************
				//add_group
				//**********************************************
				if (action.equals("add_group")) {
					String group_type=par1;
					String group_name=par2;
					 
					int res=addNewGroup(conn,session,group_type,group_name);
					if (res<0) {
						if (res==-1) {
							html="-";
							msg="nok:there is already an group named :  ("+group_name+")";
						}
						if (res==-2) {
							html="-";
							msg="nok:group cannot be added.";
						}
					}
					else {
						html="-";
						msg="ok:javascript:makeGroupList()";
					}
				}
				//**********************************************
				//update_group_field
				//**********************************************
				if (action.equals("update_group_field")) {
					String group_id=par1;
					String field_name=par2;
					String field_value=par3; 
					 
					updateTableField(conn,session,"mad_group",group_id, field_name, field_value);
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//delete_group
				//**********************************************
				if (action.equals("delete_group")) {
					String application_id=par1;
					 
					String err_msg=deleteGroup(conn,session,application_id);
					
					if (err_msg.length()==0) {
						html="-";
						msg="ok:javascript:makeGroupList()";			
					}
					else {
						html="-";
						msg="nok:"+err_msg;
					}
					
				}
				//**********************************************
				//add_remove_group_member
				//**********************************************
				if (action.equals("add_remove_group_member")) {
					String group_id=par1;
					String action_and_id=par2;
					String addremove="ADD";
					String member_id="0";
					try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
					try {member_id=action_and_id.split(":")[1];} catch(Exception e){}
					String member_type=par3; 
								
					addRemoveGroupMember(conn,session,group_id,member_type,addremove,member_id); 
					
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//add_remove_group_permission
				//**********************************************
				if (action.equals("add_remove_group_permission")) {
					String group_id=par1;
					String action_and_id=par2;
					String addremove="ADD";
					String permission_id="0";
					try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
					try {permission_id=action_and_id.split(":")[1];} catch(Exception e){}
									
					addRemoveGroupPermission(conn,session,group_id,addremove,permission_id); 
					
					html="-";
					msg="ok";			
				}
				//**********************************************
				//assign_role_to_group
				//**********************************************
				if (action.equals("assign_role_to_group")) {
					
					String group_id=par1;
					String role_id=par2;
					String role_action=par3;

					int assigned_user_count=assignDeassignRoleToGroup(conn, session, group_id, role_id, role_action); 
					html="-";
					msg="ok:javascript:myalert('"+assigned_user_count+" user is effected')";
				}
				//**********************************************
				//make_email_template_list
				//**********************************************
				if (action.equals("make_email_template_list")) {
					html=makeEmailTemplateList(conn, session);
					msg="ok";
				}
				//**********************************************
				//add_email_template
				//**********************************************
				if (action.equals("add_email_template")) {
					String template_name=par1;
					 
					int res=addNewEmailTemplate(conn,session,template_name);
					if (res<0) {
						if (res==-1) {
							html="-";
							msg="nok:there is already an template named :  ("+template_name+")";
						}
						if (res==-2) {
							html="-";
							msg="nok:template cannot be added.";
						}
					}
					else {
						html="-";
						msg="ok:javascript:makeEmailTemplateList()";
					}
								
					
				}
				//**********************************************
				//update_email_template_field
				//**********************************************
				if (action.equals("update_email_template_field")) {
					String group_id=par1;
					String field_name=par2;
					String field_value=par3; 
					 
					updateTableField(conn,session,"mad_email_template",group_id, field_name, field_value);
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//delete_email_template
				//**********************************************
				if (action.equals("delete_email_template")) {
					String email_template_id=par1;
					 
					String err_msg=deleteEmailTemplate(conn,session,email_template_id);
					
					if (err_msg.length()==0) {
						html="-";
						msg="ok:javascript:makeEmailTemplateList()";
					}
					else {
						html="-";
						msg="nok:"+err_msg;
					}
					
								
					
				}
				//**********************************************
				//make_database_list
				//**********************************************
				if (action.equals("make_database_list")) {
					html=makeDatabaseList(conn, session);
					msg="ok";
				}
				//**********************************************
				//add_database
				//**********************************************
				if (action.equals("add_database")) {
					String database_name=par1;

					addDatabase(conn,session,database_name);
					
					html="-";
					msg="ok:javascript:makeDatabaseList()";			
					
				}
				//**********************************************
				//make_database_editor
				//**********************************************
				if (action.equals("make_database_editor")) {
					String database_id=par1;
					
					html=makeDatabaseEditor(conn, session, database_id);
					msg="ok";
				}
				//**********************************************
				//update_database_field
				//**********************************************
				if (action.equals("update_database_field")) {
					String database_id=par1;
					String field_name=par2;
					String field_value=par3; 
					 
					updateTableField(conn,session,"tdm_envs",database_id, field_name, field_value);
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//remove_database
				//**********************************************
				if (action.equals("remove_database")) {
					String target_id=par1;

					boolean is_ok=deleteDatabase(conn,session,target_id); 
					
					if (is_ok) {
						html="-"; 
						msg="ok:javascript:makeDatabaseList()";		
					} else {
						html="-"; 
						msg="nok:Database is used or can't be removed.";	
					}
						
					
				}
				//**********************************************
				//test_connection_by_db_id
				//**********************************************
				if (action.equals("test_connection_by_db_id")) {
					
					String db_id=par1;
					
					StringBuilder errmsg=new StringBuilder();
					
					boolean test_ok=testConnectionByDbId(conn,session,db_id, errmsg);
					
					
					
					if (test_ok) {
						html="<strong><font color=green>Connection is successfull :)</font></strong>";
						msg="ok";
					}	
					else {
						html="<strong><font color=red>Connection Failed !</font></strong> : "+errmsg.toString();
						msg="ok";
					}
					
				}	
				//**********************************************
				//make_method_list
				//**********************************************
				if (action.equals("make_method_list")) {
					html=makeMethodList(conn, session);
					msg="ok";
				}
				//**********************************************
				//make_mad_method_editor
				//**********************************************
				if (action.equals("make_method_editor")) {
					String method_id=par1;
					
					html=makeMethodEditor(conn, session, method_id); 
					msg="ok";
				}
				//**********************************************
				//update_method_field
				//**********************************************
				if (action.equals("update_method_field")) {
					String method_id=par1;
					String field_name=par2;
					String field_value=par3; 
					 
					updateTableField(conn,session,"mad_method",method_id, field_name, field_value);
					html="-";
					msg="ok";			
					
					if (field_name.equals("parameter_count")) 
						msg="ok:javascript:makeMethodParameterEditor('"+method_id+"');";	
				}
				//**********************************************
				//add_new_method
				//**********************************************
				if (action.equals("add_new_method")) {
					String method_name=par1;
					String method_type=par2;
					 
					int res=addNewMethod(conn,session,method_name,method_type);
					
					if (res<0) {
						if (res==-1) {
							html="-";
							msg="nok:there is already an method named :  ("+method_name+")";
						}
						if (res==-2) {
							html="-";
							msg="nok:method cannot be added.";
						}
					}
					else {
						html="-";
						msg="ok:javascript:makeMethodList()";
					}
								
					
				}
				//**********************************************
				//delete_method
				//**********************************************
				if (action.equals("delete_method")) {
					String method_id=par1;
					 
					String err_msg=deleteMethod(conn,session,method_id);
					
					if (err_msg.length()==0) {
						html="-";
						msg="ok:javascript:makeMethodList()";
					}
					else {
						html="-";
						msg="nok:"+err_msg;
					}
				}
				//**********************************************
				//make_method_parameter_editor
				//**********************************************
				if (action.equals("make_method_parameter_editor")) {
					String method_id=par1;

					html=makeMethodParameterEditor(conn, session, method_id);
					msg="ok";			
				}
				//**********************************************
				//make_flow_list
				//**********************************************
				if (action.equals("make_flow_list")) {
					html=makeFlowList(conn, session);
					msg="ok";
				}
				//**********************************************
				//make_flow_editor
				//**********************************************
				if (action.equals("make_flow_editor")) {
					String flow_id=par1;
					
					html=makeFlowEditor(conn, session, flow_id); 
					msg="ok";
				}
				//**********************************************
				//add_new_flow
				//**********************************************
				if (action.equals("add_new_flow")) {
					String flow_name=par1;
					 
					int res=addNewFlow(conn,session,flow_name);
					if (res<0) {
						if (res==-1) {
							html="-";
							msg="nok:there is already an flow named :  ("+flow_name+")";
						}
						if (res==-2) {
							html="-";
							msg="nok:flow cannot be added.";
						}
					}
					else {
						html="-";
						msg="ok:javascript:makeFlowList()";
					}
				}
				//**********************************************
				//test_method
				//**********************************************
				if (action.equals("test_method")) {
					String method_id=par1;
					String action_method_id=par2;
					
					html=testMethod(conn,session, method_id, action_method_id);
					msg="ok";	
				}
				//**********************************************
				//execute_method
				//**********************************************
				if (action.equals("execute_method")) {
					String test_method_id=par1;
					String test_action_method_id=par2;
					String parameters=par3;
					
					 
					html=executeMethod(conn,session, test_method_id, test_action_method_id, parameters); 
					msg="ok:javascript:getLastExecuteMethodLogs()";	
				}
				//**********************************************
				//get_last_execute_method_logs
				//**********************************************
				if (action.equals("get_last_execute_method_logs")) {
					
					
					html=getLastExecuteMethodLogs(conn,session);
					msg="ok";	
				}
				//**********************************************
				//update_flow_field
				//**********************************************
				if (action.equals("update_flow_field")) {
					String flow_id=par1;
					String field_name=par2;
					String field_value=par3; 
					 
					updateTableField(conn,session,"mad_flow",flow_id, field_name, field_value);
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//delete_flow
				//**********************************************
				if (action.equals("delete_flow")) {
					String flow_id=par1;
					 
					String err_msg=deleteFlow(conn,session,flow_id); 
					
					if (err_msg.length()==0) {
						html="-";
						msg="ok:javascript:makeFlowList()";
					}
					else {
						html="-";
						msg="nok:"+err_msg;
					}
				}
				//**********************************************
				//add_new_flow_state
				//**********************************************
				if (action.equals("add_new_flow_state")) {
					String flow_id=par1;
					String state_name=par2;
					 
					int res=addNewFlowState(conn,session,flow_id, state_name);
					if (res<0) {
						if (res==-1) {
							html="-";
							msg="nok:there is already an state named :  ("+state_name+")";
						}
						if (res==-2) {
							html="-";
							msg="nok:state cannot be added.";
						}
					}
					else {
						html="-";
						msg="ok:javascript:makeFlowStateList("+flow_id+")";	
					}
				}
				//**********************************************
				//make_flow_state_list
				//**********************************************
				if (action.equals("make_flow_state_list")) {
					String flow_id=par1;
					html=makeFlowStateList(conn,session,flow_id);
					msg="ok:javascript:remakeFlowDrawing('"+flow_id+"')";
				}
				
				//**********************************************
				//make_flow_state_editor
				//**********************************************
				if (action.equals("make_flow_state_editor")) {
					String flow_id=par1;
					String state_id=par2;
					
					html=makeFlowStateEditor(conn, session, flow_id, state_id);
					msg="ok";
				}
				//**********************************************
				//delete_flow_state
				//**********************************************
				if (action.equals("delete_flow_state")) {
					String flow_id=par1;
					String flow_state_id=par2;
					 
					deleteFlowState(conn,session,flow_state_id); 
					html="-";
					msg="ok:javascript:makeFlowStateList("+flow_id+")";			
					
				}
				//**********************************************
				//update_flow_state_field
				//**********************************************
				if (action.equals("update_flow_state_field")) {
					String state_id=par1;
					String field_name=par2;
					String field_value=par3; 
					 
					updateTableField(conn,session,"mad_flow_state",state_id, field_name, field_value);
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//add_remove_state_edit_permission
				//**********************************************
				if (action.equals("add_remove_state_edit_permission")) {
					String flow_state_id=par1;
					String action_and_id=par2;
					String addremove="ADD";
					String permission_id="0";
					try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
					try {permission_id=action_and_id.split(":")[1];} catch(Exception e){}
					
					addRemoveStateEditPermission(conn, session, flow_state_id, addremove, permission_id); 
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//make_flow_state_action_list
				//**********************************************
				if (action.equals("make_flow_state_action_list")) {
					String flow_state_id=par1;
					html=makeFlowStateActionList(conn, session,flow_state_id);
					msg="ok";
				}
				//**********************************************
				//add_new_flow_state_action
				//**********************************************
				if (action.equals("add_new_flow_state_action")) {
					String flow_state_id=par1;
					String action_name=par2;
					 
					int res=addNewFlowStateAction(conn,session,flow_state_id, action_name);
					if (res<0) {
						if (res==-1) {
							html="-";
							msg="nok:there is already an action named :  ("+action_name+")";
						}
						if (res==-2) {
							html="-";
							msg="nok:action cannot be added.";
						}
					}
					else {
						html="-";
						msg="ok:javascript:makeFlowStateActionList("+flow_state_id+")";
					}
				}
				//**********************************************
				//delete_flow_state_action
				//**********************************************
				if (action.equals("delete_flow_state_action")) {
					String action_id=par1;
					String flow_state_id=par2;
					 
					deleteFlowStateAction(conn,session,action_id);
					html="-";
					msg="ok:javascript:makeFlowStateActionList('"+flow_state_id+"')";			
					
				}
				//**********************************************
				//update_flow_state_action_field
				//**********************************************
				if (action.equals("update_flow_state_action_field")) {
					String action_id=par1;
					String field_name=par2;
					String field_value=par3; 
					 
					updateTableField(conn,session,"mad_flow_state_action",action_id, field_name, field_value);
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//add_remove_action_permission
				//**********************************************
				if (action.equals("add_remove_action_permission")) {
					String action_id=par1;
					String action_and_id=par2;
					String addremove="ADD";
					String permission_id="0";
					try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
					try {permission_id=action_and_id.split(":")[1];} catch(Exception e){}
					
					addRemoveActionPermission(conn,session,action_id,addremove,permission_id); 
					
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//add_remove_action_group
				//**********************************************
				if (action.equals("add_remove_action_group")) {
					String flow_state_action_id=par1;
					String action_and_id=par2;
					String addremove="ADD";
					String group_id="0";
					try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
					try {group_id=action_and_id.split(":")[1];} catch(Exception e){}
					
					addRemoveActionGroup(conn,session,flow_state_action_id,addremove,group_id); 
					
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//add_new_mad_action_method
				//**********************************************
				if (action.equals("add_new_mad_action_method")) {
					String action_id=par1;
					String method_id=par2;
					 
					int res=addNewMadActionMethod(conn,session, action_id,method_id);
					if (res<0) {
						
						if (res==-2) {
							html="-";
							msg="nok:method cannot be added.";
						}
					}
					else {
						html="-";
						msg="ok:javascript:makeMadActionMethodList('"+action_id+"')";
					}
				}
				
				//**********************************************
				//make_flow_state_action_method_list
				//**********************************************
				if (action.equals("make_flow_state_action_method_list")) {
					String action_id=par1;
				
					html=makeFlowStateActionMethodList(conn,session,action_id);
					msg="ok";
					
				}
				//**********************************************
				//reorder_flow_state_action_method
				//**********************************************
				if (action.equals("reorder_flow_state_action_method")) {
					String action_id=par1;
					String execution_order=par2;
					String direction=par3;
					 
					
					
					
					reorderFlowStateActionMethod(conn,session, action_id, execution_order, direction);
					
					html="-";
					msg="ok:javascript:makeActionMethodList('"+action_id+"')";
					
				}
				//**********************************************
				//delete_flow_state_action_method
				//**********************************************
				if (action.equals("delete_flow_state_action_method")) {
					String action_id=par1;
					String action_method_id=par2;
					 
					deleteFlowStateActionMethod(conn,session,action_method_id);
					html="-";
					msg="ok:javascript:makeActionMethodList('"+action_id+"')";			
					
				}
				//**********************************************
				//make_flow_state_action_method_parameter_editor
				//**********************************************
				if (action.equals("make_flow_state_action_method_parameter_editor")) {
					String action_method_id=par1;
					 				
					html=setMadFlowStateActionMethodParameters(conn,session, action_method_id);
					msg="ok";
					
				}
				//**********************************************
				//update_action_method_field
				//**********************************************
				if (action.equals("update_action_method_field")) {
					String action_method_id=par1;
					String field_name=par2;
					String field_value=par3; 
					
					 
					updateTableField(conn,session,"mad_flow_state_action_methods",action_method_id, field_name, field_value);
					html="-";
					msg="ok";			
					
				}
				
				//**********************************************
				//duplicate_flow
				//**********************************************
				if (action.equals("duplicate_flow")) {
					String flow_id=par1;
					
					 
					duplicateFlow(conn,session,flow_id);
					html="-";
					msg="ok:javascript:makeFlowList()";
					
				}
				//**********************************************
				//fiil_set_test_parameters_box
				//**********************************************
				if (action.equals("fiil_set_test_parameters_box")) {
					String test_id=par1;
					
					 				
					html=makeSetTestParameterForm(conn,session,test_id);
					msg="ok";
					
				}
				
				//**********************************************
				//save_tree_node
				//**********************************************
				if (action.equals("save_tree_node")) {
					String tree_id=par1;
					String flexFormContent=par2;
					
					StringBuilder cherr=new StringBuilder();
					
					boolean is_ok=saveTreeNodeDO(conn, session,tree_id,flexFormContent,cherr);
					
					
					if (!is_ok) {
						html="-"; 
						msg="ok:javascript:hideWaitingModal(); setActiveTree('"+tree_id+"'); myalert('"+clearHtml(cherr.toString())+"'); ";
					}
					else {
						html="-";
						msg="ok:javascript:hideWaitingModal(); setActiveTree('"+tree_id+"'); ";
					}
				
			
				}
				//**********************************************
				//add_test_parameter
				//**********************************************
				if (action.equals("add_test_parameter")) {
					String test_id=par1;
					String direction=par2;
					
					 
					addTestParameter(conn,session,test_id,direction); 
					html="-";
					msg="ok:javascript:showTestParameter('"+test_id+"')";
					
				}
				//**********************************************
				//remove_test_parameter
				//**********************************************
				if (action.equals("remove_test_parameter")) {
					String test_id=par1;
					String parameter_id=par2;
					

					StringBuilder err=new StringBuilder();
										
					removeTestParameterDO(conn, session,test_id, parameter_id,  err); 
					
					if (err.length()>0) {
						html="-"; 
						msg="ok:javascript:myalert('"+err.toString()+"')";
					}
					else {
						html="-";
						msg="ok:javascript:showTestParameter('"+test_id+"');  ";
					}
				
			
				}
				
				//**********************************************
				//update_test_parameter_field
				//**********************************************
				if (action.equals("update_test_parameter_field")) {
					String group_id=par1;
					String field_name=par2;
					String field_value=par3; 

					updateTableField(conn,session,"tdm_test_tree_parameters",group_id, field_name, field_value, "LONG");
					html="-";
					msg="ok";			
					
				}
				//**********************************************
				//make_form_list
				//**********************************************
				if (action.equals("make_form_list")) {
					html=makeFormList(conn,session); 
					msg="ok";
					
				}
				//**********************************************
				//set_form_fields_filter
				//**********************************************
				if (action.equals("set_form_fields_filter")) {
					String module=par1;
					String domain=par2;
					String tree_type=par3;
					String field=par4;
					
					session.setAttribute("form_module", module);
					session.setAttribute("form_domain", domain);
					session.setAttribute("form_tree_type", tree_type);
					session.setAttribute("form_field", field);
					
					
					html="-"; 
					msg="ok:javascript:listFormFields()";
					
				}
				
				//**********************************************
				//list_form_fields
				//**********************************************
				if (action.equals("list_form_fields")) {
					html=makeListFormFields(conn,session); 
					msg="ok";
					
				}
				
				//**********************************************
				//make_add_new_form_field_form
				//**********************************************
				if (action.equals("make_add_new_form_field_form")) {
					html=makeAddNewFormFieldForm(conn,session);  
					msg="ok";
					
				}
				
				//**********************************************
				//add_new_form_field
				//**********************************************
				if (action.equals("add_new_form_field")) {
					
					String module=par1;
					String domain=par2;
					String tree_type=par3;
					String field=par4;
					

					StringBuilder err=new StringBuilder();
										
					addNewFormFieldDO(conn,session,module,domain,tree_type,field, err); 
					
					if (err.length()>0) {
						html="-"; 
						msg="ok:javascript:myalert('"+err.toString()+"')";
					}
					else {
						html="-";
						msg="ok:javascript:closeAddNewFieldModal(); listFormFields(); ";
					}
				
					
				}
				//**********************************************
				//remove_form_field
				//**********************************************
				if (action.equals("remove_form_field")) {
					String form_field_id=par1;
					removeFormField(conn,session,form_field_id);

					html="-";
					msg="ok:javascript:listFormFields(); ";
				}
				
				//**********************************************
				//reorder_form_field
				//**********************************************
				if (action.equals("reorder_form_field")) {
					String tree_id=par1;
					String group_vals=par2;
					String p_direction=par3;
					
					String table_name="tdm_test_tree_fields";
					String table_pk_id_val=tree_id;
					String table_pk_bind_type="LONG";
					String direction=p_direction;
					String group_field_names="module|::|domain_id|::|tree_type";
					String group_field_bind_types="STRING|::|INTEGER|::|STRING";
					String group_field_values=group_vals;
					String order_field_name="order_by";
					
					reorderTableOrderByGroup(conn, session, table_name, table_pk_id_val, table_pk_bind_type, direction, group_field_names, group_field_bind_types, group_field_values, order_field_name); 


					html="-";
					msg="ok:javascript:listFormFields(); ";
			
				}
				
				//**********************************************
				//make_tree_picker_window
				//**********************************************
				if (action.equals("make_tree_picker_window")) {
					String module=par1;
					String domain=par2;
					String element_id=par3;
					String curr_tree_id=par4;
					
					
					
					html=makeTreeNodePickerWindow(conn,session,module, domain, element_id, curr_tree_id);   
					msg="ok";
					
				}
				
				//**********************************************
				//expand_tree_picker_node
				//**********************************************
				if (action.equals("expand_tree_picker_node")) {
					String module=par1;
					String domain=par2;
					String element_id=par3;
					String curr_tree_id=par4;
					String clicked_tree_id=par5;
					
					session.setAttribute("is_node_expanded_"+module+"_"+domain+"_"+element_id+"_"+clicked_tree_id,true);
					
					html=getNodePickerList(conn,session,module,domain,element_id,curr_tree_id,clicked_tree_id);   
					msg="ok";
					
				}
				
				//**********************************************
				//collapse_tree_picker_node
				//**********************************************
				if (action.equals("collapse_tree_picker_node")) {
					String module=par1;
					String domain=par2;
					String element_id=par3;
					String clicked_tree_id=par4;

					
					session.removeAttribute("is_node_expanded_"+module+"_"+domain+"_"+element_id+"_"+clicked_tree_id); 
					
					html="-";   
					msg="ok";
					
				}
				
				//**********************************************
				//list_picker_elements
				//**********************************************
				if (action.equals("list_picker_elements")) {
					String module=par1;
					String domain=par2;
					String element_id=par3;
					String clicked_tree_id=par4;
					String search_options=par5;
					
					String include_sub_tree="YES";
					String text_to_search="";
					
					try{include_sub_tree=search_options.split(":")[0];} catch(Exception e) {}
					try{text_to_search=search_options.split(":")[1];} catch(Exception e) {}
					if (text_to_search.length()>0) text_to_search=decrypt(text_to_search);
					
					
					html=listPickerElements(conn, session, module, domain, element_id, clicked_tree_id,text_to_search, include_sub_tree);  
					msg="ok";
					
				}
				
				
				
				
				//**********************************************
				//make_tree_node_picker_area
				//**********************************************
				if (action.equals("make_tree_node_picker_area")) {
					
					String element_id=par1;
					String picked_node_id=par2;

					html=maketreeNodePickerSelection(conn,session,element_id,picked_node_id);   
					msg="ok";
					
				}
				
				//**********************************************
				//fiil_link_tree_node_box
				//**********************************************
				if (action.equals("fiil_link_tree_node_box")) {
					String tree_id=par1;
					String module=par2;
					String linked_node_id=par3;
					
					boolean is_checkin_available=isCheckinAvailable(conn, session, tree_id);
					
					
					if (is_checkin_available) {
						html=makeLinkTreeNodeBox(conn, session,tree_id, module, linked_node_id);   
						msg="ok";
					} else {
						html="Not Checked out!";
						msg="ok ";
					}
					
					
				}
				
				
				//**********************************************
				//link_tree_node
				//**********************************************
				if (action.equals("link_tree_node")) {
					String tree_id=par1;
					String module=par2;
					String linked_tree_id=par3;
					
					
					StringBuilder errmsg=new StringBuilder();
					boolean is_linked=linkTreeNodes(conn,session,tree_id,module,linked_tree_id,errmsg); 

					if (is_linked) {
						html="-";   
						msg="ok:javascript:makeTreeContentLinkList('"+tree_id+"','"+module+"')";
					}
					else {
						html="-"; 
						msg="ok:javascript:myalert('"+errmsg.toString()+"')";
					}
					
					
				}
				//**********************************************
				//link_tree_node
				//**********************************************
				if (action.equals("unlink_tree_node")) {
					String tree_id=par1;
					String module=par2;
					String linked_tree_id=par3;
					
					
					unlinkTreeNodes(conn,session,tree_id,linked_tree_id); 

					html="-";   
					msg="ok:javascript:makeTreeContentLinkList('"+tree_id+"','"+module+"')";
					
					
				}
				//**********************************************
				//make_tree_content_link_list
				//**********************************************
				if (action.equals("make_tree_content_link_list")) {
					
					String node_id=par1;
					String module=par2;

					String is_editable="NO";
					if (isCheckinAvailable(conn, session, node_id)) is_editable="YES";
					

					
					html=makeTreeContentLinkList(conn,session,node_id,module,is_editable);   
					msg="ok";
					
				}
				
				//**********************************************
				//set_active_test_details_tab_id
				//**********************************************
				if (action.equals("set_active_test_details_tab_id")) {
					String active_id=par1;
					
					setActiveTestDetailsTabId(conn,session,active_id);  
					
					html="-";   
					msg="ok";
					
				}
				
				//**********************************************
				//add_new_organization_group
				//**********************************************
				if (action.equals("add_new_organization_group")) {
					String tree_id=par1;
					String group_id=par2;
					
					addNewOrganizationGroupDO(conn,session,tree_id,group_id);  
					
					html="-";   
					msg="ok:javascript:makeOrganizationGroupList('"+tree_id+"')";
					
				}
				//**********************************************
				//remove_organization_group
				//**********************************************
				if (action.equals("remove_organization_group")) {
					String tree_id=par1;
					String group_id=par2;
					
					removeOrganizationGrou(conn,session,tree_id,group_id);  
					
					html="-";   
					msg="ok:javascript:makeOrganizationGroupList('"+tree_id+"')";
					
				}
				//**********************************************
				//make_organization_group_list
				//**********************************************
				if (action.equals("make_organization_group_list")) {
					String tree_id=par1;
					
					String is_editable="NO";
					if (isCheckinAvailable(conn, session, tree_id)) is_editable="YES";
					
					
					html=makeOrganizationGroupList(conn,session,tree_id,is_editable);  ;   
					msg="ok";
					
				}
				
				//**********************************************
				//make_domain_list
				//**********************************************
				if (action.equals("make_domain_list")) {
					html=makeDomainList(conn, session); 
					msg="ok";
				}
				//**********************************************
				//add_new_domain
				//**********************************************
				if (action.equals("add_new_domain")) {
					String domain_name=par1;
					
					 
					int res=addNewDomain(conn,session,domain_name); 
					if (res<0) {
						
						if (res==-1) {
							html="-";
							msg="nok:there is already a domain named :  ("+domain_name+")";
						}
						
						if (res==-2) {
							html="-";
							msg="nok:domain cannot be added.";
						}
						
					}
					else {
						html="-";
						msg="ok:javascript:makeDomainList()";
					}
				}
				//**********************************************
				//update_domain_field
				//**********************************************
				if (action.equals("update_domain_field")) {
					String domain_id=par1;
					String field_name=par2;
					String field_value=par3;
					 
					updateTableField(conn,session,"tdm_test_domain",domain_id, field_name, field_value); 
					html="-";
					msg="ok";			
					
				}
				
				
				
				/////////////////////////////////////////////////
				/////////////////////////////////////////////////
				/////////////////////////////////////////////////
				/////////////////////////////////////////////////
				/////////////////////////////////////////////////
				/////////////////////////////////////////////////
				/////////////////////////////////////////////////
				
				
				
				
				htmlArr.add(html);
				divArr.add(div); 
				
				if (action.length()>0) {
					obj.put("html"+(a+1), htmlArr.get(a));
					obj.put("div"+(a+1), divArr.get(a));	
					
					long duration=System.currentTimeMillis()-start_ts;
				}
				
				
				
				html="";
				div="";
		
		} // if (msg.indexOf("nok:")==-1) 
	} //for (int a=0;a<arr_action.length;a++
	
	
	obj.put("msg", msg);

} 
	
catch(Exception e) {
	e.printStackTrace();
}
finally {
	
	try {
		
		
		if( conn!=null) {conn.close();conn=null;}
		} catch(Exception e) { e.printStackTrace(); }
	} 
 


		
try{ out.print(obj);   out.flush();} catch(IOException e) {	e.printStackTrace();  } 

%>

