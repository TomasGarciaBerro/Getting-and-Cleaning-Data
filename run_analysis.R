#First set your working directory and then run the script.

#Download needed files
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile='HAR.zip',mode="wb")
unzip(zipfile = "HAR.zip")

project_path <- file.path(getwd(),"/UCI HAR Dataset")

#Load and Merge all test data sets
subject_test <- fread(file.path(project_path,"test/subject_test.txt"))
y_test <- fread(file.path(project_path,"test/y_test.txt"))
X_test <- fread(file.path(project_path,"test/X_test.txt"))

dt_test <- cbind(subject_test,y_test,X_test)

#Load and Merge all training data sets
subject_train <- fread(file.path(project_path,"train/subject_train.txt"))
y_train <- fread(file.path(project_path,"train/y_train.txt"))
X_train <- fread(file.path(project_path,"train/X_train.txt"))

dt_train <- cbind(subject_train,y_train,X_train)

#Merge complete test and complete train
dt <- rbind(dt_test,dt_train)

#Load features
dt_features <- fread(file.path(project_path, "features.txt"))
setnames(dt_features, c("V1", "V2"), c("measureNumber", "measureName"))

#Leave only mean and std measurements
#TRUE TRUE for the first and second column (subject and activity)
select_columns <- c(TRUE,TRUE)
l_needed_measures <- grepl("(mean|std)\\(\\)", dt_features$measureName)
select_columns <- c(select_columns,l_needed_measures)

dt_filtered <- dt[,select_columns,with = FALSE]

#Put nice names to the columns of the new data table
column_names <- c("subject","activityNumber")
names_needed_measures <- grep("(mean|std)\\(\\)", dt_features$measureName, value = TRUE)
column_names <- c(column_names,names_needed_measures)

names(dt_filtered) <- column_names

#Change activityNumber to activityName
dt_activities <- fread(file.path(project_path, "activity_labels.txt"))
setnames(dt_activities, c("V1", "V2"), c("activityNumber", "activityName"))

dt_filtered <- merge(dt_filtered,dt_activities, by = "activityNumber")

#Eliminate activityNumber
dt_filtered <- dt_filtered[,names(dt_filtered) != "activityNumber",with = F]

#Rearange column order
dt_filtered <- dt_filtered[,c("subject","activityName",names_needed_measures), with = F]

#Melt data set
dt_melted <- melt(dt_filtered,id = c("subject","activityName"),measure.vars = names_needed_measures)

#Cast data set
dt_tidy <- dcast(dt_melted,subject + activityName ~ variable, mean)

# Write the tidy data set into a tab delimited file
write.table(dt_tidy, file="tidydata.txt", row.name=FALSE, sep = "\t")
