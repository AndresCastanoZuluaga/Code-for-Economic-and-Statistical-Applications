** Simple Logit 
** Restaurant Example
** Reference: page 1093-1095 of the -logit- manual (Example2: Predictive margins)

clear
cd "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/5. Logit - Predicting Low Weight"
log using logit_result.log, replace

* Data
  use logit_example, clear

* Run a logit model predicting low birthweight from characteristics of the mother 
  logit low age i.race i.smoke ptl i.ht i.ui
  /*
  The coefficients are log odds-ratios: conditional on the other predictors, 
  smoking during pregnancy is associated with an increase of 0.96 in the log 
  odds-ratios of low birthweight. The model is linear in the log odds-scale, 
  so the estimate of 0.96 has the same interpretation, whatever the values of
  the other predictors might be. We could convert 0.96 to an odds ratio by 
  replaying the results with -logit, or-.

  But what if we want to talk about the probability of low birthweight, and not 
  the odds? Then we will need the command -margins, contrast-. We will use the 
  -r.- contrast operator to compare each level of smoke with a reference level. 
  (smoke has only two levels, so there will be only one comparison: a comparison 
  of smokers with nonsmokers.)
  */

* Predictive Margins  
  margins r.smoke, contrast
  /*
  We see that maternal smoking is associated with an 18.3% increase in the 
  probability of low birthweight. (We received a contrast in the probability scale
  because predicted probabilities are the default when margins is used after logit.)

  The contrast of 18.3% is a difference of margins that are computed by averaging 
  over the predictions for observations in the estimation sample. If the values of
  the other predictors were different, the contrast for smoke would be different, 
  too. Let¡¯s estimate the contrast for 25-year-old mothers:
  */ 
 
  margins r.smoke, contrast at(age=25)
  /*
  Specifying a maternal age of 25 changed the contrast to 18.1%. Our contrast of 
  probabilities changed because the -logit- model is nonlinear in the probability 
  scale. A contrast of log odds-ratios would not have changed.
  */  
  
log close
