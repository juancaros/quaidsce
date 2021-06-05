clear all
cd "C:\ado\personal\_"
do _quaidsce__utils.mata
lmbuild lquaidsce.mlib, replace dir( C:\ado\personal\l\)

webuse food, clear
program drop _all
set trace on
set tracedepth 4
set matadebug on
mata: mata set matalnum on

set seed 1
gen nkids = int(runiform()*4)
gen rural = (runiform() > 0.7)

*quaids w1-w4, anot(10) prices(p1-p4) expenditure(expfd) demographics(nkids rural) nolog 
quaidsce w1-w4, anot(10) prices(p1-p4) expenditure(expfd) demographics(nkids rural) nolog 




