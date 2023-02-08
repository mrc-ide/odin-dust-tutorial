This Thursday afternoon (from 15:30, Praed St meeting room), we will be running the next departmental training session "Introduction to mcstate".  This workshop is aimed at anyone who wants to perform inference with stochastic compartmental models written in odin. We will show how to use a particle filter with these models and your data, and then run a particle mcmc with this.

This will be an interactive in-person workshop with floating helpers, so it's really important to try and bring along a laptop with prerequisites installed, so that by the end of the workshop you should be able to run everything yourself.

This workshop follows from last week's workshop (introduction to odin and dust), but we'll cover the basics even if you were unable to make that session.

Install required packages, by running these commands in a fresh R session:

```
options(repos = c(
  mrcide = 'https://mrc-ide.r-universe.dev',
  CRAN = 'https://cloud.r-project.org'))
install.packages(c("odin", "dust", "odin.dust", "mcstate"))
```

You also need to have a working C++ toolchain. If you use stan already there's a good chance that you already have one and you should probably avoid fiddling around with it unnecessarily as stan tends to be awfully fussy about settings.

You can check if you are set up ok by running:

```
pkgbuild::check_build_tools(TRUE)
```

If you run this from Rstudio and tools are not available, apparently this function will help you install the compiler. To install the tools manually:

* on windows follow instructions from
https://cran.r-project.org/bin/windows/Rtools/rtools40.html - be sure to select the "edit PATH" checkbox during installation or the tools will not be found.
* on mac: follow instructions from:
https://support.posit.co/hc/en-us/articles/200486498-Package-Development-Prerequisites

In both cases, restart R and check that
Then restart R, and check that `pkgbuild::check_build_tools(TRUE)` reports that everything is ok.

We will share links to code via the DIDE Training Series team channel. In Teams, check your list of Teams, look for "DIDE Training Series - WP", select the bit that says "13 hidden channels" or similar, and next to "9th Feb 2023 - MCState by..." click "Show" to display the channel in your sidebar.
