##' @title Package Details
##' @return A list with all the relevant data in the RcppExrpots
##' @param path to the package with RcppExports file
##' @description Ths function takes the path to the test package and captures the argument specific data.
##' @import nc
##' @import data.table
##' @export
deepstate_get_package_details <- function(path){
  funs <- ""
  package_path <- file.path(
    path,"src", "RcppExports.cpp")
  if(!file.exists(package_path)){
  stop("pkgdir must refer to the directory containing an R package")
  }else{
    funs<- nc::capture_all_str(
      package_path,
      "\n\\s*// ",
      commentName=".*",
      "\n",
      prototype=list(
        returnType=".*",
        " ",
        funName=".*?",
        "\\(",
        arguments=".*",
        "\\);"),"\n",
      SEXP=".*\n","\\s*BEGIN_RCPP\\s*\n",
      code="(?:.*\n)*?",
      "\\s*END_RCPP")
  }
}

##' @title Function Details
##' @return A list with function names and arguments
##' @param package_path path to the test package
##' @examples
##' deepstate_get_function_body(system.file("testpkgs/testSAN", package = "RcppDeepState")) 
##' @export
deepstate_get_function_body<-function(package_path){
  funs <-  RcppDeepState::deepstate_get_package_details(package_path) 
  function.list <-""
  if(nrow(funs) > 0){
    function.list <- funs[,{
      dt <- nc::capture_all_str(
        code,
        "input_parameter< ",
        argument.type=".*?",
        ">::type",
        argument.name="[^(]+")
    }, by=funName]
  }
  return(function.list)
}

##' @title Prototypes
##' @return prototypes list with function prototypes
##' @param package_path to the RcppExports file
##' @export
deepstate_get_prototype_calls <-function(package_path){
  funs <-  RcppDeepState::deepstate_get_package_details(package_path) 
  codes <- funs[,{nc::capture_all_str(code,"::wrap",calls ="(?:.*)")},by=funName]
  prototypes <-funs[,.(funName,prototype,calls=codes$calls)]
  return(prototypes)
}


##' @title get_package_name
##' @description gets the name of a package from its DESCRIPTION file
##' @param package_path location of the package in the filesystem
##' @export
get_package_name <- function(package_path){
  description_file <- file.path(package_path, "DESCRIPTION")
  if (!file.exists(description_file)) {
    message(paste0("ERROR: ", package_path, " doesn't contain a valid package ",
                    "with a DESCRIPTION file"))
    return(NA_character_)
  }

  # parse the DESCRIPTION file in order to get the package name
  description_lines <- readLines(description_file)
  package_name_line <- description_lines[grepl("^Package:", description_lines)]
  package_name <- gsub("Package: ", "", package_name_line[1])
  
}



globalVariables(c("argument.name","funName","argument.type","calls"
                  ,"code","funName",".","error.i","src.file.lines",
                  "heapsum","file.line","arg.name","value",":=",".N","f","fun_name"
                  ,"read.table","new.i.vec","download.file","result","inputs",
                  "rest","status","fun","max_inputs","package_name","pkg.list","testfiles.res"))

globalVariables(c("error.i","error.type","sanitizer","function.i",
                  "src.file.lines","heapsum","file.line","arg.name",
                  "value",".N",":=","prototype","data.table"))

