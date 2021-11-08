#### 202 - Años de vida potencialmente perdidos ####

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
indicator <- "2 - Salud/202 - avpp"

# Definir rutas de datos brutos

whdir <- readLines("data/raw/warehouselink.txt")

datadirs <- read.csv2("data/raw/datasources.csv", encoding = "UTF-8") %>%
  filter(indice == 202)

rawdefdatadir <- glue("{whdir}{datadirs$folder}")[1]
rawespdatadir <- glue("{whdir}{datadirs$folder}")[2]
rawpopdatadir <- glue("{whdir}{datadirs$folder}")[3]

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# importar codigos de ciudad
source("src/functions/citycodes_import.R")

# añadir padding de 5 digitos a codigos
citycodes <- citycodes %>%
  select(nom_com, city, cod_2017)

# Esperanza de vida para chile según datos de la DEIS. 
espvida <- read.csv2(glue("{rawespdatadir}esperanza_vida.csv"), fileEncoding = 'UTF-8-BOM') %>%
  pivot_longer(values_to = "EspVida", names_to = "sexo", cols = c("Hombre", "Mujer", "Ambos")) %>%
  #mutate(EspVida = as.numeric(EspVida) %>% round)
  mutate(EspVida = 70) # Test de comparacion


#### Tabla defunciones ####
# Las tablas de defunciones están organizadas en dos archivos.
def02 <- read.csv2(glue("{rawdefdatadir}DEF_1990-2018.csv")) %>%
  select(ANO_DEF, COMUNA, GLOSA_SEXO, EDAD_CANT, EDAD_TIPO) %>% # seleccionar columnas a trabajar
  filter(ANO_DEF >= 2002 & ANO_DEF < 2016)

# El header se rescata desde el diccionario de palabras
headerdef20 <- readxl::read_xlsx(glue("{rawdefdatadir}Diccionario de Datos BBDD-COVID19 liberada.xlsx"), skip = 3)
def20 <- read.csv2(glue("{rawdefdatadir}DEFUNCIONES_FUENTE_DEIS_2016_2021_21102021.csv"), header = F) %>%
  `colnames<-`(headerdef20[[2]]) %>% # Asignar los nombres correctos 
  select(ANO_DEF, CODIGO_COMUNA_RESIDENCIA, GLOSA_SEXO, EDAD_CANT, EDAD_TIPO) %>%# seleccionar columnas a trabaj
  rename(COMUNA = CODIGO_COMUNA_RESIDENCIA) %>%
  filter(ANO_DEF < 2021)

defs <- def02 %>% 
  rbind(def20) %>%
  filter(COMUNA %in% citycodes$cod_2017, # Aquellos que están en las comunas de análisis
         EDAD_TIPO != 9,
         GLOSA_SEXO != "Indeterminado") %>% # Aquellos cuya edad no sea inválida
  mutate(EDAD_CANT = ifelse(EDAD_TIPO != 1, 0, EDAD_CANT),
         edad_key = ifelse(EDAD_CANT <= 80, EDAD_CANT, 80)) %>% # Si la edad no está en años, entonces edad == 0 años.
  right_join(citycodes, by = c("COMUNA" = "cod_2017")) %>%# Unir con tabla de ciudades
  rename_all(tolower) %>%
  rename(sexo = glosa_sexo, 
         año = ano_def) %>%
  rowid_to_column("ID")

summary(defs)

# Obtener la población para cada área

# Poblacion comunal por año y grupo etareo
popcomage <- readxl::read_xlsx(glue("{rawpopdatadir}estimaciones-y-proyecciones-2002-2035-comunas.xlsx")) %>%
  mutate(sexo = recode(`Sexo\r\n1=Hombre\r\n2=Mujer`, "1" = "Hombre", "2" = "Mujer")) %>%
  select(Comuna, Edad, sexo,paste("Poblacion", c(2002:2020))) %>%
  pivot_longer(names_to = "año", values_to = "pop", cols = paste("Poblacion", c(2002:2020))) %>%
  mutate(año = str_remove(año, "Poblacion ") %>% str_trim %>% as.numeric(.)) %>%
  group_by(año, Comuna, sexo, Edad) %>%
  summarise(pop = sum(pop)) %>%
  rename(edad_key = Edad) %>%
  rename_all(tolower) %>%
  left_join(espvida) %>%
  filter(año >= Agno1 & año < Agno2) %>%
  mutate(EspVida = if_else(EspVida > 80, 80, EspVida)) %>%
  filter(edad_key <= EspVida) %>%
  group_by(año, comuna) %>%
  summarise(pop = sum(pop))


# Unir datos de mortalidad con datos de poblacion comunal y esperanza de vida
defsout <- defs %>%
  left_join(espvida) %>%
  filter(año >= Agno1 & año < Agno2) %>%
  rowwise() %>%
  mutate(AVPP = max(0, EspVida - edad_cant)) %>%
  left_join(popcomage)


  
  
# Exportar datos

save(defsout, file = glue("{dirs@cleandatadir}/clean.RDS"))

