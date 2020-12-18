/* data preparation for calculation of generic outcomes given:

1. Hazard Ratios: age, hr_conditionX (wide)
--------------------------------------------
a. Full. Age constant but file still has ages for consistency.
b. Simple. Ditto.
[d. full-discrete]
[e. simple-discrete]

2. Prevalences: age, prev_conditionX (wide)
--------------------------------------------
a. England age-invariant (OpenSafely)
b. England age-variant (OpenSafely + other England data + GBD)
c. India (biomarkers + GBD)

3. Population distribution: age, population
--------------------------------------------
a. England
b. India

Outcomes
---------
1. age-specific mortality curve (Fig. 2A)
2. share of deaths under age 60
3. total number of deaths given a mortality rate for women aged 50-59.

Questions
---------
- do we use England population age distribution or OpenSafely age distribution?
  - for now we'll use population.

  */

/**********************/
/* prep hazard ratios */
/**********************/

/* full-continuous */
use $tmp/eng_nhs_hazard_ratios_flat_hr_full, clear
drop v1 age*
expand 82
gen age = _n + 17
order age
merge 1:1 age using $tmp/eng_age_predicted_hr, keep(match) nogen
ren hr_full_age_cts age_hr_full
ren *_hr_full hr_*
ren *_hr_lnse hr_lnse_*
drop hr_simp_age_cts
save $tmp/hr_full_cts, replace

/* full-discrete */
use $tmp/eng_nhs_hazard_ratios_flat_hr_full, clear
drop v1
expand 82
gen age = _n + 17
gen     hr_age = age18_40_hr_full if inrange(age, 18, 40)
replace hr_age = age40_50_hr_full if inrange(age, 41, 50)
replace hr_age = age50_60_hr_full if inrange(age, 51, 60)
replace hr_age = age60_70_hr_full if inrange(age, 61, 70)
replace hr_age = age70_80_hr_full if inrange(age, 71, 80)
replace hr_age = age80__hr_full   if inrange(age, 81, 99)
drop age*full
ren *_hr_full hr_*
order age
save $tmp/hr_full_dis, replace

/* simple continuous */
use $tmp/eng_nhs_hazard_ratios_flat_hr_simp, clear
drop v1 age*
expand 82
gen age = _n + 17
order age
merge 1:1 age using $tmp/eng_age_predicted_hr, keep(match) nogen
drop hr_full_age_cts
ren hr_simp_age_cts age_hr_simp
ren *_hr_simp hr_*
/* set all condition HRs to 1 */
foreach v of varlist hr_* {
  if !inlist("`v'", "hr_age", "hr_male") {
    replace `v' = 1
  }
}
save $tmp/hr_simp_cts, replace

/* simple discrete */
use $tmp/eng_nhs_hazard_ratios_flat_hr_simp, clear
drop v1
expand 82
gen age = _n + 17
gen     hr_age = age18_40_hr_simp if inrange(age, 18, 40)
replace hr_age = age40_50_hr_simp if inrange(age, 41, 50)
replace hr_age = age50_60_hr_simp if inrange(age, 51, 60)
replace hr_age = age60_70_hr_simp if inrange(age, 61, 70)
replace hr_age = age70_80_hr_simp if inrange(age, 71, 80)
replace hr_age = age80__hr_simp   if inrange(age, 81, 99)
drop age*simp
ren *_hr_simp hr_*
order age
/* set all condition HRs to 1 */
foreach v of varlist hr_* {
  if !inlist("`v'", "hr_age", "hr_male") {
    replace `v' = 1
  }
}
save $tmp/hr_simp_dis, replace

/* compare age HRs in all 4 models */
clear
set obs 82
gen age = _n + 17
foreach v in full_cts full_dis simp_cts simp_dis {
  merge 1:1 age using $tmp/hr_`v', keepusing(hr_age) nogen
  ren hr_age hr_age_`v'
  replace hr_age_`v' = ln(hr_age_`v')
}
sort age
twoway ///
    (line hr_age_full_cts   age) ///
    (line hr_age_full_dis   age) ///
    (line hr_age_simp_cts age) ///
    (line hr_age_simp_dis age) 
graphout hr_ages

/**********************/
/* prep prevalences   */
/**********************/

/* ***************************** */
/* England OpenSafely (age-invariant) */
import delimited using $comocsv/uk_nhs_incidence.csv, clear
gen x = 1
replace prevalence = prevalence / 100
reshape wide prevalence, j(condition) i(x) string
ren prevalence* prev_*
drop x
expand 82
gen age = _n + 17
/* drop age prevalences-- we're getting these from the England population */
drop prev*age*
order age
save $tmp/prev_eng_os, replace

/* ******* */
/* England biomarkers + GBD */
/* start with biomarkers */
use $datafp/eng_prevalences, clear
ren eng_prev* prev*
keep if inrange(age, 18, 99)
order age
save $tmp/eng_biomarkers, replace

/* bring in GBD */
merge 1:1 age using $health/gbd/gbd_nhs_conditions_eng, nogen
keep if inrange(age, 18, 99)
drop *upper *lower *granular country
/* use GBD unless non-GBD var already exists */
drop gbd_diabetes gbd_chronic_resp_dz
foreach v of varlist gbd* {
  local condition = substr("`v'", 5, .)
  cap confirm variable prev_`condition'
  if _rc {
    di "Using GBD for `condition'..."
    ren gbd_`condition' prev_`condition'
  }
}

/* get remaining vars from OpenSafely as age-invariant */
ren prev* prevc*
merge 1:1 age using $tmp/prev_eng_os, nogen

/* loop over OpenSafely vars */
foreach v of varlist prev_* {
  local condition = substr("`v'", 6, .)
  cap confirm variable prevc_`condition'
  if _rc {
    di "Using OpenSafely age-invariant prevalence for `condition'..."
    ren prev_`condition' prevc_`condition'
  }
  else {
    drop prev_`condition'
  }
}  
ren prevc* prev*

/* get male share from England census data */
drop prev_female prev_male
merge 1:1 age using $tmp/eng_pop, keep(match) nogen keepusing(male)
ren male prev_male

/* save */
save $tmp/prev_eng_nhs, replace

/* A England version that doesn't have the conditions we couldn't match in India */
use $tmp/prev_eng_nhs, clear
foreach v in $hr_os_only_vars {
  replace prev_`v' = 0
}
save $tmp/prev_eng_nhs_matched, replace

/*************/
/* India     */

/* start with DLHS/AHS biomarkers */
use $health/dlhs/data/dlhs_ahs_covid_comorbidities, clear
keep wt age $hr_biomarker_vars hypertension_contr hypertension_uncontr
collapse (mean) $hr_biomarker_vars hypertension_contr hypertension_uncontr [aw=wt], by(age)

/* bring in GBD measures */
merge m:1 age using $health/gbd/gbd_nhs_conditions_india, keep(match) nogen
drop gbd_diabetes country *upper *lower *granular
ren gbd_* *
ren * prev_*
ren prev_age age

/* set prevalence to zero for the measures we don't have */
foreach v in $hr_os_only_vars {
  gen prev_`v' = 0
}

/* get male prevalence  */
merge 1:1 age using $tmp/india_pop, keep(match) nogen keepusing(male)
ren male prev_male
save $tmp/prev_india, replace

