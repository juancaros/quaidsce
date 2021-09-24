*! version 1.0.0  29dec2011

program quaidsce_p

	version 12
	
	if "`e(cmd)'" != "quaidsce" {
		exit 301
	}
	
	syntax [anything(name = vlist id = "newvarlist")] [if] [in]
	
	marksample touse

	_stubstar2names `vlist', nvars(`=e(ngoods)')
	local vars `s(varlist)'
	local typs `s(typelist)'
			// make our own names vlist_i instead of vlisti
	if `s(stub)' {	
		local vars ""
		local vlist : subinstr local vlist "*" ""
		forvalues i = 1/`=e(ngoods)' {
			local vars `vars' `vlist'_`i'
		}
	}
	forvalues i = 1/`=e(ngoods)' {
		local v : word `i' of `vars'
		local t : word `i' of `types'
		qui gen `t' `v' = .
		lab var `v' "Predicted expenditure share: good `i'"
	}
	
	if "`e(lnprices)'" != "" {
		local lnp `e(lnprices)'
	}
	else {
		local i 1
		foreach var of varlist `e(prices)' {
			tempvar vv`i'
			qui gen double `vv`i'' = ln(`var')
			local lnp `lnp' `vv`i''
			local `++i'
		}
	}
	if "`e(lnexpenditure)'" != "" {
		local lnexp `e(lnexpenditure)'
	}
	else {
		tempvar exp
		qui gen double `exp' = ln(`e(expenditure)')
		local lnexp `exp'
	}

	local ndemo = `e(ndemos)'
	if `ndemo' > 0 {
		local demos `e(demographics)'
	}

	tempname betas
	mat `betas' = e(b)
	
	mata:_quaidsce__predshrs("`vars'", "`touse'", 			///
			       "`lnexp'","`lnp'",			///
			       `=e(ngoods)', `=e(ndemos)',		///
			       `=e(anot)', "`e(quadratic)'",		///
			       "`e(demographics)'")

end

exit
