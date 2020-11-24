const TN{T} = Union{TNode{T}, Nothing} where T
const NTUP{T} = NamedTuple{(:key, :data),Tuple{T,Any}} where T

mutable struct BST{T}
  root::TN{T}

  function BST{T}(input) where T
    ##
    ## can be Array of Tuples [(key1, data1), (key2, data2), ... ]
    ## or just a tuple (key1, data1)
    ## just a key of type T
    ##
    root = if isa(input, Array)
      data = length(input[1]) < 2 ? nothing : input[1][2]
      root = TNode{T}(input[1][1]; data=data)
      for t in input[2:end]
        data = length(t) < 2 ? nothing : t[2]
        insert_node(root, TNode{T}(t[1]; data=data))
      end
      root

    elseif isa(input, Tuple)
      data = length(input) < 2 ? nothing : input[2]
      TNode{T}(input[1]; data=data)

    elseif isa(input, T)
      TNode{T}(input)

    else
      throw(ArgumentError("Error..."))
    end
    bst = new(root)
  end

  BST{T}() where T = new(nothing)
end

BST() = BST{Any}()

size(bst::BST{T}) where T = defined(bst.root) ? bst.root.size : 0   ## now use root node
length(bst::BST{T}) where T = defined(bst.root) ? bst.root.size : 0 ## Synonym

left(bst::BST{T}) where T = defined(bst.root) ? bst.root.left : nothing
right(bst::BST{T}) where T = defined(bst.root) ? bst.root.right : nothing
key(bst::BST{T}) where T = defined(bst.root) ? bst.root.key : nothing

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

#
# generating pred and succ, given these are symmetric
#
for (fn, link1, mfn, link2) in [(:pred, :left, :max, :right), (:succ, :right, :min, :left)]
  @eval begin

    function $(fn)(bst::BST{T}, key::T)::TN{T} where T
      root = search(bst, key)
      is_nothing(root) && return nothing
      $(fn)(root, key)
    end

    function $(fn)(root::TN{T}, key::T)::TN{T} where T
      defined(root.$(link1)) && return $(mfn)(root.$(link1))

      while true
        ## no parent?
        (is_nothing(root) || is_nothing(root.parent)) && return nothing

        ## $(link2) child (of a parent) => $(fn) is parent
        root.parent.$(link2) == root && return root.parent

        ## otherwise go up...
        root = root.parent
      end

      @assert root.key < key
      return root
    end

  end
end

function insert!(bst::BST{T}, input=Tuple{T, Any}) where T
  data = length(input) < 2 ? nothing : input[2]
  nnode = TNode{T}(input[1]; data=data)

  if is_nothing(bst.root)
    bst.root = nnode
  else
    insert_node(bst.root, nnode)
  end

  bst
end

function delete!(bst::BST{T}, key::T) where T
  cnode = search(bst, key)            ## cnode is the replacement node for the node (given key) we need to delete

  defined(cnode) || return            ## 0 - key is not in the tree

  ## now update all the size from cnode upto the root of the tree
  node = cnode
  while node != bst.root
    node.size -= 1
    node = node.parent
  end
  bst.root.size -= 1

  if isleaf(cnode)                    ## 1 - no children case
    cnode = delete_leaf!(bst, cnode)
    cnode == bst.root ? bst.root = nothing : cnode = nothing

  elseif has_one_child(cnode)         ## 2 - 1 child case
    delete_when_one_child!(bst, cnode)

  else                                ## 3 - 2 children case
    delete_when_two_children!(bst, cnode)
  end
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
  (bst == nothing || is_nothing(bst.root)) && return nothing
  ix > bst.root.size && return nothing

  (order[ix], (order, ix+1))
end

# ######################################################################
# Internal
# ######################################################################
#

defined(node::TN{T}) where T = node != nothing

is_nothing(node::TN{T}) where T = node == nothing
# is_noting(bst::BST{T}) where T = bst == nothing
# is_nothing(nothing) where T = true


function insert_node(root::TN{T}, node::TNode{T}) where T

  function _insert(parent::TN{T}, cnode::TN{T}; d=:left)
    if is_nothing(cnode)
      d == :left ? parent.left = node : parent.right = node
      node.parent = parent
      return
    end

    cnode.size += 1
    if node.key < cnode.key
      _insert(cnode, cnode.left)

    elseif node.key > cnode.key
      _insert(cnode, cnode.right; d=:right)

    else
      _insert(cnode, cnode.left)

    end
  end

  _insert(root, root)
end

##
## in-order or reverse-order traversal
##
function dfs(bst::BST{T}, reverse=false) where T
  sz = defined(bst.root) ? size(bst) : 0
  sz ≤ 0 && return nothing

  ary = Vector{NTUP{T}}(undef, sz)
  ix, incr = reverse ? (sz, -1) : (1, 1)

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

function delete_leaf!(bst::BST{T}, cnode::TN{T}) where T
  if cnode.parent != nothing
    if cnode.parent.left == cnode
      cnode.parent.left = nothing
    else
      cnode.parent.right = nothing
    end
  end
  cnode.parent = nothing
  cnode
end

function delete_when_one_child!(bst::BST{T}, cnode::TN{T}) where T
  if cnode.left != nothing
    ## cnode has 1 left child
    cnode.left.parent = cnode.parent  ## set parent
    if defined(cnode.parent)
      cnode.parent.right == cnode ?
        cnode.parent.right = cnode.left :
        cnode.parent.left = cnode.left
    else
      bst.root = cnode.left           ## new root
    end
  else
    ## cnode has 1 right child
    cnode.right.parent = cnode.parent ## set parent
    if defined(cnode.parent)
      cnode.parent.right == cnode ?
        cnode.parent.right = cnode.right :
        cnode.parent.left = cnode.right
    else
      bst.root = cnode.right          ## new root
    end
  end
end

function delete_when_two_children!(bst::BST{T}, cnode::TN{T}) where T
  rnode = pred(cnode, cnode.key) # max(cnode.left)
  @assert has_one_child(rnode) || isleaf(rnode) # at most one child

  ## update cnode
  cnode.key, cnode.data = rnode.key, rnode.data

  ## update rnode which may have a left child, but NOT a right child
  @assert is_nothing(rnode.right)
  if rnode.parent != cnode
    rnode.parent.right = rnode.left

    if defined(rnode.left)
      rnode.left.parent = rnode.parent
      rnode.left = nothing
    end
  else ## rnode.parent == cnode
    @assert rnode.parent == cnode

    if cnode.left == rnode
      cnode.left = rnode.left
    else
      ## cnode.right == rnode
      cnode.right = rnode.left
    end
    rnode.parent = nothing
  end
end
