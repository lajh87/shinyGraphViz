library(shiny)
library(shinyAce)
library(DiagrammeR)
library(dbplyr)

pool <- connect_db()
onStop(function(){pool::poolClose(pool)})

ui <- fluidPage(
  loadPanzoom("graph"),
  column(
    width = 4,
    actionButton("load", "Load"),
    actionButton("save", "Save"),
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
  
  # Connect to database
  db <- pool::poolCheckout(pool)
  onStop(function() pool::poolReturn(db))
  
  # Set initial values
  values <- reactiveValues(
    graph = "digraph{a->b}",
    graphtbl = getGraphTbl(db)
  )
  
  # Display graph and observe change to editor
  output$graph <- renderGrViz(grViz(input$ace))
  observe(updateAceEditor(session, "ace", values$graph))
  
  # Load graph 
  observeEvent(input$load,loadModal())
  output$graphtbl <- DT::renderDataTable(graphDT(values$graphtbl))
   
  observeEvent(input$load_graph,{
    values$graph <- getGraph(db, input$graphtbl_rows_selected)
  })
  
  # Save graph 
  observeEvent(input$save, saveModal())
  observeEvent(input$save_graph, {
    save_graph(db, input$save_label, input$ace)
    values$graphtbl <- getGraphTbl(db)
  })
  observeEvent(input$save_error, saveModal())
  
}

shinyApp(ui, server)