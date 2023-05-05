push!(LOAD_PATH, "./src")
push!(LOAD_PATH, "../11-queue/src") ## for YAQ

using YAG_SCC

function calc_scc(infile::String; n::Integer=-1)   ## T == Int here...
  g = n > 0 ? DiGraph{Int}(infile, n) : DiGraph{Int}(infile)
  scc_g = SCC{Int}(g)
  (scc_g, g)
end

function calc_scc(n::Int, edges)    ## number of vertices
  g = DiGraph{Int}(n)
  for (o, d) ∈ edges
    add_edge(g, o, d)
  end

  scc_g = SCC{Int}(g)
  (scc_g, g)
end
