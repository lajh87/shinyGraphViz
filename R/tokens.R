create_token <- function(){
  selector <- sodium::random(6) |> sodium::bin2hex()
  validator <- sodium::random(32) |> sodium::bin2hex()
  paste(selector, validator, sep  = ":")
}

split_token <- function(token){
  stringr::str_split(token, ":") %>% unlist()
}

hash_validator <- function(validator){
  sodium::hex2bin(validator) %>%
    sodium::sha256() %>%
    sodium::bin2hex()
}

create_new_token <- function(pool, session){
  token <- create_token()
  selector <- split_token(token)[1]
  validator <- split_token(token)[2]
  hashed_validator <- hash_validator(validator)
  session$sendCustomMessage("cookie-set", list(name = "token", value = token))

  DBI::dbExecute(pool, glue::glue(
    "INSERT INTO token",
    "VALUES('{selector}', '{hashed_validator}', '0', '{Sys.Date()+90}')",
    .sep = "\n"
  ))
  return(token)
}
