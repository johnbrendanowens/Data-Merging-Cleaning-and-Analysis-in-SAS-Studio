data demog; *Import Demog data;
infile'H:\Apps\MinitabFiles\Morrell\ST710\demog.dat';
input idno 1-6 age 8-12 .1 height 22-26 .1 weight 28-32 .1 smoke 34 dead 37;
run;

LIBNAME stat 'H:\Apps\MinitabFiles\Morrell\ST710\'; *Set library for Permanenet SAS File;

data bp; *Read in permenant SAS file;
set stat.bp;
run;

proc contents data=bp;*Check contents of file;
run;

proc import 
datafile = 'H:\Apps\MinitabFiles\Morrell\ST710\psa.xls'
out = psa
dbms = xls replace;
getnames = YES;
run; *import excel file;

data complete;
merge bp demog psa;
by idno;
run; *Merge data files;

data newcomplete; *Create new variables and transform existing varibles;
set complete;
if idno < 5000 then gender = 1; *Creating Gender Var;
else gender = 2;
heightm = height/100;*changing height to meters;
bmi = (weight)/(heightm*heightm);*calculating bmi;
if bmi = . then bmicat = .;*creating bmi categorical var;
else if bmi <20 then  bmicat = 1;
else if 20<= bmi < 25 then bmicat= 2;
else if 25<= bmi < 30 then bmicat= 3; 
else if bmi=>30 then bmicat = 4;
psalog = log(psa+1);*creating natural log of psa var;
if psbp>140 or pdbp >90 then hypertension = 1;*creating hypertension categorical var;
else if psbp<=140 and pdbp<=90 then hypertension = 2;
else hypertension = .;

femalebmitest = bmi-25;
run;

proc format;
value gfmt 1 = "Male" 2 = "Female";
value bmifmt 1 = "Lean" 2="Normal" 3= "Overweight" 4= "Obese"; 
value hfmt 1= "Hypertensive" 2 = "Non-Hypertensive";                                      
   
*Formatting Variables for graphing; 	

run;

proc sort data=newcomplete; *Sorting for use of by statement;
by gender;
run;

proc means  data=newcomplete; *Getting descriptive statistics for men and women weights;
title "Descriptive Statistics of Men and Women's Height and Weight";
label heightm = "Height in meters";
label weight = "Weight in kg";
var heightm weight;
by gender;
format gender gfmt.;
run;

proc boxplot data = newcomplete; *Plotting men and womens heights/weights;
title "Men versus Women Height and Weight";
label heightm = "Height in meters";
label weight = "Weight in kg";
plot heightm*gender;
plot weight*gender;
format gender gfmt.; 
run;

proc freq data = newcomplete; *comparing distribution of of BMI Cat versus Gender;
title "Distribution of BMI categories between men and women";
label bmicat = "BMI Categories" ;
table bmicat*gender; 
format gender gfmt.;
format bmicat bmifmt.; 
run;

proc univariate normal data = newcomplete; *Testing the Normalty of PSA between Groups;
title "Normailty of PSA distribution in three groups"; 
class group;
var psa;
run;
proc univariate normal data = newcomplete; *Testing the Normality of Natural Log of PSA between groups;
title "Normailty of Natural Log PSA distribution in three groups";
class group;
var psalog;
run;


proc means data = newcomplete n mean std t probt; *Testing the BMI of Women less than 40;
title "Is the Average BMI of Women under 40 less than 25";
where gender = 2 and age < 40;
var femalebmitest;
run;

proc sort data = newcomplete;

by gender;
run;

proc ttest data = newcomplete; *Comparing Systolic Blood Pressure between Men who smoke and have never smoked;
title "T Test Systolics Blodd Pressure between current Male Smokers and never smoked";
label psbp = "Systolics Blood Pressure" smoke = "Smoking Status" 1 = "Never Smoked" 3 ="Current Smoker"  ;
class smoke;
where smoke = 1 or smoke = 3 and gender = 1;
var psbp;
run;

proc npar1way wilcoxon; *Nonparametric test of Natural Log of PSA;
title "Wilcoxon Rank Sum Test of Natural Log PSA between groups";
class group;
where group = "CAN" or group = "CON";
var psalog;
run;
proc npar1way wilcoxon; *Nonparametric test of PSA;
title "Wilcoxon Rank Sum Test of PSA between groups";
class group;
where group = "CAN" or group = "CON";
var psa;
run;
proc ttest data = newcomplete; *T-test of Convcan v PSAlog;
title "Parametric test of PSA between groups";
class group;
where group = "CON" or group = "CAN";
var psalog;
run;

proc freq data = newcomplete; *Testing distribution of BMIcat for Men over 50;
title "Distribution of BMI Cat for Men Over 50";
label bmicat = "BMI Categories" ;
where gender = "male" and age > 50;
tables bmicat / binomial (p=.15 level =4);
format bmicat bmifmt.; 
format gender gfmt.;
run;


proc freq data = newcomplete; *Testing distribution of BMIcat among adults;
title "Distribution of BMIcat for Adults";
label bmicat = "BMI Categories" ;
where age >=20;
table bmicat / chisq testp = (.05 .3 .35 .3);
format bmicat bmifmt.; 
run;

proc sort;
by gender;
run;

proc freq data = newcomplete; *Testing association between bmicat and hypertension by gender;
title "Correlation between Hypertension and BMI Categories by Gender";
label bmicat = "BMI Categories" ;
label hypertension = "Hypertension";
table bmicat*hypertension / chisq ;
by gender;
format hypertension hfmt.;
format gender gfmt.; 
run;

