"""
  TSP - Revisited - using Nearest Neighbour (NN) heuristic

  - brute force version
  - x-sorted version

  Using Int32 for indexing and Float64 (for goiod precision regarding the distance
  calculation)
"""

include("./src/common.jl")
include("./src/nn_tsp_common.jl")


"""

using mutable vector (to_visit) for the cities to visit
"""
function calc_tsp(vcities::Vector{Tuple{Integer, Point{T}}}, hsh::Dict{T1, T1}) where T
  n = T1(length(vcities))
  visited = Vector{T1}(undef, n)
  visited[1] = one(T1)
  ix, tot_dist = one(T1), zero(T)
  to_visit::Vector{T1} = map(((jx, _p)=t) -> jx, vcities) |> a -> filter(ix -> ix > 1, a)

  for kx in 2:n
    (e_mdist, m_ix) = min_dist(vcities, ix, to_visit, hsh)
    visited[kx] = ix = m_ix
    deleteat!(to_visit, findfirst(idx -> idx == m_ix, to_visit))
    tot_dist += √(e_mdist)
  end

  ## Finally
  tot_dist += euclidean_dist(vcities[hsh[visited[end]]][2], vcities[hsh[1]][2])
  return (tot_dist, visited)
end


"""
This version is for the challenge which uses a specification file nn.txt which is
pre x-sorted already

visited is pre-allocated
using a hash (hvisited) to keep track of city indexes already visited
"""
function calc_tsp(vcities::Vector{Point{T}}) where T
  n = T1(length(vcities))
  visited, hvisited = Vector{T1}(undef, n), Dict{T1, Bool}()
  ix, tot_dist = one(T1), zero(T)

  for kx in 2:n
    (e_mdist, m_ix) = min_dist(vcities, ix, n, hvisited)
    visited[kx] = ix = m_ix
    hvisited[m_ix] = true
    tot_dist += √(e_mdist)
  end

  tot_dist += euclidean_dist(vcities[visited[end]], vcities[one(T1)])
  return (tot_dist, visited)
end

"""
This version is for the challenge which uses a specification file nn.txt which is
pre x-sorted already

visited is pre-allocated

instead of using a hash (hvisited) to keep track of city indexes already visited, use
a vector where we delete the city indexes already visited (this turns out to be significantly
faster)
"""
function calc_tsp_f(vcities::Vector{Point{T}}) where T
  n = T1(length(vcities))
  visited = Vector{T1}(undef, n)
  ix, tot_dist = one(T1), zero(T)
  to_visit::Vector{T1} = collect(T1(2):n)

  for kx in 2:n
    (e_mdist, m_ix) = min_dist(vcities, ix, n, to_visit)
    visited[kx] = ix = m_ix
    deleteat!(to_visit, findfirst(idx -> idx == m_ix, to_visit))
    tot_dist += √(e_mdist)
  end

  tot_dist += euclidean_dist(vcities[visited[end]], vcities[one(T1)])
  return (tot_dist, visited)
end
