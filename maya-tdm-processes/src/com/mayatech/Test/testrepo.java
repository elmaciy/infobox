package com.mayatech.Test;

import java.util.ArrayList;

import com.mayatech.repoDrivers.RepoExplorer;
import com.mayatech.tdm.ConfDBOper;



public class testrepo {

	
	public static void main(String[] args) {
		
		ConfDBOper d=new ConfDBOper(false);
		int application_id=1;
		
		String sql=" select " +
				" class_name, par_hostname, par_username, "+
				" par_password, app_repo_root, app_repo_filter "+
				" from  mad_application a, mad_repository r "+
				" where a.repository_id=r.id "+
				" and a.id=?";		
		ArrayList<String[]> repoparams=d.getDbArrayConfInt(sql, 1, application_id);
		
		String className=repoparams.get(0)[0];
		String repo_url=repoparams.get(0)[1];
		String username=repoparams.get(0)[2];
		String password=repoparams.get(0)[3];
		String path=repoparams.get(0)[4];
		String filter=repoparams.get(0)[5];
		
		d.closeAll();
		
		
		ArrayList<String[]> arr=new ArrayList<String[]>();
		long start_ts=System.currentTimeMillis();
		RepoExplorer re=new RepoExplorer();
		
		
		//arr=re.getRepoTree(conn, application_id);
		arr=re.getRepoTree(className,repo_url,username,password, path, filter);
		 
		System.out.println("item count : " + arr.size() );
		long dur=System.currentTimeMillis()-start_ts;
		for (int i=0;i<arr.size();i++) {
			String[] item=arr.get(i);
			for (int j=0;j<item.length;j++) {
				System.out.print(item[j]+"\t");
			}
			System.out.print("\n");
		}
		
		System.out.println("Duration  :  "  + dur);

	}

}
