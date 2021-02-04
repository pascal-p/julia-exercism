"""
Given a sorted (increasing order) array with unique integer elements, write an
algorithm to create a binary search tree with minimal height.
"""

push!(LOAD_PATH, "../Algo/09-bst/lib")  ## SHOULD BE src
using YAB

const VInt = Vector{Int}
const TN{T} = Union{TNode{T}, Nothing} where T


"""
  Proceed with dichotomic method...
"""
function create_bst(v::VInt)::BST{Int}
  length(v) == 0 && return BST{Int}()

  function _create_bst(l, h; node::TN{Int}=nothing)
    l > h && return nothing

    m = (l + h) ÷ 2
    rn = _create_bst(m+1, h; node)
    ln = _create_bst(l, m-1; node)

    return TNode{Int}(v[m]; left=ln, right=rn)
  end

  rnode = _create_bst(1, length(v))
  return BST{Int}(rnode)
end
