"""
  rselect(a., ith)

  Randomized Selection - find i-th statistic in linear time, based on quicksort
"""

function rselect(a, ith; pivot="median-3")
  length(a) == 0 && return nothing
  (ith < 0 || ith > length(a)) && return nothing

  function _search(a, n, ith)
    n == 1 && return a[1]

    ip = choose_pivot(a, n, pivot)
    p = a[ip]
    a[1], a[ip] = a[ip], a[1]  # move pivot in first pos. (at index l)
    jx = partition(a, n)

    if jx == ith
      return p

    elseif jx > ith
      _search(a[1:jx - 1], jx - 1, ith)

    else  # jx < ith
      _search(a[jx + 1:end], length(a) - jx, ith - jx)
    end
  end

  return _search(a, length(a), ith)
end

#
# from quisksort
#

function choose_pivot(a, n, pivot)
  if pivot == "first"
    l
  elseif pivot == "last"
    r
  elseif pivot == "random"
    rand(1:n)
  elseif pivot == "median-3"
    median_3(a, 1, n)
  else
    throw(ArgumentError("option not managed yet"))
  end
end

function partition(a, n)
  pivot, ix = a[1], 2

  for jx in ix:n
    if a[jx] < pivot
      a[jx], a[ix] = a[ix], a[jx]
      ix += 1
    end
  end

  ix -= 1
  a[1], a[ix] = a[ix], a[1] # move pivot to its final place in sorted array
  return ix                 # indice of pivot
end

function median_3(a, l, r)
  s =  (r - l + 1)
  m = (l  - 1) + ceil(Int, s / 2)
  x, y, z = a[l], a[m], a[r]

  if x < y
    y ≤ z && return m # y
    x < z && return r # z, y ≥ z && y > x
    return l          # x

  else # x ≥ y
    y ≥ z && return m # y
    x < z && return l # x,  y ≤ z
    return r          # z
  end
end
