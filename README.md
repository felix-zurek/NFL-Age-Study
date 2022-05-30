# **Why Drafting Younger Is Better**

This study is inspired by [this](https://fivethirtyeight.com/features/age-played-a-bigger-role-in-the-nfl-draft-its-about-time/)
great article on age in the NFL Draft by [Michael Salfino](https://twitter.com/MichaelSalfino) from FiveThirtyEight.

### Motivation

While the study from Salfino is great it certainly has its flaws.
One is the use of discrete age buckets as players with the same age can
almost have a year of age distance between them.
For an example one can look at the following three players:
Derek Stingley Jr. and Trent McDuffie both will be 21 on September 1st in contrary to 
Sauce Gardner who will be 22. But this is misleading as McDuffie is 280 days
older than Stingley while Gardner who turns 22 exactly on September 1st is only 12
days older than McDuffie.\
For this reason I considered age on a continuous scale with two digits after the decimal point.
Going back to our example we get that Stingley is 21.20, McDuffie is 21.97 and Sauce is 22.00 years old.
No we can easily see that McDuffie and Sauce are almost the same age while Stingley
is almost year younger than both of them.\
Another problem is the use of CarAV (Career Approximated Value by 
[pro-football-reference.com](https://pro-football-reference.com)).
One argument one often hears against taking younger players is while they might
have better careers the older more experienced players perform better on their rookie
deals where they create the most surplus value.
So we will only consider the AV a player accumulates over their first five career years.\
And a final problem is the correlation between age and draft postion.
Most players declare for the NFL Draft once they are considered a top-talent in the upcoming
draft while players who are not often decide to stay a year in the college ranks to
improve their draft stock. So better players declare earlier as worse ones and so draft
position may be a confounding variable, i.e. when measuring that younger players
perform better we might just end up measuring that higher picked players
perform better than later picked players which would not be groundbreaking analysis.
![correlation](plot_pick_age_cor.png?raw=true)


### Methodology

In the following we want to perform a regression to estimate the expected AV in
the first five years based on age and draft position of a player.\
A short look at the distribution of the AV variable shows us that the outcome variable
is not normally distributed so we can not use normal regression but need to turn
to a [Generalized Linear Model](https://en.wikipedia.org/wiki/Generalized_linear_model).\
<img src="plot_av_density.png?raw=true">
More precisely we use a generalized additive model which leads us to the following
assumption:
$$ AV \sim \text{Pois}\Big(\exp\big[\beta_0 + f_1(pick) + f_2(age)\big]\Big)$$
(We actually use a quasi-poisson model as the AV is overdispersed.)\
This can be rewritten into the following model:
$$ AV \sim \text{Pois}\Big(\tilde{\beta_0} \times \tilde{f_1}(pick) \times \tilde{f_2}(age)\Big) \text{, with} $$ 
$$\tilde{\beta_0} = exp(\beta_0),\ \tilde{f_1} = exp(f_1),\ \tilde{f_2} = exp(f_2)$$
In the following we will focus on $\tilde{f_2}(age)$.

### Analysis

Estimating the functions we find that both draft position and age are
highly significant $\left(p < 10^{-15}\right)$ and we get the following age curve:
<img src="plot_f_age.png?raw=true" >
This graph can be read as follows:\
If two players are drafted at the same spot in the draft with player A being
21.0 years old while player B is 23.03 years old (the average age of a NFL Draftee)
we expect player A to accumulate 126.5% of the AV that we expect of player B.
Similarly we expect that a player C who is 25.5 will earn only
72.3% of that player B. That means that player A's expectation of AV is 
126.5% / 0.723% = 174.9% of the expectation of player C.
But what about the most important position in football, what about quarterbacks ?\
Fitting the model with linear age parameter we get that quarterbacks neither
have a significant main effect (p = 0.585) nor a significant interaction with age
(p = 0.561) in other words age has no significant effect on the draft success of
quarterbacks.

### Problems

One flaw of this study is the use of Approximate Value. While it is almost certainly
the best openly available data we have on Draft Success it has many flaws,
especially when it comes to evaluating offensive line or running back play.
Part of the problem when looking at quarterbacks is that our sample size gets
quite small (n = 202) especially as AV is quite noisy.
(Blake Bortles accumulated an AV of 48 in his first five year 
which is better than Matthew Stafford who earned 47.)

### Conclusion

This study suggest that age does indeed play a role independent of draft
position when predicting the success of draftees during their rookie contract
window. So drafting younger is better as not only get you better players but
you also expect more prime years out of these players. 




