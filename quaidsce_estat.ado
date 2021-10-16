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
		tempname lnpr
		local lnpr ""
		foreach var of varlist `e(lnprices)' {
			local lnp`i' `var'
			local lnpr `lnpr' `lnp`i''
			local `++i'
		}
	}
	else {
		local i 1
		tempname lnpr
		local lnpr ""
		foreach var of varlist `e(prices)' {
			tempvar lnp`i'
			gen double `lnp`i'' = ln(`var')
			local lnpr `lnpr' `lnp`i''
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

	if "`e(lhs)'" != "" { // This doesnt work if there is no censoring (what is it for?)
		local i 1
		foreach var of varlist `e(lhs)' {
			local w`i' `var'
			local `++i'
		}
	}
	
	//PROCESSING VARIABLES (MARGINS WONT WORK DUE TO PARAMETER NAMES, NLCOM DOES NOT PRODDUCE SE)

	local ndemo = `e(ndemos)'
	quietly {
		if "`e(censor)'" == "censor" {
		foreach x of varlist w* `lnpr' cdfw* pdfw* `lnexp' duw* `e(demographics)' {
		sum `x'
		scalar `x'm=r(mean)
		}
		}
		else {
		foreach x of varlist w* `lnpr' `lnexp' `e(demographics)' {
		sum `x'
		scalar `x'm=r(mean)
		}
		}
	}

	//AIDS
	tempname lnpindex
	scalar `lnpindex'= `e(anot)'
	forvalue i=1/`=e(ngoods)' {	
		scalar `lnpindex'= `lnpindex' + _b[alpha:alpha_`i']*`lnp`i''m
		forvalue j=1/`e(ngoods)' {
			if `j'>=`i' {
				scalar `lnpindex'= `lnpindex' + 0.5*(_b[gamma:gamma_`j'_`i']*(`lnp`i''m*`lnp`j''m))
			}
			 else {
				scalar `lnpindex'= `lnpindex' + 0.5*(_b[gamma:gamma_`i'_`j']*(`lnp`i''m*`lnp`j''m))
			}
		}
	}
	
	forvalues i = 1/`=e(ngoods)' {
		tempname gsum`i'
		local gsum`i' = 0	
		forvalues j = 1/`=e(ngoods)' {
			if `j'>=`i' {	
			local gsum`i' = `gsum`i''+_b[gamma:gamma_`j'_`i']*`lnp`i''m 
			}
			else {
			local gsum`i' = `gsum`i''+_b[gamma:gamma_`i'_`j']*`lnp`i''m 	
			}
		}
	}

	//When quadratics
	if "`e(quadratic)'" == "quadratic" {
		tempname bofp 
		scalar `bofp'= _b[beta:beta_1]*`lnp1'm		
		forvalues i = 2/`=e(ngoods)' {		
			 scalar `bofp'= `bofp' + _b[beta:beta_`i']*`lnp`i''m
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
				 scalar `cofp'= `cofp'*(`var'm*_b[eta:eta_`var'_`i']*`lnp`i''m) 
				 tempname betanz`i'
				 scalar `betanz`i''=_b[beta:beta_`i']+(`var'm*_b[eta:eta_`var'_`i'])						
			}			
		scalar `mbar'= `mbar' + (_b[rho:rho_`var']*`var'm)
		}										
		*replace `cofp' = exp(`cofp')
	}

	//FUNCTION EVALUATOR (PREDICTED SHARE)
	forvalues i = 1/`=e(ngoods)' {
		if `ndemo' == 0 {
		scalar we`i' = _b[alpha:alpha_`i']+_b[beta:beta_`i']*(lnexpm-`lnpindex') + `gsum`i''
			if "`e(quadratic)'" == "quadratic" {
				 scalar we`i' = we`i' + (lambda[1,`i']/exp(`bofp'))*(lnexpm-`lnpindex')^2
			}
		}
		else {
		scalar we`i' = _b[alpha:alpha_`i']+`betanz`i''*(lnexpm-`lnpindex'-ln(`mbar')) + `gsum`i''
			if "`e(quadratic)'" == "quadratic" {
				 scalar we`i' = we`i' + (_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))^2
				}
			}
		//When censor
		if "`e(censor)'" == "censor" {
		 scalar we`i' = we`i'*cdfw`i'm + _b[delta:delta_`i']*pdfw`i'm
		}			 
	}
		
	//FUNCTION EVALUATOR (ELASTICITY)
	forvalues i = 1/`=e(ngoods)' {
		if `ndemo' == 0 {
			global ie`i' "(1+_b[beta:beta_`i']/we`i')"
			if "`e(quadratic)'" == "quadratic" {
				 global ie`i' "(1+(1/we`i')*(_b[beta:beta_`i']+(2*_b[lambda:lambda_`i']/exp(`bofp'))*(lnexpm-`lnpindex')))"
			}
		}
		else {
			global ie`i' "(1+`betanz`i''/we`i')"
			if "`e(quadratic)'" == "quadratic" {
				 global ie`i' "(1+(1/we`i')*(`betanz`i''+(2*_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))))"
			}
		}
			//When censor
		if "`e(censor)'" == "censor" {
			global ie`i' "(${ie`i'}*cdfw`i'm + (_b[tau:M_`i']*pdfw`i'm*(w`i'm-_b[delta:delta_`i']*duw`i'm))/we`i')"
		}			 

	}
	
	tempname elasi sei
	mat elasi=J(1,`e(ngoods)',0)
	mat sei=J(1,`e(ngoods)',0)
	forvalues i = 1/`=e(ngoods)' {
		qui nlcom(${ie`i'})			
		mat elasi[1,`i'] = r(b)
		mat sei[1,`i'] = r(V)
		mat sei[1,`i'] = sqrt(sei[1,`i'])
	}
	ret mat elas_i elasi 
	ret mat se_elas_i sei
	
end


/// UNCOMPENSATED PRICE ELASTICITY

program DoUncomp, rclass

	syntax [if] [in] 
	
	marksample touse
	
	if "`e(lnprices)'" != "" {
		local i 1
		tempname lnpr
		local lnpr ""
		foreach var of varlist `e(lnprices)' {
			local lnp`i' `var'
			local lnpr `lnpr' `lnp`i''
			local `++i'
		}
	}
	else {
		local i 1
		tempname lnpr
		local lnpr ""
		foreach var of varlist `e(prices)' {
			tempvar lnp`i'
			gen double `lnp`i'' = ln(`var')
			local lnpr `lnpr' `lnp`i''
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

	if "`e(lhs)'" != "" { // This doesnt work if there is no censoring (what is it for?)
		local i 1
		foreach var of varlist `e(lhs)' {
			local w`i' `var'
			local `++i'
		}
	}
	
	//PROCESSING VARIABLES (MARGINS WONT WORK DUE TO PARAMETER NAMES, NLCOM DOES NOT PRODDUCE SE)

	local ndemo = `e(ndemos)'
	quietly {
		if "`e(censor)'" == "censor" {
		foreach x of varlist w* `lnpr' cdfw* pdfw* `lnexp' duw* `e(demographics)' {
		sum `x'
		scalar `x'm=r(mean)
		}
		}
		else {
		foreach x of varlist w* `lnpr' `lnexp' `e(demographics)' {
		sum `x'
		scalar `x'm=r(mean)
		}
		}
	}

	//AIDS
	tempname lnpindex
	scalar `lnpindex'= `e(anot)'
	forvalue i=1/`=e(ngoods)' {	
		scalar `lnpindex'= `lnpindex' + _b[alpha:alpha_`i']*`lnp`i''m
		forvalue j=1/`e(ngoods)' {
			if `j'>=`i' {
				scalar `lnpindex'= `lnpindex' + 0.5*(_b[gamma:gamma_`j'_`i']*(`lnp`i''m*`lnp`j''m))
			}
			 else {
				scalar `lnpindex'= `lnpindex' + 0.5*(_b[gamma:gamma_`i'_`j']*(`lnp`i''m*`lnp`j''m))
			}
		}
	}
	
	forvalues i = 1/`=e(ngoods)' {
		tempname gsum`i'
		local gsum`i' = 0	
		forvalues j = 1/`=e(ngoods)' {
			if `j'>=`i' {	
			local gsum`i' = `gsum`i''+_b[gamma:gamma_`j'_`i']*`lnp`i''m 
			}
			else {
			local gsum`i' = `gsum`i''+_b[gamma:gamma_`i'_`j']*`lnp`i''m 	
			}
		}
	}

	//When quadratics
	if "`e(quadratic)'" == "quadratic" {
		tempname bofp 
		scalar `bofp'= _b[beta:beta_1]*`lnp1'm		
		forvalues i = 2/`=e(ngoods)' {		
			 scalar `bofp'= `bofp' + _b[beta:beta_`i']*`lnp`i''m
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
				 scalar `cofp'= `cofp'*(`var'm*_b[eta:eta_`var'_`i']*`lnp`i''m) 
				 tempname betanz`i'
				 scalar `betanz`i''=_b[beta:beta_`i']+(`var'm*_b[eta:eta_`var'_`i'])						
			}			
		scalar `mbar'= `mbar' + (_b[rho:rho_`var']*`var'm)
		}										
		*replace `cofp' = exp(`cofp')
	}

	//FUNCTION EVALUATOR (PREDICTED SHARE)
	forvalues i = 1/`=e(ngoods)' {
		if `ndemo' == 0 {
		scalar we`i' = _b[alpha:alpha_`i']+_b[beta:beta_`i']*(lnexpm-`lnpindex') + `gsum`i''
			if "`e(quadratic)'" == "quadratic" {
				 scalar we`i' = we`i' + (lambda[1,`i']/exp(`bofp'))*(lnexpm-`lnpindex')^2
			}
		}
		else {
		scalar we`i' = _b[alpha:alpha_`i']+`betanz`i''*(lnexpm-`lnpindex'-ln(`mbar')) + `gsum`i''
			if "`e(quadratic)'" == "quadratic" {
				 scalar we`i' = we`i' + (_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))^2
				}
			}
		//When censor
		if "`e(censor)'" == "censor" {
		 scalar we`i' = we`i'*cdfw`i'm + _b[delta:delta_`i']*pdfw`i'm
		}			 
	}

	//FUNCTION EVALUATOR (ELASTICITY)

	forvalues i = 1/`=e(ngoods)' {
	forvalues j = 1/`=e(ngoods)' {
		local de=cond(`i'==`j',1,0)
		if `ndemo' == 0 {
			if `j'>=`i' {
			global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`j'_`i']-(_b[beta:beta_`i']*(_b[alpha:alpha_`i']+`gsum`i''))))"
			}
			else {
			global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`i'_`j']-(_b[beta:beta_`i']*(_b[alpha:alpha_`i']+`gsum`i''))))"	
			}
			if "`e(quadratic)'" == "quadratic" {
				if `j'>=`i' {	
					global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`j'_`i']-(_b[beta:beta_`i']+(2*_b[lambda:lambda_`i']/exp(`bofp')*(lnexpm-`lnpindex'))*(_b[alpha:alpha_`i']+`gsum`i''))-(_b[beta:beta_`i']*_b[lambda:lambda_`i']/exp(`bofp'))*(lnexpm-`lnpindex')^2)))"
				}
				else {
					global ue`i'`j'"(-`de'+(1/we`i')*(_b[gamma:gamma_`i'_`j']-(_b[beta:beta_`i']+(2*_b[lambda:lambda_`i']/exp(`bofp')*(lnexpm-`lnpindex'))*(_b[alpha:alpha_`i']+`gsum`i''))-(_b[beta:beta_`i']*_b[lambda:lambda_`i']/exp(`bofp'))*(lnexpm-`lnpindex')^2)))"
				}
			}
		}
		else {
			if `j'>=`i' {
			global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`j'_`i']-(`betanz`i''*(_b[alpha:alpha_`i']+`gsum`i''))))"
			}
			else {
			global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`i'_`j']-(`betanz`i''*(_b[alpha:alpha_`i']+`gsum`i''))))"	
			}
			if "`e(quadratic)'" == "quadratic" {
				if `j'>=`i' {	
				 global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`i'_`j']-(`betanz`i''+(2*_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))*(_b[alpha:alpha_`i']+`gsum`i''))-(`betanz`i''*_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))^2))"
				}
				else {
				global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`j'_`i']-(`betanz`i''+(2*_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))*(_b[alpha:alpha_`i']+`gsum`i''))-(`betanz`i''*_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))^2))"				
				}
			}	
		}
			//When censor
		if "`e(censor)'" == "censor" {
			global ue`i'`j' "(${ue`i'`j'}*cdfw`i'm + (_b[tau:p`i'_`j']*pdfw`i'm*(w`i'm-_b[delta:delta_`i']*duw`i'm))/we`i')"
		}			 
	}
	}
	
	tempname elasu seu
	mat elasu=J(`e(ngoods)',`e(ngoods)',0)
	mat seu=J(`e(ngoods)',`e(ngoods)',0)
	
	forvalues i = 1/`=e(ngoods)' {
		forvalues j = 1/`=e(ngoods)' {
			qui nlcom(${ue`i'`j'})			
			mat elasu[`i',`j'] = r(b)
			mat seu[`i',`j'] = r(V)
			mat seu[`i',`j'] = sqrt(seu[`i',`j'])
		}
	}
	ret mat elas_u elasu 
	ret mat se_elas_u seu
	
end


/// COMPENSATED PRICE ELASTICITY

program DoComp, rclass

	syntax [if] [in] 

	marksample touse
	
	if "`e(lnprices)'" != "" {
		local i 1
		tempname lnpr
		local lnpr ""
		foreach var of varlist `e(lnprices)' {
			local lnp`i' `var'
			local lnpr `lnpr' `lnp`i''
			local `++i'
		}
	}
	else {
		local i 1
		tempname lnpr
		local lnpr ""
		foreach var of varlist `e(prices)' {
			tempvar lnp`i'
			gen double `lnp`i'' = ln(`var')
			local lnpr `lnpr' `lnp`i''
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

	if "`e(lhs)'" != "" { // This doesnt work if there is no censoring (what is it for?)
		local i 1
		foreach var of varlist `e(lhs)' {
			local w`i' `var'
			local `++i'
		}
	}
	
	//PROCESSING VARIABLES (MARGINS WONT WORK DUE TO PARAMETER NAMES, NLCOM DOES NOT PRODDUCE SE)

	local ndemo = `e(ndemos)'
	quietly {
		if "`e(censor)'" == "censor" {
		foreach x of varlist w* `lnpr' cdfw* pdfw* `lnexp' duw* `e(demographics)' {
		sum `x'
		scalar `x'm=r(mean)
		}
		}
		else {
		foreach x of varlist w* `lnpr' `lnexp' `e(demographics)' {
		sum `x'
		scalar `x'm=r(mean)
		}
		}
	}

	//AIDS
	tempname lnpindex
	scalar `lnpindex'= `e(anot)'
	forvalue i=1/`=e(ngoods)' {	
		scalar `lnpindex'= `lnpindex' + _b[alpha:alpha_`i']*`lnp`i''m
		forvalue j=1/`e(ngoods)' {
			if `j'>=`i' {
				scalar `lnpindex'= `lnpindex' + 0.5*(_b[gamma:gamma_`j'_`i']*(`lnp`i''m*`lnp`j''m))
			}
			 else {
				scalar `lnpindex'= `lnpindex' + 0.5*(_b[gamma:gamma_`i'_`j']*(`lnp`i''m*`lnp`j''m))
			}
		}
	}
	
	forvalues i = 1/`=e(ngoods)' {
		tempname gsum`i'
		local gsum`i' = 0	
		forvalues j = 1/`=e(ngoods)' {
			if `j'>=`i' {	
			local gsum`i' = `gsum`i''+_b[gamma:gamma_`j'_`i']*`lnp`i''m 
			}
			else {
			local gsum`i' = `gsum`i''+_b[gamma:gamma_`i'_`j']*`lnp`i''m 	
			}
		}
	}

	//When quadratics
	if "`e(quadratic)'" == "quadratic" {
		tempname bofp 
		scalar `bofp'= _b[beta:beta_1]*`lnp1'm		
		forvalues i = 2/`=e(ngoods)' {		
			 scalar `bofp'= `bofp' + _b[beta:beta_`i']*`lnp`i''m
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
				 scalar `cofp'= `cofp'*(`var'm*_b[eta:eta_`var'_`i']*`lnp`i''m) 
				 tempname betanz`i'
				 scalar `betanz`i''=_b[beta:beta_`i']+(`var'm*_b[eta:eta_`var'_`i'])						
			}			
		scalar `mbar'= `mbar' + (_b[rho:rho_`var']*`var'm)
		}										
		*replace `cofp' = exp(`cofp')
	}

	//FUNCTION EVALUATOR (PREDICTED SHARE)
	forvalues i = 1/`=e(ngoods)' {
		if `ndemo' == 0 {
		scalar we`i' = _b[alpha:alpha_`i']+_b[beta:beta_`i']*(lnexpm-`lnpindex') + `gsum`i''
			if "`e(quadratic)'" == "quadratic" {
				 scalar we`i' = we`i' + (lambda[1,`i']/exp(`bofp'))*(lnexpm-`lnpindex')^2
			}
		}
		else {
		scalar we`i' = _b[alpha:alpha_`i']+`betanz`i''*(lnexpm-`lnpindex'-ln(`mbar')) + `gsum`i''
			if "`e(quadratic)'" == "quadratic" {
				 scalar we`i' = we`i' + (_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))^2
				}
			}
		//When censor
		if "`e(censor)'" == "censor" {
		 scalar we`i' = we`i'*cdfw`i'm + _b[delta:delta_`i']*pdfw`i'm
		}			 
	}
	
	//FUNCTION EVALUATOR (INCOME ELASTICITY)
	forvalues i = 1/`=e(ngoods)' {
		if `ndemo' == 0 {
			global ie`i' "(1+_b[beta:beta_`i']/we`i')"
			if "`e(quadratic)'" == "quadratic" {
				 global ie`i' "(1+(1/we`i')*(_b[beta:beta_`i']+(2*_b[lambda:lambda_`i']/exp(`bofp'))*(lnexpm-`lnpindex')))"
			}
		}
		else {
			global ie`i' "(1+`betanz`i''/we`i')"
			if "`e(quadratic)'" == "quadratic" {
				 global ie`i' "(1+(1/we`i')*(`betanz`i''+(2*_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))))"
			}
		}
			//When censor
		if "`e(censor)'" == "censor" {
			global ie`i' "(${ie`i'}*cdfw`i'm + (_b[tau:M_`i']*pdfw`i'm*(w`i'm-_b[delta:delta_`i']*duw`i'm))/we`i')"
		}			 

	}

	//FUNCTION EVALUATOR (UNCOMP ELASTICITY)

	forvalues i = 1/`=e(ngoods)' {
	forvalues j = 1/`=e(ngoods)' {
		local de=cond(`i'==`j',1,0)
		if `ndemo' == 0 {
			if `j'>=`i' {
			global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`j'_`i']-(_b[beta:beta_`i']*(_b[alpha:alpha_`i']+`gsum`i''))))"
			}
			else {
			global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`i'_`j']-(_b[beta:beta_`i']*(_b[alpha:alpha_`i']+`gsum`i''))))"	
			}
			if "`e(quadratic)'" == "quadratic" {
				if `j'>=`i' {	
					global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`j'_`i']-(_b[beta:beta_`i']+(2*_b[lambda:lambda_`i']/exp(`bofp')*(lnexpm-`lnpindex'))*(_b[alpha:alpha_`i']+`gsum`i''))-(_b[beta:beta_`i']*_b[lambda:lambda_`i']/exp(`bofp'))*(lnexpm-`lnpindex')^2)))"
				}
				else {
					global ue`i'`j'"(-`de'+(1/we`i')*(_b[gamma:gamma_`i'_`j']-(_b[beta:beta_`i']+(2*_b[lambda:lambda_`i']/exp(`bofp')*(lnexpm-`lnpindex'))*(_b[alpha:alpha_`i']+`gsum`i''))-(_b[beta:beta_`i']*_b[lambda:lambda_`i']/exp(`bofp'))*(lnexpm-`lnpindex')^2)))"
				}
			}
		}
		else {
			if `j'>=`i' {
			global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`j'_`i']-(`betanz`i''*(_b[alpha:alpha_`i']+`gsum`i''))))"
			}
			else {
			global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`i'_`j']-(`betanz`i''*(_b[alpha:alpha_`i']+`gsum`i''))))"	
			}
			if "`e(quadratic)'" == "quadratic" {
				if `j'>=`i' {	
				 global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`i'_`j']-(`betanz`i''+(2*_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))*(_b[alpha:alpha_`i']+`gsum`i''))-(`betanz`i''*_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))^2))"
				}
				else {
				global ue`i'`j' "(-`de'+(1/we`i')*(_b[gamma:gamma_`j'_`i']-(`betanz`i''+(2*_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))*(_b[alpha:alpha_`i']+`gsum`i''))-(`betanz`i''*_b[lambda:lambda_`i']/exp(`bofp')/exp(`cofp'))*(lnexpm-`lnpindex'-ln(`mbar'))^2))"				
				}
			}	
		}
			//When censor
		if "`e(censor)'" == "censor" {
			global ue`i'`j' "(${ue`i'`j'}*cdfw`i'm + (_b[tau:p`i'_`j']*pdfw`i'm*(w`i'm-_b[delta:delta_`i']*duw`i'm))/we`i')"
		}			 
	}
	}
		
	tempname elasc sec
	mat elasc=J(`e(ngoods)',`e(ngoods)',0)
	mat sec=J(`e(ngoods)',`e(ngoods)',0)
	forvalues i = 1/`=e(ngoods)' {
		forvalues j = 1/`=e(ngoods)' {
			global ce`i'`j' "(${ue`i'`j'} + ${ie`i'}*we`j')" 
			qui nlcom(${ce`i'`j'})			
			mat elasc[`i',`j'] = r(b)
			mat sec[`i',`j'] = r(V)
			mat sec[`i',`j'] = sqrt(sec[`i',`j'])
		}
	}
	ret mat elas_c elasc 
	ret mat se_elas_c sec

end
