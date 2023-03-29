# RcppDeepState <a href="https://akhikolla.github.io./"><img src="https://github.com/akhikolla/RcppDeepState/blob/master/inst/graphics/logo.jpg" align="right" height="140" /></a>

RcppDeepState, a simple way to fuzz test compiled code in Rcpp packages. This package extends the DeepState framework to fully support Rcpp based packages.

**Note:** RcppDeepState is currently supported on Linux and macOS, with windows support in progress.

## See Also
To learn more about how RcppDeepState works see: 
* @akhikolla's [RcppDeepState blog](https://akhikolla.github.io./) 
* @FabrizioSandri's [GSOC 2022 blog](https://fabriziosandri.github.io/gsoc-2022-blog/) 
* [Wiki](https://github.com/FabrizioSandri/RcppDeepState/wiki) page

## Dependencies

First, make sure to install the following dependencies on your local machine.

* CMake
* GCC and G++ with multilib support
* Python 3.6 (or newer)
* Setuptools

Use this command line to install the dependencies.

```shell
sudo apt-get install build-essential gcc-multilib g++-multilib cmake python3-setuptools libffi-dev z3
```

## Installation

The RcppDeepState package can be installed from GitHub as follows:

```R
install.packages("devtools")
devtools::install_github("FabrizioSandri/RcppDeepState")
```

## Functionalities
The main purpose of RcppDeepState is to analyze a package and find sublter bugs such memory issues.

### Automatic package analysis
To test your package using RcppDeepState follow the steps below:

(a) **deepstate_harness_compile_run**: This function creates the TestHarnesses for all the functions in the test package with the corresponding makefiles. This function compiles and executes all of the above-mentioned TestHarnesses, as well as creates random inputs for your code. This function gives a list of functions that have been successfully compiled in the package; otherwise, a warning message will be displayed if a test harness cannot be generated automatically. 


```R
> RcppDeepState::deepstate_harness_compile_run("~/testSAN")
We can't test the function - unsupported_datatype - due to the following datatypes falling out of the allowed ones: LogicalVector

Failed to create testharness for 1 functions in the package - unsupported_datatype
Testharness created for 6 functions in the package

[1] "rcpp_read_out_of_bound"      "rcpp_use_after_deallocate"  
[3] "rcpp_use_after_free"         "rcpp_use_uninitialized"     
[5] "rcpp_write_index_outofbound" "rcpp_zero_sized_array"   
```

(b) **deepstate_harness_analyze_pkg**: This method examines each test file created in the previous step and produces a table with information on the error messages and inputs supplied to each tested function. The test run log files are saved in the same location as the inputs, i.e.  `/inst/function/log_*/valgrind_log`

```R
result <- RcppDeepState::deepstate_harness_analyze_pkg("~/testSAN")
```

The result contains a data table with three columns: binary.file, inputs, logtable. Each row of this table correspond to a single test.

```R
> head(result,2)
                                          binaryfile
1: ~/testSAN/inst/testfiles/rcpp_read_out_of_bound/rcpp_read_out_of_bound_output/00004669c554b565471956e17bf36a67a67ecd78.pass
2: ~/testSAN/inst/testfiles/rcpp_read_out_of_bound/rcpp_read_out_of_bound_output/0001a4df441415b38d97b918f6b1e26e26fdadce.pass
      inputs          logtable
1: <list[1]> <data.table[1x5]>
2: <list[1]> <data.table[1x5]>
```

The inputs column contains all the inputs that are passed: 

```R
> result$inputs[[1]]
$rbound
[1] -53789918
```
The logtable is a table containing all of the errors identified by RcppDeepState for a single test. 

```R
> result$logtable[[1]]
      err.kind                message                 file.line
1: InvalidRead Invalid read of size 4 read_out_of_bound.cpp : 7
                                                                address.msg
1: Address 0xfffffffffe099498 is not stack'd, malloc'd or (recently) free'd
            address.trace
1: No Address Trace found
```

### Manual package analysis
Remember from the previous paragraph that RcppDeepState automatically produces a test harness for you; however, it is possible that RcppDeepState cannot generate the test harness for you, as in the case of the aforementioned `unsupported_datatype` function, and will display the following error message: 
```
We can't test the function - unsupported_datatype - due to the following datatypes falling out of the allowed ones: LogicalVector

Failed to create testharness for 1 functions in the package - unsupported_datatype
```
In this case there are two possible solutions:
* provide a manually built test harness for these functions; more details can be found in the relative guide [Provide a custom test harness to RcppDeepState GitHub Action](https://fabriziosandri.github.io/gsoc-2022-blog/rcppdeepstate/github%20action/2022/08/11/action-custom-harness.html).
* add support for this datatype to RcppDeepState, following this guide [Add a new datatype to RcppDeepState](https://github.com/FabrizioSandri/RcppDeepState/wiki/Add-a-new-datatype-to-RcppDeepState)


### Use RcppDeepState inside a GitHub repository
Now RcppDeepState makes it easy to use RcppDeepState with GitHub Actions. 

**ci_setup**: this function can be used to automatically initialize a GitHub 
workflow file inside your repository for the RcppDeepState analysis. This 
workflow uses [RcppDeepState-action](https://github.com/marketplace/actions/rcppdeepstate).

```R
> RcppDeepState::ci_setup(pathtotestpackage)
```

