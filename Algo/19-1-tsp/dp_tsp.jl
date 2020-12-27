"""
  TSP - Bellman-Held-Karp Algorithm (DP bottom-up version)

Algorithm (a version of Bellman-Held-Karp)

  Using a a 2d-array (Matrix in Julia), indexed by subsets S ⊆ {1, 2, ..., n}
  that contains 1 and destination j ∈ {1, 2, ...n}

  Base case: a[S, 1] = 0   if S = {1}
                     = +∞  otherwise

  Main:
  for m ∈ 2:n                                          # sub-problem size
    ∀ subset S ⊆ {1, 2, ..., n} containing 1, |S| = m  # subset of size m containing 1
      ∀ j ∈ S - {1}
        a{S, j] = min{a[S - {j}, k] + cₖⱼ} ∀ k ∈ S, k ≠ j

  return min{a[{1, 2, ..., n}, j] + cⱼ₁} ∀ j ∈ {2, ..., n}
"""

struct Point{T}
  x::T
  y::T
end

##
## distm is the distance matrix
## assuming starting at first vertex (1)
##
function tsp_m(distm::Matrix{T}) where {T <: Real}
  (n, _n) = size(distm)
  nₓ = 2^(n - 1) - 1
  a::Matrix{T} = fill(inf(T), nₓ, n)

  for j ∈ 2:n                         ## All subsets of size 2, containing 1
    jx = convert2ix(Int[1, j], n)
    a[jx, j] = distm[1, j]
  end

  for m in 3:n
    for (ix, s) in gen_ix_subset(1, n, m), j ∈ s
      j == 1 && continue
      jx = ix - convert2ix(Int[j], n)
      a[ix, j] = minimum([(a[jx, k] < inf(T) ? a[jx, k] + distm[k, j] : a[jx, k])
                          for k ∈ s if k ≠ j])
    end
  end

  minimum([a[nₓ, j] + distm[j, 1] for j in 2:n])
end

##
## with hash instead of matrix
##
function tsp_h(distm::Matrix{T}) where {T <: Real}
  (n, _n) = size(distm)

  a = Dict{Int, Vector{T}}()
  a[1] = fill(inf(T), n)
  a[2^(n - 1) - 1] = fill(inf(T), n)

  for j ∈ 2:n                         ## All subsets of size 2, containing 1
    jx = convert2ix(Int[1, j], n)
    a[jx] = fill(inf(T), n)

    a[jx][j] = distm[1, j]
  end

  keys2del = Vector{T}() ## bookeeping (1)

  for m in 3:n
    for (ix, s) in gen_ix_subset(1, n, m)
      !haskey(a, ix) && (a[ix] = fill(inf(T), n))
      for j ∈ s
        j == 1 && continue

        jx = ix - convert2ix(Int[j], n)
        push!(keys2del, jx)  ## bookeeping (2)

        a[ix][j] = minimum([(a[jx][k] < inf(T) ? a[jx][k] + distm[k, j] : a[jx][k])
                            for k ∈ s if k ≠ j])
      end
    end

    while !isempty(keys2del) ## bookeeping (3)
      delete!(a, pop!(keys2del))
    end
  end

  minimum([a[2^(n - 1) - 1][j] + distm[j, 1] for j in 2:n])
end


"""
  gen_ix_subset(low::T, high::T, m::Integer)

Compute all subsets of size m containing low (≡ 1) and up to high
=> We can omit 1 as it is present in all the subset we generate:


# Examples:
```julia
julia> gen_ix_subset(1, 4, 2)
3-element Array{Tuple{Int64,Array{Int64,1}},1}:
 (1, [1, 2])
 (2, [1, 3])
 (4, [1, 4])

julia> gen_ix_subset(1, 4, 3)
3-element Array{Tuple{Int64,Array{Int64,1}},1}:
 (3, [1, 2, 3])
 (5, [1, 2, 4])
 (6, [1, 3, 4])
```
"""
function gen_ix_subset(low::T, high::T, m::Integer) where {T <: Integer}
  @assert 1 ≤ low ≤ high && m > 0
  # 1 could be made implicit!
  a = prepend_all!(low, gen_subset_with_1(low + 1, high, m - 1))

  ## gen. ix now
  T1 = Tuple{T, Vector{T}}
  a_t, n = Vector{T1}(undef, length(a)), high

  for (ix, da) in enumerate(a)
    a_t[ix] = (convert2ix(da, n), da)
  end
  a_t
end

function gen_subset_with_1(low::T, high::T, m::Integer) where {T <: Integer}
  m == 1 && (return [T[jx] for jx in low:high])

  a = Vector{T}[]
  for ix in low:high
    ix + 1 > high && continue
    sa = prepend_all!(ix, gen_subset_with_1(ix + 1, high, m - 1))
    for _a in sa; push!(a, _a); end
  end

  return a
end

function prepend_all!(x::T, v::Vector{Vector{T}}) where {T <: Integer}
  length(v) == 0 && (return v)
  [pushfirst!(w, x) for w in v]
end

"""
  convert2ix(v::Vector{T}, n::T)

Convert a given set into its binary representation and return the decimal value
...
# Arguments
- `n::T`: the size of the set. (T is an Integer)
- `v`: the vector representing the set of type T element
...

# Principle
|                                  | bitmask | decimal                    |
|----------------------------------+---------+----------------------------|
|                                  |     421 |                            |
|                                  |     432 |                            |
|----------------------------------+---------+----------------------------|
| Consider subset of 1:4 of size 2 |         |                            |
|                                  |         |                            |
| Set [1, 2] can be represented as |     001 | 1 = 0 × 4 + 0 × 2 + 1 × 1  |
| Set [1, 3] can be represented as |     010 | 2 = 0 × 4 + 1 × 2 + 0 × 1  |
| Set [1, 4] can be represented as |     100 | 4 = 1 × 4 + 0 × 2 + 0 × 1  |
|                                  |         |                            |
|----------------------------------+---------+----------------------------|
| Consider subset of 1:4 of size 3 |         |                            |
|                                  |         |                            |
| Set [1, 2, 3] can be ........    |     011 | 3  = 0 × 4 + 1 × 2 + 1 × 1 |
| Set [1, 2, 4] can be ........    |     101 | 5  = 1 × 4 + 0 × 2 + 1 × 1 |
| Set [1, 3, 4] can be ........    |     110 | 6  = 1 × 4 + 1 × 2 + 0 × 1 |
|                                  |         |                            |

# Examples
```julia
julia> convert2ix([1, 3], 4)
2

julia> convert2ix([1, 3, 4], 4)
6
"""
function convert2ix(v::Vector{T}, n::T) where {T <: Integer}
  T1 = UInt8
  a = fill(zero(T1), n - 1)

  if length(v) > 1
    for d in v[2:end]         ## omit 1, it is implicit
      a[n - d + 1] = 1
    end
  elseif length(v) == 1
    a[n - v[1] + 1] = 1
  end
  parse(T, join(a, ""), base=2)
end

"""
  Init
"""
function init_distm(infile::String, DType::DataType; tsp=tsp_m)
  vp = load_data(infile, DType)  ## Vector of points
  calc_dist(vp)
end

"""
For Challenge use specific heuristic.

Plotting the city coordinate shows that the points can be divided into 2 clusters
  - cluster 1: 1-13
  - cluster 2: 12-25
"""
function distm_challenge(infile::String, DType::DataType; tsp=tsp_h)
  vp = load_data(infile, DType)  ## Vector of points

  vp_clu1 = vp[1:13]
  d_clu1 = calc_dist(vp_clu1)
  tsp_clu1 = tsp(d_clu1)      ## compute tsp for 1st cluster

  vp_clu2 = vp[12:25]
  d_clu2 = calc_dist(vp_clu2)
  tsp_clu2 = tsp(d_clu2)      ## compute tsp for 2nd cluster

  tsp_clu1 + tsp_clu2 - 2 * euclidean_dist(vp_clu1[end - 1], vp_clu1[end])
end


"""
Calc. distm from vector of Points
"""
function calc_dist(vp::Vector{Point{T}}) where T
  n = length(vp)
  distm = Matrix{T}(undef, n, n)

  for ix in 1:n
    ori = vp[ix]
    distm[ix, ix] = zero(T)
    for jx in ix+1:n
      distm[ix, jx] = distm[jx, ix] = euclidean_dist(ori, vp[jx])
    end
  end

  distm
end

euclidean_dist(ori::Point{T}, dst::Point{T}) where T = √((ori.x - dst.x)^2 + (ori.y - dst.y)^2)

function round_dist(d::Real, DT::DataType)::Integer
  @assert DT <: Integer
  floor(DT, d)
end

"""
Load data from file
"""
function load_data(infile::String, DType::DataType)
  try
    local v, n
    open(infile, "r") do fh
      for line in eachline(fh)
        n = parse(Int, strip(line))
        break
      end

      v = Vector{Point{DType}}(undef, n)
      for (ix, line) in enumerate(eachline(fh))
        (x, y) = map(s -> parse(DType, strip(s)), split(line, r"\s+"))
        v[ix] = Point(x, y)
      end
    end
    v

  catch err
    if isa(err, ArgumentError)
      println("! Problem with content of file $(infile)")
    elseif isa(err, SystemError)
      println("! Problem opening $(infile) in read mode... Exit")
    else
      println("! Other error: $(err)...")
    end
    exit(1)
  end
end

for DT in (Int32, Int64, Float64, Float32)
  @eval begin
    inf(DT) = typemax(DT)
  end
end
