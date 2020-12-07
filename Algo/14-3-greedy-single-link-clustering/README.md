# Computing a max-spacing k-clustering.

  **Programming Problem 14.3: max-spacing k-clustering**  
  using Kruskal MST


## Work

 - Challenge data set: This [file](https://github.com/pascal-p/julia-exercism/blob/master/Algo/.../clustering1.txt)

This file describes a distance function (equivalently, a complete graph with edge costs). It has the following format:

    [number_of_nodes]
    [edge 1 node 1] [edge 1 node 2] [edge 1 cost]
    [edge 2 node 1] [edge 2 node 2] [edge 2 cost]
    ...

There is one edge (i,j) for each choice of 1 ≤ i < j ≤ n, where n is the number of nodes.

*For example, the third line of the file is `"1 3 5250"`, indicating that the distance between nodes 1 and 3 (equivalently, the cost of the edge (1,3)) is 5250. You can assume that distances are positive, but you should NOT assume that they are distinct.*

Your task in this problem is to run the clustering algorithm from lecture on this data set, where the target number k of clusters is set to 4. What is the maximum spacing of a 4-clustering? *Answer: 106*

ref. Coursera/Stanford Algorithms [Greedy Algorithms, Minimum Spanning Trees, and Dynamic Programming](https://www.coursera.org/learn/algorithms-greedy/home/welcome)

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA

<hr />
<p style="font-size:0.25em">Dec. 2020, Corto Inc</p>
