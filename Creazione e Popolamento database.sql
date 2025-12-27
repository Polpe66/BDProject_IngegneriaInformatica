DROP DATABASE IF EXISTS `progetto_cannarella_dellamaggiora_polperio`;
CREATE DATABASE `progetto_cannarella_dellamaggiora_polperio`;
USE `progetto_cannarella_dellamaggiora_polperio`;

CREATE TABLE AreaGeografica (

    NomeAreaGeografica VARCHAR(30) PRIMARY KEY,
    Superficie FLOAT NOT NULL,
    CHECK (Superficie > 0)
);

CREATE TABLE StoricoRischio (

	DataFine DATE NOT NULL,
	Tipo VARCHAR(30) NOT NULL,
    CoeffRischio FLOAT NOT NULL,
    DataInizio DATE NOT NULL,
    FK_NomeAreaGeografica VARCHAR(30) NOT NULL,
    
    PRIMARY KEY (DataFine, FK_NomeAreaGeografica),
    
    FOREIGN KEY (FK_NomeAreaGeografica) REFERENCES AreaGeografica(NomeAreaGeografica) ON DELETE CASCADE,
    
    CHECK (CoeffRischio BETWEEN 0.01 AND 100.00)
);

CREATE TABLE Rischio (

    Tipo VARCHAR(30) NOT NULL,
    CoeffRischio FLOAT NOT NULL,		
    DataInizio DATE NOT NULL,
    FK_NomeAreaGeografica VARCHAR(30) NOT NULL,
    
    PRIMARY KEY (Tipo, FK_NomeAreaGeografica),
    
    FOREIGN KEY (FK_NomeAreaGeografica) REFERENCES AreaGeografica(NomeAreaGeografica) ON DELETE CASCADE,

	CHECK (CoeffRischio BETWEEN 0.01 AND 100.00)
);

CREATE TABLE Indirizzo (

	IdIndirizzo INT AUTO_INCREMENT PRIMARY KEY,
    CAP INT NOT NULL,
    Civico INT NOT NULL,
    Via VARCHAR(60) NOT NULL,
    
    CHECK (CAP > 9999 AND CAP < 1000000),
    CHECK (Civico > 0)
);

CREATE TABLE Edificio (

    TipoEdificio VARCHAR(30) NOT NULL,
    StatoEdificio FLOAT NOT NULL,
    FK_NomeAreaGeografica VARCHAR(30) NOT NULL,
    FK_IdIndirizzo INT NOT NULL,
    Latitudine FLOAT NOT NULL,
    Longitudine FLOAT NOT NULL,
    
    PRIMARY KEY (FK_NomeAreaGeografica, FK_IdIndirizzo),
    
    FOREIGN KEY (FK_NomeAreaGeografica ) REFERENCES AreaGeografica(NomeAreaGeografica) ON DELETE CASCADE,
    FOREIGN KEY (FK_IdIndirizzo) REFERENCES Indirizzo(IdIndirizzo) ON DELETE CASCADE,
    
    CHECK (StatoEdificio >= 0.01 AND StatoEdificio <= 100)
);

CREATE TABLE Vano (

	IdVano INT AUTO_INCREMENT PRIMARY KEY,
    Larghezza FLOAT NOT NULL,
    Lunghezza FLOAT NOT NULL,
    Piano INT NOT NULL,			#I piani negativi indicano i piani sotto il livello del suolo
    AltezzaMax FLOAT NOT NULL,
    AltezzaMin FLOAT NOT NULL,
    Balcone ENUM("Balcone", "Terrazzo", "Assente", "Inagibile") NOT NULL,
    FK_NomeAreaGeograficaEdificio VARCHAR(30) NOT NULL,
    FK_IdIndirizzoEdificio INT NOT NULL,
    
    FOREIGN KEY (FK_NomeAreaGeograficaEdificio, FK_IdIndirizzoEdificio) REFERENCES Edificio(FK_NomeAreaGeografica, FK_IdIndirizzo) ON DELETE CASCADE,
    
    CHECK (Larghezza > 0),
    CHECK (Lunghezza > 0),
    CHECK (AltezzaMax > 0),
    CHECK (AltezzaMin > 0),
    CHECK (AltezzaMax >= AltezzaMin)
);

CREATE TABLE PuntoDAccesso (

	IdPuntoDAccesso INT PRIMARY KEY AUTO_INCREMENT,
	X FLOAT NOT NULL,
    Y FLOAT NOT NULL,
    Lunghezza FLOAT NOT NULL,
    Altezza FLOAT NOT NULL,
    TipologiaPuntoAccesso VARCHAR(30) NOT NULL,
    PuntoCardinale ENUM("N", "NE", "NW", "S", "SE", "SW", "E", "W") NOT NULL,
    FK_IdVanoOut INT NOT NULL,		#Vano da cui esco (che esiste sicuro)
    FK_IdVanoIn INT NULL,				#Vano nel quale entro (che può non esistere)
    
    UNIQUE (FK_IdVanoOut, FK_IdVanoIn),
    FOREIGN KEY (FK_IdVanoIn) REFERENCES Vano(IdVano) ON DELETE CASCADE,
    FOREIGN KEY (FK_IdVanoOut) REFERENCES Vano(IdVano) ON DELETE CASCADE,
    
    CHECK (X >= 0),
    CHECK (Y >= 0),
    CHECK (Lunghezza > 0),
    CHECK (Altezza > 0)
);
CREATE INDEX indexPuntoDAccesso
ON PuntoDAccesso(FK_IdVanoOut, FK_IdVanoIn);

CREATE TABLE FunzioneVano (

	FK_IdVano INT NOT NULL,
    Funzione VARCHAR(15) NOT NULL,
    
    PRIMARY KEY (FK_IdVano, Funzione),
    
    FOREIGN KEY (FK_IdVano) REFERENCES  Vano(IdVano) ON DELETE CASCADE
);

CREATE TABLE MaterialeGenerico (

    NomeMaterialeGenerico VARCHAR(60) PRIMARY KEY,
    DimensioneX FLOAT NOT NULL,
    DimensioneY FLOAT,
    DimensioneZ FLOAT,
    Costituzione TEXT NOT NULL,
    
    CHECK (DimensioneX > 0),
    CHECK (DimensioneY IS NULL OR DimensioneY > 0),
    CHECK (DimensioneZ IS NULL OR DimensioneZ > 0)
);

CREATE TABLE Piastrella (

    NomePiastrella VARCHAR(60) PRIMARY KEY,
    Tipo ENUM("Piastrella", "Pietra", "Lastra di Legno"),
    DimensioneLato FLOAT,
    NumeroLati INT,
    Materiale VARCHAR(30),
    Disegno VARCHAR(100),
    SuperficieMedia FLOAT NOT NULL,
    PesoMedio FLOAT NOT NULL,
    Costituzione TEXT NOT NULL,
    
    CHECK (DimensioneLato IS NULL OR DimensioneLato > 0),
    CHECK (NumeroLati IS NULL OR NumeroLati > 0),
    CHECK (SuperficieMedia > 0),
    CHECK (PesoMedio > 0)    
);

CREATE TABLE Mattone (
	
    NomeMattone VARCHAR(60) PRIMARY KEY,
    Alveolatura FLOAT,
    Isolante BOOLEAN NOT NULL,
    Materiale VARCHAR(100),
    DimensioneX FLOAT NOT NULL,
    DimensioneY FLOAT NOT NULL,
    DimensioneZ FLOAT NOT NULL,
    Costituzione TEXT NOT NULL,
    
    CHECK (DimensioneX > 0),
    CHECK (DimensioneY > 0),
    CHECK (DimensioneZ > 0)
);

CREATE TABLE Intonaco (

     NomeIntonaco VARCHAR(60) NOT NULL PRIMARY KEY,
     Tipo VARCHAR(30) NOT NULL,
     Costituzione TEXT NOT NULL
);

CREATE TABLE Superficie(

	IdSuperficie INT AUTO_INCREMENT PRIMARY KEY,
    TipoSuperficie varchar(15) NOT NULL, 
    Fuga FLOAT,
    DisposizionePiastrelle VARCHAR(50), 
    
    FK_IdVano INT NOT NULL,
    FK_NomeMaterialeGenerico VARCHAR(60),
    FK_NomePiastrella VARCHAR(60),
    FK_NomeMattone VARCHAR(60),
    
    FOREIGN KEY (FK_IdVano) REFERENCES Vano(IdVano) ON DELETE CASCADE,
    FOREIGN KEY (FK_NomeMaterialeGenerico) REFERENCES MaterialeGenerico(NomeMaterialeGenerico) ON DELETE CASCADE,
    FOREIGN KEY (FK_NomePiastrella) REFERENCES Piastrella(NomePiastrella) ON DELETE CASCADE,
    FOREIGN KEY (FK_NomeMattone) REFERENCES Mattone(NomeMattone) ON DELETE CASCADE,
    
    CHECK (Fuga IS NULL OR Fuga > 0)
);

CREATE INDEX indexSuperficie
ON Superficie(TipoSuperficie, FK_IdVano);

CREATE TABLE Finestra (
	
    X FLOAT NOT NULL,
    Y FLOAT NOT NULL,
    PuntoCardinale ENUM("N", "NE", "NW", "S", "SE", "SW", "E", "W") NOT NULL,
    Lunghezza FLOAT NOT NULL,
    Larghezza FLOAT NOT NULL,	
    FK_IdSuperficie INT NOT NULL,
    
    PRIMARY KEY (X, Y, FK_IdSuperficie),
    
    FOREIGN KEY (FK_IdSuperficie) REFERENCES Superficie(IdSuperficie) ON DELETE CASCADE,
    
    CHECK (Lunghezza > 0),
    CHECK (Larghezza > 0),
    CHECK (X >= 0),
    CHECK (Y >= 0)
);

CREATE TABLE Calamita (

    TipoCalamita VARCHAR(30) NOT NULL,
    DataCalamita DATE NOT NULL,
    FK_NomeAreaGeograficaCentro VARCHAR(30) NOT NULL,
    Intensita FLOAT NOT NULL,
    Latitudine FLOAT NOT NULL,
    Longitudine FLOAT NOT NULL,

	PRIMARY KEY (TipoCalamita, DataCalamita),

	FOREIGN KEY (FK_NomeAreaGeograficaCentro) REFERENCES AreaGeografica(NomeAreaGeografica) ON DELETE CASCADE
);

CREATE TABLE Calamita_AreaGeografica (
	
    Intensita FLOAT NOT NULL,
    FK_TipoCalamita VARCHAR(30) NOT NULL,
    FK_DataCalamita DATE NOT NULL,
    FK_NomeAreaGeografica VARCHAR(30) NOT NULL,
    
    PRIMARY KEY (FK_TipoCalamita, FK_DataCalamita, FK_NomeAreaGeografica),
    
    FOREIGN KEY (FK_TipoCalamita, FK_DataCalamita) REFERENCES Calamita(TipoCalamita, DataCalamita) ON DELETE CASCADE,
	FOREIGN KEY (FK_NomeAreaGeografica) REFERENCES AreaGeografica(NomeAreaGeografica) ON DELETE CASCADE,

	CHECK (Intensita > 0)
);

CREATE TABLE Danno (

    TipoDanno VARCHAR(30) NOT NULL,
    Entita FLOAT NOT NULL,
    X FLOAT NOT NULL,
    Y FLOAT NOT NULL,
    FK_TipoCalamita VARCHAR(30) NOT NULL,
    FK_DataCalamita DATE NOT NULL,
    FK_IdSuperfice INT NOT NULL,
    
    PRIMARY KEY (FK_TipoCalamita, FK_DataCalamita, FK_IdSuperfice, X, Y),
    
    FOREIGN KEY (FK_TipoCalamita, FK_DataCalamita) REFERENCES Calamita(TipoCalamita, DataCalamita) ON DELETE CASCADE,
    FOREIGN KEY (FK_IdSuperfice) REFERENCES Superficie(IdSuperficie) ON DELETE CASCADE,
    
    CHECK (X >= 0),
    CHECK (Y >= 0)
);

CREATE TABLE Sensore (

	IdSensore INT AUTO_INCREMENT PRIMARY KEY,
    DataInstallazione DATE NOT NULL,
    NomeSensore VARCHAR(60) NOT NULL,
	Tipo ENUM("Scalare", "Triassiale") NOT NULL,
    X FLOAT NOT NULL,
    Y FLOAT NOT NULL,
    SogliaLimiteX FLOAT NOT NULL,
    SogliaLimiteY FLOAT,
    SogliaLimiteZ FLOAT,		#Per i sensori, le misure negative hanno senso
    FK_IdSuperficie INT NOT NULL, 
    
    FOREIGN KEY (FK_IdSuperficie) REFERENCES Superficie(IdSuperficie) ON DELETE CASCADE,
    
    CHECK (X >= 0),
    CHECK (Y >= 0)
);

CREATE INDEX indexSensore
ON Sensore(X, Y, FK_IdSuperficie);

CREATE TABLE MisuraTriassiale (

    X FLOAT NOT NULL,
    Y FLOAT,
    Z FLOAT,
    DataMisura DATETIME NOT NULL,
    FK_IdSensore INT NOT NULL,
    
    PRIMARY KEY (DataMisura, FK_IdSensore),
    
    FOREIGN KEY (FK_IdSensore) REFERENCES Sensore(IdSensore) ON DELETE CASCADE
);

CREATE TABLE MisuraScalare (
    Valore FLOAT NOT NULL,
    DataMisura DATETIME NOT NULL,
    FK_IdSensore INT NOT NULL,
    
    PRIMARY KEY (DataMisura, FK_IdSensore),
    
    FOREIGN KEY (FK_IdSensore) REFERENCES Sensore(IdSensore) ON DELETE CASCADE
);

CREATE TABLE Alert (

	IdAlert INT PRIMARY KEY AUTO_INCREMENT,
	DataAlert DATETIME NOT NULL,
    MessaggioAlert TEXT NOT NULL,
    FK_IdVano INT,
    FK_DataMisuraScalare DATETIME,
    FK_IdSensoreScalare INT,
    FK_DataMisuraTriassiale DATETIME,
    FK_IdSensoreTriassiale INT,
    
    
    UNIQUE (DataAlert,  FK_DataMisuraScalare, FK_IdSensoreScalare, FK_DataMisuraTriassiale, FK_IdSensoreTriassiale),
    
    FOREIGN KEY (FK_IdVano) REFERENCES Vano(IdVano) ON DELETE CASCADE,
    FOREIGN KEY (FK_DataMisuraScalare, FK_IdSensoreScalare) REFERENCES MisuraScalare (DataMisura, FK_IdSensore) ON DELETE CASCADE,
    FOREIGN KEY (FK_DataMisuraTriassiale, FK_IdSensoreTriassiale) REFERENCES MisuraTriassiale (DataMisura, FK_IdSensore) ON DELETE CASCADE
);

CREATE INDEX indexAlert
ON Alert(DataAlert,  FK_DataMisuraScalare, FK_IdSensoreScalare, FK_DataMisuraTriassiale, FK_IdSensoreTriassiale);


CREATE TABLE Progetto (

	CodiceProgetto INT AUTO_INCREMENT PRIMARY KEY,
    DataPresentazione DATE NOT NULL,
    DataApprovazione DATE,
    DataInizio DATE,
    DataPrevistaFine DATE,
    DataFine DATE,
    TipoProgetto ENUM ("Costruzione Nuovo Edificio", "Restaurazione Edificio"),
    FK_NomeAreaGeograficaEdificio VARCHAR(30) NOT NULL,
    FK_IdIndirizzoEdificio INT NOT NULL,

    FOREIGN KEY (FK_NomeAreaGeograficaEdificio, FK_IdIndirizzoEdificio) REFERENCES Edificio(FK_NomeAreaGeografica, FK_IdIndirizzo) ON DELETE CASCADE,
    
    CHECK (DataApprovazione IS NULL OR DataPresentazione < DataApprovazione),
    CHECK ((DataApprovazione IS NULL AND DataInizio IS NULL) OR (DataApprovazione IS  NOT NULL AND DataInizio IS NULL) OR DataApprovazione < DataInizio),
    CHECK ((DataInizio IS NULL AND DataPrevistaFine IS NULL) OR (DataInizio IS  NOT NULL AND DataPrevistaFine IS NULL) OR DataInizio < DataPrevistaFine)
);

CREATE TABLE StatoDiAvanzamento (

	IdStatoDiAvanzamento INT AUTO_INCREMENT PRIMARY KEY,
    DataInizio DATE,
    DataFineStimata DATE,
    DataFine DATE,
    Costo FLOAT NOT NULL DEFAULT 0,
    FK_CodProgetto INT NOT NULL,
    
    FOREIGN KEY (FK_CodProgetto) REFERENCES Progetto(CodiceProgetto) ON DELETE CASCADE,
    
    CHECK (Costo >= 0)
);

CREATE TABLE Lavoro (

	IdLavoro INT AUTO_INCREMENT PRIMARY KEY,
    TipoLavoro VARCHAR(60) NOT NULL,
    FK_IdStatoDiAvanzamento INT NOT NULL,
    FK_IdVano INT, 
    FK_IdSuperficie INT,
    
    FOREIGN KEY (FK_IdStatoDiAvanzamento) REFERENCES StatoDiAvanzamento(IdStatoDiAvanzamento) ON DELETE CASCADE,
    FOREIGN KEY (FK_IdVano) REFERENCES Vano(IdVano) ON DELETE CASCADE,
    FOREIGN KEY (FK_IdSuperficie) REFERENCES superficie(IdSuperficie) ON DELETE CASCADE

);

CREATE TABLE Fornitore (

	PIva VARCHAR(11) PRIMARY KEY,
	NomeFornitore VARCHAR(30) NOT NULL
);

CREATE TABLE Acquisto (

	CodLotto INT AUTO_INCREMENT PRIMARY KEY,
    CostoPerUnita FLOAT NOT NULL,
    Quantita INT NOT NULL,
    DataAcquisto DATE NOT NULL,
    FK_PIvaFornitore VARCHAR(11) NOT NULL,
    FK_NomeMaterialeGenerico VARCHAR(60),
    FK_NomeMattone VARCHAR(60),
    FK_NomePiastrella VARCHAR(60),
    FK_NomeIntonaco VARCHAR(60),
    
    
    FOREIGN KEY (FK_NomeMaterialeGenerico) REFERENCES MaterialeGenerico(NomeMaterialeGenerico) ON DELETE CASCADE,
    FOREIGN KEY (FK_NomeMattone) REFERENCES Mattone(NomeMattone) ON DELETE CASCADE,
    FOREIGN KEY (FK_NomePiastrella) REFERENCES Piastrella(NomePiastrella) ON DELETE CASCADE,
    FOREIGN KEY (FK_NomeIntonaco) REFERENCES Intonaco(NomeIntonaco) ON DELETE CASCADE,
    FOREIGN KEY (FK_PIvaFornitore) REFERENCES Fornitore(PIva) ON DELETE CASCADE,
    
    CHECK (Quantita > 0),
    CHECK (CostoPerUnita > 0)
    
);

CREATE TABLE Lavoro_Acquisti (

	FK_IdLavoro INT NOT NULL,
    FK_CodLotto INT NOT NULL,
    
    PRIMARY KEY(FK_IdLavoro, FK_CodLotto),
    
    FOREIGN KEY (FK_IdLavoro) REFERENCES Lavoro(IdLavoro) ON DELETE CASCADE,
    FOREIGN KEY (FK_CodLotto) REFERENCES Acquisto(CodLotto) ON DELETE CASCADE
);

CREATE TABLE Personale (

	Matricola INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(30) NOT NULL,
    Cognome VARCHAR(30) NOT NULL,
    DataAssunzione DATE NOT NULL,
    Stipendio FLOAT NOT NULL,
    MaxSorvegliati INT,
    FK_MatricolaSupervisore INT,
    
	FOREIGN KEY (FK_MatricolaSupervisore) REFERENCES Personale(Matricola) ON DELETE CASCADE,
    
    CHECK (Stipendio > 0),
    CHECK (MaxSorvegliati > 0)
);

CREATE TABLE Turno (

	InizioTurno DATETIME NOT NULL,
	FineTurno DATETIME NOT NULL,
    FK_Matricola INT NOT NULL,
    FK_IdLavoro INT NOT NULL,
    
    PRIMARY KEY (InizioTurno, FK_Matricola),
    
    FOREIGN KEY (FK_Matricola) REFERENCES Personale(Matricola) ON DELETE CASCADE,
    FOREIGN KEY (FK_IdLavoro) REFERENCES Lavoro(IdLavoro) ON DELETE CASCADE
);

CREATE TABLE StratiIntonaco (

	FK_IdSuperficie INT NOT NULL,
    FK_NomeIntonaco VARCHAR(30) NOT NULL,
    NumeroStrato INT NOT NULL,
    Spessore FLOAT NOT NULL,
    
    PRIMARY KEY (FK_IdSuperficie, FK_NomeIntonaco),
    
    FOREIGN KEY (FK_IdSuperficie) REFERENCES Superficie(IdSuperficie) ON DELETE CASCADE,
    FOREIGN KEY (FK_NomeIntonaco) REFERENCES Intonaco(NomeIntonaco) ON DELETE CASCADE,
    
    CHECK (Spessore > 0)
);


###############################################################################################
# 										STORED FUNCTION                             		  #
###############################################################################################

DROP FUNCTION IF EXISTS nomeSensoreToRiparazione;

DELIMITER $$

CREATE FUNCTION nomeSensoreToRiparazione (_nomeSensore VARCHAR(60))
RETURNS VARCHAR(160) DETERMINISTIC
    BEGIN
		
        DECLARE returnValue VARCHAR(160);
        
        CASE
			WHEN _nomeSensore = "Sensore multi uso inerziale con accelerometro a 3 assi" THEN
				SET returnValue = "A causa di instabilita` varie, la superficie rischia di subire danni (anche gravi). Stabilizzare la superficie";
			WHEN _nomeSensore = "Misuratore di distanza" THEN
				SET returnValue = "La crepa presente rischia di aumentare la sua lunghezza e arreccare danni alla stabilita` dell'edificio. Riparare la crepa presente sulla superficie";
			WHEN _nomeSensore = "Igrometro" THEN
				SET returnValue = "Il tasso di umilta` nell'aria e` alto, anche non a livelli pericolosi. Installare un deumidificatore o eseguire dei lavori di isolamento sulla superficie";
        END CASE;
        
		RETURN returnValue;
    END$$

DELIMITER ;

DROP FUNCTION IF EXISTS tipoCalamitaToTipoRischio;

DELIMITER $$

CREATE FUNCTION tipoCalamitaToTipoRischio( _tipoCalamita VARCHAR(30) )
RETURNS VARCHAR(30) DETERMINISTIC
	BEGIN
		
		DECLARE tipoRischio VARCHAR(30) DEFAULT "";
    
		CASE
			WHEN _tipoCalamita = "terremoto" THEN
				SET tipoRischio = "LIQUEFAZIONE TERRENO";
            WHEN _tipoCalamita = "eruzione vulcanica" THEN
				SET tipoRischio = "INCENDIO";
			WHEN _tipoCalamita = "frana" THEN
				SET tipoRischio = "FRANA";
			WHEN _tipoCalamita = "valanga" THEN
				SET tipoRischio = "FRANA";
			WHEN _tipoCalamita = "inondazione" THEN
				SET tipoRischio = "Alluvione";
			WHEN _tipoCalamita = "alluvione" THEN
				SET tipoRischio = "Alluvione";
			WHEN _tipoCalamita = "tsunami" THEN
				SET tipoRischio = "MAREMOTO";
			WHEN _tipoCalamita = "ciclone" THEN
				SET tipoRischio = "FRANA";
			WHEN _tipoCalamita = "tornado" THEN
				SET tipoRischio = "FRANA";
			WHEN _tipoCalamita = "incendio" THEN
				SET tipoRischio = "INCENDIO";
		END CASE;
        
		RETURN tipoRischio;
    
    END $$

DELIMITER ;

DROP FUNCTION IF EXISTS tipoCalamitaRange;

DELIMITER $$

CREATE FUNCTION tipoCalamitaRange( _tipoCalamita VARCHAR(30) )
RETURNS INTEGER DETERMINISTIC
	BEGIN
		
		DECLARE rangeValue INTEGER DEFAULT 0;
    
		CASE
			WHEN _tipoCalamita = "terremoto" THEN
				SET rangeValue = 45;
            WHEN _tipoCalamita = "eruzione vulcanica" THEN
				SET rangeValue = 10;
			WHEN _tipoCalamita = "frana" THEN
				SET rangeValue = 5;
			WHEN _tipoCalamita = "valanga" THEN
				SET rangeValue = 5;
			WHEN _tipoCalamita = "inondazione" THEN
				SET rangeValue = 15;
			WHEN _tipoCalamita = "alluvione" THEN
				SET rangeValue = 20;
			WHEN _tipoCalamita = "tsunami" THEN
				SET rangeValue = "20";
			WHEN _tipoCalamita = "ciclone" THEN
				SET rangeValue = "30";
			WHEN _tipoCalamita = "tornado" THEN
				SET rangeValue = "30";
			WHEN _tipoCalamita = "incendio" THEN
				SET rangeValue = "30";
		END CASE;
        
		RETURN rangeValue;
    
    END $$

DELIMITER ;

DROP FUNCTION IF EXISTS distanzaCoordinate;

DELIMITER $$

CREATE FUNCTION distanzaCoordinate( _LAT1 FLOAT, _LAT2 FLOAT, _LONG1 FLOAT, _LONG2 FLOAT )
RETURNS INTEGER DETERMINISTIC
	BEGIN
		DECLARE diff FLOAT DEFAULT 0;
        DECLARE distanza FLOAT DEFAULT 0;
        SET diff = _LONG1 - _LONG2;
    
		SET distanza = 60 * 1.1515 * (180/PI()) * ACOS(SIN(_LAT1 * (PI()/180)) * SIN(_LAT2 * (PI()/180)) + COS(_LAT1 * (PI()/180)) * COS(_LAT2 * (PI()/180)) * COS(diff * (PI()/180)));
        RETURN distanza * 1.609344;
    END $$

DELIMITER ;


###############################################################################################
# 						TRIGGER PER VINCOLI DI INTEGRITA GENERICI                             #
###############################################################################################

DROP TRIGGER IF EXISTS ControlloEsistenzaBalconePuntiDAccesso;
DELIMITER $$

CREATE TRIGGER ControlloEsistenzaBalconePuntiDAccesso
	BEFORE INSERT
    ON PuntoDAccesso
    FOR EACH ROW
    BEGIN
		
        DECLARE flagBalconeEntrante VARCHAR(15) DEFAULT "";
    
		IF (NEW.FK_IdVanoIn IS NULL) THEN
			SELECT v.Balcone INTO flagBalconeEntrante
            FROM Vano v
            WHERE v.IdVano = NEW.FK_IdVanoOut;
            
            IF (flagBalconeEntrante = "Assente") THEN
				SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Nel vano non è presente nessun balcone nel quale uscire';
            END IF;
        END IF;
    
    END$$

DELIMITER ;

DROP TRIGGER IF EXISTS ControlloDimensioneSensore;
DELIMITER $$

CREATE TRIGGER ControlloDimensioneSensore
	BEFORE INSERT
    ON Sensore
    FOR EACH ROW
    BEGIN
        IF (NEW.Tipo = 'Scalare') THEN
        
			IF ((NEW.SogliaLimiteY IS NOT NULL) OR (NEW.SogliaLimiteZ IS NOT NULL)) THEN
				SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Il sensore è scalare, non hanno senso soglie limite nella seconda e terza dimensione';
			END IF;
        END IF;
    END$$

DELIMITER ;

DROP TRIGGER IF EXISTS ControlloProvenienzaMisuraScalare;
DELIMITER $$

CREATE TRIGGER ControlloProvenienzaMisuraScalare
	BEFORE INSERT
    ON MisuraScalare
    FOR EACH ROW
    BEGIN
		
        DECLARE tipoSensore VARCHAR(10) DEFAULT "";
        
        SELECT s.Tipo INTO tipoSensore
        FROM Sensore s
        WHERE s.IdSensore = NEW.FK_IdSensore;
        
        IF (tipoSensore = "Triassale") THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La misura è generata da un sensore triassale';
        END IF;
    END$$

DELIMITER ;

DROP TRIGGER IF EXISTS ControlloProvenienzaMisuraTriassiale;
DELIMITER $$

CREATE TRIGGER ControlloProvenienzaMisuraTriassiale
	BEFORE INSERT
    ON MisuraTriassiale
    FOR EACH ROW
    BEGIN
		
        DECLARE tipoSensore VARCHAR(10) DEFAULT "";
        
        SELECT s.Tipo INTO tipoSensore
        FROM Sensore s
        WHERE s.IdSensore = NEW.FK_IdSensore;
        
        IF (tipoSensore = "Scalare") THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La misura è generata da un sensore scalare';
        END IF;
    END$$

DELIMITER ;

DROP TRIGGER IF EXISTS ControlloProvenienzaAlert;
DELIMITER $$

CREATE TRIGGER ControlloProvenienzaAlert
	BEFORE INSERT
    ON Alert
    FOR EACH ROW
    BEGIN
    
		DECLARE counter INTEGER DEFAULT 0;
		
        SELECT IF(NEW.FK_DataMisuraScalare IS NOT NULL, 1, 0) +
				IF(NEW.FK_IdSensoreScalare IS NOT NULL, 1, 0) +
				IF(NEW.FK_DataMisuraTriassiale IS NOT NULL, 1, 0) +
                IF(NEW.FK_IdSensoreTriassiale IS NOT NULL, 1, 0) INTO counter;
                
		IF (counter != 2) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'L\'Alert non risulta generato da nessun sensore';
        END IF;
        
    END$$

DELIMITER ;

DROP TRIGGER IF EXISTS ControlloTipoLavoro;
DELIMITER $$

CREATE TRIGGER ControlloTipoLavoro
	BEFORE INSERT
    ON Lavoro
    FOR EACH ROW
    BEGIN
		
        IF ((NEW.FK_IdVano IS NULL) AND (NEW.FK_IdSuperficie IS NULL)) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Il lavoro non è svolto da nessuna parte';
        END IF;
        
        IF ((NEW.FK_IdVano IS NOT NULL) AND (NEW.FK_IdSuperficie IS NOT NULL)) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Un lavoro non può essere svolto contemporaneamente su di un vano e su di una superficie';
        END IF;
        
    END$$

DELIMITER ;

DROP TRIGGER IF EXISTS ControlloMaterialiAcquisto;
DELIMITER $$

CREATE TRIGGER ControlloMaterialiAcquisto
	BEFORE INSERT
    ON Acquisto
    FOR EACH ROW
    BEGIN
		
        DECLARE counter INTEGER DEFAULT 0;
        
        SELECT IF(NEW.FK_NomeMaterialeGenerico IS NOT NULL, 1, 0) +
			   IF(NEW.FK_NomeMattone IS NOT NULL, 1, 0) +
               IF(NEW.FK_NomePiastrella IS NOT NULL, 1, 0) +
               IF(NEW.FK_NomeIntonaco IS NOT NULL, 1, 0) INTO counter;
                
		IF (counter != 1) THEN
        
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Con un acquisto posso acquistare solo un e un solatato tipo di materiale';
        END IF;
                
    END$$

DELIMITER ;

DROP TRIGGER IF EXISTS ControlloPersonaleCapocantiere;
DELIMITER $$

CREATE TRIGGER ControlloPersonaleCapocantiere
	BEFORE INSERT
    ON Personale
    FOR EACH ROW
    BEGIN
		
        IF (NEW.FK_MatricolaSupervisore IS NULL) AND (NEW.MaxSorvegliati IS NULL) THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Non è possibile capire se si tratta di un Dipendente semplice o di un Capocantiere';
        END IF;
        
        IF (NEW.FK_MatricolaSupervisore IS NOT NULL) AND (NEW.MaxSorvegliati IS NOT NULL) THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Non è possibile capire se si tratta di un Dipendente semplice o di un Capocantiere';
        END IF;
        
    END $$

DELIMITER ;

DROP TRIGGER IF EXISTS ControlloPersonaleTurno;
DELIMITER $$

CREATE TRIGGER ControlloPersonaleTurno
	BEFORE INSERT
    ON Turno
    FOR EACH ROW
    BEGIN
    
		DECLARE flagDipendente BOOLEAN DEFAULT FALSE;
        DECLARE flagRegolarita BOOLEAN DEFAULT FALSE;
        DECLARE matricolaSupervisore INT DEFAULT 0;
        DECLARE dataInizioSupervisore DATETIME DEFAULT NOW();
        DECLARE dataFineSupervisore DATETIME DEFAULT NOW();
        DECLARE NumeroDipentiAttuali INT DEFAULT 0;
        DECLARE NumeroDipentiSupervisore INT DEFAULT 0;
        
        SELECT (p.FK_MatricolaSupervisore IS NOT NULL), p.FK_MatricolaSupervisore
			INTO flagDipendente, matricolaSupervisore
        FROM Personale p
        WHERE p.Matricola = NEW.FK_Matricola;
        
        
        IF flagDipendente THEN
			SELECT DISTINCT TRUE INTO flagRegolarita
            FROM Turno 
            WHERE EXISTS (
				SELECT 1
                FROM Turno t2
					JOIN Personale p ON p.Matricola = t2.FK_Matricola
				WHERE NEW.InizioTurno BETWEEN t2.InizioTurno AND t2.FineTurno
					AND NEW.FineTurno <= t2.FineTurno 
                    AND t2.FK_Matricola = matricolaSupervisore
            );
            
            IF NOT flagRegolarita THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Il dipendente non è nello stesso turno del suo caposquadra';
            END IF;
            
            
            SELECT t.InizioTurno, t.FineTurno, p.MaxSorvegliati
				INTO dataInizioSupervisore, dataFineSupervisore, NumeroDipentiSupervisore
            FROM Turno t
				JOIN Personale p ON p.Matricola = t.FK_Matricola
            WHERE t.FK_Matricola = matricolaSupervisore
				AND DATE(t.InizioTurno) = DATE(NEW.InizioTurno);
            
            WITH elencoSottoposti AS (
				SELECT P.Matricola
                FROM Personale p
                WHERE p.FK_MatricolaSupervisore = matricolaSupervisore
            ) SELECT COUNT(*) INTO NumeroDipentiAttuali
            FROM Turno t
				JOIN elencoSottoposti es ON es.Matricola = t.FK_Matricola
			WHERE t.InizioTurno BETWEEN dataInizioSupervisore AND dataFineSupervisore;
            
            IF NumeroDipentiSupervisore <= NumeroDipentiAttuali THEN
            	SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Per ragioni di sicurezza, il caposquadra non può seguire altri dipendenti';
            END IF;
            
        END IF;
    
    END $$

DELIMITER ;


###############################################################################################
# 								TRIGGER PER AGGIORNAMENTI                             		  #
###############################################################################################

DROP TRIGGER IF EXISTS AggiornamentoStoricoRischio;
DELIMITER $$

CREATE TRIGGER AggiornamentoStoricoRischio
	AFTER UPDATE
    ON Rischio
    FOR EACH ROW
    BEGIN
    
		INSERT INTO StoricoRischio(DataFine, FK_NomeAreaGeografica, Tipo, CoeffRischio, DataInizio)
        SELECT current_date(), OLD.FK_NomeAreaGeografica, OLD.Tipo, OLD.CoeffRischio, OLD.DataInizio;
    
    END $$

DELIMITER ;

DROP TRIGGER IF EXISTS GenerazioneAlertTriassiale;
DELIMITER $$

CREATE TRIGGER GenerazioneAlertTriassiale
	AFTER INSERT
    ON MisuraTriassiale
    FOR EACH ROW
    BEGIN
    
		DECLARE alertFlag BOOLEAN DEFAULT FALSE;
        
        SELECT (
				IF (s.SogliaLimiteX IS NOT NULL, (NEW.X > s.SogliaLimiteX), FALSE) OR
                IF (s.SogliaLimiteY IS NOT NULL, (NEW.Y > s.SogliaLimiteY), FALSE) OR
                IF (s.SogliaLimiteZ IS NOT NULL, (NEW.Z > s.SogliaLimiteZ), FALSE) )
                INTO alertFlag
        FROM Sensore s
        WHERE s.IdSensore = NEW.FK_IdSensore;
        
        IF (alertFlag IS TRUE) THEN
			
			INSERT INTO Alert (FK_IdVano, DataAlert, FK_DataMisuraTriassiale, FK_IdSensoreTriassiale, MessaggioAlert)
            SELECT DISTINCT su.FK_IdVano, NOW(), NEW.DataMisura, NEW.FK_IdSensore, "La misura generata supera i limiti di soglia"
            FROM Sensore s
                JOIN Superficie su ON su.IdSuperficie = s.FK_IdSuperficie
			WHERE s.IdSensore = new.FK_IdSensore;
        END IF;
    
    END $$
    
DELIMITER ;

DROP TRIGGER IF EXISTS GenerazioneAlertScalare;
DELIMITER $$

CREATE TRIGGER GenerazioneAlertScalare
	AFTER INSERT
    ON MisuraScalare
    FOR EACH ROW
    BEGIN
    
		DECLARE alertFlag BOOLEAN DEFAULT FALSE;
        
        SELECT (NEW.Valore > s.SogliaLimiteX) INTO alertFlag
        FROM Sensore s
        WHERE s.IdSensore = NEW.FK_IdSensore;
        
        IF (alertFlag IS TRUE) THEN
			
			INSERT INTO Alert (FK_IdVano, DataAlert, FK_DataMisuraScalare, FK_IdSensoreScalare, MessaggioAlert)
            SELECT DISTINCT su.FK_IdVano, NOW(), NEW.DataMisura, NEW.FK_IdSensore, "La misura generata supera i limiti di soglia"
            FROM Sensore s
                JOIN Superficie su ON su.IdSuperficie = s.FK_IdSuperficie
			WHERE s.IdSensore = new.FK_IdSensore;
        END IF;
    
    END $$
    
DELIMITER ;

DROP TRIGGER IF EXISTS 	GenerazioneIntensitaCalamita;

DELIMITER $$

CREATE TRIGGER GenerazioneIntensitaCalamita
	AFTER INSERT
    ON Calamita
    FOR EACH ROW
    BEGIN
		INSERT INTO Calamita_AreaGeografica
		SELECT NEW.Intensita/distanzaCoordinate(NEW.Latitudine, AVG(e.Latitudine), NEW.Longitudine, AVG(e.Longitudine)), NEW.TipoCalamita, NEW.DataCalamita, e.FK_NomeAreaGeografica
        FROM Edificio e
        WHERE e.FK_NomeAreaGeografica <> NEW.FK_NomeAreaGeograficaCentro
        GROUP BY e.FK_NomeAreaGeografica
        HAVING distanzaCoordinate(NEW.Latitudine, AVG(e.Latitudine), NEW.Longitudine, AVG(e.Longitudine)) < tipoCalamitaRange (NEW.TipoCalamita);
    
    END $$

DELIMITER ;


###############################################################################################
# 							TIGGER PER AGGIORNAMENTO RIDONDANZE                        		  #
###############################################################################################

DROP TRIGGER IF EXISTS RidondanzaCostoAcquisti;
DELIMITER $$
CREATE TRIGGER RidondanzaCostoAcquisti
	AFTER INSERT
    ON Lavoro_Acquisti
    FOR EACH ROW
    BEGIN
		DECLARE spesaTotale FLOAT DEFAULT 0;
        
        SELECT (a.Quantita * a.CostoPerUnita) INTO spesaTotale
        FROM Acquisto a
        WHERE a.CodLotto = NEW.FK_CodLotto;
        
        UPDATE StatoDiAvanzamento s
        SET s.Costo = S.Costo + spesaTotale
        WHERE S.IdStatoDiAvanzamento = (
			SELECT l.FK_IdStatoDiAvanzamento
            FROM Lavoro l
			WHERE l.IdLavoro = new.FK_IdLavoro
        );
    END $$
DELIMITER ;


DROP TRIGGER IF EXISTS RidondanzaCostoTurno;
DELIMITER $$
CREATE TRIGGER RidondanzaCostoTurno
	AFTER INSERT
    ON Turno
    FOR EACH ROW
    BEGIN
		DECLARE oreLavorate INT DEFAULT 0;
        DECLARE minutiLavorati INT DEFAULT 0;
        DECLARE stipendio FLOAT DEFAULT 0;
        
        SELECT (HOUR(NEW.FineTurno) - HOUR(NEW.InizioTurno)) INTO oreLavorate;
        SELECT MINUTE(NEW.FineTurno) - MINUTE(NEW.InizioTurno) INTO minutiLavorati;
        
        SELECT p.Stipendio INTO stipendio
        FROM Personale p
        WHERE p.Matricola = NEW.FK_Matricola;
        
        UPDATE StatoDiAvanzamento s
        SET s.Costo = S.Costo + (stipendio * oreLavorate) + ((stipendio / 60) * minutiLavorati)
        WHERE S.IdStatoDiAvanzamento = (
			SELECT l.FK_IdStatoDiAvanzamento
            FROM Lavoro l
			WHERE l.IdLavoro = new.FK_IdLavoro
        );
    END $$
    
DELIMITER ;

DROP TRIGGER IF EXISTS RidondanzaRiduzioneStatoEdificio;
DELIMITER $$

CREATE TRIGGER RidondanzaRiduzioneStatoEdificio
	AFTER INSERT 
    ON Alert
    FOR EACH ROW
    BEGIN

		DECLARE percentualeX FLOAT DEFAULT 0;
        DECLARE percentualeY FLOAT DEFAULT 0;
        DECLARE percentualeZ FLOAT DEFAULT 0;
        DECLARE dimensioniNonNulle INT DEFAULT 0;
        DECLARE numeroVani INT DEFAULT 0;
		DECLARE statoAttuale FLOAT DEFAULT 0;
        DECLARE nomeAreaGeograficaEdificio VARCHAR(30) DEFAULT "";
        DECLARE idIndirizzoEdificio INT DEFAULT 0;    
    
		IF NEW.FK_IdSensoreScalare IS NOT NULL THEN
        
			SELECT ((ms.Valore-s.SogliaLimiteX) * 100) / s.SogliaLimiteX INTO percentualeX
            FROM MisuraScalare ms
				JOIN Sensore s ON s.IdSensore = ms.FK_IdSensore
            WHERE ms.DataMisura = NEW.FK_DataMisuraScalare
				AND ms.FK_IdSensore = NEW.FK_IdSensoreScalare;
            
            SELECT v.FK_NomeAreaGeograficaEdificio, v.FK_IdIndirizzoEdificio, COUNT(*)
					INTO nomeAreaGeograficaEdificio, idIndirizzoEdificio, numeroVani
			FROM Vano v
            GROUP BY v.FK_NomeAreaGeograficaEdificio, v.FK_IdIndirizzoEdificio
            HAVING (v.FK_NomeAreaGeograficaEdificio, v.FK_IdIndirizzoEdificio) = (
				
                SELECT v1.FK_NomeAreaGeograficaEdificio, v1.FK_IdIndirizzoEdificio
                FROM Vano v1
				WHERE v1.IdVano = NEW.FK_IdVano
            );
            
            SELECT e.StatoEdificio INTO statoAttuale
            FROM Edificio e
            WHERE e.FK_NomeAreaGeografica = nomeAreaGeograficaEdificio
				AND e.FK_IdIndirizzo = idIndirizzoEdificio;
                
			IF (statoAttuale - (percentualeX / numeroVani)) < 0.01 THEN
				
                UPDATE Edificio e 
				SET e.StatoEdificio = 0.02
				WHERE e.FK_NomeAreaGeografica = nomeAreaGeograficaEdificio
					AND e.FK_IdIndirizzo = idIndirizzoEdificio;
            ELSE
				UPDATE Edificio e 
				SET e.StatoEdificio = e.StatoEdificio - (percentualeX / numeroVani)
				WHERE e.FK_NomeAreaGeografica = nomeAreaGeograficaEdificio
					AND e.FK_IdIndirizzo = idIndirizzoEdificio;
			END IF;
            
        ELSE
        
			SELECT ((mt.X-s.SogliaLimiteX) * 100) / s.SogliaLimiteX INTO percentualeX
            FROM MisuraTriassiale mt 
				JOIN Sensore s ON s.IdSensore = mt.FK_IdSensore
            WHERE mt.DataMisura = NEW.FK_DataMisuraTriassiale
				AND mt.FK_IdSensore = NEW.FK_IdSensoreTriassiale;
                
			SELECT IF(mt.Y IS NOT NULL, ((mt.Y-s.SogliaLimiteY) * 100) / s.SogliaLimiteY, 0) INTO percentualeY
            FROM MisuraTriassiale mt
				JOIN Sensore s ON s.IdSensore = mt.FK_IdSensore
            WHERE mt.DataMisura = NEW.FK_DataMisuraTriassiale
				AND mt.FK_IdSensore = NEW.FK_IdSensoreTriassiale;
                
			SELECT IF(mt.Z IS NOT NULL, ((mt.Z-s.SogliaLimiteZ) * 100) / s.SogliaLimiteZ, 0) INTO percentualeZ
            FROM MisuraTriassiale mt
				JOIN Sensore s ON s.IdSensore = mt.FK_IdSensore
            WHERE mt.DataMisura = NEW.FK_DataMisuraTriassiale
				AND mt.FK_IdSensore = NEW.FK_IdSensoreTriassiale;
        
			SELECT IF(mt.X IS NOT NULL, 1, 0)+IF(mt.Y IS NOT NULL, 1, 0)+IF(mt.Z IS NOT NULL, 1, 0) INTO dimensioniNonNulle
            FROM misuratriassiale mt
				JOIN Sensore s ON s.IdSensore = mt.FK_IdSensore
            WHERE mt.DataMisura = NEW.FK_DataMisuraTriassiale
				AND mt.FK_IdSensore = NEW.FK_IdSensoreTriassiale;
        
			SELECT v.FK_NomeAreaGeograficaEdificio, v.FK_IdIndirizzoEdificio, COUNT(*)
					INTO nomeAreaGeograficaEdificio, idIndirizzoEdificio, numeroVani
			FROM Vano v
            GROUP BY v.FK_NomeAreaGeograficaEdificio, v.FK_IdIndirizzoEdificio
            HAVING (v.FK_NomeAreaGeograficaEdificio, v.FK_IdIndirizzoEdificio) = (
				
                SELECT v1.FK_NomeAreaGeograficaEdificio, v1.FK_IdIndirizzoEdificio
                FROM Vano v1
				WHERE v1.IdVano = NEW.FK_IdVano
            );
        
			SELECT e.StatoEdificio INTO statoAttuale
            FROM Edificio e
            WHERE e.FK_NomeAreaGeografica = nomeAreaGeograficaEdificio
				AND e.FK_IdIndirizzo = idIndirizzoEdificio;
            
			IF (statoAttuale - (percentualeX / (numeroVani * dimensioniNonNulle)) - (percentualeY / (numeroVani * dimensioniNonNulle)) - (percentualeZ / (numeroVani * dimensioniNonNulle))) < 0.01 THEN
				
                UPDATE Edificio e 
				SET e.StatoEdificio = 0.02
				WHERE e.FK_NomeAreaGeografica = nomeAreaGeograficaEdificio
					AND e.FK_IdIndirizzo = idIndirizzoEdificio;
            ELSE
				UPDATE Edificio e 
				SET e.StatoEdificio = (statoAttuale - (percentualeX / (numeroVani * dimensioniNonNulle)) - (percentualeY / (numeroVani * dimensioniNonNulle)) - (percentualeZ / (numeroVani * dimensioniNonNulle)))
				WHERE e.FK_NomeAreaGeografica = nomeAreaGeograficaEdificio
					AND e.FK_IdIndirizzo = idIndirizzoEdificio;
			END IF;
        
        END IF;
    
    END $$
DELIMITER ;

DROP TRIGGER IF EXISTS RidondanzaAumentoStatoEdificio;
DELIMITER $$

CREATE TRIGGER RidondanzaAumentoStatoEdificio
	AFTER UPDATE 
    ON Progetto
    FOR EACH ROW
    BEGIN
    
		DECLARE n INT DEFAULT 0;
        DECLARE x INT DEFAULT 0;
        DECLARE a FLOAT DEFAULT 0;
    
		IF ( NEW.DataFine IS NOT NULL ) AND (OLD.DataFine IS NULL) AND (NEW.TipoProgetto = "Restaurazione Edificio" ) THEN
			
       	SELECT SUM(numero) INTO n
				FROM (
				SELECT COUNT(DISTINCT(su.IdSuperficie)) as "numero"
				FROM Alert a
					JOIN MisuraScalare ms ON (
						ms.DataMisura = a.FK_DataMisuraScalare
						AND ms.FK_IdSensore = a.FK_IdSensoreScalare
					)
					JOIN Sensore s ON ms.FK_IdSensore = s.IdSensore
					JOIN superficie su on s.FK_IdSuperficie = su.IdSuperficie 
					JOIN vano v on v.IdVano = su.FK_IdVano
					WHERE v.FK_NomeAreaGeograficaEdificio = NEW.FK_NomeAreaGeograficaEdificio 
					AND v.FK_IdIndirizzoEdificio = NEW.FK_IdIndirizzoEdificio
				UNION
				SELECT COUNT(DISTINCT(su.IdSuperficie))  as "numero"
				FROM Alert a
					JOIN MisuraTriassiale mt ON (
						mt.DataMisura = a.FK_DataMisuraScalare
						AND mt.FK_IdSensore = a.FK_IdSensoreScalare
					)
					JOIN Sensore s ON mt.FK_IdSensore = s.IdSensore
					JOIN superficie su on s.FK_IdSuperficie = su.IdSuperficie 
					JOIN vano v on v.IdVano = su.FK_IdVano
					WHERE v.FK_NomeAreaGeograficaEdificio = NEW.FK_NomeAreaGeograficaEdificio 
					AND v.FK_IdIndirizzoEdificio = NEW.FK_IdIndirizzoEdificio
			)as D;
    
            SELECT SUM(numero) INTO x
			FROM ( 
				SELECT COUNT(DISTINCT(su.IdSuperficie)) as "numero"
				FROM Alert a
					JOIN MisuraScalare ms ON (
						ms.DataMisura = a.FK_DataMisuraScalare
						AND ms.FK_IdSensore = a.FK_IdSensoreScalare
					)
					JOIN Sensore s ON ( ms.FK_IdSensore = s.IdSensore )
					JOIN Superficie su ON s.FK_IdSuperficie = su.IdSuperficie
					JOIN Lavoro l ON (l.FK_IdSuperficie = su.IdSuperficie)
					JOIN StatoDiAvanzamento sda ON sda.IdStatoDiAvanzamento = l.FK_IdStatoDiAvanzamento
				WHERE sda.FK_CodProgetto = NEW.CodiceProgetto
				UNION
				SELECT COUNT(DISTINCT(su.IdSuperficie)) as "numero"
				FROM Alert a
					JOIN MisuraTriassiale mt ON (
						mt.DataMisura = a.FK_DataMisuraScalare
						AND mt.FK_IdSensore = a.FK_IdSensoreScalare
					)
					JOIN Sensore s ON mt.FK_IdSensore = s.IdSensore
					JOIN Superficie su ON s.FK_IdSuperficie = su.IdSuperficie
					JOIN Lavoro l ON (l.FK_IdSuperficie = su.IdSuperficie)
					JOIN StatoDiAvanzamento sda ON sda.IdStatoDiAvanzamento = l.FK_IdStatoDiAvanzamento
				WHERE sda.FK_CodProgetto = NEW.CodiceProgetto
			) as D;
            
            SELECT e.StatoEdificio INTO a
            FROM Edificio e
			WHERE NEW.FK_NomeAreaGeograficaEdificio = e.FK_NomeAreaGeografica AND 
				NEW.FK_IdIndirizzoEdificio = e.FK_IdIndirizzo;
			
            IF (x != 0) THEN				
            
				UPDATE Edificio e
				SET e.StatoEdificio = e.StatoEdificio + (x*(100-a)/n)
				WHERE NEW.FK_NomeAreaGeograficaEdificio = e.FK_NomeAreaGeografica AND 
					NEW.FK_IdIndirizzoEdificio = e.FK_IdIndirizzo;
            END IF;
            
        END IF;
    
    END $$

DELIMITER ;

###############################################################################################
# 											POPOLAMENTO                        		  		  #
###############################################################################################

insert into `Areageografica` values ('Spazzavento',11.3),('QT',23.4),('Stazione',22.3),('Villaggio',16.9),('Padule',28.1),( 'Industriale',20),('Mercato',5),('Monte',13.5),('Cimitero',4),('Terme',7);
INSERT INTO `rischio` VALUES ('Alluvione',17,'2021-01-18','Cimitero'),('Alluvione',22,'2000-03-17','Industriale'),('Alluvione',55,'2008-11-28','Monte'),('Alluvione',45,'2019-05-22','QT'),('Alluvione',60,'2009-10-22','Spazzavento'),('Alluvione',70,'2009-06-12','Stazione'),('Alluvione',42,'2021-04-29','Villaggio'),('Frana',82,'2007-07-06','Monte'),('Frana',15,'2015-12-21','Spazzavento'),('Incendio',60,'2010-10-18','Industriale'),('Incendio',4,'2003-06-26','Mercato'),('Incendio',43,'2009-11-12','Spazzavento'),('Incendio',60,'2003-08-22','Stazione'),('Incendio',40,'2014-01-28','Villaggio'),('Liquefazione terreno',55,'2002-10-02','Padule'),('Liquefazione terreno',20,'2005-09-29','Spazzavento'),('Liquefazione terreno',78,'2003-03-12','Terme'),('Liquefazione terreno',5,'2001-12-14','Villaggio'),('Subsidenza',10,'2017-05-11','Industriale'),('Subsidenza',33,'2018-12-28','QT'),('Subsidenza',23,'2010-06-15','Stazione'),('Subsidenza',33,'2009-07-28','Terme'),('Subsidenza',20,'2000-07-07','Villaggio');
INSERT INTO `indirizzo` VALUES (1,86111,30,'Basi'),(2,86111,23,'XX Settembre'),(3,86112,795,'De Santis'),(4,86112,7,'Strada Marieva'),(5,86112,2,'Borgo Patrizio'),(6,86110,11,'Piazza Gioacchino'),(7,86113,15,'CEI'),(8,86113,34,'Della Repubblica'),(9,86113,42,'Lungo la Ferrovia'),(10,86114,6,'Greco'),(11,86114,2,'Della Costituzione'),(12,86115,80,'Italia'),(13,86116,1,'Maggio'),(14,86117,7,'Fontanelli'),(15,86116,2,'Caciagli'),(16,86118,3,'Castello');
INSERT INTO `edificio` VALUES ('Religioso',45,'Cimitero',14,43.43,10.23),('Industriale',88,'Industriale',10,43.53,10.32),('Industriale',91,'Industriale',11,43.53,10.32),('Industriale',34,'Mercato',12,43.51,10.26),('Residenziale',20,'Monte',13,43.51,10.24),('Residenziale',70,'Monte',15,43.51,10.24),('Agricolo',60,'Padule',6,43.48,10.37),('Residenziale',100,'QT',1,43.42,10.27),('Residenziale',89,'QT',2,43.44,10.29),('Residenziale',33,'Stazione',3,43.5,10.3),('Industriale',60,'Stazione',4,43.51,10.31),('Industriale',79,'Stazione',5,43.52,10.32),('Residenziale',92,'Terme',16,43.52,10.46),('Residenziale',100,'Villaggio',7,43.44,10.25),('Residenziale',100,'Villaggio',8,43.45,10.26),('Residenziale',35,'Villaggio',9,43.46,10.26);
INSERT INTO `vano` VALUES (1,5,4,0,3.5,3,'Balcone','QT',1),(2,3,3.5,1,3,3,'Balcone','QT',1),(3,2.7,3,1,3,3,'Terrazzo','QT',1),(4,2,3,1,3,3,'Assente','QT',1),(5,3.5,3.5,0,3.5,3.5,'Assente','QT',1),(6,3,3,0,3.5,3.5,'Assente','QT',1),(7,3,2.5,0,3,3,'Assente','QT',2),(8,3.2,2,0,3,3,'Balcone','QT',2),(9,3,2.8,0,2.7,2.7,'Assente','QT',2),(10,2,3,0,2.7,2,'Assente','QT',2),(11,2.3,2,2,3,3,'Terrazzo','Stazione',3),(12,2,3,2,3,3,'Assente','Stazione',3),(13,3,3,2,2.5,2.5,'Assente','Stazione',3),(14,20,15,0,10,2.7,'Assente','Stazione',4),(15,10,5,0,10,9,'Assente','Stazione',4),(16,3,5,1,10,9,'Assente','Stazione',4),(17,20,20,0,15,10,'Assente','Stazione',5),(18,10,4,0,15,15,'Assente','Padule',6),(19,7,9,0,15,15,'Assente','Padule',6),(20,5,10,0,15,15,'Assente','Padule',6),(21,13,2,0,15,10,'Assente','Padule',6),(22,3,11,0,10,10,'Assente','Padule',6),(23,5,17,0,10,8,'Balcone','Padule',6),(24,2,4,0,3,3,'Assente','Villaggio',7),(25,4,5,0,2.7,2.7,'Balcone','Villaggio',7),(26,2.5,3.3,1,2.7,2.7,'Assente','Villaggio',7),(27,3,4,0,2.7,2.7,'Assente','Villaggio',7),(28,3,2,1,2.7,2.7,'Terrazzo','Villaggio',7),(29,4,4,1,2.7,2.7,'Assente','Villaggio',7),(30,2,2,1,2.7,2.7,'Assente','Villaggio',7),(31,3,3,0,4,3,'Assente','Villaggio',8),(32,2,4,1,3,3,'Balcone','Villaggio',8),(33,4,3,0,3,2,'Assente','Villaggio',8),(34,2,4,1,3,3,'Balcone','Villaggio',8),(35,2,3,0,3,3,'Assente','Villaggio',8),(36,4,4,1,3,2,'Assente','Villaggio',8),(37,2,2,2,2,1,'Terrazzo','Villaggio',8),(38,4,4,1,4,3,'Assente','Villaggio',8),(39,3,3,1,4,4,'Balcone','Villaggio',9),(40,4,2,1,3,2.5,'Assente','Villaggio',9),(41,3,4,0,3.9,3.8,'Assente','Villaggio',9),(42,2,2,1,3,3,'Assente','Villaggio',9),(43,4,3,0,4,3,'Assente','Villaggio',9),(44,2,2,1,3,2,'Assente','Villaggio',9),(45,4,3,1,2.5,2,'Assente','Villaggio',9),(46,4,3,2,3,2,'Assente','Villaggio',9),(47,3,4,2,2.5,2.5,'Assente','Villaggio',9),(48,10,9,0,10,10,'Assente','Industriale',10),(49,15,12.5,0,9,8,'Assente','Industriale',11),(50,15,11,0,10,9,'Assente','Industriale',11),(51,5,5,0,2.9,2.9,'Balcone','Mercato',12),(52,3,4,0,2.9,2.9,'Assente','Mercato',12),(53,2.7,3,1,2.5,2.5,'Assente','Mercato',12),(54,4,4,1,2.5,2.5,'Assente','Mercato',12),(55,5,4.3,1,2.5,2.5,'Assente','Mercato',12),(56,2,2,0,2.9,1.7,'Assente','Mercato',12),(57,3,4,0,2.5,2,'Balcone','Monte',13),(58,3,3,0,3,2,'Assente','Monte',13),(59,2.5,2,0,2.8,2,'Assente','Monte',13),(60,1.9,3,0,2.9,2,'Assente','Monte',13),(61,2,4,0,3,2,'Assente','Monte',13),(62,3,1.8,-1,4,2,'Assente','Monte',13),(63,2,3,0,3,2,'Assente','Monte',13),(64,4,2,0,7,6.5,'Assente','Cimitero',14),(65,5,3,0,7,7,'Assente','Cimitero',14),(66,6,6,1,3,2,'Terrazzo','Cimitero',14),(67,3,3,0,3,3,'Assente','Monte',15),(68,3,3,1,3,3,'Assente','Monte',15),(69,3,3,2,3,3,'Assente','Monte',15),(70,3,4,0,2.8,2.8,'Balcone','Terme',16),(71,4,3,1,3,3,'Balcone','Terme',16),(72,2,3,0,2.8,2.8,'Balcone','Terme',16),(73,4,5,0,2.8,2.8,'Assente','Terme',16),(74,4,4,1,3,3,'Assente','Terme',16),(75,3,2,1,3,3,'Assente','Terme',16),(76,2.7,4,2,2.5,2.5,'Assente','Terme',16),(77,3.8,4,2,2.5,2.5,'Terrazzo','Terme',16),(78,3,3,1,3,3,'Assente','Terme',16);
INSERT INTO `funzionevano` VALUES (1,'Sala'),(2,'Camera'),(3,'Camera'),(4,'Bagno'),(5,'Cucina'),(6,'Studio'),(7,'Sala'),(8,'Bagno'),(9,'Cucina'),(10,'Camera'),(11,'Cucina'),(12,'Bagno'),(13,'Camera'),(14,'Magazzino'),(15,'Laboratorio'),(16,'Magazzino'),(17,'Magazzino'),(18,'Granaio'),(19,'Stalla'),(20,'Stalla'),(21,'Stalla'),(22,'Stalla'),(23,'Stalla'),(24,'Garage'),(25,'Cucina'),(26,'Bagno'),(27,'Bagno'),(28,'Camera'),(29,'Camera'),(30,'Sala'),(31,'Garage'),(32,'Studio'),(33,'Sala'),(34,'Camera'),(35,'Cucina'),(36,'Bagno'),(37,'Soffitta'),(38,'Camera'),(39,'Camera'),(40,'Bagno'),(41,'Camera'),(42,'Camera'),(43,'Cucina'),(44,'Bagno'),(45,'Sala'),(46,'Mansarda'),(47,'Lavanderia'),(48,'Magazzino'),(49,'Laboratorio'),(50,'Magazzino'),(51,'Camera'),(52,'Bagno'),(53,'Cucina'),(54,'Bagno'),(55,'Sala'),(56,'Ripostiglio'),(57,'Cucina'),(58,'Bagno'),(59,'Sala'),(60,'Camera'),(61,'Studio'),(62,'Taverna'),(63,'Bagno'),(64,'Chiesa'),(65,'Chiostro'),(66,'Sacrestia'),(67,'Bagno'),(68,'Cucina'),(69,'Bagno'),(70,'Bagno'),(71,'Camera'),(72,'Studio'),(73,'Sala'),(74,'Biblioteca'),(75,'Camera'),(76,'Cucina'),(77,'Bagno'),(78,'Ripostiglio');
INSERT INTO `materialegenerico` VALUES ('Asfalto',0.06,0.006,0.006,'Conglomerato bituminoso a freddo.'),('Calce',0.01,0.001,0.001,'Prodotto minerale non siliceo per sabbiature a secco.'),('Corda in Ferro',50,0.2,0.002,'Corda universale in poliammide.'),('Ghiaia',0.01,0.008,0.008,'Miscela di aggregati per MAPECEM in granulometria assortita da 0 a 8 mm.'),('Lamiera',6,5,0.0006,'Lamiera grecata per pareti e soffitto.'),('Materiale per installazione servizi',0.01,NULL,NULL,'Materiale per linstallazione degli impianti: gas'),('Pannello',0.05,0.05,0.01,'Pannello a rete stirata metallica.'),('Pannello Preformato',2,2,0.02,'Pannello preformato accoppiata a Lamiera esterna.'),('Perlite',0.05,0.005,0.005,'La perlite ha la capacitÃ  di espandere il proprio volume fino a 20 volte rispetto a quello originale quando viene portata ad elevate temperature'),('Policarbonato',4,4,0.01,'Lastra opaca.'),('Quarzo',0.03,0.003,0.003,'Sabbie di quarzo lavate ed essiccate a forno da utilizzarsi con resine epossidiche e poliuretaniche.'),('Resina',0.01,NULL,NULL,'Resina per lastre di vetro.'),('Resina Indurente',0.01,NULL,NULL,'Resina termoindurente.'),('Rete',10,10,0.0085,'Rete stirata per rivestimenti.'),('Sabbia',0.01,0.001,0.001,'Sabbia silicea naturale, lavata e vagliata del fiume Po.'),('Vernice',0.01,NULL,NULL,'Vernice per interni.');
INSERT INTO `piastrella` VALUES ('Cementum','Piastrella',0.03,4,'Porcellana','Ash Arc',0.9,0.5,'Piastrella Gres Di Porcellana'),('Grande Marble','Piastrella',0.05,6,'Marmo','Naturale',0.25,0.25,'Piastrella In Marmo'),('Legno','Lastra di Legno',NULL,NULL,'Legno',NULL,0.9,0.7,'Lastra di Legno Per Parquet'),('Memoria','Piastrella',0.07,4,'Porcellana','Naturale',1.15,0.3,'Piastrella Gres In Pietrisco'),('Mystone travertino','Piastrella',0.02,4,'Pietra','Classico Botanico',0.8,0.6,'Piastrella Gres In Pietrisco'),('Pietra','Pietra',NULL,NULL,'Pietra',NULL,0.7,0.8,'Lastra Di Pietra'),('Poster','Piastrella',0.08,8,'Porcellana','Exotic',0.47,0.03,'Piastrella Gres Di Porcellana'),('Uniche','Piastrella',0.05,3,'Pietra','Arles',0.15,0.3,'Piastrella Gres In Pietrisco'),('Vero','Piastrella',0.45,5,'Porcellana','Floreale',0.46,4.23,'Piastrella Gres Di Porcellana');
INSERT INTO `mattone` VALUES ('Alveolater',0.01,1,'malta',0.25,0.19,0.2,'Mattone alveolato vuoto.'),('Blocco di cemento',0.02,0,'cemento',0.12,0.25,0.12,'Blocco di cemento alveolato vuoto.'),('Mattone 2 fori',0.02,1,'cemento',0.2,0.19,0.2,'Blocco di cemento alveolato con polistirolo.'),('Mattone in laterizio',NULL,0,'argilla- sabbia e ossidi',0.055,0.12,0.25,'Mattone pieno in laterizio.'),('Mattone in terra cruda',NULL,0,'Argilla-Sabbia- Paglia',0.085,0.105,0.215,'Mattone pieno in terra dura.'),('Mattone semipieno',0.01,1,'argilla- sabbia e ossidi',0.055,0.12,0.25,'Mattone alveolato con poliuretano espanso.');
INSERT INTO `intonaco` VALUES ('Beton Cire','Cementizio','Intonaco cementizio.'),('Granol','Calce','Calce da rifinitura.'),('Intonaco argilloso','Argilla','Intonaco argilloso da rifinitura.'),('Intonaco civile','Premiscelato','Premiscelato argilloso da rifinitura.'),('KP3','Cementizio','Intonaco cementizio.'),('MP2','Gesso','Intonaco in polvere di gesso da esterno.'),('Rofix','Calce idrata','Intonaco in calce idrata.'),('Spachtelputz','Calce','Calce da rifinitura.');
INSERT INTO `superficie` VALUES (1,'Soffitto',NULL,NULL,1,'Resina indurente','Cementum','Mattone in terra cruda'),(2,'Pavimento',0.002,'Naturale',1,NULL,'Cementum','Mattone in terra cruda'),(3,'Parete1',NULL,NULL,1,'Quarzo',NULL,'Mattone in terra cruda'),(4,'Parete2',NULL,NULL,1,'Policarbonato',NULL,'Mattone in laterizio'),(5,'Parete3',NULL,NULL,1,NULL,NULL,'Mattone in terra cruda'),(6,'Parete4',NULL,NULL,1,'Resina indurente',NULL,'Mattone in terra cruda'),(7,'Soffitto',NULL,NULL,2,NULL,NULL,'Mattone in terra cruda'),(8,'Pavimento',0.004,'Orizzontale',2,NULL,'Grande Marble','Mattone in laterizio'),(9,'Parete1',NULL,NULL,2,'Rete',NULL,'Mattone in terra cruda'),(10,'Parete2',NULL,NULL,2,'Corda in Ferro',NULL,'Mattone in terra cruda'),(11,'Parete3',NULL,NULL,2,'Perlite',NULL,'Mattone in terra cruda'),(12,'Parete4',NULL,NULL,2,'Ghiaia',NULL,'Mattone in laterizio'),(13,'Soffitto',NULL,NULL,3,NULL,NULL,'Alveolater'),(14,'Pavimento',0.004,'Orizzontale',3,NULL,'Poster','Alveolater'),(15,'Parete1',NULL,NULL,3,NULL,NULL,'Alveolater'),(16,'Parete2',NULL,NULL,3,NULL,NULL,'Alveolater'),(17,'Parete3',NULL,NULL,3,'Sabbia',NULL,'Alveolater'),(18,'Parete4',NULL,NULL,3,NULL,NULL,'Alveolater'),(19,'Soffitto',NULL,NULL,4,NULL,NULL,'Alveolater'),(20,'Pavimento',0.001,'Naturale',4,'Pannello','Mystone travertino','Alveolater'),(21,'Parete1',NULL,NULL,4,'Pannello Preformato',NULL,'Mattone semipieno'),(22,'Parete2',NULL,NULL,4,NULL,NULL,'Blocco di cemento'),(23,'Parete3',NULL,NULL,4,NULL,NULL,'Blocco di cemento'),(24,'Parete4',NULL,NULL,4,NULL,NULL,'Blocco di cemento'),(25,'Soffitto',NULL,NULL,5,NULL,NULL,'Blocco di cemento'),(26,'Pavimento',0.006,'Verticale',5,'Lamiera','Vero','Blocco di cemento'),(27,'Parete1',NULL,NULL,5,NULL,NULL,'Mattone 2 fori'),(28,'Parete2',NULL,NULL,5,NULL,NULL,'Mattone 2 fori'),(29,'Parete3',NULL,NULL,5,'Resina',NULL,'Mattone 2 fori'),(30,'Parete4',NULL,NULL,5,NULL,NULL,'Mattone 2 fori'),(31,'Soffitto',NULL,NULL,6,'Quarzo',NULL,'Mattone 2 fori'),(32,'Pavimento',NULL,NULL,6,'Policarbonato','Legno','Blocco di cemento'),(33,'Parete1',NULL,NULL,6,NULL,NULL,'Blocco di cemento'),(34,'Parete2',NULL,NULL,6,'Resina Indurente',NULL,'Blocco di cemento'),(35,'Parete3',NULL,NULL,6,NULL,NULL,'Mattone 2 fori'),(36,'Parete4',NULL,NULL,6,NULL,NULL,'Mattone 2 fori'),(37,'Soffitto',NULL,NULL,7,'Rete',NULL,'Mattone 2 fori'),(38,'Pavimento',0.006,'Naturale',7,'Corda in Ferro','Memoria','Mattone in terra cruda'),(39,'Parete1',NULL,NULL,7,'Perlite',NULL,'Mattone in laterizio'),(40,'Parete2',NULL,NULL,7,'Ghiaia',NULL,'Mattone in terra cruda'),(41,'Parete3',NULL,NULL,7,NULL,NULL,'Mattone in terra cruda'),(42,'Parete4',NULL,NULL,7,NULL,NULL,'Mattone in terra cruda'),(43,'Soffitto',NULL,NULL,8,NULL,NULL,'Mattone in laterizio'),(44,'Pavimento',0.001,'Verticale',8,NULL,'Uniche','Alveolater'),(45,'Parete1',NULL,NULL,8,'Sabbia',NULL,'Alveolater'),(46,'Parete2',NULL,NULL,8,NULL,NULL,'Alveolater'),(47,'Parete3',NULL,NULL,8,NULL,NULL,'Alveolater'),(48,'Parete4',NULL,NULL,8,'Pannello',NULL,'Alveolater'),(49,'Soffitto',NULL,NULL,9,'Pannello Preformato',NULL,'Alveolater'),(50,'Pavimento',0.01,'Orizzontale',9,NULL,'Cementum','Alveolater'),(51,'Parete1',NULL,NULL,9,NULL,NULL,'Alveolater'),(52,'Parete2',NULL,NULL,9,NULL,NULL,'Mattone semipieno'),(53,'Parete3',NULL,NULL,9,NULL,NULL,'Blocco di cemento'),(54,'Parete4',NULL,NULL,9,'Lamiera',NULL,'Blocco di cemento'),(55,'Soffitto',NULL,NULL,10,NULL,NULL,'Blocco di cemento'),(56,'Pavimento',NULL,NULL,10,NULL,'Pietra','Blocco di cemento'),(57,'Parete1',NULL,NULL,10,'Resina',NULL,'Blocco di cemento'),(58,'Parete2',NULL,NULL,10,NULL,'Legno','Mattone 2 fori'),(59,'Parete3',NULL,NULL,10,'Quarzo','Legno','Mattone 2 fori'),(60,'Parete4',NULL,NULL,10,'Policarbonato',NULL,'Mattone 2 fori'),(61,'Soffitto',NULL,NULL,11,NULL,NULL,'Alveolater'),(62,'Pavimento',NULL,NULL,11,'Resina Indurente','Legno','Alveolater'),(63,'Parete1',NULL,NULL,11,NULL,NULL,'Alveolater'),(64,'Parete2',NULL,NULL,11,NULL,NULL,'Mattone semipieno'),(65,'Parete3',NULL,NULL,11,'Rete',NULL,'Blocco di cemento'),(66,'Parete4',NULL,NULL,11,'Corda in Ferro',NULL,'Blocco di cemento'),(67,'Soffitto',NULL,NULL,12,'Perlite',NULL,'Blocco di cemento'),(68,'Pavimento',NULL,NULL,12,'Ghiaia','Pietra','Blocco di cemento'),(69,'Parete1',NULL,NULL,12,NULL,NULL,'Blocco di cemento'),(70,'Parete2',NULL,NULL,12,NULL,NULL,'Mattone 2 fori'),(71,'Parete3',NULL,NULL,12,NULL,'Pietra','Mattone 2 fori'),(72,'Parete4',NULL,NULL,12,NULL,NULL,'Mattone 2 fori'),(73,'Soffitto',NULL,NULL,13,'Sabbia',NULL,'Mattone 2 fori'),(74,'Pavimento',0.03,'Orizzontale',13,NULL,'Grande Marble','Mattone 2 fori'),(75,'Parete1',NULL,NULL,13,NULL,NULL,'Blocco di cemento'),(76,'Parete2',NULL,NULL,13,'Pannello',NULL,'Blocco di cemento'),(77,'Parete3',NULL,NULL,13,'Pannello Preformato',NULL,'Blocco di cemento'),(78,'Parete4',NULL,NULL,13,NULL,NULL,'Mattone 2 fori'),(79,'Soffitto',NULL,NULL,14,NULL,NULL,'Mattone 2 fori'),(80,'Pavimento',0.001,'Verticale',14,NULL,'Poster','Mattone 2 fori'),(81,'Parete1',NULL,NULL,14,NULL,NULL,'Mattone in terra cruda'),(82,'Parete2',NULL,NULL,14,'Lamiera',NULL,'Mattone in laterizio'),(83,'Parete3',NULL,NULL,14,NULL,NULL,'Mattone in terra cruda'),(84,'Parete4',NULL,NULL,14,NULL,NULL,'Mattone in terra cruda'),(85,'Soffitto',NULL,NULL,15,'Resina',NULL,'Mattone in terra cruda'),(86,'Pavimento',0.067,'Naturale',15,NULL,'Mystone travertino','Mattone in laterizio'),(87,'Parete1',NULL,NULL,15,'Quarzo',NULL,'Alveolater'),(88,'Parete2',NULL,NULL,15,'Policarbonato',NULL,'Alveolater'),(89,'Parete3',NULL,NULL,15,NULL,NULL,'Alveolater'),(90,'Parete4',NULL,NULL,15,'Resina Indurente',NULL,'Alveolater'),(91,'Soffitto',NULL,NULL,16,NULL,NULL,'Alveolater'),(92,'Pavimento',NULL,NULL,16,NULL,'Legno','Mattone in terra cruda'),(93,'Parete1',NULL,NULL,16,'Rete',NULL,'Mattone in terra cruda'),(94,'Parete2',NULL,NULL,16,'Corda in Ferro',NULL,'Mattone in terra cruda'),(95,'Parete3',NULL,NULL,16,'Perlite',NULL,'Mattone in laterizio'),(96,'Parete4',NULL,NULL,16,'Ghiaia',NULL,'Mattone in terra cruda'),(97,'Soffitto',NULL,NULL,17,NULL,NULL,'Mattone in terra cruda'),(98,'Pavimento',0.07,'Naturale',17,NULL,'Vero','Mattone in terra cruda'),(99,'Parete1',NULL,NULL,17,NULL,NULL,'Mattone in laterizio'),(100,'Parete2',NULL,NULL,17,NULL,'Pietra','Mattone in terra cruda'),(101,'Parete3',NULL,NULL,17,'Sabbia',NULL,'Mattone in terra cruda'),(102,'Parete4',NULL,NULL,17,NULL,NULL,'Mattone in terra cruda'),(103,'Soffitto',NULL,NULL,18,NULL,NULL,'Mattone in laterizio'),(104,'Pavimento',0.009,'Orizzontale',18,'Pannello','Memoria','Alveolater'),(105,'Parete1',NULL,NULL,18,'Pannello Preformato',NULL,'Alveolater'),(106,'Parete2',NULL,NULL,18,NULL,NULL,'Alveolater'),(107,'Parete3',NULL,NULL,18,NULL,NULL,'Alveolater'),(108,'Parete4',NULL,NULL,18,NULL,NULL,'Alveolater'),(109,'Soffitto',NULL,NULL,19,NULL,NULL,'Alveolater'),(110,'Pavimento',0.008,'Verticale',19,'Lamiera','Uniche','Alveolater'),(111,'Parete1',NULL,NULL,19,NULL,NULL,'Alveolater'),(112,'Parete2',NULL,NULL,19,NULL,NULL,'Mattone semipieno'),(113,'Parete3',NULL,NULL,19,'Resina',NULL,'Blocco di cemento'),(114,'Parete4',NULL,NULL,19,NULL,'Pietra','Blocco di cemento'),(115,'Soffitto',NULL,NULL,20,'Quarzo',NULL,'Blocco di cemento'),(116,'Pavimento',NULL,NULL,20,'Policarbonato','Pietra','Blocco di cemento'),(117,'Parete1',NULL,NULL,20,NULL,NULL,'Blocco di cemento'),(118,'Parete2',NULL,NULL,20,'Resina Indurente',NULL,'Mattone 2 fori'),(119,'Parete3',NULL,NULL,20,NULL,NULL,'Mattone 2 fori'),(120,'Parete4',NULL,NULL,20,NULL,NULL,'Mattone 2 fori'),(121,'Soffitto',NULL,NULL,21,'Rete',NULL,'Mattone 2 fori'),(122,'Pavimento',0.005,'Orizzontale',21,'Corda in Ferro','Cementum','Mattone 2 fori'),(123,'Parete1',NULL,NULL,21,'Perlite',NULL,'Blocco di cemento'),(124,'Parete2',NULL,NULL,21,'Ghiaia',NULL,'Blocco di cemento'),(125,'Parete3',NULL,NULL,21,NULL,NULL,'Blocco di cemento'),(126,'Parete4',NULL,NULL,21,NULL,NULL,'Mattone 2 fori'),(127,'Soffitto',NULL,NULL,22,NULL,NULL,'Mattone 2 fori'),(128,'Pavimento',0.009,'Verticale',22,NULL,'Cementum','Mattone 2 fori'),(129,'Parete1',NULL,NULL,22,'Sabbia',NULL,'Mattone in laterizio'),(130,'Parete2',NULL,NULL,22,NULL,'Pietra','Alveolater'),(131,'Parete3',NULL,NULL,22,NULL,NULL,'Alveolater'),(132,'Parete4',NULL,NULL,22,'Pannello','Pietra','Alveolater'),(133,'Soffitto',NULL,NULL,23,'Pannello Preformato',NULL,'Alveolater'),(134,'Pavimento',0.09,'Naturale',23,NULL,'Grande Marble','Alveolater'),(135,'Parete1',NULL,NULL,23,NULL,NULL,'Alveolater'),(136,'Parete2',NULL,NULL,23,NULL,NULL,'Alveolater'),(137,'Parete3',NULL,NULL,23,NULL,NULL,'Alveolater'),(138,'Parete4',NULL,NULL,23,'Lamiera',NULL,'Mattone semipieno'),(139,'Soffitto',NULL,NULL,24,NULL,NULL,'Blocco di cemento'),(140,'Pavimento',NULL,NULL,24,NULL,'Legno','Blocco di cemento'),(141,'Parete1',NULL,NULL,24,'Policarbonato',NULL,'Blocco di cemento'),(142,'Parete2',NULL,NULL,24,NULL,NULL,'Blocco di cemento'),(143,'Parete3',NULL,NULL,24,'Resina Indurente','Pietra','Blocco di cemento'),(144,'Parete4',NULL,NULL,24,NULL,'Pietra','Mattone 2 fori'),(145,'Soffitto',NULL,NULL,25,NULL,NULL,'Mattone 2 fori'),(146,'Pavimento',0.006,'Orizzontale',25,'Rete','Vero','Mattone 2 fori'),(147,'Parete1',NULL,NULL,25,'Corda in Ferro',NULL,'Mattone 2 fori'),(148,'Parete2',NULL,NULL,25,'Perlite',NULL,'Mattone 2 fori'),(149,'Parete3',NULL,NULL,25,'Ghiaia',NULL,'Blocco di cemento'),(150,'Parete4',NULL,NULL,25,NULL,NULL,'Blocco di cemento'),(151,'Soffitto',NULL,NULL,26,NULL,NULL,'Blocco di cemento'),(152,'Pavimento',0.009,'Orizzontale',26,NULL,'Vero','Mattone 2 fori'),(153,'Parete1',NULL,NULL,26,NULL,NULL,'Mattone 2 fori'),(154,'Parete2',NULL,NULL,26,'Sabbia','Pietra','Mattone 2 fori'),(155,'Parete3',NULL,NULL,26,NULL,NULL,'Mattone in terra cruda'),(156,'Parete4',NULL,NULL,26,NULL,NULL,'Mattone in laterizio'),(157,'Soffitto',NULL,NULL,27,'Pannello',NULL,'Mattone in terra cruda'),(158,'Pavimento',0.09,'Verticale',27,'Pannello Preformato','Vero','Mattone in terra cruda'),(159,'Parete1',NULL,NULL,27,NULL,NULL,'Mattone in terra cruda'),(160,'Parete2',NULL,NULL,27,NULL,NULL,'Mattone in laterizio'),(161,'Parete3',NULL,NULL,27,'Policarbonato',NULL,'Alveolater'),(162,'Parete4',NULL,NULL,27,NULL,NULL,'Alveolater'),(163,'Soffitto',NULL,NULL,28,'Resina Indurente',NULL,'Alveolater'),(164,'Pavimento',0.009,'Naturale',28,NULL,'Poster','Alveolater'),(165,'Parete1',NULL,NULL,28,NULL,NULL,'Alveolater'),(166,'Parete2',NULL,NULL,28,'Rete',NULL,'Alveolater'),(167,'Parete3',NULL,NULL,28,'Corda in Ferro',NULL,'Alveolater'),(168,'Parete4',NULL,NULL,28,'Perlite',NULL,'Alveolater'),(169,'Soffitto',NULL,NULL,29,'Ghiaia',NULL,'Mattone semipieno'),(170,'Pavimento',0.003,'Verticale',29,NULL,'Poster','Blocco di cemento'),(171,'Parete1',NULL,NULL,29,NULL,NULL,'Blocco di cemento'),(172,'Parete2',NULL,NULL,29,NULL,'Pietra','Blocco di cemento'),(173,'Parete3',NULL,NULL,29,NULL,NULL,'Blocco di cemento'),(174,'Parete4',NULL,NULL,29,'Sabbia',NULL,'Blocco di cemento'),(175,'Soffitto',NULL,NULL,30,NULL,NULL,'Mattone 2 fori'),(176,'Pavimento',0.03,'Orizzontale',30,NULL,'Poster','Mattone 2 fori'),(177,'Parete1',NULL,NULL,30,'Pannello',NULL,'Mattone 2 fori'),(178,'Parete2',NULL,NULL,30,'Pannello Preformato',NULL,'Alveolater'),(179,'Parete3',NULL,NULL,30,NULL,NULL,'Alveolater'),(180,'Parete4',NULL,NULL,30,NULL,NULL,'Alveolater'),(181,'Soffitto',NULL,NULL,31,NULL,NULL,'Mattone semipieno'),(182,'Pavimento',0.008,'Naturale',31,'Sabbia','Poster','Blocco di cemento'),(183,'Parete1',NULL,NULL,31,NULL,NULL,'Blocco di cemento'),(184,'Parete2',NULL,NULL,31,NULL,NULL,'Blocco di cemento'),(185,'Parete3',NULL,NULL,31,'Pannello',NULL,'Blocco di cemento'),(186,'Parete4',NULL,NULL,31,'Pannello Preformato',NULL,'Blocco di cemento'),(187,'Soffitto',NULL,NULL,32,NULL,NULL,'Mattone 2 fori'),(188,'Pavimento',0.009,'Naturale',32,NULL,'Grande Marble','Mattone 2 fori'),(189,'Parete1',NULL,NULL,32,NULL,NULL,'Mattone 2 fori'),(190,'Parete2',NULL,NULL,32,NULL,'Pietra','Mattone 2 fori'),(191,'Parete3',NULL,NULL,32,'Lamiera','Pietra','Mattone 2 fori'),(192,'Parete4',NULL,NULL,32,NULL,'Pietra','Blocco di cemento'),(193,'Soffitto',NULL,NULL,33,NULL,NULL,'Blocco di cemento'),(194,'Pavimento',0.008,'Verticale',33,'Policarbonato','Grande Marble','Blocco di cemento'),(195,'Parete1',NULL,NULL,33,NULL,NULL,'Mattone 2 fori'),(196,'Parete2',NULL,NULL,33,'Resina Indurente',NULL,'Mattone 2 fori'),(197,'Parete3',NULL,NULL,33,NULL,NULL,'Mattone 2 fori'),(198,'Parete4',NULL,NULL,33,NULL,'Pietra','Mattone in terra cruda'),(199,'Soffitto',NULL,NULL,34,'Rete','Pietra','Mattone in laterizio'),(200,'Pavimento',0.009,'Naturale',34,'Corda in Ferro','Grande Marble','Mattone in terra cruda'),(201,'Parete1',NULL,NULL,34,'Perlite',NULL,'Mattone in terra cruda'),(202,'Parete2',NULL,NULL,34,'Ghiaia',NULL,'Mattone in terra cruda'),(203,'Parete3',NULL,NULL,34,NULL,NULL,'Mattone in laterizio'),(204,'Parete4',NULL,NULL,34,NULL,NULL,'Alveolater'),(205,'Soffitto',NULL,NULL,35,NULL,NULL,'Alveolater'),(206,'Pavimento',0.007,'Verticale',35,NULL,'Grande Marble','Alveolater'),(207,'Parete1',NULL,NULL,35,'Sabbia',NULL,'Alveolater'),(208,'Parete2',NULL,NULL,35,NULL,NULL,'Alveolater'),(209,'Parete3',NULL,NULL,35,NULL,NULL,'Mattone in terra cruda'),(210,'Parete4',NULL,NULL,35,'Pannello',NULL,'Mattone in terra cruda'),(211,'Soffitto',NULL,NULL,36,'Pannello Preformato',NULL,'Mattone in terra cruda'),(212,'Pavimento',NULL,NULL,36,NULL,'Legno','Mattone in laterizio'),(213,'Parete1',NULL,NULL,36,NULL,NULL,'Mattone in terra cruda'),(214,'Parete2',NULL,NULL,36,'Policarbonato',NULL,'Mattone in terra cruda'),(215,'Parete3',NULL,NULL,36,NULL,NULL,'Mattone in terra cruda'),(216,'Parete4',NULL,NULL,36,'Resina Indurente',NULL,'Mattone in laterizio'),(217,'Soffitto',NULL,NULL,37,NULL,NULL,'Mattone in terra cruda'),(218,'Pavimento',0.009,'Orizzontale',37,NULL,'Cementum','Mattone in terra cruda'),(219,'Parete1',NULL,NULL,37,'Rete',NULL,'Mattone in terra cruda'),(220,'Parete2',NULL,NULL,37,'Corda in Ferro',NULL,'Mattone in laterizio'),(221,'Parete3',NULL,NULL,37,'Perlite',NULL,'Alveolater'),(222,'Parete4',NULL,NULL,37,'Ghiaia',NULL,'Alveolater'),(223,'Soffitto',NULL,NULL,38,NULL,NULL,'Alveolater'),(224,'Pavimento',0.003,'Verticale',38,NULL,'Cementum','Alveolater'),(225,'Parete1',NULL,NULL,38,NULL,NULL,'Alveolater'),(226,'Parete2',NULL,NULL,38,NULL,NULL,'Alveolater'),(227,'Parete3',NULL,NULL,38,'Sabbia',NULL,'Alveolater'),(228,'Parete4',NULL,NULL,38,NULL,NULL,'Alveolater'),(229,'Soffitto',NULL,NULL,39,NULL,NULL,'Mattone semipieno'),(230,'Pavimento',0.007,'Verticale',39,'Pannello','Cementum','Blocco di cemento'),(231,'Parete1',NULL,NULL,39,'Pannello Preformato',NULL,'Blocco di cemento'),(232,'Parete2',NULL,NULL,39,NULL,NULL,'Blocco di cemento'),(233,'Parete3',NULL,NULL,39,'Pannello','Pietra','Blocco di cemento'),(234,'Parete4',NULL,NULL,39,'Pannello Preformato','Pietra','Blocco di cemento'),(235,'Soffitto',NULL,NULL,40,NULL,NULL,'Mattone 2 fori'),(236,'Pavimento',0.005,'Verticale',40,NULL,'Cementum','Mattone 2 fori'),(237,'Parete1',NULL,NULL,40,'Policarbonato',NULL,'Mattone 2 fori'),(238,'Parete2',NULL,NULL,40,NULL,NULL,'Mattone 2 fori'),(239,'Parete3',NULL,NULL,40,'Resina Indurente',NULL,'Mattone 2 fori'),(240,'Parete4',NULL,NULL,40,NULL,NULL,'Blocco di cemento'),(241,'Soffitto',NULL,NULL,41,NULL,NULL,'Blocco di cemento'),(242,'Pavimento',0.009,'Orizzontale',41,'Rete','Cementum','Blocco di cemento'),(243,'Parete1',NULL,NULL,41,'Corda in Ferro',NULL,'Mattone 2 fori'),(244,'Parete2',NULL,NULL,41,'Perlite',NULL,'Alveolater'),(245,'Parete3',NULL,NULL,41,'Ghiaia',NULL,'Mattone semipieno'),(246,'Parete4',NULL,NULL,41,NULL,NULL,'Blocco di cemento'),(247,'Soffitto',NULL,NULL,42,NULL,NULL,'Blocco di cemento'),(248,'Pavimento',0.006,'Orizzontale',42,NULL,'Poster','Blocco di cemento'),(249,'Parete1',NULL,NULL,42,NULL,NULL,'Blocco di cemento'),(250,'Parete2',NULL,NULL,42,'Sabbia',NULL,'Blocco di cemento'),(251,'Parete3',NULL,NULL,42,NULL,NULL,'Mattone 2 fori'),(252,'Parete4',NULL,NULL,42,NULL,NULL,'Mattone 2 fori'),(253,'Soffitto',NULL,NULL,43,'Pannello',NULL,'Mattone 2 fori'),(254,'Pavimento',0.008,'Orizzontale',43,'Pannello Preformato','Poster','Mattone 2 fori'),(255,'Parete1',NULL,NULL,43,NULL,NULL,'Mattone 2 fori'),(256,'Parete2',NULL,NULL,43,'Pannello',NULL,'Blocco di cemento'),(257,'Parete3',NULL,NULL,43,'Pannello Preformato',NULL,'Blocco di cemento'),(258,'Parete4',NULL,NULL,43,NULL,NULL,'Blocco di cemento'),(259,'Soffitto',NULL,NULL,44,NULL,NULL,'Mattone 2 fori'),(260,'Pavimento',0.009,'Verticale',44,'Policarbonato','Poster','Mattone 2 fori'),(261,'Parete1',NULL,NULL,44,NULL,NULL,'Mattone 2 fori'),(262,'Parete2',NULL,NULL,44,'Resina Indurente',NULL,'Mattone in laterizio'),(263,'Parete3',NULL,NULL,44,NULL,NULL,'Alveolater'),(264,'Parete4',NULL,NULL,44,NULL,'Pietra','Alveolater'),(265,'Soffitto',NULL,NULL,45,'Rete',NULL,'Alveolater'),(266,'Pavimento',0.05,'Naturale',45,'Corda in Ferro','Poster','Alveolater'),(267,'Parete1',NULL,NULL,45,'Perlite',NULL,'Alveolater'),(268,'Parete2',NULL,NULL,45,'Ghiaia',NULL,'Alveolater'),(269,'Parete3',NULL,NULL,45,NULL,NULL,'Alveolater'),(270,'Parete4',NULL,NULL,45,NULL,NULL,'Alveolater'),(271,'Soffitto',NULL,NULL,46,NULL,NULL,'Mattone semipieno'),(272,'Pavimento',0.05,'Naturale',46,NULL,'Poster','Blocco di cemento'),(273,'Parete1',NULL,NULL,46,'Sabbia',NULL,'Blocco di cemento'),(274,'Parete2',NULL,NULL,46,NULL,NULL,'Blocco di cemento'),(275,'Parete3',NULL,NULL,46,NULL,NULL,'Blocco di cemento'),(276,'Parete4',NULL,NULL,46,'Pannello',NULL,'Blocco di cemento'),(277,'Soffitto',NULL,NULL,47,'Pannello Preformato',NULL,'Blocco di cemento'),(278,'Pavimento',NULL,NULL,47,'Rete','Legno','Blocco di cemento'),(279,'Parete1',NULL,NULL,47,'Corda in Ferro',NULL,'Mattone 2 fori'),(280,'Parete2',NULL,NULL,47,'Perlite',NULL,'Mattone 2 fori'),(281,'Parete3',NULL,NULL,47,'Ghiaia',NULL,'Mattone 2 fori'),(282,'Parete4',NULL,NULL,47,NULL,NULL,'Mattone 2 fori'),(283,'Soffitto',NULL,NULL,48,NULL,NULL,'Mattone 2 fori'),(284,'Pavimento',0.003,'Naturale',48,NULL,'Poster','Blocco di cemento'),(285,'Parete1',NULL,NULL,48,NULL,NULL,'Blocco di cemento'),(286,'Parete2',NULL,NULL,48,'Sabbia',NULL,'Blocco di cemento'),(287,'Parete3',NULL,NULL,48,NULL,NULL,'Mattone 2 fori'),(288,'Parete4',NULL,NULL,48,NULL,NULL,'Alveolater'),(289,'Soffitto',NULL,NULL,49,'Pannello',NULL,'Mattone semipieno'),(290,'Pavimento',0.003,'Naturale',49,'Pannello Preformato','Poster','Blocco di cemento'),(291,'Parete1',NULL,NULL,49,NULL,NULL,'Blocco di cemento'),(292,'Parete2',NULL,NULL,49,'Pannello',NULL,'Blocco di cemento'),(293,'Parete3',NULL,NULL,49,'Pannello Preformato','Pietra','Blocco di cemento'),(294,'Parete4',NULL,NULL,49,NULL,NULL,'Blocco di cemento'),(295,'Soffitto',NULL,NULL,50,NULL,NULL,'Mattone in terra cruda'),(296,'Pavimento',0.006,'Verticale',50,'Policarbonato','Poster','Mattone in terra cruda'),(297,'Parete1',NULL,NULL,50,NULL,NULL,'Mattone in terra cruda'),(298,'Parete2',NULL,NULL,50,'Resina Indurente',NULL,'Mattone in laterizio'),(299,'Parete3',NULL,NULL,50,NULL,NULL,'Mattone in terra cruda'),(300,'Parete4',NULL,NULL,50,NULL,NULL,'Mattone in terra cruda'),(301,'Soffitto',NULL,NULL,51,'Rete',NULL,'Mattone in terra cruda'),(302,'Pavimento',0.006,'Orizzontale',51,'Corda in Ferro','Uniche','Mattone in laterizio'),(303,'Parete1',NULL,NULL,51,'Perlite',NULL,'Mattone in terra cruda'),(304,'Parete2',NULL,NULL,51,'Ghiaia',NULL,'Mattone in terra cruda'),(305,'Parete3',NULL,NULL,51,NULL,NULL,'Mattone in terra cruda'),(306,'Parete4',NULL,NULL,51,NULL,NULL,'Mattone in laterizio'),(307,'Soffitto',NULL,NULL,52,NULL,NULL,'Alveolater'),(308,'Pavimento',0.003,'Verticale',52,NULL,'Uniche','Alveolater'),(309,'Parete1',NULL,NULL,52,'Sabbia',NULL,'Alveolater'),(310,'Parete2',NULL,NULL,52,NULL,NULL,'Alveolater'),(311,'Parete3',NULL,NULL,52,NULL,NULL,'Alveolater'),(312,'Parete4',NULL,NULL,52,'Pannello',NULL,'Alveolater'),(313,'Soffitto',NULL,NULL,53,'Pannello Preformato',NULL,'Alveolater'),(314,'Pavimento',0.003,'Naturale',53,NULL,'Uniche','Alveolater'),(315,'Parete1',NULL,NULL,53,'Pannello',NULL,'Mattone semipieno'),(316,'Parete2',NULL,NULL,53,'Pannello Preformato',NULL,'Blocco di cemento'),(317,'Parete3',NULL,NULL,53,NULL,NULL,'Blocco di cemento'),(318,'Parete4',NULL,NULL,53,NULL,NULL,'Blocco di cemento'),(319,'Soffitto',NULL,NULL,54,'Policarbonato',NULL,'Blocco di cemento'),(320,'Pavimento',0.008,'Orizzontale',54,NULL,'Uniche','Blocco di cemento'),(321,'Parete1',NULL,NULL,54,'Resina Indurente',NULL,'Mattone 2 fori'),(322,'Parete2',NULL,NULL,54,NULL,NULL,'Mattone 2 fori'),(323,'Parete3',NULL,NULL,54,NULL,'Pietra','Mattone 2 fori'),(324,'Parete4',NULL,NULL,54,'Rete','Pietra','Mattone 2 fori'),(325,'Soffitto',NULL,NULL,55,'Corda in Ferro',NULL,'Mattone 2 fori'),(326,'Pavimento',0.009,'Orizzontale',55,'Perlite','Uniche','Blocco di cemento'),(327,'Parete1',NULL,NULL,55,'Ghiaia',NULL,'Blocco di cemento'),(328,'Parete2',NULL,NULL,55,NULL,NULL,'Blocco di cemento'),(329,'Parete3',NULL,NULL,55,NULL,NULL,'Mattone 2 fori'),(330,'Parete4',NULL,NULL,55,NULL,NULL,'Mattone 2 fori'),(331,'Soffitto',NULL,NULL,56,NULL,NULL,'Mattone 2 fori'),(332,'Pavimento',0.007,'Verticale',56,'Sabbia','Memoria','Mattone in terra cruda'),(333,'Parete1',NULL,NULL,56,NULL,NULL,'Mattone in laterizio'),(334,'Parete2',NULL,NULL,56,NULL,'Pietra','Mattone in terra cruda'),(335,'Parete3',NULL,NULL,56,'Pannello','Pietra','Mattone in terra cruda'),(336,'Parete4',NULL,NULL,56,'Pannello Preformato','Pietra','Mattone in terra cruda'),(337,'Soffitto',NULL,NULL,57,'Rete',NULL,'Mattone in laterizio'),(338,'Pavimento',0.007,'Verticale',57,'Corda in Ferro','Memoria','Alveolater'),(339,'Parete1',NULL,NULL,57,'Perlite',NULL,'Alveolater'),(340,'Parete2',NULL,NULL,57,'Ghiaia',NULL,'Alveolater'),(341,'Parete3',NULL,NULL,57,NULL,NULL,'Alveolater'),(342,'Parete4',NULL,NULL,57,NULL,NULL,'Alveolater'),(343,'Soffitto',NULL,NULL,58,NULL,NULL,'Alveolater'),(344,'Pavimento',0.007,'Naturale',58,NULL,'Memoria','Alveolater'),(345,'Parete1',NULL,NULL,58,'Sabbia',NULL,'Alveolater'),(346,'Parete2',NULL,NULL,58,NULL,NULL,'Mattone semipieno'),(347,'Parete3',NULL,NULL,58,NULL,NULL,'Blocco di cemento'),(348,'Parete4',NULL,NULL,58,'Pannello',NULL,'Blocco di cemento'),(349,'Soffitto',NULL,NULL,59,'Pannello Preformato',NULL,'Blocco di cemento'),(350,'Pavimento',0.009,'Naturale',59,NULL,'Memoria','Blocco di cemento'),(351,'Parete1',NULL,NULL,59,'Pannello',NULL,'Blocco di cemento'),(352,'Parete2',NULL,NULL,59,'Pannello Preformato',NULL,'Mattone 2 fori'),(353,'Parete3',NULL,NULL,59,NULL,NULL,'Mattone 2 fori'),(354,'Parete4',NULL,NULL,59,NULL,NULL,'Mattone 2 fori'),(355,'Soffitto',NULL,NULL,60,'Policarbonato',NULL,'Alveolater'),(356,'Pavimento',0.009,'Orizzontale',60,NULL,'Memoria','Alveolater'),(357,'Parete1',NULL,NULL,60,'Resina Indurente',NULL,'Alveolater'),(358,'Parete2',NULL,NULL,60,NULL,'Pietra','Mattone semipieno'),(359,'Parete3',NULL,NULL,60,NULL,NULL,'Blocco di cemento'),(360,'Parete4',NULL,NULL,60,'Rete',NULL,'Blocco di cemento'),(361,'Soffitto',NULL,NULL,61,'Corda in Ferro',NULL,'Blocco di cemento'),(362,'Pavimento',0.009,'Orizzontale',61,'Perlite','Memoria','Blocco di cemento'),(363,'Parete1',NULL,NULL,61,'Ghiaia',NULL,'Blocco di cemento'),(364,'Parete2',NULL,NULL,61,NULL,NULL,'Mattone 2 fori'),(365,'Parete3',NULL,NULL,61,NULL,NULL,'Mattone 2 fori'),(366,'Parete4',NULL,NULL,61,NULL,NULL,'Mattone 2 fori'),(367,'Soffitto',NULL,NULL,62,NULL,NULL,'Mattone 2 fori'),(368,'Pavimento',0.009,'Naturale',62,'Sabbia','Mystone travertino','Mattone 2 fori'),(369,'Parete1',NULL,NULL,62,NULL,NULL,'Blocco di cemento'),(370,'Parete2',NULL,NULL,62,NULL,NULL,'Blocco di cemento'),(371,'Parete3',NULL,NULL,62,'Pannello',NULL,'Blocco di cemento'),(372,'Parete4',NULL,NULL,62,'Pannello Preformato',NULL,'Mattone 2 fori'),(373,'Soffitto',NULL,NULL,63,NULL,NULL,'Mattone 2 fori'),(374,'Pavimento',0.002,'Verticale',63,'Pannello','Mystone travertino','Mattone 2 fori'),(375,'Parete1',NULL,NULL,63,'Pannello Preformato',NULL,'Mattone in terra cruda'),(376,'Parete2',NULL,NULL,63,NULL,NULL,'Mattone in laterizio'),(377,'Parete3',NULL,NULL,63,NULL,NULL,'Mattone in terra cruda'),(378,'Parete4',NULL,NULL,63,'Policarbonato',NULL,'Mattone in terra cruda'),(379,'Soffitto',NULL,NULL,64,NULL,NULL,'Mattone in terra cruda'),(380,'Pavimento',0.003,'Orizzontale',64,'Resina Indurente','Mystone travertino','Mattone in laterizio'),(381,'Parete1',NULL,NULL,64,NULL,NULL,'Alveolater'),(382,'Parete2',NULL,NULL,64,NULL,NULL,'Alveolater'),(383,'Parete3',NULL,NULL,64,'Rete',NULL,'Alveolater'),(384,'Parete4',NULL,NULL,64,'Corda in Ferro',NULL,'Alveolater'),(385,'Soffitto',NULL,NULL,65,'Perlite',NULL,'Alveolater'),(386,'Pavimento',0.009,'Verticale',65,'Ghiaia','Mystone travertino','Mattone in terra cruda'),(387,'Parete1',NULL,NULL,65,NULL,'Pietra','Mattone in terra cruda'),(388,'Parete2',NULL,NULL,65,NULL,'Pietra','Mattone in terra cruda'),(389,'Parete3',NULL,NULL,65,NULL,'Pietra','Mattone in laterizio'),(390,'Parete4',NULL,NULL,65,NULL,'Pietra','Mattone in terra cruda'),(391,'Soffitto',NULL,NULL,66,'Sabbia','Pietra','Mattone in terra cruda'),(392,'Pavimento',0.009,'Naturale',66,NULL,'Mystone travertino','Mattone in terra cruda'),(393,'Parete1',NULL,NULL,66,NULL,NULL,'Mattone in laterizio'),(394,'Parete2',NULL,NULL,66,'Pannello',NULL,'Mattone in terra cruda'),(395,'Parete3',NULL,NULL,66,'Pannello Preformato',NULL,'Mattone in terra cruda'),(396,'Parete4',NULL,NULL,66,'Rete',NULL,'Mattone in terra cruda'),(397,'Soffitto',NULL,NULL,67,'Corda in Ferro',NULL,'Mattone in laterizio'),(398,'Pavimento',0.007,'Verticale',67,'Perlite','Vero','Alveolater'),(399,'Parete1',NULL,NULL,67,'Ghiaia',NULL,'Alveolater'),(400,'Parete2',NULL,NULL,67,NULL,NULL,'Alveolater'),(401,'Parete3',NULL,NULL,67,NULL,NULL,'Alveolater'),(402,'Parete4',NULL,NULL,67,NULL,NULL,'Alveolater'),(403,'Soffitto',NULL,NULL,68,NULL,NULL,'Alveolater'),(404,'Pavimento',0.05,'Naturale',68,'Sabbia','Vero','Alveolater'),(405,'Parete1',NULL,NULL,68,NULL,NULL,'Alveolater'),(406,'Parete2',NULL,NULL,68,NULL,NULL,'Mattone semipieno'),(407,'Parete3',NULL,NULL,68,'Pannello',NULL,'Blocco di cemento'),(408,'Parete4',NULL,NULL,68,'Pannello Preformato',NULL,'Blocco di cemento'),(409,'Soffitto',NULL,NULL,69,NULL,NULL,'Blocco di cemento'),(410,'Pavimento',0.008,'Naturale',69,'Pannello','Vero','Blocco di cemento'),(411,'Parete1',NULL,NULL,69,'Pannello Preformato',NULL,'Blocco di cemento'),(412,'Parete2',NULL,NULL,69,NULL,NULL,'Mattone 2 fori'),(413,'Parete3',NULL,NULL,69,NULL,NULL,'Mattone 2 fori'),(414,'Parete4',NULL,NULL,69,'Policarbonato',NULL,'Mattone 2 fori'),(415,'Soffitto',NULL,NULL,70,NULL,NULL,'Mattone 2 fori'),(416,'Pavimento',NULL,NULL,70,'Resina Indurente','Legno','Mattone 2 fori'),(417,'Parete1',NULL,NULL,70,NULL,NULL,'Blocco di cemento'),(418,'Parete2',NULL,NULL,70,NULL,NULL,'Blocco di cemento'),(419,'Parete3',NULL,NULL,70,'Rete',NULL,'Blocco di cemento'),(420,'Parete4',NULL,NULL,70,'Corda in Ferro',NULL,'Mattone 2 fori'),(421,'Soffitto',NULL,NULL,71,'Perlite',NULL,'Mattone 2 fori'),(422,'Pavimento',NULL,NULL,71,'Ghiaia','Legno','Mattone 2 fori'),(423,'Parete1',NULL,NULL,71,NULL,NULL,'Mattone in laterizio'),(424,'Parete2',NULL,NULL,71,NULL,NULL,'Alveolater'),(425,'Parete3',NULL,NULL,71,NULL,NULL,'Alveolater'),(426,'Parete4',NULL,NULL,71,NULL,'Pietra','Alveolater'),(427,'Soffitto',NULL,NULL,72,'Sabbia',NULL,'Alveolater'),(428,'Pavimento',0.009,'Naturale',72,NULL,'Vero','Alveolater'),(429,'Parete1',NULL,NULL,72,NULL,'Pietra','Alveolater'),(430,'Parete2',NULL,NULL,72,'Pannello',NULL,'Alveolater'),(431,'Parete3',NULL,NULL,72,'Pannello Preformato',NULL,'Alveolater'),(432,'Parete4',NULL,NULL,72,NULL,NULL,'Mattone semipieno'),(433,'Soffitto',NULL,NULL,73,'Pannello',NULL,'Blocco di cemento'),(434,'Pavimento',0.001,'Verticale',73,'Pannello Preformato','Grande Marble','Blocco di cemento'),(435,'Parete1',NULL,NULL,73,NULL,NULL,'Blocco di cemento'),(436,'Parete2',NULL,NULL,73,NULL,NULL,'Blocco di cemento'),(437,'Parete3',NULL,NULL,73,'Policarbonato',NULL,'Blocco di cemento'),(438,'Parete4',NULL,NULL,73,NULL,NULL,'Mattone 2 fori'),(439,'Soffitto',NULL,NULL,74,'Resina Indurente',NULL,'Mattone 2 fori'),(440,'Pavimento',0.01,'Orizzontale',74,NULL,'Grande Marble','Mattone 2 fori'),(441,'Parete1',NULL,NULL,74,NULL,NULL,'Mattone 2 fori'),(442,'Parete2',NULL,NULL,74,'Rete',NULL,'Mattone 2 fori'),(443,'Parete3',NULL,NULL,74,'Corda in Ferro',NULL,'Blocco di cemento'),(444,'Parete4',NULL,NULL,74,'Perlite',NULL,'Blocco di cemento'),(445,'Soffitto',NULL,NULL,75,'Ghiaia',NULL,'Blocco di cemento'),(446,'Pavimento',NULL,NULL,75,NULL,'Legno','Mattone 2 fori'),(447,'Parete1',NULL,NULL,75,NULL,NULL,'Mattone 2 fori'),(448,'Parete2',NULL,NULL,75,NULL,NULL,'Mattone 2 fori'),(449,'Parete3',NULL,NULL,75,NULL,NULL,'Mattone in terra cruda'),(450,'Parete4',NULL,NULL,75,'Sabbia',NULL,'Mattone in laterizio'),(451,'Soffitto',NULL,NULL,76,NULL,NULL,'Mattone in terra cruda'),(452,'Pavimento',0.0089,'Verticale',76,NULL,'Grande Marble','Mattone in terra cruda'),(453,'Parete1',NULL,NULL,76,'Pannello',NULL,'Mattone in terra cruda'),(454,'Parete2',NULL,NULL,76,'Pannello Preformato',NULL,'Mattone in laterizio'),(455,'Parete3',NULL,NULL,76,NULL,NULL,'Alveolater'),(456,'Parete4',NULL,NULL,76,'Sabbia',NULL,'Alveolater'),(457,'Soffitto',NULL,NULL,77,NULL,NULL,'Alveolater'),(458,'Pavimento',0.0086,'Orizzontale',77,NULL,'Grande Marble','Alveolater'),(459,'Parete1',NULL,NULL,77,'Pannello',NULL,'Alveolater'),(460,'Parete2',NULL,NULL,77,NULL,NULL,'Alveolater'),(461,'Parete3',NULL,NULL,77,'Sabbia',NULL,'Alveolater'),(462,'Parete4',NULL,NULL,77,NULL,NULL,'Alveolater'),(463,'Soffitto',NULL,NULL,78,NULL,NULL,'Mattone semipieno'),(464,'Pavimento',0.009,'Naturale',78,'Pannello','Cementum','Blocco di cemento'),(465,'Parete1',NULL,NULL,78,NULL,'Pietra','Blocco di cemento'),(466,'Parete2',NULL,NULL,78,'Sabbia','Pietra','Blocco di cemento'),(467,'Parete3',NULL,NULL,78,NULL,'Pietra','Blocco di cemento'),(468,'Parete4',NULL,NULL,78,NULL,'Pietra','Blocco di cemento');
INSERT INTO `finestra` VALUES (1,0.8,'SW',1.4,0.68,93),(1,0.8,'E',1.4,0.64,219),(1,0.8,'SE',1.4,0.64,264),(1,0.8,'NW',1.4,0.65,360),(1,0.8,'SW',1.4,0.69,432),(1,0.825,'N',1.45,0.64,105),(1,0.825,'NE',1.45,0.6,125),(1,0.825,'N',1.45,0.7,159),(1,0.825,'SE',1.45,0.61,252),(1,0.825,'SW',1.45,0.69,286),(1,0.825,'SW',1.45,0.6,312),(1,0.825,'SE',1.45,0.7,348),(1,0.825,'E',1.45,0.65,389),(1,0.825,'N',1.45,0.62,408),(1,0.825,'SW',1.45,0.6,443),(1,0.825,'E',1.45,0.62,465),(1,0.895,'NW',1.59,0.65,213),(1,0.895,'N',1.59,0.7,262),(1,0.895,'E',1.59,0.6,358),(1,0.93,'SE',1.66,0.61,126),(1,0.93,'E',1.66,0.6,255),(1,0.93,'SW',1.66,0.62,390),(1,0.95,'E',1.7,0.62,94),(1,0.95,'SE',1.7,0.64,117),(1,0.95,'N',1.7,0.68,220),(1,0.95,'E',1.7,0.64,276),(1,0.95,'SW',1.7,0.7,435),(1,0.98,'SW',1.76,0.69,131),(1,0.98,'E',1.76,0.67,258),(1,0.98,'NE',1.76,0.6,395),(1,0.995,'SW',1.79,0.62,22),(1,0.995,'SW',1.79,0.65,129),(1,0.995,'SW',1.79,0.61,256),(1,0.995,'SW',1.79,0.64,393),(1,1,'E',1.4,0.64,34),(1,1,'NE',1.8,0.63,95),(1,1,'NE',1.8,0.6,150),(1,1,'NW',1.8,0.64,244),(1,1,'E',1.8,0.62,303),(1,1,'E',1.8,0.62,436),(1,1,'NE',1.8,0.61,456),(1,1.04,'N',1.88,0.61,213),(1,1.04,'NE',1.88,0.69,261),(1,1.04,'E',1.88,0.62,293),(1,1.04,'SE',1.88,0.63,357),(1,1.05,'N',1.9,0.6,96),(1,1.05,'N',1.9,0.61,153),(1,1.05,'SW',1.9,0.68,178),(1,1.05,'N',1.9,0.64,304),(1,1.05,'E',1.9,0.62,329),(1,1.05,'NE',1.9,0.64,437),(1,1.065,'SW',1.93,0.64,90),(1,1.065,'SE',1.93,0.62,214),(1,1.065,'NW',1.93,0.62,263),(1,1.065,'N',1.93,0.61,359),(1,1.065,'SE',1.93,0.61,396),(1,1.095,'NW',1.59,0.65,30),(1,1.095,'E',1.99,0.67,130),(1,1.095,'SW',1.99,0.65,257),(1,1.095,'E',1.99,0.68,394),(1,1.1,'E',2,0.63,65),(1,1.1,'E',2,0.62,102),(1,1.1,'E',2,0.61,124),(1,1.1,'E',2,0.69,156),(1,1.1,'NW',2,0.62,160),(1,1.1,'SE',2,0.64,161),(1,1.1,'E',2,0.68,162),(1,1.1,'E',2,0.67,197),(1,1.1,'SW',2,0.68,204),(1,1.1,'SW',2,0.62,207),(1,1.1,'E',2,0.63,208),(1,1.1,'NE',2,0.6,209),(1,1.1,'SE',2,0.68,233),(1,1.1,'SW',2,0.67,285),(1,1.1,'E',2,0.63,311),(1,1.1,'SW',2,0.61,315),(1,1.1,'E',2,0.6,316),(1,1.1,'NE',2,0.61,317),(1,1.1,'E',2,0.68,341),(1,1.1,'SW',2,0.62,351),(1,1.1,'E',2,0.64,352),(1,1.1,'N',2,0.68,353),(1,1.1,'NW',2,0.62,354),(1,1.1,'NW',2,0.6,370),(1,1.1,'SW',2,0.61,388),(1,1.1,'SW',2,0.62,417),(1,1.1,'E',2,0.61,425),(1,1.1,'E',2,0.63,442),(1,1.1,'SW',2,0.61,444),(1,1.15,'N',1.7,0.68,35),(1,1.15,'SE',2.1,0.7,100),(1,1.15,'SE',2.1,0.67,155),(1,1.15,'SE',2.1,0.62,310),(1,1.15,'SE',2.1,0.6,387),(1,1.15,'SW',2.1,0.62,441),(1,1.16,'SE',2.12,0.7,377),(1,1.16,'E',2.12,0.64,418),(1,1.18,'NE',1.76,0.6,27),(1,1.195,'SE',1.79,0.6,467),(1,1.2,'N',2.2,0.69,16),(1,1.2,'NW',1.8,0.62,36),(1,1.2,'NW',2.2,0.61,99),(1,1.2,'SE',2.2,0.61,143),(1,1.2,'NW',2.2,0.65,154),(1,1.2,'NW',2.2,0.68,309),(1,1.2,'NE',2.2,0.63,384),(1,1.2,'SE',2.2,0.68,438),(1,1.24,'N',1.88,0.61,29),(1,1.25,'SW',1.9,0.69,54),(1,1.265,'SE',1.93,0.62,33),(1,1.295,'E',1.99,0.63,24),(1,1.43,'W',1.66,0.63,466),(1,1.595,'NE',1.99,0.61,468),(1.2,0.8,'NE',1.4,0.62,114),(1.2,0.8,'SW',1.4,0.62,275),(1.2,0.825,'E',1.45,0.64,203),(1.2,0.825,'N',1.45,0.61,369),(1.2,0.895,'E',1.59,0.62,89),(1.2,0.93,'SW',1.66,0.68,21),(1.2,0.95,'E',1.7,0.68,149),(1.2,0.95,'N',1.7,0.62,243),(1.2,0.95,'SE',1.7,0.65,300),(1.2,0.95,'N',1.7,0.6,455),(1.2,1,'E',1.8,0.64,177),(1.2,1,'SE',1.8,0.68,328),(1.2,1.05,'E',1.9,0.67,15),(1.2,1.05,'NW',1.9,0.6,142),(1.2,1.05,'E',1.9,0.62,383),(1.2,1.065,'NW',1.93,0.64,136),(1.2,1.065,'E',1.93,0.67,431),(1.2,1.1,'SE',2,0.62,64),(1.2,1.1,'SE',2,0.65,196),(1.2,1.1,'NE',2,0.64,232),(1.2,1.1,'NW',2,0.6,251),(1.2,1.1,'SW',2,0.68,292),(1.2,1.1,'SW',2,0.64,340),(1.2,1.1,'NE',2,0.61,347),(1.2,1.1,'NW',2,0.69,376),(1.2,1.1,'E',2,0.68,407),(1.2,1.1,'SW',2,0.65,414),(1.2,1.1,'SE',2,0.6,424),(1.2,1.1,'SW',2,0.68,462),(1.2,1.15,'SW',2.1,0.6,123),(1.2,1.15,'E',2.1,0.65,282),(1.2,1.2,'SE',1.8,0.67,51),(1.3,0.8,'SW',1.4,0.64,148),(1.3,0.8,'E',1.4,0.65,240),(1.3,0.8,'NW',1.4,0.61,299),(1.3,0.8,'W',1.4,0.63,454),(1.3,0.825,'E',1.45,0.64,18),(1.3,0.825,'E',1.45,0.62,231),(1.3,0.895,'N',1.59,0.62,135),(1.3,0.895,'E',1.59,0.6,167),(1.3,0.895,'SE',1.59,0.65,430),(1.3,0.95,'SW',1.7,0.62,172),(1.3,0.95,'NW',1.7,0.64,327),(1.3,1,'SE',1.8,0.65,11),(1.3,1,'N',1.8,0.63,141),(1.3,1,'SW',1.8,0.68,382),(1.3,1,'SE',1.8,0.69,401),(1.3,1.025,'NW',1.45,0.68,63),(1.3,1.04,'SE',1.88,0.65,88),(1.3,1.05,'NW',1.9,0.63,269),(1.3,1.05,'SW',1.9,0.68,363),(1.3,1.065,'SW',1.93,0.65,274),(1.3,1.095,'SW',1.59,0.61,42),(1.3,1.1,'E',2,0.63,108),(1.3,1.1,'NE',2,0.6,189),(1.3,1.1,'NW',2,0.61,195),(1.3,1.1,'SE',2,0.62,202),(1.3,1.1,'SE',2,0.64,291),(1.3,1.1,'SE',2,0.62,339),(1.3,1.1,'NE',2,0.6,366),(1.3,1.1,'N',2,0.67,375),(1.3,1.1,'E',2,0.61,413),(1.3,1.1,'NW',2,0.63,423),(1.3,1.1,'SE',2,0.64,449),(1.3,1.15,'NE',1.7,0.65,51),(1.3,1.15,'N',2.1,0.63,250),(1.3,1.15,'SE',2.1,0.64,406),(1.3,1.15,'SE',2.1,0.64,461),(1.3,1.16,'E',2.12,0.65,113),(1.3,1.16,'SE',2.12,0.69,322),(1.3,1.16,'E',2.12,0.6,346),(1.3,1.2,'SW',2.2,0.63,120),(1.3,1.2,'E',2.2,0.6,225),(1.3,1.2,'SW',2.2,0.61,281),(1.5,0.8,'SE',1.4,0.65,171),(1.5,0.8,'N',1.4,0.62,324),(1.5,0.825,'NE',1.45,0.65,335),(1.5,0.825,'N',1.45,0.62,420),(1.5,0.895,'E',1.59,0.61,273),(1.5,0.95,'NW',1.7,0.61,10),(1.5,0.95,'E',1.7,0.62,138),(1.5,0.95,'SW',1.7,0.64,381),(1.5,0.95,'E',1.7,0.67,400),(1.5,1,'E',1.4,0.61,51),(1.5,1,'N',1.8,0.62,268),(1.5,1,'E',1.8,0.64,360),(1.5,1.04,'E',1.88,0.7,132),(1.5,1.04,'SW',1.88,0.63,166),(1.5,1.04,'NW',1.88,0.61,429),(1.5,1.05,'E',1.9,0.62,119),(1.5,1.05,'SE',1.9,0.63,222),(1.5,1.05,'SE',1.9,0.6,280),(1.5,1.065,'SW',1.93,0.62,147),(1.5,1.065,'N',1.93,0.6,298),(1.5,1.1,'SE',2,0.62,17),(1.5,1.1,'NW',2,0.61,87),(1.5,1.1,'SE',2,0.62,107),(1.5,1.1,'SW',2,0.61,112),(1.5,1.1,'N',2,0.6,191),(1.5,1.1,'SW',2,0.7,227),(1.5,1.1,'E',2,0.63,237),(1.5,1.1,'NE',2,0.62,288),(1.5,1.1,'NW',2,0.67,321),(1.5,1.1,'SW',2,0.63,345),(1.5,1.1,'E',2,0.65,372),(1.5,1.1,'SE',2,0.6,412),(1.5,1.1,'NE',2,0.62,448),(1.5,1.15,'E',2.1,0.63,184),(1.5,1.15,'SW',2.1,0.6,333),(1.5,1.15,'E',2.1,0.63,365),(1.5,1.16,'NW',2.12,0.7,201),(1.5,1.16,'SW',2.12,0.61,239),(1.5,1.16,'E',2.12,0.62,453),(1.5,1.2,'E',2.2,0.62,249),(1.5,1.2,'NW',2.2,0.62,405),(1.5,1.2,'S',2.2,0.62,460),(1.5,1.3,'N',2,0.64,60),(1.5,1.4,'E',2.2,0.6,40),(1.7,0.8,'N',1.4,0.6,4),(1.7,0.8,'SE',1.4,0.68,137),(1.7,0.8,'E',1.4,0.62,378),(1.7,0.8,'SW',1.4,0.65,399),(1.7,0.825,'SE',1.45,0.61,190),(1.7,0.895,'E',1.59,0.65,144),(1.7,0.895,'N',1.59,0.63,297),(1.7,0.95,'E',1.7,0.68,267),(1.7,0.95,'SE',1.7,0.62,360),(1.7,1,'SW',1.8,0.68,118),(1.7,1,'NW',1.8,0.62,221),(1.7,1,'NE',1.8,0.68,279),(1.7,1.05,'SE',1.9,0.68,245),(1.7,1.05,'N',1.9,0.7,402),(1.7,1.05,'NW',1.9,0.7,459),(1.7,1.065,'NE',1.93,0.61,168),(1.7,1.065,'E',1.93,0.7,323),(1.7,1.1,'N',2,0.6,66),(1.7,1.1,'NW',2,0.68,106),(1.7,1.1,'SW',2,0.6,111),(1.7,1.1,'SW',2,0.62,165),(1.7,1.1,'N',2,0.69,198),(1.7,1.1,'SW',2,0.62,234),(1.7,1.1,'SW',2,0.6,238),(1.7,1.1,'E',2,0.7,287),(1.7,1.1,'N',2,0.65,318),(1.7,1.1,'E',2,0.61,334),(1.7,1.1,'SW',2,0.62,342),(1.7,1.1,'SE',2,0.61,371),(1.7,1.1,'NW',2,0.63,411),(1.7,1.1,'NE',2,0.68,419),(1.7,1.1,'N',2,0.6,426),(1.7,1.1,'E',2,0.65,447),(1.7,1.1,'SW',2,0.68,450),(1.7,1.15,'NW',2.1,0.7,17),(1.7,1.15,'SW',2.1,0.61,226),(1.7,1.2,'SW',2.2,0.62,179),(1.7,1.2,'SE',2.2,0.6,270),(1.7,1.2,'SW',2.2,0.63,330),(1.7,1.2,'SW',2.2,0.62,364),(1.7,1.25,'SE',1.9,0.63,39),(1.7,1.265,'SW',1.93,0.6,48),(1.7,1.35,'SW',2.1,0.62,58),(1.7,1.4,'E',2.2,0.7,57);
INSERT INTO `Calamita` ( TipoCalamita, DataCalamita, FK_NomeAreaGeograficaCentro, Intensita, Latitudine, Longitudine) VALUES ( 'Terremoto','2008-09-02', 'Spazzavento',8,43.48,10.3),('Frana','2006-01-13', 'Monte',5,43.5,10.51), ('Alluvione','2013-12-20', 'Mercato',3,43.11,10.2),('Incendio','2001-11-09', 'Industriale',2,43.61,10.11),('Frana','2008-03-15', 'Terme',1,43.34,10.42),('Inondazione','2021-01-15', 'Terme',10,43.45,10.21),('Terremoto','2007-06-15', 'Padule',2,43.21,10.15),('Frana','2004-07-17', 'Villaggio',1,43.45,10.41),('Incendio','2002-10-20', 'Spazzavento',1,43.45,10.42),('Alluvione','2018-03-11', 'Mercato',4,43.15,10.31),('Frana','2009-05-22', 'Terme',2,43.7,10.21),('Inondazione','2021-06-13', 'Padule',4,43.5,10.35),('Terremoto','2008-04-18', 'Villaggio',4,43.12,10.29),('Frana','2003-11-13', 'Spazzavento',4,43.45,10.25),('Frana','2001-11-08', 'Mercato',5,43.48,10.3),('Inondazione','2019-03-14', 'Terme',6,43.5,10.4),('Terremoto','2017-10-13', 'Padule',7,43.47,10.29),('Frana','2018-08-10', 'Villaggio',8,43.14,43.32),( 'Terremoto','2020-09-02', 'Padule',4,43.30,10.20),( 'Terremoto','2020-10-07', 'Padule',4,43.40,10.25),( 'Terremoto','2020-11-18', 'Padule',4,43.50,10.30);
INSERT INTO `danno` VALUES ('Allagamento',1,15,200,'Alluvione','2013-12-20',368),('Cedimento fondamenta',6,4.5,0.5,'Alluvione','2018-03-11',44),('Allagamento',7,10.5,0.5,'Alluvione','2018-03-11',50),('Cedimento fondamenta',7,0.5,0.5,'Alluvione','2018-03-11',110),('Cedimento superficie',2,147,23,'Alluvione','2018-03-11',325),('Cedimento superficie',7,98,1.4,'Alluvione','2018-03-11',328),('Cedimento superficie',8,0.7,0.7,'Alluvione','2018-03-11',329),('Cedimento superficie',9,1.4,65,'Frana','2004-07-17',260),('Cedimento superficie',10,0.2,0.2,'Frana','2018-08-10',239),('Cedimento superficie',1,1,1,'Frana','2018-08-10',245),('Cedimento superficie',3,2,1.5,'Frana','2018-08-10',255),('Cedimento fondamenta',3,1.75,0.5,'Inondazione','2021-01-15',242),('Allagamento',3,37.4,145,'Inondazione','2021-01-15',296),('Cedimento fondamenta',7,4.1,4.8,'Inondazione','2021-01-15',326),('Allagamento',10,20,190,'Inondazione','2021-01-15',379),('Allagamento',1,25,195,'Inondazione','2021-01-15',380),('Allagamento',10,15,185,'Inondazione','2021-01-15',392),('Allagamento',7,110,115,'Inondazione','2021-06-13',110),('Crepa',3,40.5,125,'Terremoto','2007-06-15',70),('Crepa',5,74.9,11.5,'Terremoto','2007-06-15',90),('Crepa',8,96.4,87,'Terremoto','2007-06-15',92),('Cedimento superficie',10,0.4,0.4,'Terremoto','2007-06-15',96),('Cedimento superficie',1,47.4,0.5,'Terremoto','2007-06-15',99),('Cedimento superficie',7,52.7,0.5,'Terremoto','2007-06-15',102),('Crepa',1,98.2,41,'Terremoto','2007-06-15',115),('Crepa',3,15,15,'Terremoto','2007-06-15',117),('Crepa',7,64.2,85,'Terremoto','2008-04-18',109),('Crepa',8,74.1,98.4,'Terremoto','2008-04-18',110),('Crepa',10,0.4,87,'Terremoto','2008-04-18',111),('Crepa',7,98.7,145,'Terremoto','2008-04-18',234),('Cedimento superficie',3,15.2,37,'Terremoto','2008-04-18',267),('Crepa',6,157,45.4,'Terremoto','2008-04-18',312),('Crepa',7,74,96,'Terremoto','2008-04-18',313),('Crepa',9,96.7,47.2,'Terremoto','2008-04-18',314),('Crepa',3,64.4,78.96,'Terremoto','2008-04-18',320),('Crepa',9,98,85.47,'Terremoto','2008-09-02',64),('Crepa',10,11,30,'Terremoto','2008-09-02',80),('Crepa',1,30,11,'Terremoto','2008-09-02',81),('Crepa',3,52,24,'Terremoto','2008-09-02',88),('Crepa',5,76,4.1,'Terremoto','2008-09-02',119),('Crepa',6,65,21,'Terremoto','2008-09-02',120),('Crepa',7,47.1,14,'Terremoto','2008-09-02',125),('Crepa',9,64.5,97.1,'Terremoto','2008-09-02',129),('Crepa',2,74.59,12.4,'Terremoto','2017-10-13',71),('Crepa',7,96.47,54.8,'Terremoto','2017-10-13',76),('Cedimento fondamenta',6,95,0.15,'Terremoto','2017-10-13',86),('Crepa',2,4.1,27.6,'Terremoto','2017-10-13',104),('Crepa',3,0.5,0.5,'Terremoto','2017-10-13',135);
INSERT INTO `sensore` VALUES (1,'2008-04-19','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',4.5,0.5,1,1.5,0.5,44),(2,'2008-04-20','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',10.5,0.5,1,NULL,0.5,50),(3,'2007-06-16','Misuratore di distanza','Scalare',40.4,125,5,NULL,NULL,70),(4,'2008-09-03','Misuratore di distanza','Scalare',98,85.47,1.4,NULL,NULL,64),(5,'2017-10-14','Misuratore di distanza','Scalare',74.59,12.4,6,NULL,NULL,71),(6,'2017-10-15','Misuratore di distanza','Scalare',96.47,54.8,2.4,NULL,NULL,76),(7,'2007-06-16','Misuratore di distanza','Scalare',74.9,14.5,3,NULL,NULL,90),(8,'2007-06-17','Misuratore di distanza','Scalare',96.4,87,1.5,NULL,NULL,92),(9,'2007-06-18','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',0.4,0.4,0.5,0.5,0.5,96),(10,'2008-09-03','Misuratore di distanza','Scalare',11,30,0.8,NULL,NULL,80),(11,'2008-09-04','Misuratore di distanza','Scalare',30,11,6,NULL,NULL,81),(12,'2008-09-05','Misuratore di distanza','Scalare',52,24,4,NULL,NULL,88),(13,'2017-10-14','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',95,0.15,1,1,NULL,86),(14,'2007-06-16','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',47.4,0.5,2,1.8,1.5,99),(15,'2007-06-17','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',47.1,0.5,0.9,0.8,0.7,102),(16,'2007-06-16','Misuratore di distanza','Scalare',98.2,41,3,NULL,NULL,115),(17,'2007-06-16','Misuratore di distanza','Scalare',15,15,2.5,NULL,NULL,117),(18,'2008-04-19','Misuratore di distanza','Scalare',64.2,85,0.4,NULL,NULL,109),(19,'2008-04-20','Misuratore di distanza','Scalare',74.1,98.4,1.1,NULL,NULL,110),(20,'2008-04-21','Misuratore di distanza','Scalare',0.4,87,0.2,NULL,NULL,111),(21,'2008-09-03','Misuratore di distanza','Scalare',76,4.1,5,NULL,NULL,119),(22,'2008-09-04','Misuratore di distanza','Scalare',65,21,4.2,NULL,NULL,120),(23,'2008-09-05','Misuratore di distanza','Scalare',47.1,14,1.75,NULL,NULL,125),(24,'2008-09-06','Misuratore di distanza','Scalare',64.5,97.1,0.9,NULL,NULL,129),(25,'2009-05-23','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',0.5,0.5,2,0.4,1.5,110),(26,'2017-10-14','Misuratore di distanza','Scalare',4.1,27.6,4,NULL,NULL,104),(27,'2017-10-15','Misuratore di distanza','Scalare',0.5,0.5,3.4,NULL,NULL,135),(28,'2021-06-14','Igrometro','Scalare',110,115,30,NULL,NULL,110),(29,'2004-07-18','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',1.4,65,2,4,1,260),(30,'2013-12-21','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',15.2,37,4,1,3,267),(31,'2013-12-22','Misuratore di distanza','Scalare',98.7,145,3,NULL,NULL,234),(32,'2018-08-11','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',0.2,0.2,0.5,NULL,0.5,239),(33,'2018-08-12','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',1,1,1.5,1.5,1.5,245),(34,'2018-08-13','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',2,1.5,1.3,1.5,NULL,253),(35,'2021-01-16','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',1.75,0.5,1.7,2,0.4,242),(36,'2013-12-21','Igrometro','Scalare',37.4,145,40,NULL,NULL,296),(37,'2008-04-19','Misuratore di distanza','Scalare',157,45.4,2.4,NULL,NULL,312),(38,'2008-04-19','Misuratore di distanza','Scalare',74,96,1.5,NULL,NULL,313),(39,'2008-04-19','Misuratore di distanza','Scalare',96.7,47.2,0.8,NULL,NULL,314),(40,'2008-04-19','Misuratore di distanza','Scalare',65.4,78.96,4.7,NULL,NULL,320),(41,'2009-05-23','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',147,23,1.47,6.4,NULL,325),(42,'2009-05-23','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',98,1.4,1.4,NULL,2.47,328),(43,'2009-05-23','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',0.7,0.7,1.3,1.7,1.4,329),(44,'2021-01-16','Sensore multi uso inerziale con accelerometro a 3 assi','Triassiale',4.1,4.8,1.5,2.1,0.9,326),(45,'2008-09-03','Igrometro','Scalare',15,200,35,NULL,NULL,368),(46,'2021-01-16','Igrometro','Scalare',15,185,25,NULL,NULL,392),(47,'2021-01-16','Igrometro','Scalare',20,190,25,NULL,NULL,379),(48,'2021-01-16','Igrometro','Scalare',25,195,30,NULL,NULL,380);
INSERT INTO `progetto` VALUES (1,'2010-10-15','2012-06-06','2014-03-02','2018-05-06','2022-02-04','Costruzione Nuovo Edificio','QT',1),(2,'2015-10-15','2016-11-15','2017-05-02','2020-01-01','2021-01-02','Costruzione Nuovo Edificio','QT',2),(3,'2022-01-03','2022-06-06','2022-12-12','2026-05-01',NULL,'Restaurazione Edificio','Stazione',3),(4,'2002-12-05',NULL,NULL,NULL,NULL,'Restaurazione Edificio','Stazione',4),(5,'2015-09-08','2019-09-09','2021-06-03','2025-05-05',NULL,'Costruzione Nuovo Edificio','Stazione',5),(6,'2002-09-03','2020-01-01','2020-01-15','2030-05-06',NULL,'Restaurazione Edificio','Padule',6),(7,'2010-02-04','2012-12-12','2019-09-08','2022-07-09','2022-12-02','Restaurazione Edificio','Villaggio',7),(8,'2011-01-08','2016-12-10','2018-10-02','2020-01-05','2022-10-09','Costruzione Nuovo Edificio','Villaggio',8),(9,'2021-09-02',NULL,NULL,NULL,NULL,'Restaurazione Edificio','Villaggio',9),(10,'2019-08-08','2020-02-09','2021-09-28','2023-05-09',NULL,'Costruzione Nuovo Edificio','Industriale',10),(11,'2018-03-03','2019-08-12','2020-08-07','2023-01-09',NULL,'Costruzione Nuovo Edificio','Industriale',11),(12,'2016-09-08','2017-11-01','2020-10-12','2024-09-01',NULL,'Restaurazione Edificio','Mercato',12),(13,'2010-03-09','2020-03-07','2021-09-05','2028-03-13',NULL,'Restaurazione Edificio','Monte',13),(14,'2021-05-07',NULL,NULL,NULL,NULL,'Restaurazione Edificio','Cimitero',14),(15,'2019-01-09','2019-06-03','2020-07-03','2025-04-09',NULL,'Costruzione Nuovo Edificio','Monte',15),(16,'2019-03-24','2020-07-04','2021-09-04','2023-07-09',NULL,'Costruzione Nuovo Edificio','Terme',16);
INSERT INTO `statodiavanzamento` VALUES (1,'2014-03-02','2016-03-02','2018-09-27',0,1),(2,'2018-09-27','2019-03-08','2020-12-04',0,1),(3,'2018-09-27','2020-02-13','2022-01-20',0,1),(4,'2022-01-20','2022-01-28','2022-02-04',0,1),(5,'2017-05-02','2018-04-21','2018-12-20',0,2),(6,'2018-12-20','2019-09-26','2020-05-08',0,2),(7,'2020-05-08','2020-12-18','2020-12-18',0,2),(8,'2020-12-18','2020-12-31','2021-01-02',0,2),(9,'2022-12-12','2024-11-08',NULL,0,3),(10,'2021-06-03','2021-08-03','2021-09-03',0,5),(11,'2021-06-03','2021-08-03','2022-09-03',0,5),(12,'2022-09-03','2022-11-03','2022-12-13',0,5),(13,'2022-12-13','2025-05-05',NULL,0,5),(14,'2020-01-15','2026-09-09',NULL,0,6),(15,NULL,'2030-05-06',NULL,0,6),(16,'2019-09-08','2022-07-09','2022-12-02',0,7),(17,'2018-10-02','2018-11-14','2018-11-22',0,8),(18,'2018-07-14','2019-03-09','2019-05-11',0,8),(19,'2019-02-23','2019-09-21','2019-11-15',0,8),(20,'2019-12-29','2020-01-05','2022-10-09',0,8),(21,'2021-09-28','2022-02-10','2022-04-09',0,10),(22,'2022-04-09','2022-06-09','2022-10-06',0,10),(23,'2022-10-06','2023-05-09',NULL,0,10),(24,'2020-08-07','2020-10-22','2021-01-14',0,11),(25,'2021-01-14','2022-01-06','2022-11-05',0,11),(26,'2022-11-05','2023-01-09',NULL,0,11),(27,'2020-10-12','2024-09-01',NULL,0,12),(28,'2021-09-05','2028-03-13',NULL,0,13),(29,'2021-09-05','2028-03-13',NULL,0,13),(30,'2020-07-03','2020-12-11','2021-03-31',0,15),(31,'2021-03-31','2022-07-16','2022-11-12',0,15),(32,'2021-03-31','2021-11-27','2022-11-05',0,15),(33,'2022-07-16','2025-04-09',NULL,0,15),(34,'2021-09-04','2021-12-09','2022-08-13',0,16),(35,'2022-08-13','2022-11-19','2022-12-18',0,16),(36,'2022-08-13','2022-12-31',NULL,0,16),(37,'2022-08-13','2023-07-09',NULL,0,16);
INSERT INTO `lavoro` VALUES (1,'Creazione fondamenta',1,1,NULL),(7,'Installazione impianti gas-elettrico-idrico',2,1,NULL),(13,'Installazione impianti gas-elettrico-idrico',2,2,NULL),(19,'Installazione impianti gas-elettrico-idrico',2,3,NULL),(25,'Installazione impianti gas-elettrico-idrico',2,4,NULL),(31,'Installazione impianti gas-elettrico-idrico',2,5,NULL),(37,'Installazione impianti gas-elettrico-idrico',2,6,NULL),(43,'Costruzione pareti e soffitti',3,NULL,1),(44,'Costruzione pareti e soffitti',3,NULL,3),(45,'Costruzione pareti e soffitti',3,NULL,4),(46,'Costruzione pareti e soffitti',3,NULL,5),(47,'Costruzione pareti e soffitti',3,NULL,6),(48,'Costruzione pareti e soffitti',3,NULL,7),(49,'Costruzione pareti e soffitti',3,NULL,9),(50,'Costruzione pareti e soffitti',3,NULL,10),(51,'Costruzione pareti e soffitti',3,NULL,11),(52,'Costruzione pareti e soffitti',3,NULL,12),(53,'Costruzione pareti e soffitti',3,NULL,13),(54,'Costruzione pareti e soffitti',3,NULL,15),(55,'Costruzione pareti e soffitti',3,NULL,16),(56,'Costruzione pareti e soffitti',3,NULL,17),(57,'Costruzione pareti e soffitti',3,NULL,18),(58,'Costruzione pareti e soffitti',3,NULL,19),(59,'Costruzione pareti e soffitti',3,NULL,21),(60,'Costruzione pareti e soffitti',3,NULL,22),(61,'Costruzione pareti e soffitti',3,NULL,23),(62,'Costruzione pareti e soffitti',3,NULL,24),(63,'Costruzione pareti e soffitti',3,NULL,25),(64,'Costruzione pareti e soffitti',3,NULL,27),(65,'Costruzione pareti e soffitti',3,NULL,28),(66,'Costruzione pareti e soffitti',3,NULL,29),(67,'Costruzione pareti e soffitti',3,NULL,30),(68,'Costruzione pareti e soffitti',3,NULL,31),(69,'Costruzione pareti e soffitti',3,NULL,33),(70,'Costruzione pareti e soffitti',3,NULL,34),(71,'Costruzione pareti e soffitti',3,NULL,35),(72,'Costruzione pareti e soffitti',3,NULL,36),(73,'Imbiancatura',4,NULL,1),(74,'Imbiancatura',4,NULL,3),(75,'Imbiancatura',4,NULL,4),(76,'Imbiancatura',4,NULL,5),(77,'Imbiancatura',4,NULL,6),(78,'Imbiancatura',4,NULL,7),(79,'Imbiancatura',4,NULL,9),(80,'Imbiancatura',4,NULL,10),(81,'Imbiancatura',4,NULL,11),(82,'Imbiancatura',4,NULL,12),(83,'Imbiancatura',4,NULL,13),(84,'Imbiancatura',4,NULL,15),(85,'Imbiancatura',4,NULL,16),(86,'Imbiancatura',4,NULL,17),(87,'Imbiancatura',4,NULL,18),(88,'Imbiancatura',4,NULL,19),(89,'Imbiancatura',4,NULL,21),(90,'Imbiancatura',4,NULL,22),(91,'Imbiancatura',4,NULL,23),(92,'Imbiancatura',4,NULL,24),(93,'Imbiancatura',4,NULL,25),(94,'Imbiancatura',4,NULL,27),(95,'Imbiancatura',4,NULL,28),(96,'Imbiancatura',4,NULL,29),(97,'Imbiancatura',4,NULL,30),(98,'Imbiancatura',4,NULL,31),(99,'Imbiancatura',4,NULL,33),(100,'Imbiancatura',4,NULL,34),(101,'Imbiancatura',4,NULL,35),(102,'Imbiancatura',4,NULL,36),(103,'Creazione fondamenta',5,7,NULL),(104,'Creazione fondamenta',5,8,NULL),(105,'Creazione fondamenta',5,9,NULL),(106,'Creazione fondamenta',5,10,NULL),(107,'Costruzione pareti e soffitti',6,NULL,37),(108,'Costruzione pareti e soffitti',6,NULL,39),(109,'Costruzione pareti e soffitti',6,NULL,40),(110,'Costruzione pareti e soffitti',6,NULL,41),(111,'Costruzione pareti e soffitti',6,NULL,42),(112,'Costruzione pareti e soffitti',6,NULL,43),(113,'Costruzione pareti e soffitti',6,NULL,45),(114,'Costruzione pareti e soffitti',6,NULL,46),(115,'Costruzione pareti e soffitti',6,NULL,47),(116,'Costruzione pareti e soffitti',6,NULL,48),(117,'Costruzione pareti e soffitti',6,NULL,49),(118,'Costruzione pareti e soffitti',6,NULL,51),(119,'Costruzione pareti e soffitti',6,NULL,52),(120,'Costruzione pareti e soffitti',6,NULL,53),(121,'Costruzione pareti e soffitti',6,NULL,54),(122,'Costruzione pareti e soffitti',6,NULL,55),(123,'Costruzione pareti e soffitti',6,NULL,57),(124,'Costruzione pareti e soffitti',6,NULL,58),(125,'Costruzione pareti e soffitti',6,NULL,59),(126,'Costruzione pareti e soffitti',6,NULL,60),(127,'Installazione impianti gas-elettrico-idrico',7,7,NULL),(133,'Installazione impianti gas-elettrico-idrico',7,8,NULL),(139,'Installazione impianti gas-elettrico-idrico',7,9,NULL),(145,'Installazione impianti gas-elettrico-idrico',7,10,NULL),(151,'Imbiancatura',8,NULL,37),(152,'Imbiancatura',8,NULL,39),(153,'Imbiancatura',8,NULL,40),(154,'Imbiancatura',8,NULL,41),(155,'Imbiancatura',8,NULL,42),(156,'Imbiancatura',8,NULL,43),(157,'Imbiancatura',8,NULL,45),(158,'Imbiancatura',8,NULL,46),(159,'Imbiancatura',8,NULL,47),(160,'Imbiancatura',8,NULL,48),(161,'Imbiancatura',8,NULL,49),(162,'Imbiancatura',8,NULL,51),(163,'Imbiancatura',8,NULL,52),(164,'Imbiancatura',8,NULL,53),(165,'Imbiancatura',8,NULL,54),(166,'Imbiancatura',8,NULL,55),(167,'Imbiancatura',8,NULL,57),(168,'Imbiancatura',8,NULL,58),(169,'Imbiancatura',8,NULL,59),(170,'Imbiancatura',8,NULL,60),(171,'Rifacimento pavimentazioni',9,NULL,62),(172,'Rifacimento pavimentazioni',9,NULL,68),(173,'Rifacimento pavimentazioni',9,NULL,74),(174,'Creazione fondamenta',10,17,NULL),(175,'Installazione impianti gas-elettrico-idrico',11,17,NULL),(180,'Costruzione pareti e soffitti',12,NULL,97),(181,'Costruzione pareti e soffitti',12,NULL,99),(182,'Costruzione pareti e soffitti',12,NULL,100),(183,'Costruzione pareti e soffitti',12,NULL,101),(184,'Costruzione pareti e soffitti',12,NULL,102),(185,'Imbiancatura',13,NULL,97),(186,'Imbiancatura',13,NULL,99),(187,'Imbiancatura',13,NULL,100),(188,'Imbiancatura',13,NULL,101),(189,'Imbiancatura',13,NULL,102),(190,'Rifacimento pareti',14,NULL,103),(191,'Rifacimento pareti',14,NULL,105),(192,'Rifacimento pareti',14,NULL,106),(193,'Rifacimento pareti',14,NULL,107),(194,'Rifacimento pareti',14,NULL,108),(195,'Rifacimento pareti',14,NULL,109),(196,'Rifacimento pareti',14,NULL,111),(197,'Rifacimento pareti',14,NULL,112),(198,'Rifacimento pareti',14,NULL,113),(199,'Rifacimento pareti',14,NULL,114),(200,'Rifacimento pareti',14,NULL,115),(201,'Rifacimento pareti',14,NULL,117),(202,'Rifacimento pareti',14,NULL,118),(203,'Rifacimento pareti',14,NULL,119),(204,'Rifacimento pareti',14,NULL,120),(205,'Rifacimento pareti',14,NULL,121),(206,'Rifacimento pareti',14,NULL,123),(207,'Rifacimento pareti',14,NULL,124),(208,'Rifacimento pareti',14,NULL,125),(209,'Rifacimento pareti',14,NULL,126),(210,'Rifacimento pareti',14,NULL,127),(211,'Rifacimento pareti',14,NULL,129),(212,'Rifacimento pareti',14,NULL,130),(213,'Rifacimento pareti',14,NULL,131),(214,'Rifacimento pareti',14,NULL,132),(215,'Rifacimento pareti',14,NULL,133),(216,'Rifacimento pareti',14,NULL,135),(217,'Rifacimento pareti',14,NULL,136),(218,'Rifacimento pareti',14,NULL,137),(219,'Rifacimento pareti',14,NULL,138),(220,'Tinteggiatura e rifacimento intonaco',15,NULL,103),(221,'Tinteggiatura e rifacimento intonaco',15,NULL,105),(222,'Tinteggiatura e rifacimento intonaco',15,NULL,106),(223,'Tinteggiatura e rifacimento intonaco',15,NULL,107),(224,'Tinteggiatura e rifacimento intonaco',15,NULL,108),(225,'Tinteggiatura e rifacimento intonaco',15,NULL,109),(226,'Tinteggiatura e rifacimento intonaco',15,NULL,111),(227,'Tinteggiatura e rifacimento intonaco',15,NULL,112),(228,'Tinteggiatura e rifacimento intonaco',15,NULL,113),(229,'Tinteggiatura e rifacimento intonaco',15,NULL,114),(230,'Tinteggiatura e rifacimento intonaco',15,NULL,115),(231,'Tinteggiatura e rifacimento intonaco',15,NULL,117),(232,'Tinteggiatura e rifacimento intonaco',15,NULL,118),(233,'Tinteggiatura e rifacimento intonaco',15,NULL,119),(234,'Tinteggiatura e rifacimento intonaco',15,NULL,120),(235,'Tinteggiatura e rifacimento intonaco',15,NULL,121),(236,'Tinteggiatura e rifacimento intonaco',15,NULL,123),(237,'Tinteggiatura e rifacimento intonaco',15,NULL,124),(238,'Tinteggiatura e rifacimento intonaco',15,NULL,125),(239,'Tinteggiatura e rifacimento intonaco',15,NULL,126),(240,'Tinteggiatura e rifacimento intonaco',15,NULL,127),(241,'Tinteggiatura e rifacimento intonaco',15,NULL,129),(242,'Tinteggiatura e rifacimento intonaco',15,NULL,130),(243,'Tinteggiatura e rifacimento intonaco',15,NULL,131),(244,'Tinteggiatura e rifacimento intonaco',15,NULL,132),(245,'Tinteggiatura e rifacimento intonaco',15,NULL,133),(246,'Tinteggiatura e rifacimento intonaco',15,NULL,135),(247,'Tinteggiatura e rifacimento intonaco',15,NULL,136),(248,'Tinteggiatura e rifacimento intonaco',15,NULL,137),(249,'Tinteggiatura e rifacimento intonaco',15,NULL,138),(250,'Rifacimento installazione impianti gas-elettrico-idrico',16,24,NULL),(256,'Rifacimento installazione impianti gas-elettrico-idrico',16,25,NULL),(262,'Rifacimento installazione impianti gas-elettrico-idrico',16,26,NULL),(268,'Rifacimento installazione impianti gas-elettrico-idrico',16,27,NULL),(274,'Rifacimento installazione impianti gas-elettrico-idrico',16,28,NULL),(280,'Rifacimento installazione impianti gas-elettrico-idrico',16,29,NULL),(286,'Rifacimento installazione impianti gas-elettrico-idrico',16,30,NULL),(292,'Creazione fondamenta',17,31,NULL),(293,'Creazione fondamenta',17,32,NULL),(294,'Creazione fondamenta',17,33,NULL),(295,'Creazione fondamenta',17,34,NULL),(296,'Creazione fondamenta',17,35,NULL),(297,'Creazione fondamenta',17,36,NULL),(298,'Creazione fondamenta',17,37,NULL),(299,'Creazione fondamenta',17,38,NULL),(300,'Costruzione pareti e soffitti',18,NULL,181),(301,'Costruzione pareti e soffitti',18,NULL,183),(302,'Costruzione pareti e soffitti',18,NULL,184),(303,'Costruzione pareti e soffitti',18,NULL,185),(304,'Costruzione pareti e soffitti',18,NULL,186),(305,'Costruzione pareti e soffitti',18,NULL,187),(306,'Costruzione pareti e soffitti',18,NULL,189),(307,'Costruzione pareti e soffitti',18,NULL,190),(308,'Costruzione pareti e soffitti',18,NULL,191),(309,'Costruzione pareti e soffitti',18,NULL,192),(310,'Costruzione pareti e soffitti',18,NULL,193),(311,'Costruzione pareti e soffitti',18,NULL,195),(312,'Costruzione pareti e soffitti',18,NULL,196),(313,'Costruzione pareti e soffitti',18,NULL,197),(314,'Costruzione pareti e soffitti',18,NULL,198),(315,'Costruzione pareti e soffitti',18,NULL,199),(316,'Costruzione pareti e soffitti',18,NULL,201),(317,'Costruzione pareti e soffitti',18,NULL,202),(318,'Costruzione pareti e soffitti',18,NULL,203),(319,'Costruzione pareti e soffitti',18,NULL,204),(320,'Costruzione pareti e soffitti',18,NULL,205),(321,'Costruzione pareti e soffitti',18,NULL,207),(322,'Costruzione pareti e soffitti',18,NULL,208),(323,'Costruzione pareti e soffitti',18,NULL,209),(324,'Costruzione pareti e soffitti',18,NULL,210),(325,'Costruzione pareti e soffitti',18,NULL,211),(326,'Costruzione pareti e soffitti',18,NULL,213),(327,'Costruzione pareti e soffitti',18,NULL,214),(328,'Costruzione pareti e soffitti',18,NULL,215),(329,'Costruzione pareti e soffitti',18,NULL,216),(330,'Costruzione pareti e soffitti',18,NULL,217),(331,'Costruzione pareti e soffitti',18,NULL,219),(332,'Costruzione pareti e soffitti',18,NULL,220),(333,'Costruzione pareti e soffitti',18,NULL,221),(334,'Costruzione pareti e soffitti',18,NULL,222),(335,'Costruzione pareti e soffitti',18,NULL,223),(336,'Costruzione pareti e soffitti',18,NULL,225),(337,'Costruzione pareti e soffitti',18,NULL,226),(338,'Costruzione pareti e soffitti',18,NULL,227),(339,'Costruzione pareti e soffitti',18,NULL,228),(340,'Installazione impianti gas-elettrico-idrico',19,31,NULL),(346,'Installazione impianti gas-elettrico-idrico',19,32,NULL),(352,'Installazione impianti gas-elettrico-idrico',19,33,NULL),(358,'Installazione impianti gas-elettrico-idrico',19,34,NULL),(364,'Installazione impianti gas-elettrico-idrico',19,35,NULL),(370,'Installazione impianti gas-elettrico-idrico',19,36,NULL),(376,'Installazione impianti gas-elettrico-idrico',19,37,NULL),(382,'Installazione impianti gas-elettrico-idrico',19,38,NULL),(388,'Imbiancatura',20,NULL,181),(389,'Imbiancatura',20,NULL,183),(390,'Imbiancatura',20,NULL,184),(391,'Imbiancatura',20,NULL,185),(392,'Imbiancatura',20,NULL,186),(393,'Imbiancatura',20,NULL,187),(394,'Imbiancatura',20,NULL,189),(395,'Imbiancatura',20,NULL,190),(396,'Imbiancatura',20,NULL,191),(397,'Imbiancatura',20,NULL,192),(398,'Imbiancatura',20,NULL,193),(399,'Imbiancatura',20,NULL,195),(400,'Imbiancatura',20,NULL,196),(401,'Imbiancatura',20,NULL,197),(402,'Imbiancatura',20,NULL,198),(403,'Imbiancatura',20,NULL,199),(404,'Imbiancatura',20,NULL,201),(405,'Imbiancatura',20,NULL,202),(406,'Imbiancatura',20,NULL,203),(407,'Imbiancatura',20,NULL,204),(408,'Imbiancatura',20,NULL,205),(409,'Imbiancatura',20,NULL,207),(410,'Imbiancatura',20,NULL,208),(411,'Imbiancatura',20,NULL,209),(412,'Imbiancatura',20,NULL,210),(413,'Imbiancatura',20,NULL,211),(414,'Imbiancatura',20,NULL,213),(415,'Imbiancatura',20,NULL,214),(416,'Imbiancatura',20,NULL,215),(417,'Imbiancatura',20,NULL,216),(418,'Imbiancatura',20,NULL,217),(419,'Imbiancatura',20,NULL,219),(420,'Imbiancatura',20,NULL,220),(421,'Imbiancatura',20,NULL,221),(422,'Imbiancatura',20,NULL,222),(423,'Imbiancatura',20,NULL,223),(424,'Imbiancatura',20,NULL,225),(425,'Imbiancatura',20,NULL,226),(426,'Imbiancatura',20,NULL,227),(427,'Imbiancatura',20,NULL,228),(428,'Creazione fondamenta',21,48,NULL),(429,'Costruzione pareti e soffitti',22,NULL,283),(430,'Costruzione pareti e soffitti',22,NULL,285),(431,'Costruzione pareti e soffitti',22,NULL,286),(432,'Costruzione pareti e soffitti',22,NULL,287),(433,'Costruzione pareti e soffitti',22,NULL,288),(434,'Installazione impianto elettrico',23,48,NULL),(439,'Creazione fondamenta',24,49,NULL),(440,'Creazione fondamenta',24,50,NULL),(441,'Costruzione pareti e soffitti',25,NULL,289),(442,'Costruzione pareti e soffitti',25,NULL,291),(443,'Costruzione pareti e soffitti',25,NULL,292),(444,'Costruzione pareti e soffitti',25,NULL,293),(445,'Costruzione pareti e soffitti',25,NULL,294),(446,'Costruzione pareti e soffitti',25,NULL,295),(447,'Costruzione pareti e soffitti',25,NULL,297),(448,'Costruzione pareti e soffitti',25,NULL,298),(449,'Costruzione pareti e soffitti',25,NULL,299),(450,'Installazione impianto elettrico',25,50,NULL),(451,'Installazione impianto elettrico',26,49,NULL),(456,'Installazione impianto elettrico',26,50,NULL),(461,'Rifacimento Soffitti',27,NULL,301),(462,'Rifacimento Soffitti',27,NULL,307),(463,'Rifacimento Soffitti',27,NULL,313),(464,'Rifacimento Soffitti',27,NULL,319),(465,'Rifacimento Soffitti',27,NULL,325),(466,'Rifacimento Soffitti',27,NULL,331),(467,'Rifacimento Soffitti',28,NULL,337),(468,'Rifacimento Soffitti',28,NULL,343),(469,'Rifacimento Soffitti',28,NULL,349),(470,'Rifacimento Soffitti',28,NULL,355),(471,'Rifacimento Soffitti',28,NULL,361),(472,'Rifacimento Soffitti',28,NULL,367),(473,'Rifacimento Soffitti',28,NULL,373),(474,'Rifacimento Pavimenti',29,NULL,338),(475,'Rifacimento Pavimenti',29,NULL,344),(476,'Rifacimento Pavimenti',29,NULL,350),(477,'Rifacimento Pavimenti',29,NULL,356),(478,'Rifacimento Pavimenti',29,NULL,362),(479,'Rifacimento Pavimenti',29,NULL,368),(480,'Rifacimento Pavimenti',29,NULL,374),(481,'Creazione fondamenta',30,67,NULL),(482,'Creazione fondamenta',30,68,NULL),(483,'Creazione fondamenta',30,69,NULL),(484,'Costruzione pareti e soffitti',31,NULL,397),(485,'Costruzione pareti e soffitti',31,NULL,399),(486,'Costruzione pareti e soffitti',31,NULL,400),(487,'Costruzione pareti e soffitti',31,NULL,401),(488,'Costruzione pareti e soffitti',31,NULL,402),(489,'Costruzione pareti e soffitti',31,NULL,403),(490,'Costruzione pareti e soffitti',31,NULL,405),(491,'Costruzione pareti e soffitti',31,NULL,406),(492,'Costruzione pareti e soffitti',31,NULL,407),(493,'Costruzione pareti e soffitti',31,NULL,408),(494,'Costruzione pareti e soffitti',31,NULL,409),(495,'Costruzione pareti e soffitti',31,NULL,411),(496,'Costruzione pareti e soffitti',31,NULL,412),(497,'Costruzione pareti e soffitti',31,NULL,413),(498,'Costruzione pareti e soffitti',31,NULL,414),(499,'Installazione impianti gas-elettrico-idrico',32,67,NULL),(505,'Installazione impianti gas-elettrico-idrico',32,68,NULL),(511,'Installazione impianti gas-elettrico-idrico',32,69,NULL),(517,'Imbiancatura',33,NULL,397),(518,'Imbiancatura',33,NULL,399),(519,'Imbiancatura',33,NULL,400),(520,'Imbiancatura',33,NULL,401),(521,'Imbiancatura',33,NULL,402),(522,'Imbiancatura',33,NULL,403),(523,'Imbiancatura',33,NULL,405),(524,'Imbiancatura',33,NULL,406),(525,'Imbiancatura',33,NULL,407),(526,'Imbiancatura',33,NULL,408),(527,'Imbiancatura',33,NULL,409),(528,'Imbiancatura',33,NULL,411),(529,'Imbiancatura',33,NULL,412),(530,'Imbiancatura',33,NULL,413),(531,'Imbiancatura',33,NULL,414),(532,'Creazione fondamenta',34,70,NULL),(533,'Creazione fondamenta',34,71,NULL),(534,'Creazione fondamenta',34,72,NULL),(535,'Creazione fondamenta',34,73,NULL),(536,'Creazione fondamenta',34,74,NULL),(537,'Creazione fondamenta',34,75,NULL),(538,'Creazione fondamenta',34,76,NULL),(539,'Creazione fondamenta',34,77,NULL),(540,'Creazione fondamenta',34,78,NULL),(541,'Costruzione pareti e soffitti',35,NULL,415),(542,'Costruzione pareti e soffitti',35,NULL,417),(543,'Costruzione pareti e soffitti',35,NULL,418),(544,'Costruzione pareti e soffitti',35,NULL,419),(545,'Costruzione pareti e soffitti',35,NULL,420),(546,'Costruzione pareti e soffitti',35,NULL,421),(547,'Costruzione pareti e soffitti',35,NULL,423),(548,'Costruzione pareti e soffitti',35,NULL,424),(549,'Costruzione pareti e soffitti',35,NULL,425),(550,'Costruzione pareti e soffitti',35,NULL,426),(551,'Costruzione pareti e soffitti',35,NULL,427),(552,'Costruzione pareti e soffitti',35,NULL,429),(553,'Costruzione pareti e soffitti',35,NULL,430),(554,'Costruzione pareti e soffitti',35,NULL,431),(555,'Costruzione pareti e soffitti',35,NULL,432),(556,'Costruzione pareti e soffitti',35,NULL,433),(557,'Costruzione pareti e soffitti',35,NULL,435),(558,'Costruzione pareti e soffitti',35,NULL,436),(559,'Costruzione pareti e soffitti',35,NULL,437),(560,'Costruzione pareti e soffitti',35,NULL,438),(561,'Costruzione pareti e soffitti',35,NULL,439),(562,'Costruzione pareti e soffitti',35,NULL,441),(563,'Costruzione pareti e soffitti',35,NULL,442),(564,'Costruzione pareti e soffitti',35,NULL,443),(565,'Costruzione pareti e soffitti',35,NULL,444),(566,'Costruzione pareti e soffitti',35,NULL,445),(567,'Costruzione pareti e soffitti',35,NULL,447),(568,'Costruzione pareti e soffitti',35,NULL,448),(569,'Costruzione pareti e soffitti',35,NULL,449),(570,'Costruzione pareti e soffitti',35,NULL,450),(571,'Costruzione pareti e soffitti',35,NULL,451),(572,'Costruzione pareti e soffitti',35,NULL,453),(573,'Costruzione pareti e soffitti',35,NULL,454),(574,'Costruzione pareti e soffitti',35,NULL,455),(575,'Costruzione pareti e soffitti',35,NULL,456),(576,'Costruzione pareti e soffitti',35,NULL,457),(577,'Costruzione pareti e soffitti',35,NULL,459),(578,'Costruzione pareti e soffitti',35,NULL,460),(579,'Costruzione pareti e soffitti',35,NULL,461),(580,'Costruzione pareti e soffitti',35,NULL,462),(581,'Costruzione pareti e soffitti',35,NULL,463),(582,'Costruzione pareti e soffitti',35,NULL,465),(583,'Costruzione pareti e soffitti',35,NULL,466),(584,'Costruzione pareti e soffitti',35,NULL,467),(585,'Costruzione pareti e soffitti',35,NULL,468),(586,'Installazione impianti gas-elettrico-idrico',36,70,NULL),(592,'Installazione impianti gas-elettrico-idrico',36,71,NULL),(598,'Installazione impianti gas-elettrico-idrico',36,72,NULL),(604,'Installazione impianti gas-elettrico-idrico',36,73,NULL),(610,'Installazione impianti gas-elettrico-idrico',36,74,NULL),(616,'Installazione impianti gas-elettrico-idrico',36,75,NULL),(622,'Installazione impianti gas-elettrico-idrico',36,76,NULL),(628,'Installazione impianti gas-elettrico-idrico',36,77,NULL),(634,'Installazione impianti gas-elettrico-idrico',36,78,NULL),(640,'Imbiancatura',37,NULL,415),(641,'Imbiancatura',37,NULL,417),(642,'Imbiancatura',37,NULL,418),(643,'Imbiancatura',37,NULL,419),(644,'Imbiancatura',37,NULL,420),(645,'Imbiancatura',37,NULL,421),(646,'Imbiancatura',37,NULL,423),(647,'Imbiancatura',37,NULL,424),(648,'Imbiancatura',37,NULL,425),(649,'Imbiancatura',37,NULL,426),(650,'Imbiancatura',37,NULL,427),(651,'Imbiancatura',37,NULL,429),(652,'Imbiancatura',37,NULL,430),(653,'Imbiancatura',37,NULL,431),(654,'Imbiancatura',37,NULL,432),(655,'Imbiancatura',37,NULL,433),(656,'Imbiancatura',37,NULL,435),(657,'Imbiancatura',37,NULL,436),(658,'Imbiancatura',37,NULL,437),(659,'Imbiancatura',37,NULL,438),(660,'Imbiancatura',37,NULL,439),(661,'Imbiancatura',37,NULL,441),(662,'Imbiancatura',37,NULL,442),(663,'Imbiancatura',37,NULL,443),(664,'Imbiancatura',37,NULL,444),(665,'Imbiancatura',37,NULL,445),(666,'Imbiancatura',37,NULL,447),(667,'Imbiancatura',37,NULL,448),(668,'Imbiancatura',37,NULL,449),(669,'Imbiancatura',37,NULL,450),(670,'Imbiancatura',37,NULL,451),(671,'Imbiancatura',37,NULL,453),(672,'Imbiancatura',37,NULL,454),(673,'Imbiancatura',37,NULL,455),(674,'Imbiancatura',37,NULL,456),(675,'Imbiancatura',37,NULL,457),(676,'Imbiancatura',37,NULL,459),(677,'Imbiancatura',37,NULL,460),(678,'Imbiancatura',37,NULL,461),(679,'Imbiancatura',37,NULL,462),(680,'Imbiancatura',37,NULL,463),(681,'Imbiancatura',37,NULL,465),(682,'Imbiancatura',37,NULL,466),(683,'Imbiancatura',37,NULL,467),(684,'Imbiancatura',37,NULL,468),(685,"Rifacimento parete", 9, NULL, 64);
INSERT INTO `puntodaccesso`( X, Y, Lunghezza, Altezza, TipologiaPuntoAccesso, PuntoCardinale, FK_IdVanoOut, FK_IdVanoIn ) VALUES (2,1,1,2,'Porta','N',1,NULL),(2,1,1,2,'Porta','S',1,5),(2,0.9,0.8,1.8,'Arco','NE',5,6),(2.5,0.875,0.8,1.75,'Apertura senza serramenti','NW',6,2),(2.5,1.05,0.8,2.1,'Apertura senza serramenti','E',2,3),(1,0.96,0.8,1.92,'Apertura senza serramenti','W',3,4),(1.5,1,0.8,2,'Porta','N',8,NULL),(1.5,1.05,0.8,2.1,'Porta','W',7,8),(1.5,0.96,0.8,1.92,'Apertura senza serramenti','S',8,9),(1.5,0.875,0.8,1.75,'Porta','SE',9,10),(1.3,1.05,0.8,2.1,'Porta','W',8,10),(1.3,0.96,0.8,1.92,'Porta','S',11,NULL),(1.3,1.15,1,2.3,'Arco','W',11,12),(4,0.9,1,1.8,'Arco','N',11,13),(3,1.05,1,2.1,'Arco','S',14,15),(12,0.96,1,1.92,'Arco','W',15,16),(3,0.96,1,1.92,'Porta','S',18,19),(1,0.9,0.8,1.8,'Arco','E',18,20),(5,0.875,0.8,1.75,'Arco','NW',18,21),(10,1.05,0.8,2.1,'Arco','N',21,22),(2,0.96,0.8,1.92,'Arco','W',22,23),(3,1,0.8,2,'Arco','S',23,NULL),(2,0.96,0.8,1.92,'Porta','W',24,25),(1,0.875,0.8,1.75,'Apertura senza serramenti','N',24,27),(1,1.05,0.8,2.1,'Porta','S',24,26),(1,0.96,0.8,1.92,'Porta','NE',26,28),(1.5,0.875,0.8,1.75,'Porta','N',26,29),(1.5,1.05,0.9,2.1,'Arco','NW',29,30),(2,1,0.9,2,'Arco','W',33,31),(2,1.05,0.9,2.1,'Arco','N',31,35),(1,0.96,0.9,1.92,'Arco','NE',35,32),(1,0.875,0.9,1.75,'Porta','S',32,34),(1,1.05,0.9,2.1,'Porta','SE',32,36),(1.7,0.96,0.9,1.92,'Porta','W',36,38),(1.2,1.15,0.9,2.3,'Porta','S',36,37),(2,0.9,0.9,1.8,'Porta','W',39,NULL),(1,0.875,0.8,1.75,'Arco','N',39,41),(1,1.05,0.8,2.1,'Arco','S',41,43),(2,0.96,0.8,1.92,'Arco','W',41,40),(2,1,0.8,2,'Arco','SE',40,42),(1,1.05,0.8,2.1,'Porta','W',40,44),(0.9,0.96,0.8,1.92,'Porta','N',40,45),(0.9,0.9,0.8,1.8,'Porta','S',45,46),(0.9,0.875,0.8,1.75,'Arco','N',46,47),(3,0.875,0.8,1.75,'Porta','NE',49,50),(1,1.05,0.8,2.1,'Apertura senza serramenti','N',51,NULL),(1,0.96,0.8,1.92,'Porta','NW',51,52),(1,0.875,0.8,1.75,'Porta','E',52,56),(1,1.05,0.8,2.1,'Porta','W',56,53),(1,0.96,0.8,1.92,'Arco','N',53,54),(1,1.05,0.8,2.1,'Porta','S',57,NULL),(1,0.96,0.8,1.92,'Apertura senza serramenti','SE',57,58),(2,0.875,0.8,1.75,'Porta','W',58,59),(2,1.05,0.8,2.1,'Porta','S',58,60),(2,0.96,0.8,1.92,'Porta','SW',58,61),(2.3,1.15,0.8,2.3,'Porta','N',58,62),(2.3,0.9,0.8,1.8,'Porta','S',61,63),(2.3,1.05,0.8,2.1,'Arco','SE',64,65),(2.2,0.96,0.8,1.92,'Arco','W',65,66),(2.1,1.05,0.8,2.1,'Arco','E',67,68),(2.1,0.96,0.8,1.92,'Arco','W',68,69),(2.1,0.9,0.8,1.8,'Porta','N',70,NULL),(0.9,1.05,0.75,2.1,'Apertura senza serramenti','S',70,72),(1,0.96,0.75,1.92,'Porta','SE',72,73),(2,1,0.75,2,'Porta','W',72,74),(3,1.05,0.75,2.1,'Porta','N',74,75),(1,0.96,0.75,1.92,'Porta','S',75,78),(1,0.875,0.75,1.75,'Porta','NE',78,76),(1,1.05,0.75,2.1,'Porta','N',78,77);
INSERT INTO `fornitore` VALUES ('84630152772' , 'Benni materials SRL'), ('35498623144' , 'Mava toffi SRL'),('41486886249' , 'Materiali S.A.S'),('58843462067' , 'Tristi & co SRL'),('37468674251' , 'Agrana S.A.S'),('95910782700' , 'Bianchi SRL'),('54908173906' , 'Costruzioni SRL'),('80231812734' , 'Mattone SRL'),('47164159739' , 'Contesi SRL'),('81512365057' , 'Piacere SRL');
INSERT INTO `acquisto` VALUES (1,0.29,54,'2014-03-01','35498623144',NULL,NULL,'Cementum',NULL),(2,1,200,'2014-03-01','84630152772',NULL,'Mattone in terra cruda',NULL,NULL),(3,0.6,80,'2014-03-01','35498623144',NULL,NULL,'Grande Marble',NULL),(4,1.1,100,'2014-03-01','58843462067',NULL,'Mattone in laterizio',NULL,NULL),(5,0.3,80,'2014-03-01','35498623144',NULL,NULL,'Poster',NULL),(6,1.3,100,'2014-03-01','84630152772',NULL,'Alveolater',NULL,NULL),(7,8.5,15,'2014-03-01','35498623144','Pannello',NULL,NULL,NULL),(8,1.3,90,'2014-03-01','84630152772',NULL,'Alveolater',NULL,NULL),(9,0.5,66,'2014-02-21','35498623144',NULL,NULL,'Mystone travertino',NULL),(10,1.22,31,'2014-03-01','41486886249','Lamiera',NULL,NULL,NULL),(11,0.9,44,'2014-03-01','58843462067',NULL,'Blocco di cemento',NULL,NULL),(12,2,100,'2014-03-01','37468674251',NULL,NULL,'Vero',NULL),(13,14,20,'2014-03-01','95910782700','Policarbonato',NULL,NULL,NULL),(14,0.7,66,'2014-03-01','54908173906',NULL,'Blocco di cemento',NULL,NULL),(15,6.4,200,'2014-03-01','80231812734',NULL,NULL,'Legno',NULL),(16,15,9,'2018-09-20','47164159739','Resina Indurente',NULL,NULL,NULL),(17,1.1,100,'2018-09-20','81512365057',NULL,'Mattone in terra cruda',NULL,NULL),(18,0.4,106,'2018-09-20','80231812734',NULL,NULL,'Cementum',NULL),(19,40,3,'2018-09-20','47164159739','Quarzo',NULL,NULL,NULL),(20,1.1,99,'2018-09-20','81512365057',NULL,'Mattone in terra cruda',NULL,NULL),(21,16,8,'2018-09-27','47164159739','Policarbonato',NULL,NULL,NULL),(22,1,99,'2018-09-20','35498623144',NULL,'Mattone in laterizio',NULL,NULL),(23,1,88,'2018-09-20','84630152772',NULL,'Mattone in terra cruda',NULL,NULL),(24,16,7,'2018-09-20','35498623144','Resina Indurente',NULL,NULL,NULL),(25,0.9,77,'2018-09-20','58843462067',NULL,'Mattone in terra cruda',NULL,NULL),(26,1,66,'2018-09-20','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(27,4.5,6,'2018-09-27','84630152772','Rete',NULL,NULL,NULL),(28,1,99,'2018-09-27','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(29,10.5,6,'2018-09-20','58843462067','Corda in Ferro',NULL,NULL,NULL),(30,0.85,66,'2018-09-20','37468674251',NULL,'Mattone in terra cruda',NULL,NULL),(31,9,5,'2018-09-20','95910782700','Perlite',NULL,NULL,NULL),(32,1,66,'2018-09-20','84630152772',NULL,'Mattone in terra cruda',NULL,NULL),(33,2.27,2,'2018-09-20','35498623144','Ghiaia',NULL,NULL,NULL),(34,0.9,99,'2018-09-20','41486886249',NULL,'Mattone in laterizio',NULL,NULL),(35,1.2,150,'2018-09-20','58843462067',NULL,'Alveolater',NULL,NULL),(36,1.1,156,'2018-09-20','37468674251',NULL,'Alveolater',NULL,NULL),(37,1,155,'2018-09-27','95910782700',NULL,'Alveolater',NULL,NULL),(38,5.5,4,'2018-09-27','54908173906','Sabbia',NULL,NULL,NULL),(39,1,45,'2018-09-20','80231812734',NULL,'Alveolater',NULL,NULL),(40,1,66,'2018-09-20','47164159739',NULL,'Alveolater',NULL,NULL),(41,1.5,89,'2018-09-27','81512365057',NULL,'Alveolater',NULL,NULL),(42,9,5,'2018-09-27','37468674251','Pannello Preformato',NULL,NULL,NULL),(43,0.85,99,'2018-09-27','95910782700',NULL,'Mattone semipieno',NULL,NULL),(44,0.7,88,'2018-09-27','54908173906',NULL,'Blocco di cemento',NULL,NULL),(45,0.8,77,'2018-09-27','80231812734',NULL,'Blocco di cemento',NULL,NULL),(46,0.8,99,'2018-09-20','47164159739',NULL,'Blocco di cemento',NULL,NULL),(47,0.7,100,'2018-09-20','81512365057',NULL,'Blocco di cemento',NULL,NULL),(48,1.4,101,'2018-09-27','47164159739',NULL,'Mattone 2 fori',NULL,NULL),(49,1.5,102,'2018-09-27','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(50,7,10,'2018-09-27','84630152772','Resina',NULL,NULL,NULL),(51,1.5,106,'2018-09-27','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(52,1.3,106,'2018-09-20','58843462067',NULL,'Mattone 2 fori',NULL,NULL),(53,45,8,'2018-09-20','35498623144','Quarzo',NULL,NULL,NULL),(54,1.3,145,'2018-09-27','84630152772',NULL,'Mattone 2 fori',NULL,NULL),(55,0.9,146,'2018-09-27','35498623144',NULL,'Blocco di cemento',NULL,NULL),(56,16,12,'2018-09-27','35498623144','Resina Indurente',NULL,NULL,NULL),(57,1,456,'2018-09-27','84630152772',NULL,'Blocco di cemento',NULL,NULL),(58,1,560,'2018-09-20','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(59,1.3,566,'2018-09-20','58843462067',NULL,'Mattone 2 fori',NULL,NULL),(60,0.1,6,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(61,0.2,8,'2018-09-25','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(62,0.1,12,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(63,0.2,40,'2018-09-25','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(64,0.1,15,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(65,0.15,11,'2018-09-25','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(66,0.5,12,'2018-09-25','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(67,0.1,13,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(68,0.2,14,'2018-09-25','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(69,0.1,4,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(70,0.5,5,'2018-09-25','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(71,0.1,81,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(72,0.2,78,'2018-09-25','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(73,0.1,12,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(74,0.2,11,'2018-09-25','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(75,0.1,12,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(76,0.15,3,'2018-09-25','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(77,0.5,4,'2018-09-25','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(78,0.1,5,'2018-09-25','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(79,0.2,8,'2018-09-25','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(80,0.22,9,'2018-09-25','54908173906','Materiale per installazione servizi',NULL,NULL,NULL),(81,0.3,7,'2018-09-25','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(82,0.3,9,'2018-09-25','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(83,0.1,8,'2018-09-25','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(84,0.3,9,'2018-09-25','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(85,0.3,7,'2018-09-25','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(86,0.1,9,'2018-09-25','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(87,0.3,9,'2018-09-25','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(88,0.1,3,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(89,0.2,66,'2018-09-25','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(90,0.1,12,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(91,0.5,14,'2018-09-25','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(92,0.1,12,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(93,0.2,11,'2018-09-25','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(94,0.1,10,'2018-09-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(95,0.2,11,'2018-09-25','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(96,7,2,'2022-01-20','35498623144','Vernice',NULL,NULL,NULL),(97,5,3,'2022-01-20','41486886249','Vernice',NULL,NULL,NULL),(98,16,2,'2022-01-20','58843462067',NULL,NULL,NULL,'Intonaco civile'),(99,4.5,4,'2022-01-20','37468674251','Vernice',NULL,NULL,NULL),(100,6,5,'2022-01-20','95910782700','Vernice',NULL,NULL,NULL),(101,35,2,'2022-01-20','54908173906',NULL,NULL,NULL,'Spachtelputz'),(102,11,1,'2022-01-20','80231812734','Vernice',NULL,NULL,NULL),(103,22,1,'2022-01-20','47164159739',NULL,NULL,NULL,'Beton Cire'),(104,5,3,'2022-01-20','81512365057','Vernice',NULL,NULL,NULL),(105,11,4,'2022-01-20','80231812734','Vernice',NULL,NULL,NULL),(106,32,5,'2022-01-20','35498623144',NULL,NULL,NULL,'Granol'),(107,4,6,'2022-01-20','84630152772','Vernice',NULL,NULL,NULL),(108,7,2,'2022-01-20','35498623144','Vernice',NULL,NULL,NULL),(109,16,3,'2022-01-20','58843462067',NULL,NULL,NULL,'Intonaco civile'),(110,7,1,'2022-01-20','35498623144','Vernice',NULL,NULL,NULL),(111,14,2,'2022-01-20','84630152772',NULL,NULL,NULL,'Intonaco civile'),(112,7,3,'2022-01-20','35498623144','Vernice',NULL,NULL,NULL),(113,4,3,'2022-01-20','84630152772','Vernice',NULL,NULL,NULL),(114,7,3,'2022-01-20','35498623144','Vernice',NULL,NULL,NULL),(115,35,3,'2022-01-20','41486886249',NULL,NULL,NULL,'Beton Cire'),(116,8,6,'2022-01-20','58843462067','Vernice',NULL,NULL,NULL),(117,33,5,'2022-01-20','37468674251',NULL,NULL,NULL,'Granol'),(118,6,4,'2022-01-20','95910782700','Vernice',NULL,NULL,NULL),(119,24,1,'2022-01-20','35498623144',NULL,NULL,NULL,'Intonaco argilloso'),(120,4,2,'2022-01-20','84630152772','Vernice',NULL,NULL,NULL),(121,7,1,'2022-01-20','35498623144','Vernice',NULL,NULL,NULL),(122,40,2,'2022-01-20','58843462067',NULL,NULL,NULL,'MP2'),(123,7,5,'2022-01-20','35498623144','Vernice',NULL,NULL,NULL),(124,50,8,'2022-01-20','84630152772',NULL,NULL,NULL,'KP3'),(125,7,4,'2022-01-20','35498623144','Vernice',NULL,NULL,NULL),(126,46,1,'2022-01-20','84630152772',NULL,NULL,NULL,'Rofix'),(127,7,2,'2022-01-20','35498623144','Vernice',NULL,NULL,NULL),(128,30,3,'2022-01-20','41486886249',NULL,NULL,NULL,'Granol'),(129,8,5,'2022-01-20','58843462067','Vernice',NULL,NULL,NULL),(130,4.5,2,'2022-01-20','37468674251','Vernice',NULL,NULL,NULL),(131,26,2,'2022-01-20','95910782700',NULL,NULL,NULL,'Intonaco civile'),(132,10,2,'2022-01-20','54908173906','Vernice',NULL,NULL,NULL),(133,50,5,'2022-01-20','80231812734',NULL,NULL,NULL,'Spachtelputz'),(134,9,6,'2022-01-20','47164159739','Vernice',NULL,NULL,NULL),(135,35,5,'2022-01-20','81512365057',NULL,NULL,NULL,'Beton Cire'),(136,11,5,'2022-01-20','80231812734','Vernice',NULL,NULL,NULL),(137,35,4,'2022-01-20','47164159739',NULL,NULL,NULL,'Granol'),(138,5,4,'2022-01-20','81512365057','Vernice',NULL,NULL,NULL),(139,9,5,'2022-01-20','47164159739','Vernice',NULL,NULL,NULL),(140,33,5,'2022-01-20','35498623144',NULL,NULL,NULL,'Beton Cire'),(141,9,5,'2022-01-20','84630152772','Vernice',NULL,NULL,NULL),(142,33,5,'2022-01-20','35498623144',NULL,NULL,NULL,'Granol'),(143,8,7,'2022-01-20','58843462067','Vernice',NULL,NULL,NULL),(144,22,1,'2022-01-20','35498623144',NULL,NULL,NULL,'Intonaco civile'),(145,4,2,'2022-01-20','84630152772','Vernice',NULL,NULL,NULL),(146,15,5,'2017-05-01','35498623144','Corda in Ferro',NULL,NULL,NULL),(147,0.9,100,'2017-04-30','58843462067',NULL,'Mattone in terra cruda',NULL,NULL),(148,0.69,101,'2017-05-01','37468674251',NULL,NULL,'Memoria',NULL),(149,0.89,99,'2017-05-01','95910782700',NULL,'Alveolater',NULL,NULL),(150,1,88,'2017-05-01','84630152772',NULL,NULL,'Uniche',NULL),(151,0.88,77,'2017-05-01','35498623144',NULL,'Alveolater',NULL,NULL),(152,0.35,88,'2017-05-01','41486886249',NULL,NULL,'Cementum',NULL),(153,0.9,99,'2017-05-01','58843462067',NULL,'Blocco di cemento',NULL,NULL),(154,0.4,100,'2017-05-01','37468674251',NULL,NULL,'Pietra',NULL),(155,5,6,'2017-05-01','35498623144','Rete',NULL,NULL,NULL),(156,1,200,'2017-04-30','84630152772',NULL,'Mattone 2 fori',NULL,NULL),(157,10,6,'2017-04-30','35498623144','Perlite',NULL,NULL,NULL),(158,1.1,100,'2017-04-30','58843462067',NULL,'Mattone in laterizio',NULL,NULL),(159,2.27,6,'2017-04-30','35498623144','Ghiaia',NULL,NULL,NULL),(160,1,100,'2017-04-30','84630152772',NULL,'Mattone in terra cruda',NULL,NULL),(161,1,106,'2017-04-30','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(162,1,106,'2017-04-30','84630152772',NULL,'Mattone in terra cruda',NULL,NULL),(163,1,109,'2017-04-30','35498623144',NULL,'Mattone in laterizio',NULL,NULL),(164,4,19,'2017-04-30','41486886249','Sabbia',NULL,NULL,NULL),(165,1.2,99,'2017-05-01','58843462067',NULL,'Alveolater',NULL,NULL),(166,1.1,88,'2017-05-01','37468674251',NULL,'Alveolater',NULL,NULL),(167,1,99,'2017-05-01','95910782700',NULL,'Alveolater',NULL,NULL),(168,9,8,'2017-05-01','54908173906','Pannello',NULL,NULL,NULL),(169,1,99,'2017-05-01','80231812734',NULL,'Alveolater',NULL,NULL),(170,10,12,'2017-05-01','47164159739','Pannello Preformato',NULL,NULL,NULL),(171,1.5,103,'2017-05-01','81512365057',NULL,'Alveolater',NULL,NULL),(172,1,103,'2017-05-01','80231812734',NULL,'Alveolater',NULL,NULL),(173,0.9,102,'2017-05-01','47164159739',NULL,'Mattone semipieno',NULL,NULL),(174,0.7,102,'2017-05-01','81512365057',NULL,'Blocco di cemento',NULL,NULL),(175,2,6,'2017-05-01','47164159739','Lamiera',NULL,NULL,NULL),(176,0.9,100,'2017-05-01','35498623144',NULL,'Blocco di cemento',NULL,NULL),(177,1,100,'2017-05-01','84630152772',NULL,'Blocco di cemento',NULL,NULL),(178,8,10,'2017-05-01','35498623144','Resina',NULL,NULL,NULL),(179,0.9,135,'2017-05-01','58843462067',NULL,'Blocco di cemento',NULL,NULL),(180,1.5,300,'2017-05-01','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(181,6.3,120,'2017-05-01','84630152772',NULL,NULL,'Legno',NULL),(182,45,25,'2017-05-01','35498623144','Quarzo',NULL,NULL,NULL),(183,1.3,120,'2017-05-01','58843462067',NULL,'Mattone 2 fori',NULL,NULL),(184,6.3,45,'2017-05-01','37468674251',NULL,NULL,'Legno',NULL),(185,14,20,'2017-05-01','95910782700','Policarbonato',NULL,NULL,NULL),(186,1.3,200,'2017-05-01','84630152772',NULL,'Mattone 2 fori',NULL,NULL),(187,0.1,3,'2020-05-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(188,0.15,5,'2020-05-05','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(189,0.5,6,'2020-05-05','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(190,0.1,9,'2020-05-05','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(191,0.2,8,'2020-05-05','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(192,0.22,7,'2020-05-05','54908173906','Materiale per installazione servizi',NULL,NULL,NULL),(193,0.3,12,'2020-05-05','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(194,0.3,13,'2020-05-05','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(195,0.1,16,'2020-05-05','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(196,0.1,50,'2020-05-05','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(197,0.2,12,'2020-05-05','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(198,0.22,13,'2020-05-05','54908173906','Materiale per installazione servizi',NULL,NULL,NULL),(199,0.3,16,'2020-05-05','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(200,0.3,15,'2020-05-05','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(201,0.1,1,'2020-05-05','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(202,0.3,2,'2020-05-05','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(203,0.1,3,'2020-05-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(204,0.2,6,'2020-05-05','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(205,0.1,9,'2020-05-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(206,0.5,8,'2020-05-05','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(207,0.1,7,'2020-05-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(208,0.2,4,'2020-05-05','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(209,0.1,5,'2020-05-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(210,0.5,2,'2020-05-05','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(211,7,2,'2020-12-16','35498623144','Vernice',NULL,NULL,NULL),(212,4,3,'2020-12-16','84630152772','Vernice',NULL,NULL,NULL),(213,30,2,'2020-12-16','35498623144',NULL,NULL,NULL,'Beton Cire'),(214,8,1,'2020-12-16','58843462067','Vernice',NULL,NULL,NULL),(215,26,3,'2020-12-16','35498623144',NULL,NULL,NULL,'Granol'),(216,4,1,'2020-12-16','84630152772','Vernice',NULL,NULL,NULL),(217,20,2,'2020-12-16','35498623144',NULL,NULL,NULL,'Intonaco civile'),(218,4,5,'2020-12-16','84630152772','Vernice',NULL,NULL,NULL),(219,40,3,'2020-12-16','35498623144',NULL,NULL,NULL,'Spachtelputz'),(220,5,4,'2020-12-16','41486886249','Vernice',NULL,NULL,NULL),(221,8,2,'2020-12-16','58843462067','Vernice',NULL,NULL,NULL),(222,22,1,'2020-12-16','37468674251',NULL,NULL,NULL,'Intonaco argilloso'),(223,6,2,'2020-12-16','95910782700','Vernice',NULL,NULL,NULL),(224,20,3,'2020-12-16','54908173906',NULL,NULL,NULL,'Intonaco civile'),(225,21,1,'2020-12-16','80231812734','Vernice',NULL,NULL,NULL),(226,40,2,'2020-12-16','47164159739',NULL,NULL,NULL,'Spachtelputz'),(227,5,1,'2020-12-16','81512365057','Vernice',NULL,NULL,NULL),(228,30,3,'2020-12-16','80231812734',NULL,NULL,NULL,'Beton Cire'),(229,9,2,'2020-12-16','47164159739','Vernice',NULL,NULL,NULL),(230,5,1,'2020-12-16','81512365057','Vernice',NULL,NULL,NULL),(231,26,2,'2020-12-16','47164159739',NULL,NULL,NULL,'Granol'),(232,7,12,'2020-12-16','35498623144','Vernice',NULL,NULL,NULL),(233,22,3,'2020-12-16','84630152772',NULL,NULL,NULL,'Intonaco argilloso'),(234,7,1,'2020-12-16','35498623144','Vernice',NULL,NULL,NULL),(235,20,2,'2020-12-16','58843462067',NULL,NULL,NULL,'Intonaco civile'),(236,7,1,'2020-12-16','35498623144','Vernice',NULL,NULL,NULL),(237,24,5,'2020-12-16','84630152772',NULL,NULL,NULL,'Intonaco civile'),(238,7,2,'2020-12-16','35498623144','Vernice',NULL,NULL,NULL),(239,8,1,'2020-12-16','58843462067','Vernice',NULL,NULL,NULL),(240,40,1,'2020-12-16','37468674251',NULL,NULL,NULL,'Spachtelputz'),(241,6,2,'2020-12-16','95910782700','Vernice',NULL,NULL,NULL),(242,30,3,'2020-12-16','84630152772',NULL,NULL,NULL,'Beton Cire'),(243,7,1,'2020-12-16','35498623144','Vernice',NULL,NULL,NULL),(244,30,3,'2020-12-16','41486886249',NULL,NULL,NULL,'Granol'),(245,8,4,'2020-12-16','58843462067','Vernice',NULL,NULL,NULL),(246,22,2,'2020-12-16','37468674251',NULL,NULL,NULL,'Intonaco argilloso'),(247,15,5,'2022-12-12','95910782700','Resina Indurente',NULL,NULL,NULL),(248,1,200,'2022-12-12','54908173906',NULL,'Alveolater',NULL,NULL),(249,6.4,120,'2022-12-12','80231812734',NULL,NULL,'Legno',NULL),(250,2.27,6,'2022-12-12','47164159739','Ghiaia',NULL,NULL,NULL),(251,0.7,111,'2022-12-12','81512365057',NULL,'Blocco di cemento',NULL,NULL),(252,0.3,100,'2022-12-12','37468674251',NULL,NULL,'Pietra',NULL),(253,1.2,25,'2022-12-12','95910782700',NULL,'Mattone 2 fori',NULL,NULL),(254,0.7,66,'2022-12-12','54908173906',NULL,NULL,'Grande Marble',NULL),(255,1,100,'2021-06-03','80231812734',NULL,'Mattone in terra cruda',NULL,NULL),(256,2,60,'2021-06-03','47164159739',NULL,NULL,'Vero',NULL),(257,0.1,6,'2021-06-03','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(258,0.3,6,'2021-06-03','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(259,0.1,12,'2021-06-03','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(260,0.2,2,'2021-06-03','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(261,0.1,3,'2021-06-03','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(262,0.9,100,'2022-09-03','58843462067',NULL,'Mattone in terra cruda',NULL,NULL),(263,1,120,'2022-09-03','35498623144',NULL,'Mattone in laterizio',NULL,NULL),(264,1,120,'2022-09-03','84630152772',NULL,'Mattone in terra cruda',NULL,NULL),(265,0.3,60,'2022-09-03','35498623144',NULL,NULL,'Pietra',NULL),(266,4,5,'2022-09-03','35498623144','Sabbia',NULL,NULL,NULL),(267,1,100,'2022-09-03','84630152772',NULL,'Mattone in terra cruda',NULL,NULL),(268,1,100,'2022-09-03','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(269,8,2,'2022-12-10','58843462067','Vernice',NULL,NULL,NULL),(270,7,3,'2022-12-10','35498623144','Vernice',NULL,NULL,NULL),(271,14,2,'2022-12-10','84630152772',NULL,NULL,NULL,'Intonaco civile'),(272,7,1,'2022-12-10','35498623144','Vernice',NULL,NULL,NULL),(273,40,2,'2022-12-10','84630152772',NULL,NULL,NULL,'Spachtelputz'),(274,7,1,'2022-12-10','35498623144','Vernice',NULL,NULL,NULL),(275,60,2,'2022-12-10','41486886249',NULL,NULL,NULL,'Spachtelputz'),(276,8,2,'2022-12-10','58843462067','Vernice',NULL,NULL,NULL),(277,30,1,'2022-12-10','35498623144',NULL,NULL,NULL,'Beton Cire'),(278,1.1,200,'2020-01-15','84630152772',NULL,'Mattone in laterizio',NULL,NULL),(279,10,20,'2020-01-15','35498623144','Pannello Preformato',NULL,NULL,NULL),(280,1.2,100,'2020-01-15','58843462067',NULL,'Alveolater',NULL,NULL),(281,1,100,'2020-01-15','35498623144',NULL,'Alveolater',NULL,NULL),(282,1.3,100,'2020-01-15','84630152772',NULL,'Alveolater',NULL,NULL),(283,1,100,'2020-01-15','35498623144',NULL,'Alveolater',NULL,NULL),(284,1.3,100,'2020-01-15','84630152772',NULL,'Alveolater',NULL,NULL),(285,1,100,'2020-01-15','35498623144',NULL,'Alveolater',NULL,NULL),(286,1.5,100,'2020-01-15','41486886249',NULL,'Mattone semipieno',NULL,NULL),(287,8,6,'2020-01-15','58843462067','Resina',NULL,NULL,NULL),(288,0.7,25,'2020-01-15','37468674251',NULL,'Blocco di cemento',NULL,NULL),(289,0.7,60,'2020-01-15','95910782700',NULL,'Blocco di cemento',NULL,NULL),(290,0.4,66,'2020-01-15','54908173906',NULL,NULL,'Pietra',NULL),(291,40,5,'2020-01-15','80231812734','Quarzo',NULL,NULL,NULL),(292,0.8,120,'2020-01-15','47164159739',NULL,'Blocco di cemento',NULL,NULL),(293,0.7,200,'2020-01-15','81512365057',NULL,'Blocco di cemento',NULL,NULL),(294,15,6,'2020-01-15','80231812734','Resina Indurente',NULL,NULL,NULL),(295,1.4,190,'2020-01-15','47164159739',NULL,'Mattone 2 fori',NULL,NULL),(296,1.2,199,'2020-01-15','81512365057',NULL,'Mattone 2 fori',NULL,NULL),(297,1.4,200,'2020-01-15','47164159739',NULL,'Mattone 2 fori',NULL,NULL),(298,4.5,10,'2020-01-15','35498623144','Rete',NULL,NULL,NULL),(299,1.3,120,'2020-01-15','84630152772',NULL,'Mattone 2 fori',NULL,NULL),(300,9,16,'2020-01-15','35498623144','Perlite',NULL,NULL,NULL),(301,0.9,103,'2020-01-15','58843462067',NULL,'Blocco di cemento',NULL,NULL),(302,2.27,40,'2020-01-15','35498623144','Ghiaia',NULL,NULL,NULL),(303,1,140,'2020-01-15','84630152772',NULL,'Blocco di cemento',NULL,NULL),(304,0.9,147,'2020-01-15','35498623144',NULL,'Blocco di cemento',NULL,NULL),(305,1.3,156,'2020-01-15','84630152772',NULL,'Mattone 2 fori',NULL,NULL),(306,1.5,11,'2020-01-15','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(307,4,5,'2020-01-15','41486886249','Sabbia',NULL,NULL,NULL),(308,1.1,112,'2020-01-15','58843462067',NULL,'Mattone in laterizio',NULL,NULL),(309,0.4,120,'2020-01-15','37468674251',NULL,NULL,'Pietra',NULL),(310,1,200,'2020-01-15','95910782700',NULL,'Alveolater',NULL,NULL),(311,1.1,300,'2020-01-15','54908173906',NULL,'Alveolater',NULL,NULL),(312,9,50,'2020-01-15','80231812734','Pannello',NULL,NULL,NULL),(313,1,46,'2020-01-15','47164159739',NULL,'Alveolater',NULL,NULL),(314,0.3,62,'2020-01-15','81512365057',NULL,NULL,'Pietra',NULL),(315,10,13,'2020-01-15','80231812734','Pannello Preformato',NULL,NULL,NULL),(316,1.2,100,'2020-01-15','35498623144',NULL,'Alveolater',NULL,NULL),(317,1.3,102,'2020-01-15','84630152772',NULL,'Alveolater',NULL,NULL),(318,1.2,102,'2020-01-15','35498623144',NULL,'Alveolater',NULL,NULL),(319,1.2,103,'2020-01-15','58843462067',NULL,'Alveolater',NULL,NULL),(320,1.22,20,'2020-01-15','35498623144','Lamiera',NULL,NULL,NULL),(321,1.1,100,'2020-01-15','84630152772',NULL,'Mattone semipieno',NULL,NULL),(322,0.1,6,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(323,0.2,5,'2019-09-05','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(324,0.1,6,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(325,0.15,2,'2019-09-05','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(326,0.5,4,'2019-09-05','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(327,0.1,8,'2019-09-05','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(328,0.2,9,'2019-09-05','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(329,0.1,10,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(330,0.2,11,'2019-09-05','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(331,0.1,2,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(332,0.5,3,'2019-09-05','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(333,0.1,1,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(334,0.2,2,'2019-09-05','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(335,0.1,3,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(336,0.2,6,'2019-09-05','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(337,0.1,8,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(338,0.15,9,'2019-09-05','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(339,0.5,4,'2019-09-05','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(340,0.1,5,'2019-09-05','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(341,0.2,2,'2019-09-05','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(342,0.22,3,'2019-09-05','54908173906','Materiale per installazione servizi',NULL,NULL,NULL),(343,0.3,6,'2019-09-05','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(344,0.3,8,'2019-09-05','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(345,0.1,7,'2019-09-05','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(346,0.3,9,'2019-09-05','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(347,0.3,5,'2019-09-05','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(348,0.1,6,'2019-09-05','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(349,0.3,9,'2019-09-05','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(350,0.1,8,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(351,0.2,5,'2019-09-05','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(352,0.1,6,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(353,0.5,3,'2019-09-05','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(354,0.1,2,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(355,0.2,4,'2019-09-05','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(356,0.1,5,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(357,0.5,6,'2019-09-05','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(358,0.1,9,'2019-09-05','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(359,0.2,6,'2019-09-05','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(360,0.2,5,'2019-09-05','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(361,0.1,3,'2019-09-05','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(362,0.15,5,'2019-09-05','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(363,0.5,8,'2019-09-05','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(364,4,6,'2018-10-01','37468674251','Sabbia',NULL,NULL,NULL),(365,0.9,200,'2018-10-01','35498623144',NULL,'Blocco di cemento',NULL,NULL),(366,0.35,100,'2018-10-01','84630152772',NULL,NULL,'Poster',NULL),(367,1.5,200,'2018-10-01','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(368,0.7,99,'2018-10-01','58843462067',NULL,NULL,'Grande Marble',NULL),(369,15,6,'2018-10-01','35498623144','Policarbonato',NULL,NULL,NULL),(370,1,100,'2018-10-01','84630152772',NULL,'Blocco di cemento',NULL,NULL),(371,15,6,'2018-10-01','35498623144','Policarbonato',NULL,NULL,NULL),(372,12,12,'2018-10-01','84630152772','Corda in Ferro',NULL,NULL,NULL),(373,1,135,'2018-10-01','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(374,0.7,100,'2018-10-01','41486886249',NULL,NULL,'Grande Marble',NULL),(375,1.2,120,'2018-10-01','58843462067',NULL,'Alveolater',NULL,NULL),(376,0.7,66,'2018-10-01','37468674251',NULL,NULL,'Grande Marble',NULL),(377,1.3,103,'2018-10-01','95910782700',NULL,'Mattone in laterizio',NULL,NULL),(378,6.3,44,'2018-10-01','54908173906',NULL,NULL,'Legno',NULL),(379,1,200,'2018-10-01','80231812734',NULL,'Mattone in terra cruda',NULL,NULL),(380,0.4,88,'2018-10-01','47164159739',NULL,NULL,'Cementum',NULL),(381,1,123,'2018-10-01','81512365057',NULL,'Alveolater',NULL,NULL),(382,0.4,109,'2018-10-01','80231812734',NULL,NULL,'Cementum',NULL),(383,1.1,111,'2018-10-01','47164159739',NULL,'Mattone semipieno',NULL,NULL),(384,0.7,45,'2018-10-01','81512365057',NULL,'Blocco di cemento',NULL,NULL),(385,0.8,150,'2018-10-01','47164159739',NULL,'Blocco di cemento',NULL,NULL),(386,8.5,6,'2018-10-01','35498623144','Pannello',NULL,NULL,NULL),(387,1,120,'2018-10-01','84630152772',NULL,'Blocco di cemento',NULL,NULL),(388,10,13,'2018-10-01','35498623144','Pannello Preformato',NULL,NULL,NULL),(389,0.9,100,'2018-10-01','58843462067',NULL,'Blocco di cemento',NULL,NULL),(390,1.5,106,'2018-10-01','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(391,1.3,89,'2018-10-01','84630152772',NULL,'Mattone 2 fori',NULL,NULL),(392,1.5,88,'2018-10-01','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(393,0.3,20,'2018-10-01','58843462067',NULL,NULL,'Pietra',NULL),(394,2,30,'2018-10-01','37468674251','Lamiera',NULL,NULL,NULL),(395,1.2,200,'2018-10-01','95910782700',NULL,'Mattone 2 fori',NULL,NULL),(396,0.3,56,'2018-10-01','84630152772',NULL,NULL,'Pietra',NULL),(397,0.9,100,'2018-10-01','35498623144',NULL,'Blocco di cemento',NULL,NULL),(398,0.4,69,'2018-10-01','41486886249',NULL,NULL,'Pietra',NULL),(399,0.9,156,'2018-10-01','58843462067',NULL,'Blocco di cemento',NULL,NULL),(400,1.2,120,'2018-10-01','37468674251',NULL,'Mattone 2 fori',NULL,NULL),(401,16,9,'2018-10-01','95910782700','Resina Indurente',NULL,NULL,NULL),(402,1.2,68,'2018-10-01','54908173906',NULL,'Mattone 2 fori',NULL,NULL),(403,1.2,100,'2018-10-01','80231812734',NULL,'Mattone 2 fori',NULL,NULL),(404,1,102,'2018-10-01','47164159739',NULL,'Mattone in terra cruda',NULL,NULL),(405,0.3,80,'2018-10-01','81512365057',NULL,NULL,'Pietra',NULL),(406,5,16,'2018-10-01','37468674251','Rete',NULL,NULL,NULL),(407,1.3,112,'2018-10-01','95910782700',NULL,'Mattone in laterizio',NULL,NULL),(408,0.6,33,'2018-10-01','54908173906',NULL,NULL,'Pietra',NULL),(409,10,15,'2018-10-01','80231812734','Perlite',NULL,NULL,NULL),(410,1,100,'2018-10-01','47164159739',NULL,'Mattone in terra cruda',NULL,NULL),(411,2.2,9,'2018-10-01','81512365057','Ghiaia',NULL,NULL,NULL),(412,1,100,'2018-10-01','47164159739',NULL,'Mattone in terra cruda',NULL,NULL),(413,1,103,'2018-10-01','35498623144',NULL,'Mattone in laterizio',NULL,NULL),(414,1.3,109,'2018-10-01','84630152772',NULL,'Alveolater',NULL,NULL),(415,1,105,'2018-10-01','35498623144',NULL,'Alveolater',NULL,NULL),(416,4,10,'2018-10-01','58843462067','Sabbia',NULL,NULL,NULL),(417,1,106,'2018-10-01','35498623144',NULL,'Alveolater',NULL,NULL),(418,1.3,106,'2018-10-01','84630152772',NULL,'Alveolater',NULL,NULL),(419,1,105,'2018-10-01','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(420,9,55,'2018-10-01','58843462067','Pannello',NULL,NULL,NULL),(421,1,105,'2018-10-01','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(422,9.5,6,'2018-10-01','84630152772','Pannello Preformato',NULL,NULL,NULL),(423,1,120,'2018-10-01','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(424,0.9,129,'2018-10-01','41486886249',NULL,'Mattone in terra cruda',NULL,NULL),(425,16,12,'2018-10-01','58843462067','Policarbonato',NULL,NULL,NULL),(426,1,122,'2018-10-01','37468674251',NULL,'Mattone in terra cruda',NULL,NULL),(427,1,111,'2018-10-01','95910782700',NULL,'Mattone in terra cruda',NULL,NULL),(428,15,19,'2018-10-01','54908173906','Resina Indurente',NULL,NULL,NULL),(429,1,200,'2018-10-01','80231812734',NULL,'Mattone in laterizio',NULL,NULL),(430,1,222,'2018-10-01','47164159739',NULL,'Mattone in terra cruda',NULL,NULL),(431,6,12,'2018-10-01','81512365057','Rete',NULL,NULL,NULL),(432,1,122,'2018-10-01','80231812734',NULL,'Mattone in terra cruda',NULL,NULL),(433,10.5,15,'2018-10-01','35498623144','Corda in Ferro',NULL,NULL,NULL),(434,1,139,'2018-10-01','84630152772',NULL,'Mattone in laterizio',NULL,NULL),(435,9,6,'2018-10-01','35498623144','Perlite',NULL,NULL,NULL),(436,1.2,88,'2018-10-01','58843462067',NULL,'Alveolater',NULL,NULL),(437,2.27,8,'2018-10-01','35498623144','Ghiaia',NULL,NULL,NULL),(438,1.3,144,'2018-10-01','84630152772',NULL,'Alveolater',NULL,NULL),(439,1,78,'2018-10-01','35498623144',NULL,'Alveolater',NULL,NULL),(440,1.3,89,'2018-10-01','84630152772',NULL,'Alveolater',NULL,NULL),(441,1,98,'2018-10-01','35498623144',NULL,'Alveolater',NULL,NULL),(442,4,6,'2018-10-01','41486886249','Sabbia',NULL,NULL,NULL),(443,1.2,99,'2018-10-01','58843462067',NULL,'Alveolater',NULL,NULL),(444,1.1,88,'2018-10-01','37468674251',NULL,'Alveolater',NULL,NULL),(445,0.2,6,'2018-07-10','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(446,0.1,5,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(447,0.2,4,'2018-07-10','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(448,0.1,32,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(449,0.5,55,'2018-07-10','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(450,0.1,1,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(451,0.2,2,'2018-07-10','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(452,0.1,3,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(453,0.1,4,'2018-07-10','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(454,0.1,5,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(455,0.15,6,'2018-07-10','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(456,0.5,9,'2018-07-10','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(457,0.1,8,'2018-07-10','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(458,0.2,18,'2018-07-10','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(459,0.22,16,'2018-07-10','54908173906','Materiale per installazione servizi',NULL,NULL,NULL),(460,0.3,12,'2018-07-10','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(461,0.3,15,'2018-07-10','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(462,0.1,15,'2018-07-10','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(463,0.3,14,'2018-07-10','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(464,0.3,13,'2018-07-10','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(465,0.1,11,'2018-07-10','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(466,0.3,10,'2018-07-10','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(467,0.1,2,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(468,0.2,35,'2018-07-10','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(469,0.1,5,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(470,0.5,6,'2018-07-10','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(471,0.1,4,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(472,0.2,5,'2018-07-10','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(473,0.1,5,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(474,0.5,6,'2018-07-10','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(475,0.1,9,'2018-07-10','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(476,0.2,8,'2018-07-10','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(477,0.2,5,'2018-07-10','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(478,0.1,6,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(479,0.15,2,'2018-07-10','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(480,0.5,8,'2018-07-10','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(481,0.1,5,'2018-07-10','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(482,0.1,6,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(483,0.2,5,'2018-07-10','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(484,0.1,5,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(485,0.5,6,'2018-07-10','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(486,0.1,9,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(487,0.2,54,'2018-07-10','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(488,0.1,1,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(489,0.2,6,'2018-07-10','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(490,0.1,8,'2018-07-10','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(491,0.15,5,'2018-07-10','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(492,0.5,52,'2018-07-10','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(493,4.5,5,'2019-12-27','37468674251','Vernice',NULL,NULL,NULL),(494,6,2,'2019-12-27','95910782700','Vernice',NULL,NULL,NULL),(495,30,1,'2019-12-27','54908173906',NULL,NULL,NULL,'Beton Cire'),(496,11,2,'2019-12-27','80231812734','Vernice',NULL,NULL,NULL),(497,24,1,'2019-12-27','47164159739',NULL,NULL,NULL,'Granol'),(498,5,2,'2019-12-27','81512365057','Vernice',NULL,NULL,NULL),(499,22,2,'2019-12-27','80231812734',NULL,NULL,NULL,'Intonaco argilloso'),(500,9,1,'2019-12-27','47164159739','Vernice',NULL,NULL,NULL),(501,20,2,'2019-12-27','81512365057',NULL,NULL,NULL,'Intonaco civile'),(502,9,2,'2019-12-27','47164159739','Vernice',NULL,NULL,NULL),(503,7,1,'2019-12-27','35498623144','Vernice',NULL,NULL,NULL),(504,4,2,'2019-12-27','84630152772','Vernice',NULL,NULL,NULL),(505,40,3,'2019-12-27','35498623144',NULL,NULL,NULL,'Spachtelputz'),(506,8,2,'2019-12-27','58843462067','Vernice',NULL,NULL,NULL),(507,30,1,'2019-12-27','35498623144',NULL,NULL,NULL,'Beton Cire'),(508,4,2,'2019-12-27','84630152772','Vernice',NULL,NULL,NULL),(509,20,4,'2019-12-27','35498623144',NULL,NULL,NULL,'Intonaco civile'),(510,8,2,'2019-12-27','58843462067','Vernice',NULL,NULL,NULL),(511,4.5,3,'2019-12-27','37468674251','Vernice',NULL,NULL,NULL),(512,6,6,'2019-12-27','95910782700','Vernice',NULL,NULL,NULL),(513,40,4,'2019-12-27','84630152772',NULL,NULL,NULL,'Spachtelputz'),(514,7,2,'2019-12-27','35498623144','Vernice',NULL,NULL,NULL),(515,35,3,'2019-12-27','41486886249',NULL,NULL,NULL,'Beton Cire'),(516,8,1,'2019-12-27','58843462067','Vernice',NULL,NULL,NULL),(517,26,5,'2019-12-27','37468674251',NULL,NULL,NULL,'Granol'),(518,6,3,'2019-12-27','95910782700','Vernice',NULL,NULL,NULL),(519,10,2,'2019-12-27','54908173906','Vernice',NULL,NULL,NULL),(520,22,1,'2019-12-27','80231812734',NULL,NULL,NULL,'Intonaco argilloso'),(521,9,4,'2019-12-27','47164159739','Vernice',NULL,NULL,NULL),(522,21,2,'2019-12-27','81512365057',NULL,NULL,NULL,'Intonaco civile'),(523,4.5,3,'2019-12-27','37468674251','Vernice',NULL,NULL,NULL),(524,20,1,'2019-12-27','95910782700',NULL,NULL,NULL,'Intonaco civile'),(525,10,2,'2019-12-27','54908173906','Vernice',NULL,NULL,NULL),(526,40,3,'2019-12-27','80231812734',NULL,NULL,NULL,'Spachtelputz'),(527,9,2,'2019-12-27','47164159739','Vernice',NULL,NULL,NULL),(528,5,1,'2019-12-27','81512365057','Vernice',NULL,NULL,NULL),(529,32,2,'2019-12-27','47164159739',NULL,NULL,NULL,'Beton Cire'),(530,7,3,'2019-12-27','35498623144','Vernice',NULL,NULL,NULL),(531,26,4,'2019-12-27','84630152772',NULL,NULL,NULL,'Granol'),(532,7,2,'2019-12-27','35498623144','Vernice',NULL,NULL,NULL),(533,22,3,'2019-12-27','58843462067',NULL,NULL,NULL,'Intonaco argilloso'),(534,7,2,'2019-12-27','35498623144','Vernice',NULL,NULL,NULL),(535,40,4,'2019-12-27','41486886249',NULL,NULL,NULL,'MP2'),(536,8,2,'2019-12-27','58843462067','Vernice',NULL,NULL,NULL),(537,4.5,3,'2019-12-27','37468674251','Vernice',NULL,NULL,NULL),(538,50,2,'2019-12-27','95910782700',NULL,NULL,NULL,'KP3'),(539,10,5,'2019-12-27','54908173906','Vernice',NULL,NULL,NULL),(540,45,2,'2019-12-27','80231812734',NULL,NULL,NULL,'Rofix'),(541,9,3,'2019-12-27','47164159739','Vernice',NULL,NULL,NULL),(542,26,1,'2019-12-27','81512365057',NULL,NULL,NULL,'Granol'),(543,11,2,'2019-12-27','80231812734','Vernice',NULL,NULL,NULL),(544,20,3,'2019-12-27','47164159739',NULL,NULL,NULL,'Intonaco civile'),(545,5,2,'2019-12-27','81512365057','Vernice',NULL,NULL,NULL),(546,9,3,'2019-12-27','47164159739','Vernice',NULL,NULL,NULL),(547,40,2,'2019-12-27','35498623144',NULL,NULL,NULL,'Spachtelputz'),(548,4,3,'2019-12-27','84630152772','Vernice',NULL,NULL,NULL),(549,30,2,'2019-12-27','35498623144',NULL,NULL,NULL,'Beton Cire'),(550,8,3,'2019-12-27','58843462067','Vernice',NULL,NULL,NULL),(551,25,2,'2019-12-27','35498623144',NULL,NULL,NULL,'Granol'),(552,4,3,'2019-12-27','84630152772','Vernice',NULL,NULL,NULL),(553,30,2,'2019-12-27','35498623144',NULL,NULL,NULL,'Beton Cire'),(554,8,3,'2019-12-27','58843462067','Vernice',NULL,NULL,NULL),(555,4.5,2,'2019-12-27','37468674251','Vernice',NULL,NULL,NULL),(556,24,3,'2019-12-27','95910782700',NULL,NULL,NULL,'Granol'),(557,4,2,'2019-12-27','84630152772','Vernice',NULL,NULL,NULL),(558,7,3,'2019-12-27','35498623144','Vernice',NULL,NULL,NULL),(559,60,2,'2019-12-27','41486886249',NULL,NULL,NULL,'Spachtelputz'),(560,8,3,'2019-12-27','58843462067','Vernice',NULL,NULL,NULL),(561,30,2,'2019-12-27','37468674251',NULL,NULL,NULL,'Beton Cire'),(562,1.2,200,'2021-09-20','95910782700',NULL,'Blocco di cemento',NULL,NULL),(563,0.3,69,'2022-04-09','54908173906',NULL,NULL,'Poster',NULL),(564,1.3,96,'2022-04-09','80231812734',NULL,'Mattone 2 fori',NULL,NULL),(565,0.8,100,'2022-04-09','47164159739',NULL,'Blocco di cemento',NULL,NULL),(566,6,15,'2022-04-09','81512365057','Sabbia',NULL,NULL,NULL),(567,1.2,150,'2022-04-09','37468674251',NULL,'Blocco di cemento',NULL,NULL),(568,1.3,150,'2022-04-09','95910782700',NULL,'Mattone 2 fori',NULL,NULL),(569,1,122,'2022-04-09','54908173906',NULL,'Alveolater',NULL,NULL),(570,0.3,23,'2022-10-04','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(571,0.3,21,'2022-10-04','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(572,0.1,2,'2022-10-04','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(573,0.3,1,'2022-10-04','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(574,0.1,45,'2022-10-04','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(575,9.5,12,'2020-08-04','84630152772','Pannello Preformato',NULL,NULL,NULL),(576,0.9,123,'2020-08-04','35498623144',NULL,'Blocco di cemento',NULL,NULL),(577,0.3,120,'2020-08-04','58843462067',NULL,NULL,'Poster',NULL),(578,14,12,'2020-08-04','35498623144','Policarbonato',NULL,NULL,NULL),(579,1,123,'2020-08-04','84630152772',NULL,'Mattone in terra cruda',NULL,NULL),(580,0.3,99,'2020-08-04','35498623144',NULL,NULL,'Poster',NULL),(581,9,5,'2020-08-04','58843462067','Pannello',NULL,NULL,NULL),(582,1.1,120,'2020-08-04','35498623144',NULL,'Mattone semipieno',NULL,NULL),(583,1,123,'2020-08-04','84630152772',NULL,'Blocco di cemento',NULL,NULL),(584,8.5,6,'2020-08-04','35498623144','Pannello',NULL,NULL,NULL),(585,1,120,'2020-08-04','41486886249',NULL,'Blocco di cemento',NULL,NULL),(586,9,12,'2020-08-04','58843462067','Pannello Preformato',NULL,NULL,NULL),(587,0.7,123,'2020-08-04','37468674251',NULL,'Blocco di cemento',NULL,NULL),(588,0.5,12,'2020-08-04','95910782700',NULL,NULL,'Pietra',NULL),(589,0.7,123,'2020-08-04','54908173906',NULL,'Blocco di cemento',NULL,NULL),(590,0.9,321,'2020-08-04','80231812734',NULL,'Mattone in terra cruda',NULL,NULL),(591,0.9,222,'2020-08-04','47164159739',NULL,'Mattone in terra cruda',NULL,NULL),(592,15,1,'2020-08-04','81512365057','Resina Indurente',NULL,NULL,NULL),(593,1,120,'2020-08-04','80231812734',NULL,'Mattone in laterizio',NULL,NULL),(594,1,210,'2020-08-04','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(595,1,125,'2020-08-04','84630152772',NULL,'Mattone in terra cruda',NULL,NULL),(596,0.1,12,'2022-11-03','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(597,0.5,11,'2022-11-03','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(598,0.1,10,'2022-11-03','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(599,0.2,9,'2022-11-03','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(600,0.1,8,'2022-11-03','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(601,0.2,7,'2022-11-03','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(602,0.1,5,'2022-11-03','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(603,0.15,6,'2022-11-03','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(604,0.5,7,'2022-11-03','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(605,0.1,8,'2022-11-03','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(606,5,6,'2020-10-07','95910782700','Rete',NULL,NULL,NULL),(607,1,120,'2020-10-07','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(608,1.3,123,'2020-10-07','84630152772',NULL,'Alveolater',NULL,NULL),(609,10,12,'2020-10-07','35498623144','Pannello Preformato',NULL,NULL,NULL),(610,1.2,56,'2020-10-07','58843462067',NULL,'Alveolater',NULL,NULL),(611,15,12,'2020-10-07','35498623144','Policarbonato',NULL,NULL,NULL),(612,1,100,'2020-10-07','84630152772',NULL,'Blocco di cemento',NULL,NULL),(613,15,12,'2020-10-07','35498623144','Corda in Ferro',NULL,NULL,NULL),(614,1.3,123,'2020-10-07','84630152772',NULL,'Mattone 2 fori',NULL,NULL),(615,1.5,321,'2020-10-07','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(616,7,5,'2021-09-05','41486886249','Rete',NULL,NULL,NULL),(617,1.1,123,'2021-09-05','58843462067',NULL,'Mattone in laterizio',NULL,NULL),(618,1,230,'2021-09-05','37468674251',NULL,'Alveolater',NULL,NULL),(619,10,55,'2021-09-05','95910782700','Pannello Preformato',NULL,NULL,NULL),(620,0.7,120,'2021-09-05','54908173906',NULL,'Blocco di cemento',NULL,NULL),(621,16,2,'2021-09-05','80231812734','Policarbonato',NULL,NULL,NULL),(622,1,200,'2021-09-05','47164159739',NULL,'Alveolater',NULL,NULL),(623,12,6,'2021-09-05','81512365057','Corda in Ferro',NULL,NULL,NULL),(624,0.8,120,'2021-09-05','80231812734',NULL,'Blocco di cemento',NULL,NULL),(625,1.4,133,'2021-09-05','47164159739',NULL,'Mattone 2 fori',NULL,NULL),(626,1.3,160,'2021-09-05','81512365057',NULL,'Mattone 2 fori',NULL,NULL),(627,10.5,6,'2021-09-05','47164159739','Corda in Ferro',NULL,NULL,NULL),(628,1,200,'2021-09-05','35498623144',NULL,'Alveolater',NULL,NULL),(629,0.69,99,'2021-09-05','84630152772',NULL,NULL,'Memoria',NULL),(630,1.1,120,'2021-09-05','35498623144',NULL,'Alveolater',NULL,NULL),(631,0.69,100,'2021-09-05','58843462067',NULL,NULL,'Memoria',NULL),(632,0.9,123,'2021-09-05','35498623144',NULL,'Blocco di cemento',NULL,NULL),(633,0.69,60,'2021-09-05','84630152772',NULL,NULL,'Memoria',NULL),(634,1.1,100,'2021-09-05','35498623144',NULL,'Alveolater',NULL,NULL),(635,0.69,72,'2021-09-05','58843462067',NULL,NULL,'Memoria',NULL),(636,10,9,'2021-09-05','37468674251','Perlite',NULL,NULL,NULL),(637,0.7,120,'2021-09-05','95910782700',NULL,'Blocco di cemento',NULL,NULL),(638,0.69,60,'2021-09-05','84630152772',NULL,NULL,'Memoria',NULL),(639,5,9,'2021-09-05','35498623144','Sabbia',NULL,NULL,NULL),(640,1.3,120,'2021-09-05','41486886249',NULL,'Mattone 2 fori',NULL,NULL),(641,0.5,100,'2021-09-05','58843462067',NULL,NULL,'Mystone travertino',NULL),(642,9,19,'2021-09-05','37468674251','Pannello',NULL,NULL,NULL),(643,1.5,200,'2021-09-05','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(644,0.5,36,'2021-09-05','84630152772',NULL,NULL,'Mystone travertino',NULL),(645,9,12,'2020-07-02','35498623144','Perlite',NULL,NULL,NULL),(646,1.2,123,'2020-07-02','58843462067',NULL,'Alveolater',NULL,NULL),(647,2,60,'2020-07-02','35498623144',NULL,NULL,'Vero',NULL),(648,5.5,6,'2020-07-02','84630152772','Sabbia',NULL,NULL,NULL),(649,1.1,120,'2020-07-02','35498623144',NULL,'Alveolater',NULL,NULL),(650,2,60,'2020-07-02','84630152772',NULL,NULL,'Vero',NULL),(651,8.5,12,'2020-07-02','35498623144','Pannello',NULL,NULL,NULL),(652,1,200,'2020-07-02','41486886249',NULL,'Blocco di cemento',NULL,NULL),(653,2,56,'2020-07-02','58843462067',NULL,NULL,'Vero',NULL),(654,15,6,'2021-03-29','37468674251','Corda in Ferro',NULL,NULL,NULL),(655,1,180,'2021-03-29','95910782700',NULL,'Mattone in laterizio',NULL,NULL),(656,2.2,6,'2021-03-29','54908173906','Ghiaia',NULL,NULL,NULL),(657,1,120,'2021-03-29','80231812734',NULL,'Alveolater',NULL,NULL),(658,1,133,'2021-03-29','47164159739',NULL,'Alveolater',NULL,NULL),(659,1.5,140,'2021-03-29','81512365057',NULL,'Alveolater',NULL,NULL),(660,1,200,'2021-03-29','80231812734',NULL,'Alveolater',NULL,NULL),(661,1,203,'2021-03-29','47164159739',NULL,'Alveolater',NULL,NULL),(662,1.5,203,'2021-03-29','81512365057',NULL,'Alveolater',NULL,NULL),(663,1.1,205,'2021-03-29','47164159739',NULL,'Mattone semipieno',NULL,NULL),(664,8.5,2,'2021-03-29','35498623144','Pannello',NULL,NULL,NULL),(665,1,99,'2021-03-29','84630152772',NULL,'Blocco di cemento',NULL,NULL),(666,10,5,'2021-03-29','35498623144','Pannello Preformato',NULL,NULL,NULL),(667,0.9,99,'2021-03-29','58843462067',NULL,'Blocco di cemento',NULL,NULL),(668,0.9,98,'2021-03-29','35498623144',NULL,'Blocco di cemento',NULL,NULL),(669,9.5,5,'2021-03-29','84630152772','Pannello Preformato',NULL,NULL,NULL),(670,0.9,99,'2021-03-29','35498623144',NULL,'Blocco di cemento',NULL,NULL),(671,1.3,100,'2021-03-29','58843462067',NULL,'Mattone 2 fori',NULL,NULL),(672,1.3,103,'2021-03-29','37468674251',NULL,'Mattone 2 fori',NULL,NULL),(673,14,6,'2021-03-29','95910782700','Policarbonato',NULL,NULL,NULL),(674,1.3,102,'2021-03-29','84630152772',NULL,'Mattone 2 fori',NULL,NULL),(675,0.1,5,'2021-03-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(676,0.15,6,'2021-03-25','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(677,0.5,5,'2021-03-25','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(678,0.1,6,'2021-03-25','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(679,0.2,9,'2021-03-25','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(680,0.22,8,'2021-03-25','54908173906','Materiale per installazione servizi',NULL,NULL,NULL),(681,0.3,9,'2021-03-25','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(682,0.3,6,'2021-03-25','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(683,0.1,5,'2021-03-25','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(684,0.1,8,'2021-03-25','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(685,0.2,9,'2021-03-25','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(686,0.3,6,'2021-03-25','54908173906','Materiale per installazione servizi',NULL,NULL,NULL),(687,0.3,3,'2021-03-25','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(688,0.3,2,'2021-03-25','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(689,0.1,1,'2021-03-25','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(690,0.3,2,'2021-03-25','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(691,0.1,12,'2021-03-25','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(692,0.2,13,'2021-03-25','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(693,7,2,'2022-07-14','35498623144','Vernice',NULL,NULL,NULL),(694,8,1,'2022-07-14','58843462067','Vernice',NULL,NULL,NULL),(695,31,2,'2022-07-14','35498623144',NULL,NULL,NULL,'Beton Cire'),(696,4,3,'2022-07-14','84630152772','Vernice',NULL,NULL,NULL),(697,25,1,'2022-07-14','35498623144',NULL,NULL,NULL,'Granol'),(698,8,3,'2022-07-14','58843462067','Vernice',NULL,NULL,NULL),(699,21,6,'2022-07-14','35498623144',NULL,NULL,NULL,'Intonaco civile'),(700,4,3,'2022-07-14','84630152772','Vernice',NULL,NULL,NULL),(701,40,2,'2022-07-14','35498623144',NULL,NULL,NULL,'Spachtelputz'),(702,8,3,'2022-07-14','58843462067','Vernice',NULL,NULL,NULL),(703,7,2,'2022-07-14','35498623144','Vernice',NULL,NULL,NULL),(704,31,3,'2022-07-14','84630152772',NULL,NULL,NULL,'Beton Cire'),(705,7,2,'2022-07-14','35498623144','Vernice',NULL,NULL,NULL),(706,26,3,'2022-07-14','84630152772',NULL,NULL,NULL,'Granol'),(707,7,2,'2022-07-14','35498623144','Vernice',NULL,NULL,NULL),(708,20,3,'2022-07-14','41486886249',NULL,NULL,NULL,'Intonaco civile'),(709,8,1,'2022-07-14','58843462067','Vernice',NULL,NULL,NULL),(710,40,3,'2022-07-14','37468674251',NULL,NULL,NULL,'Spachtelputz'),(711,6,2,'2022-07-14','95910782700','Vernice',NULL,NULL,NULL),(712,10,3,'2022-07-14','54908173906','Vernice',NULL,NULL,NULL),(713,30,5,'2022-07-14','80231812734',NULL,NULL,NULL,'Beton Cire'),(714,9,2,'2022-07-14','47164159739','Vernice',NULL,NULL,NULL),(715,25,3,'2022-07-14','81512365057',NULL,NULL,NULL,'Granol'),(716,11,2,'2022-07-14','80231812734','Vernice',NULL,NULL,NULL),(717,21,5,'2022-07-14','47164159739',NULL,NULL,NULL,'Intonaco civile'),(718,5,2,'2022-07-14','81512365057','Vernice',NULL,NULL,NULL),(719,40,3,'2022-07-14','47164159739',NULL,NULL,NULL,'Spachtelputz'),(720,16,6,'2021-09-02','35498623144','Resina Indurente',NULL,NULL,NULL),(721,1,200,'2021-09-02','84630152772',NULL,'Mattone 2 fori',NULL,NULL),(722,6.3,56,'2021-09-02','35498623144',NULL,NULL,'Legno',NULL),(723,2.2,5,'2021-09-02','58843462067','Ghiaia',NULL,NULL,NULL),(724,1.3,120,'2021-09-02','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(725,6.4,65,'2021-09-02','84630152772',NULL,NULL,'Legno',NULL),(726,1.1,100,'2021-09-02','35498623144',NULL,'Alveolater',NULL,NULL),(727,2,99,'2021-09-02','58843462067',NULL,NULL,'Vero',NULL),(728,9,6,'2021-09-02','37468674251','Pannello Preformato',NULL,NULL,NULL),(729,0.9,132,'2021-09-02','95910782700',NULL,'Blocco di cemento',NULL,NULL),(730,0.7,120,'2021-09-02','84630152772',NULL,NULL,'Grande Marble',NULL),(731,1.2,100,'2021-09-02','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(732,0.7,100,'2021-09-02','41486886249',NULL,NULL,'Grande Marble',NULL),(733,1.3,102,'2021-09-02','58843462067',NULL,'Mattone 2 fori',NULL,NULL),(734,6.4,102,'2021-09-02','37468674251',NULL,NULL,'Legno',NULL),(735,1,102,'2021-09-02','95910782700',NULL,'Mattone in terra cruda',NULL,NULL),(736,0.6,102,'2021-09-02','54908173906',NULL,NULL,'Grande Marble',NULL),(737,1,101,'2021-09-02','80231812734',NULL,'Alveolater',NULL,NULL),(738,0.7,100,'2021-09-02','47164159739',NULL,NULL,'Grande Marble',NULL),(739,9,6,'2021-09-02','81512365057','Pannello',NULL,NULL,NULL),(740,0.9,102,'2021-09-02','37468674251',NULL,'Blocco di cemento',NULL,NULL),(741,0.3,100,'2021-09-02','95910782700',NULL,NULL,'Cementum',NULL),(742,1.2,69,'2022-08-10','54908173906',NULL,'Mattone 2 fori',NULL,NULL),(743,0.8,200,'2022-08-10','80231812734',NULL,'Blocco di cemento',NULL,NULL),(744,0.8,300,'2022-08-10','47164159739',NULL,'Blocco di cemento',NULL,NULL),(745,7,16,'2022-08-10','81512365057','Rete',NULL,NULL,NULL),(746,0.8,86,'2022-08-10','47164159739',NULL,'Blocco di cemento',NULL,NULL),(747,12,15,'2022-08-10','35498623144','Corda in Ferro',NULL,NULL,NULL),(748,1.3,200,'2022-08-10','84630152772',NULL,'Mattone 2 fori',NULL,NULL),(749,10,6,'2022-08-10','35498623144','Perlite',NULL,NULL,NULL),(750,1.3,120,'2022-08-10','58843462067',NULL,'Mattone 2 fori',NULL,NULL),(751,1,123,'2022-08-10','35498623144',NULL,'Mattone in laterizio',NULL,NULL),(752,1.3,125,'2022-08-10','84630152772',NULL,'Alveolater',NULL,NULL),(753,1.1,124,'2022-08-10','35498623144',NULL,'Alveolater',NULL,NULL),(754,1.1,126,'2022-08-10','35498623144',NULL,'Alveolater',NULL,NULL),(755,0.3,66,'2022-08-10','84630152772',NULL,NULL,'Pietra',NULL),(756,6,9,'2022-08-10','35498623144','Sabbia',NULL,NULL,NULL),(757,1.2,123,'2022-08-10','58843462067',NULL,'Alveolater',NULL,NULL),(758,1.1,125,'2022-08-10','35498623144',NULL,'Alveolater',NULL,NULL),(759,0.3,9,'2022-08-10','84630152772',NULL,NULL,'Pietra',NULL),(760,8.5,12,'2022-08-10','35498623144','Pannello',NULL,NULL,NULL),(761,1.3,125,'2022-08-10','84630152772',NULL,'Alveolater',NULL,NULL),(762,9,9,'2022-08-10','35498623144','Pannello Preformato',NULL,NULL,NULL),(763,0.85,254,'2022-08-10','41486886249',NULL,'Alveolater',NULL,NULL),(764,1.1,256,'2022-08-10','58843462067',NULL,'Mattone semipieno',NULL,NULL),(765,8.5,6,'2022-08-10','35498623144','Pannello',NULL,NULL,NULL),(766,1,253,'2022-08-10','84630152772',NULL,'Blocco di cemento',NULL,NULL),(767,0.9,251,'2022-08-10','35498623144',NULL,'Blocco di cemento',NULL,NULL),(768,0.9,123,'2022-08-10','58843462067',NULL,'Blocco di cemento',NULL,NULL),(769,14,9,'2022-08-10','35498623144','Policarbonato',NULL,NULL,NULL),(770,1,125,'2022-08-10','84630152772',NULL,'Blocco di cemento',NULL,NULL),(771,1.5,125,'2022-08-10','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(772,16,6,'2022-08-10','84630152772','Resina Indurente',NULL,NULL,NULL),(773,1.5,123,'2022-08-10','35498623144',NULL,'Mattone 2 fori',NULL,NULL),(774,1.3,123,'2022-08-10','41486886249',NULL,'Mattone 2 fori',NULL,NULL),(775,4.5,12,'2022-08-10','58843462067','Rete',NULL,NULL,NULL),(776,1.2,144,'2022-08-10','37468674251',NULL,'Mattone 2 fori',NULL,NULL),(777,15,14,'2022-08-10','95910782700','Corda in Ferro',NULL,NULL,NULL),(778,0.7,147,'2022-08-10','54908173906',NULL,'Blocco di cemento',NULL,NULL),(779,9,8,'2022-08-10','80231812734','Perlite',NULL,NULL,NULL),(780,0.8,148,'2022-08-10','47164159739',NULL,'Blocco di cemento',NULL,NULL),(781,2.2,6,'2022-08-10','81512365057','Ghiaia',NULL,NULL,NULL),(782,0.8,148,'2022-08-10','80231812734',NULL,'Blocco di cemento',NULL,NULL),(783,1.4,149,'2022-08-10','47164159739',NULL,'Mattone 2 fori',NULL,NULL),(784,1.2,146,'2022-08-10','81512365057',NULL,'Mattone 2 fori',NULL,NULL),(785,1,89,'2022-08-10','47164159739',NULL,'Mattone in terra cruda',NULL,NULL),(786,5.5,15,'2022-08-10','35498623144','Sabbia',NULL,NULL,NULL),(787,1.3,89,'2022-08-10','84630152772',NULL,'Mattone in laterizio',NULL,NULL),(788,1,99,'2022-08-10','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(789,9,9,'2022-08-10','58843462067','Pannello',NULL,NULL,NULL),(790,1,90,'2022-08-10','35498623144',NULL,'Mattone in terra cruda',NULL,NULL),(791,10,9,'2022-08-10','84630152772','Pannello Preformato',NULL,NULL,NULL),(792,1,120,'2022-08-10','35498623144',NULL,'Mattone in laterizio',NULL,NULL),(793,1.3,123,'2022-08-10','84630152772',NULL,'Alveolater',NULL,NULL),(794,6,9,'2022-08-10','35498623144','Sabbia',NULL,NULL,NULL),(795,0.85,120,'2022-08-10','41486886249',NULL,'Alveolater',NULL,NULL),(796,1.2,190,'2022-08-10','58843462067',NULL,'Alveolater',NULL,NULL),(797,9,12,'2022-08-10','37468674251','Pannello',NULL,NULL,NULL),(798,1,120,'2022-08-10','95910782700',NULL,'Alveolater',NULL,NULL),(799,1,120,'2022-08-10','54908173906',NULL,'Alveolater',NULL,NULL),(800,6,6,'2022-08-10','80231812734','Sabbia',NULL,NULL,NULL),(801,1,120,'2022-08-10','47164159739',NULL,'Alveolater',NULL,NULL),(802,1.5,120,'2022-08-10','81512365057',NULL,'Alveolater',NULL,NULL),(803,1.1,120,'2022-08-10','80231812734',NULL,'Mattone semipieno',NULL,NULL),(804,0.9,123,'2022-08-10','35498623144',NULL,'Blocco di cemento',NULL,NULL),(805,0.3,56,'2022-08-10','84630152772',NULL,NULL,'Pietra',NULL),(806,6,12,'2022-08-10','35498623144','Sabbia',NULL,NULL,NULL),(807,0.9,120,'2022-08-10','58843462067',NULL,'Blocco di cemento',NULL,NULL),(808,0.4,69,'2022-08-10','35498623144',NULL,NULL,'Pietra',NULL),(809,1,96,'2022-08-10','84630152772',NULL,'Blocco di cemento',NULL,NULL),(810,0.4,30,'2022-08-10','35498623144',NULL,NULL,'Pietra',NULL),(811,1,100,'2022-08-10','84630152772',NULL,'Blocco di cemento',NULL,NULL),(812,0.4,99,'2022-08-10','35498623144',NULL,NULL,'Pietra',NULL),(813,0.15,5,'2022-08-09','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(814,0.5,6,'2022-08-09','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(815,0.1,5,'2022-08-09','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(816,0.2,6,'2022-08-09','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(817,0.1,5,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(818,0.2,6,'2022-08-09','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(819,0.1,5,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(820,0.5,6,'2022-08-09','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(821,0.1,56,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(822,0.2,4,'2022-08-09','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(823,0.1,2,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(824,0.2,3,'2022-08-09','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(825,0.2,5,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(826,0.15,3,'2022-08-09','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(827,0.5,6,'2022-08-09','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(828,0.1,5,'2022-08-09','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(829,0.2,2,'2022-08-09','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(830,0.22,5,'2022-08-09','54908173906','Materiale per installazione servizi',NULL,NULL,NULL),(831,0.3,6,'2022-08-09','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(832,0.3,2,'2022-08-09','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(833,0.1,5,'2022-08-09','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(834,0.3,6,'2022-08-09','80231812734','Materiale per installazione servizi',NULL,NULL,NULL),(835,0.3,2,'2022-08-09','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(836,0.1,5,'2022-08-09','81512365057','Materiale per installazione servizi',NULL,NULL,NULL),(837,0.3,5,'2022-08-09','47164159739','Materiale per installazione servizi',NULL,NULL,NULL),(838,0.1,5,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(839,0.2,6,'2022-08-09','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(840,0.1,2,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(841,0.5,6,'2022-08-09','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(842,0.2,2,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(843,0.2,6,'2022-08-09','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(844,0.1,2,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(845,0.5,6,'2022-08-09','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(846,0.1,2,'2022-08-09','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(847,0.2,5,'2022-08-09','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(848,0.2,6,'2022-08-09','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(849,0.1,2,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(850,0.15,9,'2022-08-09','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(851,0.5,8,'2022-08-09','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(852,0.1,7,'2022-08-09','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(853,0.1,62,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(854,0.2,26,'2022-08-09','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(855,0.1,2,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(856,0.5,6,'2022-08-09','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(857,0.1,2,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(858,0.2,6,'2022-08-09','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(859,0.1,2,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(860,0.2,6,'2022-08-09','84630152772','Materiale per installazione servizi',NULL,NULL,NULL),(861,0.1,2,'2022-08-09','35498623144','Materiale per installazione servizi',NULL,NULL,NULL),(862,0.15,2,'2022-08-09','41486886249','Materiale per installazione servizi',NULL,NULL,NULL),(863,0.5,5,'2022-08-09','58843462067','Materiale per installazione servizi',NULL,NULL,NULL),(864,0.1,2,'2022-08-09','37468674251','Materiale per installazione servizi',NULL,NULL,NULL),(865,0.2,5,'2022-08-09','95910782700','Materiale per installazione servizi',NULL,NULL,NULL),(866,0.22,2,'2022-08-09','54908173906','Materiale per installazione servizi',NULL,NULL,NULL),(867,11,2,'2022-08-13','80231812734','Vernice',NULL,NULL,NULL),(868,9,1,'2022-08-13','47164159739','Vernice',NULL,NULL,NULL),(869,40,2,'2022-08-13','81512365057',NULL,NULL,NULL,'Spachtelputz'),(870,11,2,'2022-08-13','80231812734','Vernice',NULL,NULL,NULL),(871,32,3,'2022-08-13','47164159739',NULL,NULL,NULL,'Beton Cire'),(872,5,2,'2022-08-13','81512365057','Vernice',NULL,NULL,NULL),(873,32,1,'2022-08-13','47164159739',NULL,NULL,NULL,'Beton Cire'),(874,7,3,'2022-08-13','35498623144','Vernice',NULL,NULL,NULL),(875,25,2,'2022-08-13','84630152772',NULL,NULL,NULL,'Granol'),(876,7,3,'2022-08-13','35498623144','Vernice',NULL,NULL,NULL),(877,8,2,'2022-08-13','58843462067','Vernice',NULL,NULL,NULL),(878,20,3,'2022-08-13','35498623144',NULL,NULL,NULL,'Intonaco civile'),(879,4,2,'2022-08-13','84630152772','Vernice',NULL,NULL,NULL),(880,40,3,'2022-08-13','35498623144',NULL,NULL,NULL,'Spachtelputz'),(881,8,2,'2022-08-13','58843462067','Vernice',NULL,NULL,NULL),(882,30,3,'2022-08-13','37468674251',NULL,NULL,NULL,'Beton Cire'),(883,6,2,'2022-08-13','95910782700','Vernice',NULL,NULL,NULL),(884,4,3,'2022-08-13','84630152772','Vernice',NULL,NULL,NULL),(885,26,2,'2022-08-13','35498623144',NULL,NULL,NULL,'Granol'),(886,5,3,'2022-08-13','41486886249','Vernice',NULL,NULL,NULL),(887,8,2,'2022-08-13','58843462067','Vernice',NULL,NULL,NULL),(888,4.5,3,'2022-08-13','37468674251','Vernice',NULL,NULL,NULL),(889,6,2,'2022-08-13','95910782700','Vernice',NULL,NULL,NULL),(890,8,3,'2022-08-13','54908173906','Vernice',NULL,NULL,NULL),(891,10,2,'2022-08-13','80231812734','Vernice',NULL,NULL,NULL),(892,9,3,'2022-08-13','47164159739','Vernice',NULL,NULL,NULL),(893,5,2,'2022-08-13','81512365057','Vernice',NULL,NULL,NULL),(894,4.5,3,'2022-08-13','37468674251','Vernice',NULL,NULL,NULL),(895,6,2,'2022-08-13','95910782700','Vernice',NULL,NULL,NULL),(896,10,2,'2022-08-13','54908173906','Vernice',NULL,NULL,NULL),(897,20,3,'2022-08-13','80231812734',NULL,NULL,NULL,'Intonaco civile'),(898,9,2,'2022-08-13','47164159739','Vernice',NULL,NULL,NULL),(899,20,3,'2022-08-13','81512365057',NULL,NULL,NULL,'Intonaco civile'),(900,9,2,'2022-08-13','47164159739','Vernice',NULL,NULL,NULL),(901,40,3,'2022-08-13','35498623144',NULL,NULL,NULL,'Spachtelputz'),(902,4,2,'2022-08-13','84630152772','Vernice',NULL,NULL,NULL),(903,30,3,'2022-08-13','35498623144',NULL,NULL,NULL,'Beton Cire'),(904,8,2,'2022-08-13','58843462067','Vernice',NULL,NULL,NULL),(905,7,3,'2022-08-13','35498623144','Vernice',NULL,NULL,NULL),(906,25,2,'2022-08-13','84630152772',NULL,NULL,NULL,'Granol'),(907,7,3,'2022-08-13','35498623144','Vernice',NULL,NULL,NULL),(908,8,2,'2022-08-13','58843462067','Vernice',NULL,NULL,NULL),(909,40,3,'2022-08-13','35498623144',NULL,NULL,NULL,'MP2'),(910,4,2,'2022-08-13','84630152772','Vernice',NULL,NULL,NULL),(911,50,5,'2022-08-13','35498623144',NULL,NULL,NULL,'KP3'),(912,8,3,'2022-08-13','58843462067','Vernice',NULL,NULL,NULL),(913,7,2,'2022-08-13','35498623144','Vernice',NULL,NULL,NULL),(914,45,5,'2022-08-13','84630152772',NULL,NULL,NULL,'Rofix'),(915,7,3,'2022-08-13','35498623144','Vernice',NULL,NULL,NULL),(916,26,5,'2022-08-13','84630152772',NULL,NULL,NULL,'Granol'),(917,7,2,'2022-08-13','35498623144','Vernice',NULL,NULL,NULL),(918,5,35,'2022-08-13','41486886249','Vernice',NULL,NULL,NULL),(919,8,3,'2022-08-13','58843462067','Vernice',NULL,NULL,NULL),(920,4.5,2,'2022-08-13','37468674251','Vernice',NULL,NULL,NULL),(921,35,5,'2022-08-13','95910782700',NULL,NULL,NULL,'Beton Cire'),(922,10,3,'2022-08-13','54908173906','Vernice',NULL,NULL,NULL),(923,11,5,'2022-08-13','80231812734','Vernice',NULL,NULL,NULL),(924,9,6,'2022-08-13','47164159739','Vernice',NULL,NULL,NULL),(925,5,5,'2022-08-13','81512365057','Vernice',NULL,NULL,NULL),(926,11,6,'2022-08-13','80231812734','Vernice',NULL,NULL,NULL),(927,32,5,'2022-08-13','47164159739',NULL,NULL,NULL,'Beton Cire'),(928,5,6,'2022-08-13','81512365057','Vernice',NULL,NULL,NULL),(929,24,5,'2022-08-13','47164159739',NULL,NULL,NULL,'Granol'),(930,7,6,'2022-08-13','35498623144','Vernice',NULL,NULL,NULL),(931,24,5,'2022-08-13','84630152772',NULL,NULL,NULL,'Intonaco civile'),(932,7,6,'2022-08-13','35498623144','Vernice',NULL,NULL,NULL),(933,26,5,'2022-08-13','58843462067',NULL,NULL,NULL,'Intonaco civile');
INSERT INTO `lavoro_acquisti` VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(43,16),(43,17),(43,18),(44,19),(44,20),(45,21),(45,22),(46,23),(47,24),(47,25),(48,26),(49,27),(49,28),(50,29),(50,30),(51,31),(51,32),(52,33),(52,34),(53,35),(54,36),(55,37),(56,38),(56,39),(57,40),(58,41),(59,42),(59,43),(60,44),(61,45),(62,46),(63,47),(64,48),(65,49),(66,50),(66,51),(67,52),(68,53),(68,54),(69,55),(70,56),(70,57),(71,58),(72,59),(7,60),(7,61),(7,62),(7,63),(7,64),(7,65),(13,66),(13,67),(13,68),(13,69),(13,70),(13,71),(19,72),(19,73),(19,74),(19,75),(19,76),(19,77),(25,78),(25,79),(25,80),(25,81),(25,82),(25,83),(31,84),(31,85),(31,86),(31,87),(31,88),(31,89),(37,90),(37,91),(37,92),(37,93),(37,94),(37,95),(73,96),(74,97),(75,98),(75,99),(76,100),(76,101),(77,102),(77,103),(78,104),(79,105),(79,106),(80,107),(81,108),(81,109),(82,110),(82,111),(83,112),(84,113),(85,114),(85,115),(86,116),(86,117),(87,118),(87,119),(88,120),(89,121),(89,122),(90,123),(90,124),(91,125),(91,126),(92,127),(92,128),(93,129),(94,130),(94,131),(95,132),(95,133),(96,134),(96,135),(97,136),(97,137),(98,138),(99,139),(99,140),(100,141),(100,142),(101,143),(101,144),(102,145),(103,146),(103,147),(103,148),(104,149),(104,150),(105,151),(105,152),(106,153),(106,154),(107,155),(107,156),(108,157),(108,158),(109,159),(109,160),(110,161),(111,162),(112,163),(113,164),(113,165),(114,166),(115,167),(116,168),(116,169),(117,170),(117,171),(118,172),(119,173),(120,174),(121,175),(121,176),(122,177),(123,178),(123,179),(124,180),(124,181),(125,182),(125,183),(125,184),(126,185),(126,186),(127,187),(127,188),(127,189),(127,190),(127,191),(127,192),(133,193),(133,194),(133,195),(133,196),(133,197),(133,198),(139,199),(139,200),(139,201),(139,202),(139,203),(139,204),(145,205),(145,206),(145,207),(145,208),(145,209),(145,210),(151,211),(152,212),(152,213),(153,214),(153,215),(154,216),(154,217),(155,218),(155,219),(156,220),(157,221),(157,222),(158,223),(158,224),(159,225),(159,226),(160,227),(160,228),(161,229),(162,230),(162,231),(163,232),(163,233),(164,234),(164,235),(165,236),(165,237),(166,238),(167,239),(167,240),(168,241),(168,242),(169,243),(169,244),(170,245),(170,246),(171,247),(171,248),(171,249),(172,250),(172,251),(172,252),(173,253),(173,254),(174,255),(174,256),(175,257),(175,258),(180,262),(181,263),(182,264),(182,265),(183,266),(183,267),(184,268),(185,269),(186,270),(186,271),(187,272),(187,273),(188,274),(188,275),(189,276),(189,277),(190,278),(191,279),(191,280),(192,281),(193,282),(194,283),(195,284),(196,285),(197,286),(198,287),(198,288),(199,289),(199,290),(200,291),(200,292),(201,293),(202,294),(202,295),(203,296),(204,297),(205,298),(205,299),(206,300),(206,301),(207,302),(207,303),(208,304),(209,305),(210,306),(211,307),(211,308),(212,309),(212,310),(213,311),(214,312),(214,313),(214,314),(215,315),(215,316),(216,317),(217,318),(218,319),(219,320),(219,321),(250,322),(250,323),(250,324),(250,325),(250,326),(250,327),(256,328),(256,329),(256,330),(256,331),(256,332),(256,333),(262,334),(262,335),(262,336),(262,337),(262,338),(262,339),(268,340),(268,341),(268,342),(268,343),(268,344),(268,345),(274,346),(274,347),(274,348),(274,349),(274,350),(274,351),(280,352),(280,353),(280,354),(280,355),(280,356),(280,357),(286,358),(286,359),(286,360),(286,361),(286,362),(286,363),(292,364),(292,365),(292,366),(293,367),(293,368),(294,369),(294,370),(294,371),(295,372),(295,373),(295,374),(296,375),(296,376),(297,377),(297,378),(298,379),(298,380),(299,381),(299,382),(300,383),(301,384),(302,385),(303,386),(303,387),(304,388),(304,389),(305,390),(306,391),(307,392),(307,393),(308,394),(308,395),(308,396),(309,397),(309,398),(310,399),(311,400),(312,401),(312,402),(313,403),(314,404),(314,405),(315,406),(315,407),(315,408),(316,409),(316,410),(317,411),(317,412),(318,413),(319,414),(320,415),(321,416),(321,417),(322,418),(323,419),(324,420),(324,421),(325,422),(325,423),(326,424),(327,425),(327,426),(328,427),(329,428),(329,429),(330,430),(331,431),(331,432),(332,433),(332,434),(333,435),(333,436),(334,437),(334,438),(335,439),(336,440),(337,441),(338,442),(338,443),(339,444),(340,445),(340,446),(340,447),(340,448),(340,449),(340,450),(346,451),(346,452),(346,453),(346,454),(346,455),(346,456),(352,457),(352,458),(352,459),(352,460),(352,461),(352,462),(358,463),(358,464),(358,465),(358,466),(358,467),(358,468),(364,469),(364,470),(364,471),(364,472),(364,473),(364,474),(370,475),(370,476),(370,477),(370,478),(370,479),(370,480),(376,481),(376,482),(376,483),(376,484),(376,485),(376,486),(382,487),(382,488),(382,489),(382,490),(382,491),(382,492),(388,493),(389,494),(389,495),(390,496),(390,497),(391,498),(391,499),(392,500),(392,501),(393,502),(394,503),(395,504),(395,505),(396,506),(396,507),(397,508),(397,509),(398,510),(399,511),(400,512),(400,513),(401,514),(401,515),(402,516),(402,517),(403,518),(404,519),(404,520),(405,521),(405,522),(406,523),(406,524),(407,525),(407,526),(408,527),(409,528),(409,529),(410,530),(410,531),(411,532),(411,533),(412,534),(412,535),(413,536),(414,537),(414,538),(415,539),(415,540),(416,541),(416,542),(417,543),(417,544),(418,545),(419,546),(419,547),(420,548),(420,549),(421,550),(421,551),(422,552),(422,553),(423,554),(424,555),(424,556),(425,557),(426,558),(426,559),(427,560),(427,561),(428,562),(428,563),(429,564),(430,565),(431,566),(431,567),(432,568),(433,569),(434,570),(434,571),(434,572),(434,573),(434,574),(439,575),(439,576),(439,577),(440,578),(440,579),(440,580),(441,581),(441,582),(442,583),(443,584),(443,585),(444,586),(444,587),(444,588),(445,589),(446,590),(447,591),(448,592),(448,593),(449,594),(450,595),(451,596),(541,597),(451,598),(451,599),(451,600),(456,601),(456,602),(456,603),(456,604),(456,605),(461,606),(461,607),(462,608),(463,609),(463,610),(464,611),(464,612),(465,613),(465,614),(466,615),(467,616),(467,617),(468,618),(469,619),(469,620),(470,621),(470,622),(471,623),(471,624),(472,625),(473,626),(474,627),(474,628),(474,629),(475,630),(475,631),(476,632),(476,633),(477,634),(477,635),(478,636),(478,637),(478,638),(479,639),(479,640),(479,641),(480,642),(480,643),(480,644),(481,645),(481,646),(481,647),(482,648),(482,649),(482,650),(483,651),(483,652),(483,653),(484,654),(484,655),(485,656),(485,657),(486,658),(487,659),(488,660),(489,661),(490,662),(491,663),(492,664),(492,665),(493,666),(493,667),(494,668),(495,669),(495,670),(496,671),(497,672),(498,673),(498,674),(499,675),(499,676),(499,677),(499,678),(499,679),(499,680),(505,681),(505,682),(505,683),(505,684),(505,685),(505,686),(511,687),(511,688),(511,689),(511,690),(511,691),(511,692),(517,693),(518,694),(518,695),(519,696),(519,697),(520,698),(520,699),(521,700),(521,701),(522,702),(523,703),(523,704),(524,705),(524,706),(525,707),(525,708),(526,709),(526,710),(527,711),(528,712),(528,713),(529,714),(529,715),(530,716),(530,717),(531,718),(531,719),(532,720),(532,721),(532,722),(533,723),(533,724),(533,725),(534,726),(534,727),(535,728),(535,729),(535,730),(536,731),(536,732),(537,733),(537,734),(538,735),(538,736),(539,737),(539,738),(540,739),(540,740),(540,741),(541,742),(542,743),(543,744),(544,745),(544,746),(545,747),(545,748),(546,749),(546,750),(547,751),(548,752),(549,753),(550,754),(550,755),(551,756),(551,757),(552,758),(552,759),(553,760),(553,761),(554,762),(554,763),(555,764),(556,765),(556,766),(557,767),(558,768),(559,769),(559,770),(560,771),(561,772),(561,773),(562,774),(563,775),(563,776),(564,777),(564,778),(565,779),(565,780),(566,781),(566,782),(567,783),(568,784),(569,785),(570,786),(570,787),(571,788),(572,789),(572,790),(573,791),(573,792),(574,793),(575,794),(575,795),(576,796),(577,797),(577,798),(578,799),(579,800),(579,801),(580,802),(581,803),(582,804),(582,805),(583,806),(583,807),(583,808),(584,809),(584,810),(585,811),(585,812),(586,813),(586,814),(586,815),(586,816),(586,817),(586,818),(592,819),(592,820),(592,821),(592,822),(592,823),(592,824),(598,825),(598,826),(598,827),(598,828),(598,829),(598,830),(604,831),(604,832),(604,833),(604,834),(604,835),(604,836),(610,837),(610,838),(610,839),(610,840),(610,841),(610,842),(616,843),(616,844),(616,845),(616,846),(616,847),(616,848),(622,849),(622,850),(622,851),(622,852),(622,853),(622,854),(628,855),(628,856),(628,857),(628,858),(628,859),(628,860),(634,861),(634,862),(634,863),(634,864),(634,865),(634,866),(640,867),(641,868),(641,869),(642,870),(642,871),(643,872),(643,873),(644,874),(644,875),(645,876),(646,877),(646,878),(647,879),(647,880),(648,881),(648,882),(649,883),(650,884),(650,885),(651,886),(652,887),(653,888),(654,889),(655,890),(656,891),(657,892),(658,893),(659,894),(660,895),(661,896),(661,897),(662,898),(662,899),(663,900),(663,901),(664,902),(664,903),(665,904),(666,905),(666,906),(667,907),(668,908),(668,909),(669,910),(669,911),(670,912),(671,913),(671,914),(672,915),(672,916),(673,917),(674,918),(675,919),(676,920),(676,921),(677,922),(678,923),(679,924),(680,925),(681,926),(681,927),(682,928),(682,929),(683,930),(683,931),(684,932),(684,933);
INSERT INTO `personale` VALUES (1,'Luca','Giannini','2021-03-29',10,5,NULL),(2,'Francesca','Repice','2006-12-02',23,4,NULL),(3,'Valentino','Cannalira','2008-01-19',22,5,NULL),(4,'Frank','Sinatra','2001-08-12',30,7,NULL),(5,'Angelo','Cielo','2017-03-24',10,1,NULL),(6,'Giustino','Belluca','2007-09-07',16,3,NULL),(7,'Dante','Rossi','2006-03-22',12,NULL,3),(8,'Valente','Liberato','2002-08-08',20,NULL,4),(9,'Gaia','Bianchi','2009-11-19',10,NULL,3),(10,'Paolo','Rossi','2010-03-25',8,NULL,6),(11,'Cecilia','Caciagli','2015-03-10',9,NULL,3),(12,'Dario','Lampa','2009-03-27',9,NULL,4),(13,'Martina','Iacoponi','2019-03-28',9,NULL,3),(14,'Angela','Digianpaolo','2022-03-30',15,NULL,6),(15,'Matteo','Professione','2019-03-31',13,NULL,1),(16,'Alex','Del Piero','2016-04-01',11,NULL,1),(17,'Maria','Armani','2014-04-02',9,NULL,1),(18,'Armando','Busca','2012-11-15',12,NULL,4),(19,'Giuseppe','Rossi','2013-01-24',12,NULL,2),(20,'Francesco','Totti','2008-09-13',40,NULL,1),(21,'Francesco','Bagnaia','2009-06-06',15,NULL,2),(22,'Christian','Polperio','2008-06-14',12,NULL,1),(23,'Mario','Lucca','2006-04-10',19,NULL,4),(24,'Paola','Mannino','2000-05-05',25,NULL,4),(25,'Alberto','Correnti','2011-12-11',14,NULL,6),(26,'Gennaro','Rubio','2007-10-04',5,NULL,4),(27,'Gary','Kuka','2000-04-18',7,NULL,3),(28,'Paolo','Roberti','2020-08-22',8,NULL,4);
INSERT INTO `turno` VALUES ('2014-03-02 08:00:00','2014-03-02 16:00:00',1,1),('2014-03-02 08:00:00','2014-03-02 16:00:00',15,1),('2014-03-02 08:00:00','2014-03-02 16:00:00',16,1),('2014-03-02 08:00:00','2014-03-02 16:00:00',17,1),('2015-03-03 08:00:00','2015-03-03 16:00:00',1,1),('2015-03-03 08:00:00','2015-03-03 16:00:00',15,1),('2015-03-03 08:00:00','2015-03-03 16:00:00',16,1),('2015-03-03 08:00:00','2015-03-03 16:00:00',17,1),('2016-03-04 08:00:00','2016-03-04 16:00:00',1,1),('2016-03-04 08:00:00','2016-03-04 16:00:00',15,1),('2016-03-04 08:00:00','2016-03-04 16:00:00',16,1),('2016-03-04 08:00:00','2016-03-04 16:00:00',17,1),('2017-03-05 08:00:00','2017-03-05 16:00:00',1,1),('2017-03-05 08:00:00','2017-03-05 16:00:00',15,1),('2017-03-05 08:00:00','2017-03-05 16:00:00',16,1),('2017-03-05 08:00:00','2017-03-05 16:00:00',17,1),('2017-03-06 08:00:00','2017-03-06 16:00:00',1,1),('2017-03-06 08:00:00','2017-03-06 16:00:00',15,1),('2017-03-06 08:00:00','2017-03-06 16:00:00',16,1),('2017-03-06 08:00:00','2017-03-06 16:00:00',17,1),('2017-05-02 12:00:00','2017-05-02 20:00:00',5,103),('2017-05-03 12:00:00','2017-05-03 20:00:00',5,104),('2018-07-14 14:00:00','2018-07-14 22:00:00',4,300),('2018-07-14 14:00:00','2018-07-14 22:00:00',26,70),('2018-07-15 14:00:00','2018-07-15 22:00:00',4,301),('2018-07-15 14:00:00','2018-07-15 22:00:00',26,71),('2018-07-16 14:00:00','2018-07-16 22:00:00',4,302),('2018-07-16 14:00:00','2018-07-16 22:00:00',26,71),('2018-07-17 14:00:00','2018-07-17 22:00:00',4,303),('2018-07-17 14:00:00','2018-07-17 22:00:00',26,71),('2018-07-18 14:00:00','2018-07-18 22:00:00',4,304),('2018-07-18 14:00:00','2018-07-18 22:00:00',26,71),('2018-07-19 14:00:00','2018-07-19 22:00:00',4,305),('2018-07-19 14:00:00','2018-07-19 22:00:00',26,71),('2018-07-20 14:00:00','2018-07-20 22:00:00',4,306),('2018-07-20 14:00:00','2018-07-20 22:00:00',26,71),('2018-07-21 14:00:00','2018-07-21 22:00:00',4,307),('2018-07-21 14:00:00','2018-07-21 22:00:00',26,77),('2018-07-22 14:00:00','2018-07-22 22:00:00',4,308),('2018-07-22 14:00:00','2018-07-22 22:00:00',26,77),('2018-07-23 14:00:00','2018-07-23 22:00:00',4,309),('2018-07-23 14:00:00','2018-07-23 22:00:00',26,77),('2018-07-24 14:00:00','2018-07-24 22:00:00',4,310),('2018-07-25 14:00:00','2018-07-25 22:00:00',4,311),('2018-07-25 14:00:00','2018-07-25 22:00:00',26,71),('2018-07-26 14:00:00','2018-07-26 22:00:00',4,312),('2018-07-26 14:00:00','2018-07-26 22:00:00',26,71),('2018-07-27 14:00:00','2018-07-27 22:00:00',4,313),('2018-07-27 14:00:00','2018-07-27 22:00:00',26,71),('2018-07-28 14:00:00','2018-07-28 22:00:00',4,314),('2018-07-28 14:00:00','2018-07-28 22:00:00',26,71),('2018-07-29 14:00:00','2018-07-29 22:00:00',4,315),('2018-07-29 14:00:00','2018-07-29 22:00:00',26,71),('2018-07-30 14:00:00','2018-07-30 22:00:00',4,316),('2018-07-30 14:00:00','2018-07-30 22:00:00',26,71),('2018-07-31 14:00:00','2018-07-31 22:00:00',4,317),('2018-07-31 14:00:00','2018-07-31 22:00:00',26,77),('2018-08-01 14:00:00','2018-08-01 22:00:00',4,318),('2018-08-01 14:00:00','2018-08-01 22:00:00',26,77),('2018-08-02 14:00:00','2018-08-02 22:00:00',4,319),('2018-08-02 14:00:00','2018-08-02 22:00:00',26,77),('2018-08-03 14:00:00','2018-08-03 22:00:00',4,320),('2018-08-04 14:00:00','2018-08-04 22:00:00',4,321),('2018-08-04 14:00:00','2018-08-04 22:00:00',26,71),('2018-08-05 14:00:00','2018-08-05 22:00:00',4,322),('2018-08-05 14:00:00','2018-08-05 22:00:00',26,71),('2018-08-06 14:00:00','2018-08-06 22:00:00',4,323),('2018-08-06 14:00:00','2018-08-06 22:00:00',26,71),('2018-08-07 14:00:00','2018-08-07 22:00:00',4,324),('2018-08-07 14:00:00','2018-08-07 22:00:00',26,71),('2018-08-08 14:00:00','2018-08-08 22:00:00',4,325),('2018-08-08 14:00:00','2018-08-08 22:00:00',26,71),('2018-08-09 14:00:00','2018-08-09 22:00:00',4,326),('2018-08-09 14:00:00','2018-08-09 22:00:00',26,71),('2018-08-10 14:00:00','2018-08-10 22:00:00',4,327),('2018-08-10 14:00:00','2018-08-10 22:00:00',26,77),('2018-08-11 14:00:00','2018-08-11 22:00:00',4,328),('2018-08-11 14:00:00','2018-08-11 22:00:00',26,77),('2018-08-12 14:00:00','2018-08-12 22:00:00',4,329),('2018-08-12 14:00:00','2018-08-12 22:00:00',26,77),('2018-08-13 14:00:00','2018-08-13 22:00:00',4,330),('2018-08-14 14:00:00','2018-08-14 22:00:00',4,331),('2018-08-14 14:00:00','2018-08-14 22:00:00',26,71),('2018-08-15 14:00:00','2018-08-15 22:00:00',4,332),('2018-08-15 14:00:00','2018-08-15 22:00:00',26,71),('2018-08-16 14:00:00','2018-08-16 22:00:00',4,333),('2018-08-16 14:00:00','2018-08-16 22:00:00',26,71),('2018-08-17 14:00:00','2018-08-17 22:00:00',4,334),('2018-08-17 14:00:00','2018-08-17 22:00:00',26,71),('2018-09-27 08:00:00','2018-09-27 16:00:00',1,1),('2018-09-27 08:00:00','2018-09-27 16:00:00',15,1),('2018-09-27 08:00:00','2018-09-27 16:00:00',16,1),('2018-09-27 08:00:00','2018-09-27 16:00:00',17,1),('2018-09-28 08:00:00','2018-09-28 16:00:00',2,7),('2018-09-28 08:00:00','2018-09-28 16:00:00',6,43),('2018-09-28 08:00:00','2018-09-28 16:00:00',10,7),('2018-09-28 08:00:00','2018-09-28 16:00:00',19,7),('2018-09-28 08:00:00','2018-09-28 16:00:00',21,7),('2018-09-29 08:00:00','2018-09-29 16:00:00',2,7),('2018-09-29 08:00:00','2018-09-29 16:00:00',6,44),('2018-09-29 08:00:00','2018-09-29 16:00:00',10,7),('2018-09-29 08:00:00','2018-09-29 16:00:00',19,7),('2018-09-29 08:00:00','2018-09-29 16:00:00',21,7),('2018-09-30 08:00:00','2018-09-30 16:00:00',2,7),('2018-09-30 08:00:00','2018-09-30 16:00:00',6,45),('2018-09-30 08:00:00','2018-09-30 16:00:00',10,7),('2018-09-30 08:00:00','2018-09-30 16:00:00',19,7),('2018-09-30 08:00:00','2018-09-30 16:00:00',21,7),('2018-10-01 08:00:00','2018-10-01 16:00:00',2,7),('2018-10-01 08:00:00','2018-10-01 16:00:00',6,46),('2018-10-01 08:00:00','2018-10-01 16:00:00',10,7),('2018-10-01 08:00:00','2018-10-01 16:00:00',19,7),('2018-10-01 08:00:00','2018-10-01 16:00:00',21,7),('2018-10-02 08:00:00','2018-10-02 16:00:00',2,7),('2018-10-02 08:00:00','2018-10-02 16:00:00',4,292),('2018-10-02 08:00:00','2018-10-02 16:00:00',6,47),('2018-10-02 08:00:00','2018-10-02 16:00:00',19,7),('2018-10-02 08:00:00','2018-10-02 16:00:00',21,7),('2018-10-02 08:00:00','2018-10-02 16:00:00',24,171),('2018-10-03 08:00:00','2018-10-03 16:00:00',4,293),('2018-10-03 08:00:00','2018-10-03 16:00:00',24,171),('2018-10-04 08:00:00','2018-10-04 16:00:00',4,294),('2018-10-04 08:00:00','2018-10-04 16:00:00',24,171),('2018-10-05 08:00:00','2018-10-05 16:00:00',4,295),('2018-10-05 08:00:00','2018-10-05 16:00:00',24,171),('2018-10-06 08:00:00','2018-10-06 16:00:00',4,296),('2018-10-06 08:00:00','2018-10-06 16:00:00',24,171),('2018-10-19 12:00:00','2018-10-19 20:00:00',5,105),('2018-10-20 12:00:00','2018-10-20 20:00:00',5,106),('2018-11-20 08:00:00','2018-11-20 16:00:00',4,297),('2018-11-20 08:00:00','2018-11-20 16:00:00',24,175),('2018-11-21 08:00:00','2018-11-21 16:00:00',4,298),('2018-11-21 08:00:00','2018-11-21 16:00:00',24,175),('2018-11-22 08:00:00','2018-11-22 16:00:00',4,299),('2018-11-22 08:00:00','2018-11-22 16:00:00',24,175),('2018-12-20 12:00:00','2018-12-20 20:00:00',3,107),('2018-12-20 12:00:00','2018-12-20 20:00:00',11,77),('2018-12-21 12:00:00','2018-12-21 20:00:00',3,108),('2018-12-21 12:00:00','2018-12-21 20:00:00',11,77),('2018-12-22 12:00:00','2018-12-22 20:00:00',3,109),('2018-12-22 12:00:00','2018-12-22 20:00:00',11,77),('2018-12-23 12:00:00','2018-12-23 20:00:00',3,110),('2018-12-24 12:00:00','2018-12-24 20:00:00',3,111),('2018-12-24 12:00:00','2018-12-24 20:00:00',11,71),('2018-12-25 12:00:00','2018-12-25 20:00:00',3,112),('2018-12-25 12:00:00','2018-12-25 20:00:00',11,71),('2018-12-26 12:00:00','2018-12-26 20:00:00',3,113),('2018-12-26 12:00:00','2018-12-26 20:00:00',11,71),('2018-12-27 12:00:00','2018-12-27 20:00:00',3,114),('2018-12-27 12:00:00','2018-12-27 20:00:00',11,71),('2018-12-28 12:00:00','2018-12-28 20:00:00',3,115),('2018-12-28 12:00:00','2018-12-28 20:00:00',11,71),('2018-12-29 12:00:00','2018-12-29 20:00:00',3,116),('2018-12-29 12:00:00','2018-12-29 20:00:00',11,71),('2018-12-30 12:00:00','2018-12-30 20:00:00',3,117),('2018-12-30 12:00:00','2018-12-30 20:00:00',11,77),('2018-12-31 12:00:00','2018-12-31 20:00:00',3,118),('2018-12-31 12:00:00','2018-12-31 20:00:00',11,77),('2019-01-01 12:00:00','2019-01-01 20:00:00',3,119),('2019-01-01 12:00:00','2019-01-01 20:00:00',11,77),('2019-01-02 12:00:00','2019-01-02 20:00:00',3,120),('2019-01-03 12:00:00','2019-01-03 20:00:00',3,121),('2019-01-03 12:00:00','2019-01-03 20:00:00',11,71),('2019-02-23 08:00:00','2019-02-23 16:00:00',3,340),('2019-02-24 08:00:00','2019-02-24 16:00:00',3,71),('2019-02-24 08:00:00','2019-02-24 16:00:00',27,71),('2019-02-25 08:00:00','2019-02-25 16:00:00',3,71),('2019-02-25 08:00:00','2019-02-25 16:00:00',27,71),('2019-02-26 08:00:00','2019-02-26 16:00:00',2,7),('2019-02-26 08:00:00','2019-02-26 16:00:00',3,71),('2019-02-26 08:00:00','2019-02-26 16:00:00',6,48),('2019-02-26 08:00:00','2019-02-26 16:00:00',19,7),('2019-02-26 08:00:00','2019-02-26 16:00:00',21,7),('2019-02-26 08:00:00','2019-02-26 16:00:00',27,71),('2019-02-27 08:00:00','2019-02-27 16:00:00',2,13),('2019-02-27 08:00:00','2019-02-27 16:00:00',3,71),('2019-02-27 08:00:00','2019-02-27 16:00:00',6,49),('2019-02-27 08:00:00','2019-02-27 16:00:00',19,7),('2019-02-27 08:00:00','2019-02-27 16:00:00',21,7),('2019-02-27 08:00:00','2019-02-27 16:00:00',27,71),('2019-02-28 08:00:00','2019-02-28 16:00:00',2,7),('2019-02-28 08:00:00','2019-02-28 16:00:00',3,71),('2019-02-28 08:00:00','2019-02-28 16:00:00',6,50),('2019-02-28 08:00:00','2019-02-28 16:00:00',10,7),('2019-02-28 08:00:00','2019-02-28 16:00:00',19,7),('2019-02-28 08:00:00','2019-02-28 16:00:00',21,7),('2019-02-28 08:00:00','2019-02-28 16:00:00',27,71),('2019-03-01 08:00:00','2019-03-01 16:00:00',2,7),('2019-03-01 08:00:00','2019-03-01 16:00:00',3,346),('2019-03-01 08:00:00','2019-03-01 16:00:00',6,51),('2019-03-01 08:00:00','2019-03-01 16:00:00',10,7),('2019-03-01 08:00:00','2019-03-01 16:00:00',19,7),('2019-03-01 08:00:00','2019-03-01 16:00:00',21,7),('2019-03-01 08:00:00','2019-03-01 16:00:00',27,71),('2019-03-02 08:00:00','2019-03-02 16:00:00',2,7),('2019-03-02 08:00:00','2019-03-02 16:00:00',3,77),('2019-03-02 08:00:00','2019-03-02 16:00:00',6,52),('2019-03-02 08:00:00','2019-03-02 16:00:00',10,7),('2019-03-02 08:00:00','2019-03-02 16:00:00',19,7),('2019-03-02 08:00:00','2019-03-02 16:00:00',21,7),('2019-03-02 08:00:00','2019-03-02 16:00:00',27,77),('2019-03-03 08:00:00','2019-03-03 16:00:00',3,77),('2019-03-03 08:00:00','2019-03-03 16:00:00',6,53),('2019-03-03 08:00:00','2019-03-03 16:00:00',10,7),('2019-03-03 08:00:00','2019-03-03 16:00:00',27,77),('2019-03-04 08:00:00','2019-03-04 16:00:00',3,77),('2019-03-04 08:00:00','2019-03-04 16:00:00',6,54),('2019-03-04 08:00:00','2019-03-04 16:00:00',10,7),('2019-03-04 08:00:00','2019-03-04 16:00:00',27,77),('2019-03-05 08:00:00','2019-03-05 16:00:00',2,19),('2019-03-05 08:00:00','2019-03-05 16:00:00',6,55),('2019-03-05 08:00:00','2019-03-05 16:00:00',10,7),('2019-03-06 08:00:00','2019-03-06 16:00:00',2,7),('2019-03-06 08:00:00','2019-03-06 16:00:00',3,71),('2019-03-06 08:00:00','2019-03-06 16:00:00',6,56),('2019-03-06 08:00:00','2019-03-06 16:00:00',10,7),('2019-03-06 08:00:00','2019-03-06 16:00:00',19,7),('2019-03-06 08:00:00','2019-03-06 16:00:00',21,7),('2019-03-06 08:00:00','2019-03-06 16:00:00',27,71),('2019-03-07 08:00:00','2019-03-07 16:00:00',2,7),('2019-03-07 08:00:00','2019-03-07 16:00:00',3,352),('2019-03-07 08:00:00','2019-03-07 16:00:00',6,57),('2019-03-07 08:00:00','2019-03-07 16:00:00',19,7),('2019-03-07 08:00:00','2019-03-07 16:00:00',21,7),('2019-03-07 08:00:00','2019-03-07 16:00:00',27,71),('2019-03-08 08:00:00','2019-03-08 16:00:00',2,7),('2019-03-08 08:00:00','2019-03-08 16:00:00',3,71),('2019-03-08 08:00:00','2019-03-08 16:00:00',6,58),('2019-03-08 08:00:00','2019-03-08 16:00:00',19,7),('2019-03-08 08:00:00','2019-03-08 16:00:00',21,7),('2019-03-08 08:00:00','2019-03-08 16:00:00',27,71),('2019-03-09 08:00:00','2019-03-09 16:00:00',2,7),('2019-03-09 08:00:00','2019-03-09 16:00:00',3,71),('2019-03-09 08:00:00','2019-03-09 16:00:00',6,59),('2019-03-09 08:00:00','2019-03-09 16:00:00',19,7),('2019-03-09 08:00:00','2019-03-09 16:00:00',21,7),('2019-03-09 08:00:00','2019-03-09 16:00:00',27,71),('2019-03-10 08:00:00','2019-03-10 16:00:00',2,7),('2019-03-10 08:00:00','2019-03-10 16:00:00',3,71),('2019-03-10 08:00:00','2019-03-10 16:00:00',6,60),('2019-03-10 08:00:00','2019-03-10 16:00:00',10,7),('2019-03-10 08:00:00','2019-03-10 16:00:00',19,7),('2019-03-10 08:00:00','2019-03-10 16:00:00',21,7),('2019-03-10 08:00:00','2019-03-10 16:00:00',27,71),('2019-03-11 08:00:00','2019-03-11 16:00:00',2,25),('2019-03-11 08:00:00','2019-03-11 16:00:00',3,71),('2019-03-11 08:00:00','2019-03-11 16:00:00',6,61),('2019-03-11 08:00:00','2019-03-11 16:00:00',10,7),('2019-03-11 08:00:00','2019-03-11 16:00:00',19,7),('2019-03-11 08:00:00','2019-03-11 16:00:00',21,7),('2019-03-11 08:00:00','2019-03-11 16:00:00',27,71),('2019-03-12 08:00:00','2019-03-12 16:00:00',2,7),('2019-03-12 08:00:00','2019-03-12 16:00:00',3,77),('2019-03-12 08:00:00','2019-03-12 16:00:00',6,62),('2019-03-12 08:00:00','2019-03-12 16:00:00',10,7),('2019-03-12 08:00:00','2019-03-12 16:00:00',19,7),('2019-03-12 08:00:00','2019-03-12 16:00:00',21,7),('2019-03-12 08:00:00','2019-03-12 16:00:00',27,77),('2019-03-13 08:00:00','2019-03-13 16:00:00',3,358),('2019-03-13 08:00:00','2019-03-13 16:00:00',6,63),('2019-03-13 08:00:00','2019-03-13 16:00:00',10,7),('2019-03-13 08:00:00','2019-03-13 16:00:00',27,77),('2019-03-14 08:00:00','2019-03-14 16:00:00',3,77),('2019-03-14 08:00:00','2019-03-14 16:00:00',6,64),('2019-03-14 08:00:00','2019-03-14 16:00:00',10,7),('2019-03-14 08:00:00','2019-03-14 16:00:00',27,77),('2019-03-15 08:00:00','2019-03-15 16:00:00',6,65),('2019-03-15 08:00:00','2019-03-15 16:00:00',10,7),('2019-03-16 08:00:00','2019-03-16 16:00:00',3,71),('2019-03-16 08:00:00','2019-03-16 16:00:00',27,71),('2019-03-17 08:00:00','2019-03-17 16:00:00',3,71),('2019-03-17 08:00:00','2019-03-17 16:00:00',27,71),('2019-03-18 08:00:00','2019-03-18 16:00:00',3,71),('2019-03-18 08:00:00','2019-03-18 16:00:00',27,71),('2019-03-19 08:00:00','2019-03-19 16:00:00',3,364),('2019-03-19 08:00:00','2019-03-19 16:00:00',27,71),('2019-03-20 08:00:00','2019-03-20 16:00:00',3,71),('2019-03-20 08:00:00','2019-03-20 16:00:00',27,71),('2019-03-21 08:00:00','2019-03-21 16:00:00',3,71),('2019-03-21 08:00:00','2019-03-21 16:00:00',27,71),('2019-03-22 08:00:00','2019-03-22 16:00:00',3,77),('2019-03-22 08:00:00','2019-03-22 16:00:00',27,77),('2019-03-23 08:00:00','2019-03-23 16:00:00',3,77),('2019-03-23 08:00:00','2019-03-23 16:00:00',27,77),('2019-03-24 08:00:00','2019-03-24 16:00:00',3,77),('2019-03-24 08:00:00','2019-03-24 16:00:00',27,77),('2019-03-25 08:00:00','2019-03-25 16:00:00',3,370),('2019-03-25 08:00:00','2019-03-25 16:00:00',27,170),('2019-03-26 08:00:00','2019-03-26 16:00:00',3,171),('2019-03-26 08:00:00','2019-03-26 16:00:00',27,171),('2019-03-27 08:00:00','2019-03-27 16:00:00',3,171),('2019-03-27 08:00:00','2019-03-27 16:00:00',27,171),('2019-03-28 08:00:00','2019-03-28 16:00:00',3,171),('2019-03-28 08:00:00','2019-03-28 16:00:00',27,171),('2019-03-29 08:00:00','2019-03-29 16:00:00',3,171),('2019-03-29 08:00:00','2019-03-29 16:00:00',27,171),('2019-03-30 08:00:00','2019-03-30 16:00:00',3,171),('2019-03-30 08:00:00','2019-03-30 16:00:00',27,171),('2019-03-31 08:00:00','2019-03-31 16:00:00',3,376),('2019-03-31 08:00:00','2019-03-31 16:00:00',27,171),('2019-04-01 08:00:00','2019-04-01 16:00:00',3,175),('2019-04-01 08:00:00','2019-04-01 16:00:00',27,175),('2019-05-07 14:00:00','2019-05-07 22:00:00',4,335),('2019-05-07 14:00:00','2019-05-07 22:00:00',26,71),('2019-05-08 14:00:00','2019-05-08 22:00:00',4,336),('2019-05-08 14:00:00','2019-05-08 22:00:00',26,71),('2019-05-09 14:00:00','2019-05-09 22:00:00',4,337),('2019-05-09 14:00:00','2019-05-09 22:00:00',26,77),('2019-05-10 14:00:00','2019-05-10 22:00:00',4,338),('2019-05-10 14:00:00','2019-05-10 22:00:00',26,77),('2019-05-11 14:00:00','2019-05-11 22:00:00',4,339),('2019-05-11 14:00:00','2019-05-11 22:00:00',26,77),('2019-09-08 08:00:00','2019-09-08 08:00:00',4,250),('2019-09-09 08:00:00','2019-09-09 08:00:00',4,71),('2019-09-09 08:00:00','2019-09-09 08:00:00',23,71),('2019-09-10 08:00:00','2019-09-10 08:00:00',4,71),('2019-09-10 08:00:00','2019-09-10 08:00:00',23,71),('2019-09-11 08:00:00','2019-09-11 08:00:00',4,71),('2019-09-11 08:00:00','2019-09-11 08:00:00',23,71),('2019-09-12 08:00:00','2019-09-12 08:00:00',4,71),('2019-09-12 08:00:00','2019-09-12 08:00:00',23,71),('2019-09-13 08:00:00','2019-09-13 08:00:00',4,71),('2019-09-13 08:00:00','2019-09-13 08:00:00',23,71),('2019-09-14 08:00:00','2019-09-14 08:00:00',4,256),('2019-09-14 08:00:00','2019-09-14 08:00:00',23,71),('2019-09-15 08:00:00','2019-09-15 08:00:00',4,77),('2019-09-15 08:00:00','2019-09-15 08:00:00',23,77),('2019-09-16 08:00:00','2019-09-16 08:00:00',4,77),('2019-09-16 08:00:00','2019-09-16 08:00:00',23,77),('2019-09-17 08:00:00','2019-09-17 08:00:00',4,77),('2019-09-17 08:00:00','2019-09-17 08:00:00',23,77),('2019-09-19 08:00:00','2019-09-19 08:00:00',4,71),('2019-09-19 08:00:00','2019-09-19 08:00:00',23,71),('2019-09-20 08:00:00','2019-09-20 08:00:00',4,262),('2019-09-20 08:00:00','2019-09-20 08:00:00',23,71),('2019-09-21 08:00:00','2019-09-21 08:00:00',4,71),('2019-09-21 08:00:00','2019-09-21 08:00:00',23,71),('2019-09-22 08:00:00','2019-09-22 08:00:00',4,71),('2019-09-22 08:00:00','2019-09-22 08:00:00',23,71),('2019-09-23 08:00:00','2019-09-23 08:00:00',4,71),('2019-09-23 08:00:00','2019-09-23 08:00:00',23,71),('2019-09-24 08:00:00','2019-09-24 08:00:00',4,71),('2019-09-24 08:00:00','2019-09-24 08:00:00',23,71),('2019-09-25 08:00:00','2019-09-25 08:00:00',4,77),('2019-09-25 08:00:00','2019-09-25 08:00:00',23,77),('2019-09-26 08:00:00','2019-09-26 08:00:00',4,268),('2019-09-26 08:00:00','2019-09-26 08:00:00',23,77),('2019-09-27 08:00:00','2019-09-27 08:00:00',4,77),('2019-09-27 08:00:00','2019-09-27 08:00:00',23,77),('2019-09-28 08:00:00','2019-09-28 08:00:00',4,170),('2019-09-28 08:00:00','2019-09-28 08:00:00',23,170),('2019-09-29 08:00:00','2019-09-29 08:00:00',4,171),('2019-09-29 08:00:00','2019-09-29 08:00:00',23,171),('2019-09-30 08:00:00','2019-09-30 08:00:00',4,171),('2019-09-30 08:00:00','2019-09-30 08:00:00',23,171),('2019-10-01 08:00:00','2019-10-01 08:00:00',4,171),('2019-10-01 08:00:00','2019-10-01 08:00:00',23,171),('2019-10-02 08:00:00','2019-10-02 08:00:00',4,274),('2019-10-02 08:00:00','2019-10-02 08:00:00',23,171),('2019-10-03 08:00:00','2019-10-03 08:00:00',4,171),('2019-10-03 08:00:00','2019-10-03 08:00:00',23,171),('2019-10-04 08:00:00','2019-10-04 08:00:00',4,171),('2019-10-04 08:00:00','2019-10-04 08:00:00',23,171),('2019-10-05 08:00:00','2019-10-05 08:00:00',4,175),('2019-10-05 08:00:00','2019-10-05 08:00:00',23,175),('2019-10-06 08:00:00','2019-10-06 08:00:00',4,175),('2019-10-06 08:00:00','2019-10-06 08:00:00',23,175),('2019-10-07 08:00:00','2019-10-07 08:00:00',4,175),('2019-10-07 08:00:00','2019-10-07 08:00:00',23,175),('2019-10-08 08:00:00','2019-10-08 08:00:00',4,280),('2019-10-08 08:00:00','2019-10-08 08:00:00',23,170),('2019-10-09 08:00:00','2019-10-09 08:00:00',4,171),('2019-10-09 08:00:00','2019-10-09 08:00:00',23,171),('2019-10-10 08:00:00','2019-10-10 08:00:00',4,171),('2019-10-10 08:00:00','2019-10-10 08:00:00',23,171),('2019-10-11 08:00:00','2019-10-11 08:00:00',4,171),('2019-10-11 08:00:00','2019-10-11 08:00:00',23,171),('2019-10-12 08:00:00','2019-10-12 08:00:00',4,171),('2019-10-12 08:00:00','2019-10-12 08:00:00',23,171),('2019-10-13 08:00:00','2019-10-13 08:00:00',4,171),('2019-10-13 08:00:00','2019-10-13 08:00:00',23,171),('2019-10-14 08:00:00','2019-10-14 08:00:00',4,286),('2019-10-14 08:00:00','2019-10-14 08:00:00',23,171),('2019-10-15 08:00:00','2019-10-15 08:00:00',4,175),('2019-10-15 08:00:00','2019-10-15 08:00:00',23,175),('2019-10-16 08:00:00','2019-10-16 08:00:00',4,175),('2019-10-16 08:00:00','2019-10-16 08:00:00',23,175),('2019-10-17 08:00:00','2019-10-17 08:00:00',4,175),('2019-10-17 08:00:00','2019-10-17 08:00:00',23,175),('2019-11-06 08:00:00','2019-11-06 16:00:00',3,175),('2019-11-06 08:00:00','2019-11-06 16:00:00',27,175),('2019-11-07 08:00:00','2019-11-07 16:00:00',3,175),('2019-11-07 08:00:00','2019-11-07 16:00:00',27,175),('2019-11-08 08:00:00','2019-11-08 16:00:00',3,170),('2019-11-08 08:00:00','2019-11-08 16:00:00',27,170),('2019-11-09 08:00:00','2019-11-09 16:00:00',3,171),('2019-11-09 08:00:00','2019-11-09 16:00:00',27,171),('2019-11-10 08:00:00','2019-11-10 16:00:00',3,382),('2019-11-10 08:00:00','2019-11-10 16:00:00',27,171),('2019-11-11 08:00:00','2019-11-11 16:00:00',3,171),('2019-11-11 08:00:00','2019-11-11 16:00:00',27,171),('2019-11-12 08:00:00','2019-11-12 16:00:00',3,171),('2019-11-12 08:00:00','2019-11-12 16:00:00',27,171),('2019-11-13 08:00:00','2019-11-13 16:00:00',3,171),('2019-11-13 08:00:00','2019-11-13 16:00:00',27,171),('2019-11-14 08:00:00','2019-11-14 16:00:00',3,171),('2019-11-14 08:00:00','2019-11-14 16:00:00',27,171),('2019-11-15 08:00:00','2019-11-15 16:00:00',3,175),('2019-11-15 08:00:00','2019-11-15 16:00:00',27,175),('2019-12-29 12:00:00','2019-12-29 20:00:00',4,388),('2019-12-29 12:00:00','2019-12-29 20:00:00',28,175),('2019-12-30 12:00:00','2019-12-30 20:00:00',4,389),('2019-12-30 12:00:00','2019-12-30 20:00:00',28,175),('2019-12-31 12:00:00','2019-12-31 20:00:00',4,390),('2019-12-31 12:00:00','2019-12-31 20:00:00',28,170),('2020-01-01 12:00:00','2020-01-01 20:00:00',4,391),('2020-01-01 12:00:00','2020-01-01 20:00:00',28,171),('2020-01-02 12:00:00','2020-01-02 20:00:00',4,392),('2020-01-02 12:00:00','2020-01-02 20:00:00',28,171),('2020-01-03 12:00:00','2020-01-03 20:00:00',4,393),('2020-01-03 12:00:00','2020-01-03 20:00:00',28,171),('2020-01-04 12:00:00','2020-01-04 20:00:00',4,394),('2020-01-04 12:00:00','2020-01-04 20:00:00',28,171),('2020-01-05 12:00:00','2020-01-05 20:00:00',4,395),('2020-01-05 12:00:00','2020-01-05 20:00:00',28,171),('2020-01-06 12:00:00','2020-01-06 20:00:00',4,396),('2020-01-06 12:00:00','2020-01-06 20:00:00',28,171),('2020-01-07 12:00:00','2020-01-07 20:00:00',4,397),('2020-01-07 12:00:00','2020-01-07 20:00:00',28,175),('2020-01-08 12:00:00','2020-01-08 20:00:00',4,398),('2020-01-08 12:00:00','2020-01-08 20:00:00',28,175),('2020-01-09 12:00:00','2020-01-09 20:00:00',4,399),('2020-01-09 12:00:00','2020-01-09 20:00:00',28,175),('2020-01-10 12:00:00','2020-01-10 20:00:00',4,400),('2020-01-10 12:00:00','2020-01-10 20:00:00',28,70),('2020-01-11 12:00:00','2020-01-11 20:00:00',4,401),('2020-01-11 12:00:00','2020-01-11 20:00:00',28,71),('2020-01-12 12:00:00','2020-01-12 20:00:00',4,402),('2020-01-12 12:00:00','2020-01-12 20:00:00',28,71),('2020-01-13 12:00:00','2020-01-13 20:00:00',4,403),('2020-01-13 12:00:00','2020-01-13 20:00:00',28,71),('2020-01-14 12:00:00','2020-01-14 20:00:00',4,404),('2020-01-14 12:00:00','2020-01-14 20:00:00',28,71),('2020-01-15 12:00:00','2020-01-15 20:00:00',1,190),('2020-01-15 12:00:00','2020-01-15 20:00:00',4,405),('2020-01-15 12:00:00','2020-01-15 20:00:00',22,170),('2020-01-15 12:00:00','2020-01-15 20:00:00',28,71),('2020-01-16 12:00:00','2020-01-16 20:00:00',1,191),('2020-01-16 12:00:00','2020-01-16 20:00:00',4,406),('2020-01-16 12:00:00','2020-01-16 20:00:00',22,171),('2020-01-16 12:00:00','2020-01-16 20:00:00',28,71),('2020-01-17 12:00:00','2020-01-17 20:00:00',1,192),('2020-01-17 12:00:00','2020-01-17 20:00:00',4,407),('2020-01-17 12:00:00','2020-01-17 20:00:00',22,171),('2020-01-17 12:00:00','2020-01-17 20:00:00',28,77),('2020-01-18 12:00:00','2020-01-18 20:00:00',1,193),('2020-01-18 12:00:00','2020-01-18 20:00:00',4,408),('2020-01-18 12:00:00','2020-01-18 20:00:00',22,171),('2020-01-18 12:00:00','2020-01-18 20:00:00',28,77),('2020-01-19 12:00:00','2020-01-19 20:00:00',1,194),('2020-01-19 12:00:00','2020-01-19 20:00:00',4,409),('2020-01-19 12:00:00','2020-01-19 20:00:00',22,171),('2020-01-19 12:00:00','2020-01-19 20:00:00',28,77),('2020-01-20 12:00:00','2020-01-20 20:00:00',1,195),('2020-01-20 12:00:00','2020-01-20 20:00:00',4,410),('2020-01-20 12:00:00','2020-01-20 20:00:00',22,171),('2020-01-21 12:00:00','2020-01-21 20:00:00',1,196),('2020-01-21 12:00:00','2020-01-21 20:00:00',4,411),('2020-01-21 12:00:00','2020-01-21 20:00:00',22,171),('2020-01-21 12:00:00','2020-01-21 20:00:00',28,71),('2020-01-22 12:00:00','2020-01-22 20:00:00',1,197),('2020-01-22 12:00:00','2020-01-22 20:00:00',4,412),('2020-01-22 12:00:00','2020-01-22 20:00:00',22,175),('2020-01-22 12:00:00','2020-01-22 20:00:00',28,71),('2020-01-23 12:00:00','2020-01-23 20:00:00',1,198),('2020-01-23 12:00:00','2020-01-23 20:00:00',4,413),('2020-01-23 12:00:00','2020-01-23 20:00:00',22,175),('2020-01-23 12:00:00','2020-01-23 20:00:00',28,71),('2020-01-24 12:00:00','2020-01-24 20:00:00',1,199),('2020-01-24 12:00:00','2020-01-24 20:00:00',4,414),('2020-01-24 12:00:00','2020-01-24 20:00:00',22,175),('2020-01-24 12:00:00','2020-01-24 20:00:00',28,71),('2020-01-25 12:00:00','2020-01-25 20:00:00',1,200),('2020-01-25 12:00:00','2020-01-25 20:00:00',4,415),('2020-01-25 12:00:00','2020-01-25 20:00:00',22,70),('2020-01-25 12:00:00','2020-01-25 20:00:00',28,71),('2020-01-26 12:00:00','2020-01-26 20:00:00',1,201),('2020-01-26 12:00:00','2020-01-26 20:00:00',4,416),('2020-01-26 12:00:00','2020-01-26 20:00:00',22,71),('2020-01-26 12:00:00','2020-01-26 20:00:00',28,71),('2020-01-27 12:00:00','2020-01-27 20:00:00',1,202),('2020-01-27 12:00:00','2020-01-27 20:00:00',4,417),('2020-01-27 12:00:00','2020-01-27 20:00:00',22,71),('2020-01-27 12:00:00','2020-01-27 20:00:00',28,77),('2020-01-28 12:00:00','2020-01-28 20:00:00',1,203),('2020-01-28 12:00:00','2020-01-28 20:00:00',4,418),('2020-01-28 12:00:00','2020-01-28 20:00:00',22,71),('2020-01-28 12:00:00','2020-01-28 20:00:00',28,77),('2020-01-29 12:00:00','2020-01-29 20:00:00',1,204),('2020-01-29 12:00:00','2020-01-29 20:00:00',4,419),('2020-01-29 12:00:00','2020-01-29 20:00:00',22,71),('2020-01-29 12:00:00','2020-01-29 20:00:00',28,77),('2020-01-30 12:00:00','2020-01-30 20:00:00',1,205),('2020-01-30 12:00:00','2020-01-30 20:00:00',4,420),('2020-01-30 12:00:00','2020-01-30 20:00:00',22,71),('2020-01-31 12:00:00','2020-01-31 20:00:00',1,206),('2020-01-31 12:00:00','2020-01-31 20:00:00',22,71),('2020-02-01 12:00:00','2020-02-01 20:00:00',1,207),('2020-02-01 12:00:00','2020-02-01 20:00:00',22,77),('2020-02-02 12:00:00','2020-02-02 20:00:00',1,208),('2020-02-02 12:00:00','2020-02-02 20:00:00',22,77),('2020-02-03 12:00:00','2020-02-03 20:00:00',1,209),('2020-02-03 12:00:00','2020-02-03 20:00:00',22,77),('2020-02-04 12:00:00','2020-02-04 20:00:00',1,210),('2020-02-05 12:00:00','2020-02-05 20:00:00',1,211),('2020-02-05 12:00:00','2020-02-05 20:00:00',22,71),('2020-02-06 12:00:00','2020-02-06 20:00:00',1,212),('2020-02-06 12:00:00','2020-02-06 20:00:00',22,71),('2020-02-07 12:00:00','2020-02-07 20:00:00',1,213),('2020-02-07 12:00:00','2020-02-07 20:00:00',22,71),('2020-02-08 12:00:00','2020-02-08 20:00:00',1,214),('2020-02-08 12:00:00','2020-02-08 20:00:00',22,71),('2020-02-09 12:00:00','2020-02-09 20:00:00',1,215),('2020-02-09 12:00:00','2020-02-09 20:00:00',22,71),('2020-02-10 12:00:00','2020-02-10 20:00:00',1,216),('2020-02-10 12:00:00','2020-02-10 20:00:00',22,71),('2020-02-11 12:00:00','2020-02-11 20:00:00',1,217),('2020-02-11 12:00:00','2020-02-11 20:00:00',22,77),('2020-02-12 12:00:00','2020-02-12 20:00:00',1,218),('2020-02-12 12:00:00','2020-02-12 20:00:00',22,77),('2020-02-13 12:00:00','2020-02-13 20:00:00',1,219),('2020-02-13 12:00:00','2020-02-13 20:00:00',22,77),('2020-05-04 12:00:00','2020-05-04 20:00:00',3,122),('2020-05-04 12:00:00','2020-05-04 20:00:00',11,71),('2020-05-05 12:00:00','2020-05-05 20:00:00',3,123),('2020-05-05 12:00:00','2020-05-05 20:00:00',11,71),('2020-05-06 12:00:00','2020-05-06 20:00:00',3,124),('2020-05-06 12:00:00','2020-05-06 20:00:00',11,71),('2020-05-07 12:00:00','2020-05-07 20:00:00',3,125),('2020-05-07 12:00:00','2020-05-07 20:00:00',11,71),('2020-05-08 08:00:00','2020-05-08 16:00:00',4,127),('2020-05-08 08:00:00','2020-05-08 16:00:00',8,77),('2020-05-08 12:00:00','2020-05-08 20:00:00',3,126),('2020-05-08 12:00:00','2020-05-08 20:00:00',11,71),('2020-05-09 08:00:00','2020-05-09 16:00:00',4,77),('2020-05-09 08:00:00','2020-05-09 16:00:00',8,77),('2020-05-10 08:00:00','2020-05-10 16:00:00',4,77),('2020-05-10 08:00:00','2020-05-10 16:00:00',8,77),('2020-05-12 08:00:00','2020-05-12 16:00:00',4,71),('2020-05-12 08:00:00','2020-05-12 16:00:00',8,71),('2020-05-13 08:00:00','2020-05-13 16:00:00',4,71),('2020-05-13 08:00:00','2020-05-13 16:00:00',8,71),('2020-05-14 08:00:00','2020-05-14 16:00:00',4,133),('2020-05-14 08:00:00','2020-05-14 16:00:00',8,71),('2020-05-15 08:00:00','2020-05-15 16:00:00',4,71),('2020-05-15 08:00:00','2020-05-15 16:00:00',8,71),('2020-05-16 08:00:00','2020-05-16 16:00:00',4,71),('2020-05-16 08:00:00','2020-05-16 16:00:00',8,71),('2020-05-17 08:00:00','2020-05-17 16:00:00',4,71),('2020-05-17 08:00:00','2020-05-17 16:00:00',8,71),('2020-05-18 08:00:00','2020-05-18 16:00:00',4,77),('2020-05-18 08:00:00','2020-05-18 16:00:00',8,77),('2020-05-19 08:00:00','2020-05-19 16:00:00',4,77),('2020-05-19 08:00:00','2020-05-19 16:00:00',8,77),('2020-05-20 08:00:00','2020-05-20 16:00:00',4,139),('2020-05-20 08:00:00','2020-05-20 16:00:00',8,77),('2020-05-22 08:00:00','2020-05-22 16:00:00',4,71),('2020-05-22 08:00:00','2020-05-22 16:00:00',8,71),('2020-07-03 08:00:00','2020-07-03 16:00:00',5,481),('2020-07-04 08:00:00','2020-07-04 16:00:00',5,482),('2020-08-07 08:00:00','2020-08-07 16:00:00',3,439),('2020-08-07 08:00:00','2020-08-07 16:00:00',7,77),('2020-10-12 08:00:00','2020-10-12 16:00:00',2,461),('2020-10-12 08:00:00','2020-10-12 16:00:00',19,71),('2020-10-13 08:00:00','2020-10-13 16:00:00',2,462),('2020-10-13 08:00:00','2020-10-13 16:00:00',19,71),('2020-10-14 08:00:00','2020-10-14 16:00:00',2,463),('2020-10-14 08:00:00','2020-10-14 16:00:00',19,71),('2020-10-15 08:00:00','2020-10-15 16:00:00',2,464),('2020-10-15 08:00:00','2020-10-15 16:00:00',19,71),('2020-10-16 08:00:00','2020-10-16 16:00:00',2,465),('2020-10-16 08:00:00','2020-10-16 16:00:00',19,71),('2020-10-17 08:00:00','2020-10-17 16:00:00',2,466),('2020-10-17 08:00:00','2020-10-17 16:00:00',19,71),('2020-11-22 08:00:00','2020-11-22 16:00:00',2,7),('2020-11-22 08:00:00','2020-11-22 16:00:00',19,7),('2020-11-22 08:00:00','2020-11-22 16:00:00',21,7),('2020-11-23 08:00:00','2020-11-23 16:00:00',2,31),('2020-11-23 08:00:00','2020-11-23 16:00:00',19,7),('2020-11-23 08:00:00','2020-11-23 16:00:00',21,7),('2020-11-24 08:00:00','2020-11-24 16:00:00',2,7),('2020-11-24 08:00:00','2020-11-24 16:00:00',19,7),('2020-11-24 08:00:00','2020-11-24 16:00:00',21,7),('2020-11-25 08:00:00','2020-11-25 16:00:00',2,7),('2020-11-25 08:00:00','2020-11-25 16:00:00',19,7),('2020-11-25 08:00:00','2020-11-25 16:00:00',21,7),('2020-11-26 08:00:00','2020-11-26 16:00:00',2,7),('2020-11-26 08:00:00','2020-11-26 16:00:00',19,7),('2020-11-26 08:00:00','2020-11-26 16:00:00',21,7),('2020-11-27 08:00:00','2020-11-27 16:00:00',2,7),('2020-11-27 08:00:00','2020-11-27 16:00:00',19,7),('2020-11-27 08:00:00','2020-11-27 16:00:00',21,7),('2020-11-28 08:00:00','2020-11-28 16:00:00',2,7),('2020-11-28 08:00:00','2020-11-28 16:00:00',19,7),('2020-11-28 08:00:00','2020-11-28 16:00:00',21,7),('2020-11-29 08:00:00','2020-11-29 16:00:00',2,37),('2020-12-02 08:00:00','2020-12-02 16:00:00',2,7),('2020-12-02 08:00:00','2020-12-02 16:00:00',19,7),('2020-12-02 08:00:00','2020-12-02 16:00:00',21,7),('2020-12-03 08:00:00','2020-12-03 16:00:00',2,7),('2020-12-03 08:00:00','2020-12-03 16:00:00',19,7),('2020-12-03 08:00:00','2020-12-03 16:00:00',21,7),('2020-12-04 08:00:00','2020-12-04 16:00:00',2,7),('2020-12-04 08:00:00','2020-12-04 16:00:00',19,7),('2020-12-04 08:00:00','2020-12-04 16:00:00',21,7),('2020-12-10 08:00:00','2020-12-10 16:00:00',4,71),('2020-12-10 08:00:00','2020-12-10 16:00:00',8,71),('2020-12-11 08:00:00','2020-12-11 16:00:00',4,71),('2020-12-11 08:00:00','2020-12-11 16:00:00',8,71),('2020-12-12 08:00:00','2020-12-12 16:00:00',4,71),('2020-12-12 08:00:00','2020-12-12 16:00:00',8,71),('2020-12-13 08:00:00','2020-12-13 16:00:00',4,145),('2020-12-13 08:00:00','2020-12-13 16:00:00',8,71),('2020-12-14 08:00:00','2020-12-14 16:00:00',4,71),('2020-12-14 08:00:00','2020-12-14 16:00:00',8,71),('2020-12-15 08:00:00','2020-12-15 16:00:00',4,77),('2020-12-15 08:00:00','2020-12-15 16:00:00',8,77),('2020-12-16 08:00:00','2020-12-16 16:00:00',4,77),('2020-12-16 08:00:00','2020-12-16 16:00:00',8,77),('2020-12-17 08:00:00','2020-12-17 16:00:00',4,77),('2020-12-17 08:00:00','2020-12-17 16:00:00',8,77),('2020-12-18 12:00:00','2020-12-18 20:00:00',1,151),('2020-12-18 12:00:00','2020-12-18 20:00:00',20,71),('2020-12-19 12:00:00','2020-12-19 20:00:00',1,152),('2020-12-19 12:00:00','2020-12-19 20:00:00',20,71),('2020-12-20 12:00:00','2020-12-20 20:00:00',1,153),('2020-12-20 12:00:00','2020-12-20 20:00:00',20,71),('2020-12-21 12:00:00','2020-12-21 20:00:00',1,154),('2020-12-21 12:00:00','2020-12-21 20:00:00',20,71),('2020-12-22 12:00:00','2020-12-22 20:00:00',1,155),('2020-12-22 12:00:00','2020-12-22 20:00:00',20,71),('2020-12-23 12:00:00','2020-12-23 20:00:00',1,156),('2020-12-23 12:00:00','2020-12-23 20:00:00',20,71),('2020-12-24 12:00:00','2020-12-24 20:00:00',1,157),('2020-12-24 12:00:00','2020-12-24 20:00:00',20,77),('2020-12-25 12:00:00','2020-12-25 20:00:00',1,158),('2020-12-25 12:00:00','2020-12-25 20:00:00',20,77),('2020-12-26 12:00:00','2020-12-26 20:00:00',1,159),('2020-12-26 12:00:00','2020-12-26 20:00:00',20,77),('2020-12-27 12:00:00','2020-12-27 20:00:00',1,160),('2020-12-28 12:00:00','2020-12-28 20:00:00',1,161),('2020-12-28 12:00:00','2020-12-28 20:00:00',20,71),('2020-12-29 12:00:00','2020-12-29 20:00:00',1,162),('2020-12-29 12:00:00','2020-12-29 20:00:00',20,71),('2020-12-30 08:00:00','2020-12-30 11:00:00',1,167),('2020-12-30 12:00:00','2020-12-30 20:00:00',1,163),('2020-12-31 08:00:00','2020-12-31 11:00:00',1,168),('2020-12-31 12:00:00','2020-12-31 20:00:00',1,164),('2021-01-01 08:00:00','2021-01-01 11:00:00',1,169),('2021-01-01 12:00:00','2021-01-01 20:00:00',1,165),('2021-01-02 08:00:00','2021-01-02 11:00:00',1,170),('2021-01-02 12:00:00','2021-01-02 20:00:00',1,166),('2021-01-14 08:00:00','2021-08-07 16:00:00',3,440),('2021-01-14 12:00:00','2021-01-14 20:00:00',1,441),('2021-01-14 12:00:00','2021-01-14 20:00:00',15,71),('2021-01-15 12:00:00','2021-01-15 20:00:00',1,442),('2021-01-15 12:00:00','2021-01-15 20:00:00',15,71),('2021-01-16 12:00:00','2021-01-16 20:00:00',1,443),('2021-01-16 12:00:00','2021-01-16 20:00:00',15,71),('2021-01-17 12:00:00','2021-01-17 20:00:00',1,444),('2021-01-17 12:00:00','2021-01-17 20:00:00',15,71),('2021-01-18 12:00:00','2021-01-18 20:00:00',1,445),('2021-01-18 12:00:00','2021-01-18 20:00:00',15,71),('2021-01-19 12:00:00','2021-01-19 20:00:00',1,446),('2021-01-19 12:00:00','2021-01-19 20:00:00',15,71),('2021-03-31 08:00:00','2021-03-31 16:00:00',1,499),('2021-03-31 08:00:00','2021-03-31 16:00:00',5,483),('2021-03-31 08:00:00','2021-03-31 16:00:00',16,175),('2021-03-31 12:00:00','2021-03-31 20:00:00',6,484),('2021-03-31 12:00:00','2021-03-31 20:00:00',14,171),('2021-04-01 08:00:00','2021-04-01 16:00:00',1,70),('2021-04-01 08:00:00','2021-04-01 16:00:00',16,70),('2021-04-01 12:00:00','2021-04-01 20:00:00',6,485),('2021-04-01 12:00:00','2021-04-01 20:00:00',14,171),('2021-04-02 08:00:00','2021-04-02 16:00:00',1,71),('2021-04-02 08:00:00','2021-04-02 16:00:00',16,71),('2021-04-02 12:00:00','2021-04-02 20:00:00',6,486),('2021-04-02 12:00:00','2021-04-02 20:00:00',14,171),('2021-04-03 08:00:00','2021-04-03 16:00:00',1,71),('2021-04-03 08:00:00','2021-04-03 16:00:00',16,71),('2021-04-03 12:00:00','2021-04-03 20:00:00',6,487),('2021-04-03 12:00:00','2021-04-03 20:00:00',14,175),('2021-04-04 08:00:00','2021-04-04 16:00:00',1,71),('2021-04-04 08:00:00','2021-04-04 16:00:00',16,71),('2021-04-04 12:00:00','2021-04-04 20:00:00',6,488),('2021-04-04 12:00:00','2021-04-04 20:00:00',14,175),('2021-04-05 08:00:00','2021-04-05 16:00:00',1,71),('2021-04-05 08:00:00','2021-04-05 16:00:00',16,71),('2021-04-05 12:00:00','2021-04-05 20:00:00',6,489),('2021-04-05 12:00:00','2021-04-05 20:00:00',14,175),('2021-04-06 08:00:00','2021-04-06 16:00:00',1,505),('2021-04-06 08:00:00','2021-04-06 16:00:00',16,71),('2021-04-06 12:00:00','2021-04-06 20:00:00',6,490),('2021-04-06 12:00:00','2021-04-06 20:00:00',14,170),('2021-04-07 08:00:00','2021-04-07 16:00:00',1,71),('2021-04-07 08:00:00','2021-04-07 16:00:00',16,71),('2021-04-07 12:00:00','2021-04-07 20:00:00',6,491),('2021-04-07 12:00:00','2021-04-07 20:00:00',14,171),('2021-04-08 08:00:00','2021-04-08 16:00:00',1,77),('2021-04-08 08:00:00','2021-04-08 16:00:00',16,77),('2021-04-09 08:00:00','2021-04-09 16:00:00',1,77),('2021-04-09 08:00:00','2021-04-09 16:00:00',16,77),('2021-04-10 08:00:00','2021-04-10 16:00:00',1,77),('2021-04-10 08:00:00','2021-04-10 16:00:00',16,77),('2021-06-03 08:00:00','2021-06-03 16:00:00',3,174),('2021-06-03 08:00:00','2021-06-03 16:00:00',9,171),('2021-06-03 15:00:00','2021-06-03 21:00:00',4,175),('2021-06-03 15:00:00','2021-06-03 21:00:00',18,171),('2021-06-04 15:00:00','2021-06-04 21:00:00',4,171),('2021-06-04 15:00:00','2021-06-04 21:00:00',18,171),('2021-06-05 15:00:00','2021-06-05 21:00:00',4,175),('2021-06-05 15:00:00','2021-06-05 21:00:00',18,175),('2021-09-03 08:00:00','2021-09-03 16:00:00',3,174),('2021-09-03 08:00:00','2021-09-03 16:00:00',9,171),('2021-09-04 08:00:00','2021-09-04 16:00:00',4,532),('2021-09-04 08:00:00','2021-09-04 16:00:00',8,71),('2021-09-05 08:00:00','2021-09-05 16:00:00',4,474),('2021-09-05 08:00:00','2021-09-05 16:00:00',8,71),('2021-09-05 08:00:00','2021-09-05 16:00:00',18,171),('2021-09-05 12:00:00','2021-09-05 20:00:00',3,467),('2021-09-05 12:00:00','2021-09-05 20:00:00',11,77),('2021-09-06 08:00:00','2021-09-06 16:00:00',4,475),('2021-09-06 08:00:00','2021-09-06 16:00:00',8,71),('2021-09-06 08:00:00','2021-09-06 16:00:00',18,171),('2021-09-06 12:00:00','2021-09-06 20:00:00',3,468),('2021-09-06 12:00:00','2021-09-06 20:00:00',11,77),('2021-09-07 08:00:00','2021-09-07 16:00:00',4,476),('2021-09-07 08:00:00','2021-09-07 16:00:00',8,71),('2021-09-07 08:00:00','2021-09-07 16:00:00',18,171),('2021-09-07 12:00:00','2021-09-07 20:00:00',3,469),('2021-09-07 12:00:00','2021-09-07 20:00:00',11,77),('2021-09-08 08:00:00','2021-09-08 16:00:00',4,477),('2021-09-08 08:00:00','2021-09-08 16:00:00',8,71),('2021-09-08 08:00:00','2021-09-08 16:00:00',18,175),('2021-09-08 12:00:00','2021-09-08 20:00:00',3,470),('2021-09-08 12:00:00','2021-09-08 20:00:00',11,170),('2021-09-09 08:00:00','2021-09-09 16:00:00',4,478),('2021-09-09 08:00:00','2021-09-09 16:00:00',8,77),('2021-09-09 08:00:00','2021-09-09 16:00:00',18,175),('2021-09-09 12:00:00','2021-09-09 20:00:00',3,471),('2021-09-09 12:00:00','2021-09-09 20:00:00',11,171),('2021-09-10 08:00:00','2021-09-10 16:00:00',4,479),('2021-09-10 08:00:00','2021-09-10 16:00:00',18,175),('2021-09-10 12:00:00','2021-09-10 20:00:00',3,472),('2021-09-10 12:00:00','2021-09-10 20:00:00',11,171),('2021-09-11 08:00:00','2021-09-11 16:00:00',4,480),('2021-09-11 08:00:00','2021-09-11 16:00:00',18,170),('2021-09-11 12:00:00','2021-09-11 20:00:00',3,473),('2021-09-11 12:00:00','2021-09-11 20:00:00',11,171),('2021-09-28 08:00:00','2021-09-20 16:00:00',6,428),('2022-01-14 08:00:00','2022-01-14 16:00:00',6,66),('2022-01-14 08:00:00','2022-01-14 16:00:00',10,7),('2022-01-15 08:00:00','2022-01-15 16:00:00',6,67),('2022-01-16 08:00:00','2022-01-16 16:00:00',6,68),('2022-01-17 08:00:00','2022-01-17 16:00:00',6,69),('2022-01-18 08:00:00','2022-01-18 16:00:00',6,70),('2022-01-18 08:00:00','2022-01-18 16:00:00',10,70),('2022-01-19 08:00:00','2022-01-19 16:00:00',6,71),('2022-01-19 08:00:00','2022-01-19 16:00:00',10,71),('2022-01-20 08:00:00','2022-01-20 16:00:00',5,73),('2022-01-20 08:00:00','2022-01-20 16:00:00',6,72),('2022-01-20 08:00:00','2022-01-20 16:00:00',10,71),('2022-01-20 17:00:00','2022-01-20 20:00:00',5,89),('2022-01-21 08:00:00','2022-01-21 16:00:00',5,74),('2022-01-21 17:00:00','2022-01-21 20:00:00',5,90),('2022-01-22 08:00:00','2022-01-22 16:00:00',5,75),('2022-01-22 17:00:00','2022-01-22 20:00:00',5,91),('2022-01-23 08:00:00','2022-01-23 16:00:00',5,76),('2022-01-23 17:00:00','2022-01-23 20:00:00',5,92),('2022-01-24 08:00:00','2022-01-24 16:00:00',5,77),('2022-01-24 17:00:00','2022-01-24 20:00:00',5,93),('2022-01-25 08:00:00','2022-01-25 16:00:00',5,78),('2022-01-25 17:00:00','2022-01-25 20:00:00',5,94),('2022-01-26 08:00:00','2022-01-26 16:00:00',5,79),('2022-01-26 17:00:00','2022-01-26 20:00:00',5,95),('2022-01-27 08:00:00','2022-01-27 16:00:00',5,80),('2022-01-27 17:00:00','2022-01-27 20:00:00',5,96),('2022-01-28 08:00:00','2022-01-28 16:00:00',5,81),('2022-01-28 17:00:00','2022-01-28 20:00:00',5,97),('2022-01-29 08:00:00','2022-01-29 16:00:00',5,82),('2022-01-29 17:00:00','2022-01-29 20:00:00',5,98),('2022-01-30 08:00:00','2022-01-30 16:00:00',5,83),('2022-01-30 17:00:00','2022-01-30 20:00:00',5,99),('2022-01-31 08:00:00','2022-01-31 16:00:00',5,84),('2022-01-31 17:00:00','2022-01-31 20:00:00',5,100),('2022-02-01 08:00:00','2022-02-01 16:00:00',5,85),('2022-02-02 08:00:00','2022-02-02 16:00:00',5,86),('2022-02-03 08:00:00','2022-02-03 16:00:00',5,87),('2022-02-03 15:00:00','2022-02-03 20:00:00',5,101),('2022-02-04 08:00:00','2022-02-04 16:00:00',5,88),('2022-02-04 15:00:00','2022-02-04 20:00:00',5,102),('2022-04-09 08:00:00','2022-04-09 16:00:00',3,429),('2022-04-09 08:00:00','2022-04-09 16:00:00',6,428),('2022-04-09 08:00:00','2022-04-09 16:00:00',13,77),('2022-04-09 08:00:00','2022-04-09 16:00:00',14,77),('2022-04-10 08:00:00','2022-04-10 16:00:00',3,430),('2022-04-11 08:00:00','2022-04-11 16:00:00',3,431),('2022-04-11 08:00:00','2022-04-11 16:00:00',13,71),('2022-07-16 08:00:00','2022-07-16 16:00:00',3,517),('2022-07-16 08:00:00','2022-07-16 16:00:00',13,77),('2022-07-17 08:00:00','2022-07-17 16:00:00',3,518),('2022-07-17 08:00:00','2022-07-17 16:00:00',13,77),('2022-07-18 08:00:00','2022-07-18 16:00:00',3,519),('2022-07-18 08:00:00','2022-07-18 16:00:00',13,77),('2022-07-19 08:00:00','2022-07-19 16:00:00',3,520),('2022-07-20 08:00:00','2022-07-20 16:00:00',3,521),('2022-07-20 08:00:00','2022-07-20 16:00:00',13,71),('2022-07-21 08:00:00','2022-07-21 16:00:00',3,522),('2022-07-21 08:00:00','2022-07-21 16:00:00',13,71),('2022-07-22 08:00:00','2022-07-22 16:00:00',3,523),('2022-07-22 08:00:00','2022-07-22 16:00:00',13,71),('2022-07-23 08:00:00','2022-07-23 16:00:00',3,524),('2022-07-23 08:00:00','2022-07-23 16:00:00',13,71),('2022-07-24 08:00:00','2022-07-24 16:00:00',3,525),('2022-07-24 08:00:00','2022-07-24 16:00:00',13,71),('2022-07-25 08:00:00','2022-07-25 16:00:00',3,526),('2022-07-25 08:00:00','2022-07-25 16:00:00',13,71),('2022-07-26 08:00:00','2022-07-26 16:00:00',3,527),('2022-07-26 08:00:00','2022-07-26 16:00:00',13,77),('2022-07-27 08:00:00','2022-07-27 16:00:00',3,528),('2022-07-27 08:00:00','2022-07-27 16:00:00',13,77),('2022-07-28 08:00:00','2022-07-28 16:00:00',3,529),('2022-07-28 08:00:00','2022-07-28 16:00:00',13,77),('2022-07-29 08:00:00','2022-07-29 16:00:00',3,530),('2022-07-30 08:00:00','2022-07-30 16:00:00',3,531),('2022-07-30 08:00:00','2022-07-30 16:00:00',13,71),('2022-08-11 08:00:00','2022-08-11 16:00:00',4,538),('2022-08-11 08:00:00','2022-08-11 16:00:00',8,77),('2022-08-12 08:00:00','2022-08-12 16:00:00',4,539),('2022-08-12 08:00:00','2022-08-12 16:00:00',8,77),('2022-08-13 08:00:00','2022-08-13 16:00:00',1,640),('2022-08-13 08:00:00','2022-08-13 16:00:00',4,540),('2022-08-13 08:00:00','2022-08-13 16:00:00',5,541),('2022-08-13 08:00:00','2022-08-13 16:00:00',6,586),('2022-08-13 08:00:00','2022-08-13 16:00:00',25,171),('2022-08-14 08:00:00','2022-08-14 16:00:00',1,641),('2022-08-14 08:00:00','2022-08-14 16:00:00',5,542),('2022-08-14 08:00:00','2022-08-14 16:00:00',6,175),('2022-08-14 08:00:00','2022-08-14 16:00:00',17,71),('2022-08-14 08:00:00','2022-08-14 16:00:00',25,175),('2022-08-15 08:00:00','2022-08-15 16:00:00',1,642),('2022-08-15 08:00:00','2022-08-15 16:00:00',5,543),('2022-08-15 08:00:00','2022-08-15 16:00:00',6,175),('2022-08-15 08:00:00','2022-08-15 16:00:00',17,71),('2022-08-15 08:00:00','2022-08-15 16:00:00',25,175),('2022-08-16 08:00:00','2022-08-16 16:00:00',1,643),('2022-08-16 08:00:00','2022-08-16 16:00:00',5,544),('2022-08-16 08:00:00','2022-08-16 16:00:00',6,175),('2022-08-16 08:00:00','2022-08-16 16:00:00',17,71),('2022-08-16 08:00:00','2022-08-16 16:00:00',25,175),('2022-08-17 08:00:00','2022-08-17 16:00:00',1,644),('2022-08-17 08:00:00','2022-08-17 16:00:00',5,545),('2022-08-17 08:00:00','2022-08-17 16:00:00',6,170),('2022-08-17 08:00:00','2022-08-17 16:00:00',17,71),('2022-08-17 08:00:00','2022-08-17 16:00:00',25,170),('2022-08-18 08:00:00','2022-08-18 16:00:00',1,645),('2022-08-18 08:00:00','2022-08-18 16:00:00',5,546),('2022-08-18 08:00:00','2022-08-18 16:00:00',6,171),('2022-08-18 08:00:00','2022-08-18 16:00:00',17,71),('2022-08-18 08:00:00','2022-08-18 16:00:00',25,171),('2022-08-19 08:00:00','2022-08-19 16:00:00',1,646),('2022-08-19 08:00:00','2022-08-19 16:00:00',5,547),('2022-08-19 08:00:00','2022-08-19 16:00:00',6,592),('2022-08-19 08:00:00','2022-08-19 16:00:00',17,71),('2022-08-19 08:00:00','2022-08-19 16:00:00',25,171),('2022-08-20 08:00:00','2022-08-20 16:00:00',1,647),('2022-08-20 08:00:00','2022-08-20 16:00:00',5,548),('2022-08-20 08:00:00','2022-08-20 16:00:00',6,171),('2022-08-20 08:00:00','2022-08-20 16:00:00',17,77),('2022-08-20 08:00:00','2022-08-20 16:00:00',25,171),('2022-08-21 08:00:00','2022-08-21 16:00:00',1,648),('2022-08-21 08:00:00','2022-08-21 16:00:00',5,549),('2022-08-21 08:00:00','2022-08-21 16:00:00',6,171),('2022-08-21 08:00:00','2022-08-21 16:00:00',17,77),('2022-08-21 08:00:00','2022-08-21 16:00:00',25,171),('2022-08-22 08:00:00','2022-08-22 16:00:00',1,649),('2022-08-22 08:00:00','2022-08-22 16:00:00',5,550),('2022-08-22 08:00:00','2022-08-22 16:00:00',6,171),('2022-08-22 08:00:00','2022-08-22 16:00:00',17,77),('2022-08-22 08:00:00','2022-08-22 16:00:00',25,171),('2022-08-23 08:00:00','2022-08-23 16:00:00',1,650),('2022-08-23 08:00:00','2022-08-23 16:00:00',5,551),('2022-08-23 08:00:00','2022-08-23 16:00:00',6,171),('2022-08-23 08:00:00','2022-08-23 16:00:00',25,171),('2022-08-24 08:00:00','2022-08-24 16:00:00',1,651),('2022-08-24 08:00:00','2022-08-24 16:00:00',5,552),('2022-08-24 08:00:00','2022-08-24 16:00:00',6,175),('2022-08-24 08:00:00','2022-08-24 16:00:00',17,71),('2022-08-24 08:00:00','2022-08-24 16:00:00',25,175),('2022-08-25 08:00:00','2022-08-25 16:00:00',1,652),('2022-08-25 08:00:00','2022-08-25 16:00:00',5,553),('2022-08-25 08:00:00','2022-08-25 16:00:00',6,598),('2022-08-25 08:00:00','2022-08-25 16:00:00',17,71),('2022-08-25 08:00:00','2022-08-25 16:00:00',25,175),('2022-08-26 08:00:00','2022-08-26 16:00:00',1,653),('2022-08-26 08:00:00','2022-08-26 16:00:00',5,554),('2022-08-26 08:00:00','2022-08-26 16:00:00',6,175),('2022-08-26 08:00:00','2022-08-26 16:00:00',17,71),('2022-08-26 08:00:00','2022-08-26 16:00:00',25,175),('2022-08-27 08:00:00','2022-08-27 16:00:00',1,654),('2022-08-27 08:00:00','2022-08-27 16:00:00',5,555),('2022-08-27 08:00:00','2022-08-27 16:00:00',6,70),('2022-08-27 08:00:00','2022-08-27 16:00:00',17,71),('2022-08-27 08:00:00','2022-08-27 16:00:00',25,70),('2022-08-28 08:00:00','2022-08-28 16:00:00',1,655),('2022-08-28 08:00:00','2022-08-28 16:00:00',5,556),('2022-08-28 08:00:00','2022-08-28 16:00:00',6,71),('2022-08-28 08:00:00','2022-08-28 16:00:00',17,71),('2022-08-28 08:00:00','2022-08-28 16:00:00',25,71),('2022-08-29 08:00:00','2022-08-29 16:00:00',1,656),('2022-08-29 08:00:00','2022-08-29 16:00:00',5,557),('2022-08-29 08:00:00','2022-08-29 16:00:00',6,71),('2022-08-29 08:00:00','2022-08-29 16:00:00',17,71),('2022-08-29 08:00:00','2022-08-29 16:00:00',25,71),('2022-08-30 08:00:00','2022-08-30 16:00:00',1,657),('2022-08-30 08:00:00','2022-08-30 16:00:00',5,558),('2022-08-30 08:00:00','2022-08-30 16:00:00',6,71),('2022-08-30 08:00:00','2022-08-30 16:00:00',17,77),('2022-08-30 08:00:00','2022-08-30 16:00:00',25,71),('2022-08-31 08:00:00','2022-08-31 16:00:00',1,658),('2022-08-31 08:00:00','2022-08-31 16:00:00',5,559),('2022-08-31 08:00:00','2022-08-31 16:00:00',6,604),('2022-08-31 08:00:00','2022-08-31 16:00:00',17,77),('2022-08-31 08:00:00','2022-08-31 16:00:00',25,71),('2022-09-01 08:00:00','2022-09-01 16:00:00',1,659),('2022-09-01 08:00:00','2022-09-01 16:00:00',5,560),('2022-09-01 08:00:00','2022-09-01 16:00:00',6,71),('2022-09-01 08:00:00','2022-09-01 16:00:00',17,77),('2022-09-01 08:00:00','2022-09-01 16:00:00',25,71),('2022-09-02 08:00:00','2022-09-02 16:00:00',1,660),('2022-09-02 08:00:00','2022-09-02 16:00:00',5,561),('2022-09-02 08:00:00','2022-09-02 16:00:00',6,71),('2022-09-02 08:00:00','2022-09-02 16:00:00',25,71),('2022-09-02 15:00:00','2022-09-02 21:00:00',4,175),('2022-09-02 15:00:00','2022-09-02 21:00:00',18,175),('2022-09-03 08:00:00','2022-09-03 16:00:00',1,661),('2022-09-03 08:00:00','2022-09-03 16:00:00',5,562),('2022-09-03 08:00:00','2022-09-03 16:00:00',6,180),('2022-09-03 08:00:00','2022-09-03 16:00:00',17,71),('2022-09-03 08:00:00','2022-09-03 16:00:00',25,170),('2022-09-03 15:00:00','2022-09-03 21:00:00',4,175),('2022-09-03 15:00:00','2022-09-03 21:00:00',18,175),('2022-09-04 08:00:00','2022-09-04 16:00:00',1,662),('2022-09-04 08:00:00','2022-09-04 16:00:00',5,563),('2022-09-04 08:00:00','2022-09-03 16:00:00',6,181),('2022-09-04 08:00:00','2022-09-04 16:00:00',17,71),('2022-09-05 08:00:00','2022-09-05 16:00:00',1,663),('2022-09-05 08:00:00','2022-09-05 16:00:00',5,564),('2022-09-05 08:00:00','2022-09-03 16:00:00',6,182),('2022-09-05 08:00:00','2022-09-05 16:00:00',17,71),('2022-09-06 08:00:00','2022-09-06 16:00:00',1,664),('2022-09-06 08:00:00','2022-09-06 16:00:00',5,565),('2022-09-06 08:00:00','2022-09-06 16:00:00',6,610),('2022-09-06 08:00:00','2022-09-06 16:00:00',17,71),('2022-09-07 08:00:00','2022-09-07 16:00:00',1,665),('2022-09-07 08:00:00','2022-09-07 16:00:00',5,566),('2022-09-07 08:00:00','2022-09-07 16:00:00',6,71),('2022-09-07 08:00:00','2022-09-07 16:00:00',17,71),('2022-09-07 08:00:00','2022-09-07 16:00:00',25,71),('2022-09-08 08:00:00','2022-09-08 16:00:00',1,666),('2022-09-08 08:00:00','2022-09-08 16:00:00',5,567),('2022-09-08 08:00:00','2022-09-08 16:00:00',6,71),('2022-09-08 08:00:00','2022-09-08 16:00:00',17,71),('2022-09-08 08:00:00','2022-09-08 16:00:00',25,71),('2022-09-09 08:00:00','2022-09-09 16:00:00',1,667),('2022-09-09 08:00:00','2022-09-09 16:00:00',5,568),('2022-09-09 08:00:00','2022-09-09 16:00:00',6,71),('2022-09-09 08:00:00','2022-09-09 16:00:00',17,77),('2022-09-09 08:00:00','2022-09-09 16:00:00',25,71),('2022-09-10 08:00:00','2022-09-10 16:00:00',1,668),('2022-09-10 08:00:00','2022-09-10 16:00:00',5,569),('2022-09-10 08:00:00','2022-09-10 16:00:00',6,71),('2022-09-10 08:00:00','2022-09-10 16:00:00',17,77),('2022-09-10 08:00:00','2022-09-10 16:00:00',25,71),('2022-09-11 08:00:00','2022-09-11 16:00:00',1,669),('2022-09-11 08:00:00','2022-09-11 16:00:00',5,570),('2022-09-11 08:00:00','2022-09-11 16:00:00',6,71),('2022-09-11 08:00:00','2022-09-11 16:00:00',17,77),('2022-09-11 08:00:00','2022-09-11 16:00:00',25,71),('2022-09-12 08:00:00','2022-09-12 16:00:00',1,670),('2022-09-12 08:00:00','2022-09-12 16:00:00',5,571),('2022-09-12 08:00:00','2022-09-12 16:00:00',6,616),('2022-09-12 08:00:00','2022-09-12 16:00:00',17,170),('2022-09-12 08:00:00','2022-09-12 16:00:00',25,71),('2022-09-13 08:00:00','2022-09-13 16:00:00',1,671),('2022-09-13 08:00:00','2022-09-13 16:00:00',5,572),('2022-09-13 08:00:00','2022-09-13 16:00:00',6,77),('2022-09-13 08:00:00','2022-09-13 16:00:00',17,171),('2022-09-13 08:00:00','2022-09-13 16:00:00',25,77),('2022-09-14 08:00:00','2022-09-14 16:00:00',1,672),('2022-09-14 08:00:00','2022-09-14 16:00:00',5,573),('2022-09-14 08:00:00','2022-09-14 16:00:00',6,77),('2022-09-14 08:00:00','2022-09-14 16:00:00',17,171),('2022-09-14 08:00:00','2022-09-14 16:00:00',25,77),('2022-09-15 08:00:00','2022-09-15 16:00:00',1,673),('2022-09-15 08:00:00','2022-09-15 16:00:00',5,574),('2022-09-15 08:00:00','2022-09-15 16:00:00',6,77),('2022-09-15 08:00:00','2022-09-15 16:00:00',17,171),('2022-09-15 08:00:00','2022-09-15 16:00:00',25,77),('2022-09-16 08:00:00','2022-09-16 16:00:00',1,674),('2022-09-16 08:00:00','2022-09-16 16:00:00',5,575),('2022-09-16 08:00:00','2022-09-16 16:00:00',17,171),('2022-09-17 08:00:00','2022-09-17 16:00:00',1,675),('2022-09-17 08:00:00','2022-09-17 16:00:00',5,576),('2022-09-17 08:00:00','2022-09-17 16:00:00',6,71),('2022-09-17 08:00:00','2022-09-17 16:00:00',17,171),('2022-09-17 08:00:00','2022-09-17 16:00:00',25,71),('2022-09-18 08:00:00','2022-09-18 16:00:00',1,676),('2022-09-18 08:00:00','2022-09-18 16:00:00',5,577),('2022-09-18 08:00:00','2022-09-18 16:00:00',6,622),('2022-09-18 08:00:00','2022-09-18 16:00:00',17,171),('2022-09-18 08:00:00','2022-09-18 16:00:00',25,71),('2022-09-19 08:00:00','2022-09-19 16:00:00',1,677),('2022-09-19 08:00:00','2022-09-19 16:00:00',5,578),('2022-09-19 08:00:00','2022-09-19 16:00:00',6,71),('2022-09-19 08:00:00','2022-09-19 16:00:00',17,175),('2022-09-19 08:00:00','2022-09-19 16:00:00',25,71),('2022-09-20 08:00:00','2022-09-20 16:00:00',1,678),('2022-09-20 08:00:00','2022-09-20 16:00:00',5,579),('2022-09-20 08:00:00','2022-09-20 16:00:00',6,71),('2022-09-20 08:00:00','2022-09-20 16:00:00',17,175),('2022-09-20 08:00:00','2022-09-20 16:00:00',25,71),('2022-09-21 08:00:00','2022-09-21 16:00:00',1,679),('2022-09-21 08:00:00','2022-09-21 16:00:00',5,580),('2022-09-21 08:00:00','2022-09-21 16:00:00',6,71),('2022-09-21 08:00:00','2022-09-21 16:00:00',17,175),('2022-09-21 08:00:00','2022-09-21 16:00:00',25,71),('2022-09-22 08:00:00','2022-09-22 16:00:00',1,680),('2022-09-22 08:00:00','2022-09-22 16:00:00',5,581),('2022-09-22 08:00:00','2022-09-22 16:00:00',6,71),('2022-09-22 08:00:00','2022-09-22 16:00:00',17,170),('2022-09-22 08:00:00','2022-09-22 16:00:00',25,71),('2022-09-23 08:00:00','2022-09-23 16:00:00',1,681),('2022-09-23 08:00:00','2022-09-23 16:00:00',6,77),('2022-09-23 08:00:00','2022-09-23 16:00:00',17,171),('2022-09-23 08:00:00','2022-09-23 16:00:00',25,77),('2022-09-24 08:00:00','2022-09-24 16:00:00',1,682),('2022-09-24 08:00:00','2022-09-24 16:00:00',6,628),('2022-09-24 08:00:00','2022-09-24 16:00:00',17,171),('2022-09-24 08:00:00','2022-09-24 16:00:00',25,77),('2022-09-25 08:00:00','2022-09-25 16:00:00',1,683),('2022-09-25 08:00:00','2022-09-25 16:00:00',6,77),('2022-09-25 08:00:00','2022-09-25 16:00:00',17,171),('2022-09-25 08:00:00','2022-09-25 16:00:00',25,77),('2022-09-26 08:00:00','2022-09-26 16:00:00',1,684),('2022-09-26 08:00:00','2022-09-26 16:00:00',17,171),('2022-09-27 08:00:00','2022-09-27 16:00:00',6,71),('2022-09-27 08:00:00','2022-09-27 16:00:00',25,71),('2022-09-28 08:00:00','2022-09-28 16:00:00',6,71),('2022-09-28 08:00:00','2022-09-28 16:00:00',25,71),('2022-09-29 08:00:00','2022-09-29 16:00:00',6,71),('2022-09-29 08:00:00','2022-09-29 16:00:00',25,71),('2022-09-30 08:00:00','2022-09-30 16:00:00',6,634),('2022-09-30 08:00:00','2022-09-30 16:00:00',25,71),('2022-10-01 08:00:00','2022-10-01 16:00:00',6,71),('2022-10-01 08:00:00','2022-10-01 16:00:00',25,71),('2022-10-02 08:00:00','2022-10-02 16:00:00',6,71),('2022-10-02 08:00:00','2022-10-02 16:00:00',25,71),('2022-10-03 08:00:00','2022-10-03 16:00:00',6,77),('2022-10-03 08:00:00','2022-10-03 16:00:00',25,77),('2022-10-03 12:00:00','2022-10-03 20:00:00',4,421),('2022-10-03 12:00:00','2022-10-03 20:00:00',28,71),('2022-10-04 08:00:00','2022-10-04 16:00:00',6,77),('2022-10-04 08:00:00','2022-10-04 16:00:00',25,77),('2022-10-04 12:00:00','2022-10-04 20:00:00',4,422),('2022-10-04 12:00:00','2022-10-04 20:00:00',28,71),('2022-10-05 08:00:00','2022-10-05 20:00:00',3,432),('2022-10-05 08:00:00','2022-10-05 16:00:00',6,77),('2022-10-05 08:00:00','2022-10-05 20:00:00',13,71),('2022-10-05 08:00:00','2022-10-05 16:00:00',25,77),('2022-10-05 12:00:00','2022-10-05 20:00:00',4,423),('2022-10-05 12:00:00','2022-10-05 20:00:00',28,71),('2022-10-06 08:00:00','2022-10-06 20:00:00',3,433),('2022-10-06 08:00:00','2022-10-06 16:00:00',4,434),('2022-10-06 08:00:00','2022-10-06 20:00:00',13,71),('2022-10-06 12:00:00','2022-10-06 20:00:00',4,424),('2022-10-07 08:00:00','2022-10-07 16:00:00',4,71),('2022-10-07 12:00:00','2022-10-07 20:00:00',4,425),('2022-10-08 08:00:00','2022-10-08 16:00:00',4,71),('2022-10-08 12:00:00','2022-10-08 20:00:00',4,426),('2022-10-09 08:00:00','2022-10-09 16:00:00',4,77),('2022-10-09 12:00:00','2022-10-09 20:00:00',4,427),('2022-10-10 08:00:00','2022-10-10 16:00:00',4,77),('2022-10-10 08:00:00','2022-10-10 16:00:00',12,77),('2022-10-31 08:00:00','2022-10-31 16:00:00',1,511),('2022-10-31 08:00:00','2022-10-31 16:00:00',16,71),('2022-11-01 08:00:00','2022-11-01 16:00:00',1,71),('2022-11-01 08:00:00','2022-11-01 16:00:00',16,71),('2022-11-02 08:00:00','2022-11-02 16:00:00',1,71),('2022-11-02 08:00:00','2022-11-02 16:00:00',16,71),('2022-11-03 08:00:00','2022-11-03 16:00:00',1,71),('2022-11-03 12:00:00','2022-11-03 20:00:00',1,447),('2022-11-04 08:00:00','2022-11-04 16:00:00',1,71),('2022-11-04 12:00:00','2022-11-04 20:00:00',1,448),('2022-11-05 08:00:00','2022-11-05 16:00:00',1,71),('2022-11-05 12:00:00','2022-11-05 20:00:00',1,449),('2022-11-05 15:00:00','2022-11-05 22:00:00',2,450),('2022-11-06 12:00:00','2022-04-07 20:00:00',6,492),('2022-11-06 15:00:00','2022-11-06 22:00:00',2,451),('2022-11-06 15:00:00','2022-11-06 22:00:00',21,71),('2022-11-07 12:00:00','2022-04-08 20:00:00',6,493),('2022-11-07 15:00:00','2022-11-07 22:00:00',2,71),('2022-11-07 15:00:00','2022-11-07 22:00:00',21,71),('2022-11-08 12:00:00','2022-04-09 20:00:00',6,494),('2022-11-08 15:00:00','2022-11-08 22:00:00',2,71),('2022-11-08 15:00:00','2022-11-08 22:00:00',21,71),('2022-11-09 12:00:00','2022-04-10 20:00:00',6,495),('2022-11-09 15:00:00','2022-11-09 22:00:00',2,71),('2022-11-09 15:00:00','2022-11-09 22:00:00',21,71),('2022-11-10 12:00:00','2022-04-11 20:00:00',6,496),('2022-11-10 15:00:00','2022-11-10 22:00:00',2,71),('2022-11-10 15:00:00','2022-11-10 22:00:00',21,71),('2022-11-11 12:00:00','2022-04-12 20:00:00',6,497),('2022-11-11 15:00:00','2022-11-11 22:00:00',2,456),('2022-11-11 15:00:00','2022-11-11 22:00:00',21,71),('2022-11-12 12:00:00','2022-04-13 20:00:00',6,498),('2022-11-12 15:00:00','2022-11-12 22:00:00',2,77),('2022-11-12 15:00:00','2022-11-12 22:00:00',21,77),('2022-11-13 15:00:00','2022-11-13 22:00:00',2,77),('2022-11-13 15:00:00','2022-11-13 22:00:00',21,77),('2022-11-14 15:00:00','2022-11-14 22:00:00',2,77),('2022-11-14 15:00:00','2022-11-14 22:00:00',21,77),('2022-12-01 08:00:00','2022-12-01 16:00:00',4,170),('2022-12-01 08:00:00','2022-12-01 16:00:00',23,170),('2022-12-02 08:00:00','2022-12-02 16:00:00',4,171),('2022-12-02 08:00:00','2022-12-02 16:00:00',23,171),('2022-12-12 08:00:00','2022-12-12 16:00:00',6,183),('2022-12-12 08:00:00','2022-12-12 16:00:00',25,171),('2022-12-12 12:00:00','2022-12-12 20:00:00',2,171),('2022-12-13 08:00:00','2022-12-13 16:00:00',5,185),('2022-12-13 08:00:00','2022-12-13 16:00:00',6,184),('2022-12-13 08:00:00','2022-12-13 16:00:00',25,171),('2022-12-14 08:00:00','2022-12-14 16:00:00',5,186),('2022-12-15 08:00:00','2022-12-15 16:00:00',5,187),('2022-12-16 08:00:00','2022-12-16 16:00:00',5,188),('2022-12-17 08:00:00','2022-12-17 16:00:00',5,189),('2022-12-18 08:00:00','2022-12-18 16:00:00',5,585),('2023-12-12 12:00:00','2023-12-12 20:00:00',2,172),('2024-11-08 12:00:00','2024-11-08 20:00:00',2,173);
INSERT INTO `stratiintonaco` VALUES (4,'Intonaco civile',3,0.034),(5,'Spachtelputz',4,0.023),(6,'Beton Cire',3,0.024),(9,'Granol',3,0.025),(11,'Intonaco civile',3,0.027),(12,'Intonaco civile',6,0.02),(16,'Beton Cire',7,0.023),(17,'Granol',4,0.024),(18,'Intonaco argilloso',3,0.025),(21,'MP2',3,0.026),(22,'KP3',3,0.027),(23,'Rofix',4,0.028),(24,'Granol',3,0.035),(27,'Intonaco civile',3,0.036),(28,'Spachtelputz',2,0.037),(29,'Beton Cire',3,0.038),(30,'Granol',6,0.039),(33,'Beton Cire',5,0.04),(34,'Granol',7,0.026),(35,'Intonaco civile',4,0.027),(39,'Beton Cire',3,0.029),(40,'Granol',3,0.03),(41,'Intonaco civile',3,0.031),(42,'Spachtelputz',4,0.032),(45,'Intonaco argilloso',3,0.033),(46,'Intonaco civile',3,0.034),(47,'Spachtelputz',2,0.023),(48,'Beton Cire',3,0.024),(51,'Granol',6,0.025),(52,'Intonaco argilloso',5,0.026),(53,'Intonaco civile',7,0.027),(54,'Intonaco civile',4,0.028),(57,'Spachtelputz',3,0.035),(58,'Beton Cire',3,0.036),(59,'Granol',3,0.037),(60,'Intonaco argilloso',4,0.038),(63,'MP2',3,0.039),(64,'KP3',3,0.04),(65,'Rofix',2,0.02),(66,'Granol',3,0.034),(69,'Intonaco civile',6,0.023),(70,'Spachtelputz',5,0.024),(72,'Granol',4,0.026),(87,'Intonaco civile',7,0.026),(88,'Spachtelputz',4,0.027),(89,'Beton Cire',3,0.028),(93,'Intonaco civile',3,0.03),(94,'Spachtelputz',4,0.02),(95,'Beton Cire',3,0.021),(96,'Granol',4,0.022),(99,'Intonaco civile',3,0.023),(100,'Spachtelputz',3,0.024),(101,'Spachtelputz',2,0.024),(102,'Beton Cire',3,0.025),(105,'Granol',6,0.026),(106,'Intonaco argilloso',3,0.027),(107,'Intonaco civile',3,0.028),(108,'Intonaco civile',4,0.035),(111,'Spachtelputz',3,0.036),(112,'Beton Cire',3,0.037),(113,'Granol',2,0.038),(114,'Intonaco argilloso',3,0.039),(117,'Intonaco civile',6,0.04),(118,'Intonaco civile',5,0.024),(119,'Spachtelputz',7,0.025),(120,'Beton Cire',4,0.026),(123,'Granol',3,0.027),(124,'Intonaco argilloso',3,0.028),(125,'MP2',3,0.035),(126,'KP3',4,0.036),(129,'Rofix',3,0.037),(130,'Granol',3,0.038),(131,'Intonaco civile',2,0.039),(132,'Spachtelputz',3,0.04),(135,'Beton Cire',6,0.026),(136,'Granol',5,0.027),(137,'Intonaco civile',7,0.028),(142,'Intonaco civile',3,0.02),(143,'Intonaco civile',3,0.021),(144,'Spachtelputz',3,0.022),(147,'Beton Cire',2,0.023),(148,'Granol',3,0.024),(150,'MP2',5,0.025),(153,'KP3',7,0.026),(154,'Rofix',4,0.027),(155,'Intonaco argilloso',3,0.028),(156,'Intonaco civile',3,0.035),(159,'Intonaco civile',3,0.036),(160,'Spachtelputz',4,0.037),(161,'Beton Cire',3,0.038),(162,'Granol',4,0.039),(165,'Intonaco argilloso',3,0.04),(166,'MP2',3,0.025),(167,'KP3',2,0.026),(168,'Rofix',3,0.027),(171,'Granol',3,0.028),(172,'Intonaco civile',3,0.035),(173,'Spachtelputz',4,0.036),(174,'Beton Cire',3,0.037),(177,'Granol',3,0.038),(179,'Intonaco civile',3,0.04),(180,'Spachtelputz',6,0.026),(183,'Beton Cire',5,0.027),(184,'Granol',7,0.028),(185,'Intonaco argilloso',4,0.029),(186,'Intonaco civile',3,0.03),(190,'Spachtelputz',3,0.021),(191,'Beton Cire',4,0.022),(192,'Intonaco civile',3,0.023),(196,'Spachtelputz',2,0.024),(197,'Beton Cire',3,0.025),(198,'Granol',6,0.026),(201,'Intonaco argilloso',5,0.027),(202,'Intonaco civile',7,0.028),(203,'Intonaco civile',4,0.035),(204,'Spachtelputz',3,0.036),(207,'Beton Cire',3,0.037),(208,'Granol',3,0.038),(209,'Intonaco argilloso',3,0.039),(210,'MP2',2,0.04),(213,'KP3',3,0.023),(214,'Rofix',6,0.024),(215,'Granol',5,0.025),(216,'Intonaco civile',7,0.026),(219,'Spachtelputz',4,0.027),(220,'Beton Cire',3,0.028),(221,'Granol',3,0.035),(222,'Beton Cire',3,0.036),(225,'Granol',4,0.037),(227,'Spachtelputz',4,0.039),(228,'Beton Cire',3,0.04),(231,'Granol',3,0.02),(232,'Intonaco civile',2,0.034),(233,'Spachtelputz',3,0.023),(237,'Intonaco civile',5,0.025),(240,'Spachtelputz',3,0.028),(243,'Beton Cire',3,0.035),(244,'Granol',4,0.036),(246,'Intonaco civile',6,0.024),(249,'Intonaco civile',5,0.025),(250,'Spachtelputz',7,0.026),(251,'Beton Cire',4,0.027),(252,'Granol',3,0.028),(255,'Intonaco argilloso',3,0.035),(256,'MP2',3,0.036),(257,'KP3',4,0.037),(258,'Rofix',3,0.038),(261,'Granol',3,0.039),(262,'Intonaco civile',2,0.04),(263,'Spachtelputz',3,0.02),(264,'Beton Cire',6,0.034),(267,'Granol',5,0.023),(268,'Beton Cire',7,0.024),(269,'Granol',4,0.025),(270,'Intonaco civile',3,0.026),(273,'Spachtelputz',3,0.027),(274,'Beton Cire',3,0.028),(275,'Granol',3,0.035),(276,'Intonaco civile',2,0.036),(279,'Spachtelputz',3,0.037),(280,'Intonaco argilloso',6,0.038),(281,'Intonaco civile',5,0.039),(282,'Spachtelputz',7,0.04),(285,'Beton Cire',4,0.026),(286,'Granol',3,0.027),(287,'Intonaco argilloso',3,0.028),(288,'Intonaco civile',3,0.029),(291,'Intonaco civile',4,0.03),(292,'Spachtelputz',3,0.02),(293,'Beton Cire',4,0.021),(294,'Granol',3,0.022),(297,'Intonaco argilloso',3,0.023),(299,'KP3',3,0.024),(300,'Rofix',3,0.025),(303,'Granol',3,0.026),(304,'Intonaco civile',4,0.027),(305,'Spachtelputz',3,0.028),(306,'Beton Cire',3,0.023),(310,'Intonaco civile',3,0.025),(311,'Spachtelputz',6,0.026),(312,'Beton Cire',5,0.027),(315,'Granol',7,0.028),(316,'Intonaco civile',4,0.035),(317,'Intonaco civile',3,0.036),(318,'Intonaco civile',3,0.037),(321,'Spachtelputz',3,0.038),(322,'Beton Cire',4,0.039),(323,'Granol',3,0.04),(324,'Intonaco argilloso',3,0.02),(327,'Intonaco civile',2,0.034),(328,'Intonaco civile',3,0.023),(329,'Spachtelputz',6,0.024),(330,'Beton Cire',5,0.025),(333,'Granol',7,0.026),(334,'Intonaco argilloso',4,0.027),(335,'MP2',3,0.028),(336,'KP3',3,0.035),(339,'Rofix',3,0.036),(340,'Granol',3,0.037),(341,'Intonaco civile',2,0.038),(345,'Beton Cire',6,0.04),(346,'Granol',5,0.026),(347,'Beton Cire',7,0.027),(348,'Granol',4,0.028),(351,'Intonaco civile',3,0.029),(352,'Spachtelputz',3,0.03),(353,'Beton Cire',3,0.02),(354,'Granol',4,0.021),(357,'Intonaco civile',3,0.022),(358,'Spachtelputz',4,0.023),(359,'Intonaco argilloso',3,0.023),(360,'Intonaco civile',3,0.024),(363,'Spachtelputz',2,0.025),(364,'Beton Cire',3,0.026),(365,'Granol',6,0.027),(366,'Intonaco argilloso',5,0.028),(369,'Intonaco civile',7,0.035),(387,'Beton Cire',7,0.027),(389,'Intonaco civile',3,0.035),(390,'Spachtelputz',3,0.036),(393,'Beton Cire',3,0.037),(394,'Granol',3,0.038),(395,'Intonaco civile',2,0.039),(396,'Spachtelputz',3,0.04),(399,'Beton Cire',6,0.026),(400,'Granol',5,0.027),(401,'Intonaco civile',7,0.028),(402,'Spachtelputz',4,0.029),(405,'Beton Cire',3,0.03),(406,'Granol',3,0.02),(407,'Intonaco civile',3,0.021),(408,'Spachtelputz',4,0.022),(411,'Beton Cire',3,0.023),(412,'Granol',4,0.024),(413,'Intonaco civile',3,0.024),(414,'Spachtelputz',3,0.025),(417,'Spachtelputz',2,0.026),(418,'Beton Cire',3,0.027),(419,'Beton Cire',3,0.028),(420,'Granol',3,0.035),(423,'Intonaco civile',4,0.023),(424,'Spachtelputz',3,0.024),(425,'Beton Cire',3,0.025),(427,'Granol',3,0.039),(441,'Intonaco civile',4,0.02),(442,'Intonaco civile',3,0.034),(443,'Spachtelputz',3,0.023),(444,'Beton Cire',2,0.024),(447,'Granol',3,0.025),(449,'MP2',5,0.027),(450,'KP3',7,0.028),(453,'Rofix',4,0.035),(454,'Granol',3,0.036),(459,'Beton Cire',3,0.039),(465,'Beton Cire',5,0.028),(466,'Granol',7,0.029),(467,'Intonaco civile',4,0.03),(468,'Intonaco civile',3,0.02);
INSERT INTO `storicorischio` VALUES ('2021-01-18', "Alluvione", 25, '2019-04-30', "Cimitero"), ('2019-04-30', "Alluvione", 45, '2018-03-24', "Cimitero"), ('2010-10-18', "Incendio", 50, '2008-03-21', "Industriale"), ('2014-01-28', "Incendio", 49, '2010-11-19', "Villaggio");
INSERT INTO `misuratriassiale` (X,Y,Z,DataMisura, FK_IdSensore) VALUES  (1.5, 4, 1.2, '2004-10-18', 29), (1.8, 4, 1.2, '2005-07-01', 29), (2.5, 4, 1.2, '2006-09-13', 29), (1.5, 3.5, 0.4, '2007-12-16', 29), (1.5, 3.5, 0.4, '2007-12-16', 14), (1, 1, 1, '2010-12-16', 15), (0.5, 0.5, 0.5, '2009-12-16', 15), (0.9, 0.4, 0.2, '2010-06-18', 9), (1, 1, 1, '2012-01-04', 1), (0.1, NULL, 0.3, '2009-02-07', 2), (1, 1, 1, '2012-01-04', 15), (0.4, 2, 0.3, '2013-04-24', 25), (1, 1, NULL, '2012-01-04', 41), (1, NULL, 1, '2012-01-04', 42), (1, 1, 1, '2012-01-05', 42), (0.4, 1.2, NULL, '2018-03-05', 13), (0.4, NULL, 0.4, '2019-11-04', 32), (1.6, 1.6, 1.6, '2019-10-23', 33), (1, 1, NULL, '2021-01-04', 34), (0.3, 1, 0.3, '2022-05-28', 35), (1, 1, 0.8, '2022-05-28', 44), (1.2, 1, 0.9, '2008-04-18', 15), (1.2, 1, 1.2, '2020-09-02', 15);
INSERT INTO `MisuraScalare` (Valore, DataMisura,FK_IdSensore) VALUES 	(3.4, '2007-07-19', 3), (3.5, '2007-06-30', 7), (3.4, '2007-07-21', 16), (2, '2007-10-23', 17), (1, '2010-07-19', 8), (0.7, '2008-07-15', 18), (2, '2010-04-11', 37), (1.7, '2010-07-01', 38), (1, '2010-02-18', 39), (2, '2010-10-12', 40), (0.4, '2019-08-11', 19), (0.1, '2009-04-21', 20), (1.3, '2009-03-14', 4), (0.8, '2010-04-11', 10), (2, '2009-12-25', 21), (30, '2010-01-06', 45), (5, '2008-12-17', 11), (3, '2010-04-11', 22), (4.1, '2010-09-05', 12), (1.5, '2009-07-06', 23), (1.2, '2009-08-17', 24), (45, '2015-12-14', 36), (2, '2015-12-14', 31), (5, '2018-10-14', 5), (3.6, '2018-07-07', 26), (2, '2018-08-29', 6), (3.5, '2018-10-15', 27), (25, '2022-02-18', 46), (25, '2022-02-18', 47), (25, '2022-02-18', 48), (25, '2022-02-18', 28);

###############################################################################################
# 									STORED PROCEDURE										  #
###############################################################################################

DROP PROCEDURE IF EXISTS consigliIntervento;
DELIMITER $$

CREATE PROCEDURE consigliIntervento (IN _NomeAreaGeografica VARCHAR(30), IN _IdIndirizzo INT)
	BEGIN
		
        DECLARE finito INTEGER DEFAULT 0;
        DECLARE nomeSensore VARCHAR(60) DEFAULT "";
        DECLARE statoEdificio FLOAT DEFAULT 0;
        DECLARE nuovoStatoEdificio FLOAT DEFAULT 0;
        DECLARE sogliaLimiteX FLOAT DEFAULT 0;
        DECLARE sogliaLimiteY FLOAT DEFAULT 0;
        DECLARE sogliaLimiteZ FLOAT DEFAULT 0;
        DECLARE numeroVani INT DEFAULT 0;
        DECLARE dimensioniNonNulle INT DEFAULT 0;
		DECLARE riparazioni VARCHAR(1024) DEFAULT "";
        
        DECLARE datiSensori CURSOR FOR
			SELECT s.NomeSensore, MAX(s.SogliaLimiteX), MAX(s.SogliaLimiteY), MAX(s.SogliaLimiteZ) 
			FROM Sensore s
				JOIN Superficie su ON su.IdSuperficie = s.FK_IdSuperficie
				JOIN Vano v on su.FK_IdVano = v.IdVano
			WHERE FK_NomeAreaGeograficaEdificio = _NomeAreaGeografica
					AND FK_IdIndirizzoEdificio = _IdIndirizzo
			GROUP BY NomeSensore;
           
		DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET finito = 1;
           
		SELECT StatoEdificio INTO statoEdificio
        FROM Edificio
        WHERE FK_NomeAreaGeografica = _NomeAreaGeografica
			AND FK_IdIndirizzo = _IdIndirizzo;
            
		SELECT COUNT(*) INTO numeroVani
        FROM Vano
        WHERE FK_NomeAreaGeograficaEdificio = _NomeAreaGeografica
			AND FK_IdIndirizzoEdificio = _IdIndirizzo;
            
        OPEN datiSensori;
        
        calcola: LOOP
			FETCH datiSensori INTO nomeSensore, sogliaLimiteX, sogliaLimiteY, sogliaLimiteZ;
            
            IF finito = 1 THEN
				LEAVE calcola;
            END IF;
					
            IF (sogliaLimiteY IS NULL) AND (sogliaLimiteZ IS NULL) THEN
                SET nuovoStatoEdificio = statoEdificio - (((sogliaLimiteX + 1) * 100)/ (sogliaLimiteX * numeroVani));
                
            ELSE 
            
				SELECT IF(sogliaLimiteX IS NOT NULL, 1, 0)+IF(sogliaLimiteY IS NOT NULL, 1, 0)+IF(sogliaLimiteZ IS NOT NULL, 1, 0) INTO dimensioniNonNulle;
				
				IF sogliaLimiteY IS NOT NULL THEN
                
					IF sogliaLimiteZ IS NOT NULL THEN
                    
						SET nuovoStatoEdificio = nuovoStatoEdificio - (((sogliaLimiteX + 1)* 100) / (sogliaLimiteX * numeroVani * dimensioniNonNulle))
																	- (((sogliaLimiteY + 1)* 100) / (sogliaLimiteY * numeroVani * dimensioniNonNulle))
                                                                    - (((sogliaLimiteZ + 1)* 100) / (sogliaLimiteZ * numeroVani * dimensioniNonNulle));
                    ELSE
						SET nuovoStatoEdificio = nuovoStatoEdificio - (((sogliaLimiteX + 1)* 100) / (sogliaLimiteX * numeroVani * dimensioniNonNulle))
																	- (((sogliaLimiteY + 1)* 100) / (sogliaLimiteY * numeroVani * dimensioniNonNulle));
                    END IF;
						
				ELSE
					SET nuovoStatoEdificio = nuovoStatoEdificio - (((sogliaLimiteX + 1)* 100) / (sogliaLimiteX * numeroVani * dimensioniNonNulle))
																	- (((sogliaLimiteZ + 1)* 100) / (sogliaLimiteZ * numeroVani * dimensioniNonNulle));
                END IF;
                
            END IF;
            
            IF nuovoStatoEdificio < 50 THEN
				SET riparazioni = CONCAT(riparazioni, nomeSensoreToRiparazione(nomeSensore), ';');
			END IF;
            
        END LOOP calcola;
        CLOSE datiSensori;
        
        SELECT riparazioni;	
    END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS StimaDanni;
DELIMITER $$

CREATE PROCEDURE StimaDanni (IN _magnetudo FLOAT, IN _FKNomeAreaGeografica VARCHAR(30), IN _FKIdIndirizzo INT)
	BEGIN
    
		DECLARE flag INTEGER DEFAULT 0;
        DECLARE finito INTEGER DEFAULT 0;
        DECLARE valoreLettoId INTEGER DEFAULT 0;
        DECLARE valoreLettoX FLOAT DEFAULT 0;
        DECLARE valoreLettoY FLOAT DEFAULT 0;
        DECLARE valoreLettoZ  FLOAT DEFAULT 0;
        DECLARE avgSensoriX FLOAT DEFAULT 0;
        DECLARE avgSensoriY FLOAT DEFAULT 0;
        DECLARE avgSensoriZ FLOAT DEFAULT 0;
        DECLARE sensoriEdificio CURSOR FOR
			SELECT s.IdSensore, s.SogliaLImiteX, s.SogliaLimiteY, s.SogliaLimiteZ
            FROM Sensore s
				JOIN Superficie su ON s.FK_IdSuperficie = su.IdSuperficie
                JOIN Vano v ON su.FK_IdVano = v.IdVano
			WHERE s.NomeSensore = "Sensore multi uso inerziale con accelerometro a 3 assi"
				AND v.FK_NomeAreaGeograficaEdificio = _FKNomeAreaGeografica
                AND v.FK_IdIndirizzoEdificio =  _FKIdIndirizzo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET finito = 1;
        
        CREATE TEMPORARY TABLE IF NOT EXISTS _datiSuperficie (
		
			IdVano INT,
            IdSuperficie INT,
            primary key (IdVano, IdSuperficie)
        );
        
        TRUNCATE _datiSuperficie;
        
        SELECT 1 INTO flag
        FROM Edificio
        WHERE FK_NomeAreaGeografica = _FKNomeAreaGeografica
			AND FK_IdIndirizzo = _FKIdIndirizzo;
            
		IF flag != 1 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'L\'Edificio richiesto non esiste';
        END IF;
        
        WITH dateTarget AS (
			SELECT c.DataCalamita
			FROM Calamita C
			WHERE C.TipoCalamita = "Terremoto"
				AND c.Intensita BETWEEN (_magnetudo - 0.5) AND (_magnetudo + 0.5)
        )
        SELECT IFNULL(AVG(mt.x), 0) INTO avgSensoriX
        FROM MisuraTriassiale mt
			JOIN Sensore s ON mt.FK_IdSensore = s.IdSensore
        WHERE s.NomeSensore = "Sensore multi uso inerziale con accelerometro a 3 assi"
			AND mt.DataMisura IN (
			
            SELECT *
            FROM dateTarget
        );
        
        WITH dateTarget AS (
			SELECT c.DataCalamita
			FROM Calamita C
			WHERE C.TipoCalamita = "Terremoto"
				AND c.Intensita BETWEEN (_magnetudo - 0.5) AND (_magnetudo + 0.5)
        )
        SELECT IFNULL(AVG(mt.y), 0) INTO avgSensoriY
        FROM MisuraTriassiale mt
			JOIN Sensore s ON mt.FK_IdSensore = s.IdSensore
        WHERE s.NomeSensore =  "Sensore multi uso inerziale con accelerometro a 3 assi"
			AND mt.DataMisura IN (
			
            SELECT *
            FROM dateTarget
        );
        
        WITH dateTarget AS (
			SELECT c.DataCalamita
			FROM Calamita C
			WHERE C.TipoCalamita = "Terremoto"
				AND c.Intensita BETWEEN (_magnetudo - 0.5) AND (_magnetudo + 0.5)
        )
        SELECT IFNULL(AVG(mt.z), 0) INTO avgSensoriZ
        FROM MisuraTriassiale mt
			JOIN Sensore s ON mt.FK_IdSensore = s.IdSensore
        WHERE s.NomeSensore = "Sensore multi uso inerziale con accelerometro a 3 assi" 
			AND mt.DataMisura IN (
			
            SELECT *
            FROM dateTarget
        );
        
        IF (avgSensoriX = 0) AND (avgSensoriY = 0) AND (avgSensoriZ = 0) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Dato che i sensori non sono stati stati sollecitati da scosse simili, Non è possibile generale una stima dei danni';
        END IF;
        
        OPEN sensoriEdificio;
        elabora: LOOP
        
		FETCH sensoriEdificio INTO valoreLettoId, valoreLettoX, valoreLettoY, valoreLettoZ;
        IF finito = 1 THEN
			LEAVE elabora;
		END IF;
            
		IF  (valoreLettoX >= avgSensoriX) OR
			(valoreLettoY >= avgSensoriY) OR
            (valoreLettoZ >= avgSensoriZ) THEN
                
            INSERT INTO _datiSuperficie
				SELECT su.FK_IdVano, su.IdSuperficie
                FROM Sensore s
					JOIN Superficie su ON s.FK_IdSuperficie = su.IdSuperficie
				WHERE s.IdSensore = valoreLettoId;
                
		END IF;
        
        END LOOP elabora;
        CLOSE sensoriEdificio;
    
		SELECT IdVano, COUNT(IdSuperficie) AS "Numero Superfici Danneggiate" 
        FROM _datiSuperficie
        GROUP BY IdVano
        WITH ROLLUP;
    
    END $$

DELIMITER ;
DROP PROCEDURE IF EXISTS SostituzioniPreventive;

DELIMITER $$   
CREATE PROCEDURE SostituzioniPreventive()
	BEGIN
    
		CREATE TEMPORARY TABLE IF NOT EXISTS datiSostituzioni (
        
			id INT AUTO_INCREMENT PRIMARY KEY,
			TipoCalamita VARCHAR(30),
            NomeAreaGeograficaEdificio VARCHAR(30),
            IdIndirizzoEdificio INTEGER,
            NomePiastrellaARischio VARCHAR(60) DEFAULT "",
            NomeMattoneARischio VARCHAR(60) DEFAULT "",
            NomePiastrellaSostitutivo VARCHAR(60) DEFAULT "",
            NomeMattoneSostitutivo VARCHAR(60) DEFAULT ""
        );

		TRUNCATE datiSostituzioni;
    
        INSERT INTO datiSostituzioni(TipoCalamita, NomeAreaGeograficaEdificio, IdIndirizzoEdificio, NomePiastrellaARischio, NomePiastrellaSostitutivo)
		WITH DatiMateriali AS (
			SELECT 	TipoCalamita,
					FK_NomePiastrella,
					TotaleDanni,
					RANK() OVER (
						PARTITION BY TipoCalamita ORDER BY TotaleDanni DESC
					) AS "Classifica"
			FROM (
								
				SELECT 	c.TipoCalamita,	
						s.FK_NomePiastrella,
						SUM(d.Entita) AS "TotaleDanni"		
				FROM Calamita c 
					JOIN Danno d ON d.FK_TipoCalamita = c.TipoCalamita
					JOIN Superficie s ON d.FK_IdSuperfice = s.IdSuperficie
					WHERE s.FK_NomePiastrella IS NOT NULL
				GROUP BY c.TipoCalamita, s.FK_NomePiastrella
			) AS D
								
		), DatiEdificio AS (
		
			SELECT 	FK_NomeAreaGeografica,
					FK_IdIndirizzo,
					NomePiastrella,
					NumeroUtilizzi,
					RANK() OVER (
						PARTITION BY NomePiastrella ORDER BY NumeroUtilizzi DESC
					) AS "ClassificaUtilizzi"
			FROM (
				SELECT 	e.FK_NomeAreaGeografica,
						e.FK_IdIndirizzo,
						p.NomePiastrella,
						COUNT( DISTINCT s.IdSuperficie ) AS "NumeroUtilizzi"
						
				FROM Piastrella p
					JOIN Superficie s ON s.FK_NomePiastrella = p.NomePiastrella
					JOIN Vano v ON s.FK_IdVano = v.IdVano
					JOIN Edificio e ON (v.FK_NomeAreaGeograficaEdificio = e.FK_NomeAreaGeografica) AND (v.FK_IdIndirizzoEdificio = e.FK_IdIndirizzo)
				GROUP BY p.NomePiastrella, e.FK_NomeAreaGeografica, e.FK_IdIndirizzo
			) AS D
		), datiEdificioPiuRischio AS (

		SELECT 	dm.TipoCalamita,	
					dm.FK_NomePiastrella,
					de.FK_NomeAreaGeografica,
					de.FK_IdIndirizzo,
					de.ClassificaUtilizzi
			FROM DatiMateriali dm
				JOIN DatiEdificio de ON de.NomePiastrella = dm.FK_NomePiastrella
				JOIN Rischio r ON de.FK_NomeAreaGeografica = r.FK_NomeAreaGeografica
			WHERE dm.Classifica = 1
				AND r.Tipo = tipoCalamitaToTipoRischio(dm.TipoCalamita)
				AND NOT EXISTS (
					SELECT 1
					FROM DatiEdificio de1
						JOIN Rischio r1 ON de1.FK_NomeAreaGeografica = r1.FK_NomeAreaGeografica
					WHERE de.FK_NomeAreaGeografica = de1.FK_NomeAreaGeografica
						AND r.Tipo = r1.tipo
						AND r.CoeffRischio < r1.CoeffRischio	
				)
		)
		SELECT 	depr.TipoCalamita AS "Tipo Calamita",
				depr.FK_NomeAreaGeografica AS "Area Geografica Edificio",
				depr.FK_IdIndirizzo AS "Indirizzo Edificio",
				depr.FK_NomePiastrella AS "Nome Piastrella A rischio",
				dm.FK_NomePiastrella AS "Nome Piastrella Sostitutivo"
		FROM datiEdificioPiuRischio depr
			JOIN DatiMateriali dm ON dm.TipoCalamita = depr.TipoCalamita
		WHERE NOT EXISTS (
			SELECT 1
			FROM datiEdificioPiuRischio depr1
			WHERE depr.TipoCalamita = depr1.TipoCalamita
				AND depr.FK_NomePiastrella = depr1.FK_NomePiastrella
				AND depr.FK_NomeAreaGeografica = depr1.FK_NomeAreaGeografica
				AND depr.ClassificaUtilizzi < depr1.ClassificaUtilizzi
		) AND dm.Classifica >= ALL (

			SELECT dm1.Classifica
			FROM DatiMateriali dm1
			WHERE dm.TipoCalamita = dm1.TipoCalamita
		);
        
        
        
        
        INSERT INTO datiSostituzioni(TipoCalamita, NomeAreaGeograficaEdificio, IdIndirizzoEdificio, NomeMattoneARischio, NomeMattoneSostitutivo)
		WITH DatiMateriali AS (
			SELECT 	TipoCalamita,
					FK_NomeMattone,
					TotaleDanni,
					RANK() OVER (
						PARTITION BY TipoCalamita ORDER BY TotaleDanni DESC
					) AS "Classifica"
			FROM (
								
				SELECT 	c.TipoCalamita,	
						s.FK_NomeMattone,
						SUM(d.Entita) AS "TotaleDanni"		
				FROM Calamita c 
					JOIN Danno d ON d.FK_TipoCalamita = c.TipoCalamita
					JOIN Superficie s ON d.FK_IdSuperfice = s.IdSuperficie
					WHERE s.FK_NomeMattone IS NOT NULL
				GROUP BY c.TipoCalamita, s.FK_NomeMattone
			) AS D
								
		), DatiEdificio AS (
			SELECT 	FK_NomeAreaGeografica,
					FK_IdIndirizzo,
					NomeMattone,
					NumeroUtilizzi,
					RANK() OVER (
						PARTITION BY NomeMattone ORDER BY NumeroUtilizzi DESC
					) AS "ClassificaUtilizzi"
			FROM (
				SELECT 	e.FK_NomeAreaGeografica,
						e.FK_IdIndirizzo,
						m.NomeMattone,
						COUNT( DISTINCT s.IdSuperficie ) AS "NumeroUtilizzi"
						
				FROM Mattone m
					JOIN Superficie s ON s.FK_NomeMattone = m.NomeMattone
					JOIN Vano v ON s.FK_IdVano = v.IdVano
					JOIN Edificio e ON (v.FK_NomeAreaGeograficaEdificio = e.FK_NomeAreaGeografica) AND (v.FK_IdIndirizzoEdificio = e.FK_IdIndirizzo)
				GROUP BY m.NomeMattone, e.FK_NomeAreaGeografica, e.FK_IdIndirizzo
			) AS D
		), datiEdificioPiuRischio AS (
			SELECT 	dm.TipoCalamita,	
					dm.FK_NomeMattone,
					de.FK_NomeAreaGeografica,
					de.FK_IdIndirizzo,
					de.ClassificaUtilizzi
			FROM DatiMateriali dm
				JOIN DatiEdificio de ON de.NomeMattone = dm.FK_NomeMattone
				JOIN Rischio r ON de.FK_NomeAreaGeografica = r.FK_NomeAreaGeografica
			WHERE dm.Classifica = 1
				AND r.Tipo = tipoCalamitaToTipoRischio(dm.TipoCalamita)
				AND NOT EXISTS (
					SELECT 1
					FROM DatiEdificio de1
						JOIN Rischio r1 ON de1.FK_NomeAreaGeografica = r1.FK_NomeAreaGeografica
					WHERE de.FK_NomeAreaGeografica = de1.FK_NomeAreaGeografica
						AND r.Tipo = r1.tipo
						AND r.CoeffRischio < r1.CoeffRischio
							
				)
		)
		SELECT 	depr.TipoCalamita AS "Tipo Calamita",
				depr.FK_NomeAreaGeografica AS "Area Geografica Edificio",
				depr.FK_IdIndirizzo AS "Indirizzo Edificio",
				depr.FK_NomeMattone AS "Nome Mattone A rischio",
				dm.FK_NomeMattone AS "Nome Mattone Sostitutivo"
		FROM datiEdificioPiuRischio depr
			JOIN DatiMateriali dm ON dm.TipoCalamita = depr.TipoCalamita
		WHERE NOT EXISTS (
			SELECT 1
			FROM datiEdificioPiuRischio depr1
			WHERE depr.TipoCalamita = depr1.TipoCalamita
				AND depr.FK_NomeMattone = depr1.FK_NomeMattone
				AND depr.FK_NomeAreaGeografica = depr1.FK_NomeAreaGeografica
				AND depr.ClassificaUtilizzi < depr1.ClassificaUtilizzi
		) AND dm.Classifica >= ALL (

			SELECT dm1.Classifica
			FROM DatiMateriali dm1
			WHERE dm.TipoCalamita = dm1.TipoCalamita
		);
SELECT 
			TipoCalamita,
            NomeAreaGeograficaEdificio,
            IdIndirizzoEdificio,
            NomePiastrellaARischio,
            NomeMattoneARischio,
            NomePiastrellaSostitutivo,
            NomeMattoneSostitutivo
FROM
    datiSostituzioni;
            
    END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS ReportClassificazioneMonitoraggioDanni;

DELIMITER $$

CREATE PROCEDURE ReportClassificazioneMonitoraggioDanni(IN _FKNomeAreaGeografica VARCHAR(30), IN _FKIdIndirizzo INT)
	BEGIN
    

	SELECT DISTINCT(v.IdVano) AS "Vano", "Rischio Alto" AS "LivelloRischio"
	FROM Alert a
		JOIN MisuraTriassiale mt ON a.FK_DataMisuraTriassiale = mt.DataMisura AND a.FK_IdSensoreTriassiale = mt.FK_IdSensore
		JOIN Vano v ON v.IdVano = a.FK_IdVano
	WHERE 	v.FK_NomeAreaGeograficaEdificio = _FKNomeAreaGeografica
		AND v.FK_IdIndirizzoEdificio = _FKIdIndirizzo
	UNION
	SELECT DISTINCT(v.IdVano) AS "Vano", "Rischio Alto" AS "LivelloRischio"
	FROM Alert a
		JOIN MisuraScalare ms ON a.FK_DataMisuraScalare = ms.DataMisura AND a.FK_IdSensoreScalare = ms.FK_IdSensore
		JOIN Vano v ON v.IdVano = a.FK_IdVano
	WHERE 	v.FK_NomeAreaGeograficaEdificio = _FKNomeAreaGeografica
		AND v.FK_IdIndirizzoEdificio = _FKIdIndirizzo
	UNION
	SELECT DISTINCT(v.IdVano) AS "Vano", "Rischio Moderato" AS "LivelloRischio"
	FROM MisuraScalare ms
		JOIN Sensore se ON ms.FK_IdSensore = se.IdSensore
		JOIN Superficie su ON su.IdSuperficie = se.FK_IdSuperficie
		JOIN Vano v ON v.IdVano = su.FK_IdVano
	WHERE 	v.FK_NomeAreaGeograficaEdificio = _FKNomeAreaGeografica
		AND v.FK_IdIndirizzoEdificio = _FKIdIndirizzo
		AND ms.Valore BETWEEN se.SogliaLimiteX * 0.80 AND se.SogliaLimiteX
        AND NOT EXISTS (
			SELECT 1 
            FROM Alert a
            WHERE a.FK_IdVano = v.IdVano
        )
	UNION
		SELECT DISTINCT(v.IdVano) AS "Vano", "Rischio Moderato" AS "LivelloRischio"
		FROM MisuraTriassiale mt
			JOIN Sensore se ON mt.FK_IdSensore = se.IdSensore
			JOIN Superficie su ON su.IdSuperficie = se.FK_IdSuperficie
			JOIN Vano v ON v.IdVano = su.FK_IdVano
	WHERE 	v.FK_NomeAreaGeograficaEdificio = _FKNomeAreaGeografica
		AND v.FK_IdIndirizzoEdificio = _FKIdIndirizzo
		AND (
			mt.X BETWEEN se.SogliaLimiteX * 0.80 AND se.SogliaLimiteX 
			OR mt.Y BETWEEN se.SogliaLimiteY * 0.80 AND se.SogliaLimiteY
			OR mt.Z BETWEEN se.SogliaLimiteZ * 0.80 AND se.SogliaLimiteZ
		) AND (
			mt.X < se.SogliaLimiteX 
			AND mt.Y < se.SogliaLimiteY
			AND mt.Z < se.SogliaLimiteZ
		) AND NOT EXISTS (
			SELECT 1 
            FROM Alert a
            WHERE a.FK_IdVano = v.IdVano
        );

    
    END $$
    
DELIMITER ;