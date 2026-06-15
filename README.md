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

## ETL ##
- Verified the dataset was complete for the selected variables, with no missing values and zero values.
- Engineered target variable by aggregating expenditure (Restaurant and Hotels Expenditure, Alcoholic Beverages Expenditure, Tobacco Expenditure, Clothing, Footwear and Other Wear Expenditure, Miscellaneous Goods and Services Expenditure, Special Occasions Expenditure)
- Cleaned up the messy raw education data by grouping dozens of individual grade levels into 5 simple tiers. This keeps the model from getting bogged down in the noise, making it much easier to see how, for instance, graduating high school or college impacts spending.
- Applied $\log_{10}$ transformations to both total income and discretionary spending to normalize the severe right-skewness typical in economic household data.


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

## Diagnostic and Model Limitations ##

Linearity (Residuals vs. Fitted Plot)

<img width="830" height="553" alt="image" src="https://github.com/user-attachments/assets/b9da675f-2aea-440e-b622-1245befe966a" />


- Observation: The red line stays pretty flat and hugs the horizontal dashed line at 0 across almost all of the data points.
- Verdict: The linearity assumption holds up well here. It shows that a straight-line model fits the data quite well and that no strange hidden curves are messing with the predictions.
  
Independence of Errors (ACF Plot)

<img width="1382" height="887" alt="image" src="https://github.com/user-attachments/assets/9e3501e4-28e6-4b86-9993-d5dc378b6025" />

- Observation: The vertical bars on the plot stick out much past the blue dashed lines in a clear, downward wave instead of looking like random, jumbled spikes.
- Verdict: The independence assumption doesn't hold here. This type of pattern typically appears in a large study like this due to a group effect, such as neighbors or families in the same area naturally having similar local spending habits.
  
Homoscedasticity (Breusch-Pagan Test)

<img width="405" height="96" alt="image" src="https://github.com/user-attachments/assets/84c0e9ec-7071-42bb-b2f9-07720bc761eb" />

- Observation: The Breusch-Pagan test returns a tiny p-value ($p < 2.2 \times 10^{-16}$), which completely rules out the idea of a equal variance.
- Verdict: Although heteroscedasticity is present, this is completely expected. In real-world economics, lower-income households are constrained by a smaller budget, whereas higher-income households have significantly different spending patterns—some save a lot, while others spend a lot on leisure. The variance expands out precisely because of this inherent expansion of options as wealth increases.

Multicollinearity (GVIF)

<img width="597" height="77" alt="image" src="https://github.com/user-attachments/assets/47552302-781f-4d44-b9e6-b268789a1b34" />

- Observation: The Generalized VIF values for all predictor variables are incredibly low, sitting safely between 1.14 and 1.54.
- Verdict: Multicollinearity is not a problem in this case. The fact that all of the values are extremely close to 1 and far from the usual red-flag values of 5 or 10 shows that income, household size, and education are not overlapping or interfering with one another. Each variable's impact may be neatly isolated by the model itself.

Influential Points (Cook's Distance)

<img width="830" height="553" alt="image" src="https://github.com/user-attachments/assets/22794eb6-f58d-415e-9124-93335822b9f1" />

- Observation: The highest spike (observation 21954) in the plot barely reaches roughly 0.0035, which is far below the typical red-flag threshold of 0.5. The data is entirely flat on this scale despite having 2,948 high-leverage points and 642 outliers.
- Verdict: There are zero influential points. This shows that, despite the fact that a large survey such as the FIES always contains some extreme expenditure anomalies or unique family setups, none of these are strong enough to cause the regression lines to tilt or warp on their own. The coefficients are robust and completely stable.


Normality of Errors (Normal Q-Q Plot)

<img width="830" height="553" alt="image" src="https://github.com/user-attachments/assets/70630406-3a89-4cfb-b5ac-1527d424d9a1" />

- Observation: The points closely follow the straight red reference line through the middle, but at both ends they curve away, rising above the line on the right and falling below it on the left. Rather than a perfect normal curve, this typical shape suggests a heavy-tailed distribution.
- Verdict: Although the strict normality assumption is technically violated at the extremes, the model is unaffected. The Central Limit Theorem (CLT) ensures that all statistical conclusions, p-values, and confidence intervals remain fully valid and reliable because of the enormous sample size of almost 41,000 households.


