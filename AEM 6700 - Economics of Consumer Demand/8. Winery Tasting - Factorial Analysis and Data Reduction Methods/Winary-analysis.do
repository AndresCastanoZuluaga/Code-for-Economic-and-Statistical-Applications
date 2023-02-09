/*CONSUMER SATISFACTION AND SALES PERFORMANCE IN WINERY */


/*LOADING THE DATABASE*/
cd "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery"
insheet using "Winary_tasting_scores.txt", clear

/*QUESTION TO ADDRESS

1. WHAT ARE THE DRIVER OF CUSTOMER SATISFACTION
2. WHAT IS THE INFLUENCE OF THIS DRIVERS ON OVERALL CUSTOMER SATISFACTION
3. WHAT IS THE IMPACT OF CUSTOMER SATISFACTION ON SALES PERFORMANCE*/


/*DESCRIPTIVE STATISTICS*/

tab overall_cs
tab purchase
tab come_back
summ bottles
summ dollars

/*FACTOR ANALYSIS*/
factor q1-q25, factors(5) pcf
factor q1-q25, pcf

/*FACTORS AFFECTING THE DESICION TO PURCHASE*/
logit purchase overall_cs female age_group education
margins, dydx(*)
margins, at(overall_cs=(2(1)5))
marginsplot, xlabel(2(1)5) play(homework4-aem6700)
graph save Graph "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/purchase-impact.gph", replace
graph export "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/purchase-impact.png", as(png)  replace
/*elasticities*/
margins, eyex(*)


/*FACTORS AFFECTING THE DECISION TO REPURCHASE*/
logit come_back overall_cs female age_group education
margins, dydx(*)
margins, at(overall_cs=(2(1)5))
marginsplot, xlabel(2(1)5) play(homework4-aem6700)
graph save Graph "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/re-purchase-impact.gph", replace
graph export "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/re-purchase-impact.png", as(png)  replace
/*elasticities*/
margins, eyex(*)


/*FACTORS AFFECTING THE AMOUNT OF MONEY SPENT*/
regress dollars overall_cs i.female i.age_group i.education

/*FACTORS AFFECTING THE NUMBER OF BOTTLES PURCHASED*/
regress bottles overall_cs i.female i.age_group i.education
