# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

rcpp_read_out_of_bound <- function(rbound) {
    .Call('_testSAN_rcpp_read_out_of_bound', PACKAGE = 'testSAN', rbound)
}

unsupported_datatype <- function(param) {
    .Call('_testSAN_unsupported_datatype', PACKAGE = 'testSAN', param)
}

rcpp_use_after_deallocate <- function(array_size) {
    .Call('_testSAN_rcpp_use_after_deallocate', PACKAGE = 'testSAN', array_size)
}

rcpp_use_after_free <- function(alloc_size) {
    .Call('_testSAN_rcpp_use_after_free', PACKAGE = 'testSAN', alloc_size)
}

rcpp_use_uninitialized <- function(u_value) {
    .Call('_testSAN_rcpp_use_uninitialized', PACKAGE = 'testSAN', u_value)
}

rcpp_write_index_outofbound <- function(wbound) {
    .Call('_testSAN_rcpp_write_index_outofbound', PACKAGE = 'testSAN', wbound)
}

rcpp_zero_sized_array <- function(value) {
    .Call('_testSAN_rcpp_zero_sized_array', PACKAGE = 'testSAN', value)
}

