*QUAIDSCE EXAMPLE SEPT 2024

*Quaidsce requires the parallel command, and this example requires the user-written command parmest, as noted below:
*ssc install parmest, replace
*net install quaidsce, replace force from("https://juancaros.github.io/quaidsce/")
*net install parallel, from("https://raw.github.com/gvegayon/parallel/stable/") replace
*Enable the next line if you need to download quaids, which corresponds to the demand-model application by Poi that does not address censoring
*search quaids //Look for "Software update for quaids, quaids_postestimation"

*Setup
mata mata mlib index
parallel initialize 4, f
clear all
capture log close
program drop _all
log using example.log, replace
set seed 123456
use https://www.stata-press.com/data/r18/food_consumption, clear

*Generated demographics and conditional censoring
gen rural = (runiform() > 0.8)
gen income = exp(rnormal())+exp(rnormal())*(p_proteins*expfd/10)
gen aux = (n_adults + n_kids + income - p_fruitveg + p_dairy)*exp(rnormal())
replace w_flours=0 if aux*aux*aux>20000
replace w_proteins=0 if aux*aux<30
replace w_fruitveg=0 if aux<5
replace w_dairy=0 if aux>30
gen total = w_fruitveg + w_dairy + w_proteins + w_flours
drop aux
save foodcomp_censored.dta, replace

*Tables and Figures
*Table 1
use foodcomp_censored.dta, clear

foreach var in w_proteins w_fruitveg w_dairy w_flours {
	replace `var'=`var'/total
	drop if `var' > .75
	gen d`var' = 0
	replace d`var' = 1 if `var'==0
}

sum w* dw*


*QUAIDS (Poi 2012)
quaids w_proteins w_fruitveg w_dairy w_flours, prices(p_proteins p_fruitveg p_dairy p_flours) expenditure(expfd) nolog demographics(income) anot(1.6)
estat exp, atmeans
mat elas = r(expelas)'
estat uncomp, atmeans
mat elas = elas \ vecdiag(r(uncompelas))'


*Censored QUAIDS estimation
quaidsce w_proteins w_fruitveg w_dairy w_flours, prices(p_proteins p_fruitveg p_dairy p_flours) expenditure(expfd) nolog demographics(income) anot(1.6) reps(100) 

parmest, saving(output, replace)   

*Figures 1 and 2
use output.dta, clear
keep if eq =="ELAS_INC" | ((parm=="e_1_1" | parm=="e_2_2" | parm=="e_3_3" | parm=="e_4_4") & eq=="ELAS_UNCOMP")
svmat elas, name(quaids)
save output.dta, replace
gen rw = _n

tw (rcap min95 max95 rw , horizontal) (scatter rw estimate) (scatter rw quaids1) if eq =="ELAS_INC" , ylabel(1 "Proteins" 2 "F & V" 3 "Dairy" 4 "Flours", angle(horizontal)) yti("Food Group") xti("Estimate") graphr(color(white)) legend(order(1 "95% CI" 2 "QUAIDSCE" 3 "QUAIDS") rows(1)) scheme(s2mono)

tw (rcap min95 max95 rw , horizontal) (scatter rw estimate) (scatter rw quaids1) if eq =="ELAS_UNCOMP" , ylabel(5 "Proteins" 6 "F & V" 7 "Dairy" 8 "Flours", angle(horizontal)) yti("Food Group") xti("Estimate") graphr(color(white)) legend(order(1 "95% CI" 2 "QUAIDSCE" 3 "QUAIDS") rows(1)) scheme(s2mono)

log close
