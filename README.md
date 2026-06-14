# FIES-expenditure-analysis
A comprehensive OLS regression baseline and diagnostic audit of household discretionary spending, emphasizing classical statistical assumption testing using the FIES dataset.
## Project Overview ##
This project establishes a statistical baseline identifying the primary drivers of household discretionary spending using data from the Family Income and Expenditure Survey (FIES). This analysis executes an end-to-end Ordinary Least Squares (OLS) regression workflow in Base R, featuring data engineering, univariate/bivariate exploratory data analysis (EDA), and a transparent diagnostic audit based on the classical Neter, Wasserman, and Kutner (1983) framework.
## Data and Variables ##
Source: Family Income and Expenditure Survey (FIES)
Target Variable: log10(discretionary_spending) #Created by adding together what a household spends on restaurants/hotels, alcohol, tobacco, clothing, miscellaneous goods, and special occasions.
Predictors:
- log10(total_household_income) #Total income
- household_size #Number of family members
- education_groups #The household head's education, simplified from raw data into 5 basic groups
