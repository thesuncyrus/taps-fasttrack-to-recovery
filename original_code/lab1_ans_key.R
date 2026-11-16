################################################################################
# Lab #1 answer key
#
################################################################################
# Q1 - discuss what data for good means to you
# Q2 - register for data 4 good competition
# Q3 - create a kaggle account and merge your team using the invited link

# Q4 - The cross-industry standard process for data mining (CRISP-DM), is an 
# iterative open standard process model used by data mining and analytics 
# practitioners. It is the most widely-used analytics model.

#1.	Business understanding
# a.	Understand the business problem.
# b.	Create data mining goals that are realistic and specific. 
# c.	To increase chance of achieving business objectives, a detailed project 
#     plan must be made

#2.	Data understanding
# a.	Data Collection (or understand how it was collected), visualizations, 
#     EDA, and identify potential data needs
# b.	Get a feel for how truth worthy, timely, and accurate the data is.

#3.	Data preparation
# a.	Data Cleaning, missing values imputation, outlier detection, standardization.

#4.	Modeling
# a.	Select appropriate techniques that support the data mining goals to try 
#     and train model(s) to the prepared dataset

#5.	Evaluation
# a.	In this phase, the model results must be compared with business 
#     requirements - new requirements can be raised from model results or other 
#     factors.
# b.	Gaining business understanding is an iterative process in data mining. 
#     Evaluate the result both statistically and potential business impacts.

#6.	Deployment
# a.	utilize what we have learned from the previous phases and review the 
#     results/model(s) for continuous improvements. Can you automate any future 
#     iterations of the process? 
# b.	Information presented to stakeholders. Obtain feedback.
# c.	Documentation for supporting solution. Benchmark for future iterations.

# Q5
#a.	Deciding whether to issue a loan to an applicant based on demographic and 
# financial data (with reference to a database of similar data on prior customers).
# This is supervised learning because the database includes information on 
# whether the loan as approved or not. Since the response is binary (approved, 
#not approved) we would frame this as a classification problem.

#b.	In an online bookstore, making recommendations to customers concerning 
# additional items to buy based on the buying patterns in prior transactions.
#This is unsupervised learning because there is no apparent outcome (e.g. 
#whether the recommendation was adopted or not). 

#c.	Identifying segments of similar customers.
#This is unsupervised learning because there is no known outcome (though once 
#you use unsupervised learning to identify segments, you could use supervised 
#learning to classify new customers into those segments). 

#d.	Estimating the repair time required for an aircraft based on a trouble ticket.
#This is supervised learning because there is likely to be knowledge of actual 
#(historic) repair times of similar repairs. Since the response is numeric, we 
#would frame this as a regression problem.

#e.	Automated sorting of mail by zip code scanning.
#This could be a considered a supervised learning problem because there is 
#likely to be knowledge about whether the sorting was correct or not in the 
#previous mail sorting. Since the response is binary (correct, incorrect) we 
#would frame this as a classification problem.

# Q6
#b)	Read in the "window_breakage_data.xlsx" data 
getwd()
setwd("C:\\Users\\lanhamm\\Dropbox\\_Purdue\\_Teaching\\Data Mining & Predictive Analytics\\_Assignments & Exams\\Fall 2024")
library(readxl)
d <- read_xlsx("window_breakage_data.xlsx", sheet="window_breakage_data", col_names=T)
d <- as.data.frame(d)
str(d)

#c)	Identify where and how many records are missing for each variable.
# I copied and tweaked code from the 'Ex_Preprocessing.R' script
sapply(d, function(x) sum(is.na(x)))

#d)	Create a 3x3 window of 8 histograms using par(mfrow=) that we discussed 
#in class for the following the numeric features: window size, glass thickness
#, window color, ambient temp, cut speed, edge deletion rate, spacer distance
#, silicon visocity.
# I copied and tweaked code from the 'Ex_Preprocessing.R' script

# I first change the column names to remove any spaces and odd characters. Doing
# this will make your downstream code easier so you don't have to put the names
# in quotes
names(d) <- c("Batch", "BreakageRate", "YldFrctn", "PassFail", "WindowSize"             
              ,"GlassThickness", "AmbientTemp", "CutSpeed","EdgeDeletionRate"
              ,"SpacerDistance", "WindowColor", "WindowType", "GlassSupplier"
              ,"SiliconViscosity", "GlassSupplierLocation")
names(d)
par(mfcol=c(3,3))
hist(d$WindowSize, col="blue", main="Window Size")
hist(d$GlassThickness, col="blue", main="Glass Thickness")
hist(d$WindowColor, col="blue", main="Window Color")
hist(d$AmbientTemp, col="blue", main="Ambient Temp")
hist(d$CutSpeed, col="blue", main="Cut Speed")
hist(d$EdgeDeletionRate, col="blue", main="Edge Deletion Rate")
hist(d$SpacerDistance, col="blue", main="Spacer Distance")
hist(d$SiliconViscosity, col="blue", main="Silicon Viscosity")

# here is a more complicated way using a for() loop. Not expected to know this
# but wanted to give you an example.
par(mfcol=c(3,3))
myVars <- c("WindowSize","GlassThickness", "AmbientTemp", "CutSpeed"
              ,"EdgeDeletionRate","SpacerDistance", "WindowColor"
              ,"SiliconViscosity")
for (s in myVars){
  hist(d[,as.character(s)], col="blue", main=paste(as.character(s)))
}

# e)	Create a correlation matrix of these variables. 
# I copied and tweaked code from the 'caret demo.R' script
str(d)
names(d)
cor(x=d[complete.cases(d),c(2:3,5:11,14)])

#f)	Discuss what you observe from d) and e). Which input variables do you think 
# are "drivers" of window breakage?

# If we just look at the correlation matrix we see that window size has a strong
# negative correlation with breakage rate (-0.49), same for glass thickness (-.68)
# which suggests these two variables might be drivers of window breakage 
#                 BreakageRate    YldFrctn   WindowSize GlassThickness
#BreakageRate       1.00000000 -0.99997170 -0.497462464   -0.687633510
#YldFrctn          -0.99997170  1.00000000  0.498878511    0.688063771
#WindowSize        -0.49746246  0.49887851  1.000000000    0.451242111
#GlassThickness    -0.68763351  0.68806377  0.451242111    1.000000000
#AmbientTemp        0.10419940 -0.10371889  0.004115768   -0.037429194
#CutSpeed           0.38109754 -0.38062416 -0.037958885   -0.537010683
#EdgeDeletionRate   0.02268768 -0.02203238 -0.018208147    0.284070216
#SpacerDistance     0.05051449 -0.05000082 -0.045622968   -0.046210271
#WindowColor        0.01913110 -0.01967529 -0.070325250   -0.261354593
#SiliconViscosity   0.05407885 -0.05431546 -0.064959054   -0.003741643

# g)	Create scatter plots of the target variable breakage rate versus these 
# numeric features: window size, glass thickness, window color, ambient 
# temp, cut speed, edge deletion rate, spacer distance, silicon visocity. 
# You may or may not use par(mfrow=).

# This is similar to problem d). I just copied the code from d and tweaked it
# to make scatter plots
par(mfcol=c(3,3))
plot(y=d$BreakageRate, x=d$WindowSize, col="blue")
plot(y=d$BreakageRate, x=d$GlassThickness, col="blue")
plot(y=d$BreakageRate, x=d$WindowColor, col="blue")
plot(y=d$BreakageRate, x=d$AmbientTemp, col="blue")
plot(y=d$BreakageRate, x=d$CutSpeed, col="blue")
plot(y=d$BreakageRate, x=d$EdgeDeletionRate, col="blue")
plot(y=d$BreakageRate, x=d$SpacerDistance, col="blue")
plot(y=d$BreakageRate, x=d$SiliconViscosity, col="blue")

#h)	Create cross-tabulation tables of the target variable pass/fail versus 
# window type, glass supplier, and glass supplier location.

# I copied and tweaked code from the 'EDA.R' script
names(d)
table(d$PassFail, d$WindowType)
table(d$PassFail, d$GlassSupplier)
table(d$PassFail, d$GlassSupplierLocation)


#i)	Create normalized views of the target variable pass/fail versus # window 
# type, glass supplier, and glass supplier location.
# NOTE: The question I provided asked for numeric features (which obviously
# did not make any sense as we use normalized views on categorical type 
# variables. You will not lose points if you did as asked)

# I copied and tweaked code from the 'EDA.R' script
library(ggplot2)
# plot 1
ggplot() +
  geom_bar(data = d, 
           aes(x = factor(WindowType),
               fill = factor(PassFail)),
           position = "fill") +
  guides(fill=guide_legend(title="Pass/Fail")) +
  #scale_fill_manual(values=c("cornflowerblue", "chartreuse4")) +
  labs(title = "Percent for Window Types that Fail",x="Window Type",y="Percent")  

# plot 2
ggplot() +
  geom_bar(data = d, 
           aes(x = factor(GlassSupplier),
               fill = factor(PassFail)),
           position = "fill") +
  guides(fill=guide_legend(title="Pass/Fail")) +
  #scale_fill_manual(values=c("cornflowerblue", "chartreuse4")) +
  labs(title = "Percent for Glass Supplier that Fail",x="Glass Supplier"
       ,y="Percent")  

# plot 3
ggplot() +
  geom_bar(data = d, 
           aes(x = factor(GlassSupplierLocation),
               fill = factor(PassFail)),
           position = "fill") +
  guides(fill=guide_legend(title="Pass/Fail")) +
  #scale_fill_manual(values=c("cornflowerblue", "chartreuse4")) +
  labs(title = "Percent for Glass Supplier Location that Fail"
       ,x="Glass Supplier Location",y="Percent")  
