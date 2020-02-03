drop schema azeinda cascade;

----------------------------------------------------------------
-- COPIARE DA QUI IN POI PER CREARE LE TABELLE LA PRIMA VOLTA --
----------------------------------------------------------------

create database azienda; 

create domain dom_cf as varchar check(value ~ '[A-Z]{6}[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z][0-9]{3}[A-Z]');

create domain dom_partita as varchar check(value ~ '[A-Z]{2}[0-9]{4}');

create domain dom_email as varchar 
check(value ~'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$');

create sequence dom_fattura_seq;
create domain dom_fattura as int default nextval('dom_fattura_seq');

create domain dom_piva as varchar check(value ~ '[0-9]{11}');

create domain dom_tel as varchar check(value ~ '[0-9]{10}');

create sequence dom_articoloComp_seq;
create domain dom_articoloComp as int default nextval('dom_articoloComp_seq');



CREATE TABLE capo_area (
    cf dom_cf PRIMARY KEY,
    nome varchar(50) NOT NULL,
    cognome varchar(50) NOT NULL,
    nascita date NOT NULL,
    indirizzo varchar(100) NOT NULL,
    sesso varchar(1) check (sesso in ('m', 'f')) NOT NULL,
    mercato varchar(25) NOT NULL);
 
CREATE TABLE agente (
    cf dom_cf PRIMARY KEY,
    nome varchar(50) NOT NULL,
    cognome varchar(50) NOT NULL,
    nascita date NOT NULL,
    indirizzo varchar(100) NOT NULL,
    sesso varchar(1) check (sesso in ('m', 'f')) NOT NULL,
    capo_area dom_cf NOT NULL);
 
CREATE TABLE mercato (
	nome varchar(25) PRIMARY KEY);

CREATE TABLE regione (
	mercato varchar(25) PRIMARY KEY);

CREATE TABLE macro_zona (
	mercato varchar(25) PRIMARY KEY);

CREATE TABLE formazione (
    macro_zona varchar(25),
    regione varchar(25),
    PRIMARY KEY (macro_zona, regione));

CREATE TABLE sede (
    citta varchar(50) NOT NULL,
    indirizzo varchar(100) NOT NULL,
    cliente dom_piva NOT NULL,
    PRIMARY KEY (citta, indirizzo));

CREATE TABLE cliente (
    p_iva dom_piva PRIMARY KEY,
    nome varchar(50) NOT NULL,
    tel dom_tel NOT NULL,
    mail dom_email NOT NULL,
    agente dom_cf NOT NULL,
    mercato varchar(25) NOT NULL);

CREATE TABLE ordine (
    n_fattura dom_fattura PRIMARY KEY,
    costo_totale numeric NOT NULL,
    data date NOT NULL,
    cliente dom_piva NOT NULL);

CREATE TABLE linea_prodotto(
    nome varchar(25) PRIMARY KEY);

CREATE TABLE fornitore (
    p_iva dom_piva PRIMARY KEY,
    nome varchar(50) NOT NULL);

CREATE TABLE articolo_venduto(
    codice integer primary key,
    prezzo_articolo float not null,
    peso float not null,
    valori_nutrizionali varchar,
    descrizione varchar(100),
    scadenza date not null,
    confezionamento date not null,
    ordine dom_fattura not null,
    quantita int not null,
    linea_prodotto varchar not null,
    articolo_comprato dom_articoloComp not null,
    partita dom_partita not null);

CREATE TABLE partita (
 codice dom_partita PRIMARY KEY,
 quantita integer not null,
 bio boolean not null,
 razza varchar not null,
 tipo varchar not null,
 costo_acquisto numeric not null,
 costo_stoccaggio numeric not null,
 costo_spedizione numeric not null,
 p_iva dom_piva);

CREATE TABLE articolo_comprato (
 codice dom_articoloComp ,
 partita dom_partita,
 eta numeric not null,
 prezzo numeric not null,
 PRIMARY KEY (codice,partita));
 
 
ALTER TABLE agente  ( on delete set null, on update cascade)
ADD CONSTRAINT constraint_fk FOREIGN KEY (capo_area) REFERENCES capo_area (cf);

ALTER TABLE capo_area ( on delete set null, on update cascade)
ADD CONSTRAINT constraint_fk FOREIGN KEY (mercato) REFERENCES mercato (nome);

ALTER TABLE regione ( on delete set null, on update cascade)
ADD CONSTRAINT constraint_fk FOREIGN KEY (mercato) REFERENCES mercato (nome);

ALTER TABLE macro_zona ( on delete set null, on update cascade)
ADD CONSTRAINT constraint_fk FOREIGN KEY (mercato) REFERENCES mercato (nome);

//Tabella formazione
ALTER TABLE formazione ( on delete cascade, on update cascade)
ADD CONSTRAINT constraint_fk_macro_zona FOREIGN KEY (macro_zona) REFERENCES macro_zona (mercato);

ALTER TABLE formazione ( on delete cascade, on update cascade)
ADD CONSTRAINT constraint_fk_regione FOREIGN KEY (regione) REFERENCES regione (mercato);

//Tabella cliente
ALTER TABLE cliente ( on delete no action, on update cascade)
ADD CONSTRAINT constraint_fk_mercato FOREIGN KEY (mercato) REFERENCES mercato (nome);


ALTER TABLE cliente ( on delete no action, on update cascade)
ADD CONSTRAINT constraint_fk_agente FOREIGN KEY (agente) REFERENCES agente (cf);

//Tabella sede
ALTER TABLE sede ( on delete cascade, on update cascade)
ADD CONSTRAINT constraint_fk FOREIGN KEY (cliente) REFERENCES cliente (p_iva);

//Tabella Ordine
ALTER TABLE ordine ( on delete no action, on update cascade)
ADD CONSTRAINT constraint_fk FOREIGN KEY (cliente) REFERENCES cliente (p_iva);

//Tabella articolo_venduto
ALTER TABLE articolo_venduto ( on delete cascade, on update cascade)
ADD CONSTRAINT constraint_fk_ordine FOREIGN KEY (ordine) REFERENCES ordine (n_fattura);

ALTER TABLE articolo_venduto ( on delete no action, on update cascade)
ADD CONSTRAINT constraint_fk_linea_prodotto FOREIGN KEY (linea_prodotto) REFERENCES linea_prodotto (nome);

ALTER TABLE articolo_venduto ( on delete set null, on update cascade)
ADD CONSTRAINT constraint_fk_articolo_comprato FOREIGN KEY (articolo_comprato,partita) REFERENCES articolo_comprato (codice,partita);


ANCHE QUESTO DA’ ERRORE
ALTER TABLE articolo_venduto
ADD CONSTRAINT constraint_fk_partita FOREIGN KEY (partita) REFERENCES articolo_comprato (partita);

//Tabella articolo_comprato
ALTER TABLE articolo_comprato ( on delete set null, on update cascade)
ADD CONSTRAINT constraint_partita FOREIGN KEY (partita) REFERENCES partita (codice);

//Tabella partita
ALTER TABLE partita ( on delete no action, on update cascade)
ADD CONSTRAINT constraint_p_iva FOREIGN KEY (p_iva) REFERENCES fornitore (p_iva);



