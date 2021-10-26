
-- Wie funktioniert eigentlich ein SELECT?

	' siehe Excel-Mappe > SELECT '

USE [TSQL2012]
GO


SELECT *
FROM Production.Products		-- SCHEMA.TABLE > Filter : welche Tabelle interessant


SELECT productname				-- Filter : Spalten
FROM Production.Products
WHERE unitprice > 20			-- Filter : Datensätze

SELECT
	SUM(unitprice) AS [Umsatz]	-- Aggregation : bewerte FCT && Spalten-ALIAS
FROM Production.Products
GROUP BY supplierid				-- Gruppierung : (Teil-) Summen für [Umsatz] PRO supplierid


SELECT
	supplierid						-- GruppierungsEbene SICHTBAR
	, SUM(unitprice) AS [Umsatz]	-- Aggregation : bewerte FCT && Spalten-ALIAS
FROM Production.Products
GROUP BY supplierid					-- Gruppierung : (Teil-) Summen für [Umsatz] PRO supplierid


SELECT
	supplierid						
	, SUM(unitprice) AS [Umsatz]	-- Spalten-ALIAS ist NACH dem SELECT bekannt
FROM Production.Products
-- WHERE Umsatz > 100		; Was ist "Umsatz"? > das ist erst NACH dem SELECT bekannt
--							; Umsatz existiert NICHT in RAW DATA > WHERE filter aber Datensätze
-- WHERE SUM(unitprice) > 100 ; das wäre die GESAMT-SUMME <OHNE> Gruppierung > 100 = TRUE
--							  ; Praxis : kann ich nicht berechnen, bitte nutze HAVING
GROUP BY supplierid		
HAVING SUM(unitprice) > 100	-- Berechnung stumpf hinein-kopieren, da "Umsatz" als Name unbekannt


SELECT TOP 3			-- LIMITER = bekomme WORTWÖRTLICH "die obersten 3 Elemente"
	supplierid						
	, SUM(unitprice) AS [Umsatz]	
FROM Production.Products
GROUP BY supplierid		
HAVING SUM(unitprice) > 100	


SELECT TOP 3			-- LIMITER = bekomme WORTWÖRTLICH "die obersten 3 Elemente"
	supplierid						
	, SUM(unitprice) AS [Umsatz]	
FROM Production.Products
GROUP BY supplierid		
HAVING SUM(unitprice) > 100	
ORDER BY [Umsatz] DESC		-- "Umsatz" bekannt, weil Sortieren NACH dem SELECT stattfindet
							-- ASC ist Standard, also schreibe DESC = 1000... 1 && Z ... A

-- ############################################################################################
