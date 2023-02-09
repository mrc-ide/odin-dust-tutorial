compare <- function(state, observed, pars = NULL) {
  modelled <- state["incidence", , drop = TRUE]
  lambda <- modelled + rexp(length(modelled), 1e6)
  dpois(observed$cases, lambda, log = TRUE)
}
