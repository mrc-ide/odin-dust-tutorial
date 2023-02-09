incidence <- read.csv("data/incidence.csv")
data <- mcstate::particle_filter_data(
  incidence, time = "day", rate = 4, initial_time = 0)

sir <- odin.dust::odin_dust("models/sir.R")

index <- function(info) {
  list(run = c(incidence = info$index$cases_inc),
       state = c(t = info$index$time,
                 I = info$index$I,
                 cases = info$index$cases_inc))
}

compare <- function(state, observed, pars = NULL) {
  modelled <- state["incidence", , drop = TRUE]
  lambda <- modelled + rexp(length(modelled), 1e6)
  dpois(observed$cases, lambda, log = TRUE)
}

filter <- mcstate::particle_filter$new(data, model = sir, n_particles = 100,
                                       compare = compare, index = index)

priors <- list(
  mcstate::pmcmc_parameter("beta", 0.2, min = 0),
  mcstate::pmcmc_parameter("gamma", 0.1, min = 0, prior = function(p)
    dgamma(p, shape = 1, scale = 0.2, log = TRUE)))

vcv <- matrix(c(0.00057, 0.00052, 0.00052, 0.00057), 2, 2)

transform <- function(theta) {
  as.list(theta)
}

mcmc_pars <- mcstate::pmcmc_parameters$new(priors, vcv, transform)

vcv <- matrix(c(0.00057, 0.00052, 0.00052, 0.00057), 2, 2)
mcmc_pars <- mcstate::pmcmc_parameters$new(priors, vcv, transform)
control <- mcstate::pmcmc_control(
    n_steps = 500,
    n_chains = 4,
    n_threads_total = 12,
    n_workers = 4,
    save_state = TRUE,
    save_trajectories = TRUE,
    progress = TRUE)
samples <- mcstate::pmcmc(mcmc_pars, filter, control = control)
