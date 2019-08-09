Thesis: Cancer Mortality Rate of each County in the United States
================
This is brief introduction for my project on analyzing and predicting Cancer Mortality Rate of each County in the United States. For reading whole report, please go to file `report` above.

### 1. INTRODUCTION

Cancer has major impact on society in the world. Many researchers around the world has conducted many research to come up treatment plans to deal with cancer. One of most frequently used measurement for researchers or doctors to track the progress of cancer is Cancer Mortality Rate(Cancer Death Rate). It describes the number of people who die from cancer out of 100,000 people in 1 year. According to National Cancer Institute, the number of cancer deaths (cancer mortality) is 163.5 per 100,000 men and women per year (based on 2011–2015 deaths). In the previous paper "Poisson Regression in Mapping Cancer Mortality" by Marta N.Vacchino, the author aims to map standardized mortality ratios of specific cancers in Argentina and to use Poisson regression to find some ecological relationships. In this paper, I used author Marta N.Vacchino's Paper as reference to analyze and fitted multiple statistical models to predict the cancer mortality rate for each county at the United States. The purpose are to find the factors can affect the cancer mortality rate and to find best statistical models to predict the cancer mortality rate.

### 2. MATERIALS

#### 2.1 Cancer Data

The cancer data is from Data World. According to Data World, these data were aggregated from a number of sources including the American Community Survey (census.gov), clinicaltrials.gov, and cancer.gov. The data set contains 3,047 county in the U.S. with the cancer mortality rate during 2010 through 2016. The mortality rate range are from 59.7 to 362.8.

There are 31 numerical variables and 1 categorical variable in the dataset. The variables studied were incidence rate, median income, percentage of race(white, black, asian, ect), percentage of education levels(high school, college), and ects. The target variable is mortality rate(death rate).

#### 2.2 Quality of the Data

There are three variables contain missing value, which are "pctsomecol18\_24", "pctprivatecoveragealone", and "pctemployed16\_over". The percentage of missing in these variables are 75%, 20% and 5% respectively. The missing value of these variables might have huge effect on our statistical models. It might consisder to remove those variables for modeling.

There are also some variables are multicollinearity. Multicollinearity(predictors are highly correlated) is bad for linear regression and it should be removed.

#### 2.3 Population

The population for 3,047 counties in the U.S. are obtained from the census 2015. The Los Angeles County, California has higgest population 10,170,292 among those counties and Golden Valley County, Montana has the lowest population 827.

### 3. STATISTICAL ANALYSIS

We split the data into 70 percent training and 30 percent testing. We used the training data to fit multiple statistical models and used testing data to evaluate the results.

We used the following model to fit the data:

-   Multiple Linear Regression

-   Scaled Poisson Regression

-   Logistics Regression

-   Multilevel Regression - Random Intercept

**Key Note** - For scaled poisson regression and logistics regression, we rounded our target variable deathrate(mortality rate) into whole number. For example, we converted deathrate 164.9 for Kitsap County, Washington into 165. The reason is these two model only works with whole number.

**Target Variable DeathRate** - Mean per capita (100,000) cancer mortalities(a)


<table>
<colgroup>
<col width="26%" />
<col width="30%" />
<col width="42%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">Equation Variable</th>
<th align="center">Variables</th>
<th align="center">Defintion</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">X_1</td>
<td align="center">incidencerate</td>
<td align="center">Mean per capita (100,000) cancer diagoses</td>
</tr>
<tr class="even">
<td align="center">X_2</td>
<td align="center">povertypercent</td>
<td align="center">Percent of populace in poverty</td>
</tr>
<tr class="odd">
<td align="center">X_3</td>
<td align="center">pctwhite</td>
<td align="center">Percent of county residents who identify as White</td>
</tr>
<tr class="even">
<td align="center">X_4</td>
<td align="center">pctblack</td>
<td align="center">Percent of county residents who identify as Black</td>
</tr>
<tr class="odd">
<td align="center">X_5</td>
<td align="center">pctasian</td>
<td align="center">Percent of county residents who identify as Asian</td>
</tr>
<tr class="even">
<td align="center">X_6</td>
<td align="center">pctotherrace</td>
<td align="center">Percent of county residents who identify in a category which is not White, Black, or Asian</td>
</tr>
<tr class="odd">
<td align="center">X_7</td>
<td align="center">pctnohs18_24</td>
<td align="center">Percent of county residents ages 18-24 highest education attained: less than high school</td>
</tr>
<tr class="even">
<td align="center">X_8</td>
<td align="center">pcths18_24</td>
<td align="center">Percent of county residents ages 18-24 highest education attained: high school diploma</td>
</tr>
<tr class="odd">
<td align="center">X_9</td>
<td align="center">pctbachdeg18_24</td>
<td align="center">Percent of county residents ages 18-24 highest education attained: bachelorâs degree</td>
</tr>
<tr class="even">
<td align="center">X_10</td>
<td align="center">pcths25_over</td>
<td align="center">Percent of county residents ages 25 and over highest education attained: high school diploma</td>
</tr>
<tr class="odd">
<td align="center">X_11</td>
<td align="center">pctbachdeg25_over</td>
<td align="center">Percent of county residents ages 25 and over highest education attained: bachelorâs degree</td>
</tr>
<tr class="even">
<td align="center">X_12</td>
<td align="center">percentmarried</td>
<td align="center">Percent of county residents who are married</td>
</tr>
<tr class="odd">
<td align="center">X_13</td>
<td align="center">pctunemployed16_over</td>
<td align="center">Percent of county residents ages 16 and over unemployed</td>
</tr>
<tr class="even">
<td align="center">X_14</td>
<td align="center">pctempprivcoverage</td>
<td align="center">Percent of county residents with private health coverage</td>
</tr>
<tr class="odd">
<td align="center">X_15</td>
<td align="center">pctpubliccoverage</td>
<td align="center">Percent of county residents with government-provided health coverage</td>
</tr>
<tr class="even">
<td align="center">X_16</td>
<td align="center">medianage</td>
<td align="center">Median age of county residents</td>
</tr>
<tr class="odd">
<td align="center">X_17</td>
<td align="center">medincome</td>
<td align="center">Median income per county</td>
</tr>
</tbody>
</table>





