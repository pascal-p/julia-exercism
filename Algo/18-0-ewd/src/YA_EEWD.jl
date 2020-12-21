module YA_EEWD

  export AEWDiGraph   # Abstract EWDG
  export EWDiGraph    # Edge Weighted Directed Graph [EWDG]
  export EEWDiGraph   # Extended Edge Weighted Directed Graph [EEWDG]


export v, e, adj, has_edge,
    # add_edge,
    has_weighted_edge, weight

  include("abstract_edge_weighted_di_graph.jl")
  include("edge_weighted_di_graph.jl")
  include("ext_edge_weighted_di_graph.jl")

end
