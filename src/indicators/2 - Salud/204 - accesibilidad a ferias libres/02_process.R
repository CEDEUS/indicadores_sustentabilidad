#### 204 - Accesibilidad a ferias ####

# Autor: Rodrigo Villegas Salgado
# version: 05-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: data processing

# Librerías
library(here)
library(dplyr)
library(glue)
library(opentripplanner)
library(sf)
# Indicador
indicator <- "2 - Salud/204 - accesibilidad a ferias libres"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# Importar datos limpios
ferias_clean <- readRDS(glue("{dirs@cleandatadir}/clean.RDS")) 

#### Calcular isocronas ####

# Inicializar server de OTP

datadirs <- readLines("data/raw/otplink.txt")
otpgraphs <- readLines("data/raw/otpgraphnames.txt")


# Check si OTP está funcionando
class(otpcon)

otp_dir <- datadirs[1]
otpjar_file <- datadirs[2]
log2 <- otp_setup(otp = otpjar_file, router = otpgraphs, dir = otp_dir, memory = (2048 * 5))

otpcon <- otp_connect()

# Llamado a calculo de isocronas
ferias_clean <- ferias_clean[125:127,]
# Generar isocronas y determinar el tipo (para luego eliminar los pedacitos chicos)
travel_time <- as.POSIXct(paste0("2020-10-12 ", "09:00:00"), tz=Sys.timezone())

isometro<-otp_isochrone(otpcon = otpcon, 
                        fromPlace = st_coordinates(ferias_clean), 
                        fromID = ferias_clean$rowid %>% as.character(), 
                        mode = "WALK",
                        date_time = travel_time, 
                        cutoffSec = c(600))



  mutate(type = st_geometry_type(.)) 

#### Intersectar isocronas con manzanas ####


#### Calcular porcentajes de población ####
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

