context("checking functions in utilities.R")


##############################################
###               SETUP                    ###
##############################################

mt <- as.data.table(mtcars)
iris_dt <- as.data.table(iris)
mt_some_na <- copy(mt)
mt_some_na[mpg<16, mpg:=NA]

ejemplo <- as.data.table(iris)
setnames(ejemplo, c("Sepal Length", "Sepal@Width", "Petal Length",
                    "Petal\\nWidth", "Spêcies"))

ejemplo2 <- as.data.table(iris)
setnames(ejemplo2, c("Sepal Length", "Sepal@Width", "Petal Length",
                     "Petal\\nWidth", "Spêcies"))
ejemplo2[, Sp_cies:=1]
ejemplo2[, Sp_cies_1:=2]

ejemplo3 <- as.data.table(iris)
setnames(ejemplo3, c("data0", "data1", "data!", "data@", "d4ta4"))

letters_dt <- data.table(g=c("a", "a", "a", "b", "b", "c"))


# --------------------------------------------------------------- #


test_that("dt_del_cols() works", {
  expect_equal(names(dt_del_cols(copy(mt), "cyl", "disp", "hp")),
               c("mpg", "drat", "wt", "qsec", "vs", "am", "gear", "carb"))
  expect_equal(names(dt_del_cols(copy(mt), c("cyl", "disp", "hp"))),
               c("mpg", "drat", "wt", "qsec", "vs", "am", "gear", "carb"))
  expect_warning(dt_del_cols(copy(mt), "not_a_column"))
  expect_error(dt_del_cols(mtcars, "cyl"),
    regexp="DT must be a data.table object",
    fixed=TRUE)
})

test_that("dt_keep_cols() works", {
  expect_equal(names(dt_keep_cols(copy(mt), "mpg", "am", "gear", "carb")),
               c("mpg", "am", "gear", "carb"))
  # the order of the columns in the data.table is kept
  expect_equal(names(dt_keep_cols(copy(mt), "carb", "mpg")),
               c("mpg", "carb"))
  expect_warning(dt_keep_cols(copy(mt), "mpg", "not_a_column"),
    regexp='Columns ("not_a_column") are missing from supplied data.table',
    fixed=TRUE)
  expect_error(dt_keep_cols(mtcars, "cyl"),
    regexp="DT must be a data.table object",
    fixed=TRUE)
})

test_that("dt_counts_and_percents() works", {
  # factor column
  tmp <- dt_counts_and_percents(iris_dt, "Species")
  expect_equal(names(tmp), c("Species", "count", "percent"))
  expect_equal(as.character(tmp[, Species]),
               c("setosa", "versicolor", "virginica", "TOTAL"))
  expect_equal(tmp[, count], c(50, 50, 50, 150))
  expect_equal(tmp[, percent], c(33.33, 33.33, 33.33, 100))

  # character column
  tmp <- dt_counts_and_percents(letters_dt, "g")
  expect_equal(tmp[, g], c("a", "b", "c", "TOTAL"))
  expect_equal(tmp[, count], c(3, 2, 1, 6))
  expect_equal(tmp[, percent], c(50, 33.33, 16.67, 100))

  # percent.cutoff
  tmp <- dt_counts_and_percents(letters_dt, "g", percent.cutoff=20)
  expect_equal(tmp[, g], c("a", "b", "OTHER", "TOTAL"))
  expect_equal(tmp[, count], c(3, 2, 1, 6))

  # big.mark
  tmp <- dt_counts_and_percents(data.table(g=rep(c("a", "b"), c(1500, 500))),
                                "g", big.mark=",")
  expect_equal(tmp[, count], c("1,500", "500", "2,000"))
  expect_error(dt_counts_and_percents(letters_dt, "g", big.mark=TRUE),
    regexp="big.mark must either be FALSE or a character type",
    fixed=TRUE)

  # column that is not a character or a factor
  mt2 <- copy(mt)
  expect_warning(tmp <- dt_counts_and_percents(mt2, "cyl"),
    regexp="Column (cyl) is not a factor (or character), copying DT and converting...",
    fixed=TRUE)
  expect_equal(as.character(tmp[, cyl]), c("8", "4", "6", "TOTAL"))
  expect_equal(tmp[, count], c(14, 11, 7, 32))
  expect_equal(class(mt2[, cyl]), "numeric")

  # columns with the same name as something used internally
  tmp <- dt_counts_and_percents(data.table(percent=c("a", "a", "b")),
                                "percent")
  expect_equal(tmp[[1]], c("a", "b", "TOTAL"))
  expect_equal(tmp[[2]], c(2, 1, 3))
  # (a column named "theby" that is not the one being grouped by)
  tmp <- dt_counts_and_percents(data.table(theby=c("x", "x", "x", "y"),
                                           g=c("a", "a", "b", "b")),
                                "g")
  expect_equal(names(tmp), c("g", "count", "percent"))
  expect_equal(tmp[[1]], c("a", "b", "TOTAL"))
  expect_equal(tmp[[2]], c(2, 2, 4))
  tmp <- dt_counts_and_percents(data.table(val=c("a", "a", "b")), "val")
  expect_equal(tmp[, val], c("a", "b", "TOTAL"))
  expect_equal(tmp[, count], c(2, 1, 3))
  tmp <- dt_counts_and_percents(data.table(thetotal=c("a", "a", "b")),
                                "thetotal")
  expect_equal(tmp[[1]], c("a", "b", "TOTAL"))
  expect_equal(tmp[[2]], c(2, 1, 3))
  expect_warning(tmp <- dt_counts_and_percents(data.table(group_by_this=c(1, 1, 2)),
                                               "group_by_this"),
    regexp="is not a factor (or character)",
    fixed=TRUE)
  expect_equal(as.character(tmp[[1]]), c("1", "2", "TOTAL"))
  expect_equal(tmp[[2]], c(2, 1, 3))

  expect_error(dt_counts_and_percents(iris, "Species"),
    regexp="DT must be a data.table object",
    fixed=TRUE)
})


test_that("get_clean_names() works", {
  expect_equal(get_clean_names(ejemplo),
               c("sepal_length", "sepal_width", "petal_length",
                 "petal_nwidth", "sp_cies"))
  expect_equal(get_clean_names(ejemplo, lower=FALSE),
               c("Sepal_Length", "Sepal_Width", "Petal_Length",
                 "Petal_nWidth", "Sp_cies"))
  expect_equal(get_clean_names(ejemplo2, lower=FALSE),
               c("Sepal_Length", "Sepal_Width", "Petal_Length",
                 "Petal_nWidth", "Sp_cies", "Sp_cies_2", "Sp_cies_1"))
  expect_equal(get_clean_names(ejemplo3),
               c("data0", "data1", "data_", "data__1", "d4ta4"))
})

test_that("dt_set_clean_names() works", {
  expect_equal(names(dt_set_clean_names(copy(ejemplo))),
               c("sepal_length", "sepal_width", "petal_length",
                 "petal_nwidth", "sp_cies"))
  expect_equal(names(dt_set_clean_names(copy(ejemplo), lower=FALSE)),
               c("Sepal_Length", "Sepal_Width", "Petal_Length",
                 "Petal_nWidth", "Sp_cies"))
  # the names are set by reference
  ejemplo4 <- copy(ejemplo)
  dt_set_clean_names(ejemplo4)
  expect_equal(names(ejemplo4)[1], "sepal_length")
  expect_error(dt_set_clean_names(iris),
    regexp="DT must be a data.table object",
    fixed=TRUE)
})


test_that("dt_percent_not_na() works", {
  expect_equal(dt_percent_not_na(mt_some_na, "mpg"), 68.75)
  expect_equal(dt_percent_not_na(mt, "mpg"), 100)
  # a column with the same name as the argument
  expect_equal(dt_percent_not_na(data.table(acolumn=c(1, NA)), "acolumn"),
               50)
  expect_error(dt_percent_not_na(iris, "Species"),
    regexp="DT must be a data.table object",
    fixed=TRUE)
})


test_that("dt_na_breakdown() works", {
  tmp <- dt_na_breakdown(mt_some_na, "mpg")
  expect_equal(names(tmp), c("mpg_not_na", "count", "percent"))
  expect_equal(tmp[, mpg_not_na], c("TRUE", "FALSE", "TOTAL"))
  expect_equal(tmp[, count], c(22, 10, 32))
  expect_equal(tmp[, percent], c(68.75, 31.25, 100))

  # no NAs
  tmp <- dt_na_breakdown(mt, "mpg")
  expect_equal(tmp[, mpg_not_na], c("TRUE", "TOTAL"))
  expect_equal(tmp[, count], c(32, 32))

  # a column with the same name as the argument
  tmp <- dt_na_breakdown(data.table(acolumn=c(1, NA)), "acolumn")
  expect_equal(tmp[, count], c(1, 1, 2))

  expect_error(dt_na_breakdown(mtcars, "mpg"),
    regexp="DT must be a data.table object",
    fixed=TRUE)
})


test_that("dt_add_to_col_names() works", {
  expect_equal(names(dt_add_to_col_names(data.table(iris), "_post")),
               c("Sepal.Length_post", "Sepal.Width_post", "Petal.Length_post",
                 "Petal.Width_post", "Species_post"))
  expect_equal(names(dt_add_to_col_names(data.table(iris), "pre_", prefix=TRUE)),
               c("pre_Sepal.Length", "pre_Sepal.Width", "pre_Petal.Length",
                 "pre_Petal.Width", "pre_Species"))
  expect_equal(names(dt_add_to_col_names(data.table(iris), "pre_", prefix=TRUE,
                                         exclude=c("Species", "Sepal.Length"))),
               c("Sepal.Length", "pre_Sepal.Width", "pre_Petal.Length",
                 "pre_Petal.Width", "Species"))
  expect_equal(names(dt_add_to_col_names(data.table(iris), "pre_", prefix=TRUE,
                                         include=c("Sepal.Width", "Petal.Length",
                                                   "Petal.Width"))),
               c("Sepal.Length", "pre_Sepal.Width", "pre_Petal.Length",
                 "pre_Petal.Width", "Species"))
  expect_error(dt_add_to_col_names(iris, "hi"),
               "DT must be a data.table")
  expect_warning(dt_add_to_col_names(data.table(iris), "hi", include=c("people", "streets")),
               '') #'Columns ("people", "streets") are missing from supplied data.table')
  expect_warning(dt_add_to_col_names(data.table(iris), "hi", exclude=c("people", "streets")),
               '') #'Columns ("people", "streets") are missing from supplied data.table')
  expect_warning(dt_add_to_col_names(data.table(iris), "hi", exclude="people"),
               '') #'Columns ("people") are missing from supplied data.table')
  expect_error(dt_add_to_col_names(data.table(iris), exclude="bs", include="gs"),
               "cannot have both 'include' and 'exclude' parameters at the same time")
})


