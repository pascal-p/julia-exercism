# Next VersionFavorite Number

## Description

Let f(n) = ( n + 1 )
           (   2   )

( n )
( k ) is Binomial coefficient.

You need to represent the given number N like this:

n = f(i) + f(j) + f(k), which is possible ∀ n ∈ N

For example:

`34 = f(0) + f(3) + f(7) = f(2) + f(4) + f(6)`
`69 = f(0) + f(2) + f(11) = f(2) + f(6) + f(9)`

As you can see, there can be multiple representations for one n, so return any representation [f(i), f(j), f(k)] in any order.

represent(34) = `[0, 6, 28]` or represent(34) = `[3, 10, 21]`

In this kata all the tests will be with 1⩽N⩽2666 1 \leqslant N \leqslant 2^{666} 1⩽N⩽2666


## Source

ref. https://www.codewars.com/kata/638f6152d03d8b0023fa58e3
