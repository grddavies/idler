test_server_01 <- function(input, output, session) {
  idler::set(0.1)
}

test_server_0 <- function(input, output, session) {
  idler::set(0)
}

test_ui <- function(request) {
  shiny::tagList(idler::use_idler(), shiny::tags$h1("Test"))
}

test_that("Sessions terminate automatically with positive nonzero timer", {
  skip_on_cran()
  app <- shinytest::ShinyDriver$new(shiny::shinyApp(test_ui, test_server_01))
  app$waitFor("", timeout = 100)
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
