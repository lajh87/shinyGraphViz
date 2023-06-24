#'@export
shinyGraphViz <- function(){
  ui <- fluidPage(
    shinyjs::useShinyjs(),
    includeScript(system.file("www/js.cookie.min.js", package = "shinyGraphViz")),
    includeScript(system.file("www/shiny-cookies.js", package = "shinyGraphViz")),
    includeScript(system.file("www/panzoom.min.js", package = "shinyGraphViz")),
    includeScript(system.file("www/panzoom-shiny.js", package = "shinyGraphViz")),
    includeCSS(system.file("www/style.css", package = "shinyGraphViz")),
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

    # Reactive values update based on change to the application
    values <- reactiveValues()

    # Use a database pool instance to enable multiple connections.
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

    # If there is no token then create a new one and save info in database.
    # Otherwise use existing token after checking whether it is valid
    observeEvent(input$cookies, {

      if(is.null(input$cookies$token)){
        values$token <- create_new_token(pool, session)
      } else{
        values$token <- input$cookies$token

        expiry_date <- pool %>% dplyr::tbl("token") %>%
          dplyr::collect() %>%
          dplyr::filter(.data$selector == split_token(values$token)[1]) %>%
          dplyr::pull(.data$expires)

        if(length(expiry_date) == 0){
          session$sendCustomMessage("cookie-remove", list(name = "token"))
          values$token <- create_new_token(pool, session)
        } else{
          if(as.Date(expiry_date) < Sys.Date()){
            session$sendCustomMessage("cookie-remove", list(name = "token"))
            DBI::dbExecute(pool, glue::glue(
              "DELETE FROM token WHERE selector = '{split_token[1]}';"
            ))
            values$token <- create_new_token(pool)
          }
        }
      }

    }, ignoreInit = FALSE, once = TRUE)

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

      editor <- callModule(
        module = editorServer,
        id = "editor",
        controls = controls
      )

      controls <- callModule(
        module = controlsServer,
        id = "controls",
        pool = pool,
        token = values$token,
        login = login,
        editor = editor
        )

      graph <- callModule(
        module = graphServer,
        id = "graph",
        editor = editor
        )
    })

  }

  shinyApp(ui, server)
}
