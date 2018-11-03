package com.mayatech.repoDrivers;

import java.lang.reflect.Method;
import java.util.ArrayList;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.mayatech.baseLibs.genLib;

public class RepoExplorer {

	StringBuilder locallogs=new StringBuilder();
	Logger logger=LogManager.getLogger(this.getClass());
	
	//*********************************
	void mylog(StringBuilder logs, String alog) {
		logs.append(alog);
		logs.append("\n");
		System.err.println(alog);
		
		logger.warn("RepoExplorer : "+alog);
	}
	
	//*********************************
	ArrayList<String[]> sortArrayByType(ArrayList<String[]> inarr) {
		ArrayList<String[]> ret1=inarr;
		int TYPE_COL_ID=4;
		int TYPE_COL_NAME=3;


		for (int i=0;i<ret1.size();i++) {
			for (int j=i+1;j<ret1.size();j++) {
				String comp1=ret1.get(i)[TYPE_COL_ID]+"."+ret1.get(i)[TYPE_COL_NAME];
				String comp2=ret1.get(j)[TYPE_COL_ID]+"."+ret1.get(j)[TYPE_COL_NAME];
				if (comp1.compareTo(comp2)>0) {
					String[] tmparr=ret1.get(i);
					ret1.set(i, ret1.get(j));
					ret1.set(j, tmparr);
				}
			}
		}
		
		return ret1;
	}
	
	//*********************************
	ArrayList<String[]> sortByRevision(ArrayList<String[]> inarr) {
		ArrayList<String[]> ret1=inarr;
		int SORT_COL_ID=0;
		for (int i=0;i<ret1.size();i++) {
			for (int j=i+1;j<ret1.size();j++) {
				if (ret1.get(i)[SORT_COL_ID].compareTo(ret1.get(j)[SORT_COL_ID])<0) {
					String[] tmparr=ret1.get(i);
					ret1.set(i, ret1.get(j));
					ret1.set(j, tmparr);
				}
			}
		}
		
		return ret1;
	}
	
	//*********************************
	ArrayList<String> sortTagListDesc(ArrayList<String> inarr, StringBuilder logs) {
		
		mylog(logs, "Sorting tag list.");
		
		ArrayList<String> ret1=inarr;
		for (int i=0;i<ret1.size();i++) {
			for (int j=i+1;j<ret1.size();j++) {
				if (ret1.get(i).compareTo(ret1.get(j))<0) {
					String tmp=ret1.get(i);
					ret1.set(i, ret1.get(j));
					ret1.set(j, tmp);
				}
			}
		}
		mylog(logs, "Sorting tag list. DONE");
		return ret1;
	}

	 //*****************************************************************
	  public ArrayList<String[]> getRepoTree(
			String className,
			String url,
			String username, 
			String password,
			String path,
			String filter 
			) {

		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		
		
		Class ExplorerClass=null;
		Object  RepoExplorer=null;
		
		try { ExplorerClass=Class.forName(className); } catch (ClassNotFoundException e) { return ret1; }
		
		try {
			RepoExplorer=ExplorerClass.newInstance();
		} catch (Exception e) {
			e.printStackTrace();
			mylog(locallogs, "Exception@initialize : Class instance cannot be created : " + className);
			return ret1;
		}
		
		Method method=null;
		
		try {
			Method[] methods=RepoExplorer.getClass().getMethods();
			
			for (int i=0;i<methods.length;i++) {
				Method a_method=methods[i];
				if (a_method.getName().equals("getRepoTree")) {
					method=a_method;
					break;
				}
			}
		} catch(Exception e) { }
		
		
		if (method==null) {
			mylog(locallogs, "No Such Method Found");
			return ret1;
		}
		
		ArrayList<String[]> arr=new ArrayList<String[]>();
		
		
		try {
			ret1 = (ArrayList<String[]>) method.invoke(RepoExplorer, 1, 0 , null, url, username, password, path, filter);
		} catch (Exception e) {e.printStackTrace();}
		
		if (ret1!=null && ret1.size()<1000) {
			ret1=sortArrayByType(ret1);
		}
		
		
		
		return ret1;
	}
	
	//*****************************************************************
	public ArrayList<String> getTagList(
			String className,
			String url,
			String username, 
			String password,
			String path,
			String filter
			) {

		ArrayList<String> ret1=new ArrayList<String>();
		
		
		
		Class ExplorerClass=null;
		Object  RepoExplorer=null;
		
		try { ExplorerClass=Class.forName(className); } catch (ClassNotFoundException e) { return ret1; }
		
		try {
			RepoExplorer=ExplorerClass.newInstance();
		} catch (Exception e) {
			e.printStackTrace();
			mylog(locallogs, "Exception@initialize : Class instance cannot be created : " + className);
			return ret1;
		}
		
		Method method=null;
		
		try {
			Method[] methods=RepoExplorer.getClass().getMethods();
			
			for (int i=0;i<methods.length;i++) {
				Method a_method=methods[i];
				if (a_method.getName().equals("getTagList")) {
					method=a_method;
					break;
				}
			}
		} catch(Exception e) { }
		
		
		if (method==null) {
			mylog(locallogs, "No Such Method Found");
			return ret1;
		}
		
		
		try {
			ret1 = (ArrayList<String>) method.invoke(RepoExplorer, url, username, password, path, filter);
		} catch (Exception e) {e.printStackTrace();}
		
	return sortTagListDesc(ret1,locallogs);
		

	}
	
	
	//*****************************************************************
	public ArrayList<String> getFileContent(
			String className,
			String url,
			String username, 
			String password,
			String path,
			String version,
			boolean split_lines
			) {

		ArrayList<String> ret1=new ArrayList<String>();
		
		
		
		Class ExplorerClass=null;
		Object  RepoExplorer=null;
		
		try { ExplorerClass=Class.forName(className); } catch (ClassNotFoundException e) { return ret1; }
		
		try {
			RepoExplorer=ExplorerClass.newInstance();
		} catch (Exception e) {
			e.printStackTrace();
			mylog(locallogs, "Exception@initialize : Class instance cannot be created : " + className);
			return ret1;
		}
		
		Method method=null;
		
		try {
			Method[] methods=RepoExplorer.getClass().getMethods();
			
			for (int i=0;i<methods.length;i++) {
				Method a_method=methods[i];
				if (a_method.getName().equals("getFileContent")) {
					method=a_method;
					break;
				}
			}
		} catch(Exception e) { }
		
		
		if (method==null) {
			mylog(locallogs, "No Such Method Found");
			return ret1;
		}
		
		
		try {
			ret1 = (ArrayList<String>) method.invoke(RepoExplorer, url, username, password, path, version, split_lines);
		} catch (Exception e) {e.printStackTrace();}
		
	return ret1;
		

	}
	
	//*****************************************************************
	public ArrayList<String[]> getVersioningInfo(
			String className,
			String url,
			String username, 
			String password,
			String path
			) {

		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		
		mylog(locallogs, "getting revision info for : " + url+ path);
		
		Class ExplorerClass=null;
		Object  RepoExplorer=null;
		
		try { ExplorerClass=Class.forName(className); } catch (ClassNotFoundException e) { return ret1; }
		
		try {
			RepoExplorer=ExplorerClass.newInstance();
		} catch (Exception e) {
			e.printStackTrace();
			mylog(locallogs, "Exception@initialize : Class instance cannot be created : " + className);
			return ret1;
		}
		
		Method method=null;
		
		try {
			Method[] methods=RepoExplorer.getClass().getMethods();
			
			for (int i=0;i<methods.length;i++) {
				Method a_method=methods[i];
				if (a_method.getName().equals("getVersioningInfo")) {
					method=a_method;
					break;
				}
			}
		} catch(Exception e) { }
		
		
		if (method==null) {
			mylog(locallogs, "No Such Method Found");
			return ret1;
		}
		
		
		try {
			ret1 = (ArrayList<String[]>) method.invoke(RepoExplorer, url, username, password, path);
		} catch (Exception e) {e.printStackTrace();}
		
		ret1=sortByRevision(ret1);
		
		
		return ret1;
	
	}
	
	
	
	//*****************************************************************
		public boolean exportFolder(
				String className,
				String url,
				String username, 
				String password,
				String export_path,
				String export_file,
				String export_version,
				String local_path,
				StringBuilder retlogs
				) {

			mylog(retlogs, "Exporting path : " + export_path);
			
			Class ExplorerClass=null;
			Object  RepoExplorer=null;
			
			try { ExplorerClass=Class.forName(className); } catch (ClassNotFoundException e) { 
				mylog(retlogs, "Exception@exportFolder : "+e.getMessage());
				mylog(retlogs, genLib.getStackTraceAsStringBuilder(e).toString());
				
				e.printStackTrace();
				return false; 
				}
			
			try {
				RepoExplorer=ExplorerClass.newInstance();
			} catch (Exception e) {
				
				mylog(retlogs, "Exception@initialize : Class instance cannot be created : " + className);
				mylog(retlogs, genLib.getStackTraceAsStringBuilder(e).toString());
				
				e.printStackTrace();
				return false;
			}
			
			Method method=null;
			
			try {
				Method[] methods=RepoExplorer.getClass().getMethods();
				
				for (int i=0;i<methods.length;i++) {
					Method a_method=methods[i];
					if (a_method.getName().equals("exportFolder")) {
						method=a_method;
						break;
					}
				}
			} catch(Exception e) { }
			
			
			if (method==null) {
				mylog(retlogs, "No Such Method Found: exportFolder");
				return false;
			}
			
			
			try {
				boolean res=(Boolean) method.invoke(RepoExplorer, url, username, password, export_path, export_file, export_version, local_path, retlogs);
				
				return res;
				
			} catch (Exception e) {
				mylog(retlogs, "Exception@initialize : Class instance cannot be created : " + className);
				mylog(retlogs, genLib.getStackTraceAsStringBuilder(e).toString());
				
				e.printStackTrace();
				return false;
				}
			
			
			
			
		
		}
	
			
}
