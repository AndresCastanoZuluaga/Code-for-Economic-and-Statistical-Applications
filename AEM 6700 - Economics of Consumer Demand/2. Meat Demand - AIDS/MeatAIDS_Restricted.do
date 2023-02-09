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

*-------------------------------------------------------------------------------
* ADIS, Rotterdam, and OLS Model (Without Seasonality) 
 
* Estimate AIDS: -nlsur- 
  nlsur (w_beef ={ab}+{bb}*lnXP+{gbb}*lnpb+{gbp}*lnpp+{gbc}*lnpc+(0-{gbb}-{gbp}-{gbc})*lnpt) ///
        (w_pork ={ap}+{bp}*lnXP+{gbp}*lnpb+{gpp}*lnpp+{gpc}*lnpc+(0-{gbp}-{gpp}-{gpc})*lnpt) ///
		(w_chick={ac}+{bc}*lnXP+{gbc}*lnpb+{gpc}*lnpp+{gcc}*lnpc+(0-{gbc}-{gpc}-{gcc})*lnpt), ///
        ifgnls 
		
  /* 
     Here 'ab' is short for alpha_beef, 'ap':alpha_pork, 'ac': alpha_chick
	      'bb' is short for beta_beef,  'bp':beta_pork,  'bc': beta_chick
	      'gbb':gamma_beef&beef, 'gbp':gamma_beef&pork, 'gbc':gamma_beef&chick
		  'gpp':gamma_pork&pork, 'gpc':gamma_pork&chick, 'gcc':gamma_chick&chick
		  
	 Although we have data for four meats, yet we fit only three euqations. 
     Because the four shares sum to one, we must drop one of the equations to 
	 avoid having a singular error covariance matrix. The (linearly restricted) 
	 parameters of the fourth equation can be obtained using the -lincom- 
	 command. 
	 
	 We imposed symmetry restrictions here by setting gbp=gpb, gbc=gcb, gcp=gpc
	 We also imposed HOD0 restrictions by letting gbt = 0 - gbb - gbp - gbc, 
	                                              gpt = 0 - gpb - gpp - gpc,
												  gct = 0 - gcb - gcp - gcc
  */
  
  * Calculate parameters of the fourth equation
    lincom 1 - [ab]_cons - [ap]_cons - [ac]_cons    //at HOD1
	lincom 0 - _b[/bb]  - _b[/bp]  - _b[/bc]        //bt HOD0  
	lincom 0 - _b[/gbb] - _b[/gbp] - _b[/gbc]       //gbt=gtb
    lincom 0 - _b[/gbp] - _b[/gpp] - _b[/gpc]       //gpt=gtp
    lincom 0 - _b[/gbc] - _b[/gpc] - _b[/gcc]       //gct=gtc
	lincom _b[/gbb]+_b[/gpp]+_b[/gcc]+2*_b[/gbp]+2*_b[/gbc]+2*_b[/gpc]    //gtt
	
  * Saving estimated coefficients as matrixs
    * alpha = [ab, ap, ac, at]
	  scalar at = 1 - [ab]_cons - [ap]_cons - [ac]_cons
	  matrix alpha = [[ab]_cons\ [ap]_cons\ [ac]_cons\ at]
	  matrix rownames alpha = beef, pork, chick, turkey
	  matrix colnames alpha = alpha
	  matrix list alpha
	  
	* beta = [bb, bp, bc, bt]
	  scalar bt = 0 - _b[/bb]  - _b[/bp]  - _b[/bc]
	  matrix beta = [_b[/bb]\ _b[/bp]\ _b[/bc]\ bt]
	  matrix rownames beta = beef, pork, chick, turkey
	  matrix colnames beta = beta
	  matrix list beta	 
	  
	* gamma = [gbb, gbp, gbc, gbt;
	*          gpb, gpp, gpc, gpt;
	*          gcb, gcp, gcc, gct;
	*          gtb, gtp, gtc, gtt]
	  scalar gbt = 0 - _b[/gbb] - _b[/gbp] - _b[/gbc]
	  scalar gpt = 0 - _b[/gbp] - _b[/gpp] - _b[/gpc]
	  scalar gct = 0 - _b[/gbc] - _b[/gpc] - _b[/gcc] 
	  scalar gtt = _b[/gbb]+_b[/gpp]+_b[/gcc]+2*_b[/gbp]+2*_b[/gbc]+2*_b[/gpc]
	  matrix gamma_b = [_b[/gbb], _b[/gbp], _b[/gbc], gbt]
	  matrix gamma_p = [_b[/gbp], _b[/gpp], _b[/gpc], gpt]
	  matrix gamma_c = [_b[/gbc], _b[/gpc], _b[/gcc], gct]
	  matrix gamma_t = [gbt, gpt, gct, gtt]	 
	  matrix gamma = [gamma_b\ gamma_p\ gamma_c\ gamma_t]
	  matrix rownames gamma = beef, pork, chick, turkey
	  matrix colnames gamma = gamma_beef, gamma_pork, gamma_chick, gamma_turkey
	  matrix list gamma
	
	* alpha, beta, gamma  
      matrix AIDS_Parameters = [alpha, beta, gamma]
	  matrix list AIDS_Parameters

  /* 
  The next step will be calculating uncompensated price elasticities and income
  elasticities, please refer to "Green and Alston (1990): Elasticities in AIDS
  Models" for the expression (Equation 11) to calculate elasticities.
  
  The expression for the uncompensated demand elasticities is in the form of 
  Equation 9) in Green & Alston (1990). You will need to solve system of 
  equations to get the elasticities. One way of solving it will be writing down 
  all 16 equations in excel and then use "solver" to solve for the elasticities.
  Another way is to write the system of equations in matrix form and use 
  Equation 11) in Green & Alston (1990) to solve the elasticity matrix, which
  is the method we will use in this do file.
  */	 
  
  * Create matrixs A B & C in Green & Alston (1990):
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
	
	sum lnpb
	scalar lnpb = r(mean)
	sum lnpp
	scalar lnpp = r(mean)
	sum lnpc
	scalar lnpc = r(mean)
	sum lnpt
	scalar lnpt = r(mean)	
	matrix lnP = [lnpb\ lnpp\ lnpc\ lnpt]
	matrix rownames lnP = beef, pork, chick, turkey
	matrix colnames lnP = LogPrice
	matrix list lnP
	
	matrix delta = I(4)
	
	matrix A = J(4,4,.)
	forvalues i = 1/4 {
	          forvalues j = 1/4 {
			            matrix A[`i',`j'] = - delta[`i',`j'] + /// 
						gamma[`i',`j']/w[`i',1] - beta[`i',1]*w[`j',1]/w[`i',1]
	        }
	}
    matrix list A
	
	matrix B = J(4,1,.)
	forvalues i = 1/4 {
			  matrix B[`i',1] = beta[`i',1]/w[`i',1]
	}
    matrix list B
	
	matrix C = J(1,4,.)
	forvalues j = 1/4 {
			  matrix C[1,`j'] = w[`j',1]*lnP[`j',1]
	}	
	matrix list C
  
  * Calculating compensated (Hicksian) price elasticities:
    matrix E_AIDS = inv(B*C+delta)*(A+delta)-delta // Equation 11 in Green & Alston (1990)
	matrix rownames E_AIDS = beef, pork, chick, turkey
	matrix colnames E_AIDS = beef, pork, chick, turkey	
	matrix list E_AIDS
	
  * Calculating expenditure (income) elasticities:
    matrix One = J(4,1,1)
	matrix IncE_AIDS = inv(delta+B*C)*B + One
	matrix rownames IncE_AIDS = beef, pork, chick, turkey
	matrix colnames IncE_AIDS = IncomeElasticities	
	matrix list IncE_AIDS
	
  * Calculating uncompenstated (Marshallian) price elasticities:
	matrix E_AIDS_Mar = J(4,4,.)
	forvalues i = 1/4 {
	          forvalues j = 1/4 {
			            matrix E_AIDS_Mar[`i',`j'] = E_AIDS[`i',`j'] + /// 
						(1 + beta[`i',1]*w[`j',1]) * w[`j',1]
	        }
	}
	matrix rownames E_AIDS_Mar = beef, pork, chick, turkey
	matrix colnames E_AIDS_Mar = beef, pork, chick, turkey	
    matrix list E_AIDS_Mar
 
  * There are other Stata packages which can estimate AIDS model more easily.
  * For example: check command -quaids- or -aidsills-. 

	
*-------------------------------------------------------------------------------
* OLS Model (Without Seasonality)  
  gen lnqb = log(beef_q)
  gen lnqp = log(pork_q)
  gen lnqc = log(chick_q)
  gen lnqt = log(turkey_q)
  reg lnqb lnpb lnpp lnpc lnpt
  matrix E_OLS_b=e(b)
  reg lnqp lnpb lnpp lnpc lnpt
  matrix E_OLS_p=e(b)  
  reg lnqc lnpb lnpp lnpc lnpt
  matrix E_OLS_c=e(b)  
  reg lnqt lnpb lnpp lnpc lnpt
  matrix E_OLS_t=e(b) 
  matrix E_OLS = [E_OLS_b\ E_OLS_p\ E_OLS_c\ E_OLS_t]
  matrix E_OLS = E_OLS[1..4,1..4]
  matrix rownames E_OLS = beef, pork, chick, turkey
  matrix colnames E_OLS = beef, pork, chick, turkey  


*-------------------------------------------------------------------------------
* Rotterdam Model (Without Seasonality)

* Estimation equation:  
* w_bar_it*D.lnq_it = sum_j(c_ij*D.lnp_jt) + b_i*(D.lnX_t- sum_j(w_bar_jt*D.lnp_jt)) 

* Generate w_bar_it
  gen w_bar_b = 0.5 * (w_beef   + L.w_beef)   //beef
  gen w_bar_p = 0.5 * (w_pork   + L.w_pork)   //pork
  gen w_bar_c = 0.5 * (w_chick  + L.w_chick)  //chick
  gen w_bar_t = 0.5 * (w_turkey + L.w_turkey) //turkey 

* Generate dependent variables
  gen Dep_beef   = w_bar_b * D.lnqb //beef
  gen Dep_pork   = w_bar_p * D.lnqp //pork
  gen Dep_chick  = w_bar_c * D.lnqc //chick
  gen Dep_turkey = w_bar_t * D.lnqt //turkey
  
* Generate logged nominal prices
  * notice that we need to use nominal price here (vs. real price in AIDS model)
  gen lnnpb = log(beef_p)
  gen lnnpp = log(pork_p)
  gen lnnpc = log(chick_p)
  gen lnnpt = log(turkey_p)

* Estimate Rotterdam: -nlsur- 
  nlsur (Dep_beef  = {bb}*(D.lnX-w_bar_b*D.lnnpb-w_bar_p*D.lnnpp-w_bar_c*D.lnnpc-w_bar_t*D.lnnpt) ///
                   + {cbb}*D.lnnpb+{cbp}*D.lnnpp+{cbc}*D.lnnpc+(0-{cbb}-{cbp}-{cbc})*D.lnnpt) ///
        (Dep_pork  = {bp}*(D.lnX-w_bar_b*D.lnnpb-w_bar_p*D.lnnpp-w_bar_c*D.lnnpc-w_bar_t*D.lnnpt) ///
                   + {cbp}*D.lnnpb+{cpp}*D.lnnpp+{cpc}*D.lnnpc+(0-{cbp}-{cpp}-{cpc})*D.lnnpt) ///
        (Dep_chick = {bc}*(D.lnX-w_bar_b*D.lnnpb-w_bar_p*D.lnnpp-w_bar_c*D.lnnpc-w_bar_t*D.lnnpt) ///
                   + {cbc}*D.lnnpb+{cpc}*D.lnnpp+{ccc}*D.lnnpc+(0-{cbc}-{cpc}-{ccc})*D.lnnpt), ///
        ifgnls  
		
* Calculate parameters of the fourth equation
  lincom 1 - _b[/bb]  - _b[/bp]  - _b[/bc]        //bt HOD1  
  lincom 0 - _b[/cbb] - _b[/cbp] - _b[/cbc]       //cbt=ctb
  lincom 0 - _b[/cbp] - _b[/cpp] - _b[/cpc]       //cpt=ctp
  lincom 0 - _b[/cbc] - _b[/cpc] - _b[/ccc]       //cct=ctc
  lincom _b[/cbb]+_b[/cpp]+_b[/ccc]+2*_b[/cbp]+2*_b[/cbc]+2*_b[/cpc]    //ctt
  scalar bt = 1 - _b[/bb]  - _b[/bp]  - _b[/bc]
  scalar cbt = 0 - _b[/cbb] - _b[/cbp] - _b[/cbc]
  scalar cpt = 0 - _b[/cbp] - _b[/cpp] - _b[/cpc]
  scalar cct = 0 - _b[/cbc] - _b[/cpc] - _b[/ccc] 
  scalar ctt = _b[/cbb]+_b[/cpp]+_b[/ccc]+2*_b[/cbp]+2*_b[/cbc]+2*_b[/cpc]
  
* Calculating income/expenditure elasticities
  matrix b = [_b[/bb]\ _b[/bp]\ _b[/bc]\ bt] 
  matrix list b
  matrix IncE_Rdam = J(4,1,.)
  forvalues i = 1/4 {
			matrix IncE_Rdam[`i',1] = b[`i',1] / w[`i',1]
  }
  matrix rownames IncE_Rdam = beef, pork, chick, turkey 
  matrix colnames IncE_Rdam = IncomeElasticityRotterdam
  matrix list IncE_Rdam
  
* Calculating uncompensated/Marshallian elasticities
  matrix c = [_b[/cbb], _b[/cbp], _b[/cbc], cbt\ ///
              _b[/cbp], _b[/cpp], _b[/cpc], cpt\ ///
			  _b[/cbc], _b[/cpc], _b[/ccc], cct\ ///
			   cbt,      cpt,      cct,     ctt]
  matrix E_Rdam_Mar = J(4,4,.)
  forvalues i = 1/4 {
	          forvalues j = 1/4 {
			            matrix E_Rdam_Mar[`i',`j'] = c[`i',`j']/w[`i',1] 
	        }
  }
  matrix rownames E_Rdam_Mar = beef, pork, chick, turkey
  matrix colnames E_Rdam_Mar = beef, pork, chick, turkey  
  matrix list E_Rdam_Mar
 
*-------------------------------------------------------------------------------  
* Comparing OLS, AIDS and Rotterdam Elasticities:  
  dis "The Price Elasticities calculated from OLS model are:"
  matrix list E_OLS 
  dis "The Price Elasticities (Marshallian) calculated from Rotterdam model are:"
  matrix list E_Rdam_Mar 
  dis "The Price Elasticities (Marshallian) calculated from AIDS model are:"
  matrix list E_AIDS_Mar

  
*-------------------------------------------------------------------------------
* Seasonality
  gen t = _n
  gen cos = cos(_pi*t/2)
  gen sin = sin(_pi*t/2)
  
  * OLS-Seasonality
    reg lnqb lnpb lnpp lnpc lnpt t cos sin
    matrix E_OLS_S_b=e(b)
    reg lnqp lnpb lnpp lnpc lnpt t cos sin
    matrix E_OLS_S_p=e(b)  
    reg lnqc lnpb lnpp lnpc lnpt t cos sin
    matrix E_OLS_S_c=e(b)  
    reg lnqt lnpb lnpp lnpc lnpt t cos sin
    matrix E_OLS_S_t=e(b) 
    matrix E_OLS_S = [E_OLS_S_b\ E_OLS_S_p\ E_OLS_S_c\ E_OLS_S_t]
    matrix E_OLS_S = E_OLS_S[1..4,1..4]
    matrix rownames E_OLS_S = beef, pork, chick, turkey
    matrix colnames E_OLS_S = beef, pork, chick, turkey 
    matrix list E_OLS_S
  
  * Rotterdam-Seasonality
    nlsur (Dep_beef  = {bb}*(D.lnX-w_bar_b*D.lnnpb-w_bar_p*D.lnnpp-w_bar_c*D.lnnpc-w_bar_t*D.lnnpt+{btrend}*t+{bcos}*cos+{bsin}*sin) ///
                     + {cbb}*D.lnnpb+{cbp}*D.lnnpp+{cbc}*D.lnnpc+(0-{cbb}-{cbp}-{cbc})*D.lnnpt) ///
          (Dep_pork  = {bp}*(D.lnX-w_bar_b*D.lnnpb-w_bar_p*D.lnnpp-w_bar_c*D.lnnpc-w_bar_t*D.lnnpt+{ptrend}*t+{pcos}*cos+{psin}*sin) ///
                     + {cbp}*D.lnnpb+{cpp}*D.lnnpp+{cpc}*D.lnnpc+(0-{cbp}-{cpp}-{cpc})*D.lnnpt) ///
          (Dep_chick = {bc}*(D.lnX-w_bar_b*D.lnnpb-w_bar_p*D.lnnpp-w_bar_c*D.lnnpc-w_bar_t*D.lnnpt+{ctrend}*t+{ccos}*cos+{csin}*sin) ///
                     + {cbc}*D.lnnpb+{cpc}*D.lnnpp+{ccc}*D.lnnpc+(0-{cbc}-{cpc}-{ccc})*D.lnnpt), ///
        ifgnls  
		
    * Calculate parameters of the fourth equation
      lincom 1 - _b[/bb]  - _b[/bp]  - _b[/bc]        //bt HOD1  
      lincom 0 - _b[/cbb] - _b[/cbp] - _b[/cbc]       //cbt=ctb
      lincom 0 - _b[/cbp] - _b[/cpp] - _b[/cpc]       //cpt=ctp
      lincom 0 - _b[/cbc] - _b[/cpc] - _b[/ccc]       //cct=ctc
      lincom _b[/cbb]+_b[/cpp]+_b[/ccc]+2*_b[/cbp]+2*_b[/cbc]+2*_b[/cpc]    //ctt
      scalar bt = 1 - _b[/bb]  - _b[/bp]  - _b[/bc]
      scalar cbt = 0 - _b[/cbb] - _b[/cbp] - _b[/cbc]
      scalar cpt = 0 - _b[/cbp] - _b[/cpp] - _b[/cpc]
      scalar cct = 0 - _b[/cbc] - _b[/cpc] - _b[/ccc] 
      scalar ctt = _b[/cbb]+_b[/cpp]+_b[/ccc]+2*_b[/cbp]+2*_b[/cbc]+2*_b[/cpc]
  
    * Calculating income/expenditure elasticities
      matrix b_S = [_b[/bb]\ _b[/bp]\ _b[/bc]\ bt] 
      matrix list b_S
      matrix IncE_Rdam_S = J(4,1,.)
      forvalues i = 1/4 {
			matrix IncE_Rdam_S[`i',1] = b_S[`i',1] / w[`i',1]
      }
      matrix rownames IncE_Rdam_S = beef, pork, chick, turkey 
      matrix colnames IncE_Rdam_S = IncomeElasticityRotterdam
      matrix list IncE_Rdam_S
  
    * Calculating uncompensated/Marshallian elasticities
      matrix c_S = [_b[/cbb], _b[/cbp], _b[/cbc], cbt\ ///
              _b[/cbp], _b[/cpp], _b[/cpc], cpt\ ///
			  _b[/cbc], _b[/cpc], _b[/ccc], cct\ ///
			   cbt,      cpt,      cct,     ctt]
      matrix E_Rdam_MS = J(4,4,.)
      forvalues i = 1/4 {
	          forvalues j = 1/4 {
			            matrix E_Rdam_MS[`i',`j'] = c_S[`i',`j']/w[`i',1] 
	        }
      }
      matrix rownames E_Rdam_MS = beef, pork, chick, turkey
      matrix colnames E_Rdam_MS = beef, pork, chick, turkey  
      matrix list E_Rdam_MS
  
  
  
  * AIDS-Seasonality
    nlsur (w_beef ={ab}+{bb}*lnXP+{gbb}*lnpb+{gbp}*lnpp+{gbc}*lnpc+(0-{gbb}-{gbp}-{gbc})*lnpt+{btrend}*t+{bcos}*cos+{bsin}*sin) ///
          (w_pork ={ap}+{bp}*lnXP+{gbp}*lnpb+{gpp}*lnpp+{gpc}*lnpc+(0-{gbp}-{gpp}-{gpc})*lnpt+{ptrend}*t+{pcos}*cos+{psin}*sin) ///
		  (w_chick={ac}+{bc}*lnXP+{gbc}*lnpb+{gpc}*lnpp+{gcc}*lnpc+(0-{gbc}-{gpc}-{gcc})*lnpt+{ctrend}*t+{ccos}*cos+{csin}*sin), ///
          ifgnls 
	
    * Saving estimated coefficients as matrixs
    * alpha = [ab, ap, ac, at]
	  scalar at = 1 - [ab]_cons - [ap]_cons - [ac]_cons
	  matrix alpha_S = [[ab]_cons\ [ap]_cons\ [ac]_cons\ at]
	  matrix rownames alpha_S = beef, pork, chick, turkey
	  matrix colnames alpha_S = alphaSeasonality
	  matrix list alpha_S
	  
	* beta = [bb, bp, bc, bt]
	  scalar bt = 0 - _b[/bb]  - _b[/bp]  - _b[/bc]
	  matrix beta_S = [_b[/bb]\ _b[/bp]\ _b[/bc]\ bt]
	  matrix rownames beta_S = beef, pork, chick, turkey
	  matrix colnames beta_S = betaSeasonality
	  matrix list beta_S	 
	  
	* gamma = [gbb, gbp, gbc, gbt;
	*          gpb, gpp, gpc, gpt;
	*          gcb, gcp, gcc, gct;
	*          gtb, gtp, gtc, gtt]
	  scalar gbt = 0 - _b[/gbb] - _b[/gbp] - _b[/gbc]
	  scalar gpt = 0 - _b[/gbp] - _b[/gpp] - _b[/gpc]
	  scalar gct = 0 - _b[/gbc] - _b[/gpc] - _b[/gcc] 
	  scalar gtt = _b[/gbb]+_b[/gpp]+_b[/gcc]+2*_b[/gbp]+2*_b[/gbc]+2*_b[/gpc]
	  matrix gamma_b = [_b[/gbb], _b[/gbp], _b[/gbc], gbt]
	  matrix gamma_p = [_b[/gbp], _b[/gpp], _b[/gpc], gpt]
	  matrix gamma_c = [_b[/gbc], _b[/gpc], _b[/gcc], gct]
	  matrix gamma_t = [gbt, gpt, gct, gtt]	 
	  matrix gamma_S = [gamma_b\ gamma_p\ gamma_c\ gamma_t]
	  matrix rownames gamma_S = beef, pork, chick, turkey
	  matrix colnames gamma_S = gamma_beef, gamma_pork, gamma_chick, gamma_turkey
	  matrix list gamma_S
	
  * Create matrixs A B & C in Green & Alston (1990):
	matrix A = J(4,4,.)
	forvalues i = 1/4 {
	          forvalues j = 1/4 {
			            matrix A[`i',`j'] = - delta[`i',`j'] + /// 
						gamma_S[`i',`j']/w[`i',1] - beta_S[`i',1]*w[`j',1]/w[`i',1]
	        }
	}
    matrix list A
	
	matrix B = J(4,1,.)
	forvalues i = 1/4 {
			  matrix B[`i',1] = beta_S[`i',1]/w[`i',1]
	}
    matrix list B
	
	matrix C = J(1,4,.)
	forvalues j = 1/4 {
			  matrix C[1,`j'] = w[`j',1]*lnP[`j',1]
	}	
	matrix list C
  
  * Calculating compensated (Hicksian) price elasticities:
    matrix E_AIDS_S = inv(B*C+delta)*(A+delta)-delta // Equation 11 in Green & Alston (1990)
	matrix rownames E_AIDS_S = beef, pork, chick, turkey
	matrix colnames E_AIDS_S = beef, pork, chick, turkey	
	matrix list E_AIDS_S
	
  * Calculating expenditure (income) elasticities:
    matrix One = J(4,1,1)
	matrix IncE_AIDS_S = inv(delta+B*C)*B + One
	matrix rownames IncE_AIDS_S = beef, pork, chick, turkey
	matrix colnames IncE_AIDS_S = IncomeElasticities	
	matrix list IncE_AIDS_S
	
  * Calculating uncompenstated (Marshallian) price elasticities:
	matrix E_AIDS_MS = J(4,4,.)
	forvalues i = 1/4 {
	          forvalues j = 1/4 {
			            matrix E_AIDS_MS[`i',`j'] = E_AIDS_S[`i',`j'] + /// 
						(1 + beta_S[`i',1]*w[`j',1]) * w[`j',1]
	        }
	}
	matrix rownames E_AIDS_MS = beef, pork, chick, turkey
	matrix colnames E_AIDS_MS = beef, pork, chick, turkey	
    matrix list E_AIDS_MS
	
	
* Comparing OLS, AIDS and Rotterdam Elasticities:  
  dis "The OLS Price Elasticities (Without Seasonality) are:"
  matrix list E_OLS 
  dis "The Rotterdam Elasticities (Marshallian & Without Seasonality) are:"
  matrix list E_Rdam_Mar 
  dis "The AIDS Elasticities (Marshallian & Without Seasonality) are:"
  matrix list E_AIDS_Mar
  dis "The OLS Price Elasticities (With Seasonality) are:"
  matrix list E_OLS_S 
  dis "The Rotterdam Elasticities (Marshallian & With Seasonality) are:"
  matrix list E_Rdam_MS 
  dis "The AIDS Elasticities (Marshallian & With Seasonality) are:"
  matrix list E_AIDS_MS
  
*log close



/*TO COMPARE COEEFICIENTS of MARSHALIAN DEMANDS UNRESTRICTED WITH AND WITHOUT SEASONALITY*/
coefplot (matrix(E_OLS[1,]))  (matrix(E_OLS_S[1,])) (matrix(E_Rdam_Mar[1,])) (matrix(E_Rdam_MS[1,])) (matrix(E_AIDS_Mar[1,])) (matrix(E_AIDS_MS[1,]))
coefplot (matrix(E_OLS[2,]))  (matrix(E_OLS_S[2,])) (matrix(E_Rdam_Mar[2,])) (matrix(E_Rdam_MS[2,])) (matrix(E_AIDS_Mar[2,])) (matrix(E_AIDS_MS[2,]))
coefplot (matrix(E_OLS[3,]))  (matrix(E_OLS_S[3,])) (matrix(E_Rdam_Mar[3,])) (matrix(E_Rdam_MS[3,])) (matrix(E_AIDS_Mar[3,])) (matrix(E_AIDS_MS[3,]))
coefplot (matrix(E_OLS[4,]))  (matrix(E_OLS_S[4,])) (matrix(E_Rdam_Mar[4,])) (matrix(E_Rdam_MS[4,])) (matrix(E_AIDS_Mar[4,])) (matrix(E_AIDS_MS[4,]))

/*TO COMPARE COEEFICIENTS INCOME ELASTICITIES UNRESTRICTED WITH AND WITHOUT SEASONALITY*/

coefplot (matrix(IncE_AIDS[,1]))  (matrix(IncE_AIDS_S[,1])) (matrix(IncE_Rdam[,1])) (matrix(IncE_Rdam_S[,1])) 



