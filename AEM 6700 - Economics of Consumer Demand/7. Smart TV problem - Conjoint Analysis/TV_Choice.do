** In Class Activity: TV
** Nov 7, 2016

clear
cd "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/7. Conjoin analysis - Smart tvs"
*log using TV_choices.log, replace
import delimited TV_Choices_data.csv
save TV_Choices_raw, replace

use TV_Choices_raw, clear

* Add var to indicate obs#
  gen obs = _n
  order obs id
* Add var Question#
  gen question = obs - 12*(id-1)
  order obs id question 
* Add Dummies for var choice
  gen choice1 = 0
  replace choice1 = 1 if choice == 1
  gen choice2 = 0
  replace choice2 = 1 if choice == 2  
  gen choice3 = 0
  replace choice3 = 1 if choice == 3
  order obs id question choice*
  drop choice

* Reshape data from wide to long
  reshape long choice smarttv s_screen threed s_price,i(obs) j(option)

* Generate dummies for variable "s_screen" and "s_price"
  tabulate s_screen, generate(s)
  rename s1 s30
  rename s2 s40
  rename s3 s50
  
  tabulate s_price, generate(p)
  rename p1 p400
  rename p2 p500
  rename p3 p600

rename smarttv samsung  
drop s_screen s_price
save TV_Choices_reshape, replace  

* Import Demographic data
  clear
  import delimited TV_Choices_demographics.csv
  save TV_Choices_demo, replace

* Merge demographic data with TV choice data
  merge 1:m id using TV_Choices_reshape
  sort obs id option
  order q*, last
  order obs id question option 
  
  drop obs _merge
  save TV_Choices_clean, replace
  
* (randome-effects)Logit model  
  xtset id
  xtlogit choice i.samsung i.threed i.s40 i.s50 i.p500 i.p600
  margins, dydx(*)
  predict prob

*log close
