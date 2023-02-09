/* Full list of Stata commands used in Lecocq & Robin (2014) to get: */

/* Fig01_rev2 */
sjlog using aidsills1, replace
version 13
webuse food
drop lnp1 lnp2 lnp3 lnp4 lnexp
set seed 1
generate nkids = int(runiform()*4)
generate rural = (runiform() > 0.7)
sjlog close, replace

/* Fig02_rev2 */
sjlog using aidsills2, replace
aidsills w1-w4, prices(p1-p4) expenditure(expfd) symmetry alpha_0(10)
sjlog close, replace

/* Fig03_rev2 */
sjlog using aidsills3, replace
aidsills_elas
sjlog close, replace
quaids w1-w4, prices(p1-p4) expenditure(expfd) noquadratic anot(10)

/* Fig04_rev2 */
sjlog using aidsills4, replace
estat expenditure, atmeans stderrs
matrix list r(expelas)
matrix list r(sd)
estat uncompensated, atmeans stderrs
matrix list r(uncompelas)
matrix list r(sd)
estat compensated, atmeans stderrs
matrix list r(compelas)
matrix list r(sd)
sjlog close, replace

/* Table */
aidsills w1-w4, prices(p1-p4) expenditure(expfd) symmetry alpha_0(10)
quaids w1-w4, prices(p1-p4) expenditure(expfd) noquadratic anot(10)
aidsills w1-w4, prices(p1-p4) expenditure(expfd) intercept(nkids rural) symmetry alpha_0(10)
quaids w1-w4, prices(p1-p4) expenditure(expfd) demographics(nkids rural) noquadratic anot(10)
use data, clear
aidsills s1-s7, prices(p1-p7) expenditure(somtot) symmetry alpha_0(10)
quaids s1-s7, prices(p1-p7) expenditure(somtot) noquadratic anot(10)
aidsills s1-s7, prices(p1-p7) expenditure(somtot) intercept(nbpers rural) symmetry alpha_0(10)
quaids s1-s7, prices(p1-p7) expenditure(somtot) demographics(nbpers rural) noquadratic anot(10)

webuse food, clear
drop lnp1 lnp2 lnp3 lnp4 lnexp
set seed 1
generate nkids = int(runiform()*4)
generate rural = (runiform() > 0.7)

/* Fig05_rev2 & Fig06_rev2 */
sjlog using aidsills5, replace
generate lninc = ln(100+(runiform()*1000)+10*expfd)
aidsills w1-w4, prices(p1-p4) expenditure(expfd) intercept(nkids rural) ivexpenditure(lninc) symmetry alpha_0(10)
sjlog close, replace

/* Fig07_rev2 */
sjlog using aidsills6, replace
test rho_vexpfd
sjlog close, replace

/* Fig08_rev2 */
sjlog using aidsills7, replace
aidsills w1-w4, prices(p1-p4) expenditure(expfd) intercept(nkids rural) iteration(0) alpha_0(10)
sjlog close, replace

/* Fig09_rev2 */
sjlog using aidsills8, replace
aidsills w1-w4, prices(p1-p4) expenditure(expfd) intercept(nkids rural) homogeneity alpha_0(10)
sjlog close, replace

/* Fig10_rev2 */
sjlog using aidsills9, replace
quietly test [w1]gamma_lnp2=[w2]gamma_lnp1, notest
quietly test [w1]gamma_lnp3=[w3]gamma_lnp1, notest accumulate
test [w2]gamma_lnp3=[w3]gamma_lnp2, accumulate
sjlog close, replace
