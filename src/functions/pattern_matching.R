# Funcion para identificar la palabra más cercana entre una palabra y un vector
# de palabras.

ClosestMatch = function(string, stringVector , dist){
  
  stringVector[stringdist::amatch(string, stringVector, maxDist = dist)]
  
}

# Una extensión de ClosestMatch para identificar la palabra más parecida en un
# set. La adaptación se hizo para filtrar nombres de comunas abreviadas en text.

match_name2 <- function(string1, string2, dist = 10) {
  first_letter <- stringr::str_extract(string1, "^\\D")
  words <- stringr::str_split(string1, " ") %>% unlist
  last_word <- words[length(words)]
  
  # Seleccionar aquellas palabras que empiecen igual que el original
  starting1 <- grep(paste0("^", first_letter, ""), x = string2, ignore.case = T)
  # O seleccionar aquellas palabras que contengan al menos la última palabra
  starting2 <- grep(last_word, x = string2, ignore.case = T)
  # Unir ambos casos
  starting <- c(starting1, starting2)
  # Filtrar las palabras según los criterios anteriores
  target_word <- string2[starting]
  # Calcualr la palabra más parecida a la original
  ClosestMatch(last_word, target_word, dist = 15)
}


match_name <- function(string1, string2, dist = 15) {
  
  # Realizar un primer intento, en donde se busca el cercano más próximo en bruto
  preliminar_result <- ClosestMatch(string1, string2, dist = dist)
  
  # Si los resultados no tienen las mismas iniciales, entonces se prueba otra forma
  if (check_firstlast(string1, preliminar_result %>% str_remove(".php"))) {
    return(preliminar_result)
  }
  
  
  first_letter <- stringr::str_extract(string1, "^\\D")
  words <- stringr::str_split(string1, " ") %>% unlist
  last_word <- words[length(words)]
  
  # Seleccionar aquellas palabras que empiecen igual que el original
  firstword_string2 <- grep(paste0("^", first_letter, ""), x = string2, 
                    ignore.case = TRUE)
  # O seleccionar aquellas palabras que contengan al menos la última palabra
  firstword_string2 <- if (length(firstword_string2) == 0) {
    grep(last_word, x = string2, ignore.case = TRUE)
  }
  # Y si aún así no hay nada, entonces usar la palabra que más se parezca
  if (length(firstword_string2) == 0) {
    firstword_string2 <- grep(pattern = 
                                ClosestMatch(last_word, string2, dist = dist),
                              x = string2)
  }
  
  # Filtrar las palabras según los criterios anteriores
  target_word <- string2[firstword_string2]
  # Calcualr la palabra más parecida a la original
  ClosestMatch(last_word, target_word, dist = dist)
  
  #ClosestMatch(string1, string2, dist = dist)
}

# Funcion para chequear si la priemra y ultima letra coinciden
check_firstlast <- function(string1, string2){
  string1 <- tolower(string1)
  string2 <- tolower(string2)
  first_letter1 <- stringr::str_extract(string1, "^\\D")
  first_letter2 <- stringr::str_extract(string2, "^\\D")
  
  last_letter1 <- stringr::str_extract(string1, "\\D$")
  last_letter2 <- stringr::str_extract(string2, "\\D$")
  
  first_letter1 == first_letter2 & last_letter1 == last_letter2 
}
