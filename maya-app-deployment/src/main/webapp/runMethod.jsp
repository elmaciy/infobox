<%@include file="header2.jsp" %>

<%
	String id=nvl(request.getParameter("id"),"0");
	String token=nvl(request.getParameter("token"),"-");
	
	
	
	StringBuilder sb=new StringBuilder();
	
	String sql="select "+
				" request_id, method_id, action_method_id, flow_state_action_id, parameters  "+
				" from mad_method_call_logs "+
				" where id=? and token=? and status in ('NEW','FAILED') ";
			
	ArrayList<String[]> bindlist=new ArrayList<String[]>();
	bindlist.clear();
	bindlist.add(new String[]{"INTEGER",id});
	bindlist.add(new String[]{"STRING",token});
	
	Connection conn=getconn();
	
	if (conn==null) {
		sb.append("CONNERR:"+last_connection_error);
		closeconn(conn);
	} else {
		ArrayList<String[]> arr=getDbArrayConf(conn, sql, 1, bindlist);


		if (arr==null || arr.size()==0) {
			sb.append("NOTFOUND:"+id);
			closeconn(conn);
		} else {
			String request_id=arr.get(0)[0];
			String method_id=arr.get(0)[1];
			String action_method_id=arr.get(0)[2];
			String flow_state_action_id=arr.get(0)[3];
			String parameters=arr.get(0)[4];
			
			StringBuilder executable=new StringBuilder();
			StringBuilder result=new StringBuilder();
			StringBuilder logs=new StringBuilder();
			
			
			long start_ts=System.currentTimeMillis();
			
			executeMadMethod(
					conn, 
					session, 
					method_id,
					action_method_id,
					request_id,
					parameters,
					executable,
					result,
					logs
				);
			
			long duration=System.currentTimeMillis()-start_ts;
			
			boolean is_success=false;
			if (result.toString().indexOf("true")==0) is_success=true;
			
			System.out.println("runMethod.executable:"+executable.toString());
			System.out.println("runMethod.result:"+result.toString());
			System.out.println("runMethod.logs:"+logs.toString());
			
			if (is_success) {
				
				
				sql="update mad_method_call_logs "+
					" set "+
					" attempt_no=attempt_no+1, " +
					" status='FINISHED',  "+
					" last_execution_date=now(), "+
					" executable=?, "+
					" duration=?, "+
					" execution_result=?, "+
					" execution_log=? " + 
					" where id=?";
				
				bindlist.clear();
				bindlist.add(new String[]{"STRING",executable.toString()});
				bindlist.add(new String[]{"INTEGER",""+duration});
				bindlist.add(new String[]{"STRING",result.toString()});
				bindlist.add(new String[]{"STRING",logs.toString()});
				bindlist.add(new String[]{"INTEGER",id});
				
				execDBConf(conn, sql, bindlist);
				
				sb.append("SUCCESS:"+id);
				
				
				
				
			} else {
				
				String new_token=""+System.currentTimeMillis()+generateToken();
				
				sql="update mad_method_call_logs "+
						" set   "+
						" attempt_no=attempt_no+1, " +
						" status='FAILED',  "+
						" token=?, "+
						" last_execution_date=now(), "+
						" executable=?, "+
						" duration=?, "+
						" execution_result=?, "+
						" execution_log=? " + 
						" where id=?";
					
					bindlist.clear();
					bindlist.add(new String[]{"STRING",new_token});
					bindlist.add(new String[]{"STRING",executable.toString()});
					bindlist.add(new String[]{"INTEGER",""+duration});
					bindlist.add(new String[]{"STRING",result.toString()});
					bindlist.add(new String[]{"STRING",logs.toString()});
					bindlist.add(new String[]{"INTEGER",id});
					
					execDBConf(conn, sql, bindlist);
				
				sb.append("FAILED:"+id);
			}
			
			closeconn(conn);
		}

	}
	
	
	closeconn(conn);
	
	
	out.print(sb.toString());

%>

