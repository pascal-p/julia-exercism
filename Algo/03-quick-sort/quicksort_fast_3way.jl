using Random

const VT = Vector{<: Real}
const TI = Integer

"""
  quick_sort!(v; ...)

QuickSort with Fast 3-way partitioning. [Bentley, McIlroy]

Implement fast 3-way partitioning [Bentley, MacIlroy]
     before:
| v | ... |   |
l   |     |   r

     during
| = v | <v |  ...  | > v | = v |
|l    px   ix      jx    q     r

| = v | <v     |      > v | = v |
|l    px     jx ix      q |     r

     end
| <v | = v | > v |
l    |     |     h

l, r: left and right ends
a[l, p - 1], a[q + 1, r] == pivot (=a[l])
a[p..ix - 1] < pivot && a[jx..q] > pivot  (pivot == a[l])

"""
function quick_sort!(v; shuffle=true, pivot=:first)
  length(v) ≤ 1 && return v
  length(v) == 2 && return v[2] < v[1] ? [v[2], v[1]] : v

  function qsort!(v::VT, l::TI, r::TI)
    r ≤ l && return

    ix = choose_pivot(v, l, r, pivot)
    v[l], v[ix] = v[ix], v[l]

    lx, rx = partition(v, l, r)
    qsort!(v, l, lx)
    qsort!(v, rx, r)
  end

  shuffle && Random.shuffle!(v)
  qsort!(v, 1, length(v))
  v
end

function partition(v::VT, l::TI, r::TI)
  ix, jx = l, r + 1
  p, q = l + 1, r
  pivot = v[l]

  while true
    ix += 1
    while v[ix] ≤ pivot
      ix == r && break
      if v[ix] == pivot && ix < jx
        v[ix], v[p] = v[p], v[ix]
        p += 1
      end
      ix += 1
    end

    jx -= 1
    while v[jx] ≥ pivot
      jx == l && break
      if pivot == v[jx] && jx > ix
        v[jx], v[q] = v[q], v[jx]
        q -= 1
      end
      jx -= 1
    end

    ## scan completed
    ix ≥ jx && break

    ## otherwise swap
    v[ix], v[jx] = v[jx], v[ix]
  end

  ## swap pivots: a[l..p-1] with a[p..jx] (if necessary)
  if l ≤ p ≤ jx
    lix = l
    for kx ∈ jx:-1:(jx - (p - l) + 1)
      v[kx], v[lix] = v[lix], v[kx]
      lix += 1
    end
    jx = p == l + 1 ? jx - 1 : jx - (p - l)
  end

  ## swap pivots: a[q+1..r] with a[ix..q] (if necessary)
  if r > q ≥ ix
    rix = r
    for kx ∈ ix:(ix + (r - q) - 1)
      v[kx], v[rix] = v[rix], v[kx]
      rix -= 1
    end
    ix = q == r ? ix + 1 : ix + (r - q)
  end

  jx, ix
end

function choose_pivot(v::VT, l::TI, r::TI, pivot::Symbol)
  if pivot == :first
    l
  elseif pivot == :last
    r
  elseif pivot == :median3
    median_3(v, l, r)
  else
    throw(ArgumentError("option not managed yet"))
  end
end

function median_3(v::VT, l::TI, r::TI)
  s =  (r - l + 1)
  m = s % 2 == 0 ? s ÷ 2 : ceil(Int, s / 2)
  x, y, z = v[l], v[m], v[r]

  if x < y
    y < z && return m # y
    x < z && return r # z, y ≥ z && y > x
    return l          # x
  end
  # x ≥ y
  y > z && return m # y
  x < z && return l # x,  y ≤ z
  return r          # z
end
