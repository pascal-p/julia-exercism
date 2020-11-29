#
# Undirected graph with edges with cost
#

mutable struct UnGraph{T1, T2}
  v::Int   # num. of vertices
  e::Int   # num. of edges
  adj::Vector{Vector{Tuple{T1, T2}}}

  function UnGraph{T1, T2}(v::Int) where {T1, T2}
    adj = [ Vector{Tuple{T1, T2}}() for _ in 1:v ] # Vector{Tuple{T1, T2}}(undef, v)
    self = new(v, 0, adj)
    return self
  end

  function UnGraph{T1, T2}(infile::String) where {T1, T2}
    from_file(infile, UnGraph{T1, T2})
  end
end

v(ug::UnGraph) = ug.v
e(ug::UnGraph) = ug.e

function add_edge!(ug::UnGraph{T1, T2}, x::T1, y::T1, c::T2) where {T1, T2}
  push!(ug.adj[x], (y, c))
  x != y && push!(ug.adj[y], (x, c))
  ug.e += 1
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
    (cmin, cy) = foldl(λ, ug.adj[x]; init=(typemax(T2), -1))
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
function from_file(infile::String, T::DataType; T1::DataType=Int, T2::DataType=Int)
  local g
  local act_ne = 0

  try
    open(infile, "r") do fh
      local nv, ne
      for line in eachline(fh)    ## read only first line, where we expect 2 Integers
        nv, ne = map(x -> parse(Int, strip(x)), split(line, r"\s+"))
        break
      end

      g = T(nv)
      for line in eachline(fh)
        length(line) == 0 && continue
        ary = split(line)
        ##
        ## Here we expect only integers so followiung line would work
        ## u, v, c = map(x -> parse(Int, strip(x)), split(line))
        ## However, the cost can be of a different type than the vertices,
        ## thus the following two lines are more general
        ##
        u, v = map(x -> parse(T1, strip(x)), ary[1:2])
        c = parse(T2, strip(ary[end]))  ## overkill: (c,) = map(x -> parse(T2, strip(x)), [ary[end]])
        act_ne += 1
        add_edge!(g, u, v, c)     ## also add edge in the other direction
      end

      @assert act_ne == ne "Expecting actual number of vertices $(act_ne) to be $(ne)"
    end

    @assert length(g.adj) == g.v " 2 Expecting actual number of vertices $(act_nv) to be $(g.v)" # defer message to catch block
    @assert act_ne == g.e " 2 Expecting actual number of vertices $(act_ne) to be $(g.e)" # defer message to catch block
    return g

  catch err
    if isa(err, ArgumentError)
      println("! Problem with content of file $(infile)")
    elseif isa(err, SystemError)
      println("! Problem opening $(infile) in read mode... Exit")
    elseif isa(err, AssertionError)
      println("! Expected $(g.v) vertices, got: $(act_nv)")
    else
      println("! other error: $(typeof(err))...")
    end
    exit(1)
  end
end
