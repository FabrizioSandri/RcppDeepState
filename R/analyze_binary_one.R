##' @title Analyze Harness for the function
##' @param package_path path to the test package
##' @param fun_name path of the function to compile
##' @param max_inputs maximum number of inputs to run on the executable under 
##' valgrind. defaults to all
##' @param sep default to infun
##' @param verbose used to deliver more in depth information
##' @description Analyzes the function-specific testharness in the package under
##' valgrind.
##' @examples
##' #package_path <- system.file("testpkgs/testSAN", package = "RcppDeepState")
##' #fun_name <- "rcpp_read_out_of_bound"
##' #analyzed.fun <- deepstate_analyze_fun(package_path,fun_name)
##' #print(analyzed.fun)
##' @return A data table with inputs, error messages, address trace and line
##' numbers
##' @export
deepstate_analyze_fun <- function(package_path, fun_name, max_inputs="all",
                                  sep="infun", verbose=getOption("verbose")){
                                    
  fun_path <- file.path(package_path,"inst/testfiles",fun_name)
  fun_path <- normalizePath(fun_path, mustWork=TRUE)
  package_name <- get_package_name(package_path)
  if(file.exists(fun_path)){
    bin.path <- if(sep == "generation" || sep == "checks"){
      file.path( fun_path ,paste0(fun_name,"_output","_",sep))
    }else{
      file.path( fun_path ,paste0(fun_name,"_output"))
    }
    bin.files <- Sys.glob(file.path(bin.path,"*"))
    if(length(bin.files) == 0){
      warn_msg <- paste("No bin files exists for function", fun_name)
      return(message(warn_msg))
    }
    if(max_inputs != "all" && max_inputs <= length(bin.files) && 
       length(bin.files) > 0){
      bin.files <- bin.files[1:max_inputs]
    }else{
      if(length(bin.files) > 3){ 
        bin.files <- bin.files[1:3] 
      }
    }
    final_table=list()
    for(bin.i in seq_along(bin.files)){
      current.list <- list()
      bin.path.i <- bin.files[[bin.i]]
      current.list <-  deepstate_analyze_file(package_name, bin.path.i, verbose)
      final_table[[bin.path.i]] <- current.list 
    }
    final_table <- do.call(rbind,final_table)
    return(final_table)
  }
  else{
    return(message(sprintf("Testharness doesn't exists for %s\n:",fun_path)))
  }
}


##' @title Analyze Binary file for Harness
##' @param package_name name of the package of the harness being analyzed
##' @param files.path path to the binary file to analyze
##' @param verbose used to deliver more in depth information
##' @description Analyzes the function-specific binary file in the package under
##' valgrind
##' @return A data table with inputs, error messages, address trace and line 
##' numbers
##' package_path <- system.file("testpkgs/testSAN", package = "RcppDeepState")
##' fun_name <- "rcpp_read_out_of_bound"
##' binary.dir <- file.path(package_path,"inst/testfiles",fun_name,paste0(fun_name,"_output"))
##' binary.files <- Sys.glob(file.path(binary.dir,"*"))
##' print(binary.files[1])
##' analyze.result <- deepstate_analyze_file(binary.files[1])
##' print(analyze.result)
##' @export
deepstate_analyze_file <- function(package_name, files.path,
                          verbose=getOption("verbose")){
  inputs_list<- list()
  final_table <- list()
  if(file.exists(files.path)){
    files.path <-normalizePath(files.path, mustWork=TRUE)
    exec <- paste0("./",gsub("_output","_DeepState_TestHarness",
                   basename(dirname(files.path)))) 
    output_folder <- file.path(dirname(files.path),paste0("log_",sub('\\..*', 
                               '', basename(files.path))))
    dir.create(output_folder,showWarnings = FALSE)
    valgrind_log_xml <- file.path(output_folder,"valgrind_log")
    valgrind_log_txt <- file.path(output_folder,"valgrind_log_text")
    analyze_one <- paste0("valgrind --xml=yes --xml-file=", valgrind_log_xml,
                          " --tool=memcheck --leak-check=yes ", exec, 
                          " --input_test_file ", files.path, 
                          " --input_which_test ", package_name, "_runner > ",
                          valgrind_log_txt, " 2>&1")
    executable_run <- paste("cd",dirname(dirname(files.path)),";", analyze_one) 
    if (verbose){
      print(executable_run)
    }
    exit_code <- system(executable_run, ignore.stdout=!verbose)
    valgrind_log_content <- readLines(valgrind_log_txt)
    fuzzing_crash <- all(grepl("Initialized test input buffer", 
                               valgrind_log_content)==FALSE)
    if (exit_code != 0 && fuzzing_crash){
      error_msg <- paste("The file", files.path, "has not been analyzed due to",
                      "some errors while running the test harness. You can",
                      "find more details inside", valgrind_log_txt)
      stop(error_msg)
    }

    inputs.path <- Sys.glob(file.path(dirname(dirname(files.path)),"inputs/*"))
    logtable <- deepstate_read_valgrind_xml(valgrind_log_xml)
    for(inputs.i in seq_along(inputs.path)){
      file.copy(inputs.path[[inputs.i]],output_folder)
      if(grepl(".qs",inputs.path[[inputs.i]],fixed = TRUE)){
        inputs_file <- gsub(".qs","",basename(inputs.path[[inputs.i]]))
        inputs_list[[inputs_file]] <- qread(inputs.path[[inputs.i]])
      }else{
        inputs_file <- basename(inputs.path[[inputs.i]])
        inputs_list[[inputs_file]] <-scan(inputs.path[[inputs.i]],quiet = TRUE)
      }
    }
    final_table <- data.table(binaryfile=files.path,inputs=list(inputs_list),
                              logtable=list(logtable))
    
    return(final_table)
  }else {
    error_msg <- paste("Provided binary file doesn't exists for", files.path)
    return(message(error_msg))
  }
}  



