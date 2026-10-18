#' Extract Node List from a ranger Forest
#'
#' Extracts node-level attributes from the trees of a \code{ranger} random
#' forest via \code{ranger::treeInfo()}.  The columns match
#' \code{\link{nodelist.randomForest}}.  Node IDs match the
#' \code{from}/\code{to} values produced by \code{\link{edgelist.ranger}}.
#'
#' @inheritParams edgelist.ranger
#'
#' @returns A data.frame with one row per node (across all trees) and the
#'   following columns:
#'   \describe{
#'     \item{name}{Node ID within the tree (ranger's 0-based
#'       \code{nodeID}; matches edgelist from/to)}
#'     \item{is_leaf}{Logical: \code{TRUE} for terminal nodes}
#'     \item{split_var}{Index of the split variable in
#'       \code{input_object$forest$independent.variable.names}
#'       (\code{NA} for leaves)}
#'     \item{split_var_name}{Name of the split variable (\code{NA} for
#'       leaves)}
#'     \item{split_point}{Split threshold (\code{NA} for leaves and for
#'       unordered factor partition splits)}
#'     \item{prediction}{Leaf prediction: the class label for
#'       classification, the most probable class for probability forests,
#'       the numeric value for regression (\code{NA} for internal nodes
#'       and for survival forests)}
#'     \item{treenum}{Integer identifying which tree the node belongs to}
#'     \item{label}{Display label: \code{"<var>\\n<= <threshold>"} for
#'       numeric splits, the variable name for partition splits, the
#'       prediction for leaves}
#'     \item{prob_*}{(probability forests only) Class probability at each
#'       leaf, one column per class}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("ranger", quietly = TRUE)) {
#'   set.seed(12)
#'   rg <- ranger::ranger(Species ~ ., data = iris, num.trees = 3,
#'                        max.depth = 3)
#'   head(nodelist(rg))
#'
#'   # Extract a single tree
#'   nodelist(rg, treenum = 1)
#' }
nodelist.ranger <- function(input_object, treenum = NULL, ...) {
  tree_indices <- .validate_treenum(treenum, input_object$num.trees)

  convert_tree <- function(tn) {
    nodes <- .ranger_tree(input_object, tn)
    internal_label <- ifelse(
      is.na(nodes$split_levels),
      paste0(nodes$split_var_name, "\n<= ", round(nodes$split_point, 2)),
      nodes$split_var_name
    )
    out <- data.frame(
      name           = nodes$id,
      is_leaf        = nodes$is_leaf,
      split_var      = nodes$split_var,
      split_var_name = nodes$split_var_name,
      split_point    = nodes$split_point,
      prediction     = nodes$prediction,
      treenum        = tn,
      label          = ifelse(nodes$is_leaf, as.character(nodes$prediction),
                              internal_label),
      stringsAsFactors = FALSE
    )
    prob_cols <- grep("^prob_", names(nodes), value = TRUE)
    if (length(prob_cols) > 0L) out <- cbind(out, nodes[, prob_cols, drop = FALSE])
    out
  }

  result <- do.call(rbind, lapply(tree_indices, convert_tree))
  rownames(result) <- NULL
  result
}
