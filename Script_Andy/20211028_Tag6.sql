
USE [TSQL2012]
GO

-- Daten "auslagern"

CREATE VIEW AS ...	-- als View = wird die ABFRAGE immer wieder NEU ausgeführt, wenn ich danach frage

CREATE TABLE (...)	-- eine echte "leere" Tabelle, die DANACH mit Inhalt befüllt wird

SELECT ...			-- kannst nur <DU> sehen, niemand sonst && auch NUR in der aktuellen SITZUNG
  INTO dbo.#TEMP	-- Temporäre Tabelle > sie wird in diesem Schritt NEU in [tempDB] erstellt!
FROM ...			-- nach Schließen des REITERS = SITZUNG ist #TEMP ist WEG und kommt nicht wieder

SELECT ...			-- Antwort-Tabelle > Inhalt-Tabelle OHNE Tabellen-Definition (Constraints)
  INTO DeineMutter	-- eine NEUE Tabelle OHNE Constraints (Primary, Foreign, Check, Default,...)
FROM ...			-- Anwendungsfall : zeitlicher TRIGGER = 1x Tag für Tagesauswertung

DROP dbo.#TEMP / DROP dbo.Antwort --> ggf. bewusst Wegschmeißen

INSERT INTO <Tabelle>
	VALUES ...		-- fügt neue Elemente an eine BESTEHENDE Tabelle hinzu
					-- > SCHEMA.TABLE / #TEMP / Antwort-Tabelle 

WITH [cteTable]
AS ( SELECT ... FROM [Original] INNER JOIN [bearbeitete_KOPIE] ) -- VorTabelle, die RAM gehalten wird 
UPDATE ...
FROM [cteTable]		-- aus dieser Tabelle hole ich mir die Daten und mache damit etwas == UPDATE des Originals !


-- Aggregation je nach SERVER VERSION

			' SQL SVR 2017 EXP '		' SQL SVR 2016 ENT '		ISNULL( [Spalte] , 0 )
SUM ( 1 ; 2 ; NULL ) = 3.0					3.0 / NULL					3.0

AVG ( 1 ; 2 ; NULL ) = 1.5					NULL						1.0
MIN ( 1 ; 2 ; NULL ) = 1.0					NULL						0.0
MAX ( 1 ; 2 ; NULL ) = 2.0					NULL						2.0

											
-- GROUP ROLLUP <-> GROUPING & GROUPING_ID

SELECT 
	CUS.country
	, CUS.city
	, CUS.companyname
	, FORMAT( SUM(ODS.LineTotal) , 'C' , 'de-DE' ) AS [Umsatz]
FROM Sales.OrderDetails AS [ODS]
		INNER JOIN Sales.Orders AS [ORD] ON ODS.orderid = ORD.orderid
		INNER JOIN Sales.Customers AS [CUS] ON ORD.custid = CUS.custid
		INNER JOIN Production.Products AS [PRO] ON ODS.productid = PRO.productid
GROUP BY 	
	CUS.country, CUS.city, CUS.companyname
ORDER BY 	
	CUS.country, CUS.city, CUS.companyname


SELECT					-- [!] für ROLLUP muss auch diese Reihenfolge im SELECT stehen
	ISNULL(CUS.country, 'Gesamtumsatz') AS [country]
	, ISNULL(CUS.city, '=======') AS [city]
	, ISNULL(CUS.companyname, '') AS [companyname]
	, FORMAT( SUM(ODS.LineTotal) , 'C' , 'de-DE' ) AS [Umsatz]
FROM Sales.OrderDetails AS [ODS]
		INNER JOIN Sales.Orders AS [ORD] ON ODS.orderid = ORD.orderid
		INNER JOIN Sales.Customers AS [CUS] ON ORD.custid = CUS.custid
		INNER JOIN Production.Products AS [PRO] ON ODS.productid = PRO.productid
GROUP BY --			<<		<<		<<
	ROLLUP(CUS.country, CUS.city, CUS.companyname) -- ROLLUP > Teil-Aggregation
		-- [!] WICHTIG : Reihenfolge entscheidend über Hierarchie der Aggregation
-- ORDER BY 				<<  Teilsummen-Berechnung generiert automatisch Sortierung
--	CUS.country, CUS.city, CUS.companyname


SELECT					
	GROUPING_ID(CUS.country, CUS.city, CUS.companyname) 
	, ISNULL(CUS.country, 'Gesamtumsatz') AS [country] ,	GROUPING(CUS.country)
	, ISNULL(CUS.city, '=======') AS [city],				GROUPING(CUS.city)
	, ISNULL(CUS.companyname, '') AS [companyname],			GROUPING(CUS.companyname)
	, FORMAT( SUM(ODS.LineTotal) , 'C' , 'de-DE' ) AS [Umsatz]
FROM Sales.OrderDetails AS [ODS]
		INNER JOIN Sales.Orders AS [ORD] ON ODS.orderid = ORD.orderid
		INNER JOIN Sales.Customers AS [CUS] ON ORD.custid = CUS.custid
		INNER JOIN Production.Products AS [PRO] ON ODS.productid = PRO.productid
GROUP BY 
	ROLLUP(CUS.country, CUS.city, CUS.companyname) 


SELECT					
	ISNULL(CUS.country, 'Gesamtumsatz') AS [country] 
	, FORMAT( SUM(ODS.LineTotal) , 'C' , 'de-DE' ) AS [Umsatz]
FROM Sales.OrderDetails AS [ODS]
		INNER JOIN Sales.Orders AS [ORD] ON ODS.orderid = ORD.orderid
		INNER JOIN Sales.Customers AS [CUS] ON ORD.custid = CUS.custid
		INNER JOIN Production.Products AS [PRO] ON ODS.productid = PRO.productid
GROUP BY 
	ROLLUP(CUS.country, CUS.city, CUS.companyname) 
HAVING GROUPING(CUS.city) = 1

-- ### DATEADD-DATEDIFF-PROBLEM

SELECT GETDATE()								-- 28.10.2021 10:43:42.1234567

-- DATEDIFF ( datepart , startdate , enddate ) ; RETURN = number

	' DATE ZERO := 1900-01-01T00:00:00.0000000+01:00 '

SELECT DATEDIFF ( MONTH , 0 , GETDATE() )		-- 1461

-- DATEADD (datepart , number , date ) ; RETURN = datetime

SELECT DATEADD ( MONTH , 1461 , 0 )				-- 01.10.2021 00:00:00.000
