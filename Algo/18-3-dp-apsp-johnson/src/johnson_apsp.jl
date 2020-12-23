"""
  Johnson Algorithms

  Step 1.
    Create g' by adding a vertex s such that v(g') = v(g) ∪ {s}
    e(g') = e(g) ∪ {(s, u) / ∀ u ∈ v(g)}

  Step 2. Run Bellman-Ford
    outcome: either negative cycle detected (end) or
             ok

    if ok
      for vertex v ∈ g'.v:
        h(v) = distance(s, v) computed by Bellman-Ford  ## bfsp.dist_to

      for (u, v, w) ∈ g'.e
        weight'(u, v) = w + h(u) - h(v)

    end

  Step 3.
    D  matrix n × n of distances init. to +∞

    for u ∈ g.v:
      run Dijkstra(g, weight', u)  # compute all dist'(u, v) ∀ v in v(g)

      for each vertex v ∈ g.v:
        D[u, v] = dist'(u, v) + h(v) - h(u)
    end

"""

struct JAPSP{T, T1}
  ng::EEWDiGraph{T, T1}
  src::T
  distm::Matrix{T1}
  path_to::Vector{Vector{T}}

  function JAPSP{T, T1}(g::AEWDiGraph{T, T1}) where {T, T1 <: Real}
    n₀ = v(g)
    ng = YA_EWD.EEWDiGraph{T, T1}(g)                 ## 1 - Build extended graph
    src = v(ng)                                      ## 2 - src is newly added vertex
    bfsp = YA_BFSP.BFSP{T, T1}(ng, src)              ## 3 - Run BF - calc. dist for src to all other vertices
    distm = Matrix{T1}(undef, 0, 0)
    YA_BFSP.has_negative_cycle(bfsp) &&
      return new(ng, src, Matrix{T1}(undef, 0, 0), Vector{Vector{T}}())

    weights = reweight(ng, bfsp, v(ng))              ## 4 - Build new weight matrix => reweighting
    distm, pathto = calc_distm(g, weights, bfsp,
                               init_pathto(T, n₀))   ## 5 - Run Dijkstra Shortets Path [DSP]

    new(ng, src, distm, pathto)
  end

  function JAPSP{T, T1}(infile::String, GType::DataType; positive_weight=true)  where {T, T1<: Real}
    g = GType(infile; positive_weight)
    JAPSP{T, T1}(g)
  end
end

##
## public API
##

function has_negative_cycle(japsp::JAPSP{T, T1})::Bool where {T, T1}
  length(japsp.distm) ≤ 0 && length(japsp.path_to) ≤ 0
end

function dist_to(japsp::JAPSP{T, T1}, u::T, v::T) where {T, T1 <: Real}
  check_vertex_valid(japsp, u) && check_vertex_valid(japsp, v)

  japsp.distm[u, v] < infinity(T1) && (return japsp.distm[u, v])
  throw(ArgumentError("No path from $(u) to $(v)"))
end

function has_path(japsp::JAPSP{T, T1}, u::T, v::T)::Bool where {T, T1 <: Real}
  check_vertex_valid(japsp, u) && check_vertex_valid(japsp, v)

  japsp.distm[u, v] < infinity(T1)
end

function path_to(japsp::JAPSP{T, T1}, u::T, v::T) where {T, T1 <: Real}
  check_vertex_valid(japsp, u) && check_vertex_valid(japsp, v)
  japsp.distm[u, v] < infinity(T1) || throw(ArgumentError("No path from $(u) to $(v)"))

  vc, path = v, Vector{T}()
  while vc ≠ u
    pushfirst!(path, vc)
    vc = japsp.path_to[u][vc]
  end
  pushfirst!(path, u)

  return path
end

function min_dist(japsp::JAPSP{T, T1}) where {T, T1 <: Real}
  check_negative_cycle(japsp)

  (n, _n) = size(japsp.distm)

  ## find min in distm matrix, then trace back path in path_to Vector
  min_val = infinity(T1)
  src, dst = (T(-1), T(-1))
  for cix in eachindex(view(japsp.distm, one(T):n, one(T):n))  # cartesian indexes
    eq(japsp.distm[cix], zero(T1), T1) && continue

    if japsp.distm[cix] < min_val
      min_val = japsp.distm[cix]
      (src, dst) = Tuple(cix)
    end
  end

  path = path_to(japsp, T(src), T(dst))
  (min_val, path)
end


##
## Internal Helpers
##

function reweight(ng::AEWDiGraph{T, T1}, bfsp::YA_BFSP.BFSP, n::Int) where {T, T1 <: Real}
  n = v(ng)
  re_weights::Matrix{T1} = fill(typemax(T1), n, n)

  for u in 1:n, (v, w) in adj(ng, u)
    re_weights[u, v] = w + YA_BFSP.dist_to(bfsp, u) - YA_BFSP.dist_to(bfsp, v)
  end

  re_weights
end

function init_pathto(T::DataType, n::Int)
  path_to = Vector{Vector{T}}(undef, n)
  for u in 1:n # ≡ v(g)
    path_to[u] = Vector{T}()
  end
  path_to
end

function calc_distm(g::AEWDiGraph{T, T1}, weights::Matrix{T1}, bfsp::YA_BFSP.BFSP,
                    pathto::Vector{Vector{T}}) where {T, T1 <: Real}
  n = v(g)
  distm::Matrix{T1} = fill(typemax(T1), n, n)

  for u in 1:n
    dsp = DSP{T, T1}(g, u, weights)
    pathto[u] = dsp.edge_to

    for vₒ in 1:n
      if YA_DSP.dist_to(dsp, vₒ) < infinity(T1)
        distm[u, vₒ] = YA_DSP.dist_to(dsp, vₒ) + YA_BFSP.dist_to(bfsp, vₒ) - YA_BFSP.dist_to(bfsp, u)
      end
    end
  end

  (distm, pathto)
end

check_vertex_valid(japsp::JAPSP{T, T1}, u::T) where {T, T1 <: Real} = 1 ≤ u ≤ v(japsp.ng) ||
  throw(ArgumentError("Expected vertex $(u) to be in [1..#{v(japsp._g)}]"))

function check_negative_cycle(japsp::JAPSP{T, T1}) where {T <: Integer, T1}
  has_negative_cycle(japsp) && throw(ArgumentError("Negative cycle detected"))
end

infinity(::Type{Int}) = typemax(Int)
infinity(::Type{Int32}) = typemax(Int32)
infinity(::Type{Float32}) = typemax(Float32)
infinity(::Type{Float64}) = typemax(Float64)

## in the following x, y are defined over T1
eq(x, y, ::Type{Int32}) = x == y
eq(x, y, ::Type{Int64}) = x == y
eq(x, y, ::Type{Float32}) = x ≈ y
eq(x, y, ::Type{Float64}) = x ≈ y
