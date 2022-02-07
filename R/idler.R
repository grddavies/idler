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

#' Set the idle timer duration in seconds
#'
#' @param duration number of seconds of inactivity before the session is ended
#' @return invisibly returns a Shiny observer R6 class object
#'  (see [shiny::observe()])
#' @examples
#' \dontrun{
#' # We set a 10s timeout
#' idler::set(10)
#' }
#' @export
set <- function(duration) {
  session <- shiny::getDefaultReactiveDomain()
  if (is.null(session)) stop_not_in_session()
  observer <- idle_timeout(session)
  session$sendCustomMessage("setTimeout", duration * 1000)
  invisible(observer)
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
