*! version 1.0.0  29dec2011
* Not to be called alone; for use with -quaids-

program nlsur__quaids

	version 12
	
	syntax varlist if, at(name) lnexp(varname) lnp(varlist)		///
		a0(real) [ noQUADratic DEMOGRAPHICS(varlist) ]
	
	tempvar touse
	qui gen byte `touse' = 0
	qui replace `touse' = 1 `if'

	local nm1 : word count `varlist'
	local neqn = `nm1' + 1
	local ndemo : word count `demographics'

	mata:_quaids__expshrs("`varlist'", "`touse'", "`lnexp'",	///
		"`lnp'", `neqn', `ndemo', `a0', "`quadratic'", "`at'",	///
		"`demographics'")
	
end
exit
