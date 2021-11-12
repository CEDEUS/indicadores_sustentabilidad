#### 202 - Años de vida potencialmente perdidos ####

# Autor: Rodrigo Villegas Salgado
# version: 08-11-21
# email: rdvillegas@uc.cl
# status: development
# rol: main script

library(glue)
library(here)

# Indicador
indicator <- "2 - Salud/202 - avpp"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)


# Ejecutar scripts de trabajo

source(glue("{dirs@srcdir}/01_clean.R"), encoding = "utf-8")
source(glue("{dirs@srcdir}/02_process.R"), encoding = "utf-8")
source(glue("{dirs@srcdir}/03_export.R"), encoding = "utf-8")

