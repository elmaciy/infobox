package com.mayatech.Test;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.util.Date;

import org.bson.BasicBSONEncoder;

import com.mayatech.dm.ddmLib;
import com.mongodb.BasicDBObject;

public class testBson {
	
	public static void main(String[] args) {
		BasicDBObject obj = new BasicDBObject();
		
		obj.put("name", "Matt");
		obj.put("date", new Date());
		
		
		BasicDBObject subobj = new BasicDBObject();
		
		subobj.put("val1", "aaaaaa");
		subobj.put("val2", "bbbbb");
		
		obj.put("subobj", subobj);
		
		String bsonString = obj.toString();
		
		
		System.out.println(bsonString);
		
		
		
		
		BasicBSONEncoder encoder=new BasicBSONEncoder();
		byte[] encoded=encoder.encode(obj);
		
		ddmLib.printByteArray(encoded, encoded.length);
		
	}
	
}
