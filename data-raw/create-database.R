
graph <- paste(readLines("data-raw/git.gv"), collapse = "\n")
source("R/connect_db.R")
db <- connect_db()
DBI::dbExecute(db, "DROP TABLE IF EXISTS `graphviz`;")

# Create Table
q <- paste(
  "CREATE TABLE graphviz (",
  "id int NOT NULL,",
  "label varchar(255),",
  "graph MEDIUMTEXT,",
  "PRIMARY KEY (id)",
  ");",
  sep = " "
)
DBI::dbExecute(db, q)

q <- glue::glue("INSERT INTO graphviz VALUES (1, 'git', '{graph}')")
DBI::dbExecute(db, q)
