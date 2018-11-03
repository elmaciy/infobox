package com.mayatech.Test;

import java.util.ArrayList;

import com.mayatech.tdm.ConfDBOper;

public class indexAll {

	//***********************************************************
	void indexRequestSearchText(ConfDBOper d, String request_id) {
		
		
		String sql="";
		
		ArrayList<String[]> arr=new ArrayList<String[]>();
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		bindlist.add(new String[]{"INTEGER",request_id});
		sql="select description from mad_request where id=?";
		
		arr=d.getDbArrayConf(sql, 1, bindlist);
		if (arr==null ||  arr.size()==0) return;
		
		String request_description=arr.get(0)[0];
		
		sql="select id from mad_keywords where object_type='mad_request' and object_id=?";
		
		arr=d.getDbArrayConf(sql, 1, bindlist);
		int keyword_id=0;
		try {keyword_id=Integer.parseInt(arr.get(0)[0]);} catch(Exception e) {}
		
		
		String keyword_text=""+ request_id+" "+ request_description;
		
		sql="select field_value  from mad_request_fields rf, mad_flex_field f " +
			"	where request_id=? " +
			"	and rf.flex_field_id=f.id and f.entry_type not in ('DATE','DATETIME')";
		
		arr=d.getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);
		for (int i=0;i<arr.size();i++) {
			String aline=arr.get(i)[0];
			if (aline.trim().length()<3) continue;
			if (keyword_text.length()>0)  keyword_text=keyword_text+" ";
			keyword_text=keyword_text+aline;
		}
		
		
		sql="select action_note  from mad_request_flow_logs  where request_id=? ";
		
		arr=d.getDbArrayConf(sql, Integer.MAX_VALUE, bindlist);
		for (int i=0;i<arr.size();i++) {
			String aline=arr.get(i)[0];
			if (aline.trim().length()<3) continue;
			if (keyword_text.length()>0)  keyword_text=keyword_text+" ";
			keyword_text=keyword_text+aline;
		}

		
		
		
		sql="insert into mad_keywords (object_type, object_id, keywords) values ('mad_request',?,?)";
		bindlist.clear();
		bindlist.add(new String[]{"INTEGER",request_id});
		bindlist.add(new String[]{"STRING",keyword_text});
		
		if (keyword_id>0) {
			bindlist.clear();
			bindlist.add(new String[]{"STRING",keyword_text});
			bindlist.add(new String[]{"INTEGER",""+keyword_id});
			sql="update mad_keywords set keywords=? where id=?";
		}
		
		d.execDBBindingConf(sql, bindlist);
		
	}
	
	
	public static void main(String[] args) {

		ConfDBOper d=new ConfDBOper(false);
		indexAll index=new indexAll();
		
		String sql="select id from mad_request";
		
		ArrayList<String[]> arr=d.getDbArrayConf(sql, Integer.MAX_VALUE);
		
		for (int i=0;i<arr.size();i++) {
			String request_id=arr.get(i)[0];
			System.out.println("indexing " + (i+1) + " of " + arr.size() + " id = " + request_id);
			index.indexRequestSearchText(d, request_id);
			
		}

		d.closeAll();
	}

}
