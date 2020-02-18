--Controllo vincolo di data nella tabella articolo_venduto (data scadenza> data confezionamento)
--Questo dovrebbe fallire
insert into articolo_venduto values (2342,3.45,4,'Duecentokcal','bistecca di pollo','2020-09-18','2020-09-19',12,7,'CasaleB',27,'0764352056C');
--Questo dovrebbe avere successo
insert into articolo_venduto values (2342,3.45,4,'Duecentokcal','bistecca di pollo','2020-12-01','2020-09-19',12,7,'CasaleB',27,'0764352056C');
