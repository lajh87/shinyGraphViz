loadPanzoom <- function(){
  tags$head(
    tags$script(src = "panzoom.min.js")
  )
}

panzoomOutput <- function(outputid){
  tags$script(
    HTML(
      glue::glue(
        "panzoom($(#{{outputid}})[0], {
          bounds: true,
          boundsPadding: 0.1
          });;",
        .sep = "\n",.open = "{{", .close = "}}"
        )
    )
  )
}

addZoomButtons <- function(){
  tags$div(
    class = "zoom-button-container", 
    shinyWidgets::actionGroupButtons(
      c("zoomIn", "zoomOut"),
      c("+", "-"),
      direction = "vertical"
    )
  )
}

addZoomButtonsJS <- function(outputid){
  js <- glue::glue("Array.from(
    document.querySelectorAll('.zoom-button-container button')
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