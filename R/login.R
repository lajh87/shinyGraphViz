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

loginServer<- function(input, output, session, pool) {

  ns <- session$ns

  values <- reactiveValues()

  # Dynamic Login Button ----
  output$dynamic_login <- renderUI({
    tagList(
      actionLink(ns("login"), "Login"),
      tags$br(),
      actionLink(ns("register"), "Register")
    )
  })

  observeEvent(input$login, login_modal(ns))

  # Login ----
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
      shinyjs::hide("error")
      updateActionButton(session, "dropdown", icon = icon("user", class = "fa-solid"))
    } else{
      shinyjs::show("error")
    }
  }, ignoreInit = TRUE)

  # Register
  # With link to verify account.

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

