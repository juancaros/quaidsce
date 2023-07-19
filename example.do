clear all
capture log close
program drop _all
log using test.log, replace
net install quaidsce, replace force from("https://juancaros.github.io/quaidsce/")
use https://www.stata-press.com/data/r18/food_consumption

*Generated demographics and conditional censoring
gen rural = (runiform() > 0.8)
gen income = exp(rnormal())+exp(rnormal())
gen aux = (n_adults + n_kids + income)*exp(rnormal())
replace w_flours=0 if aux<1
replace w_proteins=0 if aux<2
replace w_fruitveg=0 if aux<3
replace w_misc=0 if aux>10
replace w_dairy=0 if aux>15
replace w_misc=1-w_dairy-w_flours-w_proteins-w_fruitveg
replace w_misc=0 if w_misc<0.001
drop aux

*Censored QUAIDS estimation
quaidsce w_dairy w_proteins w_fruitveg w_flours w_misc, prices(p_dairy p_proteins p_fruitveg p_flours p_misc) expenditure(expfd) nolog demographics(n_adults n_kids income rural) anot(10) reps(10)   
