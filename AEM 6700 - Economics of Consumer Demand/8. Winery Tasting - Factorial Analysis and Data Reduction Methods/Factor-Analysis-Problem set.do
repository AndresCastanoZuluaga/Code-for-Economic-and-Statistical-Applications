
/* 
MODIFIED CODE FINGERLAKES WINERIES ANALYSIS
MODIFIED BY: ANDRES CASTANO
AEM 6700
DECEMBER 4, 2016
*/


********************************
/*PART 1: LOADING THE DATABASE*/
********************************
clear all
cd "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery"
import delimited "Winary_tasting_scores.csv"
save Winery_tasting_scores, replace

**********************************
/*PART 2: DESCRIPTIVE STATISTICS*/
**********************************

tab overall_cs
tab purchase
tab come_back
summ bottles
summ dollars

************************************************************************
/*PART 3: PERFORMING THE FACTOR ANALYSIS 
(SELECTING APRIORI 5 FACTORS AND USING THE PRINCIPAL COMPONENT METHOD*/
************************************************************************
*factor q1-q19 q21-q25, pcf /*exercise without forcing the number of factors, the outcome in some sense give an idea that we need to consider more factors, q20 was deleted from the instrument*/
factor q1-q19 q21-q25, factors(5) pcf /*exercise keeping 5 factors*/
rotate
estat kmo

*************************************************************************************
/*PART 4: CREATING THE FACTOR VARIABLES, THIS RESULTS ARE BASE ON THE INTERPRETATION 
OF THE FACTOR LOADINGs AFTER RUNNING THE VARIMAX ROTATION*/
*************************************************************************************
generate facility = (q1+q2+q3+q4+q5)/5
generate retail = (q13+q14+q15+q16+q17+q19+q21)/7
generate tasting = (q22+q23+q24+q25)/4
generate service = (q6+q7+q8+q18)/4
generate tasting_prot = (q9+q10+q11+q12)/4


******************************
/*PART 5: REGRESSION RESULTS*/
******************************

/*PART 5.1: IDENTIFYING THE IMPACT OF THE FACTORS ON THE OVERALL CONSUMER SATISFACTION*/
reg overall_cs facility retail tasting service tasting_prot

/*PART 5.2: IDENTIFYING THE IMPACT ON SALES AS A FUNCTION OF OVERALL CONSUMER SATISFACTION AND DEMOGRAPHIC CHARACTERISTICS*/

/*5.2.1: FACTORS AFECTING THE DESICION OF PURCHASE. PURCHASE=1 IF YES, ZERO OTHERWISE*/
logit purchase overall_cs i.female i.age_group i.education
margins, dydx(*)
margins, at(overall_cs=(1(1)5)) /*this is Average Marginal Effects (AME), do not confuse with Marginal Effects at means (MEM)*/
marginsplot, xlabel(2(1)5) play(homework4-aem6700)
graph save Graph "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/purchase-impact.gph", replace
graph export "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/purchase-impact.png", as(png)  replace
/*elasticities*/
margins, eyex(*)

/* 5.2.2: FACTORS AFECTING THE DESICION TO COMING BACK*/
logit come_back overall_cs i.female i.age_group i.education
margins, dydx(*)
margins, at(overall_cs=(1(1)5))
marginsplot, xlabel(2(1)5) play(homework4-aem6700)
graph save Graph "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/re-purchase-impact.gph", replace
graph export "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/re-purchase-impact.png", as(png)  replace
/*elasticities*/
margins, eyex(*)


/*5.2.3: FACTORS AFECTING THE NUMBER OF BOTTLES PURCHASED*/
regress bottles overall_cs i.female i.age_group i.education
margins, at(overall_cs=(1(1)5))  
marginsplot, xlabel(2(1)5) play(homework4-aem6700)
graph save Graph "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/numberofbottles-impact.gph", replace
graph export "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/numberofbottles-impact.png", as(png)  replace


/*5.2.4: FACTORS AFECTING THE AMOUNT OF MONEY SPENT*/
regress dollars overall_cs i.female i.age_group i.education
margins, at(overall_cs=(2(1)5))
marginsplot, xlabel(2(1)5) play(homework4-aem6700)
graph save Graph "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/moneyspent-impact.gph", replace
graph export "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/8. Factorial analysis - Winery/moneyspent-impact.png", as(png)  replace







