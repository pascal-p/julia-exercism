const VReal{T} = Vector{T} where T <: Real

"""
   counting_inversions(v::VReal)::Tuple{Integer}

input: v array of `Julia` Real number in a random order
output: the resulting sorted array and the number of inversions

The running time of this algorithm (using Gauss trick 3 mult. instead of 4) can be found
by using the Master Method (parameterized by 3 var. a, b and d) as follows:
  - a = 3 (number of recursive calls or sub-problems)
  - b = 2 (each sub-problems is half the size of the original one)
    d = 1 (outside the rec. call we need to do some adds and subs, this is done in linear time)

Therefore  a (= 3) > bᵈ (= 2)  => Running time is:
  O(n^(log₂(3))) ≈ O(n¹.⁵⁸)
"""

function counting_inversions(v::VReal)::Tuple{VReal, Integer}
  vlen = length(v)

  function sort_and_count(v::VReal)::Tuple{VReal, Integer}
    n = length(v)
    n ≤ 1 && return(v, 0)

    ## define limits for sub-arrays (high, low / left, right)
    n₂ = n ÷ 2
    low_lix, high_rix = 1, n
    high_lix, low_rix = n₂, n₂ + 1

    (c, l_inv_cnt) = sort_and_count(v[low_lix:high_lix])
    (d, r_inv_cnt) = sort_and_count(v[low_rix:high_rix])
    (b, shift_inv_cnt) = merge_and_count(c, d)

    (b, l_inv_cnt + r_inv_cnt + shift_inv_cnt)
  end

  (nv, num_inv) = sort_and_count(v)
  @assert vlen == length(nv) "input array $(v), and resulting array $(nv) should have same length"
  (nv, num_inv)
end

function counting_inversions(v::Any)::Tuple{Any, Integer}
  length(v) == 0 && return (v, 0)

  throw(ArgumentError("$(typeof(v)) not managed yet..."))
end

function merge_and_count(vl::VReal, vr::VReal)::Tuple{VReal, Integer}
  vl_lim, vr_lim = length(vl), length(vr)
  kx, ix, jx, num_inv = 1, 1, 1, 0
  v = VReal{eltype(vl)}(undef, vl_lim + vr_lim)

  ## Merge vl, vr => v
  for k ∈ 1:(vl_lim + vr_lim)
    if ix > vl_lim || jx > vr_lim
      kx = k
      break
    end

    if vl[ix] ≤ vr[jx]
      v[k] = vl[ix]
      ix += 1
    else
      v[k] = vr[jx]
      jx += 1
      num_inv += vl_lim - ix + 1
    end
  end

  ## Copy remaining elements of c into b (if any)
  if ix ≤ vl_lim
    l_ix = kx + vl_lim - ix
    v[kx:l_ix] = vl[ix:end]
    kx = l_ix + 1
  end

  ## Copy remaining elements of d into b (if any)
  if jx ≤ vr_lim
    l_jx = kx + vr_lim - jx
    v[kx:l_jx] = vr[jx:end]
    kx = l_jx + 1 # one(TIn)  # not necessary (because nothing more to do), just
    # for the sake of symmetry, however if we were to permute this block with
    # previous one, this would become necessary.
  end

  (v, num_inv)
end
