#
# minheap property: a key at a parent level is ≤ the keys at children level
# maxheap property: a key at a parent level is ≥ the keys at children level
#

import Base: isempty, size, length, insert!, peek, delete!

abstract type AbsHeap end
abstract type MinHeap <: AbsHeap end
abstract type MaxHeap <: AbsHeap end

const KV{T1, T2} = NamedTuple{(:key, :value), Tuple{T1, T2}} where {T1, T2}

mutable struct Heap{T1, T2} <: AbsHeap
  h::Vector{KV{T1, T2}}
  last::Int                  ## index to next free position in the heap
  klass::DataType            ## MinHeap or MaxHeap
  map_ix::Dict{T2, Int}      ## keep track of position of kv pair in the heap. Optional

  function Heap{T1, T2}(n::Int=4; klass=MinHeap, with_map=false) where {T1, T2}
    @assert klass == MinHeap || klass == MaxHeap "Either MaxHeap xor MaxHeap"

    v = Vector{KV{T1, T2}}(undef, n)
    self = !with_map ? new(v, 1, klass) : new(v, 1, klass, Dict{T2, Int}())
  end
end

# n = 5
# julia> mheap = Heap{Int, Float64}(n)
# Heap{Int64,Float64}(NamedTuple{(:key, :value),Tuple{Int64,Float64}}[(key = 140134274447856, value = 6.92355308099855e-310), (key = 140134274445168, value = 6.92355308099855e-310), (key = 140134274445168, value = 6.92355308848305e-310), (key = 140134274600272, value = 6.92355538706774e-310), (key = 140134274601488, value = 6.92355538706774e-310)], 1, MinHeap, #undef)
#
# julia> fieldnames(Heap)
# (:h, :last, :klass, :map_ix)
#
# isdefined(mheap, :last)
# true
#
# julia> isdefined(mheap, :map_ix)
# false

"""
  length
Current number of items in the heap
"""
length(self::Heap{T1, T2}) where {T1, T2} = self.last - 1

"""
  size
Current (Allocated) size of the heap
"""
size(self::Heap{T1, T2}) where {T1, T2} = length(self.h)

isempty(self::Heap{T1, T2}) where {T1, T2} = self.last == 1

function peek(self::Heap{T1, T2})::KV{T1, T2} where {T1, T2}
  self.last ≤ 1 && throw(ArgumentError("empty heap!"))
  self.h[1]
end

map_ix(self::Heap{T1, T2}) where {T1, T2} = isdefined(self, :map_ix) ? self.map_ix : nothing

extract_min!(self::Heap{T1, T2}) where {T1, T2} = _extract(self; cmp=(>))
extract_max!(self::Heap{T1, T2}) where {T1, T2} = _extract(self; cmp=(<))

function heapify!(self::Heap{T1, T2}, a::Vector{KV{T1, T2}}) where {T1, T2}
  n = length(a)   # a ≡ vector of pair (key / value)
  ca = Vector{KV{T1, T2}}(undef, n)
  copyto!(ca, a)

  self.h, self.last = ca, n + 1

  if isdefined(self, :map_ix)
    for (ix, (_k, v)) in enumerate(ca)
      self.map_ix[v] = ix
    end
  end

  for k in n ÷ 2:-1:1
    _buble_down!(self.klass, self, k)
  end
end

"""
  insert!(self::Heap{T1, T2}, kv::KV{T1, T2})

insert pair kv into the heap self
"""
function insert!(self::Heap{T1, T2}, kv::KV{T1, T2}) where {T1, T2}
  self.last > size(self) && _resize!(self)

  ## 1 - Stick the new object at the end of the heap and incr. the heap size.
  self.h[self.last] = kv
  isdefined(self, :map_ix) && (self.map_ix[kv.value] = self.last)
  self.last += 1

  ## 2 - Buble-up (swap) repeatedly until heap property is restored
  _buble_up!(self.klass, self)
end

"""
  delete!(self::Heap{T1, T2}, k::T1)

delete key/value pair located at index k in the heap self
"""
function delete!(self::Heap{T1, T2}, k::T1)::KV{T1, T2} where {T1, T2}
  ## 0 - empty?
  self.last ≤ 1 && throw(ArgumentError("empty heap!"))
  k ≤ 1 || k > self.last - 1 &&
    throw(ArgumentError("no such element in the heap! index: $(k) outside range[1, $(self.last - 1)]"))

  ## 1 - find element k in heap - trivial as k is the index
  ## delete => replace deleted value with last item in the heap
  ## decr last
  pair, repl_pair = self.h[k], self.h[self.last - 1]
  self.h[k] = repl_pair

  if isdefined(self, :map_ix)
    ix = self.map_ix[pair.value]
    delete!(self.map_ix, pair.value)
    self.map_ix[repl_pair.value] = ix  ## update this index
  end
  self.last -= 1

  ## 2 - buble-down
  _buble_down!(self.klass, self, k)

  return pair
end

#
# Internal
#

function _extract(self::Heap{T1, T2}; cmp=self.klass == MinHeap ? (>) : (<))::KV{T1, T2} where {T1, T2}
  ## 0. check
  self.last ≤ 1 && throw(ArgumentError("empty heap!"))
  self.last < (size(self) ÷ 2) && _resize!(self; incr=false)

  root = self.h[1]
  isdefined(self, :map_ix) && (delete!(self.map_ix, root.value))

  ## 1 - Overwrite the root with the last object x in the heap, and decrement the heap size.
  pair = self.h[self.last - 1]
  self.h[1] = pair
  isdefined(self, :map_ix) && (self.map_ix[pair.value] = 1)
  self.last -= 1

  ## 2 - Buble-down (swap) x repeatedly with its smaller child until the
  ## heap property is restored.
  _buble_down!(self.klass, self, 1)

  return root
end

##
## Using code generation to build the specialized version depending on Heap type (whether MinHeap or MaxHeap)
##
for (klass, op) in ((MaxHeap , <), (MinHeap, >))

  @eval begin
    function _buble_up!(::Type{$(klass)}, self::Heap{T1, T2}) where {T1, T2}
      k = self.last - 1

      while k > 1
        j = k ÷ 2
        ($(op))(self.h[k].key, self.h[j].key) && break
        swap!(self, k, j)
        k = j
      end
    end

    function _buble_down!(::Type{$(klass)}, self::Heap{T1, T2}, k::T1) where {T1, T2}
      n = self.last - 1

      while 2k ≤ n
        j = 2k                                                 ## first child position
        j < n && ($(op))(self.h[j].key, self.h[j + 1].key) &&
          (j += 1)                                             ## move to 2nd child if necessary
        !($(op))(self.h[k].key, self.h[j].key) && break        ## we are done
        swap!(self, k, j)
        k = j
      end
    end

  end # end of @eval

end

function swap!(self::Heap{T1, T2}, k::Int, j::Int) where {T1, T2}
  if isdefined(self, :map_ix)
    pk, pj = self.h[k], self.h[j]
    self.map_ix[pk.value] = j
    self.map_ix[pj.value] = k
  end

  self.h[k], self.h[j] = self.h[j], self.h[k]
end

function _resize!(self::Heap{T1, T2}; incr=true) where {T1, T2}
  n = size(self)
  nsize = incr ? 2n : floor(Int, n * 0.75)
  c_size = min(n, nsize)
  new_heap = Heap{T1, T2}(nsize)
  last = self.last
  copyto!(new_heap.h, self.h[1:c_size])
  self.h, self.last = new_heap.h, last
end
