package com.mayatech.licence;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.Console;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Calendar;
import java.util.Date;
import java.util.zip.DataFormatException;
import java.util.zip.Deflater;
import java.util.zip.Inflater;

public class generateLicence {
	
	String licence_hostname="UNKNOWN";
	String licence_serial="UNKNOWN";
	String licence_os="UNKNOWN";
	
	
	
	String licence_owner_company="UNKNOWN";
	String licence_owner_contact="UNKNOWN";
	String licence_owner_email_address="UNKNOWN";
	int licence_duration_int=365;
	int licence_worker_limit=10;
	int licence_master_limit=10;
	int licence_db_limit=3;
	
	
	
	//------------------------------------------------------------------
	public String nvl(String in, String out) {
		String r = "";
		try {
			r=in;
			if (r.equals("null")) r="";
		} catch (Exception e) {
			r = "";
		}

		if (r.length() == 0)
			r = out;

		return r;
	}
	
	//------------------------------------------------------------------
	public String encode(String a) {
		
		//byte[]   bytesEncoded = Base64.encodeBase64(a.getBytes());
		byte[]   bytesEncoded = Base64.getEncoder().encode(a.getBytes());

		return new String(bytesEncoded);
	}

	//------------------------------------------------------------------
	public String decode(String a) {
		//byte[] valueDecoded= Base64.decodeBase64(a);
		byte[] valueDecoded= Base64.getDecoder().decode(a);
		return new String(valueDecoded);
		
	}
		
	//------------------------------------------------------------------
	String getUserInput(String label, String default_val) {
		String ret1=default_val;
		System.out.print(label + " ["+default_val+"]"+ " :");
		Console co=System.console();
		try{
			String s=co.readLine(); 
			if (s.trim().length()>0) ret1=s;
			} catch(Exception e) {return default_val;}
		
		return ret1;
	}

	//----------------------------------------------------------------

	private void text2file(String text, String filepath) {
		PrintWriter out = null;

		try {
			out = new PrintWriter(filepath);
			out.println(text);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			out.close();
		}
	}
	
	
	//*************************************************
		public static byte[] compress(String data){
			byte[] input;
			try {
				input = data.getBytes();
			} catch (Exception e) {
				e.printStackTrace();
				return null;
			}
		    Deflater df = new Deflater();
		    df.setLevel(Deflater.BEST_COMPRESSION);
		    df.setInput(input);

		    ByteArrayOutputStream baos = new ByteArrayOutputStream(input.length);
		    df.finish();
		    byte[] buff = new byte[1024];
		    while (!df.finished()) {
		        int count = df.deflate(buff);
		        baos.write(buff, 0, count);
		    }
		    try {
				baos.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		    byte[] output = baos.toByteArray();

		    return output;
		}
		
		//******************************************************
		public static String uncompress(byte[] input)  {
	    Inflater ifl = new Inflater();
	    ifl.setInput(input);

	    ByteArrayOutputStream baos = new ByteArrayOutputStream(input.length);
	    byte[] buff = new byte[1024];
	    while (!ifl.finished()) {
	        int count;
			try {
				count = ifl.inflate(buff);
			} catch (DataFormatException e) {
				e.printStackTrace();
				return "ERROR";
			}
	        baos.write(buff, 0, count); 
	        try {baos.close();} catch (IOException e){}
	    }
	   
	    byte[] output = baos.toByteArray();

	    try {
			return new String(output,"UTF-8");
		} catch (Exception e) {
			return "ERROR";
		}
	    
	}
	//----------------------------------------------------------------
	boolean checkLicenceInfo() {
		
		String curr_dir=Paths.get(".").toAbsolutePath().normalize().toString();
		String default_licence_info_file=curr_dir+File.separator+"licence.info";
		
		String lincence_info_loc=getUserInput("Location for lincence.info", default_licence_info_file);

		try{
			File f = new File(lincence_info_loc);
			if (!f.exists()) {
				System.out.println("File not found.");
				return false;
			}
			
		} catch(Exception e) {
			return false;
		} 
		
		BufferedReader reader =null;
		try {
			reader = new BufferedReader(new InputStreamReader(new FileInputStream(lincence_info_loc), "UTF8"));
			
			
			int recno=0;
	        String         line = null;
	        String         ls = System.getProperty("line.separator");

	        while( ( line = reader.readLine() ) != null ) {
				if (line.trim().length()>0) {
					
					String decoded=decode(line);
					
					
					String[] lines=decoded.split("\n");
					for (int i=0;i<lines.length;i++) {
						String a_line=lines[i];

						if (a_line.indexOf("=")>-1) {
							String key=a_line.split("=")[0];
							String val=a_line.split("=")[1];
							System.out.println(key + " : "+val);
							if (key.equals("HOSTNAME")) licence_hostname=nvl(val,"UNKNOWN");
							if (key.equals("SERIAL")) licence_serial=nvl(val,"UNKNOWN");
							if (key.equals("OS")) licence_os=nvl(val,"UNKNOWN");
							
						}
					}
					
					break;
					
					
				}
	        }
			
		} catch(Exception e) {
			e.printStackTrace();
			return false;
		} finally {
			try {reader.close();} catch (IOException e) {e.printStackTrace();}
		}
		 
		
		//--------------------------------------
		licence_owner_company=getUserInput("Licence Owner Company", "UNKNOWN");
		licence_owner_contact=getUserInput("Licence Owner Contact Name", "UNKNOWN");
		licence_owner_email_address=getUserInput("Licence Owner Contact Email Address", "UNKNOWN");
		
		String val_txt="";
		int val_int=0;
		boolean is_input_ok=false;
		
		while(!is_input_ok) {
			val_txt=getUserInput("Licence Duration as Calendar Day", "365");
			try {val_int=Integer.parseInt(val_txt);is_input_ok=true;} catch(Exception e) {is_input_ok=false;}
			
		}
		licence_duration_int=val_int;
		
		is_input_ok=false;
		while(!is_input_ok) {
			val_txt=getUserInput("Licence worker limit", "10");
			try {val_int=Integer.parseInt(val_txt);is_input_ok=true;} catch(Exception e) {is_input_ok=false;}
			
		}
		licence_worker_limit=val_int;
		
		is_input_ok=false;
		while(!is_input_ok) {
			val_txt=getUserInput("Licence master limit", "10");
			try {val_int=Integer.parseInt(val_txt);is_input_ok=true;} catch(Exception e) {is_input_ok=false;}
			
		}
		licence_master_limit=val_int;
		
		
		is_input_ok=false;
		while(!is_input_ok) {
			val_txt=getUserInput("Licence database limit", "3");
			try {val_int=Integer.parseInt(val_txt);is_input_ok=true;} catch(Exception e) {is_input_ok=false;}
			
		}
		licence_db_limit=val_int;
		
		return true;
		
	}
	
	//---------------------------------------------------------
	void makeLicenceFile() {

		
		
		String extra_info="\n"+
				"OWNER_COMPANY="+licence_owner_company+"\n"+
				"OWNER_CONTACT="+licence_owner_contact+"\n"+
				"OWNER_EMAIL="+licence_owner_email_address+"\n"+
				"DURATION="+licence_duration_int+"\n"+
				"WORKER="+licence_worker_limit+"\n"+
				"MASTER="+licence_master_limit+"\n"+
				"DB="+licence_db_limit+"\n";
		
		
		
		String licence_string=""+
			"HOSTNAME="+licence_hostname+"\n"+
			"SERIAL="+licence_serial+"\n"+
			"OS="+licence_os+"\n"+
			extra_info;
		
		System.out.println(licence_string);
		
		String[] lines=licence_string.split("\n");
		String end_date="";
		
		//Add Checksum
		long checksum=0;
		for (int i=0;i<lines.length;i++) {
			String a_line=lines[i];
			if (a_line.contains("=")) {
				String key=a_line.split("=")[0];
				String val=a_line.split("=")[1];
				
				checksum+=nvl(val,"0").hashCode();
				
				if (key.equals("DURATION")) {
					Date now=new Date();
					Calendar c = Calendar.getInstance();
					c.add(Calendar.DATE, Integer.parseInt(val));
					Date d=c.getTime();
					SimpleDateFormat df=new SimpleDateFormat("dd/MM/yyyy");
					end_date=df.format(d);
					checksum+=end_date.hashCode();
					
				}
			}
		}
		
		licence_string=licence_string+"\nCHECKSUM="+checksum;
		licence_string=licence_string+"\nEND_DATE="+end_date;
		
		System.out.println(licence_string);
		
		byte[] compressed=compress(licence_string);
		StringBuilder sbyte=new StringBuilder();
		for(byte b: compressed) 
			sbyte.append(String.format("%02x", b&0xff));
		String curr_dir=Paths.get(".").toAbsolutePath().normalize().toString();

		String generated_file="licence.lic";
		String generated_file_path=curr_dir+File.separator + generated_file;
		text2file(sbyte.toString(), generated_file_path);
		
		System.out.println("Licence file is generated successfully. ["+generated_file_path+"]");
	}
	
	
	public static void main(String[] args) {
		System.out.println("****************************************");
		System.out.println("***  WELCOME MAYA LICENCE GENERATOR  ***");
		System.out.println("****************************************");
		
		
		generateLicence g=new generateLicence();
		
		boolean is_check_info_ok=g.checkLicenceInfo();
		
		if (!is_check_info_ok) {
			System.err.println("Licence info file not found or invalid.");
			return;
		}
		
		g.makeLicenceFile();
		
		
		
		

	}

}
