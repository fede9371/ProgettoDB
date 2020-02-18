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
