# Función para extraer datos de obesidad a partir de los excels de junaeb


excelReader <- function(path, grado){
  # Extraer el año a partir del nombre del archivo
  agno <- stri_extract_last_regex(path, "\\d{4}")
  # Corregir los nombres de la primera fila del excel, que contiene los grupos
  head1 <- read_excel(path, sheet = grado, col_names = TRUE) %>% 
    names() %>% 
    str_replace("\\...\\d*", NA_character_) %>% tibble() %>% 
    mutate(head1 = zoo::na.locf0(.)) %>% 
    pull()
  # guardar el numero de columnas de la primera fila
  ncols <- length(head1)
  # Corregir la segunda fila, que contiene las condiciones de los estudiantes
  head2 <- read_excel(path, sheet = grado, skip = 1, col_names = TRUE) %>% 
    names() %>% 
    str_remove("\\.\\.\\.\\d*$")
  # Combinar ambas filas para generar los headers de las columnas
  headers <- map_chr(1:ncols, ~ {
    case_when(!is.na(head1[.x]) & !is.na(head2[.x]) ~ paste(head1[.x], head2[.x], sep = "_"),
              TRUE ~ head2[.x])})
  # Leer excel con nuevos headers
  obesidad <- read_excel(path, skip = 2, col_names = headers, sheet = grado) %>%
    # Estandarizar nombres
    rename_all(tolower) %>%
    # Seleccionar casos en donde sólo hayan casos de obesidad y sobrepeso para estudiantes
    select(comuna, "área geográfica", contains("n° estudiantes con la"), contains("total estudiantes")) %>%
    select(-ends_with(c("desnutrición", "normal", "obesidad", "severa","bajo peso", "talla"))) %>%
    # Unir con tabla de ciudades
    right_join(citycodes, by = c("comuna" = "cod_2017")) %>% 
    rename("obesidad" = contains("obesidad"),
           "urbarural" = "área geográfica",
           "sobrepeso" = contains("sobrepeso"),
           "total" = contains("total estudiantes")) %>%
    # procesar datos
    filter(str_detect(urbarural, "(?i)urbano")) %>%
    
    mutate(agno = agno) %>%
    group_by(agno, comuna, nom_com, city) %>%
    summarise(grado = grado,
              obesos = sum(sobrepeso, obesidad),
              total = sum(total))
  return(obesidad)
  
}