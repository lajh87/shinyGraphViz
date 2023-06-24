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
    "selector CHAR(12),",
    "hashed_validator CHAR(64),",
    "userid INT,",
    "expires DATE",
    ");",
    .sep= "\n"
  )
)
DBI::dbExecute(graphviz, "DROP TABLE IF EXISTS graph;")
DBI::dbExecute(
  conn = graphviz,
  statement = glue::glue(
    "CREATE TABLE graph(",
    "id INT PRIMARY KEY,",
    "label TEXT,",
    "graph MEDIUMBLOB,",
    "published INT,",
    "protected INT,",
    "userid INT",
    ");",
    .sep = "\n"
  )
)
g1 <- system.file("examples/siblings.gv", package = "shinyGraphViz") %>%
  readLines() %>% paste(collapse = "\n") %>%
  charToRaw() %>%
  sodium::bin2hex()

DBI::dbExecute(
  graphviz,
  glue::glue(
    "INSERT INTO graph",
    "VALUES(1, 'siblings', '{{{g1}}}', 1, 1, 1);",
    .sep = "\n",
    .open = "{{{",
    .close = "}}}",
  )
)

DBI::dbExecute(graphviz, "DROP TABLE IF EXISTS autosave;")
DBI::dbExecute(
  conn = graphviz,
  statement = glue::glue(
    "CREATE TABLE autosave(",
    "selector CHAR(12),",
    "id INT,",
    "label TEXT,",
    "graph MEDIUMBLOB,",
    "published INT,",
    "protected INT,",
    "userid INT",
    ");",
    .sep = "\n"
  )
)

DBI::dbDisconnect(con)
DBI::dbDisconnect(graphviz)
