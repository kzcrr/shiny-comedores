#Preprocesamiento

library(sf)
library(geoAr)
library(tidyverse)
library(readxl)


#bajamos codigos censales porque las bases no tienen los mismos códigos

codigos<- read_xlsx("C:/Users/kazcu/Desktop/Renacom/codigos_pais_dept.xlsx")

#bajamos polígonos de la libreria geoAr

mapa_argentina_provincias <- get_geo("ARGENTINA", level = "provincia")
mapa_argentina_departamentos <- get_geo("ARGENTINA", level = "departamento")
class(mapa_argentina_departamentos)

#chequeamos rapidamente que esten todos los códigos
plot(mapa_argentina_departamentos[,2])

deptos <- get_departamentos(orden = "id", max = 600)


deptos <- deptos %>%
  mutate(etiqueta = paste0(provincia_nombre, ", ", nombre))

codigos<- codigos %>% 
  mutate(etiqueta= paste0(Provincia, ", ", `Departamento/ partido/ comuna`))


# Unimos las tablas de codigos y deptos

deptos_actualizado <- deptos %>%
  left_join(codigos %>% select(etiqueta, nuevo_id = `Código concatenado`), by = "etiqueta") %>%
  mutate(id = ifelse(!is.na(nuevo_id), nuevo_id, id)) %>%
  select(-nuevo_id)  


mapa_argentina_departamentos <- mapa_argentina_departamentos %>%
  mutate(id = paste0(codprov_censo, coddepto_censo)) 

mapa_completo <- mapa_argentina_departamentos %>%
  left_join(deptos %>% select(id, nombre, provincia_nombre), by = "id")

mapa_completo <- mapa_argentina_departamentos %>%
  left_join(deptos_actualizado %>% select(id, nombre, provincia_nombre), by = "id")


#datos de comedores

comedores <- read_excel("C:/Users/kazcu/Downloads/Renacom rta 22-5.xlsx")

comedores <- comedores %>%
  mutate(departamento = case_when(
    departamento == "Ciudad Libertador San Martín" ~ "General San Martín",
    departamento == "José M. Ezeiza" ~ "Ezeiza",
    departamento == "Villa Constitución" ~ "Constitución",
    departamento == "Juan F. Ibarra" ~ "Juan Felipe Ibarra",
    departamento == "9 de julio" ~ "9 de Julio",
    departamento == "General Ocampo" ~ "General Ortiz de Ocampo",
    TRUE ~ departamento  
  ))


comedores<- comedores %>% select(departamento, tipo_espacioComunitario, cantidad_asistentes,localidad,provincia, Prescripcion )
write.xlsx(comedores, file = "C:/Users/kazcu/Desktop/Shinny/shiny/comedores/comedores_2023_renacom.xlsx")


#Limpiamos valores repetidos 

comedoreslimpio <- comedores %>%
  group_by(across(-Prescripcion)) %>% 
  slice(1) %>%                         
  ungroup()  

conteo_iguales <- comedores %>%
  group_by(across(-Prescripcion)) %>% 
  mutate(count = n()) %>%                
  ungroup() %>% 
  filter(count > 1) 

unicos <-  conteo_iguales %>%
  distinct(across(-Prescripcion), .keep_all = TRUE)

unicos$count<-as.numeric(unicos$count)
suma<-sum(unicos$count,  na.rm = TRUE)

comedoreslimpio <- comedoreslimpio %>%
  mutate(etiqueta = paste0(provincia, ", ", departamento))


mapa_completo1 <- mapa_completo %>%
  mutate(etiqueta = paste0(provincia_nombre, ", ", nombre))


agrupados_comedores <- comedoreslimpio %>%
  group_by(etiqueta) %>%
  summarise(
    total_comedores = n(),  
    total_asistentes = sum(cantidad_asistentes, na.rm = TRUE),  
    promedio_asistentes = mean(cantidad_asistentes, na.rm = TRUE))  

agrupados_comedores_provincia <- comedoreslimpio %>%
  group_by(provincia) %>%
  summarise(
    total_comedores = n(),  
    total_asistentes = sum(cantidad_asistentes, na.rm = TRUE),  
    promedio_asistentes = round(mean(cantidad_asistentes, na.rm = TRUE)))

#mapa_deptos
mapa_completo2 <- mapa_completo1 %>%
  left_join(agrupados_comedores, by = "etiqueta")




colnames(codigos)[colnames(codigos) == "Código provincia"] <- "codprov_censo"

mapa_argentina_provincias <- mapa_argentina_provincias %>%
  st_cast("MULTIPOLYGON") %>%  
  st_make_valid()


codigos_prov<-codigos %>% 
  select(codprov_censo,Provincia) %>% 
  distinct(across(Provincia), .keep_all = TRUE) 

mapa_completo <- mapa_argentina_provincias %>%
  left_join(codigos_prov , by = "codprov_censo")



mapa_comedores_provincia <- merge(mapa_argentina_provincias, codigos_prov[, c("codprov_censo", "Provincia" )], by = "codprov_censo", all.x = TRUE)

mapa_comedores_provincia <- mapa_comedores_provincia %>% 
  left_join(agrupados_comedores_provincia, by= c("Provincia" = "provincia"))





