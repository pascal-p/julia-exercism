"""
Bellman-Ford Data Structure for Single-Source Shortest Path (src: Algo Stanford)

Dependency on EWDiGraph
"""

const NULL_VERTEX = -1

struct BFSP{T, T1}
  dist_to::Vector{T1}
  path_to::Vector{T}
  g::EWDiGraph{T, T1}
  src::T

  function BFSP{T, T1}(g::EWDiGraph{T, T1}, s::T) where {T, T1}
    dist_to, path_to = shortest_path(g, s)
    new(dist_to, path_to, g, s)
  end

  function BFSP{T, T1}(infile::String, s::T; positive_weight=true) where {T, T1}
    g = EWDiGraph{T, T1}(infile; positive_weight)
    BFSP{T, T1}(g, s)
  end
end


function has_negative_cycle(bfsp::BFSP{T, T1}) where {T, T1}
  return length(bfsp.dist_to) == 0 && length(bfsp.path_to) == 0
end

## Shortest path form src --> dst
function has_path_to(bfsp::BFSP{T, T1}, dst::T) where {T, T1}
  @assert 1 ≤ dst ≤ v(bfsp.g)
  has_negative_cycle(bfsp) && (return false)

  bfsp.dist_to[dst] < infinity(T1)
end

function dist_to(bfsp::BFSP{T, T1}, dst::T) where {T, T1 <: Real}
  """
  Returns distance to vertex source (as calculated by shortest_path)
  """
  @assert 1 ≤ dst ≤ v(bfsp.g)
  has_negative_cycle(bfsp) && throw(ArgumentError("Negative cycle detected"))

  bfsp.dist_to[dst]
end

function path_to(bfsp::BFSP{T, T1}, dst::T) where {T, T1 <: Real}
  @assert 1 ≤ dst ≤ v(bfsp.g)
  has_negative_cycle(bfsp) && throw(ArgumentError("Negative cycle detected"))
  !has_path_to(bfsp, dst) && (return nothing)

  x, path = dst, Vector{T}()
  n = v(bfsp.g)
  while x ≠ NULL_VERTEX
    pushfirst!(path, x)
    x = bfsp.path_to[x]
    n -= 1
    n == 0 && break
  end

  x ≠ NULL_VERTEX && throw(ArgumentError("Problem with path: $(bfsp.src) --> $(dst) - FOUND path: $(path) / dump: $(bfsp.path_to)"))
  path
end

function min_dist(bfsp::BFSP{T, T1}) where {T, T1 <: Real}
  min_dist = infinity(T1)
  has_negative_cycle(bfsp) && throw(ArgumentError("Negative cycle detected"))

  for ix in 2:v(bfsp.g)
    bfsp.dist_to[ix] ≡ infinity(T1) && continue
    bfsp.dist_to[ix] < min_dist && (min_dist = bfsp.dist_to[ix])
  end

  min_dist
end


##
## Internal Helpers
##

infinity(::Type{Int}) = typemax(Int)
infinity(::Type{Float32}) = typemax(Float32)
infinity(::Type{Float64}) = typemax(Float64)

function incoming_edge(g::EWDiGraph{T, T1}) where {T, T1 <: Real}
  in_edges = Dict{Int, Vector{Tuple{T, T1}}}()

  for vₒ ∈ 1:v(g)
    for (u, w) ∈ adj(g, vₒ)
      l_u = get(in_edges, u, [])
      push!(l_u, (vₒ, w))          ## vertex origin, weight
      in_edges[u] = l_u
    end
  end

  in_edges
end

function shortest_path(g::EWDiGraph{T, T1}, s::T) where {T, T1 <: Real}
  @assert s ∈ 1:v(g) "Expecting vertex source to be in the graph"
  in_edges = incoming_edge(g)
  n = v(g)

  ## base case (ix = 1)
  a::Matrix{T1} = fill(infinity(T1), n + 1, n)
  path_to::Vector{T} = fill(NULL_VERTEX, n)
  a[1, s] = zero(T1)
  path_to[s] = NULL_VERTEX # s

  ## systematically solve all sub-problems
  for ix in 2:n+1
    stable = true
    for vₒ ∈ 1:v(g)
      # vₒ == s && continue
      min_uw, min_u = infinity(T1), NULL_VERTEX

      for (u, l_wv) ∈ get(in_edges, vₒ, Vector{Tuple{T, T1}}())
        ## edge "relaxation"
        if a[ix - 1, u] ≠ infinity(T1) && a[ix - 1, u] + l_wv < min_uw
          min_uw = a[ix - 1, u] + l_wv
          min_u = u
        end
      end

      if a[ix - 1, vₒ] < min_uw
        a[ix, vₒ] = a[ix - 1, vₒ]
      else
        a[ix, vₒ] = min_uw
        path_to[vₒ] = min_u
      end

      a[ix, vₒ] ≠ a[ix - 1, vₒ] && (stable = false)
    end

    stable && (return (a[ix, 1:end], path_to))  # ∀ v ∈ V
  end

  return ([], [])
end
