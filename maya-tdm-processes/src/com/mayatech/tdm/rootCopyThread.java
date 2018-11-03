package com.mayatech.tdm;

import java.sql.Connection;
import java.util.ArrayList;

class rootCopyThread implements Runnable  {

	copyLib cpLib=null;
	Connection connSource=null;
	Connection connTarget=null;
	ConfDBOper db=null;
	ArrayList<copyTableObj> tableArr=null;
	ArrayList<String> copyRefFieldsArr=null;
	copyTableObj ct=null;
	ArrayList<String> parentRecord=null;
	boolean is_parent_changed=false;
	ArrayList<String> parentChangedRecord=null;
	ArrayList<Boolean> parentChangeStatus=null;
	boolean RecursiveMode=false;
	int parallel_no=0;
	String filter_value="";
	
	
	
	rootCopyThread(
			copyLib cpLib,
			Connection connSource,
			Connection connTarget,
			ConfDBOper db,
			ArrayList<copyTableObj> tableArr,
			ArrayList<String> copyRefFieldsArr,
			copyTableObj ct,
			ArrayList<String> parentRecord,
			boolean is_parent_changed,
			ArrayList<String> parentChangedRecord,
			ArrayList<Boolean> parentChangeStatus,
			boolean RecursiveMode,
			int parallel_no,
			String filter_value
			) {
		
		this.cpLib=cpLib;
		this.connSource=connSource;
		this.connTarget=connTarget;
		this.db=db;
		this.tableArr=new ArrayList<copyTableObj>();
		this.tableArr.addAll(tableArr);
		
		this.copyRefFieldsArr=new ArrayList<String>();
		this.copyRefFieldsArr.addAll(copyRefFieldsArr);
		
		this.ct=ct;
		
		
		this.parentRecord=parentRecord;
		this.is_parent_changed=is_parent_changed;
		this.parentChangedRecord=parentChangedRecord;
		this.parentChangeStatus=parentChangeStatus;
		this.RecursiveMode=RecursiveMode;
		this.parallel_no=parallel_no;
		
		this.filter_value=filter_value;
		
		
	}

	//-------------------------------------------------------------------
	@Override
    public void run() {
		
		
		cpLib.copyTableDo(
				connSource,
				connTarget,
				db, 
				tableArr,
				copyRefFieldsArr,
				ct, 
				parentRecord, //parentRecord, 
				is_parent_changed, 
				parentChangedRecord, 
				parentChangeStatus, 
				RecursiveMode,
				false, //isOriginatedFromNeed
				parallel_no,
				filter_value
				);
		
		
	}
	
	
	
	
	
}
