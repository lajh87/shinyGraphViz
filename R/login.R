loginUI <- function(id) {
  ns <- NS(id)
  tagList(
    shinyWidgets::dropdownButton(
      inputId = ns("dropdown"),
      circle = FALSE,
      icon = icon("user"),
      uiOutput(ns("dynamic_login"))
    )
  )
}

loginServer<- function(input, output, session, pool, token, parent) {

  ns <- session$ns

  values <- reactiveValues(logged_in = FALSE)

  # Dynamic Login Button ----
  output$dynamic_login <- renderUI({
    if(!values$logged_in){
      tagList(
        actionLink(ns("login"), "Login"),
        tags$br(),
        actionLink(ns("register"), "Register")
      )
    } else{
      tagList(
        "You are logged in.",
        tags$br(),
        actionLink(ns("logout"), "Logout")
      )
    }

  })

  # Login using token ----
  # Check whether token is valid and has userid associated.
  observeEvent(token,{
    split_token <- stringr::str_split(token, ":") %>% unlist()
    values$selector <- split_token[1]
    values$validator <- split_token[2]
    values$hashed_validator <- sodium::hex2bin(split_token[2]) %>%
      sodium::sha256() %>%
      sodium::bin2hex()

    db_token <- pool %>% dplyr::tbl("token") %>%
      dplyr::filter(.data$selector == !!values$selector) %>%
      dplyr::collect()

    if(!nrow(db_token)) return(NULL)

    if(db_token$hashed_validator == values$hashed_validator){
      # TODO add expiry.

        values$user <- pool %>%
          dplyr::tbl("user") %>%
          dplyr::filter(.data$userid == !!db_token$userid) %>%
          dplyr::collect()

      if(nrow(values$user)>0){
        values$logged_in <- TRUE
      }

    } else{
      parent$sendCustomMessage("cookie-remove", list(name = "token"))
    }
  })

  # Login through button ----
  observeEvent(input$login, login_modal(ns))
  observeEvent(input$confirm,{
    email <- input$email
    pw <- input$password
    user <- pool %>% dplyr::tbl("user") %>%
      dplyr::filter(username == email) %>%
      dplyr::collect()

    if(length(user$hashed_password)>0 && nchar(user$hashed_password)==101){
      verified <- sodium::password_verify(user$hashed_password, pw)
    } else{
      verified <- FALSE
    }

    if(verified){
      values$user <- user
      values$logged_in <- TRUE
      removeModal()

      if(input$remember){
        DBI::dbExecute(pool, glue::glue(
          "UPDATE token",
          "SET userid = {user$userid}",
          "WHERE selector = '{values$selector}';",
          .sep = "\n"
        ))
      }
    } else{
      shinyjs::show("error")
    }
  }, ignoreInit = TRUE)

  observeEvent(values$logged_in,{
    if(values$logged_in){
      shinyjs::hide("error")
      updateActionButton(session, "dropdown", icon = icon("user", class = "fa-solid"))
    }

  })

  # Logout ----
  observeEvent(input$logout,{
    values$logged_in <- FALSE
    values$user <- NULL
    updateActionButton(session, "dropdown", icon = icon("user"))

    DBI::dbExecute(pool, glue::glue(
      "UPDATE token",
      "SET userid = NULL",
      "WHERE selector = '{values$selector}';",
      .sep = "\n"
    ))

  })

  # Register
  # With link to verify account.
  return(values)

}

login_modal <- function(ns){
  showModal(
    modalDialog(
      title = "Login",
      size = "s",
      textInput(ns("email"), "Enter Email Address"),
      passwordInput(ns("password"), "Enter Password"),
      checkboxInput(ns("remember"), "Remember Me?"),
      div(id = ns("error"), style = "color:red; display: none;", "Incorrect Username or Password"),
      footer = tagList(
        tags$p(align = "left", actionLink(ns("forgot_pw"), "Forgot Password?")),
        actionButton(ns("confirm"), "Confirm"),
        modalButton("Close")

      )
    )
  )
}

register_modal <- function(){
  showModal(
    modalDialog(
      title = "Register",
      size = "s",
      textInput("email", "Enter Email Address"),
      passwordInput("password", "Enter Password"),
      footer = tagList(
        actionButton("register_confirm", "Confirm"),
        modalButton("Close")
      )
    )
  )
}

