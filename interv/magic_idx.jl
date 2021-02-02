"""
A magic index in a an array A[1..n] is defined to be an index such that
a[i] ≡ i
Given a sorted array of distincvt integers, write a function to find
a magic index, if one exists in array A.

Next: what if the values are not distinct
"""

const NInt = Union{Nothing, Int}

function magic_idx(a::Vector{Int}; first_only=true, no_dup=true) #::NInt
  length(a) == 0 && return nothing

  n = length(a)

  ## 1. pass the negative integers in the array (if array contains such integers)
  jx = 1
  while jx ≤ n
    if a[jx] < 0
      jx += 1
      continue
    end
    break
  end

  ## 2. now we may have situation where i > a[i] => keep looking (no duplicate)
  resp = Int[]

  while jx ≤ n
    if jx == a[jx]
      first_only && return jx
      push!(resp, jx)
    end

    no_dup && jx < a[jx] && break

    jx += 1
  end

  return length(resp) == 0 ? nothing : resp
end
