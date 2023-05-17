saveModal <- function(){
  showModal(modalDialog(
    title = "Save Current Graph",
    tagList(
      textInput("save_label", "Label")
    ),
    footer = tagList(
      actionButton("save_graph", "Save"),
      modalButton("Close")
    )
  ))
}

save_graph <- function(db, save_label, graph){
  id <- db |> dplyr::tbl("graphviz") |> dplyr::collect() |> nrow() + 1
  
  if(length(save_label) ==0 | nchar(save_label)==0){
    showModal(modalDialog(title = "Error", "Label must not be null",
                          footer = actionButton("save_error", "Dismiss")))
  } else{
    q <- glue::glue(
      "INSERT INTO graphviz", 
      "VALUES ({id}, '{save_label}', '{graph}');",
      .sep = "\n"
    )
    DBI::dbExecute(db, q)
    message <- ""
    showModal(modalDialog(title = "Success", "Graph saved successfully"))
  }
  message
}
