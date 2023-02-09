/*AIDS ESTIMATION USING THE QUAIDS COMMAND*/

* AEM 6700
* Meat Demand (AIDS Model)

clear
set more off
* Setting working directory
    cd "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/Meat Demand" 
* Log file
  *log using MeatAIDS_Restricted.log, replace
  
* Import data
  import excel using "MeatAIDSData.xlsx", sheet("meat") firstrow
  save AIDSMeats, replace
  
* Generate quarter index  
  gen yrqtr = yq(year, qtr)
  format yrqtr %tq
  order yrqtr, a(qtr)
  tsset yrqtr
  
* Generate real prices  
  gen beef_pr = beef_p/cpi
  gen pork_pr = pork_p/cpi
  gen chick_pr = chick_p/cpi
  gen turkey_pr = turkey_p/cpi
  
* Calcuate total expenditures on all meats (X) and shares of each meat
  gen ex_beef = beef_pr*beef_q
  gen ex_pork = pork_pr*pork_q
  gen ex_chick = chick_pr*chick_q
  gen ex_turkey = turkey_pr*turkey_q
  gen X = ex_beef + ex_pork + ex_chick + ex_turkey  
  
  gen w_beef = ex_beef/X     // share of beef
  gen w_pork = ex_pork/X     // share of pork
  gen w_chick = ex_chick/X   // share of chick
  gen w_turkey = ex_turkey/X // share of turkey
  
  * Plot budget shares  
    twoway (connected w_beef yrqtr) (connected w_pork yrqtr) ///
           (connected w_chick yrqtr) (connected w_turkey yrqtr)
    graph export BudgetShares.png, replace
  
* Generate logged values
  gen lnX  = log(X)	
  gen lnpb = log(beef_pr)
  gen lnpp = log(pork_pr)
  gen lnpc = log(chick_pr)
  gen lnpt = log(turkey_pr)
  gen lnP  = w_beef*lnpb + w_pork*lnpp + w_chick*lnpc + w_turkey*lnpt
  gen lnXP = lnX - lnP
  
    sum w_beef
	scalar w_b = r(mean)
	sum w_pork
	scalar w_p = r(mean)
	sum w_chick
	scalar w_c = r(mean)
    sum w_turkey
	scalar w_t = r(mean)
	matrix w = [w_b\ w_p\ w_c\ w_t]
	matrix rownames w = beef, pork, chick, turkey
	matrix colnames w = ExpShare
	matrix list w
  
* ESTIMATING THE AIDS SYSTEM USING THE QUAIDS COMMAND

quaids  w_beef w_pork w_chick w_turkey, anot(0.1) lnprices(lnpb lnpp lnpc lnpt) lnexpenditure(lnX)   

aidsills w_beef w_pork w_chick w_turkey, prices(beef_pr pork_pr chick_pr turkey_pr) expenditure(X) alpha_0(0)
aidsills_elas in w_beef



  
