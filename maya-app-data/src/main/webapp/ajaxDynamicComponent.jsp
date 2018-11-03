<%@include file="header2.jsp"%> 


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
String par6="";





try {
	action=nvl(request.getParameter("action"),"-");

	div=nvl(request.getParameter("div"),"-");
	par1	=	nvl(request.getParameter("par1"),"");
	par2	=	nvl(request.getParameter("par2"),"");
	par3	=	nvl(request.getParameter("par3"),"");
	par4	=	nvl(request.getParameter("par4"),"");
	par5	=	nvl(request.getParameter("par5"),"");
	par6	=	nvl(request.getParameter("par6"),"");


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
	String[] arr_par6=par6.split(curr_param_delimiter);
	
	
	for (int a=0;a<arr_action.length;a++) {

		
		try {action=arr_action[a];} catch(Exception e) {action="";}
		try {div=arr_div[a];} catch(Exception e) {div="";}
		try {par1=arr_par1[a];} catch(Exception e) {par1="";}
		try {par2=arr_par2[a];} catch(Exception e) {par2="";}
		try {par3=arr_par3[a];} catch(Exception e) {par3="";}
		try {par4=arr_par4[a];} catch(Exception e) {par4="";}
		try {par5=arr_par5[a];} catch(Exception e) {par5="";}
		try {par6=arr_par6[a];} catch(Exception e) {par6="";}
		
		par1=par1.replaceAll("\\*\\*NEWLINE\\*\\*", "\n");
		par2=par2.replaceAll("\\*\\*NEWLINE\\*\\*", "\n");
		par3=par3.replaceAll("\\*\\*NEWLINE\\*\\*", "\n");
		par4=par4.replaceAll("\\*\\*NEWLINE\\*\\*", "\n");
		par5=par5.replaceAll("\\*\\*NEWLINE\\*\\*", "\n");
		par6=par6.replaceAll("\\*\\*NEWLINE\\*\\*", "\n");
		



		/*
		System.out.println("action="+action);
		System.out.println("par1="+par1);
		System.out.println("par2="+par2);
		System.out.println("par3="+par3);
		System.out.println("par4="+par4);
		System.out.println("par5="+par5);
		System.out.println("par6="+par6);
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
		

		html="";
		//msg="";
		

		if (msg.indexOf("nok:")==-1) {	

			

			//**********************************************
			//fill Application Type 
			//**********************************************
			if (action.equals("fill_app_type")) {
				String curr_app_type=nvl(par1,"MASK");

				
			   	sql="select 'MASK' a, 'Static Masking' b from dual union all "+
			   		"select 'DMASK' a, 'Dynamic Masking' b from dual union all "+
			   		"select 'COPY' a, 'Copying' b from dual union all " + 
			   		"select 'DPOOL' a, 'Data Pool' b from dual  ";
			    
			    html="<table class=\"table .table-striped\"><tr>";
			   	html=html+"<td>";
			   	html=html+makeCombo(conn, sql, "filter_app_type", "id=filter_app_type size=1  onchange=fillAppList();", curr_app_type, 0);
			   	html=html+"</td>";
			   	html=html+"</tr></table>";
			   	
			    msg="ok";
			}

			//**********************************************
			//get_app_script
			//**********************************************
			if (action.equals("get_app_script")) {

				String app_id=par1;
				String script_type=par2;
				
			   	sql="select "+script_type+ " from tdm_apps where id="+app_id;
			   	String script=getDBSingleVal(conn, sql);
			   	html=html +"<center><textarea id=ascript rows=20 style=\"width:100%; background-color:black; color:white; font-family:Courier New, Courier, monospace;\">"+script+"</textarea></center>";
	
			    msg="ok";
			}

			//**********************************************
			//save_app_script
			//**********************************************
			if (action.equals("save_app_script")) {

				String app_id=par1;
				String script_type=par2;
				String script=par3;
				log_trial(conn, "tdm_apps", Integer.parseInt(app_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
			   	sql="update tdm_apps set  "+script_type+ "=? where id="+app_id;

			   	bindlist=new ArrayList<String[]>();
			   	bindlist.add(new String[]{"STRING",script});
			   	execDBConf(conn, sql, bindlist);
			   	
			   	msg="ok";
			}

			
			//**********************************************
			//show_sql_editor
			//**********************************************
			if (action.equals("show_sql_editor")) {
				String env_id=par1;
				String tab_id=par2;
				String tab_name=par3;
				String in_sql=par4;
				String cat=par5;
				
				
				html=makeSqlEditorWindow(conn,session, env_id, tab_id, tab_name, in_sql, cat);
			    msg="ok:javascript:fillSqlEditorResult()";
			}
			
			//**********************************************
			//make_sql_editor_catalog_combo
			//**********************************************
			if (action.equals("make_sql_editor_catalog_combo")) {
				String env_id=nvl(par1,"");
				
				html=makeSqlEditorCatalogCombo(conn,session, env_id,"");
			    msg="ok";
			}

			//**********************************************
			//fill_sql_editor_results
			//**********************************************
			if (action.equals("fill_sql_editor_results")) {
				String env_id=par1;
				String query_catalog=par2;
				String sql_statement=par3;
				String querying_table=par4;
				
				
				html=fillSqlEditorResult(conn,session, env_id, query_catalog, sql_statement, querying_table);
			    msg="ok:javascript:runPostQueryExecution()";
			}
			
			//**********************************************
			//fill Application Name
			//**********************************************
			if (action.equals("fill_app_list")) {
				String filter_app_type=par1;
				String curr_app_id=par2;
				
				session.setAttribute("app_type", filter_app_type);
				
			    sql="select id, name from tdm_apps where app_type='"+filter_app_type+"'  order by name " ;
			   
			    html="<table class=\"table table-condensed\"><tr>";
			    
			    html=html+"<td>";
			    html=html+"<b>Application : </b>";
			    html=html+"</td>";
			    
			    
			    html=html+"<td>";
			    html=html+makeCombo(conn, sql, "filter_app_id", "id=filter_app_id  onchange=fillEnvList();", curr_app_id, 0);
			    html=html+"</td>";

			    html=html+"<td>";
			    html=html+makeAppActionMenu(filter_app_type);
			    html=html+"</td>";
			    
			    html=html+"<td>";
			    html=html+""+
					    "<button type=\"button\" class=\"btn btn-default  btn-sm\"  onclick=\"openRunDialog();\" data-toggle=\"tooltip\" data-placement=\"left\" title=\"Run this application\">\n"+
			    		"<font color=green><span class=\"glyphicon glyphicon-play\">"+"</span></font>\n"+
			    	"</button>\n";
			    
			    html=html+"</td>";
			    
		    			
		    
			    html=html+"</tr></table>";
			    
			    msg="ok:javascript:fillAppTabList();  fillSchemaDomainInstanceList(); ";
			}

			//**********************************************
			//add_application, remove_application, rename_application
			//**********************************************
			if (action.equals("add_application") || action.equals("remove_application") || action.equals("rename_application")) {
				
				
				
				
				int app_id=0;
				String app_name=par2;
				
				try {app_id=Integer.parseInt(par1);} catch(Exception e)  {app_id=0;}
				
				if (action.equals("add_application") || action.equals("rename_application")) {
					bindlist=new ArrayList<String[]>();
					bindlist.add(new String[]{"STRING",app_name});
					sql="select id from tdm_apps where name=?";
					ArrayList<String[]> checkArr=getDbArrayConf(conn, sql, 1, bindlist);
					if (checkArr.size()>0) {
						msg="nok:There is another application with the same name ["+app_name+"].";
					} 
					else
					{
						if (action.equals("rename_application")) {
							bindlist=new ArrayList<String[]>();
							bindlist.add(new String[]{"STRING",app_name});
							bindlist.add(new String[]{"INTEGER",""+app_id});
							sql="update tdm_apps set name=? where id=?";
							log_trial(conn, "tdm_apps", app_id, nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
							execDBConf(conn, sql, bindlist);
			
							msg="ok";
						}
						
						if (action.equals("add_application")) {
							String app_type=par1;
							
							bindlist=new ArrayList<String[]>();
							bindlist.add(new String[]{"STRING",app_name});
							bindlist.add(new String[]{"STRING",app_type});
							sql="insert into tdm_apps (name, app_type)  values (?,?)";
							execDBConf(conn, sql, bindlist);
			
							bindlist=new ArrayList<String[]>();
							bindlist.add(new String[]{"STRING",app_name});
							sql="select max(id) x from tdm_apps where name=?";
							
							String new_app_id="";
							try {
								new_app_id=getDbArrayConf(conn, sql, 1, bindlist).get(0)[0];
							} catch(Exception e) {
								new_app_id="";
							}
							
							html="javascript:curr_app_id=\""+new_app_id+"\";";
							msg="ok";
						}
						
					}
					
				}
				else {
					
					sql="select count(*) from tdm_work_plan where app_id="+app_id;
					String countx=getDBSingleVal(conn, sql);

					if (countx.equals("0")) {

						bindlist=new ArrayList<String[]>();
						bindlist.add(new String[]{"INTEGER",""+app_id});
						
						sql="delete from tdm_tabs_rel where tab_id in (select id from tdm_tabs where app_id=?)";
						execDBConf(conn, sql, bindlist);

						sql="delete from tdm_fields where tab_id in (select id from tdm_tabs where app_id=?)";
						execDBConf(conn, sql, bindlist);

						sql="delete from tdm_tabs where app_id=?";
						execDBConf(conn, sql, bindlist);

						sql="delete from tdm_apps where id=?";
						execDBConf(conn, sql, bindlist);
						html="-";
						msg="ok:javascript:fillAppList()";
					}
					else {
						html="-";
						msg="nok: This application can't be deleted. At least 1 work plan linked.";		
						
					}
				
				}

			}
			
			
			//**********************************************
			//fill Environment List
			//**********************************************
			if (action.equals("fill_env_list")) {
				String app_id=par1;
				String env_id=par2;
				String app_type=par3;
				
				session.setAttribute("app_id", app_id);
				session.setAttribute("app_table_filter", "");
				
				html="<table class=\"table .table-striped\"><tr>";
	        			
	       
	        	sql = " select id, name from tdm_envs where for_design='YES' order by name ";
	        	
	        	
	        	
	        	
		    	html=html+"<td nowrap><b>Database : </b></td>";
	        	html=html+"<td nowrap>";
		    	html=html + makeCombo(conn, sql, 
		        			"envList", 
		        			"id=envList  onchange=fillSchemaDomainInstanceList()", 
		        			env_id, 
		        			0);
	        	html=html+"</td>";
			
		        
	        	html=html+"<td nowrap>";


			   html=html+makeEnvActionMenu(app_type);
    		   html=html+"</td>";
		       html=html+"</tr></table>";
		        msg="ok:javascript:fillSchemaDomainInstanceList()";
			}
			
			
			
			//**********************************************
			//fill Table Design Header
			//**********************************************
			if (action.equals("fill_table_list_header")) {
				String env_id=nvl(par1,"0");
				String to_refresh=nvl(par2,"-");

				html=fillTableListHeader(conn,session,env_id,to_refresh); 
						        
				msg="ok:javascript:fillTableList();";
			}
			
			//**********************************************
			//fill Schema List
			//**********************************************
			if (action.equals("fill_schema_list")) {
				String catalog=par1; 
				String env_id=nvl(par2,"0");
				
				session.setAttribute("catalog_name_filter_for_"+env_id, catalog);

				html=fillSchemaList(conn,session,env_id,catalog);  
						        
				msg="ok:javascript:fillTableList()";
			}
			
			
			//**********************************************
			//fill Table List
			//**********************************************
			if (action.equals("fill_table_list")) {
				
				String cat_schema_filter=par1;
				String[] arr=cat_schema_filter.split("\\|");
				
				String catalog_filter="All";
				String owner_filter="All";
				
				try {catalog_filter=arr[0];} catch(Exception e) {}
				try {owner_filter=arr[1];} catch(Exception e) {}
				
				
				
				if (owner_filter.equals("-")) owner_filter="All";
				
				
				
				String env_id=nvl(par2,"0");
				String app_type=nvl(par3,"MASK");
				String table_name_filter=par4.trim();
				String other_filters=par5;
				if (table_name_filter.equals("undefined")) table_name_filter="";
				
				String include_added_tables="";
				String include_commented_tables="";
				String include_discarded_tables="";
				
				try {include_added_tables=other_filters.split(":")[0];} catch(Exception e) {} 
				try {include_commented_tables=other_filters.split(":")[1];} catch(Exception e) {}
				try {include_discarded_tables=other_filters.split(":")[2];} catch(Exception e) {}
				
				
				session.setAttribute("catalog_name_filter_for_"+env_id, catalog_filter);
				session.setAttribute("schema_name_filter_for_"+env_id, owner_filter);
				session.setAttribute("table_name_filter_for_"+env_id,table_name_filter);


				session.setAttribute("include_added_tables_for_"+env_id,include_added_tables);
				session.setAttribute("include_commented_tables_for_"+env_id,include_commented_tables);
				session.setAttribute("include_discarded_tables_for_"+env_id,include_discarded_tables);
				

				
				if (env_id.equals("0")) {
					html="-";
					msg="ok";
				}
				else 
				 {
					html=fillTableListInDB(conn, session, env_id, app_type);
					msg="ok";
				 
						
				} 
	
				
			}
			
			//**********************************************
			//fill_app_table
			//**********************************************
			if (action.equals("fill_app_table")) {
				String app_id=nvl(par1,"0");
				String filter=par2;
				
				
				if (app_id.equals("0")) {
					html="Select an application to see content.";
					msg="ok";
				} else {
					html=fillAppTables(conn,session,app_id,filter);
					msg="ok";
				}
				
				
				
					
				
			}
	
			
			//**********************************************
			//fill Table Details
			//**********************************************
			if (action.equals("fill_table_details")) {
				String tab_id=par1;
				String env_id=par2;
				if (env_id.equals("x")) env_id="0";
				
				String readonly="";
				if (env_id.equals("0")) readonly="readonly";
				
				
				session.setAttribute("tab_id", tab_id);
		        
	            sql="select t.cat_name, t.schema_name, t.tab_name, t.tab_desc, t.mask_level, t.tab_filter, " +
	            		" t.tab_order_stmt, t.parallel_function, t.parallel_field, t.parallel_mod, "+
	            		" t.partition_flag, t.partition_used, " +
	            		" a.app_type, t.recursive_fields, family_id, rollback_needed, export_plan " + 
	            		" from tdm_tabs t, tdm_apps a   "+
	            		" where t.id=? and t.app_id=a.id ";
	
	            bindlist=new ArrayList<String[]>();
	            bindlist.add(new String[]{"INTEGER",tab_id});
	
	            ArrayList<String[]> tabfields=getDbArrayConf(conn, sql, 1, bindlist);
	
				String table_catalog=tabfields.get(0)[0];
	            String table_owner=tabfields.get(0)[1];
	            String table_name=tabfields.get(0)[2];
	
	            String table_title=(table_catalog+"."+table_owner+"."+table_name).replace("${default}.", "");
	            
	            String tab_desc=tabfields.get(0)[3];
	            String mask_level=tabfields.get(0)[4];
	            String tab_filter=tabfields.get(0)[5];
	            String tab_order_stmt=tabfields.get(0)[6];
	            String parallel_function=tabfields.get(0)[7];
	          	String parallel_field=tabfields.get(0)[8];
	            String parallel_mod=tabfields.get(0)[9];
	            String partition_flag=tabfields.get(0)[10];
	            String partition_used=tabfields.get(0)[11];
	            String app_type=tabfields.get(0)[12];
	            String recursive_fields=tabfields.get(0)[13];
	            String family_id=tabfields.get(0)[14];
	            String rollback_needed=tabfields.get(0)[15];
	            String export_plan=tabfields.get(0)[16];
		        
	            StringBuilder sb=new StringBuilder();
	            
	            
	            sql="select  id from tdm_fields where tab_id="+ tab_id +
	            	" and mask_prof_id in (select id from tdm_mask_prof where rule_id='KEYMAP')";
	            int keymap_field_id=0;
	            
	            try {
	            	keymap_field_id=Integer.parseInt(getDBSingleVal(conn, sql));
	            } catch(Exception e) {
	            	
	            }
	            

            	sb.append("<input type=hidden id=keymap_field_id value=\""+keymap_field_id+"\">");
	            
	            
	            sb.append("<table class=\"table table-condensed table-striped\" >");
	            
	            sb.append("<tr class=\"active\">");
	            
	            
	            
	            sb.append("<td>");
	            sb.append("<span class=\"label label-danger\"><b>"+ table_title +"</b></span>");
	            sb.append("</td>");
	            
	            
	            sb.append("<td align=right>");
	            
	            
	            if (app_type.equals("DMASK")) {
	            	sb.append("<span id=exception_TABLE_"+tab_id+">");
					sb.append(makeExceptionButton(conn, session, "TABLE",tab_id));
					sb.append("</span> ");
	            }
            	
	            
	            if (!readonly.equals("readonly")) 
	            	sb.append(" <button type=\"button\" class=\"btn btn-default btn-sm\" onclick=\"showcontentbytabid('"+tab_id+"')\" data-toggle=\"tooltip\" data-placement=\"left\" title=\"Show Table Content\">" +
			                "<font color=blue><span class=\"glyphicon glyphicon-list-alt\"></span></font>"+
			         	  "</button>");
	            
	            if (!app_type.equals("DMASK")) 
		            sb.append(" <button type=\"button\" class=\"btn btn-default btn-sm\" onclick=\"showtabconfig('"+tab_id+"')\" data-toggle=\"tooltip\" data-placement=\"left\" title=\"Show Table Configuratiob\">" +
			                "<font color=black><span class=\"glyphicon glyphicon-cog\"></span></font>"+
			         	  "</button>");
		            
	            
	            
	            
	            sb.append("</td>");
	           
	            
	            sb.append("</tr>");

	            
	            
	            
	            sb.append(
	            		"<tr>"+
	            			"<td align=right style=\"vertical-align:bottom;\">" + 
	            				"<b>Description : </b>"+
	            			"</td>" +
	            			"<td style=\"vertical-align:bottom;\">"+
	            			"<input type=text id=tab_desc name=tab_desc size=60 maxlength=1000 value=\""+codehtml(tab_desc)+"\" style=\"width:100%;\"  onchange=savetabinfo()>"+
	            			"</td>" +
	            		"</tr>"
	            );
	            
	            
	            
            	sb.append(
	            		"<tr>"+
	            			"<td align=right style=\"vertical-align:bottom;\">" +
	            				"<b>Table Filter :</b> "+
	            					" (<small><b>${this}</b> for table alias.</small>)"+
	            				"</td>" +
	            			"<td nowrap style=\"vertical-align:bottom;\">"+
	            			"<input "+readonly+" type=text id=tab_filter name=tab_filter size=60 maxlength=1000 value=\""+codehtml(tab_filter)+"\" onkeypress=\"return isEnvSelected()\"; style=\"width:100%;\" onchange=validateTableFilter()>"+
	            			"</td>" +
	            		"</tr>"
	            		);
	          
	            
				if (!app_type.equals("DMASK")) {

					
		            
	
		            
		            
		            if (parallel_function.equals("MOD") || parallel_function.equals("%") || parallel_function.equals("$mod")) {
		            	
			            ArrayList<String[]> arr=new ArrayList<String[]>();
			            arr=new ArrayList<String[]>();
			            for (int i=1;i<100;i++) {
			            	arr.add(new String[]{""+i,""+i});
			            }
			            arr.add(new String[]{"150","150"});
			            arr.add(new String[]{"200","200"});
			            arr.add(new String[]{"250","250"});
			            arr.add(new String[]{"300","300"});
			            arr.add(new String[]{"500","500"});
			            
			            sb.append(
			            		"<tr>"+
			            			"<td align=right style=\"vertical-align:bottom;\">"+
			            				"<b>Paralelism Count : </b>" +
			            			"<td style=\"vertical-align:bottom;\">"+
			            			makeComboArr(arr, "parallel_mod", "id=parallel_mod size=1 onchange=savetabinfo()", nvl(parallel_mod,"1"),100)+
			            			"</td>" +
			            		"</tr>"
			            );
		            	
		            
			            sb.append(
			            		"<tr>"+
			            			"<td align=right style=\"vertical-align:bottom;\">"+
			            				"<b>Paralelism Formula : </b>" +
			            			"</td>");
			            if (parallel_function.equals("MOD"))
				            sb.append(
				            			"<td style=\"vertical-align:center;\">"+
		            					"<small><b><font color=red>Mod(</font></b>"+
		            						"<input "+readonly+" type=text id=parallel_field name=parallel_field size=50 maxlength=200 value=\""+parallel_field+"\"  onkeypress=\"return isEnvSelected()\";  onchange=validateTableParallelField()>"+
		            					"<b><font color=blue>,[Paralelism Count])</font>=<font color=green>:?</font></b>"+
	           							" <a href=\"javascript:showsample();\"><span class=\"glyphicon glyphicon-question-sign btn-sm\"></span></a>"+	            			
		            					"</small></td>"
				            );
			            
			            if (parallel_function.equals("%"))
				            sb.append(
				            			"<td style=\"vertical-align:center;\">"+
		            					"<input "+readonly+" type=text id=parallel_field name=parallel_field size=30 maxlength=200 value=\""+parallel_field+"\"  onkeypress=\"return isEnvSelected()\";  onchange=validateTableParallelField()>"+
		            					"<small><b><font color=red><big> % </big></font></b>"+
		            					"<b><font color=blue> [Paralelism Count])</font>=<font color=green>:?</font></b>"+
	           							" <a href=\"javascript:showsample();\"><span class=\"glyphicon glyphicon-question-sign btn-sm\"></span></a>"+	            			
		            					"</small></td>"
				            );	
			            if (parallel_function.equals("$mod"))
				            sb.append(
				            			"<td style=\"vertical-align:bottom;\">"+
		            					"<input "+readonly+" type=text id=parallel_field name=parallel_field size=60 maxlength=200 value=\""+codehtml(parallel_field)+"\"  onkeypress=\"return isEnvSelected()\";  onchange=validateTableParallelField()>"+
		            					" <a href=\"javascript:showmongosample();\"><span class=\"glyphicon glyphicon-question-sign btn-lg\"></span></a>"+
		            					"</td>"
				            );	
				            
			            sb.append("</tr>");            	
		            } //if (parallel_function.equals("MOD") || parallel_function.equals("%") )
	
		            if (!env_id.equals("0")) {

		            	
		            	String update_partition_flag=getPartitionFlag(conn,env_id,table_catalog, table_owner, table_name);
		            	if (!partition_flag.equals(update_partition_flag)) {
		            		
		            		
		            		sql="update tdm_tabs set partition_flag=? where id=?";
		            		bindlist.clear();
		            		bindlist.add(new String[]{"STRING",update_partition_flag});
		            		bindlist.add(new String[]{"INTEGER",tab_id});
		            		
		            		boolean is_updated=execDBConf(conn, sql, bindlist);
		            		if (is_updated) partition_flag=update_partition_flag;
		            	}
		            }
	
		            if (partition_flag.equals("YES")) {
		            	
		            	String partition_use_checkbox="";
		            	sql="select 'YES','Use Partitioning' from dual union all select 'NO','Dont Use' from dual";
		            	partition_use_checkbox=makeCombo(conn, sql, "partition_use", "size=1 id=partition_use onchange=savetabinfo()", partition_used, 250);
	
		            	sb.append(
			            		"<tr>"+
			            			"<td align=right style=\"vertical-align:bottom;\">"+
			            				"<b>Use Partitioning : </b>" +
			            			"<td style=\"vertical-align:center;\">"+
			            				partition_use_checkbox+
			            			"</td>" +
			            		"</tr>"
			            );
		            } //if (partition_flag.equals("YES"))
		            	
		            if (app_type.equals("COPY")) 	 {
		            	
		            	
		            	
			            	sb.append( "<tr>"+
					    			"<td align=right style=\"vertical-align:top;\">"+
					    				"<b>Database Family : </b>" +
					    			"<td style=\"vertical-align:top;\">");
			            	sql="select id, family_name from tdm_family order by 2";
			            	
							sb.append(makeCombo(conn, sql, "", "size=1 id=family_id onchange=savetabinfo()", family_id, 0));
	            			sb.append("</td>" +
								"</tr>");
		            		
		            	 
		            		sb.append( "<tr>"+
					    			"<td align=right style=\"vertical-align:top;\">"+
					    				"<b>Parent Table : </b>" +
					    			"<td style=\"vertical-align:top;\">");
		            		sb.append("<div id=parentTabInfoDiv"+tab_id+">");
		            		sb.append(refillParentTable(conn, session, tab_id)); 
		            		sb.append("</div>");
	
		            		sb.append("</td>" +
								"</tr>");
		            	
		            		sb.append( "<tr>"+
					    			"<td align=right style=\"vertical-align:top;\">"+
					    				"<b>Recursive On Field(s) : </b>" +
					    			"<td style=\"vertical-align:top;\">");
		            		
		            		sql="select field_name from tdm_fields where tab_id=? order by 1";
		            		bindlist.clear();
		            		bindlist.add(new String[]{"INTEGER",tab_id});
		            		ArrayList<String[]> source_arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
		            		ArrayList<String[]> picked_arr=new ArrayList<String[]>();
		            		String[] recursiveArr=recursive_fields.split("\\|::\\|");
		            		for (int r=0;r<recursiveArr.length;r++) {
		            			String recursivefield=recursiveArr[r];
		            			if (recursivefield.length()==0) continue;
		            			picked_arr.add(new String[]{recursivefield});
		            		}
		           			
		            		sb.append(makePickList("0", "recursive_fields", source_arr, picked_arr, "", "setRecursiveFields('"+tab_id+"')"));
		            		sb.append("</td>" +
								"</tr>");
	            		
		            		
		            		
		            	
		            	
		            	
		            	
		            	sb.append( "<tr>"+
				    			"<td align=right style=\"vertical-align:top;\">"+
				    				"<b>Needs : </b>" +
				    			"<td style=\"vertical-align:top;\">"+
				    				"<div id=tabNeedDivFor"+tab_id+">"+
			    					makeTableNeedList(conn, tab_id, false)+
			    					"</div>"+
				    			"</td>" +
							"</tr>");
		            	
		            	sql="select rel_tab_id, concat(t.schema_name, '.',t.tab_name) "+
			            		" from tdm_tabs_rel tr, tdm_tabs t " + 
			            		" where tr.rel_tab_id=t.id and tr.tab_id=?";
			            	bindlist.clear();
			            	bindlist.add(new String[]{"INTEGER",tab_id});
			            	ArrayList<String[]> arr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
			            	
			            	
		            		sb.append(
		            				"<tr>"+
					    			"<td align=right style=\"vertical-align:top;\">"+
					    				"<b>Child Table(s) : </b>" +
					    			"</td>"+
					    			"<td style=\"vertical-align:top;\">"+
					    			"<a href=\"javascript:discoverCopy('"+tab_id+"','CHILD')\"><span class=\"glyphicon glyphicon glyphicon-eye-open\"></span> discover</a>"	
					    			);
		            		
		            		sb.append("<table border=0 cellspacing=0 cellpadding=0>");
		            		for (int r=0;r<arr.size();r++) {
		            			String child_table_id=arr.get(r)[0];
		            			String child_table_name=arr.get(r)[1];
		            			sb.append("<tr>");
			            		sb.append("<td>");
			            		sb.append("[<a href=\"javascript:openTableScriptDetails(curr_env_id, '"+child_table_id+"')\">"+child_table_name+"</a>]");
			            		sb.append("</td>");
			            		sb.append("</tr>");
			            	}
		            		
		            		sb.append("</table>");
		            		
		            		sb.append("</td>" +
		    						"</tr>");
		            	
		            	
		            	
		            }
		            
		            
		            if (app_type.equals("MASK")) 	 {
		            	
		            	
		            	String export_plan_checkbox="";
		            	sql="select 'EXPORT_MASKING','Exporting & Masking Same Time' from dual "+
		            		" union all "+
		            		" select 'EXPORT_FIRST','Exporting First & Then Masking' from dual "+
		            		" union all "+
		            		" select 'EXPORT_FROM_CTAS','Export from Temporary Table (CTAS First)' from dual "		
		            		;
		            	export_plan_checkbox=makeCombo(conn, sql, "export_plan", "size=1 id=export_plan onchange=savetabinfo()", export_plan, 400);
	
		            	sb.append(
			            		"<tr>"+
			            			"<td align=right style=\"vertical-align:bottom;\">"+
			            				"<b>Export/Masking Policy : </b>" +
			            			"<td style=\"vertical-align:center;\">"+
			            					export_plan_checkbox+
			            			"</td>" +
			            		"</tr>"
			            );
		            	
		            	
		            	String rollback_needed_checkbox="";
		            	sql="select 'YES','YES-Rollback needed' from dual union all select 'NO','NO-Rollback is not needed' from dual";
		            	rollback_needed_checkbox=makeCombo(conn, sql, "rollback_needed", "size=1 id=rollback_needed onchange=savetabinfo()", rollback_needed, 400);
	
		            	sb.append(
			            		"<tr>"+
			            			"<td align=right style=\"vertical-align:bottom;\">"+
			            				"<b>Rollback Need : </b>" +
			            			"<td style=\"vertical-align:center;\">"+
			            					rollback_needed_checkbox+
			            			"</td>" +
			            		"</tr>"
			            );
		            }
	            
	            
				 } //if (!app_type.equals("DMASK"))
	            sb.append("</table>");
	            
	            
	            html=sb.toString();
	            
				msg="ok";
			}
			//**********************************************
			//set_field_filter
			//**********************************************
			if (action.equals("set_field_filter")) {
				String tab_id=par1;
	            String filter=par2;
	            session.setAttribute("is_mask_field_filter_check_"+tab_id, filter);
			}
			//**********************************************
			//fill_field_details
			//**********************************************
			if (action.equals("fill_field_details")) {
				String tab_id=par1;
	            String sel_field_id=nvl(par2,"0");
	            String env_id=nvl(par3,"0");
	            
	            if (env_id.equals("x")) env_id="0";
	            
				StringBuilder sb=new StringBuilder();
				
				String env_db_type=getEnvDBParam(conn, env_id, "DB_TYPE");
				String field_filter_checked=nvl((String) session.getAttribute("is_mask_field_filter_check_"+tab_id),"");

				
				sql="select " +
					" f.id, " + 
					" field_name, " + 
					" field_type, " + 
					" field_size, " + 
					" is_pk, " +
					" mask_prof_id, " + 
					" calc_prof_id, " + 
					" is_conditional, " + 
					" condition_expr, " + 
					" list_field_name, " + 
					" mask_level " + 
					" from tdm_fields f, tdm_tabs t where f.tab_id=t.id and t.id="+tab_id;
				
				
				
				int sel_field_id_INT=0;
				try {
					sel_field_id_INT=Integer.parseInt(sel_field_id);
				} catch(Exception e) {sel_field_id_INT=0;}
				
				if (sel_field_id_INT>0) 
					sql=sql + " and f.id="+sel_field_id;

				sql= sql + " order by f.id";
				
				bindlist=new ArrayList<String[]>();
				ArrayList<String[]> fieldsArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
				
				

				String mask_level="";
				try {mask_level=fieldsArr.get(0)[10];} catch(Exception e) {mask_level="FIELD";}
				
				sql="select id, name from tdm_mask_prof where valid='YES'  order by name";
                if (mask_level.equals("FIELD")) 
                	sql="select id, name from tdm_mask_prof where valid='YES' and rule_id not not in ('GROUP','GROUP_MIX') order by name";
                
                sql="select id, name from tdm_mask_prof where valid='YES' order by name";
                
                bindlist=new ArrayList<String[]>();
                ArrayList<String[]> profArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
                
                
                sql="select t.cat_name, t.schema_name, t.tab_name, a.app_type from tdm_tabs t, tdm_apps a where t.app_id=a.id and t.id=" + tab_id;
                ArrayList<String[]> aTabArr=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>());
                
                String cat=aTabArr.get(0)[0];
                String owner=aTabArr.get(0)[1];
                String table=aTabArr.get(0)[2];
                String app_type=aTabArr.get(0)[3];
                
                //check for missing fields
                boolean is_missing_field=false;
                ArrayList<String[]> dbFields=null;
                		
          		
                if (!env_id.equals("0")) {
                    //dbFields=(ArrayList<String[]>) session.getAttribute("FIELDS_OF_"+env_id+"_"+owner+"_"+table);
                    
                    //if (dbFields==null) 
                    dbFields=getFieldList(conn, app_type, env_id, cat, owner, table,env_db_type);
                           
                    

                    for (int i=0;i<dbFields.size();i++) {
                    	boolean found=false;
                    	System.out.println(""+(i+1)+" ] "+dbFields.get(i)[0]);
                    
                    	for (int j=0;j<fieldsArr.size();j++) {
                    		
                    		if (fieldsArr.get(j)[1].equals(dbFields.get(i)[0])) {
                    			found=true;
                    			break;
                    		}
                    	}
                    	
                    	if (!found) {
                    		is_missing_field=true;                	
                    		break;
                    	}
                    }
                	
                } //if (!env_id.equals("0"))
                
                

                if (sel_field_id_INT==0) {
    				sb.append("<table class=\"table table-striped\" width=\"100%\">");
    				
    				sb.append("<tr>");
    				sb.append("<td colspan=8>");
    				
    				
    				
    				if (app_type.equals("MASK")) {
    					if(field_filter_checked.equals("checked")) 
        					sb.append("<span class=\"label label-danger\">");
        				else 
        					sb.append(" <span class=\"label label-primary\">");
        				
        				sb.append("<input "+field_filter_checked+" type=checkbox value=YES onclick=setTableFieldFilterCheck('"+tab_id+"',this)> <b>Show only masked fields</b>");
        				sb.append("</span>");
    				}
    				
    				if (!app_type.equals("DMASK")) {
    					sb.append(" <button type=button class=\"btn btn-sm btn-default\" onclick=addCalculatedField()>");
        				sb.append(" <font color=green><span class=\"glyphicon glyphicon-plus\"></span></font> Add calculated field");
        				sb.append(" </button>");
    				}

    				
    				if (is_missing_field) {
        				sb.append(
	            			" <button type=\"button\" class=\"btn btn-danger btn-sm\" onclick=addMissingFields()>\n"+
				  			"	<span class=\"glyphicon glyphicon-floppy-add\">!!! New Fields Found. Add Missing Fields Now !!!</span>"+
							" </button>"
				  			);
    					
    				}
    				
    				
    				sb.append("</td>");
    				sb.append("</tr>");
    				
    				sb.append("<tr class=active>");
    				sb.append("<td align=center><span class=\"label label-warning\">CH</span></td>");
    				sb.append("<td align=center><span class=\"label label-warning\">PK</span></td>");
    				sb.append("<td align=left><span class=\"label label-warning\">Name</span></td>");
    				sb.append("<td align=left><span class=\"label label-warning\">Type</span></td>");
    				if (!app_type.equals("DMASK"))
    					sb.append("<td align=center><span class=\"label label-warning\">Cond?</span></td>");
    				sb.append("<td colspan=3 align=left><span class=\"label label-warning\">Change Profile</span></td>");
    				sb.append("</tr>");
    				
    				
    				
                } //if (sel_field_id_INT==0) 
				
                	
               
				
				for (int i=0;i<fieldsArr.size();i++) {
					String field_id=fieldsArr.get(i)[0];
					String field_name=fieldsArr.get(i)[1];
					String field_type=fieldsArr.get(i)[2];
					String field_size=fieldsArr.get(i)[3];
					String is_pk=fieldsArr.get(i)[4];
					String mask_prof_id=nvl(fieldsArr.get(i)[5],"0");
					String calc_prof_id=nvl(fieldsArr.get(i)[6],"0");
					String is_conditional=fieldsArr.get(i)[7];
					String condition_expr=fieldsArr.get(i)[8];
					String list_field_name=fieldsArr.get(i)[9];
					
					
					if (field_filter_checked.equals("checked")) {
						if (	mask_prof_id.equals("0") &&
								!field_type.equals("CALCULATED") &&
								!is_conditional.equals("YES") &&
								!is_pk.equals("YES")
								) continue;
						
						
					}
						sql=sql+" and (mask_prof_id>0 or field_type='CALCULATED' or is_conditional='YES' or is_pk='YES') ";
					
					
                if (sel_field_id_INT==0) 
					sb.append("<tr id=tr_field_"+field_id+">");

                boolean field_ok=false;
                //check if this field is there
                if (!env_id.equals("0")) {
                	for (int f=0;f<dbFields.size();f++) 
                			if (dbFields.get(f)[0].equals(field_name)) {
                				field_ok=true;
                				break;
                			}
                } else 
                	field_ok=true;
                
					sb.append(
							getFieldRow(
									conn,
									session,
									env_db_type,
									app_type,
									field_id,
									field_name,
									field_type,
									field_size,
									is_pk,
									mask_prof_id,
									calc_prof_id,
									condition_expr,
									is_conditional,
									list_field_name,
									profArr,
									field_ok
								)
							);
                
                if (sel_field_id_INT==0) 
					sb.append("</tr>");
				

				} //for 
				
                if (sel_field_id_INT==0) 
					sb.append("</table>");
						
	            	


	            html=sb.toString();
	            
				msg="ok";
			}
			//**********************************************
			//change_field_config
			//**********************************************
			if (action.equals("change_field_config")) {
	            String field_id=par1;
	            String field_name=par2;
	            String field_value=par3;
	            
	            
	            String tab_id=getDBSingleVal(conn, "select tab_id from tdm_fields where id="+field_id);
	            
	            if (field_value.length()==0) {
	            	if (field_name.equals("is_conditional")) field_value="NO";
	            	if (field_name.equals("mask_prof_id")) field_value="0";
	            }
	            
	            if (field_name.equals("mask_prof_id")) 
	            	sql="update tdm_fields set  mask_prof_id=?, is_conditional='NO', condition_expr=null, list_field_name=null, copy_ref_tab_id=0, copy_ref_field_name=null where id=?";
	            if (field_name.equals("calc_prof_id")) 
	            	sql="update tdm_fields set  calc_prof_id=? where id=?";
	            if (field_name.equals("is_pk")) 
	            	sql="update tdm_fields set  is_pk=? ,mask_prof_id=0,is_conditional='NO',condition_expr=null  where id=?";
	            if (field_name.equals("is_conditional")) 
	            	sql="update tdm_fields set  mask_prof_id=0, is_conditional=?,condition_expr=null  where id=?";
	            if (field_name.equals("condition_expr")) 
	            	sql="update tdm_fields set  condition_expr=? where id=?";
	            if (field_name.equals("list_field_name")) {
	           		String curr_val=getDBSingleVal(conn, "select list_field_name from tdm_fields where id="+field_id);
	           		if (curr_val.contains(":FIXED"))  field_value=field_value+":FIXED";
	            
	            	sql="update tdm_fields set  list_field_name=? where id=?";
	            	
	            }
	            
	            
	            
	            if (field_name.equals("list_field_name_fixed")) {
	           		String curr_val=getDBSingleVal(conn, "select list_field_name from tdm_fields where id="+field_id);

	           	 	if (curr_val.contains(":FIXED"))  
	           			field_value=curr_val.split(":")[0]+field_value;
	           	 	else 
	           	 		field_value=curr_val+field_value;
	            	sql="update tdm_fields set  list_field_name=? where id=?";
	            	
	            }
	            	
	           
	            
				if (field_name.equals("delete"))
	            	sql="delete from tdm_fields where id=?";

				bindlist=new ArrayList<String[]>();
				
				if (!field_name.equals("delete")) {
					if (field_name.equals("mask_prof_id") || field_name.equals("calc_prof_id"))
						bindlist.add(new String[]{"INTEGER",field_value});
					else
						bindlist.add(new String[]{"STRING",field_value});
				}

				bindlist.add(new String[]{"INTEGER",field_id});
				
				log_trial(conn, "tdm_fields", Integer.parseInt(field_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
				execDBConf(conn, sql, bindlist);
				
				sql="select count(1) from tdm_fields where tab_id in (select tab_id from tdm_fields where id="+field_id+")" +
					" and mask_prof_id in (select id from tdm_mask_prof where rule_id in('GROUP_MIX','KEYMAP')) ;";
				int group_field_count=0;
				try {
					group_field_count=Integer.parseInt(getDBSingleVal(conn, sql));
				} catch(Exception e) {
					e.printStackTrace();
				}
				
				String mask_level="FIELD";
				if (group_field_count>0) mask_level="RELATION";
				
				sql="update tdm_tabs set mask_level='"+mask_level+"' where id="+tab_id;

				log_trial(conn, "tdm_tabs", Integer.parseInt(tab_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
				execDBConf(conn, sql, new ArrayList<String[]>());
				
				msg="ok:javascript:fillFieldDetails('"+field_id+"')";
			}			
			//**********************************************
			//validate_table_filter
			//**********************************************
			if (action.equals("validate_table_filter")) {
				String tab_id=par1;
				String tab_filter=par2;
				String env_id=par3;
				
				StringBuilder sbErr=new StringBuilder();
				
				boolean is_sql_valid=isTableFilterValid(conn,env_id,tab_id,tab_filter,sbErr); 
				
				if (is_sql_valid) {
					html="-";
					msg="ok:javascript:is_table_filter_validated="+is_sql_valid+"; savetabinfo(); ";
				}
				else {
					msg="ok:javascript:myalert('<font color=red><b>Filter is not valid! </b></font>:<hr>  "+sbErr.toString()+"')";
				}
					
					            
			}
			//**********************************************
			//validate_parallel_field
			//**********************************************
			if (action.equals("validate_parallel_field")) {
				String tab_id=par1;
				String parallel_field=par2;
				String env_id=par3;
				
				StringBuilder sbErr=new StringBuilder();
				
				boolean is_sql_valid=isTableParallelFunctionValid(conn,env_id,tab_id,parallel_field,sbErr); 
				
				if (is_sql_valid) {
					html=html + " ;";
					msg="ok:javascript:is_table_parallel_mod_validated="+is_sql_valid+"; savetabinfo();";
				} else {
					msg="ok:javascript:myalert('<font color=red><b>Paralelism Formula is not valid! </b></font>:<hr>  "+sbErr.toString()+"')";
				}
					
	            
				
			}			
			//**********************************************
			//save_table_info
			//**********************************************
			if (action.equals("save_table_info")) {
				String tab_id=par1;
				String tab_summary=par2;
				
				sql="select mask_level from tdm_tabs where id="+tab_id;
				String curr_mask_level=getDBSingleVal(conn, sql);
				
				String tab_desc="";
				String tab_filter="";
				String parallel_mod="";
				String parallel_field="";
				String partition_use="";
				String family_id="";
				String rollback_needed="";
				String export_plan="";

				String[] tabSumArr=tab_summary.split("::");
							
				
				try {tab_desc=tabSumArr[0];} catch(Exception e) {tab_desc="";  };
				try {tab_filter=tabSumArr[1];} catch(Exception e) {tab_filter="";};
				try {parallel_mod=tabSumArr[2];} catch(Exception e) {parallel_mod="1";};
				try {parallel_field=tabSumArr[3];} catch(Exception e) {parallel_field="1";};
				try {partition_use=tabSumArr[4];} catch(Exception e) {partition_use="NO";};
				try {family_id=tabSumArr[5];} catch(Exception e) {family_id="0";};
				try {rollback_needed=tabSumArr[6];} catch(Exception e) {rollback_needed="YES";};
				try {export_plan=tabSumArr[7];} catch(Exception e) {export_plan="EXPORT_MASKING";};

				
				sql="update tdm_tabs set " + 
						" tab_desc=?," +  
						//" mask_level=?," + 
						" tab_filter=?," +  
						" parallel_mod=?, "+
						" parallel_field=?," +
						" partition_used=?, " +
						" family_id=?, " + 
						" rollback_needed=?, " + 
						" export_plan=? " +
						" where id=?" ;
				
				bindlist=new ArrayList<String[]>();
				
				bindlist.add(new String[]{"STRING",tab_desc});
				//bindlist.add(new String[]{"STRING",mask_level});
				bindlist.add(new String[]{"STRING",tab_filter});
				bindlist.add(new String[]{"INTEGER",parallel_mod});
				bindlist.add(new String[]{"STRING",parallel_field});
				bindlist.add(new String[]{"STRING",partition_use});
				bindlist.add(new String[]{"INTEGER",family_id});
				bindlist.add(new String[]{"STRING",rollback_needed});
				bindlist.add(new String[]{"STRING",export_plan});
				bindlist.add(new String[]{"INTEGER",tab_id});
				
				log_trial(conn, "tdm_tabs", Integer.parseInt(tab_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
				execDBConf(conn, sql, bindlist);
				
				//html="javascript:mynotification('Table info is saved successfully');";
				
	
				msg="ok";
			}			
			
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
			//Add New Table to the Application
			//**********************************************
			if (action.equals("add_new_table")) {
				String table_name=par1;
				String filter_env_id=par2;
				String filter_app_id=par3;
				String discovery_rel_id=par4;
				String rel_type=par5;
				String family_id=par6;
				
				String app_type=getDBSingleVal(conn, "select app_type from tdm_apps where id="+filter_app_id);
				
				int added_tab_id=0;
				
				
				added_tab_id=addNewTable(conn, app_type, filter_env_id, filter_app_id, table_name, discovery_rel_id,rel_type, family_id);
 
				sql="select cat_name, schema_name, tab_name from tdm_tabs where id=?";
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",""+added_tab_id});
				
				ArrayList<String[]> tmpArr=getDbArrayConf(conn, sql, 1, bindlist);
				
				if (tmpArr.size()==1) {
					String added_table_cat=tmpArr.get(0)[0];
					String added_table_owner=tmpArr.get(0)[1];
					String added_table_name=tmpArr.get(0)[2];
					
					html="curr_tab_id='"+added_tab_id+"';";
					msg="ok:javascript:myalert('"+added_table_owner+"."+added_table_name+" is added.'); fillAppTabList(); redrawTableCell('"+filter_env_id+"', '"+added_table_cat+"', '"+added_table_owner+"', '"+added_table_name+"')";
				}
				else {
					html="-";
					msg="nok:table cannot be added to the application";
					
				}
				
				
			}
			//**********************************************
			//update_table_relation
			//**********************************************
			if (action.equals("update_table_relation")) {
				String child_tab_id=par1;
				String new_parent_tab_id=par2;
				String rel_on_fields=par3;
				String rel_type=par4;

				
				
				updateTableRelation(conn,child_tab_id, new_parent_tab_id, rel_on_fields,rel_type);
				
				html="-";
				msg="ok";
				
				
			}
			//**********************************************
			//Remove Table from Application
			//**********************************************
			if (action.equals("remove_table_from_app")) {
				String tab_id=par1;
				String env_id=par2;
				
				sql="select cat_name, schema_name, tab_name from tdm_tabs where id=?";
				bindlist.clear();
				bindlist.add(new String[]{"INTEGER",tab_id});
				
				ArrayList<String[]> tmpArr=getDbArrayConf(conn, sql, 1, bindlist);
				
				String del_tab_cat=tmpArr.get(0)[0];
				String del_tab_owner=tmpArr.get(0)[1];
				String del_tab_name=tmpArr.get(0)[2];
				
				session.setAttribute("tab_id", "");
		        
				log_trial(conn, "tdm_tabs", Integer.parseInt(tab_id), nvl((String) session.getAttribute("username"),"unknown"), "DELETE");
				removeTable(conn, tab_id);
				
				html="-";
		        	
				msg="ok:javascript:fillAppTabList(); redrawTableCell('"+ env_id +"', '"+del_tab_cat+"', '"+ del_tab_owner +"', '"+ del_tab_name +"'); ";
			}


			
			//**********************************************
			//change_discovery_flag
			//**********************************************
			if (action.equals("change_discovery_flag")) {
				String tab_id=par1;
				String discovery_flag=par2;

				log_trial(conn, "tdm_tabs", Integer.parseInt(tab_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
				setDiscoveryFlag(conn, tab_id,discovery_flag);
				
				html="-";
		        	
				msg="ok";
			}
			
			//**********************************************
			//add_new_list
			//**********************************************
			if (action.equals("add_new_list")) {
				String list_name=par1;
				bindlist.add(new String[]{"STRING", list_name});
				
				sql="select id from tdm_list where name=?";
				ArrayList<String[]> checkArr=getDbArrayConf(conn, sql, 1, bindlist);
				if (checkArr.size()>0) {
					html="-";
					msg="nok:Cannot be inserted. There are another list named with '"+list_name+"'.";
				}
				else {
					sql="insert into tdm_list (name) values (?)";
					execDBConf(conn, sql,bindlist);
					
					sql="select max(id) from tdm_list where name=?";
					String new_list_id="";
					try {
						new_list_id=getDbArrayConf(conn, sql, 1, bindlist).get(0)[0];
					} catch(Exception e) {
						e.printStackTrace();
						new_list_id="";
					}
					
					if (new_list_id.length()>0) {
						html="-";
						msg="ok:javascript:curr_list_id="+new_list_id+"; loadListofList(); ";
					}
					
				} //if (checkArr.size()>0) {
			
	
					
				
			}			
			
			//**********************************************
			//rename_list
			//**********************************************
			if (action.equals("rename_list")) {
				String list_id=par1;
				String list_name=par2;

				bindlist.add(new String[]{"STRING", list_name});
				bindlist.add(new String[]{"INTEGER", list_id});
				
				sql="select id from tdm_list where name=? and id<>?";
				ArrayList<String[]> checkArr=getDbArrayConf(conn, sql, 1, bindlist);
				if (checkArr.size()>0) {
					html="-";
					msg="nok:Cannot be renamed. There are another list named with '"+list_name+"'.";
				}
				else {
					sql="update tdm_list set name=? where id=?";
					log_trial(conn, "tdm_list", Integer.parseInt(list_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
					execDBConf(conn, sql,bindlist);
					
					html="-";
					msg="ok:javascript:loadListofList()";
				} //if (checkArr.size()>0) {
				
			}	
				
				
			//**********************************************
			//list_of_list
			//********************************************** 
			if (action.equals("list_of_list")) {
		    	
				sql = "select id, name from tdm_list order by name ";
		        html=makeCombo(conn, sql, "listList", "id=listList size=28  onchange=openListItems()", "", 0);
			
		        html = "<center>" + html + "</center>";
			 
				msg="ok";
			}	
			
			//**********************************************
			//delete_list
			//**********************************************
			if (action.equals("delete_list")) {
				String list_id=par1;
			
				sql="select count(*) from tdm_mask_prof where src_list_id="+list_id;
				int ref_cnt=0;
				try{ref_cnt=Integer.parseInt(getDBSingleVal(conn, sql));} catch(Exception e) {ref_cnt=0;}
				
				
				
				if (ref_cnt==0) {
					bindlist.add(new String[]{"INTEGER", list_id});
				
					sql="delete from tdm_list_items where list_id=?";
					execDBConf(conn, sql,bindlist);
					sql="delete from tdm_list where id=?";
					log_trial(conn, "tdm_list", Integer.parseInt(list_id), nvl((String) session.getAttribute("username"),"unknown"), "DELETE");
					execDBConf(conn, sql,bindlist);
					
					html="-";
					msg="ok:javascript: curr_list_id=-1; loadListofList(); ";
				}
				else {
					html="-";
					msg="nok:Cannot delete this list since it is used in configurations.";

				}
			}	
			
			//**********************************************
			//items_of_list
			//**********************************************
			if (action.equals("items_of_list")) {
				String list_id=par1;
				session.setAttribute("currlistid", list_id);
				session.setAttribute("ListSQL","");
				
				sql="select count(*) from tdm_list_items where list_id="+list_id;
	            String all_count=getDBSingleVal(conn, sql);
	            
	            sql="select title_list, sql_statement from tdm_list where id="+list_id;
	            bindlist=new ArrayList<String[]>();

	            ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1000, bindlist);
	            
	            String title_list=arr.get(0)[0];
	            String sql_statement=arr.get(0)[1];
	            
		    	sql = "select id, list_val from tdm_list_items where list_id=" + list_id+ " limit 0,1000";
		    	bindlist=new ArrayList<String[]>();
	            
	            arr=getDbArrayConf(conn, sql, 1000, bindlist);
	            
	            
	            StringBuilder sb=new StringBuilder();
	            
	            if (sql_statement.trim().length()>0) {
	            	sb.append("<div class=row>");
	            	sb.append("<div class=\"col-md-2\" align=right><b>Sql : </b></div>");
	            	sb.append("<div class=\"col-md-10\" style=\"background-color:#DDDDDD;font-family:Courier New, Courier, monospace;\">");
	            	sb.append("<font color=blue>");
	            	sb.append(clearHtml(sql_statement));
	            	sb.append("</font>");
	            	sb.append("</div>");
	            	sb.append("</div>");
	            }
	            
	            if (arr.size()>0) {
	                sb.append("<table class=\"table table-striped table-bordered\">");
	            	int id=0;
	            	
	                for (int i=0;i<arr.size();i++) {
	                	
	                	if (i==0 && title_list.contains("|::|")) {
	                		String[] titleArr=title_list.split("\\|::\\|");
		                	sb.append("<tr class=info>");
		                	sb.append("<td></td>");

	                		for (int f=0;f<titleArr.length;f++) {
		                    	sb.append("<td>");
		                    	sb.append("<div id=list_col_"+f+">");
		                		//sb.append("<input type=text id=col_name_"+f+"  size=8 maxlength=20 value=\""+titleArr[f]+"\" onchange=changeListColName('"+list_id+"',"+f+",this)>");
		                		sb.append(makeText("col_name_"+f, titleArr[f], "maxlength=20 onchange=\"changeListColName('"+list_id+"',"+f+",this);\" ", 120));
		                		sb.append("</div>");
		                    	sb.append("</td>");
	                		}
		                	sb.append("</tr>");
	                	}
	                
	                	sb.append("<tr>");
	                	sb.append("<td nowrap align=right>"+(i+1)+" / "+ all_count + "</td>");
	                
	                	id=Integer.parseInt(arr.get(i)[0]);
	                	String[] tarr=arr.get(i)[1].split("\\|::\\|");
	                	
	                	for (int f=0;f<tarr.length;f++) {
	                    	sb.append("<td nowrap>");
	                		sb.append("<b>"+nvl(tarr[f].trim(),"${null}")+"</b>");
	                    	sb.append("</td>");
	                	}
	                	
	                	
	                	sb.append("</tr>");
	
	                    }
	                
	                sb.append("</table>");
	            } //if (arr.size()>0) {
	            else {
	            	sb.append("<b><font color=red>There is no item in the list yet. </font></b>");
	            }
		        
			    html = sb.toString();
	
				msg="ok";
			}			

			
			//**********************************************
			//draw_condition
			//**********************************************
			if (action.equals("draw_condition")) {
				String field_id=par1;
				
				
				
				sql="select tab_id, condition_expr from tdm_fields where id="+field_id;
				ArrayList<String[]> arrl=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>());
 				String tab_id=arrl.get(0)[0];
				String condition=arrl.get(0)[1];
				
				//condition="IF[${CNTC_DATA}::=::2::MASK(12:name)]||IF[${CNTC_DATA}::=::2::MASK(12)]||IF[${CNTC_DATA}::=::1::MASK(4)]||ELSE[MASK(3)]";

				if (condition.length()==0) {
					condition="ELSE[MASK(0)]";
				}
				session.setAttribute("condition_to_edit", condition);
				
				sql="select app_type from tdm_apps where id in (select app_id from tdm_tabs where id="+tab_id+")";
				String app_type=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>()).get(0)[0];

				String sql_fields="select field_name, field_name from tdm_fields where tab_id=" + nvl(tab_id,"0") + " and (is_conditional='YES' or mask_prof_id>0) and is_pk<>'YES'  order by field_name";
				if (app_type.equals("COPY"))
					sql_fields="select field_name, field_name from tdm_fields where tab_id=" + nvl(tab_id,"0") + " order by id";
					
				String sql_operand="" + 
						 	"select '=' oper, 'Equals' oper_desc union all " + 
							" select '!=' oper, 'Not Equals' oper_desc from dual union all " + 
							" select '>' oper, 'Greater Than' oper_desc  from dual union all " + 
							" select '<' oper, 'Less Than' oper_desc  from dual union all " + 
							" select 'isnull' oper, 'is Null' oper_desc  from dual union all " + 
							" select 'notnull' oper, 'is not Null' oper_desc  from dual union all " + 
							" select 'like' oper, 'Like' oper_desc  from dual union all " + 
							" select '!like' oper, 'not Like' oper_desc  from dual union all " +
							" select 'in' oper, 'In' oper_desc  from dual union all " + 
							" select '!in' oper, 'not In' oper_desc ";
				String sql_profiles="select id, name from tdm_mask_prof where valid='YES' and rule_id not in ('GROUP','GROUP_MIX','HASH_REF') order by name";
				
				

				html="<div class=\"panel panel-primary\">";
				
				html = html + "<div class=\"panel-body\" style=\"background-color:#DDDDDD;\">";
				
				String mask_prof_id_0=nvl((String) session.getAttribute("mask_prof_id_0"),"");
				String list_field_name_0=nvl((String) session.getAttribute("list_field_name_0"),"");
				String list_field_fixed_0=nvl((String) session.getAttribute("list_field_fixed_0"),"");
				
				html = html + "<div id=div_condition_p_0"+"  class=\"col-md-3\">";
				html = html + makeCombo(conn, sql_profiles, "condition_mask_prof_0", "id=condition_mask_prof_0 onchange=openConditionEditor(curr_condition_field_id,curr_condition_field_name,'mask_prof_id_0',this.value)", mask_prof_id_0, 200);
				
				html = html + makeListFieldNameCombo(conn, mask_prof_id_0,field_id,list_field_name_0,list_field_fixed_0,"CONDITION","0",200);
				
				html = html + "</div>";
				

				html = html + "<div id=div_condition_l_0"+"  class=\"col-md-1\">";
				html = html + "<b>WHEN</b>";
				html = html + "</div>";


				html = html + "<div id=div_condition_f_0"+"  class=\"col-md-3\">";
				html = html + makeCombo(conn, sql_fields, "condition_field_0", "id=condition_field_0", "", 180);
				html = html + "</div>";
				
				html = html + "<div id=div_condition_op_0"+"  class=\"col-md-2\">";
				html = html + makeCombo(conn, sql_operand, "condition_operand_0", "id=condition_operand_0", "", 120);
				html = html + "</div>";
				
				html = html + "<div id=div_condition_op_0"+"  class=\"col-md-2\">";
				html = html + "<input type=text id=condition_value_0 size=12 maxlength=100 value=\"\">";
				html = html + "</div>";

				html = html + "<div id=div_condition_b0_"+"  class=\"col-md-1\">";
				html = html + ""+
					    		"<button type=\"button\" class=\"btn btn-default btn-md\" onclick=saveCondition(0)> " +
		    					"  <span class=\"glyphicon glyphicon-plus\"></span> " +
		    					"</button> ";
				html = html + "</div>";

				html = html + "</div> <!--add new -->";

				
				html=html + "<div class=\"panel-body\"  style=\"min-height: 240px; max-height: 420px; overflow-x: scroll; overflow-y: scroll;\">";

				if (condition.length()>0) {

					
					String[] ifelse=condition.split("\\|\\|");
					for (int i=0;i<ifelse.length;i++) {
						String a_statement=ifelse[i];
						String a_type=a_statement.split("\\[")[0];
						String a_param=a_statement.split("\\[")[1].split("]")[0];
						
						html = html + "<div class=\"row\">";
						
						if (a_type.equals("IF")) {
							
							String arr[]=a_param.split("::");
							
							String field_name=arr[0].split("\\{")[1].split("\\}")[0];
							String operand=arr[1];
							String value=arr[2];
							String mask_prof_id=arr[3].split("\\(")[1].split("\\)")[0];
							String list_field_name="";
							String list_field_fixed="";

							if (mask_prof_id.contains(":")) {
								list_field_name=mask_prof_id.split(":")[1];
								try { list_field_fixed=mask_prof_id.split(":")[2]; } catch(Exception e) {list_field_fixed="";}
								mask_prof_id=mask_prof_id.split(":")[0];
							}

							html = html + "<div id=div_condition_p_"+(i+1)+"  class=\"col-md-3\">";
							html = html + makeCombo(conn, sql_profiles, "condition_mask_prof_"+(i+1), " onchange=saveCondition("+(i+1)+") id=condition_mask_prof_"+(i+1), mask_prof_id, 200);
							html = html + makeListFieldNameCombo(conn, mask_prof_id,field_id,list_field_name,list_field_fixed, "CONDITION",""+(i+1),200);
							html = html + "</div>";

							html = html + "<div id=div_condition_l_"+(i+1)+"  class=\"col-md-1\">";
							html = html + "<b>WHEN</b>";
							html = html + "</div>";

							html = html + "<div id=div_condition_f_"+(i+1)+"  class=\"col-md-3\">";
							html = html + makeCombo(conn, sql_fields, "condition_field_"+(i+1), " onchange=saveCondition("+(i+1)+") id=condition_field_"+(i+1), field_name, 180);
							html = html + "</div>";
							
							html = html + "<div id=div_condition_op_"+(i+1)+"  class=\"col-md-2\">";
							html = html + makeCombo(conn, sql_operand, "condition_operand_"+(i+1), " onchange=saveCondition("+(i+1)+") id=condition_operand_"+(i+1), operand, 120);
							html = html + "</div>";
							
							html = html + "<div id=div_condition_op_"+(i+1)+"  class=\"col-md-2\">";
							html = html + "<input type=text id=condition_value_"+(i+1)+" size=12 maxlength=100 value=\""+value+"\" onchange=saveCondition("+(i+1)+")>";
							html = html + "</div>";

							
							html = html + "<div id=div_condition_b_"+(i+1)+"  class=\"col-md-1\">";
			    			html = html + ""+
						    		"<button type=\"button\" class=\"btn btn-default btn-md\" onclick=removeCondition("+(i+1)+")> " +
			    					"  <span class=\"glyphicon glyphicon-minus\"></span> " +
			    					"</button>";
							html = html + "</div>";
							
						}
						
						if (a_type.equals("ELSE") || (i==(ifelse.length-1)) ) {
							
							String mask_prof_id=a_param.split("\\(")[1].split("\\)")[0];	
							String list_field_name_else="";
							String list_field_fixed_else="";
							System.out.println("mask_prof_id:"+mask_prof_id);
							if (mask_prof_id.contains(":")) {
								
								list_field_name_else=mask_prof_id.split(":")[1];
								try {list_field_fixed_else=mask_prof_id.split(":")[2];} catch(Exception e) {list_field_fixed_else="";}
								mask_prof_id=mask_prof_id.split(":")[0];
							}
							
				
							html = html + "<div id=div_condition_p_"+i+"  class=\"col-md-12\">";
							html = html + "<hr><b>ELSE</b>";
							html = html + makeCombo(conn, sql_profiles, "condition_mask_prof_else", "id=condition_mask_prof_else onchange=saveCondition(-1)", mask_prof_id, 250);
							html = html + makeListFieldNameCombo(conn, mask_prof_id,field_id,list_field_name_else,list_field_fixed_else,"CONDITION","-1",200);
							html = html + "</div>";
						}
						
						html=html +"</div>  <!-- row -->";
					
						
					}
					
					
				}
				
				html = html + "</div> <!-- panel body -->";

				html=html + "<div> <!-- panel-->";
				
				

				
				msg="ok";
				
			}	
			
			//**********************************************
			//save_condition_item
			//**********************************************
			if (action.equals("save_condition_item")) {
				
				String field_id=par1;
				int item_to_save=Integer.parseInt(par2);
				String saving_condition_expr=par3;
				String saving_else_expr=par4;
				
				String condition=(String) session.getAttribute("condition_to_edit");
									
				String[] items=condition.split("\\|\\|");
				
				String new_condition="";
				int condition_count=0;
				
				if (item_to_save==0) {
					condition_count++;
					new_condition=new_condition+saving_condition_expr;
					session.setAttribute("mask_prof_id_0", "");
					session.setAttribute("list_field_name_0", "");
					session.setAttribute("list_field_fixed_0", "");
				}

				for (int i=0;i<items.length-1;i++) {
					
					if ((i+1)!=item_to_save) {
						condition_count++;
						if (condition_count>1) new_condition=new_condition+"||";
						new_condition=new_condition+items[i];
					} 
					else {
						condition_count++;
						if (condition_count>1) new_condition=new_condition+"||";
						new_condition=new_condition+saving_condition_expr;
					}
				} // for
				
				//else expression
				new_condition=new_condition+"||";
				new_condition=new_condition+saving_else_expr;
				
				sql="update tdm_fields set condition_expr=? where id=?";
				bindlist=new ArrayList<String[]>();
				bindlist.add(new String[]{"STRING",new_condition});
				bindlist.add(new String[]{"INTEGER",field_id});
				log_trial(conn, "tdm_fields", Integer.parseInt(field_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
				execDBConf(conn, sql, bindlist);
				
				
			}
			
			//**********************************************
			//remove_condition_item
			//**********************************************
			if (action.equals("remove_condition_item")) {
				
				String field_id=par1;
				int item_to_remove=Integer.parseInt(par2);

				String condition=(String) session.getAttribute("condition_to_edit");
									
				String[] items=condition.split("\\|\\|");
				
				String new_condition="";
				int condition_count=0;
				
				for (int i=0;i<items.length;i++) {
					if (i!=item_to_remove) {
						condition_count++;
						if (condition_count>1) new_condition=new_condition+"||";
						new_condition=new_condition+items[i];
					} 
				} // for
				
				sql="update tdm_fields set condition_expr=? where id=?";
				bindlist=new ArrayList<String[]>();
				bindlist.add(new String[]{"STRING",new_condition});
				bindlist.add(new String[]{"INTEGER",field_id});
				log_trial(conn, "tdm_fields", Integer.parseInt(field_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
				execDBConf(conn, sql, bindlist);
				
				
			}
			
			
			//**********************************************
			//open_run_dialog
			//**********************************************
			if (action.equals("open_run_dialog")) {
				
				String app_type_id=par1;
				String app_id=par2;
				String env_id=par3;
				String dateformat=DEFAULT_DATE_FORMAT;
				
				html=makeRunApplicationDlg(conn, session, app_id, env_id, dateformat); 
				msg="ok:javascript:fillSchemaChangeDiv()";


				
			}
			
			
			//**********************************************
			//fill_schema_changer_div
			//**********************************************
			if (action.equals("fill_schema_changer_div")) {
				String showhide=par1;
				String app_id=par2;
				String env_id=par3;
				String target_env_id=par4;
				
				
				
				if (target_env_id.equals("-1")) target_env_id=env_id;
				
					
				StringBuilder sb=new StringBuilder();
				
				sql="select distinct concat(cat_name,'.',schema_name) from tdm_tabs where app_id="+app_id+ " order by 1";
				ArrayList<String[]> appSchemas=getDbArrayConf(conn, sql, Integer.MAX_VALUE, null);
				
				sql="select concat(cat_name,'.',schema_name) schema_name, tab_name from tdm_tabs where app_id="+app_id+ " order by 1,2";
				ArrayList<String[]> appTables=getDbArrayConf(conn, sql, Integer.MAX_VALUE, null);
				
				StringBuilder errmsg=new StringBuilder();
				
				ArrayList<String[]> ownerList=getDesignerSchemaList(conn, session, env_id, "All", errmsg);
				
				if (errmsg.length()>0) {
					System.out.println("Error@getSourceSchemaList :"+errmsg);
				}
				
				
				
				String app_type=getDBSingleVal(conn, "select app_type from tdm_apps where id="+app_id);
				
				
				//ArrayList<String[]> newOwnerList=(ArrayList<String[]>) session.getAttribute("SCHEMA_LIST_OF_"+target_env_id);

				ArrayList<String[]> newOwnerList=getDesignerSchemaList(conn, session, target_env_id, "All", errmsg);
				
				if (errmsg.length()>0) {
					System.out.println("Error@getTargetSchemaList :"+errmsg);
				}
				
				sb.append("<center>");
				sb.append("<h4><span class=\"label label-info\">");
				sb.append("Change Source / Target Info");
				sb.append("</span></h4>");
				sb.append("</center>");
				
				
				sb.append("<table class=\"table .table-condensed\" border=0");
				
				
				sb.append("<tr class=active>");
				sb.append("<td colspan=2><b>Source Target</b></td>");
				
				
				sb.append("</tr>");
				
				String copy_level="SINGLETAB";
				//sql="select count(*) from tdm_tabs where app_id =" + app_id;
				sql="select count(*) from tdm_tabs_rel where tab_id in (select id from tdm_tabs where app_id =" + app_id+")";
				int relcount=0;
				try {relcount=Integer.parseInt(getDbArrayConf(conn, sql, 1, new ArrayList<String[]>()).get(0)[0]);} catch(Exception e) {e.printStackTrace();}
				if (relcount>1) copy_level="MULTITAB";
				
				
				for (int i=0;i<appTables.size();i++) {
					String source_schema=appTables.get(i)[0];	
					String source_table=appTables.get(i)[1];
				
					sb.append("<input type=hidden id=orig_table_name_"+i+" value=\""+source_schema+"."+source_table+"\">");
					sb.append("<tr>");
					
					
					sb.append("<td class=warning>");
					sb.append(makeComboArr(ownerList, "", "id=source_schema_"+i, source_schema, 150));
					sb.append("</td>");
					
					//System.out.println("Copy Level : "   + copy_level);
					sb.append("<td class=warning>");
					if (app_type.equals("COPY") && copy_level.equals("MULTITAB"))
						sb.append("<input disabled type=text size=24 id=source_table_"+i+" value=\""+source_table+"\" maxlength=50>");
					else
						sb.append("<input type=text size=24 id=source_table_"+i+" value=\""+source_table+"\" maxlength=50>");
					sb.append("</td>");
					
					
					sb.append("</tr>");
				}
				sb.append("</table>");
			
				html=sb.toString();
				msg="ok";
				
				
			
			}

			//**********************************************
			//show_check_and_compare_table_results
			//**********************************************
			if (action.equals("show_check_and_compare_table_results")) {
				
				String app_type=par1;
				String app_id=par2;
				String source_id=par3;
				String wp_params=par4;
				String target_id=par5;
				
				
				
				html=showTableCheckCompareStatus(conn, session, app_type, app_id, source_id, target_id, wp_params);
				msg="ok";
			}
			//**********************************************
			//create_work_plan
			//**********************************************
			if (action.equals("create_work_plan")) {
				
				String app_type_id=par1;
				String app_id=par2;
				String env_id=par3;
				String wp_params=par4;
				String target_env_id=nvl(par5,"0");
				
				
				boolean checkTables=true;
				
				if (app_type_id.equals("COPY")) 
						checkTables=checkSourceTargetDb(conn, session, app_id, env_id, target_env_id, wp_params);
				
				if (!checkTables) {
					html="-";
					msg="ok:javascript:showTableCheckStatus()";
					
				} //if (!checkTables)
				else {
					String[] arr=wp_params.split("::::");
					
					String work_plan_name=arr[0];
					String run_type=arr[1];
					String start_date=arr[2];
					String master_limit=arr[3];
					String worker_limit=arr[4];
					String REC_SIZE_PER_TASK=arr[5];
					String TASK_SIZE_PER_WORKER=arr[6];
					String UPDATE_WPACK_COUNTS_INTERVAL=arr[7];
					String target_owner_info=arr[8];
					String copy_filter=arr[9];
					String copy_filter_bind=arr[10].trim();
					String copy_rec_count=arr[11];
					String copy_repeat_count=arr[12];
					String email_address=arr[13].trim();
					String run_options=arr[14].trim();
					String depended_application=arr[15].trim();
					String execution_type=arr[16].trim();
					String on_error_action=arr[17].trim();
					String repeat_period=arr[18].trim();
					String repeat_by=arr[19].trim();
					String error_actions="";
					
					try{error_actions=arr[20].trim();} catch(Exception e) {error_actions="-";}
					
					
					
					if (email_address.equals("-")) email_address="";
					if (copy_filter_bind.equals("-")) copy_filter_bind="";
					if (error_actions.equals("-")) error_actions="";
					if (run_options.equals("x")) run_options="";
					
					if (error_actions.length()>0) {
						if (run_options.length()>0) run_options=run_options+"\n";
						 run_options=run_options+error_actions;
					}

					
					if (start_date.equals("-")) {
						sql="select date_format(now(),'%d.%m.%Y %H:%i:%s') from dual";
						bindlist.clear();
						ArrayList<String[]> arrcurrdate=getDbArrayConf(conn, sql, 1, bindlist);
						start_date=arrcurrdate.get(0)[0];
					}

					
					
					sql ="SELECT AUTO_INCREMENT FROM information_schema.tables WHERE table_name = 'tdm_work_plan' AND table_schema = DATABASE()";
					
					bindlist.clear();
					ArrayList<String[]> arrx=getDbArrayConf(conn, sql, 1, bindlist);
					
					String work_plan_id="";
					
					try{work_plan_id=arrx.get(0)[0];} catch(Exception e) {work_plan_id="";}

					String curruser_id=""+((Integer) session.getAttribute("userid"));
					
					bindlist.clear(); 
					bindlist.add(new String[]{"INTEGER",work_plan_id });
					bindlist.add(new String[]{"STRING",work_plan_name });
					bindlist.add(new String[]{"INTEGER",curruser_id });
					bindlist.add(new String[]{"INTEGER",env_id });
					bindlist.add(new String[]{"INTEGER",app_id });
					bindlist.add(new String[]{"INTEGER",target_env_id });
					bindlist.add(new String[]{"STRING",app_type_id });
					bindlist.add(new String[]{"STRING",execution_type });
					bindlist.add(new String[]{"STRING",on_error_action });
					bindlist.add(new String[]{"LONG",REC_SIZE_PER_TASK});
					bindlist.add(new String[]{"LONG",TASK_SIZE_PER_WORKER});
					bindlist.add(new String[]{"LONG","50"});
					bindlist.add(new String[]{"LONG","20"});
					bindlist.add(new String[]{"LONG",UPDATE_WPACK_COUNTS_INTERVAL });
					bindlist.add(new String[]{"STRING", run_type });
					bindlist.add(new String[]{"STRING", target_owner_info});
					bindlist.add(new String[]{"INTEGER", master_limit});
					bindlist.add(new String[]{"INTEGER", worker_limit});
					bindlist.add(new String[]{"INTEGER", copy_filter});
					bindlist.add(new String[]{"STRING", copy_filter_bind});
					bindlist.add(new String[]{"INTEGER", copy_rec_count});
					bindlist.add(new String[]{"INTEGER", copy_repeat_count});
					bindlist.add(new String[]{"STRING", email_address});
					bindlist.add(new String[]{"STRING", run_options});
					bindlist.add(new String[]{"STRING", start_date});
					bindlist.add(new String[]{"STRING", mysql_format});
					bindlist.add(new String[]{"STRING", repeat_period});
					bindlist.add(new String[]{"INTEGER", repeat_by});
				

					sql="insert into tdm_work_plan (id, work_plan_name, created_by, env_id, app_id, target_env_id, wplan_type,"+
							" execution_type, on_error_action, " + 
							"REC_SIZE_PER_TASK, TASK_SIZE_PER_WORKER, BULK_UPDATE_REC_COUNT, "+ 
							" COMMIT_LENGTH, UPDATE_WPACK_COUNTS_INTERVAL,RUN_TYPE, target_owner_info, " + 
							" master_limit, worker_limit,copy_filter, copy_filter_bind, copy_rec_count, copy_repeat_count, "+
							" email_address, run_options, "+
							" start_date, repeat_period, repeat_by) values ( " + 
							"?," + //id
							"?," + //work_plan_name
							"?," + //created_by
							"?," + //env_id
							"?," + //app_id
							"?," + //target_env_id
							"?," + //wplan_type
							"?," + //execution_type
							"?," + //on_error_action
							"?," + //REC_SIZE_PER_TASK
							"?," + //TASK_SIZE_PER_WORKER
							"?," + //BULK_UPDATE_REC_COUNT
							"?," + //COMMIT_LENGTH
							"?," + //UPDATE_WPACK_COUNTS_INTERVAL
							"?," + //run_type
							"?," + //target_owner_info
							"?," + //master_limit
							"?," + //worker_limit
							"?," + //copy_filter
							"?," + //copy_filter_bind
							"?," + //copy_rec_count
							"?," + //copy_repeat_count
							"?," + //email_address
							"?," + //run_options
							"str_to_date(?,?), " + //start_time
							"?," + //repeat_period
							"?" + //repeat_by
							") " ;
							
					boolean is_created=execDBConf(conn, sql, bindlist);
					
					
					if (is_created) {
						
						sql="insert into tdm_work_plan_dependency (work_plan_id, depended_work_plan_id) values (?,?)";

						String[] dependedArr=depended_application.split(",");
						
						

						for (int i=0;i<dependedArr.length;i++) {
							String depended_work_plan_id=dependedArr[i];
							
							
							bindlist.clear();
							bindlist.add(new String[]{"INTEGER",work_plan_id });
							bindlist.add(new String[]{"INTEGER",depended_work_plan_id });
							execDBConf(conn, sql, bindlist);
						}
						
						
						ArrayList<String> pickedWPList= (ArrayList<String>) session.getAttribute("pickedWorkPlanIDs");
						if (pickedWPList==null) pickedWPList=new ArrayList<String>();
						pickedWPList.add(work_plan_id);
						session.setAttribute("pickedWorkPlanIDs",pickedWPList);
						
						html="-";
						msg="ok:javascript:myalert('Work Plan created successfully.'); ";
						if (app_type_id.equals("COPY2"))
							msg="ok:javascript:  listMyCopyTasks(); myalert('Copy task created successfully.'); ";
					}
						
					else {
						msg="nok:Work plan can not be placed.";
					}
				}
				
				
				
				
					

				}
			
			//**********************************************
			//fill_process_summary
			//**********************************************
			if (action.equals("fill_process_summary")) {
				//kill stalled manager
				sql="delete from tdm_manager where  last_heartbeat<DATE_ADD(NOW(), INTERVAL -15 MINUTE)";
				execDBConf(conn, sql, bindlist);

				//kill stalled masters
				sql="delete from tdm_master where  last_heartbeat<DATE_ADD(NOW(), INTERVAL -15 MINUTE)";
				execDBConf(conn, sql, bindlist);

				//kill stalled workers
				sql="delete from tdm_worker where  last_heartbeat<DATE_ADD(NOW(), INTERVAL -15 MINUTE)";
				execDBConf(conn, sql, bindlist);
				
				
				sql="select status, last_heartbeat, hostname, cancel_flag from tdm_manager";
				ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>());

				String status="";
				String last_heartbeat="";
				String hostname="";
				String cancel_flag="";

				if (arr.size()==1) {
					status=arr.get(0)[0];
					last_heartbeat=arr.get(0)[0];
					hostname=arr.get(0)[0];
					cancel_flag=arr.get(0)[0];
				}
				else 
				{
					status="stopped";
				}
				
				String status_img="running.gif";
				if (status.equals("stopped")) status_img="stopping.png";
				if (cancel_flag.equals("YES")) status_img="cancelling.png";

				html=""+
						" <div class=\"panel-heading\">\n" +
						"   <img src=\"img/"+status_img+"\" width=24 height=24 data-toggle=\"popover\" title=\""+ hostname +" ["+last_heartbeat+"]\">\n"+
		  				 "   Manager"+
						"</span>\n" ;
			  			
			  				

						html=html+
					  			" </div>\n" +
					  			" <div class=\"panel-body\" id=\"div_manager\">\n";
					  			
					  			html=html + 
					  					" <button type=\"button\" class=\"btn btn-default\" onclick=fillProcessSummary()  data-toggle=\"tooltip\" data-placement=\"left\" title=\"Refresh\">\n" +
										  " <span class=\"glyphicon glyphicon-refresh\" aria-hidden=\"true\" alt=\"Stop\">\n" +" </span>\n" +
										" </button>\n";

					  			if (status.equals("RUNNING") && !cancel_flag.equals("YES")) {
					  				
					  				String last_manager_heartbeat=getDBSingleVal(conn, "select last_heartbeat from tdm_manager");
					  				html=html +
										    " <button type=\"button\" class=\"btn btn-danger\" onclick=setProcessStatus('manager',0,'stop')  data-toggle=\"tooltip\" data-placement=\"left\" title=\"Stop Manager\">\n" +
											  " <span class=\"glyphicon glyphicon-stop\" aria-hidden=\"true\" alt=\"Stop\">\n" +" </span>\n" +
											" </button>\n" +
				
							  				" <button type=\"button\" class=\"btn btn-success\" onclick=setProcessStatus('manager',0,'restart')  data-toggle=\"tooltip\" data-placement=\"left\" title=\"Restart Manager\">\n" +
											  " <span class=\"glyphicon glyphicon-refresh\" aria-hidden=\"true\" alt=\"Restart\">\n" +" </span>\n" +
											" </button>\n"+
													  " <br>[<font color=green><b>"+last_manager_heartbeat+"</b></font>]";
					  			}
						  			
										
							  			
					  			if (status.equals("stopped"))
						  			html=html +
						  				" <button type=\"button\" class=\"btn btn-success\" onclick=setProcessStatus('manager',0,'start') data-toggle=\"tooltip\" data-placement=\"left\" title=\"Start\">\n" +
										  " <span class=\"glyphicon glyphicon-play\" aria-hidden=\"true\" alt=\"Start\">\n" +" </span>\n" +
										" </button>\n";
					  			
					  			
					  	html=html+
					  			" </div>\n";

							  			
			  			sql="select status, count(*) from tdm_master group by status";
			  			ArrayList<String[]> masterArr=getDbArrayConf(conn, sql, 10, new ArrayList<String[]>());

			  			String master_summary="<table class=\"table table-condensed\">";
			  			int count=0;
			  			for (int m=0;m<masterArr.size();m++) {
			  				master_summary=master_summary + 
			  					"<tr>"+
			  					"<td>"+masterArr.get(m)[0]+"</td>"+
			  					"<td>"+masterArr.get(m)[1]+"</td>"+
			  					"<td align=right>"
			  						+"<input type= \"button\" value=\"...\" class=\"btn btn-info btn-sm\" onclick=showProcessList('master','"+masterArr.get(m)[0]+"')>"+
			  						"</button>"+
			  					"</td>"+
			  					"</tr>";
			  					count=count+Integer.parseInt(masterArr.get(m)[1]);
			  			}

		  				master_summary=master_summary + 
			  			"<tr>"+
	  					"<td><b>ALL</b></td>"+
	  					"<td><b>"+count+"</b></td>"+
	  					"<td align=right>"
  						+"<input type= \"button\" value=\"...\" class=\"btn btn-info btn-sm\" onclick=showProcessList('master','ALL')>"+
  						"</button>"+
	  					"</td>"+
	  					"</tr>";

			  			master_summary=master_summary+"</table>";
			  			
			  			int p_target_master_count=0;

			  			try {
			  				p_target_master_count=Integer.parseInt(nvl(getParamByName(conn, "TARGET_MASTER_COUNT"),"0"));	
			  			} catch(Exception e) {
			  				p_target_master_count=0;
			  				}

			  			
					  	html=html +
			  			" <div class=\"panel-heading\">\n" +
		  				 " Master(s) : </span>\n" +
		  				 "<input type=text name=TARGET_MASTER_COUNT id=TARGET_MASTER_COUNT size=3 maxlength=3 value=\""+p_target_master_count+"\"  style=\"color:red; \" onchange=setProcessStatus('master',this.value,'set_limit')>"+
			  			" </div>\n";

			  			
			  			html=html +
			  			" <div class=\"panel-body\" id=\"div_master\">\n" +
			  				master_summary+
			  			" </div>\n";
			  			
			  			
			  			
			  			
			  			
			  			sql="select status, count(*) from tdm_worker group by status";
			  			ArrayList<String[]> workerArr=getDbArrayConf(conn, sql, 10, new ArrayList<String[]>());

			  			String worker_summary="<table class=\"table table-condensed\">";
			  			count=0;
			  			for (int m=0;m<workerArr.size();m++) {
			  				worker_summary=worker_summary + 
			  					"<tr>"+
			  					"<td>"+workerArr.get(m)[0]+"</td>"+
			  					"<td>"+workerArr.get(m)[1]+"</td>"+
			  					"<td align=right>"
		  						+"<input type= \"button\" value=\"...\" class=\"btn btn-info btn-sm\" onclick=showProcessList('worker','"+workerArr.get(m)[0]+"')>"+
		  						"</button>"+
		  					"</td>"+
			  					"</tr>";
			  					count=count+Integer.parseInt(workerArr.get(m)[1]);
			  			}

			  			worker_summary=worker_summary + 
			  			"<tr>"+
	  					"<td><b>ALL</b></td>"+
	  					"<td><b>"+count+"</b></td>"+
	  					"<td align=right>"
  						+"<input type= \"button\" value=\"...\" class=\"btn btn-info btn-sm\" onclick=showProcessList('worker','ALL')>"+
  						"</button>"+
  					"</td>"+
	  					"</tr>";

	  					worker_summary=worker_summary+"</table>";
			  			
			  			int p_target_worker_count=0;


			  			try {
			  				p_target_worker_count=Integer.parseInt(nvl(getParamByName(conn, "TARGET_WORKER_COUNT"),"0"));	
			  			} catch(Exception e) {
			  				p_target_worker_count=0;
			  				}
			  			
					  	html=html +
			  			" <div class=\"panel-heading\">\n" +
		  				 " Worker(s) : </span>\n" +
		  				 "<input type=text name=TARGET_WORKER_COUNT id=TARGET_WORKER_COUNT size=3 maxlength=3 value=\""+p_target_worker_count+"\"  style=\"color:red; \" onchange=setProcessStatus('worker',this.value,'set_limit')>"+
			  			" </div>\n";

			  			
			  			html=html +
			  			" <div class=\"panel-body\" id=\"div_master\">\n" +
			  					worker_summary+
			  			" </div>\n";
			  			
			  			
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
					
				html="-";			  			
				msg="ok";
			
				
			}
			
			//**********************************************
			//show_process_list
			//**********************************************
			if (action.equals("show_process_list")) {
				String ptype=par1;
				String pstatus=par2;
				
				
				sql="select id, status, hostname, start_date, cancel_flag, last_heartbeat from tdm_"+ptype;
				
				if (!pstatus.equals("ALL")) {
					sql = sql + " where status='"+ pstatus +"'";
				}
				
				sql=sql + " order by id";
				
				
				
				ArrayList<String[]> pArr=getDbArrayConf(conn, sql, 1000, new ArrayList<String[]>());
				
				html="<div class=\"panel panel-primary\">";

				html=html + 
						"<div class=\"panel-heading\">";

				if (ptype.equals("master")) 
					html=html+"Masters ("+pstatus+")";

				if (ptype.equals("worker")) 
					html=html+"Workers ("+pstatus+")";

				html=html+
						"</div> <!-- panel heading -->";
						
				html=html + 
						"<div class=\"panel-body\">";

					
				html=html + "<table class=\"table table-striped\">"+
					"<tr>"+
						"<td><b>ID</b></td>"+
						"<td><b>STATUS</b></td>"+
						"<td><b>HOST INFO</b></td>"+
						"<td><b>START</b></td>"+
						"<td><b>CANCEL FLAG</b></td>"+
						"<td><b>HEARTBEAT</b></td>"+
						"<td><b>BUSY ON</b></td>"+
						"<td><b>STOP</b></td>"+
					"</tr>";
					
				for (int m=0;m<pArr.size();m++) {
					
					String tr_class="success";
					String status=pArr.get(m)[1];
					
					if (status.equals("BUSY")) tr_class="warning";
					if (status.equals("ASSIGNED")) tr_class="warning";
					
					String busy_on="-";
					
					if (status.equals("BUSY")) {
						if (ptype.equals("master")) 
							sql="select wp_name from tdm_work_package where master_id="+pArr.get(m)[0];
						else 
							sql="select max(wp_name) from tdm_work_package "+
								" where id in(select work_package_id from tdm_task_assignment where worker_id="+pArr.get(m)[0]+") ";
						busy_on=getDBSingleVal(conn, sql);
					}
				
					html=html +
							"<tr class=\""+tr_class+"\">"+
							"<td>"+pArr.get(m)[0]+"</td>"+
							"<td>"+status+"</td>"+
							"<td>"+pArr.get(m)[2]+"</td>"+
							"<td>"+pArr.get(m)[3]+"</td>"+
							"<td>"+pArr.get(m)[4]+"</td>"+
							"<td>"+pArr.get(m)[5]+"</td>"+
							"<td>"+nvl(busy_on,"-")+"</td>"+
							"<td><input type=\"button\" class=\"button btn-danger\" value=\"Stop\" onclick=\"setProcessStatus('"+ptype+"','"+pArr.get(m)[0]+"','stop');\"></td>"+
							"</tr>";
							
				}
				
				html=html+"</table>";

				html=html+
						"</div> <!-- panel body -->";

				html=html + "</div> <!-- panel-->";
			}
			
			//**********************************************
			//add_remove_wp_list
			//**********************************************
			if (action.equals("add_remove_wp_list")) {
				ArrayList<String> pickedWPList= (ArrayList<String>) session.getAttribute("pickedWorkPlanIDs");
				
				if (pickedWPList==null) pickedWPList=new ArrayList<String>();
				String addremove=par1;
				String wpid=par2;
								
				try {
					if (addremove.equals("ADD")) pickedWPList.add(wpid);
					else pickedWPList.remove(pickedWPList.indexOf(wpid));
				} catch(Exception e) {e.printStackTrace();}
				
				session.setAttribute("pickedWorkPlanIDs", pickedWPList);
				
			}
			//**********************************************
			//open_workplan_selection
			//**********************************************
			if (action.equals("open_workplan_selection")) {
				sql="select  " + 
					"	w.id,   " +
					"	work_plan_name,  " +
					"	wplan_type,   " +
					"	(select a.name from tdm_apps a where id=app_id) application,   " +
					"	(Select e.name from tdm_envs e where id=env_id) environment,  " +
					"	status, master_limit, worker_limit " +
					"	from tdm_work_plan w  " +
					"	order by w.id desc";
				
				ArrayList<String[]> wpList=getDbArrayConf(conn, sql, Integer.MAX_VALUE, new ArrayList<String[]>());
				
				StringBuilder sb=new StringBuilder();
				
				sb.append("<table class=\"table\">");
				
				sb.append("<tr class=active>");
				sb.append("<td><b>Pick</b></td>");
				sb.append("<td><b>#</b></td>");
				sb.append("<td><b>Workplan Name</b></td>");
				sb.append("<td><b>Status</b></td>");
				sb.append("<td><b>Progress</b></td>");
				sb.append("<td><b>Master Limit</b></td>");
				sb.append("<td><b>Worker Limit</b></td>");
				sb.append("<td><b>Type</b></td>");
				sb.append("<td><b>Application</b></td>");
				sb.append("<td><b>Environmet</b></td>");
				
				
				sb.append("</tr>");
								
				ArrayList<String> pickedWPList= (ArrayList<String>) session.getAttribute("pickedWorkPlanIDs");
				
				
				for (int i=0;i<wpList.size();i++) {
					
					String wpid=wpList.get(i)[0];
					String wpname=wpList.get(i)[1];
					String wptype=wpList.get(i)[2];
					String wpapp=wpList.get(i)[3];
					String wpenv=wpList.get(i)[4];
					String wpstatus=wpList.get(i)[5];
					String master_limit=wpList.get(i)[6];
					String worker_limit=wpList.get(i)[7];
					
					String tr_class="";
					if (wpstatus.equals("CANCELLED") || wpstatus.equals("INVALID")) tr_class="danger";
					if (wpstatus.equals("FINISHED")) tr_class="success";
					if (wpstatus.equals("RUNNING")) tr_class="warning";
					
					if (wptype.equals("DISC")) wptype="Discovery";
					if (wptype.equals("MASK")) wptype="Data Masking";
					if (wptype.equals("COPY")) wptype="Data Copy";
					if (wptype.equals("AUTO")) wptype="Automation";
					if (wptype.equals("DEPL")) wptype="Deployment";
					
					String checked="";
					if (pickedWPList!=null && pickedWPList.contains(wpid)) checked="checked";
					
				
					int progress=getProgressRate(conn, wpid);
					String progress_div="<div class=\"progress\">"+
										"<div class=\"progress-bar\" role=\"progressbar\" aria-valuenow=\""+progress+"\" aria-valuemin=\"0\" aria-valuemax=\"100\" style=\"width: "+progress+"%;\">"+
									 	progress+" %"+
										"</div>"+
										"</div>";
						    
					
					sb.append("<tr class=\""+tr_class+"\">");
					
					sb.append("<td nowrap><input type=checkbox "+checked+" id=ch_"+wpid+" value=\""+wpid+"\" onclick=addremovePickedWPlist(this,'"+wpid+"')></td>");
					sb.append("<td nowrap>"+wpid+"</td>");
					sb.append("<td nowrap>"+wpname+"</td>");
					sb.append("<td nowrap>"+wpstatus+"</td>");
					sb.append("<td nowrap>"+progress_div+"</td>");
					sb.append("<td nowrap><input type=text size=3 maxlength=3 value=\""+master_limit+"\" onchange=changeProcessLimit('master',"+wpid+",this);></td>");
					sb.append("<td nowrap><input type=text size=3 maxlength=3 value=\""+worker_limit+"\" onchange=changeProcessLimit('worker',"+wpid+",this);></td>");
					sb.append("<td nowrap>"+wptype+"</td>");
					sb.append("<td nowrap>"+wpapp+"</td>");
					sb.append("<td nowrap>"+wpenv+"</td>");
					
					
					
					sb.append("</tr>");
				}
				
				sb.append("</table>");
				
				html=sb.toString();
				msg="ok";
			}
			//**********************************************
			//set_refresh_interval
			//**********************************************
			if (action.equals("set_refresh_interval")) {
				String new_interval=par1;
				session.setAttribute("refresh_interval", par1);
			}
			//**********************************************
			//fill_workplan_summary
			//**********************************************
			if (action.equals("fill_workplan_summary")) {
				String curr_wpl_id=par1;
				String table_filter=par2;
				
				sql=
					" select * from ( \n" + 
					" select w.id, w.status, w.work_plan_name, w.wplan_type, a.app_type,  \n"+
					" w.master_limit, w.worker_limit,  \n"+
					" w.env_id, w.app_id, w.start_date, w.end_date, w.run_options, \n"+
					" length(WARNING_MESSAGE) WARNING_MESSAGE_LENGTH  \n" + 
					" from tdm_work_plan w, tdm_apps a  \n" + 
					" where w.app_id=a.id and w.wplan_type<>'DEPL' \n"+
					" union all  \n" + 
					" select w.id, w.status, w.work_plan_name, w.wplan_type, 'DEPL' app_type,  \n"+
					" w.master_limit, w.worker_limit,  \n"+
					" w.env_id, w.app_id,  w.start_date, w.end_date, w.run_options,  \n" + 
					" length(WARNING_MESSAGE) WARNING_MESSAGE_LENGTH  \n"+
					" from tdm_work_plan w where w.wplan_type='DEPL'  \n" + 
					"   ) wx ";
				
				ArrayList<String> pickedWPList= (ArrayList<String>) session.getAttribute("pickedWorkPlanIDs");
				
				if (pickedWPList!=null && pickedWPList.size()>0 ) {
					sql=sql + " where id in(";
					for (int i=0;i<pickedWPList.size();i++) {
						String wpid=pickedWPList.get(i);
						if (i>0) sql=sql + ", ";
						sql = sql + wpid;
						
					}
					sql=sql + ") ";
				}
				else 
					sql=sql + " where id in(-1) ";
				
				sql=sql+ " order by id desc";

								
				ArrayList<String[]> wplArr=getDbArrayConf(conn, sql, Integer.MAX_VALUE, new ArrayList<String[]>());
				
				
				
				html=html+"<div align=center>"+
						  "<button class=\"btn btn-success\" onclick=openWorkPlanList();>"+
						  "Pick workplan(s) to Monitor"+
						  "</button>"+
						  "</div>";
				
				

				
				for (int m=0;m<wplArr.size();m++) {

					String wpid=wplArr.get(m)[0];
					String status=wplArr.get(m)[1];
					String wpname=wplArr.get(m)[2];
					String wptype=wplArr.get(m)[3];
					String apptype=wplArr.get(m)[4];
					String master_limit=wplArr.get(m)[5];
					String worker_limit=wplArr.get(m)[6];
					String env_id=wplArr.get(m)[7];
					String app_id=wplArr.get(m)[8];
					String start_date=wplArr.get(m)[9];
					String end_date=wplArr.get(m)[10];
					String run_options=wplArr.get(m)[11];
					int WARNING_MESSAGE_LENGTH=Integer.parseInt(nvl(wplArr.get(m)[12],"0"));
					
				
					String env_name=getDBSingleVal(conn, "select name from tdm_envs where id="+env_id);
					String app_name=getDBSingleVal(conn, "select name from tdm_apps where id="+app_id);
					
					String tr_class="x";
					
					if (status.equals("RUNNING") || status.equals("PREPARATION") || status.equals("BUILDING")) tr_class="warning";
					if (status.equals("CANCELLED") || status.equals("INVALID") || status.equals("FAILED")) tr_class="danger";
					if (status.equals("FINISHED") || status.equals("COMPLETED")) tr_class="success";
					
					String in="";
					if (wpid.equals(curr_wpl_id)) in="in";

					sql="select count(*) from tdm_master where status in ('ASSIGNED','BUSY') " +
							"and id in (select master_id from tdm_work_package where work_plan_id="+wpid +" and status='EXPORTING')";
						String linked_master_count=getDBSingleVal(conn, sql);
						
						sql = "select count(*) a from  "  +
								" (select distinct worker_id " + 
								" from tdm_task_assignment  " + 
								" where  work_plan_id=" + wpid +
								" and worker_id in (select id from tdm_worker) " +
								")  t ";
						String linked_worker_count=getDBSingleVal(conn, sql);

					int progress=getProgressRate(conn,wpid);
						
						
					html = html + 
							"<div class=\"panel panel-"+tr_class+"\">"+
							"  <div class=\"panel-heading\" role=\"tab\" id=\"heading"+wpid+"\">"+
							"       <table border=0 cellspacing=0 cellpadding=0 width=\"100%\">"+
						    "		  <tr>"+
							"           <td valign=top width=\"85%\">"+ 
									      "<small>[<span class=badge>" + wpid + "</span>] " + wpname + "</small>"+
							"<br>";

					html=html + 
							"    <button type=\"button\" class=\"btn btn-active btn-sm\" onclick=showWorkPlanDetail('"+wpid+"',true)>"+
								   "<span id=\"btOpenCloseSPAN"+wpid+"\" class=\"glyphicon glyphicon-refresh\"></span>"+
							"    </button>"+
							"";
							
					html=html+makeWorkPlanActionButtons(wpid,wptype,apptype,status,1);

					html = html +		
							"          </td>"+
							
							"          <td valign=top width=\"15%\">"+
							"           <div class=\"progress\">"+
							"            <div class=\"progress-bar\" role=\"progressbar\" aria-valuenow=\""+progress+"\" aria-valuemin=\"0\" aria-valuemax=\"100\" style=\"width: "+progress+"%;\">"+
							""            +progress+" %"+
							"            </div>"+
							"           </div>"+	
							"		   </td>"+


							"         </tr>"+
							"       </table>"+
						    "   </div>"+
						    "</div>";
						    
					
					
					
					String tablist_combo="";
					
					if (wptype.equals("AUTO")) {
						
						sql=	" select 'ALL','[All]' from dual "+
								"union " +
								"select id, script_name tab " +
								" from tdm_auto_scripts  " +
								" where app_id=(select app_id from tdm_work_plan where id="+wpid+") " +
								" and script_type='EXECUTABLE' " + 
								" order by 2";
						tablist_combo=makeCombo(conn, sql, "table_filter", " size=1 onchange=changeWorkPlanTableFilter(this.value);", table_filter, 220);	
					}
					else if (wptype.equals("DEPL")) {
						
						sql=	" select 'ALL','[All]' from dual ";
						tablist_combo=makeCombo(conn, sql, "table_filter", " size=1 onchange=changeWorkPlanTableFilter(this.value);", table_filter, 220);	
					}
					else
						{
						sql=	" select 'ALL','All' from dual "+
								"union all " +
								"select id, concat(tab_name,'@',schema_name) tab " +
								" from tdm_tabs  " +
								" where app_id=(select app_id from tdm_work_plan where id="+wpid+") " +
								" order by 2";
						tablist_combo=makeCombo(conn, sql, "table_filter", " size=1 onchange=changeWorkPlanTableFilter(this.value);", table_filter, 0);
						}
	    
							
					html=html + 
							"<table class=\"table table-condensed\">"+
								"<tr><td nowrap align=right>Configure : </td><td><b>"+
										"<a href=\"javascript:editWorkPlan('"+wpid+"');\"><span class=\"glyphicon glyphicon-cog\"></span></a> "+
								"</b>";
								
					html=html + 
								"<tr><td align=right>Status : </td><td><b>"+
									status+
								"</b>";

					if (status.equals("INVALID")) {

						html = html + 
								"<button type=button class=\"btn btn-danger btn-sm\" onclick=\"showInvalidMsg('"+wpid+"');\">"+
								" <span class=\"glyphicon glyphicon-exclamation-sign\">"+
								"</button>";
						
						sql="select count(*) from tdm_work_package where work_plan_id="+wpid;
						String wpc_count=getDBSingleVal(conn, sql);
						//if masking validation is not passed
						if (!wpc_count.equals("0"))
							html = html + 
									"<button type=button class=\"btn btn-success btn-sm\" onclick=\"skipValidation('"+wpid+"');\">"+
									" <span class=\"glyphicon glyphicon-ok\">Skip</span>"+
									"</button>";
					}
					
					
					html=html + "</td></tr>";
					
					
					
					
					
					
					html=html + "<tr><td align=right>App. : </td><td>"+
							"<b><a href=\"designer2.jsp?app_type="+nvl(apptype,"MASK")+"&app_id="+nvl(app_id,"0")+"&env_id="+nvl(env_id,"0")+"&tab_id=0\">"+
								app_name+
							"</a></b>"+
						"</td></tr>";
					
					if (WARNING_MESSAGE_LENGTH>0) {
						
						html = html + 
								"<tr><td colspan=2>"+
								"<button type=button class=\"btn btn-warning\" onclick=\"showWarningMsg('"+wpid+"');\">"+
								" <span class=\"glyphicon glyphicon-exclamation-sign\"> Warnings Found </span>"+
								"</button>"+
								"</td></tr>";

					}
								
					if (wptype.equals("AUTO")) {
						
						
						String domain="";
						String autolib="";		
						String browser="";
						String paramsin="";
						sql="select concat(domain_class_name,'.',domain_instance_name) "+ 
							"	from tdm_domain_instance i, tdm_domain_class c "+
							"	where i.domain_class_id=c.id and i.id=" + env_id;
						domain=getDBSingleVal(conn, sql);
					
						String[] arr=run_options.split("\n|\r");
						for (int i=0;i<arr.length;i++) {
							String item=arr[i];
							if (item.contains("=")) {
								String key=item.split("=")[0];
								String val=item.substring(new String(key+"=").length());
								if (key.equals("AUTOMATION_LIBRARY")) autolib=val;
								if (key.equals("AUTOMATION_BROWSER")) browser=val;
								if (key.equals("AUTOMATION_PARAMS_IN")) paramsin=val;
							}
						}
						
						html=html + 
								""+
								"<tr><td nowrap align=right>Domain : </td>"+
								"<td nowrap><b>"+domain+"</b></td>"+
								"</tr>"+
								"<tr><td nowrap align=right>AutLib : </td>"+
								"<td nowrap><b>"+autolib+"</b></td><"+
								"/tr>"+
								"<tr><td nowrap align=right>Slot : </td>"+
								"<td nowrap><b>"+browser+"</b></td>"+
								"</tr>";
						if (paramsin.length()>0)
							html=html + 		
							"<tr><td  nowrap align=right>Params : </td>"+
							"<td nowrap><b>"+paramsin+"</b></td>"+
							"</tr>"+
							"";
					}
					else 
					
						
					html=html + 
							"<tr><td align=right>Env. : </td><td><b>"+env_name+"</b></td></tr>";
							
					if (!wptype.equals("DISC"))
						html=html +
								"<tr><td align=right>Filter : </td><td  nowrap>"+
									tablist_combo+
								"</td></tr>";								
						
						if (start_date.length()>0)		
						html = html +
								"<tr><td align=right>Start : </td><td><b>"+start_date+"</b>"+
								"<button class=\"btn btn-sm\" onclick=showInfoDetail('"+wpid+"','tdm_work_plan','prep_script_log');>"+
								"<span class=\"glyphicon glyphicon-log-in\"></span>"+
								"</button>" +
								"</td></tr>";
						
						if (end_date.length()>0)
						html=html+ 
								"<tr><td align=right>End : </td><td><b>"+end_date+"</b>"+
										"<button class=\"btn btn-sm\" onclick=showInfoDetail('"+wpid+"','tdm_work_plan','post_script_log');>"+
										"<span class=\"glyphicon glyphicon-log-out\"></span>"+
										"</button>" +
										"</td></tr>";
								
						
								
							
					
						
							
				} //for
				
				
				
				msg="ok:javascript:setRefreshInterval()";
			
				
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
			
			//**********************************************
			//fill_workplan_detail
			//**********************************************
			if (action.equals("fill_workplan_detail")) {
				
				String wpid=par1;
				String table_filter=nvl(par2,"-");
				String wp_type=getDBSingleVal(conn, "select wplan_type from tdm_work_plan where id="+wpid);

				html="<div class=\"panel panel-primary\">";

				html=html + 
						"<div class=\"panel-heading\">"+
							"Work Packages"+
						"</div> <!-- panel heading -->";
				
				html=html + 
						"<div class=\"panel-body\">";

				html=html+
						"<table class=\"table table-bordered table-striped\">"+
				
						"<tr>"+
						"<td><b>Status</td>"+
						"<td><b>WP#</td>"+
						"<td><b>Dur.</td>"+
//						"<td><b>Done Task#</td>"+
						"<td><b>All#</td>"+
						"<td><b>Success#</td>"+
						"<td><b>Fail#</td>"+
						"</tr>";
						
						sql=	" select " +
								" status, " + 
								" count(*) wp_count, " +
								" round(avg(duration)) avg_duration, " +
								" sum(all_count) all_count, "+
								" sum(export_count) export_count, " +
								" sum(done_count) done_count, " +
								" sum(success_count) success_count,  " + 
								" sum(fail_count) fail_count   " +
								" from tdm_work_package " +
								" where work_plan_id=" + wpid;

						if (wp_type.equals("AUTO") && !table_filter.equals("-") && !table_filter.equals("ALL")) 
							sql=sql + " and tab_id=" + table_filter;
						
						sql=sql +
								" group by status order by 1 " ;
						
						long all_count=0;
						long  export_count=0;
						long  done_count=0;
						long success_count=0;
						long fail_count=0;

						ArrayList<String[]> recs=getDbArrayConf(conn, sql, Integer.MAX_VALUE, bindlist);
						
						for (int i=0;i<recs.size();i++) {
							String[] arec=recs.get(i);
							
							
							String wp_Status=arec[0];
							String wp_count=arec[1];
							String wp_duration=arec[2];
							String wp_record=arec[3];
							String wp_export=arec[4];
							String wp_done=arec[5];
							String wp_success=arec[6];
							String wp_fail=arec[7];
							
							
							all_count=all_count+Long.parseLong(nvl(wp_record,"0"));
							export_count=export_count+Long.parseLong(nvl(wp_export,"0"));
							done_count=done_count+Long.parseLong(nvl(wp_done,"0"));
							success_count=success_count+Long.parseLong(nvl(wp_success,"0"));
							fail_count=fail_count+Long.parseLong(nvl(wp_fail,"0"));
							
							
							String bgcolor="white";
							
							if (wp_Status.equals("NEW")) bgcolor="default";

							if (wp_Status.equals("ASSIGNED")) bgcolor="info";

							if (wp_Status.equals("EXPORTING")) bgcolor="warning";
							if (wp_Status.equals("MASKING")) bgcolor="warning";

							if (wp_Status.equals("FINISHED")) bgcolor="success";

							html=html+
								"<tr class=\""+bgcolor+"\">"+
								"<td><a href=\"#\" onclick=getWPDetailList('WORK_PACKAGE','"+wp_Status+"','NO')>"+ 
										wp_Status +
								"</a></td>"+
								"<td align=right>"+ formatnum(wp_count) +"</td>"+
								"<td align=right>"+ formatnum(wp_duration) +"</td>"+
								"<td align=right>"+ formatnum(wp_export) +"</td>"+
								"<td align=right>"+ formatnum(wp_success) +"</td>"+
								"<td align=right>"+ formatnum(wp_fail) +"</td>"+
								"</tr>";
								
									
						}
						
						html=html+
							"<tr  bgcolor=#FFDDAA>"+
							"<td colspan=3>"+
								"<b>ALL</b>"+
							"</td>"+
							"<td align=right><b>"+ formatnum(""+export_count) +"</td>"+
							"<td align=right><b>"+ formatnum(""+success_count) +"</td>"+
							"<td align=right><b>"+ formatnum(""+fail_count) +"</td>"+
							"</tr>";
						
						

				html=html+"</table>";								
				html=html+		
						"</div> <!-- panel body -->";

				html=html + 
						"<div class=\"panel-heading\">"+
							"Tasks"+
						"</div> <!-- panel heading -->";
				
				html=html + 
						"<div class=\"panel-body\">";
						
				String wpc_filter=table_filter;
				if(wp_type.equals("AUTO")) wpc_filter="ALL";
				ArrayList<String[]> wpclist=getWpcListByWorkPlan(conn, wpid, wpc_filter);


				int elcount=0;
				sql="";
				
				if (wpclist.size()>100 || wp_type.equals("DEPL"))
					elcount=999999; //to force fail
				else
				for (int i=0;i<wpclist.size();i++) {
					
					String wpc_id=wpclist.get(i)[0];
					String wpc_status=wpclist.get(i)[1];
					if (!wpc_status.equals("NEW")) {
						elcount++;
					
						if (sql.length()>0) sql=sql + "\n union all \n";					
						sql=sql + 
								" select " + 
								" status, " +  
								" count(*) task_count,  " + 
								" avg(duration) avg_duration, " + 
								" sum(all_count) rec_count, " + 
								" sum(done_count) done_count, " + 
								" sum(success_count) success_count, " + 
								" sum(fail_count) fail_count " + 
								" from tdm_task_" +wpid+ "_"  +wpc_id+ " " ;
						if (wp_type.equals("AUTO") && !nvl(table_filter,"ALL").equals("-") && !nvl(table_filter,"ALL").equals("ALL"))
								sql=sql  + " where script_id="+table_filter;
						sql=sql + 
								" group by " + 
								" status";
					}
				} //for
				
				
				sql=""  + 
						" select status,  " +
						" sum(task_count) task_count,"+
						" round(avg(avg_duration)) avg_duration," +
						" sum(rec_count) rec_count, " +
						" sum(done_count) done_count," +
						" sum(success_count) success_count," +
						" sum(fail_count) fail_count" +
						" from \n(" + sql + ") a \n" +
						"  group by status order by 1 " ; 
				
				
				if (elcount>0) {
					
					all_count=0;
					export_count=0;
					success_count=0;
					fail_count=0;
					
					html=html+
						"<table class=\"table table-condensed\" >"+
						"<tr>"+
						"<td><b>Status</td>"+
						"<td><b>Task#</td>"+
						"<td><b>Done#</td>"+
						"<td><b>Dur.</td>"+
						"<td><b>Record#</td>"+ 
						"<td><b>Success#</td>"+
						"<td><b>Fail#</td>"+
						"<td><b>Retry</td>"+
						"</tr>";
						
						//only from task_summary
						//elcount=999999;
						
						if (elcount==999999) 
							recs=null;
						else
							recs=getDbArrayConf(conn, sql, Integer.MAX_VALUE, null, 10);
						
						
						if (recs==null || recs.size()==0) {
							
							
							sql="select status, \n " + 
								"	sum(task_count) task_count,\n " + 
								"	round(avg(avg_duration)) avg_duration,\n " + 
								"	sum(rec_count) rec_count, \n " + 
								"	sum(done_count) done_count,\n " + 
								"	sum(success_count) success_count,\n " + 
								"	sum(fail_count) fail_count\n " + 
								"	from tdm_task_summary a \n "+
								"	where work_plan_id="+wpid+" \n " ;
							
							if (!nvl(table_filter,"-").equals("-"))
								sql=sql + " and work_package_id in (select id from tdm_work_package where tab_id="+table_filter+") \n" ; 
							
							sql=sql + 
								
								"	group by status order by 1";
								
								
							recs=getDbArrayConf(conn, sql, Integer.MAX_VALUE, null, 30);
						}


						
						for (int i=0;i<recs.size();i++) {
							String[] arec=recs.get(i);
							
							String task_Status=arec[0];
							String task_count=arec[1];
							String task_duration=arec[2];
							String task_record=arec[3];
							String task_done=arec[4];
							String task_success=arec[5];
							String task_fail=arec[6];
							
							all_count=all_count+Long.parseLong(nvl(task_record,"0"));
							success_count=success_count+Long.parseLong(nvl(task_success,"0"));
							fail_count=fail_count+Long.parseLong(nvl(task_fail,"0"));
							
							
							
							String bgcolor="";
							
							if (task_Status.equals("NEW"))  bgcolor="default";
			
							if (task_Status.equals("ASSIGNED"))  bgcolor="info";
			
							if (task_Status.equals("RUNNING"))   bgcolor="warning";
			
							if (task_Status.equals("FINISHED"))  bgcolor="success";
			
							if (task_Status.equals("RETRY"))  bgcolor="dangers";
							
							html=html+
								"<tr class="+ bgcolor +">"+
								"<td>"+
									"<a href=\"#\" onclick=getWPDetailList('TASK','"+task_Status+"','NO')>"+task_Status + "</a>"+
								"</td>"+
								"<td align=right>"+ formatnum(task_count) +"</td>"+
								"<td align=right>"+ formatnum(task_done) +"</td>"+
								"<td align=right>"+ formatnum(task_duration) +"</td>"+
								"<td align=right>"+ formatnum(task_record) +"</td>"+
								"<td align=right>"+ formatnum(task_success) +"</td>";
							if (task_fail.equals("0"))
								html=html + 
								"<td align=right>"+
										formatnum(task_fail) +
									"</td>";	
							else
							html=html + 
									"<td align=right>"+
										"<a href=\"#\"  onclick=getWPDetailList('TASK','"+task_Status+"','YES')>"+
											formatnum(task_fail) +
										"</a>"+
										"</td>";	
								
								
								
								if (!nvl(task_fail,"0").equals("0")) {
									html=html + 
											"<td align=center>"+
												"<button type=button class=\"btn btn-warning btn-sm\" onclick=setWorkPlanStatus1('"+wpid+"','REPEAT:"+task_Status+"')>"+
													"<span class=\"glyphicon glyphicon-repeat\">"+
												"</button>"+
											"</td>";	
								} else {
									html=html + "<td align=right>-</td>";	
								}
								
								
							html=html + "</tr>";
						}
						
						
						
						
						html=html+
							"<tr  bgcolor=#FFDDAA>"+
							"<td colspan=4>"+
							    "<b>ALL</b>"+
							"</td>"+
							"<td align=right><b>" + formatnum(""+all_count) + "</td>"+
							"<td align=right><b>" + formatnum(""+success_count)  +"</td>"+
							"<td align=right><b>" + formatnum(""+fail_count) + "</td>"+
							"</tr>"+
							"</table>";
						
				} //if (wpclist.size()>0)
				
				
				html=html+
						"</div> <!-- panel body -->";

				html=html + "<div> <!-- panel-->";

				
				
				msg="ok:javascript:setRefreshInterval()";
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
				String caller=par2;
				
				html="";
				sql="update tdm_work_plan  set status='COMPLETED' where id="+wpid;

				execDBConf(conn, sql, new ArrayList<String[]>());
				if (caller.equals("window"))
					msg="ok:javascript:openWorkPlanWindow('"+wpid+"');  ";
				else 
					msg="ok:javascript:makeWorkPlanList();  ";

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
			//save_title_list
			//**********************************************
			if (action.equals("save_title_list")) {
				
				String list_id=par1;
				String title_list=par2.replaceAll(":", "|::|");
				
				sql="update tdm_list set title_list=? where id=?";
				bindlist=new ArrayList<String[]>();
				bindlist.add(new String[]{"STRING",title_list});
				bindlist.add(new String[]{"INTEGER",list_id});
				
				log_trial(conn, "tdm_list", Integer.parseInt(list_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
				execDBConf(conn, sql, bindlist);
				
				html="";
				msg="ok";

			}
			//**********************************************
			//change_delimiter
			//**********************************************
			if (action.equals("change_delimiter")) {
				
				String delimiter=nvl(par1,";");
				
				session.setAttribute("column_delimiter", delimiter);	
				
				html="";
				msg="ok";
			
			}
			
			//**********************************************
			//list_of_profile
			//**********************************************
			if (action.equals("list_of_profile")) {
				String curr_profile_id=par1;
				String curr_app_type=nvl(par2,"MASK");
				String curr_field_id=nvl(par3,"0");
				String pick_for=nvl(par4,"MASK");
				
				
				String title="";
				if (!curr_field_id.equals("0") && !curr_field_id.equals("undefined")) {
					sql="select replace(concat(cat_name,'.',schema_name, '.', tab_name,'[', field_name, ']'),'${default}','')  from tdm_tabs t, tdm_fields f "+ 
							"	where f.id=?  and f.tab_id=t.id ";
						bindlist.clear();
						bindlist.add(new String[]{"INTEGER",curr_field_id});
						ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);
						
						if (arr!=null && arr.size()==1) title=arr.get(0)[0];
				}
				
			
		    	sql = "select id, if(run_on_server='YES',concat(name,' (*) '),name) from tdm_mask_prof ";
		    	
		    	if (pick_for.equals("COPY"))
		    		sql=sql + " where  rule_id not in ('GROUP','GROUP_MIX','MIX') " ;
		    	
		    	if (pick_for.equals("MASK"))
		    		sql=sql + " where  rule_id not in ('COPY_REF') " ;
		    	
		    	if (pick_for.equals("DMASK"))
		    		sql=sql + " where  rule_id in ('HIDE','FIXED','RANDOM_NUMBER','RANDOM_STRING','SETNULL','ENCAPSULATE','NOCOL') " ;
		    	
		    	if (pick_for.equals("CALC")) {
		    		if (sql.contains(" where ")) 
		    			sql=sql+ " and rule_id in('SQL') ";
		    		else 
		    			sql=sql+ " where rule_id in('SQL') ";
		    	}
		    	
		    	sql=sql + " order by "+
		    			" if (rule_id in('NONE','GROUP','GROUP_MIX','MIX','HASH_REF','COPY_REF'),1,99), name";
		        html=makeCombo(conn, sql, "listProfile", "id=listProfile size=26 onchange=openProfileDetail()  style=\"height:100%; \" ", curr_profile_id, 0);
				
		        if (title.length()>0)
		        	html = "<span class=\"label label-warning\" style=\"width:100%;\">Pick Profile For <b>" + title+ "</b></span><br>"+
		        		"<center>" + html + "</center>";
        		else 
        			html = "<center>" + html + "</center>";	
        			
        			html = html + "<b><small><i>(*) : Runs on server profile</i></small></b>";
				msg="ok";
			}	
			
			
			
			
			
			
			} //	if (msg.indexOf("nok:")==-1) {	
				
			//**********************************************
			//add_new_profile
			//**********************************************
			if (action.equals("add_new_profile")) {
				String mask_prof_name=par1;
				bindlist.add(new String[]{"STRING", mask_prof_name});
				
				sql="select id from tdm_mask_prof where name=?";
				ArrayList<String[]> checkArr=getDbArrayConf(conn, sql, 1, bindlist);
				if (checkArr.size()>0) {
					msg="nok:Cannot be inserted. There are another list named with '"+mask_prof_name+"'.";
				}
				else {
					sql="insert into tdm_mask_prof (name, rule_id, "+
								" hide_char, "+
								" hide_by_word, "+
								" hide_after, "+
								" random_range, "+
								" format, "+
								" date_change_params "+
							" ) "+
							" values (?,'NEW',"+
								"'*',"+
								"'YES',"+
								"'2',"+
								"'0,10',"+
								"'dd/MM/yyyy HH:mm:ss',"+
								"'day=10,month=5,year=0'"+
							"    )";
					execDBConf(conn, sql,bindlist);
					
					sql="select max(id) from tdm_mask_prof where name=?";
					String new_mask_prof_id="";
					try {
						new_mask_prof_id=getDbArrayConf(conn, sql, 1, bindlist).get(0)[0];
					} catch(Exception e) {
						e.printStackTrace();
						new_mask_prof_id="";
					}
					
					if (new_mask_prof_id.length()>0) {
						
						sql="update tdm_mask_prof set short_code='MASK_"+new_mask_prof_id+"' where id="+new_mask_prof_id;
						log_trial(conn, "tdm_mask_prof", Integer.parseInt(new_mask_prof_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
						execDBConf(conn, sql, new ArrayList<String[]>());
						
						
					}
					
					html="-";
					msg="ok:javascript:openProfileDetailByID('"+new_mask_prof_id+"'); loadListofProfile(); ";
				} //if (checkArr.size()>0) {
			
			}			

				
			//**********************************************
			//details_of_profile
			//**********************************************
			if (action.equals("details_of_profile")) {
				String mask_prof_id=par1;
				
	            StringBuilder sb=new StringBuilder();

	            if (!nvl(par1,"0").equals("0")) {
		            sql="select " +
		    	            " name, " + 
		    	            " short_code, "  + 
		    	            " rule_id," +
		    	            " post_stmt, " + 
		    	            " hide_char, "+
		    	            " hide_after, "+ 
		    	            " hide_by_word, "+
		    	            " src_list_id, " +
		    	            " random_range, "+
		    	            " random_char_list, " +
		    	            " regex_stmt, "+ 
		    	            " pre_stmt, "+ 
		    	            " date_change_params, " + 
		    	            " format, " + 
		    	            " fixed_val, " +
		    	            " js_code, " +
		    	            " js_test_par, " +
		    	            " run_on_server, " + 
		    	            " scramble_part_type, " + 
		    	            " scramble_part_type_par1, " + 
		    	            " scramble_part_type_par2 " + 
		    	            " 	from tdm_mask_prof where id="+mask_prof_id;
		    	            
		    	            String[] arr=getDbArrayConf(conn, sql, 1, new ArrayList<String[]>()).get(0);
		    	            

		    	            String p_name=arr[0];
		    	            String p_short_code=arr[1];
		    	            String p_rule_id=arr[2];
		    	            String p_post_stmt=arr[3];
		    	            String p_hide_char=arr[4];
		    	            String p_hide_after=arr[5];
		    	            String p_hide_by_word=arr[6];
		    	            String p_src_list_id=arr[7];
		    	            String p_random_range=arr[8];
		    	            String p_random_char_list=arr[9];
		    	            String p_regex_stmt=arr[10];
		    	            String p_pre_stmt=arr[11];
		    	            String p_date_change_params=arr[12];
		    	            String p_format=arr[13];
		    	            String p_fixed_val=arr[14];
		    	            String p_js_code=arr[15];
		    	            String p_js_test_par=arr[16];
		    	            String p_run_on_server=arr[17];
		    	            String p_scramble_part_type=arr[18];
		    	            String p_scramble_part_type_par1=arr[19];
		    	            String p_scramble_part_type_par2=arr[20];
		    	            
		    	            
		    	            sql="" +
		                            //" select 'NONE','Do not change' from dual union all " +
		                            //" select 'GROUP','Group By this Field' from dual union all " +
		                            //" select 'GROUP_MIX','Group Switch' from dual union all " +
		                            //" select 'MIX','Record Switch' from dual union all " +
		                            //" select 'HASH_REF','List Hashing Reference Field' from dual union all " +
		                            " select 'FIXED','Fixed Value' from dual union all " +
		                            " select 'HIDE','Hide characters' from dual union all " +
		                            " select 'SETNULL','Set Null' from dual union all " +
		                            " select 'NOCOL','Hide Column' from dual union all " +
                            		" select 'ENCAPSULATE','Encapsulating SQL Code' from dual union all " +
		                            " select 'HASHLIST','List masking' from dual union all " 	+
                            		" select 'KEYMAP','Single Key-Value Mapping' from dual union all " 	+
		                            " select 'JAVASCRIPT','JavaScript Engine' from dual union all " +
                            		" select 'SQL','SQL Engine' from dual union all " +
		                            " select 'SCRAMBLE_INNER','Scramble inner' from dual union all " +
		                            " select 'SCRAMBLE_PARTIAL','Scramble Partial' from dual union all " +
		                            " select 'SCRAMBLE_RANDOM','Scramble outter (random)' from dual union all " +
		                            " select 'SCRAMBLE_DATE','Date Scrambling' from dual union all " +
		                            " select 'RANDOM_NUMBER','Randomized number' from dual union all " +
		                            " select 'RANDOM_STRING','Randomized string' from dual ";
		    	            
		    	            String combo_rule_id=makeCombo(conn, sql, "p_rule_id", " id=p_rule_id onchange=\"changeProfileField('rule_id',this.value);\" ", p_rule_id, 300);
		    	            //NAME -------------------------------------
		    	            sb.append("<div class=row>");

		    	            sb.append("	<div class=\"col-md-12\">");
		    				sb.append("		<h4><b><font color=red>"+p_name+"</font></b></h4>");
		    				sb.append("	</div>");
		    	            sb.append("</div>");	

		    	            //RULE_ID -------------------------------------
		    	            if (!"-HASH_REF-NONE-GROUP-GROUP_MIX-MIX-".contains(nvl(p_rule_id,"NULL"))) {
			    	           
		    	            	sb.append("<div class=row>");
			    				sb.append("	<div class=\"col-md-4\">");
			    				sb.append("		<span class=\"label label-info\">Profile Type </span>");
			    				sb.append("	</div>");

			    				sb.append("	<div class=\"col-md-8\">");
			    				sb.append(combo_rule_id);
			    				sb.append("	</div>");
			    	            sb.append("</div>");

			    	            //SHORT CODE  -------------------------------------
			    	            sb.append("<div class=row>");
			    				sb.append("	<div class=\"col-md-4\">");
			    				sb.append("		<span class=\"label label-info\">Short Code  </span>");
			    				sb.append("	</div>");

			    				sb.append("	<div class=\"col-md-8\">");
			    				sb.append("		<input type=text id=p_short_code size=15 value=\""+p_short_code+"\" onchange=\"changeProfileField('short_code',this.value);\">");
			    				sb.append("(*) Case Sensitive");
			    				sb.append("	</div>");
			    	            sb.append("</div>");
		    	            	
			                   sql="" +
			                           " select 'UPPERCASE','to UpperCase' from dual union all " +
			                           " select 'LOWERCASE','to LowerCase' from dual union all " +
			                           " select 'INITIALS','Initials are Uppercase' from dual " ;
				                String combo_post_stmt=makeCombo(conn, sql, "p_post_stmt", " id=p_post_stmt onchange=\"changeProfileField('post_stmt',this.value);\"", p_post_stmt, 200);

				                //POST STMT ---------------------------------
				                sb.append("<div class=row>");
				    			sb.append("	<div class=\"col-md-4\">");
				    			sb.append("		<span class=\"label label-info\">Post Process</span>");
				    			sb.append("	</div>");

				    			sb.append("	<div class=\"col-md-8\">");
				    			sb.append(combo_post_stmt);
				    			sb.append("	</div>");
				                sb.append("</div>");

				                sql="select 'NO','No' from dual union all select 'YES','Yes' from dual";
				                String combo_run_on_server=makeCombo(conn, sql, "p_run_on_server", "size=1 id=p_run_on_server onchange=\"changeProfileField('run_on_server',this.value);\"", p_run_on_server, 200);

				                //RUN ON SERVER
				                 if ("NONE-FIXED-HIDE-SQL-SCRAMBLE_INNER-SCRAMBLE_DATE-RANDOM_NUMBER-RANDOM_STRING-HASHLIST-SETNULL".contains(p_rule_id)) {
				                	 sb.append("<div class=row>");
						    			sb.append("	<div class=\"col-md-4\">");
						    			sb.append("		<span class=\"label label-info\">Run On Server</span>");
						    			sb.append("	</div>");

						    			sb.append("	<div class=\"col-md-8\">");
						    			sb.append(combo_run_on_server);
						    			sb.append("	</div>");
						                sb.append("</div>");
				                 }
				                

				                //SEPERATOR
				                sb.append("<hr>");
			    	            
		    	            } //if ("-NONE-GROUP-GROUP_MIX-MIX-".contains(p_rule_id))
		    	            
		    	            if (p_rule_id.equals("HASHLIST")) {
		    		            sql="select id, name from tdm_list order by name ";
		    		            String combo_list=makeCombo(conn, sql, "p_src_list_id", " id=p_src_list_id onchange=\"changeProfileField('src_list_id',this.value);\"", nvl(p_src_list_id,"0"), 200);
		    	
		    		            //SRC_LIST_ID ---------------------------------
		    		            sb.append("<div class=row>");
		    					sb.append("	<div class=\"col-md-4\">");
		    					sb.append("		<span class=\"label label-info\">Source List</span> ");
		    					sb.append("	</div>");

		    					sb.append("	<div class=\"col-md-8\">");
		    					sb.append(combo_list);
		    					sb.append("	</div>");
		    		            sb.append("</div>");
		    	            }
		    	            
		    	            
		    	            if (p_rule_id.equals("KEYMAP")) {
		    		            sql="select id, name from tdm_list order by name ";
		    		            String combo_list=makeCombo(conn, sql, "p_src_list_id", " id=p_src_list_id onchange=\"changeProfileField('src_list_id',this.value);\"", nvl(p_src_list_id,"0"), 200);
		    	
		    		            //SRC_LIST_ID ---------------------------------
		    		            sb.append("<div class=row>");
		    					sb.append("	<div class=\"col-md-4\">");
		    					sb.append("		<span class=\"label label-info\">Source List</span> ");
		    					sb.append("	</div>");

		    					sb.append("	<div class=\"col-md-8\">");
		    					sb.append(combo_list);
		    					sb.append("	</div>");
		    		            sb.append("</div>");
		    		            
		    		            
		    		            sb.append("<div class=row>");
			    				sb.append("	<div class=\"col-md-4\">");
			    				sb.append("		<span class=\"label label-info\">KeyMap Main Filename</span>");
			    				sb.append("	</div>");

			    				sb.append("	<div class=\"col-md-8\">");
			    				sb.append("<b>"+ getParamByName(conn, "TDM_PROCESS_HOME")+File.separator+"list"+File.separator+" </b>");
			    				sb.append("<input type=text size=30 name=random_char_list value=\""+ clearHtml(p_random_char_list) +"\" onchange=\"changeProfileField('random_char_list',this.value);\">");
			    				sb.append("	</div>");
			    	            sb.append("</div>");
			    	            
			    	            
		    	            }
		    	            
		    	            
		    	            if (p_rule_id.equals("FIXED")) {
		    		            //FIXED_VAL ---------------------------------
		    		            sb.append("<div class=row>");
		    					sb.append("	<div class=\"col-md-4\">");
		    					sb.append("		<span class=\"label label-info\">Fixed Value</span>");
		    					sb.append("	</div>");

		    					sb.append("	<div class=\"col-md-8\">");
		    					sb.append("<input type=text name=fixed_val value=\"" + codehtml(p_fixed_val) + "\" size=40 maxlength=200 onchange=\"changeProfileField('fixed_val',this.value);\">  ");
		    					sb.append("	</div>");
		    		            sb.append("</div>");
		                }
		    	            

		                if (p_rule_id.equals("HIDE")) {

		                		//------------------
		    		            sb.append("<div class=row>");
		    					sb.append("	<div class=\"col-md-4\">");
		    					sb.append("		<span class=\"label label-info\">Hide with character</span>");
		    					sb.append("	</div>");

		    					sb.append("	<div class=\"col-md-8\">");
		    					sb.append("<input type=text name=hide_char value=\"" + p_hide_char + "\" size=3 maxlength=1 onchange=\"changeProfileField('hide_char',this.value);\">");
		    					sb.append("	</div>");
		    		            sb.append("</div>");
		    		    
		    		            //--------------------
		    		            sb.append("<div class=row>");
		    					sb.append("	<div class=\"col-md-4\">");
		    					sb.append("		<span class=\"label label-info\">Hide after xx character</span> ");
		    					sb.append("	</div>");

		    					sb.append("	<div class=\"col-md-8\">");
		    					sb.append("<input type=text name=hide_after value=\"" + p_hide_after + "\" size=3 maxlength=3 onchange=\"changeProfileField('hide_after',this.value);\">");
		    					sb.append("	</div>");
		    		            sb.append("</div>");

		    		            //-------------------------
		    		            String checked="";
		                        if (nvl(p_hide_by_word,"NO").equals("YES"))
		                            checked="checked";
		                        
		    		            sb.append("<div class=row>");
		    					sb.append("	<div class=\"col-md-4\">");
		    					sb.append("		<span class=\"label label-info\">Keep Spaces</span>");
		    					sb.append("	</div>");

		    					sb.append("	<div class=\"col-md-8\">");
		    					sb.append("<input " + checked+ " type=checkbox id=hide_by_word value=\"YES\" onchange=\"changeProfileField('hide_by_word',this.value);\">");
		    					sb.append("	</div>");
		    		            sb.append("</div>");

		                }

		                if (p_rule_id.equals("JAVASCRIPT")) {
		            		//------------------
		    	            sb.append("<div class=row>");
		    				sb.append("	<div class=\"col-md-4\">");
		    				sb.append("		<span class=\"label label-info\">Javascript Code</span>");
		    				sb.append("<br><br><br><br>");
		    				sb.append("<b><a href=\"#\" onclick=showsamplejs()>Paste Sample >>> </a></b>");
		    				sb.append("	</div>");

		    				sb.append("	<div class=\"col-md-8\">");
		    				sb.append("" +
		                			"<textarea id=\"p_js_code\" rows=8 cols=40  style=\"width:100%\">" + p_js_code + "</textarea>"+
		    						"<br><font color=red>Field names between {?} is case sensitive!!!.</font>"+
		            				"<input type=text size=33 id=p_js_test_val value=\""+codehtml(p_js_test_par)+"\"  onchange=\"changeProfileField('js_test_par',removePipes(this.value));\">"+
		            				"<input type=button name=bt_test value=\"Test\" onclick=\"testjs_code();\">"+
		                    		"<div id=jsret></div>"+
		                    		"<br>"+
		                			"<button type=button class=\"btn btn-success btn-sm\" onclick=\"changeProfileField('js_code',removePipes(document.getElementById('p_js_code').value));\">"+
		    						"Save JavaScript"+
		    						"</button>"
		                			);
		    				sb.append("	</div>");
		    	            sb.append("</div>");
		                	
		                }
		                
		                if (p_rule_id.equals("SQL") || p_rule_id.equals("ENCAPSULATE")) {
		            		//------------------
		    	            sb.append("<div class=row>");
		    				sb.append("	<div class=\"col-md-4\">");
		    				sb.append("		<span class=\"label label-info\">SQL Code</span>");
		    				sb.append("	</div>");

		    				sql="select id, name from tdm_envs order by name";
		    				String combo_envs=makeCombo(conn, sql, "env_id", "id=env_id", "", 300);
		    				sb.append("	<div class=\"col-md-8\">");
		    				sb.append("<textarea id=\"p_js_code\" rows=5 cols=40>" + p_js_code + "</textarea>"+
		    						"<br>"+
		                			"<button type=button class=\"btn btn-success btn-sm\" onclick=\"changeProfileField('js_code',removePipes(document.getElementById('p_js_code').value));\">"+
		    						"Save SQL"+
		    						"</button>"+
		    						"<br>"+
		    						"DB to test : "+combo_envs+
		    						"<br>"+
		            				"<input type=text size=40 id=p_sql_test_val value=\""+codehtml(p_js_test_par)+"\"  onchange=\"changeProfileField('js_test_par',removePipes(this.value));\">"+
		            				"<input type=button name=bt_test value=\"Test\" onclick=\"testsql_code();\">"+
		                    		"<div id=sql_result></div>"
		                			);
		    				sb.append("	</div>");
		    	            sb.append("</div>");
		                	
		                }
		                
		                if (p_rule_id.equals("SCRAMBLE_RANDOM")) {
		            		//------------------
		    	            sb.append("<div class=row>");
		    				sb.append("	<div class=\"col-md-4\">");
		    				sb.append("		<span class=\"label label-info\">Random Character List</span>");
		    				sb.append("	</div>");

		    				sb.append("	<div class=\"col-md-8\">");
		    				sb.append("<textarea name=random_char_list rows=4 cols=40 onchange=\"changeProfileField('random_char_list',this.value);\">" + p_random_char_list + "</textarea>");
		    				sb.append("	</div>");
		    	            sb.append("</div>");
		                	
		                }
		                
		                if (p_rule_id.equals("SCRAMBLE_PARTIAL")) {
		            		
		                	ArrayList<String[]> partList=new ArrayList<String[]>();
		                	partList.add(new String[]{"ALL","Scramble All"});
		                	partList.add(new String[]{"FIRST","Scramble First ? chars"});
		                	partList.add(new String[]{"LAST","Scramble Last ? chars"});
		                	partList.add(new String[]{"EXCEPT_FIRST","Scramble Except first ?  chars"});
		                	partList.add(new String[]{"EXCEPT_LAST","Scramble Except last ?  chars"});
		                	partList.add(new String[]{"BETWEEN","Between ?th  and ?th  chars"});
		                	partList.add(new String[]{"BETWEEN_FIRST_LAST","Between First ? and Last ? chars"});
		                	partList.add(new String[]{"EXCEPT","Except ?"});
		                	
		                	
		                	//------------------
		    	            sb.append("<div class=row>");
		    				sb.append("	<div class=\"col-md-4\">");
		    				sb.append("		<span class=\"label label-info\">Scrambling What?</span>");
		    				sb.append("	</div>");

		    				sb.append("	<div class=\"col-md-8\">");
		    				sb.append(makeComboArr(partList, "", "id=scramble_part_type  onchange=changeScramblePartialType('"+mask_prof_id+"')", p_scramble_part_type, 300));
		    				sb.append("	</div>");
		    	            sb.append("</div>");
		    	            
		    	            
		    	            sb.append("<div class=row>");
		    				sb.append("	<div class=\"col-md-4\">");
		    				sb.append("		<span class=\"label label-info\">Scrambling Parameters</span>");
		    				sb.append("	</div>");

		    				sb.append("	<div id=scramblePartialParsDiv class=\"col-md-8\">");
		    				sb.append(makeScramblePartialParameters(conn,session,mask_prof_id));
		    				sb.append("	</div>");
		    	            sb.append("</div>");
		    	            
		    	            
		    	            
		    	            
		                	
		                }

		                if (p_rule_id.equals("SCRAMBLE_DATE")) {
		            		//------------------
		    	            sb.append("<div class=row>");
		    				sb.append("	<div class=\"col-md-4\">");
		    				sb.append("		<span class=\"label label-info\">Date format (java)</span>");
		    				sb.append("	</div>");

		    				sb.append("	<div class=\"col-md-8\">");
		    				sb.append("<input type=text name=format value=\"" + nvl(p_format,"dd/MM/yyyy HH:mm:ss") + "\" size=20 maxlength=30 onchange=\"changeProfileField('format',this.value);\">");
		    				sb.append("	</div>");
		    	            sb.append("</div>");

		            		//------------------
		    	            sb.append("<div class=row>");
		    				sb.append("	<div class=\"col-md-4\">");
		    				sb.append("		<span class=\"label label-info\">Date change parameters</span>");
		    				sb.append("	</div>");

		    				String v_date_change_val=nvl(p_date_change_params,"day=0,month=0,year=0");
		    				String v_day="10";
		    				String v_month="6";
		    				String v_year="10";
		    				
		    				try {v_day=v_date_change_val.split(",")[0].split("=")[1];} catch(Exception e){}
		    				try {v_month=v_date_change_val.split(",")[1].split("=")[1];} catch(Exception e){}
		    				try {v_year=v_date_change_val.split(",")[2].split("=")[1];} catch(Exception e){}
		    				
		    				sb.append("	<div class=\"col-md-8\">");
		    				sb.append(" 	Day :   <input type=text id=date_change_params_day   value=\"" + v_day + "\"   size=3 maxlength=2 onchange=\"changeProfileField('date_change_params',this.value);\">");
		    				sb.append(" 	Month : <input type=text id=date_change_params_month value=\"" + v_month + "\" size=3 maxlength=2 onchange=\"changeProfileField('date_change_params',this.value);\">");
		    				sb.append(" 	Year :  <input type=text id=date_change_params_year  value=\"" + v_year + "\"  size=5 maxlength=3 onchange=\"changeProfileField('date_change_params',this.value);\">");
		    				sb.append("	</div>");
		    	            sb.append("</div>");

		                }
		                	
		                if (p_rule_id.equals("RANDOM_NUMBER") || p_rule_id.equals("RANDOM_STRING")) {
		            		//------------------
		    	            sb.append("<div class=row>");
		    				sb.append("	<div class=\"col-md-4\">");
		    				sb.append("		<span class=\"label label-info\">Random Range</span>");
		    				sb.append("	</div>");

		    				String v_random_range=nvl(p_random_range,"1,10");
		    				String v_start="1";
		    				String v_end="10";
		    				
		    				try {v_start=v_random_range.split(",")[0];} catch(Exception e) {}
		    				try {v_end=v_random_range.split(",")[1];} catch(Exception e) {}
		    				
		    				sb.append("	<div class=\"col-md-8\">");
		    				
		    				sb.append("Between ");
		    				sb.append("<br>");
		    				sb.append("<input type=text id=random_range_start value=\"" + v_start + "\" size=40 maxlength=30 onchange=\"changeProfileField('random_range',this.value);\">");
		    				sb.append("<br>");
		    				sb.append(" and ");
		    				sb.append("<br>");
		    				sb.append("<input type=text id=random_range_end value=\"" + v_end + "\" size=40 maxlength=30 onchange=\"changeProfileField('random_range',this.value);\">");
		    				sb.append("	</div>");
		    	            sb.append("</div>");
		                	
		                }

	            } //if (!nvl(par1,"0").equals("0"))
	            

            html=sb.toString();

			msg="ok";
			}			
			
			//**********************************************
			//change_profile_field
			//**********************************************
			if (action.equals("change_profile_field")) {
				String prof_id=par1;
				String field_name=par2;
				String new_val=par3;
				
				
				String countx="0";
				
				if (field_name.equals("short_code")) {
					sql="select count(*) from tdm_mask_prof where short_code=?  and id<>?";
					
					bindlist=new ArrayList<String[]>();
					bindlist.add(new String[]{"STRING", new_val});
					bindlist.add(new String[]{"INTEGER", prof_id});
					
					countx=getDbArrayConf(conn, sql, 1, bindlist).get(0)[0];
				}
				
				if (!countx.equals("0")) {
					html="javascript:myalert('There is another masking profile with same short code("+new_val+")');";
				}
				else
				{
					sql="update tdm_mask_prof set "+field_name+"=? where id=?";
					bindlist=new ArrayList<String[]>();
					
					if (field_name.equals("src_list_id") || field_name.equals("hide_after") )
						bindlist.add(new String[]{"INTEGER", new_val});
					else
						bindlist.add(new String[]{"STRING", new_val});
					
					bindlist.add(new String[]{"INTEGER", prof_id});
					log_trial(conn, "tdm_mask_prof", Integer.parseInt(prof_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
					
					execDBConf(conn, sql, bindlist);
					
					msg="ok";
					html="";
					
				}
				
			}
				

			//**********************************************
			//delete_profile
			//**********************************************
			if (action.equals("delete_profile")) {
				String mask_prof_id=par1;
			
				sql="select count(*) from tdm_fields where mask_prof_id="+mask_prof_id + " or condition_expr like '%MASK("+mask_prof_id+")%'";
				int ref_cnt=0;
				try{ref_cnt=Integer.parseInt(getDBSingleVal(conn, sql));} catch(Exception e) {ref_cnt=0;}
					
				if (ref_cnt==0) {
					bindlist.add(new String[]{"INTEGER", mask_prof_id});
				
					sql="delete from tdm_mask_prof where id=?";

					log_trial(conn, "tdm_mask_prof", Integer.parseInt(mask_prof_id), nvl((String) session.getAttribute("username"),"unknown"), "DELETE");
					execDBConf(conn, sql,bindlist);
					
					html="javascript:" + 
							"curr_mask_prof_id=-1;";
					
					msg="ok";
				}
				else {
					
					String profile_usage=getProfileUsage(conn,mask_prof_id);
					msg="nok:Cannot delete this profile since it is used in configurations. <hr>"+profile_usage;
					html="-";
				}
					
			}	
				
				
			//**********************************************
			//rename_profile
			//**********************************************
			if (action.equals("rename_profile")) {
				String profile_id=par1;
				String profile_name=par2;

				bindlist.add(new String[]{"STRING", profile_name});
				bindlist.add(new String[]{"INTEGER", profile_id});
				
				sql="select id from tdm_mask_prof where name=? and id<>?";
				ArrayList<String[]> checkArr=getDbArrayConf(conn, sql, 1, bindlist);
				if (checkArr.size()>0) {
					msg="nok:Cannot be renamed. There are another profile named with '"+profile_name+"'.";
				}
				else {
					sql="update tdm_mask_prof set name=? where id=?";
					
					log_trial(conn, "tdm_mask_prof", Integer.parseInt(profile_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
					execDBConf(conn, sql,bindlist);
					msg="ok";
				}
				
			}	

			//**********************************************
			//create_new_discovery
			//**********************************************
			if (action.equals("create_new_discovery")) {
				String app_id=par1;
				String env_id=par2;
				String schema_name=par3;
				String schedule_date=par4;
				
				String app_name=getDBSingleVal(conn, "select name from tdm_apps where id="+app_id);
				String env_name=getDBSingleVal(conn, "select name from tdm_envs where id="+env_id);

				sql="insert into tdm_work_plan "+
						"("+
						" work_plan_name, env_id, app_id, wplan_type,"+
						" target_owner_info, worker_limit, master_limit, "+
						" TASK_SIZE_PER_WORKER, created_by, start_date"+
						" ) "+
						" values ( " + 
						"?," + //work_plan_name
						"?," + //env_id
						"?," + //app_id
						"'DISC'," + //wplan_type
						"?," + //target_owner_info
						"999, 999 ,3," + //worker/master limits/TASK_SIZE_PER_WORKER
						"?," + //created_by
						"STR_TO_DATE(?,?) "+ //start_date		
						") " ;
				
				String work_plan_name="Discovery of "+app_name+" in " + env_name+"["+schema_name+"]";
				
				int user_id=(Integer) session.getAttribute("userid");
				
				bindlist=new ArrayList<String[]>();
				
				bindlist.add(new String[]{"STRING",work_plan_name});
				bindlist.add(new String[]{"INTEGER",env_id});
				bindlist.add(new String[]{"INTEGER",app_id});
				bindlist.add(new String[]{"STRING",schema_name});
				bindlist.add(new String[]{"INTEGER",""+user_id});
				bindlist.add(new String[]{"STRING",schedule_date});
				bindlist.add(new String[]{"STRING",mysql_format});
				
				
				execDBConf(conn, sql, bindlist);
				
				sql ="select max(id) id from tdm_work_plan where work_plan_name=?";
				bindlist=new ArrayList<String[]>();
				bindlist.add(new String[]{"STRING",work_plan_name });
				ArrayList<String[]> arrx=getDbArrayConf(conn, sql, 1, bindlist);
				
				String work_plan_id="";
				
				try{work_plan_id=arrx.get(0)[0];} catch(Exception e) {work_plan_id="0";}

				if (!work_plan_id.equals("0")) {
					
					msg="ok";
					html="javascript:openDiscoveryList()";
				}
					
				else {
					msg="nok:Work plan can not be placed.";
				}

			}

			
			
			//**********************************************
			//create_new_masking_discovery
			//**********************************************
			if (action.equals("create_new_masking_discovery")) {
				String discovery_type=par1;
				String app_id=par2;
				String env_id=par3;
				String schema_name=par4;
				String discovery_title=par5;
				String options=par6;
				
				String sample_count="100";
				String sector_id="0";
				
				String[] optsArr=options.split(":");
				
				try{sample_count=optsArr[0];} catch(Exception e) {sample_count="100";}
				try{sector_id=optsArr[1];} catch(Exception e) {sector_id="0";}
				
				
				
				String discovery_id=startNewDiscovery(conn,session,discovery_type, app_id, env_id, schema_name,discovery_title, sample_count, sector_id);  
				
				html="-";
				msg="ok:javascript:setActiveDiscoveryId('"+discovery_id+"')";
				
				
				if (discovery_id.equals("0")) 
					msg="ok:javascript:myalert('discovery is not started!')";


			}

			
			
			//**********************************************
			//show_discovery_copying_report
			//**********************************************
			if (action.equals("show_discovery_copying_report")) {
				
				int disc_id=Integer.parseInt(par1);
				int match_rate=Integer.parseInt(nvl(par2,"20"));
				String parent_table=nvl(par3,"");

				StringBuilder sb=discoveryCopyingPrint(conn, disc_id, match_rate,parent_table);
				
				html=sb.toString();
				session.setAttribute("last_discovery_report_content", html);
				
				msg="ok";
				
			}
			
			
			
			//**********************************************
			//set_jdbc_template
			//**********************************************
			if (action.equals("set_jdbc_template")) {
				
				String db_type=par1;
				
				sql="select flexval2 from  tdm_ref where ref_type='DB_TYPE' and ref_name='"+db_type+"'";
				String template=getDBSingleVal(conn, sql);
				
				if (template.contains("|")) {
					String jdbc_url_template=template.split("\\|")[1];
					html="javascript:document.getElementById(\"db_connstr\").value=\""+jdbc_url_template+"\"";
				}
				msg="ok";
				
			}
			//**********************************************
			//set_discovery_filter
			//**********************************************
			if (action.equals("set_discovery_filter")) {
				
				String discovery_rel_id=par1;
				String new_filter=par2;
				
				sql="update tdm_discovery_rel set rel_filter='"+new_filter+"' where id="+discovery_rel_id;
				execDBConf(conn, sql, new ArrayList<String[]>());
				msg="ok";
				
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
			//show_target_setter
			//**********************************************
			if (action.equals("show_target_setter")) {
				
				
				StringBuilder sb=new StringBuilder();
				
				
				html=sb.toString();
				
				msg="ok";
				
			}
			//**********************************************
			//show_table_add
			//**********************************************
			if (action.equals("show_table_add")) {
				String parent_tab_id=par1;
				String table_name=par2;
				String app_type=par3;
				String env_id=par4;
				String child_tab_id=par5;
				String family_id=par6;
				
				
				 
				html=drawChildTableDialog(conn, app_type, env_id, parent_tab_id,table_name,child_tab_id, "XXX", family_id);
			    
				msg="ok";
			}
			
			
			//**********************************************
			//test_sql_code
			//**********************************************
			if (action.equals("test_sql_code")) {
				String env_id=par1;
				String sql_to_test=par2;
				String param=par3;
				String sql_for=nvl(par4,"MASK");
				String tab_id=par5;
				
				if (sql_for.equals("CALC")) {
					sql="select concat(schema_name,'.',tab_name) from tdm_tabs where id="+tab_id;
					String table_name=getDBSingleVal(conn, sql);
					
					sql_to_test="select ("+sql_to_test+") test_field_xxx";
					
					sql="select field_name from tdm_fields where field_type<>'CALCULATED' and tab_id="+tab_id;
					ArrayList<String[]> fields=getDbArrayConf(conn, sql, Integer.MAX_VALUE, null);
					for (int i=0;i<fields.size();i++) {
						sql_to_test = sql_to_test + ", "+ fields.get(i)[0];
					}
					sql_to_test = sql_to_test +" from " + table_name + " m ";
					
				}
				
				
				boolean bind=false;
				if (sql_to_test.contains("=?") ||sql_to_test.contains("= ?"))
					bind=true;
				bindlist=new ArrayList<String[]>();
				if (bind)
					bindlist.add(new String[]{"STRING",param});
				
			    ArrayList<String[]> testArr=getDbArrayApp(conn, env_id, sql_to_test, 1, bindlist);
			    
			    
			    if (testArr.size()==0) {
			    	html="<font color=red>No record found or an error occured!</font>";
			    }
			    else
			    {
			    	
			    
			    	html="Returns  : <font color=green><big><big><b>"+testArr.get(0)[0]+"</b></big></big></font>";
			    }
			    
				msg="ok";
			}
			
			
			//**********************************************
			//show_dblist_dialog
			//**********************************************
			if (action.equals("show_dblist_dialog")) {
				String list_id=par1;
				String listsql=nvl( (String) session.getAttribute("ListSQL"),"");
				if (listsql.length()==0) {
					listsql=getDBSingleVal(conn, "select sql_statement from tdm_list where id="+list_id);
				}
				html=showDBListDialog(conn, listsql);
				
			    
				msg="ok";
			}
			
			//**********************************************
			//run_dblist_sql
			//**********************************************
			if (action.equals("run_dblist_sql")) {
						
				String listsql=par1;
				String env_id=par2;
				
				session.setAttribute("ListSQL", listsql);
				
				html=runListSQL(conn, listsql, env_id);
			    
				msg="ok";
			}
			
			
			//**********************************************
			//create_db_list
			//**********************************************
			if (action.equals("create_db_list")) {
						
				String listsql=nvl( (String) session.getAttribute("ListSQL"),"");
				String list_id=par1;
				String env_id=par2;
				int item_count=Integer.parseInt(par3);
				String is_distinct=par4;
				String selected_fields=par5;
							
				
				html="";
				
				log_trial(conn, "tdm_list", Integer.parseInt(list_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
				html=createDBListItems(conn, env_id, list_id, listsql, item_count, is_distinct,selected_fields);
			    
				msg="ok";
			}
			
			
			
			//**********************************************
			//list_conditional_fields
			//**********************************************
			if (action.equals("list_conditional_fields")) {
						
				String tab_id=par1;
				String field_id=par2;
				
				sql="select id, field_name from tdm_fields where tab_id="+tab_id + " and is_conditional='YES' and id<>"+field_id;
				html="<b>Select Field to copy from :</b>"+
					makeCombo(conn, sql, "copyFromFieldId", "id=copyFromFieldId", "", 500);
				    
				msg="ok";
			}
			
			//**********************************************
			//copy_condition_from_field
			//**********************************************
			if (action.equals("copy_condition_from_field")) {
						
				String tab_id=par1;
				String source_field_id=par2;
				String target_field_id=par3;
				
				String source_condition=getDBSingleVal(conn, "select condition_expr from tdm_fields where id="+source_field_id);
				
				sql="update tdm_fields set condition_expr=? where id=?";
				bindlist=new ArrayList<String[]>();
				bindlist.add(new String[]{"STRING",source_condition});
				bindlist.add(new String[]{"INTEGER",target_field_id});
				log_trial(conn, "tdm_fields", Integer.parseInt(target_field_id), nvl((String) session.getAttribute("username"),"unknown"), "UPDATE");
				execDBConf(conn, sql, bindlist);
				
				html="";
				
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
			//add_new_calculated_field
			//**********************************************
			if (action.equals("add_new_calculated_field")) {
			
				String tab_id=par1;
				String new_field_name=par2;
				
				boolean field_already_exists=true;
				
				do {
					sql="select count(*) from tdm_fields where tab_id="+tab_id+" and field_name=?";
					bindlist.clear();
					bindlist.add(new String[]{"STRING",new_field_name});
					
					int cnt=0;
					try {cnt=Integer.parseInt(getDbArrayConf(conn, sql, 1, bindlist).get(0)[0]);} catch(Exception e) {e.printStackTrace();}
				
					if (cnt==0) field_already_exists=false;
					else new_field_name=new_field_name+"2";
					
				} while(field_already_exists);
				
				new_field_name=new_field_name.toLowerCase();
				
				sql="insert into tdm_fields (tab_id, field_name, field_type, field_size, is_pk, mask_prof_id, calc_prof_id) "+
					" values ("+tab_id+",?,'CALCULATED',0,'NO',0,0)";
				execDBConf(conn, sql, bindlist);
				
				msg="ok";
			}
			
			//**********************************************
			//open_copy_table_dlg
			//**********************************************
			if (action.equals("open_copy_table_dlg")) {
				String target_app_id=par1;
				
				html=createCopyAppDlg(conn,target_app_id);
				msg="ok";
			}
			
			
			//**********************************************
			//fill_copy_table_list
			//**********************************************
			if (action.equals("fill_copy_table_list")) {
				String source_app_id=par1;
				
				html=fillCopyTableList(conn,source_app_id);
				msg="ok";
			}
			
			
			
			//**********************************************
			//copy_table_to_app
			//**********************************************
			if (action.equals("copy_table_to_app")) {
				String target_app_id=par1;
				String copy_table_ids=par2;
				
				copyTablesToApp(conn,target_app_id, copy_table_ids);
				html="";
				msg="ok";
			}
			//**********************************************
			//copy_filter_table_dialog
			//**********************************************
			if (action.equals("copy_filter_table_dialog")) {
				String app_id=par1;
				
				html=filterTableDlg(conn,app_id);
				msg="ok";
			}
			//**********************************************
			//open_bulk_config_dlg
			//**********************************************
			if (action.equals("open_bulk_config_dlg")) {
				String target_app_id=par1;
				String target_env_id=par2;
				
				html=makeBulkConfigDlg(conn, session,target_app_id, target_env_id); 
				msg="ok";
			}
			
			//**********************************************
			//test_or_import_bulk_config
			//**********************************************
			if (action.equals("test_or_import_bulk_config")) {
				String target_app_id=par1;
				String target_env_id=par2;
				String bulk_config_memo=decrypt(par3);
				String to_perform=par4;
				
				html=testOrImportBulkConfig(conn, session,target_app_id, target_env_id, bulk_config_memo, to_perform); 
				
				if (to_perform.equals("YES"))
					msg="ok:javascript:fillAppTabList();myalert('Import finished.')";
				else 
					msg="ok:javascript:fillAppTabList();";
			}
			
		
			
			//**********************************************
			//depended_applicatons_dialog
			//**********************************************
			if (action.equals("depended_applicatons_dialog")) {
				String app_id=par1;
				
				html=dependedAppsDlg(conn,session, app_id);
				msg="ok";
			}
			
			//**********************************************
			//db_scripts_dialog
			//**********************************************
			if (action.equals("db_scripts_dialog")) {
				String app_id=par1;
				String stage=par2;
				
				html=dbScriptDlg(conn,session, app_id, stage);
				msg="ok";
			}
			
			//**********************************************
			//make_checklist_dialog
			//**********************************************
			if (action.equals("make_checklist_dialog")) {
				String app_id=par1;
				
				html=checkListDlg(conn,app_id);
				msg="ok";
			}
			
		
			
			//**********************************************
			//check_copy_app_problems
			//**********************************************
			if (action.equals("check_copy_app_problems")) {
				String app_id=par1;
				String db_id=par2;

				html=checkProblems(conn,session,app_id, db_id); 
				msg="ok";
			}
			
			//**********************************************
			//make_application_list
			//**********************************************
			if (action.equals("make_application_list")) {
				
				String dis_wp_id=par1;
				String disc_id=par2;
				String table_name=par3;
				String disc_env_id=par4;
				String disc_app_id=par5;
				
				html=makeApplicationList(conn,dis_wp_id, disc_id, table_name, disc_env_id, disc_app_id);
				msg="ok";
			}
			
			//**********************************************
			//add_new_table_filter
			//**********************************************
			if (action.equals("add_new_table_filter")) {
				String app_id=par1;
				String tab_id=par2;
				
				filterTableAddNew(conn,app_id,tab_id);
				html="";
				msg="ok:javascript:openFilterTableDlg()";
			}
			
			//**********************************************
			//delete_table_filter
			//**********************************************
			if (action.equals("delete_table_filter")) {
				String filter_id=par1;
				
				
				
				filterTableDelete(conn,filter_id);
				html="";
				msg="ok:javascript:openFilterTableDlg()";
			}
			
			//**********************************************
			//change_copy_filter
			//**********************************************
			if (action.equals("change_copy_filter")) {
				String app_id=par1;
				String env_id=par2;
				String filter_id=par3;
								
				html=getCopyFilter(conn, app_id, env_id, filter_id);
				msg="ok";
			}
			

	
			//**********************************************
			//change_table_filter
			//**********************************************
			if (action.equals("change_table_filter")) {
				String filter_id=par1;
				String filter_name=par2;
				String filter_type=par3;
				String filter_sql=par4;
				
				
				String[] arr=par5.split("::::");
				
				
				String format_1="";
				String format_2="";
				String list_id_1="0";
				String list_id_2="0";
				String list_source_1="STATIC";
				String list_source_2="STATIC";
				
				try {format_1=arr[0];if (format_1.equals("-")) format_1="";} catch(Exception e) {e.printStackTrace();}
				try {format_2=arr[1];if (format_2.equals("-")) format_2="";} catch(Exception e) {e.printStackTrace();}
				try {list_id_1=arr[2];if (list_id_1.equals("-")) list_id_1="0";} catch(Exception e) {e.printStackTrace();}
				try {list_id_2=arr[3];if (list_id_2.equals("-")) list_id_2="0";} catch(Exception e) {e.printStackTrace();}
				
				list_source_1=arr[4];
				list_source_2=arr[5];
				
				
				 
				filterTableChange(conn,filter_id, filter_name, filter_type, filter_sql, format_1, format_2, list_id_1, list_id_2, list_source_1, list_source_2);
				html="";
				msg="ok:javascript:openFilterTableDlg()";
			}


			//**********************************************
			//change_mask_level
			//**********************************************
			if (action.equals("change_mask_level")) {
				String tab_id=par1;
				String mask_level=par2;
				
				
				
				changeMaskLevel(conn, tab_id,mask_level);
				html="";
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
			//load_configuration_menu
			//**********************************************
			if (action.equals("load_configuration_menu")) {
				
				html=loadConfigurationMenu(conn,session);
				msg="ok:javascript:makeMadUserList()";			 
				
			}
			
			//**********************************************
			//show_lov_dialog
			//**********************************************
			if (action.equals("show_lov_dialog")) {
				String lov_title=par1;
				String lov_type=par2;
				String lov_for_id=par3;
				String curr_value=par4;
				String fireEvent=par5;
				
				html=makeLov(conn,session,lov_title,lov_type, lov_for_id, curr_value, fireEvent);
				msg="ok";			
				
			}
			
			//**********************************************
			//set_lov_filter
			//**********************************************
			if (action.equals("set_lov_filter")) {
				
				String lov_type=par1;
				String curr_value=par2;
				String filter_value=par3;
				
				if (filter_value.trim().equals("${null}")) filter_value="";
				
				
				
				html=setLovFilter(conn,session,lov_type,curr_value, filter_value);
				msg="ok";			
				
				
				
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
			//add_new_sector
			//**********************************************
			if (action.equals("add_new_sector")) {
				String sector_name=par1;
				 
				int res=addNewSector(conn,session,sector_name);
				if (res<0) { 
					if (res==-1) {
						html="-";
						msg="nok:there is already a sector named :  ("+sector_name+")";
					}
					if (res==-2) {
						html="-";
						msg="nok:sector cannot be added.";
					}
				}
				else {
					html="-";
					msg="ok:javascript:makeSectorList()";
				}
							
				
			}

			//**********************************************
			//make_mad_user_list
			//**********************************************
			if (action.equals("make_mad_user_list")) {
				html=makeMadUserList(conn, session);
				msg="ok";
			}
			
			//**********************************************
			//make_sector_list
			//**********************************************
			if (action.equals("make_sector_list")) {
				html=makeSectorList(conn, session); 
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
			//make_sector_editor
			//**********************************************
			if (action.equals("make_sector_editor")) {
				String sector_id=par1;
				
				html=makeSectorEditor(conn, session, sector_id);
				msg="ok";
			}

			//**********************************************
			//make_database_editor
			//**********************************************
			if (action.equals("make_database_editor")) {
				String database_id=par1;
				
				html=makeDatabaseEditor(conn, application, session, database_id);
				msg="ok";
			}
			
			//**********************************************
			//make_policy_group_editor
			//**********************************************
			if (action.equals("make_policy_group_editor")) {
				String policy_group_id=par1;
				
				html=makePolicyGroupEditor(conn, session, policy_group_id);
				msg="ok";
			}
			//**********************************************
			//make_calendar_editor
			//**********************************************
			if (action.equals("make_calendar_editor")) {
				String calendar_id=par1;
				
				html=makeCalendarEditor(conn, session, calendar_id);
				msg="ok";
			}
			//**********************************************
			//make_session_validation_editor
			//**********************************************
			if (action.equals("make_session_validation_editor")) {
				String session_validation_id=par1;
				
				html=makeSessionValidationEditor(conn, session, session_validation_id);
				msg="ok";
			}
			//**********************************************
			//make_monitoring_editor
			//**********************************************
			if (action.equals("make_monitoring_editor")) {
				String monitoring_id=par1;
				
				html=makeMonitoringEditor(conn, session, monitoring_id);
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
			//make_environment_list
			//**********************************************
			if (action.equals("make_environment_list")) {
				html=makeEnvironmentList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_policy_group_list
			//**********************************************
			if (action.equals("make_policy_group_list")) {
				html=makePolicyGroupList(conn, session);
				msg="ok";
			}
			//**********************************************
			//make_calendar_list
			//**********************************************
			if (action.equals("make_calendar_list")) {
				html=makeCalendarList(conn, session); 
				msg="ok";
			}
			//**********************************************
			//make_session_validation_list
			//**********************************************
			if (action.equals("make_session_validation_list")) {
				html=makeSessionValidationList(conn, session); 
				msg="ok";
			}
			//**********************************************
			//make_monitoring_list
			//**********************************************
			if (action.equals("make_monitoring_list")) {
				html=makeMonitoringList(conn, session);  
				msg="ok";
			}
			//**********************************************
			//make_calendar_exception_list
			//**********************************************
			if (action.equals("make_calendar_exception_list")) {
				String calendar_id=par1;
				html=makeCalendarExceptionList(conn, session, calendar_id); 
				msg="ok";
			}
			//**********************************************
			//make_database_list
			//**********************************************
			if (action.equals("make_database_list")) {
				html=makeDatabaseList(conn, application, session);  
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
			//update_sector_field
			//**********************************************
			if (action.equals("update_sector_field")) {
				String sector_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_discovery_sector",sector_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}


			//**********************************************
			//delete_mad_user
			//**********************************************
			if (action.equals("delete_mad_user")) {
				String deleted_user_id=par1;
				 
				deleteMadUser(conn,session,deleted_user_id);
				html="-";
				msg="ok:javascript:makeMadUserList()";			
				
			}
			
			//**********************************************
			//delete_sector
			//**********************************************
			if (action.equals("delete_sector")) {
				String sector_id=par1;
				 
				deleteSector(conn,session,sector_id);
				html="-";
				msg="ok:javascript:makeSectorList()";			
				
			}
			//**********************************************
			//add_mad_group
			//**********************************************
			if (action.equals("add_mad_group")) {
				String group_name=par1;
				 
				int res=addNewMadGroup(conn,session,group_name); 
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
			//add_remove_sector_rule
			//**********************************************
			if (action.equals("add_remove_sector_rule")) {
				String sector_id=par1;
				String action_and_id=par2;
				String addremove="ADD";
				String rule_id="0";
				try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
				try {rule_id=action_and_id.split(":")[1];} catch(Exception e){}
				 
				addRemoveSectorRule(conn,session,sector_id,addremove,rule_id);  
				
				html="-";
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
			//draw_monitoring_areas
			//**********************************************
			if (action.equals("draw_monitoring_areas")) {
								
				html=drawMonitoringAreas(conn, application, session);
				msg="ok:javascript:setRefreshInterval('WORK_PLAN_LIST')";
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
				msg="ok:javascript:drawMonitoringGraphs(); makeWorkPlanList(); ";
				
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

				html=printLongDet2(conn, wplan_type, env_id,work_plan_id,rec_type,field);
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
			//make_work_package_assignment_list
			//**********************************************
			if (action.equals("make_work_package_assignment_list")) {
				
				String work_package_id=par1;			

				html=makeWorkPackageAssignmentList(conn, session, work_package_id);
				msg="ok";
			}
			
			//**********************************************
			//assign_work_package
			//**********************************************
			if (action.equals("assign_work_package")) {
				
				String work_package_id=par1;	
				String master_id=par2;			
				boolean is_ok=assignWorkPackage(conn, session, work_package_id, master_id);
				html="-";
				msg="nok:Work package is assigned to master " + master_id;
				
				if (!is_ok)
					msg="nok:Work package cannot be assigned";
				
			}
			
			//**********************************************
			//make_table_config_menu
			//**********************************************
			if (action.equals("make_table_config_menu")) {
				String tab_id=par1;
				
				html=makeTableConfig(conn,session,tab_id);
				msg="ok";
			}
			
			//**********************************************
			//save_table_config
			//**********************************************
			if (action.equals("save_table_config")) {
				String tab_id=par1;
				String skip_options=par2;
				
				String hint_options=par3;
				
				String hint_after_select="";
				String hint_before_table="";
				String hint_after_table="";
				
				try {
					String[] arr=hint_options.split("\\|::\\|");
					hint_after_select=arr[0];
					hint_before_table=arr[1];
					hint_after_table=arr[2];
				} catch(Exception e) {
					e.printStackTrace();
				}
				
				
				
				String skip_drop_index="NO";
				String skip_drop_constraint="NO";
				String skip_drop_trigger="NO";
				
				try {
					String[] arr=skip_options.split(":");
					skip_drop_index=arr[0];
					skip_drop_constraint=arr[1];
					skip_drop_trigger=arr[2];
				} catch(Exception e) {
					e.printStackTrace();
				}
				
				String check_existence_action=par4;
				String check_existence_sql=par5;
				String check_existence_on_fields=par6;
				
				saveTableConfig(conn,session,tab_id, 
						skip_drop_index, 
						skip_drop_constraint, 
						skip_drop_trigger, 
						hint_after_select, 
						hint_before_table,
						hint_after_table,
						check_existence_action, 
						check_existence_sql,
						check_existence_on_fields);
				
				html="-";
				msg="ok:javascript:myalert('Configuration Saved')";
			}
			
			//**********************************************
			//start_new_discovery_window
			//**********************************************
			if (action.equals("start_new_discovery_window")) {
				String disc_type=par1;
				html=startNewDiscoveryWindow(conn,session,disc_type);
				msg="ok";
			}
			
			//**********************************************
			//fill_discovery_catalog_list
			//**********************************************
			if (action.equals("fill_discovery_catalog_list")) {
				String disc_env_id=par1;
				
				
				html=fillDiscoveryCatalogList(conn,session,disc_env_id);
				msg="ok";
			}
			//**********************************************
			//fill_discovery_schema_list
			//**********************************************
			if (action.equals("fill_discovery_schema_list")) {
				String disc_env_id=par1;
				String disc_catalog_filter=par2;
				
				
				html=fillDiscoverySchemaList(conn,session,disc_env_id, disc_catalog_filter); 
				msg="ok";
			}
			
			//**********************************************
			//open_discovery_list
			//**********************************************
			if (action.equals("open_discovery_list")) {
				
				html=makeDiscoveryList(conn,session);
				msg="ok:javascript:loadDiscoveryReport()";
			}
			
			//**********************************************
			//set_active_discovery_id
			//**********************************************
			if (action.equals("set_active_discovery_id")) {
				String discovery_id=par1;
				setActiveDiscoveryId(conn,session,discovery_id);
				html="-";
				msg="ok:javascript:ondiscoveryload()";
			}
			
			//**********************************************
			//load_discovery_left
			//**********************************************
			if (action.equals("load_discovery_left")) {
				html=loadDiscoveryLeft(conn,session);
				msg="ok:javascript:loadDiscoveryReport()";
			}
			
			//**********************************************
			//load_discovery_report
			//**********************************************
			if (action.equals("load_discovery_report")) {
				
				String active_discovery_id=nvl((String) session.getAttribute("active_discovery_id"),"0");
				

				String include_discarded=par1;
				String group_by=par2;
				String filter_catalog=par3;
				String filter_owner=par4;
				String filter_category=par5;
				String more_filter=par6;
				
				String[] arr=more_filter.split(":");
				
				String match_rate=arr[0];
				String filter_table="";
				String filter_column="";
				String comparing_discovery_id="";
				
				filter_table=arr[1];
				filter_column=arr[2];
				comparing_discovery_id=arr[3];
				
				if (filter_table.equals("${null}")) filter_table="";
				if (filter_column.equals("${null}")) filter_column="";
				if (comparing_discovery_id.equals("${null}")) comparing_discovery_id="";
				
				html=loadDiscoveryReport(conn,session,
						active_discovery_id,
						include_discarded,
						group_by,
						filter_catalog,
						filter_owner,
						filter_category,
						match_rate,
						filter_table,
						filter_column,
						comparing_discovery_id
						);
				msg="ok";
			}
			
			//**********************************************
			//write_masking_report
			//**********************************************
			if (action.equals("write_masking_report")) { 
				
				String discovery_id=par1;
				String report_type=par2;
				String rep="";
						
				html="-";
				
			        
			  String rep_name=generateMaskDiscoveryReportContent(conn, discovery_id, report_type);
			    				    
			  if (rep_name.length()==0) 
				  msg="nok:file not generated.";
			  else				
			  	  msg="ok:javascript:downloadMaskingDiscoveryReport('"+rep_name+"')";
			
			}
			//**********************************************
			//export_masking_configuration
			//**********************************************
			if (action.equals("export_masking_configuration")) { 
				
				String export_app_id=par1;
				
						
				html="-";
				
			        
			  String rep_name=exportMaskingConfiguration(conn, export_app_id);
			    				    
			  if (rep_name.length()==0) 
				  msg="nok:file not generated.";
			  else				
			  	  msg="ok:javascript:downloadMaskingExportedFile('"+rep_name+"')";
			
			}
			

			//**********************************************
			//load_copy_app_params
			//**********************************************
			if (action.equals("load_copy_app_params")) {
				String app_id=par1;
				
				
				
				html=loadCopyAppParams(conn,session,app_id);
				msg="ok:javascript:setCopyWorkPlanName()";
				
			
			}
			
			//**********************************************
			//list_my_copy_tasks
			//**********************************************
			if (action.equals("list_my_copy_tasks")) {
				
				String filter_options=par1;
				
				html=listMyCopyTasks(conn, session,filter_options); 
				msg="ok";
			
			}
			
			//**********************************************
			//fill_copy_filter_vals
			//**********************************************
			if (action.equals("fill_copy_filter_vals")) {
				String app_id=par1;
				String filter_id=par2;
				String source_env_id=par3;
				String target_env_id=par4;
				String filter_value=par5;
				
			
				
				html=fillCopyFilterVals(conn,session,app_id,filter_id, source_env_id, target_env_id, filter_value);
				msg="ok:javascript:setCopyWorkPlanName(); fillTargetInfo('"+app_id+"'); ";
				if (!div.equals("copyFilterValsDiv"))  
					msg="ok";

			}
			
			//**********************************************
			//save_prerequisite_application_filter_value
			//**********************************************
			if (action.equals("save_prerequisite_application_filter_value")) {
				String apps_rel_id=par1;
				String filter_value=par2;
				
				savePrereqAppFilterValues(conn,session,apps_rel_id, filter_value); 
				
				html="-";
				msg="ok:javascript:myalert('Filter Parameters Saved')";
			
			}
			
			
			//**********************************************
			//fill_target_info
			//**********************************************
			if (action.equals("fill_target_info")) {
				String app_id=par1;
				String source_id=par2;
				String target_id=par3;
				String condition_tab_id=par4;
				
				
				html=fillTargetInfo(conn,session,app_id,source_id, target_id,condition_tab_id);
				msg="ok:javascript:setCopyWorkPlanName()";
			
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
			//update_group_field
			//**********************************************
			if (action.equals("update_group_field")) {
				String group_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_group",group_id, field_name, field_value);
				html="-";
				msg="ok";			
				
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
			//update_copy_checklist_field
			//**********************************************
			if (action.equals("update_copy_checklist_field")) {
				String checklist_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_copy_app_checklist",checklist_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_policy_group_field
			//**********************************************
			if (action.equals("update_policy_group_field")) {
				String policy_group_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_proxy_policy_group",policy_group_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//update_calendar_field
			//**********************************************
			if (action.equals("update_calendar_field")) {
				String calendar_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_proxy_calendar",calendar_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_session_validation_field
			//**********************************************
			if (action.equals("update_session_validation_field")) {
				String session_validation_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_proxy_session_validation",session_validation_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_monitoring_field
			//**********************************************
			if (action.equals("update_monitoring_field")) {
				String monitoring_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_proxy_monitoring",monitoring_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_monitoring_rule_field
			//**********************************************
			if (action.equals("update_monitoring_rule_field")) {
				String monitoring_id=par1;
				String monitoring_rule_id=par2;
				String field_name=par3;
				String field_value=par4; 
				 
				updateMadTableField(conn,session,"tdm_proxy_monitoring_policy_rules",monitoring_rule_id, field_name, field_value);
				html="-";
				if (field_name.equals("is_active"))
					msg="ok:javascript:makeMonitoringColumnsEditor('"+monitoring_id+"'); makeMonitoringExpressionsEditor('"+monitoring_id+"')";
				else 
					msg="ok";			
				
			}
			//**********************************************
			//add_new_monitoring_rule
			//**********************************************
			if (action.equals("add_new_monitoring_rule")) {
				String monitoring_id=par1;
				String rule_type=par2;

				addNewMonitoringRule(conn,session,monitoring_id,rule_type);
				html="-";
				if (rule_type.equals("COLUMN"))
					msg="ok:javascript:makeMonitoringColumnsEditor('"+monitoring_id+"')";		
				else 
					msg="ok:javascript:makeMonitoringExpressionsEditor('"+monitoring_id+"')";
			}
	
			//**********************************************
			//remove_monitoring_rule
			//**********************************************
			if (action.equals("remove_monitoring_rule")) {
				String monitoring_id=par1;
				String monitoring_rule_id=par2;
				String rule_type=par3;

				removeMonitoringRule(conn,session,monitoring_rule_id);  
				html="-";
				
				if (rule_type.equals("COLUMN"))
					msg="ok:javascript:makeMonitoringColumnsEditor('"+monitoring_id+"')";	
				else 
					msg="ok:javascript:makeMonitoringExpressionsEditor('"+monitoring_id+"')";	
			}
			//**********************************************
			//update_calendar_exception_field
			//**********************************************
			if (action.equals("update_calendar_exception_field")) {
				String calendar_exception_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_proxy_calendar_exception",calendar_exception_id, field_name, field_value); 
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_calendar_exception_date
			//**********************************************
			if (action.equals("update_calendar_exception_date")) {
				String calendar_exception_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateCalendarExceptionDate(conn,session,calendar_exception_id, field_name, field_value); 
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_log_exception_field
			//**********************************************
			if (action.equals("update_log_exception_field")) {
				String exception_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_proxy_log_exception",exception_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//update_statement_exception_field
			//**********************************************
			if (action.equals("update_statement_exception_field")) {
				String exception_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_proxy_statement_exception",exception_id, field_name, field_value);
				html="-";
				msg="ok";			
				
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
							
				addRemoveGroupMember(conn,session,group_id,addremove,member_id); 
				
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//add_remove_group_environment
			//**********************************************
			if (action.equals("add_remove_group_environment")) {
				String group_id=par1;
				String action_and_id=par2;
				String addremove="ADD";
				String environment_id="0";
				try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
				try {environment_id=action_and_id.split(":")[1];} catch(Exception e){}
				String env_type=par3;
				
				addRemoveGroupEnvironment(conn,session,group_id,addremove,environment_id, env_type); 
				
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//add_remove_group_application
			//**********************************************
			if (action.equals("add_remove_group_application")) {
				String group_id=par1;
				String action_and_id=par2;
				String addremove="ADD";
				String application_id="0";
				try {addremove=action_and_id.split(":")[0];} catch(Exception e){}
				try {application_id=action_and_id.split(":")[1];} catch(Exception e){}
				
				addRemoveGroupCopyApplication(conn,session,group_id,addremove,application_id); 
				
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
			//change_copy_ref_table
			//**********************************************
			if (action.equals("change_copy_ref_table")) {
				String field_id=par1;
				String curr_copy_ref_tab_id=par2;
				
				changeCopyRefTable(conn,session,field_id,curr_copy_ref_tab_id); 

				html="-";
				msg="ok:javascript:makeCopyFieldNameCombo('"+field_id+"','"+curr_copy_ref_tab_id+"'); ";			
				
			}
			
			//**********************************************
			//make_copy_field_name_combo
			//**********************************************
			if (action.equals("make_copy_field_name_combo")) {
				String field_id=par1;
				String copy_ref_tab_id=par2;

				
				
				html=makeCopyFieldNameCombo(conn,field_id,copy_ref_tab_id); 
				msg="ok";			
				
			}
			
			
			//**********************************************
			//change_copy_ref_table
			//**********************************************
			if (action.equals("change_copy_ref_field_name")) {
				String field_id=par1;
				String curr_copy_ref_field_name=par2;
				
				changeCopyRefFieldName(conn,session,field_id,curr_copy_ref_field_name); 

				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//add_table_need
			//**********************************************
			if (action.equals("add_table_need")) {
				String tabid=par1;
				String need_id="0";

				html=makeTableNeedForm(conn, session, tabid, need_id); 
				msg="ok";			
				
			}
			
			//**********************************************
			//edit_table_need
			//**********************************************
			if (action.equals("edit_table_need")) {
				String tabid=par1;
				String need_id=par2;

				html=makeTableNeedForm(conn, session, tabid, need_id); 
				msg="ok";			
				
			}
			
			//**********************************************
			//remove_table_need
			//**********************************************
			if (action.equals("remove_table_need")) {
				String tabid=par1;
				String need_id=par2;
				
				removeTableNeed(conn, session, need_id); 
				html="-";
				msg="ok:javascript:loadTabNeedList("+tabid+");";			
				
			}
			
			//**********************************************
			//load_table_need_list
			//**********************************************
			if (action.equals("load_table_need_list")) {
				String tabid=par1;

				html=makeTableNeedList(conn, tabid, false); 
				msg="ok:javascript:fillAppTabList()";			
				
			}
			
			//**********************************************
			//save_need
			//**********************************************
			if (action.equals("save_need")) {
				String need_id=par1;
				String need_tab_id=par2;
				String need_app_id=par3;
				String need_filter_id=par4;
				String need_rel_on_fields=par5;
				
				String field_id=saveNeed(conn, need_id, need_tab_id, need_app_id, need_filter_id, need_rel_on_fields);
				System.out.println("field_id.:"+field_id);
				
				html="-";
				if (field_id.length()>0) {
					msg="ok:javascript:fillFieldDetails('"+field_id+"'); loadTabNeedList("+need_tab_id+"); ";	
				}
				else 
				{
					msg="ok:javascript:loadTabNeedList("+need_tab_id+");";	
				}
				
					
				
			}

			//**********************************************
			//load_need_filter_list
			//**********************************************
			if (action.equals("load_need_filter_list")) {
				String need_app_id=par1;

				html=makeNeedFilterList(conn, session, nvl(need_app_id,"0"), "0");
				msg="ok";			
				
			}
			
			
			//**********************************************
			//remove_database
			//**********************************************
			if (action.equals("remove_database")) {
				String target_id=par1;

				boolean is_ok=removeDatabase(conn,session,target_id); 
				
				if (is_ok) {
					html="-"; 
					msg="ok:javascript:makeDatabaseList()";		
				} else {
					html="-"; 
					msg="nok:Database is used or can't be removed.";	
				}
					
				
			}
			
			//**********************************************
			//remove_database
			//**********************************************
			if (action.equals("remove_policy_group")) {
				String policy_group_id=par1;

				boolean is_ok=removePolicyGroup(conn,session,policy_group_id); 
				
				if (is_ok) {
					html="-"; 
					msg="ok:javascript:makePolicyGroupList()";		
				} else {
					html="-"; 
					msg="nok:Policy Group is used or can't be removed.";	
				}
					
				
			}
			
			//**********************************************
			//remove_calendar
			//**********************************************
			if (action.equals("remove_calendar")) {
				String calendar_id=par1;

				boolean is_ok=removeCalendar(conn,session,calendar_id);  
				
				if (is_ok) {
					html="-"; 
					msg="ok:javascript:makeCalendarList()";		
				} else {
					html="-"; 
					msg="nok:Calendar is used or can't be removed.";	
				}
					
				
			}
			//**********************************************
			//remove_session_validation
			//**********************************************
			if (action.equals("remove_session_validation")) {
				String session_validation_id=par1;

				boolean is_ok=removeSessionValidation(conn,session,session_validation_id);  
				
				if (is_ok) {
					html="-"; 
					msg="ok:javascript:makeSessionValidationList()";		
				} else {
					html="-"; 
					msg="nok:Session validation is used or can't be removed.";	
				}
					
				
			}
			//**********************************************
			//remove_monitoring
			//**********************************************
			if (action.equals("remove_monitoring")) {
				String monioring_id=par1;

				boolean is_ok=removeMonitoring(conn,session,monioring_id); 
				
				if (is_ok) {
					html="-"; 
					msg="ok:javascript:makeMonitoringList()";		
				} else {
					html="-"; 
					msg="nok:Monitoring is used or can't be removed.";	
				}
					
				
			}
			//**********************************************
			//remove_calendar_exception
			//**********************************************
			if (action.equals("remove_calendar_exception")) {
				String calendar_id=par1;
				String calendar_exception_id=par2;
 
				removeCalendarException(conn,session,calendar_exception_id);  
				
				html="-"; 
				msg="ok:javascript:makeCalendarExceptionList('"+calendar_id+"')";	
					
				
			}
			//**********************************************
			//remove_target
			//**********************************************
			if (action.equals("remove_target")) {
				String target_id=par1;

				boolean is_ok=removeTarget(conn,session,target_id);

				
				if (is_ok) {
					html="-"; 
					msg="ok:javascript:makeEnvironmentList()";		
				} else {
					html="-"; 
					msg="nok:Target is used or can't be removed.";	
				}
				
					
				
			}
			
			//**********************************************
			//remove_family
			//**********************************************
			if (action.equals("remove_family")) {
				String family_id=par1;

				boolean is_ok=removeFamily(conn,session,family_id);
				

				
				if (is_ok) {
					html="-"; 
					msg="ok:javascript:makeEnvironmentList()";		
				} else {
					html="-"; 
					msg="nok:Family is used or can't be removed.";	
				}
				
				
						
				
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
			//add_policy_group
			//**********************************************
			if (action.equals("add_policy_group")) {
				String policy_group_name=par1;

				addPolicyGroup(conn,session,policy_group_name);
				
				html="-";
				msg="ok:javascript:makePolicyGroupList()";			
				
			}
			//**********************************************
			//add_new_session_validation
			//**********************************************
			if (action.equals("add_new_session_validation")) {
				String session_validation_name=par1;

				addNewSessionValidation(conn,session,session_validation_name); 
				
				html="-";
				msg="ok:javascript:makeSessionValidationList()";			
				
			}
			//**********************************************
			//add_new_monitoring
			//**********************************************
			if (action.equals("add_new_monitoring")) {
				String monitoring_name=par1;

				addNewMonitoring(conn,session,monitoring_name); 
				
				html="-";
				msg="ok:javascript:makeMonitoringList()";			
				
			}
			//**********************************************
			//add_new_calendar
			//**********************************************
			if (action.equals("add_new_calendar")) {
				String calendar_name=par1;

				addCalendar(conn,session,calendar_name);
				
				html="-";
				msg="ok:javascript:makeCalendarList()";			
				
			}
			//**********************************************
			//add_new_calendar_exception
			//**********************************************
			if (action.equals("add_new_calendar_exception")) {
				String calendar_id=par1;

				addCalendarException(conn,session,calendar_id);
				
				html="-";
				msg="ok:javascript:makeCalendarExceptionList('"+calendar_id+"')";			
				
			}
			//**********************************************
			//add_target
			//**********************************************
			if (action.equals("add_target")) {
				String target_name=par1;

				addTarget(conn,session,target_name);
				
				html="-";
				msg="ok:javascript:makeEnvironmentList()";			
				
			}
			
			//**********************************************
			//add_family
			//**********************************************
			if (action.equals("add_family")) {
				String family_name=par1;

				addFamily(conn,session,family_name); 
				
				html="-";
				msg="ok:javascript:makeEnvironmentList()";			
				
			}
			
			//**********************************************
			//rename_target
			//**********************************************
			if (action.equals("rename_target")) {
				
				String target_id=par1;
				String target_name=par2;
				
				renameTarget(conn,session,target_id, target_name);
				
				html="-";
				msg="ok:javascript:makeEnvironmentList()";			
				
			}
			
			
			//**********************************************
			//rename_family
			//**********************************************
			if (action.equals("rename_family")) {
				
				String family_id=par1;
				String family_name=par2;
				
				renameFamily(conn,session,family_id, family_name);
				
				html="-";
				msg="ok:javascript:makeEnvironmentList()";			
				
			}
			
			//**********************************************
			//remove_target_family_db
			//**********************************************
			if (action.equals("remove_target_family_db")) {
				
				String target_id=par1;
				String family_id=par2;
				
				removeTargetFamilyDb(conn,session,target_id, family_id); 
				
				html="-";
				msg="ok:javascript:makeEnvironmentList()";			
				
			}
			//**********************************************
			//set_recursive_fields
			//**********************************************
			if (action.equals("set_recursive_fields")) {
				
				String tab_id=par1;
				String recursive_fields=par2;
				
				setRecursiveFields(conn,session,tab_id, recursive_fields); 
				
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//set_target_family_db
			//**********************************************
			if (action.equals("set_target_family_db")) {
				
				String target_id=par1;
				String family_id=par2; 
				String env_id=par3;
				
				setTargetFamilyDb(conn,session,target_id, family_id,env_id ); 
				
				html="-";
				msg="ok:javascript:makeEnvironmentList()";			
				
			}
			
			//**********************************************
			//refill_parent_table_info
			//**********************************************
			if (action.equals("refill_parent_table_info")) {
				
				String tab_id=par1;
				

				
				html=refillParentTable(conn, session, tab_id);
				msg="ok";			
				
			}
			
			//**********************************************
			//show_failed_work_package_list
			//**********************************************
			if (action.equals("show_failed_work_package_list")) {
				
				String work_plan_id=par1;
				

				
				html=showFailedWorkPackageList(conn, session, work_plan_id);
				msg="ok";			
				
			}
			
			//**********************************************
			//show_copy_summary
			//**********************************************
			if (action.equals("show_copy_summary")) {
				
				String work_plan_id=par1;
				

				
				html=showCopySummary(conn, session, work_plan_id);
				msg="ok";			
				
			}

			//**********************************************
			//print_work_package_error
			//**********************************************
			if (action.equals("print_work_package_error")) {
				
				String work_package_id=par1;
				

				
				html=printWorkPackageError(conn, session, work_package_id);
				msg="ok";			
				
			}
			
			//**********************************************
			//show_waiting_work_plan_list
			//**********************************************
			if (action.equals("show_waiting_work_plan_list")) {
				
				String work_package_id=par1;
				

				
				html=printDependedWorkPlanList(conn, session, work_package_id); 
				msg="ok";			
				
			}
			//**********************************************
			//make_app_options
			//**********************************************
			if (action.equals("make_app_options")) {
				
				String app_id=par1;
				

				
				html=makeAppOptions(conn, session, app_id);
				msg="ok";			
				
			}
			
			//**********************************************
			//save_app_options
			//**********************************************
			if (action.equals("save_app_options")) {
				
				String app_id=par1;
				String last_run_point_statement=par2;

				
				saveAppOptions(conn, session, app_id, last_run_point_statement);
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//set_hide_needed_tables_checked
			//**********************************************
			if (action.equals("set_hide_needed_tables_checked")) {
				
				String hide_needed_tables=par1;

				session.setAttribute("hide_needed_tables", hide_needed_tables);
				
				html="-";
				msg="ok:javascript:fillAppTabList()";			
				
			}
			//**********************************************
			//set_filter_family_id
			//**********************************************
			if (action.equals("set_filter_family_id")) {
				
				String filter_family_id=par1;

				session.setAttribute("filter_family_id", filter_family_id);
				
				html="-";
				msg="ok:javascript:fillAppTabList()";			
				
			}
			//**********************************************
			//rollback_copy
			//**********************************************
			if (action.equals("rollback_copy")) {
				
				String rollback_wp_id=par1;

				rollbackCopyWorkPlan(conn, rollback_wp_id);
				
				html="-";
				msg="ok:javascript:listMyCopyTasks()";			
				
			}
			
			//**********************************************
			//do_login
			//**********************************************
			if (action.equals("do_login")) {
				
				String input_username=par1;
				String input_password=par2;
				
				
				boolean is_connection_ok=doLoginAttempt(conn, session, input_username, input_password);

				html="-";

				if (!is_connection_ok)
					msg="ok:javascript:showLoginError()";
				else 
					msg="ok:javascript:gotoHome()";			
				
			}
			
			//**********************************************
			//show_app_list_for_table
			//**********************************************
			if (action.equals("show_app_list_for_table")) {
				
				String table_cat=par1;
				String table_owner=par2;
				String table_name=par3;
				String app_type=par4;
				
				
				html=showAppListForTable(conn, session, app_type, table_cat, table_owner, table_name);  
				msg="ok";			
				
			}
			
			//**********************************************
			//show_comment_for_table
			//**********************************************
			if (action.equals("show_comment_for_table")) {
				String env_id=par1;
				String table_cat=par2;
				String table_owner=par3;
				String table_name=par4;
				String app_type=par5;
				
				
				
				
				html=showCommentForTable(conn, session, app_type,  env_id, table_cat, table_owner, table_name); 
				msg="ok";			
				
			}
			
			//**********************************************
			//show_comment_for_table
			//**********************************************
			if (action.equals("set_comment_for_table")) {
				
				String comment_action_app_type=par1;
				
				String comment_action=comment_action_app_type.split(":")[0];
				String app_type=comment_action_app_type.split(":")[1];
				
				String table_cat=par2;
				String table_owner=par3;
				String table_name=par4;
				String table_comment=par5;
				String env_id=par6;
				
				System.out.println("table_cat="+table_cat); 
				
				setCommentForTable(conn, session, comment_action, app_type,  env_id, table_cat, table_owner, table_name, table_comment);  
				html="-";
				msg="ok:javascript:redrawTableCell('"+env_id+"','"+table_cat+"','"+table_owner+"','"+table_name+"')";			
				
			}
			
			//**********************************************
			//set_discard_flag_for_table
			//**********************************************
			if (action.equals("set_discard_flag_for_table")) {
				
				String env_id=par1;
				String table_cat=par2;
				String table_owner=par3;
				String table_name=par4;
				String discard_flag=par5;
				String app_type=par6;
				
				System.out.println("set_discard_flag_for_table : " +env_id+", table_cat: "+table_cat+", table_owner:"+table_owner+",table_name : "+table_name+", discard_flag: "+discard_flag+", discard_flag="+discard_flag);
				
				setDiscardFlagForTable(conn, session, app_type, env_id, table_cat, table_owner, table_name, discard_flag);  
				html="-";
				msg="ok:javascript:redrawTableCell('"+env_id+"','"+table_cat+"','"+table_owner+"','"+table_name+"')";			
				
			}
			
			//**********************************************
			//redraw_table_cell
			//**********************************************
			if (action.equals("redraw_table_cell")) {
				
				String env_id=par1;
				String table_cat=par2;
				String table_owner=par3;
				String table_name=par4;
				String app_type=par5;
				
				System.out.println("redraw_table_cell : " +env_id+", table_cat: "+table_cat+", table_owner:"+table_owner+",table_name : "+table_name+", app_type: "+app_type);
				
				
				html=makeTableCell(conn, session, env_id, app_type, table_cat, table_owner, table_name, null, null, null, null);
				msg="ok";			
				
			}
			
			//**********************************************
			//reorder_table_relation_in_app
			//**********************************************
			if (action.equals("reorder_table_relation_in_app")) {
				
				String tab_id=par1;
				String direction=par2;
				
				
				reorderTableInApp(conn, session, tab_id, direction);
				html="-";
				msg="ok:javascript:fillAppTabList()";			
				
			}
			
			//**********************************************
			//reorder_table_in_app
			//**********************************************
			if (action.equals("reorder_table_in_app")) {
				
				String tab_id=par1;
				String direction=par2;


				
				reorderTable(conn, session, tab_id, direction);
				html="-";
				msg="ok:javascript:fillAppTabList()";			
				
			}
			
			//**********************************************
			//set_copy_table_order
			//**********************************************
			if (action.equals("set_copy_table_order")) {
				
				String tab_id=par1;
				String direction=par2;


				
				html=makeCopyTableOrderDlg(conn, session, tab_id);
				msg="ok";			
				
			}
			//**********************************************
			//set_copy_table_order_do
			//**********************************************
			if (action.equals("set_copy_table_order_do")) {
				
				String tab_id=par1;
				String set_after_tab_id=par2;
				String set_after_parent_tab_id=par3;
					
				setCopyTableOrderDo(conn,session,tab_id,set_after_tab_id, set_after_parent_tab_id);
				
				html="-";
				msg="ok:javascript:fillAppTabList()";		
				
			}
			//**********************************************
			//change_table_order
			//**********************************************
			if (action.equals("change_table_order")) {
				
				String app_id=par1;
				String changing_tab_order=par2;
				String before_tab_order=par3;
					
				changeTableOrder(conn,session,app_id,changing_tab_order, before_tab_order);
				
				html="-";
				msg="ok:javascript:fillAppTabList(); checkProblems(); ";		
				
			}
			//**********************************************
			//add_depended_copy_application
			//**********************************************
			if (action.equals("add_depended_copy_application")) {
				
				String app_id=par1;
				String depended_app_id=par2;
				
				
				addDependedCopyApplication(conn, session, app_id, depended_app_id);
				html="-";
				msg="ok:javascript:openAppDependancyDlg()";			
				
			}
			
			//**********************************************
			//add_depended_copy_application
			//**********************************************
			if (action.equals("delete_apps_rel")) {
				
				String app_rel_id=par1;
				
				
				deleteApplicationRel(conn, session, app_rel_id);
				html="-";
				msg="ok:javascript:openAppDependancyDlg()";			
				
			}
			
			//**********************************************
			//reorder_apps_rel
			//**********************************************
			if (action.equals("reorder_apps_rel")) {
				
				String app_rel_id=par1;
				String direction=par2;
				
				
				
				reorderApplicationRel(conn, session, app_rel_id, direction);
				html="-";
				msg="ok:javascript:openAppDependancyDlg()";			
				
			}
			
			//**********************************************
			//add_new_script
			//**********************************************
			if (action.equals("add_new_script")) {
				
				String app_id=par1;
				String stage=par2;
				String script_description=par3;
				String family_id=par4;
				
				
				addNewScript(conn, session, app_id, stage,script_description,family_id);
				html="-";
				msg="ok:javascript:openScriptDlg('"+stage+"')";			
				
			}
			
			
			//**********************************************
			//remove_script
			//**********************************************
			if (action.equals("remove_script")) {
				
				String app_id=par1;
				String stage=par2;
				String script_id=par3;
				
				
				
				removeScript(conn, session ,script_id); 
				html="-";
				msg="ok:javascript:openScriptDlg('"+stage+"')";			
				
			}
			
			//**********************************************
			//reorder_script
			//**********************************************
			if (action.equals("reorder_script")) {
				
				String app_id=par1;
				String stage=par2;
				String script_id=par3;
				String direction=par4;
				
				
				
				reorderScript(conn ,app_id, stage, script_id, direction);  
				
				html="-";
				msg="ok:javascript:openScriptDlg('"+stage+"')";			
				
			}
			
			//**********************************************
			//update_rel_app_field
			//**********************************************
			if (action.equals("update_rel_app_field")) {
				String rel_app_id=par1;
				String field_name=par2;
				String field_value=par3; 
				  
				updateTdmTableField(conn,session,"tdm_apps_rel",rel_app_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//update_script_field
			//**********************************************
			if (action.equals("update_script_field")) {
				String script_id=par1;
				String field_name=par2;
				String field_value=par3; 
				  
				updateTdmTableField(conn,session,"tdm_copy_script",script_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//discover_for_copy
			//**********************************************
			if (action.equals("discover_for_copy")) {
				String env_id=par1;
				String tab_id=par2;
				String discovery_type=par3;
				  
				html=discoverCopy(conn,session,env_id,tab_id,discovery_type);
				msg="ok";			
				
			}
			
			//**********************************************
			//install_server_side_scripts
			//**********************************************
			if (action.equals("install_server_side_scripts")) {
				String db_id=par1;
				
				StringBuilder installLogs=new StringBuilder();
				  
				boolean is_installed=installServerSideScripts(conn, application,  session, db_id, installLogs);
				html="-";
				
				
				
				if (is_installed)
					msg="ok:javascript:myalert('<font color=green><b>Installation is successfull</b></font><hr>"+clearHtml(installLogs.toString()).replaceAll("\n|\r","<br>").replaceAll("'","`")+"'); ";
				else 
					msg="ok:javascript:myalert('<font color=red><b>Installation failed. </b></font><hr>"+clearHtml(installLogs.toString()).replaceAll("\n|\r","<br>").replaceAll("'","`")+"'); ";

			}
			
		
			
			//**********************************************
			//draw_dm_screen
			//**********************************************
			if (action.equals("draw_dm_screen")) {
				
				html=makeDMScreen(conn,session); 
				msg="ok";			
				
			}
			
			//**********************************************
			//show_dm_proxy_actions
			//**********************************************
			if (action.equals("show_dm_proxy_actions")) {

				String proxy_id=par1;
				
				html=makeDMProxyActions(conn,session,proxy_id); 
				msg="ok";			
				
			}
			
			//**********************************************
			//show_dm_proxy_sessions
			//**********************************************
			if (action.equals("show_dm_proxy_sessions")) {

				String proxy_id=par1;
				String proxy_session_filter=par2;
				
				html=makeDMProxySessionList(conn,session, proxy_id, proxy_session_filter); 
				msg="ok";			
				
			}
			
			//**********************************************
			//add_new_dm_proxy
			//**********************************************
			if (action.equals("add_new_dm_proxy")) {

				
				html=makeAddnewDMProxyForm(conn,session); 
				msg="ok";			
				
			}
			
			//**********************************************
			//stop_dm_proxy
			//**********************************************
			if (action.equals("stop_dm_proxy")) {

				String proxy_id=par1;
				
				setDMProxyStatus(conn,session,proxy_id,"STOP");  
				
				html="-"; 
				msg="ok:javascript:listDMProxies()";			
				
			}
			
			
			//**********************************************
			//reload_all_dm_proxy
			//**********************************************
			if (action.equals("reload_all_dm_proxy")) {

				String app_id=par1;
				
				reloadDMProxyConfigurations(conn,session,app_id);  
				
				html="-"; 
				msg="ok";			
				
			}
			
			//**********************************************
			//reload_dm_proxy
			//**********************************************
			if (action.equals("reload_dm_proxy")) {

				String proxy_id=par1;
				
				reloadDMProxy(conn,session,proxy_id);  
				
				html="-"; 
				msg="ok:javascript:listDMProxies()";			
				
			}
			
			//**********************************************
			//set_proxy_debug_flag
			//**********************************************
			if (action.equals("set_proxy_debug_flag")) {

				String proxy_id=par1;
				String current_debug_flag=par2;
				
				changeProxyDebugFlag(conn,session,proxy_id,current_debug_flag);  
				 
				html="-"; 
				msg="ok:javascript:listDMProxies()";			
				
			}
			//**********************************************
			//remove_dm_proxy
			//**********************************************
			if (action.equals("remove_dm_proxy")) {

				String proxy_id=par1;
				
				removeDMProxy(conn,session,proxy_id);  
				
				html="-"; 
				msg="ok:javascript:listDMProxies()";			
				
			}
			//**********************************************
			//add_new_copy_checklist
			//**********************************************
			if (action.equals("add_new_copy_checklist")) {

				String checklist_app_id=par1;
				String checklist_name=par2;
				
				addNewCopyCheckList(conn,session,checklist_app_id, checklist_name);  
				
				html="-"; 
				msg="ok:javascript:openChecklistDlg()";			
				
			}
			//**********************************************
			//remove_copy_checklist
			//**********************************************
			if (action.equals("remove_copy_checklist")) {

				String checklist_id=par1;
				
				removeCopyCheckList(conn,session,checklist_id);  
				
				html="-"; 
				msg="ok:javascript:openChecklistDlg()";			
				
			}
			//**********************************************
			//start_dm_proxy
			//**********************************************
			if (action.equals("start_dm_proxy")) {

				String proxy_id=par1;
				
				setDMProxyStatus(conn,session,proxy_id,"START");  
				
				html="-"; 
				msg="ok:javascript:listDMProxies()";			
				
			}
			
			//**********************************************
			//save_dm_configuration
			//**********************************************
			if (action.equals("save_dm_configuration")) {

				String proxy_id=par1;
				String proxy_name=par2;
				String proxy_info=par3;
				String target_app_id=par4;
				String target_env_id=par5;
				
				
				saveProxyInfo(conn,session,proxy_id,proxy_name,proxy_info,target_app_id,target_env_id);   
				
				html="-"; 
				msg="ok:javascript:listDMProxies()";			
				
			}
			
			
			//**********************************************
			//make_dynamic_masking_confiruration
			//**********************************************
			if (action.equals("make_dynamic_masking_confiruration")) {
				String app_id=par1;
				
				html=makeDynamicMaskingConfiguration(conn,session, app_id); 
				msg="ok";			
				
			}
			
			//**********************************************
			//make_content_based_content_rule
			//**********************************************
			if (action.equals("make_content_based_content_rule")) {
				String app_id=par1;
				
				html=makeDynamicMaskingContentRules(conn,session, app_id); 
				msg="ok";			
				
			}
			
			//**********************************************
			//make_statement_exceptions
			//**********************************************
			if (action.equals("make_statement_exceptions")) {
				String app_id=par1;
				
				html=makeDynamicMaskingStatementExceptions(conn,session, app_id); 
				msg="ok";			 
				
			}
			
			//**********************************************
			//make_rule_exceptions
			//**********************************************
			if (action.equals("make_rule_exceptions")) {
				String app_id=par1;
				
				html=makeDynamicMaskingLogExceptions(conn,session, app_id); 
				msg="ok";			
				
			}
			
			//**********************************************
			//make_exception_window
			//**********************************************
			if (action.equals("make_exception_window")) {
				String exception_scope=par1;
				String exception_obj_id=par2;
				
				html=openDynamicMaskingExceptionWindow(conn,session, exception_scope, exception_obj_id); 
				msg="ok";			
				
			}
			//**********************************************
			//add_new_content_based_rule
			//**********************************************
			if (action.equals("add_new_content_based_rule")) {
				String app_id=par1;
				
				addNewDynamicMaskingRule(conn,session, app_id);
				
				html="-"; 
				msg="ok:javascript:makeDynamicMaskingContentRules('"+app_id+"');";			
				
			}
			//**********************************************
			//add_new_log_exception
			//**********************************************
			if (action.equals("add_new_log_exception")) {
				String app_id=par1;
				
				addNewLogException(conn,session, app_id);
				
				html="-"; 
				msg="ok:javascript:makeDynamicMaskingLogExceptions('"+app_id+"');";			
				
			}
			//**********************************************
			//add_new_statement_exception
			//**********************************************
			if (action.equals("add_new_statement_exception")) {
				String app_id=par1;
				
				addStatementLogException(conn,session, app_id);
				
				html="-"; 
				msg="ok:javascript:makeDynamicMaskingStatementExceptions('"+app_id+"');";			
				
			}
			
			//**********************************************
			//remove_content_based_rule
			//**********************************************
			if (action.equals("remove_content_based_rule")) {
				String app_id=par1;
				String rule_id=par2;
				
				removeDynamicMaskingRule(conn,session, rule_id);
				
				html="-"; 
				msg="ok:javascript:makeDynamicMaskingContentRules('"+app_id+"');";			
				
			}
			
			//**********************************************
			//remove_log_exception
			//**********************************************
			if (action.equals("remove_log_exception")) {
				String app_id=par1;
				String exception_id=par2;
				
				removeLogException(conn,session, exception_id);
				
				html="-"; 
				msg="ok:javascript:makeDynamicMaskingLogExceptions('"+app_id+"');";			
				
			}
			
			//**********************************************
			//remove_statement_exception
			//**********************************************
			if (action.equals("remove_statement_exception")) {
				String app_id=par1;
				String exception_id=par2;
				
				removeStatementException(conn,session, exception_id);
				
				html="-"; 
				msg="ok:javascript:makeDynamicMaskingStatementExceptions('"+app_id+"');";			
				
			}
			
			//**********************************************
			//reorder_content_based_rule
			//**********************************************
			if (action.equals("reorder_content_based_rule")) {
				String app_id=par1;
				String rule_id=par2;
				String direction=par3;
				
				reorderDynamicMaskingRule(conn,session, app_id, rule_id, direction);
				
				html="-"; 
				msg="ok:javascript:makeDynamicMaskingContentRules('"+app_id+"');";			
				
			}
			
			//**********************************************
			//change_content_based_rule_field_value
			//**********************************************
			if (action.equals("change_content_based_rule_field_value")) {

				String app_id=par1;
				String rule_id=par2;
				String rule_field_name=par3;
				String field_value=par4;
				
				changeContentBasedRuleField(conn,session,rule_id,rule_field_name, field_value);  
				
				html="-"; 
				msg="ok:javascript:makeDynamicMaskingContentRules('"+app_id+"');";			
				
			}
			
			//**********************************************
			//list_session_commands
			//**********************************************
			if (action.equals("list_session_commands")) {

				String proxy_id=par1;
				String selected_Session_ids=par2;
				String proxy_session_filter=par3;
				
				
				html=makeDMProxySessionCommandList(conn,session, proxy_id, selected_Session_ids, proxy_session_filter);  
				msg="ok";			
				
			}
			//**********************************************
			//list_blacklisted_session_commands
			//**********************************************
			if (action.equals("list_blacklisted_session_commands")) {

				String proxy_id=par1;
				String session_id=par2;
				String blacklist_id=par3;
				
				 
				html=makeDMProxyBlackListedSessionCommandList(conn,session, proxy_id, session_id, blacklist_id);   
				msg="ok";			
				
			}
			
			//**********************************************
			//set_exception_for_sessions_dlg
			//**********************************************
			if (action.equals("set_exception_for_sessions_dlg")) {

				String proxy_id=par1;
				String selected_Session_ids=par2;
				
				html=makeDMExceptionForSessionDialog(conn,session, proxy_id, selected_Session_ids); 
				msg="ok";			
				
			}
			
			
			//**********************************************
			//set_exception_for_sessions
			//**********************************************
			if (action.equals("set_exception_for_sessions")) {

				String exception_proxy_id=par1;
				String exception_selected_session_ids=par2;
				String exception_duration=par3;
				String exception_period=par4;
				String proxy_session_filter=par5;
				
				
				setDMProxySessionException(conn, session, exception_proxy_id, exception_selected_session_ids, exception_duration, exception_period); 
				
				html="-";
				msg="ok:javascript:showDMProxySessions('"+exception_proxy_id+"','"+proxy_session_filter+"')";	
				
				
			}
			
			//**********************************************
			//clear_exception_for_sessions
			//**********************************************
			if (action.equals("clear_exception_for_sessions")) {

				String exception_proxy_id=par1;
				String exception_selected_session_ids=par2;
				String proxy_session_filter=par3;
				
				
				
				clearDMProxySessionException(conn, session, exception_proxy_id, exception_selected_session_ids); 
				
				html="-";
				msg="ok:javascript:showDMProxySessions('"+exception_proxy_id+"','"+proxy_session_filter+"')";	
				
				
			}
			
			//**********************************************
			//terminate_sessions
			//**********************************************
			if (action.equals("terminate_sessions")) {

				String exception_proxy_id=par1;
				String exception_selected_session_ids=par2;
				String proxy_session_filter=par3;
				
				
				
				terminateSessions(conn, session, exception_proxy_id, exception_selected_session_ids);  
				
				html="-";
				msg="ok:javascript:showDMProxySessions('"+exception_proxy_id+"','"+proxy_session_filter+"')";	
				
				
			}
			//**********************************************
			//blacklist_sessions
			//**********************************************
			if (action.equals("blacklist_sessions")) {

				String blacklist_proxy_id=par1;
				String blacklist_selected_session_ids=par2;
				String proxy_session_filter=par3;
				
				
				blacklistSessions(conn, session, blacklist_proxy_id, blacklist_selected_session_ids);   


				html="-";
				msg="ok:javascript:showDMProxySessions('"+blacklist_proxy_id+"','"+proxy_session_filter+"'); myalert('Selected sessions successfuly added to blacklsit')";	
			
				
				
				
				
			}
			
			//**********************************************
			//trace_sessions
			//**********************************************
			if (action.equals("trace_sessions")) {

				String exception_proxy_id=par1;
				String exception_selected_session_ids=par2;
				String proxy_session_filter=par3;
				String start_stop=par4;
				
				
				
				traceSessions(conn, session, exception_proxy_id, exception_selected_session_ids, start_stop);  
				
				html="-";
				msg="ok:javascript:showDMProxySessions('"+exception_proxy_id+"','"+proxy_session_filter+"')";	
				
				
			}
			
			
			//**********************************************
			//get_masked_result_list
			//**********************************************
			if (action.equals("get_masked_result_list")) {

				String log_id=par1;
				
				
				html=getMaskedResultList(conn,session, log_id); 
				msg="ok";			
				
			}
			
			//**********************************************
			//set_dm_proxy_filter
			//**********************************************
			if (action.equals("set_dm_proxy_filter")) {

				String proxy_id=par1;
				String proxy_session_filter=par2;
				String origin=par3;
				
				
				html=makeSessionFilterDlg(conn,session, proxy_id, proxy_session_filter, origin); 
				msg="ok";			
				
			}
			
			//**********************************************
			//set_dm_proxy_filter_do_SESSION or set_dm_proxy_filter_do_COMMAND
			//**********************************************
			if (action.equals("set_dm_proxy_filter_do_SESSION") || action.equals("set_dm_proxy_filter_do_COMMAND")) {

				String session_filter_proxy_id=par1;
				String session_filter_proxy_session_filter=par2;
				String filter_username=par3;
				String filter_session_info=par4;
				String filter_command=par5;
				
				
				setDmProxyFilter(conn, session, 
						session_filter_proxy_id,
						session_filter_proxy_session_filter,
						filter_username,
						filter_session_info,
						filter_command
						);
				
				html="-";
				
				
				msg="ok:javascript:showDMProxySessions('"+session_filter_proxy_id+"','"+session_filter_proxy_session_filter+"'); ";	
				if (action.equals("set_dm_proxy_filter_do_COMMAND")) {
					msg=msg +" listSessionCommands('"+session_filter_proxy_id+"','"+session_filter_proxy_session_filter+"'); ";	
				}
				
			}
			
			//**********************************************
			//add_new_exception
			//**********************************************
			if (action.equals("add_new_exception")) {

				String exception_scope=par1;
				String exception_obj_id=par2;
				String new_policy_group_id=par3;
				
				
				
				addNewException(conn, session, exception_scope, exception_obj_id, new_policy_group_id); 
				
				html="-";
				msg="ok:javascript:openDynamicMaskingExceptionWindow('"+exception_scope+"','"+exception_obj_id+"')";	
				
				
			}
			
			//**********************************************
			//add_new_exception
			//**********************************************
			if (action.equals("remove_exception")) {

				String exception_scope=par1;
				String exception_obj_id=par2;
				String exception_id=par3;
				
				
				
				removeException(conn, session, exception_id); 
				
				html="-";
				msg="ok:javascript:openDynamicMaskingExceptionWindow('"+exception_scope+"','"+exception_obj_id+"')";
				
				
			}
			
			
			
			
			//**********************************************
			//make_exception_button
			//**********************************************
			if (action.equals("make_exception_button")) {

				String exception_scope=par1;
				String exception_obj_id=par2;
				
				
				html=makeExceptionButton(conn,session, exception_scope, exception_obj_id); 
				msg="ok";			
				
			}
			
			
			//**********************************************
			//open_data_pool_configuration_dlg
			//**********************************************
			if (action.equals("open_data_pool_configuration_dlg")) {

				String app_id=par1;
				String env_id=par2;
				
				
				
				html=makeDataPoolConfigurationDlg(conn,session, app_id, env_id); 
				msg="ok";
				
				
			}
			
			
			//**********************************************
			//open_data_pool_lov_dlg
			//**********************************************
			if (action.equals("open_data_pool_lov_dlg")) {

				String app_id=par1;
				String env_id=par2;
				
				
				
				html=makeDataPoolLovDlg(conn,session, app_id, env_id); 
				msg="ok";
				
				
			}
			
			//**********************************************
			//open_data_pool_group_dlg
			//**********************************************
			if (action.equals("open_data_pool_group_dlg")) {

				String app_id=par1;
				
				
				
				html=makeDataPoolGroupDlg(conn,session, app_id); 
				msg="ok";
				
				
			}
			//**********************************************
			//save_data_pool_configuration
			//**********************************************
			if (action.equals("save_data_pool_configuration")) {

				String pool_id=par1;
				String family_id=par2;
				String base_sql=par3;
			
				saveDataPoolConfiguration(conn,session, pool_id, family_id, base_sql);  
				
				html="-";
				msg="ok";
				
				
			}
			
			//**********************************************
			//open_data_pool_property_dlg
			//**********************************************
			if (action.equals("open_data_pool_property_dlg")) {

				String app_id=par1;
				String env_id=par2;
				String property_id=par3;
				
				
				
				html=makeDataPoolPropertyDlg(conn,session, app_id, env_id, property_id); 
				msg="ok";
				
				
			}
			//**********************************************
			//make_property_get_method_details
			//**********************************************
			if (action.equals("make_property_get_method_details")) {

				String property_id=par1;
				String get_method=par2;
				
				
				html=makePropertyGetMethodDetails(conn,session, property_id, get_method);  
				msg="ok";
				
				
			}
			
			//**********************************************
			//update_pool_lov_field
			//**********************************************
			if (action.equals("update_pool_lov_field")) {
				String pool_lov_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_pool_lov",pool_lov_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//update_pool_group_field
			//**********************************************
			if (action.equals("update_pool_group_field")) {
				String pool_group_id=par1;
				String field_name=par2;
				String field_value=par3; 
				 
				updateMadTableField(conn,session,"tdm_pool_group",pool_group_id, field_name, field_value);
				html="-";
				msg="ok";			
				
			}
			
			
			//**********************************************
			//add_pool_lov
			//**********************************************
			if (action.equals("add_pool_lov")) {
				String pool_id=par1;
				String app_id=par2;

				 
				addNewPoolLov(conn,session,pool_id);
				html="-";
				msg="ok:javascript:openDataPoolLovDlg('"+app_id+"')";			
				
			}
			
			//**********************************************
			//add_pool_group
			//**********************************************
			if (action.equals("add_pool_group")) {
				String pool_id=par1;
				String app_id=par2;

				 
				addNewPoolGroup(conn,session,pool_id); 
				html="-";
				msg="ok:javascript:openDataPoolGroupDlg('"+app_id+"')";			
				
			}
			
			//**********************************************
			//remove_pool_lov
			//**********************************************
			if (action.equals("remove_pool_lov")) {
				String pool_lov_id=par1;
				String app_id=par2;

				 
				boolean is_ok=removePoolLov(conn,session,pool_lov_id); 
				
				
				if (is_ok) {
					html="-";
					msg="ok:javascript:openDataPoolLovDlg('"+app_id+"')";
				}
				else {
					html="-";
					msg="ok:javascript:myalert('cannot removed since this LOV is used or there was an error on deleting.')";
				}
							
				
			}
			
			
			//**********************************************
			//remove_pool_group
			//**********************************************
			if (action.equals("remove_pool_group")) {
				String pool_group_id=par1;
				String app_id=par2;

				 
				boolean is_ok=removePoolGroup(conn,session,pool_group_id); 
				
				
				if (is_ok) {
					html="-";
					msg="ok:javascript:openDataPoolGroupDlg('"+app_id+"')";
				}
				else {
					html="-";
					msg="ok:javascript:myalert('cannot removed since this group is used or there was an error on deleting.')";
				}
							
				
			}
			
			//**********************************************
			//remove_pool_property
			//**********************************************
			if (action.equals("remove_pool_property")) {
				String pool_property_id=par1;
				String app_id=par2;

				 
				boolean is_ok=removePoolProperty(conn,session,pool_property_id);  
				
				
				if (is_ok) {
					html="-";
					msg="ok:javascript:listPoolProperties('"+app_id+"')";
				}
				else {
					html="-";
					msg="ok:javascript:myalert('cannot removed since this property is used or there was an error on deleting.')";
				}
							
				
			}
			
			
			//**********************************************
			//reorder_pool_group_group
			//**********************************************
			if (action.equals("reorder_pool_group_group")) {
				String pool_group_id=par1;
				String app_id=par2;
				String direction=par3;
				
				
				reorderByGroup(conn,session,"tdm_pool_group","pool_id",pool_group_id,direction);  
			
				html="-";
				msg="ok:javascript:openDataPoolGroupDlg('"+app_id+"')";
			
							
				
			}

			//**********************************************
			//create_new_pool_property
			//**********************************************
			if (action.equals("create_new_pool_property")) {

				String pool_id=par1;
			
				createNewProperty(conn,session, pool_id);   
				 
				
				html="-";
				msg="ok";
				
				
			}
			
			//**********************************************
			//set_pool_property_id
			//**********************************************
			if (action.equals("set_pool_property_id")) {

				String pool_property_id=par1;
			
				setPoolPropertyId(conn,session, pool_property_id);   
				 
				
				html="-";
				msg="ok";
				
				
			}
			
			//**********************************************
			//set_pool_property_field
			//**********************************************
			if (action.equals("set_pool_property_field")) {

				String pool_property_id=getPoolPropertyId(conn,session);
			
				String field_name=par1;
				String field_value=par2; 
				 
				updateMadTableField(conn,session,"tdm_pool_property",pool_property_id, field_name, field_value);
				
				
				html="-";
				msg="ok";
				
				
			}
			
			//**********************************************
			//list_pool_properties
			//**********************************************
			if (action.equals("list_pool_properties")) {

				String pool_app_id=par1;
			
				html=getDataPoolProperties(conn,session, pool_app_id);
				msg="ok";
				
				
			}
			
			
			//**********************************************
			//draw_pool_screen
			//**********************************************
			if (action.equals("draw_pool_screen")) {

			
				html=drawPoolScreen(conn,session);
				msg="ok";
				
				
			}
			
			
			//**********************************************
			//add_new_data_pool_instancel_dlg
			//**********************************************
			if (action.equals("add_new_data_pool_instancel_dlg")) {

			
				html=makeNewDataPoolInstanceDlg(conn,session);
				msg="ok";
				
				
			}
			
			//**********************************************
			//add_new_data_pool_instance
			//**********************************************
			if (action.equals("add_new_data_pool_instance")) {
	
				String pool_ins_app_id=par1;
				String pool_ins_target_id=par2;
				String target_pool_size=par3;
				String is_debug=par4;
				String paralellism_count=par5;
				
				
				
				addNewDataPoolInstance(conn, session, pool_ins_app_id, pool_ins_target_id, target_pool_size,is_debug, paralellism_count);
			
				html="-";
				msg="ok:javascript:listPoolInstances()";
				
				
			}
			
			
			//**********************************************
			//remove_data_pool_instance
			//**********************************************
			if (action.equals("remove_data_pool_instance")) {
	
				String pool_instance_id=par1;
				
				removeDataPoolInstance(conn, session, pool_instance_id);
			
				html="-";
				msg="ok:javascript:listPoolInstances()"; 
				
				
			}
			//**********************************************
			//start_data_pool_instances
			//**********************************************
			if (action.equals("start_data_pool_instance")) {
	
				String pool_instance_id=par1;
				
				startDataPoolInstance(conn, session, pool_instance_id);
			
				html="-";
				msg="ok:javascript:listPoolInstances()"; 
				
				
			}
			//**********************************************
			//stop_data_pool_instance
			//**********************************************
			if (action.equals("stop_data_pool_instance")) {
	
				String pool_instance_id=par1;
				
				stopDataPoolInstance(conn, session, pool_instance_id);
			
				html="-";
				msg="ok:javascript:listPoolInstances()"; 
				
				
			}
			//**********************************************
			//refresh_data_pool_instance
			//**********************************************
			if (action.equals("refresh_data_pool_instance")) {
	
				String pool_instance_id=par1;
				
				refreshDataPoolInstance(conn, session, pool_instance_id);
			
				html="-";
				msg="ok:javascript:listPoolInstances()"; 
				
				
			}
			//**********************************************
			//set_data_pool_instance_parameters_dlg
			//**********************************************
			if (action.equals("set_data_pool_instance_parameters_dlg")) {
	
				String pool_instance_id=par1;
				
				
			
				html=makeDataPoolInstanceParametersDlg(conn, session, pool_instance_id);
				msg="ok:javascript:listPoolInstances()"; 
				
				
			}
			
			//**********************************************
			//set_data_pool_instance_parameters_do
			//**********************************************
			if (action.equals("set_data_pool_instance_parameters_do")) {
	
				String pool_instance_id=par1;
				String target_pool_size=par2;
				String is_debug=par3;
				String paralellism_count=par4;
				
				updateDataPoolInstanceParameters(conn, session, pool_instance_id, target_pool_size, is_debug, paralellism_count);
			
				html="-";
				msg="ok:javascript:listPoolInstances()"; 
				
				
			}
			
			
			//**********************************************
			//reservation_data_pool_instance_dlg
			//**********************************************
			if (action.equals("reservation_data_pool_instance_dlg")) {
	
				String pool_instance_id=par1;
				
				html=makeReserveDataPoolInstanceDlg(conn, session, pool_instance_id); 
				msg="ok:javascript:listPoolInstances()"; 
				
				
			}
			
			//**********************************************
			//pick_from_data_pool
			//**********************************************
			if (action.equals("pick_from_data_pool")) {
	
				String pool_instance_id=par1;
				String data_id=par2;
				
				html=makePickFromDataPoolDlg(conn, session, pool_instance_id, data_id); 
				msg="ok"; 
				
				
			}
			//**********************************************
			//pick_from_data_pool_do
			//**********************************************
			if (action.equals("pick_from_data_pool_do")) {
	
				String pool_instance_id=par1;
				String data_id=par2;
				String reservation_note=par3;
				
				pickFromDataPool(conn, session, pool_instance_id, data_id, reservation_note); 
			
				html="-";
				msg="ok:javascript:reloadPoolDataList('"+pool_instance_id+"')"; 
				
				
			}
			
			
			//**********************************************
			//set_data_pool_filter
			//**********************************************
			if (action.equals("set_data_pool_filter")) {
	
				String pool_instance_id=par1;
				String filter_field_name=par2;
				String filter_field_value=par3;
				
				dataPoolSetFilter(conn, session, pool_instance_id, filter_field_name, filter_field_value); 
			
				html="-";
				msg="ok:javascript:reloadPoolDataList('"+pool_instance_id+"')"; 
				
				
			}
			
			//**********************************************
			//reload_pool_data_list
			//**********************************************
			if (action.equals("reload_pool_data_list")) {
	
				String pool_instance_id=par1;

				html=makeloadPoolDataList(conn, session, pool_instance_id); 
				msg="ok"; 
				
				
				
			}
			
			//**********************************************
			//set_data_pool_filter
			//**********************************************
			if (action.equals("set_only_my_reservations_filter")) {
	
				String pool_instance_id=par1;
				String filter_val=par2; 
				
				dataPoolSetShowOnlyMyReservations(conn, session, pool_instance_id, filter_val); 
			
				html="-";
				msg="ok:javascript:reloadPoolDataList('"+pool_instance_id+"')"; 
				
				
			}
			
			//**********************************************
			//reorder_pool_property
			//**********************************************
			if (action.equals("reorder_pool_property")) {
				String pool_property_id=par1;
				String app_id=par2;
				String direction=par3;
				
				
				reorderByGroup(conn,session,"tdm_pool_property","pool_id",pool_property_id,direction);  
				
				
			
				html="-";
				msg="ok:javascript:listPoolProperties('"+app_id+"')";
			
							
				
			}
			
			//**********************************************
			//reorder_pool_property
			//**********************************************
			if (action.equals("set_mask_discovery_action")) {
				String discovery_id=par1;
				String action_name=par2;
				
				
				setMaskDiscoveryAction(conn,session,discovery_id,action_name);  
				
				
			
				html="-";
				msg="ok:javascript:loadDiscoveryReport()";
			
							
				
			}
			
			//**********************************************
			//open_database_catalog_list
			//**********************************************
			if (action.equals("open_database_catalog_list")) {
	
				String db_id=par1;
				String db_catalog=par2;

				html=makeDatabaseCatalogList(conn, session, db_id,db_catalog); 
				msg="ok"; 
			}
			
			//**********************************************
			//set_database_catalog
			//**********************************************
			if (action.equals("set_database_catalog")) {
				String db_id=par1;
				String db_catalog=par2;
				
				setDatabaseCatalog(conn,session,db_id,db_catalog);   
				html="-";
				msg="ok:javascript:makeDatabaseCatalogField('"+db_id+"','"+db_catalog+"')";
			
			}
			//**********************************************
			//make_database_catalog_field
			//**********************************************
			if (action.equals("make_database_catalog_field")) {
	
				String db_id=par1;
				String db_catalog=par2;

				html=makeDatabaseCatalogField(conn, session, db_id,db_catalog); 
				msg="ok"; 
			}
			
			
			
			//**********************************************
			//open_database_catalog_list
			//**********************************************
			if (action.equals("open_database_catalog_list")) {
	
				String db_id=par1;
				String db_catalog=par2;

				html=makeDatabaseCatalogList(conn, session, db_id,db_catalog); 
				msg="ok"; 
			}
			
			
			//**********************************************
			//change_scramble_partial_type
			//**********************************************
			if (action.equals("change_scramble_partial_type")) {
	
				String mask_prof_id=par1;
				String scramble_type=par2;

				changeScramblePartialType(conn, session, mask_prof_id, scramble_type);
				
				html="-";
				msg="ok:javascript:makeScramblePartialParameters('"+mask_prof_id+"')"; 
			}
			
			//**********************************************
			//make_scramble_partial_parameters
			//**********************************************
			if (action.equals("make_scramble_partial_parameters")) {
	
				String mask_prof_id=par1;

				html=makeScramblePartialParameters(conn, session, mask_prof_id); 
				msg="ok"; 
			}
			//**********************************************
			//make_partition_list_for_table
			//**********************************************
			if (action.equals("make_partition_list_for_table")) {
	
				String partition_tab_id=par1;
				String source_env_id=par2;

				html=makePartitionListForTable(conn, session, source_env_id, partition_tab_id); 
				msg="ok"; 
			}
			//**********************************************
			//add_new_overrideparameter
			//**********************************************
			if (action.equals("add_new_overrideparameter")) {
				String app_id=par1;
				String policy_group_id=par2;
				
				boolean is_exists=isOverrideParamExists(conn,session,app_id,policy_group_id); 
				
				if (is_exists) {
					html="-";
					msg="nok:Overriding is already defined for this policy group";
				} else {
					addNewOverrideParameter(conn,session,app_id,policy_group_id);    
					html="-";
					msg="ok:javascript:makeDynamicMaskingOverrideParams('"+app_id+"')";
				}
			
			}
			//**********************************************
			//make_override_param_list
			//**********************************************
			if (action.equals("make_override_param_list")) {
	
				String app_id=par1;

				html=makeDynamicMaskingOverrideParams(conn, session, app_id); 
				msg="ok"; 
			}
			//**********************************************
			//update_override_param_field
			//**********************************************
			if (action.equals("update_override_param_field")) {
				String override_id=par1;
				String app_id=par2;
				String field_name=par3;
				String field_value=par4; 
				 
				updateMadTableField(conn,session,"tdm_proxy_param_override",override_id, field_name, field_value);
				html="-";
				msg="ok:javascript:makeDynamicMaskingOverrideParams('"+app_id+"');";			
				
			}
			//**********************************************
			//remove_overriding_param
			//**********************************************
			if (action.equals("remove_overriding_param")) {
				String app_id=par1;
				String override_id=par2;
				
				 
				removeOverridingParam(conn,session,override_id); 
				html="-";
				msg="ok:javascript:makeDynamicMaskingOverrideParams('"+app_id+"');";			
				
			}
			
			
			//**********************************************
			//make_change_db_password_form
			//**********************************************
			if (action.equals("make_change_db_password_form")) {
				String db_id=par1;
				
				html=makeChangeDbPasswordForm(conn,session, db_id); 
				msg="ok";			
				
			}
			
			//**********************************************
			//make_test_session_validation_form
			//**********************************************
			if (action.equals("make_test_session_validation_form")) {
				String session_validation_id=par1;
				String test_regex_field_name=par2;
				
				html=makeSessionValidationRegexForm(conn,session, session_validation_id, test_regex_field_name); 
				msg="ok";			
				
			}
			
			//**********************************************
			//change_db_password_form
			//**********************************************
			if (action.equals("change_db_password_form")) {
				String change_password_db_id=par1;
				String encoded_password=par2;
				
				 
				boolean is_ok=changeDbPassword(conn,session,change_password_db_id,encoded_password);  
				
				if (is_ok) {
					html="-";
					msg="ok:Password changed successfully.";	
				} else {
					html="-";
					msg="nok:Password NOT changed.";	
				}
						
				
			}
			
			//**********************************************
			//save_session_validation_regex
			//**********************************************
			if (action.equals("save_session_validation_regex")) {
				String session_validation_id=par1;
				String validation_regex_field_name=par2;
				String test_for_statement_check_regex=decrypt(par3);
				
				 
				saveSessionValidationRegex(conn,session,session_validation_id,validation_regex_field_name,test_for_statement_check_regex ); 
				html="-";
				msg="ok:javascript:makeSessionValidationEditor('"+session_validation_id+"');";			
				
			}
			
			//**********************************************
			//reset_session_validation_script_validated
			//**********************************************
			if (action.equals("reset_session_validation_script_validated")) {
				String session_validation_id=par1;
				String build_script_field=par2;
				
				session.setAttribute("tested_session_validated_script_"+build_script_field+"_of_"+session_validation_id, "NO");
				 
				html="-";
				msg="ok:javascript:makeEditTestJSParamList()";			
			}
			
			//**********************************************
			//build_session_validation_script
			//**********************************************
			if (action.equals("build_session_validation_script")) {
				String session_validation_id=par1;
				String script_field=par2;
				
				
				session.setAttribute("tested_session_validated_script_"+script_field+"_of_"+session_validation_id, "NO");
				
				html=buildSessionValidationScript(conn,session, session_validation_id, script_field); 
				msg="ok";			
				
			}
			
			//**********************************************
			//save_session_validation_test_clause
			//**********************************************
			if (action.equals("save_session_validation_test_clause")) {
				String session_validation_id=par1;
				String field_value=decrypt(par2); //building_script
				
				
				session.setAttribute("test_clause_for_session_validation_id_"+session_validation_id, field_value);
				
				 
				html="-";
				msg="ok";			
				
			}
			//**********************************************
			//save_session_validation_script
			//**********************************************
			if (action.equals("save_session_validation_script")) {
				String session_validation_id=par1;
				String script_field_name=par2; //build_script_field
				String field_value=decrypt(par3); //building_script
				
				String is_validated=nvl((String) session.getAttribute("tested_session_validated_script_"+script_field_name+"_of_"+session_validation_id), "NO");
				
				if (is_validated.equals("NO")) {
					html="-";
					msg="nok:Validate the script before saving.";	
				}
				else {
					updateMadTableField(conn,session,"tdm_proxy_session_validation",session_validation_id, script_field_name, field_value);
					
					 
					html="-";
					msg="ok:javascript:scriptSaved()";		
				}
				
					
				
			}
			
			//**********************************************
			//execute_session_validation_script
			//**********************************************
			if (action.equals("execute_session_validation_script")) {
				String session_validation_id=par1;
				String build_script_field=par2;
				String script_to_execute=decrypt(par3);
				String clause_to_test=decrypt(par4);
				String script_parameters=decrypt(par5);
				
				StringBuilder sbResults=new StringBuilder();
				StringBuilder sbLogs=new StringBuilder();
				
				boolean isSuccess=executeScriptTest(conn,session, session_validation_id, build_script_field, script_to_execute, clause_to_test, script_parameters, sbResults, sbLogs);  
			
				 
				
				StringBuilder sbFinal=new StringBuilder();
				
				sbFinal.append("<b>Result :</b><br>");
				if (sbResults.length()>0 && sbResults.charAt(0)=='<') 
					sbFinal.append("<textarea readonly rows=1 style=\"width:100%; background-color:red; color:white;\">"+clearHtml(sbResults.toString())+"</textarea>");
				else 
					sbFinal.append("<textarea readonly rows=1 style=\"width:100%; background-color:darkgreen; color:white;\">"+clearHtml(sbResults.toString())+"</textarea>");
				
				sbFinal.append("<b>Execution Logs :</b><br>");
				sbFinal.append("<textarea readonly rows=2 style=\"width:100%; background-color:black; color:white;\">"+clearHtml(sbLogs.toString())+"</textarea>");

				
				if (isSuccess) {
					session.setAttribute("tested_session_validated_script_"+build_script_field+"_of_"+session_validation_id, "YES");
					
					html=sbFinal.toString();
					msg="ok";	
				} else {
					session.setAttribute("tested_session_validated_script_"+build_script_field+"_of_"+session_validation_id, "NO");
					
					html=sbFinal.toString();
					msg="nok:Can not be saved since the script seems invalid!";	
				}
						
				
			}
			
			
			//**********************************************
			//make_edit_test_js_param_list
			//**********************************************
			if (action.equals("make_edit_test_js_param_list")) {
				String session_validation_id=par1;
				String script_field=par2;
				String building_script=decrypt(par3);
				
				html=makeEditTestJSParamList(conn,session, session_validation_id, script_field, building_script); 
				msg="ok";			
				
			}
			
			//**********************************************
			//set_js_test_param
			//**********************************************
			if (action.equals("set_js_test_param")) {
				String param_name=par1;
				String param_val=decrypt(par2);
				
				setJSTestParamVal(conn, session, param_name, param_val);
				
				html="-";
				msg="ok";			
				
			}
			
			//**********************************************
			//remove_session_validation_script
			//**********************************************
			if (action.equals("remove_session_validation_script")) {
				String session_validation_id=par1;
				String script_field_name=par2; //build_script_field
				String field_value="";
				
				updateMadTableField(conn,session,"tdm_proxy_session_validation",session_validation_id, script_field_name, field_value);
				 
				html="-";
				msg="ok:javascript:scriptSaved(); makeSessionValidationEditor('"+session_validation_id+"')";	
				
					
				
			}
			
			
			//**********************************************
			//make_monitoring_policy_group_editor
			//**********************************************
			if (action.equals("make_monitoring_policy_group_editor")) {
				String monitoring_id=par1;
				
				html=makeMonitoringPolicyGroupEditor(conn, session, monitoring_id); 
				msg="ok";			
				
			}
			//**********************************************
			//make_monitoring_application_editor
			//**********************************************
			if (action.equals("make_monitoring_application_editor")) {
				String monitoring_id=par1;
				
				html=makeMonitoringApplicationEditor(conn, session, monitoring_id); 
				msg="ok";			
				
			}
			//**********************************************
			//make_monitoring_columns_editor
			//**********************************************
			if (action.equals("make_monitoring_columns_editor")) {
				String monitoring_id=par1;
				
				html=makeMonitoringColumnsEditor(conn, session, monitoring_id); 
				msg="ok";			
				
			}
			//**********************************************
			//make_monitoring_expressions_editor
			//**********************************************
			if (action.equals("make_monitoring_expressions_editor")) {
				String monitoring_id=par1;
				
				html=makeMonitoringExpressionsEditor(conn, session, monitoring_id); 
				msg="ok";			
				
			}
			//**********************************************
			//update_monitoring_policy_group
			//**********************************************
			if (action.equals("update_monitoring_policy_group")) {
				String monitoring_id=par1;
				String policy_group_id=par2; 
				String method=par3;
				
				updateMonitoringPolicyGroup(conn,session,monitoring_id,policy_group_id,method); 
				 
				html="-";
				msg="ok:javascript:makeMonitoringPolicyGroupEditor('"+monitoring_id+"')";	
				
					
				
			}
			
			
			//**********************************************
			//update_monitoring_application
			//**********************************************
			if (action.equals("update_monitoring_application")) {
				String monitoring_id=par1;
				String app_id=par2; 
				String method=par3;
				
				updateMonitoringApplication(conn,session,monitoring_id,app_id,method); 
				 
				html="-";
				msg="ok:javascript:makeMonitoringApplicationEditor('"+monitoring_id+"')";	
				
					
				
			}
			
			//**********************************************
			//manage_proxy_blacklist
			//**********************************************
			if (action.equals("manage_proxy_blacklist")) {

				String proxy_id=par1;
				
				html=makeManageBlacklistDialog(conn,session, proxy_id);  
				msg="ok";			
				
			}
			
			//**********************************************
			//list_black_list
			//**********************************************
			if (action.equals("list_black_list")) {

				String proxy_id=par1;
				String searchtext=decrypt(par2);
				String only_active=par3;

				
				html=listBlacklist(conn,session, proxy_id,searchtext,only_active);  
				msg="ok";			
				
			}



			htmlArr.add(html);
			divArr.add(div); 
			
			if (action.length()>0) {
				obj.put("html"+(a+1), htmlArr.get(a));
				obj.put("div"+(a+1), divArr.get(a));		
			}
			
			html="";
			div="";
	
	} //for (int a=0;a<arr_action.length;a++

	obj.put("msg", msg);

} 
catch(Exception e) {
	e.printStackTrace();
}
finally {closeconn(conn);} 


		
try{ out.print(obj);   out.flush();} catch(IOException e) {	e.printStackTrace();  } 

%>

