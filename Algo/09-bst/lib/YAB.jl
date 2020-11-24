module YAB
  # Yet Another Binary Search Tree ADT
  import Base: insert!, ==, min, max, delete!
  import Base: size, length, iterate

  export BST, TNode

  export isleaf, parent, left, right, key
  export ==, to_tuple, has_one_child
  export insert!, search, min, max, pred
  export delete!, size, length
  export select

  include("./tnode.jl")
  include("./bst.jl")
end
