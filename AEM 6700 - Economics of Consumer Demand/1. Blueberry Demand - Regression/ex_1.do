/*clear all*/
insheet using "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/1/DATA_EX1.txt", clear
gen time=0
replace time=0 if year<=2001
replace time=1 if year>2001
/*INITIAL GRAPHS*/
twoway scatter pp_bb_com prom_exp 
twoway scatter pp_bb_com pop 
twoway scatter pp_bb_com rbp 
twoway scatter pp_bb_com ia_gdp 
twoway scatter pp_bb_com cpi pp_bb_com 
twoway scatter pp_bb_com n_ras n_stra
twoway line  pp_bb_com year
/*REGRESSION*/
regress pp_bb_com prom_exp pop rbp ia_gdp cpi n_ras n_stra
regress pp_bb_com prom_exp pop rbp ia_gdp cpi n_ras n_stra i.time 

