"""
  Compute the strongly-connected components (SCC) of a DiGraph using the
  Kosaraju-Sharir algorithm.
"""

const NT_BI = NamedTuple{(:marked, :id), Tuple{Vector{Bool}, Vector{Int}}}

struct SCC{T}               # Strongly Connected Components
  marked::Vector{Bool}
  count::Int
  id::Vector{Int}           # id[v] = id of strong component containing v

  function SCC{T}(g::DiGraph{T}) where T
    dfo::DFO{T} = DFO{T}(reverse(g))
    count, args = 1, scc_init(g)

    for s in rev_post(dfo)
      if !args.marked[s]
        args = scc_dfs(g, s, args, count)
        count += 1
      end
    end

    return new(args.marked, count - 1, args.id)
    # TODO: assert that id[] gives strong comp.
  end
end

function id(self::SCC{T}, v::T)::T where T
  # check_vertex(self, v)
  self.id[v]
end

function count(self::SCC{T})::Int where T
  self.count
end

"""
  groupby (by) id
"""
function groupby(self::SCC{T}, v::T)::Vector{T} where T
  vec(collect(Base.enumerate(self.id))) |>
    at -> filter((t) -> t[2] == v, at) |>
    at -> map((t) -> t[1], at) |>
    a -> sort(a, rev=false)
end

"""
  topn (default 5) SCC in descendant order
"""
function topn(self::SCC{T}; n::Int=5)::Vector{Pair{T, T}} where T
  foldl((h, x) -> (h[x]=get(h, x, 0) + 1; h),
        self.id;
        init=Dict{Int, Int}()) |>
    h -> sort(vec(collect(h)); by=t -> t[2], rev=true) |>
    h -> h[1:min(n, length(h))]
end

#
# Internal
#

function scc_init(g::DiGraph{T})::NT_BI where T
  n = g.v
  marked::Vector{Bool} = fill(false, n)
  id = Vector{T}(undef, n)
  return (marked = marked, id = id)
end

function scc_dfs(g::DiGraph{T}, u::T, args::NT_BI, count::Int)::NT_BI where T
  function _dfs_(u::T)
    args.marked[u] = true
    args.id[u] = count

    for v in g.adj[u]
      !args.marked[v] && _dfs_(v)
    end
  end

  _dfs_(u)
  return args
end
