module YA_DSP
  ## Yet Another Dijkstra Shortest Path [impl.]

  using DataStructures                 ## `Julia` Package
  # using YAQ                          ## TODO: Write PriorityQ based on Heap
  using YA_EWD                         ## from 18-0-ewd/src (Edge Weigthed DiGraph)

  export DSP                           # Dijkstra Shortest Path

  export g, path_to, has_path, dist_to

  include("dijkstra_shortest_path.jl")
end
