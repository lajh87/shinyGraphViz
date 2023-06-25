library(sendmailR)
#
# sendmail(
#   from="no-reply@graphviz.io",
#   to=c("lukeheley@outlook.com"),
#   subject="SMTP auth test",
#   msg=mime_part("This message was send using sendmailR and curl."),
#   engine = "curl",
#   engineopts = list(username = "lajh87@me.com", password = Sys.getenv("brevo_smtp_key")),
#   control=list(smtpServer="smtp-relay.sendinblue.com:587", verbose = TRUE)
# )
