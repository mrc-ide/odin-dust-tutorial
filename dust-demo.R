gen <- odin.dust::odin_dust("models/sir_stochastic.R")

mod <- gen$new(list(), time = 0, n_particles = 1)
mod$run(10)
