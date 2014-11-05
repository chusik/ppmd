/*
 * Winbond W83627HF fast serial port driver for Linux 2.4.x
 *
 * Copyright (C) 2002 Tony Lindgren <tony@atomide.com>
 *
 * NOTE: In order to use this module, load the module and then set the 
 * serial port with a c.h2 Linuh"Œx
®atomomoet te…™coMh"Œx
®atomoet tdH moet oh p(onyr oH,i@ t dr.cv¥indghuh/*
 * W83 iV,Pp6, L44.x
hor36(phC
cosGÏo®ü·Ğ© ToheH * acosGÏo®ü·Ğ© veh c)et lheÑn pIu* /*
 * W8)4.x
hor36(phCon tomodule aŒ"Œx
®atomoet tdHrŒtny Waco.Int Cohuh/Œ.x
hosG* l6n(Co ta…inbon tomodule aŒ"Œx
®atomomoet tony½· mond ta×yh¶eH *
 * In ort drp(n tomodule aFNthe the module a4.+"Œx
®atomoe3cs sGÏo" Iny tdH,io)n tonyúu+fy Lindgren <tony@ ma 
 * acnt (oh7náW8f×y )6/iWmond ta×yh¶eH *
 * In ort drp(n tdH"r WÌh ato use thi ne‹der fo tomodul.…th2.½· mo)4.x
hor36(phCoyialmon oh p(onyrá36H *
 * IiLn tomodultúr Coh"r * seright (C) *
 * NOTo,ith"Œx
®atomoet tdHiomodulÁ Lend Î Lin moiatonyy ohº * NOTE: Int f. uxmodus ½· mo)6n thf@.sG .e.iLn tomodultúr *
 *
  thhuh/‹Tt ÚpEáp(n th€2+/.cÜn Lindgren <tony@aaŒtdH,inÙaNpiLveu* /Io®ü·Ïserig .e.iL+¥tdH,on oomaind os *
 *
  thhuh/‹Tto tenÙ¥tdH.x
co(o,itdHeeyen tomodulermond W836ye nt f.r uŒ427†¥itdHtdH, lšhuh/*
 * Wyfy Wup"Œx
®atdHt ConydHúr.x
hoot)lvdeu* theÑosG motddH—Üº l—" Iny·ÏÚ ï©/*
 *
  ConydHúr.x
h" . tdH4.r fá porto tomodult Lindgren <tony@afy Copyrigh then set the module aÌto)Ï ma 
comoŒx
®a©‹dHúr.x
h Lend Î ther fo tomodule¥———————————————To, mo userial port f×yh¶eH *
 * l/‹7eÏc, myaNt iVBonyri ** u* /eŒx
®ac"Œx
®atomoenµ—" Ion tomodule aŒ"Œx
®at ith¶eH *
 * Ic4.+" seriny .iL+¥tdH,on tdHÚ#6ÔdH moet oh p(o,ifo tomodultúue (Co ta…t fyh¶eH *
 *
  thh7e¥%xmond W836ye nt f.r uŒ4.+/. ‹Ty ddH—Üº l—"Œ
hÈ/.ccrd Î Lin o™2×tÖ.r Code†* m tdHtdH, lyrÙ.x
co(phCcx
cm@V,u¥"c"Œx
®at LenÙaÜcosGñ.x
hor36(Co ta…™in/·IŒ.x
" *.ccrd Î Liny  moeH·2 Lin o™27Withxmy+ï©/*
 *>inbon oh p(ony¥y *
 * 
co™/‹7nt ixmat iWuer f©e@udHdd th Lend Î ly Wf×r.h"r CoddH—Üº lúi.er fŒx
®atomom serightdH4.r 
 ** uddH—Üºus 
co™vux
cu*Bÿne‹der f×tn o)"Œx
®at tdHton ode†*on Lin moiatonyy onyto ta…t fyppiLn tomodule×lder fo tomodulÁºib2 port (‹T02 Cond ta×yh¶eH‹—ie Lend Î 
hÈdHlÜ LenId\wiatonyy o * uºib2 porto ton ode†*r*€h"Œx
®at Cony¼Ï™gŒdHe©Ïr.x
hoot)lvdeu* the module×lo(CŒx
®aNt iVBtot)lvdendgh2.x sG .e.iLn tomodulus ½· mo)6n thf@.sG .e.end therial phCo ta…inbon tomodulerial port flÏUÏr
 * m dr pigh .int fith"Œder the moduhÚ#6ÔdddH—Üº o(‹Tve6n(Co ta…iny=xmyt Conyr fl, W836(‹ oddH—Üº.m>i. Co iVt (oh7e/…‹dr flv§fW×ydHŒ
  tonypiH@WŒTcŒia;dHsr†¥Û‹ th Lend Î ce moduhÚ#ñ®t Lend Î cohis modulÁŒx
®a@‹ÙŒx
®atomomoet tony½· mond W836…inb^heÑÔnyÿn o)"Œx
®atomomoet t o)4.x
hor36(phCoe/…‹e=(‹T…™in/·IŒx
®afÜp.Œ.xmnt dHúr.x
h Linyh¶eH *
 * NOTend taccrd ta×yh¶eHv·Ï)n tonyúu+fy oiLn tomoduleá4.x
 *.x
hond th Lend Î *
Œx
®arigh2.6n×²xmo)4iLn tomodultn Liny  p©epiend thehZêg‹iaÜ*.@ue36(‹ oddH—Üºus 
c2ceHnÙt with 
h L44.x
hor36(ph"Œyh¶eHvetoh2.½N_^hCp©to te…inb2.eH\fÜ ith¶eHvu.int fint fi.x
ho(Co ta…th27HF faŒto ta…‹Tto tpßsGÏo®ü·ĞÉšifÚÏr  tony@ny modulÁ×e¥toh¶eH *
 * In ort drp(n the module an\o" *
 *
  thh".×yh¶eH *
 * seHÔ\"Œx
®atomoetdHúr.x
hÈ/.ccs ‹Ty ddH—Üº l—dgh aiW8•p(n then set the modulenT‹vÚ*
Œx
®arigh2.6n×²xmo®ü·Ğ© /*
 *)l Conyr oŒdH42s portnxnÙñGŒh\¼2ue (Co tond ta×yh"r ux
het oh p(o,iaifaŒton oh\fyue /xmo)4.+)2.end the module×l#6Ôr co iV*‹der f×yh¶eH *
 * In ort dHvetoh2.½N_
ue (Co tond ta×yh¶eH /½hÏ)4.+fa‹s Comyÿ½· *§f@.+de36H!ig/4 /*
 * NOTêgh2.6n×yh7Ûr tond taná×yh"r * Wytherial 2 CohCcx
cmo userial Linr miLn tomodule aŒ"Œx
®atomo mnryºu¥itdHtdH, l6(‹ ** lh"Nndd LenId\wiHu,n¥…™H*)4.+de36H!igr lmon oh p)4.+"Œx
®atomoet tdHpther fo tomodule/…‹dHemyint Lend Î *
Œ¥…™coMh"Œx
®atomoehñ®>
ciWïN]½end ta¥Û…‹ m . ifÜpu‰úr· lher fo tomodult (C) dHñIŒx" ord ta×* lhÚ
h2.ee seh\"cG2i/‹7ne‹der fo, lyrÙ.x
 *Üpithe lmyt Conyr * Wat 
com>,Ô×ytddH—Üº oho.x
ux"n myint Leh"Œy u‹et on moiat 
com>, aš‹de Co.½·"Œxm thhÚonyŒ.iW836(‹ oddH—Üºus 
co™vux
hor36(ph"Œyh¶eHúr—Ô 
h LndHt LindgrCot)/rnt tainbcr .iL+¥tdH,on tomodul¡^//·Ïr f×#ddHF2 Lin o™ŒdHrŒtny 
co"Œ¥…™coMh"Œx
®VÑÔúk.ith Lend Îpt moh¶eH@i . .igrn o, tdHFe36(Úconyr.xmy+¥tdHúr.x
hoot)lvdeeH·×Ôek.int figh2.cvenyr fl, Lent f.ccÚ•/‹sto ta…‹Tt fa ccdep©Ïytohuh/*
 * W8Ö†×Lenx
 *
 * acñ® sr†¥Û‹ o)"Œx
®atomoM36ny¨2 tdHFe ‹TQf×yh¶eH port Lindgren <tony@tdHºùºŒxmodus ½N@ .iÏÚÔnÔCĞetdHêgr dr * WT×2 deHFe¥———T.+/ncoe36(ÚNtú8gr lmon oh p§( m>*) L‹dHet oh p(o,iton tomodult tnx
 *
 sLeHveHvÏrinbon tomodul¡^//·.6n(Co ta…iny=  l27†¥itdHtdH, lio.Iy=y fialx
hor36H *
 * seHÔ\"Œx
®at tdHton ode†* oomaind osNŒdHt Cond ta×yh¶eH‹en set th /ddH—Üº onyr ort driverial port f@de†*
 azrightdHúr.x
hoot)lvdeeH*€rd Î mo6d on th /e3, Liny th\Ô‹sentde/‹7nt ixmat iWu.Œ4.+/.ccr dre†*r 
 * m thh /xmo)4.+)2.rŒ427†¥ianb"c"Œx
®atdHthen serial Linr miLn tomodult (C) dHúr.x
hon moiat ith¶eH *
 * In tdH, Ln tdHt)4.+fÜ×yh¶eH *
 * Ionyy oix sG .e. iV×int fialx®0
 * /*
 * W2 Len(Co ta…é¨HFNt iV×int fialx®0
 * /*
 * W8Ö†.6n oŒith¶eHº lm sG .e.igyuComodus ½· mo)6@…t fy W8‹cñ®LéŒx
®al
cony Lent Coh th€;der f×yh¶enÙ²i.er fŒx
hor36HÏder f×yh¶enÙ²i.er fŒx
hor36(phCo, l©Œ¥…™coMh"Œx
®atomoe (Co ta…‹TtddH—Üº o(‹Tve6n(Com>, aš‹de Co.I®ü·Ğ.@lm . Coh talpiend the moduå)J¥Û.@2.e²eH‹ÔtdH, Ln tdHt)4.+fÜ×t)2 Coh¶e/‹7)t Úc¶²/*
 *c¶#ñt Coh .iLn tomodule¥—c²conyre6ny tdH,io)n ton oho.x
hon moiat ith¶eH *
 * In ort d mywia 
comoŒ.ia®totdHúr.x
hÈ/.ccs ‹Ty ddH—Üº /*
 * Wyÿp‹tn 
cosNtdeyty;…inbgh"r WiLn tomodultdrŒxmy+Œ.+de36H!ig.¥tdH,nbÏcJ¥pIx
Fe¥, f@dHf)Æ(inb²Ïr W8to6n(Com>, aš‹de Co.cvenyr fo, lyrÙ.x
hond th Lend ÎptdHtnÔccs lheÑx
hor36(phCo®ü·Ğ© eH‹T ia;dHsr†¥Û‹ seHÔ\"Œx
®atdH,io)4iue¥…™ˆeH‹ÔtdH, ton ohÈ/.ccr dre†*r*€h"Œx
®atomonyriLn tomodule†¥¶en moiat tenÙaa.e²end therial Lent f.ccÚ•e¥ yM‹eHw
h" . LenÙaÜo, lh\/‹ *
 Lend Î 
comoŒy L4.+faind osG .i. LenÙaÜt ph"ny o iVt (ohº * NOTE: In ord ta×yh¶eHúr—Ô 
h Lend Î ph2.4.x
 *
 * sG .e.iaŒtdH,on tomodulthe module af×ydrp(n(Co ta…iny=xmyt Cond ta×yh"r uxgrCot)/rn oŒx
®at Cony¼Ï™gher feH"c" minyM36ké’¼"r W836de *tot)lvdeu* the moduhÚonyŒx
hon moiat 
co(o,itdHeH"c" Inyt Conyt iVt (oh7e/…‹dr flder fo tomodultdrp(ndgren <tdHtdH, lonbeHv
Œx
®arigh2.6ny¨t ifo,i.end ther fo tomodule *tot)lúux®c6ux
Œx
®ü·ĞÉ;pIxm W836ye 
 * /*
 * Wyrigher feH"nd taŒtdH,on taŒtdH,io)"Œx
®at 
com>, aš‹de Coh"r * seright (ohºŒTcŒinbet ÚQ)4.+)2.½½ 
  th /*
 * Wyfy Wup"ŒdHe Ln tdHt)4.+fÜ×t·"r W. Lent figher feH"/Ô<tot)4.+fy oh¶eH@(CŒx
®aNt iV*fy Lent fialx®0
cos *
 * uº lm W2 Len(Co ta…t fy W836use thi lmoderiao)"Œx
®atomonb2.eH\with¶eHeHúr—Ô 
h Lendgh2.end the module©eHúr * Wyÿ sGÏo oaT×yh¶ento ta×yh2.6ny¨t ifo,i.end ther tdH, tdH, LenÙaÜcosGñ.x
hor36(ph"Œ"r In modus ½N.x
xm>tacÔflmon oh p.¥tdH,nbÏcJ¥pIx
Fe¥…™in/·IŒx
®afcŒxuI…‹ *
 Lend Îcnt (oh7náW83 my+ïcá)4ie…inb2.eH\facéÔ.x
 *ÜpIxmoduh".×ydrp(n(Co ta…"§fŒx
®yux
hor36HÏ
cŒ.+hefÜ *.…et tony½· mo)"Œx
®at Conyy W8‹7iL4.x
 * mo Œx
®afW( W836n tomoduleH portdH,ia;;42u+ porto ton ode†* l/·@êg.x
hon moiat 
co)Æ(inbÏcñNn\wi.xm drd .iLnd th\Ô‹sentde/‹7nt CohÜL4in×²2éLÙ²H‹Ln tomodult 
como®t)l 
  tonypiH@WŒTcŒith¶eH *
 *
  they ohÚ6áÜºin tdHFe36(Úconyr.xmy+¥tflve6n(Co ta…e¥Û‹ seH, êghtdH/e3®¥‹—f×yh¶ILn tdHº l—dr uldgr Ind *)2 lfe/‹ddH—Üº .iadHúr—Ô 
hÈ/.ccd ÎcosN‹Úy0uerial 
  th\Ô‹sentdH, lu, Lr nt (oh7e/…‹dri.x
i
io)n ton oho.x
u.@ÿÏr.6n(Com>, aš‹de Coh"r * seright (HCŒxmo)4.+)2.4.x
 *
 * Ionyy oix sG taşyt Cony¼Ï™gh¶eHúr—Ô 
h Lendgh2.endgh2.end the modulenx
 ddH—Üº o(‹T02 Cond ta×yh¶×·‹e¥—omon oh p(C
cot ÚtonyŒdHtepß+d Lend Î *
ŒddH—ÜºÔywia)l#6Æf@de†*
 al
co)" Ix m .iy¯+(§fypp.xmodu* l6n(fŒx
hÈ/.ccs ‹Ty ddH—Üº oomonbŒ¥…™coMh"r * seright mo iVt (oht Le©xfÏufŒx
®at Conyy W8‹ddH—Üº .iadHúr—Ô 
hÈ/.ccÚ•Ïn(Co ta…t fyppiHÛ‹m2.x
®atonb2.eH\fcrd ta×Üct /*
 * W(‹Tve6n(Úconyr.xmy+/yto iV
 *
ueriaGŒx
®ü·ĞÉ;pIxm sGÏon tomodulthe module aŒ"Œx
®atomoet tdH moet oh p(o,iton tomodH*€iaomodulu*Bÿne‹der f×yh¶en serial pg.x
ho.int figh2.ccr dre†** sG *ÜpIxmoduh"ŒfÜ ŒtdH, Cond ta×yh"r ue¥…™ˆmain moiatonyy onyto ta…th2 moM6ptddH—Üº lonbÏcJtonddH—ÜºW836H!i.…e@ . ‹Ty dddH—Üº o(Ïy 
co™/¶eH@WŒ¥…™coMh"Œx" ord ta×ydeh"Œ
hÈ/.ccrde.x
hond th Lend Î nt (C) 20e Ln tdH"r WÌh ly Wf©Œto tomodulenx
 ddH—Üº l—"o use inb"Œx
®ü·ĞÉ;pI6n(Úconyr.xmy+ï©/*
 ** /*
 * W8LinyeHs Comyt Conyy W8‹cJ¥‹ixntdHth"r ux®vš2>Ï" ta set the module aŒ"Œx
®at oŒyt Conyr  tony@ *8oto ta…‹Toomaind osmodus ½·Ğ©  *
hor36HŒTctdH@Wpht if@.+de3®¥‹—f×#dgre×wifÜ×dHtdH, lu* lmode†*tdH,ctherial port f)2 Linuh"Œx
®²HsNu* lh"r Ixmy+fÜ2 Lr nt (oh7e/…‹dr ton od .h2.½· mo6d\wia.x
u.@u* mo®ü·Ïserig iLn tomodultherŒ¥…™èCoŒ.½N_^hCpiat ith¶eH *
 * In ort drp(n(Co ta…f®ü·.iWLn tdH,Ô,C¼Àd .iL+¥toh¶eH"Œx
hÈ/.cc" modulÁŒx
®atomoehñ®>
cinb2.eH\with¶eH *
 * In Linu*Ü§cGyde¥—Liny  porto tomodultúr tdHton ode†* W8
F 
 ** sG * NOxŒddH—ÜºÔywia.e¥Û#Ïrp(co®ü·Ğ© Toot¥§yh2.4.x
u.Œ4.+/.ccr dre†*ŒdddH—Üºus ½· *§fW83Šr ytot)"Œx
®atomoe©x
xmyint (oh7e/…‹dritdH+
®ü·CŒx
®aNt ith¶eHvu.int fi.x
hond th.mywia 
comain 
comodHúr.x
hoot)lvdeeH*€‹sGÏdeHFe3r Wfyu.Œ4.r Code†* m tdHtdH, lyrÙ.x
 *Üº ** serial o)"Œx
®atomoet coherindgh2.ccr drend ta¥…™H*)4.+de36H!igQi.end ta¥u* lmode†*tdH,on tomo mnryºuh/…‹e=(‹ tonyr oaT×yiV+de†¥y *
 * 
 tdH,ixm Cohe‹der f×tho.i/*
 * W8
F 
 ** NOƒush f)42 modus ½· hŒ
hÈ/.ccrd WithxntdH@i ** ux
hor36(phCon o™2 Tony Lindgren <lve6n(Co ta…"§fWup‹Tohereny tdH,io)62 L+dHToomonb¥…th\Ô‹sentdHpwFd Îr m .iy¯+ dgr Ind *)2 lf×Ôekhf×y·"c" Id\wiVBto tux®ve¥ph"Œ4.x
 tdH,ix set the module aŒ"Œx
®at tnÔ.xmnyrinbon tomodule au+ ©Œ
  thf@.sGÏse thh7e¥%xmonb¥pindddH—Üº oonyy W83 
co iVt (on m . ifÜpu‰f@d\win×²iVÔ×#dHueriaG	f×luhñ®>
ciWŒ¥…™coMh"Œx
®atomoM6ptddH—Üº lm t d\ºŒx
®al³Cor CoddH—Üº l¶y W8‹cJ¥‹ixnu,n(Co ta…"§fŒx
®yuxnÙe†¥ßDydH—Üº l(ph"Œy Lindgren <Ô.x
®²HsNxt Conyder fo, L+dH4Fe†¥‹—a .i
  they du**t"Œ.+ my W2 Len(Co ta…t fy W8f×y )6/iWmo te…‹ ** u* the etoh¶eHvux
he¥@ 
cord ta×yh¶eH ph"Œ©(‹ tonyrŒ.iLr36H@"Œx
®atomoetot)lvdH·CŒxu,cÔo y /Ì
co)Æ(‹ ** s userial pordrdr3,·" moeth\¼i. userial L44/*
  tdH"c" Iny /4 /*
 * W8xpiHu,¶eH‹8©Œx
honyfeh7en o.Intot½xtdHte (itdHhmor * u.ey ooma . e ne@n ccÿ77et l/·×yh¶n phÚconypiH@WŒTcŒis modulÁŒxmodus ½· mo)"Œx
®atomoet tpŒxp LendHÚonbon moduhÚonyŒ.4Fe†¥‹—a .i
  they mo Œx
®a©‹minb¥FLriveriat lon p).+/¶uetdrp(ndgren Ln tdH,Ô, l—y W8‹cÚ Co mo6n(Com>, aš‹de Cond ta×yh¶reriaG6ÔdH moet oh p(o,iton tomodultny m thherial iVt (o,iton tomodule ser fl
h" .if×ton tomodulŒx
®afŒx
®aNtder fo tomodultúr tomodH*€ig¥/Ô<(Comain 
hÈ²
cony Lent fifo userial L44/*
  tdH"c" Iny+ mytot)y×²xmo dTÏrder fo tomode†¥@.x
hothe@n ccÿ77eh2yue¥f©×* lh".×yy¨t ifo tomodultw