drop database azienda cascade;

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
    cf dom_cf primary key,
    nome varchar(50) not null,
    cognome varchar(50) not null,
    nascita date not null,
    indirizzo varchar(100) not null,
    sesso varchar(1) check (sesso in ('m', 'f')) not null,
    mercato varchar(25) not null unique);
 
CREATE TABLE agente (
    cf dom_cf primary key,
    nome varchar(50) not null,
    cognome varchar(50) not null,
    nascita date not null,
    indirizzo varchar(100) not null,
    sesso varchar(1) check (sesso in ('m', 'f')) not null,
    capo_area dom_cf not null unique);
 
CREATE TABLE mercato (
	nome varchar(25) primary key);

CREATE TABLE regione (
	mercato varchar(25) primary key);

CREATE TABLE macro_zona (
	mercato varchar(25) primary key);

CREATE TABLE formazione (
    macro_zona varchar(25),
    regione varchar(25),
    primary key(macro_zona, regione));

CREATE TABLE sede (
    citta varchar(50) not null,
    indirizzo varchar(100) not null,
    cliente dom_piva not null,
    primary key(citta, indirizzo));

CREATE TABLE cliente (
    p_iva dom_piva primary key,
    nome varchar(50) not null,
    tel dom_tel not null unique,
    mail dom_email not null unique ,
    agente dom_cf not null,
    mercato varchar(25) not null unique);

CREATE TABLE ordine (
    n_fattura dom_fattura primary key,
    costo_totale numeric not null ,
    data date not null,
    cliente dom_piva not null unique);

CREATE TABLE linea_prodotto(
    nome varchar(25)primary key);

CREATE TABLE fornitore (
    p_iva dom_piva primary key,
    nome varchar(50) not null);

CREATE TABLE articolo_venduto(
    codice integer primary key,
    prezzo_articolo float not null,
    peso float not null,
    valori_nutrizionali varchar,
    descrizione varchar(100),
    scadenza date not null,
    confezionamento date not null,
    ordine dom_fattura not null unique,
    quantita int not null,
    linea_prodotto varchar not null unique,
    articolo_comprato dom_articoloComp not null,
    partita dom_partita not null);

CREATE TABLE partita (
 codice dom_partita primary key,
 quantita integer not null,
 bio boolean not null,
 razza varchar not null,
 tipo varchar not null,
 costo_acquisto numeric not null,
 costo_stoccaggio numeric not null,
 costo_spedizione numeric not null,
 p_iva dom_piva unique);

CREATE TABLE articolo_comprato (
 codice dom_articoloComp ,
 partita dom_partita,
 eta numeric not null,
 prezzo numeric not null,
 primary key(codice,partita));



Aggiunta chiavi esterne:
ATTENZIONE:controllare on update e on delete

ALTER TABLE agente
ADD CONSTRAINT constraint_fk 
FOREIGN KEY (capo_area) 
REFERENCES capo_area (cf)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE capo_area 
ADD CONSTRAINT constraint_fk 
FOREIGN KEY (mercato)
REFERENCES mercato (nome)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE regione 
ADD CONSTRAINT constraint_fk 
FOREIGN KEY (mercato) 
REFERENCES mercato (nome)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE macro_zona
ADD CONSTRAINT constraint_fk 
FOREIGN KEY (mercato) 
REFERENCES mercato (nome)
ON DELETE SET NULL
ON UPDATE CASCADE;

//Tabella formazione
ALTER TABLE formazione 
ADD CONSTRAINT constraint_fk_macro_zona 
FOREIGN KEY (macro_zona) 
REFERENCES macro_zona (mercato)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE formazione 
ADD CONSTRAINT constraint_fk_regione 
FOREIGN KEY (regione)
REFERENCES regione (mercato)
ON DELETE CASCADE
ON UPDATE CASCADE;

//Tabella cliente
ALTER TABLE cliente
ADD CONSTRAINT constraint_fk_mercato 
FOREIGN KEY (mercato) 
REFERENCES mercato (nome)
ON DELETE NO ACTION
ON UPDATE CASCADE;


ALTER TABLE cliente
ADD CONSTRAINT constraint_fk_agente
FOREIGN KEY (agente) 
REFERENCES agente (cf)
ON DELETE NO ACTION
ON UPDATE CASCADE;

//Tabella sede
ALTER TABLE sede 
ADD CONSTRAINT constraint_fk 
FOREIGN KEY (cliente) 
REFERENCES cliente (p_iva)
ON DELETE CASCADE
ON UPDATE CASCADE;

//Tabella Ordine
ALTER TABLE ordine 
ADD CONSTRAINT constraint_fk 
FOREIGN KEY (cliente) 
REFERENCES cliente (p_iva)
ON DELETE NO ACTION
ON UPDATE CASCADE;


//Tabella articolo_venduto
ALTER TABLE articolo_venduto 
ADD CONSTRAINT constraint_fk_ordine
FOREIGN KEY (ordine) 
REFERENCES ordine (n_fattura)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE articolo_venduto 
ADD CONSTRAINT constraint_fk_linea_prodotto
FOREIGN KEY (linea_prodotto) 
REFERENCES linea_prodotto (nome)
ON DELETE NO ACTION
ON UPDATE CASCADE;

ALTER TABLE articolo_venduto
ADD CONSTRAINT constraint_fk_articolo_comprato
FOREIGN KEY (articolo_comprato,partita) 
REFERENCES articolo_comprato (codice,partita)
ON DELETE SET NULL
ON UPDATE CASCADE;


//Tabella articolo_comprato
ALTER TABLE articolo_comprato 
ADD CONSTRAINT constraint_partita 
FOREIGN KEY (partita) 
REFERENCES partita (codice)
ON DELETE SET NULL
ON UPDATE CASCADE;

//Tabella partita
ALTER TABLE partita 
ADD CONSTRAINT constraint_p_iva 
FOREIGN KEY (p_iva)
REFERENCES fornitore (p_iva)
ON DELETE NO ACTION
ON UPDATE CASCADE;


POSSIBILI TRIGGER:
1)Tabella articolo_venduto: data_scadenza>data ordine
2)Tabella ordine: costo_totale = quantità * prezzo articolo (perchè attributo derivato)
3)Tabella cliente: quando inserisco un cliente in un mercato, l’agente che lo segue deve essere coordinato dal capo area che gestisce quel mercato
4) Tabella ordine:Data di ordine < data odierna
5) Tabella articolo_comprato: prezzo = (costo acquisto + spedizione + stoccaggio) \ quantità 


Vincoli risolvibili con l’aggiunta di not null nella tabella:
-Tabella cliente: un cliente deve avere almeno un recapito telefonico ed almeno una mail

Vincoli risolvibili con l’aggiunta di unique nelle tabelle:
-Tabella cliente: un cliente deve afferire ad un unico mercato,tel e mail unici
-Tabella capo-area: un capo area deve gestire un unico mercato 
-Tabella agente: un agente deve essere coordinato da un unico capo-area
-Tabella ordine: uno specifico ordine è effettuato da un unico cliente
-Tabella articolo_venduto: ogni articolo_venduto deve appartenere ad un unico ordine e ad una linea di prodotto unica
-Tabella partita: ogni partita è fornita da un unico fornitore
-Tabella cliente: ogni tel e\o mail deve essere univoco\a

Gli altri sono tutti uguali e si possono risolvere allo stesso modo

Contraints sulle date:
Data di confezionamento < data_scadenza
Data di ordine < data odierna

Constraint numero 1: Data di confezionamento < data_scadenza

create  or  replace  function
check_date_valide(data_conf  date , data_scad  date)
returns  bool as
$$
  begin
    return  data_conf < data_scad;
   end;
$$  language  plpgsql;

alter  table  articolo_venduto add
 constraint  check_date_valide_ric
  check(check_date_valide(confezionamento ,scadenza ));

Constraint numero 2: Data di ordine < data odierna

create  or  replace  function
check_date_valide_ordine(data_ordine date)
returns  bool as
$$
  begin
    return  data_ordine < current_date
   end;
$$  language  plpgsql;

alter  table  ordine add
 constraint  check_date_valide_ordine_ric
  check(check_date_valide_ordine(data));








Trigger 1: Tabella articolo_venduto: data_scadenza>data ordine
Da eseguire quando si inserisce un nuovo articolo_venduto
O quando si modifica la data di scadenza 

create  or  replace  function 
check_dateOrdine(fattura dom_fattura,dataScadenza date)
returns trigger as
$$ 
begin
  perform *
  from ordine
  where n_fattura=fattura and ordine.data<dataScadenza
if found
    then
raise  exception
       ’Non è possibile fare vendere un articolo scaduto’;
 return  null;
     else
return  new;
  end if;
end;
$$  language  plpgsql;

create  trigger modifica_ordine before update
  on  articolo_venduto for  each  row
   when (new.scadenza <> old.scadenza)
  execute  procedure check_dateOrdine(ordine,scadenza);





create  trigger  newOrdine before  insert
  on  articolo_venduto for  each  row
  execute  procedure check_dateOrdine(ordine,scadenza);






Trigger 2: Tabella ordine: costo_totale = quantità * prezzo articolo (perchè attributo derivato)
Da eseguire quando si inserisce un nuovo ordine o quando si modifica il costo_totale 

create  or  replace  function
check_costo(fattura dom_fattura)
returns  bool as
$$ 
begin
  perform *
  from articolo_venduto
  where  fattura=ordine and costo_totale = prezzo_articolo*quantita
if not found
    then
raise  exception
       ’E’ sbagliato il calcolo del costo_totale ’;
return  null;
     else
return  new;
  end if;
end;

  $$  language  plpgsql;

create  trigger  costo_ordine before  insert
  on  ordine for  each  row
  execute  procedure check_costo(n_fattura);


create  trigger new_costo_ordine before update
  on  ordine for  each  row
   when ( new.costo_totale  <> old.costo_totale)
  execute  procedure check_costo(n_fattura);








Trigger 3: Tabella cliente: quando inserisco un cliente in un mercato, l’agente che lo segue deve essere coordinato dal capo area che gestisce quel mercato.
Da eseguire quando si inserisce un nuovo cliente oppure si modifica l’agente che segue il cliente o il mercato di appartenenza del cliente 


create  or  replace  function 
check_cliente(cfAgente dom_cf,nomeMercato varchar(25))
returns trigger as
$$ 
begin
  perform *
  from mercato,agente
  where cfAgente=agente.cf and nomeMercato=mercato.nome and
         not exists(select *
                    from capo_area
                    where agente.capo_area=capo_area.cf
                          and capo_area.mercato <> nomeMercato)

if not found
    then
raise  exception
       ’Non rispetta i vincoli di integrità ’;
return  null;
     else
return  new;
  end if;
end;


$$  language  plpgsql;

create  trigger  newCliente before insert
  on  cliente for  each  row
  execute  procedure check_cliente(agente,mercato);

create  trigger cliente_modifica before update
  on  cliente for  each  row
   when ( new.agente  <> old.agente  or
            new.mercato  <> old.mercato)
  execute  procedure check_cliente(agente,mercato);

Trigger 4:
Data di un ordine non deve essere successiva alla data odierna (considero data in cui viene fatto l’ordine e non data in cui viene consegnato al cliente). Viene eseguito quando modifico data dell’ordine 

create  or  replace  function 
check_ordine(numeroFattura dom_fattura)
returns trigger as
$$ 
begin
  perform *
  from ordine
  where n_fattura=numeroFattura and data>current_date
if found
    then
raise  exception
       ’Non è possibile fare un ordine per il futuro’;
 return  null;
     else
return  new;
  end if;
end;
$$  language  plpgsql;

create  trigger modifica_ordine before update
  on  ordine for  each  row
   when ( new.data <> old.data)
  execute  procedure check_ordine(n_fattura);
















Vincolo 5:
Tabella articolo-comprato: prezzo = (costo acquisto + spedizione + stoccaggio) \ quantità 
Viene eseguito quando modifico partita o prezzo di un articolo comprato o quando inserisco un nuovo articolo comprato 


create  or  replace  function 
check_articolo(Numpartita dom_partita)
returns trigger as
$$ 
begin
  perform *
  from partita as p,articolo_comprato
  where codice=Numpartita and 
      articolo_comprato.prezzo=(p.costo_acquisto+p.costo_stoccaggio+p.costo_spedizione)\quantita

If not found found
    then
raise  exception
       ’Errore di derivazione dell’attributo prezzo’;
 return  null;
     else
return  new;
  end if;
end;
$$  language  plpgsql;

create  trigger  newArticolo before insert
  on  articolo_comprato for  each  row
  execute  procedure check_articolo(partita);

create  trigger modifica_articolo before update
  on  articolo_comprato for  each  row
   when (new.partita <> old.partita or
          new.prezzo  <> old.prezzo )
  execute  procedure check_articolo(partita);
