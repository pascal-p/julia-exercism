struct Node{T}
  v::T
  l::Union{Nothing, Node{T}}
  r::Union{Nothing, Node{T}}

  function Node{T}(v; l=nothing, r=nothing) where T
    new(v, l, r)
  end
end

function tree_from_traversals(pre_o::Vector{T}, in_o::Vector{T}) where T
  has_duplicate(pre_o) && has_duplicate(in_o) && throw(ArgumentError("repeated values detected"))

  from_tree_trav_fn(pre_o, in_o)
end

function from_tree_trav_fn(pre_o::Vector{T}, in_o::Vector{T}) where T
  # println("==> pre_order: $(pre_o) / in_order: $(in_o)")

  n_pre, n_ino = length(pre_o), length(in_o)
  n_pre == n_ino || throw(ArgumentError("preorder and inorder should have the same length"))
  n_pre == 0 && return nothing

  root = pre_o[1]
  rix = findfirst(x -> x == root, in_o)
  rix == nothing && throw(ArgumentError("Could not find the root in the in-order array"))

  lst = from_tree_trav_fn(pre_o[2:rix], in_o[1:rix - 1])
  rst = from_tree_trav_fn(pre_o[rix+1:n_pre], in_o[rix+1:n_ino])
  return Node{T}(root; l=lst, r=rst)
end

function has_duplicate(v::Vector{T}) where T
  length(unique(v)) < length(v)
end
