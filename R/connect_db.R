connect_db <- function(
    dbname = Sys.getenv("MYSQL_ADDON_DB"),
    host = Sys.getenv("MYSQL_ADDON_HOST"),
    port = Sys.getenv("MYSQL_ADDON_PORT"),
    user = Sys.getenv("MYSQL_ADDON_USER"),
    password = Sys.getenv("MYSQL_ADDON_PASSWORD")
    ){
  pool::dbPool(
    RMySQL::MySQL(),
    maxSize = 5,
    dbname = dbname,
    host = host,
    port = as.numeric(port),
    user = user,
    password = password
  )
               
}
