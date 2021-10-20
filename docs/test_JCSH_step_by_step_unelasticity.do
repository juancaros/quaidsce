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

//Assuming quadratic specification with demographics

quaids w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog 
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

mat define parametros= e(b)
mat list parametros
mat alpha = e(alpha)
mat beta = e(beta)
mat gamma = e(gamma)
	
mat lambda = e(lambda)
mat eta = e(eta)
mat rho = e(rho)



//Create mean values 
foreach var in lnp1 lnp2 lnp3 lnp4 lnp5 expfd nkids income {
	egen `var'm= mean(`var')
}

mat list beta

//bofp component
	gen bofp= beta[1,1]*lnp1m		
	forvalues i = 2/5 {		
		replace bofp= bofp + beta[1,`i']*lnp`i'm
									}
		replace bofp= exp(bofp)

sum bofp //It's OK

//Component lnpindex
		gen lnpindex= `e(anot)' 
		forvalue i=1/5 {	
			quiet replace lnpindex= lnpindex + alpha[1,`i']*lnp`i'm
			local j=`i' 
			forvalue ii=`j'/5 {
				quiet replace lnpindex=  lnpindex + 0.5*(gamma[`ii',`i']*(lnp`i'm*lnp`ii'm))
				}
				}
			
			
//Componen 	cofp mbar		
		gen cofp= 1 //It is OK to set 1 because below we set a multiplication
			gen double mbar= 1 //It is OK because I need to add a "1"
			
			foreach var of varlist `e(demographics)' {	
			local n_demo= 1
			forvalue i=1/5 {
				
				replace cofp= cofp*(`d_`var''*eta[`n_demo',`i']*lnp`i'm) 
				//JCSH verificar que sea una multiplicacion de todo
				
				*tempvar betanz`i'
					gen betanz`i'=.
				replace betanz`i'=beta[1,`i']+(`d_`var''*eta[`n_demo',`i'])												
								}
								
		replace mbar= mbar + (rho[1,`n_demo']*`d_`var'') 					
			local n_demo= `n_demo' + 1							
		}										
		replace cofp = exp(cofp)
	
				