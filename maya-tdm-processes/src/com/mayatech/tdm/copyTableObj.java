package com.mayatech.tdm;

import java.util.ArrayList;

public class copyTableObj {
	
	int level=0;
	int app_id=0;
	int tab_id=0; 
	String catalog="";
	String owner="";
	String table_name="";
	
	String source_catalog="";
	String source_owner="";
	String source_table_name="";
	
	String source_partition_name="";
	
	String family_id="";
	
	String target_catalog="";
	String target_owner="";
	String target_table_name="";
	
	String source_db_type="";
	String target_db_type="";
	
	String source_db_id="";
	String target_db_id="";
	
	String user_filter_type="";
	String user_filter_sql="";
	String user_filter_values="";
	
	String parallel_function="";
	String parallel_field="";
	int parallel_count=1;
	
	//ArrayList<String[]> bindlistUSERFILTER=new ArrayList<String[]>();
	
	
	String tab_filter="";
	
	String hint_after_select="";
	String hint_before_table="";
	String hint_after_table="";
	
	String check_existence_action="";
	String check_existence_sql="";
	String check_existence_on_fields="";
	
	String rel_type="";
	String parent_tab_pk_fields="";
	String rel_on_fields="";
    String tab_relation_filter="";
	boolean hasChild=false;
	boolean hasParent=false;
	boolean hasPrimaryKey=false;
	
	boolean hasNeeds=false;
	
	boolean hasCheckExistance=false;
	
	boolean hasFixedListColumns=false;
	ArrayList<Integer> fixedFieldsArr=new ArrayList<Integer>();
	
	ArrayList<Integer> childTableObjIds=new ArrayList<Integer>();
	int  parent_tab_id=0;
	
	ArrayList<String[]> fields=new ArrayList<String[]>();
	ArrayList<String[]> PRI_KEYfields=new ArrayList<String[]>();
	ArrayList<Integer> thisTablePKEYfieldORDERS=new ArrayList<Integer>();
	
	ArrayList<String[]> extraFields=new ArrayList<String[]>();
	ArrayList<Integer>  extraFieldTypes=new ArrayList<Integer>();

	
	ArrayList<String> relPKFieldNames=new ArrayList<String>();
	ArrayList<String> relFieldNames=new ArrayList<String>();
	ArrayList<String> recursiveFieldNames=new ArrayList<String>();
	
	ArrayList<Integer> relParentTablePKFieldIDs=new ArrayList<Integer>();
	ArrayList<Integer> relThisTableFieldIDs=new ArrayList<Integer>();
	ArrayList<Integer> recursiveFieldIDs=new ArrayList<Integer>();
	
	
	ArrayList<Integer> checkExistanceFieldIDs=new ArrayList<Integer>();
	ArrayList<Boolean> fieldToBeMaskedArr=new ArrayList<Boolean>();
	
	ArrayList<String[]> needRelArr=new ArrayList<String[]>();
	
	
	String retrieve_sql="";
	String retrieve_rollback_sql="";
	String recursive_sql="";
	String insert_sql="";
	String update_sql="";
	String delete_rollback_sql="";
	
	int copy_table_obj_id=-1;
	int copy_table_parent_obj_id=-1;
	
	long copy_count=0;
	
	ArrayList<Integer> needingFieldIds=new ArrayList<Integer>();
	ArrayList<Integer> needingNeedArrIds=new ArrayList<Integer>();
	
	boolean isRecursive=false;
	
	//------------------------------------------------

	public copyTableObj() {
		
	}
	
	

	//---------------------------------
	void setTable(int parent_tab_id, int tab_id, int app_id, int level, String catalog, String owner,  String table_name, String family_id) {
		this.catalog=catalog;
		this.owner=owner;
		this.table_name=table_name;
		this.family_id=family_id;
		this.app_id=app_id;
		this.tab_id=tab_id;
		this.level=level;
		this.parent_tab_id=parent_tab_id;
		childTableObjIds.clear();
		
	}
	
	//--------------------------------
	void setTableObjId(int table_obj_id) {
		this.copy_table_obj_id=table_obj_id;
	}
	

	


	
	//---------------------------------
	void setTabFilter(String tab_filter) {
		this.tab_filter=tab_filter;
	}
	
	//---------------------------------
	void setHints(String hint_after_select, String hint_before_table, String hint_after_table) {
		this.hint_after_select=hint_after_select;
		this.hint_before_table=hint_before_table;
		this.hint_after_table=hint_after_table;
		
	}
	
	//---------------------------------
	void setExistanceCheckConfig(String check_existence_action, String check_existence_sql, String check_existence_on_fields) {
		this.check_existence_action=check_existence_action;
		this.check_existence_sql=check_existence_sql;
		this.check_existence_on_fields=check_existence_on_fields;
		



		
		if (check_existence_sql.trim().length()==0 && check_existence_on_fields.length()==0) 
			check_existence_action="NONE";
		
	}
	
	//----------------------------------
	void setDbInfo(String source_db_type, String target_db_type, String source_db_id, String target_db_id) {
		this.source_db_type=source_db_type;
		this.target_db_type=target_db_type;
		
		this.source_db_id=source_db_id;
		this.target_db_id=target_db_id;
	}
	
	
	
	//--------------------------------
	void setRecursiveFields(String recursive_fields) {
		String[] relArr=recursive_fields.split("\\|::\\|");
		
		for (int i=0;i<relArr.length;i++) {
			String recursive_field_name=relArr[i];
			if (recursive_field_name.trim().length()==0) continue;
			recursiveFieldNames.add(recursive_field_name);
			for (int f=0;f<fields.size();f++) {
				if (fields.get(f)[0].equals(recursive_field_name)) {
					recursiveFieldIDs.add(f);
					break;
				}
			}
		}
	}
	
	//---------------------------------
	void setParentRelation(
				String rel_type, 
				String parent_tab_pk_fields, 
				String rel_on_fields, 
				String tab_relation_filter, 
				copyTableObj parencopyTable
				) {
		this.rel_type=rel_type;
		this.parent_tab_pk_fields=parent_tab_pk_fields;
		this.rel_on_fields=rel_on_fields;
		this.tab_relation_filter=tab_relation_filter;
		this.copy_table_parent_obj_id=parencopyTable.copy_table_obj_id;
		
		String[] relPkArr=parent_tab_pk_fields.split(",");
		
		System.out.println(" ...........  setParentRelation  ["+table_name+" "+rel_type+" on "+rel_on_fields+" ] for " + this.table_name);
		
		relPKFieldNames.clear();
		relParentTablePKFieldIDs.clear();
		
		for (int i=0;i<relPkArr.length;i++) {
			
			relPKFieldNames.add(relPkArr[i]);
			for (int f=0;f<parencopyTable.fields.size();f++) {
				if (parencopyTable.fields.get(f)[0].equals(relPkArr[i])) {
					relParentTablePKFieldIDs.add(f);
					break;
				}
			}
		}
		
		String[] relArr=rel_on_fields.split(",");
		
		relFieldNames.clear();
		relThisTableFieldIDs.clear();
		
		for (int i=0;i<relArr.length;i++) {
			
			relFieldNames.add(relArr[i]);
			
			for (int f=0;f<fields.size();f++) {
				if (fields.get(f)[0].equals(relArr[i])) {
					
					relThisTableFieldIDs.add(f);
					
					break;
				}
			}
		}
	}
	
	//---------------------------------
	void addChildTabObjId(int child_tab_obj_id) {
		
		childTableObjIds.add(child_tab_obj_id);
	}
	
	
	
	//---------------------------------
	void addField(
			String field_name, 
			String field_type, 
			String is_pk, 
			String binding_type,
			String mask_prof_id, 
			String is_conditional, 
			String condition_expr, 
			String list_field_name,
			String mask_prof_rule_id,
			String copy_ref_tab_id,
			String copy_ref_field_name
			) {
		
		String list_field_name_real=list_field_name;
		String list_field_name_fixed="NO";
		
		
		
		if (list_field_name.contains(":FIXED")) {
			list_field_name_fixed="YES";
			list_field_name_real=list_field_name.split(":")[0];
			
			//hasFixedListColumns=true;
			
			//fixedFieldsArr.add(fields.size());
		}
		
		if (mask_prof_rule_id.equals("HASH_REF")) {
			hasFixedListColumns=true;
			fixedFieldsArr.add(fields.size());
		}
		
		fields.add(new String[]{
				field_name,
				field_type,
				is_pk,
				binding_type,
				mask_prof_id, 
				is_conditional, 
				condition_expr, 
				list_field_name_real,
				list_field_name_fixed,
				copy_ref_tab_id,
				copy_ref_field_name
		});
		
		boolean to_be_masked=false;
		if (!mask_prof_id.equals("0") || is_conditional.equals("YES")) 
			to_be_masked=true;
		fieldToBeMaskedArr.add(to_be_masked);
		
		if (is_pk.equals("YES")) {
			PRI_KEYfields.add(fields.get(fields.size()-1));
			
			thisTablePKEYfieldORDERS.add(fields.size()-1);
		}
		
		
			
	}
	
	
	//---------------------------------
		void addExtraField(
				String field_name, 
				String field_type, 
				String binding_type,
				String mask_prof_id
				) {
			
			
			extraFields.add(new String[]{
					field_name,
					field_type,
					binding_type,
					mask_prof_id
			});
			
	
		}
	
	boolean hasCopyReferencingField=false;
	
	
	static final String ORACLE_INSERT_APPEND_HINT=" /*+ append */ ";
	//---------------------------------
	void compile(ArrayList<String> copyRefFieldsArr) {

		String retrieve_sql="";
		String retrieve_rollback_sql="";
		String recursive_sql="";
		String insert_sql="";
		String update_sql="";
		String delete_rollback_sql="";
		
		//ilk derlenmede field bazli check sql olusur
		//ikincide bu sql dolu olacagindan sql bos set edilebilr
		//o yuzden bunu basta ayarliyoruz
		String check_existence_sql=this.check_existence_sql;
		
		
		// ssping bindlistUSERFILTER.clear();
		
		hasChild=false;
		if (childTableObjIds.size()>0) hasChild=true;
		
		isRecursive=false;
				
		if (recursiveFieldIDs.size()>0 && recursiveFieldIDs.size()==PRI_KEYfields.size()) 
			isRecursive=true;
		
		hasParent=false;
		if (level>1) hasParent=true;
		
		hasCopyReferencingField=false;
		
		for (int i=0;i<fields.size();i++) {
			String key=""+this.tab_id+"."+fields.get(i)[0];
			if (copyRefFieldsArr.indexOf(key)>-1) {
				hasCopyReferencingField=true;
				break;
			}
		}
		
		//hasCopyReferencingField=true ;  //YALIÞ HESAPLANIYOR, TEST AMACLIDIR SÝLÝNECEK
		
		hasNeeds=false;
		
		needingFieldIds.clear();
		needingNeedArrIds.clear();
		
		if (needRelArr.size()>0) {
			hasNeeds=true;
			for (int i=0;i<needRelArr.size();i++) {
				String rel_on_fields=needRelArr.get(i)[2];
				
				for (int f=0;f<fields.size();f++) {
					String field_name=fields.get(f)[0];
					if (rel_on_fields.equals(field_name)) {
						needingFieldIds.add(f);
						needingNeedArrIds.add(i);
						break;
					}
				}
				
			}
		}
		
		
		retrieve_sql="select ";
		retrieve_rollback_sql="select ";
		recursive_sql="select ";
		delete_rollback_sql="delete from "+target_owner+"."+target_table_name;
		
		delete_rollback_sql=delete_rollback_sql+" WHERE ";
		
		if (thisTablePKEYfieldORDERS.size()>0) hasPrimaryKey=true;
		
		for (int f=0;f<thisTablePKEYfieldORDERS.size();f++) {
			int pk_field_id=thisTablePKEYfieldORDERS.get(f);
			if (f>0) delete_rollback_sql=delete_rollback_sql+" AND ";
			delete_rollback_sql=delete_rollback_sql+fields.get(pk_field_id)[0]+"=?";
		}
		
		if (hint_after_select.length()>0) {
			retrieve_sql=retrieve_sql+" "+hint_after_select+ " ";
			retrieve_rollback_sql=retrieve_rollback_sql+" "+hint_after_select+ " ";
			recursive_sql=recursive_sql+" "+hint_after_select+ " ";
		}
		
		
		
		insert_sql="insert into "+target_owner+"."+target_table_name + " (";
		
		for (int i=0;i<fields.size();i++) {
			if (i>0) {
				retrieve_sql=retrieve_sql+", "; 
				retrieve_rollback_sql=retrieve_rollback_sql+", "; 
				recursive_sql=recursive_sql+", ";
			}
			
			retrieve_sql=retrieve_sql+fields.get(i)[0];
			retrieve_rollback_sql=retrieve_rollback_sql+fields.get(i)[0];
			recursive_sql=recursive_sql+fields.get(i)[0];
			
			if (i>0) insert_sql=insert_sql+", "; 
			insert_sql=insert_sql+fields.get(i)[0];
		}
		
		for (int i=0;i<extraFields.size();i++) {
			insert_sql=insert_sql+", "; 
			insert_sql=insert_sql+extraFields.get(i)[0];
		}
		
		
		if (hint_before_table.length()>0) {
			retrieve_sql=retrieve_sql+" "+hint_before_table+ " ";
			retrieve_rollback_sql=retrieve_rollback_sql+" "+hint_before_table+ " ";
			recursive_sql=recursive_sql+" "+hint_before_table+ " ";
		}
		
		retrieve_sql=retrieve_sql+" from "+source_owner+"."+source_table_name;
		retrieve_rollback_sql=retrieve_rollback_sql+" from "+target_owner+"."+target_table_name;
		recursive_sql=recursive_sql+" from "+source_owner+"."+source_table_name;
		
		if (user_filter_type.equals("BY_PARTITION")) {
			String copy_partition_name=source_partition_name;
			if (source_db_type.equals("ORACLE")) {
				hint_after_table="PARTITION ("+copy_partition_name+")";
			}
			
		} else  if (parallel_field.indexOf("BY_PARTITION")==0) {
			String parallel_partition_name=parallel_field.split(":")[1];
			if (!parallel_partition_name.equals("-")) {
				if (source_db_type.equals("ORACLE")) {
					hint_after_table="PARTITION ("+parallel_partition_name+")";
				}
			}
		}
		
		
		if (source_db_type.equals("ORACLE") ) {
			// oracle için daha hizli kopyalamayi saglar
			if (!hint_after_table.contains(ORACLE_INSERT_APPEND_HINT))
					hint_after_table=hint_after_table+ORACLE_INSERT_APPEND_HINT; 
		} else if (source_db_type.equals("MSSQL") ) {
			if (!hint_after_table.toUpperCase().contains("WITH") && !hint_after_table.toUpperCase().contains("NOLOCK"))
				hint_after_table=hint_after_table+" WITH(NOLOCK) "; 
		}
			
		
		
		
		if (hint_after_table.length()>0) {
			retrieve_sql=retrieve_sql+" "+hint_after_table+ " ";
			retrieve_rollback_sql=retrieve_rollback_sql+" "+hint_after_table+ " ";
			recursive_sql=recursive_sql+" "+hint_after_table+ " ";
		}
		
		if (relFieldNames.size()>0) {
			retrieve_sql=retrieve_sql + " where ";
			retrieve_rollback_sql=retrieve_rollback_sql + " where ";

			for (int i=0;i<relFieldNames.size();i++) {
				if (i>0) retrieve_sql=retrieve_sql+" AND "; 
				retrieve_sql=retrieve_sql+relFieldNames.get(i)+"=?";
				
				if (i>0) retrieve_rollback_sql=retrieve_rollback_sql+" AND "; 
				retrieve_rollback_sql=retrieve_rollback_sql+relFieldNames.get(i)+"=?";
				
			}
		}
			
		
		
		
		if (recursiveFieldNames.size()>0) {
			recursive_sql=recursive_sql + " where ";
			
			for (int i=0;i<recursiveFieldNames.size();i++) {
				if (i>0) recursive_sql=recursive_sql+" AND "; 
				recursive_sql=recursive_sql+recursiveFieldNames.get(i)+"=?";
			}
		}
			
		
		
		
		insert_sql=insert_sql+") values (";
		
		for (int i=0;i<fields.size();i++) {
			if (i>0) insert_sql=insert_sql+", "; 
			insert_sql=insert_sql+"?";
		}
		
		for (int i=0;i<extraFields.size();i++) {
			insert_sql=insert_sql+", "; 
			insert_sql=insert_sql+"?";
		}
		
		insert_sql=insert_sql+")";
		
		if (tab_filter.length()>0) {
			if (retrieve_sql.contains(" where ")) {
				retrieve_sql=retrieve_sql+" AND "+tab_filter;
				retrieve_rollback_sql=retrieve_rollback_sql+" AND "+tab_filter;
			}
				
			else {
				retrieve_sql=retrieve_sql+" where "+tab_filter;
				retrieve_rollback_sql=retrieve_rollback_sql+" where "+tab_filter;
			}
				
			
			if (recursive_sql.contains(" where "))
				recursive_sql=recursive_sql+" AND "+tab_filter;
			else
				recursive_sql=recursive_sql+" where "+tab_filter;
		}
		
		
		if (parallel_count>1 && parallel_field.length()>0 && parallel_function.length()>0) {
			
			String parallelism_filter="";
			
			if (parallel_function.equals("MOD"))
				parallelism_filter="mod("+parallel_field+","+parallel_count+")=?";
			else if (parallel_function.equals("$mod")) //mongo
				parallelism_filter="";
			else 
				parallelism_filter=parallel_field+" % "+parallel_count+"=?";

			if (parallelism_filter.length()>0) {
					
				// ssping bindlistUSERFILTER.add(new String[]{"INTEGER","%PARALLEL_NO%"});
				
				if (retrieve_sql.contains(" where ")) 
					retrieve_sql=retrieve_sql+" AND "+parallelism_filter;
				else 
					retrieve_sql=retrieve_sql+" where "+parallelism_filter;
				
				if (recursive_sql.contains(" where "))
					recursive_sql=recursive_sql+" AND "+parallelism_filter;
				else
					recursive_sql=recursive_sql+" where "+parallelism_filter;
				
				
				
			} //if (parallelism_filter.length()>0)
			
		}
		
		
		
		if (tab_relation_filter.length()>0) {
			if (retrieve_sql.contains(" where ")) {
				retrieve_sql=retrieve_sql+" AND "+tab_relation_filter;
				retrieve_rollback_sql=retrieve_rollback_sql+" AND "+tab_relation_filter;
			}
				
			else {
				retrieve_sql=retrieve_sql+" where "+tab_relation_filter;
				retrieve_rollback_sql=retrieve_rollback_sql+" where "+tab_relation_filter;
			}
				
		}
		
		
		
		if (user_filter_type.length()>0 && user_filter_sql.trim().length()>0) {
			
			if (retrieve_sql.contains(" where ")) {
				retrieve_sql=retrieve_sql+" AND "+user_filter_sql;
				retrieve_rollback_sql=retrieve_rollback_sql+" AND "+user_filter_sql;
			} else {
				retrieve_sql=retrieve_sql+" where "+user_filter_sql;
				retrieve_rollback_sql=retrieve_rollback_sql+" where "+user_filter_sql;
			}
				


			
		}
		
		
		
		
		
		this.hasCheckExistance=false;
		if (!check_existence_action.equals("NONE")) {
			this.hasCheckExistance=true;
			
			if (check_existence_action.equals("UPDATE")) {
				update_sql="update " + target_owner+"."+target_table_name +" set ";
				
				int update_field_cnt=0;
				
				for (int f=0;f<fields.size();f++) {
					if (thisTablePKEYfieldORDERS.indexOf(f)>-1) continue;
					update_field_cnt++;
					if (update_field_cnt>1) update_sql=update_sql+", ";
					update_sql=update_sql+fields.get(f)[0]+"=?";
				}
				update_sql=update_sql+" WHERE ";
				
				for (int f=0;f<thisTablePKEYfieldORDERS.size();f++) {
					int pk_field_id=thisTablePKEYfieldORDERS.get(f);
					if (f>0) update_sql=update_sql+" AND ";
					update_sql=update_sql+fields.get(pk_field_id)[0]+"=?";
				}
			}
		}
		
		String[] arr=check_existence_on_fields.split("\\|::\\|");
		
		for (int i=0;i<arr.length;i++) {
			String check_field=arr[i];
			if (check_field.trim().length()==0) continue;
			int check_field_id=-1;
			
			for (int f=0;f<fields.size();f++) {
				String field_name=fields.get(f)[0];
				if (check_field.trim().equals(field_name)) {
					check_field_id=f;
					break;
				}
			}
			
			if (check_field_id==-1) {
				System.out.println("Check field "+check_field+" not found in field list.");
				continue;
			}
			
			if (checkExistanceFieldIDs.indexOf(check_field_id)==-1)
				checkExistanceFieldIDs.add(check_field_id);
			
		}
		
		
		if (checkExistanceFieldIDs.size()>0 && this.check_existence_sql.trim().length()==0  ) {
			
			check_existence_sql="select ";
			
			for (int i=0;i<thisTablePKEYfieldORDERS.size();i++) {
				int field_id=thisTablePKEYfieldORDERS.get(i);
				if (i>0) check_existence_sql=check_existence_sql+", ";
				check_existence_sql=check_existence_sql+fields.get(field_id)[0];
			}
			
			if (source_db_type.equals("MSSQL") ) 
				check_existence_sql=check_existence_sql+" from " + target_owner+"."+target_table_name +" WITH (NOLOCK) WHERE " ;
			else
				check_existence_sql=check_existence_sql+" from " + target_owner+"."+target_table_name +" WHERE " ;
			
			for (int i=0;i<checkExistanceFieldIDs.size();i++) {
				if (i>0) check_existence_sql=check_existence_sql +" AND ";
				check_existence_sql=check_existence_sql+fields.get(checkExistanceFieldIDs.get(i))[0]+ "=? ";
			}	
		}
			
		
		
		
		this.retrieve_sql=retrieve_sql;
		this.retrieve_rollback_sql=retrieve_rollback_sql;
		this.recursive_sql=recursive_sql;
		this.insert_sql=insert_sql;
		this.update_sql=update_sql;
		this.delete_rollback_sql=delete_rollback_sql;
		this.check_existence_sql=check_existence_sql;
		
		
		
		System.out.println("");
		System.out.println(" ********************************************************");
		System.out.println(" *** INFO FOR  : "+target_table_name);
		System.out.println(" ********************************************************");
		System.out.println(" Retrieve SQL           : "+this.retrieve_sql);
		System.out.println(" Parallel Function      : "+this.parallel_function);
		System.out.println(" Parallel Field         : "+this.parallel_field);
		System.out.println(" Parallel Count         : "+this.parallel_count);

		System.out.println(" Recursive SQL          : "+this.recursive_sql);
		System.out.println(" Insert SQL             : "+this.insert_sql);
		System.out.println(" Check Existance SQL    : "+this.check_existence_sql);
		System.out.println(" CHECK EXISTANCE ACTION : "+this.check_existence_action);
		System.out.println(" CHECK EXISTANCE FIELDS : "+this.check_existence_on_fields);
		System.out.println(" Update SQL             : "+this.update_sql);
		System.out.println(" Rollback SQL           : "+this.delete_rollback_sql);
		
		System.out.println("");
		
	}
	
	
	
	
}
