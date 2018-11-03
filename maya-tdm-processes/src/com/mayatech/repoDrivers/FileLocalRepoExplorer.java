package com.mayatech.repoDrivers;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.nio.file.CopyOption;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.attribute.FileOwnerAttributeView;
import java.nio.file.attribute.UserPrincipal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.mayatech.baseLibs.genLib;



public class FileLocalRepoExplorer {

	static final String FILE_TYPE_FILTER_ALL="ALL";
	static final String FILE_TYPE_FILTER_FILE="FILE";
	static final String FILE_TYPE_FILTER_DIR="DIR";
	
	int max_level=Integer.MAX_VALUE;
	ArrayList<String> filenameFilterArr=new ArrayList<String>();
	String filetypeFilter=FILE_TYPE_FILTER_ALL;
	
	
	StringBuilder locallogs=new StringBuilder();
	
	//*********************************
	void mylog(StringBuilder logs, String alog) {
		logs.append(alog);
		logs.append("\n");
		System.out.println(alog);
	}
	//*********************************
	void setListFilter(String filter) {
		filenameFilterArr.clear();
		String[] arr=filter.split("\n|\r");
		for (int i=0;i<arr.length;i++) {
			String afilter=arr[i];
			if (afilter.trim().length()==0) continue;
			if (!afilter.contains("=")) continue;
			String[] keyval=afilter.split("=");
			String key=keyval[0].trim().toUpperCase();
			String val=afilter.substring(afilter.indexOf("=")+1);
			if (val.length()==0)  continue;
			
			if (key.equals("MAXLEVEL")) try {max_level=Integer.parseInt(val);} catch(Exception e) {}
			if (key.equals("NAME_FILTER")) filenameFilterArr.add(val);
			if (key.equals("TYPE_FILTER")) filetypeFilter=val;
			
		}

	}
	
	//*********************************
	boolean checkFileFilter(String filename, StringBuilder log) {
		
		if (filenameFilterArr.size()==0) return true;
		Pattern pattern = null;
		for (int i=0;i<filenameFilterArr.size();i++) {
			String regex_filter=filenameFilterArr.get(i);
			
			try {
				pattern=Pattern.compile(regex_filter,Pattern.CASE_INSENSITIVE);
				} catch(Exception e) {
					pattern=null;
					mylog(log, "Exception@Pattern.compile REGEX : " + regex_filter);
					mylog(log, "Exception@Pattern.compile ERROR : " + e.getMessage());
					e.printStackTrace();
				}
			if (pattern==null) continue;


			Matcher matcher = pattern.matcher(filename);
			while (matcher.find()) {
				return true;
				
			}

		}
		return false;
	}
	
	//*****************************************************************
	public ArrayList<String> getTagList(
			String url,
			String username, 
			String password,
			String path,
			String filter
			) {

		ArrayList<String> ret1=new ArrayList<String>();
		
		
		ArrayList<String[]> arr=getRepoTree(1, 0, null, url, username, password, path, filter);
			
		for (int i=0;i<arr.size();i++) {
			String tag_name=arr.get(i)[3];
			ret1.add(tag_name);
		}
		
		return ret1;
	}
	
	//*********************************
	private String formatDate(Date datein) {
		
		String ret1="";
		try{
			SimpleDateFormat sd=new SimpleDateFormat(genLib.DEFAULT_DATE_FORMAT);
			ret1=sd.format(datein);
			} catch(Exception e) {ret1=""+datein;}
		
		return ret1;
	}
	
	//*********************************
	private String formatDate(long datein_ts) {
		Date dt=new Date(datein_ts);
		return formatDate(dt);
	}
	
	//*********************************
	String getFileOwner(String full_path) {
		try {
			Path fileinfo=Paths.get(full_path);
			FileOwnerAttributeView ownerAttributeView = Files.getFileAttributeView(fileinfo, FileOwnerAttributeView.class);
			UserPrincipal owner = ownerAttributeView.getOwner();
			return owner.getName();
		} catch(Exception e) {
			return "unknown";
		}
		
		
		
	}
	
	//*********************************
	public ArrayList<String[]> getVersioningInfo(
			String url, 
			String username, 
			String password, 
			String path
			) {
		ArrayList<String[]>  ret1=new ArrayList<String[]>();
		//String full_path=url+path;
		String full_path=path;
		
		mylog(locallogs,"Reading version info for : "+full_path);
		try {
			
			if (!isPathExists(full_path)) {
				mylog(locallogs,"Path not found : " + full_path);
				return ret1;
			}
			
			
			
			
			File f = new File(full_path);
			
			ret1.add(new String[]{
					"-1",
					getFileOwner(full_path),
					formatDate(f.lastModified()),
				    "" //checkin message
					} 
					);
				    
			return ret1;
			
		} catch(Exception e) {
			mylog(locallogs, "Exception@getVersioningInfo : "+genLib.getStackTraceAsStringBuilder(e).toString());
			
			return ret1;
		}
		
		
		
		
	}
	
	
	
	
		
		
	
	
	//*********************************
	boolean isPathExists(String filePathString) {
		try {
			File f = new File(filePathString);
			if(f.exists()) return true;
			return false;
			
		} catch (Exception e) {
			return false;
		}
		
	}
	//*********************************
	boolean isDirectory(String filePathString) {
		try {
			File f = new File(filePathString);
			if(f.isDirectory()) return true;
			return false;
			
		} catch (Exception e) {
			return false;
		}
		
	}
	//*********************************
	public ArrayList<String[]> getRepoTree(
			int level,
			int parent_item_id,
			Object dummyobj, //SVNRepository repoin, 
			String url, 
			String username, 
			String password, 
			String path, 
			String filter
			) {
		ArrayList<String[]>  ret1=new ArrayList<String[]>();

		if (level==1) setListFilter(filter);
		
		
		
		try {
			
			//String full_path=url + path;
			String full_path=path;
			
			mylog(locallogs, "Reading " + full_path);
			
			if (!isPathExists(full_path)) {
				mylog(locallogs,  "Path not found "+full_path + "'." );
				return ret1;
			}
			
			if (!isDirectory(full_path) ) {
				   mylog(locallogs,  "There is no directory entry at '/"+full_path + "'." );
				   return ret1;
				   }
			
			mylog(locallogs,  " ... The entry at '" + full_path + "' is a directory as expected." );
			
			
			File f = new File(full_path);
			File[] listOfFiles=f.listFiles();
			
			if (listOfFiles==null || listOfFiles.length==0) return ret1;
		
			for (int i=0;i<listOfFiles.length;i++) {
				File a_file=listOfFiles[i];
				String file_name=a_file.getName();
				int item_id=Math.abs(a_file.hashCode());
				
				String item_type="FILE";
				if (a_file.isDirectory()) item_type="DIR";
				
					if (filetypeFilter.equals(FILE_TYPE_FILTER_ALL) || filetypeFilter.equals(item_type)) {
						if (item_type.equals("DIR")  || checkFileFilter(file_name, locallogs)) {
							String[] item=new String[]
									{
									""+item_id,
									""+parent_item_id,
									""+level,
									file_name,
									item_type,
									getFileOwner(full_path),
									formatDate(f.lastModified()),
									a_file.getPath(),
									"-1", //entry.getRevision(),
									""+a_file.length() //entry.getSize()
									};
							
							ret1.add(item);
							
						} //if (filetypeFilter.equals(FILE_TYPE_FILTER_ALL) || filetypeFilter.equals(item_type))
				}
					
				if (isDirectory(full_path) && (level+1)<=max_level) {
					String new_path=full_path+File.separator+file_name;
					ret1.addAll(getRepoTree(level+1,item_id, null, url, username, password, new_path, filter));
				}
					
			} //for
				 
		} catch(Exception e) {
			e.printStackTrace();
		} 
		
		return ret1;
	}
	
	//*********************************
		public ArrayList<String> getFileContent(
				String url, 
				String username, 
				String password, 
				String path,
				String revision,
				boolean split_lines
				) {
			ArrayList<String>  ret1=new ArrayList<String>();
			
			String file_path=path;
			
			
			
			if (!isPathExists(file_path)) {
				mylog(locallogs, "File not found : " + file_path);
				return ret1;
			}
			
			
			if (isDirectory(file_path)) {
				 mylog(locallogs, "Directory content cannot be read '" +file_path + "'." );
				return ret1;
			}

			
			try {
				File f = new File(file_path);
				long file_size=f.length();
				mylog(locallogs, "File Size : "+file_size);
				
				if (file_size>10*1024*1024) {
					ret1.add("File is too big>10 MB ["+file_size+"] bytes");
					mylog(locallogs, "File is too big>10 MB ["+file_size+"] bytes");
					return ret1;
				}
				
				
				long given_rev=-1;
				try{given_rev=Long.parseLong(revision);} catch(Exception e) {given_rev=-1; /*HEAD*/}
				long read_rev=-1;
								
				
				if (read_rev!=given_rev && given_rev>-1) {
					ret1.add("Version is not matched with given '" + file_path  + "'.");
					ret1.add("Demanded : "+given_rev);
					ret1.add("Read     : "+read_rev);
					
					mylog(locallogs, "Version is not matched with given '" + file_path  + "'.");
					mylog(locallogs, "Demanded : "+given_rev);
					mylog(locallogs, "Read     : "+read_rev);
							
					return ret1;
				}
				
				System.out.println("Reading file content : "+ file_path);
				
				BufferedReader br = new BufferedReader(new InputStreamReader(
	                      new FileInputStream(file_path), "UTF8"));
				StringBuilder sb=new StringBuilder();
				
				try {
					
					
					while (true) {	
						String line = br.readLine();
						if (line==null) break;
						
						if (split_lines) ret1.add(line);
						else sb.append(line+"\n");
						
						
					} //while
					
					if (!split_lines) 
						ret1.add(sb.toString());
					
				} catch(Exception e) {
					e.printStackTrace();
					mylog(locallogs, "Exception@getFileContent : " + genLib.getStackTraceAsStringBuilder(e).toString());
					return ret1;
				} finally {
					try {br.close();} catch(Exception e) {}
				}
				
				System.out.println("Done. Reading file content : "+ file_path);
				
				return ret1;
				
			} catch(Exception e) {
				e.printStackTrace();
				mylog(locallogs, "Exception@getFileContent : " + genLib.getStackTraceAsStringBuilder(e).toString());
				return ret1;
			} 

		}

	//*********************************
	public boolean exportFolder(
			String url, 
			String username, 
			String password, 
			String export_path,
			String export_file,
			String export_version,
			String local_path,
			StringBuilder retlogs
			) {
		boolean dir_copy=true;
		String final_export_path=export_path;
		
		if (export_file.trim().length()>0) {
			 final_export_path=final_export_path+File.separator+export_file;
			 dir_copy=false;
		}
		
		if (!isPathExists(final_export_path)) {
			mylog(retlogs, "Path not found : '" + final_export_path + "'." );
			return false;
		}
		                                   
		if (dir_copy && !isDirectory(final_export_path)) {
			mylog(retlogs, "There is no directory entry at '" + final_export_path + "'." );
			return false;
		}
		
		
		
		
		try {
		
			if (!isPathExists(local_path) || !isDirectory(local_path)) {
				mylog(locallogs,"Directory not found. Creating... : "+local_path);
				
				try {
					new File(local_path).mkdirs();
				} catch(Exception e) {
					e.printStackTrace();
				}
				
				
				if (isPathExists(local_path)) 
					mylog(locallogs,"Directory created : "+local_path);
				else {
					mylog(locallogs,"Directory cannot be created : "+local_path);
					return false;
				}
			}
			
			if (!dir_copy) {
				String final_target_path=local_path+File.separator+export_file;
				return copySingleFile(final_target_path, final_target_path, retlogs);
				}
			
			File dir_to_copy=new File(final_export_path);
			
			File[] files=dir_to_copy.listFiles();
			for (int i=0;i<files.length;i++) {
				File afile=files[i];
				boolean is_directory=afile.isDirectory();
				String fname=afile.getName();
				if (fname.equals(".") || fname.equals("..")) {
					System.out.println("skipping : " + fname);
					continue;
				}
				
				if (!is_directory) {
					String final_target_path=local_path+File.separator+fname;
					mylog(locallogs, "Copying... "+afile.getPath() +" => "+final_target_path);
					
					boolean is_ok=copySingleFile(afile.getPath(), final_target_path, retlogs);
					if (is_ok) {
						mylog(locallogs, "Copied : "+afile.getPath() +" => "+final_target_path);
					} else {
						mylog(locallogs, "NOT Copied : "+afile.getPath() +" => "+final_target_path);
					}
				} else {
					
					String sub_export_dir=afile.getPath();
					String sub_local_path=local_path +File.separator+ afile.getName();
					
					
					exportFolder(
							url, 
							username, 
							password, 
							sub_export_dir, 
							"", 
							export_version, 
							sub_local_path, 
							retlogs);
				}
			}
			
			
		} catch(Exception e) {
			mylog(retlogs, "Exception@exportFolder : "+e.getMessage());
			mylog(retlogs, genLib.getStackTraceAsStringBuilder(e).toString());
			
			e.printStackTrace();
			
			return false;
		}

		return true;
	}
	
	boolean copySingleFile(String source_file_path, String target_file_path, StringBuilder retlogs) {
		
		try {
			File fCopy=new File(source_file_path);
			File fTarget=new File(target_file_path);
			
			if (fTarget.exists() && !fTarget.isDirectory()) {
				try {
					mylog(retlogs, "File is already exists on target. Deleting... "+target_file_path);
					fTarget.delete();
					mylog(retlogs, "Deleted.. "+target_file_path);
				} catch(Exception e) {
					e.printStackTrace();
					mylog(retlogs, "Exception@copySingleFile Delete existing : "+e.getMessage());
					mylog(retlogs, genLib.getStackTraceAsStringBuilder(e).toString());
					return false;
				}
			}
			
			mylog(locallogs, "Copying... " + source_file_path  + " to " +target_file_path + " ...");
			//Path  p=Files.copy(fCopy.toPath(), fTarget.toPath(), new CopyOption[] { StandardCopyOption.REPLACE_EXISTING,  StandardCopyOption.COPY_ATTRIBUTES } );
			Path  p=Files.copy(fCopy.toPath(), fTarget.toPath(), new CopyOption[] {StandardCopyOption.COPY_ATTRIBUTES } );
			
			mylog(locallogs, "File copied  : " + source_file_path  +" to " + p.toString());
		} catch(Exception e ) {
			mylog(retlogs, "Exception@copySingleFile : "+e.getMessage());
			mylog(retlogs, genLib.getStackTraceAsStringBuilder(e).toString());
			
			return false;
		}
		
		
		
		return true;
		
		
		
	}
	

}
