#
# for mix-in
#

const T1 = Int32


"""
  Brute force version
"""
function tsp_bf(infile::String, DT::DataType)
  vcities = load_data(infile, DT; with_index=true)
  tdist, visited = calc_tsp_bf(vcities)
  (round_dist(tdist, Int), tdist, visited)
end

"""
  Using x-sorted data (by sorting first the loaded data if not already x-sorted)

  x-sorted means sorting on x portion of the coordinate
"""
function tsp(infile::String, DT::DataType;
             x_sorted=false, no_index=false, algo=calc_tsp)
  vcities = no_index ? load_data(infile, DT; no_index) : load_data(infile, DT; with_index=true)

  tdist, visited = if !x_sorted
    sort!(vcities, by=((_ix, p)=t) -> p.x)
    hsh = Dict{Int32, Int32}([Int32(c[1]) => Int32(ix) for (ix, c) in enumerate(vcities)])
    calc_tsp(vcities, hsh)
  else
    algo(vcities)
  end

  (round_dist(tdist, Int), tdist, visited)
end


"""
Returns min. euclidean distance to next city and the index of that city

using a hash (hvisited) to keep track of cities already visited
"""
@inline function min_dist(vcities::Vector{Tuple{Integer, Point{T}}}, ix::Integer,
                  hvisited::Dict{T1, Bool}, hsh::Dict{T1, T1}) where T
  e_mdist, m_ix = typemax(T), zero(T1)

  for c in vcities
    get(hvisited, c[1], false) && continue ## avoid cities already visited
    jx = T1(c[1])                          ## original index (before sorting vcities)

    x_cdist = vcities[hsh[ix]][2].x - vcities[hsh[jx]][2].x
    x_cdist *= x_cdist                     ## calc. x-dist (last visited city, next city to visit)

    x_cdist > e_mdist && break             ## as vcities is x-coord. sorted in increasing order
    #                                      ## no need to go further when x-dist is greater than the recorded min. dist

    y_cdist = vcities[hsh[ix]][2].y - vcities[hsh[jx]][2].y
    e_cdist = x_cdist + y_cdist * y_cdist  ## square euclidean distance (last visited city, next city to visit)

    if e_cdist < e_mdist                   ## update min. euclidean distance
      e_mdist, m_ix = e_cdist, jx

    elseif e_cdist == e_mdist              ## in case of ties, select lowest index
      jx < m_ix && (m_ix = jx)
    end
  end

  (e_mdist, m_ix)
end

"""
using vector to_visit, for remaining cities to visit (fatser than above version)
"""
@inline function min_dist(vcities::Vector{Tuple{Integer, Point{T}}}, ix::Integer,
                  to_visit::Vector{T1}, hsh::Dict{T1, T1}) where T
  e_mdist, m_ix = typemax(T), zero(T1)

  for jx ∈ to_visit
    x_cdist = vcities[hsh[ix]][2].x - vcities[hsh[jx]][2].x
    x_cdist *= x_cdist                     ## calc. x-dist (last visited city, next city to visit)

    x_cdist > e_mdist && break             ## as vcities is x-coord. sorted in increasing order
    #                                      ## no need to go further when x-dist is greater than the recorded min. dist

    y_cdist = vcities[hsh[ix]][2].y - vcities[hsh[jx]][2].y
    e_cdist = x_cdist + y_cdist * y_cdist  ## square euclidean distance (last visited city, next city to visit)

    if e_cdist < e_mdist                   ## update min. euclidean distance
      e_mdist, m_ix = e_cdist, jx

    elseif e_cdist == e_mdist              ## in case of ties, select lowest index
      jx < m_ix && (m_ix = jx)
    end
  end

  (e_mdist, m_ix)
end


"""
for challenge
using a hash (hvisited) to keep track of cities already visited
"""
@inline function min_dist(vcities::Vector{Point{T}},  ix::Integer, n::Integer,
                          hvisited::Dict{T1, Bool}) where T
  e_mdist, m_ix = typemax(T), zero(T1)

  for jx ∈ T1(2):n
    get(hvisited, jx, false) && continue   ## avoid cities already visited

    x_cdist = vcities[ix].x - vcities[jx].x
    x_cdist *= x_cdist                     ## calc. x-dist (last visited city, next city to visit)

    x_cdist > e_mdist && break             ## as vcities is x-coord. sorted in increasing order
    #                                      ## no need to go further when x-dist is greater than the recorded min. dist

    y_cdist = vcities[ix].y - vcities[jx].y
    e_cdist = x_cdist + y_cdist * y_cdist  ## square euclidean distance (last visited city, next city to visit)

    if e_cdist < e_mdist                   ## update min. euclidean distance
      e_mdist, m_ix = e_cdist, jx

    elseif e_cdist == e_mdist              ## in case of ties, select lowest index
      jx < m_ix && (m_ix = jx)
    end
  end

  (e_mdist, m_ix)
end

"""
for challenge
using a hash (hvisited) to keep track of cities already visited
"""
@inline function min_dist(vcities::Vector{Point{T}},  ix::Integer, n::Integer,  # DT::DataType,
                          to_visit::Vector{T1}) where T
  e_mdist, m_ix = typemax(T), zero(T1)

  for jx ∈ to_visit
    x_cdist = vcities[ix].x - vcities[jx].x
    x_cdist *= x_cdist                     ## calc. x-dist (last visited city, next city to visit)

    x_cdist > e_mdist && break             ## as vcities is x-coord. sorted in increasing order
    #                                      ## no need to go further when x-dist is greater than the recorded min. dist

    y_cdist = vcities[ix].y - vcities[jx].y
    e_cdist = x_cdist + y_cdist * y_cdist  ## square euclidean distance (last visited city, next city to visit)

    if e_cdist < e_mdist                   ## update min. euclidean distance
      e_mdist, m_ix = e_cdist, jx

    elseif e_cdist == e_mdist              ## in case of ties, select lowest index
      jx < m_ix && (m_ix = jx)
    end
  end

  (e_mdist, m_ix)
end
