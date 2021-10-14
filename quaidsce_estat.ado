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
			gen double `lnp`i'' = ln(`var')
			local `++i'
		}
	}
	
	if "`e(lnexpenditure)'" != "" {
		local lnexp `e(lnexpenditure)'
	}
	else {
		tempvar exp
		gen double `exp' = ln(`e(expenditure)')
		local lnexp `exp'
	}

	if "`e(lhs)'" != "" {
		local i 1
		foreach var of varlist `e(lhs)' {
			local w`i' `var'
			local `++i'
		}
	}
	
	//PROCESSING VARIABLES (MARGINS WONT WORK DUE TO PARAMETER NAMES, NLCOM DOES NOT PRODDUCE SE)

	local ndemo = `e(ndemos)'
	quietly {
		foreach x of varlist w* lnp* cdfw* pdfw* lnexp duw* `e(demographics)' {
		sum `x'
		scalar `x'm=r(mean)
		}
	}

	//AIDS
	tempname lnpindex
	scalar `lnpindex'= `e(anot)'
	forvalue i=1/`=e(ngoods)' {	
		scalar `lnpindex'= `lnpindex' + _b[alpha:alpha_`i']*lnp`i'm
		forvalue j=1/`e(ngoods)' {
			if `j'>=`i' {
				scalar `lnpindex'= `lnpindex' + 0.5*(_b[gamma:gamma_`j'_`i']*(lnp`i'm*lnp`j'm))
			}
			 else {
				scalar `lnpindex'= `lnpindex' + 0.5*(_b[gamma:gamma_`i'_`j']*(lnp`i'm*lnp`j'm))
			}
		}
	}

	//When quadratics
	if "`e(quadratic)'" == "quadratic" {
		tempname bofp 
		scalar `bofp'= _b[beta:beta_1]*lnp1m		
		forvalues i = 2/`=e(ngoods)' {		
			 scalar `bofp'= `bofp' + _b[beta:beta_`i']*lnp`i'm
		}
		*replace `bofp'= exp(`bofp')
	}
	
	//When demographics
	if `ndemo' > 0 {			
		tempname cofp mbar
		scalar `cofp'= 1 //It is OK to set 1 because below we set a multiplication
		scalar `mbar'= 1 //It is OK because I need to add a "1"
		foreach var of varlist `e(demographics)' {	
			forvalue i=1/`=e(ngoods)' {
				 scalar `cofp'= `cofp'*(`var'm*_b[eta:eta_`var'_`i']*lnp`i'm) 
				 tempname betanz`i'
				 scalar `betanz`i''=_b[beta:beta_`i']+(`var'm*_b[eta:eta_`var'_`i'])						
			}			
		scalar `mbar'= `mbar' + (_b[rho:rho_`var']*`var'm)
		}										
		*replace `cofp' = exp(`cofp')
	}

	//FUNCTION EVALUATOR (PREDICTED SHARE)
	forvalues i = 1/`=e(ngoods)' {
		forvalues j = 1/`=e(ngoods)' {
			if `ndemo' == 0 {
				if `j'>=`i' {
				scalar we`i' = _b[alpha:alpha_`i']+_b[beta:beta_`i']*(lnexpm-`lnpindex')+_b[gamma:gamma_`j'_`i']*`lnp`i''
				}
				else {
				scalar we`i' = _b[alpha:alpha_`i']+_b[beta:beta_`i']*(lnexpm-`lnpindex')+_b[gamma:gamma_`i'_`j']*`lnp`i''
				}
				if "`e(quadratic)'" == "quadratic" {
					 scalar we`i' = we`i' + (lambda[1,`i']/exp(`bofp'))*(lnexpm-`lnpindex')^2
				}
			}
			else {
				if `j'>=`i' {
				scalar we`i' = _b[alpha:alpha_`i']+`betanz`i''*(lnexpm-`lnpindex'-ln(`mbar'))+_b[gamma:gamma_`j'_`i']*`lnp`i''
				}
				else {
				scalar we`i' = _b[alpha:alpha_`i']+`betanz`i''*(lnexpm-`lnpindex'-ln(`mbar'))+_b[gamma:gamma_`i'_`j']*`lnp`i''
				}	
				if "`e(quadratic)'" == "quadratic" {
					 scalar we`i' = we`i' + (_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))^2
					}
				}
			//When censor
			if "`e(censor)'" == "censor" {
			 scalar we`i' = we`i'*cdfw`i'm + _b[delta:delta_`i']*pdfw`i'm
			}			 
		}
	}
		
	//FUNCTION EVALUATOR (ELASTICITY)
	forvalues i = 1/`=e(ngoods)' {
		if `ndemo' == 0 {
			global ie`i' = 1+_b[beta:beta_`i']/we`i'
			if "`e(quadratic)'" == "quadratic" {
				 global ie`i' = 1+(1/we`i')*(_b[beta:beta_`i']+(2*_b[lambda:lambda_`i']/exp(`bofp'))*(lnexpm-`lnpindex'))
			}
		}
		else {
			global ie`i' = 1+`betanz`i''/we`i'
			if "`e(quadratic)'" == "quadratic" {
				 global ie`i' = 1+(1/we`i')*(`betanz`i''+(2*_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar')))
			}
		}
			//When censor
		if "`e(censor)'" == "censor" {
			global ie`i' = ${ie`i'}*cdfw`i'm + (_b[tau:M_`i']*pdfw`i'm*(w`i'm-_b[delta:delta_`i']*duw`i'm))/we`i'
		}			 

	}
	
	tempname elasi sei
	mat `elasi'=J(1,`e(ngoods)',0)
	mat `sei'=J(1,`e(ngoods)',0)
	forvalues i = 1/`=e(ngoods)' {
		nlcom(${ie`i'})			
		*mat elasi[1,`i'] = r(b)
		*mat sei[1,`i'] = sqrt(r(V)) 
	}
	*local cn: colnames `elasi'
	*matrix colnames `elasi' = `cn'
	*matrix colnames `sei' = `cn'
	*ereturn post `elasi' `sei'
	
end


/// UNCOMPENSATED PRICE ELASTICITY

program DoUncomp, rclass

	syntax [if] [in] 
	
	marksample touse
	
	ereturn post elasu seu
	
end


/// COMPENSATED PRICE ELASTICITY

program DoComp, rclass

	syntax [if] [in] 

	marksample touse
	
	return post elasc sec

end

