#### 301 - Hacinamiento ####

# Autor: Rodrigo Villegas Salgado
# version: 04-10-21
# email: rdvillegas@uc.cl
# status: production
# rol: data cleaning

# Librerías

library(tidyverse)
library(here)
library(glue)

# Indicador
indicator <- "3 - Equidad/301 - Hacinamiento"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
rawdatadir <- here("data/raw/censo/")
dirs <- getDirs(indicator)

# importar codigos de ciudad
source("src/functions/citycodes_import.R")

# añadir padding de 5 digitos a codigos
citycodes <- citycodes %>%
  mutate(cod_2017 = str_pad(cod_2017, width = 5, pad = "0"))

# Leer censo, filtrar por:
#   viviendas no colectivas (p01 < 8)
#   viviendas ocupadas (p02 == 1)
#   jefe de hogar (p07 == 1)
censo2017_hog <- readRDS(glue("{rawdatadir}/Censo2017_Persona_Full.Rds")) %>% 
  filter(p01 < 8 & p02 == 1, p07 == 1) %>%
  right_join(citycodes, by = c("comuna" = "cod_2017"))


# filtro de variables para calcular hacinamiento
censo2017_hac <- censo2017_hog %>% 
  mutate(#Filtrar Numero de piezas usadas exclusivamente como dormitorio
    p04 = case_when(p04 == 98 ~ NA_integer_,
                    p04 == 99 ~ NA_integer_,
                    TRUE~ p04),
    # Cantidad de hogares por vivienda
    cant_hog = case_when(cant_hog == 98 ~ NA_integer_,
                         cant_hog == 99 ~ NA_integer_,
                         TRUE ~ cant_hog),
    nhogar = case_when(cant_hog == 98 ~ NA_integer_,
                       cant_hog == 99 ~ NA_integer_,TRUE ~ cant_hog))

save(censo2017_hac, file = glue("{dirs@cleandatadir}/clean.RDS"))
