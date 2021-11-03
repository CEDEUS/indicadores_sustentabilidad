#### 203 - Salud Infantil ####

# Autor: Rodrigo Villegas Salgado
# version: 03-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: data cleaning

# Librerías
library(here)
library(tidyverse)
library(glue)
library(readxl)
library(zoo)
library(stringi)


# Indicador
indicator <- "2 - Salud/203 - Salud Infantil"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# importar codigos de ciudad
source("src/functions/citycodes_import.R")

# añadir padding de 5 digitos a codigos
citycodes <- citycodes %>%
  select(nom_com, city, cod_2017)

# Importar función para leer excels de junaeb
source("src/indicators/2 - Salud/203 - Salud infantil/auxiliar/excelReader.R", encoding = "utf-8")

# Obtener lista con archivos 
listaArchivos <- list.files(dirs@rawdatadir, pattern = ".xlsx",full.names = T) 

# Las hojas de interés en cada archivo. En este caso, Kínder y 1° Básico
grados <- c("Kínder","1° Básico")
# Combinar ambos en un dataframe
archivosGradosDF <- data.frame(file = listaArchivos, grado = grados)

# Usar un nested lapply para iterar por todas las combinaciones de archivos y grados
#  TODO: No me funciona el mapply :C
diagnutr <- lapply(listaArchivos, 
                function(files) {
                  lapply(grados, function(grados){
                    excelReader(files, grados)})
                })
# Dado que es un nested lapply, hay que hacer dos veces el do.call
diagnutr <- do.call(rbind, diagnutr)
diagnutr <- do.call(rbind, diagnutr)

save(diagnutr, file = glue("{dirs@cleandatadir}/clean.RDS"))

