using Random


"""
  QuickSort standard not dealing with ties 
"""
function quick_sort!(a; shuffle=true, cmp_count=false, pivot="first")
  length(a) ≤ 1 && return a

  length(a) == 2 &&
    return a[2] < a[1] ? [a[2], a[1]] : a

  nb_cmp = 0

  function qsort!(a, l, r)  # closure
    l ≥ r && return

    print()
    ixp = choose_pivot(a, l, r, pivot)
    a[l], a[ixp] = a[ixp], a[l]  # set pivot in first pos.

    jx = partition(a, l, r)
    #
    # There’s no need to count the comparisons one by one. When there is a
    # recursive call on a subarray of length m, you can simply add m - 1 to your running
    # total of comparisons. (Recall that the pivot element is compared to each of the
    # other m - 1 elements in the subarray in this recursive call.)
    #
    qsort!(a, l, jx - 1)
    qsort!(a, jx + 1, r)
    nb_cmp += r - l
  end

  shuffle && Random.shuffle!(a)
  qsort!(a, 1, length(a)) # ; nb_cmp += length(a) - 1
  return cmp_count ? (a, nb_cmp) : a
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
  a[l], a[ix] = a[ix], a[l]
  return ix
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
