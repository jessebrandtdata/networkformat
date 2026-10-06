# networkformat: Convert R Objects to Network Edgelists and Nodelists

Network analysis and plotting packages such as 'igraph', 'tidygraph',
and 'ggraph' expect the edges and nodes of a graph as flat tables.
Methods are provided to build those tables from data frames (column-pair
edges chosen with 'tidyselect' semantics), tree-based model objects
('randomForest', 'tree', 'rpart', 'xgboost', 'gbm'), lists (recursive
parent-child edges), and atomic vectors (sequential edges). Graphs can
also be constructed in one step via as.igraph() and as_tbl_graph()
methods for tree models.

## See also

Vignettes:

- [`vignette("networkformat")`](https://jessebrandtdata.github.io/networkformat/articles/networkformat.md)
  — package overview

- [`vignette("edgelist-nodelist")`](https://jessebrandtdata.github.io/networkformat/articles/edgelist-nodelist.md)
  — edgelist and nodelist usage

- [`vignette("visualization")`](https://jessebrandtdata.github.io/networkformat/articles/visualization.md)
  — ggraph visualization examples

## Author

**Maintainer**: Jesse Brandt <jesse.a.brandt@gmail.com>
([ORCID](https://orcid.org/0009-0005-7462-075X))

Authors:

- Jesse Brandt <jesse.a.brandt@gmail.com>
  ([ORCID](https://orcid.org/0009-0005-7462-075X))
