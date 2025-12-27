USE `progetto_cannarella_dellamaggiora_polperio`;

###############################################################################################
# 										OPERAZIONI											  #
###############################################################################################

/* PRIMA OPERAZIONE */

WITH oreLavorate as (
	SELECT p.Matricola, p.Stipendio, SUM(HOUR(t.FineTurno) - HOUR(t.InizioTurno)) as ore
	FROM Personale p 
		LEFT OUTER JOIN Turno t ON p.Matricola = t.FK_Matricola
	WHERE YEAR(t.InizioTurno) = 2022
		AND MONTH(t.InizioTurno) = 11
	GROUP BY p.Matricola
)
SELECT ol.Matricola, IF (ol.ore > 40, (ol.Stipendio * ol.ore) + (ol.Stipendio * (ol.ore - 40) * 0.10) , ol.ore * ol.Stipendio) AS Stipendio
FROM oreLavorate ol;

/* SECONDA OPERAZIONE */
WITH edificiCommercialiIndustriali AS (
	SELECT e.FK_NomeAreaGeografica, e.FK_IdIndirizzo
    FROM Edificio e 
    WHERE e.TipoEdificio = "AGRICOLO" 
		OR e.TipoEdificio = "INDUSTRIALE"
        
), elencoTerremoti AS (
	SELECT cag.FK_DataCalamita AS "DataCalamita", eci.FK_NomeAreaGeografica AS "FK_NomeAreaGeografica", eci.FK_IdIndirizzo AS "FK_IdIndirizzo"
	FROM edificiCommercialiIndustriali eci
		JOIN Calamita_AreaGeografica cag ON cag.FK_NomeAreaGeografica = eci.FK_NomeAreaGeografica
	WHERE cag.FK_TipoCalamita = "Terremoto" 
		AND cag.Intensita >= 4
	UNION
	SELECT c.DataCalamita AS "DataCalamita", eci.FK_NomeAreaGeografica AS "FK_NomeAreaGeografica", eci.FK_IdIndirizzo AS "FK_IdIndirizzo"
	FROM edificiCommercialiIndustriali eci
		JOIN Calamita c ON c.FK_NomeAreaGeograficaCentro = eci.FK_NomeAreaGeografica
	WHERE c.TipoCalamita = "Terremoto" 
		AND c.Intensita >= 4
        
), elencoAccelerometri AS (
	SELECT eci.FK_NomeAreaGeografica, eci.FK_IdIndirizzo, s.IdSensore, s.DataInstallazione
    FROM edificiCommercialiIndustriali eci
		JOIN Vano v ON ((v.FK_NomeAreaGeograficaEdificio = eci.FK_NomeAreaGeografica) AND (v.FK_IdIndirizzoEdificio = eci.FK_IdIndirizzo))
        JOIN Superficie su ON su.FK_IdVano = v.IdVano
        JOIN Sensore s ON s.FK_IdSuperficie = su.IdSuperficie
	WHERE s.NomeSensore = "Sensore multi uso inerziale con accelerometro a 3 assi"
    
)
SELECT i.Via, I.Civico, i.cap
FROM (
		SELECT ea.FK_NomeAreaGeografica, ea.FK_IdIndirizzo, ea.IdSensore, COUNT(*) AS "numeroSollecitazioni"
		FROM elencoAccelerometri ea
			JOIN elencoTerremoti et ON ((et.FK_NomeAreaGeografica = ea.FK_NomeAreaGeografica) AND (et.FK_IdIndirizzo = ea.FK_IdIndirizzo))
		WHERE ea.DataInstallazione < et.DataCalamita
		GROUP BY ea.FK_NomeAreaGeografica, ea.FK_IdIndirizzo, ea.IdSensore
        HAVING numeroSollecitazioni >= 4
    ) AS D
    JOIN Indirizzo i ON i.IdIndirizzo = D.FK_IdIndirizzo;
    
/* TERZA OPERAZIONE */
    
SELECT f.NomeFornitore, f.PIva
FROM Fornitore f
WHERE f.PIva IN (

	SELECT a.FK_PIvaFornitore
    FROM Acquisto a
    GROUP BY a.FK_PIvaFornitore
    HAVING AVG(a.CostoPerUnita) <= ALL (
		SELECT AVG(a2.CostoPerUnita)
		FROM Acquisto a2
		GROUP BY a2.FK_PIvaFornitore
    )
);
    
/* QUARTA OPERAZIONE */

UPDATE Personale p
SET p.Stipendio = p.Stipendio +  ((((YEAR(current_date) - YEAR(p.DataAssunzione)) DIV 5) + 1) * p.stipendio)/100
WHERE p.DataAssunzione + INTERVAL 1 YEAR < current_date()
	AND p.Matricola <> 0;

/* QUINTA OPERAZIONE */

WITH DatiMaterialeGenerico AS (

	SELECT 	mg.NomeMaterialeGenerico AS "NomeMateriale",
			IFNULL(SUM(a.Quantita),0) AS "QuantitaTotaleAcquistata",
			IFNULL(SUM(a.Quantita * a.CostoPerUnita), 0) AS "SpesaComplessiva",
			"Materiale Generico" AS "Tipo"
		FROM MaterialeGenerico mg
			LEFT OUTER JOIN Acquisto a ON a.FK_NomeMaterialeGenerico = mg.NomeMaterialeGenerico
	GROUP BY mg.NomeMaterialeGenerico
), DatiMattone AS (

	SELECT 	m.NomeMattone AS "NomeMateriale",
			IFNULL(SUM(a.Quantita), 0) AS "QuantitaTotaleAcquistata",
			IFNULL(SUM(a.Quantita * a.CostoPerUnita), 0) AS "SpesaComplessiva",
			"Mattone" AS "Tipo"
    FROM Mattone m
		LEFT OUTER JOIN Acquisto a ON a.FK_NomeMattone = m.NomeMattone
	GROUP BY m.NomeMattone
), DatiIntonato AS (

		SELECT 	i.NomeIntonaco AS "NomeMateriale",
			iFNULL(SUM(a.Quantita), 0) AS "QuantitaTotaleAcquistata",
            IFNULL(SUM(a.Quantita * a.CostoPerUnita), 0) AS "SpesaComplessiva",
            "Intonaco" AS "Tipo"
    FROM Intonaco i
		LEFT OUTER JOIN Acquisto a ON a.FK_NomeIntonaco = i.NomeIntonaco
	GROUP BY i.NomeIntonaco

), DatiPiastrella AS (

	SELECT 	p.NomePiastrella AS "NomeMateriale",
			iFNULL(SUM(a.Quantita), 0) AS "QuantitaTotaleAcquistata",
            IFNULL(SUM(a.Quantita * a.CostoPerUnita), 0) AS "SpesaComplessiva",
            "Piastrella" AS "Tipo"
    FROM Piastrella p
		LEFT OUTER JOIN Acquisto a ON a.FK_NomePiastrella = p.NomePiastrella
	GROUP BY p.NomePiastrella
), DatiCompleti AS (

	SELECT *
    FROM DatiMaterialeGenerico
		UNION
	SELECT *
    FROM DatiMattone
		UNION
	SELECT *
    FROM DatiIntonato
		UNION
	SELECT *
    FROM DatiPiastrella
)
SELECT 	dc.NomeMateriale AS "Nome Materiale",
		dc.QuantitaTotaleAcquistata AS "Quantita Totale Acquistata",
        dc.SpesaComplessiva AS "Spesa Complessiva",
        dc.Tipo,
        RANK() OVER ( ORDER BY dc.QuantitaTotaleAcquistata DESC) AS "Classifica Generale",
        RANK() OVER ( PARTITION BY dc.Tipo ORDER BY dc.QuantitaTotaleAcquistata DESC) AS "Classifica Per Materiale"
FROM DatiCompleti dc;

/* SESTA OPERAZIONE */
UPDATE Vano v
SET v.Balcone = "Inagibile"
WHERE v.IdVano <> 0 AND
	v.IdVano IN (

	SELECT *
	FROM (
		SELECT v2.IdVano
		FROM Alert a
			JOIN Vano v2 ON a.FK_IdVano = v2.IdVano
			JOIN MisuraScalare ms ON (ms.DataMisura = a.FK_DataMisuraScalare) AND (ms.FK_IdSensore = a.FK_IdSensoreScalare)
			JOIN Sensore s ON ms.FK_IdSensore = s.IdSensore
		WHERE ms.valore >= 2 * s.SogliaLimiteX
			AND (v2.Balcone = "Balcone" OR v2.Balcone = "Terrazzo")
		UNION
		SELECT v3.IdVano
		FROM Alert a
			JOIN Vano v3 ON a.FK_IdVano = v3.IdVano
			JOIN MisuraTriassiale mt ON (mt.DataMisura = a.FK_DataMisuraTriassiale) AND (mT.FK_IdSensore = a.FK_IdSensoreTriassiale)
			JOIN Sensore s ON mt.FK_IdSensore = s.IdSensore
		WHERE (v3.Balcone = "Balcone" OR v3.Balcone = "Terrazzo")
			AND (
				 mt.X >= s.SogliaLimiteX * 2
			  OR mt.Y >= s.SogliaLimiteY * 2
			  OR mt.Z >= s.SogliaLimiteZ * 2
			)
	) AS D
);

/* SETTIMA OPERAZIONE */    
    
WITH ModificheStati AS (
	SELECT ag.NomeAreaGeografica, count(*) AS "NumeroCambiamenti"
	FROM AreaGeografica ag
		JOIN StoricoRischio sr ON sr.FK_NomeAreaGeografica = ag.NomeAreaGeografica
	GROUP BY ag.NomeAreaGeografica
)
SELECT ms.NomeAreaGeografica
FROM ModificheStati ms
WHERE ms.NumeroCambiamenti >= ALL (
	SELECT ms2.NumeroCambiamenti
    FROM modificheStati ms2
);

/* OTTAVA OPERAZIONE */
SELECT SUM(sda.Costo) AS "Prezzo Pieno", SUM(sda.Costo) * 0.85 AS "Prezzo Scontato"
FROM StatoDiAvanzamento sda
WHERE FK_CodProgetto = 3
GROUP BY FK_CodProgetto;