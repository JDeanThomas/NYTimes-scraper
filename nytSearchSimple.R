# Simple Long pipeline interative version. Returns no JSON at all, only tidy Data Frame with all results.

# NTY Search API documentation: http://developer.nytimes.com/docs/read/article_search_api_v2
# You can construct and test NYT API calls here: http://developer.nytimes.com/io-docs
# You can sign up for API keys here: http://developer.nytimes.com/docs/reference/keys


require(dplyr)
require(rjson)


# Determine length of pagination for full results of search query 
pageLength <- function (n=1) {
  initCall <- paste("http://api.nytimes.com/svc/search/v2/articlesearch.json?q=artist&fq=section_name%3A+Arts+AND+body%3A+band&begin_date=20100701&end_date=20150701&sort=newest&page=", n, "&api-key=305b6af4f2b615fa47c9b55d593ea8ac%3A18%3A61281329", sep = "")
  init <- fromJSON(file=initCall)
  pages <- ceiling(init$response$meta$hits / 10)
}

pages <- pageLength()

# Simple example to extract two calls and apend to data frame
# Search term "band" inccluding term "artsit" in arts section
# Date range 7/1/2010 - 7/1/2015
pages <- 1:2
apiCall <- paste("http://api.nytimes.com/svc/search/v2/articlesearch.json?q=artist&fq=section_name%3A+Arts+AND+body%3A+band&begin_date=20100701&end_date=20150701&sort=newest&page=", pages,"&api-key=305b6af4f2b615fa47c9b55d593ea8ac%3A18%3A61281329", sep = "")

# Simple NYT search api query fucntion
getDataTest <- function(apiCall) {
  df <- data.frame()
  for (i in seq_along(apiCall)) { 
    message("Retrieving page ", i)
    rdParsed <- list()
    rawData <- fromJSON(file=apiCall[i])
    rdParsed <- lapply(rawData$response$docs, function(x) {
      x[sapply(x, is.null)] <- NA
      unlist(x)})
    for (i in seq_along(rdParsed)) {
      dfContainer <- data.frame(do.call(unlist("rbind"), rdParsed[i]), stringsAsFactors = FALSE)
      df <- bind_rows(df, dfContainer)
    }
  }
  return(df)
}    

df <- getDataTest(apiCall)

    
