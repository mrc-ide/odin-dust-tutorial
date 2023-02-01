deriv(S) <- -beta * S * I / N
deriv(I) <- beta * S * I / N - sigma * I
deriv(R) <- sigma * I

initial(S) <- N - I0
initial(I) <- I0
initial(R) <- 0

N <- user(1e6)
I0 <- user(1)
beta <- user(4)
sigma <- user(2)
