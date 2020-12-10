# Knapsack Problem

  **Programming Problem 16: Knapsack**  
  using Dynamic Programming [DP]


## Work
 - Let's start with a warm-up on [this file](https://github.com/pascal-p/julia-exercism/blob/master/Algo/16-dp-knapsack/testfiles/input_knapsack1.txt)

It describes a knapsack instance, and it has the following format:

    [knapsack_size][number_of_items]
    [value_1] [weight_1]
    [value_2] [weight_2]
    ...

*For example, the third line of the file is "50074 659", indicating that the second item has value 50074 and size 659, respectively.*  
You can assume that all numbers are positive. You should assume that item weights and the knapsack capacity are integers.  
In the box below, type in the value of the optimal solution. *Answer: 2_493_893*

  - This problem also asks you to solve a knapsack instance, but a much bigger one.  
  [This file](https://github.com/pascal-p/julia-exercism/blob/master/Algo/16-dp-knapsack/testfiles/input_knapsack_big.txt)
  Same description as above.
  
*For example, the third line of the file is "50074 834558", indicating that the second item has value 50074 and size 834558, respectively. As before, you should assume that item weights and the knapsack capacity are integers.*

This instance is so big that the straightforward iterative implemetation uses an infeasible amount of time and space. So you will have to be creative to compute an optimal solution. One idea is to go back to a recursive implementation, solving subproblems --- and, of course, caching the results to avoid redundant work --- only on an "as needed" basis. Also, be sure to think about appropriate data structures for storing and looking up solutions to subproblems.

In the box below, type in the value of the optimal solution. *Anwser: 4_243_395*


ref. Coursera/Stanford Algorithms [Greedy Algorithms, Minimum Spanning Trees, and Dynamic Programming](https://www.coursera.org/learn/algorithms-greedy/home/welcome)

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA

<hr />
<p style="font-size:0.25em">Dec. 2020, Corto Inc</p>
