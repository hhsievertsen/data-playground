clear 
// from https://api.statbank.dk/console#data

import delimited "https://api.statbank.dk/v1/data/FORLOB15/CSV?AFGAARG(Head)=2010%2C2016%2C2023&UDDSTAT(Head)=*&STATUSTID(Head)=*&UDDANNELSE(Head)=*", delimiter(";") 


// Cleaning
keep if statustid=="1 år"
 


//  Aggregate
gen aggr=""
replace aggr=uddannelse if uddstat=="I gang med en uddannelse"
replace aggr=uddstat if uddstat=="Har afbrudt en uddannelse"
replace aggr=uddstat if uddstat=="Ej påbegyndt"
replace aggr="Rest" if aggr==""
drop if uddannelse=="I alt"
collapse (sum) indhold, by(aggr afgaarg)


drop if indhold==0
bys afgaarg: egen sum=sum(indhold)
gen value=100*indhold/sum

replace aggr="Andet" if value <2
collapse (sum) value, by(aggr afgaarg)
//  Sankey
// ssc install sankey, replace
//ssc install palettes, replace
//ssc install colrspace, replace
//ssc install graphfunctions, replace
graph set window fontface "Arial Narrow"


tostring afgaarg, replace


gen colorvar=0
replace colorvar=1 if afgaarg=="2023"
sankey value, from(afgaarg) to(aggr)  novalleft labs(2.4)  laba(0) ///
	labpos(9 3) labg(2) gap(5) ctwrap(8) ctgap(5) ///
	xsize(2) ysize(2) plotregion(margin(l+6 r+60 b+5)) colorvar(colorvar)

/*
import excel using "https://github.com/asjadnaqvi/stata-sankey/blob/main/data/sankey_example2.xlsx?raw=true", clear first

sankey value, from(source) to(destination) by(layer)
