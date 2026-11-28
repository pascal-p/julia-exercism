# Prime Factors

Compute the prime factors of a given natural number.

A prime number is only evenly divisible by itself and 1.

Note that 1 is not a prime number.

## Example

What are the prime factors of 60?

- Our first divisor is 2. 2 goes into 60, leaving 30.
- 2 goes into 30, leaving 15.
  - 2 doesn't go cleanly into 15. So let's move on to our next divisor, 3.
- 3 goes cleanly into 15, leaving 5.
  - 3 does not go cleanly into 5. The next possible factor is 4.
  - 4 does not go cleanly into 5. The next possible factor is 5.
- 5 does go cleanly into 5.
- We're left only with 1, so now, we're done.

Our successful divisors in that computation represent the list of prime
factors of 60: 2, 2, 3, and 5.

You can check this yourself:

- 2 * 2 * 3 * 5
- = 4 * 15
- = 60
- Success!

## Source

The Prime Factors Kata by Uncle Bob [http://butunclebob.com/ArticleS.UncleBob.ThePrimeFactorsKata](http://butunclebob.com/ArticleS.UncleBob.ThePrimeFactorsKata)

## Lessons learned
- **Type Stability & Concrete Containers:** Parameterizing `prime_factors(n::T; ...) where {T<:Integer}` and initializing `divisors = T[]` (instead of `[]` / `Vector{UInt128}` / `::Vector{Integer}` with a `[1]` sentinel and `divisors[2:end]` slice) guarantees a uniform, concrete `Vector{T}` return type across `Int`, `Int32`, `UInt8`, `UInt128`, and `BigInt`.
- **Immutable `Tuple` Constants:** Replacing `Vector{Integer}` constants (`FIRST_PRIMES`, `BASE`, `WHEEL_INC`) with `Tuple`s eliminates element boxing and dynamic dispatch in the inner wheel loop, cutting $2^{128} - 1$ wheel factorization time from ~`0.6s` to ~`0.1s`.
- **Avoiding Captured-Variable Boxing (`Core.Box`):** Passing `n` explicitly into `try_div(n::T, d::T)` and returning the updated `n` (instead of mutating a captured outer `n`) avoids heap-boxing `n` and halved `pf_trial` runtime on $2^{128} - 1$ (`0.7s` → `0.3s`).
- **`BigInt` Compatibility & Overflow Safety:** Removing `Unsigned(n)` (which has no method for `BigInt`) and using `d ≤ n ÷ d` instead of `d * d ≤ n` keeps both algorithms overflow-safe and generic across all `Integer` subtypes.
- **`DomainError(val, msg)` & 1-Based Wraparound:** Passing the offending value first (`DomainError(n, ...)`) populates `err.val` properly; `mod1(ix + 1, lim)` (or `(ix & (lim - 1)) + 1` for power-of-2 `lim`) expresses 1-based cyclic indexing cleanly.

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
It's possible to submit an incomplete solution so you can see how others have completed the exercise.

## Interactive Notebook
Launch the Pluto notebook from inside `prime-factors/`:
```bash
julia --project=.. -e 'using Pluto; Pluto.run(notebook="./prime-factors_pluto.jl")'
```
