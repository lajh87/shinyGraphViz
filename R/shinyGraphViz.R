# 40d41e3b7f73596d
#'@export
shinyGraphViz <- function(){
  ui <- fluidPage(
    shinyjs::useShinyjs(),
    includeScript(system.file("www/js.cookie.min.js", package = "shinyGraphViz")),
    includeScript(system.file("www/shiny-cookies.js", package = "shinyGraphViz")),
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

    values <- reactiveValues()

    observeEvent(input$cookies,{
      if(is.null(input$cookies$token)){
        selector <- sodium::random(6) |> sodium::bin2hex()
        validator <- sodium::random(32) |> sodium::bin2hex()
        values$token <- paste(selector, validator, sep  = ":")
        hashed_validator <- sodium::hex2bin(validator) %>%
          sodium::sha256() %>%
          sodium::bin2hex()
        msg <- list(
          name = "token",
          value = values$token
        )
        session$sendCustomMessage("cookie-set", msg)
        DBI::dbExecute(pool, glue::glue(
          "INSERT INTO token",
          "VALUES('{selector}', '{hashed_validator}', '0')",
          .sep = "\n"
        ))
      } else{
        values$token <- input$cookies$token
      }
    }, ignoreInit = FALSE, once = TRUE)


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

    # wrapped the modules in an observer so can use req(values$token) preventing
    # null value being passed to login module.
    observe({
      req(values$token)
      login <- callModule(
        module = loginServer,
        id = "login",
        pool = pool,
        token = values$token,
        parent = session
      )
      controls <- callModule(controlsServer, id = "controls")
      editor <- callModule(editorServer, id = "editor")
      graph <- callModule(graphServer,  id = "graph", editor = editor)
    })
  }

  shinyApp(ui, server)
}
