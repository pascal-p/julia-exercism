push!(LOAD_PATH, "../08-heap-adt/lib")
using YAH

const MOD = 10_000 # only the last 4 digits

"""
  Compute the "rolling" median of a stream of digits in logarithmic time per round.

  The key idea is to use 2 heaps (minheap, maxheap) and maintain 2 invariants:

  (i) minheap, maxheap are balanced containing the same number of elements (after an
  even round) or one is containing 1 more element than the other (odd round)

  (ii) minheap, maxheap are ordered - ∀ x ∈ maxheap and ∀ y ∈ minheap => x ≤ y (yes)

  minheap, maxheap stay balanced after an element (x) is inserted in all but one case:
  In an even round 2k, if x is inserted into the bigger heap (with k elements), this heap
  will contain k + 1 elements while the other contains only k - 1 elements
  In this case we need to rebalance by extracting the maximum or minimum element from
  maxheap  or minheap (respectively, whichever contains more elements), and re-insert
  this element into the other heap.

  Here we make us of our custom implementation of heaps (module YAH)
"""

function median_maint(infile::String; with_medians=false)
  ary = []
  try
    open(infile, "r") do fh
      ary = [parse(Int, line) for line in eachline(fh)]
    end
    median_maint(ary; with_medians=with_medians)

  catch err
    println("Error: $(typeof(err))...")
  end
end

function median_maint(v::Vector{Int}; with_medians=false)
  n = 10  ## pre-alloc
  min_heap = Heap{Int}(n)
  max_heap = Heap{Int}(n; klass=MaxHeap)
  median_calc(v, min_heap, max_heap; with_medians=with_medians)
end

function median_calc(v::Vector{Int}, min_heap, max_heap; with_medians=false)
  medians = with_medians ? Dict{Int, Int}() : Nothing

  cmed = with_medians ? init_median(v, min_heap, max_heap, medians) :
    init_median(v, min_heap, max_heap)

  for (ix, x) in enumerate(v[3:end])
    min, max = peek(min_heap), peek(max_heap)

    if x < max
      insert!(max_heap, x)
    elseif x > min
      insert!(min_heap, x)
    else
      length(min_heap) < length(max_heap) ? insert!(min_heap, x) :
        insert!(max_heap, x)
    end

    ix % 2 == 0 && rebalance!(min_heap, max_heap)
    median = fetch_median(ix, min_heap, max_heap)

    ## update median
    with_medians && (medians[median] = get(medians, median, 0) + 1)
    cmed += median
  end

  last4digits = cmed % MOD
  with_medians ? (last4digits, sort(collect(medians))) : (last4digits, )
end

function init_median(v, min_heap, max_heap)
  x, y = v[1], v[2]
  if x > y
    insert!(min_heap, x)
    insert!(max_heap, y)
    x + y
  else
                          # x ≤ y
    insert!(max_heap, x)
    insert!(min_heap, y)
    2x
  end
end

function init_median(v, min_heap, max_heap, medians)
  x, y = v[1], v[2]
  if x > y
    insert!(min_heap, x)
    insert!(max_heap, y)
    medians[x] = 1
    medians[y] = 1
    x + y
  else                    # x ≤ y
    insert!(max_heap, x)
    insert!(min_heap, y)
    medians[x] = 2        # same median...
    2x
  end
end

function rebalance!(min_heap, max_heap)
  if length(min_heap) - length(max_heap) ≥ 2
    insert!(max_heap,
            extract_min!(min_heap))

  elseif length(max_heap) - length(min_heap) ≥ 2
    insert!(min_heap,
            extract_max!(max_heap))
  end
end

function fetch_median(ix, min_heap, max_heap)
  ix % 2 == 1 ?
    (length(min_heap) < length(max_heap) ? peek(max_heap) : peek(min_heap)) :
    peek(max_heap)
end
