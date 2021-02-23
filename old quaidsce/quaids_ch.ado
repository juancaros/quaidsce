*************CALCULATING ELASTICITIES WITH IC/BOOTSTRAP***********
*QUAIDS MODEL FOR EPF VII CHILE 2011-2012
*Carlos Caro, 2016

cap program drop quaids_ch
program define quaids_ch, rclass
	version 14.0
	syntax varlist(min=35 max=35)
	tokenize `varlist'
args w1 w2 w3 w4 w5 w6 w7 w8 w9 lnp1 lnp2 lnp3 lnp4 lnp5 lnp6 lnp7 lnp8 lnp9 lnexp ///
x1 x2 x3 x4 x5 x6 x7 QME1 QME2 QME3 QME4 QME5 QME6 QME7 QME8 QME9

tempvar elnexp
qui reg `lnexp' `x1' `x2' `x3' `x4' `x5' `x6' `x7' i.`x5'#`x4'
predict `elnexp', r

tempvar d z1 z2 z3 z4 z5 z6 z7 z8 z9
tempvar cdf1 cdf2 cdf3 cdf4 cdf5 cdf6 cdf7 cdf8 cdf9 pdf1 pdf2 pdf3 pdf4 pdf5 pdf6 pdf7 pdf8 pdf9
gen `d'=.  
forval y = 1/9 {
	replace `d'=1 if `w`y''>0 
	replace `d'=0 if `w`y''==0 
	quietly probit `d' `lnp1' `lnp2' `lnp3' `lnp4' `lnp5' `lnp6' `lnp7' `lnp8' `lnp9' `x1' `x2' `x3' `x4' `x5' `x6'
	quietly predict `z`y''
	gen `pdf`y''= normalden(`z`y'')
	gen `cdf`y''= normal(`z`y'')
}

nlsur quaidsNN9c @ `w1' `w2' `w3' `w4' `w5' `w6' `w7' `w8' `w9' `lnp1' `lnp2' `lnp3' ///
`lnp4' `lnp5' `lnp6' `lnp7' `lnp8' `lnp9' `lnexp' `x1' `x2' `x3' `elnexp' /// 
`pdf1' `pdf2' `pdf3' `pdf4' `pdf5' `pdf6' `pdf7' `pdf8' `pdf9' ///
`cdf1' `cdf2' `cdf3' `cdf4' `cdf5' `cdf6' `cdf7' `cdf8' `cdf9', ///
nls neq(9) parameters(a1 a2 a3 a4 a5 a6 a7 a8 a9 b1 b2 b3 b4 b5 b6 b7 b8 b9 ///
g11 g12 g13 g14 g15 g16 g17 g18 g22 g23 g24 g25 g26 g27 g28 g33 g34 g35 g36 g37 g38 ///
g44 g45 g46 g47 g48 g55 g56 g57 g58 g66 g67 g68 g77 g78 g88 l1 l2 l3 l4 l5 l6 l7 l8 l9 ///
r11 r21 r31 r41 r51 r61 r71 r81 r12 r22 r32 r42 r52 r62 r72 r82 r13 r23 r33 r43 r53 r63 r73 r83 /// 
r14 r24 r34 r44 r54 r64 r74 r84 d1 d2 d3 d4 d5 d6 d7 d8 d9)

tempname b nu e n
matrix b=e(b)

tempname a1 a2 a3 a4 a5 a6 a7 a8 a9
scalar `a1' = b[1,1] 
scalar `a2' = b[1,2] 
scalar `a3' = b[1,3] 
scalar `a4' = b[1,4] 
scalar `a5' = b[1,5] 
scalar `a6' = b[1,6]
scalar `a7' = b[1,7] 
scalar `a8' = b[1,8] 
scalar `a9' = b[1,9]

tempname b1 b2 b3 b4 b5 b6 b7 b8 b9
scalar `b1' = b[1,10]
scalar `b2' = b[1,11]
scalar `b3' = b[1,12]
scalar `b4' = b[1,13]
scalar `b5' = b[1,14]
scalar `b6' = b[1,15]
scalar `b7' = b[1,16]
scalar `b8' = b[1,17]
scalar `b9' = b[1,18] 

tempname g11 g12 g13 g14 g15 g16 g17 g18 g19
tempname g21 g22 g23 g24 g25 g26 g27 g28 g29
tempname g31 g32 g33 g34 g35 g36 g37 g38 g39
tempname g41 g42 g43 g44 g45 g46 g47 g48 g49
tempname g51 g52 g53 g54 g55 g56 g57 g58 g59
tempname g61 g62 g63 g64 g65 g66 g67 g68 g69
tempname g71 g72 g73 g74 g75 g76 g77 g78 g79 
tempname g81 g82 g83 g84 g85 g86 g87 g88 g89
tempname g91 g92 g93 g94 g95 g96 g97 g98 g99

scalar `g11' = b[1,19]
scalar `g12' = b[1,20]
scalar `g13' = b[1,21]
scalar `g14' = b[1,22]
scalar `g15' = b[1,23]
scalar `g16' = b[1,24]
scalar `g17' = b[1,25]
scalar `g18' = b[1,26]
scalar `g19' = - `g11' - `g12' - `g13' -`g14' - `g15' - `g16' -`g17' - `g18' 

scalar `g21' = `g12'
scalar `g22' = b[1,27]
scalar `g23' = b[1,28]
scalar `g24' = b[1,29]
scalar `g25' = b[1,30]
scalar `g26' = b[1,31]
scalar `g27' = b[1,32]
scalar `g28' = b[1,33]
scalar `g29' = - `g21' - `g22' - `g23' -`g24' - `g25' - `g26' -`g27' - `g28'

scalar `g31' = `g13'
scalar `g32' = `g23'
scalar `g33' = b[1,34]
scalar `g34' = b[1,35]
scalar `g35' = b[1,36]
scalar `g36' = b[1,37]
scalar `g37' = b[1,38]
scalar `g38' = b[1,39]
scalar `g39' = - `g31' - `g32' - `g33' -`g34' - `g35' - `g36' -`g37' - `g38'

scalar `g41' = `g14'
scalar `g42' = `g24'
scalar `g43' = `g34'
scalar `g44' = b[1,40]
scalar `g45' = b[1,41]
scalar `g46' = b[1,42]
scalar `g47' = b[1,43]
scalar `g48' = b[1,44]
scalar `g49' = - `g41' - `g42' - `g43' -`g44' - `g45' - `g46' -`g47' - `g48'

scalar `g51' = `g15'
scalar `g52' = `g25'
scalar `g53' = `g35'
scalar `g54' = `g45'
scalar `g55' = b[1,45]
scalar `g56' = b[1,46]
scalar `g57' = b[1,47]
scalar `g58' = b[1,48]
scalar `g59' = - `g51' - `g52' - `g53' -`g54' - `g55' - `g56' -`g57' - `g58'

scalar `g61' = `g16'
scalar `g62' = `g26'
scalar `g63' = `g36'
scalar `g64' = `g46'
scalar `g65' = `g56'
scalar `g66' = b[1,49]
scalar `g67' = b[1,50]
scalar `g68' = b[1,51]
scalar `g69' = - `g61' - `g62' - `g63' -`g64' - `g65' - `g66' -`g67' - `g68'

scalar `g71' = `g17'
scalar `g72' = `g27'
scalar `g73' = `g37'
scalar `g74' = `g47'
scalar `g75' = `g57'
scalar `g76' = `g67'
scalar `g77' = b[1,52]
scalar `g78' = b[1,53]
scalar `g79' = - `g71' - `g72' - `g73' -`g74' - `g75' - `g76' -`g77' - `g78'

scalar `g81' = `g18'
scalar `g82' = `g28'
scalar `g83' = `g38'
scalar `g84' = `g48'
scalar `g85' = `g58'
scalar `g86' = `g68'
scalar `g87' = `g78'
scalar `g88' = b[1,54]
scalar `g89' = - `g81' - `g82' - `g83' -`g84' - `g85' - `g86' -`g87' - `g88'

scalar `g91' = `g19'
scalar `g92' = `g29'
scalar `g93' = `g39'
scalar `g94' = `g49'
scalar `g95' = `g59'
scalar `g96' = `g69'
scalar `g97' = `g79'
scalar `g98' = `g89'
scalar `g99' = - `g91' - `g92' - `g93' -`g94' - `g95' - `g96' -`g97' - `g98'

tempname l1 l2 l3 l4 l5 l6 l7 l8 l9
scalar `l1' = b[1,55]
scalar `l2' = b[1,56]
scalar `l3' = b[1,57]
scalar `l4' = b[1,58]
scalar `l5' = b[1,59]
scalar `l6' = b[1,60]
scalar `l7' = b[1,61]
scalar `l8' = b[1,62]
scalar `l9' = b[1,63]

//household demographics
tempname r11 r12 r13 r14
tempname r21 r22 r23 r24
tempname r31 r32 r33 r34
tempname r41 r42 r43 r44
tempname r51 r52 r53 r54
tempname r61 r62 r63 r64
tempname r71 r72 r73 r74
tempname r81 r82 r83 r84 
tempname r91 r92 r93 r94

scalar `r11' = b[1,64]
scalar `r21' = b[1,65]
scalar `r31' = b[1,66]
scalar `r41' = b[1,67]
scalar `r51' = b[1,68]
scalar `r61' = b[1,69]
scalar `r71' = b[1,70]
scalar `r81' = b[1,71]
scalar `r91' = - `r11' - `r21' - `r31' -`r41' - `r51' - `r61' -`r71' - `r81'

scalar `r12' = b[1,72]
scalar `r22' = b[1,73]
scalar `r32' = b[1,74]
scalar `r42' = b[1,75]
scalar `r52' = b[1,76]
scalar `r62' = b[1,77]
scalar `r72' = b[1,78]
scalar `r82' = b[1,79]
scalar `r92' = - `r12' - `r22' - `r32' -`r42' - `r52' - `r62' -`r72' - `r82'

scalar `r13' = b[1,80]
scalar `r23' = b[1,81]
scalar `r33' = b[1,82]
scalar `r43' = b[1,83]
scalar `r53' = b[1,84]
scalar `r63' = b[1,85]
scalar `r73' = b[1,86]
scalar `r83' = b[1,87]
scalar `r93' = - `r13' - `r23' - `r33' -`r43' - `r53' - `r63' -`r73' - `r83'

scalar `r14' = b[1,88]
scalar `r24' = b[1,89]
scalar `r34' = b[1,90]
scalar `r44' = b[1,91]
scalar `r54' = b[1,92]
scalar `r64' = b[1,93]
scalar `r74' = b[1,94]
scalar `r84' = b[1,95]
scalar `r94' = - `r14' - `r24' - `r34' -`r44' - `r54' - `r64' -`r74' - `r84'

// pdf
tempname d1 d2 d3 d4 d5 d6 d7 d8 d9
scalar `d1' = b[1,96]
scalar `d2' = b[1,97]
scalar `d3' = b[1,98]
scalar `d4' = b[1,99]
scalar `d5' = b[1,100]
scalar `d6' = b[1,101]
scalar `d7' = b[1,102]
scalar `d8' = b[1,103]
scalar `d9' = b[1,104]

forv i=1(1)9 {
sum `w`i''
scalar w`i'mean=r(mean)
}

forv i=1(1)9 {
sum `lnp`i''
scalar lnp`i'mean=r(mean)
}

forv i=1(1)9 {
sum `cdf`i''
scalar `cdf`i''mean=r(mean)
}

sum `elnexp'
scalar elnexpmean=r(mean)
sum `lnexp'
scalar lnexpmean=r(mean)

sum `x1'
scalar x1mean=r(mean)
sum `x2'
scalar x2mean=r(mean)
sum `x3'
scalar x3mean=r(mean)

tempname dem1 dem2 dem3 dem4 dem5 dem6 dem7 dem8 dem9
tempname asum lp gsum ap bp 
tempname gsum21 gsum22 gsum23 gsum24 gsum25 gsum26 gsum27 gsum28 gsum29
tempname mu1 mu2 mu3 mu4 mu5 mu6 mu7 mu8 mu9
tempname mu11 mu12 mu13 mu14 mu15 mu16 mu17 mu18 mu19
tempname mu21 mu22 mu23 mu24 mu25 mu26 mu27 mu28 mu29
tempname mu31 mu32 mu33 mu34 mu35 mu36 mu37 mu38 mu39
tempname mu41 mu42 mu43 mu44 mu45 mu46 mu47 mu48 mu49
tempname mu51 mu52 mu53 mu54 mu55 mu56 mu57 mu58 mu59
tempname mu61 mu62 mu63 mu64 mu65 mu66 mu67 mu68 mu69
tempname mu71 mu72 mu73 mu74 mu75 mu76 mu77 mu78 mu79
tempname mu81 mu82 mu83 mu84 mu85 mu86 mu87 mu88 mu89
tempname mu91 mu92 mu93 mu94 mu95 mu96 mu97 mu98 mu99

* Price indexes
forv i=1(1)9 {
local dem`i'= `r`i'1'*x1mean+`r`i'2'*x2mean+`r`i'3'*x3mean+`r`i'4'*elnexpmean
}
local asum =(`a1'+`dem1')*lnp1mean
local lp =`l1'*lnp1mean
forv i=2(1)9 {
local asum = asum +(`a`i'' + `dem`i'')*lnp`i'mean
local lp = `lp' + `l`i''*lnp`i'mean
}
local gsum=0
forv i=1(1)9 {
forv j=1(1)9 {
local gsum = `gsum' + 0.5*`g`i'`j''*lnp`i'mean*lnp`j'mean
}
}
local ap = 5 + `asum' + `gsum'
local bp = `b1'*lnp1mean
forv i=2(1)9 {
local bp = `bp' + `b`i''*lnp`i'mean
}
local bp = exp(`bp')

*Reduced form (Mu)
forv i=1(1)9 {
local mu`i' = `b`i''+(2*`l`i''/`bp')*(lnexpmean-`ap')
}
forv j=1(1)9 {
local gsum2`j'=0
forv k=1(1)9 {
local gsum2`j' = `gsum2`j'' + `g`j'`k''*lnp`k'mean
}
}

************ELASTICITIES*******************

return matrix e=I(9)
forv i=1(1)9 {
forv j=1(1)9 {
local delta=cond(`i'==`j',1,0)
local mu`i'`j'=`g`i'`j'' - (`mu`i''*(`a`i'' + `dem`j'' + `gsum2`j''))-`l`i''*`b`j''/`bp'*(lnexpmean - `ap')^2
return matrix e[`i',`j']=`mu`i'`j''*cdf`i'mean/w`i'mean-`delta'
}
}

************NUTRIENT AVAILABILITY***********

qui {
foreach i=1(1)9 {
sum QME`i' ,d
scalar QME`x'm=r(p50)/30/x1mean
}
scalar t1=0
scalar t2=0
scalar t3=0.27
scalar t4=0.27
}

return matrix n=J(9,7,1)

matrix nu=(2949,527,399,1063,79,39,35\5182,567,17,5852,294,38,61\2951,9,5,3526,253,84,158\ ///
687,110,46,487,18,3,35\2449,470,13,1899,26,3,87\374,93,90,130,0,0,3\143,34,33,110,0,0,6\ ///
7,2,0,22,0,0,0\469,52,48,592,16,10,31)

forv i=1(1)9 {
forv j=1(1)9 {
return matrix n[`i',`j']= QME`i'm*(nu[`i',`j']*(t1*e[1,`j']+t2*e[2,`j']+t3*e[3,`j']+t4*e[4,`j']))
}
}

end
