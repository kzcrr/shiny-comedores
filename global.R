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

mapa_comedores_deptos <- st_read ("C:/Users/kazcu/Desktop/Shinny/shiny/mapa_completo2.geojson")

mapa_comedores_provincia<-st_read("C:/Users/kazcu/Desktop/Shinny/shiny/mapa_completo_provincias_nbi.geojson")
agrupados_comedores_provincia<- read.xlsx("C:/Users/kazcu/Desktop/Shinny/shiny/comedores/agrupados_comedores_provincia.xlsx")

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


NBI <- readxl::read_excel("C:/Users/kazcu/Desktop/Shinny/shiny/comedores/total_depto_nbi.xlsx")


mapa_deptos_nbi<-read_sf("C:/Users/kazcu/Desktop/Shinny/shiny/comedores/mapa_nbi_depto_.geojson")



mapa_comedores_provincia$NBI[is.na(mapa_comedores_provincia$NBI)] <- 28602
mapa_comedores_provincia$porcentaje[is.na(mapa_comedores_provincia$porcentaje)] <- 15.4
