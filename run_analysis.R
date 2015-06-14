library(plyr) ## Used in step 3 (join) 

#############   Download and unzip data if not already done    ###############

if (!file.exists("./data")) { # Create a data folder if needed
        dir.create("./data") 
} 

url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip?accessType=DOWNLOAD"

destfile = file.path( "./data" , "UCI HAR dataset.zip" )

if (!file.exists(destfile)) { # Download zipped file if it is not already done
        download.file( url = url, 
                       destfile = destfile, 
                       mode = "wb") # Windows. Other OS may use method=curl
} 

datafolder <- file.path("./data" , "UCI HAR Dataset")

if (!file.exists(datafolder)) { # Unzip it if is not already done
        unzip(destfile, exdir='./data')  
}


################      Read data into R objects      ##########################

## Activity labels
x_train        <- read.table(file.path(datafolder,"train", "X_train.txt"), header = FALSE, stringsAsFactors = FALSE)
y_train        <- read.table(file.path(datafolder,"train", "Y_train.txt"), header = FALSE, stringsAsFactors = FALSE, col.names = "ActivityID")

## Measurement data
x_test         <- read.table(file.path(datafolder,"test", "X_test.txt"), header = FALSE, stringsAsFactors = FALSE)
y_test         <- read.table(file.path(datafolder,"test", "Y_test.txt"), header = FALSE, stringsAsFactors = FALSE, col.names = "ActivityID")

## Subjects who performed the activity 
subject_train  <- read.table(file.path(datafolder,"train", "subject_train.txt"), header = FALSE, stringsAsFactors = FALSE, col.names = "SubjectID")
subject_test   <- read.table(file.path(datafolder,"test", "subject_test.txt"), header = FALSE, stringsAsFactors = FALSE, col.names = "SubjectID")

## Feature and activity names
featurelookup  <- read.table(file.path(datafolder,"features.txt"), header = FALSE, stringsAsFactors = FALSE, col.names = c("FeatureID", "FeatureName"))
activitylookup <- read.table(file.path(datafolder,"activity_labels.txt"), header = FALSE, stringsAsFactors = FALSE, col.names = c("ActivityID", "ActivityName"))


#############   Step 1 : Merge the training and the test sets   ###############

train <- cbind(y_train,subject_train,x_train) 
test  <- cbind(y_test,subject_test,x_test)
alldata <- rbind(train,test)


#############   Step 2 : Extract mean/std measurements only     ###############

selectedFeatures <- grep("mean\\(\\)|std\\(\\)", featurelookup$FeatureName, ignore.case=TRUE, value=TRUE) #Feature name chr vector
selectedMeasurements <- alldata[,c(c(1:2), grep("mean\\(\\)|std\\(\\)",featurelookup$FeatureName, ignore.case=TRUE) + 2)] 


#############   Step 3 : Add descriptive activity names     ###################

#require(plyr)
selected <- join(selectedMeasurements, activitylookup) # Adds ActivityName (as last column)
selected <- selected[,c(2,ncol(selected),3:(ncol(selected)-1))] # Replace ActivityID with ActivityName


#############   Step 4 : Add descriptive variable names     ###################

names(selected) <- c("SubjectID", "ActivityName", selectedFeatures)


###  Step 5 : Tidy outdata: Avg. per variable for each activity and subject  ###

tidied <- aggregate(selected[, 3:length(selected)], 
                    list(SubjectID=selected$SubjectID, ActivityName=selected$ActivityName),
                    mean)

write.table(tidied, file = "tidy.txt", sep = "\t", row.names = FALSE) 

