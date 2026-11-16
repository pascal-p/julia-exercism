## Exercism - Julia Programming Languages

Practicing Julia.

Check https://exercism.io/tracks/julia

Aug-Nov 2020, 2021, 2022

## Algorithms Specialization - Standford / Coursera
Instructor: [Tim Roughgarden](https://www.coursera.org/instructor/~768)

Julia Programming Implementation. Check [Algorithm Implementation here](https://github.com/pascal-p/YaAlgo)

Nov-Dec 2020, Jan 2021

## Tooling (`tools/check.jl`)

Run syntax, formatting (`JuliaFormatter`), static analysis (`JET`), and tests for any exercise from the repository root:

```bash
# Check syntax, formatting, and run tests
julia --project=. tools/check.jl <exercise>

# Format in-place and run tests
julia --project=. tools/check.jl <exercise> --fmt

# Include JET static analysis (and optionally skip tests with --no-test)
julia --project=. tools/check.jl <exercise> --jet
```

Wrap any block (e.g., hand-aligned test tables) with `#! format: off` / `#! format: on` to exclude it from `JuliaFormatter`.

<hr />
<p><sub><em>2020-2026 Corto Inc</sub></em></p>
