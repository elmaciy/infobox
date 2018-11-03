package com.mayatech.Test;

import com.mayatech.tdm.metadataCopyLib;

public class copyMetadataTest {

	public static void main(String[] args) {

		String jdbc_driver="oracle.jdbc.driver.OracleDriver";
		String jdbc_url="jdbc:oracle:thin:@localhost:1521:orcl";
		String jdbc_username="system";
		String jdbc_password="Han#1323";
		
		
		String jdbc_target_driver="oracle.jdbc.driver.OracleDriver";
		String jdbc_target_url="jdbc:oracle:thin:@localhost:1521:orcl";
		String jdbc_target_username="system";
		String jdbc_target_password="Han#1323";
		
		String source_schemas="HR,OE";
		String target_schemeas="HR,OE"; 
		
		//String source_schemas="";
		//String target_schemeas=""; 
		
		metadataCopyLib mdLib=new metadataCopyLib(
				jdbc_driver,jdbc_url,jdbc_username,jdbc_password,
				jdbc_target_driver,jdbc_target_url,jdbc_target_username,jdbc_target_password
				);
		
		
		
		mdLib.setSchemas(source_schemas, target_schemeas);


		mdLib.copyMetadata();
		
		//mdLib.synchSequences();
		

	}

}
