############################################################
#  Downloading data
############################################################
if(!file.exists("./data")){dir.create("./data")}
dataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataUrl, "./data/dataset.zip")
unzip("./data/dataset.zip", exdir = "./data/AssignData")



############################################################
# Step 1:
# Merges the training & test sets to create one data set:
############################################################

### Reading in training $ test sets:
train <- read.table("./data/AssignData/dataset/train/X_train.txt",
                    header = FALSE, sep = "")
test <- read.table("./data/AssignData/dataset/test/X_test.txt",
                   header = FALSE, sep = "")
### Combining them by columns:
data <- rbind(train, test)



##############################################################
# Step 2:
# Extracts only the measurements on the mean and standard deviation 
# for each measurement.
##############################################################

### Reading in the features:
library(dplyr)
features  <- read.table("./data/AssignData/dataset/features.txt", 
                        header = FALSE,sep = "") %>% select(2) 
### Getting the index where features contains just "mean" or "std":
s <- grep("(mean|std)[^meanFreq]", features$V2)
### Extracting from data 
### all values for mean OR standard deviation:
subset <- data.frame(data[,s])



############################################################
# Step 3:
# Uses descriptive activity names to name the activities
# in the data set.
############################################################

### Adding labels as the last column of  the subset:
train_labels <- read.table("./data/AssignData/dataset/train/y_train.txt", 
                           header = FALSE, sep = "")
test_labels <- read.table("./data/AssignData/dataset/test/y_test.txt", 
                          header = FALSE, sep = "")
subset$labels <- unlist(rbind(train_labels, test_labels))

### Loading in the contrasting relationship between 1:6 and 
### those 6 activities as a table:
activity <- read.table("./data/AssignData/dataset/activity_labels.txt", 
                       header = FALSE, sep = "")
### Turning the integers into corresponding activities
### in the labels column of subset:
subset[,"labels"] <- activity[,2][subset$labels]



##############################################################
# Step 4:
# Labels the data set with descriptive variable names:
##############################################################

### Extracting related features according to the split:
f <- features[s,]
### Passing f as the first 1:66 column names for subset
### and renaming "labels" as "Activity":
colnames(subset) <- c(f, "Activity")
View(subset)



#############################################################
# Step 5:
# From the data set in step 4, creates a second, independent
# tidy data set with the average of each variable 
# for each activity and each subject.
##############################################################


### Copy the data set from Step4:
newset <- subset
### Adding the Subject index to the last column of newset:
train_subject <- read.table("./data/AssignData/dataset/train/subject_train.txt",
                            header = FALSE, sep = "")
test_subject <- read.table("./data/AssignData/dataset/test/subject_test.txt",
                           header = FALSE, sep = "")
newset$Subject <- unlist(rbind(train_subject, test_subject))

### Summarizing by Activity and Subject:
newset <- aggregate(. ~ Activity + Subject, data = newset, mean)
View(newset)
write.table(newset, "newset.txt", row.name=FALSE)

