/*practice to understand the marginal effects*/
/*Cornell Server directory*/
*cd "\\tsclient\Andres\Dropbox\CORNELL\Spring 2017\BTRY 6020 Statistical Methods II\Homework\HW4"
/*MacBook pro directory*/
cd "/Users/Andres/Dropbox/CORNELL/Spring 2017/BTRY 6020 Statistical Methods II/Homework/HW4"
insheet using "Hwk4Q2DatSp17.txt", clear
/*run logit*/
logit taskcomp emotscore, 
/* marginal effect for a continuos variable is: 
(delta prob(yi | x) / delta xj)= (prob_hat(yi|x)) * (1-prob_hat(yi|x))*bj
Usually what stata does is evalute the derivative in the mean of the prob_obs(yi|xj) and then report 
the marginal effect, for instance:
*/

/*
MEMs - Marginal effect at means = bj*(pi)*(1-pi) where pi is evaluated at mean of the explanatory variables
*/
margins, dydx(emotscore) atmeans

/*
AMEs - Average marginal effect = (summ_{i} {(bj)*(pi_i)*(1-pi_i)})/n;  where pi is calculated at the respective value of the explanatory variable
*/
margins, dydx(emotscore)
/*Save the data set*/
save "Hwk4Q2DatSp17.dta", replace






/*PRUEBA LOGIT REGRESSION WITH TWO COMMANDS "logit" AND "logistic"*/

sysuse auto, clear 
/*with logistic, show the coefficients as odds ratios (odds in favor of p(yi=1|X) compared to p(yi=0|X), 
to get the log of odds ratio, you need to take the natural log of the coefficients ln(bj)*/
logistic foreign mpg turn
/*with logit the coefficients are shown as log(odds ratio), to the the odds ratio you need to exponentiate the coefficients EXP(bj)*/
logit foreign mpg turn


/*PRUEBA*/
webuse margex, clear
probit outcome age distance
margins, dydx(age) at(distance=(0(100)800))
marginsplot

