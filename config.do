/****************************************/
/* set globals used throughout analysis */
/****************************************/

/* MAIN COMORBID CONDITION SETS USED IN THE PAPER */

/* define ccode as the root directory of the repository */
global ccode ~/paper-covid-comorbidities

/* define a filepath where intermediate outputs are stored */
global tmp $ccode/tmp
cap mkdir $tmp

/* define a filepath to the data folder in this repository */
global datafp $ccode/data

/* define a filepath to the results folder in this repository */
global out $ccode/outputs

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

