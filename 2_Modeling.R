# Author: Felix Zurek (@felixzurek)
library(tidyverse)
library(mgcv)

df <-  read_csv('data_draft.csv') %>%
  filter(!is.na(age),!is.na(av),!is.na(av_five)) %>%
  filter(av >= 0) %>% 
  mutate(QB = position == "QB") 
summary(df)

# Models

model_age <- mgcv::gam(av_five ~ s(pick, k = 20) + s(age, k = 10),
                       family = 'nb',
                       data = df,
                       method = "REML")

model_qb <- mgcv::gam(av_five ~ s(pick) + age * QB,
                      family = "nb",
                      data = df,
                      method = "REML")