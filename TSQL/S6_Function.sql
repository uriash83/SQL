

--------------------------------------
--------- Scalar function ------------
--------------------------------------
-- fukcja skalarna zwraca 1 wartosc 

CREATE FUNCTION AmoumntPlusOne(@Amount smallmoney)
RETURNS smallmoney
AS
BEGIN

    RETURN @Amount + 1

END
go

select DateOfTransaction, Amount, EmployeeNum , dbo.AmoumntPlusOne(Amount) as Amount
from tblTransaction

-- funcje sa podobne do procedur ale 
-- funkcje mozemy uzywac w SELECT a procedury nie


--- more complicatd function 
if object_ID(N'NumberOfTransaction',N'FN') is not null
	drop function NumberOfTransaction
select * from sys.objects where type = 'FN'
go
CREATE FUNCTION NumberOfTransaction(@EmployeeNumber int)
RETURNS int
AS
BEGIN

    DECLARE @NumberOfTransactions INT
	SELECT @NumberOfTransactions = COUNT(*) FROM tblTransaction
	WHERE EmployeeNum = @EmployeeNumber
	RETURN @NumberOfTransactions
END
go


---  inline table function
select * from sys.objects order by name asc
if object_ID(N'TransactionList',N'IF') is not null
	drop function TransactionList
go
CREATE FUNCTION TransactionList ( @EmployeeNumber int )
RETURNS TABLE AS RETURN
(
    SELECT * FROM tblTransaction
	WHERE EmployeeNum = @EmployeeNumber
)
go
select * from dbo.TransactionList(123)

select * from tblEmployee 
where exists ( select * from dbo.TransactionList(EmployeeNumber)) -- czyli z tego select przekazuje EmplyeeNumber do TransactionList(), jesli nie ma to nie Transactiolist ngo nie pokaze 
order by EmployeeNumber

select * from tblEmployee as E
left join tblTransaction as T
on T.EmployeeNum = E.EmployeeNumber
where EmployeeNumber = 123


---- mulit function table function -----
if object_ID(N'TransList',N'IF') is not null
	drop function TransList
go
CREATE FUNCTION TransList(@EmployeeNumber int )
RETURNS @TransList TABLE 
(
	Amount smallmoney,
	DateOfTransaction smalldatetime,
	EmployeeNum int
)
AS
BEGIN
    INSERT INTO @TransList(Amount,DateOfTransaction,EmployeeNum)
	SELECT Amount,DateOfTransaction,EmployeeNum from tblTransaction
	where EmployeeNum = @EmployeeNumber
	RETURN 
END
go

------------ APPLYT ---------------
