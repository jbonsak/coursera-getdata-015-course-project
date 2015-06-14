#ReadMe 

This is a walk-through of how my version of run_analysis.R is constructed. The conceptual thinking behind the data processing and the resulting dataset is described in the Codebook.

This run_analysis.R first creates a directory "data" as a subdirectory to the present R work directory. The step is skipped if such a directory exists. I am on R version 3.1.3 "Smooth Sidewalk", and I guess others are too, so I haven't used the new dir.exists here.

```R
#############   Download and unzip data if not already done    ###############

if (!file.exists("./data")) { # Create a data folder if needed
        dir.create("./data") 
} 
```

Then the UCI HAR zipped dataset is downloaded if it is not present in the data directory already, and unzipped if not already done.

```R
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

```

The third and last preparing step is reading the training and test data sets plus the subjectID's, feature names and activity names into R objects.

```R
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
```

## Step 1: Merge the train and test data sets
Train and test data are equally formatted (they were one data set originally, then randomly split 30/70), so after joining them separately to their subject and activity lookups, they can be stacked on top of each other again (append, here done by rbind).

```R
train <- cbind(y_train,subject_train,x_train) 
test  <- cbind(y_test,subject_test,x_test)
alldata <- rbind(train,test)
```

## Step 2: Extract only mean and standard deviation data
My selection criteria for the mean and standard deviation data is discussed in the Codebook. The backslashes before the parenthesis escapes them so that grep can match them without problem.
```R
selectedFeatures <- grep("mean\\(\\)|std\\(\\)", featurelookup$FeatureName, ignore.case=TRUE, value=TRUE) #Feature name chr vector
selectedMeasurements <- alldata[,c(c(1:2), grep("mean\\(\\)|std\\(\\)",featurelookup$FeatureName, ignore.case=TRUE) + 2)] 
```

##   Step 3 : Add descriptive activity names
join() requires the plyr package. The second selected-assignment below is just a minor column reshuffle I found to be useful in later steps.
```R
require(plyr)
selected <- join(selectedMeasurements, activitylookup) # Adds ActivityName (as last column)
selected <- selected[,c(2,ncol(selected),3:(ncol(selected)-1))] # Replace ActivityID with ActivityName
```

##   Step 4 : Add descriptive variable names
All the column names for the selected features are here pulled from the data frame selectedFeatures created in step 2 above.
```R
names(selected) <- c("SubjectID", "ActivityName", selectedFeatures)
```

##  Step 5 : Produce tidy outdata with means per variable for each activity and subject  
This section writes a tab separated text file "tidy.txt" to the R work directory. See it in "tidy.txt" in this repository.
```R
tidied <- aggregate(selected[, 3:ncol(selected)], 
                    list(SubjectID=selected$SubjectID, ActivityName=selected$ActivityName),
                    mean)

write.table(tidied, file = "tidy.txt", sep = "\t", row.names = FALSE) 
