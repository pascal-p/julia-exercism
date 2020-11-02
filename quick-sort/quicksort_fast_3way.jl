using Random

"""
  QuickSort with Fast 3-way partitioning. [Bentley, McIlroy]
"""
function quick_sort!(a; shuffle=true, pivot="first")
  length(a) ≤ 1 && return a
  length(a) == 2 &&
    return a[2] < a[1] ? [a[2], a[1]] : a

  function qsort!(a, l, r)
    r ≤ l && return

    ix = choose_pivot(a, l, r, pivot)
    a[l], a[ix] = a[ix], a[l]

    lx, rx = partition(a, l, r)
    qsort!(a, l, lx)
    qsort!(a, rx, r)
  end

  shuffle && Random.shuffle!(a)
  qsort!(a, 1, length(a))
  return a
end

# Implement fast 3-way partitioning [Bentley, MacIlroy]
#      before:
# | v | ... |   |
# l   |     |   r
#
#      during
# | = v | <v |  ...  | > v | = v |
# |l    px   ix      jx    q     r
#
# | = v | <v     |      > v | = v |
# |l    px     jx ix      q |     r
#
#      end
# | <v | = v | > v |
# l    |     |     h
#
# l, r: left and right ends
# a[l, p - 1], a[q + 1, r] == pivot (=a[l])
# a[p..ix - 1] < pivot && a[jx..q] > pivot  (pivot == a[l])
#

function partition(a, l, r)
  ix, jx = l, r + 1
  p, q = l + 1, r
  pivot = a[l]

  while true
    ix += 1
    while a[ix] ≤ pivot
      ix == r && break
      if a[ix] == pivot && ix < jx
        a[ix], a[p] = a[p], a[ix]
        p += 1
      end
      ix += 1
    end

    jx -= 1
    while a[jx] ≥ pivot
      jx == l && break
      if pivot == a[jx] && jx > ix
        a[jx], a[q] = a[q], a[jx]
        q -= 1
      end
      jx -= 1
    end

    ## scan completed
    ix ≥ jx && break

    ## otherwise swap
    a[ix], a[jx] = a[jx], a[ix]
  end

  ## swap pivots: a[l..p-1] with a[p..jx] (if necessary)
  if l ≤ p ≤ jx
    lix = l
    for kx in jx:-1:(jx - (p - l) + 1)
      a[kx], a[lix] = a[lix], a[kx]
      lix += 1
    end
    jx = p == l + 1 ? jx - 1 : jx - (p - l)
  end

  ## swap pivots: a[q+1..r] with a[ix..q] (if necessary)
  if r > q ≥ ix
    rix = r
    for kx in ix:(ix + (r - q) - 1)
      a[kx], a[rix] = a[rix], a[kx]
      rix -= 1
    end
    ix = q == r ? ix + 1 : ix + (r - q)
  end

  return jx, ix
end

function choose_pivot(a, l, r, pivot)
  if pivot == "first"
    l
  elseif pivot == "last"
    r
  elseif pivot == "median-3"
    median_3(a, l, r)
  else
    throw(ArgumentError("option not managed yet"))
  end
end

function median_3(a, l, r)
  s =  (r - l + 1)
  m = s % 2 == 0 ? s ÷ 2 : ceil(Int, s / 2)
  x, y, z = a[l], a[m], a[r]

  if x < y
    y < z && return m # y
    x < z && return r # z, y ≥ z && y > x
    return l # x

  else # x ≥ y
    y > z && return m # y
    x < z && return l # x,  y ≤ z
    return r # z
  end
end
