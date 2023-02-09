/*PAPER TOWEL EXERCISE*/
clear all
cd "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/Paper Towel" 
insheet using "Paper_Towel_500Samples.txt"
/*binary choice variable*/
gen binary_choice=0
replace binary_choice= 1 if choice==1 | choice==2 | choice==3 | choice==4| choice==5
tab binary_choice
tab 
/* price vs. display*/
graph box price1, over(d1)
graph box price2, over(d2) 
graph box price3, over(d3) 
graph box price4, over(d4) 
graph box price5, over(d5) 
/*price vs color*/
graph box price1, over(color1)
graph box price2, over(color2) 
graph box price3, over(color3) 
graph box price4, over(color4) 
graph box price5, over(color5)  
 

bysort choice: egen mean_price1=mean(price1)
bysort choice: egen mean_price2=mean(price2) 
bysort choice: egen mean_price3=mean(price3) 
bysort choice: egen mean_price4=mean(price4) 
bysort choice: egen mean_price5=mean(price5) 
 

bysort choice: summ price1
bysort choice: summ price2
bysort choice: summ price3
bysort choice: summ price4
bysort choice: summ price5

 
tab binary_choice 


