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
## Tools and Project Focus ##
Language & Libraries:
- R (dplyr, patchwork, readxl, forcats, lmtest, car)
Project Focus:
- Using Base R functions to calculate statistical diagnostics manually.
- Applying log-transformations to handle highly skewed income and spending data.
- Running transparent, classic assumption checks to understand the limits of a linear model.
## Key Findings and Interpretation ##
The regression model is highly statistically significant (F(6, 41537) = 15,070, p < 2.2 x 10e-16) and explains 68.52% of the variance in household discretionary spending (Adjusted R^2 = 0.6852).
All included predictors are highly significant (p < 0.001). Because log-transformations were applied to handle extreme financial variance, the coefficients translate to the following real-world impacts:
* Income Elasticity (Log-Log): Discretionary spending exhibits a nearly perfect 1:1 elasticity with income (B $\approx$ 1.001). For every 10% increase in total household income, discretionary spending increases proportionally by 10%.
