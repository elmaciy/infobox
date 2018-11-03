package com.mayatech.Test;

import java.util.ArrayList;

import com.mayatech.buildDrivers.ShellDriver;

public class testShellDriver {

	public static void main(String[] args) {

		ShellDriver drv=new ShellDriver();
		
		StringBuilder cmds=new StringBuilder();
		
		cmds.append("dir\n");
		cmds.append("@wait(1000)\n");
		cmds.append("cd /data/mad/createTag\n");
		cmds.append("@wait(5000)\n");
		cmds.append("rm deneme.txt\n");
		cmds.append("ls -ltr > deneme.txt\n");
		cmds.append("ant createTag\n");
		
		ArrayList<String[]> parameters=new ArrayList<String[]>();
		parameters.add(new String[]{"MAD_REQUEST_ITEM_DIRECTORY",""});
		parameters.add(new String[]{"MAD_SHELL_SHELL_START_CMD","bash"});
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
