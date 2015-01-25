#
#  Activities - a R RC class to generate a filtered set of averages on the datasets from 
#  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#
#  To run this code and get the resulting tidy dataset, download the above data and decompress it, and run the following:
#
#  source("run_analysis.R")
#  theData <- Activities$new( newPath="pathtoyourextracteddata" )
#  theData$extractMeasurements()
#  theData$getTidyResults()
#
#  A description of the data can be found at http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
#
#  See the LICENSE file for full license text
#
#
Activities <- setRefClass( "Activities", 
                fields = list( 
                  subjectColumns="numeric",
                  filePath="character",
                  testPath="character",
                  trainPath="character",
                  signalsPath="character",
                  columnNames="character",
                  activitiesFrame="data.frame",
                  subjectsFrame="data.frame",
                  subjectIDFrame="data.frame",
                  columnIDFrame="data.frame",
                  FilteredFrame="data.frame",
                  AvgFrame="data.frame"
                ),
                
                methods = list( 
                  initialize = function( newPath, ... ) 
                  {
                    subjectColumns <<- 561
                    filePath <<- newPath
                    testPath <<- "test"
                    trainPath <<- "train"
                    signalsPath <<- "Inertial Signals"
                    columnNames <<- "mean\\(\\)|std\\(\\)"
                    activitiesFrame <<- data.frame()
                    subjectsFrame <<- data.frame()
                    subjectIDFrame <<- data.frame()
                    columnIDFrame <<- data.frame()
                    FilteredFrame <<- data.frame()
                    AvgFrame <<- data.frame()
                  },               
                  
                  #
                  #  Load subject measurement data and store in a frame.  scan is used as the delimeter spacing 
                  #  is irregular and NAs from extra spaces are stripped to give a properly sized vector
                  #  
                  #  Convert to a frame with subject measurements as rows
                  #            
                  loadSubjects = function()
                  {
                    subjectsTest   <- scan( file.path( filePath, testPath, "X_test.txt" ), sep = " ", quiet = TRUE )
                    subjectsTest   <- subjectsTest[ ! is.na( subjectsTest ) ]
                    subjectsTrain  <- scan( file.path( filePath, trainPath, "X_train.txt" ), sep = " ", quiet = TRUE )
                    subjectsTrain  <- subjectsTrain[ ! is.na( subjectsTrain ) ]
                    subjectsCombined <- c( subjectsTest, subjectsTrain )
                    dim( subjectsCombined ) <- c( length( subjectsCombined ) / subjectColumns, subjectColumns )
                    subjectsFrame  <<- data.frame( subjectsCombined )
                  },
                  
                  loadSubjectIDs = function()
                  {
                    subjectsTest    <- read.table( file.path( filePath, testPath, "subject_test.txt" ), sep = " " , header = F )
                    subjectsTrain   <- read.table( file.path( filePath, trainPath, "subject_train.txt" ), sep = " " , header = F )
                    subjectIDFrame <<- rbind( subjectsTest, subjectsTrain )
                    colnames( subjectIDFrame ) <<- c( "SubjectID")
                  },
                  
                  loadColumnIDs = function()
                  {
                    columnIDFrame <<- read.table( file.path( filePath, "features.txt" ), sep = " " )
                  },
                  
                  #
                  #  Load activities data and join labels with row data
                  #  
                  #  Store a frame with activity descriptions as rows
                  #
                  loadActivities = function()
                  {
                    activitiesTest   <- read.table( file.path( filePath, testPath, "y_test.txt" ), sep = " " , header = F )
                    activitiesTrain  <- read.table( file.path( filePath, trainPath, "y_train.txt" ), sep = " " , header = F )
                    activitiesLabels <- read.table( file.path( filePath, "activity_labels.txt" ), sep = " " , header = F )
                    activitiesFrame <<- rbind( activitiesTest, activitiesTrain )
 
                    activitiesFrame[ ,1 ] <<- activitiesLabels[ activitiesFrame[ ,1 ], 2]
                  },
                  
                  #
                  #  Get the subset of columns of interest from overall data frame
                  #
                  #  Use grep to generate a vector of columns names, then extract columns into new frame
                  #
                  extractMeasurements = function()
                  {
                    library(plyr)
                    
                    loadColumnIDs()
                    loadSubjects()
                    
                    colnames( subjectsFrame ) <<- gsub("\\(\\)","", as.vector( columnIDFrame[[ 2 ]] ) ) # Remove parenthesis from strings
                    interestingColumns <- grep( columnNames, as.vector( columnIDFrame[[ 2 ]] ))
                    
                    loadActivities()
                    loadSubjectIDs()
                    
                    FilteredFrame <<- data.frame( "Activity" = activitiesFrame[ , 1 ], "Subject" = subjectIDFrame, subjectsFrame[ , interestingColumns ] )
                    AvgFrame <<- ddply(FilteredFrame, .(SubjectID, Activity), function(x) colMeans(x[, 3:68]))
                    colnames( AvgFrame )[1:2] <<- c( "Subject", "Activity" )                   
                  },
                  
                  getTidyResults = function( outputfile = "" )
                  {
                    write.table(theData$AvgFrame, outputfile, row.name=F)
                  }
                )
      )
