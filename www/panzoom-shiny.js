console.log("panzoom-shiny loaded");

Shiny.addCustomMessageHandler("panzoom_handler", panzoom_zoom);
Shiny.addCustomMessageHandler("panzoom_reset", panzoom_reset);

function panzoom_zoom(message){
  let container = document.querySelector('#graph > svg');
  let rect = container.getBBox();
  let cx = rect.x + rect.width/2;
  let cy = rect.y + rect.height/2;
  let isZoomIn = message === 'zoomIn';
  let zoomBy = isZoomIn ? 1.1 : 0.9;
  pz.smoothZoom(cx, cy, zoomBy);
}

function panzoom_reset(x){
  pz.moveTo(0, 0);
  pz.zoomAbs(0, 0, 0.9);
}
