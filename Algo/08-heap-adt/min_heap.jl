#
# minheap property: a key at a parent level is ≤ the keys at children level
#
import Base: isempty

mutable struct MinHeap{T}
  h::Vector{T}
  last::Int                  # index to next free position in the heap

  function MinHeap{T}(n::Int=4) where T
    self = new(zeros(T, n), 1)
  end

end

function size(self::MinHeap{T})::Int where T
  length(self.h)
end

function isempty(self::MinHeap{T})::Bool where T
  length(self.last) == 1
end

function peek(self::MinHeap{T})::T where T
  self.last ≤ 1 && throw(ArgumentError("empty heap!"))
  self.h[1]
end

function insert!(self::MinHeap{T}, k::T) where T
  self.last > size(self) && resize!(self)

  ## 1 - Stick the new object at the end of the heap and incr. the heap size.
  self.h[self.last] = k
  self.last += 1

  ## 2 - Buble-up (swap) repeatedly until heap property is restored
  buble_up!(self)
end

function extract_min!(self::MinHeap{T})::T where T
  # 0. check
  self.last ≤ 1 && throw(ArgumentError("empty heap!"))
  self.last < (size(self) ÷ 2) && resize!(self; incr=false)

  root = self.h[1]

  # 1 - Overwrite the root with the last object x in the heap, and decrement the heap size.
  self.h[1] = self.h[self.last - 1]
  self.last -= 1

  # 2 - Buble-down (swap) x repeatedly with its smaller child until the
  # heap property is restored.
  buble_down!(self, 1)

  return root
end

function heapify(a::Vector{T}) where T
  n = length(a)
  for k in n ÷ 2:-1:1
    buble_down!(a, k, n)
  end
end

function delete!(self::MinHeap{T}, k::T)::T where T
  # empty?
  self.last ≤ 1 && throw(ArgumentError("empty heap!"))
  k ≤ 1 || k > self.last - 1 && throw(ArgumentError("no such element in the heap!"))

  # find element k in heap - trivial as k is the index
  # delete => replace deleted value with last item in the heap
  # decr last
  item = self.h[k]
  self.h[k] = self.h[self.last - 1]
  self.last -= 1

  # buble-down
  buble_down!(self, k)

  return item
end

#
# Internal
#

function buble_up!(self::MinHeap{T}) where T
  k = self.last - 1

  while k > 1  # TODO: Check!
    j = k ÷ 2

    self.h[k] > self.h[j] && break
    self.h[k], self.h[j] = self.h[j], self.h[k]

    k = j
  end
end

function buble_down!(self::MinHeap{T}, k::T) where T
  n = self.last - 1 # size(self)

  while 2k ≤ n
    j = 2k                                         ## first child position
    j < n && self.h[j] > self.h[j + 1] && (j += 1) ## move to 2nd child if necessary
    self.h[k] < self.h[j] && break                 ## we are done

    self.h[k], self.h[j] = self.h[j], self.h[k]    ## exchange
    k = j
  end
end

function resize!(self::MinHeap{T}; incr=true) where T
  n = size(self)
  nsize = incr ? 2n : floor(Int, n * 0.75)

  c_size = min(n, nsize)

  new_heap = MinHeap{T}(nsize) ## FIXME check for decreasing size

  last = self.last
  copyto!(new_heap.h, self.h[1:c_size])
  self.h = new_heap.h
  self.last = last
end
