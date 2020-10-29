const VReal{T} = Vector{T} where T<: Real

"""
   counting_inversions(a::VReal)::Tuple{Integer}

   input: a array of integer in a random order
   output: sorted array (a sorted) b and the number of inversions
"""

function counting_inversions(a::VReal)::Tuple{VReal, Integer}
  n_a = length(a)

  function sort_and_count(a::VReal)::Tuple{VReal, Integer}
    n = length(a)
    n ≤ 1 && return(a, 0)

    ## define limits for sub-arrays (high, low / left, right)
    n₂ = n ÷ 2
    l_lix, h_rix = 1, n
    h_lix, l_rix = n₂, n₂ + 1

    (c, l_inv_cnt) = sort_and_count(a[l_lix:h_lix])
    (d, r_inv_cnt) = sort_and_count(a[l_rix:h_rix])
    (b, shift_inv_cnt) = merge_and_count(c, d)

    (b, l_inv_cnt + r_inv_cnt + shift_inv_cnt)
  end

  (b, num_inv) = sort_and_count(a)
  @assert n_a == length(b) "input array $(a), and resulting array $(b) should have same length"
  return (b, num_inv)
end

function counting_inversions(a::Any)::Tuple{Any, Integer}
  length(a) == 0 && return (a, 0)

  throw(ArgumentError("$(typeof(a)) not managed yet..."))
end

function merge_and_count(c::VReal, d::VReal)::Tuple{VReal, Integer}
  ix_lim, jx_lim = length(c), length(d)
  kx, ix, jx, num_inv = 1, 1, 1, 0
  b = VReal{eltype(c)}(undef, ix_lim + jx_lim)

  ## merge c, d => b
  for k in 1:(ix_lim + jx_lim)
    if ix > ix_lim || jx > jx_lim
      kx = k
      break
    end

    if c[ix] ≤ d[jx]
      b[k] = c[ix]
      ix += 1
    else
      b[k] = d[jx]
      jx += 1
      num_inv += ix_lim - ix + 1
    end
  end

  ## copy remaining elements of c into b (if any)
  while ix ≤ ix_lim
    b[kx] = c[ix]
    kx += 1
    ix += 1
  end

  ## copy remaining elements of d into b (if any)
  while jx ≤ jx_lim
    b[kx] = d[jx]
    kx += 1
    jx += 1
  end

  (b, num_inv)
end
