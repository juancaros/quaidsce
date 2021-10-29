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

gen nkids = int(runiform()*4)
gen rural = (runiform() > 0.2)
gen income = exp(rnormal())+exp(rnormal())

/*
quaids w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog 
estat uncompensated, atmeans
mat define orale=  r(uncompelas)
mat list orale

*orale[5,5]
*            c1          c2          c3          c4          c5
*r1  -.65402369  -.15466283  -.09667678  -.09535059  -.04164129
*r2  -.21527343  -.65645026   .03375876   .00593423   -.0215072
*r3  -.38990361   .05398783  -.62667958  -.10153493   .07453049
*r4  -.14469442  -.02361435  -.04087145  -.84323998   .04214077
*r5  -.08273809  -.06005829   .02626937   .03599686  -.98202648
*/

quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog nocensor
estat uncomp
mat define orale2=  r(elas_u)
mat list orale2

/*
orale2[5,5]
            c1          c2          c3          c4          c5
r1  -.64534912  -.89931613  -.95456507  -.94570892  -.85438557
r2  -.24199662  -.65231209   .06769473   .01920772  -.01932869
r3  -.39310898   .05356852   -.6269222   -.1053927   .02234835
r4   -.1433446  -.02419149  -.04168211   -.8437668   .02328233
r5  -.07189021  -.06213448   .02285732   .03540848  -.98487215
*/



/* IGNORA ESTO DE ABAJO
. sum jcsh*

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
jcsh_lnpin~x |      1,000    9.830901           0   9.830901   9.830901
  jcsh_gsum1 |      1,000   -2.08e-17           0  -2.08e-17  -2.08e-17
  jcsh_gsum2 |      1,000   -.0559635           0  -.0559635  -.0559635
  jcsh_gsum3 |      1,000    .0252636           0   .0252636   .0252636
  jcsh_gsum4 |      1,000   -.0464364           0  -.0464364  -.0464364
-------------+---------------------------------------------------------
  jcsh_gsum5 |      1,000    .0206204           0   .0206204   .0206204
   jcsh_bofp |      1,000   -.0928249           0  -.0928249  -.0928249
jcsh_betanz1 |      1,000    -.246818           0   -.246818   -.246818
jcsh_betanz2 |      1,000    .0335353           0   .0335353   .0335353
jcsh_betanz3 |      1,000    .0761931           0   .0761931   .0761931
-------------+---------------------------------------------------------
jcsh_betanz4 |      1,000    .0755592           0   .0755592   .0755592
jcsh_betanz5 |      1,000    .0615304           0   .0615304   .0615304
   jcsh_mbar |      1,000     2.95169           0    2.95169    2.95169
   jcsh_cofp |      1,000   -2.84e-16           0  -2.84e-16  -2.84e-16


//From do file "test_JCSH_step_..." 

 sum lnpindex gsum* bofp betanz* mbar cofp

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
    lnpindex |      1,000    9.832472           0   9.832472   9.832472
       gsum1 |      1,000    1.79e-09           0   1.79e-09   1.79e-09
       gsum2 |      1,000   -.0559635           0  -.0559635  -.0559635
       gsum3 |      1,000    .0252636           0   .0252636   .0252636
       gsum4 |      1,000   -.0464364           0  -.0464364  -.0464364
-------------+---------------------------------------------------------
       gsum5 |      1,000    .0206204           0   .0206204   .0206204
        bofp |      1,000   -.0928249           0  -.0928249  -.0928249
     betanz1 |      1,000    -.246818           0   -.246818   -.246818
     betanz2 |      1,000    .0335353           0   .0335353   .0335353
     betanz3 |      1,000    .0761931           0   .0761931   .0761931
-------------+---------------------------------------------------------
     betanz4 |      1,000    .0755592           0   .0755592   .0755592
     betanz5 |      1,000    .0615304           0   .0615304   .0615304
        mbar |      1,000     2.95169           0    2.95169    2.95169
        cofp |      1,000    9.93e-35           0   9.93e-35   9.93e-35

. 


