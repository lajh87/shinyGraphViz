library(shiny)
library(shinyAce)
library(DiagrammeR)
# https://stackoverflow.com/questions/70381005/how-to-add-controls-in-panzoom-functionality-in-shiny-app
# pool <- connect_db()
# onStop(function(){pool::poolClose(pool)})

ui <- fluidPage(
  loadPanzoom("graph"),
  column(
    width = 4,
    aceEditor("ace", "digraph{a->b}", "dot")
  ),
  column(
    width = 8,
    grVizOutput("graph"),
    panzoomOutput("graph"),
    tags$div(
      class = "button-container", 
      shinyWidgets::actionGroupButtons(
        c("zoomIn", "zoomOut"),
        c("+", "-")
      )
    ),
    addPanzoomButtonsJS()
  )
)

server <- function(input, output, session) {
  
  output$graph <- renderGrViz({
    grViz(input$ace)
  })

}

shinyApp(ui, server)