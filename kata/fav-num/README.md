# Next VersionFavorite Number

## Description

Let

$$f(n) = \left(
  \begin{array}{c}
   n + 1 \\
   2
  \end{array}
\right)
$$

where:

$$f(n) = \left(
  \begin{array}{c}
   n \\
   k
  \end{array}
\right)
$$

is Binomial coefficient.

You need to represent the given number N like this: $n = f(i) + f(j) + f(k), ∀ n ∈ N$

which is possible if repetitions are allowed.\
Here we have the _additional constraint on i ≠ j ≠ k, hence some numbers cannot be decomposed...

For example:

- `34 = f(0) + f(3) + f(7) = f(2) + f(4) + f(6)`
- `69 = f(0) + f(2) + f(11) = f(2) + f(6) + f(9)`

As you can see, there can be multiple representations for one n, so return any representation $[f(i), f(j), f(k)]$ in any order.

represent(34) = `[0, 6, 28]` or represent(34) = `[3, 10, 21]`


However:
`0, 1, 2, 3, 5, 6, 8, 12, 15, 20 have no decomposition...`

In this kata all the tests will be with $1 ≤  N ≤ 2^{666}$


## Source

ref. https://www.codewars.com/kata/638f6152d03d8b0023fa58e3
