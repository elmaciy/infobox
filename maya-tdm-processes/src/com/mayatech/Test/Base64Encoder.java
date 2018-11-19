package com.mayatech.Test;

import java.io.File;
import java.nio.file.Files;
import java.util.Base64;

public class Base64Encoder {

	public static void main(String[] args) {
		String filePath="D:\\selenium\\libs\\mayatdm.jar";
		String base64String="";
		try {
			File file=new File(filePath);
			byte[] fileContent = Files.readAllBytes(file.toPath());
			byte[] encoded=Base64.getEncoder().encode(fileContent);
			base64String=new String(encoded);
			System.out.println(base64String);
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

}
