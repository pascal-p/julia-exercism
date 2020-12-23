"""
Bellman-Ford Data Structure for Single-Source Shortest Path (src: Algo Princeton)

Dependency on AEWDiGraph, YAQ (cf. YA_BFSP)
"""

const EPS = 1e-14
const NULL_EDGE = (-1, -1)

struct BFSP{T, T1}
  dist_to::Vector{T1}
  edge_to::Vector{Tuple{T, T}}
  g::AEWDiGraph{T, T1}
  cycle::Vector{Tuple{T, T}}
  src::T

  function BFSP{T, T1}(g::AEWDiGraph{T, T1}, s::T) where {T <: Integer, T1 <: Real}
    dist_to, edge_to, cycle = bfsp_builder(g, s)
    new(dist_to, edge_to, g, cycle, s)
  end

  function BFSP{T, T1}(infile::String, s::T, GType::DataType; positive_weight=true) where {T <: Integer, T1 <: Real}
    g = GType(infile; positive_weight)
    BFSP{T, T1}(g, s)
  end
end

##
## Public API
##

function dist_to(bfsp::BFSP{T, T1}, v::T) where {T <: Integer, T1 <: Real}
  check_valid_vertex(bfsp, v)
  check_negative_cycle(bfsp)

  bfsp.dist_to[v]
end

function has_path_to(bfsp::BFSP{T, T1}, v::T) where {T <: Integer, T1 <: Real}
  check_valid_vertex(bfsp, v)

  bfsp.dist_to[v] < infinity(T1)
end

function path_to(bfsp::BFSP{T, T1}, v::T) where {T <: Integer, T1 <: Real}
  check_valid_vertex(bfsp, v)
  check_negative_cycle(bfsp)

  !has_path_to(bfsp, v) && (return nothing)

  e, path = bfsp.edge_to[v], Vector{Tuple{T, T}}() # e == tuple(e[1] == src, e[2] == dst)
  while e ≠ NULL_EDGE
    pushfirst!(path, e)
    e = bfsp.edge_to[e[1]]
  end

  path
end

function has_negative_cycle(bfsp::BFSP{T, T1})::Bool where {T <: Integer, T1 <: Real}
  return length(bfsp.cycle) > 0
end

negative_cycle(bfsp::BFSP{T, T1}) where {T <: Integer, T1 <: Real} = bfsp.cycle

function min_dist(bfsp::BFSP{T, T1})::T1 where {T <: Integer, T1 <: Real}
  min_dist = infinity(T1)

  for ix in 2:v(bfsp.g)
    dist_to(bfsp, ix) ≡ infinity(T1) && continue

    if dist_to(bfsp, ix) < min_dist
      min_dist = dist_to(bfsp, ix)
    end
  end

  min_dist
end

##
## Internal Helpers
##

function check_valid_vertex(bfsp::BFSP{T, T1}, u::T) where {T <: Integer, T1 <: Real}
  1 ≤ u ≤ v(bfsp.g) ||
    throw(ArgumentError("the given vertex $(u) is not defined in current digraph"))
end

function check_negative_cycle(bfsp::BFSP{T, T1}) where {T <: Integer, T1 <: Real}
  has_negative_cycle(bfsp) &&
    throw(ArgumentError("a negative weight/cost exists in this graph"))
end

function bfsp_builder(g::AEWDiGraph{T, T1}, s::T) where {T <: Integer, T1 <: Real}
  ## Prep.
  dist_to::Vector{T1} = fill(typemax(T1), v(g))
  edge_to::Vector{Tuple{T, T}} = fill(NULL_EDGE, v(g))
  on_q::Vector{Bool} = fill(false, v(g))
  queue = Q{T}(v(g))

  ## Init.
  cycle, cost, dist_to[s] = Vector{Tuple{T, T}}(), 0, zero(T1)
  enque!(queue, on_q, s)

  ## Closure
  function _relax(u::T) where T
    for (cv, cw) in adj(g, u)
      if dist_to[cv] > dist_to[u] + cw + (isa(typeof(cw), AbstractFloat) ? EPS : zero(T1))
        dist_to[cv] = dist_to[u] + cw
        edge_to[cv] = (u, cv)
        !on_q[cv] && enque!(queue, on_q, cv)
      end

      cost += 1
      if cost % v(g) == 0
        cycle = find_negative_cycle(v(g), T1, edge_to, cycle)
        length(cycle) > 0 && return
      end
    end
  end

  ## Main
  while !isempty(queue) && length(cycle) == 0
    cv = dequeue!(queue) # YAQ.dequeue!(queue)
    on_q[cv] = false
    _relax(cv)
  end

  (dist_to, edge_to, cycle)
end

enque!(queue::Q{T}, on_q::Vector{Bool}, v::T) where T = (enqueue!(queue, v); on_q[v] = true)
# (YAQ.enqueue!(queue, v); on_q[v] = true)

function find_negative_cycle(nv::Integer, T1::DataType,
                             edge_to::Vector{Tuple{T, T}}, cycle::Vector{Tuple{T, T}}) where {T <: Integer}

  ## 1 - build new graph based on edge_to
  g = EWDiGraph{T, T1}(nv)

  for v in 1:nv
    if edge_to[v] ≠ NULL_EDGE
      (u, w) = edge_to[v]
      add_edge(g, u, w, one(T1))
    end
  end

  ## 2 - Prep
  c_edge_to::Vector{Tuple{T, T}} = fill(NULL_EDGE, nv)
  marked::Vector{Bool} = fill(false, nv)
  on_stack::Vector{Bool} = fill(false, nv)

  function _dfs(u::T)
    marked[u] = true
    on_stack[u] = true

    for (cv, _w) in adj(g, u)
      length(cycle) > 0 && return

      if !marked[cv]
        c_edge_to[cv] = (u, cv)
        _dfs(cv)

      elseif on_stack[cv]  ## trace back cycle
        f = (u, cv)
        while f[1] ≠ cv
          pushfirst!(cycle, f)
          f = c_edge_to[f[1]]
        end

        pushfirst!(cycle, f)
        return
      end
    end
    on_stack[u] = false
  end

  ## 3 - run detection
  for u ∈ one(T):v(g)
    !marked[u] && _dfs(u)
  end

  cycle
end

infinity(::Type{Int}) = typemax(Int)
infinity(::Type{Int32}) = typemax(Int32)
infinity(::Type{Float32}) = typemax(Float32)
infinity(::Type{Float64}) = typemax(Float64)
