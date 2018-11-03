package com.mayatech.datapool;

import com.mayatech.baseLibs.genLib;

public class poolDriver {

	public static void main(String[] args) {
		dataPoolServer m=new dataPoolServer();
		
		int data_pool_instance_id=0;
		int app_id=0;
		int target_id=0;
		int target_pool_size=0;
		boolean is_debug=false;
		int paralellism_count=10;

		boolean is_params_ok=true;
		
		try{data_pool_instance_id=Integer.parseInt(genLib.getEnvValue("DATA_POOL_INSTANCE_ID"));  } catch(Exception e) {is_params_ok=false; System.out.println("Pool Instance id is not valid.");}
		try{app_id=Integer.parseInt(genLib.getEnvValue("DATA_APP_ID"));  } catch(Exception e) {is_params_ok=false; System.out.println("Application id is not valid.");}
		try{target_id=Integer.parseInt(genLib.getEnvValue("DATA_TARGET_ID"));  } catch(Exception e) {is_params_ok=false; System.out.println("Target id is not valid.");}
		try{target_pool_size=Integer.parseInt(genLib.getEnvValue("DATA_TARGET_POOL_SIZE"));  } catch(Exception e) {is_params_ok=false; System.out.println("Target pool size is not valid.");}
		try{
			String is_debug_str=genLib.getEnvValue("DATA_TARGET_IS_DEBUG");  
			if (is_debug_str.equals("YES")) is_debug=true;
		} catch(Exception e) {is_params_ok=false; System.out.println("Is Debug is not valid.");}
		try{paralellism_count=Integer.parseInt(genLib.getEnvValue("DATA_TARGET_PARALELLISM_COUNT"));  } catch(Exception e) {is_params_ok=false; System.out.println("Paralellism count is not valid.");}


		String conf_driver=genLib.getEnvValue("DM_PROXY_CONFIG_DB_DRIVER");
		String conf_connstr=genLib.getEnvValue("DM_PROXY_CONFIG_DB_URL");
		String conf_username=genLib.getEnvValue("DM_PROXY_CONFIG_DB_USERNAME");
		String conf_password=genLib.getEnvValue("DM_PROXY_CONFIG_DB_PASSWORD");

		if (!is_params_ok) System.exit(0);
		
		System.out.println("----------------------------------------------");
		System.out.println("---      STARTING NEW DATA POOL SERVER      --");
		System.out.println("----------------------------------------------");
		System.out.println("instance_id................................. : "+data_pool_instance_id);
		System.out.println("app_id...................................... : "+app_id);
		System.out.println("target_id................................... : "+target_id);
		System.out.println("target_pool_size............................ : "+target_pool_size);
		System.out.println("is_debug.................................... : "+is_debug);
		System.out.println("paralellism_count........................... : "+paralellism_count);
		System.out.println("conf_driver................................. : "+conf_driver);
		System.out.println("conf_connstr................................ : "+conf_connstr);
		System.out.println("conf_username............................... : "+conf_username);
		System.out.println("conf_password............................... : "+"************");
		System.out.println("----------------------------------------------");
		
		
		m.initNewDataPoolServer(
				data_pool_instance_id, 
				app_id, 
				target_id, 
				target_pool_size, 
				is_debug,
				paralellism_count,
				conf_driver, 
				conf_connstr, 
				conf_username, 
				conf_password);
		
		
		
		
	}

}
