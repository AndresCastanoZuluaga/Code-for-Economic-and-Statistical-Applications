/*practice to understand the marginal effects*/
/*Cornell Server directory*/
*cd "\\tsclient\Andres\Dropbox\CORNELL\Spring 2017\BTRY 6020 Statistical Methods II\Homework\HW4"
/*MacBook pro directory*/
cd "/Users/Andres/Dropbox/CORNELL/Spring 2017/BTRY 6020 Statistical Methods II/Homework/HW5"
insheet using "Hwk5Q3DatSp17.txt", clear
**************************
/*Run Poisson Regression*/
**************************
poisson numcases cigsperday years

/* 
In general:
marginal effect for a continuos variable in poisson regression = exp(xB)*Bj
Then Average marginal effect is summ_{i} {(exp(xiB)*Bj)}. But how this calculation is computed depent in which value of x we want to start
*/

*********************************
/*AME«s variety of calculations*/
*********************************

/*AMEs - Average marginal effect = (1/n)*summ_{i} {(exp(xiB)*Bj)};  
where xiB is calculated at the respective value of the explanatory variabl*/
margins, dydx(cigsperday)
margins, dydx(years)
/*AME«s as Semielasticities d(log(E(y|x))/d(x)*/
margins, eydx(cigsperday)
margins, eydx(years)
/*AME«s as semielasticities d(E(y|x))/d(lnx)*/
margins, dyex(cigsperday)
margins, dyex(years)
/*AME«s as elasticities d(log(E(y|x))/d(log(x))*/
margins, eyex(cigsperday)
margins, eyex(years)


*********************************
/*MEM«s variety of calculations*/
*********************************


/*MEMs - Marginal effect at means, where E(y|x) is evaluated at mean of the explanatory variables*/
margins, dydx(cigsperday) atmeans
margins, dydx(years) atmeans
/*MEM«s as Semielasticities d(log(E(y|x))/d(x)*/
margins, eydx(cigsperday) atmeans
margins, eydx(years) atmeans
/*MEM«s as semielasticities d(E(y|x))/d(lnx)*/
margins, dyex(cigsperday) atmeans
margins, dyex(years) atmeans
/*MEM«s as elasticities d(log(E(y|x))/d(log(x))*/
margins, eyex(cigsperday) atmeans
margins, eyex(years) atmeans



/*Save dataset in Stata format*/
save "Hwk5Q3DatSp17.dta", replace


