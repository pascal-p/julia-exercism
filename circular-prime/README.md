
## Project Euler: Problem 35: Circular primes

The number, 197, is called a circular prime because all rotations of the digits: 197, 971, and 719, are themselves prime.  
There are thirteen such primes below 100:  
`2, 3, 5, 7, 11, 13, 17, 31, 37, 71, 73, 79, and 97`.  

How many circular primes are there below n, whereas 100 ≤ n ≤ 1_000_000?  

Note:
  - Circular primes individual rotation can exceed n.


## Tests

    circular_primes(100) should return a number.
    circular_primes(100) should return 13.
    circular_primes(100000) should return 43.
    circular_primes(250000) should return 45.
    circular_primes(500000) should return 49.
    circular_primes(750000) should return 49.
    circular_primes(1000000) should return 55.
