package com.mayatech.Test;

import java.util.Scanner;

public class getSerialWindows {

	public static void main(String[] args) {
		
		boolean is_windows=true;
		
		String OS = System.getProperty("os.name").toLowerCase();
		
		if (OS.indexOf("win")==-1)  is_windows=false;
		
		String serial ="unknownSerialID";
		
		if (is_windows)
			try
			{
			    Process process = Runtime.getRuntime().exec(new String[]
			    {
			    "wmic", "bios", "get", "serialnumber"
			    });
			    process.getOutputStream().close();
			    Scanner sc = new Scanner(process.getInputStream());
			    String property = sc.next();
			    serial = sc.next();
			} catch(Exception e)
			{
			    e.printStackTrace();
			}
		else
			try
			{
			    Process process = Runtime.getRuntime().exec(new String[]
			    {
			    "uname", "-a"
			    });
			    process.getOutputStream().close();
			    Scanner sc = new Scanner(process.getInputStream());
			    serial = sc.next();
			} catch(Exception e)
			{
			    e.printStackTrace();
			}
	    System.out.println("Serial : " + serial);

	}
	
	
}
