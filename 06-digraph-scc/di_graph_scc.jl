push!(LOAD_PATH, "./lib")

using YaG

function calc_scc(infile::String)  # T == Int here...
  g = DiGraph{Int}(infile)
  scc_g = SCC{Int}(g)

  return (scc_g, g)
end

function calc_scc(n::Int, edges)  # number of vertices
  g = DiGraph{Int}(n)

  for (o, d) in edges
    add_edge(g, o, d)
  end

  scc_g = SCC{Int}(g)

  return (scc_g, g)
end
