<%@page import="org.apache.http.HttpRequest"%>
<%@include file="header2.jsp"%> 

 
<% 

String checktimeout=(String) session.getAttribute("username");

if (checktimeout==null) 
	response.sendRedirect("default2.jsp?logout=YES");



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
				html="";
			}
		
			String session_username=nvl((String) session.getAttribute("username"),"");
			if (session_username.length()==0) {
				msg="nok:Sesssion has been expired!";
				html="javascript:windows.location.href='default2.jsp';";
			}
			
		}
		

		long start_ts=System.currentTimeMillis();
		
		html="";
		//msg="";
		

		if (msg.indexOf("nok:")==-1) {	

			
			
				
			
			//**********************************************
			//clear_div
			//**********************************************
			if (action.equals("clear_div")) {
					
					html="<p></p>";
					msg="ok";
					divArr.add(div);
					htmlArr.add(html);	
			}	
			
			//**********************************************
			//run_javascript
			//**********************************************
			if (action.equals("run_javascript")) {
					String javascript_code=par1;		
					html="javascript:"+javascript_code;
					System.out.println(html);
					msg="ok";	
			}		
			
			
			
			//**********************************************
			//set_process_status
			//**********************************************
			if (action.equals("set_process_status")) {
				
				String ptype=par1;
				String pid=par2;
				String paction=par3;
				
				setProcessStatus(conn, session, ptype, pid, paction);
					
				html="javascript:fillProcessSummary()";			  			
				msg="ok";
			
				
			}
			
			
			
			//**********************************************
			//change_process_limit
			//**********************************************
			if (action.equals("change_process_limit")) {
				String limit_type=par1;
				String wpid=par2;
				String limit=par3;
				
				
				
				
				sql="update tdm_work_plan set worker_limit=? ";
				if (limit_type.equals("master")) sql="update tdm_work_plan set master_limit=? ";
				
				sql=sql + "where id=?";
				
				try {
					int limit_INT=Integer.parseInt(limit);
					
					
					bindlist=new ArrayList<String[]>();
					bindlist.add(new String[]{"INTEGER", ""+limit_INT});
					bindlist.add(new String[]{"INTEGER", wpid});
					execDBConf(conn, sql, bindlist);
				} catch(Exception e) {
					e.printStackTrace();
				}
				
				html="";
				msg="ok";
			}
			
			//**********************************************
			//set_work_plan_status
			//**********************************************
			if (action.equals("set_work_plan_status")) {

				String wpid=par1;
				String status=par2;
				String update_sql="";
				
				//---------------------------------------------------------------
				if (status.equals("CANCEL")) {
					bindlist.add(new String[]{"INTEGER",wpid});
					
					update_sql="delete from tdm_task_assignment where work_plan_id=?";
					execDBConf(conn, update_sql,bindlist);
					
					update_sql="delete from tdm_task_summary where work_plan_id=?";
					execDBConf(conn, update_sql,bindlist);

					update_sql="update tdm_work_plan set status='CANCELLED',end_date=now() where id=?";
					execDBConf(conn, update_sql,bindlist);
				}
				
				//---------------------------------------------------------------
				if (status.equals("PAUSE")) {
					update_sql="update tdm_work_plan set status='PAUSED' where id=?";

					bindlist.add(new String[]{"INTEGER",""+wpid});
					execDBConf(conn, update_sql, bindlist);
				}
				
				//---------------------------------------------------------------
				if (status.equals("RESUME")) {
					update_sql="update tdm_work_plan set status='RUNNING' where id=?";
					
					bindlist.add(new String[]{"INTEGER",""+wpid});
					execDBConf(conn, update_sql, bindlist);
				}
				
				//---------------------------------------------------------------
				if (status.equals("REPLAY")) {
					ArrayList<String[]> currWpcArr=getWpcListByWorkPlan(conn,wpid,"");
					
					if (currWpcArr.size()<=100) // otherwise, master will be removind unused task tables
					for (int w=0;w<currWpcArr.size();w++) {
						String current_work_package_id=currWpcArr.get(w)[0];
						update_sql="drop table tdm_task_"+wpid+"_" + current_work_package_id;
						execDBConf(conn, update_sql,bindlist);
					}
					
					
					bindlist.add(new String[]{"INTEGER",wpid});
					
					update_sql="delete from tdm_work_package where work_plan_id=?";
					execDBConf(conn, update_sql,bindlist);
					
					update_sql="update tdm_work_plan set status='NEW', run_type='ACTUAL:ACCURACY', start_date=now(), end_date=null where id=?";
					execDBConf(conn, update_sql, bindlist);
				}

				//---------------------------------------------------------------
				if (status.equals("ROLLBACK")) {
					ArrayList<String[]> currWpcArr=getWpcListByWorkPlan(conn,wpid,"");
					
					for (int w=0;w<currWpcArr.size();w++) {
						String current_work_package_id=currWpcArr.get(w)[0];
							
						update_sql="update tdm_task_"+wpid + "_" + current_work_package_id + " set status='NEWxxx', retry_count=0 where status='NEW'";
						execDBConf(conn, update_sql,bindlist);
						
						
						update_sql="update tdm_task_"+wpid + "_" + current_work_package_id + " set status='NEW', retry_count=0 where status!='NEWxxx'";
						execDBConf(conn, update_sql,bindlist);
						
						update_sql="update tdm_task_"+wpid + "_" + current_work_package_id + " set status='FINISHED', retry_count=0 where status='NEWxxx'";
						execDBConf(conn, update_sql,bindlist);
					}
					
					bindlist.add(new String[]{"INTEGER",wpid});

					
					update_sql="update tdm_work_plan set run_type='TEST:ACCURACY' where id=?";
					execDBConf(conn, update_sql,bindlist);
					
					update_sql="update tdm_work_package set status='NEWxxx' where work_plan_id=? and status='NEW'";
					execDBConf(conn, update_sql,bindlist);
					
					update_sql="update tdm_work_package set status='MASKING' where work_plan_id=? and status!='NEWxxx'";
					execDBConf(conn, update_sql,bindlist);

					update_sql="update tdm_work_package set status='FINISHED' where work_plan_id=? and status='NEWxxx'";
					execDBConf(conn, update_sql,bindlist);
					
					update_sql="delete from tdm_task_summary  where work_plan_id=? ";
					execDBConf(conn, update_sql,bindlist);
					
					update_sql="update tdm_worker set cancel_flag='YES'";
					execDBConf(conn, update_sql,new ArrayList<String[]>());
					
					update_sql="update tdm_work_plan set status='RUNNING',start_date=now(), end_date=null where id=?";
					execDBConf(conn, update_sql,bindlist);
				}

				//---------------------------------------------------------------
				if (status.equals("PURGE")) {
				
					
					sql="select count(*) from  " +
						"	(  " +
						"			select work_plan_id from tdm_work_package   " +
						"			where master_id in(select id from tdm_master where status='BUSY')  " +
						"			union all  " +
						"			select work_plan_id from tdm_task_assignment   " +
						"			where worker_id in (select id from tdm_worker where status='BUSY')  " +
						"		) a  " +
						"		where work_plan_id="+wpid;
					
					String busyprocesscount=getDBSingleVal(conn, sql);
					
					if (busyprocesscount.equals("0"))  {
						ArrayList<String[]> currWpcArr=getWpcListByWorkPlan(conn,wpid,"");
						
						if (currWpcArr.size()<=100) // otherwise, master will be removind unused task tables
						for (int w=0;w<currWpcArr.size();w++) {
							String current_work_package_id=currWpcArr.get(w)[0];
							update_sql="drop table tdm_task_" +wpid+"_"+current_work_package_id;
							execDBConf(conn, update_sql,bindlist);
						}
						
						
						bindlist.add(new String[]{"INTEGER",wpid});

						update_sql="delete from tdm_task_assignment where work_plan_id=?";
						execDBConf(conn, update_sql,bindlist);

						update_sql="delete from tdm_task_summary where work_plan_id=?";
						execDBConf(conn, update_sql,bindlist);

						update_sql="delete from tdm_work_package where work_plan_id=?";
						execDBConf(conn, update_sql,bindlist);
						
						
						update_sql="delete from mad_request_work_package where work_plan_id=?";
						execDBConf(conn, update_sql,bindlist);
						
						update_sql="delete from mad_request_work_plan where work_plan_id=?";
						execDBConf(conn, update_sql,bindlist);
						
						
						update_sql="delete from tdm_work_plan_dependency where work_plan_id=?";
						execDBConf(conn, update_sql,bindlist);

						update_sql="delete from tdm_work_plan where id=?";
						execDBConf(conn, update_sql,bindlist);
						
						update_sql="delete from tdm_discovery_rel where discovery_id=?";
						execDBConf(conn, update_sql,bindlist);
						
						update_sql="delete from tdm_discovery_result where discovery_id=?";
						execDBConf(conn, update_sql,bindlist);
					}
					
				}
				
				
				
				//------------------------------------------------------------------------------------
				if (status.indexOf("REPEAT:")==0) {
					String retry_failed_work_plan_id=wpid;
					String retry_failed_status=status.split(":")[1];
					
					ArrayList<String[]> currWpcArr=getWpcListByWorkPlan(conn,retry_failed_work_plan_id,"");
					
					if (!retry_failed_work_plan_id.equals("0") && !retry_failed_status.equals("0")) {
						

						for (int w=0;w<currWpcArr.size();w++) {
							String current_work_package_id=currWpcArr.get(w)[0];
							sql="select  distinct work_package_id " + 
								" from tdm_task_"+ retry_failed_work_plan_id + "_" + current_work_package_id+
								" where fail_count>0";
							
							ArrayList<String[]> retry_wpc_arr=getDbArrayConf(conn, sql, 1, bindlist);
							
							System.out.println("xxx" + retry_wpc_arr.size());
							
							if (retry_wpc_arr.size()>0) {
								
								update_sql="update tdm_task_" + retry_failed_work_plan_id + "_" + current_work_package_id + 
										" set status='NEW', start_date=null, end_date=null, " +
										" duration=null, success_count=0, fail_count=0, done_count=0," + 
										" log_info_zipped=null, err_info_zipped=null, retry_count=0" +
										" where fail_count>0 ";
										
								if (!retry_failed_status.equals("ALL")) {
									update_sql=update_sql + " and status='" +retry_failed_status+ "'  ";
								}
								
							execDBConf(conn, update_sql, bindlist);
							
							
							update_sql="update tdm_work_package set status='MASKING'  where id="+current_work_package_id;
							System.out.println(update_sql);
							execDBConf(conn, update_sql, bindlist);
								
							} //if (retry_wpc_arr.size()>0) {
						}
						

						update_sql="update tdm_work_plan set status='RUNNING' where id=" + retry_failed_work_plan_id;
						System.out.println(update_sql);
						execDBConf(conn, update_sql, bindlist);
						
						
						update_sql="";
						
						//response.sendRedirect("monitoring.jsp?ListALL=YES");
					}
				}
				
				html="";
				
				msg="ok";
			}
			}
			//**********************************************
			//get_wp_detail_list
			//**********************************************
			if (action.equals("get_wp_detail_list")) {
				
				String work_plan_id=par1;
				String tab_name="tdm_"+par2;
				String status=par3;
				String only_failed=par4;
				String a_filter=par5;
			

				html=printMonitoringDetails(conn, work_plan_id, tab_name, status, only_failed, a_filter);
				msg="ok";
			}

			//**********************************************
			//get_long_detail
			//**********************************************
			if (action.equals("get_long_detail")) {
				
				String wpid=par1;
				String rec_type=par2;
				String rec_id=par3;
				String field=par4;
				
				
				
				String env_id=getDBSingleVal(conn,"select env_id from tdm_work_plan where id="+wpid);
				String wplan_type=getDBSingleVal(conn,"select wplan_type from tdm_work_plan where id="+wpid);

				html=printLongDet2(conn,wplan_type, env_id,rec_id,rec_type,field);
				msg="ok";
			}
			
			
			//**********************************************
			//show_invalid_msg
			//**********************************************
			if (action.equals("show_invalid_msg")) {
				
				String wpid=par1;
				html="";
				sql="select invalid_message from tdm_work_plan where id="+wpid;
				String invalid_msg=getDBSingleVal(conn, sql);
				
				invalid_msg=invalid_msg.replaceAll("\n", "<br>");
				
				msg="nok:"+invalid_msg;

			}
			
			//**********************************************
			//show_warning_msg
			//**********************************************
			if (action.equals("show_warning_msg")) {
				
				String wpid=par1;
				html="";
				sql="select warning_message from tdm_work_plan where id="+wpid;
				String invalid_msg=getDBSingleVal(conn, sql);
				
				invalid_msg=invalid_msg.replaceAll("\n", "<br>");
				
				msg="nok:"+invalid_msg;

			}
			
			
			//**********************************************
			//skip_validation
			//**********************************************
			if (action.equals("skip_validation")) {
				
				String wpid=par1;
				html="";
				sql="update tdm_work_plan set invalid_message=null, status='COMPLETED' where id="+wpid;

				execDBConf(conn, sql, new ArrayList<String[]>());
				msg="ok:javascript:fillWorkPlanSummary()";

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
			//make_request_type_picker
			//**********************************************
			if (action.equals("make_request_type_picker")) {
			String request_group=par1;
			html=makeMadRequestTypePicker(conn, session,request_group);
			msg="ok";
			
			}
			
			//**********************************************
			//create_new_request
			//**********************************************
			if (action.equals("create_new_request")) {
			String request_type_id=par1;
			String request_group=par2;
			String main_request_id=par3;
			
			String request_id=makeNewMadRequest(conn, session,request_group, request_type_id, main_request_id);
			
			if (request_id.equals("0")) {
				html="-";
				msg="nok:Request can not be created.";
				
			} else if (request_id.equals("-1")) {
				html="-";
				msg="nok:No permission for this request type.";
				
			} else {
				
				html="-";
				msg="ok:javascript:openRequest('"+request_id+"','"+request_group+"','')";
				
				
			}
			 
			
			}
			
			
			//**********************************************
			//remove_sub_request
			//**********************************************
			if (action.equals("remove_sub_request")) {
			String main_request_id=par1; 
			String sub_request_id=par2; 
			String tab_request_type_id=par3; 
			
			removeSubRequest(conn, session, sub_request_id); 
			html="-";
			msg="ok:javascript:reloadRequestTableContent(\""+main_request_id+"\",\""+tab_request_type_id+"\");";
			
			
			}
			
			//**********************************************
			//make_request_table_content
			//**********************************************
			if (action.equals("make_request_table_content")) {
			String main_request_id=par1; 
			String tab_request_type_id=par2; 
			 
			html=makeTableFieldContent(conn, session, main_request_id, tab_request_type_id, "EDITABLE");
			msg="ok";
			
			}
			
			//**********************************************
			//open_mad_request
			//**********************************************
			if (action.equals("open_mad_request")) {
				String request_id=par1;
				String request_group=par2;
				
				if (request_group.length()==0) 
					request_group=getRequestGroup(conn,session,request_id);
				

				html=formMakerForRequest(conn, session, request_group, request_id); 
				msg="ok:javascript:makeEntryList(\""+request_id+"\");";

				//indexRequestSearchText(conn, session, request_id);
				 
			} 
			
			//**********************************************
			//remove_request
			//**********************************************
			if (action.equals("remove_request")) {
				String request_id=par1;
				int ret1=removeMadRequest(conn, session,request_id);
				if (ret1<0) {
					html="-";
					msg="nok:This request cannot be removed.";
				}
				else {
					html="-";
					msg="ok";	
				}
				
			} 
			
			
			//**********************************************
			//load_deployment_header
			//**********************************************
			if (action.equals("load_deployment_header")) {
				html=loadDeploymentHeader(conn, session);
				msg="ok";
			}
			//**********************************************
			//load_mad_queries
			//**********************************************
			if (action.equals("load_mad_queries")) {
				html=loadMadQueries(conn, session);
				msg="ok";
			}  
			//**********************************************
			//set_mad_query
			//**********************************************
			if (action.equals("set_mad_query")) {
				String query_id=par1;
				String state=par2;

				setMadQuery(session, query_id, state);
				html="-";
				msg="ok:javascript:reloadRequestList(\"NO\")";
			}
			//**********************************************
			//set_mad_waiting_action_query
			//**********************************************
			if (action.equals("set_mad_waiting_action_query")) {

				clearMadSearchAllFilters(session,"FILTER");
				clearFlexFieldFilters(session,"FILTER");
				
				session.setAttribute("MAD_QUERY_WAITING_MY_ACTION", "SET"); 
				
				html="-";
				msg="ok";
			}
			//**********************************************
			//unset_mad_waiting_action_query
			//**********************************************
			if (action.equals("unset_mad_waiting_action_query")) {

				session.setAttribute("MAD_QUERY_WAITING_MY_ACTION", "UNSET"); 
				html="-";
				msg="ok:javascript:reloadRequestList(\"NO\")";
			}
			//**********************************************
			//get_MAD_Warnings
			//**********************************************
			if (action.equals("get_MAD_Warnings")) {
				html=getMADWarning(conn, session);
				msg="ok";
			} 
			
			//**********************************************
			//initialize_repo_folder
			//**********************************************
			if (action.equals("initialize_repo_folder")) {
				String package_id=par1;
				String application_id=par2;
				html=openRepoFolder(conn, session, package_id, application_id, "", 1);
				msg="ok";
			}
			
			
			//**********************************************
			//open_repo_folder
			//**********************************************
			if (action.equals("open_repo_folder")) {
				
				String package_id=par1;
				String application_id=par2;
				String dir_to_open=par3;
				int level=Integer.parseInt(par4);
				
				System.out.println("dir_to_open : " + dir_to_open);
				
				html=openRepoFolder(conn, session, package_id, application_id, dir_to_open, level );
				msg="ok";
				
				
			}
			 
			//**********************************************
			//load_request_list
			//**********************************************
			if (action.equals("load_request_list")) {
				String list_mode=par1;
				String main_request_id=par2;
				String skip_filters=par3;
				if (!skip_filters.equals("YES")) skip_filters="NO";
				
				if (list_mode=="x") list_mode="FILTER";
				if (main_request_id=="x") main_request_id="";
				
				html=loadRequestList(conn, session, list_mode, main_request_id, skip_filters);
				msg="ok:javascript:hideWaitingModal();";
			}
			//**********************************************
			//make_entry_list
			//**********************************************
			if (action.equals("make_entry_list")) {
				
				String request_type_id=par1;
				String request_id=par2;
				
				html=makeEntryList(conn, session,request_type_id,request_id);
				msg="ok";
			}
			//**********************************************
			//set_request_footer
			//**********************************************
			if (action.equals("set_request_footer")) {
				
				String request_type_id=par1;
				String request_id=par2;
				
				html=makeRequestFooter(conn, session,request_type_id,request_id);
				msg="ok:javascript:hideWaitingModal()";
			}
			
			//**********************************************
			//send_lock_requests
			//**********************************************
			if (action.equals("send_lock_requests")) {
				
				String locking_request_ids=par1;
				sendLockRequest(conn, session,locking_request_ids);
				html="-";
				msg="ok";
			}
			
			//**********************************************
			//remove_lock
			//**********************************************
			if (action.equals("remove_lock")) {
				
				String request_id=par1;
				removeLockForRequest(conn, session,request_id);
				html="-";
				msg="ok";
			}


			
			//**********************************************
			//save_mad_request
			//**********************************************
			if (action.equals("save_mad_request")) {
				
				String request_id=par1;
				String request_type_id=par2;
				String request_description=par3;
				
				int curr_request_id=createUpdateRequest(conn, session,request_id, request_type_id,request_description);

				if (curr_request_id==-1) {
					html="-";
					msg="nok:Request could not be saved.";
				}
				else if (curr_request_id==-2) {
					html="-";
					msg="nok:Saving is not allowed.";
				}
				else {
					html="-";
					//msg="ok:javascript:setFlexFields(\"entry\",\""+curr_request_id+"\");  reloadRequestList(\"NO\"); ";
					msg="ok";
				}
				
				
				
			}
			
			//**********************************************
			//set_flex_field
			//**********************************************
			if (action.equals("set_flex_field")) {
				String request_id=par1;
				String flex_field_id=par2;
				String flex_field_value=par3;
				
				
				setFlexField(conn, session,request_id, flex_field_id,flex_field_value);
				
				html="-";
				msg="ok";
				
				
			}
			
			//**********************************************
			//show_saved_successfully_notification
			//**********************************************
			if (action.equals("show_saved_successfully_notification")) {
				String request_id=par1;
				
				indexRequestSearchText(conn, session, request_id);
				
				html="-";
				msg="ok:javascript:showMadSaveNotification(\""+request_id+"\"); setIndexRequestTimer(\""+request_id+"\"); ";
				
				
			}
			//**********************************************
			//add_remove_request_application
			//**********************************************
			if (action.equals("add_remove_request_application")) {
				
				String request_id=par1;
				String action_and_id=par2;
				String addremove="ADD";
				String application_id="0";
				try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
				try {application_id=action_and_id.split(":")[1];} catch(Exception e){}
				
				addRemoveRequestApplication(conn,session,request_id,addremove,application_id); 
				
				html="-";
				msg="ok:javascript:makeApplicationRepoConfig(\""+request_id+"\");";	
				
				
			}
			
			
			//**********************************************
			//make_application_repo_config
			//**********************************************
			if (action.equals("make_application_repo_config")) {
				String request_id=par1;
				
				boolean is_form_editable=isMadRequestFormEditable(conn, session, request_id);
				html=makeApplicationRepoConfig(conn, session, request_id, is_form_editable);
				msg="ok";

			}
			//**********************************************
			//add_item_to_application
			//**********************************************
			if (action.equals("add_item_to_application")) {
				String package_id=par1;
				String application_id=par2;
				String item_name=par3;
				String item_path=par4;
				String version=par5;
				
				int ret1=addItemToApplication(conn, session,package_id, application_id,item_name,item_path, version);
				
				if (ret1<0) {
					html="-";
					msg="ok:javascript:myalert(\"Selected artifact is already in application.\"); ";
					 
				}
				else {
					html="-";
					msg="ok";
				}
				
				
				
			}
			
			
			//**********************************************
			//remove_item_from_application
			//**********************************************
			if (action.equals("remove_item_from_application")) {
				String package_id=par1;
				String application_id=par2;
				String item_name=par3;
				String item_path=par4;
				String version=par5;
				
				int ret1=removeItemFromApplication(conn, session,package_id, application_id,item_name,item_path, version);
				
				if (ret1<0) {
					html="-";
					msg="ok:javascript:myalert(\"Selected artifact is not in the package.\"); ";
					 
				}
				else {
					html="-";
					msg="ok";
				}
				
				
				
			}
			
			
			//**********************************************
			//show_added_app_items
			//**********************************************
			if (action.equals("show_added_app_items")) {
				String package_id=par1;
				String application_id=par2;
				boolean is_form_editable=isMadRequestFormEditable(conn, session, package_id);
				html=getItemsInApplication(conn, session,package_id, application_id,is_form_editable ); 
				msg="ok";			
				
			}
			
			
			//**********************************************
			//reorder_item_of_application
			//**********************************************
			if (action.equals("reorder_item_of_application")) {
				
				
				String id1=par1;
				String id2=par2;
				
				reorderItemsInApplication(conn, session,id1, id2); 
				html="-";
				msg="ok";			
				
			}
			
			
			//**********************************************
			//link_app_environment
			//**********************************************
			if (action.equals("link_app_environment")) {
				String request_id=par1;
				String addremove=par2;
				String target=par3;
				String id=par4;
				String link_id=par5;
				linkApplicationEnvironment(conn, session, request_id, addremove, target, id, link_id);
				html="-";
				msg="ok:javascript:refreshAllRequestPackageDivs(\""+request_id+"\");";			
				
			}
			
			//**********************************************
			//make_add_package_options
			//**********************************************
			if (action.equals("make_add_package_options")) {
				String request_id=par1;
				String package_ids=par2;
				
				
				
				html=makePackageAddPackageOptions(conn,session,request_id,package_ids);
				msg="ok:javascript:refreshAllRequestPackageDivs(\""+request_id+"\"); ";			
				
			}
			
			//**********************************************
			//add_package_to_request
			//**********************************************
			if (action.equals("add_package_to_request")) {
				String request_id=par1;
				String package_ids=par2;
				String environment_id=par3;
				
				
				addPackageToRequest(conn,session,request_id,package_ids, environment_id);
				html="-";
				msg="ok:javascript: refreshAllRequestPackageDivs(\""+request_id+"\"); hideWaitingModal(); ";			
				
			}
			
			//**********************************************
			//remove_packages_from_request
			//**********************************************
			if (action.equals("remove_packages_from_request")) {
				String request_id=par1;
				String package_ids_to_remove=par2;
				String environment_id=par3;
				
				
				removePackagesFromRequest(conn,session,request_id,package_ids_to_remove, environment_id);
				html="-";
				msg="ok:javascript:refreshAllRequestPackageDivs(\""+request_id+"\"); hideWaitingModal();";			
				
			} 
			
			//**********************************************
			//write_request_app_environment_link
			//**********************************************
			if (action.equals("write_request_app_environment_link")) {
				String request_id=par1;
				

				boolean is_form_editable=isMadRequestFormEditable(conn, session, request_id);
				html=writeRequestAppEnvLink(conn,session,request_id,is_form_editable);
				msg="ok";			
				
			}
			
			//**********************************************
			//write_package_list_in_request
			//**********************************************
			if (action.equals("write_package_list_in_request")) {
				String request_id=par1;


				
				boolean is_form_editable=isMadRequestFormEditable(conn, session, request_id);
				html=writeDeploymentPackagesInRequest(conn,session,request_id, is_form_editable);
				msg="ok";			
				
			}
			
			//**********************************************
			//write_applications_in_request
			//**********************************************
			if (action.equals("write_applications_in_request")) {
				String request_id=par1;
				

				boolean is_form_editable=isMadRequestFormEditable(conn, session, request_id);
				html=writeApplicationsInRequest(conn,session,request_id, is_form_editable); 
				msg="ok";			
				
			}
			
			
			//**********************************************
			//write_deployment_list_of_request
			//**********************************************
			if (action.equals("write_deployment_list_of_request")) {
				String request_id=par1;
				

				boolean is_form_editable=isMadRequestFormEditable(conn, session, request_id);
				html=writeRequestDeploymentList(conn, session, request_id, is_form_editable);
				msg="ok";			
				
			}
			
			
			//**********************************************
			//datetimepicker_validate
			//**********************************************
			if (action.equals("datetimepicker_validate")) {
				String table_id=par1;
				String date_id=par2;
				String curr_val=par3;
				String field_mode=par4;
				String additional=par5;
				
				
				
				html=makeDateContent(table_id, date_id, curr_val, additional, field_mode); 
				if (additional.trim().length()>0)
					msg="ok:javascript:fireOnChangeDateTime(\""+table_id+"\",\""+date_id+"\"); ";	 
				else msg="ok";
				
			}
			
			
			//**********************************************
			//show_tag_picker
			//**********************************************
			if (action.equals("show_tag_picker")) {
				String application_id=par1;
				String member_id=par2; 
				String current_tag=par3; 
				String current_ver=par4; 
				String use_cache=par5;
				
			
				
				
				html=makeTagPicker(conn, application, session, application_id, member_id, current_tag, current_ver, use_cache);
				msg="ok";			
				
			}
			
			//**********************************************
			if (action.equals("set_version_info")) {
				String application_id=par1;
				String member_id=par2;
				String current_tag=par3; 
				String current_ver=par4; 
				
				//System.out.println("set_version_info "+ current_tag + "("+current_ver+")");
				
				html=getTagVersionDetail(conn, session, application_id, member_id, current_tag, current_ver);
				msg="ok";			
				
			}
			
			
			//**********************************************
			//set_tag_info
			//**********************************************
			if (action.equals("set_tag_info")) {
				String member_id=par1;
				String tag_to_set=par2; 	
				String version_to_set=par3;
				String set_all_application_items=par4; 
				
				
				sql="select request_id, application_id from mad_request_application_member where id=? ";
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",member_id});
				ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
				
				String request_id="";
				String application_id="";
				String request_group="";
				
				if (arr.size()==1) {
					request_id=arr.get(0)[0];
					application_id=arr.get(0)[1];
					
					sql="select request_group from mad_request r, mad_request_type rt where r.request_type_id=rt.id and r.id=?";
					bindlist.clear();
					bindlist.add(new String[]{"INTEGER",request_id});
					arr=getDbArrayConf(conn, sql, 1, bindlist);
					if (arr.size()==1) {
						request_group=arr.get(0)[0];
						String js_for_refresh="refreshRequestDeploymentList(\""+request_id+"\");";
						
						if (request_group.equals("PACKAGE"))
							js_for_refresh="refreshApplicationMembersInPackage(\""+request_id+"\",\""+application_id+"\")";
						
						setTagInfo(conn, session, member_id, tag_to_set, version_to_set, set_all_application_items);
						
						
						html="-";
						msg="ok:javascript:"+js_for_refresh;	
					} else {
						html="-";
						msg="nok:Request info of the member not found";
					}
					
					
					
				} else {
					html="-";
					msg="nok:Member info not found";	
				}
				
						
			}
			
			
			
			//**********************************************
			//show_mad_search_box
			//**********************************************
			if (action.equals("show_mad_search_box")) {
				
				String search_mode=par1;
				String query_id=par2;
				String main_request_id=par3;
				
				if (!nvl(query_id,"x").equals("x")) {
					clearMadSearchAllFilters(session, search_mode);
					clearFlexFieldFilters(session, search_mode);
				}
								
				html=makeMADSearchBox(conn, session, search_mode, query_id, main_request_id);
				msg="ok";			
				if (search_mode.equals("SELECT")) 
					msg="ok:javascript:setMadFiltersAndRun('LIST','','"+main_request_id+"');";
				
				
			}
			
			
			//**********************************************
			//index_request
			//**********************************************
			if (action.equals("index_request")) {
				String request_id=par1;
				
				indexRequestSearchText(conn, session, request_id);
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//search_request_by_id
			//**********************************************
			if (action.equals("search_request_by_text")) {
				String keyword=par1;
				String search_mode=par2;
				
				if (keyword.equals("${null}")) keyword=""; 
				setMadSearchFilter(session, "FILTER_KEYWORD",keyword, search_mode);
				html="-"; 
				msg="ok:javascript:reloadRequestList(\"YES\");";			
				
			}
			  
			//**********************************************
			//clear_mad_all_search_filters
			//**********************************************
			if (action.equals("clear_mad_all_search_filters")) {
				String search_mode=par1;
				clearMadSearchAllFilters(session,search_mode);

				html="-";
				msg="ok";			
				
			}
			


			//**********************************************
			//set_mad_filter
			//**********************************************
			if (action.equals("set_mad_filter")) {
				String filter_name=par1;
				String filter_val=par2;
				String search_mode=par3;
				
				
				
				if (filter_name.toLowerCase().contains("filter"))
					setMadSearchFilter(session, filter_name,filter_val, search_mode);
				html="-";
				msg="ok";			
				
			}
			
			
			//**********************************************
			//make_request_type_filter_combo
			//**********************************************
			if (action.equals("make_request_type_filter_combo")) {
				String request_group=par1;
				String search_mode=par2;
				
				setMadSearchFilter(session, "filter_request_group", request_group, search_mode);
				html=makeRequesTypeFilterCombo(conn, session, request_group,search_mode);
				msg="ok";			
				
			}
			//**********************************************
			//make_request_type_status_list
			//**********************************************
			if (action.equals("make_request_type_status_list")) {
				String request_group=par1;
				String request_type_id=par2;
				String search_mode=par3;
				
				html=makeRequesTypeStatusFilter(conn, session, request_group, request_type_id, search_mode ); 
				msg="ok";			
				
			}
			//**********************************************
			//make_request_type_flex_field_filter_list
			//********************************************** 
			if (action.equals("make_request_type_flex_field_filter_list")) {
				String request_type_id=par1;
				String search_mode=par2;
				
				setMadSearchFilter(session, "filter_request_type", request_type_id, search_mode);
				
				html=makeRequesTypeFlexFieldsFilterList(conn, session,search_mode);
				msg="ok";			
				
			}
			
			//**********************************************
			//clear_flex_field_filters
			//**********************************************
			if (action.equals("clear_flex_field_filters")) {
				String search_mode=par1;
				
				clearFlexFieldFilters(session,search_mode); 
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//unset_mad_all_queries
			//**********************************************
			if (action.equals("unset_mad_all_queries")) {
				
				unsetAllMadQueries(conn, session); 
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//unset_mad_user_queries
			//**********************************************
			if (action.equals("unset_mad_user_queries")) {
				
				unsetAllMadQueries(conn, session); 
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//set_flex_field_filter
			//**********************************************
			if (action.equals("set_flex_field_filter")) {
				String flex_field_type=par1;
				String flex_field_id=par2;
				String filter_value=par3;
				String search_mode=par4; 
								
				setFlexFieldFilter(session,flex_field_type,flex_field_id,filter_value,search_mode);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//set_platform_parameter
			//**********************************************
			if (action.equals("set_platform_parameter")) {
				String request_id=par1;
				String platform_id=par2;
				String application_id=par3;
				String flex_field_id=par4;
				String field_value=par5;
				
				
				
				setPlatformParameter(conn,session,request_id,platform_id, application_id, flex_field_id, field_value);
				
				html="-";
				msg="ok";			
				
			}
			
			
			//**********************************************
			//load_configuration_menu
			//**********************************************
			if (action.equals("load_configuration_menu")) {
				
				html=loadConfigurationMenu(conn,session);
				msg="ok";			 
				
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
			//set_lov_filter
			//**********************************************
			if (action.equals("set_lov_filter")) {
				
				String lov_type=par1;
				String curr_value=par2;
				String filter_value=par3;
				String lov_parameters=par4;
				String to_refresh=par5;
				

				
				if (filter_value.trim().equals("${null}")) filter_value="";
				
				
				
				html=setLovFilter(conn,session,lov_type,curr_value, filter_value, lov_parameters, to_refresh);
				msg="ok";			
				
				
				
			}
			
			
			//**********************************************
			//add_mad_platform_type_modifier_group
			//**********************************************
			if (action.equals("add_mad_platform_type_modifier_group")) {
				String platform_type_id=par1;
				String modifier_group=par2;
				 
				int res=addNewMadPlatformTypeModifierGroup(conn,session,platform_type_id,modifier_group);
				if (res<0) {
					
					if (res==-2) {
						html="-";
						msg="nok:modifier group cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadPlatformTypeModifierGroupEditor('"+platform_type_id+"')";
				}
							
				
			}
			
			//**********************************************
			//add_mad_flexible_field
			//**********************************************
			if (action.equals("add_mad_flexible_field")) {
				String flex_field_type=par1;
				String field_title=par2;
				 
				int res=addNewMadFlexField(conn,session,flex_field_type,field_title);
				if (res<0) {
					
					if (res==-2) {
						html="-";
						msg="nok:modifier group cannot be added.";
					} 
				}
				else {
					html="-";
					msg="ok:javascript:makeMadFlexFieldList()";
				}
							
				
			}
			
			
			//**********************************************
			//add_new_mad_environment
			//**********************************************
			if (action.equals("add_new_mad_environment")) {
				String environment_name=par1;
				 
				int res=addNewMadEnvironment(conn,session,environment_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already an environment named :  ("+environment_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:environment cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadEnvironmentList()";
				}
							
				
			}
			
			//**********************************************
			//make_save_as_private_filter_dlg
			//**********************************************
			if (action.equals("make_save_as_private_filter_dlg")) {
				String current_query_id=par1;
				if (current_query_id.equals("x")) current_query_id="";
				
				html=makeSaveAsPrivateFilterDlg(conn, session, current_query_id);
				msg="ok";
			}
			
			
			//**********************************************
			//add_new_mad_private_filter
			//**********************************************
			if (action.equals("add_new_mad_private_filter")) {
				String filter_name=par1;
				 
				int res=addNewPrivateFilter(conn,session,filter_name);
				 
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already filter named :  ("+filter_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:filter cannot be added.";
					}
				}
				else {
					html="javascript:myalert(\"<font color=green>Filter Saved Successfully.</font>\");";
					msg="ok";
				}
							
				
			}
			
			//**********************************************
			//set_mad_private_filter_parameters
			//**********************************************
			if (action.equals("set_mad_private_filter_parameters")) {
				String filter_id=par1;
				 
				savePrivateFilterParameters(conn,session,filter_id);
				
				html="javascript:myalert(\"<font color=green>Filter Saved Successfully.</font>\")";
				msg="ok";
				
							
				
			}
			
			//**********************************************
			//edit_mad_private_filter
			//**********************************************
			if (action.equals("edit_mad_private_filter")) {
				String query_id=par1;
				html=makePrivateFilterEditor(conn,session,query_id);
				msg="ok";
				
				
			}
			//**********************************************
			//rename_mad_private_filter
			//**********************************************
			if (action.equals("rename_mad_private_filter")) {
				String query_id=par1;
				String query_name=par2;
				
				int res=renamePrivateFilter(conn,session,query_id, query_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already filter named :  ("+query_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:filter cannot be renamed.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:loadMadQueries()";
				}
				
				
			}
			//**********************************************
			//remove_mad_private_filter
			//**********************************************
			if (action.equals("remove_mad_private_filter")) {
				String query_id=par1;
				
				removePrivateFilter(conn,session,query_id);
				html="-";
				msg="ok:javascript:loadMadQueries()";
				
				
				
			}
			//**********************************************
			//add_mad_request_type
			//**********************************************
			if (action.equals("add_mad_request_type")) {
				String request_group=par1;
				String request_type_name=par2;
				 
				int res=addNewMadRequestType(conn,session,request_group,request_type_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already an request type named :  ("+request_type_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:request type cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadRequestTypeList()";
				}
							
				
			}
			//**********************************************
			//add_mad_platform
			//**********************************************
			if (action.equals("add_mad_platform")) {
				String platform_type_id=par1;
				String platform_name=par2;
				 
				int res=addNewMadPlatform(conn,session,platform_type_id,platform_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already an platform named :  ("+platform_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:request type cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadPlatformList()";
				}
							
				
			}
			
			//**********************************************
			//add_mad_repository
			//**********************************************
			if (action.equals("add_mad_repository")) {
				String repository_name=par1;
				 
				int res=addNewMadRepository(conn,session,repository_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already a repository named :  ("+repository_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:repository cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadRepositoryList()";
				}
			}
			
			//**********************************************
			//add_mad_string
			//**********************************************
			if (action.equals("add_mad_string")) {
				String string_name=par1;
				String lang=par2;
				
				 
				int res=addNewMadString(conn,session,string_name, lang);
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
					msg="ok:javascript:makeMadStringList()";
				}
			}
			
			
			//**********************************************
			//add_mad_lang
			//**********************************************
			if (action.equals("add_mad_lang")) {
				String lang_desc=par1;
				
				 
				int res=addNewMadLang(conn,session,lang_desc);
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
					msg="ok:javascript:makeMadLangList()";
				}
			}
			
			//**********************************************
			//add_mad_class
			//**********************************************
			if (action.equals("add_mad_class")) {
				String class_type=par1;
				String class_name=par2;
				
				 
				int res=addNewMadClass(conn,session,class_type,class_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already a class named :  ("+class_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:class cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadClassList()";
				}
			}
			//**********************************************
			//add_mad_driver
			//**********************************************
			if (action.equals("add_mad_driver")) {
				String driver_type=par1;
				String driver_name=par2;
				
				 
				int res=addNewMadDriver(conn,session,driver_type,driver_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already a driver named :  ("+driver_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:driver cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadDriverList()";
				}
			}
			//**********************************************
			//add_mad_modifier_group
			//**********************************************
			if (action.equals("add_mad_modifier_group")) {
				String modifier_group_name=par1;
				 
				int res=addNewMadModifierGroup(conn,session,modifier_group_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already a modifier group named :  ("+modifier_group_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:modifier group cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadModifierGroupList()";
				}
			}
			//**********************************************
			//add_mad_modifier_rule
			//**********************************************
			if (action.equals("add_mad_modifier_rule")) {
				String modifier_group_id=par1;
				String modifier_rule_name=par2;
				 
				int res=addNewMadModifierRule(conn,session,modifier_group_id,modifier_rule_name); 
				if (res<0) {
					if (res==-2) {
						html="-";
						msg="nok:modifier group cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadModifierRuleList('"+modifier_group_id+"')";
				}
			}
			//**********************************************
			//add_new_mad_platform_type
			//**********************************************
			if (action.equals("add_new_mad_platform_type")) {
				String platform_type_name=par1;
				 
				int res=addNewMadPlatformType(conn,session,platform_type_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already an platform type named :  ("+platform_type_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:platform type cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadPlatformTypeList()";
				}
							
				
			}
			//**********************************************
			//add_new_mad_user
			//**********************************************
			if (action.equals("add_new_mad_user")) {
				String entered_username=par1;
				 
				int res=addNewMadUser(conn,session,entered_username);
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
					msg="ok:javascript:makeMadUserList()";
				}
							
				
			}
			//**********************************************
			//add_mad_group
			//**********************************************
			if (action.equals("add_mad_group")) {
				String group_type=par1;
				String group_name=par2;
				 
				int res=addNewMadGroup(conn,session,group_type,group_name);
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
					msg="ok:javascript:makeMadGroupList()";
				}
							
				
			}
			//**********************************************
			//add_mad_email_template
			//**********************************************
			if (action.equals("add_mad_email_template")) {
				String template_name=par1;
				 
				int res=addNewMadEmailTemplate(conn,session,template_name);
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
					msg="ok:javascript:makeMadEmailTemplateList()";
				}
							
				
			}
			//**********************************************
			//add_new_mad_application
			//**********************************************
			if (action.equals("add_new_mad_application")) {
				String application_name=par1;
				 
				int res=addNewMadAppication(conn,session,application_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already an application named :  ("+application_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:application cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadApplicationList()";
				}
							
				
			}
			//**********************************************
			//add_new_mad_permission
			//**********************************************
			if (action.equals("add_new_mad_permission")) {
				String permission_name=par1;
				 
				int res=addNewMadPermission(conn,session,permission_name);
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
					msg="ok:javascript:makeMadPermissionList()";
				}
							
				
			}
			
			//**********************************************
			//add_new_mad_method
			//**********************************************
			if (action.equals("add_new_mad_method")) {
				String method_name=par1;
				String method_type=par2;
				 
				int res=addNewMadMethod(conn,session,method_name,method_type);
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
					msg="ok:javascript:makeMadMethodList()";
				}
							
				
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
			//reorder_flow_state_action_method
			//**********************************************
			if (action.equals("reorder_flow_state_action_method")) {
				String action_id=par1;
				String execution_order=par2;
				String direction=par3;
				 
				
				
				
				reorderMadFlowStateActionMethod(conn,session, action_id, execution_order, direction);
				
				html="-";
				msg="ok:javascript:makeMadActionMethodList('"+action_id+"')";
				
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
			//make_flow_state_action_method_list
			//**********************************************
			if (action.equals("make_flow_state_action_method_list")) {
				String action_id=par1;
			
				html=makeFlowStateActionMethodList(conn,session,action_id);
				msg="ok";
				
			}
			//**********************************************
			//add_new_mad_flow
			//**********************************************
			if (action.equals("add_new_mad_flow")) {
				String flow_name=par1;
				 
				int res=addNewMadFlow(conn,session,flow_name);
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
					msg="ok:javascript:makeMadFlowList()";
				}
							
				
			}
			//**********************************************
			//add_mad_deployment_slot
			//**********************************************
			if (action.equals("add_mad_deployment_slot")) {
				String slot_type=par1;
				String slot_name=par2;
				 
				int res=addNewMadDeploymentSlot(conn,session,slot_type,slot_name );
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already an slot named :  ("+slot_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:slot cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadDeploymentSlotList()";
				}
							
				
			}
			
			//**********************************************
			//add_mad_dashboard_sql
			//**********************************************
			if (action.equals("add_mad_dashboard_sql")) {
				String sql_name=par1;
				 
				int res=addNewMadDashSql(conn,session,sql_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already an sql named :  ("+sql_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:sql cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadDashSqlList()";
				}
							
				
			}
			
			//**********************************************
			//add_mad_dashboard_parameter
			//**********************************************
			if (action.equals("add_mad_dashboard_parameter")) {
				String parameter_name=par1;
				 
				int res=addNewMadDashParameter(conn,session,parameter_name);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already a parameter named :  ("+parameter_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:parameter cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadDashParameterList()";
				}
							
				
			}
			
			//**********************************************
			//add_mad_dashboard_view
			//**********************************************
			if (action.equals("add_mad_dashboard_view")) {
				String view_name=par1;
				String view_type=par2;
				 
				int res=addNewMadDashView(conn,session,view_name,view_type);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already a view named :  ("+view_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:view cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadDashViewList()";
				}
							
				
			}
			
			
			//**********************************************
			//add_mad_dashboard_view_parameter
			//**********************************************
			if (action.equals("add_mad_dashboard_view_parameter")) {
				String view_id=par1;
				String parameter_id=par2;
				 
				int res=addNewMadDashViewFilter(conn,session,view_id,parameter_id);
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:this parameter already exists";
					}if (res==-2) {
						html="-";
						msg="nok:filter cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadDashViewFilterList('"+view_id+"')";
				}
							
				
			}
			
			//**********************************************
			//add_mad_deployment_slot_detail
			//**********************************************
			if (action.equals("add_mad_deployment_slot_detail")) {
				String slot_id=par1;
				String slot_detail_name=par2;
				 
				int res=addNewMadDeploymentSlotDetail(conn,session,slot_id,slot_detail_name );
				if (res<0) {
					if (res==-1) {
						html="-";
						msg="nok:there is already an slot time named :  ("+slot_detail_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:slot time cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeMadDeploymentSlotDetailList(\""+slot_id+"\")";
				}
							
				
			}
			
			//**********************************************
			//update_mad_deployment_slot_detail
			//**********************************************
			if (action.equals("update_mad_deployment_slot_detail")) {
				String slot_detail_id=par1;
				String daily_time=par2;
				String slot_name=par3;
				String is_valid=par4;
				
				updateMadDeploymentSlotDetail(conn,session,slot_detail_id,daily_time,slot_name,is_valid); 
				
				html="-";
				msg="ok";
				
			}
			
			//**********************************************
			//remove_mad_deployment_slot_detail
			//**********************************************
			if (action.equals("remove_mad_deployment_slot_detail")) {
				String slot_id=par1;
				String slot_detail_id=par2; 
				removeMadDeploymentSlotDetail(conn,session,slot_id, slot_detail_id); 
				html="-";
				msg="ok:javascript:makeMadDeploymentSlotDetailList(\""+slot_id+"\")";
			}
			//**********************************************
			//add_new_mad_flow_state
			//**********************************************
			if (action.equals("add_new_mad_flow_state")) {
				String flow_id=par1;
				String state_name=par2;
				 
				int res=addNewMadFlowState(conn,session,flow_id, state_name);
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
					msg="ok:javascript:makeMadFlowStateList("+flow_id+")";	
				}
							
				
			}
			//**********************************************
			//add_new_mad_flow_state_action
			//**********************************************
			if (action.equals("add_new_mad_flow_state_action")) {
				String flow_state_id=par1;
				String action_name=par2;
				 
				int res=addNewMadFlowStateAction(conn,session,flow_state_id, action_name);
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
					msg="ok:javascript:makeMadFlowStateActionList("+flow_state_id+")";
				}
							
				
			}
			//**********************************************
			//make_mad_flex_field_list
			//**********************************************
			if (action.equals("make_mad_flex_field_list")) {
				html=makeMadFlexFieldList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_flex_field_editor
			//**********************************************
			if (action.equals("make_mad_flex_field_editor")) {
				String flex_field_id=par1;
				html=makeFlexFieldEditor(conn, session, flex_field_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_request_type_list
			//**********************************************
			if (action.equals("make_mad_request_type_list")) {
				html=makeMadRequestTypeList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_platform_list
			//**********************************************
			if (action.equals("make_mad_platform_list")) {
				html=makeMadPlatformList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_repository_list
			//**********************************************
			if (action.equals("make_mad_repository_list")) {
				html=makeMadRepositoryList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_string_list
			//**********************************************
			if (action.equals("make_mad_string_list")) {
				html=makeMadStringList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_lang_list
			//**********************************************
			if (action.equals("make_mad_lang_list")) {
				html=makeMadLangList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_class_list
			//**********************************************
			if (action.equals("make_mad_class_list")) {
				html=makeMadClassList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_driver_list
			//**********************************************
			if (action.equals("make_mad_driver_list")) {
				html=makeMadDriverList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_modifier_group_list
			//**********************************************
			if (action.equals("make_mad_modifier_group_list")) {
				html=makeMadModifierGroupList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_modifier_rule_list
			//**********************************************
			if (action.equals("make_mad_modifier_rule_list")) {
				String modifier_group_id=par1;
				html=makeMadModifierGroupEditor(conn, session, modifier_group_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_modifier_rule_editor
			//**********************************************
			if (action.equals("make_mad_modifier_rule_editor")) {
				String modifier_rule_id=par1;
				html=makeMadModifierRuleEditor(conn, session, modifier_rule_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_platform_editor
			//**********************************************
			if (action.equals("make_mad_platform_editor")) {
				String platform_id=par1;
				html=makePlatformEditor(conn, session, platform_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_platform_type_list
			//**********************************************
			if (action.equals("make_mad_platform_type_list")) {
				html=makeMadPlatformTypeList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_environment_list
			//**********************************************
			if (action.equals("make_mad_environment_list")) {
				html=makeMadEnvironmentList(conn, session);
				msg="ok";
			}
			
			//**********************************************
			//make_mad_application_list
			//**********************************************
			if (action.equals("make_mad_application_list")) {
				html=makeMadApplicationList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_permission_list
			//**********************************************
			if (action.equals("make_mad_permission_list")) {
				html=makeMadPermissionList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_method_list
			//**********************************************
			if (action.equals("make_mad_method_list")) {
				html=makeMadMethodList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_flow_list
			//**********************************************
			if (action.equals("make_mad_flow_list")) {
				html=makeMadFlowList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_deployment_slot_list
			//**********************************************
			if (action.equals("make_mad_deployment_slot_list")) {
				html=makeMadDeploymentSlotList(conn, session);
				msg="ok";
			}
			
			
			
			//**********************************************
			//make_mad_dashboard_sql_list
			//**********************************************
			if (action.equals("make_mad_dashboard_sql_list")) {
				html=makeMadDashSqlList(conn, session);
				msg="ok";
			}
			
			//**********************************************
			//make_mad_dashboard_parameter_list
			//**********************************************
			if (action.equals("make_mad_dashboard_parameter_list")) {
				html=makeMadDashParameterList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_dashboard_view_list
			//**********************************************
			if (action.equals("make_mad_dashboard_view_list")) {
				html=makeMadDashViewList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_dash_view_filter_list
			//**********************************************
			if (action.equals("make_mad_dash_view_filter_list")) {
				String view_id=par1;
				html=makeMadDashViewFilterList(conn, session,view_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_deployment_slot_detail_list
			//**********************************************
			if (action.equals("make_mad_deployment_slot_detail_list")) {
				String slot_id=par1;
				html=makeDailyDeploymentSlotEditor(conn, session, slot_id);  
				msg="ok"; 
			}
			//**********************************************
			//make_mad_flow_state_list
			//**********************************************
			if (action.equals("make_mad_flow_state_list")) {
				String flow_id=par1;
				html=makeMadFlowStateList(conn,session,flow_id);
				msg="ok:javascript:remakeMadFlowDrawing('"+flow_id+"')";
			}
			//**********************************************
			//make_mad_flow_state_action_list
			//**********************************************
			if (action.equals("make_mad_flow_state_action_list")) {
				String flow_state_id=par1;
				html=makeMadFlowStateActionList(conn, session,flow_state_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_application_editor
			//**********************************************
			if (action.equals("make_mad_application_editor")) {
				String application_id=par1;
				
				html=makeApplicationEditor(conn, session, application_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_permission_editor
			//**********************************************
			if (action.equals("make_mad_permission_editor")) {
				String permission_id=par1;
				
				html=makePermissionEditor(conn, session, permission_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_method_editor
			//**********************************************
			if (action.equals("make_mad_method_editor")) {
				String method_id=par1;
				
				html=makeMethodEditor(conn, session, method_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_flow_editor
			//**********************************************
			if (action.equals("make_mad_flow_editor")) {
				String flow_id=par1;
				
				html=makeFlowEditor(conn, session, flow_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_deployment_slot_editor
			//**********************************************
			if (action.equals("make_mad_deployment_slot_editor")) {
				String slot_id=par1;
				
				html=makeDeploymentSlotEditor(conn, session, slot_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_dashboard_sql_editor
			//**********************************************
			if (action.equals("make_mad_dashboard_sql_editor")) {
				String sql_id=par1;
				
				html=makeDashSqlEditor(conn, session, sql_id);
				msg="ok";
			}
			
			//**********************************************
			//make_mad_dashboard_parameter_editor
			//**********************************************
			if (action.equals("make_mad_dashboard_parameter_editor")) {
				String parmeter_id=par1;
				
				html=makeDashParameterEditor(conn, session, parmeter_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_dashboard_view_editor
			//**********************************************
			if (action.equals("make_mad_dashboard_view_editor")) {
				String view_id=par1;
				
				html=makeDashViewEditor(conn, session, view_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_flow_state_editor
			//**********************************************
			if (action.equals("make_mad_flow_state_editor")) {
				String flow_id=par1;
				String state_id=par2;
				
				html=makeMadFlowStateEditor(conn, session, flow_id, state_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_user_list
			//**********************************************
			if (action.equals("make_mad_user_list")) {
				html=makeMadUserList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_group_list
			//**********************************************
			if (action.equals("make_mad_group_list")) {
				html=makeMadGroupList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_email_template_list
			//**********************************************
			if (action.equals("make_mad_email_template_list")) {
				html=makeEmailTemplateList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_mad_user_editor
			//**********************************************
			if (action.equals("make_mad_user_editor")) {
				String user_id=par1;
				
				html=makeUserEditor(conn, session, user_id);
				msg="ok";
			}
			//**********************************************
			//make_mad_group_editor
			//**********************************************
			if (action.equals("make_mad_group_editor")) {
				String group_id=par1;
				
				html=makeGroupEditor(conn, session, group_id);
				msg="ok";
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
			//update_database_field
			//**********************************************
			if (action.equals("update_database_field")) {
				String database_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_envs",database_id, field_name, field_value);
				html="-";
				msg="ok";			
				
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
				
				html=html+"<hr>"+
							"<center>"+
								"<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button>"+
							"</center>";
						

				
			}	
			//**********************************************
			//update_platform_type_modifier_group_id_field
			//**********************************************
			if (action.equals("update_platform_type_modifier_group_id_field")) {
				String platform_type_modifier_group_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_platform_type_modifier_group",platform_type_modifier_group_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_request_type_field
			//**********************************************
			if (action.equals("update_request_type_field")) {
				String request_type_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_request_type",request_type_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_request_flow_log_field
			//**********************************************
			if (action.equals("update_request_flow_log_field")) {
				String request_flow_log_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_request_flow_logs",request_flow_log_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_flex_field
			//**********************************************
			if (action.equals("update_flex_field")) {
				String flex_field_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				
				updateMadTableField(conn,session,"mad_flex_field",flex_field_id, field_name, field_value);
				html="-";
				msg="ok:javascript:makeMadFlexFieldEditor('"+flex_field_id+"')";			
				
			}
			//**********************************************
			//update_platform_type_field
			//**********************************************
			if (action.equals("update_platform_type_field")) {
				String platform_type_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_platform_type",platform_type_id, field_name, field_value);
				html="-";
				msg="ok";		 	
				
			}
			//**********************************************
			//update_platform_field
			//**********************************************
			if (action.equals("update_platform_field")) {
				String platform_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_platform",platform_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_repository_field
			//**********************************************
			if (action.equals("update_repository_field")) {
				String repository_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_repository",repository_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_string_field
			//**********************************************
			if (action.equals("update_string_field")) {
				String string_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_string",string_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//update_lang_field
			//**********************************************
			if (action.equals("update_lang_field")) {
				String lang_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_lang",lang_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//update_class_field
			//**********************************************
			if (action.equals("update_class_field")) {
				String class_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_class",class_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_driver_field
			//**********************************************
			if (action.equals("update_driver_field")) {
				String driver_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_driver",driver_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_modifier_group_field
			//**********************************************
			if (action.equals("update_modifier_group_field")) {
				String modifier_group_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_modifier_group",modifier_group_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_modifier_rule_field
			//**********************************************
			if (action.equals("update_modifier_rule_field")) {
				String modifier_rule_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_modifier_rule",modifier_rule_id, field_name, field_value);
				html="-";
				msg="ok:javascript:makeMadModifierRuleEditor('"+modifier_rule_id+"');";			
				
			}
			//**********************************************
			//update_environment_field
			//**********************************************
			if (action.equals("update_environment_field")) {
				String environment_id=par1;
				String field_name=par2;
				String field_value=par3;
				 
				updateMadTableField(conn,session,"mad_environment",environment_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_application_field
			//**********************************************
			if (action.equals("update_application_field")) {
				String application_id=par1;
				String field_name=par2;
				String field_value=par3; 
				
				
				 
				updateMadTableField(conn,session,"mad_application",application_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_permission_field
			//**********************************************
			if (action.equals("update_permission_field")) {
				String permission_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"mad_permission",permission_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_method_field
			//**********************************************
			if (action.equals("update_method_field")) {
				String method_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"mad_method",method_id, field_name, field_value);
				html="-";
				msg="ok";			
				
				if (field_name.equals("parameter_count")) 
					msg="ok:javascript:makeMethodParameterEditor('"+method_id+"');";	
					
				
				
			}
			
			
			//**********************************************
			//update_action_method_field
			//**********************************************
			if (action.equals("update_action_method_field")) {
				String action_method_id=par1;
				String field_name=par2;
				String field_value=par3; 
				
				 
				updateMadTableField(conn,session,"mad_flow_state_action_methods",action_method_id, field_name, field_value);
				html="-";
				msg="ok";			
				
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
			//update_flow_field
			//**********************************************
			if (action.equals("update_flow_field")) {
				String flow_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"mad_flow",flow_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_deployment_slot_field
			//**********************************************
			if (action.equals("update_deployment_slot_field")) {
				String slot_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"mad_deployment_slot",slot_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_dashboard_sql_field
			//**********************************************
			if (action.equals("update_dashboard_sql_field")) {
				String sql_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"mad_dashboard_sql",sql_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_dashboard_parameter_field
			//**********************************************
			if (action.equals("update_dashboard_parameter_field")) {
				String parameter_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"mad_dashboard_parameter",parameter_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_dashboard_view_field
			//**********************************************
			if (action.equals("update_dashboard_view_field")) {
				String view_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"mad_dashboard_view",view_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_deployment_slot_detail_hourly
			//**********************************************
			if (action.equals("update_deployment_slot_detail_hourly")) {
				String slot_id=par1;
				String day_id=par2;
				String minute_id=par3; 
				String state=par4;
				
				
				 
				updateMadDeploymentSlotDetailHourly(conn,session,slot_id,day_id,minute_id, state); 
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_flow_state_field
			//**********************************************
			if (action.equals("update_flow_state_field")) {
				String state_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"mad_flow_state",state_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_flow_state_action_field
			//**********************************************
			if (action.equals("update_flow_state_action_field")) {
				String action_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"mad_flow_state_action",action_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_group_field
			//**********************************************
			if (action.equals("update_group_field")) {
				String group_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"mad_group",group_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_email_template_field
			//**********************************************
			if (action.equals("update_email_template_field")) {
				String group_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"mad_email_template",group_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_user_field
			//**********************************************
			if (action.equals("update_user_field")) {
				String updating_user_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_user",updating_user_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//delete_mad_platform_type_modifier_group
			//**********************************************
			if (action.equals("delete_mad_platform_type_modifier_group")) {
				String platform_type_id=par1;
				String id=par2;
				 
				deleteMadPlatformTypeModifierGroup(conn,session,id);
				html="-";
				msg="ok:javascript:makeMadPlatformTypeModifierGroupEditor(\""+platform_type_id+"\")";			
				
			}
			//**********************************************
			//delete_mad_flex_field
			//**********************************************
			if (action.equals("delete_mad_flex_field")) {
				String flex_field_id=par1;
				 
				String err_msg=deleteMadFlexField(conn,session,flex_field_id);
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadFlexFieldList()";	
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
						
				
			}
			//**********************************************
			//delete_mad_request_type
			//**********************************************
			if (action.equals("delete_mad_request_type")) {
				String request_type_id=par1;
				 
				String err_msg=deleteMadRequestType(conn,session,request_type_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadRequestTypeList()";	
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
						
				
			}
			//**********************************************
			//delete_mad_platform
			//**********************************************
			if (action.equals("delete_mad_platform")) {
				String platform_id=par1;
				 
				String err_msg=deleteMadPlatform(conn,session,platform_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadPlatformList()";	
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
						
				
			}
			//**********************************************
			//delete_mad_repository
			//**********************************************
			if (action.equals("delete_mad_repository")) {
				String repository_id=par1;
				 
				String err_msg=deleteMadRepository(conn,session,repository_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadRepositoryList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
			}
			
			//**********************************************
			//delete_mad_string
			//**********************************************
			if (action.equals("delete_mad_string")) {
				String string_id=par1;
				 
				String err_msg=deleteMadString(conn,session,string_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadStringList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
			}
			
			
			//**********************************************
			//delete_mad_lang
			//**********************************************
			if (action.equals("delete_mad_lang")) {
				String lang_id=par1;
				 
				String err_msg=deleteMadLang(conn,session,lang_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadLangList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
			}

			//**********************************************
			//delete_mad_class
			//**********************************************
			if (action.equals("delete_mad_class")) {
				String class_id=par1;
				 
				String err_msg=deleteMadClass(conn,session,class_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadClassList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
							
				
			}
			//**********************************************
			//delete_mad_driver
			//**********************************************
			if (action.equals("delete_mad_driver")) {
				String driver_id=par1;
				 
				String err_msg=deleteMadDriver(conn,session,driver_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadDriverList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
							
				
			}
			//**********************************************
			//delete_mad_modifier_group
			//**********************************************
			if (action.equals("delete_mad_modifier_group")) {
				String modifier_group_id=par1;
				 
				String err_msg=deleteMadModifierGroup(conn,session,modifier_group_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadModifierGroupList()";	
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
						
				
			}
			//**********************************************
			//delete_mad_modifier_rule
			//**********************************************
			if (action.equals("delete_mad_modifier_rule")) {
				String modifier_group_id=par1;
				String modifier_rule_id=par2;
				 
				deleteMadModifierRule(conn,session,modifier_rule_id);
				html="-";
				msg="ok:javascript:makeMadModifierRuleList('"+modifier_group_id+"')";		
				
			}
			//**********************************************
			//delete_mad_platform_type
			//**********************************************
			if (action.equals("delete_mad_platform_type")) {
				String platform_type_id=par1;
				 
				String err_msg=deleteMadPlatformType(conn,session,platform_type_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadPlatformTypeList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
							
				
			}
			
			//**********************************************
			//delete_mad_environment
			//**********************************************
			if (action.equals("delete_mad_environment")) {
				String environment_id=par1;
				 
				String err_msg=deleteMadEnvironment(conn,session,environment_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadEnvironmentList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
							
				
			}
			//**********************************************
			//delete_mad_application
			//**********************************************
			if (action.equals("delete_mad_application")) {
				String application_id=par1;
				 
				String err_msg=deleteMadApplication(conn,session,application_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadApplicationList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
				
				
			}
			//**********************************************
			//delete_mad_permission
			//**********************************************
			if (action.equals("delete_mad_permission")) {
				String permission_id=par1;
				 
				String err_msg=deleteMadPermission(conn,session,permission_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadPermissionList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
							
				
			}
			
			//**********************************************
			//delete_mad_method
			//**********************************************
			if (action.equals("delete_mad_method")) {
				String method_id=par1;
				 
				String err_msg=deleteMadMethod(conn,session,method_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadMethodList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
							
				
			}
			//**********************************************
			//delete_mad_flow
			//**********************************************
			if (action.equals("delete_mad_flow")) {
				String flow_id=par1;
				 
				String err_msg=deleteMadFlow(conn,session,flow_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadFlowList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
							
				
			}
			//**********************************************
			//delete_mad_deployment_slot
			//**********************************************
			if (action.equals("delete_mad_deployment_slot")) {
				String slot_id=par1;
				 
				deleteMadDeploymentSlot(conn,session,slot_id); 
				html="-";
				msg="ok:javascript:makeMadDeploymentSlotList()";			
				
			}
			
			//**********************************************
			//delete_mad_dashboard_sql
			//**********************************************
			if (action.equals("delete_mad_dashboard_sql")) {
				String sql_id=par1;
				 
				String err_msg=deleteMadDashSql(conn,session,sql_id); 
				
				if (err_msg.length()>0) {
					html="-";
					msg="nok:"+err_msg;
				}
				else {
					html="-";
					msg="ok:javascript:makeMadDashSqlList()";
				}
							
				
			}
			
			//**********************************************
			//delete_mad_dashboard_parameter
			//**********************************************
			if (action.equals("delete_mad_dashboard_parameter")) {
				String parameter_id=par1;
				 
				String err_msg=deleteMadDashParameter(conn,session,parameter_id); 
				
				if (err_msg.length()>0) {
					html="-";
					msg="nok:"+err_msg;
				}
				else {
					html="-";
					msg="ok:javascript:makeMadDashParameterList()";
				}
							
				
			}
			
			//**********************************************
			//delete_mad_dashboard_view
			//**********************************************
			if (action.equals("delete_mad_dashboard_view")) {
				String view_id=par1;
				 
				String err_msg=deleteMadDashView(conn,session,view_id); 
				
				if (err_msg.length()>0) {
					html="-";
					msg="nok:"+err_msg;
				}
				else {
					html="-";
					msg="ok:javascript:makeMadDashViewList()";
				}
							
				
			}
			
			//**********************************************
			//delete_mad_dashboard_view_parameter
			//**********************************************
			if (action.equals("delete_mad_dashboard_view_parameter")) {
				String view_id=par1;
				String view_parameter_id=par2;
				
				String err_msg=deleteMadDashViewParameter(conn,session,view_parameter_id); 
				
				if (err_msg.length()>0) {
					html="-";
					msg="nok:"+err_msg;
				}
				else {
					html="-";
					msg="ok:javascript:makeMadDashViewFilterList('"+view_id+"')";
				}
							
				
			}
			//**********************************************
			//delete_mad_flow_state
			//**********************************************
			if (action.equals("delete_mad_flow_state")) {
				String flow_id=par1;
				String flow_state_id=par2;
				 
				deleteMadFlowState(conn,session,flow_state_id); 
				html="-";
				msg="ok:javascript:makeMadFlowStateList("+flow_id+")";			
				
			}
			//**********************************************
			//make_mad_flow_field_setting_form
			//**********************************************
			if (action.equals("make_mad_flow_field_setting_form")) {
				String request_type_id=par1;
				
				 
				html=makeMadFieldSettingForm(conn,session, request_type_id); 
				msg="ok";			 
				
			}
			//**********************************************
			//set_mad_flow_state_field_override
			//**********************************************
			if (action.equals("set_mad_flow_state_field_override")) {
				String request_type_id=par1;
				String flow_state_id=par2;
				String permission_id=par3;
				String flex_field_id=par4;
				String override_key=par5;
				
				changeMadRequestFieldSettingOverride(conn, request_type_id, flow_state_id, flex_field_id, permission_id, override_key);
				
				html=makeMadRequestFieldSettingCell(conn, request_type_id, flow_state_id, flex_field_id, permission_id, override_key);
				msg="ok";			 
				
			}
			
			//**********************************************
			//delete_mad_flow_state_action
			//**********************************************
			if (action.equals("delete_mad_flow_state_action")) {
				String action_id=par1;
				String flow_state_id=par2;
				 
				deleteMadFlowStateAction(conn,session,action_id);
				html="-";
				msg="ok:javascript:makeMadFlowStateActionList('"+flow_state_id+"')";			
				
			}
			
			//**********************************************
			//delete_mad_flow_state_action_method
			//**********************************************
			if (action.equals("delete_mad_flow_state_action_method")) {
				String action_id=par1;
				String action_method_id=par2;
				 
				deleteMadFlowStateActionMethod(conn,session,action_method_id);
				html="-";
				msg="ok:javascript:makeMadActionMethodList('"+action_id+"')";			
				
			}
			//**********************************************
			//delete_mad_user
			//**********************************************
			if (action.equals("delete_mad_user")) {
				String deleted_user_id=par1;
				 
				String err_msg=deleteMadUser(conn,session,deleted_user_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadUserList()";	
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
			}
			//**********************************************
			//delete_mad_group
			//**********************************************
			if (action.equals("delete_mad_group")) {
				String application_id=par1;
				 
				String err_msg=deleteMadGroup(conn,session,application_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadGroupList()";			
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
			}
			//**********************************************
			//delete_mad_email_template
			//**********************************************
			if (action.equals("delete_mad_email_template")) {
				String email_template_id=par1;
				 
				String err_msg=deleteMadEmailTemplate(conn,session,email_template_id);
				
				if (err_msg.length()==0) {
					html="-";
					msg="ok:javascript:makeMadEmailTemplateList()";
				}
				else {
					html="-";
					msg="nok:"+err_msg;
				}
				
							
				
			}
			//**********************************************
			//add_flex_field
			//**********************************************
			if (action.equals("add_flex_field")) {
				String parent_table=par1;
				String parent_table_id=par2;
				String flex_field_id=par3;
				
				if ("mad_request_type_field, mad_application_flex_fields, mad_platform_type_flex_fields, ".contains(parent_table+","))
					{
						int res=addFlexField(conn,session,parent_table, parent_table_id,flex_field_id);
						if (res<0) {
							if (res==-1) {
								html="-";
								msg="nok:this flexible field was already added";
							}
							if (res==-2) {
								html="-";
								msg="nok:flexible field cannot be added.";
							}
						}
						else {
							html="-";
							msg="ok:javascript:makeMadFlexField('"+parent_table+"',"+parent_table_id+");";	
						}
						
					}
					
				
			} 
			 
			//**********************************************
			//update_table_flex_field
			//**********************************************
			if (action.equals("update_table_flex_field")) {
				String parent_table=par1;
				String parent_table_id=par2;
				String id=par3;
				String field_name=par4;
				String field_value=par5;
				
				if ("mad_request_type_field, mad_application_flex_fields, mad_platform_type_flex_fields, ".contains(parent_table+","))
					updateMadTableField(conn,session, parent_table,id,field_name, field_value);
				html="-";
				msg="ok:javascript:makeMadFlexField('"+parent_table+"',"+parent_table_id+")";			
				
			}
			
			//**********************************************
			//remove_flex_field
			//**********************************************
			if (action.equals("remove_flex_field")) {
				String parent_table=par1;
				String parent_table_id=par2;
				String id=par3;
				
				if ("mad_request_type_field, mad_application_flex_fields, mad_platform_type_flex_fields, ".contains(parent_table+","))
					removeFlexField(conn,session,parent_table,id);
				html="-";
				msg="ok:javascript:makeMadFlexField('"+parent_table+"',"+parent_table_id+")";			
				
			}
			
			//**********************************************
			//make_mad_platform_type_modifier_group_editor
			//**********************************************
			if (action.equals("make_mad_platform_type_modifier_group_editor")) {
				String platform_type_id=par1;
				
				html=makeMadPlatformTypeModifierGroupEditor(conn,session,platform_type_id);
				msg="ok";			
				 
			}
			
			//**********************************************
			//make_flex_field_table
			//**********************************************
			if (action.equals("make_flex_field_table")) {
				String parent_table=par1;
				String parent_table_id=par2;
				
				html=makeFlexFieldTableEditor(conn,session,parent_table,parent_table_id);
				msg="ok";			
				 
			}
			
			//**********************************************
			//add_remove_platform_environment
			//**********************************************
			if (action.equals("add_remove_platform_environment")) {
				String environment_id=par1;
				String action_and_id=par2;
				String addremove="ADD";
				String platform_id="0";
				try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
				try {platform_id=action_and_id.split(":")[1];} catch(Exception e){}
				String platform_type_id=par3; 
				
				addRemovePlatformEnv(conn,session,environment_id,addremove,platform_id);
				html="-";
				msg="ok:javascript:makeMadEvironmentEditor(\""+environment_id+"\",\""+platform_type_id+"\");";			
				
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
			//add_remove_request_type_application
			//**********************************************
			if (action.equals("add_remove_request_type_application")) {
				String request_type_id=par1;
				String action_and_id=par2;
				String addremove="ADD";
				String application_id="0";
				try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
				try {application_id=action_and_id.split(":")[1];} catch(Exception e){}
				
				addRemoveRequestTypeApplication(conn,session,request_type_id,addremove,application_id);  
				
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//add_remove_request_type_environment
			//**********************************************
			if (action.equals("add_remove_request_type_environment")) {
				String request_type_id=par1;
				String action_and_id=par2;
				String addremove="ADD";
				String environment_id="0";
				try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
				try {environment_id=action_and_id.split(":")[1];} catch(Exception e){}
				
				
				addRemoveRequestTypeEnvironment(conn,session,request_type_id,addremove,environment_id);  
				
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//add_remove_depended_applicaion
			//**********************************************
			if (action.equals("add_remove_depended_applicaion")) {
				String application_id=par1;
				String action_and_id=par2;
				String addremove="ADD";
				String depended_application_id="0";
				try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
				try {depended_application_id=action_and_id.split(":")[1];} catch(Exception e){}
				
				addRemoveDependedApplication(conn,session,application_id,addremove,depended_application_id); 
				
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
			//add_remove_user_role
			//**********************************************
			if (action.equals("add_remove_user_role")) {
				String member_user_id=par1;
				String action_and_id=par2;
				String addremove="ADD";
				String role_id="0";
				try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
				try {role_id=action_and_id.split(":")[1];} catch(Exception e){}
				
				addRemoveUserRole(conn,session,member_user_id,addremove,role_id); 
				
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//update_mad_platform_parameter_value
			//**********************************************
			if (action.equals("update_mad_platform_parameter_value")) {
				String platform_id=par1;
				String flex_field_id=par2;
				String new_value=par3;
								
				updateMadPlatformParameterValue(conn,session,platform_id,flex_field_id,new_value);
				html="-";
				msg="ok";			
				
			}
			
			
			
			//**********************************************
			//make_mad_environment_editor
			//**********************************************
			if (action.equals("make_mad_environment_editor")) {
				String environment_id=par1;
				String active_platform_type_id=par2;
				
				html=makeMadEnvironmentEditor(conn, session, environment_id,active_platform_type_id);
				msg="ok";			
				
			}
			//**********************************************
			//make_user_set_password
			//**********************************************
			if (action.equals("make_user_set_password")) {
				String password_user_id=par1;
				
				html=makeMadSetPassword(conn, session, password_user_id);
				msg="ok";			
				
			}
			//**********************************************
			//set_user_password
			//**********************************************
			if (action.equals("set_user_password")) {
				String password_user_id=par1;
				String new_password=par2;
				
				setMadUserPassword(conn, session, password_user_id, new_password);
				html="-";
				msg="nok:Password is changed successfully.";			
				
			}
			
			//**********************************************
			//reorder_mad_modifier_rule
			//**********************************************
			if (action.equals("reorder_mad_modifier_rule")) {
				String modifier_group_id=par1;
				String rule_id=par2;
				String updown=par3;
				
				reorderTableOrderByGroup(conn, session, "mad_modifier_rule", rule_id, updown,"modifier_group_id","modifier_order",modifier_group_id);
				html="-";
				msg="ok:javascript:makeMadModifierRuleList('"+modifier_group_id+"')";
		
				
			}
			
			//**********************************************
			//reorder_mad_flex_field
			//**********************************************
			if (action.equals("reorder_mad_flex_field")) {
				String table_name=par1;
				String group_field_name=par2;
				String group_field_id=par3;
				String table_id=par4;
				String updown=par5;
				
				reorderTableOrderByGroup(conn, session, table_name, table_id, updown, group_field_name,"field_order",group_field_id);
				html="-";
				msg="ok:javascript:makeMadFlexField('"+table_name+"','"+group_field_id+"')";
		
				
			}
			//**********************************************
			//open_multiple_flex_field_editor
			//**********************************************
			if (action.equals("open_multiple_flex_field_editor")) {
				String flex_field_id=par1;
				String platform_type_id=par2;
				
				html=makeMultipleFlexFieldEditor(conn,session,flex_field_id, platform_type_id);
				msg="ok";
		
				
			}
			//**********************************************
			//save_multiple_platform_field
			//**********************************************
			if (action.equals("save_multiple_platform_field")) {
				String platform_field_id=par1;
				String new_value=par2;
				
				saveMultiplePlatformFlexField(conn,session,platform_field_id,new_value);
				html="-";
				msg="ok";
		
				 
			}
			//**********************************************
			//search_tag_list
			//**********************************************
			if (action.equals("search_tag_list")) {
				String application_id=par1;
				String member_id=par2;
				String current_tag=par3;
				String search_val=par4;
				
				
				html=searchTagList(conn,application, session,application_id,member_id,current_tag,search_val);
				msg="ok";
			}
			
			//**********************************************
			//search_mad_configuration
			//**********************************************
			if (action.equals("search_mad_configuration")) {
				String search_what="search_for_"+par1;
				String search_value=par2;
				html="-";
				
				session.setAttribute(search_what, search_value);
				
				
				if (search_what.equals("search_for_flexible_fields")) 
					html=makeMadFlexFieldList(conn, session);
				else	
				if (search_what.equals("search_for_strings")) 
					html=makeMadStringList(conn, session);
				else
				if (search_what.equals("search_for_users")) 
					html=makeMadUserList(conn, session);
					
				msg="ok";
			}		
			
			//**********************************************
			//show_route_menu
			//**********************************************
			if (action.equals("show_route_menu")) {
				String request_id=par1;
				
				
				
				html=makeRouteMenu(conn, session, request_id);
				msg="ok";
			}	
			//********************************************** 
			//show_route_menu
			//**********************************************
			if (action.equals("show_route_logs")) {
				String request_id=par1;
				html=showRouteLogs(conn, session, request_id);
				msg="ok";
			}	
			
			//********************************************** 
			//show_change_logs
			//**********************************************
			if (action.equals("show_change_logs")) {
				String request_id=par1;
				html=showChangeLogs(conn, session, request_id); 
				msg="ok";
			}	

			//**********************************************
			//route_request
			//**********************************************
			if (action.equals("route_request")) {
				String request_id=par1;
				String new_action_id=par2;
				String action_memo=par3;
				String time_spent=par4;
				
				String err_msg=routeRequest(conn, session, request_id, new_action_id, action_memo, time_spent);

				
				
				if (err_msg.length()==0) {
					
					indexRequestSearchText(conn, session, request_id);
					
					
					sql="select request_group from mad_request r, mad_request_type rt where r.request_type_id=rt.id and r.id=?";
					bindlist.clear();
					bindlist.add(new String[]{"INTEGER",request_id});
					ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
					String request_group="";
					try{request_group=arr.get(0)[0];} catch(Exception e) {e.printStackTrace();}
					
					html="-";
					msg="ok:javascript:hideWaitingModal(); showRootSuccessAndReopenRequest('"+request_id+"','"+request_group+"','');  reloadRequestList('NO');";
					
				}
				else {
					html="-";
					msg="ok:javascript:hideWaitingModal(); myalert('"+err_msg+"'); ";
				}
			}
			//**********************************************
			//show_mad_deploy_progress
			//**********************************************
			if (action.equals("show_mad_deploy_progress")) {
				String request_id=par1;
				String current_deployment_work_plan_id=par2;
				
			
				html=showMadDeployProgress(conn, session, request_id,current_deployment_work_plan_id);
				msg="ok";
			
			}
			//**********************************************
			//write_mad_deployment_wpl_info
			//**********************************************
			if (action.equals("write_mad_deployment_wpl_info")) {
				String work_plan_id=par1;
				String request_id=par2;
				
			
				html=writeMadDeployWPLInfo(conn, session, work_plan_id, request_id);
				msg="ok";
			
			}
			
			//**********************************************
			//set_req_app_member_skip
			//**********************************************
			if (action.equals("set_req_app_member_skip")) {
				String request_id=par1;
				String req_app_member_id=par2;
				String skip_status=par3; 
				String skip_reason=par4;
				
				boolean has_ability=checkpermissionByName(session, "REQUEST_PARTIAL_DEPLOYMENT");
				if (has_ability) {
					setMadReqAppMemberSkip(conn, session, req_app_member_id, skip_status, skip_reason);
					html="-";
					msg="ok:javascript:refreshRequestDeploymentList(\""+request_id+"\");";
				}
				else {
					html="-";
					msg="nok:No Permission";
				}
				
			
			}
			
			//**********************************************
			//set_req_platform_skip
			//**********************************************
			if (action.equals("set_req_platform_skip")) {
				String request_id=par1;
				String platform_id=par2;
				String skip_status=par3; 
				
				boolean has_ability=checkpermissionByName(session, "SKIP_PLATFORM_DEPLOYMENT");
				
				if (has_ability) {
					setMadReqPlatformSkip(conn, session, request_id, platform_id,skip_status );
					html="-";
					msg="ok:javascript:refreshRequestDeploymentList(\""+request_id+"\");";
				}
			}
			
			//**********************************************
			//get_mad_flow_info
			//**********************************************
			if (action.equals("get_mad_flow_info")) {
				String flow_id=par1;
				String flow_info=getMadFlowInfo(conn, session, flow_id, "0");
				html="-";
				msg="ok:javascript:drawMadFlow('flowDrawInnerBody_Flow"+flow_id+"','"+flow_id+"',\""+flow_info+"\",\"0\")";
			}
			//**********************************************
			//get_mad_flow_info_for_request
			//**********************************************
			if (action.equals("get_mad_flow_info_for_request")) {
				String flow_id=par1;
				String request_id=par2;
				String flow_info=getMadFlowInfo(conn, session, flow_id, request_id);
				
				html="-";
				msg="ok:javascript:drawMadFlow('RequestFlowDiv','"+flow_id+"',\""+flow_info+"\",\""+request_id+"\")";
			}
			
			//**********************************************
			//save_mad_flow_box_location
			//**********************************************
			if (action.equals("save_mad_flow_box_location")) {
				String flow_id=par1;
				String saving_state=par2;
				String loc_x=par3;
				String loc_y=par4;
				
				
				saveMadFlowLocation(conn,session,flow_id,saving_state,loc_x,loc_y);
				
				html="-";
				msg="ok";
			}
			
			
			//**********************************************
			//add_mad_request_attachment
			//**********************************************
			if (action.equals("add_mad_request_attachment")) {
				String request_id=par1;
				String flex_field_id=par2;
				
				html=makeMadAttachmentDialog(conn,session,request_id,flex_field_id);
				msg="ok";
			}
			
			
			//**********************************************
			//wait_for_attachment_completed
			//**********************************************
			if (action.equals("wait_for_attachment_completed")) {
				
				String request_id=par1;
				String flex_field_id=par2;
				
				
				String attachment_id=nvl((String) session.getAttribute("attachment_attachment_id"),"0");
				
				
				try{Thread.sleep(3000);} catch(Exception e) {}
				
				
				
				boolean is_timeout=waitForAttachmentCompleted(conn,session);
				String last_attachment_error=nvl((String) session.getAttribute("last_attachment_error"),"");
				session.setAttribute("last_attachment_error", "");

				 
				html="-";
				msg="ok:javascript:finishAttachment("+is_timeout+",'"+request_id+"','"+flex_field_id+"','"+clearHtml(last_attachment_error)+"');";
			}
			
			
			
			//**********************************************
			//delete_mad_request_attachment
			//**********************************************
			if (action.equals("delete_mad_request_attachment")) {
				String request_id=par1;
				String flex_field_id=par2;
				
				String request_group=getRequestGroup(conn, session, request_id);
				
				deleteMadAttachment(conn,session,request_id,flex_field_id);
				html="-";
				msg="ok:javascript:finishAttachment(false,'"+request_id+"','"+flex_field_id+"','');";
			}
			
			
			//**********************************************
			//redraw_attachment_field_content
			//**********************************************
			if (action.equals("redraw_attachment_field_content")) {
				String request_id=par1;
				String flex_field_id=par2;
				
				html=makeAttachmentFieldContent(conn, session, request_id, flex_field_id);

				
			}
			
			//**********************************************
			//view_mad_request_attachment
			//**********************************************
			if (action.equals("view_mad_request_attachment")) {
				String request_id=par1;
				String flex_field_id=decode(par2);
				
				String attachment_id=getMadAttachmentId(conn,session,request_id,flex_field_id);
				if (!attachment_id.equals("0")) {
					attachment_id=encode(attachment_id);
					html="-";
					msg="ok:javascript:downloadMadAttachment(\""+attachment_id+"\");";
				} else {
					html="-";
					msg="ok:javascript:myalert(\"No attachment to download!\")";
				}
				
			}
			
			//**********************************************
			//show_notification_parameters
			//**********************************************
			if (action.equals("show_notification_parameters")) {
				
				html=getNotificationParameters();
				msg="ok";
			}
			
			//**********************************************
			//show_mad_deployment_slot
			//**********************************************
			if (action.equals("show_mad_deployment_slot")) {
				String request_id=par1;
				String environment_id=par2; 
				html=showMadDeploymentSlot(conn,session,request_id,environment_id);
				msg="ok";
			}
			
			//**********************************************
			//set_mad_deployment_slot
			//**********************************************
			if (action.equals("set_mad_deployment_slot")) {
				String request_id=par1;
				String slot_detail_id=par2; 
				String free_time=par3;
				
				setMadDeploymentSlot(conn,session,request_id,slot_detail_id,free_time);
				html="-"; 
				msg="ok:javascript:makeDeploymentSlotButton(\""+request_id+"\");";
			}
			
			//**********************************************
			//make_mad_deployment_button
			//**********************************************
			if (action.equals("make_mad_deployment_button")) {
				String request_id=par1;
				boolean is_form_editable=isMadRequestFormEditable(conn, session, request_id);
				boolean is_deployment_time_editable=isDeploymentTimeButtonEditable(session, is_form_editable);
				 
				html=makeDeploymentSlotButton(conn,request_id,is_deployment_time_editable);
				msg="ok";
			}
			
			//**********************************************
			//show_mad_member_conflict
			//**********************************************
			if (action.equals("show_mad_member_conflict")) {
				String request_id=par1;
				String member_id=par2;
				
				boolean is_form_editable=isMadRequestFormEditable(conn, session, request_id);
				
				html=showMadMemberConflict(conn, session, request_id, member_id, is_form_editable);
				msg="ok";
			}
			
			
			//**********************************************
			//draw_monitoring_areas
			//**********************************************
			if (action.equals("draw_monitoring_areas")) {
								
				html=drawMonitoringAreas(conn, application, session);
				msg="ok:javascript:setRefreshInterval()";
			}
			
			//**********************************************
			//make_work_plan_list
			//**********************************************
			if (action.equals("make_work_plan_list")) {
				String work_plan_type_filter=par1;
				String work_plan_status_filter=par2;
				String refresh_interval=par3;
				
				html=makeWorkPlanList(conn, session, work_plan_type_filter, work_plan_status_filter, refresh_interval);
				msg="ok";
			}
			
			//**********************************************
			//show_process_window
			//**********************************************
			if (action.equals("show_process_window")) {
				String ptype=par1;
				String pstatus=par2;
				
				html=makeProcessWindow(conn,session,ptype,pstatus);
				msg="ok";
			}
			//**********************************************
			//set_process_action
			//**********************************************
			if (action.equals("set_process_action")) {
				
				String ptype=par1;
				String pid=par2;
				String paction=par3;
				String pstatus=par4;
				
				setProcessStatus(conn, session, ptype, pid, paction);
					
				html="-";	
				
				if (pstatus.length()>0 )
					msg="ok:javascript:showProcessWindow('"+ptype+"','"+pstatus+"')";
				else msg="ok";

			}
			
			//**********************************************
			//change_work_plan_process_limit
			//**********************************************
			if (action.equals("change_work_plan_process_limit")) {
				String work_plan_id=par1;
				String limit_type=par2;
				String limit=par3;
				
				changeWorkPlanProcessLimit(conn,session,work_plan_id,limit_type,limit);
				
				html="-";
				msg="ok:javascript:makeWorkPlanList()";
			}
			//**********************************************
			//edit_work_plan_parameters
			//**********************************************
			if (action.equals("edit_work_plan_parameters")) {
				String work_plan_id=par1;
				html=makeWorkPlanParamEditor(conn,session,work_plan_id);
				msg="ok";
			}
			//**********************************************
			//save_work_plan_parameters
			//**********************************************
			if (action.equals("save_work_plan_parameters")) {
				String work_plan_id=par1;
				String wp_email_address=par2;
				String wp_execution_type=par3;
				String wp_on_error_action=par4;
				String wp_options=par5;
				
				saveWorkPlanParams(conn,session,work_plan_id,wp_email_address,wp_execution_type,wp_on_error_action,wp_options);
				html="-";
				msg="ok";
			}
			//**********************************************
			//open_work_plan_window
			//**********************************************
			if (action.equals("open_work_plan_window")) {
				
				String work_plan_id=par1;
				
				html=makeWorkPlanWindow(conn, session, work_plan_id);
				msg="ok:javascript:makeMonitoringGraphData()";
				
			}
			//**********************************************
			//make_work_plan_graph_data
			//**********************************************
			if (action.equals("make_work_plan_graph_data")) {
				
				String work_plan_id=par1;
				
				html=makeGraphData(conn, session, work_plan_id);
				msg="ok:javascript:drawMonitoringGraphs()";
				
			}
			//**********************************************
			//show_work_plan_script_log
			//**********************************************
			if (action.equals("show_work_plan_script_log")) {
				
				String work_plan_id=par1;
				String field=par2+"_script_log";
				String rec_type="tdm_work_plan";
				
				String env_id=getDBSingleVal(conn,"select env_id from tdm_work_plan where id="+work_plan_id);
				String wplan_type=getDBSingleVal(conn,"select wplan_type from tdm_work_plan where id="+work_plan_id);

				html=printLongDet2(conn,wplan_type, env_id,work_plan_id,rec_type,field);
				msg="ok";
			}
			//**********************************************
			//get_work_package_list_by_status
			//**********************************************
			if (action.equals("get_work_package_list_by_status")) {
				
				String work_plan_id=par1;
				String status=par2;
			

				html=getWorkPackageListByStatus(conn, session, work_plan_id, status);
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
			//test_app_repo_script
			//**********************************************
			if (action.equals("test_app_repo_script")) {
				
				String test_request_id=par1;
				String application_id=par2;

				html=testAppRepoScript(conn, session, test_request_id, application_id);
				msg="ok";
			}
			
			//**********************************************
			//show_file_content
			//**********************************************
			if (action.equals("show_file_content")) {
				
				String request_id=par1;
				String member_id=par2;
				String member_version=par3;
				String compare_version=par4;


				html=showFileContentByMemberId(conn, session, request_id, member_id, member_version, compare_version); 
				msg="ok";
			}
			
			
			//**********************************************
			//show_file_content_by_url
			//**********************************************
			if (action.equals("show_file_content_by_url")) {
				
				String application_id=par1;
				String url=par2;
				
				String request_id="0";
				String member_id="0";


				html=showFileContentByUrl(conn, session, request_id, member_id, application_id,url);
				msg="ok";
			}
			
			//***************************************************
			//change_deployment_environment
			//***************************************************
			if (action.equals("change_deployment_environment")) {
				
				String request_id=par1;
				String environment_id=par2;


				changeDeploymentEnvironmet(conn, session, request_id,environment_id);
				
				html="-";
				msg="ok:javascript:refreshRequestApppEnvList('"+request_id+"')";
			}
			
			//**********************************************
			//make_request_env_list
			//**********************************************
			if (action.equals("make_request_env_list")) {
				
				String request_id=par1;


				html=makeRequestEnvList(conn, session, request_id);
				msg="ok";
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
			//test_js_code
			//**********************************************
			if (action.equals("test_js_code")) {
				
				String tab_name=par1;
				String col_name=par2;
				String rec_id=par3;
				
				if (
				"mad_modifier_rule,mad_application,mad_flex_field".contains(tab_name) 
				&& 
				"rule_changer_statement,app_repo_script,version_calculation_script,item_view_script,validation_sql,calc_statement".contains(col_name)
				) {
					html=testJsCode(conn, session, tab_name,col_name,rec_id );
				} 
				else {
					html="This columnd does not hold javascript.";
				}

				
				msg="ok";
			}
			
			//**********************************************
			//set_js_parameters
			//**********************************************
			if (action.equals("set_js_parameters")) {
				
				String params_to_set=par1;
				setJSParameters(session,params_to_set);
				
				html="-";			
				msg="ok";
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
			//load_dashboard_top_menu
			//**********************************************
			if (action.equals("load_dashboard_top_menu")) {
				html=loadDashboardTop(conn, session);			
				msg="ok";
			}
			
		
			
			//**********************************************
			//load_dashboard_main
			//**********************************************
			if (action.equals("load_dashboard_main")) {
				html=loadDashboardMain(conn, session, application);			
				msg="ok";
			}
			
			//**********************************************
			//make_run_mad_dashboard_view_dlg
			//**********************************************
			if (action.equals("make_run_mad_dashboard_view_dlg")) {
				String view_id=par1;
				String target_div=par2;
				String runMode=par3;
				
				html=makeRunMadDashViewDlg(conn, session, view_id, target_div, runMode);			
				msg="ok";
			}
			
			//**********************************************
			//run_mad_dashboard_view
			//**********************************************
			if (action.equals("run_mad_dashboard_view")) {
				String running_view_id=par1;
				String view_user_title=par2;
				String run_parameters=par3;
				String runMode=par4;
				String target_div_id=par5;
				
				
				
				html=runMadDashView(conn, session, application, running_view_id, view_user_title, run_parameters, runMode, target_div_id);			
				msg="ok";
			}
			
			//**********************************************
			//build_dashboard_view
			//**********************************************
			if (action.equals("build_dashboard_view")) {
				String divid=par1;
				
				html=buildDashBoardDiv(conn,session, application, divid);
				msg="ok";
			}
			
			//**********************************************
			//download_dashboard_data
			//**********************************************
			if (action.equals("download_dashboard_data")) {
				String view_id=par1;
				String divid=par2;
				
				String filename=downloadDashboardViewData(conn,session, application, view_id, divid);
				
				if (filename.length()==0) {
					html="-";
					msg="nok:data cannot be downloaded.";
				}
				else {
					html="-";
					msg="ok:javascript:downloadDashboardDataGet('"+filename+"')";
				}
				
			}
			
			//**********************************************
			//remove_dashboard_view
			//**********************************************
			if (action.equals("remove_dashboard_view")) {
				String view_id=par1;
				String divid=par2;
				
				removeDashBoardDiv(conn,session, divid);
				
				html=buildDashBoardDiv(conn,session, application, divid);
				msg="ok";
			}
			
			//**********************************************
			//change_dashboard_layout
			//**********************************************
			if (action.equals("change_dashboard_layout")) {
				String layout=par1;
				
				changeDashboardLayout(conn,session,layout);
				
				html="-";
				msg="ok:javascript:reloadCurrentPage()";
			}
			
			//**********************************************
			//make_dashboard_configuration_window
			//**********************************************
			if (action.equals("make_dashboard_configuration_window")) {
				String view_id=par1;
				String divid=par2;
				
				html=buildDashBoardConfigurationWindow(conn,session, view_id, divid);
				msg="ok";
			}
			
			//**********************************************
			//save_dashboard_view_config
			//**********************************************
			if (action.equals("save_dashboard_view_config")) {
				String config_id=par1;
				String original_vals=par2;
				String height=par3;
				String notification_info=par4;

				String refresh_by=notification_info.split(",")[0];
				String refresh_interval=notification_info.split(",")[1];
				String send_notification=notification_info.split(",")[2];
				String notification_groups="";
				try {notification_groups=notification_info.split(",")[3];} catch(Exception e) {}
				
				saveDashboardViewConfig(conn,session,config_id, height, refresh_by, refresh_interval, send_notification, notification_groups);
				
				
				html="-";
				
				if (original_vals.equals(height+"_"+refresh_by+"_"+refresh_interval)) 
					msg="ok";
				else
				    msg="ok:javascript:reloadCurrentPage()"; 
			}
			
			//**********************************************
			//make_sort_field_configuration
			//**********************************************
			if (action.equals("make_sort_field_configuration")) {
				html=makeSortFieldsConfiguration(conn,session);
				msg="ok";	
			}
			
			
			//**********************************************
			//add_remove_sort_field
			//**********************************************
			if (action.equals("add_remove_sort_field")) {
				
				
				String action_and_id=par1;
				String addremove="ADD";
				String field_name="";
				try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
				try {field_name=action_and_id.split(":")[1];} catch(Exception e){}
				
				addRemoveUpdateSortField(conn,session,addremove,field_name,"asc"); 
				
				html="-";
				msg="ok:javascript:makeSortFieldsConfiguration();";	
				
				
			}
			
			//**********************************************
			//set_sort_field_direction
			//**********************************************
			if (action.equals("set_sort_field_direction")) {
				String field_name=par1;
				String sort_ascdesc=par2;
				
				addRemoveUpdateSortField(conn,session,"UPDATE",field_name,sort_ascdesc); 
				
				html="-";
				msg="ok:javascript:makeSortFieldsConfiguration();";	
			}
			
			
			//**********************************************
			//set_sort_field_direction_and_reload_list
			//**********************************************
			if (action.equals("set_sort_field_direction_and_reload_list")) {
				String field_name=par1;
				String sort_ascdesc=par2;
				
				
				
				addRemoveUpdateSortField(conn,session,"UPDATE",field_name,sort_ascdesc); 
				
				html="-";
				msg="ok:javascript:reloadRequestList(false)";	
			}

			//**********************************************
			//remove_sort_field_and_reload_list
			//**********************************************
			if (action.equals("remove_sort_field_and_reload_list")) {
				String field_name=par1;
				
				addRemoveUpdateSortField(conn,session,"REMOVE",field_name,"x"); 
				
				html="-";
				msg="ok:javascript:reloadRequestList(false);";	
			}
			
			
			//**********************************************
			//do_login
			//**********************************************
			if (action.equals("do_login")) {
				
				String input_username=par1;
				String input_password=par2;
				
				
				boolean is_connection_ok=doLoginAttempt(conn, session, input_username, input_password);
				
				
				

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
					msg="ok:javascript:gotoHome()";
					break;
					 
				}
				else 
					msg="ok:javascript:showLoginError()";
				
			}
			
			
			//**********************************************
			//list_parent_requests
			//**********************************************
			if (action.equals("list_parent_requests")) {
				String request_id=par1;
				html=getListOfParentRequests(conn,session, request_id);
				msg="ok";	
			}
			
			//**********************************************
			//test_mad_method
			//**********************************************
			if (action.equals("test_mad_method")) {
				String method_id=par1;
				String action_method_id=par2;
				
				html=testMadMethod(conn,session, method_id, action_method_id);
				msg="ok";	
			}
			
			//**********************************************
			//execute_mad_method
			//**********************************************
			if (action.equals("execute_mad_method")) {
				String test_method_id=par1;
				String test_action_method_id=par2;
				String test_request_id=par3;
				String parameters=par4;
				
				session.setAttribute("test_request_id", test_request_id);
				
				html=executeMadMethod(conn,session, test_method_id, test_action_method_id, test_request_id, parameters);
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
			//open_method_call_log_details
			//**********************************************
			if (action.equals("open_method_call_log_details")) {
				String log_id=par1;
				
				html=getMethodCallLogDetail(conn,session,log_id);
				msg="ok";	
			}
			
			//**********************************************
			//open_method_call_log_details
			//**********************************************
			if (action.equals("set_lov_field_value")) {
				String request_id=par1;
				String flex_field_id=par2;
				String element_id=par3;
				String width=par4;
				String lov_value=par5;
				
				
				int width_int=0;
				try{width_int=Integer.parseInt(width);} catch(Exception e) {width_int=0;}
				

				String entry_title="";
				String lov_sql="";
				String lov_env_id="";
				
				
				html=makeLovFlexField(conn, session, element_id, lov_sql, lov_value ,width_int, lov_env_id, "EDITABLE",flex_field_id, entry_title, request_id);
				msg="ok:javascript:validateAllRequestFlexFields('"+request_id+"')";	
			}
			
			
			//**********************************************
			//reload_db_repository_object_list
			//**********************************************
			if (action.equals("reload_db_repository_object_list")) {
				String package_id=par1;
				String application_id=par2;
				String schema=par3;
				String object_type=par4;
				String object_filter=par5;
				
				html=getObjectListFromDbRepository(conn,session,package_id,application_id ,schema,object_type,object_filter);
				msg="ok";	
			}
			
			//**********************************************
			//show_checkout_history
			//**********************************************
			if (action.equals("show_checkout_history")) {
				String application_id=par1;
				String member_path=par2; 


				
				html=showCheckOutHistory(conn,session,application_id,member_path);
				msg="ok";	
			}
			
			//**********************************************
			//duplicate_mad_platform_type
			//**********************************************
			if (action.equals("duplicate_mad_platform_type")) {
				String platform_type_id=par1;
				
				 
				duplicateMadPlatformType(conn,session,platform_type_id);
				html="-";
				msg="ok:javascript:makeMadPlatformTypeList()";
				
			}
			//**********************************************
			//duplicate_mad_platform
			//**********************************************
			if (action.equals("duplicate_mad_platform")) {
				String platform_id=par1;
				
				 
				duplicateMadPlatform(conn,session,platform_id);
				html="-";
				msg="ok:javascript:makeMadPlatformList()";
				
			}
			//**********************************************
			//duplicate_mad_modifier_group
			//**********************************************
			if (action.equals("duplicate_mad_modifier_group")) {
				String modifier_group_id=par1;
				
				 
				duplicateMadModifierGroup(conn,session,modifier_group_id); 
				html="-";
				msg="ok:javascript:makeMadModifierGroupList()";
				
			}
			//**********************************************
			//duplicate_mad_application
			//**********************************************
			if (action.equals("duplicate_mad_application")) {
				String application_id=par1;
				
				 
				duplicateMadApplication(conn,session,application_id);
				html="-";
				msg="ok:javascript:makeMadApplicationList()";
				
			}
			//**********************************************
			//duplicate_mad_flow
			//**********************************************
			if (action.equals("duplicate_mad_flow")) {
				String flow_id=par1;
				
				 
				duplicateMadFlow(conn,session,flow_id);
				html="-";
				msg="ok:javascript:makeMadFlowList()";
				
			}
			//**********************************************
			//duplicate_mad_request_type
			//**********************************************
			if (action.equals("duplicate_mad_request_type")) {
				String request_type_id=par1;
				
				 
				duplicateMadRequestType(conn,session,request_type_id);
				html="-";
				msg="ok:javascript:makeMadRequestTypeList()";
				
			}
			//**********************************************
			//remake_calculated_field
			//**********************************************
			if (action.equals("remake_calculated_field")) {
				String request_id=par1;
				String flex_field_id=par2;
				String field_index=par3;
				String depended_field_values=par4;
				

				
				
				
				//for (int i=0;i<values.size();i++) System.out.println(values.get(i)[0]+":"+values.get(i)[1]);
				
				String field_object_id="entry_TAB"+request_id+"_flex_field_id_"+field_index;
				
				//String curr_val="recalculated "+field_object_id+" "+(new Date().toString());
				String curr_val=calculateFieldValue(conn, session, flex_field_id, depended_field_values);

				html=makeCalculatedFlexField(
						conn,
						session,
						request_id,
						flex_field_id,
						Integer.parseInt(field_index),
						curr_val
						);
				
				msg="ok:javascript:redrawDependedFields('"+request_id+"','"+field_object_id+"');";
				
			}
			htmlArr.add(html);
			divArr.add(div); 
			
			if (action.length()>0) {
				obj.put("html"+(a+1), htmlArr.get(a));
				obj.put("div"+(a+1), divArr.get(a));	
				
				long duration=System.currentTimeMillis()-start_ts;
				
				makeAjaxCallLog(conn,session, request, action, div, par1,par2,par3,par4,par5, msg, duration);
				
			}
			
			html="";
			div="";
	
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

