con <- DBI::dbConnect(
  odbc::odbc(),
  driver = "MySQL ODBC 8.0 Unicode Driver",
  UID    = "root",
  PWD    = Sys.getenv("mysql_root_pw"),
  host = "localhost",
  port = 3306
)

# Create Database
DBI::dbExecute(con, "CREATE DATABASE IF NOT EXISTS graphviz;")

graphviz <- DBI::dbConnect(
  odbc::odbc(),
  driver = "MySQL ODBC 8.0 Unicode Driver",
  database = "graphviz",
  UID    = "lheley",
  PWD    = Sys.getenv("mysql_pw"),
  host = "localhost",
  port = 3306,
)


# Create User Table
DBI::dbExecute(graphviz, "DROP TABLE IF EXISTS auth_users;")
DBI::dbExecute(
  conn = graphviz,
  statement = glue::glue(
    "CREATE TABLE auth_users(",
    "userid INT PRIMARY KEY,",
    "username CHAR,",
    "hashed_password CHAR,",
    "admin INT",
    ");",
    .sep = "\n"
  ))


# Create Token Table
DBI::dbExecute(graphviz, "DROP TABLE IF EXISTS auth_tokens;")
DBI::dbExecute(
  conn = graphviz, 
  statement = glue::glue(
    "CREATE TABLE auth_tokens(",
    "selector CHAR,",
    "hashed_validator CHAR,",
    "userid INT",
    ");", 
    .sep= "\n"
  )
)
