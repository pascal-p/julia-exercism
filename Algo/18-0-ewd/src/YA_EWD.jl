module YA_EWD
  ## Yet Another Edge Weigthed DiGraph

  export AEWDiGraph
  export EWDiGraph                  # Edge Weighted Directed Graph

  export add_edge, v, e, adj, has_edge,
    has_weighted_edge, weight

  include("abstract_edge_weighted_di_graph.jl")
  include("edge_weighted_di_graph.jl")
end
