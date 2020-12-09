/*********************/
/* data construction */
/*********************/
/* the files in this section document the cleaning and merging of 
   all microdata used in this study. the original microdata is
   not available in this repository. skip to the analysis 
   section to replicate paper results.
*/

/* get continuous fit to UK age hazard ratios */
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

/* prep NY odds ratios of death */
do $ccode/b/prep_ny_mortality.do

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
