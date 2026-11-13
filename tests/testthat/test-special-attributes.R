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


# set_lb_attribute
test_that("set_lb_attribute() works", {
  EX.dt <- data.table(a=1:2)
  set_lb_attribute(EX.dt, "source", "somewhere")
  expect_equal(attr(EX.dt, "lb.source"), "somewhere")

  EX.df <- data.frame(a=1:2)
  set_lb_attribute(EX.df, "note", "not a data.table")
  expect_equal(attr(EX.df, "lb.note"), "not a data.table")
})


# set_lb_date
test_that("set_lb_date() works", {
  EX.dt <- data.table(a=1:2)
  set_lb_date(EX.dt, "2021-05-08")
  expect_equal(attr(EX.dt, "lb.date"), as.Date("2021-05-08"))
  set_lb_date(EX.dt, as.Date("2021-05-09"))
  expect_equal(attr(EX.dt, "lb.date"), as.Date("2021-05-09"))
  expect_error(set_lb_date(EX.dt, "not a date"))
})


# cp_lb_attributes
test_that("cp_lb_attributes() works", {
  EX.from <- data.table(a=1:2)
  set_lb_date(EX.from, "2021-05-08")
  set_lb_attribute(EX.from, "note", "just an example")
  setattr(EX.from, "other", "not a libbib attribute")
  EX.to <- data.table(b=1)
  cp_lb_attributes(EX.from, EX.to)
  expect_equal(attr(EX.to, "lb.date"), as.Date("2021-05-08"))
  expect_equal(attr(EX.to, "lb.note"), "just an example")
  expect_null(attr(EX.to, "other"))
})


# fread_plus_date
test_that("fread_plus_date() works", {
  make_example_file("plain", "iris-2021-05-08.csv")
  expect_equal(get_date_read("plain", "iris.csv"),
               as.Date("2021-05-08"))
  expect_equal(get_date_read("plain", "iris-2021-05-08.csv"),
               as.Date("2021-05-08"))
  expect_equal(fread_plus_date(file.path(EX.tmpdir, "plain", "iris.csv"))[, a],
               1:2)
  expect_equal(fread_plus_date(file.path(EX.tmpdir, "plain", "iris.csv"),
                               nrows=1)[, .N],
               1)

  make_example_file("with space", "iris-2021-05-08.csv")
  expect_equal(get_date_read("with space", "iris.csv"),
               as.Date("2021-05-08"))

  make_example_file("my.data", "iris-2021-05-08.csv")
  expect_equal(get_date_read("my.data", "iris.csv"),
               as.Date("2021-05-08"))

  make_example_file("digit-in-name", "iris2-2021-05-08.csv")
  expect_equal(get_date_read("digit-in-name", "iris2.csv"),
               as.Date("2021-05-08"))
})

test_that("fread_plus_date() works with a compressed file", {
  # fread() needs the R.utils package to read .gz files
  skip_if_not_installed("R.utils")
  make_example_file("compressed", "iris-2021-05-08.csv.gz")
  expect_equal(get_date_read("compressed", "iris.csv.gz"),
               as.Date("2021-05-08"))
})

test_that("fread_plus_date() handles missing dates and files", {
  make_example_file("no-date", "iris.csv")
  expect_message(EX.fallback <- get_date_read("no-date", "iris.csv"),
                 "no date in filename found... using today's date")
  expect_equal(EX.fallback, Sys.Date())
  expect_error(fread_plus_date(file.path(EX.tmpdir, "no-date", "iris.csv"),
                               allow.fallback.date=FALSE),
               "no date in filename found")
  expect_error(fread_plus_date(file.path(EX.tmpdir, "no-date", "nothing.csv")),
               "no matching filename")

  make_example_file("two-matches", "iris.csv")
  make_example_file("two-matches", "iris-2021-05-08.csv")
  expect_error(fread_plus_date(file.path(EX.tmpdir, "two-matches", "iris.csv")),
               "more than one matching file")
})

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
test_that("fwrite_plus_date() works", {
  EX.dated <- data.table(a=1:2)
  set_lb_date(EX.dated, "2021-05-08")
  EX.undated <- data.table(a=1:2)
  EX.outdir <- file.path(EX.tmpdir, "out")
  dir.create(EX.outdir)

  fwrite_plus_date(EX.dated, file.path(EX.outdir, "iris.csv"))
  expect_true(file.exists(file.path(EX.outdir, "iris-2021-05-08.csv")))
  fwrite_plus_date(EX.dated, file.path(EX.outdir, "iris.csv.gz"))
  expect_true(file.exists(file.path(EX.outdir, "iris-2021-05-08.csv.gz")))

  # what was written can be read back with its date
  expect_equal(get_date_read("out", "iris.csv"),
               as.Date("2021-05-08"))

  # no lb.date attribute
  expect_message(fwrite_plus_date(EX.undated,
                                  file.path(EX.outdir, "undated.csv")),
                 "DT has no usable date attribute... using today's date")
  expect_true(file.exists(file.path(EX.outdir,
                                    sprintf("undated-%s.csv", Sys.Date()))))
  expect_error(fwrite_plus_date(EX.undated,
                                file.path(EX.outdir, "undated.csv"),
                                allow.fallback.date=FALSE),
               "DT has no usable date attribute")

  # ignoring the lb.date attribute
  fwrite_plus_date(EX.dated, file.path(EX.outdir, "today.csv"),
                   from.attribute=FALSE)
  expect_true(file.exists(file.path(EX.outdir,
                                    sprintf("today-%s.csv", Sys.Date()))))
})

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

