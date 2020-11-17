"""
   Graph: Vertices = {1, 2, 3, 4}
          5 edges

   Representation: Dict(1: [2, 3], 2: [1, 3, 4], 3: [1, 2, 4], 4: [2, 3])

   [1]---[3]
    |    /|
    |   / |
    |  /  |
   [2]---[4]

"""

import Base.copy

mutable struct UnGraph{T}     ## undirected UnGraph
  n::Int                      ## Number of vertices (or nodes)
  m::Int                      ## Number of edges
  adj::Dict{T, Vector{T}}     ## Adjacency dict
  edges::Vector{Vector{T}}    ## unique list of edges in the current graph

  function UnGraph{T}(n::Int) where T
    self = new(n, 0)
    self.adj = Dict()
    return self
  end

  function UnGraph{T}(adj::Dict{T, Array{T, 1}}) where T
    self = new(length(keys(adj)), 0) # adjacency dict/hash
    add_adj!(self, adj)
    return self
  end
end

function add_adj!(graph::UnGraph{T}, adj::Dict{T, Vector{T}}) where T
  graph.adj = adj
  graph.m, graph.edges = update_edges(adj)
end

function update_edges(adj)
  s = Set()
  for k in keys(adj)
    edges = [sort([k, xe]) for xe in adj[k]]
    push!(s, edges...)
  end

  (length(s), sort([s...], by=t -> (t[1], t[2])))
end

function copy(graph::UnGraph{T}) where T
  adj_cpy = copy(graph.adj)
  UnGraph{T}(adj_cpy)
end

function cons_graph(graph)
  # TODO...
end

# -------------------------------------------------------------------

function mincut!(graph::UnGraph{T}) where T
  nv = graph.n

  while graph.n > 2
    k = rand(1:graph.m)                            # ex. k = 1
    (eo, ed) = graph.edges[k]                      # edge orig, edge dest / eo == 1, ed == 3
    adj_o, adj_e = graph.adj[eo], graph.adj[ed]    # get adjacency list
    nv += 1                                        # new vertex (replacing the 2 merged ones)
    graph.adj[nv] = sort([adj_o..., adj_e...])     # merge
    graph.adj[nv] = filter(x -> x ∉ (eo, ed),
                            graph.adj[nv])         # eliminate self-loop
    delete!(graph.adj, eo)                         # remove 1st merged node
    delete!(graph.adj, ed)                         # remove 3nd merged node
    graph.n -= 1                                   # one vertex/node less

    for n in keys(graph.adj)                       # update edge(s) in rest of graph to point
      n ∈ (eo, ed) && continue                     # to new merged node
      graph.adj[n] = map(x -> x ∈ (eo, ed) ? nv : x, graph.adj[n])
    end

    graph.m, graph.edges = update_edges(graph.adj) # update number of edges and edge list/array
  end

  @assert(graph.n == 2 && length(keys(graph.adj)) == 2,
          "graph.n: $(graph.n) / length(keys(graph.adj)): $(length(keys(graph.adj)))")

  n₁, n₂ = keys(graph.adj)
  @assert(length(graph.adj[n₁]) == length(graph.adj[n₂]),
          "graph.adj[n₁] (== $(graph.adj[n₁])) == graph.adj[n₂] (== $(graph.adj[n₂]))")

  return length(graph.adj[n₁])                     # get the cut number from the 2 last nodes / SHOULD BE EQUAL!
end

# -------------------------------------------------------------------
