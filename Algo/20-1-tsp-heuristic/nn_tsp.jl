"""
  TSP - Revisited - using Nearest Neighbour (NN) heuristic

  - brute force version
  - x-sorted version

  Using Int32 for indexing and Float64 (for goiod precision regarding the distance
  calculation)
"""

include("./src/common.jl")
include("./src/nn_tsp_common.jl")


function calc_tsp(vcities::Vector{Tuple{Integer, Point{T}}}, DT::DataType,
                  hsh::Dict{T1, T1}) where T
  n = T1(length(vcities))
  visited, hvisited = Vector{T1}(undef, n), Dict{T1, Bool}()
  visited[1] = one(T1)
  hvisited[one(T1)] = true
  ix, tot_dist = one(T1), zero(DT)

  for kx in 2:n
    (e_mdist, m_ix) = min_dist(vcities, DT, ix, hvisited, hsh)
    visited[kx] = ix = m_ix
    hvisited[m_ix] = true
    tot_dist += √(e_mdist)
  end

  ## Finally
  tot_dist += euclidean_dist(vcities[hsh[visited[end]]][2], vcities[hsh[1]][2])
  return (tot_dist, visited)
end


"""
This version is for the challenge which uses a specification file nn.txt which is
pre x-sorted already

visited is preallocated
"""
function calc_tsp(vcities::Vector{Point{T}}, DT::DataType) where T
  n = T1(length(vcities))
  visited, hvisited = Vector{T1}(undef, n), Dict{T1, Bool}()
  ix, tot_dist = one(T1), zero(DT)

  for kx in 2:n
    (e_mdist, m_ix) = min_dist(vcities, DT, ix, n, hvisited)
    visited[kx] = ix = m_ix
    hvisited[m_ix] = true
    tot_dist += DT(√(e_mdist))
  end

  tot_dist += euclidean_dist(vcities[visited[end]], vcities[one(T1)])
  return (tot_dist, visited)
end
