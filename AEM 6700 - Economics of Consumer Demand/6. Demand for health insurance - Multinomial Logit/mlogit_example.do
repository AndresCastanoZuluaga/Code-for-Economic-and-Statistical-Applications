** Multinomial Logit 
** Health Insurance Example
** Reference: page 1358-1360 (Example 1), 1371-1377 of the -mlogit- manual 

clear
cd "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/6. Multinomial logit - demand for health insurance"
*log using mlogit_result.log, replace

* Data 
  use mlogit_example, clear
  /*
  We have data on the type of health insurance available to 616 psychologically 
  depressed subjects in the United States (Tarlov et al. 1989; Wells et al. 1989). 
  The insurance is categorized as either an indemnity plan (that is, regular 
  fee-for-service insurance, which may have a deductible or coinsurance rate) or 
  a prepaid plan (a fixed up-front payment allowing subsequent unlimited use as 
  provided, for instance, by an HMO). The third possibility is that the subject 
  has no insurance whatsoever. We wish to explore the demographic factors 
  associated with each subject¡¯s insurance choice. One of the demographic factors 
  in our data is the race of the participant, coded as white or nonwhite.
  */

  tabulate insure nonwhite, chi2 col


* Run the mlogit model  
  mlogit insure nonwhite
  mlogit insure age i.male i.nonwhite i.site


* Predicted Probabilities  
  /*
  Continuing with our previously fit insurance-choice model, we wish to describe 
  the model¡¯s predictions by race. For this purpose, we can use the method of 
  predictive margins (also known as recycled predictions), in which we vary 
  characteristics of interest across the whole dataset and average the predictions. 
  That is, we have data on both whites and nonwhites, and our individuals have 
  other characteristics as well. We will first pretend that all the people in our 
  data are white but hold their other characteristics constant. We then calculate 
  the probabilities of each outcome. Next we will pretend that all the people in 
  our data are nonwhite, still holding their other characteristics constant. 
  Again we calculate the probabilities of each outcome. The difference in those 
  two sets of calculated probabilities, then, is the difference due to race, 
  holding other characteristics constant.
  */

  gen byte nonwhold=nonwhite // save real race
  replace nonwhite=0 // make everyone white
  predict wpind, outcome(Indemnity) // predict probabilities
  predict wpp, outcome(Prepaid)
  predict wpnoi, outcome(Uninsure)
  replace nonwhite=1 // make everyone nonwhite
  predict nwpind, outcome(Indemnity)
  predict nwpp, outcome(Prepaid)
  predict nwpnoi, outcome(Uninsure)
  replace nonwhite=nonwhold // restore real race
  summarize wp* nwp*, sep(3)


* Predictive Margins
  /*
  Computing predictive margins by hand was instructive, but we can compute these 
  values more easily using the margins command (see [R] margins). The two margins 
  for the indemnity outcome can be estimated by typing
  */
  margins nonwhite, predict(outcome(Indemnity)) noesample
  marginsplot
  margins nonwhite, predict(outcome(Prepaid)) noesample
  margins nonwhite, predict(outcome(Uninsure)) noesample


* Marginal Effects
  margins, dydx(*) predict(outcome(Indemnity)) //Average marginal effects
  margins, dydx(*) predict(outcome(Prepaid))
  margins, dydx(*) predict(outcome(Uninsure))
  
log close
