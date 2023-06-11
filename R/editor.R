editorUI <- function(id) {
  ns <- NS(id)
  tagList(
    shinyAce::aceEditor(
      outputId = ns("ace"),
      value = "",
      mode = "dot"
    )
  )
}

editorServer<- function(input, output, session) {
  
  values <- reactiveValues(
    graph = "digraph {a->b}"
  )
  
  observe({
    shinyAce::updateAceEditor(
      session = session,
      editorId = "ace",
      value = values$graph
    )
  })
  
  return(values)
}
