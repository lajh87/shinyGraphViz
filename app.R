library(shiny)
library(shinyAce)
library(DiagrammeR)

pool <- connect_db()
onStop(function(){pool::poolClose(pool)})

ui <- fluidPage(
  loadPanzoom(),
  column(
    width = 4,
    aceEditor("ace", "digraph{a->b}", "dot")
  ),
  column(
    width = 8,
    grVizOutput("graph"),
    panzoomOutput("graph")
  )
)

server <- function(input, output, session) {
  
  output$graph <- renderGrViz({
    grViz(input$ace)
  })

}

shinyApp(ui, server)