#### 202 - Años de vida potencialmente perdidos ####

# Autor: Rodrigo Villegas Salgado
# version: 08-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: data processing

# Librerías
library(here)
library(tidyverse)
library(glue)

# Indicador
indicator <- "2 - Salud/202 - avpp"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# Importar datos limpios
load(file = glue("{dirs@cleandatadir}/clean.RDS"))
defsout <- defsout %>%
  rename(agno = año)


# Avpp a nivel comunal
avpp_com <- defsout %>%
  group_by(agno, comuna, nom_com, city) %>%
  summarise(AVPP = sum(AVPP),
            pop = unique(pop)) %>%
  mutate(AVPP = AVPP / pop * 100000) %>%
  select(-pop)

# Defunciones a nivel ciudad
avpp_city <- defsout %>%
  group_by(agno, city) %>%
  summarise(AVPP = sum(AVPP),
            pop = sum(unique(pop))) %>%
  mutate(AVPP = AVPP / pop * 100000) %>%
  select(-pop)

# Defunciones a nivel pmc
avpp_pmc <- defsout %>%
  group_by(agno, comuna) %>%
  summarise(AVPP = sum(AVPP),
            pop = unique(pop)) %>%
  mutate(dato = AVPP / pop * 100000) %>%
  select(-c(AVPP, pop)) %>%
  rename(codcomuna = comuna) %>%
  ungroup


# Guardar resultados

save(avpp_com, file = glue("{dirs@cleandatadir}/avpp_com.RDS"))
save(avpp_city, file = glue("{dirs@cleandatadir}/avpp_city.RDS"))
save(avpp_pmc, file = glue("{dirs@cleandatadir}/avpp_pmc.RDS"))

