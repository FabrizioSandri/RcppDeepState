#include <Rcpp.h>
using namespace std;

// [[Rcpp::export]]
int unsupported_datatype(Rcpp::LogicalVector param){
  
  return param.size();
  
} 

