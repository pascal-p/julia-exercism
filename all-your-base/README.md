# All Your Base

Convert a number, represented as a sequence of digits in one base, to any other base.

Implement general base conversion. Given a number in base **a**,
represented as a sequence of digits, convert it to base **b**.

## Note

- Try to implement the conversion yourself.
  Do not use something else to perform the conversion for you.

## About [Positional Notation](https://en.wikipedia.org/wiki/Positional_notation)

In positional notation, a number in base **b** can be understood as a linear
combination of powers of **b**.

The number 42, *in base 10*, means: `(4 × 10¹) + (2 × 10⁰)`

The number 101010, *in base 2*, means: `(1 × 2⁵) + (0 × 2⁴) + (1 × 2³) + (0 × 2²) + (1 × 2¹) + (0 × 2⁰)`

The number 1120, *in base 3*, means: `(1 × 3³) + (1 × 3²) + (2 × 3¹) + (0 × 3⁰`

I think you got the idea!

*Yes. Those three numbers above are exactly the same. Congratulations!*

## Lessons learned
- **Avoid Type Piracy:** Instead of overriding `Base.zero(::AbstractVector)` to return a scalar, use `zero(T)` / `zero(eltype(digits))`.
- **Overflow-Safe Widening & `Bool <: Integer`:** Accumulating into `(zero ∘ widen)(T)` prevents `Int64` overflow on long digit vectors (`Int64 → Int128`, `UInt64 → UInt128`, `UInt128 → BigInt`). Because `Bool` is the only `Integer` subtype in Julia `Base` without `widen(Bool)`, dispatching `all_your_base(::AbstractVector{Bool}, ...)` to throw `ArgumentError` avoids `try/catch` in `decode`.
- **No Floating-Point `log`:** Using `Base.ndigits(number; base = base_out)` + `divrem` (or `reverse!(Base.digits(T, number; base = base_out))`) avoids floating-point rounding bugs and `try/catch`.
- **Zero-Cost Strategy Dispatch:** Singleton structs (`Imperative <: Style`, `Functional <: Style`) let `all_your_base(...; style = Imperative())` dispatch between imperative (`for`/`while` + `divrem`) and functional (`foldl` + `Base.digits`) implementations at compile time.
- **Recursion vs Loops in Julia:** Julia does not guarantee Tail-Call Optimization (TCO); prefer loops or `foldl`/`Base.digits` over linear recursion.

## Interactive Notebook
Launch the Pluto notebook from inside `all-your-base/`:
```bash
julia --project=.. -e 'using Pluto; Pluto.run(notebook="./all-your-base_pluto.jl")'
```

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
It's possible to submit an incomplete solution so you can see how others have completed the exercise.
