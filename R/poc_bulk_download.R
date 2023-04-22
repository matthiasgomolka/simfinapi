library(httr2)
library(arrow)
library(data.table)

#https://backend.simfin.com/api/bulk-download?

# create request
req <- request("https://backend.simfin.com/api") |>
  req_url_path_append("bulk-download") |>
  req_headers(Authorization = paste("api-key", Sys.getenv("SFPLUS_API_KEY"))) |>
  req_url_query(dataset = "companies", market = "us") |>
  req_user_agent("simfinapi (https://github.com/matthiasgomolka/simfinapi)")

# get request
resp <- req |> req_perform()

# store result from request in zip file
tf <- tempfile("simfin_data_", fileext = ".zip")
dest <- file(tf, open = "wb", raw = TRUE)
resp |>
  resp_body_raw() |>
  writeBin(con = dest)
close(dest)

# extract and read zip file
unzip(tf, exdir = dirname(tf))
files <- unzip(tf, list = TRUE)[["Name"]]

read_delim_arrow(file.path(dirname(tf), files), delim = ";")


