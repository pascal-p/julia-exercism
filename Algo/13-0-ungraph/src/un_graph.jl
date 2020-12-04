"""
  Undirected graph with edges with cost
"""

import Base: Ordering, Forward

mutable struct UnGraph{T1, T2}
  _v::Int                              ## num. of vertices
  _e::Int                              ## num. of edges
  _adj::Vector{Vector{Tuple{T1, T2}}}  ## adjacency list

  _cache_edges::Bool
  _edges::Vector{Tuple{T1, T1, T2}}    ## keep list of all edges(3-tuple) (x, y, c)

  function UnGraph{T1, T2}(v::Int; cache_edges=false) where {T1, T2}
    adj = [Vector{Tuple{T1, T2}}() for _ in 1:v]
    edges = Vector{Tuple{T1, T1, T2}}()
    self = new(v, 0, adj, cache_edges, edges)
    return self
  end

  function UnGraph{T1, T2}(file::String) where {T1, T2}
    from_file(file, UnGraph{T1, T2})
  end
end

v(ug::UnGraph) = ug._v
e(ug::UnGraph) = ug._e
adj(ug::UnGraph, u::T1) where T1 = ug._adj[u]  ### no check to ensure ug.adj[u] is defined!
edges(ug::UnGraph) = ug._edges
sort_edges!(ug::UnGraph; lt=isless, by=((_x, _y, c)=t) -> c,
            rev=false, order::Ordering=Forward) = sort!(ug._edges; lt, by, rev, order)
# Forward or Reverse ordering

function add_edge!(ug::UnGraph{T1, T2}, x::T1, y::T1, c::T2;
                   cache_edges=false) where {T1, T2}
  x == y && return   ## self loop - ignore

  ## parallel edges - fine
  push!(ug._adj[x], (y, c))
  x != y && push!(ug._adj[y], (x, c))
  ug._e += 1
  if cache_edges || ug._cache_edges
    !ug._cache_edges && (ug._cache_edges = true)
    push!(ug._edges, (x, y, c))
  end
end

"""
  (x, y) is an edge of graph g (specify by its adjacency list) iff
  - y ∈ adj. list of vertex x or
  - x ∈ adj. list of vertex y

  or (if using 'edges' list) if (x, y) ∈ 'edges' list
"""
function is_edge(ug::UnGraph{T1, T2}, x::T1, y::T1) where {T1, T2}
  if ug._cache_edges
    any(((u, v) = t) -> u == x && v == y || u == y && v == x, ug._edges)
  else
    any(((u, _c) = t) -> u == y, ug._adj[x]) ||
      any(((u, _c) = t) -> u == x, ug._adj[y])
  end
end

"""
  edge_with_cost

returns (vertex, cost) - if several candidates, returns the one with lowest cost
"""
function edge_with_cost(ug::UnGraph{T1, T2}, x::T1, y::T1) where {T1, T2}
  a = filter(((u, _c) = t) -> u == y, ug._adj[x])
  isempty(a) && return (nothing, typemax(T1))

  if length(a) > 1
    foldl((cmin, ((_x, c)=t)) -> (cmin = c < cmin[2] ? c : cmin; cmin),
          a[2:end];
          init=a[1])
  else
    a[1]
  end
end

function find_mincost_edge(ug::UnGraph{T1, T2}, s::Set{T1})::Tuple{T1, T1, T2} where {T1, T2}
  u, v, min_cost = -1, -1, typemax(T2)

  λ = function(t_acc, (cv, cc))
    if cv ∈ s
      t_acc                ## next iteration
    else
      (min_c, y) = t_acc   ## min (cost), vertex (so far)
      if cc < min_c        ## cmp with current one
        y, min_c = cv, cc
      end
      (min_c, y)
    end
  end

  for x in s
    (cmin, cy) = foldl(λ, ug._adj[x]; init=(typemax(T2), -1))
    u, v, min_cost = cmin < min_cost ? (x, cy, cmin) : (u, v, min_cost)
  end

  return (u, v, min_cost)
end

"""
  Convention about the file structure:

  Start with an integer denoting the
  - number of vertices (or nodes) followed by
  - number of edges

  Then a sequence of lines describing edges, such line is
  formatted as follows:
  - vertex origin
  - vertex destination
  - the cost

  Ex: 4 vertex digraph with 4 (undirected) edges with cost:
  4 4
  1 2 10
  1 3 -5
  2 4 7
  3 4 5

"""

function from_file(infile::String, T::DataType;
                   T1::DataType=Int, T2::DataType=Int, cache_edges::Bool=false)
  local ug
  local act_ne = 0

  try
    open(infile, "r") do fh
      local nv, ne
      for line in eachline(fh)    ## read only first line, where we expect 2 Integers
        nv, ne = map(x -> parse(Int, strip(x)), split(line, r"\s+"))
        break
      end

      ug = T(nv)
      for line in eachline(fh)
        length(line) == 0 && continue
        ary = split(line)
        ##
        ## Here we expect only integers so following line would work
        ## u, v, c = map(x -> parse(Int, strip(x)), split(line))
        ## However, the cost can be of a different type than the vertices,
        ## thus the following two lines are more general
        ##
        u, v = map(x -> parse(T1, strip(x)), ary[1:2])
        c = parse(T2, strip(ary[end]))

        _n = ug._e
        add_edge!(ug, u, v, c; cache_edges)     ## also add edge in the other direction
        ug._e > _n && (act_ne += 1)
      end

      @assert act_ne ≤ ne "Expecting actual number of vertices $(act_ne) to be ≤ $(ne)"
    end

    @assert length(ug._adj) ≤ ug._v "Expecting actual number of vertices $(act_nv) to be ≤ $(ug._v)" # defer message to catch block
    @assert act_ne ≤ ug._e "Expecting actual number of edges $(act_ne) to be ≤  $(ug._e)" # defer message to catch block
    return ug

  catch err
    if isa(err, ArgumentError)
      println("! Problem with content of file $(infile)")

    elseif isa(err, SystemError)
      println("! Problem opening $(infile) in read mode... Exit")

    elseif isa(err, AssertionError)
      println("! Failed expectation: $(err)")

    else
      println("! other error: $(err)...")
    end
    exit(1)
  end
end


# ------------------------------------------------------------------------
# function add_edge!(ug::UnGraph{T1, T2}, x::T1, y::T1, c::T2) where {T1, T2}
#   ## deal with possible parallel edge - with different cost => keep the cheapest
#   (ix, _c) = find(ug._adj[x], y)

#   if ix == -1
#     push!(ug._adj[x], (y, c))
#     x != y && push!(ug._adj[y], (x, c))
#     ug.e += 1
#   else
#      if c < _c
#        ug._adj[x][ix] = (y, c)
#        x != y && replace!(ug._adj[y], x, c)
#     end
#   end
# end

# function find(adj, v)
#   local ix, c
#   found = false

#   for (jx, (x, c_)) in enumerate(adj)
#     if x == v
#       ix, c = jx, c_
#       println("Found parallel edge for v: $(v) in $(adj) with cost $(c_)")
#       found = true
#       break
#     end
#   end

#   found ? (ix, c) : (-1, nothing)
# end

# function replace!(adj, x, c)
#   (ix, _c) = find(adj, x)
#   adj[ix] = (x, c)
# end
# ------------------------------------------------------------------------
