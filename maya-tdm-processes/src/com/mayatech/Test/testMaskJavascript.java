package com.mayatech.Test;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

import com.mayatech.tdm.maskLib;

public class testMaskJavascript {

	public static void main(String[] args) {
		maskLib m=new maskLib(false);
		
		
		ScriptEngineManager factory=null;
		ScriptEngine engine=null;
		
		if (factory==null) 	{
			factory = new ScriptEngineManager();
			engine = factory.getEngineByName("JavaScript");
		}
		
		String p_js_code="";
		String original_value="OKTAY AKTAÞ";
		
		String ret=m.maskJavascript(engine, 0, 1, original_value, null, p_js_code, null, "-", null);
		
		System.out.println("ret="+ret);
		
		
	}

}
