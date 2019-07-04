ssc install synth, replace all 

cd /Users/calumdavey/Desktop/MJ/

// Open data 
import delim data.csv, clear

// Setup data 
tsset id time

// Graph
graph twoway (line hr time if id==47 ) ///
(lowess hr time if id!=47) , xline(2014)

// Run synth control
synth hr ur hr, ///
trunit(47) trperiod(2014) xperiod(1996(1)2013) fig keep(hrfig2) replace


use smoking, clear
tsset state year
graph twoway (line cigsale year if state==3 )(lowess cigsale year ///
if state!=3) , xline(1988) ytitle("Cigarette sale (packs per capita)") xtitle("Year") legend(label(1 "California") label(2 "Other US states"))
synth cigsale beer lnincome retprice age15to24 cigsale, trunit(3) trperiod(1989) xperiod(1980(1)1988) nested fig keep(abadie) replace
