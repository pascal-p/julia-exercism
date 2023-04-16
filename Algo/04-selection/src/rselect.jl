"""
  rselect(a., ith)

  Randomized Selection - find i-th statistic in linear time, based on quicksort
"""

function rselect(a, ith; pivot=:median3)
  length(a) == 0 && return nothing
  (ith < 0 || ith > length(a)) && return nothing
  _search(a, length(a), ith, pivot)
end

function _search(a, n, ith, pivot)
  n == 1 && return a[1]

  ip = choose_pivot(a, n, pivot)
  p = a[ip]
  a[1], a[ip] = a[ip], a[1]  # move pivot in first pos. (at index l)
  jx = partition(a, n)

  if jx == ith
    return p

  elseif jx > ith
    return _search(a[1:jx - 1], jx - 1, ith, pivot)
  end

  # jx < ith
  _search(a[jx + 1:end], length(a) - jx, ith - jx, pivot)
end

#
# from quicksort
#
function choose_pivot(a, n, pivot)
  pivot == :first && return 1
  pivot == :last && return n
  pivot == :random && return rand(1:n)
  pivot == :median3 && return median3(a, 1, n)

  throw(ArgumentError("option not managed yet"))
end

function partition(a, n)
  pivot, ix = a[1], 2

  for jx ∈ ix:n
    if a[jx] < pivot
      a[jx], a[ix] = a[ix], a[jx]
      ix += 1
    end
  end

  ix -= 1
  a[1], a[ix] = a[ix], a[1] # move pivot to its final place in sorted array
  ix                        # indice of pivot
end

function median3(a, l, r)
  s =  (r - l + 1)
  m = (l  - 1) + ceil(Int, s / 2)
  x, y, z = a[l], a[m], a[r]

  if x < y
    y ≤ z && return m # y
    x < z && return r # z, y ≥ z && y > x
    return l          # x
  end

  # x ≥ y
  y ≥ z && return m # y
  x < z && return l # x,  y ≤ z
  r                 # z
end
