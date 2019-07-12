dm out 'clear';
dm odsresults 'clear';
dm log 'clear';

libname box "C:\Users\Sarah\Dropbox\CE_SarahZhang\Data";
data a0;
merge box.demo box.dxx box.dxx_s box.bmx box.osq box.paq box.paq2 box.alq box.bpq box.diq box.mcq 
		box.smq box.whq ;
by seqn;
run;

%macro dats(dat);
data &dat.0;
merge box.demo_&dat box.dxx_&dat box.dxx_&dat._s box.bmx_&dat box.osq_&dat box.paq_&dat box.paq2_&dat box.alq_&dat 
		box.bpq_&dat box.diq_&dat box.mcq_&dat box.smq_&dat box.whq_&dat ;
by seqn;
run;
%mend dats;
%dats(b);
%dats(c);
%dats(d);

*modify variables before put together;
data a0;  set a0;  
sdmvpsu1=sdmvpsu;
MEC8YR=wtmec4yr/2;
mcq160m=mcq160I;
whq060=whd060;
run;

data b0;  set b0;  
sdmvpsu1=sdmvpsu+10;
MEC8YR=wtmec4yr/2;
ALQ100=ALD100;
run;

data c0;  set c0;  
sdmvpsu1=sdmvpsu+20;
MEC8YR=wtmec2yr/4;
alq100=alq101;
run;

data d0;  set d0;  
sdmvpsu1=sdmvpsu+30;
MEC8YR=wtmec2yr/4;
alq100=alq101;
run;

*creat separate datasets;
%macro datax(dat,num);
data &dat.&num;
set &dat.0;
where _MULT_=&num or _mult_ = .;
run;
%mend datax;
%macro sets;
%do i=1 %to 5;
	%datax(a,&i);
	%datax(b,&i);
	%datax(c,&i);
	%datax(d,&i);
	%end;
%mend sets;
%sets;

*combine datasets according to _mult_;
%macro comb;
%do i=1 %to 5;
	data set&i;
	set a&i b&i c&i d&i;
	run;
	data box.set&i;
	set set&i;
	keep seqn sddsrvyr riagendr ridageyr ridreth1 dmdeduc2 mec8yr sdmvpsu1 sdmvstra dxdtofat dxdtobmd _mult_ 
			bmxwt bmxht bmxbmi bmxwaist osq010a osq010b osq010c OSD030AA OSD030Ab OSD030Ac 
			OSD030BA OSD030BB OSD030BC OSD030BD OSD030BE OSD030BF OSD030BG OSD030BH OSD030BI OSD030BJ 
			OSD030CA OSD030CB OSD030CC OSD030CD OSD030CE OSD030CF OSD030CG OSD030CH OSD030CI OSD030CJ
			OSQ060 OSQ070 PAQ050Q PAQ050U pad080 pad120 pad160 paq180 pad440 pad460 paq560 duratq metscor
			alq100 alq120q alq120u alq130 bpq020 bpq080 diq010 mcq010 mcq053 mcq160c mcq160f mcq160m mcq220 smq020 smq040 
			whd020 whd050 whq060 whq070 whd140 whd160;
	run;
	%end;
%mend comb;
%comb;

*creat datasets and save;
%macro makedata;
%do i=1 %to 5;
data set0&i;
set box.set&i;

fract=0;
if (osq010a=1 and ((ridageyr-OSD030AA in (0:1) and OSD030AA^=.) or (ridageyr-OSD030Ab in (0:1) and OSD030Ab^=.) 
				or (ridageyr-OSD030Ac in (0:1) and OSD030Ac^=.) )) or
	(osq010b=1 and ((ridageyr-OSD030BA in (0:1) and OSD030bA^=.) or (ridageyr-OSD030BB in (0:1) and OSD030bb^=.) or 
				(ridageyr-OSD030BC in (0:1) and OSD030bc^=.) or (ridageyr-OSD030BD  in (0:1) and OSD030bd^=.) or
				(ridageyr-OSD030BE in (0:1) and OSD030be^=.)or (ridageyr-OSD030BF  in (0:1) and OSD030bf^=.) or 
				(ridageyr-OSD030BG in (0:1) and OSD030bg^=.) or (ridageyr-OSD030BH  in (0:1) and OSD030bh^=.) or
				(ridageyr-OSD030BI in (0:1) and OSD030bi^=.) or (ridageyr-OSD030BJ  in (0:1) and OSD030bj^=.))) or
	(osq010c=1 and ((ridageyr-OSD030cA in (0:1) and OSD030cA^=.) or (ridageyr-OSD030cB in (0:1) and OSD030cb^=.) or 
				(ridageyr-OSD030cC in (0:1) and OSD030cc^=.) or (ridageyr-OSD030cD  in (0:1) and OSD030cd^=.) or
				(ridageyr-OSD030cE in (0:1) and OSD030ce^=.)or (ridageyr-OSD030cF  in (0:1) and OSD030cf^=.) or 
				(ridageyr-OSD030cG in (0:1) and OSD030cg^=.) or (ridageyr-OSD030cH  in (0:1) and OSD030ch^=.) or
				(ridageyr-OSD030cI in (0:1) and OSD030ci^=.) or (ridageyr-OSD030cJ  in (0:1) and OSD030cj^=.)))
	then fract=1;
drop OSD030AA OSD030Ab OSD030Ac 
			OSD030BA OSD030BB OSD030BC OSD030BD OSD030BE OSD030BF OSD030BG OSD030BH OSD030BI OSD030BJ 
			OSD030CA OSD030CB OSD030CC OSD030CD OSD030CE OSD030CF OSD030CG OSD030CH OSD030CI OSD030CJ;
run;

data set0&i;
set set0&i;
particip=(ridageyr>=20 and ridageyr<70 and (((whd050-whd020)/whd050<0.05 and (whd020-whd050)/whd050<0.07)or whd050=. or whd020=.));
chronic=(bpq020=1)+(bpq080=1)+(diq010=1)+(mcq010=1)+(mcq053=1)+(mcq160c=1)+(mcq160f=1)+(mcq160m=1)+(mcq220=1);
if chronic^=. then chroncat=(chronic>0);
if ridreth1=2 then race=4; else if ridreth1=3 then race=2; else if ridreth1=4 then race=3; else if ridreth1^=. then race=4;
if dmdeduc2=1 then dmdeduc2=2;if dmdeduc2 in (7,9) then dmdeduc2=.;
if smq020=2 then smoke=0; else if smq040 in (1,2) then smoke=2; else if smq020=1 then smoke=1;
if alq120u=2 then alqind=7/30.5;else if alq120u=3 then alqind=7/365; else if alq120u=1 then alqind=1;
if alq130<99 then alqweek=alqind*alq120q*alq130;
if alq100=2 then alcohol=0; else if alq100=1 then alcohol=1;
if pad440=1 then pad440=1;else if pad440=2 then pad440=0; else pad440=.;
if (whd050-whd020)/whd050>=0.05 then losewt=1; else losewt=0;
if (whd020-whd050)/whd050>=0.07 then gainwt=1; else gainwt=0;
if osq060=1 then osq060=1; else osq060=0;
if paq050u=1 then metind1=30; else if paq050u=2 then metind1=4.3; else if paq050u=3 then metind1=1;
durat1=metind1*paq050q*pad080; met1=durat1*4;
met2=pad120*pad160*4.5;
if paq180=1 then metind2=1.4; else if paq180=2 then metind2=1.5; else if paq180=3 then metind2=1.6; else if paq180=4 then metind2=1.8;
if duratq=. then duratq=0; if durat1=. then durat1=0; if pad160=. then pad160=0;
met3=(30*24*60-duratq-durat1-pad160)*metind2;
if met1=. then met1=0; if met2=. then met2=0; if metscor=. then metscor=0;
met=(met1+met2+met3)/60+metscor;
label race='race/eth 2=w 3=b 4=other';
label smoke='smoke 0=no 1=quit 2=yes';
run;

data set0&i;
set set0&i;
if riagendr=1 then do;
bmir=1+(bmxbmi>23.4107)+(bmxbmi>25.9536)+(bmxbmi>28.3207)+(bmxbmi>31.4109);
waistr=1+(bmxwaist>86.4548)+(bmxwaist>94.0306)+(bmxwaist> 100.9289)+(bmxwaist> 109.9071);
fatr=1+(dxdtofat>16383)+(dxdtofat> 21184)+(dxdtofat> 25522)+(dxdtofat> 32081);
end;
else if riagendr=2 then do;
bmir=1+(bmxbmi>21.6492)+(bmxbmi>24.4764)+(bmxbmi>28.0858)+(bmxbmi>33.5484);
waistr=1+(bmxwaist>76.9087)+(bmxwaist>85.2525)+(bmxwaist> 93.9465)+(bmxwaist> 105.8579);
fatr=1+(dxdtofat>18907)+(dxdtofat> 24518)+(dxdtofat> 31037)+(dxdtofat> 39618);
end;
run;

data set0&i;
set set0&i;
fatr1=(fatr=1); fatr3=(fatr=3);fatr4=(fatr=4);fatr5=(fatr=5);
bmir1=(bmir=1);bmir3=(bmir=3);bmir4=(bmir=4);bmir5=(bmir=5);
waist1=(waistr=1);waist3=(waistr=3);waist4=(waistr=4);waist5=(waistr=5);
race3=(race=3);race4=(race=4);
edu3=(DMDEDUC2=3);edu4=(DMDEDUC2=4);edu5=(DMDEDUC2=5);
smoke1=(smoke=1);smoke2=(smoke=2);
run;
%end;
%mend makedata;
%makedata;

*divide the exposure into quintiles;
%macro mean;
%do i=1 %to 5;
proc surveymeans data=set0&i plots=none quantile=(0.2 to 1 by 0.2);
strata sdmvstra; cluster sdmvpsu1; weight mec8yr; domain particip*riagendr;
var dxdtofat;
run;
%end;
%mend mean;
%mean;

*descriptive statistics;
%macro sorting;
%do i=1 %to 5;
proc sort data=set0&i;
by particip riagendr;
run;
%end;
%mend sorting;
%sorting;
proc surveyfreq data=set01;
strata sdmvstra; cluster sdmvpsu1; weight mec8yr;
tables particip*riagendr*fract*(race dmdeduc2 smoke chroncat pad440 osq060 losewt gainwt)/chisq row;
run;
proc surveymeans data=set01 plots=none;
strata sdmvstra; cluster sdmvpsu1; weight mec8yr; domain particip*riagendr;
var ridageyr bmxht bmxwt bmxbmi bmxwaist chronic met;
run;

%macro multmean;
%do i=1 %to 5;
proc surveymeans data=set0&i plots=none;
strata sdmvstra; cluster sdmvpsu1; weight mec8yr; domain particip;*riagendr;
var dxdtobmd dxdtofat;
run;
%end;
%mend multmean;
%multmean;

*main effect -- BMD;
%macro bmd;
%do i=1 %to 5;
proc surveyreg data=set0&i;
strata sdmvstra; cluster sdmvpsu1; weight mec8yr; domain particip*riagendr;
model dxdtobmd=fatr1 fatr3 fatr4 fatr5 ;*ridageyr bmxht race3 race4 edu3 edu4 edu5 smoke1 smoke2 met alcohol chronic pad440;
ods output ParameterEstimates=outa&i;
run;
proc surveyreg data=set0&i;
strata sdmvstra; cluster sdmvpsu1; weight mec8yr; domain particip*riagendr;
model dxdtobmd=waist1 waist3 waist4 waist5 ;*ridageyr bmxht race3 race4 edu3 edu4 edu5 smoke1 smoke2 met alcohol chronic pad440;
ods output ParameterEstimates=outb&i;
run;
proc surveyreg data=set0&i ;
strata sdmvstra; cluster sdmvpsu1; weight mec8yr; domain particip*riagendr;
model dxdtobmd=bmir1 bmir3 bmir4 bmir5 ;*ridageyr bmxht race3 race4 edu3 edu4 edu5 smoke1 smoke2 met alcohol chronic pad440;
ods output ParameterEstimates=outc&i;
run;
%end;
%mend bmd;
%bmd;

*make result copying work easier;
data outp;
set outa1 outa2 outa3 outa4 outa5 outb1 outb2 outb3 outb4 outb5 outc1 outc2 outc3 outc4 outc5;
where particip=1 and parameter^='Intercept';
run;
proc sort data=outp;
by parameter riagendr;
run;
proc transpose data=outp out=outq prefix=e;
by parameter riagendr;
var estimate stderr;
run;
data oute;
set outq;
where _name_='Estimate';
N=_n_;
run;
data outse;
set outq;
where _name_='StdErr';
N=_n_;
rename e1=s1 e2=s2 e3=s3 e4=s4 e5=s5;
run;
data outm;
merge oute outse;
by N;
q=(e1+e2+e3+e4+e5)/5;
w=(s1*s1+s2*s2+s3*s3+s4*s4+s5*s5)/5;
b=((e1-q)*(e1-q)+(e2-q)*(e2-q)+(e3-q)*(e3-q)+(e4-q)*(e4-q)+(e5-q)*(e5-q))/4;
t=w+6/5*b;
se=sqrt(t);
lower=q-1.96*se;
upper=q+1.96*se;
format q 10.3 lower 10.3 upper 10.3;
q2=put(q,10.3);
lower2=put(lower,10.3);
upper2=put(upper,10.3);
outlet=q2||" ("||strip(lower2)||", "||upper2||")";
run;
proc sort data=outm;
by riagendr;
run;
proc print data=outm;
var parameter riagendr outlet;
run;

*Remake the data to get less catagories;
%macro makedata2;
%do i=1 %to 5;
data set0&i;
set box.set&i;

fract=0;
if (osq010a=1 and ((ridageyr-OSD030AA in (0:1) and OSD030AA^=.) or (ridageyr-OSD030Ab in (0:1) and OSD030Ab^=.) 
				or (ridageyr-OSD030Ac in (0:1) and OSD030Ac^=.) )) or
	(osq010b=1 and ((ridageyr-OSD030BA in (0:1) and OSD030bA^=.) or (ridageyr-OSD030BB in (0:1) and OSD030bb^=.) or 
				(ridageyr-OSD030BC in (0:1) and OSD030bc^=.) or (ridageyr-OSD030BD  in (0:1) and OSD030bd^=.) or
				(ridageyr-OSD030BE in (0:1) and OSD030be^=.)or (ridageyr-OSD030BF  in (0:1) and OSD030bf^=.) or 
				(ridageyr-OSD030BG in (0:1) and OSD030bg^=.) or (ridageyr-OSD030BH  in (0:1) and OSD030bh^=.) or
				(ridageyr-OSD030BI in (0:1) and OSD030bi^=.) or (ridageyr-OSD030BJ  in (0:1) and OSD030bj^=.))) or
	(osq010c=1 and ((ridageyr-OSD030cA in (0:1) and OSD030cA^=.) or (ridageyr-OSD030cB in (0:1) and OSD030cb^=.) or 
				(ridageyr-OSD030cC in (0:1) and OSD030cc^=.) or (ridageyr-OSD030cD  in (0:1) and OSD030cd^=.) or
				(ridageyr-OSD030cE in (0:1) and OSD030ce^=.)or (ridageyr-OSD030cF  in (0:1) and OSD030cf^=.) or 
				(ridageyr-OSD030cG in (0:1) and OSD030cg^=.) or (ridageyr-OSD030cH  in (0:1) and OSD030ch^=.) or
				(ridageyr-OSD030cI in (0:1) and OSD030ci^=.) or (ridageyr-OSD030cJ  in (0:1) and OSD030cj^=.)))
	then fract=1;
drop OSD030AA OSD030Ab OSD030Ac 
			OSD030BA OSD030BB OSD030BC OSD030BD OSD030BE OSD030BF OSD030BG OSD030BH OSD030BI OSD030BJ 
			OSD030CA OSD030CB OSD030CC OSD030CD OSD030CE OSD030CF OSD030CG OSD030CH OSD030CI OSD030CJ;
run;

data set0&i;
set set0&i;
particip=(ridageyr>=20 and ridageyr<70 and (((whd050-whd020)/whd050<0.05 and (whd020-whd050)/whd050<0.07)or whd050=. or whd020=.));
chronic=(bpq020=1)+(bpq080=1)+(diq010=1)+(mcq010=1)+(mcq053=1)+(mcq160c=1)+(mcq160f=1)+(mcq160m=1)+(mcq220=1);
if chronic^=. then chroncat=(chronic>0);
if ridreth1=2 then race=3; else if ridreth1=3 then race=2; else if ridreth1=4 then race=3; else if ridreth1^=. then race=3;
if dmdeduc2 in (1,2,3) then dmdeduc2=3;if dmdeduc2 in (4,5) then dmdeduc2=4; if dmdeduc2 in (7,9) then dmdeduc2=.;
if smq020=2 then smoke=0; else if smq040 in (1,2) then smoke=2; else if smq020=1 then smoke=0;
if alq120u=2 then alqind=7/30.5;else if alq120u=3 then alqind=7/365; else if alq120u=1 then alqind=1;
if alq130<99 then alqweek=alqind*alq120q*alq130;
if alq100=2 then alcohol=0; else if alq100=1 then alcohol=1;
if pad440=1 then pad440=1;else if pad440=2 then pad440=0; else pad440=.;
if (whd050-whd020)/whd050>=0.05 then losewt=1; else losewt=0;
if (whd020-whd050)/whd050>=0.07 then gainwt=1; else gainwt=0;
if osq060=1 then osq060=1; else osq060=0;
if paq050u=1 then metind1=30; else if paq050u=2 then metind1=4.3; else if paq050u=3 then metind1=1;
durat1=metind1*paq050q*pad080; met1=durat1*4;
met2=pad120*pad160*4.5;
if paq180=1 then metind2=1.4; else if paq180=2 then metind2=1.5; else if paq180=3 then metind2=1.6; else if paq180=4 then metind2=1.8;
if duratq=. then duratq=0; if durat1=. then durat1=0; if pad160=. then pad160=0;
met3=(30*24*60-duratq-durat1-pad160)*metind2;
if met1=. then met1=0; if met2=. then met2=0; if metscor=. then metscor=0;
met=(met1+met2+met3)/60+metscor;
label race='race/eth 2=w 3=b 4=other';
label smoke='smoke 0=no 1=quit 2=yes';
run;

data set0&i;
set set0&i;
if riagendr=1 then do;
bmir=1+(bmxbmi>23.4107)+(bmxbmi>31.4109);
waistr=1+(bmxwaist>86.4548)+(bmxwaist> 109.9071);
fatr=1+(dxdtofat>16383)+(dxdtofat> 32081);
end;
else if riagendr=2 then do;
bmir=1+(bmxbmi>21.6492)+(bmxbmi>33.5484);
waistr=1+(bmxwaist>76.9087)+(bmxwaist> 105.8579);
fatr=1+(dxdtofat>18907)+(dxdtofat> 39618);
end;
run;

data set0&i;
set set0&i;
fatr1=(fatr=1); fatr3=(fatr=3);
bmir1=(bmir=1);bmir3=(bmir=3);
waist1=(waistr=1);waist3=(waistr=3);
run;
%end;
%mend makedata2;
%makedata2;

*main effect -- Fracture;
%macro fract;
%do i=1 %to 5;
proc surveylogistic data=set0&i;
strata sdmvstra; cluster sdmvpsu1; weight mec8yr; domain particip*riagendr;
class bmir1 bmir3 race dmdeduc2 smoke chroncat pad440 / param=ref;
model fract(event='1')=bmir1 bmir3 ridageyr race dmdeduc2 smoke chroncat pad440;
ods output ParameterEstimates=outa&i;
run;
proc surveylogistic data=set0&i;
strata sdmvstra; cluster sdmvpsu1; weight mec8yr; domain particip*riagendr;
class waist1 waist3 race dmdeduc2 smoke chroncat pad440 / param=ref;
model fract(event='1')=waist1 waist3 ridageyr race dmdeduc2 smoke chroncat pad440;
ods output ParameterEstimates=outb&i;
run;
proc surveylogistic data=set0&i;
strata sdmvstra; cluster sdmvpsu1; weight mec8yr; domain particip*riagendr;
class fatr1 fatr3 race dmdeduc2 smoke chroncat pad440 /  param=ref;
model fract(event='1')=fatr1 fatr3 ridageyr race dmdeduc2 smoke chroncat pad440;
ods output ParameterEstimates=outc&i;
run;
%end;
%mend fract;
%fract;

*easy copy process;
data outp;
set outa1 outa2 outa3 outa4 outa5 outb1 outb2 outb3 outb4 outb5 outc1 outc2 outc3 outc4 outc5;
where particip=1 and variable^='Intercept';
run;
proc sort data=outp;
by variable riagendr;
run;
proc transpose data=outp out=outq prefix=e;
by variable riagendr;
var estimate stderr;
run;
data oute;
set outq;
where _name_='Estimate';
N=_n_;
run;
data outse;
set outq;
where _name_='StdErr';
N=_n_;
rename e1=s1 e2=s2 e3=s3 e4=s4 e5=s5;
run;
data outm;
merge oute outse;
by N;
q=(e1+e2+e3+e4+e5)/5;
w=(s1*s1+s2*s2+s3*s3+s4*s4+s5*s5)/5;
b=((e1-q)*(e1-q)+(e2-q)*(e2-q)+(e3-q)*(e3-q)+(e4-q)*(e4-q)+(e5-q)*(e5-q))/4;
t=w+6/5*b;
se=sqrt(t);
lower=q-1.96*se;
upper=q+1.96*se;
eq=exp(q);
elower=exp(lower);
eupper=exp(upper);
q2=put(eq,10.3);
lower2=put(elower,10.3);
upper2=put(eupper,10.3);
outlet=q2||" ("||strip(lower2)||", "||upper2||")";
run;
proc sort data=outm;
by riagendr;
run;
proc print data=outm;
var variable riagendr outlet;
run;

*This is actually the first analysis. Get the correlation between the three exposures;
%macro db;
%do i=1 %to 5;
proc surveyreg data=set0&i;
strata sdmvstra; cluster sdmvpsu1; weight mec8yr; domain particip*riagendr;
model bmxbmi=bmxwaist / clparm;
ods output fitstatistics=db&i;
run;
%end;
%mend db;
%db;

data db;
set db1 db2 db3 db4 db5;
where label1='R-Square';
run;

proc sort data=db; by domain; run;
proc transpose data=db out=db0;
var nvalue1;
by domain;
run;
data db0;
set db0;
means=sqrt(mean(col1,col2,col3,col4,col5));
run;
proc print data=db0;
run;
