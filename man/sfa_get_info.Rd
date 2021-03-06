% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sfa_get_info.R
\name{sfa_get_info}
\alias{sfa_get_info}
\title{Get basic company information}
\usage{
sfa_get_info(
  ticker = NULL,
  simfin_id = NULL,
  api_key = getOption("sfa_api_key"),
  cache_dir = getOption("sfa_cache_dir")
)
}
\arguments{
\item{ticker}{\link{integer} Ticker of the companies of interest.}

\item{simfin_id}{\link{integer} 'SimFin' IDs of the companies of interest. Any
\code{simfin_id} will be internally translated to the respective \code{ticker}. This
reduces the number of queries in case you query the same company via
\code{ticker} \emph{and} \code{simfin_id}.}

\item{api_key}{\link{character} Your 'SimFin' API key. It's recommended to set
the API key globally using \link{sfa_set_api_key}.}

\item{cache_dir}{\link{character} Your cache directory. It's recommended to set
the cache directory globally using \link{sfa_set_cache_dir}.}
}
\description{
Get basic company information
}
