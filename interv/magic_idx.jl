"""
A magic index in a an array A[1..n] is defined to be an index such that
a[i] ≡ i
Given a sorted array of distincvt integers, write a function to find
a magic index, if one exists in array A.

Next: what if the values are not distinct
"""

const VInt = Vector{Int}
const NVInt = Union{Nothing, Int, VInt}

"""
  Using binary serach principle
"""
function magic_idx(a::Vector{Int}; first_only=true, no_dup=true)::NVInt
  resp = Int[]

  function _magic_idx(il::Int, ih::Int)::NVInt
    il > ih && (return first_only ? nothing : resp)

    im = (il + ih) ÷ 2

    if im == a[im]
      first_only && return im
      push!(resp, im)
    end

    if no_dup
      im > a[im] && return _magic_idx(im + 1, ih)

      # im < a[im]
      return _magic_idx(il, im - 1)

    else
      r = _magic_idx(im + 1, ih)

      if r != nothing && first_only
        return r
      else
        return _magic_idx(il, im - 1)
      end
    end

  end

  a = _magic_idx(1, length(a))
  return a == nothing ? nothing : (first_only ? a : sort(resp))
end


"""
  Naive way
"""
function magic_idx_bf(a::Vector{Int}; first_only=true, no_dup=true)::NVInt
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
