# Definition of the time-step and output as "time"
dt <- user()
initial(time) <- 0
update(time) <- (step + 1) * dt

# Equations for transitions between compartments by age group
update(S[, ]) <- new_S[i, j]
update(I[, , ]) <- new_I[i, j, k]
update(R[, ]) <- R[i, j] + n_I_progress[i, j, k_I]

# Individual probabilities of transition:
p_SI[, ] <- 1 - exp(-rel_susceptibility[i, j] * lambda[i] * dt) # S to I
p_I_progress <- 1 - exp(-gamma * dt) # I to R
p_vacc[, ] <- 1 - exp(-eta[i, j] * dt)

# Time-varying beta
beta_step[] <- user()
dim(beta_step) <- user()
beta <- if (as.integer(step) >= length(beta_step))
  beta_step[length(beta_step)] else beta_step[step + 1]

# Force of infection
m[, ] <- user() # age-structured contact matrix
s_ij[, ] <- m[i, j] * sum(I[j, , ])
lambda[] <- beta * sum(s_ij[i, ])

# Draws from binomial distributions for numbers changing between
# compartments:
n_SI[, ] <- rbinom(S[i, j], p_SI[i, j])
n_I_progress[, , ] <- rbinom(I[i, j, k], p_I_progress)

# Nested binomial draw for vaccination in S
# Assume you cannot get move vaccine class and get infected in same step
n_S_vacc[, ] <- rbinom(S[i, j] - n_SI[i, j], p_vacc[i, j])
new_S[, ] <- S[i, j] - n_SI[i, j] - n_S_vacc[i, j] +
  (if (j == 1) n_S_vacc[i, N_vacc_classes] else n_S_vacc[i, j - 1])

new_I[, , ] <- I[i, j, k] - n_I_progress[i, j, k] +
  (if (i == 1) n_SI[i, j] else n_I_progress[i, j, k - 1])

# Initial states:
initial(S[, ]) <- S_ini[i, j]
initial(I[, , ]) <- I_ini[i, j, k]
initial(R[, ]) <- 0

# User defined parameters - default in parentheses:
S_ini[, ] <- user()
I_ini[, , ] <- user()
gamma <- user(0.1)
eta[, ] <- user()
rel_susceptibility[, ] <- user()
k_I <- user(integer = TRUE)

# Dimensions of arrays
N_age <- user()
N_vacc_classes <- user()
dim(S_ini) <- c(N_age, N_vacc_classes)
dim(I_ini) <- c(N_age, N_vacc_classes, k_I)
dim(S) <- c(N_age, N_vacc_classes)
dim(I) <- c(N_age, N_vacc_classes, k_I)
dim(R) <- c(N_age, N_vacc_classes)
dim(n_SI) <- c(N_age, N_vacc_classes)
dim(n_I_progress) <- c(N_age, N_vacc_classes, k_I)
dim(p_SI) <- c(N_age, N_vacc_classes)
dim(m) <- c(N_age, N_age)
dim(s_ij) <- c(N_age, N_age)
dim(lambda) <- N_age
dim(eta) <- c(N_age, N_vacc_classes)
dim(rel_susceptibility) <- c(N_age, N_vacc_classes)
dim(p_vacc) <- c(N_age, N_vacc_classes)
dim(n_S_vacc) <- c(N_age, N_vacc_classes)
dim(new_S) <- c(N_age, N_vacc_classes)
dim(new_I) <- c(N_age, N_vacc_classes, k_I)
