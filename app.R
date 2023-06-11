library(shiny)

graphviz <- DBI::dbConnect(
  odbc::odbc(),
  driver = "MySQL ODBC 8.0 Unicode Driver",
  database = "graphviz",
  UID    = "lheley",
  PWD    = Sys.getenv("mysql_pw"),
  host = "localhost",
  port = 3306,
)


ui <- fluidPage(
  loadPanzoom(),
  includeCSS("www/style.css"),
  includeScript("www/panzoom-shiny.js"),
  fluidRow(
      column(
        width = 12,
        shinyWidgets::dropdownButton(
          "You are not logged in.",
          inline = TRUE,
          right = FALSE,
          icon = icon("user"),
          circle = FALSE,
          text = "Login"
        ),
        actionButton("new", NULL, title = "New", icon("file")),
        actionButton("save", NULL, title = "Save", icon("save")),
        actionButton("load", NULL, title = "Load", icon("folder-open")),
        HTML("&nbsp"),HTML("&nbsp"),
        textOutput("filename", inline = TRUE)
      )
  ),

  fluidRow(
    column(
      width = 3,
      shinyAce::aceEditor(
        outputId = "ace", 
        value = "digraph g{a->b}", 
        mode = "dot",
        height = "85vh"
      )
    ),
    column(
      width = 9,
      div(
        id = "graph-container",
        style = "overflow: hidden;",
        DiagrammeR::grVizOutput("graph", height = "90vh"),
        tags$script(
          HTML('pz = panzoom($("#graph")[0], {
            bounds: true,
            zoomDoubleClickSpeed: 1
        }); pz.zoomAbs(0, 0, 0.7);')
        ),
        tags$div(
          style = "position: absolute; right: 30px; top: 5px;",
          downloadButton(
            outputId = "download_plot",
            label = NULL,
            icon = icon("download")
          )
        ),
        tags$style(
          type = 'text/css',
          paste('.modal-dialog { width: 100% !important; }',
                '.modal-body {height: 90vh !important;}', sep = "\n")
        ),
        tags$div(
          style = "position: absolute; right: 30px; top: 50px;",
          actionButton(
            inputId = "fullscreen",
            label = NULL,
            icon = icon("expand")
          )
        ),
        
        tags$div(
          style = "position: absolute; right: 30px; bottom: 79px;",
          actionButton(
            inputId = "zoomin",
            label = NULL,
            icon = icon("plus")
          )
        ),
        tags$div(
          style = "position: absolute; right: 30px; bottom: 42px;",
          actionButton(
            inputId = "reset",
            label = NULL,
            icon = icon("arrows-alt")
          )
        ),
        tags$div(
          style = "position: absolute; right: 30px; bottom: 5px;",
          actionButton(
            inputId = "zoomout",
            label = NULL,
            icon = icon("minus")
          )
        ),
        tags$div(
          style = "position: absolute; right: 100px; bottom: 5px;",
          tags$em(tags$a(href = "", "Defence Economics"), "| Graphviz")
        )
        
      )
        )
      )
    )
  
server <- function(input, output, session) {
  
  values <- reactiveValues(
    graph = "digraph g{a->b}" 
  )
  
  output$graph <- DiagrammeR::renderGrViz({
    message(input$engine)
    DiagrammeR::grViz(values$graph)
  })
  
  observeEvent(input$ace,{
    values$graph <- input$ace
  }, ignoreInit = TRUE)
  
  observeEvent(input$zoomin,{
    session$sendCustomMessage("panzoom_handler","zoomIn")
  }, ignoreInit = TRUE)
  observeEvent(input$zoomout,{
    session$sendCustomMessage("panzoom_handler","zoomOut")
  }, ignoreInit = TRUE)
  observeEvent(input$reset,{
    session$sendCustomMessage("panzoom_reset","reset")
  }, ignoreInit = TRUE)
  
  observeEvent(input$fullscreen,{
    showModal(
      modalDialog(easyClose = TRUE,
                  DiagrammeR::grViz(values$graph, height = "100%", width = "100%"))
    )
  })
  
  output$download_plot <- downloadHandler(
    filename = function(){
      paste0(Sys.time(),"plot.svg")
    }, content = function(file){
      gv <- DiagrammeR::grViz(values$graph, height = "100%", width = "100%")
      svg <- DiagrammeRsvg::export_svg(gv)
      write(svg, file)
    }
  )
  
  output$filename <- renderText({"untitled.gv"})
  
}

shinyApp(ui, server)
