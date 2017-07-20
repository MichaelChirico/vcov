#logic mostly adopted from test.data.table()

test.vcov <- function(...) {
  test_dir = paste0(getNamespaceInfo("vcov", "path"), "/tests/")
  olddir = setwd(test_dir)
  on.exit(setwd(olddir))
  cat("Running tests of `vcov`")
  sys.source(file.path(test_dir, "tests.Rraw"), 
             envir = new.env(parent = .GlobalEnv))
}

test <- function(name, x, y, approx = FALSE, error, warning, message) {
  #Extra spaces since \r moves the cursor to the beginning of
  #  the line, but doesn't erase the current text in the line --
  #  so new text only overwrites old text if it's wider. 
  #  Otherwise, the scars remain.
  cat("\rRunning test: ", name, "                ", sep = "")
  #since most of the package is about using `cat`,
  #  which supersedes output suppression through `invisible`
  capture.output(
    x.catch <- tryCatch(x, error = identity, 
                        warning = identity, message = identity)
  )
  if (inherits(x.catch, "error")) {
    if (missing(error)) {
      cat("\n`", deparse(substitute(x)),
          "` produced an unanticipated error: '",
          x.catch$message, "'.\n", sep = "")
      return()
    }
    if (grepl(error, x.catch$message)) return()
    cat("\nExpected error matching '", error, 
        "', but returned '", x.catch$message, "'.\n", sep = "")
    return()
  }
  if (!missing(error)) {
    cat("\nExpected error matching '", error,
        "', but returned no error.\n", sep = "")
    return()
  }
  if (inherits(x.catch, "warning")) {
    if (missing(warning)) {
      cat("\n`", deparse(substitute(x)),
          "` produced an unanticipated warning: '",
          x.catch$message, "'.\n", sep = "")
      return()
    }
    if (grepl(warning, x.catch$message)) return()
    cat("\nExpected warning matching '", error, 
        "', but returned '", x.catch$message, "'.\n", sep = "")
    return()
  }
  if (!missing(warning)) {
    cat("\nExpected warning matching '", warning,
        "', but returned no warning.\n", sep = "")
    return()
  }
  if (inherits(x.catch, "message")) {
    if (missing(message)) {
      cat("\n`", deparse(substitute(x)),
          "` produced an unanticipated message: '",
          x.catch$message, "'.\n", sep = "")
      return()
    }
    if (grepl(message, x.catch$message)) return()
    cat("\nExpected message matching '", error, 
        "', but returned '", x.catch$message, "'.\n", sep = "")
    return()
  }
  if (!missing(message)) {
    cat("\nExpected message matching '", message,
        "', but returned no message.\n", sep = "")
    return()
  }
  #allow for numerical errors if approx = TRUE
  if (approx) {
    if (all.equal(x.catch, y)) return()
    else 
      cat("\n`", deparse(substitute(x)),
          "` evaluated without errors to:\n", x,
          "\nwhich is not equal to the expected output:\n",
          eval(substitute(y)), "\nat default tolerance\n", sep = "")
  } else {
    if (identical(x.catch, y)) return()
    else 
      cat("\n`", deparse(substitute(x)),
          "` evaluated without errors to:\n", x,
          "\nwhich is not identical to the expected output:\n",
          eval(substitute(y)), "\n", sep = "")
  }
  return()
}
