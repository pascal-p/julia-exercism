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
  println("Start with vertex: $(s)")
  #println("Graph: $(g)")

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
  # println("Computed(vanilla): (tot_cost=$(tot_cost), ts=$(ts))")
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
  s = rand(1:g.v)   # 4, 6, 9, 10, 11, 12...35...
  # println("Start with vertex: $(s)")
  # println("Graph: $(g)")
  xs = Set{T1}(s)              ## set of vertices that forms the MST
  ts = Set{Tuple{T1, T1}}()    ## a set of edges that forms the MST
  min_heap = Heap{Int, Int}(g.v; klass=MinHeap, with_map=true)

  ## 2 - heapify (or tournament)
  ## for each not yet processed vertex v, record cost and identity of
  ## the cheapest edge incident to v that crosses the frontier and add
  ## it to the heap
  ##
  key    = Dict{T1, T2}()             ## key: vertex, value: cost
  winner = Dict{T1, Tuple{T1, T2}}()  ## winner key:vertex, value: edge

  for v in filter(x -> x != s, 1:g.v)
    xv, c_sv = edge_with_cost(g, s, v); # println("\t>> Considering edge $(s) ===> $(v) / cost: $(c_sv)")

    @assert v == xv || xv == nothing        ## safety check - can be removed later
    key[v] = c_sv
    xv != nothing && (winner[v] = (s, v))
    insert!(min_heap, (key=c_sv, value=v))  ## key:cost, value: vertex
  end
  # println("\nHeap: $(min_heap)")

  ## 3 - Loop over all vertices...
  tot_cost = 0

  while !isempty(min_heap)
    (c, w) = extract_min!(min_heap); # print(" > from vertex: $(s) ---> $(w) (c: $(c)) / adding winner[w:$(w)]: $(winner[w]) to ts / adj[$(w)]: $(g.adj[w]) ")
    @assert c == key[w]
    push!(xs, w)
    push!(ts, winner[w])
    tot_cost += c # or key[w]
    # s = w
    # println(" [$(ts)]")

    ## update keys in heap
    for (y, c_wy) in filter(((x, c)=t) -> x ∉ xs, g.adj[w]) ## ug.adj[w] vector of (vertex, cost)
      if c_wy < key[y]
        delete!(min_heap, map_ix(min_heap)[y])
        key[y] = c_wy
        winner[y] = (w, y)
        insert!(min_heap, (key=c_wy, value=y))
      end
    end

    if !isempty(min_heap)
      # println(" ||| update: next peek: $(peek(min_heap))")
      (_k, _v) = peek(min_heap)
      s = winner[_v][1]

      #if s ∈ [76, 77, 71, 72]
      #  println("\t// s:$(s) / heap: $(min_heap.h[1:6])")
      #end
    end
  end

  #println("\n1 Computed(heap): (tot_cost=$(tot_cost), ts=$(ts))")
  # println("2 key: $(key)")
  #println("3 winner: $(winner)")
  @assert tot_cost == sum(values(key))

  return (tot_cost, ts)
end

# Evaluated: -184174 == -184735  # 561
# KO: -184174
# [-9895, -9820, -9801, -9384, -9175, -9027, -9010, -8861, -8829, -8688, -8625, -8436, -8272, -8090, -8067, -7905, -7587, -7578, -7515, -7261, -7254, -7237, -6948, -6764, -6659, -6137, -6055, -6021, -5906, -5846, -5446, -5224, -5115, -4567, -4537, -4369, -4354, -4314, -4306, -3876, -3853, -3734, -3706, -3580, -3329, -3199, -3194, -3172, -3090, -2644, -2213, -1981, -1741, -1189, -686, -612, -591, -381, -283, -229, -134, -107, -82, -13, 439, 471, 748, 1463, 1510, 1658, 1748, 2653, 2881, 3144, 3403, 3413, 3477, 3847, 4004, 4025, 4052, 4067, 4115, 4143, 4240, 4505, 4583, 4657, 4902, 4944, 5072, 5209, 5259, 5896, 6830, 7217, 7419, 8151, 8185]                                                                                                                                                                                             ^^^^

# OK: -184735
# [-9895, -9820, -9801, -9384, -9175, -9027, -9010, -8861, -8829, -8688, -8625, -8436, -8272, -8090, -8067, -7905, -7587, -7578, -7515, -7261, -7254, -7237, -6948, -6764, -6659, -6137, -6055, -6021, -5906, -5846, -5446, -5224, -5115, -4567, -4537, -4369, -4354, -4314, -4306, -3876, -3853, -3734, -3706, -3580, -3329, -3199, -3194, -3172, -3090, -2644, -2213, -1981, -1741, -1189, -686, -612, -591, -381, -283, -229, -134, -107, -82, -13, 439, 471, 748, 1463, 1510, 1658, 1748, 2653, 2881, 3144, 3403, 3413, 3443, 3477, 3847, 4025, 4052, 4067, 4115, 4143, 4240, 4505, 4583, 4657, 4902, 4944, 5072, 5209, 5259, 5896, 6830, 7217, 7419, 8151, 8185]                                                                                                                                                                                 ^^^^
