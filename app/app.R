library(shiny)
library(ggplot2)
library(bslib)
library(onsvplot)
library(plotly)
library(leaflet)

## Home ---

home_panel <- nav_panel(
  value = "home",
  title = "Home",
  icon = bsicons::bs_icon("house"),
  layout_columns(
    fill = FALSE,
    height = "90px",
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
          leafletOutput(outputId = "mapa"),
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
          plotlyOutput(outputId = "piramide")
        ),
        card(
          card_header("Série temporal"),
          full_screen = TRUE,
          plotlyOutput(outputId = "serie")
        ),
        card(
          card_header("Modo de transporte das vítimas"),
          full_screen = TRUE,
          plotlyOutput(outputId = "modal")
        ),
        card(
          card_header("Modo de transporte e faixa etária das vítimas"),
          full_screen = TRUE,
          plotlyOutput(outputId = "heatmap")
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
    choices = c("test1", "test2")
  ),
  selectizeInput(
    inputId = "municipio",
    label = "Selecione o município",
    choices = c("test1", "test2")
  ),
  selectizeInput(
    inputId = "ano",
    label = "Selecione o ano",
    choices = seq(1996, 2022, 1)
  ),
  actionButton(
    inputId = "filter",
    label = "Aplicar",
    icon = icon("cog"),
    class = "btn-primary"
  )
)

## UI ----

ui <- page_navbar(
  title = "Óbitos no Trânsito Brasileiro",
  home_panel,
  about_panel,
  sidebar = filter_sidebar,
  bg = onsv_palette$blue,,
  theme = bs_theme(
    primary = onsv_palette$blue,
    warning = onsv_palette$yellow,
    danger = onsv_palette$red,
    success = onsv_palette$green
  )
)

## Server -----

server <- function(input, output) {

  output$municipioBox <- renderText({

  })
  output$ufBox <- renderText({
    
  })
  output$regiaoBox <- renderText({
    
  })
  output$obitosBox <- renderText({
    
  })
  output$mapa <- renderLeaflet({
    
  })
  output$piramide <- renderPlotly({
    
  })
  output$serie <- renderPlotly({
    
  })
  output$modal <- renderPlotly({
    
  })
  output$heatmap <- renderPlotly({
    
  })
}

shinyApp(ui, server)
