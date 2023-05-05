"""
  Depth First Search (DFS) in DiGraph
"""

struct DFS{T}
  marked::Vector{Bool}
  edge_to::Vector{T}
  s::T

  function DFS{T}(g::DiGraph{T}, s::T) where T
    """
    Single source (s)
    """
    marked, count = dfs_init(g)
    check_vertex(marked, s) && ((marked, count) = dfs(g, s, marked, count))
    new(marked, count)
  end

  function DFS{T}(g::DiGraph{T}, ms::Vector{T}) where T
    """
    Multiple sources (ms)
    """
    marked::Vector{Bool} = fill(false, g.v)
    count = 0
    for s ∈ ms
      if check_vertex(marked, s) && !marked[s]
        marked, count = dfs(g, s, marked, count)
      end
    end
    new(marked, count)
  end
end

count(self::DFS{T}) where T = self.count

function marked(self::DFS{T}, v::T) where T
  check_vertex(self, v)
  self.marked[v]
end

#
# Internal
#
function dfs_init(g::DiGraph{T}) where T
  marked::Vector{Bool} = fill(false, g.v)
  count = 0
  (marked, count)
end

function dfs(g::DiGraph{T}, u::T, args::Vararg{Any,2}) where T
  marked, count = args
  function _dfs_(u::T)
    count += 1
    marked[u] = true
    for v ∈ g.adj[u]
      !marked[v] && _dfs_(v)
    end
  end

  _dfs_(u)
  (marked, count)
end
