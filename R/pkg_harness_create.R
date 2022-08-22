##' @title TestHarness for the package
##' @param package_path path to the test package
##' @param verbose used to deliver more in depth information
##' @description Creates Testharness for all the functions in the package that
##' you want to test
##' using RcppDeepState.
##' @examples
##' path <- system.file("testpkgs/testSAN", package = "RcppDeepState")
##' harness.list <- deepstate_pkg_create(path)
##' print(harness.list)
##' @import RcppArmadillo
##' @return A character vector of TestHarness files that are generated
##' @export
deepstate_pkg_create <- function(package_path, verbose=getOption("verbose")) {
  package_path <- normalizePath(package_path, mustWork=TRUE)
  package_path <- sub("/$", "", package_path)
  test_path <- file.path(package_path, "inst", "testfiles")

  # Test directory structure initialization
  if (!dir.exists(test_path)) {
    dir.create(test_path, showWarnings=FALSE, recursive=TRUE)
  }else {
    # delete all the existing files except for the harness
    for (function_name in list.files(test_path)) {
      fun_path <- file.path(test_path, function_name)
      filename <- paste0(function_name, "_DeepState_TestHarness", ".cpp")
      harness_path <- file.path(fun_path, filename)

      # delete all the files and directories except the harness file
      if (file.exists(harness_path)) {
        delete_content <- setdiff(list.files(fun_path), filename)
        unlink(file.path(fun_path, delete_content), recursive=TRUE)
      }
    }
  }

  if (!file.exists(file.path(package_path, "src/*.so"))) {
    # ensure that the debugging symbols are embedded in the shared object
    makevars_file <- file.path(package_path, "src", "Makevars")
    if (dir.exists(file.path(package_path, "src"))) {
        makevars_content <- "PKG_CXXFLAGS += -g "
        write(makevars_content, makevars_file, append=TRUE)
    }

    system(paste0("R CMD INSTALL ", package_path), intern=FALSE,
           ignore.stdout=!verbose, ignore.stderr=!verbose)
    unlink(makevars_file, recursive = FALSE)
  }

  # download and build deepstate
  libdeepstate32 <- "~/.RcppDeepState/deepstate-master/build/libdeepstate32.a"
  libdeepstate <- "~/.RcppDeepState/deepstate-master/build/libdeepstate.a"
  if (!(file.exists(libdeepstate32) && file.exists(libdeepstate))) {
    deepstate_make_run(verbose)
  }

  Rcpp::compileAttributes(package_path)
  harness <- list()
  failed.harness <- list()

  functions.list <-  deepstate_get_function_body(package_path)
  if (!is.null(functions.list) && length(functions.list) > 1) {
    functions.list$argument.type <- gsub("Rcpp::", "",
                                         functions.list$argument.type)
    match_count <- 0
    mismatch_count <- 0
    
    fun_names <- unique(functions.list$funName)
    for (function_name in fun_names) {
      fun_path <- file.path(test_path, function_name)
      filename <- paste0(function_name, "_DeepState_TestHarness", ".cpp")
      harness_path <- file.path(fun_path, filename)

      functions.rows <- functions.list[functions.list$funName == function_name,]
      params <- c(functions.rows$argument.type)
      filepath <- deepstate_fun_create(package_path, function_name)
      
      if (!is.na(filepath) && basename(filepath) == filename) {
        match_count <- match_count + 1
        harness <- c(harness, filename)
      }else {
        mismatch_count <- mismatch_count + 1
        failed.harness <- c(failed.harness, function_name)
      }
      
    }
    

    # harness generated for all of the functions
    if (match_count > 0 && match_count == length(fun_names)) {
      message(paste0("Testharness created for ", match_count, 
                     " functions in the package\n"))
      return(as.character(harness))
    }

    # harness generated for some function
    if (mismatch_count < length(fun_names) && length(failed.harness) > 0
        && match_count != 0) {
      failed_str <- paste(failed.harness, collapse=", ")
      message(paste0("Failed to create testharness for ", mismatch_count,
                     " functions in the package - ", failed_str))

      message(paste0("Testharness created for ", match_count,
                     " functions in the package\n"))
      return(as.character(harness))
    }

    # harness not generated for any function
    if (mismatch_count == length(fun_names)) {
      stop("Testharnesses cannot be created for the package")
      return(as.character(failed.harness))
    }

  }else {
    stop("No Rcpp function to test in the package")
  }
}
