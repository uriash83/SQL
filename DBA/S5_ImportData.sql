--task -> import Data
-- importtuje plik jako osobna tabele
use AdventureWorks2014
select * from [dbo].[New Text Document]

-- task -> export Data

--- bulk import


use [AdventureWorks2014]
select * from  dbo.FlatFile3

bulk insert dbo.FlatFile3
from 'C:\Users\IEUser\Desktop\NewTextDocument.txt'
with
(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
)