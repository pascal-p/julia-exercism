# Implementing Dijkstra's Algorithm

  **Programming Problem 9.8: Shortest Paths** \
  using Dijkstra's Algorithm

## Work

 - Test case: This [file](https://github.com/pascal-p/julia-exercism/blob/master/07-dijkstra-sp/tests/8v_16e.txt) describes an undirected graph with 8 vertices (see below for the file format). What are the shortest-path distances from vertex 1 to every other vertex? (Answer, for vertices 1 through 8, in order: 0,1,2,3,4,4,3,2.)

 - Challenge data set: This [file](https://github.com/pascal-p/julia-exercism/blob/master/07-dijkstra-sp/tests/200e_3734v.txt) contains an adjacency list representation of an undirected graph with 200 vertices labeled 1 to 200.
 First row gives the number of vertices.
 Then each row indicates the edges incident to the given vertex along with their (nonnegative) lengths. For example, the sixth row has a "6" as its first entry indicating that this row corresponds to vertex 6. The next entry of this row "141,8200" indicates that there is an undirected edge between vertex 6 and vertex 141 that has length 8200. The rest of the pairs in this row indicate the other vertices adjacent to vertex 6 and the lengths of the corresponding edges.
 Vertex 1 is the starting vertex.
 What are the shortest-path distances from vertex 1 to the following ten vertices?: 7, 37, 59, 82, 99, 115, 133, 165, 188, 197.

ref. Coursera/Stanford Algorithms [Graph Search, Shortest Paths, and Data Structures](https://www.coursera.org/learn/algorithms-graphs-data-structures/home/welcome)

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA

<hr />
<p><sub><em>Corto Inc, Jan 2021, rev. May 2023</sub></em></p>
