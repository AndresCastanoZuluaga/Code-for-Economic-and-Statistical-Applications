* AEM 6700
* Meat Demand (AIDS Model)
* Notes: with seasonality there is a command that gives you all the parameter estimated (look for).
/* Other commands to estimate AIDS Models:  
- sureg  for seemingly unrelated regressions 
- quaids
- aidsills 
*/

clear
set more off
* Setting working directory
  cd "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/Meat Demand"
 
* Log file
  *log using MeatAIDS_Unrestricted.log, replace
  
* Import data
  import excel using "MeatAIDSData.xlsx", sheet("meat") firstrow
  save AIDSMeats, replace
    
* Generate quarter index  
  gen yrqtr = yq(year, qtr) /*To covert the data to quarters (trimestres)*/
  format yrqtr %tq
  order yrqtr, a(qtr)
  tsset yrqtr
  
* Generate real prices  
/*important question, de donde viene el Consumer Price Index*/
  gen beef_pr = beef_p/cpi
  gen pork_pr = pork_p/cpi
  gen chick_pr = chick_p/cpi
  gen turkey_pr = turkey_p/cpi
  
* Calcuate total expenditures on all meats (X) and shares of each meat
  gen ex_beef = beef_pr*beef_q
  gen ex_pork = pork_pr*pork_q
  gen ex_chick = chick_pr*chick_q
  gen ex_turkey = turkey_pr*turkey_q
  gen X = ex_beef + ex_pork + ex_chick + ex_turkey  /*total expenditure*/
  
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
  /* The price index used is the Stone's Geometric Price Index (view Green and Alston 1990, pag. 1)*/
  gen lnP  = w_beef*lnpb + w_pork*lnpp + w_chick*lnpc + w_turkey*lnpt 
  gen lnXP = lnX - lnP

*-------------------------------------------------------------------------------
* ADIS, Rotterdam, and OLS Model (Without Seasonality) 
 
* Estimate AIDS: -nlsur- 
/*Given that there are 4 goods we need to estimate the system with 4 equations, to no loss grados de libertad
a good strategy is estimate the system with three goods and then recover the estimates for the fourth 
equation*/
  nlsur (w_beef ={ab}+{bb}*lnXP+{gbb}*lnpb+{gbp}*lnpp+{gbc}*lnpc+{gbt}*lnpt) ///
        (w_pork ={ap}+{bp}*lnXP+{gpb}*lnpb+{gpp}*lnpp+{gpc}*lnpc+{gpt}*lnpt) ///
		(w_chick={ac}+{bc}*lnXP+{gcb}*lnpb+{gcp}*lnpp+{gcc}*lnpc+{gct}*lnpt), ///
        ifgnls 
		
		
  * Calculate parameters of the fourth equation
    lincom 1 - [ab]_cons - [ap]_cons - [ac]_cons    //at HOD1 constant for the turkey equation
	lincom 0 - _b[/bb]  - _b[/bp]  - _b[/bc]        //bt HOD0  estimate of bt
	lincom 0 - _b[/gbb] - _b[/gpb] - _b[/gcb]       //gtb how beef price affects share of turkey
    lincom 0 - _b[/gbp] - _b[/gpp] - _b[/gcp]       //gtp how pork price affect hare of turkey
    lincom 0 - _b[/gbc] - _b[/gpc] - _b[/gcc]       //gtc how chicken price affect hare of turkey
	lincom _b[/gbb]+_b[/gbp]+_b[/gbc]+_b[/gpb]+_b[/gpp]+_b[/gpc]+_b[/gcb]+_b[/gcp]+_b[/gcc]    //gtt
	
  * Test symmetry restrictions /* d(hj(p,u))/d(pi) = d(hi(p,u))/d(pj)*/
    test _b[/gbp]=_b[/gpb] 
    test _b[/gbc]=_b[/gcb]
    test _b[/gpc]=_b[/gcp]	
	test _b[/gbt]=0 - _b[/gbb] - _b[/gpb] - _b[/gcb] // gbt=gtb
	test _b[/gpt]=0 - _b[/gbp] - _b[/gpp] - _b[/gcp] // gpt=gtp
	test _b[/gct]=0 - _b[/gbc] - _b[/gpc] - _b[/gcc] // gct=gtc	
	
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
	  scalar gtb = 0 - _b[/gbb] - _b[/gpb] - _b[/gcb]
	  scalar gtp = 0 - _b[/gbp] - _b[/gpp] - _b[/gcp]
	  scalar gtc = 0 - _b[/gbc] - _b[/gpc] - _b[/gcc] 
	  scalar gtt = _b[/gbb]+_b[/gbp]+_b[/gbc]+_b[/gpb]+_b[/gpp]+_b[/gpc]+_b[/gcb]+_b[/gcp]+_b[/gcc]
	  matrix gamma_b = [_b[/gbb], _b[/gbp], _b[/gbc], _b[/gbt]]
	  matrix gamma_p = [_b[/gpb], _b[/gpp], _b[/gpc], _b[/gpt]]
	  matrix gamma_c = [_b[/gcb], _b[/gcp], _b[/gcc], _b[/gct]]
	  matrix gamma_t = [gtb, gtp, gtc, gtt]	 
	  matrix gamma = [gamma_b\ gamma_p\ gamma_c\ gamma_t]
	  matrix rownames gamma = beef, pork, chick, turkey
	  matrix colnames gamma = gamma_beef, gamma_pork, gamma_chick, gamma_turkey
	  matrix list gamma
	
	* alpha, beta, gamma  
      matrix AIDS_Parameters = [alpha, beta, gamma]
	  matrix list AIDS_Parameters

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
	matrix list delta
	
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
	
  * Calculating expenditure (income) elasticities: (De donde sacas la derivacion matricila de esto
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
  matrix list  E_OLS

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
                   + {cbb}*D.lnnpb+{cbp}*D.lnnpp+{cbc}*D.lnnpc+{cbt}*D.lnnpt) ///
        (Dep_pork  = {bp}*(D.lnX-w_bar_b*D.lnnpb-w_bar_p*D.lnnpp-w_bar_c*D.lnnpc-w_bar_t*D.lnnpt) ///
                   + {cpb}*D.lnnpb+{cpp}*D.lnnpp+{cpc}*D.lnnpc+{cpt}*D.lnnpt) ///
        (Dep_chick = {bc}*(D.lnX-w_bar_b*D.lnnpb-w_bar_p*D.lnnpp-w_bar_c*D.lnnpc-w_bar_t*D.lnnpt) ///
                   + {ccb}*D.lnnpb+{ccp}*D.lnnpp+{ccc}*D.lnnpc+{cct}*D.lnnpt), ///
        ifgnls  
		
  * Calculate parameters of the fourth equation
	lincom 1 - _b[/bb]  - _b[/bp]  - _b[/bc]        //bt HOD0  
	lincom 0 - _b[/cbb] - _b[/cpb] - _b[/ccb]       //ctb
    lincom 0 - _b[/cbp] - _b[/cpp] - _b[/ccp]       //ctp
    lincom 0 - _b[/cbc] - _b[/cpc] - _b[/ccc]       //ctc
	lincom _b[/cbb]+_b[/cbp]+_b[/cbc]+_b[/cpb]+_b[/cpp]+_b[/cpc]+_b[/ccb]+_b[/ccp]+_b[/ccc]    //ctt
	
  * Test symmetry restrictions
    test _b[/cbp]=_b[/cpb]
    test _b[/cbc]=_b[/ccb]
    test _b[/cpc]=_b[/ccp]	
	test _b[/cbt]=0 - _b[/cbb] - _b[/cpb] - _b[/ccb] // cbt=ctb
	test _b[/cpt]=0 - _b[/cbp] - _b[/cpp] - _b[/ccp] // cpt=ctp
	test _b[/cct]=0 - _b[/cbc] - _b[/cpc] - _b[/ccc] // cct=ctc	
	
    scalar bt = 1 - _b[/bb]  - _b[/bp]  - _b[/bc]
    scalar ctb = 0 - _b[/cbb] - _b[/cpb] - _b[/ccb]
    scalar ctp = 0 - _b[/cbp] - _b[/cpp] - _b[/ccp]
    scalar ctc = 0 - _b[/cbc] - _b[/cpc] - _b[/ccc] 
    scalar ctt = _b[/cbb]+_b[/cbp]+_b[/cbc]+_b[/cpb]+_b[/cpp]+_b[/cpc]+_b[/ccb]+_b[/ccp]+_b[/ccc]
  
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
    matrix c = [_b[/cbb], _b[/cbp], _b[/cbc], _b[/cbt]\ ///
                _b[/cpb], _b[/cpp], _b[/cpc], _b[/cpt]\ ///
		    	_b[/ccb], _b[/ccp], _b[/ccc], _b[/cct]\ ///
			        ctb,      ctp,      ctc,      ctt]
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
* Seasonality (which seasonality method do you use)
  gen t = _n
  gen cos = cos(_pi*t/2)
  gen sin = sin(_pi*t/2)
  
  * AIDS-Seasonality
	nlsur (w_beef ={ab}+{bb}*lnXP+{gbb}*lnpb+{gbp}*lnpp+{gbc}*lnpc+{gbt}*lnpt+{btrend}*t+{bcos}*cos+{bsin}*sin) ///
          (w_pork ={ap}+{bp}*lnXP+{gpb}*lnpb+{gpp}*lnpp+{gpc}*lnpc+{gpt}*lnpt+{ptrend}*t+{pcos}*cos+{psin}*sin) ///
		  (w_chick={ac}+{bc}*lnXP+{gcb}*lnpb+{gcp}*lnpp+{gcc}*lnpc+{gct}*lnpt+{ctrend}*t+{ccos}*cos+{csin}*sin), ///
          ifgnls 	  
	
    * Calculate parameters of the fourth equation
      lincom 1 - [ab]_cons - [ap]_cons - [ac]_cons    //at HOD1
	  lincom 0 - _b[/bb]  - _b[/bp]  - _b[/bc]        //bt HOD0  
	  lincom 0 - _b[/gbb] - _b[/gpb] - _b[/gcb]       //gtb
      lincom 0 - _b[/gbp] - _b[/gpp] - _b[/gcp]       //gtp
      lincom 0 - _b[/gbc] - _b[/gpc] - _b[/gcc]       //gtc
	  lincom _b[/gbb]+_b[/gbp]+_b[/gbc]+_b[/gpb]+_b[/gpp]+_b[/gpc]+_b[/gcb]+_b[/gcp]+_b[/gcc]    //gtt
	
    * Test symmetry restrictions
      test _b[/gbp]=_b[/gpb]
      test _b[/gbc]=_b[/gcb]
      test _b[/gpc]=_b[/gcp]	
	  test _b[/gbt]=0 - _b[/gbb] - _b[/gpb] - _b[/gcb] // gbt=gtb
	  test _b[/gpt]=0 - _b[/gbp] - _b[/gpp] - _b[/gcp] // gpt=gtp
	  test _b[/gct]=0 - _b[/gbc] - _b[/gpc] - _b[/gcc] // gct=gtc	
	
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
	  scalar gtb = 0 - _b[/gbb] - _b[/gpb] - _b[/gcb]
	  scalar gtp = 0 - _b[/gbp] - _b[/gpp] - _b[/gcp]
	  scalar gtc = 0 - _b[/gbc] - _b[/gpc] - _b[/gcc] 
	  scalar gtt = _b[/gbb]+_b[/gbp]+_b[/gbc]+_b[/gpb]+_b[/gpp]+_b[/gpc]+_b[/gcb]+_b[/gcp]+_b[/gcc]
	  matrix gamma_b = [_b[/gbb], _b[/gbp], _b[/gbc], _b[/gbt]]
	  matrix gamma_p = [_b[/gpb], _b[/gpp], _b[/gpc], _b[/gpt]]
	  matrix gamma_c = [_b[/gcb], _b[/gcp], _b[/gcc], _b[/gct]]
	  matrix gamma_t = [gtb, gtp, gtc, gtt]	 
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
                     + {cbb}*D.lnnpb+{cbp}*D.lnnpp+{cbc}*D.lnnpc+{cbt}*D.lnnpt) ///
          (Dep_pork  = {bp}*(D.lnX-w_bar_b*D.lnnpb-w_bar_p*D.lnnpp-w_bar_c*D.lnnpc-w_bar_t*D.lnnpt+{ptrend}*t+{pcos}*cos+{psin}*si) ///
                     + {cpb}*D.lnnpb+{cpp}*D.lnnpp+{cpc}*D.lnnpc+{cpt}*D.lnnpt) ///
          (Dep_chick = {bc}*(D.lnX-w_bar_b*D.lnnpb-w_bar_p*D.lnnpp-w_bar_c*D.lnnpc-w_bar_t*D.lnnpt+{ctrend}*t+{ccos}*cos+{csin}*si) ///
                     + {ccb}*D.lnnpb+{ccp}*D.lnnpp+{ccc}*D.lnnpc+{cct}*D.lnnpt), ///
        ifgnls  
		
    * Calculate parameters of the fourth equation
	  lincom 1 - _b[/bb]  - _b[/bp]  - _b[/bc]        //bt HOD0  
	  lincom 0 - _b[/cbb] - _b[/cpb] - _b[/ccb]       //ctb
      lincom 0 - _b[/cbp] - _b[/cpp] - _b[/ccp]       //ctp
      lincom 0 - _b[/cbc] - _b[/cpc] - _b[/ccc]       //ctc
	  lincom _b[/cbb]+_b[/cbp]+_b[/cbc]+_b[/cpb]+_b[/cpp]+_b[/cpc]+_b[/ccb]+_b[/ccp]+_b[/ccc]    //ctt
	
    * Test symmetry restrictions
      test _b[/cbp]=_b[/cpb]
      test _b[/cbc]=_b[/ccb]
      test _b[/cpc]=_b[/ccp]	
	  test _b[/cbt]=0 - _b[/cbb] - _b[/cpb] - _b[/ccb] // cbt=ctb
	  test _b[/cpt]=0 - _b[/cbp] - _b[/cpp] - _b[/ccp] // cpt=ctp
	  test _b[/cct]=0 - _b[/cbc] - _b[/cpc] - _b[/ccc] // cct=ctc	
	
      scalar bt = 1 - _b[/bb]  - _b[/bp]  - _b[/bc]
      scalar ctb = 0 - _b[/cbb] - _b[/cpb] - _b[/ccb]
      scalar ctp = 0 - _b[/cbp] - _b[/cpp] - _b[/ccp]
      scalar ctc = 0 - _b[/cbc] - _b[/cpc] - _b[/ccc] 
      scalar ctt = _b[/cbb]+_b[/cbp]+_b[/cbc]+_b[/cpb]+_b[/cpp]+_b[/cpc]+_b[/ccb]+_b[/ccp]+_b[/ccc]
  
  
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
    matrix c_S = [_b[/cbb], _b[/cbp], _b[/cbc], _b[/cbt]\ ///
                  _b[/cpb], _b[/cpp], _b[/cpc], _b[/cpt]\ ///
		    	  _b[/ccb], _b[/ccp], _b[/ccc], _b[/cct]\ ///
			          ctb,      ctp,      ctc,      ctt]
      matrix E_Rdam_MS = J(4,4,.)
      forvalues i = 1/4 {
	          forvalues j = 1/4 {
			            matrix E_Rdam_MS[`i',`j'] = c_S[`i',`j']/w[`i',1] 
	        }
      }
      matrix rownames E_Rdam_MS = beef, pork, chick, turkey
      matrix colnames E_Rdam_MS = beef, pork, chick, turkey  
      matrix list E_Rdam_MS	
	
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
 

 * Comparing  AIDS and Rotterdam Income Elasticities:
dis "The AIDS Income Elasticities (Without Seasonality) are:"
matrix list IncE_AIDS
dis "The ROTTERDAN Income Elasticities (Without Seasonality) are:"
matrix list IncE_Rdam
dis "The AIDS Income Elasticities (With Seasonality) are:"
matrix list IncE_AIDS_S
dis "The ROTTERDAN Income Elasticities (With Seasonality) are:"
matrix list IncE_Rdam_S


 
 
/*TO COMPARE COEEFICIENTS of MARSHALIAN DEMANDS UNRESTRICTED WITH AND WITHOUT SEASONALITY*/
coefplot (matrix(E_OLS[1,]))  (matrix(E_OLS_S[1,])) (matrix(E_Rdam_Mar[1,])) (matrix(E_Rdam_MS[1,])) (matrix(E_AIDS_Mar[1,])) (matrix(E_AIDS_MS[1,]))
coefplot (matrix(E_OLS[2,]))  (matrix(E_OLS_S[2,])) (matrix(E_Rdam_Mar[2,])) (matrix(E_Rdam_MS[2,])) (matrix(E_AIDS_Mar[2,])) (matrix(E_AIDS_MS[2,]))
coefplot (matrix(E_OLS[3,]))  (matrix(E_OLS_S[3,])) (matrix(E_Rdam_Mar[3,])) (matrix(E_Rdam_MS[3,])) (matrix(E_AIDS_Mar[3,])) (matrix(E_AIDS_MS[3,]))
coefplot (matrix(E_OLS[4,]))  (matrix(E_OLS_S[4,])) (matrix(E_Rdam_Mar[4,])) (matrix(E_Rdam_MS[4,])) (matrix(E_AIDS_Mar[4,])) (matrix(E_AIDS_MS[4,]))

/*TO COMPARE COEEFICIENTS INCOME ELASTICITIES UNRESTRICTED WITH AND WITHOUT SEASONALITY*/

coefplot (matrix(IncE_AIDS[,1]))  (matrix(IncE_AIDS_S[,1])) (matrix(IncE_Rdam[,1])) (matrix(IncE_Rdam_S[,1])) 


 
log close


