loginUI <- function(id) {
  ns <- NS(id)
  tagList(
    shinyWidgets::dropdownButton(
      circle = FALSE, 
      icon = icon("user"),
      "You are not logged in"
    )
  )
}

loginServer<- function(input, output, session) {
  
  # Dynamic Login Button
  
  # Login
  # Check the user inputted data against database.
  # If user checks remember me then store a cookie to bypass step in future.
  
  # Register
  # With link to verify account.
  
}
