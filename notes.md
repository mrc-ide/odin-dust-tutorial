# What is odin?

Odin is a DSL - a domain specific language. It exists to describe a specific problem efficiently. We developed it to describe ordinary differential equations which evolve a system in continuous time. This is a great target for DSL because it's just a collection of mathematical truths - rates exist independent of any idea of order of operation.

Give an example here of an ODE system and corresponding odin code, for a simple SIR model?

Need to also show running the model, too, and issues with odin perhaps?

Prereqs, especially the compilers

# What about discrete time models

You can extend this same idea to discrete time models, if you're willing to make a few sacrafices along the way. The issue is that a discrete time system is really arbitrary computation - at any particular time really anything can happen (e.g. an intervention that changes the sytem arbitrarily). In addition, the order in which events happens has an effect as we're no longer describing rates but changes to some quantity. For example, you get different behaviour in a birth/death/migration model if you change the order of events (Sally's book has something on this).

# What about stochastic models?

One thing that discrete time models allow for is stochasticity - random updates to variables. You can't do this in continuous time models (unless you make some very limiting assumptions and consider only brownian motion changes to a single variable to get some degree of tractability for an SDE). As soon as things become stochastic we are rarely interested in single realisations from the process, but instead some set (or summary of a set) of realisations of the stochastic process.

(There's lots to discuss here if people are interested, especially once we get to the parallelism section, so we'll leave it until there)

Same example here of ODE model converted to use binomial draws, then a summary  of the trajectories out of this.

# Real model here (epi)

* show run, simulate - any other methods?
* time scaling

# Differences in odin and odin.dust discrete support

Before getting to the good bits, here's what you can't do:

* no use of `output()`; this is required in ODE models to use non-variable quantities but this is not needed in discrete time models
* no use of `interpolate()`; we might restore this later
* no use of `delay()`; this is hard to do well and was not well supported for discrete time models anyway
* not all stochastic distributions supported; just tell us if one you need is missing
* the interface for working with the models is different

https://mrc-ide.github.io/odin.dust/articles/porting.html

# Adding dimensions (epi)



# Running models in parallel

As models get more complicated, they take longer to run. One of the big advantages - possibly the biggest - of odin over odin.dust is that models can take advantage of multiple cores to efficiently compute different realisations at the same time. This will take *at least* the same amount of CPU time but probably less wall-time

* wall time vs cpu time - add a diagram showing how this works
* efficiency comparing wall and cpu time - show real benchmarks on our simple models
* why can't we use mcapply etc?
  - efficiency (data transfer overhead especially)
  - seeding and rng state

Parallelisation strategy: always parallelise at the coarsest level first

* running the same thing over 10 regions, or for 5 different broad set of assumptions: set these off on a cluster on different nodes. These don't interfere and that gives you maximum efficiency.
* running different MCMC chains within an analysis? This is the next block of parallelism, but be careful about seeding
* within a chain we can then use parallelism to make the model faster but due to Amdhel's Law, this will never be a perfect speedup (as we only parallelise some fraction of the process)

dust does a few things here to help you:

* it has a parallel random number generator that can be run in parallel, done by starting many positions along the state space of the uniform random number process
* it then has distribution functions for converting U(0, 1) numbers into your distribution of choice without using any global state
* it also has tools to help you start a distributed set of parallel calculations at points even further apart in the stream (for mcmc), and saving/reloading that rng state

Important that this is totally different to the R RNG engine

Do not parallelise dust models with mclapply, parLapply, doParallel or similar, it will be less efficient than using its own parallel methods, and may not work due to how memory is set up.

You need OpenMP set up on your machine for this to work. For macOS this is a drag. For windows and Linux it should work out of the box.

Check your system with:

```
dust::dust_openmp_support()
```

Test if a model has support:

```
walk$public_methods$has_openmp()
walk$new(list(sd = 1), 0, 1)$as_openmp()
```

**Running in parallel will not change results** - this is an important design decision in dust. No matter how many threads you use for your problem you should get the same answer. It is possible that you may see different answers on different platforms however.

To bring up a model with more than one thread, add `n_threads = 8` when you initialise it, or use the `set_n_threads()` method on an object that already exists. Going beyond the number of threads you have on your machine will not typically show a good speedup.

Many methods are parallelised, but `run` and `simulate` are the ones you'll notice.

Unlike `parallel::parLapply` etc more threads does not increase memory usage.


# More dimensions - age x vaccination (epi)


# Packaging your models

Working with `odin.dust::odin_dust` is pretty tedious and has some drawbacks. In particular, every user of the model is required to have a C++ compiler installed, and every time you run anything with the model you need to compile it. As C++ is slow to compile, this can represent a decent chunk of the time taken to run the model!

Packaging a model is easy:

1. Create a basic skeleton for your package with `usethis::create_r_package("mymodel")`
2. Add the DSL code into a file within `inst/odin`
3. Edit `DESCRIPTION`:
   - add cpp11 and dust to LinkingTo
4. Add the useDynLib junk somewhere
5. Run `odin.dust::odin_dust()` to generate all the files
6. Load your package locally with `pkgload::load_all()`

Once you have a package you can do lots of fun things as a developer:

* Add wrapper functions to generate your parameters
* Write unit tests to make sure that things stay working
* Set up GitHub actions to run your tests automatically as you develop
* Create a nice website explaining to the world what your package does

Your users get a couple of nice installation routes (e.g., `remotes:install_github`, drat, r-universe with binaries) depending.

# Time varying parameters (epi)

Example using contact rates?

## Comparison with odin

In odin we support the idea of interpolating functions, you write:

```
beta <- interpolate(beta_time, beta_value, "linear")
```

for example to use linear interpolation between a set of beta time points and values. This is essential for ODE models because we have to be able to look up `beta(t)` at any real valued `t`. However, for discrete time models it's less important - you already know _exactly_ what time steps your model will stop at, in order, because it will stop at every step in turn.

The pattern that we used in sircovid is to create a big array `beta_step` and index into it with

```
beta_step <- if (step >= length(beta_step)) beta_step[length(beta_step)] else beta_step[as.integer(step) + 1]
```

# Running models on a GPU

This goes beyond what is really needed for an introduction, but it's something that I want to highlight.

The parallelisation strategy that we use for dust models scales really well, and you can use this to scale off a CPU and onto a GPU.

CPUs are good at doing general purpose calculations and in a good multicore system you might be able to do up to 16 different things at once. You can program against these using standard APIs, and the only issue is making sure that you don't have any data races really.

GPUs are more challenging. They rely on lining up a bunch of different bits of data and then applying *exactly* the same code to each piece of data at the same time. While this is happening they can organise getting the next bits of data lined up for the next calculations. The payback is that you get potentially tens of thousands of cores at once, but the cost is that every `if` statement is a chore.

odin.dust hides all this from you and you can compile your model without any modification. To do this you need:

* an NVIDIA GPU at least a RTX 20xx (circa 2018 and on). A builtin GPU in your laptop is generally not enough unless you have a very fancy laptop
* all the NVIDIA toolchain (nvcc) in addition to the usual build tools

The general strategy is to recompile the model in *single precision mode* targetting the GPU your system has available.

You then need to start the model targetting one of the GPUs on the machine. By default we'll use the first one (id 0) but you can use any of the available devices.

You should expect to run *at least 100,000* particles to get a decent benefit of this approach. The benefit is in number of particles per unit walltime, not in walltime itself.

Tuning

* At compilation you can also choose to make some additional optimisations such as fixing the dimensions of any arrays being used; this reduces the number of registers and opens up a few more optimisations
* At model initialisation you can change the block size which has a big effect on how the resources are allocated
* Sometimes you can get better performance by forcing the model to use fewer registers than it wants
* You'll inevitably need to use the profiler to check your kernel, this is quite fun in practice

# Erlang distributions (epi)



# Debugging strategies

Any C/C++ error is a bug, repoducible examples are appreciated.

## Avoid creating bugs

Build your model incrementally, and compile often

Put your model in a package, put the package under version control, and add some tests with testthat - this is all easier than you might think

## Read the error messages

if odin can't compile your model, it will produce a message at the *first* error

odin tries pretty hard to produce sensible error messages, do read them

provide some common examples here

## Add some debug logging

We'll try and make this easier soon

# What's next?

* Assoiating data with your model
* Running a particle filter
* Doing inference with your model and data!

# Other advanced things

* extend your model with custom c++ code
