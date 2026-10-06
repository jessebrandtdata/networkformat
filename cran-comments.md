# cran-comments

## Resubmission

This is a resubmission of a new package. The 0.1.1 submission was returned with
two requests, both about the `DESCRIPTION` file:

* "Please do not start the description with package name, title or similar."
  --- the Description field no longer opens by restating the title. It now opens
  by naming the problem (network packages expect edges and nodes as flat tables)
  before describing what the package does.
* "Please always write package names, software names and API names in single
  quotes in title and description." --- 'tidyselect' was the one software name
  left unquoted; it is now in single quotes like the others. The Title contains
  no software or package names.

No code, documentation or behaviour changed; the diff is the Description field,
the version number, and a NEWS entry.

## Test environments

All three were run against 0.1.2:

* local: Ubuntu 24.04.4 LTS (Linux 6.8), R 4.3.3
* win-builder: Windows Server 2022, R 4.6.1 (2026-06-24 ucrt) (R-release)
* win-builder: Windows Server 2022, R Under development (unstable)
  (2026-10-05 r90641 ucrt)

## R CMD check results

0 errors | 0 warnings | 1 note

Both win-builder runs returned the same single NOTE, from "checking CRAN
incoming feasibility":

* "New submission" --- expected.
* Possibly misspelled words in DESCRIPTION: "Edgelists" (3:37) and
  "Nodelists" (3:51). Both are in the Title and both are correct: they are the
  standard network-analysis terms for the two data structures this package
  produces.

On 0.1.1 that word list also included "edgelist", "nodelist" and "tidyselect";
all three are gone now that the Description has been reworded and 'tidyselect'
is quoted.

The local check additionally reports two items that are artifacts of the check
environment rather than of the package:

* WARNING: 'qpdf' is needed for checks on size reduction of PDFs --- qpdf is
  not installed on the local machine.
* NOTE: unable to verify current time --- the local machine has no access to
  the network time service the check consults.

Both win-builder runs built the PDF and HTML manuals successfully.

All suggested packages (including 'xgboost' and 'gbm') are installed locally,
so the model-specific methods and their tests are exercised rather than
skipped.

## Downstream dependencies

There are no downstream dependencies; this is a first submission.
