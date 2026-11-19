# Allergies

Given a person's allergy score, determine whether or not they're allergic to a given item, and their full list of allergies.

An allergy test produces a single numeric score which contains the
information about all the allergies the person has (that they were
tested for).

The list of items (and their value) that were tested are:

* eggs (1)
* peanuts (2)
* shellfish (4)
* strawberries (8)
* tomatoes (16)
* chocolate (32)
* pollen (64)
* cats (128)

So if Tom is allergic to peanuts and chocolate, he gets a score of 34.

Now, given just that score of 34, your program should be able to say:

- Whether Tom is allergic to any one of those allergens listed above.
- All the allergens Tom is allergic to.

Note: a given score may include allergens **not** listed above (i.e.
allergens that score 256, 512, 1024, etc.).  Your program should
ignore those components of the score.  For example, if the allergy
score is 257, your program should only report the eggs (1) allergy.

## Source

Jumpstart Lab Warm-up [http://jumpstartlab.com](http://jumpstartlab.com)

## Lessons learned
- **Handling Unknown High Bits (`≥ 256`):** Clamping `ix > N ? N : ix` in `next_pow` caused scores like `256` or `257` to be misattributed to `"cats"` (`128`). Masking/reducing `score` modulo `256` (`score % 256` / `score & 0xff`) before decomposing ensures unknown allergen bits (`256`, `512`, ...) are ignored.
- **Boundary Conditions on `score` and `ix`:** Guarding `score < 0` with `DomainError` prevents `log(score)` from failing silently or unexpectedly, and keeping `while ix ≥ 1` ensures the highest known allergen (`128` → `"cats"`, index `N = 8`) is included.
- **Idiomatic Bitwise Rewrite (`NTuple` + `&` + `<<`):** Replacing `Dict` + `KEYS` + `log`/`ceil` with an ordered `NTuple{8,String}` and bitwise testing (`!iszero(score & (1 << (ix - 1)))`) inside a `Set{String}` generator eliminates `next_pow`, guarantees type stability (`Set{String}`), and ignores bits `≥ 256` automatically.
- **Zero-Allocation `allergic_to`:** Using `findfirst(==(allergen), ALLERGENS)` and testing a single bit avoids allocating a `Set{String}` when checking one allergen.

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
It's possible to submit an incomplete solution so you can see how others have completed the exercise.

## Interactive Notebook
Launch the Pluto notebook from inside `allergies/`:
```bash
julia --project=.. -e 'using Pluto; Pluto.run(notebook="./allergies_pluto.jl")'
```

