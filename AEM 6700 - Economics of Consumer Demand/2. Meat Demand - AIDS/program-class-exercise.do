clear all 
insheet using "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/Meat Demand/MeatAIDSData.txt"
/*1. adjust for inflation */
local vars = "beef_q pork_q chick_q turkey_q"
foreach j of local vars {
gen r_`j'=(`j'/cpi) 
}
gen time_aq=yq(year,qtr)
/*2. make some plots with different relations between variables, tendencies*/
graph ts line 

line r_beef_q time_aq   || line r_pork_q time_aq  || line  r_turkey_q   time_aq  || line r_chick_q    time_aq

		  
 

/*3. make some descriptive statistics*/

/*4. It is important to note if there is a seasonality in compsumption*/

/*5. transform de varibles Into logs */





insheet using ""



