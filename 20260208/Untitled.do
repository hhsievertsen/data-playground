clear 
// from https://api.statbank.dk/console#data

import delimited "https://api.statbank.dk/v1/data/FORLOB15/CSV?AFGAARG(Head)=2008%2C2012%2C2016%2C2020%2C2024&UDDSTAT(Head)=*&STATUSTID(Head)=*", delimiter(";") 


// Cleaning
keep if statustid=="1 år"


//  Sankey
// ssc install sankey, replace
//ssc install palettes, replace
//ssc install colrspace, replace
//ssc install graphfunctions, replace
graph set window fontface "Arial Narrow"

rename indhold value
tostring afgaarg, replace
sankey value, from(afgaarg) to(uddstat) 
