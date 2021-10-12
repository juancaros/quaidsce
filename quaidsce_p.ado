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

	if "`e(lhs)'" != "" {
		local i 1
		foreach var of varlist `e(lhs)' {
			local w`i' `var'
			local `++i'
		}
	}
	
	tempname alpha beta gamma lambda delta eta rho tau
	mat alpha = e(alpha)
	mat beta = e(beta)
	mat gamma = e(gamma)
	if "`e(quadratic)'" == "quadratic" {
	mat lambda = e(lambda)
	}
	local ndemo = `e(ndemos)'
	if `ndemo' > 0 {
	mat eta = e(eta)
	mat rho = e(rho)
	}
	if "`e(censor)'" == "censor" {
	mat delta = e(delta)
	mat tau = e(tau)
	}
	
/// REPLACE VARIABLES FROM PREDICTIONS BASED ON THE STUBS `v' and the right formula	
	//JCSH salvar variables temporales como double
	
	//When quadratics
	if "`e(quadratic)'" == "quadratic" {
		tempvar bofp lnpindex
		
			gen `bofp'= beta[1,1]*`lnp1' 		
		forvalues i = 2/`=e(ngoods)' {		
		replace `bofp'= `bofp' + beta[1,`i']*`lnp`i''
									}
		replace `bofp'= exp(`bofp')
		

		local alpha0=   `e(anot)' 
		gen `lnpindex'= `alpha0'
		forvalue i=1/`=e(ngoods)' {	
			quiet replace `lnpindex'= `lnpindex' + alpha[1,`i']*`lnp`i''
			local j=`i' 
			forvalue ii=`j'/`=e(ngoods)' {
				quiet replace `lnpindex'=  `lnpindex' + 0.5*(gamma[`ii',`i']*(`lnp`i''*`lnp`ii''))
				//JCSH verificar que el 0.5 multiplica cada combinacion 	
				}
		}	
	}	
	
	//When demographics
	if `ndemo' > 0 {			
		tempvar cofp mbar
			
			gen `cofp'= 1 //It is OK to set 1 because below we set a multiplication
			gen double `mbar'= 1 //It is OK because I need to add a "1"
			
			foreach var of varlist `e(demographics)' {	
			local n_demo= 1
			forvalue i=1/`=e(ngoods)' {
				
				replace `cofp'= `cofp'*(`d_`var''*eta[`n_demo',`i']*`lnp`i'') 
				//JCSH verificar que sea una multiplicacion de todo
				
				tempvar betanz`i'
					gen `betanz`i''=.
				replace `betanz`i''=beta[1,`i']+(`d_`var''*eta[`n_demo',`i'])												
								}
								
		replace `mbar'= `mbar' + (rho[1,`n_demo']*`d_`var'') 					
			local n_demo= `n_demo' + 1							
		}										
		replace `cofp' = exp(`cofp')
		
	
	}
		
	//Uncompensated prices elasticities	
		forvalues j = 1/`=e(ngoods)' {
		local v : word `j' of `vars'
		qui replace `v' = -1 + (1/`w`j'')*(gamma[1,1])
		//JCSH necesito w observada o latente
		}
				
end

exit
