*! version 1.0.0  Sep 2021

program quaidsce_p

	version 12
	
	if "`e(cmd)'" != "quaidsce" {
		exit 301
	}
	
	syntax [anything(name = vlist id = "newvarlist")] [if] [in]
	
	marksample touse

	// MAKING MACROS OF e() AS LOCALS
	
	_stubstar2names `vlist', nvars(`=e(ngoods)')
	local vars `s(varlist)'
	if `s(stub)' {	
		local vars ""
		local vlist : subinstr local vlist "*" ""
		forvalues i = 1/`=e(ngoods)' {
			local vars `vars' `vlist'_`i'
		}
	}
	
	forvalues i = 1/`=e(ngoods)' {
		local v : word `i' of `vars'
		tempvar vlist_`i'
		qui gen `v' =.
		lab var `v' "Predicted expenditure share: good `i'"
	}
	
	//JCS
	//there are misisng inputs here (pdf, cdf, du, tau, setau)
	
	if "`e(lnprices)'" != "" {
		local i 1
		foreach var of varlist `e(lnprices)' {
			local lnp`i' `var'
			local `++i'
		}
	}
	else {
		local i 1
		foreach var of varlist `e(prices)' {
			tempvar lnp`i'
			qui gen double `lnp`i'' = ln(`var')
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
		foreach var of varlist `e(demographics)' {
			tempvar d_`var'
			qui gen double `d_`var'' = `var'
		}
	}

/// WRITE HERE THE IF/ELSE WITH THE CORRESPONDING FORMULA FOR THE SHARES USING LOCALS SO WE CAN PREDICT USING MARGINS

	tempname alpha beta gamma lambda delta eta rho tau
	mat alpha = e(alpha)
	mat beta = e(beta)
	mat gamma = e(gamma)
	
	mat lambda = e(lambda)
	mat delta = e(delta)
	mat eta = e(eta)
	mat rho = e(rho)
		
/// REPLACE VARIABLES FROM PREDICTIONS BASED ON THE STUBS `v' and the right formula

	forvalues j = 1/`=e(ngoods)' {
		local v : word `j' of `vars'
		qui replace `v' = alpha[1,`j']*`lnexp'		//this works but idk why it doest with a local expression	
		}
	
end

exit
