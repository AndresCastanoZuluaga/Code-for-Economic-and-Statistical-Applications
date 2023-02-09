* AEM 6700 Economics of Consumer Demand
* Aug 29, Monday
* Blueberry Demand

clear
* Setting workin directory
  cd "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/Blueberry Demand" 
* Save log file
  log using BlueberryDemand.log, replace
* Import data from excel into Stata
  import excel BBDATA.xlsx, sheet("Sheet1") firstrow
	
	
** Data Cleaning
  * Rename variables
    rename YEAR year
    rename CPIFORALLITEMS20141 cpi
    rename INFLATIONADJUSTEDGDP gdp
    rename REALBLUEBERRYPRICECENTSLB bbp
    rename USPOPULATIONINMILLIONS pop
    rename GENERICBLUEBERRYPROMOTIONEXPE prom
    rename PERCAPITABBCONSUMPTIONOUNCES cons
    rename NOMINALRASPBERRYPRICECENTSLB rsp_n 
    rename NOMINALSTRAWBERRYPRICECENTSL stp_n
  * Generate real(inflation adjusted) prices
    *gen bbp = bbp_n * cpi
    *label variable bbp "REAL BLUEBERRY PRICE CENTS/LB"
    gen rsp = rsp_n / cpi
    label variable rsp "REAL RASPBERRY PRICE CENTS/LB"
	gen stp = stp_n / cpi
    label variable stp "REAL STRAWBERRY PRICE CENTS/LB"
  * Generate per capita income 
    gen inc = gdp/pop
    lab variable inc "PER CAPITA INCOME, REAL, 1,000$"
  * Convert year from string variable to numerical variable
    destring year, replace
  * Declare data to be time-series data to use lag operator
    tsset year
  * Generate log value of dependent and independent variabls to calculate elasticity
    gen lnbbp = log(bbp)
    gen lnprom = log(prom)
    gen lncons = log(cons)
    gen lnconsl = log(L.cons)
    gen lnrsp = log(rsp)
    gen lnstp = log(stp)
    gen lninc = log(inc)

** Run regression on log vars
	reg lncons lnconsl lnbbp lnrsp lnstp lninc lnprom
	estat durbinalt
log close
