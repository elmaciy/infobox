package com.mayatech.baseLibs;
 
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.Map;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.DataFormatException;
import java.util.zip.Deflater;
import java.util.zip.Inflater;



public final class genLib {
	
	static public final String DEFAULT_DATE_FORMAT="dd/MM/yyyy HH:mm:ss";
	
	public static final String MINUS="-";
	
	
	static final String AB = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	static Random rnd = new Random();
	
	public static final String DB_TYPE_MYSQL="MYSQL";
	public static final String DB_TYPE_ORACLE="ORACLE";
	public static final String DB_TYPE_DB2="DB2";
	public static final String DB_TYPE_MSSQL="MSSQL";
	public static final String DB_TYPE_SYBASE="SYBASE";
	public static final String DB_TYPE_JBASE="JBASE";
	public static final String DB_TYPE_POSTGRESQL="POSTGRESQL";
				
	
	//--------------------------------------------
	
	public static byte[] uncompress(byte[] input)  {
	    
		if (input==null) return null;
			
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
				return null;
			}
	        baos.write(buff, 0, count); 
	       
	    }
	   
	    byte[] output = baos.toByteArray();
	    try {baos.close();} catch (IOException e){}
	    
	    return output;
	    
	    
	}
	
	
	
	//--------------------------------------------
	public static byte[] compress(byte[] input){
		
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
	
	//--------------------------------------------
	public static byte[] arrayListToByte( ArrayList<String[]> in) {
		byte[] ret1=null;
		ObjectOutputStream out =null;
		try {
			ByteArrayOutputStream bos = new ByteArrayOutputStream() ;
			out =new ObjectOutputStream(bos) ;
			out.writeObject(in);
			out.close();
			ret1= bos.toByteArray();
		} catch(IOException e) {
			e.printStackTrace();
		} finally {
			try{out.close();} catch(Exception e) {}
		}
		
		return ret1;
	}
	
	//--------------------------------------------
	public static ArrayList<String[]> byteArrToArrayList(byte[] in) {
		ArrayList<String[]> ret1=null;
		ObjectInputStream ois =null;
		
		if (in==null) return null;
		try { 
			ByteArrayInputStream bis=new ByteArrayInputStream(in);
			ois = new ObjectInputStream(bis);
			
			ret1=(ArrayList<String[]>) ois.readObject();
			ois.close();
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {ois.close();} catch (IOException e) {e.printStackTrace();}
		}
		
		return ret1;
	}
	//--------------------------------------------
	public static final String randomString( int len ) 
	{
	   StringBuilder sb = new StringBuilder( len );
	   for( int i = 0; i < len; i++ ) 
	      sb.append( AB.charAt( rnd.nextInt(AB.length()) ) );
	   return sb.toString();
	}
	//----------------------------------------------
	public static final String getDelimiter() {
		return "::";
	}
	
	// ----------------------------------------------
	public static final String getEnvValue(String key1) {
        String ret1 = "";

        Map<String, String> env = System.getenv();

        for (String envName : env.keySet()) 
            if (envName.equals(key1)) 
                ret1 = env.get(envName);
        
        ret1=ret1.replaceAll("\"", "");
        
        
        return ret1;
    }
	
	// ----------------------------------------------
	public static final void printEnvValues() {

        Map<String, String> env = System.getenv();

        for (String envName : env.keySet()) 
                System.out.println(envName+"="+env.get(envName));
        
        
    }
	
	// ----------------------------------------------
	public static final String[] getAllEnvValues() {

        Map<String, String> env = System.getenv();
        
        String[] ret1=new String[env.size()];
        int i=0;
        for (String envName : env.keySet()) {
        	ret1[i]=envName+"="+env.get(envName);
        	i++;
        }
                
        
        return ret1;
        
    }

	


	//***************************************************
	public static final String getDelimitedParamVal(String param_in, String param_name) {
		String ret1="";
		boolean found=false;
		
		String delimiter=getDelimiter();
		
		String[] params=param_in.split("\\|\\|");
		String par_name="";
		String par_val="";
		

		for (int i=0;i<params.length;i++) {
			par_name="";
			par_val="";
			String a_param=params[i];
			
			if (a_param.indexOf(delimiter)>-1) {
				
				try {par_name=a_param.split(delimiter)[0];} catch(Exception e) {par_name="";}
				try {par_val=a_param.split(delimiter)[1];} catch(Exception e) {par_val="";}
				
				
				if (par_name.equals(param_name)) {
					ret1=par_val;
					found=true;
				}
			}
			
			
		}
		
		if (!found) ret1="!!NOT/FOUND!!";
		
		return ret1;
	}
	
	//----------------------------------------------------------------------
	public static String nvl(String in, String out) {
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
		
	//----------------------------------------------------------------------
	public static final void printDelimitedParameters(String param_in) {
		
		System.out.println(" --------- CURRENT PARAMETER LIST  ------------ ");
		
		String delimiter=getDelimiter();
		
		String[] params=param_in.split("\\|\\|");
		String par_name="";
		String par_val="";
		
		for (int i=0;i<params.length;i++) {
			String a_param=params[i];
			
			if (a_param.indexOf(delimiter)>-1) {
				try {
					par_name=a_param.split(delimiter)[0];
					par_val=a_param.split(delimiter)[1];
				} catch(Exception e) {
					par_name="";
					par_val="!!N/F!!";
				}

				if (par_name.length()>0) System.out.println(par_name+" =>   "+par_val);
				
				}
			}
			
		
	}
	
	//*****************************************************************************************
	public static final String getParamByName(ArrayList<String[]> parameters, String parameter_name) {
		
		for (int i=0;i<parameters.size();i++) {
			if (parameters.get(i)[0].equals(parameter_name)) {
				return parameters.get(i)[1];
			}
		}
		
		return "";
	}
	
	//*****************************************************************************************
	public static final String printParameters(ArrayList<String[]> parameters) {
		
		for (int i=0;i<parameters.size();i++) {
			String param_name=parameters.get(i)[0];
			String param_val=parameters.get(i)[1];
			if (param_name.toUpperCase().contains("PASSWORD")) param_val="**********";
			
			System.out.println(param_name+"=\t"+param_val);
		}
		
		return "";
	}
	
	//*****************************************************************************************
	public static final String printParameters(ArrayList<String[]> parameters, StringBuilder outsb) {
		
		for (int i=0;i<parameters.size();i++) {
			String param_name=parameters.get(i)[0];
			String param_val=parameters.get(i)[1];
			if (param_name.toUpperCase().contains("PASSWORD")) param_val="**********";
			outsb.append(param_name+"=\t"+param_val+"\n");
			//System.out.println(param_name+"=\t"+param_val);
		}
		
		return "";
	}

	//*****************************************************************************************

	public static final String replaceAllParams(String str, ArrayList<String[]> params) {
		StringBuilder ret1=new StringBuilder();
		ret1.append(str);
		if (params==null) return str;
		for (int i=0;i<params.size();i++) {
			String param_name="${"+params.get(i)[0]+"}";
			String param_val=params.get(i)[1];
			
			while (ret1.indexOf(param_name)>-1) {
				int loc=ret1.indexOf(param_name);
				int len=param_name.length();
				
				ret1.delete(loc, loc+len);
				ret1.insert(loc, param_val);
			}
		}
		
		
		return ret1.toString();
	}
	//***********************************
	public static final String replaceparams(String str, String param_in) {
		
		if (str==null) return "";
		
		String ret1=str;
		

		String delimiter=getDelimiter();
		
		String[] params=param_in.split("\\|\\|");
		String par_name="";
		String par_val="";
		
		for (int i=0;i<params.length;i++) {
			String a_param=params[i];
			
			if (a_param.indexOf(delimiter)>-1) {
				try {
					par_name="%"+a_param.split(delimiter)[0]+"%";
					par_val=a_param.split(delimiter)[1];
				} catch(Exception e) {
					par_name="";
					par_val="!!N/F!!";
				}

				if (par_name.length()>0) {
					if (ret1.indexOf(par_name)>-1) {
						ret1=ret1.replaceAll(par_name,par_val);
					}
				}
				
				}
			}
			
		
		return ret1;
	}
	
	//----------------------------------------------------------
	public static final StringBuilder getStackTraceAsStringBuilder(Exception e) {
		
		StringBuilder sb=new StringBuilder();
		
		StringWriter sw = new StringWriter();
		e.printStackTrace(new PrintWriter(sw));
		sb.append(sw.toString());
		
		return sb;
		
	}
	
	// ************************************************
	public static int heapUsedRate() {
		// ************************************************
		try {
			Runtime runtime = Runtime.getRuntime();
			int ret1 = Math.round(100
					* (runtime.totalMemory() - runtime.freeMemory())
					/ runtime.maxMemory());

			runtime = null;

			return ret1;
		} catch(Exception e) {return -1;}
	}
	
	//----------------------------------------------------------------
	public static boolean testRegex(String test_str, String regex_str) {
		Pattern pattern = null;
		
		try {
			pattern=Pattern.compile(regex_str);
			Matcher matcher = pattern.matcher(test_str);
			while (matcher.find()) return true;
		} catch(Exception e) {
			e.printStackTrace();
			return false;
		}
		
				
		
		return false;
		
	}
	
	
	//*****************************************************************************
	public static void setCatalogForConnection(Connection conn, String cat) {
		if (cat.length()==0 || cat.equals("${default}")) return;
			
			String curr_cat="";
			try { curr_cat=genLib.nvl(conn.getCatalog(),"");} catch(Exception e) {e.printStackTrace();}
			
			if (!curr_cat.equals(cat)) {
				System.out.println("setting catalog to ="+cat);
				try { conn.setCatalog(cat);} catch(Exception e) {e.printStackTrace();}	
			}
				
		
	}
	
	
	
	//********************************************************************************
	
	public static final int TABLE_PART_SOURCE=0;
	public static final int TABLE_PART_TARGET=1;
	
	public static final String TABLE_PART_ONLY_CATALOG="ONLY_CATALOG";
	public static final String TABLE_PART_ONLY_SCHEMA="ONLY_SCHEMA";
	public static final String TABLE_PART_ONLY_TABLE="ONLY_TABLE";
	public static final String TABLE_PART_ALL="ALL";
	
	//********************************************************************************
	public static String decodeTableTargetInfo(String target_owner_info, String full_tab_info, int part, String format) {
		
		String original_cat_name="";
		String original_schema_name="";
		String original_tab_name="";
		
		try {original_cat_name=full_tab_info.split("\\.")[0];} catch(Exception e) {}
		try {original_schema_name=full_tab_info.split("\\.")[1];} catch(Exception e) {}
		try {original_tab_name=full_tab_info.split("\\.")[2];} catch(Exception e) {}
		
		String decoded_cat_name=original_cat_name;
		String decoded_schema_name=original_schema_name;
		String decoded_tab_name=original_tab_name;
		
		
		
		String[] targets=target_owner_info.split("\n");
		
		for (int t=0;t<targets.length;t++) {
			String a_target=targets[t];
			if (a_target.contains("[") && a_target.contains("]")) {
				String a_orig_part=a_target.split("\\[")[0];
				if (a_orig_part.contains(".")) {
					String a_orig_cat=a_orig_part.split("\\.")[0];
					String a_orig_schema=a_orig_part.split("\\.")[1];
					String a_orig_table=a_orig_part.split("\\.")[2];
					
					if (a_orig_cat.equals(original_cat_name) &&  a_orig_schema.equals(original_schema_name) && a_orig_table.toLowerCase().equals(original_tab_name.toLowerCase())) {
						String a_new_table=a_target.split("\\[")[1].split("\\]")[0].split(":")[part];
						if (a_new_table.contains(".")) {
							decoded_cat_name=a_new_table.split("\\.")[0];
							decoded_schema_name=a_new_table.split("\\.")[1];
							decoded_tab_name=a_new_table.split("\\.")[2];
							break;
						}
						
					}
				}
				
			}
			
		} // for t
		
		if (format.equals(TABLE_PART_ONLY_CATALOG)) return decoded_cat_name;
		else if (format.equals(TABLE_PART_ONLY_SCHEMA)) return decoded_schema_name;
		else if (format.equals(TABLE_PART_ONLY_TABLE)) return decoded_tab_name;
		else return decoded_cat_name+"."+decoded_schema_name+"."+decoded_tab_name;
		
	}
	
	
	//****************************************
	public static String decrypt(String val) {
		
		try {			
			String ret1="";
			int i=0;
			while (true) {
				int char_len=0;
				try {char_len=Integer.parseInt(val.substring(i,i+1));} catch(Exception e) {break;}
				char c=(char) Integer.parseInt(val.substring(i+1,i+1+char_len));
				ret1=ret1+c;
				i=i+char_len+1;
			}
			
			return ret1;
		} catch(Exception e) {
			e.printStackTrace();
			return val;
		}
		
	}
	
	//***************************************************************************
	public static String passwordDecoder(String password) {
		if (!password.startsWith("DEC:"))  return password;
		
		try {
			String tmp=password.substring(4);
			return decrypt(tmp);
			
		} catch(Exception e) {
			e.printStackTrace();
			return "";
		}
		
	}
	
	
}
