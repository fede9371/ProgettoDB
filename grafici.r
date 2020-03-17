library(ggplot2)

# Query 
#1)Per ogni mercato, vogliamo individuare il numero di clienti

fq<-dbGetQuery(con, "
           SELECT mercato.nome, count(c.p_iva)
           FROM cliente as c, mercato
           WHERE c.mercato=mercato.nome
           GROUP BY mercato.nome;
           
           ")


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
  labs(x='Peso',y='Prezzo articolo', title= 'Variazione prezzo per peso articolo')+
  facet_grid(.~linea_prodotto)+
  theme_minimal()
  
