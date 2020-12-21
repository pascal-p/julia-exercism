module YA_FWAPSP
  ## Yet Another Floyd-Warshall APSP [All Pairs Shortest Paths] implementation
  # export AEWDiGraph
  export EWDiGraph
  export FWAPSP

  export add_edge, v, e, adj, has_edge, has_weighted_edge,
    weight

  export has_negative_cycle, min_dist, dist_to, path_to,
    has_path_to, infinity

  include("../../18-0-ewd/src/abstract_edge_weighted_di_graph.jl")
  include("../../18-0-ewd/src/edge_weighted_di_graph.jl")
  include("floyd_warshall_apsp.jl")
end
