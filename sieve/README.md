# Sieve

Use the Sieve of Eratosthenes to find all the primes from 2 up to a given
number.

The Sieve of Eratosthenes is a simple, ancient algorithm for finding all
prime numbers up to any given limit. It does so by iteratively marking as
composite (i.e. not prime) the multiples of each prime, starting with the
multiples of 2. It does not use any division or remainder operation.

Create your range, starting at two and continuing up to and including the given limit. (i.e. [2, limit])

The algorithm consists of repeating the following over and over:

- take the next available unmarked number in your list (it is prime)
- mark all the multiples of that number (they are not prime)

Repeat until you have processed each number in your range.

When the algorithm terminates, all the numbers in the list that have not
been marked are prime.

The wikipedia article has a useful graphic that explains the algorithm:
https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes

Notice that this is a very specific algorithm, and the tests don't check
that you've implemented the algorithm, only that you've come up with the
correct list of primes. A good first test is to check that you do not use
division or remainder operations (div, /, mod or % depending on the
language).

## Source

Sieve of Eratosthenes at Wikipedia [http://en.wikipedia.org/wiki/Sieve_of_Eratosthenes](http://en.wikipedia.org/wiki/Sieve_of_Eratosthenes)

## Lessons Learned
- **Multiple Dispatch & Parametric Types:** Separating `sieve(limit::Signed)` (guarding `limit < 0` and forwarding via `unsigned(limit)`) from `sieve(limit::T) where {T<:Unsigned}` lets one core implementation return `Vector{T}` (`UInt8`–`UInt128`) while still accepting standard `Int` inputs.
- **Type Stability:** Returning `T[]` (not `[]`, which is `Vector{Any}`) keeps the return type `Vector{T}` uniform across all branches.
- **Bit-Packed Storage & Exact Integer Math:** `trues(limit)` uses a `BitVector` (1 bit/element, 8× smaller than `fill(true, limit)`), and `isqrt(limit)` computes the exact integer square root without floating-point `ceil(√limit)`.
- **Eliminating `%` and Redundant Work:** Pre-marking evens (`cprimes[4:2:limit] .= false`) and starting the inner marking at `cand * cand` with step `2 * cand` avoids division/remainder operations (`%`) and skips even multiples.
- **Boundary Behavior (`typemax`):** `StepRange` (`T(3):T(2):limit`) handles `typemax(T)` safely without infinite-loop wraparound (verified up to `typemax(UInt32)` with `SIEVE_FULL_TESTS=true`); `typemax(UInt64)` is bounded by `BitVector` size (`typemax(Int64)`) and RAM rather than arithmetic overflow.


## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
It's possible to submit an incomplete solution so you can see how others have completed the exercise.

<hr />
<p><sub><em>2026 Corto Inc</sub></em></p>
