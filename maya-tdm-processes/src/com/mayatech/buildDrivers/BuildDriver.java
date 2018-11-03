package com.mayatech.buildDrivers;

import java.lang.reflect.Method;
import java.util.ArrayList;

public class BuildDriver {
	
	//**************************************************************
	public ArrayList<String[]> build(
			String className,
			ArrayList<String[]> parameters
			) {
	
		Class BuilderClass=null;
		Object  Builder=null;
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		try { BuilderClass=Class.forName(className); } catch (ClassNotFoundException e) { 
			ret1.add(new String[]{"false",e.getMessage()});
			return ret1;
			}
		
		try {
			Builder=BuilderClass.newInstance();
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("Exception@initialize : Class instance cannot be created : " + className);
			ret1.add(new String[]{"false","Exception@initialize : Class instance cannot be created : " + className});
			return ret1;
		}
		
		Method method=null;
		
		try {
			Method[] methods=Builder.getClass().getMethods();
			
			for (int i=0;i<methods.length;i++) {
				Method a_method=methods[i];
				if (a_method.getName().equals("build")) {
					method=a_method;
					break;
				}
			}
		} catch(Exception e) { }
		
		
		if (method==null) {
			System.out.println("No Such Method Found");
			ret1.add(new String[]{"false","No Such Method Found : ("+method+")" });
			return ret1;
		}
		
		
		try {
			System.out.println("Calling Driver : "+className);
			ret1 = (ArrayList<String[]>) method.invoke(Builder, parameters);
			return ret1;
		} catch (Exception e) {
			e.printStackTrace(); 
			ret1.add(new String[]{"false","Exception@method.invoke ("+method+") :"+e.getMessage() });
			return ret1;
			}
		
		
		
	}
	
}
