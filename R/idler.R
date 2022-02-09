#' Set up a Shiny app to use idler
#'
#' @description This function must be called from a Shiny app's UI
#'
#' @return shiny.tag containing a JS message handler to monitor client app use
#'
#' @examples
#' shiny::tags$head(use_idler())
#' @export
use_idler <- function() {
  shiny::singleton(
    shiny::tags$head(
      shiny::tags$script(src = "idler-assets/idler.js")
    )
  )
}

#' Set up observer for client-side idle timeout message
#'
#' @param session Session to observe (the default should almost always be used)
#'
#' @return a Shiny observer R6 class object  (see [shiny::observe()])
#'
#' @examples
#' \dontrun{
#' idler::idle_timeout()
#' }
idle_timeout <- function(session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) stop_not_in_session()
  shiny::observeEvent(session$input$`idler-timeout`, {
    message("Session (", session$token, ") timed out at: ", Sys.time())
    shinyWidgets::sendSweetAlert(
      session,
      title = "Session Timeout",
      text = htmltools::HTML(sprintf(
        "<p>Session timeout due to %.2fs inactivity<br>%s</p>",
        session$input$`idler-timeout` / 1000,
        Sys.time()
      )),
      type = "error",
      btn_labels = NA,
      closeOnClickOutside = FALSE,
      html = TRUE
    )
    session$close()
  })
}

#' Set up observer to warn client their session will be closed
#'
#' @inheritParams idle_timeout
idle_warning <- function(session = shiny::getDefaultReactiveDomain()) {
  shiny::observeEvent(session$input$`idler-warning`, {
    message("Session (", session$token, ") warned at: ", Sys.time())
    shinyWidgets::sendSweetAlert(
      session,
      title = "Session Timeout Warning",
      text = htmltools::HTML(sprintf(
        "<p>Your session will time out due to inactivity in %ss<br>%s</p>",
        session$input$`idler-warning` / 1000,
        Sys.time()
      )),
      type = "warning",
      btn_labels = NA,
      showCloseButton = TRUE,
      closeOnClickOutside = TRUE,
      html = TRUE
    )
  })
}

#' Set the idle timer duration in seconds
#'
#' @param duration number of seconds of inactivity before the session is ended
#' @param warn_after number of seconds of inactivity before the user is warned.
#'   A NULL or value greater than `duration` will give the user no warning
#'   before terminating the session.
#' @return invisibly returns a list of Shiny observer R6 class objects. The
#'  first element observes timeout messages, the second observes warning inputs
#'  from client side idler code. (see [shiny::observe()])
#' @examples
#' \dontrun{
#' # We set a 10s timeout
#' idler::set(10)
#' }
#' @export
set <- function(duration, warn_after = NULL) {
  session <- shiny::getDefaultReactiveDomain()
  if (is.null(session)) stop_not_in_session()
  timeoutObs <- idle_timeout(session)
  warningObs <- idle_warning(session)
  msg <- list(timeout = duration, warning = warn_after)
  session$sendCustomMessage(
    "setTimeout",
    Map(function(x) x * 1000, msg)
  )
  invisible(list(timeoutObs, warningObs))
}

#' Error constructor
#' @noRd
#' @keywords internal
stop_not_in_session <- function() {
  rlang::abort(
    caller = deparse(sys.call(-1)),
    class = "idler_error_not_in_session"
  )
}

#' Format error messages
#' @export
#' @noRd
conditionMessage.idler_error_not_in_session <- function(c) {
  glue::glue_data(c, "`{caller}` called outside of a Shiny reactive domain")
}
