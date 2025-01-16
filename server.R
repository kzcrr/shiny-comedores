


# Server
shinyServer(function(input, output, session) {
  
  #reactividad
  
  current_story <- reactiveVal(1)
  show_storytelling <- reactiveVal(TRUE)
  modal_visible <- reactiveVal(FALSE) 
  show_dept_map <- reactiveVal(FALSE)
  selected_provincia <- reactiveVal(NULL)
  selected_variable <- reactiveVal("total_comedores") 
  show_amba <- reactiveVal(FALSE)
  show_legend <- reactive(!show_storytelling())
  
  
  observe({
    if (show_storytelling()) {
      shinyjs::runjs("document.getElementById('controls-and-cards').className = 'hidden-during-story';")
    } else {
      shinyjs::runjs("document.getElementById('controls-and-cards').className = 'hidden-during-story visible';")
    }
  })
  
  #actualiza en base a los clicks en los botones
  observeEvent(input$btn_comedores, {
    selected_variable("total_comedores")
  })
  
  observeEvent(input$btn_asistentes, {
    selected_variable("total_asistentes")
  })
  
  observeEvent(input$btn_nbi, {
    selected_variable("total_nbi")
  })
  
  # actualiza en base a los clicks en el map
  observeEvent(input$map_selected, {
    selected_provincia(input$map_selected)
    show_dept_map(TRUE)
    print(paste("Provincia seleccionada:", input$map_selected))  
    if (!input$map_selected %in% c("Buenos Aires", "Ciudad Autónoma de Buenos Aires")) {
      show_amba(FALSE)
    }
  })
  observeEvent(input$btn_amba, {
    show_amba(!show_amba())
    
    
  })
  
  
  observeEvent(input$reset_view, {
    show_amba(FALSE)
    selected_provincia(NULL)
  })
  
  observe({
    if (show_dept_map()) {
      shinyjs::addClass(id = "map-wrapper", class = "dept-map")
      shinyjs::removeClass(id = "map-wrapper", class = "national-map")
    } else {
      shinyjs::addClass(id = "map-wrapper", class = "national-map")
      shinyjs::removeClass(id = "map-wrapper", class = "dept-map")
    }
  })
  
  # Agregar un botón para volver al mapa nacional
  observeEvent(input$return_to_map, {
    selected_provincia(NULL)
    show_dept_map(FALSE)
  })
  
  
  # Reactividad
  provincia_data <- reactive({
    req(selected_provincia())
    filter(agrupados_comedores_provincia, provincia == selected_provincia())
  })
  
  total_comedores_val <- reactive({
    if (is.null(selected_provincia())) return(sum(agrupados_comedores_provincia$total_comedores))
    sum(provincia_data()$total_comedores)
  })
  
  total_asistentes_val <- reactive({
    if (is.null(selected_provincia())) return(sum(agrupados_comedores_provincia$total_asistentes))
    sum(provincia_data()$total_asistentes)
  })
  
  total_nbi_val <- reactive({
    if (is.null(selected_provincia())) {
      return(9.4)
    }
    
    mean(mapa_comedores_provincia$porcentaje[mapa_comedores_provincia$Provincia == selected_provincia()], na.rm = TRUE)
  })
  
  Purp <- c("#FDE0DD", "#FCC5C0", "#FA9FB5", "#F768A1", "#DD3497", "#AE017E", "#7A0177")
  
  get_color_scale <- function(var, is_dept_map = FALSE, provincia = NULL) {
    if (var == "total_nbi") {
      #NBI
      if (is_dept_map && !is.null(provincia)) {
        valores_nbi <- mapa_deptos_nbi %>%
          filter(Provincia == provincia) %>%
          pull(porcentaje_NBI_depto_pobl)
      } else {
        valores_nbi <- mapa_comedores_provincia$porcentaje
      }
      
      # Asegurar valores numéricos válidos
      valores_nbi <- as.numeric(as.character(valores_nbi))
      valores_nbi <- valores_nbi[!is.infinite(valores_nbi) & !is.na(valores_nbi)]
      
      if(length(valores_nbi) > 0) {
        data_range <- range(valores_nbi, na.rm = TRUE)
      } else {
        data_range <- c(0, 100)  
      }
      
      scale_fill_gradientn(
        colours = Purp[c(2,6,5)],
        name = "NBI (%)",
        limits = data_range,
        na.value = "white"
      )
      
    } else {
      # Para comedores y asistentes
      if (is_dept_map && !is.null(provincia)) {
        data_range <- range(mapa_comedores_deptos %>% 
                              filter(provincia_nombre == provincia) %>% 
                              pull(!!sym(var)), 
                            na.rm = TRUE)
      } else {
        data_range <- range(mapa_comedores_provincia[[var]], na.rm = TRUE)
      }
      
      if (var == "total_comedores") {
        scale_fill_gradientn(
          colours = Purp[c(2,6,5)],  
          name = "Total Comedores",
          limits = data_range,
          na.value = "white"
        )
      } else if (var == "total_asistentes") {
        scale_fill_gradientn(
          colours = Purp[c(1,6,5)],  
          name = "Total Asistentes",
          limits = data_range,
          na.value = "white"
        )
      }
    }
  }
  
  # Observers para el modal
  observeEvent(input$show_info, {
    modal_visible(!modal_visible())
  })
  
  observeEvent(input$overlay_click, {
    modal_visible(FALSE)
  })
  
  observeEvent(input$close_info, {
    modal_visible(FALSE)
  }) 
  # Contenido del storytelling
  output$storytelling <- renderUI({
    if (!show_storytelling()) return(NULL)
    
    story_content <- switch(current_story(),
                            "1" = list(
                              text = "De acuerdo al último informe del Observatorio de Deuda Social de la UCA (diciembre 2024), uno de cada cuatro hogares argentinos no logra cubrir todas sus comidas diarias.",
                              color = "#3b8d99"
                            ),
                            "2" = list(
                              text = "Los comedores y merenderos sostienen la vida de miles de personas que se encuentran en condición de inseguridad alimentaria.",
                              color = "#3b8d99"
                            ),
                            "3" = list(
                              text = "Cada sección en este mapa oculta todo ese trabajo. Generalmente, realizado por mujeres de clases de populares",
                              color = "#3b8d99"
                            ),
                            "4" = list(
                              text = "Conocé más sobre estos datos.",
                              color = "#3b8d99"
                            )
    )
    
    div(
      id = "storytelling-overlay",
      style = sprintf("background-color: %s99;", story_content$color),
      div(
        class = "story-content",
        if (current_story() > 1) 
          div(class = "story-nav-prev",
              actionButton("prev_story",  bs_icon("chevron-down"), class = "scroll-btn")),
        p(story_content$text),
        if (current_story() < 4) 
          div(class = "story-nav-next",
              actionButton("next_story",  bs_icon("chevron-down"), class = "scroll-btn"))
        else 
          div(class = "story-nav-next",
              actionButton("start_explore", "Explorar el mapa", class = "story-nav-btn"))
      )
    )
    
  })
  
  # Navegación del storytelling
  observeEvent(input$next_story, {
    current_story(current_story() + 1)
  })
  
  observeEvent(input$prev_story, {
    current_story(current_story() - 1)
  })
  
  observeEvent(input$start_explore, {
    show_storytelling(FALSE)
  })
  
  observeEvent(input$return_to_map, {
    selected_provincia(NULL)
    show_dept_map(FALSE)
  })
  
  # Output del modal
  output$info_modal <- renderUI({
    observeEvent(input$show_info, {
      showModal(
        modalDialog(
          title = "Fuentes de datos",
          div(
            style = "font-size: 14px;",
            h4("Datos de comedores y merenderos:", style = "color: #4e5b61;"),
            p("Los datos provienen del Registro Nacional de Comedores y Merenderos Comunitarios (ReNaCoM) 
            actualizado a mayo del 2023. Provienen de un pedido de información pública mediante TAD."),
            
            h4("Datos de Necesidades Básicas Insatisfechas:", style = "color: #4e5b61;"),
            p("Los datos fueron tomados del CENSO 2022 obtenidos a través de la plataforma REDATAM. 
            Corresponde a los datos de la población total en viviendas particulares.
            El INDEC considera a las Necesidades básicas insatisfechas a hogares que presentan al menos 
            uno de los siguientes indicadores de privación:"),
            tags$ul(
              class = "nbi-list",
              tags$li("Hacinamiento: hogares que tienen más de tres personas por cuarto."),
              tags$li("Vivienda: hogares en una vivienda de tipo inconveniente (pieza de inquilinato, vivienda 
    precaria u otro tipo, lo que excluye casa, departamento y rancho)."),
              tags$li("Condiciones sanitarias: hogares que no tienen acceso a baño o letrina."),
              tags$li("Asistencia escolar: hogares que tienen algún niño en edad escolar (6 a 12 años) que no 
    asiste a la escuela."),
              tags$li("Capacidad de subsistencia: hogares que tienen cuatro o más personas por miembro ocupado y, 
    además, cuyo jefe no haya completado el tercer grado de escolaridad primaria.")
            ),
            
            h4("Datos geográficos:", style = "color: #4e5b61;"),
            p("La información geográfica se obtiene a través del paquete geoAr, que proporciona datos
            oficiales de límites administrativos de Argentina."),
            
            h4("Procesamiento:", style = "color: #4e5b61;"),
            p("Los datos han sido procesados y agregados a nivel provincial y departamental para su
            visualización en este dashboard. Podés ver el paso a paso ",
              a(href = "https://github.com/kzcrr/shiny-comedores", "acá.", target = "_blank")),
            
            h5("Contacto:", style = "color: #4e5b61;"),
            div(
              class = "contact-info",
              bs_icon("envelope-at"),
              p("azcurrakaren@gmail.com", style = "margin: 0;")
            ),
            div(
              class = "contact-info",
              bs_icon("linkedin"),
              a(href = "https://www.linkedin.com/in/karen-azcurra/", 
                "karen-azcurra", 
                target = "_blank")
            )
          ),
          size = "s",
          easyClose = TRUE,
          footer = modalButton("Cerrar")
        )
      )
      
      
    })
  } )
  
  
  
  # Cerrar modal al hacer clic en el overlay
  observeEvent(input$overlay_click, {
    updateActionButton(session, "show_info", label = "¿De dónde salen estos datos?")
  })
  
  # Cerrar modal con el botón X
  observeEvent(input$close_info, {
    updateActionButton(session, "show_info", label = "¿De dónde salen estos datos?")
  })
  
  
  
  
  # Outputs
  output$selected_provincia <- renderText({
    if (is.null(selected_provincia())) return("Seleccione una provincia")
    paste("Provincia seleccionada:", selected_provincia())
  })
  
  output$total_comedores <- renderText({
    paste("Total de Comedores:", format(total_comedores_val(), big.mark = ","))
  })
  
  output$total_asistentes <- renderText({
    paste("Total de personas que asisten:", format(total_asistentes_val(), big.mark = ","))
  })
  
  output$total_nbi <- renderText({
    paste("Población con Necesidades Básicas Insatisfechas:", format(round(total_nbi_val(), 2), big.mark = ","))
  })
  
  #PLOT
  output$info_plot <- renderGirafe({
    var <- selected_variable() 
    titulo <- if(var == "total_comedores") {
      "Top 5 provincias con más comedores"
    } else if(var == "total_asistentes") {
      "Top 5 provincias con más asistentes"
    } else {
      "Top 5 provincias con mayor NBI"
    }
    
    if(var == "total_nbi") {
      plot_data <- mapa_comedores_provincia %>%
        mutate(provincia_wrap = str_wrap(Provincia, width = 15)) %>%
        arrange(desc(porcentaje)) %>%
        slice_head(n = 5)
      
      gg <- ggplot(plot_data, 
                   aes(x = reorder(provincia_wrap, -porcentaje), 
                       y = porcentaje)) +
        geom_col_interactive(
          aes(tooltip = paste0("Provincia: ", Provincia, "\n",
                               "NBI: ", format(round(porcentaje, 1), decimal.mark=","), "%")),
          fill = "#F768A1",
          width = 0.7
        ) +
        geom_text(aes(label = paste0(format(round(porcentaje, 1), decimal.mark=","), "%")),
                  vjust = -0.5,
                  size = 4) +
        scale_y_continuous(
          labels = function(x) paste0(format(x, decimal.mark=","), "%"),
          limits = c(0, max(plot_data$porcentaje) * 1.1)  
        )
      
    } else {
      
      plot_data <- agrupados_comedores_provincia %>%
        mutate(provincia_wrap = str_wrap(provincia, width = 15)) %>%
        arrange(desc(!!sym(var))) %>%
        slice_head(n = 5)
      
      titulo <- if(var == "total_comedores") {
        "Top 5 provincias con más comedores"
      } else if(var == "total_asistentes") {
        "Top 5 provincias con más asistentes"
      } else {
        "Top 5 provincias con mayor NBI"
      }
      
      gg <- ggplot(plot_data, 
                   aes(x = reorder(provincia_wrap, -!!sym(var)), 
                       y = !!sym(var))) +
        geom_col_interactive(
          aes(tooltip = paste0("Provincia: ", provincia, "\n",
                               ifelse(var == "total_comedores", 
                                      "Total de Comedores: ", 
                                      "Total de Asistentes: "),
                               format(!!sym(var), big.mark = ","))),
          fill = "#F768A1",
          width = 0.7
        )
    }
    
    titulo <- if(var == "total_comedores") {
      "Top 5 provincias con más comedores"
    } else if(var == "total_asistentes") {
      "Top 5 provincias con más asistentes"
    } else {
      "Top 5 provincias con mayor NBI"
    }
    
    gg <- gg +
      labs(
        title = titulo,
        x = NULL,
        y = if(var == "total_nbi") "Porcentaje NBI" else NULL
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(
          hjust = 0.5, 
          color = "#3b8d99",
          size = 30,
          family = "sans"
        ),
        axis.text.x = element_text(
          color = "#515456",
          size = 15,
          family = "sans"
        ),
        axis.text.y = element_text(
          color = "#515456",
          size = 12,
          family = "sans"
        ),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.background = element_rect(fill = "transparent", color = NA)
      )
    
    girafe(
      ggobj = gg,
      options = list(
        opts_hover(css = "fill:stealblue;"),
        opts_tooltip(css = "background-color:grey;color:black;padding:10px;border-radius:5px;"),
        opts_selection(type = "single", css = "fill:#3b8d99;")
      ),
      width_svg = 8,
      height_svg = 6,
      bg = "transparent"
    )
  })
  
  
  
  #MAPAS
  output$map <- renderGirafe({
    tryCatch({
      var <- selected_variable()
      
      if (is.null(selected_provincia()) || !show_dept_map()) {
        # Mapa nacional 
        if(var == "total_nbi") {
          mapa_data <- mapa_comedores_provincia %>%
            mutate(porcentaje = as.numeric(as.character(porcentaje))) 
          
          mapa_base <- ggplot() +
            geom_sf_interactive(
              data = mapa_comedores_provincia,
              aes(fill = porcentaje,
                  tooltip = paste0("Provincia: ", Provincia, "\n",
                                   "NBI: ", format(round(porcentaje, 1), decimal.mark=","), "%"),
                  data_id = Provincia),
              color = "white",
              linewidth = 0.1
            )
        } else {
          mapa_base <- ggplot() +
            geom_sf_interactive(
              data = mapa_comedores_provincia, 
              aes(fill = !!sym(var), 
                  tooltip = paste0("Provincia: ", Provincia, "\n",
                                   if(var == "total_comedores") "Comedores: " else "Asistentes: ",
                                   format(!!sym(var), big.mark = ",")),
                  data_id = Provincia), 
              color = "white",
              linewidth = 0.1
            )
        }
        
        mapa_base <- mapa_base +
          get_color_scale(var, TRUE, selected_provincia()) +
          labs(title = if(show_amba()) "AMBA" else str_wrap(selected_provincia(), width = 10))+
          theme_void() +
          theme(
            plot.background = element_rect(fill = "transparent", color = NA),
            panel.background = element_rect(fill = "transparent", color = NA),
            legend.position = if(show_legend()) c(1, 0.3) else "none",                
            legend.text = element_text(size = 8),
            legend.title = element_text(size = 9),
            legend.key.size = unit(0.4, "cm")
          )
        
      } else {
        # Mapa departamental
        if(var == "total_nbi") {
          deptos_provincia <- mapa_deptos_nbi %>% 
            filter(provincia_nombre %in% c(selected_provincia(), 
                                           if(show_amba() && selected_provincia() == "Buenos Aires") 
                                             "Ciudad Autónoma de Buenos Aires" else NULL)) %>%
            mutate(
              porcentaje_NBI_depto_pobl = as.numeric(as.character(porcentaje_NBI_depto_pobl)),
              Departamento = gsub("'", "", Departamento)
            ) %>%
            filter(!is.na(porcentaje_NBI_depto_pobl)) %>%
            st_make_valid()
          
          validate(
            need(any(!is.na(deptos_provincia$porcentaje_NBI_depto_pobl)), 
                 paste("No hay datos NBI para la provincia:", selected_provincia()))
          )
        } else {
          deptos_provincia <- mapa_comedores_deptos %>% 
            filter(provincia_nombre %in% c(selected_provincia(), 
                                           if(show_amba() && selected_provincia() == "Buenos Aires") 
                                             "Ciudad Autónoma de Buenos Aires" else NULL)) %>%
            st_cast("MULTIPOLYGON") %>%
            st_make_valid()
        }
        
        if (show_amba() && selected_provincia() %in% c("Buenos Aires", "Ciudad Autónoma de Buenos Aires")) {
          deptos_provincia <- deptos_provincia %>%
            filter(nombre %in% amba_municipios)
        }
        
        bbox <- st_bbox(deptos_provincia)
        is_amba <- show_amba() && selected_provincia() %in% c("Buenos Aires", "Ciudad Autónoma de Buenos Aires")
        
        mapa_base <- ggplot()
        
        if(var == "total_nbi") {
          mapa_base <- mapa_base +
            geom_sf_interactive(
              data = deptos_provincia %>% 
                filter(!is.na(porcentaje_NBI_depto_pobl)),
              aes(fill = porcentaje_NBI_depto_pobl,
                  tooltip = sprintf(
                    "Departamento: %s\nNBI: %.1f%%",
                    Departamento,
                    porcentaje_NBI_depto_pobl
                  ),
                  data_id = Departamento),
              color = "white",
              linewidth = 0.1
            )
        } else {
          mapa_base <- mapa_base +
            geom_sf_interactive(
              data = deptos_provincia %>% filter(!is.na(!!sym(var))),
              aes(
                fill = !!sym(var),
                tooltip = paste0(
                  "Departamento: ", nombre, "\n",
                  if(var == "total_comedores") "Comedores: " else "Asistentes: ",
                  format(!!sym(var), big.mark = ",")
                )
              ),
              color = "white",
              linewidth = 0.1
            )
        }
        
        mapa_base <- mapa_base +
          get_color_scale(var, TRUE, selected_provincia()) +
          labs(title = if(show_amba()) "AMBA" else 
            ifelse(selected_provincia() == "Tierra del Fuego, Antártida e Islas del Atlántico Sur",
                   "Tierra del Fuego,\nAntártida e Islas del Atlántico Sur",
                   selected_provincia())) +
          coord_sf(
            xlim = if(is_amba) c(bbox["xmin"] - 0.3, bbox["xmax"] + 0.1) else c(bbox["xmin"] - 0.2, bbox["xmax"] + 1.5),
            ylim = if(is_amba) c(bbox["ymin"] - 0.05, bbox["ymax"] + 0.05) else c(bbox["ymin"] - 0.2, bbox["ymax"] + 0.2),
            expand = FALSE
          ) +
          theme_void() +
          theme(
            plot.title = element_text(
              hjust = 0.5,
              color = "#3b8d99",
              size = if(is_amba) 20 else 16,
              family = "sans",
              lineheight = 1.2
            ),
            plot.background = element_rect(fill = "transparent", color = NA),
            panel.background = element_rect(fill = "transparent", color = NA),
            legend.position = if(show_legend()) "right" else "none",
            legend.text = element_text(size = if(is_amba) 10 else 8),
            legend.title = element_text(size = if(is_amba) 12 else 9)
          )
      }
      
      is_amba <- !is.null(selected_provincia()) && 
        show_amba() && 
        selected_provincia() %in% c("Buenos Aires", "Ciudad Autónoma de Buenos Aires")
      
      girafe(ggobj = mapa_base,
             width_svg = if(is_amba) 8 else if(show_dept_map()) 5 else 4,
             height_svg = if(is_amba) 8 else 6) %>%
        girafe_options(
          opts_tooltip(css = "background-color:black;color:white;"),
          opts_zoom(min = 1, max = if(is_amba) 2 else 1),
          opts_sizing(rescale = TRUE, width = 0.9),
          opts_toolbar(saveaspng = FALSE),
          opts_hover(css = "fill:#3b8d99;"),
          opts_selection(type = "single")
        )
    }, error = function(e) {
      print(paste("Error en el mapa:", e))
    })
  })
})