using Random

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

const ALT{T} = Dict{T, Vector{T}} where T ## Adjacency List Type

mutable struct UnGraph{T}     ## undirected graph
  n::Int                      ## Number of vertices (or nodes)
  m::Int                      ## Number of edges
  adj::ALT{T}                 ## Adjacency list, represented as a dict
  edges::Set{Tuple{T, T}}     ## Set of edges in the current graph

  function UnGraph{T}(n::Int) where T
    self = new(n, 0)
    self.adj = Dict()
    self
  end

  function UnGraph{T}(adj::ALT{T}) where T
    self = new(length(keys(adj)), 0) # adjacency dict/hash
    add_adj!(self, adj)
    self
  end
end

function add_adj!(graph::UnGraph{T}, adj::ALT{T}) where T
  graph.adj = adj
  graph.m, graph.edges = update_edges(adj)
end

function update_edges(adj::ALT{T}) where T
  ## eliminate parallel edges
  s = Set{Tuple{T, T}}()

  for k ∈ keys(adj)
    edges = [k < xe ? (k, xe) : (xe, k) for xe ∈ adj[k] if xe != k]
    push!(s, edges...)
  end

  (length(s), s) ## sort([s...], by=t -> (t[1], t[2])))
end

function update_edges!(graph::UnGraph{T}, nv::Int, eo::T, ed::T) where T
  delete!(graph.edges, (eo, ed))
  sd = Set{Tuple{T, T}}()
  sa = Set{Tuple{T, T}}()

  for (x, y) ∈ graph.edges
    if x == eo || x == ed
      push!(sd, (x, y))
      x = nv
      push!(sa, x < y ? (x, y) : (y, x))
    end

    if y == eo || y == ed
      push!(sd, (x, y))
      y = nv
      push!(sa, x < y ? (x, y) : (y, x))
    end

    if x ∉ keys(graph.adj) || y ∉ keys(graph.adj)
      push!(sd, (x, y))
    end
  end

  ## delete no longer required edges
  for (x, y) ∈ sd; delete!(graph.edges, (x, y)); end

  ## add renamed edges
  for (x, y) ∈ sa; push!(graph.edges, (x, y)); end

  graph.m = length(graph.edges)
  return
end

function copy(graph::UnGraph{T}) where T
  adj_cpy = copy(graph.adj)
  UnGraph{T}(adj_cpy)
end

function cons_graph(_graph::UnGraph{T}) where T
  # TODO...
end

# -------------------------------------------------------------------
##
## Client portion
##
# -------------------------------------------------------------------

function mincut!(graph::UnGraph{T}; seed=9977) where T
  nᵥ = graph.n
  Random.Random.seed!(seed)

  while graph.n > 2
    (eo, ed) = rand(graph.edges)                   ## randomly select an edge from graph and assign to eo == 1, ed == 3
    # @assert(eo < ed, "edge origin $(eo) and edge dest $(ed) should be ordered")
    adj_o, adj_e = graph.adj[eo], graph.adj[ed]    ## get adjacency list
    nᵥ += 1                                        ## new vertex (replacing the 2 merged ones)

    graph.adj[nᵥ] = filter(
      x -> x ∉ (eo, ed),
      sort([adj_o..., adj_e...])
    )                                              ## merge vertices && eliminate self-loop
    delete!(graph.adj, eo)                         ## remove 1st merged node
    delete!(graph.adj, ed)                         ## remove 2nd merged node
    graph.n -= 1                                   ## one vertex/node less as a result of the merge operation

    for n ∈ keys(graph.adj)                       ## update edge(s) in rest of graph to point
      n ∈ (eo, ed) && continue                    ## to new merged node

      graph.adj[n] = map(
        x -> x ∈ (eo, ed) ? nᵥ : x,
        graph.adj[n]
      )
    end

    update_edges!(graph, nᵥ, eo, ed)
  end

  @assert(graph.n == 2 && length(keys(graph.adj)) == 2,
          "graph.n: $(graph.n) / length(keys(graph.adj)): $(length(keys(graph.adj))) / adj: $(graph.adj)")

  n₁, n₂ = keys(graph.adj)                        ## get the cut number from the 2 last nodes / SHOULD BE EQUAL!
  @assert(length(graph.adj[n₁]) == length(graph.adj[n₂]),
          "graph.adj[n₁] (== $(graph.adj[n₁])) == graph.adj[n₂] (== $(graph.adj[n₂]))")

  length(graph.adj[n₁])
end

# -------------------------------------------------------------------
