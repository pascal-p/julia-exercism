#
# minheap property: a key at a parent level is ≤ the keys at children level
# maxheap property: a key at a parent level is ≥ the keys at children level
#

import Base: isempty, size, length, insert!, peek, delete!

abstract type AbsHeap end
abstract type MinHeap <: AbsHeap end
abstract type MaxHeap <: AbsHeap end

mutable struct Heap{T} <: AbsHeap
  h::Vector{T}
  last::Int                  ## index to next free position in the heap
  klass::DataType            ## MinHeap or MaxHeap

  function Heap{T}(n::Int=4; klass=MinHeap) where T
    @assert klass == MinHeap || klass == MaxHeap "Either MaxHeap xor MaxHeap"
    self = new(zeros(T, n), 1, klass)
  end
end


"""
  length
    - Current number of items in the heap
"""
function length(self::Heap{T})::Int where T
  self.last - 1
end

"""
  size
    - Current (Allocated) size of the heap
"""
function size(self::Heap{T})::Int where T
  length(self.h)
end

function isempty(self::Heap{T})::Bool where T
  length(self.last) == 1
end

function peek(self::Heap{T})::T where T
  self.last ≤ 1 && throw(ArgumentError("empty heap!"))
  self.h[1]
end

function insert!(self::Heap{T}, k::T) where T
  self.last > size(self) && _resize!(self)

  ## 1 - Stick the new object at the end of the heap and incr. the heap size.
  self.h[self.last] = k
  self.last += 1

  ## 2 - Buble-up (swap) repeatedly until heap property is restored
  _buble_up!(self.klass, self)
end

extract_min!(self::Heap{T}) where T = _extract(self; cmp=(>))

extract_max!(self::Heap{T}) where T = _extract(self; cmp=(<))

function heapify!(self::Heap{T}, a::Vector{T}) where T
  n = length(a)
  self.h, self.last = a, n + 1
  for k in n ÷ 2:-1:1
    _buble_down!(self.klass, self, k)
  end
end

function delete!(self::Heap{T}, k::T)::T where T
  ## 0 - empty?
  self.last ≤ 1 && throw(ArgumentError("empty heap!"))
  k ≤ 1 || k > self.last - 1 && throw(ArgumentError("no such element in the heap!"))

  ## 1 - find element k in heap - trivial as k is the index
  ## delete => replace deleted value with last item in the heap
  ## decr last
  item = self.h[k]
  self.h[k] = self.h[self.last - 1]
  self.last -= 1

  ## 2 - buble-down
  _buble_down!(self.klass, self, k)

  return item
end

#
# Internal
#

function _extract(self::Heap{T}; cmp=self.klass == MinHeap ? (>) : (<))::T where T
  ## 0. check
  self.last ≤ 1 && throw(ArgumentError("empty heap!"))
  self.last < (size(self) ÷ 2) && _resize!(self; incr=false)

  root = self.h[1]

  ## 1 - Overwrite the root with the last object x in the heap, and decrement the heap size.
  self.h[1] = self.h[self.last - 1]
  self.last -= 1

  ## 2 - Buble-down (swap) x repeatedly with its smaller child until the
  # heap property is restored.
  _buble_down!(self.klass, self, 1)

  return root
end

#
# Using code generation to build the specialized version depending on Heap type (whether MinHeap or MaxHeap)
#
for (klass, op) in ((MaxHeap , <), (MinHeap, >))

  @eval begin
    function _buble_up!(::Type{$(klass)}, self::Heap{T}) where T
      k = self.last - 1

      while k > 1
        j = k ÷ 2

        ($(op))(self.h[k], self.h[j]) && break
        self.h[k], self.h[j] = self.h[j], self.h[k]

        k = j
      end
    end

    function _buble_down!(::Type{$(klass)}, self::Heap{T}, k::T) where T
      n = self.last - 1

      while 2k ≤ n
        j = 2k                                                 ## first child position
        j < n && ($(op))(self.h[j], self.h[j + 1]) && (j += 1) ## move to 2nd child if necessary
        !($(op))(self.h[k], self.h[j]) && break                ## we are done

        self.h[k], self.h[j] = self.h[j], self.h[k]            ## exchange
        k = j
      end
    end

  end # end of @eval

end

function _resize!(self::Heap{T}; incr=true) where T
  n = size(self)
  nsize = incr ? 2n : floor(Int, n * 0.75)
  c_size = min(n, nsize)
  new_heap = Heap{T}(nsize)
  last = self.last
  copyto!(new_heap.h, self.h[1:c_size])
  self.h, self.last = new_heap.h, last
end
