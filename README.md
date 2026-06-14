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

## Diagnostic and Model Limitations ##

Linearity (Residuals vs. Fitted Plot)

<img width="830" height="553" alt="image" src="https://github.com/user-attachments/assets/b9da675f-2aea-440e-b622-1245befe966a" />


- Observation: The red line stays pretty flat and hugs the horizontal dashed line at 0 across almost all of the data points.
- Verdict: The linearity assumption holds up well here. It shows that a straight-line model is a great fit for the data, and there aren't any weird hidden curves throwing off the predictions.
  
Independence of Errors (ACF Plot)

<img width="1382" height="887" alt="image" src="https://github.com/user-attachments/assets/9e3501e4-28e6-4b86-9993-d5dc378b6025" />

- Observation: The vertical bars on the plot stick out way past the blue dashed lines in a clear, downward wave instead of looking like random, messy spikes.
- Verdict: The independence assumption doesn't hold here. In a massive survey like this, this kind of pattern usually pops up because of a group effect—like neighbors or families living in the same region naturally sharing similar local spending habits.
  
Homoscedasticity (Breusch-Pagan Test)

<img width="405" height="96" alt="image" src="https://github.com/user-attachments/assets/84c0e9ec-7071-42bb-b2f9-07720bc761eb" />

- Observation: The Breusch-Pagan test returns a tiny p-value ($p < 2.2 \times 10^{-16}$), which completely rules out the idea of a perfectly uniform spread.
- Verdict: Heteroscedasticity is present, but it is 100% expected here. In real-world economics, higher-income households have wildly different spending habits—some save a ton, others spend heavily on leisure—while lower-income households are locked into a tighter budget. That natural widening of choices as income grows is exactly why the variance spreads out.

Multicollinearity (GVIF)

<img width="597" height="77" alt="image" src="https://github.com/user-attachments/assets/47552302-781f-4d44-b9e6-b268789a1b34" />

- Observation: The Generalized VIF values for all predictor variables are incredibly low, sitting safely between 1.14 and 1.54.
- Verdict: Multicollinearity is definitely not an issue here. Because the values are all super close to 1 and nowhere near the typical red-flag thresholds of 5 or 10, it proves that income, household size, and education aren't overlapping or stepping on each other's toes. Your model can cleanly isolate the impact of each variable.

Influential Points (Cook's Distance)

<img width="830" height="553" alt="image" src="https://github.com/user-attachments/assets/22794eb6-f58d-415e-9124-93335822b9f1" />

- Observation: The plot shows that the highest spike (observation 21954) only reaches about 0.0035, which is nowhere near the standard red-flag threshold of 0.5. Even though the data contains 642 outliers and 2,948 high-leverage points, they are completely flat on this scale.
- Verdict: There are zero influential points pulling the strings. This proves that even though a massive survey like the FIES naturally has some extreme spending anomalies or unique family setups, none of them have enough power to single-handedly tilt or warp the regression lines. The coefficients are completely stable and robust.


Normality of Errors (Normal Q-Q Plot)

<img width="830" height="553" alt="image" src="https://github.com/user-attachments/assets/70630406-3a89-4cfb-b5ac-1527d424d9a1" />

- Observation: The points track the straight red reference line closely through the center but curve away at both ends—dipping below the line on the left and rising above it on the right. This classic pattern indicates a heavy-tailed distribution rather than a perfect normal curve.
- Verdict: While the strict normality assumption is technically violated at the extremes, it does not compromise the model. Thanks to the massive sample size of over 41,000 households, the Central Limit Theorem (CLT) guarantees that all statistical inferences, p-values, and confidence intervals remain completely valid and reliable.


