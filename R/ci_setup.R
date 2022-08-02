##' @title  RcppDeepState-action GitHub workflow setup
##' @param repository path to the repository root folder
##' @param event the event that triggers the workflow to run, accepted values 
##' are pull_request and push
##' @param fail_ci_if_error specify if CI pipeline should fail when 
##' RcppDeepState finds errors
##' @param location location of the package if not in the root of the repository
##' @param seed seed used for deterministic fuzz testing and reproduce the 
##' analysis results
##' @param time_limit fuzzing phase's duration in seconds
##' @param max_inputs number of inputs generated in the fuzzing phase to analyze
##' @param comment print the analysis results as a comment in pull request
##' @export
ci_setup <- function(repository="./", event="pull_request", 
                     fail_ci_if_error=FALSE, location="/", seed="-1", 
                     time_limit="2", max_inputs="3", comment=FALSE){
                    
  workflow_path <- gsub("[/]+", "/", file.path(repository, ".github/workflows"))
  workflow_file <- file.path(workflow_path, "RcppDeepState.yaml")
  
  # repository containing the RcppDeepState-action
  action_repo <- "FabrizioSandri/RcppDeepState-action@main"

  if(!dir.exists(workflow_path)){
    dir.create(workflow_path, showWarnings = FALSE, recursive=TRUE)
  }
  
  # workflow events
  available_events <- c("push", "pull_request")
  if (! event %in% available_events){
    events <- paste0("on:\n", indent(), "# Add your events here", "\n")

    event_warn <- paste("The specified event falls out of the supported ones.",
                "Please manually edit file: ", workflow_file)
    message(event_warn)
  }else{
    events <- paste0("on:\n", indent(), event, ":\n", indent(2), "branches:\n", 
                   indent(3), "- '*'", "\n")
  }

  name <- "name: 'RcppDeepState analysis'"

  # checkout step
  checkout_step <- paste0(indent(3), "- uses: ", "actions/checkout@v2", "\n\n")
    
  # RcppDeepState step
  fail_ci_param <- get_param_yaml("fail_ci_if_error", tolower(fail_ci_if_error))
  location_param <- get_param_yaml("location", location)
  seed_param <- get_param_yaml("seed", seed)
  time_limit_param <- get_param_yaml("time_limit", time_limit)
  max_inputs_param <- get_param_yaml("max_inputs", max_inputs)
  comment_param <- get_param_yaml("comment", tolower(comment))

  params <- paste(fail_ci_param, location_param, seed_param, time_limit_param,
                  max_inputs_param, comment_param, sep="\n")
  rcppdeepstate_step <- paste0(indent(3), "- uses: ", action_repo, "\n",
                               indent(4), "with:\n", params)

  # jobs definition
  steps <- paste0(indent(2), "steps: ", "\n", checkout_step, rcppdeepstate_step)

  env <- paste0(indent(2), "env:", "\n", indent(3), 
                "GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}", "\n")

  jobs <- paste0("jobs:", "\n", indent(), "RcppDeepState:", "\n", indent(2),
                 "runs-on: ubuntu-latest", "\n\n", env, "\n", steps)


  # final workflow code
  workflow_code <- paste(events, name, jobs, sep="\n")
  
  write(workflow_code, workflow_file, append=FALSE)
}


# Helper function that returns 'times' indentation symbols
indent <- function(times=1){
  indent_symbol <- "  "
  strrep(indent_symbol, times)
}

# Helper function that generates a string representing a yaml formatted code of
# a given parameter
get_param_yaml <- function(param_name, param){
  paste0(indent(5), param_name, ": '", param, "'")
}