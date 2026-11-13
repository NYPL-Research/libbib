context("checking functions in special-attributes.R")


##############################################
###               SETUP                    ###
##############################################

# everything is written under R's session temp directory
EX.tmpdir <- tempfile("libbib-special-attributes-")
dir.create(EX.tmpdir)

# writes a small csv to the given path (under the temp directory),
# creating any directories needed
make_example_file <- function(...){
  apath <- file.path(EX.tmpdir, ...)
  dir.create(dirname(apath), recursive=TRUE, showWarnings=FALSE)
  fwrite(data.table(a=1:2), apath)
}

# reads the given path (under the temp directory) with fread_plus_date()
# and returns the lb.date attribute
get_date_read <- function(...){
  attr(fread_plus_date(file.path(EX.tmpdir, ...)), "lb.date")
}


# --------------------------------------------------------------- #


# fread_plus_date
test_that("fread_plus_date() tolerates regex characters in the path", {
  make_example_file("plus-in-name", "data+x-2021-05-08.csv")
  expect_equal(get_date_read("plus-in-name", "data+x.csv"),
               as.Date("2021-05-08"))

  make_example_file("parens-in-name", "data(x)-2021-05-08.csv")
  expect_equal(get_date_read("parens-in-name", "data(x).csv"),
               as.Date("2021-05-08"))

  make_example_file("Dropbox (Personal)", "iris-2021-05-08.csv")
  expect_equal(get_date_read("Dropbox (Personal)", "iris.csv"),
               as.Date("2021-05-08"))

  make_example_file("a+b", "iris-2021-05-08.csv")
  expect_equal(get_date_read("a+b", "iris.csv"),
               as.Date("2021-05-08"))
})

test_that("fread_plus_date() rejects file names with no extension", {
  make_example_file("no-extension", "iris-2021-05-08")
  expect_error(fread_plus_date(file.path(EX.tmpdir, "no-extension", "iris")),
               "file name must have an extension")
  expect_error(fread_plus_date(file.path(EX.tmpdir, "no-extension",
                                         "iris-2021-05-08")),
               "file name must have an extension")
})


# fwrite_plus_date
test_that("fwrite_plus_date() rejects file names with no extension", {
  EX.dated <- data.table(a=1:2)
  set_lb_date(EX.dated, "2021-05-08")
  dir.create(file.path(EX.tmpdir, "no-extension-out"))
  expect_error(fwrite_plus_date(EX.dated, file.path(EX.tmpdir,
                                                    "no-extension-out", "iris")),
               "file name must have an extension")
  expect_equal(list.files(file.path(EX.tmpdir, "no-extension-out")),
               character(0))
})

