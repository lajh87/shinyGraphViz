loadPanzoom <- function(outputid){
  tags$head(
    tags$script(src = "panzoom.min.js", name = "pz", query = glue::glue("#{outputid}"))
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

addPanzoomButtons <- function(){
  tags$div(
    class = "button-container", 
    shinyWidgets::actionGroupButtons(
      c("zoomIn", "zoomOut", "fullScreen"),
      c("+", "-", list(icon("expand")))
    )
  )
}

addPanzoomButtonsJS <- function(outputid){
  js <- glue::glue("Array.from(
    document.querySelectorAll('.button-container button')
  ).forEach(attachClickHandler)
  
  function attachClickHandler(el) {
    el.addEventListener('click', handleClick);
  }
  
  function handleClick(e) {
    e.preventDefault();
    let container = document.querySelector('#<<outputid>> > svg');
    let rect = container.getBBox();
    let cx = rect.x + rect.width/2;
    let cy = rect.y + rect.height/2;
    let isZoomIn = e.target.id === 'zoomIn';
    let zoomBy = isZoomIn ? 2 : 0.5;
    pz.smoothZoom(cx, cy, zoomBy);
    // Or if you don't need animation, usee this:
      // pz.zoomTo(cx, cy, zoomBy);
    }", .open = "<<", .close = ">>")
  
    tags$script(HTML(js))
}