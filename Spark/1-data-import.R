download.file("https://alizaidi.blob.core.windows.net/training/manhattan.RData", "manhattan.RData")
download.file("https://alizaidi.blob.core.windows.net/training/sample_taxi.csv", "sample_taxi.csv")
wasb_taxi <- "/NYCTaxi/sample"
rxHadoopListFiles("/")
rxHadoopMakeDir(wasb_taxi)
rxHadoopCopyFromLocal("sample_taxi.csv", wasb_taxi)
rxHadoopCommand("fs -cat /NYCTaxi/sample/sample_taxi.csv | head")

library(SparkR)

# create sql context to create Spark DataFrames
sparkEnvir <- list(spark.executor.instance = '10',
                   spark.yarn.executor.memoryOverhead = '8000')

sc <- sparkR.init(
  sparkEnvir = sparkEnvir,
  sparkPackages = "com.databricks:spark-csv_2.10:1.3.0"
)

sqlContext <- sparkRHive.init(sc)

dataframe_import <- function(path) {
  
  library(SparkR)
  path <- file.path(path)
  path_df <- read.df(sqlContext, path,
                     source = "com.databricks.spark.csv",
                     header = "true", inferSchema = "true", delimiter = ",")
  
  return(path_df)
  
}

sample_taxi <- dataframe_import("/NYCTaxi/sample/sample_taxi.csv")
