# Binary Search

Implement a binary search algorithm.

Searching a sorted collection is a common task. A dictionary is a sorted
list of word definitions. Given a word, one can find its definition. A
telephone book is a sorted list of people's names, addresses, and
telephone numbers. Knowing someone's name allows one to quickly find
their telephone number and address.

If the list to be searched contains more than a few items (a dozen, say)
a binary search will require far fewer comparisons than a linear search,
but it imposes the requirement that the list be sorted.

In computer science, a binary search or half-interval search algorithm
finds the position of a specified input value (the search "key") within
an array sorted by key value.

In each step, the algorithm compares the search key value with the key
value of the middle element of the array.

If the keys match, then a matching element has been found and the range of indices that equal the search key value are returned.

Otherwise, if the search key is less than the middle element's key, then
the algorithm repeats its action on the sub-array to the left of the
middle element or, if the search key is greater, on the sub-array to the
right.

If the remaining array to be searched is empty, then the key cannot be
found in the array and a special "not found" indication is returned. Search methods in Julia typically return an empty range located at the insertion point in this case.

A binary search halves the number of items to check with each iteration,
so locating an item (or determining its absence) takes logarithmic time.
A binary search is a dichotomic divide and conquer search algorithm.

**For simplification, you can assume that all elements of the list to be searched are unique.** Feel free to implement a solution that works on lists with non-unique elements as a bonus task.

## Bonus task
Implement keyword arguments `by`, `lt` and `rev` so that `by` specifies a transformation applied to all elements of the list, `lt` specifies a comparison and `rev` specifies if the list is ordered in reverse.

## Lessons learned
- **Exact Insertion Range (`l:(l-1)`):** When `while l ≤ r` exits without a match, `l == r + 1`, so `l:(l-1)` is always the exact empty insertion range (fixing the off-by-1 bug where `m:(m-1)` failed whenever the final step moved `l = m + 1`, e.g., searching for `5` in `[1, 3, 4, 6, 8, 9, 11]`).
- **Generic Signature (`AbstractVector`, untyped `elem`):** Requiring `Vector{T}, elem::T` or `<:Real` rejects `[]` (`Vector{Any}`), mixed numeric types (`Vector{Float64}` with `Int`), and non-numeric ordered types (`String`, `Date`). Accepting `(ary::AbstractVector, elem; ...)` is both more general and still fully specialized by Julia's compiler.
- **Composing `by`, `lt`, `rev` via a Local Closure:** Defining `is_lt(x, y) = rev ? lt(by(y), by(x)) : lt(by(x), by(y))` inside `binarysearch` captures `by`, `lt`, and `rev` cleanly and replaces `O(n log n)` sorting and raw `<`/`>` checks with a single `O(log n)` comparator.
- **`O(log n)` Duplicate Bounds (`lower_bound` & `upper_bound`):** Replacing the linear `O(k)` scan (`find_others`) with two binary-search passes (`lower_bound` using floor midpoint `lo + (hi - lo) ÷ 2` and `upper_bound` using ceiling midpoint `lo + (hi - lo + 1) ÷ 2` so `lo = mid` always progresses) keeps `all = true` `O(log n)` even with many duplicates and automatically honors `by`/`lt`/`rev`.
- **Debugging in Tests:** `@show l r m` prints variable names and values directly even inside `@testset`.

## Interactive Notebook
Launch the Pluto notebook from inside `binary-search/`:
```bash
julia --project=.. -e 'using Pluto; Pluto.run(notebook="./binary-search_pluto.jl")'
```

## Source

Wikipedia [http://en.wikipedia.org/wiki/Binary_search_algorithm](http://en.wikipedia.org/wiki/Binary_search_algorithm)

Some phrases above and the bonus tasks are taken from the [Julia base documentation (MIT license)](https://docs.julialang.org/en/v1/base/sort/#Base.Sort.searchsorted) of `searchsorted`.

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
It's possible to submit an incomplete solution so you can see how others have completed the exercise.
