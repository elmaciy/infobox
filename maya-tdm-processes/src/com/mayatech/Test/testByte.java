package com.mayatech.Test;

import java.nio.ByteOrder;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

import com.mayatech.dm.ddmLib;

public class testByte {

	
	
	public static void main(String[] args) {
		
		int x=152;
		byte[] res=ddmLib.convertInteger2ByteArray4Bytes(x, ByteOrder.LITTLE_ENDIAN);
		System.out.println(""+(System.currentTimeMillis() % 1000000000) );

		
		

	}

}
