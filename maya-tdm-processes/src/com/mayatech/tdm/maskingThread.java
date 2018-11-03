package com.mayatech.tdm;

import java.util.ArrayList;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

import org.bson.Document;
import org.bson.types.ObjectId;

import com.mayatech.baseLibs.genLib;
import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;
import com.mongodb.util.JSON;

class maskingThread implements Runnable  {
	
	
	
	int targetDBId=-1;
	int work_plan_id=0;
	int work_package_id=0;
	maskLib mLib=null;
	String task_table_name="";
	String p_id=""; 
	int worker_id=0;
	int all_count=0;
	ArrayList<Integer> globalTaskIdArr=new ArrayList<Integer>();
	
	
	String built_update_statement=null;
	

	ScriptEngineManager factory=null;
	ScriptEngine engine=null;
	
	StringBuilder logForThread=new StringBuilder();
	StringBuilder errForThread=new StringBuilder();
	
	
	
	maskingThread(
			maskLib mLib, 
			int targetDBId,
			int work_plan_id, 
			int work_package_id, 
			ArrayList<Integer> globalTaskIdArr
			
			) {
		
		this.mLib=mLib;
		this.targetDBId=targetDBId;
		this.p_id=""+ (System.currentTimeMillis() % Integer.MAX_VALUE);
		this.work_plan_id=work_plan_id;
		this.work_package_id=work_package_id;
		task_table_name="tdm_task_"+this.work_plan_id+"_"+this.work_package_id;
		//this.globalTaskIdArr=globalTaskIdArr;
		this.globalTaskIdArr.addAll(globalTaskIdArr);
	
		
		//if (this.mLib==null) this.mLib=new maskLib(false); 
		
		
		if (factory==null) 	{
			factory = new ScriptEngineManager();
			engine = factory.getEngineByName("JavaScript");
		}
		
		
			
		
	}

	
	
	//-------------------------------------------------------------------
	@Override
    public void run() {

		mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_INFO, "changeActiveMaskingThreadCount +1");
		mLib.changeActiveMaskingThreadCount(+1);
		
		try {
			for (int i=0;i<globalTaskIdArr.size();i++) {
				
				
				if (mLib.cancellation_flag)  {
					for (int c=i;c<globalTaskIdArr.size();c++) {
						int cancel_global_task_id=globalTaskIdArr.get(c);
						if (mLib.hmArrStatus.get(cancel_global_task_id)==mLib.ARR_STAT_ASSIGNED)
							mLib.hmArrStatus.put(cancel_global_task_id, mLib.ARR_STAT_FILLED);
					}
					
					
						
					break;
				}
				
				logForThread.setLength(0);
				errForThread.setLength(0);
				
				
				int global_task_id=globalTaskIdArr.get(i);
				long task_id=mLib.hmTaskId.get(global_task_id);
				int rec_count_in_task=mLib.hmTaskSize.get(global_task_id);
				
				if (mLib.globalTaskArr.get(global_task_id)==null) {
					mLib.hmArrStatus.put(global_task_id, mLib.ARR_STAT_FREE);
					mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_INFO, "Taks ["+global_task_id+"] is NULL. skip.");
					mLib.hmInMemoryTaskList.remove(task_id);
					continue;
				}
				
				ArrayList<String[]>  taskArr=mLib.globalTaskArr.get(global_task_id);
				
				//may be timed out by resumeStalledTasks procedure before 
				if (mLib.hmArrStatus.get(global_task_id)!=mLib.ARR_STAT_ASSIGNED) {
					mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_INFO, "Taks ["+global_task_id+"] is reasigned caused by timeout.skip.");
					mLib.hmInMemoryTaskList.remove(task_id);
					continue;
				}
				
				
				//ora-01555 undo hatasini onlemek icin
				//paralel ve gruplularda
				//export bitmeden update yapmiyoruz, tasklari persist ediyoruz.
				if (!mLib.isExportImportSameTime && (mLib.is_paralleled_by_mod || mLib.is_group_mixing) ) {
					if (!mLib.isExportingFinished) {

						mLib.last_worker_heartbeat=System.currentTimeMillis();
						mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_INFO, "Taks ["+global_task_id+"] is persisted directly to database until export finish..");
						
						mLib.writeTaskRecord(
				 				mLib.confDBForUpdate.get(targetDBId), 
				 				work_plan_id, 
				 				work_package_id, 
				 				task_id, 
				 				mLib.globalTaskArr.get(global_task_id),
				 				rec_count_in_task,
				 				mLib.cLib.TASK_STATUS_NEW,
				 				true
				 				);
						
				 		mLib.hmArrStatus.put(global_task_id, mLib.ARR_STAT_FREE);
					 	mLib.globalTaskArr.set(global_task_id, null);
					 	
					 	mLib.hmInMemoryTaskList.remove(task_id);

		
						continue;
					}
				}
			 	
			 	long start_ts=System.currentTimeMillis();
			 	
			 	int failed_rec_count=0;
			 	int succeeded_rec_count=0;
			 	
			 	
			 	if (mLib.isTaskAlreadyFinished(mLib.confDBForUpdate.get(targetDBId), work_plan_id, work_package_id, task_id)) {
			 		mLib.last_worker_heartbeat=System.currentTimeMillis();
			 		
			 		mLib.hmArrStatus.put(global_task_id, mLib.ARR_STAT_FREE);
				 	mLib.globalTaskArr.set(global_task_id, null);
				 	
				 	mLib.hmInMemoryTaskList.remove(task_id);
				 	
				 	mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_INFO, ":) Task [" + task_id + "] with ["+rec_count_in_task+"] record is already masked. skipping...");
			 		
			 		continue;
			 	}

					
			 		
			 	if (!mLib.isLoadedFromConfDb(global_task_id)) {
			 		mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_INFO, "Taks ["+global_task_id+"] is persisting to database since !mLib.hmTaskFromConfDb.get.");
			 		
			 		mLib.writeTaskRecord(
			 				mLib.confDBForUpdate.get(targetDBId), 
			 				work_plan_id, 
			 				work_package_id, 
			 				task_id, 
			 				mLib.globalTaskArr.get(global_task_id),
			 				rec_count_in_task,
			 				mLib.cLib.TASK_STATUS_RUNNING,
			 				mLib.isRollbackRequired
			 				);
			 	}
			 	else 
			 		mLib.cLib.setTaskStatus(
			 				mLib.confDBForUpdate.get(targetDBId), 
			 				work_plan_id, 
			 				work_package_id, 
			 				task_id, 
			 				mLib.cLib.TASK_STATUS_RUNNING, 
			 				0
			 				);
			 		


			 	
			 	mLib.hmArrStatus.put(global_task_id,mLib.ARR_STAT_RUNNING);
		 	
			 	boolean mask_success=false;
			 	
			 	if (!mLib.is_rollback) {
			 		
			 		mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_INFO, "Taks ["+global_task_id+"] is being masked....");
			 		
			 		if (mLib.is_mongo) 
			 			mask_success=maskRecordsForMONGO(taskArr); 
			 		else 
			 			mask_success=maskRecordsForRDBMS(taskArr);
			 	}
			 	else 
			 		mask_success=true;
			 	
			 	mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_INFO, "Taks ["+global_task_id+"] is being written to application db as masked.");
			 	
			 	if (mLib.is_mongo) 
			 		succeeded_rec_count=writeToMONGODB(taskArr);
			 	else {
			 		succeeded_rec_count=writeToAppDB(taskArr);
			 	

		 		if (mLib.is_paralleled_by_mod)
		 			try { mLib.appDBForUpdate.get(this.targetDBId).commit(); } catch(Exception e) {}
			 		
	 			
	 			
			 	}
			 	
			 	long task_duration=System.currentTimeMillis()-start_ts;
			 	mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_INFO, ":) Task [" + task_id + "@"+work_package_id+"] with ["+rec_count_in_task+"] record is finished, mask_success="+mask_success+", succeeded :"+succeeded_rec_count+" by ["+mLib.master_id+"]. " + task_duration + " msecs. ["+mLib.export_table+"]");
			 	
			 	if (mask_success) {
			 					 		
			 		failed_rec_count=all_count-succeeded_rec_count;
				 	
				 	if (succeeded_rec_count<0) succeeded_rec_count=0;
				 	if (succeeded_rec_count>all_count) succeeded_rec_count=all_count;
				 	
				 	if (failed_rec_count<0) failed_rec_count=0;
				 	if (failed_rec_count>all_count) failed_rec_count=all_count;

			 	} else {
			 		failed_rec_count=all_count;
			 	}

			 	
			 	
			 	
			 	


			 	if (failed_rec_count==0) {
			 		//keep first 1 milion recs for preview/compare
			 		if (!mLib.isRollbackRequired && task_id>1000000)
			 			mLib.cLib.setTaskContentNull(mLib.confDBForUpdate.get(targetDBId),"tdm_task_"+work_plan_id+"_"+work_package_id,task_id);
			 		
			 		mLib.cLib.setTaskStatus(
				 			mLib.confDBForUpdate.get(targetDBId), 
				 			work_plan_id, 
				 			work_package_id, 
				 			task_id, 
				 			0,
				 			mLib.cLib.TASK_STATUS_FINISHED, 
				 			succeeded_rec_count,
				 			failed_rec_count,
				 			task_duration
				 			);
			 		
			 	}
			 	else {
			 		
			 		mLib.cLib.setTaskStatus(
				 			mLib.confDBForUpdate.get(targetDBId), 
				 			work_plan_id, 
				 			work_package_id, 
				 			task_id, 
				 			0,
				 			mLib.cLib.TASK_STATUS_RETRY, 
				 			succeeded_rec_count,
				 			failed_rec_count,
				 			task_duration
				 			);

			 		
			 		//to retry, write task info 
			 		if (!mLib.hmTaskFromConfDb.get(global_task_id))
				 		mLib.cLib.setBinInfo(
				 				mLib.confDBForUpdate.get(targetDBId), 
				 				"tdm_task_"+work_plan_id+"_"+work_package_id, 
				 				"id", 
				 				task_id,  
				 				"task_info_zipped", 
				 				genLib.compress(genLib.arrayListToByte(taskArr))
				 				);
			 		
			 		
			 		
			 		mLib.cLib.setBinInfo(mLib.confDBForUpdate.get(targetDBId), "tdm_task_"+work_plan_id+"_"+work_package_id,task_id,"log_info_zipped", logForThread);
					mLib.cLib.setBinInfo(mLib.confDBForUpdate.get(targetDBId), "tdm_task_"+work_plan_id+"_"+work_package_id,task_id,"err_info_zipped", errForThread);

			 	}


			 	
			 	mLib.hmArrStatus.put(global_task_id, mLib.ARR_STAT_FREE);
			 	mLib.globalTaskArr.set(global_task_id, null);
			 	
			 	mLib.hmInMemoryTaskList.remove(task_id);

			 	
			 	mLib.last_worker_heartbeat=System.currentTimeMillis();
			 	
			 	//renew the leasing
			 	mLib.appDBForUpdateLeasedTime.set(this.targetDBId, System.currentTimeMillis());
			 	
			 	
			 	//renew assignment ts for remaining tasks
			 	// to prevent resumes
			 	for (int t=i+1;t<globalTaskIdArr.size();t++) {
			 		global_task_id=globalTaskIdArr.get(t);
			 		mLib.hmTaskAssignTs.put(global_task_id, System.currentTimeMillis());
			 	}

			} //for (int i=0;i<globalTaskIdArr.size();i++)	
			
			
		} catch(Exception e) {
			mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_INFO, "Exception@maskingThreadLoop : "+genLib.getStackTraceAsStringBuilder(e).toString());
			
		} finally {
			mLib.appDBForUpdateState.set(this.targetDBId, mLib.TARGET_DB_STATE_IDDLE);
			
			
			mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_INFO, "set changeActiveMaskingThreadCount -1");
			
			mLib.changeActiveMaskingThreadCount(-1);
			
			Thread.currentThread().interrupt();
			
			return;
		}
		
		
		
		
		
		
	 	
	}
	
	

	
		
		
	//----------------------------------------------------------------------
	
	private volatile boolean running = true;
	
	public void stopRunning()
	{
	    running = false;
	}
	
	
	//---------------------------------------------------------------------
	boolean maskRecordsForMONGO(ArrayList<String[]> taskArr) {
		System.out.println("Masking for MONGO...");
		
		if (taskArr.size()<2) {
			mLib.cLib.mylog(mLib.cLib.LOG_LEVEL_DANGER, "Task Array is invalid. ");
			return false;
		}
		
		
		try {
			String[] exportInfo=taskArr.get(0);
			
			//String export_catalog=exportInfo[0];
			//String export_schema=exportInfo[1];
			//String export_table=exportInfo[2];
			//String export_statement=exportInfo[3];
			int colcount=Integer.parseInt(exportInfo[4]);
			//int export_tab_id=Integer.parseInt(exportInfo[5]);
			
			
			ArrayList<String[]> columnInfo=new ArrayList<String[]>();
			
			for (int i=1;i<1+colcount;i++)  
				columnInfo.add(taskArr.get(i));
			
			int rec_start=1+colcount;
			//int  mask_profile_id=0;
			
			
			//int doc_col_count=mLib.field_names.size();
			int json_col_no=0;
			
			for (int i=rec_start;i<taskArr.size();i++) {
				String[] row=taskArr.get(i);
				json_col_no=row.length-1;
				
				try {
					row[json_col_no]=mLib.maskJsonDocument(row[json_col_no], "", engine).toString();
				} catch(Exception e) {
					mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER, "Exception@maskRecordsForMONGO  : " + e.getMessage());
					return false;
				}
				
				
				taskArr.set(i, row);
			}
			
		} catch(Exception e) {
			mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER, "Exception@maskRecordsForMONGO : "+genLib.getStackTraceAsStringBuilder(e).toString());
			return false;
		}
		
		return true;
		
		
		

	}
	
	//---------------------------------------------------------------------
	int writeToMONGODB(ArrayList<String[]> taskArr) {
		String[] exportInfo=taskArr.get(0);
		
		
		String export_table=exportInfo[2];		
		int colcount=Integer.parseInt(exportInfo[4]);
		
		ArrayList<String[]> columnInfo=new ArrayList<String[]>();
		for (int i=1;i<1+colcount;i++)  
			columnInfo.add(taskArr.get(i));
		
		int rec_start=1+colcount;
		
		ArrayList<String> updateFields=new ArrayList<String>();
		ArrayList<String> pkFields=new ArrayList<String>();
		
		int rec_size=0;
		BasicDBObject filter = new BasicDBObject();
		int arr_size=taskArr.size();
		StringBuilder key=new StringBuilder();
		
		int success_count=0;
		
		
		for (int i=rec_start;i<arr_size;i++) {
			rec_size++;
			
			
			filter.clear();
			for (int p=0;p<colcount-1;p++) {
				key.setLength(0);
				key.append(columnInfo.get(p)[0]);
				
				if (key.toString().equals("_id"))
					filter.append(key.toString(), new ObjectId(taskArr.get(i)[p]));
				else 
					filter.append(key.toString(), taskArr.get(i)[p]);
			}
			
			try {
				Document doc=new Document();
				doc.putAll( ((DBObject) JSON.parse(taskArr.get(i)[colcount-1])).toMap()  );
				
				mLib.mongoDB.getCollection(export_table).findOneAndReplace(filter, doc);
				success_count++;	
			} catch(Exception e) {
				mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER, "Exception@writeToMONGODB : " +e.getMessage());
				e.printStackTrace();
			}
			
		}
		
		this.all_count=rec_size;
			
		return success_count;
		
	}
	
	//---------------------------------------------------------------------
	boolean maskRecordsForRDBMS(ArrayList<String[]> taskArr) {
		if (taskArr==null) {
			mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER, "maskRecordsForRDBMS : Task Array is null. ");
			return false;
		}
		
		if (taskArr.size()<2) {
			mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER, "maskRecordsForRDBMS :Task Array is invalid. ");
			return false;
		}
		
		try {
			String[] exportInfo=taskArr.get(0);
			
			String export_catalog=exportInfo[0];
			String export_schema=exportInfo[1];
			String export_table=exportInfo[2];
			String export_statement=exportInfo[3];
			
			int colcount=Integer.parseInt(exportInfo[4]);
			
			int export_tab_id=Integer.parseInt(exportInfo[5]);
			
			String mask_prof_table_name=export_schema+"."+export_table;
			if (export_schema.length()==0 || export_schema.equals("null")) mask_prof_table_name=export_table;
			
			ArrayList<String[]> columnInfo=new ArrayList<String[]>();
			
			for (int i=1;i<1+colcount;i++)  
				columnInfo.add(taskArr.get(i));
			
			int rec_start=1+colcount;
			int  mask_profile_id=0;
			StringBuilder hkey_ref_value=new StringBuilder();
			
			if (mLib.is_group_mixing || mLib.is_record_mixing) {
				mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DEBUG, "@Mixing records");
				mixArray(taskArr, rec_start,colcount);
			}
			
			
			for (int i=rec_start;i<taskArr.size();i++) {
				String[] row=taskArr.get(i);
				hkey_ref_value.setLength(0);
				
				
				for (int c=0;c<colcount;c++) {
					if (mLib.field_mask_rules.get(c).equals(mLib.MASK_RULE_HASH_REF)) 
						hkey_ref_value.append(row[c]);
				}
				
				for (int c=0;c<colcount;c++) {
					
					mask_profile_id=mLib.decodeMaskParam(""+export_tab_id, mask_prof_table_name, columnInfo.get(c)[0], taskArr.get(i));
					
					
					
					try {
						
						row[c]=mLib.mask( 
								export_tab_id,
								c, 
								row[c],  
								hkey_ref_value, 
								mask_profile_id, 
								mLib.getMaskProfileById(mask_profile_id), 
								row,
								engine
								);	
						
						
					} catch(Exception e) {
						mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER,"Exception@maskRecordsForRDBMS Data to mask:"+row[c]);
						mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER,"Exception@maskRecordsForRDBMS mask_profile_id:"+mask_profile_id);
						StringBuilder logX=new StringBuilder();
						
						logX.setLength(0);
						for (int x=0;x<row.length;x++) {
							if (x>0) logX.append("\t");
							logX.append(row[x]);
						}
						mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER,"Exception@maskRecordsForRDBMS row to mask:"+logX.toString());
						
						String[] dummyArr=mLib.getMaskProfileById(mask_profile_id);

						logX.setLength(0);
						for (int x=0;x<dummyArr.length;x++) {
							if (x>0) logX.append("\t");
							logX.append(dummyArr[x]);
						}
						mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER,"Exception@maskRecordsForRDBMS profile details:"+logX.toString());
						
						mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER,"Exception@maskRecordsForRDBMS Stack:"+genLib.getStackTraceAsStringBuilder(e).toString());
						
						return false;
					}
					
					
					
				}
				
				taskArr.set(i, row);
				
			}	
		} catch(Exception e) {
			mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER,"Exception@maskRecordsForRDBMS General Stack:"+genLib.getStackTraceAsStringBuilder(e).toString());
			
			return false;
		}
		
		
		return true;
	
	}
	
	//---------------------------------------------------------------
	void mixArray(ArrayList<String[]> taskArr, int rec_start, int colcount) {

		int arr_rec_count=taskArr.size()-rec_start;
		if (arr_rec_count==1) return;
		
		long start_ts=System.currentTimeMillis();
		
		ArrayList<Integer> groupMixFieldsArr=new ArrayList<Integer>();
		ArrayList<Integer> recordMixFieldsArr=new ArrayList<Integer>();
		
		for (int c=0;c<colcount;c++) {
			if (mLib.field_mask_rules.get(c).equals(mLib.MASK_RULE_GROUP_MIX)) groupMixFieldsArr.add(c);
			if (mLib.field_mask_rules.get(c).equals(mLib.MASK_RULE_MIX)) recordMixFieldsArr.add(c);
		}

		int swap_id=0;
		
		int half_point=arr_rec_count/2;
		int recno=0;
		
		int random_start=0;
		int random_end=0;
		StringBuilder tmpfld=new StringBuilder();
		
		for (int i=rec_start;i<taskArr.size();i++) {
			recno++;
			random_start=1;
			random_end=half_point;
			
			if (recno>half_point) {
				random_start=half_point+1;
				random_end=arr_rec_count;
			}
			
			//---------------------------------------------------
			if (mLib.is_group_mixing) {
				
				while(true) {
					swap_id=makeRandomSwapId(random_start,random_end)+rec_start-1;
					if (swap_id<taskArr.size() && swap_id>=rec_start) break;
				}
				
				
				
				String[] thisRow=taskArr.get(i);
				String[] swapRow=taskArr.get(swap_id);
				
				
				
				for (int c=0;c<groupMixFieldsArr.size();c++) {
					
					
					tmpfld.setLength(0);
					tmpfld.append(thisRow[groupMixFieldsArr.get(c)]);
					
					
					thisRow[groupMixFieldsArr.get(c)]=swapRow[groupMixFieldsArr.get(c)];
					swapRow[groupMixFieldsArr.get(c)]=tmpfld.toString();
					
					
				}
				
				taskArr.set(i, thisRow);
				taskArr.set(swap_id, swapRow);
				
				
			}
			
			//---------------------------------------------------
			if (mLib.is_record_mixing) {
				for (int c=0;c<recordMixFieldsArr.size();c++) {
					while(true) {
						swap_id=makeRandomSwapId(random_start,random_end)+rec_start-1;
						if (swap_id<taskArr.size() && swap_id>=rec_start) break;
					}
					String[] thisRow=taskArr.get(i);
					String[] swapRow=taskArr.get(swap_id);
					
					tmpfld.setLength(0);
					tmpfld.append(thisRow[recordMixFieldsArr.get(c)]);
					thisRow[recordMixFieldsArr.get(c)]=swapRow[recordMixFieldsArr.get(c)];
					swapRow[recordMixFieldsArr.get(c)]=tmpfld.toString();
					
					taskArr.set(i, thisRow);
					taskArr.set(swap_id, swapRow);
				}
				
				
			}
		} //for (int i=rec_start;
		
		mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DEBUG, "Mix Duration : "+ (System.currentTimeMillis()-start_ts)+ " msecs");
	}
	//----------------------------------------------------------------
	int makeRandomSwapId(int random_start, int random_end) {
		try{
			return random_start+ (int) Math.round(Math.random()*(random_end-random_start+1));
		} catch(Exception e) {
			e.printStackTrace();
			return random_start;
		}
	}
	
	//----------------------------------------------------------------
	int writeToAppDB(ArrayList<String[]> taskArr) {
		
		try {
			String[] exportInfo=taskArr.get(0);
			

			int colcount=Integer.parseInt(exportInfo[4]);
					
			ArrayList<String[]> columnInfo=new ArrayList<String[]>();
			for (int i=1;i<1+colcount;i++)  
				columnInfo.add(taskArr.get(i));
			
			int rec_start=1+colcount;
			
			ArrayList<String> updateFields=new ArrayList<String>();
			ArrayList<String> pkFields=new ArrayList<String>();
			
			for (int c=0;c<colcount;c++) {
				
				if (mLib.field_PKs.get(c).equals("YES")) 
					pkFields.add(mLib.field_names.get(c)); 
				
				
				if (mLib.field_mask_rules.get(c).equals(mLib.MASK_RULE_GROUP)) continue;
				if (mLib.field_mask_rules.get(c).equals(mLib.MASK_RULE_NONE)  
						&& mLib.field_mask_profiles.get(c).indexOf("IF[")==-1) continue;
				if (mLib.field_types.get(c).equals(mLib.FIELD_TYPE_CALCULATED)) continue;
				
				
				updateFields.add(mLib.field_names.get(c));
				
			}		
			
			ArrayList<String[]> bindlist=new ArrayList<String[]>();
			
			ArrayList<String[]> pkValArr=new ArrayList<String[]>();
			int rec_size=0;
			for (int i=rec_start;i<taskArr.size();i++) {
				rec_size++;
				pkValArr.clear();
				
				for (int c=0;c<colcount;c++) {				
					if (mLib.field_PKs.get(c).equals("YES"))  
						pkValArr.add(new String[]{mLib.fieldtype2bindtype( mLib.field_types.get(c), taskArr.get(i)[c]),taskArr.get(i)[c]}); 
					
					if (mLib.field_mask_rules.get(c).equals(mLib.MASK_RULE_GROUP)) continue;
					if (mLib.field_mask_rules.get(c).equals(mLib.MASK_RULE_NONE)  
							&& mLib.field_mask_profiles.get(c).indexOf("IF[")==-1) continue;
					if (mLib.field_types.get(c).equals(mLib.FIELD_TYPE_CALCULATED)) continue;
					
					bindlist.add(new String[]{mLib.fieldtype2bindtype( mLib.field_types.get(c), taskArr.get(i)[c]),taskArr.get(i)[c]}); 
					
				}
				bindlist.addAll(pkValArr); 
				
			}
			
			this.all_count=rec_size;
			
			if (built_update_statement==null)
				built_update_statement=buildUpdateStatement(updateFields, pkFields);
			
			
			
			int binding_size=bindlist.size()/rec_size;
			
			
			int success_count=mLib.cLib.execBatchUpdateSql(
					mLib.appDBForUpdate.get(this.targetDBId)  ,
					mLib.isBatchUpdateSupported,
					built_update_statement,
					bindlist,
					binding_size,
					60,
					mLib,
					logForThread, 
					errForThread
					);
			
			
			
			return success_count;	
		} catch(Exception e) {
			mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER, "Exception@writeToAppDB : " + genLib.getStackTraceAsStringBuilder(e).toString());
			
			return 0;
		}
		
		
		
		
	}
	
	
	
	//-----------------------------------------------------------------
	String  buildUpdateStatement(ArrayList<String> updateFields, ArrayList<String> pkFields) {
		
		if (built_update_statement!=null) return built_update_statement;
		
		mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DEBUG,"buildExportStatement.export_catalog: " + mLib.export_catalog);
		mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DEBUG,"buildExportStatement.export_schema: " + mLib.export_schema);
		mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DEBUG,"buildExportStatement.export_table: " + mLib.export_table);
		
		
		
		String schema_delimiter=".";
		String field_list="*";
		String ext_before_fields="";
		String ext_after_table_name="";
		
		StringBuilder sql=new StringBuilder();
		
		try {
			sql.append("Update ");
			
			if (mLib.db_type.equals(genLib.DB_TYPE_ORACLE)) {
				
				/*
				sql.append(mLib.IdentifierQuote +mLib.export_schema+mLib.IdentifierQuote);
				sql.append(".");
				sql.append(mLib.IdentifierQuote+ mLib.export_table+mLib.IdentifierQuote);
				*/
				
				sql.append(mLib.addStartEndForTable(mLib.export_schema+"."+mLib.export_table));
				
				sql.append(" NOLOGGING ");
				
			} else if (mLib.db_type.equals(genLib.DB_TYPE_MSSQL)) {
				sql.append("[" +mLib.export_schema+"]");
				sql.append(".");
				sql.append("["+ mLib.export_table+"]");
				
				//sql.append(" WITH (NOLOCK) ");
				
			} else if (mLib.db_type.toUpperCase().contains("ACCESS")) {
				sql.append("[" +mLib.export_schema+"]");
				sql.append(".");
				sql.append("["+ mLib.export_table+"]");
			}  else {
				
				sql.append(mLib.addStartEndForTable(mLib.export_schema+"."+mLib.export_table));
				/*
				sql.append(mLib.IdentifierQuote +mLib.export_schema+mLib.IdentifierQuote);
				sql.append(".");
				sql.append(mLib.IdentifierQuote+ mLib.export_table+mLib.IdentifierQuote);
				*/
			}
				
			


			
			
			if (ext_after_table_name.length()>0)  
				sql.append(ext_after_table_name);
			
			
			
			sql.append(" SET ");
			
			for (int i=0;i<updateFields.size();i++) {
				if (i>0) sql.append(", ");
				if (mLib.db_type.toUpperCase().contains("ACCESS")) {
					sql.append("["+updateFields.get(i)+"]"+"=?");
				}
				else 
					//sql.append(mLib.IdentifierQuote+updateFields.get(i)+mLib.IdentifierQuote+"=?");
					sql.append(mLib.addStartEndForColumn(updateFields.get(i))+"=?");
			}
			
			sql.append(" WHERE ");
			
			for (int i=0;i<pkFields.size();i++) {
				if (i>0) sql.append(" AND ");;
				if (mLib.db_type.toUpperCase().contains("ACCESS")) {
					sql.append("["+pkFields.get(i)+"]"+"=?");
				}
				else 
					//sql.append(mLib.IdentifierQuote+pkFields.get(i)+mLib.IdentifierQuote+"=?");
					sql.append(mLib.addStartEndForColumn(pkFields.get(i))+"=?");
			}
			
		} catch(Exception e) {
			mLib.cLib.myloggerBase(logForThread, errForThread, mLib.cLib.LOG_LEVEL_DANGER,"Exception@buildExportStatement stack :"+genLib.getStackTraceAsStringBuilder(e).toString());
			
		}
		
		
		
				
		return sql.toString();
		
		
	}
	
	
	
	
}
