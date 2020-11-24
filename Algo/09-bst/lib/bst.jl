const TN{T} = Union{TNode{T}, Nothing} where T
const NTUP{T} = NamedTuple{(:key, :data),Tuple{T,Any}} where T

mutable struct BST{T}
  root::TN{T}
  size::Integer
  # ...

  function BST{T}(input) where T
    ##
    ## can be Array of Tuples [(key1, data1), (key2, data2), ... ]
    ## or just a tuple (key1, data1)
    ## just a key of type T
    ##
    (root, size) = if isa(input, Array)
      data = length(input[1]) < 2 ? nothing : input[1][2]
      root = TNode{T}(input[1][1]; data=data)
      size = 1
      for t in input[2:end]
        data = length(t) < 2 ? nothing : t[2]
        insert_node(root, TNode{T}(t[1]; data=data))
        size += 1
      end
      (root, size)

    elseif isa(input, Tuple)
      data = length(input) < 2 ? nothing : input[2]
      (TNode{T}(input[1]; data=data), 1)

    elseif isa(input, T)
      (TNode{T}(input), 1)

    else
      throw(ArgumentError(""))

    end
    bst = new(root, size)
  end

  BST{T}() where T = new(nothing, 0)
end

BST() = BST{Any}()

size(bst::BST{T}) where T = bst.size
length(bst::BST{T}) where T = bst.size     ## Synonym
left(bst::BST{T}) where T = bst.root.left
right(bst::BST{T}) where T = bst.root.right
key(bst::BST{T}) where T = bst.root.key

"""
  search(bst, key)
    returns a tuple if key can be found in the tree,
    nothing otherwise
"""
function search(bst::BST{T}, key::T)::TN{T} where T
  cnode = bst.root
  while cnode != nothing
    if key == cnode.key
      return cnode

    elseif key < cnode.key
      cnode = cnode.left

    else
      cnode = cnode.right

    end
  end
  nothing
end

#
# min(bst)
#  returns tuple(min key, data) (left-ist node) from the bst if defined,
#  nothing otherwise
#
# max(bst)
#  returns tuple(max key, data) (rigth-est node) from the bst if defined,
#  nothing otherwise
#
for (fn, link) in [(:min, :left), (:max, :right)]
  @eval begin

    function $(fn)(cnode::TN{T}) where T      ## ::TN{T} where T
      defined(cnode) || return nothing

      while defined(cnode.$(link))
        cnode = cnode.$(link)
      end

      cnode
    end

  end
end

min(bst::BST{T}) where T = min(bst.root)
max(bst::BST{T}) where T = max(bst.root)

function pred(bst::BST{T}, key::T)::TN{T} where T
  root = search(bst, key)
  defined(root) || return nothing
  pred(root, key)
end

function pred(root::TN{T}, key::T)::TN{T} where T
  if defined(root.left) # root.left != nothing
    max(root.left)
  else
    ix = 10
    while true
      ix -= 1
      ix == 0 && return nothing

      # no parent?
      (is_nothing(root) || is_nothing(root.parent)) && return nothing

      # right child (of a parent) => pred is parent
      root.parent.right == root && return root.parent

      # otherwise left child - go up...
      root = root.parent
    end

    @assert root.key < key
    return root
  end
end

function insert!(bst::BST{T}, input=Tuple{T, Any}) where T
  data = length(input) < 2 ? nothing : input[2]
  insert_node(bst.root,
              TNode{T}(input[1]; data=data))
  bst.size += 1
  bst
end

function delete!(bst::BST{T}, key::T) where T
  croot = search(bst, key)
  defined(croot) || return # croot == nothing && return          ## 0 - key is not in the tree

  if isleaf(croot)                    ## 1 - no children case
    croot = delete_leaf!(bst, croot)
    croot == bst.root ? bst.root = nothing : croot = nothing

  elseif has_one_child(croot)         ## 2 - 1 child case
    delete_when_one_child!(bst, croot)

  else                                ## 3 - 2 children case
    delete_when_two_children!(bst, croot)
  end

  bst.size -= 1
end


"""
  select(...)
    Lookup for i-th key in the (extended) BST
"""
function select(bst::BST{T}, ith::Integer)::TN{T} where T
  is_nothing(bst.root) && return nothing
  (ith ≤ 0 || ith > bst.root.size) && return nothing

  function _select(root::TN{T}, ith::Integer)
    is_nothing(root) && return nothing
    sz = defined(root.left) ? root.left.size + 1 : 1

    ith == sz && return root
    if ith < sz
      _select(root.left, ith)
    else
      _select(root.right, ith - sz)
    end
  end

  _select(bst.root, ith)
end

function iterate(bst::BST, (order, ix)=(dfs(bst), 1))
  ix > bst.size && return nothing

  (order[ix], (order, ix+1))
end

# ######################################################################
# Internal
# ######################################################################
#

defined(node::TN{T}) where T = node != nothing
is_nothing(node::TN{T}) where T = node == nothing

function insert_node(root::TN{T}, node::TNode{T}) where T

  function _insert(parent::TN{T}, root::TN{T}; d=:left)
    if is_nothing(root)
      d == :left ? parent.left = node : parent.right = node
      node.parent = parent
      return
    end

    root.size += 1
    if node.key < root.key
      _insert(root, root.left)

    elseif node.key > root.key
      _insert(root, root.right; d=:right)

    else
      _insert(root, root.left)

    end
  end

  _insert(root, root)
end

##
## in-order or reverse-order traversal
##
function dfs(bst::BST{T}, reverse=false) where T
  bst.size ≤ 0 && return nothing

  ary = Vector{NTUP{T}}(undef, bst.size)
  ix, incr = reverse ? (bst.size, -1) : (1, 1)

  ## define 2 closure
  λ!(cnode) = (ary[ix] = (key=cnode.key, data=cnode.data); ix += incr)

  function _dfs(cnode::TN{T})
    is_nothing(cnode) && return
    isleaf(cnode) && (return λ!(cnode))

    _dfs(cnode.left)
    λ!(cnode)
    _dfs(cnode.right)
  end

  _dfs(bst.root)
  ary
end


##
## delete helpers
##

function delete_leaf!(bst::BST{T}, croot::TN{T}) where T
  if croot.parent != nothing
    if croot.parent.left == croot
      croot.parent.left = nothing
    else
      croot.parent.right = nothing
    end
  end
  croot.parent = nothing
  croot
end

function delete_when_one_child!(bst::BST{T}, croot::TN{T}) where T
  if croot.left != nothing
    ## croot has 1 left child
    croot.left.parent = croot.parent  ## set parent
    if defined(croot.parent)
      croot.parent.right == croot ? croot.parent.right = croot.left :
      croot.parent.left = croot.left
    else
      bst.root = croot.left  # new root !
    end
  else
    ## croot has 1 right child
    croot.right.parent = croot.parent  ## set parent
    if defined(croot.parent)
      croot.parent.right == croot ? croot.parent.right = croot.right :
      croot.parent.left = croot.right
    else
      bst.root = croot.right  # new root !
    end
  end
  # (bst, croot)
end

function delete_when_two_children!(bst::BST{T}, croot::TN{T}) where T
  rnode = pred(croot, croot.key) # max(croot.left)
  @assert has_one_child(rnode) || isleaf(rnode) # at most one child

  # update cnode
  croot.key, croot.data = rnode.key, rnode.data

  # update rnode which may have a left child, but NOT a right child
  @assert is_nothing(rnode.right)
  if rnode.parent != croot
    rnode.parent.right = rnode.left

    if defined(rnode.left)
      rnode.left.parent = rnode.parent
      rnode.left = nothing
    end
  else ## rnode.parent == croot
    @assert rnode.parent == croot

    if croot.left == rnode
      croot.left = rnode.left
    else
      ## croot.right == rnode
      croot.right = rnode.left
    end
    rnode.parent = nothing
  end
end
