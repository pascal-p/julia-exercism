# Johnson Algorithm

 **Programming Problem 18-3: Johnson**  
  All Pairs Shortest Path

ref. Coursera/Stanford Algorithms [Shortest Paths Revisited, NP-Complete Problems and What To Do About Them](https://www.coursera.org/learn/algorithms-npcomplete/home/welcome)

## Work

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


## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA

<hr />
<p style="font-size:0.25em">Dec. 2020, Corto Inc</p>
