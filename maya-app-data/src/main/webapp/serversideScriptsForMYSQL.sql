create table IF NOT EXISTS temp_list_items 
(
work_plan_no int(11),
list_id int(11),
list_item_id int(11),
list_val varchar(2000)
)


/




DROP FUNCTION IF EXISTS maya_tdm_mask_HIDE
/


create  function maya_tdm_mask_HIDE (
	org_value  varchar(21845),
	hide_char  varchar(100),
	hide_after  varchar(100),
	hide_by_word  varchar(100)
)
	returns varchar(21845) DETERMINISTIC
begin
	
	declare ret1 varchar(21845);
	declare INT_hide_after int(10);
	
	set INT_hide_after=CAST(hide_after AS UNSIGNED);

	if (length(org_value)<=INT_hide_after) then
		return org_value;
	end if;
	
	

	set ret1=concat(SUBSTRING(org_value,1,INT_hide_after),
		repeat(hide_char,length(org_value)-INT_hide_after)
		);


	return (ret1);
	
end;
/


DROP FUNCTION IF EXISTS maya_tdm_mask_NORMALIZE
/


create  function maya_tdm_mask_NORMALIZE (org_value  varchar(21845)) 	returns varchar(21845) DETERMINISTIC
begin
	declare ret1 varchar(21845) default '';
	declare normal_chars varchar(100) default 'ABCDEFGHIJKLMNOPQRSTUWXYZ0123456789';
	declare a int default 1;
	declare len int default CHARACTER_LENGTH(org_value);
	declare loc int default 0;
	declare curr_char varchar(1) default 'x';
	declare charset1 varchar(20) default 'çÇğĞıİöÖşŞüÜ';
	declare charset2 varchar(20) default 'CCGGIIOOSSUU';
	
	if (org_value is null) then 
		return null;
	end if;
	
	if (length(org_value)=0) then 
		return org_value;
	end if;
	
	
	simple_loop : LOOP
		set curr_char=UPPER(substring(org_value,a,1));
		
		if (LOCATE(curr_char,charset1)>0) then
			set curr_char=substring(charset2,LOCATE(curr_char,charset1),1);
		end if;
		
		if (curr_char!=' ') then
			set loc=LOCATE( curr_char  ,normal_chars);
			
			if (loc=0) then
				set ret1=concat(ret1,'?');
			else
				set ret1=concat(ret1,curr_char);
			end if;
			
		end if; /*if (curr_char!=' ') then*/
		
		set a=a+1;
		
		if a>len then
			LEAVE  simple_loop;
		end if;
		
	END LOOP simple_loop;
	
	return (ret1);
end;
/


DROP FUNCTION IF EXISTS maya_tdm_mask_HASHCODE
/


create  function maya_tdm_mask_HASHCODE (org_value  varchar(21845)) 	returns int DETERMINISTIC
begin
	declare hex_value varchar(21845) default hex(WEIGHT_STRING(org_value));
	declare len int default CHARACTER_LENGTH(hex_value);
	declare ret1 int default 0;
	declare a int default 1;

	
	if (org_value is null) then 
		return null;
	end if;
	
	if (length(org_value)=0) then 
		return org_value;
	end if;
	
	
	simple_loop : LOOP
		set ret1=ret1+ASCII(UPPER(substring(hex_value,a,1)));
		set a=a+1;
		
		if a>len then
			LEAVE  simple_loop;
		end if;
		
	END LOOP simple_loop;
	
	return (ret1);
end;
/

DROP FUNCTION IF EXISTS maya_tdm_mask_FROMLIST
/

create  function maya_tdm_mask_FROMLIST (
	org_value  varchar(21845),
	work_plan_id  varchar(100),
	p_list_id  varchar(100),
	list_size  varchar(100)
)
	returns varchar(21845) DETERMINISTIC
begin
	
	declare ret1 varchar(21845) default maya_tdm_mask_NORMALIZE(org_value);
	declare INT_work_plan_id int default CAST(work_plan_id AS UNSIGNED);
	declare INT_list_id int default CAST(p_list_id AS UNSIGNED);
	declare INT_list_size int default CAST(list_size AS UNSIGNED);
	declare item_no int default 0;

	/*select abs(mod(ORA_HASH(ret1), to_number(list_size))) into item_no from dual;*/
	
	set item_no=abs(maya_tdm_mask_HASHCODE(ret1) % INT_list_size);
		
	select list_val 
	into ret1 
	from temp_list_items
	where work_plan_no=INT_work_plan_id and list_id=INT_list_id and list_item_id=item_no;

	return (ret1);
	
end;
/


DROP FUNCTION IF EXISTS maya_tdm_mask_RANDOM_NUM
/

create  function maya_tdm_mask_RANDOM_NUM (
	range1  varchar(100),
	range2  varchar(100)
)
	returns varchar(100) DETERMINISTIC
begin
	declare ret1 varchar(100) default range1;
	set ret1= Concat('',Round(Abs((CAST(range2 AS UNSIGNED)-CAST(range1 AS UNSIGNED)))*rand())+1+CAST(range1 AS UNSIGNED));
	return (ret1);
	
end;
/

DROP FUNCTION IF EXISTS maya_tdm_mask_COMPLETE
/

create  function maya_tdm_mask_COMPLETE (
	str1  varchar(21845),
	str2  varchar(21845)
)
	returns varchar(21845) DETERMINISTIC
begin
	
	declare ret1 varchar(21845) default str2;
	declare len_1 int default CHAR_LENGTH(str1);
	declare len_2 int default CHAR_LENGTH(str2);
	declare a int default len_2+1;
	
	
	simple_loop : LOOP
		set ret1=concat(ret1,substring(str1,a,1));
		set a=a+1;
		
		if a>len_1 then
			LEAVE  simple_loop;
		end if;
		
	END LOOP simple_loop;
	
	return (ret1);
	
end;
/


DROP FUNCTION IF EXISTS maya_tdm_mask_REVERSE
/

create  function maya_tdm_mask_REVERSE (
	orig_str varchar(21845)
)
	returns varchar(21845) DETERMINISTIC
begin
	declare ret1 varchar(100) default reverse(orig_str);
	declare len int default CHAR_LENGTH(orig_str);
	declare half1 int default Round(CHAR_LENGTH(orig_str)/2);
	declare half2 int default Round(CHAR_LENGTH(orig_str)/4);
	
	if (half2>2) then 
		set ret1=concat(  
		reverse(substring(ret1,1,half2)), 
		reverse(substring(ret1,half2+1,half2)), 
		reverse(substring(ret1,half2*2+1,half2)), 
		reverse(substring(ret1,half2*3+1))
		);
	end if;
	
	if (half1>2) then
		set ret1=concat(  reverse(substring(ret1,1,half1)), reverse(substring(ret1,half1+1)) );
	end if;
	
	
	
	
	
	return (reverse(ret1));
	
end;
/

DROP FUNCTION IF EXISTS maya_tdm_mask_RANDOM_STR
/

create  function maya_tdm_mask_RANDOM_STR (
	range1  varchar(21845),
	range2  varchar(21845)
)
	returns varchar(21845) DETERMINISTIC
begin
	declare ret1 varchar(21845) default '';
	declare start_1 varchar(21845) default maya_tdm_mask_NORMALIZE(range1);
	declare end_1 varchar(21845) default maya_tdm_mask_NORMALIZE(range2);
	declare cmp_result int default STRCMP(start_1,end_1);
	declare a int default 0;
	declare len int default 0;
	declare ascii_1 int default 0;
	declare ascii_2 int default 0;

	/*ilk string ikinciden kucuk degilse direk ilk string donulecek*/
	if (cmp_result=1) then
		return start_1;
	elseif (cmp_result=0) then
		return maya_tdm_mask_REVERSE(range1);
	end if;
	
	
	if CHAR_LENGTH(start_1)>CHAR_LENGTH(end_1) then
		set end_1=maya_tdm_mask_COMPLETE(start_1,end_1);
	elseif CHAR_LENGTH(start_1)<CHAR_LENGTH(end_1) then
		set start_1=maya_tdm_mask_COMPLETE(end_1,start_1);
	end if;
	
	set a=1;
	set len=CHAR_LENGTH(start_1);
	
	simple_loop : LOOP
		set ascii_1=ascii(  substring(end_1,a,1)  );
		set ascii_2=ascii(  substring(start_1,a,1)  );
		
		set ret1=Concat(ret1, Char(Round(Abs(ascii_1-ascii_2)*rand())+ascii_2)  );
		set a=a+1;
		
		if a>len then
			LEAVE  simple_loop;
		end if;
		
	END LOOP simple_loop;
	
	return ret1;
	
end;
/

DROP FUNCTION IF EXISTS maya_tdm_mask
/

create  function maya_tdm_mask (
	org_value  varchar(21845),
	mask_rule  varchar(100),
	par1  varchar(100),
	par2  varchar(100),
	par3  varchar(100),
	par4  varchar(100),
	par5  varchar(100)
)
	returns varchar(21845) DETERMINISTIC
begin
	if org_value is  null then
		return (null);
	end if;
	
	if mask_rule='FIXED' then 
		return  (par1);
	ELSEIF  mask_rule='NONE' then
		return (org_value);
	ELSEIF  mask_rule='HIDE' then 
		/* par1 : hide char, par2 : hide after, par3 : hide by word */
		return (maya_tdm_mask_HIDE(org_value, par1, par2, par3));
	ELSEIF  mask_rule='SCRAMBLE_INNER' then 
		/* par1 : range 1, par2 : range 2 */
		return maya_tdm_mask_RANDOM_STR(org_value, org_value);
	ELSEIF  mask_rule='HASHLIST' then 
		/* par1 : work plan id, par2 : FLD_SRC_LIST, par3 : LIST_ITEM_COUNT */
		return maya_tdm_mask_FROMLIST(org_value, par1, par2, par3);
	ELSEIF  mask_rule='SCRAMBLE_RANDOM' then 
		/*return maskRandomString(org_value, par1, par2);*/
		return (org_value);
	ELSEIF  mask_rule='SCRAMBLE_DATE' then 
		/*return maskDate(value);*/
		return (org_value);
	ELSEIF  mask_rule='RANDOM_NUMBER' then 
		/* par1 : range 1, par2 : range 2 */
		return maya_tdm_mask_RANDOM_NUM(org_value, par1, par2);
	ELSEIF  mask_rule='RANDOM_STRING' then 
		/* par1 : range 1, par2 : range 2 */
		return maya_tdm_mask_RANDOM_STR(par1, par2);
	ELSEIF  mask_rule='SETNULL' then 
		return (null);
	else 
		return (org_value);
	end if;
	
end;
/







