library(shiny)
library(bslib)
library(ggplot2)
library(ggiraph)
library(plotly)
library(dplyr)
library(sf)
library(openxlsx)
library(readxl)
library(geoAr)
library(stringr)
library(shinyjs)
library(bsicons)
library(rsconnect)


mapa_comedores_deptos<-st_read("mapa_completo2.geojson")
mapa_comedores_provincia<-st_read("mapa_completo_provincias_nbi.geojson")

agrupados_comedores_provincia<-read.xlsx("agrupados_comedores_provincia.xlsx")


amba_municipios <- c(
  "Almirante Brown", "Avellaneda", "Berazategui", "Berisso", "Brandsen",
  "Campana", "Cañuelas", "Ensenada", "Escobar", "Esteban Echeverría",
  "Exaltación", "Ezeiza", "Florencio Varela", "Gral. Las Heras",
  "Gral. Rodríguez", "General San Martín", "Hurlingham", "Ituzaingó",
  "José C. Paz", "La Matanza", "La Plata", "Lanús", "Lomas de Zamora",
  "Luján", "Malvinas Argentinas", "Marcos Paz", "Merlo", "Moreno",
  "Morón", "Quilmes", "Pilar", "Presidente Perón", "San Fernando",
  "San Isidro", "San Miguel", "San Vicente", "Tigre", "Tres de Febrero",
  "Vicente López", "Zárate", "Comuna 1", "Comuna 2", "Comuna 3", "Comuna 4",
  "Comuna 5", "Comuna 6", "Comuna 7", "Comuna 8", "Comuna 9", "Comuna 10",
  "Comuna 11", "Comuna 12", "Comuna 13", "Comuna 14", "Comuna 15"
)




mapa_deptos_nbi<-read_sf("mapa_nbi_depto_.geojson")




#imputo unos datos que se me perdieron en el joint

mapa_comedores_provincia$NBI[is.na(mapa_comedores_provincia$NBI)] <- 28602
mapa_comedores_provincia$porcentaje[is.na(mapa_comedores_provincia$porcentaje)] <- 15.4
mapa_deptos_nbi$Departamento[mapa_deptos_nbi$nombre == "Puán"] <- "Puan"

mapa_deptos_nbi$porcentaje_NBI_depto_pobl[mapa_deptos_nbi$Departamento == "Puan"] <- 3.7
mapa_deptos_nbi$Departamento[mapa_deptos_nbi$nombre == "Juan Felipe Ibarra"] <- "Juan Felipe Ibarra"
mapa_deptos_nbi$porcentaje_NBI_depto_pobl[mapa_deptos_nbi$Departamento == "Juan Felipe Ibarra"]<- 16.3
