##' @title  travis setup
##' @param repository path to the repository root folder
##' @export
ci_setup<-function(repository="./", event="pull_request"){
  workflows_path <- file.path(repository, ".github", "workflows")
  workflow_file <- file.path(repository, workflows_path)

  # workflow events
  events <- paste0("on:\n", indent(), event, ":\n", indent(2), "branches:\n", 
                   indent(3), "- '*'" )
  name <- "name: 'RcppDeepState analysis'"

  # jobs definition
  checkout_step <- paste0(indent(3), "- uses: ", "actions/checkout@v2", "\n")

  rcppdeepstate_step <- paste0(indent(3), "- uses: ", 
                               "FabrizioSandri/RcppDeepState-action", "\n",
                               indent(4), "with:\n")

  steps <- paste0(indent(2), "steps: ", "\n", checkout_step, rcppdeepstate_step)

  env <- paste0(indent(2), "env:", "\n", indent(3), 
                "GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}")

}


indent <- function(times=1){
  indent_symbol <- "  "
  strrep(indent_symbol, times)
}