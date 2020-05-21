*************CALCULATING ELASTICITIES WITH IC/BOOTSTRAP***********
*QUAIDS MODEL FOR EPF VII CHILE 2016-2017
*Carlos Caro, 2019

cap program drop quaidsc9
program define quaidsc9, eclass
	version 14.0
	syntax varlist 
	local nargs `varlist'
	args `varlist'

local J1 : word count `nargs'
local J1 = (`J1'-11)/3
local J = `J1'+1

tempvar elnexp
qui reg `lnexp' `x1' `x2' `x3' `x4' `x6' `x7' `x5' 
predict `elnexp', r

matrix tau=I(`J') 
forval i = 1(1)`J' {
	tempvar du`i' z`i' cdf`i' pdf`i'
	if `i'<`J' {
	gen `z`i''=.
	replace `z`i''=1 if `w`i''>0 
	replace `z`i''=0 if `w`i''==0 
	quietly probit `z`i'' `lnp1'-`lnp`J'' `x1' `x2' `x3' `x6' `x4' `x7'
	matrix tmp=e(b)
	forval j = 1(1)`J' {
	matrix tau[`i',`j']=tmp[1,`j']
	}
	quietly predict `du`i''
	gen `pdf`i''= normalden(`du`i'')
	gen `cdf`i''= normal(`du`i'')
	}
	else {
	gen `z`i''=1
	gen `du`i''=1
	gen `pdf`i''=0
	gen `cdf`i''=1
	}
}

local nargs2 `w1'
forval i = 2(1)`J1' {
local nargs2 `nargs2' `w`i'' 
}
local nargs2 `nargs2' `lnexp' `x1' `x2' `x3' `elnexp'

forval i = 1(1)`J' {
local nargs2 `nargs2' `lnp`i'' 
}
forval i = 1(1)`J1' {
local nargs2 `nargs2' `pdf`i'' 
}
forval i = 1(1)`J1' {
local nargs2 `nargs2' `cdf`i''
}
forval i = 1(1)`J1' {
local nargs2 `nargs2' `z`i'' 
}

forvalues j=1(1)`J' {
tempname a`j'
tempname b`j'
tempname l`j'
tempname d`j'
forvalues k=1(1)`J' {
tempname g`j'g`k'
}
tempname r`j'1
tempname r`j'2
tempname r`j'3
tempname r`j'4
}

forvalues j=1(1)`J1' {
local param `param' a`j' 
}
forvalues j=1(1)`J1' {
local param `param' b`j'
}

forvalues j=1(1)`J1' {
forvalues k=1(1)`J1' {
	if `k'>=`j' {
	local param `param' g`j'g`k'
	else
	}
}
}
forvalues j=1(1)`J1' {
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
forvalues j=1(1)`J1' {
local param `param' d`j' 
}

*initial values*
mat ini_a=(-.01,.38,0,.28,.7,.7,0,.7,.26,0,0,0,0,.13,0,0)
mat ini_b=(0,0,.01,.01,.01,.01,0,0,.01,0,0,0,0,.01,0,-.1)
mat ini_g1=(.02,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
mat ini_g2=(.02,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
mat ini_g3=(.02,0,0,0,0,0,0,0,0,0,0,0,0,0)
mat ini_g4=(.02,0,0,0,0,0,0,0,0,0,0,0,0)
mat ini_g5=(.02,0,0,0,0,0,0,0,0,0,0,0)
mat ini_g6=(.02,0,0,0,0,0,0,0,0,0,0)
mat ini_g7=(.02,0,0,0,0,0,0,0,0,0)
mat ini_g8=(.02,0,0,0,0,0,0,0,0)
mat ini_g9=(.02,0,0,0,0,0,0,0)
mat ini_g10=(.02,0,0,0,0,0,0)
mat ini_g11=(.02,0,0,0,0,0)
mat ini_g12=(.02,0,0,0,0)
mat ini_g13=(.02,0,0,0)
mat ini_g14=(.02,0,0)
mat ini_g15=(.02,0)
mat ini_g16=(.02)
mat ini_l=(.02,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
mat ini_r1=(.02,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
mat ini_r2=(.02,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
mat ini_r3=(.02,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
mat ini_r4=(.02,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
mat ini_d=(-.24,-.62,0,-.38,.1,.1,.1,.1,.1,.1,.1,1,0,0,0,0)

mat ini_g=ini_g1,ini_g2,ini_g3,ini_g4,ini_g5,ini_g6,ini_g7,ini_g8,ini_g9,ini_g10,ini_g11,ini_g12,ini_g13,ini_g14,ini_g15,ini_g16
mat ini=ini_a,ini_b,ini_g,ini_l,ini_r1,ini_r2,ini_r3,ini_r4,ini_d

nlsur quaidsc9 @ `nargs2' , nls neq(`J1') parameters(`param') 

tempname b nu e n1 n2 n3 bb vv aux
matrix b=e(b)

local aux=0
forvalues j=1(1)`J1' {
scalar `a`j'' = b[1,`j'] 
local aux = `aux' + `a`j''
}
scalar `a`J'' = 1-`aux'

forvalues j=1(1)`J1' {
scalar `b`j'' = b[1,`J1'+`j'] 
local aux = `aux' + `b`j''
}
scalar `b`J'' = -`aux'


local aux0=2*`J1'
forvalues j=1(1)`J1' {
	local aux`j'=0
	forvalues k=1(1)`J1' {
	tempname g`j'g`k'
	if `k'>=`j' {
	scalar `g`j'g`k'' = b[1,`aux0'+(`k'-`j'+1)]
	}
	else {
	scalar `g`j'g`k'' = `g`k'g`j'' 
	} 
	local aux`j' = `aux`j'' + `g`j'g`k''
	}
	local aux0=`aux0'+`J'-`j'
}

local auxg = 0
forvalues j=1(1)`J1' {
tempname g`J'g`j' g`j'g`J'
scalar `g`J'g`j'' = -`aux`j''
scalar `g`j'g`J'' = -`aux`j''
local auxg = `auxg' -`aux`j''
}
tempname g`J'g`J'
scalar `g`J'g`J'' = `auxg'

local aux=0
forvalues j=1(1)`J1' {
tempname l`j'
scalar `l`j'' = b[1,`aux0'+`j'] 
local aux = `aux' + `l`j''
}
tempname l`J'
scalar `l`J'' = -`aux'

//household demographics

local aux=0
local aux0=`aux0'+`J1'
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
local aux = `aux' + `d`j''
}
tempname d`J'
scalar `d`J'' = -`aux'

***

qui {
local aux=0
forv i=1(1)`J' {
sum `w`i''
scalar w`i'mean=r(mean)
}

forv i=1(1)`J' {
tempvar wu`i'
gen `wu`i''=`w`i''*`cdf`i''+`d`i''*`pdf`i''
sum `wu`i''
scalar wu`i'mean=r(mean)
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
scalar gsum = gsum + 0.5*`g`i'g`j''*lnp`i'mean*lnp`j'mean
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
scalar gsum2`j' = gsum2`j' + `g`j'g`k''*lnp`k'mean
}
}


************ELASTICITIES*******************

matrix e=I(`J')
forv i=1(1)`J' {
forv j=1(1)`J' {
local delta=cond(`i'==`j',1,0)
scalar mu`i'`j'=`g`i'g`j'' - (mu`i'*(`a`j'' + dem`j' + gsum2`j'))-`l`i''*`b`j''/bp*(lnexpmean - ap)^2
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

*matrix `vv'=0*I(`bsize')
*local cn: colnames `vv'
*matrix rownames `vv' = `cn'
ereturn post `bb' 

end
