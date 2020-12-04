# for inclusion only

function mst(infile::String; T1::DataType=Int, T2::DataType=Int)
  ug = UnGraph{T1, T2}(infile; cache_edges=true)   ## instanciate the graph from input file
  mst_vanilla(ug)
end

function initialize(ug::UnGraph{T1, T2}) where {T1, T2}
  sort_edges!(ug)   ## default sort by increasing cost of edges

  UnGraph{T1, T2}(v(ug))
end

function calc_cost(t_edges::Vector{Tuple{T1, T1, T2}})::T2 where {T1, T2}
  foldl((t_cost, ((_x, _y, c)=t)) -> t_cost += c,
        t_edges;
        init=0)
end
