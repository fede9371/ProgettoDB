--Query 1
--Vogliamo stabilire quale sia la linea di prodotto più remunerativa.

CREATE VIEW COSTO_ARTICOLO AS
SELECT codice, linea_prodotto, prezzo_articolo*quantita as costo_articolo
FROM ARTICOLO_VENDUTO;

CREATE VIEW COSTO_LINEA AS
SELECT linea_prodotto, SUM(costo_articolo) as sommaLinea
FROM COSTO_ARTICOLO
GROUP BY linea_prodotto;

SELECT L1.linea_prodotto
FROM COSTO_LINEA as L1
WHERE NOT EXISTS (SELECT *
                  FROM COSTO_LINEA as L2
                  WHERE L2.linea_prodotto <> L1.linea_prodotto AND
                        L2.sommaLinea > L1.sommaLinea);
--Query 2
--Per ogni mercato, vogliamo individuare il cliente che ha effettuato più ordini.

CREATE VIEW COUNT_CLIENTI AS
SELECT cliente, COUNT(n_fattura) AS num_ordini
FROM ORDINE
GROUP BY cliente;

CREATE VIEW JOIN_C AS
SELECT cliente, cliente.nome, num_ordini, mercato
FROM CLIENTE, COUNT_CLIENTI AS CC
WHERE CLIENTE.p_iva = CC.cliente;


SELECT C1.cliente, C1.nome, C1.mercato, C1.num_ordini
FROM JOIN_C AS C1
WHERE NOT EXISTS( SELECT *
                  FROM JOIN_C AS C2
                  WHERE C1.mercato=C2.mercato AND C2.cliente<>C1.cliente AND 
                        C1.num_ordini<C2.num_ordini);
--Query 3                       
--Individuare la partita di animali da cui sono stati ricavati più articoli venduti.

CREATE VIEW COUNT_ARTICOLI AS
SELECT partita, COUNT(codice) as num_articoli
FROM ARTICOLO_VENDUTO
GROUP BY partita;

SELECT C1.partita
FROM COUNT_ARTICOLI AS C1
WHERE NOT EXISTS (SELECT *
			FROM COUNT_ARTICOLI AS C2
			WHERE C1.num_articoli < C2.num_articoli AND
				C1.partita <> C2.partita);
