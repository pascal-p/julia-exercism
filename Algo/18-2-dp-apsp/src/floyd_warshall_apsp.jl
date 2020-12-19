const EPS = 1e-14

struct FWAPSP{T, T1 <: Real}
  dist_to # ::Matrix{T1, 2}
  path_to # ::Matrix{T, 2}
  g::EWDiGraph{T, T1}

  function FWAPSP{T, T1}(g::EWDiGraph{T, T1}) where {T, T1 <: Real}
    status, dist_to, path_to = shortest_path(g)

    if status == :negative_cycle
      dist_to = Matrix{T1, 2}()
      path_to = Matrix{T, 2}()
    end

    new(dist_to, path_to, g)
  end

  function FWAPSP{T, T1}(infile::String; positive_weight=true) where {T, T1 <: Real}
    g = EWDiGraph{T, T1}(infile; positive_weight)
    FW_APSP(g)
  end
end

##
## Public API
##

function has_negative_cycle(fwapsp::FWAPSP{T, T1})::Bool where {T, T1}
  length(fwapsp.dist_to) == 0 && length(fwapsp.path_to) == 0
end

function min_dist(fwapsp::FWAPSP{T, T1}) where {T, T1}
  check_negative_cycle(fwapsp)

  (n, _n) = size(fwapsp.dist_to)

  ## find min in dist_to matrix, then trcae back path in path_to matrix
  min_val = infinity(T1)
  src, dst = (-1, 11)

  for cix in eachindex(view(fwapsp.dist_to, 1:n, 1:n))  # cartesian indexes
    eq(fwapsp.dist_to[cix], zero(T1)) && continue

    if fwapsp.dist_to[cix] < min_val
      min_val = fwapsp.dist_to[cix]
      (src, dst) = cix
    end
  end

  path = path_to(fwapsp, src, dst)
  (min_val, path)
end

infinity(::Type{Int}) = typemax(Int)
infinity(::Type{Float32}) = typemax(Float32)
infinity(::Type{Float64}) = typemax(Float64)


function dist_to(fwapsp::FWAPSP{T, T1}, src::T, dst::T) where {T, T1}
  check_valid_vertex(fwapsp.g, src, dst)
  check_negative_cycle(fwapsp)

  fwapsp.dist_to[src, dst]
end

function path_to(fwapsp::FWAPSP{T, T1}, src::T, dst::T) where {T, T1}
  check_valid_vertex(fwapsp.g, src, dst)
  check_negative_cycle(fwapsp)

  path, cur = Vector{T}(), src
  println("Start at $(cur) on path to $(src) to $(dst)")
  while cur ≠ dst
    push!(path, cur)
    cur = fwapsp.path_to[cur, dst]
    println("\t$(cur) from fwapsp.path_to[cur: $(cur), dst: $(dst)]")
  end

  path
end

function has_path_to(fwapsp::FWAPSP{T, T1}, src::T, dst::T) where {T, T1}
  check_valid_vertex(fwapsp.g, src, dst)

  fwapsp.dist_to[src, dst] < infinity(T1)
end

##
## Internal Helpers
##

function shortest_path(g::EWDiGraph{T, T1}) where {T, T1 <: Real}
  n = v(g)
  a = Array{T1, 3}(undef, n, n, n)
  a₀ = Matrix{T1}(undef, n, n)
  p = Matrix{T1}(undef, n, n)

  ## base case k ≡ 1
  for v in 1:n, w in 1:n
    if v == w
      a₀[v, w] = zero(T1)
      p[v, w] = infinity(T1)
    else
      (edge_vw, weight_vw) = has_weighted_edge(g, v, w)

      a₀[v, w], p[v, w] = edge_vw ? (weight_vw, w) : (infinity(T1), infinity(T1))
      #                                         v?
    end
  end
  println("Init. routes: $(p)")

  ## systematically solve all subproblems
  k = 1
  for v in 1:n, w in 1:n
    a[k, v, w], update_p = core_calc(a₀[v, w],
                                     a₀[v, k], a₀[k, w])
    update_p && (p[v, w] = 1) # p[v, k]) ## k == 1
    # p[v, w] = update_p ? k : w
  end

  for k in 2:n, v in 1:n, w in 1:n
    a[k, v, w], update_p = core_calc(a[k - 1, v, w],
                                     a[k - 1, v, k], a[k - 1, k, w])
    update_p && (p[v, w] = k) # p[v, k]) # update_p && (p[v, w] = k-1) # p[v, k])  ## shortest path is through k...
    # p[v, w] = update_p ? k : w
  end

  ## Check for negative cycles
  for v in 1:n
    a[n, v, v] < 0 && (return (:negative_cycle, nothing, nothing))
  end

  return (:ok, a[n, 1:end, 1:end], p)
end

function core_calc(a₀::T1, v₁::T1, v₂::T1) where T1
  if v₁ < infinity(T1) && v₂ < infinity(T1)
    b = v₁ + v₂ + (isa(typeof(v₁), AbstractFloat) ? EPS : zero(T1))
    if a₀ < b
     (a₀, false)
    else
     (b, true)  # update p matrix
    end
    # (min(a₀, b), true)
  else
    (a₀, false)
  end
end

function check_valid_vertex(g::EWDiGraph{T, T1}, v₁::T, v₂::T) where {T, T1}
  (1 ≤ v₁ ≤ v(g) && 1 ≤ v₂ ≤ v(g)) ||
    throw(ArgumentError("at least one of given vertex $(v₁) or $(v₂) is not defined in current digraph"))
end

function check_negative_cycle(fwapsp::FWAPSP{T, T1}) where {T, T1}
  has_negative_cycle(fwapsp) && throw(ArgumentError("Negative cycle detected"))
end
