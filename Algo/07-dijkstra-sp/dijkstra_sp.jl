push!(LOAD_PATH, "./lib")

using YAG_DSP

#
# given a filename (infile) specifying an edge weigthed directed graph
# calculate the shortest path from a given source vertex
#
# T == Int
function shortest_path(infile::String, s::Int)
  g = EWDiGraph{typeof(s)}(infile)

  @assert s ∈ 1:g.v "Expecting vertex source to be in the graph"
  dsp = DSP{typeof(s)}(g, s)

  return (dsp, g)
end
