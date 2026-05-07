test_that("set_privacy_defaults sets options and handles levels", {
  withr::local_options(list(engager.verbose = TRUE))

  cfg <- set_privacy_defaults("privacy_strict", "stop")
  expect_equal(getOption("engager.privacy_level"), "privacy_strict")
  expect_equal(getOption("engager.unmatched_names_action"), "stop")
  expect_equal(cfg$privacy_level, "privacy_strict")
  expect_equal(cfg$unmatched_names_action, "stop")

  cfg <- set_privacy_defaults("privacy_standard", "warn")
  expect_equal(getOption("engager.privacy_level"), "privacy_standard")
  expect_equal(getOption("engager.unmatched_names_action"), "warn")

  expect_warning(set_privacy_defaults("none"), "Privacy disabled globally")
  expect_equal(getOption("engager.privacy_level"), "none")
})

test_that("set_privacy_defaults arg matching works", {
  # default args choose first of each
  cfg <- set_privacy_defaults()
  expect_true(cfg$privacy_level %in% c("privacy_strict", "privacy_standard", "mask", "none"))
  expect_true(cfg$unmatched_names_action %in% c("stop", "warn"))
})
