library(shiny)
library(shinyAce)
library(DiagrammeR)
library(dbplyr)
library(shinyFeedback)

# pool <- connect_db()
# onStop(function(){pool::poolClose(pool)})

ui <- fluidPage(
  loadPanzoom("graph"),
  includeCSS("www/style.css"),
  useShinyFeedback(),
  fluidRow(
    column(
      width = 12,
      actionButton("load", "Load"),
      actionButton("save", "Save"),
      div(style = "z-index: 20000;",
          selectInput("engine", "Engine", 
                      c("dot", "neato", "circo", "twopi"),
                      selectize = TRUE
                      )),
      span(
        style = "float:right;",
        shinyWidgets::dropdownButton(
          "You are not logged in.",
          inline = TRUE,
          right = TRUE,
          icon = icon("user"),
          circle = FALSE,
          style = "z-index: 10000;"
        )
      )
    )
  ),
  fluidRow(
    column(
      width = 4,
      aceEditor(outputId = "ace",value = NULL, mode =  "dot", height = "90vh")
    ),
    column(
      width = 8,
      grVizOutput("graph", height = "90vh", width = "100%"),
      tags$script(
        HTML('panzoom($("#graph")[0], {
          bounds: true,
           boundsPadding: 0.2
        });')
      )
  )
)
)

server <- function(input, output, session) {
  
  # Connect to database
  # db <- pool::poolCheckout(pool )
  # onSessionEnded(function() pool::poolReturn(db))
  # onStop(function(){pool::poolReturn(db)})

  # Set initial values
  values <- reactiveValues(
    graph = "digraph{a->b}",
    # graphtbl = getGraphTbl(db),
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