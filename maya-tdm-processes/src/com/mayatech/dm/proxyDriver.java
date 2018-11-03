package com.mayatech.dm;

import java.nio.charset.Charset;

import com.mayatech.baseLibs.genLib;

public class proxyDriver {

	public static void main(String[] args) {
		ddmProxyServer m=new ddmProxyServer();
		
		int proxy_id=0;
		String proxy_type="";
		String secure_client="NO";
		String secure_public_key="";
		String proxy_port="0";
		String target_host="";
		int target_port=0;
		String proxy_charset="";
		int target_app_id=0;
		int target_env_id=0;
		String conf_driver="";
		String conf_connstr="";
		String conf_username="";
		String conf_password="";
		int max_pack_size=4096;
		boolean is_debug=false;
		String extra_args="";

		
		boolean is_params_ok=true;
		
		try{proxy_id=Integer.parseInt(genLib.getEnvValue("DM_PROXY_ID"));  } catch(Exception e) {is_params_ok=false; System.out.println("Proxy id is not valid.");}
		
		proxy_type=genLib.getEnvValue("DM_PROXY_TYPE").trim(); 
		
		if (proxy_type.length()==0 || "ORACLE_T2,MSSQL_T2,POSTGRESQL,MYSQL,MONGODB,HIVE,GENERIC".indexOf(proxy_type)==-1) {
			System.out.println("Proxy type ["+proxy_type+"] is invalid.");
			is_params_ok=false;
		}
		
		secure_client=genLib.nvl(genLib.getEnvValue("DM_SECURE_CLIENT"), "NO") ;  
		secure_public_key=genLib.getEnvValue("DM_SECURE_PUBLIC_KEY");  

		
		try{proxy_port=genLib.getEnvValue("DM_PROXY_PORT");  } catch(Exception e) {is_params_ok=false; System.out.println("Proxy port is not valid.");}
		
		target_host=genLib.getEnvValue("DM_PROXY_TARGET_HOST");  
		if (target_host.length()==0) {
			System.out.println("Proxy target host is empty.");
			is_params_ok=false;
		}

		try{target_port=Integer.parseInt(genLib.getEnvValue("DM_PROXY_TARGET_PORT"));  } catch(Exception e) {is_params_ok=false; System.out.println("Proxy target port is not valid.");}

		proxy_charset=genLib.getEnvValue("DM_PROXY_CHARSET");  
		if (proxy_charset.length()==0) {
			System.out.println("Charset is empty.");
			is_params_ok=false;
		}
		
		try {
			String test_str="test";
			test_str.getBytes(Charset.forName(proxy_charset));
		} catch(Exception e) {
			System.out.println("Charset ["+proxy_charset+"] is  invalid.");
			is_params_ok=false;
		}
		
		try{target_app_id=Integer.parseInt(genLib.getEnvValue("DM_PROXY_TARGET_APP_ID"));  } catch(Exception e) {is_params_ok=false; System.out.println("Proxy target application id is not valid.");}
		try{target_env_id=Integer.parseInt(genLib.getEnvValue("DM_PROXY_TARGET_ENV_ID"));  } catch(Exception e) {is_params_ok=false; System.out.println("Proxy target environment is not valid.");}

		try{max_pack_size=Integer.parseInt(genLib.getEnvValue("DM_MAX_PACKAGE_SIZE"));  } catch(Exception e) {max_pack_size=2048; System.out.println("MAX_PACKAGE_SIZE set to default 2048.");}

		conf_driver=genLib.getEnvValue("DM_PROXY_CONFIG_DB_DRIVER");
		conf_connstr=genLib.getEnvValue("DM_PROXY_CONFIG_DB_URL");
		conf_username=genLib.getEnvValue("DM_PROXY_CONFIG_DB_USERNAME");
		conf_password=genLib.getEnvValue("DM_PROXY_CONFIG_DB_PASSWORD");
		
		String debug_str="NO";
		try{debug_str=genLib.getEnvValue("DM_DEBUG");  } catch(Exception e) {debug_str="NO"; }
		if (debug_str.equals("YES")) is_debug=true;
		
		extra_args=genLib.getEnvValue("DM_EXTRA_ARGS");
		
		


		
		
		if (!is_params_ok) System.exit(0);
		
		System.out.println("----------------------------------------------");
		System.out.println("--- STARTING NEW DYNAMIC DATA MASKING PROXY --");
		System.out.println("----------------------------------------------");
		System.out.println("proxy_id.................................. : "+proxy_id);
		System.out.println("proxy_type................................ : "+proxy_type);
		System.out.println("secure_client............................. : "+secure_client);
		System.out.println("secure_public_key......................... : **************");
		System.out.println("proxy_ports............................... : "+proxy_port);
		System.out.println("target_host............................... : "+target_host);
		System.out.println("target_port............................... : "+target_port);
		System.out.println("proxy_charset............................. : "+proxy_charset);
		System.out.println("target_app_id............................. : "+target_app_id);
		System.out.println("target_env_id............................. : "+target_env_id);
		System.out.println("max_pack_size............................. : "+max_pack_size);
		System.out.println("conf_driver............................... : "+conf_driver);
		System.out.println("conf_connstr.............................. : "+conf_connstr);
		System.out.println("conf_username............................. : "+conf_username);
		System.out.println("conf_password............................. : "+"************");
		System.out.println("debug..................................... : "+is_debug);
		System.out.println("extra_args................................ : "+extra_args);
		System.out.println("----------------------------------------------");
		
		
		m.initNewProxy(
				proxy_id,
				proxy_type, 
				secure_client,
				secure_public_key,
				proxy_port, 
				target_host,
				target_port, 
				proxy_charset, 
				target_app_id,
				target_env_id,
				max_pack_size,
				conf_driver,
				conf_connstr,
				conf_username,
				conf_password,
				is_debug,
				extra_args
				);
		
		
		
	}

}
