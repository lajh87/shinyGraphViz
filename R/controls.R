controlsUI <- function(id) {
  ns <- NS(id)
  tagList(
  actionButton(
    inputId = ns("new"),
    label = NULL,
    icon = icon("file"),
    title = "New"
  ),
  actionButton(
    inputId = ns("save"),
    label = NULL,
    icon = icon("save"),
    title = "Save"
  ),
  actionButton(
    inputId = "saveas",
    label = NULL,
    icon = icon("cloud-upload"),
    class = "fa fa-inverse",
    title = "Save As"
  ),
  actionButton(
    inputId = ns("load"),
    label = NULL,
    icon = icon("cloud-download"),
    title = "Load"
  ),
  HTML("&nbsp"),
  HTML("&nbsp"),
  textOutput(
    outputId = ns("filename"),
    inline = TRUE
  )
  )
}

controlsServer <- function(input, output, session) {
  
  output$filename <- renderText("untitled.gv")
  
}
