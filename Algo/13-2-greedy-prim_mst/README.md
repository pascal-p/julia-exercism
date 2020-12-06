# Implementing "Prim's Minimum Spanning Tree" Algorithm

  **Programming Problem 13.2: Prim's MST** using a heap data-structure


## Work

 - Challenge data set: This [file](https://github.com/pascal-p/julia-exercism/blob/master/Algo/13-2-greedy-alg_mst/testfiles/edges.txt) 

 This file describes a set of jobs with positive and integral weights and lengths. It has the format

        [number_of_nodes] [number_of_edges]
        [one_node_of_edge_1] [other_node_of_edge_1] [edge_1_cost]
        [one_node_of_edge_2] [other_node_of_edge_2] [edge_2_cost]
        ...

*For example, the third line of the file is "2 3 -8874", indicating that there is an edge connecting vertex #2 and vertex #3 that has cost -8874.*

You should NOT assume that edge costs are positive, nor should you assume that they are distinct.

Your task is to run Prim's minimum spanning tree algorithm on this graph. You should report the overall cost of a minimum spanning tree --- an integer, which may or may not be negative --- in the box below. *Answer: -3_612_829*

ref. Coursera/Stanford Algorithms [Greedy Algorithms, Minimum Spanning Trees, and Dynamic Programming](https://www.coursera.org/learn/algorithms-greedy/home/welcome)

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA  

<p style="font-size:0.25em">Dec. 2020, Corto Inc</p>
