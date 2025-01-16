

# UI
shinyUI(page_fluid(
  theme = bs_theme(
    bootswatch = "minty",
    base_font = c("Montserrat", "sans-serif"),
    "enable-rounded" = TRUE,
    "primary" = "#3b8d99"
  ) |> 
    bs_add_rules(
      
      "@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&display=swap');"
    ),
  useShinyjs(),
  
  tags$head(
    tags$style(HTML("
      body {
        background-color: white;
        color: black;
        margin: 0;
        padding: 0;
        overflow: hidden;
      }
       
      .modal-dialog {
        width: 90% !important;
        max-width: 500px !important;
        margin: 20px auto;
       
      }
      .modal-content {
        max-height: 80vh;  
      }
      
      .modal-body {
        max-height: calc(80vh - 120px);  
        overflow-y: auto;  
        padding: 15px;
      }
      .contact-info {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-top: 10px;
      }
      .nbi-list {
    list-style: none; 
    padding-left: 20px;
    margin-top: 10px;
  }
  .nbi-list li {
    margin-bottom: 8px;
    text-indent: -1em;  
    
  }
  .nbi-list li::before {
    content: '● ';     
    color: #4e5b61;    
  }
      #map-wrapper {
        position: absolute;
        top: 0;
        left: 30px;
        width: 100%;
        height: 100vh;
        z-index: 1;
        transition: left 0.3s ease
      }
      .national-map {
    left: 0;
      }
      .dept-map {
    position: absolute;
    top: 0;
    left: -250px;  
    width: calc(100% + 250px);
    height: 100vh;
    z-index: 1;
      }
      /* storytelling */
      #storytelling-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.92);
        z-index: 1000;
        display: flex;
        justify-content: center;
        align-items: center;
        transition: opacity 0.5s;
      }
      .story-content {
        color: white;
        text-align: center;
        max-width: 800px;
        padding: 20px;
        font-size: 30px;
        line-height: 1.6;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 30px; 
        position:relative;
      }
      .story-nav-prev {
        position: absolute;
        top:-80px;  
        left: 50%;
        transform: translateX(-50%) rotate(180deg); 
      }
      
      .story-nav-next {
        position: relative;
        margin-top: 30px;   
      }
      .scroll-btn {
        background: none;
        border: none;
        color: none;
        font-size: 32px;
        cursor: pointer;
        padding: 10px;
        opacity: 0.8;
        transition: none;
        transform: rotate(0deg);
        outline: none;
        box-shadow: none;
      }
      .scroll-btn:hover {
        opacity: 0.8;
        transform: none;
      }
      .scroll-btn.prev {
        transform: rotate(180deg);
      }
      .scroll-btn.prev:hover {
        transform: rotate(180deg) translateY(-5px);
      }
      /* Ocultar elementos durante el storytelling */
      .hidden-during-story {
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.5s;
      }
      .visible {
        opacity: 1;
        pointer-events: auto;
      }
      .overlay-cards {
        position: absolute;
        top: 120px;
        left: 20px;
        z-index: 2;
        max-width: 600px;
      }
      .overlay-card {
        margin-bottom: 15px;
        background: #f0f8ff;
        border-radius: 10px;
        box-shadow: 0px 4px 6px rgba(0,0,0,0.1);
        padding: 15px;
        border: 2px solid #3b8d99;
      }
      .overlay-card h4 {
        color: #3b8d99;
      }
      .overlay-card p, .overlay-card label {
        color: #4e5b61;
      }
      .btn-group {
        position: absolute;
        top: 70px;
        left: 50px;
        z-index: 2;
        margin-bottom: 20px;
      }
      .btn {
        margin-bottom: 10px;
      }
      .btn-custom-green {
        background-color: #3b8d99;
        border-color: #3b8d99;
      }
      .btn-custom-green:hover {
        background-color: #218838;
        border-color: #3b8d99;
      }
      @media only screen and (max-width: 768px) {
      body {
        overflow-x: hidden;
      }
      
      @media only screen and (max-width: 480px) {
      .overlay-card {
        font-size: 14px;
      }
      
      #info_plot {
        height: 200px !important;
      
    "))
  ),
  
  
  div(
    girafeOutput("map", height = "100vh"),
    

    
    # Capa de storytelling
    uiOutput("storytelling"),
    #oculto todo para el boton de donde salen estos datos?
    
    div(
      id = "controls-and-cards",
      class = "hidden-during-story",  
      div(
        style = "position: absolute; top: 20px; right:20px; z-index: 1000;",
        actionButton("show_info", "¿De dónde salen estos datos?",
                     class = "btn btn-secondary")
      ),
      
      
      # Modal de información
      uiOutput("info_modal"),
      
      
      #botones
      div(
        class = "btn-group",
        actionButton("btn_comedores", "Comedores", class = "btn btn-custom-green"),
        actionButton("btn_asistentes", "Asistentes", class = "btn btn-custom-green"),
        actionButton("btn_nbi", "NBI", class = "btn btn-custom-green")
      ),
      
      div(
        class = "overlay-cards",
        div(
          class = "overlay-card",
          h4("Comedores y merenderos 2023"),
          textOutput("total_comedores"),
          textOutput("total_asistentes"),
          textOutput("total_nbi")
        ),
        div(
          class = "overlay-card",
          girafeOutput("info_plot", height = "300px")
        )
        
        
        
        
      )
    )
  ),
  #BOTON AMBA
  div(
    style = "position: absolute; top: 20px; right: 535px; z-index: 1000;",
    conditionalPanel(
      condition = "input.map_selected == 'Buenos Aires' || input.map_selected == 'Ciudad Autónoma de Buenos Aires'",
      actionButton("btn_amba", "Ver AMBA", class = "btn btn-custom-green")
    )
  ),
  #BOTON DE "VOLVER AL MAPA NACIONAL"
  
  div(
    style = "position: absolute; top: 20px; right: 300px; z-index: 1000;",
    conditionalPanel(
      condition = "input.map_selected",
      actionButton("return_to_map", "Volver al mapa nacional", 
                   class = "btn btn-custom-green",
                   style = "margin-bottom: 10px;")))    
  
))