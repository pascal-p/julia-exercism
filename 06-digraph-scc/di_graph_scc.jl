push!(LOAD_PATH, "./lib")

using YaG

function calc_scc(infile::String)  # T == Int here...
  g = DiGraph{Int}(infile)
  scc_g = SCC{Int}(g)

  return (scc_g, g)
end
