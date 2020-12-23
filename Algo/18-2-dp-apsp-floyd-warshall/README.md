# Programming Problem 18-2: All Pairs Shortest Paths

  Using Floyd-Warshall Algorithms


## Work

  - [This file](https://github.com/pascal-p/julia-exercism/blob/master/Algo/18-1-dp-bellman-ford/testfiles/tiny_ewdnc.txt) describes an instance of a weighted edge graph. The format of the file is:

  1st line: number of vertices
  following lines: verte(src) vertex(dst),weight vertex(dst),weight ...

*For example 2nd line is: 1 3,0.26 5,0.38 which means vertex source 1 is linked to vertex 3 with weight 0.26 and vertex 5 with weight 0.38*
*(Answer: negative cycle detected)*

  - In this assignment you will implement one or more algorithms for the all-pairs shortest-path problem.  Here are data files describing three graphs:

  [g1.txt](https://github.com/pascal-p/julia-exercism/blob/master/Algo/18-1-dp-bellman-ford/testfiles/g1.txt)  
  [g2.txt](https://github.com/pascal-p/julia-exercism/blob/master/Algo/18-1-dp-bellman-ford/testfiles/g1.txt)  
  [g3.txt](https://github.com/pascal-p/julia-exercism/blob/master/Algo/18-1-dp-bellman-ford/testfiles/g1.txt)  

*The first line indicates the number of vertices and edges, respectively.  Each subsequent line describes an edge (the first two numbers are its tail and head, respectively) and its length (the third number)*.  
*NOTE: some of the edge lengths are negative.*  
*NOTE: These graphs may or may not have negative-cost cycles.*

Your task is to compute the "shortest shortest path". Precisely, you must first identify which, if any, of the three graphs have no negative cycles.  
For each such graph, you should compute all-pairs shortest paths and remember the smallest one (i.e., compute min⁡_u,v ∈ V d(u,v), where d(u,v) denotes the shortest-path distance from u to v).

If each of the three graphs has a negative-cost cycle, then enter "NULL" in the box below. If exactly one graph has no negative-cost cycles, then enter the length of its shortest shortest path in the box below.  
If two or more of the graphs have no negative-cost cycles, then enter the smallest of the lengths of their shortest shortest paths in the box below.  
*(Answer -19)*  


OPTIONAL: You can use whatever algorithm you like to solve this question.  If you have extra time, try comparing the performance of different all-pairs shortest-path algorithms!

OPTIONAL: Here is a bigger data set to play with.
  [large.txt](https://www.coursera.org/learn/algorithms-npcomplete/exam/cnDtw/programming-assignment-1/attempt)


ref. Coursera/Stanford Algorithms [Shortest Paths Revisited, NP-Complete Problems and What To Do About Them](https://www.coursera.org/learn/algorithms-npcomplete/home/)

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA

<hr />
<p style="font-size:0.25em">Dec. 2020, Corto Inc</p>
