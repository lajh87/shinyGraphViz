
# shinyGraphViz

<!-- badges: start -->
<!-- badges: end -->

The goal of shinyGraphViz is to create a editor to CREATE, READ, UPDATE and DELETE graphViz objects created in the DOT language. 

## Prerequisites

To enable persistent data storage you need to connect to a MySQL database with READ/WRITE access.

I use a free instance on [Clever Cloud](https://www.clever-cloud.com/).

The `connect_db` function uses the following default environment variables:

```
MYSQL_ADDON_HOST=<HOST>
MYSQL_ADDON_DB=<DB>
MYSQL_ADDON_USER=<USER>
MYSQL_ADDON_PORT=<PORT>
MYSQL_ADDON_PASSWORD=<PASSWORD>
```

For information on how to access and set environment variables see `?Startup`.
