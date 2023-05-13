module YA_EWD
  ## Yet Another Edge Weigthed DiGraph (with extenstion)

  export AEWDiGraph      ## (Abstract) Edge Weighted Directed Graph
  export EWDiGraph       ## Edge Weighted Directed Graph
  export EEWDiGraph      ## Ext(ended) Edge Weighted Directed Graph

  export add_edge, v, e, adj, has_edge,
    has_weighted_edge, weight, build_graph!

  include("abstract_edge_weighted_di_graph.jl")
  include("edge_weighted_di_graph.jl")
  include("ext_edge_weighted_di_graph.jl")
end
