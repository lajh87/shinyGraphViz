loginUI <- function(id) {
  ns <- NS(id)
  tagList(
    shinyWidgets::dropdownButton(
      circle = FALSE,
      icon = icon("user"),
      uiOutput(ns("dynamic_login"))
    )
  )
}

loginServer<- function(input, output, session) {

  ns <- session$ns

  # Dynamic Login Button ----
  output$dynamic_login <- renderUI({
    tagList(
      actionLink(ns("login"), "Login"),
      tags$br(),
      actionLink(ns("register"), "Register")
    )
  })

  observeEvent(input$login, login_modal())
  observeEvent(input$register, register_modal())

  # Login ----
  # "root", "4ae5ebd11f051216"

  # Register
  # With link to verify account.

}


login_modal <- function(){
  showModal(
    modalDialog(
      title = "Login",
      size = "s",
      textInput("email", "Enter Email Address"),
      passwordInput("password", "Enter Password"),
      checkboxInput("rememberme", "Remember Me?"),
      footer = tagList(
        tags$p(align = "left", actionLink("forgot_pw", "Forgot Password?")),
        actionButton("login_confirm", "Confirm"),
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

