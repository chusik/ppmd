/*
 * Winbond W83627HF fast serial port driver for Linux 2.4.x
 *
 * Copyright (C) 2002 Tony Lindgren <tony@atomide.com>
 *
 * NOTE: In order to use this module, load the module and then set the 
 * serial port with a c.h2 Linuh"��x
�atomomoet te��coMh"��x
�atomoet tdH moet oh p(onyr oH,i@ t dr.cv�indgh�uh/*
 * W83 iV,Pp�6, L44.x
hor36(�phC
cosG�o���Щ�ToheH * acosG�o���Щ�veh c)et lhe�n pIu* /*
 * W8)4.x
hor36(�phCon tomodule a�"��x
�atomoet tdHr�tny Waco.Int Coh�uh/�.x
hosG* l6n(Co ta�inbon tomodule a�"��x
�atomomoet tony�� mond ta�yh�eH *
 * In ort drp(n tomodule aFNthe the module a4.+"��x
�atomoe3�cs sG�o" Iny tdH,io)n tony�u+fy Lindgren <tony@ ma 
 * acnt (oh7n�W8f�y )6/iWmond ta�yh�eH *
 * In ort drp(n tdH"r W�h ato use thi ne�der fo tomodul.�th2.�� mo)4.x
hor36(�phCoyialmon oh p(onyr�36H *
 * IiLn tomodult�r Coh"r * seright (C) *
 * NOTo,ith"��x
�atomoet tdHiomodul� Lend � Lin moiatonyy oh� * NOTE: Int f. uxmodus �� mo)6n thf@.sG .e.iLn tomodult�r *
 *
  thh�uh/�Tt �pE�p(n th�2+/.c�n Lindgren <tony@aa�tdH,in�aNpiLveu* /Io����serig .e.iL+�tdH,on oomaind os *
 *
  thh�uh/�Tto ten٥tdH.x
co(o,itdHeeyen tomodulermond W836ye nt f.r u�427��itdHtdH, l�h�uh/*
 * Wyfy Wup"��x
�atdHt ConydH�r.x
hoot)lvdeu* the�osG motddH�ܺ l�" Iny��� �/*
 *
  ConydH�r.x
h" . tdH4.r f� porto tomodult Lindgren <tony@afy Copyrigh then set the module a̝to)� ma 
como��x
�a��dH�r.x
h� Lend � ther fo tomodule����������������To, mo userial port f�yh�eH *
 * l/�7e�c, myaNt iVBonyri ** u* /e��x
�ac"��x
�atomoen��" Ion tomodule a�"��x
�at ith�eH *
 * Ic4.+" seriny .iL+�tdH,on tdH�#6�dH moet oh p(o,ifo tomodult�ue (Co ta�t fyh�eH *
 *
  thh7e�%xmond W836ye nt f.r u�4.+/. �Ty ddH�ܺ l�"��
h�/.ccrd � Lin o�2�t�.r Code�* m tdHtdH, lyr�.x
co(�phCcx
cm@V,u�"c"��x
�at Len�a�cosG�.x
hor36(Co ta��in/�I�.x
" *.ccrd � Liny  moeH�2 Lin o�27Withxmy+�/*
 *>inbon oh p(ony�y *
 * 
co�/�7nt ixmat iWuer f�e@udHdd th� Lend � ly Wf�r.h"r CoddH�ܺ l�i.er f��x
�atomom serightdH4.r 
 ** uddH�ܺ�us 
co�vux
cu*B�ne�der f�tn o)"��x
�at tdHton ode�*on Lin moiatonyy onyto ta�t fyppiLn tomodule�lder fo tomodul��ib2 port (�T02 Cond ta�yh�eH��ie� Lend � 
h�dHl� LenId\wiatonyy o * u�ib2 porto ton ode�*r*�h"��x
�at Cony�ϙg��dHe��r.x
hoot)lvdeu* the module�lo(C��x
�aNt iVBtot)lvdendgh2.x sG .e.iLn tomodulus �� mo)6n thf@.sG .e.end therial phCo ta�inbon tomodulerial port fl�U�r
 * m dr pigh .int fith"��der the moduh�#6�dddH�ܺ o(�Tve6n(Co ta�iny=xmyt Conyr fl, W836(� oddH�ܺ�.m>i. Co iVt (oh7e/��dr flv�fW�ydH�
  tonypiH@W����Tc��ia;dHsr��ۋ th� Lend � ce moduh�#�t Lend � cohis modul���x
�a@�َ�x
�atomomoet tony�� mond W836�inb^heѝ�ny�n o)"��x
�atomomoet t o)4.x
hor36(�phCoe/��e=(�T��in/�I�x
�af�p.�.xmnt dH�r.x
h� Linyh�eH *
 * NOTend taccrd ta�yh�eHv��)n tony�u+fy oiLn tomodule�4.x
 *.x
hond th� Lend � *
��x
�arigh2.6nײxmo)4iLn tomodultn Liny  p�epiend theh�Z�g�ia�*.@ue36(� oddH�ܺ�us 
c2ceHn�t with 
h� L44.x
hor36(�ph"��yh�eHvetoh2.�N_^hCp�to te�inb2.eH\f� ith�eHvu.int fint fi.x
ho(Co ta�th27HF fa�to ta��Tto tp�sG�o����ɚif��r  tony@ny modul��e�toh�eH *
 * In ort drp(n the module an\o" *
 *
  thh".�yh�eH *
 * seH�\"��x
�atomoetdH�r.x
h�/.ccs �Ty ddH�ܺ l�dgh aiW8�p(n then set the modulenT�v�*
��x
�arigh2.6nײxmo���Щ�/*
 *)l Conyr o��dH42s portnxn��G�h\�2ue (Co tond ta�yh"r ux
het oh p(o,iaifa�ton oh\fyue� /xmo)4.+)2.end the module�l#6�r co iV*�der f�yh�eH *
 * In ort dHvetoh2.�N_
ue (Co tond ta�yh�eH /�h�)4.+fa�s Comy��� *�f@.+de36H!ig��/4 /*
 * NOT�gh2.6n�yh7�r tond tan��yh"r * Wytherial 2 CohCcx
cmo userial Linr miLn tomodule a�"��x
�atomo mnry��u�itdHtdH, l6(� ** lh"Nndd LenId\wiHu,n���H*)4.+de36H!igr lmon oh p)4.+"��x
�atomoet tdHpther fo tomodule/��dHemyint Lend � *
�����coMh"��x
�atomoeh��>
ciW�N]�end ta�ۅ� m . if�pu��r� lher fo tomodult (C) dH�I�x" ord ta�* lh�
h2.e�e seh\"cG2i/�7ne�der fo, lyr�.x
 *�pithe lmyt Conyr * Wat 
com>,��ytddH�ܺ oho.x
ux"n myint Leh"��y u�et on moiat 
com>, a��de Co.��"��xm thh�ony��.iW836(� oddH�ܺ�us 
co�vux
hor36(�ph"��yh�eH�r�� 
h� LndHt LindgrCot)/rnt tainbcr .iL+�tdH,on tomodul�^//��r f�#ddHF2 Lin o���dHr�tny 
co"�����coMh"��x
�Vѝ��k.ith� Lend �pt moh�eH@i . .igrn o, tdHFe36(�conyr.xmy+�tdH�r.x
hoot)lvdeeH���ek.int figh2.cvenyr fl, Lent f.ccڕ/�sto ta��Tt fa ccdep��ytoh�uh/*
 * W8ֆ�Lenx
 *
 * ac� sr��ۋ o)"��x
�atomoM36ny�2 tdHFe �TQf�yh�eH port Lindgren <tony@tdH�����xmodus �N@ .i�ڝ�n�C�etdH�gr dr * WT�2 deHFe����T.+/ncoe36(�Nt�8gr lmon oh p��(� m>*) L�dHet oh p(o,iton tomodult tnx
 *
 sLeHveHv�rinbon tomodul�^//�.6n(Co ta�iny=  l27��itdHtdH, lio.Iy=y fialx
hor36H *
 * seH�\"��x
�at tdHton ode�* oomaind osN��dHt Cond ta�yh�eH�en set th� /ddH�ܺ onyr ort driverial port f@de�*
 azrightdH�r.x
hoot)lvdeeH*�rd � mo6d on th� /e3, Liny th\ԋsentde/�7nt ixmat iWu.�4.+/.ccr dre�*r 
 * m thh� /xmo)4.+)2.r�427��ia�nb"c"��x
�atdHthen serial Linr miLn tomodult (C) dH�r.x
hon moiat ith�eH *
 * In tdH, Ln tdHt)4.+f��yh�eH *
 * Ionyy oix sG .e. iV�int fialx�0
 * /*
 * W2 Len(Co ta��HFNt iV�int fialx�0
 * /*
 * W8ֆ�.6n o��ith�eH� lm sG .e.igyuComodus �� mo)6@�t fy W8�c�L�x
�al
cony Lent Coh th�;der f�yh�enٲi.er f��x
hor36H�der f�yh�enٲi.er f��x
hor36(�phCo, l������coMh"��x
�atomoe (Co ta��TtddH�ܺ o(�Tve6n(Com>, a��de Co.I����.@lm . Coh talpiend the modu�)J��.@2.e�eH��tdH, Ln tdHt)4.+f��t)2 Coh�e/�7)t �c��/*
 *c�#�t Coh .iLn tomodule��c�conyre6ny tdH,io)n ton oho.x
hon moiat ith�eH *
 * In ort d mywia 
como��.ia�totdH�r.x
h�/.ccs �Ty ddH�ܺ /*
 * Wy�p�tn 
cosNtdeyty�;�inbgh"r WiLn tomodultdr�xmy+�.+de36H!ig.�tdH,nb�cJ�pIx
Fe�, f@dHf)�(inb��r W8to6n(Com>, a��de Co.cvenyr fo, lyr�.x
hond th� Lend �ptdHtn�ccs lhe�x
hor36(�phCo���Щ�eH�T ia;dHsr��ۋ seH�\"��x
�atdH,io)4iue����eH��tdH, ton oh�/.ccr dre�*r*�h"��x
�atomonyriLn tomodule���en moiat ten�aa.e�end therial Lent f.ccڕe� yM�eHw
h" . Len�a�o, lh\/� *
 Lend � 
como��y L4.+faind osG .i. Len�a�t ph"ny o iVt (oh� * NOTE: In ord ta�yh�eH�r�� 
h� Lend � ph2.4.x
 *
 * sG .e.ia�tdH,on tomodulthe module af�ydrp(n(Co ta�iny=xmyt Cond ta�yh"r uxgrCot)/rn o��x
�at Cony�ϙgher feH"c" minyM36k钼"r W836de *tot)lvdeu* the moduh�ony��x
hon moiat 
co(o,itdHeH"c" Inyt Cony�t iVt (oh7e/��dr flder fo tomodultdrp(ndgren <tdHtdH, lonbeHv
��x
�arigh2.6ny�t ifo,i.end ther fo tomodule *tot)l�ux�c6ux
��x
�����;pIxm W836ye 
 * /*
 * Wyrigher feH"nd ta�tdH,on ta�tdH,io)"��x
�at 
com>, a��de Coh"r * seright (oh����Tc��inbet �Q)4.+)2.�� 
  th� /*
 * Wyfy Wup"��dHe Ln tdHt)4.+f��t�"r W. Lent figher feH"�/�<tot)4.+fy oh�eH@(C��x
�aNt iV*fy Lent fialx�0
cos *
 * u� lm W2 Len(Co ta�t fy W836use thi lmoderiao)"��x
�atomonb2.eH\with�eHeH�r�� 
h� Lendgh2.end the module�eH�r * Wy� sG�o oaT�yh�ento ta�yh2.6ny�t ifo,i.end ther tdH, tdH, Len�a�cosG�.x
hor36(�ph"��"r In modus �N.x
xm>tac�flmon oh p.�tdH,nb�cJ�pIx
Fe���in/�I�x
�afc�xuI�� *
 Lend �cnt (oh7n�W83 my+�c�)4ie�inb2.eH\fac��.x
 *�pIxmoduh".�ydrp(n(Co ta�"�f��x
�y�ux
hor36H�
c�.+he�f� *.�et tony�� mo)"��x
�at Conyy W8�7iL4.x
 * mo �x
�afW( W836n tomoduleH portdH,ia;;42u+ porto ton ode�* l/�@�g.x
hon moiat 
co)�(inb�c�Nn\wi.xm drd .iLnd th\ԋsentde/�7nt Coh��L4inײ2�LٲH�Ln tomodult 
como�t)l 
  tonypiH@W����Tc��ith�eH *
 *
  they oh�6�ܺin tdHFe36(�conyr.xmy+�tflve6n(Co ta�e�ۋ seH, �ghtdH/e3����f�yh�ILn tdH� l�dr uldgr Ind *)2 lfe/�ddH�ܺ .iadH�r�� 
h�/.ccd �cosN��y0uerial 
  th\ԋsentdH, lu, Lr nt (oh7e/��dri.x
i
io)n ton oho.x
u.@��r.6n(Com>, a��de Coh"r * seright (HC��xmo)4.+)2.4.x
 *
 * Ionyy oix sG ta�yt Cony�ϙgh�eH�r�� 
h� Lendgh2.endgh2.end the modulenx
 ddH�ܺ o(�T02 Cond ta�yh�׷�e��omon oh p(C
cot �tony��dHtep�+d Lend � *
��ddH�ܺ�ywia)l#6�f@de�*
 al
co)" Ix m .iy��+(�fypp.xmodu* l6n(�f��x
h�/.ccs �Ty ddH�ܺ oomonb�����coMh"r * seright mo iVt (oh�t Le�xf�uf��x
�at Conyy W8�ddH�ܺ .iadH�r�� 
h�/.ccڕ�n(Co ta�t fyppiHۋm2.x
�atonb2.eH\fcrd ta��ct /*
 * W(�Tve6n(�conyr.xmy+/yto iV
 *
ueriaG��x
�����;pIxm sG�on tomodulthe module a�"��x
�atomoet tdH moet oh p(o,iton tomodH*�iaomodulu*B�ne�der f�yh�en serial pg.x
ho.int figh2.ccr dre�** sG *�pIxmoduh"��f� �tdH, Cond ta�yh"r ue����main moiatonyy onyto ta�th2 moM6ptddH�ܺ lonb�cJtonddH�ܺW836H!i.�e@ . �Ty dddH�ܺ o(��y 
co�/�eH@W�����coMh"��x" ord ta�ydeh"��
h�/.ccrde.x
hond th� Lend � nt (C) 20e Ln tdH"r W�h ly Wf��to tomodulenx
 ddH�ܺ l�"o use inb"��x
�����;pI6n(�conyr.xmy+�/*
 ** /*
 * W8LinyeHs Comyt Conyy W8�cJ��ixntdHth"r ux�v�2>�" ta set the module a�"��x
�at o��y�t Conyr  tony@ *8oto ta��Toomaind osmodus ��Щ� *
hor36H���Tc��tdH@W��ph�t if@.+de3����f�#dgre�wif��dHtdH, lu* lmode�*tdH,ctherial port f)2 Linuh"��x
��HsNu* lh"r Ixmy+f�2 Lr nt (oh7e/��dr ton od .h2.�� mo6d\wia.x
u.@u* mo����serig iLn tomodulther�����Co��.�N_^hCpiat ith�eH *
 * In ort drp(n(Co ta�f���.iWLn tdH,�,C��d .iL+�toh�eH"��x
h�/.cc" modul���x
�atomoeh��>
cinb2.eH\with�eH *
 * In Linu*ܧcGyde��Liny  porto tomodult�r tdHton ode�* W8
F 
 ** sG * NOx��ddH�ܺ�ywia.e��#�rp(co���Щ�Toot��yh2.4.x
u.�4.+/.ccr dre�*��dddH�ܺ�us �� *�fW83�r ytot)"��x
�atomoe�x
xmyint (oh7e/��dritdH+
���C��x
�aNt ith�eHvu.int fi.x
hond th�.mywia 
comain 
comodH�r.x
hoot)lvdeeH*��sG�deHFe3r Wfyu.�4.r Code�* m tdHtdH, lyr�.x
 *ܺ ** serial o)"��x
�atomoe�t coherindgh2.ccr drend ta���H*)4.+de36H!igQi.end ta�u* lmode�*tdH,on tomo mnry��uh/��e=(� tonyr oaT�yiV+de��y *
 * 
 tdH,ixm Cohe�der f�tho.i/*
 * W8
F 
 ** NO�ush f)42 modus �� h��
h�/.ccrd WithxntdH@i ** ux
hor36(�phCon o�2 Tony Lindgren <lve6n(Co ta�"�fWup�Tohereny tdH,io)62 L+dHToomonb��th\ԋsentdHpwFd �r m .iy��+ dgr Ind *)2 lf��ekh�f�y�"c" Id\wiVBto tux�ve�ph"��4.x
 tdH,ix set the module a�"��x
�at tn�.xmnyrinbon tomodule au+ ��
  thf@.sG�se thh7e�%xmonb�pindddH�ܺ oonyy W83 
co iVt (on m . if�pu�f@d\winײiV��#dHueriaG	f�luh��>
ciW�����coMh"��x
�atomoM6ptddH�ܺ lm t d\���x
�al�Cor CoddH�ܺ l�y W8�cJ��ixnu,n(Co ta�"�f��x
�y�uxn�e���DydH�ܺ l(�ph"��y Lindgren <�.x
��HsNxt Conyder fo, L+dH4Fe����a .i
  they du**t"��.+ my W2 Len(Co ta�t fy W8f�y )6/iWmo te�� ** u* the etoh�eHvux
he�@ 
cord ta�yh�eH ph"���(� tonyr�.iLr36H@"��x
�atomoetot)lvdH�C��xu,c�o y� /�
co)�(� ** s userial pordrdr3,�" moeth\�i. userial L44/*
  tdH"c" Iny� /4 /*
 * W8xpiHu,�eH�8���x
honyfeh7en o.Intot�x�tdHte (itdHhmor * u.ey ooma . e ne@n cc�77et l/��yh�n ph�conypiH@W����Tc��is modul���xmodus �� mo)"��x
�atomoet tp�xp� LendH�onbon moduh�ony��.4Fe����a .i
  they mo �x
�a��minb�FLriveriat lon p).+/�uetdrp(ndgren Ln tdH,�, l�y W8�c� Co mo6n(Com>, a��de Cond ta�yh�reriaG6�dH moet oh p(o,iton tomodultny m thherial iVt (o,iton tomodule ser fl
h" .if�ton tomodul�x
�af��x
�aNtder fo tomodult�r tomodH*�ig�/�<(Comain 
hȲ
cony Lent fifo userial L44/*
  tdH"c" Iny+ mytot)yײxmo dT��rder fo tomode��@.x
hothe@n cc�77eh2yue�f��* lh".�yy�t ifo tomodultw