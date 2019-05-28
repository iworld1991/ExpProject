

******************************************
** Importing and cleaning inflation series 
******************************************
clear


global mainfolder "/Users/Myworld/Dropbox/ExpProject/workingfolder"
global folder "${mainfolder}/SurveyData/"
global surveyfolder "NYFEDSurvey"
global otherdatafolder "OtherData"
global sum_graph_folder "${mainfolder}/${otherdatafolder}"



cd "${mainfolder}/${otherdatafolder}"

import excel "${mainfolder}/${otherdatafolder}/CPI&CPICoreIdxM.xls", sheet("FRED Graph") cellrange(A12:C867) firstrow
rename observation_date date
gen month=month(date)
gen year = year(date)
gen date_str=string(year)+"m"+string(month)
gen date2=monthly(date_str,"YM")
format date2 %tm
drop date_str date 
rename date2 date 
label var CPIAUCSL "CPI index for all urban households(seasonally adjusted)"
label var CPILFESL "CPI index for all urban households excl food and energy (seaonsally adjusted)"

rename CPIAUCSL CPIAU
rename CPILFESL CPICore

order date year month
 
save CPICPICore.dta,replace

clear
import excel "${mainfolder}/${otherdatafolder}/PCEIdxM.xls", sheet("FRED Graph") cellrange(A11:B734) firstrow
rename observation_date date
gen month=month(date)
gen year = year(date)
gen date_str=string(year)+"m"+string(month)
gen date2=monthly(date_str,"YM")
format date2 %tm
drop date_str date
rename date2 date 
order date year month 
label var PCEPI "PCE: chain-type price idx"
save PCEIdx.dta,replace
clear


use "${mainfolder}/${otherdatafolder}/CPICPICore.dta",clear 

merge 1:1 date using "${mainfolder}/${otherdatafolder}/PCEIdx.dta"

rename _merge PCEPI_merge

tsset date


foreach var in  CPIAU CPICore PCEPI{
   
   ** computing yoy inflation and foreward inflation
   gen Inf1y_`var' = (`var'- l12.`var')*100/l12.`var'
   label var Inf1y_`var' "yoy inflation based on `var'"
   gen Inf1yf_`var' = (f12.`var'- `var')*100/`var'
   label var Inf1yf_`var' "1-year-ahead realized inflation"
     
}


*********************************
**   Plot Inflation Series *****
*********************************


tsline Inf1y_CPIAU Inf1y_CPICore Inf1y_PCEPI, title("Annual Inflation of the U.S.") legend(label(1 "Headline CPI") label(2 "Core CPI") label(3 "PCE"))
graph export "${mainfolder}/${otherdatafolder}/Inflation", as(png) replace 


save InfM,replace 
