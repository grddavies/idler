test_server_0001 <- function(input, output, session) {
  idler::set(0.0001)
}

test_server_0 <- function(input, output, session) {
  idler::set(0)
}

test_ui <- function(request) {
  idler::use_idler()
}

test_that("Sessions terminate automatically with positive nonzero timer", {
  skip_on_cran()
  app <- shinytest::ShinyDriver$new(shiny::shinyApp(test_ui, test_server_0001))
  last_console_log <- tail(app$getDebugLog("shiny_console")$message, n = 1)
  expect_match(last_console_log, "timed out", perl = TRUE)
  app$finalize()
})

test_that("Sessions do not terminate with timer set to zero", {
  skip_on_cran()
  app <- shinytest::ShinyDriver$new(shiny::shinyApp(test_ui, test_server_0))
  last_console_log <- tail(app$getDebugLog("shiny_console")$message, n = 1)
  expect_false(grepl("timed out", last_console_log, perl = TRUE))
  app$finalize()
})
