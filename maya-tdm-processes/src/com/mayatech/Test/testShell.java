package com.mayatech.Test;

import java.util.ArrayList;

import com.mayatech.baseLibs.genLib;
import com.mayatech.baseLibs.shellLib;

public class testShell {

	public static void main(String[] args) {
		shellLib sh=new shellLib("cmd","d:\\temp");
		
		StringBuilder cmds=new StringBuilder();
		
		
		
		ArrayList<String[]> parameters=new ArrayList<String[]>();
		parameters.add(new String[]{"PARAMETER_1","*.*"});
		parameters.add(new String[]{"PING_HOST","hotmail.com"});
		
		cmds.append("ping ${PING_HOST}\n");
		cmds.append("@wait(10000,Average =)\n");
		cmds.append("dir\n");
		cmds.append("@wait(1000,bytes free)\n");
		cmds.append("cd logs\n");
		cmds.append("@wait(5000)\n");
		cmds.append("echo on\n");
		cmds.append("echo ping to ${PING_HOST} ...\n");
		cmds.append("echo selam\n");
		cmds.append("del ${PARAMETER_1}\n");
		cmds.append("@wait(1000,Are you sure)\n");
		cmds.append("Y\n");
		
		
		
		
		String cmd_list=genLib.replaceAllParams(cmds.toString(), parameters);
		
		
		StringBuilder logs=new StringBuilder();
		
		boolean is_success=sh.performDeployment(cmd_list, logs);
		
		System.out.println(logs.toString());
		System.out.println("is_success="+is_success);
		

	}

}
