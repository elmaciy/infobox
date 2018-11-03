package com.mayatech.datamodel;

import java.sql.Connection;
import java.util.ArrayList;

import com.mayatech.dm.ddmLib;

public class dmModelForDM {
	
	
	
	ArrayList<dmTable> tableList=new ArrayList<dmTable>();
	
	public dmModelForDM() {
		loadTableList();
	}
	
	
	//-----------------------------------------------------------------------------------------------------------------------------------------
	void loadTableList() {
		String table_name="";
		String engine="";

		//table.columnList.add(new dmColumn(column_name, column_type, size, default_value, isPK, nullable, auto_increment));

		//----------------------------------------------
		//tdm_test_123
		//----------------------------------------------
		table_name="tdm_test_123";
		engine="InnoDB";
		dmTable tdm_test_123=new dmTable(table_name,engine);
		tdm_test_123.columnList.add(new dmColumn("id","int",11,"",true,true,true));
		tdm_test_123.columnList.add(new dmColumn("session_validation_name","varchar",200,"NULL",false,true,false));
		tdm_test_123.columnList.add(new dmColumn("controll_method","varchar",3,"YES",false,true,false));
		tdm_test_123.columnList.add(new dmColumn("creation_time","datetime",0, "CURRENT_TIMESTAMP",false,false,false));
		tdm_test_123.indexList.add(new dmIndex("ndx_tdm_test_123_name", "session_validation_name"));
		tableList.add(tdm_test_123);
		
		
		//-------------------------------------------
		//mad_application
		//-------------------------------------------
		table_name="mad_application";
		engine="InnoDB";
		dmTable mad_application=new dmTable(table_name,engine);
		mad_application.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_application.columnList.add(new dmColumn("application_name","varchar",100,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("repository_id","int",11,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("build_driver_id","int",11,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("deploy_driver_id","int",11,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("pre_deploy_method_id","int",11,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("post_deploy_method_id","int",11,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("platform_type_id","int",11,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("app_repo_root","text",0,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("app_repo_policy","varchar",20,"APP_REPO_ROOT",false,true,false));
		mad_application.columnList.add(new dmColumn("app_repo_filter","text",0,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("is_valid","varchar",3,"YES",false,true,false));
		mad_application.columnList.add(new dmColumn("app_repo_tag_path","text",0,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("app_repo_tag_filter","text",0,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("permission","int",11,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("conflict_level","int",1,"1",false,true,false));
		mad_application.columnList.add(new dmColumn("app_repo_script","text",0,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("export_type","varchar",10,"FILE",false,true,false));
		mad_application.columnList.add(new dmColumn("item_repo_selection_type","varchar",10,"FILE",false,true,false));
		mad_application.columnList.add(new dmColumn("prevent_older_version","varchar",3,"NO",false,true,false));
		mad_application.columnList.add(new dmColumn("version_calculation_script","text",0,"NULL",false,true,false));
		mad_application.columnList.add(new dmColumn("item_view_script","text",0,"NULL",false,true,false));
		tableList.add(mad_application);

		//-------------------------------------------
		//mad_application_dependency
		//-------------------------------------------
		table_name="mad_application_dependency";
		engine="InnoDB";
		dmTable mad_application_dependency=new dmTable(table_name,engine);
		mad_application_dependency.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_application_dependency.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		mad_application_dependency.columnList.add(new dmColumn("depended_application_id","int",11,"NULL",false,true,false));
		tableList.add(mad_application_dependency);

		//-------------------------------------------
		//mad_application_flex_fields
		//-------------------------------------------
		table_name="mad_application_flex_fields";
		engine="InnoDB";
		dmTable mad_application_flex_fields=new dmTable(table_name,engine);
		mad_application_flex_fields.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_application_flex_fields.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		mad_application_flex_fields.columnList.add(new dmColumn("field_parameter_name","varchar",200,"NULL",false,true,false));
		mad_application_flex_fields.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		mad_application_flex_fields.columnList.add(new dmColumn("default_value","text",0,"NULL",false,true,false));
		mad_application_flex_fields.columnList.add(new dmColumn("is_mandatory","varchar",3,"NO",false,true,false));
		mad_application_flex_fields.columnList.add(new dmColumn("is_editable","varchar",3,"YES",false,true,false));
		mad_application_flex_fields.columnList.add(new dmColumn("is_visible","varchar",3,"YES",false,true,false));
		mad_application_flex_fields.columnList.add(new dmColumn("field_order","int",4,"0",false,true,false));
		tableList.add(mad_application_flex_fields);

		//-------------------------------------------
		//mad_checkout_log
		//-------------------------------------------
		table_name="mad_checkout_log";
		engine="InnoDB";
		dmTable mad_checkout_log=new dmTable(table_name,engine);
		mad_checkout_log.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_checkout_log.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("member_id","int",11,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("member_path","varchar",200,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("member_version","varchar",100,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("status","varchar",10,"OPEN",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("repository_id","int",11,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("check_out_user_info","varchar",200,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("check_out_machine_info","varchar",200,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("check_out_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_checkout_log.columnList.add(new dmColumn("check_in_user_info","varchar",200,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("check_in_machine_info","varchar",200,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("check_in_date","timestamp",0,"0000-00-00 00:00:00",false,false,false));
		mad_checkout_log.columnList.add(new dmColumn("check_in_note","text",0,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("check_out_code","longtext",0,"NULL",false,true,false));
		mad_checkout_log.columnList.add(new dmColumn("check_in_code","longtext",0,"NULL",false,true,false));
		tableList.add(mad_checkout_log);

		//-------------------------------------------
		//mad_class
		//-------------------------------------------
		table_name="mad_class";
		engine="InnoDB";
		dmTable mad_class=new dmTable(table_name,engine);
		mad_class.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_class.columnList.add(new dmColumn("class_name","varchar",200,"NULL",false,true,false));
		mad_class.columnList.add(new dmColumn("class_desc","varchar",200,"NULL",false,true,false));
		mad_class.columnList.add(new dmColumn("class_type","varchar",10,"REPO",false,true,false));
		tableList.add(mad_class);

		//-------------------------------------------
		//mad_dashboard_parameter
		//-------------------------------------------
		table_name="mad_dashboard_parameter";
		engine="InnoDB";
		dmTable mad_dashboard_parameter=new dmTable(table_name,engine);
		mad_dashboard_parameter.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_dashboard_parameter.columnList.add(new dmColumn("parameter_title","varchar",200,"NULL",false,true,false));
		mad_dashboard_parameter.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		mad_dashboard_parameter.columnList.add(new dmColumn("field_parameter_name","varchar",200,"NULL",false,true,false));
		mad_dashboard_parameter.columnList.add(new dmColumn("sql_statement","text",0,"NULL",false,true,false));
		mad_dashboard_parameter.columnList.add(new dmColumn("bind_type","varchar",20,"STRING",false,true,false));
		tableList.add(mad_dashboard_parameter);

		//-------------------------------------------
		//mad_dashboard_sql
		//-------------------------------------------
		table_name="mad_dashboard_sql";
		engine="InnoDB";
		dmTable mad_dashboard_sql=new dmTable(table_name,engine);
		mad_dashboard_sql.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_dashboard_sql.columnList.add(new dmColumn("sql_name","varchar",200,"NULL",false,true,false));
		mad_dashboard_sql.columnList.add(new dmColumn("query_statement","text",0,"NULL",false,true,false));
		tableList.add(mad_dashboard_sql);

		//-------------------------------------------
		//mad_dashboard_user_configuration
		//-------------------------------------------
		table_name="mad_dashboard_user_configuration";
		engine="InnoDB";
		dmTable mad_dashboard_user_configuration=new dmTable(table_name,engine);
		mad_dashboard_user_configuration.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_dashboard_user_configuration.columnList.add(new dmColumn("user_id","int",11,"NULL",false,true,false));
		mad_dashboard_user_configuration.columnList.add(new dmColumn("divid","varchar",200,"NULL",false,true,false));
		mad_dashboard_user_configuration.columnList.add(new dmColumn("view_id","int",11,"NULL",false,true,false));
		mad_dashboard_user_configuration.columnList.add(new dmColumn("report_title","varchar",1000,"NULL",false,true,false));
		mad_dashboard_user_configuration.columnList.add(new dmColumn("parameters","text",0,"NULL",false,true,false));
		mad_dashboard_user_configuration.columnList.add(new dmColumn("refresh_interval","varchar",20,"MINUTE",false,true,false));
		mad_dashboard_user_configuration.columnList.add(new dmColumn("refresh_by","int",5,"10",false,true,false));
		mad_dashboard_user_configuration.columnList.add(new dmColumn("send_notification","varchar",3,"NO",false,true,false));
		mad_dashboard_user_configuration.columnList.add(new dmColumn("notification_groups","varchar",1000,"NULL",false,true,false));
		mad_dashboard_user_configuration.columnList.add(new dmColumn("height","int",5,"240",false,true,false));
		tableList.add(mad_dashboard_user_configuration);

		//-------------------------------------------
		//mad_dashboard_view
		//-------------------------------------------
		table_name="mad_dashboard_view";
		engine="InnoDB";
		dmTable mad_dashboard_view=new dmTable(table_name,engine);
		mad_dashboard_view.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_dashboard_view.columnList.add(new dmColumn("view_name","varchar",200,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("view_type","varchar",20,"RAW",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("short_code","varchar",100,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("sql_id","int",11,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("sql_filter","text",0,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("env_id","int",11,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("order_by","varchar",200,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("permission_id","int",11,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("field_list","text",0,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("title_list","text",0,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("color_list","text",0,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("group_by","varchar",1000,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("x_field","varchar",200,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("y_field","varchar",200,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("sum_field","varchar",200,"NULL",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("sum_function","varchar",10,"SUM",false,true,false));
		mad_dashboard_view.columnList.add(new dmColumn("decimal_size","int",5,"0",false,true,false));
		tableList.add(mad_dashboard_view);

		//-------------------------------------------
		//mad_dashboard_view_parameter
		//-------------------------------------------
		table_name="mad_dashboard_view_parameter";
		engine="InnoDB";
		dmTable mad_dashboard_view_parameter=new dmTable(table_name,engine);
		mad_dashboard_view_parameter.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_dashboard_view_parameter.columnList.add(new dmColumn("view_id","int",11,"NULL",false,true,false));
		mad_dashboard_view_parameter.columnList.add(new dmColumn("parameter_id","int",11,"NULL",false,true,false));
		tableList.add(mad_dashboard_view_parameter);

		//-------------------------------------------
		//mad_deployment_slot
		//-------------------------------------------
		table_name="mad_deployment_slot";
		engine="InnoDB";
		dmTable mad_deployment_slot=new dmTable(table_name,engine);
		mad_deployment_slot.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_deployment_slot.columnList.add(new dmColumn("slot_type","varchar",20,"DAILY",false,true,false));
		mad_deployment_slot.columnList.add(new dmColumn("slot_name","varchar",200,"NULL",false,true,false));
		mad_deployment_slot.columnList.add(new dmColumn("is_valid","varchar",3,"YES",false,true,false));
		mad_deployment_slot.columnList.add(new dmColumn("freeze_period","int",5,"0",false,true,false));
		mad_deployment_slot.columnList.add(new dmColumn("freeze_period_after","int",5,"0",false,true,false));
		tableList.add(mad_deployment_slot);

		//-------------------------------------------
		//mad_deployment_slot_detail
		//-------------------------------------------
		table_name="mad_deployment_slot_detail";
		engine="InnoDB";
		dmTable mad_deployment_slot_detail=new dmTable(table_name,engine);
		mad_deployment_slot_detail.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_deployment_slot_detail.columnList.add(new dmColumn("slot_id","varchar",20,"DAILY",false,true,false));
		mad_deployment_slot_detail.columnList.add(new dmColumn("slot_name","varchar",200,"NULL",false,true,false));
		mad_deployment_slot_detail.columnList.add(new dmColumn("slot_description","text",0,"NULL",false,true,false));
		mad_deployment_slot_detail.columnList.add(new dmColumn("hourly_day_id","int",2,"-1",false,true,false));
		mad_deployment_slot_detail.columnList.add(new dmColumn("hourly_minute_id","int",4,"-1",false,true,false));
		mad_deployment_slot_detail.columnList.add(new dmColumn("daily_time","timestamp",0,"NULL",false,true,false));
		mad_deployment_slot_detail.columnList.add(new dmColumn("is_valid","varchar",3,"YES",false,true,false));
		tableList.add(mad_deployment_slot_detail);

		//-------------------------------------------
		//mad_driver
		//-------------------------------------------
		table_name="mad_driver";
		engine="InnoDB";
		dmTable mad_driver=new dmTable(table_name,engine);
		mad_driver.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_driver.columnList.add(new dmColumn("driver_name","varchar",100,"NULL",false,true,false));
		mad_driver.columnList.add(new dmColumn("class_name","varchar",200,"NULL",false,true,false));
		mad_driver.columnList.add(new dmColumn("driver_type","varchar",10,"NULL",false,true,false));
		mad_driver.columnList.add(new dmColumn("success_keyword","varchar",1000,"NULL",false,true,false));
		tableList.add(mad_driver);

		//-------------------------------------------
		//mad_email_template
		//-------------------------------------------
		table_name="mad_email_template";
		engine="InnoDB";
		dmTable mad_email_template=new dmTable(table_name,engine);
		mad_email_template.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_email_template.columnList.add(new dmColumn("template_name","varchar",100,"NULL",false,true,false));
		mad_email_template.columnList.add(new dmColumn("email_subject","varchar",255,"NULL",false,true,false));
		mad_email_template.columnList.add(new dmColumn("email_body","text",0,"NULL",false,true,false));
		mad_email_template.columnList.add(new dmColumn("from_type","varchar",10,"FIXED",false,true,false));
		mad_email_template.columnList.add(new dmColumn("from_email","varchar",200,"NULL",false,true,false));
		mad_email_template.columnList.add(new dmColumn("from_name","varchar",200,"NULL",false,true,false));
		tableList.add(mad_email_template);

		//-------------------------------------------
		//mad_environment
		//-------------------------------------------
		table_name="mad_environment";
		engine="InnoDB";
		dmTable mad_environment=new dmTable(table_name,engine);
		mad_environment.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_environment.columnList.add(new dmColumn("environment_name","varchar",100,"NULL",false,true,false));
		mad_environment.columnList.add(new dmColumn("permission","int",11,"NULL",false,true,false));
		mad_environment.columnList.add(new dmColumn("on_error_action","varchar",20,"CONTINUE",false,true,false));
		mad_environment.columnList.add(new dmColumn("deployment_slot_id","int",11,"NULL",false,true,false));
		tableList.add(mad_environment);

		//-------------------------------------------
		//mad_flex_field
		//-------------------------------------------
		table_name="mad_flex_field";
		engine="InnoDB";
		dmTable mad_flex_field=new dmTable(table_name,engine);
		mad_flex_field.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_flex_field.columnList.add(new dmColumn("title","varchar",100,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("string_name","varchar",200,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("entry_type","varchar",20,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("entry_validation_regex","varchar",200,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("is_validated","varchar",3,"NO",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("validation_sql","text",0,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("validation_env_id","int",11,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("field_size","int",5,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("tab_request_type_id","int",11,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("tab_delete_allowed","varchar",3,"YES",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("num_fixed_length","int",2,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("num_decimal_length","int",2,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("num_grouping_char","varchar",1,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("num_decimal_char","varchar",1,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("num_currency_symbol","varchar",10,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("num_min_val","double",0,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("num_max_val","double",0,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("calc_data_type","varchar",10,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("calc_display_type","varchar",10,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("calc_display_format","varchar",200,"NULL",false,true,false));
		mad_flex_field.columnList.add(new dmColumn("calc_statement","text",0,"NULL",false,true,false));
		tableList.add(mad_flex_field);

		//-------------------------------------------
		//mad_flow
		//-------------------------------------------
		table_name="mad_flow";
		engine="InnoDB";
		dmTable mad_flow=new dmTable(table_name,engine);
		mad_flow.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_flow.columnList.add(new dmColumn("flow_name","varchar",200,"NULL",false,true,false));
		mad_flow.columnList.add(new dmColumn("flow_description","text",0,"NULL",false,true,false));
		mad_flow.columnList.add(new dmColumn("email_template_id","int",11,"NULL",false,true,false));
		tableList.add(mad_flow);

		//-------------------------------------------
		//mad_flow_state
		//-------------------------------------------
		table_name="mad_flow_state";
		engine="InnoDB";
		dmTable mad_flow_state=new dmTable(table_name,engine);
		mad_flow_state.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_flow_state.columnList.add(new dmColumn("flow_id","int",11,"NULL",false,true,false));
		mad_flow_state.columnList.add(new dmColumn("state_type","varchar",10,"STATIC",false,true,false));
		mad_flow_state.columnList.add(new dmColumn("state_stage","varchar",20,"NULL",false,true,false));
		mad_flow_state.columnList.add(new dmColumn("state_name","varchar",100,"NULL",false,true,false));
		mad_flow_state.columnList.add(new dmColumn("state_title","varchar",100,"NULL",false,true,false));
		mad_flow_state.columnList.add(new dmColumn("state_description","text",0,"NULL",false,true,false));
		mad_flow_state.columnList.add(new dmColumn("loc_y","int",10,"NULL",false,true,false));
		mad_flow_state.columnList.add(new dmColumn("loc_x","int",10,"NULL",false,true,false));
		tableList.add(mad_flow_state);

		//-------------------------------------------
		//mad_flow_state_action
		//-------------------------------------------
		table_name="mad_flow_state_action";
		engine="InnoDB";
		dmTable mad_flow_state_action=new dmTable(table_name,engine);
		mad_flow_state_action.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_flow_state_action.columnList.add(new dmColumn("flow_state_id","int",11,"NULL",false,true,false));
		mad_flow_state_action.columnList.add(new dmColumn("action_type","varchar",10,"SYSTEM",false,true,false));
		mad_flow_state_action.columnList.add(new dmColumn("action_name","varchar",100,"NULL",false,true,false));
		mad_flow_state_action.columnList.add(new dmColumn("action_description","text",0,"NULL",false,true,false));
		mad_flow_state_action.columnList.add(new dmColumn("next_state_id","int",11,"NULL",false,true,false));
		mad_flow_state_action.columnList.add(new dmColumn("email_template_id","int",11,"NULL",false,true,false));
		mad_flow_state_action.columnList.add(new dmColumn("repository_action","varchar",10,"NONE",false,true,false));
		tableList.add(mad_flow_state_action);

		//-------------------------------------------
		//mad_flow_state_action_groups
		//-------------------------------------------
		table_name="mad_flow_state_action_groups";
		engine="InnoDB";
		dmTable mad_flow_state_action_groups=new dmTable(table_name,engine);
		mad_flow_state_action_groups.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_flow_state_action_groups.columnList.add(new dmColumn("flow_state_action_id","int",11,"NULL",false,true,false));
		mad_flow_state_action_groups.columnList.add(new dmColumn("group_id","int",11,"NULL",false,true,false));
		tableList.add(mad_flow_state_action_groups);

		//-------------------------------------------
		//mad_flow_state_action_methods
		//-------------------------------------------
		table_name="mad_flow_state_action_methods";
		engine="InnoDB";
		dmTable mad_flow_state_action_methods=new dmTable(table_name,engine);
		mad_flow_state_action_methods.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_flow_state_action_methods.columnList.add(new dmColumn("flow_state_action_id","int",11,"NULL",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("execution_order","int",3,"1",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("execution_type","varchar",10,"SYNCH",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("is_valid","varchar",3,"YES",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("retry_count","int",5,"0",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("on_fail","varchar",10,"STOP",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("method_id","int",11,"NULL",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("value_1","varchar",1000,"NULL",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("value_2","varchar",1000,"NULL",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("value_3","varchar",1000,"NULL",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("value_4","varchar",1000,"NULL",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("value_5","varchar",1000,"NULL",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("value_6","varchar",1000,"NULL",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("value_7","varchar",1000,"NULL",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("value_8","varchar",1000,"NULL",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("value_9","varchar",1000,"NULL",false,true,false));
		mad_flow_state_action_methods.columnList.add(new dmColumn("value_10","varchar",1000,"NULL",false,true,false));
		tableList.add(mad_flow_state_action_methods);

		//-------------------------------------------
		//mad_flow_state_action_permissions
		//-------------------------------------------
		table_name="mad_flow_state_action_permissions";
		engine="InnoDB";
		dmTable mad_flow_state_action_permissions=new dmTable(table_name,engine);
		mad_flow_state_action_permissions.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_flow_state_action_permissions.columnList.add(new dmColumn("flow_state_action_id","int",11,"NULL",false,true,false));
		mad_flow_state_action_permissions.columnList.add(new dmColumn("permission_id","int",11,"NULL",false,true,false));
		tableList.add(mad_flow_state_action_permissions);

		//-------------------------------------------
		//mad_flow_state_edit_permissions
		//-------------------------------------------
		table_name="mad_flow_state_edit_permissions";
		engine="InnoDB";
		dmTable mad_flow_state_edit_permissions=new dmTable(table_name,engine);
		mad_flow_state_edit_permissions.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_flow_state_edit_permissions.columnList.add(new dmColumn("flow_state_id","int",11,"NULL",false,true,false));
		mad_flow_state_edit_permissions.columnList.add(new dmColumn("permission_id","int",11,"NULL",false,true,false));
		tableList.add(mad_flow_state_edit_permissions);

		//-------------------------------------------
		//mad_generic_history
		//-------------------------------------------
		table_name="mad_generic_history";
		engine="InnoDB";
		dmTable mad_generic_history=new dmTable(table_name,engine);
		mad_generic_history.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_generic_history.columnList.add(new dmColumn("table_name","varchar",50,"NULL",false,true,false));
		mad_generic_history.columnList.add(new dmColumn("table_id","int",11,"NULL",false,true,false));
		mad_generic_history.columnList.add(new dmColumn("change_id","int",11,"NULL",false,true,false));
		mad_generic_history.columnList.add(new dmColumn("field_name","varchar",1000,"NULL",false,true,false));
		mad_generic_history.columnList.add(new dmColumn("field_value","varchar",1000,"NULL",false,true,false));
		mad_generic_history.columnList.add(new dmColumn("history_action","varchar",10,"NULL",false,true,false));
		mad_generic_history.columnList.add(new dmColumn("history_user","int",11,"NULL",false,true,false));
		mad_generic_history.columnList.add(new dmColumn("history_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_generic_history.columnList.add(new dmColumn("history_host","varchar",100,"NULL",false,true,false));
		tableList.add(mad_generic_history);

		//-------------------------------------------
		//mad_group
		//-------------------------------------------
		table_name="mad_group";
		engine="InnoDB";
		dmTable mad_group=new dmTable(table_name,engine);
		mad_group.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_group.columnList.add(new dmColumn("group_type","varchar",20,"USER",false,true,false));
		mad_group.columnList.add(new dmColumn("group_name","varchar",200,"NULL",false,true,false));
		mad_group.columnList.add(new dmColumn("common_email_address","varchar",200,"NULL",false,true,false));
		mad_group.columnList.add(new dmColumn("manager_user_id","int",11,"NULL",false,true,false));
		mad_group.columnList.add(new dmColumn("group_description","text",0,"NULL",false,true,false));
		tableList.add(mad_group);

		//-------------------------------------------
		//mad_group_members
		//-------------------------------------------
		table_name="mad_group_members";
		engine="InnoDB";
		dmTable mad_group_members=new dmTable(table_name,engine);
		mad_group_members.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_group_members.columnList.add(new dmColumn("group_id","int",11,"NULL",false,true,false));
		mad_group_members.columnList.add(new dmColumn("member_id","int",11,"NULL",false,true,false));
		mad_group_members.columnList.add(new dmColumn("member_type","varchar",10,"USER",false,true,false));
		mad_group_members.columnList.add(new dmColumn("group_membership_description","text",0,"NULL",false,true,false));
		tableList.add(mad_group_members);

		//-------------------------------------------
		//mad_group_permission
		//-------------------------------------------
		table_name="mad_group_permission";
		engine="InnoDB";
		dmTable mad_group_permission=new dmTable(table_name,engine);
		mad_group_permission.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_group_permission.columnList.add(new dmColumn("group_id","int",11,"NULL",false,true,false));
		mad_group_permission.columnList.add(new dmColumn("permission_id","int",11,"NULL",false,true,false));
		tableList.add(mad_group_permission);

		//-------------------------------------------
		//mad_keywords
		//-------------------------------------------
		table_name="mad_keywords";
		engine="InnoDB";
		dmTable mad_keywords=new dmTable(table_name,engine);
		mad_keywords.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_keywords.columnList.add(new dmColumn("object_type","varchar",100,"NULL",false,true,false));
		mad_keywords.columnList.add(new dmColumn("object_id","int",11,"NULL",false,true,false));
		mad_keywords.columnList.add(new dmColumn("keywords","mediumtext",0,"NULL",false,true,false));
		tableList.add(mad_keywords);

		//-------------------------------------------
		//mad_lang
		//-------------------------------------------
		table_name="mad_lang";
		engine="InnoDB";
		dmTable mad_lang=new dmTable(table_name,engine);
		mad_lang.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_lang.columnList.add(new dmColumn("lang","varchar",20,"NULL",false,true,false));
		mad_lang.columnList.add(new dmColumn("lang_desc","varchar",200,"NULL",false,true,false));
		tableList.add(mad_lang);

		//-------------------------------------------
		//mad_method
		//-------------------------------------------
		table_name="mad_method";
		engine="InnoDB";
		dmTable mad_method=new dmTable(table_name,engine);
		mad_method.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_method.columnList.add(new dmColumn("method_name","varchar",200,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("method_description","text",0,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("method_type","varchar",20,"JAVASCRIPT",false,true,false));
		mad_method.columnList.add(new dmColumn("is_valid","varchar",3,"YES",false,true,false));
		mad_method.columnList.add(new dmColumn("reflection_classname","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("reflection_methodname","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("source_code","text",0,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("database_id","int",11,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("start_directory","varchar",200,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("success_keyword","varchar",2000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("parameter_count","int",3,"1",false,true,false));
		mad_method.columnList.add(new dmColumn("param_default_val_1","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_default_val_2","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_default_val_3","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_default_val_4","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_default_val_5","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_default_val_6","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_default_val_7","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_default_val_8","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_default_val_9","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_default_val_10","varchar",1000,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_type_1","varchar",20,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_type_2","varchar",20,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_type_3","varchar",20,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_type_4","varchar",20,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_type_5","varchar",20,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_type_6","varchar",20,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_type_7","varchar",20,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_type_8","varchar",20,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_type_9","varchar",20,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_type_10","varchar",20,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_name_1","varchar",200,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_name_2","varchar",200,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_name_3","varchar",200,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_name_4","varchar",200,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_name_5","varchar",200,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_name_6","varchar",200,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_name_7","varchar",200,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_name_8","varchar",200,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_name_9","varchar",200,"NULL",false,true,false));
		mad_method.columnList.add(new dmColumn("param_name_10","varchar",200,"NULL",false,true,false));
		tableList.add(mad_method);

		//-------------------------------------------
		//mad_method_call_logs
		//-------------------------------------------
		table_name="mad_method_call_logs";
		engine="InnoDB";
		dmTable mad_method_call_logs=new dmTable(table_name,engine);
		mad_method_call_logs.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_method_call_logs.columnList.add(new dmColumn("request_flow_logs_id","int",11,"NULL",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("token","varchar",100,"NULL",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("flow_state_action_id","int",11,"NULL",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("method_id","int",11,"NULL",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("action_method_id","int",11,"NULL",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("status","varchar",10,"STOP",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("last_execution_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_method_call_logs.columnList.add(new dmColumn("attempt_no","int",5,"1",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("executable","text",0,"NULL",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("parameters","text",0,"NULL",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("duration","int",11,"NULL",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("execution_result","text",0,"NULL",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("execution_log","text",0,"NULL",false,true,false));
		mad_method_call_logs.columnList.add(new dmColumn("entdate","timestamp",0,"0000-00-00 00:00:00",false,false,false));
		tableList.add(mad_method_call_logs);

		//-------------------------------------------
		//mad_modifier_group
		//-------------------------------------------
		table_name="mad_modifier_group";
		engine="InnoDB";
		dmTable mad_modifier_group=new dmTable(table_name,engine);
		mad_modifier_group.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_modifier_group.columnList.add(new dmColumn("modifier_group_name","varchar",200,"NULL",false,true,false));
		tableList.add(mad_modifier_group);

		//-------------------------------------------
		//mad_modifier_rule
		//-------------------------------------------
		table_name="mad_modifier_rule";
		engine="InnoDB";
		dmTable mad_modifier_rule=new dmTable(table_name,engine);
		mad_modifier_rule.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_modifier_rule.columnList.add(new dmColumn("modifier_group_id","int",11,"NULL",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("modifier_name","varchar",200,"NULL",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("modifier_order","int",5,"NULL",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("is_valid","varchar",3,"YES",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("rule_locator_type","varchar",20,"NULL",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("rule_locator_statement","varchar",400,"NULL",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("rule_locator_options","varchar",400,"NULL",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("rule_changer_action","varchar",400,"NULL",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("rule_changer_statement","text",0,"NULL",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("rule_changer_options","varchar",400,"NULL",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("when_value_to_check","varchar",1000,"NULL",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("when_operand","varchar",10,"NULL",false,true,false));
		mad_modifier_rule.columnList.add(new dmColumn("when_values","varchar",1000,"NULL",false,true,false));
		tableList.add(mad_modifier_rule);

		//-------------------------------------------
		//mad_permission
		//-------------------------------------------
		table_name="mad_permission";
		engine="InnoDB";
		dmTable mad_permission=new dmTable(table_name,engine);
		mad_permission.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_permission.columnList.add(new dmColumn("permission_name","varchar",200,"NULL",false,true,false));
		mad_permission.columnList.add(new dmColumn("permission_level","varchar",10,"USER",false,true,false));
		mad_permission.columnList.add(new dmColumn("permission_description","text",0,"NULL",false,true,false));
		tableList.add(mad_permission);

		//-------------------------------------------
		//mad_platform
		//-------------------------------------------
		table_name="mad_platform";
		engine="InnoDB";
		dmTable mad_platform=new dmTable(table_name,engine);
		mad_platform.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_platform.columnList.add(new dmColumn("platform_type_id","int",11,"NULL",false,true,false));
		mad_platform.columnList.add(new dmColumn("platform_name","varchar",100,"NULL",false,true,false));
		mad_platform.columnList.add(new dmColumn("edit_permission_id","int",11,"NULL",false,true,false));
		mad_platform.columnList.add(new dmColumn("on_error_action","varchar",20,"CONTINUE",false,true,false));
		tableList.add(mad_platform);

		//-------------------------------------------
		//mad_platform_env
		//-------------------------------------------
		table_name="mad_platform_env";
		engine="InnoDB";
		dmTable mad_platform_env=new dmTable(table_name,engine);
		mad_platform_env.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_platform_env.columnList.add(new dmColumn("platform_id","int",11,"NULL",false,true,false));
		mad_platform_env.columnList.add(new dmColumn("environment_id","int",11,"NULL",false,true,false));
		tableList.add(mad_platform_env);

		//-------------------------------------------
		//mad_platform_fields
		//-------------------------------------------
		table_name="mad_platform_fields";
		engine="InnoDB";
		dmTable mad_platform_fields=new dmTable(table_name,engine);
		mad_platform_fields.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_platform_fields.columnList.add(new dmColumn("platform_id","int",11,"NULL",false,true,false));
		mad_platform_fields.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		mad_platform_fields.columnList.add(new dmColumn("field_value","text",0,"NULL",false,true,false));
		mad_platform_fields.columnList.add(new dmColumn("entuser","int",11,"NULL",false,true,false));
		mad_platform_fields.columnList.add(new dmColumn("entdate","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		tableList.add(mad_platform_fields);

		//-------------------------------------------
		//mad_platform_type
		//-------------------------------------------
		table_name="mad_platform_type";
		engine="InnoDB";
		dmTable mad_platform_type=new dmTable(table_name,engine);
		mad_platform_type.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_platform_type.columnList.add(new dmColumn("platform_type_name","varchar",100,"NULL",false,true,false));
		mad_platform_type.columnList.add(new dmColumn("deployment_type","varchar",10,"SERIAL",false,true,false));
		tableList.add(mad_platform_type);

		//-------------------------------------------
		//mad_platform_type_flex_fields
		//-------------------------------------------
		table_name="mad_platform_type_flex_fields";
		engine="InnoDB";
		dmTable mad_platform_type_flex_fields=new dmTable(table_name,engine);
		mad_platform_type_flex_fields.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_platform_type_flex_fields.columnList.add(new dmColumn("platform_type_id","int",11,"NULL",false,true,false));
		mad_platform_type_flex_fields.columnList.add(new dmColumn("field_parameter_name","varchar",200,"NULL",false,true,false));
		mad_platform_type_flex_fields.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		mad_platform_type_flex_fields.columnList.add(new dmColumn("default_value","text",0,"NULL",false,true,false));
		mad_platform_type_flex_fields.columnList.add(new dmColumn("is_mandatory","varchar",3,"NO",false,true,false));
		mad_platform_type_flex_fields.columnList.add(new dmColumn("is_editable","varchar",3,"NULL",false,true,false));
		mad_platform_type_flex_fields.columnList.add(new dmColumn("is_visible","varchar",3,"YES",false,true,false));
		mad_platform_type_flex_fields.columnList.add(new dmColumn("field_order","int",4,"0",false,true,false));
		tableList.add(mad_platform_type_flex_fields);

		//-------------------------------------------
		//mad_platform_type_modifier_group
		//-------------------------------------------
		table_name="mad_platform_type_modifier_group";
		engine="InnoDB";
		dmTable mad_platform_type_modifier_group=new dmTable(table_name,engine);
		mad_platform_type_modifier_group.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_platform_type_modifier_group.columnList.add(new dmColumn("platform_type_id","int",11,"NULL",false,true,false));
		mad_platform_type_modifier_group.columnList.add(new dmColumn("file_name","varchar",200,"NULL",false,true,false));
		mad_platform_type_modifier_group.columnList.add(new dmColumn("modifier_group_id","int",11,"NULL",false,true,false));
		mad_platform_type_modifier_group.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		mad_platform_type_modifier_group.columnList.add(new dmColumn("include_sub_folders","varchar",3,"NO",false,true,false));
		tableList.add(mad_platform_type_modifier_group);

		//-------------------------------------------
		//mad_query
		//-------------------------------------------
		table_name="mad_query";
		engine="InnoDB";
		dmTable mad_query=new dmTable(table_name,engine);
		mad_query.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_query.columnList.add(new dmColumn("query_name","varchar",200,"NULL",false,true,false));
		mad_query.columnList.add(new dmColumn("query_statement","text",0,"NULL",false,true,false));
		mad_query.columnList.add(new dmColumn("created_user","int",11,"0",false,true,false));
		mad_query.columnList.add(new dmColumn("query_user","int",11,"0",false,true,false));
		tableList.add(mad_query);

		//-------------------------------------------
		//mad_repository
		//-------------------------------------------
		table_name="mad_repository";
		engine="InnoDB";
		dmTable mad_repository=new dmTable(table_name,engine);
		mad_repository.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_repository.columnList.add(new dmColumn("repository_name","varchar",100,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("class_name","varchar",200,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("par_hostname","varchar",100,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("par_port","varchar",10,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("par_username","varchar",100,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("par_password","varchar",100,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("par_flex_1","text",0,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("par_flex_2","text",0,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("par_flex_3","text",0,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("par_flex_4","text",0,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("par_flex_5","text",0,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("par_flex_6","text",0,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("par_flex_7","text",0,"NULL",false,true,false));
		mad_repository.columnList.add(new dmColumn("is_valid","varchar",3,"YES",false,true,false));
		tableList.add(mad_repository);

		//-------------------------------------------
		//mad_request
		//-------------------------------------------
		table_name="mad_request";
		engine="InnoDB";
		dmTable mad_request=new dmTable(table_name,engine);
		mad_request.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request.columnList.add(new dmColumn("request_type_id","int",11,"NULL",false,true,false));
		mad_request.columnList.add(new dmColumn("is_saved","varchar",3,"NO",false,true,false));
		mad_request.columnList.add(new dmColumn("status","varchar",20,"NEW",false,true,false));
		mad_request.columnList.add(new dmColumn("description","varchar",400,"NULL",false,true,false));
		mad_request.columnList.add(new dmColumn("long_description","text",0,"NULL",false,true,false));
		mad_request.columnList.add(new dmColumn("entuser","int",11,"NULL",false,true,false));
		mad_request.columnList.add(new dmColumn("entdate","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_request.columnList.add(new dmColumn("deployment_slot_id","int",11,"NULL",false,true,false));
		mad_request.columnList.add(new dmColumn("deployment_slot_detail_id","int",11,"NULL",false,true,false));
		mad_request.columnList.add(new dmColumn("deployment_date","timestamp",0,"NULL",false,true,false));
		mad_request.columnList.add(new dmColumn("deployment_attempt_no","int",5,"0",false,true,false));
		tableList.add(mad_request);

		//-------------------------------------------
		//mad_request2
		//-------------------------------------------
		table_name="mad_request2";
		engine="InnoDB";
		dmTable mad_request2=new dmTable(table_name,engine);
		mad_request2.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request2.columnList.add(new dmColumn("request_type_id","int",11,"NULL",false,true,false));
		mad_request2.columnList.add(new dmColumn("is_saved","varchar",3,"NO",false,true,false));
		mad_request2.columnList.add(new dmColumn("status","varchar",20,"NEW",false,true,false));
		mad_request2.columnList.add(new dmColumn("description","varchar",400,"NULL",false,true,false));
		mad_request2.columnList.add(new dmColumn("long_description","text",0,"NULL",false,true,false));
		mad_request2.columnList.add(new dmColumn("entuser","int",11,"NULL",false,true,false));
		mad_request2.columnList.add(new dmColumn("entdate","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_request2.columnList.add(new dmColumn("deployment_slot_id","int",11,"NULL",false,true,false));
		mad_request2.columnList.add(new dmColumn("deployment_slot_detail_id","int",11,"NULL",false,true,false));
		mad_request2.columnList.add(new dmColumn("deployment_date","timestamp",0,"NULL",false,true,false));
		mad_request2.columnList.add(new dmColumn("deployment_attempt_no","int",5,"0",false,true,false));
		tableList.add(mad_request2);

		//-------------------------------------------
		//mad_request_application
		//-------------------------------------------
		table_name="mad_request_application";
		engine="InnoDB";
		dmTable mad_request_application=new dmTable(table_name,engine);
		mad_request_application.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_application.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_application.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		mad_request_application.columnList.add(new dmColumn("entuser","int",11,"NULL",false,true,false));
		mad_request_application.columnList.add(new dmColumn("entdate","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		tableList.add(mad_request_application);

		//-------------------------------------------
		//mad_request_application_member
		//-------------------------------------------
		table_name="mad_request_application_member";
		engine="InnoDB";
		dmTable mad_request_application_member=new dmTable(table_name,engine);
		mad_request_application_member.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_application_member.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("member_name","varchar",200,"NULL",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("member_path","text",0,"NULL",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("member_version","varchar",100,"NULL",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("member_order","int",5,"NULL",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("member_memo","text",0,"NULL",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("to_skip","varchar",3,"NO",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("skip_reason","varchar",20,"CANCELLED",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("status","varchar",10,"NULL",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("entuser","int",11,"NULL",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("entdate","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_request_application_member.columnList.add(new dmColumn("member_tag_info","varchar",100,"NULL",false,true,false));
		mad_request_application_member.columnList.add(new dmColumn("work_package_id","int",11,"0",false,true,false));
		tableList.add(mad_request_application_member);

		//-------------------------------------------
		//mad_request_application_member_history
		//-------------------------------------------
		table_name="mad_request_application_member_history";
		engine="InnoDB";
		dmTable mad_request_application_member_history=new dmTable(table_name,engine);
		mad_request_application_member_history.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_application_member_history.columnList.add(new dmColumn("request_application_member_id","int",11,"NULL",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("member_name","varchar",200,"NULL",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("member_path","text",0,"NULL",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("member_version","varchar",100,"NULL",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("member_order","int",5,"NULL",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("to_skip","varchar",3,"NO",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("skip_reason","varchar",20,"CANCELLED",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("member_tag_info","varchar",100,"NULL",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("history_action","varchar",10,"NULL",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("history_user","int",11,"NULL",false,true,false));
		mad_request_application_member_history.columnList.add(new dmColumn("history_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_request_application_member_history.columnList.add(new dmColumn("history_host","varchar",100,"NULL",false,true,false));
		tableList.add(mad_request_application_member_history);

		//-------------------------------------------
		//mad_request_app_env
		//-------------------------------------------
		table_name="mad_request_app_env";
		engine="InnoDB";
		dmTable mad_request_app_env=new dmTable(table_name,engine);
		mad_request_app_env.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_app_env.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_app_env.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		mad_request_app_env.columnList.add(new dmColumn("environment_id","int",11,"NULL",false,true,false));
		mad_request_app_env.columnList.add(new dmColumn("entuser","int",11,"NULL",false,true,false));
		mad_request_app_env.columnList.add(new dmColumn("entdate","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		tableList.add(mad_request_app_env);

		//-------------------------------------------
		//mad_request_app_env_history
		//-------------------------------------------
		table_name="mad_request_app_env_history";
		engine="InnoDB";
		dmTable mad_request_app_env_history=new dmTable(table_name,engine);
		mad_request_app_env_history.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_app_env_history.columnList.add(new dmColumn("request_app_env_id","int",11,"NULL",false,true,false));
		mad_request_app_env_history.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_app_env_history.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		mad_request_app_env_history.columnList.add(new dmColumn("environment_id","int",11,"NULL",false,true,false));
		mad_request_app_env_history.columnList.add(new dmColumn("history_action","varchar",10,"NULL",false,true,false));
		mad_request_app_env_history.columnList.add(new dmColumn("history_user","int",11,"NULL",false,true,false));
		mad_request_app_env_history.columnList.add(new dmColumn("history_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_request_app_env_history.columnList.add(new dmColumn("history_host","varchar",100,"NULL",false,true,false));
		tableList.add(mad_request_app_env_history);

		//-------------------------------------------
		//mad_request_attachment
		//-------------------------------------------
		table_name="mad_request_attachment";
		engine="InnoDB";
		dmTable mad_request_attachment=new dmTable(table_name,engine);
		mad_request_attachment.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_attachment.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_attachment.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		mad_request_attachment.columnList.add(new dmColumn("file_name","varchar",200,"NULL",false,true,false));
		mad_request_attachment.columnList.add(new dmColumn("file_size","int",11,"NULL",false,true,false));
		mad_request_attachment.columnList.add(new dmColumn("file_blob","longblob",0,"NULL",false,true,false));
		mad_request_attachment.columnList.add(new dmColumn("entuser","int",11,"NULL",false,true,false));
		mad_request_attachment.columnList.add(new dmColumn("entdate","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		tableList.add(mad_request_attachment);

		//-------------------------------------------
		//mad_request_env_fields
		//-------------------------------------------
		table_name="mad_request_env_fields";
		engine="InnoDB";
		dmTable mad_request_env_fields=new dmTable(table_name,engine);
		mad_request_env_fields.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_env_fields.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_env_fields.columnList.add(new dmColumn("environment_id","int",11,"NULL",false,true,false));
		mad_request_env_fields.columnList.add(new dmColumn("platform_id","int",11,"NULL",false,true,false));
		mad_request_env_fields.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		mad_request_env_fields.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		mad_request_env_fields.columnList.add(new dmColumn("field_value","text",0,"NULL",false,true,false));
		mad_request_env_fields.columnList.add(new dmColumn("entuser","int",11,"NULL",false,true,false));
		mad_request_env_fields.columnList.add(new dmColumn("entdate","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		tableList.add(mad_request_env_fields);

		//-------------------------------------------
		//mad_request_env_fields_history
		//-------------------------------------------
		table_name="mad_request_env_fields_history";
		engine="InnoDB";
		dmTable mad_request_env_fields_history=new dmTable(table_name,engine);
		mad_request_env_fields_history.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_env_fields_history.columnList.add(new dmColumn("request_env_fields_id","int",11,"NULL",false,true,false));
		mad_request_env_fields_history.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_env_fields_history.columnList.add(new dmColumn("environment_id","int",11,"NULL",false,true,false));
		mad_request_env_fields_history.columnList.add(new dmColumn("platform_id","int",11,"NULL",false,true,false));
		mad_request_env_fields_history.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		mad_request_env_fields_history.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		mad_request_env_fields_history.columnList.add(new dmColumn("field_value","text",0,"NULL",false,true,false));
		mad_request_env_fields_history.columnList.add(new dmColumn("history_action","varchar",10,"NULL",false,true,false));
		mad_request_env_fields_history.columnList.add(new dmColumn("history_user","int",11,"NULL",false,true,false));
		mad_request_env_fields_history.columnList.add(new dmColumn("history_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_request_env_fields_history.columnList.add(new dmColumn("history_host","varchar",100,"NULL",false,true,false));
		tableList.add(mad_request_env_fields_history);

		//-------------------------------------------
		//mad_request_fields
		//-------------------------------------------
		table_name="mad_request_fields";
		engine="InnoDB";
		dmTable mad_request_fields=new dmTable(table_name,engine);
		mad_request_fields.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_fields.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_fields.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		mad_request_fields.columnList.add(new dmColumn("field_value","text",0,"NULL",false,true,false));
		mad_request_fields.columnList.add(new dmColumn("field_value_ts","timestamp",0,"NULL",false,true,false));
		mad_request_fields.columnList.add(new dmColumn("field_value_num","double",0,"NULL",false,true,false));
		mad_request_fields.columnList.add(new dmColumn("entuser","int",11,"NULL",false,true,false));
		mad_request_fields.columnList.add(new dmColumn("entdate","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		tableList.add(mad_request_fields);

		//-------------------------------------------
		//mad_request_fields_history
		//-------------------------------------------
		table_name="mad_request_fields_history";
		engine="InnoDB";
		dmTable mad_request_fields_history=new dmTable(table_name,engine);
		mad_request_fields_history.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_fields_history.columnList.add(new dmColumn("request_fields_id","int",11,"NULL",false,true,false));
		mad_request_fields_history.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_fields_history.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		mad_request_fields_history.columnList.add(new dmColumn("field_value","text",0,"NULL",false,true,false));
		mad_request_fields_history.columnList.add(new dmColumn("field_value_ts","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_request_fields_history.columnList.add(new dmColumn("field_value_num","double",0,"NULL",false,true,false));
		mad_request_fields_history.columnList.add(new dmColumn("history_action","varchar",10,"NULL",false,true,false));
		mad_request_fields_history.columnList.add(new dmColumn("history_user","int",11,"NULL",false,true,false));
		mad_request_fields_history.columnList.add(new dmColumn("history_date","timestamp",0,"0000-00-00 00:00:00",false,false,false));
		mad_request_fields_history.columnList.add(new dmColumn("history_host","varchar",100,"NULL",false,true,false));
		tableList.add(mad_request_fields_history);

		//-------------------------------------------
		//mad_request_flow_logs
		//-------------------------------------------
		table_name="mad_request_flow_logs";
		engine="InnoDB";
		dmTable mad_request_flow_logs=new dmTable(table_name,engine);
		mad_request_flow_logs.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_flow_logs.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_flow_logs.columnList.add(new dmColumn("flow_id","int",11,"NULL",false,true,false));
		mad_request_flow_logs.columnList.add(new dmColumn("flow_state_id","int",11,"NULL",false,true,false));
		mad_request_flow_logs.columnList.add(new dmColumn("curr_state_user","int",11,"NULL",false,true,false));
		mad_request_flow_logs.columnList.add(new dmColumn("curr_state_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_request_flow_logs.columnList.add(new dmColumn("status","varchar",10,"OPEN",false,true,false));
		mad_request_flow_logs.columnList.add(new dmColumn("flow_state_action_id","int",11,"NULL",false,true,false));
		mad_request_flow_logs.columnList.add(new dmColumn("action_note","text",0,"NULL",false,true,false));
		mad_request_flow_logs.columnList.add(new dmColumn("next_state_id","int",11,"NULL",false,true,false));
		mad_request_flow_logs.columnList.add(new dmColumn("next_state_user","int",11,"NULL",false,true,false));
		mad_request_flow_logs.columnList.add(new dmColumn("next_state_date","timestamp",0,"0000-00-00 00:00:00",false,false,false));
		mad_request_flow_logs.columnList.add(new dmColumn("time_spent","int",5,"0",false,true,false));
		mad_request_flow_logs.columnList.add(new dmColumn("notification_sent","varchar",3,"NO",false,true,false));
		mad_request_flow_logs.columnList.add(new dmColumn("notification_attempt_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		tableList.add(mad_request_flow_logs);

		//-------------------------------------------
		//mad_request_history
		//-------------------------------------------
		table_name="mad_request_history";
		engine="InnoDB";
		dmTable mad_request_history=new dmTable(table_name,engine);
		mad_request_history.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_history.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_history.columnList.add(new dmColumn("description","varchar",400,"NULL",false,true,false));
		mad_request_history.columnList.add(new dmColumn("status","varchar",20,"NULL",false,true,false));
		mad_request_history.columnList.add(new dmColumn("deployment_slot_id","int",11,"NULL",false,true,false));
		mad_request_history.columnList.add(new dmColumn("deployment_slot_detail_id","int",11,"NULL",false,true,false));
		mad_request_history.columnList.add(new dmColumn("deployment_date","timestamp",0,"NULL",false,true,false));
		mad_request_history.columnList.add(new dmColumn("history_action","varchar",10,"NULL",false,true,false));
		mad_request_history.columnList.add(new dmColumn("history_user","int",11,"NULL",false,true,false));
		mad_request_history.columnList.add(new dmColumn("history_date","timestamp",0,"0000-00-00 00:00:00",false,false,false));
		mad_request_history.columnList.add(new dmColumn("history_host","varchar",100,"NULL",false,true,false));
		tableList.add(mad_request_history);

		//-------------------------------------------
		//mad_request_link
		//-------------------------------------------
		table_name="mad_request_link";
		engine="InnoDB";
		dmTable mad_request_link=new dmTable(table_name,engine);
		mad_request_link.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_link.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_link.columnList.add(new dmColumn("linked_request_id","int",11,"NULL",false,true,false));
		mad_request_link.columnList.add(new dmColumn("entuser","int",11,"NULL",false,true,false));
		mad_request_link.columnList.add(new dmColumn("entdate","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		tableList.add(mad_request_link);

		//-------------------------------------------
		//mad_request_link_history
		//-------------------------------------------
		table_name="mad_request_link_history";
		engine="InnoDB";
		dmTable mad_request_link_history=new dmTable(table_name,engine);
		mad_request_link_history.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_link_history.columnList.add(new dmColumn("request_link_id","int",11,"NULL",false,true,false));
		mad_request_link_history.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_link_history.columnList.add(new dmColumn("linked_request_id","int",11,"NULL",false,true,false));
		mad_request_link_history.columnList.add(new dmColumn("history_action","varchar",10,"NULL",false,true,false));
		mad_request_link_history.columnList.add(new dmColumn("history_user","int",11,"NULL",false,true,false));
		mad_request_link_history.columnList.add(new dmColumn("history_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_request_link_history.columnList.add(new dmColumn("history_host","varchar",100,"NULL",false,true,false));
		tableList.add(mad_request_link_history);

		//-------------------------------------------
		//mad_request_lock
		//-------------------------------------------
		table_name="mad_request_lock";
		engine="MEMORY";
		dmTable mad_request_lock=new dmTable(table_name,engine);
		mad_request_lock.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_lock.columnList.add(new dmColumn("lock_user_id","int",11,"NULL",false,true,false));
		mad_request_lock.columnList.add(new dmColumn("lock_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		tableList.add(mad_request_lock);

		//-------------------------------------------
		//mad_request_notification_log
		//-------------------------------------------
		table_name="mad_request_notification_log";
		engine="InnoDB";
		dmTable mad_request_notification_log=new dmTable(table_name,engine);
		mad_request_notification_log.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_notification_log.columnList.add(new dmColumn("request_flow_log_id","int",11,"NULL",false,true,false));
		mad_request_notification_log.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_notification_log.columnList.add(new dmColumn("send_status","varchar",3,"YES",false,true,false));
		mad_request_notification_log.columnList.add(new dmColumn("send_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_request_notification_log.columnList.add(new dmColumn("from_email_addr","varchar",200,"NULL",false,true,false));
		mad_request_notification_log.columnList.add(new dmColumn("from_name","varchar",200,"NULL",false,true,false));
		mad_request_notification_log.columnList.add(new dmColumn("to_email_addr","text",0,"NULL",false,true,false));
		mad_request_notification_log.columnList.add(new dmColumn("to_name","text",0,"NULL",false,true,false));
		mad_request_notification_log.columnList.add(new dmColumn("email_subject","varchar",1000,"NULL",false,true,false));
		mad_request_notification_log.columnList.add(new dmColumn("email_body","text",0,"NULL",false,true,false));
		mad_request_notification_log.columnList.add(new dmColumn("trans_logs","text",0,"NULL",false,true,false));
		mad_request_notification_log.columnList.add(new dmColumn("entuser","int",11,"NULL",false,true,false));
		mad_request_notification_log.columnList.add(new dmColumn("entdate","timestamp",0,"0000-00-00 00:00:00",false,false,false));
		tableList.add(mad_request_notification_log);

		//-------------------------------------------
		//mad_request_platform_skip
		//-------------------------------------------
		table_name="mad_request_platform_skip";
		engine="InnoDB";
		dmTable mad_request_platform_skip=new dmTable(table_name,engine);
		mad_request_platform_skip.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_platform_skip.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_platform_skip.columnList.add(new dmColumn("platform_id","int",11,"NULL",false,true,false));
		tableList.add(mad_request_platform_skip);

		//-------------------------------------------
		//mad_request_platform_skip_history
		//-------------------------------------------
		table_name="mad_request_platform_skip_history";
		engine="InnoDB";
		dmTable mad_request_platform_skip_history=new dmTable(table_name,engine);
		mad_request_platform_skip_history.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_platform_skip_history.columnList.add(new dmColumn("request_platform_skip_id","int",11,"NULL",false,true,false));
		mad_request_platform_skip_history.columnList.add(new dmColumn("request_id","int",11,"NULL",false,true,false));
		mad_request_platform_skip_history.columnList.add(new dmColumn("platform_id","int",11,"NULL",false,true,false));
		mad_request_platform_skip_history.columnList.add(new dmColumn("history_action","varchar",10,"NULL",false,true,false));
		mad_request_platform_skip_history.columnList.add(new dmColumn("history_user","int",11,"NULL",false,true,false));
		mad_request_platform_skip_history.columnList.add(new dmColumn("history_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		mad_request_platform_skip_history.columnList.add(new dmColumn("history_host","varchar",100,"NULL",false,true,false));
		tableList.add(mad_request_platform_skip_history);

		//-------------------------------------------
		//mad_request_type
		//-------------------------------------------
		table_name="mad_request_type";
		engine="InnoDB";
		dmTable mad_request_type=new dmTable(table_name,engine);
		mad_request_type.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_type.columnList.add(new dmColumn("request_type","varchar",100,"NULL",false,true,false));
		mad_request_type.columnList.add(new dmColumn("request_group","varchar",20,"NULL",false,true,false));
		mad_request_type.columnList.add(new dmColumn("permission","int",11,"NULL",false,true,false));
		mad_request_type.columnList.add(new dmColumn("flow_id","int",11,"NULL",false,true,false));
		mad_request_type.columnList.add(new dmColumn("is_visible","varchar",3,"YES",false,true,false));
		mad_request_type.columnList.add(new dmColumn("deployment_slot_id","int",11,"NULL",false,true,false));
		tableList.add(mad_request_type);

		//-------------------------------------------
		//mad_request_type_application
		//-------------------------------------------
		table_name="mad_request_type_application";
		engine="InnoDB";
		dmTable mad_request_type_application=new dmTable(table_name,engine);
		mad_request_type_application.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_type_application.columnList.add(new dmColumn("request_type_id","int",11,"NULL",false,true,false));
		mad_request_type_application.columnList.add(new dmColumn("application_id","int",11,"NULL",false,true,false));
		tableList.add(mad_request_type_application);

		//-------------------------------------------
		//mad_request_type_environment
		//-------------------------------------------
		table_name="mad_request_type_environment";
		engine="InnoDB";
		dmTable mad_request_type_environment=new dmTable(table_name,engine);
		mad_request_type_environment.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_type_environment.columnList.add(new dmColumn("request_type_id","int",11,"NULL",false,true,false));
		mad_request_type_environment.columnList.add(new dmColumn("environment_id","int",11,"NULL",false,true,false));
		tableList.add(mad_request_type_environment);

		//-------------------------------------------
		//mad_request_type_field
		//-------------------------------------------
		table_name="mad_request_type_field";
		engine="InnoDB";
		dmTable mad_request_type_field=new dmTable(table_name,engine);
		mad_request_type_field.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_type_field.columnList.add(new dmColumn("request_type_id","int",11,"NULL",false,true,false));
		mad_request_type_field.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		mad_request_type_field.columnList.add(new dmColumn("field_parameter_name","varchar",200,"NULL",false,true,false));
		mad_request_type_field.columnList.add(new dmColumn("default_value","text",0,"NULL",false,true,false));
		mad_request_type_field.columnList.add(new dmColumn("is_mandatory","varchar",3,"NO",false,true,false));
		mad_request_type_field.columnList.add(new dmColumn("is_editable","varchar",3,"YES",false,true,false));
		mad_request_type_field.columnList.add(new dmColumn("is_visible","varchar",3,"YES",false,true,false));
		mad_request_type_field.columnList.add(new dmColumn("field_order","int",4,"0",false,true,false));
		tableList.add(mad_request_type_field);

		//-------------------------------------------
		//mad_request_type_state_field_override
		//-------------------------------------------
		table_name="mad_request_type_state_field_override";
		engine="InnoDB";
		dmTable mad_request_type_state_field_override=new dmTable(table_name,engine);
		mad_request_type_state_field_override.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_type_state_field_override.columnList.add(new dmColumn("request_type_id","int",11,"NULL",false,true,false));
		mad_request_type_state_field_override.columnList.add(new dmColumn("flow_state_id","int",11,"NULL",false,true,false));
		mad_request_type_state_field_override.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		mad_request_type_state_field_override.columnList.add(new dmColumn("permission_id","int",11,"NULL",false,true,false));
		mad_request_type_state_field_override.columnList.add(new dmColumn("overriding_key","varchar",10,"NULL",false,true,false));
		tableList.add(mad_request_type_state_field_override);

		//-------------------------------------------
		//mad_request_work_package
		//-------------------------------------------
		table_name="mad_request_work_package";
		engine="InnoDB";
		dmTable mad_request_work_package=new dmTable(table_name,engine);
		mad_request_work_package.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_work_package.columnList.add(new dmColumn("request_id","varchar",100,"NULL",false,true,false));
		mad_request_work_package.columnList.add(new dmColumn("work_plan_id","int",11,"NULL",false,true,false));
		mad_request_work_package.columnList.add(new dmColumn("work_package_id","int",11,"NULL",false,true,false));
		mad_request_work_package.columnList.add(new dmColumn("deployment_attempt_no","int",11,"0",false,true,false));
		tableList.add(mad_request_work_package);

		//-------------------------------------------
		//mad_request_work_plan
		//-------------------------------------------
		table_name="mad_request_work_plan";
		engine="InnoDB";
		dmTable mad_request_work_plan=new dmTable(table_name,engine);
		mad_request_work_plan.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_request_work_plan.columnList.add(new dmColumn("request_id","varchar",100,"NULL",false,true,false));
		mad_request_work_plan.columnList.add(new dmColumn("work_plan_id","int",11,"NULL",false,true,false));
		mad_request_work_plan.columnList.add(new dmColumn("deployment_attempt_no","int",5,"NULL",false,true,false));
		tableList.add(mad_request_work_plan);

		//-------------------------------------------
		//mad_string
		//-------------------------------------------
		table_name="mad_string";
		engine="InnoDB";
		dmTable mad_string=new dmTable(table_name,engine);
		mad_string.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		mad_string.columnList.add(new dmColumn("lang","varchar",20,"NULL",false,true,false));
		mad_string.columnList.add(new dmColumn("string_name","varchar",200,"NULL",false,true,false));
		mad_string.columnList.add(new dmColumn("short_desc","varchar",2000,"NULL",false,true,false));
		mad_string.columnList.add(new dmColumn("long_desc","text",0,"NULL",false,true,false));
		tableList.add(mad_string);

		//-------------------------------------------
		//tdm_add_process
		//-------------------------------------------
		table_name="tdm_add_process";
		engine="InnoDB";
		dmTable tdm_add_process=new dmTable(table_name,engine);
		tdm_add_process.columnList.add(new dmColumn("process_class","varchar",100,"NULL",false,true,false));
		tdm_add_process.columnList.add(new dmColumn("process_count","varchar",10,"NULL",false,true,false));
		tableList.add(tdm_add_process);

		//-------------------------------------------
		//tdm_apps
		//-------------------------------------------
		table_name="tdm_apps";
		engine="InnoDB";
		dmTable tdm_apps=new dmTable(table_name,engine);
		tdm_apps.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_apps.columnList.add(new dmColumn("name","varchar",100,"NULL",false,true,false));
		tdm_apps.columnList.add(new dmColumn("app_type","varchar",20,"NULL",false,true,false));
		tdm_apps.columnList.add(new dmColumn("prep_script","mediumtext",0,"NULL",false,true,false));
		tdm_apps.columnList.add(new dmColumn("post_script","mediumtext",0,"NULL",false,true,false));
		tdm_apps.columnList.add(new dmColumn("last_run_point_statement","text",0,"NULL",false,true,false));
		tableList.add(tdm_apps);

		//-------------------------------------------
		//tdm_apps_rel
		//-------------------------------------------
		table_name="tdm_apps_rel";
		engine="InnoDB";
		dmTable tdm_apps_rel=new dmTable(table_name,engine);
		tdm_apps_rel.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_apps_rel.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_apps_rel.columnList.add(new dmColumn("rel_app_id","int",11,"NULL",false,true,false));
		tdm_apps_rel.columnList.add(new dmColumn("rel_order","int",4,"0",false,true,false));
		tdm_apps_rel.columnList.add(new dmColumn("filter_id","int",11,"NULL",false,true,false));
		tdm_apps_rel.columnList.add(new dmColumn("filter_value","varchar",1000,"NULL",false,true,false));
		tdm_apps_rel.columnList.add(new dmColumn("run_after_app_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_apps_rel);

		//-------------------------------------------
		//tdm_audit_logs
		//-------------------------------------------
		table_name="tdm_audit_logs";
		engine="InnoDB";
		dmTable tdm_audit_logs=new dmTable(table_name,engine);
		tdm_audit_logs.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_audit_logs.columnList.add(new dmColumn("table_name","varchar",100,"NULL",false,true,false));
		tdm_audit_logs.columnList.add(new dmColumn("table_id","int",11,"0",false,false,false));
		tdm_audit_logs.columnList.add(new dmColumn("log_action","varchar",10,"NULL",false,true,false));
		tdm_audit_logs.columnList.add(new dmColumn("log_date","timestamp",0,"CURRENT_TIMESTAMP",false,false,false));
		tdm_audit_logs.columnList.add(new dmColumn("log_user","varchar",100,"NULL",false,true,false));
		tdm_audit_logs.columnList.add(new dmColumn("old_record","mediumtext",0,"NULL",false,true,false));
		tableList.add(tdm_audit_logs);

		//-------------------------------------------
		//tdm_auto_scripts
		//-------------------------------------------
		table_name="tdm_auto_scripts";
		engine="InnoDB";
		dmTable tdm_auto_scripts=new dmTable(table_name,engine);
		tdm_auto_scripts.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_auto_scripts.columnList.add(new dmColumn("app_id","int",11,"0",false,false,false));
		tdm_auto_scripts.columnList.add(new dmColumn("script_name","varchar",100,"NULL",false,true,false));
		tdm_auto_scripts.columnList.add(new dmColumn("description","varchar",1000,"NULL",false,true,false));
		tdm_auto_scripts.columnList.add(new dmColumn("script_body","mediumblob",0,"NULL",false,true,false));
		tdm_auto_scripts.columnList.add(new dmColumn("script_type","varchar",20,"NULL",false,true,false));
		tdm_auto_scripts.columnList.add(new dmColumn("lock_info","varchar",100,"NULL",false,true,false));
		tableList.add(tdm_auto_scripts);

		//-------------------------------------------
		//tdm_auto_scripts_dep
		//-------------------------------------------
		table_name="tdm_auto_scripts_dep";
		engine="InnoDB";
		dmTable tdm_auto_scripts_dep=new dmTable(table_name,engine);
		tdm_auto_scripts_dep.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_auto_scripts_dep.columnList.add(new dmColumn("main_script_id","int",11,"0",false,false,false));
		tdm_auto_scripts_dep.columnList.add(new dmColumn("reusable_script_id","int",11,"0",false,false,false));
		tableList.add(tdm_auto_scripts_dep);

		//-------------------------------------------
		//tdm_auto_scripts_par
		//-------------------------------------------
		table_name="tdm_auto_scripts_par";
		engine="InnoDB";
		dmTable tdm_auto_scripts_par=new dmTable(table_name,engine);
		tdm_auto_scripts_par.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_auto_scripts_par.columnList.add(new dmColumn("script_id","int",11,"NULL",false,true,false));
		tdm_auto_scripts_par.columnList.add(new dmColumn("param_name","varchar",100,"NULL",false,true,false));
		tdm_auto_scripts_par.columnList.add(new dmColumn("param_desc","text",0,"NULL",false,true,false));
		tdm_auto_scripts_par.columnList.add(new dmColumn("param_order","int",3,"NULL",false,true,false));
		tdm_auto_scripts_par.columnList.add(new dmColumn("default_value","varchar",1000,"NULL",false,true,false));
		tdm_auto_scripts_par.columnList.add(new dmColumn("regex_statement","varchar",1000,"NULL",false,true,false));
		tdm_auto_scripts_par.columnList.add(new dmColumn("source_prof_id","int",11,"NULL",false,true,false));
		tdm_auto_scripts_par.columnList.add(new dmColumn("lov_list","text",0,"NULL",false,true,false));
		tdm_auto_scripts_par.columnList.add(new dmColumn("param_type","varchar",20,"NULL",false,true,false));
		tableList.add(tdm_auto_scripts_par);

		//-------------------------------------------
		//tdm_copy_app_checklist
		//-------------------------------------------
		table_name="tdm_copy_app_checklist";
		engine="InnoDB";
		dmTable tdm_copy_app_checklist=new dmTable(table_name,engine);
		tdm_copy_app_checklist.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_copy_app_checklist.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_copy_app_checklist.columnList.add(new dmColumn("checklist_name","varchar",200,"NULL",false,true,false));
		tdm_copy_app_checklist.columnList.add(new dmColumn("checklist_statement","text",0,"NULL",false,true,false));
		tdm_copy_app_checklist.columnList.add(new dmColumn("not_check","varchar",3,"NO",false,true,false));
		tdm_copy_app_checklist.columnList.add(new dmColumn("operand","varchar",30,"EQUALS",false,true,false));
		tdm_copy_app_checklist.columnList.add(new dmColumn("operand_parameters","text",0,"NULL",false,true,false));
		tdm_copy_app_checklist.columnList.add(new dmColumn("valid","varchar",3,"NO",false,true,false));
		tableList.add(tdm_copy_app_checklist);

		//-------------------------------------------
		//tdm_copy_filter
		//-------------------------------------------
		table_name="tdm_copy_filter";
		engine="InnoDB";
		dmTable tdm_copy_filter=new dmTable(table_name,engine);
		tdm_copy_filter.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_copy_filter.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_copy_filter.columnList.add(new dmColumn("tab_id","int",11,"NULL",false,true,false));
		tdm_copy_filter.columnList.add(new dmColumn("filter_name","varchar",200,"NULL",false,true,false));
		tdm_copy_filter.columnList.add(new dmColumn("filter_type","varchar",20,"NULL",false,true,false));
		tdm_copy_filter.columnList.add(new dmColumn("filter_sql","text",0,"NULL",false,true,false));
		tdm_copy_filter.columnList.add(new dmColumn("format_1","varchar",200,"NULL",false,true,false));
		tdm_copy_filter.columnList.add(new dmColumn("format_2","varchar",200,"NULL",false,true,false));
		tdm_copy_filter.columnList.add(new dmColumn("list_id_1","int",11,"NULL",false,true,false));
		tdm_copy_filter.columnList.add(new dmColumn("list_id_2","int",11,"NULL",false,true,false));
		tdm_copy_filter.columnList.add(new dmColumn("list_source_1","varchar",10,"STATIC",false,true,false));
		tdm_copy_filter.columnList.add(new dmColumn("list_source_2","varchar",10,"STATIC",false,true,false));
		tableList.add(tdm_copy_filter);

		//-------------------------------------------
		//tdm_copy_rule
		//-------------------------------------------
		table_name="tdm_copy_rule";
		engine="InnoDB";
		dmTable tdm_copy_rule=new dmTable(table_name,engine);
		tdm_copy_rule.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_copy_rule.columnList.add(new dmColumn("tab_id","int",11,"NULL",false,true,false));
		tdm_copy_rule.columnList.add(new dmColumn("rule_order","int",3,"NULL",false,true,false));
		tdm_copy_rule.columnList.add(new dmColumn("if_field","varchar",100,"NULL",false,true,false));
		tdm_copy_rule.columnList.add(new dmColumn("if_operand","varchar",100,"NULL",false,true,false));
		tdm_copy_rule.columnList.add(new dmColumn("if_clause","varchar",200,"NULL",false,true,false));
		tdm_copy_rule.columnList.add(new dmColumn("ref_tab_id","int",11,"NULL",false,true,false));
		tdm_copy_rule.columnList.add(new dmColumn("rel_fields","varchar",200,"NULL",false,true,false));
		tdm_copy_rule.columnList.add(new dmColumn("ref_filter","varchar",1000,"NULL",false,true,false));
		tdm_copy_rule.columnList.add(new dmColumn("max_row","int",10,"-1",false,true,false));
		tdm_copy_rule.columnList.add(new dmColumn("max_cycle","int",10,"-1",false,true,false));
		tableList.add(tdm_copy_rule);

		//-------------------------------------------
		//tdm_copy_script
		//-------------------------------------------
		table_name="tdm_copy_script";
		engine="InnoDB";
		dmTable tdm_copy_script=new dmTable(table_name,engine);
		tdm_copy_script.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_copy_script.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_copy_script.columnList.add(new dmColumn("script_description","varchar",200,"NULL",false,true,false));
		tdm_copy_script.columnList.add(new dmColumn("family_id","int",11,"NULL",false,true,false));
		tdm_copy_script.columnList.add(new dmColumn("stage","varchar",10,"NULL",false,true,false));
		tdm_copy_script.columnList.add(new dmColumn("target","varchar",10,"NULL",false,true,false));
		tdm_copy_script.columnList.add(new dmColumn("script_body","text",0,"NULL",false,true,false));
		tdm_copy_script.columnList.add(new dmColumn("script_order","int",11,"1",false,true,false));
		tableList.add(tdm_copy_script);

		//-------------------------------------------
		//tdm_discovery
		//-------------------------------------------
		table_name="tdm_discovery";
		engine="InnoDB";
		dmTable tdm_discovery=new dmTable(table_name,engine);
		tdm_discovery.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_discovery.columnList.add(new dmColumn("discovery_type","varchar",10,"MASK",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("discovery_title","varchar",1000,"NULL",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("status","varchar",45,"NEW",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("cancel_flag","varchar",3,"NO",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("env_id","int",11,"NULL",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("schema_name","varchar",1000,"NEW",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("sample_count","int",6,"1000",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("sector_id","int",11,"0",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("create_date","datetime",0,"NULL",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("start_date","datetime",0,"NULL",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("heartbeat","datetime",0,"NULL",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("finish_date","datetime",0,"NULL",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("progress","int",5,"NULL",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("progress_desc","varchar",1000,"NULL",false,true,false));
		tdm_discovery.columnList.add(new dmColumn("error_msg","varchar",1000,"NULL",false,true,false));
		tableList.add(tdm_discovery);

		//-------------------------------------------
		//tdm_discovery_rel
		//-------------------------------------------
		table_name="tdm_discovery_rel";
		engine="InnoDB";
		dmTable tdm_discovery_rel=new dmTable(table_name,engine);
		tdm_discovery_rel.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_discovery_rel.columnList.add(new dmColumn("discovery_id","int",11,"NULL",false,true,false));
		tdm_discovery_rel.columnList.add(new dmColumn("tab_cat","varchar",100,"${default}",false,true,false));
		tdm_discovery_rel.columnList.add(new dmColumn("tab_owner","varchar",200,"NULL",false,true,false));
		tdm_discovery_rel.columnList.add(new dmColumn("tab_name","varchar",200,"NULL",false,true,false));
		tdm_discovery_rel.columnList.add(new dmColumn("parent_tab_cat","varchar",200,"NULL",false,true,false));
		tdm_discovery_rel.columnList.add(new dmColumn("parent_tab_owner","varchar",200,"NULL",false,true,false));
		tdm_discovery_rel.columnList.add(new dmColumn("parent_tab_name","varchar",200,"NULL",false,true,false));
		tdm_discovery_rel.columnList.add(new dmColumn("child_rel_fields","varchar",200,"NULL",false,true,false));
		tdm_discovery_rel.columnList.add(new dmColumn("parent_pk_fields","varchar",200,"NULL",false,true,false));
		tdm_discovery_rel.columnList.add(new dmColumn("sample_count","int",10,"NULL",false,true,false));
		tdm_discovery_rel.columnList.add(new dmColumn("matched_count","int",10,"NULL",false,true,false));
		tableList.add(tdm_discovery_rel);

		//-------------------------------------------
		//tdm_discovery_result
		//-------------------------------------------
		table_name="tdm_discovery_result";
		engine="InnoDB";
		dmTable tdm_discovery_result=new dmTable(table_name,engine);
		tdm_discovery_result.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_discovery_result.columnList.add(new dmColumn("discovery_id","int",11,"NULL",false,true,false));
		tdm_discovery_result.columnList.add(new dmColumn("catalog_name","varchar",100,"${default}",false,true,false));
		tdm_discovery_result.columnList.add(new dmColumn("schema_name","varchar",200,"NULL",false,true,false));
		tdm_discovery_result.columnList.add(new dmColumn("table_name","varchar",200,"NULL",false,true,false));
		tdm_discovery_result.columnList.add(new dmColumn("field_name","varchar",200,"NULL",false,true,false));
		tdm_discovery_result.columnList.add(new dmColumn("field_type","varchar",200,"NULL",false,true,false));
		tdm_discovery_result.columnList.add(new dmColumn("discovery_target_id","int",11,"NULL",false,true,false));
		tdm_discovery_result.columnList.add(new dmColumn("discovery_rule_id","int",11,"NULL",false,true,false));
		tdm_discovery_result.columnList.add(new dmColumn("match_count","int",11,"NULL",false,true,false));
		tdm_discovery_result.columnList.add(new dmColumn("sample_count","int",11,"0",false,true,false));
		tableList.add(tdm_discovery_result);

		//-------------------------------------------
		//tdm_discovery_rule
		//-------------------------------------------
		table_name="tdm_discovery_rule";
		engine="InnoDB";
		dmTable tdm_discovery_rule=new dmTable(table_name,engine);
		tdm_discovery_rule.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_discovery_rule.columnList.add(new dmColumn("discovery_target_id","int",11,"NULL",false,true,false));
		tdm_discovery_rule.columnList.add(new dmColumn("rule_type","varchar",10,"MATCHES",false,true,false));
		tdm_discovery_rule.columnList.add(new dmColumn("description","varchar",1000,"NULL",false,true,false));
		tdm_discovery_rule.columnList.add(new dmColumn("regex","varchar",1000,"NULL",false,true,false));
		tdm_discovery_rule.columnList.add(new dmColumn("script","text",0,"NULL",false,true,false));
		tdm_discovery_rule.columnList.add(new dmColumn("field_names","varchar",4000,"NULL",false,true,false));
		tdm_discovery_rule.columnList.add(new dmColumn("rule_weight","int",3,"10",false,true,false));
		tdm_discovery_rule.columnList.add(new dmColumn("is_valid","varchar",3,"YES",false,true,false));
		tableList.add(tdm_discovery_rule);

		//-------------------------------------------
		//tdm_discovery_sector
		//-------------------------------------------
		table_name="tdm_discovery_sector";
		engine="InnoDB";
		dmTable tdm_discovery_sector=new dmTable(table_name,engine);
		tdm_discovery_sector.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_discovery_sector.columnList.add(new dmColumn("description","varchar",200,"NULL",false,true,false));
		tableList.add(tdm_discovery_sector);

		//-------------------------------------------
		//tdm_discovery_sector_rule
		//-------------------------------------------
		table_name="tdm_discovery_sector_rule";
		engine="InnoDB";
		dmTable tdm_discovery_sector_rule=new dmTable(table_name,engine);
		tdm_discovery_sector_rule.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_discovery_sector_rule.columnList.add(new dmColumn("discovery_sector_id","int",11,"NULL",false,true,false));
		tdm_discovery_sector_rule.columnList.add(new dmColumn("discovery_rule_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_discovery_sector_rule);

		//-------------------------------------------
		//tdm_discovery_target
		//-------------------------------------------
		table_name="tdm_discovery_target";
		engine="InnoDB";
		dmTable tdm_discovery_target=new dmTable(table_name,engine);
		tdm_discovery_target.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_discovery_target.columnList.add(new dmColumn("description","varchar",1000,"NEW",false,true,false));
		tableList.add(tdm_discovery_target);

		//-------------------------------------------
		//tdm_domain
		//-------------------------------------------
		table_name="tdm_domain";
		engine="InnoDB";
		dmTable tdm_domain=new dmTable(table_name,engine);
		tdm_domain.columnList.add(new dmColumn("ID","int",11,"NULL",true,true,true));
		tdm_domain.columnList.add(new dmColumn("domain_name","varchar",100,"NULL",false,true,false));
		tableList.add(tdm_domain);

		//-------------------------------------------
		//tdm_domain_class
		//-------------------------------------------
		table_name="tdm_domain_class";
		engine="InnoDB";
		dmTable tdm_domain_class=new dmTable(table_name,engine);
		tdm_domain_class.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_domain_class.columnList.add(new dmColumn("domain_class_name","varchar",100,"NULL",false,true,false));
		tdm_domain_class.columnList.add(new dmColumn("description","varchar",1000,"NULL",false,true,false));
		tableList.add(tdm_domain_class);

		//-------------------------------------------
		//tdm_domain_element
		//-------------------------------------------
		table_name="tdm_domain_element";
		engine="InnoDB";
		dmTable tdm_domain_element=new dmTable(table_name,engine);
		tdm_domain_element.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_domain_element.columnList.add(new dmColumn("domain_class_id","int",11,"NULL",false,true,false));
		tdm_domain_element.columnList.add(new dmColumn("domain_element_name","varchar",100,"NULL",false,true,false));
		tdm_domain_element.columnList.add(new dmColumn("domain_element_type","varchar",12,"NULL",false,true,false));
		tdm_domain_element.columnList.add(new dmColumn("description","varchar",1000,"NULL",false,true,false));
		tableList.add(tdm_domain_element);

		//-------------------------------------------
		//tdm_domain_instance
		//-------------------------------------------
		table_name="tdm_domain_instance";
		engine="InnoDB";
		dmTable tdm_domain_instance=new dmTable(table_name,engine);
		tdm_domain_instance.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_domain_instance.columnList.add(new dmColumn("domain_class_id","int",11,"NULL",false,true,false));
		tdm_domain_instance.columnList.add(new dmColumn("domain_instance_name","varchar",100,"NULL",false,true,false));
		tdm_domain_instance.columnList.add(new dmColumn("description","varchar",1000,"NULL",false,true,false));
		tableList.add(tdm_domain_instance);

		//-------------------------------------------
		//tdm_domain_instance_prop_val
		//-------------------------------------------
		table_name="tdm_domain_instance_prop_val";
		engine="InnoDB";
		dmTable tdm_domain_instance_prop_val=new dmTable(table_name,engine);
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("domain_instance_id","int",11,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("domain_element_id","int",11,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("description","varchar",1000,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("var_value","varchar",1000,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("db_driver","varchar",200,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("db_connstr","varchar",200,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("db_username","varchar",100,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("db_password","varchar",100,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("ftp_host","varchar",100,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("ftp_port","varchar",10,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("ftp_secure","varchar",3,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("ftp_username","varchar",100,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("ftp_password","varchar",100,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("terminal_host","varchar",100,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("terminal_port","varchar",10,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("terminal_type","varchar",100,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("terminal_username","varchar",100,"NULL",false,true,false));
		tdm_domain_instance_prop_val.columnList.add(new dmColumn("terminal_password","varchar",100,"NULL",false,true,false));
		tableList.add(tdm_domain_instance_prop_val);



		//-------------------------------------------
		//tdm_environment
		//-------------------------------------------
		table_name="tdm_environment";
		engine="InnoDB";
		dmTable tdm_environment=new dmTable(table_name,engine);
		tdm_environment.columnList.add(new dmColumn("ID","int",11,"NULL",true,true,true));
		tdm_environment.columnList.add(new dmColumn("domain_id","int",11,"NULL",false,true,false));
		tdm_environment.columnList.add(new dmColumn("environment_name","varchar",100,"NULL",false,true,false));
		tdm_environment.columnList.add(new dmColumn("environment_desc","varchar",4000,"NULL",false,true,false));
		tableList.add(tdm_environment);

		//-------------------------------------------
		//tdm_envs
		//-------------------------------------------
		table_name="tdm_envs";
		engine="InnoDB";
		dmTable tdm_envs=new dmTable(table_name,engine);
		tdm_envs.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_envs.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_envs.columnList.add(new dmColumn("name","varchar",100,"NULL",false,true,false));
		tdm_envs.columnList.add(new dmColumn("db_driver","varchar",200,"NULL",false,true,false));
		tdm_envs.columnList.add(new dmColumn("db_connstr","varchar",1000,"NULL",false,true,false));
		tdm_envs.columnList.add(new dmColumn("db_username","varchar",45,"NULL",false,true,false));
		tdm_envs.columnList.add(new dmColumn("db_password","varchar",200,"NULL",false,true,false));
		tdm_envs.columnList.add(new dmColumn("db_catalog","varchar",100,"${default}",false,true,false));
		tdm_envs.columnList.add(new dmColumn("asp_connstr","varchar",1000,"NULL",false,true,false));
		tdm_envs.columnList.add(new dmColumn("for_static","varchar",3,"NO",false,true,false));
		tdm_envs.columnList.add(new dmColumn("for_dynamic","varchar",3,"NO",false,true,false));
		tdm_envs.columnList.add(new dmColumn("for_design","varchar",3,"NO",false,true,false));
		tableList.add(tdm_envs);

		//-------------------------------------------
		//tdm_family
		//-------------------------------------------
		table_name="tdm_family";
		engine="InnoDB";
		dmTable tdm_family=new dmTable(table_name,engine);
		tdm_family.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_family.columnList.add(new dmColumn("family_name","varchar",100,"NULL",false,true,false));
		tableList.add(tdm_family);

		//-------------------------------------------
		//tdm_fields
		//-------------------------------------------
		table_name="tdm_fields";
		engine="InnoDB";
		dmTable tdm_fields=new dmTable(table_name,engine);
		tdm_fields.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_fields.columnList.add(new dmColumn("tab_id","int",11,"NULL",false,false,false));
		tdm_fields.columnList.add(new dmColumn("field_name","varchar",100,"NULL",false,true,false));
		tdm_fields.columnList.add(new dmColumn("field_type","varchar",100,"NULL",false,true,false));
		tdm_fields.columnList.add(new dmColumn("field_size","int",5,"0",false,true,false));
		tdm_fields.columnList.add(new dmColumn("is_pk","varchar",3,"NULL",false,true,false));
		tdm_fields.columnList.add(new dmColumn("mask_prof_id","int",11,"NULL",false,false,false));
		tdm_fields.columnList.add(new dmColumn("list_field_name","varchar",100,"NULL",false,true,false));
		tdm_fields.columnList.add(new dmColumn("is_conditional","varchar",3,"NULL",false,true,false));
		tdm_fields.columnList.add(new dmColumn("condition_expr","varchar",3000,"NULL",false,true,false));
		tdm_fields.columnList.add(new dmColumn("calc_prof_id","int",11,"NULL",false,true,false));
		tdm_fields.columnList.add(new dmColumn("copy_ref_tab_id","int",11,"NULL",false,true,false));
		tdm_fields.columnList.add(new dmColumn("copy_ref_field_name","varchar",1000,"NULL",false,true,false));
		tableList.add(tdm_fields);

		//-------------------------------------------
		//tdm_group
		//-------------------------------------------
		table_name="tdm_group";
		engine="InnoDB";
		dmTable tdm_group=new dmTable(table_name,engine);
		tdm_group.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_group.columnList.add(new dmColumn("group_name","varchar",200,"NULL",false,true,false));
		tdm_group.columnList.add(new dmColumn("group_description","text",0,"NULL",false,true,false));
		tableList.add(tdm_group);

		//-------------------------------------------
		//tdm_group_applications
		//-------------------------------------------
		table_name="tdm_group_applications";
		engine="InnoDB";
		dmTable tdm_group_applications=new dmTable(table_name,engine);
		tdm_group_applications.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_group_applications.columnList.add(new dmColumn("group_id","int",11,"NULL",false,true,false));
		tdm_group_applications.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_group_applications);

		//-------------------------------------------
		//tdm_group_environments
		//-------------------------------------------
		table_name="tdm_group_environments";
		engine="InnoDB";
		dmTable tdm_group_environments=new dmTable(table_name,engine);
		tdm_group_environments.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_group_environments.columnList.add(new dmColumn("group_id","int",11,"NULL",false,true,false));
		tdm_group_environments.columnList.add(new dmColumn("env_id","int",11,"NULL",false,true,false));
		tdm_group_environments.columnList.add(new dmColumn("env_type","varchar",10,"NULL",false,true,false));
		tableList.add(tdm_group_environments);

		//-------------------------------------------
		//tdm_group_members
		//-------------------------------------------
		table_name="tdm_group_members";
		engine="InnoDB";
		dmTable tdm_group_members=new dmTable(table_name,engine);
		tdm_group_members.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_group_members.columnList.add(new dmColumn("group_id","int",11,"NULL",false,true,false));
		tdm_group_members.columnList.add(new dmColumn("member_id","int",11,"NULL",false,true,false));
		tdm_group_members.columnList.add(new dmColumn("group_membership_description","text",0,"NULL",false,true,false));
		tableList.add(tdm_group_members);

		//-------------------------------------------
		//tdm_list
		//-------------------------------------------
		table_name="tdm_list";
		engine="InnoDB";
		dmTable tdm_list=new dmTable(table_name,engine);
		tdm_list.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_list.columnList.add(new dmColumn("name","varchar",100,"NULL",false,true,false));
		tdm_list.columnList.add(new dmColumn("title_list","varchar",1000,"NULL",false,true,false));
		tdm_list.columnList.add(new dmColumn("sql_statement","mediumtext",0,"NULL",false,true,false));
		tableList.add(tdm_list);

		//-------------------------------------------
		//tdm_list_items
		//-------------------------------------------
		table_name="tdm_list_items";
		engine="InnoDB";
		dmTable tdm_list_items=new dmTable(table_name,engine);
		tdm_list_items.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_list_items.columnList.add(new dmColumn("list_id","int",11,"NULL",false,false,false));
		tdm_list_items.columnList.add(new dmColumn("list_val","text",0,"NULL",false,true,false));
		tableList.add(tdm_list_items);

		//-------------------------------------------
		//tdm_manager
		//-------------------------------------------
		table_name="tdm_manager";
		engine="MEMORY";
		dmTable tdm_manager=new dmTable(table_name,engine);
		tdm_manager.columnList.add(new dmColumn("status","varchar",45,"FREE",false,true,false));
		tdm_manager.columnList.add(new dmColumn("last_heartbeat","datetime",0,"NULL",false,true,false));
		tdm_manager.columnList.add(new dmColumn("hostname","varchar",100,"NULL",false,true,false));
		tdm_manager.columnList.add(new dmColumn("cancel_flag","varchar",3,"NULL",false,true,false));
		tableList.add(tdm_manager);

		//-------------------------------------------
		//tdm_mask_prof
		//-------------------------------------------
		table_name="tdm_mask_prof";
		engine="InnoDB";
		dmTable tdm_mask_prof=new dmTable(table_name,engine);
		tdm_mask_prof.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_mask_prof.columnList.add(new dmColumn("name","varchar",100,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("rule_id","varchar",20,"NULL",false,false,false));
		tdm_mask_prof.columnList.add(new dmColumn("valid","varchar",3,"YES",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("hide_char","varchar",1,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("hide_after","int",3,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("hide_by_word","varchar",3,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("src_list_id","int",11,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("random_range","varchar",30,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("random_char_list","varchar",1000,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("regex_stmt","varchar",1000,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("post_stmt","varchar",1000,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("format","varchar",100,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("date_change_params","varchar",100,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("pre_stmt","varchar",1000,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("fixed_val","varchar",200,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("js_code","text",0,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("js_test_par","varchar",1000,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("short_code","varchar",45,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("run_on_server","varchar",3,"NO",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("scramble_part_type","varchar",20,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("scramble_part_type_par1","varchar",100,"NULL",false,true,false));
		tdm_mask_prof.columnList.add(new dmColumn("scramble_part_type_par2","varchar",100,"NULL",false,true,false));
		tableList.add(tdm_mask_prof);

		//-------------------------------------------
		//tdm_master
		//-------------------------------------------
		table_name="tdm_master";
		engine="MEMORY";
		dmTable tdm_master=new dmTable(table_name,engine);
		tdm_master.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_master.columnList.add(new dmColumn("master_name","varchar",200,"NULL",false,true,false));
		tdm_master.columnList.add(new dmColumn("status","varchar",45,"NEW",false,true,false));
		tdm_master.columnList.add(new dmColumn("hired_worker_count","int",11,"0",false,true,false));
		tdm_master.columnList.add(new dmColumn("last_heartbeat","datetime",0,"NULL",false,true,false));
		tdm_master.columnList.add(new dmColumn("hostname","varchar",100,"NULL",false,true,false));
		tdm_master.columnList.add(new dmColumn("assign_date","datetime",0,"NULL",false,true,false));
		tdm_master.columnList.add(new dmColumn("start_date","datetime",0,"NULL",false,true,false));
		tdm_master.columnList.add(new dmColumn("finish_date","datetime",0,"NULL",false,true,false));
		tdm_master.columnList.add(new dmColumn("cancel_flag","varchar",3,"NULL",false,true,false));
		tableList.add(tdm_master);

		//-------------------------------------------
		//tdm_master_log
		//-------------------------------------------
		table_name="tdm_master_log";
		engine="InnoDB";
		dmTable tdm_master_log=new dmTable(table_name,engine);
		tdm_master_log.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_master_log.columnList.add(new dmColumn("master_id","int",11,"0",false,true,false));
		tdm_master_log.columnList.add(new dmColumn("work_package_id","int",11,"0",false,true,false));
		tdm_master_log.columnList.add(new dmColumn("status","varchar",45,"NEW",false,true,false));
		tdm_master_log.columnList.add(new dmColumn("status_date","datetime",0,"NULL",false,true,false));
		tableList.add(tdm_master_log);

		//-------------------------------------------
		//tdm_node
		//-------------------------------------------
		table_name="tdm_node";
		engine="InnoDB";
		dmTable tdm_node=new dmTable(table_name,engine);
		tdm_node.columnList.add(new dmColumn("ID","int",11,"NULL",true,true,true));
		tdm_node.columnList.add(new dmColumn("domain_id","int",11,"NULL",false,true,false));
		tdm_node.columnList.add(new dmColumn("node_type","varchar",20,"NULL",false,true,false));
		tdm_node.columnList.add(new dmColumn("node_name","varchar",100,"NULL",false,true,false));
		tdm_node.columnList.add(new dmColumn("node_desc","varchar",4000,"NULL",false,true,false));
		tableList.add(tdm_node);

		//-------------------------------------------
		//tdm_node_environment
		//-------------------------------------------
		table_name="tdm_node_environment";
		engine="InnoDB";
		dmTable tdm_node_environment=new dmTable(table_name,engine);
		tdm_node_environment.columnList.add(new dmColumn("ID","int",11,"NULL",true,true,true));
		tdm_node_environment.columnList.add(new dmColumn("node_id","int",11,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("environment_id","int",11,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("db_driver","varchar",1000,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("db_connstr","varchar",1000,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("db_username","varchar",100,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("db_password","varchar",100,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("sel_class_name","varchar",1000,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("ws_endpoint_url","varchar",1000,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("ws_soap_action","varchar",200,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("add_info","varchar",4000,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("web_url","varchar",1000,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("param_value","varchar",500,"NULL",false,true,false));
		tdm_node_environment.columnList.add(new dmColumn("password_value","varchar",500,"NULL",false,true,false));
		tableList.add(tdm_node_environment);

		//-------------------------------------------
		//tdm_parameters
		//-------------------------------------------
		table_name="tdm_parameters";
		engine="InnoDB";
		dmTable tdm_parameters=new dmTable(table_name,engine);
		tdm_parameters.columnList.add(new dmColumn("param_name","varchar",200,"NULL",false,false,false));
		tdm_parameters.columnList.add(new dmColumn("param_value","text",0,"NULL",false,true,false));
		tableList.add(tdm_parameters);

		//-------------------------------------------
		//tdm_pool
		//-------------------------------------------
		table_name="tdm_pool";
		engine="InnoDB";
		dmTable tdm_pool=new dmTable(table_name,engine);
		tdm_pool.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_pool.columnList.add(new dmColumn("app_id","int",11,"NULL",false,false,false));
		tdm_pool.columnList.add(new dmColumn("family_id","int",11,"NULL",false,true,false));
		tdm_pool.columnList.add(new dmColumn("base_sql","text",0,"NULL",false,true,false));
		tableList.add(tdm_pool);


		//-------------------------------------------
		//tdm_pool_group
		//-------------------------------------------
		table_name="tdm_pool_group";
		engine="InnoDB";
		dmTable tdm_pool_group=new dmTable(table_name,engine);
		tdm_pool_group.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_pool_group.columnList.add(new dmColumn("pool_id","int",11,"NULL",false,true,false));
		tdm_pool_group.columnList.add(new dmColumn("group_name","varchar",200,"NULL",false,true,false));
		tdm_pool_group.columnList.add(new dmColumn("order_no","int",3,"1",false,true,false));
		tableList.add(tdm_pool_group);

		//-------------------------------------------
		//tdm_pool_instance
		//-------------------------------------------
		table_name="tdm_pool_instance";
		engine="InnoDB";
		dmTable tdm_pool_instance=new dmTable(table_name,engine);
		tdm_pool_instance.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_pool_instance.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("target_id","varchar",200,"NULL",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("target_pool_size","int",11,"0",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("is_debug","varchar",3,"NO",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("paralellism_count","int",4,"10",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("status","varchar",16,"NEW",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("start_date","datetime",0,"NULL",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("last_update_date","datetime",0,"NULL",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("last_check_date","datetime",0,"NULL",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("pool_size","int",11,"0",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("reserved_size","int",11,"0",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("cancel_flag","varchar",3,"NO",false,true,false));
		tdm_pool_instance.columnList.add(new dmColumn("reload_flag","varchar",3,"NO",false,true,false));
		tableList.add(tdm_pool_instance);

		//-------------------------------------------
		//tdm_pool_lov
		//-------------------------------------------
		table_name="tdm_pool_lov";
		engine="InnoDB";
		dmTable tdm_pool_lov=new dmTable(table_name,engine);
		tdm_pool_lov.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_pool_lov.columnList.add(new dmColumn("pool_id","int",11,"NULL",false,true,false));
		tdm_pool_lov.columnList.add(new dmColumn("lov_name","varchar",200,"NULL",false,true,false));
		tdm_pool_lov.columnList.add(new dmColumn("family_id","int",11,"0",false,true,false));
		tdm_pool_lov.columnList.add(new dmColumn("lov_statement","text",0,"NULL",false,true,false));
		tableList.add(tdm_pool_lov);

		//-------------------------------------------
		//tdm_pool_property
		//-------------------------------------------
		table_name="tdm_pool_property";
		engine="InnoDB";
		dmTable tdm_pool_property=new dmTable(table_name,engine);
		tdm_pool_property.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_pool_property.columnList.add(new dmColumn("pool_id","int",11,"NULL",false,false,false));
		tdm_pool_property.columnList.add(new dmColumn("property_name","varchar",40,"NULL",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("property_title","varchar",200,"NULL",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("group_id","int",11,"0",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("is_searchable","varchar",3,"YES",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("lov_id","int",11,"0",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("is_indexed","varchar",3,"NO",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("is_visible_on_search","varchar",3,"YES",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("data_type","varchar",10,"STRING",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("get_method","varchar",10,"DB",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("source_code","text",0,"NULL",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("property_family_id","int",11,"NULL",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("target_url","varchar",1000,"NULL",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("extract_method","varchar",10,"NONE",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("extract_method_parameter","text",0,"NULL",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("is_valid","varchar",3,"YES",false,true,false));
		tdm_pool_property.columnList.add(new dmColumn("order_no","int",3,"NULL",false,true,false));
		tableList.add(tdm_pool_property);

		//-------------------------------------------
		//tdm_project
		//-------------------------------------------
		table_name="tdm_project";
		engine="InnoDB";
		dmTable tdm_project=new dmTable(table_name,engine);
		tdm_project.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_project.columnList.add(new dmColumn("domain_id","int",11,"NULL",false,true,false));
		tdm_project.columnList.add(new dmColumn("project_name","varchar",1000,"NULL",false,true,false));
		tdm_project.columnList.add(new dmColumn("status","varchar",45,"NULL",false,true,false));
		tableList.add(tdm_project);

		//-------------------------------------------
		//tdm_proxy
		//-------------------------------------------
		table_name="tdm_proxy";
		engine="InnoDB";
		dmTable tdm_proxy=new dmTable(table_name,engine);
		tdm_proxy.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy.columnList.add(new dmColumn("proxy_name","varchar",200,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("status","varchar",45,"NEW",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("proxy_type","varchar",45,"ORACLE",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("secure_client","varchar",3,"NO",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("secure_public_key","varchar",1000,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("proxy_port","varchar",200,"NULL",false,false,false));
		tdm_proxy.columnList.add(new dmColumn("target_host","varchar",200,"127.0.0.1",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("target_port","int",5,"NULL",false,false,false));
		tdm_proxy.columnList.add(new dmColumn("proxy_charset","varchar",100,"UTF-8",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("target_app_id","int",11,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("target_env_id","int",11,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("protocol_configuration_id","int",11,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("max_package_size","int",10,"4096",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("is_debug","varchar",3,"NO",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("extra_args","varchar",1000,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("start_date","datetime",0,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("last_heartbeat","datetime",0,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("hostname","varchar",100,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("cancel_flag","varchar",3,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("reload_flag","varchar",3,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("last_reload_time","datetime",0,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("error_log","text",0,"NULL",false,true,false));
		tdm_proxy.columnList.add(new dmColumn("last_configuration","mediumblob",0,"NULL",false,true,false));
		tableList.add(tdm_proxy);

		//-------------------------------------------
		//tdm_proxy_calendar
		//-------------------------------------------
		table_name="tdm_proxy_calendar";
		engine="InnoDB";
		dmTable tdm_proxy_calendar=new dmTable(table_name,engine);
		tdm_proxy_calendar.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_calendar.columnList.add(new dmColumn("calendar_name","varchar",200,"NULL",false,true,false));
		tableList.add(tdm_proxy_calendar);

		//-------------------------------------------
		//tdm_proxy_calendar_exception
		//-------------------------------------------
		table_name="tdm_proxy_calendar_exception";
		engine="InnoDB";
		dmTable tdm_proxy_calendar_exception=new dmTable(table_name,engine);
		tdm_proxy_calendar_exception.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_calendar_exception.columnList.add(new dmColumn("calendar_id","int",11,"NULL",false,false,false));
		tdm_proxy_calendar_exception.columnList.add(new dmColumn("calendar_exception_name","varchar",200,"NULL",false,true,false));
		tdm_proxy_calendar_exception.columnList.add(new dmColumn("exception_start_time","datetime",0,"NULL",false,true,false));
		tdm_proxy_calendar_exception.columnList.add(new dmColumn("exception_end_time","datetime",0,"NULL",false,true,false));
		tableList.add(tdm_proxy_calendar_exception);

		//-------------------------------------------
		//tdm_proxy_config_log
		//-------------------------------------------
		table_name="tdm_proxy_config_log";
		engine="InnoDB";
		dmTable tdm_proxy_config_log=new dmTable(table_name,engine);
		tdm_proxy_config_log.columnList.add(new dmColumn("proxy_id","int",11,"NULL",false,true,false));
		tdm_proxy_config_log.columnList.add(new dmColumn("schema_name","varchar",100,"NULL",false,true,false));
		tdm_proxy_config_log.columnList.add(new dmColumn("table_name","varchar",100,"NULL",false,true,false));
		tdm_proxy_config_log.columnList.add(new dmColumn("last_activity_date","datetime",0,"NULL",false,true,false));
		tdm_proxy_config_log.columnList.add(new dmColumn("log_info","text",0,"NULL",false,true,false));
		tableList.add(tdm_proxy_config_log);

		//-------------------------------------------
		//tdm_proxy_exception
		//-------------------------------------------
		table_name="tdm_proxy_exception";
		engine="InnoDB";
		dmTable tdm_proxy_exception=new dmTable(table_name,engine);
		tdm_proxy_exception.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_exception.columnList.add(new dmColumn("exception_scope","varchar",20,"APPLICATION",false,true,false));
		tdm_proxy_exception.columnList.add(new dmColumn("exception_obj_id","int",11,"NULL",false,true,false));
		tdm_proxy_exception.columnList.add(new dmColumn("policy_group_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_proxy_exception);

		//-------------------------------------------
		//tdm_proxy_log
		//-------------------------------------------
		table_name="tdm_proxy_log";
		engine="InnoDB";
		dmTable tdm_proxy_log=new dmTable(table_name,engine);
		tdm_proxy_log.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_log.columnList.add(new dmColumn("log_date","datetime",0,"NULL",false,true,false));
		tdm_proxy_log.columnList.add(new dmColumn("proxy_id","int",11,"NULL",false,true,false));
		tdm_proxy_log.columnList.add(new dmColumn("proxy_session_id","int",11,"NULL",false,true,false));
		tdm_proxy_log.columnList.add(new dmColumn("current_schema","varchar",200,"NULL",false,true,false));
		tdm_proxy_log.columnList.add(new dmColumn("statement_type","varchar",50,"NULL",false,true,false));
		tdm_proxy_log.columnList.add(new dmColumn("original_sql","text",0,"NULL",false,true,false));
		tdm_proxy_log.columnList.add(new dmColumn("sample_sql","text",0,"NULL",false,true,false));
		tdm_proxy_log.columnList.add(new dmColumn("masking_sql","text",0,"NULL",false,true,false));
		tdm_proxy_log.columnList.add(new dmColumn("sample_count","int",11,"NULL",false,true,false));
		tdm_proxy_log.columnList.add(new dmColumn("bind_info","text",0,"NULL",false,true,false));
		tableList.add(tdm_proxy_log);

		//-------------------------------------------
		//tdm_proxy_log_exception
		//-------------------------------------------
		table_name="tdm_proxy_log_exception";
		engine="InnoDB";
		dmTable tdm_proxy_log_exception=new dmTable(table_name,engine);
		tdm_proxy_log_exception.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_log_exception.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_proxy_log_exception.columnList.add(new dmColumn("check_field","varchar",200,"SQL",false,true,false));
		tdm_proxy_log_exception.columnList.add(new dmColumn("check_rule","varchar",45,"CONTAINS",false,true,false));
		tdm_proxy_log_exception.columnList.add(new dmColumn("check_parameter","text",0,"NULL",false,true,false));
		tdm_proxy_log_exception.columnList.add(new dmColumn("env_id","int",11,"NULL",false,true,false));
		tdm_proxy_log_exception.columnList.add(new dmColumn("case_sensitive","varchar",10,"YES",false,true,false));
		tdm_proxy_log_exception.columnList.add(new dmColumn("valid","varchar",3,"YES",false,true,false));
		tableList.add(tdm_proxy_log_exception);

		//-------------------------------------------
		//tdm_proxy_monitoring
		//-------------------------------------------
		table_name="tdm_proxy_monitoring";
		engine="InnoDB";
		dmTable tdm_proxy_monitoring=new dmTable(table_name,engine);
		tdm_proxy_monitoring.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_monitoring.columnList.add(new dmColumn("monitoring_name","varchar",200,"NULL",false,true,false));
		tdm_proxy_monitoring.columnList.add(new dmColumn("monitoring_interval","int",5,"0",false,true,false));
		tdm_proxy_monitoring.columnList.add(new dmColumn("monitoring_period","varchar",10,"MINUTE",false,true,false));
		tdm_proxy_monitoring.columnList.add(new dmColumn("monitoring_threashold","int",6,"0",false,true,false));
		tdm_proxy_monitoring.columnList.add(new dmColumn("monitoring_threashold_recv_bytes","int",11,"0",false,true,false));
		tdm_proxy_monitoring.columnList.add(new dmColumn("monitoring_email","varchar",200,"NULL",false,true,false));
		tdm_proxy_monitoring.columnList.add(new dmColumn("monitoring_blacklist","varchar",3,"YES",false,true,false));
		tdm_proxy_monitoring.columnList.add(new dmColumn("is_active","varchar",3,"YES",false,true,false));
		tableList.add(tdm_proxy_monitoring);

		//-------------------------------------------
		//tdm_proxy_monitoring_application
		//-------------------------------------------
		table_name="tdm_proxy_monitoring_application";
		engine="InnoDB";
		dmTable tdm_proxy_monitoring_application=new dmTable(table_name,engine);
		tdm_proxy_monitoring_application.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_monitoring_application.columnList.add(new dmColumn("monitoring_id","int",11,"NULL",false,true,false));
		tdm_proxy_monitoring_application.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_proxy_monitoring_application);

		//-------------------------------------------
		//tdm_proxy_monitoring_blacklist
		//-------------------------------------------
		table_name="tdm_proxy_monitoring_blacklist";
		engine="InnoDB";
		dmTable tdm_proxy_monitoring_blacklist=new dmTable(table_name,engine);
		tdm_proxy_monitoring_blacklist.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_monitoring_blacklist.columnList.add(new dmColumn("proxy_id","int",11,"NULL",false,true,false));
		tdm_proxy_monitoring_blacklist.columnList.add(new dmColumn("proxy_session_id","int",11,"0",false,true,false));
		tdm_proxy_monitoring_blacklist.columnList.add(new dmColumn("blacklist_time","datetime",0,"NULL",false,true,false));
		tdm_proxy_monitoring_blacklist.columnList.add(new dmColumn("machine","varchar",100,"NULL",false,true,false));
		tdm_proxy_monitoring_blacklist.columnList.add(new dmColumn("osuser","varchar",100,"NULL",false,true,false));
		tdm_proxy_monitoring_blacklist.columnList.add(new dmColumn("dbuser","varchar",100,"NULL",false,true,false));
		tdm_proxy_monitoring_blacklist.columnList.add(new dmColumn("is_deactivated","varchar",3,"NO",false,true,false));
		tdm_proxy_monitoring_blacklist.columnList.add(new dmColumn("deactivated_by_user_id","int",11,"NULL",false,true,false));
		tdm_proxy_monitoring_blacklist.columnList.add(new dmColumn("deactivation_time","datetime",0,"NULL",false,true,false));
		tdm_proxy_monitoring_blacklist.columnList.add(new dmColumn("deactivation_note","varchar",100,"NULL",false,true,false));
		tableList.add(tdm_proxy_monitoring_blacklist);

		//-------------------------------------------
		//tdm_proxy_monitoring_columns
		//-------------------------------------------
		table_name="tdm_proxy_monitoring_columns";
		engine="MEMORY";
		dmTable tdm_proxy_monitoring_columns=new dmTable(table_name,engine);
		tdm_proxy_monitoring_columns.columnList.add(new dmColumn("id","int",11,"NULL",true,true,false));
		tdm_proxy_monitoring_columns.columnList.add(new dmColumn("proxy_id","int",11,"0",false,true,false));
		tdm_proxy_monitoring_columns.columnList.add(new dmColumn("proxy_session_id","int",11,"0",false,true,false));
		tdm_proxy_monitoring_columns.columnList.add(new dmColumn("policy_group_id","int",11,"0",false,true,false));
		tdm_proxy_monitoring_columns.columnList.add(new dmColumn("monitoring_time","datetime",0,"NULL",false,true,false));
		tdm_proxy_monitoring_columns.columnList.add(new dmColumn("catalog_name","varchar",100,"${default}",false,true,false));
		tdm_proxy_monitoring_columns.columnList.add(new dmColumn("schema_name","varchar",100,"NULL",false,true,false));
		tdm_proxy_monitoring_columns.columnList.add(new dmColumn("object_name","varchar",100,"NULL",false,true,false));
		tdm_proxy_monitoring_columns.columnList.add(new dmColumn("column_name","varchar",100,"NULL",false,true,false));
		tdm_proxy_monitoring_columns.columnList.add(new dmColumn("expression","varchar",200,"NULL",false,true,false));
		tdm_proxy_monitoring_columns.columnList.add(new dmColumn("bytes_received","int",11,"0",false,true,false));
		tableList.add(tdm_proxy_monitoring_columns);

		//-------------------------------------------
		//tdm_proxy_monitoring_columns_archive
		//-------------------------------------------
		table_name="tdm_proxy_monitoring_columns_archive";
		engine="InnoDB";
		dmTable tdm_proxy_monitoring_columns_archive=new dmTable(table_name,engine);
		tdm_proxy_monitoring_columns_archive.columnList.add(new dmColumn("id","int",11,"NULL",true,true,false));
		tdm_proxy_monitoring_columns_archive.columnList.add(new dmColumn("proxy_id","int",11,"0",false,false,false));
		tdm_proxy_monitoring_columns_archive.columnList.add(new dmColumn("proxy_session_id","int",11,"0",false,true,false));
		tdm_proxy_monitoring_columns_archive.columnList.add(new dmColumn("policy_group_id","int",11,"0",false,true,false));
		tdm_proxy_monitoring_columns_archive.columnList.add(new dmColumn("monitoring_time","datetime",0,"NULL",false,true,false));
		tdm_proxy_monitoring_columns_archive.columnList.add(new dmColumn("catalog_name","varchar",100,"${default}",false,true,false));
		tdm_proxy_monitoring_columns_archive.columnList.add(new dmColumn("schema_name","varchar",100,"NULL",false,true,false));
		tdm_proxy_monitoring_columns_archive.columnList.add(new dmColumn("object_name","varchar",100,"NULL",false,true,false));
		tdm_proxy_monitoring_columns_archive.columnList.add(new dmColumn("column_name","varchar",100,"NULL",false,true,false));
		tdm_proxy_monitoring_columns_archive.columnList.add(new dmColumn("expression","varchar",200,"NULL",false,true,false));
		tdm_proxy_monitoring_columns_archive.columnList.add(new dmColumn("bytes_received","int",11,"0",false,true,false));
		tableList.add(tdm_proxy_monitoring_columns_archive);

		//-------------------------------------------
		//tdm_proxy_monitoring_email_log
		//-------------------------------------------
		table_name="tdm_proxy_monitoring_email_log";
		engine="InnoDB";
		dmTable tdm_proxy_monitoring_email_log=new dmTable(table_name,engine);
		tdm_proxy_monitoring_email_log.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_monitoring_email_log.columnList.add(new dmColumn("proxy_id","int",11,"NULL",false,true,false));
		tdm_proxy_monitoring_email_log.columnList.add(new dmColumn("monitoring_id","int",11,"0",false,true,false));
		tdm_proxy_monitoring_email_log.columnList.add(new dmColumn("from_address","varchar",200,"NULL",false,true,false));
		tdm_proxy_monitoring_email_log.columnList.add(new dmColumn("to_address","varchar",2000,"NULL",false,true,false));
		tdm_proxy_monitoring_email_log.columnList.add(new dmColumn("email_body","text",0,"NULL",false,true,false));
		tdm_proxy_monitoring_email_log.columnList.add(new dmColumn("sent_date","datetime",0,"NULL",false,true,false));
		tdm_proxy_monitoring_email_log.columnList.add(new dmColumn("is_success","varchar",3,"NO",false,true,false));
		tdm_proxy_monitoring_email_log.columnList.add(new dmColumn("sending_logs","text",0,"NULL",false,true,false));
		tableList.add(tdm_proxy_monitoring_email_log);

		//-------------------------------------------
		//tdm_proxy_monitoring_policy_group
		//-------------------------------------------
		table_name="tdm_proxy_monitoring_policy_group";
		engine="InnoDB";
		dmTable tdm_proxy_monitoring_policy_group=new dmTable(table_name,engine);
		tdm_proxy_monitoring_policy_group.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_monitoring_policy_group.columnList.add(new dmColumn("monitoring_id","int",11,"NULL",false,true,false));
		tdm_proxy_monitoring_policy_group.columnList.add(new dmColumn("policy_group_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_proxy_monitoring_policy_group);

		//-------------------------------------------
		//tdm_proxy_monitoring_policy_rules
		//-------------------------------------------
		table_name="tdm_proxy_monitoring_policy_rules";
		engine="InnoDB";
		dmTable tdm_proxy_monitoring_policy_rules=new dmTable(table_name,engine);
		tdm_proxy_monitoring_policy_rules.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_monitoring_policy_rules.columnList.add(new dmColumn("monitoring_id","int",11,"NULL",false,true,false));
		tdm_proxy_monitoring_policy_rules.columnList.add(new dmColumn("rule_type","varchar",20,"COLUMN",false,true,false));
		tdm_proxy_monitoring_policy_rules.columnList.add(new dmColumn("rule_description","varchar",200,"NULL",false,true,false));
		tdm_proxy_monitoring_policy_rules.columnList.add(new dmColumn("rule_catalog_name","varchar",200,"NULL",false,true,false));
		tdm_proxy_monitoring_policy_rules.columnList.add(new dmColumn("rule_schema_name","varchar",200,"NULL",false,true,false));
		tdm_proxy_monitoring_policy_rules.columnList.add(new dmColumn("rule_object_name","varchar",200,"NULL",false,true,false));
		tdm_proxy_monitoring_policy_rules.columnList.add(new dmColumn("rule_column_name","varchar",200,"NULL",false,true,false));
		tdm_proxy_monitoring_policy_rules.columnList.add(new dmColumn("rule_expression","varchar",200,"NULL",false,true,false));
		tdm_proxy_monitoring_policy_rules.columnList.add(new dmColumn("is_active","varchar",3,"YES",false,true,false));
		tableList.add(tdm_proxy_monitoring_policy_rules);

		//-------------------------------------------
		//tdm_proxy_param_override
		//-------------------------------------------
		table_name="tdm_proxy_param_override";
		engine="InnoDB";
		dmTable tdm_proxy_param_override=new dmTable(table_name,engine);
		tdm_proxy_param_override.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_param_override.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_proxy_param_override.columnList.add(new dmColumn("policy_group_id","int",11,"NULL",false,true,false));
		tdm_proxy_param_override.columnList.add(new dmColumn("sql_logging","varchar",45,"SYSTEM",false,true,false));
		tdm_proxy_param_override.columnList.add(new dmColumn("iddle_timeout","varchar",45,"SYSTEM",false,true,false));
		tdm_proxy_param_override.columnList.add(new dmColumn("deny_connection","varchar",45,"NO",false,true,false));
		tdm_proxy_param_override.columnList.add(new dmColumn("calendar_id","int",11,"NULL",false,true,false));
		tdm_proxy_param_override.columnList.add(new dmColumn("valid","varchar",3,"YES",false,true,false));
		tdm_proxy_param_override.columnList.add(new dmColumn("session_validation_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_proxy_param_override);

		//-------------------------------------------
		//tdm_proxy_policy_group
		//-------------------------------------------
		table_name="tdm_proxy_policy_group";
		engine="InnoDB";
		dmTable tdm_proxy_policy_group=new dmTable(table_name,engine);
		tdm_proxy_policy_group.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_policy_group.columnList.add(new dmColumn("policy_group_name","varchar",200,"NULL",false,true,false));
		tdm_proxy_policy_group.columnList.add(new dmColumn("check_field","varchar",200,"CURRENT_USER",false,true,false));
		tdm_proxy_policy_group.columnList.add(new dmColumn("check_rule","varchar",45,"CONTAINS",false,true,false));
		tdm_proxy_policy_group.columnList.add(new dmColumn("check_parameter","text",0,"NULL",false,true,false));
		tdm_proxy_policy_group.columnList.add(new dmColumn("env_id","int",11,"NULL",false,true,false));
		tdm_proxy_policy_group.columnList.add(new dmColumn("case_sensitive","varchar",10,"YES",false,true,false));
		tdm_proxy_policy_group.columnList.add(new dmColumn("valid","varchar",3,"YES",false,true,false));
		tdm_proxy_policy_group.columnList.add(new dmColumn("record_limit","int",11,"-1",false,true,false));
		tdm_proxy_policy_group.columnList.add(new dmColumn("start_debuging","varchar",10,"NO",false,true,false));
		tableList.add(tdm_proxy_policy_group);

		//-------------------------------------------
		//tdm_proxy_rules
		//-------------------------------------------
		table_name="tdm_proxy_rules";
		engine="InnoDB";
		dmTable tdm_proxy_rules=new dmTable(table_name,engine);
		tdm_proxy_rules.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_rules.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_proxy_rules.columnList.add(new dmColumn("rule_order","int",10,"0",false,true,false));
		tdm_proxy_rules.columnList.add(new dmColumn("rule_scope","varchar",10,"DATA",false,true,false));
		tdm_proxy_rules.columnList.add(new dmColumn("rule_type","varchar",20,"CONTAINS",false,true,false));
		tdm_proxy_rules.columnList.add(new dmColumn("rule_parameter1","text",0,"NULL",false,true,false));
		tdm_proxy_rules.columnList.add(new dmColumn("env_id","int",11,"NULL",false,true,false));
		tdm_proxy_rules.columnList.add(new dmColumn("rule_parameter2","text",0,"NULL",false,true,false));
		tdm_proxy_rules.columnList.add(new dmColumn("min_match_rate","int",3,"NULL",false,true,false));
		tdm_proxy_rules.columnList.add(new dmColumn("mask_prof_id","int",11,"NULL",false,true,false));
		tdm_proxy_rules.columnList.add(new dmColumn("rule_notes","text",0,"NULL",false,true,false));
		tdm_proxy_rules.columnList.add(new dmColumn("valid","varchar",3,"YES",false,true,false));
		tableList.add(tdm_proxy_rules);

		//-------------------------------------------
		//tdm_proxy_session
		//-------------------------------------------
		table_name="tdm_proxy_session";
		engine="InnoDB";
		dmTable tdm_proxy_session=new dmTable(table_name,engine);
		tdm_proxy_session.columnList.add(new dmColumn("id","int",11,"NULL",true,true,false));
		tdm_proxy_session.columnList.add(new dmColumn("proxy_id","int",11,"NULL",false,true,false));
		tdm_proxy_session.columnList.add(new dmColumn("status","varchar",10,"NULL",false,true,false));
		tdm_proxy_session.columnList.add(new dmColumn("start_date","datetime",0,"NULL",false,true,false));
		tdm_proxy_session.columnList.add(new dmColumn("finish_date","datetime",0,"NULL",false,true,false));
		tdm_proxy_session.columnList.add(new dmColumn("username","varchar",200,"NULL",false,true,false));
		tdm_proxy_session.columnList.add(new dmColumn("session_info","text",0,"NULL",false,true,false));
		tdm_proxy_session.columnList.add(new dmColumn("last_activity_date","datetime",0,"NULL",false,true,false));
		tdm_proxy_session.columnList.add(new dmColumn("exception_time_to","datetime",0,"NULL",false,true,false));
		tdm_proxy_session.columnList.add(new dmColumn("cancel_flag","varchar",3,"NO",false,true,false));
		tdm_proxy_session.columnList.add(new dmColumn("tracing_flag","varchar",3,"NO",false,true,false));
		tableList.add(tdm_proxy_session);

		//-------------------------------------------
		//tdm_proxy_session_validation
		//-------------------------------------------
		table_name="tdm_proxy_session_validation";
		engine="InnoDB";
		dmTable tdm_proxy_session_validation=new dmTable(table_name,engine);
		tdm_proxy_session_validation.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_session_validation.columnList.add(new dmColumn("session_validation_name","varchar",200,"NULL",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("for_statement_check_regex","varchar",1000,"NULL",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("check_start","int",11,"0",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("check_duration","int",11,"60000",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("limit_session_duration","int",11,"0",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("max_attempt_count","int",11,"1",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("extraction_js_for_par1","text",0,"NULL",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("extraction_js_for_par2","text",0,"NULL",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("extraction_js_for_par3","text",0,"NULL",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("extraction_js_for_par4","text",0,"NULL",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("extraction_js_for_par5","text",0,"NULL",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("controll_method","varchar",10,"DATABASE",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("controll_statement","text",0,"NULL",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("controll_db_id","int",11,"NULL",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("expected_result","varchar",1000,"NULL",false,true,false));
		tdm_proxy_session_validation.columnList.add(new dmColumn("validate_identical_sessions","varchar",3,"NO",false,true,false));
		tableList.add(tdm_proxy_session_validation);

		//-------------------------------------------
		//tdm_proxy_statement_exception
		//-------------------------------------------
		table_name="tdm_proxy_statement_exception";
		engine="InnoDB";
		dmTable tdm_proxy_statement_exception=new dmTable(table_name,engine);
		tdm_proxy_statement_exception.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_proxy_statement_exception.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_proxy_statement_exception.columnList.add(new dmColumn("check_field","varchar",20,"SQL",false,true,false));
		tdm_proxy_statement_exception.columnList.add(new dmColumn("check_rule","varchar",45,"CONTAINS",false,true,false));
		tdm_proxy_statement_exception.columnList.add(new dmColumn("check_parameter","text",0,"NULL",false,true,false));
		tdm_proxy_statement_exception.columnList.add(new dmColumn("env_id","int",11,"NULL",false,true,false));
		tdm_proxy_statement_exception.columnList.add(new dmColumn("new_command","text",0,"NULL",false,true,false));
		tdm_proxy_statement_exception.columnList.add(new dmColumn("case_sensitive","varchar",10,"YES",false,true,false));
		tdm_proxy_statement_exception.columnList.add(new dmColumn("valid","varchar",3,"YES",false,true,false));
		tableList.add(tdm_proxy_statement_exception);

		//-------------------------------------------
		//tdm_rec_sample
		//-------------------------------------------
		table_name="tdm_rec_sample";
		engine="InnoDB";
		dmTable tdm_rec_sample=new dmTable(table_name,engine);
		tdm_rec_sample.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_rec_sample.columnList.add(new dmColumn("work_plan_id","int",11,"NULL",false,true,false));
		tdm_rec_sample.columnList.add(new dmColumn("tab_id","int",11,"NULL",false,true,false));
		tdm_rec_sample.columnList.add(new dmColumn("list_val","longtext",0,"NULL",false,true,false));
		tableList.add(tdm_rec_sample);

		//-------------------------------------------
		//tdm_ref
		//-------------------------------------------
		table_name="tdm_ref";
		engine="InnoDB";
		dmTable tdm_ref=new dmTable(table_name,engine);
		tdm_ref.columnList.add(new dmColumn("ID","int",11,"NULL",true,true,true));
		tdm_ref.columnList.add(new dmColumn("ref_type","varchar",45,"NULL",false,true,false));
		tdm_ref.columnList.add(new dmColumn("ref_name","varchar",100,"NULL",false,true,false));
		tdm_ref.columnList.add(new dmColumn("ref_desc","varchar",100,"NULL",false,true,false));
		tdm_ref.columnList.add(new dmColumn("flexval1","varchar",200,"NULL",false,true,false));
		tdm_ref.columnList.add(new dmColumn("flexval2","varchar",200,"NULL",false,true,false));
		tdm_ref.columnList.add(new dmColumn("flexval3","varchar",200,"NULL",false,true,false));
		tdm_ref.columnList.add(new dmColumn("ref_order","varchar",45,"NULL",false,true,false));
		tableList.add(tdm_ref);

		//-------------------------------------------
		//tdm_role
		//-------------------------------------------
		table_name="tdm_role";
		engine="InnoDB";
		dmTable tdm_role=new dmTable(table_name,engine);
		tdm_role.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_role.columnList.add(new dmColumn("shortcode","varchar",20,"NULL",false,true,false));
		tdm_role.columnList.add(new dmColumn("description","varchar",100,"NULL",false,true,false));
		tableList.add(tdm_role);

		//-------------------------------------------
		//tdm_seq
		//-------------------------------------------
		table_name="tdm_seq";
		engine="InnoDB";
		dmTable tdm_seq=new dmTable(table_name,engine);
		tdm_seq.columnList.add(new dmColumn("KEY_NAME","varchar",500,"NULL",false,false,false));
		tdm_seq.columnList.add(new dmColumn("VAL","int",11,"NULL",false,true,false));
		tableList.add(tdm_seq);

		//-------------------------------------------
		//tdm_tabs
		//-------------------------------------------
		table_name="tdm_tabs";
		engine="InnoDB";
		dmTable tdm_tabs=new dmTable(table_name,engine);
		tdm_tabs.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_tabs.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("db_type","varchar",20,"ORACLE",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("cat_name","varchar",100,"${default}",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("schema_name","varchar",100,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("tab_name","varchar",100,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("mask_level","varchar",45,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("tab_filter","varchar",1000,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("tab_order_stmt","varchar",1000,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("parallel_field","varchar",100,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("parallel_mod","int",11,"5",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("tab_desc","longtext",0,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("sample_size","int",11,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("sample_filter","varchar",1000,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("parallel_function","varchar",10,"MOD",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("discovery_flag","varchar",3,"YES",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("partition_flag","varchar",3,"NO",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("partition_used","varchar",3,"NO",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("export_plan","varchar",20,"EXPORT_MASKING",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("skip_drop_index","varchar",3,"NO",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("skip_drop_constraint","varchar",3,"NO",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("skip_drop_trigger","varchar",3,"NO",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("hint_after_select","varchar",1000,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("hint_before_table","varchar",1000,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("hint_after_table","varchar",1000,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("check_existence_action","varchar",20,"NONE",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("check_existence_on_fields","text",0,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("check_existence_sql","text",0,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("recursive_fields","varchar",1000,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("family_id","int",11,"NULL",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("tab_order","int",3,"1",false,true,false));
		tdm_tabs.columnList.add(new dmColumn("rollback_needed","varchar",3,"YES",false,true,false));
		tableList.add(tdm_tabs);

		//-------------------------------------------
		//tdm_tabs_need
		//-------------------------------------------
		table_name="tdm_tabs_need";
		engine="InnoDB";
		dmTable tdm_tabs_need=new dmTable(table_name,engine);
		tdm_tabs_need.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_tabs_need.columnList.add(new dmColumn("tab_id","int",11,"NULL",false,true,false));
		tdm_tabs_need.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_tabs_need.columnList.add(new dmColumn("copy_filter_id","int",11,"NULL",false,true,false));
		tdm_tabs_need.columnList.add(new dmColumn("rel_on_fields","varchar",200,"NULL",false,true,false));
		tableList.add(tdm_tabs_need);

		//-------------------------------------------
		//tdm_tabs_rel
		//-------------------------------------------
		table_name="tdm_tabs_rel";
		engine="InnoDB";
		dmTable tdm_tabs_rel=new dmTable(table_name,engine);
		tdm_tabs_rel.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_tabs_rel.columnList.add(new dmColumn("tab_id","int",11,"NULL",false,true,false));
		tdm_tabs_rel.columnList.add(new dmColumn("rel_tab_id","int",11,"NULL",false,true,false));
		tdm_tabs_rel.columnList.add(new dmColumn("rel_type","varchar",20,"NULL",false,true,false));
		tdm_tabs_rel.columnList.add(new dmColumn("pk_fields","varchar",200,"NULL",false,true,false));
		tdm_tabs_rel.columnList.add(new dmColumn("rel_on_fields","varchar",200,"NULL",false,true,false));
		tdm_tabs_rel.columnList.add(new dmColumn("rel_filter","varchar",1000,"NULL",false,true,false));
		tdm_tabs_rel.columnList.add(new dmColumn("rel_order","int",4,"0",false,true,false));
		tableList.add(tdm_tabs_rel);

		//-------------------------------------------
		//tdm_tab_comment
		//-------------------------------------------
		table_name="tdm_tab_comment";
		engine="InnoDB";
		dmTable tdm_tab_comment=new dmTable(table_name,engine);
		tdm_tab_comment.columnList.add(new dmColumn("table_owner","varchar",100,"NULL",false,true,false));
		tdm_tab_comment.columnList.add(new dmColumn("table_cat","varchar",100,"${default}",false,true,false));
		tdm_tab_comment.columnList.add(new dmColumn("table_name","varchar",100,"NULL",false,true,false));
		tdm_tab_comment.columnList.add(new dmColumn("table_comment","mediumtext",0,"NULL",false,true,false));
		tdm_tab_comment.columnList.add(new dmColumn("env_id","int",11,"NULL",false,true,false));
		tdm_tab_comment.columnList.add(new dmColumn("discard_flag","varchar",3,"NO",false,true,false));
		tdm_tab_comment.columnList.add(new dmColumn("app_type","varchar",10,"COPY",false,true,false));
		tableList.add(tdm_tab_comment);

		//-------------------------------------------
		//tdm_target
		//-------------------------------------------
		table_name="tdm_target";
		engine="InnoDB";
		dmTable tdm_target=new dmTable(table_name,engine);
		tdm_target.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_target.columnList.add(new dmColumn("target_name","varchar",100,"NULL",false,true,false));
		tableList.add(tdm_target);

		//-------------------------------------------
		//tdm_target_family_env
		//-------------------------------------------
		table_name="tdm_target_family_env";
		engine="InnoDB";
		dmTable tdm_target_family_env=new dmTable(table_name,engine);
		tdm_target_family_env.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_target_family_env.columnList.add(new dmColumn("target_id","int",11,"NULL",false,true,false));
		tdm_target_family_env.columnList.add(new dmColumn("family_id","int",11,"NULL",false,true,false));
		tdm_target_family_env.columnList.add(new dmColumn("env_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_target_family_env);

		//-------------------------------------------
		//tdm_task_assignment
		//-------------------------------------------
		table_name="tdm_task_assignment";
		engine="MEMORY";
		dmTable tdm_task_assignment=new dmTable(table_name,engine);
		tdm_task_assignment.columnList.add(new dmColumn("work_plan_id","int",11,"NULL",false,true,false));
		tdm_task_assignment.columnList.add(new dmColumn("work_package_id","int",11,"NULL",false,true,false));
		tdm_task_assignment.columnList.add(new dmColumn("task_id","int",11,"NULL",false,true,false));
		tdm_task_assignment.columnList.add(new dmColumn("last_activity_date","datetime",0,"NULL",false,true,false));
		tdm_task_assignment.columnList.add(new dmColumn("status","varchar",45,"NULL",false,true,false));
		tdm_task_assignment.columnList.add(new dmColumn("worker_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_task_assignment);

		//-------------------------------------------
		//tdm_task_summary
		//-------------------------------------------
		table_name="tdm_task_summary";
		engine="InnoDB";
		dmTable tdm_task_summary=new dmTable(table_name,engine);
		tdm_task_summary.columnList.add(new dmColumn("work_plan_id","int",11,"NULL",false,true,false));
		tdm_task_summary.columnList.add(new dmColumn("work_package_id","int",11,"NULL",false,true,false));
		tdm_task_summary.columnList.add(new dmColumn("status","varchar",20,"NULL",false,true,false));
		tdm_task_summary.columnList.add(new dmColumn("task_count","int",11,"NULL",false,true,false));
		tdm_task_summary.columnList.add(new dmColumn("avg_duration","int",11,"NULL",false,true,false));
		tdm_task_summary.columnList.add(new dmColumn("rec_count","int",11,"NULL",false,true,false));
		tdm_task_summary.columnList.add(new dmColumn("done_count","int",11,"NULL",false,true,false));
		tdm_task_summary.columnList.add(new dmColumn("success_count","int",11,"NULL",false,true,false));
		tdm_task_summary.columnList.add(new dmColumn("fail_count","int",11,"NULL",false,true,false));
		tableList.add(tdm_task_summary);

		//-------------------------------------------
		//tdm_test
		//-------------------------------------------
		table_name="tdm_test";
		engine="InnoDB";
		dmTable tdm_test=new dmTable(table_name,engine);
		tdm_test.columnList.add(new dmColumn("ID","int",11,"NULL",true,true,true));
		tdm_test.columnList.add(new dmColumn("test_name","varchar",1000,"NULL",false,true,false));
		tdm_test.columnList.add(new dmColumn("domain_id","int",11,"NULL",false,false,false));
		tdm_test.columnList.add(new dmColumn("project_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_test);


		//-------------------------------------------
		//tdm_test_call_parameter_values
		//-------------------------------------------
		table_name="tdm_test_call_parameter_values";
		engine="InnoDB";
		dmTable tdm_test_call_parameter_values=new dmTable(table_name,engine);
		tdm_test_call_parameter_values.columnList.add(new dmColumn("ID","bigint",11,"NULL",false,false,false));
		tdm_test_call_parameter_values.columnList.add(new dmColumn("tree_id","bigint",11,"0",false,true,false));
		tdm_test_call_parameter_values.columnList.add(new dmColumn("referenced_test_id","bigint",11,"0",false,true,false));
		tdm_test_call_parameter_values.columnList.add(new dmColumn("parameter_id","bigint",11,"0",false,true,false));
		tdm_test_call_parameter_values.columnList.add(new dmColumn("parameter_value","varchar",1000,"NULL",false,true,false));
		tableList.add(tdm_test_call_parameter_values);

		//-------------------------------------------
		//tdm_test_domain
		//-------------------------------------------
		table_name="tdm_test_domain";
		engine="InnoDB";
		dmTable tdm_test_domain=new dmTable(table_name,engine);
		tdm_test_domain.columnList.add(new dmColumn("ID","int",11,"NULL",true,true,true));
		tdm_test_domain.columnList.add(new dmColumn("domain_name","varchar",100,"NULL",false,true,false));
		tdm_test_domain.columnList.add(new dmColumn("is_active","varchar",3,"YES",false,true,false));
		tableList.add(tdm_test_domain);

		//-------------------------------------------
		//tdm_test_domain_user
		//-------------------------------------------
		table_name="tdm_test_domain_user";
		engine="InnoDB";
		dmTable tdm_test_domain_user=new dmTable(table_name,engine);
		tdm_test_domain_user.columnList.add(new dmColumn("ID","int",11,"NULL",true,true,true));
		tdm_test_domain_user.columnList.add(new dmColumn("domain_id","int",11,"NULL",false,true,false));
		tdm_test_domain_user.columnList.add(new dmColumn("user_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_test_domain_user);

		//-------------------------------------------
		//tdm_test_exec
		//-------------------------------------------
		table_name="tdm_test_exec";
		engine="InnoDB";
		dmTable tdm_test_exec=new dmTable(table_name,engine);
		tdm_test_exec.columnList.add(new dmColumn("ID","int",11,"NULL",true,true,true));
		tdm_test_exec.columnList.add(new dmColumn("TEST_ID","int",11,"NULL",false,true,false));
		tdm_test_exec.columnList.add(new dmColumn("ENVIRONMENT_ID","int",11,"NULL",false,true,false));
		tdm_test_exec.columnList.add(new dmColumn("EXEC_NOTE","varchar",1000,"NULL",false,true,false));
		tdm_test_exec.columnList.add(new dmColumn("EXEC_INPUT","varchar",1000,"NULL",false,true,false));
		tdm_test_exec.columnList.add(new dmColumn("EXEC_START","datetime",0,"NULL",false,true,false));
		tdm_test_exec.columnList.add(new dmColumn("EXEC_END","datetime",0,"NULL",false,true,false));
		tdm_test_exec.columnList.add(new dmColumn("EXEC_STATUS","varchar",45,"NEW",false,true,false));
		tdm_test_exec.columnList.add(new dmColumn("EXEC_RESULT","varchar",45,"NONE",false,true,false));
		tdm_test_exec.columnList.add(new dmColumn("EXEC_ERR_MSG","longtext",0,"NULL",false,true,false));
		tdm_test_exec.columnList.add(new dmColumn("EXEC_USER","varchar",100,"NULL",false,true,false));
		tdm_test_exec.columnList.add(new dmColumn("CRDATE","varchar",100,"NULL",false,true,false));
		tableList.add(tdm_test_exec);

		//-------------------------------------------
		//tdm_test_exec_step
		//-------------------------------------------
		table_name="tdm_test_exec_step";
		engine="InnoDB";
		dmTable tdm_test_exec_step=new dmTable(table_name,engine);
		tdm_test_exec_step.columnList.add(new dmColumn("ID","int",11,"NULL",true,true,true));
		tdm_test_exec_step.columnList.add(new dmColumn("TEST_EXEC_ID","int",11,"NULL",false,true,false));
		tdm_test_exec_step.columnList.add(new dmColumn("STEP_ID","int",11,"NULL",false,true,false));
		tdm_test_exec_step.columnList.add(new dmColumn("STEP_NAME","varchar",100,"NULL",false,true,false));
		tdm_test_exec_step.columnList.add(new dmColumn("STEP_DESC","varchar",4000,"NULL",false,true,false));
		tdm_test_exec_step.columnList.add(new dmColumn("STEP_TYPE","varchar",45,"NULL",false,false,false));
		tdm_test_exec_step.columnList.add(new dmColumn("STEP_IN","longtext",0,"NULL",false,true,false));
		tdm_test_exec_step.columnList.add(new dmColumn("SQLORXML","longtext",0,"NULL",false,true,false));
		tdm_test_exec_step.columnList.add(new dmColumn("STEP_OUT","longtext",0,"NULL",false,true,false));
		tdm_test_exec_step.columnList.add(new dmColumn("STEP_STATUS","varchar",15,"NULL",false,true,false));
		tdm_test_exec_step.columnList.add(new dmColumn("STEP_RESULT","longtext",0,"NULL",false,true,false));
		tdm_test_exec_step.columnList.add(new dmColumn("STEP_ERR_MSG","longtext",0,"NULL",false,true,false));
		tdm_test_exec_step.columnList.add(new dmColumn("STEP_SEL_REPORT","varchar",1000,"NULL",false,true,false));
		tableList.add(tdm_test_exec_step);

		//-------------------------------------------
		//tdm_test_run
		//-------------------------------------------
		table_name="tdm_test_run";
		engine="InnoDB";
		dmTable tdm_test_run=new dmTable(table_name,engine);
		tdm_test_run.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_test_run.columnList.add(new dmColumn("script_id","int",11,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("task_id","int",11,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("domain_instance_id","int",11,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("automation_lib","varchar",200,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("test_status","varchar",10,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("crdate","datetime",0,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("startdate","datetime",0,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("enddate","datetime",0,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("script_body","mediumblob",0,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("params_in","text",0,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("params_out","text",0,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("run_host_info","text",0,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("duration","int",11,"NULL",false,true,false));
		tdm_test_run.columnList.add(new dmColumn("work_package_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_test_run);

		//-------------------------------------------
		//tdm_test_run_step
		//-------------------------------------------
		table_name="tdm_test_run_step";
		engine="InnoDB";
		dmTable tdm_test_run_step=new dmTable(table_name,engine);
		tdm_test_run_step.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_test_run_step.columnList.add(new dmColumn("script_id","int",11,"NULL",false,false,false));
		tdm_test_run_step.columnList.add(new dmColumn("test_run_id","int",11,"NULL",false,false,false));
		tdm_test_run_step.columnList.add(new dmColumn("test_run_step","int",11,"NULL",false,false,false));
		tdm_test_run_step.columnList.add(new dmColumn("step_status","varchar",10,"NULL",false,true,false));
		tdm_test_run_step.columnList.add(new dmColumn("command","varchar",100,"NULL",false,false,false));
		tdm_test_run_step.columnList.add(new dmColumn("command_parameters","text",0,"NULL",false,true,false));
		tdm_test_run_step.columnList.add(new dmColumn("command_err","text",0,"NULL",false,true,false));
		tdm_test_run_step.columnList.add(new dmColumn("duration","int",11,"NULL",false,true,false));
		tdm_test_run_step.columnList.add(new dmColumn("attachment","mediumblob",0,"NULL",false,true,false));
		tableList.add(tdm_test_run_step);

		//-------------------------------------------
		//tdm_test_step
		//-------------------------------------------
		table_name="tdm_test_step";
		engine="InnoDB";
		dmTable tdm_test_step=new dmTable(table_name,engine);
		tdm_test_step.columnList.add(new dmColumn("ID","int",11,"NULL",true,true,true));
		tdm_test_step.columnList.add(new dmColumn("test_id","int",11,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("step_type","varchar",40,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("step_name","varchar",100,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("step_desc","varchar",4000,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("step_in","varchar",4000,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("sqlorxml","longtext",0,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("step_order","int",11,"1",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("ref_node_id","int",11,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("ref_step_id","int",11,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("check_true_action","varchar",45,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("check_true_step_id","int",11,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("check_false_action","varchar",45,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("check_false_step_id","int",11,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("check_timeout","varchar",45,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("check_interval","varchar",45,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("check_parameter","varchar",1000,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("check_operand","varchar",45,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("check_value","varchar",100,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("var_name","varchar",100,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("var_type","varchar",45,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("var_rand_num_start","int",11,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("var_rand_num_end","int",11,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("var_rand_str_len","int",11,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("var_seq_start","int",11,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("var_seq_end","int",11,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("var_rand_list","longtext",0,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("var_seq_list","longtext",0,"NULL",false,true,false));
		tdm_test_step.columnList.add(new dmColumn("var_xpath_query","varchar",500,"NULL",false,true,false));
		tableList.add(tdm_test_step);

		//-------------------------------------------
		//tdm_test_tree
		//-------------------------------------------
		table_name="tdm_test_tree";
		engine="InnoDB";
		dmTable tdm_test_tree=new dmTable(table_name,engine);
		tdm_test_tree.columnList.add(new dmColumn("ID","bigint",11,"NULL",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("parent_tree_id","bigint",11,"0",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("referenced_test_id","bigint",11,"0",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("order_by","int",5,"1",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("module","varchar",20,"NULL",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("domain_id","int",11,"NULL",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("tree_type","varchar",10,"container",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("tree_title","varchar",1000,"NULL",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("tree_description","text",0,"NULL",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("created_by","int",11,"0",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("creation_date","datetime",0,"CURRENT_TIMESTAMP",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("checked_out_by","int",11,"0",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("version","int",11,"0",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("checkin_date","datetime",0,"NULL",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("checkout_date","datetime",0,"NULL",false,true,false));
		tdm_test_tree.columnList.add(new dmColumn("checkin_note","varchar",1000,"NULL",false,true,false));
		tableList.add(tdm_test_tree);

		//-------------------------------------------
		//tdm_test_tree_check_history
		//-------------------------------------------
		table_name="tdm_test_tree_check_history";
		engine="InnoDB";
		dmTable tdm_test_tree_check_history=new dmTable(table_name,engine);
		tdm_test_tree_check_history.columnList.add(new dmColumn("ID","bigint",11,"NULL",false,true,false));
		tdm_test_tree_check_history.columnList.add(new dmColumn("tree_id","bigint",11,"0",false,true,false));
		tdm_test_tree_check_history.columnList.add(new dmColumn("action_type","varchar",10,"CHECKIN",false,true,false));
		tdm_test_tree_check_history.columnList.add(new dmColumn("action_by","int",11,"0",false,true,false));
		tdm_test_tree_check_history.columnList.add(new dmColumn("action_date","datetime",0,"NULL",false,true,false));
		tdm_test_tree_check_history.columnList.add(new dmColumn("action_note","varchar",1000,"NULL",false,true,false));
		tdm_test_tree_check_history.columnList.add(new dmColumn("version","int",11,"0",false,true,false));
		tableList.add(tdm_test_tree_check_history);

		//-------------------------------------------
		//tdm_test_tree_fields
		//-------------------------------------------
		table_name="tdm_test_tree_fields";
		engine="InnoDB";
		dmTable tdm_test_tree_fields=new dmTable(table_name,engine);
		tdm_test_tree_fields.columnList.add(new dmColumn("ID","bigint",11,"NULL",false,true,false));
		tdm_test_tree_fields.columnList.add(new dmColumn("order_by","int",5,"1",false,true,false));
		tdm_test_tree_fields.columnList.add(new dmColumn("module","varchar",20,"NULL",false,true,false));
		tdm_test_tree_fields.columnList.add(new dmColumn("domain_id","int",11,"NULL",false,true,false));
		tdm_test_tree_fields.columnList.add(new dmColumn("tree_type","varchar",10,"element",false,true,false));
		tdm_test_tree_fields.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_test_tree_fields);

		//-------------------------------------------
		//tdm_test_tree_group
		//-------------------------------------------
		table_name="tdm_test_tree_group";
		engine="InnoDB";
		dmTable tdm_test_tree_group=new dmTable(table_name,engine);
		tdm_test_tree_group.columnList.add(new dmColumn("ID","bigint",11,"NULL",false,true,false));
		tdm_test_tree_group.columnList.add(new dmColumn("tree_id","bigint",11,"0",false,true,false));
		tdm_test_tree_group.columnList.add(new dmColumn("group_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_test_tree_group);

		//-------------------------------------------
		//tdm_test_tree_link
		//-------------------------------------------
		table_name="tdm_test_tree_link";
		engine="InnoDB";
		dmTable tdm_test_tree_link=new dmTable(table_name,engine);
		tdm_test_tree_link.columnList.add(new dmColumn("ID","bigint",11,"NULL",false,true,false));
		tdm_test_tree_link.columnList.add(new dmColumn("tree_id","bigint",11,"0",false,true,false));
		tdm_test_tree_link.columnList.add(new dmColumn("module","varchar",20,"NULL",false,true,false));
		tdm_test_tree_link.columnList.add(new dmColumn("linked_tree_id","bigint",11,"0",false,true,false));
		tableList.add(tdm_test_tree_link);

		//-------------------------------------------
		//tdm_test_tree_parameters
		//-------------------------------------------
		table_name="tdm_test_tree_parameters";
		engine="InnoDB";
		dmTable tdm_test_tree_parameters=new dmTable(table_name,engine);
		tdm_test_tree_parameters.columnList.add(new dmColumn("ID","bigint",11,"NULL",false,true,false));
		tdm_test_tree_parameters.columnList.add(new dmColumn("tree_id","bigint",11,"0",false,true,false));
		tdm_test_tree_parameters.columnList.add(new dmColumn("parameter_direction","varchar",3,"IN",false,true,false));
		tdm_test_tree_parameters.columnList.add(new dmColumn("parameter_scope","varchar",6,"GLOBAL",false,true,false));
		tdm_test_tree_parameters.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		tdm_test_tree_parameters.columnList.add(new dmColumn("parameter_title","varchar",200,"NULL",false,true,false));
		tdm_test_tree_parameters.columnList.add(new dmColumn("parameter_name","varchar",100,"NULL",false,true,false));
		tdm_test_tree_parameters.columnList.add(new dmColumn("default_value","varchar",1000,"NULL",false,true,false));
		tableList.add(tdm_test_tree_parameters);

		//-------------------------------------------
		//tdm_test_tree_values
		//-------------------------------------------
		table_name="tdm_test_tree_values";
		engine="InnoDB";
		dmTable tdm_test_tree_values=new dmTable(table_name,engine);
		tdm_test_tree_values.columnList.add(new dmColumn("ID","bigint",11,"NULL",false,true,false));
		tdm_test_tree_values.columnList.add(new dmColumn("tree_id","bigint",11,"0",false,true,false));
		tdm_test_tree_values.columnList.add(new dmColumn("flex_field_id","int",11,"NULL",false,true,false));
		tdm_test_tree_values.columnList.add(new dmColumn("val_string","varchar",1000,"NULL",false,true,false));
		tdm_test_tree_values.columnList.add(new dmColumn("val_memo","text",0,"NULL",false,true,false));
		tdm_test_tree_values.columnList.add(new dmColumn("val_datetime","datetime",0,"NULL",false,true,false));
		tdm_test_tree_values.columnList.add(new dmColumn("val_numeric","decimal",0,"NULL",false,true,false));
		tdm_test_tree_values.columnList.add(new dmColumn("created_by","int",11,"0",false,true,false));
		tdm_test_tree_values.columnList.add(new dmColumn("creation_date","datetime",0,"CURRENT_TIMESTAMP",false,true,false));
		tableList.add(tdm_test_tree_values);

		//-------------------------------------------
		//tdm_user
		//-------------------------------------------
		table_name="tdm_user";
		engine="InnoDB";
		dmTable tdm_user=new dmTable(table_name,engine);
		tdm_user.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_user.columnList.add(new dmColumn("username","varchar",100,"NULL",false,true,false));
		tdm_user.columnList.add(new dmColumn("password","varchar",100,"NULL",false,true,false));
		tdm_user.columnList.add(new dmColumn("email","varchar",200,"NULL",false,true,false));
		tdm_user.columnList.add(new dmColumn("fname","varchar",50,"NULL",false,true,false));
		tdm_user.columnList.add(new dmColumn("lname","varchar",50,"NULL",false,true,false));
		tdm_user.columnList.add(new dmColumn("valid","varchar",1,"Y",false,true,false));
		tdm_user.columnList.add(new dmColumn("lang","varchar",20,"NULL",false,true,false));
		tdm_user.columnList.add(new dmColumn("authentication_method","varchar",6,"SYSTEM",false,true,false));
		tdm_user.columnList.add(new dmColumn("domain_id","int",11,"NULL",false,true,false));
		tdm_user.columnList.add(new dmColumn("module","varchar",20,"NULL",false,true,false));
		tableList.add(tdm_user);

		//-------------------------------------------
		//tdm_user_role
		//-------------------------------------------
		table_name="tdm_user_role";
		engine="InnoDB";
		dmTable tdm_user_role=new dmTable(table_name,engine);
		tdm_user_role.columnList.add(new dmColumn("user_id","int",11,"NULL",false,true,false));
		tdm_user_role.columnList.add(new dmColumn("role_id","int",11,"NULL",false,true,false));
		tableList.add(tdm_user_role);

		//-------------------------------------------
		//tdm_worker
		//-------------------------------------------
		table_name="tdm_worker";
		engine="MEMORY";
		dmTable tdm_worker=new dmTable(table_name,engine);
		tdm_worker.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_worker.columnList.add(new dmColumn("worker_name","varchar",100,"NULL",false,true,false));
		tdm_worker.columnList.add(new dmColumn("status","varchar",45,"FREE",false,true,false));
		tdm_worker.columnList.add(new dmColumn("last_heartbeat","datetime",0,"NULL",false,true,false));
		tdm_worker.columnList.add(new dmColumn("hostname","varchar",100,"NULL",false,true,false));
		tdm_worker.columnList.add(new dmColumn("assign_date","datetime",0,"NULL",false,true,false));
		tdm_worker.columnList.add(new dmColumn("start_date","datetime",0,"NULL",false,true,false));
		tdm_worker.columnList.add(new dmColumn("finish_date","datetime",0,"NULL",false,true,false));
		tdm_worker.columnList.add(new dmColumn("hiring_master_id","int",11,"NULL",false,true,false));
		tdm_worker.columnList.add(new dmColumn("hiring_date","datetime",0,"NULL",false,true,false));
		tdm_worker.columnList.add(new dmColumn("cancel_flag","varchar",3,"NULL",false,true,false));
		tableList.add(tdm_worker);

		//-------------------------------------------
		//tdm_work_package
		//-------------------------------------------
		table_name="tdm_work_package";
		engine="InnoDB";
		dmTable tdm_work_package=new dmTable(table_name,engine);
		tdm_work_package.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_work_package.columnList.add(new dmColumn("wp_name","varchar",1000,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("original_wpack_id","int",11,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("work_plan_id","int",11,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("status","varchar",45,"NEW",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("master_id","int",11,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("execution_order","int",5,"1",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("tab_id","int",11,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("schema_name","varchar",2000,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("table_name","varchar",100,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("mask_level","varchar",45,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("filter_condition","varchar",1000,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("parallel_condition","varchar",1000,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("order_by_stmt","varchar",1000,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("sql_statement","text",0,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("mask_params","text",0,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("create_date","datetime",0,"CURRENT_TIMESTAMP",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("assign_date","datetime",0,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("start_date","datetime",0,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("end_date","datetime",0,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("last_activity_date","datetime",0,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("duration","int",11,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("export_count","int",11,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("all_count","int",11,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("done_count","int",11,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("success_count","int",11,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("fail_count","int",11,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("err_info","longtext",0,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("last_rowid","varchar",100,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("sample_size","int",11,"NULL",false,true,false));
		tdm_work_package.columnList.add(new dmColumn("sample_filter","varchar",1000,"NULL",false,true,false));
		tableList.add(tdm_work_package);

		//-------------------------------------------
		//tdm_work_plan
		//-------------------------------------------
		table_name="tdm_work_plan";
		engine="InnoDB";
		dmTable tdm_work_plan=new dmTable(table_name,engine);
		tdm_work_plan.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_work_plan.columnList.add(new dmColumn("work_plan_name","varchar",1000,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("wplan_type","varchar",20,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("status","varchar",45,"NEW",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("cancel_flag","varchar",3,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("created_by","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("create_date","datetime",0,"CURRENT_TIMESTAMP",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("start_date","datetime",0,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("end_date","datetime",0,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("last_activity_date","datetime",0,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("on_error_action","varchar",10,"CONTINUE",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("execution_type","varchar",10,"PARALLEL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("env_id","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("app_id","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("REC_SIZE_PER_TASK","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("TASK_SIZE_PER_WORKER","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("BULK_UPDATE_REC_COUNT","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("COMMIT_LENGTH","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("UPDATE_WPACK_COUNTS_INTERVAL","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("RUN_TYPE","varchar",45,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("INVALID_MESSAGE","longtext",0,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("WARNING_MESSAGE","longtext",0,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("target_owner_info","longtext",0,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("master_limit","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("worker_limit","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("prep_script_log","mediumtext",0,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("post_script_log","mediumtext",0,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("target_env_id","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("copy_filter","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("copy_filter_bind","varchar",1000,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("copy_rec_count","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("email_address","varchar",100,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("run_options","varchar",1000,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("post_script","mediumtext",0,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("copy_repeat_count","int",11,"NULL",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("repeat_period","varchar",20,"NONE",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("repeat_by","int",5,"0",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("main_work_plan_id","int",11,"0",false,true,false));
		tdm_work_plan.columnList.add(new dmColumn("repeat_parameters","text",0,"NULL",false,true,false));
		tableList.add(tdm_work_plan);

		//-------------------------------------------
		//tdm_work_plan_dependency
		//-------------------------------------------
		table_name="tdm_work_plan_dependency";
		engine="InnoDB";
		dmTable tdm_work_plan_dependency=new dmTable(table_name,engine);
		tdm_work_plan_dependency.columnList.add(new dmColumn("id","int",11,"NULL",true,true,true));
		tdm_work_plan_dependency.columnList.add(new dmColumn("work_plan_id","int",11,"NULL",false,true,false));
		tdm_work_plan_dependency.columnList.add(new dmColumn("depended_work_plan_id","int",11,"NULL",false,true,false));
		tdm_work_plan_dependency.columnList.add(new dmColumn("dependency_order","int",11,"0",false,true,false));
		tableList.add(tdm_work_plan_dependency);



		
	}
	//-------------------------------
	boolean checkDatabase(Connection conn, String owner) {
		String sql="show databases";
		ArrayList<String[]> arr=ddmLib.getDbArray(conn, sql, Integer.MAX_VALUE, null, 0);
		for (int i=0;i<arr.size();i++) {
			String schema_name=arr.get(i)[0];
			if (schema_name.equalsIgnoreCase(owner)) return true;
		}
		return false;
	}
	//-------------------------------
	public void syncDM(Connection conn) {
		
		if (conn==null) {
			System.out.println("Connection was invalid.");
			return;
		}
		
		String owner="";
		ArrayList<String[]> arr=ddmLib.getDbArray(conn, "select database()", 1, null, 0);
		if (arr!=null && arr.size()==1) 
			owner=arr.get(0)[0];
		
		boolean is_SchemaExists=checkDatabase(conn,owner);
		
		if (!is_SchemaExists) {
			System.out.println("Schema is not exists");
			return;
		}
		
		for (int t=0;t<tableList.size();t++) {
			dmTable table=tableList.get(t);
			
			ArrayList<String> scriptList=table.generateInstallScript(conn, owner);
			
			for (int s=0;s<scriptList.size();s++) {
				String script=scriptList.get(s);
				
				boolean is_ok=ddmLib.execSingleUpdateSQL(conn, script, null);
				
				System.out.println(script+" ["+is_ok+"]");
			}
		}
	}
	
	
	
}
