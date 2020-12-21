"""
  Dijkstra (Single-Source) Shortest Path [DSP] - EWDiGraph

  Using a Priority Queue
"""

struct DSP{T, T1 <: Real}
  edge_to::Vector{T}
  dist_to::Vector{T1}              ## as edge weight are of type T1, so are distance
  pq::PriorityQueue{T, T1}
  _g::EWDiGraph{T, T1}
  src::T                           ## source vertex

  function DSP{T, T1}(g::EWDiGraph{T, T1}, s::T) where {T, T1}  ## s == source vertex
    self = new(init(g, s)..., g, s)
    while !isempty(self.pq)
      relax!(self, dequeue!(self.pq))
    end
    self
  end

  function DSP{T, T1}(g::EWDiGraph{T, T1}, s::T, wm::Matrix{T1}) where {T, T1}
    self = new(init(g, s)..., g, s)
    while !isempty(self.pq)
      relax!(self, dequeue!(self.pq), wm)
    end
    self
  end
end


##
## Public API
##

g(dsp::DSP{T, T1}) where {T, T1 <: Real} = dsp._g

function path_to(dsp::DSP{T, T1}, u::T) where {T, T1 <: Real}
  check_vertex_valid(dsp, u)

  has_path, path = follow_path(dsp, u)
  !has_path && throw(ArgumentError("No path from $(dsp.src) to $(u)"))
  path
end

has_path(dsp::DSP{T, T1}, u::T) where {T, T1 <: Real} = (check_vertex_valid(dsp, u) ; follow_path(dsp, u)[1])

dist_to(dsp::DSP{T, T1}, u::T) where {T, T1 <: Real} = (check_vertex_valid(dsp, u); dsp.dist_to[u])


##
## Internal Helpers
##
function init(g::EWDiGraph{T, T1}, s::T) where {T, T1}
  pq = PriorityQueue{T, T1}()
  edge_to = zeros(T, v(g))
  dist_to = fill(typemax(T1), v(g))
  dist_to[s] = 0
  enqueue!(pq, s, 0)

  (edge_to, dist_to, pq)
end

function relax!(dsp::DSP{T, T1}, u::T) where {T, T1  <: Real}
  for (v, w) in adj(dsp._g, u)
    relax!(dsp, (u, v, w))
  end
end

"""
  Ignore defined weight, use given wm (weight matrix)
"""
function relax!(dsp::DSP{T, T1}, u::T, wm::Matrix{T1}) where {T, T1  <: Real}
  for (v, _) in adj(dsp._g, u)
    relax!(dsp, (u, v, wm[u, v]))
  end
end

function relax!(dsp::DSP{T, T1}, (u, v, w) ::Tuple{T, T, T1}) where {T, T1  <: Real}
  du_w = dsp.dist_to[u] + w

  if dsp.dist_to[v] > du_w
    dsp.dist_to[v], dsp.edge_to[v] = du_w, u
    if v ∈ keys(dsp.pq)
      dsp.pq[v] = dsp.dist_to[v]
    else
      enqueue!(dsp.pq, v, w) # v => w
    end
  end
end

check_vertex_valid(dsp::DSP{T, T1}, u::T) where {T, T1  <: Real} = 1 ≤ u ≤ v(dsp._g) ||
  throw(ArgumentError("Expected vertex $(u) to be in [1..#{v(dsp._g)}]"))

function follow_path(dsp::DSP{T, T1}, u::T) where {T, T1 <: Real}
  path, has_path = Vector{T}(), true

  while has_path
    pushfirst!(path, u)
    u = dsp.edge_to[u]
    u == 0 && break
    u ∉ 1:v(dsp._g) && (has_path = false)
  end

  (has_path, path)
end
