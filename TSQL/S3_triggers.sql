use [70-461]
-- blokowanie message np. 1 row affected
SET NOCOUNT ON
SELECT * FROM tblDepartment
SET NOCOUNT OFF

-- przyklad triggera
-- Inserted i Delted to tabele w Triggerze
-- trigger AFTER moze byc na kilku , np jak niżej
-- AFTER = FOR
go
CREATE TRIGGER tr_tblDepartment
    ON tblDepartment
    AFTER DELETE, INSERT, UPDATE
    AS
    BEGIN
    SELECT * FROM inserted
	SELECT * FROM deleted
    END
go
-- trigger INSTEAD OF moze byc tylko na jednym alboDELET albo INSERT
-- @EmployeeNum = EmployeeNum - to jest inny sposob na przypisanie zmienehj
-- a ten select select @EmployeeNum = EmployeeNum,.... ma tylko za zadanie przypisanie zmiennej a nie wysiwtlenie

select * from ViewByDepartment
use [70-461]
go
CREATE TRIGGER tr_ViewByDepartment
	ON dbo.[ViewByDepartment]
    INSTEAD OF DELETE
    AS
    BEGIN
		SELECT *,'ViewByDepartment' from deleted -- wykonujac delete from ViewByDepartment przekazujemy dane do triggera ( ale go nie usuwa)
	END
go

begin tran 
SELECT * FROM ViewByDepartment WHERE  EmployeeNum = 132 and TotalAmount = 999.99
delete from ViewByDepartment WHERE TotalAmount = -2.77 AND EmployeeNum = 132

begin tran 
delete from ViewByDepartment where EmployeeNum = 129 and DateOfTransaction = '2015-05-09'
rollback tran

SELECT * FROM ViewByDepartment WHERE TotalAmount = -2.77 AND EmployeeNum = 132
rollback tran 

--drop trigger tr_ViewByDepartmentOnce
go
ALTER TRIGGER tr_ViewByDepartment
    ON [ViewByDepartment]
    INSTEAD OF DELETE
    AS
    BEGIN
	select 1
    declare @EmployeeNum as int
	declare @TotalAmount as smallmoney
	declare @DateOfTransaction as smalldatetime
	select @EmployeeNum = EmployeeNum, @TotalAmount = TotalAmount, @DateOfTransaction = DateOfTransaction from deleted
	select *,'deleted' from deleted
	delete tblTransaction from tblTransaction as T
	where T.Amount = @TotalAmount and T.DateOfTransaction = @DateOfTransaction and T.EmployeeNum = @EmployeeNum

    END

go


go
ALTER TRIGGER [dbo].[tr_tblTransaction]
    ON [dbo].[tblTransaction]
    AFTER DELETE, INSERT, UPDATE
    AS
    BEGIN
		--if @@NESTLEVEL = 1
			BEGIN
				SELECT @@NESTLEVEL as NestLevel
				SELECT *,'TABLEINSERTED' FROM inserted -- pojawi dodatkowa pusta kolumna TABLEINSERTED
				SELECT *,'TABLEDELETED' FROM deleted
				--select 'hello'
			END
    END
go

begin tran 
--insert into tblTransaction (Amount,DateOfTransaction,EmployeeNum) values ( 123,'2023-02-02',123)
delete from ViewByDepartment where EmployeeNum = 131 and DateOfTransaction = '2015-04-21'
rollback tran

-- maxymalnie zagniezdzenie to 32
-- ograniczenie nested trigger do 0
exec sp_configure 'nested_triggers',0;
reconfigure
go


-- ROWCOUNT 
-- jesli w wyniku bedzie 0 ow affected to nic nie wyswietli

ALTER TRIGGER [dbo].[tr_tblTransaction]
    ON [dbo].[tblTransaction]
    AFTER DELETE, INSERT, UPDATE
    AS
    BEGIN
		if @@ROWCOUNT > 0
			--if update(DateOfTransaction) -- czy byl  update DateOftransaction
			if COLUMNS_UPDATED() & 2 = 2 -- 1,2,4,8,16
				BEGIN
					SELECT *,'TABLEINSERTED' FROM inserted
					SELECT *,'TABLEDELETED' FROM deleted
					--select 'hello'
				END
    END
go
-- multiple rows in session
go
ALTER TRIGGER tr_ViewByDepartment
    ON [ViewByDepartment]
    INSTEAD OF DELETE
    AS
		BEGIN
		select * , 'To be deleted' from deleted
		delete tblTransaction from tblTransaction as T
		join deleted as D
		on 
		T.EmployeeNum = D.EmployeeNum and 
		T.Amount = D.TotalAmount and
		T.DateOfTransaction = D.DateOfTransaction

		END

go

begin tran
select *,'Before Delete' from ViewByDepartment where EmployeeNum = 132
delete from ViewByDepartment where EmployeeNum = 132 --and TotalAmount = 861.16
select *,'After Delete' from ViewByDepartment where EmployeeNum = 132
rollback tran


