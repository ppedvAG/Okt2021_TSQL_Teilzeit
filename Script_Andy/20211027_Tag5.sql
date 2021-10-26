
-- ### JOIN

SELECT	* 
FROM	leftTable AS lt		-- benutze Tabellen-ALIAS > JOIN schneller / kompakter zu schreiben!
		(INNER / LEFT [OUTER] / RIGHT [OUTER] / FULL [OUTER]) JOIN rightTable AS rt ON lt.IDCol = rt.IDCol

-- ### Beispiel für INNER JOIN :: Schlachtordnung im Bau von JOINs
