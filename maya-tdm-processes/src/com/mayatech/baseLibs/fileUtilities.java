package com.mayatech.baseLibs;


import static org.w3c.dom.Node.ATTRIBUTE_NODE;
import static org.w3c.dom.Node.CDATA_SECTION_NODE;
import static org.w3c.dom.Node.COMMENT_NODE;
import static org.w3c.dom.Node.DOCUMENT_TYPE_NODE;
import static org.w3c.dom.Node.ELEMENT_NODE;
import static org.w3c.dom.Node.ENTITY_NODE;
import static org.w3c.dom.Node.ENTITY_REFERENCE_NODE;
import static org.w3c.dom.Node.NOTATION_NODE;
import static org.w3c.dom.Node.PROCESSING_INSTRUCTION_NODE;
import static org.w3c.dom.Node.TEXT_NODE;
import gudusoft.gsqlparser.EDbVendor;
import gudusoft.gsqlparser.TGSqlParser;
import gudusoft.gsqlparser.TSyntaxError;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.WildcardFileFilter;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class fileUtilities {
	
	public String ls = System.getProperty("line.separator");
	
	public StringBuilder logs=new StringBuilder();
	
	//*****************************************************************************************
	void mylog(String log) {
		System.out.println(log);
		logs.append(log);
		logs.append("\n");
	}
	
	
	//*****************************************************************************************
	public String readFile( String file )  {
		
		
		BufferedReader reader = null;
		try {
	    	reader = new BufferedReader( new FileReader (file));
	    	String         line = null;
		    StringBuilder  stringBuilder = new StringBuilder();
		    

		    while( ( line = reader.readLine() ) != null ) {
		        stringBuilder.append( line );
		        stringBuilder.append( ls );
		    }
		    return stringBuilder.toString();
	    } catch(Exception e) {
	    	e.printStackTrace();
	    	
	    } finally {
	    	try {reader.close();} catch (IOException e1) {e1.printStackTrace();}
	    }
	    
		return "";
	   
	}
	
	// *****************************************
	void write2file(String filepath) {
		BufferedWriter out = null;
		
		File f=new File(filepath);
		if (f.exists()) f.delete();
		
		StringBuilder text=new StringBuilder();
		for (int i=0;i<file_lines.size();i++) {
			text.append(file_lines.get(i));
			if (i<file_lines.size()-1) text.append(ls);
		}
			
		
		write2file(filepath, text);
	}
	
	
	// *****************************************
	void write2file(String filepath, StringBuilder text) {
		BufferedWriter out = null;
		
		File f=new File(filepath);
		
		if (f.exists()) f.delete();
		
		try {
			out=new BufferedWriter(new OutputStreamWriter(new FileOutputStream(filepath),"UTF-8"));
			out.append(text);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {out.close();} catch(Exception e) {}
		}
	}
		
	//*****************************************************************************************
	boolean testRegex(String text_2_match, String regex) {
		
		try {
			Pattern pattern = Pattern.compile(regex);
			
			Matcher matcher = pattern.matcher(text_2_match);
			while (matcher.find()) {
				mylog("\""+text_2_match + "\" \tmatched with ["+regex+"]");
				return true;
			}
		} catch(Exception e) {
			mylog("Exception@testRegex["+text_2_match+","+regex+"]");
			e.printStackTrace();
		}
		
		return false;
	}
	
	//*****************************************************************************************
	ArrayList<String[]> parameters=new ArrayList<String[]>();
	
	
	//*****************************************************************************************
	ArrayList<String> file_lines=new ArrayList<String>();
	//*****************************************************************************************
	public boolean checkAndModifyFile(
			String file_pattern, 
			boolean to_include_sub_folders,
			String new_file_path, 
			ArrayList<String[]> rules,
			ArrayList<String[]> out_params, 
			StringBuilder replacer_log 
			) {
		
		if (out_params!=null) parameters=out_params;
		
		ArrayList<String> filelist=getMatchingFileList(file_pattern,to_include_sub_folders);
		
		if (filelist.size()==0) {
			mylog("No file found to check and replace.: "+file_pattern);
			return true;
		}
		
		for (int r=0;r<filelist.size();r++) {
			String replace_file_name=filelist.get(r);
			mylog("Processing file : "+replace_file_name);
			
			try {new File(replace_file_name);} 
			catch(Exception e) {
				mylog("File not found : " + replace_file_name);
				e.printStackTrace();
				continue;
			}
			
			File f=new File(replace_file_name);
			if (!f.exists()) {
				mylog("Error@replaceFile");
				mylog("!File Not Found : "+ replace_file_name);
				continue;
			}
			
			
			String[] lines=readFile(replace_file_name).toString().split(ls);
			file_lines.clear();
			for (int i=0;i<lines.length;i++) {
				file_lines.add(lines[i]);
				
			}
			
			//file is empty or not read properly
			if (file_lines.size()==0) {
				mylog("File is empty : "+replace_file_name);
				continue;
			}
			
			for (int i=0;i<rules.size();i++) {
				
				String rule_id=rules.get(i)[0];
				String rule_locator_type=rules.get(i)[1];
				String rule_locator_statement=rules.get(i)[2];
				String rule_locator_options=rules.get(i)[3];
				String rule_changer_action=rules.get(i)[4];
				String rule_changer_statement=rules.get(i)[5];
				String rule_changer_options=rules.get(i)[6];
				String when_value_to_check=genLib.replaceAllParams(rules.get(i)[7], parameters);
				String when_operand=rules.get(i)[8];
				String when_values=genLib.replaceAllParams(rules.get(i)[9], parameters);
				
				
				mylog("Applying rule  : " + rule_id + 
						"\tWhen "+rule_locator_type + 
						"\t"+rule_locator_statement + 
						"\t"+rule_locator_options +
						"\t Do "+rule_changer_action +
						"\t"+rule_changer_statement +
						"\t"+rule_changer_options+
						"\t Only If "+when_value_to_check+
						"\t"+when_operand+
						"\t"+when_values);
				
				if (when_value_to_check.length()>0) {
					boolean apply_rule=checkIf(when_value_to_check, when_operand, when_values);
					if (!apply_rule) {
						mylog("Rule will be skipped.");
						continue;
					}
				}
				
				if (rule_locator_type.equals("XPATH")) {
					boolean xpath_ok=checkAndModifyByXpath(rule_locator_statement, rule_locator_options, rule_changer_action, rule_changer_statement, rule_changer_options);
					
					if (rule_changer_action.equals("STOP") && xpath_ok) {
						mylog("File XPATH check failed with message :["+genLib.replaceAllParams(rule_changer_statement,parameters)+"] ");
						return false;
					}


					
					continue;
				}
				
				if (rule_locator_type.equals("CUSTOM")) {
					StringBuilder checkLogs=new StringBuilder();
					boolean check_ok=checkByCustomClass(replace_file_name, rule_locator_statement, rule_locator_options ,parameters, checkLogs);
					
					if (rule_changer_action.equals("STOP") && check_ok) {
						mylog("File CUSTOM check failed with message :["+genLib.replaceAllParams(rule_changer_statement,parameters)+"] ");
						return false;
					}


					
					continue;
				}
				
				int line_number=0;
				boolean matched=false;
				while(line_number<file_lines.size()) {

					matched=false;
					String a_line=file_lines.get(line_number);
					
					switch (rule_locator_type) {
						case "EMPTY" : {if (a_line.trim().length()==0) matched=true; break;}
						case "CONTAINS" : {if (a_line.contains(rule_locator_statement)) matched=true; break;}
						case "EQUALS" : {if (a_line.equals(rule_locator_statement)) matched=true; break;}
						case "STARTS_WITH" : {if (a_line.indexOf(rule_locator_statement)==0) matched=true; break;}
						case "ENDS_WITH" : {if (a_line.indexOf(rule_locator_statement)>-1 && a_line.indexOf(rule_locator_statement)+rule_locator_statement.length()==a_line.length()) matched=true;break;}
						case "REGEX" : {if (testRegex(a_line, rule_locator_statement)) matched=true; break;}
						default : mylog("No such rule " + rule_locator_type); 
					} //switch case
					
					
					if (rule_changer_action.equals("STOP") && matched) {
						mylog("File Line check failed  at line ["+line_number+"] with message :["+genLib.replaceAllParams(rule_changer_statement,parameters)+"] ");
						return false;
					} 

					
					if (matched) {
						String replaced_rule_changer_statement=genLib.replaceAllParams(rule_changer_statement,parameters);
						String replaced_rule_changer_options=genLib.replaceAllParams(rule_changer_options,parameters);
						
						applyChange(line_number,rule_changer_action,replaced_rule_changer_statement,replaced_rule_changer_options);
						if (rule_changer_action.equals("INSERT_BEFORE")) line_number++;
						if (rule_changer_action.equals("DELETE")) line_number--;
					}
					
					line_number++;
					
				}
				
			} // for int i=0; i<rules.size()
			
			
			
			write2file(replace_file_name);
			
			
		}
		
		
		
		
		
		
		
		
		

		
		replacer_log.append(logs.toString());
		return true;
	}
	

	
	//*****************************************************************************************
	void applyChange( 
			int line_number,
			String action,
			String statement,
			String options
			) {
		
		mylog("Change : \t"+action+"("+line_number+","+statement+","+options+")");
		switch (action) {
			case "UPDATE" : {file_lines.set(line_number, statement);break;}
			case "DELETE" : {file_lines.remove(line_number);break;}
			case "INSERT_BEFORE" : {file_lines.add(line_number, statement);break;}
			case "INSERT_AFTER" : {file_lines.add(line_number+1, statement);break;}
			case "SET_START" : {file_lines.set(line_number, statement + file_lines.get(line_number));break;}
			case "SET_END" : {file_lines.set(line_number, file_lines.get(line_number) + statement);break;}
			case "REPLACE" : {file_lines.set(line_number, file_lines.get(line_number).replace(statement, options));break;}
			case "REPLACE_ALL" : {file_lines.set(line_number, file_lines.get(line_number).replaceAll(statement, options));break;}
			case "REPLACE_FIRST" : {file_lines.set(line_number, file_lines.get(line_number).replaceFirst(statement, options));break;}
			case "JAVASCRIPT" : {file_lines.set(line_number, changeByJavaScriptEngine(file_lines.get(line_number),statement));break;}
			default : mylog("No such action " + action); 
		}
		
		
	}
	
	//*****************************************************************************************
	String changeByJavaScriptEngine(String original_str, String js_code) {
		
		String ret1=original_str;
		String changed_js_code=genLib.replaceAllParams(js_code, parameters);
		
		if (changed_js_code.trim().length()==0)
			return ret1;
		
		ScriptEngineManager factory=null;
		ScriptEngine engine=null;
		
		try {
			factory = new ScriptEngineManager();
			engine = factory.getEngineByName("JavaScript");
			ret1=""+ engine.eval(js_code);
		} catch (Exception e) {
			e.printStackTrace();
			ret1=original_str;
		}
		
		return ret1;
		
		
	}
	
	//*****************************************************************************************

	static String nodeType(short type) {
	    switch(type) {
	      case ELEMENT_NODE:                return "Element";
	      case DOCUMENT_TYPE_NODE:          return "Document type";
	      case ENTITY_NODE:                 return "Entity";
	      case ENTITY_REFERENCE_NODE:       return "Entity reference";
	      case NOTATION_NODE:               return "Notation";
	      case TEXT_NODE:                   return "Text";
	      case COMMENT_NODE:                return "Comment";
	      case CDATA_SECTION_NODE:          return "CDATA Section";
	      case ATTRIBUTE_NODE:              return "Attribute";
	      case PROCESSING_INSTRUCTION_NODE: return "Attribute";
	    }
	    return "Unidentified";
	  }
	
	
	//*****************************************************************************************
	Node setNodeValue(Node aNode, String val) {
		Node ret1=aNode;
		
		if (ret1.getNodeType()==Node.TEXT_NODE)
				ret1.setTextContent(val);
		else ret1.setNodeValue(val);
		
		return ret1;
	}
	//*****************************************************************************************
	boolean checkByCustomClass(
			String file_path,
			String class_name, 
			String class_parameter, 
			ArrayList<String[]> params,
			StringBuilder logs) {
		
		Class CheckerClass=null;
		Object  Checker=null;
		
		try { CheckerClass=Class.forName(class_name); } catch (ClassNotFoundException e) { 
			mylog("Exception@checkByCustomClass : Class not found : "+class_name);
			mylog(genLib.getStackTraceAsStringBuilder(e).toString());
			return false;
			}
		
		
		try {
			Checker=CheckerClass.newInstance();
		} catch (Exception e) {
			e.printStackTrace();
			mylog("Exception@initialize : Class instance cannot be created : " + class_name);
			return false;
		}
		
		
		Method method=null;
		
		
		try {
			Method[] methods=Checker.getClass().getMethods();
			
			for (int i=0;i<methods.length;i++) {
				Method a_method=methods[i];
				if (a_method.getName().equals("checkFile")) {
					method=a_method;
					break;
				}
			}
		} catch(Exception e) { }
		
		
		if (method==null) {
			mylog("No checkFile Method Found");
			return false;
		}
		
		try {
			StringBuilder checkerLogs=new StringBuilder();
			mylog("Calling Checker : "+class_name+"("+class_parameter+")");

			boolean res = (boolean) method.invoke(Checker, file_path, class_parameter, params, checkerLogs);
			mylog("Checker returns : "+res);
			
			mylog(checkerLogs.toString());
			
			return res;
		} catch (Exception e) {
			e.printStackTrace(); 
			mylog("Exception@method.invoke ("+method+"):"+ genLib.getStackTraceAsStringBuilder(e).toString());
			return false;
			}
	}
	//*****************************************************************************************
	boolean checkAndModifyByXpath( 
			String rule_locator_statement,
			String rule_locator_options,
			String rule_changer_action,
			String rule_changer_statement,
			String rule_changer_options) {
		
		DocumentBuilderFactory docBuilderFactory = null;
		DocumentBuilder docBuilder = null;
		Document doc = null;
		
		docBuilderFactory= DocumentBuilderFactory.newInstance();
		
		try {
			docBuilder = docBuilderFactory.newDocumentBuilder();
			StringBuilder xml_string=new StringBuilder();
			for (int i=0;i<file_lines.size();i++) {
				xml_string.append(file_lines.get(i));
				if (i<file_lines.size()-1) xml_string.append(ls);
			}
			
			
			InputStream is=new ByteArrayInputStream(xml_string.toString().getBytes());
			
			doc=docBuilder.parse(is);
			mylog("Document is parsed");
		} catch(Exception e) {
			e.printStackTrace();
			mylog("Exception@replaceByXpath : " + e.getMessage());
			return false;
		}
		
		// CREATE XPATH 
		XPathFactory xpathFactory = XPathFactory.newInstance();
		XPath xpath = xpathFactory.newXPath();
		XPathExpression expr = null;
		
		try {
			try {
				expr =xpath.compile(rule_locator_statement);
			} catch(Exception e) {
				mylog("Invalid XPATH Statement : " + rule_locator_statement);
				mylog("Exception@replaceByXpath.xpath.compile XPATH   : " + rule_locator_statement);
				mylog("Exception@replaceByXpath.xpath.compile MESSAGE : " + e.getMessage());
				return false;
			}
			NodeList nodes = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);
			
			if (nodes==null) {
				mylog("Exception : nodes is null");
				return false;
			}
			
			
			
			if (rule_changer_action.equals("STOP") && nodes.getLength()>0) {
				mylog("XML XPATH matched ["+rule_locator_statement+"] ");
				return true;
			}
			
			mylog("Matched node count : " + nodes.getLength());
			
			for (int i = 0; i < nodes.getLength(); i++) {
				Node anode=nodes.item(i);
				
				String changed_rule_changer_statement=genLib.replaceAllParams(rule_changer_statement, parameters);
				String changed_rule_changer_options=genLib.replaceAllParams(rule_changer_options, parameters);
				
				switch (rule_changer_action) {
					case "UPDATE" : { 
						//anode.setNodeValue(changed_rule_changer_statement);
						anode=setNodeValue(anode,changed_rule_changer_statement);
						break;
						}
					case "ADD_ATTRIBUTE" : { 
						NamedNodeMap attrs=anode.getAttributes();
						if (attrs==null) break;
						boolean found=false;
						Node attr=null;
						for (int n=0;n<attrs.getLength();n++) {
							attr=attrs.item(n);
							
							if (attr.getNodeName().toLowerCase().equals(changed_rule_changer_statement.toLowerCase())) {
								mylog("there is already such attribute : "  + changed_rule_changer_statement);
								found=true;
								break;
							}
						}
						
						if (!found) {
							try {
								Attr newattr = doc.createAttribute(changed_rule_changer_statement);
								newattr.setNodeValue(changed_rule_changer_options);
								attrs.setNamedItem(newattr);
							} catch(Exception e) {
								e.printStackTrace();
							}
						}
						
						break; 
						}
					case "DELETE_ATTRIBUTE" : { 
						NamedNodeMap attrs=anode.getAttributes();
						if (attrs==null) break;
						boolean found=false;
						
						for (int n=0;n<attrs.getLength();n++) {
							Node nodetoremove=attrs.item(n);
							
							if (nodetoremove.getNodeName().toLowerCase().equals(changed_rule_changer_statement.toLowerCase())) {
								try {
									mylog("deleting node : " + nodetoremove.getNodeName());
									found=true;
									attrs.removeNamedItem(nodetoremove.getNodeName());
									
								} catch(Exception e) {
									mylog("Node cannot be removed  : " );
									mylog("anode.getNodeType()\t:"+nodetoremove.getNodeType());
									mylog("anode.getNodeName()\t:"+nodetoremove.getNodeName());
									mylog("anode.getNodeValue()\t:"+nodetoremove.getNodeValue());
									e.printStackTrace();
								}
							}
								
						}
						
						if (!found) mylog("No such attribute found : " + rule_changer_statement);
						break;
						}
					
					case "SET_START" : {
										//anode.setNodeValue(changed_rule_changer_statement+anode.getNodeValue()); 
										anode=setNodeValue(anode,changed_rule_changer_statement+anode.getNodeValue());
										break;
										}
					case "SET_END" : {
										//anode.setNodeValue(anode.getNodeValue()+changed_rule_changer_statement); 
										anode=setNodeValue(anode, anode.getNodeValue()+changed_rule_changer_statement);
										break; 
										}
					case "REPLACE" : {
										//anode.setNodeValue(anode.getNodeValue().replace(changed_rule_changer_statement, changed_rule_changer_options)); 
										anode=setNodeValue(anode, anode.getNodeValue().replace(changed_rule_changer_statement, changed_rule_changer_options));
										break;
										}
					case "REPLACE_ALL" : {
										//anode.setNodeValue(anode.getNodeValue().replaceAll(changed_rule_changer_statement, changed_rule_changer_options)); 
										anode=setNodeValue(anode, anode.getNodeValue().replaceAll(changed_rule_changer_statement, changed_rule_changer_options));
										break;
										}
					case "REPLACE_FIRST" : {
										//anode.setNodeValue(anode.getNodeValue().replaceFirst(changed_rule_changer_statement, changed_rule_changer_options)); 
										anode=setNodeValue(anode, anode.getNodeValue().replaceFirst(changed_rule_changer_statement, changed_rule_changer_options));
										break;
										}
					default : mylog("No such action " + rule_changer_action); 
				}
				
			}
		} catch(Exception e) {
			e.printStackTrace();
			mylog("Exception@replaceByXpath : " + e.getMessage());
			return false;
		}
		
		//*****************
		String xml_out="";
		try {
			TransformerFactory tf = TransformerFactory.newInstance();
			Transformer transformer = tf.newTransformer();
			transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
			transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
			transformer.setOutputProperty(OutputKeys.INDENT, "yes");

			StringWriter writer = new StringWriter();
			transformer.transform(new DOMSource(doc), new StreamResult(writer));
			xml_out = writer.getBuffer().toString();
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		if (xml_out.length()>0) {
			file_lines.clear();
			String[] lines=xml_out.split(ls);
			for (int i=0;i<lines.length;i++) 
				file_lines.add(lines[i]);
			
		}
		
		return true;
		
		
	}
	
	//------------------------------------
	String clearDbLine(
			StringBuilder sb,
			String CMD_END_OF_LINE,
			String CMD_COMMENT_BLOCK_START,
			String CMD_COMMENT_BLOCK_FINISH,
			String CMD_COMMENT_BLOCK_ONE_LINE) {
		
		StringBuilder ret1=new StringBuilder();
		ret1.append(sb.toString().toUpperCase().trim().replaceAll("\n|\r|\t", " "));
		
		for (int i=ret1.length()-1;i>=0;i--) {
			if (ret1.charAt(i)<32) ret1.setCharAt(i, ' ');
		}
		
		int block_comment_start_ind=ret1.indexOf(CMD_COMMENT_BLOCK_START);
		
		if (block_comment_start_ind>-1) {
			int block_comment_finish_ind=ret1.indexOf(CMD_COMMENT_BLOCK_FINISH,block_comment_start_ind);
			if (block_comment_finish_ind>block_comment_start_ind) {
				ret1.delete(block_comment_start_ind, block_comment_finish_ind+CMD_COMMENT_BLOCK_FINISH.length());
			}
		}
		
		int line_comment_ind=ret1.indexOf(CMD_COMMENT_BLOCK_ONE_LINE);
		if (line_comment_ind>-1) {
			ret1.delete(line_comment_ind, ret1.length());
		}
		
		while(true) {
			int ind=ret1.indexOf("  ");
			if (ind==-1) break;
			ret1.deleteCharAt(ind);
		}
		
		return ret1.toString();
	}
	
	//-------------------------------------
	public ArrayList<String[]> parseDatabaseFile(
			ArrayList<String[]> parameters, 
			String file_path, 
			String db_type, 
			String cmd_type
			) {
		
		
		ArrayList<String[]> ret1=new ArrayList<String[]>();
		
		mylog("parseDatabaseFile \t parseDatabaseFile:"+file_path);
		mylog("parseDatabaseFile \t db_type:"+db_type);
		mylog("parseDatabaseFile \t cmd_type:"+cmd_type);
		
		File f=new File(file_path);
		if (!f.exists()) {
			System.out.println("parseDatabaseFile !File Not Found : "+ file_path);
			mylog("parseDatabaseFile Error@replaceFile");
			mylog("parseDatabaseFile !File Not Found : "+ file_path);
			return null;
		}
		
		
		
		
		try {
			EDbVendor testVendor=EDbVendor.valueOf(db_type);
			mylog("parseDatabaseFile DB Vendor found : "+ testVendor.name());
		} catch(Exception e) {
			mylog("parseDatabaseFile !Db Vendor Not Found : "+ db_type);
			return null;
		}
		
		mylog("parseDatabaseFile File is being parsed... "+file_path);
		
		
		
		TGSqlParser sqlparser = new TGSqlParser(EDbVendor.valueOf(db_type));
		
		
		long fsize=0;
		
		try {fsize=f.length();} catch(Exception e) {fsize=0; } 
		
		if (fsize==0) {
			mylog("parseDatabaseFile File ["+file_path+"] is empty : "+ fsize);
			return ret1;
		} else if (fsize<10000) {
			String fcontent=readFile(file_path);
			fcontent=fcontent.replaceAll("\n|\r", "").trim();
			if (fcontent.length()<=5)  
				mylog("parseDatabaseFile File content is too short : "+ fcontent);
		}

		sqlparser.sqlfilename = file_path;
		
		
		int ret = sqlparser.parse();
		
		if (ret != 0){
			mylog("parseDatabaseFile Parsing Errors : ");
            ArrayList<TSyntaxError> se=sqlparser.getSyntaxErrors();
            for (int i=0;i<se.size();i++) {
            	TSyntaxError err=se.get(i);
            	mylog("parseDatabaseFile Syntax Error["+err.errorno+"]@"+err.errortype.name()+", line/col : "+err.lineNo + "/" + err.columnNo +" , "+err.hint+" near {"+err.tokentext+"}");
            }
            
            return null;
        }
		mylog("parseDatabaseFile Successfully parsed... "+file_path);
		
		mylog("parseDatabaseFile File is being splitted.");
		
		
		int part_no=0;
		StringBuilder parsedStmt=new StringBuilder();
		for (int i=0;i<sqlparser.sqlstatements.size();i++){
			part_no++;
			String padded=("00000000000000"+part_no);
			padded=padded.substring(padded.length()-4);
			String chunk_file_name=file_path+"_"+padded;
			parsedStmt.setLength(0);
			parsedStmt.append(sqlparser.sqlstatements.get(i).toString());
			
			//System.out.println("*** Writing ... " + chunk_file_name + " " + parsedStmt.toString() );
			
			write2file(chunk_file_name, parsedStmt);
			ret1.add(new String[]{
					parsedStmt.toString(), 
					sqlparser.sqlstatements.get(i).sqlstatementtype.name()
					});
			
		}
		
		mylog("parseDatabaseFile Successfully splited into "+ part_no +" pieces. ");
		
		
		return ret1;
		
	}
	
	
	
	//-----------------------------------------------------------------
	boolean checkIf(String val_to_check, String oper, String ctrl_vals) {
		// oper ========> =, !=, like, !like, in, !in,

		mylog("*** Check if ["+val_to_check+"] "+oper + " ["+ ctrl_vals+"]");
		
		if (oper.equals("=")) {
			if (val_to_check.equals(ctrl_vals))
				return true;
		}

		if (oper.equals("!=")) {
			if (!val_to_check.equals(ctrl_vals))
				return true;
		}

		if (oper.equals(">")) {
			try {
				int i_val_to_check = Integer.parseInt(val_to_check);
				int i_ctrl_vals = Integer.parseInt(ctrl_vals);
				if (i_val_to_check > i_ctrl_vals)
					return true;
			} catch (Exception e) {
				return false;
			}
		}

		if (oper.equals("<")) {
			try {
				int i_val_to_check = Integer.parseInt(val_to_check);
				int i_ctrl_vals = Integer.parseInt(ctrl_vals);
				if (i_val_to_check < i_ctrl_vals)
					return true;
			} catch (Exception e) {
				return false;
			}
		}

		if (oper.equals("isnull")) {
			if (val_to_check.length() == 0)
				return true;
		}

		if (oper.equals("notnull")) {
			if (val_to_check.length() > 0)
				return true;
		}

		if (oper.equals("like")) {
			if (val_to_check.indexOf(ctrl_vals) > -1)
				return true;
		}

		if (oper.equals("!like")) {
			if (val_to_check.indexOf(ctrl_vals) == -1)
				return true;
		}

		if (oper.equals("in")) {
			String[] ctrlArr=ctrl_vals.split(",");
			for (int i=0;i<ctrlArr.length;i++)
				if (ctrlArr[i].trim().indexOf(val_to_check) > -1)
				return true;
			return false;
		}

		if (oper.equals("!in")) {
			String[] ctrlArr=ctrl_vals.split(",");
			boolean found=false;
			for (int i=0;i<ctrlArr.length;i++)
				if (ctrlArr[i].trim().indexOf(val_to_check) > -1) {
					found=true;
					break;
				}
			return !found;
		}

		if (oper.equals("regex")) {
			return testRegex(val_to_check, ctrl_vals);
		}

		if (oper.equals("!regex")) {
			return !testRegex(val_to_check, ctrl_vals);
		}

		
		return false;

	}
		
	//---------------------------------------------------------------------
	ArrayList<String> getMatchingFileList(String filepattern, boolean includeSubdirs) {
		ArrayList<String> ret1=new ArrayList<String>();
		
		String searchdirpath="";
		String searchpattern="";
		
		int dir_last_sep=filepattern.lastIndexOf(File.separator);
		try {
			searchdirpath=filepattern.substring(0,dir_last_sep);
			searchpattern=filepattern.substring(dir_last_sep+1);
		} catch(Exception e) {
			return ret1;
		}
		
		if (searchdirpath.length()==0 || searchpattern.length()==0) return ret1;
		
		try {
			File directory=new File(searchdirpath);
			if (!directory.isDirectory()) {
				mylog(searchdirpath+" is not a directory");
				return ret1;
			}

			WildcardFileFilter wildcardfile=new WildcardFileFilter(searchpattern);
			WildcardFileFilter wildcarddir=new WildcardFileFilter("*");

			FileUtils fu=new FileUtils();
			Collection<File> col=fu.listFilesAndDirs(directory, wildcardfile, wildcarddir);
			Iterator<File> fiter=col.iterator();
			while(true) {
				
				if (!fiter.hasNext()) break;
				File f=fiter.next();
				String foundfilepath=f.getAbsolutePath();
				if(foundfilepath.equals(searchdirpath)) continue;
				//System.out.println("File Found  : " + " "+foundfilepath);
				
				if (ret1.indexOf(foundfilepath)>-1) continue;
				
				if (f.isFile()) 
					ret1.add(foundfilepath);
				
				if (f.isDirectory() && includeSubdirs) {
					String subdirsearchpattern=foundfilepath+File.separator+searchpattern;
					mylog("Searching for sub directory : "+subdirsearchpattern);
					ret1.addAll(getMatchingFileList(subdirsearchpattern,includeSubdirs));
				}
					
				
			}
			

		} catch(Exception e) {
			mylog("Directory error : "+searchdirpath);
			e.printStackTrace();
		}
		
		return ret1;
	}
	
	
}
