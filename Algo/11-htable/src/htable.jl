## hash chaining

import Base: isempty, show, get, size

const A = (√5 - 1) / 2
const LOAD_FACT = 0.8

mutable struct HTable{T1, T2}
  n::Integer               ## number of bucket
  size::Integer
  v::Vector{SLList{T2}}

  function HTable{T1, T2}(n::Integer) where {T1, T2}
    @assert n > 0
    self = new(n, 0)
    init_vector!(self)   # better way?
    self
  end
end

size(ht::HTable{T1, T2}) where {T1, T2} = ht.size
isempty(ht::HTable{T1, T2}) where {T1, T2} = ht.size == 0

function show(io::IO, ht::HTable{T1, T2}) where {T1, T2}
  if isempty(ht)
    print(io, "{}")
  else
    print(io, "{")
    for ix in 1:ht.n, l in ht.v[ix]
      !isempty(l) && Base.show(io, l)  ## delegate to SLList show
    end
    print(io, "}")
  end
end

function get(ht::HTable{T1, T2}, key::T1) where {T1<:Integer, T2}
  _ix, lst = _get(ht, key)
  isempty(lst) && return nothing

  head = car(lst)
  if length(head) > 1
    for (k, v) in lst      ## pair <key, value>
      k == key && return v
    end
  else
    for k in lst  ## only a key
      k == key && return k
    end
  end

  return nothing
end

function add!(ht::HTable{T1, T2}, key::T1, val) where {T1<:Integer, T2}
  ix, lst = _get(ht, key)

  ## Check if <key, value> already present
  for p in lst  ## pair <key, value>
    p[1] == key && p[2] == val && return
  end

  ## now we can insert into lst
  ht.v[ix] = cons((key, val), ht.v[ix])
  ht.size += 1

  ht.size / ht.n ≥ LOAD_FACT && _realloc!(ht)
end

function add!(ht::HTable{T, T}, key::T) where {T}
  ix, lst = _get(ht, key)

  ## Check if key already present
  for k in lst; k == key && return; end

  ## now we can insert into lst
  ht.v[ix] = cons(key, ht.v[ix])
  ht.size += 1

  ht.size / ht.n ≥ LOAD_FACT && _realloc!(ht)
end

function remove!(ht::HTable{T1, T2}, key::T1) where {T1<:Integer, T2}
  ix, lst = _get(ht, key)
  sz = length(lst)

  lst = filter(p -> p[1] != key, lst)
  nsz = length(lst)

  if nsz < sz       ## actual deletion
    ht.v[ix] = lst
    ht.size -= 1
  end
end

#
# Internal
#

function init_vector!(ht::HTable{T1, T2}) where {T1<:Integer, T2}
  ht.v = Vector{SLList{T2}}(undef, ht.n)
  fill!(ht.v, nil(T2))
end

function init_vector!(v::Vector{SLList{T2}}) where {T2}
  fill!(v, nil(T2))
end

"""
  Using multiplication method (good for Integer key)
    hash_fn(k) = floor(Integer, n × (key × A) mod 1)
"""
function hash_fn(ht::HTable{T1, T2}, key::T1)::Integer where {T1<:Integer, T2}
  n = ht.n
  # hum... key and -key => same index
  floor(Integer, n * abs(key * A % 1)) + 1 # [1..n]
end

"""
 _get(ht, key)
   returns <bucket index, bucket> associated with key
"""
function _get(ht::HTable{T1, T2}, key::T1) where {T1<:Integer, T2}
  ix = hash_fn(ht, key)
  (ix, ht.v[ix])
end

function _realloc!(ht::HTable{T1, T2}) where {T1<:Integer, T2}
  n = ht.n                    ## init. size
  ht.n *= 2                   ## double ht size
  v = init_vector!(Vector{SLList{T2}}(undef, ht.n))
  _copy!(ht, v, n)
end

function _copy!(ht::HTable{T1, T2}, vec::Vector{SLList{T2}}, n::Integer) where {T1<:Integer, T2}
  for ix in 1:n
    if ht.v[ix] != nil()      ## we have 'values' here - copy them

      head = car(ht.v[ix])
      if length(head) > 1     ## tuple <key, value>
        for (k, v) in ht.v[ix]
          jx = hash_fn(ht, k) # (jx,) = _get(ht, k)  ## calc. new hash
          vec[jx] = cons((k, v), vec[jx])
        end
      else                    ## only a key...
        for k in ht.v[ix]
          jx = hash_fn(ht, k) # (jx,) = _get(ht, k)  ## calc. new hash
          vec[jx] = cons(k, vec[jx])
        end
      end

    end
  end

  ht.v = vec
end
