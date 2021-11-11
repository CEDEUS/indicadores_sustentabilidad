#### 203 - Salud Infantil ####

# Autor: Rodrigo Villegas Salgado
# version: 03-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: main script

library(glue)
library(here)

# Indicador
indicator <- "2 - Salud/203 - sobrepeso y obesidad infantil"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# Ejecutar scripts de trabajo

source(glue("{dirs@srcdir}/01_clean.R"), encoding = "utf-8")
source(glue("{dirs@srcdir}/02_process.R"), encoding = "utf-8")
source(glue("{dirs@srcdir}/03_export.R"), encoding = "utf-8")

