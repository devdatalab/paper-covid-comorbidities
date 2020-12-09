qui {

  /*********************************************************************************************************/
  /* program ddrop : drop any observations that are duplicated - not to be confused with "duplicates drop" */
  /*********************************************************************************************************/
  cap prog drop ddrop
  cap prog def ddrop
  {
    syntax varlist(min=1) [if]

    /* do nothing if no observations */
    if _N == 0 exit
    
    /* `0' contains the `if', so don't need to do anything special here */
    duplicates tag `0', gen(ddrop_dups)
    drop if ddrop_dups > 0 & !mi(ddrop_dups) 
    drop ddrop_dups
  }
  end
  /* *********** END program ddrop ***************************************** */



  /*********************************************************************************/
  /* program winsorize: replace variables outside of a range(min,max) with min,max */
  /*********************************************************************************/
  cap prog drop winsorize
  prog def winsorize
  {
    syntax anything,  [REPLace GENerate(name) centile]
  
    tokenize "`anything'"
  
    /* require generate or replace [sum of existence must equal 1] */
    if (!mi("`generate'") + !mi("`replace'") != 1) {
      display as error "winsorize: generate or replace must be specified, not both"
      exit 1
    }
  
    if ("`1'" == "" | "`2'" == "" | "`3'" == "" | "`4'" != "") {
      di "syntax: winsorize varname [minvalue] [maxvalue], [replace generate] [centile]"
      exit
    }
    if !mi("`replace'") {
      local generate = "`1'"
    }
    tempvar x
    gen `x' = `1'
  
  
    /* reset bounds to centiles if requested */
    if !mi("`centile'") {
  
      centile `x', c(`2')
      local 2 `r(c_1)'
  
      centile `x', c(`3')
      local 3 `r(c_1)'
    }
  
    di "replace `generate' = `2' if `1' < `2'  "
    replace `x' = `2' if `x' < `2'
    di "replace `generate' = `3' if `1' > `3' & !mi(`1')"
    replace `x' = `3' if `x' > `3' & !mi(`x')
  
    if !mi("`replace'") {
      replace `1' = `x'
    }
    else {
      generate `generate' = `x'
    }
  }
  end
  /* *********** END program winsorize ***************************************** */

  /**********************************************************************************/
  /* program tag : Fast way to run egen tag(), using first letter of var for tag    */
  /**********************************************************************************/
  cap prog drop tag
  prog def tag
  {
    syntax anything [if]
  
    tokenize "`anything'"
  
    local x = ""
    while !mi("`1'") {
  
      if regexm("`1'", "pc[0-9][0-9][ru]?_") {
        local x = "`x'" + substr("`1'", strpos("`1'", "_") + 1, 1)
      }
      else {
        local x = "`x'" + substr("`1'", 1, 1)
      }
      mac shift
    }
  
    display `"RUNNING: egen `x'tag = tag(`anything') `if'"'
    egen `x'tag = tag(`anything') `if'
  }
  end
  /* *********** END program tag ***************************************** */
  
  /**********************************************************************************/
  /* program normalize: demean and scale by standard deviation */
  /***********************************************************************************/
  cap prog drop normalize
  prog def normalize
  {
    syntax varname, [REPLace GENerate(name)]
    tokenize `varlist'

    /* require generate or replace [sum of existence must equal 1] */
    if ((!mi("`generate'") + !mi("`replace'")) != 1) {
      display as error "normalize: generate or replace must be specified, not both"
      exit 1
    }

    tempvar tmp

    cap drop __mean __sd
    egen __mean = mean(`1')
    egen __sd = sd(`1')
    gen `tmp' = (`1' - __mean) / __sd
    drop __mean __sd

    /* assign created variable based on replace or generate option */
    if "`replace'" == "replace" {
      replace `1' = `tmp'
    }
    else {
      gen `generate' = `tmp'
    }
  }
  end
  /* *********** END program normalize ***************************************** */

  /**********************************************************************************/
  /* program lf : Better version of lf */
  /***********************************************************************************/
  cap prog drop lf
  prog def lf
  {
    syntax anything
    d *`1'*, f
  }
  end
  /* *********** END program lf ***************************************** */


  cap prog drop group
  prog def group
  {
    syntax anything [if], [drop]
  
    tokenize "`anything'"
  
    local x = ""
    while !mi("`1'") {
  
      if regexm("`1'", "pc[0-9][0-9][ru]?_") {
        local x = "`x'" + substr("`1'", strpos("`1'", "_") + 1, 1)
      }
      else {
        local x = "`x'" + substr("`1'", 1, 1)
      }
      mac shift
    }
  
    if ~mi("`drop'") cap drop `x'group
  
    display `"RUNNING: egen int `x'group = group(`anything')" `if''
    egen int `x'group = group(`anything') `if'
  }
  end
  /* *********** END program group ***************************************** */


  /****************************************************************/
  /* program get_state_ids : merge in state_ids using state_names */
  /****************************************************************/
  /* get state ids ( y(91) if want 1991 ids ) */
  cap prog drop get_state_ids
  prog def get_state_ids
  {
    syntax , [Year(string)]

    /* default is 2001 */
    if mi("`year'") {
      local year 01
    }

    /* merge to the state key on state name */
    merge m:1 pc`year'_state_name using $keys/pc`year'_state_key, gen(_gsn_merge) update replace

    /* display state names that did not match the key */
    di "unmatched names: "
    cap noi table pc`year'_state_name if _gsn_merge == 1

    /* drop places that were only in the key */
    drop if _gsn_merge == 2
    drop _gsn_merge

  }
  end

  /**********************************************************************************/
  /* program fail : Fail with an error message */
  /***********************************************************************************/
  cap prog drop fail
  prog def fail
    syntax anything
    display as error "`anything'"
    error 345
  end
  /* *********** END program fail ***************************************** */

  /**********************************************************************************/
  /* program disp_nice : Insert a nice title in stata window */
  /***********************************************************************************/
  cap prog drop disp_nice
  prog def disp_nice
  {
    di _n "+--------------------------------------------------------------------------------------" _n `"| `1'"' _n  "+--------------------------------------------------------------------------------------"
  }
  end
  /* *********** END program disp_nice ***************************************** */
  
  /**********************************************************************************/
  /* program capdrop : Drop a bunch of variables without errors if they don't exist */
  /**********************************************************************************/
  cap prog drop capdrop
  prog def capdrop
  {
    syntax anything
    foreach v in `anything' {
      cap drop `v'
    }
  }
  end
  /* *********** END program capdrop ***************************************** */

  /**************************************************************************************************/
  /* program app : short form of append_to_file: app $f, s(foo) == append_to_file using $f, s(foo) */
  /**************************************************************************************************/
  cap prog drop app
  prog def app
  {
    syntax anything, s(passthru) [format(passthru) erase(passthru)]
    append_to_file using `anything', `s' `format' `erase'
  }
  end
  /* *********** END program app ***************************************** */

  /**********************************************************************************/
  /* program graphout : Export graph to public_html/png and pdf form                */
  /* defaults:
     - on MacOS, exports a pdf to $tmp
  */
  
  /* options:
     - pdf: export a pdf to $out
     - pdfout(path): specifies an alternate filename or path for the pdf
                     i.e.:  mv file.pdf `pdfout'
  */
  /**********************************************************************************/
  cap prog drop gt
  prog def gt
  {
    syntax anything, [pdf pdfout(passthru)]
    graphout `1', `pdf' `pdfout'
  }
  end

  cap prog drop graphout
  prog def graphout
    
    syntax anything, [small png pdf pdfout(string) QUIet rescale(real 100)]

    /* strip space from anything */
    local anything = subinstr(`"`anything'"', " ", "", .)

    /* make everything quiet from here */
    qui {

      /* always start with an eps file to $tmp */
      graph export `"$tmp/`anything'.eps"', replace 
      local linkpath `"$tmp/`anything'.eps"'

      /* if small is specified, specify size */
      if "`small'" == "small" {
        local size 480x480
      }

      if "`small'" == ""{
        local size 960x960
      }
      
      /* if "pdf" is specified, send a PDF to $out */
      if "`pdf'" == "pdf" {

        /* convert the eps to pdf in the $tmp folder */
        // noi di "Converting EPS to PDF..."
        shell epstopdf $tmp/`anything'.eps

        /* now move it to its destination, which is $out or `pdfout' */
        if mi("`pdfout'")  local out $out
        if !mi("`pdfout'") local out `pdfout'
        shell mv $tmp/`anything'.pdf `out'
          
        /* set output path for link */
        local linkpath `out'/`anything'.pdf
      }

      /* if png is specified, save png to out folder */
      if ("`png'" != "") {
      
        /* create a large png */
        shell convert -size `size' -resize `size' -density 300 $tmp/`anything'.eps $tmp/`anything'.png

        /* save in out folder */
        cap erase $out/`anything'.png
        shell convert $tmp/`anything'.png -resize `rescale'% $out/`anything'.png
      }

  end
  /* *********** END program graphout ***************************************** */

}
