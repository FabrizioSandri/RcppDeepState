##' @title TestHarness for the function
##' @param package_path to the test package
##' @param function_name from the test package
##' @param sep infun default
##' @description The function creates Testharness for the provided function name
##' @examples 
##' path <- system.file("testpkgs/testSAN", package = "RcppDeepState")
##' function_name <- "rcpp_read_out_of_bound"
##' function.harness <- deepstate_fun_create(path,function_name)
##' print(function.harness)
##' @return The TestHarness file that is generated
##' @export
deepstate_fun_create <- function(package_path, function_name, sep="infun"){
  
  packagename <- get_package_name(package_path)
  functions.list <- deepstate_get_function_body(package_path)
  functions.list$argument.type <- gsub("Rcpp::","",functions.list$argument.type)
  prototypes_calls <- deepstate_get_prototype_calls(package_path)
  fun_path <- file.path(package_path, "inst", "testfiles", function_name)

  if(sep == "generation" || sep == "checks"){ 
    if(is.null(functions.list) || length(functions.list) < 1){
      stop("No Rcpp Function to test in the package")
    }
  }
  
  # Each row of the "types_table" table corresponds to a supported datatype and
  # provides details for each datatype. The first column contains an alternative 
  # datatype to be used when running `qs::c_qsave`, whereas the second column 
  # correspond to the associated generation function with a range. When a 
  # datatype contains a value of NA in both columns, it is supported, utilizes 
  # itself when executing `qs::c_qsave` and lacks a range function. 
  datatype <- function(ctype, rtype, args) data.table(ctype, rtype, args)
  types_table <- rbind(
    datatype("int", "IntegerVector", "(low,high)"),
    datatype("double", "NumericVector", "(low,high)"),
    datatype("string", "CharacterVector", NA),
    datatype("NumericVector", NA, "(size,low,high)"),
    datatype("IntegerVector", NA, "(size,low,high)"),
    datatype("NumericMatrix", NA, "(row,column,low,high)"),
    datatype("IntegerMatrix", NA, "(row,column,low,high)"),
    datatype("CharacterVector", NA, NA),
    datatype("mat", NA, NA),
    datatype("char", "CharacterVector", NA),
    datatype("float", "NumericVector", "(low,high)"))
  setkey(types_table, "ctype")

  headers <- paste("#include <fstream>", "#include <RInside.h>", 
                   "#include <iostream>", "#include <RcppDeepState.h>", 
                   "#include <qs.h>", "#include <DeepState.hpp>\n\n", sep="\n")
  functions.rows  <- functions.list[functions.list$funName == function_name,]
  params <- gsub(" ", "", functions.rows$argument.type)
  params <- gsub("const", "", params)
  params <- gsub("Rcpp::", "", params)
  params <- gsub("arma::", "", params)
  params <- gsub("std::", "", params)

  filename <- if(sep == "generation" || sep == "checks"){
    paste0(function_name, "_DeepState_TestHarness_", sep, ".cpp")
  }else{
    paste0(function_name, "_DeepState_TestHarness.cpp")
  }

  # check if the parameters are allowed or not
  matched <- params %in% types_table$ctype
  unsupported_datatypes <- params[!matched]
  if(file.exists(file.path(fun_path, filename))){
    deepstate_create_makefile(package_path,function_name)
    warn_msg <- paste0("Test harness already exists for the function - ",
                       function_name, " - using the existing one\n")
    message(warn_msg)
    return(filename)
  }else if(length(unsupported_datatypes) > 0){
    unsupported_datatypes <- paste(unsupported_datatypes, collapse=",")
    error_msg <- paste0("We can't test the function - ", function_name,
                        " - due to the following datatypes falling out of the ",
                        "allowed ones: ", unsupported_datatypes, "\n")
    message(error_msg)
    return(NA_character_)
  }

  pt <- prototypes_calls[prototypes_calls$funName == function_name,]

  if(!dir.exists(fun_path)){
    dir.create(fun_path, showWarnings = FALSE, recursive = TRUE)
  }

  if(sep == "generation" || sep == "checks"){
    write_to_file <- paste0(headers)
    makesep.path <- file.path(fun_path, paste0(sep, ".Makefile"))
    file_path <- file.path(fun_path, filename)
    file.create(file_path, recursive=TRUE)
    if(file.exists(file.path(fun_path, "Makefile"))){
      file.copy(file.path(fun_path, "Makefile"), makesep.path)
    }else{
      deepstate_create_makefile(package_path, function_name)
    }

    default_harness <- paste0(function_name, "_DeepState_TestHarness")
    generation_harness <- paste0(function_name, "_DeepState_TestHarness_", sep)
    makefile_lines <- readLines(file.path(fun_path, "Makefile"), warn=FALSE)
    makefile_lines <- gsub(file.path(fun_path, default_harness), 
                           file.path(fun_path, generation_harness), 
                           makefile_lines, fixed=TRUE)

    file.create(makesep.path, recursive=TRUE)
    cat(makefile_lines, file=makesep.path, sep="\n")
    unlink(file.path(fun_path, "Makefile"))
    gen_output <- file.path(fun_path, paste0(function_name, "_output","_", sep))
    dir.create(gen_output, showWarnings=FALSE)
  }else{
    comment <- paste0("// AUTOMATICALLY GENERATED BY RCPPDEEPSTATE PLEASE DO",
                      "NOT EDIT BY HAND, INSTEAD EDIT\n// ", function_name, 
                      "_DeepState_TestHarness_generation.cpp and ", 
                      function_name, "_DeepState_TestHarness_checks.cpp\n\n")
    write_to_file <- paste0(comment, headers)
    file_path <- file.path(fun_path, filename)
    file.create(file_path, recursive=TRUE)
    deepstate_create_makefile(package_path, function_name)
  }

  # create a single RInside instance at the beginning
  write_to_file <- paste0(write_to_file, "RInside Rinstance;", "\n\n")  
  write_to_file <- paste0(write_to_file, pt[1,pt$prototype], "\n\n")
  
  unittest <- gsub(".", "", packagename, fixed=TRUE)
  generator_header <- paste0("\n\n", "TEST(", unittest, ", generator){", "\n")
  runner_header <- paste0("\n\n","TEST(",unittest,", runner){", "\n")

  # Test harness body
  generation_comment <- if(sep == "generation") "// RANGES CAN BE ADDED HERE\n" 
                        else ""
  indent <- "  "
  inputs <- "#define INPUTS \\\n"
  inputs_dump <- ""
  print_values <- paste0("\n\n#define PRINT_INPUTS \\\n", indent, 
                         "std::cout << \"input starts\" << std::endl;\\\n")

  proto_args <- ""
  for(argument.i in 1:nrow(functions.rows)){
    arg.type <- gsub(" ", "", functions.rows[argument.i,argument.type])
    arg.name <- gsub(" ", "", functions.rows[argument.i,argument.name])
    type.arg <- gsub("const", "", arg.type)
    type.arg <-gsub("Rcpp::", "", type.arg)
    type.arg <-gsub("arma::", "", type.arg)
    type.arg <-gsub("std::", "", type.arg)
    
    if(sep == "generation" && !is.na(types_table[type.arg]$args)){
      generation_comment <- paste0(generation_comment, "// RcppDeepState_", 
                                   type.arg, types_table[type.arg]$args, "\n")
    }
    
    # generate the inputs
    if (!is.na(types_table[type.arg]$rtype)){
      variable <- paste0(indent, types_table[type.arg]$rtype, " ", arg.name, 
                         "(1);", " \\\n", indent, arg.name, "[0]")
    }else{
      variable <- paste0(indent, arg.type, " ", arg.name)
    }
    variable <- paste0(variable, "= RcppDeepState_", type.arg, "();", " \\\n")
    variable <- gsub("const", "", variable)
    
    # save the inputs
    inputs_path <- file.path(fun_path, "inputs")
    if(!dir.exists(inputs_path)){
      dir.create(inputs_path)
    }
    if(type.arg == "mat"){
      input_vals <- file.path(inputs_path, arg.name)
      save_inputs <- paste0("std::ofstream ",  gsub(" ", "", arg.name), 
                            "_stream", ";\n", indent, arg.name, 
                            '_stream.open("', input_vals, '" );\n', indent, 
                            arg.name, '_stream << ', arg.name, ';\n', indent, 
                            arg.name, '_stream.close(); \n')
    }else{
      input_file <- paste0(arg.name, ".qs")
      input_vals <- file.path(inputs_path, input_file)
      save_inputs <- paste0('qs::c_qsave(', arg.name, ',"', input_vals, '",\n',
                            '\t\t"high", "zstd", 1, 15, true, 1);\n')
    }

    inputs <- paste0(inputs, variable)
    inputs_dump <- paste0(inputs_dump, indent, save_inputs)
    print_values <- paste0(print_values, indent, 'std::cout << "', arg.name,
                           ' values: " << ', arg.name, ' << std::endl; \\\n')    
    
    if (type.arg == "string"){
      proto_args <- paste0(proto_args, "Rcpp::as<std::string>(", arg.name, 
                           "[0]),")
    }else if(!is.na(types_table[type.arg]$rtype)){
      proto_args <- paste0(proto_args, arg.name, "[0],")
    }else{
      proto_args <- paste0(proto_args, arg.name, ",")  
    }

  }

  inputs <- gsub("\\\\\n$", "", inputs)
  print_values <- paste0(print_values, indent, 
                         'std::cout << "input ends" << std::endl;\n')

  generator_body <- paste0(indent, "INPUTS\n", indent, "PRINT_INPUTS\n")
  runner_body <- paste0(indent, "INPUTS\n", indent,"PRINT_INPUTS\n",inputs_dump)

  runner_body <- paste0(runner_body, indent, "try{\n", indent, indent, 
                        function_name, "(", gsub(",$", "", proto_args), ");\n")
  if(sep == "checks"){
    assert_comment <- "//ASSERT CONDITIONS CAN BE ADDED HERE\n"
    runner_body <- paste0(runner_body, indent, indent, assert_comment) 
  }
  runner_body <- paste0(runner_body, indent, "}catch(Rcpp::exception& e){\n",
                        indent, indent, 'std::cout<<"Exception Handled"', 
                        "<<std::endl;\n", indent, "}")
  
  write_to_file <- paste0(write_to_file, generation_comment, inputs, 
                          print_values, generator_header, generator_body, "}", 
                          runner_header, runner_body, "\n}")
                        
  write(write_to_file, file_path, append=TRUE)

  return(filename)
}
