package tdm.deployment;
import java.sql.Connection;
import java.util.ArrayList;


public class oracleConverter {
 
	public String getOracleTableStructure(Connection connApp, String object_owner, String object_name) {
		
		commonLib cLib=new commonLib();
		
		StringBuilder sb=new StringBuilder();
		
		ArrayList<String[]> bindlist=new ArrayList<String[]>();
		String sql="";
		
		
		sql="select \n"+
				" owner, \n"+
				" table_name, \n"+
				" pct_used, \n"+
				" ini_trans, \n"+
				" max_trans, \n"+
				" pct_increase, \n" + 
				" logging, \n"+
				" cache, \n"+
				" table_lock, \n"+
				" partitioned, \n" +
				" iot_type, \n"+
				" temporary, \n"+
				" secondary, \n"+
				" nested, \n" + 
				" row_movement, \n"+
				" global_stats, \n"+
				" user_stats, \n"+
				" skip_corrupt, \n" + 
				" monitoring, \n"+
				" cluster_owner, \n"+
				" dependencies, \n" + 
				" compression, \n"+
				" compress_for, \n"+
				" dropped, \n"+
				" read_only, \n" + 
				" segment_created, \n"+
				" (select comments from ALL_TAB_COMMENTS where owner=t.owner and table_name=t.table_name)  table_comments \n" + 
				" FROM dba_tables t \n"+
				" where owner=? and table_name=? ";
			
			
			bindlist.clear();
			bindlist.add(new String[]{"STRING",object_owner});
			bindlist.add(new String[]{"STRING",object_name});
			
			ArrayList<String> colNamesForTable=new ArrayList<String>();
			ArrayList<String[]> arrTable=cLib.getDbArrayApp(connApp, sql, 1, bindlist, colNamesForTable);
			
			
			sql="select \n"+
					" segment_subtype, \n"+
					" tablespace_name, \n"+
					" header_file, \n"+
					" header_block, \n"+
					" bytes, \n"+
					" blocks, \n" + 
					" extents, \n"+
					" initial_extent, \n"+
					" next_extent, \n"+
					" min_extents, \n"+
					" max_size, \n"+
					" retention, \n"+
					" minretention, \n" + 
					" pct_increase, \n"+
					" freelists, \n"+
					" freelist_groups, \n"+
					" relative_fno, \n" + 
					" buffer_pool, \n"+
					" flash_cache, \n"+
					" cell_flash_cache \n" +
					" FROM dba_segments \n"+
					" where owner=? and segment_name=? and segment_type='TABLE' ";
				
				
				bindlist.clear();
				bindlist.add(new String[]{"STRING",object_owner});
				bindlist.add(new String[]{"STRING",object_name});
				
				ArrayList<String> colNamesForTableSegment=new ArrayList<String>();
				ArrayList<String[]> arrTableSegment=cLib.getDbArrayApp(connApp, sql, 1, bindlist, colNamesForTableSegment);
				
			sql="select \n"+
					" c.*, \n" +
					" (select comments from ALL_COL_COMMENTS where owner=c.owner and table_name=c.table_name and column_name=c.column_name) column_comments \n" + 
					" FROM all_tab_columns c \n"+
					" where owner=? and table_name=?  order by column_id";
				
				
				bindlist.clear();
				bindlist.add(new String[]{"STRING",object_owner});
				bindlist.add(new String[]{"STRING",object_name});
				
				ArrayList<String> colNamesForColumns=new ArrayList<String>();
				ArrayList<String[]> arrTableColumns=cLib.getDbArrayApp(connApp, sql, Integer.MAX_VALUE, bindlist, colNamesForColumns);
				
					
				sql="select \n"+
					" * \n" +
					" FROM DBA_TAB_PARTITIONS \n"+
					" where table_owner=? and table_name=? order by PARTITION_POSITION ";
				
				
				bindlist.clear();
				bindlist.add(new String[]{"STRING",object_owner});
				bindlist.add(new String[]{"STRING",object_name});
				
				
				
				ArrayList<String> colNamesForPartition=new ArrayList<String>();
				ArrayList<String[]> arrPartition=cLib.getDbArrayApp(connApp, sql, Integer.MAX_VALUE, bindlist, colNamesForPartition);
				

			if (arrTable==null || arrTable.size()==0) return sb.toString();
			
			

			sb.append("<object>\n");
			sb.append(" <table>\n");
			
			
			sb.append("   <table_header>\n");
			for (int c=0;c<colNamesForTable.size();c++) {
				String col_name=colNamesForTable.get(c);
				String col_val=arrTable.get(0)[c].trim();
				sb.append("    <"+col_name+">");
				sb.append(col_val);
				sb.append("</"+col_name+">\n");
			}
			sb.append("   </table_header>\n");
			
			sb.append("   <table_columns>\n");
			
			sb.append("    <column_count>"+arrTableColumns.size()+"</column_count>\n");
			
			for (int i=0;i<arrTableColumns.size();i++) {
				
				sb.append("     <table_column>\n");
				sb.append("        <column_id>"+i+"</column_id>\n");
				
				for (int c=0;c<colNamesForColumns.size();c++) {
					String col_name=colNamesForColumns.get(c);
					String col_val=arrTableColumns.get(i)[c].trim();
					sb.append("        <"+col_name+">");
					sb.append(col_val);
					sb.append("</"+col_name+">\n");
				}
				sb.append("     </table_column>\n");
			}
			sb.append("   </table_columns>\n");
			
			
			if (arrPartition.size()==0) {
				sb.append("   <table_segment_info>\n");
				for (int c=0;c<colNamesForTableSegment.size();c++) {
					String col_name=colNamesForTableSegment.get(c);
					String col_val=arrTableSegment.get(0)[c].trim();
					sb.append("      <"+col_name+">");
					sb.append(col_val);
					sb.append("</"+col_name+">\n");
				}
				sb.append("   </table_segment_info>\n");
			}
			else {
				
			
				sb.append("   <table_partitions>\n");
				sb.append("    <partition_count>"+arrPartition.size()+"</partition_count>\n");
				for (int i=0;i<arrPartition.size();i++) {
					
					sb.append("     <table_partition>\n");
					sb.append("        <partition_id>"+i+"</partition_id>\n");
					
					for (int c=0;c<arrPartition.size();c++) {
						String col_name=colNamesForPartition.get(c);
						String col_val=arrPartition.get(i)[c].trim();
						sb.append("        <"+col_name+">");
						sb.append(col_val);
						sb.append("</"+col_name+">\n");
					}
					
					sb.append("     </table_partition>\n");
				}
				sb.append("   </table_partitions>\n");
				
			}

			sb.append("  </table>\n");
			sb.append("</objectz>");
		
		
		return sb.toString();
	}
}
