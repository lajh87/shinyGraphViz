graphUI <- function(id) {
  ns <- NS(id)
  tagList(
  grVizOutput(ns("graph"))
  )
}

graphServer<- function(input, output, session, editor) {

  output$graph <- renderGrViz(grViz(editor$ace))


  # TODO Add the panzoom functionality.

  # TODO The the autosave functionality.


}

#' R + viz.js
#'
#' Make diagrams in R using `viz.js` with infrastructure provided by
#' pkg{htmlwidgets}.
#'
#' @param diagram Spec for a diagram as either text, filename string, or file
#'   connection.
#' @param engine String for the Graphviz layout engine; can be `dot` (default),
#'   `neato`, `circo`, or `twopi`.
#' @param allow_subst A boolean that enables/disables substitution
#'   functionality.
#' @param options Parameters supplied to the htmlwidgets framework.
#' @param width An optional parameter for specifying the width of the resulting
#'   graphic in pixels.
#' @param height An optional parameter for specifying the height of the
#'   resulting graphic in pixels.
#' @param envir The environment in which substitution functionality takes place.
#'
#' @return An object of class `htmlwidget` that will intelligently print itself
#'   into HTML in a variety of contexts including the R console, within R
#'   Markdown documents, and within Shiny output bindings.
#'
#' @author Richard Iannone
#'
#' @export
grViz <- function(diagram = "",
                  engine = "dot",
                  allow_subst = TRUE,
                  options = NULL,
                  width = NULL,
                  height = NULL,
                  envir = parent.frame()) {

  # Check for a connection or file
  is_connection_or_file <-
    inherits(diagram[1], "connection") || file.exists(diagram[1])

  # Obtain the diagram text via `readLines()`
  if (is_connection_or_file) {
    diagram <- readLines(diagram, encoding = "UTF-8", warn = FALSE)
  }

  diagram <- paste0(diagram, collapse = "\n")

  if (allow_subst == TRUE) {
    diagram <- replace_in_spec(diagram, envir = envir)
  }

  # Single quotes within a diagram spec are problematic
  # so try to replace with `\"`
  diagram <- gsub(x = diagram, "'", "\"")

  # Forward options using `x`
  x <-
    list(
      diagram = diagram,
      config = list(
        engine = engine,
        options = options
      )
    )

  # Only use the Viewer for newer versions of RStudio,
  # but allow other, non-RStudio viewers
  viewer.suppress <-
    rstudioapi::isAvailable() &&
    !rstudioapi::isAvailable("0.99.120")

  # Create the widget
  htmlwidgets::createWidget(
    name = "grViz",
    x = x,
    width = width,
    height = height,
    package = "DiagrammeR",
    htmlwidgets::sizingPolicy(viewer.suppress = viewer.suppress)
  )
}

#' Widget output function for use in Shiny
#'
#' @param outputId Output variable to read from.
#' @param width A valid CSS unit for the width or a number, which will be
#'   coerced to a string and have `px` appended.
#' @param height A valid CSS unit for the height or a number, which will be
#'   coerced to a string and have `px` appended.
#'
#' @export
#' @author Richard Iannone
grVizOutput <- function(outputId,
                        width = "100%",
                        height = "400px") {

  htmlwidgets::shinyWidgetOutput(
    outputId = outputId,
    name = "grViz",
    width = width,
    height = height,
    package = "DiagrammeR"
  )
}

#' Widget render function for use in Shiny
#'
#' @param expr an expression that generates a DiagrammeR graph
#' @param env the environment in which to evaluate expr.
#' @param quoted is expr a quoted expression (with quote())? This is useful if
#'   you want to save an expression in a variable.
#' @seealso [grVizOutput()] for an example in Shiny.
#' @export
#' @author Richard Iannone
renderGrViz <- function(expr,
                        env = parent.frame(),
                        quoted = FALSE) {

  if (!quoted) expr <- substitute(expr)

  htmlwidgets::shinyRenderWidget(
    expr = expr,
    outputFunction = grVizOutput,
    env = env,
    quoted = TRUE
  )
}

#' Add MathJax-formatted equation text
#'
#' @param gv A `grViz` htmlwidget.
#' @param include_mathjax A `logical` to add mathjax JS. Change to `FALSE` if
#'   using with \pkg{rmarkdown} since MathJax will likely already be added.
#'
#' @return A `grViz` htmlwidget
#'
#' @keywords internal
#' @export
add_mathjax <- function(gv = NULL,
                        include_mathjax = TRUE) {

  stopifnot(!is.null(gv), inherits(gv, "grViz"))

  gv$dependencies <-
    c(
      gv$dependencies,
      list(htmltools::htmlDependency(
        name = "svg_mathjax2",
        version = "0.1.0",
        src = c(href="https://cdn.rawgit.com/timelyportfolio/svg_mathjax2/master/"),
        script = "svg_mathjax2.js")))

  if (include_mathjax){
    htmltools::browsable(
      htmltools::tagList(
        gv,
        htmltools::tags$script(src = "http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_SVG"),
        htmlwidgets::onStaticRenderComplete(
          "setTimeout(function(){new Svg_MathJax().install()}, 4000);"
        )
      ))
  } else {
    htmltools::browsable(htmltools::tagList(
      gv,
      htmlwidgets::onStaticRenderComplete(
        "setTimeout(function(){new Svg_MathJax().install()}, 4000);"
      )
    ))
  }
}

#' @author Richard Iannone
replace_in_spec <- function(spec, envir = parent.frame()) {

  # Directive for marking subscripted text in a label or tooltip '@_'
  if (grepl("@_", spec)) {

    spec <- gsub('(label|tooltip)[ ]*=[ ]*\'(.*?)@_\\{(.*?)\\}(.*?)\'',
                 '\\1 = <\\2<FONT POINT-SIZE=\'8\'><SUB>\\3</SUB></FONT>\\4>',
                 spec, perl = TRUE)
  }

  # Directive for marking superscripted text in a label or tooltip '@_'
  if (grepl("@\\^", spec)) {

    spec <- gsub('(label|tooltip)[ ]*=[ ]*\'(.*?)@\\^\\{(.*?)\\}(.*?)\'',
                 '\\1 = <\\2<FONT POINT-SIZE=\'8\'><SUP>\\3</SUP></FONT>\\4>',
                 spec, perl = TRUE)
  }

  # Make a second pass to add subscripts as inline HTML
  while (grepl('(label|tooltip)[ ]*=[ ]*<(.*?)@_\\{(.+?)\\}(.*?)>', spec)) {

    spec <- gsub('(label|tooltip)[ ]*=[ ]*<(.*?)@_\\{(.*?)\\}(.*?)>',
                 '\\1 = <\\2<FONT POINT-SIZE=\'8\'><SUB>\\3</SUB></FONT>\\4>',
                 spec, perl = TRUE)
  }

  # Make a second pass to add superscripts as inline HTML
  while (grepl('(label|tooltip)[ ]*=[ ]*<(.*?)@\\^\\{(.+?)\\}(.*?)>', spec)) {

    spec <- gsub('(label|tooltip)[ ]*=[ ]*<(.*?)@\\^\\{(.*?)\\}(.*?)>',
                 '\\1 = <\\2<FONT POINT-SIZE=\'8\'><SUP>\\3</SUP></FONT>\\4>',
                 spec, perl = TRUE)
  }

  # Directive for substitution of arbitrary specification text '@@'
  if (grepl("@@", spec)) {

    # Extract the spec into several pieces: first being the body,
    # subsequent pieces belonging the replacement references
    spec_body <- unlist(strsplit(x = spec, "\\n\\s*\\[1\\]:"))[1]

    spec_references <-
      paste0("[1]:", unlist(strsplit(x = spec, "\\n\\s*\\[1\\]:"))[2])

    # Split the references into a vector of R statements
    split_references <-
      gsub("\\[[0-9]+\\]:[ ]?", "", unlist(strsplit(x = spec_references, "\\n")))

    # Evaluate the expressions and save into a list object
    for (i in 1:length(split_references)) {

      if (i == 1) {
        eval_expressions <- list()
      }

      eval_expressions <-
        c(
          eval_expressions,
          list(eval(parse(text = split_references[i]), envir = envir))
        )
    }

    # Make replacements to the spec body for each replacement that has no hyphen
    for (i in 1:length(split_references)) {
      while (grepl(paste0("@@", i, "([^-0-9])"), spec_body)) {
        spec_body <-
          gsub(paste0("@@", i, "(?=[^-0-9])"), eval_expressions[[i]][1], spec_body, perl = TRUE)
      }
    }

    # If the replacement has a hyphen, then obtain the digit(s) immediately
    # following and return the value from that index
    for (i in 1:length(split_references)) {
      while (grepl(paste0("@@", i, "-", "[0-9]+"), spec_body)) {

        the_index <-
          gsub(
            "^([0-9]+)(.*)", "\\1",
            strsplit(spec_body, paste0("@@", i, "-"))[[1]][2]
          ) %>%
          as.numeric()

        if (the_index > length(eval_expressions[[i]])) {

          spec_body <-
            gsub(
              paste0("@@", i, "-", the_index, "([^0-9])"),
              paste0(eval_expressions[[i]][length(eval_expressions[[i]])], "\\1"),
              spec_body
            )

        } else {

          spec_body <-
            gsub(
              paste0("@@", i, "-", the_index, "([^0-9])"),
              paste0(eval_expressions[[i]][the_index], "\\1"),
              spec_body
            )
        }
      }
    }

    # Return the updated spec with replacements evaluated
    return(spec_body)
  }

  if (grepl("@@", spec) == FALSE) {
    return(spec)
  }
}

