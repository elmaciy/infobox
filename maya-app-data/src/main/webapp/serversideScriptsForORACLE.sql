drop public synonym temp_list_items
/

drop table temp_list_items
/

create table temp_list_items 
(
work_plan_no number(10),
list_id number(10),
list_item_id number(10),
list_val varchar2(2000)
)
/

create public synonym temp_list_items for temp_list_items
/

grant all on temp_list_items to public
/


drop public synonym maya_tdm_mask
/

create or replace function maya_tdm_mask
	(
	value in varchar2,
	mask_rule in varchar2,
	par1 in varchar2,
	par2 in varchar2,
	par3 in varchar2,
	par4 in varchar2,
	par5 in varchar2)
	return varchar2 as 
	
	--***************************************
	function maskHide(str1 in varchar2, hide_char in varchar2, hide_after in varchar2, hide_by_word in varchar2) return varchar2 is 
	after_char number(3);
	begin
		after_char:=to_number(hide_after);
		
		
		if length(str1)<=after_char then
			return str1;
		end if;
		
		--if hide_by_word='NO' then
			declare
			temp varchar2(4096);
			begin
			temp:=rpad(substr(str1,0, after_char),length(str1)-after_char, hide_char);
			return temp;
			end;
		--end if;
		
	exception 
	when others then 
		return str1;
	end;
	
	
	--***************************************
	function maskRandomNumber(str1 in varchar2, from_num in varchar2,to_num in varchar2) return varchar2 is 
	num1 number;
	num2 number;
	begin
	
		num1:=to_number(from_num);
		num2:=to_number(to_num);
		
		return ''||round(dbms_random.value(num1, num2));
		
	exception 
	when others then 
		return str1;
	end;
	--***************************************
	function maskRandomString(str1 in varchar2, from_str in varchar2,to_str in varchar2) return varchar2 is 
	begin
	
		
		return ''||dbms_random.string('x', length(from_str));
		
	exception 
	when others then 
		return str1;
	end;
	
	--***************************************
	function maskScrambleInner(str1 in varchar2) return varchar2 is 
	begin		
		return maskRandomString(str1,str1,str1);
	exception 
	when others then 
		return str1;
	end;
	

	--***************************************
	function replaceChar(str1 in varchar2) return varchar2 is 
	charset1 varchar2(1000):='çÇğĞıİöÖşŞüÜ';
	charset2 varchar2(1000):='CCGGIIOOSSUU';
	begin
		if INSTR(charset1,str1)>0 then
			return substr(charset2, INSTR(charset1,str1),1);
		else
			return str1;
		end if;
		
		exception when others then return str1;
	end;
	
	--***************************************
	function normalize(str1 in varchar2) return varchar2 is 
	normalized_value varchar(4096);
	normalized_charset varchar2(200):='ABCDEFGHIJKLMNOPQRSTUWXYZ0123456789';
	begin
		
		for x in 1..length(str1)
		loop
			if INSTR(normalized_charset, replaceChar( upper(substr(str1,x,1) ) ) )>0 then
				
				normalized_value:=normalized_value||replaceChar( upper(substr(str1,x,1) ) )	;
				
			else
				normalized_value:=normalized_value|| '?';
			end if;
		end loop;
		
		return normalized_value;
	exception 
	when others then 
		return str1;
	end;
	
	--***************************************
	function maskList(str1 in varchar2, p_work_plan_id in varchar2, p_list_id in varchar2, list_size in varchar2) return varchar2 is 
	work_plan_id number;
	item_no number;
	ret1 varchar2(4096);
	begin
			ret1:=normalize(str1);
			work_plan_id:=to_number(p_work_plan_id);
			select abs(mod(ORA_HASH(ret1), to_number(list_size))) into item_no from dual;
			select list_val into ret1 from temp_list_items where work_plan_no=to_number(p_work_plan_id) and list_id=to_number(p_list_id) and list_item_id=item_no;
			return ret1;
	exception 
	when others then 
		return str1;
	end;
	
	
	--***************************************
	function maskDate(str1 in varchar2) return varchar2 is 
	ret1 varchar2(25);
	begin
			select to_char(
						to_date(
							to_char(round(dbms_random.value(1,28)))||'.'||to_char(round(dbms_random.value(1,12)))||'.'||to_char(round(dbms_random.value(1970,to_number(to_char(sysdate,'YYYY'))))), 
							'dd.mm.yyyy'),
						'dd.mm.yyyy hh24:mi:ss'
							) into ret1 from dual;
			return ret1;
	exception 
	when others then 
		return str1;
	end;
	
	--***************************************

		

begin
	
	if value is  null then
		return null;
	end if;
	
	if mask_rule='FIXED' then 
		return  par1;
	elsif mask_rule='NONE' then
		return value;
	elsif mask_rule='HIDE' then 
		return maskHide(value, hide_char=>par1, hide_after=>par2, hide_by_word=>par3);
	elsif mask_rule='SCRAMBLE_INNER' then 
		return maskScrambleInner(value);
	elsif mask_rule='HASHLIST' then 
		return maskList(value, par1, par2, par3);
	elsif mask_rule='SCRAMBLE_RANDOM' then 
		return maskRandomString(value, par1, par2);
	elsif mask_rule='SCRAMBLE_DATE' then 
		return maskDate(value);	
	elsif mask_rule='RANDOM_NUMBER' then 
		return maskRandomNumber(value, par1, par2);
	elsif mask_rule='RANDOM_STRING' then 
		return maskRandomString(value, par1, par2);
	elsif mask_rule='SETNULL' then 
		return null;
	else 
		return value;
	end if;
		
	
exception 
when others then 
 return value;
end;

/



create public synonym maya_tdm_mask for maya_tdm_mask
/

grant all on maya_tdm_mask to public
/




