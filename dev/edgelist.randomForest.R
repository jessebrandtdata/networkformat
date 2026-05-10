edgelist.randomForest <- function(input_object){
# notes (todo): source and target columns should probably be unique identifiers actually
  # tree1 <- getTree(input_object, i)# using this function is probably more future-proof than relying on object staying the same
  # tree1 |> head()
  # tree1[,"status"] |> unique()
  # unique(tree1)
  # why are these -3 status? docs claim it should be -1 or 1

  # efficiency doesn't matter yet, write it first then make it fast
  
  convert_tree <- function(treenum){
    tree1 <- getTree(input_object, treenum)
    tree1 <- as.data.frame(tree1)
    tree1$index <- c(1:nrow(tree1))
    
    parent_index <- tree1$`left daughter` != 0
    edgelist <- data.frame(source = c(tree1[parent_index,"index"], tree1[parent_index,"index"]),
                           target = c(tree1[parent_index,"left daughter"], tree1[parent_index,"right daughter"]),
                           split_var = c(tree1[parent_index,"split var"], tree1[parent_index,"split var"]),
                           split_point = c(tree1[parent_index,"split point"], tree1[parent_index,"split point"]),
                           prediction = c(tree1[parent_index,"prediction"], tree1[parent_index,"prediction"]),
                           treenum = treenum)
    # structure is here (for one tree). but u can add the variable names I guess
    # you can do some kind of default thing.
    # idk uhhhhh labels for prediction?????
    # also add regular labels. u can add options for returning whatever later but for now it's good to have everything in there
    return(edgelist)
  }
  # edgelist$split_var |> unique()
  # forest_edge <- data.frame()
  # # is most efficient way adding to a list? 
  # for(i in 1:input_object$ntree){
  #   forest_edge <- rbind(forest_edge, convert_tree(i))
  #   
  # }
  forest_edge <- lapply(c(1:input_object$ntree), \(i)(convert_tree(i)))
  # forest_edge$split_var_name 
  forest_df <- do.call(rbind, forest_edge)
  forest_df$split_var_name <- factor(forest_df$split_var, labels = names(input_object$forest$ncat))
  # do for all trees then attach varnames
  return(forest_df)
}
