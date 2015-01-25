
#  Getting and Cleaning Data Project Repo

The run_analysis.R file contains an Activities to generate a filtered set of averages on the datasets from 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

To run this code and get the resulting tidy dataset, download the above data and decompress it, 
and perform the following:

```
source("run_analysis.R")
theData <- Activities$new( newPath="pathtoyourextracteddata" )
theData$extractMeasurements()
```
If a fileName (optional) is provided to getTidyResults, it will save the data to the provided file.  
The code assumes the complete path to the file already exists.

If no fileName is passed, output is written to the console.
```
theData$getTidyResults( fileName="myfile.txt" )
```
