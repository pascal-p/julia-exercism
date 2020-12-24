"""
  TSP - Bellman-Held-Karp Algorithm (DP bottom-up version)
"""

##
## distm is the graph representation in matrixrepresentation
## assuming starting at first vertex (1)
##
function tsp(distm::Matrix{T}) where {T <: Real}
  (n, _n) = size(distm)
  a::Matrix{T} = fill(typemax(T), 2^n - 1, n)
  a[1, 1] = zero(T)

  for m in 2:n, (ix, s) in gen_ix_subset(1, n, m)
    for j ∈ s
      j == 1 && continue
      jx = ix - convert2ix(Int[j], n)
      a[ix, j] = minimum([(a[jx, k] < typemax(T) ? a[jx, k] + distm[k, j] : a[jx, k])
                          for k ∈ s if k ≠ j])
    end
  end

  minimum([a[2^n - 1, j] + distm[j, 1] for j in 2:n])
end

"""
  gen_ix_subset

  ex.

  gen_ix_subset(1, 4, 2)
  => [(3, [1, 2]), (5, [1, 3]), (9, [1, 4])]

  gen_subset(1, 4, 3)                                                                                                                                            => [(7, [1, 2, 3]), (11, [1, 2, 4]), (13, [1, 3, 4])]
"""
function gen_ix_subset(low::T, high::T, m::Integer) where {T <: Integer}
  @assert 1 ≤ low ≤ high && m > 0
  a = prepend_all!(low, gen_subset_with_1(low+1, high, m-1))

  ## gen. ix now
  T1 = Tuple{T, Vector{T}}
  a_t, n = Vector{T1}(undef, length(a)), high

  for (ix, da) in enumerate(a)
    a_t[ix] = (convert2ix(da, n), da) # T1(convert2ix(da, n), da)
  end
  a_t
end

function gen_subset_with_1(low::T, high::T, m::Integer) where {T <: Integer}
  m == 1 && (return [T[jx] for jx in low:high])

  a = Vector{T}[]
  for ix in low:high
    ix + 1 > high && continue
    sa = prepend_all!(ix, gen_subset_with_1(ix+1, high, m - 1))
    for _a in sa; push!(a, _a); end
  end

  return a
end

function prepend_all!(x::T, v::Vector{Vector{T}}) where {T <: Integer}
  length(v) == 0 && (return v)
  [pushfirst!(w, x) for w in v]
end

"""
  convert2ix([1,3], 4)
  => 5  # => "0101"
"""
function convert2ix(v::Vector{T}, n::T) where {T <: Integer}
  T1 = UInt8
  a = fill(zero(T1), n)
  for d in v
    a[n - d + 1] = 1
  end
  parse(T, join(a, ""), base=2)
end


"""
  Init
"""
function init_distm(infile::String, DType::DataType)
  vp = load_data(infile, DType)
  calc_dist(vp)
end

"""
  Calc. distm from vector of Points
"""
function calc_dist(vp::Vector{NamedTuple{(:x, :y),Tuple{T, T}}}) where T
  n = length(vp)

  distm = Matrix{T}(undef, n, n)
  for ix in 1:n
    ori = vp[ix]
    for jx in ix+1:n
      dst = vp[jx]
      d = √((ori.x - dst.x)^2 + (ori.y - dst.y)^2)
      distm[ix, jx] = distm[jx, ix] = d
    end
    distm[ix, ix] = zero(T)
  end

  distm
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

      v = Vector{NamedTuple{(:x, :y),Tuple{DType, DType}}}(undef, n)

      for (ix, line) in enumerate(eachline(fh))
        (x, y) = map(s -> parse(DType, strip(s)), split(line, r"\s+"))
        v[ix] = (x=x, y=y)
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
