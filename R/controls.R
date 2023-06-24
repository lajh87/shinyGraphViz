controlsUI <- function(id) {
  ns <- NS(id)
  tagList(
  actionButton(
    inputId = ns("new"),
    label = NULL,
    icon = icon("file"),
    title = "New"
  ),
  actionButton(
    inputId = ns("save"),
    label = NULL,
    icon = icon("save"),
    title = "Save"
  ),
  actionButton(
    inputId = ns("saveas"),
    label = NULL,
    icon = icon("save",class = "fa-solid fa-flip-horizontal"),
    title = "Save As"
  ),
  actionButton(
    inputId = ns("load"),
    label = NULL,
    icon = icon("folder-open",class = "fa-regular"),
    title = "Load"
  ),
  HTML("&nbsp"),
  HTML("&nbsp"),
  textOutput(
    outputId = ns("filename"),
    inline = TRUE
  )
  )
}

controlsServer <- function(input, output, session, pool, token, login, editor) {

  values <- reactiveValues(token = token)

  observeEvent(token, {
    split_token <- stringr::str_split(token, ":") %>% unlist()
    auto_save_graph <- pool %>% dplyr::tbl("autosave") %>%
      dplyr::collect() %>%
      dplyr::filter(.data$selector == split_token[1])

    if(nrow(auto_save_graph)>0){
      values$graph <- auto_save_graph %>%
        dplyr::mutate(graph = sodium::hex2bin(graph) %>% rawToChar()) %>%
        dplyr::select(-.data$selector)
    } else{
      values$graph <- new_graph()
    }
  }, once = TRUE)

  observe({
    if(!login$logged_in){
      shinyjs::disable(id = "save")
      shinyjs::disable(id = "saveas")
      values$logged_in <- FALSE
      values$user$userid <- 0
    } else{
      shinyjs::enable(id = "save")
      shinyjs::enable(id = "saveas")
      values$user <- login$user
      values$logged_in <- TRUE
    }
    values$editor <- editor

  })

  autoInvalidate <- reactiveTimer(180000) # autosave every 3 minutes (180000ms)
  observeEvent(autoInvalidate(), {
    graph_binary <- values$editor$ace %>%
      charToRaw() %>%
      sodium::bin2hex()

    split_token <- values$token %>% stringr::str_split(":") %>% unlist()
    selector_var <- split_token[1]
    graph <- values$graph

    if(nrow(pool %>%
            dplyr::tbl("autosave") %>%
            dplyr::filter(.data$selector == selector_var) %>%
            dplyr::collect()) == 0){

      statement <- glue::glue(
        "INSERT INTO autosave",
        "VALUES('{selector_var}', {graph$id}, '{graph$label}', '{graph_binary}',",
        "{graph$published}, {graph$protected}, {values$user$userid}) ;",
        .sep = "\n")
       }else{

        statement <- glue::glue(
          "UPDATE autosave",
          "SET id = {graph$id},",
          "label = '{graph$label}',",
          "graph = '{graph_binary}',",
          "published = {graph$published},",
          "protected = {graph$protected},",
          "userid = {values$user$userid}",
          "WHERE selector = '{selector_var}';",
          .sep = "\n"
        )
      }

      DBI::dbExecute(pool, statement)


  }, ignoreInit = TRUE)

  output$filename <- renderText(values$graph$label)

  observeEvent(input$new, values$graph <- new_graph())
  observeEvent(input$load, load_modal(input, output, session, pool, values))
  observeEvent(input$save, save_modal(input, output, session, pool, values))
  observeEvent(input$saveas, saveas_modal(input, output, session, pool, values))

  return(values)

}

new_graph <- function(){
  dplyr::tibble(
    id = 0,
    label = "untitled.gv",
    graph = "digraph {a->b}",
    published = 0,
    protected = 1,
    userid = 1
  )
}
load_modal <- function(input, output, session, pool, values){
  ns <- session$ns

  graphs <- pool %>%
    dplyr::tbl("graph") %>%
    dplyr::collect()

  observe({
    if(values$logged_in){
      values$graphs <- graphs %>%
        dplyr::filter(.data$published == 1 | .data$userid == values$user$userid)
    } else{
      values$graphs <- graphs %>%
        dplyr::filter(.data$published == 1)
    }
  })

  output$graphs_tbl <- DT::renderDataTable(
    values$graphs %>%
      dplyr::select(id, label, protected, published),
    selection = "single",
    rownames = FALSE
  )

  showModal(
    modalDialog(
      title = list("Load", icon("folder-open")),
      DT::dataTableOutput(ns("graphs_tbl")),
      footer = tagList(
        actionButton(
          inputId = ns("load_confirm"),
          label = "Load",
          icon = icon("cloud-download")
        ),
        modalButton(label = "Close")
      )
    )
  )

  observeEvent(input$load_confirm,{
    values$graph <- values$graphs %>%
      dplyr::slice(input$graphs_tbl_rows_selected) %>%
      dplyr::mutate(graph = sodium::hex2bin(graph) %>% rawToChar())

    removeModal()
  }, ignoreInit = TRUE)
}

save_modal <- function(input, output, session, pool, values){
  ns <- session$ns

  # If the user is not logged in it should prompt them to login
  if(values$graph$protected){
      showModal(
        modalDialog(
          title = "Protected",
          "This file is protected. Click save as to save a new version."
        )
      )
  } else{
    showModal(modalDialog(
      title = "Overwrite?",
      "Are you sure you want to overwrite this file",
      footer = tagList(
        actionButton(ns("overwrite_confirm"), "Yes"),
        modalButton("Dismiss")
      )
    ))

    observeEvent(input$overwrite_confirm,{

      graph_binary <- values$editor$ace %>%
        charToRaw() %>%
        sodium::bin2hex()

      id_var <- values$graph$id

      DBI::dbExecute(pool, glue::glue(
        "UPDATE graph",
        "SET graph = '{graph_binary}'",
        "WHERE id = {id_var};",
        .sep = "\n"
      ))

      values$graph <- pool %>%
        dplyr::tbl("graph") %>%
        dplyr::filter(.data$id == id_var) %>%
        dplyr::collect() %>%
        dplyr::mutate(graph = sodium::hex2bin(graph) %>% rawToChar())


      removeModal()
      }, once = TRUE)
  }
}

saveas_modal <- function(input, output, session, pool, values){
  ns <- session$ns
  showModal(
    modalDialog(
      title = "Save As",
      textInput(ns("saveas_label"), "Enter File Name"),
      footer = tagList(
        actionButton(
          inputId = ns("saveas_confirm"),
          label = "Confirm"
        ),
        modalButton(
          label = "Close"
        )
      )
    )
  )

  observeEvent(input$saveas_confirm,{

    max_id <- pool %>% dplyr::tbl("graph") %>%
      dplyr::pull(.data$id) %>% max()

    id_var <- ifelse(is.na(max_id), 1, max_id+1)

    graph_binary <- values$editor$ace %>%
      charToRaw() %>%
      sodium::bin2hex()

    DBI::dbExecute(pool, glue::glue(
      "INSERT INTO graph",
      "VALUES({id_var}, '{input$saveas_label}', '{graph_binary}', 0, 0, {values$user$userid});",
      .sep = "\n"
    ))

    values$graph <- pool %>%
      dplyr::tbl("graph") %>%
      dplyr::filter(.data$id == id_var) %>%
      dplyr::collect() %>%
      dplyr::mutate(graph = sodium::hex2bin(graph) %>% rawToChar())

    removeModal()

  }, ignoreInit = TRUE, once = TRUE)

}
