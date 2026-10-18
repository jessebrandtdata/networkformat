#' Extract Edgelist from a ranger Forest
#'
#' Converts a \code{ranger} random forest into a network edgelist by
#' extracting parent-child relationships from one or more trees via
#' \code{ranger::treeInfo()}.  The columns match
#' \code{\link{edgelist.randomForest}}, plus a \code{label} column with the
#' split rule, so code written for one engine works with the other.
#'
#' Node IDs are ranger's own 0-based \code{nodeID} values (the root is
#' \code{0}), the same IDs \code{predict(type = "terminalNodes")} returns.
#'
#' Unordered factor splits grown with
#' \code{respect.unordered.factors = "partition"} have no numeric threshold:
#' \code{split_point} is \code{NA} and \code{label} carries ranger's
#' \code{splitval} string verbatim, a comma-separated list of the factor
#' level positions (in the original level order) sent to the right child.
#' The right edge reads \code{"<var> in <levels>"} and the left edge
#' \code{"<var> not in <levels>"}.
#'
#' @param input_object A \code{ranger} object fitted with
#'   \code{write.forest = TRUE} (the default)
#' @param treenum Integer vector of tree numbers to extract (default:
#'   \code{NULL} extracts all trees). Values must be between 1 and
#'   \code{input_object$num.trees}.
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with the following columns:
#'   \describe{
#'     \item{from}{Parent node ID within the tree (0-based)}
#'     \item{to}{Child node ID (left or right child)}
#'     \item{split_var}{Index of the split variable in
#'       \code{input_object$forest$independent.variable.names}}
#'     \item{split_point}{Split threshold: values \code{<=} go left
#'       (\code{NA} for unordered factor partition splits)}
#'     \item{prediction}{Prediction at the child node (\code{NA} for
#'       internal children): the class label for classification, the most
#'       probable class for probability forests, the numeric value for
#'       regression}
#'     \item{direction}{Branch direction: \code{"left"} or \code{"right"}}
#'     \item{treenum}{Tree number within the forest}
#'     \item{split_var_name}{Name of the split variable}
#'     \item{label}{Split rule for the edge, e.g.
#'       \code{"Petal.Width <= 0.8"}}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("ranger", quietly = TRUE)) {
#'   set.seed(12)
#'   rg <- ranger::ranger(Species ~ ., data = iris, num.trees = 5,
#'                        max.depth = 3)
#'
#'   # Extract all trees
#'   head(edgelist(rg))
#'
#'   # Extract specific trees
#'   edgelist(rg, treenum = c(1, 3))
#' }
edgelist.ranger <- function(input_object, treenum = NULL, ...) {
  tree_indices <- .validate_treenum(treenum, input_object$num.trees)

  convert_tree <- function(tn) {
    nodes <- .ranger_tree(input_object, tn)
    parents <- nodes[!nodes$is_leaf, , drop = FALSE]
    n_internal <- nrow(parents)
    child <- c(parents$left, parents$right)
    direction <- rep(c("left", "right"), each = n_internal)

    var <- rep(parents$split_var_name, 2L)
    point <- rep(parents$split_point, 2L)
    levels_right <- rep(parents$split_levels, 2L)
    label <- ifelse(direction == "left",
                    paste(var, "<=", point),
                    paste(var, ">", point))
    is_partition <- !is.na(levels_right)
    label[is_partition] <- ifelse(direction[is_partition] == "right",
                                  paste(var[is_partition], "in",
                                        levels_right[is_partition]),
                                  paste(var[is_partition], "not in",
                                        levels_right[is_partition]))

    data.frame(
      from           = rep(parents$id, 2L),
      to             = child,
      split_var      = rep(parents$split_var, 2L),
      split_point    = point,
      prediction     = nodes$prediction[match(child, nodes$id)],
      direction      = direction,
      treenum        = tn,
      split_var_name = var,
      label          = label,
      stringsAsFactors = FALSE
    )
  }

  forest_df <- do.call(rbind, lapply(tree_indices, convert_tree))
  rownames(forest_df) <- NULL
  forest_df
}
