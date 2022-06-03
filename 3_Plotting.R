# Author: Felix Zurek (@felixzurek)
library(tidyverse)
library(mgcv)

source('2_Modeling.R', echo = FALSE, print.eval = FALSE)

# Model Analysis

summary(model_age)
mgcv::gam.check(model_age, rep = 500, old.style = FALSE)
summary(model_qb)

par(mfrow=c(2,2))
plot(model_age)
plot(model_qb)
par(mfrow=c(1,1))

# Plots

get_smooths <- function(model){
  plotdata <- visreg::visreg(model, type = "contrast", plot = FALSE)
  
  smooths <- plyr::ldply(plotdata, function(part)
    tibble(Variable = part$meta$x, 
           x=part$fit[[part$meta$x]], 
           smooth=part$fit$visregFit, 
           lower=part$fit$visregLwr, 
           upper=part$fit$visregUpr))
  return(smooths)
}

smooths <- get_smooths(model_age)

p_age <- smooths %>% as_tibble() %>%
  filter(Variable == "age") %>% 
  ggplot(aes(x, exp(smooth)))+
  geom_ribbon(aes(ymin = exp(lower), ymax = exp(upper)), fill = "grey", alpha = .25)+
  geom_line(size = 1.75, color = 'darkorange')+
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     breaks = seq(0,2, by = .1)
                     )+
  scale_x_continuous(breaks = 20:28,
                     #minor_breaks = NULL
                     )+
  coord_cartesian(xlim = c(21,27),
                  ylim = c(.45,1.5))+
  labs(x = 'Age', y = 'Expected AV (as Percentage of the Mean)',
       title = 'Younger Draft Prospects Perform Better Than Older Ones',
       subtitle = str_c('NFL Drafts 2000-2017',
                        "AV = Approximate Value over a player's first five years",
                        'Independent of Draft Position',
                        sep = ' | '),
       caption = 'by @felixzurek | Data: pro-football-reference.com')+
  theme_minimal(base_size = 14)+
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title = element_text(face = "bold"))

ggsave('plots/plot_f_age.png', p_age,
       width = 12, height = 9, bg = "white", dpi = 200)


p_cor <- ggplot(df, aes(x = pick, y = age))+
  geom_point()+
  geom_smooth(method = "lm", size = 1.5, color = "darkorange", se = FALSE)+
  labs(title = "Draft Position and Age are Correlated",
       subtitle = "NFL Drafts 2000-2017 | Ages as of September 1st",
       x = "Pick",
       y = "Age",
       caption = "by @felixzurek | Data: pro-football-reference.com")+
  annotate(geom = "label", x = 250, y = 23,
           label = "R^2 = 0.05",
           color = "darkorange",
           fontface = "bold")+
  theme_minimal(base_size = 14)+
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title = element_text(face = "bold"))
ggsave("plots/plot_pick_age_cor.png",p_cor ,width = 12, height = 9, bg = "white", dpi = 200)

p_density <- ggplot(df, aes(x = av_five))+
  geom_histogram(aes(y = after_stat(density)),size = 1, color = "black", binwidth = 1)+
  theme_minimal(base_size = 14)+
  labs(title = "The AV Variable is Not Gaussian Distributed",
       x = "AV", y = "Relative Frequency",
       caption = "by @felixzurek | Data: pro-football-reference.com")+
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title = element_text(face = "bold"))
ggsave("plots/plot_av_density.png", p_density, width = 12, height = 9, bg = "white", dpi = 200)
