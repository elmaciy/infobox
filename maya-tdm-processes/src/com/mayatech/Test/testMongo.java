package com.mayatech.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.bson.Document;
import org.bson.types.ObjectId;

import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.MongoCredential;
import com.mongodb.ServerAddress;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoDatabase;
import com.mongodb.util.JSON;



public class testMongo {

	MongoClient mongo =null;
	
	
	ArrayList<String> field_names = new ArrayList<String>();
	ArrayList<String> field_PKs = new ArrayList<String>();
	ArrayList<String> field_mask_rules = new ArrayList<String>();
	ArrayList<String> field_mask_profiles=new ArrayList<String>();
	
	
	//-------------------------------------------
	testMongo(String url) {
		mongo=getMongoClient("", 0, "", "", "", url);
		if (mongo==null) {
			System.out.println("Mongo is not connected to ["+url+"]");
		} else {
			System.out.println("Mongo is connected.");
		}
	}
		
		
	//-------------------------------------------
	testMongo(String hostname, int port, String username, String password, String dbname) {
		mongo=getMongoClient(hostname, port, username, password, dbname,"");
		if (mongo==null) {
			System.out.println("Mongo is not connected to ["+hostname+":"+port+"]");
		} else {
			System.out.println("Mongo is connected.");
		}
	}
	
	//-------------------------------------------
	MongoClient getMongoClient(String hostname, int port, String username, String password, String dbname, String url) {
		System.out.println("Getting mongo client for ["+hostname+":"+port+"]...");
		
		MongoClient mongoClient = null;
		
		try {
			if (username.length()==0) {
				if (url.length()==0)
					mongoClient= new MongoClient(hostname, port);
				else {
					MongoClientURI muri=new MongoClientURI(url);
					mongoClient = new MongoClient(muri);
				}
			}
			else {
				MongoCredential credential = MongoCredential.createCredential(username, dbname, password.toCharArray());
				ServerAddress srv=new ServerAddress(hostname, port);
				mongoClient = new MongoClient(new ServerAddress(), Arrays.asList(credential));
			}
			
		} catch(Exception e) {
			e.printStackTrace();
			return null;
		}
		
		List<MongoCredential> crelist=mongoClient.getCredentialsList();
		for (int i=0;i<crelist.size();i++) {
			MongoCredential acre=crelist.get(i);
			System.out.println("Mechanism : " + acre.getMechanism());
		}
		
		if (dbname.length()>0)
			useDB(dbname);
		
		return mongoClient;
	}
	
	//-------------------------------------------------------------------
	ArrayList<String> getDBList() {
		ArrayList<String> ret1=new ArrayList<String>();
		try {
			
			for (String dbname : mongo.listDatabaseNames()) {
				ret1.add(dbname);
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		
		return ret1;
	}
	
	String using_db="";
	MongoDatabase mongodb=null;
	
	//-------------------------------------------------------------------
	void useDB(String dbname) {
		ArrayList<String> dblist=getDBList();
		if (dblist.indexOf(dbname)==-1) {
			System.out.println("DB is not available to use: "+dbname);
			return;
			}
		
		
		mongodb=mongo.getDatabase(dbname);
		
		
		using_db=dbname;
	}
	
	
	//-------------------------------------------------------------------
		ArrayList<String> getCollectionList() {
			ArrayList<String> ret1=new ArrayList<String>();
			try {
				
				for (String collection : mongodb.listCollectionNames()) {
					ret1.add(collection);
				}
				
				

			} catch(Exception e) {
				e.printStackTrace();
			}
			
			
			return ret1;
		}
	//-------------------------------------------------------------------
	ArrayList<Document> getDocuments(String dbname, String collection, String filter, int limit) {
		if (!dbname.equals(this.using_db))  useDB(dbname);
		
		ArrayList<Document> ret1=new ArrayList<Document>();
		if (mongodb==null) return ret1;
		
		
		FindIterable<Document> iterable = mongodb.getCollection(collection).find();
		
		int i=0;
		for (Document doc:iterable) {
			ret1.add(doc);
			
			i++;
			if (limit>0 && i==limit) break;
		}
		
	
		return ret1;
	}
	//-------------------------------------------------------------------
	void closeMongo() {
		try {
			mongo.close();
			System.out.println("Mongo is closed.");
		} catch(Exception e) {
			
		}
	}
	
	//----------------------------------------
	boolean checkDocFieldDuplicate(
			ArrayList<String[]> arr, String sub_field_name, String sub_field_level, String sub_parent_field) {
		
		for (int a=0;a<arr.size();a++) {
			String main_field_name=arr.get(a)[0];
			String main_field_level=arr.get(a)[1];
			String main_parent_field=arr.get(a)[2];
			
			if (
					main_field_name.equals(sub_field_name) 
					&& main_field_level.equals(sub_field_level)
					&& main_parent_field.equals(sub_parent_field)) {
				return true;
				
			}
		}
		
		return false;
	}
	
	
	
	
	//----------------------------------------
	ArrayList<String[]> getDocumentStructure(ArrayList<String[]> curFields, String doc, int level, String parent) {
		ArrayList<String[]> ret1=curFields;
		if (ret1==null) ret1=new ArrayList<String[]>();
		
			
		DBObject dbObject = (DBObject) JSON.parse(doc);

		ArrayList<String> checkArr=new ArrayList<String>();
		
		Map map=dbObject.toMap();
		
		for (Object obj:  map.keySet()) {
			String key=obj.toString();
			String val=map.get(key).toString();
			
			
			boolean is_array_num=false;
			try {
				Integer.parseInt(key);  
				is_array_num=true;
				key="(\\d+)";
				} catch(Exception e) {is_array_num=false;}
			
			String full_key_path=key;
			if (parent.length()>0) full_key_path=parent+"."+full_key_path;
			
			
			int chid=checkArr.indexOf(key);
			if(chid>-1) continue;
			checkArr.add(key);
			
			
			char first_char='x';
			try{first_char=val.trim().charAt(0);} catch(Exception e) {}
			
			if (first_char=='{' || first_char=='[')  {
				if(!checkDocFieldDuplicate(ret1, key, ""+level, parent))
					ret1.add(new String[]{full_key_path,""+level,parent,"NODE"});
				
				ArrayList<String[]> subFields=getDocumentStructure(null, val, level+1, full_key_path);
				
				for (int s=0;s<subFields.size();s++) {
					String sub_field_name=subFields.get(s)[0];
					String sub_field_level=subFields.get(s)[1];
					String sub_parent_field=subFields.get(s)[2];
					
					boolean is_exists=checkDocFieldDuplicate(ret1, sub_field_name, sub_field_level, sub_parent_field);

					if (is_exists) continue;
					
					ret1.add(subFields.get(s));
				}
				
			}
			else {
				
				boolean is_exists=checkDocFieldDuplicate(ret1, key, ""+level, parent);
				if (!is_exists) {
					if (key.equals("_id"))
						ret1.add(new String[]{full_key_path,""+level,parent,"KEY"});
					else 
						ret1.add(new String[]{full_key_path,""+level,parent,"ENTITY"});
				}
				
			}
			
		}

		
		//--------------------------------------------
		if (level==1) {
			
			for (int i=0;i<ret1.size();i++) {
				String key1=ret1.get(i)[0];
				for (int j=i+1;j<ret1.size();j++) {
					String key2=ret1.get(j)[0];
					if (key1.compareTo(key2)>0) {
						String[] tmp=ret1.get(i);
						ret1.set(i, ret1.get(j));
						ret1.set(j, tmp);
					}
				}
			} // for i
			
			//set Field Types
			for (int i=0;i<ret1.size();i++) {
				
			}

		}
			
		return ret1;
	}
	
	//---------------------------------------

	String getMONGODocumentById(String db_name, String collection, String id) {
		if (id.length()==0) return "";
		
		try {
			MongoDatabase mdb=mongo.getDatabase(db_name);
			BasicDBObject query = new BasicDBObject();
			query.put("_id", new ObjectId(id));
			FindIterable<Document> iterable = mdb.getCollection(collection).find(query);
			for (Document doc:iterable) 
			 return doc.toJson();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		
		return "";
	}
	
	
	//---------------------------------------
	DBObject maskJsonDocument(String docstr, String parent) {
		DBObject doc = (DBObject) JSON.parse(docstr);
		
		Map map=doc.toMap();
		char first_char='x';

		StringBuilder key=new StringBuilder();
		StringBuilder val=new StringBuilder();
		
		StringBuilder matchkeyname=new StringBuilder();
		
		for (Object obj:  map.keySet()) {
			key.setLength(0);			
			val.setLength(0);
			
			key.append(obj.toString());
			val.append(map.get(key.toString()).toString());
			
			if (val.length()==0) continue;
			
			matchkeyname.setLength(0);
			if (parent.length()>0) matchkeyname.append(parent+".");
			matchkeyname.append(key);
			
			
			
			try{first_char=val.toString().trim().charAt(0);} catch(Exception e) {first_char='x';}
			
			if (first_char=='{' || first_char=='[')  
				map.put(obj, maskJsonDocument(val.toString(),matchkeyname.toString()));
			
				
						
			for (int p=0;p<field_names.size();p++) {
				
				if (field_mask_rules.get(p).equals("NONE")) continue;
				
				
				
				Pattern r = Pattern.compile(field_names.get(p));
				Matcher m = r.matcher(matchkeyname.toString());
				
				if (m.find()) {
					map.put(obj, "Masked " +val.toString());
					break;
				} 
			}
			
		}
		
		doc.putAll(map);
		
		return doc;
		
	}
	
	//--------------------------------------
	ArrayList<String[]> getJsonKeyValue(String json,String parent) {

		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		try {
			
			DBObject doc = (DBObject) JSON.parse(json);
			
			Map map=doc.toMap();
			char first_char='x';
			
			StringBuilder key=new StringBuilder();
			StringBuilder val=new StringBuilder();
			
			StringBuilder matchkeyname=new StringBuilder();
			
			for (Object obj:  map.keySet()) {
				key.setLength(0);			
				val.setLength(0);
				
				key.append(obj.toString());
				val.append(map.get(key.toString()).toString());
				
				matchkeyname.setLength(0);
				if (parent.length()>0) matchkeyname.append(parent+".");
				matchkeyname.append(key);
				
				try{first_char=val.toString().trim().charAt(0);} catch(Exception e) {first_char='x';}
				
				if (first_char=='{' || first_char=='[') {
					ret1.addAll(getJsonKeyValue(val.toString(), matchkeyname.toString()));
				} else {
					ret1.add(new String[]{matchkeyname.toString(),val.toString()});
				}
				
				
				
				
			}
			
			
		} catch(Exception e) {
			e.printStackTrace();
			return ret1;
			
		}
		
		return ret1;
	}
	
	//---------------------------------------
	public static void main(String[] args) {
		
		testMongo t=new testMongo("localhost",27017,"","","");
		t.useDB("test");
		ArrayList<String> collections=t.getCollectionList();
		for (int i=0;i<collections.size();i++) {
			String acoll=collections.get(i);
		}
		
		ArrayList<Document> docs=t.getDocuments("test", "restaurants", "", 10);
		
		
		ArrayList<String[]> arr=new ArrayList<String[]>();
		
		for (int i=0;i<docs.size();i++) 
			arr=t.getDocumentStructure(arr, docs.get(i).toJson(),1, "");
			
		
		
		for (int a=0;a<arr.size();a++) {
			
			String field_name=arr.get(a)[0];
			String field_level=arr.get(a)[1];
			String parent_field=arr.get(a)[2];
			String field_type=arr.get(a)[3];
			
			
			System.out.println(field_name +" : " + field_type);
		}
		
		
		//------------------------------------------------------------------
		String db_name="test";
		String collection_name="restaurants";
		MongoClient mongoClient=t.getMongoClient("localhost", 27017, "", "", db_name, "");
		MongoDatabase mdb=mongoClient.getDatabase(db_name);
		String id="5597b4a209f9ebd5633fd7bf";
		
		String jsonstr=t.getMONGODocumentById("test","restaurants",id);
		
		System.out.println("Document  : \n" + jsonstr);
		
		t.field_names.add("_id");
		t.field_names.add("cuisine");
		t.field_names.add("name");
		t.field_names.add("grades.(\\d+).score");
		
		t.field_PKs.add("YES");
		t.field_PKs.add("NO");
		t.field_PKs.add("NO");
		t.field_PKs.add("NO");
		
		t.field_mask_rules.add("NONE");
		t.field_mask_rules.add("HASHLIST");
		t.field_mask_rules.add("SCRAMBLE_INNER");
		t.field_mask_rules.add("RANDOM_NUMBER");
		
		t.field_mask_profiles.add("0");
		t.field_mask_profiles.add("5");
		t.field_mask_profiles.add("4");
		t.field_mask_profiles.add("8");
		
		long start_ts=System.currentTimeMillis();
		
		
		String maskedJson=t.maskJsonDocument(jsonstr,"").toString();
		
		System.out.println("Duration : " + (System.currentTimeMillis()-start_ts));
		System.out.println("MASKED : " + maskedJson);
		
		//----------------------------------------------------------------------
		
		String after_jsonstr=t.getMONGODocumentById(db_name,collection_name,id);
		System.out.println("Document after  : \n" + after_jsonstr);
		
		ArrayList<String[]> keyvalArr=t.getJsonKeyValue(after_jsonstr,"");
		
		//"address.coord.(\\d+)"
		for (int i=0;i<keyvalArr.size();i++) {
			String key=keyvalArr.get(i)[0];
			String val=keyvalArr.get(i)[1];
			
			System.out.println(key+"="+val);
		}
		
		
		t.closeMongo(); 
	}
}
