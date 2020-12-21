"""
  Dijkstra (Single-Source) Shortest Path [DSP] - EWDiGraph

  Using a Priority Queue
"""

using DataStructures

struct DSP{T, T1 <: Real}
  edge_to::Vector{T}
  dist_to::Vector{T1}                            ## as edge weigth are of type T1, so are distance
  pq::PriorityQueue{T, T1}

  function DSP{T, T1}(g::EWDiGraph{T, T1}, s::T) where {T, T1}  ## s == source vertex
    pq = PriorityQueue{T, T1}()
    edge_to = zeros(T, v(g))
    dist_to = fill(typemax(T1), v(g))
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
function relax(self::DSP{T, T1}, g::EWDiGraph{T, T1}, u::T) where {T, T1  <: Real}
  for (v, w) in adj(g, u)
    if self.dist_to[v] > self.dist_to[u] + w
      self.dist_to[v] = self.dist_to[u] + w
      self.edge_to[v] = u

      if v ∈ keys(self.pq)
        self.pq[v] = self.dist_to[v]
      else
        enqueue!(self.pq, v, w) # v => w
      end
    end
  end

end

function path_to(self::DSP{T, T1}, g::EWDiGraph{T, T1}, u::T) where {T, T1 <: Real}
  path, has_path = Stack{T}(), true

  while has_path
    push!(path, u)
    x = self.edge_to[u]
    x == 0 && break
    x ∉ 1:v(g) && (has_path = false)
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

function has_path(self::DSP{T, T1}, g::EWDiGraph{T, T1}, u::T) where {T, T1 <: Real}
  @assert u ∈ 1:v(g) "Expected vertex $(u) to be in [1..#{v(g)}]"
  has_path = true

  while has_path
    x = self.edge_to[u]
    x == 0 && break
    x ∉ 1:v(g) && (has_path = false)
    u = x
  end

  has_path
end

function dist_to(self::DSP{T, T1}, g::EWDiGraph{T, T1}, u::T) where {T, T1 <: Real}
  @assert u ∈ 1:v(g) "Expected vertex $(u) to be in [1..#{v(g)}]"
  self.dist_to[u]
end
