#'@export
shinyGraphViz <- function(){
  ui <- fluidPage(
    shinyjs::useShinyjs(),
    fluidRow(
      column(width = 12,
             div(style = "display: inline-block", loginUI("login")),
             div(style = "display: inline-block", controlsUI("controls"))
      )
    ),
    fluidRow(
      column(width = 3,
             tags$br(),
             editorUI("editor")),
      column(width = 9,
             graphUI("graph"))
    )

  )

  server <- function(input, output, session) {

    pool <- pool::dbPool(
      drv = RMySQL::MySQL(),
      user = "lheley",
      password = Sys.getenv("mysql_pw"),
      host = "localhost",
      db = "graphviz"
    )

    onStop(function() {
      pool::poolClose(pool)
    })

    login <- callModule(loginServer, id = "login", pool)
    controls <- callModule(controlsServer, id = "controls")
    editor <- callModule(editorServer, id = "editor")
    graph <- callModule(graphServer,  id = "graph", editor = editor)

  }

  shinyApp(ui, server)
}
