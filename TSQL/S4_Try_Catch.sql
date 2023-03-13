-- TRY CATCH

-- ERROR_SEVERITY() od 0 do 25 - stopen problemu, 0-10- jest ok , powyżej 10 jest problem, 16 tojest default, powzyej 20  duzy problem - trzeba zamknąc połączenie do DB
if OBJECT_ID('AvegareBalance','P') is not null
drop proc AvegareBalance
go
create proc AvegareBalance(@EmployeeNumberFrom int, @EmployeeNumberTo int, @AvegareBalance int OUTPUT) as 
begin	
	SET NOCOUNT ON
	declare @TotalAmount money
	declare @NumOfEmployee int
	begin try
		select @TotalAmount = sum(Amount)	from tblTransaction
		where EmployeeNum between @EmployeeNumberFrom and @EmployeeNumberTo

		select @NumOfEmployee = count(distinct EmployeeNumber) from tblEmployee
		where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo

		SET @AvegareBalance = @TotalAmount/@NumOfEmployee
		return 0
	end try
	begin catch
		SET @AvegareBalance = 0
		select ERROR_MESSAGE() as ErrorMessage, ERROR_LINE() as ErrorLine, ERROR_NUMBER() as ErrorNumber,
			   ERROR_PROCEDURE() as ErrorProcedure, ERROR_SEVERITY() as ErrorSeverity, ERROR_STATE()  as ErrorState
		return 1
	end catch
		

end

go
DECLARE @Average int
exec AvegareBalance 123,127, @Average OUTPUT
select @Average as Result
go
DECLARE @Average int
exec AvegareBalance 4,5, @Average OUTPUT
select @Average as Result
go
select * from tblTransaction where EmployeeNum between 123 and 127

--------------------------------------
-------THROW ERROR -------------------
--------------------------------------

if OBJECT_ID('AvegareBalance','P') is not null
drop proc AvegareBalance
go
create proc AvegareBalance(@EmployeeNumberFrom int, @EmployeeNumberTo int, @AvegareBalance int OUTPUT) as 
begin	
	SET NOCOUNT ON
	declare @TotalAmount money
	declare @NumOfEmployee int
	begin try
		select @TotalAmount = sum(Amount)	from tblTransaction
		where EmployeeNum between @EmployeeNumberFrom and @EmployeeNumberTo

		select @NumOfEmployee = count(distinct EmployeeNumber) from tblEmployee
		where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo

		SET @AvegareBalance = @TotalAmount/@NumOfEmployee
		return 0
	end try
	begin catch
		print('Looks like we have a problem in ' + convert(varchar(10),@EmployeeNumberFrom))
		SET @AvegareBalance = 0;
		--raiserror ('too many fnags',10,1) 
		
		if ERROR_NUMBER() = 8134
		begin
			SET @AvegareBalance = 0
			return 8134
		end
		else
			throw 56789, 'Unknow error',1 -- tej error będzie rzucony niezalzenie od tego taki będzie bład
		select ERROR_MESSAGE() as ErrorMessage, ERROR_LINE() as ErrorLine, ERROR_NUMBER() as ErrorNumber,
			   ERROR_PROCEDURE() as ErrorProcedure, ERROR_SEVERITY() as ErrorSeverity, ERROR_STATE()  as ErrorState
		return 1
	end catch
end

go
DECLARE @Average int, @ReturnStatus int
exec @ReturnStatus = AvegareBalance 4,5, @Average OUTPUT
select @Average as Result, @ReturnStatus as Status
go
--raise error
create proc AvegareBalance(@EmployeeNumberFrom int, @EmployeeNumberTo int, @AvegareBalance int OUTPUT) as 
begin	
	SET NOCOUNT ON
	declare @TotalAmount decimal(5,2)
	declare @NumOfEmployee int
	begin try
		print'employe number are from ' + convert(varchar(10), @EmployeeNumberFrom) + 'to' + convert(varchar(10), @EmployeeNumberTo)-- to laduje w message
		select @TotalAmount = sum(Amount)	from tblTransaction
		where EmployeeNum between @EmployeeNumberFrom and @EmployeeNumberTo

		select @NumOfEmployee = count(distinct EmployeeNumber) from tblEmployee
		where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo

		SET @AvegareBalance = @TotalAmount/@NumOfEmployee
		return 0
	end try
	begin catch
		SET @AvegareBalance = 0
		if ERROR_NUMBER() = 8134
		begin
			SET @AvegareBalance = 0
			return 8134
		end
		else
			declare @ErrorMessage as varchar(255)
			select @ErrorMessage = ERROR_MESSAGE()
			raiserror  (@ErrorMessage,10,1)
			--throw 56789, 'Unknow error',1
		select ERROR_MESSAGE() as ErrorMessage, ERROR_LINE() as ErrorLine, ERROR_NUMBER() as ErrorNumber,
			   ERROR_PROCEDURE() as ErrorProcedure, ERROR_SEVERITY() as ErrorSeverity, ERROR_STATE()  as ErrorState
		return 1
	end catch
		

end

