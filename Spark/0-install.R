r <- getOption('repos')
# set mirror to something a bit more recent
r["CRAN"] <- "https://mran.revolutionanalytics.com/snapshot/2016-06-20/"
options(repos = r)
install.packages('magrittr')
install.packages('ggplot2')


system("sudo apt-get -y build-dep libcurl4-gnutls-dev")
system("sudo apt-get -y install libcurl4-gnutls-dev")
install.packages('devtools')
devtools::install_github("akzaidi/SparkRext")
devtools::install_github('plotly/ropensci')

.libPaths(c(.libPaths(),
            file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))


