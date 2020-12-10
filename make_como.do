/************************/
/* set global filepaths */
/************************/

/* define ccode as the root directory of the repository */
global ccode ~/paper-covid-comorbidities

/* define a filepath where intermediate outputs are stored */
global tmp $ccode/tmp
cap mkdir $tmp

/* define a filepath to the data folder in this repository */
global datafp $ccode/data

/* define a filepath to the results folder in this repository */
global out $ccode/outputs

/*************************************/
/* set global variables for analysis */
/*************************************/

/* define age bin indicator variables */
global age_vars age18_40 age40_50 age50_60 age60_70 age70_80 age80_

/* define biomarker variables from DLHS/AHS that match NHS hazard ratio vars */
global hr_biomarker_vars obese_1_2 obese_3 bp_high diabetes_uncontr diabetes_contr

/* define non-biomarker GBD variables that match NHS hazard ratio vars */
global hr_gbd_vars asthma_ocs autoimmune_dz haem_malig_1 cancer_non_haem_1    ///
    chronic_heart_dz chronic_resp_dz immuno_other_dz kidney_dz liver_dz neuro_other ///
    stroke_dementia

/* define varlist found only in opensafely */
global hr_os_only_vars asthma_no_ocs cancer_non_haem_1_5 cancer_non_haem_5 diabetes_no_measure haem_malig_1_5 haem_malig_5 organ_transplant spleen_dz

/* run the configuration file */
do $ccode/config.do

/* load the necessary tools */
do $ccode/tools/tools.do
do $ccode/tools/stata-tex.do

/*********************/
/* data construction */
/*********************/
/* the files in this section document the cleaning and merging of 
   all microdata used in this study. the original microdata is
   not available in this repository. skip to the analysis 
   section to replicate paper results.
*/

/* get continuous fit to UK age hazard ratios */
cd $ccode
shell matlab $ccode/b/fit_cts_uk_age_hr.m

/* combine DLHS and AHS */
do $ccode/b/prep_health_data.do

/* prepare global burden of disease data */
do $ccode/b/prep_gbd.do

/* calculate risk factors */
do $ccode/b/prep_india_comorbidities.do

/* create an age-level dataset with England condition prevalence */
do $ccode/b/prep_england_prevalence.do

/* create a clean set of files with relative risks */
do $ccode/b/prep_hrs.do

/* prep india and UK sex ratios and populations */
do $ccode/b/prep_pop_sex.do

/* create age-level datasets for HR, prevalence, population, all with identical structures */
/* THIS CREATES THE MAIN ANALYSIS FILE */
do $ccode/b/prep_age_level_data.do

/* create prevalence standard errors for bootstraps */
do $ccode/b/prep_standard_errors.do

/************/
/* analysis */
/************/
/* the files in this section draw from the aggregated data output by
   the data construction and saved in this repository in the /data
   folder. run these files to reproduce paper results.
*/

/* calculate population relative risks and death distributions for england / india */
do $ccode/a/calc_prrs.do

/* prepare data for England / India prevalence comparison */
do $ccode/a/prep_eng_india_prev_compare.do

/* create tables for main text and appendix*/
do $ccode/a/make_paper_tables.do

/* create figures */
do $ccode/a/make_paper_figures.do
