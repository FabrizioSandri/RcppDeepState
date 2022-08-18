##' @title Analyze Harness for the Package
##' @param path path of the test package to analyze
##' @param max_inputs maximum number of inputs to run on the executable under 
##' valgrind. Defaults to all
##' @param testfiles number of functions to analyze in the package
##' @param verbose used to deliver more in depth information
##' @description Analyze all the function specific testharness in the package 
##' under valgrind.
##' @examples
##' path <- system.file("testpkgs/testSAN", package = "RcppDeepState")
##' analyzed.harness <- deepstate_harness_analyze_pkg(path)
##' print(analyzed.harness)
##' @return A list of data tables with inputs, error messages, address trace and
##' line numbers for specified testfiles.
##' @import methods
##' @import Rcpp
##' @import qs
##' @export
deepstate_harness_analyze_pkg <- function(path,testfiles="all",max_inputs="all", 
                                          verbose=getOption("verbose")){
  path <-normalizePath(path, mustWork=TRUE)
  package_name <- sub("/$","",path)
  list_testfiles <- list()
  inst_path <- file.path(package_name, "inst")
  if(!dir.exists(inst_path)){
    dir.create(inst_path)
  }
  test_path <- file.path(inst_path,"testfiles")
  if(file.exists(test_path)){
    packagename <- get_package_name(package_name)
    test.files <- Sys.glob(paste0(test_path,"/*"))
    if(testfiles != "all"){
      test.files <- test.files[1:testfiles]
    }
    for(pkg.i in seq_along(test.files)){
      fun_name <- basename(test.files[[pkg.i]])
      list_testfiles[[basename(test.files[[pkg.i]])]] <- deepstate_analyze_fun(
          package_path=path, fun_name=fun_name, max_inputs=max_inputs, 
          verbose=verbose)
    }
    list_testfiles <- do.call(rbind,list_testfiles)

    return(list_testfiles)
  }
  else{
    message(sprintf("Please make a call to deepstate_harness_compile_run()"))
    return(message(sprintf("Testharness doesn't exists for package %s\n:",basename(path))))
    
  }
}


##' @title analyze the binary file 
##' @param test_function path of the test function
##' @param seed input seed to pass on the executable
##' @param time_limit duration to run the code
##' @param verbose used to deliver more in depth information
##' @export
deepstate_fuzz_fun_analyze <- function(test_function,seed=-1,time_limit, 
                                       verbose=getOption("verbose")) {
  test_function <- normalizePath(test_function,mustWork = TRUE)
  fun_name <- basename(test_function)
  seed_log_analyze <- data.table()
  inputs_list<- list()
  output_folder <- file.path(test_function,paste0(time_limit,"_",seed))
  if(!dir.exists(output_folder)){
    dir.create(output_folder)
  }
  inputs.path <- Sys.glob(file.path(test_function,"inputs/*"))
  test_harness.cpp <- file.path(test_function, paste0(fun_name, 
                                "_DeepState_TestHarness.cpp"))
  test_harness.o <- file.path(test_function, paste0(fun_name, 
                              "_DeepState_TestHarness.o"))
  valgrind_log_xml <- file.path(output_folder,paste0(seed,"_log"))
  valgrind_log_txt <- file.path(output_folder,"valgrind_log_text")
  if(!file.exists(test_harness.o)){
    deepstate_compile_fun(test_function, verbose=verbose)
  }
  if(time_limit <= 0){
    stop("time_limit should always be greater than zero")
  }

  # get the test name for the runner
  harness_file <- readLines(test_harness.cpp)
  runner_line <- harness_file[grepl("^TEST.*runner", harness_file)]
  runner_line_split <- strsplit(runner_line, "[(|)| +|,]")[[1]]
  runner_harness_name <- paste0(runner_line_split[2], "_", runner_line_split[4])

  seed_param <- if(seed != -1) paste0("--seed=", seed) else ""
  timeout_param <- if(time_limit != -1) paste0("--timeout=", time_limit) else ""
  
  executable_run <- paste0("cd ", test_function, " && valgrind --xml=yes ",
           "--xml-file=",valgrind_log_xml," --tool=memcheck --leak-check=full ",
           "--track-origins=yes ", "./", basename(test_function),
           "_DeepState_TestHarness ", seed_param, " ", timeout_param,
           " --fuzz --input_which_test ", runner_harness_name, " > ",
           valgrind_log_txt," 2>&1")

  if (verbose){
    message(sprintf("running the executable .. \n%s\n", executable_run))
  }
  exit_code <- system(executable_run, ignore.stdout=!verbose)
  valgrind_log_content <- readLines(valgrind_log_txt)
  fuzzing_crash <- all(grepl("Starting fuzzing", valgrind_log_content)==FALSE)
  if (exit_code != 0 && fuzzing_crash){
    error_msg <- paste("The function", fun_name, "has not been analyzed due to",
                       "some errors while running the test harness. You can",
                       "find more details inside", valgrind_log_txt)
    stop(error_msg)
  }


  for(inputs.i in seq_along(inputs.path)){
    file.copy(inputs.path[[inputs.i]],output_folder)
    input_file <- basename(inputs.path[[inputs.i]])
    if(grepl(".qs",inputs.path[[inputs.i]],fixed = TRUE)){
      input_name <- gsub(".qs","",input_file)
      inputs_list[[input_name]] <- qread(inputs.path[[inputs.i]])
    }else{
      inputs_list[[input_file]] <- scan(inputs.path[[inputs.i]],quiet = TRUE)
    }
  }
  
  logtable <- deepstate_read_valgrind_xml(valgrind_log_xml)
  data.table(inputs=list(inputs_list),logtable=list(logtable))
}


