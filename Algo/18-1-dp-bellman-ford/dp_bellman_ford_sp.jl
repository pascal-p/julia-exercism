push!(LOAD_PATH, "./src")
using YA_EWD

"""
  Bellman-Ford Single-Source Shortest Path using DP

  Input:
    - a directed graph G=(V, E) in adjacency-list representation,
    - a source vertex s ∈ V , and
    - a real-valued length lₑ for each e ∈ E.

  Output: dist(s, v) for every vertex v ∈ V, or a declaration that G
    contains a negative cycle
"""

function shortest_path(infile::String, s::T;
                       WType::DataType=Int, positive_weight=true) where T
  g = EWDiGraph{T, WType}(infile; positive_weight)
  (shortest_path(g, s), g)
end

function shortest_path(g::EWDiGraph{T, T1}, s::T) where {T, T1 <: Real}
  @assert s ∈ 1:v(g) "Expecting vertex source to be in the graph"

  # hsh = edges_by_hop(g)
  in_edges = incoming_edge(g)
  n = v(g)

  ## base case (ix = 1)
  a::Matrix{T1} = fill(typemax(T1), n + 1, n)
  path_to = Vector{T}(undef, n) # = fill(nothing, n)

  a[1, s] = zero(T1)
  path_to[s] = s

  ## systematically solve all sub-problems
  for ix in 2:n+1
    stable = true

    for vₒ ∈ 1:v(g)
      min_uw, min_u = typemax(T1), -1

      for (u, l_wv) ∈ get(in_edges, vₒ, [])
        ## edge "relaxation"
        if a[ix - 1, u] ≠ typemax(T1) && a[ix - 1, u] + l_wv < min_uw
          min_uw = a[ix - 1, u] + l_wv
          min_u = u
        end
      end

      ## a[ix, vₒ] = min(a[ix - 1, vₒ], min_uw) + path memo for later path reconstruction
      if a[ix - 1, vₒ] < min_uw
        a[ix, vₒ] = a[ix - 1, vₒ]
      else
        a[ix, vₒ] = min_uw
        path_to[vₒ] = min_u
      end


      a[ix, vₒ] ≠ a[ix - 1, vₒ] && (stable = false)
    end
    # println()
    stable && (return (a[ix, 1:end], path_to))  # ∀ v ∈ V
  end

  return (:negative_cycle_found, [])
end

function incoming_edge(g::EWDiGraph{T, T1}) where {T, T1 <: Real}
  in_edges = Dict{Int, Vector{Tuple{T, T1}}}()

  for vₒ ∈ 1:v(g)
    for (u, w) ∈ adj(g, vₒ)
      l_u = get(in_edges, u, [])
      push!(l_u, (vₒ, w))
      in_edges[u] = l_u
    end
  end

  in_edges
end

# function edges_by_hop(g::EWDiGraph{T, T1}) where {T, T1 <: Real}
#   hsh = Dict{Int, Vector{Tuple{T, T1}}}()
#   level, vₒ = 1, 1
#   hsh[level] = Vector{Tuple{T, T1}}()

#   for (v₂, w) ∈ adj(g, vₒ)
#     push!(hsh[level], (v₂, w))
#   end
#   for _ ∈ 2:v(g)
#     level += 1
#     hsh[level] = []

#     for (v₂, _)  ∈ hsh[level - 1]
#       for (u, w) ∈ adj(g, v₂)
#         u ∉ map(t -> t[1], hsh[level]) && (push!(hsh[level], (u, w)))
#       end
#     end
#   end

#   hsh
# end

function dist_to(g::EWDiGraph{T, T1}, dist::Vector{T1}, dest::T) where {T, T1 <: Real}
  """
  Returns distance to vertex source (as calculated by  shortest_path above)
  """
  @assert 1 ≤ dest ≤ v(g)
  dist[dest]
end

function path_to(g::EWDiGraph{T, T1}, path_to::Vector{T}, dst::T; src::T=1) where {T, T1 <: Real}
  @assert 1 ≤ dst ≤ v(g)

  n = v(g)
  x, path = dst, [dst]
  while x ≠ 1
    pushfirst!(path, path_to[x])
    x = path_to[x]
    n -= 1
    n ≤ 0 && break
  end

  x ≠ 1 && throw(ArgumentError("cycle detected in path: $(src) --> $(dst)"))
  path
end

# Dict{Int64,Array{Tuple{Int64,Int64},1}} with 5 entries:
#   4 => Tuple{Int64,Int64}[]
#   2 => [(4, 4), (5, 2), (2, -1)]
#   3 => [(4, 2)]
#   5 => Tuple{Int64,Int64}[]
#   1 => [(2, 4), (3, 2)]


# [0 9223372036854775807 9223372036854775807 9223372036854775807 9223372036854775807;
#  0 4 -1 9223372036854775807 2;
#  0 4 -1 9223372036854775807 2;
#  9223372036854775807 9223372036854775807 9223372036854775807 9223372036854775807 9223372036854775807;
#  9223372036854775807 9223372036854775807 9223372036854775807 9223372036854775807 9223372036854775807;
#  9223372036854775807 9223372036854775807 9223372036854775807 9223372036854775807 9223372036854775807]
