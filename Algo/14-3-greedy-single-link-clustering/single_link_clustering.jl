"""
  Single-Link Clustering via Kruskal’s Algorithm
"""

push!(LOAD_PATH, "./src")
push!(LOAD_PATH, "../14-1-union-find/src")

using YAUG                    ## for undirected graph
using YAFUF                   ## (faster) union-find data struct.

include("./utils/common.jl")  ## ../14-2-greedy-kruskal_mst/utils/


"""
Apply Kruskal algorithm on the set of points (≡ vertices), stop whenever
t (computed MST) has |X| - k edges
"""

function mst(ug::UnGraph{T1, T2}, k::Int) where {T1, T2}
  @assert k ≥ 1
  ut = initialize(ug)
  uf = UnionFind(v(ug))

  ## initialize with first edge
  (x, y, c) = edges(ug)[1]
  add_edge!(ut, x, y, c; cache_edges=true)
  union(uf, x, y)
  ix, n, m = 2, v(ug) - k, length(edges(ug)) - 1

  while length(edges(ut)) < n
    (x, y, c) = edges(ug)[ix]
    ix += 1
    @assert ix ≤ m "ix: $(ix) must be ≤ m: $(m)"

    if find(uf, x) ≠ find(uf, y)
      add_edge!(ut, x, y, c; cache_edges=true)
      union(uf, x, y)
    end
  end

  ## not required
  # t_edges = edges(t)
  # t_vertices = foldl((s, e) -> push!(s, e[1:2]...),
  #                   t_edges;
  #                   init=Set{T1}())
  return (ut, edges(ug))
end

get_cc(ut::UnGraph{T1, T2}) where {T1, T2} = UnCC{T1}(ut)

"""
  Calculate minimum separated distance inter-clusters ≡ maximum spacing
"""
function max_spacing(ut::UnGraph{T1, T2}, uncc::UnCC{T1}, edges)::T2 where {T1, T2}
  min_dist = typemax(T2)
  distance = Dict{Tuple{T1, T1}, T2}([(x, y) => c for (x, y, c) in edges]...)

  ## expensive calculation
  for ix in 1:count(uncc) - 1, jx in (ix+1):count(uncc)
    for vₚ ∈ vertex_from_cluster(uncc, ix), vᵣ ∈ vertex_from_cluster(uncc, jx)
      dist = get(distance, (vₚ, vᵣ), get(distance, (vᵣ, vₚ), typemax(T2)))
      dist < min_dist && (min_dist = dist)
    end
  end

  min_dist
end

"""
  Find the k clusters and return the max. spacing inter-clusters
"""
function calc_clusters(ug::UnGraph{T1, T2}, k::Int)::T2 where {T1, T2}
  ut, ug_edges = mst(ug, K)
  max_spacing(ut, get_cc(ut), ug_edges)
end
