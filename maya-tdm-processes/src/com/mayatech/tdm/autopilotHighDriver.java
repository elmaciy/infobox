package com.mayatech.tdm;

import java.awt.AWTException;
import java.awt.Robot;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Properties;

import org.openqa.selenium.WebElement;

import com.mayatech.baseLibs.genLib;

public class autopilotHighDriver {
	
	
	Object  autoDriver=null;
	Robot robot=null;
	
	@SuppressWarnings("rawtypes")
	HashMap hm = new HashMap();

	
	final String DIRECTION_NEAR="NEAR";
	final String DIRECTION_BY="BY";
	final String DIRECTION_NEXTTO="NEXTTO";
	final String DIRECTION_EAST="EAST";
	final String DIRECTION_WEST="WEST";
	final String DIRECTION_NORTH="NORTH";
	final String DIRECTION_SOUTH="SOUTH";
	
	final String TAG_INPUT="input";
	final String TAG_SELECT="select";
	final String TAG_TEXTAREA="textarea";
	final String TAG_BUTTON="button";
	final String TAG_LINK="a";
	
	final String INPUT_TYPE_NULL="";
	final String INPUT_TYPE_TEXT="text";
	final String INPUT_TYPE_BUTTON="button";
	final String INPUT_TYPE_CHECKBOX="checkbox";
	final String INPUT_TYPE_SUBMIT="submit";
	final String INPUT_TYPE_RADIO="radio";
	
	
	static final String TEST_TERMINATION_SUCCESS="###TEST_RESULT_SUCCESS###";
	static final String TEST_TERMINATION_FAIL="###TEST_RESULT_FAIL###";
	static final String TEST_TERMINATION_RETRY="###TEST_RESULT_RETRY###";
	
	final String LAST_ELEMENT_LOCATED="LAST_ELEMENT_LOCATED";
	
	String report_img_path="";
	//StringBuilder report=new StringBuilder();
	int command_order=0;
	
	
	
	
	public static final String AUTO_REPORT_HEADER="<html>\n"+
			"<header>\n"+
				"<title>#HTMLTITLE#</title>\n"+
				"<meta charset=\"UTF-8\">\n"+
			"</header>\n"+
			"<body>\n";
		
	public static final String AUTO_REPORT_INFO="<table width=\"100%\">\n"+
				"<tr>\n"+
				"<td align=right><b>Test Name : </b></td>"+
				"<td colspan=7>#TESTNAME#</td>\n"+
				"</tr>\n"+
				"<tr>\n"+
				"<td align=right><b>Execution Info : </b></td>"+
				"<td colspan=7>#EXECUTIONINFO#</td>\n"+
				"</tr>\n"+
				"<tr>\n"+
				"<td align=right><b>Status : </b></td><td>#STATUS#</td>"+
				"<td align=right><b>Start Time : </b></td><td>#START#</td>"+
				"<td align=right><b>End Time : </b></td><td>#END#</td>"+
				"<td align=right><b>Duration : </b></td><td>#DURATION#</td>"+
				"</tr>\n"+
				"</table>\n"+
				
				"<table border=1 cellspacing=0 cellpadding=0 width=\"100%\">\n";

	public static final String AUTO_REPORT_FOOTER="\n</table>\n</body>\n</html>";	
	
	
	static final String AUTO_REPORT_COMMAND_LINE=""+
			"<tr>\n"+
			"<td width=250px align=right><b>#COMMANDEXECUTED#</b></td>\n"+
			"<td>#COMMANDPARAMETERS#</td>\n"+
			"</tr>\n"+
			"";
	
	static final String AUTO_REPORT_STEP_LINE=
			"<tr>\n"+
			"<td colspan=2 align=center bgcolor=#FAFAFA><h3>#STEPNAME#</h3></td>\n"+
			"</tr>\n";
	
	
	static final String AUTO_REPORT_EXCEPTION_LINE=
			"<tr>\n"+
			"<td width=250px align=right><b>ERROR : </b></td>\n"+
			"<td><font color=red>#EXCEPTION#</font></td>\n"+
			"</tr>\n";
	
	static final String AUTO_REPORT_SCREENSHOT_LINE=
			"<tr>\n"+
			"<td width=250px align=right><b>ScreenShot </b></td>\n"+
			"<td><a href=\"#SCREENSHOTFILE#\" target=_new><img width=\"20%\" height=\"20%\" border=2 src=\"#SCREENSHOTFILE#\"></a></td>\n"+
			"</tr>\n";	
	
	
	
	
	Date start_time=new Date();
	Date end_time=new Date();
	long start_ts=System.currentTimeMillis();

	String test_name="xxxx test";
	String test_execution_status="SUCCESS";
	
	
	String current_reported_step="";
	String last_reported_step="";
	
	boolean is_terminated=false;
	
	int screenshot_no=0;
	
	ConfDBOper d=null;
	
	
	//*********************************************************
	Method getMethodByName(String methodname) {
	//*********************************************************
		
		if (
				!methodname.equals("terminateTest") && 
				!methodname.equals("getLastException") && 
				!methodname.equals("resetException") && 
				!methodname.equals("screenShot")
				) {
			String exception=getLastException();
			if (exception.length()>0) {
				terminateTest();			
				
			}
		}
		
		
		Method[] methods=autoDriver.getClass().getMethods();
		for (int i=0;i<methods.length;i++) {
			Method a_method=methods[i];
			if (a_method.getName().equals(methodname)) {
				
				if (
					!methodname.equals("resetException") 
					&& !methodname.equals("terminateTest")  
					&& !methodname.equals("getLastException")
					&& !methodname.equals("screenShot")
					) 
						methodRun("resetException");
				
				return a_method;
			}
		}
		System.out.println("No such method found : " + methodname);
		return null;
	}
		
	

	//************************************************
	String getLastException() {
		Method method=getMethodByName("getLastException");
		if (method==null) return "";
		try {
			return (String) method.invoke(autoDriver);
		} catch(Exception e) {
			return "";
		}
		
	}
	
	//*************************************************
	void initialize() {
	//*************************************************
	initialize(0);
	}
	
	boolean is_initiated=false;
	int RUNNING_work_plan_id=0;
	
	//*************************************************
	void initialize(int run_id) {
	//*************************************************
		is_initiated=false;
		RUNNING_work_plan_id=0;
		try {
			robot=new Robot();
		} catch (AWTException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		
		for (int i=1;i<=100;i++)
			hm.put("PARAM_$"+i, "");
		
		hm.put("EMPTY","");
		
		Class autoClass=null;
		//report.setLength(0);

		
		d=new ConfDBOper(false);
		if (d==null) terminateTest();
		
		if (run_id>0)
			script_run_id=run_id;
		else {
			try {script_run_id=Integer.parseInt(genLib.getEnvValue("CONFIG_AUTOMATION_SCRIPT_RUN_ID").trim());} 
			catch(Exception e) {
				e.printStackTrace();
				System.out.println("no such script run id found : " + genLib.getEnvValue("CONFIG_AUTOMATION_SCRIPT_RUN_ID"));
				//terminateTest();
			}
			
			try {d.worker_id=Integer.parseInt(genLib.getEnvValue("CONFIG_AUTOMATION_WORKER_ID").trim());} 
			catch(Exception e) {
				System.out.println("No Worker Found, running standalone...");
				d.worker_id=0;
			}
			
		}
		
		System.out.println("Execution test with run id : " + script_run_id);
		
		String sql="select script_id, domain_instance_id, automation_lib, params_in, run_host_info, work_package_id  " + 
					" from tdm_test_run where id="+script_run_id;
		ArrayList<String[]> runArr=d.getDbArrayConf(sql, 1);
		
		
		if (runArr==null || runArr.size()==0) {
			System.out.println("no such run record found with run id : " + script_run_id);
			terminateTest();
		}
		
		
		
		script_id=Integer.parseInt(runArr.get(0)[0]);
		domain_instance_id=Integer.parseInt(runArr.get(0)[1]);
		String className=runArr.get(0)[2];
		String params_in=runArr.get(0)[3];
		String run_host_info =runArr.get(0)[4];
		String work_package_id =runArr.get(0)[5];
		
		if (!work_package_id.equals("0")) {
			sql="select work_plan_id from tdm_work_package where id="+work_package_id;
			try {
				RUNNING_work_plan_id=Integer.parseInt(d.getDbArrayConf(sql, 1).get(0)[0]);
				d.loadRunParams(RUNNING_work_plan_id);
			} catch(Exception e) {}
		}
		

		loadDomainScriptParams(domain_instance_id, script_id,params_in );
		
		
		
		sql="delete from tdm_test_run_step where test_run_id="+script_run_id;
		d.execDBConf(sql);
		
		Properties props=new Properties();

		String[] arr=run_host_info.split(";");
		if (arr!=null & arr.length>0) {
			for (int i=0;i<arr.length;i++) {
				String aprop=arr[i];
				if (aprop.contains("=")) {
					String prop=aprop.split("=")[0];
					String val="";
					try{val=aprop.substring(aprop.indexOf("=")+1);} catch(Exception e) {val="";}
					props.put(prop, val);		
					System.out.println("** Properties put " + prop + " = " + val);
				}
			}
		}
		
		try {
			autoClass=Class.forName(className);
		} catch (ClassNotFoundException e) {
			
			e.printStackTrace();
		}
		
		if (autoClass==null) {
			System.out.println("Exception@initialize : no such class found " + className);
			terminateTest();
		}

		
		try {
			 autoDriver=autoClass.newInstance();
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("Exception@initialize : Class instance cannot be created : " + className);
			terminateTest();
		}
		
		
		if (autoDriver==null) {
			System.out.println("Exception@initialize :instance could not created");
			return;
		}
		
		System.out.println("New autoDriver instance created succesfully."+ autoDriver.hashCode());
		
		System.out.println("initializing new execution slot...");
		
		
		
		Method method=getMethodByName("initializeTest");
		
		try {
			method.invoke(autoDriver, props);
		} catch (Exception e) {
			System.out.println("Exception@initialize : " + e.getMessage());
			e.printStackTrace();
			d.resumeTasksByWorkerId(d.worker_id);
			d.setWorkerStatus("FREE");
			terminateTest(true,false, null);
		}
		
		if (!is_terminated) {
			String report_base_dir=d.nvl(d.getParamByName("TDM_PROCESS_HOME"),System.getProperty("user.home"));
			
			String report_sub_dir=report_base_dir+File.separator+"temp";
			createDir(report_sub_dir);
			
			report_img_path=report_sub_dir+File.separator+"img";
			createDir(report_img_path);
		}
		
		is_initiated=true;
		
	}
	
	
	
	
	//************************************************
	void methodRun(String methodName) {
		ArrayList<String> params=new ArrayList<String>();
		methodRun(methodName,params);
	}

	//************************************************
	void methodRun(String methodName, String par1) {
		ArrayList<String> params=new ArrayList<String>();
		params.add(par1);
		methodRun(methodName,params);
	}
	
	//************************************************
		void methodRun(String methodName, String par1, String par2) {
			ArrayList<String> params=new ArrayList<String>();
			params.add(par1);
			params.add(par2);
			methodRun(methodName,params);
		}
	//************************************************
	void methodRun(String methodName, String par1, String par2, String par3) {
		ArrayList<String> params=new ArrayList<String>();
		params.add(par1);
		params.add(par2);
		params.add(par3);
		methodRun(methodName,params);
	}	
	//************************************************
	void methodRun(String methodName, String par1, String par2, String par3, String par4) {
		ArrayList<String> params=new ArrayList<String>();
		params.add(par1);
		params.add(par2);
		params.add(par3);
		params.add(par4);
		methodRun(methodName,params);
	}
	//************************************************
	void methodRun(String methodName, String par1, String par2, String par3, String par4, String par5) {
		ArrayList<String> params=new ArrayList<String>();
		params.add(par1);
		params.add(par2);
		params.add(par3);
		params.add(par4);
		params.add(par5);
		methodRun(methodName,params);
	}	
	
	//************************************************
		void methodRun(String methodName, String par1, String par2, String par3, String par4, String par5, String par6) {
			ArrayList<String> params=new ArrayList<String>();
			params.add(par1);
			params.add(par2);
			params.add(par3);
			params.add(par4);
			params.add(par5);
			params.add(par6);
			methodRun(methodName,params);
		}	
		
	//*********************************************************
	void makeReportForCommand(String methodName, ArrayList<String> params) {
		
		if (is_terminated) return;
	
		String params_text="";
	
		if (params.size()>0) params_text=params_text+"(";
		
		for (int i=0;i<params.size();i++) {
			String a_param=params.get(i);
			
			if (i>0) params_text=params_text+", ";
			params_text=params_text+"'"+a_param+"'";
		}
		if (params.size()>0) params_text=params_text+")";
		
		
		addTestRunStep("SUCCESS", methodName, params_text, "", last_method_duration, null);

		
	}
	
	void makeReportForSqlTable(ArrayList<String[]> tab) {
		if (is_terminated) return;
		
		StringBuilder sb=new StringBuilder();
		
		sb.append("<table class=\"table .table-striped\">");
		for (int i=0;i<tab.size();i++) {
			String[] rec=tab.get(i);
			if (i==0) sb.append("<tr class=warning>");
			else sb.append("<tr class=active>");
			for (int r=0;r<rec.length;r++) 
				sb.append("<td>"+rec[r]+"</td>");
			
			sb.append("</tr>");
		}
		sb.append("</table>");
		
		
		
		//addTestRunStep("SUCCESS", "sqlLoadTable result", "", "", last_method_duration, d.compress(sb.toString())  );
		addTestRunStep("SUCCESS", "sqlLoadTable result", "", "", last_method_duration,sb.toString().getBytes()  );
	
		
	}
	
	long next_check_cancellation_ts=0;
	static final int CHECK_CANCEL_INTERVAL=5000;
	
	//************************************************
	void checkCancellation() {
		
		if (!is_initiated) return;
		if (is_terminated) return;
		if (RUNNING_work_plan_id==0) return;
		if (d.worker_id==0) return;

		if (System.currentTimeMillis()<next_check_cancellation_ts) return;
				
		boolean is_worker_cancelled=d.getCancelFlag("tdm_worker");
		if (is_worker_cancelled) {
			terminateTest(true, true, "Test is terminated by  user");
			d.resumeTasksByWorkerId(d.worker_id);
			d.setWorkerStatus("FREE");
			
		}
		else
		{
			boolean is_wp_cancelled=d.isWorkPlanCancelled(RUNNING_work_plan_id);
			if (is_wp_cancelled) {
				terminateTest(false, true, "Test is terminated by  user");
				d.resumeTasksByWorkerId(d.worker_id);
				d.setWorkerStatus("FREE");
				
			}
			
		}
		
		next_check_cancellation_ts=System.currentTimeMillis();
		
	}
	
	//************************************************
	void methodRun(String methodName, ArrayList<String> params) {
		long start_ts=System.currentTimeMillis();
		last_method_duration=0;
		


		for (int i=0;i<params.size();i++)
			params.set(i, P(params.get(i)));
		

		
		if (!methodName.equals("resetException") && !methodName.equals("screenShot")  && !is_terminated) {
			System.out.print(methodName);
			System.out.print("(");
			
			
			for (int i=0;i<params.size();i++) {
				if (i>0)  System.out.print(",");
				System.out.print("'"+params.get(i)+"'");
			}
			System.out.print(")");
			System.out.println("");
			
			}
		
		checkCancellation();
		
		Method method =  getMethodByName(methodName);
				
		if (is_terminated) return;
		
		
		if (method==null) {
			System.out.println("No such method found :  "+ methodName);
			terminateTest();
		}
		
		command_order++;
		
		try {
			switch(params.size()) {
			case 0: {
				method.invoke(autoDriver); 
				break;
			}
			case 1: {
				method.invoke(autoDriver, params.get(0)); 
				break;
			}
			case 2: {
				method.invoke(autoDriver, params.get(0), params.get(1)); 
				break;
			}
			case 3: {
				method.invoke(autoDriver, params.get(0), params.get(1), params.get(2)); 
				break;
			}
			case 4: {
				method.invoke(autoDriver, params.get(0), params.get(1), params.get(2), params.get(3)); 
				break;
			}
			case 5: {
				method.invoke(autoDriver, params.get(0), params.get(1), params.get(2),params.get(3), params.get(4)); 
				break;
			}
			case 6: {
				method.invoke(autoDriver, params.get(0), params.get(1), params.get(2), params.get(3), params.get(4), params.get(5)); 
				break;
			}
			
			}
			
			
		} catch (Exception e) {
			System.out.println("Exception@methodRun("+methodName+") : " + e.getMessage());
			if (params.size()>0)
				System.out.println("with parameters : " );
			for (int i=0;i<params.size();i++)
				System.out.println("Parameter 1 " + params.get(i));
			e.printStackTrace();
		} finally {
			if (!methodName.equals("resetException") && !methodName.equals("screenShot")  && !is_terminated)
				{
				last_method_duration=System.currentTimeMillis()-start_ts;
				makeReportForCommand(methodName,params);
				}
			
		}
	}
	
	int randomRange(int start, int end) {
		int diff=end-start;
		if (diff==0) return end;
		
	return  ((int) Math.round(Math.random()*diff))+start;	
	}
	
	//********************************************************
	String P(String pin) {
		StringBuilder val=new StringBuilder(pin);	
		final String par_begins="${";
		final String par_ends="}";
			
			while(true) {
				boolean is_replaced_any=false;
				//find out ${xxx} pattern
				int fromIndex=0;
				while(true) {
					int p_start=val.indexOf(par_begins, fromIndex);
					if (p_start==-1) break;
					int p_end=val.indexOf(par_ends, p_start);
					if (p_end==-1) break;
					fromIndex=p_end;
					
					String param_detail=val.substring(p_start+2,p_end);
					
					if (param_detail.toUpperCase().contains("RANDOM") && param_detail.indexOf("(")>-1 && param_detail.indexOf("(")<param_detail.indexOf(")")) {
						String range_str="";
						
						try{range_str=param_detail.toUpperCase().split("RANDOM")[1].split("\\(")[1].split("\\)")[0];} catch(Exception e) {}
						
						
						if (range_str.contains(",")) {
							boolean is_parsed=true;
							int range_start=0;
							int range_end=1000;
							try {
								range_start=Integer.parseInt(range_str.split(",")[0].trim());
								range_end=Integer.parseInt(range_str.split(",")[1].trim());
								} 
							catch(Exception e) {
								System.out.println("Unrecognized random range : " +param_detail);
								is_parsed=false;
								}
							
							if (is_parsed && range_start<=range_end) {
								is_replaced_any=true;
								int  random_value=randomRange(range_start,range_end);
								val.delete(p_start, p_end+par_ends.length());
								val.insert(p_start, random_value);
							}
						}
					}
					
					
					if (param_detail.toUpperCase().contains("DATETIME") && param_detail.indexOf("(")>-1 && param_detail.indexOf("(")<param_detail.indexOf(")")) {
						String date_format_str="";
						
						try{date_format_str=param_detail.split("\\(")[1].split("\\)")[0].trim();} catch(Exception e) {}
						String datetime_format=genLib.DEFAULT_DATE_FORMAT;
						if (date_format_str.length()>0)  datetime_format=date_format_str;
						boolean is_parsed=true;
						String parsed_datetime="";
						
						
						try {							
							parsed_datetime=new SimpleDateFormat(datetime_format).format(new Date());
						} catch(Exception e) {
							System.out.println("Unrecognized date-time format : " +datetime_format);
							e.printStackTrace();
							is_parsed=false;
							};
						
						if (is_parsed) {
							is_replaced_any=true;
							val.delete(p_start, p_end+par_ends.length());
							val.insert(p_start, parsed_datetime);
						}
					}
					
					
					
					if (hm.containsKey("PARAM_"+param_detail.toUpperCase())) {
						is_replaced_any=true;
						val.delete(p_start, p_end+par_ends.length());
						val.insert(p_start, (String) hm.get("PARAM_"+param_detail.toUpperCase()));
					}
					
					
				}
				
				if (!is_replaced_any) break;
			}
			
			
		return val.toString();
	}
	
	
	
	
	
	//*********************************************************
	void setTestStep(String new_step_name) {
		if (is_terminated) return;
		if (new_step_name.equals(current_reported_step)) return;
		screenShot();
		current_reported_step=P(new_step_name);
		last_reported_step="";
		script_run_step++;
		
		System.out.println("setTestStep('"+P(new_step_name)+"')");
		
		addTestRunStep("SUCCESS", "setTestStep", P(new_step_name), "", 0, null);
	}

	
	//*********************************************************
		void makeReportForException(String exception) {
			if (is_terminated) return;
			addTestRunStep("FAIL", "Exception", "()", exception, 0, null);
			
			
		}
	
		
	//*********************************************************
	void  makeReportForScreenShot(String screenshotfilepath) {
		if (is_terminated) return;
		File file =null;
		DataInputStream dis = null;
		try {
			file = new File(screenshotfilepath);
			byte[] fileData = new byte[(int) file.length()];
			dis = new DataInputStream(new FileInputStream(file));
			dis.readFully(fileData);
			dis.close();
			
			
			addTestRunStep("SUCCESS", "screenShot", "()", "", last_method_duration, fileData);
			
		} catch(Exception e) {
			System.out.println("Exception@makeReportForScreenShot : " + e.getMessage());
			e.printStackTrace();
		} finally {
			try {dis.close();} catch(Exception e) {}
			try {if (file.exists()) file.delete();} catch(Exception e) {}
			
 		}
		
	}


	
	int script_id=1;
	int script_run_id=1;
	int script_run_step=0;
	int domain_instance_id=0;
	
	//********************************************************
	void addTestRunStep(
			String step_status,
			String command,
			String command_parameters,
			String command_err,
			long duration,
			byte[] attachment
			) {
		
		script_run_step++;
		

		
		String sql="insert into tdm_test_run_step ( "+
				" id, script_id, test_run_id, test_run_step, step_status, "+
				" command, command_parameters, command_err, duration) "+
				" values " + 
				"(?, ?, ?, ?, ?, ?, ?, ?, ?)";
		
		boolean success=false;
		int retry_count=0;
		long last_id=0;
		
		while (!success) {
			
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			
			last_id=(System.currentTimeMillis() % Integer.MAX_VALUE)+1;
			
			bindlist.add(new String[]{"LONG",""+last_id});
			bindlist.add(new String[]{"INTEGER",""+script_id});
			bindlist.add(new String[]{"INTEGER",""+script_run_id});
			bindlist.add(new String[]{"INTEGER",""+script_run_step});
			bindlist.add(new String[]{"STRING",step_status});
			bindlist.add(new String[]{"STRING",command});
			bindlist.add(new String[]{"STRING",command_parameters});
			bindlist.add(new String[]{"STRING",command_err});
			long v_step_duration=duration;
			if (v_step_duration>Integer.MAX_VALUE)  v_step_duration=0;
			bindlist.add(new String[]{"INTEGER",""+v_step_duration});

			
			success=d.execDBBindingConf(sql, bindlist);
			
			retry_count++;
			d.sleep(100);
			if (retry_count>10) break;
		}
		
		if (success && attachment!=null) 
			d.setBinInfo("tdm_test_run_step", (int) last_id, "attachment", attachment);
		
		
		
	}
	
	//********************************************************
	void failTestIf(String locator, String attr, String oper, String checkval) {
		String v_locator=P(locator);
		String v_attr=P(attr);
		String v_checkval=P(checkval);
		
		System.out.println("failTestIf('"+v_locator+"','"+v_attr+"','"+oper+"','"+v_checkval+"')");
		
		ArrayList<String> params=new ArrayList<String>();
		params.add(v_locator);
		params.add(v_attr);
		params.add(oper);
		params.add(v_checkval);

		makeReportForCommand("failTestIf", params);
		
		
		
		String attr_val=getAttr(v_locator, v_attr);
		if (attr_val==null) {
			terminateTestFail("Element or it's attribute not found.");
			return;
		}
		
		System.out.println("getAttr returns : " + attr_val);

		
		boolean to_fail=false;
		
		if (oper.equals("CONTAINS") && attr_val.contains(v_checkval)) 
			to_fail=true;
		else if (oper.equals("NOT CONTAINS") && !attr_val.contains(v_checkval)) 
			to_fail=true;
		else if (oper.equals("EQUALS") && attr_val.equals(v_checkval)) 
			to_fail=true;
		else if (oper.equals("NOT EQUALS") && !attr_val.equals(v_checkval)) 
			to_fail=true;	
		else if (oper.equals("STARTS") && attr_val.indexOf(v_checkval)==0) 
			to_fail=true;
		else if (oper.equals("NOT STARTS") && attr_val.indexOf(v_checkval)!=0) 
			to_fail=true;
		else if (oper.equals("ENDS") && attr_val.indexOf(v_checkval)==(attr_val.length()-v_checkval.length())) 
			to_fail=true;
		else if (oper.equals("NOT ENDS") && attr_val.indexOf(v_checkval)!=(attr_val.length()-v_checkval.length())) 
			to_fail=true;
		else if (oper.equals("EMPTY") && attr_val.length()==0)
			to_fail=true;
		else if (oper.equals("NOT EMPTY") && attr_val.length()>0)
			to_fail=true;
		
		if (to_fail) 
			terminateTestFail(v_attr+ " of Element "+ oper + " {"+v_checkval+"} : "  + attr_val);
		
	}


	//*********************************************************
	void terminateTest() {
	//*********************************************************
		terminateTest(false,false, "");
	}
	//*********************************************************
	void terminateTestFail(String termination_msg) {
	//*********************************************************
		terminateTest(false,true,termination_msg);
	}
	
	
	
	//*********************************************************
		void terminateTest(boolean retry, boolean forcefail, String termination_msg) {
	//*********************************************************
			
			//if (is_terminated) return;
			
			System.out.println("");
			String exception="";
			
			if (forcefail) exception=termination_msg;
			else exception=getLastException();
				
			if (retry) {
				makeReportForException(exception);
				methodRun("terminateTest");
				is_terminated=true;
				System.out.println(TEST_TERMINATION_RETRY);
			} 
			else {
				if (exception.length()>0) {
					makeReportForException(exception);
					screenShot();
					methodRun("terminateTest");
					is_terminated=true;
					System.out.println(TEST_TERMINATION_FAIL);
				}
				else {
					screenShot();
					methodRun("terminateTest");
					is_terminated=true;
					System.out.println(TEST_TERMINATION_SUCCESS);
				}	
			} //if (retry)
			
						
			if (d!=null) d.closeAll();
			
			
			
			
			
		}
		
	//**********************************************
	void createDir(String dir) {
		File theDir = new File(dir);
		if (!theDir.exists()) {
		    System.out.println("creating directory: " + dir);
		    boolean result = false;

		    try{
		        theDir.mkdir();
		        result = true;
		     } catch(SecurityException se){
		        //handle it
		     }        
		}
	}
	

		
	//*********************************************************
	void click() {
	//*********************************************************
			click(LAST_ELEMENT_LOCATED);
	}
	
	//*********************************************************
	void click(String locator) {
	//*********************************************************
		
			methodRun("click",locator);
	}
	//*********************************************************
	void hover() {
	//*********************************************************
			hover(LAST_ELEMENT_LOCATED);
	}
	
	//*********************************************************
	void hover(String locator) {
	//*********************************************************
		
			methodRun("hover",locator);
	}
	//*********************************************************
	void check() {
	//*********************************************************
		check(LAST_ELEMENT_LOCATED);
	}
	
	//*********************************************************
	void keyEnter() {
	//*********************************************************
		methodRun("keyEnter");
	}
	
	//*********************************************************
	void clearCookies() {
	//*********************************************************
		methodRun("clearCookies");
	}
	

	//*********************************************************
	void keyTab() {
	//*********************************************************
		methodRun("keyTab");
	}
	
	//*********************************************************
	void check(String locator) {
	//*********************************************************
		methodRun("check",locator);
	}
	
	//*********************************************************
	void uncheck() {
	//*********************************************************
		uncheck(LAST_ELEMENT_LOCATED);
	}
	//*********************************************************
	void uncheck(String locator) {
	//*********************************************************
		methodRun("uncheck",locator);
	}
	
	//*********************************************************
	void setText(String text) {
	//*********************************************************
		setText(LAST_ELEMENT_LOCATED, text);
	}
	
	//*********************************************************
	void setText(String locator, String text) {
	//*********************************************************
		methodRun("setText",locator,text);
	}
	
	//*********************************************************
	void setSelectOption(String text, String val) {
	//*********************************************************
		setSelectOption(LAST_ELEMENT_LOCATED, text, val);
	}
	
	//*********************************************************
	void setSelectOption(String locator, String text, String val) {
	//*********************************************************
		methodRun("setSelectOption",locator, text, val);
	}
	//*********************************************************
	void go(String url) {
	//*********************************************************
		methodRun("go",url);
		
	}
	
	//*********************************************************
	void runJS(String script) {
	//*********************************************************
		
			methodRun("runJS",script);
	}
	
	//*********************************************************
	void sleep(String dur) {
	//*********************************************************
		int durint=0;
		try {durint=Integer.parseInt(P(dur));} catch(Exception e) {}
		sleep(durint);
	}
	
	
	//*********************************************************
	void sleep(int dur) {
	//*********************************************************
		System.out.println("sleep("+dur+")");
		try {Thread.sleep(dur);} catch(Exception e){};
	}
	//*********************************************************
	String nvl(String in, String out) {
	//*********************************************************
		return d.nvl(in, out);
	}
	long last_method_duration=0;	

	//*********************************************************
	WebElement findElementEx(String ref_locator, int order, String tagtofind) {
	//*********************************************************
		return findElementEx(ref_locator, DIRECTION_NEAR, order, tagtofind, "");
	}
	
	//*********************************************************
	WebElement findElementEx(String ref_locator, String direction, int order) {
	//*********************************************************
		return findElementEx(ref_locator, direction, order, "", "");
	}
	
	//*********************************************************
	WebElement findElementEx(String ref_locator, String direction, int order, String tagtofind) {
	//*********************************************************
		return findElementEx(ref_locator, direction, order, tagtofind, "");
	}
	
	//*********************************************************
	WebElement findElementEx(String ref_locator, String direction, int order, String tagtofind, String typetofind) {
	//*********************************************************
			long start_ts=System.currentTimeMillis();
			last_method_duration=0;	

			
			
			Method method =  getMethodByName("findElementEx");
			if (is_terminated) return null;
			
			ArrayList<String> params=new ArrayList<String>();
			
			params.add(P(ref_locator));
			params.add(P(direction));
			params.add(""+order);
			params.add(P(tagtofind));		
			params.add(P(typetofind));
			
			
			
			WebElement ret1=null;
			try {
				ret1= (WebElement) method.invoke(autoDriver, P(ref_locator),P(direction),order, P(tagtofind),P(typetofind));
				System.out.println("findElementEx("+
						"'"+P(ref_locator)+"',"+
						"'"+P(direction)+"',"+
						""+order+"',"+
						"'"+P(tagtofind)+"',"+
						"'"+P(typetofind)+"'"+
						")"
						);
			} catch (Exception e) {
				System.out.println("Exception@findElementEx : " + e.getMessage());
				e.printStackTrace();
				ret1=null;
			} 

			last_method_duration=System.currentTimeMillis()-start_ts;	
			makeReportForCommand("findElementEx",params);
			
			
			return ret1;
			
	}
	
	
	//*********************************************************
	String getAttr(String locator, String attr) {
	//*********************************************************
			long start_ts=System.currentTimeMillis();
			last_method_duration=0;	

			
			
			Method method =  getMethodByName("getAttr");
			if (is_terminated) return null;
			
			ArrayList<String> params=new ArrayList<String>();
			
			params.add(P(locator));
			params.add(P(attr));		
			
			
			String ret1="";
			try {
				ret1= (String) method.invoke(autoDriver, P(locator),P(attr));
				System.out.println("getAttr("+
						"'"+P(locator)+"',"+
						"'"+P(attr)+"'"+
						")"
						);
			} catch (Exception e) {
				System.out.println("Exception@getAttr : " + e.getMessage());
				e.printStackTrace();
				ret1=null;
			} 

			last_method_duration=System.currentTimeMillis()-start_ts;	
			makeReportForCommand("getAttr",params);
			
			
			return ret1;
			
	}
	
	//****************************************
	void screenShot() {
		
		screenshot_no++;
		
		try {Thread.sleep(1000);} catch(Exception e){};

		String screenshotfilepath=report_img_path+File.separator+"SCREEN_"+screenshot_no+".PNG";
		
		methodRun("screenShot",screenshotfilepath);
		
		makeReportForScreenShot(screenshotfilepath);
	}
	
	//*****************************************
	void loadDomainScriptParams(int domain_instance_id, int p_script_id, String params_in) {
		
		String sql="select domain_element_type, e.domain_element_name, var_value " + 
					"	from tdm_domain_instance_prop_val v, tdm_domain_element e " +  
					"	where v.domain_instance_id=" + domain_instance_id + 
					"	and v.domain_element_id=e.id " + 
					"	and e.domain_element_type in ('VARIABLE','PASSWORD') ";
		
		ArrayList<String[]> arr=d.getDbArrayConf(sql, Integer.MAX_VALUE);
		
		if (arr!=null)
			for (int i=0;i<arr.size();i++) {
				String prop_type=arr.get(i)[0];
				String prop_name=arr.get(i)[1];
				String prop_val=arr.get(i)[2];
				if (prop_type.equals("PASSWORD") && prop_val.length()>0) 
					prop_val=d.decode(prop_val);
				
				if (prop_type.equals("PASSWORD")) 
					setParam(prop_name, prop_val, true, false);
				else 
					setParam(prop_name, prop_val, false, false);
			}
		
		
		sql="select param_name, default_value from tdm_auto_scripts_par  where script_id =? order by param_order";
		arr=d.getDbArrayConfInt(sql, Integer.MAX_VALUE,p_script_id);

		if (arr!=null)
			for (int i=0;i<arr.size();i++) {
				String param_name=arr.get(i)[0];
				String param_val=arr.get(i)[1];
				setParam(param_name, P(param_val));
			}
		
		if (params_in.length()>0) {
			String[] parsin=params_in.split("\n|\r");
			for (int i=0;i<parsin.length;i++) {
				String a_par=parsin[i];
				if (!a_par.contains("=")) continue;
				String param_name=a_par.split("=")[0];
				String param_val=a_par.substring(a_par.indexOf("=")+1);
				setParam(param_name, P(param_val));
			}
		}
	}
	
	
	
	//*****************************************
	void setParam(String param_name, String param_val) {
		setParam(param_name, param_val, false, true);
	}

	
	
	//*****************************************
	void setParam(String param_name, String param_val, boolean is_secure, boolean is_visible) {
		if (is_terminated) return;
		hm.put("PARAM_"+P(param_name), P(param_val));
		
		//$1 $2 $3 ....
		if (param_name.indexOf("$")!=0)
			if (is_visible) {
				if (is_secure) 
					System.out.println("setParam('"+param_name+"','*****************')");
				else 
					System.out.println("setParam('"+P(param_name)+"','"+P(param_val)+"')");
			}
			
		
		ArrayList<String> params=new ArrayList<String>();
		params.add(P(param_name));
		params.add(P(param_val));
		
		if (param_name.indexOf("$")!=0 || param_name.length()>2)
			makeReportForCommand("setParam", params);
		
		checkCancellation();
	}
	
	//*****************************************
	
	String getParam(String param_name) {
		if (is_terminated) return "";
		String p_param_name=P(param_name);
		//$1 $2 $3 ....
		if (p_param_name.indexOf("$")!=0 || p_param_name.length()>2) {
			System.out.println("getParam('"+p_param_name+"')");
			ArrayList<String> params=new ArrayList<String>();
			params.add(p_param_name);		
		}
	
		
		if (p_param_name.contains(".")) {
			String tab_param_name=p_param_name.split("\\.")[0];
			if (hm.containsKey("PARAM_"+tab_param_name)) {
				String tab_field_name=p_param_name.substring(p_param_name.indexOf(".")+1);
				return getParamFromTable(tab_param_name,tab_field_name);
			}
		}
		
		
		if (!hm.containsKey("PARAM_"+p_param_name)) {
			terminateTestFail("parameter not found : " + p_param_name);
			return null;
		}
		
		Object obj=hm.get("PARAM_"+p_param_name);
		if (obj instanceof String)
			return (String) hm.get("PARAM_"+p_param_name);
		else  
			return getParamFromTable(p_param_name,"*");
	
	}
	
	//******************************************
	String getParamFromTable(String tab_name, String field_name) {
		StringBuilder sb=new StringBuilder();
		ArrayList<String[]> tab=(ArrayList<String[]>) hm.get("PARAM_"+tab_name);
		String[] fields=tab.get(0);
		for (int i=1;i<tab.size();i++) {
			String[] arr=tab.get(i);
			for (int c=0;c<arr.length;c++) {
				if (field_name.equals("*") || field_name.equals(fields[c])) {
					sb.append(arr[c]+"\t");
				}
			}
		}
		return sb.toString();
	}
	//******************************************
	void runScript(String scriptname, String... params ) {
		if (is_terminated) return;
		
		for (int i=1;i<=100;i++)
			hm.put("PARAM_$"+i, "");
		
		for (int i=0;i<params.length;i++) 
			if (params[i]!=null) 
				setParam("$"+(i+1), P(params[i]));
		
		String sql="select param_name, default_value from tdm_auto_scripts_par " + 
					" where script_id in (select id from tdm_auto_scripts where script_name=? and app_id=(select app_id from tdm_auto_scripts where id=?)) "  + 
					"  " +
					" order by param_order";
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"STRING",scriptname});
		bindlist.add(new String[]{"INTEGER",""+script_id});
		
		ArrayList<String[]> pars=d.getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);
		
		for (int i=0;i<pars.size();i++) {
			try {
				hm.put("PARAM_"+pars.get(i)[0],nvl(P(params[i]),pars.get(i)[1]));
			} catch(Exception e) {e.printStackTrace();}
		}
			
		
		checkCancellation();
		
	}
	
	
	//**********************************************************
	void sqlLoadTable(String param_for_table, String db_id, String sql_to_execute, String in_limit) {
		if (is_terminated) return;
		long start_ts=0;
		last_method_duration=0;
		int limit=1;
		try {limit=Integer.parseInt(in_limit);} catch(Exception e) {}
		if (limit==0) limit=Integer.MAX_VALUE;
		
		String final_sql=P(sql_to_execute);
		
		ArrayList<String> params=new ArrayList<String>();
		params.add(param_for_table);
		params.add(db_id);
		params.add(final_sql);
		params.add(in_limit);
		
		makeReportForCommand("sqlLoadTable", params);
		
		String  sql="select db_driver, db_connstr, db_username, db_password "+
					" from tdm_domain_instance_prop_val "+
					" where domain_element_id=? and domain_instance_id=?";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",db_id});
		bindlist.add(new String[]{"INTEGER",""+domain_instance_id});
		
		ArrayList<String[]> dbconf=d.getDbArrayConf(sql, 1, bindlist);
		
		if (dbconf==null || dbconf.size()==0) {
			last_method_duration=System.currentTimeMillis()-start_ts;
			String termination_msg="Db configuration for db " + db_id + " can't be loaded.";
			System.out.println(termination_msg);
			terminateTestFail(termination_msg);
			return;
		}
		
		String Driver=dbconf.get(0)[0];
		String ConnStr=dbconf.get(0)[1];
		String User=dbconf.get(0)[2];
		String Pass=dbconf.get(0)[3];
		
		
		Connection conn=d.getconn(ConnStr, Driver, User, Pass,0);
		
		if (conn==null) {
			last_method_duration=System.currentTimeMillis()-start_ts;
			String termination_msg="Db connection can't be established.";
			System.out.println(termination_msg);
			terminateTestFail(termination_msg);
			return;
		}
		
		PreparedStatement pstmtApp = null;
		ResultSet rsetApp = null;
		ResultSetMetaData rsmdApp = null;
		
		try {
			pstmtApp = conn.prepareStatement(final_sql);
			rsetApp = pstmtApp.executeQuery();
			rsmdApp = rsetApp.getMetaData();
			int colcount = rsmdApp.getColumnCount();
			int reccnt=0;
			
			ArrayList<String[]> resArr=new ArrayList<String[]>();
			
			// add column names as first row
			String[] row = new String[colcount];
			for (int i=1;i<=colcount;i++) 
				row[i-1]=rsmdApp.getColumnName(i);
			resArr.add(row);
			
			String a_field = "";
			
			while (rsetApp.next()) {
				reccnt++;
				row = new String[colcount];
				for (int i = 1; i <= colcount; i++) {

					int colType=rsmdApp.getColumnType(i);
					try {
						//if ("DATE,TIMESTAMP".indexOf(rsmdApp.getColumnTypeName(i)) > -1) {
						if (colType==91 || colType==92 || colType==93) {
							Date dt = rsetApp.getDate(i);
							if (dt == null)	a_field = "";
							else
								a_field = new SimpleDateFormat(genLib.DEFAULT_DATE_FORMAT).format(dt);
						} 
						
						
						else
							a_field = rsetApp.getString(i);
						if (a_field.equals("null")) {
							if (rsetApp.wasNull()) a_field="";
						}
					} catch (Exception enull) {
						a_field = "";
					}
					row[i - 1] = a_field;
				
				}
				
				resArr.add(row);
				if (reccnt >= limit) break;
			}
			
			hm.put("PARAM_", resArr);
			last_method_duration=System.currentTimeMillis()-start_ts;
			makeReportForSqlTable(resArr);
			
		} catch(Exception e) {
			e.printStackTrace();
			String exception="Exception@sqlLoadTable : "+ e.getMessage();
			last_method_duration=System.currentTimeMillis()-start_ts;
			makeReportForException(exception);
		} finally {
			try {rsetApp.close();} catch (Exception e) {}
			try {pstmtApp.close();} catch (Exception e) {}
			try {conn.close();} catch (Exception e) {}
		}
		
	}
}
