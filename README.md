# paper-covid-comorbidities
Replication code for results of "COVID-19 mortality effects of
underlying health conditions in India: a modelling study" by Paul
Novosad, Radhika Jain, Alison Campion, and Sam Asher in _BMJ
Open_, December 2020, accessed [here](https://bmjopen.bmj.com/content/10/12/e043165).

## Repository guide
To run the code, open `make_como.do`. Set the global filepaths at the
top of the file as directed in the comments. These global filepaths
must be set according correctly in order for any code to
run. `make_como.do` then walks you through all of the code in the
proper order.

### Dependencies
All stata code was run in Stata 16.

Python is used to create one of the figures. The environment
configuration file listing the required packages can be found in
`tools/py3.yml`. The environment can be created using conda by running
the following:
```
conda env create -f tools/py3.yml
conda activate py3
```
Any other package manager or python installation can be used, just
ensure the packages listed in the configuration file are
installed.

### Data build
The first section in `make_como.do` is the data build, which calls files in the build folder,
`code/b`. These files import microdata and generate the aggregated
analysis files used in the paper. The raw data is not included in
this repository, so this section is intended just to
show how we handled the microdata but not for individual users to run. Below is a diagram illustrating the
data build process. The outputs from the build process have been
generated and stored in the `data/` folder, where they can be sourced
to run the analysis.

![alt text](https://github.com/devdatalab/paper-covid-comorbidities/blob/main/assets/covid-como-build.png "Data build workflow")

### Data analysis
The second section of `make_como.do` is the data analysis portion,
calling files in the analysis folder, `code/a`. Figures and tables
output by the analysis will be stored in `outputs/`.  Below is a
diagram illustrating the analysis.

![alt text](https://github.com/devdatalab/paper-covid-comorbidities/blob/main/assets/covid-como-analysis.png "Analysis workflow")

### Findings
All results can be combined into a pdf by typesetting the file
`tex/results.tex`.  This file will include the 4 figures and 2 tables
included in the paper.

![alt text](https://github.com/devdatalab/paper-covid-comorbidities/blob/main/assets/figure4.png "Figure 4")

