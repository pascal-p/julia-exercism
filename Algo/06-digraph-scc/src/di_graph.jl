"""
  DiGraph - Directed Graph
"""

mutable struct DiGraph{T}
  v::Int                   # num. of vertices 1..v
  e::Int                   # num. of edges
  adj::Vector{Vector{T}}   # for adjacency list

  function DiGraph{T}(v::Int) where T
    adj = [ Vector{T}() for _ in 1:v ]
    self = new(v, 0, adj)
    return self
  end

  function DiGraph{T}(infile::String) where T
    from_file(infile, DiGraph{T})
  end

  function DiGraph{T}(infile::String, n::Integer) where T
    from_file(infile, n, DiGraph{T})
  end
end

function add_edge(self::DiGraph{T}, x::T, y::T) where T
  push!(self.adj[x], y)
  self.e += 1
end

function reverse(self::DiGraph{T})::DiGraph{T} where T
  rg::DiGraph{T} = DiGraph{T}(self.v)  # copy!

  for v in one(T):T(self.v), w in self.adj[v]
    add_edge(rg, w, v)
  end

  return rg
end

v(g::DiGraph) = g.v
e(g::DiGraph) = g.e

"""
  Convention about the file structure:

  Start with an integer denoting the number of vertices (or nodes) followed by
  a sequence of lines describing edges:
  - starting with the vertex origin (unique) and
  - an enumeration of destination vertices

  Ex: 4 vertex digraph with 4 edges:
  4
  1 2 3
  2 4
  3 4
  4

"""
function from_file(infile::String, graph_cons; DT::DataType=Int)
  g = graph_cons(0)
  act_nv = 0
  # try
    open(infile, "r") do fh
      # nv = 0
      # for line in eachline(fh) # read only first line
      #  nv = parse(Int, line)
      #  break
      #end
      nv = get_nv(fh, DT)

      g = graph_cons(nv)

      # for line in eachline(fh)
      #   length(line) == 0 && continue
      #   ary = split(line)
      #   v = parse(T, ary[1])
      #   act_nv += 1
      #   for w in ary[2:end]
      #     add_edge(g, v, parse(T, w))
      #   end
      # end
      act_nv = load_edges!(g, fh, DT)
    end

    @assert act_nv == g.v # defer message to catch block
    return g

  # catch err
  #   if isa(err, ArgumentError)
  #     println("! Problem with content of file $(infile)")
  #   elseif isa(err, SystemError)
  #     println("! Problem opening $(infile) in read mode... Exit")
  #   elseif isa(err, AssertionError)
  #     println("! Expected $(g.v) vertices, got: $(act_nv)")
  #   else
  #     println("! other error: $(err)...")
  #   end
  #   exit(1)
  # end
end

function from_file(infile::String, n::Integer, graph_cons; DT::DataType=Int)
  g = DiGraph{DT}(n)
  open(infile, "r") do fh
    load_edges!(g, fh, DT)
  end
  g
end

function get_nv(fh, DT::DataType)
  nv = 0
  for line in eachline(fh) # read only first line
    nv = parse(DT, line)
    break
  end
  nv
end

function load_edges!(g::DiGraph, fh, DT::DataType)
  nv = 0
  for line in eachline(fh)
    length(line) == 0 && continue

    ary = split(line)
    v = parse(DT, ary[1])

    nv += 1
    for w in ary[2:end]
      add_edge(g, v, parse(DT, w))
    end
  end
  nv
end
