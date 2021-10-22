#### 308 -  Deficit de vivienda ####

# Autor: Rodrigo Villegas Salgado
# version: 22-10-21
# email: rdvillegas@uc.cl
# status: development
# rol: data processing

# Librerías

library(tidyverse)
library(here)
library(glue)

# Nombre Indicador
indicator <- "3 - Equidad/308 - Deficit de vivienda"
# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

load(file = glue("{dirs@cleandatadir}/clean2002.RDS"))
load(file = glue("{dirs@cleandatadir}/clean2017.RDS"))

#### Deficit de vivienda 2017 ####

### Calidad de Vivienda ###
cal_viv <-  censo2017 %>%
  filter(p07 == 1, nhogar == 1) %>%
  select(geocode, comuna, city, idviv, p01, p03a, p03b, p03c) %>%
  mutate(tipo_viv = case_when(p01 %in% c(1:4) ~ 1,
                              p01 %in% c(5:7) ~ 2,
                              is.na(p01)~ 0),
         muro = case_when(p03a %in% 1:3 ~ 1,
                          p03a %in% 4:5 ~ 2,
                          p03a %in% 6:6 ~ 3,
                          p03a %in% 99  ~ 0),
         techo = case_when(p03b %in% 1:3 ~ 1,
                           p03b %in% 4:5 ~ 2,
                           p03b %in% 6:7 ~ 3,
                           p03b %in% 99   ~ 0),
         piso  = case_when(p03c %in% 1:1 ~ 1,
                           p03c %in% 2:4 ~ 2,
                           p03c %in% 5:5 ~ 3,
                           p03c %in% 99  ~ 0),
         ind_mat = case_when(muro == 0 | techo == 0 | piso == 0 ~ 0,
                             muro == 1 & techo == 1 & piso == 1 ~ 1,
                             muro == 3 | techo == 3 | piso == 3 ~ 3,
                             muro == 2 & techo <  3 & piso <  3 ~ 2,
                             muro <  3 & techo == 2 & piso <  3 ~ 2,
                             muro <  3 & techo <  3 & piso == 2 ~ 2),
         indmat_muro = case_when(muro == 0 | techo == 0 | piso == 0 ~ 0,
                                 muro == 1 & techo == 1 & piso == 1 ~ 1,
                                 muro == 2 & techo == 1 & piso == 1 ~ 4,
                                 muro == 3 | techo == 3 | piso == 3 ~ 3,
                                 muro == 2 & techo == 2 & piso <  3 ~ 2,
                                 muro == 2 & techo <  3 & piso == 2 ~ 2,
                                 muro <  3 & techo == 2 & piso <  3 ~ 2,
                                 muro <  3 & techo <  3 & piso == 2 ~ 2),
         cal_viv_aj = case_when(indmat_muro == 0 ~ 0,
                                tipo_viv == 1 & indmat_muro == 1 ~ 1,
                                tipo_viv == 1 & indmat_muro == 4 ~ 1,
                                tipo_viv == 1 & indmat_muro == 2 ~ 2,
                                tipo_viv == 2 | indmat_muro == 3 ~ 3),
         TGCV = case_when(cal_viv_aj == 3 ~ 1,
                          T ~ 0)) %>%
  select(city, comuna, geocode, idviv, TGCV)  %>%
  group_by(city, comuna, geocode) %>%
  summarise(TGCV = sum(TGCV, na.rm = T))

### Allegamiento Externo ###


alle_ext <-  censo2017 %>%
  filter(p07 == 1, nhogar == 1) %>%
  mutate(n_viv = 1,
         n_hog = cant_hog,
         alle_ext = n_hog - n_viv)  %>%
  select(city, comuna, geocode, idviv, alle_ext)  %>%
  group_by(city, comuna, geocode) %>%
  summarise(alle_ext = sum(alle_ext, na.rm = T))

### Allegamiento Interno ###

# Calcular Nucleos secundarios
nucleos <- censo2017 %>%
  filter(p10 == 1) %>%
  group_by(city, comuna, idviv, idhogar) %>%
  summarise(yeronu = sum(p07 == 11),
            hijasmadre =  sum((p07 == 5 | p07 == 6) & p09 >= 15 & (p20 >= 1 & p20 < 97)),
            nieto = sum(p07 == 12),
            padres = sum(p07 == 8),
            suegro = sum(p07 == 10),
            hrno = sum(p07 == 7),
            cunado = sum(p07 == 9),
            otropar = sum((p07 == 13 | p07 == 14)),
            otronopar = sum(p07 == 15)) %>%
  mutate(nu_hijasmadres = sum(hijasmadre[yeronu == 0 & nieto >= 1]),
         nu_pad_su = case_when(padres + suegro < 2 ~ 0,
                               padres + suegro >= 2 & padres + suegro < 3 ~ 1,
                               padres + suegro >= 3 ~ 2),
         nu_hrnos = case_when(cunado + hrno < 2 ~ 0,
                              cunado + hrno >= 2 & cunado + hrno < 4 ~ 1,
                              cunado + hrno >= 4 ~ 2),
         nu_otropar = case_when(otropar < 2 ~ 0,
                                otropar >= 2 & otropar < 4 ~ 1,
                                otropar >= 4 ~ 2),
         nu_otronopar = case_when(otronopar < 2 ~ 0,
                                  otronopar >= 2 & otronopar < 4 ~ 1,
                                  otronopar >= 4 ~ 2)) %>%
  group_by(city, comuna,idviv, idhogar) %>%
  summarise(nu_yernos = sum(yeronu),
            nu_hijasmadres = sum(hijasmadre[yeronu == 0 & nieto >= 1]),
            nu_hrnos = sum(nu_hrnos),
            nu_pad_su = sum(nu_pad_su),
            nu_otropar = sum(nu_otropar),
            nu_otronopar = sum(nu_otronopar),
            nuc_alle = sum(nu_yernos, nu_hijasmadres, nu_hrnos, nu_pad_su,
                           nu_otropar, nu_otronopar, na.rm = T)) %>%
  select(city, comuna,idviv, idhogar, nuc_alle)

# Calcular Indice de hacinamineto
hacinamiento <- censo2017 %>%
  filter(p07 == 1, nhogar == 1) %>%
  mutate(hacin = case_when(p04 > 0 & p04 != 99 ~ cant_per/p04,
                           p04 == 0 ~ 5),
         hacin_indi = case_when(hacin <= 2.4 ~ 1,
                                hacin > 2.4 & hacin <= 4.9 ~ 2,
                                hacin > 4.9 ~ 3,
                                T ~ 0)) %>%
  select(city, comuna, geocode, idviv, hacin,  hacin_indi)
# Calcular Indice de dependencia económica
dep_eco <- censo2017 %>%
  select(city, comuna,idviv, idhogar, p17, p09) %>%# filter(P10 == 1 ) %>%
  group_by(city, comuna,idviv, idhogar) %>%
  summarise(con_ingreso = sum(p17 == 1 | p17 == 3 | p17 == 7, na.rm = T),
            sin_ingreso = sum(p17 == 2, na.rm = T) + sum(p17 >= 4 & p17 < 7, na.rm = T) + sum(p17 == 8, na.rm = T) + sum(p09 < 15, na.rm = T), 
            depend_bruto = if_else(con_ingreso != 0, sin_ingreso/con_ingreso, NA_real_),
            depend_econ = case_when(depend_bruto < 1.1 ~ 1,
                                    depend_bruto >= 1.1 & depend_bruto < 2.6 ~ 2,
                                    depend_bruto >= 2.6 ~ 3,
                                    con_ingreso == 0 ~ 3)) %>%
  select(city, comuna,idviv, idhogar, depend_econ)

# Combinar los tres y generar el allegamiento interno

alle_int <- dep_eco  %>%
  full_join(hacinamiento) %>%
  full_join(nucleos) %>%
  ungroup() %>%
  mutate(alle_int = case_when(hacin_indi >= 2 & depend_econ < 3 ~ nuc_alle,
                              T ~ 0)) %>%
  select(city, comuna, geocode, idviv, idhogar, alle_int) %>%
  group_by(city, comuna, geocode) %>%
  summarise(alle_int = sum(alle_int, na.rm = T))

### Déficit cuantitativo de vivienda ###

deficit2017 <- alle_int %>%
  full_join(cal_viv) %>%
  full_join(alle_ext) %>%
  ungroup() %>%
  mutate(Deficit = `TGCV` + alle_int + alle_ext)

#### Deficit de vivienda 2002 ####

### Calidad de Vivienda ###
tgcv <- censo2002 %>%
  mutate(id = paste(portafolio, vn)) %>%
  filter(!duplicated(id)) %>%
  mutate(pared = case_when(v4a %in% c(1:4) ~ 1,
                           v4a %in% c(5:6) ~ 2,
                           v4a %in% c(7)   ~ 3),
         techo = case_when(v4b %in% c(1:5) ~ 1,
                           v4b %in% c(6:8) ~ 2,
                           v4b %in% c(9)   ~ 3),
         piso  = case_when(v4c %in% c(1:4, 6) ~ 1,
                           v4c %in% c(5, 8) ~ 2,
                           v4c %in% c(7, 9)   ~ 3),
         imv = case_when(pared == 1 & techo == 1 & piso == 1 ~ 1,
                         pared == 2 & techo <= 2 & piso <= 2 ~ 2,
                         pared <= 2 & techo == 2 & piso <= 2 ~ 2,
                         pared <= 2 & techo <= 2 & piso == 2 ~ 2,
                         pared == 3 & techo <= 3 & piso <= 3 ~ 3,
                         pared <= 3 & techo == 3 & piso <= 3 ~ 3,
                         pared <= 3 & techo <= 3 & piso == 3 ~ 3),
         sancane = case_when(v7 == 1 ~ 1,
                             v7 %in% c(2:3) ~ 2),
         sanwc = case_when(v8 %in% c(1:2) ~ 1,
                           v8 %in% c(3:6) ~ 2),
         isv = case_when(sancane == 1 & sanwc == 1 ~ 1,
                         sancane == 2 & sanwc == 1 ~ 1,
                         sancane == 1 & sanwc == 2 ~ 2,
                         sancane == 2 & sanwc == 2 ~ 2),
         itv = case_when(v1 %in% c(1:3) ~ 1,
                         v1 %in% c(4:8) ~ 2),
         tgcv = case_when(itv == 1 & isv == 1 & imv == 1 ~ 1,
                          itv == 1 & isv == 1 & imv == 2 & pared == 2 & techo == 1 & piso == 1 ~ 1,
                          itv == 2 ~ 3,
                          itv == 1 & imv == 3 ~ 3,
                          !is.na(itv) & !is.na(isv) & !is.na(imv) ~ 2)) %>%
  select(city, comuna, zc_loc, imv, isv, itv, tgcv) %>%
  group_by(city, comuna, zc_loc) %>%
  summarise(tgcv = sum(tgcv, na.rm = T))
### Allegamiento Interno ###

### Allegamiento Externo ###

### Déficit cuantitativo de vivienda ###


# Guardar resultados

#save(hacinam_cty, file = glue("{dirs@cleandatadir}/hacinam_cty.RDS"))
#save(hacinam_com, file = glue("{dirs@cleandatadir}/hacinam_com.RDS"))
#save(hacinam_pmc, file = glue("{dirs@cleandatadir}/hacinam_pmc.RDS"))

