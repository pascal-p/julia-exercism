"""
Bellman-Ford Data Structure for Single-Source Shortest Path (src: Algo Stanford)

Dependency on AEWDiGraph
"""

const NULL_VERTEX = -1

struct BFSP{T, T1}
  dist_to::Vector{T1}
  path_to::Vector{T}
  g::AEWDiGraph{T, T1}
  src::T

  function BFSP{T, T1}(g::AEWDiGraph{T, T1}, s::T) where {T, T1}
    dist_to, path_to = shortest_path(g, s)
    new(dist_to, path_to, g, s)
  end

  function BFSP{T, T1}(infile::String, s::T, GType::DataType; positive_weight=true) where {T, T1}
    g = GType(infile; positive_weight)
    BFSP{T, T1}(g, s)
  end
end

##
## Public API
##

function has_negative_cycle(bfsp::BFSP{T, T1}) where {T, T1}
  return length(bfsp.dist_to) == 0 && length(bfsp.path_to) == 0
end

function has_path_to(bfsp::BFSP{T, T1}, dst::T) where {T, T1}  ## Shortest path form src --> dst
  check_valid_vertex(bfsp, dst)
  has_negative_cycle(bfsp) && (return false)

  bfsp.dist_to[dst] < infinity(T1)
end

"""
  Returns distance to vertex source (as calculated by shortest_path)
"""
function dist_to(bfsp::BFSP{T, T1}, dst::T) where {T, T1 <: Real}
  check_valid_vertex(bfsp, dst)
  check_negative_cycle(bfsp)

  bfsp.dist_to[dst]
end

function path_to(bfsp::BFSP{T, T1}, dst::T) where {T, T1 <: Real}
  check_valid_vertex(bfsp, dst)
  check_negative_cycle(bfsp)

  !has_path_to(bfsp, dst) && (return nothing)

  x, path = dst, Vector{T}()
  while x ≠ bfsp.src
    if x ∈ path
      println(" loop for x: $(x) / path so far: $(path)")
      break # continue  ## Loop ?
    end
    pushfirst!(path, x)
    x = bfsp.path_to[x]
  end

  x ≠ bfsp.src &&
    throw(ArgumentError("Problem with path: $(bfsp.src) -> $(dst) / FOUND path: $(path)\n\n$(bfsp.path_to)"))
  pushfirst!(path, x) ## origin/src

  path
end

function min_dist(bfsp::BFSP{T, T1}) where {T, T1 <: Real}
  check_negative_cycle(bfsp)
  min_dist = infinity(T1)

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
infinity(::Type{Int32}) = typemax(Int32)
infinity(::Type{Float32}) = typemax(Float32)
infinity(::Type{Float64}) = typemax(Float64)

function check_valid_vertex(bfsp::BFSP{T, T1}, u::T) where {T, T1}
  1 ≤ u ≤ v(bfsp.g) ||
    throw(ArgumentError("the given vertex $(u) is not defined in current digraph"))
end

function check_negative_cycle(bfsp::BFSP{T, T1}) where {T, T1}
  has_negative_cycle(bfsp) &&
    throw(ArgumentError("a negative weight/cost exists in this digraph"))
end

function incoming_edge(g::AEWDiGraph{T, T1}) where {T, T1 <: Real}
  in_edges = Dict{Int, Vector{Tuple{T, T1}}}()

  for vₒ ∈ 1:v(g)
    for (u, w) ∈ adj(g, vₒ)
      l_u = get(in_edges, u, Vector{Tuple{T, T1}}())
      push!(l_u, (vₒ, w))          ## vertex origin, weight
      in_edges[u] = l_u
    end
  end

  in_edges
end

function shortest_path(g::AEWDiGraph{T, T1}, s::T) where {T, T1 <: Real}
  @assert s ∈ 1:v(g) "Expecting vertex source to be in the graph"
  in_edges = incoming_edge(g)
  n = v(g)

  ## base case (ix = 1)
  a::Matrix{T1} = fill(infinity(T1), 2, n)  ## Only need a[ix - 1, v]’s to compute the a[ix, v]’s
  path_to::Vector{T} = fill(NULL_VERTEX, n)
  a[1, s] = zero(T1)

  ## systematically solve all sub-problems
  pk, ck = 1, 2
  for _ix in 1:n
    stable = true

    for vₒ ∈ 1:v(g)
      min_uvₒ, min_u = infinity(T1), NULL_VERTEX

      for (u, wv) ∈ get(in_edges, vₒ, Vector{Tuple{T, T1}}())
        ## edge "relaxation"
        if a[pk, u] < infinity(T1)
          d_uv₀ = a[pk, u] + wv

          if  d_uv₀ < min_uvₒ
            min_uvₒ, min_u = d_uv₀, u
          end
        end
      end

      a[ck, vₒ] = if a[pk, vₒ] < min_uvₒ
        a[pk, vₒ]
      else
        path_to[vₒ] = min_u
        min_uvₒ
      end

      a[ck, vₒ] ≠ a[pk, vₒ] && (stable = false)
    end

    stable && (return (a[ck, 1:end], path_to))
    pk, ck = 3 - pk, 3 - ck  ## toggle for next iteration
  end

  return ([], [])
end
