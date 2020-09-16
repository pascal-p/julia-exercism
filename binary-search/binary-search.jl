"""
Binary Search (Assume array sorted, but can be in reverse order)

Assume elem can be ∈ array multiple times
"""
function binarysearch(ary::Vector{T}, elem::T;
                      by=identity, lt=isless, rev::Bool=false, all::Bool=false,) where T

  # empty array case
  isempty(ary) && return 1:0

  # 1-length array
  n = length(ary)
  n == 1 && ary[1] == elem && return 1:1

  # apply transfo.
  n_ary = rev ? sort(ary, by=by, rev=rev, lt=lt) : ary

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

  if all       ## return all occurences
    if found
      lx = m
      m > l && (lx = find_others(n_ary, elem, lx, l))
      rx = m
      m < r && (rx = find_others(n_ary, elem, rx, r, cmp=isgreater, inc=1))

      (lx:rx)
    else
      (m:m-1)
    end
  else
    return found ? (m:m) : (m:m-1)
  end
end

function find_others(ary::Vector{T}, elem::T, ix::Integer, n::Integer;
                     cmp=isless, inc::Integer=-1) where T
  while elem == ary[ix]
    ix += inc
    cmp(ix, n) && break
  end
  ix -= inc
end

isgreater(x::T, y::T) where T = x > y
