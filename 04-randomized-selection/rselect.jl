
"""
  rselect(a., ith)

  Randomized Selection - find i-th statistic in linear time, based on quicksort
"""

function rselect(a, ith; pivot="median-3")
  length(a) == 0 && return nothing
  (ith < 0 || ith > length(a)) && return nothing
  
  function _search(a, l, r, ith)
    l == r && return a[l]

    ip = choose_pivot(a, l, r, pivot)
    p = a[ip]
    a[l], a[ip] = a[ip], a[l]  # move pivot in first pos. (at index l)
    jx = partition(a, l, r)

    if jx == ith
      return p
    elseif jx > ith
      _search(a, l, jx - 1, ith)
    else
      # jx < ith
      _search(a, jx + 1, r, ith)
    end
  end

  return _search(a, 1, length(a), ith) 
end


#
# from quisksort
#

function choose_pivot(a, l, r, pivot)
  if pivot == "first"
    l
  elseif pivot == "last"
    r
  elseif pivot == "random"
    rand(l:r)
  elseif pivot == "median-3"
    median_3(a, l, r)
  else
    throw(ArgumentError("option not managed yet"))
  end
end

function partition(a, l, r)
  pivot = a[l]
  ix = l + 1

  for jx in (l + 1):r
    if a[jx] < pivot
      a[jx], a[ix] = a[ix], a[jx]
      ix += 1
    end
  end

  ix -= 1
  a[l], a[ix] = a[ix], a[l] # move pivot to its final place in sorted array
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
