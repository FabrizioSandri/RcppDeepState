library(RcppDeepState)

testSAN_path <- "testpkgs/testSAN"
workflow_file_name <- "RcppDeepState.yaml"

repository_path <- system.file("/", package="RcppDeepState")
workflow_path <- gsub("[/]+","/",file.path(repository_path,".github/workflows"))
workflow_file <- file.path(workflow_path, workflow_file_name)

test_that("ci_setup test on different location", {
    
  ci_setup(repository=repository_path, location=testSAN_path, comment=TRUE, 
           workflow_file_name=workflow_file_name)
  
  # check if the final workflows directory and the workflow exists
  expect_true(dir.exists(workflow_path))
  expect_true(file.exists(workflow_file))

  workflow_code <- readLines(workflow_file)

  # check if the workflow file contains some code
  expect_false(length(workflow_code)==0)

  event_pull_request <- grepl("pull_request", workflow_code, fixed=TRUE)

  # check if the pull request event has been added
  expect_true(length(event_pull_request)>0)

})

test_that("ci_setup with a non supported value", {
    
  expect_message(ci_setup(repository=repository_path, location=testSAN_path, 
          comment=TRUE, workflow_file_name=workflow_file_name, event="delete"),
          "The specified event falls out of the supported ones.")

})