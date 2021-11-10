clear all
capture log close
set maxvar 10000
*lmbuild lquaidsce.mlib, replace dir(C:\ado\plus)
net install quaidsce, replace force from("https://juancaros.github.io/quaidsce")
webuse food, clear
program drop _all

*use "C:\Users\jccaro\quaidsce\docs\DS_STATA_3_2__pci2sls_.dta"

foreach i of numlist 1/4 {
gen aux = cond(runiform() < 0.2, 0, 1)
replace w`i'=0 if aux==0
drop aux 
}

gen w5=1-w1-w2-w3-w4
replace w5=0 if w5<0.0001
gen p5=0.5*p1+0.5*p3+exp(rnormal())
gen lnp5=ln(p5)

set seed 1
gen nkids = int(runiform()*4)
gen rural = (runiform() > 0.2)
gen income = exp(rnormal())+exp(rnormal())


quaids w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5o expenditure(expfd) demographics(nkids income) nolog 
quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) nolog demographics(income nkids) nocensor
*****************************************************************************************
* comments
*****************************************************************************************

* a) quaidsce shr1-shr17, anot(10) prices(p1-p17) expenditure(total) nolog demographics(x1-x3) method(nls)
*hr1 not found
*r(111);

* b) endogenous total?
*****************************************************************************************


use "C:\Users\grace.meloguerrero\OneDrive - Texas A&M AgriLife\Documents\GitHub\quaidsce\data\DS_STATA_3_2_0_pci2sls_", clear

egen total=rowtotal(hh_shill1-hh_shill17)


foreach i of numlist 1/17 {
	drop w`i'
gen w`i'=hh_shill`i'/total
drop if missing(w`i')
}


log using  "C:\Users\grace.meloguerrero\OneDrive - Texas A&M AgriLife\Documents\GitHub\quaidsce\log\nocensor.log", replace
quaidsce w1-w17, anot(10) prices(p1-p17) expenditure(total) nolog demographics(x1-x3) method(nls) 


log close

log using  "C:\Users\grace.meloguerrero\OneDrive - Texas A&M AgriLife\Documents\GitHub\quaidsce\log\nocensor_elast.log", replace

estat uncomp
mat define unce_quaidsce=  r(elas_u)
mat list unce_quaidsce

log close


log using  "C:\Users\grace.meloguerrero\OneDrive - Texas A&M AgriLife\Documents\GitHub\quaidsce\log\censor.log", replace
quaidsce w1-w17, anot(10) prices(p1-p17) expenditure(total) nolog demographics(x1-x3) method(nls) 


log close

log using  "C:\Users\grace.meloguerrero\OneDrive - Texas A&M AgriLife\Documents\GitHub\quaidsce\log\censor_exp_elast.log", replac
estat exp
mat define ee_quaidsce=  r(elas_i)
mat list ee_quaidsce

log using  "C:\Users\grace.meloguerrero\OneDrive - Texas A&M AgriLife\Documents\GitHub\quaidsce\log\censor_comp_elast.log", repl
estat comp
mat define ce_quaidsce=  r(elas_c)
mat list ce_quaidsce
log close

log using  "C:\Users\grace.meloguerrero\OneDrive - Texas A&M AgriLife\Documents\GitHub\quaidsce\log\censor_uncomp_elast.log", replace
estat uncomp
mat define unce_quaidsce=  r(elas_u)
mat list unce_quaidsce