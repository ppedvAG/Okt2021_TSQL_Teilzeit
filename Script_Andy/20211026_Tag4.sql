
USE [TSQL2012]
GO

-- TOP 13 .. 24

-- Derived Table Expressions = DTE = abgeleiteter tabellenwertiger Ausdruck
-- > Sub-Query = Unterabfrage
-- -- > independent Sub-Query = unabhängige Unterabfrage

DECLARE @12 INT
SET @12 = 12
DECLARE @24 INT = 24
SELECT *
FROM (
	SELECT TOP (@12) *
	FROM
		  ( SELECT TOP (@24) *					
			FROM Sales.Customers		AS [SQ2]
			ORDER BY SQ2.custid ASC )	AS [SQ1] 
	ORDER BY SQ1.custid DESC )			AS [QUERY]
ORDER BY QUERY.custid ASC

-- Windowed Function : OFFSET

GO
DECLARE @page INT = 2 , @range INT = 12
SELECT *
FROM Sales.Customers
ORDER BY custid
OFFSET ((@page - 1 ) * @range) ROWS FETCH NEXT (@range) ROWS ONLY 

-- Stored Procedure

CREATE PROCEDURE dbo.Andy
	@page INT = 1 
	, @range INT = 100
AS
BEGIN
	SELECT *
	FROM Sales.Customers
	ORDER BY custid
	OFFSET ((@page - 1 ) * @range) ROWS FETCH NEXT (@range) ROWS ONLY 
END

EXEC dbo.Andy 2, 12		-- für DEVs easy, aber für SQL Admins laufzeit-technisch unschön

-- ##### WHERE > RegularExpression = MusterErkennung 

	WHERE [Spalte] LIKE '....' -- ... die ÄHNLICH sind zu ...

	-- WildCards = Platzhalter 

	%			= beliebig viele Elemente = 0 ... n 
	_			= GENAU 1 bel. Element    = 1 ... 1
	_%			= MINDESTENS 1 bel. Ele.  = 1 ... n
	_____		= GENAU 5 beliebige Elemente

	-- tatsächlicher Inhalt

	x           = an DIESER Stelle steht ein (kleines) x
	5           = an DIESER Stelle steht eine Zahl = 5

	-- Regular Expressions = Muster

	[123]		= an DIESER Stelle steht eine 1 ODER eine 2 ODER eine 3
	[^123]		= an DIESER Stelle steht 'KEIN' 1 , 2 ODER 3
					-- Version1	: dafür IRGENDETWAS anderes		<< SELTEN
					-- Version2 : dafür irgendeine andere ZAHL	>> HÄUFIG

	'IMMER'				'HÄUFIG'			'SELTEN'

	[123]				[1-3]
	[abc]									[a-c]
	[^abc]									[^a-c]
	[^123]				[^1-3]

#1	WHERE [Spalte] LIKE '[gfi]_%-12[67][89]-juhu-[^xy][abc][6-9][3-7]_'

	ga635-1268-juhu-aa73s	-- CORRECT
	georg-1279-juhu-ac98b	-- CORRECT

#2	WHERE [Country] LIKE '...' ; German , Germany , Germania

	WHERE [Country] LIKE 'German[iy]%'	-- relatives Muster
		OR [Country] = 'German'			-- exakter Wert

#3	'IDEALLÖSUNG' WHERE [Country] IN (German , Germany , Germania)
	-- Array-Lösung ist wieder EXAKTHEIT und nicht UNGEFÄHR im Muster ; Gegenereignis : NOT IN (...)

-- Kombinieren mit bisherigem Wissen

DECLARE @country NVARCHAR(10) = 'German'
....
WHERE [Country] LIKE '%' + @country + '%' -- CONTAINS-Vergleich

-- ######### CASE SELECT SWITCH

SELECT	-- Type A ; wesentlich häufiger
	CASE
#1		WHEN ... = ... THEN ...
#2		WHEN ... LIKE ... THEN ...		-- wenn [1] NICHT greift, dann teste auf [2]
		ELSE ...						-- DEFAULT-Zweig 
	END

SELECT	-- Type B ; extrem selten
	CASE
#1		WHEN ... = ... THEN ...
#2		WHEN ... LIKE ... THEN ...		-- UNABHÄNGIG davon, ob [1] greift, teste auf [2]
	END									-- ELSE funktioniert in Type B nicht

SELECT	-- Type B ; extrem selten
	CASE
#1		WHEN ... = ... THEN ... EXIT	-- falls [1] zutreffend, dann teste NICHT auf andere Zweige
#2		WHEN ... LIKE ... THEN ...		
	END									

-- #### Der NULL-Filter && das NULL-Problem

GO
SELECT *
FROM Sales.Customers
WHERE region IS NULL

-- Das NULL-Problem = USER vergisst Wert / Variable setzen und es knallt
DECLARE @region VARCHAR(5) = NULL
SELECT *
FROM Sales.Customers
WHERE region = @region
	OR ( @region IS NULL AND region IS NULL )

-- Das NULL-Problem für DEVs > gebe mir ALLES, falls USER nix einträgt
DECLARE @region VARCHAR(5) = '%'
SELECT *
FROM Sales.Customers
WHERE region LIKE @region
	OR ( @region = '%' AND region IS NULL )

' ### WARNING *** VERWECHLSUNGSGEFAHR #### '

	Vergleich IS NULL		<>		ISNULL() Funktion
			
			FUNCTION ISNULL( [Spalte] , 0 ) := immer wenn Wert in Spalte NULL, setze 0

