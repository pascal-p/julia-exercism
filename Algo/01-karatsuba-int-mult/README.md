# Karatsuba’s integer multiplication algorithm

Implement Karatsuba’s integer multiplication algorithm in your favorite programming language. To get the most out of this problem, your program should invoke the language’s multiplication operator only on pairs of single-digit numbers.  

For a concrete challenge, what’s the product of the following two 64-digit numbers?  
`3141592653589793238462643383279502884197169399375105820974944592`  
`2718281828459045235360287471352662497757247093699959574966967627`  

ref. Coursera/Stanford Algorithms [Divide and Conquer, Sorting and Searching, and Randomized Algorithms](https://www.coursera.org/learn/algorithms-divide-conquer)

## Examples

To compute the product of 12345 and 6789, where `B=10`, choose `m=3`. 
We use m right shifts for decomposing the input operands using the resulting base (B<sup>m</sup> = 1000), as:  

<pre>
    12345 = 12 × 1000 + 345  
    6789 = 6 × 1000 + 789
</pre>

Only three multiplications, which operate on smaller integers, are used to compute three partial results:  

<pre>
    z<sub>2</sub> = 12 × 6 = 72
    z<sub>0</sub> = 345 × 789 = 272205
    z<sub>1</sub> = (12 + 345) × (6 + 789) - z<sub>2</sub> - z<sub>0</sub> = 357 × 795 - 72 - 272205 = 283815 - 72 - 272205 = 11538$
</pre>

We get the result by just adding these three partial results, shifted accordingly (and then taking carries into account by decomposing these three inputs in base 1000 like for the input operands):

<pre>
  result = z<sub>2</sub> × B<sup>(m × 2)</sup> + z<sub>1</sub> × B<sup>m</sup> + z<sub>0</sub>, i.e.
  result = 72 × 1000<sup>2</sup> + 11_538 × 1000 + 272_205 = 83_810_205
</pre>

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA
