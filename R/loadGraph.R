loadModal <- function(){
  showModal(
    modalDialog(
      title = "Load a Saved Graph", size = "m",
      DT::DTOutput("graphtbl"),
      footer = tagList(
        actionButton("load_graph", "Load"),
        actionButton("delete_graph", "Delete"),
        modalButton("Close")
      ),
      easyClose = TRUE,
      FADE = TRUE
    )
  )
}

getGraphTbl <- function(db){
  db |>
    dplyr::tbl("graphviz") |>
    dplyr::select(id, label) |>
    dplyr::collect()
}

getLabel <- function(db, row_id){
  db |> 
    dplyr::tbl("graphviz") |>
    dplyr::filter(dplyr::row_number()== row_id) |>
    dplyr::pull(.data$label)
}

getGraph <- function(db, row_id){
  db |>
    dplyr::tbl("graphviz") |>
    dplyr::filter(dplyr::row_number() == row_id) |>
    dplyr::pull(graph)
}

deleteGraph <- function(db, row_id){
  
  selected_id <- db |>
    dplyr::tbl("graphviz") |>
    dplyr::filter(dplyr::row_number() == row_id) |>
    dplyr::pull(.data$id)
  
  q <- glue::glue(
    "DELETE FROM graphviz WHERE id = {selected_id};"
  )
  DBI::dbExecute(db, q)
}