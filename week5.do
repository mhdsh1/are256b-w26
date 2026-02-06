*----------------------------------------------------------------------------*-
* ARE 256b W26 -- Week 5
* week5.do
* Feb 5, 2026
* Mahdi Shams 
*----------------------------------------------------------------------------*

*Program Setup

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

global filename = "week5"

if "`c(os)'" == "Windows" global out "${path}/out/${filename}"
if "`c(os)'" == "Unix"    global out "${path}/out/${filename}"
cap mkdir $out

local ts = subinstr("`c(current_date)'", " ", "", .)

log using "$path/log/${filename}_`ts'", text replace

* Load your dataset
import delimited "$path/data/broiler.csv", clear

********************************************************************************

browse

/*
"y" is per­capita real disposable income, 
"pchick" stands for "price of chicken", 
"pbeef" is "price of beef", 
"pcor" is "price of corn", 
"pf" is "price of chicken feed", 
"cpi" is "consumer price index", 
"qproda" is "aggregate production of chicken in pounds", 
"pop" is "population of the US", a
nd "meatex" is "exports of beef, veal, and pork in pounds".
*/

* OLS regressions
reg q pchick // short regression 

reg q pchick y pop cpi meatex pbeef // long regression 

/* Recall the OVB formula:

OVB = \beta_long - \beta_short = \Sigma_j \Gamma_j Cov(W_j,X)/var(X)

let's see what explains the difference between the two betas */

reg y pchick 
reg pop pchick
reg cpi pchick
reg meatex pchick
reg pbeef pchick

********************************************************************************

/* --> we use pcor or pfeed as an instrument! */

/*Refresher on instruments, out good friend for demand estimation! 

1) Validity: cov(u,Z) = 0.

in demand estimation u are all the unobservable factors that affect the demand ... 
"demand-shifters", "taste", ...

2) Relvance: cov(X,Z) not 0.

instrument should affect the endogenuous variable 

3) Exclusion: Z has no direct link with Y.

Simply the fact that instrument should be "excluded exogenuous variable" */


* IV regression

ivregress 2sls q (pchick = pf) y pop cpi pbeef meatex

qui eststo model1: ivregress 2sls q (pchick = pf pcor) y pop cpi pbeef meatex

// lets do it ourself

* first stage ls
reg pchick pcor pf y pop cpi meatex pbeef
predict xhat, xb

* Second stage ls 
eststo  model2: reg q xhat y pop cpi pbeef meatex

esttab model1 model2


*----------------------------------------------------------------------
* multiple endogenous regressors: what if PBEEF is also endogenuous?
*----------------------------------------------------------------------

* long regression:

reg q pchick y pop cpi meatex pbeef

/* Now we also want to instrument for price of beef! */

*** Method 1: using ivreg 2sls command 

ivregress 2sls q (pchick pbeef = pf pcor) y pop cpi meatex


*** Method 2: coding 2sls ourslef

* first stage LS 

cap drop pbeef_h
reg pbeef  pcor pf y pop cpi meatex 
predict pbeef_h, xb

cap drop pchick_h
reg pchick pcor pf y pop cpi meatex 
predict pchick_h, xb

* second stage least squares 

reg q pchick_h pbeef_h y pop cpi meatex



log close 

* end of script 