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