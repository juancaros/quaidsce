clear all
capture log close
program drop _all
log using example.log, replace
set seed 123456
*Quaidsce requires the parallel command, and this example requires the user-written command parmest, as noted below:
ssc install parmest, replace
net install quaidsce, replace force from("https://juancaros.github.io/quaidsce/")
net install parallel, from("https://raw.github.com/gvegayon/parallel/stable/") replace
mata mata mlib index
parallel initialize 

use https://www.stata-press.com/data/r18/food_consumption, clear

*Generated demographics and conditional censoring
gen rural = (runiform() > 0.8)
gen income = exp(rnormal())+exp(rnormal())
gen aux = (n_adults + n_kids + income)*exp(rnormal())
replace w_proteins=0 if aux<1
replace w_flours=0 if aux<1.5
replace w_fruitveg=0 if aux<2
replace w_misc=0 if aux>5
replace w_dairy=0 if aux>15
replace w_misc=1-w_dairy-w_flours-w_proteins-w_fruitveg
replace w_misc=0 if w_misc<0.00001
drop aux
save foodcomp_censored.dta, replace

*QUAIDS (Poi 2012)
quaids w_dairy w_proteins w_fruitveg w_flours w_misc, prices(p_dairy p_proteins p_fruitveg p_flours p_misc) expenditure(expfd) nolog demographics(n_adults n_kids income rural) anot(1.6)
estat exp, atmeans
mat elas = r(expelas)'
estat uncomp, atmeans
mat elas = elas \ vecdiag(r(uncompelas))'

*Censored QUAIDS estimation
quaidsce w_dairy w_proteins w_fruitveg w_flours w_misc, prices(p_dairy p_proteins p_fruitveg p_flours p_misc) expenditure(expfd) nolog demographics(n_adults n_kids income rural) anot(1.6) reps(100) 

parmest, saving(output, replace)   

*Tables and Figures
*Table 1
use foodcomp_censored.dta, clear
foreach var in w_dairy w_proteins w_fruitveg w_flours w_misc {
	gen d`var' = 0
	replace d`var' = 1 if `var'==0
}

sum w* dw*

*Figures 1 and 2
use output.dta, clear
keep if eq =="ELAS_INC" | ((parm=="e_1_1" | parm=="e_1_1" | parm=="e_2_2" | parm=="e_3_3" | parm=="e_4_4" | parm=="e_5_5") & eq=="ELAS_UNCOMP")
svmat elas, name(quaids)
save output.dta, replace
gen rw = _n

tw (rcap min95 max95 rw , horizontal) (scatter rw estimate) (scatter rw quaids1) if eq =="ELAS_INC" , ylabel(1 "Dairy" 2 "Proteins" 3 "F & V" 4 "Flours" 5 "Misc", angle(horizontal)) yti("Food Group") xti("Estimate") graphr(color(white)) legend(order(1 "95% CI" 2 "QUAIDSCE" 3 "QUAIDS") rows(1)) scheme(s2mono)

tw (rcap min95 max95 rw , horizontal) (scatter rw estimate) (scatter rw quaids1) if eq =="ELAS_UNCOMP" , ylabel(6 "Dairy" 7 "Proteins" 8 "F & V" 9 "Flours" 10 "Misc", angle(horizontal)) yti("Food Group") xti("Estimate") graphr(color(white)) legend(order(1 "95% CI" 2 "QUAIDSCE" 3 "QUAIDS") rows(1)) scheme(s2mono)

log close
