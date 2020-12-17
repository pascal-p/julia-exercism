"""
Bellman-Ford Data Structure for Single-Source Shortest Path

Dependency on EWDiGraph
"""

push!(LOAD_PATH, ".")
using YAQ

const EPS = 1e-14
const NULL_EDGE = (-1, -1)
const INFINITY_INT = typemax(Int)
const INFINITY_FLOAT32 = typemax(Float32)
const INFINITY_FLOAT64 = typemax(Float64)

struct BFSP{T, T1}
  dist_to::Vector{T1}
  edge_to::Vector{Tuple{T, T}}
  g::EWDiGraph{T, T1}
  cycle::Vector{Tuple{T, T}}
  src::T

  function BFSP{T, T1}(g::EWDiGraph{T, T1}, s::T) where {T, T1}
    dist_to, edge_to, cycle = bfsp_builder(g, s)
    new(dist_to, edge_to, g, cycle, s)
  end

  function BFSP{T, T1}(infile::String, s::T; positive_weight=true) where {T, T1}
    g = EWDiGraph{T, T1}(infile; positive_weight)
    BFSP{T, T1}(g, s)
  end
end

function dist_to(bfsp::BFSP{T, T1}, v::T) where {T, T1}
  check_valid_vertex(bfsp.g, v)
  check_negative_cycle(bfsp)

  bfsp.dist_to[v]
end

function has_path_to(bfsp::BFSP{T, T1}, v::T) where {T, T1}
  check_valid_vertex(bfsp.g, v)

  has_path_to(bfsp, v, T1) # bfsp.dist_to[v] < typemax(T1)
end

function path_to(bfsp::BFSP{T, T1}, v::T) where {T, T1}
  check_valid_vertex(bfsp.g, v)
  check_negative_cycle(bfsp)

  !has_path_to(bfsp, v) && (return nothing)

  e, path = bfsp.edge_to[v], Vector{Tuple{T, T}}() # e == tuple(e[1] == src, e[2] == dst)
  while e ≠ NULL_EDGE
    pushfirst!(path, e)
    e = bfsp.edge_to[e[1]]
  end

  path
end

function has_negative_cycle(bfsp::BFSP{T, T1})::Bool where {T, T1}
  return length(bfsp.cycle) > 0
end

negative_cycle(bfsp::BFSP{T, T1}) where {T, T1} = bfsp.cycle

##
## Internal Helpers
##

function check_valid_vertex(g::EWDiGraph{T, T1}, u::T) where {T, T1}
  1 ≤ u ≤ v(g) ||
    throw(ArgumentError("the given vertex $(u) is not defined in current digraph"))
end

function check_negative_cycle(bfsp::BFSP{T, T1}) where {T, T1}
  has_negative_cycle(bfsp) &&
    throw(ArgumentError("a negative weight/cost exists in this graph"))
end

function bfsp_builder(g::EWDiGraph{T, T1}, s::T) where {T, T1}
  ## Prep.
  dist_to::Vector{T1} = fill(typemax(T1), v(g))
  edge_to::Vector{Tuple{T, T}} = fill(NULL_EDGE, v(g))
  on_q::Vector{Bool} = fill(false, v(g))
  queue = Q{T}(v(g))

  # cycle, cost, dist_to[s], edge_to[s] = Vector{Tuple{T, T}}(), 0, zero(T1), (s, s)
  cycle, cost, dist_to[s] = Vector{Tuple{T, T}}(), 0, zero(T1)

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
  enque!(queue, on_q, s)
  ix = 10
  while !isempty(queue) && length(cycle) == 0
    cv = dequeue!(queue)
    on_q[cv] = false
    _relax(cv)
    ix -= 1
    ix < 0 && break
  end

  (dist_to, edge_to, cycle)
end

enque!(queue::Q{T}, on_q::Vector{Bool}, v::T) where T = (enqueue!(queue, v); on_q[v] = true)

function find_negative_cycle(nv::Int, T1::DataType, edge_to::Vector{Tuple{T, T}},
                             cycle::Vector{Tuple{T, T}}) where T
  ## 1 - build new graph based on edge_to
  g = EWDiGraph{T, T1}(nv)
  for v in 1:nv
    if edge_to[v] ≠ NULL_EDGE
      (u, w) = edge_to[v]
      add_edge(g, u, w, one(T1))
    end
  end

  ## 2 - Prep
  c_edge_to::Vector{Tuple{T, T}} = fill(NULL_EDGE, nv) # = Vector{Tuple{T, T}}(undef, nv)
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
  for u ∈ 1:v(g)
    !marked[u] && _dfs(u)
  end

  cycle
end

has_path_to(bfsp::BFSP{T, T1}, v::T, ::Type{Int}) where {T, T1} = bfsp.dist_to[v] < INFINITY_INT
has_path_to(bfsp::BFSP{T, T1}, v::T, ::Type{Float32}) where {T, T1} = bfsp.dist_to[v] < INFINITY_FLOAT32
has_path_to(bfsp::BFSP{T, T1}, v::T, ::Type{Float64}) where {T, T1} = bfsp.dist_to[v] < INFINITY_FLOAT64
