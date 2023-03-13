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

* on mac follow instructions from:

https://support.posit.co/hc/en-us/articles/200486498-Package-Development-Prerequisites

Then restart R, and check that `pkgbuild::check_build_tools(TRUE)` reports that everything is ok.
