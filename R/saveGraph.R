saveModal <- function(label){
  
  showModal(modalDialog(
    title = "Save Current Graph",
    tagList(
      textInput(inputId = "save_label", label = "Label",value = label)
    ),
    footer = tagList(
      actionButton("save_graph", "Save"),
      modalButton("Close")
    )
  ))
}

save_graph <- function(db, save_label, graph, overwrite){
  
  if(length(save_label) ==0 | nchar(save_label)==0){
    showModal(modalDialog(
      title = "Error", "Label must not be null",
      footer = actionButton("save_error", "Dismiss")
    ))
  } else{
    if(overwrite){
      
      id <- db |> dplyr::tbl("graphviz") |> 
        dplyr::filter(.data$label == save_label) |>
        dplyr::pull(id)
      
      if(id == 1)
        showModal(
          modalDialog(title = "Error", "Cannot overwrite protected graph.")
        )
      
      q <- glue::glue(
        "UPDATE `graphviz`",
        "SET graph = '{graph}'",
        "WHERE id = {id}", 
        .sep = "\n"
      )
      DBI::dbExecute(db, q)
      
    } else{
      id <- db |> dplyr::tbl("graphviz") |> dplyr::pull(id) |> max() +1
      q <- glue::glue(
        "INSERT INTO graphviz", 
        "VALUES ({id}, '{save_label}', '{graph}');",
        .sep = "\n"
      )
      DBI::dbExecute(db, q)
    }
    
    showModal(modalDialog(title = "Success", "Graph saved successfully"))
  }
 
}
