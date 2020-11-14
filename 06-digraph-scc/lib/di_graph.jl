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

end

function add_edge(self::DiGraph{T}, x::Int, y::Int) where T
  push!(self.adj[x], y)
  self.e += 1
end

function reverse(self::DiGraph{T})::DiGraph{T} where T
  rg::DiGraph{T} = DiGraph{T}(self.v)  # copy!

  for v in 1:self.v, w in self.adj[v]
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
function from_file(infile::String, graph_cons) where T
  g = graph_cons(0)
  act_nv = 0
  try
    open(infile, "r") do fh
      nv = 0
      for line in eachline(fh) # read only first line
        nv = parse(Int, line)
        break
      end

      g = graph_cons(nv)

      for line in eachline(fh)
        length(line) == 0 && continue
        # println("==> processing line: $(line)")
        ary = split(line)
        v = parse(Int, ary[1])
        act_nv += 1
        for w in ary[2:end]
          add_edge(g, v, parse(Int, w))
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
      println("! other error: $(typeof(err))...")
    end
    exit(1)
  end
end
