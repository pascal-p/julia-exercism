module YA_EEWD

  # export AEWDiGraph
  export EEWDiGraph                   # Extended Edge Weighted Directed Graph
  export EWDiGraph                    # Edge Weighted Directed Graph

  export add_edge, v, e, adj, has_edge,
    has_weighted_edge, weight

  # include("abstract_edge_weighted_di_graph.jl")
  include("edge_weighted_di_graph.jl")
  include("ext_edge_weighted_di_graph.jl")
end
