# using DataStructures

push!(LOAD_PATH, "./src")
push!(LOAD_PATH, "../08-heap/src")
using YAUG    ## for undirected graph support
using YAH     ## for heap support - a way to impl. Priority Queue!

mutable struct ST{T1, T2}
  edge_to::Vector{Tuple{T1, T1}}
  cost_to::Vector{T2}
  marked::Vector{Int}
  pq::Heap{T1, T2}                               # PriorityQueue{T1, T2}

  function ST{T1, T2}(n::Integer) where {T1, T2}
    edge_to = Vector{Tuple{T1, T1}}(undef, n)
    cost_to::Vector{T2} = fill(typemax(T2), n)
    marked = zeros(Int, n)
    pq = Heap{T1, T2}(n; klass=MinHeap)          # PriorityQueue{T1, T2}()

    new(edge_to, cost_to, marked, pq)
  end
end

function mst(infile::String; T1::DataType=Int, T2::DataType=Int)
  ## 0 - instanciate the graph
  g = UnGraph{T1, T2}(infile)

  mst(g)
end

function mst(g::UnGraph{T1, T2}) where {T1, T2<:Integer}
  st = ST{T1, T2}(g.v)
  #
  # Multiple identical keys are NOT permitted. Ah!
  #
  insert!(st.pq, (key=zero(T2), value=one(T1)))  # enqueue!(st.pq, one(T2) => zero(T1))
  st.cost_to[1] = zero(T2)
  ix = 1
  while !isempty(st.pq)
    (_c, v) = extract_min!(st.pq)                # dequeue_pair!(st.pq)
    st.marked[v] = ix
    visit(g, v, st)
    ix += 1
  end

  return (sum(st.cost_to), st.edge_to[2:end], st.marked, st.cost_to)
end

function visit(g::UnGraph{T1, T2}, v::T1, st::ST{T1, T2}) where {T1, T2<:Integer}
  for (u, c) in g.adj[v]
    st.marked[u] > 0 && continue

    if c < st.cost_to[u]
      st.edge_to[u] = (v, u)
      ex_c = st.cost_to[u]
      st.cost_to[u] = c
      ix = get(map_ix(st.pq), (key=ex_c, value=u), 0)
      ix > 0 && delete!(st.pq, ix)
      insert!(st.pq, (key=c, value=u))
    end
  end

end

#
# include("./ug_prim_pq.jl")
# const TF_DIR = "./testfiles"
# g = UnGraph{Int, Int}("$(TF_DIR)/input_random_1_10.txt")
# mst(g)
#
