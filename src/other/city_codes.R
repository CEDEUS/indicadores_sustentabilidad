# Script que genera tabla de codigos de ciudad y comuna
library(tidyverse)
library(here)
library(glue)
datadir <- here("data/raw/common/codes/")
outdir <- here("data/output/citycodes/")
# Codigos históricos

# Algunos están duplicados, pero no pasa nada

codes_old <- read_csv2(glue("{datadir}/codigos_dpa_historico.csv")) %>%
  rename(cod_2002 = `Código Comuna desde 2000`, cod_2008 = `Código Comuna desde 2008`, cod_2012 = `Código Comuna desde 2010`, nom_com = `Nombre Comuna`) %>%
  select(nom_com, cod_2002, cod_2008, cod_2012)

# Codigos actuales

codes_current <- read_csv2(glue("{datadir}/codigos_2018.csv")) %>%
  rename(cod_2017 = `Código Comuna 2017`, nom_com = `Nombre Comuna`) %>%
  select(nom_com, cod_2017)


# Codigos de ciudad

city_codes <- read.csv2(glue("{datadir}/codigos_com_pre2017.csv"))

# Unir codigos

codes <- codes_old %>%
  right_join(city_codes, by = c("nom_com", "cod_2012" = "Codigo")) %>%
  left_join(codes_current) %>%
  select(nom_com, city, cod_2002, cod_2008, cod_2012, cod_2017 ) %>%
  mutate(cod_2017 = if_else(cod_2012 == 13121, 13121, cod_2017))

# Tests para verificar que códigos están bien asignados
codes[codes$nom_com == "Valdivia", "cod_2002"] == 10501
codes[codes$nom_com == "Valdivia", "cod_2008"] == 14101
codes[codes$nom_com == "Chillán", "cod_2002"] == 8401
codes[codes$nom_com == "Chillán", "cod_2008"] == 8401
codes[codes$nom_com == "Chillán", "cod_2017"] == 16101


# Exportar resultados
write.csv2(codes, glue("{outdir}/codigos_ciudad.csv"), row.names = F)
