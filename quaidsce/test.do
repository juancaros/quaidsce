clear all
capture log close
cd "C:\ado\personal\_"
do _quaidsce__utils.mata
lmbuild lquaidsce.mlib, replace dir( C:\ado\personal\l\)
log using  "C:\Users\jccaro\quaidsce\quaidsce\test.log", replace
webuse food, clear
program drop _all
*set trace on
*set tracedepth 4
*set matadebug on
*mata: mata set matalnum on

set seed 1
gen nkids = int(runiform()*4)
gen rural = (runiform() > 0.7)
gen income = exp(rnormal())

quaids w1-w4, anot(10) prices(p1-p4) expenditure(expfd) demographics(nkids income) nolog 
quaidsce w1-w4, anot(10) prices(p1-p4) expenditure(expfd) demographics(nkids income) nolog nocensor
quaidsce w1-w4, anot(10) prices(p1-p4) expenditure(expfd) demographics(nkids income) nolog 

log close




