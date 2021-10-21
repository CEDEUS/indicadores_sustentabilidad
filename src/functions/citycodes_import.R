# Función para leer los city codes
library(here)
library(glue)
codesdir <- here("data/other/citycodes/")

citycodes <- read.csv2(glue("{codesdir}/codigos_ciudad.csv"))
