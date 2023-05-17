loadModal <- function(){
  showModal(
    modalDialog(
      title = "Load a Saved Graph", size = "m",
      DT::DTOutput("graphtbl"),
      footer = tagList(
        actionButton("load_graph", "Load"),
        modalButton("Close")
      ),
      easyClose = TRUE,
      FADE = TRUE
    )
  )
}

graphDT <- function(df){
  DT::datatable(df,
                selection = "single",
                options = list(dom = "ftp",
                               autoWidth = TRUE,
                               columnDefs = list(
                                 list(width = '25px', targets = c(0)),
                                 list(width = '500px', targets = c(1))
                               )),
                rownames = FALSE
  )
}

getGraphTbl <- function(db){
  db |>
    dplyr::tbl("graphviz") |>
    dplyr::select(id, label) |>
    dplyr::collect()
}

getGraph <- function(db, selected_id){
  new_graph <- db |>
    dplyr::tbl("graphviz") |>
    dplyr::filter(.data$id == selected_id) |>
    dplyr::pull(graph)
}