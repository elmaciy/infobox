package com.mayatech.baseLibs;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.enterprise.deploy.spi.Target;
import javax.enterprise.deploy.spi.TargetModuleID;
import javax.enterprise.deploy.spi.status.DeploymentStatus;
import javax.enterprise.deploy.spi.status.ProgressObject;

import weblogic.deploy.api.spi.DeploymentOptions;
import weblogic.deploy.api.spi.WebLogicDeploymentManager;
import weblogic.deploy.api.spi.deploy.ServerConnection;
import weblogic.deploy.api.spi.deploy.TargetImpl;
import weblogic.deploy.api.tools.SessionHelper;
import weblogic.management.mbeanservers.edit.ConfigurationManagerMBean;
import weblogic.management.mbeanservers.edit.EditServiceMBean;
import weblogic.wsee.policy.deployment.config.MBeanUtils;



public class wlsDeployLib {

	String admin_server_protocol="";
	String admin_server_host="";
	String admin_server_port="";
	String admin_username="";
	String admin_password="";
	
	public wlsDeployLib() {
		
	}
	
	public wlsDeployLib(String admin_server_protocol, String admin_server_host, String admin_server_port, String admin_username, String admin_password) {
		this.admin_server_protocol=admin_server_protocol;
		this.admin_server_host=admin_server_host;
		this.admin_server_port=admin_server_port;
		
		this.admin_username=admin_username;
		this.admin_password=admin_password;
		
	}
	
	public void setConnection(
			String admin_server_protocol, 
			String admin_server_host, 
			String admin_server_port, 
			String admin_username, 
			String admin_password,
			StringBuilder logs
			) {
		this.admin_server_protocol=admin_server_protocol;
		this.admin_server_host=admin_server_host;
		this.admin_server_port=admin_server_port;
		
		this.admin_username=admin_username;
		this.admin_password=admin_password;
	}
	
	
	
	boolean isCluster=false;
	boolean isJMSServer=false;
	boolean isSAFAgent=false;
	boolean isServer=false;
	boolean isVirtualHost=false;
	
	
	WebLogicDeploymentManager deployManager=null;
	
	
	
	ArrayList<String[]> availableTargetsInfo=new ArrayList<String[]>();
	ArrayList<Target> availableTargets=new ArrayList<Target>();
	
	String domain_name="";
	
	
	void mylog(StringBuilder log, String logstr) {
		log.append(logstr);
		log.append("\n");
		System.out.println(logstr);
	}
	
	
	public void DiscoverWLServer(StringBuilder log) {
	
		 
		 try {
			
			 mylog(log,"Connecting..."+admin_server_protocol+"://"+admin_server_host+":"+admin_server_port +"[user="+admin_username+"]");
			 
			 deployManager=SessionHelper.getRemoteDeploymentManager( 
					 admin_server_protocol,
					 admin_server_host,
					 admin_server_port,
					 admin_username,
					 admin_password);
			 
			 
		 } catch(Exception e) {
			 e.printStackTrace();
			 mylog(log, "Exception@wlsDeployLib.Connect : \n"+genLib.getStackTraceAsStringBuilder(e).toString());
			 deployManager=null;
		 }
		 
		 
		 
		
		 
		 if (deployManager==null) {
			 mylog(log,"deployManager is not connected.");
			 return;
		 }
		 
		 
		 mylog(log,"deployManager is connected successfully.");
		 
		 mylog(log,"Retrieving targets...");
		 
		 
		 Target[] WLStargets=new Target[0];
		 
		 try {
			 WLStargets=deployManager.getTargets();
		 } catch(Exception e) {
			 mylog(log,"Exception@deployManager.getTargets() : "+genLib.getStackTraceAsStringBuilder(e).toString());
			 e.printStackTrace();
			 return;
		 }
		 
		 
		 availableTargets.clear();
		 deployTarget.clear();
		 
		 for (int i=0;i<WLStargets.length;i++) {
			 Target aTarget=WLStargets[i];
			 mylog(log,"Target["+(i+1)+"] : "+aTarget.getName() + "{"+aTarget.getDescription()+"}");
			 
			 
			 String target_name=aTarget.getName();
			 String target_type=aTarget.getDescription();
			 
			 availableTargetsInfo.add(new String[]{target_name,target_type});
			 
			 availableTargets.add(aTarget);
			 
		 }
		 
		 
		 domain_name=deployManager.getDomain();

		 
		 mylog(log, "Domain Name : "+domain_name);
		 
		 
		 
		
	}
	
	ArrayList<Target> deployTarget=new ArrayList<Target>();
	
	
	
	//-----------------------------------------------------------------
	public void addDeploymentTarget(String target_type, String target_name, StringBuilder log) {
		if (deployManager==null) return;
		
		String[] targetArr=null;
		if (target_name.length()==0) targetArr=new String[]{""};
		else {
			if (target_name.contains(",")) targetArr=target_name.split(",");
			else if (target_name.contains("|::|")) targetArr=target_name.split("\\|::\\|");
			else targetArr=new String[]{target_name};
		}
		
		for (int i=0;i<availableTargets.size();i++) {
			String available_target_name=availableTargetsInfo.get(i)[0];
			String available_target_type=availableTargetsInfo.get(i)[1];
			
			for (int j=0;j<targetArr.length;j++) {
				
				String a_target_name=targetArr[j];
				
				
				boolean to_be_added=false;
				
				if (target_type.length()==0) {
					if (a_target_name.length()==0 || a_target_name.equals(available_target_name)) to_be_added=true;
				} else {
					if (target_type.equals(available_target_type) && (a_target_name.length()==0 || a_target_name.equals(available_target_name))) 
						to_be_added=true;
				}
				
				if (to_be_added) {
					deployTarget.add(availableTargets.get(i));
					mylog(log,"Adding target : "+available_target_name +" {"+available_target_type+"}");
				}
			} //for j
			
			
				
			
		}
		
	}
	
	DeploymentOptions options = new DeploymentOptions();
	
	//-----------------------------------------------------------------
	public void setStagingMode(String mode, StringBuilder log) {
		ArrayList<String> modes=new ArrayList<String>();
		
		modes.add("stage"); // Force copying of files to target servers.
		modes.add("nostage"); // Files are not copied to target servers.
		
		if (modes.indexOf(mode)==-1) {
			mylog(log, "No valid staging mode=> "+mode);
			
			return;
		}
		
		options.setStageMode(mode);
	}
	
	
	
	String start_mode="NO";
	
	//-----------------------------------------------------------------
	public void setStartMode(String mode, StringBuilder log) {
		ArrayList<String> modes=new ArrayList<String>();
		
		modes.add("NO"); // Don't start automatically after install
		modes.add("YES_ADMIN"); // Start only for admin
		modes.add("YES_PUBLIC"); // Start  for all
		
		if (modes.indexOf(mode)==-1) {
			mylog(log, "No valid start mode=> "+mode);
			
			return;
		}
		
		start_mode=mode;
	}
	
	//-----------------------------------------------------------------
	public void setIsLibrary(String is_lib, StringBuilder log) {
		ArrayList<String> modes=new ArrayList<String>();
		
		modes.add("NO"); 
		modes.add("YES"); 
		
		if (modes.indexOf(is_lib)==-1) {
			mylog(log, "No valid lib mode=> "+is_lib);
			
			return;
		}
		
		if (modes.equals("YES"))
			options.setLibrary(true);
		else 
			options.setLibrary(false);
		
		
		
		
		
	}
	//----------------------------------------------------------------
	javax.enterprise.deploy.shared.ModuleType decodeModuleType(String package_type) {
		
		
		switch (package_type) {
			case "CAR": return javax.enterprise.deploy.shared.ModuleType.CAR;
			case "EAR": return javax.enterprise.deploy.shared.ModuleType.EAR;
			case "EJB": return javax.enterprise.deploy.shared.ModuleType.EJB;
			case "WAR": return javax.enterprise.deploy.shared.ModuleType.WAR;
			case "RAR": return javax.enterprise.deploy.shared.ModuleType.RAR;
		}
		
		return null;
	}
	//-----------------------------------------------------------------
	public boolean performDeployment(
			String package_path, 
			String deployment_application_name, 
			String deployment_application_version,
			String package_type,
			long deployment_timeout,
			String wl_retired_option,
			StringBuilder log) {
		boolean ret1=false;
		
		
		 if (deployManager==null) {
			 mylog(log,"Exception@performDeployment : deployManager is not connected.");
			 return false;
		 }
		 
		//see if admin console is locked
		try {
			EditServiceMBean esm=MBeanUtils.getEditServiceMBean();

			ConfigurationManagerMBean cmm = esm.getConfigurationManager();

			String locking_user = cmm.getCurrentEditor();
			boolean haveUnactivatedChanges=cmm.haveUnactivatedChanges();
			
            if (genLib.nvl(locking_user,"-").equals("-") && haveUnactivatedChanges) {
                mylog(log,"Error : Server Console  is Locked by " + locking_user);
                return false;
            }

			
		} catch (Exception e1) {
			mylog(log,"Warning@performDeployment: "+e1.getMessage());
			mylog(log,"Console Lock status is not get successfully : "+e1.getMessage());
			mylog(log, genLib.getStackTraceAsStringBuilder(e1).toString());
		}
		
		ServerConnection serverConn=null;
		
		try {
			mylog(log,"Getting and testing server connection ....");
			serverConn=deployManager.getServerConnection();
			serverConn.test();
			mylog(log,"Test is ok ....");
		} catch(Throwable e1) {
			mylog(log,"getServerConnection.Test: "+e1.getMessage());
			mylog(log,"getServerConnection test message : "+e1.getMessage());
			serverConn=null;
		}
		
		
		if (serverConn!=null) {
			mylog(log,"------------------------------------------------------------------");
			mylog(log,"Printing Current Server Information...");
			mylog(log,"------------------------------------------------------------------");
			
			try {
			//----------------------------------
				
				
				
				List servers=serverConn.getServers();
				
				if (servers==null || servers.size()==0) {
					mylog(log,"\t No servers targeted.");
				} else {
					for (int i=0;i<servers.size();i++) {
						
						TargetImpl srv=(TargetImpl) servers.get(i);
						
						
						mylog(log, "\tTarget "+(i+1)+ " : " + srv.getName() + ", Desc : " + srv.getDescription()+
								", isServer="+srv.isServer()+
								", isCluster="+srv.isCluster()+
								", isJMSServer="+srv.isJMSServer()+
								", isSAFAgent="+srv.isSAFAgent()+
								", isVirtualHost="+srv.isVirtualHost()+
								", isManagerAuthenticated ="+srv.getManager().isAuthenticated()+
								", isManagerConnected="+srv.getManager().isConnected()
								);
						
						mylog(log,"\tPrinting Modules deployed on {"+srv.getName()+"}...");
						
						
						Target[] srvtargets=srv.getManager().getTargets();
						
						
						
						TargetModuleID[] currModuleIds = srv.getManager().getAvailableModules(decodeModuleType(package_type), srvtargets);
						
						
						
						if (currModuleIds!=null) {
							for (int t=0;t<currModuleIds.length;t++) {
								TargetModuleID a_module=currModuleIds[t];
								mylog(log, 
										"\t\tModule ["+(t+1)+"] : " + 
										", Name:"+ a_module.getModuleID()+
										", ModuleInfo : "+a_module.toString()+
										", URL : "+a_module.getWebURL()
										);
							}
						}
						
					}
				}

				
				
			//----------------------------------
			} catch(Exception e1) {
				mylog(log,"PrintCurrentServerInfo Err Msg: "+e1.getMessage());
				mylog(log, genLib.getStackTraceAsStringBuilder(e1).toString());
			}
			
			mylog(log,"------------------------------------------------------------------");

		} //if (serverConn!=null)
			
		
		
		
			
		
		try {
			File f = new File(package_path);
			if(!f.exists() || f.isDirectory()) { 
				mylog(log,"Exception@performDeployment : File not found : "+package_path);


				return false;
				}
		} catch(Exception e ) {
			mylog(log,"Exception@performDeployment : "+e.getMessage());
			e.printStackTrace();
			return false;
		}
		
		
		
		if (deployment_application_name==null || deployment_application_name.length()==0) {
			int last_dot=package_path.lastIndexOf(".");
			int last_file_splitter=package_path.lastIndexOf(File.separator);
			
			if (last_dot==-1 || last_file_splitter==-1) {
				deployment_application_name="UnknownApplicationName";
			} else 
				try {
					deployment_application_name=package_path.substring(last_file_splitter+1,last_dot);
				} catch(Exception e) {deployment_application_name="UnknownApplicationName";}

		}
		
		ArrayList<String> packTypeArr=new ArrayList<String>();
		packTypeArr.add("WAR");
		packTypeArr.add("RAR");
		packTypeArr.add("EAR");
		packTypeArr.add("CAR");
		packTypeArr.add("EJB");
		
		if (packTypeArr.indexOf(package_type)==-1) {
			int last_dot=package_path.lastIndexOf(".");
			try { package_type=package_path.substring(last_dot+1).toUpperCase();} catch(Exception e) {}
		}
		
		//Lock & Edit wait. Bu kisim daha akilli olmali.
		try { Thread.sleep(30000); } catch(Exception e) {}
		
		options.setName(deployment_application_name);
		
		
		
		
		mylog(log,"Deploying application .............:");
		mylog(log,"DomainName      : "+domain_name);
		mylog(log,"ApplicationName : "+deployment_application_name);
		mylog(log,"Package Path    : "+package_path);
		mylog(log,"Admin Server    : "+admin_server_protocol+"://"+admin_server_host+":"+admin_server_port);
		mylog(log,"Package Type    : "+package_type);
		mylog(log,"Deploy Targets  : ");
		
		for (int i=0;i<deployTarget.size();i++) {
			mylog(log,"\t"+deployTarget.get(i).getName());
		}
		mylog(log,"");
		
		mylog(log,"...................................:");
		
		Target[] Targets=new Target[deployTarget.size()];
		for (int i=0;i<deployTarget.size();i++) {
			Targets[i]=deployTarget.get(i);
		}
		
		ProgressObject processStatus=null;
		
		options.setTimeout(deployment_timeout);
		options.setForceUndeployTimeout(deployment_timeout);
		options.setGracefulIgnoreSessions(true);
		options.setGracefulProductionToAdmin(true);
		
		try {
			
			//if versioned deployment, undeploy retired ones
			if (deployment_application_version.length()>0 && wl_retired_option.equals("UNDEPLOY")) {
				TargetModuleID[] nonAllActiveModules=deployManager.getAvailableModules(decodeModuleType(package_type), Targets);
				//TargetModuleID[] nonRunningModules=deployManager.getNonRunningModules(decodeModuleType(package_type), Targets);
				
				ArrayList<TargetModuleID> targetModuleIDsToUndeploy=new ArrayList<TargetModuleID>();
				
				if (nonAllActiveModules!=null)
					for (int m=0;m<nonAllActiveModules.length;m++) {
						TargetModuleID aTargetModuleID=nonAllActiveModules[m];
						if (aTargetModuleID.getModuleID().indexOf(deployment_application_name)==-1) continue;
						mylog(log, "Checking versions to undeploy for : "+aTargetModuleID.getModuleID());
						if (aTargetModuleID.getModuleID().indexOf(deployment_application_name+"#")!=0) continue;
						
						targetModuleIDsToUndeploy.add(aTargetModuleID);
					}
				
				if (targetModuleIDsToUndeploy.size()>0) {
					TargetModuleID[] undeployModuleIDs=new TargetModuleID[1];
					
					for (int t=0;t<targetModuleIDsToUndeploy.size();t++) {
						undeployModuleIDs[0]=targetModuleIDsToUndeploy.get(t);
						
						DeploymentOptions undeployoptions = new DeploymentOptions();
						undeployoptions.setUndeployAllVersions(true);
						undeployoptions.setRetireGracefully(false);
						
						mylog(log, "Undeploying retired version ..." + undeployModuleIDs[0].getModuleID()+"("+undeployModuleIDs[0].getTarget()+")");
						
						processStatus=deployManager.undeploy(undeployModuleIDs,undeployoptions);
						
						waitDeployProcess(processStatus, 10*60*1000, log);
					}
						

				}
			
			} //if (deployment_application_version.length()>0 && wl_retired_option.equals("UNDEPLOY"))
			
			
			
			TargetModuleID[] runningModuleIds = deployManager.getRunningModules(decodeModuleType(package_type), Targets);
			
			if (runningModuleIds!=null) 
				for (int i=0;i<runningModuleIds.length;i++) {
					
					
					TargetModuleID aModule=runningModuleIds[i];
					
					String module_name=aModule.getModuleID();
					String module_version="";
					
					if (module_name.contains("#")) {
						module_version=module_name.substring(module_name.indexOf("#")+1);
						module_name=module_name.substring(0,module_name.indexOf("#"));
					}
						
					//System.out.println("*** Checking... " + module_name+ "("+module_version+") with " + deployment_application_name+ "("+deployment_application_version+")");
					
					
					if (module_name.equals(deployment_application_name) &&  genLib.nvl(module_version, deployment_application_version).equals(deployment_application_version)) {
						
						mylog(log,"Stopping..."  + aModule.getModuleID()+"@"+aModule.getTarget());
						
						DeploymentOptions stopoptions = new DeploymentOptions();
						
						stopoptions.setGracefulIgnoreSessions(true);
						stopoptions.setGracefulProductionToAdmin(true);
						
						processStatus=deployManager.stop(new TargetModuleID[]{aModule} , stopoptions);
						
						
						javax.enterprise.deploy.shared.StateType stopState=waitDeployProcess(processStatus, 5*60*1000, log);
						
						if (stopState.equals(javax.enterprise.deploy.shared.StateType.COMPLETED)) 
							mylog(log, "Stopped successfully." + aModule.getModuleID()+"@"+aModule.getTarget());
						else {
							mylog(log, "Stopping is failed." + aModule.getModuleID()+"@"+aModule.getTarget());
							return false;
						}
						
						break;
					}
						
				}
			
			
			if (deployment_application_version.length()>0) {
				options.setRetireGracefully(false);
				options.setNoVersion(false);
				options.setVersionIdentifier(deployment_application_version);				
			} //if (application_version.length()>0)

			
			ArrayList<TargetModuleID> moduleArr=new ArrayList<TargetModuleID>();
			for (int t=0;t<Targets.length;t++) {
				Target aTarget=Targets[t];
				TargetModuleID aTargetModuleID=deployManager.createTargetModuleID(deployment_application_name,decodeModuleType(package_type),aTarget);
				moduleArr.add(aTargetModuleID);
			}
			
			
			mylog(log, "Distribution is started.");
			
			TargetModuleID[] depTargetModuleIDs=new TargetModuleID[moduleArr.size()];
			for (int t=0;t<moduleArr.size();t++) depTargetModuleIDs[t]=moduleArr.get(t);
			
			
			
			processStatus=deployManager.distribute(depTargetModuleIDs, new File(package_path), null,options);
			
			
			javax.enterprise.deploy.shared.StateType distributeState=waitDeployProcess(processStatus, 60*60*1000, log);
			
			if (distributeState.equals(javax.enterprise.deploy.shared.StateType.COMPLETED)) {
				
				mylog(log, "Distribution is successfull.");
				
				Thread.sleep(1000);
				
				mylog(log, "Start Deploying...."+deployment_application_name+"("+deployment_application_version+")");
				
				
				
				processStatus=deployManager.deploy(depTargetModuleIDs, new File(package_path), null, options);
				
				
				javax.enterprise.deploy.shared.StateType deployState=waitDeployProcess(processStatus, 60*60*1000, log);

				if (deployState.equals(javax.enterprise.deploy.shared.StateType.COMPLETED)) 
					mylog(log, "Deployed successfully.   : " + deployment_application_name+"("+deployment_application_version+")");
				else {
					mylog(log, "Deployment is failed.    : " + deployment_application_name+"("+deployment_application_version+")");
					return false;
				}
				
				Thread.sleep(1000);
				
				
				
				
				
				
				if (!genLib.nvl(start_mode,"NO").equals("NO")) {
					
					TargetModuleID[] nonRunningModuleIds =new TargetModuleID[0];
					nonRunningModuleIds = deployManager.getNonRunningModules(decodeModuleType(package_type), Targets);
					
					if (nonRunningModuleIds!=null)
						for (int i=0;i<nonRunningModuleIds.length;i++) {
							
							
							TargetModuleID aModule=nonRunningModuleIds[i];
							String module_name=aModule.getModuleID();
							String module_version="";
							
							if (module_name.contains("#")) {
								module_version=module_name.substring(module_name.indexOf("#")+1);
								module_name=module_name.substring(0,module_name.indexOf("#"));
							}
								
							//System.out.println("*** Checking... " + module_name+ "("+module_version+") with " + deployment_application_name+ "("+deployment_application_version+")");
							
							if (module_name.equals(deployment_application_name) && genLib.nvl(module_version, deployment_application_version).equals(deployment_application_version)) {
								
								
								
								mylog(log,"Starting..."  + aModule.getModuleID()+"@"+aModule.getTarget());
								DeploymentOptions startoptions = new DeploymentOptions();
								
								if (start_mode.equals("YES_ADMIN"))
									startoptions.setAdminMode(true);
								
								processStatus=deployManager.start(new TargetModuleID[]{aModule} , startoptions);
								
								break;
								
							}
								
						}
					
				}
			} else {
				mylog(log,"Distribution is failed...");
				return false;
			}
			
			
			ret1=true;
			
			
			
		} catch(Exception e) {
			
			mylog(log, "Exception@performDeployment : " + e.getMessage());
			
			
			e.printStackTrace();
			
			
			mylog(log, genLib.getStackTraceAsStringBuilder(e).toString());
			
		

			try {serverConn.close(false);} catch(Exception e2) {}
			
			return false;
		}
		
		
		return ret1;
	}
	
	
	//-------------------------------------------------------------
	javax.enterprise.deploy.shared.StateType waitDeployProcess(ProgressObject processStatus, int timeout_ms, StringBuilder log) {
		
		DeploymentStatus deploymentStatus=null;
		
		deploymentStatus=processStatus.getDeploymentStatus();

		mylog(log,"\tDeploymentStatus.getState(): "+deploymentStatus.getState()+ " @"+new Date());
		
		long start_ts=System.currentTimeMillis();
		
		while(deploymentStatus.getState().equals(javax.enterprise.deploy.shared.StateType.RUNNING)) {
			
			try {Thread.sleep(5000);} catch (InterruptedException e) {}
			 
			 deploymentStatus=processStatus.getDeploymentStatus() ;
			 
			 
			 mylog(log,"\tDeploymentStatus.getState("+deploymentStatus.getCommand()+"): "+deploymentStatus.getState()+ " @"+new Date());
				
				if (deploymentStatus.getMessage()!=null && deploymentStatus.getMessage().length()>0) {
					mylog(log,"\tDeploymentStatus.Action()    : "+deploymentStatus.getAction()+ " @"+new Date());
					mylog(log,"\tDeploymentStatus.getCommand(): "+deploymentStatus.getCommand()+ " @"+new Date());
					mylog(log,"\tDeploymentStatus.getMessage(): "+deploymentStatus.getMessage());

				}
					
				
				if (System.currentTimeMillis()-start_ts>timeout_ms) break;
				
		}
		
		if (deploymentStatus.getMessage()!=null && deploymentStatus.getMessage().length()>0) {
			mylog(log,"\tDeploymentStatus.Action()    : "+deploymentStatus.getAction()+ " @"+new Date());
			mylog(log,"\tDeploymentStatus.getCommand(): "+deploymentStatus.getCommand()+ " @"+new Date());
			mylog(log,"\tDeploymentStatus.getMessage(): "+deploymentStatus.getMessage());
		}
			
		
		
		return deploymentStatus.getState();
	}
	//-----------------------------------------------------------------
	public void closeDeployment() {
		if (deployManager==null) return;
		deployManager.release();
		
		deployTarget.clear();
		availableTargets.clear();
	}
	
	
}
