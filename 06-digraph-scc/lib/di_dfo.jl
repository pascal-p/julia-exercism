"""
  Depth First Search vertex Ordering in a DiGraph
"""

const NT_VQQS = NamedTuple{(:marked, :pre, :post, :rev_post), Tuple{Vector{Bool}, Queue{T}, Queue{T}, Stack{T}}} where T

struct DFO{T}            # Depth First Order
  marked::Vector{Bool}   # Has vertex v been marked?
  pre::Queue{T}
  post::Queue{T}
  rev_post::Stack{T}

  function DFO{T}(g::DiGraph{T}) where T
    args = dfo_init(g)
    for v in 1:g.v
      !args.marked[v] && (args = dfo_dfs(g, v, args))
    end

    return new(args...)
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
  marked::Vector{Bool} = fill(false, g.v)
  pre, post = Queue{T}(), Queue{T}()
  rev_post = Stack{T}()

  return (marked = marked, pre =  Queue{T}(),
          post = Queue{T}(), rev_post = Stack{T}())
end

function dfo_dfs(g::DiGraph{T}, v::T, args::NT_VQQS)::NT_VQQS where T

  function _dfs_(u::T)
    enqueue!(args.pre, u)
    args.marked[u] = true

    for v in g.adj[u]
      !args.marked[v] && _dfs_(v)
    end

    enqueue!(args.post, u)
    push!(args.rev_post, u)
  end

  _dfs_(v)
  return args

end