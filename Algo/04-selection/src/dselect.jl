"""
  dselect(a., ith)

  Deterministic Selection - find i-th statistic in linear time, based on quicksort
"""
const N_GRP = 5

function dselect(a, ith)
  length(a) == 0 && return nothing
  (ith < 0 || ith > length(a)) && return nothing
  _search(a, length(a), ith)
end

function _search(a, n, ith)
  (n == 1 || ith == 0) && return a[1]

  n₅, r = divrem(n, N_GRP)
  m = r > 0 ? n₅ + 1 : n₅
  c = zeros(eltype(a), m)
  hl, hr = 1, N_GRP
  for h ∈ 1:n₅
    c[h] = _median_of(a, hl, hr)
    hl += N_GRP
    hr += N_GRP
  end
  # last chunk if n not multiple of n_GRP
  r > 0 && (c[m] = _median_of(a, hl, hr - 5 + r))
  p = _search(c, m, n ÷ 10)
  jx = _partition(a, p)

  if jx == ith
    return p
  elseif jx > ith
    return _search(a[1:jx - 1], jx - 1, ith)
  end
  # jx < ith
  _search(a[jx + 1:end], length(a) - jx, ith - jx)
end

function _median_of(a, l, r)
  l < r && _sort!(a, l, r)
  a[(l + r) ÷ 2]
end

function _sort!(a, l, r)
  for ix ∈ l:r
    min, min_ix = a[ix], ix

    for jx ∈ ix+1:r
      if a[jx] < min
        min, min_ix = a[jx], jx
      end
    end

    a[ix], a[min_ix] = a[min_ix], a[ix]
  end
end

#
# from quicksort
#
function _partition(a, pivot)
  ix, jx, ix_p  = 1, length(a), -1

  while ix < jx
    while a[ix] < pivot
      ix ≥ jx && break
      ix += 1
    end

    if a[ix] == pivot
      ix_p = ix
      ix += 1
    end

    while a[jx] > pivot
      # ix ≥ jx && break
      jx -= 1
    end

    ix ≥ jx && break

    a[ix], a[jx] = a[jx], a[ix]
  end

  @assert ix_p ≠ -1 "Expecting pivot index to be defined!"
  a[jx], a[ix_p] = a[ix_p], a[jx]

  jx
end
