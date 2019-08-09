#load libraries
library(tidyverse)
library(pander)
#import data
cancer_reg <- read_csv("data/cancer_data/cancer_reg.csv")

cancer_reg_train <- read_csv("data/cancer_data/cancer_reg_train.csv")
cancer_reg_test <- read_csv("data/cancer_data/cancer_reg_test.csv")
cancer_reg %>%
  filter(target_deathrate == max(target_deathrate) |
         target_deathrate == min(target_deathrate))
#missing value
cancer_reg %>%
  map(.f = function(x){
    sum(is.na(x))
  }) %>%
  as_tibble() %>%
  gather(key = "Varible", value =  "Number_of_Missing_Value") %>%
  arrange(desc(Number_of_Missing_Value)) %>%
  mutate(Percentage = round(Number_of_Missing_Value / nrow(cancer_reg) * 100,3))
summary(cancer_reg$popest2015)

cancer_reg %>%
  filter(popest2015 == min(popest2015)|
           popest2015 == max(popest2015))

## #split the data 70% training  and 30% testing
## set.seed(12)
## train_Index <- caret::createDataPartition(cancer_reg$target_deathrate, p = .7,
##                                   list = FALSE,
##                                   times = 1)
## cancer_reg_train <- cancer_reg[train_Index, ]
## cancer_reg_test  <- cancer_reg[-train_Index,]
## 
## cancer_reg_train %>%
##   write.csv("cancer_reg_train.csv", na = "", row.names = F)
## 
## cancer_reg_test %>%
##   write.csv("cancer_reg_test.csv", na = "", row.names = F)
## 
regfit <- lm(target_deathrate ~ ., data = cancer_reg_train %>%
               dplyr::select(-geography, -binnedinc, -state, -county))

set.seed(123)
regfit_fwd_0.05 <- olsrr::ols_step_forward_p(regfit, pent = 0.05)

regfit_bwd_0.05 <- olsrr::ols_step_backward_p(regfit, prem = 0.05)

regfit_fwd_0.05
regfit_bwd_0.05
fwd_vars <- regfit_fwd_0.05$predictors 
bwd_vars <- setdiff(
  names(cancer_reg %>%
          select(-state, -county, -binnedinc,
               -geography, -target_deathrate)), regfit_bwd_0.05$removed)
var.list <- list(fwd_vars, bwd_vars)

n.obs <- sapply(var.list, length)

seq.max <- seq_len(max(n.obs))

mat <- (sapply(var.list, "[", i = seq.max))

vars_sele_df <- tibble(`Stepwise Forward Selection` = mat[,1],
       `Stepwise Backward Selection` = mat[,2]) 

vars_sele_df[is.na(vars_sele_df$`Stepwise Backward Selection`),2] <- "-"

vars_sele_df %>%
  pander()
equ_vars <- c("X_1", "X_2", "X_3", "X_4", "X_5", "X_6",
              "X_7", "X_8", "X_9", "X_10","X_11", "X_12","X_13",
              "X_14","X_15", "X_16", "X_17")
vars <- c("incidencerate", "povertypercent", "pctwhite", "pctblack", 
          "pctasian", "pctotherrace", "pctnohs18_24", "pcths18_24", 
          "pctbachdeg18_24", "pcths25_over", "pctbachdeg25_over",
           "percentmarried" , "pctunemployed16_over" , 
           "pctempprivcoverage", "pctpubliccoverage",
           "medianage", "medincome")

def <- c("Mean per capita (100,000) cancer diagoses",
         "Percent of populace in poverty",
         "Percent of county residents who identify as White",
         "Percent of county residents who identify as Black",
         "Percent of county residents who identify as Asian",
         "Percent of county residents who identify in a category 
          which is not White, Black, or Asian",
         "Percent of county residents ages 18-24 highest education attained: less than high school",
         "Percent of county residents ages 18-24 highest education attained: high school diploma",
         "Percent of county residents ages 18-24 highest education attained: bachelor’s degree",
         "Percent of county residents ages 25 and over highest education attained: high school diploma",
         "Percent of county residents ages 25 and over highest education attained: bachelor’s degree",
         "Percent of county residents who are married",
         "Percent of county residents ages 16 and over unemployed",
         "Percent of county residents with private health coverage",
         "Percent of county residents with government-provided health coverage",
         "Median age of county residents",
         "Median income per county")

tibble(`Equation Variable` = equ_vars, 
       Variables = vars,
       Defintion = def) %>%
  pander::pander()

regfit_cancer <- lm(target_deathrate ~ incidencerate + povertypercent + 
                      pctwhite + pctblack + pctasian + pctotherrace + 
                      pctnohs18_24 + pcths18_24  + pctbachdeg18_24 + 
                      pcths25_over + pctbachdeg25_over +
                      percentmarried + pctunemployed16_over + 
                      pctempprivcoverage + pctpubliccoverage + 
                      medianage + medincome, 
                    data = cancer_reg_train)

panderOptions("digits", 6)


regfit_cancer %>%
  summary() 

regfit_cancer$coefficients %>%
  round(6)
qq <- olsrr::ols_plot_resid_qq(regfit_cancer) + theme_bw()
res <- olsrr::ols_plot_resid_fit(regfit_cancer) + theme_bw()
cowplot::plot_grid(qq, res)

#round the deathrate to whole number
cancer_reg_train$target_deathrate_count <- 
  round(cancer_reg_train$target_deathrate,0) 

cancer_reg_train$target_deathrate_count <- 
  round(cancer_reg_train$target_deathrate,0) 

#mean and variance of deathrate count
mean_deathrate <- round(mean(cancer_reg_train$target_deathrate_count),3)
var_deathrate <- round(var(cancer_reg_train$target_deathrate_count),3)

glue::glue("
mean: {mean_deathrate}
Var: {var_deathrate}")


#poisson 
poisson_cancer <- glm(target_deathrate_count ~ incidencerate + povertypercent + 
                      pctwhite + pctblack + pctasian + pctotherrace + 
                      pctnohs18_24 + pcths18_24  + pctbachdeg18_24 + 
                      pcths25_over + pctbachdeg25_over +
                      percentmarried + pctunemployed16_over + 
                      pctempprivcoverage + pctpubliccoverage + 
                        medianage + medincome, 
    data = cancer_reg_train, family=poisson(link=log))

#table result
poisson_cancer %>%
  summary() %>%
  pander::pander()


#overdispersion test
AER::dispersiontest(poisson_cancer)
#scaled poisson 
scaled_poisson_cancer<-glm(target_deathrate_count ~ incidencerate + povertypercent + 
                      pctwhite + pctblack + pctasian + pctotherrace + 
                      pctnohs18_24 + pcths18_24  + pctbachdeg18_24 + 
                      pcths25_over + pctbachdeg25_over +
                      percentmarried + pctunemployed16_over + 
                      pctempprivcoverage + pctpubliccoverage + 
                        medianage + medincome, 
    data = cancer_reg_train, family=quasipoisson(link=log))

scaled_poisson_cancer %>%
    summary() %>%
  pander

scaled_poisson_cancer$coefficients %>%
  round(6)
#logsitcs regression

cancer_reg_train$target_survialrate_count <- 100000 - 
  cancer_reg_train$target_deathrate_count

Log_cancer <- glm(cbind(target_deathrate_count, target_survialrate_count) ~
                      incidencerate + povertypercent + 
                      pctwhite + pctblack + pctasian + pctotherrace + 
                      pctnohs18_24 + pcths18_24  + pctbachdeg18_24 + 
                      pcths25_over + pctbachdeg25_over +
                      percentmarried + pctunemployed16_over + 
                      pctempprivcoverage + pctpubliccoverage + 
                    medianage + medincome,
                  
                  family=binomial, data = cancer_reg_train)

Log_cancer %>%
  summary

#Multilevel regression Random Intercept

ML_state <- lme4::lmer(target_deathrate ~ incidencerate + povertypercent + 
                      pctwhite + pctblack + pctasian + pctotherrace + 
                      pctnohs18_24 + pcths18_24  + pctbachdeg18_24 + 
                      pcths25_over + pctbachdeg25_over +
                      percentmarried + pctunemployed16_over + 
                      pctempprivcoverage + pctpubliccoverage + 
                        medianage + medincome + (1 | state), 
                 data = cancer_reg_train) 


totalVar <- 71.14  + 335.66

pie(c(71.14/totalVar,335.66/totalVar), labels = c('17%','83%' ),
    main = 'Breakdown of Variance', col = c('red','pink'))


legend(-1.75,1,legend =c('Level 2: Intercept','Level 1'),
       col = c('red','pink','lightgreen'),
       pch = 22, pt.bg = c('red','pink'),
       cex = .75)

p1 <- tibble(Residual = residuals(ML_state)) %>%
  ggplot(aes(sample = Residual)) +
  stat_qq(color = "blue") + 
  stat_qq_line(color = "red") +
  labs(title = "Normal Q-Q Plot") +
  theme_bw()

p2 <- tibble(fitted.value = fitted(ML_state),
       Residual = residuals(ML_state)) %>%
  ggplot(aes(fitted.value, Residual)) +
  geom_point(color = "blue") +
  geom_hline(yintercept = 0, color = "red")+
  labs(x = "fitted value", y = "residuals",
       title = "fitted value vs residuals plot") +
  theme_bw()

cowplot::plot_grid(p1, p2)

#performance on training data
#-----------------------
#mul linear regression
#scaled poisson
#logistics regression
#Multilevel Regression - Random Intercept

mse <- function(actual_value,fitted_value) {
    round(mean((actual_value - fitted_value)^2),4)
}



#mse
mse_ml_train <- mse(cancer_reg_train$target_deathrate, 
                    regfit_cancer$fitted.values)

mse_sp_train <- mse(cancer_reg_train$target_deathrate_count, 
                    scaled_poisson_cancer$fitted.values)
  

mse_log_train <- mse(cancer_reg_train$target_deathrate_count, 
                     (Log_cancer$fitted.values*100000))
  

mse_ram_inc_train <-  mse(cancer_reg_train$target_deathrate, 
                          fitted(ML_state))
  




tibble(models = c("Multiple_Linear_Regression", "Scaled_poisson_regression", 
                  "Logistics_Regression","Multilevel Regression - Random Intercept"),
  R2 = c(round(rsq::rsq(regfit_cancer, adj = F),2), 
         round(rsq::rsq(scaled_poisson_cancer, adj = F),2), "", 0.54),
  Adj_R2 = c(round(rsq::rsq(regfit_cancer, adj = T),2), 
             round(rsq::rsq(scaled_poisson_cancer, adj = T),2), "", ""),
  MSE = c(mse_ml_train, mse_sp_train, mse_log_train, mse_ram_inc_train)) %>%
  pander()

#performance on testing data
#-----------------------

cancer_reg_test$target_deathrate_count = round(cancer_reg_test$target_deathrate,
                                               0)

mse_ml_test <- mse(cancer_reg_test$target_deathrate, 
                   regfit_cancer %>%
                     predict(cancer_reg_test))


mse_sp_test <- mse(cancer_reg_test$target_deathrate_count,
                   scaled_poisson_cancer %>%
                     predict(cancer_reg_test, type = "response"))
  

mse_log_test <- mse(cancer_reg_test$target_deathrate_count, 
                    Log_cancer %>%
                      predict(cancer_reg_test, 
                              type = "response")*100000)
  

mse_ram_inc_test <-  mse(cancer_reg_test$target_deathrate, 
                         ML_state %>%
                           predict(cancer_reg_test))
  




tibble(models = c("Multiple_Linear_Regression", "Scaled_poisson_regression", 
                  "Logistics_Regression","Multilevel Regression - Random Intercept"),
  MSE = c(mse_ml_test, mse_sp_test, mse_log_test, mse_ram_inc_test)) %>%
  pander()
knitr::include_graphics("graph/States.png")
knitr::include_graphics("graph/NY_CA.png")

#deathrate in NY and CA
cancer_reg %>%
  filter(state == "New York" | state == "California") %>%
  select(state, county, target_deathrate) %>%
  arrange(desc(target_deathrate))
regfit_cancer %>%
  pander()
AER::dispersiontest(poisson_cancer)
  
scaled_poisson_cancer %>%
  pander()
Log_cancer %>%
  pander()
jtools::summ(ML_state,pvals = T)
## NA
