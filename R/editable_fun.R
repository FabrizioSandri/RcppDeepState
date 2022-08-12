##' @title Generation and Checks TestHarness creation
##' @param package_path path to the test package
##' @param function_name function name in the package
##' @description This function creates two different testharness one for 
##' generating the vectors of user defined size that are created by deepstate 
##' and second for writing asserts/checks on the result/generated inputs.
##' @export
deepstate_editable_fun <- function(package_path, function_name) {
  gen <- deepstate_fun_create(package_path, function_name, sep="generation")
  chk <- deepstate_fun_create(package_path, function_name, sep="checks")
  
  c(gen, chk)
}

##' @title Generation test harness compilation and execution
##' @param package_path path to the tested package
##' @param function_name function name in the package
##' @param continue_on_missing if set to FALSE, terminates the execution if 
##' at leas one range is missing
##' @param verbose used to deliver more in depth information
##' @description This function compiles and runs the generation test harness.
##' The generation test harness contains user defined ranges 
##' @export
deepstate_compile_generate_fun <- function(package_path, function_name,
                      continue_on_missing=TRUE, verbose=getOption("verbose")){
  inst_path <- file.path(package_path, "inst")
  test_path <- file.path(inst_path,"testfiles")
  filename <- paste0(function_name,"_DeepState_TestHarness_generation.cpp")
  fun_path <- file.path(test_path,function_name)
  file_path <- file.path(test_path,function_name,filename)
  makefile.path <- file.path(test_path,function_name)
  if(file.exists(fun_path)){
    harness_lines <- readLines(file_path,warn=FALSE)
    range_elements <- nc::capture_all_str(harness_lines,"//",
                                          fun_call=".*","\\(")
                                          
    for(fun_range in range_elements$fun_call){
      missing_range <- grep(paste0(fun_range, "();"), harness_lines, value=TRUE,
                            fixed=TRUE)[1]

      if (!is.na(missing_range)){ # missing range
        variable = nc::capture_all_str(missing_range, val=".*", "=",
                                       " RcppDeepState_", type=".*","\\(")

        warn_msg <- paste0("The following range has not been specified:\n",
                           variable$val, " : ", variable$type)
        message(warn_msg)

        if(!continue_on_missing) {
          error_msg <- paste0("Execution stopped. Please provide the following",
                              " range : \n", variable$val, " : ", variable$type)
          stop(error_msg)
        }

      }
      
    }

    deepstate_fuzz_fun(package_path, fun_name, sep="generation", 
                       verbose=verbose)
    deepstate_analyze_fun(package_path, fun_name, sep="generation", 
                          verbose=verbose)

  }else{
    stop("Editable file doesn't exist. Run deepstate_editable_fun")
  }
}

##' @title Checks Testharness compilation and execution
##' @param package_path path to the testpackage
##' @param function_name function name in the package
##' @param continue_on_missing if set to FALSE, terminates the execution if 
##' asserts are missing
##' @param verbose used to deliver more in depth information
##' @description This function compiles and runs the checks test harness.
##' The checks test harness contains user defined assertions 
##' @export
deepstate_compile_checks_fun <- function(package_path, function_name,
                      continue_on_missing=TRUE, verbose=getOption("verbose")){
  test_path <- file.path(package_path, "inst", "testfiles")
  filename <- paste0(function_name, "_DeepState_TestHarness_checks.cpp")
  fun_path <- file.path(test_path, function_name)
  file_path <- file.path(test_path, function_name, filename)
  makefile.path <- file.path(test_path, function_name)
  if(file.exists(fun_path)){
    harness_lines <- readLines(file_path, warn=FALSE)
    assert_lines <- grep("ASSERT_", harness_lines, value=TRUE, fixed=TRUE)
    if(length(assert_lines) == 0) { # no assert line found
      warn_msg <- "No asserts are specified you still want to continue?"
      message(warn_msg)
      
      if(!continue_on_missing) {
        error_msg <- "Execution stopped. Please provide some assertions."
        stop(error_msg)
      }

    }
    deepstate_fuzz_fun(package_path, fun_name, sep="checks", verbose=verbose)
    deepstate_analyze_fun(package_path, fun_name, sep="checks", verbose=verbose)
      
  }else{
    stop("Editable file doesn't exist. Run deepstate_editable_fun")
  }
}