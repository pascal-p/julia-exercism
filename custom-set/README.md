# Custom Set

Create a custom set type.

Sometimes it is necessary to define a custom data structure of some
type, like a set. In this exercise you will define your own set. How it
works internally doesn't matter, as long as it behaves like a set of
unique elements.

The tests require a constructor that takes an array. The internals of your custom set implementation can use other data structures but you may have to implement an outer constructor that takes exactly one array for the tests to pass.

Certain methods have a unicode operator equivalent. E.g. `intersect(CustomSet([1, 2, 3, 4]), CustomSet([]))` is equivalent to `CustomSet([1, 2, 3, 4]) ∩ CustomSet([])`.

## Lessons learned
- **Extend `Base` Instead of Shadowing:** Explicitly import `Base: copy, union, union!, show` (alongside `==`, `∈`, `intersect`, `intersect!`, `issubset`, `push!`, etc.) so `∪`, `Base.copy`, and REPL `show` dispatch to `CustomSet` (and `Base.∩` works automatically without `const ∩ = intersect`).
- **Avoid Over-Constraining Type Parameters:** Accepting `(s₁::CustomSet, s₂::CustomSet)` and `∈(elt, s::CustomSet)` instead of forcing a shared `{T}` eliminates redundant `CustomSet{Any}` workarounds, keeps `∈` `O(1)` across types, and fixes `disjoint(CustomSet([1]), CustomSet(Int[]))`.
- **`O(n)` Set Equality Without Sorting:** `==(s₁, s₂) = length(s₁) == length(s₂) && issubset(s₁, s₂)` avoids `O(n log n)` `sort`/`collect` allocations and works on unorderable types like `Complex`.
- **No Aliasing & `promote_type`:** Non-mutating operations (`intersect`, `complement`, `union`) must return fresh copies (`copy(s₁)` or a new `CustomSet{promote_type(T1, T2)}()`), never `s₁`/`s₂` directly; `promote_type(Int, Float64) == Float64` avoids abstract `typejoin` (`Real`).
- **Mutating Return-Value Contract:** `push!`, `intersect!`, `complement!`, and `union!` return the mutated set `s₁`, matching Julia `Base` conventions.

## Interactive Notebook
Launch the Pluto notebook from inside `custom-set/`:
```bash
julia --project=.. -e 'using Pluto; Pluto.run(notebook="./custom-set_pluto.jl")'
```

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
It's possible to submit an incomplete solution so you can see how others have completed the exercise.
