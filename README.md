Versione ITA

**Progetto finale per il corso di Basi di Dati 2021/2022 (Ingegneria Informatica, Università di Pisa).**


Il sistema gestisce l'intero ciclo di vita di edifici moderni: dalla fase di costruzione (logistica e personale) al monitoraggio strutturale tramite sensori IoT per la manutenzione predittiva.

Valutazione: 29/30

📋 Caratteristiche Principali
Il database è progettato per gestire la complessità di una "Smart City", focalizzandosi su:

Gestione Cantieri: Monitoraggio di lotti di materiali (mattoni, piastrelle), fornitori e avanzamento lavori (SAL).

IoT & Monitoraggio: Ingestione dati da sensori scalari e triassiali con sistema di alert automatico in caso di superamento soglie.

Analisi del Rischio: Correlazione tra calamità naturali (es. terremoti) e integrità degli edifici tramite storici dei coefficienti di rischio.

🏗️ Architettura del Database
Il sistema è normalizzato in BCNF e si divide in 5 aree:

Area Generale: Edifici e localizzazione.

Area Costruzione: Progetti, materiali e fornitori.

Area Personale: Dipendenti, ruoli e turni.

Area Monitoraggio: Sensori e misurazioni.

Area Analisi Rischio: Danni e calamità.

📂 Struttura del Repository
Creazione e Popolamento database.sql: Schema DDL completo e dataset di test.

Operazioni.sql: Query avanzate (es. calcolo stipendi complessi, analisi resilienza materiali).

Documentazione.pdf: Relazione tecnica con analisi dei requisiti e progettazione logica.

Diagrammi E-R: Schemi concettuali prima e dopo la ristrutturazione.

⚠️ Note Tecniche
DBMS: MySQL / MariaDB.

Logica Applicativa: Implementazione di trigger per il calcolo dinamico dei costi e aggiornamento automatico dello stato di salute degli edifici.

---

EN Version

**Final project for the Database Systems course 2021/2022 (Computer Engineering, University of Pisa).**
This system manages the complete lifecycle of modern buildings: from the construction phase (logistics and workforce) to structural health monitoring via IoT sensors for predictive maintenance.

Grade: 29/30

📋 Key Features
The database is designed to handle the complexity of a "Smart City," focusing on:

Construction Management: Tracking material lots (bricks, tiles), suppliers, and Work Progress Status (WPS).

IoT & Monitoring: Data ingestion from scalar and triaxial sensors with an automated alert system for safety threshold breaches.

Risk Analysis: Correlation between natural disasters and building integrity through historical risk coefficient tracking.

🏗️ Database Architecture
The system is normalized to BCNF and organized into 5 core modules:

General Area: Buildings and geographic localization.

Construction Area: Projects, materials, and vendors.

Personnel Area: Employees, roles, and shift management.

Monitoring Area: Sensors and real-time measurements.

Risk Analysis Area: Damage reports and natural disaster history.

📂 Repository Structure
Creazione e Popolamento database.sql: Full DDL schema and test dataset.

Operazioni.sql: Advanced SQL queries (e.g., complex payroll calculation, material resilience analysis).

Documentazione.pdf: Technical report including requirement analysis and logical design.

E-R Diagrams: Conceptual schemas (pre and post-restructuring).

⚠️ Technical Highlights
DBMS: MySQL / MariaDB.

Business Logic: Heavy use of triggers for dynamic cost estimation and automated building health status updates based on sensor data.
