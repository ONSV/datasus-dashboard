load("data/estados.rda")
load("data/municipios.rda")
load("data/regioes.rda")
load("data/rtdeaths.rda")
load("data/lista_municipios.rda")

# função para pirâmide etária

prep_pyramid <- function(data, year, cod) {
  res <- 
    tibble(data) |> 
    rename(code_muni = cod_municipio_res) |> 
    relocate(code_muni) |>  
    filter(ano_ocorrencia == year) |> 
    left_join(x = municipios, by = "code_muni", relationship = "many-to-many") |> 
    st_drop_geometry() |> 
    filter(code_muni == cod) |> 
    count(faixa_etaria_vitima, sexo_vitima, name = "mortes") |> 
    complete(faixa_etaria_vitima = unique(data$faixa_etaria_vitima),
             sexo_vitima = unique(data$sexo_vitima),
             fill = list(mortes = 0)) |> 
    drop_na()
  
  max_value = max(res$mortes)
  
  plot <- res |> 
    mutate(mortes = ifelse(test = sexo_vitima == "Masculino", 
                           yes = -mortes, no = mortes)) |> 
    mutate(abs_mortes = abs(mortes)) |> 
    plot_ly(x = ~mortes, y = ~faixa_etaria_vitima, 
            color = ~sexo_vitima, 
            colors = c(onsv_palette$blue, onsv_palette$yellow)) |> 
    add_bars(orientation = 'h', hoverinfo = "text", 
             text = ~paste(abs_mortes, "vítima(s)"),
             textposition = "none") |> 
    layout(bargap = 0.1, barmode = 'overlay',
           xaxis = list(tickmode = 'array', 
                        tickvals = c(-(max_value), -max_value/2,
                                     0, max_value/2, max_value),
                        ticktext = c(toString(max_value),
                                     toString(max_value/2),
                                     toString(0),
                                     toString(max_value/2),
                                     toString(max_value)),
                        range = c(-max_value, max_value),
                        title = ""),
           yaxis = list(title = "", ticklen = 3, tickcolor = "white"))
  return(plot)
}

# função para serie temporal

prep_ts <- function(data, cod) {
  res <-
    tibble(data) |> 
    rename(code_muni = cod_municipio_res) |>
    left_join(x = municipios, by = "code_muni", relationship = "many-to-many") |> 
    st_drop_geometry() |> 
    filter(code_muni == cod) |> 
    count(ano_ocorrencia, name = "mortes") |> 
    complete(ano_ocorrencia = unique(data$ano_ocorrencia), 
             fill = list(mortes = 0)) |> 
    drop_na() |> 
    arrange(ano_ocorrencia)
  
  plot <- res |> 
    plot_ly(x = ~ano_ocorrencia, y = ~mortes, type = "scatter",
            mode = "markers+lines", 
            line = list(color = onsv_palette$blue),
            marker = list(color = onsv_palette$blue),
            hoverinfo = "text", 
            text = ~paste0(ano_ocorrencia,", ",mortes, " vítima(s)")) |> 
    layout(xaxis = list(title = ""),
           yaxis = list(title = "", ticklen = 1, tickcolor = "white"))
  
  return(plot)
}

# função para bar plot (modal)

prep_bars <- function(data, year, cod) {
  res <- 
    tibble(data) |> 
    rename(code_muni = cod_municipio_res) |> 
    filter(ano_ocorrencia == year) |> 
    left_join(x = municipios, by = "code_muni", relationship = "many-to-many") |> 
    st_drop_geometry() |> 
    filter(code_muni == cod) |> 
    count(modal_vitima, sexo_vitima, name = "mortes") |> 
    complete(
      modal_vitima = unique(data$modal_vitima),
      sexo_vitima = unique(data$sexo_vitima),
      fill = list(mortes = 0)
    ) |> 
    pivot_wider(
      names_from = sexo_vitima,
      values_from = mortes
    )
  
  plot <- res |> 
    plot_ly(
      x = ~Masculino, 
      y = ~modal_vitima, 
      type = 'bar', 
      name = "Masculino",
      marker = list(color = onsv_palette$yellow)
      # marker = list(color = 'rgb(0, 73, 109)')
    ) |> 
    add_trace(
      x = ~Feminino,
      name = "Feminino",
      marker = list(color = onsv_palette$blue)
    ) |> 
    layout(
      xaxis = list(title = ""),
      yaxis = list(title = "", ticklen = 1, tickcolor = "white"),
      barmode = "stack"
    )
  
  return(plot)
}

# função para criar mapa leaflet

prep_map <- function(data, year, uf, cod) {
  res <-
    tibble(data) |> 
    rename(code_muni = cod_municipio_res) |> 
    filter(ano_ocorrencia == year) |> 
    count(code_muni, name = "mortes") |> 
    left_join(x = municipios, by = "code_muni", relationship = "many-to-many") |> 
    mutate(mortes = replace_na(mortes, 0)) |> 
    filter(abbrev_state == uf) |> 
    st_transform(crs = '+proj=longlat +datum=WGS84')
  
  filter_res <- filter(res, code_muni == cod)
  
  centroid <- st_coordinates(st_centroid(filter_res))
  
  max_value <- max(res$mortes)
  
  labels <- sprintf(
    "<strong>%s</strong><br/>%g óbitos",
    lapply(res$code_muni, code_to_name_muni),
    res$mortes
  ) |> lapply(htmltools::HTML)
  
  label_filter <- sprintf(
    "<strong>%s</strong><br/>%g óbitos",
    lapply(filter_res$code_muni, code_to_name_muni),
    filter_res$mortes
  ) |> lapply(htmltools::HTML)
  
  pal <- colorBin(
    palette = "YlGnBu",
    bins = c(0, max_value*0.05, max_value*0.1,
             max_value*0.5, max_value*0.75, max_value)
  )
  
  plot <- 
    leaflet() |> 
    addTiles() |> 
    addPolygons(
      data = res, 
      fillColor = ~pal(mortes), 
      fillOpacity = 0.7,
      weight = 1, 
      color = "black",
      highlightOptions = highlightOptions(
        color = "white",
        weight = 3,
        bringToFront = T,
        opacity = 1
      ),
      label = labels
    ) |> 
    addPolygons(
      data = filter_res,
      fillColor = ~pal(mortes),
      fillOpacity = 0.7,
      weight = 3,
      color = onsv_palette$yellow,
      opacity = 0.75,
      highlightOptions = highlightOptions(
        color = "white",
        weight = 3,
        bringToFront = T,
        opacity = 1
      ),
      label = label_filter
    ) |> 
    addLegend(
      data = res,
      position = "bottomright",
      pal = pal,
      values = ~mortes,
      opacity = 1,
      title = "Óbitos",
      labFormat = labelFormat(digits = 0)
    ) |> 
    setView(lng = centroid[1], lat = centroid[2], zoom = 9)
    
  return(plot)
}

# função para criar heatmap

prep_heatmap <- function(data, year, cod) {
  res <-
    tibble(rtdeaths) |> 
    rename(code_muni = cod_municipio_res) |> 
    filter(ano_ocorrencia == year) |> 
    left_join(x = municipios, by = "code_muni", relationship = "many-to-many") |> 
    st_drop_geometry() |> 
    filter(code_muni == cod) |> 
    count(faixa_etaria_vitima, modal_vitima, name = "mortes") |> 
    complete(faixa_etaria_vitima = unique(data$faixa_etaria_vitima),
             modal_vitima = unique(data$modal_vitima),
             fill  = list(mortes = 0)) |> 
    drop_na() |> 
    mutate(
      tooltip_text = glue::glue("{modal_vitima} - {faixa_etaria_vitima}: {mortes}")
    )
  
  plot <- res |>
    plot_ly(y = ~modal_vitima, x = ~faixa_etaria_vitima, z = ~mortes,
            type = "heatmap", showscale = F, text = ~tooltip_text,
            hoverinfo = "text", colors = colorRamp(c("#CCEEFF", "#99DDFF","#55A9D4"))) |>
    add_annotations(text = ~mortes, showarrow = F) |>
    layout(xaxis = list(title = "Faixa Etária", ticklen = 1, tickcolor = "white",
                        tickode = "array", tickvals = unique(res$faixa_etaria_vitima),
                        ticktext = c("0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80+"),
                        tickfont = list(size = 10)),
           yaxis = list(title = "", ticklen = 1, tickcolor = "white"))
  
  return(plot)
}

# função para atualizar de selectInput

select_filter <- function(df, uf) {
  filtered <- arrange(filter(df, abbrev_state == uf), name_muni)
  res <- setNames(as.character(filtered$code_muni), 
                  as.character(filtered$name_muni))
  
  return(res)
}

# função para traduzir código para nome de município

code_to_name_muni <- function(cod) {
  res <- filter(lista_municipios, code_muni == cod)$name_muni
  
  return(res)
}

# função para traduzir sigla de uf para nome

uf_acronym_to_name <- function(uf) {
  states <- c("Acre", "Alagoas", "Amapá", "Amazonas", "Bahia", "Ceará", "Distrito Federal", 
              "Espírito Santo", "Goiás", "Maranhão", "Mato Grosso", "Mato Grosso do Sul", 
              "Minas Gerais", "Pará", "Paraíba", "Paraná", "Pernambuco", "Piauí", "Rio de Janeiro", 
              "Rio Grande do Norte", "Rio Grande do Sul", "Rondônia", "Roraima", "Santa Catarina", 
              "São Paulo", "Sergipe", "Tocantins")
  acronyms <- c("AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", "PA", 
                "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO")
  brazil_states_df <- tibble(State = states, Acronym = acronyms)
  
  res <- select(filter(brazil_states_df, Acronym == uf), State)[[1]]
  
  return(res)
}

uf_to_region <- function(uf) {
  res <- select(filter(estados, abbrev_state == uf), name_region)[[1]]
  
  return(res)
}
