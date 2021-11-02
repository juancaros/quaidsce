clear all
*capture log close
*set maxvar 10000
*cd "C:\ado\plus\u"  //set path

*net install quaidsce, replace force from("https://juancaros.github.io/quaidsce")
*do utils__quaidsce.mata //run mata to update libraries
*lmbuild lquaidsce.mlib, replace dir(C:\Users\juan.caro\ado\plus)
quiet do "C:\Users\juanp\OneDrive\Documentos\GitHub\quaidsce\utils__quaidsce.mata" //run mata to update libraries
*lmbuild lquaidsce.mlib, replace dir(C:\ado\plus\l)

*log using  "C:\Users\jccaro\quaidsce\quaidsce\test.log", replace
webuse food, clear
program drop _all

keep if _n<1001

***debugginb tools
*set trace on
*set tracedepth 4
*set matadebug on
*mata: mata set matalnum on

set seed 1
foreach i of numlist 1/4 {
gen aux = cond(runiform() < 0.2, 0, 1)
replace w`i'=0 if aux==0
drop aux 
}

gen w5=1-w1-w2-w3-w4
replace w5=0 if w5<0.0001
gen p5=0.5*p1+0.5*p3+exp(rnormal())
gen lnp5=ln(p5)

gen nkids = int(runiform()*4)
gen rural = (runiform() > 0.2)
gen income = exp(rnormal())+exp(rnormal())


log using  "C:\Users\juanp\OneDrive\Documentos\GitHub\quaidsce\test_JCSH.log", replace

/***********************************
************************************
************************************
NO QUADRATICS AND NO DEMOGRAPHICS
************************************
************************************
***********************************/
quiet quaids w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) nolog noquadratic 

estat uncompensated, atmeans
mat define unce_quaids=  r(uncompelas)
mat list unce_quaids

*unce_quaids[5,5]
*            c1          c2          c3          c4          c5
*r1  -.69153711   -.1446679  -.08682326   -.0833703  -.03566236
*r2  -.19958404  -.65813068    .0278182  -.00121548  -.02597998
*r3  -.35031502   .03872032  -.63778572   -.1068305   .06004895
*r4  -.11668527  -.02507305  -.04044397  -.84713088    .0437619
*r5   -.0786502  -.06827499   .01867919   .02806866  -.98395759

estat expenditure, atmeans
mat define ee_quaids=  r(expelas) 
mat list ee_quaids

*ee_quaids[1,5]
*           c1         c2         c3         c4         c5
*r1  1.0420609  .85709198  .99616196  .98557128  1.0841349

estat compensated, atmeans
mat define ce_quaids=    r(compelas) 
mat list ce_quaids

*ce_quaids[5,5]
*            c1          c2          c3          c4          c5
*r1   -.3391018   .04983175  -.00318228    .1330121   .15944023
*r2   .09029294   -.4981553   .09661266   .17675839   .13449132
*r3  -.01340319   .22465298  -.55782882   .10002105   .24655799
*r4   .21664468   .15888287   .03866286  -.64247848   .22828807
*r5   .28801495   .13407773   .10569724   .25318766  -.78097758


quiet quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) nolog nocensor noquadratic 

estat uncomp
mat define unce_quaidsce=  r(elas_u)
mat list unce_quaidsce

*unce_quaidsce[5,5]
*            c1          c2          c3          c4          c5
*r1  -.68795229  -.14647604   -.0870176  -.08327911  -.03559704
*r2    -.211764  -.65198727   .02847852  -.00152532  -.02620191
*r3  -.35064213   .03888532  -.63776799  -.10683882   .06004299
*r4  -.11791502  -.02445278  -.04037731  -.84716217   .04373949
*r5  -.07147943  -.07189183   .01829044   .02825108  -.98382693

estat exp
mat define ee_quaidsce=  r(elas_i)
mat list ee_quaidsce

*ee_quaidsce[1,5]
*           c1         c2         c3         c4         c5
*r1  1.0420609  .85709198  .99616196  .98557128  1.0841349

estat comp
mat define ce_quaidsce=  r(elas_c)
mat list ce_quaidsce

*ce_quaidsce[5,5]
*            c1          c2          c3          c4          c5
*r1  -.33551698   .04802362  -.00337662   .13310329   .15950555
*r2   .07811298  -.49201189   .09727297   .17644855   .13426938
*r3  -.01373031   .22481797  -.55781109   .10001273   .24655203
*r4   .21541493   .15950313   .03872953  -.64250976   .22826566
*r5   .29518572   .13046089   .10530849   .25337008  -.78084692


/***********************************
************************************
************************************
NO QUADRATICS AND DEMOGRAPHICS
************************************
************************************
***********************************/
quiet quaids w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog noquadratic 

estat uncompensated, atmeans
mat define unce_quaids=  r(uncompelas)
mat list unce_quaids

*unce_quaids[5,5]
*            c1          c2          c3          c4          c5
*r1  -.68738373    -.141825  -.08645897  -.08559725  -.03408142
*r2  -.19434658  -.66299591   .02913256   .00330384  -.02534175
*r3  -.35414358   .03877068  -.63967495   -.1116947   .06142013
*r4   -.1270128  -.02470048  -.04263838  -.84321285   .03892798
*r5  -.07827891  -.06899503   .01995451   .02532602  -.98267636

estat expenditure, atmeans
mat define ee_quaids=  r(expelas) 
mat list ee_quaids
*ee_quaids[1,5]
*           c1         c2         c3         c4         c5
*r1  1.0353464  .85024784  1.0053224  .99863653  1.0846698

estat compensated, atmeans
mat define ce_quaids=    r(compelas) 
mat list ce_quaids
*ce_quaids[5,5]
*            c1          c2          c3          c4          c5
*r1  -.33721935   .05142139  -.00335694   .12939088   .15976402
*r2   .09321564  -.50429798   .09737767   .17985653   .13384813
*r3   -.0141336   .22641313  -.55898279     .097059   .24964425
*r4   .21073595   .16169405   .03751714  -.63584746   .22590033
*r5   .28856713   .13345752   .10701548   .25055608  -.77959621



quiet quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog noquadratic nocensor
estat uncomp
mat define unce_quaidsce=  r(elas_u)
mat list unce_quaidsce

*unce_quaidsce[5,5]
*            c1          c2          c3          c4          c5
*r1  -.68437272  -.14334535  -.08660613  -.08555407   -.0340147
*r2  -.20710334  -.65655464   .02975603   .00312088  -.02562444
*r3  -.35369018   .03854175  -.63969711  -.11168819   .06143017
*r4  -.12712895  -.02464183  -.04263271  -.84321452   .03892541
*r5  -.07106625  -.07263692     .019602   .02542946  -.98251653

estat exp
mat define ee_quaidsce=  r(elas_i)
mat list ee_quaidsce
*ee_quaidsce[1,5]
*           c1         c2         c3         c4         c5
*r1  1.0353464  .85024784  1.0053224  .99863653  1.0846698


estat comp
mat define ce_quaidsce=  r(elas_c)
mat list ce_quaidsce

*ce_quaidsce[5,5]
*            c1          c2          c3          c4          c5
*r1  -.33420834   .04990104  -.00350409   .12943406   .15983075
*r2   .08045889  -.49785672   .09800113   .17967358   .13356544
*r3   -.0136802   .22618419  -.55900494   .09706551    .2496543
*r4    .2106198    .1617527   .03752281  -.63584913   .22589776
*r5   .29577979   .12981563   .10666298   .25065952  -.77943638


/***********************************
************************************
************************************
QUADRATICS AND NO DEMOGRAPHICS
************************************
************************************
***********************************/
quiet quaids w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) nolog 

estat uncompensated, atmeans
mat define unce_quaids=  r(uncompelas)
mat list unce_quaids
*unce_quaids[5,5]
*            c1          c2          c3          c4          c5
*r1   -.6734386  -.15884546  -.09422362  -.08367213  -.03111475
*r2  -.22726473  -.63982397   .03603636  -.00326336   -.0291211
*r3  -.38496159   .05819222  -.62482798  -.10965612   .05682208
*r4  -.11899527  -.02654172  -.04126619  -.84706385   .04367799
*r5  -.06633336  -.06763343    .0192114   .03179245   -.9875646

estat expenditure, atmeans
mat define ee_quaids=  r(expelas) 
mat list ee_quaids
*ee_quaids[1,5]
*           c1         c2         c3         c4         c5
*r1  1.0412946   .8634368  1.0044314  .99018904  1.0705275

estat compensated, atmeans
mat define ce_quaids=    r(compelas) 
mat list ce_quaids
*ce_quaids[5,5]
*            c1          c2          c3          c4          c5
*r1  -.32126249   .03551115  -.01064415   .13255113   .16384436
*r2   .06475813  -.47866434   .10534008   .17602801   .13253812
*r3  -.04525296   .24566836  -.54420734   .09891256   .24487938
*r4   .21589645    .1582761   .03821129  -.64145257   .22906873
*r5   .29572964   .13217948   .10513725    .2540859  -.78713227



quiet quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) nolog nocensor
estat uncomp
mat define unce_quaidsce=  r(elas_u)
mat list unce_quaidsce
*unce_quaidsce[5,5]
*            c1          c2          c3          c4          c5
*r1  -.66520759   -.1621836  -.09655822  -.08428008  -.02995319
*r2  -.25448509  -.62878458   .04375699  -.00125284  -.03296245
*r3  -.38407831     .057834  -.62507851  -.10972136   .05694673
*r4  -.12095083  -.02574862  -.04071153  -.84691941   .04340202
*r5  -.05227551  -.07333468   .01522411   .03075413  -.98558075

estat exp
mat define ee_quaidsce=  r(elas_i)
mat list ee_quaidsce
*ee_quaidsce[1,5]
*           c1         c2         c3         c4         c5
*r1  1.0412946   .8634368  1.0044314  .99018904  1.0705275

estat comp
mat define ce_quaidsce=  r(elas_c)
mat list ce_quaidsce
*ce_quaidsce[5,5]
*            c1          c2          c3          c4          c5
*r1  -.31303148   .03217301  -.01297875   .13194318   .16500592
*r2   .03753777  -.46762494   .11306071   .17803853   .12869677
*r3  -.04436968   .24531014  -.54445787   .09884732   .24500403
*r4   .21394089   .15906919   .03876596  -.64130813   .22879276
*r5   .30978749   .12647823   .10114996   .25304757  -.78514842



/***********************************
************************************
************************************
QUADRATICS AND DEMOGRAPHICS
************************************
************************************
***********************************/
quiet quaids w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog 

estat uncompensated, atmeans
mat define unce_quaids=  r(uncompelas)
mat list unce_quaids
*unce_quaids[5,5]
*            c1          c2          c3          c4          c5
*r1  -.65402369  -.15466283  -.09667678  -.09535059  -.04164129
*r2  -.21527343  -.65645026   .03375876   .00593423   -.0215072
*r3  -.38990361   .05398783  -.62667958  -.10153493   .07453049
*r4  -.14469442  -.02361435  -.04087145  -.84323998   .04214077
*r5  -.08273809  -.06005829   .02626937   .03599686  -.98202648

estat expenditure, atmeans
mat define ee_quaids=  r(expelas) 
mat list ee_quaids
*ee_quaids[1,5]
*           c1         c2         c3         c4         c5
*r1  1.0423552   .8535379   .9895998  1.0102794  1.0625566

estat compensated, atmeans
mat define ce_quaids=    r(compelas) 
mat list ce_quaids
/*ce_quaids[5,5]
            c1          c2          c3          c4          c5
r1  -.30148886   .03989174  -.01301219   .12109291   .15351639
r2   .07340152  -.49713825   .10226795    .1831701   .13829868
r3  -.05521117   .23869566  -.54724939   .10395399   .25981091
r4   .19699207   .16495332   .04021859  -.63345697   .23129299
r5   .27662907   .13826686   .11155543   .25663516  -.78308653*/


quiet quaidsce w1 w2 w3 w4 w5, anot(10) prices(p1 p2 p3 p4 p5) expenditure(expfd) demographics(nkids income) nolog nocensor
estat uncomp
mat define unce_quaidsce=  r(elas_u)
mat list unce_quaidsce

*unce_quaidsce[5,5]
*            c1          c2          c3          c4          c5
*r1  -.64534912  -.15534338  -.09821874  -.09442714  -.04195151
*r2  -.24199662  -.65231209   .04098162   .00599439  -.01645581
*r3  -.39310898   .05356852   -.6269222  -.10283058   .07329948
*r4   -.1433446  -.02419149  -.04168211   -.8437668   .04114715
*r5  -.07189021  -.06213448   .02285732   .03540848  -.98487215

estat exp
mat define ee_quaidsce=  r(elas_i)
mat list ee_quaidsce

*ee_quaidsce[1,5]
*           c1         c2         c3         c4         c5
*r1  1.0374038  .85562926  .99575379  1.0125469  1.0642629

estat comp
mat define ce_quaidsce=  r(elas_c)
mat list ce_quaidsce

/*ce_quaidsce[5,5]
            c1          c2          c3          c4          c5
r1   -.2944889   .03828702  -.01495156   .12098821   .15227914
r2   .04738565  -.49260972   .10965866   .18366453   .14374163
r3  -.05633521   .23942499  -.54699806   .10393621    .2597321
r4   .19910879   .16479941   .03958993  -.63351293   .23072391
r5   .28805403   .13650915   .10828034   .25640108  -.78561273*/



log close

