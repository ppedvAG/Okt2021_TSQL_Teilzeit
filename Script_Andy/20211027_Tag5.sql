
USE [TSQL2012]
GO

-- ### JOIN

SELECT	* 
FROM	leftTable AS lt		-- benutze Tabellen-ALIAS > JOIN schneller / kompakter zu schreiben!
		(INNER / LEFT [OUTER] / RIGHT [OUTER] / FULL [OUTER]) JOIN rightTable AS rt ON lt.IDCol = rt.IDCol

-- ### Beispiel für INNER JOIN :: Schlachtordnung im Bau von JOINs

-- [0.] Wissen ums Terrain

[0.] Wie funktioniert eigentlich ein JOIN? > ' siehe Excel-Mappe : JOIN '

[1.] Database DIAGRAMs > Tabellen && Beziehungen && Properties
[2.] Tabelle > Rechtsklick > Script > CREATE TO > New Window = Tabellen-Konstruktor 
[3.] Database DIAGRAMs > relevanten Tabellen > Markiere > Namen einer Tabelle > Rechtsklick > VIEW : KEYS

-- [1.] ZIEL : gebe mir die Kunden und deren Bestellungen (Produkte) mit Bestell-Infos

0091	Customers		Sales		CUS		custid						| companyname, city, country
0830	Orders			Sales		ORD		custid	orderid				| orderdate
#2155	OrderDetails	Sales		ODS				orderid		prodid	| unitprice
0077	Products		Production	PRO							prodid	| unitprice, productname

GO
SELECT * FROM Sales.OrderDetails

-- [2.] Marschrichtung 

-- Wo fange ich an?

[1.] Verknüpfungstabelle > Ort der effektivsten Filterung 
[2.] Der maximal Bietende > größte "Haufen" zuerst

-- Wie mache ich weiter?

[3.] Bleibe im jeweiligen SCHEMA > in SECURITY später "umschalten"
[4.] baue so viel LEFT JOIN wie möglich, da RIGHT JOIN > LEFT JOIN umgewandet wird

	' ODS > ORD > CUS > PRO '

-- SQL Entscheidung > nicht nötig für EIGENE Betrachtung

[5.] SVR "darf" davon abweichen, wenn es 'günstiger' ist, es in einer 'anderen' Reihenfolge zu machen

	' ODS > PRO && ODS > ORD > CUS '

-- [3.] TUE ES!

0091	Customers		Sales		CUS		custid						| companyname, city, country
0830	Orders			Sales		ORD		custid	orderid				| orderdate = 2007
#2155	OrderDetails	Sales		ODS				orderid		prodid	| unitprice
0077	Products		Production	PRO							prodid	| unitprice, productname


CREATE VIEW Sales.[vFJ2007Umsatz]
AS
SELECT 
	CUS.companyname
	, CUS.city
	, CUS.country
	, ORD.orderdate
	, FORMAT( ODS.unitprice , 'C' , 'de-DE' ) AS [VKP]
	, FORMAT( PRO.unitprice , 'C' , 'en-GB' ) AS [EKP]
	, FORMAT( (PRO.unitprice - ODS.unitprice) , 'C' , 'en-US') AS [GEW]
	, PRO.productname
FROM Sales.OrderDetails AS [ODS]
		INNER JOIN Sales.Orders AS [ORD] ON ODS.orderid = ORD.orderid
		INNER JOIN Sales.Customers AS [CUS] ON ORD.custid = CUS.custid
		INNER JOIN Production.Products AS [PRO] ON ODS.productid = PRO.productid
WHERE ORD.orderdate BETWEEN '20070101' AND '20071231'		-- ISO-DATE : yyyymmdd
-- ORDER BY [GEW] DESC ; nicht erlaubt, "unless TOP, OFFSET or FOR XML" 

SELECT * FROM Sales.vFJ2007Umsatz
ORDER BY [GEW] DESC