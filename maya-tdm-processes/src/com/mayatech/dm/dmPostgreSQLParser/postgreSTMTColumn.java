package com.mayatech.dm.dmPostgreSQLParser;

import java.util.ArrayList;

import com.mayatech.baseLibs.genLib;
import com.mayatech.dm.ddmClient;
import com.mayatech.dm.ddmLib;

public class postgreSTMTColumn {

	String col_path;
	
	public String catalog_name;
	public String schema_name;
	public String object_name;
	public String column_name;
	public String data_type;
	String maskingFunction;

	
	boolean is_exception=false;
	boolean isMasked=false;
	
	
	void compile(ddmClient ddmClient) {
		catalog_name="";
		col_path=schema_name+"."+object_name+"."+column_name;
		
		isMasked=ddmClient.dm.hmConfig.containsKey("MASK_METHOD_FOR_COLUMN_"+col_path);
		
		if (isMasked) {
			maskingFunction=(String) ddmClient.dm.hmConfig.get("MASK_METHOD_FOR_COLUMN_"+col_path);
			is_exception=postgreParser.checkColumnException(this, ddmClient);
			return;
		}
		
		/*
		sampleMaskingProfilesTemp.add(new String[]{
				rule_id,
				rule_scope,
				rule_type,		
				rule_parameter1,		
				min_match_rate,	
				masking_function,
				});
		*/
		
		String hm_key="RULE_BASED_MASKING_FUNCTION_"+col_path;
		
		boolean isFoundInCache=ddmClient.dm.hmCache.containsKey(hm_key);
		
		if (isFoundInCache) {
			maskingFunction=(String) ddmClient.dm.hmCache.get(hm_key);
			if (maskingFunction!=null && maskingFunction.length()>0) isMasked=true;
			return;
		}
		
		if (schema_name.equals("SYS")) return;
		
		ArrayList<String[]> sampleMaskingProfiles=(ArrayList<String[]>) ddmClient.dm.hmConfig.get("SAMPLE_MASKING_PROFILES");

		ArrayList<String[]> sampleDataArr=new ArrayList<String[]>();
		
		if (sampleMaskingProfiles!=null)
			for (int i=0;i<sampleMaskingProfiles.size();i++) {
				
				String rule_id=sampleMaskingProfiles.get(i)[0];
				
				
				//if (rule_scope.equals("DATA")) continue;
				
				if (postgreParser.checkRuleException(rule_id, ddmClient)) {
					if (ddmClient.dm.is_debug ||  ddmClient.is_tracing) ddmClient.mydebug("checkRuleException matched. skipping this rule...");
					
					continue;
				}
				
				String rule_scope=sampleMaskingProfiles.get(i)[1];
				
				boolean isRuleMatched=false;
				
				try {
					
					
					int targetRate=0;
					sampleDataArr.clear();
					
					
					if (rule_scope.equals("COL"))  {
						sampleDataArr.add(new String[]{column_name});
						targetRate=100;
					} else if (rule_scope.equals("COL_TYPE")) {
						sampleDataArr.add(new String[]{data_type});
						targetRate=100;
					} else if (rule_scope.equals("DATA")) {
						ddmLib.getSampleDataPostgreSQL(this, sampleDataArr, ddmClient.dm.sample_size, ddmClient);
						
						if (ddmClient.dm.is_debug ||  ddmClient.is_tracing)  ddmClient.mydebug("Sample Extracted : "+sampleDataArr.size());
						
						try{targetRate=Integer.parseInt(sampleMaskingProfiles.get(i)[4]);} catch(Exception e) {targetRate=100;}
						if (targetRate<1) targetRate=1; else if (targetRate>100) targetRate=100;
						
					}
					
					
					String rule_type=sampleMaskingProfiles.get(i)[2];
					String rule_parameter1=sampleMaskingProfiles.get(i)[3];
		
					if (ddmClient.dm.is_debug ||  ddmClient.is_tracing) ddmClient.mydebug("checkig for rule_type : "+rule_type+", rule_parameter1:"+rule_parameter1);
					
					isRuleMatched=ddmLib.evaluateDataArray(ddmClient, sampleDataArr, 0, rule_id, rule_type, rule_parameter1, targetRate);
				}
				catch(Exception e) {
					ddmClient.mydebug("Exception@postgreSTMTColumn.compile:"+genLib.getStackTraceAsStringBuilder(e).toString());
				}
				
				if (ddmClient.dm.is_debug ||  ddmClient.is_tracing) ddmClient.mydebug("isRuleMatched:"+isRuleMatched);
				
				if (isRuleMatched) {
					maskingFunction=sampleMaskingProfiles.get(i)[5];
					
					if (ddmClient.dm.is_debug ||  ddmClient.is_tracing) ddmClient.mydebug("maskingFunction:"+maskingFunction);
					this.isMasked=true;
					
					break;
					
				}
			}
		
		if (maskingFunction!=null)
			ddmClient.dm.hmCache.put(hm_key,maskingFunction);
		else 
			ddmClient.dm.hmCache.put(hm_key,"");
		
	}
	
	
	
}
