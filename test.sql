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
--Questo dovrebbe funzionare E INVECE NOOO PERCHEEE
insert into articolo_venduto values (1234,7.89,200,'Duecentokcal','prosciutto','2020-12-01','2019-09-01',12,7,'CasaleA',27,'AB3153');
insert into articolo_venduto values (7967,7.89,200,'Duecentokcal','petto','2021-12-01','2019-09-19',12,7,'CasaleB',27,'AB3153');
insert into articolo_comprato values('27','AB3153',4,34.4);
insert into partita values('AB3153',12,'prima','0','maiale','baby',12.45,'24.23','12.55','22190050652');
