*! version 1.1.1  04sep2013
/*
	_quaids__utils.mata
	
	Mata routines called by
		nlsur__quaids.ado
		quaids_estat.ado
		quaids_p.ado
*/

mata

mata set matastrict on

void _quaids__expelas(string scalar touses,
		      string scalar quadratics,
		      string scalar atmeans,
		      string scalar lnps,
		      string scalar lnexps,
		      real   scalar ndemo,
		      string scalar demos,
		      string scalar stderrs,
		      string scalar stderrmat,
		      string scalar expelass)
{
	real scalar	i
	string scalar	s
	real vector	lnexp
	real matrix	demo, shares, expelas, lnp, semat
	
	ndemo = st_numscalar("e(ndemos)")
	
	if (ndemo > 0) {
		if (atmeans == "") {
			st_view(demo=., ., demos, touses)
		}
		else {
			demo = mean(st_data(., demos, touses))
		}
	}

	if (atmeans == "") {
		st_view(shares=.,  ., st_global("e(lhs)"),  touses)
		st_view(lnp=.,     ., lnps, touses)
		st_view(lnexp=.,   ., lnexps, touses)
		expelas = J(rows(lnp), cols(shares), .)
	}
	else {
		shares  = mean(st_data(., st_global("e(lhs)"), touses))
		lnp     = mean(st_data(., lnps, touses))
		lnexp   = mean(st_data(., lnexps, touses))
		expelas = J(1, cols(shares), .)
	}
	
	_quaids__expelas_wrk(st_matrix("e(best)"), quadratics,
			     ndemo, shares, lnp, lnexp, demo, expelas)

	if (stderrs != "") {
		_quaids__expelas_stderr(st_matrix("e(best)"), quadratics,
			     ndemo, shares, lnp, lnexp, demo, semat)
		st_matrix(stderrmat, semat)
	}
			     
	if (atmeans != "") {
		st_matrix(expelass, expelas)
	}
	else {
		s = tokens(expelass)
		for(i=1; i<=cols(expelas); ++i)		      
			st_store(., s[i], touses, expelas[.,i])
	}	

}

void _quaids__expelas_stderr(real vector   params,
			     string scalar quadratics,
			     real scalar   ndemo,
			     real matrix   shares,
			     real matrix   lnp,
			     real vector   lnexp,
			     real matrix   demo,
			     real matrix   semat)
{

	real matrix  J, V
	transmorphic D
	
	D = deriv_init()
	deriv_init_evaluator(D, &_quaids__expelas_wrk())
	deriv_init_evaluatortype(D, "t")
	deriv_init_params(D, params)
	deriv_init_argument(D, 1, quadratics)
	deriv_init_argument(D, 2, ndemo)
	deriv_init_argument(D, 3, shares)
	deriv_init_argument(D, 4, lnp)
	deriv_init_argument(D, 5, lnexp)
	deriv_init_argument(D, 6, demo)
	J = deriv(D, 1)
	V = J*st_matrix("e(Vest)")*J'
	semat = diagonal(cholesky(diag(diagonal(V))))'
	

}

void _quaids__expelas_wrk(real vector   params,
			  string scalar quadratics,
			  real scalar   ndemo,
			  real matrix   shares,
			  real matrix   lnp,
			  real vector   lnexp,
			  real matrix	demo,
			  real matrix   expelas)
{
        real scalar	i, ng
	real vector	bofp, lnpindex, cofp, mbar
	real vector	alpha, beta, lambda, rho
	real matrix	gamma, eta

	
	ng = st_numscalar("e(ngoods)")
	/*
		This is necessary because deriv() wants to redimension
		expelas every time it calls us.  deriv() will only call
		use when rows(expelas) is 1.
	*/
	if (rows(expelas) == 1) 	expelas = J(1, ng, .)
	
	_quaids__getcoefs_wrk(params, ng, 
		      	      quadratics, ndemo,
		      	      alpha, beta, gamma, lambda, eta, rho)
	if (quadratics == "") {
		bofp = exp(lnp*beta')
		lnpindex = lnp*alpha' :+ st_numscalar("e(anot)")
		for(i=1; i<=rows(lnpindex); ++i) {
			lnpindex[i] = lnpindex[i] + 0.5*lnp[i,.]*gamma*lnp[i,.]'
		}
	}
	else {
		bofp = J(rows(lnp), 1, 1)	// 1, so now div0 problem
		lnpindex = J(rows(lnp), 1, 0)
		lambda = J(rows(beta),cols(beta),0)
	}
	if (ndemo > 0) {
		cofp = J(rows(lnp), 1, 0)
		for(i=1; i<=rows(lnp); ++i) {
			cofp[i] = lnp[i,.]*(eta'*demo[i,.]')
		}
		cofp = exp(cofp)
		mbar = 1 :+ demo*rho'
		for(i=1; i<=rows(expelas); ++i) {
			expelas[i,.] = 1 :+ 1:/shares[i,.]:*
	(beta + demo[i,.]*eta + 2*lambda/bofp[i]/cofp[i]*
			(lnexp[i]-ln(mbar[i])-lnpindex[i]))
		}
	}
	else {
		for(i=1; i<=rows(expelas); ++i) {
			expelas[i,.] = 1 :+ 1:/shares[i,.]:*
				(beta + 2*lambda/bofp[i]*(lnexp[i]-lnpindex[i]))
		}
	}

}


void _quaids__uncompelas(string scalar touses,
			 string scalar quadratics,
			 string scalar atmeans,
			 string scalar lnps,
			 string scalar lnexps,
			 real   scalar ndemo,
			 string scalar demos,
			 string scalar stderrs,
		         string scalar stderrmat,
			 string scalar elass)
{
	real scalar	i
	string scalar	s
	real vector	lnexp
	real matrix	lnp, elas, shares, demo, semat
	
	if (ndemo > 0) {
		if (atmeans == "") {
			st_view(demo=., ., demos, touses)
		}
		else {
			demo = mean(st_data(., demos, touses))
		}
	}
	
	if (atmeans == "") {
		st_view(lnp=.,    ., lnps,                touses)
		st_view(lnexp=.,  ., lnexps,              touses)
		st_view(shares=., ., st_global("e(lhs)"), touses)
		elas = J(rows(shares), (cols(shares)^2), .)
	}
	else {
		shares  = mean(st_data(., st_global("e(lhs)"), touses))
		lnp     = mean(st_data(., lnps, touses))
		lnexp   = mean(st_data(., lnexps, touses))
		elas    = J(1, (cols(shares)^2), .)
	}
	
	_quaids__uncompelas_wrk(st_matrix("e(best)"), quadratics,
			        ndemo, shares, lnp, lnexp, demo, elas)
	
	if (stderrs != "") {
		_quaids__uncompelas_stderr(st_matrix("e(best)"), quadratics,
			ndemo, shares, lnp, lnexp, demo, semat)
		st_matrix(stderrmat, rowshape(semat, cols(lnp)))
	}
	
	if (atmeans != "") {
		st_matrix(elass, rowshape(elas, cols(lnp)))
	}
	else {
		s = tokens(elass)
		for(i=1; i<=cols(elas); ++i)		      
			st_store(., s[i], touses, elas[.,i])
	}
}

void _quaids__uncompelas_stderr(real vector   params,
			        string scalar quadratics,
			        real scalar   ndemo,
			        real matrix   shares,
			        real matrix   lnp,
			        real vector   lnexp,
			        real matrix   demo,
			        real matrix   semat)
{
	real matrix  J, V
	transmorphic D
	
	D = deriv_init()
	deriv_init_evaluator(D, &_quaids__uncompelas_wrk())
	deriv_init_evaluatortype(D, "t")
	deriv_init_params(D, params)
	deriv_init_argument(D, 1, quadratics)
	deriv_init_argument(D, 2, ndemo)
	deriv_init_argument(D, 3, shares)
	deriv_init_argument(D, 4, lnp)
	deriv_init_argument(D, 5, lnexp)
	deriv_init_argument(D, 6, demo)
	J = deriv(D, 1)
	V = J*st_matrix("e(Vest)")*J'
	semat = diagonal(cholesky(diag(diagonal(V))))'

}

void _quaids__uncompelas_wrk(real vector   params,
			     string scalar quadratics,
			     real scalar   ndemo,
			     real matrix   shares,
			     real matrix   lnp,
			     real vector   lnexp,
			     real matrix   demo,
			     real matrix   elas)
{

	real scalar 	i, j, obs, ng, index
	real vector	bofp, lnpindex, cofp, mbar, betanz
	real vector	alpha, beta, lambda, rho
	real matrix	gamma, eta

	ng = st_numscalar("e(ngoods)")
		/*
			This is for deriv(), which resizes elas
		*/
	if (cols(elas) == 1)	elas = J(1, ng^2, .)

	_quaids__getcoefs_wrk(params, ng, 
		      	      quadratics, ndemo,
		      	      alpha, beta, gamma, lambda, eta, rho)

	if (quadratics == "") {
		bofp = exp(lnp*beta')
		lnpindex = lnp*alpha' :+ st_numscalar("e(anot)")
		for(i=1; i<=rows(lnpindex); ++i) {
			lnpindex[i] = lnpindex[i] + 0.5*lnp[i,.]*gamma*lnp[i,.]'
		}
	}
	else {
		bofp = J(rows(lnp), 1, 1)	// 1, so now div0 problem
		lnpindex = J(rows(lnp), 1, 0)
		lambda = J(rows(beta), cols(beta), 0)
	}
	if (ndemo > 0) {
		cofp = J(rows(lnp), 1, 0)
		for(i=1; i<=rows(lnp); ++i) {
			cofp[i] = lnp[i,.]*(eta'*demo[i,.]')
		}
		cofp = exp(cofp)
		mbar = 1 :+ demo*rho'
		betanz = J(rows(lnp), 1, beta)
		for(i=1; i<=rows(lnp); ++i) {
			betanz[i,.] = betanz[i,.] + demo[i,.]*eta
		}
	}
	else {           
		mbar = J(rows(lnp), 1, 1)
		cofp = mbar
		betanz = J(rows(lnp), 1, beta)
	}
	for(obs=1; obs<=rows(elas); ++obs) {
		for(i=1; i<=ng; ++i) {
			for(j=1; j<=ng; ++j) {
				index = (i-1)*ng + j
elas[obs,index] = 
	(i==j ? -1 : 0) + 
	1/shares[obs,i]*(gamma[i,j] - 
		(betanz[obs, i] + 2*lambda[i]/bofp[obs]/cofp[obs]*
			(lnexp[obs] - ln(mbar[obs]) - lnpindex[obs]))*
			(alpha[j] + gamma[j,.]*lnp[obs,.]') -
		(betanz[obs,j]*lambda[i]/bofp[obs]/cofp[obs]*
			(lnexp[obs] - ln(mbar[obs]) - lnpindex[obs])^2))
			}
		}
	}
}


void _quaids__compelas(string scalar touses,
		       string scalar quadratics,
		       string scalar atmeans,
		       string scalar lnps,
		       string scalar lnexps,
		       real   scalar ndemo,
		       string scalar demos,
		       string scalar stderrs,
		       string scalar stderrmat,
		       string scalar elass)
{
	real scalar	i
	string scalar	s
	real vector	lnexp
	real matrix	lnp, elas, shares, demo, semat
	
	if (ndemo > 0) {
		if (atmeans == "") {
			st_view(demo=., ., demos, touses)
		}
		else {
			demo = mean(st_data(., demos, touses))
		}
	}
	
	if (atmeans == "") {
		st_view(lnp=.,    ., lnps,                touses)
		st_view(lnexp=.,  ., lnexps,              touses)
		st_view(shares=., ., st_global("e(lhs)"), touses)
		elas = J(rows(shares), (cols(shares)^2), .)
	}
	else {
		shares  = mean(st_data(., st_global("e(lhs)"), touses))
		lnp     = mean(st_data(., lnps, touses))
		lnexp   = mean(st_data(., lnexps, touses))
		elas    = J(1, (cols(shares)^2), .)
	}
	_quaids__compelas_wrk(st_matrix("e(best)"), quadratics, 
			      ndemo, shares, lnp, lnexp, demo, elas)
	if (stderrs != "") {
		_quaids__compelas_stderr(st_matrix("e(best)"), quadratics,
			ndemo, shares, lnp, lnexp, demo, semat)
		st_matrix(stderrmat, rowshape(semat, cols(lnp)))
	}
	
	if (atmeans != "") {
		st_matrix(elass, rowshape(elas,cols(lnp)))
	}
	else {
		s = tokens(elass)
		for(i=1; i<=cols(elas); ++i)		      
			st_store(., s[i], touses, elas[.,i])
	}
}

void _quaids__compelas_stderr(real vector   params,
			        string scalar quadratics,
			        real scalar   ndemo,
			        real matrix   shares,
			        real matrix   lnp,
			        real vector   lnexp,
			        real matrix   demo,
			        real matrix   semat)
{
	real matrix  J, V
	transmorphic D
	
	D = deriv_init()
	deriv_init_evaluator(D, &_quaids__compelas_wrk())
	deriv_init_evaluatortype(D, "t")
	deriv_init_params(D, params)
	deriv_init_argument(D, 1, quadratics)
	deriv_init_argument(D, 2, ndemo)
	deriv_init_argument(D, 3, shares)
	deriv_init_argument(D, 4, lnp)
	deriv_init_argument(D, 5, lnexp)
	deriv_init_argument(D, 6, demo)
	J = deriv(D, 1)
	V = J*st_matrix("e(Vest)")*J'
	semat = diagonal(cholesky(diag(diagonal(V))))'

}


void _quaids__compelas_wrk(real vector   params,
			     string scalar quadratics,
			     real scalar   ndemo,
			     real matrix   shares,
			     real matrix   lnp,
			     real vector   lnexp,
			     real matrix   demo,
			     real matrix   elas)
{
	real scalar	i, j, index, ng
	real matrix 	ee, up
	
	ng = cols(lnp)

	ee   = J(rows(lnp), cols(lnp), .)
	up   = J(rows(lnp), cols(lnp)^2, .)
	elas = J(rows(lnp), cols(lnp)^2, .)
	
	_quaids__expelas_wrk(params, quadratics, ndemo, shares, lnp,
			     lnexp, demo, ee)
	_quaids__uncompelas_wrk(params, quadratics, ndemo, shares, lnp,
			     lnexp, demo, up)

	for(i=1; i<=ng; ++i) {
		for(j=1; j<=ng; ++j) {
			index = (i-1)*ng + j
			elas[.,index] = up[.,index] :+ ee[.,i]:*shares[.,j]
		}
	}
}



void _quaids__fullvector(string scalar ins,
			real scalar neqn,
			string scalar quadratics,
			real scalar ndemo,
			string scalar outs)
{

	real vector	in
	real vector	alpha, beta, lambda, rho
	real matrix	gamma, eta
	
	in = st_matrix(ins)
	_quaids__getcoefs_wrk(in, neqn, quadratics, ndemo,
		alpha, beta, gamma, lambda, eta, rho)
	if (quadratics == "" & ndemo > 0) {
		st_matrix(outs, (alpha, beta, (vech(gamma)'), 
			lambda, (vec(eta')'), rho))
	}
	else if (quadratics == "") {
		st_matrix(outs, (alpha, beta, (vech(gamma)'), lambda))
	}
	else if (ndemo > 0) {
		st_matrix(outs, (alpha, beta, (vech(gamma)'), 
			(vec(eta')'), rho))
	}
	else {
		st_matrix(outs, (alpha, beta, (vech(gamma)')))
	}
	
}

void _quaids__getcoefs(string scalar ins,
		       real   scalar neqn,
		       string scalar quadratics,
		       real   scalar ndemo,
		       string scalar alphas,
		       string scalar betas,
		       string scalar gammas,
		       string scalar lambdas,
		       string scalar etas,
		       string scalar rhos)
{
	real scalar	np
	real vector	in
	real vector	alpha, beta, lambda, rho
	real matrix	gamma, eta

	in = st_matrix(ins)

	if (quadratics == "") {
		np = 3*(neqn-1) + neqn*(neqn-1)/2
	}
	else {
		np = 2*(neqn-1) + neqn*(neqn-1)/2
	}
	if (ndemo > 0) {
		np = np + ndemo*(neqn-1) + ndemo
	}
	if (cols(in) != np) {
		errprintf("_quaids__getcoefs received invalid vector\n")
		exit(9999)
	}
	
	_quaids__getcoefs_wrk(in, neqn, quadratics, ndemo, 
				alpha, beta, gamma, lambda, eta, rho)
	
	st_matrix(alphas, alpha)
	st_matrix(betas, beta)
	st_matrix(gammas, gamma)
	if (quadratics == "") {
		st_matrix(lambdas, lambda)
	}
	if (ndemo > 0) {
		st_matrix(etas, eta)
		st_matrix(rhos, rho)
	}
	
}

void _quaids__getcoefs_wrk(real rowvector 	in,
			   real scalar		neqn,
			   string scalar	quadratics,
			   real scalar		ndemo,
			   real rowvector	alpha,
			   real rowvector	beta,
			   real matrix		gamma,
			   real rowvector	lambda,
			   real matrix		eta,
			   real rowvector	rho)
{

	real scalar	col, i, j

	col = 1
	alpha = J(1, neqn, 1)		// NB initialize to 1
	for(i=1; i<neqn; ++i) {
		alpha[i] = in[col]
		alpha[neqn] = alpha[neqn] - alpha[i]
		++col
	}
	
	beta = J(1, neqn, 0)		// NB initialize to 0
	for(i=1; i<neqn; ++i) {
		beta[i] = in[col]
		beta[neqn] = beta[neqn] - beta[i]
		++col
	}
	
	gamma = J(neqn, neqn, 0)	// NB initialize to 0
		// j is in outer loop, so that what we are doing corresponds
		// to standard vech() and invvech() functions.
	for(j=1; j<neqn; ++j) {
		for(i=j; i<neqn; ++i) {
			gamma[i, j] = in[col]
			if (j != i) gamma[j, i] = in[col]
			++col
		}
	}
	for(i=1; i<neqn; ++i) {
		for(j=1; j<neqn; ++j) {
			gamma[i, neqn] = gamma[i, neqn] - gamma[i,j]
		}
		gamma[neqn, i] = gamma[i, neqn]
	}
	for(i=1; i<neqn; ++i) {
		gamma[neqn,neqn] = gamma[neqn,neqn]-gamma[i,neqn]
	}
	if (quadratics == "") {
		lambda = J(1, neqn, 0)		// NB initialize to zero
		for(i=1; i<neqn; ++i) {
			lambda[i] = in[col]
			lambda[neqn] = lambda[neqn] - lambda[i]
			++col
		}
	}
	if (ndemo > 0) {
		eta = J(ndemo, neqn, 0)
		for(i=1; i<=ndemo; ++i) {
			for(j=1; j<neqn; ++j) {
				eta[i,j] = in[col]
				eta[i,neqn] = eta[i,neqn] - eta[i,j]
				++col
			}
		}
		rho = J(1, ndemo, 0)
		for(i=1; i<=ndemo; ++i) {
			rho[i] = in[col]
			++col
		}
	}
	
}


void _quaids__expshrs(string scalar shrs,			///
		      string scalar touses,			///
		      string scalar lnexps,			///
		      string scalar lnps,			///
		      real scalar neqn,				///
		      real scalar ndemo,			///
		      real scalar a0,				///
		      string scalar quadratics,			///
		      string scalar ats,			///
		      string scalar demos)
{
	real scalar i
	real vector at, alpha, beta, lambda, rho
	real vector lnexp, lnpindex, bofp, cofp, mbar
	real matrix gamma, eta
	real matrix lnp, shr, demo

	st_view(shr=.,   .,    shrs, touses)
	st_view(lnp=.,   .,    lnps, touses)
	st_view(lnexp=., .,  lnexps, touses)
	st_view(demo=.,   .,  demos, touses)
	
	at = st_matrix(ats)

	if (cols(shr) != (neqn-1)) {
		exit(9998)
	}
	
	// Get all the parameters
	_quaids__getcoefs_wrk(at, neqn, quadratics, ndemo,
		alpha, beta, gamma, lambda, eta, rho)

	// First get the price index
	lnpindex = a0 :+ lnp*alpha'
	for(i=1; i<=rows(lnpindex); ++i) {
		lnpindex[i] = lnpindex[i] + 0.5*lnp[i,.]*gamma*lnp[i,.]'
	}
	
	if (ndemo > 0) {
		cofp = J(rows(lnp), 1, 0)
		for(i=1; i<=rows(lnp); ++i) {
			cofp[i] = lnp[i,.]*(eta'*demo[i,.]')
		}
		cofp = exp(cofp)
		mbar = 1 :+ demo*rho'
	}
	else {
		cofp = J(rows(lnp), 1, 1)
		mbar = J(rows(lnp), 1, 1)
	}
	if (quadratics == "") {
		// The b(p) term
		bofp = exp(lnp*beta')
	}
	else {
		bofp = J(rows(lnp), 1, 1)
	}	
	for(i=1; i<neqn; ++i) {
		shr[.,i] = alpha[i] :+ lnp*gamma[i,.]'
		if (ndemo > 0) {
			shr[., i] = shr[., i] + 
				(J(rows(lnp), 1, beta[i]) + demo*eta[.,i]):*
				(lnexp - lnpindex - ln(mbar))
		}
		else {
			shr[., i] = shr[., i] + beta[i]*(lnexp - lnpindex)

		}
		if (quadratics == "") {
			shr[., i] = shr[., i] + lambda[i]:/(bofp:*cofp):*(
				(lnexp - lnpindex - ln(mbar)):^2)
		}
	}

}

void _quaids__predshrs(string scalar shrs,			///
		       string scalar touses,			///
		       string scalar lnexps,			///
		       string scalar lnps,			///
		       real scalar neqn,			///
		       real scalar ndemo,			///
		       real scalar a0,				///
		       string scalar quadratics,		///
		       string scalar demos)
{
	real scalar i
	real vector alpha, beta, lambda, rho
	real vector lnexp, lnpindex, bofp, cofp, mbar
	real matrix gamma, eta
	real matrix lnp, shr, demo

	st_view(shr=.,   .,    shrs, touses)
	st_view(lnp=.,   .,    lnps, touses)
	st_view(lnexp=., .,  lnexps, touses)
	st_view(demo=.,   .,  demos, touses)
	
	alpha  = st_matrix("e(alpha)")
	beta   = st_matrix("e(beta)")
	gamma  = st_matrix("e(gamma)")
	lambda = st_matrix("e(lambda)")
	rho    = st_matrix("e(rho)")
	eta    = st_matrix("e(eta)")

	if (cols(shr) != neqn) {
		exit(9998)
	}
	
	// First get the price index
	lnpindex = a0 :+ lnp*alpha'
	for(i=1; i<=rows(lnpindex); ++i) {
		lnpindex[i] = lnpindex[i] + 0.5*lnp[i,.]*gamma*lnp[i,.]'
	}
	
	if (ndemo > 0) {
		cofp = J(rows(lnp), 1, 0)
		for(i=1; i<=rows(lnp); ++i) {
			cofp[i] = lnp[i,.]*(eta'*demo[i,.]')
		}
		cofp = exp(cofp)
		mbar = 1 :+ demo*rho'
	}
	else {
		cofp = J(rows(lnp), 1, 1)
		mbar = J(rows(lnp), 1, 1)
	}
	if (quadratics == "") {
		// The b(p) term
		bofp = exp(lnp*beta')
	}
	else {
		bofp = J(rows(lnp), 1, 1)
	}	
	for(i=1; i<=neqn; ++i) {
		shr[.,i] = alpha[i] :+ lnp*gamma[i,.]'
		if (ndemo > 0) {
			shr[., i] = shr[., i] + 
				(J(rows(lnp), 1, beta[i]) + demo*eta[.,i]):*
				(lnexp - lnpindex - ln(mbar))
		}
		else {
			shr[., i] = shr[., i] + beta[i]*(lnexp - lnpindex)

		}
		if (quadratics == "") {
			shr[., i] = shr[., i] + lambda[i]:/(bofp:*cofp):*(
				(lnexp - lnpindex - ln(mbar)):^2)
		}
	}

}


void _quaids__sharebar(string scalar outs, touses)
{

	st_matrix(outs, mean(st_data(., st_global("e(lhs)"), touses)))

}

/*
	This program assumes the Gamma parameters are stored as vech(Gamma) 

	Derivatives for the Gamma parameters.

	Let N = number of goods

	Case 1: We have Gamma_{i,j} for i,j < N.  The derivative is
		simply unity
		
	Case 2: We have Gamma_{i,j} for i==N and j < N.  In this case
		
			Gamma_{N,j} = 0 - Gamma_{1,j} - Gamma_{2,j} - ...
		
		So the required derivative is minus one.
		
	Case 3: We are at Gamma_{N,N}.
	
			Gamma_{N,N} = 0 - Gamma_{1,N} - Gamma_{2,N} - ...
		(Slutsky symm.)	    = 0 - Gamma_{N,1} - Gamma_{N,2} - ...
				    = 0 - (0 - Sum_{j=1}^{j=N-1} Gamma_{1,j})
				    	- (0 - Sum_{j=1}^{j=N-1} Gamma_{2,j})
				    	- ...                           ^
				    	                    Call that i |
				    	
		So the required derivative is one if i==j and two if i!=j.
		
*/

void _quaids__delta(real scalar ng, 
		    string scalar quadratics,
		    real scalar ndemo,
		    string scalar Dmats)
{
	real scalar	i, j, ic, jc, m, n
	real scalar	ngm1
	real matrix	block, Delta, Gamma

	ngm1 = ng - 1
	block = I(ngm1) \ J(1, ngm1, -1)
	
	Delta = block				// alpha
	Delta = blockdiag(Delta, block)		// beta

	// Gamma
	Gamma = J((ng+1)*ng/2, (ngm1+1)*ngm1/2, 0)
	m = 1
	for(j=1; j<=ng; ++j) {
		for(i=j; i<=ng; ++i) {
			n = 1
			for(jc=1; jc<ng; ++jc) {
				for(ic=jc; ic<ng; ++ic) {
					if (j < ng & i < ng) {     /* Case 1 */
						if (jc==j && ic==i) 
							Gamma[m,n] = 1
					}
					else if (j < ng & i==ng) { /* Case 2 */
						if (jc==j || ic==j)
							Gamma[m,n]=-1
					}
					else if (j==ng & i==ng) {  /* Case 3 */
						Gamma[m,n] = Gamma[m,n]+1
						if (ic != jc) 
							Gamma[m,n] =
								Gamma[m,n] + 1
					}
					++n
				}
			}
			++m
		}
	}
	Delta = blockdiag(Delta, Gamma)

	if (quadratics == "") {
		Delta = blockdiag(Delta, block)		// lambda	
	}
	
	if (ndemo > 0) {
		for(i=1; i<= ndemo; ++i) Delta = blockdiag(Delta, block)
		Delta = blockdiag(Delta, I(ndemo))
	}

	st_matrix(Dmats, Delta)
	
}
	
end



exit
