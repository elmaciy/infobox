package com.mayatech.Test;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

public class testjavascriptengine {

	
	public static void main(String args[]) {
	    ScriptEngineManager manager = new ScriptEngineManager();
	    ScriptEngine engine = manager.getEngineByName("javascript");
	    try {
	      engine.put("name", "Selamlar.");
	      
	      engine.eval("var output = '';for (i = 0; i <= name.length; i++) {"
	          + "  output = name.charAt(i)+'-' + output" + "}");
	      String name = (String) engine.get("output");
	      System.out.println(name);
	    } catch (ScriptException e) {
	      System.err.println(e);
	    }
	    
	}
	
}
