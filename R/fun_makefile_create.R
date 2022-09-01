##' @title Harness Makefile Generation
##' @param package path to the test package
##' @param fun_name name of the function
##' @description This function generates makefile for the provided function specific TestHarness
##' @export
deepstate_create_makefile <-function(package,fun_name){
  
  inst_path <- file.path(package, "inst")
  test_path <- file.path(inst_path,"testfiles")
  fun_path <- file.path(test_path,fun_name)
  log_file_path <- file.path(fun_path,paste0(fun_name,"_log"))

  test_harness <- paste0(fun_name,"_DeepState_TestHarness")
  makefile_path <- file.path(fun_path, "Makefile")
  test_harness.o <- paste0(test_harness,".o")
  test_harness.cpp <- paste0(test_harness,".cpp")
  test_harness.o_path <- file.path(fun_path,test_harness.o)
  test_harness.cpp_path <- file.path(fun_path,test_harness.cpp)
  test_harness_path <- file.path(fun_path,test_harness)

  # R home, include and lib directories
  path_home <-paste0("R_HOME=",R.home())
  path_include <-paste0("R_INCLUDE=",R.home("include"))
  path_lib <-paste0("R_LIB=",R.home("lib"))
  
  # include and lib path locations
  rcpp_include <- system.file("include", package="RcppDeepState")
  rcppdeepstate_include <- system.file("include", package="Rcpp")
  rcpparmadillo_include <- system.file("include", package="RcppArmadillo")
  rinside_include <- system.file("include", package="RInside")
  deepstate_path <- file.path("${HOME}", ".RcppDeepState", "deepstate-master")
  deepstate_build <- file.path(deepstate_path, "build")
  deepstate_include <- file.path(deepstate_path, "src", "include")
  qs_include <- system.file("include", package="qs")
  rinside_lib <- system.file("lib", package="RInside")

  # CPPFLAGS : headers inclusion
  cppflags <- c(rcpp_include, rcppdeepstate_include, rcpparmadillo_include,
                rinside_include, deepstate_build, deepstate_include, qs_include,
                "${R_INCLUDE}")

  compiler_cppflags <- paste(cppflags, collapse=" -I ")
  cppflags_write <- paste0("CPPFLAGS=-I",compiler_cppflags)

  # LDFLAGS : libs inclusion
  ldflag <- function(path) paste0("-L", path, " -Wl,-rpath=", path) 
  ldflags <- c(ldflag(rinside_lib), ldflag("${R_LIB}"), ldflag(deepstate_build))

  compiler_ldflags <- paste(ldflags, collapse=" ")
  ldflags_write <- paste0("LDFLAGS=", compiler_ldflags)

  # LDLIBS : library flags for the linker
  ldlibs <- c("-lR", "-lRInside", "-ldeepstate")
  compiler_ldlibs <- paste(ldlibs, collapse=" ")

  ldlibs_write <- paste0("LDLIBS=", compiler_ldlibs)

  # generate the shared object file for the library
  shared_objects <- file.path(package, "src/*.so")  
  if (length(Sys.glob(shared_objects)) <= 0) {
    # ensure that the debugging symbols are embedded in the shared object
    makevars_file <- file.path(package, "src", "Makevars")
    if (dir.exists(file.path(package, "src"))) {
      makevars_content <- "PKG_CXXFLAGS += -g \n"
      write(makevars_content, makevars_file, append=TRUE)
    }

    utils::install.packages(package, repo=NULL)

    if (length(Sys.glob(shared_objects)) <= 0) {
      stop("The shared object for your package cannot be generated. This is ",
           "probably caused by a missing dependency. Please install all the ",
           "dependencies for your package.")
    }
  }
 
  # Makefile rules : compile lines
  gen_rule <- function(targets, prerequisites, recipe) paste0(targets, " : ", 
                        prerequisites, "\n\t", recipe, "\n")
  obj <- paste0("clang++ -g -gdwarf-4 -c ", " ${CPPFLAGS} ", 
                test_harness.cpp_path, " -o ", test_harness.o_path)
  obj_rule <- gen_rule(test_harness.o_path, test_harness.cpp_path, obj)

  exe <- paste0("clang++ -g -gdwarf-4 ", test_harness.o_path, " ${CPPFLAGS} ", 
                " ${LDFLAGS} ", " ${LDLIBS} ", shared_objects, " -o ", 
                test_harness_path) 
  exe_rule <- gen_rule(test_harness_path, test_harness.o_path, exe)
  
  # create the inputs, outputs folder and save the makefile
  dir.create(file.path(fun_path, paste0(fun_name,"_output")), 
             showWarnings=FALSE, recursive=TRUE)
  
  inputs_path <- file.path(fun_path, "inputs")
  if(!dir.exists(inputs_path)){
    dir.create(inputs_path)
  }

  write_to_file <- paste(path_home, path_include, path_lib, "\n", 
                         cppflags_write, ldflags_write, ldlibs_write, "\n", 
                         exe_rule, obj_rule, sep="\n")

  file.create(makefile_path, recursive=TRUE)
  write(write_to_file, makefile_path, append=FALSE)
  
}
