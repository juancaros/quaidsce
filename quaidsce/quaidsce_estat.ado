*! version 1.1.0  18jul2013

program quaids_estat

	version 12
	
	if "`e(cmd)'" != "quaids" {
		exit 301
	}
	
	gettoken key 0 : 0, parse(", ")
	local lkey = length(`"`key'"')
	
	if `"`key'"' == substr("expenditure", 1, max(3, `lkey')) {
		DoExp `0'
	}
	else if `"`key'"' == substr("uncompensated", 1, max(6, `lkey')) {
		DoUncomp `0'
	}
	else if `"`key'"' == substr("compensated", 1, max(4, `lkey')) {
		DoComp `0'
	}
	else {
		di as error "invalid subcommand `key'"
		exit 321
	}
	
end

program DoExp, rclass

	syntax [anything(name = vlist id = "newvarlist")] [if] [in] 	///
		[, atmeans Stderrs]
	
	marksample touse

	if ("`stderrs'" != "" & "`atmeans'" == "") {
		qui count if `touse'
		if r(N) != 1 {
			di as err			/// 
"may only specify {bf:stderrs} if the selected sample has one observation"
			exit 198
		}
	}
	
	if "`atmeans'" == "" {
		_stubstar2names `vlist', nvars(`=e(ngoods)')
		local vars  `s(varlist)'
		local types `s(typlist)'
				// make our own names vlist_i instead of vlisti
		if `s(stub)' {	
			local vars ""
			local vlist : subinstr local vlist "*" ""
			if (`:word count `vlist'' == 2) {
				local vlist : word 2 of `vlist'
			}
			forvalues i = 1/`=e(ngoods)' {
				local vars `vars' `vlist'_`i'
			}
		}
		forvalues i = 1/`=e(ngoods)' {
			local v : word `i' of `vars'
			local t : word `i' of `types'
			qui gen `t' `v' = .
		}
	}
	else {
		if `"`vlist'"' != "" {
			di in smcl as error 			///
				"cannot specify varlist with {opt atmeans}"
			exit 198
		}
		tempname vars
	}	
	
	if "`stderrs'" != "" {
		tempname stderrmat
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
	mata:_quaids__expelas("`touse'", "`e(quadratic)'", 		///
			      "`atmeans'", "`lnp'", "`lnexp'", 		///
			      `ndemo', "`demos'",	 		///
			      "`stderrs'", "`stderrmat'",		///
			      "`vars'")
	if "`atmeans'" == "" {
		local i 1
		foreach var of varlist `vars' {
			lab var `var' "Expenditure elasticity: good `i'"
			local `++i'
		}
	}
	else {
		return matrix expelas = `vars'
	}
	
	if "`stderrs'" != "" {
		return matrix sd = `stderrmat'
	}

end


program DoUncomp, rclass

	syntax [anything(name = vlist id = "newvarlist")] [if] [in]	///
		[, atmeans Stderrs]
	
	marksample touse
	
	if ("`stderrs'" != "" & "`atmeans'" == "") {
		qui count if `touse'
		if r(N) != 1 {
			di as err			/// 
"may only specify {bf:stderrs} if the selected sample has one observation"
			exit 198
		}
	}
	
	if "`atmeans'" == "" {
		_stubstar2names `vlist', nvars(`=e(ngoods)^2')
		local vars  `s(varlist)'
		local types `s(typlist)'
			// make our own names vlist_i instead of vlisti
		if `s(stub)' {	
			local vars ""
			local vlist : subinstr local vlist "*" ""
			if (`:word count `vlist'' == 2) {
				local vlist : word 2 of `vlist'
			}
			forvalues i = 1/`=e(ngoods)' {
				forvalues j = 1/`=e(ngoods)' {
					local vars `vars' `vlist'_`i'_`j'
				}
			}
		}
		forvalues i = 1/`=e(ngoods)^2' {
			local v : word `i' of `vars'
			local t : word `i' of `types'
			qui gen `t' `v' = .
		}
	}
	else {
		if `"`vlist'"' != "" {
			di in smcl as error 			///
				"cannot specify varlist with {opt atmeans}"
			exit 198
		}
		tempname vars
	}
	
	if "`stderrs'" != "" {
		tempname stderrmat
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
	mata:_quaids__uncompelas("`touse'", "`e(quadratic)'",		///
				 "`atmeans'", "`lnp'", "`lnexp'",	///
				 `ndemo', "`demos'",			///
				 "`stderrs'", "`stderrmat'",		///
				 "`vars'")
	if "`atmeans'" == "" {
		loc m 1
		forvalues i = 1/`=e(ngoods)' {
			forvalues j = 1/`=e(ngoods)' {
				local v : word `m' of `vars'
				lab var `v' 				///
"Uncompensated elasticity: good `i', price `j'"
				local vars `vars' `vlist'_`i'_`j'
				local `++m'
			}
		}
	}
	else {
		return matrix uncompelas = `vars'
	}
	
	if "`stderrs'" != "" {
		return matrix sd = `stderrmat'
	}

end

program DoComp, rclass

	syntax [anything(name = vlist id = "newvarlist")] [if] [in] 	///
		[, atmeans Stderrs]

	marksample touse

	if ("`stderrs'" != "" & "`atmeans'" == "") {
		qui count if `touse'
		if r(N) != 1 {
			di as err			/// 
"may only specify {bf:stderrs} if the selected sample has one observation"
			exit 198
		}
	}
	
	if "`atmeans'" == "" {
		local ng = e(ngoods)
		local ngsq = `ng'^2
		_stubstar2names `vlist', nvars(`ngsq')
		local vars  `s(varlist)'
		local types `s(typlist)'
			// make our own names vlist_i instead of vlisti
		if `s(stub)' {		
			local vars ""
			local vlist : subinstr local vlist "*" ""
			if (`:word count `vlist'' == 2) {
				local vlist : word 2 of `vlist'
			}
			forvalues i = 1/`ng' {
				forvalues j = 1/`ng' {
					local vars `vars' `vlist'_`i'_`j'
				}
			}
		}
		forvalues i = 1/`ngsq' {
			local v : word `i' of `vars'
			local t : word `i' of `types'
			qui gen `t' `v' = .
		}
	}
	else {
		if `"`vlist'"' != "" {
			di in smcl as error 			///
				"cannot specify varlist with {opt atmeans}"
			exit 198
		}
		tempname vars
	}
	
	if "`stderrs'" != "" {
		tempname stderrmat
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
	mata:_quaids__compelas("`touse'", "`e(quadratic)'",		///
			       "`atmeans'", "`lnp'", "`lnexp'",		///
			       `ndemo', "`demos'",			///
			       "`stderrs'", "`stderrmat'",		///
			       "`vars'")
	if "`atmeans'" == "" {
		loc m 1
		forvalues i = 1/`=e(ngoods)' {
			forvalues j = 1/`=e(ngoods)' {
				local v : word `m' of `vars'
				lab var `v' 				///
				   "Compensated elasticity: good `i', price `j'"
				local vars `vars' `vlist'_`i'_`j'
				local `++m'
			}
		}
	}
	else {
		return matrix compelas = `vars'
	}
	
	if "`stderrs'" != "" {
		return matrix sd = `stderrmat'
	}
end

