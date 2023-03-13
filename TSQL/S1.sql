-- deklaracja zmiennej
DECLARE @myval as int = 9;

--ustawienie zmiennej
SET @myval = @myval * 12;

SELECT @myval AS variable;
-----------
-- MATH ---
-----------
SELECT POWER(@myval,3)
SELECT SQUARE(@myval)
SELECT SQRT(@myval)

GO

DECLARE @myval as decimal(5,2) = -3.67

SELECT FLOOR(@myval)
SELECT CEILING(@myval)
SELECT ROUND(@myval,2)

GO

SELECT PI() AS myPI
SELECT EXP(2) AS E

DECLARE @myval as numeric(7,2) =0

select ABS(@myval) as myabs, SIGN(@myval) as myval

GO

SELECT RAND(3)
-----------
-- CONVERT-
-----------



