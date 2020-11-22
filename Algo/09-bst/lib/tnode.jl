mutable struct TNode{T}
  key::T
  data::Any
  parent::Union{TNode, Nothing}
  left::Union{TNode, Nothing}
  right::Union{TNode, Nothing}

  function TNode{T}(key::T; data::Any=nothing, parent=nothing, left=nothing, right=nothing) where T
    self = new(key, data, parent, left, right)
    @assert typeof(self.key) == T
    self
  end
end

const TData{T} = Union{Tuple{T, Any}, Nothing}

isleaf(self::TNode{T}) where T = self.left == nothing && self.right == nothing

has_one_child(self::TNode{T}) where T = (self.left == nothing && self.right != nothing) || (self.left != nothing && self.right == nothing)

parent(self::TNode{T}) where T = self.parent

left(self::TNode{T}) where T = self.left

right(self::TNode{T}) where T = self.right

key(self::TNode{T}) where T = self.key

function to_tuple(self::TNode{T})::TData{T} where T
  (self.key, self.data)
end

to_tuple(nothing)::TData{T} where T = nothing

function ==(self::TNode{T}, node::TNode{T})::Bool where T
  self.key == node.key && self.data == node.data &&
    self.left == node.left && self.right == node.right
end

function Base.show(io::IO, self::TNode{T}) where T
  str = "<key: $(self.key), data: $(self.data)"
  str = self.parent != nothing ? string(str, ", parent: $(self.parent.key)") : string(str, ", parent: <>")  ## AVOID circular reference!
  str = self.left != nothing ? string(str, ", left: $(self.left)") : string(str, ", left: <>")
  str = self.right != nothing ? string(str, ", right: $(self.right)") : string(str, ", right: <>")
  print(io, str)
end
