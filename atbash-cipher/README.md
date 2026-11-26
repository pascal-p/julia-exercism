# Atbash Cipher

Create an implementation of the atbash cipher, an ancient encryption system created in the Middle East.

The Atbash cipher is a simple substitution cipher that relies on
transposing all the letters in the alphabet such that the resulting
alphabet is backwards. The first letter is replaced with the last
letter, the second with the second-last, and so on.

An Atbash cipher for the Latin alphabet would be as follows:

```text
Plain:  abcdefghijklmnopqrstuvwxyz
Cipher: zyxwvutsrqponmlkjihgfedcba
```

It is a very weak cipher because it only has one possible key, and it is
a simple monoalphabetic substitution cipher. However, this may not have
been an issue in the cipher's time.

Ciphertext is written out in groups of fixed length, the traditional group size
being 5 letters, and punctuation is excluded. This is to make it harder to guess
things based on word boundaries.

## Examples

- Encoding `test` gives `gvhg`
- Decoding `gvhg` gives `test`
- Decoding `gsvjf rxpyi ldmul cqfnk hlevi gsvoz abwlt` gives `thequickbrownfoxjumpsoverthelazydog`

## Lessons learned
- **Concrete `String` Return via `IOBuffer`:** Previously `foldl` + `init = " "` + `strip(s, ' ')` returned a `SubString{String}` (retaining the padded backing buffer) and did $O(L^2)$ reallocations. Building into `IOBuffer(; sizehint = ncodeunits(plain))` and returning `String(take!(io))` runs in $O(L)$ and returns a concrete `String`.
- **Direct `Char` Predicates Over Per-Char Regex:** Replacing `occursin(r"[a-zA-Z0-9]+", string(ch))` and `collect(input)` with direct `'0' ≤ ch ≤ '9'`, `'a' ≤ ch ≤ 'z'`, `'A' ≤ ch ≤ 'Z'` checks eliminates per-character `String` allocations and regex overhead.
- **Separator-Before-Write Grouping:** Counting only emitted characters and writing `' '` *before* the next character when `group && count > 0 && count % 5 == 0` avoids leading/trailing spaces without needing `strip` or `GROUP_FACT = 5 + 1`.
- **Unicode Operator Gotcha (`≤` vs `⩽`):** Julia defines `≤` (`\le`, U+2264), not `⩽` (`\leqslant`, U+2A7D), which raises `UndefVarError`.
- **Clean Signatures & Docstrings:** Removed the dead `encode_v1` function, omitted abstract `::AbstractString` return annotations, and attached proper `"""..."""` docstrings directly above `encode` and `decode`.

## Source
Wikipedia [http://en.wikipedia.org/wiki/Atbash](http://en.wikipedia.org/wiki/Atbash)

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
It's possible to submit an incomplete solution so you can see how others have completed the exercise.

## Interactive Notebook
Launch the Pluto notebook from inside `atbash-cipher/`:
```bash
julia --project=.. -e 'using Pluto; Pluto.run(notebook="./atbash-cipher_pluto.jl")'
```
