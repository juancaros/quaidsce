*! version 1.1.0  Sep 2021

program quaidsce_estat

	version 12
	
	if "`e(cmd)'" != "quaidsce" {
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


/// EXPENDITURE ELASTICITY

program DoExp, rclass

	syntax [if] [in] 
	
	marksample touse
	
	*there are misisng inputs here (pdf, cdf, du, tau, setau)
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
		local i 1 
		foreach var of varlist `e(demographics)' {
			local d_`i' `var'
		local `++i'	
		}
	}

/// WRITE HERE THE IF/ELSE WITH THE CORRESPONDING FORMULA FOR THE SHARES USING LOCALS SO WE CAN PREDICT USING MARGINS



/// WRITE HERE THE LOOP FOR THE MARGINS COMMAND INTO TWO MATRICES (elas, se) AND RETURN AS e()

	for i=1(1)`J' {
		margins, predict(`local_ie`i'')			/// add corresponding formula for elasticity `i' given the coefficients
		elasi[`i'] = e(b)
		sei[`i'] = sqrt(e(sd))
	}
	
	return post elasi sei
	
end

/// UNCOMPENSATED PRICE ELASTICITY

program DoUncomp, rclass

	syntax [if] [in] 
	
	marksample touse

	*there are misisng inputs here (pdf, cdf, du, w)
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
		local i 1 
		foreach var of varlist `e(demographics)' {
			local d_`i' `var'
		local `++i'	
		}
	}
	
/// WRITE HERE THE IF/ELSE WITH THE CORRESPONDING FORMULA FOR THE SHARES USING LOCALS SO WE CAN PREDICT USING MARGINS

/// WRITE HERE THE LOOP FOR THE MARGINS COMMAND INTO TWO MATRICES (elas, se) AND RETURN AS e()

	for i=1(1)`J' {
		for j=1(1)`J' {
			margins, predict(`local_ue`i'`j'')			/// add corresponding formula for uncompensated elasticity `i'`j' given the coefficients
			elasu[`i',`j'] = e(b)
			seu[`i',`j'] = sqrt(e(sd))
		}
	}	
	
	return post elasu seu
	
end

end

/// COMPENSATED PRICE ELASTICITY

program DoComp, rclass

	syntax [if] [in] 

	marksample touse
	
	*there are misisng inputs here (pdf, cdf, du, w)
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
		local i 1 
		foreach var of varlist `e(demographics)' {
			local d_`i' `var'
		local `++i'	
		}
	}

/// WRITE HERE THE IF/ELSE WITH THE CORRESPONDING FORMULA FOR THE SHARES USING LOCALS SO WE CAN PREDICT USING MARGINS

/// WRITE HERE THE LOOP FOR THE MARGINS COMMAND INTO TWO MATRICES (elas, se) AND RETURN AS e()

	for i=1(1)`J' {
		margins, predict(`local_ie`i'')			/// add corresponding formula for income elasticity `i' given the coefficients
		elasi[`i'] = e(b)
		sei[`i'] = sqrt(e(sd))
	}

	for i=1(1)`J' {
		for j=1(1)`J' {
			margins, predict(`local_ue`i'`j'')			/// add corresponding formula for uncompensated elasticity `i'`j' given the coefficients
			elasu[`i',`j'] = e(b)
			seu[`i',`j'] = sqrt(e(sd))
		}
	}	
	
	for i=1(1)`J' {
		for j=1(1)`J' {
			margins, predict(`local_ce`i'`j'')			/// add corresponding formula for compensated elasticity `i'`j' given the coefficients
			elase[`i',`j'] = e(b)
			sec[`i',`j'] = sqrt(e(sd))
		}
	}	

	return post elasc sec

end

