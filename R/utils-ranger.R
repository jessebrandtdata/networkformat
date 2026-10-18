# Returns one tree of a ranger forest as a data.frame with one row per node:
# id, left, right, split_var, split_var_name, split_point, split_levels,
# is_leaf, prediction, and prob_<class> columns for probability forests.
.ranger_tree <- function(x, tn) {
  if (!requireNamespace("ranger", quietly = TRUE)) {
    stop("Package 'ranger' is required. Install it with install.packages('ranger').")
  }
  if (is.null(x$forest)) {
    stop("This ranger object has no saved forest. ",
         "Refit it with write.forest = TRUE.")
  }

  ti <- ranger::treeInfo(x, tree = tn)
  var_names <- x$forest$independent.variable.names
  is_leaf <- ti$terminal

  split_var <- as.numeric(match(ti$splitvarName, var_names))
  # Unordered factors in "partition" mode list the level positions sent right
  is_partition <- !is_leaf & !x$forest$is.ordered[pmax(split_var, 1)]
  is_partition[is.na(is_partition)] <- FALSE
  split_raw <- as.character(ti$splitval)
  split_point <- suppressWarnings(as.numeric(split_raw))
  split_point[is_partition] <- NA_real_
  split_levels <- ifelse(is_partition, split_raw, NA_character_)

  prob_cols <- grep("^pred\\.", names(ti), value = TRUE)
  prob <- NULL
  if ("prediction" %in% names(ti)) {
    prediction <- ti$prediction
    if (is.factor(prediction)) prediction <- as.character(prediction)
  } else if (length(prob_cols) > 0L) {
    prob <- as.matrix(ti[, prob_cols, drop = FALSE])
    classes <- sub("^pred\\.", "", prob_cols)
    prediction <- rep(NA_character_, nrow(ti))
    prediction[is_leaf] <- classes[max.col(prob[is_leaf, , drop = FALSE],
                                           ties.method = "first")]
    colnames(prob) <- paste0("prob_", classes)
  } else {
    prediction <- rep(NA_real_, nrow(ti))
  }

  out <- data.frame(
    id             = ti$nodeID,
    left           = ti$leftChild,
    right          = ti$rightChild,
    split_var      = split_var,
    split_var_name = ti$splitvarName,
    split_point    = split_point,
    split_levels   = split_levels,
    is_leaf        = is_leaf,
    prediction     = prediction,
    stringsAsFactors = FALSE
  )
  if (!is.null(prob)) out <- cbind(out, as.data.frame(prob))
  out
}

# Builds one igraph from a forest's trees, naming vertices "treenum.node"
# when more than one tree is requested.
.forest_igraph <- function(x, tree_indices) {
  edges <- edgelist(x, treenum = tree_indices)
  nodes <- nodelist(x, treenum = tree_indices)
  if (length(tree_indices) > 1L) {
    edges$from <- paste0(edges$treenum, ".", edges$from)
    edges$to   <- paste0(edges$treenum, ".", edges$to)
    nodes$name <- paste0(nodes$treenum, ".", nodes$name)
  }
  igraph::graph_from_data_frame(edges, directed = TRUE, vertices = nodes)
}
