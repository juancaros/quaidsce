cap program drop nlsurquaidsNN9c
program nlsurquaidsNN9c
	version 14.0
	syntax varlist if, at(name)
	tokenize `varlist'

*** needs to be updated manually
	
*****************
*variables must enter the program in the following order and with the same names as quaids_.ado:
*args w1...wJ lnp1...lnpJ lnm x1 x2 x3 x4 pdf1...pdfJ cdf1...cdfJ
*****************

***Coefficients

qui describe `varlist'
local J= (r(k)-6)/4
local J1 =`J'-1
local aux=0

forvalues j=1(1)`J1' {
tempname a`j'
scalar `a`j'' = `at'[1,`j'] 
replace `aux' = `aux' + `a`j''
}
tempname a`J'
scalar `a`J'' = 1-`aux'

replace `aux'=0
forvalues j=1(1)`J1' {
tempname b`j'
scalar `b`j'' = `at'[1,`J1'+`j'] 
replace `aux' = `aux' + `b`j''
}
tempname b`J'
scalar `b`J'' = -`aux'
local aux0=2*`J1'
forvalues j=1(1)`J1' {
	local aux`j'=0
		forvalues k=1(1)`J1' {
	tempname g`j'`k'
	if `k'>=`j' {
	scalar `g`j'`k'' = `at'[1,`aux0'+(`k'-`j'+1)]
	}
	else {
	scalar `g`j'`k'' = `g`k'`j'' 
	} 
	replace `aux`j'' = `aux`j'' + `g`j'`k''
	}
	replace `aux0'=`aux0'+`J'-`j'
}

forvalues j=1(1)`J' {
tempname `g`j'`J''
scalar `g`j'`J'' = -`aux`j''
}

replace `aux'=0
forvalues j=1(1)`J' {
tempname l`j'
scalar `l`j'' = `at'[1,`aux0'+`j'] 
replace `aux' = `aux' + `l`j''
}
tempname l`J'
scalar `l`J'' = -`aux'


//household demographics

replace `aux'=0
replace `aux0'=`aux0'+`J'
forvalues j=1(1)`J1' {
tempname r`j'1
scalar `r`j'1' = `at'[1,`aux0'+`j'] 
replace `aux' = `aux' + `r`j'1'
}
tempname r`J'1
scalar `r`J'1' = -`aux'

replace `aux'=0
replace `aux0'=`aux0'+`J1'
forvalues j=1(1)`J1' {
tempname r`j'2
scalar `r`j'2' = `at'[1,`aux0'+`j'] 
replace `aux' = `aux' + `r`j'2'
}
tempname r`J'2
scalar `r`J'2' = -`aux'

replace `aux'=0
replace `aux0'=`aux0'+`J1'
forvalues j=1(1)`J1' {
tempname r`j'3
scalar `r`j'3' = `at'[1,`aux0'+`j'] 
replace `aux' = `aux' + `r`j'3'
}
tempname r`J'3
scalar `r`J'3' = -`aux'

replace `aux'=0
replace `aux0'=`aux0'+`J1'
forvalues j=1(1)`J1' {
tempname r`j'4
scalar `r`j'4' = `at'[1,`aux0'+`j'] 
replace `aux' = `aux' + `r`j'4'
}
tempname r`J'4
scalar `r`J'4' = -`aux'

replace `aux'=0
replace `aux0'=`aux0'+`J'
forvalues j=1(1)`J1' {
tempname d`j'
scalar `d`j'' = `at'[1,`aux0'+`j'] 
replace `aux' = `aux' + `d`j''
}
tempname d`J'
scalar `d`J'' = -`aux'


***indexes 

quietly {
forvalues i=1(1)`J' {
tempvar aa`i'
gen double `aa`i'' = `a`i''+`r`i'1'*`x1' +`r`i'2'*`x2' +`r`i'3'*`x3' +`r`i'4'*`x4'
}

tempvar lnpindex
gen double `lnpindex' = 5
forvalues i = 1(1)`J' {
replace `lnpindex' = `lnpindex' + `aa`i''*`lnp`i'' 
}
forvalues i = 1(1)`J' {
forvalues j = 1(1)`J' {
replace `lnpindex' = `lnpindex' + 0.5*`g`i'`j''*`lnp`i''*`lnp`j''
}
}

// The b(p) term in the QUAIDS model:
tempvar bofp
gen double `bofp' = 0
forvalues i = 1(1)`J' {
replace `bofp' = `bofp' + `lnp`i''*`b`i''
}
replace `bofp' = exp(`bofp')

// Finally, the expenditure shares

forvalues i = 1(1)`J' {
replace `w`i'' = `aa`i'' + `b`i''*(`lnm' - `lnpindex') + `l`i''/`bofp'*(`lnm' - `lnpindex')^2
forvalues j = 1(1)`J' {
replace `w`i'' = `w`i''+ `g`i'`j''*`lnp`j''
}
replace `w`i''=`w`i''*`cdf`i'' + `d`i''*`pdf`i''
}


}

end
