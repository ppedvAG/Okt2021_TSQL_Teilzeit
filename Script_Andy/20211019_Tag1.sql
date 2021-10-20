
/*
	Prosa ; WhiteSpace = TABULAR && ENTER = neue Zeile 
	ALT + X = ALTernative eXecute == F5 = execution
	SHIFT + Pfeiltasten = Markieren && weitere leere Zeile am ENDE
*/

-- [0.] SSMS anpassen

Tools / Extras > Optionen > Environment > International Language		-- en_US für Oberfläche 
						  > Text Editor > All Languages > LineNumbers	-- ZeilenNummern einschalten
						  > Environment > Fonts & Colours				-- ggf. Rot/Grün-Blind ; Größe

-- [1.] Wo lebe ich?

SELECT @@VERSION					-- SQL SVR 

SELECT @@LANGUAGE					-- SQL Default LANGUAGE 

SELECT * FROM sys.syslanguages		-- weitere bekannte Sprachen des SQL SVR

SELECT GETDATE()					-- Zeit auf WINDOWS SVR
SELECT SYSDATETIME()				-- Zeit im SQL SVR, der auf dem WINDOWS SVR läuft

-- [2.] Wie lebe ich?

-- MASTER
> Config des SVR in 'KOPIE'
> MetaDaten der Struktur
> MetaDaten ALLER Datenbanken 
> Sicherheit auf SVR Ebene

-- msDB
> MetaDaten für BACKUP :: 1x Woche
> Config für verteilte Systeme = CLUSTER 
> 'Sicherheit auf der jew. DB-Ebene' >> wer darf ... auf DIESER Datenbank
> SCHEMABINDING :: PersonA darf, PersonB darf nicht > weil das SCHEMA das so will
>>	SCHEMA.TABLE = wird bei 'ERSTELLUNG' der Tabelle initial festgelegt ; Ändern? Siehe unten.

-- tempDB
> ' Kopie ALLER in VERWENDUNG befindlicher BENAMTER Objekte '
> tempDB 1:1 im RAM halten im SVR && RESULT 1:1 im RAM des PCs  
> SQL SVR ist tendentiell FAUL :: so viel wie nötig, so wenig wie möglich
>> ORDER BY findet auf DEINEM PC statt und damit in DEINEM RAM

-- DistributionDB
> Config für CLUSTER 

-- modelDB
> Rohlinge zum Erstellen NEUER BENAMTER Objekte

-- ReportServer / ReportServerTempDB
> SSRS = SQL SVR Reporting Service 

-- DW... = DataWareHouse
> Oracle-DB / SAP / OLAP /... = Tabular Data Warehouse = [ Table => Business Intelligence (Report) 

-- [3.] Sauberes TSQL = Transact SQL { SELECT ; INSERT ; UPDATE ; DELETE ; CREATE ; DROP ;... }

	>> TABULATOR && new LINE
	>> saubere [Benamung] && eine TYPE-Setzung

-- [3.1] GO ist Dein Freund

GO		-- beginne hier TSQL neu zu interpretieren
USE [Northwind]
GO		-- STOPP, falls NICHT erfolgreich

SELECT * FROM Customers		-- OK, aber das Gegenteil von GUTEM Stil

SELECT CustomerID
FROM Customers		-- dbo = DataBaseObject = Default SCHEMA, wenn keines angegeben wird
					-- bei dbo nicht notwendig, aber kein guter Stil!

SELECT CustomerID
FROM dbo.Customers	-- VOLL-QUALIFIZIERT = SCHEMA.TABLE entsteht automatisch EINDEUTIGKEIT


SELECT 
	CustomerID		-- neue Zeile führt zu besserer Lesbarkeit
	, Country		-- Komma am Anfang ist besser für spätere Auskommentierung
FROM dbo.Customers ;	--< Delimiter : Info an den Prä-Prozessor, dass das Statement hier zu Ende ist
GO	--< Delimiter : STOPP ; falls Security / ... nein sagt, dann (etwas) ausführlichere ERROR-Message

-- Alternativ-Beispiel

USE [TSQL2012]
GO

SELECT *
FROM Sales.Customers	-- im SCHEMA "Sales" die Tabelle "Customers" aufrufen

-- [3.2.] Benamung

	ä ü ö ß / ? * _ % ( ) [ ] Punkt Leerzeichen > ASCII benutzen , kein UTF-8 ; Käufer = K[]ufer
		> ich bins = [ich bins] = ich%20bins = ich%C3%20bins = ich_x0020_bins 

	Funktionsbezeichnungen 'NICHT' benutzen
		> Alter versus [Alter] = FUNCTION versus [Benamung] = bitte nicht benutzen!
		> Create Table Demo Table versus [Demo Table] versus DemoTable 

	' Nomenklatur ; Camel Case / Pascal Case = DemoTable , txtDocName '

	Server > Rechtklick > Properties > Server COLLATION = Latin1_General_CI_AS
		>	Latin1	 =  Lateinisch (ASCII) &&  AlphaNumerische Grundsortierung
		>	General  =  Allgemeine Sortierungs- und Funktionseinstellungen 
		>	CI		 =  Case Insensitive = Groß- / Kleinschreibung 'uninteressant' 
		>	AS		 =  Accent Sensitive = a ä à á â ... 'interessiert' sehr wohl

	'M[]use' ASCII  <>  N'Mäuse' UTF-8 :: für Datensätze OK, falls CULTURE = de-DE

-- [3.3] Passender Type für Spalten

				[Nachname]
CHAR(10)		'Krause....'	+ TRIM() + LEN() + RIGHT() + LEFT()
VARCHAR(10)		'Krause'

UPDATE [Nachname]

CHAR(10)		'Bergmann..'
VARCHAR(10)		'Bergma'	+ Appendix_1 (Extend)
...
..
.
Appendix_1		'nn'		-- 1 Speicherseite = 8kB ; 1 Speicherblock = 8 Speicherseiten = 64kB

CHAR(10)		'Krause....'	= 10 Byte
NCHAR(10)		'Krause....'	= 10 Byte CONTENT + 10 Byte UTF-8

NCHAR(10)		'Kräußel...'
NVARCHAR(10)	'Kräußel'

-- Normalform meiner Datenbank

	' siehe Excel-Mappe > Normalform '

	> was brauche ich wie oft und wie viel wovon? (Normalform)
	> wonach frage ich häufig? (Struktur = JOIN)
	> wie granular brauche ich eine Info wirklich / regelmäßig? (UPDATE)
	> CALCULATED COLUMN = UPDATE ggf. notwendig! (Gesamt-Bestellsumme) 
	> UPDATE >> COLUMN TYPE :: wie häufig ändert es sich? ([Nachname] von oben)

-- ### Ende Tag 1
