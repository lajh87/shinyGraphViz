loadPanzoom <- function(){
  tags$head(
    includeScript("www/panzoom.min.js")
  )
}

panzoomOutput <- function(outputid){
  tags$script(
    HTML(
      glue::glue(
        "var element = document.querySelector('#{outputid}');",
        "panzoom(element);", 
        .sep = "\n"
        )
    )
  )
  
}