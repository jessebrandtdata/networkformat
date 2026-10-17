# The as.igraph() and as_tbl_graph() methods are registered against igraph's
# and tidygraph's generics by delayed S3 registration (NAMESPACE:
# S3method(igraph::as.igraph, tree) and friends). Before 2026-03-04 the package
# shipped its own generics instead, and whichever package was attached last
# masked the other's, so dispatch depended on library() order. Each case here
# runs in a fresh R session so the attach order is really what is tested.

skip_if_not_installed("callr")
skip_if_not_installed("igraph")
skip_if_not_installed("tidygraph")
skip_if_not_installed("tree")

classes_after_attaching <- function(pkgs) {
  callr::r(
    function(pkgs) {
      for (p in pkgs) suppressPackageStartupMessages(library(p, character.only = TRUE))
      tr <- tree::tree(Species ~ ., data = iris)
      c(igraph = class(as.igraph(tr))[1], tbl_graph = class(as_tbl_graph(tr))[1])
    },
    args = list(pkgs = pkgs),
    libpath = .libPaths()
  )
}

test_that("model methods dispatch whatever order the packages are attached in", {
  orders <- list(
    c("networkformat", "igraph", "tidygraph"),
    c("igraph", "networkformat", "tidygraph"),
    c("tidygraph", "igraph", "networkformat"),
    c("networkformat", "tidygraph", "igraph"),
    c("igraph", "tidygraph", "networkformat")
  )
  for (ord in orders) {
    got <- classes_after_attaching(ord)
    expect_equal(got[["igraph"]], "igraph", info = paste(ord, collapse = " > "))
    expect_equal(got[["tbl_graph"]], "tbl_graph", info = paste(ord, collapse = " > "))
  }
})

test_that("a qualified igraph::as.igraph() call works with only networkformat attached", {
  got <- callr::r(
    function() {
      suppressPackageStartupMessages(library(networkformat))
      tr <- tree::tree(Species ~ ., data = iris)
      class(igraph::as.igraph(tr))[1]
    },
    libpath = .libPaths()
  )
  expect_equal(got, "igraph")
})
