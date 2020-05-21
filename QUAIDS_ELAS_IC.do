*************CALCULATING ELASTICITIES WITH IC/BOOTSTRAP***********
*QUAIDS MODEL FOR EPF VII CHILE 2011-2012
*Carlos Caro, 2016

clear all
set maxvar 10000

use "C:\Users\jccaro\Desktop\EPFVII.dta", clear

use "C:\Users\jccaro\Desktop\DS_4.dta", clear
local par
set seed 1
*forval i=1(1)256 {
*local par `par' bb_`i'=r(bb[`i',1]) 
*}

rename cpi_excl p17
forval i=1(1)17 {
rename hh_q`i' QME`i'
gen w`i'=hh_shill`i'/total_exp
}
forval i=1(1)17 {
gen lnp`i' = log(p`i')
}

rename NEA x1
rename EDUE x2
rename ZONA x3
rename SEXO x4
rename SES x5
rename EDAD x6
rename login x7

rename EA x1
rename Shop_CollegeDegree x2
rename region x3
rename Shop_F x4
rename QL x5
rename Shop_F_under35 x6
gen login=log(ttl_income)
rename login x7
gen lnexp=log(total_exp)

egen u = rowmiss(w1 w2 w3 w4 w5 w6 w7 w8 w9 lnp1 lnp2 lnp3 lnp4 lnp5 lnp6 lnp7 lnp8 lnp9 /// 
lnexp x1 x2 x3 x4 x5 x6 x7)
drop if u==1

quaidsc w1 w2 w3 w4 w5 w6 w7 w8 w9 w10 w11 w12 w13 w14 w15 w16 w17 ///
lnp1 lnp2 lnp3 lnp4 lnp5 lnp6 lnp7 lnp8 lnp9 lnp10 lnp11 lnp12 lnp13 lnp14 lnp15 lnp16 lnp17 ///
lnexp x1 x2 x3 x4 x5 x6 x7 ///
QME1 QME2 QME3 QME4 QME5 QME6 QME7 QME8 QME9 QME10 QME11 QME12 QME13 QME14 QME15 QME16 QME17



quaidsc9 w1 w2 w3 w4 w5 w6 w7 w8 w9  ///
lnp1 lnp2 lnp3 lnp4 lnp5 lnp6 lnp7 lnp8 lnp9  ///
lnexp x1 x2 x3 x4 x5 x6 x7 ///
QME1 QME2 QME3 QME4 QME5 QME6 QME7 QME8 QME9 


********************************************************************************************

est store quaids

qui nlcom (a1:_b[/a1])(a2:_b[/a2])(a3:_b[/a3])(a4:_b[/a4])(a5:_b[/a5])(a6:_b[/a6]) ///
(a7:_b[/a7])(a8:_b[/a8])(a9:_b[/a9]) ///
(b1:_b[/b1])(b2:_b[/b2])(b3:_b[/b3])(b4:_b[/b4])(b5:_b[/b5])(b6:_b[/b6]) ///
(b7:_b[/b7])(b8:_b[/b8])(b9:_b[/b9]) ///
(g11:_b[/g11])(g12:_b[/g12])(g13:_b[/g13])(g14:_b[/g14])(g15:_b[/g15])(g16:_b[/g16])(g17:_b[/g17])(g18:_b[/g18]) ///
(g21:_b[/g12])(g22:_b[/g22])(g23:_b[/g23])(g24:_b[/g24])(g25:_b[/g25])(g26:_b[/g26])(g27:_b[/g27])(g28:_b[/g28]) ///
(g31:_b[/g13])(g32:_b[/g23])(g33:_b[/g33])(g34:_b[/g34])(g35:_b[/g35])(g36:_b[/g36])(g37:_b[/g37])(g38:_b[/g38]) ///
(g41:_b[/g14])(g42:_b[/g24])(g43:_b[/g34])(g44:_b[/g44])(g45:_b[/g45])(g46:_b[/g46])(g47:_b[/g47])(g48:_b[/g48]) ///
(g51:_b[/g15])(g52:_b[/g25])(g53:_b[/g35])(g54:_b[/g45])(g55:_b[/g55])(g56:_b[/g56])(g57:_b[/g57])(g58:_b[/g58]) ///
(g61:_b[/g16])(g62:_b[/g26])(g63:_b[/g36])(g64:_b[/g46])(g65:_b[/g56])(g66:_b[/g66])(g67:_b[/g67])(g68:_b[/g68]) ///
(g71:_b[/g17])(g72:_b[/g27])(g73:_b[/g37])(g74:_b[/g47])(g75:_b[/g57])(g76:_b[/g67])(g77:_b[/g77])(g78:_b[/g78]) ///
(g81:_b[/g18])(g82:_b[/g28])(g83:_b[/g38])(g84:_b[/g48])(g85:_b[/g58])(g86:_b[/g68])(g87:_b[/g78])(g88:_b[/g88]) ///
(g19:-_b[/g11]-_b[/g12]-_b[/g13]-_b[/g14]-_b[/g15]-_b[/g16]-_b[/g17]-_b[/g18]) ///
(g91:-_b[/g11]-_b[/g12]-_b[/g13]-_b[/g14]-_b[/g15]-_b[/g16]-_b[/g17]-_b[/g18]) ///
(g29:-_b[/g12]-_b[/g22]-_b[/g23]-_b[/g24]-_b[/g25]-_b[/g26]-_b[/g27]-_b[/g28]) ///
(g92:-_b[/g12]-_b[/g22]-_b[/g23]-_b[/g24]-_b[/g25]-_b[/g26]-_b[/g27]-_b[/g28]) ///
(g39:-_b[/g13]-_b[/g23]-_b[/g33]-_b[/g34]-_b[/g35]-_b[/g36]-_b[/g37]-_b[/g38]) ///
(g93:-_b[/g13]-_b[/g23]-_b[/g33]-_b[/g34]-_b[/g35]-_b[/g36]-_b[/g37]-_b[/g38]) ///
(g49:-_b[/g14]-_b[/g24]-_b[/g34]-_b[/g44]-_b[/g45]-_b[/g46]-_b[/g47]-_b[/g48]) ///
(g94:-_b[/g14]-_b[/g24]-_b[/g34]-_b[/g44]-_b[/g45]-_b[/g46]-_b[/g47]-_b[/g48]) ///
(g59:-_b[/g15]-_b[/g25]-_b[/g35]-_b[/g45]-_b[/g55]-_b[/g56]-_b[/g57]-_b[/g58]) ///
(g95:-_b[/g15]-_b[/g25]-_b[/g35]-_b[/g45]-_b[/g55]-_b[/g56]-_b[/g57]-_b[/g58]) ///
(g69:-_b[/g16]-_b[/g26]-_b[/g36]-_b[/g46]-_b[/g56]-_b[/g66]-_b[/g67]-_b[/g68]) ///
(g96:-_b[/g16]-_b[/g26]-_b[/g36]-_b[/g46]-_b[/g56]-_b[/g66]-_b[/g67]-_b[/g68]) ///
(g79:-_b[/g17]-_b[/g27]-_b[/g37]-_b[/g47]-_b[/g57]-_b[/g67]-_b[/g77]-_b[/g78]) ///
(g97:-_b[/g17]-_b[/g27]-_b[/g37]-_b[/g47]-_b[/g57]-_b[/g67]-_b[/g77]-_b[/g78]) ///
(g89:-_b[/g18]-_b[/g28]-_b[/g38]-_b[/g48]-_b[/g58]-_b[/g68]-_b[/g78]-_b[/g88]) ///
(g98:-_b[/g18]-_b[/g28]-_b[/g38]-_b[/g48]-_b[/g58]-_b[/g68]-_b[/g78]-_b[/g88]) ///
(g99:-(-_b[/g11]-_b[/g12]-_b[/g13]-_b[/g14]-_b[/g15]-_b[/g16]-_b[/g17]-_b[/g18])-(-_b[/g12]-_b[/g22]-_b[/g23]-_b[/g24]-_b[/g25]-_b[/g26]-_b[/g27]-_b[/g28]) ///
-(-_b[/g13]-_b[/g23]-_b[/g33]-_b[/g34]-_b[/g35]-_b[/g36]-_b[/g37]-_b[/g38])-(-_b[/g14]-_b[/g24]-_b[/g34]-_b[/g44]-_b[/g45]-_b[/g46]-_b[/g47]-_b[/g48]) ///
-(-_b[/g15]-_b[/g25]-_b[/g35]-_b[/g45]-_b[/g55]-_b[/g56]-_b[/g57]-_b[/g58])-(-_b[/g16]-_b[/g26]-_b[/g36]-_b[/g46]-_b[/g56]-_b[/g66]-_b[/g67]-_b[/g68]) ///
-(-_b[/g17]-_b[/g27]-_b[/g37]-_b[/g47]-_b[/g57]-_b[/g67]-_b[/g77]-_b[/g78])-(-_b[/g18]-_b[/g28]-_b[/g38]-_b[/g48]-_b[/g58]-_b[/g68]-_b[/g78]-_b[/g88])) ///
(r11:_b[/r11])(r21:_b[/r21])(r31:_b[/r31])(r41:_b[/r41])(r51:_b[/r51])(r61:_b[/r61]) ///
(r71:_b[/r71])(r81:_b[/r81])(r91:-_b[/r11]-_b[/r21]-_b[/r31]-_b[/r41]-_b[/r51]-_b[/r61]-_b[/r71]-_b[/r81]) ///
(r12:_b[/r12])(r22:_b[/r22])(r32:_b[/r32])(r42:_b[/r42])(r52:_b[/r52])(r62:_b[/r62]) ///
(r72:_b[/r72])(r82:_b[/r82])(r92:-_b[/r12]-_b[/r22]-_b[/r32]-_b[/r42]-_b[/r52]-_b[/r62]-_b[/r72]-_b[/r82]) ///
(r13:_b[/r13])(r23:_b[/r23])(r33:_b[/r33])(r43:_b[/r43])(r53:_b[/r53])(r63:_b[/r63]) ///
(r73:_b[/r73])(r83:_b[/r83])(r93:-_b[/r13]-_b[/r23]-_b[/r33]-_b[/r43]-_b[/r53]-_b[/r63]-_b[/r73]-_b[/r83]) ///
(r14:_b[/r14])(r24:_b[/r24])(r34:_b[/r34])(r44:_b[/r44])(r54:_b[/r54])(r64:_b[/r64]) ///
(r74:_b[/r74])(r84:_b[/r84])(r94:-_b[/r14]-_b[/r24]-_b[/r34]-_b[/r44]-_b[/r54]-_b[/r64]-_b[/r74]-_b[/r84]) ///
(l1:_b[/l1])(l2:_b[/l2])(l3:_b[/l3])(l4:_b[/l4])(l5:_b[/l5])(l6:_b[/l6]) ///
(l7:_b[/l7])(l8:_b[/l8])(l9:_b[/l9]) ///
(d1:_b[/d1])(d2:_b[/d2])(d3:_b[/d3])(d4:_b[/d4])(d5:_b[/d5])(d6:_b[/d6]) ///
(d7:_b[/d7])(d8:_b[/d8])(d9:_b[/d9]) , post noheader

est store quaidse

***ELASTICITIES***

quietly {
foreach x of varlist w* lnp* cdf* pdf* lnexp x4 x1 x2 x3 {
sum `x'
scalar `x'mean=r(mean)
}

* Price indexes
glo asum "(_b[a1] +_b[r11]*x1mean+_b[r12]*x2mean+_b[r13]*x3mean+_b[r14]*x4mean)*lnp1mean"
glo lp "_b[l1]*lnp1mean"
forv i=2(1)9 {
glo asum "${asum} + (_b[a`i'] +_b[r`i'1]*x1mean+_b[r`i'2]*x2mean+_b[r`i'3]*x3mean+_b[r`i'4]*x4mean)*lnp`i'mean"
glo lp "${lp} + _b[l`i']*lnp`i'mean"
}
glo gsum ""
forv i=1(1)9 {
forv j=1(1)9 {
glo gsum "${gsum} + 0.5*_b[g`i'`j']*lnp`i'mean*lnp`j'mean"
}
}
glo ap "5 + ${asum} ${gsum}"
glo bp "_b[b1]*lnp1mean"
forv i=2(1)9 {
glo bp "${bp} + _b[b`i']*lnp`i'mean"
}
glo bp "(exp(${bp}))"
*Reduced form (Mu)
forv i=1(1)9 {
glo mu`i' "_b[b`i'] + 2*_b[l`i']/${bp}*(lnexpmean-(${ap}))"
}
forv j=1(1)9 {
glo gsum2`j' ""
forv k=1(1)9 {
glo gsum2`j' "${gsum2`j'} + _b[g`j'`k']*lnp`k'mean"
}
}
forv i=1(1)9 {
glo dem`i' "_b[r`i'1]*x1mean + _b[r`i'2]*x2mean + _b[r`i'3]*x3mean+_b[r`i'4]*x4mean"
}
}

***ELASTICITIES (EXPRESSION TOO LONG) ***

*matrix e=I(9)
*forv i=1(1)9 {
*forv j=1(1)9 {
*local delta=cond(`i'==`j',1,0)
*scalar mu`i'`j'=_b[g`i'`j'] - (${mu`i'}*(_b[a`j'] + ${dem`j'} ${gsum2`j'}))-_b[l`i']*_b[b`j']/${bp}*(lnexpmean - ${ap})^2
*matrix e[`i',`j']=mu`i'`j'*cdf`i'mean/w`i'mean-`delta'
*}
*}

***ELASTICITIES (THIS IS DONE ONE BY ONE BUT IT WORKS)***

qui nlcom ///
(mua11: (_b[g11]-${mu1}*(_b[a1] + ${dem1} ${gsum21}))*100)(mub11: 100*_b[l1]*_b[b1]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua21: (_b[g21]-${mu2}*(_b[a1] + ${dem1} ${gsum21}))*100)(mub21: 100*_b[l2]*_b[b2]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua31: (_b[g31]-${mu3}*(_b[a1] + ${dem1} ${gsum21}))*100)(mub31: 100*_b[l3]*_b[b3]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua41: (_b[g41]-${mu4}*(_b[a1] + ${dem1} ${gsum21}))*100)(mub41: 100*_b[l4]*_b[b4]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua51: (_b[g51]-${mu5}*(_b[a1] + ${dem1} ${gsum21}))*100)(mub51: 100*_b[l5]*_b[b5]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua61: (_b[g61]-${mu6}*(_b[a1] + ${dem1} ${gsum21}))*100)(mub61: 100*_b[l6]*_b[b6]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua71: (_b[g71]-${mu7}*(_b[a1] + ${dem1} ${gsum21}))*100)(mub71: 100*_b[l7]*_b[b7]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua81: (_b[g81]-${mu8}*(_b[a1] + ${dem1} ${gsum21}))*100)(mub81: 100*_b[l8]*_b[b8]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua91: (_b[g91]-${mu9}*(_b[a1] + ${dem1} ${gsum21}))*100)(mub91: 100*_b[l9]*_b[b9]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua12: (_b[g12]-${mu1}*(_b[a2] + ${dem2} ${gsum22}))*100)(mub12: 100*_b[l1]*_b[b1]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua22: (_b[g22]-${mu2}*(_b[a2] + ${dem2} ${gsum22}))*100)(mub22: 100*_b[l2]*_b[b2]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua32: (_b[g32]-${mu3}*(_b[a2] + ${dem2} ${gsum22}))*100)(mub32: 100*_b[l3]*_b[b3]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua42: (_b[g42]-${mu4}*(_b[a2] + ${dem2} ${gsum22}))*100)(mub42: 100*_b[l4]*_b[b4]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua52: (_b[g52]-${mu5}*(_b[a2] + ${dem2} ${gsum22}))*100)(mub52: 100*_b[l5]*_b[b5]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua62: (_b[g62]-${mu6}*(_b[a2] + ${dem2} ${gsum22}))*100)(mub62: 100*_b[l6]*_b[b6]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua72: (_b[g72]-${mu7}*(_b[a2] + ${dem2} ${gsum22}))*100)(mub72: 100*_b[l7]*_b[b7]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua82: (_b[g82]-${mu8}*(_b[a2] + ${dem2} ${gsum22}))*100)(mub82: 100*_b[l8]*_b[b8]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua92: (_b[g92]-${mu9}*(_b[a2] + ${dem2} ${gsum22}))*100)(mub92: 100*_b[l9]*_b[b9]/${bp}*(lnexpmean - (${ap}))^2) ///
(mua13: (_b[g13]-${mu1}*(_b[a3] + ${dem3} ${gsum23}))*100)(mub13: 100*_b[l1]*_b[b1]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua23: (_b[g23]-${mu2}*(_b[a3] + ${dem3} ${gsum23}))*100)(mub23: 100*_b[l2]*_b[b2]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua33: (_b[g33]-${mu3}*(_b[a3] + ${dem3} ${gsum23}))*100)(mub33: 100*_b[l3]*_b[b3]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua43: (_b[g43]-${mu4}*(_b[a3] + ${dem3} ${gsum23}))*100)(mub43: 100*_b[l4]*_b[b4]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua53: (_b[g53]-${mu5}*(_b[a3] + ${dem3} ${gsum23}))*100)(mub53: 100*_b[l5]*_b[b5]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua63: (_b[g63]-${mu6}*(_b[a3] + ${dem3} ${gsum23}))*100)(mub63: 100*_b[l6]*_b[b6]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua73: (_b[g73]-${mu7}*(_b[a3] + ${dem3} ${gsum23}))*100)(mub73: 100*_b[l7]*_b[b7]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua83: (_b[g83]-${mu8}*(_b[a3] + ${dem3} ${gsum23}))*100)(mub83: 100*_b[l8]*_b[b8]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua93: (_b[g93]-${mu9}*(_b[a3] + ${dem3} ${gsum23}))*100)(mub93: 100*_b[l9]*_b[b9]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua14: (_b[g14]-${mu1}*(_b[a4] + ${dem4} ${gsum24}))*100)(mub14: 100*_b[l1]*_b[b1]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua24: (_b[g24]-${mu2}*(_b[a4] + ${dem4} ${gsum24}))*100)(mub24: 100*_b[l2]*_b[b2]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua34: (_b[g34]-${mu3}*(_b[a4] + ${dem4} ${gsum24}))*100)(mub34: 100*_b[l3]*_b[b3]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua44: (_b[g44]-${mu4}*(_b[a4] + ${dem4} ${gsum24}))*100)(mub44: 100*_b[l4]*_b[b4]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua54: (_b[g54]-${mu5}*(_b[a4] + ${dem4} ${gsum24}))*100)(mub54: 100*_b[l5]*_b[b5]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua64: (_b[g64]-${mu6}*(_b[a4] + ${dem4} ${gsum24}))*100)(mub64: 100*_b[l6]*_b[b6]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua74: (_b[g74]-${mu7}*(_b[a4] + ${dem4} ${gsum24}))*100)(mub74: 100*_b[l7]*_b[b7]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua84: (_b[g84]-${mu8}*(_b[a4] + ${dem4} ${gsum24}))*100)(mub84: 100*_b[l8]*_b[b8]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua94: (_b[g94]-${mu9}*(_b[a4] + ${dem4} ${gsum24}))*100)(mub94: 100*_b[l9]*_b[b9]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua15: (_b[g15]-${mu1}*(_b[a5] + ${dem5} ${gsum25}))*100)(mub15: 100*_b[l1]*_b[b1]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua25: (_b[g25]-${mu2}*(_b[a5] + ${dem5} ${gsum25}))*100)(mub25: 100*_b[l2]*_b[b2]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua35: (_b[g35]-${mu3}*(_b[a5] + ${dem5} ${gsum25}))*100)(mub35: 100*_b[l3]*_b[b3]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua45: (_b[g45]-${mu4}*(_b[a5] + ${dem5} ${gsum25}))*100)(mub45: 100*_b[l4]*_b[b4]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua55: (_b[g55]-${mu5}*(_b[a5] + ${dem5} ${gsum25}))*100)(mub55: 100*_b[l5]*_b[b5]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua65: (_b[g65]-${mu6}*(_b[a5] + ${dem5} ${gsum25}))*100)(mub65: 100*_b[l6]*_b[b6]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua75: (_b[g75]-${mu7}*(_b[a5] + ${dem5} ${gsum25}))*100)(mub75: 100*_b[l7]*_b[b7]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua85: (_b[g85]-${mu8}*(_b[a5] + ${dem5} ${gsum25}))*100)(mub85: 100*_b[l8]*_b[b8]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua95: (_b[g95]-${mu9}*(_b[a5] + ${dem5} ${gsum25}))*100)(mub95: 100*_b[l9]*_b[b9]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua16: (_b[g16]-${mu1}*(_b[a6] + ${dem6} ${gsum26}))*100)(mub16: 100*_b[l1]*_b[b1]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua26: (_b[g26]-${mu2}*(_b[a6] + ${dem6} ${gsum26}))*100)(mub26: 100*_b[l2]*_b[b2]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua36: (_b[g36]-${mu3}*(_b[a6] + ${dem6} ${gsum26}))*100)(mub36: 100*_b[l3]*_b[b3]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua46: (_b[g46]-${mu4}*(_b[a6] + ${dem6} ${gsum26}))*100)(mub46: 100*_b[l4]*_b[b4]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua56: (_b[g56]-${mu5}*(_b[a6] + ${dem6} ${gsum26}))*100)(mub56: 100*_b[l5]*_b[b5]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua66: (_b[g66]-${mu6}*(_b[a6] + ${dem6} ${gsum26}))*100)(mub66: 100*_b[l6]*_b[b6]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua76: (_b[g76]-${mu7}*(_b[a6] + ${dem6} ${gsum26}))*100)(mub76: 100*_b[l7]*_b[b7]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua86: (_b[g86]-${mu8}*(_b[a6] + ${dem6} ${gsum26}))*100)(mub86: 100*_b[l8]*_b[b8]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua96: (_b[g96]-${mu9}*(_b[a6] + ${dem6} ${gsum26}))*100)(mub96: 100*_b[l9]*_b[b9]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua17: (_b[g17]-${mu1}*(_b[a7] + ${dem7} ${gsum27}))*100)(mub17: 100*_b[l1]*_b[b1]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua27: (_b[g27]-${mu2}*(_b[a7] + ${dem7} ${gsum27}))*100)(mub27: 100*_b[l2]*_b[b2]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua37: (_b[g37]-${mu3}*(_b[a7] + ${dem7} ${gsum27}))*100)(mub37: 100*_b[l3]*_b[b3]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua47: (_b[g47]-${mu4}*(_b[a7] + ${dem7} ${gsum27}))*100)(mub47: 100*_b[l4]*_b[b4]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua57: (_b[g57]-${mu5}*(_b[a7] + ${dem7} ${gsum27}))*100)(mub57: 100*_b[l5]*_b[b5]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua67: (_b[g67]-${mu6}*(_b[a7] + ${dem7} ${gsum27}))*100)(mub67: 100*_b[l6]*_b[b6]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua77: (_b[g77]-${mu7}*(_b[a7] + ${dem7} ${gsum27}))*100)(mub77: 100*_b[l7]*_b[b7]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua87: (_b[g87]-${mu8}*(_b[a7] + ${dem7} ${gsum27}))*100)(mub87: 100*_b[l8]*_b[b8]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua97: (_b[g97]-${mu9}*(_b[a7] + ${dem7} ${gsum27}))*100)(mub97: 100*_b[l9]*_b[b9]/${bp}*(lnexpmean - (${ap}))^2) ///
(mua18: (_b[g18]-${mu1}*(_b[a8] + ${dem8} ${gsum28}))*100)(mub18: 100*_b[l1]*_b[b1]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua28: (_b[g28]-${mu2}*(_b[a8] + ${dem8} ${gsum28}))*100)(mub28: 100*_b[l2]*_b[b2]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua38: (_b[g38]-${mu3}*(_b[a8] + ${dem8} ${gsum28}))*100)(mub38: 100*_b[l3]*_b[b3]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua48: (_b[g48]-${mu4}*(_b[a8] + ${dem8} ${gsum28}))*100)(mub48: 100*_b[l4]*_b[b4]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua58: (_b[g58]-${mu5}*(_b[a8] + ${dem8} ${gsum28}))*100)(mub58: 100*_b[l5]*_b[b5]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua68: (_b[g68]-${mu6}*(_b[a8] + ${dem8} ${gsum28}))*100)(mub68: 100*_b[l6]*_b[b6]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua78: (_b[g78]-${mu7}*(_b[a8] + ${dem8} ${gsum28}))*100)(mub78: 100*_b[l7]*_b[b7]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua88: (_b[g88]-${mu8}*(_b[a8] + ${dem8} ${gsum28}))*100)(mub88: 100*_b[l8]*_b[b8]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua98: (_b[g98]-${mu9}*(_b[a8] + ${dem8} ${gsum28}))*100)(mub98: 100*_b[l9]*_b[b9]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua19: (_b[g19]-${mu1}*(_b[a9] + ${dem9} ${gsum29}))*100)(mub19: 100*_b[l1]*_b[b1]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua29: (_b[g29]-${mu2}*(_b[a9] + ${dem9} ${gsum29}))*100)(mub29: 100*_b[l2]*_b[b2]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua39: (_b[g39]-${mu3}*(_b[a9] + ${dem9} ${gsum29}))*100)(mub39: 100*_b[l3]*_b[b3]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua49: (_b[g49]-${mu4}*(_b[a9] + ${dem9} ${gsum29}))*100)(mub49: 100*_b[l4]*_b[b4]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua59: (_b[g59]-${mu5}*(_b[a9] + ${dem9} ${gsum29}))*100)(mub59: 100*_b[l5]*_b[b5]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua69: (_b[g69]-${mu6}*(_b[a9] + ${dem9} ${gsum29}))*100)(mub69: 100*_b[l6]*_b[b6]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua79: (_b[g79]-${mu7}*(_b[a9] + ${dem9} ${gsum29}))*100)(mub79: 100*_b[l7]*_b[b7]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua89: (_b[g89]-${mu8}*(_b[a9] + ${dem9} ${gsum29}))*100)(mub89: 100*_b[l8]*_b[b8]/${bp}*(lnexpmean - (${ap}))^2) /// 
(mua99: (_b[g99]-${mu9}*(_b[a9] + ${dem9} ${gsum29}))*100)(mub99: 100*_b[l9]*_b[b9]/${bp}*(lnexpmean - (${ap}))^2) /// 
, post noheader

qui nlcom ///
(mu11: _b[mua11]-_b[mub11])(mu21: _b[mua21]-_b[mub21])(mu31: _b[mua31]-_b[mub31])(mu41: _b[mua41]-_b[mub41])(mu51: _b[mua51]-_b[mub51]) ///
(mu61: _b[mua61]-_b[mub61])(mu71: _b[mua71]-_b[mub71])(mu81: _b[mua81]-_b[mub81])(mu91: _b[mua91]-_b[mub91]) ///
(mu12: _b[mua12]-_b[mub12])(mu22: _b[mua22]-_b[mub22])(mu32: _b[mua32]-_b[mub32])(mu42: _b[mua42]-_b[mub42])(mu52: _b[mua52]-_b[mub52]) ///
(mu62: _b[mua62]-_b[mub62])(mu72: _b[mua72]-_b[mub72])(mu82: _b[mua82]-_b[mub82])(mu92: _b[mua92]-_b[mub92]) ///
(mu13: _b[mua13]-_b[mub13])(mu23: _b[mua23]-_b[mub23])(mu33: _b[mua33]-_b[mub33])(mu43: _b[mua43]-_b[mub43])(mu53: _b[mua53]-_b[mub53]) ///
(mu63: _b[mua63]-_b[mub63])(mu73: _b[mua73]-_b[mub73])(mu83: _b[mua83]-_b[mub83])(mu93: _b[mua93]-_b[mub93]) ///
(mu14: _b[mua14]-_b[mub14])(mu24: _b[mua24]-_b[mub24])(mu34: _b[mua34]-_b[mub34])(mu44: _b[mua44]-_b[mub44])(mu54: _b[mua54]-_b[mub54]) ///
(mu64: _b[mua64]-_b[mub64])(mu74: _b[mua74]-_b[mub74])(mu84: _b[mua84]-_b[mub84])(mu94: _b[mua94]-_b[mub94]) ///
(mu15: _b[mua15]-_b[mub15])(mu25: _b[mua25]-_b[mub25])(mu35: _b[mua35]-_b[mub35])(mu45: _b[mua45]-_b[mub45])(mu55: _b[mua55]-_b[mub55]) ///
(mu65: _b[mua65]-_b[mub65])(mu75: _b[mua75]-_b[mub75])(mu85: _b[mua85]-_b[mub85])(mu95: _b[mua95]-_b[mub95]) ///
(mu16: _b[mua16]-_b[mub16])(mu26: _b[mua26]-_b[mub26])(mu36: _b[mua36]-_b[mub36])(mu46: _b[mua46]-_b[mub46])(mu56: _b[mua56]-_b[mub56]) ///
(mu66: _b[mua66]-_b[mub66])(mu76: _b[mua76]-_b[mub76])(mu86: _b[mua86]-_b[mub86])(mu96: _b[mua96]-_b[mub96]) ///
(mu17: _b[mua17]-_b[mub17])(mu27: _b[mua27]-_b[mub27])(mu37: _b[mua37]-_b[mub37])(mu47: _b[mua47]-_b[mub47])(mu57: _b[mua57]-_b[mub57]) ///
(mu67: _b[mua67]-_b[mub67])(mu77: _b[mua77]-_b[mub77])(mu87: _b[mua87]-_b[mub87])(mu97: _b[mua97]-_b[mub97]) ///
(mu18: _b[mua18]-_b[mub18])(mu28: _b[mua28]-_b[mub28])(mu38: _b[mua38]-_b[mub38])(mu48: _b[mua48]-_b[mub48])(mu58: _b[mua58]-_b[mub58]) ///
(mu68: _b[mua68]-_b[mub68])(mu78: _b[mua78]-_b[mub78])(mu88: _b[mua88]-_b[mub88])(mu98: _b[mua98]-_b[mub98]) ///
(mu19: _b[mua19]-_b[mub19])(mu29: _b[mua29]-_b[mub29])(mu39: _b[mua39]-_b[mub39])(mu49: _b[mua49]-_b[mub49])(mu59: _b[mua59]-_b[mub59]) ///
(mu69: _b[mua69]-_b[mub69])(mu79: _b[mua79]-_b[mub79])(mu89: _b[mua89]-_b[mub89])(mu99: _b[mua99]-_b[mub99]) ///
, post noheader

nlcom (elu11:_b[mu11]*0.01*cdf1mean/w1mean-1)(elu21:_b[mu21]*0.01*cdf2mean/w2mean)(elu31:_b[mu31]*0.01*cdf3mean/w3mean) ///
(elu41:_b[mu41]*0.01*cdf4mean/w4mean)(elu51:_b[mu51]*0.01*cdf2mean/w5mean)(elu61:_b[mu61]*0.01*cdf6mean/w6mean) ///
(elu71:_b[mu71]*0.01*cdf7mean/w7mean)(elu81:_b[mu81]*0.01*cdf8mean/w8mean)(elu91:_b[mu91]*0.01*cdf9mean/w9mean) ///
(elu12:_b[mu12]*0.01*cdf1mean/w1mean)(elu22:_b[mu22]*0.01*cdf2mean/w2mean-1)(elu32:_b[mu32]*0.01*cdf3mean/w3mean) ///
(elu42:_b[mu42]*0.01*cdf4mean/w4mean)(elu52:_b[mu52]*0.01*cdf5mean/w5mean)(elu62:_b[mu62]*0.01*cdf6mean/w6mean) ///
(elu72:_b[mu72]*0.01*cdf7mean/w7mean)(elu82:_b[mu82]*0.01*cdf8mean/w8mean)(elu92:_b[mu92]*0.01*cdf9mean/w9mean) ///
(elu13:_b[mu13]*0.01*cdf1mean/w1mean)(elu23:_b[mu23]*0.01*cdf2mean/w2mean)(elu33:_b[mu33]*0.01*cdf3mean/w3mean-1) ///
(elu43:_b[mu43]*0.01*cdf4mean/w4mean)(elu53:_b[mu53]*0.01*cdf5mean/w5mean)(elu63:_b[mu63]*0.01*cdf6mean/w6mean) ///
(elu73:_b[mu73]*0.01*cdf7mean/w7mean)(elu83:_b[mu83]*0.01*cdf8mean/w8mean)(elu93:_b[mu93]*0.01*cdf9mean/w9mean) ///
(elu14:_b[mu14]*0.01*cdf1mean/w1mean)(elu24:_b[mu24]*0.01*cdf2mean/w2mean)(elu34:_b[mu34]*0.01*cdf3mean/w3mean) ///
(elu44:_b[mu44]*0.01*cdf4mean/w4mean-1)(elu54:_b[mu54]*0.01*cdf5mean/w5mean)(elu64:_b[mu64]*0.01*cdf6mean/w6mean) ///
(elu74:_b[mu74]*0.01*cdf7mean/w7mean)(elu84:_b[mu84]*0.01*cdf8mean/w8mean)(elu94:_b[mu94]*0.01*cdf9mean/w9mean) ///
(elu15:_b[mu15]*0.01*cdf1mean/w1mean)(elu25:_b[mu22]*0.01*cdf2mean/w2mean)(elu35:_b[mu35]*0.01*cdf3mean/w3mean) ///
(elu45:_b[mu45]*0.01*cdf4mean/w4mean)(elu55:_b[mu52]*0.01*cdf5mean/w5mean-1)(elu65:_b[mu65]*0.01*cdf6mean/w6mean) ///
(elu75:_b[mu75]*0.01*cdf7mean/w7mean)(elu85:_b[mu82]*0.01*cdf8mean/w8mean)(elu95:_b[mu95]*0.01*cdf9mean/w9mean) ///
(elu16:_b[mu16]*0.01*cdf1mean/w1mean)(elu26:_b[mu26]*0.01*cdf2mean/w2mean)(elu36:_b[mu36]*0.01*cdf3mean/w3mean) ///
(elu46:_b[mu46]*0.01*cdf4mean/w4mean)(elu56:_b[mu56]*0.01*cdf5mean/w5mean)(elu66:_b[mu66]*0.01*cdf6mean/w6mean-1) ///
(elu76:_b[mu76]*0.01*cdf7mean/w7mean)(elu86:_b[mu86]*0.01*cdf8mean/w8mean)(elu96:_b[mu96]*0.01*cdf9mean/w9mean) ///
(elu17:_b[mu17]*0.01*cdf1mean/w1mean)(elu27:_b[mu27]*0.01*cdf2mean/w2mean)(elu37:_b[mu37]*0.01*cdf3mean/w3mean) ///
(elu47:_b[mu47]*0.01*cdf4mean/w4mean)(elu57:_b[mu57]*0.01*cdf5mean/w5mean)(elu67:_b[mu67]*0.01*cdf6mean/w6mean) ///
(elu77:_b[mu77]*0.01*cdf7mean/w7mean-1)(elu87:_b[mu87]*0.01*cdf8mean/w8mean)(elu97:_b[mu97]*0.01*cdf9mean/w9mean) ///
(elu18:_b[mu18]*0.01*cdf1mean/w1mean)(elu28:_b[mu28]*0.01*cdf2mean/w2mean)(elu38:_b[mu38]*0.01*cdf3mean/w3mean) ///
(elu48:_b[mu48]*0.01*cdf4mean/w4mean)(elu58:_b[mu58]*0.01*cdf5mean/w5mean)(elu68:_b[mu68]*0.01*cdf6mean/w6mean) ///
(elu78:_b[mu78]*0.01*cdf7mean/w7mean)(elu88:_b[mu88]*0.01*cdf8mean/w8mean-1)(elu98:_b[mu98]*0.01*cdf9mean/w9mean) ///
(elu19:_b[mu19]*0.01*cdf1mean/w1mean)(elu29:_b[mu29]*0.01*cdf2mean/w2mean)(elu39:_b[mu39]*0.01*cdf3mean/w3mean) ///
(elu49:_b[mu49]*0.01*cdf4mean/w4mean)(elu59:_b[mu59]*0.01*cdf5mean/w5mean)(elu69:_b[mu69]*0.01*cdf6mean/w6mean) ///
(elu79:_b[mu79]*0.01*cdf7mean/w7mean)(elu89:_b[mu89]*0.01*cdf8mean/w8mean)(elu99:_b[mu99]*0.01*cdf9mean/w9mean-1) ///
, post noheader
