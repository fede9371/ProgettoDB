require(tidyverse)
require('RPostgreSQL')
require("httr")
drv <- dbDriver('PostgreSQL')

con <- dbConnect(drv,
                # dbname = 'azienda',
                # host = '127.0.0.1',
                 host = "localhost",
                 port = 5432, 
                 user = 'postgres',
                 password='federica6345')


#-------------------------------------- !! LEGGIMI !! ------------------------------------------------------------------------
# 1. Assicurarsi di avere impostato i parametri di conessione al db sopra.
# 2. Per il corretto funzionamento dello script è neccessario caricare i file di input presenti nella cartella DA CARICARE
#    Eseguire una alla volta le seguenti righe (Ctrl + Invio su windows, Cmd + Invio su MacOS) 
#    e selezionare i singoli fle dalla finestra che appare.
# 3. Il resto dello script può essere eseguito in una sola volta, selezionando il resto del codice ed eseguendolo.
# 4. Per velocizzare lo script, sono stati salvati dei riultati parziali nei file 'inutili.rds' e 'lista_cf.rds',
#    il codice che li ha generati è commentato nelle apposite sezioni.
#----------------------------------------------------------------------------------------------------------------------------

lista_regioni <- readLines(file.choose(), warn = F) # SELEZIONARE FILE 1_lista_regioni.txt
lista_mercati <- readLines(file.choose(), warn = F) # SELEZIONARE FILE 2_lista_mercati.txt
identita_fake = read_csv(file.choose()) # SELEZIONARE FILE 3_identita_fake.csv
lista_nomi_fornitori = readLines(file.choose(), warn = F) # SELEZIONARE FILE  4_ lista_nomi_fornitori.txt
lista_bovini = readLines(file.choose(), warn = F) # SELEZIONARE FILE 5_razze_bovine.txt
lista_suini = readLines(file.choose(), warn = F) # SELEZIONARE FILE 6_ razze_suine.txt
lista_polli = readLines(file.choose(), warn = F) # SELEZIONARE FILE 7_razze_polli.txt 
lista_clienti = readLines(file.choose(), warn = F) # SELEZIONARE FILE 8_clienti.txt
lista_tagli_bovino = readLines(file.choose(), warn = F) # SELEZIONARE FILE 9_tagli_bovino.txt
lista_tagli_suino = readLines(file.choose(), warn = F) # SELEZIONARE FILE 10_tagli_suino.txt
lista_tagli_pollo = readLines(file.choose(), warn = F) # SELEZIONARE FILE 11_tagli_pollo.txt

inutili = readRDS(file.choose()) # SELEZIONARE FILE inutili.rds
lista_cf = readRDS(file.choose()) # SELEZIONARE FILE lista_cf.rds


######################################################################################
################### POPOLAMENTO MERCATO, REGIONE, MACROZONA, FORMAZIONE ##############
######################################################################################
mercato_df <- data.frame(nome = lista_mercati)
regione_df <- data.frame(mercato = lista_regioni)
df_macrozona <- data.frame(mercato = c("Isole", "Triveneto"))
df_formazione <- data.frame(macro_zona = c("Isole", "Isole", "Triveneto", "Triveneto", "Triveneto"),
                            regione = c("Sicilia", "Sardegna", "Trentino-Alto Adige", "Veneto","Friuli-Venezia Giulia")
                            )

dbWriteTable(con, name = 'mercato', value = mercato_df, append=T, row.names=F)
dbWriteTable(con, name = 'regione', value = regione_df, append=T, row.names=F)
dbWriteTable(con, name = 'macro_zona', value = df_macrozona, append=T, row.names=F)
dbWriteTable(con, name = 'formazione', value = df_formazione, append=T, row.names=F)


dbGetQuery(con, "select * from regione")

######################################################################################
############################# POPOLAMENTO CAPO_AREA e AGENTE #########################
######################################################################################

## PER CALCOLARE CODICE FISCALE USO API http://webservices.dotnethell.it/codicefiscale.asmx?op=CalcolaCodiceFiscale

# funzione per chiamare api e calcolare codice fiscale
calcola_CF = function(nome, cognome, comune, nascita, sesso){
  richiesta = paste(
    'webservices.dotnethell.it/codicefiscale.asmx/CalcolaCodiceFiscale?Nome=',
    nome %>% parsing_testo(),
    '&Cognome=',
    cognome %>% parsing_testo(),
    '&ComuneNascita=',
    comune %>% parsing_testo(),
    '&DataNascita=',
    nascita,
    '&Sesso=',
    sesso, 
    sep = ""
  ) %>% GET()
  content(richiesta, "text") %>% estrai_Testo()
}
# funzione per estrarre la risposta della api
estrai_Testo = function(str){
  parte_finale = substring(str, nchar(str) - 24)
  substring(parte_finale, 0, 16)
}

parsing_testo = function(str){
  s = str_replace_all(str, " ", "+") 
  str_replace_all(s, "'", paste("\\", "'", sep = ""))
}
#calcola_CF("Ovidiu", 'Blaj', "San Nicolo' D'Arcidano", '06_03_1998', 'm')
## Alcune frazioni di comuni presenti in identita_fake.csv non sono presenti nella API
## individuo queste frazioni e poi le tolgo dal dataframe (visto che ho 10000 identita diverse, posso scartare direttamente quelle problematiche)

# frazioniIutili = function(df){
#   lista_frazioni = c()
#   for (x in 1:nrow(df)) {
#     nome = df[x,1]
#     cognome = df[x,2]
#     comune = df[x,5]
#     nascita = df[x,9]
#     sesso = df[x,8]
#     risposta = calcola_CF(nome, cognome, comune, nascita, sesso)
#     if(grepl("inesistente",  risposta, fixed=TRUE)){ # false se il comune nascita Ã¨ una frazione non presente nella API per calcolare il cf
#       lista_frazioni = c(lista_frazioni, c(as.character(comune)))
#     }
#   }
#   lista_frazioni 
# }
#inutili = frazioniIutili(identita_fake2)
#saveRDS(inutili, file = "inutili.rds")

identita_fake2 = identita_fake %>% 
  select(nome = GivenName,
         cognome = Surname, 
         nascita = Birthday,
         via = StreetAddress,
         comune = City,
         provincia = StateFull,
         cap = ZipCode,
         sesso = Gender) %>%
  mutate(sesso = substring(sesso, 0, 1),
         nascita = as.Date(nascita, "%m/%d/%Y"),
         nascitaStr = format(nascita, "%d_%m_%Y")
         ) %>% 
  filter(!(comune %in% inutili)) # tolgo comuni problematici

## CALCOLO I CODICI FISCALI, RISULTATI SALVATI NEL FILE lista_cf.rds
# lista_cf = c()
# for(x in 1:nrow(identita_fake2)){
#   nome = df[x,1]
#   cognome = df[x,2]
#   comune = df[x,5]
#   nascita = df[x,9]
#   sesso = df[x,8]
#   lista_cf = append(lista_cf, calcola_CF(nome, cognome, comune, nascita, sesso))
# }
#saveRDS(lista_cf, file = "lista_cf.rds")

identita_fake_finale = identita_fake2 %>% 
  mutate(cf = lista_cf,
         indirizzo = 
           paste(via, cap, sep = ", ") %>% 
           paste(comune, sep = ", ") %>% 
           paste(" (", sep = "") %>%
           paste(provincia, sep = "") %>%
           paste(")", sep = "")
         ) %>% 
  select(cf, nome, cognome, nascita, indirizzo, sesso)

set.seed(0.1)
df_capo_area = sample_n(identita_fake_finale, 22) %>%
  mutate(mercato = lista_mercati)

set.seed(5) # seed che garantisce che non ci siano capi area senza agenti
lista_capi_area = df_capo_area$cf %>% sample(45, replace = T)
set.seed(0.1)
df_agente = identita_fake_finale %>% 
  filter(!cf %in% df_capo_area$cf) %>% 
  sample_n(45) %>% 
  mutate(capo_area = lista_capi_area)
View(df_agente)
dbWriteTable(con, name = 'capo_area', value = df_capo_area, append=T, row.names=F)
dbWriteTable(con, name = 'agente', value = df_agente, append=T, row.names=F)


######################################################################################
############################### POPOLAMENTO CLIENTE e SEDE ###########################
######################################################################################
lista_piva_cliente = runif(length(lista_clienti), min=10000000000, max=99999999999) %>% floor()
lista_cf_agenti = c(df_agente$cf, # tutti gli agenti seguono almeno un cliente
                    sample(df_agente$cf, length(lista_clienti) - length(df_agente$cf), replace = T)) # qualcuno piu di uno

mercato_agenti = tibble(agente = lista_cf_agenti) %>%
  inner_join(df_agente, by = c("agente" = "cf")) %>% 
  inner_join(df_capo_area, by = c("capo_area" = "cf")) %>% 
  select(agente, mercato) %>%
  unique()

df_cliente = tibble(p_iva = lista_piva_cliente, nome = lista_clienti) %>% 
  mutate(tel = paste("0", runif(length(lista_clienti), min=100000000, max=999999999) %>% floor(), sep = "") %>% paste(),
         mail = paste("info@", str_replace_all(nome, " ", ""), ".com", sep = "") %>% tolower(),
         agente = lista_cf_agenti) %>%
  inner_join(mercato_agenti)

lista_indirizzi_sedi = sample(identita_fake$StreetAddress, nrow(df_cliente), replace = F)

df_sede = df_cliente %>% 
  select(p_iva, agente) %>% 
  inner_join(df_agente, by = c("agente" = "cf")) %>%
  inner_join(identita_fake2, c("nome" = "nome", "cognome" = "cognome")) %>%  # uso provincie dei capi area come citta in cui hanno sede i clienti da loro seguiti
  distinct(p_iva, .keep_all = T) %>%
  mutate(indirizzo = lista_indirizzi_sedi) %>%
  select(citta = provincia, indirizzo, cliente = p_iva)

dbWriteTable(con, name = 'cliente', value = df_cliente, append=T, row.names=F)
dbWriteTable(con, name = 'sede', value = df_sede, append=T, row.names=F)

##########################################################################################
############################### POPOLAMENTO FORNITORE e PARTITA ##########################
##########################################################################################
df_fornitore = tibble(
  p_iva = runif(length(lista_nomi_fornitori), min=10000000000, max=99999999999) %>% floor(),
  nome = lista_nomi_fornitori
)

partite_suini = tibble(
  quantita = rnorm(121, mean=300, sd=50) %>% floor(),
  razza = sample(lista_suini, 121, replace = T),
  tipo = rep("suino", times = 121),
  costo_acquisto =  quantita * sample(100:150, 121, replace = T),
  costo_spedizione = costo_acquisto * sample(2:6/100, 121, replace = T),
  costo_stoccaggio = costo_acquisto * sample(1:3/100, 121, replace = T)
  )

partite_bovini = tibble(
  quantita = rnorm(210, mean=100, sd=25) %>% floor(),
  razza = sample(lista_bovini, 210, replace = T),
  tipo = rep("bovino", times = 210),
  costo_acquisto =  quantita * sample(700:3000, 210, replace = T),
  costo_spedizione = costo_acquisto * sample(2:6/100, 210, replace = T),
  costo_stoccaggio = costo_acquisto * sample(1:3/100, 210, replace = T)
)

partite_polli = tibble(
  quantita = rnorm(50, mean=1000, sd=175) %>% floor(),
  razza = sample(lista_polli, 50, replace = T),
  tipo = rep("pollo", times = 50),
  costo_acquisto =  quantita * sample(5:10, 50, replace = T),
  costo_spedizione = costo_acquisto * sample(3:4/100, 50, replace = T),
  costo_stoccaggio = costo_acquisto * sample(1:2/100, 50, replace = T)
)

df_partita = rbind(partite_bovini, partite_suini, partite_polli)
df_partita = df_partita %>%
  mutate(
    codice = paste("PA", sprintf("%05d", seq.int(nrow(df_partita))), sep = ""),
    qualita_scelta = sample(c('prima', 'seconda','terza'), nrow(df_partita), replace = T),
    bio = sample(c(T, F), nrow(df_partita), replace = T),
    p_iva = sample(df_fornitore$p_iva, nrow(df_partita), replace = T)
  ) %>%
  select(codice, quantita, qualita_scelta, bio, razza, tipo, costo_acquisto, costo_spedizione, costo_stoccaggio, p_iva)


dbWriteTable(con, name = 'fornitore', value = df_fornitore, append=T, row.names=F)
dbWriteTable(con, name = 'partita', value = df_partita, append=T, row.names=F)

##########################################################################################
################################ POPOLAMENTO ARTICOLO COMPRATO, LINEA PRODOTTO E ORDINE ###########################
##########################################################################################
eta_bovini = sample(7:15, nrow(partite_bovini), replace = T)
eta_suini = sample(5:12, nrow(partite_suini), replace = T)
eta_polli = sample(2:8, nrow(partite_polli), replace = T)
lista_eta = c(eta_bovini, eta_suini, eta_polli)

articolo_comprato_temp = df_partita %>% 
  select(partita = codice, quantita, tipo) %>%
  mutate(eta = lista_eta)

df_articolo_comprato = # ripeto ogni riga, tante volte quanto indicato dall'attributo quantita
  as_tibble(lapply(articolo_comprato_temp, rep, articolo_comprato_temp$quantita)) %>% 
  mutate(conta = ave(eta, tipo, FUN = seq_along), #raggruppo per tipo, e conto ogni singola istanza del sottogruppo
         codice = paste( # compongo il codice
           substring(tipo, 0, 2), 
           sprintf("%06d", conta), sep = "") %>% toupper(),
         prezzo = rep(0, n())) %>%
  select(codice, partita, eta, prezzo)

dbWriteTable(con, name = 'articolo_comprato', value = df_articolo_comprato, append=T, row.names=F)
##########################################################################################
################################ POPOLAMENTO ORDINE ######################################
##########################################################################################
df_linea_prodotto = tibble(nome = c("linea bovini", "linea polli", "linea suini"))
dbWriteTable(con, name = 'linea_prodotto', value = df_linea_prodotto , append=T, row.names=F)

df_articolo_venduto1 = tibble(
  articolo_comprato = df_articolo_comprato$codice,
  partita = df_articolo_comprato$partita,
  linea_prodotto = ifelse(substring(articolo_comprato, 0, 2) == "BO", "linea bovini", 
                          ifelse(substring(articolo_comprato, 0, 2) == "PO", "linea polli", "linea suini")),
  n_tagli = ifelse(linea_prodotto == "linea bovini", length(lista_tagli_bovino),
                   ifelse(linea_prodotto == "linea suini", length(lista_tagli_suino), 
                          length(lista_tagli_pollo)))
)

View(df_articolo_venduto1)
n_art_bovini = df_articolo_venduto1 %>% filter(linea_prodotto == "linea bovini") %>% nrow() 
n_art_suini = df_articolo_venduto1 %>% filter(linea_prodotto == "linea suini") %>% nrow() 
n_art_polli = df_articolo_venduto1 %>% filter(linea_prodotto == "linea polli") %>% nrow()

lista_descrizioni = c(rep(lista_tagli_bovino, n_art_bovini), rep(lista_tagli_suino, n_art_suini), rep(lista_tagli_pollo, n_art_polli)) 
lista_fatture = sample(df_ordine_temp$n_fattura, length(lista_descrizioni), replace = T) #length(lista_descrizioni) =  numero di tutti gli articoli venduti  

df_articolo_venduto2 = as_tibble(lapply(df_articolo_venduto1, rep, df_articolo_venduto1$n_tagli)) %>%
  select(-c("n_tagli")) %>%
  mutate(descrizione = lista_descrizioni,
         ordine = lista_fatture 
        )


df_quantita =  df_articolo_venduto2 %>% 
  group_by(ordine) %>% 
  summarise(n_articoli = n()) %>% mutate(ordine = as.integer(ordine))

# CONTROLLO CHE CI SIANO circa 150 ARTICOLI PER ORDINE, per rispettare quanto ipotizziato nella relazione 
# df_quantita$n_articoli %>% mean() # = 149.6047 -> OK

confezionamento_scadenza = df_articolo_venduto2 %>% 
  inner_join(df_ordine_temp, by = c("ordine" = "n_fattura")) %>% 
  select(data) %>%
  mutate(confezionamento = data - 3, # suppongo che gli articoli vegano confezionati 3 gioni prima di essere venduti
         scadenza = data + sample(7:45, nrow(df_articolo_venduto2), replace = T))  # suppongono che le scadenze siano comprese fra 7 e 45 giorni

df_articolo_venduto = df_articolo_venduto2 %>% 
  inner_join(df_quantita) %>% 
  mutate(scadenza = confezionamento_scadenza$scadenza,
         confezionamento = confezionamento_scadenza$confezionamento,
         peso = sample(1:50 / 10, nrow(df_articolo_venduto2), replace = T),
         prezzo_articolo = peso * 15, # semplifico assumendo che 1kg = 15 euro in generale
         codice = paste(rep("AT", nrow(df_articolo_venduto2)), 
                        sprintf("%08d", 1:nrow(df_articolo_venduto2)),
                        sep = "")
         ) %>% 
  select(codice, prezzo_articolo, peso, descrizione, scadenza, confezionamento, ordine, quantita = n_articoli, linea_prodotto, articolo_comprato, partita)
View(df_articolo_venduto)
dbWriteTable(con, name = 'articolo_venduto', value = df_articolo_venduto, append=T, row.names=F)


df_ordine = tibble(n_fattura = 1:8000,
                   costo_totale = rep(0, 8000),
                   data =seq(as.Date('2019/01/01'), as.Date('2019/12/31'), by="day") %>% rep(each = 22, length.out = 8000),
                   cliente = sample(lista_piva_cliente, 8000, replace = T))
dbWriteTable(con, name = 'ordine', value =df_ordine, append=T, row.names=F)



#Query

library(ggplot2)

# Query 
#1)Per ogni mercato, vogliamo individuare il numero di clienti

fq<-dbGetQuery(con, "
           SELECT mercato.nome, count(c.p_iva)
           FROM cliente as c, mercato
           WHERE c.mercato=mercato.nome
           GROUP BY mercato.nome;
           
           ")

fq

ggplot(fq,aes(nome,count,color=nome))+
  geom_col()+
  labs(x='Mercati',y='Numero clienti', title= 'Numero clienti per mercato')+
  theme(
  axis.text.x=element_blank(),
  axis.ticks.x=element_blank())
  
#2) Numero di articoli per linea prodotto


sq<-dbGetQuery(con, "
           SELECT linea_prodotto, count(codice)
           FROM articolo_venduto
           GROUP BY linea_prodotto;
           
           ")

sq
ggplot(sq,aes(linea_prodotto,count,fill=linea_prodotto))+
  geom_col()+
  labs(x='Linea Prodotto',y='Numero articoli', title= 'Numero di articoli per linea prodotto')+
  theme_minimal()




#Query 3
# Boxplot per costi delle 3 linee di prodotto

tq<-dbGetQuery(con, "
               SELECT linea_prodotto, prezzo_articolo
               FROM articolo_venduto
               
               ")

tq
ggplot(tq,aes(linea_prodotto,prezzo_articolo,color=linea_prodotto))+
  geom_boxplot()+
  labs(x='Linea Prodotto',y='Prezzo articoli', title= 'Variazione prezzo per linea prodotto')+
  theme_minimal()+
  stat_summary(fun.y=mean, geom="point", shape=23, size=4)


#Query 4
# Come varia il prezzo di articolo_venduto in base al peso?

fq<-dbGetQuery(con, "
               SELECT prezzo_articolo,peso
               FROM articolo_venduto as av
            
               
               ")

fq

ggplot(fq,aes(peso,prezzo_articolo))+
  geom_line()+
  labs(x='Peso',y='Prezzo articolo', title= 'Variazione prezzo per peso articolo')+
  theme_minimal()

#Query 5
# Come varia il prezzo di articolo_venduto in base al peso e alla linea_prodotto?



cq<-dbGetQuery(con, "
               SELECT prezzo_articolo,peso,linea_prodotto
               FROM articolo_venduto as av
               
               
               ")

cq

ggplot(cq,aes(peso,prezzo_articolo))+
  geom_line(color='orange')+
  labs(x='Peso',y='Prezzo articolo', title= 'Variazione prezzo per peso ')+
  facet_grid(.~linea_prodotto)+
  theme_minimal()
  
  


dbDisconnect(con)
