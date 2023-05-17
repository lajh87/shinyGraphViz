loadPanzoom <- function(outputid){
  tags$head(
    tags$script(src = "panzoom.min.js", name = "pz", query = "#graph")
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

addPanzoomButtonsJS <- function(){
  js <- "Array.from(
    document.querySelectorAll('.button-container a.button')
  ).forEach(attachClickHandler)
  
  function attachClickHandler(el) {
    el.addEventListener('click', handleClick);
  }
  
  function handleClick(e) {
    e.preventDefault();
    let container = document.querySelector('#graph > svg');
    let rect = container.getBBox();
    let cx = rect.x + rect.width/2;
    let cy = rect.y + rect.height/2;
    let isZoomIn = e.target.id === 'zoomIn';
    let zoomBy = isZoomIn ? 2 : 0.5;
    pz.smoothZoom(cx, cy, zoomBy);
    // Or if you don't need animation, usee this:
      // pz.zoomTo(cx, cy, zoomBy);
    }"
  
    tags$script(HTML(js))
}