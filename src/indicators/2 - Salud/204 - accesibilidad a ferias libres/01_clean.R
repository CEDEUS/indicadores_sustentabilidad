#### 204 - Accesibilidad a ferias ####

# Autor: Rodrigo Villegas Salgado
# version: 05-11-21
# email: rdvillegas@uc.cl
# status: development
# rol: data cleaning

# Librerías
library(here)
library(tidyverse)
library(glue)



# Indicador
indicator <- "2 - Salud/204 - accesibilidad a ferias libres"

# Definir rutas de datos brutos

whdir <- readLines("data/raw/warehouselink.txt")

datadirs <- read.csv2("data/raw/datasources.csv", encoding = "UTF-8") %>%
  filter(indice == 202)
rawdatadir <- glue("{whdir}{datadirs$folder}")

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# importar codigos de ciudad
source("src/functions/citycodes_import.R")

# añadir padding de 5 digitos a codigos
citycodes <- citycodes %>%
  select(nom_com, city, cod_2017)


