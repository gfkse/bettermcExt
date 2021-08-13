test_that("overloading works for doMC", {
  skip_on_os("windows")
  skip_if_not_installed("doMC")
  skip_if_not_installed("foreach")

  overload_mclapply(imports = "doMC", fixed_args = list(mc.set.seed = NA),
                    defaults = list(mc.dump.frames = "no"))

  doMC::registerDoMC(2L)

  set.seed(123)
  ret1 <- foreach::`%dopar%`(foreach::foreach(i = 1:4), runif(1))
  set.seed(123)
  ret2 <- foreach::`%dopar%`(foreach::foreach(i = 1:4), runif(1))
  expect_identical(ret1, ret2)

  undo_overload_mclapply(imports = "doMC")

  set.seed(123)
  ret1 <- foreach::`%dopar%`(foreach::foreach(i = 1:4), runif(1))
  set.seed(123)
  ret2 <- foreach::`%dopar%`(foreach::foreach(i = 1:4), runif(1))
  expect_true(!identical(ret1, ret2))
})

test_that("overloading works for imports='all'", {
  overload_mclapply(imports = "all")

  if (requireNamespace("doMC", quietly = TRUE)) {
    expect_identical(get("mclapply", parent.env(asNamespace("doMC"))),
                     bettermc::mclapply)
  }

  undo_overload_mclapply(imports = "all")

  skip_if_not_installed("doMC")
  expect_identical(get("mclapply", parent.env(asNamespace("doMC"))),
                   parallel::mclapply)
})

test_that("overloading mclapply in namespace:parallel works", {
  skip_if(utils::packageVersion("bettermc") <= package_version("1.1.2"))
  overload_mclapply(parallel_namespace = TRUE)
  expect_identical(environment(parallel::mclapply), asNamespace("bettermc"))

  set.seed(123)
  ret1 <- parallel::mclapply(1:2, function(i) runif(1))
  set.seed(123)
  ret2 <- parallel::mclapply(1:2, function(i) runif(1))
  expect_identical(ret1, ret2)

  undo_overload_mclapply(parallel_namespace = TRUE)
  expect_identical(environment(parallel::mclapply), asNamespace("parallel"))
})

test_that("overloading mclapply in package:parallel works", {
  expect_silent(overload_mclapply(parallel_package = TRUE))
  library(parallel)
  overload_mclapply(parallel_package = TRUE)
  expect_identical(environment(as.environment("package:parallel")[["mclapply"]]),
                   asNamespace("bettermc"))

  set.seed(123)
  ret1 <- mclapply(1:2, function(i) runif(1))
  set.seed(123)
  ret2 <- mclapply(1:2, function(i) runif(1))
  expect_identical(ret1, ret2)

  undo_overload_mclapply(parallel_package = TRUE)
  expect_identical(environment(as.environment("package:parallel")[["mclapply"]]),
                   asNamespace("parallel"))
  detach("package:parallel")
})
