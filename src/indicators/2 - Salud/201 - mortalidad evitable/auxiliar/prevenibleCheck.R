# Funcion de ayuda para identificar si la muerte era prevenible:
# Parte por identificar la causa de la muerte y luego chequea si la 
# edad de la defunción se encuentra dentro de lo que se encuentra 
# prevenible. Arroja 1 si era prevenible y 0 si no lo era.
prevenibleCheck <- function(edad, codigo) {
  codigolin <- filter(prev_codes, codigo >= Char_Min, 
                      codigo <= Char_Max) # Identifica si la enfermedad del paciente es prevenible
  condition <- ifelse(nrow(codigolin) == 0, F, # Si la enfermedad no era prevenible, arroja 0
                      with(codigolin, edad >= Edad_min # Si era prevenible, y cumple con el requisito de edad, arroja 1
                           & edad <= Edad_max))
  return(condition)
}