library(shiny)
library(shinyAce)
library(DiagrammeR)

pool <- connect_db()
onStop(function(){pool::poolClose(pool)})

ui <- fluidPage(
  loadPanzoom("graph"),
  column(
    width = 4,
    actionButton("load", "Load"),
    aceEditor(outputId = "ace",value = NULL ,mode =  "dot")
  ),
  column(
    width = 8,
    grVizOutput("graph"),
    panzoomOutput("graph"),
    addPanzoomButtons(),
    addPanzoomButtonsJS("graph")
  )
)

server <- function(input, output, session) {
  
  # Connect to database and set initial values
  db <- pool::poolCheckout(pool)
  values <- reactiveValues(graph = "digraph{a->b}")
  
  # Display graph and observe change to editor
  output$graph <- renderGrViz(grViz(input$ace))
  
  observe({
    updateAceEditor(
      session, 
      "ace", 
      values$graph
    )
  })
  
  # Load Graph ----
  observeEvent(input$load,loadModal())
  output$graphtbl <- DT::renderDataTable(graphDT(db))
   
  observeEvent(input$load_graph,{
    values$graph <- getGraph(db, input$graphtbl_rows_selected)
  })
  
  # Return checkout connection object
  onStop(function() pool::poolReturn(db))
}

shinyApp(ui, server)