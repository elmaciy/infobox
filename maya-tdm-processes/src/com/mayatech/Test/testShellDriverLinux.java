package com.mayatech.Test;

import java.util.ArrayList;

import com.mayatech.baseLibs.genLib;
import com.mayatech.baseLibs.shellLib;
import com.mayatech.buildDrivers.ShellDriver;

public class testShellDriverLinux {

	public static void main(String[] args) {

		ShellDriver drv=new ShellDriver();
		
		StringBuilder cmds=new StringBuilder();
		
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
		
		ArrayList<String[]> parameters=new ArrayList<String[]>();
		parameters.add(new String[]{"MAD_REQUEST_ITEM_DIRECTORY","d:\\temp"});
		parameters.add(new String[]{"MAD_SHELL_SHELL_START_CMD","cmd"});
		parameters.add(new String[]{"MAD_SHELL_CMD_LIST",cmds.toString()});
		
		parameters.add(new String[]{"PARAMETER_1","*.*"});
		parameters.add(new String[]{"PING_HOST","hotmail.com"});
		
		ArrayList<String[]> ret1=drv.build(parameters);
		
		String ret=ret1.get(0)[0];
		String logs=ret1.get(0)[1];
		
		System.err.println("Logs : "+logs);
		System.err.println("ret : "+ret);

	}

}
