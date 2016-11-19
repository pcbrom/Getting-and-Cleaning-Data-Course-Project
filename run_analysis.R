# You should create one R script called run_analysis.R that does the following. 

# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names. 

# From the data set in step 4, creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject.

# Good luck!

# Please upload the tidy data set created in step 5 of the instructions. 
# Please upload your data set as a txt file created with write.table() 
# using row.name=FALSE (do not cut and paste a dataset directly into the 
# text box, as this may cause errors saving your submission).

setwd("~/Dropbox/Trabalho e Estudo/Cursos Livres/Getting and Cleaning Data/Project")

loc.features = "/home/pcbrom/Dropbox/Trabalho e Estudo/Cursos Livres/Getting and Cleaning Data/Project/UCI HAR Dataset/features.txt"
data = read.table(loc.features, sep="", stringsAsFactors = F)

loc.test = list.files("/home/pcbrom/Dropbox/Trabalho e Estudo/Cursos Livres/Getting and Cleaning Data/Project/UCI HAR Dataset/test")
loc.train = list.files("/home/pcbrom/Dropbox/Trabalho e Estudo/Cursos Livres/Getting and Cleaning Data/Project/UCI HAR Dataset/train")

loc.test = loc.test[grep("*.txt", loc.test)]
loc.train = loc.train[grep("*.txt", loc.train)]

for(i in 1:3) { 
  nam = paste("data.test", i, sep = "")
  file.dt = paste("/home/pcbrom/Dropbox/Trabalho e Estudo/Cursos Livres/Getting and Cleaning Data/Project/UCI HAR Dataset/test",
                  loc.test[i], sep = "/", collapse = "")
  assign(nam, read.table(file.dt))
}

for(i in 1:3) { 
  nam = paste("data.train", i, sep = "")
  file.dt = paste("/home/pcbrom/Dropbox/Trabalho e Estudo/Cursos Livres/Getting and Cleaning Data/Project/UCI HAR Dataset/train",
                  loc.train[i], sep = "/", collapse = "")
  assign(nam, read.table(file.dt))
}

test = cbind(data.test1, data.test3, data.test2)
train = cbind(data.train1, data.train3, data.train2)

# adjust names
names(test) = c("subject", "activity", paste0(rep("V",(dim(test)[[2]] - 2)), seq(1:(dim(test)[[2]] - 2))))
names(train) = c("subject", "activity", paste0(rep("V",(dim(train)[[2]] - 2)), seq(1:(dim(train)[[2]] - 2))))
test$activity = as.factor(test$activity)
train$activity = as.factor(train$activity)

# adjust levels to correct activity name
activity_labels = read.table("UCI HAR Dataset/activity_labels.txt", sep = " ")
levels(test$activity) = activity_labels$V2
levels(train$activity) = activity_labels$V2

# save test and train files
write.csv(test, "test.csv", row.names = F)
write.csv(train, "train.csv", row.names = F)

# concatenate all data
library(plyr)
db = rbind(train, test)
db = arrange(data, subject)

# get features names
features = read.table("UCI HAR Dataset/features.txt")
data.index = grep("-mean\\(\\)|-std\\(\\)", features[, 2])

v.names = features$V2[data.index]
db2 = subset(db, select = -c(subject, activity))
dbnew = db2[, data.index] 
names(dbnew) = v.names
dbnew = cbind.data.frame(db[,c(1,2)], dbnew)

db.mean = aggregate(. ~ activity + subject, mean, data = dbnew)

write.csv(db.mean, "tidy_average_data.txt", row.names = F)
