"""
  HeapSort Implementation

  Using a max heap:
  the keys are stored in an array such that each key (parent level in term of tree)) is
  guaranteed to be larger than (or equal to) the keys at two other specific (children
  level) positions.
"""


"""
  heap_sort!

  As the first phase of a sort, heap construction is a bit counterintuitive, because its goal
  is to produce a heap-ordered result, which has the largest item first in the array (and other
  larger items near the beginning), not at the end, where it is destined to finish!

  Ex:
  using Random; a = rand(1:20, 12)

  initial sequence  : [16, 7, 14, 17, 14, 15, 3, 18, 12, 3, 3, 8]
  heapify conmpleted: [18, 17, 15, 16, 14, 14, 3, 7, 12, 3, 3, 8]
  sort completed:     [3, 3, 3, 7, 8, 12, 14, 14, 15, 16, 17, 18]
"""
function heap_sort!(a::Vector{Int}; opt=:maxheap)
  """in-place mutation"""
  n = length(a)
  n ≤ 1 && return a

  heapify!(a, n, lt=opt == :maxheap ? (<) : (>))

  k = n
  while k > 1
    a[1], a[k] = a[k], a[1]
    k -= 1
    buble_down!(a, 1, k; lt=opt == :maxheap ? (<) : (>))
  end
end

function heap_sort(a::Vector{Int}; opt=:maxheap)
  b = zeros(eltype(a), length(a))
  copyto!(b, a)
  heap_sort!(b; opt=opt)
  b
end

function heap_sort!(a::Vector{Any})
  length(a) ≤ 1 && return a
  throw(ArgumentError("#(eltype(a)) not yet supported..."))
end


##
## Using code generation
##
for op in (<, >)

  @eval begin
    function buble_down!(a::Vector{Int}, k::Int, n::Int; lt=($(op)))  # for multi-dispatch
      ## n == size of the heap (represented by a)
      ## we want to exchange a[k] with max of a[2k], a[2k + 1]
      ## and repeat the process as many time as required.
      ## Worst case, we will reach the leaves where the heap property hold in O(ln₂ n)

      while 2k ≤ n
        j = 2k                                   ## first child position
        j < n && lt(a[j], a[j + 1]) && (j += 1)  ## move to 2nd child if necessary
        !lt(a[k], a[j]) && break                 ## we are done

        a[k], a[j] = a[j], a[k]                  ## exchange
        k = j
      end

      ## assert heap property on a hold
    end

    function heapify!(a::Vector{Int}, n::Int; lt=$(op))
      for k in n ÷ 2:-1:1
        buble_down!(a, k, n; lt=lt)
      end
    end

  end

end

# Note on: heapify!
# src: Algorithms / Princeton / R. Sedgewick

# Proceed from right to left, using buble_down!() to make subheaps as we go.
# Every position in the array is the root of a small subheap; buble_down!() works
# for such subheaps, as well.
# If the two children of a node are heaps, then calling buble_down!() on that node
# makes the subtree rooted at the parent a heap. This process establishes the heap
# order inductively.
# The scan starts halfway back through the array because we can skip the subheaps of size 1.
# The scan ends at position 1, when we finish building the heap with one call to buble_down!().
