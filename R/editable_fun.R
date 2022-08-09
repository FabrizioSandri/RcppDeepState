##' @title Generation and Checks TestHarness creation
##' @param package_path path to the test package
##' @param function_name function name in the package
##' @description This function creates two different testharness one for generating the vectors of 
##' user defined size that are creatd by deepstate and second for writing asserts/checks 
##' on the result/generated inputs.
##' @export
deepstate_editable_fun<-function(package_path,function_name){
  deepstate_fun_create(package_path,function_name,sep="generation")  
  deepstate_fun_create(package_path,function_name,sep="checks")  
}

##' @title  Generation Testharness compilation
##' @param package_path path to the testpackage
##' @param function_name function name in the package
##' @description This function compiles the generation testharness.
##' @export
deepstate_compile_generate_fun <-function(package_path,function_name){
  inst_path <- file.path(package_path, "inst")
  test_path <- file.path(inst_path,"testfiles")
  filename  <- paste0(function_name,"_DeepState_TestHarness_generation.cpp")
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

        response <- readline(prompt="Enter y/n to continue/exit:\n")
        if(response != 'y') {
          error_msg <- paste0("Execution stopped. Please provide the following",
                              " range : \n", variable$val, " : ", variable$type)
          stop(error_msg)
        }

      }
      
    }

    fun_generated <- deepstate_fuzz_fun(package_path, fun_name, sep="generation")
    print(fun_generated)
    final_res <- deepstate_analyze_fun(package_path, fun_name, sep="generation")
    print(final_res)

  }else{
    stop("Editable file doesn't exist. Run deepstate_editable_fun")
  }
}

##' @title  Checks Testharness compilation
##' @param package_path path to the testpackage
##' @param function_name function name in the package
##' @description This function compiles the checks testharness.
##' @export
deepstate_compile_checks_fun <-function(package_path,function_name){
  inst_path <- file.path(package_path, "inst")
  test_path <- file.path(inst_path,"testfiles")
  filename  <- paste0(function_name,"_DeepState_TestHarness_checks.cpp")
  missing_range <- list()
  fun_path <- file.path(test_path,function_name)
  file_path <- file.path(test_path,function_name,filename)
  makefile.path <- file.path(test_path,function_name)
  if(file.exists(fun_path)){
    harness_lines <- readLines(file_path,warn=FALSE)
     range_check <- grep("ASSERT_",harness_lines,value = TRUE,fixed=TRUE)
     if(length(range_check) == 0)
      message(sprintf("No asserts are specified you still want to continue?"))
      response <- readline(prompt="Enter y/n to continue/exit:\n")
      if(response == 'y' || length(range_check) > 0){
        fun_generated <- deepstate_fuzz_fun(package_path, fun_name, sep="checks")
        print(fun_generated)
        final_res <- deepstate_analyze_fun(package_path, fun_name, sep="generation")
        print(final_res)
      }
    }else{
    stop("Editable file doesn't exist. Run deepstate_editable_fun")
  }
}