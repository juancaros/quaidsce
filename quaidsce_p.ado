*! version 1.0.0  Sep 2021

program quaidsce_p

	version 12
	
	if "`e(cmd)'" != "quaidsce" {
		exit 301
	}
	
	syntax [anything(name = vlist id = "newvarlist")] [if] [in]
	
	marksample touse

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
		lab var `v' "Predicted expenditure share: good `i'"
	}

	/// CHECK THE ELEMENTS NOT NEEDED BELOW (SINCE ALREADY AVAILABLE IN e())
	
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
	

/// WRITE HERE THE IF/ELSE WITH THE CORRESPONDING FORMULA FOR THE SHARES USING LOCALS SO WE CAN PREDICT USING MARGINS
	
/// GEN VARIABLES FROM PREDICTIONS BASED ON THE STUBS `v'

	forvalues i = 1/`=e(ngoods)' {
		local v : word `i' of `vars'
		predict `v' , `local_w`i''		/// local is the corresponding formula for the predicted share in each case
	}
	
end

exit
