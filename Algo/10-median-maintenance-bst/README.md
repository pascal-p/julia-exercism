# Implementing "Median Maintenance" algorithm

  **Programming Problem 11.3: The Median Maintenance Problem**  
  using a BST data structure


## Work

 - Test case: This [file](https://github.com/pascal-p/julia-exercism/blob/master/Algo/08-median-maintenance/testfiles/problem11.3test.txt) represents a stream of 10 numbers. What are the last 4 digits of the sum of the kth medians?  
 (See below for the definition of the kth median.) (Answer: 9335.)

 - Challenge data set: This [file](https://github.com/pascal-p/julia-exercism/blob/master/Algo/08-median-maintenance/testfiles/problem11.3.txt) contains a list of the integers from 1 to 10000 in unsorted order; you should treat this as a stream of numbers, arriving one by one.
 By the k-th median, we mean the median of the first k numbers in the stream (the ((k+1)/2)th smallest number among the first k if k is odd, the (k/2)th smallest if k is even). What are the last 4 digits of the sum of the kth medians (with k going from 1 to 10000)?  
   Which data structure makes your algorithm faster: two heaps, or a search tree?


ref. Coursera/Stanford Algorithms [Graph Search, Shortest Paths, and Data Structures](https://www.coursera.org/learn/algorithms-graphs-data-structures/home/welcome)

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA
