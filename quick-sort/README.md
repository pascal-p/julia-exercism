# Sort

    Programming Problem 5.6: QuickSort

### Work

  - Test case #1: 10 integers, representing a 10-element array.  
    Your program should count:
      - 25 comparisons if you always use the first element as the pivot, 
      - 31 comparisons if you always use the last element as the pivot, and 
      - 21 comparisons if you always use the median-of-3 as the pivot (not counting the comparisons used to compute the pivot).
    
  - Test case #2: This file [file_100_num.txt](https://github.com/pascal-p/julia-exercism/blob/master/quick-sort/file_100_num.txt) contains 100 integers, representing a 100-element array.  
    Your program should count:
      - 620 comparisons if you always use the first element as the pivot, 
      - 573 comparisons if you always use the last element as the pivot, and 
      - 502 comparisons if you always use the median-of-3 as the pivot (not counting the comparisons used to compute the pivot).
    
  - Challenge data set: This file [file_10000_num.txt](https://github.com/pascal-p/julia-exercism/blob/master/quick-sort/file_10000_num.txt) contains all of the integers between 1 and 10,000 (inclusive) in some order, with no integer repeated. The ith row of the file indicates the ith entry of an array.  
    How many comparisons does QuickSort make on this input when the first element is always chosen as the pivot? If the last element is always chosen as the pivot? If the median-of-3 is always chosen as the pivot? 


ref. Coursera/Stanford Algorithms [Divide and Conquer, Sorting and Searching, and Randomized Algorithms](https://www.coursera.org/learn/algorithms-divide-conquer)

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA
