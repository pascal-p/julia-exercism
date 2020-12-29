"""
  TSP - Revisited - using Nearest Neighbour (NN) heuristic

  - brute force version
  - x-sorted version
"""

include("./src/common.jl")

function tsp_bf(infile::String, DType::DataType)
  vcities = load_data(infile, DType; with_index=true)

  tdist, visited = calc_tsp_bf(vcities)

  (round_dist(tdist, Int), tdist, visited)
end

function tsp(infile::String, DType::DataType, x_sorted=true)
  vcities = load_data(infile, DType; with_index=true)

  x_sorted && (sort!(vcities, by=((_ix, p)=t) -> p.x))
  hsh = Dict([c[1] => ix for (ix, c) in enumerate(vcities)])

  tdist, visited = calc_tsp(vcities, hsh)
  (round_dist(tdist, Int), tdist, visited)
end

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

function calc_tsp(vcities::Vector{Tuple{Integer, Point{T}}}, hsh) where T
  DT, n = Float64, length(vcities)
  visited = Vector{Int}(undef, n + 1)
  visited[1] = 1
  ix, tot_dist = 1, zero(DT)

  for kx in 2:n                     ## visit each city once
    e_mdist, m_ix = typemax(DT), 0

    for c in vcities
      jx = c[1]                     ## original index (before sorting vcities)
      jx ∈ visited[1:kx - 1] && continue      ## avoid cities already visited

      x_cdist = vcities[hsh[ix]][2].x - vcities[hsh[jx]][2].x
      x_cdist *= x_cdist            ## calc. x-dist (last visited city, next city to visit)

      x_cdist > e_mdist && break    ## as vcities is x-coord. sorted in increasing order
                                    ## no need to go further when x-dist is greater than the recorded min. dist

      e_cdist = x_cdist +           ## square euclidean distance (last visited city, next city to visit)
        (vcities[hsh[ix]][2].y - vcities[hsh[jx]][2].y) ^ 2

      if e_cdist < e_mdist          ## update min. euclidean distance
        e_mdist, m_ix = e_cdist, jx

      elseif e_cdist == e_mdist     ## in case of ties, select lowest index
        m_ix = min(m_ix, jx)
      end
    end

    @assert m_ix ≠ 0 "Expecting m_ix to be > 0, got: $(m_ix)!"
    visited[kx] = ix = m_ix         ## update
    tot_dist += √(e_mdist)
  end

  ## Finally
  tot_dist += euclidean_dist(vcities[hsh[visited[end - 1]]][2], vcities[hsh[1]][2])
  visited[end] = 1
  return (tot_dist, visited)
end

function x_dist(ori::Point{T}, dst::Point{T}) where T <: Real
  abs(ori.x - dst.x)
end
