

--*************************
--Administer jobs and alerts
--*************************


-- lista jobow
use msdb
select* from sysjobs

--
select * from syssessions

--
select * from sysjobactivity

--
select * from sysjobhistory

select * from sysschedules


--*************************
-- RAISERROR
--*************************

select count(language_id) as leng  from sys.messages 
group by language_id

select * from sys.messages

exec sp_addmessage 50001,16,'I am rising message'

RAISERROR (50001,16,1) WITH LOG



