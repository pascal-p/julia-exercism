push!(LOAD_PATH, "./lib")

using YAG_DSP

#
# given a filename (infile) specifying an edge weigthed directed graph
# calculate the single-source shortest path (SSSP)
#
function shortest_path(infile::String, s::T; WType::DataType=Int) where T
  g = EWDiGraph{T, WType}(infile)

  @assert s ∈ 1:v(g) "Expecting vertex source to be in the graph"
  dsp = DSP{typeof(s), WType}(g, s)

  return (dsp, g)
end
