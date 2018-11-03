package com.mayatech.dm.protocolTds;


public class tdsMicrosoftSqlRPCParam {
	
	tdsMicrosoftSqlPackage TDSPackage=null;
	
	boolean isOutput=false;
	int tdsType=0;
	
	boolean isStatmentParameter=false;
	
	String parameter_name=null;
	public String parametervalue_as_string=null;
	byte[]  parametervalue_as_bytes=null;
	byte[] collationBytes=new byte[5];

	
	void print(int param_no) {
		
		if (!TDSPackage.is_debug)  return ;
		
		TDSPackage.mydebug("## ___________________________________________________________________ : "+param_no);
		TDSPackage.mydebug("parameter name         : "+parameter_name);
		TDSPackage.mydebug("dataType               : "+tdsType);
		TDSPackage.mydebug("isStatmentParameter    : "+isStatmentParameter);
		TDSPackage.mydebug("parametervalue     : ");
		if (parametervalue_as_string!=null) TDSPackage.mydebug(parametervalue_as_string);
		if (parametervalue_as_bytes!=null) 	TDSPackage.printByteArray(parametervalue_as_bytes, parametervalue_as_bytes.length);
		TDSPackage.mydebug("collationBytes     : "); 
		if (collationBytes!=null) 	
			TDSPackage.printByteArray(collationBytes, collationBytes.length);
		else 
			TDSPackage.mydebug("null");
	}
	
}
