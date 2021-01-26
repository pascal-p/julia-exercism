"""
  mimimax with α-β pruning


  - node (or positon)
  - h(n) ≡ static evaluation of terminal node n
  - childen(node) ≡ all the children of given node (or reachable position from node's position)

"""

const TF = AbstractFloat

function minimax(node::T, depth::T1, max_player::Bool, DT::DataType) where {T, T1 <: Integer}

  function _minimax(node::T, depth::T1, max_player::Bool)
    if depth == 0 || is_terminal(node)
      @assert node.value != nothing "Expecting value of node to be defined, got $(node) / depth == $(depth)"
      return value(node)
    end

    if max_player # turn
      cval = typemin(DT)
      for cnode ∈ children(node)
        cval = max(cval,
                   _minimax(cnode, depth - 1, !max_player))
      end
      return cval

    else          # min_player's turn
      cval = typemax(DT)
      for cnode ∈ children(node)
        cval = min(cval,
                   _minimax(cnode, depth - 1, !max_player))
      end
      return cval
    end
  end

  _minimax(node, depth, max_player)
end

function minimax(node::T, depth::T1, max_player::Bool;
                 α::T2=typemin(T2), β::T2=typemax(T2)) where {T, T1 <: Integer, T2 <: AbstractFloat}

  function _minimax(node::T, depth::T1, max_player::Bool, α::T2, β::T2)
    (depth == 0 || is_terminal(node)) && (return value(node))

    if max_player # turn
      cval = typemin(T2)
      for cnode ∈ children(node)
        cval = max(cval,
                   _minimax(cnode, depth - 1, !max_player, α, β))
        α = max(α, cval)

        α ≥ β && break   ## β-cutoff
      end
      return cval
    end

    # min_player's turn
    cval = typemax(T2)
    for cnode ∈ children(node)
      cval = min(cval,
                 _minimax(cnode, depth - 1, !max_player, α, β))
      β = min(β, cval)
      β ≤ α && break   ## α-cutoff
    end
    return cval
  end

  _minimax(node, depth, max_player, α, β)
end



##
## Client portion
##


const NT{T} = Union{T, Nothing} where T

struct Node{T}
  value::NT{T}
  children::Vector{Node{T}}

  function Node{T}(value::NT{T}; children=Vector{Node{T}}[]) where T
    new(value, children)
  end

  function Node{T}(nodelst::AbstractVector) where T
    vnodes = node_builder(nodelst, T)
    return Node{T}(nothing; children=vnodes)
  end
end

children(n::Node{T}) where T = n.children
is_terminal(n::Node{T}) where T = isempty(n.children)
value(n::Node{T}) where T = n.value


function node_builder(nodelst::AbstractVector, DT::DataType)
  if eltype(nodelst) == NT{DT} || eltype(nodelst) == DT
    vnodes::Vector{Node{DT}} = [
      Node{DT}(ch; children=[]) for ch ∈ nodelst
    ]
    return vnodes
  end

  #
  vchildren = Vector{Node{DT}}()
  for ch ∈ nodelst
    push!(vchildren,
          Node{DT}(nothing; children=node_builder(ch, DT)))   ## rec. call
  end
  return vchildren
end
