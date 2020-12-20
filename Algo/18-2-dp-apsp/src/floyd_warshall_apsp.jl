const EPS = 1e-14

struct FWAPSP{T <: Integer, T1 <: Real}
  dist_to::Matrix{T1}
  path_to::Matrix{T}
  g::EWDiGraph{T, T1}

  function FWAPSP{T, T1}(g::EWDiGraph{T, T1}) where {T <: Integer, T1 <: Real}
    status, dist_to, path_to = shortest_path(g)

    if status == :negative_cycle
      dist_to = Matrix{T1}(undef, 0, 0)
      path_to = Matrix{T}(undef, 0, 0)
    end

    new(dist_to, path_to, g)
  end

  function FWAPSP{T, T1}(infile::String; positive_weight=true) where {T <: Integer, T1 <: Real}
    g = EWDiGraph{T, T1}(infile; positive_weight)
    FWAPSP{T, T1}(g)
  end
end

##
## Public API
##

function has_negative_cycle(fwapsp::FWAPSP{T, T1})::Bool where {T <: Integer, T1}
  length(fwapsp.dist_to) == 0 && length(fwapsp.path_to) == 0
end

function min_dist(fwapsp::FWAPSP{T, T1}) where {T <: Integer, T1}
  check_negative_cycle(fwapsp)

  (n, _n) = size(fwapsp.dist_to)

  ## find min in dist_to matrix, then trcae back path in path_to matrix
  min_val = infinity(T1)
  src, dst = (T(-1), T(-1))

  for cix in eachindex(view(fwapsp.dist_to, one(T):n, one(T):n))  # cartesian indexes
    eq(fwapsp.dist_to[cix], zero(T1), T1) && continue

    if fwapsp.dist_to[cix] < min_val
      min_val = fwapsp.dist_to[cix]
      (src, dst) = Tuple(cix)
    end
  end

  path = path_to(fwapsp, T(src), T(dst))
  (min_val, path)
end

infinity(::Type{Int32}) = typemax(Int32)
infinity(::Type{Int64}) = typemax(Int64)
infinity(::Type{Float32}) = typemax(Float32)
infinity(::Type{Float64}) = typemax(Float64)

function dist_to(fwapsp::FWAPSP{T, T1}, src::T, dst::T) where {T <: Integer, T1}
  check_valid_vertex(fwapsp.g, src, dst)
  check_negative_cycle(fwapsp)

  fwapsp.dist_to[src, dst]
end

function path_to(fwapsp::FWAPSP{T, T1}, src::T, dst::T) where {T <: Integer, T1}
  check_valid_vertex(fwapsp.g, src, dst)
  check_negative_cycle(fwapsp)

  path, cur = Vector{T}(), src
  while cur ≠ dst
    push!(path, cur)
    cur = fwapsp.path_to[cur, dst]
  end
  push!(path, dst)

  path
end

function has_path_to(fwapsp::FWAPSP{T, T1}, src::T, dst::T) where {T <: Integer, T1}
  check_valid_vertex(fwapsp.g, src, dst)

  fwapsp.dist_to[src, dst] < infinity(T1)
end

##
## Internal Helpers
##

function shortest_path(g::EWDiGraph{T, T1}) where {T <: Integer, T1 <: Real}
  n = T(v(g))
  a = Array{T1, 3}(undef, n, n, n)
  p = Matrix{T1}(undef, n, n)

  ## base case k ≡ 1
  for v in one(T):n, w in one(T):n
    (edge_vw, weight_vw) = has_weighted_edge(g, v, w)

    if v == w
      a[1, v, w], p[v, w] = edge_vw ? (weight_vw, w) : (zero(T1), infinity(T1))
    else
      a[1, v, w], p[v, w] = edge_vw ? (weight_vw, w) : (infinity(T1), infinity(T1))
    end
  end

  ## systematically solve all subproblems
  for k in 2:n, v in one(T):n, w in one(T):n
    v₁, v₂ = a[k - 1, v, k], a[k - 1, k, w]
    a[k, v, w], update_p = if v₁ < infinity(T1) && v₂ < infinity(T1)
      s = v₁ + v₂ + (isa(typeof(v₁), AbstractFloat) ? EPS : zero(T1))
      a[k - 1, v, w] ≤ s ? (a[k - 1, v, w], false) : (s, true)  # update p matrix
    else
      (a[k - 1, v, w], false)
    end
    update_p && (p[v, w] = p[v, k])
  end

  ## Check for negative cycles
  for v in 1:n
    a[n, v, v] < zero(T1) && (return (:negative_cycle, nothing, nothing))
  end

  return (:ok, a[n, 1:end, 1:end], p)
end

function check_valid_vertex(g::EWDiGraph{T, T1}, v₁::T, v₂::T) where {T <: Integer, T1}
  (1 ≤ v₁ ≤ v(g) && 1 ≤ v₂ ≤ v(g)) ||
    throw(ArgumentError("at least one of given vertex $(v₁) or $(v₂) is not defined in current digraph"))
end

function check_negative_cycle(fwapsp::FWAPSP{T, T1}) where {T <: Integer, T1}
  has_negative_cycle(fwapsp) && throw(ArgumentError("Negative cycle detected"))
end

## in the following x, y are defined over T1
eq(x, y, ::Type{Int32}) = x == y
eq(x, y, ::Type{Int64}) = x == y
eq(x, y, ::Type{Float32}) = x ≈ y
eq(x, y, ::Type{Float64}) = x ≈ y
