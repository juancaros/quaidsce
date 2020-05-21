*tax simulations*
*NOTE: set for 3 demographics but it can be easily modified*
*Carlos Caro, Ago 2019*
version 14 /*stata version*/
clear all
set matsize 800
set maxvar 10000


local vr 9 /*data version*/

*global stata "C:\Users\Usuario\Documents\EPF\VIII EPF\stata"
cd "C:\Users\Usuario\Downloads"
*cd "C:\Users\Usuario\Descargas"

*use "C:\Users\jccaro\Desktop\EPFVII.dta", clear
*use "C:\Users\jccaro\Desktop\DS_6.dta", clear
use "C:\Users\Usuario\Google Drive\Ongoing Research\Concurso Politicas Publicas\Grace\Data\DS_`vr'.dta", clear
*global data "C:\Users\Usuario\Google Drive\Ongoing Research\Concurso Politicas Publicas\Grace\Data"



*************************************************************************
************************* STEP 0: Define Locals and Sample *****************
*************************************************************************
*** Define locals ***
local f 0 /* f=0 if estimation for whole sample, f 1 is estimation by groups*/
local QL 0/* Number of groups*, QL=0 if f=0*/
local ql 4
local x 17 /* Number of categories*/
local v1 median /* mean = tax rates based on mean nutrients or median =tax  rates based on median nutrients*/
local v2 p50 /* mean = lp and lnexp x4 x1*/
local nutr 4 /* number of nutrients in the output*/
*
global est "C:\Users\Usuario\Google Drive\Ongoing Research\Concurso Politicas Publicas\Grace\Data\all"
global results "C:\Users\Usuario\Google Drive\Ongoing Research\Concurso Politicas Publicas\Grace\results\all"


***Rename
rename cpi_excl p17
rename FE projection
***Define groups
drop QL
gen f=`f'
xtile QL=ING_TOTAL_HOG_HD[aw=projection], n(`ql') 
replace QL=0  if f==0
***Drop outliers
*sum outlier*
*drop if outlier_FAH==1
*drop if outlier_p==1
save "$est\DS", replace 
*************************************************************************
************************* STEP 1: ESTIMATE QUAIDS *****************
*************************************************************************
use "$est\DS", clear
* Defined parameters

{
local par
set seed 1
forval i=1(1)158 {
local par `par' bb_`i'=r(bb[`i',1]) 
}

forval i=1(1)17 {
rename hh_q`i' QME`i'
gen w`i'=hh_shill`i'/total_exp
}

forval i=1(1)17 {
gen lnp`i'=log(p`i')/*GM*/
}


*rename NEA x1
rename EA x1
*rename EDUE x2
rename Shop_CollegeDegree x2
*rename ZONA x3
rename region x3
*rename SEXO x4
*rename Shop_F x4
*rename SES x5
rename QL x5
*rename EDAD x6
rename Shop_F_under35 x6
gen login=log(ttl_income+1)
rename login x7
gen lnexp=log(total_exp)
*replace FE=round(FE)
*drop if QI>2

save temp, replace
***quaids, using control function to account for expenditure endogeneity***


local QL 4

forv i=`f'(1)`QL'{
local QL `i'
use temp, clear
keep if x5==`QL'

order w*
*drop x4
reg lnexp x1 x2 x3 x6 x7   /*variables that predict expenditure*/
predict x4, r

/*QUAIDS_ELAS_IC should be around here*/

quaids w1-w17 , anot(5) lnpr(lnp1-lnp17) demo(x1 x2 x3 x4) lnexp(lnexp) 
*aidsills w1-w17 , alpha_0(5) pri(p1-p17) int(x1 x2 x3 x4) exp(total_exp) qua hom sym
*aidsills_elas

save "$est\temp_`QL'", replace
estimates save "$est\quaids`f'_`QL'", replace
}
}


*************************************************************************
************************* STEP 2: Nutrient Predictions *****************
*************************************************************************

*** Define locals ***
local vr 9   /* version of data*/
local f 0 /* f=0 if estimation for whole sample, f 1 is estimation by groups*/
local QL 0 /* Number of groups*/
local x 17 /* Number of categories*/
local v1 median /* mean = tax rates based on mean nutrients or median =tax  rates based on median nutrients*/
local nutr 4 /* number of nutrients in the output*/

***Calculate tax rates and enter nutrient values*****
{
use "$est\DS", clear
local v median

{
*********************************************************************
* Calculate Unit Values and import nutrient values
*********************************************************************


forvalues i = 1/`x' {
gen uv`i'=0
replace uv`i'=hh_shill`i'/(hh_q`i'*1000)*100 /*calculate unit values per 100 g of product*/
egen up`i'`i'=mean(uv`i'), by(QL)
replace up`i'=up`i'*p`i'
egen uv_ip_`i'=mean(up`i'), by(QL)
}


collapse (max)uv_ip*, by( QL)


mi set wide 
gen _mi_miss=0
mi reshape long uv_ip_, i(QL) j(group)

rename uv_ip_ uv_ip
drop _mi_miss
rename group grupo

save uv_ip, replace 

use "$est\nut_matrix_`f'", clear /* created with tables do file*/
merge 1:1 QL grupo using uv_ip 
drop _merge

save nut_uv, replace 

*********************************************************************
* Calculate Tax Rates 
*********************************************************************


use nut_uv, clear

scalar t1=1.94 /*pesos/g of nutrient*/
scalar t2=0.023 /* pesos per mg nutrient*/
scalar t3=2 /*pesos/g of nutrient*/

* nutrients in CLP/100 g of food

gen tax_1=t1*wht_`v'_sugar
gen tax_2=t2*wht_`v'_sodium
gen tax_3=t3*wht_`v'_fats
gen tax_tot=tax_1+tax_2+tax_3

*Unit value is expressed CLP/ 100 g 

gen taxr_1=tax_1/(uv_ip)
gen taxr_2=tax_2/(uv_ip)
gen taxr_3=tax_3/(uv_ip)
gen taxr_tot=tax_tot/(uv_ip)

// Ley de Etiquetado 2019
local sugar 10
local sodium 400
local fats 4

gen h_tax_1=1
replace h_tax_1=0 if wht_`v'_sugar<`sugar'
gen h_tax_2=1
replace h_tax_2=0 if wht_`v'_sodium<`sodium'
gen h_tax_3=1
replace h_tax_3=0 if wht_`v'_fats<`fats'
gen h_tax=h_tax_1+h_tax_2+h_tax_3
drop h_tax_1 h_tax_2 h_tax_3




* Round tax values
replace taxr_1=round(taxr_1,0.001)
replace taxr_2=round(taxr_2,0.001)
replace taxr_3=round(taxr_3,0.001)
replace taxr_tot=round(taxr_tot,0.001)

* eliminate tax to healthy foods
replace taxr_1=0 if h_tax==0
replace taxr_2=0 if h_tax==0
replace taxr_3=0 if h_tax==0
replace taxr_tot=0 if h_tax==0

rename grupo group

* ELiminate  fat tax to fats and oils
*replace taxr_1=0 if group==16
*replace taxr_2=0 if group==16
*replace taxr_3=0 if group==16
*replace taxr_tot= taxr_1+  taxr_3+  taxr_3 if group ==16

* Eliminate tax to FV
replace taxr_1=0 if group==9|group==10 
replace taxr_2=0 if group==9|group==10 
replace taxr_3=0 if group==9|group==10 
replace taxr_tot=0 if group==9|group==10 

* ELiminate tax to SSB 
replace taxr_1=0 if group==15
replace taxr_2=0 if group==15
replace taxr_3=0 if group==15
replace taxr_tot=0 if group==15


* ELiminate tax to Hot drinks 
replace taxr_1=0 if group==14
replace taxr_2=0 if group==14
replace taxr_3=0 if group==14
replace taxr_tot=0 if group==14

* ELiminate tax in numeraire
replace taxr_1=0 if group==17
replace taxr_2=0 if group==17
replace taxr_3=0 if group==17
replace taxr_tot=0 if group==17





keep wht_`v'_sugar wht_`v'_sodium wht_`v'_fats wht_`v'_kcal group QL taxr_* h_tax 

rename  taxr_1 `v'_taxr_1 
rename  taxr_2 `v'_taxr_2 
rename  taxr_3 `v'_taxr_3 
rename  taxr_tot `v'_taxr_tot
rename h_tax `v'_h_tax
 }
save nut_`v'_tax_matrix, replace



************ STEP 0: Calculate mean tax rates and  nutrient values: calculate weighted mean of nutrients***********************



use "$est\DS", clear

{
local t mean
foreach var of numlist 1/7 {
foreach i of numlist 1/`x' {
bysort QL:gen mean_unit_nut`var'_`i'=sum(hh_nut`var'_`i')/sum(hh_q`i'*1000)  /*nutrients are reported in g and sodium in mg*/
*bysort QL:gen mean_unit_nut`var'_`i'=sum(projection*hh_nut`var'_`i')/sum(projection*hh_q`i'*1000) 
replace  mean_unit_nut`var'_`i'=mean_unit_nut`var'_`i'*100 /* for 100 g*/
}
}


/*GM
local J 16
local x 17
forvalues i = 1/`J' {
gen  lp`i'=log(p`i')
}
*/


*calculate unit values per 100 g of product
forvalues i = 1/`x' {
gen uv`i'=hh_shill`i'/(hh_q`i'*1000)*100 /* for 100 g*/
egen up`i'`i'=mean(uv`i'), by(QL)
replace up`i'=up`i'*p`i'
egen uv_ip_`i'=mean(up`i'), by(QL)
}
 
foreach var of numlist 1/7 {
foreach i of numlist 1/`x' {
gen  unit_nut`var'_`i'=`t'_unit_nut`var'_`i'
}
}


*define tax rate
*					sugar 	sodium 	sat fat
*this study rates	1,94	0,023	2
*WHO rates			1,94	0,023	30,58
*1980 rates			0,84	0,023	22,94
scalar t1=1.94 /*pesos/g of nutrient*/
scalar t2=0.023 /* pesos per mg nutrient*/
scalar t3=2 /*pesos/g of nutrient*/

*keep wht_mean_sugar wht_mean_sodium wht_mean_fat 

/*
rename  carbohydrates hh_nut1
rename  fat hh_nut2
rename  fats hh_nut3
rename  kcal hh_nut4
rename  proteins hh_nut5
rename  sodium  hh_nut6
rename  sugar hh_nut7
*/


foreach i of numlist 1/`x' {
* tax per 100 g product
gen tax_1_`i'=t1*unit_nut7_`i'
gen tax_2_`i'=t2*unit_nut6_`i'
gen tax_3_`i'=t3*unit_nut3_`i'
gen tax_tot_`i'=tax_1_`i'+tax_2_`i'+tax_3_`i'
*Unit value is expressed CLP/ 100 g 
gen taxr_1_`i'=tax_1_`i'/(uv_ip_`i')
gen taxr_2_`i'=tax_2_`i'/(uv_ip_`i')
gen taxr_3_`i'=tax_3_`i'/(uv_ip_`i')
gen taxr_tot_`i'=tax_tot_`i'/(uv_ip_`i')

}

* Eliminate tax to Fruits
* Eliminate tax to Vegetables
* ELiminate tax to SSB 
* ELiminate tax in numeraire
/*
local x 17
foreach i of numlist   10 11 15 17{
replace taxr_1_`i'=0
replace taxr_2_`i'=0
replace taxr_3_`i'=0
replace taxr_tot_`i'=0
}
*/

collapse (max)taxr* (max)unit_nut*, by( QL)
save tax_nut, replace



use tax_nut, clear
keep taxr_1_* taxr_2_* taxr_3_*  taxr_tot_* unit_nut7_* unit_nut6_* unit_nut3_* QL unit_nut4_*
order taxr_1_* taxr_2_* taxr_3_*  unit_nut7_* unit_nut6_* unit_nut3_*


mi set wide 
gen _mi_miss=0
mi reshape long taxr_1_ taxr_2_ taxr_3_  taxr_tot_ unit_nut7_ unit_nut6_ unit_nut3_ unit_nut4_ , i(QL) j(group)
drop _mi_miss


rename taxr_1_ taxr_1
rename taxr_2_ taxr_2
rename taxr_3_ taxr_3
rename taxr_tot_ taxr_tot
rename unit_nut7_ unit_sugar
rename unit_nut6_ unit_sodium
rename unit_nut3_ unit_fats
rename unit_nut4_ unit_kcal

// Ley de Etiquetado 2019
local sugar 10
local sodium 400
local fats 4

/*
gen h_tax_1=1
replace h_tax_1=0 if unit_sugar<`sugar'
gen h_tax_2=1
replace h_tax_2=0 if unit_sodium<`sodium'
gen h_tax_3=1
replace h_tax_3=0 if unit_fats<`fats'
gen h_tax=h_tax_1+h_tax_2+h_tax_3
drop h_tax_1 h_tax_2 h_tax_3
*/
*gen h_tax=1
*replace h_tax=0 if group<3|group==4|group==9|group==10|group==11
* Use criteria of weighted median
gen h_tax=1 
replace h_tax=0 if group==1|group==4|group==6|group==9|group==10|group==11|group==17  /* based on outcome do file quaidssim  using weighed median nutrients*/
*replace h_tax=0 if group==16 /* fats and oil*/



* Round tax values
replace taxr_1=round(taxr_1,0.001)
replace taxr_2=round(taxr_2,0.001)
replace taxr_3=round(taxr_3,0.001)
replace taxr_tot=round(taxr_tot,0.001)

* eliminate tax to healthy foods
replace taxr_1=0 if h_tax==0
replace taxr_2=0 if h_tax==0
replace taxr_3=0 if h_tax==0
replace taxr_tot=0 if h_tax==0

* ELiminate  fat tax to fats and oils
*replace taxr_1=0 if group==16
*replace taxr_2=0 if group==16
*replace taxr_3=0 if group==16
*replace taxr_tot= taxr_1+  taxr_3+  taxr_3 if group ==16

* Eliminate tax to FV
replace taxr_1=0 if group==9|group==10 
replace taxr_2=0 if group==9|group==10 
replace taxr_3=0 if group==9|group==10 
replace taxr_tot=0 if group==9|group==10 

* ELiminate tax to SSB 
replace taxr_1=0 if group==15
replace taxr_2=0 if group==15
replace taxr_3=0 if group==15
replace taxr_tot=0 if group==15

* ELiminate tax to Hot drinks 
replace taxr_1=0 if group==14
replace taxr_2=0 if group==14
replace taxr_3=0 if group==14
replace taxr_tot=0 if group==14


* ELiminate tax in numeraire
replace taxr_1=0 if group==17
replace taxr_2=0 if group==17
replace taxr_3=0 if group==17
replace taxr_tot=0 if group==17


}
save nut_`t'_tax_matrix, replace 




*** merge mean and median calculations
use nut_median_tax_matrix, clear /* use median nutrient values and the corresponging tax rates */
merge 1:1 group QL using  nut_mean_tax_matrix /* use mean nutrient values and the corresponging tax rates */
drop _merge



rename wht_median_sugar median_sugar
rename wht_median_sodium median_sodium
rename wht_median_fats median_fats

rename unit_sugar mean_sugar
rename unit_sodium mean_sodium
rename unit_fats mean_fats

rename h_tax mean_h_tax

rename taxr_1 mean_taxr_1
rename taxr_2 mean_taxr_2
rename taxr_3 mean_taxr_3
rename taxr_tot mean_taxr_tot


}
save "$est\nut_tax_matrix", replace
***Estimate Elasticities and Output ***

***Predictions Calculation ***
forv i=`f'(1)`QL'{

local QL `i'
use "$est\temp_`QL'", clear
estimates use "$est\quaids`f'_`QL'"
est store quaids`f'_`QL'
est restore quaids`f'_`QL'
estat expenditure, atmeans
matrix e_exp_`QL'=r(expelas)
estat uncomp, atmeans stderrs
matrix e_`QL'=r(uncompelas)
matrix esd_`QL'=r(sd)
*matrix list e_`QL'
matrix esd=esd_`QL'

*use temp_`QL', clear
*use temp, clear

matrix  e_exp_`QL'= e_exp_`QL''
mat r=J(17,1,0)
mat r=(1\2\3\4\5\6\7\8\9\10\11\12\13\14\15\16\17)
mat c=r'


putexcel set "$results\output_e_v`vr'.xlsx", sheet(QL`QL') modify
putexcel B1=matrix(c)
putexcel A2=matrix(r)
putexcel S1="e_exp"

putexcel B19="SE"
putexcel B2=matrix(e_`QL')
putexcel S2=matrix(e_exp_`QL')
putexcel B20=matrix(esd_`QL')




***  enter tax  rates and nutrients
{
/*
* average nutrients per 100 g of product

local 	a1	0.31
local 	a2	5.91
local 	a3	25.04
local 	a4	0.00
local 	a5	1.02
local 	a6	4.72
local 	a7	12.38
local 	a8	1.07
local 	a9	9.82
local 	a10	1.10
local 	a11	2.11
local 	a12	16.09
local 	a13	26.59
local 	a14	0.00
local 	a15	8.60
local 	a16	0.00
local 	a17	6.08
local 	b1	5.00
local 	b2	508.00
local 	b3	248.28
local 	b4	85.39
local 	b5	994.80
local 	b6	63.15
local 	b7	54.14
local 	b8	684.62
local 	b9	1.00
local 	b10	6.00
local 	b11	12.00
local 	b12	53.03
local 	b13	247.79
local 	b14	2.00
local 	b15	11.01
local 	b16	0.06
local 	b17	9.36
local 	c1	0.24
local 	c2	0.78
local 	c3	1.43
local 	c4	2.69
local 	c5	5.80
local 	c6	0.90
local 	c7	1.08
local 	c8	17.35
local 	c9	0.03
local 	c10	0.03
local 	c11	0.15
local 	c12	4.49
local 	c13	9.04
local 	c14	0.00
local 	c15	0.00
local 	c16	18.62
local 	c17	0.12
local 	k1	365.00
local 	k2	267.00
local 	k3	376.63
local 	k4	155.58
local 	k5	210.14
local 	k6	44.60
local 	k7	84.74
local 	k8	343.20
local 	k9	52.00
local 	k10	41.00
local 	k11	347.00
local 	k12	150.94
local 	k13	462.43
local 	k14	1.00
local 	k15	35.10
local 	k16	884.74
local 	k17	35.93



* tax rates

local 	d1	0.00
local 	d2	0.09
local 	d3	0.10
local 	d4	0.00
local 	d5	0.00
local 	d6	0.10
local 	d7	0.10
local 	d8	0.00
local 	d9	0.00
local 	d10	0.00
local 	d11	0.01
local 	d12	0.06
local 	d13	0.10
local 	d14	0.00
local 	d15	0.00
local 	d16	0.00
local 	d17	0.00
local 	e1	0.00
local 	e2	0.09
local 	e3	0.01
local 	e4	0.01
local 	e5	0.05
local 	e6	0.02
local 	e7	0.01
local 	e8	0.03
local 	e9	0.00
local 	e10	0.00
local 	e11	0.00
local 	e12	0.00
local 	e13	0.01
local 	e14	0.00
local 	e15	0.00
local 	e16	0.00
local 	e17	0.00
local 	f1	0.00
local 	f2	0.01
local 	f3	0.01
local 	f4	0.01
local 	f5	0.03
local 	f6	0.02
local 	f7	0.01
local 	f8	0.06
local 	f9	0.00
local 	f10	0.00
local 	f11	0.00
local 	f12	0.02
local 	f13	0.04
local 	f14	0.00
local 	f15	0.00
local 	f16	0.21
local 	f17	0.00
local 	g1	0.01
local 	g2	0.20
local 	g3	0.12
local 	g4	0.02
local 	g5	0.08
local 	g6	0.13
local 	g7	0.12
local 	g8	0.09
local 	g9	0.00
local 	g10	0.00
local 	g11	0.01
local 	g12	0.07
local 	g13	0.15
local 	g14	0.00
local 	g15	0.00
local 	g16	0.21
local 	g17	0.00


*/



/*
***tax rates from table_taxr_17 **

mat ts1=(`d1',`d2',`d3',`d4',`d5',`d6',`d7',`d8',`d9',`d10',`d11',`d12',`d13',`d14',`d15',`d16',`d17')
mat ts2=(`e1',`e2',`e3',`e4',`e5',`e6',`e7',`e8',`e9',`e10',`e11',`e12',`e13',`e14',`e15',`e16',`e17')
mat ts3=(`f1',`f2',`f3',`f4',`f5',`f6',`f7',`f8',`f9',`f10',`f11',`f12',`f13',`f14',`f15',`f16',`f17')
mat ts4=(`g1',`g2',`g3',`g4',`g5',`g6',`g7',`g8',`g9',`g10',`g11',`g12',`g13',`g14',`g15',`g16',`g17')
*/


/*
***preliminary data input (enter tax rates manually)***

mat ts1=(.01,.04,.03,0,0,.02,.02,0,0,0,.01,.03,.03,0,.06,0,0)
mat ts2=(0,.23,.01,0,.04,.01,0,.02,0,0,.01,0,.01,0,0,0,0)
mat ts3=(.04,.47,.05,.11,.26,.12,.06,.48,0,0,.04,.19,.30,0,0,0,0)
mat ts4=(.04,.74,.09,.11,.3,.14,.08,.5,0,0,.06,.23,.34,0,.06,0,0)
mat ts5=(0,.18,.18,0,.18,.18,.18,.18,0,0,0,.18,.18,0,0,.18,0)

/*matrix of nutrients: sugar, sodium, sfat (g/100 g de producto)*/
mat nt1=(.3,5.9,25,0,1,4.7,12.4,1.1,9.8,1,2.1,16.1,26.6,0,8.6,0,6.1)
mat nt2=(5,508,248,85,995,63,54,685,1,6,12,53,248,2,11,0,9) /*sodium in mg*/
mat nt2=nt2/1000 /*sodium in grams*/
mat nt3=(.2,.8,1.4,2.7,5.8,0.9,1.1,17.4,0,0,.2,4.5,9,0,0,18.6,0.1)

/*matrix of nutrients: sugar, sodium, sfat (g/100 g de producto)*/
mat nt1=(`a1',`a2',`a3',`a4',`a5',`a6',`a7',`a8',`a9',`a10',`a11',`a12',`a13',`a14',`a15',`a16',`a17')
mat nt2=(`b1',`b2',`b3',`b4',`b5',`b6',`b7',`b8',`b9',`b10',`b11',`b12',`b13',`b14',`b15',`b16',`b17')  /*sodium in mg*/
mat nt2=nt2/1000 /*sodium in grams*/
mat nt3=(`c1',`c2',`c3',`c4',`c5',`c6',`c7',`c8',`c9',`c10',`c11',`c12',`c13',`c14',`c15',`c16',`c17')
mat nt4=(`k1',`k2',`k3',`k4',`k5',`k6',`k7',`k8',`k9',`k10',`k11',`k12',`k13',`k14',`k15',`k16',`k17')

*/
}

***tax rates as defined above **
*local v1 median 
*local i 1
use "$est\nut_tax_matrix", replace
keep if QL==`i'
*keep unit_*

mkmat  `v1'_* , mat(nut)
*mat list nut
mat nut=nut'
mat nt1= nut[1..1,.]
*mat list nt1
mat nt2=nut[2..2,.]
mat nt3=nut[3..3,.]
mat nt4=nut[4..4,.]

mkmat  `v1'_taxr_*  , mat(tax)
mat tax=tax'
*mat list tax
mat ts1=tax[1..1,.]
mat ts2=tax[2..2,.]
mat ts3=tax[3..3,.]
mat ts4=tax[4..4,.]


***tax rates defined by JCC*
mat ts5=(0,.18,.18,0,.18,.18,.18,.18,0,0,0,.18,.18,0,0,.18,0)


/*matrix of nutrients: sugar, sodium, sfat are  defined per 100 g convert to(g/kg of producto)*/
mat nt1=nt1*10
mat nt2=nt2*10
mat nt3=nt3*10
mat nt4=nt4*10

mat nt= nt1\nt2\nt3\nt4
*mat nt = nt1\nt2\nt3





use "$est\temp_`QL'", clear
*gen lnpt=.
*gen aux=.

forv j=1(1)5{
local ts `j' /*scenario for tax simulation*/


mat ts=ts`ts' /*tax rates as % (chosen from scenarios above)*/


mat tsq2=J(1,17,0) /*matrix of tax rates (squared)*/
mat ntq2=J(`nutr',17,0) /*matrix of nutriets: sugar, sodium, sfat (squared)*/

forv i=1(1)17{
mat tsq2[1,`i']=ts[1,`i']*ts[1,`i']
forv j=1(1)4{
mat ntq2[`j',`i']=nt[`j',`i']*nt[`j',`i']
}
}

*forv i=1(1)17{
*local tax=ts[1,`i']
*gen lnpt`i'=lnp`i'+log(1+`tax')
*drop lnpt`i'
*gen lnpt`i'=log(exp(lnp`i')*(1+`tax'))
*}


mat q1=e_`QL'*ts' /*vector of q variation (%) */
mat q1_g=q1 /*vector of q*/
mat q0_g=q1 
***quantity and nutrient calculations per product***

/*
gen aux`i'=QME`i'/(30*x1) 
local i 16
sum QME`i', d 
*/
forv i=1(1)17{
*gen aux`i'=QME`i'/(30*hh_size)
*drop aux`i'
gen aux`i'=QME`i'/(30*x1) /*x1 is adult equivalent*/
*qui sum aux`i' if x7>13.83 & x7<13.84 ,d
qui sum aux`i'  ,d  
local aux0=r(p50)

mat q1_g[`i',1]=1000*`aux0'*q1[`i',1] /*vector of q variation (g/day/capita)*/
mat q0_g[`i',1]=1000*`aux0' 


}

mat list q0_g

*** use the nutrient mean as defined above from table_taxr_17_GM
* convert in g of nut per kg product



forv i=1(1)`nutr'{
mat n`i'=J(17,1,0)
} 

forv j=1(1)17{ /*sugar*/
mat n1[`j',1]=nt[1,`j']*q1_g[`j',1]/1000 /*vector of nut variation per product (gr/day/capita)*/
}

forv j=1(1)17{ /*sodium*/
mat n2[`j',1]=nt[2,`j']*q1_g[`j',1]/1000 /*vector of nut variation per product (gr/day/capita)*/
}

forv j=1(1)17{ /*sat fats*/
mat n3[`j',1]=nt[3,`j']*q1_g[`j',1]/1000 /*vector of nut variation per product (gr/day/capita)*/
}

forv j=1(1)17{ /*kcal*/
mat n4[`j',1]=nt[4,`j']*q1_g[`j',1]/1000 /*vector of nut variation per product (gr/day/capita)*/
}


mat q1se=q1 /*se of q variation*/

forv i=1(1)17{
local aux0=0
forv j=1(1)17{
qui sum aux`j',d
*qui sum aux`j' if x7>13.83 & x7<13.84 ,d

local aux=r(p50)
local aux0= `aux0'+`aux'*`aux'*esd[`i',`j']*esd[`i',`j']*tsq2[1,`j'] 
}
mat q1se[`i',1]= sqrt(`aux0')
}

*matrix list q1se


*** nutrient calculations overall***


mat qn1=nt*q1_g/1000 /*vector of total nut variation*/
mat qn0=nt*q0_g/1000 /*vector of total nut  base line*/



mat qn1se=qn1 /*se of total nut variation*/

forv i=1(1)`nutr'{
local aux0=0
forv j=1(1)17{
*qui sum aux`j' if x7>13.83 & x7<13.84 ,d
qui sum aux`j',d

local aux=r(p50)
local aux0=`aux0'+ q1se[`j',1]*q1se[`j',1]*ntq2[`i',`j']*`aux'*`aux' 
}
mat qn1se[`i',1]= sqrt(`aux0')
}

mat outputA_`ts'_`QL' = ts', n1, n2, n3, n4
*mat c=(1, 0,0, 0\0,1,0, 0\0,0,1,0\0,0,0,1 )
mat nut=qn1'
*mat p_nut=(qn1'/qn0')*100-100


mat nutSE=qn1se'
mat outputB_`ts'_`QL'=nut\nutSE
*mat list outputB_`ts'_`QL'

mat outputB2_`ts'_`QL'=qn0'
*mat list outputB2_`ts'_`QL'

*drop lnpt* 
drop aux* 

}


}
*** Output Predictions***
forv i=`f'(1)`QL'{
local QL `i'
putexcel set "$results\output_TS_`v1'_v`vr'.xlsx", sheet(QL`QL') modify
*mat list outputA_`ts', format(%3.2f) /*vector of  nut variation per product*/
*mat list outputB_`ts', format(%3.2f)  /*vector of total nut variation, g of sugar, mg sodio, g of sat fat */
putexcel B1="Price_Delta"
putexcel C1="Sugar_Delta"
putexcel D1="Sodium_Delta"
putexcel E1="SatFat_Delta"
putexcel F1="Kcal_Delta"


putexcel H1="Sugar_Delta"
putexcel I1="Sodium_Delta"
putexcel J1="SatFat_Delta"
putexcel K1="Kcal_Delta"



putexcel N1="Sugar"
putexcel O1="Sodium"
putexcel P1="SatFat"
putexcel Q1="Kcal"


putexcel G2="TS1"
putexcel G4="TS2"
putexcel G6="TS3"
putexcel G8="TS4"
putexcel G10="TS5"

local ts 1
putexcel B2=matrix(outputA_`ts'_`QL')
putexcel H2=matrix(outputB_`ts'_`QL')
putexcel N2=matrix(outputB2_`ts'_`QL')

local ts 2
*mat list outputA_`ts', format(%3.2f) /*vector of  nut variation per product*/
putexcel B20=matrix(outputA_`ts'_`QL')
putexcel H4=matrix(outputB_`ts'_`QL')
putexcel N4=matrix(outputB2_`ts'_`QL')


local ts 3
putexcel B40=matrix(outputA_`ts'_`QL')
putexcel H6=matrix(outputB_`ts'_`QL')
putexcel N6=matrix(outputB2_`ts'_`QL')

local ts 4
putexcel B60=matrix(outputA_`ts'_`QL')
putexcel H8=matrix(outputB_`ts'_`QL')
putexcel N8=matrix(outputB2_`ts'_`QL')

local ts 5
putexcel B80=matrix(outputA_`ts'_`QL')
putexcel H10=matrix(outputB_`ts'_`QL')
putexcel N10=matrix(outputB2_`ts'_`QL')

}


*************************************************************************
************************* STEP 3: welfare calculations*****************
*************************************************************************
*** Define locals ***
local vr 9   /* version of data*/
local f  0/* f=0 if estimation for whole sample, f 1 is estimation by groups*/
local QL 0 /* Number of groups*/
local x 17 /* Number of categories*/
local v1 median /* mean = tax rates based on mean nutrients or median =tax  rates based on median nutrients*/
local v2 p50 /* mean = lp and lnexp x4 x1*/
local nutr 4 /* number of nutrients in the output*/

forv i=`f'(1)`QL'{
local QL `i'

estimates use "$est\quaids`f'_`QL'"
est store quaids`f'_`QL'
est restore quaids`f'_`QL'
*matrix esd=esd_`QL'


************** TAX RATES **************
*** enter manually tax  rates and nutrients

{
/*
* average nutrients per 100 g of product

local 	a1	0.31
local 	a2	5.91
local 	a3	25.04
local 	a4	0.00
local 	a5	1.02
local 	a6	4.72
local 	a7	12.38
local 	a8	1.07
local 	a9	9.82
local 	a10	1.10
local 	a11	2.11
local 	a12	16.09
local 	a13	26.59
local 	a14	0.00
local 	a15	8.60
local 	a16	0.00
local 	a17	6.08
local 	b1	5.00
local 	b2	508.00
local 	b3	248.28
local 	b4	85.39
local 	b5	994.80
local 	b6	63.15
local 	b7	54.14
local 	b8	684.62
local 	b9	1.00
local 	b10	6.00
local 	b11	12.00
local 	b12	53.03
local 	b13	247.79
local 	b14	2.00
local 	b15	11.01
local 	b16	0.06
local 	b17	9.36
local 	c1	0.24
local 	c2	0.78
local 	c3	1.43
local 	c4	2.69
local 	c5	5.80
local 	c6	0.90
local 	c7	1.08
local 	c8	17.35
local 	c9	0.03
local 	c10	0.03
local 	c11	0.15
local 	c12	4.49
local 	c13	9.04
local 	c14	0.00
local 	c15	0.00
local 	c16	18.62
local 	c17	0.12
local 	k1	365.00
local 	k2	267.00
local 	k3	376.63
local 	k4	155.58
local 	k5	210.14
local 	k6	44.60
local 	k7	84.74
local 	k8	343.20
local 	k9	52.00
local 	k10	41.00
local 	k11	347.00
local 	k12	150.94
local 	k13	462.43
local 	k14	1.00
local 	k15	35.10
local 	k16	884.74
local 	k17	35.93



* tax rates

local 	d1	0.00
local 	d2	0.09
local 	d3	0.10
local 	d4	0.00
local 	d5	0.00
local 	d6	0.10
local 	d7	0.10
local 	d8	0.00
local 	d9	0.00
local 	d10	0.00
local 	d11	0.01
local 	d12	0.06
local 	d13	0.10
local 	d14	0.00
local 	d15	0.00
local 	d16	0.00
local 	d17	0.00
local 	e1	0.00
local 	e2	0.09
local 	e3	0.01
local 	e4	0.01
local 	e5	0.05
local 	e6	0.02
local 	e7	0.01
local 	e8	0.03
local 	e9	0.00
local 	e10	0.00
local 	e11	0.00
local 	e12	0.00
local 	e13	0.01
local 	e14	0.00
local 	e15	0.00
local 	e16	0.00
local 	e17	0.00
local 	f1	0.00
local 	f2	0.01
local 	f3	0.01
local 	f4	0.01
local 	f5	0.03
local 	f6	0.02
local 	f7	0.01
local 	f8	0.06
local 	f9	0.00
local 	f10	0.00
local 	f11	0.00
local 	f12	0.02
local 	f13	0.04
local 	f14	0.00
local 	f15	0.00
local 	f16	0.21
local 	f17	0.00
local 	g1	0.01
local 	g2	0.20
local 	g3	0.12
local 	g4	0.02
local 	g5	0.08
local 	g6	0.13
local 	g7	0.12
local 	g8	0.09
local 	g9	0.00
local 	g10	0.00
local 	g11	0.01
local 	g12	0.07
local 	g13	0.15
local 	g14	0.00
local 	g15	0.00
local 	g16	0.21
local 	g17	0.00






***tax rates from table_taxr_17 **

mat ts1=(`d1',`d2',`d3',`d4',`d5',`d6',`d7',`d8',`d9',`d10',`d11',`d12',`d13',`d14',`d15',`d16',`d17')
mat ts2=(`e1',`e2',`e3',`e4',`e5',`e6',`e7',`e8',`e9',`e10',`e11',`e12',`e13',`e14',`e15',`e16',`e17')
mat ts3=(`f1',`f2',`f3',`f4',`f5',`f6',`f7',`f8',`f9',`f10',`f11',`f12',`f13',`f14',`f15',`f16',`f17')
mat ts4=(`g1',`g2',`g3',`g4',`g5',`g6',`g7',`g8',`g9',`g10',`g11',`g12',`g13',`g14',`g15',`g16',`g17')

***tax rates defined by JCC*
mat ts5=(0,.18,.18,0,.18,.18,.18,.18,0,0,0,.18,.18,0,0,.18,0)

*/

}

*** tax rates as defined above in the matrix **
use "$est\nut_tax_matrix", replace
keep if QL==`i'
*keep unit_*

mkmat  `v1'_taxr_*  , mat(tax)
mat tax=tax'
*mat list tax
mat ts1=tax[1..1,.]
mat ts2=tax[2..2,.]
mat ts3=tax[3..3,.]
mat ts4=tax[4..4,.]
***tax rates defined by JCC*
mat ts5=(0,.18,.18,0,.18,0,.18,.18,0,0,0,.18,.18,0,0,.18,0)


forv j=1(1)5{
local ts `j'
mat ts=ts`ts' /*tax rates as % (chosen from scenarios above)*/

use "$est\temp_`QL'", clear
forv i=1(1)17{
local tax=ts[1,`i']
*gen lnpt`i'=lnp`i'+log(1+`tax')
gen lnpt`i'=log(exp(lnp`i')*(1+`tax'))
*sum lnpt`i'
*drop lnpt`i'
}

foreach x of varlist lnp* lnpt* lnexp x4 x1{
qui sum `x', det
*scalar `x'mean=r(mean)
scalar `x'mean=r(`v2')
}

*scalar x1mean=4 /* Number of family members*/
scalar x2mean=1 /* household has at least one main shopper with a college degree*/
scalar x3mean=2 /* household lives in  nonmetro*/
*scalar x6mean=1
*scalar list

**Price indexes at baseline**

glo asum "_b[alpha:alpha_1]*lnp1mean"
glo lp "_b[lambda:lambda_1]*lnp1mean"
glo mo "1+_b[rho:rho_x1]*x1mean+_b[rho:rho_x2]*x2mean+_b[rho:rho_x3]*x3mean+_b[rho:rho_x4]*x4mean"
glo cpz "(_b[eta:eta_x1_1]*x1mean+_b[eta:eta_x2_1]*x2mean+_b[eta:eta_x3_1]*x3mean+_b[eta:eta_x4_1]*x4mean)*lnp1mean"
forv i=2(1)17 {
glo asum "${asum} + (_b[alpha:alpha_`i'] +_b[eta:eta_x1_`i']*x1mean+_b[eta:eta_x2_`i']*x2mean+_b[eta:eta_x3_`i']*x3mean+_b[eta:eta_x4_`i']*x4mean)*lnp`i'mean"
glo lp "${lp} + _b[lambda:lambda_`i']*lnp`i'mean"
glo cpz "${cpz} + (_b[eta:eta_x1_`i']*x1mean+_b[eta:eta_x2_`i']*x2mean+_b[eta:eta_x3_`i']*x3mean+_b[eta:eta_x4_`i']*x4mean)*lnp`i'mean"
}

glo gsum ""
forv i=1(1)17 {
forv j=1(1)17 {
if `i'>=`j' {
glo gsum "${gsum} + 0.5*_b[gamma:gamma_`i'_`j']*lnp`i'mean*lnp`j'mean"
}
*else {
*glo gsum2 "${gsum} + 0.5*_b[gamma:gamma_`j'_`i']*lnp`i'mean*lnp`j'mean"
*}
}
}

glo gsum2 ""
forv i=1(1)17 {
forv j=1(1)17 {
if `j'>`i' {
*glo gsum "${gsum} + 0.5*_b[gamma:gamma_`i'_`j']*lnp`i'mean*lnp`j'mean"
*}
*else {
glo gsum2 "${gsum2} + 0.5*_b[gamma:gamma_`j'_`i']*lnp`i'mean*lnp`j'mean"
}
}
}

*glo ap "5 + ${asum} ${gsum}"
*glo ap "${ap}*${mo}"

glo bp "_b[beta:beta_1]*lnp1mean"
forv i=2(1)17 {
glo bp "${bp} + _b[beta:beta_`i']*lnp`i'mean"
}
glo bp "(exp(${bp}))*(exp(${cpz}))"


**Price indexes after tax**
glo asumt "_b[alpha:alpha_1]*lnpt1mean"
glo lpt "_b[lambda:lambda_1]*lnpt1mean"
glo mot "1+_b[rho:rho_x1]*x1mean+_b[rho:rho_x2]*x2mean+_b[rho:rho_x3]*x3mean+_b[rho:rho_x4]*x4mean"
glo cpzt "(_b[eta:eta_x1_1]*x1mean+_b[eta:eta_x2_1]*x2mean+_b[eta:eta_x3_1]*x3mean+_b[eta:eta_x4_1]*x4mean)*lnpt1mean"
forv i=2(1)17 {
glo asumt "${asumt} + (_b[alpha:alpha_`i'] +_b[eta:eta_x1_`i']*x1mean+_b[eta:eta_x2_`i']*x2mean+_b[eta:eta_x3_`i']*x3mean+_b[eta:eta_x4_`i']*x4mean)*lnpt`i'mean"
glo lpt "${lpt} + _b[lambda:lambda_`i']*lnpt`i'mean"
glo cpzt "${cpzt} + (_b[eta:eta_x1_`i']*x1mean+_b[eta:eta_x2_`i']*x2mean+_b[eta:eta_x3_`i']*x3mean+_b[eta:eta_x4_`i']*x4mean)*lnpt`i'mean"
}

glo gsumt ""
*
forv i=1(1)17 {
forv j=1(1)17 {
if `i'>=`j' {
glo gsumt "${gsumt} + 0.5*_b[gamma:gamma_`i'_`j']*lnpt`i'mean*lnpt`j'mean"
}
*else {
*glo gsumt "${gsumt} + 0.5*_b[gamma:gamma_`j'_`i']*lnpt`i'mean*lnpt`j'mean"
*}
}
}


glo gsumt2 ""
*
forv i=1(1)17 {
forv j=1(1)17 {
if `j'>`i' {
*glo gsumt "${gsumt} + 0.5*_b[gamma:gamma_`i'_`j']*lnpt`i'mean*lnpt`j'mean"
*}
*else {
glo gsumt2 "${gsumt2} + 0.5*_b[gamma:gamma_`j'_`i']*lnpt`i'mean*lnpt`j'mean"
}
}
}

*glo apt "5 + ${asumt} ${gsumt}"
*glo apt "${apt}*${mot}"

glo bpt "_b[beta:beta_1]*lnpt1mean"
forv i=2(1)17 {
glo bpt "${bpt} + _b[beta:beta_`i']*lnpt`i'mean"
}
glo bpt "(exp(${bpt}))*(exp(${cpzt}))"



**welfare before tax**
*glo lnV "1/((${bp}/(lnexpmean-${ap}))+${lp})"

**expenditure after tax**
*glo lnexpt "(${bpt}/((1/${lnV})-${lpt}))+${apt}"


est restore quaids`f'_`QL'
**compensated variation with SE using delta method**
*NOTE: still expression too long, need to break down ap, lp, bp further*
qui nlcom (asum: ${asum}) (gsum: ${gsum})  (gsum2: ${gsum2}) (mo: ${mo}) (bp:${bp}) (lp:${lp}) (asumt: ${asumt}) (gsumt: ${gsumt}) (gsumt2: ${gsumt2})(mot: ${mot}) (bpt: ${bpt}) (lpt:${lpt}) , post noheader
qui nlcom (gsum:  _b[gsum]+_b[gsum2]) (asum:_b[asum]) (mo:_b[mo]) (bp:_b[bp])  (lp:_b[lp]) (gsumt:  _b[gsumt]+_b[gsumt2]) (asumt:_b[asumt]) (mot:_b[mot]) (bpt:_b[bpt]) (lpt:_b[lpt]) , post noheader
qui nlcom (ap: _b[asum] + _b[gsum]) (mo:_b[mo]) (bp:_b[bp])  (lp:_b[lp]) (apt: _b[asumt] + _b[gsumt]) (mot:_b[mot]) (bpt:_b[bpt]) (lpt:_b[lpt]) , post noheader
qui nlcom (ap: 5+ _b[ap]) (mo:_b[mo]) (bp:_b[bp])  (lp:_b[lp]) (apt: 5+ _b[apt]) (mot:_b[mot]) (bpt:_b[bpt]) (lpt:_b[lpt]) , post noheader
qui nlcom (ap: (_b[ap]*_b[mo])) (bp:_b[bp]) (lp:_b[lp]) (apt: (_b[apt]*_b[mot])) (bpt:_b[bpt]) (lpt:_b[lpt]) , post noheader
qui nlcom (aux0: lnexpmean-_b[ap]) (bp:_b[bp]) (lp:_b[lp]) (bpt:_b[bpt]) (lpt:_b[lpt]) (apt:_b[apt]), post noheader
qui nlcom (aux1: _b[bp]/_b[aux0]) (lp:_b[lp]) (bpt:_b[bpt]) (lpt:_b[lpt]) (apt:_b[apt]), post noheader
qui nlcom (lnV: 1/(_b[aux1]+_b[lp])) (bpt:_b[bpt]) (lpt:_b[lpt]) (apt:_b[apt]), post noheader /*V before tax*/
qui nlcom lnexpt: (_b[bpt]/((1/_b[lnV])-_b[lpt])+_b[apt]), post noheader /*expenditure after tax*/
nlcom
mat lnexpt=e(b)
mat lnexpt_V=e(V)
mat outputD_`ts'_`QL'=lnexpt\lnexpt_V
qui nlcom CV: (_b[lnexpt]/lnexpmean-1)*100 , post noheader /*CV as % of expenditure with SE*/
nlcom
*qui nlcom lnexpt: _b[CV]*lnexpmean , post noheader 
*test _b[CV]=1
*estimates store CV01
mat CV=e(b)
mat V=e(V)
mat outputC_`ts'_`QL'=CV\V
qui nlcom lexpmean:(lnexpmean), post noheader
nlcom
drop lnpt*

}

}


***CV Excel Output***



*** Define locals ***
local f 0 /* f=0 if estimation for whole sample, f 1 is estimation by groups*/
local QL 0 /* Number of groups*/
local x 17 /* Number of categories*/
local v1 median /* mean = tax rates based on mean nutrients or median =tax  rates based on median nutrients*/
local v2 p50 /* mean = lp and lnexp x4*/
local vr 9
local nutr 4 /* number of nutrients in the output*/

** check output
forv i=`f'(1)`QL'{
local QL  `i'
forv j=1(1)5{
local ts `j'
mat list outputC_`ts'_`QL'
}
}

***output CV
forv i=`f'(1)`QL'{
local QL `i'
putexcel set "$results\output_TS_`v1'_v`vr'.xlsx", sheet(QL`QL') modify

putexcel L1="CV_`v2'"

local ts 1
putexcel L2=matrix(outputC_`ts'_`QL')
local ts 2
putexcel L4=matrix(outputC_`ts'_`QL')
local ts 3
putexcel L6=matrix(outputC_`ts'_`QL')
local ts 4
putexcel L8=matrix(outputC_`ts'_`QL')
local ts 5
putexcel L10=matrix(outputC_`ts'_`QL')
}
***output lnexpt
forv i=`f'(1)`QL'{
local QL `i'
putexcel set "$results\output_TS_`v1'_v`vr'.xlsx", sheet(QL`QL') modify
putexcel M1="lnexpt_`v2'"
local ts 1
putexcel M2=matrix(outputD_`ts'_`QL')
local ts 2
putexcel M4=matrix(outputD_`ts'_`QL')
local ts 3
putexcel M6=matrix(outputD_`ts'_`QL')
local ts 4
putexcel M8=matrix(outputD_`ts'_`QL')
local ts 5
putexcel M10=matrix(outputD_`ts'_`QL')
}


***lnexp output**
local v2 mean
forv i=`f'(1)`QL'{
local QL `i'

forv j=1(1)5{
local ts `j'
mat ts=ts`ts' /*tax rates as % (chosen from scenarios above)*/

use "$est\temp_`QL'", clear
forv i=1(1)17{
local tax=ts[1,`i']
*gen lnpt`i'=lnp`i'+log(1+`tax')
gen lnpt`i'=log(exp(lnp`i')*(1+`tax'))
*sum lnpt`i'
*drop lnpt`i'
}

foreach x of varlist lnp* lnpt* lnexp x4 {
qui sum `x', det
scalar `x'`v2'=r(`v2')
*scalar `x'mean=r(`x')
}
qui nlcom lnexp`v2':(lnexpmean), post noheader
nlcom
mat outputE_`ts'_`QL'=lnexp`v2'

drop lnpt* 
}
}
forv i=`f'(1)`QL'{
local QL `i'

putexcel set "$results\output_TS_`v1'_v`vr'.xlsx", sheet(QL`QL') modify
putexcel S1="lnexp`v2'"
local ts 1
putexcel S2=matrix(outputE_`ts'_`QL')
local ts 2
putexcel S4=matrix(outputE_`ts'_`QL')
local ts 3
putexcel S6=matrix(outputE_`ts'_`QL')
local ts 4
putexcel S8=matrix(outputE_`ts'_`QL')
local ts 5
putexcel S10=matrix(outputE_`ts'_`QL')
}
local v2 p50
forv i=`f'(1)`QL'{
local QL `i'

forv j=1(1)5{
local ts `j'
mat ts=ts`ts' /*tax rates as % (chosen from scenarios above)*/

use "$est\temp_`QL'", clear
forv i=1(1)17{
local tax=ts[1,`i']
*gen lnpt`i'=lnp`i'+log(1+`tax')
gen lnpt`i'=log(exp(lnp`i')*(1+`tax'))
*sum lnpt`i'
*drop lnpt`i'
}

foreach x of varlist lnp* lnpt* lnexp x4 {
qui sum `x', det
scalar `x'`v2'=r(`v2')
*scalar `x'mean=r(`x')
}
qui nlcom lnexp`v2':(lnexp`v2'), post noheader
nlcom
mat outputF_`ts'_`QL'=lnexp`v2'

drop lnpt* 
}
}
forv i=`f'(1)`QL'{
local QL `i'
putexcel set "$results\output_TS_`v1'_v`vr'.xlsx", sheet(QL`QL') modify
putexcel T1="lnexp`v2'"
local ts 1
putexcel T2=matrix(outputF_`ts'_`QL')
local ts 2
putexcel T4=matrix(outputF_`ts'_`QL')
local ts 3
putexcel T6=matrix(outputF_`ts'_`QL')
local ts 4
putexcel T8=matrix(outputF_`ts'_`QL')
local ts 5
putexcel T10=matrix(outputF_`ts'_`QL')
}



