# using Random
VT = Vector{T} where T

"""
  MergeSort standard, not dealing with ties
"""
function merge_sort!(a::VT)::VT
  length(a) ≤ 1 && return a

  function _sort(a::VT, l::T, r::T) where T
    l ≥ r && return a[l:r]

    n = r - l + 1
    m = (l + r) ÷ 2

    b = _sort(a, l, m)
    c = _sort(a, m+1, r)

    return merge(b, c)
  end

  return _sort(a, 1, length(a))
end

function merge_sort!(a::Any)
  length(a) == 0 && return a

  # TODO...
  throw(ArgumentError("Not implemented yet"))
end

function merge(b::VT, c::VT)::VT
  ix, jx, kx = 1, 1, 1
  len_b, len_c = length(b), length(c)
  a = Vector{eltype(b)}(undef, len_b + len_c)

  while ix ≤ len_b && jx ≤ len_c
    if b[ix] ≤ c[jx]
      a[kx] = b[ix]
      ix += 1
    else
      a[kx] = c[jx]
      jx += 1
    end
    kx += 1
  end

  # copy remaining elements of b
  if ix ≤ len_b
    l_ix = kx + len_b - ix
    a[kx:l_ix] = b[ix:end]
    kx = l_ix + 1
  end

  # copy remaining elements of c
  if jx ≤ len_c
    l_jx = kx + len_c - jx
    a[kx:l_jx] = c[jx:end]
    kx = l_jx + 1  # not necessary, just for the sake of symmetry
  end

  return a
end
