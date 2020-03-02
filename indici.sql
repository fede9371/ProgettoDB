
CREATE INDEX nome_indx ON cliente(nome);
--Query 1
EXPLAIN ANALYZE
SELECT p_iva, n_fattura, costo_totale, data
FROM ordine, cliente
WHERE ordine.cliente=cliente.p_iva and cliente.nome=’Pietro’;

--Inserimenti per controllo tempo e da fare prima e dopo la creazione
EXPLAIN ANALYZE insert into cliente values ('00343110347','Irene','0256631130','irene@gmail.com','SNDMTT80A01F205Q','Toscana');
EXPLAIN ANALYZE insert into cliente values ('00742570332','Anna','0256389239','anna@gmail.com','SNDMTT80A01F205Q','Toscana');

--Query 2
EXPLAIN ANALYZE 
SELECT DISTINCT c1.p_iva, c1.nome, c2.p_iva, c2.nome 
FROM cliente as c1, cliente as c2 
WHERE c1.p_iva <> c2.p_iva and c1.agente=c2.agente;

