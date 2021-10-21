clear all
*capture log close
*set maxvar 10000
*cd "C:\ado\plus\u"  //set path

*net install quaidsce, replace force from("https://juancaros.github.io/quaidsce")
*do utils__quaidsce.mata //run mata to update libraries
*lmbuild lquaidsce.mlib, replace dir(C:\Users\juan.caro\ado\plus)
quiet do "C:\Users\juanp\OneDrive\Documentos\GitHub\quaidsce\utils__quaidsce.mata" //run mata to update libraries
*lmbuild lquaidsce.mlib, replace dir(C:\ado\plus\l)

*log using  "C:\Users\jccaro\quaidsce\quaidsce\test.log", replace
webuse food, clear
program drop _all

keep if _n<1001

***debugginb tools
*set trace on
*set tracedepth 4
*set matadebug on
*mata: mata set matalnum on

set seed 1
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

*quaids w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog 
*estat uncompensated, atmeans
*mat define orale=  r(uncompelas)
*mat list orale

*orale[5,5]
*            c1          c2          c3          c4          c5
*r1   -.6217292  -.12679962   -.1195767  -.07070947  -.00187313
*r2  -.25042946  -.70313731   .05739774  -.03900571  -.06771602
*r3  -.50544677   .14207981  -.62689343  -.03422957   .06902285
*r4  -.11840447  -.02686985  -.01353957  -.84422253    .0451797
*r5  -.08565155  -.09800259    .0138488   .00852168  -1.0088073

quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog nocensor
estat uncomp

mat define orale2=  r(elas_u)
mat list orale2

//When using we`i'
*orale2[5,5]
*            c1          c2          c3          c4          c5
*r1  -.11128024  -1.2469336  -1.1864109  -1.0067528  -.73158057
*r2  -.17599353  -.77913664   .04681665  -.02291422  -.04369009
*r3  -.46278706   .12161693   -.6674535  -.03579272    .0545112
*r4  -.11289211  -.02208934   -.0052683  -.85344533   .04288648
*r5   .09439401   .07545404   .12484363   .13262527  -.87066628

//When using w`i'm
*mat list orale2
*orale2[5,5]
*            c1          c2          c3          c4          c5
*r1  -.79280104  -.29071409  -.27660362  -.23471756  -.17056303
*r2  -.24248296  -.69569562   .06450374   -.0315711  -.06019598
*r3  -.51822725   .13618619  -.62761565  -.04008055   .06104144
*r4  -.12230936  -.02393199  -.00570777  -.84122001   .04646399
*r5   .17602191   .14070346   .23280306   .24731393  -.75882401



/*
*quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog  method(nls)



estat uncomp
return list

mat define orale=  r(elas_u)
mat list orale


mat define orale_se=  r(se_elas_u)
mat list orale_se


predict orale*
sum orale*
drop orale*

*log close


