"""
  DiGraph - Directed Graph
"""

mutable struct DiGraph{T}
  v::Int                   # num. of vertices 1..v
  e::Int                   # num. of edges
  adj::Vector{Vector{T}}   # for adjacency list

  function DiGraph{T}(v::Int) where T
    adj = [Vector{T}() for _ ∈ 1:v]
    new(v, 0, adj)
  end

  DiGraph{T}(infile::String) where T = from_file(infile, DiGraph{T})

  DiGraph{T}(infile::String, n::Integer) where T = from_file(infile, n, DiGraph{T})
end

function add_edge!(self::DiGraph{T}, x::T, y::T) where T
  push!(self.adj[x], y)
  self.e += 1
end

function reverse(self::DiGraph{T})::DiGraph{T} where T
  rg::DiGraph{T} = DiGraph{T}(self.v)  # copy!
  for v ∈ one(T):T(self.v), w ∈ self.adj[v]
    add_edge!(rg, w, v)
  end
  rg
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

  open(infile, "r") do fh
    nv = get_nv(fh, DT)
    g = graph_cons(nv)
    act_nv = load_edges!(g, fh, DT)
    @assert act_nv == g.v # defer message to catch block
  end

  g
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
  for line ∈ eachline(fh) # read only first line
    nv = parse(DT, line)
    break
  end
  nv
end

function load_edges!(g::DiGraph, fh, DT::DataType)
  nv = 0
  for line ∈ eachline(fh)
    length(line) == 0 && continue
    ary = split(line)
    v = parse(DT, ary[1])
    nv += 1
    for w ∈ ary[2:end]
      add_edge!(g, v, parse(DT, w))
    end
  end
  nv
end
