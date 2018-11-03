package com.mayatech.repoDrivers;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.io.FileUtils;
import org.tmatesoft.svn.core.SVNDepth;
import org.tmatesoft.svn.core.SVNDirEntry;
import org.tmatesoft.svn.core.SVNLogEntry;
import org.tmatesoft.svn.core.SVNNodeKind;
import org.tmatesoft.svn.core.SVNProperties;
import org.tmatesoft.svn.core.SVNURL;
import org.tmatesoft.svn.core.auth.ISVNAuthenticationManager;
import org.tmatesoft.svn.core.io.SVNRepository;
import org.tmatesoft.svn.core.io.SVNRepositoryFactory;
import org.tmatesoft.svn.core.wc.ISVNOptions;
import org.tmatesoft.svn.core.wc.SVNClientManager;
import org.tmatesoft.svn.core.wc.SVNRevision;
import org.tmatesoft.svn.core.wc.SVNUpdateClient;
import org.tmatesoft.svn.core.wc.SVNWCUtil;

import com.mayatech.baseLibs.genLib;



public class SVNRepoExplorer {

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
		
		///for test purpose
		if (path.equals("TEST_MAD")) {
			for (int i=8000;i<10100;i++) 
				ret1.add("TAG_"+i);
			return ret1;
		}
		
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
	public ArrayList<String[]> getVersioningInfo(
			String url, 
			String username, 
			String password, 
			String path
			) {
		ArrayList<String[]>  ret1=new ArrayList<String[]>();
		
		
		
		SVNRepository repository=getSVNConnection(url, username, password, locallogs);
		if (repository==null) return ret1;
		
		Collection logs=null;
		try {
			String[] targetPaths=new String[]{path};
			//-1 means  : HEAD version
			logs=repository.log(targetPaths, null, 0, -1, false, true);
		} catch(Exception e) {
			e.printStackTrace();
			try{repository.closeSession();} catch(Exception ex) {}
			return ret1;
		}
		
		

		if (logs==null) return ret1;
		
		Iterator iterator = logs.iterator( );
		while ( iterator.hasNext( ) ) {
			SVNLogEntry logEntry = ( SVNLogEntry ) iterator.next( );
			
			ret1.add(new String[]{
					""+logEntry.getRevision(),
					logEntry.getAuthor(),
					formatDate(logEntry.getDate()),
				    logEntry.getMessage()
			});
			
		}
		
		try{repository.closeSession();} catch(Exception ex) {}
		
		return ret1;
	}
	
	
	
	
		
		
	//*********************************
	SVNRepository getSVNConnection(
			String url, 
			String username, 
			String password,
			StringBuilder logs) {
		SVNRepository ret1=null;
		
		try {
			ret1 = SVNRepositoryFactory.create( SVNURL.parseURIDecoded( url ) );
			ISVNAuthenticationManager authManager = SVNWCUtil.createDefaultAuthenticationManager( username , password );

			
			ret1.setAuthenticationManager( authManager );
			mylog(logs, "Repository connected. ["+url+"]");
			//System.out.println( "Repository Root: " + repository.getRepositoryRoot( true ) );
			//System.out.println(  "Repository UUID: " + repository.getRepositoryUUID( true ) );
			
		} catch(Exception e) {
			e.printStackTrace();
			return null;
		}
		
		
		return ret1;
	}
	//*********************************
	public ArrayList<String[]> getRepoTree(
			int level,
			int parent_item_id,
			SVNRepository repoin, 
			String url, 
			String username, 
			String password, 
			String path, 
			String filter
			) {
		ArrayList<String[]>  ret1=new ArrayList<String[]>();

		if (level==1) setListFilter(filter);
		
		SVNRepository repository = repoin;
		
		try {
			
			if (repository==null) {
				repository=getSVNConnection(url, username, password, locallogs);
				if (repository==null) {
					mylog(locallogs, "SVN Connection is not established. Repository is null");
					return ret1;
				}
			}
			
			mylog(locallogs, "Reading " + url + " @"+ path);
			SVNNodeKind nodeKind = repository.checkPath( path ,  -1 );
			
			if (nodeKind!=null)
				mylog(locallogs,  "nodeKind :  '" + nodeKind.toString());
			
			if ( nodeKind != SVNNodeKind.DIR ) {
				   mylog(locallogs,  "There is no directory entry at '/"+path + "'." );
				   try{repository.closeSession();} catch(Exception ex) {}
				   return ret1;
				   }
			
			mylog(locallogs,  " ... The entry at '" + path + "' is a directory as expected." );
			
			
			
			Collection entries=repository.getDir(path, -1, null, (Collection) null);

			if (entries==null) {
				try{repository.closeSession();} catch(Exception ex) {}
				return ret1;
			}
			
			Iterator iterator = entries.iterator( );
			
			while ( iterator.hasNext( ) ) {
				SVNDirEntry entry = ( SVNDirEntry ) iterator.next( );
				//int item_id=++item_numerator;
				int item_id=Math.abs(entry.getURL().toDecodedString().hashCode());
				String item_type="FILE";
				if (entry.getKind().getID()==0) item_type="DIR";
				
				
				
				
				if (filetypeFilter.equals(FILE_TYPE_FILTER_ALL) || filetypeFilter.equals(item_type)) {
					
					if (item_type.equals("DIR")  || checkFileFilter(entry.getName(), locallogs)) {
						String[] item=new String[]{
								""+item_id,
								""+parent_item_id,
								""+level,
								entry.getName(),
								item_type,
								entry.getAuthor(),
								formatDate(entry.getDate()),
								path+"/"+entry.getRelativePath(),
								""+entry.getRevision(),
								""+entry.getSize()
								
						}; 
						
						ret1.add(item);
					}
						
					
				}
				
				if (entry.getKind()==SVNNodeKind.DIR && (level+1)<=max_level) {
					String new_path=path+"/"+entry.getName();
					ret1.addAll(getRepoTree(level+1,item_id, repository, url, username, password, new_path, filter));
				}
					
			}
			
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try { repository.closeSession(); } catch(Exception e) { e.printStackTrace(); }
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

			SVNRepository repository = null;
			
			try {
				
				if (repository==null) {
					repository=getSVNConnection(url, username, password, locallogs);
					if (repository==null) {
						ret1.add("Repository is not reached!");
						mylog(locallogs, "SVN Connection is not established. Repository is null");
						return ret1;
					}
				}
				
				mylog(locallogs, "Reading... " + url+path);
				SVNNodeKind nodeKind = repository.checkPath( path ,  -1 );
				
				if ( nodeKind == SVNNodeKind.NONE ) {
					   mylog(locallogs, "File not found  '" + url+path + "'." );
					   try{repository.closeSession();} catch(Exception ex) {}
					   ret1.add("File not found '" + url+path + "'.");
					   return ret1;
					   }
				
				if ( nodeKind == SVNNodeKind.DIR ) {
				   mylog(locallogs, "Directory content cannot be read '" +url+path + "'." );
				   try{repository.closeSession();} catch(Exception ex) {}
				   ret1.add("Directory content  cannot be read '" + url+path + "'.");
				   return ret1;
				   }
				
				
				
				SVNProperties properties = new SVNProperties();
				ByteArrayOutputStream out = new ByteArrayOutputStream();
				
				long given_rev=0;
				try{given_rev=Long.parseLong(revision);} catch(Exception e) {given_rev=-1; /*HEAD*/}
				long read_rev=0;
				int file_size=0;
				try {
					read_rev=repository.getFile(path, given_rev, properties, out);		
				} catch(Exception e) {
					try{repository.closeSession();} catch(Exception ex) {}
					ret1.add("Exception@getFile ["+url+"]"+e.getMessage());
					e.printStackTrace();
					mylog(locallogs, "Exception@getFile ["+url+"]"+e.getMessage());
					return ret1;
				}
				
				
				
				file_size=out.size();
				
				
				mylog(locallogs, "File Size : "+file_size);
				
				
				
				if (file_size>10*1024*1024) {
					try{repository.closeSession();} catch(Exception ex) {}
					ret1.add("File is too big>10 MB ["+file_size+"] bytes");
					mylog(locallogs, "File is too big>10 MB ["+file_size+"] bytes");
					return ret1;
				}
				
				if (read_rev!=given_rev && given_rev>-1) {
					try{repository.closeSession();} catch(Exception ex) {}
					ret1.add("Version is not matched with given '" + url+path  + "'.");
					ret1.add("Demanded : "+given_rev);
					ret1.add("Read     : "+read_rev);
					
					mylog(locallogs, "Version is not matched with given '" + url+path  + "'.");
					mylog(locallogs, "Demanded : "+given_rev);
					mylog(locallogs, "Read     : "+read_rev);
							
					return ret1;
				}
				
				if (split_lines) {
					String[] arr=out.toString("UTF-8").split("\n|\r");
					for (int i=0;i<arr.length;i++) {
						ret1.add(arr[i]);
					}
				} else {
					ret1.add(out.toString("UTF-8"));
				}
				
				
				
				
				
				
				return ret1;
				
			} catch(Exception e) {
				
				mylog(locallogs,"Exception@getFileContent : "+e.getMessage());
				e.printStackTrace();
				
				
			} finally {
				try { repository.closeSession(); } catch(Exception e) { e.printStackTrace(); }
			}
			
			return ret1;
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
		
		
		SVNClientManager scm=null;
		
		SVNRepository repository=getSVNConnection(url, username, password, retlogs);
		if (repository==null) {
			mylog(retlogs, "Error. SVNRepository  cannot be initialized." );
			
			return false;
		}
		
		String export_svn_final_path="";
		String dir_check_path="";
		
		if (export_path.indexOf(url)==0) {
			export_svn_final_path=export_path;
			dir_check_path="";
		}
		else {
			
			export_svn_final_path=url+export_path;
			dir_check_path=export_path;
		}
			
		
		
		if (export_file.length()==0)
			mylog(retlogs, "Reading " + export_svn_final_path+" ("+export_version+")" );
		else 
			mylog(retlogs, "Reading " + export_svn_final_path+"/"+export_file+" ("+export_version+")" );
		
		SVNNodeKind nodeKind = null;
		
		try {nodeKind=repository.checkPath( dir_check_path ,  -1 /*HEAD*/ );} catch(Exception e) {e.printStackTrace();}
		
		
		if ( nodeKind != SVNNodeKind.DIR ) {
				mylog(retlogs, "There is no directory entry at '" + dir_check_path + "'." );
				try {repository.closeSession();} catch(Exception e) {}
			   return false;
			   }
		
		mylog(retlogs, " ... The directory at '" + export_svn_final_path+ "' is there as expected." );
		
		File dstPath =null;
		SVNURL export_url = null; 
		
		try {
			
			String local_path_final="";
			
			
			//Till what extent under a directory, export is required, is determined by depth. INFINITY means the whole subtree of that directory will be exported
			SVNDepth export_depth = null;
			
			if (export_file.length()==0) {
				export_url=SVNURL.parseURIDecoded(export_svn_final_path);
				local_path_final=local_path;
				export_depth = SVNDepth.INFINITY;
			}
			else {
				export_url=SVNURL.parseURIDecoded(export_svn_final_path+"/"+export_file);
				local_path_final=local_path+File.separator+export_file;
				export_depth = SVNDepth.EXCLUDE;


			}
			
			dstPath = new File(local_path_final);	
			
			long path_revision=-1; /*HEAD*/
			try { path_revision=Long.parseLong(export_version); } catch(Exception e) {path_revision=-1;}
			
			//the revision number which should be looked upon for the file path
			SVNRevision pegRevision = SVNRevision.create(path_revision);
			 //the revision number which is required to be exported.
			SVNRevision revision = SVNRevision.create(path_revision);
			//if there is any special character for end of line (in the file) then it is required. For our use case, 
			//it can be null, assuming there are no special characters. In this case the OS specific EoF style will 
			//be assumed
			String eolStyle = null;
			//this would force the operation 
	        boolean force = true;
	        
	        
	        //create export client
	        
	        ISVNOptions myOptions=SVNWCUtil.createDefaultOptions(true);
			ISVNAuthenticationManager myAuthManager=repository.getAuthenticationManager();
			
			SVNClientManager clientManager = SVNClientManager.newInstance(myOptions, myAuthManager);
			SVNUpdateClient updateClient = clientManager.getUpdateClient();
			
			
			if ( dstPath.isDirectory() ) {
				
				
				mylog(retlogs, "Clearing all folder content of " + local_path_final);
				try { FileUtils.deleteDirectory(dstPath);  } catch(Exception e) {
					mylog(retlogs, "Exception@exportFolder (Clear folder exception): "+e.getMessage());
					mylog(retlogs, genLib.getStackTraceAsStringBuilder(e).toString());
					e.printStackTrace();
					try {repository.closeSession();} catch(Exception ex) {}
					return false;
					}
					
			}
			else {
				
				try { 
					mylog(retlogs, "Deleting file " + local_path_final);
					if (dstPath.exists()) dstPath.delete();  
					mylog(retlogs, "deleting Done.");
					} catch(Exception e) {
						mylog(retlogs, "Exception@exportFolder (delete file exception): "+e.getMessage());
						mylog(retlogs, genLib.getStackTraceAsStringBuilder(e).toString());
						e.printStackTrace();
						try {repository.closeSession();} catch(Exception ex) {}
						return false;
					}	
				
			}
			
			
			mylog(retlogs, "Exporting..."+export_url.getPath() + " to " + local_path_final);
			long expret=updateClient.doExport(export_url, dstPath, pegRevision, revision, eolStyle, force, export_depth );
			mylog(retlogs, "updateClient.doExport returns :"+expret);
			mylog(retlogs, "Done..");
			try {repository.closeSession();} catch(Exception e) {}
			
			return true;
			
		} catch(Exception e) {
			
			
			mylog(retlogs, "Exception@exportFolder url            : "+url);
			mylog(retlogs, "Exception@exportFolder export_path    : "+export_path);
			mylog(retlogs, "Exception@exportFolder export_file    : "+export_file);
			mylog(retlogs, "Exception@exportFolder export_version : "+export_version);
			mylog(retlogs, "Exception@exportFolder local_path : "+local_path);

			mylog(retlogs, "Exception@exportFolder : "+e.getMessage());
			mylog(retlogs, genLib.getStackTraceAsStringBuilder(e).toString());
			
			e.printStackTrace();
			
			try {repository.closeSession();} catch(Exception ex) {}
			
			return false;
		}
		
		
		

		
		
		
		
		
	}
	

}
