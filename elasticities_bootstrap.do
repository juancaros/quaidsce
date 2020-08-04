*************CALCULATING ELASTICITIES WITH IC/BOOTSTRAP***********
*QUAIDS MODEL FOR EPF VII CHILE 2011-2012
*Carlos Caro, 2016

cd "C:\GFRP\Carlos"

use "C:\GFRP\Carlos\EPFVII.dta", clear
local par
set seed 1
forval i=1(1)291 {
local par `par' bb_`i'=r(bb[`i',1]) 
}

quaids_ce w1 w2 w3 w4 w5 w6 w7 w8 w9 lnp1 lnp2 lnp3 lnp4 lnp5 lnp6 lnp7 lnp8 lnp9 /// 
lnexp NEA EDUE ZONA SEXO SES EDAD login QME1 QME2 QME3 QME4 QME5 QME6 QME7 QME8 QME9

bootstrap _b, reps(500) saving(boot_n.dta, replace) : quaids_n w1 w2 w3 w4 w5 w6 w7 w8 w9 ///
 lnp1 lnp2 lnp3 lnp4 lnp5 lnp6 lnp7 lnp8 lnp9 /// 
lnexp NEA EDUE ZONA SEXO SES EDAD login QME1 QME2 QME3 QME4 QME5 QME6 QME7 QME8 QME9

bootstrap _b, reps(500) saving(boot_c.dta, replace) : quaids_c w1 w2 w3 w4 w5 w6 w7 w8 w9 ///
lnp1 lnp2 lnp3 lnp4 lnp5 lnp6 lnp7 lnp8 lnp9 /// 
lnexp NEA EDUE ZONA SEXO SES EDAD login QME1 QME2 QME3 QME4 QME5 QME6 QME7 QME8 QME9
 
bootstrap _b, reps(500) saving(boot_ce.dta, replace) : quaids_ce w1 w2 w3 w4 w5 w6 w7 w8 w9 ///
lnp1 lnp2 lnp3 lnp4 lnp5 lnp6 lnp7 lnp8 lnp9 /// 
lnexp NEA EDUE ZONA SEXO SES EDAD login QME1 QME2 QME3 QME4 QME5 QME6 QME7 QME8 QME9
 
drop if QI>2
bootstrap _b, reps(500) saving(boot_ce_l.dta, replace) : quaids_ce w1 w2 w3 w4 w5 w6 w7 w8 w9 ///
lnp1 lnp2 lnp3 lnp4 lnp5 lnp6 lnp7 lnp8 lnp9 /// 
lnexp NEA EDUE ZONA SEXO SES EDAD login QME1 QME2 QME3 QME4 QME5 QME6 QME7 QME8 QME9 

drop if QI<=2
bootstrap _b, reps(500) saving(boot_ce_h.dta, replace) : quaids_ce w1 w2 w3 w4 w5 w6 w7 w8 w9 ///
lnp1 lnp2 lnp3 lnp4 lnp5 lnp6 lnp7 lnp8 lnp9 /// 
lnexp NEA EDUE ZONA SEXO SES EDAD login QME1 QME2 QME3 QME4 QME5 QME6 QME7 QME8 QME9

**************************

putexcel set bootstrap.xlsx, sheet("Table 1") modify

mat A=r(table)'

forv j=1(2)17 {
local i=((`j'+1)/2)+8*(((`j'+1)/2)-1)
	putexcel (B`j')=A[`i',1]
	putexcel (C`j')=A[1+`i',1]
	putexcel (D`j')=A[2+`i',1]
	putexcel (E`j')=A[3+`i',1]
	putexcel (F`j')=A[4+`i',1]
	putexcel (G`j')=A[5+`i',1]
	putexcel (H`j')=A[6+`i',1]
	putexcel (I`j')=A[7+`i',1]
	putexcel (J`j')=A[8+`i',1]
}
forv j=2(2)18 {
local i=(`j'/2)+8*((`j'/2)-1)
	putexcel (B`j')=A[`i',2]
	putexcel (C`j')=A[1+`i',2]
	putexcel (D`j')=A[2+`i',2]
	putexcel (E`j')=A[3+`i',2]
	putexcel (F`j')=A[4+`i',2]
	putexcel (G`j')=A[5+`i',2]
	putexcel (H`j')=A[6+`i',2]
	putexcel (I`j')=A[7+`i',2]
	putexcel (J`j')=A[8+`i',2]
}

putexcel set bootstrap.xlsx, sheet("Table 2") modify

forv j=1(2)13 {
local i=(`j'+1)/2
	putexcel (B`j')=A[81+`i',1]
	putexcel (C`j')=A[88+`i',1]
	putexcel (D`j')=A[95+`i',1]
	putexcel (E`j')=A[102+`i',1]
	putexcel (F`j')=A[109+`i',1]
	putexcel (G`j')=A[116+`i',1]
	putexcel (H`j')=A[123+`i',1]
	putexcel (I`j')=A[130+`i',1]
	putexcel (J`j')=A[137+`i',1]
	putexcel (K`j')=A[144+`i',1]
}
forv j=2(2)14 {
local i=`j'/2
	putexcel (B`j')=A[81+`i',2]
	putexcel (C`j')=A[88+`i',2]
	putexcel (D`j')=A[95+`i',2]
	putexcel (E`j')=A[102+`i',2]
	putexcel (F`j')=A[109+`i',2]
	putexcel (G`j')=A[116+`i',2]
	putexcel (H`j')=A[123+`i',2]
	putexcel (I`j')=A[130+`i',2]
	putexcel (J`j')=A[137+`i',2]
	putexcel (K`j')=A[144+`i',2]
}

putexcel set bootstrap.xlsx, sheet("Table 3") modify

forv j=1(2)13 {
local i=(`j'+1)/2
	putexcel (B`j')=A[151+`i',1]
	putexcel (C`j')=A[158+`i',1]
	putexcel (D`j')=A[165+`i',1]
	putexcel (E`j')=A[172+`i',1]
	putexcel (F`j')=A[179+`i',1]
	putexcel (G`j')=A[186+`i',1]
	putexcel (H`j')=A[193+`i',1]
	putexcel (I`j')=A[200+`i',1]
	putexcel (J`j')=A[207+`i',1]
	putexcel (K`j')=A[214+`i',1]
}
forv j=2(2)14 {
local i=`j'/2
	putexcel (B`j')=A[151+`i',2]
	putexcel (C`j')=A[158+`i',2]
	putexcel (D`j')=A[165+`i',2]
	putexcel (E`j')=A[172+`i',2]
	putexcel (F`j')=A[179+`i',2]
	putexcel (G`j')=A[186+`i',2]
	putexcel (H`j')=A[193+`i',2]
	putexcel (I`j')=A[200+`i',2]
	putexcel (J`j')=A[207+`i',2]
	putexcel (K`j')=A[214+`i',2]
}

putexcel set bootstrap.xlsx, sheet("Table 4") modify

forv j=1(2)13 {
local i=(`j'+1)/2
	putexcel (B`j')=A[221+`i',1]
	putexcel (C`j')=A[228+`i',1]
	putexcel (D`j')=A[235+`i',1]
	putexcel (E`j')=A[242+`i',1]
	putexcel (F`j')=A[249+`i',1]
	putexcel (G`j')=A[256+`i',1]
	putexcel (H`j')=A[263+`i',1]
	putexcel (I`j')=A[270+`i',1]
	putexcel (J`j')=A[277+`i',1]
	putexcel (K`j')=A[284+`i',1]
}
forv j=2(2)14 {
local i=`j'/2
	putexcel (B`j')=A[221+`i',2]
	putexcel (C`j')=A[228+`i',2]
	putexcel (D`j')=A[235+`i',2]
	putexcel (E`j')=A[242+`i',2]
	putexcel (F`j')=A[249+`i',2]
	putexcel (G`j')=A[256+`i',2]
	putexcel (H`j')=A[263+`i',2]
	putexcel (I`j')=A[270+`i',2]
	putexcel (J`j')=A[277+`i',2]
	putexcel (K`j')=A[284+`i',2]
}

