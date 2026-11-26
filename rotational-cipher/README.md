# Rotational Cipher

Create an implementation of the rotational cipher, also sometimes called the Caesar cipher.

The Caesar cipher is a simple shift cipher that relies on
transposing all the letters in the alphabet using an integer key
between `0` and `26`. Using a key of `0` or `26` will always yield
the same output due to modular arithmetic. The letter is shifted
for as many values as the value of the key.

The general notation for rotational ciphers is `ROT + <key>`.
The most commonly used rotational cipher is `ROT13`.

A `ROT13` on the Latin alphabet would be as follows:

```text
Plain:  abcdefghijklmnopqrstuvwxyz
Cipher: nopqrstuvwxyzabcdefghijklm
```

It is stronger than the Atbash cipher because it has 27 possible keys, and 25 usable keys.

Ciphertext is written out in the same formatting as the input including spaces and punctuation.

## Examples

- ROT5  `omg` gives `trl`
- ROT0  `c` gives `c`
- ROT26 `Cool` gives `Cool`
- ROT13 `The quick brown fox jumps over the lazy dog.` gives `Gur dhvpx oebja sbk whzcf bire gur ynml qbt.`
- ROT13 `Gur dhvpx oebja sbk whzcf bire gur ynml qbt.` gives `The quick brown fox jumps over the lazy dog.`

This is a good exercise to experiment with non-standard string literals and metaprogramming.

A short introduction to non-standard string literals can be found in this [blog post](https://web.archive.org/web/20170625222109/https://iaindunning.com/blog/julia-unicode.html). A detailed metaprogramming guide can be found in the [manual](https://docs.julialang.org/en/v1/manual/metaprogramming/).

You can extend your solution by adding the functionality described below.

Bonus A only requires basics as outlined in the blog post. Bonus B requires significantly more knowledge of metaprogramming in Julia.

## Bonus A
Implement a string literal that acts as `ROT13` on the string:
```julia
R13"abcdefghijklmnopqrstuvwxyz" == "nopqrstuvwxyzabcdefghijklm"
```

## Bonus B
Implement string literals `R<i>`, `i = 0, ..., 26`, that shift the string for `i` values:
```julia
R0"Hello, World!" == "Hello, World!"
R4"Testing 1 2 3 testing" == "Xiwxmrk 1 2 3 xiwxmrk"
R13"abcdefghijklmnopqrstuvwxyz" == "nopqrstuvwxyzabcdefghijklm"
```

## Lessons learned
- **Pass-Through Instead of Allowlists:** Maintaining explicit `Punctuation` and `Digit_As_Char` arrays (and allocating a temporary `Vector` on every character check) rejected valid characters like `-`, `(`, `\t`, `\n`, and Unicode letters (`é`). Any character outside ASCII `'a'..'z'` and `'A'..'Z'` should pass through unchanged.
- **Modular Arithmetic & Overflow (`mod` vs `%`):** In Julia, `%` is truncated remainder (`rem`), so `rotate(-1, 'a')` produced `` '`' `` instead of `'z'`. Reducing the key *first* via `mod(n, 26)` handles negative keys and prevents `Int` overflow on `typemax(Int)` / `typemin(Int)`.
- **Multiple Dispatch & Generic Signatures:** Replacing `rotate(n::Int, src::Union{String,Char})` + `===(typeof(src), Char)` with separate methods on `(::Integer, ::AbstractChar)` and `(::Integer, ::AbstractString)` supports `Int32`, `UInt8`, `SubString`, etc., cleanly.
- **$O(L)$ String Transformation (`map`):** Replacing `foldl` + quadratic `string(s, l)` concatenation with `map(rot_n_maker(n), src)` builds the result in linear time via `Base`'s internal `IOBuffer`.
- **Avoiding `Base` Shadowing:** Renaming helpers from `islowercase`/`isuppercase`/`transcode` to `isasciilower`/`isasciiupper`/`shift_letter` avoids shadowing `Base` exports and makes the ASCII-only predicate explicit (unlike Unicode-aware `Base.islowercase('é') == true`).
- **Module-Scoped Macro Tests:** Checking `isdefined(@__MODULE__, Symbol("@R13_str"))` instead of `Main` ensures Bonus A & B tests execute when `runtests.jl` is evaluated inside a sandbox module.

## Source

Wikipedia [https://en.wikipedia.org/wiki/Caesar_cipher](https://en.wikipedia.org/wiki/Caesar_cipher)

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
It's possible to submit an incomplete solution so you can see how others have completed the exercise.

## Interactive Notebook
Launch the Pluto notebook from inside `rotational-cipher/`:
```bash
julia --project=.. -e 'using Pluto; Pluto.run(notebook="./rotational-cipher_pluto.jl")'
```
