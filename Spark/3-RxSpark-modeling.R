rxHadoopListFiles("/user/RevoShare/")
data_path <- "/user/RevoShare/batman"

write.df(sample_taxi, 
         file.path(data_path, "sampleTaxi"), 
         "com.databricks.spark.csv", 
         "overwrite", 
         header = "true")

sparkR.stop()

rxHadoopListFiles(file.path(data_path, "sampleTaxi"))
file_to_delete <- file.path(data_path, 
                            "sampleTaxi", "_SUCCESS")
delete_command <- paste("fs -rm", file_to_delete)
rxHadoopCommand(delete_command)


myNameNode <- "default"
myPort <- 0
hdfsFS <- RxHdfsFileSystem(hostName = myNameNode, 
                           port = myPort)

taxi_text <- RxTextData(file.path(data_path,
                                  "sampleTaxi"),
                        fileSystem = hdfsFS)

taxi_xdf <- RxXdfData(file.path(data_path, "taxiXdf"),
                      fileSystem = hdfsFS)


rxImport(inData = taxi_text, taxi_xdf, overwrite = TRUE)
rxGetInfo(taxi_xdf)

# create RxSpark compute context
computeContext <- RxSpark(consoleOutput=TRUE,
                          nameNode=myNameNode,
                          port=myPort,
                          executorCores=6, 
                          executorMem = "3g", 
                          executorOverheadMem = "3g", 
                          persistentRun = TRUE, 
                          extraSparkConfig = "--conf spark.speculation=true")

rxSetComputeContext(computeContext)

taxi_Fxdf <- RxXdfData(file.path(data_path, "taxiXdfFactors"),
                       fileSystem = hdfsFS)


rxFactors(inData = taxi_xdf, outFile = taxi_Fxdf, 
          factorInfo = c("pickup_hour", "pickup_nhood")
)

system.time(linmod <- rxLinMod(tip_pct ~ trip_distance, 
                               data = taxi_xdf, blocksPerRead = 2))