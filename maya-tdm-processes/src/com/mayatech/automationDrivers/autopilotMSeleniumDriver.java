package com.mayatech.automationDrivers;

import java.io.File;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.apache.commons.io.FileUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Keys;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.Platform;
import org.openqa.selenium.Point;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.remote.Augmenter;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.ui.Select;




public class autopilotMSeleniumDriver  {

	
	
	
	WebDriver webDriver=null; 
	Exception CurrException=null;
	
	
	public void initializeTest(Properties prop) {
		try {
			
			DesiredCapabilities cap = new DesiredCapabilities();
			
			
			String SEL_HUB=prop.getProperty("SEL_HUB", "http://localhost:4444/wd/hub");
			System.out.println(" *** set Selenium HUB : " + SEL_HUB);
			
			String SEL_START_URL=prop.getProperty("SEL_START_URL", "http://www.yahoo.com/");
			System.out.println(" *** set Start Page : " + SEL_START_URL);
			
			String SEL_BROWSER=prop.getProperty("SEL_BROWSER", "firefox");
			System.out.println(" *** set Browser : " + SEL_BROWSER);
			cap.setBrowserName(SEL_BROWSER);
			
			if (SEL_BROWSER.toLowerCase().contains("xplore")) {
				cap.setCapability(InternetExplorerDriver.INTRODUCE_FLAKINESS_BY_IGNORING_SECURITY_DOMAINS, true);
				cap.setCapability(InternetExplorerDriver.IGNORE_ZOOM_SETTING, true);
			}
				


			
			
			String SEL_PLATFORM=prop.getProperty("SEL_PLATFORM", "");
			if(SEL_PLATFORM.trim().length()>0) {
				System.out.println(" *** set Platform : " + SEL_PLATFORM);
				cap.setPlatform(Platform.valueOf(SEL_PLATFORM));
			}
			
			String SEL_VERSION=prop.getProperty("SEL_VERSION", "");
			if(SEL_PLATFORM.trim().length()>0) {
				System.out.println(" *** set Version : " + SEL_VERSION);
				cap.setVersion(SEL_VERSION);
			}
			
			String SEL_NODE=prop.getProperty("SEL_NODE", "");
			if(SEL_NODE.trim().length()>0 && !SEL_NODE.trim().equals("ANY") && SEL_NODE.contains(",")) {
				SEL_NODE=SEL_NODE.split(",")[0].trim();
				System.out.println(" *** set NODE : " + SEL_NODE);
				cap.setCapability("remoteHost", SEL_NODE);

			}
			
			cap.setJavascriptEnabled(true);
			
			
			System.out.println("Connecting to webdriver : " + SEL_HUB);
			webDriver = new RemoteWebDriver(new URL(SEL_HUB), cap);

			
			System.out.println("Connected :)");
			
			webDriver.get(SEL_START_URL);
			webDriver.manage().window().maximize();
			
			} catch(Exception e) {
				CurrException=e;
				printCurrException();
				try {
					throw e;
				} catch (Exception e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
		}
		
	}
	


	
	
	//***********************************************************
	void printCurrException() {
		
		if (CurrException!=null) {
			

			System.out.println("----------------------------------------------------------");
			System.out.println("Exception : " + CurrException.getMessage());
			if (CurrException.getCause()!=null)
				System.out.println("Caused By : " + CurrException.getCause().toString());
			System.out.println("----------------------------------------------------------");
			StackTraceElement[] el=CurrException.getStackTrace();
			
			for (int i=0;i<el.length;i++) {
				StackTraceElement ael=el[i];
				if (!ael.isNativeMethod())
					System.out.println(ael.toString());
			}
			
			

			
			lastExceptionMessage.append("----------------------------------------------------------<br>\n");
			lastExceptionMessage.append("Exception : " + CurrException.getMessage()+"<br>\n");
			if (CurrException.getCause()!=null)
				lastExceptionMessage.append("Caused By : " + CurrException.getCause().toString()+"<br>\n");
			
			lastExceptionMessage.append("<textarea rows=6 cols=100>");
			for (int i=0;i<el.length;i++) {
				StackTraceElement ael=el[i];
				if (!ael.isNativeMethod())
					lastExceptionMessage.append(ael.toString()+"\n");
			}
			lastExceptionMessage.append("</textarea>");
			
		}
			
		CurrException=null;
	}
	
	//***********************************************************
	public void terminateTest() {
	//***********************************************************

		try {webDriver.close(); } catch(Exception e) { e.printStackTrace(); }
		try {webDriver.quit(); } catch(Exception e) { e.printStackTrace();}
		
	}
	
	
	
	
	//***********************************************************
	public void go(String url) {
	//***********************************************************
		try {
			webDriver.navigate().to(url);
		}
		 catch(Exception e) {
			 CurrException=e;
			 printCurrException();
		 }

		
	}
	
	StringBuilder lastExceptionMessage=new StringBuilder();
	
	//***********************************************
	public void resetException() {
		lastExceptionMessage.setLength(0);
	}
	
	//***********************************************
	public String getLastException() {
		return lastExceptionMessage.toString();
	}	
	
	//***********************************************************
	public void sleep(long waitts) {
	//***********************************************************
		try {Thread.sleep(waitts);} catch(Exception e) {}
	}

	WebElement lastWaitElement=null;
	String lastWaitElementLocator="";
	long lastWaitElementTs=0;

	//***********************************************************
	public WebElement waitElement(String locator, long timeout) {
	//***********************************************************
		return waitElement(locator, timeout, false);
	}
	
	
	
	
	//***********************************************************
	private WebElement getElementFromDOM(String tag_attr_val) {
		long start_ts=System.currentTimeMillis();
		
		String[] arr=tag_attr_val.split("\\.");
		if (arr.length<2) return null;
		String a_tag=arr[0];
		String a_attr=arr[1];
		String temp=a_tag+"."+a_attr;
		int oper_loc=temp.length();
		String a_oper=".";
		try{a_oper=tag_attr_val.substring(oper_loc,oper_loc+1);} catch(Exception e){}
		String a_val="";
		try{a_val=tag_attr_val.substring(oper_loc+1,tag_attr_val.length());} catch(Exception e){}
		
		if (a_attr.toLowerCase().equals("text")) a_attr="text()";
		
		
		List<WebElement> els=webDriver.findElements(By.tagName(a_tag));
		if (els!=null && els.size()>0) {
			//System.out.println(a_tag + " found : " + els.size());
			for (int t=0;t<els.size();t++) {
				WebElement el=els.get(t);
				String val="";
				try {
					if (a_attr.equals("text()"))  val=el.getText();
					else val=el.getAttribute(a_attr);
				} catch(Exception e) {}
				
				if (a_oper.equals(".") && val.equals(a_val)) {
					return el;
				}
				
				if (a_oper.equals("*") && val.contains(a_val)) {
					return el;
				}
				
			}
		} 
		
		return null;
		
	}
	
	//***********************************************************
	public WebElement waitElement(String locator, long timeout, boolean visibility_check) {
	//***********************************************************
		
		if (webDriver==null) 
			terminateTest();
		
		WebElement el=null;
		
		if (locator.equals("LAST_ELEMENT_LOCATED")) {
			if (lastElementEx==null) {
				System.out.println("No element located before.");
				return null;
			}
			el= lastElementEx;
		}
		
		if (el==null)
			if (System.currentTimeMillis()-lastWaitElementTs<1000  && lastWaitElementLocator.equals(locator)) {
				lastWaitElementTs=System.currentTimeMillis();
				el= lastWaitElement;
			}
		
		
		long startts=System.currentTimeMillis();
		
		Exception waitException=null;
		
		
		if (el==null)
		while(true) {
			try {
				
				el=null;
				
				if (locator.indexOf("dom=")==0) {
					String tag_attr_val=locator.substring(4);
					el=getElementFromDOM(tag_attr_val);
				} 
				else if (locator.indexOf("name=")==0) {
					String name=locator.substring(5);
					el=webDriver.findElement(By.name(name));
				}
				else if (locator.indexOf("id=")==0) {
					String id=locator.substring(3);
					el=webDriver.findElement(By.id(id));
				}
				else if (locator.indexOf("css=")==0) {
					el=webDriver.findElement(By.cssSelector(locator));
				}
				else {
					try {
						el=webDriver.findElement(By.xpath(locator));
					} catch(Exception e) {
						
						String contains_locator="//*[contains(text(),'"+locator+"')]";
						
						try {
							el=webDriver.findElement(By.xpath(contains_locator));
						} catch(Exception e1) {
							el=null;
						}
						
					}
				}

				if (el!=null) {
					if (visibility_check) {
						if(!el.isDisplayed()) {
							System.out.print(".");
							 sleep(500);
							 continue;
						}
					}
					break;
				}
				/*
				if (el!=null) 
					 if (visibility_check && !el.isDisplayed()) break;
					 else 
						 {
						 System.out.print(".");
						 sleep(500);
						 }
				       */       
				
				} catch(Exception e) {
					waitException=e;
					sleep(100);
					}
			
			if (System.currentTimeMillis()-startts>timeout) break;
		}
		
		 System.out.println("");
		 
		if (el!=null) {
			Point p=el.getLocation();
			lastWaitElement=el;
			lastElementEx=el;
			lastWaitElementLocator=locator;
			lastWaitElementTs=System.currentTimeMillis();
			resetException();
			
			return el;
		}


		
		
		System.out.println("Element was not found :  " + locator);
		CurrException=waitException;
		printCurrException();
		
		try {
			throw CurrException;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return null;
	}
	
	//***********************************************************
	public void  click(String locator) {
	//***********************************************************

		WebElement el=waitElement(locator, 10000, true);
		
		if (el!=null)
			try {
				el.click();
			} catch(Exception e) {
				CurrException=e;
				printCurrException();
			}
		
		
	}
	
	//**********************************************************
	public void runJS(String script) {
		System.out.println("Executing JS : \n" + script);

		JavascriptExecutor jse = (JavascriptExecutor) webDriver;

		try {
			jse.executeScript(script);
		} catch (Exception e) {
			CurrException=e;
			printCurrException();
		}

	}
	
	//***********************************************************
	public void  hover(String locator) {
	//***********************************************************

		WebElement el=waitElement(locator, 10000, true);
		
		if (el!=null)
			try {
				Actions action = new Actions(webDriver);
				action.moveToElement(el).build().perform();
			} catch(Exception e) {
				CurrException=e;
				printCurrException();
			}
		
		
	}
	//***********************************************************
	public void  check(String locator) {
	//***********************************************************
		
		WebElement el=waitElement(locator, 10000);
		
		if (el!=null)
			try {
				if (!el.isSelected()) el.click();
			} catch(Exception e) {
				CurrException=e;
				printCurrException();
			}
		
		
	}
	
	
	//***********************************************************
	public void  uncheck(String locator) {
	//***********************************************************
		
		WebElement el=waitElement(locator, 10000);
		
		if (el!=null)
			try {
				if (el.isSelected()) el.click();
			} catch(Exception e) {
				CurrException=e;
				printCurrException();
			}
	}
	
	//***********************************************************
	void setActiveElement() {
		sleep(100);
		try{lastElementEx=webDriver.switchTo().activeElement();} catch(Exception e){}
		
		}
	//***********************************************************
	public void  keyTab() {
	//***********************************************************
		if (lastElementEx!=null)
		try {
			lastElementEx.sendKeys(Keys.TAB);
			setActiveElement();
			} 
		catch(Exception e) {
			CurrException=e;
		printCurrException();
		}
		
	}
	
	//***********************************************************
	public void  keyEnter() {
	//***********************************************************
		
		if (lastElementEx!=null)
		try {
			lastElementEx.sendKeys(Keys.ENTER);
			setActiveElement();
			} 
		catch(Exception e) {
			CurrException=e;
		printCurrException();
		}
	}		
	
	
	//***********************************************************
	public void  setText(String locator,String text) {
	//***********************************************************
		
		WebElement el=waitElement(locator, 10000);
		
		if (el!=null)
			try {
				
				if (el.isDisplayed() && el.isEnabled())
					{
					try {el.clear();} catch(Exception e) {}
					el.sendKeys(text);
					}

			} catch(Exception e) {
				CurrException=e;
				printCurrException();
			}
		
		
	}
	
	//***********************************************************
	public void  setSelectOption(String locator,String text, String val) {
	//***********************************************************
		
		WebElement el=waitElement(locator, 10000);
		
		if (el!=null)
			try {
				Select select = new Select(el);
				//set by value
				if (text.trim().length()>0) 
					select.selectByVisibleText(text);
				else if (val.trim().length()>0) 
					select.selectByValue(val);
				else 
					select.selectByIndex(1);

			} catch(Exception e) {
				CurrException=e;
				printCurrException();
			}
		
		
	}
	

	WebElement lastElementEx=null;
	//***********************************************************
	public WebElement  findElementEx(String ref_locator, String direction, int order, String tagtofind, String typetofind) {
	//***********************************************************
		WebElement el=null;
		lastElementEx=null;
		lastExceptionMessage.setLength(0);
		
		WebElement reference=waitElement(ref_locator, 10000);

		if (reference==null) {
			System.out.println("Reference element was not found at " + ref_locator);
			return null;
		}
		
		Point refPoint=reference.getLocation();


		List<WebElement> elList=webDriver.findElements(By.tagName(tagtofind));
		ArrayList<Integer> addList=new ArrayList<Integer>();
		ArrayList<Integer> addListID=new ArrayList<Integer>();
		ArrayList<Integer> addListDistance=new ArrayList<Integer>();
		
		if (elList!=null) {
			for (int i=0;i<elList.size();i++) {
				WebElement ael=elList.get(i);
				Point aPoint=ael.getLocation();
				boolean add=false;
				int diff=0;
				if (direction.equals("EAST") && aPoint.getX()>=refPoint.getX()) {
					add=true;
					diff=Math.abs(aPoint.getX()-refPoint.getX());
				}
				if (direction.equals("WEST") && aPoint.getX()<=refPoint.getX()) {
					add=true;
					diff=Math.abs(aPoint.getX()-refPoint.getX());
				}
				
				if (direction.equals("NORTH") && aPoint.getY()<=refPoint.getY()) {
					add=true;
					diff=Math.abs(aPoint.getY()-refPoint.getY());
				}
				if (direction.equals("SOUTH") && aPoint.getY()>=refPoint.getY()) {
					add=true;
					diff=Math.abs(aPoint.getY()-refPoint.getY());
				}
				
				if (direction.equals("NEAR") || direction.equals("BY") || direction.equals("NEXTTO") ) {
					add=true;
					diff=Math.abs(aPoint.getY()-refPoint.getY());
					int diff_x=Math.abs(aPoint.getX()-refPoint.getX());
					int diff_y=Math.abs(aPoint.getY()-refPoint.getY());
					diff=(int) Math.round(Math.sqrt(diff_x*diff_x+diff_y*diff_y));
				}
				
				if (add && ael.isDisplayed() && ael.isEnabled()) {
					
					String a_type=ael.getAttribute("type");
					if (a_type.toLowerCase().equals("password")) a_type="text";
					
					if (typetofind.length()>0 && a_type!=null &&  !a_type.toLowerCase().equals(typetofind.toLowerCase())) 
						add=false;
					
					if (add) {
						addListDistance.add(diff);
						addListID.add(i);
					}
					
				}
				
			} //for
			
			
			if (order>addListDistance.size()) return null;
			
			//sort by distance
			
			for (int i=0;i<addListDistance.size();i++) {
				for (int j=i+1;j<addListDistance.size();j++) {
					if (addListDistance.get(i)>addListDistance.get(j)) {
						int temp=0;
						
						temp=addListDistance.get(i);
						addListDistance.set(i, addListDistance.get(j));
						addListDistance.set(j, temp);
						
						temp=addListID.get(i);
						addListID.set(i, addListID.get(j));
						addListID.set(j, temp);
						
						
					}
				}
			}
			
			//sorted. find element at desired order
			int el_id=addListID.get(order-1);
			el=elList.get(el_id);
			
			lastElementEx=el;
		}
		
		
		return el;
		
		
	}
	
	//***********************************************************
	public String  getAttr(String locator,String attr) {
	//***********************************************************
			
		WebElement el=waitElement(locator, 10000);
		
		if (el!=null)
			try {
				if (
					attr.toLowerCase().equals("text") 
					|| attr.toLowerCase().equals("text()") 
					|| attr.toLowerCase().equals("value")
					)
					return el.getText();
				else if (
						attr.toLowerCase().equals("exists") 
						|| attr.toLowerCase().equals("exists()") 
						)
					return "true";			
				else 
					{
					try {
						String ret1=el.getAttribute(attr); 
						return ret1;
						}
					catch(Exception e) {
						return "<NOT_FOUND>";
					}
					}

			} catch(Exception e) {
				CurrException=e;
				printCurrException();
			}
		
		return "";
		
	}
	
	//*********************************************
	public void screenShot(String path) {
		if (webDriver==null) return;		
		try {
			WebDriver augmentedDriver = new Augmenter().augment(webDriver);
			Thread.sleep(100);
			File source = ((TakesScreenshot) augmentedDriver).getScreenshotAs(OutputType.FILE);
			Thread.sleep(100);
			FileUtils.copyFile(source, new File(path));
			source.delete();
		} catch (Exception e) {
			CurrException=e;
			printCurrException();
		}

	}
	

	//*********************************************
	public void clearCookies() {
		if (webDriver==null) return;	
		try {
			webDriver.manage().deleteAllCookies();
		} catch (Exception e) {
		CurrException=e;
		printCurrException();
	}
	}
}
