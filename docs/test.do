clear all
capture log close
set maxvar 10000
*cd "C:\ado\plus\u"  //set path

*do "C:\ado\plus\u\utils__quaidsce.mata" //run mata to update libraries
*lmbuild lquaidsce.mlib, replace dir(C:\ado\plus)
*net install quaidsce, replace force from("https://juancaros.github.io/quaidsce")

log using  "C:\Users\jccaro\quaidsce\test.log", replace
webuse food, clear
program drop _all

use "C:\Users\jccaro\quaidsce\docs\DS_STATA_3_2__pci2sls_.dta", clear

***debugginb tools
*set trace on
*set tracedepth 4
*set matadebug on
*mata: mata set matalnum on

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

quaids w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog 
quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) nolog demographics(income) noquadratic method(nls) 
quaidsce w1-w17, anot(10) prices(p1-p17) expenditure(total_exp) demographics(EA  x1-x8) nolog  method(nls) 

log close
