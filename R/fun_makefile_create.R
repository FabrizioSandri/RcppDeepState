##' @title Harness Makefile Generation
##' @param package path to the test package
##' @param fun_name name of the function
##' @description This function generates makefile for the provided function specific TestHarness
##' @import utils
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
  write_to_file <- paste0(path_home,"\n",path_include,"\n",path_lib,"\n\n")
  
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
  compiler_cppflags <- paste0("-I", rcpp_include) 
  compiler_cppflags <- paste(compiler_cppflags, paste0("-I", rcppdeepstate_include)) 
  compiler_cppflags <- paste(compiler_cppflags, paste0("-I", rcpparmadillo_include)) 
  compiler_cppflags <- paste(compiler_cppflags, paste0("-I", rinside_include)) 
  compiler_cppflags <- paste(compiler_cppflags, paste0("-I", deepstate_build))
  compiler_cppflags <- paste(compiler_cppflags, paste0("-I", deepstate_include)) 
  compiler_cppflags <- paste(compiler_cppflags, paste0("-I", qs_include)) 
  compiler_cppflags <- paste(compiler_cppflags, paste0("-I", "${R_INCLUDE}"))
  write_to_file <- paste0(write_to_file, "CPPFLAGS=",compiler_cppflags, "\n")

  # LDFLAGS : libs inclusion
  compiler_ldflags <- paste0("-L", rinside_lib, " -Wl,-rpath=", rinside_lib) 
  compiler_ldflags <- paste(compiler_ldflags, "-L${R_LIB} -Wl,-rpath=${R_LIB}")
  compiler_ldflags <- paste(compiler_ldflags, paste0("-L", deepstate_build, " -Wl,-rpath=", deepstate_build))
  write_to_file <- paste0(write_to_file, "LDFLAGS=", compiler_ldflags, "\n")

  # LDLIBS : library flags for the linker
  compiler_ldlibs <- paste("-lR", "-lRInside", "-ldeepstate")
  write_to_file <- paste0(write_to_file, "LDLIBS=",compiler_ldlibs, "\n\n")

  dir.create(file.path(fun_path, paste0(fun_name,"_output")), showWarnings=FALSE, recursive=TRUE)
  file.create(makefile_path, recursive=TRUE)

  shared_objects <- file.path(package, "src/*.so")  
  if (length(Sys.glob(shared_objects)) <= 0) {
    # ensure that the debugging symbols are embedded in the shared object
    makevars_file <- file.path(package, "src", "Makevars")
    if (dir.exists(file.path(package, "src"))) {
        makevars_content <- "PKG_CXXFLAGS += -g \n"
        write(makevars_content, makevars_file, append=TRUE)
    }

    install.packages(package, repo=NULL)

    if (length(Sys.glob(shared_objects)) <= 0) {
      error_msg <- paste("ERROR: the shared object for your package cannot be",
                         "generated. This is probably caused by a missing",
                         "dependency. Please install all the dependencies for",
                         "your package.")
      stop(error_msg)
    }
  }
 
  # Makefile rules : compile lines
  write_to_file<-paste0(write_to_file, "\n\n", test_harness_path, " : ", test_harness.o_path)
  write_to_file<-paste0(write_to_file, "\n\t", "clang++ -g -gdwarf-4 ", test_harness.o_path, " ${CPPFLAGS} ", " ${LDFLAGS} ", " ${LDLIBS} ", shared_objects, " -o ", test_harness_path) 
  write_to_file<-paste0(write_to_file, "\n\n", test_harness.o_path, " : ", test_harness.cpp_path)
  write_to_file<-paste0(write_to_file, "\n\t", "clang++ -g -gdwarf-4 -c ", " ${CPPFLAGS} ", test_harness.cpp_path, " -o ", test_harness.o_path)
  
  write(write_to_file, makefile_path, append=TRUE)

  # create the inputs folder
  inputs_path <- file.path(fun_path, "inputs")
  if(!dir.exists(inputs_path)){
    dir.create(inputs_path)
  }
  
}
