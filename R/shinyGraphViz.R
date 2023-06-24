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

    observeEvent(input$cookies, {

      if(is.null(input$cookies$token)){
        # If there is no cookie in the browswer then create one and log in database.
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
          "VALUES('{selector}', '{hashed_validator}', '0', '{Sys.Date()+90}')",
          .sep = "\n"
        ))
      } else{
        values$token <- input$cookies$token
        split_token <- stringr::str_split(values$token, ":") %>% unlist()

        expiry_date <- pool %>% dplyr::tbl("token") %>%
          dplyr::collect() %>%
          dplyr::filter(.data$selector == split_token[1]) %>%
          dplyr::pull(.data$expires)

        if(length(expiry_date) == 0){
          session$sendCustomMessage("cookie-remove", list(name = "token"))
        } else{
          if(as.Date(expiry_date) < Sys.Date()){
            ## if it has remove cookie from browser and database
            session$sendCustomMessage("cookie-remove", list(name = "token"))
            DBI::dbExecute(pool, glue::glue(
              "DELETE FROM token WHERE selector = '{split_token[1]}';"
            ))
          }
        }
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
