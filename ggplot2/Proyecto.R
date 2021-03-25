current_folder <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(current_folder)

# https://ec.europa.eu/eurostat/databrowser/view/ILC_PW03__custom_607534/default/table?lang=en

#####################
library(eurostat)
library(dplyr)
library(tidyverse)
library(ggplot2)

dat <- get_eurostat("ilc_pw03", time_format = "date")

countries=c("DE", "BE", "ES", "FR", "IT", "NL", "UK", "SE", "CH")
dat <- dat[-c(1, 7)] 
colnames(dat) <- c('Nivel educativo', 'Confianza en', 'Sexo', 'Edad', 'Nacionalidad', 'Valor') 
dat <- filter(dat, Nacionalidad %in% countries)
dat <- dat [(dat$Edad=="Y_GE16"),]
dat <- dat [!(dat$Sexo=="T"),]
dat <- dat [!(dat$Nacionalidad=="EU27_2020"),]
dat <- dat [!(dat$Nacionalidad=="EU28"),]
dat <- dat [!(dat$`Nivel educativo`=="TOTAL"),]

dat <- dat[-c(4)] 
dat <- na.omit(dat)

dat$`Confianza en`[dat$`Confianza en`=="LEGTST"] <- 'Sistema legal'
dat$`Confianza en`[dat$`Confianza en`=="OTHTST"] <- 'Otros'
dat$`Confianza en`[dat$`Confianza en`=="PLCTST"] <- 'Policia'
dat$`Confianza en`[dat$`Confianza en`=="PLTTST"] <- 'Políticos'
dat$Sexo[dat$Sexo=="F"] <- 'Mujer'
dat$Sexo[dat$Sexo=="M"] <- 'Hombre'

tabla_con_sexo = aggregate(dat[,5], list(dat$Nacionalidad, dat$`Confianza en`, dat$Sexo), mean)
colnames(tabla_con_sexo) <- c('Nacionalidad', 'Instituciones', 'Sexo', 'Valor') 
tabla_sin_sexo = aggregate(dat[,5], list(dat$Nacionalidad, dat$`Confianza en`), mean)
colnames(tabla_sin_sexo) <- c('Nacionalidad', 'Instituciones', 'Valor') 
tabla_linea = aggregate(dat[,5], list(dat$Nacionalidad), mean)
colnames(tabla_linea) <- c('Nacionalidad', 'Valor')
tabla_linea$Instituciones <- "Policia"

ggplot(tabla_sin_sexo, aes(x = Nacionalidad, y = Valor, fill = Instituciones)) +
  geom_col(position = "dodge") +
  geom_point(data = tabla_con_sexo, position = position_dodge(width=0.9), aes(x = Nacionalidad, y = Valor, group = Instituciones, shape = Sexo), fill = "lightblue", size = 4) +
  geom_line(data = tabla_linea, aes(x = Nacionalidad, y = Valor, group = Instituciones, color = "Nivel medio confianza")) +
  geom_text(data = tabla_linea, aes(label = round(Valor, 1), group = Instituciones), vjust = 2)+
  xlab("País") +
  ylab("Nivel de confianza") + 
  scale_fill_manual(values = c('coral', 'olivedrab3', 'skyblue1', 'gray70')) +
  scale_shape_manual(values = c(3,4)) +
  scale_color_manual(name = "", values = c('black')) +
  ggtitle("Confianza en los Organismos Públicos de los países europeos del G12") +
  theme(plot.title = element_text(color = "darkblue", size = 14, face = "bold.italic", hjust = 0.5))+ 
  theme(axis.line = element_line(color = "black", size = 0.5, linetype = "solid")) 
