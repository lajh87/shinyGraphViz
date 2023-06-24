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

editorServer<- function(input, output, session, controls) {

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

  observeEvent(controls$graph,{
    values$graph <- controls$graph$graph
  }, ignoreInit = TRUE)

  observeEvent(input$ace, values$ace <- input$ace)

  return(values)
}
