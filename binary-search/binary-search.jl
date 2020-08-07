"""
Binary Search (Assume array sorted, but can be in reverse order)

Assume elem can be ∈ array multiple times
"""
function binarysearch(ary::Vector{T}, elem::T;
                      by=identity, lt=isless, rev::Bool=false,) where T

  # empty array case
  isempty(ary) && return 1:0

  # 1-length array
  n = length(ary)
  n == 1 && ary[1] == elem && return 1:1

  # apply transfo.
  n_ary = sort(ary, by=by, rev=rev, lt=lt)

  # edge cases
  elem < n_ary[1] && return 1:0
  elem > n_ary[end] && return n+1:n

  # general case
  l, r = 1, n
  found, m = false, -1

  while l ≤ r
    m = div(l + r, 2)

    if elem < n_ary[m]
      r = m - 1

    elseif elem > n_ary[m]
      l = m + 1

    else
      found = true  # value is m
      break
    end
  end

  # return found ? (m:m) : (m:m-1) # if elem ∈ ary onl;y once
  if found
    lx = m
    m > l && (lx = find_others(n_ary, elem, lx, l, lt = <, inc=-1))
    rx = m
    m < r && (rx = find_others(n_ary, elem, rx, r, lt = >, inc=1))

    lx:rx
  else
    m:m-1
  end
end

function find_others(ary::Vector{T}, elem::T, ix::Int, n::Int;
                     lt=<, inc::Int=1) where T
  while elem == ary[ix]
    ix += inc
    lt(ix, n) && break
  end
  ix -= inc
end
