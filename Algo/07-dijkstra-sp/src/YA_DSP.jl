module YA_DSP
  ## Yet Another Dijkstra Shortest Path [impl.]

  using DataStructures
  # using YAQ                          ## TODO: Write PriorityQ based on Heap
  using YA_EWD                         ## from 18-0-ewd/src

  export DSP                           # Dijkstra Shortest Path

  export g, path_to, has_path, dist_to

  include("dijkstra_shortest_path.jl")
end
