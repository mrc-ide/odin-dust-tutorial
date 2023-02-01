update(S) <- S - n_SI
update(I) <- I + n_SI - n_IR
update(R) <- R + n_IR

n_SI <- rbinom(S, 1 - exp(-beta * I / N))
n_IR <- rbinom(I, 1 - exp(-sigma))

initial(S) <- N - I0
initial(I) <- I0
initial(R) <- 0

N <- user(1e6)
I0 <- user(1)
beta <- user(4)
sigma <- user(2)
