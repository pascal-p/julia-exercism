"""
  TSP - Revisited - using Nearest Neighbour (NN) heuristic
  - x-sorted version

  Using Int32 for indexing and Float64 (for goiod precision regarding the distance
  calculation)
"""

include("./src/common.jl")
include("./src/nn_tsp_common.jl")


function calc_tsp_bf(vcities::Vector{Tuple{Integer, Point{T}}}) where T
  DT, n = Float64, length(vcities)
  visited = Vector{Int}(undef, n + 1)
  visited[1] = 1
  ix, tot_dist = 1, zero(DT)

  for kx in 2:n
    m_dist, m_ix = typemax(DT), 0

    for jx in 2:n
      (jx ∈ visited[1:kx - 1] || jx == ix) && continue

      c_dist = euclidean_dist(vcities[ix][2], vcities[jx][2])
      if c_dist < m_dist
        m_dist, m_ix = c_dist, jx
      end
    end
    visited[kx] = ix = m_ix
    tot_dist += m_dist
  end

  ## Finally
  tot_dist += euclidean_dist(vcities[visited[end - 1]][2], vcities[1][2])
  visited[end] = 1
  return (tot_dist, visited)
end


function calc_tsp(vcities::Vector{Tuple{Integer, Point{T}}}, DT::DataType,
                  hsh::Dict{T1, T1}) where T
  visited, hvisited = Vector{T1}(), Dict{T1, Bool}()
  push!(visited, one(T1))
  hvisited[one(T1)] = true
  ix, n, tot_dist = one(T1), T1(length(vcities)), zero(DT)

  while T1(length(visited)) < n
    (e_mdist, m_ix) = min_dist(vcities, DT, ix, hvisited, hsh)
    ix = m_ix
    push!(visited, m_ix)
    hvisited[m_ix] = true
    tot_dist += √(e_mdist)
  end

  ## Finally
  tot_dist += euclidean_dist(vcities[hsh[visited[end]]][2], vcities[hsh[1]][2])
  push!(visited, one(T1))
  return (tot_dist, visited)
end


"""
This version is for the challenge which uses a specification file nn.txt which is
pre x-sorted already
"""
function calc_tsp(vcities::Vector{Point{T}}, DT::DataType) where T
  visited, hvisited = Vector{T1}(), Dict{T1, Bool}()
  push!(visited, one(T1))
  ix, n = one(T1), T1(length(vcities))
  tot_dist = zero(DT)

  while T1(length(visited)) < n
    (e_mdist, m_ix) = min_dist(vcities, DT, ix, n, hvisited)
    ix = m_ix
    push!(visited, m_ix)
    hvisited[m_ix] = true
    tot_dist += DT(√(e_mdist))
  end

  ## Finally
  tot_dist += euclidean_dist(vcities[visited[end]], vcities[one(T1)])
  return (tot_dist, visited)
end
