# TITLE: Family Income and Expenditure Survey (FIES) - Discretionary Spending Analysis
# DESCRIPTION: End-to-end statistical analysis identifying the drivers of household 
# discretionary spending using Multiple Linear Regression. 
# Includes data engineering, EDA, and rigorous OLS assumption testing.

#==========================================================================================================



#---------------------------------------------------------------------------------------------------------
# PHASE 1: ENVIRONMENT SETUP & DATA IMPORT
#---------------------------------------------------------------------------------------------------------



#Install and Load Helpful Packages 

install.packages("dplyr")
install.packages("patchwork")
install.packages("readxl")
install.packages("forcats")
install.packages("lmtest")
install.packages("car")

library(dplyr)
library(patchwork)
library(readxl)
library(forcats)
library(lmtest)
library(car)

# Load the Raw Dataset

FIES <- read_excel(file.choose())



#==========================================================================================================



#---------------------------------------------------------------------------------------------------------
#Phase 2: Data Engineering and Schema Mapping
#---------------------------------------------------------------------------------------------------------


#Check Dimensionality and Data Types to make sure the dataset is loading correctly
dim(FIES)
class(FIES$`Total Household Income`)
class(FIES$`Restaurant and hotels Expenditure`)
class(FIES$`Alcoholic Beverages Expenditure`)
class(FIES$`Tobacco Expenditure`)
class(FIES$`Clothing, Footwear and Other Wear Expenditure`)
class(FIES$`Miscellaneous Goods and Services Expenditure`)
class(FIES$`Special Occasions Expenditure`)
class(FIES$`Household Head Highest Grade Completed`)
class(FIES$`Total Number of Family members`)


# Renaming key variables and engineering the target response variable which is Discretionary Spending 

FIES_Cleaned <- FIES %>%
  
  #rename variables
  rename(
    total_household_income = `Total Household Income`,
    education_of_head = `Household Head Highest Grade Completed`,
    household_size = `Total Number of Family members`
  ) %>%
  
  mutate(
    #change the data type of education of head to factor for categorical analysis
    education_of_head = as.factor(education_of_head),
    
    #aggregate specific expenditure columns into 'discretionary_spending' metric
    discretionary_spending = `Restaurant and hotels Expenditure` + 
      `Alcoholic Beverages Expenditure` + `Tobacco Expenditure` +
      `Clothing, Footwear and Other Wear Expenditure` + 
      `Miscellaneous Goods and Services Expenditure` + 
      `Special Occasions Expenditure`
  )


# Checking the quality of data (missing values or zero values)

#----Missing Values----
summary(FIES_Cleaned[, c("discretionary_spending", "total_household_income", "household_size", "education_of_head")])
# Inspect further the 'other' for education of head for missing values (education of head)
table(FIES_Cleaned$education_of_head, useNA = "always")

#----Zero Values----
zero <- colSums(FIES_Cleaned[,c("discretionary_spending","household_size", "total_household_income","education_of_head" )] == 0)
print(zero)



#==========================================================================================================



#---------------------------------------------------------------------------------------------------------
#Phase 3: Exploratory Data Analysis (Univariate Analysis)
#---------------------------------------------------------------------------------------------------------



#----Visualize the distribution and check for extreme values in Discretionary Spending---- 


DiscretionaryHistogram <- ggplot(FIES_Cleaned, aes(x = discretionary_spending)) +
  geom_histogram(fill = "steelblue", color = "white", bins = 50) + 
  scale_x_continuous(labels = scales::comma) + 
  theme_minimal() +
  labs(
    title = "Histogram of Discretionary Spending",
    xlab = "Discretionary Spending (PHP)",
    ylab = "Frequency"
  )

DiscretionaryBoxplot <- ggplot(FIES_Cleaned, aes(x = discretionary_spending)) +
  geom_boxplot(fill = "lightblue", outlier.color = "red", outlier.alpha = 0.5) + 
  scale_y_continuous(labels = scales::comma) + 
  theme_minimal() +
  labs(
    title = "Boxplot of Discretionary Spending",
    ylab = "Discretionary Spending (PHP)",
  )

# Side-by-side
DiscretionaryHistogram + DiscretionaryBoxplot


#----Visualize the distribution and check for extreme values in Total Household Income----


IncomeHistogram <- ggplot(FIES_Cleaned, aes(x=total_household_income)) +
  geom_histogram(fill = 'steelblue', color = 'white', bins = 50) +
  scale_x_continuous(labels=scales::comma) +
  theme_minimal() +
  labs(
    title = "Histogram of Total Household Income",
    xlab = "Total Household Income (PHP)",
    ylab = "frequency"
  )

IncomeBoxplot <- ggplot(FIES_Cleaned, aes(x = total_household_income)) +
  geom_boxplot(fill = "lightblue", outlier.color = "red", outlier.alpha = 0.5) +
  scale_y_continuous(labels = scales::comma) + 
  theme_minimal() +
  labs(
    title = "Boxplot of Total Household Income",
    ylab = "Total Household Income (PHP)"
  )

IncomeHistogram + IncomeBoxplot


#----Visualize the distribution and check for extreme values in Household Size----


SizeHistogram <- ggplot(FIES_Cleaned, aes(x = household_size)) + 
  geom_histogram(fill = "steelblue", color = 'white', bins = 50) + 
  scale_x_continuous(labels = scales::comma) + 
  theme_minimal() +
  labs(
    title = "Histogram of Household Size",
    xlab = "Household Size",
    ylab = "Frequency"
  )
SizeBoxplot <- ggplot(FIES_Cleaned, aes(x=household_size)) +
  geom_boxplot(fill = 'lightblue', outlier.color = 'red', outlier.alpha = 0.5) +
  scale_y_continuous(labels = scales::comma) + 
  theme_minimal() +
  labs(
    title = "Boxplot of Household Size",
    ylab = "Household Size"
  )

SizeHistogram + SizeBoxplot


#----Visualize the distribution of Educational Attainment----


educational_table <- FIES_Cleaned %>%
  count(education_of_head) %>%
  mutate(percentage = (n/sum(n)) * 100) %>%
  arrange(desc(n))

print(educational_table)

ggplot(FIES_Cleaned, aes(x = reorder(education_of_head, education_of_head, function(x)-length(x)))) +
  geom_bar(fill = "seagreen", color = "white") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + # Rotates long labels so they don't overlap
  labs(
    title = "Distribution of Household Head Educational Attainment",
    x = "Highest Grade Completed",
    y = "Household Count"
  )


#----The raw educational attainment data contains too many granular categories----
#----We collapse these into 5 logical, structured tiers to improve model interpretability----


FIES_Cleaned <- FIES_Cleaned %>%
  mutate(
    education_groups = fct_collapse(education_of_head, 
                                    "No Formal Education" = c("No Grade Completed"),
                                    "Basic Education" = c("Elementary Graduate", "First Year High School",
                                                          "Grade 1", "Grade 2", "Grade 3", "Grade 4", "Grade 5", "Grade 6",
                                                          "Preschool", "Second Year High School","Third Year High School"),
                                    "High School Graduate" = c("High School Graduate"),
                                    "Undergraduate" = c("First Year College", "First Year Post Secondary","Fourth Year College", 
                                                        "Second Year College", "Second Year Post Secondary", "Third Year College"),
                                    "College Graduate" = c("Agriculture, Forestry, and Fishery Programs", "Architecture and Building Programs",
                                                           "Arts Programs", "Basic Programs", "Business and Administration Programs",
                                                           "Computing/Information Technology Programs", "Engineering and Engineering Trades Programs", 
                                                           "Engineering and Engineering trades Programs", "Environmental Protection Programs", 
                                                           "Health Programs", "Humanities Programs", "Journalism and Information Programs",
                                                           "Law Programs", "Life Sciences Programs", "Manufacturing and Processing Programs", 
                                                           "Mathematics and Statistics Programs", "Personal Services Programs", 
                                                           "Physical Sciences Programs", "Post Baccalaureate", "Security Services Programs", 
                                                           "Social and Behavioral Science Programs", "Social Services Programs", 
                                                           "Teacher Training and Education Sciences Programs", "Transport Services Programs", "Veterinary Programs",
                                                           "Other Programs in Education at the Third Level, First Stage, of the Type that Leads to an Award not Equivalent to a First University or Baccalaureate Degree",
                                                           "Other Programs of Education at the Third Level, First Stage, of the Type that Leads to a Baccalaureate or First University/Professional Degree (HIgher Education Level, First Stage, or Collegiate Education Level)")
    )) %>%
  mutate(education_groups = fct_relevel(education_groups,
                                        "No Formal Education",
                                        "Basic Education",
                                        "High School Graduate",
                                        "Undergraduate",
                                        "College Graduate"
  )
  )

#Double checking if there are any missing vales
table(FIES_Cleaned$education_of_head, useNA = "always")

#----Visualizing the newly structured educational tiers----

educationalattainmenttable<- FIES_Cleaned  %>%
  count(education_groups) %>%
  mutate(percentage = (n/sum(n)*100)) %>%
  arrange(desc(n))

print(educationalattainmenttable)

educationbar <- ggplot(FIES_Cleaned, aes(x =  reorder(education_groups, education_groups, function(x) - length(x)))) +
  geom_bar(fill = "steelblue", color = "white") +
  theme_minimal() + 
  labs(
    title = "Distribution of Household Head Educational Attainment",
    x = "Educational Attainment",
    y = "Household Count"
  )
educationbar



#==========================================================================================================



#---------------------------------------------------------------------------------------------------------
#Phase 4: Exploratory Data Analysis (Bivariate Analysis and Multicollinearity)
#---------------------------------------------------------------------------------------------------------



#----Correlation Analysis----


#Quantifying linear relationship with the target variable
Correlation1 <- cor(FIES_Cleaned$total_household_income, FIES_Cleaned$discretionary_spending, method = "pearson")
Correlation2 <- cor(FIES_Cleaned$household_size, FIES_Cleaned$discretionary_spending, method = "pearson")

print(Correlation1)
print(Correlation2)


#----ScatterPlot of Discretionary Spending and Total Household Income/Household Size----


ScatterPlot1 <- ggplot(FIES_Cleaned, aes(x = total_household_income, y = discretionary_spending)) + 
  #adding the points
  geom_point(alpha = 0.5, color = "steelblue") + 
  #adding linear regression trendline
  geom_smooth(method = "lm", color = "darkred", se = TRUE) +
  scale_x_log10(labels =  scales::comma) +
  scale_y_log10(labels =  scales::comma) +
  theme_minimal() + 
  labs(
    title = "Scatterplot of Income vs Discretionary Spending",
    subtitle = paste("Pearson Correlation r = ", round(Correlation1, 2)),
    x = "Total Household Income (PHP)",
    y = "Discretionary Spending (PHP)"
  )

ScatterPlot2 <- ggplot(FIES_Cleaned, aes(x = household_size, y = discretionary_spending)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_smooth(method = "lm", color = "darkred", se = TRUE) +
  scale_y_log10(labels = scales::comma) + 
  scale_x_continuous(breaks = seq(1, max(FIES_Cleaned$household_size), by = 1)) +
  theme_minimal() +
  labs(
    title = "Scatterplot of Household Size vs Discretionary Spending",
    subtitle = paste("Pearson Correlation r=", round(Correlation2, 2)),
    x = "Household Size",
    y = "Discretionary Spending (PHP)"
  )

print(ScatterPlot1)
print(ScatterPlot2)


#----Group Differences of Educational Attainment in Discretionary Spending----


DSEABoxplot <- ggplot(FIES_Cleaned, aes(x = education_groups, y = discretionary_spending)) + 
  # fill = education_groups gives each boxplot a different color
  geom_boxplot(aes(fill = education_groups), outlier.alpha = 0.5) + 
  #removes the redundant color legend on the side
  guides(fill = "none") +
  scale_y_log10(labels = scales::comma) +
theme_minimal() +
  labs(
    title = "Discretionary Spending by Highest Educational Attainment",
    x = "Higest Educational Attainment",
    y = "Discretionary Spending"
  )
DSEABoxplot


#----Multicolinnearity Check----


# Houshold Size vs Household Income
Collinearity <- ggplot(FIES_Cleaned, aes(x = household_size, y =  total_household_income)) + 
  geom_jitter(alpha = 0.15, col = "darkgreen",width = 0.2, height = 0) +
  geom_smooth(method = "lm", color = "darkred", se = FALSE ) +
  scale_x_continuous(breaks = seq(1, max(FIES_Cleaned$household_size), by = 2)) +
  scale_y_log10(labels = scales::comma) +
  theme_minimal() +
  labs(
    title = "Collinerity Screen",
    x = "Household Size",
    y = "Title Household Income (PHP)"
  )
Collinearity


#Education Groups vs Household Income
Edu_Income <- ggplot(FIES_Cleaned, aes(x =  education_groups, y = total_household_income)) + 
  geom_boxplot(aes(education_groups), outlier.alpha = 0.5) + 
  scale_y_log10(labels = scales::comma) +
  theme_minimal() +
  labs(
    title = "Total Household Income across Educational Attainment",
    x = "Highest Educational Attainment",
    y = "Total Household Income (PHP)"
  )
Edu_Income


#Education Groups vs Household Size
Edu_Size <- ggplot(FIES_Cleaned, aes(x =  education_groups, y = household_size)) + 
  geom_boxplot(aes(education_groups), outlier.alpha = 0.5) + 
  scale_y_continuous(breaks = seq(1, max(FIES_Cleaned$household_size), by = 2)) +
  theme_minimal() +
  labs(
    title = "Total Household Income across Educational Attainment",
    x = "Highest Educational Attainment",
    y = "Household Size"
  )
Edu_Size



#==========================================================================================================



#---------------------------------------------------------------------------------------------------------
#Phase 5: Multiple Linear Regression and Diagnostic
#---------------------------------------------------------------------------------------------------------



#----Model Building----
#Build the OLS Model applying log10 transformation to discretionary spending and household income to handle heavy-tailed financial data
FIESModel <- lm(log10(discretionary_spending) ~ log10(total_household_income) + household_size + education_groups, data = FIES_Cleaned)
summary(FIESModel)


#----Assumption Checking----


# 5.1: Linearity Test using Residuals vs Fitted Plot
plot(FIESModel, which = 1)
#Interpretation: Since the red line stays almost flat and stays very close to the horizontal dash line at 0
#across the majority of data, then the linearity assumption is satistfied.


# 5.2: Independence of Errors using ACF plot
acf(resid(FIESModel), main="Residual Autocorrelation")
# The ACF plot shows significant positive autocorrelation in the residuals, which means the errors are not independent.


# 5.3: Homoscedasticity using Breush-Pagan Test
bptest(FIESModel)
# p-value < 2.2e-16 strongly rejects the null hypothesis. Thus, Heteroscedasticity is present.
# Although this is expected in expenditure due to expanding variance at higher income bracket.


# 5.4: Multicollinearity using Variance Inflation Factor
vif(FIESModel) 
# GVIF of predictor variables is less than 10 and near 1, thus there's no presence of Multicollinearity.


# 5.5: Outlier, Leverage, and Influential Points


#--Outlier--
residuals_FIESModel <- resid(FIESModel)
standardized_residuals_FIESModel <- rstandard(FIESModel)
studentized_residuals_FIESModel <- rstudent(FIESModel)

residual_table <- data.frame(
  Observation = 1:nrow(FIES),
  Residual = residuals_FIESModel,
  Standardized_Residual = standardized_residuals_FIESModel,
  Studentized_Residual = studentized_residuals_FIESModel
)

View(residual_table)
outlier_residual <- which(abs(studentized_residuals_FIESModel) > 3)
outlier_residual


#--Leverage--
leverage_values <- hatvalues(FIESModel)
k <- length(coef(FIESModel)) - 1
n <- nrow(FIES_Cleaned)
leverage_cutoff <- 2 * (k + 1) / n

leverage_table <- data.frame(
  Observation = 1:n,
  Leverage = leverage_values,
  Cutoff = leverage_cutoff,
  High_Leverage = leverage_values > leverage_cutoff
)
which(leverage_values > leverage_cutoff)
View(leverage_table)


#--Influential Points--
#Due to large sample size, we'll use the plot instead for reliable evidence. 
plot(FIESModel, which = 4)

#Outliers = 642, High Leverage = 2948, and based on the plot no influential points.
#Although there are outliers and high leverage, having no influential points means the
#regression coefficients are robust and not driven by individual anomalies. 


# 5.6: Normality of Erros using QQ-plot
qqnorm(resid(FIESModel))
qqline(resid(FIESModel), col = "red")
#The qqplot exhibits deviation at both the upper and lower tails, which means that the distribution
#is heavy tailed. However, due to large sample size and CLT, statistical inference is still valid. 




