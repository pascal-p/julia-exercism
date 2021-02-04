mutable struct TNode{T}
  key::T
  data::Any
  size::Integer
  parent::Union{TNode, Nothing}
  left::Union{TNode, Nothing}
  right::Union{TNode, Nothing}

  function TNode{T}(key::T;
                    data::Any=nothing, parent=nothing, left=nothing, right=nothing) where T
    size = get_size(left, right)
    self = new(key, data, size, parent, left, right)
    @assert typeof(self.key) == T
    self
  end
end

const TNN = Union{TNode{T}, Nothing} where T
const TData{T} = Union{Tuple{T, Any}, Nothing}

isleaf(tnode::TNode{T}) where T = tnode.left == nothing && tnode.right == nothing

has_one_child(tnode::TNode{T}) where T = (tnode.left == nothing && tnode.right != nothing) || (tnode.left != nothing && tnode.right == nothing)

parent(tnode::TNode{T}) where T = tnode.parent

left(tnode::TNode{T}) where T = tnode.left

right(tnode::TNode{T}) where T = tnode.right

key(tnode::TNode{T}) where T = tnode.key

size(tnode::TNode{T}) where T = tnode.size

height(::TNN) where T = 0

function height(tnode::TNode{T})::Int where T
  size(tnode) == 1  && return 1

  hl = left(tnode) == nothing ? 0 : left(tnode) |> height
  rl = right(tnode) == nothing ? 0 : right(tnode) |> height
  1 + max(hl, rl)
end

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

##
## Helper
##

function get_size(left::TNN{T}, right::TNN{T})::Int where T
  if left == right == nothing
    1
  elseif left == nothing
    1 + size(right)
  elseif right == nothing
    1 + size(left)
  else
    1 + size(left) + size(right)
  end
end
