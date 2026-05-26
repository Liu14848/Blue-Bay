set python_exec C:\Users\libin\AppData\Local\Programs\Python\Python313\python.exe
cd "C:\Users\libin\Desktop\2025\10月\蓝色海湾\附件"


import excel "data6.xlsx", firstrow clear
xtset year countyid

global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy  i.year i.countyid
global D policy
set seed 42 
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust

global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy i.year i.countyid
global D policy
set seed 66
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, nocons robust

global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy i.year i.countyid
global D policy
set seed 42 
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(gradboost)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(gradboost)
ddml crossfit
ddml estimate, nocons robust

**内生性**
clear
import excel "autoiv.xlsx", sheet("Sheet1") firstrow
encode county, gen(countyid)
xtset year countyid

global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy auto_c1 auto_c2 auto_c3 i.year i.countyid
global D policy

set seed 42
ddml init iv, kfolds(5) reps(51)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)

ddml E[Z|X]: pystacked auto_iv1 $X, type(reg) method(svm)
ddml E[Z|X]: pystacked auto_iv2 $X, type(reg) method(svm)
ddml desc, learners
ddml crossfit
ddml estimate, nocons robust

****选取输出结果对应的那一次采样****
ivreg2 Y1_pystacked_2 (D1_pystacked_2 = Z1_pystacked_2 Z2_pystacked_2), robust endog(D1_pystacked_2) first


**剔除并行政策****
*1.国家新型城镇化综合试点
global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy did_urban i.year i.countyid
global D policy
set seed 42 
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust

*2.城乡融合试点
global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy did_inte i.year i.countyid
global D policy
set seed 42 
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust

*3.乡村振兴示范县
global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy did_rural i.year i.countyid
global D policy
set seed 42 
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust


***剔除上海、深圳、广东***
drop if inlist(city, "上海市", "深圳市", "广州市")
global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy i.year i.countyid
global D policy
set seed 42 
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust

***缩尾***
*winsor2 light1, cut(1,99)
winsor2 light1, cut(5,95)
global Y light1_w
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy i.year i.countyid
global D policy
set seed 42 
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust


***更换3折、10折***

global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy i.year i.countyid
global D policy
set seed 42 
*ddml init partial, kfolds(3) reps(51)
*ddml init partial, kfolds(10) reps(51)
ddml init partial, kfolds(5) reps(101)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust

***加入控制变量二次项***
foreach var in Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy  {
    gen `var'2 = `var'^2
}
global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy Consume2 HCap2 Income2 Finance2 PDensity2 Medicine2 ESize2 Grain2 Topography2 Energy2  i.year i.countyid
global D policy
set seed 42 
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust

****机制检验*****
global Y Stru
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy i.year i.countyid
global D policy
set seed 42 
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust

global Y Patent
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy i.year i.countyid
global D policy
set seed 42 
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust

global Y PCap
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy i.year i.countyid
global D policy
set seed 42
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust



*********异质性********
****地理区位异质****
gen 地理区位虚拟变量 = 1
replace 地理区位虚拟变量 = 0 if Province == "山东省" | Province == "辽宁省" | Province == "河北省"
replace 地理区位虚拟变量 = 0 if city == "连云港市" 

gen 地理区位异质 = policy*地理区位虚拟变量

global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy policy i.year i.countyid
global D 地理区位异质
set seed 42
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust

***经济发展水平异质****
egen median_GDP = median(GDP)
gen GDP差异 = (GDP > median_GDP) if GDP != .
drop median_GDP
gen policyGDP = policy*GDP差异

global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy policy i.year i.countyid
global D policyGDP
set seed 42
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust


*data1 工程干预type=1 生态修复type=-1
*drop if type==1 
drop if type==-1
global Y light1
global X Consume HCap Income Finance PDensity Medicine ESize Grain Topography Energy i.year i.countyid
global D policy
set seed 42
ddml init partial, kfolds(5) reps(51)
ddml E[D|X]: pystacked $D $X, type(reg) method(svm)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(svm)
ddml crossfit
ddml estimate, nocons robust

