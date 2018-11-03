package com.mayatech.maskdisc;

import com.mayatech.baseLibs.genLib;

public class maskDiscDriver {

	public static void main(String[] args) {
		maskDiscServer m=new maskDiscServer();
		
		int discovery_id=0;

		boolean is_params_ok=true;
		
		try{discovery_id=Integer.parseInt(genLib.getEnvValue("DISCOVERY_ID"));  } catch(Exception e) {is_params_ok=false; System.out.println("Discovery id is not valid.");}
		

		String conf_driver=genLib.getEnvValue("CONFIG_DB_DRIVER");
		String conf_connstr=genLib.getEnvValue("CONFIG_DB_URL");
		String conf_username=genLib.getEnvValue("CONFIG_DB_USERNAME");
		String conf_password=genLib.getEnvValue("CONFIG_DB_PASSWORD");

		if (!is_params_ok) System.exit(0);
		
		System.out.println("----------------------------------------------");
		System.out.println("---      STARTING NEW DATA POOL SERVER      --");
		System.out.println("----------------------------------------------");
		System.out.println("instance_id................................. : "+discovery_id);
		System.out.println("conf_driver................................. : "+conf_driver);
		System.out.println("conf_connstr................................ : "+conf_connstr);
		System.out.println("conf_username............................... : "+conf_username);
		System.out.println("conf_password............................... : "+"************");
		System.out.println("----------------------------------------------");
		
		
		m.initNewMaskDiscoveryServer(
				discovery_id,
				conf_driver, 
				conf_connstr, 
				conf_username, 
				conf_password);
		
		
		boolean is_ok=m.loadParameters();
		
		if (is_ok) {
		
			m.startCheckCancelThread();
			
			boolean is_discovered=false;
			is_discovered=m.startDiscovery();
			
			m.finishDiscovery(is_discovered);
			
			m.closeAll();
			
		}
		
		
		
		
	}

}
