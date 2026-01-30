
* I chek the IV Question 

version 18              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros

*set working directory 

cap log close 
clear all
set more off
local user = "`c(username)'"
local folder = "are256b-w26"

if "`c(os)'" == "Windows" global path = "C:/Users/`user'/Dropbox/Courses/`folder'"
if "`c(os)'" == "Unix"    global path = "/home/`user'/Dropbox/Courses/`folder'"

global filename = "HA2_Fulton"

if "`c(os)'" == "Windows" global out "${path}/out/${filename}"
if "`c(os)'" == "Unix"    global out "${path}/out/${filename}"
cap mkdir $out

local ts = subinstr("`c(current_date)'_`c(current_time)'", " ", "", .)
local ts = subinstr("`ts'", ":", "", .)

log using "$path/git_ignore/${filename}", text replace

use "$path/data/Fulton.dta", replace

g Fair = (Stormy+Mixed)==0

g dummy1= Stormy
g dummy2= Fair 
replace dummy2 = . if Stormy == 1
g dummy3= Mixed
replace dummy3 = . if Fair == 1

ivregress 2sls q (p = dummy1)
ivregress 2sls q Mon Tue Wed Thu (p = dummy1)

ivregress 2sls q (p = dummy2)
ivregress 2sls q Mon Tue Wed Thu (p = dummy2)

ivregress 2sls q (p = dummy3)
ivregress 2sls q Mon Tue Wed Thu (p = dummy3)

eststo clear


ivregress 2sls q (p = dummy1)
eststo col1
ivregress 2sls q Mon Tue Wed Thu (p = dummy1)
eststo col2

ivregress 2sls q Mon (p = dummy2)
eststo col3
ivregress 2sls q Mon Tue Wed Thu (p = dummy2)
eststo col4

ivregress 2sls q Mon (p = dummy3)
eststo col5
ivregress 2sls q Mon Tue Wed Thu (p = dummy3)
eststo col6

esttab

esttab, replace fragment ///
keep(p Mon Tue Wed Thu) ///
order(p Mon Tue Wed Thu) ///
b(%6.2f) se(%6.2f) ///
parentheses ///
nocons 

log close