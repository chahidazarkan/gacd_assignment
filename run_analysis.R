
#load the appropriate libraries
library(dplyr)
library(plyr)
library(tidyr)
library(stringr)

## read the train dataset
train <- read.table(file="data/train/X_train.txt")

## read the test dataset
test <- read.table(file="data/test/X_test.txt")

## read the train subject_id
subject_train <- read.table(file="data/train/subject_train.txt")

## read the test subject_id
subject_test <- read.table(file="data/test/subject_test.txt")

## read the activity_label for the train dataset
activity_number_train <- read.table(file="data/train/Y_train.txt")

## read the activity_label for the train dataset
activity_number_test <- read.table(file="data/test/Y_test.txt")

## read the variable names
variablenames <- read.table(file="data/features.txt")

## read the acitivty lables
activity_label <- read.table(file="data/activity_labels.txt")


#transform the dataframes in table data frames using the dplyr package
train <- tbl_df(train)
test <- tbl_df(test)
subject_train <- tbl_df(subject_train)
subject_test <- tbl_df(subject_test)
activity_number_train <- tbl_df(activity_number_train)
activity_number_test <- tbl_df(activity_number_test)
variablenames <- tbl_df(variablenames)
activity_label <- tbl_df(activity_label)

#change the names of the columns in the different datasets
names(train) <- variablenames$V2
names(test) <- variablenames$V2

names(subject_train) <- c("subject_id")
names(subject_test) <- c("subject_id")

names(activity_number_train) <- c("activity_number")
names(activity_number_test) <- c("activity_number")

names(activity_label) <- c("activity_number", "activity_label")

#change the activity labels in lowercase
activity_label$activity_label <- c("Walking", "Walking upstairs", "Walking downstairs", "Sitting", "Standing", "Laying")

#find columns with mean or std (standard deviation) in name
train_mean_std <- train[ , grepl("mean\\()", names( train )) | grepl("std", names( train ))]
test_mean_std <- test[ , grepl("mean\\()", names( test )) | grepl("std", names( test ))]

#add subject ID and activity number to the train and test dataframe
train_mean_std <- cbind(subject_train, activity_number_train, train_mean_std)
test_mean_std <- cbind(subject_test, activity_number_test, test_mean_std)

#Add the acitvity labels
train_mean_std <- merge(activity_label, train_mean_std, by.x="activity_number")
test_mean_std <- merge(activity_label, test_mean_std, by.x="activity_number")

#transform the dataframes in table data frames using the dplyr package
train_mean_std <- tbl_df(train_mean_std)
test_mean_std <- tbl_df(test_mean_std)

#put the activity number as a last column
train_mean_std <- select(train_mean_std, -activity_number, everything())
test_mean_std <- select(test_mean_std, -activity_number, everything())

#reorder the columns
train_mean_std <- select(train_mean_std, subject_id, everything())
test_mean_std <- select(test_mean_std, subject_id, everything())

#merge training and test data set
merged_data <- rbind(train_mean_std, test_mean_std)

#arrange the merged dataset on subject_id
merged_data <- arrange(merged_data, subject_id)

#remove the special characters from the colnames
names(merged_data) <- str_replace_all(names(merged_data), "[[:punct:]]","") 

#makes a csv file of the dataframe merged_data
write.csv(merged_data, file="merged_dataset.csv")

#calculate the mean per variable, per subject, per activitylabel
mean_variable_subject_activity <- ddply(merged_data, .(subjectid, activitylabel), .fun=colwise(mean))

#drop the activity number
mean_variable_subject_activity <- mean_variable_subject_activity[,1:68]

#makes a csv file of the dataframe mean_variable_subject_activity
write.csv(mean_variable_subject_activity, file="mean_variable_subject_activity.csv")

#clear the workspace, if you want to work with the data in R delete the code below
rm(list = ls())