# using Random
VT = Vector{T} where T
# TIn = UInt

"""
    merge_sort!(v::VT)

Standard mergeSort, not dealing with ties
"""
function merge_sort!(v::VT)::VT
  length(v) ≤ 1 && return v

  function _sort(v::VT, l::T₁, r::T₁) where T₁
    l ≥ r && return v[l:r]
    m = (l + r) ÷ 2
    left, right = _sort(v, l, m), _sort(v, m + 1, r)
    merge(left, right)
  end

  _sort(v, 1, length(v))
end

function merge_sort!(v::Any)
  length(v) == 0 && return v
  # TODO...
  throw(ArgumentError("Not implemented yet"))
end

@inline copy_incr!(v::VT, ov::VT, kx::T₁, ix::T₁) where T₁ = (v[kx] = ov[ix]; ix += 1)

"""
    merge(vl, vr)

Given 2 sorted vectors defined over the same type, returns the merged sorted sequence as a vector over the same type

# Examples
```julia-repl
julia> merge([1, 3, 7, 9], [2, 4, 8])
7-element Vector{Int64}:
 1
 2
 3
 4
 7
 8
 9
```
"""
function merge(vl::VT, vr::VT)::VT
  ix, jx, kx = 1, 1, 1
  len_vl, len_vr = length(vl), length(vr)
  v = Vector{eltype(vl)}(undef, len_vl + len_vr) # Pre-allocate

  # Merge the 2 vectors up to min(len_vl, len_vr)
  while ix ≤ len_vl && jx ≤ len_vr
    if vl[ix] ≤ vr[jx]
      ix = copy_incr!(v, vl, kx, ix)
    else
      jx = copy_incr!(v, vr, kx, jx)
    end
    kx += 1
  end

  # Copy remaining elements of vl
  if ix ≤ len_vl
    l_ix = kx + len_vl - ix
    v[kx:l_ix] = vl[ix:end]
    kx = l_ix + 1
  end

  # Copy remaining elements of vr
  if jx ≤ len_vr
    l_jx = kx + len_vr - jx
    v[kx:l_jx] = vr[jx:end]
    kx = l_jx + 1 # one(TIn)  # not necessary (because nothing more to do), just
    # for the sake of symmetry, however if we were to permute this block with
    # previous one, this would become necessary.
  end

  v
end
