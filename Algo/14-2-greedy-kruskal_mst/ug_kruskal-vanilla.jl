"""
  Vanilla Kruskal (greedy) MST Algorithm
"""

push!(LOAD_PATH, "./src")
using YAUG          ## for undirected graph + bfs support

include("./utils/common.jl")


function mst(ug::UnGraph{T1, T2}) where {T1, T2}
  t = initialize(ug)

  for (x, y, c) in edges(ug)[1:1]
    add_edge!(t, x, y, c; cache_edges=true)
  end

  for (x, y, c) in edges(ug)[2:end]
    bfs = UnBFS{T1}(t, x)

    !has_path_to(bfs, y) && add_edge!(t, x, y, c; cache_edges=true)
  end

  t_edges = edges(t)
  return (calc_cost(t_edges), t_edges)
end
