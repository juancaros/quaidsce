{smcl}
{* *! version 1.1.0  Sep 2021}{...}
{right:also see:  {help quaidsce} {space 1}}
{hline}

{title:Title}

{p2colset 5 30 32 2}{...}
{p2col :{cmd:quaidsce postestimation} {hline 2}}Postestimation tools for quaidsce{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following postestimation commands are available after {cmd:quaidsce}: 

{synoptset 21}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{synopt :{helpb quaidsce postestimation##expelas:estat expenditure}}expenditure elasticities{p_end}
{synopt :{helpb quaidsce postestimation##comelas:estat compensated}}compensated price elasticities{p_end}
{synopt :{helpb quaidsce postestimation##uncelas:estat uncompensated}}uncompensated price elasticities{p_end}
INCLUDE help post_estimates
INCLUDE help post_lincom
{synopt :{helpb quaidsce postestimation##predict:predict}}predicted expenditure shares{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} 
{c -(}{it:stub}{cmd:*}}
{ifin}

{pstd}
These statistics are available both in and out of sample; type 
{cmd:predict ... if e(sample) ...} if wanted only for the estimation
sample.

{pstd}
You must specify a variable {it:stub} or {it:k} new variables, where {it:k}
is the number of goods in the demand system.


{marker expelas}{...}
{title:Syntax for estat expenditure}

{p 8 16 2}
{cmd:estat} {cmdab:exp:enditure}
{ifin}

{pstd}
The command computes the 1 x {it:k} vector of expenditure elasticities 
calculated when all the variables in the model are set to their sample means.
Standard errors are based on the delta method (as a wrapper from {cmd:margins}).

{marker comelas}{...}
{title:Syntax for estat compensated}

{p 8 16 2}
{cmd:estat} {cmdab:comp:ensated}
{ifin}

{pstd}
The command computes the {it:k} x {it:k} matrix of compensated price elasticities 
calculated when all the variables in the model are set to their sample means.
Standard errors are based on the delta method (as a wrapper from {cmd:margins}).

{marker uncelas}{...}
{title:Syntax for estat uncompensated}

{p 8 16 2}
{cmd:estat} {cmdab:uncomp:ensated}
{ifin}

{pstd}
The command computes the {it:k} x {it:k} matrix of uncompensated price elasticities 
calculated when all the variables in the model are set to their sample means.
Standard errors are based on the delta method (as a wrapper from {cmd:margins}).

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse food}{p_end}
{phang2}{cmd:. quaidsce w1-w4, anot(10) lnprices(lnp1-lnp4) expenditure(expfd)}{p_end}

{pstd}
Calculate observation-level predicted expenditure shares{p_end}
{phang2}{cmd:. predict what*}{p_end}

{pstd}
Calculate elasticities and standard errors at variable means{p_end}
{phang2}{cmd:. estat expenditure}{p_end}
{phang2}{cmd:. estat compensated}{p_end}
{phang2}{cmd:. estat uncompensated}{p_end}


{title:Stored results}

{pstd}
{cmd:estat expenditure} stores the following:{p_end}

{synoptset 18 tabbed}{...}
{synopt:{cmd:r(expelas)}}vector of expenditure elasticities{p_end}

{synopt:{cmd:r(sd)}}vector of standard errors of expenditure
elasticities{p_end}

{pstd}
{cmd:estat compensated} stores the following:{p_end}

{synoptset 18 tabbed}{...}
{synopt:{cmd:r(compelas)}}matrix of compensated price elasticities{p_end}

{phang2}
The element in row {it:i}, column {it:j} of {cmd:r(compelas)} contains the 
compensated price elasticity of good {it:i} with respect to the price of
good {it:j}.

{synopt:{cmd:r(sd)}}matrix of standard errors of compensated price
elasticities{p_end}

{pstd}
{cmd:estat uncompensated} stores the following:{p_end}

{synoptset 18 tabbed}{...}
{synopt:{cmd:r(uncompelas)}}matrix of uncompensated price elasticities{p_end}

{phang2}
The element in row {it:i}, column {it:j} of {cmd:r(uncompelas)} contains the 
uncompensated price elasticity of good {it:i} with respect to the price of good
{it:j}.

{synopt:{cmd:r(sd)}}matrix of standard errors of uncompensated price
elasticities{p_end}


{title:Corresponding author}

{pstd}Juan C. Caro{p_end}
{pstd}University of Luxembourg{p_end}
{pstd}juan.caro@uni.lu{p_end}


{title:Also see}

{p 7 14 2}Help:  {helpb quaidsce}{p_end}
