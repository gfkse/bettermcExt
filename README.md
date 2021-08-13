# bettermcExt

[![R build
status](https://github.com/gfkse/bettermcExt/workflows/R-CMD-check/badge.svg)](https://github.com/gfkse/bettermcExt/actions?workflow=R-CMD-check)
[![codecov](https://codecov.io/gh/gfkse/bettermcExt/branch/master/graph/badge.svg)](https://codecov.io/gh/gfkse/bettermcExt)

The `bettermcExt` package provides extensions of the
[bettermc](https://cran.r-project.org/package=bettermc) package which
are not allowed on CRAN.

## Installation of the Latest Release

``` r
# install.packages("remotes")
remotes::install_github("gfkse/bettermcExt", remotes::github_release())
```

## Overloading `parallel::mclapply()` With `bettermc::mclapply()`

Enable the use of `bettermc::mclapply()` by third-party packages
originally using `mclapply()` from the `parallel` package, e.g. `doMC`
or `rstan`. This is achieved by replacing the `mclapply`-function in
various environments, which violates the following [CRAN
policy](https://cran.r-project.org/web/packages/policies.html):

> A package must not tamper with the code already loaded into R: any
> attempt to change code in the standard and recommended packages which
> ship with R is prohibited. Altering the namespace of another package
> should only be done with the agreement of the maintainer of that
> package.

### Example: Making `doMC` Reproducible

``` r
doMC::registerDoMC(2L)

# fix mc.set.seed arg to NA in order to avoid modifications by doMC:::doMC
bettermcExt::overload_mclapply(imports = "doMC", fixed_args = list(mc.set.seed = NA))

set.seed(123)
ret1 <- foreach::`%dopar%`(foreach::foreach(i = 1:4), runif(1))
set.seed(123)
ret2 <- foreach::`%dopar%`(foreach::foreach(i = 1:4), runif(1))
stopifnot(identical(ret1, ret2))

bettermcExt::undo_overload_mclapply(imports = "doMC")

# back to using parallel::mclapply under the hood -> seeding has no effect
set.seed(123)
ret3 <- foreach::`%dopar%`(foreach::foreach(i = 1:4), runif(1))
set.seed(123)
ret4 <- foreach::`%dopar%`(foreach::foreach(i = 1:4), runif(1))
stopifnot(identical(ret3, ret4))
```

    ## Error: identical(ret3, ret4) is not TRUE

### Example: Making `rstan::sampling()` Reproducible

Note that `rstan::sampling()` uses `mclapply()` only in a
non-interactive session.

``` r
bettermcExt::overload_mclapply(parallel_namespace = TRUE)

m <- rstan::stan_model(model_code = 'parameters {real y;} model {y ~ normal(0,1);}')

set.seed(456)
capture.output(f1 <- rstan::sampling(m, iter = 100, cores = 2), file = "/dev/null")
set.seed(456)
capture.output(f2 <- rstan::sampling(m, iter = 100, cores = 2), file = "/dev/null")
stopifnot(identical(rstan::extract(f1), rstan::extract(f2)))

bettermcExt::undo_overload_mclapply(parallel_namespace = TRUE)

# back to using parallel::mclapply under the hood -> seeding has no effect
set.seed(456)
capture.output(f3 <- rstan::sampling(m, iter = 100, cores = 2), file = "/dev/null")
set.seed(456)
capture.output(f4 <- rstan::sampling(m, iter = 100, cores = 2), file = "/dev/null")
stopifnot(identical(rstan::extract(f3), rstan::extract(f4)))
```

    ## Error: identical(rstan::extract(f3), rstan::extract(f4)) is not TRUE
