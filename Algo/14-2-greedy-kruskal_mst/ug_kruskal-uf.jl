"""
  UnionFind powered Kruskal (greedy) MST Algorithm
"""

push!(LOAD_PATH, "./src")
push!(LOAD_PATH, "../14-1-union-find/src")

using YAUG      ## for undirected graph
using YAFUF     ## (faster) union-find data struct.

include("./utils/common.jl")


function mst(ug::UnGraph{T1, T2}) where {T1, T2}
  t = initialize(ug)
  uf = UnionFind(v(ug))

  for (x, y, c) in edges(ug)[1:1]
    add_edge!(t, x, y, c; cache_edges=true)
    union(uf, x, y)
  end

  for (x, y, c) in edges(ug)[2:end]
    if find(uf, x) ≠ find(uf, y)
      add_edge!(t, x, y, c; cache_edges=true)
      union(uf, x, y)
    end
  end

  t_edges = edges(t)
  return (calc_cost(t_edges), t_edges)
end
