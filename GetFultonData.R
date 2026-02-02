# 

if(!require('ForwardSearch')) {
  install.packages('ForwardSearch')
  library('ForwardSearch')
}

install.packages(
  "https://cran.r-project.org/src/contrib/Archive/ForwardSearch/ForwardSearch_1.0.tar.gz",
  repos = NULL,
  type = "source"
)

library(ForwardSearch)
data("Fulton", package = "ForwardSearch")

to_stata <- function(df, file) {
  haven::write_dta(df, path = file)
}

to_stata(Fulton, "/home/mahdi/Dropbox/Courses/are256b-w26/data/Fulton.dta")


head(Fulton)

# End of Script