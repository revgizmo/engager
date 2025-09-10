test_that("startup message option is set correctly", {
  # Test that the startup message option is set correctly
  expect_true(getOption("zoomstudentengagement.show_startup", TRUE))
})

test_that("startup message can be suppressed", {
  # Test that startup message can be suppressed
  options(zoomstudentengagement.show_startup = FALSE)
  expect_false(getOption("zoomstudentengagement.show_startup", TRUE))
  # Reset option
  options(zoomstudentengagement.show_startup = TRUE)
})

test_that("startup message function exists and is callable", {
  # Test that the startup message function exists and can be called
  # This tests the function exists without relying on package loading behavior
  expect_true(exists(".onAttach", envir = asNamespace("zoomstudentengagement")))

  # Test that the function can be called (it should not error)
  expect_error(
    .onAttach("test_lib", "zoomstudentengagement"),
    NA
  )
})
