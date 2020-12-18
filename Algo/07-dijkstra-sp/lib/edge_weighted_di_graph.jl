"""
  Edge Weighted Directed Graph - EWDiGraph

  Note: weigths are assumed to be positive integer
"""

mutable struct EWDiGraph{T, T1 <: Real}
  _v::Int                             # num. of vertices 1..v
  _e::Int                             # num. of edges
  _adj::Vector{Vector{Tuple{T, T1}}}  # for adjacency list (of tuples/pairs vertex(T), weight(T1)

  function EWDiGraph{T, T1}(v::Int) where {T, T1 <: Real}
    adj = [ Vector{Tuple{T, T1}}() for _ in 1:v ]
    self = new(v, 0, adj)
    return self
  end

  function EWDiGraph{T, T1}(infile::String; positive_weight=true) where {T, T1 <: Real}
    from_file(infile, EWDiGraph{T, T1}, T; WType=T1, positive_weight)
  end
end

function add_edge(self::EWDiGraph{T, T1}, x::T, y::T, w::T1;
                  positive_weight=true) where {T, T1 <: Real}
  positive_weight && (@assert w >= 0)

  push!(self._adj[x], (y, w)) ## tuple
  self._e += 1
end

v(g::EWDiGraph) = g._v
e(g::EWDiGraph) = g._e

adj(g::EWDiGraph, v::T) where T = g._adj[v]

function has_edge(g::EWDiGraph, u::T, v::T) where T
  ## if there is an edge u -> v, then adj(g, u) must contain v

  v ∈ map(t -> t[1], adj(g, u)) ## adj(g, u) ≡ list of tuple (vertex, weight)
end


"""
  Convention about the file structure:

  Start with an integer denoting the number of vertices (or nodes) followed
  optionally by expected number of edges.

  Then a sequence of lines describing edges:
  - starting with the vertex origin (unique) and
  - an enumeration of pair (destination vertex comma edge weight w/o space)

  Or
  - origin vertex
  - destination vertex
  - weight/cost

  Note weight/cost can be Int or Float

  Ex: 4 vertex digraph with 4 edges:
  4
  1 2,1 3,4
  2 3,2 4,6
  3 4,3
  4

  Or:
  1000 47978
  1 14 6
  1 25 47
  1 70 22
  1 82 31

"""
function from_file(infile::String, graph_cons, VType;
                   WType=Int, positive_weight=true)
  # VType => target type for vertices
  # WType => target type for weigth
  g = graph_cons(0)
  local nv = 0

  try
    open(infile, "r") do fh
      nv = 0
      for line in eachline(fh)             ## read only first line
        (nv, ) = map(s -> parse(Int, strip(s)),
                     split(line, r"\s+"))  ## expected number of vertices [opt. num. of edges)
        break
      end
      g = graph_cons(nv)

      prev_u = -1
      for line in eachline(fh)
        length(line) == 0 && continue

        ary = split(line)
        u = parse(VType, ary[1])
        if u ≠ prev_u            ## change of vertex?
          prev_u = u
        end

        if occursin(',', line)   ## do we have comma... assume following format:
          for v_w in ary[2:end]  ## v_w == "vertex,weight"
            sv, sw = split(v_w, r",")
            v, w = parse(VType, sv), parse(WType, sw)

            add_edge(g, u, v, w; positive_weight)
          end
        elseif length(ary) ≥ 2
          sv, sw = ary[2:end]
          v, w = parse(VType, sv), parse(WType, sw)
          add_edge(g, u, v, w; positive_weight)
        elseif length(ary) == 1
          # NO-OP - vertex with no incoming edge
        else
          throw(ArgumentError("Not dealing with this kind of data: $(ary) yet?"))
        end
      end
    end
    @assert nv == v(g) "Expected $(act_nv) vertices, got $(v(g))"   ## defer message to catch block
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
