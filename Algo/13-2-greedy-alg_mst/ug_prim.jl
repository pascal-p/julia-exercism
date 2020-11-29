push!(LOAD_PATH, "./src")
using YAUG

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
  s = rand(1:g.v)
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
  # TODO
end

# Vanilla mst results
#
# Test Summary: | Pass  Total
# basics        |    5      5
# Test Summary:                       | Pass  Total
# prim MST on: input_random_15_80.txt |    1      1
# Test Summary:                        | Pass  Total
# prim MST on: input_random_18_100.txt |    1      1
# Test Summary:                        | Pass  Total
# prim MST on: input_random_19_100.txt |    1      1
# Test Summary:                      | Pass  Total
# prim MST on: input_random_1_10.txt |    1      1
# Test Summary:                        | Pass  Total
# prim MST on: input_random_21_200.txt |    1      1
# Test Summary:                        | Pass  Total
# prim MST on: input_random_27_400.txt |    1      1
# Test Summary:                        | Pass  Total
# prim MST on: input_random_28_400.txt |    1      1
# Test Summary:                         | Pass  Total
# prim MST on: input_random_37_2000.txt |    1      1
# Test Summary:                         | Pass  Total
# prim MST on: input_random_38_2000.txt |    1      1
# Test Summary:                         | Pass  Total
# prim MST on: input_random_44_4000.txt |    1      1
# Test Summary:                         | Pass  Total
# prim MST on: input_random_47_8000.txt |    1      1
# Test Summary:                         | Pass  Total
# prim MST on: input_random_48_8000.txt |    1      1
# Test Summary:                          | Pass  Total
# prim MST on: input_random_52_10000.txt |    1      1
# Test Summary:                          | Pass  Total
# prim MST on: input_random_56_20000.txt |    1      1
# Test Summary:                          | Pass  Total
# prim MST on: input_random_57_40000.txt |    1      1
# Test Summary:                          | Pass  Total
# prim MST on: input_random_61_80000.txt |    1      1
# Test Summary:                          | Pass  Total
# prim MST on: input_random_62_80000.txt |    1      1
# Test Summary:                           | Pass  Total
# prim MST on: input_random_66_100000.txt |    1      1
# Test Summary:                           | Pass  Total
# prim MST on: input_random_67_100000.txt |    1      1
#
