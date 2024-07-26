## SQL CASE STUDY ON LAPTOP DATASET IN MYSQL

In the given case study we will basically be doing data pre-processing and EDA on our dataset.

We usually do EDA using pandas for the dataset, but for this we are doing using SQL.

![](lpimage.jpeg 'Title')

## DATASET

The dataset contains 1272 rows.Some of the features of the dataset are Company,TypeName,CPU,GPU,Ram,Memory,OpSys and manymore.
The dataset file can be downloaded from [LAPTOP.csv](laptopData.csv)

## DATA PREPROCESSING
So, in data preprocessing step, we have basically used some of the common methods for preprocessing such as -
>DATA CLEANING

>Reduce the memory consumption of the dataset

>To remove null values if present

>To remove duplicates

>Remove the rows which are not required

## EDA(Exploratory Data Analysis)
So in EDA we have basically done the following steps

1. Find head,tail,random sample of the dataset
2. For a numerical column
   1. Find the min,max,srd,var,count
   2. Find the missing values
   3. Find the outliers
   4. Horizontal or vertical histogram
   
3. For categorical columns
   1. Value_counts
   2. Missing value
   
4. Bivariate analysis - Numerical vs Numerical
   1. Find the min,max,srd,var,count
   2. scatterplot
   
5. Categorical vs Categorical
   1. contigency table
   
6. Numerical vs Categorical
   1. compare distribution across categories
   
7. Feature Engineering
   1. ppi
   2. screen_size_bracket
   
8. One Hot Encoding
   
## Requirements
To run the MYSQL queries the software you need is mysql workbench and you can download it from here:
[mysql Workbench](https://dev.mysql.com/downloads/workbench/)