mutable struct TNode{T}
  key::T
  data::Any
  size::Integer
  parent::Union{TNode, Nothing}
  left::Union{TNode, Nothing}
  right::Union{TNode, Nothing}

  function TNode{T}(key::T; data::Any=nothing, parent=nothing, left=nothing, right=nothing) where T
    self = new(key, data, 1, parent, left, right)
    @assert typeof(self.key) == T
    self
  end
end

const TData{T} = Union{Tuple{T, Any}, Nothing}

isleaf(tnode::TNode{T}) where T = tnode.left == nothing && tnode.right == nothing

has_one_child(tnode::TNode{T}) where T = (tnode.left == nothing && tnode.right != nothing) || (tnode.left != nothing && tnode.right == nothing)

parent(tnode::TNode{T}) where T = tnode.parent

left(tnode::TNode{T}) where T = tnode.left

right(tnode::TNode{T}) where T = tnode.right

key(tnode::TNode{T}) where T = tnode.key

size(tnode::TNode{T}) where T = tnode.size

function to_tuple(tnode::TNode{T})::TData{T} where T
  (tnode.key, tnode.data)
end

to_tuple(nothing)::TData{T} where T = nothing

function ==(tnode::TNode{T}, onode::TNode{T})::Bool where T
  "Do not consider references to other nodes"
  tnode.key == onode.key && tnode.data == onode.data &&
    tnode.size == onode.size
end

function Base.show(io::IO, tnode::TNode{T}) where T
  str = "<key: $(tnode.key), data: $(tnode.data), size: $(tnode.size)"
  str = tnode.parent != nothing ? string(str, ", parent: $(tnode.parent.key)") : string(str, ", parent: <>")  ## AVOID circular reference!
  str = tnode.left != nothing ? string(str, ", left: $(tnode.left.key)") : string(str, ", left: <>")
  str = tnode.right != nothing ? string(str, ", right: $(tnode.right.key)") : string(str, ", right: <>")
  print(io, str)
end
