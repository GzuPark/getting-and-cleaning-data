# file : run_analysis.R
# note : Getting and Cleanig Data Course Project
# date : 2016-03-13
# auth : Jongmin Park

# This code is able to run after downloading UCI HAR Dataset from
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# more detail..
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# clean environment
rm(list=ls())
# set working directory to the location UCI HAR Dataset saved
# I didn't show my paths exactly because of privacy
setwd('~/Getting and Cleaning Data/UCI HAR Dataset/')

# 1. Merges the training and the test sets to create one data set.
# read and store the data from files
features <- read.table('features.txt')
activity <- read.table('activity_labels.txt')
subjectTrain <- read.table('./train/subject_train.txt')
XTrain <- read.table('./train/X_train.txt')
YTrain <- read.table('./train/y_train.txt')
subjectTest <- read.table('./test/subject_test.txt')
XTest <- read.table('./test/X_test.txt')
YTest <- read.table('./test/y_test.txt')

# reannounce column names 
colnames(features) <- c('featID', 'features')
colnames(activity) <- c('actID', 'actType')
colnames(subjectTrain) <- colnames(subjectTest) <- 'subID'
colnames(XTrain) <- colnames(XTest) <- features$features
colnames(YTrain) <- colnames(YTest) <- 'actID'

# create training and test set
train <- cbind(YTrain, subjectTrain, XTrain)
test <- cbind(YTest, subjectTest, XTest)
# combine training and test set
data <- rbind(train, test)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# extract specific column names which the conditions required
extractColumn <- colnames(data)[grepl('-std', colnames(data))
                                | grepl('-mean', colnames(data)) 
                                & !grepl('-meanFreq', colnames(data))
                                | grepl('act', colnames(data)) 
                                | grepl('sub', colnames(data))]
# subset the data based on the extract condition
data <- data[, extractColumn]

# 3. Uses descriptive activity names to name the activities in the data set
# merge the data with acitivity table which had descriptive activity names
data <- merge(data, activity, by='actID')

# 4. Appropriately labels the data set with descriptive variable names.
# clear the variable names
colnames(data) <- gsub('\\()', '', colnames(data))
colnames(data) <- gsub('^t', 'time-', colnames(data))
colnames(data) <- gsub('^f', 'freq-', colnames(data))
colnames(data) <- gsub('Mag', 'Magnitue', colnames(data))

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# substract the activity type column for aggregating
tidyData <- data[,colnames(data) != 'actType']

# aggregate the tidy data to average by activity ID and subject ID
tidyData <- aggregate(tidyData[, colnames(tidyData) != c('actID', 'subID')],
                      by = list(actID=tidyData$actID, subID=tidyData$subID),
                      mean)
# merge again with activity table
tidyData <- merge(tidyData, activity, by='actID')
