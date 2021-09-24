{smcl}
{* *! version 1.1.0  24jul2013}{...}
{cmd:help quaidsce}{right: ({browse "http://www.stata-journal.com/article.html?article=up0041":SJ13-3: st0268_1})}
{right:also see:  {help quaidsce postestimation}}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{cmd:quaidsce} {hline 2}}Estimate almost-ideal demand systems{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{opt quaidsce} {it:varlist_expshares} {ifin}{cmd:,} {opt anot(#)}
   {c -(}{opt pr:ices(varlist_prices)}|{opt lnpr:ices(varlist_lnprices)}{c )-} 
   {c -(}{opt exp:enditure(varlist_exp)}|{opt lnexp:enditure(varlist_lnexp)}{c )-}
   [{it:{help quaidsce##options:options}}]

{pstd}
where {it:varlist_expshares} is the list of expenditure share
variables.  You must specify all the expenditure share variables.  Do
not omit one of the shares to avoid a singular covariance matrix;
{cmd:quaidsce} does that automatically.

{synoptset 30 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{p2coldent :# {opt anot(#)}}value to use for alpha_0 parameter{p_end}
{p2coldent :* {opt pr:ices(varlist_prices)}}list of price variables{p_end}
{p2coldent :* {opt lnpr:ices(varlist_lnprices)}}list of variables containing natural logarithms of prices{p_end}
{p2coldent :+ {opt exp:enditure(varlist_exp)}}variable representing total expenditure{p_end}
{p2coldent :+ {opt lnexp:enditure(varlist_lnexp)}}variable representing the natural logarithm of total expenditure{p_end}
{synopt :{opt demo:graphics(varlist_demo)}}demographic variables to include{p_end}
{synopt :{opt noqu:adratic}}do not include quadratic expenditure term{p_end}
{synopt :{opt nolo:g}}suppress the iteration log{p_end}
{synopt :{cmd:vce(}{it:{help quaidsce##vcetype:vcetype}}{cmd:)}}{it:vcetype} may be {opt gnr}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}# {opt anot(#)} is required.{p_end}
{p 4 6 2}* You must specify {opt prices()} or {opt lnprices()} but not both.{p_end}
{p 4 6 2}+ You must specify {opt expenditure()} or {opt lnexpenditure()} but not both.{p_end}


{title:Description}

{pstd}
{cmd:quaidsce} estimates the parameters of Deaton and Muellbauer's
(1980) almost-ideal demand system (AIDS) and Banks, Blundell, and
Lewbel's (1997) quadratic AIDS model.  Demographic variables can be
included in the model based on Ray's (1983) expenditure function scaling
technique.  See Poi (2012) for the formulas used.


{title:Options}

{phang}
{opt anot(#)} specifies the value of the alpha_0 parameter that
appears in the price index.  {opt anot()} is required.

{phang}
{opt prices(varlist_prices)} specifies the list of price
variables.  You must specify the price variables in the same order that
you specify the expenditure share variables {it:varlist_expshares}.  You
must specify {opt prices()} or {opt lnprices()} but not both.

{phang}
{opt lnprices(varlist_lnprices)} specifies the list of variables
containing the natural logarithms of the price variables.  You must
specify this list in the same order that you specify the expenditure
share variables {it:varlist_expshares}.  You must specify {opt prices()}
or {opt lnprices()} but not both.

{phang}
{opt expenditure(varlist_exp)} specifies the variable
representing total expenditure on all the goods in the demand system.
You must specify {opt expenditure()} or {opt lnexpenditure()} but not
both.

{phang}
{opt lnexpenditure(varlist_lnexp)} specifies the variable
representing the natural logarithm of the total expenditure on all
the goods in the demand system.  You must specify {opt expenditure()} or
{opt lnexpenditure()} but not both.

{phang}
{opt demographics(varlist_demo)} requests that the variables
{it:varlist_demo} be included in the demand system based on the scaling
technique introduced by Ray (1983).

{phang}
{opt noquadratic} requests that the quadratic income term not be
included in the expenditure share equations.  Specifying this option
requests Deaton and Muellbauer's (1980) AIDS model.  The default is to
include the quadratic income term, yielding Banks, Blundell, and
Lewbel's (1997) quadratic AIDS model.

{phang}
{opt nolog} requests that the iteration log be suppressed.

{marker vcetype}{...}
{phang}
{opt vce(vcetype)} specifies the type of standard error reported,
which includes types that are derived from asymptotic theory, that are
robust to some kinds of misspecification, that allow for intragroup
correlation, and that use bootstrap or jackknife methods. This option
works just as it does for {cmd:nlsur}; see {manhelp nlsur R}.

{pmore}{cmd:vce(gnr)}, the default, uses the conventionally derived
variance estimator for nonlinear models fit by using Gauss-Newton
regression.

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.


{title:Examples}

{pstd}
Fit a 5-good quadratic AIDS model with alpha_0 = 10:{p_end}
{phang2}{cmd:. quaidsce w1-w5, anot(10) prices(p1-p5) expenditure(totalexp)}
{p_end}

{pstd}
Same as above, but including household-size variable {opt hhsize}:{p_end}
{phang2}{cmd:. quaidsce w1-w5, anot(10) prices(p1-p5) expenditure(totalexp)}
            {cmd:demographics(hhsize)}{p_end}

{pstd} Fit a 4-good AIDS model using a dataset for which the price and
expenditure variables are already in natural logarithms with alpha_0 =
5:{p_end}
{phang2}{cmd:. quaidsce w1-w4, anot(5) lnprices(lnp1-lnp4) lnexpenditure(lnexp)}
             {cmd:noquadratic}{p_end}


{title:Saved results}

{pstd}
{cmd:quaidsce} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 15 17 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(ndemos)}}number of demographic variables{p_end}
{synopt:{cmd:e(anot)}}value of alpha_0{p_end}
{synopt:{cmd:e(ngoods)}}number of goods{p_end}

{p2col 5 15 17 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:quaidsce}{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used in label Std. Err.{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(estat_cmd)}}program used to implement {cmd:estat}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(demographics)}}demographic variables included{p_end}
{synopt:{cmd:e(lhs)}}expenditure share variables{p_end}
{synopt:{cmd:e(expenditure)}}expenditure variable{p_end}
{synopt:{cmd:e(lnexpenditure)}}log-expenditure variable{p_end}
{synopt:{cmd:e(prices)}}price variables{p_end}
{synopt:{cmd:e(lnprices)}}log-price variables{p_end}
{synopt:{cmd:e(quadratic)}}{cmd:noquadratic}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{p2col 5 15 17 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(best)}}coefficient vector of estimated parameters{p_end}
{synopt:{cmd:e(Vest)}}variance-covariance matrix of estimated parameters{p_end}
{synopt:{cmd:e(alpha)}}alpha vector{p_end}
{synopt:{cmd:e(beta)}}beta vector{p_end}
{synopt:{cmd:e(gamma)}}gamma matrix{p_end}
{synopt:{cmd:e(lambda)}}lambda vector{p_end}
{synopt:{cmd:e(eta)}}eta matrix{p_end}
{synopt:{cmd:e(rho)}}rho vector{p_end}

{p2col 5 15 17 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:References}

{phang}
Banks, J., R. Blundell, and A. Lewbel.  1997.  Quadratic Engle curves
and consumer demand. {it:Review of Economics and Statistics} 79:
527-539.

{phang}
Deaton, A. S., and J. Muellbauer.  1980.  An almost ideal demand system.
{it:American Economic Review} 70: 312-326.

{phang}
Poi, B. P.  2012.  Easy demand system estimation with quaids. 
{it:Stata Journal} 12: 433-446.

{phang}
Ray, R.  1983.  Measuring the costs of children: An alternative approach.
{it:Journal of Public Economics} 22: 89-102.


{title:Author}

{pstd}Brian P. Poi{p_end}
{pstd}StataCorp LP{p_end}
{pstd}College Station, TX{p_end}
{pstd}bpoi@stata.com{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 13, number 3: {browse "http://www.stata-journal.com/article.html?article=up0041":st0268_1},{break}
                    {it:Stata Journal}, volume 12, number 3: {browse "http://www.stata-journal.com/article.html?article=st0268":st0268}

{p 7 14 2}Help:  {help quaidsce postestimation}{p_end}
