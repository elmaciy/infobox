use master
/

if exists (select * from sys.objects where name = 'temp_list_items' and type='SN')  drop synonym dbo.temp_list_items
/

if exists (select * from sys.objects where name = 'temp_list_items_tab' and type='u') drop table  dbo.temp_list_items_tab
/

create table [master].dbo.temp_list_items_tab
(
work_plan_no int,
list_id int,
list_item_id int,
list_val varchar(2000)
)
/

create synonym dbo.temp_list_items for dbo.temp_list_items_tab 
/


