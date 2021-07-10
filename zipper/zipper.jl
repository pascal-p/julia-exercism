"""
Creating a zipper for a binary tree.

Zippers are a purely functional way of navigating within a data structure and manipulating it.
They essentially contain a data structure and a pointer into that data structure (called the focus).
"""

import Base: show
import Base: ==

## ====================================================================

mutable struct TreeNode{T <: Any}
  data::T
  parent::Union{TreeNode, Nothing}
  left::Union{TreeNode, Nothing}
  right::Union{TreeNode, Nothing}

  function TreeNode{T}(data::T; parent=nothing, left=nothing, right=nothing) where {T <: Any}
    new(data, parent, left, right)
  end
end

const TN = Union{TreeNode, Nothing}

TreeNode(value::T) where {T <: Any} = TreeNode{T}(value)
TreeNode(value::T;
         left::TN=nothing, right::TN=nothing) where {T <: Any} = TreeNode{T}(value; parent=nothing, left, right)

TreeNode(d::Dict) = _buildtree(d)

set_value(tn::TreeNode{T}, value::T) where {T <: Any} = (tn.data = value; tn)

function Base.show(io::IO, tn::TreeNode{T}) where {T <: Any}
  if parent == nothing
    print(io, (data=tn.data, left=tn.left, right=tn.right))
  else
    print(io, "TreeNode(data=$(tn.data), parent=$(tn.parent), left=$(tn.left), right=$(tn.right))")
  end
end

==(tn₁::TreeNode, tn₂::TreeNode) = tn₁.data == tn₂.data && tn₁.left == tn₂.left && tn₁.right == tn₂.right

## ====================================================================

mutable struct Zipper
  tree::TN
  root::TN # for reset!
end

## Public API
function from_tree(tn)::Zipper
  t = _buildtree(tn)
  Zipper(t, t)
end

to_tree(zipper::Zipper) = zipper.root

to_dict(zipper::Zipper) = _to_dict(zipper.root)

value(zipper::Zipper) = zipper.tree !== nothing ? zipper.tree.data : nothing

function left!(zipper::Zipper)
  zipper.tree = zipper.tree.left
  zipper.tree === nothing ? nothing : zipper
end

function right!(zipper::Zipper)
  zipper.tree = zipper.tree.right
  zipper.tree === nothing ? nothing : zipper
end

function set_value(zipper::Zipper, value::T) where {T <: Any}
  @assert zipper !== nothing && zipper.tree != nothing && typeof(value) == typeof(zipper.tree.data)
  zipper.tree.data = value
  zipper
end

function set_left!(zipper::Zipper, tn::TN)
  # set left node of the focus node
  zipper.tree.left = tn !== nothing ? _buildtree(tn) : tn
  zipper
end

# function set_left!(zipper::Zipper, value::T) where {T <: Any}
#   # set left node of the focus node
#   @assert zipper !== nothing && zipper.tree != nothing && typeof(value) == typeof(zipper.tree.data)
#   println("Good to go...")
#   if zipper.tree.left === nothing
#     zipper.tree.left = TreeNode(value; parent=zipper.tree)
#   else
#     zipper.tree.left.data = value
#   end
#   zipper
# end

function set_right!(zipper::Zipper, tn::TN)
  # set right node of the focus node
  zipper.tree.right = tn !== nothing ? _buildtree(tn) : tn
  zipper
end

function up!(zipper::Zipper)
  zipper.tree = zipper.tree.parent
  zipper.tree === nothing ? nothing : zipper
end

reset!(zipper::Zipper) = (zipper.tree = zipper.root; zipper)


## Internal

function _buildtree(tn::Dict)
  while tn !== nothing
    v = tn[:value]
    ln = _buildtree(tn[:left])
    rn = _buildtree(tn[:right])

    cnode = TreeNode(v; left=ln, right=rn)

    cnode.left !== nothing && (cnode.left.parent = cnode)
    cnode.right !== nothing && (cnode.right.parent = cnode)

    return cnode
  end
end

_buildtree(tn::TreeNode) = tn

_buildtree(::Nothing) = nothing

_buildtree(Any) = throw(ArgumentError("Cannot deal with this type"))

function _to_dict(tn::TN)::Union{Dict, Nothing}
  while tn !== nothing
    v = tn.data
    ln = _to_dict(tn.left)
    rn = _to_dict(tn.right)
    return Dict(:value => v, :left => ln, :right => rn)
  end
end
