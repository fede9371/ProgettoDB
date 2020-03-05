--Controllo vincolo di data nella tabella articolo_venduto (data scadenza> data confezionamento)
--Questo dovrebbe fallire
insert into articolo_venduto values (2342,3.45,4,'Duecentokcal','bistecca di pollo','2020-09-18','2020-09-19',12,7,'CasaleB',27,'AB3153');
--Questo dovrebbe avere successo
insert into articolo_venduto values (2342,3.45,4,'Duecentokcal','bistecca di pollo','2020-12-01','2020-09-19',12,7,'CasaleB',27,'AB3153');
--Controllo vincolo di data nella tabella ordine (data ordine< data attuale)
--Questo dovrebbe fallire
insert into ordine values ('12',10,'2021-09-18','00743110157');
--Questo dovrebbe avere successo
insert into ordine values ('12',10,'2019-09-18','00743110157');

--Inserisco alcuni valori nella base di dati per controllare i trigger
insert into mercato values ('Triveneto');
insert into mercato values ('Sardegna');
insert into fornitore values ('22190050652','Dafwq');
insert into linea_prodotto values('CasaleA');
insert into linea_prodotto values('CasaleB');
insert into capo_area values('BNCMRA80A01C957Z','Mario','Rossi','1965-12-09','Via roma','m','Triveneto');
insert into agente values('FRTNNA80A41L407I','Anna','Forte','1965-12-09','Via roma','f','BNCMRA80A01C957Z');
insert into cliente values ('00743110157','Dario','0438131234','dario@gmail.com','FRTNNA80A41L407I','Triveneto');
--Questo non funziona perchè non rispetta i vincoli del ciclo, il cliente afferisce a un mercato differente da quello dell'agente che lo segue
insert into cliente values ('25389560159','Marco','0438321234','marco@gmail.com','FRTNNA80A41L407I','Sardegna');
--Questo dovrebbe fallire perchè non si possono vendere articoli scaduti
insert into articolo_venduto values (1235,7.89,200,'Duecentokcal','prosciutto','2018-12-01','2017-09-19',12,7,'CasaleA',27,'AB3153');
--Questo dovrebbe funzionare
insert into articolo_venduto values (1234,7.89,200,'Duecentokcal','prosciutto','2020-12-01','2019-09-01',12,7,'CasaleA',27,'AB3153');
insert into articolo_venduto values (7967,7.89,200,'Duecentokcal','petto','2021-12-01','2019-09-19',12,7,'CasaleB',27,'AB3153');
insert into articolo_comprato values('27','AB3153',4,34.4);
insert into partita values('AB3153',12,'prima','0','maiale','baby',12.45,'24.23','12.55','22190050652');
insert into partita values('AC3512',13,'seconda','1','cavallo','pony',16.78,'12.34','15.8','56363201205');
insert into articolo_comprato values('2','AC3512',2,12.3);
-- Inserimenti per controllo query
--Query 1:
insert into linea_prodotto values('CasaleC');
insert into articolo_venduto values (1241,7.89,200,'Duecentokcal','prosciutto','2020-12-01','2019-09-01',12,7,'CasaleC',27,'AB3153');
insert into articolo_venduto values (8941,100.23,200,'Duecentokcal','prosciutto','2020-12-01','2019-09-01',12,10,'CasaleC',27,'AB3153');
--Query 2:
insert into mercato values ('Toscana');
insert into cliente values ('00743110347','Chiara','0256631234','chiara@gmail.com','FRTNNA80A41L407I','Triveneto');
insert into cliente values ('00742570312','Pietro','0256689232','pietro@gmail.com','FRTNNA80A41L407I','Triveneto')
insert into capo_area values('DMRFRC80A41L407Z','Federica','De Martin','1980-12-09','Via roma','f','Sardegna');
insert into agente values('BSTMRC80A01M089M','Marco','Busetti','1965-12-09','Via roma','m','DMRFRC80A41L407Z');
insert into cliente values ('00712470312','Camilla','0256680232','camilla@gmail.com','BSTMRC80A01M089M','Sardegna');
insert into capo_area values('BNIRNZ80A01H501E','Renzo','Bin','1980-12-09','Via mantova','m','Toscana');
insert into agente values('SNDMTT80A01F205Q','Mattia','Sandrin','1965-12-09','Via roma','m','BNIRNZ80A01H501E');
insert into cliente values ('00343110347','Irene','0256631130','irene@gmail.com','SNDMTT80A01F205Q','Toscana');
insert into cliente values ('00742570332','Anna','0256389239','anna@gmail.com','SNDMTT80A01F205Q','Toscana');
insert into articolo_venduto values (1224,7.89,200,'Duecentokcal','prosciutto','2020-12-01','2019-09-01',10,7,'CasaleA',27,'AB3153');
insert into articolo_venduto values (3456,12.45,200,'Duecentokcal','petto','2021-12-01','2019-09-19',11,7,'CasaleB',27,'AB3153');
insert into articolo_venduto values (1024,7.89,200,'Duecentokcal','prosciutto','2020-12-01','2019-09-01',9,7,'CasaleA',27,'AB3153');
insert into articolo_venduto values (1056,12.45,200,'Duecentokcal','petto','2021-12-01','2019-09-19',8,7,'CasaleB',27,'AB3153');
insert into ordine values ('12',10,'2015-09-18','00742570312');
insert into ordine values ('10',10,'2016-09-18','00742570312');
insert into ordine values ('11',10,'2017-09-18','00743110347');
insert into ordine values ('9',10,'2018-09-18','00742570332');
insert into ordine values ('8',10,'2019-09-18','00712470312');
--Query 3:
insert into articolo_venduto values (2241,7.89,200,'Duecentokcal','prosciutto','2020-12-01','2019-09-01',12,7,'CasaleC',27,'AC3512');
insert into articolo_venduto values (1241,100.23,200,'Duecentokcal','prosciutto','2020-12-01','2019-09-01',12,10,'CasaleC',27,'AC3512');
insert into articolo_comprato values('2','AC3512',2,12.3);
insert into articolo_comprato values('3','AC3512',2,12.3);
insert into articolo_venduto values (1004,7.89,200,'Duecentokcal','prosciutto','2020-12-01','2019-09-01',9,7,'CasaleA',2,'AC3512');
insert into articolo_venduto values (1006,12.45,200,'Duecentokcal','petto','2021-12-01','2019-09-19',8,7,'CasaleB',3,'AC3512');
--Query 4
insert into ordine values ('7',10,'2014-09-18','00712470312');
insert into ordine values ('6',10,'2012-09-18','00712470312');


