#### 308 -  Deficit de vivienda ####

# Autor: Rodrigo Villegas Salgado
# version: 22-10-21
# email: rdvillegas@uc.cl
# status: production
# rol: data cleaning

# Librerías

library(tidyverse)
library(here)
library(glue)

# Indicador
indicator <- "3 - Equidad/308 - Deficit de vivienda"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
rawdatadir <- here("data/raw/censo/")
dirs <- getDirs(indicator)

# importar codigos de ciudad
source("src/functions/citycodes_import.R")

# añadir padding de 5 digitos a codigos
citycodes <- citycodes %>%
  mutate(cod_2017 = str_pad(cod_2017, width = 5, pad = "0"),
         cod_2002 = str_pad(cod_2002, width = 5, pad = "0"))


# Leer censo, filtrar por:
#   viviendas no colectivas (p01 < 8)
#   viviendas ocupadas (p02 == 1)
censo2017 <- readRDS(glue("{rawdatadir}/Censo2017_Persona_Full.Rds"))  %>%
  filter(p01 < 8 & p02 == 1) %>%
  mutate(idhogar = paste(id_zona_loc, nviv, nhogar, cant_hog),
         idviv = paste(id_zona_loc, nviv)) %>%
  right_join(citycodes, by = c("comuna" = "cod_2017")) %>%
  select(geocode, comuna, city, idviv, idhogar, nhogar,cant_hog, cant_per, p01, p03a, p03b, p03c, p04, p07, p09, p10, p17, p20) 

censo2002 <- read_rds(glue("{rawdatadir}/Censo2002_Persona_Full.Rds")) %>%
  mutate(id = paste(portafolio, vn)) %>%
  filter(v1 < 9, v2 == 1) %>%
  select(portafolio, zc_loc, vn, hn, comuna, p17, p17, p18, p19, p27, p29, p23a, p35, v1, v4a, v4b, v4c, v7, v8)  %>%
  right_join(citycodes, by = c("comuna" = "cod_2002"))

save(censo2017, file = glue("{dirs@cleandatadir}/clean2017.RDS"))
save(censo2002, file = glue("{dirs@cleandatadir}/clean2002.RDS"))

