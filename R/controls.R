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
    icon = icon("save",class = "fa-solid fa-flip-horizontal"),
    #style="line-height:1px; padding-top: 12px; padding-left: 6px; padding-bottom; 12px;",
    title = "Save As"
  ),
  actionButton(
    inputId = ns("load"),
    label = NULL,
    icon = icon("folder-open",class = "fa-regular"),
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
