
**If you are viewing this file on CRAN, please check
[latest news on GitHub](https://github.com/NYPL/libbib/blob/master/NEWS.md)
where the formatting is better.**

# libbib 1.7 (in development)

1. Fixed a bug in `normalize_issn` where, if `pretty` was `TRUE`, invalid
   ISSNs were returned hyphenated (instead of `NA`) and `NA`s were
   returned as "NA-NA".

2. `is_valid_isbn_10`, `is_valid_isbn_13`, `is_valid_issn`,
   `check_isbn_10_check_digit`, `check_isbn_13_check_digit`, and
   `check_issn_check_digit` now return a logical `NA` (instead of a
   character `NA`) when every element of the input is `NA`.

3. `normalize_isbn_10`, `normalize_isbn_13`, `normalize_isbn`,
   `normalize_issn`, and `convert_to_isbn_13` now return a character `NA`
   (instead of a logical `NA`) when every element of the input is invalid.
   The same goes for `get_lc_call_first_letter` and
   `get_all_lc_call_subject_letters` when given a single invalid call
   number.

4. `is_valid_lc_call` now returns `NA` when given a bare `NA` (or a
   vector of only `NA`s), instead of throwing an error.

5. Fixed a bug in `fread_plus_date` where a file name given without its
   date could not be read if the file name (or any directory in its path)
   contained a character that is special in regular expressions, such
   as `+`, `(`, or `)`.

6. `fread_plus_date` and `fwrite_plus_date` now stop with an error if
   given a file name with no extension. Previously, `fwrite_plus_date`
   would write a file with "NA" at the end of its name.

7. `marc_leader_get_info` no longer returns the record type
   "Manuscript language material" with a trailing space.

8. Fixed a bug in `fread_plus_date` where a file could not be found if
   its name (or any directory in its path) contained a square bracket.

9. Fixed bugs in `dt_counts_and_percents`, `dt_percent_not_na`, and
   `dt_na_breakdown` where a column with the same name as one used
   inside those functions ("val", "percent", "thetotal", "theby",
   "group_by_this", or "acolumn") caused an error or an incorrect result.

10. Fixed a bug in `normalize_isbn_10`, `normalize_isbn`, `normalize_issn`,
    and `convert_to_isbn_13` where a vertical bar (`|`) in the input was
    not stripped along with the other non-digit and non-"X" characters.
    For example, `normalize_isbn("|a0195209206")` returned `NA`.

# libbib 1.6.4

1. Bug fix in `dt_counts_and_percents` wherein if the group by column
   was not a character or a factor, the "TOTAL"", and "OTHER" rows would
   be NA.

2. Fixed a bug in `get_clean_names` (and, by extension, `dt_set_clean_names`)
   where "0" was accidentally excluded from the whitelisted character set.

# libbib 1.6.2

## new features

1. Functions `fread_plus_date`, `fwrite_plus_date`, `set_lb_attribute`,
   `set_lb_date`, and `cp_lb_attributes` to read/write files with
   special date attribute and work with date and other special
   attributes.

## bug fixes

1. LC call number functions now call str_trim before anything


# libbib 1.6

## new features

1. Wrote a translation layer to translate more human-readable aliases
   of every WorldCat SRU search index to their formal name. The
   `worldcat_api_search` function now uses this by default. You can still use
   the formal names, and even mix codes in the same query. The function
   documentation has been updated to reflect these new aliases.

2. A vignette on how to use the WorldCat search API is now available
   with a ton of very useful information.

3. Added `dt_na_breakdown` function.

## bug fixes
1. `print.progress` conditional now works for Location and Search API functions

2. Fixed a bug where if the number of search results was an exact multiple
   of 100, the search api function wouldn't return anything

## improvements

1. WorldCat API functions will now error if no WSKEY is provided
   (either with `options("libbib.wskey"=...)` or explicitly
   in the formal parameters

2. WorldCat Search function now tolerant of newlines and multiple
   spaces. Now long queries can be look neat

3. More of the diagnostic output now uses `message` instead of `print` or `cat`

4. If no Search API results are returned, the function prints the any
   diagnostic message returned from the Search API
   (things like Query syntax operators and unsupported indexes)

5. `get_clean_names` and `dt_set_clean_names` will now never produce
   duplicate column names

6. `dt_keep_cols` will warn user if a supplied column name doesn't
   exist in the supplied data.table

7. `dt_add_to_col_names` will, by default, error if any of the new
   names create any duplicate column names (not setting the new
   names). If `TRUE`, all the column names are made unique,
   potentially renaming excluded column names that were not supposed
   to be changed.

8. Added option in `dt_counts_and_percents` (and `dt_na_breakdown`)
   to specify a `big.mark` which will be used to separate every
   three digits of the count. If `FALSE` (the default) the count
   will remain and integer.

## small breaking changes

1. `marc_008_get_info` no longer returns the original publication
   date by default

2. excluding "questionable dates" in `marc_008_get_info` just NAs
   character position 6="q", now

3. The `print.api.responses` parameter in the Classify API functions has
   been changed to `debug` to be more consistent with the other API functions.

4. `num_total` column in search results has been renamed the (more descriptive)
   `total_wc_results`

5. By default, `get_clean_names` and `dt_set_clean_names` will convert
   all upper case characters to lower case. This can be overidden with
   by setting the `lower` parameter (in both) to `FALSE`.

-----

# libbib 1.5 (on CRAN 2021-04-24)

## new features

1. Implemented Dewey Decimal Code to subject translation

2. Added various helpful utility functions

3. Added split_map_filter_reduce and related utilities

4. Added functions to get language and country names from
   corresponding Marc codes

5. Added function to get links to OCLC's classify service

6. Added ability to link directly  to MARCXML, MODS, MADS, or
   Dublin Core metadata formats in `loc_permalink_from_lccn`

7. Added functions to use the WorldCat Bib Read API,
   read/parse the returned MARCXml, and return a `data.table`
   containing the most pertinent information.

8. Added functions to use the WorldCat Classify API and return a
   `data.table` containing the most popular Dewey and LC call numbers.

9. Added functions to use the WorldCat Location API and return a
   `data.table` containing (optionally, all) of the holding libraries
   for that standard number.

10. Added functions to extract info from MARC leaders and 008 fields

11. Added functions to use the WorldCat SRU search API and return a
    `data.table` containing (optionally, all) of the results.

## bug fixes

1. Expanded lc call <-> subject crosswalk (mainly for 'Law')

2. Fixed bugs in lc call <-> subject translation mechanism

## improvements

1. performance of `is_valid_lc_call` improved

