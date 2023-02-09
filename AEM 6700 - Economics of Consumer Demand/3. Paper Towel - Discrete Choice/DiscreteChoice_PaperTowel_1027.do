** AEM 6700
** Paper Towel: Discrete Choice Model
** Oct 27, 2016

clear
cd "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/3. Paper Towel"
*log using PaperTowel_results.log, replace
import delimited Paper_Towel_500Samples.csv
save PaperTowel_raw, replace

** Data Cleaning
   use PaperTowel_raw, clear
   /*  choice brand     color
       1      Kimberly  print
	   2      Kimberly  white
	   3      Kimberly  assorte
	   4      Koch      print
	   5      Koch      white
	   6      OutsideGoods    */
 * summarize data  
   sum d* price* // no variation in d2 & d5: all d2 = 0 and all d5 = 1
   drop d2 d5
 * save data  
   save PaperTowel, replace
   
** Simple Logit Model: choice between brand "Kimberly" and "Koch"
 * generate binary dependent variable choice_brand 
   use PaperTowel, clear
   gen choice_brand = 1
   replace choice_brand = 0 if choice == 4 | choice == 5
   replace choice_brand = . if choice == 6
   label variable choice_brand "0 if Koch, 1 if Kimberly"
 
 * Run logit model
   * comapre choice between the two brand for the color "print"
     logit choice_brand price1 price4 d1 d4 if choice == 1 | choice == 4 /* */
     predict p1
	 sum p1
     * Marginal Effects
       margins, dydx(*)
     * Elasticities 
       margins, eyex(*)	 
   * comapre choice between the two brand for the color "white"
     logit choice_brand price2 price5 if choice == 2 | choice == 5
	 predict p2
	 sum p2
     * Marginal Effects
       margins, dydx(*)
     * Elasticities 
       margins, eyex(*)	
 
** Multinomial Logit  
   mlogit choice price* d*
   predict pm1, outcome(1)
   sum pm1
   predict pm2, outcome(2)
   sum pm2
   predict pm3, outcome(3)
   sum pm3
   predict pm4, outcome(4)
   sum pm4
   predict pm5, outcome(5)
   sum pm5   
   * Marginal Effects
     margins, dydx(*) predict(outcome(1))
     margins, dydx(*) predict(outcome(2))
     margins, dydx(*) predict(outcome(3))
     margins, dydx(*) predict(outcome(4))
     margins, dydx(*) predict(outcome(5))   
	 
   * Elasticities 
     margins, eyex(*) predict(outcome(1))
     margins, eyex(*) predict(outcome(2))
     margins, eyex(*) predict(outcome(3))
     margins, eyex(*) predict(outcome(4))
     margins, eyex(*) predict(outcome(5))   

*log close	 
