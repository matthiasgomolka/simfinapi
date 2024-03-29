% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sfa_set_api_key.R
\name{sfa_set_api_key}
\alias{sfa_set_api_key}
\title{Set your 'SimFin' API key globally}
\usage{
sfa_set_api_key(api_key, env_var)
}
\arguments{
\item{api_key}{\link{character} You API key. Ignored if you specify \code{env_var} as
well.}

\item{env_var}{\link{character} Name of an environment variable holding you API
key, e.g. \code{SIMFIN_API_KEY}. Leave empty (\code{NULL}, default) if you want to
set your API key directly.}
}
\value{
\link{character} The API key (invisibly).
}
\description{
It is highly recommended to set the API key globally as it makes
specifying the \code{api_key} argument of other \verb{sfa_*} functions obsolete.

There are two ways to set your API key globally:
\enumerate{
\item Provide the API key directly as a string (\code{api_key = 'YourApiKey'}).
\item Create a system-wide environment variable containing you API key and
refer to that (\code{env_var = 'YourEnvVar'}). How to create a system-wide
environment variable depends on your operating system.
}

The second option is recommended because your R scripts won't contain your
API key and it is safe to keep your scripts in an open repository like
GitHub.
}
\examples{
\dontrun{
# set API key directly
sfa_set_api_key(api_key = 'YourApiKey')

# set API key via environment variable
# (this assumes you already created an environment variable called
# 'SIMFIN_API_KEY' which contains you API key)
sfa_set_api_key(env_var = 'SIMFIN_API_KEY')
}
}
