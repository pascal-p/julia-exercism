push!(LOAD_PATH, "./src")
push!(LOAD_PATH, "../08-heap/src")
using YAUG    ## for undirected graph support
using YAH     ## for heap support

using Random

##
## Prim's minimum spanning tree algorithm (on undirected graph)
##
## Vanilla solution on (undirected) G(V, E), |V| = n, |E| = m
## V: Vertices (or Nodes), E: Edges
##
## Runtime complexity: O(m× n)
##

## Expecting a file of edge (as Int) and cost (as Int)
function mst_vanilla(infile::String; T1::DataType=Int, T2::DataType=Int)
  g = UnGraph{T1, T2}(infile)   ## instanciate the graph from innput file
  mst_vanilla(g)
end

function mst_vanilla(g::UnGraph{T1, T2}) where {T1, T2}
  ## 1 - Pick a vertex at random
  s = rand(1:g.v);
  xs = Set{T1}(s)              ## set of vertices that forms the MST
  ts = Set{Tuple{T1, T1}}()    ## a set of edges that forms the MST

  ## 2 - Loop over all vertices...
  tot_cost = 0
  while length(xs) < g.v
    # !all(v -> v, marked)  ## there is still a vertice to visit...
    u, v, c = find_mincost_edge(g, xs)
    @assert u ∈ xs
    @assert v ∉ xs
    tot_cost += c
    push!(xs, v)

    @assert (u, v) ∉ ts && (v, u) ∉ ts ## no cycle introducted
    push!(ts, (u, v))
  end

  @assert length(xs) == g.v
  return (tot_cost, ts)
end

##
## Using a (min)heap
##
function mst(infile::String; T1::DataType=Int, T2::DataType=Int)
  ## 0 - instanciate the graph
  g = UnGraph{T1, T2}(infile)

  mst(g)
end

function mst(g::UnGraph{T1, T2}) where {T1, T2}
  ## 1 - Pick a vertex at random
  s = rand(1:g.v)
  xs = Set{T1}(s)              ## set of vertices that forms the MST
  ts = Set{Tuple{T1, T1}}()    ## a set of edges that forms the MST
  min_heap = Heap{Int, Int}(g.v; klass=MinHeap)

  ## 2 - heapify (or tournament)
  ## for each not yet processed vertex v, record cost and identity of
  ## the cheapest edge incident to v that crosses the frontier and add
  ## it to the heap
  ##
  key    = Dict{T1, T2}()                   ## key: vertex, value: cost
  winner = Dict{T1, Tuple{T1, T2}}()        ## winner key:vertex, value: edge

  for v in filter(x -> x != s, 1:g.v)
    xv, c_sv = edge_with_cost(g, s, v);
    # @assert v == xv || xv == nothing      ## safety check - can be removed later
    key[v] = c_sv
    xv != nothing && (winner[v] = (s, v))
    insert!(min_heap, (key=c_sv, value=v))  ## key:cost, value: vertex
  end

  ## 3 - Loop over all vertices...
  tot_cost = 0
  while !isempty(min_heap)
    (c, w) = extract_min!(min_heap)
    @assert c == key[w]
    push!(xs, w)
    push!(ts, winner[w])
    tot_cost += c # or key[w]

    ## update keys in heap
    for (y, c_wy) in filter(((x, c)=t) -> x ∉ xs, g.adj[w]) ## ug.adj[w] vector of (vertex, cost)
      if c_wy < key[y]
        ix = get(map_ix(min_heap), (key=key[y], value=y), 0)
        @assert ix > 0
        delete!(min_heap, ix)

        key[y] = c_wy
        winner[y] = (w, y)
        insert!(min_heap, (key=c_wy, value=y))
      end
    end
  end

  @assert tot_cost == sum(values(key))
  return (tot_cost, ts)
end

#
# include("./ug_prim.jl") ; const TF_DIR = "./testfiles"
# mst("$(TF_DIR)/input_random_18_100.txt");
#
