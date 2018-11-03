<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@include file="header.jsp" %> 


<%

String fieldChangeAction="";
String par1="";
String par2="";
String par3="";


String msg="";
String refresh_form="";


try {
	fieldChangeAction=nvl(request.getParameter("action"),"-");
	par1=request.getParameter("par1");
	par2=request.getParameter("par2");
	par3=request.getParameter("par3");

} catch(Exception e) {
	fieldChangeAction="-";
}



	

	if (!fieldChangeAction.equals("-")) {
		
		String update_sql="";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		
		String fieldChangeFieldId=nvl(request.getParameter("par1"),"0");
		String fieldChangeNewValue=nvl(request.getParameter("par2"),"");
		String fieldChangeNewValue2=nvl(request.getParameter("par3"),"");


		if (fieldChangeAction.equals("mask_prof_id")) {
			bindlist.add(new String[]{"INTEGER",nvl(fieldChangeNewValue,"0")});
			bindlist.add(new String[]{"INTEGER",fieldChangeFieldId});

			update_sql="update tdm_fields set  mask_prof_id=?,is_conditional='NO',condition_expr=null  where id=?";
		}
		
		if (fieldChangeAction.equals("is_pk")) {

			refresh_form="refresh_form";

			System.out.println("fieldChangeNewValue="+fieldChangeNewValue);
			bindlist.add(new String[]{"STRING",nvl(fieldChangeNewValue,"NO")});
			bindlist.add(new String[]{"INTEGER",fieldChangeFieldId});

			update_sql="update tdm_fields set  is_pk=? ,mask_prof_id=0,is_conditional='NO',condition_expr=null  where id=?";
		}
		
		
		if (fieldChangeAction.equals("is_conditional")) {
			
			refresh_form="refresh_form";
			
			fieldChangeNewValue=nvl(fieldChangeNewValue,"NO");
			if (fieldChangeNewValue.equals("NO")) {
				fieldChangeNewValue2="";
			} 
			
			bindlist.add(new String[]{"STRING",fieldChangeNewValue});
			bindlist.add(new String[]{"INTEGER",fieldChangeFieldId});

			update_sql="update tdm_fields set  mask_prof_id=0, is_conditional=?,condition_expr=null  where id=?";
		}
		
		
		if (fieldChangeAction.equals("condition_expr")) {
			
			bindlist.add(new String[]{"STRING",fieldChangeNewValue2});
			bindlist.add(new String[]{"INTEGER",fieldChangeFieldId});

			update_sql="update tdm_fields set  condition_expr=? where id=?";
		}
		
		System.out.println(update_sql);
		
		if (!update_sql.isEmpty()) {
			boolean db_update=false;
			
			Connection conn=null;
			try {
				conn=getconn();

				db_update=execDBConf(conn, update_sql,bindlist);
				
				conn.close();
				conn=null;
				} 
				catch(Exception e) 
					{e.printStackTrace();}
				finally {
					try {conn.close();conn=null;} catch(Exception e) {}			}
			
			if (db_update)
				msg=fieldChangeAction + " UPDATE is OK with "+ par1 + ", " +par2 + "," + par3 + " ["+refresh_form+"]";
			}

	}
	
	
	








JSONObject obj=new JSONObject();
obj.put("msg", msg);

try{ out.print(obj);    out.flush();} catch(IOException e) {	e.printStackTrace();  }

%>