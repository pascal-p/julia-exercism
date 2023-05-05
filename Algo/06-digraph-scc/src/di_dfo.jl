"""
  Depth First Search vertex Ordering in a DiGraph
"""

const NT_VQQS = NamedTuple{(:marked, :pre, :post, :rev_post),
  Tuple{Vector{Bool}, Q{T}, Q{T}, Vector{T}}} where T

struct DFO{T}            # Depth First Order
  marked::Vector{Bool}   # Has vertex v been marked?
  pre::Q{T}
  post::Q{T}
  rev_post::Vector{T}

  function DFO{T}(g::DiGraph{T}) where T
    args = dfo_init(g)
    for v ∈ one(T):T(g.v)
      !args.marked[v] && (args = dfo_dfs(g, v, args))
    end
    new(args...)
  end
end

pre(self::DFO{T}) where T = self.pre

post(self::DFO{T}) where T = self.post

rev_post(self::DFO{T}) where T = self.rev_post

#
# Internal
#

function dfo_init(g::DiGraph{T})::NT_VQQS where T
  n = g.v
  marked::Vector{Bool} = fill(false, n)
  pre, post = Q{T}(n), Q{T}(n)
  rev_post = Vector{T}()

  (marked = marked, pre = pre, post = post, rev_post = rev_post)
end

function dfo_dfs(g::DiGraph{T}, v::T, args::NT_VQQS)::NT_VQQS where T
  function _dfs_(u::T)
    enqueue!(args.pre, u)
    args.marked[u] = true
    for v ∈ g.adj[u]
      !args.marked[v] && _dfs_(v)
    end
    enqueue!(args.post, u)
    pushfirst!(args.rev_post, u)
  end

  _dfs_(v)
  args
end
