#
# minheap property: a key at a parent level is ≤ the keys at children level
# maxheap property: a key at a parent level is ≥ the keys at children level
#

# const CHECK_FOR_CORRECTNESS = true

import Base: isempty, size, length, eltype, iterate,
  insert!, peek, delete!

abstract type AbsHeap end
abstract type MinHeap <: AbsHeap end
abstract type MaxHeap <: AbsHeap end

const KV{T1, T2} = NamedTuple{(:key, :value), Tuple{T1, T2}} where {T1, T2}

mutable struct Heap{T1, T2} <: AbsHeap
  h::Vector{KV{T1, T2}}
  last_ix::Int                  ## index to next free position in the heap
  klass::DataType               ## MinHeap or MaxHeap
  map_ix::Dict{KV{T1, T2}, Int}

  function Heap{T1, T2}(n::Int=4; klass=MinHeap) where {T1, T2}
    @assert klass == MinHeap || klass == MaxHeap "Either MinHeap xor MaxHeap"

    v = Vector{KV{T1, T2}}(undef, n)
    new(v, 1, klass, Dict{KV{T1, T2}, Int}())
  end
end


"""
  length
Current number of items in the heap
"""
length(self::Heap{T1, T2}) where {T1, T2} = self.last_ix - 1

eltype(::Heap{T1, T2}) where {T1, T2} = KV{T1, T2}
# both length and eltype useful for iterate()

"""
  size
Current (Allocated) size of the heap
"""
size(self::Heap{T1, T2}) where {T1, T2} = length(self.h)

isempty(self::Heap{T1, T2}) where {T1, T2} = self.last_ix == 1

function peek(self::Heap{T1, T2})::KV{T1, T2} where {T1, T2}
  self.last_ix ≤ 1 && throw(ArgumentError("empty heap!"))
  self.h[1]
end

# map_ix(self::Heap{T1, T2}) where {T1, T2} = isdefined(self, :map_ix) ? self.map_ix : nothing
map_ix(self::Heap{T1, T2}) where {T1, T2} = self.map_ix

extract_min!(self::Heap{T1, T2}) where {T1, T2} = _extract!(self)
extract_max!(self::Heap{T1, T2}) where {T1, T2} = _extract!(self)

function heapify!(self::Heap{T1, T2}, a::Vector{KV{T1, T2}}) where {T1, T2}
  n = length(a)                 ## a ≡ vector of pair (key / value)
  ca = Vector{KV{T1, T2}}(undef, n)
  copyto!(ca, a)

  self.h, self.last_ix = ca, n + 1
  ## update index-
  for (ix, pair) in enumerate(ca); self.map_ix[pair] = ix; end

  for k ∈ n ÷ 2:-1:1; _buble_down!(self.klass, self, k); end
end

"""
  insert!(self::Heap{T1, T2}, kv::KV{T1, T2})

insert pair kv into the heap self
"""
function insert!(self::Heap{T1, T2}, kv::KV{T1, T2}; ignore_presence=false) where {T1, T2}
  self.last_ix > size(self) && _resize!(self)

  ## 1 - Stick the new object at the end of the heap and incr. the heap size. IF NOT ALREADY IN!
  ix = get(self.map_ix, kv, 0)

  if ix > 0
    ignore_presence || println("insert! value already: $(kv) present in heap. Ignoring...")
    return
  end

  self.h[self.last_ix] = kv
  self.map_ix[kv] = self.last_ix  ## update index
  self.last_ix += 1               ## for next insert

  ## 2 - Buble-up (swap) repeatedly until heap property is restored
  _buble_up!(self.klass, self)

  ## 3 - CORRECTNESS test heap property invariant
  # CHECK_FOR_CORRECTNESS && heap_prop_inv(self)
end

"""
  delete!(self::Heap{T1, T2}, k::T1)

delete key/value pair located at index k in the heap self
"""
function delete!(self::Heap{T1, T2}, ix::Int; ignore_absence=false)::Union{KV{T1, T2}, Nothing} where {T1, T2}
  ## 0 - empty?
  self.last_ix ≤ 1 && throw(ArgumentError("empty heap!"))

  if ix < 1 || ix > self.last_ix - 1
    ignore_absence && (return nothing)
    throw(ArgumentError("no such element in the heap! index: $(ix) outside range[1, $(self.last_ix - 1)]"))
  end

  ## 1 - find element ix in heap - trivial as ix is the index
  ## delete => replace deleted value with last item in the heap, decr last
  _delete!(self, ix)
end


"""
  Alternative way of delete the kv-pair

  This one will be O(n) if n is the size of self.h array
"""
function delete!(self::Heap{T1, T2}, kv::KV{T1, T2}; ignore_absence=false)::Union{KV{T1, T2}, Nothing} where {T1, T2}
  ## 0 - empty?
  self.last_ix ≤ 1 && throw(ArgumentError("empty heap!"))

  ## 1 - locate element kv in heap
  ##   delete => replace deleted value with last item in the heap, decr last
  ix = _find(self, kv)

  if ix == -1
    ignore_absence && (return nothing)

    throw(ArgumentError("no such pair $(kv) in the heap!"))
  end

  _delete!(self, ix)
end

function iterate(self::Heap{T1, T2}, state=(self.h[1], 1)) where {T1, T2}
  elem, count = state

  elem === nothing && return nothing
  count ≥ (self.last_ix - 1) && return (elem, (nothing, count))

  (elem, (self.h[count + 1], count + 1))
end


# -------------------------------------------------------------------------------------------------
# Internal
# -------------------------------------------------------------------------------------------------
#

function _extract!(self::Heap{T1, T2})::KV{T1, T2} where {T1, T2}
  ## 0. check
  self.last_ix ≤ 1 && throw(ArgumentError("empty heap!"))
  self.last_ix < (size(self) ÷ 2) && _resize!(self; incr=false)

  root = self.h[1]
  delete!(self.map_ix, root)  ## delete from index

  ## 1 - Overwrite the root with the last object x in the heap, and decrement the heap size.
  pair = self.h[self.last_ix - 1]
  self.h[1] = pair
  self.map_ix[pair] = 1       ## update index accordingly
  self.last_ix -= 1

  ## 2 - Buble-down (swap) x repeatedly with its smaller child until the
  ## heap property is restored.
  _buble_down!(self.klass, self, 1)

  ## 3 - CORRECTNESS - heap property invariant
  # CHECK_FOR_CORRECTNESS && heap_prop_inv(self)

  root
end

##
## Using code generation to build the specialized version depending on Heap type (whether MinHeap or MaxHeap)
##
for (klass, op, nop) ∈ ((MaxHeap, <, ≥), (MinHeap, >, ≤))

  @eval begin
    function _buble_up!(::Type{$(klass)}, self::Heap; k=self.last_ix - 1)
      # function _buble_up!(::Type{$(klass)}, self::Heap{T1, T2}; k=self.last_ix - 1) where {T1, T2}
      while k > 1
        local jx = k ÷ 2
        ($(op))(self.h[k].key, self.h[jx].key) && break  ## heap property holding => done
        _swap!(self, k, jx, "_buble_up!")
        k = jx
      end
    end

    function _buble_down!(::Type{$(klass)}, self::Heap, k::Int)
      # function _buble_down!(::Type{$(klass)}, self::Heap{T1, T2}, k::Int) where {T1, T2}
      local n = self.last_ix - 1 # limit

      while 2k ≤ n
        local jx = 2k                                                 ## first child position
        jx < n && ($(op))(self.h[jx].key, self.h[jx + 1].key) &&
          (jx += 1)                                             ## move to 2nd child if necessary
        ($(nop))(self.h[k].key, self.h[jx].key) && break        ## we are done
        _swap!(self, k, jx, "_buble_down!")
        k = jx
      end
    end
  end # end of @eval

end

function _swap!(self::Heap{T1, T2}, k::Int, j::Int, _lab::String) where {T1, T2}
  k == j && return  # no swap required then

  ## update index
  pk, pj = self.h[k], self.h[j]
  self.map_ix[pk] = j
  # CHECK_FOR_CORRECTNESS && @assert j < self.last "_swap[$(lab)]!: violated assertion j=$(j)/k:$(k) must be < $(self.last - 1) / pj:$(pj) / pk:$(pk) / $(self)"
  self.map_ix[pj] = k
  # CHECK_FOR_CORRECTNESS && @assert k < self.last "_swap[$(lab)]!: violated assertion k=$(k)/j:$(j) must be < $(self.last - 1) / pj:$(pj) / pk:$(pk) / $(self)"

  ## and swap
  self.h[k], self.h[j] = self.h[j], self.h[k]
end

function _resize!(self::Heap{T1, T2}; incr=true) where {T1, T2}
  n = size(self)
  nsize = incr ? 2n : floor(Int, n * 0.75)
  c_size = min(n, nsize)
  new_heap = Heap{T1, T2}(nsize)
  last = self.last_ix
  copyto!(new_heap.h, self.h[1:c_size])
  self.h, self.last_ix = new_heap.h, last
end

function _find(self::Heap{T1, T2}, kv::KV{T1, T2})::Int where {T1, T2}
  jx = -1
  for ix ∈ 1:(self.last_ix - 1)
    (k, v) = self.h[ix]
    if k == kv.key && v == kv.value
      jx = ix
      break
    end
  end
  jx
end

function _delete!(self::Heap{T1, T2}, ix::Int)::KV{T1, T2} where {T1, T2}
  pair = self.h[ix]

  if ix == self.last_ix - 1             ## no replacement to provide as we delete last elemt from heap
    delete!(self.map_ix, pair)       ## no update of any index in map_ix required
    self.last_ix -= 1
    return pair
  end

  repl_pair = self.h[self.last_ix - 1]  ## select replacement pair (from last pos)
  self.h[ix] = repl_pair             ## overwrite at pos. ix [where pair was]
  delete!(self.map_ix, pair)         ## update index by deleting pair from it(index)

  self.map_ix[repl_pair] = ix        ## update this index
  self.last_ix -= 1
  # CHECK_FOR_CORRECTNESS && @assert ix < self.last "_delete!: violated assertion ix $(ix) must be < $(self.last)"

  ## check heap property against parent if possible
  lt = self.klass == MinHeap ? (>) : (<)
  jx = ix ÷ 2

  if jx ≥ 1
    if lt(self.h[jx].key, self.h[ix].key)
      _buble_up!(self.klass, self; k=ix)
    else
      ## check heap property against children if possible
      jx = 2 * ix

      if jx ≤ self.last_ix - 1
        jx < self.last_ix - 1 && lt(self.h[jx].key, self.h[jx + 1].key) && (jx += 1)
        lt(self.h[ix].key, self.h[jx].key) && _buble_down!(self.klass, self, ix)
      end
    end
  else
    _buble_down!(self.klass, self, ix)
  end

  pair
end

function heap_prop_inv(self::Heap{T1, T2}) where {T1, T2}
  lt = self.klass == MinHeap ? (≤) : (≥)

  n = (self.last_ix - 1) ÷ 2
  for ix ∈ 1:n
    jx = ix << 1
    @assert(
      lt(self.h[ix].key, self.h[jx].key),
      "- HEAP Error(1) at ix:$(ix) key:$(self.h[ix]) $(lt) $(self.h[jx]) at jx:$(jx)\n$(self.h[1:(self.last_ix-1)])"
    )
    if jx + 1 < (self.last_ix - 1)
      @assert(
        lt(self.h[ix].key, self.h[jx + 1].key),
        "- HEAP Error(2) at ix:$(ix)  key:$(self.h[ix]) $(lt) $(self.h[jx + 1]) at jx:$(jx+1)\n$(self.h[1:(self.last_ix-1)])"
      )
    end
  end
end
