
-- [4.] Tabellen-Definition verstehen

	Schauspieler > FOREIGN > Person 
	HR.Person { pk_PersonID ; forName ; surName }	::	Fact
	HR.Actor  { pk_ActorID  ; fk_PersonID }			::	Dimension

-- MASTER anmelden

USE [master]
GO

-- Datenbank anlegen

CREATE DATABASE [Hollywood]
GO

-- HR-Schema anlegen

USE Hollywood
GO

CREATE SCHEMA [HR] AUTHORIZATION [dbo] -- dbo ist SCHEMA im [master]
GO

-- Tabelle anlegen 

	-- INT (0) 1 ... 5.6 * 10^10 ; smallint ; bigint ; number + ROUND()

CREATE TABLE HR.[Person] (
	PersonID	INTEGER IDENTITY(1,1)	-- selbst�ndig hochz�hlen
		CONSTRAINT [pkPersonID] PRIMARY KEY	-- Primary Key Constraint f�r Naming
		NONCLUSTERED		-- nicht zwingend auch in dieser Reihenfolge auf HDD
	, Forename  NVARCHAR(30)	-- tendentiell wenig Ver�nderung
	, Surname	NCHAR(30)		-- potentiell Ver�nderung erwartbar
)
GO

CREATE TABLE HR.[Actor] (
	ActorID	INTEGER IDENTITY(1,1)	-- selbst�ndig hochz�hlen
		CONSTRAINT [pkActorID] PRIMARY KEY	-- Primary Key Constraint f�r Naming
		NONCLUSTERED		-- nicht zwingend auch in dieser Reihenfolge auf HDD
	, PersonID INTEGER	-- TYPE identisch w�hlen > weniger Aufwand beim JOIN
		CONSTRAINT [fkActorPerson] FOREIGN KEY	-- Foreign Key Constraint f�r Naming
		REFERENCES HR.Person(PersonID)		-- FK-Referenz
)
GO

	' CTRL + SHIFT + R = Refresh MetaData f�r Intellicence '

-- Das ist ein TRAUM... warum?!

	Diagramm-Darstellung : PK, FK, REL, TYPE, ... 

-- Kann ich das nachtr�glich �ndern? 

	Tabelle > Rechtsklick > Designer : �nderungen umsetzen
		Freier Bereich > Rechtsklick > �nderungs-Script : 'ERROR-MESSAGE'
		Tools > Optionen > Designer > [] Prevent ... re-creation of table
		Freier Bereich > Rechtsklick > �nderungs-Script : 'NEU-ERSTELLUNG'

	' Ja, schon... ABER: es muss eine NEUE Tabelle erstellt werden, der CONTENT wird
	  komplett KOPIERT und ALLE Tabellen, die damit in Beziehung stehen, werden bis
	  zum Ende der Aktion GESPERRT und sind nicht aufrufbar f�r ANDERE; keine I/O.
	  Dieser Prozess findet in DEINEM SSMS statt und in DEINER Sitzung! '

-- CONSTRAINTS = Einschr�nkende Eigenschaften

	 > CREATE TABLE	-- schon als fertige Struktur anlegen
		> TYPE CONSTRAINT 
		> PRIMARY / FOREIGN KEY CONSTRAINT
		> ggf. DEFAULT / CHECK ; geht aber auch sp�ter : 'siehe ## unten'

	 > ALTER TABLE -- Struktur nachtr�glich ver�ndern
		> ADD = f�ge nachtr�glich eine neue (berechnete) Spalte
				' OHNE eine Neu-Erstellung einer Tabelle zu erzwingen! '

ALTER TABLE HR.Actor ADD [Honorar] INTEGER NULL 
				' um NACHTR�GLICH Default setzen zu k�nnen, MUSS Spalte NULLABLE sein '
GO

		> DEFAULT = setze einen Standard-Wert, wenn der USER nichts angibt = NULL

ALTER TABLE HR.Actor ADD		-- nachtr�glich hinzuf�gen
	CONSTRAINT [DFT_Honorar]	-- Constraint Naming f�r DEFAULT
	DEFAULT ( (1000) )			-- Wert f�r DEFAULT
	FOR [Honorar]				-- Spalte f�r DEFAULT

		> ' ## : wenn ich BEIDES haben will, dann in EINEM Schritt '

ALTER TABLE HR.Actor ADD [Honorar] INTEGER NOT NULL 
	CONSTRAINT [DFT_Honorar]	-- Constraint Naming f�r DEFAULT
	DEFAULT ( (1000) )			-- Wert f�r DEFAULT

		> CHECK = �berpr�fe die Eingabe des USER auf Sinnhaftigkeit

ALTER TABLE HR.Actor ADD				-- nachtr�glich hinzuf�gen
	CONSTRAINT [CHK_Honorar]			-- Constraint Naming f�r CHECK
	CHECK ( ( [Honorar] >= 1000 ) )		-- Wert f�r CHECK

		> ' ## : noch eleganter w�re bei ERSTELLUNG gewesen '

CREATE TABLE HR.[Actor] (
	[ActorID]		INTEGER IDENTITY(1,1)	
		CONSTRAINT [pkActorID] PRIMARY KEY	
		NONCLUSTERED		
	, [PersonID]	INTEGER	
		CONSTRAINT [fkActorPerson] FOREIGN KEY	
		REFERENCES HR.Person(PersonID)	
	, [Honorar]		INTEGER NOT NULL
		CONSTRAINT [DFT_Honorar] DEFAULT ( (1000) )
		CONSTRAINT [CHK_Honorar] CHECK ( ( [Honorar] >= 1000 ) )
)

-- Datens�tze hinzuf�gen 

INSERT INTO HR.Actor (ActorID , PersonID ) VALUES (1,1)
GO		-- geht nicht, weil IDENTITY stets SELBST hochz�hlt

INSERT INTO HR.Actor (PersonID) VALUES (1)
GO		-- geht nicht, weil Person NOT EXISTS

INSERT INTO HR.Person (Forename, Surname) VALUES ( 'Pink' , 'Floyd' )
GO

INSERT INTO HR.Person (Forename, Surname) VALUES ( N'J�rg' , N'M�ller' )
GO

SELECT * FROM HR.Person

INSERT INTO HR.Actor (PersonID) VALUES (1)
GO		-- geht, weil Person EXISTS

SELECT * FROM HR.Actor
	' ActorID = 3 , weil andere "verbrannt" wurden von DEPP-INSERT '

INSERT INTO HR.Actor (PersonID) VALUES (1)
GO		-- geht, weil Person EXISTS > Doppel-Rolle ;)

	' ab hier HONORAR NOT NULL mit DEFAULT & CHECK '

INSERT INTO HR.Actor (PersonID) VALUES (2)
GO		-- kein Honorar > DEFAULT = 1000

INSERT INTO HR.Actor (PersonID, Honorar) VALUES (2, 500)
GO		-- CHECK >= 1000 sagt "N�!"
		' wieder eine ActorID "verbrannt" ... geil! '

INSERT INTO HR.Actor (PersonID, Honorar) VALUES (2, 1500)
GO		-- CHECK >= 1000 sagt "Gerne."

SELECT * FROM HR.Actor

-- Tabellen-Definition LESEN f�r HR.Actor

	' Tabelle > Rechtsklick > Script > CREATE TO > New Window '

/****** Object:  Table [HR].[Actor]    Script Date: 20.10.2021 12:24:01 ******/
SET ANSI_NULLS ON			-- SVR Setting
GO

SET QUOTED_IDENTIFIER ON	-- SVR Setting
GO

CREATE TABLE [HR].[Actor](
	[ActorID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NULL,
	[Honorar] [int] NOT NULL,
 CONSTRAINT [pkActorID] PRIMARY KEY NONCLUSTERED	-- PK ist NACHGELAGERT, falls ZUSAMMENGESETZT oder DESC
(
	[ActorID] ASC	-- aufsteigend sortiert ; falls absteigend, dann bewusst so schreiben mit DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]		-- SVR Setting
GO

ALTER TABLE [HR].[Actor] ADD  CONSTRAINT [DFT_Honorar]  DEFAULT ((1000)) FOR [Honorar]
GO

ALTER TABLE [HR].[Actor]  WITH CHECK ADD  CONSTRAINT [fkActorPerson] FOREIGN KEY([PersonID])
REFERENCES [HR].[Person] ([PersonID])	-- FOREIGN KEY IMMER WITH CHECK!! 
GO

ALTER TABLE [HR].[Actor] CHECK CONSTRAINT [fkActorPerson]
GO		-- WITH CHECK wird hier durchgef�hrt f�r BISHERIGE Eintr�ge R�CKWIRKEND

ALTER TABLE [HR].[Actor]  WITH CHECK ADD  CONSTRAINT [CHK_Honorar] CHECK  (([Honorar]>=(1000)))
GO		-- hier L�GT er mich an > wir haben den CHECK =OHNE= WITH CHECK angelegt

ALTER TABLE [HR].[Actor] CHECK CONSTRAINT [CHK_Honorar]
GO		-- Konstruktor nimmt pauschal an, dass alle CHECK immer WITH CHECK sind 

-- ################# Hilfe zur Selbsthilfe ######################

	' SSMS > Help > Help Content = Kurz-Referenz zu TSQL und ANDEREN Programmiersprachen '

-- FORMAT ( value , format [, culture] )

SELECT
	ActorID
	, PersonID
	, FORMAT ( Honorar, 'C' , 'de-DE' )		-- RESULT := STRING
FROM HR.Actor

-- Hausaufgabe > Kurzreferenz zu SELECT durchlesen und Excel-Mappe "Select" bef�llen

-- ### Ende Tag 2