graphUI <- function(id) {
  ns <- NS(id)
  tagList(
  DiagrammeR::grVizOutput(ns("graph"))
  )
}

graphServer<- function(input, output, session, editor) {
  
  output$graph <- DiagrammeR::renderGrViz(DiagrammeR::grViz(editor$graph))
  
}
