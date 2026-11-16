# Difference Of Squares

Find the difference between the square of the sum and the sum of the squares of the first N natural numbers.

The square of the sum of the first ten natural numbers is
(1 + 2 + ... + 10)² = 55² = 3025.

The sum of the squares of the first ten natural numbers is
1² + 2² + ... + 10² = 385.

Hence the difference between the square of the sum of the first
ten natural numbers and the sum of the squares of the first ten
natural numbers is 3025 - 385 = 2640.

You are not expected to discover an efficient solution to this yourself from
first principles; research is allowed, indeed, encouraged. Finding the best
algorithm for the problem is a key skill in software engineering.

## Source

Problem 6 at Project Euler [http://projecteuler.net/problem=6](http://projecteuler.net/problem=6)

## Lessons Learned
- **Docstring Placement:** Docstrings (`"""..."""`) must appear *above* `function ...`, not inside the function body, so Julia's doc system (`?fn`) attaches them.
- **Multiple Dispatch over Type-Checking Chains:** Replaced manual `typeof(n) ∈ (...)` / `isa` branching in `_promote` with dispatch on `n::Signed` (guarding `n < 0` with `DomainError` and forwarding via `unsigned(n)`) and `n::T where {T<:Union{Unsigned,BigInt}}`.
- **Overflow-Free Widening (`widen`):** Since `square_of_sum(n)` grows as `O(n⁴)`, `W = widen(widen(T))` guarantees enough bits (`UInt8`→`UInt32`, `UInt16`→`UInt64`, `UInt32`→`UInt128`, `UInt64`/`UInt128`/`BigInt`→`BigInt`) without forcing `BigInt` allocations on small types. Halving the even factor of `n * (n + 1)` before multiplying further avoids intermediate overflow.
- **Avoid Abstract Return-Type Annotations:** Omitting `::Integer` on function signatures lets Julia's type inference return the exact concrete type.
- **Decimal Formatting & Interactive Notebook:** `string(n; base = 10)` formats `Unsigned` values in decimal directly (without a `parse(BigInt, ...)` round-trip). Launch the Pluto notebook from `difference-of-squares/` with:
  ```bash
  julia --project=.. -e 'using Pluto; Pluto.run(notebook="./difference-of-squares_pluto.jl")'
  ```

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
It's possible to submit an incomplete solution so you can see how others have completed the exercise.
