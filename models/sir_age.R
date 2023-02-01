# Definition of the time-step and output as "time"
dt <- user()
initial(time) <- 0
update(time) <- (step + 1) * dt

# Equations for transitions between compartments by age group
update(S[]) <- S[i] - n_SI[i]
update(I[]) <- I[i] + n_SI[i] - n_IR[i]
update(R[]) <- R[i] + n_IR[i]

# Individual probabilities of transition:
p_SI[] <- 1 - exp(-lambda[i] * dt) # S to I
p_IR <- 1 - exp(-gamma * dt) # I to R

# Force of infection
m[, ] <- user() # age-structured contact matrix
s_ij[, ] <- m[i, j] * I[j]
lambda[] <- beta * sum(s_ij[i, ])

# Draws from binomial distributions for numbers changing between
# compartments:
n_SI[] <- rbinom(S[i], p_SI[i])
n_IR[] <- rbinom(I[i], p_IR)

initial(S[]) <- S_ini[i]
initial(I[]) <- I_ini[i]
initial(R[]) <- 0

# User defined parameters - default in parentheses:
S_ini[] <- user()
I_ini[] <- user()
beta <- user(0.0165)
gamma <- user(0.1)

# Dimensions of arrays
N_age <- user()
dim(S_ini) <- N_age
dim(I_ini) <- N_age
dim(S) <- N_age
dim(I) <- N_age
dim(R) <- N_age
dim(n_SI) <- N_age
dim(n_IR) <- N_age
dim(p_SI) <- N_age
dim(m) <- c(N_age, N_age)
dim(s_ij) <- c(N_age, N_age)
dim(lambda) <- N_age
