#### 203 - Salud Infantil ####

# Autor: Rodrigo Villegas Salgado
# version: 03-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: data processing

# Librerías

library(tidyverse)
library(here)
library(glue)


# Indicador
indicator <- "2 - Salud/203 - sobrepeso y obesidad infantil"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# importar codigos de ciudad
source("src/functions/citycodes_import.R")

load(file = glue("{dirs@cleandatadir}/clean.RDS"))


# Procesar los datos a nivel comunal

diagnutr_com <- diagnutr %>%
  group_by(agno, comuna, nom_com, city) %>%
  summarise(sobobesum = sum(sobobesum),
            total = sum(total),
            percent = round(sobobesum * 100/total, 1 )) %>%
  select(-sobobesum, -total) 

# Procesar los datos a nivel ciudad

diagnutr_city <- diagnutr %>%
  group_by(agno, city) %>%
  summarise(sobobesum = sum(sobobesum),
            total = sum(total),
            percent = round(sobobesum * 100/total, 1 )) %>%
  select(-sobobesum, -total) 

# Procesar los datos a nivel comunal para el pmc

diagnutr_pmc <- diagnutr %>%
  group_by(agno, comuna) %>%
  summarise(sobobesum = sum(sobobesum),
            total = sum(total),
            dato = round(sobobesum * 100/total, 1 )) %>%
  ungroup() %>%
  rename(codcomuna = comuna) %>%
  select(-sobobesum, -total) 

# Guardar resultados

save(diagnutr_com, file = glue("{dirs@cleandatadir}/diagnutr_com.RDS"))
save(diagnutr_city, file = glue("{dirs@cleandatadir}/diagnutr_city.RDS"))
save(diagnutr_pmc, file = glue("{dirs@cleandatadir}/diagnutr_pmc.RDS"))
