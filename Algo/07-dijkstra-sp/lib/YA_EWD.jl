module YA_EWD
  ## Yet Another Edge Weigthed DiGraph

  export EWDiGraph                     # Edge Weighted Directed Graph
  export add_edge, v, e, adj, has_edge,
    has_weighted_edge

  include("edge_weighted_di_graph.jl")
end
