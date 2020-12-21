module YA_DSP
  # Yet Another Dijkstra Shortest Path [impl.]

  using DataStructures
  # using YAQ                          # TODO: Write PriorityQ based on Heap

  export AEWDiGraph
  export EWDiGraph                     # Edge Weighted Directed Graph
  export DSP                           # Dijkstra Shortest Path

  export add_edge, v, e, adj
  export g, path_to, has_path, dist_to

  include("../../18-0-ewd/src/abstract_edge_weighted_di_graph.jl")
  include("../../18-0-ewd/src/edge_weighted_di_graph.jl")
  include("dijkstra_shortest_path.jl")
end
