# load required libraries
library(caret)
library(corrplot)
library(plyr)

# load required dataset
dat <- read.csv("OnlineNewsPopularity.csv")

# Set seed
set.seed(227)

# Remove variables having high missing percentage (50%)
dat1 <- dat[, colMeans(is.na(dat)) <= .5]
dim(dat1)

# Remove Zero and Near Zero-Variance Predictors
nzv <- nearZeroVar(dat1)
dat2 <- dat1[, -nzv]
dim(dat2)

# Identifying numeric variables
numericData <- dat2[sapply(dat2, is.numeric)]

# Calculate correlation matrix
descrCor <- cor(numericData)

# Print correlation matrix and look at max correlation
print(descrCor)
summary(descrCor[upper.tri(descrCor)])

# find attributes that are highly corrected
highlyCorrelated <- findCorrelation(descrCor, cutoff=0.7)

# print indexes of highly correlated attributes
print(highlyCorrelated)

# Indentifying Variable Names of Highly Correlated Variables
highlyCorCol <- colnames(numericData)[highlyCorrelated]

# Print highly correlated attributes
highlyCorCol

# Remove highly correlated variables and create a new dataset
dat3 <- dat2[, -which(colnames(dat2) %in% highlyCorCol)]
dat3

#classifiying if popular or not using threshold = 3rd quantile
q<-quantile(dat3$shares,0.75)
popular = ifelse(dat3$shares<=q, 0, 1)
dat3 = data.frame(dat3, popular)

#removing non numerical data "url"
dat3<- dat3[,-1]
dat3$popular<-factor(dat3$popular)

#spliting data into train and test
n_random<-round(0.7*nrow(dat3))
index<-sample(1:nrow(dat3),n_random)
train<-dat3[index,]
test<-dat3[-index,]

#training the model
log_model<-glm (popular ~.-shares, data = train, family = binomial)

#summary of the model
summary(log_model)

#prediction on test dataset
pred <-predict(log_model, test,type = 'response')
pred <- ifelse(pred > 0.5,1,0)

#creating confusion matrix
confusion_matrix<-table(pred, test$popular)
print(confusion_matrix)

#calculating miss classification rate
miss_class<-1-(sum(diag(confusion_matrix))/sum(confusion_matrix))
print(miss_class)

