package com.mayatech.Test;

import com.mayatech.tdm.ConfDBOper;

public class testDeploy {

	
	public static void main(String[] args) {
		ConfDBOper d=new ConfDBOper(false);
		
		d.MADBuildDeployApplication(
				"deploy", 
				"50", //request_id, 
				"1",
				"102", //application_id, 
				"11", //environment_id, 
				"111", // target_platform_id, 
				"1445" //deploy_member_id
				);
		
		d.closeAll();
	}
}
