#### 201 - Mortalidad Evitable ####

# Autor: Rodrigo Villegas Salgado
# version: 05-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: data cleaning

# Librerías
library(here)
library(tidyverse)
library(glue)

# Indicador
indicator <- "2 - Salud/201 - mortalidad evitable"

# Definir rutas de datos brutos

whdir <- readLines("data/raw/warehouselink.txt")

datadirs <- read.csv2("data/raw/datasources.csv", encoding = "UTF-8") %>%
  filter(indice == 201)

rawdefdatadir <- glue("{whdir}{datadirs$folder}")[1]
rawpopdatadir <- glue("{whdir}{datadirs$folder}")[2]
prev_dir <- "data/other/rangos_muertesprevenibles/"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# importar codigos de ciudad
source("src/functions/citycodes_import.R")

# añadir padding de 5 digitos a codigos
citycodes <- citycodes %>%
  select(nom_com, city, cod_2017)

#### Tabla defunciones ####
# Las tablas de defunciones están organizadas en dos archivos.
def02 <- read.csv2(glue("{rawdefdatadir}DEF_1990-2018.csv")) %>%
  select(ANO_DEF, COMUNA, GLOSA_SEXO, EDAD_CANT, EDAD_TIPO, DIAG1) %>% # seleccionar columnas a trabajar
  filter(ANO_DEF >= 2002 & ANO_DEF < 2016)

# El header se rescata desde el diccionario de palabras
headerdef20 <- readxl::read_xlsx(glue("{rawdefdatadir}Diccionario de Datos BBDD-COVID19 liberada.xlsx"), skip = 3)
def20 <- read.csv2(glue("{rawdefdatadir}DEFUNCIONES_FUENTE_DEIS_2016_2021_21102021.csv"), header = F) %>%
  `colnames<-`(headerdef20[[2]]) %>% # Asignar los nombres correctos 
  select(ANO_DEF, CODIGO_COMUNA_RESIDENCIA, GLOSA_SEXO, EDAD_CANT, EDAD_TIPO, DIAG1) %>%# seleccionar columnas a trabaj
  rename(COMUNA = CODIGO_COMUNA_RESIDENCIA) %>%
  filter(ANO_DEF < 2021)

defs <- def02 %>% 
  rbind(def20) %>%
  filter(COMUNA %in% citycodes$cod_2017, # Aquellos que están en las comunas de análisis
                      EDAD_TIPO != 9,
         GLOSA_SEXO != "Indeterminado") %>% # Aquellos cuya edad no sea inválida
  mutate(EDAD_CANT = ifelse(EDAD_TIPO != 1, 0, EDAD_CANT), # Si la edad no está en años, entonces edad == 0 años.
         edad_grupo = cut(EDAD_CANT, breaks = seq(0,130,by=5), right = F, include.lowest = T), # Segmentar la edad cada 5 años
         edad_grupo = if_else(EDAD_CANT >= 80, "[80,100)", as.character(edad_grupo))) %>% # Aquellos que tengan +80 años son el mismo grupo
  right_join(citycodes, by = c("COMUNA" = "cod_2017")) %>%# Unir con tabla de ciudades
  rename_all(tolower) %>%
  rename(sexo = glosa_sexo, 
         año = ano_def) %>%
  rowid_to_column("ID")
 
summary(defs)

# Leer datos de rangos de muertes prevenibles

prev_codes <- read.csv2(glue("{prev_dir}rangos_muertesprevenibles.csv")) %>% # Códigos de muertes prevenibles 
  mutate(mainchar = str_extract(Char_Min, "\\D"),
         Sexo_prev = recode(Sexo, `1` = "Hombre", `2` = "Mujer", `0` = "Total")) %>%# Recodificar variables de sexo
  rename_all(tolower) %>%
  select(-sexo)
  


# Filtrar aquellas muertes que fueron prevenibles. No se considera COVID aún.

defsPrev <- defs %>%
  filter(str_detect(string = diag1, "\\D")) %>% # identificar casos con diagnosticos validos
  mutate(mainchar = str_extract(diag1, "\\D")) %>% # Generar una columna con el primer caracter de diag1
  left_join(prev_codes, by = "mainchar") %>% # Unir con tablas de muertes prevenibles. Se van a crear duplicados
  filter(diag1 >= char_min & diag1 <= char_max, # Seleccionar aquellos casos donde diag1 sea prevenible
         edad_cant >= edad_min & edad_cant <= edad_max, # La edad esté dentro del rango prevenible
         (sexo == sexo_prev | sexo_prev == "Total")) %>%# Y el sexo sea el correspondiente
  select(ID, año, comuna, sexo, edad_grupo, nom_com, city)

# Chequear que no hayan personas duplicadas y la operación se haya hecho bien
sum(duplicated(defsPrev$ID))

# Comunas y población por edad

# Poblacion comunal por año y grupo etareo
popcomage <- readxl::read_xlsx(glue("{rawpopdatadir}estimaciones-y-proyecciones-2002-2035-comunas.xlsx")) %>%
  mutate(edad_grupo = cut(Edad, breaks = seq(0,130,by=5), right = F, include.lowest = T),
         edad_grupo = if_else(Edad >= 80, "[80,100)", as.character(edad_grupo)), 
         sexo = recode(`Sexo\r\n1=Hombre\r\n2=Mujer`, "1" = "Hombre", "2" = "Mujer")) %>%
  select(Comuna, edad_grupo, sexo,paste("Poblacion", c(2002:2020))) %>%
  pivot_longer(names_to = "año", values_to = "pop", cols = paste("Poblacion", c(2002:2020))) %>%
  mutate(año = str_remove(año, "Poblacion ") %>% str_trim %>% as.numeric(.)) %>%
  group_by(año, Comuna, sexo, edad_grupo) %>%
  summarise(pop = sum(pop)) %>%
  rename_all(tolower)

# Poblacion nacional por año, grupo etareo y totalidad
popnational <- popcomage %>%
  group_by(año, edad_grupo, sexo) %>%
  summarise(popgrunat = sum(pop)) %>% #popgrunat: poblacion por grupo a nivel nacional
  group_by(año) %>%
  mutate(popnat = sum(popgrunat)) # popnat = poblacion nacional

# Unir datos de mortalidad con datos de poblacion comunal y nacional

defsout <- defsPrev %>%
  left_join(popcomage) %>%
  group_by(año, city, comuna, sexo, edad_grupo) %>%
  summarise(defs = sum(n()),
            pop = unique(pop)) %>%
  left_join(popnational)

# Exportar datos

save(defsout, file = glue("{dirs@cleandatadir}/clean.RDS"))
