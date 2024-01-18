library(shiny)
library(ggplot2)
library(bslib)
library(gridlayout)
library(onsvplot)

ui <- page_navbar(
  title = "DataSUS",
  theme = bs_theme(preset = "lux",
                           fg = onsv_palette$blue,
                           bg = "white"),
  collapsible = T,
  selected = "home",
  sidebar = sidebar(
    width = 250,
    open = "desktop",
    title = sliderInput(
      inputId = "date_range",
      label = "Anos",
      min = 1996,
      max = 2022,
      value = 1996,
      ticks = F,
      sep = ""
    ),
    selectInput(
      inputId = "selector",
      label = "Variáveis",
      choices = c(
        "A",
        "B",
        "C"
      )
    )
  ),
  nav_panel(title = "Home", 
            value = "home",
            layout_columns(card(full_screen = T),
                           card(full_screen = T)),
            layout_columns(card(full_screen = T))),
  nav_panel(title = "Sobre",
            value = "about")
)


server <- function(input, output) {
  
}

shinyApp(ui, server)
