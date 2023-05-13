"""
  Extended EWDiGraph for Johnson Algo
"""

# abstract type AEWDiGraph{T <: Integer, T1 <: Real}; end

struct EEWDiGraph{T, T1} <: AEWDiGraph{T, T1}
  _v::Integer                         # num. of vertices 1..v
  _e::Integer                         # num. of edges
  _adj::Array{AbstractArray{T,1} where T,1}
  _g::EWDiGraph{T, T1}                # origin DiGraph

  function EEWDiGraph{T, T1}(g::EWDiGraph{T, T1}) where {T <: Integer, T1 <: Real}
    nv, w = v(g) + one(T), zero(T)
    ne = e(g)
    adj_g = view(adj(g), :)         # Using a view, instead of a copy
    adj_nv = Vector{Tuple{T, T1}}()

    for vₒ ∈ 1:v(g)
      push!(adj_nv, (vₒ, w))
      ne += 1
    end
    adj_ng = [adj_g, adj_nv]
    new(nv, ne, adj_ng, g)
  end
end

v(g::EEWDiGraph) = g._v
e(g::EEWDiGraph) = g._e

function adj(g::EEWDiGraph{T, T1}, u::T) where {T <: Integer, T1 <: Real}
  if 1 ≤ u ≤ v(g)
    u == v(g) && (return g._adj[2])   ## last vertex is the "extended" vertex
    return g._adj[1][u]
  end

  Vector{Tuple{T, T1}}()
end

function has_edge(g::EEWDiGraph{T, T1}, u::T, v::T) where {T <: Integer, T1 <: Real}
  check_valid_vertices(g, u, v)

  ## if there is an edge u -> v, then adj(g, u) must contain v
  v ∈ map(t -> t[1], adj(g, u)) ## adj(g, u) ≡ list of tuple (vertex, weight)
end

function has_weighted_edge(g::EEWDiGraph, u::T, v::T) where {T <: Integer}
  check_valid_vertices(g, u, v)

  find_weighted_edge(g, u, v)
end

function weight(g::EEWDiGraph{T, T1}, u::T, v::T) where {T <: Integer, T1 <: Real}
  check_valid_vertices(g, u, v)

  u == v && (return zero(T1))
  res, w = find_weighted_edge(g, u, v)
  res ? w : typemax(T1)
end

function build_graph!(g::EEWDiGraph{T, T1}, ::Vector{Tuple{T, T, T1}}) where {T <: Integer, T1 <: Real}
  ## identity function as an EEWDiGraph is an extension of EWDiGraph
  g
end

##
## Internal Helpers
##

function check_valid_vertices(g::EEWDiGraph{T, T1}, v₁::T, v₂::T) where {T <: Integer, T1 <: Real}
  n = v(g)
  for u ∈ (v₁, v₂)
    1 ≤ u ≤ n || throw(ArgumentError("vertex $(u) not in current digraph"))
  end
end

function find_weighted_edge(g::EEWDiGraph{T, T1}, u::T, v::T) where {T <: Integer, T1 <: Real}
  ## if there is an edge u -> v, then adj(g, u) must contain v
  for (ix, (vₒ, w)) ∈ enumerate(adj(g, u))
    vₒ == v && return (true, w, ix)
  end

  (false, nothing, nothing)
end
