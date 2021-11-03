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


log using  "C:\Users\juanp\OneDrive\Documentos\GitHub\quaidsce\test_JCSH.log", replace

/***********************************
************************************
************************************
NO QUADRATICS AND NO DEMOGRAPHICS
************************************
************************************
***********************************/

quiet quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) nolog noquadratic 

estat uncomp
mat define unce_quaidsce=  r(elas_u)
mat list unce_quaidsce

/*unce_quaidsce[5,5]
            c1          c2          c3          c4          c5
r1  -.99263683  -.01490496    .0093704   .00311374  -.00761513
r2  -.01295257  -1.0304606   .00247527   .07277699  -.00456891
r3   .04393125  -.01018839  -.99590467   .02935508  -.04338002
r4  -.00155132   .03256498   .00751026  -1.0265612   .00097298
r5  -.01423018   .00191485  -.02334516  -.01232966  -.96580099*/


estat exp
mat define ee_quaidsce=  r(elas_i)
mat list ee_quaidsce

*ee_quaidsce[1,5]
*           c1         c2         c3         c4         c5
*r1  1.0104104  .99842258  .97642779  .98647887  1.0154739

estat comp
mat define ce_quaidsce=  r(elas_c)
mat list ce_quaidsce


/***********************************
************************************
************************************
NO QUADRATICS AND DEMOGRAPHICS
************************************
************************************
***********************************/
quiet quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog noquadratic 
estat uncomp
mat define unce_quaidsce=  r(elas_u)
mat list unce_quaidsce

estat exp
mat define ee_quaidsce=  r(elas_i)
mat list ee_quaidsce

estat comp
mat define ce_quaidsce=  r(elas_c)
mat list ce_quaidsce



/***********************************
************************************
************************************
QUADRATICS AND NO DEMOGRAPHICS
************************************
************************************
***********************************/

quiet quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) nolog 
estat uncomp
mat define unce_quaidsce=  r(elas_u)
mat list unce_quaidsce

estat exp
mat define ee_quaidsce=  r(elas_i)
mat list ee_quaidsce

estat comp
mat define ce_quaidsce=  r(elas_c)
mat list ce_quaidsce

/***********************************
************************************
************************************
QUADRATICS AND DEMOGRAPHICS
************************************
************************************
***********************************/
quiet quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog 
estat uncomp
mat define unce_quaidsce=  r(elas_u)
mat list unce_quaidsce

estat exp
mat define ee_quaidsce=  r(elas_i)
mat list ee_quaidsce

estat comp
mat define ce_quaidsce=  r(elas_c)
mat list ce_quaidsce


log close

