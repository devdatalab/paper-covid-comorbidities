/* create csv files */
cap !rm -f $tmp/covid_como_agerisks.csv
cap !rm -f $tmp/covid_como_sumstats.csv

/**********************************************************************************************/
/* Store England PRRs relative to India for each health condition for tex tables and coefplot */
/**********************************************************************************************/
use $tmp/prr_result, clear

/* save all india and england aggregate prr values by comorbidity, and ratio */
foreach v in male $hr_biomarker_vars $hr_gbd_vars health {
  
  /* england aggregate risk factor */
  qui sum uprr_`v' [aw=eng_pop]
  local umean = `r(mean)'
  
  /* India aggregate risk factor */
  qui sum iprr_`v' [aw=india_pop]
  local imean = `r(mean)'

  /* percent difference India over England */
  local perc = (`imean'/`umean' - 1) * 100

  /* Get the sign on the % */
  if `perc' > 0 local sign " +"
  else local sign " "

  /* save everying in csv for table */
  insert_into_file using $tmp/covid_como_sumstats.csv, key(eng_`v'_risk) value("`umean'") format(%4.3f)  
  insert_into_file using $tmp/covid_como_sumstats.csv, key(india_`v'_risk) value("`imean'") format(%4.3f)
  insert_into_file using $tmp/covid_como_sumstats.csv, key(`v'_ratio_sign) value("`sign'")
  insert_into_file using $tmp/covid_como_sumstats.csv, key(`v'_ratio) value("`perc'") format(%3.2f)  
}

/**************************************************/
/* Store prevalences into a CSV for a latex table */
/**************************************************/

/* open national, weighted prevalences */
use $datafp/india_como_prev, clear

/* get all total population prevalences for table 1 */
foreach var in age18_40 age40_50 age50_60 age60_70 age70_80 age80_ male diabetes_uncontr diabetes_contr hypertension_both obese_3 obese_1_2{

  /* get value for this variable */
  qui sum `var'
  
  /* multiply the percentage by 100 for the table */
  local mu = `r(mean)'*100

  /* add the  mean to the csv that will feed the latex table values */
  insert_into_file using $tmp/covid_como_sumstats.csv, key(india_`var'_mu) value("`mu'") format(%2.1f)
}

/* age-specific prevalences for India */
use $datafp/prev_india, clear
ren prev_* *
gen hypertension_both = hypertension_uncontr + hypertension_contr
merge 1:1 age using $datafp/india_pop, keep(match) nogen

/* get all the age-specific prevalences for the appendix table */
foreach var in male diabetes_uncontr diabetes_contr hypertension_both obese_3 obese_1_2  {

  /* 18-40 */
  qui sum `var' [aw=india_pop] if age >=18 & age < 40
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(india_`var'_18_40) value("`mu'") format(%2.1f)
  
  /* 40-49 */
  qui sum `var' [aw=india_pop] if age >=40 & age < 50
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(india_`var'_40_50) value("`mu'") format(%2.1f)

  /* 50-60 */
  qui sum `var' [aw=india_pop] if age >=50 & age < 60
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(india_`var'_50_60) value("`mu'") format(%2.1f)

  /* 60-70 */
  qui sum `var' [aw=india_pop] if age >=60 & age < 70
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(india_`var'_60_70) value("`mu'") format(%2.1f)

  /* 70-80 */
  qui sum `var' [aw=india_pop] if age >= 70 & age < 80
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(india_`var'_70_80) value("`mu'") format(%2.1f)

  /* 80+ */
  qui sum `var' [aw=india_pop] if age >=80
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(india_`var'_80_) value("`mu'") format(%2.1f)
}

/* do the England demographics */
use $datafp/eng_pop, clear
keep if age >= 18

/* get total population total */
qui sum eng_pop
local tot_pop = `r(sum)'

/* get each age bracket */
qui sum eng_pop if age >= 18 & age < 40
local pop_frac = (`r(sum)' / `tot_pop') * 100
insert_into_file using $tmp/covid_como_sumstats.csv, key(eng_age_18_40) value("`pop_frac'") format(%2.1f)

qui sum eng_pop if age >= 40 & age < 50
local pop_frac = (`r(sum)' / `tot_pop') * 100
insert_into_file using $tmp/covid_como_sumstats.csv, key(eng_age_40_50) value("`pop_frac'") format(%2.1f)

qui sum eng_pop if age >= 50 & age < 60
local pop_frac = (`r(sum)' / `tot_pop') * 100
insert_into_file using $tmp/covid_como_sumstats.csv, key(eng_age_50_60) value("`pop_frac'") format(%2.1f)

qui sum eng_pop if age >= 60 & age < 70
local pop_frac = (`r(sum)' / `tot_pop') * 100
insert_into_file using $tmp/covid_como_sumstats.csv, key(eng_age_60_70) value("`pop_frac'") format(%2.1f)

qui sum eng_pop if age >= 70 & age < 80
local pop_frac = (`r(sum)' / `tot_pop') * 100
insert_into_file using $tmp/covid_como_sumstats.csv, key(eng_age_70_80) value("`pop_frac'") format(%2.1f)

qui sum eng_pop if age >= 80
local pop_frac = (`r(sum)' / `tot_pop') * 100
insert_into_file using $tmp/covid_como_sumstats.csv, key(eng_age_80) value("`pop_frac'") format(%2.1f)

/* Do the GBD comorbidities for both India and the ENG */
foreach geo in india eng {

  use $datafp/gbd_nhs_conditions_`geo', clear

  /* keep only the age standardized data  */
  keep if age == -90

  foreach var in gbd_chronic_heart_dz gbd_chronic_resp_dz gbd_kidney_dz gbd_liver_dz gbd_asthma_ocs gbd_cancer_non_haem_1 gbd_haem_malig_1  gbd_autoimmune_dz gbd_immuno_other_dz gbd_stroke_dementia gbd_neuro_other {
    qui sum `var'_granular
    local mu = `r(mean)'*100
    insert_into_file using $tmp/covid_como_sumstats.csv, key(`geo'_`var'_mu) value("`mu'") format(%2.1f)
  }
}


/* Do age-specific prevalences of GBD variables */
foreach geo in india eng {

  use $datafp/gbd_nhs_conditions_`geo', clear

  /* drop age standardized and all age values */
  drop if age == -90
  drop if age ==  -99

  /* merge in population data */
  merge 1:1 age using $datafp/`geo'_pop, keep(match master)

  foreach var in gbd_chronic_heart_dz gbd_chronic_resp_dz gbd_kidney_dz gbd_liver_dz gbd_asthma_ocs gbd_cancer_non_haem_1 gbd_haem_malig_1  gbd_autoimmune_dz gbd_immuno_other_dz gbd_stroke_dementia gbd_neuro_other {

    /* 18 - 40 */
    qui sum `var' [aw=`geo'_pop] if age >= 18 & age < 40
    local mu = `r(mean)'*100
    insert_into_file using $tmp/covid_como_agerisks.csv, key(`geo'_`var'_18_40) value("`mu'") format(%2.1f)

    /* 40 - 50 */
    qui sum `var' [aw=`geo'_pop] if age >= 40 & age < 50
    local mu = `r(mean)'*100
    insert_into_file using $tmp/covid_como_agerisks.csv, key(`geo'_`var'_40_50) value("`mu'") format(%2.1f)

    /* 50 - 60 */
    qui sum `var' [aw=`geo'_pop] if age >= 50 & age < 60
    local mu = `r(mean)'*100
    insert_into_file using $tmp/covid_como_agerisks.csv, key(`geo'_`var'_50_60) value("`mu'") format(%2.1f)

    /* 60 - 70 */
    qui sum `var' [aw=`geo'_pop] if age >= 60 & age < 70
    local mu = `r(mean)'*100
    insert_into_file using $tmp/covid_como_agerisks.csv, key(`geo'_`var'_60_70) value("`mu'") format(%2.1f)

    /* 70 - 80 */
    qui sum `var' [aw=`geo'_pop] if age >= 70 & age < 80
    local mu = `r(mean)'*100
    insert_into_file using $tmp/covid_como_agerisks.csv, key(`geo'_`var'_70_80) value("`mu'") format(%2.1f)
  
    /* 80+ */
    qui sum `var' [aw=`geo'_pop] if age >= 80
    local mu = `r(mean)'*100
    insert_into_file using $tmp/covid_como_agerisks.csv, key(`geo'_`var'_80_) value("`mu'") format(%2.1f)
  }
}


/* do the ENG prevalence */
use $tmp/eng_prevalences, clear
drop if age > 99
merge 1:1 age using $datafp/eng_pop, keep(match master) nogen

foreach var in male eng_prev_diabetes_contr eng_prev_diabetes_uncontr eng_prev_chronic_resp_dz eng_prev_hypertension_both eng_prev_obese_3 eng_prev_obese_1_2 {
  qui sum `var' [aw=eng_pop]
  local mu = `r(mean)'*100
  insert_into_file using $datafp/covid_como_sumstats.csv, key(`var') value("`mu'") format(%2.1f)
}

/* get all age-specific prevalences from eng data */
foreach var in male eng_prev_chronic_resp_dz eng_prev_diabetes_contr eng_prev_diabetes_uncontr eng_prev_hypertension_both eng_prev_obese_3 eng_prev_obese_1_2 {

  /* 18 - 40 */
  qui sum `var' [aw=eng_pop] if age >= 18 & age < 40
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(`var'_18_40) value("`mu'") format(%2.1f)

  /* 40 - 50 */
  qui sum `var' [aw=eng_pop] if age >= 40 & age < 50
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(`var'_40_50) value("`mu'") format(%2.1f)

  /* 50 - 60 */
  qui sum `var' [aw=eng_pop] if age >= 50 & age < 60
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(`var'_50_60) value("`mu'") format(%2.1f)

  /* 60 - 70 */
  qui sum `var' [aw=eng_pop] if age >= 60 & age < 70
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(`var'_60_70) value("`mu'") format(%2.1f)

  /* 70 - 80 */
  qui sum `var' [aw=eng_pop] if age >= 70 & age < 80
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(`var'_70_80) value("`mu'") format(%2.1f)

  /* 80+ */
  qui sum `var' [aw=eng_pop] if age >= 80
  local mu = `r(mean)'*100
  insert_into_file using $tmp/covid_como_agerisks.csv, key(`var'_80_) value("`mu'") format(%2.1f)

}

/* create the prevalence table 1 */
table_from_tpl, t($ccode/a/tpl/covid_como_sumstats_tpl.tex) r($tmp/covid_como_sumstats.csv) o($out/covid_como_sumstats.tex)

/* create the risk table 2 */
table_from_tpl, t($ccode/a/tpl/covid_como_sumhr_tpl.tex) r($tmp/covid_como_sumstats.csv) o($out/covid_como_sumhr.tex)

/* create the age-specific prevalence appendix table */
table_from_tpl, t($ccode/a/tpl/covid_como_agerisks_tpl.tex) r($tmp/covid_como_agerisks.csv) o($out/covid_como_agerisks.tex)

/* create the o/s vs. england  prevalence appendix table */
table_from_tpl, t($ccode/a/tpl/covid_como_oscompare_tpl.tex) r($tmp/covid_como_sumstats.csv) o($out/covid_como_oscompare.tex)

