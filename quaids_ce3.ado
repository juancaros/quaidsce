*************CALCULATING ELASTICITIES WITH IC/BOOTSTRAP***********
*QUAIDS MODEL FOR EPF VII CHILE 2016-2017
*Carlos Caro, 2019

cap program drop quaids_ce3
program define quaids_ce3, eclass
	version 14.0
	syntax varlist 
	local nargs `varlist'
	args `varlist'

local J : word count `nargs'
local J = (`J'-8)/3
local J1 = `J'-1
 
tempvar elnexp
qui reg `lnexp' `x1' `x2' `x3' `x4' `x6' `x7' `x5' 
predict `elnexp', r

matrix tau=I(9) 
forval i = 1(1)`J' {
	tempvar du`i' z`i' cdf`i' pdf`i'
	gen `z`i''=.
	replace `z`i''=1 if `w`i''>0 
	replace `z`i''=0 if `w`i''==0 
	quietly probit `z`i'' `lnp1'-`lnp`J'' `x1' `x2' `x3' `x4' `x5' `x6' 
	matrix tmp=e(b)
	matrix tau[`i',1]=tmp[1,1]
	matrix tau[`i',2]=tmp[1,2]
	matrix tau[`i',3]=tmp[1,3]
	matrix tau[`i',4]=tmp[1,4]
	matrix tau[`i',5]=tmp[1,5]
	matrix tau[`i',6]=tmp[1,6]
	matrix tau[`i',7]=tmp[1,7]
	matrix tau[`i',8]=tmp[1,8]
	matrix tau[`i',9]=tmp[1,9]
	quietly predict `du`i''
	gen `pdf`i''= normalden(`du`i'')
	gen `cdf`i''= normal(`du`i'')
}

local nargs2 `w1'
forval i = 2(1)`J' {
local nargs2 `nargs2' `w`i'' 
}
local nargs2 `nargs2' `lnexp' `x1' `x2' `x3' `elnexp'
forval i = 1(1)`J' {
local nargs2 `nargs2' `lnp`i'' 
}
forval i = 1(1)`J' {
local nargs2 `nargs2' `pdf`i'' 
}
forval i = 1(1)`J' {
local nargs2 `nargs2' `cdf`i''
}
forval i = 1(1)`J' {
local nargs2 `nargs2' `z`i'' 
}

forvalues j=1(1)`J' {
tempname a`j'
tempname b`j'
tempname l`j'
tempname d`j'
forvalues k=1(1)`J' {
tempname g`j'`k'
}
tempname r`j'1
tempname r`j'2
tempname r`j'3
tempname r`j'4
}

forvalues j=1(1)`J' {
local param `param' a`j' 
}
forvalues j=1(1)`J' {
local param `param' b`j'
}

forvalues j=1(1)`J1' {
forvalues k=1(1)`J1' {
	if `k'>=`j' {
	local param `param' g`j'`k'
	else
	}
}
}
forvalues j=1(1)`J' {
local param `param' l`j' 
}
forvalues j=1(1)`J1' {
local param `param' r`j'1 
}
forvalues j=1(1)`J1' {
local param `param' r`j'2 
}
forvalues j=1(1)`J1' {
local param `param' r`j'3 
}
forvalues j=1(1)`J1' {
local param `param' r`j'4 
}
forvalues j=1(1)`J' {
local param `param' d`j' 
}


nlsur quaidsNN9c @ `nargs2' , fgnls neq(`J') parameters(`param')

tempname b nu e n1 n2 n3 bb vv aux
matrix b=e(b)

forvalues j=1(1)`J' {
scalar `a`j'' = b[1,`j'] 
}
forvalues j=1(1)`J' {
scalar `b`j'' = b[1,`J'+`j'] 
}

local aux0=2*`J'
forvalues j=1(1)`J1' {
	local aux`j'=0
	forvalues k=1(1)`J1' {
	tempname g`j'`k'
	if `k'>=`j' {
	scalar `g`j'`k'' = b[1,`aux0'+(`k'-`j'+1)]
	}
	else {
	scalar `g`j'`k'' = `g`k'`j'' 
	} 
	local aux`j' = `aux`j'' + `g`j'`k''
	}
	local aux0=`aux0'+`J'-`j'
}

local auxg = 0
forvalues j=1(1)`J1' {
tempname g`J'`j' g`j'`J'
scalar `g`J'`j'' = -`aux`j''
scalar `g`j'`J'' = -`aux`j''
local auxg = `auxg' -`aux`j''
}
tempname g`J'`J'
scalar `g`J'`J'' = `auxg'

*local `aux'=0
forvalues j=1(1)`J' {
tempname l`j'
scalar `l`j'' = b[1,`aux0'+`j'] 
*local aux = `aux' + `l`j''
}


//household demographics

local aux=0
local aux0=`aux0'+`J'
forvalues j=1(1)`J1' {
tempname r`j'1
scalar `r`j'1' = b[1,`aux0'+`j'] 
local aux = `aux' + `r`j'1'
}
tempname r`J'1
scalar `r`J'1' = -`aux'

local aux=0
local aux0=`aux0'+`J1'
forvalues j=1(1)`J1' {
tempname r`j'2
scalar `r`j'2' = b[1,`aux0'+`j'] 
local aux = `aux' + `r`j'2'
}
tempname r`J'2
scalar `r`J'2' = -`aux'

local aux=0
local aux0=`aux0'+`J1'
forvalues j=1(1)`J1' {
tempname r`j'3
scalar `r`j'3' = b[1,`aux0'+`j'] 
local aux = `aux' + `r`j'3'
}
tempname r`J'3
scalar `r`J'3' = -`aux'

local aux=0
local aux0=`aux0'+`J1'
forvalues j=1(1)`J1' {
tempname r`j'4
scalar `r`j'4' = b[1,`aux0'+`j'] 
local aux = `aux' + `r`j'4'
}
tempname r`J'4
scalar `r`J'4' = -`aux'

local aux=0
local aux0=`aux0'+`J1'
forvalues j=1(1)`J' {
tempname d`j'
scalar `d`j'' = b[1,`aux0'+`j'] 
}

***

qui {
forv i=1(1)`J' {
tempvar wu`i'
gen `wu`i''=`w`i''*`cdf`i''+`d`i''*`pdf`i''
sum `wu`i''
scalar wu`i'mean=r(mean)
sum `w`i''
scalar w`i'mean=r(mean)
}

forv i=1(1)`J' {
sum `lnp`i''
scalar lnp`i'mean=r(mean)
}

forv i=1(1)`J' {
sum `cdf`i''
scalar cdf`i'mean=r(mean)
sum `du`i''
scalar du`i'mean=r(mean)
sum `pdf`i''
scalar pdf`i'mean=r(mean)
}

sum `elnexp'
scalar elnexpmean=r(mean)
sum `lnexp'
scalar lnexpmean=r(mean)

sum `x1'
scalar x1mean=r(mean)
sum `x2'
scalar x2mean=r(mean)
sum `x3'
scalar x3mean=r(mean)
}

* Price indexes
forv i=1(1)`J' {
scalar dem`i'= `r`i'1'*x1mean+`r`i'2'*x2mean+`r`i'3'*x3mean+`r`i'4'*elnexpmean
}

scalar asum=0
scalar lp=0
forv i=1(1)`J' {
scalar asum`i' = asum + (`a`i''+dem`i')*lnp1mean
scalar lp`i' = lp + `l`i''*lnp1mean
}

scalar gsum=0
forv i=1(1)`J' {
forv j=1(1)`J' {
scalar gsum = gsum + 0.5*`g`i'`j''*lnp`i'mean*lnp`j'mean
}
}

scalar ap = 5 + asum + gsum
scalar bp = 0
forv i=1(1)`J' {
scalar bp = bp + `b`i''*lnp`i'mean
}
scalar bp = exp(bp)

*Reduced form (Mu)
forv i=1(1)`J' {
scalar mu`i' = `b`i''+(2*`l`i''/bp)*(lnexpmean-ap)
}
forv j=1(1)`J' {
scalar gsum2`j'=0
forv k=1(1)`J' {
scalar gsum2`j' = gsum2`j' + `g`j'`k''*lnp`k'mean
}
}


************ELASTICITIES*******************

matrix e=I(`J')
forv i=1(1)`J' {
forv j=1(1)`J' {
local delta=cond(`i'==`j',1,0)
scalar mu`i'`j'=`g`i'`j'' - (mu`i'*(`a`j'' + dem`j' + gsum2`j'))-`l`i''*`b`j''/bp*(lnexpmean - ap)^2
matrix e[`i',`j']=mu`i'`j'*cdf`i'mean/wu`i'mean-`delta'+(pdf`i'mean*tau[`i',`j']*(w`i'mean-`d`i''*du`i'mean))/wu`i'mean
}
}

*matrix e=I(`J')
*forv i=1(1)`J' {
*forv j=1(1)`J' {
*local delta=cond(`i'==`j',1,0)
*scalar mu`i'`j'=`g`i'`j'' - (mu`i'*(`a`j'' + dem`j' + gsum2`j'))-`l`i''*`b`j''/bp*(lnexpmean - ap)^2
*matrix e[`i',`j']=mu`i'`j'*cdf`i'mean/w`i'mean-`delta'
*}
*}

************NUTRIENT AVAILABILITY PER SIMULATION (TBD)***********

/*qui {
forv i=1(1)`J' {
sum QME`i' ,d
scalar QME`i'm=r(p50)/30/x1mean
}
}

matrix n1=J(10,7,1)
matrix n2=J(10,7,1)
matrix n3=J(10,7,1)
matrix aux=J(1,9,1)

matrix nu=(2949,527,399,1063,79,39,35\5182,567,17,5852,294,38,61\2951,9,5,3526,253,84,158\ ///
687,110,46,487,18,3,35\2449,470,13,1899,26,3,87\374,93,90,130,0,0,3\143,34,33,110,0,0,6\ ///
7,2,0,22,0,0,0\469,52,48,592,16,10,31)

scalar t11=0.18
scalar t21=0.18
scalar t31=0.045
scalar t41=0.045
forv i=1(1)9 {
	forv j=1(1)7 {
		matrix n1[`i',`j']= QME`i'm*(nu[`i',`j']*(t11*e[`i',1]+t21*e[`i',2]+t31*e[`i',6]+t41*e[`i',7]))
	}
}
forv j=1(1)7 {
	matrix n1[10,`j']=aux*n1[1..9,`j']
}
	
scalar t12=0
scalar t22=0
scalar t32=0.24
scalar t42=0.24
forv i=1(1)9 {
	forv j=1(1)7 {
		matrix n2[`i',`j']= QME`i'm*(nu[`i',`j']*(t12*e[`i',1]+t22*e[`i',2]+t32*e[`i',6]+t42*e[`i',7]))
	}
}
forv j=1(1)7 {
	matrix n2[10,`j']=aux*n2[1..9,`j']
}

scalar t13=0.11
scalar t23=0
scalar t33=0.12
scalar t43=0.20
forv i=1(1)9 {
	forv j=1(1)7 {
		matrix n3[`i',`j']= QME`i'm*(nu[`i',`j']*(t13*e[`i',1]+t23*e[`i',2]+t33*e[`i',6]+t43*e[`i',7]))
	}
}

forv j=1(1)7 {
	matrix n3[10,`j']=aux*n3[1..9,`j']
}
*/

local bsize = `J'*`J'

matrix `bb'=J(1,`bsize',1)
forv i=1(1)`J' {
	forv j=1(1)`J' {
		matrix `bb'[1,`J'*(`i'-1)+`j']=e[`i',`j']
	}
}

/*
forv i=1(1)10 {
	forv j=1(1)7 {
		matrix `bb'[1,81+7*(`i'-1)+`j']=n1[`i',`j']
	}
}
forv i=1(1)10 {
	forv j=1(1)7 {
		matrix `bb'[1,151+7*(`i'-1)+`j']=n2[`i',`j']
	}
}
forv i=1(1)10 {
	forv j=1(1)7 {
		matrix `bb'[1,221+7*(`i'-1)+`j']=n3[`i',`j']
	}
}
*/

matrix `vv'=0*I(`bsize')
local cn: colnames `vv'
matrix rownames `vv' = `cn'
ereturn post `bb' `vv'

end
