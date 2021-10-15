*! version 1.1.1  Sep 2021

program quaidsce, eclass

	version 12

	if replay() {
		if "`e(cmd)'" != "quaidsce" {
			error 301 
		}
		Display `0'
		exit
	}
	
	Estimate `0'

end

program Estimate, eclass

	version 12

	syntax varlist [if] [in] ,					///
		  ANOT(real)						///
		[ LNEXPenditure(varlist min=1 max=1 numeric) 		///
		  EXPenditure(varlist min=1 max=1 numeric) 		///
		  PRices(varlist numeric)				///
		  LNPRices(varlist numeric) 				///
		  DEMOgraphics(varlist numeric)				///
		  noQUadratic 						///
		  noCEnsor   ///
		  INITial(name) noLOg Level(cilevel) VCE(passthru) Method(name) * ] 
		  
		  
	local shares `varlist'
	
	*di `shares'
	
	if "`options'" != "" {
		di as error "`options' not allowed"
		exit 198
	}
	
	if "`prices'" != "" & "`lnprices'" != "" {
		di as error "cannot specify both {cmd:prices()} and "	///
			as error "{cmd:lnprices()}"
		exit 198
	}
	if "`prices'`lnprices'" == "" {
		di as error "must specify {cmd:prices()} or {cmd:lnprices()}"
		exit 198
	}
	
	if "`expenditure'" != "" & "`lnexpenditure'" != "" {
		di as error "cannot specify both {cmd:expenditure()} "	///
			as error "and {cmd:lnexpenditure()}"
		exit 198
	}
	if "`expenditure'`lnexpenditure'" == "" {
		di as error						///
"must specify {cmd:expenditure()} or {cmd:lnexpenditure()}"
		exit 198
	}
		
	local neqn : word count `shares'
	if `neqn' < 3 {
		di as error "must specify at least 3 expenditure shares"
		exit 498
	}
	
	if `=`:word count `prices'' + `:word count `lnprices''' != `neqn' {
		if "`prices'" != "" {
			di as error "number of price variables must "	///
				as error "equal number of equations "	///
				as error "(`neqn')"
		}
		else {
			di as error "number of log price variables "	///
				as error "must equal number of "	///
				as error "equations (`neqn')"
		}
		exit 498
	}

	marksample touse
	markout `touse' `prices' `lnprices' `demographics'
	markout `touse' `expenditure' `lnexpenditure'



	local i 1
	while (`i' < `neqn') {
		local shares2 `shares2' `:word `i' of `shares''
		local `++i'
	}
	
	// Check whether variables make sense
	if "`censor'" == "nocensor" {
		tempvar sumw
		egen double `sumw' = rsum(`shares') if `touse'
		cap assert reldif(`sumw', 1) < 1e-4 if `touse'
		if _rc {
			di as error "expenditure shares do not sum to one"
			exit 499
		}	
	}

	if "`prices'" != "" {
		local usrprices 1
		local lnprices
		foreach x of varlist `prices' {
			summ `x' if `touse', mean
			if r(min) <= 0 {
				di as error "nonpositive value(s) for `x' found"
				exit 499
			}
			tempvar ln`x'
			qui gen double `ln`x'' = ln(`x') if `touse'
			local lnprices `lnprices' `ln`x''
		}
	}
	if "`expenditure'" != "" {
		local usrexpenditure 1
		summ `expenditure' if `touse', mean
		if r(min) <= 0 {
			di as error "nonpositive value(s) for "		///
				as error "`expenditure' found"
			exit 499
		}
		tempvar lnexp
		qui gen double `lnexp' = ln(`expenditure') if `touse'
		local lnexpenditure `lnexp'
	}
	
	
	if "`quadratic'" == "noquadratic" {
		local np = 2*(`neqn'-1) + `neqn'*(`neqn'-1)/2
		local np2 = 2*(`neqn') + `neqn'*(`neqn'-1)/2
	}
	else {
		local np = 3*(`neqn'-1) + `neqn'*(`neqn'-1)/2
		local np2 = 3*(`neqn') + `neqn'*(`neqn'-1)/2
	}
	
	
	
	if "`demographics'" == "" {
		local demos "nodemos"
		local demoopt ""
		local ndemos = 0
	}
	else {
		local demos ""
		local demoopt "demographics(`demographics')"
		local ndemos : word count `demographics'
		local np = `np' + `ndemos'*(`neqn'-1) + `ndemos'
		local np2 = `np2' + `ndemos'*(`neqn'-1) + `ndemos'
	}
	
	if "`initial'" != "" {
		local rf = rowsof(`initial')
		local cf = colsof(`initial')
		if `rf' != 1 | `cf' != `np' {
			di "Initial vector must be 1 x `np'"
			exit 503
		}
		else {
			local initialopt initial(`initial')
		}
	}
	
	if "`method'" == "" {
		local estimator "ifgnls"
		}
		else {
			local estimator `method'
		}

		//First stage
		local pdf
		local cdf
		capture drop cdf?? 
		capture drop pdf?? 
		capture drop du??
		
		if "`censor'" == "nocensor" {
		foreach x of varlist `shares2' {
		qui gen pdf`x'=0
		qui gen cdf`x'=1
		local pdf `pdf' pdf`x'
		local cdf `cdf' cdf`x'
		}
		}
		else {
		local np_prob : word count `lnprices' `lnexp'  `demographics' intercept
		local nprob M `demographics' cons
		
		mat tau=J(1,`np_prob',0)
		mat setau=J(`np_prob'*`neqn',`np_prob'*`neqn',0)		
		foreach x of varlist `shares' {
			summ `x' if `touse', mean
			if r(min) > 0 {
				di as error "noncensoring for `x' found"
				exit 499
			}
			tempvar z`x' 
			local pdf`x' 
			local cdf`x'
			local du`x'
			qui gen double `z`x'' = 1 if `x' > 0  & `touse'
			qui replace `z`x'' = 0 if `x' == 0  & `touse'
			qui gen pdf`x'=0
			qui gen cdf`x'=1
			
			summ `z`x'' if `touse', mean
			if r(min) == 0 {
			qui probit `z`x'' `lnprices' `lnexp'  `demographics'
			
			tempname xn loc lof
			local xn = substr("`x'",2,1)
			if `xn'==1 {
				mat tau= e(b)'
				mat setau[1,1]= e(V)
			}
			else {
				mat tau=tau \ e(b)'
				local loc = `np_prob'*(`xn'-1)+1
				mat setau[`loc',`loc'] = e(V)
			}
			quietly predict du`x'
			
			if e(N) < _N {
			di as error "at least one variable completely predicts probit outcome, check your data"
				exit 499
			}
			qui replace pdf`x'= normalden(du`x')
			qui replace cdf`x'= normal(du`x')
			}
			local pdf `pdf' pdf`x'
			local cdf `cdf' cdf`x'
			local du `du' `du`x''
		}
		}
			
		
		if "`censor'" == "nocensor" {
		local shares `shares2' 
		local np2= `np'
		local neqn2=`=`neqn'-1'
		}
		else {
		local np2= `np2' + `neqn' //add deltas
		local neqn2 `neqn'
		}
		
		
nlsur __quaidsce @ `shares' if `touse',				///
		lnp(`lnprices') lnexp(`lnexpenditure') cdfi(`cdf') pdfi(`pdf') a0(`anot')	///
		nparam(`np2') neq(`neqn2') `estimator' noeqtab nocoeftab	///
		`quadratic' `options' `censor' `demoopt'  `initialopt' `log' `vce' 

		if "`censor'" == "nocensor" {
		capture drop cdf?? pdf?? 
		}

	// do delta method to get cov matrix

	tempname b bfull V Vfull Delta aux auxt Vfullc bfullc
	mat `b' = e(b)
	mat `V' = e(V)

	mata:_quaidsce__fullvector("`b'", `neqn', "`quadratic'", `ndemos', "`bfull'", "`censor'")
	mata:_quaidsce__delta(`neqn', "`quadratic'", "`censor'", `ndemos', "`Delta'")
	mat `Vfull' = `Delta'*`V'*`Delta''
	
	if "`censor'" == "" {
	mat `bfullc' = `bfull' , tau'
	mat `aux' = J(rowsof(`Vfull'),rowsof(setau),0)
	mat `auxt' = J(rowsof(setau),rowsof(`Vfull'),0)
	mat `auxt' = `auxt' , setau
	mat `aux' = `Vfull' , `aux'
	mat `Vfullc' = `aux' \ `auxt'
	}
	else {
	mat `bfullc' = `bfull'
	mat `Vfullc' = `Vfull'
	}
	
	forvalues i = 1/`neqn' {
		local namestripe `namestripe' alpha:alpha_`i'
	}
	forvalues i = 1/`neqn' {
		local namestripe `namestripe' beta:beta_`i'
	}
	forvalues j = 1/`neqn' {
		forvalues i = `j'/`neqn' {
			local namestripe `namestripe' gamma:gamma_`i'_`j'
		}
	}
	if "`quadratic'" == "" {
		forvalues i = 1/`neqn' {
			local namestripe `namestripe' lambda:lambda_`i'
		}
	}
	
	
	if "`censor'" == "" {
		forvalues i = 1/`neqn' {
			local namestripe `namestripe' delta:delta_`i'
		}
	}

	if `ndemos' > 0 {
		foreach var of varlist `demographics' {
			forvalues i = 1/`neqn' {
				local namestripe `namestripe' eta:eta_`var'_`i'
			}
		}
		foreach var of varlist `demographics' {
			local namestripe `namestripe' rho:rho_`var'
		}
	}
	if "`censor'" == "" {
		forvalues i = 1/`neqn' {
			forvalues j = 1/`neqn' {
				local namestripe `namestripe' tau:p`j'_`i'
			}
			foreach x in `nprob' {
				local namestripe `namestripe' tau:`x'_`i'
			}
		}
	}

	mat colnames `bfullc' = `namestripe'
	mat colnames `Vfullc' = `namestripe'
	mat rownames `Vfullc' = `namestripe'
	
	tempname alpha beta gamma lambda delta eta rho ll
	mata:_quaidsce__getcoefs("`b'", `neqn', "`quadratic'", "`censor'", `ndemos', 	///
			"`alpha'", "`beta'", "`gamma'", "`lambda'", "`delta'",	///
			"`eta'", "`rho'")	
			
	scalar `ll' = e(ll)
	local vcetype	`e(vcetype)'
	local clustvar	`e(clustvar)'
	local vcer	`e(vce)'
	local nclust	`e(N_clust)'

	qui count if `touse'
	local capn = r(N)
	
	eret post `bfullc' `Vfullc', esample(`touse')	
	
	eret matrix alpha	= `alpha'
	eret matrix beta	= `beta'
	eret matrix gamma	= `gamma'
	if "`quadratic'" == "" {
		eret matrix lambda = `lambda'
		eret local quadratic	"quadratic"
	}
	else {
		eret local quadratic	"noquadratic"
	}	
	if "`censor'" == "" {
		eret matrix delta = `delta'
		mat tau = tau'
		eret matrix tau tau
		eret local censor	"censor"
	}
	else {
		eret local censor	"nocensor"
	}
	if `ndemos' > 0 {
		eret matrix eta = `eta'
		eret matrix rho = `rho'
		eret local demographics `demographics'
		eret scalar ndemos = `ndemos'
	}
	else {
		eret scalar ndemos = 0
	}
	
	eret scalar N		= `capn'
	eret scalar ll		= `ll'
	
	eret scalar anot	= `anot'
	eret scalar ngoods	= `neqn'

	if "`usrprices'" != "" {
		eret local prices	`prices'
	}
	else {
		eret local lnprices	`lnprices'
	}
	if "`usrexpenditure'" != "" {
		eret local expenditure	`expenditure'
	}
	else {
		eret local lnexpenditure `lnexpenditure'
	}
	eret local lhs		"`shares'"
	eret local demographics	"`demographics'"
	
	eret local vcetype	`vcetype'
	eret local clustvar	`clustvar'
	eret local vcer		`vce'
	if "`nclust'" != "" {
		eret scalar N_clust	= `nclust'
	}
	
	eret local predict	"quaidsce_p"
	eret local estat_cmd 	"quaidsce_estat"
	eret local cmd 		"quaidsce"

	Display, level(`level')

end

program Display

	syntax , [Level(cilevel)]
	
	di
	if "`censor'" == "" & "`quadratic'" == "" {
		di in smcl as text "Censored Quadratic AIDS model"
		di in smcl as text "{hline 20}"
	}
	else if "`quadratic'" == "" & "`censor'" == "nocensor" {
		di in smcl as text "Quadratic AIDS model"
		di in smcl as text "{hline 20}"
	}
	else if "`censor'" == "" {
		di in smcl as text "Censored AIDS model"
		di in smcl as text "{hline 20}"
	}
	else {
		di in smcl as text "AIDS model"
		di in smcl as text "{hline 10}"
	}
	di as text "Number of obs          = " as res %10.0g `=e(N)'
	di as text "Number of demographics = " as res %10.0g `=e(ndemos)'
	di as text "Alpha_0                = " as res %10.0g `=e(anot)'
	di as text "Log-likelihood         = " as res %10.0g `=e(ll)'
	di
	
	_coef_table, level(`level')
	
end
exit

