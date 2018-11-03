package tdm.deployment;

import java.sql.Connection;

public class tester {
	public static void main(String[] args) {
		oracleConverter oc=new oracleConverter();
		String table_script="";
		
		commonLib cl=new commonLib();
		
		Connection connApp=cl.getconn("oracle.jdbc.driver.OracleDriver", "jdbc:oracle:thin:@localhost:1521:orcl", "system", "Han#1323", "select 1 from dual");
		
		String object_owner="SH";
		String object_name="SALES";
		
		table_script=oc.getOracleTableStructure(connApp, object_owner, object_name);
		
		System.out.println(table_script);
	}
}
