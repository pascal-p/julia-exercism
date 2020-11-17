"""
  Edge Weighted Directed Graph - EWDiGraph

  Note: weigths are assumed to be positive integer
"""

mutable struct EWDiGraph{T}
  v::Int                             # num. of vertices 1..v
  e::Int                             # num. of edges
  adj::Vector{Vector{Tuple{T, Int}}} # for adjacency list (of tuples/pairs vertx, weight(Int)

  function EWDiGraph{T}(v::Int) where T
    adj = [ Vector{T}() for _ in 1:v ]
    self = new(v, 0, adj)
    return self
  end

  function EWDiGraph{T}(infile::String) where T
    from_file(infile, EWDiGraph{T}, T)
  end
end

function add_edge(self::EWDiGraph{T}, x::T, y::T, w::Int) where T
  push!(self.adj[x], (y, w)) # tuple
  self.e += 1
end

v(g::EWDiGraph) = g.v
e(g::EWDiGraph) = g.e

"""
  Convention about the file structure:

  Start with an integer denoting the number of vertices (or nodes) followed by
  a sequence of lines describing edges:
  - starting with the vertex origin (unique) and
  - an enumeration of pair (destination vertex comma edge weight w/o space)

  Ex: 4 vertex digraph with 4 edges:
  4
  1 2,1 3,4
  2 3,2 4,6
  3 4,3
  4

"""
function from_file(infile::String, graph_cons, ttype)
  # ttype => target type for vertices
  g = graph_cons(0)
  act_nv = 0

  try
    open(infile, "r") do fh
      nv = 0
      for line in eachline(fh) # read only first line
        nv = parse(ttype, line)  # SHOULD BE T
        break
      end
      g = graph_cons(nv)

      for line in eachline(fh)
        length(line) == 0 && continue
        ary = split(line)
        u = parse(ttype, ary[1])
        act_nv += 1
        for v_w in ary[2:end]                             # v_w == "vertex,weight"
          v, w = split(v_w, ",")
          add_edge(g, u, parse(ttype, v), parse(Int, w))  # weigths are Integers
        end
      end
    end

    @assert act_nv == g.v # defer message to catch block
    return g

  catch err
    if isa(err, ArgumentError)
      println("! Problem with content of file $(infile)")
    elseif isa(err, SystemError)
      println("! Problem opening $(infile) in read mode... Exit")
    elseif isa(err, AssertionError)
      println("! Expected $(g.v) vertices, got: $(act_nv)")
    else
      println("! Other error: $(typeof(err))...")
    end
    exit(1)
  end
end
