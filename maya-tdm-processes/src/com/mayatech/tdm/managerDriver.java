package com.mayatech.tdm;

import java.util.Date;

import com.mayatech.datamodel.dmModelForDM;


public class managerDriver {

	public static void main(String[] args) {
		
		
		String locJar=managerDriver.class.getProtectionDomain().getCodeSource().getLocation().getFile();
		int loc1=locJar.indexOf("mayatdm-");
		int loc2=locJar.indexOf(".jar");
		String version=locJar.substring(loc1+("mayatdm-".length()),loc2);
		

		ConfDBOper d = new ConfDBOper(false);
		d.manager_id=1;
		d.checkLicence();

		d.mylog(d.LOG_LEVEL_WARNING,"jar_location ="+locJar);
		d.mylog(d.LOG_LEVEL_WARNING,"version      ="+version);

		
		String sql="";
		
		sql="select count(*) x from tdm_manager where last_heartbeat> DATE_SUB(now(), INTERVAL 60 second)";
		
		int activeManagerCount=0;
		
		try {
		activeManagerCount=Integer.parseInt(d.getDbArrayConf(sql, 1).get(0)[0]);
		} catch(Exception e) {
			activeManagerCount=0;
		}
		
		if (activeManagerCount>0) {
			d.mylog(d.LOG_LEVEL_WARNING, "There is already a working manager here... fire him first. bye..");
			d.closeAll();
			d=null;
			System.exit(0);
		}
		
		sql="delete from tdm_manager";
		d.execDBConf(sql);
		
		
		String hostname = d.gethostinfo();

		
		sql="insert into tdm_manager (status,last_heartbeat,hostname, cancel_flag)  values ('RUNNING',now(),'"+hostname+"','NO') ";
		
		d.execDBConf(sql);
		
		
		dmModelForDM model=new dmModelForDM();
		model.syncDM(d.connConf);

		
			while (true) {

				if (d.LIC_END.before(new Date())) {
					d.mylog(d.LOG_LEVEL_ERROR, "Licence is expired...");
					break;
				}
				
				d.createWorkPackages();
				
				d.balanceMasterProcesses();
				
				d.killDeadProcesses();
				
				d.resumeStalled();
				
				d.matchMasterWorkPackage();
				
				if (d.isMadInstalled())
					d.createMadDeploymentMainWorkPlan();
				
				if (d.isMadInstalled())
					d.runActionMethods();
				
				if (d.isDMInstalled())
					d.checkDMProcess();
				
				if (d.isDataPoolInstalled())
					d.checkDataPoolProcess();
				
				if (d.isMaskDiscoveryInstalled())
					d.checkMaskDiscoveryProcess();
				
				d.deleteUnusedTaskTables(false);
				
				
				d.heartbeat(ConfDBOper.TABLE_TDM_MANAGER, 0, 0);
				
				
				if (d.getCancelFlag("tdm_manager")) {
					d.mylog(d.LOG_LEVEL_WARNING, "Manager is cancelled...");
					break;
				}
				
				if (d.getRestartFlag("tdm_manager")) {
					d.mylog(d.LOG_LEVEL_WARNING, "Manager is restarting...");
					sql="delete from tdm_manager";
					d.execDBConf(sql);
					d.startNewProcess("com.mayatech.tdm.managerDriver", 1, null);
					break;
				}
				
				try {Thread.sleep(1000);} catch(Exception e){}
				
				
			}// while
	
		sql="delete from tdm_manager";
		d.execDBConf(sql);
	
		
		d.closeAll();
		d = null;
	} 
}
