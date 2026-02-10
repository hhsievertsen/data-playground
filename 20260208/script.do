// Create sankey chart on flow from high school to further education in DK. By HHS. February 10, 2026
clear 

//  Install and setup. See: https://github.com/asjadnaqvi/stata-sankey 
//ssc install sankey, replace
//ssc install palettes, replace
//ssc install colrspace, replace
//ssc install graphfunctions, replace
graph set window fontface "Arial Narrow"
set dp comma

// Download data directly using DST API
// See from https://api.statbank.dk/console#data
import delimited "https://api.statbank.dk/v1/data/FORLOB15/CSV?AFGAARG(Head)=2010%2C2016%2C2023&UDDSTAT(Head)=*&STATUSTID(Head)=*&UDDANNELSE(Head)=*", delimiter(";") 

// Cleaning
keep if statustid=="1 år"

//  Aggregate values (i.e. afbrud and ej påbegyndt form groups)
gen aggr=""
replace aggr=uddannelse if uddstat=="I gang med en uddannelse"
replace aggr=uddstat if uddstat=="Har afbrudt en uddannelse"
replace aggr=uddstat if uddstat=="Ej påbegyndt"
replace aggr="Rest" if aggr==""
drop if uddannelse=="I alt"
collapse (sum) indhold, by(aggr afgaarg)

// Drop empty flows
drop if indhold==0

// Compute percentage (not used for now in chart)
bys afgaarg: egen sum=sum(indhold)
gen value=100*indhold/sum

// Collect small shares in "other"
replace aggr="Andet" if value <4
collapse (sum) sum=indhold, by(aggr afgaarg)


// Change format
tostring afgaarg, replace

// Color variable
gen colorvar=0
replace colorvar=1 if afgaarg=="2023"

// Now create Sankey chart (see https://github.com/asjadnaqvi/stata-sankey)
sankey sum, from(afgaarg) to(aggr)  novalright labs(3)  laba(0) ///
	format(%10,0fc) vals(1.3) labpos(9 3) labg(2) gap(5) ctwrap(40) ctgap(5) ///
	xsize(3) ysize(2) plotregion(margin(l+6 r+60 b+5)) colorvar(colorvar) ///
	title("Fra gymnasial uddannelse til videre uddannelse ") ///
		ctitle("{bf:Afsluttet gymnasial udd.}" "{bf:1 år efter }") ///
		note("Kilde: Danmarks Statistik. Statistikbanken.dk/FORLOEB15", size(tiny))
