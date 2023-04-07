# Strassen algorithm for matrix multiplication

## Principle

Given two squared (n × n) matrix X and Y, Calculate the dot product Z = X × Y

The straitghforward (naive) algorithm has a running time of Ω(n³) but we can do better with the Strassen algorithm which sub-cubic.
```
   X (n × n) can be written as |A B|   and Y (n × n) |E F|
                               |C D|                 |G H|

  A, B, ... H are all (n ÷ 2 × n ÷ 2) matrices
```
one property of matrix multiplication is that equal size blocks behave just like individual entries, thus:
```
       X × Y = | A × E + B × G   A × F + B × H |
               | C × E + D × G   C × F + D × H |
```

This leads to a recursive algorithm that sadly is still Ω(n³)

The Strassen algorithm takes this one step further and replaces the 8 multiplications above by 7 carefully chosen ones, thus 1 less recursive call replaced by a constant number of additional additions and substractions. This yields a subcubic running time.

The 7 recursives operations are as followed:
```
     P₁ = A × (F - H)
     P₂ = (A + B) × H
     P₃ = (C + D) × E
     P₄ = D × (G - E)
     P₅ = (A + D) × (E + F)
     P₆ = (B - D) × (G + H)
     P₇ = (A - C) × (E + F)

  X × Y = |P₅ + P₄ - P₂ + P₆        P₁ + P₂     |
          |     P₃ + P₄        P₁ + P₅ - P₃ - P₇|
```

The running time of the Strassen algorithm can be found by using the Master Method (parameterized by 3 var. a, b and d) as follows:
  - a = 7 (number of recursive calls or sub-problems)
  - b = 2 (each sub-problems is half the size of the original one)
  - d = 1 (outside the rec. call we need to do some addtions and subtractions - which is done in linear time)

Therefore: a (= 7) > bᵈ (= 2), master method states that the running time is:
```
  O(n^(log₂(7))) ≈ O(n².⁸¹) (subcubic)
  And actually Ω(n².⁸¹)
```

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA
