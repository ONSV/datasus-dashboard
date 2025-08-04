library(shiny)
library(bslib)
library(onsvplot)
library(plotly)
library(leaflet)
library(markdown)
library(shinycssloaders)
library(sf)
library(tidyverse)
library(shinyFeedback)
source("R/utils.R")

## Home ---

home_panel <- nav_panel(
  value = "home",
  title = "Home",
  icon = bsicons::bs_icon("house"),
  layout_columns(
    fill = FALSE,
    height = "120px",
    value_box(
      title = "Município",
      value = textOutput(
        outputId = "municipioBox"
      )
    ),
    value_box(
      title = "Estado / UF",
      value = textOutput(
        outputId = "ufBox"
      )
    ),
    value_box(
      title = "Região",
      value = textOutput(
        outputId = "regiaoBox"
      )
    ),
    value_box(
      title = "Quantidade de óbitos",
      value = textOutput(
        outputId = "obitosBox"
      )
    )
  ),
  tabsetPanel(
    type = "pills",
    tabPanel(
      "Mapa",
      layout_columns(
        card(
          card_header("Mapa"),
          full_screen = TRUE,
          withSpinner(leafletOutput(outputId = "mapa", height = "500px"),
                      type = 8, color = onsv_palette$blue),
          min_height = "400px",
          height = "600px"
        )
      )
    ),
    tabPanel(
      "Gráficos",
      layout_columns(
        col_widths = c(6, 6),
        card(
          card_header("Pirâmide etária das vítimas"),
          full_screen = TRUE,
          withSpinner(plotlyOutput(outputId = "piramide"), type = 8,
                      color = onsv_palette$blue)
        ),
        card(
          card_header("Série temporal"),
          full_screen = TRUE,
          withSpinner(plotlyOutput(outputId = "serie"), type = 8,
                      color = onsv_palette$blue)
        ),
        card(
          card_header("Modo de transporte das vítimas"),
          full_screen = TRUE,
          withSpinner(plotlyOutput(outputId = "modal"), type = 8,
                      color = onsv_palette$blue)
        ),
        card(
          card_header("Modo de transporte e faixa etária das vítimas"),
          full_screen = TRUE,
          withSpinner(plotlyOutput(outputId = "heatmap"), type = 8,
                      color = onsv_palette$blue)
        )
      )
    )
  )
)

## Sobre ----

about_panel <- nav_panel(
  value = "about",
  title = "Sobre",
  icon = bsicons::bs_icon("info-circle"),
  layout_columns(
    card(
      card_header("Metodologia"),
      includeMarkdown("text/metodologia.md")
    ),
    card(
      card_header("Versionamento"),
      includeMarkdown("text/versionamento.md")
    )
  )
)

## Sidebar ----

filter_sidebar <- sidebar(
  title = "Filtros",
  selectizeInput(
    inputId = "uf",
    label = "Selecione a UF",
    choices = sort(unique(lista_municipios$abbrev_state)),
    selected = "SP"
  ),
  selectizeInput(
    inputId = "municipio",
    label = "Selecione o município",
    choices = select_filter(lista_municipios, "SP")
  ),
  selectizeInput(
    inputId = "ano",
    label = "Selecione o ano",
    choices = seq(1996, 2023, 1),
    selected = last(seq(1996, 2023, 1))
  ),
  actionButton(
    inputId = "filter",
    label = "Aplicar",
    icon = icon("cog"),
    class = "btn-primary"
  ),
  img(src = "logo.png", width = "200px", height = "auto")
)

## UI ----

ui <- page_navbar(
  nav_item(useShinyFeedback()),
  title = "Óbitos no Trânsito Brasileiro",
  home_panel,
  about_panel,
  sidebar = filter_sidebar,
  bg = onsv_palette$blue,
  theme = bs_theme(
    primary = onsv_palette$blue,
    warning = onsv_palette$yellow,
    danger = onsv_palette$red,
    success = onsv_palette$green
  )
)

## Server -----

server <- function(input, output) {
  
  observe({
    updateSelectizeInput(inputId = "municipio", 
                         choices = select_filter(lista_municipios, input$uf))
  })
  
  check_inputs <- observe({
    existe_uf <- input$uf == ""
    existe_ano <- input$ano == ""
    existe_municipio <- input$municipio == ""
    feedbackWarning("uf", existe_uf, "", icon = NULL)
    feedbackWarning("ano", existe_ano, "", icon = NULL)
    feedbackWarning("municipio", existe_municipio, "", icon = NULL)
  })
  
  make_map <- eventReactive(input$filter, ignoreNULL = F, {
    req(input$uf)
    req(input$ano)
    req(input$municipio)
    prep_map(rtdeaths, input$ano, input$uf, input$municipio)
  })
  
  make_pyramid <- eventReactive(input$filter, ignoreNULL = F, {
    req(input$uf)
    req(input$ano)
    req(input$municipio)
    prep_pyramid(rtdeaths, input$ano, input$municipio)
  })
  
  make_ts <- eventReactive(input$filter, ignoreNULL = F, {
    req(input$uf)
    req(input$ano)
    req(input$municipio)
    prep_ts(rtdeaths, input$municipio)
  })
  
  make_bars <- eventReactive(input$filter, ignoreNULL = F, {
    req(input$uf)
    req(input$ano)
    req(input$municipio)
    prep_bars(rtdeaths, input$ano, input$municipio)
  })
  
  make_heatmap <- eventReactive(input$filter, ignoreNULL = F, {
    req(input$uf)
    req(input$ano)
    req(input$municipio)
    prep_heatmap(rtdeaths, input$ano, input$municipio)
  })
  
  get_muni <- eventReactive(input$filter, ignoreNULL = F, {
    req(input$uf)
    req(input$ano)
    req(input$municipio)
    code_to_name_muni(input$municipio)
  })
  
  get_uf <- eventReactive(input$filter, ignoreNULL = F, {
    req(input$uf)
    req(input$ano)
    req(input$municipio)
    uf_acronym_to_name(input$uf)
  })
  
  get_region <- eventReactive(input$filter, ignoreNULL = F, {
    req(input$uf)
    req(input$ano)
    req(input$municipio)
    uf_to_region(input$uf)
  })
  
  get_deaths <- eventReactive(input$filter, ignoreNULL = F, {
    req(input$uf)
    req(input$ano)
    req(input$municipio)
    filter(
      rtdeaths, 
      ano_ocorrencia == input$ano, 
      cod_municipio_res == input$municipio
    ) |> nrow()
  })
  
  output$municipioBox <- renderText({
    get_muni()
  })
  output$ufBox <- renderText({
    get_uf()
  })
  output$regiaoBox <- renderText({
    get_region()
  })
  output$obitosBox <- renderText({
    get_deaths()
  })
  output$mapa <- renderLeaflet({
    make_map()
  })
  output$piramide <- renderPlotly({
    make_pyramid()
  })
  output$serie <- renderPlotly({
    make_ts()
  })
  output$modal <- renderPlotly({
    make_bars()
  })
  output$heatmap <- renderPlotly({
    make_heatmap()
  })
}

shinyApp(ui, server)
