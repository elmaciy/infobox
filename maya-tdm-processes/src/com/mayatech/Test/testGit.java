package com.mayatech.Test;

import java.util.ArrayList;

import org.eclipse.jgit.lib.Repository;

import com.mayatech.repoDrivers.GITRepoExplorer;

public class testGit {

	public static void main(String[] args) {
		


		int level=1;
		int parent_item_id=0;
		Repository repoin=null;
		
		GITRepoExplorer repoExplorer=new GITRepoExplorer();
		String url_local_path="d:\\githome";
		String username="elmaciy";
		String password="Han!1323";
		String path="";
		String filter="TYPE_FILTER=ALL\nMAXLEVEL=1";
		
		
		ArrayList<String[]> treeArr=repoExplorer.getRepoTree(level, parent_item_id, repoin, url_local_path, username, password, path, filter);
		System.out.println("treeArr.size() : " + treeArr.size());
		
		for (int i=0;i<treeArr.size();i++) {
			String[] arr=treeArr.get(i);
			
			for (int a=0;a<arr.length;a++) 
				System.out.print("\t"+arr[a]);
			
			System.out.println("");
		}
		
	
		
	}
}
