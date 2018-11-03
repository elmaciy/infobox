package com.infobox.client;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;

public class proxyLib {
	static final String cipher_method="AES/CBC/PKCS5Padding";
	//static final String cipher_method="AES/ECB/PKCS5Padding";
	
	static final String AES="AES";
	static byte[] iv = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static final IvParameterSpec ivspec = new IvParameterSpec(iv);
	static final byte[] key="920A!Dsl091ad@kl".getBytes();


	
	public static final byte[] ecryptByteArray(Cipher cipher, byte[] buf, int len) {

		try {
			byte[] tmp=new byte[len];
			System.arraycopy(buf, 0, tmp, 0, len);
			return cipher.doFinal(tmp);
			
		} catch(Exception e) {
			e.printStackTrace();
			return buf;
		}
		
	}


	
	//-----------------------------------------------------------------------
	public static final byte[] decryptByteArray(Cipher cipher,  byte[] buf) {
		try {
			return cipher.doFinal(buf);
		} catch(Exception e) {
			e.printStackTrace();
			return buf;
		}
	}
}
