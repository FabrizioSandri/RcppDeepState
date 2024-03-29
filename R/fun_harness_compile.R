##' @title Harness compilation for the function
##' @param fun_path path of the function to compile
##' @param sep default to infun
##' @param verbose used to deliver more in depth information
##' @description Compiles the function-specific testharness in the package.
##' @examples
##' pkg_path <- system.file("testpkgs/testSAN", package = "RcppDeepState")
##' deepstate_pkg_create(pkg_path)
##' fun_path <- file.path(pkg_path, "inst", "testfiles", "rcpp_read_out_of_bound")
##' compiled.harness <- deepstate_compile_fun(fun_path)
##' print(compiled.harness)
##' @export
deepstate_compile_fun <- function(fun_path, sep="infun",
                                  verbose=getOption("verbose")){

  silent <- if (!verbose) "-s" else ""

  if(sep == "infun"){
    harness.file <- file.path(fun_path,paste0(basename(fun_path),
                              "_DeepState_TestHarness.cpp"))
    make.file <- file.path(fun_path,"Makefile")
    compile_line <-paste0("cd ",fun_path," && rm -f *.o && make ", silent, "\n")
  }else if(sep == "generation"){
    harness.file <- file.path(fun_path,paste0(basename(fun_path),
                              "_DeepState_TestHarness_generation.cpp"))
    make.file <- file.path(fun_path,"generation.Makefile")
    compile_line <-paste0("cd ",fun_path," && rm -f *.o && make ", silent,
                          " -f generation.Makefile\n")
  }else if(sep == "checks"){
    harness.file <- file.path(fun_path,paste0(basename(fun_path),
                              "_DeepState_TestHarness_checks.cpp"))
    make.file <- file.path(fun_path,"checks.Makefile")
    compile_line <-paste0("cd ",fun_path," && rm -f *.o && make ", silent, 
                          " -f checks.Makefile\n")
  }

  if(file.exists(harness.file) && file.exists(make.file)){
    if (verbose){
        message(sprintf("compiling .. \n%s\n", compile_line))
    }

    system(compile_line, ignore.stdout=!verbose)

  }else{
    error_msg <- paste("TestHarness and makefile doesn't exists. Please use",
                       "deepstate_pkg_create() to create them")
    stop(error_msg)
  }
  
}


