library(shiny)
library(shinyAce)
library(DiagrammeR)

pool <- connect_db()
onStop(function(){pool::poolClose(pool)})

ui <- fluidPage(
  tags$head(
    includeScript("www/panzoom.min.js")
  ),
  column(
    width = 4,
    aceEditor("ace", "digraph{a->b}", "dot")
  ),
  column(
    width = 8,
    grVizOutput("graph"),
    tags$script(
      HTML(
        "
        var element = document.querySelector('#graph');
        panzoom(element);
        "
      )
    )
  )
)

server <- function(input, output, session) {
  
  output$graph <- renderGrViz({
    grViz(input$ace)
  })

}

shinyApp(ui, server)