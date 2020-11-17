"""
  Dijkstra Shortest Path - EWDiGraph

  Using a Priority Queue
"""

using DataStructures

struct DSP{T}
  edge_to::Vector{T}
  dist_to::Vector{Int}                            ## as edge weigth are int, so are distance
  pq::PriorityQueue{T, Int}

  function DSP{T}(g::EWDiGraph{T}, s::T) where T  ## s == source vertex
    pq = PriorityQueue{T, Int}()
    edge_to = zeros(T, g.v)
    dist_to = fill(typemax(Int), g.v)
    dist_to[s] = 0
    enqueue!(pq, s, 0)

    self = new(edge_to, dist_to, pq)
    while !isempty(self.pq)
      relax(self, g, dequeue!(self.pq))
    end

    self
  end
end

# internal function
function relax(self::DSP{T}, g::EWDiGraph{T}, u::T) where T
  for (v, w) in g.adj[u]
    if self.dist_to[v] > self.dist_to[u] + w
      self.dist_to[v] = self.dist_to[u] + w
      self.edge_to[v] = u   # more edge_from ?

      if v in keys(self.pq)
        self.pq[v] = self.dist_to[v]
      else
        enqueue!(self.pq, v, w) # v => w
      end
    end
  end

end

function path_to(self::DSP{T}, g::EWDiGraph{T}, u::T) where T
  path, has_path = Stack{T}(), true

  while has_path
    push!(path, u)
    x = self.edge_to[u]
    x == 0 && break
    x ∉ 1:g.v && (has_path = false)
    u = x
  end

  !has_path && throw(ArgumentError("No path"))

  ary, ix = Vector{T}(undef, length(path)), 1
  while !isempty(path)
    ary[ix] = pop!(path)
    ix += 1
  end
  ary
end

function has_path(self::DSP{T}, g::EWDiGraph{T}, u::T) where T
  @assert u ∈ 1:g.v "Expected vertex $(u) to be in [1..#{g.v}]"
  has_path = true

  while has_path
    x = self.edge_to[u]
    x == 0 && break
    x ∉ 1:g.v && (has_path = false)
    u = x
  end

  has_path
end

function dist_to(self::DSP{T}, g::EWDiGraph{T}, u::T) where T
  @assert u ∈ 1:g.v "Expected vertex $(u) to be in [1..#{g.v}]"
  self.dist_to[u]
end
