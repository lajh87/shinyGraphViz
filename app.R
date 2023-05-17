library(shiny)
library(shinyAce)
library(DiagrammeR)
library(dbplyr)
library(shinyFeedback)
pool <- connect_db()
onStop(function(){pool::poolClose(pool)})

ui <- fluidPage(
  loadPanzoom("graph"),
  useShinyFeedback(),
  tags$head(tags$style("#fullscreen-modal .modal-dialog {
    width: 100vw;
    max-width: none;
    height: 100% !important;
    margin: 0;}")),
  column(
    width = 4,
    actionButton("load", "Load"),
    actionButton("save", "Save"),
    aceEditor(outputId = "ace",value = NULL, mode =  "dot")
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
    graphtbl = getGraphTbl(db),
    label = NA
  )
  
  # Display graph and observe change to editor
  output$graph <- renderGrViz(grViz(input$ace))
  observe(updateAceEditor(session, "ace", values$graph))
  observeEvent(input$fullScreen,{
    showModal(div(id="fullscreen-modal",modalDialog(grViz(values$graph))))
  })
  
  # Load graph 
  observeEvent(input$load,loadModal())
  output$graphtbl <- DT::renderDataTable(graphDT(values$graphtbl))
   
  observeEvent(input$load_graph,{
    req(input$graphtbl_rows_selected)
    values$graph <- getGraph(db, input$graphtbl_rows_selected)
    values$label <- getLabel(db, input$graphtbl_rows_selected)
  })
  
  # Delete graph
  observeEvent(input$delete_graph,{
    req(input$graphtbl_rows_selected)
    if(input$graphtbl_rows_selected==1){
      showModal(modalDialog(title = "Error", "Cannot delete protected graph."))
    } else{
      deleteGraph(db, input$graphtbl_rows_selected)
      values$graphtbl <- getGraphTbl(db)
    }
  })
  
  # Save graph 
  observeEvent(input$save, saveModal(values$label))
  observeEvent(input$save_label, {
    
    if (input$save_label %in% values$graphtbl$label) {
      showFeedbackWarning(
        inputId = "save_label",
        text = "Saving will overwrite existing graph."
      )  
    } else {
      hideFeedback("save_label")
    }
    
  })
  observeEvent(input$save_graph, {
    overwrite <- input$save_label %in% values$graphtbl$label
    save_graph(db, input$save_label, input$ace, overwrite)
    values$graphtbl <- getGraphTbl(db)
  })
  observeEvent(input$save_error, saveModal())
  
}

shinyApp(ui, server)