module YA_BFSP_ALT

  export EWDiGraph
  export BFSP

  export add_edge, v, e, adj, has_edge
  export dist_to, has_path_to, path_to, has_negative_cycle,
    min_dist
#    negative_cycle, min_dist

  include("edge_weighted_di_graph.jl")
  include("dp_bellman_ford_sp.jl")
end
