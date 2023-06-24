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

DBI::dbListTables(graphviz)

# Create User Table
DBI::dbExecute(graphviz, "DROP TABLE IF EXISTS user;")
DBI::dbExecute(
  conn = graphviz,
  statement = glue::glue(
    "CREATE TABLE user(",
    "userid INT PRIMARY KEY,",
    "username TEXT,",
    "hashed_password TEXT,",
    "admin INT",
    ");",
    .sep = "\n"
  ))

## Add root
pw <- sodium::random(8) |>
  sodium::bin2hex()
print(pw)
hashed <- sodium::password_store(pw)
DBI::dbExecute(graphviz, glue::glue(
"INSERT INTO user",
"VALUES(1, 'root', '{hashed}', 1);",
.sep = "\n"
))

# Create Token Table
DBI::dbExecute(graphviz, "DROP TABLE IF EXISTS token;")
DBI::dbExecute(
  conn = graphviz,
  statement = glue::glue(
    "CREATE TABLE token(",
    "selector CHAR(8),",
    "hashed_validator CHAR(64),",
    "userid INT",
    ");",
    .sep= "\n"
  )
)
