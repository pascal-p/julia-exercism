"""
  Breadth First Search (BFS) for Undirected graph
"""

using DataStructures  ## for Stack and Queue

const INFINITY = typemax(Int)

struct UnBFS{T}
  _marked::Vector{Bool} 
  _edge_to::Vector{T}
  _s::T
  _dist_to::Vector{Int}

  """
  Single source
  """
  function UnBFS{T}(ug::UnGraph{T, T2}, s::T) where {T, T2}
    marked, edge_to, dist_to = bfs_init(ug)
    check_vertex(marked, s) &&
      ((marked, edge_to, dist_to) = bfs(ug, s, marked, edge_to, dist_to))

    return new(marked, edge_to, s, dist_to)
  end

  """
  Multiple sources
  """
  # function UnBFS{T}(ug::UnGraph{T, T2}, ss::Vector{T}) where {T, T2}
  #   @assert length(ss) > 0
    
  #   marked, edge_to, dist_to = bfs_init(ug)

  #   for s in ss
  #     if check_vertex(marked, s) && !marked[s]
  #       (marked, edge_to, dist_to) = bfs(ug, s, marked, edge_to, dist_to)
  #     end
  #   end
    
  #   return new(marked, edge_to, ss[1], dist_to) 
  # end
end

has_path_to(bfs::UnBFS{T}, v::T) where T = check_vertex(bfs, v) && return bfs._marked[v]

function path_to(bfs::UnBFS{T}, v::T)::Stack{T} where T
  check_vertex(bfs, v)

  !has_path_to(bfs, v) && return nothing

  path = Stack{T}()
  x = v               ## Starting vertex
  while x != bfs._s
    push!(path, x)
    x = bfs._edge_to[x]
  end

  push!(path, bfs._s)
  return path
end

path_builder(bfs::UnBFS{T}, v::T) where T = path_to(bfs, v) |>  x -> join(x, "-")

#
# Internal
#
function bfs_init(ug::UnGraph{T, T2}) where {T, T2}
  n = v(ug)
  marked::Vector{Bool} = fill(false, v(ug))
  edge_to::Vector{T} = fill(-1, v(ug))
  dist_to::Vector{Int} = fill(INFINITY, v(ug))

  return (marked, edge_to, dist_to)
end

function bfs(ug::UnGraph{T, T2}, s::T, args::Vararg{Any, 3}) where {T, T2}
  marked, edge_to, dist_to = args

  q = Queue{T}()
  marked[s], dist_to[s] = true, 0
  enqueue!(q, s)

  while !isempty(q)
    v = dequeue!(q)

    for (w, _c) in adj(ug, v)  ## ignore cost on edge v-w
      marked[w] && continue

      marked[w] = true
      edge_to[w], dist_to[w] = v, dist_to[v] + 1
      enqueue!(q, w)
    end
  end

  return (marked, edge_to, dist_to)
end

"""
Valid vertex are in range 1:n n = length of marked vector
"""
function check_vertex(bfs::UnBFS{T}, v::T)::Bool where T
  1 ≤ v ≤ length(bfs._marked) && return true
  throw(ArgumentError("Vertex outside acceptable range"))
end

function check_vertex(marked::Vector{Bool}, v::T)::Bool where T
  1 ≤ v ≤ length(marked) && return true
  throw(ArgumentError("Vertex outside acceptable range"))
end
