package com.mayatech.datamodel;

import java.sql.Connection;
import java.util.ArrayList;


import com.mayatech.baseLibs.genLib;
import com.mayatech.dm.ddmLib;

public class dmTable {

	String table_name;
	String engine="InnoDB";
	String charset="utf8";
	
	boolean create_first=false;
	
	
	ArrayList<dmColumn> columnList=new ArrayList<dmColumn>();
	ArrayList<dmIndex> indexList=new ArrayList<dmIndex>();
	
	public dmTable(String table_name, String engine) {
		this.table_name=table_name;
		this.engine=engine;
	}
	
	//************************************************************
	
	ArrayList<String> generateInstallScript(Connection conn, String owner) {
		ArrayList<String> scriptList=new ArrayList<String>();
		

		
		String sql="";
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		


		
		
		sql="select column_name, data_type, column_default, is_nullable, extra, column_type "+
				" from information_schema.COLUMNS "+
				" where table_schema=? and table_name=? "+
				" order by ordinal_position";
		
		bindlist.clear();
		bindlist.add(new String[]{"STRING",owner});
		bindlist.add(new String[]{"STRING",table_name});
		
		ArrayList<String[]> arrColumns=ddmLib.getDbArray(conn, sql, Integer.MAX_VALUE, bindlist, 0);
		
		
		if (arrColumns.size()==0) create_first=true;
		
		if (create_first) 
			scriptList.add(generateCreateTableScript());
		
		checkDroppedColumns(arrColumns,scriptList);
		
		checkNewAndChangedColumns(arrColumns,scriptList);
		
		checkNewIndexes(conn,owner, arrColumns,scriptList);

		
		return scriptList;
	}
	
	//------------------------------------------------------------------------------
	void checkNewIndexes(Connection conn, String owner, ArrayList<String[]> arrColumns, ArrayList<String> scriptList) {
		String sql="";
		
		for (int i=0;i<indexList.size();i++) {
			dmIndex index=indexList.get(i);
			System.out.println("Checking index : "+index.index_name);
			if (!create_first) {
				sql="SHOW INDEXES FROM "+table_name+" FROM "+owner+" where Key_name='"+index.index_name+"'";
				ArrayList<String[]> arr=ddmLib.getDbArray(conn, sql, 1, null, 0);
				if (arr!=null && arr.size()==1) {
					System.out.println("index is already exists.");
					continue;
				}
			}
			
			
			scriptList.add("ALTER TABLE "+table_name+" ADD INDEX "+index.index_name+" ("+index.index_columns+") ");
		}

	}
	//------------------------------------------------------------------------------
	void checkNewAndChangedColumns(ArrayList<String[]> arrColumns, ArrayList<String> scriptList) {
		
		for (int i=0;i<columnList.size();i++) {
			dmColumn column=columnList.get(i);
			
			if (create_first && column.isPkey) continue;
			
			int col_index=-1;
			for (int c=0;c<arrColumns.size();c++) {
				String column_name=arrColumns.get(c)[0];

				if (column_name.equalsIgnoreCase(column.column_name)) {
					col_index=c;
					break;
				}
				
			}
			
			System.out.println("checking "+table_name+"."+column.column_name+"...");
			
			if (col_index==-1) {
				scriptList.add(generateColumnChangeScript(column, i-1));
				continue;
			};
			

			String data_type=arrColumns.get(col_index)[1];
			String column_default=genLib.nvl(arrColumns.get(col_index)[2], "NULL");
			String is_nullable=arrColumns.get(col_index)[3];
			String auto_increment=arrColumns.get(col_index)[4];
			String column_type_parantesis=arrColumns.get(col_index)[5];

			boolean to_alter=false;
			
			if (!data_type.equalsIgnoreCase(column.column_type))   {
				System.out.println("Data type is changed. "+data_type+"=>"+column.column_type);
				to_alter=true;
			}
			
			if (!column_default.equalsIgnoreCase(column.default_value))  {
				System.out.println("Default Value is changed. "+column_default+"=>"+column.default_value);
				to_alter=true;
			}

			if (column.column_type.equals("int") || column.column_type.equals("varchar") || column.column_type.equals("bigint")) {
				String compare_str=column.column_type+"("+column.size+")";
				if (!compare_str.equals(column_type_parantesis))  {
					System.out.println("Data Size is changed. "+column_type_parantesis+"=>"+compare_str);
					to_alter=true;
				}
			}

			/*
			boolean compare_nullable=false;
			if (is_nullable.equalsIgnoreCase("YES"))  compare_nullable=true;
			if (compare_nullable!=column.nullable) {
				System.out.println("Nullable is changed. "+compare_nullable+"=>"+column.nullable);
				to_alter=true;
			}
			 */
			
			if (column.column_name.toLowerCase().equals("id")) {
				boolean compare_auto_increment=false;
				if (auto_increment.equalsIgnoreCase("auto_increment"))  compare_auto_increment=true;
				if (compare_auto_increment!=column.auto_increment) {
					System.out.println("Auto Increment is changed. "+compare_auto_increment+"=>"+column.auto_increment);
					to_alter=true;
				}
			}

			
			if (to_alter)
				scriptList.add(generateColumnAlterScript(column));
			
			
		}

	}
	//------------------------------------------------------------------------------
	String generateColumnChangeScript(dmColumn column, int previous_col_id) {
		String ret1="ALTER TABLE "+table_name+" ADD COLUMN " +generateColumnPropertiesScript(column);
		
		if (previous_col_id>-1) {
			dmColumn prevColumn=columnList.get(previous_col_id);
			ret1=ret1 +" after "+prevColumn.column_name;
		}
		return ret1;
	}
	//------------------------------------------------------------------------------
	String generateColumnAlterScript(dmColumn column) {
		String ret1="ALTER TABLE "+table_name+" CHANGE COLUMN "+column.column_name+ " " +generateColumnPropertiesScript(column);
		return ret1; 
	}
	
	//------------------------------------------------------------------------------
	void checkDroppedColumns(ArrayList<String[]> arrColumns, ArrayList<String> scriptList) {
		
		for (int i=0;i<arrColumns.size();i++) {
			String column_name=arrColumns.get(i)[0];


			boolean to_drop=!checColExistInstallation(column_name);
			if (to_drop)  scriptList.add(generateColumnDropScript(column_name));
		}
	}
	
	
	
	//------------------------------------------------------------------------------
	boolean checColExistInstallation(String db_col_name) {
		for (int i=0;i<columnList.size();i++) 
			if (db_col_name.equalsIgnoreCase(columnList.get(i).column_name)) return true;
		
		return false;
	}
	
	
	//------------------------------------------------------------------------------
	String generateColumnPropertiesScript(dmColumn column) {
		String ret1="";
		
		ret1=ret1+"\t"+column.column_name+" "+column.column_type;
		if (column.column_type.equals("int") || column.column_type.equals("varchar") || column.column_type.equals("bigint")) 
			ret1=ret1+"("+column.size+")";
		
		if (column.nullable) ret1=ret1+" NULL "; else ret1=ret1+" NOT NULL ";
		
		if (column.auto_increment) ret1=ret1+" AUTO_INCREMENT ";
		
		if (column.default_value.equalsIgnoreCase("NULL")) ret1=ret1+" DEFAULT NULL ";
		else if (column.default_value.equalsIgnoreCase("now()") || column.default_value.equalsIgnoreCase("CURRENT_TIMESTAMP")) ret1=ret1+" DEFAULT "+column.default_value;
		else if (column.default_value!=null && column.default_value.length()>0) {
			if (
					column.column_type.equalsIgnoreCase("varchar") 
					|| column.column_type.toLowerCase().contains("text")  
					|| column.column_type.toLowerCase().contains("timestamp")
				)  ret1=ret1+" DEFAULT '"+column.default_value+"' ";
			else ret1=ret1+" DEFAULT "+column.default_value;
		}
		
		
		return ret1;
	}
	//------------------------------------------------------------------------------
	String generateColumnDropScript(String column_name) {
		String ret1="";
		
		ret1="ALTER TABLE "+table_name+" DROP COLUMN "+column_name;
		
		return ret1;
	}
	
	//------------------------------------------------------------------------------
	ArrayList<Integer> getPkIndexes() {
		ArrayList<Integer> ret1=new ArrayList<Integer>();
		
		ArrayList<Integer> pkCols=new ArrayList<Integer>();
		for (int i=0;i<columnList.size();i++) 
			if (columnList.get(i).isPkey) ret1.add(i);
		
		
		
		return ret1;
	}
	//------------------------------------------------------------------------------
	String generateCreateTableScript() {
		
		String ret1="";
		
		ArrayList<Integer> pkList=getPkIndexes();
		
		
		ret1="CREATE TABLE "+table_name+" \n(\n";
		
		if (pkList.size()>0) {
			for (int i=0;i<pkList.size();i++) {
				int pkIndex=pkList.get(i);
				dmColumn column=columnList.get(pkIndex);
				
				if (i>0) ret1=ret1+", \n";

				ret1=ret1+generateColumnPropertiesScript(column);
			
				
			}
			
			
			
			for (int i=0;i<pkList.size();i++) {
				
				int pkIndex=pkList.get(i);
				dmColumn column=columnList.get(pkIndex);
				ret1=ret1+", \n\tPRIMARY KEY ("+column.column_name+"), \n\tUNIQUE KEY id_UNIQUE ("+column.column_name+")";
				
			}
		} else if (columnList.size()>0) {
				dmColumn firstcolumn=columnList.get(0);
				ret1=ret1+generateColumnPropertiesScript(firstcolumn);
		}
		
		
		
		
		ret1=ret1+"\n)\nENGINE="+engine+" DEFAULT CHARSET="+charset;
		
		return ret1;
	}

}
