using Random

const VT = Vector{<: Real}
const TI = Integer

"""
  quick_sort!(v; ...)

Standard quickSort, not dealing with ties
"""
function quick_sort!(v::VT; shuffle=true, cmp_count=false, pivot=:first)
  length(v) ≤ 1 && return v
  length(v) == 2 && return v[2] < v[1] ? [v[2], v[1]] : v

  nb_cmp = 0

  function qsort!(v::VT, l::TI, r::TI)  # closure
    l ≥ r && return

    ip = choose_pivot(v, l, r, pivot)  # return index of chosen pivot
    v[l], v[ip] = v[ip], v[l]          # move pivot in first pos. (at index l)
    ix = partition(v, l, r)
    nb_cmp += r - l
    #
    # There’s no need to count the comparisons one by one. When there is a
    # recursive call on a subarray of length m, you can simply add m - 1 to
    # your running total of comparisons. (Recall that the pivot element is
    # compared to each of the other m - 1 elements in the subarray in this
    # recursive call.)
    #
    qsort!(v, l, ix - 1)
    qsort!(v, ix + 1, r)
  end

  shuffle && Random.shuffle!(v)
  qsort!(v, 1, length(v))
  cmp_count ? (v, nb_cmp) : v
end

function partition(v::VT, l::TI, r::TI)
  pivot = v[l]
  ix = l + 1

  for jx ∈ (l + 1):r
    if v[jx] < pivot
      v[jx], v[ix] = v[ix], v[jx]
      ix += 1
    end
  end

  ix -= 1
  v[l], v[ix] = v[ix], v[l] # move pivot to its final place in sorted array
  ix                        # indice of pivot
end

function choose_pivot(v::VT, l::TI, r::TI, pivot::Symbol)
  if pivot == :first
    l
  elseif pivot == :last
    r
  elseif pivot == :random
    Random.rand(l:r)
  elseif pivot == :median3
    median_3(v, l, r)
  else
    throw(ArgumentError("option not managed yet"))
  end
end

function median_3(v, l::TI, r::TI)
  s =  (r - l + 1)
  m = (l  - 1) + ceil(Int, s / 2)
  x, y, z = v[l], v[m], v[r]
  if x < y
    y ≤ z && return m # y
    x < z && return r # z, y ≥ z && y > x
    return l          # x
  end
  # x ≥ y
  y ≥ z && return m # y
  x < z && return l # x,  y ≤ z
  return r          # z
end
