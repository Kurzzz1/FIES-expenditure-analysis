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
The regression model is highly statistically significant ($F(6, 41537) = 15,070$, $p < 2.2 \times 10^{-16}$) and explains 68.52% of the variance in log-discretionary spending (Adjusted $R^2 = 0.6852$).
All predictors are highly significant ($p < 0.001$). Holding all other variables constant, the raw coefficients ($\beta$) are interpreted directly on the $\log_{10}$ scale relative to the baseline characteristics:
* Log-Total Household Income: Shows a strong, positive relationship ($\beta = 1.0010$). Since both the predictor and response are log-transformed, this represents a near-unitary elasticity where changes in income reflect proportional shifts in discretionary spending.
* Household Size: Shows a positive coefficient ($\beta = 0.0105$), indicating that every additional family member marginally shifts the log-discretionary spending baseline upward.
* Educational Attainment (Relative to 'No Formal Education'): All educational tiers exhibit positive, statistically significant shifts in discretionary spending compared to the baseline group:
  - Basic Education: $\beta = 0.1068$
  - High School Graduate: $\beta = 0.1683$
  - Undergraduate: $\beta = 0.1699$
  - College Graduate: $\beta = 0.1581$
<img width="837" height="482" alt="image" src="https://github.com/user-attachments/assets/b55473d9-0ec1-4d3f-9504-e33eae731a71" />



